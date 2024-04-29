--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_PRCPARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_PRCPARAMS_PVT" AS
/* $Header: OKLRPPRB.pls 115.1 2004/07/02 02:56:28 sgorantl noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_SIF_PRICE_PARMS_V
  -- modified by smahapat 01-16-2002
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    	p_sppv_rec                     	IN sppv_rec_type,
	x_return_status			OUT NOCOPY VARCHAR2,
    	x_no_data_found                	OUT NOCOPY BOOLEAN,
	x_sppv_rec			OUT NOCOPY sppv_rec_type
  ) IS
    CURSOR okl_sppv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
	    VERSION,
            DATE_START,
            NVL(DATE_END,OKL_API.G_MISS_DATE) DATE_END,
            NVL(DESCRIPTION,G_MISS_CHAR) DESCRIPTION,
            SPS_CODE,
            DYP_CODE,
            ARRAY_YN,
            NVL(ATTRIBUTE_CATEGORY,G_MISS_CHAR) ATTRIBUTE_CATEGORY,
            NVL(ATTRIBUTE1,G_MISS_CHAR) ATTRIBUTE1,
            NVL(ATTRIBUTE2,G_MISS_CHAR) ATTRIBUTE2,
            NVL(ATTRIBUTE3,G_MISS_CHAR) ATTRIBUTE3,
            NVL(ATTRIBUTE4,G_MISS_CHAR) ATTRIBUTE4,
            NVL(ATTRIBUTE5,G_MISS_CHAR) ATTRIBUTE5,
            NVL(ATTRIBUTE6,G_MISS_CHAR) ATTRIBUTE6,
            NVL(ATTRIBUTE7,G_MISS_CHAR) ATTRIBUTE7,
            NVL(ATTRIBUTE8,G_MISS_CHAR) ATTRIBUTE8,
            NVL(ATTRIBUTE9,G_MISS_CHAR) ATTRIBUTE9,
            NVL(ATTRIBUTE10,G_MISS_CHAR) ATTRIBUTE10,
            NVL(ATTRIBUTE11,G_MISS_CHAR) ATTRIBUTE11,
            NVL(ATTRIBUTE12,G_MISS_CHAR) ATTRIBUTE12,
            NVL(ATTRIBUTE13,G_MISS_CHAR) ATTRIBUTE13,
            NVL(ATTRIBUTE14,G_MISS_CHAR) ATTRIBUTE14,
            NVL(ATTRIBUTE15,G_MISS_CHAR) ATTRIBUTE15,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN,G_MISS_NUM) LAST_UPDATE_LOGIN
-- start change smahapat 01/11/02 - replace OKL_SIF_PRICE_PARMS_V by OKL_SIF_PRICE_PARMS
     FROM OKL_SIF_PRICE_PARMS
     WHERE OKL_SIF_PRICE_PARMS.id = p_id;
-- end change smahapat

    l_okl_sppv_pk                  okl_sppv_pk_csr%ROWTYPE;
    l_sppv_rec                     sppv_rec_type;
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_sppv_pk_csr (p_sppv_rec.id);
    FETCH okl_sppv_pk_csr INTO
              l_sppv_rec.ID,
              l_sppv_rec.OBJECT_VERSION_NUMBER,
              l_sppv_rec.NAME,
              l_sppv_rec.VERSION,
              l_sppv_rec.DATE_START,
              l_sppv_rec.DATE_END,
              l_sppv_rec.DESCRIPTION,
              l_sppv_rec.SPS_CODE,
              l_sppv_rec.DYP_CODE,
              l_sppv_rec.ARRAY_YN,
              l_sppv_rec.ATTRIBUTE_CATEGORY,
              l_sppv_rec.ATTRIBUTE1,
              l_sppv_rec.ATTRIBUTE2,
              l_sppv_rec.ATTRIBUTE3,
              l_sppv_rec.ATTRIBUTE4,
              l_sppv_rec.ATTRIBUTE5,
              l_sppv_rec.ATTRIBUTE6,
              l_sppv_rec.ATTRIBUTE7,
              l_sppv_rec.ATTRIBUTE8,
              l_sppv_rec.ATTRIBUTE9,
              l_sppv_rec.ATTRIBUTE10,
              l_sppv_rec.ATTRIBUTE11,
              l_sppv_rec.ATTRIBUTE12,
              l_sppv_rec.ATTRIBUTE13,
              l_sppv_rec.ATTRIBUTE14,
              l_sppv_rec.ATTRIBUTE15,
              l_sppv_rec.CREATED_BY,
              l_sppv_rec.LAST_UPDATED_BY,
              l_sppv_rec.CREATION_DATE,
              l_sppv_rec.LAST_UPDATE_DATE,
              l_sppv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_sppv_pk_csr%NOTFOUND;
    CLOSE okl_sppv_pk_csr;

    x_sppv_rec := l_sppv_rec;
    x_return_status := l_return_status;
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
		x_return_status := G_RET_STS_UNEXP_ERROR;

      IF (okl_sppv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_sppv_pk_csr;
      END IF;

  END get_rec;


  ---------------------------------------------------------------------------
  -- PROCEDURE get_changes_only for: OKL_SIF_PRICE_PARMS_V
  -- To take care of the assumption that Everything except the Changed Fields
  -- have G_MISS values in them
  -- added by smahapat 01-16-2002
  ---------------------------------------------------------------------------
  PROCEDURE get_changes_only ( p_sppv_rec                 IN sppv_rec_type,
    p_db_rec                   IN sppv_rec_type,
    x_sppv_rec                 OUT NOCOPY sppv_rec_type )
  IS
    l_sppv_rec sppv_rec_type;
  BEGIN
        l_sppv_rec := p_sppv_rec;

    	IF p_db_rec.NAME = p_sppv_rec.NAME THEN
    		l_sppv_rec.NAME := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.VERSION = p_sppv_rec.VERSION THEN
    		l_sppv_rec.NAME := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.DATE_START = p_sppv_rec.DATE_START THEN
    		l_sppv_rec.DATE_START := G_MISS_DATE;
    	END IF;

	IF p_db_rec.DATE_END IS NULL THEN
	  IF p_sppv_rec.DATE_END IS NULL THEN
	    l_sppv_rec.DATE_END := G_MISS_DATE;
	  END IF;
    	ELSIF p_db_rec.DATE_END = p_sppv_rec.DATE_END THEN
          l_sppv_rec.DATE_END := G_MISS_DATE;
    	END IF;

    	IF p_db_rec.DESCRIPTION IS NULL THEN
    	  IF p_sppv_rec.DESCRIPTION IS NULL THEN
    	    l_sppv_rec.DESCRIPTION := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.DESCRIPTION = p_sppv_rec.DESCRIPTION THEN
    	  l_sppv_rec.DESCRIPTION := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.SPS_CODE = p_sppv_rec.SPS_CODE THEN
    		l_sppv_rec.SPS_CODE := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.DYP_CODE = p_sppv_rec.DYP_CODE THEN
    		l_sppv_rec.DYP_CODE := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ARRAY_YN = p_sppv_rec.ARRAY_YN THEN
    		l_sppv_rec.ARRAY_YN := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE_CATEGORY IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE_CATEGORY IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE_CATEGORY := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE_CATEGORY = p_sppv_rec.ATTRIBUTE_CATEGORY THEN
          l_sppv_rec.ATTRIBUTE_CATEGORY := G_MISS_CHAR;
    	END IF;

        IF p_db_rec.ATTRIBUTE1 IS NULL THEN
	  IF p_sppv_rec.ATTRIBUTE1 IS NULL THEN
	    l_sppv_rec.ATTRIBUTE1 := G_MISS_CHAR;
	  END IF;
	ELSIF p_db_rec.ATTRIBUTE1 = p_sppv_rec.ATTRIBUTE1 THEN
	  l_sppv_rec.ATTRIBUTE1 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE2 IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE2 IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE2 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE2 = p_sppv_rec.ATTRIBUTE2 THEN
          l_sppv_rec.ATTRIBUTE2 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE3 IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE3 IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE3 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE3 = p_sppv_rec.ATTRIBUTE3 THEN
          l_sppv_rec.ATTRIBUTE3 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE4 IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE4 IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE4 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE4 = p_sppv_rec.ATTRIBUTE4 THEN
          l_sppv_rec.ATTRIBUTE4 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE5 IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE5 IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE5 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE5 = p_sppv_rec.ATTRIBUTE5 THEN
          l_sppv_rec.ATTRIBUTE5 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE6 IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE6 IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE6 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE6 = p_sppv_rec.ATTRIBUTE6 THEN
          l_sppv_rec.ATTRIBUTE6 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE7 IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE7 IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE7 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE7 = p_sppv_rec.ATTRIBUTE7 THEN
          l_sppv_rec.ATTRIBUTE7 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE8 IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE8 IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE8 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE8 = p_sppv_rec.ATTRIBUTE8 THEN
          l_sppv_rec.ATTRIBUTE8 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE9 IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE9 IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE9 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE9 = p_sppv_rec.ATTRIBUTE9 THEN
          l_sppv_rec.ATTRIBUTE9 := G_MISS_CHAR;
    	END IF;

        IF p_db_rec.ATTRIBUTE10 IS NULL THEN
	  IF p_sppv_rec.ATTRIBUTE10 IS NULL THEN
	    l_sppv_rec.ATTRIBUTE10 := G_MISS_CHAR;
	  END IF;
	ELSIF p_db_rec.ATTRIBUTE10 = p_sppv_rec.ATTRIBUTE10 THEN
	  l_sppv_rec.ATTRIBUTE10 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE11 IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE11 IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE11 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE11 = p_sppv_rec.ATTRIBUTE11 THEN
          l_sppv_rec.ATTRIBUTE11 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE12 IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE12 IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE12 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE12 = p_sppv_rec.ATTRIBUTE12 THEN
          l_sppv_rec.ATTRIBUTE12 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE13 IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE13 IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE13 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE13 = p_sppv_rec.ATTRIBUTE13 THEN
          l_sppv_rec.ATTRIBUTE13 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE5 IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE5 IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE5 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE5 = p_sppv_rec.ATTRIBUTE5 THEN
          l_sppv_rec.ATTRIBUTE5 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE15 IS NULL THEN
    	  IF p_sppv_rec.ATTRIBUTE15 IS NULL THEN
    	    l_sppv_rec.ATTRIBUTE15 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE15 = p_sppv_rec.ATTRIBUTE15 THEN
          l_sppv_rec.ATTRIBUTE15 := G_MISS_CHAR;
    	END IF;

        x_sppv_rec := l_sppv_rec;
  END get_changes_only;

  ---------------------------------------------------------------------------
  -- PROCEDURE determine_action for: OKL_SIF_PRICE_PARMS_V
  -- This function helps in determining the various checks to be performed
  -- for the new/updated record and also helps in determining whether a new
  -- version is required or not
  ---------------------------------------------------------------------------
  FUNCTION determine_action (p_upd_sppv_rec     IN sppv_rec_type,
				p_db_sppv_rec	IN sppv_rec_type,
				p_date		IN DATE
  ) RETURN VARCHAR2 IS
  l_action VARCHAR2(1);
  l_sysdate DATE := trunc(SYSDATE);
BEGIN

  /* Scenario 1: The Changed Field-Values can by-pass Validation */
  IF p_upd_sppv_rec.date_start = G_MISS_DATE AND
	 p_upd_sppv_rec.date_end = G_MISS_DATE AND
	 p_upd_sppv_rec.sps_code = G_MISS_CHAR AND
	 p_upd_sppv_rec.dyp_code = G_MISS_CHAR AND
	 p_upd_sppv_rec.array_yn = G_MISS_CHAR THEN
	 l_action := '1';

	/* Scenario 2: The Changed Field-Values include that needs Validation and Update
	*  but does not require a new vresion to be created
	*/
	--	1) Only End_Date is Changed
  ELSIF (p_upd_sppv_rec.date_start = G_MISS_DATE AND
	     (p_upd_sppv_rec.date_end <> G_MISS_DATE OR
		 --  IS NULL Condition has been added in case end_date was updated to NULL
	     p_upd_sppv_rec.date_end IS NULL ) AND
    	 p_upd_sppv_rec.sps_code = G_MISS_CHAR AND
    	 p_upd_sppv_rec.dyp_code = G_MISS_CHAR AND
    	 p_upd_sppv_rec.array_yn = G_MISS_CHAR) OR
	--	2)	Critical Attributes are Changed but Start_Date is Today or Future
	    (p_upd_sppv_rec.date_start = G_MISS_DATE AND
	     p_db_sppv_rec.date_start >= p_date AND
	     (p_upd_sppv_rec.sps_code <> G_MISS_CHAR OR
    	 p_upd_sppv_rec.dyp_code <> G_MISS_CHAR OR
    	 p_upd_sppv_rec.array_yn <> G_MISS_CHAR)) OR
	--	3)	Start_Date is Changed , but in Future
	    (p_upd_sppv_rec.date_start <> G_MISS_DATE AND
	     p_db_sppv_rec.date_start > p_date AND
		 p_upd_sppv_rec.date_start >= p_date) THEN
	 l_action := '2';
  ELSE
	/* Scenario 3: The Changed Field-Values mandate Creation of a New Version/Record */
     l_action := '3';
  END IF;
  RETURN(l_action);
  END determine_action;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_updates
  -- To verify whether the requested changes from the screen are valid or not
  ---------------------------------------------------------------------------
  PROCEDURE check_updates (
	p_sppv_rec		IN sppv_rec_type,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_data		OUT NOCOPY VARCHAR2
  ) IS
  l_sppv_rec	  sppv_rec_type;
  l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_valid		  BOOLEAN;
  l_attrib_tbl	okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
	   l_return_status := G_RET_STS_SUCCESS;
	   l_sppv_rec := p_sppv_rec;

		  /* call check_overlaps */
		l_attrib_tbl(1).attribute	:= 'name';
  		l_attrib_tbl(1).attrib_type	:= okl_accounting_util.G_VARCHAR2;
		l_attrib_tbl(1).value	:= l_sppv_rec.name;

		  okl_accounting_util.check_overlaps(p_id => l_sppv_rec.id,
                                                     p_attrib_tbl => l_attrib_tbl,
                                                     p_start_date_attribute_name => 'DATE_START',
		  				     p_start_date => l_sppv_rec.date_start,
                                                     p_end_date_attribute_name => 'DATE_END',
						     p_end_date => l_sppv_rec.date_end,
						     p_view => 'OKL_SIF_PRICE_PARMS_V',
						     x_return_status => l_return_status,
						     x_valid => l_valid);

       	  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
       		 x_return_status    := G_RET_STS_UNEXP_ERROR;
      	  	 RAISE G_EXCEPTION_HALT_PROCESSING;
       	  ELSIF (l_return_status = G_RET_STS_ERROR) OR
		  	    (l_return_status = G_RET_STS_SUCCESS AND
		   	     l_valid <> TRUE) THEN
       		 x_return_status    := G_RET_STS_ERROR;
      	  	 RAISE G_EXCEPTION_HALT_PROCESSING;
       	  END IF;
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END check_updates;

  ---------------------------------------------------------------------------
  -- PROCEDURE create_price_parm for: OKL_SIF_PRICE_PARMS_V
  ---------------------------------------------------------------------------
  PROCEDURE create_price_parm(	p_api_version                  IN  NUMBER,
	                        p_init_msg_list                IN  VARCHAR2 DEFAULT G_FALSE,
   	 	                p_sppv_rec                     IN  sppv_rec_type,
	 	                x_return_status                OUT NOCOPY VARCHAR2,
 	 	                x_msg_count                    OUT NOCOPY NUMBER,
  	 	                x_msg_data                     OUT NOCOPY VARCHAR2,
      		                x_sppv_rec                     OUT NOCOPY sppv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'create_price_parm';
    l_no_data_found   	  	BOOLEAN := TRUE;
	l_valid			  BOOLEAN := TRUE;
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
	l_sppv_rec		  sppv_rec_type;
	l_sysdate		  DATE := to_date(SYSDATE, 'DD/MM/YYYY');
  BEGIN
    l_return_status := G_RET_STS_SUCCESS;
	l_sppv_rec := p_sppv_rec;

	--  mvasudev -- 02/17/2002
	-- Store NAME in UPPER CASE always
	l_sppv_rec.NAME := UPPER(l_sppv_rec.NAME);
	-- end, mvasudev -- 02/17/2002

     /*
     -- mvasudev COMMENTED , 06/13/2002
     --check for the records with start and end dates less than sysdate
    IF to_date(l_sppv_rec.date_start, 'DD/MM/YYYY') < l_sysdate OR
	   to_date(l_sppv_rec.date_end, 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE G_EXCEPTION_ERROR;
	END IF;
    */

	/* public api to insert_sif_price_parms */
    okl_sif_price_parms_pub.insert_sif_price_parms(p_api_version   => p_api_version,
                              		 p_init_msg_list => p_init_msg_list,
                              		 x_return_status => l_return_status,
                              		 x_msg_count     => x_msg_count,
                              		 x_msg_data      => x_msg_data,
                              		 p_sppv_rec      => l_sppv_rec,
                              		 x_sppv_rec      => x_sppv_rec);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

     x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END create_price_parm;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_price_parm for: OKL_SIF_PRICE_PARMS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_price_parm(p_api_version                    IN  NUMBER,
	                        p_init_msg_list                IN  VARCHAR2 DEFAULT G_FALSE,
                        	p_sppv_rec                     IN  sppv_rec_type,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	x_sppv_rec                     OUT NOCOPY sppv_rec_type
                        )
  IS

    CURSOR l_okl_sppv_pk_csr (p_id IN NUMBER) IS
    SELECT
			DATE_START,
			DATE_END
      FROM OKL_SIF_PRICE_PARMS
     WHERE OKL_SIF_PRICE_PARMS.id   = p_id;

    l_api_version     	  	CONSTANT NUMBER := 1;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_price_parm';
    l_no_data_found   	  	BOOLEAN := TRUE;
    l_valid			BOOLEAN := TRUE;
    l_oldversion_enddate  	DATE := to_date(SYSDATE, 'DD/MM/YYYY');
    l_sysdate		  	DATE := to_date(SYSDATE, 'DD/MM/YYYY');
    l_db_sppv_rec    	  	sppv_rec_type; /* database copy */
    l_upd_sppv_rec	   	sppv_rec_type; /* input copy */
    l_sppv_rec	  	   	sppv_rec_type; /* latest with the retained changes */
    l_tmp_sppv_rec		sppv_rec_type; /* for any other purposes */
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_action		        VARCHAR2(1);
    l_new_version		VARCHAR2(100);
    l_attrib_tbl	        okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
    l_return_status := G_RET_STS_SUCCESS;
    l_sppv_rec := p_sppv_rec;

	-- END_DATE needs to be after START_DATE (sanity check)
	-- and Cannot be less than SysDate
	IF  l_sppv_rec.date_end IS NOT NULL
	AND TO_DATE(l_sppv_rec.date_end, 'DD/MM/YYYY') <> TO_DATE(G_MISS_DATE, 'DD/MM/YYYY')
	AND
	   (   TO_DATE(l_sppv_rec.date_end, 'DD/MM/YYYY') < TO_DATE(l_sppv_rec.DATE_START, 'DD/MM/YYYY')
	    OR TO_DATE(l_sppv_rec.date_end, 'DD/MM/YYYY') < l_sysdate
	   )
	THEN
	      OKC_API.SET_MESSAGE( p_app_name   => OKC_API.G_APP_NAME,
                           p_msg_name       => G_INVALID_VALUE,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'date_end' );
	   RAISE G_EXCEPTION_ERROR;
	END IF;

    -- Get current database values
    OPEN l_okl_sppv_pk_csr (p_sppv_rec.id);
    FETCH l_okl_sppv_pk_csr INTO
		l_db_sppv_rec.DATE_START,
		l_db_sppv_rec.DATE_END;
    l_no_data_found := l_okl_sppv_pk_csr%NOTFOUND;
    CLOSE l_okl_sppv_pk_csr;

	IF l_no_data_found THEN
	   RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;


        -- start date can not be greater than old start date if the record is active
        IF  TO_DATE(l_db_sppv_rec.DATE_START,'DD/MM/YYYY') < l_sysdate
        AND TO_DATE(l_sppv_rec.DATE_START, 'DD/MM/YYYY') > TO_DATE(l_db_sppv_rec.DATE_START, 'DD/MM/YYYY')
	THEN
	      OKC_API.SET_MESSAGE( p_app_name   => OKC_API.G_APP_NAME,
                           p_msg_name       => G_INVALID_VALUE,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'DATE_START' );
	   RAISE G_EXCEPTION_ERROR;
        END IF;


       -- public api to update_price_parm
       okl_sif_price_parms_pub.update_sif_price_parms(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_sppv_rec      => l_sppv_rec,
                              		 	x_sppv_rec      => x_sppv_rec);
    IF l_return_status = G_RET_STS_ERROR THEN
      RAISE G_EXCEPTION_ERROR;
    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    /*******************************************************************
    *  FOLLOWING CODE COMMENTED TO DISABLE  MULTIPLE VERSIONING
    *  Jun-13-2002, mvasudev
    *



	-- mvasudev -- 02/17/2002
	-- END_DATE needs to be after START_DATE (sanity check)
	IF  l_sppv_rec.date_end IS NOT NULL
	AND  to_date(l_sppv_rec.date_end, 'DD/MM/YYYY') <> to_date(G_MISS_DATE, 'DD/MM/YYYY')
	AND to_date(l_sppv_rec.date_end, 'DD/MM/YYYY') < to_date(l_sppv_rec.date_start, 'DD/MM/YYYY')
	THEN
	      OKC_API.SET_MESSAGE( p_app_name   => OKC_API.G_APP_NAME,
                           p_msg_name       => G_INVALID_VALUE,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'END_DATE' );
	END IF;
	-- end, mvasudev -- 02/17/2002

    -- fetch old details from the database
    get_rec(p_sppv_rec => l_sppv_rec,
            x_return_status => l_return_status,
	    x_no_data_found => l_no_data_found,
    	    x_sppv_rec => l_db_sppv_rec);

    IF l_return_status <> G_RET_STS_SUCCESS OR
       l_no_data_found = TRUE THEN
       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    -- check for the records if start and end dates are in the past
    IF to_date(l_db_sppv_rec.date_start,'DD/MM/YYYY') < l_sysdate AND
	   to_date(l_db_sppv_rec.date_end,'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
			       p_msg_name => G_PAST_RECORDS);
    RAISE G_EXCEPTION_ERROR;
    END IF;

    -- retain the details that has been changed only
    get_changes_only(p_sppv_rec => p_sppv_rec,
	             p_db_rec => l_db_sppv_rec,
	             x_sppv_rec => l_upd_sppv_rec);

	/* mvasudev, 02/17/2002

	-- check for start date greater than sysdate
	IF to_date(l_upd_sppv_rec.date_start, 'DD/MM/YYYY') <> to_date(G_MISS_DATE, 'DD/MM/YYYY') AND
	   to_date(l_upd_sppv_rec.date_start,'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
	   RAISE G_EXCEPTION_ERROR;
    END IF;

	-- check for end date greater than sysdate
   IF to_date(l_upd_sppv_rec.date_end, 'DD/MM/YYYY') <> to_date(G_MISS_DATE, 'DD/MM/YYYY') AND
      to_date(l_upd_sppv_rec.date_end,'DD/MM/YYYY') < l_sysdate THEN
         OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
					   p_msg_name		=> G_END_DATE);
         RAISE G_EXCEPTION_ERROR;
    END IF;


	-- START_DATE , if changed, can only be later than TODAY
	IF to_date(l_upd_sppv_rec.date_start, 'DD/MM/YYYY') <> to_date(G_MISS_DATE, 'DD/MM/YYYY') AND
	   to_date(l_upd_sppv_rec.date_start,'DD/MM/YYYY') <= l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
	   RAISE G_EXCEPTION_ERROR;
    END IF;

	-- END_DATE, if changed, cannot be earlier than TODAY
   IF to_date(l_upd_sppv_rec.date_end, 'DD/MM/YYYY') <> to_date(G_MISS_DATE, 'DD/MM/YYYY') AND
      to_date(l_upd_sppv_rec.date_end,'DD/MM/YYYY') < l_sysdate THEN
         OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
					   p_msg_name		=> G_END_DATE);
         RAISE G_EXCEPTION_ERROR;
    END IF;

	-- end, mvasudev -- 02/17/2002


	-- determine how the processing to be done
	l_action := determine_action(p_upd_sppv_rec	 => l_upd_sppv_rec,
			 					 p_db_sppv_rec	 => l_db_sppv_rec,
								 p_date			 => l_sysdate);
  -- Scenario 1: The Changed Field-Values can by-pass Validation *
	IF l_action = '1' THEN
	   -- public api to update_price_parm *
       okl_sif_price_parms_pub.update_sif_price_parms(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_sppv_rec      => l_upd_sppv_rec,
                              		 	x_sppv_rec      => x_sppv_rec);
       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	-- Scenario 2: The Changed Field-Values include that needs Validation and Update
	ELSIF l_action = '2' THEN
	   -- create a temporary record with all relevant details from db and upd records
	   -- removed call to defaults_to_actuals() by smahapat 01-16-2002
	   l_sppv_rec := p_sppv_rec;

	   check_updates(p_sppv_rec => l_sppv_rec,
			 x_return_status => l_return_status,
			 x_msg_data => x_msg_data);
       IF l_return_status = G_RET_STS_ERROR THEN
       	  RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   -- public api to update price parms
       okl_sif_price_parms_pub.update_sif_price_parms(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_sppv_rec      => l_upd_sppv_rec,
                              		 	x_sppv_rec      => x_sppv_rec);
       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	-- Scenario 3: The Changed Field-Values mandate Creation of a New Version/Record
	ELSIF l_action = '3' THEN

	   -- mvasudev -- 02/17/2002
	   -- DO NOT Update Old-record if new Start_Date is after Old End_Date
	   IF  l_upd_sppv_rec.date_start <> G_MISS_DATE
	   AND l_db_sppv_rec.date_end IS NOT NULL
           AND l_upd_sppv_rec.date_start >  l_db_sppv_rec.date_end
	   THEN
	     NULL;
	   ELSE

		   -- for old version
		   IF l_upd_sppv_rec.date_start <> G_MISS_DATE THEN
			  l_oldversion_enddate := l_upd_sppv_rec.date_start - 1;
		   ELSE
		      --mvasudev , 02/17/2002
			  -- The earliest end_date, if changed , can be TODAY.

		   	  --l_oldversion_enddate := l_sysdate - 1;
			  l_oldversion_enddate := l_sysdate;

			  -- end, mvasudev -- 02/17/2002
		   END IF;

		   l_sppv_rec := l_db_sppv_rec;
		   l_sppv_rec.date_end := l_oldversion_enddate;

		   -- call verify changes to update the database
		   IF l_oldversion_enddate > l_db_sppv_rec.date_end THEN
		     check_updates(p_sppv_rec => l_sppv_rec,
				   x_return_status => l_return_status,
				   x_msg_data => x_msg_data);

		     IF l_return_status = G_RET_STS_ERROR THEN
		       RAISE G_EXCEPTION_ERROR;
		     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
		       RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		     END IF;
		   END IF;

		   -- public api to update formulae
	       okl_sif_price_parms_pub.update_sif_price_parms(p_api_version   => p_api_version,
							p_init_msg_list => p_init_msg_list,
							x_return_status => l_return_status,
							x_msg_count     => x_msg_count,
							x_msg_data      => x_msg_data,
							p_sppv_rec      => l_sppv_rec,
							x_sppv_rec      => x_sppv_rec);

	       IF l_return_status = G_RET_STS_ERROR THEN
		  RAISE G_EXCEPTION_ERROR;
	       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
		  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	       END IF;
	    END IF;
	   -- end,mvasudev -- 02/17/2002

	   -- for new version
	   -- create a temporary record with all relevant details from db and upd records
	   -- removed call to defaults_to_actuals() by smahapat 01-16-2002
	   l_sppv_rec := p_sppv_rec;

	   -- mvasudev , 02/17/2002
	   -- The earliest START_DATE, when Update,  can be TOMORROW only
	   IF l_upd_sppv_rec.date_start = G_MISS_DATE THEN
	   	  --l_sppv_rec.date_start := l_sysdate ;
		  l_sppv_rec.date_start := l_sysdate + 1 ;
	   END IF;

		l_attrib_tbl(1).attribute := 'name';
		l_attrib_tbl(1).attrib_type := okl_accounting_util.G_VARCHAR2;
		l_attrib_tbl(1).value := l_sppv_rec.name;

    	okl_accounting_util.get_version(
								        p_attrib_tbl				=> l_attrib_tbl,
    							      	p_cur_version				=> l_sppv_rec.version,
                                    	p_end_date_attribute_name	=> 'DATE_END',
				                       p_end_date		=> l_sppv_rec.date_end,
                                    	p_view						=> 'OKL_SIF_PRICE_PARMS_V',
  				                       x_return_status				=> l_return_status,
				                       x_new_version				=> l_new_version);

       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSE
	   	  l_sppv_rec.version := l_new_version;
       END IF;

	   l_sppv_rec.id := G_MISS_NUM;

	   -- call verify changes to update the database
	   IF l_sppv_rec.date_end > l_db_sppv_rec.date_end THEN
	     check_updates(p_sppv_rec => l_sppv_rec,
			   x_return_status => l_return_status,
			   x_msg_data => x_msg_data);
       	  IF l_return_status = G_RET_STS_ERROR THEN
          	 RAISE G_EXCEPTION_ERROR;
       	  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  	 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
	   END IF;

	   -- public api to insert price parms
       okl_sif_price_parms_pub.insert_sif_price_parms(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_sppv_rec      => l_sppv_rec,
                              		 	x_sppv_rec      => x_sppv_rec);

       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   -- copy output to input structure to get the id
	   l_sppv_rec := x_sppv_rec;

	END IF;
  *******************************************************************/
  -- end, 06/13/2002 , mvasudev

	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_price_parm;

  PROCEDURE create_price_parm(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT G_FALSE,
         p_sppv_tbl                     IN  sppv_tbl_type,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         x_sppv_tbl                     OUT NOCOPY sppv_tbl_type)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'create_price_parm_tbl';
	rec_num		INTEGER	:= 0;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_version     	  	CONSTANT NUMBER := 1;
   BEGIN


        FOR rec_num IN 1..p_sppv_tbl.COUNT
	LOOP
		create_price_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sppv_rec                     => p_sppv_tbl(rec_num),
         x_sppv_rec                     => x_sppv_tbl(rec_num) );
	END LOOP;

	x_return_status := l_return_status;

   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END create_price_parm;


  PROCEDURE update_price_parm(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT G_FALSE,
         p_sppv_tbl                     IN  sppv_tbl_type,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         x_sppv_tbl                     OUT NOCOPY sppv_tbl_type)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_price_parm_tbl';
	rec_num		INTEGER	:= 0;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_version     	  	CONSTANT NUMBER := 1;
   BEGIN


 	FOR rec_num IN 1..p_sppv_tbl.COUNT
	LOOP
		update_price_parm(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_sppv_rec                     => p_sppv_tbl(rec_num),
         x_sppv_rec                     => x_sppv_tbl(rec_num) );
	END LOOP;

	x_return_status := l_return_status;

   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END update_price_parm;


END OKL_SETUP_PRCPARAMS_PVT;

/
