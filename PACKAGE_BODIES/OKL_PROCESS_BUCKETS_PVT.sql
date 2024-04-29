--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_BUCKETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_BUCKETS_PVT" AS
/* $Header: OKLRBUKB.pls 120.3 2005/10/30 03:38:23 appldev noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE get_rec for: OKL_BUCKETS_V
  ---------------------------------------------------------------------------
  PROCEDURE get_rec (
    p_bktv_rec                     IN   bktv_rec_type,
	p_changes_only   			   IN	BOOLEAN DEFAULT FALSE,
	x_return_status				   OUT NOCOPY VARCHAR2,
    x_no_data_found                OUT NOCOPY BOOLEAN,
	x_bktv_rec					   OUT NOCOPY bktv_rec_type
  ) IS
    CURSOR okl_bktv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            IBC_ID,
			VERSION,
			LOSS_RATE,
            START_DATE,
            NVL(END_DATE,OKL_API.G_MISS_DATE) END_DATE,
            NVL(COMMENTS,OKL_API.G_MISS_CHAR) COMMENTS,
            NVL(PROGRAM_ID,OKL_API.G_MISS_NUM) PROGRAM_ID,
            NVL(REQUEST_ID,OKL_API.G_MISS_NUM) REQUEST_ID,
            NVL(PROGRAM_APPLICATION_ID,OKL_API.G_MISS_NUM) PROGRAM_APPLICATION_ID,
            NVL(PROGRAM_UPDATE_DATE,OKL_API.G_MISS_DATE) PROGRAM_UPDATE_DATE,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            NVL(LAST_UPDATE_LOGIN,OKL_API.G_MISS_NUM) LAST_UPDATE_LOGIN
      FROM OKL_BUCKETS_V
     WHERE OKL_BUCKETS_V.id = p_id;

    l_okl_bktv_pk                  okl_bktv_pk_csr%ROWTYPE;
    l_bktv_rec                     bktv_rec_type;
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    x_no_data_found := TRUE;

    -- Get current database values
    OPEN okl_bktv_pk_csr (p_bktv_rec.id);
    FETCH okl_bktv_pk_csr INTO
              l_bktv_rec.ID,
              l_bktv_rec.OBJECT_VERSION_NUMBER,
              l_bktv_rec.IBC_ID,
              l_bktv_rec.VERSION,
              l_bktv_rec.LOSS_RATE,
              l_bktv_rec.START_DATE,
              l_bktv_rec.END_DATE,
              l_bktv_rec.COMMENTS,
              l_bktv_rec.PROGRAM_ID,
              l_bktv_rec.REQUEST_ID,
              l_bktv_rec.PROGRAM_APPLICATION_ID,
              l_bktv_rec.PROGRAM_UPDATE_DATE,
              l_bktv_rec.CREATED_BY,
              l_bktv_rec.LAST_UPDATED_BY,
              l_bktv_rec.CREATION_DATE,
              l_bktv_rec.LAST_UPDATE_DATE,
              l_bktv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_bktv_pk_csr%NOTFOUND;
    CLOSE okl_bktv_pk_csr;
	/* To take care of the assumption that Everything except the Changed Fields have G_MISS values in them*/
