--------------------------------------------------------
--  DDL for Package Body OKL_CREDIT_MGNT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREDIT_MGNT_PUB" AS
/* $Header: OKLPCMTB.pls 115.2 2003/02/05 18:32:47 rgalipo noship $ */

  --
  PROCEDURE submit_credit_request
                    (p_api_version              IN  NUMBER
                    ,p_init_msg_list            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                    ,x_return_status            OUT NOCOPY VARCHAR2
                    ,x_msg_count                OUT NOCOPY NUMBER
                    ,x_msg_data                 OUT NOCOPY VARCHAR2
                    ,p_contract_id              IN  NUMBER
                    ,p_review_type              IN  VARCHAR2  -- application purpose
                    ,p_credit_classification    IN  VARCHAR2
                    ,p_requested_amount         IN  NUMBER
                    ,p_contact_party_id         IN  NUMBER
                    ,p_notes                    IN  VARCHAR2
                    ,p_chr_rec                  IN  okl_credit_mgnt_pvt.l_chr_rec
                    ) IS

  l_return_status   VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
  l_api_version     CONSTANT NUMBER := 1;


  BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name      => G_APP_NAME,
                                              p_pkg_name	     => G_PKG_NAME,
                                              p_init_msg_list => p_init_msg_list,
                                              l_api_version	  => l_api_version,
                                              p_api_version	  => p_api_version,
                                              p_api_type	     => G_API_TYPE,
                                              x_return_status => l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;


   okl_credit_mgnt_pvt.submit_credit_request
                    (p_api_version           => p_api_version
                    ,p_init_msg_list         => p_init_msg_list
                    ,x_return_status         => x_return_status
                    ,x_msg_count             => x_msg_count
                    ,x_msg_data              => x_msg_data
                    ,p_contract_id           => p_contract_id
                    ,p_review_type           => p_review_type
                    ,p_credit_classification => p_credit_classification
                    ,p_requested_amount      => p_requested_amount
                    ,p_contact_party_id      => p_contact_party_id
                    ,p_notes                 => p_notes
                    ,p_chr_rec               => p_chr_rec
                    );


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

  okl_api.end_activity(x_msg_count => x_msg_count,
                       x_msg_data	 => x_msg_data);
  -- x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name  => G_APP_NAME,
                     p_pkg_name  => G_PKG_NAME,
                     p_exc_name  => G_EXC_NAME_ERROR,
                     x_msg_count => x_msg_count,
                     x_msg_data  => x_msg_data,
                     p_api_type  => G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name  => G_APP_NAME,
                     p_pkg_name  => G_PKG_NAME,
                     p_exc_name  => G_EXC_NAME_UNEXP_ERROR,
                     x_msg_count => x_msg_count,
                     x_msg_data  => x_msg_data,
                     p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name  => G_APP_NAME,
                     p_pkg_name  => G_PKG_NAME,
                     p_exc_name  => G_EXC_NAME_OTHERS,
                     x_msg_count => x_msg_count,
                     x_msg_data  => x_msg_data,
                     p_api_type  => G_API_TYPE);
  END; -- submit_credit_request


  PROCEDURE compile_credit_request
                    (p_api_version              IN  NUMBER
                    ,p_init_msg_list            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
                    ,x_return_status            OUT NOCOPY VARCHAR2
                    ,x_msg_count                OUT NOCOPY NUMBER
                    ,x_msg_data                 OUT NOCOPY VARCHAR2
                    ,p_contract_id              IN  NUMBER
                    ,x_chr_rec                  OUT NOCOPY okl_credit_mgnt_pvt.l_chr_rec
                    ) IS

  l_return_status   VARCHAR2(1)     := OKL_API.G_RET_STS_SUCCESS;
  l_api_version     CONSTANT NUMBER := 1;


  BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name      => G_APP_NAME,
                                              p_pkg_name	     => G_PKG_NAME,
                                              p_init_msg_list => p_init_msg_list,
                                              l_api_version	  => l_api_version,
                                              p_api_version	  => p_api_version,
                                              p_api_type	     => G_API_TYPE,
                                              x_return_status => l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

   okl_credit_mgnt_pvt.compile_credit_request
                    (p_api_version           => p_api_version
                    ,p_init_msg_list         => p_init_msg_list
                    ,x_return_status         => x_return_status
                    ,x_msg_count             => x_msg_count
                    ,x_msg_data              => x_msg_data
                    ,p_contract_id           => p_contract_id
                    ,x_chr_rec               => x_chr_rec
                    );


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

  okl_api.end_activity(x_msg_count => x_msg_count,
                       x_msg_data	 => x_msg_data);

  x_return_status := l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name  => G_APP_NAME,
                     p_pkg_name  => G_PKG_NAME,
                     p_exc_name  => G_EXC_NAME_ERROR,
                     x_msg_count => x_msg_count,
                     x_msg_data  => x_msg_data,
                     p_api_type  => G_API_TYPE);
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name  => G_APP_NAME,
                     p_pkg_name  => G_PKG_NAME,
                     p_exc_name  => G_EXC_NAME_UNEXP_ERROR,
                     x_msg_count => x_msg_count,
                     x_msg_data  => x_msg_data,
                     p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name  => G_APP_NAME,
                     p_pkg_name  => G_PKG_NAME,
                     p_exc_name  => G_EXC_NAME_OTHERS,
                     x_msg_count => x_msg_count,
                     x_msg_data  => x_msg_data,
                     p_api_type  => G_API_TYPE);
  END compile_credit_request;



END OKL_CREDIT_MGNT_PUB;

/
