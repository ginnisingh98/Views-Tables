--------------------------------------------------------
--  DDL for Package Body QP_JAVA_ENGINE_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_JAVA_ENGINE_UTIL_PUB" AS
/* $Header: QPXJUTLB.pls 120.2.12010000.3 2010/01/18 10:07:36 jputta ship $ */

l_debug VARCHAR2(3);-- := QP_PREQ_GRP.G_DEBUG_ENGINE;
transferTimeout PLS_INTEGER := NULL;
defaultTimeout PLS_INTEGER := NULL;
eightI_env VARCHAR2(3);
--G_INTERNAL_J VARCHAR2(32767) := nvl(FND_PROFILE.VALUE('QP_INTERNAL_11510_J'), 'QWERTY');
--G_ENGINE_TYPE VARCHAR2(10) := nvl(FND_PROFILE.VALUE('QP_PRICING_ENGINE_TYPE'), 'PLSQL');
--G_ENGINE_URL VARCHAR2(1000) := FND_PROFILE.VALUE('QP_PRICING_ENGINE_URL');
--G_ICX_SESSION_ID VARCHAR2(1000) := FND_PROFILE.VALUE('ICX_SESSION_ID');
G_WALLET_PATH VARCHAR2(32767);
G_WALLET_PASSWORD VARCHAR2(100);
G_PROXY_SERVER VARCHAR2(200);

/*
  +----------------------------------------------------------------------
  | Function Java_Engine_Installed
  | TYPE:  Public
  | FUNCTION: Determines if Java Engine is installed or not
  | Input:  NONE
  | Output: varchar2 -> 'Y', JavaEngine is installed, 'N' is not installed
  +----------------------------------------------------------------------
*/
FUNCTION Java_Engine_Installed RETURN VARCHAR2 IS
l_internal varchar2(32767);
BEGIN
 l_internal := nvl(FND_PROFILE.VALUE('QP_INTERNAL_11510_J'), 'QWERTY_1');

 IF(l_internal = 'QWERTY') THEN
 --IF(G_INTERNAL_J = 'QWERTY') THEN
    RETURN 'Y'; --- changed to 'Y' to resolve the issues for the delayed request and pattern upgrade
 ELSE
    RETURN 'N'; --- changed to 'N' to resolve the issues for the delayed request and pattern upgrade
 END IF;
END;

/*
  +----------------------------------------------------------------------
  | Function Java_Engine_Running
  | TYPE:  Public
  | FUNCTION: Determines if Java Engine is up running, which means, in use
  | Input:  NONE
  | Output: varchar2 -> 'Y', JavaEngine is up running, 'N' is not in use
  +----------------------------------------------------------------------
*/
FUNCTION Java_Engine_Running RETURN VARCHAR2 IS
l_engine_type varchar2(10);
l_internal varchar2(32767);
BEGIN
 l_internal := nvl(FND_PROFILE.VALUE('QP_INTERNAL_11510_J'), 'QWERTY');
 l_engine_type := nvl(FND_PROFILE.VALUE('QP_PRICING_ENGINE_TYPE'), 'PLSQL');

 IF(l_internal = 'QWERTY') THEN
 --IF(G_INTERNAL_J = 'QWERTY') THEN
    RETURN 'N';
 ELSE
   IF(l_engine_type = 'JAVA') THEN
   --IF(G_ENGINE_TYPE = 'JAVA') THEN
      RETURN 'Y';
   ELSE
      RETURN 'N';
   END IF;
 END IF;
END;

/*+----------------------------------------------------------------------
  | Function Get_Engine_URL
  | TYPE:  Public
  | FUNCTION: Returns the URL string where Java Engine is deployed and running
  | Input:  NONE
  | Output: varchar2 -> URL string for HTTP request
  +----------------------------------------------------------------------
*/
FUNCTION Get_Engine_URL RETURN VARCHAR2 IS
l_engine_url varchar2(1000);
j number;
l_debug varchar2(3);
BEGIN
 l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
 l_engine_url := FND_PROFILE.VALUE('QP_PRICING_ENGINE_URL');

 l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
 IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('QP_PRICING_ENGINE_URL value:'||l_engine_url);
     --QP_PREQ_GRP.engine_debug('QP_PRICING_ENGINE_URL value:'||G_ENGINE_URL);
 END IF;
 --for future
 --we can have java engine to write URL into a table once it is up running.
 --here, if l_engine_url is null, check that table for URL

 --preprocess the URL string to make sure it is correct without newline character
 IF(l_engine_url is not null) THEN
 --IF(G_ENGINE_URL is not null) THEN
   j := instr(l_engine_url, G_NEWLINE_CHARACTER);
   --j := instr(G_ENGINE_URL, G_NEWLINE_CHARACTER);
   IF j <> 0 THEN
      l_engine_url := substr(l_engine_url, 1, j-1);
      --G_ENGINE_URL := substr(G_ENGINE_URL, 1, j-1);
   END IF;
 END IF;
 RETURN l_engine_url;
 --RETURN G_ENGINE_URL;
