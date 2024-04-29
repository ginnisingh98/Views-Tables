--------------------------------------------------------
--  DDL for Package Body OKC_K_STS_CHG_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_STS_CHG_ASMBLR_PVT" AS
/* $Header: OKCRHSCB.pls 120.0 2005/05/25 22:37:46 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
--subtype control_rec_type is okc_util.okc_control_rec_type;

-- action assembler for contract status change action
PROCEDURE acn_assemble(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 ,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_k_id		 IN NUMBER,
  p_k_number		 IN VARCHAR2,
  p_k_nbr_mod		 IN VARCHAR2,
  p_k_cur_sts_code	 IN VARCHAR2,
  p_k_cur_sts_type	 IN VARCHAR2,
  p_k_pre_sts_code	 IN VARCHAR2,
  p_k_pre_sts_type	 IN VARCHAR2,
  p_k_source_system_code IN VARCHAR2
  )  IS

 l_api_name     CONSTANT VARCHAR2(30) := 'acn_assemble';
 l_api_version   CONSTANT NUMBER := 1.0;
 i               NUMBER := 1;
 l_corrid_rec    okc_aq_pvt.corrid_rec_typ;
 l_msg_tbl       okc_aq_pvt.msg_tab_typ;
 l_msg_count     number;
 l_msg_data      varchar2(1000);
 l_return_status varchar2(1);
 l_hstv_rec  	 OKC_K_HISTORY_PVT.hstv_rec_type;
 x_hstv_rec  	 OKC_K_HISTORY_PVT.hstv_rec_type;
 l_version   	 VARCHAR2(255);  --modified for bug 3007067

 CURSOR cur_corr_csr IS
 SELECT aae.element_name
	   ,aae.format_mask format_mask
   FROM okc_actions_b acn,okc_action_attributes_b aae
  WHERE acn.id = aae.acn_id
    AND acn.correlation = 'K_STS_CHANGE' ;


 CURSOR version_csr(p_chr_id NUMBER) IS
    SELECT to_char (major_version)||'.'||to_char(minor_version)
    FROM okc_k_vers_numbers
    WHERE chr_id=p_chr_id;


BEGIN

 l_return_status := OKC_API.START_ACTIVITY
                    (l_api_name
                    ,p_init_msg_list
                    ,'_PROCESS'
                    ,x_return_status);

  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
     RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- To insert record in history tables
  l_hstv_rec.chr_id := p_k_id;
  l_hstv_rec.sts_code_from := p_k_pre_sts_code;
  l_hstv_rec.sts_code_to := p_k_cur_sts_code;
  l_hstv_rec.opn_code := 'STS_CHG';

  open version_csr(p_k_id);
  fetch version_csr into l_version;
  close version_csr;

  l_hstv_rec.contract_version := l_version;

  OKC_K_HISTORY_PUB.create_k_history(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data,
         p_hstv_rec             => l_hstv_rec,
         x_hstv_rec             => x_hstv_rec);

  IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

 l_corrid_rec.corrid := 'K_STS_CHANGE' ;
-- check if action is enabled
IF OKC_K_SIGN_ASMBLR_PVT.isActionEnabled(l_corrid_rec.corrid) = 'Y' THEN
l_msg_tbl := okc_aq_pvt.msg_tab_typ();
 FOR corr_rec IN cur_corr_csr
 LOOP

 IF corr_rec.element_name = 'K_CUR_STS_CODE' THEN
  l_msg_tbl.extend;
  l_msg_tbl(i).element_name     := corr_rec.element_name;
  l_msg_tbl(i).element_value    := p_k_cur_sts_code;
 ELSIF corr_rec.element_name = 'K_CUR_STS_TYPE' THEN
  l_msg_tbl.extend;
  l_msg_tbl(i).element_name     := corr_rec.element_name;
  l_msg_tbl(i).element_value    := p_k_cur_sts_type;
 ELSIF corr_rec.element_name = 'K_ID' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  l_msg_tbl(i).element_value   := p_k_id;
 ELSIF corr_rec.element_name = 'K_NUMBER' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  l_msg_tbl(i).element_value   := p_k_number;
 ELSIF corr_rec.element_name = 'K_NBR_MOD' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  l_msg_tbl(i).element_value   := p_k_nbr_mod;
 ELSIF corr_rec.element_name = 'K_PRE_STS_CODE' THEN
  l_msg_tbl.extend;
  l_msg_tbl(i).element_name     := corr_rec.element_name;
  l_msg_tbl(i).element_value    := p_k_pre_sts_code;
 ELSIF corr_rec.element_name = 'K_PRE_STS_TYPE' THEN
  l_msg_tbl.extend;
  l_msg_tbl(i).element_name     := corr_rec.element_name;
  l_msg_tbl(i).element_value    := p_k_pre_sts_type;
 ELSIF corr_rec.element_name = 'K_SOURCE_SYSTEM_CODE' THEN
  l_msg_tbl.extend;
  l_msg_tbl(i).element_name     := corr_rec.element_name;
  l_msg_tbl(i).element_value    := p_k_source_system_code;
 END IF;

  i := i + 1;
 END LOOP;




  OKC_AQ_PUB.send_message(p_api_version     =>1.0
                         ,x_msg_count       => l_msg_count
                         ,x_msg_data        => l_msg_data
                         ,x_return_status   => l_return_status
                         ,p_corrid_rec      => l_corrid_rec
                         ,p_msg_tab         => l_msg_tbl
                         ,p_queue_name      => okc_aq_pvt.g_event_queue_name);

    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
END IF; -- OKC_K_SIGN_ASMBLR_PVT.isActionEnabled
 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
 WHEN OKC_API.G_EXCEPTION_ERROR THEN
  x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                      'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
 WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
 WHEN OTHERS THEN
  x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
END acn_assemble;

------------------------------------------------------------
-- This will be used for contract status change
------------------------------------------------------------
PROCEDURE acn_assemble(
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2 ,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  p_k_id		 IN NUMBER,
  p_k_number		 IN VARCHAR2,
  p_k_nbr_mod		 IN VARCHAR2,
  p_k_cur_sts_code	 IN VARCHAR2,
  p_k_cur_sts_type	 IN VARCHAR2,
  p_k_pre_sts_code	 IN VARCHAR2,
  p_k_pre_sts_type	 IN VARCHAR2,
  p_k_source_system_code IN VARCHAR2,
  p_control_rec	         IN control_rec_type
  )  IS

 l_api_name     CONSTANT VARCHAR2(30) := 'acn_assemble';
 l_api_version   CONSTANT NUMBER := 1.0;
 i               NUMBER := 1;
 l_corrid_rec    okc_aq_pvt.corrid_rec_typ;
 l_msg_tbl       okc_aq_pvt.msg_tab_typ;
 l_msg_count     number;
 l_msg_data      varchar2(1000);
 l_return_status varchar2(1);
 l_hstv_rec  	 OKC_K_HISTORY_PVT.hstv_rec_type;
 x_hstv_rec  	 OKC_K_HISTORY_PVT.hstv_rec_type;
 l_version   	 VARCHAR2(255); --modified for bug 3007067

 CURSOR cur_corr_csr IS
 SELECT aae.element_name
	   ,aae.format_mask format_mask
   FROM okc_actions_b acn,okc_action_attributes_b aae
  WHERE acn.id = aae.acn_id
    AND acn.correlation = 'K_STS_CHANGE' ;


 CURSOR version_csr(p_chr_id NUMBER) IS
    SELECT to_char (major_version)||'.'||to_char(minor_version)
    FROM okc_k_vers_numbers
    WHERE chr_id=p_chr_id;


BEGIN

 l_return_status := OKC_API.START_ACTIVITY
                    (l_api_name
                    ,p_init_msg_list
                    ,'_PROCESS'
                    ,x_return_status);

  IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
     RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- To insert record in history tables
  l_hstv_rec.chr_id := p_k_id;
  l_hstv_rec.sts_code_from := p_k_pre_sts_code;
  l_hstv_rec.sts_code_to := p_k_cur_sts_code;
  l_hstv_rec.opn_code := 'STS_CHG';
  l_hstv_rec.manual_yn := p_control_rec.flag;
  l_hstv_rec.reason_code := p_control_rec.code;
  l_hstv_rec.comments := p_control_rec.comments;

  open version_csr(p_k_id);
  fetch version_csr into l_version;
  close version_csr;

  l_hstv_rec.contract_version := l_version;

  OKC_K_HISTORY_PUB.create_k_history(
         p_api_version          => p_api_version,
         p_init_msg_list        => p_init_msg_list,
         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data,
         p_hstv_rec             => l_hstv_rec,
         x_hstv_rec             => x_hstv_rec);

  IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

 l_corrid_rec.corrid := 'K_STS_CHANGE' ;
-- check if action is enabled
IF OKC_K_SIGN_ASMBLR_PVT.isActionEnabled(l_corrid_rec.corrid) = 'Y' THEN

l_msg_tbl := okc_aq_pvt.msg_tab_typ();
 FOR corr_rec IN cur_corr_csr
 LOOP

 IF corr_rec.element_name = 'K_CUR_STS_CODE' THEN
  l_msg_tbl.extend;
  l_msg_tbl(i).element_name     := corr_rec.element_name;
  l_msg_tbl(i).element_value    := p_k_cur_sts_code;
 ELSIF corr_rec.element_name = 'K_CUR_STS_TYPE' THEN
  l_msg_tbl.extend;
  l_msg_tbl(i).element_name     := corr_rec.element_name;
  l_msg_tbl(i).element_value    := p_k_cur_sts_type;
 ELSIF corr_rec.element_name = 'K_ID' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  l_msg_tbl(i).element_value   := p_k_id;
 ELSIF corr_rec.element_name = 'K_NUMBER' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  l_msg_tbl(i).element_value   := p_k_number;
 ELSIF corr_rec.element_name = 'K_NBR_MOD' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  l_msg_tbl(i).element_value   := p_k_nbr_mod;
 ELSIF corr_rec.element_name = 'K_PRE_STS_CODE' THEN
  l_msg_tbl.extend;
  l_msg_tbl(i).element_name     := corr_rec.element_name;
  l_msg_tbl(i).element_value    := p_k_pre_sts_code;
 ELSIF corr_rec.element_name = 'K_PRE_STS_TYPE' THEN
  l_msg_tbl.extend;
  l_msg_tbl(i).element_name     := corr_rec.element_name;
  l_msg_tbl(i).element_value    := p_k_pre_sts_type;
 ELSIF corr_rec.element_name = 'K_SOURCE_SYSTEM_CODE' THEN
  l_msg_tbl.extend;
  l_msg_tbl(i).element_name     := corr_rec.element_name;
  l_msg_tbl(i).element_value    := p_k_source_system_code;
 END IF;

  i := i + 1;
 END LOOP;




  OKC_AQ_PUB.send_message(p_api_version     =>1.0
                         ,x_msg_count       => l_msg_count
                         ,x_msg_data        => l_msg_data
                         ,x_return_status   => l_return_status
                         ,p_corrid_rec      => l_corrid_rec
                         ,p_msg_tab         => l_msg_tbl
                         ,p_queue_name      => okc_aq_pvt.g_event_queue_name);

    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

END IF; -- OKC_K_SIGN_ASMBLR_PVT.isActionEnabled
 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
 WHEN OKC_API.G_EXCEPTION_ERROR THEN
  x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                      'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
 WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
 WHEN OTHERS THEN
  x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                        'OTHERS',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
END acn_assemble;

END OKC_K_STS_CHG_ASMBLR_PVT;

/
