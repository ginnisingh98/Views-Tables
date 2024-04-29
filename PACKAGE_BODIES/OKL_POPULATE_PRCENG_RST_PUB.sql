--------------------------------------------------------
--  DDL for Package Body OKL_POPULATE_PRCENG_RST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_POPULATE_PRCENG_RST_PUB" AS
/*$Header: OKLPPRSB.pls 120.9 2007/05/14 20:42:10 srsreeni noship $*/
  --G_MODULE VARCHAR2(40) := 'LEASE.STREAMS';
  G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_populate_prceng_rst_pub';
  G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_IS_DEBUG_EXCEPTION_ON BOOLEAN;
  G_IS_DEBUG_ERROR_ON BOOLEAN;
  G_IS_DEBUG_PROCEDURE_ON BOOLEAN;

  G_TRANSACTION_NUMBER NUMBER;


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

   --Added by BKATRAGA.
   --This procedure is used in the populate_sif_ret_strms procedure prior to the bulk insert call.

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
    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||p_transaction_number;

  BEGIN
    G_TRANSACTION_NUMBER := p_transaction_number;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_EXCEPTION_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_EXCEPTION);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_PROCEDURE);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_ERROR_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_ERROR);
    END IF;

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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||SQLERRM(SQLCODE));
	  END IF;

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

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||p_transaction_number;
  BEGIN

    G_TRANSACTION_NUMBER := p_transaction_number;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_EXCEPTION_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_EXCEPTION);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_PROCEDURE);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_ERROR_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_ERROR);
    END IF;

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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||SQLERRM(SQLCODE));
	  END IF;

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

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||p_transaction_number;
  BEGIN

    G_TRANSACTION_NUMBER := p_transaction_number;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_EXCEPTION_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_EXCEPTION);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_PROCEDURE);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_ERROR_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_ERROR);
    END IF;

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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||SQLERRM(SQLCODE));
	  END IF;

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

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||p_transaction_number;
  BEGIN

    G_TRANSACTION_NUMBER := p_transaction_number;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_EXCEPTION_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_EXCEPTION);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_PROCEDURE);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_ERROR_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_ERROR);
    END IF;

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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||x_msg_data);
	  END IF;

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

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||G_TRANSACTION_NUMBER;
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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

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

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||G_TRANSACTION_NUMBER;
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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

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

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||G_TRANSACTION_NUMBER;
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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||lx_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||lx_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||lx_msg_data);
	  END IF;

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

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||G_TRANSACTION_NUMBER;
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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||lx_msg_count);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||lx_msg_count);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||lx_msg_count);
	  END IF;

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
  -- Added by BKATRAGA on 02/24/2005
  -- This procedure has been modified to accept a table of records in place of
  -- a single record.
  -- Bug - Start of Changes
  PROCEDURE populate_sif_ret_strms (x_return_status       OUT NOCOPY VARCHAR2,
                                    p_index_number        IN NUMBER := OKC_API.G_MISS_NUM,
                                    p_strm_tbl            IN strm_tbl_type,
                                    p_sir_id              IN NUMBER := OKC_API.G_MISS_NUM
  ) IS

    l_return_status  VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_sre_date       VARCHAR2(30);
    l_amount         NUMBER;
    i                NUMBER := 0;
    l_api_name       CONSTANT VARCHAR2(30) := 'populate_sif_ret_strms';
    x_msg_data       VARCHAR2(400);
    x_msg_count      NUMBER;
    p_init_msg_list  VARCHAR2(1) := 'F';
    p_api_version    NUMBER := 1.0;
    l_api_version    CONSTANT NUMBER := 1;
    l_strm_rec       strm_rec_type;

    l_srsv_rec       srsv_rec_type;
    l_srsv_tbl       srsv_tbl_type;
    p_activity_type  OKL_SIF_RET_STRMS.ACTIVITY_TYPE%TYPE := OKC_API.G_MISS_CHAR;
	p_se_line_number NUMBER := 1;
    l_counter        NUMBER := 0;
    l_stream_type_name  OKL_SIF_RET_STRMS.STREAM_TYPE_NAME%TYPE := OKC_API.G_MISS_CHAR;
    l_description    VARCHAR2(150) := OKC_API.G_MISS_CHAR;

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||G_TRANSACTION_NUMBER;
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

    IF (p_strm_tbl.COUNT > 0) THEN
      i := p_strm_tbl.FIRST;
    LOOP
      l_strm_rec := p_strm_tbl(i);
      l_stream_type_name := l_strm_rec.strm_name;
      l_description := l_strm_rec.strm_desc;
      l_sre_date := l_strm_rec.sre_date;
      l_amount   := l_strm_rec.amount;


      IF(l_description =   'Residual Insurance Premium') THEN
           l_srsv_rec.stream_type_name := 'RESIDUAL VALUE INSURANCE PREMIUM';
   	  ELSIF ( l_description = 'NODESC' OR l_description = 'TEMPVALUE') THEN
    	   l_srsv_rec.stream_type_name := l_stream_type_name;
	  ELSE
	       l_srsv_rec.stream_type_name := l_description;
	  END IF;

          --Added by kthiruva for Streams Performance
          --Bug 4346646 - Start of Changes
          IF (l_strm_rec.index_number = NULL) THEN
            l_strm_rec.index_number := p_index_number;
          END IF;

        -- IF the index number is not returned from SuperTrump
	    -- -100 is the default value for Index Number
          IF (p_index_number = -100) THEN
    	   l_srsv_rec.index_number := NULL;
	  ELSE
           l_srsv_rec.index_number := l_strm_rec.index_number;
	  END IF;
          --Bug 4346646 - End of Changes
      l_srsv_rec.activity_type := p_activity_type;

      l_srsv_rec.sequence_number := p_se_line_number;

      l_sre_date := correct_feb_date(l_sre_date);

      l_srsv_rec.sre_date := TO_DATE(l_sre_date, 'YYYY-MM-DD');
      l_srsv_rec.amount := l_amount;
      l_srsv_rec.sir_id := p_sir_id;

      l_counter := l_counter + 1;
      l_srsv_tbl(l_counter) := l_srsv_rec;

     EXIT WHEN (i = p_strm_tbl.LAST);
        i := p_strm_tbl.NEXT(i);
     END LOOP;
    END IF;

    okl_srs_pvt.insert_row_upg(p_srsv_tbl => l_srsv_tbl);

    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
    x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);

  END populate_sif_ret_strms;
  --Bug -End of Changes

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

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||G_TRANSACTION_NUMBER;
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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

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

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||G_TRANSACTION_NUMBER;
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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

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

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||G_TRANSACTION_NUMBER;

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
	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

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

  --Added by BKATRAGA on 03/03/2005
  --This procedure has been modified to accept a table of records instead of a
  --single record.
  --Bug - Start of Changes
  PROCEDURE populate_sif_ret_errors (
    x_return_status                  OUT NOCOPY VARCHAR2,
    x_id                             OUT NOCOPY NUMBER,
    p_sir_id                         IN NUMBER := OKC_API.G_MISS_NUM,
    p_strm_excp_tbl                  IN strm_excp_tbl_type,
    p_tag_attribute_name             IN OKL_SIF_RET_ERRORS.TAG_ATTRIBUTE_NAME%TYPE := OKC_API.G_MISS_CHAR,
    p_tag_attribute_value            IN OKL_SIF_RET_ERRORS.TAG_ATTRIBUTE_VALUE%TYPE := OKC_API.G_MISS_CHAR,
    p_description                    IN OKL_SIF_RET_ERRORS.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR
  ) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'populate_sif_ret_errors';
    l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_version       CONSTANT NUMBER := 1;
    l_init_msg_list     VARCHAR2(1) := 'F';
    x_msg_data          VARCHAR2(400);
    x_msg_count         NUMBER ;
    l_strm_excp_rec     strm_excp_rec_type;
    i                   NUMBER := 0;
    l_error_code        OKL_SIF_RET_ERRORS.ERROR_CODE%TYPE := OKC_API.G_MISS_CHAR;
    l_error_message     OKL_SIF_RET_ERRORS.ERROR_MESSAGE%TYPE := OKC_API.G_MISS_CHAR;
    l_description       OKL_SIF_RET_ERRORS.DESCRIPTION%TYPE := OKC_API.G_MISS_CHAR;
    l_tag_name          OKL_SIF_RET_ERRORS.TAG_NAME%TYPE := OKC_API.G_MISS_CHAR;

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||G_TRANSACTION_NUMBER;

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


    IF (p_strm_excp_tbl.COUNT > 0) THEN
      i := p_strm_excp_tbl.FIRST;
    LOOP
      l_strm_excp_rec := p_strm_excp_tbl(i);
      l_error_code    := l_strm_excp_rec.error_code;
      l_error_message := l_strm_excp_rec.error_message;
      --l_description   := l_strm_excp_rec.description;
      l_tag_name      := l_strm_excp_rec.tag_name;

      populate_sif_ret_errors (l_return_status,
                      x_id => x_id,
                      p_sir_id => p_sir_id,
                      p_error_code => l_error_code,
                      p_error_message => l_error_message,
                      p_tag_name => l_tag_name,
                      p_tag_attribute_name => p_tag_attribute_name,
                      p_tag_attribute_value => p_tag_attribute_value,
                      p_description => p_description
                      --p_description => l_description
                      );

      IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = G_RET_STS_ERROR) THEN
          RAISE G_EXCEPTION_ERROR;
      END IF;

    EXIT WHEN (i = p_strm_excp_tbl.LAST);
        i := p_strm_excp_tbl.NEXT(i);
     END LOOP;
    END IF;


    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);

  END populate_sif_ret_errors;
  --Bug - End of Changes

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

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||G_TRANSACTION_NUMBER;

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
    --l_srmv_rec.description := p_description;
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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

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

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||G_TRANSACTION_NUMBER;

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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

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

  l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||p_transaction_number;

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
    Okl_POPULATE_PRCENG_RST_PUB.populate_sif_ret_strms (p_api_version         => p_api_version,
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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||lx_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||lx_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||lx_msg_data);
	  END IF;

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

  l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||p_transaction_number;

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
    Okl_POPULATE_PRCENG_RST_PUB.populate_sif_ret_strms (p_api_version         => l_api_version,
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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||lx_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||lx_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> lx_msg_count,
												   x_msg_data	=> lx_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,p_transaction_number ||': '||lx_msg_data);
	  END IF;

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

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||G_TRANSACTION_NUMBER;
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
    --Modified by kthiruva on 11-Nov-2005
    --Bug 4726209 - Start of Changes
    OKL_ST_CODE_CONVERSIONS.REVERSE_TRANSLATE_ADV_OR_ARR(p_advance_or_arrears, l_advance_or_arrears);
    --Bug 4726209 - End of Changes
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

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

	  IF(G_IS_DEBUG_EXCEPTION_ON) THEN
	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module ,G_TRANSACTION_NUMBER ||': '||x_msg_data);
	  END IF;

      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END populate_sif_ret_levels;

  ----------------------------------------------------------------------
  --  Procedure to call Okl_process_streams_pvt.Process_Streams_Result
  ----------------------------------------------------------------------

  --Added by RIRAWAT
  -- This procedure has been added to replace the call to the Inbound Workflow.
  -- The method Okl_Process_Streams_Pvt.process_stream_results is now being called
  -- directly instead of invoking it through the workflow.
  -- Bug - Start of Changes
  PROCEDURE process(   p_transaction_number		   IN NUMBER,
                       resultout   OUT NOCOPY VARCHAR2
  )
  IS
    l_transaction_number	VARCHAR2(240);
    document_id		VARCHAR2(240);

    l_error_msg		VARCHAR2(2000);
    result		    VARCHAR2(30);
    l_orp_code        VARCHAR2(10);

    l_api_version     NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30) := 'process';
    l_init_msg_list   VARCHAR2(1) :=  OKC_API.G_FALSE;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