END;

/*+----------------------------------------------------------------------
  | FUNCTION Get_Context_Params
  | Output: HTTP request parameters for Context
  +----------------------------------------------------------------------
*/
FUNCTION Get_Context_Params
RETURN varchar2 IS
p_ctxt_str varchar2(32767);
l_debug_flag varchar2(1);
l_debug varchar2(3);
BEGIN
  p_ctxt_str := G_PARAM_NAME_DBC||'='||fnd_web_config.database_id;
  p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
  p_ctxt_str := p_ctxt_str||G_PARAM_NAME_USERID||'='||FND_GLOBAL.USER_ID;
  p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
  p_ctxt_str := p_ctxt_str||G_PARAM_NAME_RESPID||'='||FND_GLOBAL.RESP_ID;
  p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
  p_ctxt_str := p_ctxt_str||G_PARAM_NAME_RESP_APPL_ID||'='||FND_GLOBAL.RESP_APPL_ID;
  p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
  p_ctxt_str := p_ctxt_str||G_PARAM_NAME_ORG_ID||'='||FND_GLOBAL.ORG_ID;
  p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
  p_ctxt_str := p_ctxt_str||G_PARAM_NAME_APP_SHORT_NAME||'='||FND_GLOBAL.APPLICATION_SHORT_NAME;
  p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
  p_ctxt_str := p_ctxt_str||G_PARAM_NAME_LOGIN_ID||'='||FND_GLOBAL.LOGIN_ID;
  p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
  --p_ctxt_str := p_ctxt_str||G_PARAM_NAME_ICX_SESSION_ID||'='||ICX_SEC.G_SESSION_ID;
  p_ctxt_str := p_ctxt_str||G_PARAM_NAME_ICX_SESSION_ID||'='||FND_PROFILE.VALUE('ICX_SESSION_ID');
  --p_ctxt_str := p_ctxt_str||G_PARAM_NAME_ICX_SESSION_ID||'='||G_ICX_SESSION_ID;
  p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
  p_ctxt_str := p_ctxt_str||G_PARAM_NAME_CALL_TYPE||'=DB';
  p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF(l_debug = FND_API.G_TRUE) THEN
    l_debug_flag := 'Y';
  ELSE
    l_debug_flag := 'N';
  END IF;
  p_ctxt_str := p_ctxt_str||G_PARAM_NAME_DEBUG_FLAG||'='||l_debug_flag;
  --p_ctxt_str := p_ctxt_str||'||'||FND_GLOBAL.SESSION_ID;
  --p_ctxt_str := p_ctxt_str||'||'||icx_sec.getsessioncookie();

  --p_ctxt_str := p_ctxt_str||G_PARAM_NAME_ICX_SESSION_ID||'='||icx_call.encrypt3(ICX_SEC.G_SESSION_ID);
  --p_ctxt_str := p_ctxt_str||'||'||icx_call.encrypt3(FND_GLOBAL.SESSION_ID);
  --p_ctxt_str := p_ctxt_str||'||'||icx_call.encrypt3(ICX_SEC.G_SESSION_ID);
  --p_ctxt_str := p_ctxt_str||'||'||icx_call.encrypt3(userenv('SESSIONID'));

  return p_ctxt_str;
END Get_Context_Params;

PROCEDURE Interprete_Response_Text(response_text       IN VARCHAR2,
			x_return_status          OUT NOCOPY VARCHAR2,
			x_return_status_text     OUT NOCOPY VARCHAR2,
                        x_return_details         OUT NOCOPY UTL_HTTP.HTML_PIECES)
is
l_debug VARCHAR2(3);
l_routine VARCHAR2(240):='Routine:QP_JAVA_ENGINE_UTIL_PUB.Interprete_Response_Text';
l_a number;
l_b number;
l_c number;

BEGIN
  BEGIN
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    l_a := instr(response_text, G_PARAM_NAME_STS_CODE||'=');
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('l_a='||l_a);
    END IF;
    l_b := instr(response_text, G_PARAM_NAME_STS_TEXT||'=');
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('l_b='||l_b);
    END IF;
    l_c := instr(response_text, G_PARAM_NAME_DETAILS||'=');
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('l_c='||l_c);
    END IF;

    IF(l_a = 0 or l_b = 0) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_status_text := response_text;
    ELSE
      x_return_status := substr(response_text,l_a+ length(G_PARAM_NAME_STS_CODE)+1, l_b - (l_a+length(G_PARAM_NAME_STS_CODE)+1));
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('after parse, x_return_status='||x_return_status);
    END IF;
    IF l_c = 0 THEN
      x_return_status_text := substr(response_text, l_b+length(G_PARAM_NAME_STS_TEXT)+1, 2000);
    ELSE
      x_return_status_text := substr(response_text, l_b+length(G_PARAM_NAME_STS_TEXT)+1, l_c - (l_b+length(G_PARAM_NAME_STS_TEXT)+1));
      x_return_details(1) := substr(response_text, l_c+length(G_PARAM_NAME_DETAILS)+1, 2000);
    END IF;
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('after parse,x_return_status_text='||x_return_status_text);
      IF l_c <> 0 THEN
        QP_PREQ_GRP.engine_debug('after parse,x_return_details(1)='||x_return_details(1));
      END IF;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP','QP_JPE_UTL_HTTP_STR_ERROR');
    x_return_status_text := FND_MESSAGE.get;
    --x_return_status_text := 'utl_http return string parsing error.';
  END;

  IF x_return_status IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := response_text;
  ELSE
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('HTTP request has finished successfully!');
    END IF;
  END IF;
