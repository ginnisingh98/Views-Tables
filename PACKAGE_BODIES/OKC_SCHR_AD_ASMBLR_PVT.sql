--------------------------------------------------------
--  DDL for Package Body OKC_SCHR_AD_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_SCHR_AD_ASMBLR_PVT" AS
/* $Header: OKCRSARB.pls 120.0 2005/05/25 19:16:22 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE acn_assemble(
  p_api_version       		IN NUMBER,
  p_init_msg_list     		IN VARCHAR2 ,
  x_return_status     		OUT NOCOPY VARCHAR2,
  x_msg_count         		OUT NOCOPY NUMBER,
  x_msg_data          		OUT NOCOPY VARCHAR2,
  p_rtv_id			IN NUMBER,
  p_actual_date			IN DATE)  IS

 l_api_name      CONSTANT VARCHAR2(30) := 'acn_assemble';
 l_api_version   CONSTANT NUMBER := 1.0;
 k               NUMBER := 1;
 l_corrid_rec    okc_aq_pub.corrid_rec_typ;
 l_msg_tbl       okc_aq_pub.msg_tab_typ;
 l_msg_count     number;
 l_msg_data      varchar2(1000);
 l_return_status varchar2(1);
 l_actual_date	 date;

 --Select all the attributes for the scheduled actual date recorded event
 CURSOR elements_csr IS
 SELECT aae.element_name, aae.format_mask
 FROM okc_actions_v acn,okc_action_attributes_v aae
 WHERE acn.id = aae.acn_id
 AND acn.correlation = 'SHR_ADATE_REC' ;

-- The following cursor has been changed by MSENGUPT on 12/08/2001 to replace okc_rules_v to okc_rules_b
 --Select the rule attributes for the time value id
 CURSOR rul_cur(p_rtve_id IN NUMBER) IS
 select rul.id rule_id,
        rul.dnz_chr_id,
        rul.rule_information1 rule_name
 from okc_resolved_timevalues res, okc_rules_b rul
 where res.id = p_rtve_id
 and to_char(res.tve_id) = rul.rule_information2
 and rul.rule_information_category = 'NTN';

 --Select all the Contract attributes for a specific contract id
 CURSOR chr_csr(p_chr_id IN NUMBER) IS
 SELECT khr.id k_id,
	khr.contract_number k_number,
	khr.contract_number_modifier k_nbr_mod,
	cls.cls_code k_class,
	khr.scs_code k_subclass,
	khr.estimated_amount k_estimated_amount,
	khr.sts_code
  FROM   okc_k_headers_b khr,okc_subclasses_b cls
  WHERE khr.id = p_chr_id
  AND khr.scs_code = cls.code;

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

  --The correlation for the scheduled actual date recorded event
  l_corrid_rec.corrid := 'SHR_ADATE_REC' ;
-- check if action is enabled
IF OKC_K_SIGN_ASMBLR_PVT.isActionEnabled(l_corrid_rec.corrid) = 'Y' THEN

  FOR rule_rec in rul_cur(p_rtve_id => p_rtv_id) LOOP
     FOR k1_rec in chr_csr(p_chr_id   => rule_rec.dnz_chr_id) LOOP
		k := 1;
	      --Initialize the table
  	      l_msg_tbl := okc_aq_pvt.msg_tab_typ();
           FOR elements_rec IN elements_csr LOOP
		--Build the elements table
    		IF elements_rec.element_name = 'K_ID' THEN
    			l_msg_tbl.extend;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_id;
    		ELSIF elements_rec.element_name = 'K_NUMBER' THEN
    			l_msg_tbl.extend;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_number;
    		ELSIF elements_rec.element_name = 'K_NBR_MOD' THEN
    			l_msg_tbl.extend;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_nbr_mod;
    		ELSIF elements_rec.element_name = 'K_CLASS' THEN
    			l_msg_tbl.extend;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_class;
   		ELSIF elements_rec.element_name = 'K_SUBCLASS' THEN
    			l_msg_tbl.extend;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_subclass;
         	ELSIF elements_rec.element_name = 'ESTIMATED_AMOUNT' THEN
			l_msg_tbl.extend;
			l_msg_tbl(k).element_name := elements_rec.element_name;
			l_msg_tbl(k).element_value := k1_rec.k_estimated_amount;
		ELSIF elements_rec.element_name = 'K_STATUS_CODE' THEN
			l_msg_tbl.extend;
			l_msg_tbl(k).element_name := elements_rec.element_name;
			l_msg_tbl(k).element_value := k1_rec.sts_code;
		ELSIF elements_rec.element_name = 'RULE_ID' THEN
  			l_msg_tbl.extend;
  			l_msg_tbl(k).element_name    := elements_rec.element_name;
  			l_msg_tbl(k).element_value   := rule_rec.rule_id;
		ELSIF elements_rec.element_name = 'RULE_NAME' THEN
  			l_msg_tbl.extend;
  			l_msg_tbl(k).element_name    := elements_rec.element_name;
  			l_msg_tbl(k).element_value   := rule_rec.rule_name;
		ELSIF elements_rec.element_name = 'ADATE' THEN
  			l_msg_tbl.extend;
  			l_msg_tbl(k).element_name    := elements_rec.element_name;
			IF elements_rec.format_mask IS NOT NULL THEN
				l_actual_date := to_char(p_actual_date, elements_rec.format_mask);
   			ELSE
				l_actual_date := to_char(p_actual_date, 'DD-MON-YY');
			END IF;
  			l_msg_tbl(k).element_value   := l_actual_date;
    		END IF;
		k := k + 1;
		END LOOP;

  -- call OKC_AQ_PVT.send_messages to generate the XML string and put it
  -- on the queue
  OKC_AQ_PUB.send_message(p_api_version     =>1.0
			 ,p_init_msg_list   => 'F'
                         ,x_msg_count       => l_msg_count
                         ,x_msg_data        => l_msg_data
                         ,x_return_status   => l_return_status
                         ,p_corrid_rec      => l_corrid_rec
                         ,p_msg_tab         => l_msg_tbl
                         ,p_queue_name      => okc_aq_pvt.g_event_queue_name);

    IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
	commit;
    ELSIF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    END LOOP;
   END LOOP;
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

END OKC_SCHR_AD_ASMBLR_PVT;

/
