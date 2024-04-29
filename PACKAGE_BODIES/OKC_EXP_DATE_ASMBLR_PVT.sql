--------------------------------------------------------
--  DDL for Package Body OKC_EXP_DATE_ASMBLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_EXP_DATE_ASMBLR_PVT" AS
/* $Header: OKCREDAB.pls 120.1 2006/04/05 17:34:10 vjramali noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_package  varchar2(33) := '  OKC_EXP_DATE_ASMBLR_PVT.';

 PROCEDURE exp_date_assemble(
    p_api_version	IN NUMBER,
    p_init_msg_list     IN VARCHAR2 ,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_cnh_id            IN okc_condition_headers_b.id%TYPE,
    p_dnz_chr_id        IN okc_condition_headers_b.dnz_chr_id%TYPE ,
    p_cnh_variance      IN okc_condition_headers_b.cnh_variance%TYPE,
    p_before_after      IN okc_condition_headers_b.before_after%TYPE,
    p_last_rundate      IN okc_condition_headers_b.last_rundate%TYPE) IS


    l_api_name            CONSTANT VARCHAR2(30) := 'exp_date_assemble';
    l_api_version         CONSTANT NUMBER := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    k                     NUMBER;
    l_last_rundate	      DATE;
    l_variance		       okc_condition_headers_b.cnh_variance%TYPE;
    --l_corrid_rec    	  okc_aq_pub.corrid_rec_typ;
    l_msg_tbl       	  okc_aq_pub.msg_tab_typ;
    l_element_name	       okc_action_attributes_b.element_name%TYPE;
    l_element_value	       VARCHAR2(100);
    l_acn_id              NUMBER;

    --Get all the contracts that are expiring from the last rundate
    --of the date assembler concurrent program for a given condition
    --Modified the where clause toavoid the FTS on OKC_K_HEADERS_B

    CURSOR k1_csr(p_chr_id IN NUMBER, p_variance IN NUMBER, p_last_rundate IN DATE)
    IS
    SELECT /*+ leading(khr) use_nl(khr cls) */ khr.id k_id,        -- Bug 5012601 Added hint to avoid FTS
           khr.contract_number k_number,
		 khr.contract_number_modifier k_nbr_mod,
		 khr.end_date k_expire_date,
		 cls.cls_code k_class,
		 khr.scs_code k_subclass,
		 khr.estimated_amount k_estimated_amount,
		 khr.sts_code,
		 khr.authoring_org_id
    FROM  okc_k_headers_b khr,
    		okc_subclasses_b cls
    WHERE (khr.id = p_chr_id OR p_chr_id IS NULL)
    AND khr.scs_code = cls.code
    AND khr.end_date BETWEEN (p_variance + trunc(p_last_rundate) + 1)
    AND (trunc(sysdate) + p_variance + 0.99999)
    ORDER BY k_number;

    k1_rec	k1_csr%ROWTYPE;

    CURSOR elements_csr IS
    SELECT aae.element_name
    FROM   okc_actions_v acn,okc_action_attributes_v aae
    WHERE  acn.id = aae.acn_id
    AND    acn.correlation = 'KEXPIRE';

    elements_rec elements_csr%ROWTYPE;

   --
   l_proc varchar2(72) := g_package||'exp_date_assemble';
   --

    BEGIN


  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('50: ***** In parameters **** ',2);
     okc_debug.Log('50: p_api_version : '||p_api_version ,2);
     okc_debug.Log('50: p_cnh_id : '||p_cnh_id ,2);
     okc_debug.Log('50: p_dnz_chr_id : '||p_dnz_chr_id ,2);
     okc_debug.Log('50: p_cnh_variance : '||p_cnh_variance ,2);
     okc_debug.Log('50: p_before_after : '||p_before_after ,2);
     okc_debug.Log('50: p_last_rundate : '||p_last_rundate ,2);
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Last Rundate (dd/mm/yyyy:hh24:mi:ss) :'||to_char(p_last_rundate,'dd/mm/yyyy:hh24:mi:ss'));
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'End_Date Range (dd/mm/yyyy:hh24:mi:ss) :'||to_char((p_cnh_variance + trunc(p_last_rundate) + 1),'dd/mm/yyyy:hh24:mi:ss') || ' and ' || to_char((trunc(sysdate) + p_cnh_variance + 0.99999),'dd/mm/yyyy:hh24:mi:ss' ));
    -- call start_activity to create savepoint, check comptability
    -- and initialize message list
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PROCESS'
                                                ,x_return_status
                                                );
    -- check if activity started successfully
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

    --Get the correlation
