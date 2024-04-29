--------------------------------------------------------
--  DDL for Package Body CLN_INV_REJECT_NOTIF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_INV_REJECT_NOTIF_PVT" AS
    /* $Header: CLN3C4B.pls 120.2 2006/05/10 23:56:24 smuthuav noship $ */

    l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

    -- Start of comments
    --	API name 	: SEPARATE_REASON_CODE
    --	Type		: Private.
    --	Pre-reqs	: None.
    --	Function	: It separates the line number from the given reasoncode
    --	Version	        : Current version	1.0
    --			  Initial version 	1.0
    --  Notes           :
    -- End of comments

    PROCEDURE SEPARATE_REASON_CODE (p_reason_code IN VARCHAR2,
                                    x_err_string  OUT NOCOPY VARCHAR2,
                                    x_line_num    OUT NOCOPY NUMBER) AS

      l_pos        NUMBER;
      l_error_code VARCHAR(30);
      l_errmsg     VARCHAR2(1000);

    BEGIN

         IF (l_debug_level <= 2) THEN
                cln_debug_pub.Add('Entering the procedure SEPARATE_REASON_CODE with the parameter '|| p_reason_code ,2);
         END IF;

	 l_pos := instr(p_reason_code, ':');
         x_err_string := substr(p_reason_code,l_pos+1);
         x_line_num := substr(p_reason_code,0,l_pos-1);
         x_line_num := to_number(x_line_num);

         IF (l_debug_level <= 2) THEN
               cln_debug_pub.Add('Exiting the procedure SEPARATE_REASON_CODE with parameters.... ', 2);
	  END IF;

	 IF (l_debug_level <= 1) THEN
	       cln_debug_pub.Add('LINE NUMBER:'|| x_line_num ,1);
	       cln_debug_pub.Add('ERROR STRING:'|| x_err_string ,1);
         END IF;

    EXCEPTION

         WHEN OTHERS THEN
                  l_error_code := SQLCODE;
                  l_errmsg     := SQLERRM;

		  IF (l_debug_level <= 5) THEN
	               cln_debug_pub.Add('Exception in SEPARATE_REASON_CODE' || ':'  || l_error_code || ':' ||l_errmsg,5);
                  END IF;

    END SEPARATE_REASON_CODE;


    -- Start of comments
    --	API name 	: ADD_MESSAGES_TO_COLL_HISTORY
    --	Type		: Private.
    --	Pre-reqs	: None.
    --	Function	: Adds the messages to the CH.
    --	Version	        : Current version	1.0
    --		          Initial version 	1.0
    --  Notes           :
    -- End of comments

    PROCEDURE ADD_MESSAGES_TO_COLL_HISTORY( p_internal_control_number IN NUMBER,
                                            p_line_num                IN NUMBER,
                                            p_err_string              IN VARCHAR2,
                                            p_id                      IN VARCHAR2 ) AS

      l_error_code      VARCHAR(30);
      l_errmsg          VARCHAR2(1000);
      l_parameter_list  wf_parameter_list_t;

    BEGIN

        IF (l_debug_level <= 2) THEN
              cln_debug_pub.Add('...Entering the procedure ADD_MESSAGES_TO_COLL_HISTORY with parameters...', 2);
        END IF;

	IF (l_debug_level <= 1) THEN
	       cln_debug_pub.Add('INTERNAL CONTROL NUMBER:'|| p_internal_control_number ,1);
	       cln_debug_pub.Add('P_ID:'|| p_id ,1);
	       cln_debug_pub.Add('REFERENCE_ID1:'|| p_line_num ,1);
	       cln_debug_pub.Add('DETAIL_MESSAGE:'|| p_err_string ,1);
        END IF;

	l_parameter_list := wf_parameter_list_t();
	wf_event.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',p_internal_control_number,l_parameter_list);
	wf_event.AddParameterToList('REFERENCE_ID1',p_line_num,l_parameter_list);
	wf_event.AddParameterToList('DETAIL_MESSAGE',p_err_string,l_parameter_list);

	-- Add the error string to the Collaboration History
	IF (l_debug_level <= 2) THEN
	       cln_debug_pub.Add('Raising the ----oracle.apps.cln.ch.collaboration.addmessage----- event',2);
	END IF;

	BEGIN
	     wf_event.raise(p_event_name => 'oracle.apps.cln.ch.collaboration.addmessage',
                            p_event_key  =>  p_id,
                            p_parameters =>  l_parameter_list);

            IF (l_debug_level <= 1) THEN
	              cln_debug_pub.Add('Add Message event raised',1);
            END IF;

	    IF (l_debug_level <= 2) THEN
	              cln_debug_pub.Add('Exiting the procedure CLN_INV_REJECT_NOTIF_PVT.ADD_MESSAGES_TO_COLL_HISTORY', 2);
            END IF;

       EXCEPTION
          WHEN OTHERS THEN
	            l_error_code := SQLCODE;
		    l_errmsg     := SQLERRM;

		    IF (l_debug_level <= 5) THEN
		              cln_debug_pub.Add('Exception in raising the ----oracle.apps.cln.ch.collaboration.addmessage-----
                              event' || ':'  || l_error_code || ':' || l_errmsg,5);
                    END IF;
     END;
   END ADD_MESSAGES_TO_COLL_HISTORY;


    -- Start of comments
    --	API name 	: CALL_AR_API
    --	Type		: Private.
    --	Pre-reqs	: None.
    --	Function	: Calls 'ar_confirmation.initiate_confirmation_process' to send the notification
    --	Version	        : Current version	1.0
    --			  Initial version 	1.0
    --  Notes           :
    -- End of comments

    PROCEDURE  CALL_AR_API(p_reason_code             IN VARCHAR2,
                           p_id                      IN VARCHAR2,
                           p_description             IN VARCHAR2,
                           p_internal_control_number IN NUMBER) AS

	l_error_code VARCHAR(30);
	l_errmsg     VARCHAR2(1000);

	BEGIN
	   IF (l_debug_level <= 2) THEN
	           cln_debug_pub.Add('Entering the procedure CLN_INV_REJECT_NOTIF_PVT.CALL_AR_API', 2);
           END IF;

	   IF (l_debug_level <= 2) THEN
	          cln_debug_pub.Add('Calling the -----ar_confirmation.initiate_confirmation_process----API with the parameter'  ||
                  p_reason_code ,2);
	   END IF;

	   BEGIN
	          ar_confirmation.initiate_confirmation_process(p_status      =>'10',
                                                                p_id          => p_id,
                                                                p_reason_code => p_reason_code,
                                                                p_description => p_description,
                                                                p_int_ctr_num => p_internal_control_number);

		  IF (l_debug_level <= 2) THEN
		           cln_debug_pub.Add('Exting the --ar_confirmation.initiate_confirmation_process----API',2);
			   cln_debug_pub.Add('Exiting the procedure CLN_INV_REJECT_NOTIF_PVT.CALL_AR_API', 2);
	          END IF;

	  EXCEPTION
	         WHEN OTHERS THEN
		           l_error_code := SQLCODE;
			   l_errmsg     := SQLERRM;

			   IF (l_debug_level <= 5) THEN
			          cln_debug_pub.Add('Exception in calling the procedure----
				  ar_confirmation.initiate_confirmation_process--:'||l_error_code || ':' || l_errmsg,5);
	                   END IF;
	END;
    END CALL_AR_API;


    -- Start of comments
    --	API name 	: PROCESS_INBOUND_3C4
    --	Type		: Private.
    --	Pre-reqs	: None.
    --	Function	: This procedure
    --                     (1). Separates individual reason codes from the value of the parameter
    --                          'p_reason_code' and calls the ar_confirmation.initiate_confirmation_process'
    --                          API the number of times as the number of times the reason codes are.
    --                     (2). Updates the Collaboration History
    --	Version	        : Current version	1.0
    --			  Initial version 	1.0
    --  Notes           : This procedure is called from the XML map(3C4 Inbound)
    -- End of comments

    PROCEDURE PROCESS_INBOUND_3C4 (p_internal_control_number  IN NUMBER,
                                   p_reason_code              IN VARCHAR2,
                                   p_invoice_num              IN VARCHAR2,
                                   p_description              IN VARCHAR2,
				   p_tp_id                    IN NUMBER) AS

     -- declare the local variables
     l_all_reason_code         VARCHAR2(3000);
     l_header_reason_code      VARCHAR2(1000);
     l_line_reason_code        VARCHAR2(3000);
     l_errmsg                  VARCHAR2(2000);
     l_error_code              VARCHAR2(30);
     l_internal_control_number NUMBER;
     l_comma_position          NUMBER;
     l_party_id                NUMBER;
     l_party_site_id           NUMBER;
     l_err_string              VARCHAR2(2000);
     l_line_num                NUMBER;
     l_invoice_ref_id          VARCHAR2(255);  -- l_invoice_ref_id is the document_transfer_id : customer_trx_id
     l_trx_number              VARCHAR2(255);
     l_org_id                  NUMBER;
     l_doc_transfer_id         VARCHAR2(200);
     l_cust_trx_id             VARCHAR2(200);
     l_parameter_list          wf_parameter_list_t;

     BEGIN
        IF (l_debug_level <= 2) THEN
              cln_debug_pub.Add('...Entering the procedure CLN_INV_REJECT_NOTIF_PVT.PROCESS_INBOUND_3C4 with parameters ...', 2);
        END IF;

        IF (l_debug_level <= 1) THEN
              cln_debug_pub.Add('Invoice number:'|| p_invoice_num ,1);
              cln_debug_pub.Add('Internal control number:'|| p_internal_control_number ,1);
              cln_debug_pub.Add('Reason Code:'|| p_reason_code ,1);
	       cln_debug_pub.Add('Description'|| p_description ,1);
	      cln_debug_pub.Add('Trading Partner Code:'|| p_tp_id ,1);
        END IF;

	SELECT party_id, party_site_id
        INTO   l_party_id, l_party_site_id
	FROM   ecx_tp_headers
        WHERE  tp_header_id = p_tp_id;

        IF (l_debug_level <= 1) THEN
              cln_debug_pub.Add('Party ID : '|| l_party_id, 1);
              cln_debug_pub.Add('Party Site ID : '|| l_party_site_id, 1);
        END IF;

	-- get the customer_trx_id and doc_trnsfr_id,org_id
	BEGIN

	SELECT DOCUMENT_TRANSFER_ID,CUSTOMER_TRX_ID,RCT.ORG_ID
	INTO   l_doc_transfer_id,l_cust_trx_id,l_org_id
        FROM   AR_DOCUMENT_TRANSFERS ADT,RA_CUSTOMER_TRX_ALL RCT, HZ_CUST_SITE_USES_ALL CSU, HZ_CUST_ACCT_SITES_ALL CAS, HZ_CUST_ACCOUNTS_ALL CA
        WHERE  RCT.TRX_NUMBER = p_invoice_num
	       AND ADT.SOURCE_ID = RCT.CUSTOMER_TRX_ID
	       AND ADT.SOURCE_TABLE ='RA_CUSTOMER_TRX' -- Bug #4938901.
	       AND RCT.BILL_TO_CUSTOMER_ID = CA.CUST_ACCOUNT_ID
	       AND RCT.BILL_TO_SITE_USE_ID = CSU.SITE_USE_ID
	       AND RCT.COMPLETE_FLAG = 'Y'
	       AND CAS.PARTY_SITE_ID = l_party_site_id;

      EXCEPTION
              WHEN OTHERS THEN
                   l_error_code := SQLCODE;
                   l_errmsg     := SQLERRM;

		   IF (l_debug_level <= 5) THEN
	                cln_debug_pub.Add('Exception ' || ':'  || l_error_code || ':' || l_errmsg,5);
                    END IF;
       END;


	l_invoice_ref_id := l_doc_transfer_id ||':'||l_cust_trx_id;

	IF (l_debug_level <= 1) THEN
              cln_debug_pub.Add('DOCUMENT_TRANSFER_ID: '|| l_doc_transfer_id, 1);
              cln_debug_pub.Add('CUSTOMER_TRX_ID: '|| l_cust_trx_id, 1);
              cln_debug_pub.Add('ORG_ID: '|| l_org_id, 1);
	      cln_debug_pub.Add('l_invoice_ref_id: '|| l_invoice_ref_id, 1);

        END IF;

        IF (l_debug_level <= 2) THEN
              cln_debug_pub.Add('Raising the ----oracle.apps.cln.ch.collaboration.update----- event,with parameters ',2);
        END IF;

        IF (l_debug_level <= 1) THEN
              cln_debug_pub.Add('DOCUMENT_NO: '|| p_invoice_num, 1);
              cln_debug_pub.Add('XMLG_INTERNAL_CONTROL_NUMBER: '|| p_internal_control_number, 1);
              cln_debug_pub.Add('ORG_ID: '|| l_org_id, 1);
        END IF;

        l_parameter_list:= wf_parameter_list_t();

        -- add the parameters to the parameter list
        wf_event.AddParameterToList('DOCUMENT_NO',p_invoice_num,l_parameter_list);
        wf_event.AddParameterToList('XMLG_INTERNAL_CONTROL_NUMBER',p_internal_control_number,l_parameter_list);
        wf_event.AddParameterToList('MESSAGE_TEXT','CLN_CH_XML_CONSUMED_SUCCESS',l_parameter_list);
        wf_event.AddParameterToList('ORG_ID',l_org_id,l_parameter_list);

	-- raise the 'oracle.apps.cln.ch.collaboration.update' event for Collaboration History Updation
        BEGIN
              wf_event.raise(p_event_name => 'oracle.apps.cln.ch.collaboration.update', -- Bug #5219307
		             p_event_key  =>  l_invoice_ref_id,
		             p_parameters =>  l_parameter_list);

              IF (l_debug_level <= 1) THEN
                      cln_debug_pub.Add('----Collaboration History update event raised---',1);
              END IF;

        EXCEPTION
              WHEN OTHERS THEN
                   l_error_code := SQLCODE;
                   l_errmsg     := SQLERRM;

		   IF (l_debug_level <= 5) THEN
	                cln_debug_pub.Add('Exception in calling the ----oracle.apps.cln.ch.collaboration.update----- API' ||
                       ':'  || l_error_code || ':' || l_errmsg,5);
                    END IF;
       END;

        -- separate the error reason strings from the original reason code
        l_all_reason_code:=rtrim(ltrim(p_reason_code));

        IF (l_debug_level <= 1) THEN
              cln_debug_pub.Add('Original complete reason code:'|| l_all_reason_code ,1);
        END IF;

      --Check if the string is of format %HeaderCode,linenum:linecode,linenum:linecode%
       IF  (substr(l_all_reason_code,1,1) <> '%') and  (substr(l_all_reason_code,length(l_all_reason_code),1) <> '%') THEN
            --This is just a message description and is not in the expected %HeaderCode,linenum:linecode,linenum:linecode% format

	    IF (l_debug_level <= 1) THEN
              cln_debug_pub.Add('This is just a message description and is not in the expected %HeaderCode,
	                          linenum:linecode,linenum:linecode% format',1);
            END IF;

	     IF (l_debug_level <= 2) THEN
              cln_debug_pub.Add('Calling ---- CALL_AR_API----' ,2);
             END IF;

	     CALL_AR_API(p_reason_code             => l_all_reason_code,
                         p_id                      => l_invoice_ref_id,
                         p_description             => l_all_reason_code,
                         p_internal_control_number => p_internal_control_number);

	    IF (l_debug_level <= 2) THEN
              cln_debug_pub.Add('Calling ---- ADD_MESSAGES_TO_COLL_HISTORY---- ',2);
            END IF;

	    -- Add the error description to the CH
            ADD_MESSAGES_TO_COLL_HISTORY( p_internal_control_number => p_internal_control_number,
                                          p_line_num                => null,
                                          p_err_string              => l_all_reason_code,
                                          p_id                      => p_invoice_num);

       ELSE
            -- The error string obtained may be in  %HeaderCode,linenum:linecode,linenum:linecode% format
	    -- remove % at start and end
	    l_all_reason_code := substr(l_all_reason_code,2,length(l_all_reason_code)-2);

            --Get the header reason code
            l_comma_position := instr(l_all_reason_code,',');

	    IF (l_debug_level <= 1) THEN
              cln_debug_pub.Add('The String has a comma at '|| l_comma_position,1);
            END IF;

            IF (l_comma_position=0) or (l_comma_position is NULL) THEN
	         -- The string should be %% or %header%
		 IF  l_all_reason_code IS NULL  THEN
                         -- The string should be %%
		       l_header_reason_code := nvl(l_header_reason_code,'UNEXPECTED ERROR');
                       l_all_reason_code := NULL;

		       IF (l_debug_level <= 1) THEN
                             cln_debug_pub.Add('Sending -- UNEXPECTED ERROR: String may be of form %%-- for l_header_reason_code',1);
                       END IF;
	         ELSE
		       IF (l_debug_level <= 1) THEN
                             cln_debug_pub.Add('Only Header',1);
                       END IF;

		       l_header_reason_code := l_all_reason_code;
                       l_all_reason_code := NULL;
		 END IF;

            ELSE
	        l_header_reason_code := substr(l_all_reason_code,1,l_comma_position-1);

		IF (l_debug_level <= 1) THEN
                             cln_debug_pub.Add('l_header_reason_code :'||l_header_reason_code ,1);
                END IF;

                l_all_reason_code := substr(l_all_reason_code,l_comma_position+1);

		IF (l_debug_level <= 1) THEN
                             cln_debug_pub.Add('l_all_reason_code :'||l_all_reason_code ,1);
                END IF;

               --When the string may be  %,linenum:linecode...% or %,%
               IF  (not (length(l_header_reason_code) > 0)) or  TO_CHAR((length(l_header_reason_code))) is NULL THEN
	           --When the string is %,%
		   IF  (not ( length(l_all_reason_code)> 0 ))   or   TO_CHAR((length(l_all_reason_code))) is NULL THEN

                       l_header_reason_code := nvl(l_header_reason_code,'UNEXPECTED ERROR');
                       l_all_reason_code := NULL;

		       IF (l_debug_level <= 1) THEN
                             cln_debug_pub.Add('l_header_reason_code is set as UNEXPECTED ERROR: String may be of form %,%',1);
                       END IF;

		   ELSE

		      -- When the string is %,linenum:linecode%
		      l_header_reason_code := NULL;

		      IF (l_debug_level <= 1) THEN
                             cln_debug_pub.Add('The header reason code is set to NULL and l_all_reason_code is '|| l_all_reason_code,1);
                      END IF;

	          END IF;
	       END IF;

	   END IF;

	   -- Send Notification and update Collaboration History for Header
	   IF l_header_reason_code is not null and length(l_header_reason_code) > 0 THEN

	            IF (l_debug_level <= 2) THEN
                         cln_debug_pub.Add('Calling ---- CALL_AR_API----' ,2);
                    END IF;

	            IF (l_debug_level <= 1) THEN
                          cln_debug_pub.Add('p_reason_code:' || l_header_reason_code ,1);
	                  cln_debug_pub.Add('p_description:' || p_description ,1);
	            END IF;

	            CALL_AR_API(p_reason_code             => l_header_reason_code,
                                p_id                      => l_invoice_ref_id,
                                p_description             => p_description,
                                p_internal_control_number => p_internal_control_number);

                   IF (l_debug_level <= 2) THEN
                        cln_debug_pub.Add('Calling ---- ADD_MESSAGES_TO_COLL_HISTORY----' ,2);
                   END IF;

                   IF (l_debug_level <= 1) THEN
                        cln_debug_pub.Add('p_err_string:' || l_header_reason_code ,1);
	           END IF;

	           -- add the reason code to the collaboration history
                   ADD_MESSAGES_TO_COLL_HISTORY( p_internal_control_number => p_internal_control_number,
                                                 p_line_num                => NULL,
                                                 p_err_string              => l_header_reason_code,
                                                 p_id                      => p_invoice_num);
            END IF;

            --take action for eachline
	    WHILE l_all_reason_code is not null and length(l_all_reason_code) > 0  LOOP

                  l_comma_position := instr(l_all_reason_code,',');

		  IF (l_comma_position=0) THEN
                         l_line_reason_code := l_all_reason_code;
			 l_all_reason_code := NULL;

			 IF (l_debug_level <= 1) THEN
                                 cln_debug_pub.Add('Comma position is zero',1);
				 cln_debug_pub.Add('l_line_reason_code:' || l_all_reason_code ,1);
	                 END IF;

	          ELSE
		         l_line_reason_code := substr(l_all_reason_code,1,l_comma_position-1);
			 l_all_reason_code := substr(l_all_reason_code,l_comma_position+1);

			 IF (l_debug_level <= 1) THEN
                                 cln_debug_pub.Add('Comma position is NOT zero',1);
				 cln_debug_pub.Add('l_line_reason_code:' || l_line_reason_code ,1);
				 cln_debug_pub.Add('l_all_reason_code:' || l_all_reason_code ,1);
	                 END IF;

		 END IF;

                 IF l_line_reason_code is not null and length(l_line_reason_code) > 0 THEN

	               -- take action for line
		       IF (l_debug_level <= 2) THEN
                                 cln_debug_pub.Add('Calling ----SEPARATE_REASON_CODE----API with the following parameters',2);
	               END IF;

		       IF (l_debug_level <= 1) THEN
                                 cln_debug_pub.Add('l_line_reason_code'|| l_line_reason_code,1);
		       END IF;

		       SEPARATE_REASON_CODE(p_reason_code => l_line_reason_code,
                                            x_err_string  => l_err_string,
                                            x_line_num    => l_line_num);

                       IF (l_debug_level <= 2) THEN
                           cln_debug_pub.Add('Calling the ---- CALL_AR_API-----with parameters ',2);
                       END IF;

		      IF (l_debug_level <= 1) THEN
                              cln_debug_pub.Add('p_reason_code:'|| l_err_string ,1);
                              cln_debug_pub.Add('p_description:'|| p_description ,1);
                      END IF;

                     -- Call the AR procedure to send Notification to System Administrator.
                     CALL_AR_API(p_reason_code             => l_err_string,
                                 p_id                      => l_invoice_ref_id,
                                 p_description             => p_description,
                                 p_internal_control_number => p_internal_control_number);

                     IF (l_debug_level <= 2) THEN
                          cln_debug_pub.Add('Calling the ---- ADD_MESSAGES_TO_COLL_HISTORY-----with parameters ',2);
                     END IF;

		     IF (l_debug_level <= 1) THEN
                          cln_debug_pub.Add('p_line_num:'|| l_line_num ,1);
                          cln_debug_pub.Add('p_err_string:'|| l_err_string ,1);
                     END IF;

		     -- add the reason code to the collaboration history
                     ADD_MESSAGES_TO_COLL_HISTORY( p_internal_control_number => p_internal_control_number,
                                                   p_line_num                => l_line_num,
                                                   p_err_string              => l_err_string,
                                                   p_id                      => p_invoice_num);
                END IF;
            END LOOP;

       END IF;

      IF (l_debug_level <= 2) THEN
              cln_debug_pub.Add('Exiting the procedure CLN_INV_REJECT_NOTIF_PVT.PROCESS_INBOUND_3C4', 2);
      END IF;

    EXCEPTION
        WHEN OTHERS THEN
	       l_error_code := SQLCODE;
               l_errmsg     := SQLERRM;

	       IF (l_debug_level <= 5) THEN
	           cln_debug_pub.Add('---Exception in PROCESS_INBOUND_3C4 as ---' || l_error_code || ':' || l_errmsg,5);
               END IF;

    END PROCESS_INBOUND_3C4;


     -- Start of comments
     --	API name 	: NOTIFICATION_PROCESS_3C4_IN
     --	Type		: Private
     --	Pre-reqs	: None.
     --	Function	: This procedure does the notification processing for the 3C4 Inbound. It performs all the
     --                   pre-defined actions defined in the notification code '3C4_01'.
     --	Version	        : Current version	1.0
     --			  Initial version 	1.0
     -- Notes           : This procedure is called from the XML map(3C4 Inbound)
     -- End of comments

     PROCEDURE NOTIFICATION_PROCESS_3C4_IN (p_itemtype       IN VARCHAR2,
                                            p_itemkey        IN VARCHAR2,
                                            p_actid          IN NUMBER,
                                            p_funcmode       IN VARCHAR2,
                                            x_resultout      IN OUT NOCOPY VARCHAR2) AS

      -- declare local variables
      l_notif_code         VARCHAR2(100);
      l_notif_desc         VARCHAR2(100);
      l_status             VARCHAR2(100);
      l_app_ref_id         VARCHAR2(255);
      l_return_code        VARCHAR2(10);
      l_return_desc        VARCHAR2(2000);
      l_coll_pt            VARCHAR2(100);
      l_intrl_cntrl_num    VARCHAR2(100);
      l_errmsg             VARCHAR2(2000);
      l_error_code         VARCHAR2(30);
      l_tp_id              NUMBER;

      BEGIN
           IF (l_debug_level <= 2) THEN
                  cln_debug_pub.Add('Entering the procedure CLN_INV_REJECT_NOTIF_PVT.notification_process_3c4_in', 2);
           END IF;

	   --  get the workflow activity attributes.
	   l_notif_code:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'NOTIF_CODE');

	   IF (l_debug_level <= 1) THEN
                 cln_debug_pub.Add('Notification_code:'|| l_notif_code , 1);
           END IF;

	   l_notif_desc:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'NOTIF_DESC');

	   IF (l_debug_level <= 1) THEN
                 cln_debug_pub.Add('Notification_description:'|| l_notif_desc , 1);
           END IF;

	   l_status:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'STATUS');

	   IF (l_debug_level <= 1) THEN
                cln_debug_pub.Add('Status:'|| l_status , 1);
           END IF;

	   l_tp_id:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'TPID');

	   IF (l_debug_level <= 1) THEN
                cln_debug_pub.Add('Trading Partner ID:'|| l_tp_id , 1);
           END IF;

	   l_app_ref_id :=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'REFERENCE');

	   IF (l_debug_level <= 1) THEN
                cln_debug_pub.Add('Application Reference ID:'|| l_app_ref_id  , 1);
           END IF;

	   l_coll_pt:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'COLL_POINT');

	   IF (l_debug_level <= 1) THEN
                cln_debug_pub.Add('Collaboration Point:'|| l_coll_pt, 1);
           END IF;

	   l_intrl_cntrl_num:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'XMLG_INTERNAL_CONTROL_NUMBER');

	   IF (l_debug_level <= 1) THEN
                cln_debug_pub.Add('Internal Control Number:'|| l_intrl_cntrl_num, 1);
           END IF;

	   IF (l_debug_level <= 2) THEN
                cln_debug_pub.Add('Calling the ----CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS----- API with the above parameters...',2);
           END IF;

	   IF (l_debug_level <= 1) THEN
              cln_debug_pub.Add('.....Validating the Error String format......... :',1);
           END IF;

	   --Check if the string is of format %HeaderCode,linenum:linecode,linenum:linecode%

	   IF  (substr(l_notif_desc,1,1) <> '%') and  (substr(l_notif_desc,length(l_notif_desc),1) <> '%') THEN
               IF (l_debug_level <= 1) THEN
                  cln_debug_pub.Add('The error code is just a description',1);
               END IF;

	       l_notif_desc := NULL;
           ELSE

               l_notif_desc := substr(l_notif_desc,2,length(l_notif_desc)-2);

	       IF length(l_notif_desc) = 0 or length(l_notif_desc) = 1 or (length(l_notif_desc) is NULL)  THEN
	           l_notif_desc := 'UNEXPECTED ERROR OCCURED';

	           IF (l_debug_level <= 1) THEN
                      cln_debug_pub.Add('l_notif_desc' || l_notif_desc,1);
                   END IF;

	        ELSE
	           l_notif_desc := NULL;
	        END IF;
          END IF;

	 -- Calls the CLN Notification Processing API to perform the pre-defined actions
         BEGIN
               CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS( x_ret_code            => l_return_code ,
                                                  x_ret_desc            => l_return_desc,
                                                  p_notification_code   => l_notif_code,
                                                  p_notification_desc   => l_notif_desc,
                                                  p_status              => l_status,
                                                  p_tp_id               => l_tp_id,
                                                  p_reference           => l_app_ref_id,
                                                  p_coll_point          => l_coll_pt,
                                                  p_int_con_no          => l_intrl_cntrl_num);

	       IF (l_debug_level <= 2) THEN
                  cln_debug_pub.Add('Exiting the ----CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS----- API with the below parameters...',2);
               END IF;

	       IF (l_debug_level <= 1) THEN
                  cln_debug_pub.Add('Return Code:'|| l_return_code, 1);
		  cln_debug_pub.Add('Return Description:'|| l_return_desc, 1);
               END IF;

          EXCEPTION
            WHEN OTHERS THEN
                 l_error_code := SQLCODE;
                 l_errmsg     := SQLERRM;

		 IF (l_debug_level <= 5) THEN
	              cln_debug_pub.Add('Exception in CLN_NP_PROCESSOR_PKG.TAKE_ACTIONS:' || l_error_code || ' : '||l_errmsg,5);
                 END IF;
         END;

         x_resultout := 'SUCCESS';

      EXCEPTION
          WHEN OTHERS THEN
               l_error_code := SQLCODE;
               l_errmsg     := SQLERRM;

	       IF (l_debug_level <= 5) THEN
	           cln_debug_pub.Add('Exception in NOTIFICATION_PROCESS_3C4_IN:' || l_error_code || ':' || l_errmsg,5);
               END IF;

	       x_resultout := 'ERROR';

	       IF (l_debug_level <= 2) THEN
                  cln_debug_pub.Add('Exiting the ----NOTIFICATION_PROCESS_3C4_IN----- API with Resultout as ...'||x_resultout,2);
               END IF;

      END NOTIFICATION_PROCESS_3C4_IN;

      BEGIN
        l_debug_level:= to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

END CLN_INV_REJECT_NOTIF_PVT;

/
