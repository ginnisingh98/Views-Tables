--------------------------------------------------------
--  DDL for Package Body OKL_SUBSIDY_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUBSIDY_PROCESS_PVT" as
/* $Header: OKLRSBPB.pls 120.27.12010000.7 2010/01/25 10:19:55 bkatraga ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;

--global message constants
G_MISSING_SUB_CALC_BASIS     CONSTANT VARCHAR2(200) := 'OKL_MISSING_SUB_CALC_BASIS';
G_SUBSIDY_NAME_TOKEN         CONSTANT VARCHAR2(200) := 'SUBSIDY_NAME';

G_MISSING_SUB_CALC_PARAMETER CONSTANT VARCHAR2(200) := 'OKL_MISSING_SUB_CALC_PARAM';
G_PARAMETER_NAME_TOKEN       CONSTANT VARCHAR2(200) := 'PARAMETER_NAME';
G_CALC_BASIS_TOKEN           CONSTANT VARCHAR2(200) := 'SUB_CALC_BASIS';

G_CONV_RATE_NOT_FOUND        CONSTANT VARCHAR2(200)  := 'OKL_LLA_CONV_RATE_NOT_FOUND';
G_FROM_CURRENCY_TOKEN        CONSTANT VARCHAR2(200)  := 'FROM_CURRENCY';
G_TO_CURRENCY_TOKEN          CONSTANT VARCHAR2(200)  := 'TO_CURRENCY';
G_CONV_TYPE_TOKEN            CONSTANT VARCHAR2(200)  := 'CONVERSION_TYPE';
G_CONV_DATE_TOKEN            CONSTANT VARCHAR2(200)  := 'CONVERSION_DATE';

G_AMOUNT_ROUNDING            CONSTANT VARCHAR2(200)  := 'OKL_ERROR_ROUNDING_AMT';

G_API_MISSING_PARAMETER      CONSTANT VARCHAR2(200)  := 'OKL_API_ALL_MISSING_PARAM';
G_API_NAME_TOKEN             CONSTANT VARCHAR2(50)   := 'API_NAME';
G_MISSING_PARAM_TOKEN        CONSTANT VARCHAR2(50)   := 'MISSING_PARAM';

G_SUBSIDY_NO_RENTS           CONSTANT VARCHAR2(200)  := 'OKL_SUBSIDY_NO_RENTS';
G_ASSET_NUMBER_TOKEN         CONSTANT VARCHAR2(30)   := 'ASSET_NUMBER';


--global constants
G_FORMULA_OEC                CONSTANT VARCHAR2(200)  := 'LINE_OEC';
G_RATE_TYPE                  CONSTANT VARCHAR2(30)  := 'PRE_TAX_IRR';

--global constants for billing trx creation
G_INCOMPLETE_VEND_BILL    CONSTANT VARCHAR2(200) := 'OKL_SUB_INCOMPLETE_VEND_BILL';
G_ERROR_TYPE_TOKEN        CONSTANT VARCHAR2(200) := 'ERROR_TYPE';
G_PARAMETER_TOKEN         CONSTANT VARCHAR2(200) := 'PARAMETER';

G_VERIFY_VENDOR_BILL      CONSTANT VARCHAR2(200) := 'OKL_SUB_VERIFY_VENDOR_BILL';
G_VENDOR_NAME_TOKEN       CONSTANT VARCHAR2(200) := 'VENDOR_NAME';

G_AR_INV_TRX_TYPE	       CONSTANT VARCHAR2(30)    := 'BILLING';
G_CANCEL_STATUS	               CONSTANT VARCHAR2(30)    := 'CANCELED';
G_SUBMIT_STATUS	               CONSTANT VARCHAR2(30)    := 'SUBMITTED';
G_PROCESSED_STATUS             CONSTANT VARCHAR2(30)    := 'PROCESSED';
G_AR_INV_LINE_CODE	       CONSTANT VARCHAR2(30)    := 'LINE';
G_AR_LINES_SOURCE	       CONSTANT VARCHAR2(30)    := 'OKL_TXL_AR_INV_LNS_B';
G_AR_CM_TRX_TYPE	       CONSTANT VARCHAR2(30)	:= 'CREDIT MEMO';
--global constants for billing trx creation
--Bug# 4899328
G_FORMULA_CAP                  CONSTANT VARCHAR2(200)  := 'LINE_CAP_AMNT';

-- sjalasut, added Booking source as part of R12 Billing Enhancement. BEGIN
G_SOURCE_BILLING_TRX_BOOK    CONSTANT fnd_lookups.lookup_code%TYPE :='BOOKING';
-- sjalasut, added Booking source as part of R12 Billing Enhancement. END

-- varangan - Billing Enhancement - Bug#5874824 - New constant added -Begin
G_SOURCE_BILLING_TRX_RBK    CONSTANT fnd_lookups.lookup_code%TYPE :='REBOOK';
-- varangan - Billing Enhancement - Bug#5874824 - New constant added -End

-------------------------------------------------------------------------------
--****Local procedures for parameter validations
-------------------------------------------------------------------------------
----------------------------------------------------
--validate chr_id : check that it is an okl contract
----------------------------------------------------
Procedure validate_chr_id(p_chr_id         in number,
                         x_return_status  out nocopy varchar2) is

--cursor to find that chr id is valid okl contract header id
cursor l_chr_csr (p_chr_id in number) is
select 'Y'
from   okc_k_headers_b  chrb,
       okc_subclasses_b scsb
where  chrb.id       = p_chr_id
and    scsb.code     = chrb.scs_code
and    scsb.cls_code = 'OKL';

l_valid_value varchar2(1) default 'N';
begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_valid_value := 'N';

    open l_chr_csr(p_chr_id => p_chr_id);
    fetch l_chr_csr into l_valid_value;
    if l_chr_csr%NOTFOUND then
        null;
    end if;
    close l_chr_csr;

    If l_valid_value = 'N' then
        x_return_status := OKL_API.G_RET_STS_ERROR;
   End If;

   Exception
   When Others then
   If l_chr_csr%ISOPEN then
       CLOSE l_chr_csr;
   End If;
   OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => SQLCODE
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => SQLERRM);
   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
end validate_chr_id;
--------------------------------------------------------------
--validate line id : check that it is a valid okl line
-------------------------------------------------------------
Procedure validate_cle_id(p_cle_id         in number,
                         p_lty_code       in varchar2 default NULL,
                         x_return_status  out nocopy varchar2) is


--cursor to find that chr id is valid okl contract header id
cursor l_cle_csr (p_cle_id   in number,
                  p_lty_code in varchar2) is
select 'Y'
from   okc_k_lines_b     cleb,
       okc_line_styles_b lseb,
       okc_k_headers_b   chrb,
       okc_subclasses_b  scsb
where  chrb.id       = cleb.dnz_chr_id
and    scsb.code     = chrb.scs_code
and    scsb.cls_code = 'OKL'
and    lseb.lty_code = nvl(p_lty_code,lseb.lty_code)
and    lseb.id       = cleb.lse_id
and    cleb.id       = p_cle_id;

l_valid_value varchar2(1) default 'N';
begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_valid_value := 'N';

    open l_cle_csr(p_cle_id   => p_cle_id,
                   p_lty_code => p_lty_code);
    fetch l_cle_csr into l_valid_value;
    if l_cle_csr%NOTFOUND then
        null;
    end if;
    close l_cle_csr;

    If l_valid_value = 'N' then
        x_return_status := OKL_API.G_RET_STS_ERROR;
   End If;

   Exception
   When Others then
   If l_cle_csr%ISOPEN then
       CLOSE l_cle_csr;
   End If;
   OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => SQLCODE
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => SQLERRM);
   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
end validate_cle_id;
-----------------------------------------
--validate accounting method
-----------------------------------------
procedure validate_acct_method(p_accounting_method in varchar2,
                               x_return_status      out nocopy varchar2) is

--cursor to find whether accounting method is valid
cursor l_flkup_csr (p_lookup_code in varchar2) is
select 'Y'
from   fnd_lookups
where  lookup_code = p_lookup_code
and    lookup_type = 'OKL_SUBACCT_METHOD';

l_valid_value varchar2(1) default 'N';

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_valid_value := 'N';

    open l_flkup_csr(p_lookup_code   => p_accounting_method);
    fetch l_flkup_csr into l_valid_value;
    if l_flkup_csr%NOTFOUND then
        null;
    end if;
    close l_flkup_csr;

    If l_valid_value = 'N' then
        x_return_status := OKL_API.G_RET_STS_ERROR;
   End If;

   Exception
   When Others then
   If l_flkup_csr%ISOPEN then
       CLOSE l_flkup_csr;
   End If;
   OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => SQLCODE
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => SQLERRM);
   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
end validate_acct_method;
------------------------------------
--procedure to validate vendor id
-----------------------------------
procedure validate_vendor_id(p_vendor_id in number,
                             x_return_status      out nocopy varchar2) is

--cursor to find whether vendor id is valid
cursor l_vendor_csr (p_vendor_id in number) is
select 'Y'
from   po_vendors
where  vendor_id = p_vendor_id;

l_valid_value varchar2(1) default 'N';

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_valid_value := 'N';

    open l_vendor_csr(p_vendor_id   => p_vendor_id);
    fetch l_vendor_csr into l_valid_value;
    if l_vendor_csr%NOTFOUND then
        null;
    end if;
    close l_vendor_csr;

    If l_valid_value = 'N' then
        x_return_status := OKL_API.G_RET_STS_ERROR;
   End If;

   Exception
   When Others then
   If l_vendor_csr%ISOPEN then
       CLOSE l_vendor_csr;
   End If;
   OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => SQLCODE
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => SQLERRM);
   x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
end validate_vendor_id;

------------------------------------------------------------------------------
--*****End of local procedures for parameter validations
------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Name         : Is_Contract_Subsidized
--Description  : UTIL API returns true if contract is subsidized
--
-- PARAMETERS  : IN - p_chr_id     : contract header id
--               OUT -x_subsidized : OKL_API.G_TRUE or OKL_API.G_FALSE
--------------------------------------------------------------------------------
Procedure is_contract_subsidized(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    x_subsidized                   OUT NOCOPY VARCHAR2) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'IS_CONTRACT_SUBSIDIZED';
    l_api_version          CONSTANT     NUMBER := 1.0;

--cursor to find out whether subsidies exist on the
--contract
cursor l_subexist_csr(p_chr_id in number) is
select 'Y'
from   dual
where  exists (select '1'
               from   okc_k_lines_b cleb,
                      okc_line_styles_b lseb
               where  cleb.dnz_chr_id = p_chr_id
               and    cleb.sts_code <> 'ABANDONED'
               and    lseb.id       = cleb.lse_id
               and    lseb.lty_code = 'SUBSIDY'
              );

l_subsidy_exists varchar2(1) default 'N';
begin
----
    --------------------------------------
    --start of input variable validations
    --------------------------------------
    --validate p_chr_id
    If (p_chr_id is NULL) or (p_chr_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_chr_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_chr_id is not NULL) and (p_chr_id <> OKL_API.G_MISS_NUM) then
        validate_chr_id(p_chr_id        => p_chr_id,
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_chr_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    ------------------------------------------
    --end of input variable validations
    -----------------------------------------

    l_subsidy_exists := 'N';
    open l_subexist_csr(p_chr_id => p_chr_id);
    fetch l_subexist_csr into l_subsidy_exists;
    If l_subexist_csr%NOTFOUND then
        NULL;
    End If;
    Close l_subexist_csr;
    If l_subsidy_exists = 'Y' then
        x_subsidized := OKL_API.G_TRUE;
    elsif l_subsidy_exists = 'N' then
        x_subsidized := OKL_API.G_FALSE;
    end if;
    Exception
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If l_subexist_csr%ISOPEN then
         CLOSE l_subexist_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If l_subexist_csr%ISOPEN then
         CLOSE l_subexist_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    When others then
    If l_subexist_csr%ISOPEN then
        CLOSE l_subexist_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End is_contract_subsidized;
--------------------------------------------------------------------------------
--Name         : Is_Asset_Subsidized
--Description  : UTIL API returns true if asset is subsidized
--
-- PARAMETERS  : IN - p_asset_cle_id     : financial asset line id
--               OUT -x_subsidized       : OKL_API.G_TRUE or OKL_API.G_FALSE
--------------------------------------------------------------------------------
Procedure is_asset_subsidized(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asset_cle_id                 IN  NUMBER,
    x_subsidized                   OUT NOCOPY VARCHAR2) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'IS_ASSET_SUBSIDIZED';
    l_api_version          CONSTANT     NUMBER := 1.0;

--cursor to find out whether subsidies exist on the
--contract
cursor l_subexist_csr(p_asset_cle_id in number) is
select 'Y'
from   dual
where  exists (select '1'
               from   okc_k_lines_b cleb,
                      okc_line_styles_b lseb
               where  cleb.cle_id    = p_asset_cle_id
               and    cleb.sts_code <> 'ABANDONED'
               and    lseb.id       = cleb.lse_id
               and    lseb.lty_code = 'SUBSIDY'
              );

l_subsidy_exists varchar2(1) default 'N';
begin
----
    ----------------------------------------
    --start of input parameter validations
    ---------------------------------------
    --1.validate p_asset_cle_id
    If (p_asset_cle_id is NULL) or (p_asset_cle_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_asset_cle_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_asset_cle_id is not NULL) and (p_asset_cle_id <> OKL_API.G_MISS_NUM) then
        validate_cle_id(p_cle_id        => p_asset_cle_id,
                        p_lty_code      => 'FREE_FORM1',
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_asset_cle_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    -----------------------------------
    --end of input variable validations
    -----------------------------------

    l_subsidy_exists := 'N';
    open l_subexist_csr(p_asset_cle_id => p_asset_cle_id);
    fetch l_subexist_csr into l_subsidy_exists;
    If l_subexist_csr%NOTFOUND then
        NULL;
    End If;
    Close l_subexist_csr;
    If l_subsidy_exists = 'Y' then
        x_subsidized := OKL_API.G_TRUE;
    elsif l_subsidy_exists = 'N' then
        x_subsidized := OKL_API.G_FALSE;
    end if;
    Exception
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If l_subexist_csr%ISOPEN then
         CLOSE l_subexist_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If l_subexist_csr%ISOPEN then
         CLOSE l_subexist_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    When others then
    If l_subexist_csr%ISOPEN then
        CLOSE l_subexist_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End is_asset_subsidized;
---------------------------------------------------------------------------------
--Bug# 3330669 : Bug Fix for Rate Points calculation
--------------------------------------------------------------------------------
Procedure print( p_proc_name     IN VARCHAR2,
                   p_message       IN VARCHAR2,
		   x_return_status IN VARCHAR2) IS

  Begin

       NULL;
       --dbms_output.put_line( p_proc_name||':'||p_message||':'||x_return_status );

  End;

  Procedure print( p_proc_name     IN VARCHAR2,
                   p_message       IN VARCHAR2) IS
  Begin

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,p_proc_name || p_message || 'S' );

     END IF;
  End;
  --------------------------------------------------------------------------
  -- FUNCTION get_first_sel_date
  ---------------------------------------------------------------------------
  FUNCTION get_first_sel_date( p_start_date          IN    DATE,
                               p_advance_or_arrears  IN    VARCHAR2,
                               p_months_increment    IN    NUMBER,
                               x_return_status       OUT NOCOPY VARCHAR2) RETURN DATE IS
    l_date  DATE;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_first_sel_date';

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'begin' );
    END IF;
    IF p_advance_or_arrears = 'ADVANCE' THEN
      l_date  :=  TRUNC(p_start_date);
    ELSIF p_advance_or_arrears = 'ARREARS' THEN
      l_date  :=  ADD_MONTHS(TRUNC(p_start_date), p_months_increment) - 1;
    END IF;

    IF l_date IS NOT NULL THEN
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      RETURN l_date;
    ELSE
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'end' );
    END IF;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

     OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => SQLCODE
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END get_first_sel_date;
   ---------------------------------------------------------------------------
  -- FUNCTION get_months_factor
  ---------------------------------------------------------------------------
  FUNCTION get_months_factor( p_frequency     IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2) RETURN NUMBER IS

    l_months  NUMBER;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_months_factor';


  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'begin' );
    END IF;
    IF p_frequency = 'M' THEN
      l_months := 1;
    ELSIF p_frequency = 'Q' THEN
      l_months := 3;
    ELSIF p_frequency = 'S' THEN
      l_months := 6;
    ELSIF p_frequency = 'A' THEN
      l_months := 12;
    END IF;

    IF l_months IS NOT NULL THEN
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      RETURN l_months;

    ELSE

      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_INVALID_FREQUENCY_CODE',
                          p_token1       => 'FRQ_CODE',
                          p_token1_value => p_frequency);

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'end' );
    END IF;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

     OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => SQLCODE
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END get_months_factor;
 ---------------------------------------------------------------------------
  -- PROCEDURE get_stream_elements
  --
  -- Description
  -- Populates Stream Elements array for contiguous periodic charges/expenses
  --
  ---------------------------------------------------------------------------
  PROCEDURE get_stream_elements( p_start_date          IN      DATE,
                                 p_periods             IN      NUMBER,
                                 p_frequency           IN      VARCHAR2,
                                 p_structure           IN      VARCHAR2,
                                 p_advance_or_arrears  IN      VARCHAR2,
                                 p_amount              IN      NUMBER,
                                 p_stub_days           IN      NUMBER,
                                 p_stub_amount         IN      NUMBER,
                                 p_currency_code       IN      VARCHAR2,
                                 p_khr_id              IN      NUMBER,
                                 p_kle_id              IN      NUMBER,
                                 p_purpose_code        IN      VARCHAR2,
                                 x_selv_tbl            OUT NOCOPY okl_sel_pvt.selv_tbl_type,
                                 x_pt_tbl              OUT NOCOPY okl_sel_pvt.selv_tbl_type,
                                 x_return_status       OUT NOCOPY VARCHAR2,
                                 x_msg_count           OUT NOCOPY NUMBER,
                                 x_msg_data            OUT NOCOPY VARCHAR2) IS

    lx_return_status             VARCHAR2(1);

    l_months_factor              NUMBER;
    l_first_sel_date             DATE;
    l_element_count              NUMBER;
    l_base_amount                NUMBER;
    l_amount                     NUMBER;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_stream_elements';

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS ;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'begin' );
    END IF;
    l_months_factor := get_months_factor( p_frequency       =>   p_frequency,
                                          x_return_status   =>   x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_first_sel_date := get_first_sel_date( p_start_date          =>   p_start_date,
                                            p_advance_or_arrears  =>   p_advance_or_arrears,
                                            p_months_increment    =>   l_months_factor,
                                            x_return_status       =>   x_return_status);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    If ( p_amount IS NULL ) Then
        l_amount := NULL;
    else
        l_amount := okl_accounting_util.validate_amount(p_amount         => p_amount,
                                                        p_currency_code  => p_currency_code);
    ENd If;

    If ( p_periods IS NULL ) AND ( p_stub_days IS NOT NULL ) Then

        x_selv_tbl(1).amount                     := p_stub_amount;
        x_selv_tbl(1).se_line_number             := 1;                            -- TBD
        x_selv_tbl(1).accrued_yn                 := NULL;                         -- TBD

        IF p_advance_or_arrears = 'ARREARS' THEN
            x_selv_tbl(1).stream_element_date        := p_start_date + p_stub_days - 1;
            x_selv_tbl(1).comments                   := 'Y';
        ELSE
            x_selv_tbl(1).stream_element_date        := p_start_date;
            x_selv_tbl(1).comments                   := 'N';
        END IF;

    Else

        l_element_count := p_periods;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'creating elements: ' || to_char(l_element_count) );
        END IF;
        FOR i IN 1 .. l_element_count LOOP

            x_selv_tbl(i).amount                     := l_amount;
            x_selv_tbl(i).stream_element_date        := ADD_MONTHS(l_first_sel_date, (i - 1) * l_months_factor);
            x_selv_tbl(i).se_line_number             := i;                            -- TBD
            x_selv_tbl(i).accrued_yn                 := NULL;                         -- TBD

            IF p_advance_or_arrears = 'ARREARS' THEN
              x_selv_tbl(i).comments                   := 'Y';
            ELSE
              x_selv_tbl(i).comments                   := 'N';
            END IF;

        END LOOP;

     End If;


    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'end' );

    END IF;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

       OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => SQLCODE
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END get_stream_elements;
  ---------------------------------------------------------------------------
  -- PROCEDURE get_stream_header
  ---------------------------------------------------------------------------
  PROCEDURE get_stream_header(p_purpose_code   IN  VARCHAR2,
                              p_khr_id         IN  NUMBER,
                              p_kle_id         IN  NUMBER,
                              p_sty_id         IN  NUMBER,
                              x_stmv_rec       OUT NOCOPY okl_stm_pvt.stmv_rec_type,
                              x_return_status  OUT NOCOPY VARCHAR2) IS

    l_stmv_rec                okl_stm_pvt.stmv_rec_type;
    l_transaction_number      NUMBER;

    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_stream_header';


  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'begin' );
    END IF;
    SELECT okl_sif_seq.nextval INTO l_transaction_number FROM DUAL;

    -- NOTE: UV for Streams inquiry (OKL_ASSET_STREAMS_UV) assumes a denormalized use of KHR_ID
    l_stmv_rec.khr_id  :=  p_khr_id;
    l_stmv_rec.kle_id              :=  p_kle_id;
    l_stmv_rec.sty_id              :=  p_sty_id;
    l_stmv_rec.sgn_code            :=  'MANL';
    l_stmv_rec.say_code            :=  'WORK';
    l_stmv_rec.active_yn           :=  'N';
    l_stmv_rec.transaction_number  :=  l_transaction_number;
    -- l_stmv_rec.date_current        :=  NULL;                                    --  TBD
    l_stmv_rec.date_working        :=  SYSDATE;                                    --  TBD
    -- l_stmv_rec.date_history        :=  NULL;                                    --  TBD
    -- l_stmv_rec.comments            :=  NULL;                                    --  TBD

    IF p_purpose_code = 'REPORT' THEN

      l_stmv_rec.purpose_code := 'REPORT';

    END IF;

    x_stmv_rec                     := l_stmv_rec;
    --x_return_status                := G_RET_STS_SUCCESS;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'end' );
    END IF;
  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => SQLCODE
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => SQLERRM);

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END get_stream_header;

--------------------------------------------------------------------------------
--Modified from okl_stream_generator_pvt.generate_stub_element
--------------------------------------------------------------------------------

  Procedure generate_stub_element(p_khr_id   IN NUMBER,
                                  p_api_version   IN  NUMBER,
                                  p_init_msg_list IN  VARCHAR2,
                                  x_msg_count     OUT NOCOPY NUMBER,
                                  x_msg_data      OUT NOCOPY VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_stmv_rec      OUT NOCOPY OKL_STREAMS_PUB.stmv_rec_type,
                                  x_selv_tbl      OUT NOCOPY OKL_STREAMS_PUB.selv_tbl_type
				                  ) Is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'GENERATE_STUB_ELEMENT';
    l_api_version          CONSTANT     NUMBER := 1.0;


   l_prog_name                CONSTANT VARCHAR2(100) := G_PKG_NAME||'.'||'generate_stub_element';
   l_selv_tbl                 OKL_STREAMS_PUB.selv_tbl_type;
   l_stmv_rec                 OKL_STREAMS_PUB.stmv_rec_type;
   --avsingh :
   lx_selv_tbl                 OKL_STREAMS_PUB.selv_tbl_type;
   lx_stmv_rec                 OKL_STREAMS_PUB.stmv_rec_type;


   l_sty_id NUMBER;

   Cursor c_sty IS
   Select id
   from okl_strm_type_v
   --BUG# 4181025
   --where name = 'RENT';
   where stream_type_purpose = 'RENT';

  Begin

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



     OPEN c_sty;
     FETCH c_sty INTO l_sty_id;
     CLOSE c_sty;

     get_stream_header( p_khr_id         =>   p_khr_id,
                        p_kle_id         =>   NULL,
                        p_sty_id         =>   l_sty_id,
                        p_purpose_code   =>   'STUBS',
                        x_stmv_rec       =>   l_stmv_rec,
                        x_return_status  =>   x_return_status);

      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

     l_stmv_rec.date_history    := sysdate  ;
     l_stmv_rec.say_code        :=  'HIST' ;
     l_stmv_rec.SGN_CODE        :=  'MANL';
     l_stmv_rec.active_yn       :=  'N';
     l_stmv_rec.purpose_code    :=  'STUBS';
     l_stmv_rec.comments        :=  'STUB STREAMS';

     l_selv_tbl(1).stream_element_date := sysdate;
     l_selv_tbl(1).amount              := 0.0;
     l_selv_tbl(1).se_line_number      := 1 ;
     l_selv_tbl(1).comments            := 'STUB STREAM ELEMENT' ;
     l_selv_tbl(1).parent_index        := 1 ;


     okl_streams_pvt.create_streams(
                     p_api_version     => p_api_version
					,p_init_msg_list   => p_init_msg_list
					,x_return_status   => x_return_status
					,x_msg_count       => x_msg_count
					,x_msg_data        => x_msg_data
					,p_stmv_rec        => l_stmv_rec
					,p_selv_tbl        => l_selv_tbl
					,x_stmv_rec        => lx_stmv_rec
					,x_selv_tbl        => lx_selv_tbl
                                    );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


     --x_se_id := lx_selv_tbl(1).id;
     x_stmv_rec := lx_stmv_rec;
     x_selv_tbl := lx_selv_tbl;
     OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

      EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
      WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  end generate_stub_element;

--------------------------------------------------------------------------------
--Modified from okl_stream_generator_pvt.generate cash flows
--------------------------------------------------------------------------------
  PROCEDURE generate_cash_flows(
                             p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2,
                             p_khr_id        IN  NUMBER,
		             p_kle_id        IN  NUMBER,
		             p_sty_id        IN  NUMBER,
		             p_payment_tbl   IN  okl_stream_generator_pvt.payment_tbl_type,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             x_stmv_rec_rent OUT NOCOPY okl_streams_pub.stmv_rec_type,
                             x_selv_tbl_rent OUT NOCOPY okl_streams_pub.selv_tbl_type,
                             x_stmv_rec_stub OUT NOCOPY okl_streams_pub.stmv_rec_type,
                             x_selv_tbl_stub OUT NOCOPY okl_streams_pub.selv_tbl_type,
                             x_payment_count OUT NOCOPY BINARY_INTEGER) IS

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'GENERATE_CASH_FLOWS';
    l_api_version          CONSTANT     NUMBER := 1.0;


      CURSOR c_hdr IS
      SELECT chr.template_yn,
             chr.currency_code,
             chr.start_date,
             khr.deal_type,
             khr.term_duration,
             NVL(khr.generate_accrual_yn, 'Y')
      FROM   okc_k_headers_b chr,
             okl_k_headers khr
      WHERE  khr.id = p_khr_id
        AND  chr.id = khr.id;

    l_hdr                    c_hdr%ROWTYPE;
    l_deal_type              VARCHAR2(30);
    l_purpose_code           VARCHAR2(30) := 'FLOW';

    l_pt_yn                  VARCHAR2(1);
    l_passthrough_id         NUMBER;

    l_sty_id                 NUMBER;
    l_sty_name               VARCHAR2(150);
    l_mapped_sty_name        VARCHAR2(150);

    l_pre_tax_inc_id         NUMBER;
    l_principal_id           NUMBER;
    l_interest_id            NUMBER;
    l_prin_bal_id            NUMBER;
    l_termination_id         NUMBER;

    l_selv_tbl               okl_streams_pub.selv_tbl_type;
    l_pt_tbl                 okl_streams_pub.selv_tbl_type;
    lx_selv_tbl              okl_streams_pub.selv_tbl_type;

    l_stmv_rec               okl_streams_pub.stmv_rec_type;
    l_pt_rec                 okl_streams_pub.stmv_rec_type;
    lx_stmv_rec              okl_streams_pub.stmv_rec_type;

    i                        BINARY_INTEGER := 0;
    j                        BINARY_INTEGER := 0;
    l_ele_count              BINARY_INTEGER := 0;
    k                        BINARY_INTEGER := 0;

    l_adv_arr                VARCHAR2(30);



    l_prog_name         CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'generate_cash_flows';
    l_se_id NUMBER;

    --avsingh
    l_stmv_rec_stub     okl_streams_pub.stmv_rec_type;
    l_selv_tbl_stub     okl_streams_pub.selv_tbl_type;
    l_stmv_rec_rent     okl_streams_pub.stmv_rec_type;
    l_selv_tbl_rent     okl_streams_pub.selv_tbl_type;



  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      -- Call start_activity to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY (
                                 l_api_name
                                 ,p_init_msg_list
                                 ,'_PVT'
                                 ,x_return_status);
      -- Check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;


    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'begin' );
    END IF;
    OPEN  c_hdr;
    FETCH c_hdr INTO l_hdr;
    CLOSE c_hdr;

    generate_stub_element( p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           p_khr_id        => p_khr_id,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           x_stmv_rec      => l_stmv_rec_stub,
                           x_selv_tbl      => l_selv_tbl_stub);

    IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_se_id   := l_selv_tbl_stub(1).id;

      ---------------------------------------------
      -- STEP 1: Spread cash INFLOW
      ---------------------------------------------

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' generating streams - begin');

      END IF;
      get_stream_header(p_khr_id         =>   p_khr_id,
                        p_kle_id         =>   p_kle_id,
                        p_sty_id         =>   p_sty_id,
                        p_purpose_code   =>   l_purpose_code,
                        x_stmv_rec       =>   l_stmv_rec,
                        x_return_status  =>   x_return_status);

      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_stmv_rec.purpose_code := 'FLOW';

      okl_streams_pub.create_streams(p_api_version     =>   p_api_version,
                                     p_init_msg_list   =>   p_init_msg_list,
                                     x_return_status   =>   x_return_status,
                                     x_msg_count       =>   x_msg_count,
                                     x_msg_data        =>   x_msg_data,
                                     p_stmv_rec        =>   l_stmv_rec,
                                     x_stmv_rec        =>   lx_stmv_rec);

      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_stmv_rec_rent := lx_stmv_rec;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'created header' );
      END IF;
      x_payment_count  :=  0;
      l_ele_count := 0;
      FOR i IN p_payment_tbl.FIRST..p_payment_tbl.LAST
      LOOP

        IF p_payment_tbl(i).start_date IS NULL THEN

          OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_NO_SLL_SDATE');

          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

        END IF;

/*
 * calculate stream elements for each payment level
 * also means that if there are multiple payment levels for an asset, streams are
 * calculated at different points.
 * the streams amounts are they are entered in payments. In case of passthru, a
 * new set of streams are created with amounts that are passthru'ed - l_pt_tbl.
 */
        If ( p_payment_tbl(i).arrears_yn = 'Y' ) Then
            l_adv_arr := 'ARREARS';
	    Else
            l_adv_arr := 'ADVANCE';
	    End If;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'start date ' || p_payment_tbl(i).start_date );
        END IF;
        get_stream_elements( p_start_date          =>   p_payment_tbl(i).start_date,
                             p_periods             =>   p_payment_tbl(i).periods,
                             p_frequency           =>   p_payment_tbl(i).frequency,
                             p_structure           =>   p_payment_tbl(i).structure,
                             p_advance_or_arrears  =>   l_adv_arr,
                             p_amount              =>   p_payment_tbl(i).amount,
			                 p_stub_days           =>   p_payment_tbl(i).stub_days,
			                 p_stub_amount         =>   p_payment_tbl(i).stub_amount,
                             p_currency_code       =>   l_hdr.currency_code,
                             p_khr_id              =>   p_khr_id,
                             p_kle_id              =>   p_kle_id,
                             p_purpose_code        =>   l_purpose_code,
                             x_selv_tbl            =>   l_selv_tbl,
                             x_pt_tbl              =>   l_pt_tbl,
                             x_return_status       =>   x_return_status,
                             x_msg_count           =>   x_msg_count,
                             x_msg_data            =>   x_msg_data);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'created elements ' || to_char(l_selv_tbl.COUNT) );
        END IF;
        FOR j in 1..l_selv_tbl.COUNT
	    LOOP
	        l_ele_count                  := l_ele_count + 1;
	        l_selv_tbl(j).stm_id         := lx_stmv_rec.id;
	        l_selv_tbl(j).se_line_number := l_ele_count;
	        l_selv_tbl(j).id             := NULL;
	    END LOOP;

        If ( p_payment_tbl(i).stub_days IS NOT NULL ) AND ( p_payment_tbl(i).periods IS NULL ) Then

  	        FOr i in 1..l_selv_tbl.COUNT
	        LOOP
	            l_selv_tbl(i).sel_id := l_se_id;
	        END LOOP;

	        FOr i in 1..l_pt_tbl.COUNT
	        LOOP
	            l_pt_tbl(i).sel_id := l_se_id;
	        END LOOP;

   	    End If;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'start date ' || l_selv_tbl(1).stream_element_date );
        END IF;
        okl_streams_pub.create_stream_elements(
	                                   p_api_version     =>   p_api_version,
                                       p_init_msg_list   =>   p_init_msg_list,
                                       x_return_status   =>   x_return_status,
                                       x_msg_count       =>   x_msg_count,
                                       x_msg_data        =>   x_msg_data,
                                       p_selv_tbl        =>   l_selv_tbl,
                                       x_selv_tbl        =>   lx_selv_tbl);

        IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || 'created elements ' || to_char(l_ele_count) );
        END IF;
        If l_selv_tbl_rent.COUNT = 0 then
             l_selv_tbl_rent := lx_selv_tbl;
        Else
             k := l_selv_tbl_rent.LAST;
             For j in lx_selv_tbl.FIRST..lx_selv_tbl.LAST
             Loop
                 k := k + 1;
                 l_selv_tbl_rent(k) := lx_selv_tbl(j);
             End Loop;
        End If;
        l_selv_tbl.DELETE;
        -- Clear out reusable data structures


        l_pt_rec := NULL;
        l_selv_tbl.delete;
        l_pt_tbl.delete;

        lx_selv_tbl.delete;

         x_payment_count  :=  x_payment_count + 1;
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' payment count ' || to_char(x_payment_count) );

         END IF;
      END LOOP;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_prog_name || ' done ' );

      END IF;
      l_sty_name  :=  NULL;
      l_sty_id    :=  NULL;
      l_stmv_rec  := NULL;
      lx_stmv_rec := NULL;

      x_stmv_rec_stub := l_stmv_rec_stub;
      x_selv_tbl_stub := l_selv_tbl_stub;
      x_stmv_rec_rent := l_stmv_rec_rent;
      x_selv_tbl_rent := l_selv_tbl_rent;

     OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

      EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
      WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

  END generate_cash_flows;

  -----------------------------------------------------------
  --Local procedure PV calculation - calls ISG API
  -----------------------------------------------------------
  Procedure calculate_pv  (p_api_version       IN NUMBER,
                           p_init_msg_list     IN VARCHAR2,
                           x_return_status     OUT NOCOPY VARCHAR2,
                           x_msg_count         OUT NOCOPY NUMBER,
                           x_msg_data          OUT NOCOPY VARCHAR2,
                           p_chr_id            IN  NUMBER,
                           p_asset_cle_id      IN  NUMBER,
                           p_payment_tbl       IN  OKL_STREAM_GENERATOR_PVT.payment_tbl_type,
                           p_irr               IN  NUMBER,
                           x_npv               OUT NOCOPY NUMBER
                          ) is

   l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
   l_api_name             CONSTANT     varchar2(30) := 'CALCULATE_NPV';
   l_api_version          CONSTANT     NUMBER := 1.0;

   cursor l_cleb_csr (p_cle_id in number) is
   select cleb.start_date,
          cleb.end_date
   from   okc_k_lines_b cleb
   where  cleb.id = p_cle_id;

   l_start_date  okc_k_lines_b.start_date%TYPE;
   l_end_date    okc_k_lines_b.end_date%TYPE;
   i             NUMBER;

   l_stmv_rec_rent     okl_streams_pub.stmv_rec_type;
   l_selv_tbl_rent     okl_streams_pub.selv_tbl_type;
   l_stmv_rec_stub     okl_streams_pub.stmv_rec_type;
   l_selv_tbl_stub     okl_streams_pub.selv_tbl_type;

   l_payment_count     BINARY_INTEGER;
   l_sty_id            NUMBER;
   l_npv               NUMBER;
   l_kle_yld         NUMBER;
   l_days              NUMBER;

   --cursor to ger stream type id
   cursor l_styb_csr(p_strm_type in varchar2) is
   select styb.id
   from   okl_strm_type_b styb
   --Bug# 4181025
   --where  code = p_strm_type;
   where  stream_type_purpose = p_strm_type;
   l_pv number;
   l_cash_flow_tbl okl_stream_generator_pvt.cash_flow_tbl;
  Begin
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      -- Call start_activity to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
      -- Check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      open l_styb_csr(p_strm_type => 'RENT');
      fetch l_styb_csr into l_sty_id;
      if l_styb_csr%NOTFOUND then
          null;
      end if;
      close l_styb_csr;

      generate_cash_flows(p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          p_khr_id        => p_chr_id,
                          p_kle_id        => p_asset_cle_id,
		          p_sty_id        => l_sty_id,
		          p_payment_tbl   => p_payment_tbl,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          x_stmv_rec_rent => l_stmv_rec_rent,
                          x_selv_tbl_rent => l_selv_tbl_rent,
                          x_stmv_rec_stub => l_stmv_rec_stub,
                          x_selv_tbl_stub => l_selv_tbl_stub,
                          x_payment_count => l_payment_count);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;


      l_npv := 0.0;

      open l_cleb_csr(p_cle_id => p_asset_cle_id);
      Fetch l_cleb_csr into l_start_date,
                            l_end_date;
      IF l_cleb_csr%NOTFOUND then
         NULL;
      END IF;
      close l_cleb_csr;

      FOR i in l_selv_tbl_rent.FIRST..l_selv_tbl_rent.LAST
      LOOP

          l_pv := 0;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' frequency ' || p_payment_tbl(1).frequency );
          END IF;
          OKL_STREAM_GENERATOR_PVT.get_present_value(p_api_version    => p_api_version,
                                                     p_init_msg_list  => p_init_msg_list,
	                                             p_amount_date    => l_selv_tbl_rent(i).stream_element_date,
	                                             p_amount         => l_selv_tbl_rent(i).amount,
                                                     p_frequency      => p_payment_tbl(1).frequency,
         	                                     p_rate           => p_irr,
                                                     p_pv_date        => l_start_date,
		                                     x_pv_amount      => l_pv,
                                                     x_return_status  => x_return_status,
                                                     x_msg_count      => x_msg_count,
                                                     x_msg_data       => x_msg_data);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          l_npv := l_npv + l_pv;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, l_api_name || ' amount ' || to_char(l_npv) );

          END IF;
      END LOOP;
      x_npv := l_npv;

      --delete streams created for this temporary calculation
      okl_streams_pub.delete_streams(
       p_api_version      => p_api_version,
       p_init_msg_list    => p_init_msg_list,
       x_return_status    => x_return_status,
       x_msg_count        => x_msg_count,
       x_msg_data         => x_msg_data,
       p_stmv_rec         => l_stmv_rec_stub);

      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;


      okl_streams_pub.delete_streams(
       p_api_version      => p_api_version,
       p_init_msg_list    => p_init_msg_list,
       x_return_status    => x_return_status,
       x_msg_count        => x_msg_count,
       x_msg_data         => x_msg_data,
       p_stmv_rec         => l_stmv_rec_rent);

      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

      EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN
      If l_cleb_csr%ISOPEN then
          close l_cleb_csr;
      End If;
      If l_styb_csr%ISOPEN then
          close l_styb_csr;
      End If;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      If l_cleb_csr%ISOPEN then
          close l_cleb_csr;
      End If;
      If l_styb_csr%ISOPEN then
          close l_styb_csr;
      End If;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
      WHEN OTHERS THEN
      If l_cleb_csr%ISOPEN then
          close l_cleb_csr;
      End If;
      If l_styb_csr%ISOPEN then
          close l_styb_csr;
      End If;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  End calculate_pv;
