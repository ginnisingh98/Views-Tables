--------------------------------------------------------
--  DDL for Package Body EDR_XDOC_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_XDOC_UTIL_PKG" AS
/* $Header: EDRXDUB.pls 120.12.12000000.1 2007/01/18 05:56:47 appldev ship $ */

--Bug 5256904: Start
--This procedure is used to delete the temporary parameters that were set prior to the PDF e-record
--creation process.
PROCEDURE DELETE_TEMP_PARAMS
(
  P_ERECORD_ID IN NUMBER
)

IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  DELETE FROM EDR_ERESPARAMETERS_T
  WHERE PARENT_ID = P_ERECORD_ID
  AND   PARENT_TYPE = 'EDR_XDOC_PARAMS';

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_XDOC_UTIL_PKG');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','DELETE_TEMP_PARAMS');
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_XDOC_UTIL_PKG.DELETE_TEMP_PARAMS',
                      FALSE
                     );
    end if;
    APP_EXCEPTION.RAISE_EXCEPTION;
END DELETE_TEMP_PARAMS;

--This procedure sets those parameters required for the AppsContext initialization
--into the ERES Temp Table.
PROCEDURE SET_TEMP_PARAMS
(
  P_ERECORD_ID IN NUMBER
)

IS

L_NLS_DATE_FORMAT VARCHAR2(4000);
L_NLS_DATE_LANGUAGE VARCHAR2(4000);
L_NLS_LANGUAGE VARCHAR2(4000);
L_NLS_NUMERIC_CHARACTERS VARCHAR2(4000);
L_NLS_SORT VARCHAR2(4000);
L_NLS_TERRITORY VARCHAR2(4000);
L_CURRENT_LANG  VARCHAR2(4000);
L_USER_ID NUMBER;
L_RESP_ID NUMBER;
L_RESP_APPL_ID NUMBER;
L_SECURITY_GROUP_ID NUMBER;
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  L_USER_ID := FND_GLOBAL.USER_ID();
  L_RESP_ID := FND_GLOBAL.RESP_ID();
  L_RESP_APPL_ID := FND_GLOBAL.RESP_APPL_ID();
  L_SECURITY_GROUP_ID :=FND_GLOBAL.SECURITY_GROUP_ID();
  L_NLS_DATE_FORMAT := FND_GLOBAL.NLS_DATE_FORMAT;
  L_NLS_DATE_LANGUAGE := FND_GLOBAL.NLS_DATE_LANGUAGE;
  L_NLS_LANGUAGE := FND_GLOBAL.NLS_LANGUAGE;
  L_NLS_NUMERIC_CHARACTERS := FND_GLOBAL.NLS_NUMERIC_CHARACTERS;
  L_NLS_SORT := FND_GLOBAL.NLS_SORT;
  L_NLS_TERRITORY := FND_GLOBAL.NLS_TERRITORY;
  L_CURRENT_LANG := USERENV('LANG');

  --We will log the NLS Parameters in the EVENT Level.
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,'edr.plsql.EDR_XDOC_UTIL_PKG.SET_TEMP_PARAMS',
                   'These are the NLS parameters for the e-record ID '||p_erecord_id);
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,'edr.plsql.EDR_XDOC_UTIL_PKG.SET_TEMP_PARAMS',
                   'NLS Date Format: '||L_NLS_DATE_FORMAT);
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,'edr.plsql.EDR_XDOC_UTIL_PKG.SET_TEMP_PARAMS',
                   'NLS Date Language: '||L_NLS_DATE_LANGUAGE);
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,'edr.plsql.EDR_XDOC_UTIL_PKG.SET_TEMP_PARAMS',
                   'NLS Language: '||L_NLS_LANGUAGE);
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,'edr.plsql.EDR_XDOC_UTIL_PKG.SET_TEMP_PARAMS',
                   'NLS Numeric Characters: '||L_NLS_NUMERIC_CHARACTERS);
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,'edr.plsql.EDR_XDOC_UTIL_PKG.SET_TEMP_PARAMS',
                   'NLS Sort: '||L_NLS_SORT);
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,'edr.plsql.EDR_XDOC_UTIL_PKG.SET_TEMP_PARAMS',
                   'NLS Territory: '||L_NLS_TERRITORY);

  end if;


  INSERT INTO EDR_ERESPARAMETERS_T(PARAM_ID,
                                   PARENT_ID,
                                   PARENT_TYPE,
                                   PARAM_NAME,
                                   PARAM_VALUE)

                            VALUES(EDR_ERESPARAMETERS_T_S.NEXTVAL,
			           P_ERECORD_ID,
				   'EDR_XDOC_PARAMS',
				   'NLS_DATE_FORMAT',
				   L_NLS_DATE_FORMAT);

  INSERT INTO EDR_ERESPARAMETERS_T(PARAM_ID,
                                   PARENT_ID,
                                   PARENT_TYPE,
                                   PARAM_NAME,
                                   PARAM_VALUE)

                            VALUES(EDR_ERESPARAMETERS_T_S.NEXTVAL,
			           P_ERECORD_ID,
				   'EDR_XDOC_PARAMS',
				   'NLS_DATE_LANGUAGE',
				   L_NLS_DATE_LANGUAGE);

  INSERT INTO EDR_ERESPARAMETERS_T(PARAM_ID,
                                   PARENT_ID,
                                   PARENT_TYPE,
                                   PARAM_NAME,
                                   PARAM_VALUE)

                            VALUES(EDR_ERESPARAMETERS_T_S.NEXTVAL,
			           P_ERECORD_ID,
				   'EDR_XDOC_PARAMS',
				   'NLS_LANGUAGE',
				   L_NLS_LANGUAGE);

  INSERT INTO EDR_ERESPARAMETERS_T(PARAM_ID,
                                   PARENT_ID,
                                   PARENT_TYPE,
                                   PARAM_NAME,
                                   PARAM_VALUE)

                            VALUES(EDR_ERESPARAMETERS_T_S.NEXTVAL,
			           P_ERECORD_ID,
				   'EDR_XDOC_PARAMS',
				   'NLS_NUMERIC_CHARACTERS',
				   L_NLS_NUMERIC_CHARACTERS);

  INSERT INTO EDR_ERESPARAMETERS_T(PARAM_ID,
                                   PARENT_ID,
                                   PARENT_TYPE,
                                   PARAM_NAME,
                                   PARAM_VALUE)

                            VALUES(EDR_ERESPARAMETERS_T_S.NEXTVAL,
			           P_ERECORD_ID,
				   'EDR_XDOC_PARAMS',
				   'NLS_SORT',
				   L_NLS_SORT);

  INSERT INTO EDR_ERESPARAMETERS_T(PARAM_ID,
                                   PARENT_ID,
                                   PARENT_TYPE,
                                   PARAM_NAME,
                                   PARAM_VALUE)

                            VALUES(EDR_ERESPARAMETERS_T_S.NEXTVAL,
			           P_ERECORD_ID,
				   'EDR_XDOC_PARAMS',
				   'NLS_TERRITORY',
				   L_NLS_TERRITORY);

  INSERT INTO EDR_ERESPARAMETERS_T(PARAM_ID,
                                   PARENT_ID,
                                   PARENT_TYPE,
                                   PARAM_NAME,
                                   PARAM_VALUE)

                            VALUES(EDR_ERESPARAMETERS_T_S.NEXTVAL,
			           P_ERECORD_ID,
				   'EDR_XDOC_PARAMS',
				   'CURRENT_LANG',
				   L_CURRENT_LANG);
  INSERT INTO EDR_ERESPARAMETERS_T(PARAM_ID,
                                   PARENT_ID,
                                   PARENT_TYPE,
                                   PARAM_NAME,
                                   PARAM_VALUE)

                            VALUES(EDR_ERESPARAMETERS_T_S.NEXTVAL,
			           P_ERECORD_ID,
				   'EDR_XDOC_PARAMS',
				   'USER_ID',
				   TO_CHAR(L_USER_ID));

  INSERT INTO EDR_ERESPARAMETERS_T(PARAM_ID,
                                   PARENT_ID,
                                   PARENT_TYPE,
                                   PARAM_NAME,
                                   PARAM_VALUE)

                            VALUES(EDR_ERESPARAMETERS_T_S.NEXTVAL,
			           P_ERECORD_ID,
				   'EDR_XDOC_PARAMS',
				   'RESP_ID',
				   TO_CHAR(L_RESP_ID));

  INSERT INTO EDR_ERESPARAMETERS_T(PARAM_ID,
                                   PARENT_ID,
                                   PARENT_TYPE,
                                   PARAM_NAME,
                                   PARAM_VALUE)

                            VALUES(EDR_ERESPARAMETERS_T_S.NEXTVAL,
			           P_ERECORD_ID,
				   'EDR_XDOC_PARAMS',
				   'RESP_APPL_ID',
                                   TO_CHAR(L_RESP_APPL_ID));

  INSERT INTO EDR_ERESPARAMETERS_T(PARAM_ID,
                                   PARENT_ID,
                                   PARENT_TYPE,
                                   PARAM_NAME,
                                   PARAM_VALUE)

                            VALUES(EDR_ERESPARAMETERS_T_S.NEXTVAL,
			           P_ERECORD_ID,
				   'EDR_XDOC_PARAMS',
				   'SECURITY_GROUP_ID',
				   TO_CHAR(L_SECURITY_GROUP_ID));

  COMMIT;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','EDR_XDOC_UTIL_PKG');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','SET_TEMP_PARAMS');
    if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'edr.plsql.EDR_XDOC_UTIL_PKG.SET_TEMP_PARAMS',
                      FALSE
                     );
    end if;
    APP_EXCEPTION.RAISE_EXCEPTION;
