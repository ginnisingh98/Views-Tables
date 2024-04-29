--------------------------------------------------------
--  DDL for Package Body OKL_INVOKE_PRICING_ENGINE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INVOKE_PRICING_ENGINE_PUB" AS
/* $Header: OKLPSSMB.pls 115.5 2004/04/13 11:21:25 rnaik noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE GENERATE_STREAMS
  ---------------------------------------------------------------------------
PROCEDURE generate_streams_st(
          p_api_version                  IN  NUMBER,
          p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
          x_return_status                OUT NOCOPY VARCHAR2,
          x_msg_count                    OUT NOCOPY NUMBER,
          x_msg_data                     OUT NOCOPY VARCHAR2,
          p_xmlg_trx_type                IN  VARCHAR2,
          p_xmlg_trx_sub_type            IN  VARCHAR2,
          p_sifv_rec                      IN  OKL_SIF_PVT.SIFV_REC_TYPE)
 IS

    l_return_status                   VARCHAR2(1)    := G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30)  := 'generate_streams_st';
    l_api_version     CONSTANT NUMBER := 1;
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



    OKL_INVOKE_PRICING_ENGINE_PVT.generate_streams_st(
              p_api_version       => p_api_version,
              p_init_msg_list     => p_init_msg_list,
              x_return_status     => l_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              p_xmlg_trx_type     => p_xmlg_trx_type,
              p_xmlg_trx_sub_type => p_xmlg_trx_sub_type,
              p_sifv_rec           => p_sifv_rec );

     IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;



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
  END generate_streams_st;

END OKL_INVOKE_PRICING_ENGINE_PUB;

/
