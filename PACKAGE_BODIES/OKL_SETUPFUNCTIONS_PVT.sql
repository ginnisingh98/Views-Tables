--------------------------------------------------------
--  DDL for Package Body OKL_SETUPFUNCTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUPFUNCTIONS_PVT" AS
/* $Header: OKLRSDFB.pls 115.12 2003/07/23 19:05:22 sgorantl noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.SETUP.FUNCTIONS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

-- Not required as new version will not be creatd while updating the function
/*
---------------------------------------------------------------------------
  -- PROCEDURE get_version to calculate the new version number for the
  -- function to be created
  ---------------------------------------------------------------------------
  PROCEDURE get_version(p_dsfv_rec						IN dsfv_rec_type,
  						x_return_status					OUT NOCOPY VARCHAR2,
						x_new_version					OUT NOCOPY VARCHAR2) IS
    CURSOR okl_dsf_laterversionsexist_csr (p_name IN Okl_Data_Src_Fnctns_V.NAME%TYPE,
		   					   			   p_date IN Okl_Data_Src_Fnctns_V.END_DATE%TYPE
	) IS
    SELECT '1'
    FROM Okl_Data_Src_Fnctns_V
    WHERE name = p_name
	AND NVL(end_date,OKL_API.G_MISS_DATE) > p_date;

	l_check			VARCHAR2(1) := '?';
	l_row_not_found	BOOLEAN := FALSE;
  BEGIN
  	   IF p_dsfv_rec.version = OKL_API.G_MISS_CHAR THEN
	   	  x_new_version := G_INIT_VERSION;
	   ELSE
          -- Check for future versions of the same formula
		  OPEN okl_dsf_laterversionsexist_csr (p_dsfv_rec.name,
							  			 	   p_dsfv_rec.end_date);
    	  FETCH okl_dsf_laterversionsexist_csr INTO l_check;
    	  l_row_not_found := okl_dsf_laterversionsexist_csr%NOTFOUND;
    	  CLOSE okl_dsf_laterversionsexist_csr;

    	  IF l_row_not_found = TRUE then
  	   	   	 x_new_version := TO_CHAR(TO_NUMBER(p_dsfv_rec.version, G_VERSION_FORMAT)
			                  + G_VERSION_MAJOR_INCREMENT, G_VERSION_FORMAT);
		  ELSE
		  	 x_new_version := TO_CHAR(TO_NUMBER(p_dsfv_rec.version, G_VERSION_FORMAT)
			 			   	  + G_VERSION_MINOR_INCREMENT, G_VERSION_FORMAT);
    	  END IF;
	   END IF;

	   x_return_status := OKL_API.G_RET_STS_SUCCESS;
  EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	    =>	G_APP_NAME,
							p_msg_name		=>	G_UNEXPECTED_ERROR,
							p_token1		=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	sqlcode,
							p_token2		=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	sqlerrm);
	   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

       IF (okl_dsf_laterversionsexist_csr%ISOPEN) THEN
	   	  CLOSE okl_dsf_laterversionsexist_csr;
       END IF;

  END get_version;

*/

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_DATA_SRC_FNCTNS_V
  -- Fix this once the view data structure is fixed
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_dsfv_rec                     IN dsfv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_dsfv_rec					   OUT NOCOPY dsfv_rec_type
  ) IS
    CURSOR okl_dsfv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            NVL(FNCTN_CODE, OKL_API.G_MISS_CHAR) FNCTN_CODE,
            NAME,
            NVL(DESCRIPTION,OKL_API.G_MISS_CHAR) DESCRIPTION,
            VERSION,
            START_DATE,
            NVL(END_DATE,OKL_API.G_MISS_DATE) END_DATE,
			SOURCE,
            NVL(ATTRIBUTE_CATEGORY, OKL_API.G_MISS_CHAR) ATTRIBUTE_CATEGORY,
            NVL(ATTRIBUTE1, OKL_API.G_MISS_CHAR) ATTRIBUTE1,
            NVL(ATTRIBUTE2, OKL_API.G_MISS_CHAR) ATTRIBUTE2,
            NVL(ATTRIBUTE3, OKL_API.G_MISS_CHAR) ATTRIBUTE3,
            NVL(ATTRIBUTE4, OKL_API.G_MISS_CHAR) ATTRIBUTE4,
            NVL(ATTRIBUTE5, OKL_API.G_MISS_CHAR) ATTRIBUTE5,
            NVL(ATTRIBUTE6, OKL_API.G_MISS_CHAR) ATTRIBUTE6,
            NVL(ATTRIBUTE7, OKL_API.G_MISS_CHAR) ATTRIBUTE7,
            NVL(ATTRIBUTE8, OKL_API.G_MISS_CHAR) ATTRIBUTE8,
            NVL(ATTRIBUTE9, OKL_API.G_MISS_CHAR) ATTRIBUTE9,
            NVL(ATTRIBUTE10, OKL_API.G_MISS_CHAR) ATTRIBUTE10,
            NVL(ATTRIBUTE11, OKL_API.G_MISS_CHAR) ATTRIBUTE11,
            NVL(ATTRIBUTE12, OKL_API.G_MISS_CHAR) ATTRIBUTE12,
            NVL(ATTRIBUTE13, OKL_API.G_MISS_CHAR) ATTRIBUTE13,
            NVL(ATTRIBUTE14, OKL_API.G_MISS_CHAR) ATTRIBUTE14,
            NVL(ATTRIBUTE15, OKL_API.G_MISS_CHAR) ATTRIBUTE15,
            NVL(ORG_ID,  OKL_API.G_MISS_NUM) ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN, OKL_API.G_MISS_NUM) LAST_UPDATE_LOGIN
      FROM Okl_Data_Src_Fnctns_V
     WHERE okl_Data_Src_Fnctns_v.id    = p_id;
    l_okl_dsfv_pk                  okl_dsfv_pk_csr%ROWTYPE;
    l_dsfv_rec                     dsfv_rec_type;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_dsfv_pk_csr (p_dsfv_rec.id);
    FETCH okl_dsfv_pk_csr INTO
              l_dsfv_rec.ID,
              l_dsfv_rec.OBJECT_VERSION_NUMBER,
              l_dsfv_rec.SFWT_FLAG,
              l_dsfv_rec.FNCTN_CODE,
              l_dsfv_rec.NAME,
              l_dsfv_rec.DESCRIPTION,
              l_dsfv_rec.VERSION,
              l_dsfv_rec.START_DATE,
              l_dsfv_rec.END_DATE,
			  l_dsfv_rec.SOURCE,
              l_dsfv_rec.ATTRIBUTE_CATEGORY,
              l_dsfv_rec.ATTRIBUTE1,
              l_dsfv_rec.ATTRIBUTE2,
              l_dsfv_rec.ATTRIBUTE3,
              l_dsfv_rec.ATTRIBUTE4,
              l_dsfv_rec.ATTRIBUTE5,
              l_dsfv_rec.ATTRIBUTE6,
              l_dsfv_rec.ATTRIBUTE7,
              l_dsfv_rec.ATTRIBUTE8,
              l_dsfv_rec.ATTRIBUTE9,
              l_dsfv_rec.ATTRIBUTE10,
              l_dsfv_rec.ATTRIBUTE11,
              l_dsfv_rec.ATTRIBUTE12,
              l_dsfv_rec.ATTRIBUTE13,
              l_dsfv_rec.ATTRIBUTE14,
              l_dsfv_rec.ATTRIBUTE15,
              l_dsfv_rec.ORG_ID,
              l_dsfv_rec.CREATED_BY,
              l_dsfv_rec.CREATION_DATE,
              l_dsfv_rec.LAST_UPDATED_BY,
              l_dsfv_rec.LAST_UPDATE_DATE,
              l_dsfv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_dsfv_pk_csr%NOTFOUND;
    CLOSE okl_dsfv_pk_csr;
    x_dsfv_rec := l_dsfv_rec;
