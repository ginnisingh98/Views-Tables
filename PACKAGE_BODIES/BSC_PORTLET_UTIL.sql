--------------------------------------------------------
--  DDL for Package Body BSC_PORTLET_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PORTLET_UTIL" AS
/* $Header: BSCPUTLB.pls 120.0.12000000.2 2007/01/30 08:49:55 nkishore ship $ */

FUNCTION is_alignment_needed RETURN BOOLEAN;

--==========================================================================+
--    FUNCTION
--       get_jsp_server
--
--    PURPOSE
--       Returns jsp host.
--       Ex: ap100jvm.us.oracle.com
--
--    PARAMETERS

--    HISTORY
--       05-JULY-01 juwang Created.
--       12-SEP-01 juwang Created.
--==========================================================================

FUNCTION get_jsp_server RETURN VARCHAR2
IS
    ws_url VARCHAR2(2000);
    hostname VARCHAR2(2000);
    index1 NUMBER;
    index2 NUMBER;

BEGIN
    ws_url := FND_WEB_CONFIG.JSP_AGENT;  /* 'http://serv:port/OA_HTML/' */
    if ( ws_url is null ) then
	return null;
    else
        index1 := INSTRB(ws_url, '//', 1) + 2;  /* skip 'http://' */
        index2 := INSTRB(ws_url, '/', index1);  /* 'http://serv:port/' */
        hostname := SUBSTRB(ws_url, 1, index2);

        --dbms_output.put_line('get_jsp_server= ' || hostname);
        return hostname;
    end if;
END get_jsp_server;




--==========================================================================+
--    FUNCTION
--       get_webdb_host
--
--    PURPOSE
--       Returns web db host.
--       Ex: ap100jvm.us.oracle.com
--
--    PARAMETERS

--    HISTORY
--       05-JULY-01 juwang Created.
--==========================================================================

FUNCTION get_webdb_host RETURN VARCHAR2
IS
    ws_url VARCHAR2(2000);
    hostname VARCHAR2(2000);
    index1 NUMBER;
    index2 NUMBER;

BEGIN

    ws_url := FND_WEB_CONFIG.WEB_SERVER;  -- ex : 'http://ap100jvm.us.oracle.com:8724/';


    index1 := INSTRB(ws_url, '//', 1) + 2; -- skip 'http://'
    index2 := INSTRB(ws_url, ':', index1);


    IF index2 = 0 THEN     -- ex : 'http://ap100jvm.us.oracle.com/';
      hostname := SUBSTRB(ws_url, index1, length(ws_url)-index1);
    ELSE
      hostname := SUBSTRB(ws_url, index1, index2-index1);
    END IF;


    RETURN hostname;
    ---------------------------------------------------------------------
    -- testing
    -- dbms_output.put_line('FND_WEB_CONFIG.WEB_SERVER= ' || ws_url);
    -- dbms_output.put_line('second pos= ' || index2);
    -- dbms_output.put_line('host name= ' || hostname);
    ---------------------------------------------------------------------


END get_webdb_host;


--==========================================================================+
--    FUNCTION
--       get_webdb_port
--
--    PURPOSE
--       Returns web db port.
--       Ex: 8724
--
--    PARAMETERS

--    HISTORY
--       05-JULY-01 juwang Created.
--==========================================================================

FUNCTION get_webdb_port RETURN VARCHAR2
IS
    ws_url VARCHAR2(2000);
    portno VARCHAR2(500);
    index1 NUMBER;
    index2 NUMBER;

BEGIN

    ws_url := FND_WEB_CONFIG.WEB_SERVER;  -- ex : 'http://ap100jvm.us.oracle.com:8724/';


    index1 := INSTRB(ws_url, '//', 1) + 2; -- skip 'http://'
    index2 := INSTRB(ws_url, ':', index1);


    IF index2 = 0 THEN     -- ex : 'http://ap100jvm.us.oracle.com/';
      portno := '80';
    ELSE
      portno := SUBSTRB(ws_url, index2+1, length(ws_url)-index2-1);
    END IF;

    RETURN portno;
    ---------------------------------------------------------------------
    -- testing
    -- dbms_output.put_line('FND_WEB_CONFIG.WEB_SERVER= ' || ws_url);
    -- dbms_output.put_line('second pos= ' || index2);
    -- dbms_output.put_line('host name= ' || hostname);
    -- dbms_output.put_line('port name= ' || portno);
    ---------------------------------------------------------------------


END get_webdb_port;


