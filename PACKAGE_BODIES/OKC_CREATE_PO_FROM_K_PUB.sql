--------------------------------------------------------
--  DDL for Package Body OKC_CREATE_PO_FROM_K_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CREATE_PO_FROM_K_PUB" AS
/* $Header: OKCPKPOB.pls 120.0 2005/05/25 19:37:03 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


-- Local private procedures not declared in specification

PROCEDURE submit_pdoi_errors_report(   p_api_version              IN  NUMBER
			               ,p_init_msg_list            IN  VARCHAR2
			               ,p_chr_id                   IN  okc_k_headers_b.ID%TYPE
                           ,x_return_status            OUT NOCOPY VARCHAR2
			               ,x_msg_count                OUT NOCOPY NUMBER
			               ,x_msg_data                 OUT NOCOPY VARCHAR2);


PROCEDURE my_debug( p_msg    IN VARCHAR2,
				p_level  IN NUMBER DEFAULT 1  ,
				p_module IN VARCHAR2 DEFAULT 'OKC');


----------------------------------------------------------------------------
--  Global Constants--------------------------------------------------------
----------------------------------------------------------------------------
--  Standard API Constants

G_UNEXPECTED_ERROR              CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
G_SQLCODE_TOKEN                 CONSTANT VARCHAR2(200) := 'SQLCODE';
G_SQLERRM_TOKEN                 CONSTANT VARCHAR2(200) := 'SQLERRM';
G_PKG_NAME                      CONSTANT VARCHAR2(200) := 'OKC_CREATE_PO_FROM_K_PUB';
G_APP_NAME                      CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
G_APP_NAME1                     CONSTANT VARCHAR2(3)   := 'OKC';

G_API_TYPE                      CONSTANT VARCHAR2(30)  := '_PROCESS';
G_SCOPE                         CONSTANT VARCHAR2(4)   := '_PVT';

-- Related objects constants

g_crj_rty_code                    CONSTANT VARCHAR2(20)  := 'CONTRACTCREATESPO';
g_crj_chr_jtot_object_code        CONSTANT VARCHAR2(20)  := 'OKX_PO_HEADERS';

-- Holds the value of request_data from subsequent calls
l_request_data                  VARCHAR2(100);
-------------------------------------------------------------------------------
-- Procedure:       create_po_from_k
-- Version:         1.0
-- Purpose:         craete a PO from a contract.
--                  This API is used in a concurrent program definition
--                  This will be a wrapper for create_PO_from_k
--                  procedure described below
PROCEDURE create_po_from_k(ERRBUF                   OUT NOCOPY VARCHAR2
                          ,RETCODE                  OUT NOCOPY NUMBER
			  ,p_contract_id            IN  okc_k_headers_b.ID%TYPE
			  ) IS

l_api_version       CONSTANT NUMBER        := 1;
lx_return_status    VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
lx_msg_count        NUMBER := 0;
lx_msg_data         VARCHAR2(2000);
lx_po_number         VARCHAR2(20);
l_k_number           VARCHAR2(120);
l_k_number_modifier  VARCHAR2(120);
lx_k_buyer_name      VARCHAR2(120);
l_notify             VARCHAR2(1);

  BEGIN

-- This is the main program that gets called. However, for a single
-- submission of a request, this routine gets called multiple times.
-- The reason for this is that this request submits a child request
-- every time it is called. Refer to the documentation on concurrent
-- program APIs for child requests for an explanation of how the
-- works. Following is the sequence of events:
--
-- First time call
-- ---------------
-- Call routine to populate PO interface tables and also submit a
-- child request for PDOI to import the data from the interface
-- tables. It is identified as the initial call since there is no
-- value in the request_data. While exiting, a value is stored in
-- request_data (STAGE2)
--
-- Second call
-- -----------
-- After the child request completes, the concurrent manager calls
-- this procedure again with the same parameter. This time,
-- request_data will have the value (STAGE2) from the earlier run. If
-- this value is present, then branch off and submit the concurrent
-- program for PDOI interface error reporting. Also perform the
-- tieback (clean up related objects for any invalid entries)

-- select contract number and contract number modifier

  SELECT contract_number, contract_number_modifier
  INTO l_k_number, l_k_number_modifier
  FROM okc_k_headers_b
  WHERE id = p_contract_id;

  l_k_number_modifier := nvl(l_k_number_modifier, ' ');

-- Examine the value of request_data. If this is null, then this is
-- the first time that this is being called

  l_request_data   := fnd_conc_global.request_data;


  IF l_request_data IS NULL
  THEN

  -- First time call; populate PO interface and trigger off the PDOI
  -- concurrent program as a child-request

  -- Call the main routine (overloaded procedure with same name)
  OKC_CREATE_PO_FROM_K_PUB.create_po_from_k(p_api_version   => l_api_version
                                        ,p_init_msg_list => OKC_API.G_TRUE
                                        ,x_return_status => lx_return_status
                                        ,x_msg_count     => lx_msg_count
                                        ,x_msg_data      => lx_msg_data
                                        ,p_contract_id   => p_contract_id
                                        );

-- check return status
  IF lx_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
        RETCODE := 2;
        ERRBUF:=lx_msg_data;
	   RETURN;
    ELSE
        RETCODE:=0;
    END IF;

-- If request_data contains STAGE2, then this is the second time that
-- this program is being called. At the end of the first call, STAGE2
-- was placed in request_data
-- For stage2, submit the PDOI Interface errors report and also do
-- the tieback (cleanup of related objects)
  ELSIF l_request_data = 'STAGE2'
  THEN

        OKC_CREATE_PO_FROM_K_PVT.tieback_related_objs_from_po(
                                                              p_api_version   => l_api_version
                                                             ,p_init_msg_list => OKC_API.G_TRUE
                                                             ,x_return_status => lx_return_status
                                                             ,x_msg_count     => lx_msg_count
                                                             ,x_msg_data      => lx_msg_data
							     ,x_po_number     => lx_po_number
                                                             ,p_chr_id        => p_contract_id
							                                  );

-- Tieback returns Error for any fatal errors and if the PO did not
-- get created by PDOI, returns a Warning if the header got created
-- but any lines did notget created; returns success otherwise

      IF lx_return_status = OKC_API.G_RET_STS_SUCCESS
	   THEN
              retcode := 0;
              errbuf  := NULL;

		  IF l_notify = 'T'
              THEN
 			   OKC_CREATE_PO_FROM_K_PVT.notify_buyer(p_api_version               => l_api_version
                                                          ,p_init_msg_list             => OKC_API.G_TRUE
                                                          ,p_application_name          => G_APP_NAME1
		       	      			          ,p_message_subject           => 'OKC_K2PO_NOTIF_SUBJECT'
		        	    				          ,p_message_body 	         => 'OKC_K2PO_NOTIF_BODY'
		        	    				          ,p_message_body_token1       =>	'PONUMBER'
		        	    	                            ,p_message_body_token1_value => lx_po_number
		        	    				          ,p_message_body_token2 	   => 'KNUMBER'
		        	    				          ,p_message_body_token2_value => l_k_number
                        				          ,p_message_body_token3 	   => 'KNUMMODIFIER'
		        	    				          ,p_message_body_token3_value => l_k_number_modifier
		        	    				          ,p_chr_id                    => p_contract_id
							                ,x_k_buyer_name              => lx_k_buyer_name
                        	    	 			    ,x_return_status   	         => lx_return_status
                        	    				    ,x_msg_count                 => lx_msg_count
                        	                            ,x_msg_data                  => lx_msg_data
                                                          );

			-- check return status
           	      IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    				RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  		  	ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
    				RAISE OKC_API.G_EXCEPTION_ERROR;
  		  	END IF;


		  END IF;

      ELSIF lx_return_status = OKC_API.G_RET_STS_WARNING
	   THEN
		      retcode := 1;
		      errbuf  := lx_msg_data;

              IF l_notify = 'T'
              THEN
 			   OKC_CREATE_PO_FROM_K_PVT.notify_buyer(p_api_version               => l_api_version
                                                          ,p_init_msg_list             => OKC_API.G_TRUE
                                                          ,p_application_name          => G_APP_NAME1
		        	            			    ,p_message_subject           => 'OKC_K2PO_NOTIF_SUBJECT'
		        	   				          ,p_message_body 	         => 'OKC_K2PO_NOTIF_BODY'
		        	   				          ,p_message_body_token1       =>	'PONUMBER'
		        	    			                ,p_message_body_token1_value => lx_po_number
		        	   				          ,p_message_body_token2 	     => 'KNUMBER'
		        	   				          ,p_message_body_token2_value => l_k_number
                        			                ,p_message_body_token3 	     => 'KNUMMODIFIER'
		        					          ,p_message_body_token3_value => l_k_number_modifier
		        					          ,p_chr_id                    => p_contract_id
							                ,x_k_buyer_name              => lx_k_buyer_name
                        	    				    ,x_return_status   	         => lx_return_status
                        	    				    ,x_msg_count                 => lx_msg_count
                        	                            ,x_msg_data                  => lx_msg_data
                                                          );

			-- check return status
              	IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    				RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  		  	ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
    				RAISE OKC_API.G_EXCEPTION_ERROR;
  		  	END IF;


		  END IF;

	   ELSE
              retcode := 2;
              errbuf  := lx_msg_data;
	   END IF;


       IF retcode <> 0 then

               submit_pdoi_errors_report(
                                         p_api_version   => l_api_version
                                        ,p_init_msg_list => OKC_API.G_TRUE
                                        ,x_return_status => lx_return_status
                                        ,x_msg_count     => lx_msg_count
                                        ,x_msg_data      => lx_msg_data
                                        ,p_chr_id        => p_contract_id
							         	);

            -- check return status
            IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    			RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  		ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
    			RAISE OKC_API.G_EXCEPTION_ERROR;
  		END IF;

      END IF;


  ELSE
-- This should never occur as the only valid values are NULL, STAGE2
--  Abort with an error if this happens

	   errbuf := 'Invalid request data: ' || l_request_data;
	   retcode := 2; -- Conc request completed with error

  END IF; -- end of if request_data is null

END create_po_from_k;


PROCEDURE create_po_from_k(p_api_version             IN  NUMBER
			               ,p_init_msg_list            IN  VARCHAR2
                           ,p_commit                   IN  VARCHAR2
			               ,p_contract_id              IN  okc_k_headers_b.ID%TYPE
                           ,x_return_status            OUT NOCOPY VARCHAR2
			               ,x_msg_count                OUT NOCOPY NUMBER
			               ,x_msg_data                 OUT NOCOPY VARCHAR2)IS

l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_PO_FROM_K';
l_api_version       CONSTANT NUMBER        := 1;
lx_return_status    VARCHAR2(1)    := OKC_API.G_RET_STS_SUCCESS;
lx_msg_count        NUMBER := 0;
lx_msg_data         VARCHAR2(2000);
  BEGIN
   -- call START_ACTIVITY to create savepoint, check compatibility
   -- and initialize message list
  lx_return_status := OKC_API.START_ACTIVITY(
                                        p_api_name      => l_api_name,
                                        p_pkg_name      => g_pkg_name,
                                        p_init_msg_list => p_init_msg_list,
                                        l_api_version   => l_api_version,
                                        p_api_version   => p_api_version,
                                        p_api_type      => g_api_type,
                                        x_return_status => lx_return_status);

  -- check if activity started successfully
  IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call the main routine
  OKC_CREATE_PO_FROM_K_PVT.create_po_from_k(p_api_version   => l_api_version
                                        ,p_init_msg_list => OKC_API.G_TRUE
                                        ,x_return_status => lx_return_status
                                        ,x_msg_count     => lx_msg_count
                                        ,x_msg_data      => lx_msg_data
                                        ,p_chr_id        => p_contract_id
                                        );


  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

     IF p_commit = OKC_API.G_TRUE THEN
        COMMIT;
     END IF;
  -- end activity
  OKC_API.END_ACTIVITY( x_msg_count             => lx_msg_count,
                        x_msg_data              => lx_msg_data);

  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                                                p_api_name  => l_api_name,
                                                p_pkg_name  => g_pkg_name,
                                                p_exc_name  => 'OTHERS',
                                                x_msg_count => x_msg_count,
                                                x_msg_data  => x_msg_data,
                                                p_api_type  => g_api_type);


  END create_po_from_k;

---------------------------------------------------------------------------------
---- Procedure:       submit_req_for_po_creation
---- Version:         1.0
---- Purpose:         submit the concurrent program that Populates PO interface from Contract
----

  PROCEDURE submit_req_for_po_creation(
                          p_api_version     IN  NUMBER
				 ,p_contract_id     IN  NUMBER
                         ,p_init_msg_list   IN  VARCHAR2
                         ,x_return_status   OUT NOCOPY VARCHAR2
                         ,x_msg_count       OUT NOCOPY NUMBER
                         ,x_msg_data        OUT NOCOPY  VARCHAR2) IS

l_request_id              fnd_concurrent_requests.request_id%TYPE;
x_phase                   varchar2(50);
x_status                  varchar2(50);
x_dev_phase               varchar2(50);
x_dev_status              varchar2(50);
x_message                 varchar2(50);
l_create_po_finished      boolean;
l_notify                  varchar2(1):= 'F';
l_po_number               number;
l_k_number_modifier       number;

BEGIN
 -- Submit the request to create the po
 my_debug('20: Submitting request to Populates PO interface from Contract');


 l_request_id := fnd_request.submit_request(
					  application => 'OKC'
					 ,program     => 'OKCRKPOI'
					 ,argument1   => p_contract_id  -- contract id
                                  	 );


 IF l_request_id = 0
 THEN
    my_debug('40: Error submitting request for OKCRKPOI',4);
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 END IF;

-- commit to complete the request submission

    COMMIT;
    my_debug('45: Submitted request to Populates PO interface from Contract.  Request id: ' || l_request_id);
    my_debug('50: Waiting to complete concurrent request',4);
    l_create_po_finished := FND_CONCURRENT.WAIT_FOR_REQUEST(
                                          request_id => l_request_id,
                                          interval   => 30,
                                          max_wait => 1800,
                                          phase => x_phase,
                                          status => x_status,
                                          dev_phase => x_dev_phase,
                                          dev_status => x_dev_status,
                                          message => x_message);

    IF l_create_po_finished THEN
        my_debug('60: l_create_po_finished equal true',4);
    ELSE
        my_debug('70: l_create_po_finished equal false',4);
    END IF;

    IF x_dev_phase = 'COMPLETE' AND x_dev_status IN ('NORMAL','WARNING')
     THEN

        -- If x_dev_phase = 'COMPLETE' and x_dev_status IN ('NORMAL','WARNING')
        -- the PO was successfully created. Notify the buyer of a PO creation
        -- Select po_number and contract number modifier

        SELECT po.segment1
	    INTO l_po_number
	    FROM po_headers_all po
	    WHERE po.po_header_id =
	    ( SELECT object1_id1
		  FROM okc_k_rel_objs rel
          WHERE rel.chr_id            = p_contract_id       -- for the current contract
	      AND rel.cle_id IS NULL                     -- related obj pertains to header
	      AND rel.rty_code          = g_crj_rty_code -- for PO creation
	      AND rel.jtot_object1_code = g_crj_chr_jtot_object_code -- correct jtot object
	    );

        SELECT contract_number_modifier
        INTO l_k_number_modifier
        FROM okc_k_headers_b
        WHERE id = p_contract_id;

        l_k_number_modifier := nvl(l_k_number_modifier, ' ');

        my_debug('80: create po from contract conc program finished successfully',4);
        OKC_API.set_message(p_app_name => 'OKC'
		                   ,p_msg_name => 'OKC_K2PO_NOTIF_SUBJECT'
		                   ,p_token1	 => 'PONUMBER'
		                   ,p_token1_value => l_po_number
                           ,p_token2	 => 'KNUMBER'
		                   ,p_token2_value => p_contract_id
                           ,p_token3	 => 'KNUMMODIFIER'
		                   ,p_token3_value => l_k_number_modifier
                            );
        x_return_status := OKC_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        x_msg_data  := '';
    ELSE
        my_debug('90: create po from contract conc program finished with error',4);
        OKC_API.set_message(p_app_name => 'OKC'
		                   ,p_msg_name => 'OKC_ERROR_PO_CREATED_DETAILS'
		                   ,p_token1	 => 'ERROR'
		                   ,p_token1_value => sqlerrm
                           ,p_token2	 => 'KNUMBER'
		                   ,p_token2_value => p_contract_id
                           ,p_token3	 => 'KNUMMODIFIER'
		                   ,p_token3_value => l_k_number_modifier
                            );

        x_return_status := OKC_API.G_RET_STS_ERROR;
        x_msg_data := sqlerrm;
        x_msg_count := 1;
    END IF;


    my_debug('100: x_dev_phase equal' || x_dev_phase , 4);
    my_debug('110: x_dev_status equal' || x_dev_status , 4);

EXCEPTION

WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR
THEN

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    OKC_API.set_message(p_app_name => 'OKC'
		     ,p_msg_name => 'OKC_ERROR_CONC_REQUEST'
		     ,p_token1	 => 'ERROR'
		     ,p_token1_value => sqlerrm || '-' || p_contract_id
                 );

    x_msg_data      := 'Could not submit concurrent request';
    x_msg_count     := 1;

WHEN OTHERS
THEN
    x_return_status := okc_api.g_ret_sts_unexp_error;

     OKC_API.set_message(p_app_name => 'OKC'
		     ,p_msg_name => 'OKC_ERROR_PO_FROM_K'
		     ,p_token1	 => 'ERROR'
		     ,p_token1_value => sqlerrm || '-' || p_contract_id
                 );

    x_msg_data := sqlerrm;
    x_msg_count := 1;

END submit_req_for_po_creation;
------------------------------------------------------------
-- Procedure submit_pdoi_errors_report - local
-- ......
-- ....
------------------------------------------------------------

PROCEDURE submit_pdoi_errors_report( p_api_version              IN  NUMBER
			            ,p_init_msg_list            IN  VARCHAR2
			            ,p_chr_id                   IN  okc_k_headers_b.ID%TYPE
                                   ,x_return_status            OUT NOCOPY VARCHAR2
			               ,x_msg_count                OUT NOCOPY NUMBER
			               ,x_msg_data                 OUT NOCOPY VARCHAR2)IS

l_request_id              fnd_concurrent_requests.request_id%TYPE;

BEGIN

-- May need to add checks here (later) to not fire these processes if
-- the initial ones errored out

-- Submit the request to report errors on the interface
 my_debug('20: Submitting request for PDOI Interface errors');


 l_request_id := fnd_request.submit_request(
					  application => 'PO'
					 ,program     => 'POXPIERR'
					 ,sub_request => FALSE         -- Indicates that this is a child
								       -- of the parent request
					 ,argument1   => 'PO_DOCS_OPEN_INTERFACE' -- Source program
					 ,argument2   => 'N'          -- Purge Data
					 );

 IF l_request_id = 0
 THEN
    my_debug('40: Error submitting request for POXPIERR',4);
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 END IF;

 my_debug('60: Submitted request for PDOI Interface errors.  Request id: ' || l_request_id);

END submit_pdoi_errors_report;

------------------------------------------------------------
-- Procedure my_Debug - local
------------------------------------------------------------

PROCEDURE my_debug( p_msg    IN VARCHAR2,
				p_level  IN NUMBER   DEFAULT 1,
				p_module IN VARCHAR2 DEFAULT 'OKC') IS
 BEGIN

    fnd_file.put_line(fnd_file.log, g_pkg_name ||':'|| p_msg);
 -- okc_debug.Log(p_msg,p_level,p_module);
 -- dbms_output.put_line(substr(p_msg,1,240));

END my_debug;

-------------------------------------------------------------------------------
-- Procedure:       notify_buyer
-- Version:         1.0
-- Purpose: notify the buyer of a purchase order creation
-------------------------------------------------------------------------------
PROCEDURE notify_buyer(p_api_version                  IN NUMBER
                      		,p_init_msg_list                IN VARCHAR2
                      		,p_commit                       IN VARCHAR2
		      		,p_application_name             IN VARCHAR2
		      		,p_message_subject              IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		      		,p_message_body 	        IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		      		,p_message_body_token1 		IN VARCHAR2
		      		,p_message_body_token1_value 	IN VARCHAR2
		      		,p_message_body_token2 		IN VARCHAR2
		      		,p_message_body_token2_value 	IN VARCHAR2
                                ,p_message_body_token3 		IN VARCHAR2
		      		,p_message_body_token3_value 	IN VARCHAR2
		      		,p_trace_mode      		IN VARCHAR2
                      		,p_chr_id     		        IN OKC_K_HEADERS_B.ID%TYPE
                      		,x_k_buyer_name               OUT NOCOPY VARCHAR2
                      		,x_return_status   	 OUT NOCOPY VARCHAR2
                      		,x_msg_count                    OUT NOCOPY NUMBER
                      		,x_msg_data                     OUT NOCOPY VARCHAR2) IS

l_api_name	 CONSTANT VARCHAR2(30) 	:= 'notify_buyer';
l_api_version	 CONSTANT NUMBER	:=1;
lx_return_status VARCHAR2(1)	 	:= OKC_API.G_RET_STS_SUCCESS;
lx_msg_count	 NUMBER			;
lx_msg_data	 FND_NEW_MESSAGES.message_text%TYPE;

BEGIN
  lx_return_status := OKC_API.START_ACTIVITY(
					p_api_name      => l_api_name,
					p_pkg_name      => g_pkg_name,
					p_init_msg_list => p_init_msg_list,
					l_api_version   => l_api_version,
					p_api_version   => p_api_version,
					p_api_type      => g_api_type,
					x_return_status => lx_return_status);

  IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;



  -- trace mode initialization turned ON
  IF p_trace_mode = okc_api.g_true OR
	FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y'  -- FND: Debug Log Enabled
  THEN
	okc_util.init_trace;
  END IF;

  -- call the main routine

  OKC_CREATE_PO_FROM_K_PVT.notify_buyer(
                   p_api_version      	        => l_api_version
                  ,p_init_msg_list    	        => OKC_API.G_FALSE
                  ,p_application_name	        => p_application_name
		      ,p_message_subject  		  => p_message_subject
		      ,p_message_body    		  => p_message_body
		      ,p_message_body_token1	        => p_message_body_token1
		      ,p_message_body_token1_value	  => p_message_body_token1_value
		      ,p_message_body_token2	        => p_message_body_token2
		      ,p_message_body_token2_value	  => p_message_body_token2_value
                  ,p_message_body_token3	        => p_message_body_token3
		      ,p_message_body_token3_value	  => p_message_body_token3_value
		      ,p_chr_id                       => p_chr_id
                  ,x_k_buyer_name                 => x_k_buyer_name
                  ,x_return_status                => lx_return_status
                  ,x_msg_count                    => lx_msg_count
                  ,x_msg_data                     => lx_msg_data
                  );

  -- trace mode initialization turned OFF
  IF p_trace_mode = okc_api.g_true  OR  FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
	okc_util.stop_trace;
  END IF;


  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;



  -- if we got this far, then we are successful
  IF p_commit = OKC_API.G_TRUE THEN
    COMMIT;
  END IF;

  -- end activity
  OKC_API.END_ACTIVITY(x_msg_count		=> lx_msg_count,
  		       x_msg_data		=> lx_msg_data);

  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OTHERS',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);
END notify_buyer;


END OKC_CREATE_PO_FROM_K_PUB;

/
