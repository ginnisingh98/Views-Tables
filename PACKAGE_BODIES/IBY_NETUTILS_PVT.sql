--------------------------------------------------------
--  DDL for Package Body IBY_NETUTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_NETUTILS_PVT" AS
/* $Header: ibynutlb.pls 120.7.12010000.1 2008/07/28 05:41:20 appldev ship $ */

  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_NETUTILS_PVT';

  --
  PROCEDURE set_proxy(p_url IN VARCHAR2)
  IS
   l_proxy        VARCHAR2(500) := NULL;
   l_noproxy      VARCHAR2(500);

   l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.use_proxy';
  BEGIN

    iby_utility_pvt.get_property(G_PROFILE_HTTP_PROXY,l_proxy);

    IF (NOT (TRIM(l_proxy) IS NULL)) THEN
      iby_utility_pvt.get_property(G_PROFILE_NO_PROXY,l_noproxy);
      l_noproxy := TRIM(l_noproxy);

      UTL_HTTP.set_proxy(l_proxy,l_noproxy);
    END IF;
  END set_proxy;

  --
  --
  FUNCTION decode_url_chars (p_string     IN VARCHAR2,
			     p_local_nls IN VARCHAR2 DEFAULT NULL,
			     p_remote_nls IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
  IS
	l_raw             RAW(32767);
        l_char            VARCHAR2(4);
        l_hex             VARCHAR2(8);
        l_len             INTEGER;
        i                 INTEGER := 1;
  BEGIN

	IF (p_string IS NULL) THEN
	   return p_string;
	END IF;

        l_len := length(p_string);

        WHILE i <= l_len
        LOOP
            l_char := substr(p_string, i, 1);
            IF l_char = '+' THEN
                /* convert to a hex number of space characters */
                l_hex := '20';
                i := i + 1;
            ELSIF l_char = '%' THEN
                /* process hex encoded characters. just remove a % character */
                l_hex := substr(p_string, i+1, 2);
                i := i + 3;
            ELSE
                /* convert to hex numbers for all other characters */
                l_hex := to_char(ascii(l_char), 'FM0X');
                i := i + 1;
            END IF;
            /* convert a hex number to a raw datatype */
            l_raw := l_raw || hextoraw(l_hex);
         END LOOP;

         /*
          * convert a raw data from the source charset to the database charset,
          * then cast it to a varchar2 string.
          */
         RETURN utl_raw.cast_to_varchar2(
                          utl_raw.convert(l_raw, p_local_nls, p_remote_nls));
	 EXCEPTION
		WHEN OTHERS THEN
		  RETURN p_string;
  END decode_url_chars;

  --
  --
  FUNCTION escape_url_chars (p_string IN VARCHAR2,
			     p_local_nls IN VARCHAR2 DEFAULT NULL,
			     p_remote_nls IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
  IS
	l_local_charset VARCHAR2(200);
	l_remote_charset VARCHAR2(200);

	l_tmp VARCHAR2(32767);

        -- must be large enough to hold 4 bytes multibyte char
        l_onechar	VARCHAR2(4);

        -- buffer to hold converted number 2*l_onechar+1 for leading 0
        l_str		VARCHAR2(48);
        l_byte_len	INTEGER;

	-- whether the local/remote machines have different character
	-- sets
	l_do_convert	 BOOLEAN := false;

	-- characters which should not be touched
        c_unreserved constant varchar2(72) :=
        '-_.!~*''()ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  BEGIN

	l_tmp:='';

        IF ( p_string IS NULL ) THEN
          return NULL;
        END IF;

	l_local_charset := iby_utility_pvt.get_nls_charset(p_local_nls);
	l_remote_charset := iby_utility_pvt.get_nls_charset(p_remote_nls);

	IF (l_remote_charset IS NULL) OR (l_local_charset IS NULL) THEN
		l_do_convert := false;
	ELSE
		l_do_convert := (l_local_charset <> l_remote_charset );
	END IF;

        FOR i in 1 .. length(p_string) LOOP
            l_onechar := substr(p_string,i,1);

            IF instr(c_unreserved, l_onechar) > 0 THEN
                /* if this character is excluded from encoding */
                l_tmp := l_tmp || l_onechar;
            ELSIF l_onechar = ' ' THEN
                /* spaces are encoded using the plus "+" sign */
                l_tmp := l_tmp || '+';
            ELSE
                IF (l_do_convert) THEN
                 /*
                  * This code to be called ONLY in case when client and server
                  * charsets are different. The performance of this code is
                  * significantly slower than "else" portion of this statement.
                  * But in this case it is guarenteed to be working in
                  * any configuration where the byte-length of the charset
                  * is different between client and server (e.g. UTF-8 to SJIS).
                  */

                  /*
                   * utl_raw.convert only takes a qualified NLS_LANG value in
                   * <langauge>_<territory>.<charset> format for target and
                   * source charset parameters. Need to use l_client_nls_lang
                   * and g_db_nls_lang here.
                   */
                    l_str := utl_raw.convert(utl_raw.cast_to_raw(l_onechar),
                        p_remote_nls,
                        p_local_nls);
                    l_byte_len := length(l_str);
                    IF l_byte_len = 2 THEN
                        l_tmp := l_tmp
                            || '%' || l_str;
                    ELSIF l_byte_len = 4 THEN
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2);
                    ELSIF l_byte_len = 6 THEN
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2)
                            || '%' || substr(l_str,5,2);
                    ELSIF l_byte_len = 8 THEN
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2)
                            || '%' || substr(l_str,5,2)
                            || '%' || substr(l_str,7,2);
                    ELSE /* maximum precision exceeded */
                        raise PROGRAM_ERROR;
                    END IF;
                ELSE
                 /*
                  * This is the "simple" encoding when no charset translation
                  * is needed, so it is relatively fast.
                  */
                    l_byte_len := lengthb(l_onechar);
                    IF l_byte_len = 1 THEN
                        l_tmp := l_tmp || '%' ||
                            substr(to_char(ascii(l_onechar),'FM0X'),1,2);
                    ELSIF l_byte_len = 2 THEN
                        l_str := to_char(ascii(l_onechar),'FM0XXX');
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2);
                    ELSIF l_byte_len = 3 THEN
                        l_str := to_char(ascii(l_onechar),'FM0XXXXX');
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2)
                            || '%' || substr(l_str,5,2);
                    ELSIF l_byte_len = 4 THEN
                        l_str := to_char(ascii(l_onechar),'FM0XXXXXXX');
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2)
                            || '%' || substr(l_str,5,2)
                            || '%' || substr(l_str,7,2);
                    ELSE /* maximum precision exceeded */
                        raise PROGRAM_ERROR;
                    END IF;
                END IF;
            END IF;
        END LOOP;

	RETURN l_tmp;

  EXCEPTION
	WHEN others THEN
             RAISE encoding_error;
  END escape_url_chars;