--srsreeni Bug 5599821 start
    l_msg_index_out   NUMBER;
--srsreeni Bug 5599821 end
    l_msg_data        VARCHAR2(4000);
    l_msg_text        VARCHAR2(4000);
    l_attr_name       VARCHAR2(15) := 'ERROR_MSG';
    G_SIS_CODE        VARCHAR2(50) := 'PROCESSING_FAILED';
    G_SRT_CODE        VARCHAR2(50) := 'PROCESSING_FAILED';
    l_error_message_tbl  LOG_MSG_TBL_TYPE;
    l_error_message_line VARCHAR2(4000) := NULL;

    -- smahapat added khr_id to cursor for bug 3145238
    CURSOR strm_interfaces_data_csr (p_trx_number NUMBER) IS
    SELECT
     ORP_CODE, KHR_ID
    FROM okl_stream_interfaces
    WHERE okl_stream_interfaces.transaction_number = p_trx_number;

    -- smahapat added for bug 3145238
    -- cursor to provide information for setting context
    CURSOR l_hdr_csr(chrId  NUMBER)
    IS
    SELECT chr.orig_system_source_code,
           chr.start_date,
           chr.end_date,
           chr.template_yn,
           chr.authoring_org_id,
           chr.inv_organization_id,
           khr.deal_type,
           pdt.id  pid,
           NVL(pdt.reporting_pdt_id, -1) report_pdt_id,
           chr.currency_code currency_code,
           khr.term_duration term
