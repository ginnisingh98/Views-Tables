--------------------------------------------------------
--  DDL for Package Body WSH_OTM_HTTP_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_OTM_HTTP_UTL" AS
/* $Header: WSHGLHUB.pls 120.2.12010000.2 2008/12/10 10:28:03 anvarshn ship $ */



-- GLOBAL VARIABLES/CONSTANTS
-- --------------------------
G_WSH_OTM_SERVLET_URI    VARCHAR2(4000) := NULL;
G_WSH_OTM_WS_ENDPOINT    VARCHAR2(4000) := NULL;
G_WSH_OTM_PROXY_SERVER   VARCHAR2(1000) := NULL;
G_WSH_OTM_PROXY_PORT     NUMBER;
G_WSH_TKT_OP_CODE        VARCHAR2(255) := 'WshRateOTM';
G_WSH_TKT_ARGUMENT_VALUE VARCHAR2(4000) := 'WshRate';
G_WSH_TKT_LIFESPAN       NUMBER := 36000; --10 hrs.
G_ENC_STYLE              VARCHAR2(1000) := NULL;
G_WALLET_PATH            VARCHAR2(32767) := NULL;
G_WALLET_PASSWORD        VARCHAR2(1000) := NULL;
G_OTM_UNAME              VARCHAR2(2000) := NULL;
G_OTM_PSWD               VARCHAR2(2000) :=  NULL;
G_NEWLINE_CHARACTER      CHAR(1) := FND_GLOBAL.Newline;
G_HARD_CHAR              VARCHAR2(1) := '&';
G_PARAM_NAME_DBC         VARCHAR2(3) := 'dbc';
G_PARAM_NAME_USERID      VARCHAR2(6) := 'userId';
G_PARAM_NAME_RESPID      VARCHAR2(6) := 'respId';
G_PARAM_NAME_TICKET      VARCHAR2(1)  := 't';
G_PARAM_NAME_RIQ_INPUT   VARCHAR2(3) := 'riq';
G_PARAM_NAME_ENC_STYLE   VARCHAR2(3) := 'enc';
G_PARAM_NAME_OTM_UNAME   VARCHAR2(10) := 'oun';
G_PARAM_NAME_OTM_PSSWD   VARCHAR2(10) := 'oup';
G_PARAM_NAME_RESP_APPL_ID VARCHAR2(10) := 'respApplId';
G_PARAM_NAME_TKT_EXP_DATE VARCHAR2(3) :=  'ted';
G_PARAM_NAME_WS_END_POINT VARCHAR2(3) := 'wep';
G_TKT_ERROR              EXCEPTION;
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_OTM_HTTP_UTL';
-- -----------------------------------------------------------------------------------


-- Load profile values in global variables
-- -----------------------------------------------------------------------------------
FUNCTION load_profiles RETURN VARCHAR2
IS
    l_debug_on       BOOLEAN;
    l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'load_profiles';
    j NUMBER;
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    wsh_otm_endpoint_null EXCEPTION;
    wsh_otm_uname_null       EXCEPTION;
    wsh_otm_pswd_null        EXCEPTION;
BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
  END IF;

  G_ENC_STYLE            := FND_PROFILE.VALUE('ICX_CLIENT_IANA_ENCODING');
  G_WSH_OTM_SERVLET_URI  := FND_PROFILE.value('APPS_FRAMEWORK_AGENT')||'/OA_HTML/wshRequestRates';
  G_WSH_OTM_WS_ENDPOINT  := FND_PROFILE.VALUE('WSH_OTM_SERVLET_URI');
  G_WSH_OTM_PROXY_SERVER := FND_PROFILE.VALUE('WSH_OTM_PROXY_SERVER');
  G_WSH_OTM_PROXY_PORT   := FND_PROFILE.VALUE('WSH_OTM_PROXY_PORT');
  G_OTM_UNAME            := FND_PROFILE.VALUE('WSH_OTM_USER_ID');
  G_OTM_PSWD             := FND_PROFILE.VALUE('WSH_OTM_PASSWORD');
  G_WALLET_PATH          := nvl(G_WALLET_PATH,'file:/'||FND_PROFILE.VALUE('FND_DB_WALLET_DIR'));
  G_WALLET_PASSWORD      := nvl(G_WALLET_PASSWORD,FND_PROFILE.VALUE('WSH_OTM_WALLET_PASSWORD'));

  --TODO: Look into encrypt/decrypt the uname / pswd.

  --preprocess the URL strings to make sure they are correct without newline character
  IF ((G_WSH_OTM_WS_ENDPOINT IS NULL ) OR (length(G_WSH_OTM_WS_ENDPOINT) = 0 ) )
  THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_PROFILE_NOT_SET_ERR');
    FND_MESSAGE.SET_TOKEN('PRF_NAME',fnd_message.get_string('WSH','WSH_OTM_SERVLET_URI'));
    FND_MSG_PUB.ADD;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'OTM Servlet URI profile can not be null ',WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    END IF;
  END IF;

  IF  ( (G_OTM_UNAME IS NULL ) OR ( length(G_OTM_UNAME) = 0)) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_PROFILE_NOT_SET_ERR');
    FND_MESSAGE.SET_TOKEN('PRF_NAME',fnd_message.get_string('WSH','WSH_OTM_USER_ID'));
    FND_MSG_PUB.ADD;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'OTM user name profile can not be null ',WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    END IF;
  END IF;

  IF ( (G_OTM_PSWD IS NULL) OR (length(G_OTM_PSWD) = 0)) THEN
    FND_MESSAGE.SET_NAME('WSH','WSH_PROFILE_NOT_SET_ERR');
    FND_MESSAGE.SET_TOKEN('PRF_NAME',fnd_message.get_string('WSH','WSH_OTM_PASSWORD'));
    FND_MSG_PUB.ADD;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'OTM user password profile can not be null',WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    END IF;
  END IF;

  IF ((G_WSH_OTM_WS_ENDPOINT IS NULL ) OR (length(G_WSH_OTM_WS_ENDPOINT) = 0) OR
      (G_OTM_UNAME IS NULL ) OR ( length(G_OTM_UNAME) = 0) OR
      (G_OTM_PSWD IS NULL) OR (length(G_OTM_PSWD) = 0))
  THEN
    RAISE wsh_otm_endpoint_null;
  END IF;

   IF(G_WSH_OTM_SERVLET_URI is not null) THEN
     j := instr(G_WSH_OTM_SERVLET_URI, G_NEWLINE_CHARACTER);
     IF j <> 0 THEN
        G_WSH_OTM_SERVLET_URI := substr(G_WSH_OTM_SERVLET_URI, 1, j-1);
     END IF;
   END IF;
   IF(G_WSH_OTM_WS_ENDPOINT is not null) THEN
     j := instr(G_WSH_OTM_WS_ENDPOINT, G_NEWLINE_CHARACTER);
     IF j <> 0 THEN
        G_WSH_OTM_WS_ENDPOINT := substr(G_WSH_OTM_WS_ENDPOINT, 1, j-1);
     END IF;
   END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'g_wsh_otm_servlet_uri='||G_WSH_OTM_SERVLET_URI);
    WSH_DEBUG_SV.log(l_module_name,'g_wsh_otm_ws_endpoint='||G_WSH_OTM_WS_ENDPOINT);
    WSH_DEBUG_SV.log(l_module_name,'g_wsh_otm_proxy_server='||G_WSH_OTM_PROXY_SERVER);
    WSH_DEBUG_SV.log(l_module_name,'g_wsh_otm_proxy_port='||G_WSH_OTM_PROXY_PORT);
    WSH_DEBUG_SV.log(l_module_name,'G_OTM_UNAME='||G_OTM_UNAME);
    WSH_DEBUG_SV.log(l_module_name,'G_OTM_PSWD'||G_OTM_PSWD);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

  RETURN FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN wsh_otm_endpoint_null THEN
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_otm_endpoint_null');
    END IF;
    RETURN FND_API.G_RET_STS_ERROR;
WHEN others THEN
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;
    RETURN FND_API.G_RET_STS_ERROR;
END load_profiles;

