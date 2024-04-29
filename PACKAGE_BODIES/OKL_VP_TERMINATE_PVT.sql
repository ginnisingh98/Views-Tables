--------------------------------------------------------
--  DDL for Package Body OKL_VP_TERMINATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_TERMINATE_PVT" as
/*$Header: OKLRTERB.pls 115.9 2003/10/14 00:53:35 manumanu noship $*/

SUBTYPE ter_rec_type is okc_terminate_pub.terminate_in_parameters_rec;

PROCEDURE validate_chr( p_api_version                  IN  NUMBER,
  	                p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
	                p_terminate_in_parameters_rec  IN  ter_rec_type ) IS

CURSOR cur_k_header is
SELECT
sts_code,
contract_number,
contract_number_modifier,
template_yn,
date_terminated,
date_renewed,
application_id,
scs_code
FROM okc_k_headers_b
WHERE id = p_terminate_in_parameters_rec.p_contract_id;


-- Will not need object_version_number this termination is an adverse step. Even if there
--   was a change in between, contract will be terminated.

l_chrv_rec  cur_k_header%rowtype;

CURSOR is_k_locked is
SELECT 'Y'
FROM okc_k_processes v
WHERE v.chr_id = p_terminate_in_parameters_rec.p_contract_id
AND v.in_process_yn='Y';

CURSOR cur_sts_code (l_code varchar2) is
SELECT sts.ste_code,sts.meaning
FROM okc_statuses_v sts
WHERE sts.code = l_code;

CURSOR cur_service_requests is
SELECT 'x'
FROM  okx_incident_statuses_v xis,
okc_k_lines_b cle
WHERE cle.id = xis.contract_service_id
AND cle.dnz_chr_id = p_terminate_in_parameters_rec.p_contract_id
AND xis.status_code in ('OPEN'); -- Impact -- DepENDency on status of service requests

--	CURSOR cur_old_contract is
--	  select contract_number,
--		    contract_number_modifier
--	    from okc_k_headers_b
--	   where chr_id_renewed = p_terminate_in_parameters_rec.p_contract_id;

CURSOR cur_old_contract(p_chr_id number) IS
SELECT k.contract_number,k.contract_number_modifier
FROM okc_k_headers_b K,okc_operation_lines A,
okc_operation_instances B,okc_class_operations C
WHERE  K.id=A.subject_chr_id
AND A.object_chr_id=p_chr_id AND
C.id=B.cop_id and C.opn_code='RENEWAL'
AND B.id=A.oie_id AND A.active_yn='Y' AND
A.subject_cle_id IS NULL AND A.object_cle_id IS NULL;
l_k_num okc_k_headers_v.contract_number%TYPE;
l_k_mod okc_k_headers_v.contract_number_modifier%TYPE;

-- Find out which statuses are valid FOR termination to continue

l_chg_request_in_process VARCHAR2(1);

l_status  varchar2(30);   -- Impact on status
l_meaning  okc_statuses_v.meaning%TYPE;

l_return_status varchar2(1) := okc_api.g_ret_sts_success;
l_api_name  CONSTANT VARCHAR2(30) := 'validate_chr';

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

x_return_status := okc_api.g_ret_sts_success;

-- okc_api.init_msg_list(p_init_msg_list);

OPEN cur_k_header;
FETCH cur_k_header into l_chrv_rec;
CLOSE cur_k_header;

IF l_chrv_rec.template_Yn = 'Y' THEN

  OKC_API.set_message(p_app_name      => g_app_name,
                    p_msg_name      => 'OKL_K_TEMPLATE',
                    p_token1        => 'NUMBER',
                    p_token1_value  => l_chrv_rec.contract_number);

  x_return_status := okc_api.g_ret_sts_error;
  RAISE OKL_API.G_EXCEPTION_ERROR;
END if;

OPEN is_k_locked;
FETCH is_k_locked into l_chg_request_in_process;

IF is_k_locked%FOUND THEN

  OKC_API.set_message(p_app_name      => g_app_name,
                      p_msg_name      => 'OKL_K_LOCKED'
                     );

  x_return_status := okc_api.g_ret_sts_error;
  CLOSE is_k_locked;
  RAISE OKL_API.G_EXCEPTION_ERROR;

END IF;

CLOSE is_k_locked;


l_status:='1';

OPEN cur_sts_code(l_chrv_rec.sts_code);
FETCH cur_sts_code into l_status,l_meaning;
CLOSE cur_sts_code;

IF l_status='1' then
      --
  OKC_API.set_message(p_app_name      => g_app_name,
                      p_msg_name      => 'OKL_INVALID_K_STATUS',
                      p_token1        => 'STATUS',
                      p_token1_value  => l_chrv_rec.sts_code);

  RAISE OKL_API.G_EXCEPTION_ERROR;

END IF;

