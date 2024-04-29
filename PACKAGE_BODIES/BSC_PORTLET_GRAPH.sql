--------------------------------------------------------
--  DDL for Package Body BSC_PORTLET_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PORTLET_GRAPH" AS
/* $Header: BSCPGHB.pls 115.13 2003/02/12 14:26:33 adrao ship $ */

--
-- Package constants
--






--==========================================================================
--    PROCEDURE
--       Plug
--
--    PURPOSE
--       This procedure displays the Kpi graph portlet.  If p_delete = 'Y',
--       it deletes the record from bsc_user_kpigraph_plugs table.
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
PROCEDURE Plug(p_session_id IN pls_integer,
               p_plug_id    IN pls_integer,
  	       p_display_name IN VARCHAR2 DEFAULT null,
               p_delete     IN VARCHAR2 DEFAULT 'N') IS

     l_user_id pls_integer;
     l_resp_id pls_integer;


     l_ctm_url VARCHAR2(2000);
     l_target_url VARCHAR2(2000);
     l_tab_id NUMBER := -1;
     l_kpi_id NUMBER := -1;
     l_temp  NUMBER := -1;

     CURSOR c_kg_p IS
	 SELECT k.RESPONSIBILITY_ID,
                bt.TAB_ID,
	        k.INDICATOR
	 FROM   BSC_USER_KPIGRAPH_PLUGS k,
                BSC_TAB_INDICATORS bt
	 WHERE  k.USER_ID = l_user_id
	 AND    k.PLUG_ID = p_plug_id
         AND    k.INDICATOR = bt.INDICATOR;


     CURSOR c_plug IS
	 SELECT k.INDICATOR
	 FROM   BSC_USER_KPIGRAPH_PLUGS k
	 WHERE  k.USER_ID = l_user_id
	 AND    k.PLUG_ID = p_plug_id;




     CURSOR c_tab_kpi IS
	 SELECT bt.TAB_ID
	 FROM   BSC_USER_KPIGRAPH_PLUGS k,
                BSC_TAB_INDICATORS bt
	 WHERE  k.USER_ID = l_user_id
	 AND    k.PLUG_ID = p_plug_id
         AND    k.INDICATOR = bt.INDICATOR;

BEGIN

    IF icx_sec.validatePlugSession(p_plug_id,p_session_id) THEN

        l_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'',p_session_id);

        IF p_delete = 'Y' THEN
	    --------------------------------------------
	    -- should clean up bsc_user_kpigraph_plugs
	    --------------------------------------------
	    DELETE FROM bsc_user_kpigraph_plugs
	    WHERE user_id = l_user_id
	    AND   plug_id = p_plug_id;

	    COMMIT;
	    RETURN;
        ELSE -- p_delete = 'N'

  	    --------------------------------------------
	    -- find the record in BSC_USER_KPIGRAPH_PLUGS
	    --------------------------------------------
  	    OPEN c_kg_p;
      	    FETCH c_kg_p INTO l_resp_id, l_tab_id, l_kpi_id;

            IF c_kg_p%FOUND THEN  -- the record is found

		 -- check if it has priviledge to view this kpi
		 IF (bsc_portlet_graph.has_access(p_plug_id)) THEN
		     l_ctm_url:= bsc_portlet_graph.get_customized_kpigraph_url(
			      p_session_id, p_plug_id, l_tab_id, l_kpi_id,
			      FALSE, l_resp_id, p_display_name);


		     l_target_url:= bsc_portlet_graph.get_portlet_kpigraph_url(
			      p_session_id, p_plug_id, l_tab_id, l_kpi_id,
			      l_resp_id);

		 ELSE -- no priviledge
                     l_ctm_url:= bsc_portlet_graph.get_customized_kpigraph_url(
	             	p_session_id, p_plug_id, l_tab_id, l_kpi_id,
	  	       TRUE, bsc_portlet_util.VALUE_NOT_SET,
                       p_display_name);

 		     l_target_url := bsc_portlet_util.get_bsc_url(p_session_id, p_plug_id, 'BscPorWarnNoPriv.jsp', NULL, TRUE);

	 	 END IF;  -- (bsc_portlet_graph.has_access(p_plug_id))


	    ELSE
    	        --------------------------------------------
		-- no kpi selected, should be empty graph
    	        --------------------------------------------
                l_ctm_url:= bsc_portlet_graph.get_customized_kpigraph_url(
	              	p_session_id, p_plug_id, l_tab_id, l_kpi_id,
			TRUE, bsc_portlet_util.VALUE_NOT_SET, p_display_name);


   	        ----------------------------------------------
		-- bug# 1745058, make sure if no row in BSC_USER_KPIGRAPH_PLUGS
	        ----------------------------------------------
		OPEN c_plug;
       	        FETCH c_plug INTO l_temp;

                IF c_plug%NOTFOUND THEN -- no row
      		    l_target_url := bsc_portlet_util.get_bsc_url(p_session_id, p_plug_id, 'BscPorWarnEmpty.jsp', NULL, TRUE);

                ELSE  -- has customized already

		    ----------------------------------------------
		    -- bug# 1739823
		    -- check if this kpi is unchecked from the tab
		    ----------------------------------------------
		    OPEN c_tab_kpi;
          	    FETCH c_tab_kpi INTO l_temp;
		    IF c_tab_kpi%FOUND THEN
			l_target_url := bsc_portlet_util.get_bsc_url(p_session_id, p_plug_id, 'BscPorWarnEmpty.jsp', NULL, TRUE);

		    ELSE -- uncheck from the tab in builder
			l_target_url := bsc_portlet_util.get_bsc_url(p_session_id, p_plug_id, 'BscPorWarnNoPriv.jsp', NULL, TRUE);


		    END IF;  --c_tab_kpi%FOUND
		    CLOSE c_tab_kpi;


                END IF; --c_plug%NOTFOUND
		CLOSE c_plug;

            END IF;  -- c_kg_p%FOUND
     	    CLOSE c_kg_p;

   	    bsc_portlet_graph.draw_kpi_graph(
				l_ctm_url,
				l_target_url, p_session_id,
			       	p_plug_id, p_display_name);




        END IF; -- p_delete = 'Y'
    END IF; -- icx_sec.validatePlugSession

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        htp.p(SQLERRM);
END Plug;