END SET_TEMP_PARAMS;
--Bug 5256904: End



-- EDR_XDOC_UTIL_PKG.GENERATE_ERECORD Procedure is called from STORE_ERECORD
-- Procedure of RULE FUNCTION. Its purpose is to call the JSP with all the
-- required parameters passed in URL and return ERECORD or return error message
-- if there is any error in this processing.

-- P_EDR_EVENT_ID  - Unique event id for the event being executed, for which
--                   eRecord is to be generated
-- P_ERECORD_ID    - ERecord Id for the eRecord to be generated.
-- P_STYLE_SHEET_REPOSITORY - Name of template repository to be used to generate the
--                            eRecord
-- P_STYLE_SHEET   - Template File Name as Setup in AME / Transaction Variable for
--                   this event
-- P_STYLE_SHEET_VER - Version Label of the template file as setup in AME / Transaction Variable for
--                   this event
-- X_OUTPUT_FORMAT - Format of eRecord Output viz. PDF, DOC, HTML, TEXT
-- X_ERROR_CODE    - Error Code in case of any errors
-- X_ERROR_MESSAGE - Error Message in case of any errors.

-- Bug 3170251 : start : rvsingh
-- Bug 3761813 : start : rvsingh
PROCEDURE GENERATE_ERECORD
(p_edr_event_id  NUMBER,
 p_erecord_id    NUMBER,
 p_style_sheet_repository VARCHAR2,
 p_style_sheet   VARCHAR2,
 p_style_sheet_ver    VARCHAR2,
 p_application_code VARCHAR2,
 p_redline_mode VARCHAR2,
 x_output_format OUT NOCOPY VARCHAR2,
 x_error_code    OUT NOCOPY NUMBER,
 x_error_msg     OUT NOCOPY VARCHAR2
)
as
  l_http_response VARCHAR2(20480);
  l_url  VARCHAR2(1000);
  l_position Number;
  l_subr1 VARCHAR2(100);
  l_status VARCHAR2(100);
  l_output_format  VARCHAR2(100);
  L_PAGENOTFOUND EXCEPTION;
  l_agent varchar2(1000);
  PROFILE_ERROR exception;
  REQUEST_FAIL exception;
  INIT_FAIL exception;
  -- Bug 4450651 Start
  l_src_req  varchar2(100);
  -- Bug 4450651 End
  -- Bug 5170875 : start
 l_USER_ID NUMBER;
 l_RESP_ID NUMBER;
 l_RESP_APPL_ID NUMBER;
 l_SECURITY_GROUP_ID NUMBER;
  -- Bug 5170875 : End
  l_module_name varchar2(50) := 'edr.plsql.EDR_XDOC_UTIL_PKG.GENERATE_ERECORD';