--srsreeni Bug6004114 start
--    FROM okc_k_headers_v chr,
    FROM okc_k_headers_all_b chr,
--srsreeni Bug6004114 end
         okl_k_headers khr,
         okl_products_v pdt
    WHERE khr.id = chr.id
    AND chr.id = chrId
    AND khr.pdt_id = pdt.id(+);

    l_hdr_rec l_hdr_csr%ROWTYPE;
    l_khr_id          NUMBER;
    -- end code for setting context
    l_new_line        VARCHAR2(10) := FND_GLOBAL.NEWLINE;

    l_module VARCHAR2(255) := G_MODULE||'.'||l_api_name||'.'||p_transaction_number;

    BEGIN

    G_TRANSACTION_NUMBER := p_transaction_number;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_EXCEPTION_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_EXCEPTION);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_PROCEDURE);
    END IF;

    IF(G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_ERROR_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_ERROR);
    END IF;

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module,p_transaction_number||': begin okl_populate_prceng_rst_pub.process');
    END IF;

    -- Do nothing in cancel or timeout mode
    l_transaction_number:=p_transaction_number;

 	-- Invoke Process Stream Results API
	FOR strm_interfaces_data in strm_interfaces_data_csr(l_transaction_number)
	LOOP
	  l_orp_code := strm_interfaces_data.orp_code;
	  l_khr_id := strm_interfaces_data.khr_id;	   -- added by smahapat for setting context (bug 3145238)
	END LOOP;

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_transaction_number||': l_orp_code = '||l_orp_code);
    END IF;

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_transaction_number||': l_khr_id = '||l_khr_id);
    END IF;

    -- set context (bug 3145238)
    OPEN l_hdr_csr( l_khr_id );
    FETCH l_hdr_csr INTO l_hdr_rec;
    CLOSE l_hdr_csr;
    okl_context.set_okc_org_context(l_hdr_rec.authoring_org_id,l_hdr_rec.inv_organization_id);
    -- end set context


	-- Booking
		IF (l_orp_code = 'AUTH')
		THEN
	      OKL_PROCESS_STREAMS_PVT.PROCESS_STREAM_RESULTS (l_api_version
					                                     ,l_init_msg_list
								 	                     ,l_transaction_number
								                         ,l_return_status
								                         ,l_msg_count
	 							                         ,l_msg_data);
	-- Restrucutres
	    ELSIF(l_orp_code = 'RSAM')
		THEN
	      OKL_PROCESS_STREAMS_PVT.PROCESS_REST_STRM_RESLTS(
		                                          p_api_version        => l_api_version
	                                             ,p_init_msg_list      => l_init_msg_list
		                                         ,p_transaction_number => l_transaction_number
	                                             ,x_return_status      => l_return_status
	                                             ,x_msg_count          => l_msg_count
	                                             ,x_msg_data           => l_msg_data);
	--  Quotes
	    ELSIF(l_orp_code = 'QUOT')
		THEN
	      OKL_PROCESS_STREAMS_PVT.PROCESS_QUOT_STRM_RESLTS(
		                                          p_api_version        => l_api_version
	                                             ,p_init_msg_list      => l_init_msg_list
		                                         ,p_transaction_number => l_transaction_number
	                                             ,x_return_status      => l_return_status
	                                             ,x_msg_count          => l_msg_count
	                                             ,x_msg_data           => l_msg_data);
	--  Renewals
	    ELSIF(l_orp_code = 'RENW')
		THEN
	      OKL_PROCESS_STREAMS_PVT.PROCESS_RENW_STRM_RESLTS(
		                                          p_api_version        => l_api_version
	                                             ,p_init_msg_list      => l_init_msg_list
		                                         ,p_transaction_number => l_transaction_number
	                                             ,x_return_status      => l_return_status
	                                             ,x_msg_count          => l_msg_count
	                                             ,x_msg_data           => l_msg_data);
	--  Variable Interest Rate Processing
	    ELSIF(l_orp_code = 'VIRP')
		THEN
	      OKL_PROCESS_STREAMS_PVT.PROCESS_VIRP_STRM_RESLTS(
		                                          p_api_version        => l_api_version
	                                             ,p_init_msg_list      => l_init_msg_list
		                                         ,p_transaction_number => l_transaction_number
	                                             ,x_return_status      => l_return_status
	                                             ,x_msg_count          => l_msg_count
	                                             ,x_msg_data           => l_msg_data);


        END IF;

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module, p_transaction_number||': l_return_status = '||l_return_status);
    END IF;


        -- if error
        IF(l_return_status <> G_RET_STS_SUCCESS)
		  THEN
            l_error_msg := ' ';
            FOR i IN 1..l_msg_count
             LOOP
