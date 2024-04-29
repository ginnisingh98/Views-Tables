--------------------------------------------------------
--  DDL for Package Body OKL_GENERATE_STREAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_GENERATE_STREAMS_PUB" AS
/* $Header: OKLPGSMB.pls 115.11 2004/04/13 10:47:05 rnaik noship $ */

  ---------------------------------------------------------------------------
  -- PROCEDURE GENERATE_STREAMS
  ---------------------------------------------------------------------------
  PROCEDURE GENERATE_STREAMS(p_api_version          IN         NUMBER
                             ,p_init_msg_list       IN         VARCHAR2
                             ,p_khr_id              IN         NUMBER
                             ,p_generation_ctx_code IN         VARCHAR2
                             ,x_trx_number          OUT NOCOPY NUMBER
                             ,x_trx_status          OUT NOCOPY VARCHAR2
                             ,x_return_status       OUT NOCOPY VARCHAR2
                             ,x_msg_count           OUT NOCOPY NUMBER
                             ,x_msg_data            OUT NOCOPY VARCHAR2)
  IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_name VARCHAR2(31) := 'GENERATE_STREAMS';
    l_api_version NUMBER := 1;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name       => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version    => l_api_version,
                                              p_api_version    => p_api_version,
                                              p_api_type       => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;



    Okl_Generate_Streams_Pvt.generate_streams(p_api_version          => p_api_version
                                              ,p_init_msg_list       => p_init_msg_list
					      ,p_khr_id              => p_khr_id
					      ,p_generation_ctx_code => p_generation_ctx_code
					      ,x_trx_number          => x_trx_number
					      ,x_trx_status          => x_trx_status
					      ,x_return_status       => l_return_status
					      ,x_msg_count           => x_msg_count
					      ,x_msg_data            => x_msg_data);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;



    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data);
    x_return_status := l_return_status;

   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => G_EXC_NAME_RET_STS_ERR,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => G_EXC_NAME_RET_STS_UNEXP_ERR,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => G_EXC_NAME_OTHERS,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);

  END GENERATE_STREAMS;


  ---------------------------------------------------------------------------
  -- PROCEDURE POPULATE_HEADER_DATA
  ---------------------------------------------------------------------------
  PROCEDURE POPULATE_HEADER_DATA(p_api_version          IN         NUMBER
                                 ,p_init_msg_list       IN         VARCHAR2
                                 ,p_khr_id              IN         NUMBER
                                 ,p_generation_ctx_code IN         VARCHAR2
                                 ,x_trx_number          OUT NOCOPY NUMBER
                                 ,x_return_status       OUT NOCOPY VARCHAR2
                                 ,x_msg_count           OUT NOCOPY NUMBER
                                 ,x_msg_data            OUT NOCOPY VARCHAR2)
  IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_name VARCHAR2(31) := 'POPULATE_HEADER_DATA';
    l_api_version NUMBER := 1;
  BEGIN
--dbms_output.put_line('inside gen stream pub');
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name       => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version    => l_api_version,
                                              p_api_version    => p_api_version,
                                              p_api_type       => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;


--dbms_output.put_line('calling gen stream pvt');
    Okl_Generate_Streams_Pvt.populate_header_data(p_api_version          => p_api_version
                                                  ,p_init_msg_list       => p_init_msg_list
					          ,p_khr_id              => p_khr_id
					          ,p_generation_ctx_code => p_generation_ctx_code
					          ,x_trx_number          => x_trx_number
					          ,x_return_status       => l_return_status
					          ,x_msg_count           => x_msg_count
					          ,x_msg_data            => x_msg_data);

     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;
--dbms_output.put_line('back from  gen stream pvt' || l_return_status);


    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data);
    x_return_status := l_return_status;

   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => G_EXC_NAME_RET_STS_ERR,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => G_EXC_NAME_RET_STS_UNEXP_ERR,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => G_EXC_NAME_OTHERS,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);

  END POPULATE_HEADER_DATA;


  ---------------------------------------------------------------------------
  -- PROCEDURE INVOKE_PRICING_ENGINE
  ---------------------------------------------------------------------------
  PROCEDURE INVOKE_PRICING_ENGINE(p_api_version          IN         NUMBER
                                  ,p_init_msg_list       IN         VARCHAR2
                                  ,p_trx_number          in NUMBER
                                  ,x_trx_number          OUT NOCOPY NUMBER
                                  ,x_trx_status          OUT NOCOPY VARCHAR2
                                  ,x_return_status       OUT NOCOPY VARCHAR2
                                  ,x_msg_count           OUT NOCOPY NUMBER
                                  ,x_msg_data            OUT NOCOPY VARCHAR2)
  IS
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_api_name VARCHAR2(31) := 'INVOKE_PRICING_ENGINE';
    l_api_version NUMBER := 1;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name       => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version    => l_api_version,
                                              p_api_version    => p_api_version,
                                              p_api_type       => G_API_TYPE,
                                              x_return_status  => l_return_status);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;


--DBMS_OUTPUT.PUT_LINE('pub to pvt');
    Okl_Generate_Streams_Pvt.invoke_pricing_engine(p_api_version    => p_api_version
                                                   ,p_init_msg_list => p_init_msg_list
					           ,p_trx_number    => p_trx_number
					           ,x_trx_number    => x_trx_number
					           ,x_trx_status    => x_trx_status
					           ,x_return_status => l_return_status
					           ,x_msg_count     => x_msg_count
					           ,x_msg_data      => x_msg_data);
--DBMS_OUTPUT.PUT_LINE('pvt ok?' || l_return_status);
     IF l_return_status = G_RET_STS_ERROR THEN
        RAISE G_EXCEPTION_ERROR;
     ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;



    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data);
    x_return_status := l_return_status;

   EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => G_EXC_NAME_RET_STS_ERR,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => G_EXC_NAME_RET_STS_UNEXP_ERR,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name  => l_api_name,
                                                   p_pkg_name  => G_PKG_NAME,
                                                   p_exc_name  => G_EXC_NAME_OTHERS,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data  => x_msg_data,
                                                   p_api_type  => G_API_TYPE);

  END INVOKE_PRICING_ENGINE;
END OKL_GENERATE_STREAMS_PUB;

/
