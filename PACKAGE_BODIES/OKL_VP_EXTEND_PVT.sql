--------------------------------------------------------
--  DDL for Package Body OKL_VP_EXTEND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_EXTEND_PVT" AS
/* $Header: OKLREXTB.pls 115.10 2003/10/15 22:45:26 manumanu noship $ */
SUBTYPE extn_rec_type IS okc_extend_pub.extend_in_parameters_rec;

PROCEDURE validate_chr( p_api_version                  IN  NUMBER,
      	                p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                        x_return_status               OUT NOCOPY VARCHAR2,
                        x_msg_count                   OUT NOCOPY NUMBER,
                        x_msg_data                    OUT NOCOPY VARCHAR2,
	                p_extend_in_parameters_rec     IN extn_rec_type
) IS

  CURSOR cur_k_header IS
  SELECT
  sts_code,
  contract_number,
  contract_number_modifier,
  template_yn,
  date_terminated,
  date_renewed,
  end_date
  FROM okc_k_headers_b
  WHERE id = p_extend_in_parameters_rec.p_contract_id;

  CURSOR  is_k_locked is
  SELECT 'Y'
  FROM okc_k_processes v
  WHERE v.chr_id = p_extend_in_parameters_rec.p_contract_id
  AND v.in_process_yn='Y';

  CURSOR cur_status(p_sts_code varchar2) is
  SELECT ste_code
  FROM okc_statuses_b
  WHERE code = p_sts_code;

  CURSOR cur_mean(p_sts_code varchar2) is
  SELECT meaning
  FROM okc_statuses_v
  WHERE code = p_sts_code;

  l_chg_request_in_process  VARCHAR2(1);
  l_status                  VARCHAR2(30);
  l_status_meaning okc_statuses_v.meaning%TYPE;
  l_return_status           VARCHAR2(1)  := OKC_API.g_ret_sts_success;
  l_chr_rec                 cur_k_header%rowtype;
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

  -- OKC_API.init_msg_list(p_init_msg_list);

     OPEN  cur_k_header;
     FETCH cur_k_header into l_chr_rec;
     CLOSE cur_k_header;

/* Templates can not be extended */
   IF l_chr_rec.template_yn = 'Y' THEN

        OKC_API.set_message( p_app_name      => g_app_name,
                             p_msg_name      => 'OKL_K_TEMPLATE',
                             p_token1        => 'NUMBER',
                             p_token1_value  => l_chr_rec.contract_number );

         x_return_status := okc_api.g_ret_sts_error;
         RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

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
   OPEN cur_status(l_chr_rec.sts_code);
   FETCH cur_status into l_status;
   CLOSE cur_status;
   IF l_status='1' THEN
     OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKL_INVALID_K_STATUS',
                          p_token1        => 'STATUS',
                          p_token1_value  => l_chr_rec.sts_code);
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   OPEN cur_mean(l_status);
   FETCH cur_mean into l_status_meaning;
   CLOSE cur_mean;

   IF l_status NOT IN ('ACTIVE','EXPIRED','SIGNED') THEN

     x_return_status := OKC_API.G_RET_STS_ERROR;
     OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKL_INVALID_K_STATUS',
                          p_token1        => 'STATUS',
                          p_token1_value  => l_chr_rec.sts_code);
     RAISE OKL_API.G_EXCEPTION_ERROR;
   ELSIF l_chr_rec.date_terminated IS NOT NULL THEN

     x_return_status := OKC_API.G_RET_STS_ERROR;

     OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKL_FUTURE_TERMINATED_K',
                          p_token1        => 'NUMBER',
                          p_token1_value  => l_chr_rec.contract_number );

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


FUNCTION is_k_extend_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN VARCHAR2 IS


    l_sts_code VARCHAR2(100);
    l_cls_code VARCHAR2(100);
    l_template_yn VARCHAR2(10);
    l_code VARCHAR2(100);
    l_end_date okc_k_headers_b.end_date%TYPE;
    l_app_id okc_k_headers_b.application_id%TYPE;
    l_scs_code okc_k_headers_b.scs_code%TYPE;
    l_k VARCHAR2(255);
    l_mod okc_k_headers_b.contract_number_modifier%TYPE DEFAULT OKC_API.G_MISS_CHAR;
    l_return_value	VARCHAR2(1) := 'Y';


    CURSOR c_chr IS
    SELECT sts_code,template_yn,end_date,application_id,scs_code ,contract_number,
			contract_number_modifier
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    CURSOR c_sts(p_code IN VARCHAR2) IS
    SELECT ste_code
    FROM   okc_statuses_b
    WHERE  code = p_code;

  BEGIN

    OPEN c_chr;
    FETCH c_chr INTO l_code,l_template_yn,l_end_date,l_app_id,l_scs_code,l_k,l_mod;
    CLOSE c_chr;

    IF l_template_yn = 'Y' then
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKL_K_TEMPLATE',
		          p_token1        => 'NUMBER',
			  p_token1_value  => l_k);
      l_return_value := 'N';

      RETURN(l_return_value);
    END IF;

    -- A perpetual cannot be extended further
    IF l_end_date Is Null then
      OKC_API.set_message(p_app_name      => g_app_name,
			  p_msg_name      => 'OKL_NO_PERPETUAL'
                          );
       l_return_value := 'N';
       RETURN(l_return_value);
    END IF;

    -- If there is Update access, do not allow extend
    --  *********** Fix for bug 3104000. ************
    /*****************
    IF OKC_UTIL.get_all_k_access_level(p_application_id => l_app_id,
                                       p_chr_id => p_chr_id,
                                       p_scs_code => l_scs_code) <> 'U' THEN
    OKC_API.set_message(p_app_name      => g_app_name,
                        p_msg_name      => 'OKL_NO_UPDATE',
		        p_token1        => 'CHR',
			p_token1_value  => l_k);

    l_return_value := 'N';
    RETURN(l_return_value);

    END IF;
    *****************/

