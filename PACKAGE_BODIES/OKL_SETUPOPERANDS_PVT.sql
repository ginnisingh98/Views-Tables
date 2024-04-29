--------------------------------------------------------
--  DDL for Package Body OKL_SETUPOPERANDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPOPERANDS_PVT" AS
/* $Header: OKLRSOPB.pls 115.12 2003/07/23 19:05:44 sgorantl noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.SETUP.OPERANDS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

-- Not required as new version will not be created while updating the operand
/*
---------------------------------------------------------------------------
  -- PROCEDURE get_version to calculate the new version number for the
  -- operand to be created
  ---------------------------------------------------------------------------
  PROCEDURE get_version(p_opdv_rec						IN opdv_rec_type,
  						x_return_status					OUT NOCOPY VARCHAR2,
						x_new_version					OUT NOCOPY VARCHAR2) IS
    CURSOR okl_opd_laterversionsexist_csr (p_name IN Okl_Operands_V.NAME%TYPE,
		   					               p_date IN Okl_Operands_V.END_DATE%TYPE) IS
    SELECT '1'
    FROM Okl_Operands_V
    WHERE name = p_name
	AND NVL(end_date,p_date) > p_date;

	l_check			VARCHAR2(1) := '?';
	l_row_not_found	BOOLEAN := FALSE;
  BEGIN
  	   IF p_opdv_rec.version = OKL_API.G_MISS_CHAR THEN
	   	  x_new_version := G_INIT_VERSION;
	   ELSE
          -- Check for future versions of the same formula
		  OPEN okl_opd_laterversionsexist_csr (p_opdv_rec.name,
							  			 	   p_opdv_rec.end_date);
    	  FETCH okl_opd_laterversionsexist_csr INTO l_check;
    	  l_row_not_found := okl_opd_laterversionsexist_csr%NOTFOUND;
    	  CLOSE okl_opd_laterversionsexist_csr;

    	  IF l_row_not_found = TRUE then
  	   	   	 x_new_version := TO_CHAR(TO_NUMBER(p_opdv_rec.version, G_VERSION_FORMAT)
			                  + G_VERSION_MAJOR_INCREMENT, G_VERSION_FORMAT);
		  ELSE
		  	 x_new_version := TO_CHAR(TO_NUMBER(p_opdv_rec.version, G_VERSION_FORMAT)
			 			   	  + G_VERSION_MINOR_INCREMENT, G_VERSION_FORMAT);
    	  END IF;
	   END IF;

	   x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	sqlcode,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	sqlerrm);
	   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

       IF (okl_opd_laterversionsexist_csr%ISOPEN) THEN
	   	  CLOSE okl_opd_laterversionsexist_csr;
       END IF;

  END get_version;

*/

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_OPERANDS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_opdv_rec                     IN opdv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_opdv_rec					   OUT NOCOPY opdv_rec_type
  ) IS
    CURSOR okl_opdv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            NVL(FMA_ID, OKL_API.G_MISS_NUM) FMA_ID,
			NVL(DSF_ID, OKL_API.G_MISS_NUM) DSF_ID,
            OPD_TYPE,
            NAME,
            NVL(DESCRIPTION,OKL_API.G_MISS_CHAR) DESCRIPTION,
            VERSION,
            START_DATE,
            NVL(END_DATE,OKL_API.G_MISS_DATE) END_DATE,
            NVL(ORG_ID,  OKL_API.G_MISS_NUM) ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, OKL_API.G_MISS_NUM) LAST_UPDATE_LOGIN
      FROM Okl_Operands_V
     WHERE okl_operands_v.id    = p_id;
    l_okl_opdv_pk                  okl_opdv_pk_csr%ROWTYPE;
    l_opdv_rec                     opdv_rec_type;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_opdv_pk_csr (p_opdv_rec.id);
    FETCH okl_opdv_pk_csr INTO
              l_opdv_rec.ID,
              l_opdv_rec.OBJECT_VERSION_NUMBER,
              l_opdv_rec.SFWT_FLAG,
              l_opdv_rec.FMA_ID,
              l_opdv_rec.DSF_ID,
              l_opdv_rec.OPD_TYPE,
              l_opdv_rec.NAME,
              l_opdv_rec.DESCRIPTION,
              l_opdv_rec.VERSION,
              l_opdv_rec.START_DATE,
              l_opdv_rec.END_DATE,
              l_opdv_rec.ORG_ID,
              l_opdv_rec.CREATED_BY,
              l_opdv_rec.CREATION_DATE,
              l_opdv_rec.LAST_UPDATED_BY,
              l_opdv_rec.LAST_UPDATE_DATE,
              l_opdv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_opdv_pk_csr%NOTFOUND;
    CLOSE okl_opdv_pk_csr;
    x_opdv_rec := l_opdv_rec;
EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	sqlcode,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	sqlerrm);
		-- notify UNEXPECTED error for calling API.
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      IF (okl_opdv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_opdv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_fma_opd_dates for: OKL_FORMULAE_V
  -- To fetch the operands that are attached to the existing version of the
  -- function and verify the dates for the both
  ---------------------------------------------------------------------------
  PROCEDURE check_fma_opd_dates (p_upd_opdv_rec      IN  opdv_rec_type,
                                 p_opdv_rec      	 IN opdv_rec_type,
							   	 x_return_status     OUT NOCOPY VARCHAR2
  ) IS

    CURSOR okl_fma_linkedopds_csr (p_fma_id IN Okl_Operands_V.fma_id%TYPE,
		   						   p_start_date DATE, p_end_date DATE) IS
   SELECT '1'
   FROM Okl_Formulae_B fma
   WHERE fma.ID 	=  p_fma_id
   AND ((fma.start_date > p_start_date) OR
  	  (fma.end_date < NVL(p_end_date, TO_DATE('31/12/9999', 'DD/MM/YYYY')))) ;

	l_check 			VARCHAR2(1);
	l_not_found 		BOOLEAN := TRUE;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

   OPEN okl_fma_linkedopds_csr (p_upd_opdv_rec.fma_id, p_upd_opdv_rec.start_date, p_upd_opdv_rec.end_date);
   FETCH okl_fma_linkedopds_csr INTO l_check;
   l_not_found := okl_fma_linkedopds_csr%NOTFOUND;
   CLOSE okl_fma_linkedopds_csr;

   IF NOT l_not_found THEN
		OKL_API.SET_MESSAGE(p_app_name	  => G_APP_NAME,
						   p_msg_name	  => G_DATES_MISMATCH,
						   p_token1		  => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => 'Formulae',
						   p_token2		  => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => 'Operands');
		RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
		x_return_status := OKL_API.G_RET_STS_ERROR;

      IF (okl_fma_linkedopds_csr%ISOPEN) THEN
	   	  CLOSE okl_fma_linkedopds_csr;
      END IF;

	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	    =>	G_APP_NAME,
							p_msg_name		=>	G_UNEXPECTED_ERROR,
							p_token1		=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	sqlcode,
							p_token2		=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	sqlerrm);
		-- notify UNEXPECTED error for calling API.
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      IF (okl_fma_linkedopds_csr%ISOPEN) THEN
	   	  CLOSE okl_fma_linkedopds_csr;
      END IF;

  END check_fma_opd_dates;


  ---------------------------------------------------------------------------
  -- PROCEDURE check_dsf_opd_dates for: OKL_FORMULAE_V
  -- To fetch the operands that are attached to the existing version of the
  -- function and verify the dates for the both
  ---------------------------------------------------------------------------
  PROCEDURE check_dsf_opd_dates (p_upd_opdv_rec      IN  opdv_rec_type,
                                 p_opdv_rec      	 IN opdv_rec_type,
							   	 x_return_status     OUT NOCOPY VARCHAR2
  ) IS

    CURSOR okl_dsf_linkedopds_csr (p_dsf_id IN Okl_Operands_V.dsf_id%TYPE,
		   						   p_start_date DATE, p_end_date DATE) IS
   SELECT '1'
   FROM OKL_DATA_SRC_FNCTNS_B dsf
   WHERE dsf.ID 	=  p_dsf_id
   AND ((dsf.start_date > p_start_date) OR
  	  (dsf.end_date < NVL(p_end_date, TO_DATE('31/12/9999', 'DD/MM/YYYY')))) ;

	l_check 			VARCHAR2(1);
	l_not_found 		BOOLEAN := TRUE;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

   OPEN okl_dsf_linkedopds_csr (p_upd_opdv_rec.dsf_id, p_upd_opdv_rec.start_date, p_upd_opdv_rec.end_date);
   FETCH okl_dsf_linkedopds_csr INTO l_check;
   l_not_found := okl_dsf_linkedopds_csr%NOTFOUND;
   CLOSE okl_dsf_linkedopds_csr;

   IF NOT l_not_found THEN
		OKL_API.SET_MESSAGE(p_app_name	  => G_APP_NAME,
						   p_msg_name	  => G_DATES_MISMATCH,
						   p_token1		  => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => 'Functions',
						   p_token2		  => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => 'Operands');
		RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
		x_return_status := OKL_API.G_RET_STS_ERROR;

      IF (okl_dsf_linkedopds_csr%ISOPEN) THEN
	   	  CLOSE okl_dsf_linkedopds_csr;
      END IF;

	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	    =>	G_APP_NAME,
							p_msg_name		=>	G_UNEXPECTED_ERROR,
							p_token1		=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	sqlcode,
							p_token2		=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	sqlerrm);
		-- notify UNEXPECTED error for calling API.
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      IF (okl_dsf_linkedopds_csr%ISOPEN) THEN
	   	  CLOSE okl_dsf_linkedopds_csr;
      END IF;

  END check_dsf_opd_dates;