IF (l_status NOT IN ('ACTIVE','HOLD','SIGNED')) OR (l_status='HOLD' and l_chrv_rec.sts_code='QA_HOLD')  THEN

  x_return_status := OKC_API.G_RET_STS_ERROR;

  OKC_API.set_message(p_app_name      => g_app_name,
                      p_msg_name      => 'OKL_INVALID_K_STATUS',
                      p_token1        => 'STATUS',
                      p_token1_value  => l_meaning);

  RAISE OKL_API.G_EXCEPTION_ERROR;
ELSIF l_chrv_rec.date_terminated is not null THEN

  x_return_status := OKC_API.G_RET_STS_ERROR;

  OKC_API.set_message(p_app_name      => g_app_name,
                      p_msg_name      => 'OKL_FUTURE_TERMINATED_K',
                      p_token1        => 'NUMBER',
                      p_token1_value  => l_chrv_rec.contract_number );

   RAISE OKL_API.G_EXCEPTION_ERROR;



END IF;
-- Bug 1349841, Use NVL for Perpetual Contracts
IF Nvl(p_terminate_in_parameters_rec.p_orig_end_date,
  p_terminate_in_parameters_rec.p_termination_date + 1) <
  p_terminate_in_parameters_rec.p_termination_date then

  x_return_status := OKC_API.G_RET_STS_ERROR;

  OKC_API.set_message( p_app_name      => g_app_name,
                       p_msg_name      =>'OKL_TRMDATE_MORE_END'
                      );

  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;
OKL_API.END_ACTIVITY(x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data
                    );
EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN

  --   x_return_status := l1_return_status;

  x_return_status := OKL_API.HANDLE_EXCEPTIONS
                            (p_api_name  => l_api_name
                             ,p_pkg_name  => G_PKG_NAME
                             ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                             ,x_msg_count => x_msg_count
                             ,x_msg_data  => x_msg_data
                             ,p_api_type  => '_PVT'
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

END;



FUNCTION is_k_term_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN VARCHAR2 IS

/*p_sts_code is not being used right now as not sure if the refresh from launchpad
  will take place everytime a change happens to a contract or not. That is
  If the status of the contract showing in launchpad would at all times be in sync
  with database.It might not happen due to performance reasons of launchpad. So the current approach.
  But if this sync is assured then  we could use p_sts_code as well*/

    l_sts_code VARCHAR2(100);
    l_cls_code VARCHAR2(100);
    l_template_yn VARCHAR2(10);
    l_code VARCHAR2(100);
    l_app_id okc_k_headers_b.application_id%TYPE;
    l_scs_code okc_k_headers_b.scs_code%TYPE;
    l_k VARCHAR2(255);
    l_mod okc_k_headers_b.contract_number_modifier%TYPE DEFAULT OKC_API.G_MISS_CHAR;
    l_return_value	VARCHAR2(1) := 'Y';
    L1_RETURN_STATUS varchar2(3);

    CURSOR c_chr IS
    SELECT sts_code, template_yn, application_id, scs_code  ,contract_number,
			    contract_number_modifier
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    CURSOR c_sts(p_code IN VARCHAR2) IS
    SELECT ste_code
    FROM   okc_statuses_b
    WHERE  code = p_code;


BEGIN

OPEN c_chr;
FETCH c_chr INTO l_code, l_template_yn, l_app_id, l_scs_code,l_k,l_mod;
CLOSE c_chr;

IF l_template_yn = 'Y' then
  OKC_API.set_message(p_app_name      => g_app_name,
                      p_msg_name      => 'OKL_K_TEMPLATE',
                      p_token1        => 'NUMBER',
                      p_token1_value  => l_k);

  l_return_value :='N';
  return(l_return_value);

END IF;

-- Commented by Murthy on 26-Apr-02
--update allowed checking is not required here for extend agreement
/*IF (OKL_OKC_MIGRATION_A_PVT.update_allowed(p_chr_id) <> 'Y') THEN

  l1_return_status :=OKL_API.G_RET_STS_ERROR;

  OKC_API.set_message(p_app_name      => g_app_name,
                      p_msg_name      => 'OKL_VP_UPDATE_NOT_ALLOWED'
                     );

  RAISE OKL_API.G_EXCEPTION_ERROR;

END IF;
*/

IF (OKL_VENDOR_PROGRAM_PUB.Is_Process_Active(p_chr_id) <> 'N') THEN

  OKC_API.set_message(p_app_name      => g_app_name,
                      p_msg_name      => 'OKL_VP_APPROVAL_PROCESS_ACTV'
	             );

  l_return_value := 'N';
  RETURN(l_return_value);

END IF;

/* Fix for Bug 3104000 */
/*

IF okc_util.Get_All_K_Access_Level(p_application_id => l_app_id,
                                   p_chr_id => p_chr_id,
                                   p_scs_code => l_scs_code) <> 'U' Then
  OKC_API.set_message(p_app_name      => g_app_name,
		      p_msg_name      => 'OKL_NO_UPDATE',
                      p_token1        => 'CHR',
                      p_token1_value  => l_k);
  l_return_value :='N';
  return(l_return_value);
END IF;
*/

RETURN(l_return_value);
END is_k_term_allowed;

PROCEDURE  terminate_contract(p_api_version       IN        NUMBER,
                              p_init_msg_list     IN        VARCHAR2 DEFAULT OKL_API.G_FALSE,
                              x_return_status     OUT       NOCOPY VARCHAR2,
                              x_msg_count         OUT       NOCOPY NUMBER,
                              x_msg_data          OUT       NOCOPY VARCHAR2,
                              p_ter_header_rec      IN     terminate_header_rec_type)

IS

l1_ter_header_rec  ter_rec_type;

l_terminate_allowed varchar2(1);

l_contract_id  number;
l_contract_no varchar2(120);
l_scs_code varchar2(30);
l_sts_code varchar2(30);
l_end_date date;


l_return_value	VARCHAR2(1) := 'N';
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_api_version  NUMBER := 1.0;

l_api_name  CONSTANT VARCHAR2(30) := 'terminate_contract';

l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

l1_return_status VARCHAR2(3);


CURSOR cur_k_header(p_id NUMBER)  IS
SELECT contract_number,scs_code,sts_code,end_date from okc_k_headers_v
WHERE id=p_id;


-- begin of block

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



x_return_status := OKL_API.G_RET_STS_SUCCESS;

l_contract_id :=p_ter_header_rec.p_id;

-- Added by Ajay 25-MAR-2002
   l1_ter_header_rec.p_contract_id := l_contract_id;

l_terminate_allowed :=Okl_Vp_Terminate_Pvt.is_k_term_allowed(l_contract_id,l_sts_code);


IF (l_terminate_allowed = 'Y') THEN

  -- changes made on 6th Nov to do the validations okc is doing inside extend_chr
  -- doing this to customize the messages ie to write okl messages

  Okl_Vp_Terminate_Pvt.validate_chr(p_api_version     	      => l_api_version,
                                    p_init_msg_list   	      => OKC_API.G_FALSE,
                                    x_return_status   	      => l_return_status,
                                    x_msg_count       	      => l_msg_count,
                                    x_msg_data                => l_msg_data,
                                    p_terminate_in_parameters_rec  => l1_ter_header_rec);


  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
--59 lines
-- validate the passed parameters ie end date.

IF ((p_ter_header_rec.p_terminate_date = OKL_API.G_MISS_DATE) OR (p_ter_header_rec.p_terminate_date IS NULL)) THEN

  l1_return_status :=OKL_API.G_RET_STS_ERROR;
  OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_TERM_DT_REQD');
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

OPEN cur_k_header(l_contract_id);
FETCH cur_k_header INTO l_contract_no,l_scs_code,l_sts_code,l_end_date;

IF (cur_k_header%FOUND) THEN


  IF l_end_date <> p_ter_header_rec.p_current_end_date THEN

    l1_return_status :=OKL_API.G_RET_STS_ERROR;
    OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_INV_CUR_END_DATE');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;



  IF (p_ter_header_rec.p_terminate_date <  trunc(sysdate)) THEN


    OKL_API.SET_MESSAGE(p_app_name  => g_app_name,
                        p_msg_name  => 'OKL_INV_TERM_DATE'
                        );


    l1_return_status :=OKL_API.G_RET_STS_ERROR;

    RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;



  l1_ter_header_rec.p_contract_id :=l_contract_id;
  l1_ter_header_rec.p_contract_number :=l_contract_no;
  l1_ter_header_rec. p_orig_end_date  :=l_end_date;
  l1_ter_header_rec.p_termination_date :=p_ter_header_rec.p_terminate_date;
  l1_ter_header_rec. p_termination_reason:=p_ter_header_rec.p_term_reason;

CLOSE cur_k_header;

ELSE
  l1_return_status :=OKL_API.G_RET_STS_ERROR;

  OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                      p_msg_name     => 'OKL_VP_AGREEMENT_NOT_FOUND');

  CLOSE cur_k_header;

  RAISE OKL_API.G_EXCEPTION_ERROR;

END IF;
--59 lines end
  okc_terminate_pub.terminate_chr(p_api_version => l_api_version,
                                  x_return_status => l_return_status,
                                  x_msg_data      => l_msg_data,
                            	  x_msg_count  => l_msg_count,
                            	  p_init_msg_list => OKL_API.G_TRUE,
                    	          p_terminate_in_parameters_rec => l1_ter_header_rec);

  IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
    NULL;
  ELSE
    l1_return_status :=l_return_status;

    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;

ELSE
  l1_return_status :=OKL_API.G_RET_STS_ERROR;
   RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

OKL_API.END_ACTIVITY(x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data
                    );



EXCEPTION

WHEN OKL_API.G_EXCEPTION_ERROR THEN

  x_return_status := OKL_API.HANDLE_EXCEPTIONS(p_api_name  => l_api_name
                                               ,p_pkg_name  => G_PKG_NAME
                                               ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                                               ,x_msg_count => x_msg_count
                                               ,x_msg_data  => x_msg_data
                                               ,p_api_type  => '_PVT'
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

-- end of procedure create_program
END;

END;


/