--==========================================================================+
--    PROCEDURE
--       has_access
--
--    PURPOSE
--       This procedure checks if the customized portlet has access to
--       this tab and indicator.
--
--    PARAMETERS
--       p_plug_id  portlet id
--
--    HISTORY
--       18-MAR-2001 juwang Created.
--==========================================================================
FUNCTION has_access(
    p_plug_id IN NUMBER) RETURN BOOLEAN IS

    l_kpi_id NUMBER := -1;

    CURSOR c IS
    SELECT bk.INDICATOR
    FROM
        fnd_user_resp_groups fg,
	fnd_responsibility fr,
	bsc_user_responsibility_v br,
	bsc_user_kpigraph_plugs bp,
        bsc_tab_indicators bti,
	bsc_user_tab_access bta,
	bsc_user_kpi_access bk
    WHERE
	bp.PLUG_ID = p_plug_id AND
	bp.USER_ID = br.USER_ID AND
        fg.USER_ID = bp.USER_ID AND
        fg.RESPONSIBILITY_ID = bp.RESPONSIBILITY_ID AND
        sysdate BETWEEN nvl(fg.START_DATE, sysdate) AND
        nvl(fg.END_DATE, sysdate) AND
        fr.RESPONSIBILITY_ID = fg.RESPONSIBILITY_ID AND
        sysdate BETWEEN nvl(fr.START_DATE, sysdate) AND
        nvl(fr.END_DATE, sysdate) AND
	bp.RESPONSIBILITY_ID = br.RESPONSIBILITY_ID AND
	bp.RESPONSIBILITY_ID = bta.RESPONSIBILITY_ID AND
        bp.INDICATOR = bti.INDICATOR AND
	bti.TAB_ID = bta.TAB_ID AND
	SYSDATE BETWEEN bta.START_DATE AND
	NVL(bta.END_DATE, SYSDATE) AND
	bp.RESPONSIBILITY_ID = bk.RESPONSIBILITY_ID AND
	bp.INDICATOR = bk.INDICATOR AND
	SYSDATE BETWEEN NVL(bk.START_DATE(+), SYSDATE) AND
	NVL(bk.END_DATE, SYSDATE);

BEGIN

	OPEN c;
	FETCH c INTO l_kpi_id;

	IF c%FOUND THEN  -- the record is found
	     CLOSE c;
	     RETURN TRUE;

	ELSE
	     CLOSE c;
	     RETURN FALSE;

	END IF;  -- c%FOUND



END has_access;





--==========================================================================+
--    PROCEDURE
--       re_align_html_pieces
--
--    PURPOSE
--       bug fix for 1994245
--    PARAMETERS
--
--
--
--
--    HISTORY
--       17-OCT-2001 juwang Created.
--==========================================================================

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
            cut_len := 2000 - len;
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
          EXIT WHEN utl_raw.length(buf) = 0;
      END;

      -- extract from buf at character boundary
      len := lengthb(substr(utl_raw.cast_to_varchar2(buf), 1,
        length(utl_raw.cast_to_varchar2(buf))));
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



--==========================================================================+
--    PROCEDURE
--       draw_kpi_graph
--
--    PURPOSE
--       This procedure draws the contents of kpi graph portlet.  If
--       p_customized is TRUE, draw the graph, otherwise (it is empty),
--       displays a message showing "You have not configured the portlet."
--    PARAMETERS
--
--
--
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
PROCEDURE draw_kpi_graph(
    p_ctm_url      IN VARCHAR2,
    p_target_url   IN VARCHAR2,
    p_session_id   IN pls_integer,
    p_plug_id      IN pls_integer,
    p_display_name IN VARCHAR2 DEFAULT NULL) IS


    l_ask VARCHAR2(100);
    l_display_name VARCHAR2(100);

    l_html_pieces utl_http.html_pieces;
    -- l_ret_status NUMBER := -1;
    l_errmsg VARCHAR2(2000);
    l_url VARCHAR2(2000);
    l_k_url VARCHAR2(2000);
    INIT_FAILED exception;
    REQUEST_FAILED exception;
