--------------------------------------------------------
--  DDL for Package Body OKC_KL_EXTD_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_KL_EXTD_ASMBLR_PVT" AS
/* $Header: OKCRKLEB.pls 120.0 2005/05/25 18:34:03 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE acn_assemble(
  p_api_version       IN NUMBER,
  p_init_msg_list     IN VARCHAR2 ,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2,

  p_k_class		IN VARCHAR2,
  p_k_id		IN NUMBER,
  p_kl_end_date		IN DATE,
  p_kl_id		IN NUMBER,
  p_k_number		IN VARCHAR2,
  p_k_nbr_mod		IN VARCHAR2,
  p_k_subclass		IN VARCHAR2,
  p_kl_status_code		IN VARCHAR2,
  p_estimated_amount		IN NUMBER,
  p_new_kl_end_date		IN DATE  )  IS

 l_api_name     CONSTANT VARCHAR2(30) := 'acn_assemble';
 l_api_version   CONSTANT NUMBER := 1.0;
 i               NUMBER := 1;
 l_corrid_rec    okc_aq_pvt.corrid_rec_typ;
 l_msg_tbl       okc_aq_pvt.msg_tab_typ;
 l_msg_count     number;
 l_msg_data      varchar2(1000);
 l_return_status varchar2(1);

 CURSOR cur_corr_csr IS
 SELECT aae.element_name
	   ,aae.format_mask format_mask
   FROM okc_actions_b acn,okc_action_attributes_b aae
  WHERE acn.id = aae.acn_id
    AND acn.correlation = 'KLEXTEND' ;

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

 l_corrid_rec.corrid := 'KLEXTEND' ;

-- check if action is enabled
IF OKC_K_SIGN_ASMBLR_PVT.isActionEnabled(l_corrid_rec.corrid) = 'Y' THEN



l_msg_tbl := okc_aq_pvt.msg_tab_typ();
 FOR corr_rec IN cur_corr_csr
 LOOP

 IF corr_rec.element_name = 'K_CLASS' THEN
  l_msg_tbl.extend;
  l_msg_tbl(i).element_name     := corr_rec.element_name;
  l_msg_tbl(i).element_value    := P_k_class;
 ELSIF corr_rec.element_name = 'K_ID' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  l_msg_tbl(i).element_value   := P_k_id;
 ELSIF corr_rec.element_name = 'KL_END_DATE' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  --l_msg_tbl(i).element_value   := P_kl_end_date;
  IF corr_rec.format_mask IS NOT NULL THEN
       l_msg_tbl(i).element_value := to_char(p_kl_end_date,
		      corr_rec.format_mask);
  ELSE
       l_msg_tbl(i).element_value := to_char(p_kl_end_date,'DD-MON-YY');
  END IF;
 ELSIF corr_rec.element_name = 'KL_ID' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  l_msg_tbl(i).element_value   := P_kl_id;
 ELSIF corr_rec.element_name = 'K_NUMBER' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  l_msg_tbl(i).element_value   := P_k_number;
 ELSIF corr_rec.element_name = 'K_NBR_MOD' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  l_msg_tbl(i).element_value   := P_k_nbr_mod;
 ELSIF corr_rec.element_name = 'K_SUBCLASS' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  l_msg_tbl(i).element_value   := P_k_subclass;
 ELSIF corr_rec.element_name = 'KL_STATUS_CODE' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  l_msg_tbl(i).element_value   := P_kl_status_code;
 ELSIF corr_rec.element_name = 'ESTIMATED_AMOUNT' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  l_msg_tbl(i).element_value   := P_estimated_amount;
 ELSIF corr_rec.element_name = 'NEW_KL_END_DATE' THEN
   l_msg_tbl.extend;
  l_msg_tbl(i).element_name    := corr_rec.element_name;
  --l_msg_tbl(i).element_value   := P_new_kl_end_date;
  IF corr_rec.format_mask IS NOT NULL THEN
       l_msg_tbl(i).element_value := to_char(p_new_kl_end_date,
		      corr_rec.format_mask);
  ELSE
       l_msg_tbl(i).element_value := to_char(p_new_kl_end_date,'DD-MON-YY');
  END IF;
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

END OKC_KL_EXTD_ASMBLR_PVT;

/
