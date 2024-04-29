--------------------------------------------------------
--  DDL for Package Body OKL_PAYMENT_APPLICATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAYMENT_APPLICATION_PUB" AS
/* $Header: OKLPPYAB.pls 115.4 2002/12/02 04:47:46 arajagop noship $*/


-- Global Variables
   G_DEBUG       NUMBER := 1;
   G_INIT_NUMBER NUMBER := -9999;
   G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_PAYMENT_APPLICATION_PUB';
   G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
   G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PUB';

------------------------------------------------------------------------------
-- PROCEDURE apply_payment
--
--  This procedure proportion-ed the payments accross Financial Asset Top Line
--  and Fee Top Line
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE apply_payment(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_stream_id     IN  OKC_RULES_V.OBJECT1_ID1%TYPE
                         ) IS
  l_api_name    CONSTANT VARCHAR2(30) := 'APPLY_PAYMENT';
  l_api_version CONSTANT NUMBER := 1.0;
  l_chr_id      OKC_K_HEADERS_V.ID%TYPE;

  BEGIN -- main process begins here

     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      l_chr_id := p_chr_id;


      --Call pre Vertical Hook :


      okl_payment_application_pvt.apply_payment(
                                                p_api_version => 1.0,
                                                p_init_msg_list => OKC_API.G_FALSE,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data,
                                                p_chr_id        => p_chr_id,
                                                p_stream_id     => p_stream_id
                                               );

      IF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      --Call After Horizontal Hook

      --Call After Vertical Hook :


     --Call End Activity
     OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
     		          x_msg_data    => x_msg_data);

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END apply_payment;

------------------------------------------------------------------------------
-- PROCEDURE delete_payment
--
--  This procedure deletes payments from a contract
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE delete_payment(
                          p_api_version   IN  NUMBER,
                          p_init_msg_list IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          p_chr_id        IN  OKC_K_HEADERS_V.ID%TYPE,
                          p_rgp_id        IN  OKC_RULE_GROUPS_V.ID%TYPE,
                          p_rule_id       IN  OKC_RULES_V.ID%TYPE
                         ) IS
  l_api_name    CONSTANT VARCHAR2(30) := 'DELETE_PAYMENT';
  l_api_version CONSTANT NUMBER := 1.0;

  BEGIN -- main process begins here

     x_return_status := OKC_API.G_RET_STS_SUCCESS;
     -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => G_PKG_NAME,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;



      --Call pre Vertical Hook :


      okl_payment_application_pvt.delete_payment(
                                                p_api_version => 1.0,
                                                p_init_msg_list => OKC_API.G_FALSE,
                                                x_return_status => x_return_status,
                                                x_msg_count     => x_msg_count,
                                                x_msg_data      => x_msg_data,
                                                p_chr_id        => p_chr_id,
                                                p_rgp_id        => p_rgp_id,
                                                p_rule_id       => p_rule_id
                                               );

      IF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      --Call After Horizontal Hook

      --Call After Vertical Hook :


     --Call End Activity
     OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
     		          x_msg_data    => x_msg_data);

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => G_PKG_NAME,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => G_API_TYPE);

  END delete_payment;

END OKL_PAYMENT_APPLICATION_PUB;

/