END;

PROCEDURE Interprete_Response_Text(p_response_pieces IN UTL_HTTP.HTML_PIECES,
			x_return_status          OUT NOCOPY  VARCHAR2,
			x_return_status_text     OUT NOCOPY  VARCHAR2,
                        x_return_details         OUT NOCOPY UTL_HTTP.HTML_PIECES)
is
BEGIN
  Interprete_Response_Text(p_response_pieces(1),
                           x_return_status,
                           x_return_status_text,
                           x_return_details);
  IF x_return_details.count > 0 THEN
    FOR i IN 2 .. p_response_pieces.count loop
      x_return_details(i) := p_response_pieces(i);
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP','QP_JPE_UTL_HTTP_STR_ERROR');
    x_return_status_text := FND_MESSAGE.get;
    --x_return_status_text := 'utl_http detail string parsing error.';
END;

FUNCTION is_SSL_Enabled(p_url_string IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
IF(instr(upper(p_url_string), 'HTTPS') <> 0) THEN
  RETURN 'Y';
ELSE
  RETURN 'N';
END IF;
END;

PROCEDURE UTL_HTTP_REQUEST(p_url_string       IN VARCHAR2,
                        x_return_status       OUT NOCOPY VARCHAR2,
                        x_return_status_text  OUT NOCOPY VARCHAR2,
                        x_return_details      OUT NOCOPY UTL_HTTP.HTML_PIECES,
                        p_use_request_pieces  IN BOOLEAN DEFAULT FALSE)
IS
url_str VARCHAR2(32767);
l_debug varchar2(3);
l_routine VARCHAR2(240):='Routine:QP_JAVA_ENGINE_UTIL_PUB.UTL_HTTP_REQUEST';
pieces UTL_HTTP.HTML_PIECES;
BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

  /*HTTP Get Request from Java Engine*/
  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Inside Routine:'||l_routine);
    QP_PREQ_GRP.engine_debug('url_string:'||p_url_string);
  END IF;

  IF(is_SSL_Enabled(p_url_string) = 'Y') THEN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('SSL is enabled.');
    END IF;
    G_WALLET_PATH :=nvl(G_WALLET_PATH,'file:/'||FND_PROFILE.VALUE('FND_DB_WALLET_DIR'));
    G_WALLET_PASSWORD :=nvl(G_WALLET_PASSWORD,FND_PROFILE.VALUE('QP_WALLET_PASSWORD'));
    G_PROXY_SERVER := nvl(G_PROXY_SERVER,FND_PROFILE.VALUE('QP_PROXY_SERVER'));
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('wallet_path:'||G_WALLET_PATH||' wallet_password:'||G_WALLET_PASSWORD);
      QP_PREQ_GRP.engine_debug('proxy server:'||G_PROXY_SERVER);
    END IF;
    IF p_use_request_pieces THEN
      pieces := UTL_HTTP.Request_Pieces(url             => p_url_string,
                                        proxy           => G_PROXY_SERVER,
                                        wallet_path     => G_WALLET_PATH,
                                        wallet_password => G_WALLET_PASSWORD);
    ELSE
      url_str := UTL_HTTP.Request(p_url_string, G_PROXY_SERVER, G_WALLET_PATH, G_WALLET_PASSWORD);
    END IF;
  ELSE
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('SSL is disabled.');
    END IF;
    G_PROXY_SERVER := nvl(G_PROXY_SERVER, FND_PROFILE.VALUE('QP_PROXY_SERVER'));
    IF(G_PROXY_SERVER <> null) THEN
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('proxy server:'||G_PROXY_SERVER);
      END IF;
      IF p_use_request_pieces THEN
        pieces := UTL_HTTP.Request_Pieces(url          => p_url_string,
                                          proxy        => G_PROXY_SERVER);
      ELSE
        url_str := UTL_HTTP.Request(p_url_string, G_PROXY_SERVER);
      END IF;
    ELSE
      IF p_use_request_pieces THEN
        pieces := UTL_HTTP.Request_Pieces(url          => p_url_string);
      ELSE
        url_str := UTL_HTTP.Request(p_url_string);
      END IF;
    END IF;
  END IF;

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('response length: '||length(url_str));
    QP_PREQ_GRP.engine_debug('utl_http_request response:'||url_str);
  END IF;

  IF p_use_request_pieces THEN
    Interprete_Response_Text(pieces, x_return_status, x_return_status_text, x_return_details);
  ELSE
    Interprete_Response_Text(url_str, x_return_status, x_return_status_text, x_return_details);
  END IF;

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('after Interprete_Response_Text: x_return_status='||x_return_status||' x_return_status_text='||x_return_status_text);
  END IF;
EXCEPTION
  WHEN UTL_HTTP.INIT_FAILED THEN
    BEGIN
      --EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlcode from dual' INTO x_return_status;
    --x_return_status_text := 'UTL_HTTP INIT_FAILED exception with errorcode:'||UTL_HTTP.get_detailed_sqlcode||' errormessage:'||UTL_HTTP.get_detailed_sqlerrm;
      x_return_status := FND_API.G_RET_STS_ERROR;
      EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlerrm from dual' INTO x_return_status_text;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('HTTP request failed because of UTL_HTTP_INIT_FAILED');
        QP_PREQ_GRP.engine_debug('x_return_status='||x_return_status||' x_return_status_text='||x_return_status_text);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP','QP_JPE_UNEXPECTED_ERROR');
        x_return_status_text := FND_MESSAGE.get;
        --x_return_status_text := 'Java Engine call failed unexpectedly. Please contact system administrator!';
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('HTTP request failed unexpectedly!' );
        END IF;
    END;
  WHEN UTL_HTTP.REQUEST_FAILED THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --x_return_status_text := 'UTL_HTTP.REQUEST_FAILED';
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('HTTP request failed because of UTL HTTP REQUEST_FAILED'||x_return_status_text);
    END IF;
    BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlerrm from dual' INTO x_return_status_text;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('x_return_status='||x_return_status||' x_return_status_text='||x_return_status_text);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_return_status_text := 'UTL_HTTP REQUEST_FAILED exception';
    END;
  WHEN UTL_TCP.END_OF_INPUT THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := 'UTL_TCP.END_OF_INPUT';
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('HTTP request failed because of UTL_TCP.END_OF_INPUT');
    END IF;
  WHEN OTHERS THEN
    BEGIN
      --EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlcode from dual' INTO x_return_status;
      x_return_status := FND_API.G_RET_STS_ERROR;
      EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlerrm from dual' INTO x_return_status_text;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('x_return_status='||x_return_status||' x_return_status_text='||x_return_status_text);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP','QP_JPE_UNEXPECTED_ERROR');
        x_return_status_text := FND_MESSAGE.get;
        --x_return_status_text := 'Java Engine call failed unexpectedly. Please contact system administrator!';
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('HTTP request failed unexpectedly!' );
        END IF;
    END;