/*	IF (p_changes_only) THEN

		x_bktv_rec := p_bktv_rec;

    	IF l_bktv_rec.IBC_ID = p_bktv_rec.IBC_ID THEN
    		x_bktv_rec.IBC_ID := OKL_API.G_MISS_NUM;
    	END IF;

    	IF l_bktv_rec.VERSION = p_bktv_rec.VERSION THEN
    		x_bktv_rec.IBC_ID := OKL_API.G_MISS_NUM;
    	END IF;

    	IF l_bktv_rec.LOSS_RATE = p_bktv_rec.LOSS_RATE THEN
    		x_bktv_rec.LOSS_RATE := OKL_API.G_MISS_NUM;
    	END IF;

    	IF l_bktv_rec.START_DATE = p_bktv_rec.START_DATE THEN
    		x_bktv_rec.START_DATE := OKL_API.G_MISS_DATE;
    	END IF;

    	IF l_bktv_rec.END_DATE = p_bktv_rec.END_DATE THEN
    		x_bktv_rec.END_DATE := OKL_API.G_MISS_DATE;
    	END IF;

    	IF l_bktv_rec.COMMENTS = p_bktv_rec.COMMENTS THEN
    		x_bktv_rec.COMMENTS := OKL_API.G_MISS_CHAR;
    	END IF;

    ELSE
		x_bktv_rec := l_bktv_rec;
    END IF;
*/
	x_bktv_rec := l_bktv_rec;
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

      IF (okl_bktv_pk_csr%ISOPEN) THEN
	   	  CLOSE okl_bktv_pk_csr;
      END IF;

  END get_rec;

  ---------------------------------------------------------------------------
  -- FUNCTION defaults_to_actuals
  -- This function creates an output record with changed information from the
  -- input structure and unchanged details from the database
  ---------------------------------------------------------------------------
  FUNCTION defaults_to_actuals (
    p_upd_bktv_rec                 IN bktv_rec_type,
	p_db_bktv_rec				   IN bktv_rec_type
  ) RETURN bktv_rec_type IS
  l_bktv_rec	bktv_rec_type;
  BEGIN
	   /* create a temporary record with all relevant details from db and upd records */
	   l_bktv_rec := p_db_bktv_rec;

	   IF p_upd_bktv_rec.ibc_id <> OKL_API.G_MISS_NUM THEN
	  	  l_bktv_rec.ibc_id := p_upd_bktv_rec.ibc_id;
	   END IF;

	   IF p_upd_bktv_rec.version <> OKL_API.G_MISS_CHAR THEN
	  	  l_bktv_rec.version := p_upd_bktv_rec.version;
	   END IF;

	   IF p_upd_bktv_rec.loss_rate <> OKL_API.G_MISS_NUM THEN
	  	  l_bktv_rec.loss_rate := p_upd_bktv_rec.loss_rate;
	   END IF;

	   IF p_upd_bktv_rec.start_date <> OKL_API.G_MISS_DATE THEN
	  	  l_bktv_rec.start_date := p_upd_bktv_rec.start_date;
	   END IF;

       IF p_upd_bktv_rec.end_date IS NULL OR
          p_upd_bktv_rec.end_date <> OKL_API.G_MISS_DATE
	   THEN
	   	  l_bktv_rec.end_date := p_upd_bktv_rec.end_date;
	   END IF;

	   IF p_upd_bktv_rec.comments <> OKL_API.G_MISS_CHAR THEN
	  	  l_bktv_rec.comments := p_upd_bktv_rec.comments;
	   END IF;

	   RETURN l_bktv_rec;
  END defaults_to_actuals;

  ---------------------------------------------------------------------------
  -- PROCEDURE check_updates
  -- To verify whether the requested changes from the screen are valid or not
  ---------------------------------------------------------------------------
  PROCEDURE check_updates (
    p_upd_bktv_rec                 IN bktv_rec_type,
	p_db_bktv_rec				   IN bktv_rec_type,
	p_bktv_rec					   IN bktv_rec_type,
	x_return_status				   OUT NOCOPY VARCHAR2,
	x_msg_data					   OUT NOCOPY VARCHAR2
  ) IS
  l_bktv_rec	  bktv_rec_type;
  l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_valid		  BOOLEAN;
  l_attrib_tbl	okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
	   l_return_status := OKL_API.G_RET_STS_SUCCESS;
	   l_bktv_rec := p_bktv_rec;

	   IF p_upd_bktv_rec.start_date <> OKL_API.G_MISS_DATE OR
	   	  p_upd_bktv_rec.end_date <> OKL_API.G_MISS_DATE THEN

		  /* call check_overlaps */
		l_attrib_tbl(1).attribute	:= 'ibc_id';
  		l_attrib_tbl(1).attrib_type	:= okl_accounting_util.G_NUMBER;
		l_attrib_tbl(1).value	:= l_bktv_rec.ibc_id;

		  okl_accounting_util.check_overlaps(p_id	   	 					=> l_bktv_rec.id,
                                             p_attrib_tbl					=> l_attrib_tbl,
                                             p_start_date_attribute_name	=> 'START_DATE',
		  				                     p_start_date 					=> l_bktv_rec.start_date,
                                             p_end_date_attribute_name		=> 'END_DATE',
						                     p_end_date						=> l_bktv_rec.end_date,
						                     p_view							=> 'OKL_BUCKETS_V',
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
  -- PROCEDURE create_buckets for: OKL_BUCKETS_V
  ---------------------------------------------------------------------------
  PROCEDURE create_buckets(p_api_version                  IN  NUMBER,
                              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status                OUT NOCOPY VARCHAR2,
                              x_msg_count                    OUT NOCOPY NUMBER,
                              x_msg_data                     OUT NOCOPY VARCHAR2,
                              p_bktv_rec                     IN  bktv_rec_type,
                              x_bktv_rec                     OUT NOCOPY bktv_rec_type ) IS

    l_api_version     	  	CONSTANT NUMBER := 1;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'create_buckets';
        -- viselvar fixed Bug 4016263. Changed to_date() to trunc()
	l_sysdate			  	DATE := trunc(SYSDATE);
        -- Bug 4016263 Bug Fix end.
    l_db_bktv_rec    	  	bktv_rec_type; /* database copy */
	l_upd_bktv_rec	 	  	bktv_rec_type; /* input copy */
	l_bktv_rec	  	 	  	bktv_rec_type; /* latest with the retained changes */
	l_tmp_bktv_rec			bktv_rec_type; /* for any other purposes */
    l_return_status   	  	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_new_version			VARCHAR2(100);
    l_attrib_tbl	        okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
	l_upd_bktv_rec := p_bktv_rec;

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

    -- for new version
	-- create a temporary record with all relevant details from db and upd records
	l_bktv_rec := defaults_to_actuals(p_upd_bktv_rec => l_upd_bktv_rec,
	   					  				 p_db_bktv_rec  => l_db_bktv_rec);

	   IF l_upd_bktv_rec.start_date = OKL_API.G_MISS_DATE THEN
	   	  l_bktv_rec.start_date := l_sysdate;
	   END IF;

		l_attrib_tbl(1).attribute := 'ibc_id';
		l_attrib_tbl(1).attrib_type := okl_accounting_util.G_NUMBER;
		l_attrib_tbl(1).value := l_bktv_rec.ibc_id;

    	okl_accounting_util.get_version(
								        p_attrib_tbl				=> l_attrib_tbl,
    							      	p_cur_version				=> l_bktv_rec.version,
                                    	p_end_date_attribute_name	=> 'END_DATE',
				                        p_end_date		            => l_bktv_rec.end_date,
                                      	p_view						=> 'OKL_BUCKETS_V',
  				                       x_return_status				=> l_return_status,
				                       x_new_version				=> l_new_version);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSE
	   	  l_bktv_rec.version := l_new_version;
       END IF;

	   l_bktv_rec.id := OKL_API.G_MISS_NUM;

	   -- call verify changes to update the database
	   IF l_bktv_rec.end_date > l_db_bktv_rec.end_date THEN
	   	  check_updates(p_upd_bktv_rec	=> l_upd_bktv_rec,
	   				    p_db_bktv_rec	=> l_db_bktv_rec,
					  	p_bktv_rec		=> l_bktv_rec,
					  	x_return_status => l_return_status,
					  	x_msg_data		=> x_msg_data);
       	  IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          	 RAISE OKL_API.G_EXCEPTION_ERROR;
       	  ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
	   END IF;

	/* public api to insert streamtype */
	      OKL_BUCKETS_PUB.INSERT_BUCKETS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => l_return_status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_bktv_rec        => l_bktv_rec,
    										   x_bktv_rec        => x_bktv_rec);

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

  END create_buckets;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_buckets for: OKL_BUCKETS_V
  ---------------------------------------------------------------------------
  PROCEDURE update_buckets(p_api_version                  IN  NUMBER,
                              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status                OUT NOCOPY VARCHAR2,
                              x_msg_count                    OUT NOCOPY NUMBER,
                              x_msg_data                     OUT NOCOPY VARCHAR2,
                              p_bktv_rec                     IN  bktv_rec_type,
                              x_bktv_rec                     OUT NOCOPY bktv_rec_type
                              ) IS
    l_api_version     	  	CONSTANT NUMBER := 1;
    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'update_buckets';
    l_no_data_found   	  	BOOLEAN := TRUE;
	l_valid			  	  	BOOLEAN := TRUE;
        -- viselvar fixed Bug 4016263. Changed to_date() to trunc(). Bug Fix Start
	l_oldversion_enddate  	DATE := trunc(SYSDATE);
	l_sysdate			  	DATE := trunc(SYSDATE);
        --Bug 4016263 Bug Fix end.
    l_db_bktv_rec    	  	bktv_rec_type; /* database copy */
	l_upd_bktv_rec	 	  	bktv_rec_type; /* input copy */
	l_bktv_rec	  	 	  	bktv_rec_type; /* latest with the retained changes */
	l_tmp_bktv_rec			bktv_rec_type; /* for any other purposes */
    l_return_status   	  	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_action				VARCHAR2(1);
	l_new_version			VARCHAR2(100);
    l_attrib_tbl	        okl_accounting_util.overlap_attrib_tbl_type;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
	l_upd_bktv_rec := p_bktv_rec;

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
/*
	-- retain the details that has been changed only
    get_rec(p_bktv_rec 	 	=> p_bktv_rec,
   			p_changes_only  => TRUE,
		    x_return_status => l_return_status,
			x_no_data_found => l_no_data_found,
    		x_bktv_rec		=> l_upd_bktv_rec);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	IF NOT l_no_data_found THEN
	-- check for start date greater than sysdate
	IF to_date(l_upd_bktv_rec.start_date, 'DD/MM/YYYY') <> to_date(OKL_API.G_MISS_DATE, 'DD/MM/YYYY') AND
	   to_date(l_upd_bktv_rec.start_date,'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_START_DATE);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

	-- check for end date greater than sysdate
	IF to_date(l_upd_bktv_rec.end_date, 'DD/MM/YYYY') <> to_date(OKL_API.G_MISS_DATE, 'DD/MM/YYYY') AND
	   to_date(l_upd_bktv_rec.end_date,'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_END_DATE);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
	-- fetch old details from the database
    get_rec(p_bktv_rec 	 	=> l_upd_bktv_rec,
		    x_return_status => l_return_status,
			x_no_data_found => l_no_data_found,
    		x_bktv_rec		=> l_db_bktv_rec);

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
--	   l_no_data_found = TRUE THEN
	   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	IF NOT l_no_data_found THEN
	-- check for the records if start and end dates are in the past
/*    IF to_date(l_db_bktv_rec.start_date,'DD/MM/YYYY') < l_sysdate AND
	   to_date(l_db_bktv_rec.end_date,'DD/MM/YYYY') < l_sysdate THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_PAST_RECORDS);
	   RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
*/
	   -- for old version
	   IF l_upd_bktv_rec.start_date <> OKL_API.G_MISS_DATE THEN
	   	  l_oldversion_enddate := l_upd_bktv_rec.start_date - 1;
	   ELSE
	   	  l_oldversion_enddate := l_sysdate - 1;
	   END IF;

	   l_bktv_rec := l_db_bktv_rec;
       -- if end date of old version is less than start date of old version, set end date to start date
	   -- this is to take care of records created and updated on the same start date.
       IF l_oldversion_enddate < l_bktv_rec.start_date THEN
	     l_bktv_rec.end_date := l_bktv_rec.start_date;
       ELSE
         l_bktv_rec.end_date := l_oldversion_enddate;
       END IF;

	   -- call verify changes to update the database
	   IF l_oldversion_enddate > l_db_bktv_rec.end_date THEN
	   	  check_updates(p_upd_bktv_rec	=> l_upd_bktv_rec,
	   			     	p_db_bktv_rec	=> l_db_bktv_rec,
					 	p_bktv_rec		=> l_bktv_rec,
					 	x_return_status => l_return_status,
					 	x_msg_data		=> x_msg_data);

       	  IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
       	  	 RAISE OKL_API.G_EXCEPTION_ERROR;
       	  ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
	   END IF;

	   -- public api to update buckets
	      OKL_BUCKETS_PUB.UPDATE_BUCKETS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => l_return_status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_bktv_rec        => l_bktv_rec,
    										   x_bktv_rec        => x_bktv_rec);

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   -- for new version
	   -- create a temporary record with all relevant details from db and upd records
	   l_bktv_rec := defaults_to_actuals(p_upd_bktv_rec => l_upd_bktv_rec,
	   					  				 p_db_bktv_rec  => l_db_bktv_rec);

	   IF l_upd_bktv_rec.start_date = OKL_API.G_MISS_DATE THEN
	   	  l_bktv_rec.start_date := l_sysdate;
	   END IF;

		l_attrib_tbl(1).attribute := 'ibc_id';
		l_attrib_tbl(1).attrib_type := okl_accounting_util.G_NUMBER;
		l_attrib_tbl(1).value := l_bktv_rec.ibc_id;

    	okl_accounting_util.get_version(
								        p_attrib_tbl				=> l_attrib_tbl,
    							      	p_cur_version				=> l_bktv_rec.version,
                                    	p_end_date_attribute_name	=> 'END_DATE',
				                        p_end_date		            => l_bktv_rec.end_date,
                                      	p_view						=> 'OKL_BUCKETS_V',
  				                       x_return_status				=> l_return_status,
				                       x_new_version				=> l_new_version);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSE
	   	  l_bktv_rec.version := l_new_version;
       END IF;

	   l_bktv_rec.id := OKL_API.G_MISS_NUM;

	   -- call verify changes to update the database
	   IF l_bktv_rec.end_date > l_db_bktv_rec.end_date THEN
	   	  check_updates(p_upd_bktv_rec	=> l_upd_bktv_rec,
	   				    p_db_bktv_rec	=> l_db_bktv_rec,
					  	p_bktv_rec		=> l_bktv_rec,
					  	x_return_status => l_return_status,
					  	x_msg_data		=> x_msg_data);
       	  IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          	 RAISE OKL_API.G_EXCEPTION_ERROR;
       	  ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
	   END IF;

	   -- public api to insert buckets
	      OKL_BUCKETS_PUB.INSERT_BUCKETS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => l_return_status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_bktv_rec        => l_bktv_rec,
    										   x_bktv_rec        => x_bktv_rec);

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   -- copy output to input structure to get the id
	   l_bktv_rec := x_bktv_rec;

       ELSE
        l_bktv_rec := p_bktv_rec;
        l_bktv_rec.id := OKL_API.G_MISS_NUM;
        l_bktv_rec.start_date := l_sysdate;
		l_bktv_rec.comments := OKL_API.G_MISS_CHAR;
        -- Get Version number
		l_attrib_tbl(1).attribute := 'ibc_id';
		l_attrib_tbl(1).attrib_type := okl_accounting_util.G_NUMBER;
		l_attrib_tbl(1).value := l_bktv_rec.ibc_id;

    	okl_accounting_util.get_version(
								        p_attrib_tbl				=> l_attrib_tbl,
    							      	p_cur_version				=> l_bktv_rec.version,
                                    	p_end_date_attribute_name	=> 'END_DATE',
				                        p_end_date		            => l_bktv_rec.end_date,
                                      	p_view						=> 'OKL_BUCKETS_V',
  				                       x_return_status				=> l_return_status,
				                       x_new_version				=> l_new_version);

       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSE
	   	  l_bktv_rec.version := l_new_version;
       END IF;

  	    -- public api to insert buckets
	      OKL_BUCKETS_PUB.INSERT_BUCKETS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => l_return_status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_bktv_rec        => l_bktv_rec,
    										   x_bktv_rec        => x_bktv_rec);

       IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
       	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;

	   -- copy output to input structure to get the id
	   l_bktv_rec := x_bktv_rec;

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

  END update_buckets;

  PROCEDURE create_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN  bktv_tbl_type,
    x_bktv_tbl                     OUT NOCOPY bktv_tbl_type)

	IS

	l_api_version NUMBER := 1.0;

	BEGIN

	      OKL_BUCKETS_PUB.INSERT_BUCKETS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => x_return_Status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_bktv_tbl        => p_bktv_tbl,
    										   x_bktv_tbl        => x_bktv_tbl);

	END create_buckets;

  PROCEDURE update_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN  bktv_tbl_type,
    x_bktv_tbl                     OUT NOCOPY bktv_tbl_type)

	IS
	l_api_version NUMBER := 1.0;

	BEGIN

	      OKL_BUCKETS_PUB.UPDATE_BUCKETS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => x_return_Status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_bktv_tbl        => p_bktv_tbl,
    										   x_bktv_tbl        => x_bktv_tbl);

	END update_buckets;


  PROCEDURE delete_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_rec                     IN  bktv_rec_type)

	IS
	l_api_version NUMBER := 1.0;

	BEGIN

	      OKL_BUCKETS_PUB.DELETE_BUCKETS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => x_return_Status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_bktv_rec        => p_bktv_rec);


  END delete_buckets;

  PROCEDURE delete_buckets(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bktv_tbl                     IN  bktv_tbl_type)

  IS

	l_api_version NUMBER := 1.0;

  BEGIN

	      OKL_BUCKETS_PUB.DELETE_BUCKETS(p_api_version     => l_api_version,
                                               p_init_msg_list   => p_init_msg_list,
    									       x_return_status   => x_return_Status,
    										   x_msg_count       => x_msg_count,
    										   x_msg_data        => x_msg_data,
    										   p_bktv_tbl        => p_bktv_tbl);

  END delete_buckets;


END OKL_PROCESS_BUCKETS_PVT;

/
