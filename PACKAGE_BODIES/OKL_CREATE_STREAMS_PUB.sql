--------------------------------------------------------
--  DDL for Package Body OKL_CREATE_STREAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREATE_STREAMS_PUB" AS
/* $Header: OKLPCSMB.pls 115.13 2004/04/14 13:06:43 rnaik noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.STREAMS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

  ---------------------------------------------------------------------------
  -- PROCEDURE Create_Streams_Lease_Book
  -- Public Wrapper for Create_Streams_Lease_Book Process API
  ---------------------------------------------------------------------------
 PROCEDURE Create_Streams_Lease_Book(
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_lease_header			IN  csm_lease_rec_type
       ,p_csm_one_off_fee_tbl			IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl			IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl				IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl			IN  csm_stream_types_tbl_type
       ,p_csm_line_details_tbl    	        	IN  csm_line_details_tbl_type
       ,p_rents_tbl		     		IN  csm_periodic_expenses_tbl_type
       ,x_trans_id	   			OUT NOCOPY NUMBER
       ,x_trans_status		 OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
       )
 IS
    l_api_name        CONSTANT VARCHAR2(30)  := 'Create_Streams_Lease_Book';
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
    l_api_version     CONSTANT NUMBER := 1;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;

  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
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





	-- call process api to Create_Streams_Lease_Book
-- Start of wraper code generated automatically by Debug code generator for OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Book
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPCSMB.pls call OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Book ');
    END;
  END IF;
    OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Book(p_api_version   => p_api_version,
                                          	p_init_msg_list => p_init_msg_list,
                                          	p_skip_prc_engine		=> p_skip_prc_engine,
                                          	p_csm_lease_header		=> p_csm_lease_header,
                                          	p_csm_one_off_fee_tbl	=> p_csm_one_off_fee_tbl,
                                          	p_csm_periodic_expenses_tbl	=> p_csm_periodic_expenses_tbl,
                                          	p_csm_yields_tbl			=> p_csm_yields_tbl,
                                          	p_csm_stream_types_tbl	=> p_csm_stream_types_tbl,
                                          	p_csm_line_details_tbl    	=> p_csm_line_details_tbl,
                                          	p_rents_tbl		     	=> p_rents_tbl,
                                          	x_trans_id			=> x_trans_id,
                                          	x_trans_status			=> x_trans_status,
                                          	x_return_status => l_return_status,
                                          	x_msg_count     => x_msg_count,
                                          	x_msg_data      => x_msg_data);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPCSMB.pls call OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Book ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Book

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;



    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END Create_Streams_Lease_Book;

  ---------------------------------------------------------------------------
  -- PROCEDURE Create_Streams_Loan_Book
  -- Public Wrapper for Process API Create_Streams_Loan_Book
  ---------------------------------------------------------------------------
  PROCEDURE Create_Streams_Loan_Book(
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_loan_header			IN  csm_loan_rec_type
       ,p_csm_loan_lines_tbl			IN  csm_loan_line_tbl_type
       ,p_csm_loan_levels_tbl			IN  csm_loan_level_tbl_type
       ,p_csm_one_off_fee_tbl		IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl	IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl			IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl		IN  csm_stream_types_tbl_type
       ,x_trans_id	   			    OUT NOCOPY NUMBER
       ,x_trans_status	   						OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
       ) IS

    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'Create_Streams_Loan_Book';
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;
    l_api_version     CONSTANT NUMBER := 1;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
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





	-- call process api to update formulae
-- Start of wraper code generated automatically by Debug code generator for Okl_Create_Streams_Pvt.Create_Streams_Loan_Book
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPCSMB.pls call Okl_Create_Streams_Pvt.Create_Streams_Loan_Book ');
    END;
  END IF;
    Okl_Create_Streams_Pvt.Create_Streams_Loan_Book(   p_api_version   => p_api_version,
                                          	  p_init_msg_list => p_init_msg_list,
						  x_return_status => l_return_status,
						  x_msg_count     => x_msg_count,
						  x_msg_data      => x_msg_data,
						  p_skip_prc_engine	=> p_skip_prc_engine,
						  p_csm_loan_header	=> p_csm_loan_header,
						  p_csm_one_off_fee_tbl	=> p_csm_one_off_fee_tbl,
						  p_csm_periodic_expenses_tbl	=> p_csm_periodic_expenses_tbl,
						  p_csm_yields_tbl			=> p_csm_yields_tbl,
						  p_csm_stream_types_tbl	=> p_csm_stream_types_tbl,
						  p_csm_loan_lines_tbl	=> p_csm_loan_lines_tbl,
      							p_csm_loan_levels_tbl	=> p_csm_loan_levels_tbl,
						  x_trans_id		=> x_trans_id,
						  x_trans_status			=> x_trans_status);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPCSMB.pls call Okl_Create_Streams_Pvt.Create_Streams_Loan_Book ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Create_Streams_Pvt.Create_Streams_Loan_Book

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;


    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END Create_Streams_Loan_Book;

  ---------------------------------------------------------------------------
  -- PROCEDURE Create_Streams_Lease_Quote
  -- Public Wrapper for Create_Streams_Lease_Quote Process API
  ---------------------------------------------------------------------------
 PROCEDURE Create_Streams_Lease_Quote(
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_lease_header			IN  csm_lease_rec_type
       ,p_csm_one_off_fee_tbl			IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl			IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl				IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl			IN  csm_stream_types_tbl_type
       ,p_csm_line_details_tbl    	        	IN  csm_line_details_tbl_type
       ,p_rents_tbl		     		IN  csm_periodic_expenses_tbl_type
       ,x_trans_id	   			OUT NOCOPY NUMBER
       ,x_trans_status		 OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
       )
 IS
    l_api_name        CONSTANT VARCHAR2(30)  := 'Create_Streams_Lease_Quote';
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
    l_api_version     CONSTANT NUMBER := 1;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;

  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
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



	-- call process api to Create_Streams_Lease_Quote
-- Start of wraper code generated automatically by Debug code generator for OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Quote
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPCSMB.pls call OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Quote ');
    END;
  END IF;
    OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Quote(p_api_version   => p_api_version,
                                          	p_init_msg_list => p_init_msg_list,
                                          	p_skip_prc_engine		=> p_skip_prc_engine,
                                          	p_csm_lease_header		=> p_csm_lease_header,
                                          	p_csm_one_off_fee_tbl	=> p_csm_one_off_fee_tbl,
                                          	p_csm_periodic_expenses_tbl	=> p_csm_periodic_expenses_tbl,
                                          	p_csm_yields_tbl			=> p_csm_yields_tbl,
                                          	p_csm_stream_types_tbl	=> p_csm_stream_types_tbl,
                                          	p_csm_line_details_tbl    	=> p_csm_line_details_tbl,
                                          	p_rents_tbl		     	=> p_rents_tbl,
                                          	x_trans_id			=> x_trans_id,
                                          	x_trans_status			=> x_trans_status,
                                          	x_return_status => l_return_status,
                                          	x_msg_count     => x_msg_count,
                                          	x_msg_data      => x_msg_data);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPCSMB.pls call OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Quote ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Quote

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;



    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END Create_Streams_Lease_Quote;

   PROCEDURE invoke_pricing_engine(
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_sifv_rec				IN  sifv_rec_type
       ,x_sifv_rec				OUT NOCOPY  sifv_rec_type
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
   )
   IS
    l_api_name        CONSTANT VARCHAR2(30)  := 'invoke_pricing_engine';
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
    l_api_version     CONSTANT NUMBER := 1;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;

  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
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



	-- call process api to invoke_pricing_engine
-- Start of wraper code generated automatically by Debug code generator for OKL_CREATE_STREAMS_PVT.invoke_pricing_engine
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPCSMB.pls call OKL_CREATE_STREAMS_PVT.invoke_pricing_engine ');
    END;
  END IF;
    OKL_CREATE_STREAMS_PVT.invoke_pricing_engine(p_api_version   => p_api_version,
                                          	 p_init_msg_list => p_init_msg_list,
                                                 p_sifv_rec                 => p_sifv_rec,
                                                 x_sifv_rec                 => x_sifv_rec,
       						 x_msg_data      		=> l_data,
       						 x_msg_count     		=> l_count,
       						 x_return_status 		=> l_return_status);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPCSMB.pls call OKL_CREATE_STREAMS_PVT.invoke_pricing_engine ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_CREATE_STREAMS_PVT.invoke_pricing_engine


     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;



    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
   END invoke_pricing_engine;

  ---------------------------------------------------------------------------
  -- PROCEDURE Create_Streams_Lease_Restruct
  -- Public Wrapper for Create_Streams_Lease_Restruct Process API
  ---------------------------------------------------------------------------
 PROCEDURE Create_Streams_Lease_Restr(
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_lease_header			IN  csm_lease_rec_type
       ,p_csm_one_off_fee_tbl			IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl			IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl				IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl			IN  csm_stream_types_tbl_type
       ,p_csm_line_details_tbl    	        	IN  csm_line_details_tbl_type
       ,p_rents_tbl		     		IN  csm_periodic_expenses_tbl_type
       ,x_trans_id	   			OUT NOCOPY NUMBER
       ,x_trans_status		 OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
       )
 IS
    l_api_name        CONSTANT VARCHAR2(30)  := 'Create_Streams_Lease_Restr';
    l_return_status   VARCHAR2(1)    := G_RET_STS_SUCCESS;
    l_api_version     CONSTANT NUMBER := 1;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;

  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
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





	-- call process api to Create_Streams_Lease_Restruct
-- Start of wraper code generated automatically by Debug code generator for OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Restr
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPCSMB.pls call OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Restr ');
    END;
  END IF;
    OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Restr(p_api_version   => p_api_version,
                                          	p_init_msg_list => p_init_msg_list,
                                          	p_skip_prc_engine		=> p_skip_prc_engine,
                                          	p_csm_lease_header		=> p_csm_lease_header,
                                          	p_csm_one_off_fee_tbl	=> p_csm_one_off_fee_tbl,
                                          	p_csm_periodic_expenses_tbl	=> p_csm_periodic_expenses_tbl,
                                          	p_csm_yields_tbl			=> p_csm_yields_tbl,
                                          	p_csm_stream_types_tbl	=> p_csm_stream_types_tbl,
                                          	p_csm_line_details_tbl    	=> p_csm_line_details_tbl,
                                          	p_rents_tbl		     	=> p_rents_tbl,
                                          	x_trans_id			=> x_trans_id,
                                          	x_trans_status			=> x_trans_status,
                                          	x_return_status => l_return_status,
                                          	x_msg_count     => x_msg_count,
                                          	x_msg_data      => x_msg_data);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPCSMB.pls call OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Restr ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_CREATE_STREAMS_PVT.Create_Streams_Lease_Restr

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;



    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END Create_Streams_Lease_Restr;

  ---------------------------------------------------------------------------
  -- PROCEDURE Create_Streams_Loan_Restruct
  -- Public Wrapper for Process API Create_Streams_Loan_Restruct
  ---------------------------------------------------------------------------
  PROCEDURE Create_Streams_Loan_Restr(
        p_api_version                  		IN  NUMBER
       ,p_init_msg_list                		IN  VARCHAR2 DEFAULT G_FALSE
       ,p_skip_prc_engine			IN  VARCHAR2 DEFAULT G_FALSE
       ,p_csm_loan_header			IN  csm_loan_rec_type
       ,p_csm_loan_lines_tbl			IN  csm_loan_line_tbl_type
       ,p_csm_loan_levels_tbl			IN  csm_loan_level_tbl_type
       ,p_csm_one_off_fee_tbl		IN  csm_one_off_fee_tbl_type
       ,p_csm_periodic_expenses_tbl	IN  csm_periodic_expenses_tbl_type
       ,p_csm_yields_tbl			IN  csm_yields_tbl_type
       ,p_csm_stream_types_tbl		IN  csm_stream_types_tbl_type
       ,x_trans_id	   			    OUT NOCOPY NUMBER
       ,x_trans_status	   						OUT NOCOPY VARCHAR2
       ,x_return_status                		OUT NOCOPY VARCHAR2
       ,x_msg_count                    		OUT NOCOPY NUMBER
       ,x_msg_data                     		OUT NOCOPY VARCHAR2
       ) IS

    l_api_name        	  	CONSTANT VARCHAR2(30)  := 'Create_Streams_Loan_Restr';
    l_return_status   	  	VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_data            VARCHAR2(100);
    l_count           NUMBER ;
    l_api_version     CONSTANT NUMBER := 1;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
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





	-- call process api to update formulae
-- Start of wraper code generated automatically by Debug code generator for Okl_Create_Streams_Pvt.Create_Streams_Loan_Restr
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPCSMB.pls call Okl_Create_Streams_Pvt.Create_Streams_Loan_Restr ');
    END;
  END IF;
    Okl_Create_Streams_Pvt.Create_Streams_Loan_Restr(   p_api_version   => p_api_version,
                                          	  p_init_msg_list => p_init_msg_list,
						  x_return_status => l_return_status,
						  x_msg_count     => x_msg_count,
						  x_msg_data      => x_msg_data,
						  p_skip_prc_engine	=> p_skip_prc_engine,
						  p_csm_loan_header	=> p_csm_loan_header,
						  p_csm_one_off_fee_tbl	=> p_csm_one_off_fee_tbl,
						  p_csm_periodic_expenses_tbl	=> p_csm_periodic_expenses_tbl,
						  p_csm_yields_tbl			=> p_csm_yields_tbl,
						  p_csm_stream_types_tbl	=> p_csm_stream_types_tbl,
						  p_csm_loan_lines_tbl	=> p_csm_loan_lines_tbl,
      							p_csm_loan_levels_tbl	=> p_csm_loan_levels_tbl,
						  x_trans_id		=> x_trans_id,
						  x_trans_status			=> x_trans_status);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPCSMB.pls call Okl_Create_Streams_Pvt.Create_Streams_Loan_Restr ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Create_Streams_Pvt.Create_Streams_Loan_Restr

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;


    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count,
						 x_msg_data	  => x_msg_data);
	x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
	  				  	 						   p_pkg_name	=> G_PKG_NAME,
												   p_exc_name   => G_EXC_NAME_OTHERS,
												   x_msg_count	=> x_msg_count,
												   x_msg_data	=> x_msg_data,
												   p_api_type	=> G_API_TYPE);
  END Create_Streams_Loan_Restr;


END OKL_CREATE_STREAMS_PUB;

/
