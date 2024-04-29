--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_PROVISIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_PROVISIONS_PVT" AS
/* $Header: OKLRPRVB.pls 115.6 2002/02/18 20:12:38 pkm ship        $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_PROVISIONS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (p_pvnv_rec IN pvnv_rec_type,
                     x_return_status OUT NOCOPY VARCHAR2,
                     x_no_data_found OUT NOCOPY BOOLEAN,
                     x_pvnv_rec OUT NOCOPY pvnv_rec_type
  ) IS
    CURSOR okl_pvnv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
            VERSION,
            FROM_DATE,
            NVL(TO_DATE, G_MISS_DATE) TO_DATE,
            NVL(DESCRIPTION, G_MISS_CHAR) DESCRIPTION,
            APP_DEBIT_CCID,
            APP_CREDIT_CCID,
            REV_DEBIT_CCID,
            REV_CREDIT_CCID,
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

     FROM OKL_PROVISIONS
     WHERE id = p_id;

    l_okl_pvnv_pk                  okl_pvnv_pk_csr%ROWTYPE;
    l_pvnv_rec                     pvnv_rec_type;
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_pvnv_pk_csr (p_pvnv_rec.id);
    FETCH okl_pvnv_pk_csr INTO
              l_pvnv_rec.ID,
              l_pvnv_rec.OBJECT_VERSION_NUMBER,
              l_pvnv_rec.NAME,
              l_pvnv_rec.VERSION,
              l_pvnv_rec.FROM_DATE,
              l_pvnv_rec.TO_DATE,
              l_pvnv_rec.DESCRIPTION,
              l_pvnv_rec.APP_DEBIT_CCID,
              l_pvnv_rec.APP_CREDIT_CCID,
              l_pvnv_rec.REV_DEBIT_CCID,
              l_pvnv_rec.REV_CREDIT_CCID,
              l_pvnv_rec.ATTRIBUTE_CATEGORY,
              l_pvnv_rec.ATTRIBUTE1,
              l_pvnv_rec.ATTRIBUTE2,
              l_pvnv_rec.ATTRIBUTE3,
              l_pvnv_rec.ATTRIBUTE4,
              l_pvnv_rec.ATTRIBUTE5,
              l_pvnv_rec.ATTRIBUTE6,
              l_pvnv_rec.ATTRIBUTE7,
              l_pvnv_rec.ATTRIBUTE8,
              l_pvnv_rec.ATTRIBUTE9,
              l_pvnv_rec.ATTRIBUTE10,
              l_pvnv_rec.ATTRIBUTE11,
              l_pvnv_rec.ATTRIBUTE12,
              l_pvnv_rec.ATTRIBUTE13,
              l_pvnv_rec.ATTRIBUTE14,
              l_pvnv_rec.ATTRIBUTE15,
              l_pvnv_rec.CREATED_BY,
              l_pvnv_rec.LAST_UPDATED_BY,
              l_pvnv_rec.CREATION_DATE,
              l_pvnv_rec.LAST_UPDATE_DATE,
              l_pvnv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pvnv_pk_csr%NOTFOUND;
    CLOSE okl_pvnv_pk_csr;

    x_pvnv_rec := l_pvnv_rec;
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
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

      IF (okl_pvnv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_pvnv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- PROCEDURE get_changes_only for: OKL_PROVISIONS_V
  -- To take care of the assumption that Everything except the Changed Fields
  -- have G_MISS values in them
  ---------------------------------------------------------------------------
  PROCEDURE get_changes_only (p_pvnv_rec IN pvnv_rec_type,
    p_db_rec                   IN pvnv_rec_type,
    x_pvnv_rec                 OUT NOCOPY pvnv_rec_type )
  IS
    l_pvnv_rec pvnv_rec_type;
  BEGIN
        l_pvnv_rec := p_pvnv_rec;

    	IF p_db_rec.NAME = p_pvnv_rec.NAME THEN
    		l_pvnv_rec.NAME := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.VERSION = p_pvnv_rec.VERSION THEN
    		l_pvnv_rec.VERSION := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.FROM_DATE = p_pvnv_rec.FROM_DATE THEN
    		l_pvnv_rec.FROM_DATE := G_MISS_DATE;
    	END IF;

	IF p_db_rec.TO_DATE IS NULL THEN
	  IF p_pvnv_rec.TO_DATE IS NULL THEN
	    l_pvnv_rec.TO_DATE := G_MISS_DATE;
	  END IF;
    	ELSIF p_db_rec.TO_DATE = p_pvnv_rec.TO_DATE THEN
          l_pvnv_rec.TO_DATE := G_MISS_DATE;
    	END IF;

    	IF p_db_rec.DESCRIPTION IS NULL THEN
    	  IF p_pvnv_rec.DESCRIPTION IS NULL THEN
    	    l_pvnv_rec.DESCRIPTION := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.DESCRIPTION = p_pvnv_rec.DESCRIPTION THEN
    	  l_pvnv_rec.DESCRIPTION := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.APP_DEBIT_CCID = p_pvnv_rec.APP_DEBIT_CCID THEN
    		l_pvnv_rec.APP_DEBIT_CCID := G_MISS_NUM;
    	END IF;

    	IF p_db_rec.APP_CREDIT_CCID = p_pvnv_rec.APP_CREDIT_CCID THEN
    		l_pvnv_rec.APP_CREDIT_CCID := G_MISS_NUM;
    	END IF;

    	IF p_db_rec.REV_DEBIT_CCID = p_pvnv_rec.REV_DEBIT_CCID THEN
    		l_pvnv_rec.REV_DEBIT_CCID := G_MISS_NUM;
    	END IF;

    	IF p_db_rec.REV_CREDIT_CCID = p_pvnv_rec.REV_CREDIT_CCID THEN
    		l_pvnv_rec.REV_CREDIT_CCID := G_MISS_NUM;
    	END IF;

    	IF p_db_rec.ATTRIBUTE_CATEGORY IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE_CATEGORY IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE_CATEGORY := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE_CATEGORY = p_pvnv_rec.ATTRIBUTE_CATEGORY THEN
          l_pvnv_rec.ATTRIBUTE_CATEGORY := G_MISS_CHAR;
    	END IF;

        IF p_db_rec.ATTRIBUTE1 IS NULL THEN
          IF p_pvnv_rec.ATTRIBUTE1 IS NULL THEN
            l_pvnv_rec.ATTRIBUTE1 := G_MISS_CHAR;
          END IF;
        ELSIF p_db_rec.ATTRIBUTE1 = p_pvnv_rec.ATTRIBUTE1 THEN
          l_pvnv_rec.ATTRIBUTE1 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE2 IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE2 IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE2 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE2 = p_pvnv_rec.ATTRIBUTE2 THEN
          l_pvnv_rec.ATTRIBUTE2 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE3 IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE3 IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE3 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE3 = p_pvnv_rec.ATTRIBUTE3 THEN
          l_pvnv_rec.ATTRIBUTE3 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE4 IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE4 IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE4 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE4 = p_pvnv_rec.ATTRIBUTE4 THEN
          l_pvnv_rec.ATTRIBUTE4 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE5 IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE5 IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE5 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE5 = p_pvnv_rec.ATTRIBUTE5 THEN
          l_pvnv_rec.ATTRIBUTE5 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE6 IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE6 IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE6 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE6 = p_pvnv_rec.ATTRIBUTE6 THEN
          l_pvnv_rec.ATTRIBUTE6 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE7 IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE7 IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE7 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE7 = p_pvnv_rec.ATTRIBUTE7 THEN
          l_pvnv_rec.ATTRIBUTE7 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE8 IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE8 IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE8 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE8 = p_pvnv_rec.ATTRIBUTE8 THEN
          l_pvnv_rec.ATTRIBUTE8 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE9 IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE9 IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE9 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE9 = p_pvnv_rec.ATTRIBUTE9 THEN
          l_pvnv_rec.ATTRIBUTE9 := G_MISS_CHAR;
    	END IF;

        IF p_db_rec.ATTRIBUTE10 IS NULL THEN
	  IF p_pvnv_rec.ATTRIBUTE10 IS NULL THEN
	    l_pvnv_rec.ATTRIBUTE10 := G_MISS_CHAR;
	  END IF;
	ELSIF p_db_rec.ATTRIBUTE10 = p_pvnv_rec.ATTRIBUTE10 THEN
	  l_pvnv_rec.ATTRIBUTE10 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE11 IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE11 IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE11 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE11 = p_pvnv_rec.ATTRIBUTE11 THEN
          l_pvnv_rec.ATTRIBUTE11 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE12 IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE12 IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE12 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE12 = p_pvnv_rec.ATTRIBUTE12 THEN
          l_pvnv_rec.ATTRIBUTE12 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE13 IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE13 IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE13 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE13 = p_pvnv_rec.ATTRIBUTE13 THEN
          l_pvnv_rec.ATTRIBUTE13 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE14 IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE14 IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE5 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE14 = p_pvnv_rec.ATTRIBUTE5 THEN
          l_pvnv_rec.ATTRIBUTE14 := G_MISS_CHAR;
    	END IF;

    	IF p_db_rec.ATTRIBUTE15 IS NULL THEN
    	  IF p_pvnv_rec.ATTRIBUTE15 IS NULL THEN
    	    l_pvnv_rec.ATTRIBUTE15 := G_MISS_CHAR;
    	  END IF;
    	ELSIF p_db_rec.ATTRIBUTE15 = p_pvnv_rec.ATTRIBUTE15 THEN
          l_pvnv_rec.ATTRIBUTE15 := G_MISS_CHAR;
    	END IF;

        x_pvnv_rec := l_pvnv_rec;
  END get_changes_only;

  ---------------------------------------------------------------------------
  -- PROCEDURE determine_action for: OKL_PROVISIONS_V
  -- This function helps in determining the various checks to be performed
  -- for the new/updated record and also helps in determining whether a new
  -- version is required or not
  ---------------------------------------------------------------------------
  FUNCTION determine_action (
    p_upd_pvnv_rec                 IN pvnv_rec_type,
	p_db_pvnv_rec				   IN pvnv_rec_type,
	p_date						   IN DATE
  ) RETURN VARCHAR2 IS
  l_action VARCHAR2(1);
  l_sysdate DATE := trunc(SYSDATE);
BEGIN

  /* Scenario 1: The Changed Field-Values can by-pass Validation */
  IF p_upd_pvnv_rec.from_date = G_MISS_DATE AND
	 p_upd_pvnv_rec.to_date = G_MISS_DATE AND
	 p_upd_pvnv_rec.app_debit_ccid = G_MISS_NUM AND
	 p_upd_pvnv_rec.app_credit_ccid = G_MISS_NUM AND
	 p_upd_pvnv_rec.rev_debit_ccid = G_MISS_NUM AND
	 p_upd_pvnv_rec.rev_credit_ccid = G_MISS_NUM THEN
	 l_action := '1';

	/* Scenario 2: The Changed Field-Values include that needs Validation and Update
	   but does not require a new vresion to be created
	*/
	--	1) Only End_Date is Changed
  ELSIF (p_upd_pvnv_rec.from_date = G_MISS_DATE AND
	     (p_upd_pvnv_rec.to_date <> G_MISS_DATE OR
		 --  IS NULL Condition has been added in case end_date was updated to NULL
	     p_upd_pvnv_rec.to_date IS NULL ) AND
    	 p_upd_pvnv_rec.app_debit_ccid = G_MISS_NUM AND
    	 p_upd_pvnv_rec.app_credit_ccid = G_MISS_NUM AND
    	 p_upd_pvnv_rec.rev_debit_ccid = G_MISS_NUM AND
    	 p_upd_pvnv_rec.rev_credit_ccid = G_MISS_NUM) OR
	--	2)	Critical Attributes are Changed but Start_Date is Today or Future
	    (p_upd_pvnv_rec.from_date = G_MISS_DATE AND
	     p_db_pvnv_rec.from_date >= p_date AND
	     (p_upd_pvnv_rec.app_debit_ccid <> G_MISS_NUM OR
    	 p_upd_pvnv_rec.app_credit_ccid <> G_MISS_NUM OR
    	 p_upd_pvnv_rec.rev_debit_ccid <> G_MISS_NUM OR
    	 p_upd_pvnv_rec.rev_credit_ccid <> G_MISS_NUM)) OR
	--	3)	Start_Date is Changed , but in Future
	    (p_upd_pvnv_rec.from_date <> G_MISS_DATE AND
	     p_db_pvnv_rec.from_date > p_date AND
		 p_upd_pvnv_rec.from_date >= p_date) THEN
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
  PROCEDURE check_updates (p_pvnv_rec IN pvnv_rec_type,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_data OUT NOCOPY VARCHAR2
  ) IS
  l_pvnv_rec	  pvnv_rec_type;
  l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_valid		  BOOLEAN;
  l_attrib_tbl	okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
	   l_pvnv_rec := p_pvnv_rec;

		  /* call check_overlaps */
		l_attrib_tbl(1).attribute	:= 'name';
  		l_attrib_tbl(1).attrib_type	:= okl_accounting_util.G_VARCHAR2;
		l_attrib_tbl(1).value	:= l_pvnv_rec.name;

		  okl_accounting_util.check_overlaps(p_id	   	 					=> l_pvnv_rec.id,
                                             p_attrib_tbl					=> l_attrib_tbl,
                                             p_start_date_attribute_name	=> 'FROM_DATE',
		  				                     p_start_date 					=> l_pvnv_rec.from_date,
                                             p_end_date_attribute_name		=> 'TO_DATE',
						                     p_end_date						=> l_pvnv_rec.to_date,
						                     p_view							=> 'OKL_PROVISIONS_V',
						                     x_return_status				=> l_return_status,
						                     x_valid						=> l_valid);


       	  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       		 x_return_status    := OKL_API.G_RET_STS_UNEXP_ERROR;
      	  	 RAISE G_EXCEPTION_HALT_PROCESSING;
       	  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) OR
		  	    (l_return_status = OKL_API.G_RET_STS_SUCCESS AND
		   	     l_valid <> TRUE) THEN
       		 x_return_status    := OKL_API.G_RET_STS_ERROR;
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
	  x_msg_data := 'Unexpected Database Error';
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END check_updates;


  ---------------------------------------------------------------------------
  -- PROCEDURE create_provisions for: OKL_PROVISIONS_V
  ---------------------------------------------------------------------------
  PROCEDURE create_provisions(p_api_version                  IN  NUMBER,
                              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status                OUT NOCOPY VARCHAR2,
                              x_msg_count                    OUT NOCOPY NUMBER,
                              x_msg_data                     OUT NOCOPY VARCHAR2,
                              p_pvnv_rec                     IN  pvnv_rec_type,
                              x_pvnv_rec                     OUT NOCOPY pvnv_rec_type ) IS

    l_api_version     CONSTANT NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'create_provisions';
    l_no_data_found   	  	BOOLEAN := TRUE;
	l_valid			  BOOLEAN := TRUE;
    l_return_status   VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;
	l_pvnv_rec		  pvnv_rec_type;
	l_sysdate		  DATE := to_date(SYSDATE, 'DD/MM/YYYY');
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
	l_pvnv_rec := p_pvnv_rec;

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

    /* validate name */
	IF (l_pvnv_rec.name IS NULL OR l_pvnv_rec.name = G_MISS_CHAR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						  p_msg_name		=> 'OKL_PVN_NAME_ERROR');
	  RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    /* validate on application debit account */
	IF (l_pvnv_rec.app_debit_ccid IS NULL OR l_pvnv_rec.app_debit_ccid = G_MISS_NUM) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						  p_msg_name		=> 'OKL_PVN_CCID_ERROR');
	  RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    /* validate on application credit account */
	IF (l_pvnv_rec.app_credit_ccid IS NULL OR l_pvnv_rec.app_credit_ccid = G_MISS_NUM) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						  p_msg_name		=> 'OKL_PVN_CCID_ERROR');
	  RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    /* validate on reversal debit account */
	IF (l_pvnv_rec.rev_debit_ccid IS NULL OR l_pvnv_rec.rev_debit_ccid = G_MISS_NUM) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						  p_msg_name		=> 'OKL_PVN_CCID_ERROR');
	  RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    /* validate on reversal credit account */
	IF (l_pvnv_rec.rev_credit_ccid IS NULL OR l_pvnv_rec.rev_credit_ccid = G_MISS_NUM) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						  p_msg_name		=> 'OKL_PVN_CCID_ERROR');
	  RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    /* validate effective start date */
	IF (l_pvnv_rec.from_date IS NULL OR l_pvnv_rec.from_date = G_MISS_DATE) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						  p_msg_name		=> 'OKL_PVN_DATE_ERROR');
	  RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	/* check for the records with start and end dates less than sysdate */
    IF to_date(l_pvnv_rec.from_date, 'DD/MM/YYYY') < l_sysdate OR
	   to_date(l_pvnv_rec.to_date, 'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;


	/* public api to insert provision type */
	      OKL_PROVISIONS_PUB.INSERT_PROVISIONS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => l_return_status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_pvnv_rec        => l_pvnv_rec,
    										   x_pvnv_rec        => x_pvnv_rec);

     IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
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

  END create_provisions;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_provisions for: OKL_PROVISIONS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_provisions(p_api_version                  IN  NUMBER,
                              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status                OUT NOCOPY VARCHAR2,
                              x_msg_count                    OUT NOCOPY NUMBER,
                              x_msg_data                     OUT NOCOPY VARCHAR2,
                              p_pvnv_rec                     IN  pvnv_rec_type,
                              x_pvnv_rec                     OUT NOCOPY pvnv_rec_type
                              ) IS
    l_api_version     	  	CONSTANT NUMBER := 1;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_provisions';
    l_no_data_found   	  	BOOLEAN := TRUE;
	l_valid			  	  	BOOLEAN := TRUE;
	l_oldversion_enddate  	DATE := to_date(SYSDATE, 'DD/MM/YYYY');
	l_sysdate			  	DATE := to_date(SYSDATE, 'DD/MM/YYYY');
    l_db_pvnv_rec    	  	pvnv_rec_type; /* database copy */
	l_upd_pvnv_rec	 	  	pvnv_rec_type; /* input copy */
	l_pvnv_rec	  	 	  	pvnv_rec_type := p_pvnv_rec; /* latest with the retained changes */
	l_tmp_pvnv_rec			pvnv_rec_type; /* for any other purposes */
    l_return_status   	  	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_action				VARCHAR2(1);
	l_new_version			VARCHAR2(100);
    l_attrib_tbl	        okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
	--l_upd_pvnv_rec := p_pvnv_rec;

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
    get_rec(p_pvnv_rec => p_pvnv_rec,
            x_return_status => l_return_status,
	        x_no_data_found => l_no_data_found,
    	    x_pvnv_rec => l_db_pvnv_rec);

    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS OR
       l_no_data_found = TRUE THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    /* check for the records if start and end dates are in the past */
    IF to_date(l_db_pvnv_rec.from_date,'DD/MM/YYYY') < l_sysdate AND
	   to_date(l_db_pvnv_rec.to_date,'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
			       p_msg_name => G_PAST_RECORDS);
    RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /* retain the details that has been changed only */
    get_changes_only(p_pvnv_rec => p_pvnv_rec,
	             p_db_rec => l_db_pvnv_rec,
	             x_pvnv_rec => l_upd_pvnv_rec);

    /* check for start date lesser than sysdate */
    IF to_date(l_upd_pvnv_rec.from_date, 'DD/MM/YYYY') <> to_date(G_MISS_DATE, 'DD/MM/YYYY') AND
	   to_date(l_upd_pvnv_rec.from_date,'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
			       p_msg_name => G_START_DATE);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /* check for end date lesser than sysdate */
    IF to_date(l_upd_pvnv_rec.to_date, 'DD/MM/YYYY') <> to_date(G_MISS_DATE, 'DD/MM/YYYY') AND
	   to_date(l_upd_pvnv_rec.to_date,'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
			       p_msg_name => G_END_DATE);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

	/* determine how the processing to be done */
	l_action := determine_action(p_upd_pvnv_rec	 => l_upd_pvnv_rec,
			 					 p_db_pvnv_rec	 => l_db_pvnv_rec,
								 p_date			 => l_sysdate);


  /* Scenario 1: The Changed Field-Values can by-pass Validation */
	IF l_action = '1' THEN
	   /* public api to update provisions*/
	      OKL_PROVISIONS_PUB.UPDATE_PROVISIONS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => l_return_status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_pvnv_rec        => l_upd_pvnv_rec,
    										   x_pvnv_rec        => x_pvnv_rec);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	/* Scenario 2: The Changed Field-Values include that needs Validation and Update	*/
	ELSIF l_action = '2' THEN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_pvnv_rec := p_pvnv_rec;

	   check_updates(p_pvnv_rec => l_pvnv_rec,
			 x_return_status => l_return_status,
			 x_msg_data => x_msg_data);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   /* public api to update provisions */
	      OKL_PROVISIONS_PUB.UPDATE_PROVISIONS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => l_return_status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_pvnv_rec        => l_upd_pvnv_rec,
    										   x_pvnv_rec        => x_pvnv_rec);
       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	/* Scenario 3: The Changed Field-Values mandate Creation of a New Version/Record */
	ELSIF l_action = '3' THEN

	   /* for old version */
	   IF l_upd_pvnv_rec.from_date <> G_MISS_DATE THEN
	   	  l_oldversion_enddate := l_upd_pvnv_rec.from_date - 1;
	   ELSE
	   	  l_oldversion_enddate := l_sysdate - 1;
	   END IF;

	   l_pvnv_rec := l_db_pvnv_rec;
	   l_pvnv_rec.to_date := l_oldversion_enddate;

	   /* call verify changes to update the database */
	   IF l_oldversion_enddate > l_db_pvnv_rec.to_date THEN
	   	  check_updates(p_pvnv_rec => l_pvnv_rec,
			   x_return_status => l_return_status,
			   x_msg_data => x_msg_data);

       	  IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  	 RAISE OKL_API.G_EXCEPTION_ERROR;
       	  ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
	   END IF;

	   /* public api to update provisions */
	      OKL_PROVISIONS_PUB.UPDATE_PROVISIONS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => l_return_status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_pvnv_rec        => l_pvnv_rec,
    										   x_pvnv_rec        => x_pvnv_rec);

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   /* for new version */
	   /* create a temporary record with all relevant details from db and upd records */
       /* removed call to default_to_actuals sgiyer 02-06-02 */
	   l_pvnv_rec := p_pvnv_rec;

	   IF l_upd_pvnv_rec.from_date = G_MISS_DATE THEN
	   	  l_pvnv_rec.from_date := l_sysdate;
	   END IF;

		l_attrib_tbl(1).attribute := 'name';
		l_attrib_tbl(1).attrib_type := okl_accounting_util.G_VARCHAR2;
		l_attrib_tbl(1).value := l_pvnv_rec.name;

    	okl_accounting_util.get_version(
								        p_attrib_tbl				=> l_attrib_tbl,
    							      	p_cur_version				=> l_pvnv_rec.version,
                                    	p_end_date_attribute_name	=> 'TO_DATE',
				                       p_end_date		=> l_pvnv_rec.to_date,
                                    	p_view						=> 'OKL_PROVISIONS_V',
  				                       x_return_status				=> l_return_status,
				                       x_new_version				=> l_new_version);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSE
	   	  l_pvnv_rec.version := l_new_version;
       END IF;

	   l_pvnv_rec.id := G_MISS_NUM;

	   /* call verify changes to update the database */
	   /* call verify changes to update the database */
	   IF l_pvnv_rec.from_date > l_db_pvnv_rec.to_date THEN
	     check_updates(p_pvnv_rec => l_pvnv_rec,
			   x_return_status => l_return_status,
			   x_msg_data => x_msg_data);
       	  IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          	 RAISE OKL_API.G_EXCEPTION_ERROR;
       	  ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
	   END IF;

	   /* public api to insert provisions */
	      OKL_PROVISIONS_PUB.INSERT_PROVISIONS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => l_return_status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_pvnv_rec        => l_pvnv_rec,
    										   x_pvnv_rec        => x_pvnv_rec);

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   /* copy output to input structure to get the id */
	   l_pvnv_rec := x_pvnv_rec;

	END IF;

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
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

  END update_provisions;

  PROCEDURE create_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type)

	IS

	l_api_version NUMBER := 1.0;

	BEGIN

	      OKL_PROVISIONS_PUB.INSERT_PROVISIONS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => x_return_Status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_pvnv_tbl        => p_pvnv_tbl,
    										   x_pvnv_tbl        => x_pvnv_tbl);

	END create_provisions;

  PROCEDURE update_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type,
    x_pvnv_tbl                     OUT NOCOPY pvnv_tbl_type)

	IS
	l_api_version NUMBER := 1.0;

	BEGIN

	      OKL_PROVISIONS_PUB.UPDATE_PROVISIONS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => x_return_Status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_pvnv_tbl        => p_pvnv_tbl,
    										   x_pvnv_tbl        => x_pvnv_tbl);

	END update_provisions;


  PROCEDURE delete_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_rec                     IN  pvnv_rec_type)

	IS
	l_api_version NUMBER := 1.0;

	BEGIN

	      OKL_PROVISIONS_PUB.DELETE_PROVISIONS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => x_return_Status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_pvnv_rec        => p_pvnv_rec);


  END delete_provisions;

  PROCEDURE delete_provisions(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pvnv_tbl                     IN  pvnv_tbl_type)

  IS

	l_api_version NUMBER := 1.0;

  BEGIN

	      OKL_PROVISIONS_PUB.DELETE_PROVISIONS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => x_return_Status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_pvnv_tbl        => p_pvnv_tbl);

  END delete_provisions;


END OKL_PROCESS_PROVISIONS_PVT;

/
