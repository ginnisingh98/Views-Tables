--------------------------------------------------------
--  DDL for Package Body OKL_VP_STS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_STS_PVT" AS
 /*$Header: OKLRSSCB.pls 120.2 2006/07/14 12:27:26 cdubey noship $*/


PROCEDURE get_listof_new_statuses(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ste_code                     IN  VARCHAR2,
    p_sts_code                     IN  VARCHAR2,
    p_start_date                   IN  DATE,
    p_end_date                     IN  DATE,
    x_sts_tbl                      OUT NOCOPY sts_tbl_type) IS


CURSOR cur_get_new_statuses(ste_code VARCHAR2,sts_code VARCHAR2,start_date DATE,end_date DATE) IS
SELECT
S.meaning STATUS,
S.code STATUS_CODE,
decode(S.DEFAULT_YN,'Y','*',' ') DEF,
ST.meaning STATUS_TYPE,
S.ste_code STE_CODE1
FROM
okc_statuses_v S, fnd_lookups ST
WHERE
S.ste_code IN (NVL(p_ste_code,'ENTERED'),decode(p_ste_code,NULL, 'CANCELLED','ENTERED','CANCELLED',
               'ACTIVE','HOLD', 'SIGNED','HOLD', 'HOLD',DECODE(NVL(sign(months_between
              (p_start_date,SYSDATE+1)),1), -1,
              DECODE( NVL(sign(months_between(p_end_date,SYSDATE-1)),
              1),1,'ACTIVE' ,'EXPIRED'),'SIGNED')))
AND SYSDATE BETWEEN S.start_date AND NVL(S.end_date,SYSDATE)
AND ST.lookup_type='OKC_STATUS_TYPE'
AND ST.lookup_code=s.ste_code
AND SYSDATE BETWEEN ST.start_date_active AND
	NVL(ST.end_date_active,SYSDATE)
AND ST.enabled_flag='Y'
AND S.code<>NVL(p_sts_code,'ENTERED')
AND p_sts_code NOT LIKE 'QA%HOLD'
AND S.code NOT LIKE 'QA%HOLD'
AND p_ste_code <> 'CANCELLED'
UNION ALL
SELECT  S.meaning STATUS
       ,S.code STATUS_CODE
       ,DECODE(S.DEFAULT_YN, 'Y', '*', '') DEF
       ,ST.meaning STATUS_TYPE
       ,S.ste_code STE_CODE1
FROM   okc_statuses_v S
       ,fnd_lookups ST
WHERE  S.ste_code IN ('ENTERED', 'CANCELLED')
  AND  SYSDATE BETWEEN S.start_date AND NVL(S.end_date, SYSDATE)
  AND  ST.lookup_type = 'OKC_STATUS_TYPE'
  AND  ST.lookup_code=S.ste_code
  AND  SYSDATE BETWEEN ST.start_date_active AND NVL(ST.end_date_active, SYSDATE)
  AND  ST.enabled_flag = 'Y'
  AND  S.code <> p_sts_code
  AND  p_ste_code ='CANCELLED';

  l_return_status VARCHAR2(1)   :=  OKL_API.G_RET_STS_SUCCESS;
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
  l_sts_count NUMBER := 0;

BEGIN

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  FOR l_sts_rec IN cur_get_new_statuses(p_ste_code,p_sts_code,p_start_date,p_end_date)
  LOOP
    l_sts_count     := l_sts_count + 1 ;
    x_sts_tbl(l_sts_count).status := l_sts_rec.status;
    x_sts_tbl(l_sts_count).status_code :=l_sts_rec.status_code;
  END LOOP;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    IF cur_get_new_statuses%ISOPEN THEN
      CLOSE cur_get_new_statuses;
    END IF;

END get_listof_new_statuses;


PROCEDURE change_agreement_status(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER,
    p_current_sts_code             IN VARCHAR2,
    p_new_sts_code                 IN VARCHAR2) IS

CURSOR cur_get_status(p_id number) IS
SELECT sts_code , authoring_org_id FROM okc_k_headers_v --CDUBEY authoring_org_id added for MOAC
WHERE id=p_id;


l_return_status VARCHAR2(3);
l1_return_status VARCHAR2(1)   :=  OKL_API.G_RET_STS_SUCCESS;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_api_version  NUMBER := 1.0;
l_api_name  CONSTANT VARCHAR2(30) := 'change_agreement_status';
l_database_sts_code     VARCHAR2(30);
l_authoring_org_id      NUMBER; --CDUBEY l_authoring_org_id added for MOAC

