--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_STATUS_PVT" as
/* $Header: OKLRSTKB.pls 120.9.12010000.2 2008/10/01 22:45:32 rkuttiya ship $ */

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
--
  G_MISSING_CONTRACT    CONSTANT Varchar2(200)  := 'OKL_LLA_CONTRACT_NOT_FOUND';
  G_CONTRACT_ID_TOKEN     CONSTANT Varchar2(30) := 'CONTRACT_ID';
------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION             CONSTANT  NUMBER      := 1.0;
  G_SCOPE                   CONSTANT  VARCHAR2(4) := '_PVT';
  G_BULK_BATCH_SIZE         CONSTANT NUMBER := 10000;

  TYPE clev_tbl_id_type IS TABLE OF OKC_K_LINES_B.ID%TYPE INDEX BY BINARY_INTEGER;
  TYPE clev_tbl_sts_type IS TABLE OF OKC_K_LINES_B.STS_CODE%TYPE INDEX BY BINARY_INTEGER;
  TYPE clev_tbl_start_date_type IS TABLE OF OKC_K_LINES_B.START_DATE%TYPE INDEX BY BINARY_INTEGER;
  TYPE clev_tbl_end_date_type IS TABLE OF OKC_K_LINES_B.END_DATE%TYPE INDEX BY BINARY_INTEGER;
  TYPE clev_tbl_currency_code_type IS TABLE OF OKC_K_LINES_B.CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER;

 -- GLOBAL VARIABLES
-----------------------------------------------------------------------------------



  function areStreamsRequested(p_chr_id NUMBER) RETURN VARCHAR2 is

     l_areStreamsReq    VARCHAR2(2) := OKL_API.G_FALSE;
     l_areStreamsReqRec VARCHAR2(1) := 'N';

     cursor stm_csr( chrId NUMBER ) is
     select 'Y'
     from   dual
     where  exists (
            select 'X' from okl_trx_contracts ktx
            where ktx.KHR_ID = chrId
                 and UPPER(ktx.TSU_CODE) = 'WORKING'
                 --rkuttiya added for 12.1.1 Multi GAAP
                 and ktx.representation_type = 'PRIMARY'
                 --
                 and UPPER(ktx.TCN_TYPE) = 'YIELDS');

  BEGIN

