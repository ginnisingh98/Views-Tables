--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_STREAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_STREAMS_PUB" AS
/* $Header: OKLPPSRB.pls 115.9 2004/04/14 13:06:54 rnaik noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.STREAMS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

  PROCEDURE process_stream_results(p_api_version        IN     NUMBER
                                   ,p_init_msg_list      IN     VARCHAR2
                                   ,x_return_status      OUT    NOCOPY VARCHAR2
                                   ,x_msg_count          OUT    NOCOPY NUMBER
                                   ,x_msg_data           OUT    NOCOPY VARCHAR2
                                   ,p_transaction_number IN     NUMBER

                        ) IS

    l_api_version NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'PROCESS_STREAM_RESULTS';
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;

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



	-- call process api to create_price_parm
-- Start of wraper code generated automatically by Debug code generator for okl_process_streams_pvt.process_stream_results
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPPSRB.pls call okl_process_streams_pvt.process_stream_results ');
    END;
  END IF;
    okl_process_streams_pvt.process_stream_results(
                                  p_api_version => p_api_version
                                 ,p_init_msg_list => p_init_msg_list
                                 ,x_return_status => l_return_status
                                 ,x_msg_count => x_msg_count
                                 ,x_msg_data => x_msg_data
                                 ,p_transaction_number => p_transaction_number);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPPSRB.pls call okl_process_streams_pvt.process_stream_results ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_process_streams_pvt.process_stream_results

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */



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
 END process_stream_results;




 PROCEDURE PROCESS_REST_STRM_RESLTS(p_api_version        IN     NUMBER
                                        ,p_init_msg_list      IN     VARCHAR2
	                                    ,p_transaction_number IN     NUMBER
                                        ,x_return_status      OUT    NOCOPY VARCHAR2
                                        ,x_msg_count          OUT    NOCOPY NUMBER
                                        ,x_msg_data           OUT    NOCOPY VARCHAR2
  ) IS
    l_api_version NUMBER := 1;
    l_api_name        CONSTANT VARCHAR2(30)  := 'PROCESS_RESTRUCT_STRM_RESLTS';
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;
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



	-- call process api to create_price_parm
-- Start of wraper code generated automatically by Debug code generator for Okl_Process_Streams_Pvt.PROCESS_REST_STRM_RESLTS
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPPSRB.pls call Okl_Process_Streams_Pvt.PROCESS_REST_STRM_RESLTS ');
    END;
  END IF;
    Okl_Process_Streams_Pvt.PROCESS_REST_STRM_RESLTS(
                                  p_api_version => p_api_version
                                 ,p_init_msg_list => p_init_msg_list
                                 ,x_return_status => l_return_status
                                 ,x_msg_count => x_msg_count
                                 ,x_msg_data => x_msg_data
                                 ,p_transaction_number => p_transaction_number);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPPSRB.pls call Okl_Process_Streams_Pvt.PROCESS_REST_STRM_RESLTS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Process_Streams_Pvt.PROCESS_REST_STRM_RESLTS

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

    /* re-assign local record structure using output record from pvt api */



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
 END PROCESS_REST_STRM_RESLTS;

END OKL_PROCESS_STREAMS_PUB;

/