-- Commented by Murthy on 26-Apr-02
--update allowed checking is not required here for extend agreement
/*  IF (OKL_OKC_MIGRATION_A_PVT.update_allowed(p_chr_id) <> 'Y') THEN

  -- l1_return_status :=OKL_API.G_RET_STS_ERROR;

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

  RETURN(l_return_value);

END is_k_extend_allowed;

PROCEDURE  extend_contract(p_api_version       IN        NUMBER,
                          p_init_msg_list     IN        VARCHAR2 DEFAULT OKL_API.G_FALSE,
                          x_return_status     OUT       NOCOPY VARCHAR2,
                          x_msg_count         OUT       NOCOPY NUMBER,
                          x_msg_data          OUT       NOCOPY VARCHAR2,
                          p_ext_header_rec    IN        extension_header_rec_type)
IS
l_ext_header_rec  extn_rec_type;


l_extend_allowed varchar2(1);


l_contract_id  NUMBER;
l_contract_no VARCHAR2(120);
l_scs_code VARCHAR2(30);
l_sts_code VARCHAR2(30);
l_start_date DATE;
l_end_date  DATE;

l_return_value	VARCHAR2(1) := 'N';
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_api_version  NUMBER := 1.0;

l_api_name  CONSTANT VARCHAR2(30) := 'extend_contract';

l1_return_status VARCHAR2(3);

CURSOR cur_k_header(p_id NUMBER)  IS
SELECT contract_number,scs_code,sts_code,start_date,end_date FROM okc_k_headers_v
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

  l_contract_id := p_ext_header_rec.p_id;

-- Added by Ajay 25-MAR-2002
   l_ext_header_rec.p_contract_id := l_contract_id;

  l_extend_allowed :=okl_vp_extend_pvt.is_k_extend_allowed(l_contract_id,l_sts_code);

  IF (l_extend_allowed ='Y') THEN

  -- changes made on 6th Nov to do the validations okc is doing inside extend_chr
  -- doing this to customize the messages ie to write okl messages

    okl_vp_extend_pvt.validate_chr(p_api_version     	      => l_api_version,
                                 p_init_msg_list   	      => OKC_API.G_FALSE,
                                 x_return_status   	      => l_return_status,
                                 x_msg_count       	      => l_msg_count,
                                 x_msg_data                => l_msg_data,
                                 p_extend_in_parameters_rec => l_ext_header_rec);


     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
--50 lines
  -- Validate the passed parameters
  -- new end date  should be given

   IF ((p_ext_header_rec.p_new_end_date = OKL_API.G_MISS_DATE) OR (p_ext_header_rec.p_new_end_date  IS NULL)) THEN

     l1_return_status :=OKL_API.G_RET_STS_ERROR;
     OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_EXT_DT_REQD');
     RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

  OPEN cur_k_header(l_contract_id);
  FETCH cur_k_header INTO l_contract_no,l_scs_code,l_sts_code,l_start_date,l_end_date;

  IF (cur_k_header%FOUND) THEN

    -- added on 15th Oct
    -- this if condition checks whether end date date displayed has changed by someone
    --  when the user tries to extend the contract and throws the error if it's changed

    IF l_end_date <> p_ext_header_rec.p_current_end_date THEN
      l1_return_status :=OKL_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name => 'OKL_INV_CUR_END_DATE');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF l_end_date >  p_ext_header_rec.p_new_end_date THEN
     l1_return_status :=OKL_API.G_RET_STS_ERROR;
     OKL_API.SET_MESSAGE(p_app_name => g_app_name,p_msg_name =>'OKL_INV_EXT_DATE');
     RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_ext_header_rec.p_contract_id :=l_contract_id;
    l_ext_header_rec.p_contract_number :=l_contract_no;
    l_ext_header_rec.p_orig_start_date :=l_start_date;
    l_ext_header_rec. p_orig_end_date  :=l_end_date;
    l_ext_header_rec. p_end_date :=p_ext_header_rec.p_new_end_date;

    CLOSE cur_k_header;

  ELSE

    l1_return_status :=OKL_API.G_RET_STS_ERROR;
    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => 'OKL_VP_AGREEMENT_NOT_FOUND'
                        );
    CLOSE cur_k_header;

    RAISE OKL_API.G_EXCEPTION_ERROR;

  END IF;
--end 50 lines

     okc_extend_pub.extend_chr(p_api_version => l_api_version,
                               p_init_msg_list => OKL_API.G_TRUE,
                               x_return_status => l_return_status,
                               x_msg_count  => l_msg_count,
                               x_msg_data      => l_msg_data,
                               p_extend_in_parameters_rec => l_ext_header_rec);

     IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
       NULL;
     ELSE
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

END;

/