begin
  l_http_response := null;
  l_status := null;
  l_output_format  := null;
  L_url  := null;

  l_src_req := null;
  l_src_req :=  GET_SERVICE_TICKET_STRING(EDR_CONSTANTS_GRP.g_service_name);


  l_agent := FND_PROFILE.VALUE('APPS_JSP_AGENT');
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,l_module_name,
                   'APPS JSP Agent is: '||l_agent);
  end if;

  --Bug 5256904: Start
  SET_TEMP_PARAMS(P_ERECORD_ID);
  --Bug 5256904: End

  --   Bug 3761813 : start : new query string ''redLineMode'  added in HTTP request
  l_url := l_agent || '/OA_HTML/jsp/edr/EDRRuleXMLPublisherHandler.jsp?eventId=' || p_edr_event_id;
  l_url := l_url || '&' || 'repository=' || p_style_sheet_repository || '&'|| 'erecordId=' || p_erecord_id;
  l_url := l_url || '&' || 'ssName=' ||p_style_sheet || '&' || 'ssVer=' || p_style_sheet_ver || '&' || 'src_req=' || l_src_req;
  l_url := l_url || '&' || 'appCode=' ||p_application_code;
  l_url := l_url || '&' || 'redLineMode=' ||p_redline_mode ;
  --  Bug 3761813 : END

  --These will be picked up when the AppsContext is initialized in the Java Layer.

  -- Call UTL_HTTP using EDR_XDOC_UTIL_PKG.REQUEST_HTTP package wrapper
  l_http_response := EDR_XDOC_UTIL_PKG.REQUEST_HTTP( p_request_url => l_url);

  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,l_module_name,
                   'HTTP Response from JSP: '||l_http_response);
  end if;

  --Bug 5256904: Start
  DELETE_TEMP_PARAMS(P_ERECORD_ID);
  --bug 5256904: End

  --Check if UTL_HTTP request returned with JSP Not found message.
  IF ((INSTR(SUBSTR(L_HTTP_RESPONSE,1,1024), 'FileNotFoundException', 1) > 0)
    OR (INSTR(SUBSTR(L_HTTP_RESPONSE,1,1024), '404 Not Found',1) > 0))
  THEN
    RAISE L_PAGENOTFOUND;
  END IF;

  l_position := instr(l_http_response,'=',1);
  l_http_response := substr(l_http_response,l_position+1);
  l_position :=instr(l_http_response,';',1);
  l_status := substr(l_http_response,1,l_position-1);

  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,l_module_name,
                   'Status from JSP: '||l_status);
  end if;

  l_position := instr(l_http_response,'=',1);
  l_http_response := substr(l_http_response,l_position+1);
  l_position :=instr(l_http_response,';',1);
  --p_stylesheet_type  := substr(l_http_response,1,l_position-1);
  -- Bug 4731317 : start

  -- Error Message
  l_position := instr(l_http_response,'=',1);
  l_http_response := substr(l_http_response,l_position+1);
  l_position :=instr(l_http_response,';',1);
  x_error_msg := substr(l_http_response,1,l_position-1);
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,l_module_name,
                   'Error message from JSP: '||x_error_msg);
  end if;

  l_http_response := substr(l_http_response,l_position+1);

  -- OUTPUT FORMAT
  l_position := instr(l_http_response,'=',1);
  l_http_response := substr(l_http_response,l_position+1);
  l_position :=instr(l_http_response,';',1);
  x_output_format := substr(l_http_response,1,l_position-1);
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,l_module_name,
                   'Output format from JSP: '||x_output_format);
  end if;

  -- Bug 4731317 : end

  -- PDF Generation was successful.
  if(l_status = 'SUCCESS') then
    x_error_code := 0;
    return;
  end if;


  -- PDF Generation failed. Can be some issue with template
  if(INSTR(l_status,'FAILURE',1) > 0) then
    x_error_code := 40;
    return;
  end if;

  -- XSL FO for given template is missing
  if (l_status = 'RTFTEMPLATEMISSING') then
    x_error_code := 10;
    x_error_msg := l_status;
    return;
  end if;

  -- ERecord PSIG XML was not Accessible
  if (l_status = 'ERECORDMISSING') then
    x_error_code := 20;
    x_error_msg := l_status;
    return;
  end if;

  -- Fatal Error in case of database connection or context not available.
  if (l_status = 'FATALERROR') then
    x_error_code := 30;
    x_error_msg := x_error_msg;
    return;
  else
    begin
      -- Unhandled error mean error not known to us and currently not handled
      x_error_msg := 'UNHANDLEDERROR';
      x_error_code := 100;
      return;
    end;
  end if;