----------------------------------------------------------------------------------
  /* UTILITY PROCEDURE #0.1: GET_LOCAL_NLS
      Function returns the local (i.e. database) characterset.

    */
----------------------------------------------------------------------------------
   FUNCTION get_local_nls
   RETURN VARCHAR2
   IS
   BEGIN
	return userenv('LANGUAGE');
   EXCEPTION WHEN others THEN
	     return NULL;

   END get_local_nls;



------------------------------------------------------------------------------------
   /* UTILITY PROCEDURE #1: UNPACK_RESULTS_URL
      PARSER Procedure to take in given l_string in html file format,
      parse l_string, and store the Name-Value pairs in l_names and l_values.
      For example, if OapfPrice Name-Value pairs exist in l_string, it would be
      stored as l_names(i) := 'OapfPrice' and l_values(i) := '17.00'.

      NOTE: This procedure logic is exactly similar to the iPayment 3i version
            of procedure with minor enhancements and bug fixes.
   */
------------------------------------------------------------------------------------
   PROCEDURE unpack_results_url(p_string     IN  VARCHAR2,
                                x_names      OUT NOCOPY v240_tbl_type,
                                x_values     OUT NOCOPY v240_tbl_type,
                                x_status     OUT NOCOPY NUMBER,
                                x_errcode    OUT NOCOPY NUMBER,
                                x_errmessage OUT NOCOPY VARCHAR2
                                ) IS

    l_length    NUMBER(15)    := LENGTH(p_string) + 1;
    l_count     NUMBER(15)    := 0;
    l_index     NUMBER(15)    := 1;
    l_char      VARCHAR2(1)    := '';
    l_word      VARCHAR2(2400)  := '';
    l_name      BOOLEAN       := TRUE;
    l_local_nls VARCHAR2(200);
    l_remote_nls VARCHAR2(200);
   BEGIN

     iby_debug_pub.add('In unpack_results_url');

     -- Initialize status, errcode, errmessage to Success.
     x_status := 0;
     x_errcode := 0;
     x_errmessage := 'Success';

     l_local_nls := get_local_nls();

     -- verify what HTTP response format is returned by the server
     -- NOTE: Since ECServlet is not supposed to return in this format,
     -- this condition should not be encountered.
     l_count := instr(p_string,'</H2>Oapf');
     IF l_count > 0 THEN
        l_count := l_count + 5;
     ELSE return;
     END IF;

     --Fixing Bug from OM: 1104438
     --Suggested improvement to this: Search for the first alphanumeric
     --character [a-zA-Z0-9] encountered in this string.set l_count to that position.
     --l_count := INSTR(p_string, 'Oapf');
     --End of Bug Fix 1104438

     WHILE l_count < l_length LOOP
        IF (l_name) AND (substr(p_string,l_count,1) = ':') THEN
           x_names(l_index) := substr( (ltrim(rtrim(l_word))), 1, 240 );
           --dbms_output.put_line('Name :  ' ||x_names(l_index) );
           l_name := FALSE;
           l_word := '';
           l_count := l_count + 1;
        ELSIF (l_name) THEN
           l_char := substr(p_string,l_count,1);
           l_word := l_word||l_char;
           l_count := l_count + 1;
        ELSIF upper(substr(p_string,l_count,4)) = '<BR>' THEN
           x_values(l_index) := substr( (ltrim(rtrim(l_word))), 1, 240 );
           --dbms_output.put_line('Value :  ' ||x_values(l_index) );
	   -- remember the NLS Lang parameter for below decoding
	   IF (x_names(l_index) = 'OapfNlsLang') THEN
		l_remote_nls := x_values(l_index);
	   END IF;

           l_name := TRUE;
           l_word := '';
           l_index := l_index + 1;
           l_count := l_count + 4;
        ELSE
           l_char := substr(p_string,l_count,1);
           l_word := l_word||l_char;
           l_count := l_count + 1;
        END IF;

        /*--Note: Can Add this to extra ensure that
        --additional white spaces get trimmed.
        x_names(l_count) := LTRIM(RTRIM(x_names(l_count) ));
        x_values(l_count) := LTRIM(RTRIM(x_values(l_count) )); */

     END LOOP;

     -- do URL decoding if on the output values if possible
     --

     --dbms_output.put_line('unpack::local nls: ' || l_local_nls);
     --dbms_output.put_line('unpack::remote nls: ' || l_remote_nls);

     /*
     IF ((l_remote_nls IS NOT NULL) AND (l_local_nls IS NOT NULL)) THEN
	FOR i in 1..x_values.COUNT LOOP
	   x_values(i) := decode_url_chars(x_values(i),l_local_nls,l_remote_nls);
	END LOOP;
     END IF;
    */

     iby_debug_pub.add('Exit unpack_results_url');

   EXCEPTION
      WHEN OTHERS THEN
         /* Return a status of -1 to the calling API to indicate
            errors in unpacking html body results.  */
         --dbms_output.put_line('error in unpacking procedure');
     	 x_status := -1;
         x_errcode := to_char(SQLCODE);
         x_errmessage := SQLERRM;
   END unpack_results_url;