-- Not required as new version will not be created while updating the operand
/*

  ---------------------------------------------------------------------------
  -- PROCEDURE check_overlaps for: OKL_OPERANDS_V
  -- To avoid overlapping of dates with other versions of the same operand
  ---------------------------------------------------------------------------
  PROCEDURE check_overlaps (
    p_opdv_rec                     IN opdv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_valid                		   OUT NOCOPY BOOLEAN
  ) IS
  	CURSOR okl_opd_overlaps_csr (p_id  		  IN Okl_Operands_V.ID%TYPE,
		   						 p_name   	  IN Okl_Operands_V.NAME%TYPE,
		   					     p_start_date IN Okl_Operands_V.START_DATE%TYPE,
								 p_end_date   IN Okl_Operands_V.END_DATE%TYPE
	) IS
	SELECT '1'
	FROM Okl_Operands_V
	WHERE NAME = p_name
	AND   ID <> p_id
	AND	  (p_start_date BETWEEN START_DATE AND NVL(END_DATE, OKL_API.G_MISS_DATE) OR
		   p_end_date BETWEEN START_DATE AND NVL(END_DATE, OKL_API.G_MISS_DATE))
    UNION ALL
	SELECT '2'
	FROM Okl_Operands_V
	WHERE NAME = p_name
	AND   ID <> p_id
	AND	  p_start_date <= START_DATE
	AND   p_end_date >= NVL(END_DATE, OKL_API.G_MISS_DATE);

	l_check            VARCHAR2(1) := '?';
	l_row_not_found	   BOOLEAN := FALSE;
  BEGIN
    x_valid := TRUE;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Check for operands overlaps
    OPEN okl_opd_overlaps_csr (p_opdv_rec.id,
		 					   p_opdv_rec.name,
		 					   p_opdv_rec.start_date,
							   p_opdv_rec.end_date);
    FETCH okl_opd_overlaps_csr INTO l_check;
    l_row_not_found := okl_opd_overlaps_csr%NOTFOUND;
    CLOSE okl_opd_overlaps_csr;

    IF l_row_not_found = FALSE then
	   OKL_API.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_OPD_VERSION_OVERLAPS);
	   x_valid := FALSE;
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	sqlcode,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	sqlerrm);
	   x_valid := FALSE;
	   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

       IF (okl_opd_overlaps_csr%ISOPEN) THEN
	   	  CLOSE okl_opd_overlaps_csr;
       END IF;

  END check_overlaps;

*/
-- Not required as new version will not be created while updating the operand
/*
  ---------------------------------------------------------------------------
  -- PROCEDURE check_constraints for: OKL_OPERANDS_V
  -- To verify whether the dates are valid for both formula and operands
  -- attached to it
  ---------------------------------------------------------------------------
  PROCEDURE check_constraints (
    p_opdv_rec                     IN opdv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_valid                		   OUT NOCOPY BOOLEAN
  ) IS
    CURSOR okl_opd_dsf_fk_csr (p_dsf_id IN Okl_Operands_V.dsf_id%TYPE,
		   					   p_start_date  IN Okl_Operands_V.START_DATE%TYPE,
							   p_end_date 	 IN Okl_Operands_V.END_DATE%TYPE

	) IS
    SELECT '1'
    FROM Okl_Data_Src_Fnctns_V dsf
     WHERE dsf.ID    = p_dsf_id
	 AND   (dsf.START_DATE > p_start_date OR
	 	    NVL(dsf.END_DATE, p_end_date) < p_end_date);

    CURSOR okl_opd_fma_fk_csr (p_fma_id IN Okl_Operands_V.fma_id%TYPE,
		   					   p_start_date  IN Okl_Operands_V.START_DATE%TYPE,
							   p_end_date 	 IN Okl_Operands_V.END_DATE%TYPE

	) IS
    SELECT '1'
    FROM Okl_Formulae_V fma
     WHERE fma.ID    = p_fma_id
	 AND   (fma.START_DATE > p_start_date OR
	 	    NVL(fma.END_DATE, p_end_date) < p_end_date);

    l_opdv_rec      opdv_rec_type;
	l_check		   	VARCHAR2(1) := '?';
	l_row_not_found	BOOLEAN := FALSE;
  BEGIN
    x_valid := TRUE;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Check for data function dates
	IF p_opdv_rec.dsf_id IS NOT NULL AND p_opdv_rec.dsf_id <> OKL_API.G_MISS_NUM THEN
	   OPEN okl_opd_dsf_fk_csr (p_opdv_rec.dsf_id,
		 					    p_opdv_rec.start_date,
							 	p_opdv_rec.end_date);
       FETCH okl_opd_dsf_fk_csr INTO l_check;
       l_row_not_found := okl_opd_dsf_fk_csr%NOTFOUND;
       CLOSE okl_opd_dsf_fk_csr;

       IF l_row_not_found = FALSE then
	   	  OKL_API.SET_MESSAGE(p_app_name	  => G_APP_NAME,
							  p_msg_name	  => G_DATES_MISMATCH,
						      p_token1		  => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => 'Okl_Data_Src_Fnctns_V',
						      p_token2		  => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => 'Okl_Operands_V');
	   	  x_valid := FALSE;
       	  x_return_status := OKL_API.G_RET_STS_ERROR;
		  RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;
	END IF;

    -- Check for formulae dates
	IF p_opdv_rec.fma_id IS NOT NULL AND p_opdv_rec.fma_id <> OKL_API.G_MISS_NUM THEN
       OPEN okl_opd_fma_fk_csr (p_opdv_rec.fma_id,
		 					    p_opdv_rec.start_date,
							    p_opdv_rec.end_date);
       FETCH okl_opd_fma_fk_csr INTO l_check;
       l_row_not_found := okl_opd_fma_fk_csr%NOTFOUND;
       CLOSE okl_opd_fma_fk_csr;

       IF l_row_not_found = FALSE then
	   	  OKL_API.SET_MESSAGE(p_app_name	  => G_APP_NAME,
							  p_msg_name	  => G_DATES_MISMATCH,
						      p_token1		  => G_PARENT_TABLE_TOKEN,
						      p_token1_value  => 'Okl_Formulae_V',
						      p_token2		  => G_CHILD_TABLE_TOKEN,
						      p_token2_value  => 'Okl_Operands_V');
	      x_valid := FALSE;
       	  x_return_status := OKL_API.G_RET_STS_ERROR;
		  RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;
	END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column

       IF (okl_opd_dsf_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_opd_dsf_fk_csr;
       END IF;

       IF (okl_opd_fma_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_opd_fma_fk_csr;
       END IF;

	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	sqlcode,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	sqlerrm);
	   x_valid := FALSE;
	   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

       IF (okl_opd_dsf_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_opd_dsf_fk_csr;
       END IF;

       IF (okl_opd_fma_fk_csr%ISOPEN) THEN
	   	  CLOSE okl_opd_fma_fk_csr;
       END IF;

  END check_constraints;

*/


  ---------------------------------------------------------------------------
  -- FUNCTION defaults_to_actuals
  -- This function creates an output record with changed information from the
  -- input structure and unchanged details from the database
  ---------------------------------------------------------------------------
  FUNCTION defaults_to_actuals (
    p_upd_opdv_rec                 IN opdv_rec_type,
	p_db_opdv_rec				   IN opdv_rec_type
  ) RETURN opdv_rec_type IS
  l_opdv_rec	opdv_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_opdv_rec := p_db_opdv_rec;

	   IF p_upd_opdv_rec.description <> OKL_API.G_MISS_CHAR THEN
	  	  l_opdv_rec.description := p_upd_opdv_rec.description;
	   END IF;

	   IF p_upd_opdv_rec.start_date <> OKL_API.G_MISS_DATE THEN
	  	  l_opdv_rec.start_date := p_upd_opdv_rec.start_date;
	   END IF;

	   IF p_upd_opdv_rec.end_date <> OKL_API.G_MISS_DATE THEN
	   	  l_opdv_rec.end_date := p_upd_opdv_rec.end_date;
	   END IF;

	   IF p_upd_opdv_rec.fma_id <> OKL_API.G_MISS_NUM THEN
	   	  l_opdv_rec.fma_id := p_upd_opdv_rec.fma_id;
	   END IF;

	   IF p_upd_opdv_rec.dsf_id <> OKL_API.G_MISS_NUM THEN
	   	  l_opdv_rec.dsf_id := p_upd_opdv_rec.dsf_id;
	   END IF;

	   IF p_upd_opdv_rec.opd_type <> OKL_API.G_MISS_CHAR THEN
	   	  l_opdv_rec.opd_type := p_upd_opdv_rec.opd_type;
	   END IF;

	   IF p_upd_opdv_rec.source <> OKL_API.G_MISS_CHAR THEN
	   	  l_opdv_rec.source := p_upd_opdv_rec.source;
	   END IF;

	   IF p_upd_opdv_rec.org_id <> OKL_API.G_MISS_NUM THEN
	   	  l_opdv_rec.org_id := p_upd_opdv_rec.org_id;
	   END IF;

	   RETURN l_opdv_rec;
  END defaults_to_actuals;

  ---------------------------------------------------------------------------
  -- PROCEDURE reorganize_inputs
  -- This procedure is to reset the attributes in the input structure based
  -- on the data from database
  ---------------------------------------------------------------------------
  PROCEDURE reorganize_inputs (
    p_upd_opdv_rec                 IN OUT NOCOPY opdv_rec_type,
	p_db_opdv_rec				   IN opdv_rec_type
  ) IS
  l_upd_opdv_rec	opdv_rec_type;
  l_db_opdv_rec     opdv_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_upd_opdv_rec := p_upd_opdv_rec;
       l_db_opdv_rec := p_db_opdv_rec;

	   IF l_upd_opdv_rec.description = l_db_opdv_rec.description THEN
	  	  l_upd_opdv_rec.description := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF to_date(to_char(l_upd_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_opdv_rec.start_date := OKL_API.G_MISS_DATE;
	   END IF;

	   IF to_date(to_char(l_upd_opdv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_opdv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_opdv_rec.end_date := OKL_API.G_MISS_DATE;
	   END IF;

	   IF l_upd_opdv_rec.opd_type = l_db_opdv_rec.opd_type THEN
	   	  l_upd_opdv_rec.opd_type := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_opdv_rec.fma_id = l_db_opdv_rec.fma_id THEN
	   	  l_upd_opdv_rec.fma_id := OKL_API.G_MISS_NUM;
	   END IF;

	   IF l_upd_opdv_rec.dsf_id = l_db_opdv_rec.dsf_id THEN
	   	  l_upd_opdv_rec.dsf_id := OKL_API.G_MISS_NUM;
	   END IF;

	   IF l_upd_opdv_rec.source = l_db_opdv_rec.source THEN
	   	  l_upd_opdv_rec.source := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_opdv_rec.org_id = l_db_opdv_rec.org_id THEN
	   	  l_upd_opdv_rec.org_id := OKL_API.G_MISS_NUM;
	   END IF;

       /* reset attributes based on opd_type */
       IF l_upd_opdv_rec.opd_type = G_FORMULA_TYPE THEN
          l_upd_opdv_rec.dsf_id := NULL;
          l_upd_opdv_rec.source := NULL;
       ELSIF l_upd_opdv_rec.opd_type = G_FUNCTION_TYPE THEN
          l_upd_opdv_rec.fma_id := NULL;
          l_upd_opdv_rec.source := NULL;
       ELSIF l_upd_opdv_rec.opd_type = G_CONSTANT_TYPE THEN
          l_upd_opdv_rec.fma_id := NULL;
          l_upd_opdv_rec.dsf_id := NULL;
       END IF;

       p_upd_opdv_rec := l_upd_opdv_rec;

  END reorganize_inputs;

/*
  ---------------------------------------------------------------------------
  -- PROCEDURE check_opd_fma_dates for: OKL_OPERANDS_V
  -- To fetch the formulae that are attached to the existing version of the
  -- operand
  ---------------------------------------------------------------------------
  PROCEDURE check_opd_fma_dates (p_upd_opdv_rec      IN opdv_rec_type,
                                 p_opdv_rec      	 IN opdv_rec_type,
							   	 x_return_status     OUT NOCOPY VARCHAR2
  ) IS
    CURSOR okl_opd_linkedfmas_csr (p_opd_id IN Okl_Fmla_Oprnds_V.opd_id%TYPE) IS
    SELECT fma.ID ID,
		   fma.START_DATE START_DATE,
		   NVL(fma.END_DATE, OKL_API.G_MISS_DATE) END_DATE
    FROM Okl_Fmla_Oprnds_V fod,
		 Okl_Formulae_V fma
    WHERE fod.opd_ID    = p_opd_id
	AND   fma.ID = fod.FMA_ID;

  	l_return_status 	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_min_start_date 	DATE := NULL;
	l_max_end_date	 	DATE := NULL;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Get current database values
	FOR okl_opd_linkedfmas_rec in okl_opd_linkedfmas_csr(p_upd_opdv_rec.id)
	LOOP
	   IF l_min_start_date = NULL AND l_max_end_date = NULL THEN
	   	  l_min_start_date := okl_opd_linkedfmas_rec.START_DATE;
	   	  l_max_end_date := okl_opd_linkedfmas_rec.END_DATE;
	   ELSE
	   	  IF l_min_start_date > okl_opd_linkedfmas_rec.START_DATE THEN
	   		 l_min_start_date := okl_opd_linkedfmas_rec.START_DATE;
		  END IF;

	   	  IF l_max_end_date < okl_opd_linkedfmas_rec.END_DATE THEN
	   		 l_max_end_date := okl_opd_linkedfmas_rec.END_DATE;
		  END IF;
	   END IF;
	END LOOP;

    IF p_opdv_rec.start_date > l_min_start_date OR
	   p_opdv_rec.end_date < l_max_end_date THEN
	   OKL_API.SET_MESSAGE(p_app_name	  => G_APP_NAME,
						   p_msg_name	  => G_DATES_MISMATCH,
						   p_token1		  => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => 'Okl_Data_Src_Fnctns_V',
						   p_token2		  => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => 'Okl_Formulae_V');
       RAISE G_EXCEPTION_HALT_PROCESSING;
    END IF;

EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
		x_return_status := OKL_API.G_RET_STS_ERROR;

      IF (okl_opd_linkedfmas_csr%ISOPEN) THEN
	   	  CLOSE okl_opd_linkedfmas_csr;
      END IF;

	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	sqlcode,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	sqlerrm);
		-- notify UNEXPECTED error for calling API.
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      IF (okl_opd_linkedfmas_csr%ISOPEN) THEN
	   	  CLOSE okl_opd_linkedfmas_csr;
      END IF;

  END check_opd_fma_dates;

*/
-- Not required as new version will not be created while updating the operand
/*
  ---------------------------------------------------------------------------
  -- PROCEDURE check_updates
  -- To verify whether the requested changes from the screen are valid or not
  ---------------------------------------------------------------------------
  PROCEDURE check_updates (
    p_upd_opdv_rec                 IN opdv_rec_type,
	p_db_opdv_rec				   IN opdv_rec_type,
	p_opdv_rec					   IN opdv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2
  ) IS
  l_opdv_rec	  opdv_rec_type;
  l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_valid		  BOOLEAN;
  l_attrib_tbl	okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
	   x_return_status := OKL_API.G_RET_STS_SUCCESS;
	   l_opdv_rec := p_opdv_rec;

	   IF p_upd_opdv_rec.start_date <> OKL_API.G_MISS_DATE OR
	   	  p_upd_opdv_rec.end_date <> OKL_API.G_MISS_DATE THEN

       	          -- call check_overlaps
		  l_attrib_tbl(1).attribute := 'NAME';
	  	  l_attrib_tbl(1).attrib_type	:= okl_accounting_util.G_VARCHAR2;
		  l_attrib_tbl(1).value	:= l_opdv_rec.name;

	          okl_accounting_util.check_overlaps (p_id                         => l_opdv_rec.id,
		                                      p_attrib_tbl                 => l_attrib_tbl,
		                                      p_start_date_attribute_name  => 'START_DATE',
		                                      p_start_date                 => l_opdv_rec.start_date,
		                                      p_end_date_attribute_name    => 'END_DATE',
		                                      p_end_date                   => l_opdv_rec.end_date,
		                                      p_view                       => 'Okl_Operands_V',
		                                      x_return_status              => l_return_status,
		                                      x_valid                      => l_valid);


       	  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		 x_return_status    := OKL_API.G_RET_STS_UNEXP_ERROR;
      	  	 RAISE G_EXCEPTION_HALT_PROCESSING;
       	  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) OR
		  	    (l_return_status = OKL_API.G_RET_STS_SUCCESS AND
		   	     l_valid <> TRUE) THEN
       		 x_return_status    := OKL_API.G_RET_STS_ERROR;
      	  	 RAISE G_EXCEPTION_HALT_PROCESSING;
       	  END IF;

	   END IF;

	   IF p_upd_opdv_rec.opd_type <> OKL_API.G_MISS_CHAR OR
	   	  p_upd_opdv_rec.fma_id <> OKL_API.G_MISS_NUM OR
		  p_upd_opdv_rec.dsf_id <> OKL_API.G_MISS_NUM THEN

	   	  -- call check_constraints
	   	  check_constraints(p_opdv_rec 	 	 => l_opdv_rec,
						    x_return_status	 => l_return_status,
						 	x_valid			 => l_valid);
       	  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       	  	 x_return_status    := OKL_API.G_RET_STS_UNEXP_ERROR;
      	  	 RAISE G_EXCEPTION_HALT_PROCESSING;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) OR
		  	     (l_return_status = OKL_API.G_RET_STS_SUCCESS AND
		   	      l_valid <> TRUE) THEN
       	     x_return_status    := OKL_API.G_RET_STS_ERROR;
      	  	 RAISE G_EXCEPTION_HALT_PROCESSING;
          END IF;
	   END IF;

	   -- call check_opd_fma_dates
  	   check_opd_fma_dates (p_upd_opdv_rec  => p_upd_opdv_rec,
                            p_opdv_rec      => p_opdv_rec,
  						    x_return_status => l_return_status);
       IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  x_return_status    := OKL_API.G_RET_STS_UNEXP_ERROR;
      	  RAISE G_EXCEPTION_HALT_PROCESSING;
	   ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  x_return_status    := OKL_API.G_RET_STS_ERROR;
      	  RAISE G_EXCEPTION_HALT_PROCESSING;
       END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE( p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END check_updates;

*/
-- Not required as new version will not be created while updating the operand
/*
  ---------------------------------------------------------------------------
  -- FUNCTION determine_action for: OKL_OPERANDS_V
  -- This function helps in determining the various checks to be performed
  -- for the new/updated record and also helps in determining whether a new
  -- version is required or not
  ---------------------------------------------------------------------------
  FUNCTION determine_action (
    p_upd_opdv_rec                 IN opdv_rec_type,
	p_db_opdv_rec				   IN opdv_rec_type,
	p_date						   IN DATE
  ) RETURN VARCHAR2 IS
  l_action VARCHAR2(1);
  l_sysdate DATE := trunc(SYSDATE);
  BEGIN
  -- Scenario 1: Only description and/or descriptive flexfield changes
  IF to_date(to_char(p_upd_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	 to_date(to_char(p_upd_opdv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	 p_upd_opdv_rec.opd_type = OKL_API.G_MISS_CHAR AND
	 p_upd_opdv_rec.fma_id = OKL_API.G_MISS_NUM AND
	 p_upd_opdv_rec.dsf_id = OKL_API.G_MISS_NUM AND
	 p_upd_opdv_rec.source = OKL_API.G_MISS_CHAR THEN
	 l_action := '1';
	-- Scenario 2: only changing description/descriptive flexfield changes
	--   and end date for all records or changing anything for a future record other
	--   than start date or modified start date is less than existing start date
  ELSIF (to_date(to_char(p_upd_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
         (to_date(to_char(p_upd_opdv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') OR
          p_upd_opdv_rec.end_date IS NULL) AND
	     p_upd_opdv_rec.opd_type = OKL_API.G_MISS_CHAR AND
	     p_upd_opdv_rec.fma_id = OKL_API.G_MISS_NUM AND
		 p_upd_opdv_rec.dsf_id = OKL_API.G_MISS_NUM AND
		 p_upd_opdv_rec.source = OKL_API.G_MISS_CHAR) OR
	    (to_date(to_char(p_upd_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	     to_date(to_char(p_db_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') >= to_date(to_char(p_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	     (p_upd_opdv_rec.opd_type <> OKL_API.G_MISS_CHAR OR
	      p_upd_opdv_rec.fma_id <> OKL_API.G_MISS_NUM OR
	      p_upd_opdv_rec.dsf_id <> OKL_API.G_MISS_NUM OR
		  p_upd_opdv_rec.source <> OKL_API.G_MISS_CHAR)) OR
	    (to_date(to_char(p_upd_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	     to_date(to_char(p_db_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') > to_date(to_char(p_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
		 to_date(to_char(p_upd_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < to_date(to_char(p_db_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY')) THEN
	 l_action := '2';
  ELSE
     l_action := '3';
  END IF;
  RETURN(l_action);
  END determine_action;
*/

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_operands for: OKL_OPERANDS_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_operands(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	p_opdv_rec                     IN  opdv_rec_type,
                        	x_opdv_rec                     OUT NOCOPY opdv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_operands';
	l_valid			  BOOLEAN := TRUE;
    l_return_status   VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;
	l_opdv_rec		  opdv_rec_type;
	l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
	l_opdv_rec := p_opdv_rec;

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PVT',
                                              x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

	/* check for the records with start and end dates less than sysdate */
/*    IF to_date(to_char(l_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate OR
	   to_date(to_char(l_opdv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

*/

    IF to_date(to_char(l_opdv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- Check if the dates are within the formulae's date

 	check_fma_opd_dates (p_upd_opdv_rec      => l_opdv_rec,
                        p_opdv_rec      	=> l_opdv_rec,
						x_return_status     => l_return_status );

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	-- Check if the dates are within the function's date

 	check_dsf_opd_dates (p_upd_opdv_rec      => l_opdv_rec,
                        p_opdv_rec      	=> l_opdv_rec,
						x_return_status     => l_return_status );

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;


	/* public api to insert operands */
-- Start of wraper code generated automatically by Debug code generator for okl_operands_pub.insert_operands
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSOPB.pls call okl_operands_pub.insert_operands ');
    END;
  END IF;
    okl_operands_pub.insert_operands(p_api_version   => p_api_version,
                              		 p_init_msg_list => p_init_msg_list,
                              		 x_return_status => l_return_status,
                              		 x_msg_count     => x_msg_count,
                              		 x_msg_data      => x_msg_data,
                              		 p_opdv_rec      => l_opdv_rec,
                              		 x_opdv_rec      => x_opdv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSOPB.pls call okl_operands_pub.insert_operands ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_operands_pub.insert_operands

     IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_UNEXP_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OTHERS',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');

  END insert_operands;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_operands for: OKL_OPERANDS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_operands(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	p_opdv_rec                     IN  opdv_rec_type,
                        	x_opdv_rec                     OUT NOCOPY opdv_rec_type
                        ) IS
    l_api_version     	  	CONSTANT NUMBER := 1;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_operands';
    l_no_data_found   	  	BOOLEAN := TRUE;
	l_valid			  	  	BOOLEAN := TRUE;
	l_oldversion_enddate  	DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_sysdate			  	DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
    l_db_opdv_rec    	  	opdv_rec_type; /* database copy */
	l_upd_opdv_rec	 	  	opdv_rec_type; /* input copy */
	l_opdv_rec	  	 	  	opdv_rec_type; /* latest with the retained changes */
	l_tmp_opdv_rec			opdv_rec_type; /* for any other purposes */
    l_return_status   	  	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_action				VARCHAR2(1);
	l_new_version			VARCHAR2(100);
	l_attrib_tbl			okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
	l_upd_opdv_rec := p_opdv_rec;

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => '_PVT',
                                              x_return_status  => l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

	/* fetch old details from the database */
    get_rec(p_opdv_rec 	 	=> l_upd_opdv_rec,
		    x_return_status => l_return_status,
			x_no_data_found => l_no_data_found,
    		x_opdv_rec		=> l_db_opdv_rec);
	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS OR
	   l_no_data_found = TRUE THEN
	   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	-- Check if the dates are within the formulae's date
	IF l_upd_opdv_rec.fma_id IS NOT NULL THEN
	 	check_fma_opd_dates (p_upd_opdv_rec      => l_upd_opdv_rec,
                        p_opdv_rec      	=> l_db_opdv_rec,
						x_return_status     => l_return_status );

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
	 END IF;
	-- Check if the dates are within the function's date

	IF l_upd_opdv_rec.dsf_id IS NOT NULL THEN
	 	check_dsf_opd_dates (p_upd_opdv_rec      => l_upd_opdv_rec,
                        p_opdv_rec      	=> l_db_opdv_rec,
						x_return_status     => l_return_status );

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
	END IF;


    /* to reorganize the input accordingly */
    reorganize_inputs(p_upd_opdv_rec     => l_upd_opdv_rec,
                      p_db_opdv_rec      => l_db_opdv_rec);

/*	 check for start date greater than sysdate
	IF to_date(to_char(l_upd_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'),'DD/MM/YYYY') AND
	   to_date(to_char(l_upd_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name	  => G_APP_NAME,
						   p_msg_name	  => G_START_DATE);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/

   /* check for end date greater than sysdate */
	IF to_date(to_char(l_upd_opdv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'),'DD/MM/YYYY') AND
	   to_date(to_char(l_upd_opdv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name	  => G_APP_NAME,
						   p_msg_name	  => 'OKL_END_DATE');
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


/*
	-- check for start date greater than sysdate
	IF to_date(to_char(l_upd_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'),'DD/MM/YYYY') AND
	   to_date(to_char(l_db_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(l_upd_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(l_db_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name	  => G_APP_NAME,
						   p_msg_name	  => G_PAST_RECORDS);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


	-- check for the records with start and end dates less than sysdate
    IF to_date(to_char(l_db_opdv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <= l_sysdate AND
	   to_date(to_char(l_db_opdv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <= l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name	  => G_APP_NAME,
						   p_msg_name	  => G_PAST_RECORDS);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
*/


	   /* public api to update operands */
-- Start of wraper code generated automatically by Debug code generator for okl_operands_pub.update_operands
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSOPB.pls call okl_operands_pub.update_operands ');
    END;
  END IF;
       okl_operands_pub.update_operands(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_opdv_rec      => l_upd_opdv_rec,
                              		 	x_opdv_rec      => x_opdv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSOPB.pls call okl_operands_pub.update_operands ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_operands_pub.update_operands

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;



/*
	-- determine how the processing to be done
	l_action := determine_action(p_upd_opdv_rec	 => l_upd_opdv_rec,
			 					 p_db_opdv_rec	 => l_db_opdv_rec,
								 p_date			 => l_sysdate);
	 -- Scenario 1: only changing description and/or source and/or descriptive flexfields
	IF l_action = '1' THEN
	    -- public api to update operands
       okl_operands_pub.update_operands(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_opdv_rec      => l_upd_opdv_rec,
                              		 	x_opdv_rec      => x_opdv_rec);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	-- Scenario 2: only changing description/source/descriptive flexfield changes
	--   and end date for all records or changing anything for a future record other
	--   than start date or modified start date is less than existing start date

	ELSIF l_action = '2' THEN
	   -- create a temporary record with all relevant details from db and upd records
	   l_opdv_rec := defaults_to_actuals(p_upd_opdv_rec => l_upd_opdv_rec,
	   					  				 p_db_opdv_rec  => l_db_opdv_rec);

	   check_updates(p_upd_opdv_rec	 => l_upd_opdv_rec,
	   			     p_db_opdv_rec	 => l_db_opdv_rec,
					 p_opdv_rec		 => l_opdv_rec,
					 x_return_status => l_return_status,
					 x_msg_data		 => x_msg_data);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   -- public api to update operands
       okl_operands_pub.update_operands(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_opdv_rec      => l_upd_opdv_rec,
                              		 	x_opdv_rec      => x_opdv_rec);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	-- Scenario 3: changing anything else i.e., anything including start date + start date
	--   always greater than system date for current records or anything + start date always
	--   greater than existing start date for future records
	ELSIF l_action = '3' THEN

	   -- for old version
	   IF l_upd_opdv_rec.start_date <> OKL_API.G_MISS_DATE THEN
	   	  l_oldversion_enddate := l_upd_opdv_rec.start_date - 1;
	   ELSE
	   	  l_oldversion_enddate := l_sysdate - 1;
	   END IF;

	   l_opdv_rec := l_db_opdv_rec;
	   l_opdv_rec.end_date := l_oldversion_enddate;

	   -- call verify changes to update the database
	   IF to_date(to_char(l_oldversion_enddate, 'DD/MM/YYYY'), 'DD/MM/YYYY') > to_date(to_char(l_db_opdv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	   	  check_updates(p_upd_opdv_rec	=> l_upd_opdv_rec,
	   			     	p_db_opdv_rec	=> l_db_opdv_rec,
					 	p_opdv_rec		=> l_opdv_rec,
					 	x_return_status => l_return_status,
					 	x_msg_data		=> x_msg_data);
       	  IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  	 RAISE OKL_API.G_EXCEPTION_ERROR;
       	  ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
	   END IF;

	   -- public api to update operands
       okl_operands_pub.update_operands(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_opdv_rec      => l_opdv_rec,
                              		 	x_opdv_rec      => x_opdv_rec);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   -- for new version
	   -- create a temporary record with all relevant details from db and upd records
	   l_opdv_rec := defaults_to_actuals(p_upd_opdv_rec => l_upd_opdv_rec,
	   					  				 p_db_opdv_rec  => l_db_opdv_rec);

	   IF l_upd_opdv_rec.start_date = OKL_API.G_MISS_DATE THEN
	   	  l_opdv_rec.start_date := l_sysdate;
	   END IF;

          l_attrib_tbl(1).attribute     := 'NAME';
    	  l_attrib_tbl(1).attrib_type	:= okl_accounting_util.G_VARCHAR2;
    	  l_attrib_tbl(1).value	        := l_opdv_rec.name;

  	     okl_accounting_util.get_version(p_attrib_tbl	  	     => l_attrib_tbl,
  				           p_cur_version	     => l_opdv_rec.version,
				           p_end_date_attribute_name => 'END_DATE',
				           p_end_date		     => l_opdv_rec.end_date,
				           p_view		     => 'Okl_Operands_V',
  				           x_return_status	     => l_return_status,
				           x_new_version	     => l_new_version);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSE
	   	  l_opdv_rec.version := l_new_version;
       END IF;

	    -- call verify changes to update the database
	   l_opdv_rec.id := OKL_API.G_MISS_NUM;

	   IF l_opdv_rec.end_date > l_db_opdv_rec.end_date THEN
	   	  check_updates(p_upd_opdv_rec	=> l_upd_opdv_rec,
	   				    p_db_opdv_rec	=> l_db_opdv_rec,
					  	p_opdv_rec		=> l_opdv_rec,
					  	x_return_status => l_return_status,
					  	x_msg_data		=> x_msg_data);
       	  IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          	 RAISE OKL_API.G_EXCEPTION_ERROR;
       	  ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
	   END IF;

	   -- public api to insert operands -
       okl_operands_pub.insert_operands(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_opdv_rec      => l_opdv_rec,
                              		 	x_opdv_rec      => x_opdv_rec);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	END IF;
*/


    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OKL_API.G_RET_STS_UNEXP_ERROR',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => 'OTHERS',
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> '_PVT');

  END update_operands;

END OKL_SETUPOPERANDS_PVT;

/