--==========================================================================+
--    FUNCTION
--       get_bsc_url
--
--    PURPOSE
--       This procedure returns the url as the following format
--       http://[apache_host]:[apache_port]/jsp/bsc/[p_jsp_name]?
--       [base_params]&[p_ext_params].
--       If the given jsp name, p_jsp_name, is not specified,
--       BscInit.jsp will be the defaulted jsp file name.
--       If [p_extra_params is not specified, the format will be
--       http://[apache_host]:[apache_port]/jsp/bsc/[p_jsp_name]?[base_params]
--       Ex: http://ap100jvm.us.oracle.com:8792/jsp/bsc/BscInit.jsp
--
--    PARAMETERS
--       p_session_id : Portlet session id
--       p_jsp_name : Jsp name
--       p_ext_params : Extra parameters list delimitered by '&'.
--       p_is_respid_used : append responsibilityId=l_resp_id at url
--                          parmaters list if p_is_respid_used equals TRUE.
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================

FUNCTION get_bsc_url(
    p_session_id IN NUMBER,
    p_plug_id IN NUMBER,
    p_jsp_name IN VARCHAR2,
    p_ext_params IN VARCHAR2,
    p_is_respid_used IN BOOLEAN
) RETURN VARCHAR2 IS


    l_webdb_host VARCHAR2(500) := NULL;
    l_webdb_port   VARCHAR2(500) := NULL;
    l_resp_id   VARCHAR2(30) := NULL;
    l_init_path  VARCHAR2(500) := NULL;
    l_dbcFilePath  VARCHAR2(128) := NULL;
    l_sessionCookieValue VARCHAR2(128) := NULL;
    l_parameter VARCHAR2(500)   := NULL;
    l_url VARCHAR2(2000) := NULL;
    l_jsp_name VARCHAR2(50) := NULL;

BEGIN

    -----------------------------------------------------------------
    -- Check the paramters passed are correct.
    -----------------------------------------------------------------

    IF ( p_jsp_name IS NULL ) THEN
	l_jsp_name := 'BscInit.jsp';
    ELSE
	l_jsp_name := p_jsp_name;
    END IF; -- (p_jsp_name IS NULL)

    -----------------------------------------------------------------
    -- Retrive information from profile options.
    -----------------------------------------------------------------

    -- it is a valid session
    l_webdb_host := bsc_portlet_util.get_webdb_host;
    l_webdb_port   := bsc_portlet_util.get_webdb_port;

    l_init_path :=  bsc_portlet_util.get_bsc_jsp_path || l_jsp_name;

    -----------------------------------------------------------------
    --  A valid session
    -----------------------------------------------------------------

    l_dbcFilePath := FND_WEB_CONFIG.DATABASE_ID;

    -- !!! need to find out NOCOPY p_ticket
    l_sessionCookieValue := ICX_CALL.ENCRYPT3(ICX_SEC.getsessioncookie(ICX_CALL.ENCRYPT3(p_session_id)));
  --  l_sessionCookieValue := ICX_CALL.ENCRYPT3(p_session_id);


    -----------------------------------------------------------------
    -- Construct the parameter string
    -----------------------------------------------------------------


    l_parameter := 'DBC_FILE=' || l_dbcFilePath || '&' ||
                   'webHost=' || l_webdb_host || '&' ||
   	           'webPort=' || l_webdb_port || '&' ||
                   'SessionCookieValue=' || l_sessionCookieValue;


    IF ( p_is_respid_used ) THEN
       l_resp_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID,'',p_session_id);

       l_parameter := l_parameter || '&' ||
	bsc_portlet_util.PR_RESPID || '=' || l_resp_id;
    END IF;  -- (p_is_respid_used )


    IF (p_ext_params IS NOT NULL) THEN
	 l_parameter :=  l_parameter || '&' || p_ext_params;

    END IF;  -- (p_ext_params IS NOT NULL)
    l_url:= l_init_path || '?' || l_parameter;

    RETURN l_url;

EXCEPTION


   WHEN OTHERS THEN
       RETURN l_init_path;

END get_bsc_url;




--==========================================================================
--    FUNCTION
--       get_bsc_jsp_path
--
--    PURPOSE
--       This procedure returns the url path to Balanced Scorecard
--       jsp files located.
--       Ex: http://ap100jvm.us.oracle.com:8791/OA_HTML/jsp/bsc/
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================

FUNCTION get_bsc_jsp_path RETURN VARCHAR2 IS

    l_servlet_agent varchar2(500)     :=NULL;

    l_jsp_path  VARCHAR2(500)   := NULL;
    l_url VARCHAR2(500):=NULL;