EXCEPTION
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

      IF (okl_dsfv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_dsfv_pk_csr;
      END IF;

  END get_rec;

-- Not required as new version will not be creatd while updating the function
/*
  ---------------------------------------------------------------------------
  -- PROCEDURE check_overlaps for: OKL_DATA_SRC_FNCTNS_V
  -- To avoid overlapping of dates with other versions of the same function
  ---------------------------------------------------------------------------
  PROCEDURE check_overlaps (
    p_dsfv_rec                     IN dsfv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_valid                		   OUT NOCOPY BOOLEAN
  ) IS
  	CURSOR okl_dsf_overlaps_csr (p_id  		  IN Okl_Data_Src_Fnctns_V.ID%TYPE,
		   						 p_name   	  IN Okl_Data_Src_Fnctns_V.NAME%TYPE,
		   					     p_start_date IN Okl_Data_Src_Fnctns_V.START_DATE%TYPE,
								 p_end_date   IN Okl_Data_Src_Fnctns_V.END_DATE%TYPE
	) IS
	SELECT '1'
	FROM Okl_Data_Src_Fnctns_V
	WHERE NAME = p_name
	AND   ID <> p_id
	AND	  (p_start_date BETWEEN START_DATE AND NVL(END_DATE, OKL_API.G_MISS_DATE) OR
		   p_end_date BETWEEN START_DATE AND NVL(END_DATE, OKL_API.G_MISS_DATE))
    UNION ALL
	SELECT '2'
	FROM Okl_Data_Src_Fnctns_V
	WHERE NAME = p_name
	AND   ID <> p_id
	AND	  p_start_date <= START_DATE
	AND   p_end_date >= NVL(END_DATE, OKL_API.G_MISS_DATE);

	l_check            VARCHAR2(1) := '?';
	l_row_not_found	   BOOLEAN := FALSE;
  BEGIN
    x_valid := TRUE;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- Check for functions overlaps
    OPEN okl_dsf_overlaps_csr (p_dsfv_rec.id,
		 					   p_dsfv_rec.name,
		 					   p_dsfv_rec.start_date,
							   p_dsfv_rec.end_date);
    FETCH okl_dsf_overlaps_csr INTO l_check;
    l_row_not_found := okl_dsf_overlaps_csr%NOTFOUND;
    CLOSE okl_dsf_overlaps_csr;

    IF l_row_not_found = FALSE then
	   OKL_API.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_DSF_VERSION_OVERLAPS);
	   x_valid := FALSE;
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	    =>	G_APP_NAME,
							p_msg_name		=>	G_UNEXPECTED_ERROR,
							p_token1		=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	sqlcode,
							p_token2		=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	sqlerrm);
	   x_valid := FALSE;
	   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

       IF (okl_dsf_overlaps_csr%ISOPEN) THEN
	   	  CLOSE okl_dsf_overlaps_csr;
       END IF;


  END check_overlaps;

*/

  ---------------------------------------------------------------------------
  -- PROCEDURE reorganize_inputs
  -- This procedure is to reset the attributes in the input structure based
  -- on the data from database
  ---------------------------------------------------------------------------
  PROCEDURE reorganize_inputs (
    p_upd_dsfv_rec                 IN OUT NOCOPY dsfv_rec_type,
	p_db_dsfv_rec				   IN dsfv_rec_type
  ) IS
  l_upd_dsfv_rec	dsfv_rec_type;
  l_db_dsfv_rec     dsfv_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_upd_dsfv_rec := p_upd_dsfv_rec;
       l_db_dsfv_rec := p_db_dsfv_rec;

	   IF l_upd_dsfv_rec.description = l_db_dsfv_rec.description THEN
	  	  l_upd_dsfv_rec.description := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF to_date(to_char(l_upd_dsfv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_dsfv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_dsfv_rec.start_date := OKL_API.G_MISS_DATE;
	   END IF;

	   IF to_date(to_char(l_upd_dsfv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') = to_date(to_char(l_db_dsfv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') THEN
	  	  l_upd_dsfv_rec.end_date := OKL_API.G_MISS_DATE;
	   END IF;

	   IF l_upd_dsfv_rec.fnctn_code = l_db_dsfv_rec.fnctn_code THEN
	   	  l_upd_dsfv_rec.fnctn_code := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.source = l_db_dsfv_rec.source THEN
	   	  l_upd_dsfv_rec.source := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute_category = l_db_dsfv_rec.attribute_category THEN
	   	  l_upd_dsfv_rec.attribute_category := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute1 = l_db_dsfv_rec.attribute1 THEN
	   	  l_upd_dsfv_rec.attribute1 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute2 = l_db_dsfv_rec.attribute2 THEN
	   	  l_upd_dsfv_rec.attribute2 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute3 = l_db_dsfv_rec.attribute3 THEN
	   	  l_upd_dsfv_rec.attribute3 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute4 = l_db_dsfv_rec.attribute4 THEN
	   	  l_upd_dsfv_rec.attribute4 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute5 = l_db_dsfv_rec.attribute5 THEN
	   	  l_upd_dsfv_rec.attribute5 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute6 = l_db_dsfv_rec.attribute6 THEN
	   	  l_upd_dsfv_rec.attribute6 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute7 = l_db_dsfv_rec.attribute7 THEN
	   	  l_upd_dsfv_rec.attribute7 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute8 = l_db_dsfv_rec.attribute8 THEN
	   	  l_upd_dsfv_rec.attribute8 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute9 = l_db_dsfv_rec.attribute9 THEN
	   	  l_upd_dsfv_rec.attribute9 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute10 = l_db_dsfv_rec.attribute10 THEN
	   	  l_upd_dsfv_rec.attribute10 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute11 = l_db_dsfv_rec.attribute11 THEN
	   	  l_upd_dsfv_rec.attribute11 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute12 = l_db_dsfv_rec.attribute12 THEN
	   	  l_upd_dsfv_rec.attribute12 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute13 = l_db_dsfv_rec.attribute13 THEN
	   	  l_upd_dsfv_rec.attribute13 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute14 = l_db_dsfv_rec.attribute14 THEN
	   	  l_upd_dsfv_rec.attribute14 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.attribute15 = l_db_dsfv_rec.attribute15 THEN
	   	  l_upd_dsfv_rec.attribute15 := OKL_API.G_MISS_CHAR;
	   END IF;

	   IF l_upd_dsfv_rec.org_id = l_db_dsfv_rec.org_id THEN
	   	  l_upd_dsfv_rec.org_id := OKL_API.G_MISS_NUM;
	   END IF;

       p_upd_dsfv_rec := l_upd_dsfv_rec;

  END reorganize_inputs;

  ---------------------------------------------------------------------------
  -- FUNCTION defaults_to_actuals
  -- This function creates an output record with changed information from the
  -- input structure and unchanged details from the database
  ---------------------------------------------------------------------------
  FUNCTION defaults_to_actuals (
    p_upd_dsfv_rec                 IN dsfv_rec_type,
	p_db_dsfv_rec				   IN dsfv_rec_type
  ) RETURN dsfv_rec_type IS
  l_dsfv_rec	dsfv_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_dsfv_rec := p_db_dsfv_rec;

	   IF p_upd_dsfv_rec.description <> OKL_API.G_MISS_CHAR THEN
	  	  l_dsfv_rec.description := p_upd_dsfv_rec.description;
	   END IF;

	   IF p_upd_dsfv_rec.start_date <> OKL_API.G_MISS_DATE THEN
	  	  l_dsfv_rec.start_date := p_upd_dsfv_rec.start_date;
	   END IF;

	   IF p_upd_dsfv_rec.end_date <> OKL_API.G_MISS_DATE THEN
	   	  l_dsfv_rec.end_date := p_upd_dsfv_rec.end_date;
	   END IF;

	   IF p_upd_dsfv_rec.fnctn_code <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.fnctn_code := p_upd_dsfv_rec.fnctn_code;
	   END IF;

	   IF p_upd_dsfv_rec.source <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.source := p_upd_dsfv_rec.source;
	   END IF;

	   IF p_upd_dsfv_rec.attribute_category <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute_category := p_upd_dsfv_rec.attribute_category;
	   END IF;

	   IF p_upd_dsfv_rec.attribute1 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute1 := p_upd_dsfv_rec.attribute1;
	   END IF;

	   IF p_upd_dsfv_rec.attribute2 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute2 := p_upd_dsfv_rec.attribute2;
	   END IF;

	   IF p_upd_dsfv_rec.attribute3 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute3 := p_upd_dsfv_rec.attribute3;
	   END IF;

	   IF p_upd_dsfv_rec.attribute4 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute4 := p_upd_dsfv_rec.attribute4;
	   END IF;

	   IF p_upd_dsfv_rec.attribute5 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute5 := p_upd_dsfv_rec.attribute5;
	   END IF;

	   IF p_upd_dsfv_rec.attribute6 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute6 := p_upd_dsfv_rec.attribute6;
	   END IF;

	   IF p_upd_dsfv_rec.attribute7 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute7 := p_upd_dsfv_rec.attribute7;
	   END IF;

	   IF p_upd_dsfv_rec.attribute8 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute8 := p_upd_dsfv_rec.attribute8;
	   END IF;

	   IF p_upd_dsfv_rec.attribute9 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute9 := p_upd_dsfv_rec.attribute9;
	   END IF;

	   IF p_upd_dsfv_rec.attribute10 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute10 := p_upd_dsfv_rec.attribute10;
	   END IF;

	   IF p_upd_dsfv_rec.attribute11 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute11 := p_upd_dsfv_rec.attribute11;
	   END IF;

	   IF p_upd_dsfv_rec.attribute12 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute12 := p_upd_dsfv_rec.attribute12;
	   END IF;

	   IF p_upd_dsfv_rec.attribute13 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute13 := p_upd_dsfv_rec.attribute13;
	   END IF;

	   IF p_upd_dsfv_rec.attribute14 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute14 := p_upd_dsfv_rec.attribute14;
	   END IF;

	   IF p_upd_dsfv_rec.attribute15 <> OKL_API.G_MISS_CHAR THEN
	   	  l_dsfv_rec.attribute15 := p_upd_dsfv_rec.attribute15;
	   END IF;

	   IF p_upd_dsfv_rec.org_id <> OKL_API.G_MISS_NUM THEN
	   	  l_dsfv_rec.org_id := p_upd_dsfv_rec.org_id;
	   END IF;

	   RETURN l_dsfv_rec;
  END defaults_to_actuals;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_dsf_opd_dates for: OKL_DATA_SRC_FNCTNS_V
  -- To fetch the operands that are attached to the existing version of the
  -- function and verify the dates for the both
  ---------------------------------------------------------------------------
  PROCEDURE check_dsf_opd_dates (p_upd_dsfv_rec      IN  dsfv_rec_type,
                                 p_dsfv_rec      	 IN dsfv_rec_type,
							   	 x_return_status     OUT NOCOPY VARCHAR2
  ) IS

    CURSOR okl_dsf_linkedopds_csr (p_dsf_id IN Okl_Operands_V.dsf_id%TYPE,
		   						   p_start_date DATE, p_end_date DATE) IS
   SELECT '1'
   FROM Okl_Operands_B opd
   WHERE opd.DSF_ID 	=  p_dsf_id
   AND ((opd.start_date < p_start_date) OR
  	  (NVL(opd.end_date, TO_DATE('31/12/9999', 'DD/MM/YYYY')) > p_end_date )) ;


  	l_return_status 	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_min_start_date 	DATE := NULL;
	l_max_end_date	 	DATE := OKL_API.G_MISS_DATE;
	l_check 			VARCHAR2(1);
	l_not_found 		BOOLEAN;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

   OPEN okl_dsf_linkedopds_csr (p_upd_dsfv_rec.id, p_upd_dsfv_rec.start_date, p_upd_dsfv_rec.end_date);
   FETCH okl_dsf_linkedopds_csr INTO l_check;
   l_not_found := okl_dsf_linkedopds_csr%NOTFOUND;
   CLOSE okl_dsf_linkedopds_csr;

   IF NOT l_not_found THEN
		OKL_API.SET_MESSAGE(p_app_name	  => G_APP_NAME,
						   p_msg_name	  => G_DATES_MISMATCH,
						   p_token1		  => G_PARENT_TABLE_TOKEN,
						   p_token1_value  => 'Okl_Data_Src_Fnctns_V',
						   p_token2		  => G_CHILD_TABLE_TOKEN,
						   p_token2_value  => 'Okl_Operands_V');
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


-- Not required as new version will not be creatd while updating the function
/*
  ---------------------------------------------------------------------------
  -- PROCEDURE check_updates
  -- To verify whether the requested changes from the screen are valid or not
  ---------------------------------------------------------------------------
  PROCEDURE check_updates (
    p_upd_dsfv_rec                 IN dsfv_rec_type,
	p_db_dsfv_rec				   IN dsfv_rec_type,
	p_dsfv_rec					   IN dsfv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2
  ) IS
  l_dsfv_rec	  		dsfv_rec_type;
  l_return_status 		VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_valid		  		BOOLEAN;
  l_attrib_tbl	okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
	   x_return_status := OKL_API.G_RET_STS_SUCCESS;
	   l_dsfv_rec := p_dsfv_rec;

	   IF p_upd_dsfv_rec.start_date <> OKL_API.G_MISS_DATE OR
	   	  p_upd_dsfv_rec.end_date <> OKL_API.G_MISS_DATE THEN


	   	-- call check_overlaps
		  l_attrib_tbl(1).attribute := 'NAME';
		  l_attrib_tbl(1).attrib_type	:= okl_accounting_util.G_VARCHAR2;
		  l_attrib_tbl(1).value	:= l_dsfv_rec.name;

                  okl_accounting_util.check_overlaps (p_id                         => l_dsfv_rec.id,
                                                      p_attrib_tbl                 => l_attrib_tbl,
                                                      p_start_date_attribute_name  => 'START_DATE',
                                                      p_start_date                 => l_dsfv_rec.start_date,
                                                      p_end_date_attribute_name    => 'END_DATE',
                                                      p_end_date                   => l_dsfv_rec.end_date,
                                                      p_view                       => 'Okl_Data_Src_Fnctns_V',
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

	   -- call check_dsf_fma_dates
  	   check_dsf_opd_dates (p_upd_dsfv_rec  => p_upd_dsfv_rec,
                            p_dsfv_rec      => l_dsfv_rec,
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

-- Not required as new version will not be creatd while updating the function
/*

  ---------------------------------------------------------------------------
  -- PROCEDURE determine_action for: OKL_DATA_SRC_FNCTNS_V
  -- This function helps in determining the various checks to be performed
  -- for the new/updated record and also helps in determining whether a new
  -- version is required or not
  ---------------------------------------------------------------------------
  FUNCTION determine_action (
    p_upd_dsfv_rec                 IN dsfv_rec_type,
	p_db_dsfv_rec				   IN dsfv_rec_type,
	p_date						   IN DATE
  ) RETURN VARCHAR2 IS
  l_action VARCHAR2(1);
  l_sysdate DATE := trunc(SYSDATE);
BEGIN
   -- Scenario 1: Only description and/or descriptive flexfield
  --    changes
  IF p_upd_dsfv_rec.start_date = OKL_API.G_MISS_DATE AND
	 p_upd_dsfv_rec.end_date = OKL_API.G_MISS_DATE AND
	 p_upd_dsfv_rec.fnctn_code = OKL_API.G_MISS_CHAR AND
	 p_upd_dsfv_rec.source = OKL_API.G_MISS_CHAR THEN
	 l_action := '1';
-- Scenario 2: only changing description/descriptive flexfield changes
--	   and end date for all records or changing anything for a future record other
--	   than start date or modified start date is less than existing start date

  ELSIF (p_upd_dsfv_rec.start_date = OKL_API.G_MISS_DATE AND
	     (p_upd_dsfv_rec.end_date <> OKL_API.G_MISS_DATE OR
          p_upd_dsfv_rec.end_date IS NULL) AND
	     p_upd_dsfv_rec.fnctn_code = OKL_API.G_MISS_CHAR AND
	     p_upd_dsfv_rec.source = OKL_API.G_MISS_CHAR) OR
	    (p_upd_dsfv_rec.start_date = OKL_API.G_MISS_DATE AND
	     p_db_dsfv_rec.start_date >= p_date AND
	     (p_upd_dsfv_rec.fnctn_code <> OKL_API.G_MISS_CHAR OR
	      p_upd_dsfv_rec.source <> OKL_API.G_MISS_CHAR)) OR
	    (p_upd_dsfv_rec.start_date <> OKL_API.G_MISS_DATE AND
	     p_db_dsfv_rec.start_date > p_date AND
		 p_upd_dsfv_rec.start_date < p_db_dsfv_rec.start_date) THEN
	 l_action := '2';
  ELSE
     l_action := '3';
  END IF;
  RETURN(l_action);
  END determine_action;
*/

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_operands for: OKL_DATA_SRC_FNCTNS_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_functions(p_api_version      IN  NUMBER,
                             p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        	 x_return_status    OUT NOCOPY VARCHAR2,
                        	 x_msg_count        OUT NOCOPY NUMBER,
                        	 x_msg_data         OUT NOCOPY VARCHAR2,
                        	 p_dsfv_rec         IN  dsfv_rec_type,
                        	 x_dsfv_rec         OUT NOCOPY dsfv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_functions';
	l_valid			  BOOLEAN := TRUE;
    l_return_status   VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;
	l_dsfv_rec		  dsfv_rec_type;
	l_sysdate		  DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
	l_dsfv_rec := p_dsfv_rec;

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

 /*   IF to_date(l_dsfv_rec.start_date, 'DD/MM/YYYY') < l_sysdate OR
	   to_date(l_dsfv_rec.end_date, 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
*/
     IF to_date(to_char(l_dsfv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	/* public api to insert functions */
-- Start of wraper code generated automatically by Debug code generator for okl_data_src_fnctns_pub.insert_data_src_fnctns
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSDFB.pls call okl_data_src_fnctns_pub.insert_data_src_fnctns ');
    END;
  END IF;
    okl_data_src_fnctns_pub.insert_data_src_fnctns(p_api_version   => p_api_version,
                              		               p_init_msg_list => p_init_msg_list,
                              		 			   x_return_status => l_return_status,
                              		 			   x_msg_count     => x_msg_count,
                              		 			   x_msg_data      => x_msg_data,
                              		 			   p_dsfv_rec      => l_dsfv_rec,
                              		 			   x_dsfv_rec      => x_dsfv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSDFB.pls call okl_data_src_fnctns_pub.insert_data_src_fnctns ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_data_src_fnctns_pub.insert_data_src_fnctns

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

  END insert_functions;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_functions for: OKL_DATA_SRC_FNCTNS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_functions(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	p_dsfv_rec                     IN  dsfv_rec_type,
                        	x_dsfv_rec                     OUT NOCOPY dsfv_rec_type
                        ) IS
    l_api_version     	  	CONSTANT NUMBER := 1;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_functions';
    l_no_data_found   	  	BOOLEAN := TRUE;
	l_valid			  	  	BOOLEAN := TRUE;
	l_oldversion_enddate  	DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
	l_sysdate			  	DATE := to_date(to_char(SYSDATE, 'DD/MM/YYYY'), 'DD/MM/YYYY');
    l_db_dsfv_rec    	  	dsfv_rec_type; /* database copy */
	l_upd_dsfv_rec	 	  	dsfv_rec_type; /* input copy */
	l_dsfv_rec	  	 	  	dsfv_rec_type; /* latest with the retained changes */
	l_tmp_dsfv_rec			dsfv_rec_type; /* for any other purposes */
    l_return_status   	  	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_action				VARCHAR2(1);
	l_new_version			VARCHAR2(100);
	l_attrib_tbl			okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
	l_upd_dsfv_rec := p_dsfv_rec;

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
    get_rec(p_dsfv_rec 	 	=> l_upd_dsfv_rec,
		    x_return_status => l_return_status,
			x_no_data_found => l_no_data_found,
    		x_dsfv_rec		=> l_db_dsfv_rec);
	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS OR
	   l_no_data_found = TRUE THEN
	   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

    /* to reorganize the input accordingly */
    reorganize_inputs(p_upd_dsfv_rec     => l_upd_dsfv_rec,
                      p_db_dsfv_rec      => l_db_dsfv_rec);

	/* check for start date greater than sysdate */
/*	IF to_date(l_upd_dsfv_rec.start_date, 'DD/MM/YYYY') <> to_date(OKL_API.G_MISS_DATE,'DD/MM/YYYY') AND
	   to_date(l_upd_dsfv_rec.start_date, 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name	  => G_APP_NAME,
						   p_msg_name	  => G_START_DATE);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/

	/* check for start date greater than sysdate */
	IF to_date(to_char(l_upd_dsfv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'),'DD/MM/YYYY') AND
	   to_date(to_char(l_upd_dsfv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name	  => G_APP_NAME,
						   p_msg_name	  => 'OKL_END_DATE');
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

/*

  -- check for start date greater than sysdate
	IF to_date(to_char(l_upd_dsfv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(OKL_API.G_MISS_DATE, 'DD/MM/YYYY'),'DD/MM/YYYY') AND
	   to_date(to_char(l_db_dsfv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(l_upd_dsfv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(l_db_dsfv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name	  => G_APP_NAME,
						   p_msg_name	  => G_PAST_RECORDS);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


	-- check for the records with start and end dates less than sysdate
    IF to_date(to_char(l_db_dsfv_rec.start_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate AND
	   to_date(to_char(l_db_dsfv_rec.end_date, 'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

*/

  -- Check if the linked operands are within the date range of function

 	check_dsf_opd_dates (p_upd_dsfv_rec      => l_upd_dsfv_rec,
                        p_dsfv_rec      	=> l_db_dsfv_rec,
						x_return_status     => l_return_status );

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	   /* public api to update functions */
-- Start of wraper code generated automatically by Debug code generator for okl_data_src_fnctns_pub.update_data_src_fnctns
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSDFB.pls call okl_data_src_fnctns_pub.update_data_src_fnctns ');
    END;
  END IF;
       okl_data_src_fnctns_pub.update_data_src_fnctns(p_api_version   => p_api_version,
                            		 	              p_init_msg_list => p_init_msg_list,
                              		 				  x_return_status => l_return_status,
                              		 				  x_msg_count     => x_msg_count,
                              		 				  x_msg_data      => x_msg_data,
                              		 				  p_dsfv_rec      => l_upd_dsfv_rec,
                              		 				  x_dsfv_rec      => x_dsfv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSDFB.pls call okl_data_src_fnctns_pub.update_data_src_fnctns ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_data_src_fnctns_pub.update_data_src_fnctns
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;



-- Not required as new version will not be creatd while updating the function
/*
	--  determine how the processing to be done
	l_action := determine_action(p_upd_dsfv_rec	 => l_upd_dsfv_rec,
			 					 p_db_dsfv_rec	 => l_db_dsfv_rec,
								 p_date			 => l_sysdate);

	-- Scenario 1: only changing description and/or source and/or descriptive flexfields
	IF l_action = '1' THEN
	   -- public api to update functions
       okl_data_src_fnctns_pub.update_data_src_fnctns(p_api_version   => p_api_version,
                            		 	              p_init_msg_list => p_init_msg_list,
                              		 				  x_return_status => l_return_status,
                              		 				  x_msg_count     => x_msg_count,
                              		 				  x_msg_data      => x_msg_data,
                              		 				  p_dsfv_rec      => l_upd_dsfv_rec,
                              		 				  x_dsfv_rec      => x_dsfv_rec);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	-- Scenario 2: only changing description/source/descriptive flexfield changes
	   and end date for all records or changing anything for a future record other
	   than start date or modified start date is less than existing start date
	ELSIF l_action = '2' THEN
	    create a temporary record with all relevant details from db and upd records
	   l_dsfv_rec := defaults_to_actuals(p_upd_dsfv_rec => l_upd_dsfv_rec,
	   					  				 p_db_dsfv_rec  => l_db_dsfv_rec);

	   check_updates(p_upd_dsfv_rec	 => l_upd_dsfv_rec,
	   			     p_db_dsfv_rec	 => l_db_dsfv_rec,
					 p_dsfv_rec		 => l_dsfv_rec,
					 x_return_status => l_return_status,
					 x_msg_data		 => x_msg_data);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   -- public api to update functions
       okl_data_src_fnctns_pub.update_data_src_fnctns(p_api_version   => p_api_version,
                            		 				  p_init_msg_list => p_init_msg_list,
                              		 				  x_return_status => l_return_status,
                              		 				  x_msg_count     => x_msg_count,
                              		 				  x_msg_data      => x_msg_data,
                              		 				  p_dsfv_rec      => l_upd_dsfv_rec,
                              		 				  x_dsfv_rec      => x_dsfv_rec);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	-- Scenario 3: changing anything else i.e., anything including start date + start date
	   always greater than system date for current records or anything + start date always
	   greater than existing start date for future records
	ELSIF l_action = '3' THEN

	   -- for old version
	   IF l_upd_dsfv_rec.start_date <> OKL_API.G_MISS_DATE THEN
	   	  l_oldversion_enddate := l_upd_dsfv_rec.start_date - 1;
	   ELSE
	   	  l_oldversion_enddate := l_sysdate - 1;
	   END IF;

	   l_dsfv_rec := l_db_dsfv_rec;
	   l_dsfv_rec.end_date := l_oldversion_enddate;

	    call verify changes to update the database
	   IF l_oldversion_enddate > l_db_dsfv_rec.end_date THEN
	   	  check_updates(p_upd_dsfv_rec	=> l_upd_dsfv_rec,
	   			     	p_db_dsfv_rec	=> l_db_dsfv_rec,
					 	p_dsfv_rec		=> l_dsfv_rec,
					 	x_return_status => l_return_status,
					 	x_msg_data		=> x_msg_data);
       	  IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  	 RAISE OKL_API.G_EXCEPTION_ERROR;
       	  ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
	   END IF;

	   -- public api to update functions
       okl_data_src_fnctns_pub.update_data_src_fnctns(p_api_version   => p_api_version,
                            		 	              p_init_msg_list => p_init_msg_list,
                              		 				  x_return_status => l_return_status,
                              		 				  x_msg_count     => x_msg_count,
                              		 				  x_msg_data      => x_msg_data,
                              		 				  p_dsfv_rec      => l_dsfv_rec,
                              		 				  x_dsfv_rec      => x_dsfv_rec);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   -- for new version
	    -- create a temporary record with all relevant details from db and upd records
	   l_dsfv_rec := defaults_to_actuals(p_upd_dsfv_rec => l_upd_dsfv_rec,
	   					  				 p_db_dsfv_rec  => l_db_dsfv_rec);

	   IF l_upd_dsfv_rec.start_date = OKL_API.G_MISS_DATE THEN
	   	  l_dsfv_rec.start_date := l_sysdate;
	   END IF;


          l_attrib_tbl(1).attribute       := 'NAME';
    	  l_attrib_tbl(1).attrib_type	:= okl_accounting_util.G_VARCHAR2;
    	  l_attrib_tbl(1).value	        := l_dsfv_rec.name;

  	  okl_accounting_util.get_version(p_attrib_tbl	  	     => l_attrib_tbl,
  				           p_cur_version	     => l_dsfv_rec.version,
				           p_end_date_attribute_name => 'END_DATE',
				           p_end_date		     => l_dsfv_rec.end_date,
				           p_view		     => 'Okl_Data_Src_Fnctns_V',
  				           x_return_status	     => l_return_status,
				           x_new_version	     => l_new_version);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSE
	   	  l_dsfv_rec.version := l_new_version;
       END IF;

	   -- call verify changes to update the database
	   l_dsfv_rec.id := OKL_API.G_MISS_NUM;

	   IF l_dsfv_rec.end_date > l_db_dsfv_rec.end_date THEN
	   	  check_updates(p_upd_dsfv_rec	=> l_upd_dsfv_rec,
	   				    p_db_dsfv_rec	=> l_db_dsfv_rec,
					  	p_dsfv_rec		=> l_dsfv_rec,
					  	x_return_status => l_return_status,
					  	x_msg_data		=> x_msg_data);
       	  IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          	 RAISE OKL_API.G_EXCEPTION_ERROR;
       	  ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
	   END IF;

	   -- public api to insert functions
       okl_data_src_fnctns_pub.insert_data_src_fnctns(p_api_version   => p_api_version,
                            		 	              p_init_msg_list => p_init_msg_list,
                              		 				  x_return_status => l_return_status,
                              		 				  x_msg_count     => x_msg_count,
                              		 				  x_msg_data      => x_msg_data,
                              		 				  p_dsfv_rec      => l_dsfv_rec,
                              		 				  x_dsfv_rec      => x_dsfv_rec);
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

  END update_functions;

END OKL_SETUPFUNCTIONS_PVT;

/
