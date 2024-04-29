--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_STREAMTYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_STREAMTYPES_PVT" AS
/* $Header: OKLRSMTB.pls 120.3 2005/10/30 04:38:06 appldev noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_STRM_TYPE_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_styv_rec              IN styv_rec_type,
	x_return_status			OUT NOCOPY VARCHAR2,
    x_no_data_found         OUT NOCOPY BOOLEAN,
	x_styv_rec				OUT NOCOPY styv_rec_type
  ) IS
    CURSOR okl_styv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
			ID,
			NAME,
			VERSION,
			OBJECT_VERSION_NUMBER,
			CODE,
			SFWT_FLAG,
			STREAM_TYPE_SCOPE,
			DESCRIPTION,
			START_DATE,
			END_DATE,
			BILLABLE_YN,
			TAXABLE_DEFAULT_YN,
			CUSTOMIZATION_LEVEL,
			STREAM_TYPE_CLASS,
			ACCRUAL_YN,
			ALLOCATION_FACTOR,
			ATTRIBUTE_CATEGORY,
			ATTRIBUTE1,
			ATTRIBUTE2,
			ATTRIBUTE3,
			ATTRIBUTE4,
			ATTRIBUTE5,
			ATTRIBUTE6,
			ATTRIBUTE7,
			ATTRIBUTE8,
			ATTRIBUTE9,
			ATTRIBUTE10,
			ATTRIBUTE11,
			ATTRIBUTE12,
			ATTRIBUTE13,
			ATTRIBUTE14,
			ATTRIBUTE15,
			CREATED_BY,
			CREATION_DATE,
   			LAST_UPDATED_BY,
   			LAST_UPDATE_DATE,
			LAST_UPDATE_LOGIN,
-- Added by RGOOTY for ER 3935682: Start
			STREAM_TYPE_PURPOSE,
			CONTINGENCY,
			SHORT_DESCRIPTION
-- Added by RGOOTY for ER 3935682: End
      FROM OKL_STRM_TYPE_V
     WHERE OKL_STRM_TYPE_V.id   = p_id;

    l_okl_styv_pk                  okl_styv_pk_csr%ROWTYPE;
    l_styv_rec                     styv_rec_type;
  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_styv_pk_csr (p_styv_rec.id);
    FETCH okl_styv_pk_csr INTO
            l_styv_rec.ID,
            l_styv_rec.NAME,
			l_styv_rec.VERSION,
            l_styv_rec.OBJECT_VERSION_NUMBER,
			l_styv_rec.CODE,
            l_styv_rec.SFWT_FLAG,
			l_styv_rec.STREAM_TYPE_SCOPE,
			l_styv_rec.DESCRIPTION,
			l_styv_rec.START_DATE,
			l_styv_rec.END_DATE,
			l_styv_rec.BILLABLE_YN,
			l_styv_rec.TAXABLE_DEFAULT_YN,
			l_styv_rec.CUSTOMIZATION_LEVEL,
			l_styv_rec.STREAM_TYPE_CLASS,
			l_styv_rec.ACCRUAL_YN,
			l_styv_rec.ALLOCATION_FACTOR,
			l_styv_rec.ATTRIBUTE_CATEGORY,
			l_styv_rec.ATTRIBUTE1,
			l_styv_rec.ATTRIBUTE2,
			l_styv_rec.ATTRIBUTE3,
			l_styv_rec.ATTRIBUTE4,
			l_styv_rec.ATTRIBUTE5,
			l_styv_rec.ATTRIBUTE6,
			l_styv_rec.ATTRIBUTE7,
			l_styv_rec.ATTRIBUTE8,
			l_styv_rec.ATTRIBUTE9,
			l_styv_rec.ATTRIBUTE10,
			l_styv_rec.ATTRIBUTE11,
			l_styv_rec.ATTRIBUTE12,
			l_styv_rec.ATTRIBUTE13,
			l_styv_rec.ATTRIBUTE14,
			l_styv_rec.ATTRIBUTE15,
            l_styv_rec.CREATED_BY,
           l_styv_rec.CREATION_DATE,
           l_styv_rec.LAST_UPDATED_BY,
           l_styv_rec.LAST_UPDATE_DATE,
           l_styv_rec.LAST_UPDATE_LOGIN,
-- Added by RGOOTY for ER 3935682: Start
           l_styv_rec.stream_type_purpose,
	   l_styv_rec.contingency,
	   l_styv_rec.short_description;
-- Added by RGOOTY for ER 3935682: End
    x_no_data_found := okl_styv_pk_csr%NOTFOUND;
    CLOSE okl_styv_pk_csr;

    x_styv_rec := l_styv_rec;

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

      IF (okl_styv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_styv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_changes_only
  -- To take care of the assumption that Everything
  -- except the Changed Fields have G_MISS values in them
  ---------------------------------------------------------------------------
PROCEDURE get_changes_only (
    p_styv_rec              IN styv_rec_type,
	p_db_rec   		IN styv_rec_type,
	x_styv_rec				OUT NOCOPY styv_rec_type  )
IS
   l_styv_rec styv_rec_type;
BEGIN
  	l_styv_rec := p_styv_rec;

    	IF p_db_rec.NAME = p_styv_rec.NAME THEN
    		l_styv_rec.NAME := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.CODE = p_styv_rec.CODE THEN
    		l_styv_rec.CODE := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.VERSION = p_styv_rec.VERSION THEN
    		l_styv_rec.VERSION := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.STREAM_TYPE_SCOPE = p_styv_rec.STREAM_TYPE_SCOPE THEN
    		l_styv_rec.STREAM_TYPE_SCOPE := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.START_DATE = p_styv_rec.START_DATE THEN
    		l_styv_rec.START_DATE := G_MISS_DATE;
    	END IF;

    	IF p_db_rec.BILLABLE_YN = p_styv_rec.BILLABLE_YN THEN
    		l_styv_rec.BILLABLE_YN := G_MISS_CHAR;
    	END IF;
    	IF p_db_rec.TAXABLE_DEFAULT_YN = p_styv_rec.TAXABLE_DEFAULT_YN THEN
    		l_styv_rec.TAXABLE_DEFAULT_YN := G_MISS_CHAR;
    	END IF;
    	IF p_db_rec.CUSTOMIZATION_LEVEL = p_styv_rec.CUSTOMIZATION_LEVEL THEN
    		l_styv_rec.CUSTOMIZATION_LEVEL := G_MISS_CHAR;
    	END IF;
    	IF p_db_rec.STREAM_TYPE_CLASS = p_styv_rec.STREAM_TYPE_CLASS THEN
    		l_styv_rec.STREAM_TYPE_CLASS := G_MISS_CHAR;
    	END IF;
    	IF p_db_rec.ACCRUAL_YN = p_styv_rec.ACCRUAL_YN THEN
    		l_styv_rec.ACCRUAL_YN := G_MISS_CHAR;
    	END IF;

      	IF p_db_rec.END_DATE IS NULL
      	THEN
      		 IF p_styv_rec.END_DATE IS NULL
      		 THEN
      			l_styv_rec.END_DATE := G_MISS_DATE;
      		END IF;
      	ELSIF p_db_rec.END_DATE = p_styv_rec.END_DATE
      	THEN
      		l_styv_rec.END_DATE := G_MISS_DATE;
      	END IF;

	IF p_db_rec.DESCRIPTION IS NULL
	THEN
		 IF p_styv_rec.DESCRIPTION IS NULL
		 THEN
			l_styv_rec.DESCRIPTION := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.DESCRIPTION = p_styv_rec.DESCRIPTION
	THEN
		l_styv_rec.DESCRIPTION := G_MISS_CHAR;
	END IF;

	IF p_db_rec.FUNDABLE_YN IS NULL
	THEN
		 IF p_styv_rec.FUNDABLE_YN IS NULL
		 THEN
			l_styv_rec.FUNDABLE_YN := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.FUNDABLE_YN = p_styv_rec.FUNDABLE_YN
	THEN
		l_styv_rec.FUNDABLE_YN := G_MISS_CHAR;
	END IF;

	IF p_db_rec.PERIODIC_YN IS NULL
	THEN
		 IF p_styv_rec.PERIODIC_YN IS NULL
		 THEN
			l_styv_rec.PERIODIC_YN := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.PERIODIC_YN = p_styv_rec.PERIODIC_YN
	THEN
		l_styv_rec.PERIODIC_YN := G_MISS_CHAR;
	END IF;

	IF p_db_rec.CAPITALIZE_YN IS NULL
	THEN
		 IF p_styv_rec.CAPITALIZE_YN IS NULL
		 THEN
			l_styv_rec.CAPITALIZE_YN := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.CAPITALIZE_YN = p_styv_rec.CAPITALIZE_YN
	THEN
		l_styv_rec.CAPITALIZE_YN := G_MISS_CHAR;
	END IF;

        IF p_db_rec.ALLOCATION_FACTOR IS NULL
	THEN
		 IF p_styv_rec.ALLOCATION_FACTOR IS NULL
		 THEN
			l_styv_rec.ALLOCATION_FACTOR := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ALLOCATION_FACTOR = p_styv_rec.ALLOCATION_FACTOR
	THEN
		l_styv_rec.ALLOCATION_FACTOR := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE_CATEGORY IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE_CATEGORY IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE_CATEGORY := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE_CATEGORY = p_styv_rec.ATTRIBUTE_CATEGORY
	THEN
		l_styv_rec.ATTRIBUTE_CATEGORY := G_MISS_CHAR;
	END IF;

        IF p_db_rec.ATTRIBUTE1 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE1 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE1 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE1 = p_styv_rec.ATTRIBUTE1
	THEN
		l_styv_rec.ATTRIBUTE1 := G_MISS_CHAR;
	END IF;


	IF p_db_rec.ATTRIBUTE2 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE2 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE2 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE2 = p_styv_rec.ATTRIBUTE2
	THEN
		l_styv_rec.ATTRIBUTE2 := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE3 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE3 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE3 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE3 = p_styv_rec.ATTRIBUTE3
	THEN
		l_styv_rec.ATTRIBUTE3 := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE4 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE4 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE4 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE4 = p_styv_rec.ATTRIBUTE4
	THEN
		l_styv_rec.ATTRIBUTE4 := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE5 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE5 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE5 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE5 = p_styv_rec.ATTRIBUTE5
	THEN
		l_styv_rec.ATTRIBUTE5 := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE6 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE6 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE6 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE6 = p_styv_rec.ATTRIBUTE6
	THEN
		l_styv_rec.ATTRIBUTE6 := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE7 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE7 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE7 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE7 = p_styv_rec.ATTRIBUTE7
	THEN
		l_styv_rec.ATTRIBUTE7 := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE8 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE8 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE8 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE8 = p_styv_rec.ATTRIBUTE8
	THEN
		l_styv_rec.ATTRIBUTE8 := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE9 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE9 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE9 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE9 = p_styv_rec.ATTRIBUTE9
	THEN
		l_styv_rec.ATTRIBUTE9 := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE10 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE10 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE10 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE10 = p_styv_rec.ATTRIBUTE10
	THEN
		l_styv_rec.ATTRIBUTE10 := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE11 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE11 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE11 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE11 = p_styv_rec.ATTRIBUTE11
	THEN
		l_styv_rec.ATTRIBUTE11 := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE12 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE12 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE12 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE12 = p_styv_rec.ATTRIBUTE12
	THEN
		l_styv_rec.ATTRIBUTE12 := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE13 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE13 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE13 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE13 = p_styv_rec.ATTRIBUTE13
	THEN
		l_styv_rec.ATTRIBUTE13 := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE14 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE14 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE14 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE14 = p_styv_rec.ATTRIBUTE14
	THEN
		l_styv_rec.ATTRIBUTE14 := G_MISS_CHAR;
	END IF;

	IF p_db_rec.ATTRIBUTE15 IS NULL
	THEN
		 IF p_styv_rec.ATTRIBUTE15 IS NULL
		 THEN
			l_styv_rec.ATTRIBUTE15 := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.ATTRIBUTE15 = p_styv_rec.ATTRIBUTE15
	THEN
		l_styv_rec.ATTRIBUTE15 := G_MISS_CHAR;
	END IF;
-- Added by RGOOTY for ER 3935682: Start
	IF p_db_rec.stream_type_purpose IS NULL
	THEN
		 IF p_styv_rec.stream_type_purpose IS NULL
		 THEN
			l_styv_rec.stream_type_purpose := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.stream_type_purpose = p_styv_rec.stream_type_purpose
	THEN
		l_styv_rec.stream_type_purpose := G_MISS_CHAR;
	END IF;

	IF p_db_rec.contingency IS NULL
	THEN
		 IF p_styv_rec.contingency IS NULL
		 THEN
			l_styv_rec.contingency := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.contingency = p_styv_rec.contingency
	THEN
		l_styv_rec.contingency := G_MISS_CHAR;
	END IF;

	IF p_db_rec.short_description IS NULL
	THEN
		 IF p_styv_rec.short_description IS NULL
		 THEN
			l_styv_rec.short_description := G_MISS_CHAR;
		END IF;
	ELSIF p_db_rec.short_description = p_styv_rec.short_description
	THEN
		l_styv_rec.contingency := G_MISS_CHAR;
	END IF;
-- Added by RGOOTY for ER 3935682: End
	x_styv_rec := l_styv_rec;

END get_changes_only;

  ---------------------------------------------------------------------------
  -- PROCEDURE determine_action for: OKL_STRM_TYPE_V
  -- This function helps in determining the various checks to be performed
  -- for the new/updated record and also helps in determining whether a new
  -- version is required or not
  ---------------------------------------------------------------------------
  FUNCTION determine_action (
    p_upd_styv_rec                 IN styv_rec_type,
	p_db_styv_rec				   IN styv_rec_type,
	p_date						   IN DATE
  ) RETURN VARCHAR2 IS
  l_action VARCHAR2(1);
  l_sysdate DATE := TRUNC(SYSDATE);
BEGIN

  -- Scenario 1: The Changed Field-Values can by-pass Validation
  IF p_upd_styv_rec.start_date = G_MISS_DATE AND
	 p_upd_styv_rec.end_date = G_MISS_DATE AND
	 p_upd_styv_rec.stream_type_scope = G_MISS_CHAR AND
	 p_upd_styv_rec.taxable_default_yn = G_MISS_CHAR AND
	 p_upd_styv_rec.stream_type_class = G_MISS_CHAR AND
	 p_upd_styv_rec.accrual_yn = G_MISS_CHAR AND
	 p_upd_styv_rec.capitalize_yn = G_MISS_CHAR AND
	 p_upd_styv_rec.periodic_yn = G_MISS_CHAR AND
	 p_upd_styv_rec.fundable_yn = G_MISS_CHAR AND
	 p_upd_styv_rec.allocation_factor = G_MISS_CHAR THEN
	 l_action := '1';
	-- Scenario 2: The Changed Field-Values include that needs Validation and Update

	--	1) End_Date is Changed
  ELSIF (p_upd_styv_rec.start_date = G_MISS_DATE AND
	    (p_upd_styv_rec.end_date <> G_MISS_DATE OR
		--  IS NULL Condition has been added in case end_date was updated to NULL
	      p_upd_styv_rec.end_date IS NULL ) AND
    	 p_upd_styv_rec.stream_type_scope = G_MISS_CHAR AND
    	 p_upd_styv_rec.taxable_default_yn = G_MISS_CHAR AND
    	 p_upd_styv_rec.stream_type_class = G_MISS_CHAR AND
    	 p_upd_styv_rec.accrual_yn = G_MISS_CHAR AND
         p_upd_styv_rec.capitalize_yn = G_MISS_CHAR AND
         p_upd_styv_rec.periodic_yn = G_MISS_CHAR AND
         p_upd_styv_rec.fundable_yn = G_MISS_CHAR AND
         p_upd_styv_rec.allocation_factor = G_MISS_CHAR) OR
	--	2)	Critical Attributes are Changed but does not mandate new version
	--		as Start_Date is in Future and Not Changied
	    (p_upd_styv_rec.start_date = G_MISS_DATE AND
	     p_db_styv_rec.start_date >= p_date AND
	     (p_upd_styv_rec.stream_type_scope <> G_MISS_CHAR OR
    	 p_upd_styv_rec.taxable_default_yn <> G_MISS_CHAR OR
    	 p_upd_styv_rec.stream_type_class <> G_MISS_CHAR OR
		 -- mvasudev, 02/25/2002
		--  IS NULL Condition has been added in case these attributes were updated to NULL
         (p_upd_styv_rec.capitalize_yn <> G_MISS_CHAR OR p_upd_styv_rec.capitalize_yn IS NULL ) OR
         (p_upd_styv_rec.periodic_yn <> G_MISS_CHAR OR p_upd_styv_rec.periodic_yn IS NULL ) OR
         (p_upd_styv_rec.fundable_yn <> G_MISS_CHAR OR p_upd_styv_rec.fundable_yn IS NULL ) OR
         (p_upd_styv_rec.allocation_factor <> G_MISS_CHAR OR p_upd_styv_rec.allocation_factor IS NULL ) OR
		 -- end,mvasudev, 02/25/2002
    	 p_upd_styv_rec.accrual_yn <> G_MISS_CHAR)) OR
	--	3)	Start_Date is Shifted , but in Future
	  (p_upd_styv_rec.start_date <> G_MISS_DATE AND
	   p_db_styv_rec.start_date > p_date)
	  -- Commented out to disregard multiple versions in Future , 04/11/2002
	  --AND p_upd_styv_rec.start_date < p_db_styv_rec.start_date)
	  THEN
	  l_action := '2';

  ELSE
	-- Scenario 3: The Changed Field-Values mandate Creation of a New Version/Record
     l_action := '3';
  END IF;


  RETURN(l_action);
  END determine_action;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_updates
  -- To verify whether the requested changes from the screen are valid or not
  ---------------------------------------------------------------------------
  PROCEDURE check_updates (
	p_styv_rec					   IN styv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2
  ) IS

  /* Commented till final decision made regarding Versioning
  	-- 04/11/2002
  -- Cursor to fetch streams that would be impacted by stream-type update
  CURSOR l_okl_stm_csr(p_sty_id NUMBER,p_sysdate DATE)
  IS
  SELECT '1' FROM dual
  WHERE EXISTS
         (SELECT '1'
          FROM OKL_STRM_TYPE_TL STYL,
               OKL_STREAMS STMB,
               OKL_STRM_ELEMENTS SELB
          WHERE STMB.STY_ID = STYL.ID
          AND   STMB.SAY_CODE = 'CURR'
          AND   SELB.STM_ID = STMB.ID
          AND   SELB.STREAM_ELEMENT_DATE > p_sysdate
         );

  -- Cursor to fetch accounting_templates that would be impacted by stream-type update
  CURSOR l_okl_avl_csr(p_sty_id NUMBER,p_sysdate DATE)
  IS
  SELECT '1' FROM dual
  WHERE EXISTS
        (SELECT '1'
         FROM OKL_AE_TEMPLATES_V
         WHERE sty_id = p_sty_id
         AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE, p_sysdate)
        );
	-- 04/11/2002
  */

  l_styv_rec	  styv_rec_type;
  l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_valid		  BOOLEAN;
  l_attrib_tbl	okl_accounting_util.overlap_attrib_tbl_type;
  l_sysdate DATE := TRUNC(SYSDATE);

  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
	l_styv_rec := p_styv_rec;

		  /* call check_overlaps */
	l_attrib_tbl(1).attribute := 'CODE';
	l_attrib_tbl(1).attrib_type	:= okl_accounting_util.G_VARCHAR2;
	l_attrib_tbl(1).value	:= l_styv_rec.code;

	okl_accounting_util.check_overlaps(  p_id => l_styv_rec.id,
					     p_attrib_tbl => l_attrib_tbl,
					     p_start_date_attribute_name => 'START_DATE',
					     p_start_date => l_styv_rec.start_date,
					     p_end_date_attribute_name	=> 'END_DATE',
					     p_end_date	=> l_styv_rec.end_date,
					     p_view => 'Okl_Strm_Type_V',
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

	/* Check dependencies
	-- 04/11/2002
	-- Streams
	FOR l_okl_stm_rec IN l_okl_stm_csr(l_styv_rec.id, l_sysdate)
	LOOP
	   x_return_status    := G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
	END LOOP;

	-- Accounting Templates
	FOR l_okl_avl_rec IN l_okl_avl_csr(l_styv_rec.id, l_sysdate)
	LOOP
	   x_return_status    := G_RET_STS_ERROR;
	   RAISE G_EXCEPTION_HALT_PROCESSING;
	END LOOP;
	-- end, 04/11/2002
	*/

  EXCEPTION
    WHEN G_EXCEPTION_HALT_PROCESSING THEN
    -- no processing necessary; validation can continue
    -- with the next column
	NULL;
  /* Commented till final decision made regarding Versioning
  	-- 04/11/2002
      IF (l_okl_stm_csr%ISOPEN) THEN
	   	  CLOSE l_okl_stm_csr;
      END IF;

      IF (l_okl_avl_csr%ISOPEN) THEN
	   	  CLOSE l_okl_avl_csr;
      END IF;
	 */

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
  -- PROCEDURE create_stream_type for: OKL_STRM_TYPE_V
  ---------------------------------------------------------------------------
  PROCEDURE create_stream_type(	p_api_version                  IN  NUMBER,
	                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 	                       	x_return_status                OUT NOCOPY VARCHAR2,
 	 	                      	x_msg_count                    OUT NOCOPY NUMBER,
  	 	                     	x_msg_data                     OUT NOCOPY VARCHAR2,
   	 	                    	p_styv_rec                     IN  styv_rec_type,
      		                  	x_styv_rec                     OUT NOCOPY styv_rec_type
                        ) IS
    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'create_stream_type';
    l_valid           BOOLEAN := TRUE;
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
    l_styv_rec        styv_rec_type;
    -- 25-Oct-2004 vthiruva -- Fix for Bug#3731453
    -- Changed to_date(to_char()) to trunc() for date comparisions.
    l_sysdate         DATE := TRUNC(SYSDATE);

  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
	l_styv_rec := p_styv_rec;

	--  mvasudev -- 02/17/2002
	-- Store NAME in UPPER CASE always
	l_styv_rec.NAME := UPPER(l_styv_rec.NAME);
	-- end, mvasudev -- 02/17/2002

	-- auto_update code with name
	l_styv_rec.CODE := l_styv_rec.NAME;


     /*
     -- mvasudev COMMENTED , 06/13/2002
     --  check for the records with start and end dates less than sysdate *
        IF TO_DATE(to_char(l_styv_rec.start_date,'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate OR
	   TO_DATE(to_char(l_styv_rec.end_date,'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE G_EXCEPTION_ERROR;
	END IF;
    */



	/* public api to insert streamtype */
    okl_strm_type_pub.insert_strm_type(p_api_version   => p_api_version,
                              		 p_init_msg_list => p_init_msg_list,
                              		 x_return_status => l_return_status,
                              		 x_msg_count     => x_msg_count,
                              		 x_msg_data      => x_msg_data,
                              		 p_styv_rec      => l_styv_rec,
                              		 x_styv_rec      => x_styv_rec);

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
  END create_stream_type;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_stream_type for: OKL_STRM_TYPE_V
  ---------------------------------------------------------------------------
  PROCEDURE update_stream_type(p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        	x_return_status                OUT NOCOPY VARCHAR2,
                        	x_msg_count                    OUT NOCOPY NUMBER,
                        	x_msg_data                     OUT NOCOPY VARCHAR2,
                        	p_styv_rec                     IN  styv_rec_type,
                        	x_styv_rec                     OUT NOCOPY styv_rec_type
                        ) IS

    CURSOR l_okl_styv_pk_csr (p_id IN NUMBER) IS
    SELECT
			START_DATE,
			END_DATE
      FROM OKL_STRM_TYPE_B
     WHERE OKL_STRM_TYPE_B.id   = p_id;

    l_api_version               CONSTANT NUMBER := 1;
    l_api_name                  CONSTANT VARCHAR2(30)  := 'update_stream_type';
    l_no_data_found             BOOLEAN := TRUE;
    l_valid                     BOOLEAN := TRUE;
    -- 25-Oct-2004 vthiruva. Fix for Bug#3731453
    -- Changed to_date(to_char()) to trunc() for date comparisions.
    l_oldversion_enddate        DATE := TRUNC(SYSDATE);
    l_sysdate                   DATE := TRUNC(SYSDATE);
    l_db_styv_rec               styv_rec_type; /* database copy */
    l_upd_styv_rec              styv_rec_type; /* input copy */
    l_styv_rec                  styv_rec_type; /* latest with the retained changes */
    l_tmp_styv_rec              styv_rec_type; /* for any other purposes */
    l_return_status             VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_action                    VARCHAR2(1);
    l_new_version               VARCHAR2(100);
    l_attrib_tbl                okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
    l_return_status := G_RET_STS_SUCCESS;
    l_styv_rec := p_styv_rec;
	-- auto_update code with name
	l_styv_rec.CODE := l_styv_rec.NAME;

    -- mvasudev, 04/20/2002

	-- END_DATE needs to be after START_DATE (sanity check)
	-- and Cannot be less than SysDate
	/*
	** 25-Oct-2004 vthiruva -- Fix for Bug#3731453 start
	** Changed to_date(to_char()) to trunc() for date comparisions.
	*/
	IF  l_styv_rec.end_date IS NOT NULL
	AND l_styv_rec.end_date <> G_MISS_DATE
	AND
	   (TRUNC(l_styv_rec.end_date) < TRUNC(l_styv_rec.start_date)
	    OR TRUNC(l_styv_rec.end_date) < l_sysdate
	   )
	THEN
	/*
	** 25-Oct-2004 vthiruva -- Fix for Bug#3731453 end
	*/
	      OKC_API.SET_MESSAGE( p_app_name   => OKC_API.G_APP_NAME,
                           p_msg_name       => G_INVALID_VALUE,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'END_DATE' );
	   RAISE G_EXCEPTION_ERROR;
	END IF;

    -- Get current database values
    OPEN l_okl_styv_pk_csr (p_styv_rec.id);
    FETCH l_okl_styv_pk_csr INTO
		l_db_styv_rec.START_DATE,
		l_db_styv_rec.END_DATE;
    l_no_data_found := l_okl_styv_pk_csr%NOTFOUND;
    CLOSE l_okl_styv_pk_csr;

	IF l_no_data_found THEN
	   RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

        /*
        -- mvasudev COMMENTED , 06/13/2002
	-- Start-Date cannot be CHANGED for records that have already started being effective
	-- Neither Can the new Start_Date be in the Past
	IF to_date(to_char(l_styv_rec.start_date,'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(l_db_styv_rec.start_date,'DD/MM/YYYY'), 'DD/MM/YYYY')
	AND
	   (    to_date(to_char(l_db_styv_rec.start_date,'DD/MM/YYYY'), 'DD/MM/YYYY') <= l_sysdate
	     OR to_date(to_char(l_styv_rec.start_date,'DD/MM/YYYY'), 'DD/MM/YYYY') < l_sysdate
	   )
	THEN
	      OKC_API.SET_MESSAGE( p_app_name   => OKC_API.G_APP_NAME,
                           p_msg_name       => G_INVALID_VALUE,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'START_DATE' );
	   RAISE G_EXCEPTION_ERROR;
        END IF;
        */

        -- start date can not be greater than old start date if the record is active
	/*
	** 25-Oct-2004 vthiruva -- Fix for Bug#3731453 start
	** Changed to_date(to_char()) to trunc() for date comparisions.
	*/
        IF  TRUNC(l_db_styv_rec.start_date) < l_sysdate
        AND TRUNC(l_styv_rec.start_date) > TRUNC(l_db_styv_rec.start_date)
	THEN
	/*
	** 25-Oct-2004 vthiruva -- Fix for Bug#3731453 end
	*/
	      OKC_API.SET_MESSAGE( p_app_name   => OKC_API.G_APP_NAME,
                           p_msg_name       => G_INVALID_VALUE,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'START_DATE' );
	   RAISE G_EXCEPTION_ERROR;
        END IF;


	-- public api to update_stream_type
    OKL_STRM_TYPE_PUB.update_strm_type(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_styv_rec      => l_styv_rec,
                              		 	x_styv_rec      => x_styv_rec);
    IF l_return_status = G_RET_STS_ERROR THEN
      RAISE G_EXCEPTION_ERROR;
    ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    /*******************************************************************
    *  FOLLOWING CODE COMMENTED TO DISABLE  MULTIPLE VERSIONING
    *  Apr-20-2002, mvasudev
    *
	-- mvasudev -- 02/17/2002
	-- END_DATE needs to be after START_DATE (sanity check)
	IF  l_styv_rec.end_date IS NOT NULL
	AND to_date(to_char(l_styv_rec.end_date,'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(G_MISS_DATE,'DD/MM/YYYY'), 'DD/MM/YYYY')
	AND to_date(to_char(l_styv_rec.end_date,'DD/MM/YYYY'), 'DD/MM/YYYY') < to_date(to_char(l_styv_rec.start_date,'DD/MM/YYYY'), 'DD/MM/YYYY')
	THEN
	      OKC_API.SET_MESSAGE( p_app_name   => OKC_API.G_APP_NAME,
                           p_msg_name       => G_INVALID_VALUE,
                           p_token1         => G_COL_NAME_TOKEN,
                           p_token1_value   => 'END_DATE' );
	END IF;
	-- end, mvasudev -- 02/17/2002

	-- fetch old details from the database *
    get_rec(p_styv_rec 	 	=> l_styv_rec,
		    x_return_status => l_return_status,
			x_no_data_found => l_no_data_found,
    		x_styv_rec		=> l_db_styv_rec);
	IF l_return_status <> G_RET_STS_SUCCESS OR
	   l_no_data_found = TRUE THEN
	   RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	/* check for the records if start and end dates are in the past *
    IF to_date(to_char(l_db_styv_rec.start_date,'DD/MM/YYYY'),'DD/MM/YYYY') < l_sysdate AND
	   to_date(to_char(l_db_styv_rec.end_date,'DD/MM/YYYY'),'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE G_EXCEPTION_ERROR;
	END IF;


	/* retain the details that has been changed only *
    get_changes_only(p_styv_rec 	 	=> p_styv_rec,
   			p_db_rec  => l_db_styv_rec,
    		x_styv_rec		=> l_upd_styv_rec);

	/* mvasudev, 02/17/2002

	-- check for start date greater than sysdate
	IF to_date(to_char(l_upd_styv_rec.start_date,'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(G_MISS_DATE,'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(l_upd_styv_rec.start_date,'DD/MM/YYYY'),'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
	   RAISE G_EXCEPTION_ERROR;
    END IF;

	-- check for end date greater than sysdate
   IF to_date(to_char(l_upd_styv_rec.end_date,'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(G_MISS_DATE,'DD/MM/YYYY'), 'DD/MM/YYYY') AND
      to_date(to_char(l_upd_styv_rec.end_date,'DD/MM/YYYY'),'DD/MM/YYYY') < l_sysdate THEN
         OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
					   p_msg_name		=> G_END_DATE);
         RAISE G_EXCEPTION_ERROR;
    END IF;

	*

	-- START_DATE , if changed, can only be later than TODAY
	IF to_date(to_char(l_upd_styv_rec.start_date,'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(G_MISS_DATE,'DD/MM/YYYY'), 'DD/MM/YYYY') AND
	   to_date(to_char(l_upd_styv_rec.start_date,'DD/MM/YYYY'),'DD/MM/YYYY') <= l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
	   RAISE G_EXCEPTION_ERROR;
    END IF;

	-- END_DATE, if changed, cannot be earlier than TODAY
   IF to_date(to_char(l_upd_styv_rec.end_date,'DD/MM/YYYY'), 'DD/MM/YYYY') <> to_date(to_char(G_MISS_DATE,'DD/MM/YYYY'), 'DD/MM/YYYY') AND
      to_date(to_char(l_upd_styv_rec.end_date,'DD/MM/YYYY'),'DD/MM/YYYY') < l_sysdate THEN
         OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
					   p_msg_name		=> G_END_DATE);
         RAISE G_EXCEPTION_ERROR;
    END IF;

	-- end, mvasudev -- 02/17/2002

	/* determine how the processing to be done *
	l_action := determine_action(p_upd_styv_rec	 => l_upd_styv_rec,
			 					 p_db_styv_rec	 => l_db_styv_rec,
								 p_date			 => l_sysdate);

  /* Scenario 1: The Changed Field-Values can by-pass Validation *
	IF l_action = '1' THEN
	   /* public api to update_stream_type *
       okl_strm_type_pub.update_strm_type(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_styv_rec      => l_upd_styv_rec,
                              		 	x_styv_rec      => x_styv_rec);
       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	/* Scenario 2: The Changed Field-Values include that needs Validation and Update	*
	ELSIF l_action = '2' THEN
	     check_updates(		 p_styv_rec		=> l_styv_rec,
					 x_return_status => l_return_status,
					 x_msg_data		=> x_msg_data);

       IF l_return_status = G_RET_STS_ERROR THEN
       	  RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   /* public api to update formulae *
       okl_strm_type_pub.update_strm_type(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_styv_rec      => l_upd_styv_rec,
                              		 	x_styv_rec      => x_styv_rec);
       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	/* Scenario 3: The Changed Field-Values mandate Creation of a New Version/Record *
	ELSIF l_action = '3' THEN

	   -- mvasudev -- 02/17/2002
	   -- DO NOT Update Old-record if new Start_Date is after Old End_Date
	   IF  l_upd_styv_rec.start_date <> G_MISS_DATE
	   AND l_db_styv_rec.end_date IS NOT NULL
           AND l_upd_styv_rec.start_date >  l_db_styv_rec.end_date
	   THEN
	     -- determine_action() updated on 04/11/2002 never yields this scenario
	     NULL;
	   ELSE
		   /* for old version *
		   IF l_upd_styv_rec.start_date <> G_MISS_DATE THEN
		   	  l_oldversion_enddate := l_upd_styv_rec.start_date - 1;
		   ELSE
		      --mvasudev , 02/17/2002
			  -- The earliest end_date, if changed , can be TODAY.

		   	  --l_oldversion_enddate := l_sysdate - 1;
			  l_oldversion_enddate := l_sysdate;

			  -- end, mvasudev -- 02/17/2002
		   END IF;

		   l_styv_rec := l_db_styv_rec;
		   l_styv_rec.end_date := l_oldversion_enddate;

		   /* call verify changes to update the database *
		   IF l_oldversion_enddate > l_db_styv_rec.end_date THEN
		   	  check_updates(	 	p_styv_rec		=> l_styv_rec,
						 	x_return_status => l_return_status,
						 	x_msg_data		=> x_msg_data);
	       	  IF l_return_status = G_RET_STS_ERROR THEN
	       	  	 RAISE G_EXCEPTION_ERROR;
	       	  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	       	  	 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	          END IF;
		   END IF;

		   /* public api to update stream types *
	       okl_strm_type_pub.update_strm_type(p_api_version   => p_api_version,
	                            		 	p_init_msg_list => p_init_msg_list,
	                              		 	x_return_status => l_return_status,
	                              		 	x_msg_count     => x_msg_count,
	                              		 	x_msg_data      => x_msg_data,
	                              		 	p_styv_rec      => l_styv_rec,
	                              		 	x_styv_rec      => x_styv_rec);

	       IF l_return_status = G_RET_STS_ERROR THEN
	          RAISE G_EXCEPTION_ERROR;
	       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	       END IF;
	   END IF;
	   -- end,mvasudev -- 02/17/2002

	   /* for new version *
	   l_styv_rec := p_styv_rec;
	    -- auto_update code with name
            l_styv_rec.CODE := l_styv_rec.NAME;

	   -- mvasudev , 02/17/2002
	   -- The earliest START_DATE, when Update,  can be TOMORROW only
	   IF l_upd_styv_rec.start_date = G_MISS_DATE THEN
	   	  --l_styv_rec.start_date := l_sysdate ;
		  l_styv_rec.start_date := l_sysdate + 1 ;
	   END IF;

    	l_attrib_tbl(1).attribute := 'CODE';
    	l_attrib_tbl(1).attrib_type	:= okl_accounting_util.G_VARCHAR2;
    	l_attrib_tbl(1).value	:= l_styv_rec.code;

  	   okl_accounting_util.get_version(p_attrib_tbl	  		=> l_attrib_tbl,
  				                       p_cur_version	=> l_styv_rec.version,
				                       p_end_date_attribute_name		=> 'END_DATE',
				                       p_end_date		=> l_styv_rec.end_date,
				                       p_view			=> 'OKL_STRM_TYPE_V',
  				                       x_return_status	=> l_return_status,
				                       x_new_version	=> l_new_version);
       IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       ELSE
	   	  l_styv_rec.version := l_new_version;
       END IF;

	   l_styv_rec.id := G_MISS_NUM;
	   /* call verify changes to update the database *
	   IF l_styv_rec.end_date > l_db_styv_rec.end_date THEN
	   	  check_updates(	  	p_styv_rec		=> l_styv_rec,
					  	x_return_status => l_return_status,
					  	x_msg_data		=> x_msg_data);
       	  IF l_return_status = G_RET_STS_ERROR THEN
          	 RAISE G_EXCEPTION_ERROR;
       	  ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  	 RAISE G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
	   END IF;

	   /* public api to insert stream type *
       okl_strm_type_pub.insert_strm_type(p_api_version   => p_api_version,
                            		 	p_init_msg_list => p_init_msg_list,
                              		 	x_return_status => l_return_status,
                              		 	x_msg_count     => x_msg_count,
                              		 	x_msg_data      => x_msg_data,
                              		 	p_styv_rec      => l_styv_rec,
                              		 	x_styv_rec      => x_styv_rec);
       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
       	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   /* copy output to input structure to get the id *
	   l_styv_rec := x_styv_rec;

	END IF;
  *******************************************************************/
  -- end, 04/20/2002 , mvasudev

    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
      IF (l_okl_styv_pk_csr%ISOPEN) THEN
	   	  CLOSE l_okl_styv_pk_csr;
      END IF;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      IF (l_okl_styv_pk_csr%ISOPEN) THEN
	   	  CLOSE l_okl_styv_pk_csr;
      END IF;
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
      IF (l_okl_styv_pk_csr%ISOPEN) THEN
	   	  CLOSE l_okl_styv_pk_csr;
      END IF;

  END update_stream_type;

  PROCEDURE create_stream_type(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_styv_tbl                     IN  styv_tbl_type,
         x_styv_tbl                     OUT NOCOPY styv_tbl_type)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'create_stream_type_tbl';
	rec_num		INTEGER	:= 0;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_version     CONSTANT NUMBER := 1;
   BEGIN

      	FOR rec_num	IN 1..p_styv_tbl.COUNT
	LOOP
		create_stream_type(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_styv_rec                     => p_styv_tbl(rec_num),
         x_styv_rec                     => x_styv_tbl(rec_num) );
       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;
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
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_stream_type;


  PROCEDURE update_stream_type(
         p_api_version                  IN  NUMBER,
         p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_count                    OUT NOCOPY NUMBER,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_styv_tbl                     IN  styv_tbl_type,
         x_styv_tbl                     OUT NOCOPY styv_tbl_type)
   IS
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_stream_type_tbl';
	rec_num		INTEGER	:= 0;
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_version     CONSTANT NUMBER := 1;
   BEGIN

 	FOR rec_num	IN 1.. p_styv_tbl.COUNT
	LOOP
		update_stream_type(
         p_api_version                  => p_api_version,
         p_init_msg_list                => p_init_msg_list,
         x_return_status                => l_return_status,
         x_msg_count                    => x_msg_count,
         x_msg_data                     => x_msg_data,
         p_styv_rec                     => p_styv_tbl(rec_num),
         x_styv_rec                     => x_styv_tbl(rec_num) );
	       IF l_return_status = G_RET_STS_ERROR THEN
		  RAISE G_EXCEPTION_ERROR;
	       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
		  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	      END IF;
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
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM );
      -- notify caller of an UNEXPECTED error
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_stream_type;

END Okl_Setup_Streamtypes_Pvt;

/