BEGIN

    -- for testing oa frame work purpose
    --l_servlet_agent := fnd_profile.value('APPS_FRAMEWORK_AGENT') || 'OA_HTML/' ;

    -------------------------------------------------------------
    -- Uses 'APPS_WEB_AGENT' only if 'APPS_SERVLET_AGENT' is null
    -------------------------------------------------------------

    l_servlet_agent := FND_WEB_CONFIG.JSP_AGENT;   -- 'http://serv:port/OA_HTML/'
    l_jsp_path := 'jsp/bsc/';

    if ( l_servlet_agent is null ) then   -- 'APPS_SERVLET_AGENT' is null
	l_servlet_agent := FND_WEB_CONFIG.WEB_SERVER;
        l_jsp_path := 'OA_HTML/jsp/bsc/';
    end if;


    l_url := l_servlet_agent || l_jsp_path;

    RETURN l_url;

EXCEPTION

   WHEN OTHERS THEN
       RETURN l_jsp_path;

END get_bsc_jsp_path;


--==========================================================================
--    FUNCTION
--       update_portlet_name
--
--    PURPOSE
--
--    PARAMETERS
--
--    HISTORY
--       12-MAR-2001 juwang Created.
--==========================================================================

PROCEDURE update_portlet_name(
    p_user_id IN NUMBER,
    p_plug_id      IN pls_integer,
    p_display_name IN VARCHAR2
 ) IS

BEGIN

    UPDATE
	icx_page_plugs
    SET
        DISPLAY_NAME = p_display_name,
        LAST_UPDATE_DATE = SYSDATE,
	LAST_UPDATED_BY = p_user_id

    WHERE
	PLUG_ID = p_plug_id;



END update_portlet_name;


--==========================================================================
--    FUNCTION
--       update_portlet_name
--
--    PURPOSE
--
--    PARAMETERS
--
--    HISTORY
--       12-MAR-2001 juwang Created.
--==========================================================================

PROCEDURE gotoMainMenu(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2) IS

    l_session_id NUMBER := -1;
    l_plug_id NUMBER := -1;

BEGIN
    bsc_portlet_util.decrypt_plug_info(p_cookie_value,
	p_encrypted_plug_id, l_session_id, l_plug_id);


    IF icx_sec.validateSessionPrivate(c_session_id =>l_session_id) THEN
        icx_plug_utilities.gotoMainMenu;
    END IF;


    icx_plug_utilities.gotoMainMenu;
END gotoMainMenu;





--==========================================================================+
--    PROCEDURE
--        decrypt_plug_info
--
--    PURPOSE
--        This procedure decrypts the session id and
--        plug id.
--    PARAMETERS
--
--    HISTORY
--       15-MAR-2001 juwang Created.
--==========================================================================

PROCEDURE decrypt_plug_info(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2,
    p_session_id OUT NOCOPY NUMBER,
    p_plug_id OUT NOCOPY NUMBER) IS
BEGIN


    p_session_id := icx_call.decrypt3(p_cookie_value);
    p_plug_id := icx_call.decrypt3(p_encrypted_plug_id);

END decrypt_plug_info;



--==========================================================================+
--    PROCEDURE
--       request_html_pieces
--
--    PURPOSE
--       bug fix for 2235651
--
--    PARAMETERS
--
--    HISTORY
--       17-OCT-2001 juwang Created.
--==========================================================================

FUNCTION request_html_pieces(
  p_url               IN VARCHAR2,
  p_proxy             IN VARCHAR2 DEFAULT NULL
) RETURN utl_http.html_pieces IS
  l_wallet_path       VARCHAR2(2000);
  l_wallet_password   VARCHAR2(2000);
  l_pieces            utl_http.html_pieces;
BEGIN
  IF INSTR(UPPER(p_url), 'HTTPS://') > 0 THEN
    --l_wallet_path := ''; --fnd_profile.value('BSC_WALLET_PATH');
    --l_wallet_password := '';--fnd_profile.value('BSC_WALLET_PASSWORD');
    l_pieces := utl_http.request_pieces(
      url => p_url,
      max_pieces => 32000,
      proxy => p_proxy,
      wallet_path => '',
      wallet_password => '');
  ELSE
    l_pieces := utl_http.request_pieces(
      url => p_url,
      max_pieces => 32000,
      proxy => p_proxy);
  END IF;

  -- Check if the HTML pieces need to be realigned
  IF is_alignment_needed THEN
    RETURN re_align_html_pieces(l_pieces);
  ELSE
    RETURN l_pieces;
  END IF;
END request_html_pieces;



--==========================================================================+
--    PROCEDURE
--       re_align_html_pieces
--
--    PURPOSE
--       bug fix for 1994245
--
--    PARAMETERS
--
--    HISTORY
--       17-OCT-2001 juwang Created.
--       08-JAN-03  Adeulgao fixed Bug #2728074
--       13-JAN-03  Pradeep  fixed Bug #2732070
--==========================================================================

----------------------------------------------------------------------------
-- !!! Do not use in 9i !!!
FUNCTION re_align_html_pieces(src IN utl_http.html_pieces) RETURN
  utl_http.html_pieces
