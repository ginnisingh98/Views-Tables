--------------------------------------------------------
--  DDL for Package Body OKL_LA_JE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LA_JE_PUB" as
/* $Header: OKLPJNLB.pls 115.5 2004/04/13 10:50:54 rnaik noship $ */

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


  Procedure generate_journal_entries(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_commit           IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_draft_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_TRUE,
                      p_memo_yn         IN  VARCHAR2 DEFAULT Okl_Api.G_TRUE,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2)  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'GENERATE_JOURNAL_ENTRIES';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_commit VARCHAR(1) := p_commit;
    l_contract_id NUMBER := p_contract_id;
    l_transaction_type VARCHAR2(256) := p_transaction_type;
    l_draft_yn VARCHAR2(1) := p_draft_yn;
    l_memo_yn VARCHAR2(1) := p_memo_yn;

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



    OKL_LA_JE_PVT.generate_journal_entries(
                      p_api_version,
                      p_init_msg_list,
                      p_commit,
                      p_contract_id,
                      p_transaction_type,
                      p_draft_yn,
                      p_memo_yn,
                      x_return_status,
                      x_msg_count,
                      x_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;




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


  END generate_journal_entries;

End OKL_LA_JE_PUB;

/
