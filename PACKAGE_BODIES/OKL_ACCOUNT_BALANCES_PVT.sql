--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNT_BALANCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNT_BALANCES_PVT" AS
/* $Header: OKLRACBB.pls 120.11 2007/02/08 11:38:16 dpsingh noship $ */

l_error_msg_rec     Error_message_Type;

PROCEDURE Get_Account_Balances(p_errbuf OUT NOCOPY VARCHAR2,
                                                         p_retcode OUT NOCOPY NUMBER,
                                                         p_contract_number IN VARCHAR2,
                                                         p_account_from IN VARCHAR2,
                                                         p_account_to IN VARCHAR2,
                                                         p_period_from IN VARCHAR2,
                                                         p_period_to IN VARCHAR2,
                                                         p_format IN VARCHAR2 )
IS

BEGIN
--Stubbed out this procedure for Bug 5707866 (SLA Uptake of Account Balances Report ,replaced by the Trial Balance View feature).

FND_MESSAGE.SET_NAME( application =>g_app_name ,
                                              NAME =>  'OKL_OBS_ACCT_BAL_REP_PRG' );
FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

END Get_Account_Balances;


FUNCTION Submit_Account_Balances(
                                                          p_api_version       IN NUMBER,
                                                          p_init_msg_list     IN VARCHAR2,
                                                          x_return_status    OUT NOCOPY VARCHAR2,
                                                          x_msg_count       OUT NOCOPY NUMBER,
                                                          x_msg_data         OUT NOCOPY VARCHAR2,
                                                          p_contract_number IN VARCHAR2,
                                                          p_account_from IN VARCHAR2,
                                                          p_account_to IN VARCHAR2,
                                                          p_period_from IN VARCHAR2,
                                                          p_period_to IN VARCHAR2,
                                                          p_format IN VARCHAR2 )
RETURN NUMBER IS
    l_api_version          CONSTANT NUMBER := 1;
    l_api_name             CONSTANT VARCHAR2(30) := 'SUBMIT_ACCT_BAL';
    l_return_status        VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_init_msg_list        VARCHAR2(20) DEFAULT Okl_Api.G_FALSE;
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    x_request_id           NUMBER;
BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);
    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_Status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    -- check for p_contract_number before submitting the request.
    IF (p_contract_number IS NULL) OR (p_contract_number = Okl_Api.G_MISS_CHAR) THEN
       Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Contract Number');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- check for p_account_from before submitting the request.
    IF (p_account_from IS NULL) OR (p_account_from = Okl_Api.G_MISS_CHAR) THEN
       Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Account From');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    -- check for p_account_to before submitting the request.
    IF (p_account_to IS NULL) OR (p_account_to = Okl_Api.G_MISS_CHAR) THEN
       Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Account To');
       RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;


   -- Submit Concurrent Program Request for interest calculation
   FND_REQUEST.set_org_id(mo_global.get_current_org_id); --MOAC- Concurrent request
    x_request_id := FND_REQUEST.SUBMIT_REQUEST(
                                                                                   application => 'OKL',
                                                                                   program 	=> 'OKLACCTBAL',
                                                                                   description => 'Account Balances Report',
                                                                                   argument1 => p_contract_number,
                                                                                   argument2 => p_account_from,
                                                                                   argument3 => p_account_to,
                                                                                   argument4 => p_period_from,
                                                                                   argument5 => p_period_to,
                                                                                   argument6 => p_format);

   IF x_request_id = 0 THEN
    -- Raise Error if the request has not been submitted successfully.

       Okc_Api.set_message(p_app_name => 'OKL',
                           p_msg_name => 'OKL_CONC_REQ_ERROR',
                           p_token1   => 'PROG_NAME',
                           p_token1_value => 'Account Balances Report',
                           p_token2   => 'REQUEST_ID',
                           p_token2_value => x_request_id);
      RAISE okl_api.g_exception_error;
    ELSE
  -- Return the request Id if has been submitted successfully.
      x_return_status := l_return_status;
      okl_api.end_activity(x_msg_count, x_msg_data);
    END IF;
    RETURN x_request_id;

  EXCEPTION

    WHEN okl_api.g_exception_error THEN
      x_return_status := Okl_Api.handle_exceptions(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
    RETURN x_request_id;
    WHEN okl_api.g_exception_unexpected_error THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                                                    ,g_pkg_name
                                                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                                                    ,x_msg_count
                                                                                    ,x_msg_data
                                                                                     ,'_PVT');
    RETURN x_request_id;
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    RETURN x_request_id;
  END Submit_Account_Balances;

END OKL_ACCOUNT_BALANCES_PVT;

/