EXCEPTION
  WHEN L_PAGENOTFOUND THEN
    BEGIN
      X_ERROR_MSG := 'JSPMISSING';
      X_ERROR_CODE := 505;
      END;
  WHEN PROFILE_ERROR THEN
    BEGIN
      fnd_message.set_name('EDR','EDR_PROFILE_CHECK_FAILURE');
      fnd_message.set_token('PROFILENAME','FND_DB_WALLET_DIR');
      X_ERROR_MSG := FND_MESSAGE.GET;
      X_ERROR_CODE := 100;
    END;
  WHEN REQUEST_FAIL THEN
    BEGIN
      X_ERROR_MSG := 'JSPREQFAIL';
      X_ERROR_CODE := 500;
    END;
  WHEN INIT_FAIL THEN
    BEGIN
      X_ERROR_MSG := 'JSPREQFAIL';
      X_ERROR_CODE := 500;
    END;
  WHEN OTHERS THEN
    BEGIN
      X_ERROR_MSG := SQLERRM;
      X_ERROR_CODE := 800;
    END;
End GENERATE_ERECORD;


-- EDR_XDOC_UTIL_PKG.EDR_CREATE_ATTACHEMENT is called from EDRRuleXMLPublisher Object.
-- It creates an FND Attachment for the eRecord PDF to be generated and returns
-- the file_id created in FND_LOBS table.

