--------------------------------------------------------
--  DDL for Package Body OKL_SEC_AGREMNT_BOOK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SEC_AGREMNT_BOOK_PVT" as
/* $Header: OKLRSZBB.pls 120.2 2007/12/21 14:10:44 kthiruva ship $ */

-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_NO_PARENT_RECORD    CONSTANT  VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_FND_APP		        CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_REQUIRED_VALUE	    CONSTANT  VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT  VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR    CONSTANT  VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED	CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UPPERCASE_REQ';
  G_COL_NAME_TOKEN      CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION             CONSTANT  NUMBER      := 1.0;
  G_SCOPE                   CONSTANT  VARCHAR2(4) := '_PVT';

 -- GLOBAL VARIABLES
-----------------------------------------------------------------------------------

  Procedure execute_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    x_msg_tbl                      OUT NOCOPY OKL_QA_CHECK_PUB.msg_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'EXECUTE_QA_CHECK_LIST';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
    l_PassStatus Varchar2(30) := 'INCOMPLETE'; --'PASSED';
    l_FailStatus Varchar2(256) := 'INCOMPLETE';
    severity VARCHAR2(1);
    l_msg_tbl           OKL_QA_CHECK_PUB.msg_tbl_type;
    j NUMBER;


    Cursor l_dltype_csr ( chrId NUMBER ) IS
    select khr.deal_type
    from okc_K_headers_v chr,
         okl_K_headers khr
    where chr.id = khr.id
        and chr.id = chrId;

    l_dltype_rec l_dltype_csr%ROWTYPE;

  BEGIN

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OPEN l_dltype_csr( p_chr_id);
    FETCH l_dltype_csr INTO l_dltype_rec;
    If ( l_dltype_csr%NOTFOUND) Then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    End If;

    OKL_QA_CHECK_PUB.execute_qa_check_list(
                             p_api_version,
                             p_init_msg_list,
                             x_return_status,
                             x_msg_count,
                             x_msg_data,
                             p_qcl_id,
                             p_chr_id,
                             x_msg_tbl);


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    FOR i in 1..x_msg_tbl.COUNT
    LOOP
        If ( x_msg_tbl(i).name <> 'Check Email Address' )  Then
	    l_msg_tbl(l_msg_tbl.COUNT + 1) := x_msg_tbl(i);
        End If;
    END LOOP;
    x_msg_tbl := l_msg_tbl;

    severity := 'S';
    FOR i in 1..x_msg_tbl.COUNT
    LOOP
        If ( x_msg_tbl(i).error_status = 'E' )  Then
            severity := 'E';
            Exit;
        End If;
    END LOOP;




   IF((x_return_status = Okl_Api.G_RET_STS_SUCCESS) AND (severity='S')) THEN
        OKL_SEC_AGREEMENT_PVT.update_sec_agreement_sts(
                                       l_api_version,
                                       p_init_msg_list,
                                       x_return_status,
                                       x_msg_count,
                                       x_msg_data,
                                       l_PassStatus,
                                       p_chr_id );
    ELSE
        OKL_SEC_AGREEMENT_PVT.update_sec_agreement_sts(
                                       l_api_version,
                                       p_init_msg_list,
                                       x_return_status,
                                       x_msg_count,
                                       x_msg_data,
                                       l_FailStatus,
                                       p_chr_id );
    End If;

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);
    ---
    Exception
	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END execute_qa_check_list;

  Procedure activate_contract(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2)  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'ACTIVATE_INV_AGMNT';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_isAllowed         BOOLEAN;
    l_PassStatus        VARCHAR2(100):= 'BOOKED';
    l_FailStatus        VARCHAR2(100) := 'APPROVED';
    l_event             VARCHAR2(100) := OKL_CONTRACT_STATUS_PUB.G_K_ACTIVATE;
    l_cimv_tbl          OKL_OKC_MIGRATION_PVT.cimv_tbl_type;
    x_message           VARCHAR2(256);


  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    okl_sec_agreement_pvt.activate_sec_agreement(
                                       p_api_version => l_api_version,
                                       p_init_msg_list => p_init_msg_list,
                                       x_return_status => x_return_status,
                                       x_msg_count => x_msg_count,
                                       x_msg_data => x_msg_data,
                                       p_khr_id => p_chr_id );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     OKL_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => 'OKL_LLA_AC_SUCCESS');

    x_return_status := OKL_API.G_RET_STS_SUCCESS;


    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    Exception
	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END activate_contract;

  Procedure check_reconciled(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2)  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'RECONCILED';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_isAllowed         BOOLEAN;
    l_PassStatus        VARCHAR2(100):= 'BOOKED';
    l_FailStatus        VARCHAR2(100) := 'APPROVED';
    l_event             VARCHAR2(100) := OKL_CONTRACT_STATUS_PUB.G_K_ACTIVATE;
    l_cimv_tbl          OKL_OKC_MIGRATION_PVT.cimv_tbl_type;
    x_message           VARCHAR2(256);

    pool_rec pool_csr%ROWTYPE;
    x_reconciled VARCHAR2(1);

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OPEN pool_csr ( p_chr_id );
    FETCH pool_csr INTO pool_rec;
    CLOSE pool_csr;

    OKL_POOL_PVT.reconcile_contents(
                                p_api_version => l_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data,
                                p_pol_id => pool_rec.id,
                                x_reconciled => x_reconciled );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF ( x_reconciled = OKL_API.G_TRUE ) Then
        x_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.set_message(
                    p_app_name      => G_APP_NAME,
                    p_msg_name      => 'OKL_LLA_RECONCILED');
        raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;


    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    Exception
	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END check_reconciled;

  Procedure check_event(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_event           IN  VARCHAR2,
            p_chr_id          IN  VARCHAR2)  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'EVENT';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_isAllowed         BOOLEAN;
    l_PassStatus        VARCHAR2(100):= 'BOOKED';
    l_FailStatus        VARCHAR2(100) := 'APPROVED';
    l_event             VARCHAR2(100) := OKL_CONTRACT_STATUS_PUB.G_K_ACTIVATE;
    l_cimv_tbl          OKL_OKC_MIGRATION_PVT.cimv_tbl_type;
    x_message           VARCHAR2(256);


  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;


    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    Exception
	when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END check_event;

  --Added by kthiruva on 18-Dec-2007
  -- New method to validate an add request on an active investor agreement
  --Bug 6691554 - Start of Changes
  Procedure validate_add_request(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  NUMBER)
   IS

    l_api_name		CONSTANT VARCHAR2(30) := 'validate_add_request';
    l_api_version	CONSTANT NUMBER	      := 1.0;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_event             VARCHAR2(100) := OKL_CONTRACT_STATUS_PUB.G_K_ACTIVATE;
    x_message           VARCHAR2(256);


  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    okl_sec_agreement_pvt.validate_add_request(
                                       p_api_version => l_api_version,
                                       p_init_msg_list => p_init_msg_list,
                                       x_return_status => x_return_status,
                                       x_msg_count => x_msg_count,
                                       x_msg_data => x_msg_data,
                                       p_chr_id => p_chr_id );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

  Exception
  when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END validate_add_request;
  -- Bug 6691554 - End of Changes


End OKL_SEC_AGREMNT_BOOK_PVT;

/