END;

PROCEDURE Send_Java_Engine_Request (p_url_param_string       IN VARCHAR2,
			x_return_status          OUT NOCOPY  VARCHAR2,
			x_return_status_text     OUT NOCOPY  VARCHAR2,
			x_return_details         OUT NOCOPY  UTL_HTTP.HTML_PIECES,
                        p_use_request_pieces     IN BOOLEAN,
                        p_transfer_timeout       IN NUMBER,
                        p_detailed_excp_support  IN VARCHAR2,
                        p_timeout_processing IN VARCHAR2)
is
l_debug VARCHAR2(3);
l_routine VARCHAR2(240):='Routine:QP_JAVA_ENGINE_UTIL_PUB.Send_Java_Engine_Request';
url_str VARCHAR2(32767);
p_ctrl_str varchar2(32767);
p_ctxt_str varchar2(32767);

l_pricing_start_time number;
l_pricing_end_time number;
E_ROUTINE_ERRORS EXCEPTION;
E_JAVA_ENGINE_URL_NULL EXCEPTION;
l_engine_server_url VARCHAR2(500);
l_ctxt_str varchar2(32767);
l_transfer_timeout NUMBER;
l_detailed_excp_support VARCHAR2(3);
l_return_status_code varchar2(1);
l_return_status_text varchar2(240);