AS
  dst      utl_http.html_pieces;
  buf      RAW(2000);
  src_row  PLS_INTEGER;
  src_pos  PLS_INTEGER;
  dst_row  PLS_INTEGER;
  len      PLS_INTEGER;
  cut_len  PLS_INTEGER;
BEGIN

  src_row := 1; src_pos := 1; dst_row := 1;
  LOOP
      -- fill bytes from the source till buf is full
      BEGIN
        LOOP
            len := utl_raw.length(buf);
            EXIT WHEN (len = 2000);
            cut_len := 2000 - nvl(len,0);  -- when buff is NULL len becomes NULL which causes the infinite loop
            IF (cut_len > (lengthb(src(src_row)) - src_pos + 1)) THEN
              cut_len := lengthb(src(src_row)) - src_pos + 1;
            END IF;
            buf := utl_raw.concat(buf, utl_raw.substr(
              utl_raw.cast_to_raw(src(src_row)), src_pos, cut_len));
            src_pos := src_pos + cut_len;
            IF (src_pos > lengthb(src(src_row))) THEN
              src_row := src_row + 1;
              src_pos := 1;
            END IF;
        END LOOP;
      EXCEPTION
        WHEN no_data_found THEN
          EXIT WHEN utl_raw.length(buf) IS NULL;
      END;

      -- extract from buf at character boundary
      len := lengthb(substr(utl_raw.cast_to_varchar2(buf), 1,
        length(utl_raw.cast_to_varchar2(buf))));

      EXIT WHEN nvl(len,0) = 0;  -- bug#2765446

      dst(dst_row) := utl_raw.cast_to_varchar2(utl_raw.substr(buf, 1, len));
      IF (len < utl_raw.length(buf)) THEN
        buf := utl_raw.substr(buf, len + 1);
      ELSE
        buf := NULL;
      END IF;
      dst_row := dst_row + 1;
  END LOOP;

  RETURN dst;

END;

PROCEDURE test_https(url IN VARCHAR2) IS
  l_pieces  utl_http.html_pieces;
BEGIN
  l_pieces := request_html_pieces('https://' || url || '/');
  htp.p(l_pieces.count || ' pieces retreived.');
EXCEPTION
  WHEN OTHERS THEN
    htp.p('ERROR');
END test_https;


----------------------------------------------------------------------------
-- Alignment of HTML pieces is needed in 8i only
FUNCTION is_alignment_needed RETURN BOOLEAN IS
  l_count NUMBER;
BEGIN
  SELECT count(*) INTO l_count
  FROM v$instance VI
  WHERE VI.instance_role = 'PRIMARY_INSTANCE'
  AND trim(VI.version) like '8.%';

  IF l_count > 0 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END is_alignment_needed;



--==========================================================================+
--    PROCEDURE
--       getValue
--
--    PURPOSE
--       For example, given
--         p_key => p2
--         p_parameters => p1=v1&p2=v2&p3=v3&p4=v4
--       This function will return
--         v2
--       If either p_key is null or p_parameters is null, return null
--    PARAMETERS
--
--    HISTORY
--       11-DEC-2001 juwang Created.
--==========================================================================
FUNCTION getValue(
  p_key        IN VARCHAR2
 ,p_parameters IN VARCHAR2
 ,p_delimiter  IN VARCHAR2 := '&'
) RETURN VARCHAR2

IS
  l_key VARCHAR2(2000);
  l_parameters VARCHAR2(2000);
  l_key_start NUMBER;
  l_value_start NUMBER;
  l_amp_start NUMBER;

  l_val VARCHAR2(2000);
BEGIN
  IF ( (p_key IS NULL) or (p_parameters IS NULL)) THEN

    RETURN NULL;
  END IF;

  l_key := UPPER(p_key);
  l_parameters := UPPER(p_parameters);
--  dbms_output.put_line('p_parameters='|| p_parameters);
  -- first occurance
  l_key_start := INSTRB(l_parameters, RTRIM(l_key)|| '=', 1);
--    dbms_output.put_line('l key start='||l_key_start);
  IF (l_key_start = 0) THEN -- key not found
    RETURN NULL;
  END IF;

  -- get the starting position of v2 in "p2=v2"
  l_value_start := l_key_start + LENGTHB(p_key)+1;  -- including c_eq
  l_amp_start :=  INSTRB(p_parameters, p_delimiter, l_value_start);


  IF (l_amp_start = 0) THEN -- the last one or key not found
    l_val := SUBSTRB(p_parameters, l_value_start);
  ELSE
    l_val := SUBSTRB(p_parameters, l_value_start, (l_amp_start - l_value_start));
  END IF;
  RETURN l_val;


EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;

END getValue;


END bsc_portlet_util;

/