/*    SELECT acn.correlation INTO l_corrid_rec FROM okc_actions_v acn
    WHERE acn.correlation = 'KEXPIRE';*/

    --Get the action id
    SELECT acn.id INTO l_acn_id FROM okc_actions_b acn
    WHERE acn.correlation = 'KEXPIRE';

        --Check if the variance is positive or negative
	IF p_before_after = 'A' THEN
		l_variance := p_cnh_variance * -1;
	ELSIF p_before_after = 'B' THEN
		l_variance := p_cnh_variance;
	END IF;

	    l_last_rundate := p_last_rundate;

      --get contract details
      FOR k1_rec in k1_csr(p_chr_id       => p_dnz_chr_id,
                           p_variance     => l_variance,
                           p_last_rundate => l_last_rundate) LOOP
           k := 0;
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Contract picked for Renewal :'||substr(k1_rec.k_number,1,200));
	    --Initialize the table
    	    l_msg_tbl   := okc_aq_pvt.msg_tab_typ();
           FOR elements_rec IN elements_csr LOOP


        -- Bug#4172674 increment counter K inside the loop
		--Build the elements table
    		IF elements_rec.element_name = 'K_ID' THEN
    			l_msg_tbl.extend;
		        k := k + 1;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_id;
    		ELSIF elements_rec.element_name = 'K_NUMBER' THEN
    			l_msg_tbl.extend;
		        k := k + 1;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_number;
    		ELSIF elements_rec.element_name = 'K_NBR_MOD' THEN
    			l_msg_tbl.extend;
		        k := k + 1;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_nbr_mod;
    		ELSIF elements_rec.element_name = 'K_EXPIRE_DATE' THEN
    			l_msg_tbl.extend;
		        k := k + 1;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := to_char(k1_rec.k_expire_date, 'DD-MON-YY');
    		ELSIF elements_rec.element_name = 'K_CLASS' THEN
    			l_msg_tbl.extend;
		        k := k + 1;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_class;
   		ELSIF elements_rec.element_name = 'K_SUBCLASS' THEN
    			l_msg_tbl.extend;
		        k := k + 1;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_subclass;
		ELSIF elements_rec.element_name = 'CNH_ID' THEN
    			l_msg_tbl.extend;
		        k := k + 1;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := p_cnh_id;
         	ELSIF elements_rec.element_name = 'ESTIMATED_AMOUNT' THEN
			l_msg_tbl.extend;
		    k := k + 1;
			l_msg_tbl(k).element_name := elements_rec.element_name;
			l_msg_tbl(k).element_value := k1_rec.k_estimated_amount;
		ELSIF elements_rec.element_name = 'K_STATUS_CODE' THEN
			l_msg_tbl.extend;
		    k := k + 1;
			l_msg_tbl(k).element_name := elements_rec.element_name;
			l_msg_tbl(k).element_value := k1_rec.sts_code;
		ELSIF elements_rec.element_name = 'ORG_ID' THEN
			l_msg_tbl.extend;
		    k := k + 1;
			l_msg_tbl(k).element_name := elements_rec.element_name;
			l_msg_tbl(k).element_value := k1_rec.authoring_org_id;
    		END IF;
		END LOOP;
		-- call OKC_AQ_PVT.send_messages to generate the XML string and put it
  		-- on the queue
	/*	OKC_AQ_PUB.send_message(p_api_version     =>1.0
                         ,p_init_msg_list   => 'F'
                         ,x_msg_count       => x_msg_count
                         ,x_msg_data        => x_msg_data
                         ,x_return_status   => l_return_status
                         ,p_corrid_rec      => l_corrid_rec
                         ,p_msg_tab         => l_msg_tbl
                         ,p_queue_name      => okc_aq_pvt.g_event_queue_name); */
		/* Bug#3800031 superceeds Bug#2111951
        Above call to enque message is commented to process date based events sychronously.
        A direct call to date condition evaluator is made to evaluate date based events.
        */
       OKC_CONDITION_EVAL_PUB.evaluate_date_condition (
                           p_api_version    => 1.0,
		                   p_init_msg_list  => p_init_msg_list,
                           x_return_status  =>l_return_status,
                           x_msg_count      =>x_msg_count,
                           x_msg_data       =>x_msg_data,
                           p_cnh_id         =>p_cnh_id ,
                           p_msg_tab        =>l_msg_tbl
                           );
		IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             		RAISE OKC_API.G_EXCEPTION_ERROR;
		--ELSIF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
			--commit;
       	        END IF;

                FND_MESSAGE.SET_NAME('OKC','OKC_EDA_CONTRACTS');