--End Rate Points Calc
--------------------------------------------------------------------------------
--Name         : get_rate_points_amount
--Description  : API to calculate rate point subsidy amount for a subsidy line
--
-- PARAMETERS  : IN - p_subsidy_cle_id  : subsidy line id
--                    rate_points       : rate points as specified in setup
--               OUT - x_subsidy_amount : calculated subsidy amount
--------------------------------------------------------------------------------
PROCEDURE calc_rate_points_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rate_points                  IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    p_asset_cle_id                 IN  NUMBER,
    x_subsidy_amount               OUT NOCOPY NUMBER) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'GET_RATE_POINTS';
    l_api_version          CONSTANT     NUMBER := 1.0;

-- Added sll_rulb.rule_information2 in order by clause for bug#6007644 - varangan-14-Jun-07
    cursor l_rent_csr (p_asset_cle_id in number) is
    select sll_rulb.rule_information2         start_date,
       sll_rulb.rule_information3             periods,
       sll_rulb.object1_id1                   frequency,
       sll_rulb.rule_information5             structure,
       nvl( sll_rulb.rule_information10,'N')  arrears_yn,
       sll_rulb.rule_information6             amount,
       sll_rulb.rule_information7             stub_days,
       sll_rulb.rule_information8             stub_amount,
       sll_rulb.rule_information13            rate
    from   okc_rules_b        sll_rulb,
       okc_rules_b        slh_rulb,
       okl_strm_type_b    styb,
       okc_rule_groups_b  rgpb
    where  sll_rulb.rgp_id                      = rgpb.id
    and    sll_rulb.rule_information_category   = 'LASLL'
    and    sll_rulb.dnz_chr_id                  = rgpb.dnz_chr_id
    and    sll_rulb.object2_id1                 = to_char(slh_rulb.id)
    and    slh_rulb.rgp_id                      = rgpb.id
    and    slh_rulb.rule_information_category   = 'LASLH'
    and    slh_rulb.dnz_chr_id                  = rgpb.dnz_chr_id
    and    styb.id                              = slh_rulb.object1_id1
    --Bug# 4181025 :
    --and    styb.code                            = 'RENT'
    and    styb.stream_type_purpose             = 'RENT'
    and    rgpb.cle_id                          = p_asset_cle_id
    and    rgpb.rgd_code                        = 'LALEVL'
    order by FND_DATE.canonical_to_date(sll_rulb.rule_information2);

    l_rent_rec          l_rent_csr%RowType;
    l_payment_tbl       OKL_STREAM_GENERATOR_PVT.payment_tbl_type;
    lx_payment_tbl      OKL_STREAM_GENERATOR_PVT.payment_tbl_type;
    l_payment_tbl_miss  OKL_STREAM_GENERATOR_PVT.payment_tbl_type;

    i                   number;
    l_orig_irr          number;
    lx_orig_irr         number;
    l_modified_irr      number;
    l_rate_points       number;

    l_subsidy_amount    number;

    l_npv_new           number;
    l_npv_orig          number;

    --cursor to get asset number for error message
    cursor l_astnum_csr (p_cle_id in number) is
    select clet.name
    from   okc_k_lines_tl clet
    where  id         = p_cle_id
    and    language    = userenv('LANG');

    l_asset_number okc_k_lines_tl.name%TYPE;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    ---------------------------------------
    --start of input parameter validations
    --------------------------------------
    --1.validate p_asset_cle_id
    If (p_asset_cle_id is NULL) or (p_asset_cle_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_asset_cle_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_asset_cle_id is not NULL) and (p_asset_cle_id <> OKL_API.G_MISS_NUM) then
        validate_cle_id(p_cle_id        => p_asset_cle_id,
                        p_lty_code      => 'FREE_FORM1',
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_asset_cle_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    ------------------------------------
    --end of input variable validations
    -----------------------------------

    ---------------------------------------------------------------------
    --Rate points calculation steps
    ---------------------------------------------------------------------
    --1. Get asset payments
    --2. Call ISG API to get IRR from asset payments
    --3. Add rate points to IRR to get modified IRR
    --4. Call PV formula to get PV of payments at original IRR
    --5. Call PV formula to get PV of payments at modified IRR
    --6. subtract new PV from old PV. Difference is subsidy amount;
    ------------------------------------------------------------------

    i := 0;
    l_rate_points := p_rate_points;
    -----------------------------------------------------
     --1. Get asset payments
    -----------------------------------------------------
    open l_rent_csr(p_asset_cle_id => p_asset_cle_id);
    Loop
        fetch l_rent_csr into l_rent_rec;
        Exit when l_rent_csr%NOTFOUND;
        i := i+1;
        l_Payment_tbl(i).start_date      :=  trunc(fnd_date.canonical_to_date(l_rent_rec.start_date));
        l_Payment_tbl(i).periods         :=  l_rent_rec.periods;
        l_Payment_tbl(i).frequency       :=  l_rent_rec.frequency;
        l_payment_tbl(i).structure       :=  l_rent_rec.structure;
        l_payment_tbl(i).arrears_yn      :=  l_rent_rec.arrears_yn;
        l_payment_tbl(i).amount          :=  l_rent_rec.amount;
        l_payment_tbl(i).stub_days       :=  l_rent_rec.stub_days;
        l_payment_tbl(i).stub_amount     :=  l_rent_rec.stub_amount;
        l_payment_tbl(i).rate            :=  l_rent_rec.rate;
    end loop;
    close l_rent_csr;
    If l_payment_tbl.COUNT > 0 then
       -------------------------------------------------------
       --2. Call ISG API to get IRR from asset payments
       -------------------------------------------------------
        OKL_PRICING_PVT.target_parameter
            (p_api_version   =>  p_api_version,
             p_init_msg_list =>  p_init_msg_list,
             p_khr_id        =>  p_chr_id,
             p_kle_id        =>  p_asset_cle_id,
             p_rate_type     =>  G_RATE_TYPE,
             p_target_param  =>  'PMNT',
             p_pay_tbl       =>  l_payment_tbl,
             x_pay_tbl       =>  lx_payment_tbl,
             x_overall_rate  =>  l_orig_irr,
             x_return_status =>  x_return_status,
             x_msg_count     =>  x_msg_count,
             x_msg_data      =>  x_msg_data);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        ------------------------------------------------
        --3. Add rate points to IRR to get modified IRR
        ------------------------------------------------
        l_modified_irr := l_rate_points + l_orig_irr;

         ------------------------------------------------------------
        --5. Call PV formula and get NPV for old and new payments
        -----------------------------------------------------------
        --pv for old irr
        calculate_pv(p_api_version       => p_api_version,
                      p_init_msg_list     => p_init_msg_list,
                      x_return_status     => x_return_status,
                      x_msg_count         => x_msg_count,
                      x_msg_data          => x_msg_data,
                      p_chr_id            => p_chr_id,
                      p_asset_cle_id      => p_asset_cle_id,
                      p_payment_tbl       => l_payment_tbl,
                      p_irr               => l_orig_irr,
                      x_npv               => l_npv_orig);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --pv for new irr
        calculate_pv (p_api_version       => p_api_version,
                      p_init_msg_list     => p_init_msg_list,
                      x_return_status     => x_return_status,
                      x_msg_count         => x_msg_count,
                      x_msg_data          => x_msg_data,
                      p_chr_id            => p_chr_id,
                      p_asset_cle_id      => p_asset_cle_id,
                      p_payment_tbl       => l_payment_tbl,
                      p_irr               => l_modified_irr,
                      x_npv               => l_npv_new);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;


        l_subsidy_amount := l_npv_orig - l_npv_new;

    Else
        --get asset number
        open l_astnum_csr(p_cle_id => p_asset_cle_id);
        fetch l_astnum_csr into l_asset_number;
        if l_astnum_csr%NOTFOUND then
            null;
        end if;
        close l_astnum_csr;
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_SUBSIDY_NO_RENTS,
                            p_token1       => G_ASSET_NUMBER_TOKEN,
                            p_token1_value => l_asset_number);
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE OKL_API.G_EXCEPTION_ERROR;
    End If;

    x_subsidy_amount := l_subsidy_amount;
    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

    EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If l_astnum_csr%ISOPEN then
        close l_astnum_csr;
    End If;
    If l_rent_csr%ISOPEN then
        close l_rent_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If l_astnum_csr%ISOPEN then
        close l_astnum_csr;
    End If;
    If l_rent_csr%ISOPEN then
        close l_rent_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_astnum_csr%ISOPEN then
        close l_astnum_csr;
    End If;
    If l_rent_csr%ISOPEN then
        close l_rent_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End calc_rate_points_amount;
--------------------------------------------------------------------------------
--End : Changes for Bug# 3330669
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Name         : Convert_Currency
--Description  : Local procedure to do currency conversion
--PARAMETERS   : IN p_from_currency in varchar2
--                  p_khr_id in contract header id
--                  p_transaction_date in transaction_date
--                  p_amount in number
--                  p_round_yn in varchar2 default OKL_API_G_TRUE
--               OUT x_return_status
--                   x_converted amount
--------------------------------------------------------------------------------
Procedure Convert_currency(p_khr_id            IN NUMBER,
                           p_from_currency     IN VARCHAR2,
                           p_transaction_date  IN DATE,
                           p_amount            IN NUMBER,
                           p_round_yn          IN VARCHAR2 DEFAULT OKL_API.G_TRUE,
                           x_converted_amount  OUT NOCOPY NUMBER,
                           x_return_status     OUT NOCOPY VARCHAR2) is

    l_contract_currency           okc_k_headers_b.currency_code%TYPE;
    l_currency_conversion_type    okl_k_headers.currency_conversion_type%TYPE;
    l_currency_conversion_rate    okl_k_headers.currency_conversion_rate%TYPE;
    l_currency_conversion_date    okl_k_headers.currency_conversion_date%TYPE;
    l_converted_subsidy_amount    Number;
    l_rounded_subsidy_amount      Number;

    error_condition               Exception;
Begin
    ----------------------------------------------------------------------------
    --1. Call accounting util to do currency conversion
    ----------------------------------------------------------------------------
    okl_accounting_util.convert_to_contract_currency
    (p_khr_id                   => p_khr_id,
     p_from_currency            => p_from_currency,
     p_transaction_date         => p_transaction_date,
     p_amount 			        => p_amount,
     x_contract_currency        => l_contract_currency,
     x_currency_conversion_type => l_currency_conversion_type,
     x_currency_conversion_rate => l_currency_conversion_rate,
     x_currency_conversion_date => l_currency_conversion_date,
     x_converted_amount 		=> l_converted_subsidy_amount
     );
     --check for error in rate
     If (p_amount > 0) and (l_converted_subsidy_amount < 0 ) Then
         OKC_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_CONV_RATE_NOT_FOUND,
                              p_token1       => G_FROM_CURRENCY_TOKEN,
                              p_token1_value => p_from_currency,
                              p_token2       => G_TO_CURRENCY_TOKEN,
                              p_token2_value => l_contract_currency,
                              p_token3       => G_CONV_TYPE_TOKEN,
                              p_token3_value => l_currency_conversion_type,
                              p_token4       => G_CONV_DATE_TOKEN,
                              p_token4_value => to_char(l_currency_conversion_date,'DD-MON-YYYY'));
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise error_condition;
     End If;
     ---------------------------------------------------------------------------
     --2. Call accounting util to do cross currency rounding
     ---------------------------------------------------------------------------
     If p_round_yn = OKL_API.G_TRUE then
         l_rounded_subsidy_amount :=  OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT
                                                 (l_converted_subsidy_amount,
                                                  l_contract_currency);

           IF (l_converted_subsidy_amount <> 0 AND l_rounded_subsidy_amount = 0) THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_AMOUNT_ROUNDING);
             x_return_status := OKL_API.G_RET_STS_ERROR;
             RAISE error_condition;
         End If;
         l_converted_subsidy_amount := l_rounded_subsidy_amount;
     End If;

     x_converted_amount   := l_converted_subsidy_amount;
     Exception
     When Error_Condition Then
         Null;
     When Others Then
         x_return_status :=  OKL_API.G_RET_STS_UNEXP_ERROR;
End Convert_Currency;
--------------------------------------------------------------------------------
--Name         : calculate_subsidy_amount
--Description  : API to calculate subsidy amount based on subsidy calculation
--               criteria for a subsidy line.
--Notes        :
--               Always calculates actual amount to
--               be stored in okl_k_lines.amount column for the subsidy line.
--               This will be called from OKL_ASSET_SUBSIDY_PVT.calculate_Asset_subsidy
--               to calculate subsidy amount. This does not consider subsidy_override_amount.
--               For considering subsidy_override_amount please use overloded form
--               of calculate_subsidy_amount with extra parameter p_override_yn.
-- PARAMETERS  : IN - p_subsidy_cle_id  : subsidy line id
--               OUT - x_subsidy_amount : subsidy amount
--------------------------------------------------------------------------------
PROCEDURE calculate_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subsidy_cle_id               IN  NUMBER,
    x_subsidy_amount               OUT NOCOPY NUMBER) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'CALCULATE_SUBSIDY_AMOUNT';
    l_api_version          CONSTANT     NUMBER := 1.0;

    --cursor to fetch calculation basis
    cursor l_sub_calc_csr(p_subsidy_cle_id IN NUMBER) is
    Select sub_cle.id                      subsidy_cle_id,
           sub_cle.dnz_chr_id              dnz_chr_id,
           sub_cle.start_date              subsidy_start_date,
           sub_kle.subsidy_id              subsidy_id,
           sub_kle.amount                  subsidy_line_amount,
           sub_cle.cle_id                  asset_cle_id,
           sub_kle.subsidy_override_amount subsidy_override_amount,
           ast_kle.oec                     asset_oec,
           ast_kle.capital_amount          asset_capital_amount,
           ast_kle.residual_value          residual_value,
           subb.subsidy_calc_basis         subsidy_calc_basis,
           subb.amount                     subsidy_setup_amount,
           subb.name                       subsidy_name,
           subb.percent                    subsidy_setup_percent,
           subb.formula_id                 formula_id,
           subb.rate_points                rate_points,
           subb.currency_code              subsidy_setup_currency,
           sub_cle.currency_code           contract_currency,
           --Bug# 3313802 :
           subb.maximum_financed_amount    maximum_financed_amount,
           subb.maximum_subsidy_amount     maximum_subsidy_amount
    from   okc_k_lines_b      sub_cle,
           okl_k_lines        sub_kle,
           okl_k_lines        ast_kle,
           okl_subsidies_b    subb
    where  subb.id      = sub_kle.subsidy_id
    and    ast_kle.id   = sub_cle.cle_id
    and    sub_kle.id   = sub_cle.id
    and    sub_cle.id   = p_subsidy_cle_id
    and    sub_cle.sts_code <> 'ABANDONED';

    l_sub_calc_rec                l_sub_calc_csr%ROWTYPE;
    l_subsidy_amount              Number;
    l_finance_amount              Number;  -- Added by veramach for Bug#6622178

    l_converted_subsidy_amount      Number;
    l_conv_max_fin_amount           Number;
    l_conv_max_sub_amount           Number;

    --Cursor to get formula name
    cursor l_fmla_csr (p_formula_id in NUMBER) is
    Select name
    from   okl_formulae_b
    where  id = p_formula_id;

    l_formula_name okl_formulae_b.name%TYPE;

    l_oec number;

    -----------------------
    --Bug# 3394233
    /*-----------------------
    --cursor to get any maximum financed amount OR maximum subsidy restrictions defined for
    --inventory item
    --cursor l_sub_limits_csr(p_chr_id in number,p_asset_cle_id in number, p_subsidy_id in number) is
    --select suc.maximum_subsidy_amount,
           --suc.maximum_financed_amount
    --from   okl_subsidy_criteria suc,
           --okc_k_items          cim,
           --okc_k_lines_b        cleb, --modelline
           --okc_line_styles_b    lseb
    --where  suc.subsidy_id                  = p_subsidy_id
    --and    to_char(suc.organization_id)    = cim.object1_id1
    --and    to_char(suc.inventory_item_id)  = cim.object1_id2
    --and    cim.jtot_object1_code           = 'OKX_SYSITEM'
    --and    cim.dnz_chr_id                  = cleb.dnz_chr_id
    --and    cim.cle_id                      = cleb.id
    --and    cleb.cle_id                     = p_asset_cle_id
    --and    lseb.id                         = cleb.lse_id
    --and    lseb.lty_code                   = 'ITEM'
    --and    cleb.dnz_chr_id                 = p_chr_id;
    -----------------------*/
    --Bug# 3394233
    -----------------------


    l_max_subsidy_amount  number;
    l_max_financed_amount number;

    --cursor to find out calculation basis meaning for errors
    cursor l_flkup_csr (p_lookup_code in varchar2,
                        p_lookup_type in varchar2) is
    select flkup.meaning
    from   fnd_lookups flkup
    where  flkup.lookup_type = p_lookup_type
    and    flkup.lookup_code = p_lookup_code;

    l_flkup_meaning fnd_lookups.meaning%TYPE;


begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    ---------------------------------------
    --start of input parameter validations
    ---------------------------------------
    --1.validate p_subsidy_cle_id
    If (p_subsidy_cle_id is NULL) or (p_subsidy_cle_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_subsidy_cle_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_subsidy_cle_id is not NULL) and (p_subsidy_cle_id <> OKL_API.G_MISS_NUM) then
        validate_cle_id(p_cle_id        => p_subsidy_cle_id,
                        p_lty_code      => 'SUBSIDY',
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_subsidy_cle_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    ------------------------------------
    --end of input variable validations
    ------------------------------------


    Open l_sub_calc_csr(p_subsidy_cle_id => p_subsidy_cle_id);
    Fetch l_sub_calc_csr into l_sub_calc_rec;
    If l_sub_calc_csr%NOTFOUND then
        --raise error
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_MISSING_SUB_CALC_BASIS
                            );
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- halt validation as it is a required setup
        RAISE OKL_API.G_EXCEPTION_ERROR;
    End If;
    Close l_sub_calc_csr;

    --always calculate do not override the original calculated amount
    --overide amount considered in overloaded calculate_subsidy_amount API
    IF l_sub_calc_rec.subsidy_calc_basis is Null OR l_sub_calc_rec.subsidy_calc_basis = OKL_API.G_MISS_CHAR then
        --raise error
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_MISSING_SUB_CALC_BASIS,
                            p_token1       => G_SUBSIDY_NAME_TOKEN,
		            p_token1_value => l_sub_calc_rec.subsidy_name
                            );
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- halt validation as it is a required setup to go ahead
        RAISE OKL_API.G_EXCEPTION_ERROR;
    ElsIf l_sub_calc_rec.subsidy_calc_basis = 'FIXED' then
        If l_sub_calc_rec.subsidy_setup_amount is Null OR  l_sub_calc_rec.subsidy_setup_amount = OKL_API.G_MISS_NUM then

            --raise error
            open l_flkup_csr(p_lookup_type => 'OKL_SUBCALC_BASIS',
                             p_lookup_code => l_sub_calc_rec.subsidy_calc_basis);
            fetch l_flkup_csr into l_flkup_meaning;
            If l_flkup_csr%NOTFOUND then
                l_flkup_meaning := l_sub_calc_rec.subsidy_calc_basis;
            End If;
            close l_flkup_csr;

            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_MISSING_SUB_CALC_PARAMETER,
                                p_token1       => G_PARAMETER_NAME_TOKEN,
		                p_token1_value => 'Amount',
                                p_token2       => G_CALC_BASIS_TOKEN,
		                p_token2_value => l_flkup_meaning,
                                p_token3       => G_SUBSIDY_NAME_TOKEN,
		                p_token3_value => l_sub_calc_rec.subsidy_name
                                );
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- halt validation as it is a required setup to go ahead
            RAISE OKL_API.G_EXCEPTION_ERROR;
        Else
            If l_sub_calc_rec.subsidy_setup_currency = l_sub_calc_rec.contract_currency then
                l_subsidy_amount :=  l_sub_calc_rec.subsidy_setup_amount;
            Elsif l_sub_calc_rec.subsidy_setup_currency <> l_sub_calc_rec.contract_currency then
                Convert_currency(p_khr_id             => l_sub_calc_rec.dnz_chr_id,
                                 p_from_currency      => l_sub_calc_rec.subsidy_setup_currency,
                                 p_transaction_date   => l_sub_calc_rec.subsidy_start_date,
                                 p_amount             => l_sub_calc_rec.subsidy_setup_amount,
                                 x_converted_amount   => l_converted_subsidy_amount,
                                 x_return_status      => x_return_status);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                 l_subsidy_amount := l_converted_subsidy_amount;
             End If;
         End if;
    ElsIf  l_sub_calc_rec.subsidy_calc_basis = 'ASSETCOST' then
        If l_sub_calc_rec.subsidy_setup_percent is Null OR  l_sub_calc_rec.subsidy_setup_percent = OKL_API.G_MISS_NUM then

            --raise error
            open l_flkup_csr(p_lookup_type => 'OKL_SUBCALC_BASIS',
                             p_lookup_code => l_sub_calc_rec.subsidy_calc_basis);
            fetch l_flkup_csr into l_flkup_meaning;
            If l_flkup_csr%NOTFOUND then
                l_flkup_meaning := l_sub_calc_rec.subsidy_calc_basis;
            End If;
            close l_flkup_csr;


            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_MISSING_SUB_CALC_PARAMETER,
                                p_token1       => G_PARAMETER_NAME_TOKEN,
		                p_token1_value => 'Percent',
                                p_token2       => G_CALC_BASIS_TOKEN,
		                p_token2_value => l_flkup_meaning,
                                p_token3       => G_SUBSIDY_NAME_TOKEN,
		                p_token3_value => l_sub_calc_rec.subsidy_name
                                );
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- halt validation as it is a required setup to go ahead
            RAISE OKL_API.G_EXCEPTION_ERROR;
        Else
            --get original equipment cost from formula
            OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_formula_name  => G_FORMULA_OEC,
                                    p_contract_id   => l_sub_calc_rec.dnz_chr_id,
                                    p_line_id       => l_sub_calc_rec.asset_cle_id,
                                    x_value         => l_oec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            --Bug# 3313802 : maximum financed amount moved from subsidy criteria to
            --               main subsidy setup
            /*-----------------------------------------------------------------------
            --check if there is any maximum financed amount restriction on this subsidy
            --open l_sub_limits_csr(p_chr_id        => l_sub_calc_rec.dnz_chr_id,
                                  --p_asset_cle_id  => l_sub_calc_rec.asset_cle_id,
                                  --p_subsidy_id    => l_sub_calc_rec.subsidy_id);
            --fetch  l_sub_limits_csr into l_max_subsidy_amount,
                                         --l_max_financed_amount;
            --If l_sub_limits_csr%NOTFOUND then
                --null;
            --Else
            -------------------------------------------------------------------------*/

            l_max_financed_amount := l_sub_calc_rec.maximum_financed_amount;

            IF l_sub_calc_rec.subsidy_setup_currency = l_sub_calc_rec.contract_currency then
                l_conv_max_fin_amount := l_max_financed_amount;
            ELSIF l_sub_calc_rec.subsidy_setup_currency <> l_sub_calc_rec.contract_currency then
                Convert_currency(p_khr_id             => l_sub_calc_rec.dnz_chr_id,
                                 p_from_currency      => l_sub_calc_rec.subsidy_setup_currency,
                                 p_transaction_date   => l_sub_calc_rec.subsidy_start_date,
                                 p_amount             => l_max_financed_amount,
                                 x_converted_amount   => l_conv_max_fin_amount,
                                 x_return_status      => x_return_status);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
            End If;

            If (l_oec > l_conv_max_fin_amount) then
                l_oec := l_conv_max_fin_amount;
            End If;
            End If;

            --End If;
            --Close l_sub_limits_csr;

            l_subsidy_amount :=   l_oec * (l_sub_calc_rec.subsidy_setup_percent/100);

    ElsIf l_sub_calc_rec.subsidy_calc_basis = 'FORMULA' then
        If l_sub_calc_rec.formula_id is Null OR  l_sub_calc_rec.formula_id = OKL_API.G_MISS_NUM then

            --raise error
            open l_flkup_csr(p_lookup_type => 'OKL_SUBCALC_BASIS',
                             p_lookup_code => l_sub_calc_rec.subsidy_calc_basis);
            fetch l_flkup_csr into l_flkup_meaning;
            If l_flkup_csr%NOTFOUND then
                l_flkup_meaning := l_sub_calc_rec.subsidy_calc_basis;
            End If;
            close l_flkup_csr;


            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_MISSING_SUB_CALC_PARAMETER,
                                p_token1       => G_PARAMETER_NAME_TOKEN,
            	                p_token1_value => 'Formula Name',
                                p_token2       => G_CALC_BASIS_TOKEN,
		                p_token2_value => l_flkup_meaning,
                                p_token3       => G_SUBSIDY_NAME_TOKEN,
		                p_token3_value => l_sub_calc_rec.subsidy_name
                                );
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- halt validation as it is a required setup to go ahead
            RAISE OKL_API.G_EXCEPTION_ERROR;
        Else
            Open l_fmla_csr (p_formula_id =>   l_sub_calc_rec.formula_id);
            Fetch l_fmla_csr into l_formula_name;
            If l_fmla_csr%NOTFOUND then
                --raise error
                OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy Calculation Formula');
                x_return_status := OKL_API.G_RET_STS_ERROR;
                -- halt validation as it is a required setup to go ahead
                RAISE OKL_API.G_EXCEPTION_ERROR;
            End If;
            Close l_fmla_csr;

            --Execte Formula
            OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => x_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_formula_name  => l_formula_name,
                                            p_contract_id   => l_sub_calc_rec.dnz_chr_id,
                                            --Bug# 3487167
                                            p_line_id       => l_sub_calc_rec.asset_cle_id,
                                            --p_line_id       => l_sub_calc_rec.subsidy_cle_id,
                                            x_value         => l_subsidy_amount);
            If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
            End If;

        End If;
    Elsif l_sub_calc_rec.subsidy_calc_basis = 'RATE' then
        If l_sub_calc_rec.rate_points is Null OR  l_sub_calc_rec.rate_points = OKL_API.G_MISS_NUM then
            --raise error
            open l_flkup_csr(p_lookup_type => 'OKL_SUBCALC_BASIS',
                             p_lookup_code => l_sub_calc_rec.subsidy_calc_basis);
            fetch l_flkup_csr into l_flkup_meaning;
            If l_flkup_csr%NOTFOUND then
                l_flkup_meaning := l_sub_calc_rec.subsidy_calc_basis;
            End If;
            close l_flkup_csr;

            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_MISSING_SUB_CALC_PARAMETER,
                                p_token1       => G_PARAMETER_NAME_TOKEN,
		                p_token1_value => 'Rate Points',
                                p_token2       => G_CALC_BASIS_TOKEN,
		                p_token2_value => l_flkup_meaning,
                                p_token3       => G_SUBSIDY_NAME_TOKEN,
		                p_token3_value => l_sub_calc_rec.subsidy_name
                                );
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- halt validation as it is a required setup to go ahead
            RAISE OKL_API.G_EXCEPTION_ERROR;
        Else
            calc_rate_points_amount(p_api_version   => p_api_version,
                                   p_init_msg_list  => p_init_msg_list,
                                   x_return_status  => x_return_status,
                                   x_msg_count      => x_msg_count,
                                   x_msg_data       => x_msg_data,
                                   p_rate_points    => l_sub_calc_rec.rate_points,
                                   p_chr_id         => l_sub_calc_rec.dnz_chr_id,
                                   p_asset_cle_id   => l_sub_calc_rec.asset_cle_id,
                                   x_subsidy_amount => l_subsidy_amount);

            If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
                raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            Elsif (x_return_status = OKL_API.G_RET_STS_ERROR) then
                raise OKL_API.G_EXCEPTION_ERROR;
            End If;
        End If;

       -------------------------------------------------------------
       -- Added by veramach for Bug#6622178
       -- Calculating subsidy amount on the basis of Financed Amount
       -------------------------------------------------------------
       ELSIF  l_sub_calc_rec.subsidy_calc_basis = 'FINANCED_AMOUNT' THEN
            IF l_sub_calc_rec.subsidy_setup_percent IS NULL OR  l_sub_calc_rec.subsidy_setup_percent = OKL_API.G_MISS_NUM THEN
                --raise error
                OPEN l_flkup_csr(p_lookup_type => 'OKL_SUBCALC_BASIS',
                                 p_lookup_code => l_sub_calc_rec.subsidy_calc_basis);
                FETCH l_flkup_csr INTO l_flkup_meaning;
                IF l_flkup_csr%NOTFOUND THEN
                    l_flkup_meaning := l_sub_calc_rec.subsidy_calc_basis;
                END IF;
                CLOSE l_flkup_csr;
                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_MISSING_SUB_CALC_PARAMETER,
                                    p_token1       => G_PARAMETER_NAME_TOKEN,
                                    p_token1_value => 'Percent',
                                    p_token2       => G_CALC_BASIS_TOKEN,
                                    p_token2_value => l_flkup_meaning,
                                    p_token3       => G_SUBSIDY_NAME_TOKEN,
                                    p_token3_value => l_sub_calc_rec.subsidy_name
                                    );
                x_return_status := OKL_API.G_RET_STS_ERROR;
                --halt validation as it is a required setup to go ahead
                RAISE OKL_API.G_EXCEPTION_ERROR;
            ELSE
                --get original financed amount from formula
                OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                        p_init_msg_list => p_init_msg_list,
                                        x_return_status => x_return_status,
                                        x_msg_count     => x_msg_count,
                                        x_msg_data      => x_msg_data,
                                        p_formula_name  => 'FRONT_END_FINANCED_AMOUNT',
                                        p_contract_id   => l_sub_calc_rec.dnz_chr_id,
                                        p_line_id       => l_sub_calc_rec.asset_cle_id,
                                        x_value         => l_finance_amount);
                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                l_max_financed_amount := l_sub_calc_rec.maximum_financed_amount;

                IF l_sub_calc_rec.subsidy_setup_currency = l_sub_calc_rec.contract_currency then
                    l_conv_max_fin_amount := l_max_financed_amount;
                ELSIF l_sub_calc_rec.subsidy_setup_currency <> l_sub_calc_rec.contract_currency then
                    Convert_currency(p_khr_id             => l_sub_calc_rec.dnz_chr_id,
                                     p_from_currency      => l_sub_calc_rec.subsidy_setup_currency,
                                     p_transaction_date   => l_sub_calc_rec.subsidy_start_date,
                                     p_amount             => l_max_financed_amount,
                                     x_converted_amount   => l_conv_max_fin_amount,
                                     x_return_status      => x_return_status);

                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                END IF;

                IF (l_finance_amount > l_conv_max_fin_amount) THEN
                    l_finance_amount := l_conv_max_fin_amount;
                END IF;
            END IF;
            l_subsidy_amount :=   l_finance_amount * (l_sub_calc_rec.subsidy_setup_percent/100);
    -- End by veramach for Bug#6622178
    Else
         OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy Calculation Basis');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    --Bug# 3313802 : Maximum subsidy amount moved from subsidy
    /*--------------------------------------------------------------------
    --check for limits on subsidy amount for this inventory item
    --open l_sub_limits_csr(p_chr_id        => l_sub_calc_rec.dnz_chr_id,
                          --p_asset_cle_id  => l_sub_calc_rec.asset_cle_id,
                          --p_subsidy_id    => l_sub_calc_rec.subsidy_id);
    --fetch  l_sub_limits_csr into l_max_subsidy_amount,
                                 --l_max_financed_amount;
    --If l_sub_limits_csr%NOTFOUND then
        --null;
    --Else
    --------------------------------------------------------------------------*/
    l_max_subsidy_amount := l_sub_calc_rec.maximum_subsidy_amount;
    IF l_sub_calc_rec.subsidy_setup_currency = l_sub_calc_rec.contract_currency then
        l_conv_max_sub_amount := l_max_subsidy_amount;
    ELSIF l_sub_calc_rec.subsidy_setup_currency <> l_sub_calc_rec.contract_currency then
        Convert_currency(p_khr_id             => l_sub_calc_rec.dnz_chr_id,
                         p_from_currency      => l_sub_calc_rec.subsidy_setup_currency,
                         p_transaction_date   => l_sub_calc_rec.subsidy_start_date,
                         p_amount             => l_max_subsidy_amount,
                         x_converted_amount   => l_conv_max_sub_amount,
                         x_return_status      => x_return_status);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;
    If (l_subsidy_amount > l_conv_max_sub_amount) then
        l_subsidy_amount := l_conv_max_sub_amount;
    End If;

    --End If;
    --Close l_sub_limits_csr;

    x_subsidy_amount := l_subsidy_amount;
    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If l_sub_calc_csr%ISOPEN then
        CLOSE l_sub_calc_csr;
    End If;
    If l_fmla_csr%ISOPEN then
        CLOSE l_fmla_csr;
    End If;
    -----------------------
    --Bug# 3394233
    /*--------------------------
    --If l_sub_limits_csr%ISOPEN then
        --CLOSE l_sub_limits_csr;
    --End If;
    ---------------------------*/
    --Bug# 3394233
    -----------------------
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If l_sub_calc_csr%ISOPEN then
        CLOSE l_sub_calc_csr;
    End If;
    If l_fmla_csr%ISOPEN then
        CLOSE l_fmla_csr;
    End If;
    -----------------------
    --Bug# 3394233
    /*--------------------------
    --If l_sub_limits_csr%ISOPEN then
        --CLOSE l_sub_limits_csr;
    --End If;
    ---------------------------*/
    --Bug# 3394233
    -----------------------
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_sub_calc_csr%ISOPEN then
        CLOSE l_sub_calc_csr;
    End If;
    If l_fmla_csr%ISOPEN then
        CLOSE l_fmla_csr;
    End If;
    -----------------------
    --Bug# 3394233
    /*--------------------------
    --If l_sub_limits_csr%ISOPEN then
        --CLOSE l_sub_limits_csr;
    --End If;
    ---------------------------*/
    --Bug# 3394233
    -----------------------
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End calculate_subsidy_amount;
--------------------------------------------------------------------------------
--Name         : calculate_subsidy_amount (overloaded)
--Description  : API to calculate subsidy amount based on subsidy calculation
--               criteria for a subsidy line. If subsidy_override amount is
--               specified and overloaded parameter p_override_yn is
--               OKL_API.G_TRUE then subsidy_amount = subsidy_override_amount
--               This overloaded form will be called to re-calculate total of
--               subsidies at asset or contract level at the time of QA check
--               or any other time where total calculated is to be copared
--               against total stored amount of subsidies
-- PARAMETERS  : IN - p_subsidy_cle_id  : subsidy line id
--                    p_override_yn     : OKL_API.G_TRUE/OKL_API.G_FALSE (will
--                                        determine whether subsidy override
--                                        amount is to be taken into account
--               OUT - x_subsidy_amount : subsidy amount
--------------------------------------------------------------------------------
PROCEDURE calculate_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subsidy_cle_id               IN  NUMBER,
    p_override_yn                  IN  VARCHAR2,
    x_subsidy_amount               OUT NOCOPY NUMBER) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'CALCULATE_SUBSIDY_AMOUNT';
    l_api_version          CONSTANT     NUMBER := 1.0;

    --------------------------------------------------
    --cursor to fetch subsidy override amount
    --------------------------------------------------
    cursor l_kle_csr (p_cle_id in number) is
    select kle.subsidy_override_amount
    from   okl_k_lines kle,
           okc_k_lines_b cleb
    where  kle.id         = cleb.id
    and    cleb.sts_code  <> 'ABANDONED'
    and    cleb.id        = p_cle_id;

    l_subsidy_override_amount okl_k_lines.subsidy_override_amount%TYPE default NULL;
    l_subsidy_amount          number;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    --start of input parameter validations
    --------------------------------------
    --1.validate p_subsidy_cle_id
    If (p_subsidy_cle_id is NULL) or (p_subsidy_cle_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_subsidy_cle_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_subsidy_cle_id is not NULL) and (p_subsidy_cle_id <> OKL_API.G_MISS_NUM) then
        validate_cle_id(p_cle_id        => p_subsidy_cle_id,
                        p_lty_code      => 'SUBSIDY',
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_subsidy_cle_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;

    --2.validate p_override_yn
    If p_override_yn is NULL Then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_override_yn');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;

    ElsIf (p_override_yn is Not Null) then
       If p_override_yn not in (OKL_API.G_TRUE,OKL_API.G_FALSE) then
           OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_override_yn');
           Raise OKL_API.G_EXCEPTION_ERROR;
       End If;
    End If;
    -----------------------------------
    --end of input variable validations
    -----------------------------------

    If p_override_yn = OKL_API.G_TRUE then
        open l_kle_csr (p_cle_id => p_subsidy_cle_id);
        fetch l_kle_csr into l_subsidy_override_amount;
        if l_kle_csr%NOTFOUND then
            Null;
        End If;
        close l_kle_csr;
    End If;

    If (l_subsidy_override_amount is NOT NULL) and
       (l_subsidy_override_amount <> OKL_API.G_MISS_NUM) and
       (p_override_yn = OKL_API.G_TRUE)  then

        l_subsidy_amount := l_subsidy_override_amount;

    Elsif (l_subsidy_override_amount is NULL) OR
          (l_subsidy_override_amount = OKL_API.G_MISS_NUM) OR
          (p_override_yn = OKL_API.G_FALSE) then

        calculate_subsidy_amount(
                                 p_api_version     => p_api_version,
                                 p_init_msg_list   => p_init_msg_list,
                                 x_return_status   => x_return_status,
                                 x_msg_count       => x_msg_count,
                                 x_msg_data        => x_msg_data,
                                 p_subsidy_cle_id  => p_subsidy_cle_id,
                                 x_subsidy_amount  => l_subsidy_amount);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

    End If;

    x_subsidy_amount := l_subsidy_amount;
    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If l_kle_csr%ISOPEN then
        close l_kle_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If l_kle_csr%ISOPEN then
        close l_kle_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_kle_csr%ISOPEN then
        close l_kle_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END calculate_subsidy_amount;
--------------------------------------------------------------------------------
--Name         : get_subsidy_amount
--Description  : API to get subsidy amount based on subsidy calculation
--               criteria for a subsidy line
-- PARAMETERS  : IN - p_subsidy_cle_id  : subsidy line id
--               OUT - x_subsidy_amount: subsidy amount
--------------------------------------------------------------------------------
PROCEDURE get_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subsidy_cle_id               IN  NUMBER,
    x_subsidy_amount               OUT NOCOPY NUMBER) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'GET_SUBSIDY_AMOUNT';
    l_api_version          CONSTANT     NUMBER := 1.0;

    l_subsidy_amount       Number;

    --cursor to get subsidy amount
    --should read override amount if it is specified, else amount
    cursor l_cleb_csr (p_cle_id in number) is
    select nvl(kle.subsidy_override_amount,nvl(kle.amount,0))
    from   okl_k_lines    kle,
           okc_k_lines_b  cleb
    where  kle.id       = cleb.id
    and    cleb.id      = p_subsidy_cle_id
    and    cleb.sts_code <> 'ABANDONED';



Begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -----------------------------------------
    --start of input parameter validations
    -----------------------------------------
    --1.validate p_subsidy_cle_id
    If (p_subsidy_cle_id is NULL) or (p_subsidy_cle_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_subsidy_cle_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_subsidy_cle_id is not NULL) and (p_subsidy_cle_id <> OKL_API.G_MISS_NUM) then
        validate_cle_id(p_cle_id        => p_subsidy_cle_id,
                        p_lty_code      => 'SUBSIDY',
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_subsidy_cle_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    -------------------------------------
    --end of input parameter validations
    -------------------------------------


    l_subsidy_amount := 0;
    -----------------------------------------------
    -- fetch the subsidy amount from subsidy line
    -----------------------------------------------
    Open l_cleb_csr (p_cle_id => p_subsidy_cle_id);
    fetch l_cleb_csr into  l_subsidy_amount;
    If  l_cleb_csr%NOTFOUND then
        null;
    End If;
    Close l_cleb_csr;

    x_subsidy_amount := l_subsidy_amount;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If l_cleb_csr%ISOPEN then
        CLOSE l_cleb_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If l_cleb_csr%ISOPEN then
        CLOSE l_cleb_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_cleb_csr%ISOPEN then
        CLOSE l_cleb_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End get_subsidy_amount;
--------------------------------------------------------------------------------
--Name         : get_subsidy_amount
--Description  : API to get subsidy amount along with other details from the
--               subsidy line
-- PARAMETERS  : IN - p_subsidy_cle_id  : subsidy line id
--               OUT - x_asbv_rec : subsidy amount with details of vendor, pay to
--                                  details etc (AM may need this)
--------------------------------------------------------------------------------
PROCEDURE get_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subsidy_cle_id               IN  NUMBER,
    x_asbv_rec                     OUT NOCOPY asbv_rec_type) is


    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'GET_SUBSIDY_AMOUNT';
    l_api_version          CONSTANT     NUMBER := 1.0;

    l_asbv_rec         asbv_rec_type;
    l_subsidy_amount   number;

    --Cursor to get other subsdiy details
    cursor l_sub_dtls_csr (p_subsidy_cle_id in number) is
    select
        sub_kle.subsidy_id              subsidy_id
       ,sub_cleb.id                     subsidy_cle_id
       ,sub_clet.name                   name
       ,sub_clet.item_description       description
       ,sub_kle.sty_id                  stream_type_id
       ,subb.accounting_method_code     accounting_method_code
       ,subb.maximum_term               maximum_term
       ,sub_kle.subsidy_override_amount subsidy_override_amount
       ,sub_cleb.dnz_chr_id             dnz_chr_id
       ,sub_cleb.cle_id                 asset_cle_id
       ,cplb.id                         cpl_id
       ,pov.vendor_id                   vendor_id
       ,pov.vendor_name                 vendor_name
       ,ppyd.pay_site_id                pay_site_id
       ,ppyd.payment_term_id            payment_term_id
       ,ppyd.payment_method_code        payment_method_code
       ,ppyd.pay_group_code             pay_group_code
       --
       ,sub_cleb.start_date             start_date
       ,sub_cleb.end_date               end_date
       ,subb.expire_after_days          expire_after_days
       ,subb.currency_code              currency_code
       ,subb.exclusive_yn               exclusive_yn
       ,subb.applicable_to_release_yn   applicable_to_release_yn
       ,subb.recourse_yn                recourse_yn
       ,subb.termination_refund_basis   termination_refund_basis
       ,subb.refund_formula_id          refund_formula_id
       ,subb.receipt_method_code        receipt_method_code
       ,subb.customer_visible_yn        customer_visible_yn
   from okl_subsidies_b        subb,
        okc_k_lines_b          sub_cleb,
        okc_k_lines_tl         sub_clet,
        okl_k_lines            sub_kle,
        okc_k_party_roles_b    cplb,
        po_vendors             pov,
        okl_party_payment_dtls ppyd
   where ppyd.cpl_id(+)          = cplb.id --payment details may not be mandatory
   and   ppyd.vendor_id(+)       = cplb.object1_id1
   and   to_char(pov.vendor_id)  = cplb.object1_id1
   and   cplb.object1_id2        = '#'
   and   cplb.jtot_object1_code  = 'OKX_VENDOR'
   and   cplb.rle_code           = 'OKL_VENDOR'
   and   cplb.cle_id             = sub_cleb.id
   and   cplb.dnz_chr_id         = sub_cleb.dnz_chr_id
   and   subb.id                 = sub_kle.subsidy_id
   and   sub_kle.id              = sub_cleb.id
   and   sub_clet.id             = sub_cleb.id
   and   sub_clet.language       = userenv('LANG')
   and   sub_cleb.id             = p_subsidy_cle_id;

   l_sub_dtls_rec l_sub_dtls_csr%ROWTYPE;

Begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    ---------------------------------------
    --start of input parameter validations
    ---------------------------------------
    --1.validate p_subsidy_cle_id
    If (p_subsidy_cle_id is NULL) or (p_subsidy_cle_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_subsidy_cle_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_subsidy_cle_id is not NULL) and (p_subsidy_cle_id <> OKL_API.G_MISS_NUM) then
        validate_cle_id(p_cle_id        => p_subsidy_cle_id,
                        p_lty_code      => 'SUBSIDY',
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_subsidy_cle_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    ------------------------------------------
    --end of input parameter validations
    ------------------------------------------


    ------------------------------------------------------
    --call api to get subsidy amount
    ------------------------------------------------------
    get_subsidy_amount(
    p_api_version      => p_api_version,
    p_init_msg_list    => p_init_msg_list,
    x_return_status    => x_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data,
    p_subsidy_cle_id   => p_subsidy_cle_id,
    x_subsidy_amount   => l_subsidy_amount);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    ----------------------------------------------------------------------------
    --fetch other details for subsidy
    ----------------------------------------------------------------------------
    Open l_sub_dtls_csr(p_subsidy_cle_id => p_subsidy_cle_id);
    Fetch l_sub_dtls_csr into l_sub_dtls_rec;
    If l_sub_dtls_csr%NOTFOUND then
        --need to raise error here (should have been taken care in call above)
        null;
    End If;
    Close l_sub_dtls_csr;

    ----------------------------------------------------------------------------
    --initialize output rec
    ----------------------------------------------------------------------------
    l_asbv_rec.subsidy_id               := l_sub_dtls_rec.subsidy_id;
    l_asbv_rec.subsidy_cle_id           := l_sub_dtls_rec.subsidy_cle_id;
    l_asbv_rec.name                     := l_sub_dtls_rec.name;
    l_asbv_rec.description              := l_sub_dtls_rec.description;
    l_asbv_rec.amount                   := l_subsidy_amount;
    l_asbv_rec.stream_type_id           := l_sub_dtls_rec.stream_type_id;
    l_asbv_rec.accounting_method_code   := l_sub_dtls_rec.accounting_method_code;
    l_asbv_rec.maximum_term             := l_sub_dtls_rec.maximum_term;
    l_asbv_rec.subsidy_override_amount  := l_sub_dtls_rec.subsidy_override_amount;
    l_asbv_rec.dnz_chr_id               := l_sub_dtls_rec.dnz_chr_id;
    l_asbv_rec.asset_cle_id             := l_sub_dtls_rec.asset_cle_id;
    l_asbv_rec.cpl_id                   := l_sub_dtls_rec.cpl_id;
    l_asbv_rec.vendor_id                := l_sub_dtls_rec.vendor_id;
    l_asbv_rec.vendor_name              := l_sub_dtls_rec.vendor_name;
    l_asbv_rec.pay_site_id              := l_sub_dtls_rec.pay_site_id;
    l_asbv_rec.payment_term_id          := l_sub_dtls_rec.payment_term_id;
    l_asbv_rec.payment_method_code      := l_sub_dtls_rec.payment_method_code;
    l_asbv_rec.pay_group_code           := l_sub_dtls_rec.pay_group_code;
    --
    l_asbv_rec.start_date               := l_sub_dtls_rec.start_date;
    l_asbv_rec.end_date                 := l_sub_dtls_rec.end_date;
    l_asbv_rec.expire_after_days        := l_sub_dtls_rec.expire_after_days;
    l_asbv_rec.currency_code            := l_sub_dtls_rec.currency_code;
    l_asbv_rec.exclusive_yn             := l_sub_dtls_rec.exclusive_yn;
    l_asbv_rec.applicable_to_release_yn := l_sub_dtls_rec.applicable_to_release_yn;
    l_asbv_rec.recourse_yn              := l_sub_dtls_rec.recourse_yn;
    l_asbv_rec.termination_refund_basis := l_sub_dtls_rec.termination_refund_basis;
    l_asbv_rec.refund_formula_id        := l_sub_dtls_rec.refund_formula_id;
    l_asbv_rec.receipt_method_code      := l_sub_dtls_rec.receipt_method_code;
    l_asbv_rec.customer_visible_yn      := l_sub_dtls_rec.customer_visible_yn;
    ----------------------------------------------------------------------------

    x_asbv_rec := l_asbv_rec;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_sub_dtls_csr%ISOPEN then
        CLOSE l_sub_dtls_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End get_subsidy_amount;
--------------------------------------------------------------------------------
--Name         : get_asset_subsidy_amount
--Description  : API to fetch subsidy amount an asset
-- PARAMETERS  : IN - p_asset_cle_id   : financial asset line id, p_accounting_method(NET or AMORTIZE)
--               OUT - l_subsidy_amount: subsidy amount
--------------------------------------------------------------------------------
PROCEDURE get_asset_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asset_cle_id                 IN  NUMBER,
    p_accounting_method            IN  VARCHAR2,
    x_subsidy_amount               OUT NOCOPY NUMBER) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'GET_ASSET_SUBSIDY';
    l_api_version          CONSTANT     NUMBER := 1.0;

    l_subsidy_amount       Number;

    l_asset_subsidy_amount Number;

    --cursor to fetch all the subsidies attached to financial asset
    cursor l_sub_csr(p_asset_cle_id in number) is
    select sub_cle.id
    from   okl_subsidies_b    subb,
           okl_k_lines        sub_kle,
           okc_k_lines_b      sub_cle,
           okc_line_styles_b  sub_lse
    where  subb.id                     = sub_kle.subsidy_id
    and    subb.accounting_method_code = nvl(upper(p_accounting_method),subb.accounting_method_code)
    and    sub_kle.id                  = sub_cle.id
    and    sub_cle.cle_id              = p_asset_cle_id
    and    sub_cle.lse_id              = sub_lse.id
    and    sub_lse.lty_code            = 'SUBSIDY'
    and    sub_cle.sts_code            <> 'ABANDONED';

    l_subsidy_cle_id number;
begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