/*
      open  stm_csr( p_chr_id);
      fetch stm_csr into l_areStreamsReqRec;
      close stm_csr;

      if ( l_areStreamsReqRec = 'Y' ) then
          l_areStreamsReq := OKL_API.G_TRUE;
          okl_api.set_message(
                   p_app_name => G_APP_NAME,
                   p_msg_name => OKL_CONTRACT_STATUS_PUB.G_STRMS_IN_PROGRESS);
      end if;


*/
      NULL;
      return l_areStreamsReq;

  END areStreamsRequested;

  Procedure get_loan_status( p_chr_id     IN  NUMBER,
                             p_event      IN  VARCHAR2,
                             okl_status   IN  VARCHAR2,
                             okc_status   IN  VARCHAR2,
                             x_PassStatus OUT NOCOPY  VARCHAR2,
                             x_FailStatus OUT NOCOPY  VARCHAR2,
                             isAllowed    OUT NOCOPY BOOLEAN) IS

    --Bug# 4502754
    --cursor to check for vendor program template
    CURSOR l_chk_template_csr (p_chr_id IN Number) IS
    SELECT chr.template_yn,
           khr.template_type_code
    FROM   okc_k_headers_b chr,
           okl_k_headers khr
    WHERE  chr.id = p_chr_id
    AND    chr.id = khr.id;

    l_chk_template_rec l_chk_template_csr%ROWTYPE;

  BEGIN

      x_PassStatus := NULL;
      x_FailStatus := NULL;
      isAllowed := FALSE;

      --Bug# 4502754
      OPEN l_chk_template_csr(p_chr_id => p_chr_id);
      FETCH l_chk_template_csr INTO l_chk_template_rec;
      CLOSE l_chk_template_csr;

      IF ( p_event = G_K_NEW ) THEN
          x_PassStatus := 'NEW';
          x_FailStatus :=  NULL;
          isAllowed := TRUE;
      ELSIF ( p_event = G_K_EDIT ) THEN
          if( (okc_status = 'ENTERED') OR
              (okc_status = 'SIGNED') OR
              (okc_status = 'ACTIVE') ) then

            if(( okl_status = 'PASSED' ) AND
               (areStreamsRequested( p_chr_id ) = OKL_API.G_TRUE )) then
                return;
            end if;

            x_PassStatus := 'INCOMPLETE';
            x_FailStatus := NULL;
            isAllowed := TRUE;

          end if;
      ELSIF ( p_event = G_K_QACHECK ) THEN
          if((okc_status='ENTERED' OR okc_status='SIGNED') AND
             (okl_status='NEW' OR okl_status='PASSED' OR okl_status='INCOMPLETE') )then
              x_PassStatus := 'PASSED';
              x_FailStatus := 'INCOMPLETE';
              isAllowed := TRUE;
          end if;
      ELSIF ( p_event = G_K_STRMGEN ) THEN
          if( okc_status='ENTERED'
               AND (okl_status='PASSED'  OR okl_status='COMPLETE')
               AND (areStreamsRequested(p_chr_id) = OKL_API.G_FALSE)) then
              x_PassStatus := 'COMPLETE';
              x_FailStatus := 'PASSED';
              isAllowed := TRUE;
          end if;
      ELSIF ( p_event = G_K_JOURNAL ) THEN
          if(okc_status='ENTERED' AND okl_status='COMPLETE') then
              x_PassStatus := 'COMPLETE';
              x_FailStatus := 'PASSED';
              isAllowed := TRUE;
          end if;
      ELSIF ( p_event = G_K_SUBMIT4APPRVL ) THEN

        --Bug# 4502754
        -- For Vendor Program Template, allow Submit for
        -- Approval event when the template status is PASSED

        if (l_chk_template_rec.template_yn = 'Y' AND
           --Bug# 4874338
            nvl(l_chk_template_rec.template_type_code,okl_api.g_miss_char) in ('PROGRAM','LEASEAPP')) THEN
          if(okc_status='ENTERED' AND okl_status='PASSED') then
              x_PassStatus := 'PENDING_APPROVAL';
              x_FailStatus := 'PASSED';
              isAllowed := TRUE;
          end if;
        else
          if(okc_status='ENTERED' AND okl_status='COMPLETE') then
              x_PassStatus := 'PENDING_APPROVAL';
              x_FailStatus := 'COMPLETE';
              isAllowed := TRUE;
          end if;
        end if;
      ELSIF ( p_event = G_K_APPROVAL ) THEN
          if(okc_status='SIGNED' AND okl_status='PENDING_APPROVAL') then
              x_PassStatus := 'APPROVED';
              x_FailStatus := 'PENDING_APPROVAL';
              isAllowed := TRUE;
          end if;
      ELSIF ( p_event = G_K_ACTIVATE ) THEN
          if(okc_status='SIGNED' AND okl_status='APPROVED') then
              x_PassStatus := 'BOOKED';
              x_FailStatus := 'APPROVED';
              isAllowed := TRUE;
          end if;
      END IF;

  END get_loan_status;

  Procedure get_lease_status(  p_chr_id     IN  NUMBER,
                               p_event      IN  VARCHAR2,
                               okl_status   IN  VARCHAR2,
                               okc_status   IN  VARCHAR2,
                               x_PassStatus OUT NOCOPY  VARCHAR2,
                               x_FailStatus OUT NOCOPY  VARCHAR2,
                               isAllowed    OUT NOCOPY BOOLEAN) IS

  BEGIN

     get_loan_status(p_chr_id,
                     p_event,
                     okl_status,
                     okc_status,
                     x_PassStatus,
                     x_FailStatus,
                     isAllowed);

  END get_lease_status;

  Procedure get_contract_status(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
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
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;


    CURSOR sts_csr( chrId NUMBER)  IS
    select a.ste_code okc_status,
           a.code     okl_status,
           b.template_yn template_yn,
           --Bug# 4502754
           c.template_type_code
    from   okc_statuses_v a,
           okc_k_headers_b b,
           okl_k_headers c
    where  a.code = b.sts_code
           and b.id = c.id
           and b.id = chrId;

    CURSOR chr_csr(p_chr_id OKL_K_HEADERS.KHR_ID%TYPE) IS
    SELECT chr.SCS_CODE class,
           chr.STS_CODE okc_status
    FROM OKC_K_HEADERS_B chr,
         OKL_K_HEADERS khr
    WHERE chr.id = p_chr_id
          AND chr.id = khr.id;

    CURSOR Product_csr (p_contract_id IN NUMBER ) IS
    SELECT pdt.id           product_id
          ,pdt.name         product_name
          ,chr.sts_code     okl_status
    FROM   okl_products_v   pdt
          ,okl_k_headers  khr
          ,okc_k_headers_b  chr
    WHERE  1=1
    AND    khr.id = p_contract_id
    AND    khr.pdt_id = pdt.id
    AND    khr.id = chr.id;

    l_Product_rec Product_csr%ROWTYPE;
    l_chr_rec     chr_csr%ROWTYPE;
    l_sts_rec     sts_csr%ROWTYPE;

    l_okl_status VARCHAR2(100);
    l_okc_status VARCHAR2(100);

  BEGIN



    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_isAllowed  := FALSE;
    x_PassStatus := NULL;
    x_FailStatus := NULL;


--    2. type of contract lease/loan
    OPEN  chr_csr(p_chr_id);
    FETCH chr_csr into l_chr_rec;
    IF chr_csr%NOTFOUND THEN
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    CLOSE chr_csr;

    OPEN  sts_csr(p_chr_id);
    FETCH sts_csr INTO l_sts_rec;
    IF sts_csr%NOTFOUND THEN
      Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_ID');
      CLOSE sts_csr;
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    CLOSE sts_csr;


    l_okc_status := l_sts_rec.okc_status;
    l_okl_status := l_sts_rec.okl_status;


    --Bug# 4502754
    -- Allow Vendor Program Templates to be activated
    IF ((UPPER(l_sts_rec.template_yn) = 'Y') AND
        --Bug# 4874338
        (NVL(l_sts_rec.template_type_code,OKL_API.G_MISS_CHAR) not in ('PROGRAM','LEASEAPP')) AND
        (p_event = G_K_ACTIVATE)) THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      Okl_Api.SET_MESSAGE(G_APP_NAME, OKL_CONTRACT_STATUS_PUB.G_NO_ACTV_TMPCONTRACT);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;


    IF (INSTR( l_chr_rec.class, 'LEASE') > 0) THEN
        -- its a lease
       get_lease_status(p_chr_id,
                        p_event,
                        l_okl_status,
                        l_okc_status,
                        x_PassStatus,
                        x_FailStatus,
                        x_isAllowed );

    ELSIF (INSTR(l_chr_rec.class, 'LOAN') > 0) THEN
       get_loan_status( p_chr_id,
                        p_event,
                        l_okl_status,
                        l_okc_status,
                        x_PassStatus,
                        x_FailStatus,
                        x_isAllowed );
    ELSE
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    if( NOT (x_isAllowed)) then
        x_return_status := OKL_API.G_RET_STS_ERROR;
    End If;

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


  END get_contract_status;

  Procedure update_contract_status(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_khr_status      IN  VARCHAR2,
            p_chr_id          IN  VARCHAR2)  IS

    l_api_name		CONSTANT VARCHAR2(30) := 'UPDATE_CONTRACT_STATUS';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    p_chrv_rec   okl_okc_migration_pvt.chrv_rec_type;
    p_khrv_rec   okl_contract_pub.khrv_rec_type;
    x_chrv_rec   okl_okc_migration_pvt.chrv_rec_type;
    x_khrv_rec   okl_contract_pub.khrv_rec_type;


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


    p_chrv_rec.id := p_chr_id;
    p_chrv_rec.sts_code := p_khr_status;

    p_khrv_rec.id := p_chr_id;

/*
    okl_contract_pub.update_contract_header(
                        p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        OKL_API.G_FALSE,
                        p_chrv_rec,
                        p_khrv_rec,
                        x_chrv_rec,
                        x_khrv_rec);
*/
      okl_okc_migration_pvt.update_contract_header(
                        p_api_version,
                        p_init_msg_list,
                        x_return_status,
                        x_msg_count,
                        x_msg_data,
                        OKL_API.G_FALSE,
                        p_chrv_rec,
                        x_chrv_rec);

    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

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


  END update_contract_status;

--start of comments
--Description : API to cascade contract header status to contrat lines
--              will be called before qa check
--end of comments

Procedure cascade_lease_status_old
            (p_api_version     IN  NUMBER,
             p_init_msg_list   IN  VARCHAR2,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2,
             p_chr_id          IN  NUMBER) IS

l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_api_name			           CONSTANT VARCHAR2(30) := 'CASCADE_LEASE_STATUS';
l_api_version		           CONSTANT NUMBER	:= 1.0;

--cursor to get contract header status
CURSOR khr_sts_csr (p_chr_id IN NUMBER) is
SELECT STS_CODE,
       START_DATE,
       END_DATE,
       CURRENCY_CODE,
       SCS_CODE
FROM   OKC_K_HEADERS_B
WHERE  ID = p_chr_id;

l_khr_sts         OKC_K_HEADERS_B.STS_CODE%TYPE;
l_khr_start_date  OKC_K_HEADERS_B.START_DATE%TYPE;
l_khr_end_date    OKC_K_HEADERS_B.END_DATE%TYPE;
l_khr_currency    OKC_K_HEADERS_B.CURRENCY_CODE%Type;
l_khr_scs_code    OKC_K_HEADERS_B.SCS_CODE%TYPE;

--cursor to get contract line status
CURSOR kle_sts_csr (p_chr_id IN NUMBER) is
SELECT STS_CODE,
       ID,
       START_DATE,
       END_DATE
FROM   OKC_K_LINES_B
WHERE  DNZ_CHR_ID = p_chr_id;

l_kle_sts         OKC_K_LINES_B.STS_CODE%TYPE;
l_kle_id          OKC_K_LINES_B.ID%TYPE;
l_kle_start_date  OKC_K_LINES_B.START_DATE%TYPE;
l_kle_end_date    OKC_K_LINES_B.END_DATE%TYPE;

--cusrsor to get OKC_STATUS check if status not in OKC frozen statuses
CURSOR okc_sts_csr (p_okl_sts IN VARCHAR2) IS
SELECT ste_code
FROM   OKC_STATUSES_B
WHERE  CODE = p_okl_sts
AND    nvl(START_DATE,sysdate) <= sysdate
AND    nvl(END_DATE, sysdate+1) > sysdate;

l_okc_sts  OKC_STATUSES_B.STE_CODE%TYPE;


--------------------------------------------------------------------------------
--Local Procedure to Copy Khr status to kle
--------------------------------------------------------------------------------
PROCEDURE cpy_khr_sts_to_kle(p_api_version      IN NUMBER,
                             p_init_msg_list    IN VARCHAR2,
                             p_kle_id           IN NUMBER,
                             p_sts_code         IN OKC_STATUSES_B.CODE%TYPE,
                             p_kle_start_date   IN DATE,
                             p_khr_start_date   IN DATE,
                             p_kle_end_date     IN DATE,
                             p_khr_end_date     IN DATE,
                             p_currency_code    IN OKC_K_LINES_B.CURRENCY_CODE%TYPE,
                             x_return_status    OUT NOCOPY VARCHAR2,
                             x_msg_count        OUT NOCOPY NUMBER,
                             x_msg_data         OUT NOCOPY VARCHAR2) is

l_start_date OKC_K_LINES_B.START_DATE%TYPE;
l_end_date   OKC_K_LINES_B.END_DATE%TYPE;

l_clev_rec   okl_okc_migration_pvt.clev_rec_type;
x_clev_rec   okl_okc_migration_pvt.clev_rec_type;

Begin
     If  p_kle_start_date is null then
         l_start_date := p_khr_start_date;
     ElsIf p_kle_start_date is not null then
         l_start_date := p_kle_start_date;
     End If;
     ---
     If p_kle_end_date is null then
         l_end_date := p_khr_end_date;
     ElsIf p_kle_end_date is not null then
         l_end_date := p_kle_end_date;
     End If;

     --call update contract line API
     l_clev_rec.id            := p_kle_id;
     l_clev_rec.start_date    := l_start_date;
     l_clev_rec.end_date      := l_end_date;
     l_clev_rec.currency_code := p_currency_code;
     l_clev_rec.sts_code      := p_sts_code;

     OKL_OKC_MIGRATION_PVT. update_contract_line(
            p_api_version   => p_api_version,
            p_init_msg_list => p_init_msg_list,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_clev_rec      => l_clev_rec,
            x_clev_rec      => x_clev_rec);

    Exception
    When OTHERS Then
         x_return_status := OKL_API.G_RET_STS_ERROR;
End cpy_khr_sts_to_kle;
--main
Begin
      --Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PVT',
                                         	   x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --fetch contract status
    OPEN khr_sts_csr (p_chr_id => p_chr_id);
        FETCH khr_sts_csr into
                          l_khr_sts,
                          l_khr_start_date,
                          l_khr_end_date,
                          l_khr_currency,
                          l_khr_scs_code;

        If khr_sts_csr%NOTFOUND Then
           --raise appropriate error
            OKL_API.SET_MESSAGE(p_app_name           =>  g_app_name,
                                p_msg_name           =>  G_MISSING_CONTRACT,
                                p_token1             =>  G_CONTRACT_ID_TOKEN,
                                p_token1_value       =>  to_char(p_chr_id));
            RAISE OKL_API.G_EXCEPTION_ERROR;
        Else
           If l_khr_scs_code = 'LEASE' Then
            --fetch line statuses
            OPEN kle_sts_csr (p_chr_id => p_chr_id);
            Loop
                FETCH kle_sts_csr into l_kle_sts, l_kle_id, l_kle_start_date, l_kle_end_date ;
                Exit When kle_sts_csr%NOTFOUND;
                IF l_kle_sts is not null Then
                    --fetch okc status for line
                    OPEN okc_sts_csr (p_okl_sts => l_kle_sts);
                        FETCH okc_sts_csr into l_okc_sts;
                        If okc_sts_csr%NOTFOUND Then
                            --raise appropriate error !!??
                            -- means invalid sts_code on line let header status get copied for now??
                            -- copy header status on to lines

                            cpy_khr_sts_to_kle(p_api_version    => p_api_version,
                                               p_init_msg_list  => p_init_msg_list,
                                               p_kle_id         => l_kle_id,
                                               p_sts_code       => l_khr_sts,
                                               p_kle_start_date => l_kle_start_date,
                                               p_khr_start_date => l_khr_start_date,
                                               p_kle_end_date   => l_kle_end_date,
                                               p_khr_end_date   => l_khr_end_date,
                                               p_currency_code  => l_khr_currency,
                                               x_return_status  => x_return_status,
                                               x_msg_count      => x_msg_count,
                                               x_msg_data       => x_msg_data);

                            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		                    RAISE OKL_API.G_EXCEPTION_ERROR;
                            END IF;

                        Else
                            --Bug 2522268
                            --If l_okc_sts not in ('HOLD','EXPIRED','TERMINATED','CANCELED') Then
                            If l_okc_sts not in ('HOLD','EXPIRED','TERMINATED','CANCELLED') Then
                               --copy header status on to lines
                               cpy_khr_sts_to_kle(p_api_version    => p_api_version,
                                                  p_init_msg_list  => p_init_msg_list,
                                                  p_kle_id         => l_kle_id,
                                                  p_sts_code       => l_khr_sts,
                                                  p_kle_start_date => l_kle_start_date,
                                                  p_khr_start_date => l_khr_start_date,
                                                  p_kle_end_date   => l_kle_end_date,
                                                  p_khr_end_date   => l_khr_end_date,
                                                  p_currency_code  => l_khr_currency,
                                                  x_return_status  => x_return_status,
                                                  x_msg_count      => x_msg_count,
                                                  x_msg_data       => x_msg_data);

                                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		                        RAISE OKL_API.G_EXCEPTION_ERROR;
                                END IF;
                            -- Bug# 2522268
                            --Elsif l_okc_sts in ('HOLD','EXPIRED','TERMINATED','CANCELED') Then
                            Elsif l_okc_sts in ('HOLD','EXPIRED','TERMINATED','CANCELLED') Then
                                --do not copy heaer status on to lines
                                Null;
                            End If;
                        End If;
                    Close okc_sts_csr;
                Elsif l_kle_sts is null Then
                    --copy header status on to lines
                    cpy_khr_sts_to_kle(p_api_version    => p_api_version,
                                       p_init_msg_list  => p_init_msg_list,
                                       p_kle_id         => l_kle_id,
                                       p_sts_code       => l_khr_sts,
                                       p_kle_start_date => l_kle_start_date,
                                       p_khr_start_date => l_khr_start_date,
                                       p_kle_end_date   => l_kle_end_date,
                                       p_khr_end_date   => l_khr_end_date,
                                       p_currency_code  => l_khr_currency,
                                       x_return_status  => x_return_status,
                                       x_msg_count      => x_msg_count,
                                       x_msg_data       => x_msg_data);

                    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		            RAISE OKL_API.G_EXCEPTION_ERROR;
                    END IF;
                End If; --if kle_sts is not null
            End Loop; --okc_kle_csr
            CLOSE kle_sts_csr;
            End If;---scs_code = 'LEASE'
        End If; --if khr_sts_csr found
    CLOSE khr_sts_csr;
    --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
   EXCEPTION
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

End cascade_lease_status_old;

Procedure cascade_contract_status(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_clev_id_tbl     IN  clev_tbl_id_type,
            p_clev_sts_tbl    IN  clev_tbl_sts_type ,
            p_clev_start_date_tbl    IN  clev_tbl_start_date_type,
            p_clev_end_date_tbl    IN  clev_tbl_end_date_type,
            p_clev_curr_code_tbl    IN  clev_tbl_currency_code_type )
IS
    l_api_name		CONSTANT VARCHAR2(30) := 'CASCADE_CONTRACT_STATUS';
    l_api_version	CONSTANT NUMBER	      := 1;
    l_return_status	VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;
    l_application_id    fnd_application_vl.application_id%type;
    l_last_update_date  okc_k_lines_b.last_update_date%type;
    l_last_updated_by   okc_k_lines_b.last_updated_by%type;
    l_last_update_login okc_k_lines_b.last_update_login%type;
begin
  null;

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

  select application_id into l_application_id
  from   fnd_application_vl
  where  application_short_name = 'OKL';

  l_last_update_date := sysdate;
  l_last_updated_by := fnd_global.user_id;
  l_last_update_login := fnd_global.login_id;

  forall i in p_clev_id_tbl.first..p_clev_id_tbl.last
    update okc_k_lines_b
    set    sts_code = p_clev_sts_tbl(i),
           start_date = p_clev_start_date_tbl(i),
           end_date = p_clev_end_date_tbl(i),
           currency_code = p_clev_curr_code_tbl(i),
           program_application_id = l_application_id,
           program_update_date = sysdate,
           last_update_date = l_last_update_date,
           last_updated_by = l_last_updated_by,
           last_update_login = l_last_update_login
    where  ID = p_clev_id_tbl(i);

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


end;


Procedure cascade_lease_status
            (p_api_version     IN  NUMBER,
             p_init_msg_list   IN  VARCHAR2,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2,
             p_chr_id          IN  NUMBER) IS

l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_api_name			           CONSTANT VARCHAR2(30) := 'CASCADE_LEASE_STATUS';
l_api_version		           CONSTANT NUMBER	:= 1.0;

--cursor to get contract header status
CURSOR khr_sts_csr (p_chr_id IN NUMBER) is
SELECT STS_CODE,
       START_DATE,
       END_DATE,
       CURRENCY_CODE,
       SCS_CODE
FROM   OKC_K_HEADERS_B
WHERE  ID = p_chr_id;

l_khr_sts         OKC_K_HEADERS_B.STS_CODE%TYPE;
l_khr_start_date  OKC_K_HEADERS_B.START_DATE%TYPE;
l_khr_end_date    OKC_K_HEADERS_B.END_DATE%TYPE;
l_khr_currency    OKC_K_HEADERS_B.CURRENCY_CODE%Type;
l_khr_scs_code    OKC_K_HEADERS_B.SCS_CODE%TYPE;

--cursor to get contract line status
CURSOR kle_sts_csr (p_chr_id IN NUMBER) is
SELECT A.STS_CODE,
       A.ID,
       A.START_DATE,
       A.END_DATE
FROM   OKC_K_LINES_B A,
       OKC_STATUSES_B B
WHERE  A.DNZ_CHR_ID = p_chr_id
AND    A.STS_CODE = B.CODE
AND    B.STE_CODE not in ('HOLD','EXPIRED','TERMINATED','CANCELLED');
/* -- Bug 5046462: Performance fix by removing UNION part
UNION
SELECT A.STS_CODE,
       A.ID,
       A.START_DATE,
       A.END_DATE
FROM   OKC_K_LINES_B A
WHERE  A.DNZ_CHR_ID = p_chr_id
AND    NOT EXISTS (select 'x' from OKC_STATUSES_B B where B.CODE = A.STS_CODE);
*/

l_kle_sts         clev_tbl_sts_type;
l_kle_id          clev_tbl_id_type;
l_kle_start_date  clev_tbl_start_date_type;
l_kle_end_date    clev_tbl_end_date_type;

l_clev_id_tbl              clev_tbl_id_type;
l_clev_sts_tbl             clev_tbl_sts_type;
l_clev_start_date_tbl      clev_tbl_start_date_type;
l_clev_end_date_tbl        clev_tbl_end_date_type;
l_clev_currency_code_tbl   clev_tbl_currency_code_type;

l_counter         PLS_INTEGER;

--cusrsor to get OKC_STATUS check if status not in OKC frozen statuses
CURSOR okc_sts_csr (p_okl_sts IN VARCHAR2) IS
SELECT ste_code
FROM   OKC_STATUSES_B
WHERE  CODE = p_okl_sts
AND    nvl(START_DATE,sysdate) <= sysdate
AND    nvl(END_DATE, sysdate+1) > sysdate;

l_okc_sts  OKC_STATUSES_B.STE_CODE%TYPE;


Begin
      --Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PVT',
                                         	   x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --dbms_output.put_line('In cascade_lease_status: Before open khr_sts_csr');
    --fetch contract status
    OPEN khr_sts_csr (p_chr_id => p_chr_id);
        FETCH khr_sts_csr into
                          l_khr_sts,
                          l_khr_start_date,
                          l_khr_end_date,
                          l_khr_currency,
                          l_khr_scs_code;
    --dbms_output.put_line('In cascade_lease_status: After fetch khr_sts_csr');

        If khr_sts_csr%NOTFOUND Then
           --raise appropriate error
            OKL_API.SET_MESSAGE(p_app_name           =>  g_app_name,
                                p_msg_name           =>  G_MISSING_CONTRACT,
                                p_token1             =>  G_CONTRACT_ID_TOKEN,
                                p_token1_value       =>  to_char(p_chr_id));
            RAISE OKL_API.G_EXCEPTION_ERROR;
        Else
           If l_khr_scs_code = 'LEASE' Then
            --fetch line statuses
            OPEN kle_sts_csr (p_chr_id => p_chr_id);
    --dbms_output.put_line('In cascade_lease_status: After open kle_sts_csr');
    --dbms_output.put_line('In cascade_lease_status: p_chr_id= ' || p_chr_id);
            l_counter := 1;
            Loop

                l_kle_sts.DELETE;
                l_kle_id.DELETE;
                l_kle_start_date.DELETE;
                l_kle_end_date.DELETE;

                FETCH kle_sts_csr BULK COLLECT INTO l_kle_sts, l_kle_id, l_kle_start_date, l_kle_end_date LIMIT G_BULK_BATCH_SIZE;
    --dbms_output.put_line('In cascade_lease_status: After fetch kle_sts_csr');
    --dbms_output.put_line('In cascade_lease_status: G_BULK_BATCH_SIZE='||G_BULK_BATCH_SIZE);
    --dbms_output.put_line('In cascade_lease_status: l_kle_sts.COUNT='||l_kle_sts.count);
    --dbms_output.put_line('In cascade_lease_status: l_kle_sts.first='||l_kle_sts.first);
    --dbms_output.put_line('In cascade_lease_status: l_kle_sts.last='||l_kle_sts.last);

                if (l_kle_sts.COUNT > 0) then
                for i in l_kle_sts.first .. l_kle_sts.last LOOP

                  --dbms_output.put_line('Inside LOOP' );
                  --dbms_output.put_line('l_khr_sts=' || l_khr_sts);
                  l_clev_sts_tbl(l_counter) := l_khr_sts;
    --dbms_output.put_line('In cascade_lease_status: After assignment l_khr_sts');
                  l_clev_id_tbl(l_counter) := l_kle_id(i);
    --dbms_output.put_line('In cascade_lease_status: After assignment l_kle_id');

                  If  l_kle_start_date(i) is null then
                      l_clev_start_date_tbl(l_counter) := l_khr_start_date;
                  Else
                      l_clev_start_date_tbl(l_counter) := l_kle_start_date(i);
                  End If;
    --dbms_output.put_line('In cascade_lease_status: After assignment start_date');
                  If  l_kle_end_date(i) is null then
                      l_clev_end_date_tbl(l_counter) := l_khr_end_date;
                  Else
                      l_clev_end_date_tbl(l_counter) := l_kle_end_date(i);
                  End If;
    --dbms_output.put_line('In cascade_lease_status: After assignment end_date');
                  l_clev_currency_code_tbl(l_counter) := l_khr_currency;
    --dbms_output.put_line('In cascade_lease_status: After assignment currency');

                  l_counter := l_counter + 1;
    --dbms_output.put_line('In cascade_lease_status: After assignment');
                end LOOP;
               end if;
                exit when kle_sts_csr%NOTFOUND;
            end loop;

            CLOSE kle_sts_csr;
            --dbms_output.put_line('l_counter=' || l_counter || ' @ ' || to_char(sysdate,'HH24:MI:SS'));
            If (l_clev_id_tbl.COUNT > 0) then
            cascade_contract_status(
                   p_api_version   => p_api_version,
                   p_init_msg_list => p_init_msg_list,
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   p_clev_id_tbl   => l_clev_id_tbl,
                   p_clev_sts_tbl  => l_clev_sts_tbl,
                   p_clev_start_date_tbl  => l_clev_start_date_tbl,
                   p_clev_end_date_tbl    => l_clev_end_date_tbl,
                   p_clev_curr_code_tbl   =>  l_clev_currency_code_tbl );
             End If;

            End If;---scs_code = 'LEASE'
        End If; --if khr_sts_csr found
    CLOSE khr_sts_csr;
    --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
   EXCEPTION
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

End cascade_lease_status;

--start of comments
--Description : API to cascade contract status to contract lines after the
--              user edits a the contract
--end of comments
Procedure cascade_lease_status_edit
            (p_api_version     IN  NUMBER,
             p_init_msg_list   IN  VARCHAR2,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2,
             p_chr_id          IN  NUMBER) IS

l_return_status		           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_api_name			           CONSTANT VARCHAR2(30) := 'CASCADE_LEASE_STATUS_EDIT';
l_api_version		           CONSTANT NUMBER	:= 1.0;

--cursor to get contract header status
CURSOR khr_sts_csr (p_chr_id IN NUMBER) is
SELECT STS_CODE,
       START_DATE,
       END_DATE,
       CURRENCY_CODE,
       SCS_CODE,
       CONTRACT_NUMBER,
       TEMPLATE_YN --Bug#4728470
FROM   OKC_K_HEADERS_B
WHERE  ID = p_chr_id;

l_khr_sts         OKC_K_HEADERS_B.STS_CODE%TYPE;
l_khr_start_date  OKC_K_HEADERS_B.START_DATE%TYPE;
l_khr_end_date    OKC_K_HEADERS_B.END_DATE%TYPE;
l_khr_currency    OKC_K_HEADERS_B.CURRENCY_CODE%Type;
l_khr_scs_code    OKC_K_HEADERS_B.SCS_CODE%Type;
l_khr_contract_number OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;

--Bug#4728470
l_khr_template_yn OKC_K_HEADERS_B.TEMPLATE_YN%TYPE;

--cusrsor to get OKC_STATUS check if status not in OKC frozen statuses
CURSOR okc_sts_csr (p_okl_sts IN VARCHAR2) IS
SELECT ste_code
FROM   OKC_STATUSES_B
WHERE  CODE = p_okl_sts
AND    nvl(START_DATE,sysdate) <= sysdate
AND    nvl(END_DATE, sysdate+1) > sysdate;

l_okc_sts  OKC_STATUSES_B.STE_CODE%TYPE;

l_chrv_rec        okl_okc_migration_pvt.chrv_rec_type;
x_chrv_rec        okl_okc_migration_pvt.chrv_rec_type;

Begin
      --Call OKL_API.START_ACTIVITY
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
	                                           G_PKG_NAME,
	                                           p_init_msg_list,
	                                           l_api_version,
	                                           p_api_version,
	                                           '_PVT',
                                         	   x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      		RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN khr_sts_csr (p_chr_id => p_chr_id);
        FETCH khr_sts_csr into
                          l_khr_sts,
                          l_khr_start_date,
                          l_khr_end_date,
                          l_khr_currency,
                          l_khr_scs_code,
                          l_khr_contract_number,
                          l_khr_template_yn;
        If khr_sts_csr%NOTFOUND Then
            --raise appropriate error
            OKL_API.SET_MESSAGE(p_app_name       =>  g_app_name,
                            p_msg_name           =>  G_MISSING_CONTRACT,
                            p_token1             =>  G_CONTRACT_ID_TOKEN,
                            p_token1_value       =>  to_char(p_chr_id));
            RAISE OKL_API.G_EXCEPTION_ERROR;
        Else
        If l_khr_scs_code = 'LEASE' Then

            --Bug#4728470
            If (NVL(l_khr_template_yn,'N') = 'Y' AND FND_PROFILE.VALUE('OKL_ALLOW_K_TEMPLATE_CREATE') = 'N') THEN
              OKL_API.SET_MESSAGE(p_app_name => g_app_name,
                                  p_msg_name => 'OKL_LLA_TEMPLATE_CREATE');
              RAISE OKL_API.G_EXCEPTION_ERROR;
            End If;

            If l_khr_sts in ('NEW','INCOMPLETE') Then
                --do not update statuses
                Null;

            -- Bug# 3477560 - Do not allow modification when contract status is
            -- PENDING_APPROVAL
            Elsif l_khr_sts = 'PENDING_APPROVAL' then
                OKL_API.SET_MESSAGE(p_app_name  =>  g_app_name,
                            p_msg_name          =>  'OKL_LLA_PENDING_APPROVAL',
                            p_token1            =>  'CONTRACT_NUMBER',
                            p_token1_value      =>  l_khr_contract_number);
                RAISE OKL_API.G_EXCEPTION_ERROR;
            Else
                --get okc statuses
                OPEN okc_sts_csr (p_okl_sts => l_khr_sts);
                    FETCH okc_sts_csr into l_okc_sts;
                    If okc_sts_csr%NOTFOUND Then
                        --raise appropriate error !!??
                        -- means invalid sts_code on line let header status get copied for now??
                        --update the hdr status to 'Incomplete'

                           l_chrv_rec.id        := p_chr_id;
                           l_chrv_rec.sts_code  := 'INCOMPLETE';

                           OKL_OKC_MIGRATION_PVT.update_contract_header(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_chrv_rec      => l_chrv_rec,
                            x_chrv_rec      => x_chrv_rec);

                           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                               RAISE OKL_API.G_EXCEPTION_ERROR;
                           END IF;

                       --cascade the status on to lines

                           cascade_lease_status
                           (p_api_version     => p_api_version,
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

                       -- Update the records in the OKL_BOOK_CONTROLLER_TRX table
                           OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx(
                                         p_api_version     => p_api_version,
                                         p_init_msg_list   => p_init_msg_list,
                                         x_return_status   => x_return_status,
                                         x_msg_count       => x_msg_count,
                                         x_msg_data        => x_msg_data,
                                         p_khr_id          => p_chr_id,
                                         p_prog_short_name => NULL,
                                         p_conc_req_id     => NULL,
                                         p_progress_status => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_PENDING);

                            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                               raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                               raise OKL_API.G_EXCEPTION_ERROR;
                            END IF;

               Else
                     --Bug# 2522268
                     --If l_okc_sts not in ('HOLD','EXPIRED','TERMINATED','CANCELED','ACTIVE') then
                     If l_okc_sts not in ('HOLD','EXPIRED','TERMINATED','CANCELLED','ACTIVE') then

                               --update the hdr status to 'Incomplete'
                               l_chrv_rec.id        := p_chr_id;
                               l_chrv_rec.sts_code  := 'INCOMPLETE';

                                OKL_OKC_MIGRATION_PVT.update_contract_header(
                                 p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 p_chrv_rec      => l_chrv_rec,
                                 x_chrv_rec      => x_chrv_rec);

                                IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                   RAISE OKL_API.G_EXCEPTION_ERROR;
                                END IF;

                            --cascade the status on to lines

                                cascade_lease_status
                                (p_api_version     => p_api_version,
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
                            -- Update the records in the OKL_BOOK_CONTROLLER_TRX table
                                 OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx(
                                               p_api_version     => p_api_version,
                                               p_init_msg_list   => p_init_msg_list,
                                               x_return_status   => x_return_status,
                                               x_msg_count       => x_msg_count,
                                               x_msg_data        => x_msg_data,
                                               p_khr_id          => p_chr_id,
                                               p_prog_short_name => NULL,
                                               p_conc_req_id     => NULL,
                                               p_progress_status => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_PENDING);

                                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                                     raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                                     raise OKL_API.G_EXCEPTION_ERROR;
                                  END IF;

                        --Bug# 2522268
                        --Elsif l_okc_sts in ('HOLD','EXPIRED','TERMINATED','CANCELED','ACTIVE') Then
                        Elsif l_okc_sts in ('HOLD','EXPIRED','TERMINATED','CANCELLED','ACTIVE') Then
                             --do not change hdr sts and do notcopy heaer status on to lines
                             Null;
                        End If;
                    End If;
                Close okc_sts_csr;
        End If;
    End If;
    End If;
    CLOSE khr_sts_csr;
        --Call End Activity
    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
				         x_msg_data		=> x_msg_data);
   EXCEPTION
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

End cascade_lease_status_edit;

End OKL_CONTRACT_STATUS_PVT;

/