--------------------------------------------------------------------------------------------
   /* UTILITY PROCEDURE #6: GET_BASEURL
      Procedure to retrieve the iPayment ECAPP BASE URL
   */
--------------------------------------------------------------------------------------------
  PROCEDURE get_baseurl(x_baseurl OUT NOCOPY VARCHAR2)
  IS
    -- Local variable to hold the property name for the URL.
    p_temp_var       	VARCHAR2(2);

  BEGIN

    iby_debug_pub.add('In get_baseurl');
    iby_utility_pvt.get_property(iby_payment_adapter_pub.C_ECAPP_URL_PROP_NAME,x_baseurl);
    --dbms_output.put_line('x_return_status = '|| x_return_status);

    --Raising Exception to handle errors if value is missing
      IF ((x_baseurl IS NULL) OR (trim(x_baseurl) = '')) THEN
          FND_MESSAGE.SET_NAME('IBY', 'IBY_204406');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    --appending '?' if not already present in the url
      p_temp_var := SUBSTR(x_baseurl, -1);

      IF( p_temp_var <> '?' ) THEN
        x_baseurl := x_baseurl || '?';
      END IF;

      iby_debug_pub.add('base url=' || x_baseurl);

      iby_debug_pub.add('Exit get_baseurl');

  END get_baseurl;


