--------------------------------------------------------
--  DDL for Package Body OKL_CONTRACT_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONTRACT_APPROVAL_PVT" AS
/* $Header: OKLRCAVB.pls 120.2 2006/07/14 12:58:27 cdubey noship $ */

G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;



-- Start of comments
-- Procedure Name  : reference_exists
-- Description     : This function checks if there already exists a Program
--                   Template with the same Reference Program Agreement
--                   number.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

-- Fix Bug 3159867

  FUNCTION REFERENCE_EXISTS(p_contract_id IN NUMBER) RETURN VARCHAR2 IS
  	l_id		        NUMBER;
  	l_khr_id		NUMBER;
  	CURSOR khr_id_cur IS
  	SELECT khr_id FROM okl_k_headers_full_v
  	WHERE id = p_contract_id;

  	CURSOR id_cur(p_khr_id IN NUMBER) IS
  	SELECT id FROM okl_k_headers_full_v
  	WHERE khr_id = p_khr_id
  	AND sts_code = 'ACTIVE';

  	l_return_status VARCHAR2(2000) := 'N';
  BEGIN

        OPEN khr_id_cur;
        FETCH khr_id_cur INTO l_khr_id;
        IF khr_id_cur%found THEN

           OPEN id_cur(l_khr_id);
           FETCH id_cur INTO l_id;

           IF id_cur%found THEN
             l_return_status := 'Y';
           END IF;

           CLOSE id_cur;
        END IF;
        CLOSE khr_id_cur;

    return l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      return 'N';

  END;


-- Start of comments
--
-- Procedure Name  : start_process
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE START_PROCESS(p_api_version      IN         NUMBER,
                          p_init_msg_list  IN         VARCHAR2,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2,
                          p_contract_id    IN         NUMBER,
                          p_status         IN         VARCHAR2,
                          p_do_commit      IN         VARCHAR2) IS
cursor pdf_cur is select pdf_id from okc_k_processes where chr_id = p_contract_id;
l_pdf_id varchar2(200);
SUBTYPE chrv_rec_type    IS OKC_CONTRACT_PUB.chrv_rec_type;
l1_header_rec  chrv_rec_type;
l2_header_rec  chrv_rec_type;

l_authoring_org_id NUMBER; --CDUBEY l_authoring_org_id added for MOAC

-- Fix Bug 3159867

CURSOR khr_num IS SELECT contract_number  , authoring_org_id  FROM okc_k_headers_b
  WHERE id = (SELECT khr_id FROM okl_k_headers_full_v
              WHERE id = p_contract_id);
l_khr_number okc_k_headers_b.contract_number%TYPE;

BEGIN
--	  CHECK_FOR_NULL_CONTRACT_ID;
-- If status type is not 'PASSED', do not proceed
  If (p_status <> 'PASSED') Then
    OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_QA_NOT_PASSED');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  End If;
open pdf_cur;
loop
fetch pdf_cur into l_pdf_id;
exit when pdf_cur%notfound;
  null;
end loop;
/*OKC_CONTRACT_APPROVAL_PUB.K_APPROVAL_START(p_api_version,
                                           p_init_msg_list,
                                           x_return_status,
                                           x_msg_count,
                                           x_msg_data,
                                           p_contract_id,
                                           l_pdf_id,
                                           p_do_commit
                                           );
*/


OPEN khr_num;
FETCH khr_num INTO l_khr_number,l_authoring_org_id; --CDUBEY l_authoring_org_id added for MOAC
CLOSE khr_num;

-- Temporary Fix for making Contract active without contract approval process
l1_header_rec.id := p_contract_id;
l1_header_rec.sts_code := 'ACTIVE';
l1_header_rec.org_id :=l_authoring_org_id; --CDUBEY added for MOAC

-- Fix Bug 3159867
IF (reference_exists(p_contract_id) = 'Y') THEN
  OKC_API.set_message(p_app_name      => g_app_name,
                      p_msg_name      => 'OKL_VP_REFERENCE_EXISTS',
                      p_token1        => 'NUMBER',
                      p_token1_value  => l_khr_number);

    x_return_status := okc_api.g_ret_sts_error;
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

OKC_CONTRACT_PUB.update_contract_header(
    p_api_version	=> p_api_version,
    x_return_status	=> x_return_status,
    p_init_msg_list     => OKL_API.G_TRUE,
    x_msg_count		=> x_msg_count,
    x_msg_data		=> x_msg_data,
    p_restricted_update	=> OKL_API.G_FALSE,
    p_chrv_rec		=> l1_header_rec,
    x_chrv_rec		=> l2_header_rec);
