--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_STATUS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_STATUS_PUB" as
/* $Header: OKLPSTKB.pls 115.2 2002/11/30 08:40:52 spillaip noship $ */

-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_NO_PARENT_RECORD    CONSTANT  VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_FND_APP		        CONSTANT  VARCHAR2(200) := OKC_API.G_FND_APP;
  G_REQUIRED_VALUE	    CONSTANT  VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT  VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR    CONSTANT  VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED	CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UPPERCASE_REQ';
  G_COL_NAME_TOKEN      CONSTANT  VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                CONSTANT  VARCHAR2(4) := '_PUB';
  G_API_VERSION             CONSTANT  NUMBER      := 1.0;
  G_SCOPE                   CONSTANT  VARCHAR2(4) := '_PUB';

 -- GLOBAL VARIABLES
-----------------------------------------------------------------------------------

  Procedure get_contract_status(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            x_isAllowed       OUT NOCOPY BOOLEAN,
            x_PassStatus      OUT NOCOPY VARCHAR2,
            x_FailStatus      OUT NOCOPY VARCHAR2,
            p_event           IN  VARCHAR2,
            p_chr_id          IN  VARCHAR2)  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'RETURN_CONTRACT_STATUS';
    l_api_version	CONSTANT NUMBER	      := 1;



  BEGIN

--    x_return_status  := OKC_API.G_RET_STS_SUCCESS;


    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

        OKL_CONTRACT_STATUS_PVT.get_contract_status(
                                          p_api_version,
                                          p_init_msg_list,
                                          x_return_status,
                                          x_msg_count,
                                          x_msg_data,
                                          x_isAllowed,
                                          x_PassStatus,
                                          x_FailStatus,
                                          p_event,
                                          p_chr_id);

       OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

    Exception
	when OKC_API.G_EXCEPTION_ERROR then
		x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END get_contract_status;

  Procedure update_contract_status(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_khr_status      IN VARCHAR2,
            p_chr_id          IN  VARCHAR2)  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_STATUS';
    l_api_version	CONSTANT NUMBER	      := 1;

  BEGIN

--    x_return_status  := OKC_API.G_RET_STS_SUCCESS;


    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;

        OKL_CONTRACT_STATUS_PVT.update_contract_status(
                                          p_api_version,
                                          p_init_msg_list,
                                          x_return_status,
                                          x_msg_count,
                                          x_msg_data,
                                          p_khr_status,
                                          p_chr_id);

       OKC_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data => x_msg_data);

    Exception
	when OKC_API.G_EXCEPTION_ERROR then
		x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END update_contract_status;

Procedure cascade_lease_status
            (p_api_version     IN  NUMBER,
             p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2,
             p_chr_id          IN  NUMBER) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CASCADE_LEASE_STS';
    l_api_version	CONSTANT NUMBER	      := 1;

  BEGIN

        OKL_CONTRACT_STATUS_PVT.cascade_lease_status
            (p_api_version,
             p_init_msg_list,
             x_return_status,
             x_msg_count,
             x_msg_data,
             p_chr_id);


    Exception
	when OKC_API.G_EXCEPTION_ERROR then
		x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END cascade_lease_status;



Procedure cascade_lease_status_edit
            (p_api_version     IN  NUMBER,
             p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2,
             p_chr_id          IN  NUMBER) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'CASCADE_LEASE_STS_E';
    l_api_version	CONSTANT NUMBER	      := 1;

  BEGIN

        OKL_CONTRACT_STATUS_PVT.cascade_lease_status_edit
            (p_api_version,
             p_init_msg_list,
             x_return_status,
             x_msg_count,
             x_msg_data,
             p_chr_id);


    Exception
	when OKC_API.G_EXCEPTION_ERROR then
		x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END cascade_lease_status_edit;


End OKL_CONTRACT_STATUS_PUB;

/