--------------------------------------------------------------------------------------------
   /* UTILITY PROCEDURE #7: POST_REQUEST Handles CLOB POST message
      Procedure to call HTTP_UTIL.POST_REQUEST and handle exceptions thrown by it
   */
--------------------------------------------------------------------------------------------
 PROCEDURE post_request(p_url       IN VARCHAR2,
                        p_postbody  IN CLOB,
                        x_names      OUT NOCOPY v240_tbl_type,
                        x_values     OUT NOCOPY v240_tbl_type,
                        x_status     OUT NOCOPY NUMBER,
                        x_errcode    OUT NOCOPY NUMBER,
                        x_errmessage OUT NOCOPY VARCHAR2
                       ) IS
   l_get_baseurl   VARCHAR2(2000) ;
   --The following 3 variables are meant for output of
   --get_baseurl procedure.
   l_status_url    VARCHAR2(2000);
   l_msg_count_url NUMBER := 0;
   l_msg_data_url  VARCHAR2(2000);

   l_url           VARCHAR2(4000);

   l_position     NUMBER := 0;
   l_host         VARCHAR2(4000);
   l_port         VARCHAR2(80) := NULL;
   l_post_info    VARCHAR2(2000);
   l_postbody_length NUMBER;
   l_buff         VARCHAR2(32767);
   l_pos          NUMBER := 1;
   l_len          NUMBER;
   l_html         VARCHAR2(32767);

   l_conn         UTL_TCP.CONNECTION;  -- TCP/IP connection to the Web server
   l_ret_val      PLS_INTEGER;
   l_content_len  NUMBER := 0;
   i              NUMBER := 1;