-- P_ERECORD_ID    - ERecord Id for the eRecord to be generated.
-- P_FILE_NAME     - Name of EReocrd File
-- P_STYLE_SHEET   - ERecord File Description
-- P_CONTENT_TYPE  - ERecord File Content Type
-- X_File_ID       - MediaId (FND_LOBS File Id) of the ERecord Attachement
--                   created

Procedure EDR_CREATE_ATTACHMENT (
                     p_eRecord_ID NUMBER,
                     P_FILE_NAME VARCHAR2,
                     p_description VARCHAR2,
                     p_content_type  VARCHAR2,
                     p_file_format VARCHAR2,
                     p_source_lang  VARCHAR2,
                     x_FILE_id  OUT NOCOPY NUMBER
                     )

IS

/* 	Cursors */
CURSOR c_get_category IS
   SELECT category_id
   FROM  fnd_document_categories
   WHERE name = 'ERES';

LocalCatRecord c_get_category%ROWTYPE;

 /* Used to get the next attached_document_id  for a new attachment SKARIMIS*/
CURSOR  c_get_id IS
   SELECT fnd_attached_documents_s.nextval
   FROM dual;

/* 	Numeric Variables */
L_ROW_ID	        VARCHAR2(240);
L_CATEGORY_ID		NUMBER;
L_FND_DOCUMENT_ID	NUMBER;
L_ATTACHED_DOCUMENT_ID 	NUMBER;
l_user_id 		number;
l_user_name             varchar2(240);

