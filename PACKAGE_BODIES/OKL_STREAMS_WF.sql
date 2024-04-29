--------------------------------------------------------
--  DDL for Package Body OKL_STREAMS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STREAMS_WF" AS
/* $Header: OKLRPWFB.pls 120.2 2006/07/18 10:52:52 dkagrawa noship $ */
-- INFO
-- This procedure is invoked from Inbound Work Flow Process
-- END INFO

PROCEDURE process(itemtype	  IN VARCHAR2,
	                      itemkey	  IN VARCHAR2,
	                      actid	  IN NUMBER,
	                      funcmode	  IN VARCHAR2,
	                      resultout  IN OUT NOCOPY VARCHAR2)
IS
  l_transaction_number	VARCHAR2(240);
  document_id		VARCHAR2(240);
  parameter1		VARCHAR2(240);
  parameter2		VARCHAR2(240);
  parameter3		VARCHAR2(240);
  parameter4		VARCHAR2(240);
  parameter5		VARCHAR2(240);
  parameter6		VARCHAR2(240);
  parameter7		VARCHAR2(240);
  parameter8		VARCHAR2(240);
  parameter9		VARCHAR2(240);
  parameter10		VARCHAR2(240);
  l_error_msg		VARCHAR2(2000);
  result		    VARCHAR2(30);
  l_orp_code        VARCHAR2(10);

  l_api_version     NUMBER := 1;
  l_init_msg_list   VARCHAR2(1) :=  OKC_API.G_FALSE;
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(4000);
  l_msg_text        VARCHAR2(4000);
  l_attr_name       VARCHAR2(15) := 'ERROR_MSG';
  G_SIS_CODE        VARCHAR2(50) := 'PROCESSING_FAILED';
  G_SRT_CODE        VARCHAR2(50) := 'PROCESSING_FAILED';
  l_error_message_tbl  LOG_MSG_TBL_TYPE;
  l_error_message_line VARCHAR2(4000) := NULL;
--  l_new_line        VARCHAR2(4000) := FND_GLOBAL.NEWLINE;

-- smahapat added khr_id to cursor for bug 3145238
  CURSOR strm_interfaces_data_csr (p_trx_number NUMBER) IS
  SELECT
    ORP_CODE, KHR_ID
  FROM okl_stream_interfaces
  WHERE okl_stream_interfaces.transaction_number = p_trx_number;

-- smahapat added for bug 3145238
-- cursor to provide information for setting context
  CURSOR l_hdr_csr(chrId  NUMBER)
  IS
  SELECT chr.orig_system_source_code,
         chr.start_date,
         chr.end_date,
         chr.template_yn,
         chr.authoring_org_id,
         chr.inv_organization_id,
         khr.deal_type,
         pdt.id  pid,
         NVL(pdt.reporting_pdt_id, -1) report_pdt_id,
         chr.currency_code currency_code,
         khr.term_duration term
  FROM okc_k_headers_v chr,
       okl_k_headers khr,
       okl_products_v pdt
  WHERE khr.id = chr.id
  AND chr.id = chrId
  AND khr.pdt_id = pdt.id(+);

  l_hdr_rec l_hdr_csr%ROWTYPE;
  l_khr_id          NUMBER;
-- end code for setting context

BEGIN
  -- Do nothing in cancel or timeout mode

  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;
  --
  -- We need to determine which parameters are required and which are optional
  --
  l_transaction_number  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'PARAMETER1');
  IF (  l_transaction_number IS NULL ) THEN
	wf_core.token('OKL_TRANSACTION_NUMBER','NULL');
	wf_core.RAISE('WFSQL_ARGS');
  END IF;

  --
  -- params2..10 optional
  --
  parameter2  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'PARAMETER2');
  parameter3  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'PARAMETER3');
  parameter4  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'PARAMETER4');
  parameter5  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'PARAMETER5');
  parameter6  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'PARAMETER6');
  parameter7  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'PARAMETER7');
  parameter8  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'PARAMETER8');
  parameter9  := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'PARAMETER9');
  parameter10 := Wf_Engine.GetActivityAttrText(itemtype, itemkey,actid, 'PARAMETER10');

	-- Invoke Process Stream Results API
	FOR strm_interfaces_data in strm_interfaces_data_csr(l_transaction_number)
	LOOP
	  l_orp_code := strm_interfaces_data.orp_code;
	  l_khr_id := strm_interfaces_data.khr_id;	   -- added by smahapat for setting context (bug 3145238)
	END LOOP;