BEGIN


      --l_get_baseurl := 'http://incq186sc.idc.oracle.com/servlets/snoop';
      -- Construct the full URL to send to the ECServlet.
      l_url := p_url;

      l_position := INSTR(lower(l_url),lower('http://'));
      --remove the 'http://'
      IF (l_position > 0) THEN
         l_url := SUBSTR(l_url,8);
      ELSE
        l_position := INSTR(lower(l_url),lower('https://'));
        --remove the 'https://'
        IF (l_position > 0) THEN
           l_url := SUBSTR(l_url,9);
        END IF;
      END IF;

      -- get the host address
      l_position := INSTR(l_url,':');
      IF (l_position > 0) THEN
        l_host := SUBSTR(l_url,1,l_position-1);
        --remove the 'the host + :' from the URL
        l_url := SUBSTR(l_url,l_position+1);
      ELSE
        l_position := INSTR(l_url,'/');
        IF (l_position > 0) THEN
          l_host := SUBSTR(l_url,1,l_position-1);
          --remove the 'the host' from the URL
          l_url := SUBSTR(l_url,l_position);
        END IF;
      END IF;

      -- get the port number
      l_position := INSTR(l_url,'/');
      IF (l_position > 0) THEN
        l_port := SUBSTR(l_url,1,l_position-1);
      END IF;
      IF (l_port is NULL) THEN
        l_port := '80';
      END IF;

      --remove the port number from the URL
      l_post_info := SUBSTR(l_url,l_position);
      l_post_info := 'POST ' || l_post_info || ' HTTP/1.0';

      --dbms_output.put_line('l_post_info = ' || l_post_info);

      --dbms_output.put_line('l_host = ' || l_host);
      --dbms_output.put_line('l_port = ' || l_port);
      --dbms_output.put_line('POST BoDY Length = ' ||  DBMS_LOB.GETLENGTH(p_postbody));

      l_conn := utl_tcp.open_connection(remote_host => l_host,
                                   remote_port => l_port);

      l_ret_val := utl_tcp.write_line(l_conn, l_post_info);
      l_ret_val := utl_tcp.write_line(l_conn,'Accept: text/plain');
      l_ret_val := utl_tcp.write_line(l_conn,'Content-type: application/x-www-form-urlencoded');

       -- get the length of the clob
      l_postbody_length := DBMS_LOB.GETLENGTH(p_postbody);
      --l_content_len := 0 ;
      l_content_len := l_postbody_length;
      l_ret_val := utl_tcp.write_line(l_conn,'Content-length: '||l_content_len);
      l_ret_val := utl_tcp.write_line(l_conn);



      -- splitting the clob into varchar2 and posting it.
      WHILE (l_pos <= l_postbody_length) LOOP
         l_len := 32767;
         DBMS_LOB.READ(p_postbody,l_len,l_pos,l_buff);
         l_pos := l_pos + length(l_buff);
	  --dbms_output.put_line('Read :' || l_buff);
        l_ret_val := utl_tcp.write_text(l_conn,l_buff,null);
      END LOOP;


      BEGIN
      LOOP
        l_html := substr(utl_tcp.get_line(l_conn,TRUE),1,30000);
        l_html := LTRIM(RTRIM(l_html));
        --dbms_output.put_line('Response length:' || length(x_htmldoc));
        --dbms_output.put_line('Response frag : "' || l_html||'"');
        --dbms_output.put_line('Response frag length: "' || length(l_html)||'"');
        if (length(l_html) is null) then
           --dbms_output.put_line('Raising Exception...');
           raise utl_tcp.end_of_input;
        end if;
        --x_htmldoc := x_htmldoc || l_html;

        --dbms_output.put_line('Response Param: "' || ltrim(rtrim(substr(l_html ,1,instr(l_html,':')-1)))||'"');
        --dbms_output.put_line('Response Value: "' || ltrim(rtrim(substr(l_html ,instr(l_html,':')+1,length(l_html)+1)))||'"');
        x_names(i) :=  ltrim(rtrim(substr(l_html ,1,instr(l_html,':')-1)));
        x_values(i) := ltrim(rtrim(substr(l_html ,instr(l_html,':')+1,length(l_html)+1)));
        i := i + 1;

      END LOOP;
      EXCEPTION
         WHEN utl_tcp.end_of_input THEN
         NULL; -- end of input
      END;

      --dbms_output.put_line('Final Response length  :'|| length(x_htmldoc));
      utl_tcp.close_connection(l_conn);

      EXCEPTION
      WHEN OTHERS THEN
         /* Return a status of -1 to the calling API to indicate
            errors in unpacking html body results.  */
         --dbms_output.put_line('error in unpacking procedure');
     	 x_status := -1;
         x_errcode := to_char(SQLCODE);
         x_errmessage := SQLERRM;
END;