-- Check if URL is an HTTPS URL
-- Return Y or N
FUNCTION is_SSL_Enabled(p_url_string IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
  IF(instr(upper(p_url_string), 'HTTPS') <> 0) THEN
      RETURN 'Y';
  ELSE
      RETURN 'N';
  END IF;
END is_SSL_Enabled;


-- Returns a String with all the parameters appended to it.
-- This string will be passed to WSH rating servlet.
FUNCTION Get_Context_Params (p_fnd_ticket   IN VARCHAR2
                            )
RETURN CLOB IS
    p_ctxt_str CLOB;
BEGIN
    p_ctxt_str := G_PARAM_NAME_DBC||'='||fnd_web_config.database_id;
    p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
    p_ctxt_str := p_ctxt_str||G_PARAM_NAME_USERID||'='||fnd_global.user_id;
    p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
    p_ctxt_str := p_ctxt_str||G_PARAM_NAME_RESPID||'='||fnd_global.resp_id;
    p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
    p_ctxt_str := p_ctxt_str||G_PARAM_NAME_RESP_APPL_ID||'='||fnd_global.resp_appl_id;
    p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
    p_ctxt_str := p_ctxt_str||G_PARAM_NAME_TICKET||'='||p_fnd_ticket;
    p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
    p_ctxt_str := p_ctxt_str||G_PARAM_NAME_WS_END_POINT||'='||G_WSH_OTM_WS_ENDPOINT;
    p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
    p_ctxt_str := p_ctxt_str||G_PARAM_NAME_ENC_STYLE||'='||G_ENC_STYLE;
    p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
    p_ctxt_str := p_ctxt_str||G_PARAM_NAME_OTM_UNAME||'='||G_OTM_UNAME;
    p_ctxt_str := p_ctxt_str||G_HARD_CHAR;
    p_ctxt_str := p_ctxt_str||G_PARAM_NAME_OTM_PSSWD||'='||G_OTM_PSWD;

    RETURN p_ctxt_str;
END Get_Context_Params;


--Posts the request to OTM
--Takes in the input and returns the CLOB data
PROCEDURE post_request_to_otm(   p_request       IN XMLType,
                                 x_response      OUT NOCOPY CLOB,
                                 x_return_status OUT NOCOPY VARCHAR2
                              )
IS
  i			NUMBER;
  l_servlet_uri		CLOB;
  l_fnd_ticket		RAW(1000);
  l_tkt_end_date	VARCHAR2(500);
  l_end_point		VARCHAR2(4000);
  l_return_status	VARCHAR2(1);
  l_response		UTL_HTTP.Resp;
  l_request		UTL_HTTP.Req;
  l_clob_response	CLOB;
  l_response_data	VARCHAR2(2000);
  l_resp_pieces		UTL_HTTP.html_pieces;
  l_profiles		VARCHAR2(1);
  l_context_params	CLOB;--VARCHAR2(32676);
  l_server_tz		VARCHAR2(100);
  l_debug_on		BOOLEAN;
  l_return_status_text  VARCHAR2(7000);

  -- Bug 5625714
  l_amt                 NUMBER;
  l_pos                 NUMBER;
  l_length              NUMBER;
  l_buffer              VARCHAR2(32767);
  -- End of Bug 5625714
--Bug 7519244
  l_context_params_tmp	CLOB;
--Bug 7519244

  wsh_otm_load_profile_failed EXCEPTION;
  wsh_otm_unavailable_exception EXCEPTION;
  wsh_null_otm_response		EXCEPTION;
  l_module_name CONSTANT VARCHAR2(2000) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'post_request_to_otm';

BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
  END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug_on) THEN
    WSH_DEBUG_SV.log(l_module_name,'before load profiles');
  END IF;

  l_profiles := load_profiles();


  IF (l_debug_on) THEN
    WSH_DEBUG_SV.log(l_module_name,'l_profiles='||l_profiles);
  END IF;

  IF l_profiles = FND_API.G_RET_STS_ERROR THEN
   RAISE wsh_otm_load_profile_failed;
  END IF;

  IF (l_debug_on) THEN
    WSH_DEBUG_SV.log(l_module_name,'After load profiles');
  END IF;

  get_secure_ticket_details ( p_op_code => G_WSH_TKT_OP_CODE,
                              p_argument => G_WSH_TKT_ARGUMENT_VALUE,
                              x_ticket => l_fnd_ticket,
                              x_server_time_zone => l_server_tz,
                              x_return_status => l_return_status);
  IF (l_debug_on) THEN
    WSH_DEBUG_SV.log(l_module_name,'After get secure tkt');
  END IF;
  IF (l_debug_on) THEN
    WSH_DEBUG_SV.log(l_module_name,'l_return_status='||l_return_status);
  END IF;

  --5226917
  --IF (l_debug_on) THEN
      --WSH_DEBUG_SV.log(l_module_name,'l_fnd_ticket='||l_fnd_ticket);
      --WSH_DEBUG_SV.log(l_module_name,'l_tkt_end_date='||l_tkt_end_date);
  --END IF;

  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       raise g_tkt_error;
  END IF;