--srsreeni Bug5599821 start
               /*  fnd_msg_pub.get(p_data => l_msg_text,
                         p_msg_index_out => l_msg_count,
                         p_encoded => G_FALSE,
                         p_msg_index => fnd_msg_pub.g_next);*/
                        fnd_msg_pub.get (p_msg_index => i,
                                     p_encoded => 'F',
                                     p_data => l_msg_text,
                                     p_msg_index_out => l_msg_index_out);
--srsreeni Bug5599821 end
              	 IF i = 1 THEN
 	              l_error_msg := l_msg_text;
       	         ELSE
    	          l_error_msg := l_error_msg || l_new_line || l_msg_text;
        	     END IF;
              END LOOP;

            IF(G_IS_DEBUG_ERROR_ON) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_ERROR, l_module, p_transaction_number||': '||l_error_msg);
            END IF;

			l_error_message_tbl(1) := 'Errors while processing Streams Results :- ';

            Okl_Streams_Util.LOG_MESSAGE(p_msgs_tbl => l_error_message_tbl,
                                         p_translate => G_FALSE,
                                         p_file_name => 'OKLSTXMLG_' || l_transaction_number || '.log' ,
             			                 x_return_status => l_return_status );

--srsreeni Bug5599821 start
/*			Okl_Streams_Util.LOG_MESSAGE(p_msg_count => l_msg_count,
                                         p_file_name => 'OKLSTXMLG_' || l_transaction_number || '.log',
			                             x_return_status => l_return_status
                                         );*/
            Okl_Streams_Util.LOG_MESSAGE(
                                          p_msg_name        => l_error_msg,
                                          p_translate       => G_FALSE,
                                          p_file_name       => 'OKLSTXMLG_' || l_transaction_number || '.log',
                                          x_return_status   =>  l_return_status
                                         );