--added for HTTP timeout issue handling
l_status_request_cnt  NUMBER;
MAX_STATUS_REQUESTS_REACHED EXCEPTION;
--added for HTTP timeout issue handling
BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

  IF l_debug = FND_API.G_TRUE THEN
    l_pricing_start_time := dbms_utility.get_time;
    QP_PREQ_GRP.engine_debug('Inside '||l_routine);
    IF eightI_env = FND_API.G_FALSE THEN
      l_detailed_excp_support := FND_API.G_TRUE;
    ELSE
      l_detailed_excp_support := FND_API.G_FALSE;
    END IF;
  ELSIF p_timeout_processing = FND_API.G_TRUE THEN
    IF eightI_env = FND_API.G_FALSE THEN
      l_detailed_excp_support := FND_API.G_TRUE;
    ELSE
      l_detailed_excp_support := FND_API.G_FALSE;
    END IF;
  ELSE
    IF eightI_env = FND_API.G_FALSE THEN
      l_detailed_excp_support := p_detailed_excp_support;
    ELSE
      l_detailed_excp_support := FND_API.G_FALSE;
    END IF;
  END IF;

  l_engine_server_url := QP_JAVA_ENGINE_UTIL_PUB.Get_Engine_URL;
  IF l_engine_server_url is null THEN
    IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('Java Engine URL has not been setup correctly.');
    END IF;
    RAISE E_JAVA_ENGINE_URL_NULL;
  END IF;

  /*Construct request parameter string ContextConfig*/
  l_ctxt_str := Get_Context_Params;

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('before UTL_HTTP.Request, the url string:'||l_engine_server_url||'?'||l_ctxt_str||'&'||p_url_param_string);
  END IF;

  /*Defaulting transfer timeout to transferTimeout specified by profile*/
  IF p_transfer_timeout = -1 THEN
    l_transfer_timeout := transferTimeout;
  ELSE
    l_transfer_timeout := p_transfer_timeout;
  END IF;

  /*Set transfer timeout, default is 60s in 9i database*/
  IF(l_transfer_timeout IS NOT NULL AND defaultTimeout IS NOT NULL AND l_transfer_timeout <> defaultTimeout)THEN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('set utl_http transfer_timeout to '||l_transfer_timeout);
    END IF;
    EXECUTE IMMEDIATE 'BEGIN UTL_HTTP.Set_Transfer_Timeout(:1); END;' USING IN l_transfer_timeout;
  END IF;

  /*Added for catch more detailed error when UTL_HTTP errored out*/
  IF l_detailed_excp_support = FND_API.G_TRUE THEN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('set utl_http set_detailed_excp_support(true)');
    END IF;
    EXECUTE IMMEDIATE 'BEGIN UTL_HTTP.set_detailed_excp_support(TRUE); END;';
  END IF;

  /*HTTP Get Request from Java Engine*/
  UTL_HTTP_REQUEST(l_engine_server_url||'?'||l_ctxt_str||'&'||p_url_param_string,
                   x_return_status,
                   x_return_status_text,
                   x_return_details,
                   p_use_request_pieces);

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('After first HTTP call: x_return_status='||x_return_status||' x_return_status_text='||x_return_status_text);
  END IF;

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    IF (p_timeout_processing = FND_API.G_TRUE) THEN
    /*UTL_HTTP_TRANSFER Timeout and HTTP Timeout issue handling*/
      IF (x_return_status_text = 'UTL_TCP.END_OF_INPUT' or instr(x_return_status_text, 'ORA-29276') <> 0) THEN
        l_status_request_cnt := 0;
        LOOP
          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('sleeping........'||G_STATUS_REQUEST_INTERVAL||'(secs)');
          END IF;
          DBMS_LOCK.SLEEP(G_STATUS_REQUEST_INTERVAL);

          UTL_HTTP_REQUEST(l_engine_server_url||'?'||l_ctxt_str||G_HARD_CHAR||'Action=inquery'|| G_HARD_CHAR||'RequestId='|| QP_Price_Request_Context.GET_REQUEST_ID,
                           x_return_status,
                           x_return_status_text,
                           x_return_details);

          IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('After inquery HTTP call: x_return_status='||x_return_status||' x_return_status_text='||x_return_status_text);
          END IF;

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            IF  (x_return_status_text <> 'UTL_TCP.END_OF_INPUT' and instr(x_return_status_text, 'ORA-29276') = 0) THEN
            /*other errors than timeout error, send request to remove mid-tier status */
              --UTL_HTTP_REQUEST(l_engine_server_url||'?'||l_ctxt_str||G_HARD_CHAR||'Action=finish'|| G_HARD_CHAR||'RequestId='|| QP_Price_Request_Context.GET_REQUEST_ID, x_return_status, x_return_status_text);
              UTL_HTTP_REQUEST(l_engine_server_url||'?'||l_ctxt_str||G_HARD_CHAR||'Action=finish'|| G_HARD_CHAR||'RequestId='|| QP_Price_Request_Context.GET_REQUEST_ID,
                               l_return_status_code,
                               l_return_status_text,
                               x_return_details,
                               p_use_request_pieces);
              RAISE E_ROUTINE_ERRORS;
            END IF;
          END IF;
          EXIT WHEN x_return_status_text <> 'IN_PROGRESS' and x_return_status_text <> 'UTL_TCP.END_OF_INPUT' and instr(x_return_status_text, 'ORA-29276') = 0;

            -- 'COMPLETED','ERROR', or anything else;
          IF l_status_request_cnt > G_MAX_STATUS_REQUESTS THEN
            RAISE MAX_STATUS_REQUESTS_REACHED;
          END IF;
          l_status_request_cnt := l_status_request_cnt + 1;
        END LOOP;

        IF(instr(x_return_status_text, 'ERROR') <> 0) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_return_status_text := substr(x_return_status_text,7, length(x_return_status_text)-7);
        END IF;

      ELSE
      /*other errors than timeout error, send request to remove mid-tier status */
        --UTL_HTTP_REQUEST(l_engine_server_url||'?'||l_ctxt_str||G_HARD_CHAR||'Action=finish'|| G_HARD_CHAR||'RequestId='|| QP_Price_Request_Context.GET_REQUEST_ID, x_return_status, x_return_status_text);
        UTL_HTTP_REQUEST(l_engine_server_url||'?'||l_ctxt_str||G_HARD_CHAR||'Action=finish'|| G_HARD_CHAR||'RequestId='|| QP_Price_Request_Context.GET_REQUEST_ID,
                         l_return_status_code,
                         l_return_status_text,
                         x_return_details,
                         p_use_request_pieces);
        RAISE E_ROUTINE_ERRORS;
      END IF;
    END IF;
  END IF;

  /*Set transfer timeout back to default value, default is 60s in 9i database*/
  IF(l_transfer_timeout IS NOT NULL AND defaultTimeout IS NOT NULL AND l_transfer_timeout <> defaultTimeout)THEN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('set utl_http transfer_timeout back to '||defaultTimeout);
    END IF;
    EXECUTE IMMEDIATE 'BEGIN UTL_HTTP.Set_Transfer_Timeout(:1); END;' USING IN defaultTimeout;
  END IF;

  /*Added for catch more detailed error when UTL_HTTP errored out*/
  IF l_detailed_excp_support = FND_API.G_TRUE THEN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('set utl_http set_detailed_excp_support(false)');
    END IF;
    EXECUTE IMMEDIATE 'BEGIN UTL_HTTP.set_detailed_excp_support(FALSE); END;';
  END IF;

  IF l_debug = FND_API.G_TRUE THEN
    l_pricing_end_time := dbms_utility.get_time;
    QP_PREQ_GRP.engine_debug('Request total time: '||(l_pricing_end_time - l_pricing_start_time)/100);
  END IF;