--Bug 7519244
  l_context_params_tmp := p_request.getClobVal();
  l_context_params_tmp := REPLACE(l_context_params_tmp,'&','%26');
--Bug 7519244
  l_context_params := Get_Context_Params(l_fnd_ticket);
  l_context_params := l_context_params||G_HARD_CHAR;
  l_context_params := l_context_params||G_PARAM_NAME_RIQ_INPUT||'='||l_context_params_tmp;--Bug 7519244

  l_servlet_uri := G_WSH_OTM_SERVLET_URI; ---||'?'||l_context_params;

  IF (l_debug_on) THEN
      --5226917
      --WSH_DEBUG_SV.log(l_module_name,'l_context_params='||l_context_params);
      WSH_DEBUG_SV.log(l_module_name,'l_servlet_uri='||l_servlet_uri);
      WSH_DEBUG_SV.log(l_module_name,'to_char(length(l_context_params))='||to_char(length(l_context_params)));

  END IF;


  IF(is_SSL_Enabled(G_WSH_OTM_SERVLET_URI) = 'Y') THEN
     IF (l_debug_on) THEN
         WSH_DEBUG_SV.log(l_module_name,'SSL is enabled');
         WSH_DEBUG_SV.log(l_module_name,'g_wallet_path='||G_WALLET_PATH);
         WSH_DEBUG_SV.log(l_module_name,'g_wallet_password='||G_WALLET_PASSWORD);
     END IF;

    UTL_HTTP.SET_WALLET(G_WALLET_PATH,G_WALLET_PASSWORD);

    --l_resp_pieces := UTL_HTTP.Request_Pieces(url             => l_servlet_uri,
    --                                         proxy           => G_WSH_OTM_PROXY_SERVER,
    --                                         wallet_path     => G_WALLET_PATH,
    --                                        wallet_password => G_WALLET_PASSWORD);
  END IF;
    --l_resp_pieces := UTL_HTTP.Request_Pieces(url  => l_servlet_uri,
    --                                         proxy => G_WSH_OTM_PROXY_SERVER);
    Utl_Http.Set_Proxy (  proxy => G_WSH_OTM_PROXY_SERVER );

    UTL_HTTP.set_response_error_check ( enable => false);
    --Utl_Http.Set_Detailed_Excp_Support ( enable => true );

    l_request := UTL_HTTP.begin_request(l_servlet_uri, 'POST' );--,'HTTP/1.0');--UTL_HTTP.HTTP_VERSION_1_0);
    UTL_HTTP.SET_HEADER(l_request,'Content-Type','application/x-www-form-urlencoded');
    UTL_HTTP.SET_HEADER(l_request,'Content-length',to_char(length(l_context_params)));

    -- Bug 5625714
    -- need to repeat Utl_Http.Write_Text as it can handle
    -- only up to 32767 characters
    -- Utl_Http.Write_Text(l_request,l_context_params);
    l_amt:= 32000;
    l_pos:= 1;
    l_length:=DBMS_LOB.GETLENGTH(l_context_params);
    IF (l_debug_on) THEN
      WSH_DEBUG_SV.log(l_module_name,'Length',l_length);
    END IF;
    WHILE(l_length > 0)
    LOOP
    --{
        IF (l_length < l_amt)
        THEN
          l_amt:=l_length;
        END IF;
        IF (l_debug_on) THEN
          WSH_DEBUG_SV.log(l_module_name,'l_amt', l_amt);
        END IF;
        dbms_lob.read(l_context_params, l_amt, l_pos, l_buffer);
        Utl_Http.Write_Text(l_request,l_buffer);
        l_length:=l_length-l_amt;
        l_pos := l_pos + l_amt;
    --}
    END LOOP;
    -- End of Bug 5625714
    l_response := utl_http.get_response(l_request);

  --END IF;

  IF (l_debug_on) THEN
     WSH_DEBUG_SV.log(l_module_name,'HTTP response status code:='||l_response.status_code);
     WSH_DEBUG_SV.log(l_module_name,'HTTP response reason phras:='||l_response.reason_phrase);
    --WSH_DEBUG_SV.log(l_module_name,'l_resp_pieces.COUNT='||l_resp_pieces.COUNT);
  END IF;

  IF l_response.status_code = 500 THEN
    RAISE wsh_otm_unavailable_exception;
  END IF;

  BEGIN
    LOOP
    utl_http.read_text(l_response, l_response_data);
    IF (l_debug_on) THEN
        WSH_DEBUG_SV.log(l_module_name,'Line ='||l_response_data);
    END IF;
      l_clob_response := l_clob_response||l_response_data;
    END LOOP;
    EXCEPTION
    WHEN UTL_HTTP.end_of_body THEN
    UTL_HTTP.end_response(l_response);
  END;

  IF l_clob_response IS NULL THEN
     RAISE wsh_null_otm_response;
  END IF;

  x_response := l_clob_response;--l_response;

  IF l_debug_on THEN
    WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
    WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