SUBTYPE chrv_rec_type IS OKC_CONTRACT_PUB.chrv_rec_type;

l1_header_rec  chrv_rec_type;
l2_header_rec  chrv_rec_type;

BEGIN

  l_return_status := OKL_API.START_ACTIVITY(p_api_name      => l_api_name
                                          ,p_init_msg_list => p_init_msg_list
                                          ,p_api_type      => '_PVT'
                                          ,x_return_status => x_return_status
                                          );
  IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  IF (OKL_OKC_MIGRATION_A_PVT.update_allowed(p_chr_id) <> 'Y') THEN

    l1_return_status :=OKL_API.G_RET_STS_ERROR;

    OKC_API.set_message(p_app_name      => g_app_name,
                        p_msg_name      => 'OKL_VP_UPDATE_NOT_ALLOWED'
                       );

    RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;
  IF (p_new_sts_code NOT IN  ('ABANDONED','PASSED','INCOMPLETE') OR
       -- Manu 11-Jul-2005. Added Status INCOMPLETE --
       (p_current_sts_code NOT IN ('NEW','PENDING','PASSED','INCOMPLETE'))) THEN
    OKC_API.set_message(p_app_name      => g_app_name,
                        p_msg_name      => 'OKL_INVALID_CHANGE_STS'
                       );
    RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSE
    IF (p_current_sts_code = 'PENDING')  THEN
      OKL_CONTRACT_APPROVAL_PUB.STOP_PROCESS(p_api_version,
                         p_init_msg_list,
                         x_return_status,
                         x_msg_count,
                         x_msg_data,
                         p_chr_id,
                         'Y');
      IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
  END IF;

  IF (OKL_VENDOR_PROGRAM_PUB.is_process_active(p_chr_id) <> 'N') THEN

    OKC_API.set_message(p_app_name      => g_app_name,
                        p_msg_name      => 'OKL_VP_APPROVAL_PROCESS_ACTV'
                       );
    RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;

  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  OPEN cur_get_status(p_chr_id);
  FETCH cur_get_status INTO l_database_sts_code,l_authoring_org_id; --CDUBEY l_authoring_org_id added for MOAC

  IF(cur_get_status%FOUND) THEN
    CLOSE cur_get_status;
  ELSE
    l1_return_status :=okl_api.g_ret_sts_error;
    close cur_get_status;
    OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_VP_AGREEMENT_NOT_FOUND');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;


  l1_header_rec.id       :=p_chr_id;
  l1_header_rec.sts_code :=p_new_sts_code;
  l1_header_rec.org_id   :=l_authoring_org_id; --CDUBEY added for MOAC


  IF(p_current_sts_code=l_database_sts_code) THEN
    OKC_CONTRACT_PUB.update_contract_header(p_api_version	  => l_api_version,
                                            x_return_status	  => l_return_status,
                                            p_init_msg_list     => OKL_API.G_TRUE,
                                            x_msg_count	  => l_msg_count,
                                            x_msg_data	  => l_msg_data,
                                            p_restricted_update => OKL_API.G_FALSE,
                                            p_chrv_rec	  => l1_header_rec,
                                            x_chrv_rec	  => l2_header_rec);

    IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
      NULL;
    ELSE
      l1_return_status := l_return_status;
      IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
  ELSE

    l1_return_status :=okl_api.g_ret_sts_error;

    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                      p_msg_name     => 'OKL_VP_INVALID_CURRENT_STATUS');
    RAISE  OKL_API.G_EXCEPTION_ERROR;
  END IF;

 OKL_API.END_ACTIVITY(x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data
                    );

EXCEPTION

WHEN OKL_API.G_EXCEPTION_ERROR THEN

  x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                             ,g_pkg_name
                             ,'OKL_API.G_RET_STS_ERROR'
                             ,x_msg_count
                             ,x_msg_data
                             ,'_PVT'
                             );


WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

  x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                             ,g_pkg_name
                             ,'OKL_API.G_RET_STS_ERROR'
                             ,x_msg_count
                             ,x_msg_data
                             ,'_PVT'
                             );

WHEN OTHERS THEN

  x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                             ,g_pkg_name
                             ,'OTHERS'
                             ,x_msg_count
                             ,x_msg_data
                             ,'_PVT'
                             );


END change_agreement_status;


END OKL_VP_STS_PVT;

/