-- set context (bug 3145238)
    OPEN l_hdr_csr( l_khr_id );
    FETCH l_hdr_csr INTO l_hdr_rec;
    CLOSE l_hdr_csr;
    okl_context.set_okc_org_context(l_hdr_rec.authoring_org_id,l_hdr_rec.inv_organization_id);
-- end set context


	-- Booking
		IF (l_orp_code = 'AUTH')
		THEN
	      OKL_PROCESS_STREAMS_PVT.PROCESS_STREAM_RESULTS (l_api_version
					                                     ,l_init_msg_list
								 	                     ,l_transaction_number
								                         ,l_return_status
								                         ,l_msg_count
	 							                         ,l_msg_data);
	-- Restrucutres
	    ELSIF(l_orp_code = 'RSAM')
		THEN
	      OKL_PROCESS_STREAMS_PVT.PROCESS_REST_STRM_RESLTS(
		                                          p_api_version        => l_api_version
	                                             ,p_init_msg_list      => l_init_msg_list
		                                         ,p_transaction_number => l_transaction_number
	                                             ,x_return_status      => l_return_status
	                                             ,x_msg_count          => l_msg_count
	                                             ,x_msg_data           => l_msg_data);
	--  Quotes
	    ELSIF(l_orp_code = 'QUOT')
		THEN
	      OKL_PROCESS_STREAMS_PVT.PROCESS_QUOT_STRM_RESLTS(
		                                          p_api_version        => l_api_version
	                                             ,p_init_msg_list      => l_init_msg_list
		                                         ,p_transaction_number => l_transaction_number
	                                             ,x_return_status      => l_return_status
	                                             ,x_msg_count          => l_msg_count
	                                             ,x_msg_data           => l_msg_data);
	--  Renewals
	    ELSIF(l_orp_code = 'RENW')
		THEN
	      OKL_PROCESS_STREAMS_PVT.PROCESS_RENW_STRM_RESLTS(
		                                          p_api_version        => l_api_version
	                                             ,p_init_msg_list      => l_init_msg_list
		                                         ,p_transaction_number => l_transaction_number
	                                             ,x_return_status      => l_return_status
	                                             ,x_msg_count          => l_msg_count
	                                             ,x_msg_data           => l_msg_data);
	--  Variable Interest Rate Processing
	    ELSIF(l_orp_code = 'VIRP')
		THEN
	      OKL_PROCESS_STREAMS_PVT.PROCESS_VIRP_STRM_RESLTS(
		                                          p_api_version        => l_api_version
	                                             ,p_init_msg_list      => l_init_msg_list
		                                         ,p_transaction_number => l_transaction_number
	                                             ,x_return_status      => l_return_status
	                                             ,x_msg_count          => l_msg_count
	                                             ,x_msg_data           => l_msg_data);


    END IF;
-- if error
         IF(l_return_status <> G_RET_STS_SUCCESS)
		 THEN

-- commented for using REPORT ERROR API
--            l_error_msg := 'Errors while processing results, please refer to log file ' || 'OKLSTXMLG_' || l_transaction_number || '.log' || ' for more details';
            l_error_msg := ' ';
 	   	    wf_engine.SetItemAttrText(itemtype,itemkey,l_attr_name, l_error_msg);

			l_error_message_tbl(1) := 'Errors while processing Streams Results :- ';

            Okl_Streams_Util.LOG_MESSAGE(p_msgs_tbl => l_error_message_tbl,
                                         p_translate => G_FALSE,
                                         p_file_name => 'OKLSTXMLG_' || l_transaction_number || '.log' ,
             			                 x_return_status => l_return_status );

			Okl_Streams_Util.LOG_MESSAGE(p_msg_count => l_msg_count,
                                         p_file_name => 'OKLSTXMLG_' || l_transaction_number || '.log',
			                             x_return_status => l_return_status
                                         );

	    	l_error_message_tbl(1) := 'End Errors while processing Streams Results';
            Okl_Streams_Util.LOG_MESSAGE(p_msgs_tbl => l_error_message_tbl,
                                         p_translate => G_FALSE,
                                         p_file_name => 'OKLSTXMLG_' || l_transaction_number || '.log' ,
             			                 x_return_status => l_return_status );


            OKL_POPULATE_PRCENG_RESULT_PUB.UPDATE_STATUS(--p_api_version => l_api_version,
	                                                     --p_init_msg_list => l_init_msg_list,
	                                                     p_transaction_number => l_transaction_number,
                                                         p_sis_code => G_SIS_CODE,
														 p_srt_code =>  G_SRT_CODE,
														 p_log_file_name => 'OKLSTXMLG_' || l_transaction_number || '.log',
                                                         x_return_status => l_return_status
														 );


		    	resultout := wf_engine.eng_completed || ':' || 'F';
         ELSE
		    	resultout := wf_engine.eng_completed || ':' || 'T';
		END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('OKL_PROCESS_STREAMS', 'process_streams', itemtype, itemkey, TO_CHAR(actid), funcmode);
    RAISE;