--------------------------------------------------------------------------------------------
   /* UTILITY PROCEDURE #7: POST_REQUEST
      Procedure to call HTTP_UTIL.POST_REQUEST and handle exceptions thrown by it
   */
--------------------------------------------------------------------------------------------

   PROCEDURE post_request(p_url       IN VARCHAR2,
                          p_postbody  IN VARCHAR2,
                          x_htmldoc OUT NOCOPY VARCHAR2
                       ) IS
   l_ret_val      PLS_INTEGER;
   l_content_len  NUMBER := 0;

   l_url          VARCHAR2(1000);
   l_walletpath   VARCHAR2(1000);
   l_line         VARCHAR2(4000);

   l_httpreq      UTL_HTTP.Req;
   l_httpresp     UTL_HTTP.Resp;
   l_sent_req     BOOLEAN := false;
   l_got_resp     BOOLEAN := false;

   l_dbg_mod VARCHAR2(100) := G_DEBUG_MODULE || '.post_request';
BEGIN
      iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

      IF (SUBSTR(p_url,1,6)='https:') THEN
        iby_debug_pub.add('SSL url; setting wallet',
          iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

        iby_utility_pvt.get_property
        (iby_security_pkg.C_SHARED_WALLET_LOC_PROP_NAME,l_walletpath);
        l_walletpath := iby_netutils_pvt.path_to_url(l_walletpath);
        utl_http.set_wallet(l_walletpath,NULL);
      END IF;
      set_proxy(p_url);

      iby_debug_pub.add('starting req',iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      l_httpreq := utl_http.begin_request(p_url,'POST',null);

      iby_debug_pub.add('set headers',iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
      utl_http.set_header(l_httpreq,'Accept','text/plain');
      utl_http.set_header(l_httpreq,'Content-type',
                          'application/x-www-form-urlencoded');
      utl_http.set_header(l_httpreq,'Content-length',
                          TO_CHAR(length(p_postbody)));


      iby_debug_pub.add('writing body',iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

      utl_http.write_line(l_httpreq,p_postbody);
      l_sent_req := true;
      iby_debug_pub.add('reading resp',iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

      l_httpresp := UTL_HTTP.get_response(l_httpreq);
      l_got_resp :=true;
      iby_debug_pub.add('resp status code:=' || l_httpresp.status_code,
        iby_debug_pub.G_LEVEL_ERROR,l_dbg_mod);

      BEGIN
        LOOP
          utl_http.read_text(l_httpresp,l_line,4000);
          x_htmldoc := x_htmldoc || l_line;
        END LOOP;
      EXCEPTION
       WHEN utl_http.end_of_body THEN
         NULL; -- end of input
      END;

      UTL_HTTP.end_response(l_httpresp);

      iby_debug_pub.add('Exit',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
  EXCEPTION
    WHEN OTHERS THEN
      iby_debug_pub.add('err code=' || utl_http.get_detailed_sqlcode,
        iby_debug_pub.G_LEVEL_ERROR,l_dbg_mod);
      iby_debug_pub.add('err msg=' || SUBSTR(utl_http.get_detailed_sqlerrm,1,150),
        iby_debug_pub.G_LEVEL_ERROR,l_dbg_mod);

      IF (l_got_resp) THEN
        UTL_HTTP.end_response(l_httpresp);
        iby_debug_pub.add('close resp',iby_debug_pub.G_LEVEL_ERROR,l_dbg_mod);
        iby_debug_pub.add('resp status code:=' || l_httpresp.status_code,
          iby_debug_pub.G_LEVEL_ERROR,l_dbg_mod);
      ELSIF (l_sent_req) THEN
        UTL_HTTP.end_request(l_httpreq);
        iby_debug_pub.add('close req',iby_debug_pub.G_LEVEL_ERROR,l_dbg_mod);
      END IF;
      RAISE;
END;

--------------------------------------------------------------------------------------------
   /* UTILITY PROCEDURE #2: CHECK_MANDATORY
      Procedure to take in given URL string: p_url,
                                     name-value pair strings: p_name, p_value
      Check if p_value is NOT NULL. If not NULL, then append p_name=p_value to p_url.
      If p_value is NULL, then an exception is raised and passed to the
      calling program.
      NOTE: This procedure checks only for MANDATORY INPUT parameters.
      Decision on which should be mandatory is decided by the business logic.

      NLS ARGS (used to encode the parameters that go into the URL):

	    p_local_nls -  the NLS value of the local system (as pulled
                            from DB)
            p_remote_nls - the NLS value for the remote system

   */
--------------------------------------------------------------------------------------------
  PROCEDURE check_mandatory (p_name    IN     VARCHAR2,
                             p_value   IN     VARCHAR2,
                             p_url     IN OUT NOCOPY VARCHAR2,
			     p_local_nls IN VARCHAR2 DEFAULT NULL,
			     p_remote_nls IN VARCHAR2 DEFAULT NULL
                             ) IS
    l_url VARCHAR2(2000) := p_url;
  BEGIN
    /* Logic:
    1. Check if value is null. if null, then raise exception to pass to ECApp;
    3. If not null, then append to URL.
    */

    IF (p_value is NULL) THEN
       --Note: Reused an existing IBY message and token.
       FND_MESSAGE.SET_NAME('IBY', 'IBY_0004');
       FND_MESSAGE.SET_TOKEN('FIELD', p_name);
       FND_MSG_PUB.Add;

       -- jleybovi [10/24/00]
       --
       -- should return an expected error exception here as missing input is
       -- considered a "normal" error
       --
       --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    ELSE
       --Append this <name>=<value> to the input URL
       p_url := p_url||p_name||'='||escape_url_chars(p_value,p_local_nls,p_remote_nls)||'&';
    END IF;

--    ??? who installed the exception catch below???
--    keep it for the time being as it allows a better error message, code
--    to be returned than by aborting within PL/SQL
--      [jlebovi 11/29/2001]
  EXCEPTION

    WHEN OTHERS THEN
      p_url := l_url;

  END check_mandatory;
--------------------------------------------------------------------------------------------
   /* UTILITY PROCEDURE #3: CHECK_OPTIONAL
      Procedure to take in given URL string: p_url,
                                     name-value pair strings: p_name, p_value
      Check if p_value is NOT NULL, If NOT NULL, append p_name=p_value to p_url.
      Otherwise, if p_value is NULL, then p_url is unchanged.
      NOTE: This procedure checks only for OPTIONAL INPUT parameters and does not
      validate MANDATORY INPUT parameters.

      NLS ARGS (used to encode the parameters that go into the URL):

	    p_local_nls -  the NLS value of the local system (as pulled
                            from DB)
            p_remote_nls - the NLS value for the remote system

   */
--------------------------------------------------------------------------------------------
  PROCEDURE check_optional (p_name  IN     VARCHAR2,
                            p_value IN     VARCHAR2,
                            p_url   IN OUT NOCOPY VARCHAR2,
			    p_local_nls IN VARCHAR2 DEFAULT NULL,
			    p_remote_nls IN VARCHAR2 DEFAULT NULL
                            ) IS
    l_url VARCHAR2(2000) := p_url;
  BEGIN

    /* Logic:
    1. check value if null.
       if null then don't do anything.
    2. If not null, then append to URL.
    */

    IF (p_value IS NULL) THEN
       p_url := l_url;
    ELSE
       --Append this <name>=<value> to the input URL
       p_url := p_url||p_name||'='||escape_url_chars(p_value,p_local_nls,p_remote_nls)||'&';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_url := l_url;

  END check_optional;


FUNCTION path_to_url(p_path IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
  --
  -- URLs have '/' as the path separator, regardless of
  -- platform
  --
  RETURN iby_netutils_pvt.G_FILE_PROTOCOL
    || iby_netutils_pvt.G_NET_PATH_SEP
    || replace(p_path,'\',iby_netutils_pvt.G_NET_PATH_SEP);
END path_to_url;

END IBY_NETUTILS_PVT;

/