--                FND_MESSAGE.SET_TOKEN('NUMBER',k1_rec.k_number);
                FND_MESSAGE.SET_TOKEN('NUMBER',k1_rec.k_number||': '||k1_rec.k_nbr_mod||': Ending  '|| to_char(k1_rec.k_expire_date,'DD-MM-YYYY:hh24:mi:ss'));
                FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    	END LOOP;
     commit;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);


  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PROCESS');
        IF (l_debug = 'Y') THEN
           okc_debug.Log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PROCESS');
        IF (l_debug = 'Y') THEN
           okc_debug.Log('3000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PROCESS');
        IF (l_debug = 'Y') THEN
           okc_debug.Log('4000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
    END exp_date_assemble;


 PROCEDURE exp_lines_date_assemble(
    p_api_version	IN NUMBER,
    p_init_msg_list     IN VARCHAR2 ,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_cnh_id            IN okc_condition_headers_b.id%TYPE,
    p_dnz_chr_id        IN okc_condition_headers_b.dnz_chr_id%TYPE ,
    p_cnh_variance      IN okc_condition_headers_b.cnh_variance%TYPE,
    p_before_after      IN okc_condition_headers_b.before_after%TYPE,
    p_last_rundate      IN okc_condition_headers_b.last_rundate%TYPE) IS


--    l_api_name            CONSTANT VARCHAR2(30) := 'exp_lines_date_assemble';
    l_api_name            CONSTANT VARCHAR2(30) := 'exp_ln_date_ass';
    l_api_version         CONSTANT NUMBER := 1.0;
    l_return_status       VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    k                     NUMBER;
    l_last_rundate	      DATE;
    l_variance		       okc_condition_headers_b.cnh_variance%TYPE;
    --l_corrid_rec    	  okc_aq_pub.corrid_rec_typ;
    l_msg_tbl       	  okc_aq_pub.msg_tab_typ;
    l_element_name	       okc_action_attributes_b.element_name%TYPE;
    l_element_value	       VARCHAR2(100);
    l_acn_id               NUMBER;

    --Get all the contract LINES that are expiring from the last rundate
    --of the date assembler concurrent program for a given condition

    CURSOR k1_csr(p_chr_id IN NUMBER, p_variance IN NUMBER, p_last_rundate IN DATE)
    IS
 SELECT /*+ leading(kln) use_nl(kln khr cls sts) */ khr.id k_id,   -- Bug 5012601 Added hint to avoid FTS
 		khr.contract_number k_number,
          khr.contract_number_modifier k_nbr_mod,
          khr.end_date k_expire_date,
          cls.cls_code k_class,
          khr.scs_code k_subclass,
          khr.estimated_amount k_estimated_amount,
          khr.sts_code,
          khr.authoring_org_id
    FROM   okc_k_headers_b khr,
           okc_subclasses_b cls,
           okc_statuses_b sts ,
           okc_k_lines_b kln
    WHERE
    (khr.id = p_chr_id OR p_chr_id IS NULL)
    AND khr.scs_code = cls.code
    AND khr.sts_code = sts.code
    AND sts.ste_code IN ('ACTIVE', 'SIGNED')
    AND kln.sts_code = sts.code
    AND  kln.dnz_chr_id = khr.id
    AND kln.end_date BETWEEN (p_variance + trunc(p_last_rundate) + 1)
    AND (trunc(sysdate) + p_variance + 0.99999)
    ORDER BY k_number;

    k1_rec	k1_csr%ROWTYPE;


    CURSOR elements_csr IS
    SELECT aae.element_name
    FROM   okc_actions_v acn,okc_action_attributes_v aae
    WHERE  acn.id = aae.acn_id
    AND    acn.correlation = 'KLEXPIRE';

    elements_rec elements_csr%ROWTYPE;

   --
   l_proc varchar2(72) := g_package||'exp_lines_date_assemble';
   --

    BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('100: ***** In parameters **** ',2);
     okc_debug.Log('100: p_api_version : '||p_api_version ,2);
     okc_debug.Log('100: p_cnh_id : '||p_cnh_id ,2);
     okc_debug.Log('100: p_dnz_chr_id : '||p_dnz_chr_id ,2);
     okc_debug.Log('100: p_cnh_variance : '||p_cnh_variance ,2);
     okc_debug.Log('100: p_before_after : '||p_before_after ,2);
     okc_debug.Log('100: p_last_rundate : '||p_last_rundate ,2);
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Last Rundate (dd/mm/yyyy:hh24:mi:ss) :'||to_char(p_last_rundate,'dd/mm/yyyy:hh24:mi:ss'));
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'End_Date Range (dd/mm/yyyy:hh24:mi:ss) :'||to_char((p_cnh_variance + trunc(p_last_rundate) + 1),'dd/mm/yyyy:hh24:mi:ss') || ' and ' || to_char((trunc(sysdate) + p_cnh_variance + 0.99999),'dd/mm/yyyy:hh24:mi:ss' ));


    -- call start_activity to create savepoint, check comptability
    -- and initialize message list
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PROCESS'
                                                ,x_return_status
                                                );
  IF (l_debug = 'Y') THEN
     okc_debug.Log('110: l_return_status : '||l_return_status ,2);
  END IF;

    -- check if activity started successfully
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

    --Get the correlation
    /*SELECT acn.correlation INTO l_corrid_rec FROM okc_actions_v acn
    WHERE acn.correlation = 'KLEXPIRE';*/
    --Get the action id
    SELECT acn.id INTO l_acn_id FROM okc_actions_b acn
    WHERE acn.correlation = 'KLEXPIRE';

  IF (l_debug = 'Y') THEN
     okc_debug.Log('120: After fetching into l_corrid_rec  ',2);
  END IF;

        --Check if the variance is positive or negative
	IF p_before_after = 'A' THEN
		l_variance := p_cnh_variance * -1;
	ELSIF p_before_after = 'B' THEN
		l_variance := p_cnh_variance;
	END IF;

	    l_last_rundate := p_last_rundate;


      --get contract details for K lines to be extended
      FOR k1_rec in k1_csr(p_chr_id       => p_dnz_chr_id,
                           p_variance     => l_variance,
                           p_last_rundate => l_last_rundate) LOOP
           k := 0;
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Contract picked for Renewal :'||substr(k1_rec.k_number,1,200));

	    --Initialize the table
    	    l_msg_tbl   := okc_aq_pvt.msg_tab_typ();
           FOR elements_rec IN elements_csr LOOP



        -- Bug#4172674 increment counter K inside the loop
		--Build the elements table
    		IF elements_rec.element_name = 'K_ID' THEN
		        k := k + 1;
    			l_msg_tbl.extend;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_id;
    		ELSIF elements_rec.element_name = 'K_NUMBER' THEN
		        k := k + 1;
    			l_msg_tbl.extend;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_number;
    		ELSIF elements_rec.element_name = 'K_NBR_MOD' THEN
		        k := k + 1;
    			l_msg_tbl.extend;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_nbr_mod;
    		ELSIF elements_rec.element_name = 'K_EXPIRE_DATE' THEN
		        k := k + 1;
    			l_msg_tbl.extend;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := to_char(k1_rec.k_expire_date, 'DD-MON-YY');
    		ELSIF elements_rec.element_name = 'K_CLASS' THEN
		        k := k + 1;
    			l_msg_tbl.extend;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_class;
   		ELSIF elements_rec.element_name = 'K_SUBCLASS' THEN
		        k := k + 1;
    			l_msg_tbl.extend;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := k1_rec.k_subclass;
		ELSIF elements_rec.element_name = 'CNH_ID' THEN
		        k := k + 1;
    			l_msg_tbl.extend;
       			l_msg_tbl(k).element_name  := elements_rec.element_name;
       			l_msg_tbl(k).element_value := p_cnh_id;
         	ELSIF elements_rec.element_name = 'ESTIMATED_AMOUNT' THEN
		        k := k + 1;
			l_msg_tbl.extend;
			l_msg_tbl(k).element_name := elements_rec.element_name;
			l_msg_tbl(k).element_value := k1_rec.k_estimated_amount;
		ELSIF elements_rec.element_name = 'K_STATUS_CODE' THEN
		        k := k + 1;
			l_msg_tbl.extend;
			l_msg_tbl(k).element_name := elements_rec.element_name;
			l_msg_tbl(k).element_value := k1_rec.sts_code;
		ELSIF elements_rec.element_name = 'ORG_ID' THEN
		        k := k + 1;
			l_msg_tbl.extend;
			l_msg_tbl(k).element_name := elements_rec.element_name;
			l_msg_tbl(k).element_value := k1_rec.authoring_org_id;
    		END IF;
		END LOOP;  -- built the element table for K

  IF (l_debug = 'Y') THEN
     okc_debug.Log('140: Calling OKC_AQ_PUB.send_message  ',2);
  END IF;

		-- call OKC_AQ_PVT.send_messages to generate the XML string and put it
  		-- on the queue
