--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_BOOK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_BOOK_PUB" as
/* $Header: OKLPBKGB.pls 120.4 2007/05/11 22:42:55 asahoo ship $ */

-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_NO_PARENT_RECORD    CONSTANT  VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_FND_APP		        CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_REQUIRED_VALUE	    CONSTANT  VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT  VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR    CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED	CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UPPERCASE_REQ';
  G_COL_NAME_TOKEN      CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
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

  Procedure execute_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    x_msg_tbl                      OUT NOCOPY OKL_QA_CHECK_PUB.msg_tbl_type) IS

    l_api_name		CONSTANT VARCHAR2(30) := 'EXECUTE_QA_CHECK_LIST';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_qcl_id NUMBER := p_qcl_id;
    l_chr_id NUMBER := p_chr_id;

  BEGIN




    OKL_CONTRACT_BOOK_PVT.execute_qa_check_list(
                             p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_qcl_id         => p_qcl_id,
                             p_chr_id         => p_chr_id,
                             x_msg_tbl        => x_msg_tbl);


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



  END execute_qa_check_list;

  Procedure generate_journal_entries(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_commit           IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_draft_yn         IN  VARCHAR2 DEFAULT OKC_Api.G_TRUE,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2)  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'GENERATE_JNL_ENTRIES';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_commit VARCHAR(1) := p_commit;
    l_contract_id NUMBER := p_contract_id;
    l_transaction_type VARCHAR2(256) := p_transaction_type;
    l_draft_yn VARCHAR2(1) := p_draft_yn;
    l_memo_yn VARCHAR2(1) := OKL_API.G_TRUE;

  BEGIN



    OKL_CONTRACT_BOOK_PVT.generate_journal_entries(
                      p_api_version,
                      p_init_msg_list,
                      p_commit,
                      p_contract_id,
                      p_transaction_type,
                      p_draft_yn,
                      x_return_status,
                      x_msg_count,
                      x_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



  END generate_journal_entries;

  Procedure generate_streams(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            p_chr_id             IN  VARCHAR2,
            p_generation_context IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2)  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'MAP_AND_GEN_STREAMS';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_chr_id VARCHAR2(256) := p_chr_id;
    l_generation_context VARCHAR2(256) := p_generation_context;
    l_skip_prc_engine VARCHAR2(1) := OKL_API.G_TRUE;
    x_trx_number      NUMBER;
    x_trx_status      VARCHAR2(30);

  BEGIN

    OKL_CONTRACT_BOOK_PVT.generate_streams(
                     p_api_version        => p_api_version,
                     p_init_msg_list      => p_init_msg_list,
                     p_chr_id             => p_chr_id,
                     p_generation_context => p_generation_context,
                     x_return_status      => x_return_status,
                     x_msg_count          => x_msg_count,
                     x_msg_data           => x_msg_data,
                     x_trx_number         => x_trx_number,
                     x_trx_status         => x_trx_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  END generate_streams;

  Procedure submit_for_approval(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2)  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'SUBMIT_FOR_APPROVAL';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
    l_chr_id VARCHAR2(256) := p_chr_id;

  BEGIN




        OKL_CONTRACT_BOOK_PVT.submit_for_approval(
                                          p_api_version,
                                          p_init_msg_list,
                                          x_return_status,
                                          x_msg_count,
                                          x_msg_data,
                                          p_chr_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;




  END submit_for_approval;

  Procedure activate_contract(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2)  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'ACTIVATE_CONTRACT';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_chr_id VARCHAR2(256) := p_chr_id;
  BEGIN





        OKL_CONTRACT_BOOK_PVT.activate_contract(
                                          p_api_version,
                                          p_init_msg_list,
                                          x_return_status,
                                          x_msg_count,
                                          x_msg_data,
                                          p_chr_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



  END activate_contract;

 ----------------------------------------------------------------
 --Bug# 3556674 : validate contract api to be called as an api to
 --               run qa check list
 -----------------------------------------------------------------
 Procedure validate_contract(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    x_msg_tbl                      OUT NOCOPY OKL_QA_CHECK_PUB.msg_tbl_type) IS

  l_api_name          CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT';
  l_api_version       CONSTANT NUMBER       := 1;
  l_return_status     VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

  Begin
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

    OKL_CONTRACT_BOOK_PVT.validate_contract(
        p_api_version     => p_api_version,
        p_init_msg_list   => p_init_msg_list,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_chr_id          => p_chr_id,
        p_qcl_id          => p_qcl_id,
        x_msg_tbl         => x_msg_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);
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

  End validate_contract;

 ----------------------------------------------------------------
 --Bug# 3556674 : generate_draft_accounting to be called  as an api to
 --               generate draft 'Booking' accounting entries
 -----------------------------------------------------------------
 Procedure generate_draft_accounting(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER) IS

  l_api_name          CONSTANT VARCHAR2(30) := 'GENERATE_DRAFT_ACCT';
  l_api_version       CONSTANT NUMBER       := 1;
  l_return_status     VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
  Begin

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

    OKL_CONTRACT_BOOK_PVT.generate_draft_accounting(
        p_api_version     => p_api_version,
        p_init_msg_list   => p_init_msg_list,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data,
        p_chr_id          => p_chr_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

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

  End generate_draft_Accounting;
End okl_contract_book_PUB;

/