IF (x_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
   NULL;
 ELSE
   IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
END IF;

EXCEPTION
WHEN OKL_API.G_EXCEPTION_ERROR THEN
x_return_status := OKL_API.G_RET_STS_ERROR;
/*
  x_return_status := OKL_API.HANDLE_EXCEPTIONS
                     (p_api_name  => l_api_name
                      ,p_pkg_name  => G_PKG_NAME
                      ,p_exc_name  => 'OKL_API.G_RET_STS_ERROR'
                      ,x_msg_count => x_msg_count
                      ,x_msg_data  => x_msg_data
                      ,p_api_type  => '_PVT'
                      );

*/
WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
x_return_status := OKL_API.G_RET_STS_ERROR;
/*  x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                     ,g_pkg_name
                     ,'OKL_API.G_RET_STS_ERROR'
                     ,x_msg_count
                     ,x_msg_data
                     ,'_PVT'
                     );

*/
WHEN OTHERS THEN
x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
/*  x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                     ,g_pkg_name
                     ,'OTHERS'
                     ,x_msg_count
                     ,x_msg_data
                     ,'_PVT'
                     );
*/
END;
-- Start of comments
--
-- Procedure Name  : stop_process
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE STOP_PROCESS(p_api_version IN NUMBER,
                       p_init_msg_list IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2,
                       p_contract_id IN NUMBER,
                       p_do_commit IN VARCHAR2)  IS
begin
--	  CHECK_FOR_NULL_CONTRACT_ID;
okc_contract_approval_pub.k_approval_stop(p_api_version,
                                     p_init_msg_list,
                                     x_return_status,
                                     x_msg_count,
                                     x_msg_data,
	                             p_contract_id,
                                     p_do_commit);
end;
-- Start of comments
--
-- Procedure Name  : monitor_process
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
FUNCTION MONITOR_PROCESS(p_api_version IN number,
                         p_init_msg_list IN varchar2,
                         x_return_status OUT NOCOPY varchar2,
                         x_msg_count OUT NOCOPY number,
                         x_msg_data OUT NOCOPY varchar2,
                         p_contract_id IN NUMBER,
                         p_pdf_id IN NUMBER) RETURN VARCHAR2 IS
  	l_id			NUMBER := p_contract_id;
  	l_pdf_id	NUMBER := p_pdf_id;
  	l_return_status VARCHAR2(2000);
  BEGIN
--	CHECK_FOR_NULL_CONTRACT_ID;
	If (okc_contract_approval_pub.wf_monitor_url(l_id,l_pdf_id,'USER') is null) Then
--	    MAIN.Show_Error_Message('OKC_URL_CANNOT_OPEN');
	    return 'http://';
	End If;
--  	FND_UTILITIES.open_url(okc_contract_approval_pub.wf_monitor_url(l_id,l_pdf_id,'USER'));
  	l_return_status := okc_contract_approval_pub.WF_MONITOR_URL(l_id, l_pdf_id, 'USER');
    return l_return_status;
   EXCEPTION
    WHEN OTHERS THEN
      NULL;
      return 'http://';
    --Show_Error_Message('OKC_URL_CANNOT_OPEN');
  END;
-- Start of comments
--
-- Procedure Name  : populate_active_process
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE populate_active_process(p_api_version IN number,
                          p_init_msg_list IN varchar2,
                          x_return_status OUT NOCOPY varchar2,
                          x_msg_count OUT NOCOPY number,
                          x_msg_data OUT NOCOPY varchar2,
                          p_contract_number IN VARCHAR2,
                          p_contract_number_modifier IN VARCHAR2,
                          x_wf_name OUT NOCOPY VARCHAR2,
                          x_wf_process_name OUT NOCOPY VARCHAR2,
                          x_package_name OUT NOCOPY VARCHAR2,
                          x_procedure_name OUT NOCOPY VARCHAR2,
                          x_usage OUT NOCOPY VARCHAR2,
                          x_activeyn OUT NOCOPY VARCHAR2) IS
  l_name VARCHAR2(150);
  l_wf_name VARCHAR(200);
  CURSOR cur_contract_status IS
  SELECT sts_code FROM okc_k_headers_v WHERE contract_number = p_contract_number
  AND contract_number_modifier = p_contract_number_modifier;
  l_sts_code VARCHAR2(200);

BEGIN
/*OKC_CONTRACT_PUB.Get_Active_Process (p_api_version,
                                     p_init_msg_list,
                                     x_return_status,
                                     x_msg_count,
                                     x_msg_data,
                                     p_contract_number,
                                     p_contract_number_modifier,
                                     x_wf_name,
                                     x_wf_process_name,
                                     x_package_name,
                                     x_procedure_name,
                                     x_usage);
l_wf_name := x_wf_name;
If (x_return_status ='S' and l_wf_name is not null) Then
  x_activeyn := 'Y';
Else
  x_activeyn := 'N';
END IF;
EXCEPTION
  When OTHERS Then
    NULL;
END;
*/

OPEN cur_contract_status;
FETCH cur_contract_status INTO l_sts_code;
IF(cur_contract_status%found) THEN
  NULL;
  CLOSE cur_contract_status;
ELSE
  CLOSE cur_contract_status;
  RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

IF (l_sts_code = 'ACTIVE') THEN
  x_activeyn := 'Y';
ELSE
  x_activeyn := 'N';
END IF;

END;

END; -- Package Body OKL_CONTRACT_APPROVAL_PVT

/
