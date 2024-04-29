--------------------------------------------------------
--  DDL for Package Body OKL_POPULATE_PRCENG_RESULT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_POPULATE_PRCENG_RESULT_PUB" AS
/* $Header: OKLPPERB.pls 115.22 2004/04/13 10:55:44 rnaik noship $ */


   --------------------------------------------------------------------------------
   -- FUNCTION: feb_date
   -- This is a temporary fix for the wrong dates returned by SuperTrump e.g. 02/30
   -- The function parses the given date and if the date is 02/30 returns 02/29 or
   -- 02/28 if it is a leap year or not respectively.
   --------------------------------------------------------------------------------

   FUNCTION correct_feb_date (p_date VARCHAR2)
   RETURN VARCHAR2
   IS
       l_sre_date VARCHAR2(100);
       l_feb_date VARCHAR2(100);
       l_year     VARCHAR2(100);
   BEGIN
       l_sre_date := p_date;
       l_feb_date := SUBSTR(l_sre_date, 6,5);
       l_year     := SUBSTR(l_sre_date, 1,4);

   	IF(l_feb_date = '02-30' OR l_feb_date = '02-29') THEN
         l_feb_date := '02-28';
      	  IF MOD (TO_NUMBER(l_year), 4) = 0 THEN
   	  	IF (MOD (TO_NUMBER(l_year), 100) = 0) THEN
   		 	IF  (MOD (TO_NUMBER(l_year), 400) = 0) THEN
     		 	  l_feb_date := '02-29';
   			END IF;
   		ELSE
     		 	l_feb_date := '02-29';
   	    END IF;
         END IF;
      	  l_year     := SUBSTR(l_sre_date, 1,5);
   	  l_sre_date := l_year  || l_feb_date;
   	END IF;
   	RETURN l_sre_date;
   END correct_feb_date;



  ---------------------------------------------------------------------------
  -- PROCEDURE populate_sif_rets for: OKL_SIF_RETS_V
  ---------------------------------------------------------------------------
  PROCEDURE populate_sif_rets(p_api_version                  IN  NUMBER := 1.0,
                              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status                OUT NOCOPY VARCHAR2,
                              x_id                           OUT NOCOPY NUMBER,
                              p_transaction_number           IN NUMBER := OKC_API.G_MISS_NUM,
                              p_srt_code                     IN OKL_SIF_RETS.SRT_CODE%TYPE := OKC_API.G_MISS_CHAR,
                              p_effective_pre_tax_yield      IN NUMBER := OKC_API.G_MISS_NUM,
                              p_yield_name                   IN OKL_SIF_RETS.YIELD_NAME%TYPE := OKC_API.G_MISS_CHAR,
                              p_index_number                 IN NUMBER := OKC_API.G_MISS_NUM,
                              p_effective_after_tax_yield    IN NUMBER := OKC_API.G_MISS_NUM,
                              p_nominal_pre_tax_yield        IN NUMBER := OKC_API.G_MISS_NUM,
                              p_nominal_after_tax_yield      IN NUMBER := OKC_API.G_MISS_NUM,
                              p_implicit_interest_rate       IN NUMBER := OKC_API.G_MISS_NUM,
            				  p_date_processed               IN DATE

  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_rets';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_sirv_rec sirv_rec_type;
    x_sirv_rec sirv_rec_type;
    x_msg_data               VARCHAR2(400);
	x_msg_count  NUMBER ;


  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    l_sirv_rec.transaction_number := p_transaction_number;
    l_sirv_rec.srt_code := p_srt_code;

    l_sirv_rec.yield_name := p_yield_name;
    l_sirv_rec.index_number := p_index_number;

    IF(p_effective_pre_tax_yield = -100)
	THEN
	    l_sirv_rec.effective_after_tax_yield := NULL;
	ELSE
         l_sirv_rec.effective_pre_tax_yield := p_effective_pre_tax_yield;
	END IF;

	IF(p_effective_after_tax_yield = -100)
	THEN
	    l_sirv_rec.effective_after_tax_yield := NULL;
	ELSE
         l_sirv_rec.effective_after_tax_yield := p_effective_after_tax_yield;
	END IF;

	IF(p_nominal_pre_tax_yield = -100)
	THEN
	    l_sirv_rec.nominal_pre_tax_yield := NULL;
	ELSE
        l_sirv_rec.nominal_pre_tax_yield := p_nominal_pre_tax_yield;
	END IF;

	IF(p_nominal_after_tax_yield = -100)
	THEN
	    l_sirv_rec.nominal_after_tax_yield := NULL;
	ELSE
        l_sirv_rec.nominal_after_tax_yield := p_nominal_after_tax_yield;
	END IF;


--    l_sirv_rec.implicit_interest_rate := p_implicit_interest_rate;
    l_sirv_rec.implicit_interest_rate := NULL;
-- DATE TIME THIS TRANSACTION IS PROCESSED YYYYMMDD HH24MISS

  l_sirv_rec.date_processed :=   TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD HH24MISS'), 'YYYYMMDD HH24MISS');
--    l_sirv_rec.date_processed := p_date_processed;


    /* Call main API */
    Okl_Populate_Prceng_Result_Pvt.populate_sif_rets (p_api_version   => p_api_version,
                                                      p_init_msg_list => p_init_msg_list,
                                                      x_return_status => l_return_status,
                                                      x_msg_count     => x_msg_count,
                                                      x_msg_data      => x_msg_data,
                                                      p_sirv_rec      => l_sirv_rec,
                                                      x_sirv_rec      => x_sirv_rec);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign id returned to corresponding out parameter
    x_id := x_sirv_rec.id;
    -- Assign record returned by private api to local record
    l_sirv_rec := x_sirv_rec;



    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END populate_sif_rets;

-- mvasudev , 04/24/2002
  ---------------------------------------------------------------------------
  -- PROCEDURE populate_sif_rets for: OKL_SIF_RETS_V
  ---------------------------------------------------------------------------
  PROCEDURE populate_sif_rets(x_return_status                OUT NOCOPY VARCHAR2,
                              x_id                           OUT NOCOPY NUMBER,
                              p_transaction_number           IN NUMBER := OKC_API.G_MISS_NUM,
                              p_srt_code                     IN OKL_SIF_RETS.SRT_CODE%TYPE := OKC_API.G_MISS_CHAR,
                              p_effective_pre_tax_yield      IN NUMBER := OKC_API.G_MISS_NUM,
                              p_yield_name                   IN OKL_SIF_RETS.YIELD_NAME%TYPE := OKC_API.G_MISS_CHAR,
                              p_index_number                 IN NUMBER := OKC_API.G_MISS_NUM,
                              p_effective_after_tax_yield    IN NUMBER := OKC_API.G_MISS_NUM,
                              p_nominal_pre_tax_yield        IN NUMBER := OKC_API.G_MISS_NUM,
                              p_nominal_after_tax_yield      IN NUMBER := OKC_API.G_MISS_NUM,
                              p_implicit_interest_rate       IN NUMBER := OKC_API.G_MISS_NUM,
            				  p_date_processed               IN DATE

  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_rets';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_sirv_rec sirv_rec_type;
    x_sirv_rec sirv_rec_type;
    x_msg_data               VARCHAR2(400);
	x_msg_count  NUMBER ;

	l_init_msg_list       VARCHAR2(1) := 'F';


  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => l_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => l_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    l_sirv_rec.transaction_number := p_transaction_number;
    l_sirv_rec.srt_code := p_srt_code;

    l_sirv_rec.yield_name := p_yield_name;
    l_sirv_rec.index_number := p_index_number;

    IF(p_effective_pre_tax_yield = -100)
	THEN
	    l_sirv_rec.effective_after_tax_yield := NULL;
	ELSE
         l_sirv_rec.effective_pre_tax_yield := p_effective_pre_tax_yield;
	END IF;

	IF(p_effective_after_tax_yield = -100)
	THEN
	    l_sirv_rec.effective_after_tax_yield := NULL;
	ELSE
         l_sirv_rec.effective_after_tax_yield := p_effective_after_tax_yield;
	END IF;

	IF(p_nominal_pre_tax_yield = -100)
	THEN
	    l_sirv_rec.nominal_pre_tax_yield := NULL;
	ELSE
        l_sirv_rec.nominal_pre_tax_yield := p_nominal_pre_tax_yield;
	END IF;

	IF(p_nominal_after_tax_yield = -100)
	THEN
	    l_sirv_rec.nominal_after_tax_yield := NULL;
	ELSE
        l_sirv_rec.nominal_after_tax_yield := p_nominal_after_tax_yield;
	END IF;


--    l_sirv_rec.implicit_interest_rate := p_implicit_interest_rate;
    l_sirv_rec.implicit_interest_rate := NULL;
-- DATE TIME THIS TRANSACTION IS PROCESSED YYYYMMDD HH24MISS

  l_sirv_rec.date_processed :=   TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD HH24MISS'), 'YYYYMMDD HH24MISS');
--    l_sirv_rec.date_processed := p_date_processed;


    /* Call main API */
    Okl_Populate_Prceng_Result_Pvt.populate_sif_rets (p_api_version   => l_api_version,
                                                      p_init_msg_list => l_init_msg_list,
                                                      x_return_status => l_return_status,
                                                      x_msg_count     => x_msg_count,
                                                      x_msg_data      => x_msg_data,
                                                      p_sirv_rec      => l_sirv_rec,
                                                      x_sirv_rec      => x_sirv_rec);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign id returned to corresponding out parameter
    x_id := x_sirv_rec.id;
    -- Assign record returned by private api to local record
    l_sirv_rec := x_sirv_rec;



    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END populate_sif_rets;
-- mvasudev , 04/24/2002 end

  ----------------------------------------------------------------------------------------
  -- PROCEUDRE populate_sif_rets
  ----------------------------------------------------------------------------------------

  PROCEDURE populate_sif_rets(p_api_version                  IN  NUMBER := 1.0,
                              p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status                OUT NOCOPY VARCHAR2,
                              x_id                           OUT NOCOPY NUMBER,
                              p_transaction_number           IN NUMBER := OKC_API.G_MISS_NUM,
                              p_srt_code                     IN OKL_SIF_RETS.SRT_CODE%TYPE := OKC_API.G_MISS_CHAR,
                              p_effective_pre_tax_yield      IN NUMBER := OKC_API.G_MISS_NUM,
                              p_yield_name                   IN OKL_SIF_RETS.YIELD_NAME%TYPE := OKC_API.G_MISS_CHAR,
                              p_index_number                 IN NUMBER := OKC_API.G_MISS_NUM,
                              p_effective_after_tax_yield    IN NUMBER := OKC_API.G_MISS_NUM,
                              p_nominal_pre_tax_yield        IN NUMBER := OKC_API.G_MISS_NUM,
                              p_nominal_after_tax_yield      IN NUMBER := OKC_API.G_MISS_NUM,
                              p_implicit_interest_rate       IN NUMBER := OKC_API.G_MISS_NUM
  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_rets';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_sirv_rec sirv_rec_type;
    x_sirv_rec sirv_rec_type;
    x_msg_data               VARCHAR2(400);
	x_msg_count  NUMBER ;


  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    l_sirv_rec.transaction_number := p_transaction_number;
    l_sirv_rec.srt_code := p_srt_code;

    l_sirv_rec.yield_name := p_yield_name;
    l_sirv_rec.index_number := p_index_number;

	IF(p_effective_pre_tax_yield = -100)
	THEN
	    l_sirv_rec.effective_after_tax_yield := NULL;
	ELSE
         l_sirv_rec.effective_pre_tax_yield := p_effective_pre_tax_yield;
	END IF;

	IF(p_effective_after_tax_yield = -100)
	THEN
	    l_sirv_rec.effective_after_tax_yield := NULL;
	ELSE
         l_sirv_rec.effective_after_tax_yield := p_effective_after_tax_yield;
	END IF;

	IF(p_nominal_pre_tax_yield = -100)
	THEN
	    l_sirv_rec.nominal_pre_tax_yield := NULL;
	ELSE
        l_sirv_rec.nominal_pre_tax_yield := p_nominal_pre_tax_yield;
	END IF;

	IF(p_nominal_after_tax_yield = -100)
	THEN
	    l_sirv_rec.nominal_after_tax_yield := NULL;
	ELSE
        l_sirv_rec.nominal_after_tax_yield := p_nominal_after_tax_yield;
	END IF;

/*
    l_sirv_rec.effective_after_tax_yield := p_effective_after_tax_yield;
    l_sirv_rec.nominal_pre_tax_yield := p_nominal_pre_tax_yield;
    l_sirv_rec.nominal_after_tax_yield := p_nominal_after_tax_yield;
	l_sirv_rec.effective_pre_tax_yield := p_effective_pre_tax_yield;
	*/
--    l_sirv_rec.implicit_interest_rate := p_implicit_interest_rate;
    	l_sirv_rec.implicit_interest_rate := NULL;
-- DATE TIME THIS TRANSACTION IS PROCESSED YYYYMMDD HH24MISS

  l_sirv_rec.date_processed :=   TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD HH24MISS'), 'YYYYMMDD HH24MISS');


    /* Call main API */
    Okl_Populate_Prceng_Result_Pvt.populate_sif_rets (p_api_version   => p_api_version,
                                                      p_init_msg_list => p_init_msg_list,
                                                      x_return_status => l_return_status,
                                                      x_msg_count     => x_msg_count,
                                                      x_msg_data      => x_msg_data,
                                                      p_sirv_rec      => l_sirv_rec,
                                                      x_sirv_rec      => x_sirv_rec);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign id returned to corresponding out parameter
    x_id := x_sirv_rec.id;
    -- Assign record returned by private api to local record
    l_sirv_rec := x_sirv_rec;



    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END populate_sif_rets;

-- mvasudev , 04/24/2002
  ----------------------------------------------------------------------------------------
  -- PROCEUDRE populate_sif_rets
  ----------------------------------------------------------------------------------------

  PROCEDURE populate_sif_rets(x_return_status                OUT NOCOPY VARCHAR2,
                              x_id                           OUT NOCOPY NUMBER,
                              p_transaction_number           IN NUMBER := OKC_API.G_MISS_NUM,
                              p_srt_code                     IN OKL_SIF_RETS.SRT_CODE%TYPE := OKC_API.G_MISS_CHAR,
                              p_effective_pre_tax_yield      IN NUMBER := OKC_API.G_MISS_NUM,
                              p_yield_name                   IN OKL_SIF_RETS.YIELD_NAME%TYPE := OKC_API.G_MISS_CHAR,
                              p_index_number                 IN NUMBER := OKC_API.G_MISS_NUM,
                              p_effective_after_tax_yield    IN NUMBER := OKC_API.G_MISS_NUM,
                              p_nominal_pre_tax_yield        IN NUMBER := OKC_API.G_MISS_NUM,
                              p_nominal_after_tax_yield      IN NUMBER := OKC_API.G_MISS_NUM,
                              p_implicit_interest_rate       IN NUMBER := OKC_API.G_MISS_NUM
  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_rets';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_sirv_rec sirv_rec_type;
    x_sirv_rec sirv_rec_type;
    x_msg_data               VARCHAR2(400);
	x_msg_count  NUMBER ;

	l_init_msg_list       VARCHAR2(1) := 'F';


  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => l_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => l_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    l_sirv_rec.transaction_number := p_transaction_number;
    l_sirv_rec.srt_code := p_srt_code;

    l_sirv_rec.yield_name := p_yield_name;
    l_sirv_rec.index_number := p_index_number;

	IF(p_effective_pre_tax_yield = -100)
	THEN
	    l_sirv_rec.effective_after_tax_yield := NULL;
	ELSE
         l_sirv_rec.effective_pre_tax_yield := p_effective_pre_tax_yield;
	END IF;

	IF(p_effective_after_tax_yield = -100)
	THEN
	    l_sirv_rec.effective_after_tax_yield := NULL;
	ELSE
         l_sirv_rec.effective_after_tax_yield := p_effective_after_tax_yield;
	END IF;

	IF(p_nominal_pre_tax_yield = -100)
	THEN
	    l_sirv_rec.nominal_pre_tax_yield := NULL;
	ELSE
        l_sirv_rec.nominal_pre_tax_yield := p_nominal_pre_tax_yield;
	END IF;

	IF(p_nominal_after_tax_yield = -100)
	THEN
	    l_sirv_rec.nominal_after_tax_yield := NULL;
	ELSE
        l_sirv_rec.nominal_after_tax_yield := p_nominal_after_tax_yield;
	END IF;

/*
    l_sirv_rec.effective_after_tax_yield := p_effective_after_tax_yield;
    l_sirv_rec.nominal_pre_tax_yield := p_nominal_pre_tax_yield;
    l_sirv_rec.nominal_after_tax_yield := p_nominal_after_tax_yield;
	l_sirv_rec.effective_pre_tax_yield := p_effective_pre_tax_yield;
	*/
--    l_sirv_rec.implicit_interest_rate := p_implicit_interest_rate;
    	l_sirv_rec.implicit_interest_rate := NULL;
-- DATE TIME THIS TRANSACTION IS PROCESSED YYYYMMDD HH24MISS

  l_sirv_rec.date_processed :=   TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD HH24MISS'), 'YYYYMMDD HH24MISS');


    /* Call main API */
    Okl_Populate_Prceng_Result_Pvt.populate_sif_rets (p_api_version   => l_api_version,
                                                      p_init_msg_list => l_init_msg_list,
                                                      x_return_status => l_return_status,
                                                      x_msg_count     => x_msg_count,
                                                      x_msg_data      => x_msg_data,
                                                      p_sirv_rec      => l_sirv_rec,
                                                      x_sirv_rec      => x_sirv_rec);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign id returned to corresponding out parameter
    x_id := x_sirv_rec.id;
    -- Assign record returned by private api to local record
    l_sirv_rec := x_sirv_rec;



    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END populate_sif_rets;
-- mvasudev, 04/24/2002 end




  -- Added by saran

  PROCEDURE update_sif_rets (p_api_version                  IN  NUMBER := 1.0,
                             p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status                OUT NOCOPY VARCHAR2,
                             p_id                             IN NUMBER,
                             p_implicit_interest_rate         IN NUMBER := OKC_API.G_MISS_NUM)
  IS
    l_api_name  CONSTANT VARCHAR2(30) := 'update_sif_rets';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_sirv_rec sirv_rec_type;
    x_sirv_rec sirv_rec_type;
    x_msg_data               VARCHAR2(400);
	x_msg_count  NUMBER ;


  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    l_sirv_rec.id := p_id;
    l_sirv_rec.implicit_interest_rate := p_implicit_interest_rate;



    /* Call main API */
    Okl_Populate_Prceng_Result_Pvt.update_sif_rets(p_api_version   => p_api_version,
                                                      p_init_msg_list => p_init_msg_list,
                                                      x_return_status => l_return_status,
                                                      x_msg_count     => x_msg_count,
                                                      x_msg_data      => x_msg_data,
                                                      p_sirv_rec      => l_sirv_rec,
                                                      x_sirv_rec      => x_sirv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign record returned by private api to local record
    l_sirv_rec := x_sirv_rec;


    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END update_sif_rets;

-- mvasudev, 04/24/2002
  PROCEDURE update_sif_rets (x_return_status                OUT NOCOPY VARCHAR2,
                             p_id                             IN NUMBER,
                             p_implicit_interest_rate         IN NUMBER := OKC_API.G_MISS_NUM)
  IS
    l_api_name  CONSTANT VARCHAR2(30) := 'update_sif_rets';

    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_sirv_rec sirv_rec_type;
    x_sirv_rec sirv_rec_type;
    x_msg_data               VARCHAR2(400);
	x_msg_count  NUMBER ;

	l_init_msg_list       VARCHAR2(1) := 'F';
    l_api_version     CONSTANT NUMBER := 1;

  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => l_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => l_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    l_sirv_rec.id := p_id;
    l_sirv_rec.implicit_interest_rate := p_implicit_interest_rate;



    /* Call main API */
    Okl_Populate_Prceng_Result_Pvt.update_sif_rets(p_api_version   => l_api_version,
                                                      p_init_msg_list => l_init_msg_list,
                                                      x_return_status => l_return_status,
                                                      x_msg_count     => x_msg_count,
                                                      x_msg_data      => x_msg_data,
                                                      p_sirv_rec      => l_sirv_rec,
                                                      x_sirv_rec      => x_sirv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign record returned by private api to local record
    l_sirv_rec := x_sirv_rec;


    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END update_sif_rets;
-- mvasudev  , 04/24/2002 end

  ----------------------------------------------------------------------------------
  -- PROCEDURE update_sif_rets
  ----------------------------------------------------------------------------------
  PROCEDURE update_sif_rets (p_api_version        IN NUMBER := 1.0,
                             p_init_msg_list      IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             p_id                 IN NUMBER,
                             p_yield_name         IN VARCHAR2,
							 p_amount             IN NUMBER,
                             x_return_status      OUT NOCOPY VARCHAR2)
  IS
    l_api_name  CONSTANT VARCHAR2(30) := 'update_sif_rets';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_sirv_rec sirv_rec_type;
    lx_sirv_rec sirv_rec_type;
    lx_msg_data               VARCHAR2(400);
	lx_msg_count  NUMBER ;

  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    l_sirv_rec.id := p_id;
    l_sirv_rec.effective_pre_tax_yield := p_amount;
    l_sirv_rec.yield_name := p_yield_name;



    /* Call main API */
    Okl_Populate_Prceng_Result_Pvt.update_sif_rets(p_api_version   => p_api_version,
                                                   p_init_msg_list => p_init_msg_list,
                                                   x_return_status => l_return_status,
                                                   x_msg_count     => lx_msg_count,
                                                   x_msg_data      => lx_msg_data,
                                                   p_sirv_rec      => l_sirv_rec,
                                                   x_sirv_rec      => lx_sirv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign record returned by private api to local record
    l_sirv_rec := lx_sirv_rec;


    OKL_API.END_ACTIVITY(x_msg_count  => lx_msg_count,
						 x_msg_data	  => lx_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
  END update_sif_rets;

-- mvasudev , 04/24/2002
  ----------------------------------------------------------------------------------
  -- PROCEDURE update_sif_rets
  ----------------------------------------------------------------------------------
  PROCEDURE update_sif_rets (p_id                 IN NUMBER,
                             p_yield_name         IN VARCHAR2,
							 p_amount             IN NUMBER,
                             x_return_status      OUT NOCOPY VARCHAR2)
  IS
    l_api_name  CONSTANT VARCHAR2(30) := 'update_sif_rets';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_sirv_rec sirv_rec_type;
    lx_sirv_rec sirv_rec_type;
    lx_msg_data               VARCHAR2(400);
	lx_msg_count  NUMBER ;

	l_init_msg_list       VARCHAR2(1) := 'F';


  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => l_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => l_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    l_sirv_rec.id := p_id;
    l_sirv_rec.effective_pre_tax_yield := p_amount;
    l_sirv_rec.yield_name := p_yield_name;



    /* Call main API */
    Okl_Populate_Prceng_Result_Pvt.update_sif_rets(p_api_version   => l_api_version,
                                                   p_init_msg_list => l_init_msg_list,
                                                   x_return_status => l_return_status,
                                                   x_msg_count     => lx_msg_count,
                                                   x_msg_data      => lx_msg_data,
                                                   p_sirv_rec      => l_sirv_rec,
                                                   x_sirv_rec      => lx_sirv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign record returned by private api to local record
    l_sirv_rec := lx_sirv_rec;


    OKL_API.END_ACTIVITY(x_msg_count  => lx_msg_count,
						 x_msg_data	  => lx_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
  END update_sif_rets;
-- mvasudev, 04/24/2002 end

  ---------------------------------------------------------------------------
  -- PROCEDURE populate_sif_ret_strms for: OKL_SIF_RET_STREAMS_V
  ---------------------------------------------------------------------------

  PROCEDURE populate_sif_ret_strms (x_return_status       OUT NOCOPY VARCHAR2,
                                    p_stream_type_name    IN OKL_SIF_RET_STRMS.STREAM_TYPE_NAME%TYPE := OKC_API.G_MISS_CHAR,
                                 	p_description         IN VARCHAR2 := OKC_API.G_MISS_CHAR,
                                    p_index_number        IN NUMBER := OKC_API.G_MISS_NUM,
                                    p_sre_date            IN  VARCHAR2 := OKC_API.G_MISS_CHAR,
                                    p_amount              IN NUMBER := OKC_API.G_MISS_NUM,
                                    p_sir_id              IN NUMBER := OKC_API.G_MISS_NUM
  ) IS

    p_api_version         NUMBER := 1.0;
    x_id                  NUMBER;
	p_activity_type       OKL_SIF_RET_STRMS.ACTIVITY_TYPE%TYPE := OKC_API.G_MISS_CHAR;
	p_se_line_number      NUMBER := 1;
	p_init_msg_list       VARCHAR2(1) := 'F';

    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_ret_strms';
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_srsv_rec srsv_rec_type;
    l_api_version     CONSTANT NUMBER := 1;

    x_srsv_rec srsv_rec_type;
    x_msg_data               VARCHAR2(400);
    x_msg_count  NUMBER ;
    l_sre_date   VARCHAR2(30);

  BEGIN
    --dbms_output.put_line('populate_sif_ret_strms start pub');
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;
    --dbms_output.put_line('populate_sif_ret_strms aft savepoint pub');

    IF(p_description =   'Residual Insurance Premium')
    THEN
       l_srsv_rec.stream_type_name := 'RESIDUAL VALUE INSURANCE PREMIUM';

	ELSIF ( p_description = 'NODESC' OR p_description = 'TEMPVALUE')

	THEN
    	l_srsv_rec.stream_type_name := p_stream_type_name;
	ELSE
	    l_srsv_rec.stream_type_name := p_description;
	END IF;

    -- IF the index number is not returned from SuperTrump
	-- -100 is the default value for Index Number
    IF (p_index_number = -100)
	THEN
	l_srsv_rec.index_number := NULL;
	ELSE
    l_srsv_rec.index_number := p_index_number;
	END IF;
    l_srsv_rec.activity_type := p_activity_type;
--    l_srsv_rec.sequence_number := sequence_number;
    l_srsv_rec.sequence_number := p_se_line_number;
--    l_srsv_rec.sre_date := p_sre_date;
-- TBD
-- CHECK FOR THE DATE FORMAT
--dbms_output.put_line('populate_sif_ret_strms bef date conv pub '||p_sre_date);

-- TEMP FIX FOR 02/30 DATES

    l_sre_date := p_sre_date;
    l_sre_date := correct_feb_date(l_sre_date);

    l_srsv_rec.sre_date := TO_DATE(l_sre_date, 'YYYY-MM-DD');
    l_srsv_rec.amount := p_amount;
    l_srsv_rec.sir_id := p_sir_id;

  	--DBMS_OUTPUT.PUT_LINE('INSIDE PUB  Procedure 4' );
    /* Call main API */
    Okl_Populate_Prceng_Result_Pvt.populate_sif_ret_strms (p_api_version => p_api_version,
                                                           p_init_msg_list => p_init_msg_list,
                                                           x_return_status => l_return_status,
                                                           x_msg_count => x_msg_count,
                                                           x_msg_data => x_msg_data,
                                                           p_srsv_rec => l_srsv_rec,
                                                           x_srsv_rec => x_srsv_rec);

  	--DBMS_OUTPUT.PUT_LINE('INSIDE PUB  Procedure 5' || l_return_status);
	FOR i IN 1..x_msg_count
LOOP
     fnd_msg_pub.get(p_data => x_msg_data,
		        p_msg_index_out => x_msg_count,
			    p_encoded => 'F',
    		    p_msg_index => fnd_msg_pub.g_next
	          );
--DBMS_OUTPUT.PUT_LINE('l_msg_text = ' || x_msg_data);
END LOOP;


    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign id returned to corresponding out parameter
    x_id := x_srsv_rec.id;
    -- Assign record returned by private api to local record
    l_srsv_rec := x_srsv_rec;


    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END populate_sif_ret_strms;

  ---------------------------------------------------------------------------
  -- PROCEDURE populate_sif_ret_strms for: OKL_SIF_RET_STREAMS_V
  ---------------------------------------------------------------------------

  PROCEDURE populate_sif_ret_strms (p_api_version         IN  NUMBER := 1.0,
                                    p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status       OUT NOCOPY VARCHAR2,
                                    x_id                  OUT NOCOPY NUMBER,
                                    p_stream_type_name    IN OKL_SIF_RET_STRMS.STREAM_TYPE_NAME%TYPE := OKC_API.G_MISS_CHAR,
                                 	p_description         IN VARCHAR2 := OKC_API.G_MISS_CHAR,
                                    p_index_number        IN NUMBER := OKC_API.G_MISS_NUM,
                                    p_activity_type       IN OKL_SIF_RET_STRMS.ACTIVITY_TYPE%TYPE := OKC_API.G_MISS_CHAR,
                                    p_se_line_number      IN NUMBER := OKC_API.G_MISS_NUM,
                                    p_sre_date            IN  VARCHAR2 := OKC_API.G_MISS_CHAR,
                                    p_amount              IN NUMBER := OKC_API.G_MISS_NUM,
                                    p_sir_id              IN NUMBER := OKC_API.G_MISS_NUM
  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_ret_strms';
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_srsv_rec srsv_rec_type;
    l_api_version     CONSTANT NUMBER := 1;

    x_srsv_rec srsv_rec_type;
    x_msg_data               VARCHAR2(400);
    x_msg_count  NUMBER ;
    l_sre_date   VARCHAR2(30);

  BEGIN
    --dbms_output.put_line('populate_sif_ret_strms start pub');
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;
    --dbms_output.put_line('populate_sif_ret_strms aft savepoint pub');

    IF(p_description =   'Residual Insurance Premium')
    THEN
       l_srsv_rec.stream_type_name := 'RESIDUAL VALUE INSURANCE PREMIUM';

	ELSIF ( p_description = 'NODESC' OR p_description = 'TEMPVALUE')

	THEN
    	l_srsv_rec.stream_type_name := p_stream_type_name;
	ELSE
	    l_srsv_rec.stream_type_name := p_description;
	END IF;

    -- IF the index number is not returned from SuperTrump
	-- -100 is the default value for Index Number
    IF (p_index_number = -100)
	THEN
	l_srsv_rec.index_number := NULL;
	ELSE
    l_srsv_rec.index_number := p_index_number;
	END IF;
    l_srsv_rec.activity_type := p_activity_type;
--    l_srsv_rec.sequence_number := sequence_number;
    l_srsv_rec.sequence_number := p_se_line_number;
--    l_srsv_rec.sre_date := p_sre_date;
-- TBD
-- CHECK FOR THE DATE FORMAT
--dbms_output.put_line('populate_sif_ret_strms bef date conv pub '||p_sre_date);

-- TEMP FIX FOR 02/30 DATES

    l_sre_date := p_sre_date;
    l_sre_date := correct_feb_date(l_sre_date);

    l_srsv_rec.sre_date := TO_DATE(l_sre_date, 'YYYY-MM-DD');
    l_srsv_rec.amount := p_amount;
    l_srsv_rec.sir_id := p_sir_id;

  	--DBMS_OUTPUT.PUT_LINE('INSIDE PUB  Procedure 4' );
    /* Call main API */
    Okl_Populate_Prceng_Result_Pvt.populate_sif_ret_strms (p_api_version => p_api_version,
                                                           p_init_msg_list => p_init_msg_list,
                                                           x_return_status => l_return_status,
                                                           x_msg_count => x_msg_count,
                                                           x_msg_data => x_msg_data,
                                                           p_srsv_rec => l_srsv_rec,
                                                           x_srsv_rec => x_srsv_rec);

  	--DBMS_OUTPUT.PUT_LINE('INSIDE PUB  Procedure 5' || l_return_status);
	FOR i IN 1..x_msg_count
LOOP
     fnd_msg_pub.get(p_data => x_msg_data,
		        p_msg_index_out => x_msg_count,
			    p_encoded => 'F',
    		    p_msg_index => fnd_msg_pub.g_next
	          );
--DBMS_OUTPUT.PUT_LINE('l_msg_text = ' || x_msg_data);
END LOOP;


    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign id returned to corresponding out parameter
    x_id := x_srsv_rec.id;
    -- Assign record returned by private api to local record
    l_srsv_rec := x_srsv_rec;


    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END populate_sif_ret_strms;

  ---------------------------------------------------------------------------
  -- PROCEDURE populate_sif_ret_strms for: OKL_SIF_RET_STREAMS_V
  ---------------------------------------------------------------------------

  PROCEDURE populate_sif_ret_strms (p_api_version           IN  NUMBER := 1.0,
                                    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status         OUT NOCOPY VARCHAR2,
                                    x_id                    OUT NOCOPY NUMBER,
                                    p_stream_type_name      IN OKL_SIF_RET_STRMS.STREAM_TYPE_NAME%TYPE := OKC_API.G_MISS_CHAR,
                                    p_index_number          IN NUMBER := OKC_API.G_MISS_NUM,
                                    p_activity_type         IN OKL_SIF_RET_STRMS.ACTIVITY_TYPE%TYPE := OKC_API.G_MISS_CHAR,
                                    p_se_line_number        IN NUMBER := OKC_API.G_MISS_NUM,
                                    p_sre_date              IN OKL_SIF_RET_STRMS.SRE_DATE%TYPE := OKC_API.G_MISS_DATE,
                                    p_amount                IN NUMBER := OKC_API.G_MISS_NUM,
                                    p_sir_id                IN NUMBER := OKC_API.G_MISS_NUM
  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_ret_strms';
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_srsv_rec srsv_rec_type;
    l_api_version     CONSTANT NUMBER := 1;

    x_srsv_rec srsv_rec_type;
    x_msg_data               VARCHAR2(400);
    x_msg_count  NUMBER ;

  BEGIN
  	--DBMS_OUTPUT.PUT_LINE('INSIDE PUB  Procedure ');
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;
  	--DBMS_OUTPUT.PUT_LINE('INSIDE PUB  Procedure 2');
    l_srsv_rec.stream_type_name := p_stream_type_name;
    l_srsv_rec.index_number := p_index_number;
    l_srsv_rec.activity_type := p_activity_type;
    l_srsv_rec.sequence_number := p_se_line_number;
    l_srsv_rec.sre_date := p_sre_date;

    l_srsv_rec.amount := p_amount;
    l_srsv_rec.sir_id := p_sir_id;
  	--DBMS_OUTPUT.PUT_LINE('INSIDE PUB  Procedure 3');


    /* Call main API */
	  	--DBMS_OUTPUT.PUT_LINE('INSIDE PUB  Procedure 4');
    Okl_Populate_Prceng_Result_Pvt.populate_sif_ret_strms (p_api_version => p_api_version,
                                                           p_init_msg_list => p_init_msg_list,
                                                           x_return_status => l_return_status,
                                                           x_msg_count => x_msg_count,
                                                           x_msg_data => x_msg_data,
                                                           p_srsv_rec => l_srsv_rec,
                                                           x_srsv_rec => x_srsv_rec);
  	--DBMS_OUTPUT.PUT_LINE('INSIDE PUB  Procedure 5' || l_return_status);
	FOR i IN 1..x_msg_count
LOOP
     fnd_msg_pub.get(p_data => x_msg_data,
		        p_msg_index_out => x_msg_count,
			    p_encoded => 'F',
    		    p_msg_index => fnd_msg_pub.g_next
	          );
--DBMS_OUTPUT.PUT_LINE('l_msg_text = ' || x_msg_data);
END LOOP;
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign id returned to corresponding out parameter
    x_id := x_srsv_rec.id;
    -- Assign record returned by private api to local record
    l_srsv_rec := x_srsv_rec;


    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END populate_sif_ret_strms;




  ---------------------------------------------------------------------------
  -- PROCEDURE populate_sif_ret_errors for: OKL_SIF_RET_ERRORS_V
  ---------------------------------------------------------------------------

  PROCEDURE populate_sif_ret_errors (p_api_version            IN  NUMBER := 1.0,
                                     p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                     x_return_status          OUT NOCOPY VARCHAR2,
                                     x_id                     OUT NOCOPY NUMBER,
                                     p_sir_id                 IN NUMBER := OKC_API.G_MISS_NUM,
                                     p_error_code             IN OKL_SIF_RET_ERRORS.ERROR_CODE%TYPE := OKC_API.G_MISS_CHAR,
                                     p_error_message          IN OKL_SIF_RET_ERRORS.ERROR_MESSAGE%TYPE := OKC_API.G_MISS_CHAR,
                                     p_tag_name               IN OKL_SIF_RET_ERRORS.TAG_NAME%TYPE := OKC_API.G_MISS_CHAR,
                                     p_tag_attribute_name     IN OKL_SIF_RET_ERRORS.TAG_ATTRIBUTE_NAME%TYPE := OKC_API.G_MISS_CHAR,
                                     p_tag_attribute_value    IN OKL_SIF_RET_ERRORS.TAG_ATTRIBUTE_VALUE%TYPE := OKC_API.G_MISS_CHAR,
                                     p_description            IN OKL_SIF_RET_ERRORS.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_ret_errors';
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_srmv_rec srmv_rec_type;
    l_api_version     CONSTANT NUMBER := 1;
    x_srmv_rec srmv_rec_type;
    x_msg_data               VARCHAR2(400);
    x_msg_count  NUMBER ;

  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    l_srmv_rec.sir_id := p_sir_id;
    l_srmv_rec.error_code := p_error_code;
    l_srmv_rec.error_message := p_error_message;
    l_srmv_rec.tag_name := p_tag_name;
    IF(p_tag_attribute_name = 'TEMPVALUE')
	THEN
    	l_srmv_rec.tag_attribute_name := NULL;
	ELSE
        l_srmv_rec.tag_attribute_name := p_tag_attribute_name;
	END IF;
	IF(p_tag_attribute_value = 'TEMPVALUE')
	THEN
	    l_srmv_rec.tag_attribute_value := NULL;
	ELSE
    	l_srmv_rec.tag_attribute_value := p_tag_attribute_value;
	END IF;
    IF(p_description = 'TEMPVALUE')
	THEN
        l_srmv_rec.description := NULL;
	ELSE
    l_srmv_rec.description := p_description;
	END IF;



    /* Call main API */
    Okl_Populate_Prceng_Result_Pvt.populate_sif_ret_errors(p_api_version   => p_api_version,
                                                           p_init_msg_list => p_init_msg_list,
                                                           x_return_status => l_return_status,
                                                           x_msg_count     => x_msg_count,
                                                           x_msg_data      => x_msg_data,
                                                           p_srmv_rec      => l_srmv_rec,
                                                           x_srmv_rec      => x_srmv_rec);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign id returned to corresponding out parameter
    x_id := x_srmv_rec.id;
    -- Assign record returned by private api to local record
    l_srmv_rec := x_srmv_rec;


    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END populate_sif_ret_errors;

-- mvasudev , 04/24/2002
  ---------------------------------------------------------------------------
  -- PROCEDURE populate_sif_ret_errors for: OKL_SIF_RET_ERRORS_V
  ---------------------------------------------------------------------------

  PROCEDURE populate_sif_ret_errors (x_return_status          OUT NOCOPY VARCHAR2,
                                     x_id                     OUT NOCOPY NUMBER,
                                     p_sir_id                 IN NUMBER := OKC_API.G_MISS_NUM,
                                     p_error_code             IN OKL_SIF_RET_ERRORS.ERROR_CODE%TYPE := OKC_API.G_MISS_CHAR,
                                     p_error_message          IN OKL_SIF_RET_ERRORS.ERROR_MESSAGE%TYPE := OKC_API.G_MISS_CHAR,
                                     p_tag_name               IN OKL_SIF_RET_ERRORS.TAG_NAME%TYPE := OKC_API.G_MISS_CHAR,
                                     p_tag_attribute_name     IN OKL_SIF_RET_ERRORS.TAG_ATTRIBUTE_NAME%TYPE := OKC_API.G_MISS_CHAR,
                                     p_tag_attribute_value    IN OKL_SIF_RET_ERRORS.TAG_ATTRIBUTE_VALUE%TYPE := OKC_API.G_MISS_CHAR,
                                     p_description            IN OKL_SIF_RET_ERRORS.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_ret_errors';
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_srmv_rec srmv_rec_type;
    l_api_version     CONSTANT NUMBER := 1;
    x_srmv_rec srmv_rec_type;
    x_msg_data               VARCHAR2(400);
    x_msg_count  NUMBER ;

	l_init_msg_list       VARCHAR2(1) := 'F';


  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => l_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => l_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    l_srmv_rec.sir_id := p_sir_id;
    l_srmv_rec.error_code := p_error_code;
    l_srmv_rec.error_message := p_error_message;
    l_srmv_rec.tag_name := p_tag_name;
    IF(p_tag_attribute_name = 'TEMPVALUE')
	THEN
    	l_srmv_rec.tag_attribute_name := NULL;
	ELSE
        l_srmv_rec.tag_attribute_name := p_tag_attribute_name;
	END IF;
	IF(p_tag_attribute_value = 'TEMPVALUE')
	THEN
	    l_srmv_rec.tag_attribute_value := NULL;
	ELSE
    	l_srmv_rec.tag_attribute_value := p_tag_attribute_value;
	END IF;
    IF(p_description = 'TEMPVALUE')
	THEN
        l_srmv_rec.description := NULL;
	ELSE
    l_srmv_rec.description := p_description;
	END IF;



    /* Call main API */
    Okl_Populate_Prceng_Result_Pvt.populate_sif_ret_errors(p_api_version   => l_api_version,
                                                           p_init_msg_list => l_init_msg_list,
                                                           x_return_status => l_return_status,
                                                           x_msg_count     => x_msg_count,
                                                           x_msg_data      => x_msg_data,
                                                           p_srmv_rec      => l_srmv_rec,
                                                           x_srmv_rec      => x_srmv_rec);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign id returned to corresponding out parameter
    x_id := x_srmv_rec.id;
    -- Assign record returned by private api to local record
    l_srmv_rec := x_srmv_rec;


    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END populate_sif_ret_errors;
-- mvasudev , 04/24/2002 end

  ----------------------------------------------------------------------------------------
  -- PROCEDURE populate_insured_residual
  ----------------------------------------------------------------------------------------
  PROCEDURE populate_insured_residual (
    p_api_version                  IN NUMBER,
	p_init_msg_list				   IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_transaction_number           IN NUMBER,
	p_amount					   IN NUMBER,
	p_sir_id					   IN NUMBER,
	x_return_status                OUT NOCOPY VARCHAR2
	--x_msg_count                    OUT NOCOPY NUMBER,
	--x_msg_data                     OUT NOCOPY VARCHAR2
  ) IS

  l_khr_id NUMBER;
  l_start_date DATE;
  l_stream_type_name VARCHAR2(30);
  l_api_name  CONSTANT VARCHAR2(30) := 'populate_insured_residual';
  l_api_version     CONSTANT NUMBER := 1;
  l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
  --l_srsv_rec  srsv_rec_type;
  --lx_srsv_rec  srsv_rec_type;
  lx_msg_count  NUMBER;
  lx_msg_data  VARCHAR2(400);
  lx_id NUMBER;

  CURSOR khr_id_csr (trx_number NUMBER) IS
  SELECT khr_id
  FROM okl_stream_interfaces
  WHERE transaction_number = trx_number;

  CURSOR start_date_csr (khr_id NUMBER) IS
  SELECT start_date
  FROM okc_k_headers_b
  WHERE id = khr_id;

  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    FOR khr_id_info IN khr_id_csr(p_transaction_number)
    LOOP
      l_khr_id := khr_id_info.khr_id;
    END LOOP;

    FOR start_date_info IN start_date_csr(l_khr_id)
    LOOP
      l_start_date := start_date_info.start_date;
    END LOOP;

	l_stream_type_name := 'GUARANTEED RESIDUAL INSURED';

    --l_srsv_rec.stream_type_name := l_stream_type_name;
    --l_srsv_rec.index_number := to_number(NULL);
    --l_srsv_rec.activity_type := NULL;
    --l_srsv_rec.sre_date := l_start_date;
    --l_srsv_rec.amount := p_amount;
    --l_srsv_rec.sir_id := p_sir_id;


    /* Call main API */
	--DBMS_OUTPUT.PUT_LINE('khr_id ' || l_khr_id);
    --DBMS_OUTPUT.PUT_LINE('Before calling Procedure ' || l_start_date);
    Okl_Populate_Prceng_Result_Pub.populate_sif_ret_strms (p_api_version         => p_api_version,
                                                           p_init_msg_list       => p_init_msg_list,
                                                           x_return_status       => l_return_status,
                                                           x_id                  => lx_id,
                                                           p_stream_type_name    => l_stream_type_name,
	                                                       p_description         => l_stream_type_name,
                                                           p_index_number        => TO_NUMBER(NULL),
                                                          -- p_index_number        => 1,
                                                         --  p_activity_type       => NULL,
														   p_activity_type       => 'TYPE',
                                                         --  p_se_line_number      => to_number(NULL),
														   p_se_line_number      => 1,
                                                           p_sre_date            => TO_CHAR(l_start_date, 'YYYY-MM-DD'),
                                                           p_amount              => p_amount,
                                                           p_sir_id              => p_sir_id);


	--DBMS_OUTPUT.PUT_LINE('After calling Procedure ' ||  l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;


    OKL_API.END_ACTIVITY(x_msg_count  => lx_msg_count,
						 x_msg_data	  => lx_msg_data);

	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
  END populate_insured_residual;

-- mvasudev, 04/24/2002
  ----------------------------------------------------------------------------------------
  -- PROCEDURE populate_insured_residual
  ----------------------------------------------------------------------------------------
  PROCEDURE populate_insured_residual (
    p_transaction_number           IN NUMBER,
	p_amount					   IN NUMBER,
	p_sir_id					   IN NUMBER,
	x_return_status                OUT NOCOPY VARCHAR2
  ) IS

  l_khr_id NUMBER;
  l_start_date DATE;
  l_stream_type_name VARCHAR2(30);
  l_api_name  CONSTANT VARCHAR2(30) := 'populate_insured_residual';
  l_api_version     CONSTANT NUMBER := 1;
  l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
  --l_srsv_rec  srsv_rec_type;
  --lx_srsv_rec  srsv_rec_type;
  lx_msg_count  NUMBER;
  lx_msg_data  VARCHAR2(400);
  lx_id NUMBER;

  CURSOR khr_id_csr (trx_number NUMBER) IS
  SELECT khr_id
  FROM okl_stream_interfaces
  WHERE transaction_number = trx_number;

  CURSOR start_date_csr (khr_id NUMBER) IS
  SELECT start_date
  FROM okc_k_headers_b
  WHERE id = khr_id;

	l_init_msg_list       VARCHAR2(1) := 'F';


  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => l_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => l_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    FOR khr_id_info IN khr_id_csr(p_transaction_number)
    LOOP
      l_khr_id := khr_id_info.khr_id;
    END LOOP;

    FOR start_date_info IN start_date_csr(l_khr_id)
    LOOP
      l_start_date := start_date_info.start_date;
    END LOOP;

	l_stream_type_name := 'GUARANTEED RESIDUAL INSURED';

    --l_srsv_rec.stream_type_name := l_stream_type_name;
    --l_srsv_rec.index_number := to_number(NULL);
    --l_srsv_rec.activity_type := NULL;
    --l_srsv_rec.sre_date := l_start_date;
    --l_srsv_rec.amount := p_amount;
    --l_srsv_rec.sir_id := p_sir_id;


    /* Call main API */
	--DBMS_OUTPUT.PUT_LINE('khr_id ' || l_khr_id);
    --DBMS_OUTPUT.PUT_LINE('Before calling Procedure ' || l_start_date);
    Okl_Populate_Prceng_Result_Pub.populate_sif_ret_strms (p_api_version         => l_api_version,
                                                           p_init_msg_list       => l_init_msg_list,
                                                           x_return_status       => l_return_status,
                                                           x_id                  => lx_id,
                                                           p_stream_type_name    => l_stream_type_name,
	                                                       p_description         => l_stream_type_name,
                                                           p_index_number        => TO_NUMBER(NULL),
                                                          -- p_index_number        => 1,
                                                         --  p_activity_type       => NULL,
														   p_activity_type       => 'TYPE',
                                                         --  p_se_line_number      => to_number(NULL),
														   p_se_line_number      => 1,
                                                           p_sre_date            => TO_CHAR(l_start_date, 'YYYY-MM-DD'),
                                                           p_amount              => p_amount,
                                                           p_sir_id              => p_sir_id);


	--DBMS_OUTPUT.PUT_LINE('After calling Procedure ' ||  l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;


    OKL_API.END_ACTIVITY(x_msg_count  => lx_msg_count,
						 x_msg_data	  => lx_msg_data);

	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
  END populate_insured_residual;
-- mvasudev, 04/24/2002 end

/*
  PROCEDURE update_status (
    p_api_version		   		   IN NUMBER,
	p_init_msg_list				   IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	p_transaction_number		   IN NUMBER,
	p_sis_code					   IN VARCHAR2,
	x_return_status				   OUT NOCOPY VARCHAR2
  ) IS
    -- cursor to update transaction status in the OKL_STREAM_INTERFACES table
    CURSOR sif_data_csr (trx_number IN NUMBER) IS
    SELECT
          ID,ORP_CODE
    FROM Okl_Stream_Interfaces
    WHERE okl_stream_interfaces.transaction_number = trx_number;

    l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	lp_sifv_rec  sifv_rec_type;
	lx_sifv_rec  sifv_rec_type;
	lx_msg_count NUMBER;
	lx_msg_data VARCHAR2(100);

  BEGIN

  -- update the status in the In bound Interface Tables
    FOR sif_data in sif_data_csr(p_transaction_number)
    LOOP
      lp_sifv_rec.id := sif_data.id;
      lp_sifv_rec.ORP_CODE := sif_data.ORP_CODE;
    END LOOP;
    lp_sifv_rec.date_processed := to_date(to_char(SYSDATE,'YYYYMMDD HH24MISS'), 'YYYYMMDD HH24MISS');
    lp_sifv_rec.sis_code := p_sis_code;

    OKL_POPULATE_PRCENG_RESULT_PVT.update_status (p_api_version => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                                                  p_sifv_rec => lp_sifv_rec,
                                                  x_sifv_rec => lx_sifv_rec,
                                                  x_msg_count => lx_msg_count,
                                                  x_msg_data => lx_msg_data,
                                                  x_return_status => l_return_status);

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
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_status;
*/
  PROCEDURE update_status (
    p_api_version		   		   IN NUMBER,
    p_init_msg_list				   IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_transaction_number		   IN NUMBER,
    p_sis_code			   		   IN VARCHAR2, -- outbound status
    p_srt_code					   IN VARCHAR2, -- inbound status
	p_log_file_name 			   IN VARCHAR2,
    x_return_status				   OUT NOCOPY VARCHAR2
  ) IS
    -- cursor to update transaction status in the OKL_STREAM_INTERFACES table
    CURSOR sif_data_csr (trx_number IN NUMBER) IS
    SELECT
          ID,ORP_CODE
    FROM Okl_Stream_Interfaces
    WHERE okl_stream_interfaces.transaction_number = trx_number;

    CURSOR sir_data_csr (trx_number IN NUMBER) IS
    SELECT
          ID
    FROM Okl_Sif_Rets
    WHERE okl_sif_rets.transaction_number = trx_number;

    l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	lp_sifv_rec  sifv_rec_type;
	lx_sifv_rec  sifv_rec_type;
	lp_sirv_rec  sirv_rec_type;
	lx_sirv_rec  sirv_rec_type;
	lx_msg_count NUMBER;
	lx_msg_data VARCHAR2(100);

  BEGIN

  -- update the status in the In bound Interface Tables
    FOR sif_data IN sif_data_csr(p_transaction_number)
    LOOP
      lp_sifv_rec.id := sif_data.id;
      lp_sifv_rec.ORP_CODE := sif_data.ORP_CODE;
    END LOOP;
    lp_sifv_rec.date_processed := TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD HH24MISS'), 'YYYYMMDD HH24MISS');
    lp_sifv_rec.sis_code := p_sis_code;
	IF(p_log_file_name <> 'TEMPVALUE')
	THEN
	lp_sifv_rec.log_file := p_log_file_name;
	END IF;


    Okl_Populate_Prceng_Result_Pvt.update_outbound_status (p_api_version => p_api_version,
                                                           p_init_msg_list => p_init_msg_list,
                                                           p_sifv_rec => lp_sifv_rec,
                                                           x_sifv_rec => lx_sifv_rec,
                                                           x_msg_count => lx_msg_count,
                                                           x_msg_data => lx_msg_data,
                                                           x_return_status => l_return_status);

    IF l_return_status = G_RET_STS_ERROR THEN
	  RAISE G_EXCEPTION_ERROR;
	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

    FOR sir_data IN sir_data_csr(p_transaction_number)
    LOOP
      lp_sirv_rec.id := sir_data.id;
      lp_sirv_rec.date_processed := TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD HH24MISS'), 'YYYYMMDD HH24MISS');
      lp_sirv_rec.srt_code := p_srt_code;

      Okl_Populate_Prceng_Result_Pvt.update_sif_rets (p_api_version => p_api_version,
                                                      p_init_msg_list => p_init_msg_list,
                                                      p_sirv_rec => lp_sirv_rec,
                                                      x_sirv_rec => lx_sirv_rec,
                                                      x_msg_count => lx_msg_count,
                                                      x_msg_data => lx_msg_data,
                                                      x_return_status => l_return_status);

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
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_status;

-- mvasudev , 04/24/2002
  PROCEDURE update_status (
    p_transaction_number		   IN NUMBER,
    p_sis_code			   		   IN VARCHAR2, -- outbound status
    p_srt_code					   IN VARCHAR2, -- inbound status
	p_log_file_name 			   IN VARCHAR2,
    x_return_status				   OUT NOCOPY VARCHAR2
  ) IS
    -- cursor to update transaction status in the OKL_STREAM_INTERFACES table
    CURSOR sif_data_csr (trx_number IN NUMBER) IS
    SELECT
          ID,ORP_CODE
    FROM Okl_Stream_Interfaces
    WHERE okl_stream_interfaces.transaction_number = trx_number;

    CURSOR sir_data_csr (trx_number IN NUMBER) IS
    SELECT
          ID
    FROM Okl_Sif_Rets
    WHERE okl_sif_rets.transaction_number = trx_number;

    l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	lp_sifv_rec  sifv_rec_type;
	lx_sifv_rec  sifv_rec_type;
	lp_sirv_rec  sirv_rec_type;
	lx_sirv_rec  sirv_rec_type;
	lx_msg_count NUMBER;
	lx_msg_data VARCHAR2(100);

	l_init_msg_list       VARCHAR2(1) := 'F';
    l_api_version     CONSTANT NUMBER := 1;

  BEGIN

  -- update the status in the In bound Interface Tables
    FOR sif_data IN sif_data_csr(p_transaction_number)
    LOOP
      lp_sifv_rec.id := sif_data.id;
      lp_sifv_rec.ORP_CODE := sif_data.ORP_CODE;
    END LOOP;
    lp_sifv_rec.date_processed := TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD HH24MISS'), 'YYYYMMDD HH24MISS');
    lp_sifv_rec.sis_code := p_sis_code;
	IF(p_log_file_name <> 'TEMPVALUE')
	THEN
	lp_sifv_rec.log_file := p_log_file_name;
	END IF;


    Okl_Populate_Prceng_Result_Pvt.update_outbound_status (p_api_version => l_api_version,
                                                           p_init_msg_list => l_init_msg_list,
                                                           p_sifv_rec => lp_sifv_rec,
                                                           x_sifv_rec => lx_sifv_rec,
                                                           x_msg_count => lx_msg_count,
                                                           x_msg_data => lx_msg_data,
                                                           x_return_status => l_return_status);

    IF l_return_status = G_RET_STS_ERROR THEN
	  RAISE G_EXCEPTION_ERROR;
	ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
	  RAISE G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

    FOR sir_data IN sir_data_csr(p_transaction_number)
    LOOP
      lp_sirv_rec.id := sir_data.id;
      lp_sirv_rec.date_processed := TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD HH24MISS'), 'YYYYMMDD HH24MISS');
      lp_sirv_rec.srt_code := p_srt_code;

      Okl_Populate_Prceng_Result_Pvt.update_sif_rets (p_api_version => l_api_version,
                                                      p_init_msg_list => l_init_msg_list,
                                                      p_sirv_rec => lp_sirv_rec,
                                                      x_sirv_rec => lx_sirv_rec,
                                                      x_msg_count => lx_msg_count,
                                                      x_msg_data => lx_msg_data,
                                                      x_return_status => l_return_status);

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
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_status;

-- mvasudev , 04/24/2002 end
  ----------------------------------------------------------------------------------------
  -- PROCEDURE check_status: checks outbound status and if the outbound has time out
  --                         returns a 'N' else returns 'Y' which indicates whether
  --                         the inbound should proceed or not.
  ----------------------------------------------------------------------------------------

  PROCEDURE check_status (
    p_transaction_number		   IN NUMBER,
	x_ok_to_proceed                OUT NOCOPY VARCHAR2,
    x_return_status				   OUT NOCOPY VARCHAR2
  ) IS

    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_rets';
    l_api_version     CONSTANT NUMBER := 1;
    l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    CURSOR sif_data_csr (trx_number IN NUMBER) IS
    SELECT
          SIS_CODE
    FROM Okl_Stream_Interfaces
    WHERE okl_stream_interfaces.transaction_number = trx_number;
  BEGIN
    x_ok_to_proceed := 'Y';
    FOR sif_data IN sif_data_csr(p_transaction_number)
	LOOP
	  IF sif_data.sis_code = 'TIME_OUT' or sif_data.sis_code = 'PROCESS_ABORTED' THEN
	    x_ok_to_proceed := 'N';
	  END IF;
	END LOOP;
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END check_status;


  PROCEDURE log_error_messages (
    p_transaction_number           IN NUMBER,
	x_return_status                OUT NOCOPY VARCHAR2
  ) IS
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
	l_failure_code VARCHAR2(20) := 'PROCESSING_FAILED';
    l_error_message_tbl  LOG_MSG_TBL_TYPE;
	l_msg_count NUMBER;
	l_log_file_name_pre VARCHAR2(15) := OKL_INVOKE_PRICING_ENGINE_PVT.G_FILENAME_PRE;
	l_log_file_name_ext VARCHAR2(15) := OKL_INVOKE_PRICING_ENGINE_PVT.G_FILENAME_EXT;

  BEGIN
    -- log error message
    l_error_message_tbl(1) := 'Errors while processing Streams Results :- ';
    Okl_Streams_Util.LOG_MESSAGE(p_msgs_tbl => l_error_message_tbl,
                                 p_translate => G_FALSE,
                                 p_file_name => l_log_file_name_pre || p_transaction_number || l_log_file_name_ext ,
       			                 x_return_status => l_return_status );

    l_msg_count := fnd_msg_pub.count_msg;
    Okl_Streams_Util.LOG_MESSAGE(p_msg_count => l_msg_count,
                                 p_file_name => l_log_file_name_pre || p_transaction_number || l_log_file_name_ext,
	                             x_return_status => l_return_status);

   	l_error_message_tbl(1) := 'End Errors while processing Streams Results';
    Okl_Streams_Util.LOG_MESSAGE(p_msgs_tbl => l_error_message_tbl,
                                 p_translate => G_FALSE,
                                 p_file_name => l_log_file_name_pre || p_transaction_number || l_log_file_name_ext ,
       			                 x_return_status => l_return_status );

    -- update status to PROCESSING_FAILED
	update_status (p_transaction_number => p_transaction_number,
                   p_sis_code => l_failure_code, -- outbound status
                   p_srt_code => l_failure_code, -- inbound status
	               p_log_file_name => l_log_file_name_pre || p_transaction_number || l_log_file_name_ext,
                   x_return_status => l_return_status);

    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
  END log_error_messages;


  PROCEDURE populate_sif_ret_levels (
    p_sir_id                         IN NUMBER := OKC_API.G_MISS_NUM,
    p_index_number                   IN NUMBER := OKC_API.G_MISS_NUM,
    p_level_index_number             IN NUMBER := OKC_API.G_MISS_NUM,
    p_number_of_periods              IN NUMBER := OKC_API.G_MISS_NUM,
    p_level_type                     IN OKL_SIF_RET_LEVELS.LEVEL_TYPE%TYPE := OKC_API.G_MISS_CHAR,
    p_amount                         IN NUMBER := OKC_API.G_MISS_NUM,
    p_advance_or_arrears             IN OKL_SIF_RET_LEVELS.ADVANCE_OR_ARREARS%TYPE := OKC_API.G_MISS_CHAR,
    p_period                         IN OKL_SIF_RET_LEVELS.PERIOD%TYPE := OKC_API.G_MISS_CHAR,
    p_lock_level_step                IN OKL_SIF_RET_LEVELS.LOCK_LEVEL_STEP%TYPE := OKC_API.G_MISS_CHAR,
    p_days_in_period                 IN NUMBER := OKC_API.G_MISS_NUM,
    p_first_payment_date             IN VARCHAR2,
    p_rate                           IN NUMBER := OKC_API.G_MISS_NUM,
    x_return_status                  OUT NOCOPY VARCHAR2
  ) IS
    l_api_name  CONSTANT VARCHAR2(30) := 'populate_sif_ret_levels';
    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_srlv_rec srlv_rec_type;
    l_api_version     CONSTANT NUMBER := 1;
	l_init_msg_list       VARCHAR2(1) := 'F';
	l_first_payment_date VARCHAR2(30);
	l_advance_or_arrears VARCHAR2(1);
	l_lock_level_step VARCHAR2(1);

    x_srlv_rec srlv_rec_type;
    x_msg_data               VARCHAR2(400);
    x_msg_count  NUMBER ;

  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => l_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => l_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;
    l_srlv_rec.sir_id := p_sir_id;
    l_srlv_rec.index_number := p_index_number;
    l_srlv_rec.level_index_number := p_level_index_number;
    l_srlv_rec.number_of_periods := p_number_of_periods;
    l_srlv_rec.level_type := p_level_type;
    l_srlv_rec.amount := p_amount;
	OKL_ST_CODE_CONVERSIONS.REVERSE_TRANSLATE_YN(p_advance_or_arrears, l_advance_or_arrears);
    l_srlv_rec.advance_or_arrears := l_advance_or_arrears;
    l_srlv_rec.period := p_period;
	OKL_ST_CODE_CONVERSIONS.REVERSE_TRANSLATE_YN(p_lock_level_step, l_lock_level_step);
    l_srlv_rec.lock_level_step := l_lock_level_step;
    l_srlv_rec.days_in_period := p_days_in_period;
    l_srlv_rec.rate := p_rate;	--smahapat 10/12/03

    l_first_payment_date := p_first_payment_date;
    l_first_payment_date := correct_feb_date(l_first_payment_date);

    l_srlv_rec.first_payment_date := TO_DATE(l_first_payment_date, 'YYYY-MM-DD');


    /* Call main API */
    Okl_Populate_Prceng_Result_Pvt.populate_sif_ret_levels(p_api_version   => l_api_version,
                                                           p_init_msg_list => l_init_msg_list,
                                                           x_return_status => l_return_status,
                                                           x_msg_count     => x_msg_count,
                                                           x_msg_data      => x_msg_data,
                                                           p_srlv_rec      => l_srlv_rec,
                                                           x_srlv_rec      => x_srlv_rec);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    -- Assign record returned by private api to local record
    l_srlv_rec := x_srlv_rec;


    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END populate_sif_ret_levels;

END OKL_POPULATE_PRCENG_RESULT_PUB;

/
