--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_PRD_PRCTEMPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_PRD_PRCTEMPL_PVT" AS
/* $Header: OKLRPPEB.pls 120.2 2005/10/30 03:40:32 appldev noship $ */

  ---------------------------------------------------------------------------
  -- FUNCTION BOOLEAN_TO_CHAR
  ---------------------------------------------------------------------------
  FUNCTION BOOLEAN_TO_CHAR(p_flag IN BOOLEAN)
  RETURN VARCHAR2
  IS
  	l_boolean_char VARCHAR2(1);
  BEGIN
  	IF (p_flag) THEN
  		l_boolean_char := G_TRUE;
  	ELSE
    		l_boolean_char := G_FALSE;
    	END IF;

    RETURN l_boolean_char;
  END BOOLEAN_TO_CHAR;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_PRD_PRICE_TMPLS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_pitv_rec              IN pitv_rec_type,
	x_return_status			OUT NOCOPY VARCHAR2,
       x_no_data_found         OUT NOCOPY BOOLEAN,
	x_pitv_rec				OUT NOCOPY pitv_rec_type
  ) IS
    CURSOR okl_pit_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            PDT_ID,
            TEMPLATE_NAME,
            TEMPLATE_PATH,
		    VERSION,
	        START_DATE,
		    END_DATE,
			DESCRIPTION,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_DATE,
		    LAST_UPDATE_LOGIN
      FROM OKL_PRD_PRICE_TMPLS
     WHERE OKL_PRD_PRICE_TMPLS.id = p_id;

    l_okl_pitv_pk                  okl_pit_pk_csr%ROWTYPE;
    l_pitv_rec                     pitv_rec_type;
  l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_pit_pk_csr (p_pitv_rec.id);
    FETCH okl_pit_pk_csr INTO
            l_pitv_rec.ID,
            l_pitv_rec.OBJECT_VERSION_NUMBER,
            l_pitv_rec.PDT_ID,
            l_pitv_rec.TEMPLATE_NAME,
            l_pitv_rec.TEMPLATE_PATH,
			l_pitv_rec.VERSION,
			l_pitv_rec.START_DATE,
			l_pitv_rec.END_DATE,
			l_pitv_rec.DESCRIPTION,
            l_pitv_rec.CREATED_BY,
            l_pitv_rec.CREATION_DATE,
            l_pitv_rec.LAST_UPDATED_BY,
            l_pitv_rec.LAST_UPDATE_DATE,
            l_pitv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pit_pk_csr%NOTFOUND;
    CLOSE okl_pit_pk_csr;

	x_pitv_rec := l_pitv_rec;
	x_return_status := l_return_status;
	EXCEPTION
	WHEN OTHERS THEN

		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
		-- notify UNEXPECTED error for calling API.
		x_return_status := G_RET_STS_UNEXP_ERROR;

      IF (okl_pit_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_pit_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_changes_only
  -- To take care of the assumption that Everything
  -- except the Changed Fields have G_MISS values in them
  ---------------------------------------------------------------------------
  PROCEDURE get_changes_only (
    p_pitv_rec              IN pitv_rec_type,
	p_db_rec   		IN pitv_rec_type,
	x_pitv_rec				OUT NOCOPY pitv_rec_type  )
  IS
   l_pitv_rec pitv_rec_type;
  BEGIN
  	l_pitv_rec := p_pitv_rec;

      	IF p_db_rec.PDT_ID = p_pitv_rec.PDT_ID
      	THEN
      		l_pitv_rec.PDT_ID := G_MISS_NUM;
      	END IF;
      	IF p_db_rec.TEMPLATE_NAME = p_pitv_rec.TEMPLATE_NAME
      	THEN
      		l_pitv_rec.TEMPLATE_NAME := G_MISS_CHAR;
      	END IF;

      	IF p_db_rec.VERSION = p_pitv_rec.VERSION
      	THEN
      		l_pitv_rec.VERSION := G_MISS_CHAR;
      	END IF;

      	IF p_db_rec.START_DATE = p_pitv_rec.START_DATE
      	THEN
      		l_pitv_rec.START_DATE := G_MISS_DATE;
      	END IF;

      	IF p_db_rec.TEMPLATE_PATH IS NULL
	THEN
	    IF p_pitv_rec.TEMPLATE_PATH IS NULL
	    THEN
	        l_pitv_rec.TEMPLATE_PATH := G_MISS_CHAR;
	    END IF;
	ELSIF p_db_rec.TEMPLATE_PATH = p_pitv_rec.TEMPLATE_PATH
	THEN
	    l_pitv_rec.TEMPLATE_PATH := G_MISS_CHAR;
      	END IF;

      	IF p_db_rec.END_DATE IS NULL
      	THEN
      		 IF p_pitv_rec.END_DATE IS NULL
      		 THEN
      			l_pitv_rec.END_DATE := G_MISS_DATE;
      		END IF;
      	ELSIF p_db_rec.END_DATE = p_pitv_rec.END_DATE
      	THEN
      		l_pitv_rec.END_DATE := G_MISS_DATE;
      	END IF;

	IF p_db_rec.DESCRIPTION IS NULL
	THEN
		 IF p_pitv_rec.DESCRIPTION IS NULL
		 THEN
			l_pitv_rec.DESCRIPTION := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.DESCRIPTION = p_pitv_rec.DESCRIPTION
	THEN
		l_pitv_rec.DESCRIPTION := G_MISS_CHAR;
	END IF;

	x_pitv_rec := l_pitv_rec;

  END get_changes_only;

  ---------------------------------------------------------------------------
  -- PROCEDURE determine_action for: OKL_PRD_PRICE_TMPLS_V
  -- This function helps in determining the various checks to be performed
  -- for the new/updated record and also helps in determining whether a new
  -- version is required or not
  ---------------------------------------------------------------------------
  FUNCTION determine_action (
    p_upd_pitv_rec                 IN pitv_rec_type,
	p_db_pitv_rec				   IN pitv_rec_type,
	p_date						   IN DATE
  ) RETURN VARCHAR2 IS
  l_action VARCHAR2(1);
  l_sysdate DATE := TRUNC(SYSDATE);
BEGIN

  /* Scenario 1: The Changed Field-Values can by-pass Validation */
  IF p_upd_pitv_rec.start_date = G_MISS_DATE AND
	 p_upd_pitv_rec.end_date = G_MISS_DATE AND
	 p_upd_pitv_rec.template_name = G_MISS_CHAR  THEN
	 l_action := '1';
	/* Scenario 2: The Changed Field-Values include that needs Validation and Update	*/

	--	1) End_Date is Changed
  ELSIF (p_upd_pitv_rec.start_date = G_MISS_DATE AND
	    (p_upd_pitv_rec.end_date <> G_MISS_DATE
	    OR p_upd_pitv_rec.end_date IS NULL  ) AND
    	 p_upd_pitv_rec.template_name = G_MISS_CHAR ) OR
	--	2)	Critical Attributes are Changed but does not mandate new version
	--		as Start_Date is Not Changied
	    (p_upd_pitv_rec.start_date = G_MISS_DATE AND
	     p_db_pitv_rec.start_date >= p_date AND
	     (p_upd_pitv_rec.template_name <> G_MISS_CHAR)) OR
	--	3)	Start_Date is Changed , but in Future
	    (p_upd_pitv_rec.start_date <> G_MISS_DATE AND
	     p_db_pitv_rec.start_date > p_date AND
		 p_upd_pitv_rec.start_date >= p_date) THEN
	 l_action := '2';
  ELSE
	/* Scenario 3: The Changed Field-Values mandate Creation of a New Version/Record */
     l_action := '3';
  END IF;
  RETURN(l_action);
  END determine_action;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_constraints for: OKL_PRD_PRICE_TMPLS_V
  -- To verify whether the dates are valid for both Pricing Template and Products
  -- attached to it
  ---------------------------------------------------------------------------
  PROCEDURE check_constraints (
    p_pitv_rec	IN  pitv_rec_type,
	x_return_status	OUT NOCOPY VARCHAR2,
    x_valid			OUT NOCOPY BOOLEAN
  )
  IS
    CURSOR okl_pit_constraints_csr (p_pit_rec IN pitv_rec_type)
	IS
    SELECT from_date,TO_DATE
    FROM OKL_PRODUCTS
     WHERE id    = p_pit_rec.pdt_id;

    l_pitv_rec      pitv_rec_type;
	l_valid			BOOLEAN := FALSE;
	l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
	l_token1_value VARCHAR2(100);
	l_token2_value VARCHAR2(100);
  BEGIN
    l_valid 		:= TRUE;
    l_pitv_rec 		:= p_pitv_rec;
    l_return_status := G_RET_STS_SUCCESS;

   	FOR l_pdt_rec IN okl_pit_constraints_csr (l_pitv_rec)
       LOOP
	    -- Check START_DATE
		IF l_pitv_rec.start_date <> G_MISS_DATE
		AND l_pdt_rec.from_date >  l_pitv_rec.start_date THEN
    	   		l_valid := FALSE;
		END IF;

		--Check END_DATE
		IF  l_pdt_rec.TO_DATE IS NOT NULL THEN
			IF  l_pitv_rec.end_date IS NULL
			OR  l_pitv_rec.end_date = OKC_API.G_MISS_DATE
			THEN
	   	 	   l_valid := FALSE;
			ELSIF  l_pitv_rec.end_date > l_pdt_rec.TO_DATE
			THEN
	   	 	   l_valid := FALSE;
			END IF;
		END IF;

   	EXIT WHEN(l_valid <> TRUE);
   	END LOOP;

	IF(l_valid <> TRUE) THEN

	-- added akjain to fix bug # 2429053
	-- Get the token value.
	   l_token2_value := Okl_Accounting_Util.Get_Message_Token(p_region_code      => 'OKL_LP_PRCTEMPLAT_CRUPT',
	                                                           p_attribute_code    => 'OKL_PRODUCT_PRICING_TEMPLATE'
	                                                           );

           l_token1_value := Okl_Accounting_Util.Get_Message_Token(p_region_code      => 'OKL_LP_PRCTEMPLAT_CRUPT',
	                                                           p_attribute_code    => 'OKL_PRODUCT'
	                                                           );


   	   OKL_API.SET_MESSAGE(p_app_name	   => G_APP_NAME,
   						   p_msg_name	   => G_DATES_MISMATCH,
   						   p_token1		   => G_PARENT_TABLE_TOKEN,
   						   p_token1_value  => l_token1_value,
   						   p_token2		   => G_CHILD_TABLE_TOKEN,
  						   p_token2_value  => l_token2_value);
           l_return_status := G_RET_STS_ERROR;
	END IF;

	x_return_status := l_return_status;
	x_valid := l_valid;

  EXCEPTION
	WHEN OTHERS THEN
		-- store SQL error message on message stack
		OKL_API.SET_MESSAGE(p_app_name	=>	G_APP_NAME,
							p_msg_name	=>	G_UNEXPECTED_ERROR,
							p_token1	=>	G_SQLCODE_TOKEN,
							p_token1_value	=>	SQLCODE,
							p_token2	=>	G_SQLERRM_TOKEN,
							p_token2_value	=>	SQLERRM);
	   x_valid := FALSE;
	   x_return_status := G_RET_STS_UNEXP_ERROR;
       IF (okl_pit_constraints_csr%ISOPEN) THEN
	   	  CLOSE okl_pit_constraints_csr;
       END IF;

  END check_constraints;


  ---------------------------------------------------------------------------
  -- PROCEDURE check_updates
  -- To verify whether the requested changes from the screen are valid or not
  ---------------------------------------------------------------------------
  PROCEDURE check_updates (
	p_pitv_rec					   IN pitv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2
  ) IS
  l_pitv_rec	  pitv_rec_type;
  l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_valid		  BOOLEAN;
  l_attrib_tbl	okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
    l_return_status := G_RET_STS_SUCCESS;
    l_pitv_rec := p_pitv_rec;

	  /* call check_overlaps */
	l_attrib_tbl(1).attribute	:= 'pdt_id';
	l_attrib_tbl(1).attrib_type	:= okl_accounting_util.G_NUMBER;
	l_attrib_tbl(1).value	:= l_pitv_rec.pdt_id;

	  okl_accounting_util.check_overlaps(p_id	   	 					=> l_pitv_rec.id,
				     p_attrib_tbl					=> l_attrib_tbl,
				     p_start_date_attribute_name	=> 'START_DATE',
							     p_start_date 					=> l_pitv_rec.start_date,
				     p_end_date_attribute_name		=> 'END_DATE',
							     p_end_date						=> l_pitv_rec.end_date,
							     p_view							=> 'OKL_PRD_PRICE_TMPLS_V',
							     x_return_status				=> l_return_status,
							     x_valid						=> l_valid);
	  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
		 x_return_status    := G_RET_STS_UNEXP_ERROR;
		 RAISE G_EXCEPTION_HALT_PROCESSING;
	  ELSIF (l_return_status = G_RET_STS_ERROR) OR
			    (l_return_status = G_RET_STS_SUCCESS AND
			     l_valid <> TRUE) THEN
		 x_return_status    := G_RET_STS_ERROR;
		 RAISE G_EXCEPTION_HALT_PROCESSING;
	  END IF;

	 check_constraints (p_pitv_rec		=> l_pitv_rec,
			      x_return_status	=> l_return_status,
		     x_valid						=> l_valid);

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
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
	        -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END check_updates;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_prd_price_tmpls for: OKL_PRD_PRICE_TMPLS_V
  ---------------------------------------------------------------------------
  PROCEDURE insert_prd_price_tmpls(	p_api_version                  IN  NUMBER,
	                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 	                       	x_return_status                OUT NOCOPY VARCHAR2,
 	 	                      	x_msg_count                    OUT NOCOPY NUMBER,
  	 	                     	x_msg_data                     OUT NOCOPY VARCHAR2,
   	 	                    	p_pitv_rec                     IN  pitv_rec_type,
      		                  	x_pitv_rec                     OUT NOCOPY pitv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'insert_prd_price_tmpls';
    l_valid           BOOLEAN := TRUE;
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
    l_pitv_rec        pitv_rec_type;
    --25-Oct-2004 vthiruva. Fix for Bug#3944026
    --Changed to_date() to trunc() for date comparisions.
    l_sysdate         DATE := TRUNC(SYSDATE);
  BEGIN
    l_return_status := G_RET_STS_SUCCESS;
	l_pitv_rec := p_pitv_rec;

	--  mvasudev -- 02/17/2002
	-- Store NAME in UPPER CASE always
	l_pitv_rec.TEMPLATE_NAME := UPPER(l_pitv_rec.TEMPLATE_NAME);
	-- end, mvasudev -- 02/17/2002

	--  mvasudev -- 06/13/2002
     /*
     -- mvasudev COMMENTED , 06/13/2002
     --check for the records with start and end dates less than sysdate
       IF TO_DATE(l_pitv_rec.start_date, 'DD/MM/YYYY') < l_sysdate OR
	   TO_DATE(l_pitv_rec.end_date, 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE G_EXCEPTION_ERROR;
	END IF;
     */


	/* Check if dates are consistent with Product Dates */
    check_constraints (
	    p_pitv_rec		=> l_pitv_rec,
		x_return_status	=> l_return_status,
	    x_valid			=> l_valid);

   	  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
   		 x_return_status    := G_RET_STS_UNEXP_ERROR;
  	  	 RAISE G_EXCEPTION_ERROR;
   	  ELSIF (l_return_status = G_RET_STS_ERROR) OR
		  	    (l_return_status = G_RET_STS_SUCCESS AND
		   	     l_valid <> TRUE) THEN
   		 x_return_status    := G_RET_STS_ERROR;
  	  	 RAISE G_EXCEPTION_ERROR;
   	  END IF;

	/* public api to insert pricing template*/
       okl_prd_price_tmpls_pub.insert_prd_price_tmpls(p_api_version   => p_api_version,
                              		 p_init_msg_list => p_init_msg_list,
                              		 x_return_status => l_return_status,
                              		 x_msg_count     => x_msg_count,
                              		 x_msg_data      => x_msg_data,
                              		 p_pitv_rec      => l_pitv_rec,
                              		 x_pitv_rec      => x_pitv_rec);

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
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END insert_prd_price_tmpls;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_prd_price_tmpls for: OKL_PRD_PRICE_TMPLS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_prd_price_tmpls(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	p_pitv_rec                     IN  pitv_rec_type,
                        	x_pitv_rec                     OUT NOCOPY pitv_rec_type
                        )
   IS
    CURSOR l_okl_pitv_pk_csr (p_id IN NUMBER) IS
    SELECT
			START_DATE,
			END_DATE
      FROM OKL_PRD_PRICE_TMPLS
     WHERE OKL_PRD_PRICE_TMPLS.id   = p_id;

    l_api_version               CONSTANT NUMBER := 1;
    l_api_name                  CONSTANT VARCHAR2(30)  := 'update_stream_type';
    l_no_data_found             BOOLEAN := TRUE;
    l_valid                     BOOLEAN := TRUE;
    --25-Oct-2004 vthiruva. Fix for Bug#3944026
    --Changed to_date() to trunc() for date comparisions.
    l_oldversion_enddate        DATE := TRUNC(SYSDATE);
    l_sysdate                   DATE := TRUNC(SYSDATE);
    l_db_pitv_rec               pitv_rec_type; /* database copy */
    l_upd_pitv_rec              pitv_rec_type; /* input copy */
    l_pitv_rec                  pitv_rec_type; /* latest with the retained changes */
    l_tmp_pitv_rec              pitv_rec_type; /* for any other purposes */
    l_return_status             VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_action                    VARCHAR2(1);
    l_new_version               VARCHAR2(100);
    l_attrib_tbl                okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
    l_return_status := G_RET_STS_SUCCESS;

    l_pitv_rec := p_pitv_rec;

	-- END_DATE needs to be after START_DATE (sanity check)
	-- and Cannot be less than SysDate
	/*
	** 25-Oct-2004 vthiruva -- Fix for Bug#3944026 start
	** Changed to_date() to trunc() for date comparisions.
	*/
	IF  l_pitv_rec.end_date IS NOT NULL
	AND l_pitv_rec.end_date <> G_MISS_DATE
	AND
	   (TRUNC(l_pitv_rec.end_date) < TRUNC(l_pitv_rec.start_date)
	    OR TRUNC(l_pitv_rec.end_date) < l_sysdate
	   )
	THEN
	/*
	** 25-Oct-2004 vthiruva -- Fix for Bug#3944026 end
	*/
	      OKC_API.SET_MESSAGE( p_app_name   => OKC_API.G_APP_NAME,
                           p_msg_name       => G_INVALID_VALUE,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'END_DATE' );
	   RAISE G_EXCEPTION_ERROR;
	END IF;

    -- Get current database values
    OPEN l_okl_pitv_pk_csr (p_pitv_rec.id);
    FETCH l_okl_pitv_pk_csr INTO
		l_db_pitv_rec.START_DATE,
		l_db_pitv_rec.END_DATE;
    l_no_data_found := l_okl_pitv_pk_csr%NOTFOUND;
    CLOSE l_okl_pitv_pk_csr;

	IF l_no_data_found THEN
	   RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;


        -- start date can not be greater than old start date if the record is active
	/*
	** 25-Oct-2004 vthiruva -- Fix for Bug#3944026 start
	** Changed to_date() to trunc() for date comparisions.
	*/
        IF  TRUNC(l_db_pitv_rec.start_date) < l_sysdate
        AND TRUNC(l_pitv_rec.start_date) > TRUNC(l_db_pitv_rec.start_date)
	THEN
	/*
	** 25-Oct-2004 vthiruva -- Fix for Bug#3944026 end
	*/
	      OKC_API.SET_MESSAGE( p_app_name   => OKC_API.G_APP_NAME,
                           p_msg_name       => G_INVALID_VALUE,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'START_DATE' );
	   RAISE G_EXCEPTION_ERROR;
        END IF;

	/* Check if dates are consistent with Product Dates */
       check_constraints (
	    p_pitv_rec		=> l_pitv_rec,
		x_return_status	=> l_return_status,
	    x_valid			=> l_valid);

   	  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
   		 x_return_status    := G_RET_STS_UNEXP_ERROR;
  	  	 RAISE G_EXCEPTION_ERROR;
   	  ELSIF (l_return_status = G_RET_STS_ERROR) OR
		  	    (l_return_status = G_RET_STS_SUCCESS AND
		   	     l_valid <> TRUE) THEN
   		 x_return_status    := G_RET_STS_ERROR;
  	  	 RAISE G_EXCEPTION_ERROR;
   	  END IF;


	-- public api to update_prd_price_tmpls
       okl_prd_price_tmpls_pub.update_prd_price_tmpls(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_pitv_rec      => l_pitv_rec,
                              		 	x_pitv_rec      => x_pitv_rec);
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
	IF  l_pitv_rec.end_date IS NOT NULL
	AND  TO_DATE(l_pitv_rec.end_date, 'DD/MM/YYYY') <> TO_DATE(G_MISS_DATE, 'DD/MM/YYYY')
	AND TO_DATE(l_pitv_rec.end_date, 'DD/MM/YYYY') < TO_DATE(l_pitv_rec.start_date, 'DD/MM/YYYY')
	THEN
	      OKC_API.SET_MESSAGE( p_app_name   => OKC_API.G_APP_NAME,
                           p_msg_name       => G_INVALID_VALUE,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'END_DATE' );
	END IF;
	-- end, mvasudev -- 02/17/2002

	 -- fetch old details from the database
    get_rec(p_pitv_rec 	 	=> p_pitv_rec,
		    x_return_status => l_return_status,
			x_no_data_found => l_no_data_found,
    		x_pitv_rec		=> l_db_pitv_rec);
	IF l_return_status <> G_RET_STS_SUCCESS OR
	   l_no_data_found = TRUE THEN
	   RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	-- check for the records if start and end dates are in the past
    IF TO_DATE(l_db_pitv_rec.start_date,'DD/MM/YYYY') < l_sysdate AND
	   TO_DATE(l_db_pitv_rec.end_date,'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE G_EXCEPTION_ERROR;
	END IF;

	-- retain the details that has been changed only
    get_changes_only(p_pitv_rec 	 	=> p_pitv_rec,
   			p_db_rec  => l_db_pitv_rec,
    		x_pitv_rec		=> l_upd_pitv_rec);
	IF l_return_status <> G_RET_STS_SUCCESS OR
	   l_no_data_found = TRUE THEN
	   RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	-- mvasudev, 02/17/2002
	-- check for start date greater than sysdate
	IF to_date(l_upd_pitv_rec.start_date, 'DD/MM/YYYY') <> to_date(G_MISS_DATE, 'DD/MM/YYYY') AND
	   to_date(l_upd_pitv_rec.start_date,'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
	   RAISE G_EXCEPTION_ERROR;
        END IF;

	 -- check for end date greater than sysdate
	IF to_date(l_upd_pitv_rec.end_date, 'DD/MM/YYYY') <> to_date(G_MISS_DATE, 'DD/MM/YYYY') AND
	   to_date(l_upd_pitv_rec.end_date,'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_END_DATE);
	   RAISE G_EXCEPTION_ERROR;
        END IF;


	-- START_DATE , if changed, can only be later than TODAY
	IF TO_DATE(l_upd_pitv_rec.start_date, 'DD/MM/YYYY') <> TO_DATE(G_MISS_DATE, 'DD/MM/YYYY') AND
	   TO_DATE(l_upd_pitv_rec.start_date,'DD/MM/YYYY') <= l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
	   RAISE G_EXCEPTION_ERROR;
        END IF;

	-- END_DATE, if changed, cannot be earlier than TODAY
       IF TO_DATE(l_upd_pitv_rec.end_date, 'DD/MM/YYYY') <> TO_DATE(G_MISS_DATE, 'DD/MM/YYYY') AND
          TO_DATE(l_upd_pitv_rec.end_date,'DD/MM/YYYY') < l_sysdate THEN
         OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
					   p_msg_name		=> G_END_DATE);
         RAISE G_EXCEPTION_ERROR;
      END IF;

	-- end, mvasudev -- 02/17/2002

	-- determine how the processing to be done
	l_action := determine_action(p_upd_pitv_rec	 => l_upd_pitv_rec,
			 					 p_db_pitv_rec	 => l_db_pitv_rec,
								 p_date			 => l_sysdate);

        -- Scenario 1: The Changed Field-Values can by-pass Validation *
	IF l_action = '1' THEN
	   -- public api to update_stream_type *
       okl_prd_price_tmpls_pub.update_prd_price_tmpls(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_pitv_rec      => l_upd_pitv_rec,
                              		 	x_pitv_rec      => x_pitv_rec);
       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	-- Scenario 2: The Changed Field-Values include that needs Validation and Update	*
	ELSIF l_action = '2' THEN

	   check_updates(p_pitv_rec		=> l_pitv_rec,
			 x_return_status => l_return_status,
			 x_msg_data		=> x_msg_data);

       IF l_return_status = G_RET_STS_ERROR THEN
       	  RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   -- public api to update Pricing Template *
       okl_prd_price_tmpls_pub.update_prd_price_tmpls(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_pitv_rec      => l_upd_pitv_rec,
                              		 	x_pitv_rec      => x_pitv_rec);

       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	-- Scenario 3: The Changed Field-Values mandate Creation of a New Version/Record
	ELSIF l_action = '3' THEN

	   -- mvasudev -- 02/17/2002
	   -- DO NOT Update Old-record if new Start_Date is after Old End_Date
	   IF  l_upd_pitv_rec.start_date <> G_MISS_DATE
	   AND l_db_pitv_rec.end_date IS NOT NULL
           AND l_upd_pitv_rec.start_date >  l_db_pitv_rec.end_date
	   THEN
	     NULL;
	   ELSE
		   -- for old version
		   IF l_upd_pitv_rec.start_date <> G_MISS_DATE THEN
			  l_oldversion_enddate := l_upd_pitv_rec.start_date - 1;
		   ELSE
		      --mvasudev , 02/17/2002
			  -- The earliest end_date, if changed , can be TODAY.

		   	  --l_oldversion_enddate := l_sysdate - 1;
			  l_oldversion_enddate := l_sysdate;

			  -- end, mvasudev -- 02/17/2002
		   END IF;

		   l_pitv_rec := l_db_pitv_rec;
		   l_pitv_rec.end_date := l_oldversion_enddate;

		   -- call verify changes to update the database *
		   IF l_oldversion_enddate > l_db_pitv_rec.end_date THEN


			  check_updates(p_pitv_rec		=> l_pitv_rec,
							x_return_status => l_return_status,
							x_msg_data		=> x_msg_data);

		  IF l_return_status = G_RET_STS_ERROR THEN
			 RAISE G_EXCEPTION_ERROR;
		  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
			 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
		  END IF;
		   END IF;

		   -- public api to update formulae
	       okl_prd_price_tmpls_pub.update_prd_price_tmpls(p_api_version   => p_api_version,
							p_init_msg_list => p_init_msg_list,
							x_return_status => l_return_status,
							x_msg_count     => x_msg_count,
							x_msg_data      => x_msg_data,
							p_pitv_rec      => l_pitv_rec,
							x_pitv_rec      => x_pitv_rec);

	       IF l_return_status = G_RET_STS_ERROR THEN
		  RAISE G_EXCEPTION_ERROR;
	       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
		  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	       END IF;
	   END IF;
	   -- end,mvasudev -- 02/17/2002

	   -- for new version
	   -- mvasudev , 02/17/2002
	   -- The earliest START_DATE, when Update,  can be TOMORROW only
	   IF l_upd_pitv_rec.start_date = G_MISS_DATE THEN
	   	  --l_pitv_rec.start_date := l_sysdate ;
		  l_pitv_rec.start_date := l_sysdate + 1 ;
	   END IF;

		l_attrib_tbl(1).attribute := 'PDT_ID';
		l_attrib_tbl(1).attrib_type := okl_accounting_util.G_NUMBER;
		l_attrib_tbl(1).value := l_pitv_rec.pdt_id;

    	okl_accounting_util.get_version(
								        p_attrib_tbl				=> l_attrib_tbl,
    							      	p_cur_version				=> l_pitv_rec.version,
                                    	p_end_date_attribute_name	=> 'END_DATE',
                                    	p_end_date					=> l_pitv_rec.end_date,
                                    	p_view						=> 'OKL_PRD_PRICE_TMPLS_V',
  				                       x_return_status				=> l_return_status,
				                       x_new_version				=> l_new_version);

       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSE
	   	  l_pitv_rec.version := l_new_version;
       END IF;

	   l_pitv_rec.id := G_MISS_NUM;

	   -- call verify changes to update the database
	   IF l_pitv_rec.end_date > l_db_pitv_rec.end_date THEN
	   	  check_updates(p_pitv_rec		=> l_pitv_rec,
	   	                x_return_status => l_return_status,
				x_msg_data		=> x_msg_data);

       	  IF l_return_status = G_RET_STS_ERROR THEN
          	 RAISE G_EXCEPTION_ERROR;
       	  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  	 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
	   END IF;

	   -- public api to insert stream type
		okl_prd_price_tmpls_pub.insert_prd_price_tmpls(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_pitv_rec      => l_pitv_rec,
                              		 	x_pitv_rec      => x_pitv_rec);

       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   -- copy output to input structure to get the id
	   l_pitv_rec := x_pitv_rec;

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
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END update_prd_price_tmpls;

  PROCEDURE insert_prd_price_tmpls(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_pitv_tbl                     IN  pitv_tbl_type,
         x_pitv_tbl                     OUT NOCOPY pitv_tbl_type)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'insert_prd_price_tmpls_tbl';
	rec_num		INTEGER	:= 0;
   BEGIN

   	FOR rec_num IN 1..p_pitv_tbl.COUNT
	LOOP
		insert_prd_price_tmpls(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_pitv_rec                     => p_pitv_tbl(rec_num),
         x_pitv_rec                     => x_pitv_tbl(rec_num) );
	    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
	      RAISE G_EXCEPTION_ERROR;
	    END IF;
	END LOOP;

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
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
	        -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END insert_prd_price_tmpls;


  PROCEDURE update_prd_price_tmpls(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_pitv_tbl                     IN  pitv_tbl_type,
         x_pitv_tbl                     OUT NOCOPY pitv_tbl_type)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_prd_price_tmpls_tbl';
	rec_num		INTEGER	:= 0;
   BEGIN
   	FOR rec_num IN 1..p_pitv_tbl.COUNT
	LOOP
		update_prd_price_tmpls(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_pitv_rec                     => p_pitv_tbl(rec_num),
         x_pitv_rec                     => x_pitv_tbl(rec_num) );
	    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
	      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
	      RAISE G_EXCEPTION_ERROR;
	    END IF;
	END LOOP;
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
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_prd_price_tmpls;

 PROCEDURE check_product_constraints(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
      	p_pdtv_rec			IN  pdtv_rec_type,
        x_validated			   OUT NOCOPY VARCHAR2)
  IS
    CURSOR okl_pit_pdt_csr (p_pdt_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            PDT_ID,
            TEMPLATE_NAME,
            TEMPLATE_PATH,
			VERSION,
            START_DATE,
			NVL(END_DATE,G_MISS_DATE) END_DATE,
			NVL(DESCRIPTION,G_MISS_CHAR) DESCRIPTION,
			CREATED_BY,
			CREATION_DATE,
   			LAST_UPDATED_BY,
   			LAST_UPDATE_DATE,
			NVL(LAST_UPDATE_LOGIN,G_MISS_NUM) LAST_UPDATE_LOGIN
      FROM OKL_PRD_PRICE_TMPLS
     WHERE OKL_PRD_PRICE_TMPLS.pdt_id = p_pdt_id;

    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'check_product_constraints';
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
	l_valid	BOOLEAN := TRUE;
	l_pitv_rec	pitv_rec_type;
  BEGIN
 	l_return_status := G_RET_STS_SUCCESS;

	FOR l_okl_pit_pdt_csr IN okl_pit_pdt_csr(p_pdtv_rec.id)
	LOOP
		l_pitv_rec.ID	:= l_okl_pit_pdt_csr.id;
		l_pitv_rec.OBJECT_VERSION_NUMBER := l_okl_pit_pdt_csr.OBJECT_VERSION_NUMBER;
		l_pitv_rec.PDT_ID := l_okl_pit_pdt_csr.PDT_ID;
  		l_pitv_rec.TEMPLATE_NAME := l_okl_pit_pdt_csr.TEMPLATE_NAME;
  		l_pitv_rec.TEMPLATE_PATH := l_okl_pit_pdt_csr.TEMPLATE_PATH;
		l_pitv_rec.VERSION := l_okl_pit_pdt_csr.VERSION;
		l_pitv_rec.START_DATE := l_okl_pit_pdt_csr.START_DATE;
		l_pitv_rec.END_DATE := l_okl_pit_pdt_csr.END_DATE;
		l_pitv_rec.DESCRIPTION := l_okl_pit_pdt_csr.DESCRIPTION;
  		l_pitv_rec.CREATED_BY := l_okl_pit_pdt_csr.CREATED_BY;
		l_pitv_rec.CREATION_DATE := l_okl_pit_pdt_csr.CREATION_DATE;
		l_pitv_rec.LAST_UPDATED_BY := l_okl_pit_pdt_csr.LAST_UPDATED_BY;
		l_pitv_rec.LAST_UPDATE_DATE := l_okl_pit_pdt_csr.LAST_UPDATE_DATE;
		l_pitv_rec.LAST_UPDATE_LOGIN := l_okl_pit_pdt_csr.LAST_UPDATE_LOGIN;

		check_constraints (p_pitv_rec	=>  l_pitv_rec,
						   x_return_status	=> l_return_status,
						   x_valid			=> l_valid);
       	  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      	  	 RAISE G_EXCEPTION_ERROR ;
       	  ELSIF (l_return_status = G_RET_STS_ERROR) OR
		  	    (l_return_status = G_RET_STS_SUCCESS AND
		   	     l_valid <> TRUE) THEN
      	  	 RAISE G_EXCEPTION_ERROR ;
       	  END IF;
	END LOOP;

	x_validated := BOOLEAN_TO_CHAR(l_valid);

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_validated := G_FALSE;
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_validated := G_FALSE;
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      x_validated := G_FALSE;
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END check_product_constraints;

 PROCEDURE check_product_constraints(
        p_api_version                  IN  NUMBER,
        p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
      	p_pdtv_tbl					   IN  pdtv_tbl_type,
        x_validated			       OUT NOCOPY VARCHAR2)
  IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'check_product_constraints_tbl';
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
	l_validated VARCHAR2(1) := G_TRUE;
	l_valid	BOOLEAN := TRUE;
	rec_num		INTEGER	:= 0;
  BEGIN
 	l_return_status := G_RET_STS_SUCCESS;

   	FOR rec_num IN 1..p_pdtv_tbl.COUNT
	LOOP
    	check_product_constraints(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => x_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_pdtv_rec					   =>  p_pdtv_tbl(rec_num),
         x_validated						   => l_validated);

         l_valid := FND_API.TO_BOOLEAN(l_validated);
       	  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      	  	 RAISE G_EXCEPTION_ERROR;
       	  ELSIF (l_return_status = G_RET_STS_ERROR) OR
		  	    (l_return_status = G_RET_STS_SUCCESS AND
		   	     l_valid <> TRUE) THEN
      	  	 RAISE G_EXCEPTION_ERROR;
       	  END IF;
	END LOOP;

	x_validated := BOOLEAN_TO_CHAR(l_valid);

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_validated := G_FALSE;
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_validated := G_FALSE;
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      x_validated := G_FALSE;
     x_return_status := G_RET_STS_UNEXP_ERROR;
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );

  END check_product_constraints;

END OKL_SETUP_PRD_PRCTEMPL_PVT;

/
