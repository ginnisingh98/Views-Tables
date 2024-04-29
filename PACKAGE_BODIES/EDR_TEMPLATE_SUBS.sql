--------------------------------------------------------
--  DDL for Package Body EDR_TEMPLATE_SUBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_TEMPLATE_SUBS" AS
/* $Header: EDRTMPSB.pls 120.2.12000000.1 2007/01/18 05:55:47 appldev ship $ */

--- Status to be returned to indicate workflow ---
	G_YES CONSTANT VARCHAR2(25) := 'COMPLETE:Y';
	G_NO CONSTANT varchar2(25) := 'COMPLETE:N';

--- This is the file category for eRecord Template ----
	G_TMP_CATEGORY CONSTANT VARCHAR2(30) := 'EDR_EREC_TEMPLATE';

-- EDR_TEMPLATE_SUBS.UPLOAD_TEMPLATE
-- This procedure is a post process function called from RTFUPLOAF Workflow process.
-- It gets the name of file being approved and converts it to XSLFO if it is EDR_EREC_TEMPLATE
-- and File Extension is RTF.

-- P_ITEMTYPE  The internal name for the item type. Item types are
--             defined in the Oracle Workflow Builder.

-- P_ITEMKEY   A string that represents a primary key generated
--             by the workflow-enabled application for the item
--             type. The string uniquely identifies the item within
--             an item type.

-- P_ACTID     The ID number of the activity from which this
--              procedure is called.

-- P_FUNCMODE  The execution mode of the activity. If the activity is
--             a function activity, the mode is either RUN or
--             CANCEL. If the activity is a notification activity,
--             with a postnotification function, then the mode
--             can be RESPOND, FORWARD, TRANSFER,
--             TIMEOUT, or RUN.

-- P_RESULTOUT If a result type is specified in the Activities
--             properties page for the activity in the Oracle
--             Workflow Builder, this parameter represents the
--             expected result that is returned when the
--             procedure completes. The possible results are:
--             COMPLETE:<result_code> activity completes
--             with the indicated result code. The result code
--             must match one of the result codes specified in the
--             result type of the function activity.
--             WAITING-activity is pending, waiting on
--             another activity to complete before it completes.
--             An example is the Standard AND activity.
--             DEFERRED:<date>activity is deferred to a
--             background engine for execution until a given date.
--             <date> must be of the format:
--             to_char(<date_string>, wf_engine.date_format)
--             NOTIFIED:<notification_id>:<assigned_user>-a
--             n external entity is notified that an action must be
--             performed. A notification ID and an assigned user
--             can optionally be returned with this result. Note
--             that the external entity must call CompleteActivity( )
--             to inform the Workflow Engine when the action
--             completes.
--             ERROR:<error_code>-activity encounters an
--             error and returns the indicated error code.

PROCEDURE UPLOAD_TEMPLATE
(
 		  	   P_ITEMTYPE VARCHAR2,
   			   P_ITEMKEY VARCHAR2,
 			   P_ACTID NUMBER,
 			   P_FUNCMODE VARCHAR2,
 			   P_RESULTOUT OUT NOCOPY VARCHAR2
)
AS
  			   L_EVENT_NAME VARCHAR2(240);
 			   L_EVENT_KEY VARCHAR2(240);

                           L_PRODUCT VARCHAR2(50);
 			   L_AUTHOR VARCHAR2(100);
 			   L_FILE_NAME VARCHAR2(300);

			   l_VERSION VARCHAR2(15);
			   L_VERSION_NUM NUMBER(15,3);

			   L_UPLOAD_STATUS VARCHAR2(300);
			   L_EXTENSION VARCHAR2(30);
			   L_RETURN_STATUS VARCHAR2(25);
			   L_CATEGORY_NAME VARCHAR2(30);
			   L_EVENT_STATUS VARCHAR2(15);
			   L_POS NUMBER;

			   -- VARIABLES USED FOR FND_ATTACHED_DOCUMENTS_PKG API
			   L_ROW_ID 	VARCHAR2(240);
			   L_ATTACHED_DOCUMENT_ID NUMBER;
			   L_FND_DOCUMENT_ID NUMBER;
			   L_MEDIA_ID NUMBER;
			   L_CATEGORY_ID NUMBER;
			   L_POSITION NUMBER;

			   -- VARIABLES USED FOR CALL TO JSP WITH UTL_HTTP PKG
			   L_HTTP_RESPONSE VARCHAR2(1024);
			   L_STATUS VARCHAR2(1024);
			   L_HTTP_URL VARCHAR2(1024);

			   l_no_approval_status VARCHAR2(20);
			   l_success_status VARCHAR2(20);

                           -- Bug : 3950047
                           -- VARIABLES RELATED TO UTL_HTTP ERROR HANDLING
			   L_PAGENOTFOUND EXCEPTION;
			   PROFILE_ERROR EXCEPTION;
                           REQUEST_FAIL EXCEPTION;
                           INIT_FAIL EXCEPTION;

                           L_agent  VARCHAR2(1000);
                     -- Bug 4450651  Start
                      l_src_req  varchar2(100);
                    -- Bug 4450651  End


  CURSOR  C_GET_ID IS
   		  SELECT FND_ATTACHED_DOCUMENTS_S.NEXTVAL
		  FROM DUAL;