BEGIN


/* Select the category id */
   OPEN c_get_category;
   FETCH c_get_category INTO LocalCatRecord;
   l_category_id := LocalCatRecord.category_id;
   CLOSE c_get_category;


  OPEN c_get_id;
  FETCH c_get_id INTO l_attached_document_id;
  CLOSE c_get_id;

  /* Set the Security Context to access EDR_PSIG_DOCUMENTS */
  edr_ctx_pkg.set_secure_attr;

  select document_requester into l_user_name
  from edr_psig_documents where document_id = p_eRecord_Id;

  /* Get the requestors user-id for Last Updated by field in Attachments */
  select user_id into l_user_id
  from fnd_user where user_name = l_user_name;

  -- Bug 4045057 : Start
  -- Unset the secure context

  edr_ctx_pkg.unset_secure_attr;

  -- Bug 4045057 : End

  FND_ATTACHED_DOCUMENTS_PKG.Insert_Row(X_Rowid=>l_row_id,
               X_attached_document_id=>l_attached_document_id,
               X_document_id=>l_fnd_document_id,
               X_creation_date=>SYSDATE,
               X_created_by=> L_USER_ID,
               X_last_update_date=>SYSDATE,
               X_last_updated_by=>L_USER_ID,
               X_last_update_login=>L_USER_ID,
               X_seq_num=>1,
               X_entity_name=>'ERECORD',
               X_column1=>NULL,
               X_pk1_value=>p_eRecord_ID,
               X_pk2_value=>NULL,
               X_pk3_value=>NULL,
               X_pk4_value=>NULL,
               X_pk5_value=>NULL,
               X_automatically_added_flag=>'N',
               X_datatype_id=>6,
               X_category_id=>l_category_id,
               --Bug 4381237: Start
               --We want to set the security type to 4.
               X_security_type=>4,
               --Security ID should be set to null
               X_security_id=>null,
               --Bug 4381237: End
               X_publish_flag=>'N',
               X_storage_type=>1,
               X_usage_type=>'S',
               X_language=>p_source_lang,
               X_description=>p_description,
               X_file_name=>p_file_name,
               X_media_id=>x_file_id,
               X_doc_attribute_category=>null,
               X_doc_attribute1=>null,
               X_doc_attribute2=>null,
               X_doc_attribute3=>null,
               X_doc_attribute4=>null,
               X_doc_attribute5=>null,
               X_doc_attribute6=>null,
               X_doc_attribute7=>null,
               X_doc_attribute8=>null,
               X_doc_attribute9=>null,
               X_doc_attribute10=>null,
               X_create_doc=>'N');

   INSERT into FND_LOBS
   	(file_id,
    	 file_name,
    	 file_data,
    	 file_content_type,
    	 file_format)
    VALUES
    	(x_file_id,
    	 p_file_name,
    	 empty_blob(),
    	 p_content_type,
    	 p_file_format);

END EDR_CREATE_ATTACHMENT;

-- EDR_XDOC_UTIL_PKG.GET_NTF_MESSAGE_BODY is called from Workflow while rendering the
-- Notification for rendering E-Record Message "Please read the attached ... eRecord_XXXX.pdf"
-- This procedure follows PLSQL Document Attrubute Format API Call conventions

-- p_document_id   - This field is used to pass eRecord Id -- > ERECORD_ID
--                   E_RECORD_ID to be part of message body in file name
-- p_display_type  - Format of display text/palin, text/html etc...
-- x_document      - Document rendered in VARCHAR2 string is returned
--                            eRecord
-- x_document_type - Document type i.e. text, rtf, doc, etc...

Procedure GET_NTF_MESSAGE_BODY
(	   p_document_id in varchar2,
	   p_display_type in varchar2,
	   x_document in out nocopy varchar2,
	   x_document_type in out nocopy varchar2
)
Is
Begin
   fnd_message.set_name('EDR','EDR_EREC_ATT_NTF_BODY');
   fnd_message.set_token('ERECORD_ID',p_document_id);
   x_document := fnd_message.get;
   x_document_type := 'text/plain';
