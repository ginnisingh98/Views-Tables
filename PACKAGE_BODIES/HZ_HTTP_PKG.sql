--------------------------------------------------------
--  DDL for Package Body HZ_HTTP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_HTTP_PKG" AS
/*$Header: ARHHTTPB.pls 115.9 2003/12/22 14:52:23 rchanamo noship $*/

  /*PROCEDURE enable_debug;

  PROCEDURE disable_debug;
  */

  --g_debug                                 BOOLEAN := FALSE;
  g_debug_count                           NUMBER := 0;
  --------------------------------------
  -- private procedures and functions
  --------------------------------------
  --
  -- PRIVATE PROCEDURE enable_debug
  -- DESCRIPTION
  --     Turn on debug mode.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --     HZ_UTILITY_V2PUB.enable_debug
  -- MODIFICATION HISTORY
  --------------------------------------
  /*PROCEDURE enable_debug IS
  BEGIN
    g_debug_count := g_debug_count + 1;
    IF g_debug_count = 1 THEN
      IF fnd_profile.value('HZ_API_FILE_DEBUG_ON') = 'Y' OR
         fnd_profile.value('HZ_API_DBMS_DEBUG_ON') = 'Y'
      THEN
        hz_utility_v2pub.enable_debug;
        g_debug := TRUE;
      END IF;
    END IF;
  END enable_debug;
  */

  --------------------------------------
  -- PRIVATE PROCEDURE disable_debug
  -- DESCRIPTION
  --     Turn off debug mode.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --     HZ_UTILITY_V2PUB.disable_debug
  -- MODIFICATION HISTORY
  --------------------------------------
  /*PROCEDURE disable_debug IS
  BEGIN
    IF g_debug THEN
      g_debug_count := g_debug_count - 1;
      IF g_debug_count = 0 THEN
        hz_utility_v2pub.disable_debug;
        g_debug := FALSE;
      END IF;
    END IF;
  END disable_debug;
  */

  PROCEDURE write(
    c     IN OUT NOCOPY  utl_tcp.connection,
    value VARCHAR2 := NULL)
  IS
    b   pls_integer;
    l_debug_prefix		       VARCHAR2(30) := '';
  BEGIN
    b := utl_tcp.write_line(c, value);
    --enable_debug;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'The text line transmitted :'|| substrb(value,1,200),
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;
    --disable_debug;
  END write;

  PROCEDURE write_header(
    c     IN OUT NOCOPY utl_tcp.connection,
    name  VARCHAR2,
    value VARCHAR2)
  IS
  l_debug_prefix		       VARCHAR2(30) := '';
  BEGIN
    --enable_debug;
    write(c, name||': '||value);
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'The header is :'|| substrb(name||': '||value,1,200),
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;
    --disable_debug;
  END write_header;

  PROCEDURE sethostpostpath(
    url         VARCHAR2,
    proxyserver VARCHAR2,
    proxyport   NUMBER,
    host    OUT NOCOPY VARCHAR2,
    port IN OUT NOCOPY NUMBER,
    path    OUT NOCOPY VARCHAR2)
  IS
    temp    VARCHAR2(400);
    slash   NUMBER;
    colon   NUMBER;
  BEGIN
    IF proxyserver IS NOT NULL THEN
      host := proxyserver;
      port := proxyport;
      path := url;
    ELSE
      temp   := SUBSTRB(url, instrb(url, 'http://')+7);
      slash  := INSTRB(temp,'/');
      IF slash > 0 THEN
        host := SUBSTRB(temp, 1, slash-1);
        path := SUBSTRB(temp, slash);
      ELSE
        host := temp;
        path := '/';
      END IF;
      colon := instrb(host, ':');
      IF colon > 0 THEN
        port := TO_NUMBER(substrb(host, colon+1));
        host := SUBSTRB(host,1,colon-1);
      END IF;
    END IF;
  END sethostpostpath;

  --------------------------------------
  -- PRIVATE PROCEDURE get_response_from
  -- DESCRIPTION
  --   Gets an http-format response from the tcp socket and returns it into
  --   resp.  Non-http-formatted responses are returned into err_resp.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --   hz_utility_v2pub
  --   utl_tcp
  -- MODIFICATION HISTORY
  --   03-27-2002 J. del Callar Added err_resp parameter to get non-http
  --                            error messages for inclusion in log.
  --------------------------------------
  PROCEDURE get_response_from (
    c in          OUT NOCOPY utl_tcp.connection,
    resp          OUT NOCOPY VARCHAR2,
    content_type  OUT NOCOPY VARCHAR2,
    err_resp      OUT NOCOPY VARCHAR2
  ) IS
    line      VARCHAR2(32767);
    firstline BOOLEAN := TRUE;
    header    BOOLEAN := TRUE;
    success   BOOLEAN := TRUE;
    l_debug_prefix   VARCHAR2(30) := '';
  BEGIN
    --enable_debug;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_response_from (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
    WHILE success LOOP
      line := utl_tcp.get_line(c);
      IF firstline THEN
        IF line NOT LIKE '%HTTP%200%OK%' THEN
          success := FALSE;
          err_resp := line || utl_tcp.get_text(c, 32767-LENGTHB(line));
        END IF;
        firstline := FALSE;
      ELSE
        IF header THEN
          IF line = utl_tcp.crlf THEN
            header := false;
          ELSE
            IF UPPER(line) LIKE 'CONTENT-TYPE:%' THEN
              content_type := RTRIM(RTRIM(RTRIM(LTRIM(SUBSTRB(line,14))),fnd_global.local_chr(10)),fnd_global.local_chr(13));
            END IF;
          END IF;
        ELSE
          resp := resp || line;
        END IF;
      END IF;
    END LOOP;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'The response is :' || SUBSTRB(resp, 1, 200),
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   hz_utility_v2pub.debug(p_message=>'The error response is :' || SUBSTRB(err_resp, 1, 200),
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_response_from (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    --disable_debug;
  EXCEPTION
    WHEN utl_tcp.end_of_input THEN
    IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'The response is :' || SUBSTRB(resp, 1, 200),
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
    END IF;
    IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'The error response is :' || SUBSTRB(err_resp, 1, 200),
	                           p_prefix=>'ERROR',
			           p_msg_level=>fnd_log.level_error);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_response_from (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
         --disable_debug;
  END get_response_from;

  --------------------------------------
  -- PUBLIC PROCEDURE post
  -- DESCRIPTION
  --   Implements HTTP post functionality.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --   hz_utility_v2pub
  --   utl_tcp
  -- MODIFICATION HISTORY
  --   07-22-2002 J. del Callar Added for backward compatibility.
  --------------------------------------
  PROCEDURE post(
    doc                    VARCHAR2,
    content_type           VARCHAR2,
    url                    VARCHAR2,
    resp               OUT NOCOPY VARCHAR2,
    resp_content_type  OUT NOCOPY VARCHAR2,
    proxyserver            VARCHAR2 := NULL,
    proxyport              NUMBER   := 80,
    x_return_status IN OUT NOCOPY VARCHAR2,
    x_msg_count     IN OUT NOCOPY NUMBER,
    x_msg_data      IN OUT NOCOPY VARCHAR2)
  IS
    l_err_resp VARCHAR2(32767) := NULL;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    post(doc,
         content_type,
         url,
         resp,
         resp_content_type,
         proxyserver,
         proxyport,
         l_err_resp,
         x_return_status,
         x_msg_count,
         x_msg_data);

    IF l_err_resp IS NOT NULL THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR','HZ_HTTP_POST_FAILED');
      fnd_message.set_token('RETRY', '1');
      fnd_message.set_token('LASTMSG', NVL(l_err_resp, '<NULL>'));
      fnd_msg_pub.add;
    END IF;
  END post;

  --------------------------------------
  -- PUBLIC PROCEDURE post
  -- DESCRIPTION
  --   Implements HTTP post functionality.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --   hz_utility_v2pub
  --   utl_tcp
  -- MODIFICATION HISTORY
  --   03-27-2002 J. del Callar Added err_resp parameter to get non-http
  --                            error messages for inclusion in log.
  --------------------------------------
  PROCEDURE post(
    doc                    VARCHAR2,
    content_type           VARCHAR2,
    url                    VARCHAR2,
    resp               OUT NOCOPY VARCHAR2,
    resp_content_type  OUT NOCOPY VARCHAR2,
    proxyserver            VARCHAR2 := NULL,
    proxyport              NUMBER   := 80,
    err_resp           OUT NOCOPY VARCHAR2,
    x_return_status IN OUT NOCOPY VARCHAR2,
    x_msg_count     IN OUT NOCOPY NUMBER,
    x_msg_data      IN OUT NOCOPY VARCHAR2)
  IS
    port         NUMBER := 80;
    host         VARCHAR2(400);
    path         VARCHAR2(400);
    line         VARCHAR2(32767);
    firstline    BOOLEAN := TRUE;
    head         BOOLEAN := TRUE;
    success      BOOLEAN := TRUE;
    c            utl_tcp.connection;
    l_debug_prefix	VARCHAR2(30) := '';
  BEGIN
    --enable_debug;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'post (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
    sethostpostpath(url, proxyserver,proxyport,  host, port, path);
    c := utl_tcp.open_connection(host,port);
    write(c, 'POST '|| path||' HTTP/1.0');
    write_header(c, 'Content-Type', content_type);
    write_header(c, 'Content-Length', lengthb(doc));
    write(c);
    write(c, doc);
    utl_tcp.flush(c);
    get_response_from(c, resp, resp_content_type, err_resp);
    utl_tcp.close_connection(c);
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'post (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
    --disable_debug;
  EXCEPTION
    WHEN OTHERS THEN
      IF c.remote_host IS NOT NULL THEN
        utl_tcp.close_connection(c);
      END IF;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --disable_debug;
  END post;

  --------------------------------------
  -- PUBLIC PROCEDURE get
  -- DESCRIPTION
  --   Implements HTTP post functionality.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --   hz_utility_v2pub
  --   utl_tcp
  -- MODIFICATION HISTORY
  --   07-22-2002 J. del Callar Added for backward compatibility.
  --------------------------------------
  PROCEDURE get(
    url                    VARCHAR2,
    resp               OUT NOCOPY VARCHAR2,
    resp_content_type  OUT NOCOPY VARCHAR2,
    proxyserver            VARCHAR2 := NULL,
    proxyport              NUMBER   := 80,
    x_return_status IN OUT NOCOPY VARCHAR2,
    x_msg_count     IN OUT NOCOPY NUMBER,
    x_msg_data      IN OUT NOCOPY VARCHAR2)
  IS
    l_err_resp VARCHAR2(32767) := NULL;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    get(url,
        resp,
        resp_content_type,
        proxyserver,
        proxyport,
        l_err_resp,
        x_return_status,
        x_msg_count,
        x_msg_data);

    IF l_err_resp IS NOT NULL THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR','HZ_HTTP_POST_FAILED');
      fnd_message.set_token('RETRY', '1');
      fnd_message.set_token('LASTMSG', NVL(l_err_resp, '<NULL>'));
      fnd_msg_pub.add;
    END IF;
  END get;

  --------------------------------------
  -- PUBLIC PROCEDURE get
  -- DESCRIPTION
  --   Implements HTTP get functionality.
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --   hz_utility_v2pub
  --   utl_tcp
  -- MODIFICATION HISTORY
  --   03-27-2002 J. del Callar Added err_resp parameter to get non-http
  --                            error messages for inclusion in log.
  --------------------------------------
  PROCEDURE get(
    url                    VARCHAR2,
    resp               OUT NOCOPY VARCHAR2,
    resp_content_type  OUT NOCOPY VARCHAR2,
    proxyserver            VARCHAR2 := NULL,
    proxyport              NUMBER   := 80,
    err_resp           OUT NOCOPY VARCHAR2,
    x_return_status IN OUT NOCOPY VARCHAR2,
    x_msg_count     IN OUT NOCOPY NUMBER,
    x_msg_data      IN OUT NOCOPY VARCHAR2)
  IS
    port   NUMBER := 80;
    host   VARCHAR2(400);
    path   VARCHAR2(400);
    msg    VARCHAR2(32767);
    c      utl_tcp.connection;
    l_debug_prefix	VARCHAR2(30) := '';
  BEGIN
    --enable_debug;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
    sethostpostpath( url, proxyserver, proxyport, host, port, port);
    c := utl_tcp.open_connection(host, port);
    write(c, 'GET '||path||' HTTP/1.0');
    write(c);
    utl_tcp.flush(c);
    get_response_from(c, resp, resp_content_type, err_resp);
    utl_tcp.close_connection(c);
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;
    --disable_debug;
  EXCEPTION
    WHEN OTHERS THEN
      IF c.remote_host IS NOT NULL THEN
        utl_tcp.close_connection(c);
      END IF;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      --disable_debug;
  END get;

END hz_http_pkg;

/