EXCEPTION
  WHEN UTL_HTTP.INIT_FAILED THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --x_return_status_text := 'UTL_HTTP INIT_FAILED exception with errorcode:'||UTL_HTTP.get_detailed_sqlcode||' errormessage:'||UTL_HTTP.get_detailed_sqlerrm ;
    x_return_status_text := 'UTL_HTTP.INIT_FAILED';
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('HTTP request failed because of UTL_HTTP_INIT_FAILED');
    END IF;
  WHEN UTL_HTTP.REQUEST_FAILED THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := 'UTL_HTTP.REQUEST_FAILED';
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('HTTP request failed because of UTL HTTP REQUEST_FAILED'||x_return_status_text);
    END IF;
    BEGIN
      --EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlcode from dual' INTO x_return_status;
      x_return_status := FND_API.G_RET_STS_ERROR;
      EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlerrm from dual' INTO x_return_status_text;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('x_return_status='||x_return_status||' x_return_status_text='||x_return_status_text);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_return_status_text := 'UTL_HTTP REQUEST_FAILED exception';
    END;
  WHEN UTL_TCP.END_OF_INPUT THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := 'UTL_TCP.END_OF_INPUT';
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('HTTP request failed because of UTL_TCP.END_OF_INPUT');
    END IF;
  WHEN E_JAVA_ENGINE_URL_NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP','QP_JPE_URL_NULL_ERROR');
    x_return_status_text := FND_MESSAGE.get;
    --x_return_status_text := 'Java Engine URL should not be null. Please contact system administrator to setup the URL correctly first.';
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Java Engine URL is null');
    END IF;
  WHEN MAX_STATUS_REQUESTS_REACHED THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP','QP_JPE_REQUEST_TIMEOUT_ERROR');
    FND_MESSAGE.SET_TOKEN('SECONDS',G_MAX_STATUS_REQUESTS*G_STATUS_REQUEST_INTERVAL);

    x_return_status_text := FND_MESSAGE.GET;
     --x_return_status_text := 'Request has exceeded '||(G_MAX_STATUS_REQUESTS*G_STATUS_REQUEST_INTERVAL)||' seconds.';
  WHEN E_ROUTINE_ERRORS THEN
    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug(l_routine||': '||x_return_status_text);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    BEGIN
      --EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlcode from dual' INTO x_return_status;
      x_return_status := FND_API.G_RET_STS_ERROR;
      EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlerrm from dual' INTO x_return_status_text;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('x_return_status='||x_return_status||' x_return_status_text='||x_return_status_text);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP','QP_JPE_UNEXPECTED_ERROR');
        x_return_status_text := FND_MESSAGE.GET;
        --x_return_status_text := 'Java Engine call failed unexpectedly. Please contact system administrator!';
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('HTTP request failed unexpectedly!' );
        END IF;
    END;

end Send_Java_Engine_Request;