--srsreeni Bug5599821 end
	    	l_error_message_tbl(1) := 'End Errors while processing Streams Results';
            Okl_Streams_Util.LOG_MESSAGE(p_msgs_tbl => l_error_message_tbl,
                                         p_translate => G_FALSE,
                                         p_file_name => 'OKLSTXMLG_' || l_transaction_number || '.log' ,
             			                 x_return_status => l_return_status );


            OKL_POPULATE_PRCENG_RST_PUB.UPDATE_STATUS(--p_api_version => l_api_version,
	                                                     --p_init_msg_list => l_init_msg_list,
	                                                     p_transaction_number => l_transaction_number,
                                                         p_sis_code => G_SIS_CODE,
														 p_srt_code =>  G_SRT_CODE,
														 p_log_file_name => 'OKLSTXMLG_' || l_transaction_number || '.log',
                                                         x_return_status => l_return_status
														 );
--srsreeni Bug6011651 starts.Updates to ERROR when the processing fails
OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx(
     p_api_version         => l_api_version,
     p_init_msg_list       => l_init_msg_list,
     x_return_status       => l_return_status,
     x_msg_count           => l_msg_count,
     x_msg_data            => l_msg_data,
     p_khr_id              => l_khr_id,
     p_prog_short_name     => OKL_BOOK_CONTROLLER_PVT.G_PRICE_CONTRACT,
     p_progress_status     => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_ERROR);
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
--srsreeni Bug6011651 ends
   		   resultout := 'F';
        ELSE
             resultout := 'T';
		END IF;

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module,p_transaction_number||': resultout = '||resultout);
    END IF;

    IF(G_IS_DEBUG_PROCEDURE_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_PROCEDURE, l_module,p_transaction_number||': end okl_populate_prceng_rst_pub.process');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