BEGIN

    /* check if region name has been customized */
    SELECT display_name into l_display_name
    FROM icx_page_plugs
    WHERE plug_id = p_plug_id;

    IF ( l_display_name IS NULL ) THEN
	l_ask := '';
    ELSE
        l_ask := l_display_name;
    END IF;
    -----------------------------------------------------------------
    --l_html_pieces := bsc_portlet_graph.re_align_html_pieces(utl_http.request_pieces(url => p_target_url, max_pieces => 32000));
    l_html_pieces := bsc_portlet_util.request_html_pieces(p_url => p_target_url);


    -----------------------------------------------------------------

    htp.p('<!-- My Balanced Scorecard Indicator Graph Plug -->');
    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=100%>');
    htp.p('<tr><td>');

    icx_plug_utilities.plugbanner(nvl(p_display_name, l_ask),
						   p_ctm_url,
						   'bscigrph.gif');

    htp.p('</td></tr>');
    htp.p('<tr><td>');
    -----------------------------------------------------------------
    -- inserting record for testing
    -- l_errmsg := bsc_portlet_graph.set_customized_data_private(0, p_plug_id, 0, 2, 3001, 0, 0, l_ret_status);
    -- htp.p('err code=' || l_ret_status);
    -----------------------------------------------------------------

    FOR i in 1..l_html_pieces.count LOOP
	htp.prn(l_html_pieces(i));
    END LOOP;


    -----------------------------------------------------------------
    -- outputing for tessting !!!
    -- l_k_url := bsc_portlet_graph.get_kpi_url(p_session_id, p_plug_id);
    -- htp.p('ctm url=' || p_ctm_url);
    -- l_errmsg := icx_call.encrypt(p_display_name);
    -- htp.p('target=' || p_target_url);
    -----------------------------------------------------------------
    htp.p('</td></tr>');
    htp.p('</table>');

EXCEPTION

    WHEN OTHERS THEN
         show_err(p_ctm_url, l_ask, p_display_name);
END draw_kpi_graph;



--==========================================================================+
--    PROCEDURE
--       show_err
--
--    PURPOSE
--       This procedure shows the same content as BscPorWarnNetErr.jsp
--
--    PARAMETERS
--
--
--
--
--    HISTORY
--       02-MAY-2001 juwang Created.
--==========================================================================
PROCEDURE show_err(
	p_ctm_url IN VARCHAR2,
 	l_ask IN VARCHAR2,
	p_display_name IN VARCHAR2 DEFAULT NULL) IS
BEGIN

    htp.p('<table border=0 cellspacing=0 cellpadding=0 width=100%>');
    htp.p('<tr><td>');
    icx_plug_utilities.plugbanner(nvl(p_display_name, l_ask),
 				   p_ctm_url, 'bscigrph.gif');

    htp.p('</td></tr>');
    htp.p('<tr><td>');

--    htp.p('OTHERS!!');
    -- BscPorWarnNetErr.jsp
    htp.p('<table width="100%" border="0" cellspacing="0" cellpadding="0">');
    htp.p('  <tr>');
    htp.p('    <td width="40" align="center"><img src="/OA_MEDIA/bscerroricon_pagetitle.gif" width="32" height="32"></td>');
    htp.p('    <td valign=bottom><span style="COLOR: #cc0000; FONT-SIZE: 16pt">Error</span></td>');
    htp.p('  </tr>');
    htp.p('  <tr>');
    htp.p('    <td width="40" align="center"><img src=/OA_MEDIA/bscpixel.gif height=1 width=10></td>');
    htp.p('    <td style="BACKGROUND-COLOR: #cccc99" height=1><img src=/OA_MEDIA/bscpixel.gif height=1 width=10></td>');
    htp.p('  </tr>');
    htp.p('  <tr>');
    htp.p('    <td valign="top" width="40" align="center" height="5"><img src=/OA_MEDIA/bscpixel.gif height=1 width=10></td>');
    htp.p('    <td height="5"><span style="COLOR: #000000; FONT-SIZE: 10pt"><img src=/OA_MEDIA/bscpixel.gif height=1 width=10></span></td>');
    htp.p('  </tr>');
    htp.p('  <tr>');
    htp.p('<td valign="top" width="40" align="center">&nbsp;</td>');

    htp.p('    <td>');
    htp.p('    <p><b><span style="COLOR: #000000; FONT-SIZE: 10pt">Network Problems</span></b></p>');
    htp.p('    </td>');
    htp.p('  </tr>');
    htp.p('  <tr>');
    htp.p('    <td valign="top" width="40" align="center" height="5"><img src=/OA_MEDIA/bscpixel.gif height=1 width=10></td>');
    htp.p('    <td height="5"><span style="COLOR: #000000; FONT-SIZE: 10pt"><img src=/OA_MEDIA/bscpixel.gif height=1 width=10></span></td>');
    htp.p('  </tr>');
    htp.p('  <tr>');
    htp.p('    <td valign="top" width="40" align="center">&nbsp;</td>');

    htp.p('    <td><span style="COLOR: #000000; FONT-SIZE: 10pt">The server could be down or is not responding. Please try again later or contact your administrator if the problem persist.</span><br></td>');
    htp.p('  </tr>');
    htp.p('</table>');






    htp.p('</td></tr>');
    htp.p('</table>');
END show_err;





--==========================================================================+
--    PROCEDURE
--       launch_bsckpi_jsp
--
--    PURPOSE
--       This procedure replaces the current browser with bsc kpi page.
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
PROCEDURE launch_bsckpi_jsp(
    p_session_id IN pls_integer,
    p_plug_id IN pls_integer) IS

    l_kpi_url  VARCHAR2(2000):= NULL;
    e_reqserver_not_set exception;