WHEN wsh_null_otm_response THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status='||x_return_status);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_null_otm_response: Null response received.');
    END IF;
WHEN wsh_otm_unavailable_exception THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status='||x_return_status);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_otm_unavailable_exception: OTM Server is down. Contact the System Administrator');
    END IF;
WHEN wsh_otm_load_profile_failed THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status='||x_return_status);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:wsh_otm_load_profile_failed');
    END IF;
WHEN UTL_HTTP.INIT_FAILED THEN
  BEGIN
    EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlcode from dual' INTO x_return_status;
    x_return_status := FND_API.G_RET_STS_ERROR;
    EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlerrm from dual' INTO l_return_status_text;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'HTTP request failed because of UTL_HTTP_INIT_FAILED');
      WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status='||x_return_status||' l_return_status_text='||l_return_status_text);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.UTL_HTTP.INIT_FAILED');
    END IF;
  END;
WHEN UTL_HTTP.REQUEST_FAILED THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  l_return_status_text := 'UTL_HTTP.REQUEST_FAILED';
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'HTTP request failed because of UTL HTTP REQUEST_FAILED'||l_return_status_text);
  END IF;
  BEGIN
    EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlcode from dual' INTO x_return_status;
    x_return_status := FND_API.G_RET_STS_ERROR;
    EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlerrm from dual' INTO l_return_status_text;
    IF l_debug_on THEN
      WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status='||x_return_status||' l_return_status_text='||l_return_status_text);
      WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UTL_HTTP.REQUEST_FAILED');
    END IF;
  END;
WHEN UTL_TCP.END_OF_INPUT THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  l_return_status_text := 'UTL_TCP.END_OF_INPUT';
  IF l_debug_on THEN
    WSH_DEBUG_SV.logmsg(l_module_name,'HTTP request failed because of UTL_TCP.END_OF_INPUT');
    WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status='||x_return_status||' l_return_status_text='||l_return_status_text);
    WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:UTL_TCP.END_OF_INPUT');
  END IF;
WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'FND_API.G_EXC_ERROR exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:FND_API.G_EXC_ERROR');
    END IF;
WHEN g_tkt_error THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'g_tkt_error has occured.',WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'FND_API.G_EXC_ERROR');
    END IF;
WHEN others THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
    BEGIN
      EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlcode from dual' INTO x_return_status;
      EXECUTE IMMEDIATE 'SELECT UTL_HTTP.get_detailed_sqlerrm from dual' INTO l_return_status_text;
      IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'x_return_status='||x_return_status||' l_return_status_text='||l_return_status_text);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
      END IF;
      EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('WSH','WSH_UTL_POST_UNEXPECTED_ERROR');
        l_return_status_text := FND_MESSAGE.GET;
    END;
    END IF;
END post_request_to_otm;

-- Get FND Security details.
-- Create New if doesn't exist
-- Return existing if valid.
-- If expired, delete existing and create new
PROCEDURE get_secure_ticket_details( p_op_code          IN         VARCHAR2,
                                     p_argument         IN         VARCHAR2,
                                     x_ticket           OUT NOCOPY RAW,
                                     x_server_time_zone OUT NOCOPY VARCHAR2,
                                     x_return_status    OUT NOCOPY VARCHAR2
                                   )
