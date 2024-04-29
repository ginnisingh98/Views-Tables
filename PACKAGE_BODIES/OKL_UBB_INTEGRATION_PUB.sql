--------------------------------------------------------
--  DDL for Package Body OKL_UBB_INTEGRATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_UBB_INTEGRATION_PUB" AS
/* $Header: OKLPUBIB.pls 115.1 2002/05/10 12:11:10 pkm ship     $*/

-- Global Variables
   G_DEBUG       NUMBER := 1;
   G_INIT_NUMBER NUMBER := -9999;

------------------------------------------------------------------------------
-- PROCEDURE create_ubb_contract
--
--  This procedure creats Service Contract corresponding to Usage Base Line
--  for a given contract. It also registers error, if any and it is calling
--  modules responsibility to print error message from error stack
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
  PROCEDURE create_ubb_contract (
                             p_api_version    IN  NUMBER,
                             p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2,
                             p_chr_id         IN  OKC_K_HEADERS_V.ID%TYPE,
                             x_chr_id         OUT NOCOPY OKC_K_HEADERS_V.ID%TYPE
                           ) IS


   l_proc_name               VARCHAR2(35)          := 'CREATE_UBB_CONTRACT';
   l_api_name                CONSTANT VARCHAR2(30) := 'CREATE_UBB_CONTRACT';
   l_api_version             CONSTANT NUMBER       := 1;

   BEGIN -- main process starts here

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

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      okl_ubb_integration_pvt.create_ubb_contract(
                                                  p_api_version   => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                                                  x_return_status => x_return_status,
                                                  x_msg_count     => x_msg_count,
                                                  x_msg_data      => x_msg_data,
                                                  p_chr_id        => p_chr_id,
                                                  x_chr_id        => x_chr_id
                                                 );

      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

      -- End activity

      OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
		           x_msg_data	=> x_msg_data);

   Exception
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

  END create_ubb_contract;

END OKL_UBB_INTEGRATION_PUB;

/