BEGIN
         L_EVENT_NAME :=WF_ENGINE.GETITEMATTRTEXT(
						ITEMTYPE=>P_ITEMTYPE,
                                                ITEMKEY=>P_ITEMKEY,
                                                ANAME=>'EVENT_NAME');

         L_EVENT_KEY :=WF_ENGINE.GETITEMATTRTEXT(
                                                ITEMTYPE=>P_ITEMTYPE,
                                                ITEMKEY=>P_ITEMKEY,
                                                ANAME=>'EVENT_KEY');

         L_RETURN_STATUS := G_NO;
         L_HTTP_RESPONSE := NULL ;
         L_no_approval_status  := 'NO APPROVAL';
	 l_success_status  := 'SUCCESS';




 	 WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','EVENT NAME '||L_EVENT_NAME);
 	 WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','EVENT KEY '||L_EVENT_KEY);

 	 --START WITH CHECKING THAT THE FILE IS AN RTF TEMPLATE
 	 EDR_FILE_UTIL_PUB.GET_FILE_NAME(L_EVENT_KEY, L_FILE_NAME);

	 WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','FILE NAME'||L_FILE_NAME);

	 --LOCATE BEGINNING OF THE EXTENSION IN THE FILE NAME STRING TO USE
 	 --POSITION TO SPLIT UP THE FILE NAME
 	 L_EXTENSION := NULL;
         L_POS := INSTR(L_FILE_NAME, '.',-1,1);

        IF L_POS <> 0 THEN
      	L_EXTENSION := SUBSTR(L_FILE_NAME,L_POS+1,LENGTH(L_FILE_NAME));
        END IF;

	 WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','EXTENSION '||L_EXTENSION);


	 --ONLY IF THE EXTENSION OF THE FILE IS XSL PROCEED FURTHER
	 IF (UPPER(L_EXTENSION) = 'RTF') THEN
	  		--GET THE CATEGORY OF THE FILE
		 	EDR_FILE_UTIL_PUB.GET_CATEGORY_NAME(L_EVENT_KEY,L_CATEGORY_NAME);
		 	WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','CATEGORY NAME'||L_CATEGORY_NAME);


			-- CHECK THE FILE CATEGORY AFTER CHECKING EXTENSION, WHETHER ITS ERECORD TEMPLATE
			IF (L_CATEGORY_NAME = G_TMP_CATEGORY) THEN
			 		WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','EDR ERCORD TEMPLATE CATEGORY NAME FOUND');
					L_RETURN_STATUS := G_YES;
			END IF;
 	 END IF;

	 --NOW THAT WE HAVE MADE CERTAIN THAT THE FILE EXTENSION IS RTF AND THE CATEGORY
 	 --IS E RECORD TEMPLATE GO AHEAD AND TRY TO UPLOAD IT

 	 IF (L_RETURN_STATUS = G_YES) THEN
 	 	WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','RETURN STATUS IS YES...STARTING UPLOAD');

		--SET THE FILE AUTHOR ATTRIBUTE IN WORKFLOW
 		EDR_FILE_UTIL_PUB.GET_AUTHOR_NAME(L_EVENT_KEY, L_AUTHOR);
 		WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','AUTHOR '||L_AUTHOR);
 		WF_ENGINE.SETITEMATTRTEXT(P_ITEMTYPE, P_ITEMKEY, 'AUTHOR',L_AUTHOR);
		WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','AUTHOR NAME SET IN THE WORKFLOW');

		--set the file name
		wf_engine.setitemattrtext(p_itemtype, p_itemkey, 'RTF_NAME', l_file_name);
		wf_log_pkg.string(6, 'UPLOAD_TEMPLATE','file name set in the workflow');

		--set the version
		EDR_FILE_UTIL_PUB.GET_VERSION_LABEL(l_event_key, l_version);
		l_version_num := l_version;
		wf_log_pkg.string(6, 'UPLOAD_TEMPLATE','version num '||l_version_num);
		wf_engine.setitemattrtext(p_itemtype, p_itemkey, 'VERSION', l_version);

		--set the product name of the file owner product
		EDR_FILE_UTIL_PUB.GET_ATTRIBUTE(l_event_key, 'ATTRIBUTE1', l_product);
		wf_log_pkg.string(6, 'UPLOAD_XSL','PRODUCT ' ||l_product);
		wf_engine.setitemattrtext(p_itemtype, p_itemkey, 'PRODUCT', l_product);

 		-- GET THE EVENT STATUS FROM WORKFLOW
 		L_EVENT_STATUS := WF_ENGINE.GETITEMATTRTEXT(P_ITEMTYPE,P_ITEMKEY,'FILE_STATUS');
 		WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','EVENT STATUS'||L_EVENT_STATUS);

		--IF THE STATUS IS SUCCESS ONLY THEN UPLOAD IT TO THE DATABASE


		IF (L_EVENT_STATUS = l_success_status OR L_EVENT_STATUS = l_no_approval_status ) THEN

 			-- GET THE FILE CATEGORY ID
 			SELECT CATEGORY_ID INTO L_CATEGORY_ID
			FROM
	   			FND_DOCUMENT_CATEGORIES
 			WHERE
	    		        NAME = L_CATEGORY_NAME;

                        -- GET THE DOCUMENT ID FROM FND SEQUENCE CURSOR
		        OPEN C_GET_ID;
  				 FETCH C_GET_ID INTO L_ATTACHED_DOCUMENT_ID;
  		        CLOSE C_GET_ID;
         		-- CREATE A ROW IN FND_ATTACHED_DOCUMENTS
                        FND_ATTACHED_DOCUMENTS_PKG.INSERT_ROW(
                                                         X_ROWID=>L_ROW_ID,
                                                         X_ATTACHED_DOCUMENT_ID=>L_ATTACHED_DOCUMENT_ID,
                                                         X_DOCUMENT_ID=>L_FND_DOCUMENT_ID,
                                                         X_CREATION_DATE=>SYSDATE,
                                                         X_CREATED_BY=>FND_GLOBAL.USER_ID,
                                                         X_LAST_UPDATE_DATE=>SYSDATE,
                                                         X_LAST_UPDATED_BY=>FND_GLOBAL.USER_ID,
                                                         X_LAST_UPDATE_LOGIN=>FND_GLOBAL.USER_ID,
                                                         X_SEQ_NUM=>1,
                                                         X_ENTITY_NAME=>'EDR_XSLFO_TEMPLATE',
                                                         X_COLUMN1=>NULL,
                                                         X_PK1_VALUE=>L_EVENT_KEY,
                                                         X_PK2_VALUE=>NULL,
                                                         X_PK3_VALUE=>NULL,
                                                         X_PK4_VALUE=>NULL,
                                                         X_PK5_VALUE=>NULL,
                                                         X_AUTOMATICALLY_ADDED_FLAG=>'N',
                                                         X_DATATYPE_ID=>6,
                                                         X_CATEGORY_ID=>L_CATEGORY_ID,
                                                         X_SECURITY_TYPE=>1,
                                                         X_SECURITY_ID=>-1,
                                                         X_PUBLISH_FLAG=>'N',
                                                         X_STORAGE_TYPE=>1,
                                                         X_USAGE_TYPE=>'S',
                                                         X_LANGUAGE=>USERENV('LANG'),
                                                         X_DESCRIPTION=>'XSL FO TEMPLATE',
                                                         X_FILE_NAME=>L_FILE_NAME,
                                                         X_MEDIA_ID=>L_MEDIA_ID,
                                                         X_DOC_ATTRIBUTE_CATEGORY=>NULL,
                                                         X_DOC_ATTRIBUTE1=>NULL,
                                                         X_DOC_ATTRIBUTE2=>NULL,
                                                         X_DOC_ATTRIBUTE3=>NULL,
                                                         X_DOC_ATTRIBUTE4=>NULL,
                                                         X_DOC_ATTRIBUTE5=>NULL,
                                                         X_DOC_ATTRIBUTE6=>NULL,
                                                         X_DOC_ATTRIBUTE7=>NULL,
                                                         X_DOC_ATTRIBUTE8=>NULL,
                                                         X_DOC_ATTRIBUTE9=>NULL,
                                                         X_DOC_ATTRIBUTE10=>NULL,
                                                         X_CREATE_DOC=>'N');

            -- CALL THE JSP TO CREATE AN XSL FO IN THE FND LOB TABLES.
            WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','SENDING REQUEST FOR XSL CONVERSION TO JSP');

	    BEGIN

		L_AGENT := FND_PROFILE.VALUE('APPS_JSP_AGENT');

       -- Bug 4450651 Start
           l_src_req := null;
           l_src_req :=  EDR_XDOC_UTIL_PKG.GET_SERVICE_TICKET_STRING(EDR_CONSTANTS_GRP.g_service_name);

	 	L_HTTP_URL := L_AGENT || '/OA_HTML/jsp/edr/iSignPublisherHandler.jsp?eventId=' || L_EVENT_KEY
				      || '&' || 'mediaId='||L_MEDIA_ID || '&' || 'repository=ISIGN'|| '&' || 'src_req=' || l_src_req;

          	WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','URL' ||  L_HTTP_URL);
        -- Bug 4450651 end


                --Bug 3950047 : Start
                --Call EDR UTL_HTTP wrapper for using HTTP
                  L_HTTP_RESPONSE  := EDR_XDOC_UTIL_PKG.REQUEST_HTTP(P_REQUEST_URL=> L_HTTP_URL);
                --Bug 3950047 : End

                EXCEPTION WHEN OTHERS THEN
                BEGIN
                      WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','EXCEPTION  IN GETTING RESPONSE' ||  SQLERRM  );
                      RAISE;
                END;

           END;

          WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','RESPONSE FROM JSP' || L_HTTP_RESPONSE);

           -- READ THE STATUS FROM JSP RESPONSE
           --L_POSITION := INSTR(L_HTTP_RESPONSE,'=',1);
           --L_HTTP_RESPONSE := SUBSTR(L_HTTP_RESPONSE,L_POSITION+1);
           --L_POSITION :=INSTR(L_HTTP_RESPONSE,';',1);
           --L_STATUS := SUBSTR(L_HTTP_RESPONSE,1,L_POSITION-1);

           L_STATUS := UPPER(TRIM(L_HTTP_RESPONSE));
           WF_LOG_PKG.STRING(6, 'UPLOAD_RTF','STATUS ' || L_STATUS);

           --Check if UTL_HTTP request returned with JSp Not found message.
           IF (INSTR(SUBSTR(L_HTTP_RESPONSE,1,1024), 'FileNotFoundException', 1) > 0) THEN
	  	 RAISE L_PAGENOTFOUND;
	   END IF;

           -- THE JSP RETURNS EITHER SUCCESS OR FAILURE AS STATUS CODE AND GIVE APPROPRIATE MESSAGES.
           IF NOT (INSTR(L_STATUS, L_SUCCESS_STATUS, 1) > 0) THEN
                          FND_MESSAGE.SET_NAME('EDR','EDR_FILES_TEMPLATE_FAILURE');
                          FND_MESSAGE.SET_TOKEN('ERROR_MSG',L_STATUS);
                          L_UPLOAD_STATUS := FND_MESSAGE.GET();
           ELSE
                          L_UPLOAD_STATUS := FND_MESSAGE.GET_STRING('EDR','EDR_FILES_TEMPLATE_SUCCESS');
           END IF;

       ELSIF (L_EVENT_STATUS = 'REJECTED') THEN
 			  L_UPLOAD_STATUS :=  FND_MESSAGE.GET_STRING('EDR','EDR_FILES_APPROVAL_REJECTION');

       ELSE
           FND_MESSAGE.SET_NAME('EDR','EDR_FILES_TEMPLATE_FAILURE');
           FND_MESSAGE.SET_TOKEN('ERROR_MSG','WF EVENT FAILED');
           L_UPLOAD_STATUS := FND_MESSAGE.GET();
       END IF;

     END IF;

     WF_ENGINE.SETITEMATTRTEXT(P_ITEMTYPE, P_ITEMKEY, 'UPLOAD_STATUS',L_UPLOAD_STATUS);
     P_RESULTOUT := L_RETURN_STATUS;