/*		OKC_AQ_PUB.send_message(p_api_version     =>'1.0'
                         ,p_init_msg_list   => 'F'
                         ,x_msg_count       => x_msg_count
                         ,x_msg_data        => x_msg_data
                         ,x_return_status   => l_return_status
                         ,p_corrid_rec      => l_corrid_rec
                         ,p_msg_tab         => l_msg_tbl
                         ,p_queue_name      => okc_aq_pvt.g_event_queue_name);
*/
        /* Bug#2111951 Above call to enque message is commented to process date based events
 sychronously. A direct call to condition evaluator is made to evaluate date bas
ed events.*/

		/* Bug#3800031 superceeds Bug#2111951
        Above call to enque message is commented to process date based events sychronously.
        A direct call to date condition evaluator is made to evaluate date based events.
        */
       OKC_CONDITION_EVAL_PUB.evaluate_date_condition (
                           p_api_version    => 1.0,
		                   p_init_msg_list  => p_init_msg_list,
                           x_return_status  =>l_return_status,
                           x_msg_count      =>x_msg_count,
                           x_msg_data       =>x_msg_data,
                           p_cnh_id         =>p_cnh_id ,
                           p_msg_tab        =>l_msg_tbl
                           );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('150: Called OKC_AQ_PUB.send_message  ',2);
     okc_debug.Log('160: l_return_status : '||l_return_status,2);
  END IF;

		IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             		RAISE OKC_API.G_EXCEPTION_ERROR;
       	        END IF;

       FND_MESSAGE.SET_NAME('OKC','OKC_EDA_CONTRACTS');
       FND_MESSAGE.SET_TOKEN('NUMBER',k1_rec.k_number||': '||k1_rec.k_nbr_mod||':Ending  '|| to_char(k1_rec.k_expire_date,'DD-MM-YYYY:hh24:mi:ss'));
       FND_MESSAGE.SET_TOKEN('NUMBER',k1_rec.k_number);
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

 IF (l_debug = 'Y') THEN
    okc_debug.Log('170: going to next k ',2);
 END IF;

    	END LOOP; -- for each K

     COMMIT;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
        IF (l_debug = 'Y') THEN
           okc_debug.Log('2000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PROCESS');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF (l_debug = 'Y') THEN
           okc_debug.Log('3000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PROCESS');
       WHEN OTHERS THEN
        IF (l_debug = 'Y') THEN
           okc_debug.Log('4000: Leaving ',2);
           okc_debug.Reset_Indentation;
        END IF;
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PROCESS');
    END exp_lines_date_assemble;

END OKC_EXP_DATE_ASMBLR_PVT;

/