End GET_NTF_MESSAGE_BODY;

-- Bug 3950047 : Start

-- EDR_XDOC_UTIL_PKG.REQUEST_HTTP provides a wrapper over UTL_HTTP calls
-- It performs all the checks required on URL before calling UTL_HTTP.REQUEST
-- This FUNCTION follows PLSQL API Call conventions.

-- p_request_url    - Request URL over which UTL_HTTP call is to be made.
-- returns varchar2 - HTTP_RESPONSE returned from UTL_HTTP.REQUEST

-- throws           - profile_error which must be caught in calling procedure.

function REQUEST_HTTP
(
         p_request_url in varchar2

) return varchar2
is
    l_http_response varchar2(20480);
 --    Bug : 5170875 : start
    l_module_name varchar2(50) := 'edr.plsql.EDR_XDOC_UTIL_PKG.REQUEST_HTTP';
 --    Bug : 5170875 : end
    l_wallet varchar2(1000);
    profile_error exception;
begin
   l_http_response := null;
   l_wallet := null;

   if(instr(upper(p_request_url),'HTTPS' ) > 0 ) then
         if(fnd_profile.defined('FND_DB_WALLET_DIR')) then
           l_wallet := fnd_profile.value('FND_DB_WALLET_DIR');
             if(l_wallet is null) then
               raise profile_error;
             end if;
         else
               raise profile_error;
         end if;

         -- Append file: in the beginning and set the wallet directory
         -- Before UTL_HTTP call.

         l_wallet := 'file:' || l_wallet;
         utl_http.set_wallet(l_wallet);
   end if;
 --    Bug : 5170875 : start
  if (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_EVENT,l_module_name,
                   'HTTP Request to JSP: '||p_request_url);
  end if;
 --    Bug : 5170875 : End
   l_http_response := utl_http.request( URL=> p_request_url);
   return l_http_response;
END REQUEST_HTTP;

-- Bug 3950047 : End

-- Bug 4450651 start
-- Gets the ticket for use with an HTTP service.
-- Returns string va;ue of a pair of 16-byte secure random raw values concatenated into
-- a 32-byte raw, or null upon failure.  The first 16 bytes are the
-- current ticket value, and the last 16 bytes are the previous ticket
-- value.


function GET_SERVICE_TICKET_STRING
(
         p_request_service_name in varchar2
) return varchar2 IS PRAGMA AUTONOMOUS_TRANSACTION;
    l_service_ticket varchar2(100);
    X     raw(16) := hextoraw('00000000000000000000000000000000');
begin
   l_service_ticket := null;
        delete from FND_HTTP_SERVICE_TICKETS where SERVICE = p_request_service_name;
        insert into FND_HTTP_SERVICE_TICKETS
              (SERVICE, TICKET, OLD_TICKET,END_DATE)  values (p_request_service_name, X, X,sysdate);
          commit;
        l_service_ticket := FND_HTTP_TICKET.GET_SERVICE_TICKET_STRING(p_request_service_name);
   return l_service_ticket;
   END GET_SERVICE_TICKET_STRING;


-- Compare service ticket

function VALIDATE_SERVICE_TICKET(P_TICKET in varchar2)
    return varchar2
  is
    X_TICKET    VARCHAR2(100);
  begin

    X_TICKET := GET_SERVICE_TICKET_STRING(EDR_CONSTANTS_GRP.g_service_name);

    IF(FND_HTTP_TICKET.COMPARE_SERVICE_TICKET_STRINGS(P_TICKET,X_TICKET)) THEN
            return EDR_CONSTANTS_GRP.g_success_service_req_status;
    ELSE
             return EDR_CONSTANTS_GRP.g_fail_service_req_status;
    END IF;
  end VALIDATE_SERVICE_TICKET;
-- Bug 4450651 End

End EDR_XDOC_UTIL_PKG;

/