BEGIN


   IF icx_sec.validatePlugSession(p_plug_id,p_session_id) THEN

     l_kpi_url:= bsc_portlet_util.get_bsc_url(p_session_id,
	p_plug_id, 'BscInit.jsp', NULL, FALSE);

     htp.p('<html><body onload="window.location.replace('''|| l_kpi_url || ''');">' ||  '</body></html>');
   END IF; -- icx_sec.validatePlugSession

EXCEPTION

   WHEN OTHERS THEN
        htp.p(SQLERRM);
/*
  WHEN E_REQSERVER_NOT_SET THEN
    htp.p('por_redirect.reqserver '|| 'reqserver_not_set exception ' ||
             l_progress || ' '|| sqlerrm);

  WHEN OTHERS THEN
    htp.p('por_redirect.reqserver '|| l_progress || ' '|| sqlerrm);
*/
END launch_bsckpi_jsp;



--==========================================================================+
--    PROCEDURE
--       get_tab_url
--
--    PURPOSE
--       This procedure returns the url to the jsp for displaying
--       Balanced Scorecard Tab page.  It also includes the necessary
-- 	 parameters.
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
FUNCTION get_tab_url(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2
) RETURN VARCHAR2 IS

    l_session_id NUMBER := -1;
    l_plug_id NUMBER := -1;
BEGIN

    bsc_portlet_util.decrypt_plug_info(p_cookie_value,
	p_encrypted_plug_id, l_session_id, l_plug_id);

    RETURN get_tab_url(l_session_id, l_plug_id);

END get_tab_url;







--==========================================================================+
--    PROCEDURE
--       get_kpi_url
--
--    PURPOSE
--       This procedure returns the url to the jsp for displaying
--       Balanced Scorecard Tab page.  It also includes the necessary
-- 	 parameters.
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
FUNCTION get_kpi_url(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2
) RETURN VARCHAR2 IS

    l_session_id NUMBER := -1;
    l_plug_id NUMBER := -1;
BEGIN

    bsc_portlet_util.decrypt_plug_info(p_cookie_value,
	p_encrypted_plug_id, l_session_id, l_plug_id);

    RETURN get_kpi_url(l_session_id, l_plug_id);


END get_kpi_url;







--==========================================================================+
--    PROCEDURE
--       get_tab_url
--
--    PURPOSE
--       This procedure returns the url to the jsp for displaying
--       Balanced Scorecard Tab page.  It also includes the necessary
-- 	 parameters.
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
FUNCTION get_tab_url(
    p_session_id IN NUMBER,
    p_plug_id    IN NUMBER
) RETURN VARCHAR2 IS


    l_ext_params VARCHAR2(2000):= NULL;

    l_tab_url  VARCHAR2(2000):= NULL;
    l_resp_id NUMBER := bsc_portlet_util.VALUE_NOT_SET;
    l_tab_id NUMBER := bsc_portlet_util.VALUE_NOT_SET;
    l_kpi_id NUMBER := bsc_portlet_util.VALUE_NOT_SET;


BEGIN

    bsc_portlet_graph.get_customized_data_private(p_session_id,
	p_plug_id, l_resp_id, l_tab_id, l_kpi_id);

    l_ext_params := get_pluginfo_params(l_resp_id, p_session_id, p_plug_id) ||'&' || bsc_portlet_util.PR_TABCODE || '=' || l_tab_id;

    l_tab_url := bsc_portlet_util.get_bsc_url(p_session_id, p_plug_id, 'BscInit.jsp', l_ext_params, FALSE);



    RETURN l_tab_url;


EXCEPTION

    WHEN OTHERS THEN
   	RETURN l_tab_url;

END get_tab_url;






--==========================================================================+
--    PROCEDURE
--       get_kpi_url
--
--    PURPOSE
--       This procedure returns the url to the jsp for displaying
--       Balanced Scorecard Kpi page.  It also includes the necessary
--	parameters.
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
FUNCTION get_kpi_url(
    p_session_id IN NUMBER,
    p_plug_id    IN NUMBER
) RETURN VARCHAR2 IS


    l_ext_params VARCHAR2(2000):= NULL;

    l_kpi_url  VARCHAR2(2000):= NULL;
    l_resp_id NUMBER := bsc_portlet_util.VALUE_NOT_SET;
    l_tab_id NUMBER := bsc_portlet_util.VALUE_NOT_SET;
    l_kpi_id NUMBER := bsc_portlet_util.VALUE_NOT_SET;



BEGIN

    bsc_portlet_graph.get_customized_data_private(p_session_id,
	p_plug_id, l_resp_id, l_tab_id, l_kpi_id);

    l_ext_params := get_pluginfo_params(l_resp_id, p_session_id, p_plug_id) ||'&' || bsc_portlet_util.PR_KCODE || '=' || l_kpi_id;

    l_kpi_url := bsc_portlet_util.get_bsc_url(p_session_id, p_plug_id, 'BscInit.jsp', l_ext_params, FALSE);



    RETURN l_kpi_url;

EXCEPTION

    WHEN OTHERS THEN
   	RETURN l_kpi_url;

END get_kpi_url;




--==========================================================================+
--    PROCEDURE
--       get_pluginfo_params
--
--    PURPOSE
--       This procedure builds the paramters list.
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
FUNCTION get_pluginfo_params(
    p_resp_id IN NUMBER,
    p_session_id IN NUMBER,
    p_plug_id    IN NUMBER
) RETURN VARCHAR2 IS


    l_ext_params VARCHAR2(200):= NULL;


BEGIN

    l_ext_params := bsc_portlet_util.PR_RESPID || '=' || p_resp_id;
/*
    l_ext_params := bsc_portlet_util.PR_RESPID || '=' || p_resp_id || '&' ||
                'pSessionId=' || p_session_id  || '&' ||
                'pPlugId=' || p_plug_id;
*/

    RETURN l_ext_params;



END get_pluginfo_params;




--==========================================================================+
--    PROCEDURE
--       get_portlet_kpigraph_url
--
--    PURPOSE
--       This procedure returns the url for the kpi graph
--       portlet.  It also includes the necessary
--	 parameters.
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
FUNCTION get_portlet_kpigraph_url(
    p_session_id IN pls_integer,
    p_plug_id IN pls_integer,
    p_tab_id IN NUMBER,
    p_kpi_id IN NUMBER,
    p_resp_id IN NUMBER) RETURN VARCHAR2 IS


    l_url VARCHAR2(2000):= NULL;
    l_ext_params VARCHAR2(100)   := NULL;

BEGIN

    l_ext_params := bsc_portlet_util.PR_RESPID || '=' || p_resp_id || '&' ||
	            bsc_portlet_util.PR_KCODE || '=' || p_kpi_id  || '&' ||
	            'pPlugId=' || icx_call.encrypt3(p_plug_id);

    -----------------------------------------------------
    -- Now, we form the url by passing jsp name and extra params.
    -- NOTE: do not use preferences's responsibility id.
    -----------------------------------------------------
    l_url := bsc_portlet_util.get_bsc_url(
			p_session_id,
			p_plug_id,
			'BscPorKpi.jsp',
			l_ext_params,
			FALSE);


    RETURN l_url;

EXCEPTION

    WHEN OTHERS THEN
   	RETURN null;

END get_portlet_kpigraph_url;




--==========================================================================+
--    FUNCTION
--       get_customized_kpigraph_url
--
--    PURPOSE
--       This procedure returns the url for customize the kpi graph
--       portlet.  It also includes the necessary
--	 parameters.
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
FUNCTION get_customized_kpigraph_url(
    p_session_id IN pls_integer,
    p_plug_id IN pls_integer,
    p_tab_id IN NUMBER,
    p_kpi_id IN NUMBER,
    p_is_never_customized IN BOOLEAN,
    p_resp_id IN NUMBER,
    p_display_name IN VARCHAR2) RETURN VARCHAR2 IS

    enc_disp_name VARCHAR2(1000):= NULL;
    l_url VARCHAR2(2000):= NULL;
    l_ext_params VARCHAR2(100)   := NULL;

BEGIN

/*
    l_ext_params := 'pSessionId=' || p_session_id  || '&' ||
                    'pPlugId=' || p_plug_id;
*/
    l_ext_params := 'pPlugId=' || icx_call.encrypt3(p_plug_id);

    -- it has been customized, resonsibility id is available
    IF ( NOT p_is_never_customized ) THEN

       l_ext_params := l_ext_params || '&' ||
        bsc_portlet_util.PR_KCODE || '=' || p_kpi_id  || '&' ||
	bsc_portlet_util.PR_RESPID || '=' || p_resp_id;


    END IF;  -- (p_is_respid_used )

    l_url := bsc_portlet_util.get_bsc_url(
			p_session_id,
			p_plug_id,
			'BscGraphPortletCust.jsp',
			l_ext_params,
		        FALSE);


    RETURN l_url;

EXCEPTION

    WHEN OTHERS THEN
   	RETURN null;

END get_customized_kpigraph_url;







--==========================================================================+
--    PROCEDURE
--       get_customized_data_private
--
--    PURPOSE
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
PROCEDURE get_customized_data_private(
    p_session_id IN pls_integer,
    p_plug_id    IN pls_integer,
    p_o_resp_id  OUT NOCOPY NUMBER,
    p_o_tab_id   OUT NOCOPY NUMBER,
    p_o_kpi_id   OUT NOCOPY NUMBER) IS

    l_user_id NUMBER;

    CURSOR c_kg_p IS
        SELECT k.RESPONSIBILITY_ID,
               bt.TAB_ID,
               k.INDICATOR
	FROM   BSC_USER_KPIGRAPH_PLUGS k,
               BSC_TAB_INDICATORS bt
	WHERE  k.USER_ID = l_user_id
	AND    k.PLUG_ID = p_plug_id
        AND    k.INDICATOR = bt.INDICATOR;

BEGIN

    IF icx_sec.validatePlugSession(p_plug_id,p_session_id) THEN

        l_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'',p_session_id);
 	--------------------------------------------
	-- find the record in BSC_USER_KPIGRAPH_PLUGS
	--------------------------------------------
  	OPEN c_kg_p;
      	FETCH c_kg_p INTO p_o_resp_id, p_o_tab_id, p_o_kpi_id;

        IF c_kg_p%FOUND THEN
	    RETURN;

        ELSE
            p_o_resp_id := bsc_portlet_util.VALUE_NOT_SET;
            p_o_tab_id := bsc_portlet_util.VALUE_NOT_SET;
            p_o_kpi_id := bsc_portlet_util.VALUE_NOT_SET;

        END IF; --c_kg_p%FOUND


    END IF; -- icx_sec.validatePlugSession(p_plug_id,p_session_id)

END get_customized_data_private;






--==========================================================================+
--    PROCEDURE
--       set_customized_data_private
--
--    PURPOSE
--        This procedure is used internally.  It should not be used
--        by java program.
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
FUNCTION set_customized_data_private(
    p_user_id IN NUMBER,
    p_plug_id IN NUMBER,
    p_resp_id IN NUMBER,
    p_kpi_id IN NUMBER,
    p_createy_by IN NUMBER,
    p_last_updated_by IN NUMBER,
    p_porlet_name IN VARCHAR2,
    p_o_ret_status OUT NOCOPY NUMBER) RETURN VARCHAR2 IS

    insert_err  EXCEPTION;
    update_err  EXCEPTION;

    l_errmesg VARCHAR2(2000) := bsc_portlet_util.MSGTXT_SUCCESS;
    l_count NUMBER := 0;

BEGIN
     SELECT count(*)
     INTO   l_count
     FROM   BSC_USER_KPIGRAPH_PLUGS k
     WHERE
	 k.USER_ID = p_user_id AND
	 k.PLUG_ID = p_plug_id;

    IF (l_count > 0) THEN  -- record exists, need to update

	UPDATE
	    BSC_USER_KPIGRAPH_PLUGS
  	SET
            RESPONSIBILITY_ID = p_resp_id,
	    INDICATOR = p_kpi_id,
	    LAST_UPDATE_DATE = SYSDATE,
	    LAST_UPDATED_BY = p_last_updated_by
	WHERE
	    USER_ID = p_user_id AND
	    PLUG_ID = p_plug_id;

        IF SQL%ROWCOUNT = 0 THEN
              RAISE update_err;
        END IF;

    ELSE -- record does not exist, insert it

	INSERT INTO BSC_USER_KPIGRAPH_PLUGS (
            USER_ID, PLUG_ID, RESPONSIBILITY_ID, INDICATOR,
      	    CREATION_DATE, CREATED_BY,
	    LAST_UPDATE_DATE,  LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN)
	VALUES (
	    p_user_id, p_plug_id, p_resp_id, p_kpi_id,
	    SYSDATE, p_createy_by,
	    SYSDATE, p_last_updated_by,
	    p_last_updated_by);

        IF SQL%ROWCOUNT = 0 THEN
           RAISE insert_err;
        END IF;

    END IF;  -- (l_count > 0)

    -- update display name  !!!!
    bsc_portlet_util.update_portlet_name(p_user_id, p_plug_id, p_porlet_name);

    -- everything works ok so we commit
    COMMIT;
    p_o_ret_status := bsc_portlet_util.CODE_RET_SUCCESS;
    RETURN bsc_portlet_util.MSGTXT_SUCCESS;

EXCEPTION

    WHEN insert_err THEN
        ROLLBACK;
        p_o_ret_status := bsc_portlet_util.CODE_RET_ERROR;
        l_errmesg := 'Error inserting to BSC_USER_KPIGRAPH_PLUGS';
	RETURN l_errmesg;


    WHEN update_err THEN
        ROLLBACK;
        p_o_ret_status := bsc_portlet_util.CODE_RET_ERROR;
        l_errmesg := 'Error updating to BSC_USER_KPIGRAPH_PLUGS';
	RETURN l_errmesg;

    WHEN OTHERS THEN
        ROLLBACK;
        p_o_ret_status := bsc_portlet_util.CODE_RET_ERROR;
	l_errmesg :=  'Error in bsc_portlet_graph.set_customized_data_private. SQLERRM = ' || SQLERRM;
	RETURN l_errmesg;



END set_customized_data_private;





--==========================================================================+
--    FUNCTION
--       get_customization
--
--    PURPOSE
--       This function is used by
--       oracle.apps.bsc.iviewer.thinext.client.ThinDataExtractor
--       class.
--    PARAMETERS
--       p_has_access : 1=>TRUE, 0->FALSE
--    HISTORY
--       08-MAR-2001 juwang Created.

--==========================================================================
FUNCTION get_customization(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2,
    p_resp_id OUT NOCOPY NUMBER,
    p_tab_id OUT NOCOPY NUMBER,
    p_kpi_id OUT NOCOPY NUMBER,
    p_display_name OUT NOCOPY VARCHAR2,
    p_has_access OUT NOCOPY NUMBER) RETURN NUMBER IS

    l_session_id NUMBER;
    l_plug_id NUMBER;
    l_user_id NUMBER;


    CURSOR c_kg_p IS
        SELECT k.RESPONSIBILITY_ID, k.INDICATOR, p.DISPLAY_NAME
        FROM   bsc_user_kpigraph_plugs k,
               icx_page_plugs p
        WHERE
	    p.PLUG_ID = l_plug_id AND
	    k.PLUG_ID(+)= p.PLUG_ID AND
	    k.USER_ID(+) = l_user_id;


    CURSOR c_tab IS
        SELECT bt.TAB_ID
        FROM bsc_tab_indicators bt
        WHERE
            bt.INDICATOR = p_kpi_id;


    CURSOR c_fm IS
	SELECT PROMPT
        FROM fnd_menu_entries_vl fme,
	     icx_page_plugs ipp
        WHERE
	     ipp.PLUG_ID = l_plug_id AND
	     fme.menu_id = ipp.menu_id and
	     fme.ENTRY_SEQUENCE = ipp.ENTRY_SEQUENCE;

BEGIN


    bsc_portlet_util.decrypt_plug_info(p_cookie_value,
	p_encrypted_plug_id, l_session_id, l_plug_id);

    p_has_access := 0;
    IF icx_sec.validatePlugSession(l_plug_id, l_session_id) THEN
        l_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'',l_session_id);

        OPEN c_kg_p;
        FETCH c_kg_p INTO p_resp_id, p_kpi_id, p_display_name;

        IF c_kg_p%FOUND THEN  -- the record is found

            -- get the tab id this indicator belongs
            OPEN c_tab;
            FETCH c_tab INTO p_tab_id;
            IF c_tab%NOTFOUND THEN
                p_tab_id := bsc_portlet_util.VALUE_NOT_SET;
            END IF; --c_tab%NOTFOUND
            CLOSE c_tab;



	    -- checks if  display name is null
	    IF (p_display_name IS NULL) THEN
		OPEN c_fm;
                FETCH c_fm INTO  p_display_name;
                CLOSE c_fm;
	    END IF; -- (p_display_name IS NULL)


 	    IF (bsc_portlet_graph.has_access(l_plug_id)) THEN
		p_has_access := 1;
            ELSE
		p_has_access := 0;
            END IF;
	    CLOSE c_kg_p;
 	    RETURN bsc_portlet_util.CODE_RET_SUCCESS;

        ELSE  -- not found, no such plug i
   	    p_has_access := 0;
   	    CLOSE c_kg_p;
	    RETURN bsc_portlet_util.CODE_RET_NOROW;

        END IF;  -- c_kg_p%FOUND

    ELSE  -- session expires
	RETURN bsc_portlet_util.CODE_RET_SESSION_EXP;
    END IF;  -- icx_sec.validatePlugSession(l_plug_id, l_session_id)

END get_customization;











--==========================================================================+
--    FUNCTION
--       set_customization
--
--    PURPOSE
--       This function is used by
--       oracle.apps.bsc.iviewer.thinext.client.ThinDataExtractor
--       class.
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================

FUNCTION set_customization(
    p_cookie_value IN VARCHAR2,
    p_encrypted_plug_id IN VARCHAR2,
    p_resp_id IN NUMBER,
    p_kpi_id IN NUMBER,
    p_portlet_name IN VARCHAR2,
    p_o_ret_status OUT NOCOPY NUMBER) RETURN VARCHAR2 IS


    session_expire_err  EXCEPTION;
    l_session_id NUMBER := -1;
    l_plug_id NUMBER := -1;
    l_user_id NUMBER := -1;

    l_errmsg VARCHAR2(2000) := bsc_portlet_util.MSGTXT_SUCCESS;

BEGIN

    bsc_portlet_util.decrypt_plug_info(p_cookie_value,
	p_encrypted_plug_id, l_session_id, l_plug_id);


    IF icx_sec.validatePlugSession(l_plug_id, l_session_id) THEN

        l_user_id := icx_sec.getID(icx_sec.PV_USER_ID,'', l_session_id);
        l_errmsg := bsc_portlet_graph.set_customized_data_private(l_user_id,
	l_plug_id, p_resp_id,  p_kpi_id,
	l_user_id, l_user_id, p_portlet_name, p_o_ret_status);

        RETURN l_errmsg;

    ELSE  -- session expires now

        RAISE session_expire_err;


    END IF;  -- icx_sec.validatePlugSession

    -- icx_plug_utilities.gotoMainMenu;
    -- htp.p(l_errmsg);

EXCEPTION

    WHEN session_expire_err THEN

       p_o_ret_status := bsc_portlet_util.CODE_RET_SESSION_EXP;
       l_errmsg := bsc_portlet_util.MSGTXT_SESSION_EXP;
       RETURN l_errmsg;


    WHEN OTHERS THEN
        return 'Error';

END set_customization;


















--==========================================================================+
--    FUNCTION
--       get_graph_image
--
--    PURPOSE
--       This function passes the blob to caller
--
--
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
FUNCTION get_graph_image(
    p_resp_id IN NUMBER,
    p_kpi_id IN NUMBER,
    p_graph_key IN VARCHAR2,
    p_fbody OUT NOCOPY BLOB,
    p_o_ret_status OUT NOCOPY NUMBER) RETURN VARCHAR2 IS

    insert_err  EXCEPTION;
    update_err  EXCEPTION;

    l_db_gkey VARCHAR2(100);  -- stores the key retrieved from db
    l_errmesg VARCHAR2(2000) := bsc_portlet_util.MSGTXT_SUCCESS;
    l_w NUMBER := 600;
    l_h NUMBER := 400;
--    l_sq_img_id NUMBER;



    CURSOR c_kg IS
        SELECT bsi.FILE_BODY
        FROM   bsc_kpi_graphs k,
	       bsc_sys_images bsi
        WHERE
	    k.RESPONSIBILITY_ID = p_resp_id AND
	    k.INDICATOR = p_kpi_id AND
	    k.GRAPH_KEY = p_graph_key AND
            k.IMAGE_ID = bsi.IMAGE_ID;

BEGIN

     OPEN c_kg;
     FETCH c_kg INTO p_fbody;

     IF c_kg%FOUND THEN
        ---------------------------------------------------
	-- row exists in bsc_sys_images and bsc_kpi_graphs
        ---------------------------------------------------
        CLOSE c_kg;
        p_o_ret_status := bsc_portlet_util.CODE_RET_SUCCESS;
        l_errmesg := bsc_portlet_util.MSGTXT_SUCCESS;
        RETURN l_errmesg;

     ELSE
        ---------------------------------------------------
	-- row does not exist
        ---------------------------------------------------
        CLOSE c_kg;
        p_o_ret_status := bsc_portlet_util.CODE_RET_NOROW;
        l_errmesg := bsc_portlet_util.MSGTXT_NOROW;
        RETURN l_errmesg;

     END IF;  -- c_kg%FOUND



EXCEPTION

    WHEN OTHERS THEN
        IF c_kg%ISOPEN THEN
            CLOSE c_kg;
        END IF;

        p_o_ret_status := bsc_portlet_util.CODE_RET_ERROR;
	RETURN l_errmesg;



END get_graph_image;





--==========================================================================+
--    FUNCTION
--       save_graphkey
--
--    PURPOSE
--        This fucntion makes sure
--         1. The record by the given p_resp_id, p_kpi_id, p_graph_key
--            exists in bsc_kpi_graphs and the record with given p_img_id
--            exists in bsc_sys_images.
--    PARAMETERS
--
--    HISTORY
--       08-MAR-2001 juwang Created.
--==========================================================================
FUNCTION save_graphkey(
    p_user_id IN NUMBER,
    p_resp_id IN NUMBER,
    p_kpi_id IN NUMBER,
    p_graph_key IN VARCHAR2,
    p_img_id OUT NOCOPY NUMBER,
    p_o_ret_status OUT NOCOPY NUMBER) RETURN VARCHAR2 IS

    insert_err  EXCEPTION;
    update_err  EXCEPTION;

    l_gkey VARCHAR2(100);
    l_errmesg VARCHAR2(2000) := bsc_portlet_util.MSGTXT_SUCCESS;
    l_w NUMBER := 550;
    l_h NUMBER := 250;

    CURSOR c_kg IS
        SELECT k.IMAGE_ID, k.GRAPH_KEY
        FROM   bsc_kpi_graphs k,
	       bsc_sys_images bsi
        WHERE
	    k.RESPONSIBILITY_ID = p_resp_id AND
	    k.INDICATOR = p_kpi_id AND
            k.IMAGE_ID = bsi.IMAGE_ID;

BEGIN

     OPEN c_kg;
     FETCH c_kg INTO p_img_id, l_gkey;

     IF c_kg%FOUND THEN
        ---------------------------------------------------
	-- row exists in bsc_sys_images and bsc_kpi_graphs
        ---------------------------------------------------

        IF l_gkey = p_graph_key THEN
            ------------------------------------------------
            -- graph key is the same, no need to update
            -- make sure all the return vars are set.
            ------------------------------------------------
            CLOSE c_kg;
            p_o_ret_status := bsc_portlet_util.CODE_RET_SUCCESS;
            RETURN bsc_portlet_util.MSGTXT_SUCCESS;
        END IF;


        ------------------------------------------------
        -- graph key is different, need to update record
        ------------------------------------------------
        UPDATE bsc_kpi_graphs
        SET
       	    GRAPH_KEY = p_graph_key,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = p_user_id
        WHERE
	    RESPONSIBILITY_ID = p_resp_id AND
	    INDICATOR = p_kpi_id;


        IF SQL%ROWCOUNT = 0 THEN
            l_errmesg := 'Error updating bsc_kpi_graphs. RESPONSIBILITY_ID=' || p_resp_id || ', INDICATOR=' || p_kpi_id  ;
            RAISE update_err;
        END IF;


        UPDATE bsc_sys_images
        SET
       	    FILE_NAME = p_graph_key,
       	    DESCRIPTION = p_graph_key,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = p_user_id
        WHERE
	    IMAGE_ID = p_img_id;


        IF SQL%ROWCOUNT = 0 THEN
            l_errmesg := 'Error updating bsc_kpi_graphs. RESPONSIBILITY_ID=' || p_resp_id || ', INDICATOR=' || p_kpi_id  ;
            RAISE update_err;
        END IF;


     ELSE
        ---------------------------------------------------
	-- Record does not exist both in bsc_kpi_graphs and bsc_sys_images
        ---------------------------------------------------
/*
        SELECT bsc_sys_image_id_s.NEXTVAL
        INTO l_sq_img_id
        FROM dual;
*/
	INSERT INTO bsc_sys_images(
            IMAGE_ID, FILE_NAME, DESCRIPTION, FILE_BODY, WIDTH, HEIGHT,
      	    CREATION_DATE, CREATED_BY,
	    LAST_UPDATE_DATE,  LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN)
	VALUES (
	    bsc_sys_image_id_s.NEXTVAL,
            p_graph_key, p_graph_key, empty_blob(), l_w, l_h,
	    SYSDATE, p_user_id,
	    SYSDATE, p_user_id,
	    p_user_id)
        RETURNING IMAGE_ID INTO p_img_id;

        IF SQL%ROWCOUNT = 0 THEN
           l_errmesg := 'Error inserting into bsc_sys_images. FILE_NAME=' ||
                        p_graph_key;
           RAISE insert_err;
        END IF;


	INSERT INTO bsc_kpi_graphs(
            RESPONSIBILITY_ID, INDICATOR, GRAPH_KEY, IMAGE_ID,
            CREATION_DATE, CREATED_BY,
            LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN)
        VALUES(
            p_resp_id, p_kpi_id, p_graph_key, p_img_id,
	    SYSDATE, p_user_id,
	    SYSDATE, p_user_id, p_user_id);

        IF SQL%ROWCOUNT = 0 THEN
           l_errmesg := 'Error inserting into bsc_kpi_graphs. RESPONSIBILITY_ID='|| p_resp_id || ', INDICATOR=' || p_kpi_id || ', GRAPH_KEY=' ||
		p_graph_key || ', IMAGE_ID' || p_img_id;
           RAISE insert_err;
        END IF;





     END IF;  -- c_kg%FOUND

     ----------------------------
     -- success if it goes here.
     ----------------------------
     COMMIT;
     CLOSE c_kg;
     p_o_ret_status := bsc_portlet_util.CODE_RET_SUCCESS;
     RETURN bsc_portlet_util.MSGTXT_SUCCESS;


EXCEPTION

    WHEN insert_err THEN
        ROLLBACK;
        CLOSE c_kg;
        p_o_ret_status := bsc_portlet_util.CODE_RET_ERROR;
	RETURN l_errmesg;


    WHEN update_err THEN
        ROLLBACK;
        CLOSE c_kg;
        p_o_ret_status := bsc_portlet_util.CODE_RET_ERROR;
	RETURN l_errmesg;

    WHEN OTHERS THEN
        ROLLBACK;
        CLOSE c_kg;
        p_o_ret_status := bsc_portlet_util.CODE_RET_ERROR;
	RETURN l_errmesg;



END save_graphkey;









END bsc_portlet_graph;

/