END process;

PROCEDURE REPORT_ERROR(ITEMTYPE	  IN VARCHAR2,
	       ITEMKEY	  IN VARCHAR2,
	       ACTID	  IN NUMBER,
	       FUNCMODE	  IN VARCHAR2,
	       RESULTOUT  IN OUT NOCOPY VARCHAR2)
IS
  l_transaction_number	VARCHAR2(40);
  l_document_id		VARCHAR2(240);
  l_msg_name		VARCHAR2(30);

  parameter1		VARCHAR2(240);
  parameter2		VARCHAR2(240);
  parameter3		VARCHAR2(240);
  parameter4		VARCHAR2(240);
  parameter5		VARCHAR2(240);
  l_error_msg		VARCHAR2(2000);
  result		    VARCHAR2(30);

  l_api_version     NUMBER := 1;
  l_init_msg_list   VARCHAR2(1) :=  OKC_API.G_FALSE;
  l_return_status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(4000);
  l_msg_text        VARCHAR2(1000);
  l_attr_name       VARCHAR2(15) := 'OKL_ERROR_MSG';
  l_new_line        VARCHAR2(10) := FND_GLOBAL.NEWLINE;

  l_file_name VARCHAR2(100);

BEGIN
  -- Do nothing in cancel or timeout mode
  IF (funcmode <> wf_engine.eng_run) THEN
    resultout := wf_engine.eng_null;
    RETURN;
  END IF;

  l_document_id  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'OKL_REQUEST_ID');
  IF (  l_document_id IS NULL ) THEN
	wf_core.token('OKL_REQUEST_ID','NULL');
	wf_core.RAISE('WFSQL_ARGS');
  END IF;

  l_msg_name  := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'OKL_ERROR_MSG');
  IF (  l_document_id IS NULL ) THEN
	wf_core.token('OKL_DOCUMENT_ID','NULL');
	wf_core.RAISE('WFSQL_ARGS');
  END IF;


  -- WHAT IS THIS????

  -- AKJAIN
  -- MAY BE WE DO NOT NEED IT SO COMMENTED
  --  wf_Item_Activity_Status.Result(itemtype, itemkey, actid, status, result);
  -- AKJAIN

  l_file_name := G_FILENAME_PRE || l_document_id || G_FILENAME_EXT;

			-- Call the Process Stream Results API
    Okl_Streams_Util.LOG_MESSAGE(p_msg_name            => l_msg_name
                             ,p_file_name           => l_file_name
                             ,x_return_status       => l_return_status);
   -- if error
   IF(l_return_status <> G_RET_STS_SUCCESS)
   THEN

     -- GET THE MESSAGES FROM FND_MESSAGES
     FOR i IN 1..l_msg_count
     LOOP
         fnd_msg_pub.get(p_data => l_msg_text,
                         p_msg_index_out => l_msg_count,
                         p_encoded => G_FALSE,
                         p_msg_index => fnd_msg_pub.g_next);
	 IF i = 1 THEN
	   l_error_msg := l_msg_text;
	 ELSE
	   l_error_msg := l_error_msg || l_new_line || l_msg_text;
	 END IF;
      END LOOP;
      wf_engine.SetItemAttrText(itemtype,itemkey,l_attr_name,l_error_msg);
      resultout := wf_engine.eng_completed||':'|| 'F';
   ELSE
      resultout := wf_engine.eng_completed||':'|| 'T';
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('report_error', 'report_error', itemtype, itemkey, TO_CHAR(actid), funcmode);
    RAISE;
END REPORT_ERROR;


END Okl_Streams_Wf;

/