/*----commented this validation as it causes issues during booking
    --------------------------------------
    --start of input parameter validations
    --------------------------------------
    --1.validate p_asset_cle_id
    If (p_asset_cle_id is NULL) or (p_asset_cle_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_asset_cle_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_asset_cle_id is not NULL) and (p_asset_cle_id <> OKL_API.G_MISS_NUM) then
        validate_cle_id(p_cle_id        => p_asset_cle_id,
                        p_lty_code      => 'FREE_FORM1',
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_asset_cle_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    --2.validate accounting method
    If (p_accounting_method is NOT NULL) then
        validate_acct_method(p_accounting_method => p_accounting_method,
                             x_return_status     => x_return_status);
       IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_accounting_method');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    ------------------------------------
    --end of input parameter validations
    ------------------------------------
---commented this validation as this causes issues during booking------*/



    l_asset_subsidy_amount := 0;

    --------------------------------------------------------------
    --get all the subsidies associated to asset and get amount
    --------------------------------------------------------------
    Open l_sub_csr(p_asset_cle_id => p_asset_cle_id);
    Loop
        Fetch l_sub_csr into l_subsidy_cle_id;
        Exit when l_sub_csr%NOTFOUND;
        get_subsidy_amount(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_subsidy_cle_id   => l_subsidy_cle_id,
            x_subsidy_amount   => l_subsidy_amount);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_asset_subsidy_Amount := l_asset_subsidy_Amount + l_subsidy_amount;
    End Loop;
    Close l_sub_csr;

    x_subsidy_amount := l_asset_subsidy_amount;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_sub_csr%ISOPEN then
        CLOSE l_sub_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

End get_asset_subsidy_amount;

--------------------------------------------------------------------------------
--Name         : get_asset_subsidy_amount
--Description  : API to get subsidy amount for an asset
-- PARAMETERS  : IN - p_asset_cle_id   : financial asset line id
--               OUT - l_asbv_tbl:subsidy amount with additional details about
--                     subsidy vendor
--------------------------------------------------------------------------------
PROCEDURE get_asset_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asset_cle_id                 IN  NUMBER,
    x_asbv_tbl                     OUT NOCOPY asbv_tbl_type) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'GET_ASSET_SUBSIDY';
    l_api_version          CONSTANT     NUMBER := 1.0;

    l_asbv_tbl             asbv_tbl_type;

    --cursor to fetch all the subsidies attached to financial asset
    cursor l_sub_csr(p_asset_cle_id in number) is
    select sub_cle.id
    from   okc_k_lines_b      sub_cle,
           okc_line_styles_b  sub_lse
    where  sub_cle.cle_id   = p_asset_cle_id
    and    sub_cle.lse_id   = sub_lse.id
    and    sub_lse.lty_code = 'SUBSIDY'
    and    sub_cle.sts_code <> 'ABANDONED';

    l_subsidy_cle_id number;
    i number;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    ---------------------------------------
    --start of input parameter validations
    ---------------------------------------
    --1.validate p_asset_cle_id
    If (p_asset_cle_id is NULL) or (p_asset_cle_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_asset_cle_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_asset_cle_id is not NULL) and (p_asset_cle_id <> OKL_API.G_MISS_NUM) then
        validate_cle_id(p_cle_id        => p_asset_cle_id,
                        p_lty_code      => 'FREE_FORM1',
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_asset_cle_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    -------------------------------------
    --end of input parameter validations
    -------------------------------------

    i := 0;
    Open l_sub_csr(p_asset_cle_id => p_asset_cle_id);
    Loop
        Fetch l_sub_csr into l_subsidy_cle_id;
        Exit when l_sub_csr%NOTFOUND;
        i := i + 1;
        get_subsidy_amount(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_subsidy_cle_id   => l_subsidy_cle_id,
            x_asbv_rec         => l_asbv_tbl(i));

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    End Loop;
    Close l_sub_csr;

    x_asbv_tbl := l_asbv_tbl;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_sub_csr%ISOPEN then
        CLOSE l_sub_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

End get_asset_subsidy_amount;
--------------------------------------------------------------------------------
--Name         : calculate_asset_subsidy
--Description  : API to calculate total subsidy amount for an asset
-- PARAMETERS  : IN - p_asset_cle_id   : financial asset line id
--               OUT - l_subsidy_amount: subsidy amount
--------------------------------------------------------------------------------
PROCEDURE calculate_asset_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asset_cle_id                 IN  NUMBER,
    x_subsidy_amount               OUT NOCOPY NUMBER) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'CALC_ASSET_SUBSIDY';
    l_api_version          CONSTANT     NUMBER := 1.0;

    l_subsidy_amount       Number;

    l_asset_subsidy_amount Number;

    --cursor to fetch all the subsidies attached to financial asset
    cursor l_sub_csr(p_asset_cle_id in number) is
    select sub_cle.id
    from   okc_k_lines_b      sub_cle,
           okc_line_styles_b  sub_lse
    where  sub_cle.cle_id   = p_asset_cle_id
    and    sub_cle.lse_id   = sub_lse.id
    and    sub_lse.lty_code = 'SUBSIDY'
    and    sub_cle.sts_code <> 'ABANDONED';

    l_subsidy_cle_id number;
begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    ---------------------------------------
    --start of input parameter validations
    ---------------------------------------
    --1.validate p_asset_cle_id
    If (p_asset_cle_id is NULL) or (p_asset_cle_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_asset_cle_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_asset_cle_id is not NULL) and (p_asset_cle_id <> OKL_API.G_MISS_NUM) then
        validate_cle_id(p_cle_id        => p_asset_cle_id,
                        p_lty_code      => 'FREE_FORM1',
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_asset_cle_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    ------------------------------------
    --end of input parameter validations
    ------------------------------------

    l_asset_subsidy_amount := 0;

    --------------------------------------------------------------
    --get all the subsidies associated to asset and get amount
    --------------------------------------------------------------
    Open l_sub_csr(p_asset_cle_id => p_asset_cle_id);
    Loop
        Fetch l_sub_csr into l_subsidy_cle_id;
        Exit when l_sub_csr%NOTFOUND;
        calculate_subsidy_amount(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_subsidy_cle_id   => l_subsidy_cle_id,
            p_override_yn      => OKL_API.G_TRUE,
            x_subsidy_amount   => l_subsidy_amount);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_asset_subsidy_Amount := l_asset_subsidy_Amount + l_subsidy_amount;
    End Loop;
    Close l_sub_csr;

    x_subsidy_amount := l_asset_subsidy_amount;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_sub_csr%ISOPEN then
        CLOSE l_sub_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

End calculate_asset_subsidy;
--------------------------------------------------------------------------------
--Name         : get_contract_subsidy_amount
--Description  : API to fetch subsidy amount for the contract
-- PARAMETERS  : IN - p_chr_id   : Contract id
--               OUT - x_subsidy_amount:subsidy amount
--------------------------------------------------------------------------------
PROCEDURE get_contract_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_accounting_method            IN  VARCHAR2,
    x_subsidy_amount               OUT NOCOPY NUMBER) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'GET_CONTRACT_SUBSIDY';
    l_api_version          CONSTANT     NUMBER := 1.0;

    l_subsidy_amount            number;
    l_chr_subsidy_amount        number;

    --cursor to get all the financial assets in the contract
    cursor l_asst_csr(p_chr_id in number) is
    select cleb.id
    from   okc_k_lines_b      cleb,
           okc_line_styles_b  lseb,
           okc_statuses_b     stsb
    where  cleb.chr_id      = p_chr_id
    and    cleb.dnz_chr_id  = p_chr_id
    and    cleb.lse_id      = lseb.id
    and    lseb.lty_code    = 'FREE_FORM1'
    and    cleb.sts_code    = stsb.code
    and    stsb.ste_code    not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');

    l_asset_cle_id    number;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -------------------------------------
    --start of input parameter validations
    -------------------------------------
    --1.validate p_chr_id
    If (p_chr_id is NULL) or (p_chr_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_chr_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_chr_id is not NULL) and (p_chr_id <> OKL_API.G_MISS_NUM) then
        validate_chr_id(p_chr_id        => p_chr_id,
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_chr_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    --2.validate accounting method
    If (p_accounting_method is NOT NULL) then
        validate_acct_method(p_accounting_method => p_accounting_method,
                             x_return_status     => x_return_status);
       IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_accounting_method');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    ------------------------------------
    --end of input parameter validations
    -------------------------------------

    l_chr_subsidy_amount := 0;
    Open l_asst_csr(p_chr_id => p_chr_id);
    Loop
        Fetch l_asst_csr into l_asset_cle_id;
        Exit when l_asst_csr%NOTFOUND;
        get_asset_subsidy_amount(
            p_api_version       => p_api_version,
            p_init_msg_list     => p_init_msg_list,
            x_return_status     => x_return_status,
            x_msg_count         => x_msg_count,
            x_msg_data          => x_msg_data,
            p_asset_cle_id      => l_asset_cle_id,
            p_accounting_method => p_accounting_method,
            x_subsidy_amount    => l_subsidy_amount);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_chr_subsidy_Amount := l_chr_subsidy_Amount + l_subsidy_amount;
    End Loop;
    Close l_asst_csr;

    x_subsidy_amount := l_chr_subsidy_amount;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_asst_csr%ISOPEN then
        CLOSE l_asst_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
end get_contract_subsidy_amount;
--------------------------------------------------------------------------------
--Name         : get_contract_subsidy_amount
--Description  : API to fetch subsidy amount for the contract
-- PARAMETERS  : IN - p_chr_id    : Contract id
--               OUT - x_asbv_tbl : subsidy amount with additional vendor details
--------------------------------------------------------------------------------
PROCEDURE get_contract_subsidy_amount(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    x_asbv_tbl                     OUT NOCOPY asbv_tbl_type) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'GET_CONTRACT_SUBSIDY';
    l_api_version          CONSTANT     NUMBER := 1.0;

    l_asset_asbv_tbl             asbv_tbl_type;
    l_chr_asbv_tbl               asbv_tbl_type;
    i                            number;
    j                            number;

    --cursor to get all the financial assets in the contract
    cursor l_asst_csr(p_chr_id in number) is
    select cleb.id
    from   okc_k_lines_b      cleb,
           okc_line_styles_b  lseb,
           okc_statuses_b     stsb
    where  cleb.chr_id      = p_chr_id
    and    cleb.dnz_chr_id  = p_chr_id
    and    cleb.lse_id      = lseb.id
    and    lseb.lty_code    = 'FREE_FORM1'
    and    cleb.sts_code    = stsb.code
    and    stsb.ste_code    not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');

    l_asset_cle_id    number;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -----------------------------------------
    --start of input parameter validations
    ----------------------------------------
    --1.validate p_chr_id
    If (p_chr_id is NULL) or (p_chr_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_chr_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_chr_id is not NULL) and (p_chr_id <> OKL_API.G_MISS_NUM) then
        validate_chr_id(p_chr_id        => p_chr_id,
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_chr_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    ------------------------------------
    --end of input parameter validations
    ------------------------------------

    j := 0;
    i := 0;
    Open l_asst_csr(p_chr_id => p_chr_id);
    Loop
        Fetch l_asst_csr into l_asset_cle_id;
        Exit when l_asst_csr%NOTFOUND;
        get_asset_subsidy_amount(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_asset_cle_id     => l_asset_cle_id,
            x_asbv_tbl         => l_asset_asbv_tbl);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF l_asset_asbv_tbl.COUNT > 0 then
            For i in l_asset_asbv_tbl.FIRST..l_asset_asbv_tbl.LAST
            Loop
                j := j + 1;
                l_chr_asbv_tbl(j) :=  l_asset_asbv_tbl(i);
            End Loop;
            l_asset_asbv_tbl.delete;
        End If;

    End Loop;
    Close l_asst_csr;

    x_asbv_tbl := l_chr_asbv_tbl;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_asst_csr%ISOPEN then
        CLOSE l_asst_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
end get_contract_subsidy_amount;
--------------------------------------------------------------------------------
--Name         : calculate_contract_subsidy
--Description  : API to fetch subsidy amount for the contract
-- PARAMETERS  : IN - p_chr_id   : Contract id
--               OUT - x_subsidy_amount:subsidy amount
--------------------------------------------------------------------------------
PROCEDURE calculate_contract_subsidy(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    x_subsidy_amount               OUT NOCOPY NUMBER) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'CALC_CONTRACT_SUBSIDY';
    l_api_version          CONSTANT     NUMBER := 1.0;

    l_subsidy_amount            number;
    l_chr_subsidy_amount        number;

    --cursor to get all the financial assets in the contract
    cursor l_asst_csr(p_chr_id in number) is
    select cleb.id
    from   okc_k_lines_b      cleb,
           okc_line_styles_b  lseb,
           okc_statuses_b     stsb
    where  cleb.chr_id      = p_chr_id
    and    cleb.dnz_chr_id  = p_chr_id
    and    cleb.lse_id      = lseb.id
    and    lseb.lty_code    = 'FREE_FORM1'
    and    cleb.sts_code    = stsb.code
    and    stsb.ste_code    not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');

    l_asset_cle_id    number;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -----------------------------------------
    --start of input parameter validations
    ----------------------------------------
    --1.validate p_chr_id
    If (p_chr_id is NULL) or (p_chr_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_chr_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_chr_id is not NULL) and (p_chr_id <> OKL_API.G_MISS_NUM) then
        validate_chr_id(p_chr_id        => p_chr_id,
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_chr_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    ------------------------------------
    --end of input parameter validations
    ------------------------------------

    l_chr_subsidy_amount := 0;
    Open l_asst_csr(p_chr_id => p_chr_id);
    Loop
        Fetch l_asst_csr into l_asset_cle_id;
        Exit when l_asst_csr%NOTFOUND;
        calculate_asset_subsidy(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_asset_cle_id     => l_asset_cle_id,
            x_subsidy_amount   => l_subsidy_amount);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_chr_subsidy_Amount := l_chr_subsidy_Amount + l_subsidy_amount;
    End Loop;
    Close l_asst_csr;

    x_subsidy_amount := l_chr_subsidy_amount;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_asst_csr%ISOPEN then
        CLOSE l_asst_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
end calculate_contract_subsidy;
--------------------------------------------------------------------------------
--Name         : get_funding_subsidy_amount
--Description  : API to fetch subsidy amount for funding request
-- PARAMETERS  : IN - p_chr_id        : Contract id
--                    p_asset_cle_id  : Financial asset line id
--               OUT -x_subsidy_amount : subsidy amount
--special logic : If vendor id is passed , subsidy is calculated for that vendor
--                If vendor id is null(defualt) subsidy is calculated only for assets
--                which have vendor attached. Subsidy vendorr and asset vendor must
--                be same.
--------------------------------------------------------------------------------
PROCEDURE get_funding_subsidy_amount(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_asset_cle_id                 IN  NUMBER,
    p_vendor_id                    IN  NUMBER DEFAULT NULL,
    x_subsidy_amount               OUT NOCOPY NUMBER) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'GET_FUND_SUBSIDY';
    l_api_version          CONSTANT     NUMBER := 1.0;

    l_subsidy_amount        number;
    l_asset_subsidy_amount  number;

    --cursor to fetch vendor subssidies
    cursor l_vend_sub_csr (p_asset_cle_id  in number,
                           p_chr_id        in number,
                           p_vendor_id     in number) is
    select sub_cle.id
    from
           okl_k_lines          sub_kle,
           okc_k_lines_b        sub_cle,
           okc_line_styles_b    sub_lse,
           okl_subsidies_b      subb,
           okc_k_party_roles_b  sub_vend,
           okc_k_party_roles_b  asst_vend,
           okc_k_lines_b        model_cle,
           okc_line_styles_b    model_lse,
           okc_k_lines_b        asst_cle,
           okc_statuses_b       asst_sts
    --subsidy vendor
    where  sub_vend.dnz_chr_id         = sub_cle.dnz_chr_id
    and    sub_vend.object1_id1        = nvl(to_char(p_vendor_id),sub_vend.object1_id1)
    and    sub_vend.object1_id1        = asst_vend.object1_id1 --to make sure asset and subsidy vendors are same
    and    sub_vend.object1_id2        = '#'
    and    sub_vend.jtot_object1_code  = 'OKX_VENDOR'
    and    sub_vend.rle_code           = 'OKL_VENDOR'
    and    sub_vend.cle_id             = sub_cle.id
    --subsidy receipt method is 'FUND' and subsidy accounting method is 'NET' (discount)
    and    subb.id                     = sub_kle.subsidy_id
    and    subb.receipt_method_code    = 'FUND'
    and    subb.accounting_method_code = 'NET'
    and    sub_kle.id                  = sub_cle.id
    --subsidy line
    and    sub_cle.cle_id              = asst_cle.id
    and    sub_cle.dnz_chr_id          = asst_cle.dnz_chr_id
    and    sub_cle.sts_code            <> 'ABANDONED'
    and    sub_lse.id                  = sub_cle.lse_id
    and    sub_lse.lty_code            = 'SUBSIDY'
    --model line vendor
    and    asst_vend.dnz_chr_id        = model_cle.dnz_chr_id
    and    asst_vend.object1_id1       = nvl(to_char(p_vendor_id),asst_vend.object1_id1)
    and    asst_vend.object1_id2       = '#'
    and    asst_vend.jtot_object1_code = 'OKX_VENDOR'
    and    asst_vend.rle_code          = 'OKL_VENDOR'
    and    asst_vend.cle_id            = model_cle.id
    --model line
    and    model_cle.cle_id              = asst_cle.id
    and    model_cle.dnz_chr_id          = asst_cle.dnz_chr_id
    and    model_lse.id                  = model_cle.lse_id
    and    model_lse.lty_code            = 'ITEM'
    --financial asset
    and    asst_sts.code               = asst_cle.sts_code
    and    asst_sts.ste_code           not in ('HOLD','EXPIRED','CANCELLED')
    and    asst_cle.dnz_chr_id         = p_chr_id
    and    asst_cle.chr_id             = p_chr_id
    and    asst_cle.id                 = p_asset_cle_id;

	  --veramach bug 5600694 start
 	  cursor is_subsidy( p_chr_id  in number, p_asset_cle_id in number) is
 	  select 'Y' from dual where exists
 	  (
 	   select null   from OKC_LINE_STYLES_B SUB_LSE,
 	   OKC_K_LINES_B SUB_CLE
 	   where SUB_CLE.dnz_chr_id=p_chr_id
 	   and  SUB_LSE.LTY_CODE = 'SUBSIDY'
 	   and SUB_CLE.lse_id= SUB_LSE.id
 	   and  SUB_CLE.CLE_ID =p_asset_cle_id
 	  );
 	  l_has_subsidy varchar2(1) := 'N';
 	  --veramach bug 5600694 end

    l_subsidy_cle_id number;
begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -----------------------------------------
    --start of input parameter validations
    -----------------------------------------
    --1.validate p_chr_id
    If (p_chr_id is NULL) or (p_chr_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_chr_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_chr_id is not NULL) and (p_chr_id <> OKL_API.G_MISS_NUM) then
        validate_chr_id(p_chr_id        => p_chr_id,
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_chr_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    --2. validate p_asset_cle_id
    If (p_asset_cle_id is NULL) or (p_asset_cle_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_asset_cle_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_asset_cle_id is not NULL) and (p_asset_cle_id <> OKL_API.G_MISS_NUM) then
        validate_cle_id(p_cle_id        => p_asset_cle_id,
                        p_lty_code      => 'FREE_FORM1',
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_asset_cle_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    --3.validate vendor id
    if (p_vendor_id is not NULL) then
        validate_vendor_id(p_vendor_id        => p_vendor_id,
                           x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_vendor_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    -------------------------------------
    --end of input parameter validations
    -------------------------------------

    l_asset_subsidy_amount := 0;

	  --veramach bug 5600694 start
 	  open is_subsidy(p_chr_id => p_chr_id, p_asset_cle_id => p_asset_cle_id);
 	  fetch is_subsidy into l_has_subsidy;
 	  close is_subsidy;
 	  if(l_has_subsidy = 'Y') then
 	  --veramach bug 5600694 end

    Open l_vend_sub_csr(p_chr_id       => p_chr_id,
                        p_asset_cle_id => p_asset_cle_id,
                        p_vendor_id    => p_vendor_id);
    Loop
        Fetch l_vend_sub_csr into l_subsidy_cle_id;
        Exit when l_vend_sub_csr%NOTFOUND;
        get_subsidy_amount(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_subsidy_cle_id   => l_subsidy_cle_id,
            x_subsidy_amount   => l_subsidy_amount);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_asset_subsidy_Amount := l_asset_subsidy_Amount + l_subsidy_amount;
    End Loop;
    Close l_vend_sub_csr;
	  --veramach bug 5600694 start
 	  end if;
 	  --veramach bug 5600694 end
    x_subsidy_amount := l_asset_subsidy_amount;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_vend_sub_csr%ISOPEN then
        CLOSE l_vend_sub_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
end get_funding_subsidy_amount;
--------------------------------------------------------------------------------
--Name         : get_partial_subsidy_amount
--Description  : API to fetch subsidy amount for partial funding request
-- PARAMETERS  : IN - p_asset_cle_id  : Financial asset line id
--               OUT -x_asbv_tbl     : table of subsidy fund details
--special logic : Subsidy vendor and asset vendor must
--                be same.
--------------------------------------------------------------------------------
PROCEDURE get_partial_subsidy_amount(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_asset_cle_id                 IN  NUMBER,
    p_req_fund_amount              IN  NUMBER,
    x_asbv_tbl                     OUT NOCOPY asbv_tbl_type) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'GET_PARTIAL_SUBSIDY';
    l_api_version          CONSTANT     NUMBER := 1.0;

    l_asbv_tbl             asbv_tbl_type;
    l_asset_oec            Number;

    --cursor to fetch vendor subssidies
    cursor l_vend_sub_csr (p_asset_cle_id  in number) is
    select sub_cle.id,
           sub_cle.dnz_chr_id
    from   okl_k_lines          sub_kle,
           okc_k_lines_b        sub_cle,
           okc_line_styles_b    sub_lse,
           okl_subsidies_b      subb,
           okc_k_party_roles_b  sub_vend,
           okc_k_party_roles_b  asst_vend,
           okc_k_lines_b        model_cle,
           okc_line_styles_b    model_lse,
           okc_k_lines_b        asst_cle,
           okc_statuses_b       asst_sts
    --subsidy vendor
    where  sub_vend.dnz_chr_id         = sub_cle.dnz_chr_id
    --and    sub_vend.object1_id1        = to_char(nvl(p_vendor_id,sub_vend.object1_id1))
    and    sub_vend.object1_id1        = asst_vend.object1_id1 --to make sure asset and subsidy vendors are same
    and    sub_vend.object1_id2        = '#'
    and    sub_vend.jtot_object1_code  = 'OKX_VENDOR'
    and    sub_vend.rle_code           = 'OKL_VENDOR'
    and    sub_vend.cle_id             = sub_cle.id
    --subsidy receipt method is 'FUND' and accounting method is 'NET'
    and    subb.id                     = sub_kle.subsidy_id
    and    subb.receipt_method_code    = 'FUND'
    and    subb.accounting_method_code IN ('NET', 'AMORTIZE') --Added 'AMORTIZE' for bug 7664571
    and    sub_kle.id                  = sub_cle.id
    --subsidy line
    and    sub_cle.cle_id              = asst_cle.id
    and    sub_cle.dnz_chr_id          = asst_cle.dnz_chr_id
    and    sub_cle.sts_code            <> 'ABANDONED'
    and    sub_lse.id                  = sub_cle.lse_id
    and    sub_lse.lty_code            = 'SUBSIDY'
    --model line vendor
    and    asst_vend.dnz_chr_id        = model_cle.dnz_chr_id
    --and    asst_vend.object1_id1       = nvl(to_char(p_vendor_id),asst_vend.object1_id1)
    and    asst_vend.object1_id2       = '#'
    and    asst_vend.jtot_object1_code = 'OKX_VENDOR'
    and    asst_vend.rle_code          = 'OKL_VENDOR'
    and    asst_vend.cle_id            = model_cle.id
    --model line
    and    model_cle.cle_id              = asst_cle.id
    and    model_cle.dnz_chr_id          = asst_cle.dnz_chr_id
    and    model_lse.id                  = model_cle.lse_id
    and    model_lse.lty_code            = 'ITEM'
    --financial asset
    and    asst_sts.code               = asst_cle.sts_code
    and    asst_sts.ste_code           not in ('HOLD','EXPIRED','CANCELLED')
    and    asst_cle.dnz_chr_id         = asst_cle.chr_id
    and    asst_cle.id                 = p_asset_cle_id;

    l_subsidy_cle_id number;
    l_chr_id         number;

    i                number;

begin
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    ---------------------------------------------
    --validate input parameters
    ---------------------------------------------
    --1.validate p_asset_id
    If (p_asset_cle_id is NULL) or (p_asset_cle_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_asset_cle_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_asset_cle_id is not NULL) and (p_asset_cle_id <> OKL_API.G_MISS_NUM) then
        validate_cle_id(p_cle_id        => p_asset_cle_id,
                        p_lty_code      => 'FREE_FORM1',
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_asset_cle_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    ------------------------------------------
    --end of input parameter validations
    ------------------------------------------

    i := 0;
    Open l_vend_sub_csr(p_asset_cle_id => p_asset_cle_id);
    Loop
        Fetch l_vend_sub_csr into l_subsidy_cle_id, l_chr_id;
        Exit when l_vend_sub_csr%NOTFOUND;
        i := i + 1;
        If i = 1 then --get oec only first time
            --get asset OEC

            /*---commented formula as it has commit and this
            --needs to be called in a sql bu funding API
            --called seeded function directly instead of formula

            --OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
            --                                p_init_msg_list => p_init_msg_list,
            --                                x_return_status => x_return_status,
            --                                x_msg_count     => x_msg_count,
            --                                x_msg_data      => x_msg_data,
            --                                p_formula_name  => G_FORMULA_OEC,
            --                                p_contract_id   => l_chr_id,
            --                                p_line_id       => p_asset_cle_id,
            --                                x_value         => l_asset_oec);

            --IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            --    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            --ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            --    RAISE OKL_API.G_EXCEPTION_ERROR;
            --END IF;
            -----------*/
            -------------------------------------------
            --call seeded functions API :
            -------------------------------------------
            -- l_asset_oec := OKL_SEEDED_FUNCTIONS_PVT.line_oec(p_dnz_chr_id => l_chr_id, p_cle_id     => p_asset_cle_id);
            -- Bug#8244551 - Get fundable portion of OEC which accounts
            -- for tradeins  and downpaymments
            l_asset_oec := OKL_FUNDING_PVT.get_contract_line_amt(l_chr_id,p_asset_cle_id);

        End If;

        get_subsidy_amount(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_subsidy_cle_id   => l_subsidy_cle_id,
            x_asbv_rec         => l_asbv_tbl(i));

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --calculate proportional subsidy amount
        l_asbv_tbl(i).amount := (l_asbv_tbl(i).amount/l_asset_oec)* p_req_fund_amount;
    End Loop;
    Close l_vend_sub_csr;

    x_asbv_tbl := l_asbv_tbl;

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_vend_sub_csr%ISOPEN then
        CLOSE l_vend_sub_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
end get_partial_subsidy_amount;



-- Start of comments
--
-- Procedure Name	: Get_Vendor_Billing_Info
-- Description		: Local Procedure to Extract Vendor Billing Information for
--                    creating billing transaction
-- Business Rules	:
-- Parameters		: Contract Party Id or Contract Id
-- History          :
-- Version		: 1.0
-- End of comments

PROCEDURE Get_Vendor_Billing_Info (
    p_contract_id           IN         NUMBER,
    p_cpl_id                IN         NUMBER,
    x_return_status	    OUT NOCOPY VARCHAR2,
    x_bill_to_site_use_id   OUT NOCOPY Number,
    x_cust_acct_id          OUT NOCOPY Number,
    x_payment_method_id     OUT NOCOPY Number,
    x_bank_account_id       OUT NOCOPY Number,
    x_inv_reason_for_review OUT NOCOPY Varchar2,
    x_inv_review_until_date OUT NOCOPY Date,
    x_cash_appl_rule_id     OUT NOCOPY Number,
    x_invoice_format        OUT NOCOPY Varchar2,
    x_review_invoice_yn     OUT NOCOPY Varchar2,
    x_cust_acct_site_id     OUT NOCOPY Number,
    x_payment_term_id       OUT NOCOPY Number) As

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;

	l_contract_id		NUMBER		:= p_contract_id;
    l_cpl_id            NUMBER      := p_cpl_id;
	l_khr_id		    NUMBER;
	l_par_id		    NUMBER;
	l_rgd_id		    NUMBER;
	l_party_name		VARCHAR2(1000);

    l_bill_to_site_use_id OKC_K_HEADERS_B.bill_to_site_use_id%TYPE;
    l_cust_acct_id        OKC_K_PARTY_ROLES_B.cust_acct_id%TYPE;
    l_party_role          FND_LOOKUPS.meaning%TYPE;

    ----------------------------------------------------------------------------
    -- Get bill to site of OKL_VENDOR party on the contract
    ----------------------------------------------------------------------------
	CURSOR	l_k_party_rg_csr (cp_cpl_id IN NUMBER) IS
	SELECT	cpl.id			        cpl_id,
			cpl.jtot_object1_code	object1_code,
			cpl.object1_id1		    object1_id1,
			cpl.object1_id2		    object1_id2,
			rgd.id			        rgd_id,
            cpl.bill_to_site_use_id bill_to_site_use_id,
            cpl.role                party_role,
            cpl.cust_acct_id        cust_acct_id
	FROM	okc_k_party_roles_v	    cpl,
			okc_rg_party_roles	    rgpr,
			okc_rule_groups_v	    rgd
	WHERE	cpl.id			= cp_cpl_id
	AND	    cpl.rle_code    = 'OKL_VENDOR'
	AND	    rgpr.cpl_id	(+)	= cpl.id
	AND	    rgd.id		(+)	= rgpr.rgp_id
	AND	    rgd.rgd_code(+)	= 'LAVENB';

    ----------------------------------------------------------------------------
    -- Get bill to site of vendor PROGRAM if Vendor Program vendor same as lease vendor
    ----------------------------------------------------------------------------
-- modified by zrehman to fix Bug#6341517 on 27-Feb-2008 start
	CURSOR	l_partner_rg_csr (cp_khr_id    IN NUMBER,
                              cp_vendor_id IN VARCHAR2) IS
        SELECT khr.Id khr_Id,
               Par.Id Par_Id,
               rgd.Id rgd_Id,
               cPl.Bill_To_Site_Use_Id Bill_To_Site_Use_Id,
             --  cPl.ROLE ParACty_Role,
               cPl.cUst_acct_Id cUst_acct_Id
        FROM   Okl_k_Headers khr,
               Okc_k_Headers_b Par,
               Okc_Rule_Groups_v rgd,
               Okc_k_Party_Roles_b cPl
        WHERE  khr.Id = cp_khr_Id
        AND Par.Id   = khr.khr_Id
        AND Par.scs_Code   = 'PROGRAM'
        AND rgd.chr_Id   = Par.Id
        AND rgd.dnz_chr_Id   = Par.Id
        AND rgd.cle_Id IS NULL
        AND rgd.rgd_Code   = 'LAVENB'
        AND Par.Id = cPl.chr_Id
        AND cPl.rle_Code = 'OKL_VENDOR'
        AND cPl.Object1_Id1 = cp_Vendor_Id
        AND cPl.Object1_Id2 = '#'
        AND cPl.jTot_Object1_Code = 'OKX_VENDOR';
-- modified by zrehman to fix Bug#6341517 on 27-Feb-2008 end

    -------------------------------------------------------
    --cursor to fetch receipt method id
    -------------------------------------------------------
	CURSOR	l_rcpt_mthd_csr (cp_cust_rct_mthd IN NUMBER) IS
	SELECT	c.receipt_method_id
	FROM	ra_cust_receipt_methods  c
	WHERE	c.cust_receipt_method_id = cp_cust_rct_mthd;


    ---------------------------------------------------------
    --cursor to fetch site use information
    ----------------------------------------------------------
	CURSOR	l_site_use_csr (cp_site_use_id		IN NUMBER,
			                cp_site_use_code	IN VARCHAR2) IS
	SELECT	a.cust_account_id	cust_account_id,
			a.cust_acct_site_id	cust_acct_site_id,
			a.payment_term_id	payment_term_id
	FROM    okx_cust_site_uses_v	a,
			okx_customer_accounts_v	c
	WHERE	a.id1			= cp_site_use_id
	AND	    a.site_use_code	= cp_site_use_code
	AND	    c.id1			= a.cust_account_id;

    ----------------------------------------------------------------------------
    --get payment term from customer profiles
    ----------------------------------------------------------------------------
	CURSOR	l_std_terms_csr (cp_cust_id		IN NUMBER,
			                 cp_site_use_id		IN NUMBER) IS
	SELECT	c.standard_terms	standard_terms
	FROM	hz_customer_profiles	c
	WHERE	c.cust_account_id	= cp_cust_id
	AND	    c.site_use_id		= cp_site_use_id
	UNION
	SELECT	c1.standard_terms	standard_terms
	FROM	hz_customer_profiles	c1
	WHERE	c1.cust_account_id	= cp_cust_id
	AND	c1.site_use_id		IS NULL
	AND	NOT EXISTS (
			SELECT	'1'
			FROM	hz_customer_profiles	c2
			WHERE	c2.cust_account_id	= cp_cust_id
			AND	c2.site_use_id		= cp_site_use_id);

	l_site_use_rec	 l_site_use_csr%ROWTYPE;
	l_k_party_rg_rec l_k_party_rg_csr%ROWTYPE;

    ----------------------------------------------------------------------------
    --cursors to fetch rule values
    ----------------------------------------------------------------------------
    cursor l_rul_csr (p_rul_code in varchar2,
                      p_rgp_id   in number,
                      p_chr_id   in number) is
    select rule_information1,
           rule_information2,
           rule_information3,
           rule_information4,
           rule_information5,
           rule_information6,
           jtot_object1_code,
           object1_id1,
           object1_id2
     from  okc_rules_b
     where rgp_id = p_rgp_id
     and   rule_information_category = p_rul_code
     and   dnz_chr_id = p_chr_id;

--START: rseela 11/28/05 bug#4673593
    ----------------------------------------------------------------------------
    --cursors to fetch bank account ID
    ----------------------------------------------------------------------------
    cursor l_bank_acc_csr (p_bank_acc_uses_id in varchar2) is
    select rmc.bank_account_id
     from  OKX_RCPT_METHOD_ACCOUNTS_V rmc
     where rmc.id1 = p_bank_acc_uses_id;

--END: rseela 11/28/05 bug#4673593

    --sechawla 26-may-09 6826580
    CURSOR l_invoice_format_csr(p_invoice_format_id IN NUMBER) IS
    SELECT name
    FROM   okl_invoice_formats_v
    WHERE  ID = p_invoice_format_id;
    l_inv_frmt   VARCHAR2(150);

     l_pmth_rec l_rul_csr%ROWTYPE;
     l_bacc_rec l_rul_csr%ROWTYPE;
     l_inpr_rec l_rul_csr%ROWTYPE;
     l_invd_rec l_rul_csr%ROWTYPE;

    l_payment_method_id     Number;
    l_bank_account_id       Number;
    l_inv_reason_for_review Varchar2(450);
    l_inv_review_until_date Date;
    l_cash_appl_rule_id     Number;
    l_invoice_format        Varchar2(450);
    l_review_invoice_yn     Varchar2(450);

    l_cust_acct_site_id     Number;
    l_payment_term_id       Number;

BEGIN
	-- *******************
	-- Validate parameters
	-- *******************
	IF (l_cpl_id	IS NULL
	     OR	l_cpl_id	= OKL_API.G_MISS_NUM)
	AND (l_contract_id	IS NULL
	     OR	l_contract_id	= OKL_API.G_MISS_NUM) THEN

		l_return_status	:= OKL_API.G_RET_STS_ERROR;
		OKL_API.SET_MESSAGE (
		    p_app_name	    => G_APP_NAME,
			p_msg_name	    => G_INCOMPLETE_VEND_BILL,
			p_token1	    => G_ERROR_TYPE_TOKEN,
			p_token1_value	=> 'Program Error : ',
			p_token2	    => G_PARAMETER_TOKEN,
			p_token2_value	=> 'Contract Party Identifier and Contract identifier'
           );

	END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- ***************
	-- Find Rule Group
	-- ***************

	IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

	    IF  l_cpl_id IS NOT NULL
	        AND l_cpl_id <> OKL_API.G_MISS_NUM THEN

		    OPEN	l_k_party_rg_csr (l_cpl_id);
		    FETCH	l_k_party_rg_csr INTO l_k_party_rg_rec;
		    CLOSE	l_k_party_rg_csr;
		    l_rgd_id := l_k_party_rg_rec.rgd_id;

            l_bill_to_site_use_id := l_k_party_rg_rec.bill_to_site_use_id ;
            l_cust_acct_id        := l_k_party_rg_rec.cust_acct_id;

		    IF l_k_party_rg_rec.cpl_id IS NULL THEN
			    l_return_status	:= OKL_API.G_RET_STS_ERROR;
			    OKL_API.SET_MESSAGE (
				    p_app_name	    => G_APP_NAME,
				    p_msg_name	    => G_INCOMPLETE_VEND_BILL,
			        p_token1	    => G_ERROR_TYPE_TOKEN,
			        p_token1_value	=> 'Program Error : ',
				    p_token2	    => G_PARAMETER_TOKEN,
				    p_token2_value	=> 'Contract Party Identifier'
                    );
            ELSIF    l_k_party_rg_rec.bill_to_site_use_id IS NULL    THEN
                ----------------------------------------------------------------
                --Try to fetch billing details from vendor program if lease
                --and vp verndor are the same
                ----------------------------------------------------------------
                If l_contract_id is not null
                    and l_contract_id <> OKL_API.G_MISS_NUM
                Then
                    --Open vendor program cursor
		            OPEN	l_partner_rg_csr (l_contract_id, l_k_party_rg_rec.object1_id1);
		            FETCH	l_partner_rg_csr INTO l_khr_id,
                                                  l_par_id,
                                                  l_rgd_id,
                                                  l_bill_to_site_use_id,
                                                 -- l_party_role, -- modified by zrehman to fix Bug#6341517 on 27-Feb-2008
                                                  l_cust_acct_id;
		            CLOSE	l_partner_rg_csr;

                 ------------------------------------------------------------
                 --not to raise this ambiguous error when VP does not exist
                    --If (l_khr_id is null) OR (l_par_id is null) then
                     --   l_return_status := OKL_API.G_RET_STS_ERROR;
    		--	        OKL_API.SET_MESSAGE (
		--		        p_app_name	    => G_APP_NAME,
		--		        p_msg_name	    => G_INCOMPLETE_VEND_BILL,
		--	            p_token1	    => G_ERROR_TYPE_TOKEN,
		--	            p_token1_value	=> 'Program Error : ',
		--		        p_token2	    => G_PARAMETER_TOKEN,
		--		        p_token2_value	=> 'Contract Header Identifier'
                 --       );
                  --  Els
                 --not to raise this ambiguous error when VP does not exist
                 -------------------------------------------------------------
                    If l_bill_to_site_use_id is null then

			            l_return_status	:= OKL_API.G_RET_STS_ERROR;
  			            OKL_API.SET_MESSAGE (
				              p_app_name	=> G_APP_NAME,
				              p_msg_name	=> G_INCOMPLETE_VEND_BILL,
			                      p_token1	        => G_ERROR_TYPE_TOKEN,
			                      p_token1_value	=> 'Billing setup not defined.',
				              p_token2	        => G_PARAMETER_TOKEN,
				              p_token2_value	=> 'Bill to Site'
                            );
                    End If;
                   ---------------------------------------------------------------
                    --End of trying to fetch billing details from VP
                   ---------------------------------------------------------------
                 Else
                        l_return_status	:= OKL_API.G_RET_STS_ERROR;
  			            OKL_API.SET_MESSAGE (
				              p_app_name	    => G_APP_NAME,
				              p_msg_name	    => G_INCOMPLETE_VEND_BILL,
			                  p_token1	        => G_ERROR_TYPE_TOKEN,
			                  p_token1_value	=> '',
				              p_token2	        => G_PARAMETER_TOKEN,
				              p_token2_value	=> 'Bill to Site'
                            );

                 End If;
		     END IF;
	    ELSE
            --exception cpl_id passed is null
            l_return_status := OKL_API.G_RET_STS_ERROR;
    		OKL_API.SET_MESSAGE (
				        p_app_name	    => G_APP_NAME,
				        p_msg_name	    => G_INCOMPLETE_VEND_BILL,
			            p_token1	    => G_ERROR_TYPE_TOKEN,
			            p_token1_value	=> 'Program Error : ',
				        p_token2	    => G_PARAMETER_TOKEN,
				        p_token2_value	=> 'Contract Party Identifier'
                        );

        END IF;
	END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;


	IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

        --------------------------------------------
        --1. Get payment method
        --------------------------------------------
        open l_rul_csr (p_rul_code => 'LAPMTH',
                        p_rgp_id   => l_rgd_id,
                        p_chr_id   => l_contract_id);
        Fetch l_rul_csr into l_pmth_rec;
        If l_rul_csr%NOTFOUND then
            l_payment_method_id := null;
        Else
            IF l_pmth_rec.object1_id2 <> '#' THEN
		       l_payment_method_id    := l_pmth_rec.object1_id2;
		    ELSE
			    -- This cursor needs to be removed when
			    -- the view changes to include id2
			    OPEN	l_rcpt_mthd_csr (l_pmth_rec.object1_id1);
			    FETCH	l_rcpt_mthd_csr INTO l_payment_method_id;
			    CLOSE	l_rcpt_mthd_csr;
		    END IF;
        End If;
        close l_rul_csr;

        --------------------------------------------
        --2. Get bank account
        --------------------------------------------
        open l_rul_csr (p_rul_code => 'LABACC',
                        p_rgp_id   => l_rgd_id,
                        p_chr_id   => l_contract_id);
        Fetch l_rul_csr into l_bacc_rec;
           If l_rul_csr%NOTFOUND then
             l_bank_account_id := null;
           Else
           --START: rseela 11/28/05 bug#4673593
             open l_bank_acc_csr(TO_NUMBER(l_bacc_rec.object1_id1));
             fetch l_bank_acc_csr into l_bank_account_id;
             close l_bank_acc_csr;
--           l_bank_account_id := l_bacc_rec.object1_id1;
           --END: rseela 11/28/05 bug#4673593

        End If;
        close l_rul_csr;


        --------------------------------------------
        --3. Get invoice pull for review
        --------------------------------------------
        open l_rul_csr (p_rul_code => 'LAINPR',
                        p_rgp_id   => l_rgd_id,
                        p_chr_id   => l_contract_id);
        Fetch l_rul_csr into l_inpr_rec;
        If l_rul_csr%NOTFOUND then
            l_inv_reason_for_review := null;
            l_inv_review_until_date := null;
        Else
            l_inv_reason_for_review := l_inpr_rec.rule_information1;
            l_inv_review_until_date := fnd_date.canonical_to_date(l_inpr_rec.rule_information2);
        End If;
        close l_rul_csr;

        --------------------------------------------
        --4. Get invoice details
        --------------------------------------------
        open l_rul_csr (p_rul_code => 'LAINVD',
                        p_rgp_id   => l_rgd_id,
                        p_chr_id   => l_contract_id);
        Fetch l_rul_csr into l_invd_rec;
        If l_rul_csr%NOTFOUND then
            l_cash_appl_rule_id := null;
            l_invoice_format    := null;
            l_review_invoice_yn := null;
        Else
            l_cash_appl_rule_id := l_invd_rec.object1_id1;

            --sechawla 26-may-09 6826580 : begin
            OPEN  l_invoice_format_csr(to_number(l_invd_rec.rule_information1));
            FETCH l_invoice_format_csr INTO l_inv_frmt;
            CLOSE l_invoice_format_csr;
            --sechawla 26-may-09 6826580 end

            l_invoice_format    := l_inv_frmt; --l_invd_rec.rule_information1; --sechawla 26-may-09 6826580

            l_review_invoice_yn := l_invd_rec.rule_information4;
        End If;
        close l_rul_csr;

	END IF;


	-- *****************************************************
	-- Extract Customer, Bill To and Payment Term from rules
	-- *****************************************************

	IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

		OPEN	l_site_use_csr (l_bill_to_site_use_id, 'BILL_TO');
		FETCH	l_site_use_csr INTO l_site_use_rec;
		CLOSE	l_site_use_csr;

        l_cust_acct_site_id     :=  l_site_use_rec.cust_acct_site_id;
        l_payment_term_id       :=  l_site_use_rec.payment_term_id;

		IF l_payment_term_id IS NULL
		OR l_payment_term_id = OKL_API.G_MISS_NUM THEN
			OPEN	l_std_terms_csr (
					l_site_use_rec.cust_account_id,
					l_bill_to_site_use_id);
			FETCH	l_std_terms_csr INTO l_payment_term_id;
			CLOSE	l_std_terms_csr;
		END IF;

	END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

	-- ****************
	-- Validate Results
	-- ****************

	IF l_overall_status = OKL_API.G_RET_STS_SUCCESS THEN

		--IF px_taiv_rec.ixx_id IS NULL
		--OR px_taiv_rec.ixx_id = G_MISS_NUM THEN
        IF l_cust_acct_id IS NULL
		    OR l_cust_acct_id = OKL_API.G_MISS_NUM THEN

			l_return_status	:= OKL_API.G_RET_STS_ERROR;
			OKL_API.SET_MESSAGE (
			    p_app_name	    => G_APP_NAME,
				p_msg_name	    => G_INCOMPLETE_VEND_BILL,
			    p_token1	    => G_ERROR_TYPE_TOKEN,
			    p_token1_value	=> '',
				p_token2	    => G_PARAMETER_TOKEN,
				p_token2_value	=> 'Customer Account'
             );

		END IF;

		--IF px_taiv_rec.ibt_id IS NULL
		--OR px_taiv_rec.ibt_id = G_MISS_NUM THEN
		IF l_cust_acct_site_id IS NULL
		OR l_cust_acct_site_id = OKL_API.G_MISS_NUM THEN
			l_return_status	:= OKL_API.G_RET_STS_ERROR;
			OKL_API.SET_MESSAGE (
			    p_app_name	    => G_APP_NAME,
				p_msg_name	    => G_INCOMPLETE_VEND_BILL,
			    p_token1	    => G_ERROR_TYPE_TOKEN,
			    p_token1_value	=> '',
				p_token2	    => G_PARAMETER_TOKEN,
				p_token2_value	=> 'Customer Account Site'
             );
		END IF;

		--IF px_taiv_rec.irt_id IS NULL
		--OR px_taiv_rec.irt_id = G_MISS_NUM THEN
		IF l_payment_term_id IS NULL
		OR l_payment_term_id = OKL_API.G_MISS_NUM THEN
			l_return_status	:= OKL_API.G_RET_STS_ERROR;
			OKL_API.SET_MESSAGE (
			    p_app_name	    => G_APP_NAME,
				p_msg_name	    => G_INCOMPLETE_VEND_BILL,
			    p_token1	    => G_ERROR_TYPE_TOKEN,
			    p_token1_value	=> '',
				p_token2	    => G_PARAMETER_TOKEN,
				p_token2_value	=> 'Payment Term'
             );
		END IF;

	END IF;

	IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
		IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
			l_overall_status := l_return_status;
		END IF;
	END IF;

    x_bill_to_site_use_id     := l_bill_to_site_use_id;
    x_cust_acct_id            := l_cust_acct_id;
    --
    x_payment_method_id       := l_payment_method_id;
    x_bank_account_id         := l_bank_account_id;
    x_inv_reason_for_review   := l_inv_reason_for_review;
    x_inv_review_until_date   := l_inv_review_until_date;
    x_cash_appl_rule_id       := l_cash_appl_rule_id;
    x_invoice_format          := l_invoice_format;
    x_review_invoice_yn       := l_review_invoice_yn;
    --
    x_cust_acct_site_id       := l_cust_acct_site_id;
    x_payment_term_id         := l_payment_term_id;

	x_return_status	:= l_overall_status;

EXCEPTION

	WHEN OTHERS THEN

		-- close open cursors
		IF l_k_party_rg_csr%ISOPEN THEN
			CLOSE l_k_party_rg_csr;
		END IF;

		IF l_partner_rg_csr%ISOPEN THEN
			CLOSE l_partner_rg_csr;
		END IF;

		IF l_rcpt_mthd_csr%ISOPEN THEN
			CLOSE l_rcpt_mthd_csr;
		END IF;

		IF l_site_use_csr%ISOPEN THEN
			CLOSE l_site_use_csr;
		END IF;

		IF l_std_terms_csr%ISOPEN THEN
			CLOSE l_std_terms_csr;
		END IF;

        IF l_rul_csr%ISOPEN THEN
			CLOSE l_rul_csr;
		END IF;

		-- store SQL error message on message stack for caller
		OKL_API.SET_MESSAGE (
			 p_app_name	=> G_APP_NAME
			,p_msg_name	=> G_UNEXPECTED_ERROR
			,p_token1	=> G_SQLCODE_TOKEN
			,p_token1_value	=> sqlcode
			,p_token2	=> G_SQLERRM_TOKEN
			,p_token2_value	=> sqlerrm);


		-- notify caller of an UNEXPECTED error
		x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END Get_Vendor_Billing_Info;

-- Start of comments
--
-- Function Name        : Get_Trx_Type_Id
-- Description          : Local function to fetch trx_type_id (try_id)
-- Business Rules       :
-- Parameters           :  p_trx_type - trx type name
--                         p_lang     - language
-- History          :
-- Version              : 1.0
-- End of comments

Function Get_trx_type_id (p_trx_type in varchar2,
                          p_lang     in varchar2) return number is


-- Cursor to get the try_id for the name passed
   CURSOR l_try_id_csr (
                                     cp_try_name        IN VARCHAR2,
                                     cp_language        IN VARCHAR2) IS
                SELECT  id
                FROM    okl_trx_types_tl t
                WHERE   Upper (t.name)  LIKE Upper (cp_try_name)
                AND     t.language  = Upper (cp_language);

   l_try_id  number default null;
begin
    l_try_id := Null;
    open l_try_id_csr (cp_try_name => p_trx_type,
                       cp_language => p_lang);
    Fetch l_try_id_csr into l_try_id;
    If l_try_id_csr%NOTFOUND then
        NULL;
    End If;
    close l_try_id_csr;
    return(l_try_id);
    Exception
    When others then
    If l_try_id_csr%ISOPEN then
       CLOSE l_try_id_csr;
    End If;
    OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                        ,p_msg_name     => G_UNEXPECTED_ERROR
                        ,p_token1       => G_SQLCODE_TOKEN
                        ,p_token1_value => SQLCODE
                        ,p_token2       => G_SQLERRM_TOKEN
                        ,p_token2_value => SQLERRM);
    Return(l_try_id);
end Get_trx_type_id;

-- varangan - Bug#5474059 - Added - Start
  -- Start of comments
  -- Procedure Name     : insert_billing_records
  -- Description        : Code in this API was intially part of the procedure
  --                      Create_Billing_Trx. Creates billing transaction
  --                      records for subsidies
  -- PARAMETERS  : IN - p_asdv_tbl : Table of records with subsidy details
  -- Created varangan
  -- End of comments
  PROCEDURE insert_billing_records
           (p_api_version    IN  NUMBER
          , p_init_msg_list  IN  VARCHAR2
          , x_return_status  OUT NOCOPY VARCHAR2
          , x_msg_count      OUT NOCOPY NUMBER
          , x_msg_data       OUT NOCOPY VARCHAR2
          , p_chr_id         IN  NUMBER
          , p_asdv_tbl       IN  asbv_tbl_type) IS
    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'insert_billing_records';
    l_api_version          CONSTANT     NUMBER := 1.0;

    l_asdv_tbl asbv_tbl_type DEFAULT p_asdv_tbl;
    l_asdv_tbl_proc asbv_tbl_type;
    i               number;
    j               number;

    --30-Oct-03 avsingh : cursor corrected for same vendor match at
    --model line level
    --cursor to verify theat asset and subsidy vendors are the same
    cursor l_samevend_csr(p_vendor_id    in number,
                          p_asset_cle_id in number,
                          p_chr_id       in number) is
    Select 'Y'
    From   okc_k_party_roles_b cplb,
           okc_k_lines_b       cleb,
           okc_line_styles_b   lseb
    where  cplb.cle_id            = cleb.id
    and    cleb.cle_id            = p_asset_cle_id
    and    lseb.id                = cleb.lse_id
    and    lseb.lty_code          = 'ITEM'
    and    cplb.dnz_chr_id        = p_chr_id
    and    cplb.object1_id1       = to_char(p_vendor_id)
    and    cplb.object1_id2       = '#'
    and    cplb.jtot_object1_code = 'OKX_VENDOR'
    and    cplb.rle_code          = 'OKL_VENDOR';

    l_exists varchar2(1) default'N';
-- varangan - Billing Enhancement changes- Bug#5874824 - begin

 /* l_taiv_rec     okl_trx_ar_invoices_pub.taiv_rec_type;
    l_tilv_rec     okl_txl_ar_inv_lns_pub.tilv_rec_type;
    l_bpd_acc_rec  okl_acc_call_pub.bpd_acc_rec_type;

    lx_taiv_rec     okl_trx_ar_invoices_pub.taiv_rec_type;
    lx_tilv_rec     okl_txl_ar_inv_lns_pub.tilv_rec_type;
    lx_bpd_acc_rec  okl_acc_call_pub.bpd_acc_rec_type;
    */

 -----------------------------------------------------------
 -- Variables for billing API call
 -----------------------------------------------------------
    lp_taiv_rec        okl_tai_pvt.taiv_rec_type;
    lp_tilv_rec	       okl_til_pvt.tilv_rec_type;
    lp_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lp_tldv_tbl        okl_tld_pvt.tldv_tbl_type;

    lx_taiv_rec        okl_tai_pvt.taiv_rec_type;
    lx_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lx_tldv_tbl        okl_tld_pvt.tldv_tbl_type;

--Varangan - Billing Enhancement changes - Bug#5874824  - End
    l_bill_to_site_use_id OKC_K_HEADERS_B.bill_to_site_use_id%TYPE;
    l_cust_acct_id        OKC_K_PARTY_ROLES_B.cust_acct_id%TYPE;
    l_payment_method_id     Number;
    l_bank_account_id       Number;
    l_inv_reason_for_review Varchar2(450);
    l_inv_review_until_date Date;
    l_cash_appl_rule_id     Number;
    l_invoice_format        Varchar2(450);
    l_review_invoice_yn     Varchar2(450);

    l_cust_acct_site_id     Number;
    l_payment_term_id       Number;

    --cursor to get vendor cpl_id at header level
    cursor l_chrcpl_csr (p_vendor_id in number,
                         p_chr_id    in number) is
    select cplb.id
    from   okc_k_party_roles_b cplb
    where  cplb.chr_id             = p_chr_id
    and    cplb.dnz_chr_id         = p_chr_id
    and    cplb.cle_id is null
    and    cplb.object1_id1        = to_char(p_vendor_id)
    and    cplb.object1_id2        = '#'
    and    cplb.jtot_object1_code  = 'OKX_VENDOR'
    and    cplb.rle_code           = 'OKL_VENDOR';

    l_chr_cpl_id number;
    l_try_id     number;
    l_chr_id     number DEFAULT p_chr_id;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_asdv_tbl.COUNT = 0 Then
        Null;
    Else
        -------------------------------------------------------------------------
        --find out subsidy records for which billing transaction is to be created
        -------------------------------------------------------------------------
        j := 1;
        FOR i in l_asdv_tbl.FIRST..l_asdv_tbl.LAST
        LOOP
	    --Removed OR condition for bug 7664571
            If (l_asdv_tbl(i).receipt_method_code = 'BILL') Then
                -- OR clause added as only discounts('NET') can be FUNDED
               l_asdv_tbl_proc(j) := l_asdv_tbl(i);
               j:= j+1;
            ElsIf (l_asdv_tbl(i).receipt_method_code = 'FUND') AND
                  (l_asdv_tbl(i).accounting_method_code IN('NET', 'AMORTIZE')) then
                --Added 'AMORTIZE' for bug 7664571
                -- AND clause added as only discounts ('NET') can be funded

                ------------------------------------------------------------
                --find out if asset vendor and subsidy vendor are the same
                --becuase only then net from funding can be done. If not same
                --then 'BILL' irrespective of receipt method
                ------------------------------------------------------------
                l_exists := 'N';
                Open l_samevend_csr(p_vendor_id    => l_asdv_tbl(i).vendor_id,
                                    p_asset_cle_id => l_asdv_tbl(i).asset_cle_id,
                                    p_chr_id       => l_chr_id);
                Fetch l_samevend_csr into l_exists;
                If l_samevend_csr%NOTFOUND then
                    null;
                End If;
                Close l_samevend_csr;

                If l_exists = 'N' Then
                    l_asdv_tbl_proc(j) := l_asdv_tbl(i);
                   j := j+1;
                End If;
            End If;
        End Loop;

        ------------------------------------------------------------------------
        --If there are records to process then create billing trx
        ------------------------------------------------------------------------
        If l_asdv_tbl_proc.COUNT > 0 Then
        For i in  l_asdv_tbl_proc.FIRST..l_asdv_tbl_proc.LAST Loop
	  -- Varangan - Billing Enhancement changes - Bug#5874824 - Begin
            lp_taiv_rec.khr_id         := l_asdv_tbl_proc(i).dnz_chr_id;
            lp_taiv_rec.description    := l_asdv_tbl_proc(i).description;
            lp_taiv_rec.currency_code  := l_asdv_tbl_proc(i).currency_code;
            lp_taiv_rec.date_invoiced  := l_asdv_tbl_proc(i).start_date; --check whether it is ok to give this
            lp_taiv_rec.amount         := l_asdv_tbl_proc(i).amount;

	    -- Varangan - Billing Enhancement changes - Bug#5874824 - End
            --l_taiv_rec.qte_id       := p_quote_id;

            /*l_taiv_rec.currency_conversion_type := l_qte_rec.currency_conversion_type;
                    l_taiv_rec.currency_conversion_rate := l_qte_rec.currency_conversion_rate;
                    l_taiv_rec.currency_conversion_date := l_qte_rec.currency_conversion_date;
            */
            --------------------------------------------------------------------
            --Get vendor billing information for the transaction
            --------------------------------------------------------------------
            --fetch contract header cpl_id
            open l_chrcpl_csr (p_vendor_id => l_asdv_tbl_proc(i).vendor_id,
                               p_chr_id    => l_chr_id);
            Fetch l_chrcpl_csr into l_chr_cpl_id;
            If l_chrcpl_csr%NOTFOUND then
                NULL;
            End If;
            Close l_chrcpl_csr;

            Get_Vendor_Billing_Info (
                p_contract_id           => l_chr_id,
                p_cpl_id                => l_chr_cpl_id,
                x_return_status         => x_return_status,
                x_bill_to_site_use_id   => l_bill_to_site_use_id,
                x_cust_acct_id          => l_cust_acct_id,
                x_payment_method_id     => l_payment_method_id,
                x_bank_account_id       => l_bank_account_id,
                x_inv_reason_for_review => l_inv_reason_for_review,
                x_inv_review_until_date => l_inv_review_until_date,
                x_cash_appl_rule_id     => l_cash_appl_rule_id,
                x_invoice_format        => l_invoice_format,
                x_review_invoice_yn     => l_review_invoice_yn,
                x_cust_acct_site_id     => l_cust_acct_site_id,
                x_payment_term_id       => l_payment_term_id);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.SET_MESSAGE (
                            p_app_name      => G_APP_NAME,
                            p_msg_name      => G_VERIFY_VENDOR_BILL,
                            p_token1        => G_VENDOR_NAME_TOKEN,
                            p_token1_value  => l_asdv_tbl_proc(i).vendor_name
               );
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.SET_MESSAGE (
                            p_app_name      => G_APP_NAME,
                            p_msg_name      => G_VERIFY_VENDOR_BILL,
                            p_token1        => G_VENDOR_NAME_TOKEN,
                            p_token1_value  => l_asdv_tbl_proc(i).vendor_name
               );
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
         -- Varangan - Billing Enhancement changes - Bug#5874824 - Begin
            lp_taiv_rec.ibt_id   := l_cust_acct_site_id;
            lp_taiv_rec.ixx_id   := l_cust_acct_id;
            lp_taiv_rec.irt_id   := l_payment_term_id;
            lp_taiv_rec.irm_id   := l_payment_method_id;
        -- Varangan - Billing Enhancement changes - Bug#5874824 - End
            --function to fetch try_id
            l_try_id := Get_trx_type_id(p_trx_type => G_AR_INV_TRX_TYPE,
                                        p_lang     => 'US');
            If l_try_id is null then
                x_return_status := OKL_API.G_RET_STS_ERROR;
                        OKL_API.SET_MESSAGE (
                                p_app_name          => G_APP_NAME,
                                p_msg_name          => G_REQUIRED_VALUE,
                                p_token1            => G_COL_NAME_TOKEN,
                                p_token1_value      => 'Transaction Type');
                RAISE OKL_API.G_EXCEPTION_ERROR;
            End If;
         -- Varangan - Billing Enhancement changes - Bug#5874824 - Begin
            lp_taiv_rec.try_id           := l_try_id;
            lp_taiv_rec.trx_status_code  := G_SUBMIT_STATUS;
            lp_taiv_rec.date_entered     := sysdate;

            lp_taiv_rec.OKL_SOURCE_BILLING_TRX := G_SOURCE_BILLING_TRX_BOOK;

        -- Populate the Line record
            lp_tilv_rec.amount               := l_asdv_tbl_proc(i).amount;
            -- varangan - Bug#5474059 - Modified - Start
		      -- Passing KLE_ID as subsidy line id to track the subsidy records during rebook
            lp_tilv_rec.kle_id               := l_asdv_tbl_proc(i).subsidy_cle_id;

            lp_tilv_rec.description          := l_asdv_tbl_proc(i).description;
            lp_tilv_rec.sty_id               := l_asdv_tbl_proc(i).stream_type_id;
            lp_tilv_rec.line_number          := i;
            lp_tilv_rec.inv_receiv_line_code := G_AR_INV_LINE_CODE;
			--   Bug# 4673593 -- pass bank acc# to internal |
	    lp_tilv_rec.bank_acct_id := l_bank_account_id;
			--   Bug# 4673593 -- pass bank acc# to internal |

            lp_tilv_tbl(1) := lp_tilv_rec; -- Assign the line record in tilv_tbl structure

            ---------------------------------------------------------------------------
	    -- Call to Billing Centralized API
	    ---------------------------------------------------------------------------
		okl_internal_billing_pvt.create_billing_trx(p_api_version =>l_api_version,
							    p_init_msg_list =>p_init_msg_list,
							    x_return_status =>  x_return_status,
							    x_msg_count => x_msg_count,
							    x_msg_data => x_msg_data,
							    p_taiv_rec => lp_taiv_rec,
							    p_tilv_tbl => lp_tilv_tbl,
							    p_tldv_tbl => lp_tldv_tbl,
							    x_taiv_rec => lx_taiv_rec,
							    x_tilv_tbl => lx_tilv_tbl,
							    x_tldv_tbl => lx_tldv_tbl,
							    p_cpl_id   => l_chr_cpl_id);

	       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;



			   /* -- Commenting the existing code for calling common Billing API

			   --create internal AR transaction header
			    okl_trx_ar_invoices_pub.insert_trx_ar_invoices (
					    p_api_version       => p_api_version,
					    p_init_msg_list     => p_init_msg_list,
					    x_return_status     => x_return_status,
					    x_msg_count         => x_msg_count,
					    x_msg_data          => x_msg_data,
					    p_taiv_rec          => l_taiv_rec,
					    x_taiv_rec          => lx_taiv_rec);

			    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
				RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
			    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
				RAISE OKL_API.G_EXCEPTION_ERROR;
			    END IF;


			    --tilv_record
			    l_tilv_rec.tai_id               := lx_taiv_rec.id;



			    --create internal AR transaction line
			    okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns  (
					    p_api_version       => p_api_version,
					    p_init_msg_list     => p_init_msg_list,
					    x_return_status     => x_return_status,
					    x_msg_count         => x_msg_count,
					    x_msg_data          => x_msg_data,
					    p_tilv_rec          => l_tilv_rec,
					    x_tilv_rec          => lx_tilv_rec);

			    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
				RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
			    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
				RAISE OKL_API.G_EXCEPTION_ERROR;
			    END IF;


			    --accounting trx
			    l_bpd_acc_rec.id                := lx_tilv_rec.id;
			    l_bpd_acc_rec.source_table      := G_AR_LINES_SOURCE;

			    -- Create Accounting Distribution
				    okl_acc_call_pub.create_acc_trans (
					    p_api_version       => p_api_version,
					    p_init_msg_list     => p_init_msg_list,
					    x_return_status     => x_return_status,
					    x_msg_count         => x_msg_count,
					    x_msg_data          => x_msg_data,
					    p_bpd_acc_rec       => l_bpd_acc_rec);

			    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
				RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
			    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
				RAISE OKL_API.G_EXCEPTION_ERROR;
			    END IF; */

            -- Varangan - Billing Enhancement changes - Bug#5874824 - End
        End Loop;
        End If;
    End If;

    l_asdv_tbl_proc.delete;
    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If l_samevend_csr%ISOPEN then
        close l_samevend_csr;
    End If;
    If l_chrcpl_csr%ISOPEN then
        close l_chrcpl_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If l_samevend_csr%ISOPEN then
        close l_samevend_csr;
    End If;
    If l_chrcpl_csr%ISOPEN then
        close l_chrcpl_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_samevend_csr%ISOPEN then
        close l_samevend_csr;
    End If;
    If l_chrcpl_csr%ISOPEN then
        close l_chrcpl_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END insert_billing_records;
-- varangan - Bug#5474059 - Added - End
--------------------------------------------------------------------------------
--Name     : Rebook_Synchronize
--Date     : 08-Sep-2003
--Purpose  : This will be called during online rebooks to synchronize any
--           changes made on subsidies
--------------------------------------------------------------------------------
PROCEDURE rebook_synchronize(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rbk_chr_id                   in number,
    p_orig_chr_id                  in number
    ) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'REBOOK_SYNCHRONIZE';
    l_api_version          CONSTANT     NUMBER := 1.0;



--2.cursors to check if any of the subsidy elements have changed
  ---------------------------------------------------------------------------
  --get subsidy elements from rebook copy contract
  ---------------------------------------------------------------------------
  cursor l_subelm_rbk_csr(p_chr_id in number) is
  select  kle.SUBSIDY_ID
         ,clet.NAME
         ,clet.ITEM_DESCRIPTION
         ,kle.AMOUNT
         ,kle.SUBSIDY_OVERRIDE_AMOUNT
         ,cleb.orig_system_id1
         ,cplb.object1_id1  vendor_id
         ,cplb.id           cpl_id
         ,kle.sty_id        sty_id
  from   okl_k_lines          kle,
         okc_k_lines_tl       clet,
         okc_k_lines_b        cleb,
         okc_statuses_b       stsb,
         okc_line_styles_b    lseb,
         okc_k_party_roles_b  cplb
  where  kle.id          = cleb.id
  and    clet.id         = cleb.id
  and    clet.language   = userenv('LANG')
  and    cleb.dnz_chr_id = p_chr_id
  and    cleb.orig_system_id1 is not null
  and    stsb.code       = cleb.sts_code
  and    stsb.ste_code   not in ('CANCELLED')
  and    lseb.id         =  cleb.lse_id
  and    lseb.lty_code   =  'SUBSIDY'
  and    cplb.cle_id     = cleb.id
  and    cplb.rle_code   = 'OKL_VENDOR'
  and    cplb.dnz_chr_id = p_chr_id;

  l_subelm_rbk_rec l_subelm_rbk_csr%ROWTYPE;

  ---------------------------------------------------------------------------
  --get subsidy elements from original contract
  ---------------------------------------------------------------------------
  cursor l_subelm_orig_csr(p_cle_id in number,
                           p_chr_id in number) is
  select  kle.SUBSIDY_ID
         ,clet.NAME
         ,clet.ITEM_DESCRIPTION
         ,kle.AMOUNT
         ,kle.SUBSIDY_OVERRIDE_AMOUNT
         ,cplb.object1_id1  vendor_id
         ,cplb.id           cpl_id
         ,kle.sty_id        sty_id
  from   okl_k_lines          kle,
         okc_k_lines_tl       clet,
         okc_k_lines_b        cleb,
         okc_statuses_b       stsb,
         okc_line_styles_b    lseb,
         okc_k_party_roles_b  cplb
  where  kle.id          = cleb.id
  and    clet.id         = cleb.id
  and    clet.language   = userenv('LANG')
  and    cleb.id         = p_cle_id
  and    cleb.dnz_chr_id = p_chr_id
  and    stsb.code       = cleb.sts_code
  and    stsb.ste_code   not in ('CANCELLED')
  and    lseb.id         =  cleb.lse_id
  and    lseb.lty_code   =  'SUBSIDY'
  and    cplb.cle_id     = cleb.id
  and    cplb.rle_code   = 'OKL_VENDOR'
  and    cplb.dnz_chr_id = p_chr_id;

  l_subelm_orig_rec l_subelm_orig_csr%ROWTYPE;

  ----------------------------------------------------------
  --cursors to get party payment details
  ----------------------------------------------------------
  cursor l_ppyd_rbk_csr (p_cpl_id in number) is
  select ID
         ,CPL_ID
         ,VENDOR_ID
         ,PAY_SITE_ID
         ,PAYMENT_TERM_ID
         ,PAYMENT_METHOD_CODE
         ,PAY_GROUP_CODE
  from okl_party_payment_dtls
  where cpl_id = p_cpl_id;

  l_ppyd_rbk_rec  l_ppyd_rbk_csr%ROWTYPE;

  cursor l_ppyd_orig_csr (p_cpl_id in number) is
  select ID
         ,CPL_ID
         ,VENDOR_ID
         ,PAY_SITE_ID
         ,PAYMENT_TERM_ID
         ,PAYMENT_METHOD_CODE
         ,PAY_GROUP_CODE
  from okl_party_payment_dtls
  where cpl_id = p_cpl_id;

  l_ppyd_orig_rec  l_ppyd_orig_csr%ROWTYPE;

  ------------------------------------------------------------------------------
  --cursor to find out subsidy line which has been deleted
  ------------------------------------------------------------------------------
  cursor l_del_sub_csr (p_orig_chr_id in number,
                        p_rbk_chr_id  in number) is
  select cleb.id  cle_id,
         cplb.id  cpl_id
  from   okc_k_lines_b        cleb,
         okc_line_styles_b    lseb,
         okc_k_party_roles_b  cplb
  where  cleb.dnz_chr_id = p_orig_chr_id
  and    lseb.id         =  cleb.lse_id
  and    lseb.lty_code   =  'SUBSIDY'
  and    cplb.cle_id     = cleb.id
  and    cplb.dnz_chr_id = p_orig_chr_id
  and    cplb.rle_code   = 'OKL_VENDOR'
  --Bug# 8766336
  and    cleb.sts_code <> 'ABANDONED'
  --line was deleted from rebook copy :
  and    not exists (select '1'
                     from   okc_k_lines_b cleb2
                     where  cleb2.orig_system_id1 = cleb.id
                     and    cleb2.dnz_chr_id       = p_rbk_chr_id
                     --Bug# 8766336
                     and    cleb2.sts_code <> 'ABANDONED')
  --line is not a new line created during this rebook
  and    not exists (select '1'
                     from   okc_k_lines_b cleb3
                     where  cleb3.id   = cleb.orig_system_id1
                     and    cleb3.dnz_chr_id = p_rbk_chr_id);

  l_del_sub_id      number;
  l_del_cpl_id      number;

    ------------------------------------------------------------------------------
  --cursor to find out new subsidy lines which have been added
  ------------------------------------------------------------------------------
  cursor l_new_sub_csr (p_chr_id  in number) is
  select kle.subsidy_id              subsidy_id,
         cleb.id                     subsidy_cle_id,
         clet.name                   name,
         clet.item_description       description,
         kle.amount                  amount,
         kle.subsidy_override_amount subsidy_override_amount,
         cleb.dnz_chr_id             dnz_chr_id,
         cleb.cle_id                 asset_cle_id,
         cplb.id                     cpl_id,
         cplb.object1_id1            vendor_id,
         cleb.lse_id                 lse_id,
         cleb.display_sequence       display_sequence,
         cleb.start_date             start_date,
         cleb.end_date               end_date,
         cleb.currency_code          currency_code,
         cleb.sts_code               sts_code,
         kle.sty_id                  sty_id,
         asst_cleb.orig_system_id1   orig_asst_cle_id,
         --Bug# 8677460
         kle.orig_contract_line_id   orig_contract_line_id
  from
         okc_k_lines_b              asst_cleb,
         okc_statuses_b             asst_sts,
         okc_k_party_roles_b        cplb,
         okc_k_lines_tl             clet,
         okl_k_lines                kle,
         okc_line_styles_b          lseb,
         okc_k_lines_b              cleb

  Where  asst_cleb.id              =   cleb.cle_id
  And    asst_cleb.dnz_chr_id      =   cleb.dnz_chr_id
  And    asst_sts.code             =   asst_cleb.sts_code
  And    asst_sts.ste_code         not in ('HOLD','EXPIRED','TERMINATED','CANCELLED')
  And    cplb.jtot_object1_code    =   'OKX_VENDOR'
  And    cplb.dnz_chr_id           =   cleb.dnz_chr_id
  And    cplb.cle_id               =   cleb.id
  And    cplb.rle_code             =   'OKL_VENDOR'
  And    clet.id                   =   cleb.id
  And    clet.language             =   userenv('LANG')
  And    kle.id                    =   cleb.id
  And    lseb.id                   =   cleb.lse_id
  And    lseb.lty_code             =   'SUBSIDY'
  And    cleb.dnz_chr_id           =   p_chr_id
  And    cleb.orig_system_id1  is null
  And    asst_cleb.orig_system_id1 is not null
  And    cleb.sts_code <> 'ABANDONED';

  l_new_sub_rec     l_new_sub_csr%ROWTYPE;

  --cursor to get asset line id if asset line is new
  cursor l_cleb_csr (p_orig_cle_id in number) is
  select cleb.id
  from   okc_k_lines_b cleb
  where  cleb.orig_system_id1 = p_orig_cle_id;

  l_asset_cle_id okc_k_lines_b.ID%TYPE;

  --record structures for update and delete

  l_asst_clev_rec    okl_okc_migration_pvt.clev_rec_type;
  l_asst_klev_rec    okl_contract_pub.klev_rec_type;
  lx_asst_clev_rec   okl_okc_migration_pvt.clev_rec_type;
  lx_asst_klev_rec   okl_contract_pub.klev_rec_type;

  l_sub_clev_rec    okl_okc_migration_pvt.clev_rec_type;
  l_sub_klev_rec    okl_contract_pub.klev_rec_type;
  lx_sub_clev_rec   okl_okc_migration_pvt.clev_rec_type;
  lx_sub_klev_rec   okl_contract_pub.klev_rec_type;


  l_cplv_rec           okl_okc_migration_pvt.cplv_rec_type;
  lx_cplv_rec          okl_okc_migration_pvt.cplv_rec_type;


  l_pydv_rec          okl_pyd_pvt.ppydv_rec_type;
  lx_pydv_rec         okl_pyd_pvt.ppydv_rec_type;

  -- sjalasut, added local variables to support logging. added as part of
  -- subsidy pools enhancement
  l_module CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_PROCESS_PVT.REBOOK_SYNCHRONIZE';
  l_debug_enabled VARCHAR2(10);
  is_debug_statement_on BOOLEAN;

  --Bug# 4558486
  l_kplv_rec          okl_k_party_roles_pvt.kplv_rec_type;
  lx_kplv_rec         okl_k_party_roles_pvt.kplv_rec_type;

  --Bug# 4899328
  l_orig_asset_cle_id   number;
  l_cap_amount          number;
  l_clev_fin_rec    okl_okc_migration_pvt.clev_rec_type;
  l_klev_fin_rec    okl_contract_pub.klev_rec_type;
  lx_clev_fin_rec   okl_okc_migration_pvt.clev_rec_type;
  lx_klev_fin_rec   okl_contract_pub.klev_rec_type;

   -- varangan - Bug#5474059  - Added - Start
   l_new_asdv_tbl asbv_tbl_type;
   l_new_cnt      NUMBER DEFAULT 0;
   -- varangan - Bug#5474059  - Added - End
begin

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- check if debug is enabled
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    --------------------------------------
    --start of input parameter validations
    --------------------------------------
    --1.validate p_rbk_chr_id
    If (p_rbk_chr_id is NULL) or (p_rbk_chr_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_rbk_chr_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_rbk_chr_id is not NULL) and (p_rbk_chr_id <> OKL_API.G_MISS_NUM) then
        validate_chr_id(p_chr_id        => p_rbk_chr_id,
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_rbk_chr_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    --2.validate p_orig_chr_id
    If (p_orig_chr_id is NULL) or (p_orig_chr_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_orig_chr_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_orig_chr_id is not NULL) and (p_orig_chr_id <> OKL_API.G_MISS_NUM) then
        validate_chr_id(p_chr_id        => p_orig_chr_id,
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_orig_chr_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    -------------------------------------
    --end of input parameter validations
    ------------------------------------
    /*
     * sjalasut, added code here to call synchornization of subsidy pool transactions
     * before synchronizing the subsidy lines. this code is added as part of
     * subsidy pools enhancement. START
     */
     -- write to log
     IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                               l_module,
                               'invoking OKL_SUBSIDY_POOL_AUTH_TRX_PVT.create_pool_trx_khr_rbk'||
                               ' p_rbk_chr_id '||p_rbk_chr_id||' p_orig_chr_id '||p_orig_chr_id
                               );
     END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

     OKL_SUBSIDY_POOL_AUTH_TRX_PVT.create_pool_trx_khr_rbk(p_api_version   => p_api_version
                                                          ,p_init_msg_list => p_init_msg_list
                                                          ,x_return_status => x_return_status
                                                          ,x_msg_count     => x_msg_count
                                                          ,x_msg_data      => x_msg_data
                                                          ,p_rbk_chr_id    => p_rbk_chr_id
                                                          ,p_orig_chr_id    => p_orig_chr_id
                                                          );
     -- write to log
     IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                               l_module,
                               'OKL_SUBSIDY_POOL_AUTH_TRX_PVT.create_pool_trx_khr_rbk returned with status '||x_return_status||
                               ' x_msg_data '||x_msg_data
                               );
     END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

     IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF(x_return_status = OKL_API.G_RET_STS_ERROR)THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

    /*
     * sjalasut, added code here to call synchornization of subsidy pool transactions
     * before synchronizing the subsidy lines. this code is added as part of
     * subsidy pools enhancement. END
     */

   -----------------------------------------------------------------------------
   --A. Synchronize subsidized amounts on the financial asset lines
   -----------------------------------------------------------------------------
    --This code(Part A) is promoted to rebook api as asset lines are being synched there

    ----------------------------------------------------------------------------
    --B. Sunchronize subsidy line attributes
    ----------------------------------------------------------------------------
    --1. Fetch subsidy line attributes for the rebook copy
    Open l_subelm_rbk_csr(p_chr_id => p_rbk_chr_id);
    Loop
        Fetch l_subelm_rbk_csr into l_subelm_rbk_rec;
        Exit when l_subelm_rbk_csr%NOTFOUND;
        --2. Fetch subsidy line attributes for original contract
        Open l_subelm_orig_csr(p_cle_id => l_subelm_rbk_rec.orig_system_id1,
                               p_chr_id => p_orig_chr_id);
        Fetch l_subelm_orig_csr into l_subelm_orig_rec;
        If l_subelm_orig_csr%NOTFOUND then
            Null;
        Else
            --3. syncronize subsidy line attributes in case of differences
            If  (nvl(l_subelm_orig_rec.amount,0)                  <>  nvl(l_subelm_rbk_rec.Amount,0)) OR
                (nvl(l_subelm_orig_rec.subsidy_override_amount,0) <>  nvl(l_subelm_rbk_rec.subsidy_override_Amount,0)) OR
                (l_subelm_orig_rec.subsidy_id                     <>  l_subelm_rbk_rec.subsidy_id) OR
                (l_subelm_orig_rec.sty_id                         <>  l_subelm_rbk_rec.sty_id) Then

                l_sub_clev_rec.id                       := l_subelm_rbk_rec.orig_system_id1;
                l_sub_klev_rec.id                       := l_subelm_rbk_rec.orig_system_id1;
                l_sub_klev_rec.Amount                   := l_subelm_rbk_rec.Amount;
                l_sub_klev_rec.Subsidy_override_Amount  := l_subelm_rbk_rec.Subsidy_override_Amount;
                l_sub_klev_rec.Subsidy_id               := l_subelm_rbk_rec.Subsidy_id;
                l_sub_clev_rec.Name                     := l_subelm_rbk_rec.Name;
                l_sub_clev_rec.item_description         := l_subelm_rbk_rec.item_description;
                l_sub_klev_rec.sty_id                   := l_subelm_rbk_rec.sty_id;

                --dbms_output.put_line('Amount before updating line '||to_char(l_sub_klev_rec.Amount));
                okl_contract_pub.update_contract_line
                    (p_api_version   => p_api_version,
                     p_init_msg_list => p_init_msg_list,
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_clev_rec      => l_sub_clev_rec,
                     p_klev_rec      => l_sub_klev_rec,
                     x_clev_rec      => lx_sub_clev_rec,
                     x_klev_rec      => lx_sub_klev_rec);

                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                --Bug# 4899328 : Recalculate OEC and capital amount and update financial asset line
                l_orig_asset_cle_id := lx_sub_clev_rec.cle_id;
                OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_formula_name  => G_FORMULA_CAP,
                                    p_contract_id   => p_orig_chr_id,
                                    p_line_id       => l_orig_asset_cle_id,
                                    x_value         => l_cap_amount);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               ----------------------------------------------------------------------
               --call api to update costs on asset line
               ----------------------------------------------------------------------
               l_clev_fin_rec.id                    := l_orig_asset_cle_id;
               l_klev_fin_rec.id                    := l_orig_asset_cle_id;
               l_klev_fin_rec.capital_amount        := l_cap_amount;


               okl_contract_pub.update_contract_line
                           (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_clev_rec      => l_clev_fin_rec,
                            p_klev_rec      => l_klev_fin_rec,
                            x_clev_rec      => lx_clev_fin_rec,
                            x_klev_rec      => lx_klev_fin_rec
                            );

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
            End If;
            --Bug# 4899328

            --4. syncronize subsidy party attributes in case of differences
            IF (l_subelm_orig_rec.vendor_id <>  l_subelm_rbk_rec.vendor_id) Then
                Null;
                --------------------------------------------------------------
                --***(i)Commented as syncing vendor not allowed during rebooks
                --as per srawlings: if vendor is to be changed delete the
                --subsidy and add a new one
                /*------------------------------------------------------------
                --l_cplv_rec.id          := l_subelm_orig_rec.cpl_id;
                --l_cplv_rec.object1_id1 := l_subelm_rbk_rec.vendor_id;

                --okl_okc_migration_pvt.update_k_party_role
                    --(p_api_version   => p_api_version,
                     --p_init_msg_list => p_init_msg_list,
                     --x_return_status => x_return_status,
                     --x_msg_count     => x_msg_count,
                     --x_msg_data      => x_msg_data,
                     --p_cplv_rec      => l_cplv_rec,
                     --x_cplv_rec      => lx_cplv_rec);

                --IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    --RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                --ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    --RAISE OKL_API.G_EXCEPTION_ERROR;
                --END IF;
                -----------------------------------------------------------*/
                --***Commented as syncing vendor not allowed during rebooks
                --as per srawlings
                -----------------------------------------------------------
            End If;

            -----------------------------------------------------------------------
            --In view of the above decesion(i) of not changing the vendor during re-book,
            --party payment details will be synced only if the vendor is same on
            --rebook copy and the original contract. So enclosed the party payment
            --details sync code in IF clause below.
            ------------------------------------------------------------------------
            IF (l_subelm_orig_rec.vendor_id = l_subelm_rbk_rec.vendor_id) THEN --new IF clause
                --5. party payment details synchronization
                open l_ppyd_rbk_csr (p_cpl_id => l_subelm_rbk_rec.cpl_id);
                fetch l_ppyd_rbk_csr into l_ppyd_rbk_rec;
                If l_ppyd_rbk_csr%NOTFOUND then
                    open l_ppyd_orig_csr (p_cpl_id => l_subelm_orig_rec.cpl_id);
                    fetch l_ppyd_orig_csr into l_ppyd_orig_rec;
                    If l_ppyd_orig_csr%NOTFOUND then
                       null;
                    Else
                       --delete party payment details
                       l_pydv_rec.id := l_ppyd_orig_rec.id;

                       OKL_PYD_PVT.delete_row
                         (p_api_version   => p_api_version,
                          p_init_msg_list => p_init_msg_list,
                          x_return_status => x_return_status,
                          x_msg_count     => x_msg_count,
                          x_msg_data      => x_msg_data,
                          p_ppydv_rec      => l_pydv_rec);


                        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                            RAISE OKL_API.G_EXCEPTION_ERROR;
                        END IF;
                    End If;
                    close l_ppyd_orig_csr;
                Else
                    open l_ppyd_orig_csr (p_cpl_id => l_subelm_orig_rec.cpl_id);
                    fetch l_ppyd_orig_csr into l_ppyd_orig_rec;
                    If l_ppyd_orig_csr%NOTFOUND then

                       --create payment details row
                       l_pydv_rec.cpl_id              := l_subelm_orig_rec.cpl_id;
                       l_pydv_rec.vendor_id           := l_ppyd_rbk_rec.vendor_id;
                       l_pydv_rec.pay_site_id         := l_ppyd_rbk_rec.pay_site_id;
                       l_pydv_rec.payment_term_id     := l_ppyd_rbk_rec.payment_term_id;
                       l_pydv_rec.payment_method_code := l_ppyd_rbk_rec.payment_method_code;
                       l_pydv_rec.pay_group_code      := l_ppyd_rbk_rec.pay_group_code;

                       OKL_PYD_PVT.insert_row
                          (p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_ppydv_rec     => l_pydv_rec,
                           x_ppydv_rec     => lx_pydv_rec);


                     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                         RAISE OKL_API.G_EXCEPTION_ERROR;
                     END IF;


                    Else
                        --if payment details are not equal
                       If (l_ppyd_orig_rec.pay_site_id           <> l_ppyd_rbk_rec.pay_site_id) OR
                       (l_ppyd_orig_rec.payment_term_id       <> l_ppyd_rbk_rec.payment_term_id) OR
                       (l_ppyd_orig_rec.payment_method_code   <> l_ppyd_rbk_rec.payment_method_code) OR
                       (l_ppyd_orig_rec.pay_group_code        <> l_ppyd_rbk_rec.pay_group_code) Then

                            l_pydv_rec.id                    := l_ppyd_orig_rec.id;
                            l_pydv_rec.cpl_id                := l_subelm_orig_rec.cpl_id;
                            l_pydv_rec.vendor_id             := l_ppyd_rbk_rec.vendor_id;
                            l_pydv_rec.pay_site_id           := l_ppyd_rbk_rec.pay_site_id;
                            l_pydv_rec.payment_term_id       := l_ppyd_rbk_rec.payment_term_id;
                            l_pydv_rec.payment_method_code   := l_ppyd_rbk_rec.payment_method_code;
                            l_pydv_rec.pay_group_code        := l_ppyd_rbk_rec.pay_group_code;

                            okl_pyd_pvt.update_row
                           (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_ppydv_rec      => l_pydv_rec,
                            x_ppydv_rec      => lx_pydv_rec);


                            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                RAISE OKL_API.G_EXCEPTION_ERROR;
                            END IF;
                        End If;
                    End If;
                    close l_ppyd_orig_csr;
                End If;
                Close l_ppyd_rbk_csr;
            END IF;-- If for effective only if vendor has not been modified
            -----------------------------------------------------------------------------------
            --party payment detail updates are effective only if vendor has not been modified on
            --rebook copy - as vendor updates are not allowed on a subsidy line during rebook
            ------------------------------------------------------------------------------------
        End If;
        Close l_subelm_orig_csr;
    End Loop;
    Close l_subelm_rbk_csr;

    ----------------------------------------------------------------------------
    --C. Delete any subsidy lines deleted during rebook
    ----------------------------------------------------------------------------
    open l_del_sub_csr (p_orig_chr_id => p_orig_chr_id,
                        p_rbk_chr_id  => p_rbk_chr_id);
    Loop
        Fetch  l_del_sub_csr into   l_del_sub_id,
                                    l_del_cpl_id;
        Exit when l_del_sub_csr%NOTFOUND;

        --3. Logically Delete subsidy line
        l_sub_clev_rec.id       := l_del_sub_id;
        l_sub_klev_rec.id       := l_del_sub_id;
        l_sub_clev_rec.sts_code := 'ABANDONED';

        okl_contract_pub.update_contract_line
            (p_api_version   => p_api_version,
             p_init_msg_list => p_init_msg_list,
             x_return_status => x_return_status,
             x_msg_count     => x_msg_count,
             x_msg_data      => x_msg_data,
             p_clev_rec      => l_sub_clev_rec,
             p_klev_rec      => l_sub_klev_rec,
             x_clev_rec      => lx_sub_clev_rec,
             x_klev_rec      => lx_sub_klev_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        /*********can not physically delete line on a booked K ****/

        --Bug# 4899328 : Recalculate OEC and capital amount and update financial asset line
        l_orig_asset_cle_id := lx_sub_clev_rec.cle_id;
        OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_formula_name  => G_FORMULA_CAP,
                                    p_contract_id   => p_orig_chr_id,
                                    p_line_id       => l_orig_asset_cle_id,
                                    x_value         => l_cap_amount);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        ----------------------------------------------------------------------
        --call api to update costs on asset line
        ----------------------------------------------------------------------
        l_clev_fin_rec.id                    := l_orig_asset_cle_id;
        l_klev_fin_rec.id                    := l_orig_asset_cle_id;
        l_klev_fin_rec.capital_amount        := l_cap_amount;


        okl_contract_pub.update_contract_line
                           (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_clev_rec      => l_clev_fin_rec,
                            p_klev_rec      => l_klev_fin_rec,
                            x_clev_rec      => lx_clev_fin_rec,
                            x_klev_rec      => lx_klev_fin_rec
                            );

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        --Bug# 4899328

    End Loop;
    Close l_del_sub_csr;

    ----------------------------------------------------------------------------
    --C. Syncronize new subsidy line
    ----------------------------------------------------------------------------
    --1. fetch new subsidy lines
    open l_new_sub_csr (p_chr_id => p_rbk_chr_id);
    Loop
        Fetch l_new_sub_csr into l_new_sub_rec;
        Exit when l_new_sub_csr%NOTFOUND;

        --create subsidy line record
        l_sub_klev_rec.id                      := OKL_API.G_MISS_NUM;
        l_sub_klev_rec.subsidy_id              := l_new_sub_rec.subsidy_id;
        l_sub_klev_rec.amount                  := l_new_sub_rec.amount;
        l_sub_klev_rec.subsidy_override_amount := l_new_sub_rec.subsidy_override_amount;
        l_sub_klev_rec.sty_id                  := l_new_sub_rec.sty_id;

        --Bug# 8677460
        l_sub_klev_rec.orig_contract_line_id   := l_new_sub_rec.orig_contract_line_id;

        If l_new_sub_rec.orig_asst_cle_id is not null then
            l_sub_clev_rec.cle_id                  := l_new_sub_rec.orig_asst_cle_id;
        Else
            Open l_cleb_csr(p_orig_cle_id => l_new_sub_rec.asset_cle_id);
            fetch l_cleb_csr into l_asset_cle_id;
            If l_cleb_csr%NOTFOUND then
                null;
            End If;
            close l_cleb_csr;
            l_sub_clev_rec.cle_id              := l_asset_cle_id;
        End If;

        l_sub_clev_rec.id                      := OKL_API.G_MISS_NUM;
        l_sub_clev_rec.dnz_chr_id              := p_orig_chr_id;
        l_sub_clev_rec.exception_yn            := 'N';
        l_sub_clev_rec.lse_id                  := l_new_sub_rec.lse_id;
        l_sub_clev_rec.display_sequence        := l_new_sub_rec.display_sequence;
        l_sub_clev_rec.name                    := l_new_sub_rec.name;
        l_sub_clev_rec.item_description        := l_new_sub_rec.description;
        l_sub_clev_rec.start_date              := l_new_sub_rec.start_date;
        l_sub_clev_rec.end_date                := l_new_sub_rec.end_date;
        l_sub_clev_rec.currency_code           := l_new_sub_rec.currency_code;
        l_sub_clev_rec.sts_code                := l_new_sub_rec.sts_code;

        --dbms_output.put_line('Amount before updating line '||to_char(l_sub_klev_rec.Amount));
        okl_contract_pub.create_contract_line
                    (p_api_version   => p_api_version,
                     p_init_msg_list => p_init_msg_list,
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_clev_rec      => l_sub_clev_rec,
                     p_klev_rec      => l_sub_klev_rec,
                     x_clev_rec      => lx_sub_clev_rec,
                     x_klev_rec      => lx_sub_klev_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --Bug# 4899328 : Recalculate OEC and capital amount and update financial asset line
        l_orig_asset_cle_id := lx_sub_clev_rec.cle_id;
        OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_formula_name  => G_FORMULA_CAP,
                                    p_contract_id   => p_orig_chr_id,
                                    p_line_id       => l_orig_asset_cle_id,
                                    x_value         => l_cap_amount);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       ----------------------------------------------------------------------
       --call api to update costs on asset line
       ----------------------------------------------------------------------
       l_clev_fin_rec.id                    := l_orig_asset_cle_id;
       l_klev_fin_rec.id                    := l_orig_asset_cle_id;
       l_klev_fin_rec.capital_amount        := l_cap_amount;


       okl_contract_pub.update_contract_line
                           (p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_clev_rec      => l_clev_fin_rec,
                            p_klev_rec      => l_klev_fin_rec,
                            x_clev_rec      => lx_clev_fin_rec,
                            x_klev_rec      => lx_klev_fin_rec
                            );

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       --Bug# 4899328

        --create the party role record
        l_cplv_rec.id                   :=  OKL_API.G_MISS_NUM;
        l_cplv_rec.dnz_chr_id           :=   p_orig_chr_id;
        l_cplv_rec.cle_id               :=   lx_sub_clev_rec.id;
        l_cplv_rec.rle_code             :=   'OKL_VENDOR';
        l_cplv_rec.jtot_object1_code    :=   'OKX_VENDOR';
        l_cplv_rec.object1_id1          :=   l_new_sub_rec.vendor_id;
        l_cplv_rec.object1_id2          :=   '#';


        --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
        --              to create records in tables
        --              okc_k_party_roles_b and okl_k_party_roles
        /*
        okl_okc_migration_pvt.create_k_party_role
                    (p_api_version   => p_api_version,
                     p_init_msg_list => p_init_msg_list,
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_cplv_rec      => l_cplv_rec,
                     x_cplv_rec      => lx_cplv_rec);
        */

        okl_k_party_roles_pvt.create_k_party_role
                    (p_api_version   => p_api_version,
                     p_init_msg_list => p_init_msg_list,
                     x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                     x_msg_data      => x_msg_data,
                     p_cplv_rec      => l_cplv_rec,
                     x_cplv_rec      => lx_cplv_rec,
                     p_kplv_rec      => l_kplv_rec,
                     x_kplv_rec      => lx_kplv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        --3. Fetch party payment details for the new line
        Open  l_ppyd_rbk_csr(p_cpl_id => l_new_sub_rec.cpl_id);
        Fetch  l_ppyd_rbk_csr into l_ppyd_rbk_rec;
        If l_ppyd_rbk_csr%NOTFOUND then
            null;
        Else
            --1.create the party payment details record
            l_pydv_rec.id                    := OKL_API.G_MISS_NUM;
            l_pydv_rec.cpl_id                := lx_cplv_rec.id;
            l_pydv_rec.vendor_id             := l_ppyd_rbk_rec.vendor_id;
            l_pydv_rec.pay_site_id           := l_ppyd_rbk_rec.pay_site_id;
            l_pydv_rec.payment_term_id       := l_ppyd_rbk_rec.payment_term_id;
            l_pydv_rec.payment_method_code   := l_ppyd_rbk_rec.payment_method_code;
            l_pydv_rec.pay_group_code        := l_ppyd_rbk_rec.pay_group_code;

            OKL_PYD_PVT.insert_row
                (p_api_version   => p_api_version,
                 p_init_msg_list => p_init_msg_list,
                 x_return_status => x_return_status,
                 x_msg_count     => x_msg_count,
                 x_msg_data      => x_msg_data,
                 p_ppydv_rec     => l_pydv_rec,
                 x_ppydv_rec     => lx_pydv_rec);


             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
        End If;
        Close l_ppyd_rbk_csr;

	-- varangan - Bug#5474059  - Added - Start
      l_new_cnt := l_new_cnt + 1;
      -- Code to create billing transaction records for the newly added subsidies
      get_subsidy_amount(
                    p_api_version       => p_api_version
                  , p_init_msg_list     => p_init_msg_list
                  , x_return_status     => x_return_status
                  , x_msg_count         => x_msg_count
                  , x_msg_data          => x_msg_data
                  , p_subsidy_cle_id    => lx_sub_clev_rec.id
                  , x_asbv_rec          => l_new_asdv_tbl(l_new_cnt));
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- varangan - Bug#5474059  - Added - End
    End Loop;
    Close l_new_sub_csr;

     -- varangan - Bug#5474059 - Added - Start
      -- Call to insert billing transaction records for the newly added subsidies
      IF ( l_new_asdv_tbl.count > 0)THEN
        insert_billing_records(
            p_api_version   => p_api_version
          , p_init_msg_list => p_init_msg_list
          , x_return_status => x_return_status
          , x_msg_count     => x_msg_count
          , x_msg_data      => x_msg_data
          , p_chr_id        => p_orig_chr_id
          , p_asdv_tbl      => l_new_asdv_tbl);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF; -- end of check for l_new_asdv_tbl count
      -- varangan - Bug#5474059 - Added - End

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If l_subelm_rbk_csr%ISOPEN then
        close l_subelm_rbk_csr;
    End If;
    If l_subelm_orig_csr%ISOPEN then
        close l_subelm_orig_csr;
    End If;
    If l_ppyd_rbk_csr%ISOPEN then
        close l_ppyd_rbk_csr;
    End If;
    If l_ppyd_orig_csr%ISOPEN then
        close l_ppyd_orig_csr;
    End If;
    If l_del_sub_csr%ISOPEN then
        close l_del_sub_csr;
    End If;
    If l_new_sub_csr%ISOPEN then
        close l_new_sub_csr;
    End If;
   If l_cleb_csr%ISOPEN then
        close l_cleb_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If l_subelm_rbk_csr%ISOPEN then
        close l_subelm_rbk_csr;
    End If;
    If l_subelm_orig_csr%ISOPEN then
        close l_subelm_orig_csr;
    End If;
    If l_ppyd_rbk_csr%ISOPEN then
        close l_ppyd_rbk_csr;
    End If;
    If l_ppyd_orig_csr%ISOPEN then
        close l_ppyd_orig_csr;
    End If;
    If l_del_sub_csr%ISOPEN then
        close l_del_sub_csr;
    End If;
    If l_new_sub_csr%ISOPEN then
        close l_new_sub_csr;
    End If;
    If l_cleb_csr%ISOPEN then
        close l_cleb_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_subelm_rbk_csr%ISOPEN then
        close l_subelm_rbk_csr;
    End If;
    If l_subelm_orig_csr%ISOPEN then
        close l_subelm_orig_csr;
    End If;
    If l_ppyd_rbk_csr%ISOPEN then
        close l_ppyd_rbk_csr;
    End If;
    If l_ppyd_orig_csr%ISOPEN then
        close l_ppyd_orig_csr;
    End If;
    If l_del_sub_csr%ISOPEN then
        close l_del_sub_csr;
    End If;
    If l_new_sub_csr%ISOPEN then
        close l_new_sub_csr;
    End If;
    If l_cleb_csr%ISOPEN then
        close l_cleb_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End Rebook_synchronize;

-- varangan - Bug#5474059 - Added - End

-- varangan - Bug#5474059 - Added - Start
  -- Start of comments
  -- Procedure Name     : rebook_adjustment
  -- Description        : Logic in the API is as follows:
  --                     - Compare the subsidy lines of the orignal and rebook copy
  --                     - If there is a decrease in subsidy, then check if the AR invoice
  --                       has a balance and create a credit memo on this invoice for the
  --                       invoice balance amount. If there is an excess amount in the subsidy
  --                       change still to be adjusted, create an on-account credit memo.
  --                     - If there is an increase in subsidy, then bill the excess amount to
  --                        the vendor
  --                     - API also handles the case of unprocessed billing transactions which
  --                       a  re cancelled.
  --                     - Deletion of subsidies is also handled
  --                     - Addition of subsidies is taken care in rebook_synchronize procedure
  -- PARAMETERS  : IN - p_rbk_chr_id   : Rebook Copy Contract id
  --               IN - p_orig_chr_id  : Original Contract id
  --               IN - p_rebook_date  : Date of rebook
  -- Created varangan
  -- End of comments
  PROCEDURE rebook_adjustment
           (p_api_version    IN  NUMBER
          , p_init_msg_list  IN  VARCHAR2
          , x_return_status  OUT NOCOPY VARCHAR2
          , x_msg_count      OUT NOCOPY NUMBER
          , x_msg_data       OUT NOCOPY VARCHAR2
          , p_rbk_chr_id     IN  NUMBER
          , p_orig_chr_id    IN  NUMBER
          , p_rebook_date    IN DATE
          ) IS
    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'rebook_adjustment';
    l_api_version          CONSTANT     NUMBER := 1.0;

    --------------------------------------
    -- Cursor Block - Begin
    --------------------------------------
    -- Cursor to get the subsidy present in rebook copy. ORIG_SYSTEM_ID1 relates
    -- to the subsidy on the original contract
    CURSOR c_rbk_subs (p_cle_id IN NUMBER
                     , p_chr_id IN NUMBER) IS
      SELECT CLEB.ID
        FROM OKC_K_LINES_B        CLEB,
             OKC_STATUSES_B       STSB,
             OKC_LINE_STYLES_B    LSEB
      WHERE CLEB.ORIG_SYSTEM_ID1 = p_cle_id
        AND CLEB.ORIG_SYSTEM_SOURCE_CODE ='OKC_LINE'
        AND CLEB.DNZ_CHR_ID = p_chr_id
        AND STSB.CODE       = CLEB.STS_CODE
        AND STSB.STE_CODE   NOT IN ('CANCELLED')
        AND LSEB.ID         =  CLEB.LSE_ID
        AND LSEB.LTY_CODE   =  'SUBSIDY';

    --Added by bkatraga for bug 9276449
    --Cursor to check whether the asset was created during rebook or not
    CURSOR c_rbk_asset(p_cle_id IN NUMBER) IS
    SELECT 'Y'
      FROM OKC_K_LINES_B  ORIG_CLEB,
           OKC_K_LINES_B  RBK_CLEB
     WHERE ORIG_CLEB.ID = p_cle_id
       AND ORIG_CLEB.ORIG_SYSTEM_SOURCE_CODE ='OKC_LINE'
       AND ORIG_CLEB.ORIG_SYSTEM_ID1 = RBK_CLEB.ID
       AND RBK_CLEB.DNZ_CHR_ID = p_rbk_chr_id
       AND RBK_CLEB.ORIG_SYSTEM_ID1 IS NULL;

    -- Cursor to get the unprocessed transactions of the subsidy
    CURSOR c_get_bill_stat( p_cle_id IN NUMBER,
                            p_chr_id IN NUMBER) IS
      SELECT TRX.ID
           , TRX.DESCRIPTION
        FROM OKL_TRX_AR_INVOICES_V TRX
           , OKL_TXL_AR_INV_LNS_B  TIL
       WHERE TIL.TAI_ID = TRX.ID
         AND TIL.KLE_ID = p_cle_id -- subsidy cle id
         AND TRX.KHR_ID = p_chr_id
         AND TRX.TRX_STATUS_CODE = G_SUBMIT_STATUS;

    -- Cursor to get all the invoices already generated for this subsidy
    -- cursor doesnot consider credit-memos,as the invoice balances are already
    -- adjusted for invoice based credit-memos
    CURSOR c_get_inv_balance(p_cle_id IN NUMBER,
                             p_chr_id IN NUMBER) IS
    SELECT ARL.receivables_invoice_id  receivables_invoice_id,
         ARL.RECEIVABLES_INVOICE_LINE_ID invoice_line_id,
         tai.ibt_id                 cust_acct_site_id,
         tai.ixx_id                 cust_acct_id,
         tai.irt_id                 payment_term_id,
         tai.irm_id                 payment_method_id,
         tai.khr_id                 khr_id,
         tai.description            tai_description,
         tai.currency_code          currency_code,
         tai.date_invoiced          date_invoiced,
         tai.amount                 tai_amount,
         tai.try_id                 try_id,
         tai.trx_status_code        trx_status_code,
         tai.date_entered           date_entered,
         til.id                     til_id_reverses,
         til.tai_id                 tai_id,
         til.amount                 til_amount,
         til.kle_id                 subsidy_cle_id,
         til.description            til_description,
         til.sty_id                 stream_type_id,
         til.line_number            line_number,
         til.inv_receiv_line_code   inv_receiv_line_code
       , til.bank_acct_id           bank_acct_id
       -- varangan - Bug#5588871 - Modified - Start
       -- Consider Invoice line balance instead of invoice balance itself
       , ARL.AMOUNT_LINE_ITEMS_REMAINING  amount_remaining
       -- varangan - Bug#5588871 - Modified - End
       , ARL.AMOUNT_DUE_ORIGINAL        invoice_amount
      FROM OKL_BPD_AR_INV_LINES_V ARL
         , OKL_TXL_AR_INV_LNS_V     TIL
         , OKL_TRX_AR_INVOICES_V    TAI
      WHERE
       TIL.KLE_ID                 = p_cle_id -- < SUBSIDY CLE ID >
       AND TAI.ID                     = TIL.TAI_ID
       AND TAI.KHR_ID                 = p_chr_id
       AND TAI.TRX_STATUS_CODE = 'PROCESSED'
       AND TIL.ID = ARL.TIL_ID_DETAILS
       AND ARL.AMOUNT_DUE_ORIGINAL > 0 -- donot consider credit memos
       AND ARL.AMOUNT_DUE_REMAINING > 0 -- only those invoices that have some balance
     ORDER BY ARL.AMOUNT_DUE_REMAINING DESC;

    -- Cursor to get billing details in order to create on-Acc CM
    CURSOR c_get_bill_details(p_cle_id IN NUMBER,
                             p_chr_id IN NUMBER) IS
    SELECT tai.ibt_id               cust_acct_site_id,
         tai.ixx_id                 cust_acct_id,
         tai.irt_id                 payment_term_id,
         tai.irm_id                 payment_method_id,
         tai.khr_id                 khr_id,
         tai.description            tai_description,
         tai.currency_code          currency_code,
         tai.date_invoiced          date_invoiced,
         tai.amount                 tai_amount,
         tai.try_id                 try_id,
         tai.trx_status_code        trx_status_code,
         tai.date_entered           date_entered,
         til.id                     til_id_reverses,
         til.tai_id                 tai_id,
         til.amount                 til_amount,
         til.kle_id                 subsidy_cle_id,
         til.description            til_description,
         til.sty_id                 stream_type_id,
         til.line_number            line_number,
         til.inv_receiv_line_code   inv_receiv_line_code
       , til.bank_acct_id           bank_acct_id
      FROM OKL_TXL_AR_INV_LNS_V     TIL
         , OKL_TRX_AR_INVOICES_V    TAI
     WHERE TIL.KLE_ID                 = p_cle_id -- < SUBSIDY CLE ID >
       AND TAI.ID                     = TIL.TAI_ID
       AND TAI.KHR_ID                 = p_chr_id;

    -- Cursor to check if any records have been processed for billing
    CURSOR c_chk_billing_done ( p_cle_id IN NUMBER
                              , p_chr_id IN NUMBER) IS
      SELECT 'Y'
        FROM OKL_TRX_AR_INVOICES_B TAI
           , OKL_TXL_AR_INV_LNS_B  TXL
       WHERE TXL.TAI_ID  = TAI.ID
         AND TXL.KLE_ID  = p_cle_id -- subsidy cle id
         AND TAI.KHR_ID  = p_chr_id
         AND TAI.TRX_STATUS_CODE = G_PROCESSED_STATUS;
    --------------------------------------
    -- Cursor Block - End
    --------------------------------------

    l_pos_try_id    NUMBER;
    l_neg_try_id    NUMBER;

    l_orig_asdv_tbl asbv_tbl_type;
    l_rbk_asdv_tbl  asbv_tbl_type;

    l_new_asdv_tbl asbv_tbl_type;
    l_new_cnt      NUMBER DEFAULT 0;

    l_rbk_subs_cle_id NUMBER;
    l_cancel_taiv_tbl OKL_TRX_AR_INVOICES_PUB.taiv_tbl_type;
    lx_cancel_taiv_tbl OKL_TRX_AR_INVOICES_PUB.taiv_tbl_type;
    l_cancel_cnt NUMBER DEFAULT 0;

    l_subs_adj NUMBER;
    l_bill_chk VARCHAR2(1) DEFAULT 'N';
    -- varangan - Billing Enhancement changes- Bug#5874824 - begin
    /*l_taiv_rec      okl_trx_ar_invoices_pub.taiv_rec_type;
    lx_taiv_rec      okl_trx_ar_invoices_pub.taiv_rec_type;
    l_tilv_rec      okl_txl_ar_inv_lns_pub.tilv_rec_type;
    lx_tilv_rec      okl_txl_ar_inv_lns_pub.tilv_rec_type;
    l_bpd_acc_rec   okl_acc_call_pub.bpd_acc_rec_type; */

    lp_taiv_rec        okl_tai_pvt.taiv_rec_type;
    lp_tilv_rec	       okl_til_pvt.tilv_rec_type;
    lp_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lp_tldv_tbl        okl_tld_pvt.tldv_tbl_type;

    lx_taiv_rec        okl_tai_pvt.taiv_rec_type;
    lx_tilv_tbl        okl_til_pvt.tilv_tbl_type;
    lx_tldv_tbl        okl_tld_pvt.tldv_tbl_type;

--Varangan - Billing Enhancement changes - Bug#5874824  - End

    l_asbv_rec asbv_rec_type;

    l_bill_details_rec c_get_bill_details%ROWTYPE;
    l_rbk_asset_flag  VARCHAR2(1); --Added by bkatraga for bug 9276449

    -------------------------------------------------------
    -- Local Procedure Block
    -------------------------------------------------------
        PROCEDURE on_acc_CM_create( p_subsidy_cle_id IN NUMBER
                              , p_chr_id         IN NUMBER
                              , p_subs_adj       IN NUMBER
                              , p_rebook_date    IN DATE ) IS
    BEGIN
       OPEN c_get_bill_details(p_subsidy_cle_id
                              ,p_chr_id );
                FETCH c_get_bill_details INTO l_bill_details_rec;
             CLOSE c_get_bill_details;

             lp_taiv_rec.amount           := p_subs_adj;
             lp_taiv_rec.khr_id           := l_bill_details_rec.khr_id;
             lp_taiv_rec.description      := 'Rebook Credit On-Acc- '||l_bill_details_rec.tai_description;
             lp_taiv_rec.currency_code    := l_bill_details_rec.currency_code;
             lp_taiv_rec.date_invoiced    := p_rebook_date; --check whether it is ok to give this
             lp_taiv_rec.ibt_id           := l_bill_details_rec.cust_acct_site_id;
             lp_taiv_rec.ixx_id           := l_bill_details_rec.cust_acct_id;
             lp_taiv_rec.irt_id           := l_bill_details_rec.payment_term_id;
             lp_taiv_rec.irm_id           := l_bill_details_rec.payment_method_id;
             lp_taiv_rec.try_id           := l_neg_try_id;
             lp_taiv_rec.trx_status_code  := G_SUBMIT_STATUS;
             lp_taiv_rec.date_entered     := SYSDATE;
             lp_taiv_rec.OKL_SOURCE_BILLING_TRX := G_SOURCE_BILLING_TRX_RBK;

	    -- Line  Record
	       lp_tilv_rec.amount               := p_subs_adj;
               lp_tilv_rec.kle_id               := l_bill_details_rec.subsidy_cle_id;
               lp_tilv_rec.description          := l_bill_details_rec.til_description;
               lp_tilv_rec.sty_id               := l_bill_details_rec.stream_type_id;
               lp_tilv_rec.line_number          := l_bill_details_rec.line_number;
               lp_tilv_rec.inv_receiv_line_code := G_AR_INV_LINE_CODE;
               lp_tilv_rec.bank_acct_id := l_bill_details_rec.bank_acct_id;
               -- ON-ACCOUNT Credit Memo
               lp_tilv_rec.TIL_ID_REVERSES := NULL;
              -- Assign the line record in tilv_tbl structure
	       lp_tilv_tbl(1) := lp_tilv_rec;
            ---------------------------------------------------------------------------
	    -- Call to Billing Centralized API
	    ---------------------------------------------------------------------------
		okl_internal_billing_pvt.create_billing_trx(p_api_version =>l_api_version,
							    p_init_msg_list =>p_init_msg_list,
							    x_return_status =>  x_return_status,
							    x_msg_count => x_msg_count,
							    x_msg_data => x_msg_data,
							    p_taiv_rec => lp_taiv_rec,
							    p_tilv_tbl => lp_tilv_tbl,
							    p_tldv_tbl => lp_tldv_tbl,
							    x_taiv_rec => lx_taiv_rec,
							    x_tilv_tbl => lx_tilv_tbl,
							    x_tldv_tbl => lx_tldv_tbl);

	       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
             -- Varangan - Billing Enhancement changes - Bug#5874824 - End

              /* --create internal AR transaction header
               OKL_TRX_AR_INVOICES_PUB.insert_trx_ar_invoices (
                            p_api_version       => p_api_version,
                            p_init_msg_list     => p_init_msg_list,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_taiv_rec          => l_taiv_rec,
                            x_taiv_rec          => lx_taiv_rec);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

              --l_tilv_rec.tai_id := lx_taiv_rec.id;

               --create internal AR transaction line
               okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns  (
                                   p_api_version       => p_api_version,
                                   p_init_msg_list     => p_init_msg_list,
                                   x_return_status     => x_return_status,
                                   x_msg_count         => x_msg_count,
                                   x_msg_data          => x_msg_data,
                                   p_tilv_rec          => l_tilv_rec,
                                   x_tilv_rec          => lx_tilv_rec);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               --accounting trx
               l_bpd_acc_rec.id                := lx_tilv_rec.id;
               l_bpd_acc_rec.source_table      := G_AR_LINES_SOURCE;
               -- Create Accounting Distribution
               okl_acc_call_pub.create_acc_trans (
                            p_api_version       => p_api_version,
                            p_init_msg_list     => p_init_msg_list,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_bpd_acc_rec       => l_bpd_acc_rec);

               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;  */

      END on_acc_CM_create;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --function to fetch try_id
    l_pos_try_id := Get_trx_type_id(p_trx_type => G_AR_INV_TRX_TYPE,
                                    p_lang     => 'US');
    If l_pos_try_id is null then
        x_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE (
                             p_app_name          => G_APP_NAME,
                             p_msg_name          => G_REQUIRED_VALUE,
                             p_token1            => G_COL_NAME_TOKEN,
                             p_token1_value      => 'Transaction Type');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_neg_try_id := Get_trx_type_id(p_trx_type => G_AR_CM_TRX_TYPE,
                                    p_lang     => 'US');
    If l_neg_try_id is null then
        x_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.SET_MESSAGE (
                             p_app_name          => G_APP_NAME,
                             p_msg_name          => G_REQUIRED_VALUE,
                             p_token1            => G_COL_NAME_TOKEN,
                             p_token1_value      => 'Transaction Type');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    End If;

    -- STEP 1 : Get the subsidy table of the original contract
    get_contract_subsidy_amount(
                    p_api_version       => p_api_version
                  , p_init_msg_list     => p_init_msg_list
                  , x_return_status     => x_return_status
                  , x_msg_count         => x_msg_count
                  , x_msg_data          => x_msg_data
                  , p_chr_id            => p_orig_chr_id
                  , x_asbv_tbl          => l_orig_asdv_tbl);

    -- check if the l_orig_asdv_tbl is not empty
    IF l_orig_asdv_tbl.count > 0 THEN
      FOR i IN l_orig_asdv_tbl.FIRST .. l_orig_asdv_tbl.LAST
      LOOP
         l_subs_adj := 0;
         -- STEP 2 : Query for the original subsidy line in rebook copy
         OPEN  c_rbk_subs(l_orig_asdv_tbl(i).subsidy_cle_id, p_rbk_chr_id);
           FETCH c_rbk_subs INTO l_rbk_subs_cle_id;

           -- STEP 3 : IF the original subsidy line doesnot exist - Subsidy DELETED
           IF c_rbk_subs%NOTFOUND THEN

            --Added by bkatraga for bug 9276449
            l_rbk_asset_flag := 'N';
            OPEN c_rbk_asset(l_orig_asdv_tbl(i).asset_cle_id);
            FETCH c_rbk_asset INTO l_rbk_asset_flag;
            CLOSE c_rbk_asset;
            IF l_rbk_asset_flag = 'Y' THEN
              --Subsidy was added to the newly created asset during rebook
              --Code to create billing transaction records for the newly added subsidies
              l_new_cnt := l_new_cnt + 1;
              get_subsidy_amount(
                    p_api_version       => p_api_version
                  , p_init_msg_list     => p_init_msg_list
                  , x_return_status     => x_return_status
                  , x_msg_count         => x_msg_count
                  , x_msg_data          => x_msg_data
                  , p_subsidy_cle_id    => l_orig_asdv_tbl(i).subsidy_cle_id
                  , x_asbv_rec          => l_new_asdv_tbl(l_new_cnt));
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

            ELSE
            --end bkatraga

             -- STEP 3 (a) : IF the subsidy billing transaction is still Unprocessed
             --              Cancel transaction
             FOR c_get_bill_stat_rec IN c_get_bill_stat(l_orig_asdv_tbl(i).subsidy_cle_id
                                                      , p_orig_chr_id)
             LOOP
               l_cancel_cnt := l_cancel_cnt + 1;
               l_cancel_taiv_tbl(l_cancel_cnt).ID := c_get_bill_stat_rec.ID;
               l_cancel_taiv_tbl(l_cancel_cnt).DESCRIPTION := c_get_bill_stat_rec.DESCRIPTION;
               l_cancel_taiv_tbl(l_cancel_cnt).TRX_STATUS_CODE := G_CANCEL_STATUS;
               -- sjalasut, added okl_source_billing_trx as 'REBOOK' as rebook process initiates
               -- cancelation
               l_cancel_taiv_tbl(l_cancel_cnt).OKL_SOURCE_BILLING_TRX := G_SOURCE_BILLING_TRX_RBK;
             END LOOP;

             -- STEP 3 (b) : IF the subsidy billing transaction had been processed

              -- need to reverse the entire amount of the deleted subsidy
              l_subs_adj := - l_orig_asdv_tbl(i).amount;

              -- IF Balance exists on the subsidy invoices, then create credit-memos
              -- on the balances
              FOR c_get_inv_balance_rec IN c_get_inv_balance(l_orig_asdv_tbl(i).subsidy_cle_id
                                                           , p_orig_chr_id)
              LOOP

                IF c_get_inv_balance_rec.amount_remaining > 0 THEN
        -- Varangan - Billing Enhancement changes - Bug#5874824 - Begin
                  -- reverse whatever amount is remaining on the invoice of deleted subsidy
                  lp_taiv_rec.amount   := (-1) * c_get_inv_balance_rec.amount_remaining;
                  -- Accordingly change the l_subs_adj so as to track if On-Acc CM needs to be generated
                  l_subs_adj := l_subs_adj + c_get_inv_balance_rec.amount_remaining;

                  lp_taiv_rec.khr_id   := c_get_inv_balance_rec.khr_id;
                  lp_taiv_rec.description      := 'Rebook Credit - '||c_get_inv_balance_rec.tai_description;
                  lp_taiv_rec.currency_code    := c_get_inv_balance_rec.currency_code;
                  lp_taiv_rec.date_invoiced    := p_rebook_date; --check whether it is ok to give this
                  lp_taiv_rec.ibt_id           := c_get_inv_balance_rec.cust_acct_site_id;
                  lp_taiv_rec.ixx_id           := c_get_inv_balance_rec.cust_acct_id;
                  lp_taiv_rec.irt_id           := c_get_inv_balance_rec.payment_term_id;
                  lp_taiv_rec.irm_id           := c_get_inv_balance_rec.payment_method_id;
                  lp_taiv_rec.try_id           := l_neg_try_id;
                  lp_taiv_rec.trx_status_code  := G_SUBMIT_STATUS;
                  lp_taiv_rec.date_entered     := SYSDATE;
                  lp_taiv_rec.OKL_SOURCE_BILLING_TRX := G_SOURCE_BILLING_TRX_RBK;
		  --tilv_record
                   --l_tilv_rec.tai_id               := lx_taiv_rec.id;
                  lp_tilv_rec.amount               := (-1) * c_get_inv_balance_rec.amount_remaining;
                  lp_tilv_rec.kle_id               := c_get_inv_balance_rec.subsidy_cle_id;
                  lp_tilv_rec.description          := 'Rebook Credit - '||c_get_inv_balance_rec.til_description;
                  lp_tilv_rec.sty_id               := c_get_inv_balance_rec.stream_type_id;
                  lp_tilv_rec.line_number          := c_get_inv_balance_rec.line_number;
                  lp_tilv_rec.inv_receiv_line_code := G_AR_INV_LINE_CODE;
                  lp_tilv_rec.til_id_reverses      := c_get_inv_balance_rec.til_id_reverses;
                  lp_tilv_rec.bank_acct_id      := c_get_inv_balance_rec.bank_acct_id;

	          lp_tilv_tbl(1) := lp_tilv_rec; -- Assign the line record in tilv_tbl structure

		  ---------------------------------------------------------------------------
	          -- Call to Billing Centralized API
	          ---------------------------------------------------------------------------
		okl_internal_billing_pvt.create_billing_trx(p_api_version =>l_api_version,
							    p_init_msg_list =>p_init_msg_list,
							    x_return_status =>  x_return_status,
							    x_msg_count => x_msg_count,
							    x_msg_data => x_msg_data,
							    p_taiv_rec => lp_taiv_rec,
							    p_tilv_tbl => lp_tilv_tbl,
							    p_tldv_tbl => lp_tldv_tbl,
							    x_taiv_rec => lx_taiv_rec,
							    x_tilv_tbl => lx_tilv_tbl,
							    x_tldv_tbl => lx_tldv_tbl);

	       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               -- Varangan - Billing Enhancement changes - Bug#5874824 - End

                 /* Commented the existing Billing call
		 --create internal AR transaction header
                  OKL_TRX_AR_INVOICES_PUB.insert_trx_ar_invoices (
                               p_api_version       => p_api_version,
                               p_init_msg_list     => p_init_msg_list,
                               x_return_status     => x_return_status,
                               x_msg_count         => x_msg_count,
                               x_msg_data          => x_msg_data,
                               p_taiv_rec          => l_taiv_rec,
                               x_taiv_rec          => lx_taiv_rec);

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

                  --tilv_record
                  l_tilv_rec.tai_id               := lx_taiv_rec.id;
                  l_tilv_rec.amount               := (-1) * c_get_inv_balance_rec.amount_remaining;
                  l_tilv_rec.kle_id               := c_get_inv_balance_rec.subsidy_cle_id;
                  l_tilv_rec.description          := 'Rebook Credit - '||c_get_inv_balance_rec.til_description;
                  l_tilv_rec.sty_id               := c_get_inv_balance_rec.stream_type_id;
                  l_tilv_rec.line_number          := c_get_inv_balance_rec.line_number;
                  l_tilv_rec.inv_receiv_line_code := G_AR_INV_LINE_CODE;
                  l_tilv_rec.til_id_reverses      := c_get_inv_balance_rec.til_id_reverses;
                  l_tilv_rec.bank_acct_id      := c_get_inv_balance_rec.bank_acct_id;

                  --create internal AR transaction line
                  okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns  (
                                      p_api_version       => p_api_version,
                                      p_init_msg_list     => p_init_msg_list,
                                      x_return_status     => x_return_status,
                                      x_msg_count         => x_msg_count,
                                      x_msg_data          => x_msg_data,
                                      p_tilv_rec          => l_tilv_rec,
                                      x_tilv_rec          => lx_tilv_rec);

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

                  --accounting trx
                  l_bpd_acc_rec.id                := lx_tilv_rec.id;
                  l_bpd_acc_rec.source_table      := G_AR_LINES_SOURCE;
                  -- Create Accounting Distribution
                  okl_acc_call_pub.create_acc_trans (
                               p_api_version       => p_api_version,
                               p_init_msg_list     => p_init_msg_list,
                               x_return_status     => x_return_status,
                               x_msg_count         => x_msg_count,
                               x_msg_data          => x_msg_data,
                               p_bpd_acc_rec       => l_bpd_acc_rec);

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;     */   --Commented End

                END IF;  -- end of check for amount_remaining > 0
              END LOOP;  -- end of check for invoice balances

              -- If there is still amount remaining, create on-account credit-memo
              IF l_subs_adj < 0 THEN
                -- Call API to create On-ACC CM
                on_acc_CM_create( p_subsidy_cle_id  =>l_orig_asdv_tbl(i).subsidy_cle_id
                                 , p_chr_id         => p_orig_chr_id
                                 , p_subs_adj       => l_subs_adj
                                 , p_rebook_date    => p_rebook_date);
              END IF; -- end of check for on_acc credit memo creation

            END IF; --Added by bkatraga for bug 9276449

           -- STEP 4 : ELSE IF the original subsidy line exists
           ELSE --else for c_rbk_subs%NOTFOUND

             -- Get the subsidy amount for the rebook copy
             get_subsidy_amount(
                       p_api_version       => p_api_version
                     , p_init_msg_list     => p_init_msg_list
                     , x_return_status     => x_return_status
                     , x_msg_count         => x_msg_count
                     , x_msg_data          => x_msg_data
                     , p_subsidy_cle_id    => l_rbk_subs_cle_id -- rebook subsidy cle id
                     , x_asbv_rec          => l_asbv_rec);

            l_subs_adj :=  l_asbv_rec.amount          -- Subsidy in rebook copy
                            - l_orig_asdv_tbl(i).amount; -- Subsidy in Original KHR
             -- STEP 4 (a) : IF there is decrease in subsidy
             IF (l_subs_adj < 0) THEN

             -- If subsidy billing transaction is still Unprocessed
             -- Cancel transaction
             FOR c_get_bill_stat_rec IN c_get_bill_stat(l_orig_asdv_tbl(i).subsidy_cle_id
                                                      , p_orig_chr_id)
             LOOP
               l_cancel_cnt := l_cancel_cnt + 1;
               l_cancel_taiv_tbl(l_cancel_cnt).ID := c_get_bill_stat_rec.ID;
               l_cancel_taiv_tbl(l_cancel_cnt).DESCRIPTION := c_get_bill_stat_rec.DESCRIPTION;
               l_cancel_taiv_tbl(l_cancel_cnt).TRX_STATUS_CODE := G_CANCEL_STATUS;
               -- sjalasut, added okl_source_billing_trx as 'REBOOK' as rebook process initiates
               -- cancelation
               l_cancel_taiv_tbl(l_cancel_cnt).OKL_SOURCE_BILLING_TRX := G_SOURCE_BILLING_TRX_RBK;
             END LOOP;

             -- If there has been no billing run till now, then on cancellation
             -- create a new record for the new subsidy amount
             OPEN c_chk_billing_done(l_orig_asdv_tbl(i).subsidy_cle_id
                                                      , p_orig_chr_id);
               FETCH c_chk_billing_done INTO l_bill_chk;
             CLOSE c_chk_billing_done;
               IF l_bill_chk <> 'Y' THEN
                 l_subs_adj := 0;
                 l_new_cnt := l_new_cnt + 1;
                 l_new_asdv_tbl(l_new_cnt) := l_orig_asdv_tbl(i);
                 l_new_asdv_tbl(l_new_cnt).amount := l_asbv_rec.amount; -- bill subsidy with new amount
               END IF;

             -- ELSE IF Balance exists on the subsidy invoices, then create credit-memos
             -- on the balances
              FOR c_get_inv_balance_rec IN c_get_inv_balance(l_orig_asdv_tbl(i).subsidy_cle_id
                                                           , p_orig_chr_id)
              LOOP
	      -- Varangan - Billing Enhancement changes - Bug#5874824 - Begin

                IF c_get_inv_balance_rec.amount_remaining > 0 AND l_subs_adj <> 0 THEN
                  IF ( c_get_inv_balance_rec.amount_remaining + l_subs_adj ) >= 0 THEN
                    lp_taiv_rec.amount   := l_subs_adj; -- l_subs_adj is already negative
                    l_subs_adj := 0;
                  ELSE
                    lp_taiv_rec.amount   := (-1) * c_get_inv_balance_rec.amount_remaining;
                    l_subs_adj := l_subs_adj + c_get_inv_balance_rec.amount_remaining;
                  END IF;
                  lp_taiv_rec.khr_id   := c_get_inv_balance_rec.khr_id;
                  lp_taiv_rec.description      := 'Rebook Credit - '||c_get_inv_balance_rec.tai_description;
                  lp_taiv_rec.currency_code    := c_get_inv_balance_rec.currency_code;
                  lp_taiv_rec.date_invoiced    := p_rebook_date; --check whether it is ok to give this
                  lp_taiv_rec.ibt_id           := c_get_inv_balance_rec.cust_acct_site_id;
                  lp_taiv_rec.ixx_id           := c_get_inv_balance_rec.cust_acct_id;
                  lp_taiv_rec.irt_id           := c_get_inv_balance_rec.payment_term_id;
                  lp_taiv_rec.irm_id           := c_get_inv_balance_rec.payment_method_id;
                  lp_taiv_rec.try_id           := l_neg_try_id;
                  lp_taiv_rec.trx_status_code  := G_SUBMIT_STATUS;
                  lp_taiv_rec.date_entered     := SYSDATE;
                  lp_taiv_rec.OKL_SOURCE_BILLING_TRX := G_SOURCE_BILLING_TRX_RBK;

                		 --lp_tilv record
                   -- l_tilv_rec.tai_id               := lx_taiv_rec.id;
                  -- varangan - Bug#5588871 - Modified - Start
                  -- THE TIL record amount should be the same as the TRX record amount
                  lp_tilv_rec.amount               := lp_taiv_rec.amount;
                  -- varangan - Bug#5588871 - Modified - End
                  lp_tilv_rec.kle_id               := c_get_inv_balance_rec.subsidy_cle_id;
                  lp_tilv_rec.description          := 'Rebook Credit - '||c_get_inv_balance_rec.til_description;
                  lp_tilv_rec.sty_id               := c_get_inv_balance_rec.stream_type_id;
                  lp_tilv_rec.line_number          := c_get_inv_balance_rec.line_number;
                  lp_tilv_rec.inv_receiv_line_code := G_AR_INV_LINE_CODE;
                  lp_tilv_rec.til_id_reverses      := c_get_inv_balance_rec.til_id_reverses;
                  lp_tilv_rec.bank_acct_id      := c_get_inv_balance_rec.bank_acct_id;

		  lp_tilv_tbl(1) := lp_tilv_rec; -- Assign the line record in tilv_tbl structure

            ---------------------------------------------------------------------------
	    -- Call to Billing Centralized API
	    ---------------------------------------------------------------------------
		okl_internal_billing_pvt.create_billing_trx(p_api_version =>l_api_version,
							    p_init_msg_list =>p_init_msg_list,
							    x_return_status =>  x_return_status,
							    x_msg_count => x_msg_count,
							    x_msg_data => x_msg_data,
							    p_taiv_rec => lp_taiv_rec,
							    p_tilv_tbl => lp_tilv_tbl,
							    p_tldv_tbl => lp_tldv_tbl,
							    x_taiv_rec => lx_taiv_rec,
							    x_tilv_tbl => lx_tilv_tbl,
							    x_tldv_tbl => lx_tldv_tbl);

	       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
             -- Varangan - Billing Enhancement changes - Bug#5874824 - End

                 /* Commented the existing billing API call
		  --create internal AR transaction header
                  OKL_TRX_AR_INVOICES_PUB.insert_trx_ar_invoices (
                               p_api_version       => p_api_version,
                               p_init_msg_list     => p_init_msg_list,
                               x_return_status     => x_return_status,
                               x_msg_count         => x_msg_count,
                               x_msg_data          => x_msg_data,
                               p_taiv_rec          => l_taiv_rec,
                               x_taiv_rec          => lx_taiv_rec);

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

                  --tilv_record
                  l_tilv_rec.tai_id               := lx_taiv_rec.id;
                  -- varangan - Bug#5588871 - Modified - Start
                  -- THE TIL record amount should be the same as the TRX record amount
                  l_tilv_rec.amount               := l_taiv_rec.amount;
                  -- varangan - Bug#5588871 - Modified - End
                  l_tilv_rec.kle_id               := c_get_inv_balance_rec.subsidy_cle_id;
                  l_tilv_rec.description          := 'Rebook Credit - '||c_get_inv_balance_rec.til_description;
                  l_tilv_rec.sty_id               := c_get_inv_balance_rec.stream_type_id;
                  l_tilv_rec.line_number          := c_get_inv_balance_rec.line_number;
                  l_tilv_rec.inv_receiv_line_code := G_AR_INV_LINE_CODE;
                  l_tilv_rec.til_id_reverses      := c_get_inv_balance_rec.til_id_reverses;
                  l_tilv_rec.bank_acct_id      := c_get_inv_balance_rec.bank_acct_id;

                  --create internal AR transaction line
                  okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns  (
                                      p_api_version       => p_api_version,
                                      p_init_msg_list     => p_init_msg_list,
                                      x_return_status     => x_return_status,
                                      x_msg_count         => x_msg_count,
                                      x_msg_data          => x_msg_data,
                                      p_tilv_rec          => l_tilv_rec,
                                      x_tilv_rec          => lx_tilv_rec);

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

                  --accounting trx
                  l_bpd_acc_rec.id                := lx_tilv_rec.id;
                  l_bpd_acc_rec.source_table      := G_AR_LINES_SOURCE;
                  -- Create Accounting Distribution
                  okl_acc_call_pub.create_acc_trans (
                               p_api_version       => p_api_version,
                               p_init_msg_list     => p_init_msg_list,
                               x_return_status     => x_return_status,
                               x_msg_count         => x_msg_count,
                               x_msg_data          => x_msg_data,
                               p_bpd_acc_rec       => l_bpd_acc_rec);

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;   */


                END IF;  -- end of check for amount_remaining > 0
              END LOOP; -- end of loop over invoice balances

             -- If there is still amount remaining, create an on-account credit-memo
             IF (l_subs_adj < 0) THEN
                -- Call API to create On-ACC CM
                on_acc_CM_create( p_subsidy_cle_id  =>l_orig_asdv_tbl(i).subsidy_cle_id
                                 , p_chr_id         => p_orig_chr_id
                                 , p_subs_adj       => l_subs_adj
                                 , p_rebook_date    => p_rebook_date);
             END IF; -- end of on_account credit memo creation

             -- STEP 4 (b) : IF there is increase in subsidy
             ELSIF (l_subs_adj > 0) THEN
               -- If subsidy billing transaction is still Unprocessed
               -- Cancel transaction
               FOR c_get_bill_stat_rec IN c_get_bill_stat(l_orig_asdv_tbl(i).subsidy_cle_id
                                                        , p_orig_chr_id)
               LOOP
                 l_cancel_cnt := l_cancel_cnt + 1;
                 l_cancel_taiv_tbl(l_cancel_cnt).ID := c_get_bill_stat_rec.ID;
                 l_cancel_taiv_tbl(l_cancel_cnt).DESCRIPTION := c_get_bill_stat_rec.DESCRIPTION;
                 l_cancel_taiv_tbl(l_cancel_cnt).TRX_STATUS_CODE := G_CANCEL_STATUS;
                 -- sjalasut, added okl_source_billing_trx as 'REBOOK' as rebook process initiates
                 -- cancelation
                 l_cancel_taiv_tbl(l_cancel_cnt).OKL_SOURCE_BILLING_TRX := G_SOURCE_BILLING_TRX_RBK;

               END LOOP;

               -- If there has been no billing run till now, then on cancellation
               -- create a new record for the new subsidy amount
               OPEN c_chk_billing_done(l_orig_asdv_tbl(i).subsidy_cle_id
                                     , p_orig_chr_id);
                 FETCH c_chk_billing_done INTO l_bill_chk;
               CLOSE c_chk_billing_done;
               IF l_bill_chk <> 'Y' THEN
                 l_subs_adj := 0;
                 l_new_cnt := l_new_cnt + 1;
                 l_new_asdv_tbl(l_new_cnt) := l_orig_asdv_tbl(i);
                 l_new_asdv_tbl(l_new_cnt).amount := l_asbv_rec.amount; -- bill subsidy with new amount
                ELSE
                -- Else IF subsidy billing transaction had been processed
                -- add new record to l_new_asdv_tbl table to bill subsidy change amount
                  l_new_cnt := l_new_cnt + 1;
                  l_new_asdv_tbl(l_new_cnt) := l_orig_asdv_tbl(i);
                  l_new_asdv_tbl(l_new_cnt).amount := l_subs_adj; -- bill subsidy with new amount
                END IF;

            END IF; -- end of check for l_subs_adj
          END IF; -- end of c_rbk_subs%NOTFOUND IF loop
        CLOSE c_rbk_subs;
      END LOOP; -- end of loop over the orignal contract subsidies
    END IF; -- end of check l_orig_asdv_tbl is not empty

    -- STEP 5 : Create billing transaction records using l_new_asdv_tbl table
    -- this procedure is called to create billing transaction
    -- records for the new subsidies
    IF l_new_cnt > 0 THEN
      insert_billing_records(
               p_api_version   => p_api_version
             , p_init_msg_list => p_init_msg_list
             , x_return_status => x_return_status
             , x_msg_count     => x_msg_count
             , x_msg_data      => x_msg_data
             , p_chr_id        => p_orig_chr_id
             , p_asdv_tbl      => l_new_asdv_tbl);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
     END IF; -- end of check for l_new_asdv_tbl count


    -- STEP 6 : Cancel the records which were in unprocessed state
    IF l_cancel_cnt > 0 THEN
      --update internal AR transaction headers to mark them canceled
      okl_trx_ar_invoices_pub.update_trx_ar_invoices (
                            p_api_version       => p_api_version,
                            p_init_msg_list     => p_init_msg_list,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_taiv_tbl          => l_cancel_taiv_tbl,
                            x_taiv_tbl          => lx_cancel_taiv_tbl);
    END IF;


    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END rebook_adjustment;
-- varangan - Bug#5474059 - Added - End

-- Start of comments
--
-- Procedure Name	: Create_Billing_Trx
-- Description		: Procedure to create billing transaction for subsidies to
--                        be billed to third party
-- Business Rules	:
-- Parameters		: Contract Id
-- History          :
-- Version		: 1.0
-- End of comments

Procedure Create_Billing_Trx
           (p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  NUMBER) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'CREATE_BILLING_TRX';
    l_api_version          CONSTANT     NUMBER := 1.0;


   l_asdv_tbl      asbv_tbl_type;
   l_asdv_tbl_proc asbv_tbl_type;
   l_chr_id        number;
   i               number;
   j               number;

   --30-Oct-03 avsingh : cursor corrected for same vendor match at
   --model line level
   --cursor to verify theat asset and subsidy vendors are the same
   cursor l_samevend_csr(p_vendor_id    in number,
                         p_asset_cle_id in number,
                         p_chr_id       in number) is
   Select 'Y'
   From   okc_k_party_roles_b cplb,
          okc_k_lines_b       cleb,
          okc_line_styles_b   lseb
   where  cplb.cle_id            = cleb.id
   and    cleb.cle_id            = p_asset_cle_id
   and    lseb.id                = cleb.lse_id
   and    lseb.lty_code          = 'ITEM'
   and    cplb.dnz_chr_id        = p_chr_id
   and    cplb.object1_id1       = to_char(p_vendor_id)
   and    cplb.object1_id2       = '#'
   and    cplb.jtot_object1_code = 'OKX_VENDOR'
   and    cplb.rle_code          = 'OKL_VENDOR';

   l_exists varchar2(1) default 'N';

   l_taiv_rec     okl_trx_ar_invoices_pub.taiv_rec_type;
   l_tilv_rec     okl_txl_ar_inv_lns_pub.tilv_rec_type;
   l_bpd_acc_rec  okl_acc_call_pub.bpd_acc_rec_type;

   lx_taiv_rec     okl_trx_ar_invoices_pub.taiv_rec_type;
   lx_tilv_rec     okl_txl_ar_inv_lns_pub.tilv_rec_type;
   lx_bpd_acc_rec  okl_acc_call_pub.bpd_acc_rec_type;

   l_bill_to_site_use_id OKC_K_HEADERS_B.bill_to_site_use_id%TYPE;
   l_cust_acct_id        OKC_K_PARTY_ROLES_B.cust_acct_id%TYPE;
   l_payment_method_id     Number;
   l_bank_account_id       Number;
   l_inv_reason_for_review Varchar2(450);
   l_inv_review_until_date Date;
   l_cash_appl_rule_id     Number;
   l_invoice_format        Varchar2(450);
   l_review_invoice_yn     Varchar2(450);

   l_cust_acct_site_id     Number;
   l_payment_term_id       Number;

   --cursor to get vendor cpl_id at header level
   cursor l_chrcpl_csr (p_vendor_id in number,
                        p_chr_id    in number) is
   select cplb.id
   from   okc_k_party_roles_b cplb
   where  cplb.chr_id             = p_chr_id
   and    cplb.dnz_chr_id         = p_chr_id
   and    cplb.cle_id is null
   and    cplb.object1_id1        = to_char(p_vendor_id)
   and    cplb.object1_id2        = '#'
   and    cplb.jtot_object1_code  = 'OKX_VENDOR'
   and    cplb.rle_code           = 'OKL_VENDOR';

   l_chr_cpl_id number;

    -- Cursor to find out whether rebook copy
    cursor l_chk_rbk_csr(p_chr_id IN NUMBER) is
    SELECT 'Y',
           chrb.orig_system_id1,
           ktrx.date_transaction_occurred
    FROM   okc_k_headers_b   CHRB,
           okl_trx_contracts ktrx
    WHERE  ktrx.khr_id_new = chrb.id
    AND    ktrx.tsu_code = 'ENTERED'
    AND    ktrx.rbr_code is NOT NULL
    AND    ktrx.tcn_type = 'TRBK'
  --rkuttiya added for 12.1.1 Multi GAAP
    AND    ktrx.representation_type = 'PRIMARY'
  --
    AND    CHRB.id = p_chr_id
    AND    CHRB.ORIG_SYSTEM_SOURCE_CODE = 'OKL_REBOOK';

    l_rebook_cpy       varchar2(1) default 'N';
    l_orig_chr_id      okc_k_headers_b.id%TYPE;
    l_rebook_date      date;

    l_try_id           number;

Begin

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -----------------------------------------------
    --start of input parameter validations
    -----------------------------------------------
    --1. validate chr_id
    If (p_chr_id is NULL) or (p_chr_id = OKL_API.G_MISS_NUM) then
        OKL_API.set_message(
                              p_app_name     => G_APP_NAME,
                              p_msg_name     => G_API_MISSING_PARAMETER,
                              p_token1       => G_API_NAME_TOKEN,
                              p_token1_value => l_api_name,
                              p_token2       => G_MISSING_PARAM_TOKEN,
                              p_token2_value => 'p_chr_id');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Raise OKL_API.G_EXCEPTION_ERROR;
    Elsif (p_chr_id is not NULL) and (p_chr_id <> OKL_API.G_MISS_NUM) then
        validate_chr_id(p_chr_id        => p_chr_id,
                        x_return_status => x_return_status);
        IF x_return_status = OKL_API.G_RET_STS_ERROR then
            OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'p_chr_id');
            Raise OKL_API.G_EXCEPTION_ERROR;
        Elsif x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR then
            Raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        End If;
    End If;
    ---------------------------------------
    --end of input parameter validations
    ---------------------------------------

    --Rebook Processing
    -------------------------------------------
    --find out whether contract is rebook copy :
    -------------------------------------------
    l_rebook_cpy := 'N';
    open l_chk_rbk_csr(p_chr_id => p_chr_id);
    fetch l_chk_rbk_csr into
        l_rebook_cpy,
        l_orig_chr_id,
        l_rebook_date;
    If l_chk_rbk_csr%NOTFOUND then
        Null;
    End If;
    close l_chk_rbk_csr;

    If l_rebook_cpy = 'N' then
        l_chr_id := p_chr_id;
    -- varangan - Bug#5474059 - Modified - Start
    get_contract_subsidy_amount(
    p_api_version    => p_api_version,
    p_init_msg_list  => p_init_msg_list,
    x_return_status  => x_return_status,
    x_msg_count      => x_msg_count,
    x_msg_data       => x_msg_data,
    p_chr_id         => l_chr_id,
    x_asbv_tbl       => l_asdv_tbl);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


       -- Moved code into a separate Procedure and called here
       -- this procedure is called to create billing transaction
       -- records for the new subsidies
       insert_billing_records(
               p_api_version   => p_api_version
             , p_init_msg_list => p_init_msg_list
             , x_return_status => x_return_status
             , x_msg_count     => x_msg_count
             , x_msg_data      => x_msg_data
             , p_chr_id        => l_chr_id
             , p_asdv_tbl      => l_asdv_tbl);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- varangan - Bug#5474059 - Modified - End

    elsif l_rebook_cpy = 'Y' then
        l_chr_id := l_orig_chr_id;
        --call api for reversals
       -- varangan - Bug#5412198 - Commented - Start
       -- Susbidy invoice will no longer be reversed. Instead additional credit memos
       -- or invoices will be generated
       /* Reverse_Billing_Trx
           (p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_chr_id         => l_orig_chr_id,
            p_rebook_date    => l_rebook_date);*/

       -- varangan - Bug#5474059 - Commented - End
       -- varangan - Bug#5474059 - Added - Start
	 rebook_adjustment
           (p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_rbk_chr_id     => p_chr_id,
	    p_orig_chr_id    => l_orig_chr_id,
            p_rebook_date    => l_rebook_date);
       -- varangan - Bug#5474059 - Added - End
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    End If;
    -- End of rebook processing



    l_asdv_tbl.delete;

    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If l_samevend_csr%ISOPEN then
        close l_samevend_csr;
    End If;
    If l_chrcpl_csr%ISOPEN then
        close l_chrcpl_csr;
    End If;
    If l_chk_rbk_csr%ISOPEN then
        close l_chk_rbk_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If l_samevend_csr%ISOPEN then
        close l_samevend_csr;
    End If;
    If l_chrcpl_csr%ISOPEN then
        close l_chrcpl_csr;
    End If;
    If l_chk_rbk_csr%ISOPEN then
        close l_chk_rbk_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_samevend_csr%ISOPEN then
        close l_samevend_csr;
    End If;
    If l_chrcpl_csr%ISOPEN then
        close l_chrcpl_csr;
    End If;
    If l_chk_rbk_csr%ISOPEN then
        close l_chk_rbk_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End Create_Billing_Trx;

--Bug# 3948361
Procedure get_relk_termn_basis
          (p_api_version    IN  NUMBER,
           p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
           x_return_status  OUT NOCOPY VARCHAR2,
           x_msg_count      OUT NOCOPY NUMBER,
           x_msg_data       OUT NOCOPY VARCHAR2,
           p_chr_id         IN  NUMBER,
           p_subsidy_id     IN  NUMBER,
           x_release_basis  OUT NOCOPY varchar2) is

    l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
    l_api_name             CONSTANT     varchar2(30) := 'GET_RELK_TERMN_BASIS';
    l_api_version          CONSTANT     NUMBER := 1.0;

    --cursor to read whether product change or customer change
    cursor l_relk_reason_csr(p_chr_id in number) is
    select tcn.rbr_code
    from   okl_trx_contracts tcn,
           okl_trx_types_tl  ttl
    where  ttl.id        =  tcn.try_id
    and    ttl.language  = 'US'
    and    ttl.name      = 'Release'
    and    tcn.tsu_code  = 'ENTERED'
    and    tcn.tcn_type  = 'MAE'
--rkuttiya added for 12.1.1 Multi GAAP
    and    tcn.representation_type = 'PRIMARY'
--
    and    tcn.khr_id    = p_chr_id;

    l_relk_reason   okl_trx_contracts.rbr_code%TYPE;

    --cursor to read subsidy setup
    cursor l_tsfr_basis_csr (p_subsidy_id in number) is
    select subb.transfer_basis_code
    from   okl_subsidies_b subb
    where  id = p_subsidy_id;

    l_transfer_basis okl_subsidies_b.transfer_basis_code%TYPE;
Begin

  x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    for l_relk_reason_rec in l_relk_reason_csr(p_chr_id => p_chr_id)
    loop
       l_relk_reason := l_relk_reason_rec.rbr_code;
    end loop;

    If l_relk_reason = 'PRODUCT_CHANGE'  then
        x_release_basis := 'ACCELERATE';
    ElsIf l_relk_reason = 'CUSTOMER_CHANGE' then
        --read subsidy setup
        for l_tsfr_basis_rec in l_tsfr_basis_csr(p_subsidy_id => p_subsidy_id)
        loop
            l_transfer_basis := l_tsfr_basis_rec.transfer_basis_code;
        end loop;
        x_release_basis := l_transfer_basis;
    End If;

    If x_release_basis is null then
        x_release_basis := 'ACCELERATE';
    end if;
   OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );

    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');

End get_relk_termn_basis;
END OKL_SUBSIDY_PROCESS_PVT;

/