EXCEPTION
        WHEN L_PAGENOTFOUND THEN
	BEGIN
		 FND_MESSAGE.SET_NAME('EDR','EDR_FILES_TEMPLATE_HTTPFAILURE');
		 FND_MESSAGE.SET_TOKEN('ERROR_MSG','JSP NOT FOUND');
                 L_UPLOAD_STATUS := FND_MESSAGE.GET();
		 WF_ENGINE.SETITEMATTRTEXT(P_ITEMTYPE, P_ITEMKEY, 'UPLOAD_STATUS',L_UPLOAD_STATUS);
 	         P_RESULTOUT := L_RETURN_STATUS;
	END;
        --  Bug 3950047 : Start
        --  Improved Error Handling
        WHEN PROFILE_ERROR THEN
        BEGIN
                FND_MESSAGE.SET_NAME('EDR','EDR_PROFILE_CHECK_FAILURE');
                FND_MESSAGE.SET_TOKEN('PROFILENAME','FND_DB_WALLET_DIR');
                L_UPLOAD_STATUS := FND_MESSAGE.GET();
                WF_ENGINE.SETITEMATTRTEXT(P_ITEMTYPE,P_ITEMKEY, 'UPLOAD_STATUS', L_UPLOAD_STATUS);
                P_RESULTOUT := L_RETURN_STATUS;
        END;
	WHEN REQUEST_FAIL THEN
	BEGIN
                FND_MESSAGE.SET_NAME('EDR','EDR_FILES_TEMPLATE_HTTPFAILURE');
		FND_MESSAGE.SET_TOKEN('ERROR_MSG','HTTP REQUEST FAILED');
	        L_UPLOAD_STATUS := FND_MESSAGE.GET();
	        WF_ENGINE.SETITEMATTRTEXT(P_ITEMTYPE, P_ITEMKEY, 'UPLOAD_STATUS',L_UPLOAD_STATUS);
  	        P_RESULTOUT := L_RETURN_STATUS;
	END;
        WHEN INIT_FAIL THEN
	BEGIN
                FND_MESSAGE.SET_NAME('EDR','EDR_FILES_TEMPLATE_HTTPFAILURE');
		FND_MESSAGE.SET_TOKEN('ERROR_MSG','UTL_HTTP INIT FAILED');
	        L_UPLOAD_STATUS := FND_MESSAGE.GET();
	        WF_ENGINE.SETITEMATTRTEXT(P_ITEMTYPE, P_ITEMKEY, 'UPLOAD_STATUS',L_UPLOAD_STATUS);
  	        P_RESULTOUT := L_RETURN_STATUS;
	END;
        WHEN OTHERS THEN
	BEGIN
	        L_UPLOAD_STATUS := SQLERRM;
	        WF_ENGINE.SETITEMATTRTEXT(P_ITEMTYPE, P_ITEMKEY, 'UPLOAD_STATUS',L_UPLOAD_STATUS);
  	        P_RESULTOUT := L_RETURN_STATUS;
	END;
        -- Bug 3950047 : End

END UPLOAD_TEMPLATE;

END EDR_TEMPLATE_SUBS;

/