IS
  l_ticket        RAW(16);
  l_ticket_string VARCHAR2(1000);
  l_operation     VARCHAR2(255);
  l_argument      VARCHAR2(4000);
  l_end_date      VARCHAR2(100);
  l_edate TimeStamp;
  l_sysdate TimeStamp;
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'get_secure_ticket_details';
  l_debug_on BOOLEAN;

  CURSOR c_get_ticket_details (c_operation VARCHAR2, c_argument VARCHAR2) IS
  SELECT ticket, operation, argument, end_date
  FROM FND_HTTP_TICKETS
  WHERE operation = c_operation
  AND   argument  = c_argument;

  --CURSOR c_get_ticket_end_date (c_ticket RAW) IS
  --SELECT to_char(end_date,'yyyy/mm/dd hh:mi:ss')
  --FROM FND_HTTP_TICKETS
  --WHERE ticket = c_ticket;

  CURSOR c_get_sysdate IS
  SELECT SYSDATE FROM DUAL;


BEGIN

  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  IF l_debug_on IS NULL  THEN
    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;

  IF l_debug_on THEN
    WSH_DEBUG_SV.push(l_module_name);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_get_ticket_details (p_op_code,p_argument);
  FETCH c_get_ticket_details INTO l_ticket,l_operation, l_argument, l_edate;
  CLOSE c_get_ticket_details;

  IF l_debug_on THEN
    --5226917
    --WSH_DEBUG_SV.log(l_module_name,'l_ticket='||l_ticket);
    WSH_DEBUG_SV.log(l_module_name,'l_operation='||l_operation);
    WSH_DEBUG_SV.log(l_module_name,'l_argument='||l_argument);
    WSH_DEBUG_SV.log(l_module_name,'l_edate='||l_edate);
  END IF;
  --FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'sysdate='||to_date(to_char(sysdate,'yyyy/mm/dd hh:mi:ss'),'yyyy/mm/dd hh:mi:ss'));

  -- Ticket Exists. Valid and not expired
  -- return the existing ticket
  OPEN c_get_sysdate;
  FETCH c_get_sysdate INTO l_sysdate;
  CLOSE c_get_sysdate;

  IF ( l_edate IS NOT NULL) AND ( l_edate > SYSDATE) THEN
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Ticket Exists. Valid and not expired');
    END IF;
    -- l_ticket is actual ticket. Do Nothing.
  -- Ticket Exists but expired.Delete existing
  ELSIF ( l_edate IS NOT NULL) AND ( l_edate < SYSDATE) THEN
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Ticket Exists but expired.Delete existing');
        WSH_DEBUG_SV.log(l_module_name,'Deleting...');
    END IF;
    FND_HTTP_TICKET.DESTROY_TICKET(l_ticket);
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'Creating new ticket...');
    END IF;
    l_ticket := FND_HTTP_TICKET.CREATE_TICKET(p_op_code
                                             ,p_argument
                                             ,G_WSH_TKT_LIFESPAN
                                             );
    --5226917
    --IF l_debug_on THEN
    --    WSH_DEBUG_SV.log(l_module_name,'new l_ticket='||l_ticket);
    --END IF;
    -- ticket doesn't exist . Get a new ticket.
    --FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_end_date='||x_end_date);
  ELSE
    IF l_debug_on THEN
        WSH_DEBUG_SV.log(l_module_name,'ticket doesnt exist . Create a new ticket');
    END IF;
    l_ticket := FND_HTTP_TICKET.CREATE_TICKET(p_op_code
                                             ,p_argument
                                             ,G_WSH_TKT_LIFESPAN
                                             );
  END IF;

  x_ticket := l_ticket;

  --5226917
  --IF l_debug_on THEN
  --    WSH_DEBUG_SV.log(l_module_name,'l_ticket='||x_ticket);
  --END IF;

  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'x_return_status',x_return_status);
     WSH_DEBUG_SV.pop(l_module_name);
  END IF;

EXCEPTION
  WHEN others THEN
    x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'Unexpected error has occured. Oracle error message is '|| SQLERRM,WSH_DEBUG_SV.C_UNEXPEC_ERR_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:OTHERS');
    END IF;

END get_secure_ticket_details;


END WSH_OTM_HTTP_UTL;


/