--srsreeni Bug6011651 starts.Updates to ERROR when exception occurs
OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx(
     p_api_version         => l_api_version,
     p_init_msg_list       => l_init_msg_list,
     x_return_status       => l_return_status,
     x_msg_count           => l_msg_count,
     x_msg_data            => l_msg_data,
     p_khr_id              => l_khr_id,
     p_prog_short_name     => OKL_BOOK_CONTROLLER_PVT.G_PRICE_CONTRACT,
     p_progress_status     => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_ERROR);
--srsreeni Bug6011651 ends
    IF(G_IS_DEBUG_EXCEPTION_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_EXCEPTION, l_module, p_transaction_number||': '||SQLERRM(SQLCODE));
    END IF;

    RAISE;
END process;
-- Bug End of Changes
  --Added by KTHIRUVA
  -- This procedure has been added to raise a business event once the call to
  -- Okl_Process_Streams_Pvt.process_stream_results completes
  PROCEDURE raise_business_event(p_transaction_number  IN NUMBER,
                                 x_return_status       OUT NOCOPY VARCHAR2)
  IS

  BEGIN
 	 x_return_status := G_RET_STS_SUCCESS;
     -- raise the event
     --  The parameter list being passed is empty
     wf_event.RAISE(p_event_name => G_XMLG_RECEIVE_EVENT,
                    p_event_key =>  TO_CHAR(p_transaction_number)
                    );

  END raise_business_event;

END OKL_POPULATE_PRCENG_RST_PUB;

/