PROCEDURE Send_Java_Engine_Request (p_url_param_string       IN VARCHAR2,
			x_return_status          OUT NOCOPY  VARCHAR2,
			x_return_status_text     OUT NOCOPY  VARCHAR2,
                        p_transfer_timeout       IN NUMBER,
                        p_detailed_excp_support  IN VARCHAR2,
                        p_timeout_processing IN VARCHAR2)
is
l_dummy_return_details UTL_HTTP.HTML_PIECES;
BEGIN

  Send_Java_Engine_Request(p_url_param_string,
                           x_return_status,
                           x_return_status_text,
                           l_dummy_return_details,
                           false,
                           p_transfer_timeout,
                           p_detailed_excp_support,
                           p_timeout_processing);

END;

PROCEDURE Send_Java_Request (p_server_url        IN VARCHAR2,
                        p_url_param_string       IN VARCHAR2,
			x_return_status          OUT NOCOPY  VARCHAR2,
			x_return_status_text     OUT NOCOPY  VARCHAR2,
			x_return_details         OUT NOCOPY  UTL_HTTP.HTML_PIECES,
                        p_use_request_pieces     IN BOOLEAN,
                        p_transfer_timeout       IN NUMBER,
                        p_detailed_excp_support  IN VARCHAR2,
                        p_timeout_processing IN VARCHAR2)
is
l_debug VARCHAR2(3);
l_routine VARCHAR2(240):='Routine:QP_JAVA_ENGINE_UTIL_PUB.Send_Java_Request';
url_str VARCHAR2(32767);
p_ctrl_str varchar2(32767);
p_ctxt_str varchar2(32767);

l_pricing_start_time number;
l_pricing_end_time number;
E_ROUTINE_ERRORS EXCEPTION;
E_JAVA_URL_NULL EXCEPTION;
l_engine_server_url VARCHAR2(500);
l_ctxt_str varchar2(32767);
l_transfer_timeout NUMBER;
l_detailed_excp_support VARCHAR2(3);
l_return_status_code varchar2(1);
l_return_status_text varchar2(240);

--added for HTTP timeout issue handling
l_status_request_cnt  NUMBER;
MAX_STATUS_REQUESTS_REACHED EXCEPTION;
--added for HTTP timeout issue handling
BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

  IF l_debug = FND_API.G_TRUE THEN
    l_pricing_start_time := dbms_utility.get_time;
    QP_PREQ_GRP.engine_debug('Inside '||l_routine);
    IF eightI_env = FND_API.G_FALSE THEN
      l_detailed_excp_support := FND_API.G_TRUE;
    ELSE
      l_detailed_excp_support := FND_API.G_FALSE;
    END IF;
  ELSIF p_timeout_processing = FND_API.G_TRUE THEN
    IF eightI_env = FND_API.G_FALSE THEN
      l_detailed_excp_support := FND_API.G_TRUE;
    ELSE
      l_detailed_excp_support := FND_API.G_FALSE;
    END IF;
  ELSE
    IF eightI_env = FND_API.G_FALSE THEN
      l_detailed_excp_support := p_detailed_excp_support;
    ELSE
      l_detailed_excp_support := FND_API.G_FALSE;
    END IF;
  END IF;

  IF p_server_url is null THEN
    IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('Java Engine URL has not been setup correctly.');
    END IF;
    RAISE E_JAVA_URL_NULL;
  END IF;

  /*Construct request parameter string ContextConfig*/
  l_ctxt_str := Get_Context_Params;

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('before UTL_HTTP.Request, the url string:'||p_server_url||'?'||l_ctxt_str||'&'||p_url_param_string);
  END IF;

  /*Defaulting transfer timeout to transferTimeout specified by profile*/
  IF p_transfer_timeout = -1 THEN
    l_transfer_timeout := transferTimeout;
  ELSE
    l_transfer_timeout := p_transfer_timeout;
  END IF;

  /*Set transfer timeout, default is 60s in 9i database*/
  IF(l_transfer_timeout IS NOT NULL AND defaultTimeout IS NOT NULL AND l_transfer_timeout <> defaultTimeout)THEN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('set utl_http transfer_timeout to '||l_transfer_timeout);
    END IF;
    EXECUTE IMMEDIATE 'BEGIN UTL_HTTP.Set_Transfer_Timeout(:1); END;' USING IN l_transfer_timeout;
  END IF;

  /*Added for catch more detailed error when UTL_HTTP errored out*/
  IF l_detailed_excp_support = FND_API.G_TRUE THEN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('set utl_http set_detailed_excp_support(true)');
    END IF;
    EXECUTE IMMEDIATE 'BEGIN UTL_HTTP.set_detailed_excp_support(TRUE); END;';
  END IF;

  /*HTTP Get Request from Java Engine*/
  UTL_HTTP_REQUEST(p_server_url||'?'||l_ctxt_str||'&'||p_url_param_string,
                   x_return_status,
                   x_return_status_text,
                   x_return_details,
                   p_use_request_pieces);

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('After first HTTP call: x_return_status='||x_return_status||' x_return_status_text='||x_return_status_text);
  END IF;

  /*Set transfer timeout back to default value, default is 60s in 9i database*/
  IF(l_transfer_timeout IS NOT NULL AND defaultTimeout IS NOT NULL AND l_transfer_timeout <> defaultTimeout)THEN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('set utl_http transfer_timeout back to '||defaultTimeout);
    END IF;
    EXECUTE IMMEDIATE 'BEGIN UTL_HTTP.Set_Transfer_Timeout(:1); END;' USING IN defaultTimeout;
  END IF;

  /*Added for catch more detailed error when UTL_HTTP errored out*/
  IF l_detailed_excp_support = FND_API.G_TRUE THEN
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('set utl_http set_detailed_excp_support(false)');
    END IF;
    EXECUTE IMMEDIATE 'BEGIN UTL_HTTP.set_detailed_excp_support(FALSE); END;';
  END IF;

  IF l_debug = FND_API.G_TRUE THEN
    l_pricing_end_time := dbms_utility.get_time;
    QP_PREQ_GRP.engine_debug('Request total time: '||(l_pricing_end_time - l_pricing_start_time)/100);
  END IF;

EXCEPTION
  WHEN UTL_HTTP.INIT_FAILED THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --x_return_status_text := 'UTL_HTTP INIT_FAILED exception with errorcode:'||UTL_HTTP.get_detailed_sqlcode||' errormessage:'||UTL_HTTP.get_detailed_sqlerrm ;
    x_return_status_text := 'UTL_HTTP.INIT_FAILED';
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('HTTP request failed because of UTL_HTTP_INIT_FAILED');
    END IF;
  WHEN UTL_HTTP.REQUEST_FAILED THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := 'UTL_HTTP.REQUEST_FAILED';
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('HTTP request failed because of UTL HTTP REQUEST_FAILED'||x_return_status_text);
    END IF;
    BEGIN
      --EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlcode from dual' INTO x_return_status;
      x_return_status := FND_API.G_RET_STS_ERROR;
      EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlerrm from dual' INTO x_return_status_text;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('x_return_status='||x_return_status||' x_return_status_text='||x_return_status_text);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_return_status_text := 'UTL_HTTP REQUEST_FAILED exception';
    END;
  WHEN UTL_TCP.END_OF_INPUT THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_text := 'UTL_TCP.END_OF_INPUT';
    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('HTTP request failed because of UTL_TCP.END_OF_INPUT');
    END IF;
  WHEN MAX_STATUS_REQUESTS_REACHED THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP','QP_JPE_REQUEST_TIMEOUT_ERROR');
    FND_MESSAGE.SET_TOKEN('SECONDS',G_MAX_STATUS_REQUESTS*G_STATUS_REQUEST_INTERVAL);

    x_return_status_text := FND_MESSAGE.GET;
     --x_return_status_text := 'Request has exceeded '||(G_MAX_STATUS_REQUESTS*G_STATUS_REQUEST_INTERVAL)||' seconds.';
  WHEN E_ROUTINE_ERRORS THEN
    IF QP_PREQ_GRP.G_DEBUG_ENGINE = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug(l_routine||': '||x_return_status_text);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    BEGIN
      --EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlcode from dual' INTO x_return_status;
      x_return_status := FND_API.G_RET_STS_ERROR;
      EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlerrm from dual' INTO x_return_status_text;

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('x_return_status='||x_return_status||' x_return_status_text='||x_return_status_text);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        --FND_MESSAGE.SET_NAME('QP','QP_JPE_UNEXPECTED_ERROR');
        --x_return_status_text := FND_MESSAGE.GET;
        x_return_status_text := 'Java call failed unexpectedly. Please contact system administrator!';
        IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug('HTTP request failed unexpectedly!' );
        END IF;
    END;

end Send_Java_Request;

BEGIN
   BEGIN
     transferTimeout :=  FND_PROFILE.VALUE('QP_UTL_HTTP_TIMEOUT');
     eightI_env := FND_API.G_FALSE;
     EXECUTE IMMEDIATE 'BEGIN UTL_HTTP.GET_TRANSFER_TIMEOUT(:1); END;' USING IN OUT defaultTimeout;
     IF l_debug = FND_API.G_TRUE THEN
       QP_PREQ_GRP.engine_debug('transferTimeout='||transferTimeout||'sec defaultTimeout='||defaultTimeout||'sec.');
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
       transferTimeout := NULL;
       defaultTimeout := NULL;
       eightI_env := FND_API.G_TRUE;
     IF l_debug = FND_API.G_TRUE THEN
       QP_PREQ_GRP.engine_debug('transferTimeout=NULL and defaultTimeout=NULL.');
     END IF;
   END;
END QP_JAVA_ENGINE_UTIL_PUB;

/
