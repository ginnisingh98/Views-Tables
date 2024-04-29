--------------------------------------------------------
--  DDL for Package Body POS_ACK_SEARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ACK_SEARCH" AS
/* $Header: POSASRCB.pls 115.24 2001/12/05 15:27:19 pkm ship      $ */

PROCEDURE veera_debug(p_debug_string	VARCHAR2)
IS
BEGIN
--	insert into veera_debug values(p_debug_string);
--	commit;
null;
END veera_debug;

PROCEDURE SEARCH_PO (
		pk1	IN	varchar2 default null,
		pk2	IN	varchar2 default null,
		pk3	IN	varchar2 default null,
		pk4	IN	varchar2 default null,
		pk5	IN	varchar2 default null,
		pk6	IN	varchar2 default null,
		pk7	IN	varchar2 default null,
		pk8	IN	varchar2 default null,
		pk9	IN	varchar2 default null,
		pk10	IN	varchar2 default null,
		c_outputs1	OUT varchar2,
		c_outputs2	OUT varchar2,
		c_outputs3	OUT varchar2,
		c_outputs4	OUT varchar2,
		c_outputs5	OUT varchar2,
		c_outputs6	OUT varchar2,
		c_outputs7	OUT varchar2,
		c_outputs8	OUT varchar2,
		c_outputs9	OUT varchar2,
		c_outputs10	OUT varchar2
	)
IS
  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;
  l_responsibility_id  NUMBER;

  l_po_number	varchar2(20);
  l_supplier_contact  number;
  l_title_message VARCHAR2(240);
BEGIN
  Veera_Debug('Start Search_PO');
  Veera_Debug('Pk1: ' || pk1 || ', Pk2: ' || pk2);
  Veera_Debug('Pk1: ' || pk1 || ', Pk2: ' || pk2);

  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

  select org_id into l_org_id
  from po_headers_all where po_header_id = to_number(pk1);

  update icx_sessions
  set org_id = l_org_id
  where session_id = l_session_id;
  commit;

  select segment1 into l_po_number
  from po_headers_all
  where po_header_id = to_number(pk1);

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  g_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

  l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
  g_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);

  l_supplier_contact := Get_Supplier_ID(l_user_id);

  fnd_client_info.set_org_context(l_org_id);
  fnd_global.apps_initialize(l_user_id, l_responsibility_id, 178);

  veera_debug('Script Name: ' || l_script_name || ' Org Id: ' || to_char(l_org_id) || 'User Id: ' || to_char(l_user_id) || 'Resp ID: ' || to_char(l_responsibility_id) || 'Session Id: ' || to_char(l_session_id));

  htp.htmlOpen;


  htp.title(fnd_message.get_string('ICX','ICX_POS_ACK_ENTER_ACK'));

  l_title_message := fnd_message.get_string('ICX','ICX_POS_ACK_ENTER_ACK');

  htp.headOpen;
    icx_util.copyright;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

    js.scriptOpen;
    	pos_global_vars_sv.InitializeMessageArray;
    	pos_global_vars_sv.InitializeOtherVars(l_script_name);
    	icx_util.LOVscript;
    js.scriptClose;

  htp.p('  <script src="/OA_HTML/POSCUTIL.js" language="JavaScript">');
  htp.p('  </script>');
  htp.p('  <script src="/OA_HTML/POSWUTIL.js" language="JavaScript">');
  htp.p('  </script>');
  htp.p('  <script src="/OA_HTML/POSEVENT.js" language="JavaScript">');
  htp.p('  </script>');
  htp.p('  <script src="/OA_HTML/POSACKEJ.js" language="JavaScript">');
  htp.p('  </script>');
  htp.p('<script Language=JavaScript>');
htp.p('top.t.renderQueue[top.t.toolbarHash["title"]]= new top.Title("' || l_title_message || '")');
htp.p('top.header.location.reload()');
  htp.p('</script>');
  htp.headClose;


    		-- blue border frame

  htp.p('
	   <FRAMESET ROWS=" 6%, 28%, 9%, 49%, 7%, 1%" BORDER=0>

                         <FRAME SRC="' || l_script_name || '/POS_ACK_SEARCH.FIXED_FRAME?l_supplier_contact=' || l_supplier_contact || '" ' ||
                        ' NAME="fixedframe" MARGINWIDTH="0" MARGINHEIGHT="0" frameborder=no SCROLLING=NO>

  					<FRAME SRC="' || l_script_name || '/POS_ACK_SEARCH.CRITERIA_FRAME?l_po_number=' || l_po_number || '"' ||
  						' NAME="criteria" MARGINWIDTH="0" MARGINHEIGHT="0" NORESIZE FRAMEBORDER=NO SCROLLING=NO>


					<FRAME SRC="' || l_script_name || '/POS_ACK_SEARCH.COUNTER_FRAME"
						NAME="counter" MARGINWIDTH="0" MARGINHEIGHT="0" SCROLLING=NO NORESIZE FRAMEBORDER=NO>

					<FRAME SRC="' || l_script_name || '/POS_ACK_SEARCH.BLANK_FRAME"
						NAME="result" MARGINWIDTH="5" MARGINHEIGHT="0" NORESIZE FRAMEBORDER=NO>

					<FRAME SRC="' || l_script_name || '/POS_ACK_SEARCH.ADD_FRAME"
						NAME="add" MARGINWIDTH="5" MARGINHEIGHT="5" SCROLLING=NO NORESIZE FRAMEBORDER=NO>
					<FRAME SRC="' || l_script_name || '/pos_lower_banner_sv.PaintLowerBanner"
						NAME="lowerbanner" MARGINWIDTH="0" MARGINHEIGHT="0" SCROLLING=NO NORESIZE FRAMEBORDER=NO>

				</FRAMESET>

  				');
    		-- blue border frame

  			htp.p('</FRAMESET>');

			htp.htmlClose;

	Veera_Debug('End Search_PO');


END SEARCH_PO;

PROCEDURE SEARCH_PO2(p_resp_id	IN	VARCHAR2 DEFAULT null) IS

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;
  l_responsibility_id  NUMBER;
  l_supplier_contact  number;
  l_mo_profile_defined	BOOLEAN;
BEGIN

  POS_INIT_SESSION_PKG.InitSession(p_resp_id);

  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  g_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

  g_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
  l_supplier_contact := Get_Supplier_ID(l_user_id);

  htp.htmlOpen;
  htp.title(fnd_message.get_string('ICX','ICX_POS_ACK_ENTER_ACK'));

  htp.headOpen;
    icx_util.copyright;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

    js.scriptOpen;
    	pos_global_vars_sv.InitializeMessageArray;
    	pos_global_vars_sv.InitializeOtherVars(l_script_name);
    	icx_util.LOVscript;
    js.scriptClose;

  htp.p('  <script src="/OA_HTML/POSCUTIL.js" language="JavaScript">');
  htp.p('  </script>');
  htp.p('  <script src="/OA_HTML/POSWUTIL.js" language="JavaScript">');
  htp.p('  </script>');
  htp.p('  <script src="/OA_HTML/POSEVENT.js" language="JavaScript">');
  htp.p('  </script>');
  htp.p('  <script src="/OA_HTML/POSACKEJ.js" language="JavaScript">');
  htp.p('  </script>');
  htp.headClose;

  htp.p('
	<FRAMESET rows="10%, 80%, 10%" border=0 framespacing=0>
	   ');
		--toolbar
		htp.p('
		<FRAME SRC="' || l_script_name || '/pos_toolbar_sv.PaintToolBar?p_title=ICX_POS_ACK_ENTER_ACK"
			NAME="toolbar" MARGINWIDTH="0" MARGINHEIGHT="0" frameborder=no SCROLLING=NO>
		<FRAMESET cols="3, *, 3" border=0 framespacing=0>
			');

    		-- blue border frame
    		htp.p('<FRAME src="/OA_HTML/US/POSBLBOR.htm"
                     name=borderLeft
                     marginwidth=0
                     frameborder=no
                     scrolling=no>');
  			htp.p('
				<FRAMESET ROWS="5%, 6%, 28%, 9%, 44%, 7%, 1%" BORDER=0>
  					<FRAME SRC="' || l_script_name || '/pos_upper_banner_sv.PaintUpperBanner?p_product=ICX&p_title=ICX_POS_ACK_SELECT"
  						NAME="upperbanner" MARGINWIDTH="0" MARGINHEIGHT="0" frameborder=no SCROLLING=NO>


                       <FRAME SRC="' || l_script_name || '/POS_ACK_SEARCH.FIXED_FRAME?l_supplier_contact=' || l_supplier_contact || '" ' ||
                        ' NAME="fixedframe" MARGINWIDTH="0" MARGINHEIGHT="0" frameborder=no SCROLLING=NO>

  					<FRAME SRC="' || l_script_name || '/POS_ACK_SEARCH.CRITERIA_FRAME"
  						NAME="criteria" MARGINWIDTH="0" MARGINHEIGHT="0" NORESIZE FRAMEBORDER=NO SCROLLING=NO>


					<FRAME SRC="' || l_script_name || '/POS_ACK_SEARCH.COUNTER_FRAME"
						NAME="counter" MARGINWIDTH="0" MARGINHEIGHT="0" SCROLLING=NO NORESIZE FRAMEBORDER=NO>

					<FRAME SRC="' || l_script_name || '/POS_ACK_SEARCH.BLANK_FRAME"
						NAME="result" MARGINWIDTH="5" MARGINHEIGHT="0" NORESIZE FRAMEBORDER=NO>

					<FRAME SRC="' || l_script_name || '/POS_ACK_SEARCH.ADD_FRAME"
						NAME="add" MARGINWIDTH="5" MARGINHEIGHT="5" SCROLLING=NO NORESIZE FRAMEBORDER=NO>
					<FRAME SRC="' || l_script_name || '/pos_lower_banner_sv.PaintLowerBanner"
						NAME="lowerbanner" MARGINWIDTH="0" MARGINHEIGHT="0" SCROLLING=NO NORESIZE FRAMEBORDER=NO>

				</FRAMESET>

  				');
    		-- blue border frame
  			htp.p('<FRAME src="/OA_HTML/US/POSBLBOR.htm"
                     name=borderRight
                     marginwidth=0
                     frameborder=no
                     scrolling=no>');

  			htp.p('</FRAMESET>');

        htp.p('<FRAME src="/OA_HTML/US/POSBLBOR.htm"
                     name=borderBottom
                     marginwidth=0
                     frameborder=no
                     scrolling=no>');

   htp.p('</FRAMESET>');



  htp.htmlClose;

	Veera_Debug('End Search_PO');

END SEARCH_PO2;

PROCEDURE CRITERIA_FRAME
(
	p_advance_flag	IN	VARCHAR2  DEFAULT 'N',
	l_po_number	IN	VARCHAR2  DEFAULT null
)
IS

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;
  l_responsibility_id  NUMBER;

  l_supplier_id NUMBER;
  l_advance_flag VARCHAR2(1);

BEGIN

  Veera_Debug('Start Criteria_Frame');
  Veera_Debug('Po Number ' || l_po_number);
  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
  l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);

  veera_debug('Org Id: ' || to_char(l_org_id) || 'User Id: ' ||
	to_char(l_user_id) || 'Resp ID: ' || to_char(l_responsibility_id) ||
	'Session Id: ' || to_char(l_session_id));

  l_supplier_id := Get_Supplier_ID(l_user_id);
  veera_debug('Supplier Id: ' || to_char(l_supplier_id));

  htp.htmlOpen;
  htp.headOpen;

    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');
  	js.scriptOpen;
  	icx_util.LOVscript;
    htp.p('
		function call_LOV(c_attribute_code)
		{
  			var c_where_clause = "";
			c_where_clause = escape(c_where_clause, 1);

    		LOV("178", c_attribute_code, "178", "POS_ACK_SEARCH_R",
					"POS_ACK_SEARCH", "criteria", "", c_where_clause);
	  }


	  function clearsearchfields()
	  {
	    document.POS_ACK_SEARCH.POS_ACK_SUPPLIER_SITE.value="";
	    document.POS_ACK_SEARCH.POS_ACK_SR_SUPPLIER_SITE_ID.value="";
            document.POS_ACK_SEARCH.POS_ACK_SR_PO_NUMBER.value="";
	    document.POS_ACK_SEARCH.POS_ACK_SR_DOC_TYPE.value="";
            document.POS_ACK_SEARCH.POS_ACK_SR_ACC_REQD_START_DATE.value="";
            document.POS_ACK_SEARCH.POS_ACK_SR_ACC_REQD_END_DATE.value="";
          }

  	');

  	js.scriptClose;

  htp.headClose;

  htp.p('<body bgcolor=#cccccc>');
  -- If the frame is basic search, the switch will be advance search.  Vice Versa

  if P_advance_flag = 'Y' then
    l_advance_flag := 'N';
  else
    l_advance_flag := 'Y';
  end if;

  /* if the supplier is not set up for the user dont paint the search fields. instead
   show a message */
 IF l_supplier_id <> -1 THEN
  htp.p('<FORM NAME="POS_ACK_SEARCH" ACTION="'||l_script_name||'/POS_ACK_SEARCH.RESULT_POS" TARGET="result" METHOD="POST">');

  htp.p('<INPUT NAME="p_advance_flag" TYPE="HIDDEN" VALUE="' || l_advance_flag || '">');

  Paint_Search_Fields(p_advance_flag => p_advance_flag,
			l_po_number => l_po_number);

  htp.p('</FORM>');

  ELSE
  htp.p('<table width=100% bgcolor=#CCCCCC cellpadding=0 cellspacing=0 border=0>');
  htp.p('<TABLE)<TR><TD VALIGN=CENTER ALIGN=LEFT BGCOLOR=#CCCCCC ><FONT CLASS=helptext>&nbsp;' ||
              fnd_message.get_string('ICX','ICX_POS_SUPP_NO_ACCESS') || '</FONT></TD></TR>');
  htp.p('</TABLE>');
 END IF;

  if l_po_number is not null then
	veera_debug('criteria_frame: po number not null');
  	htp.p('<script Language=JavaScript>');
  	htp.p('document.POS_ACK_SEARCH.submit();  ');
  	htp.p('</script>');
  end if;

  htp.bodyClose;
  htp.htmlClose;

  Veera_Debug('End Criteria_Frame');
END CRITERIA_FRAME;

PROCEDURE FIXED_FRAME(l_supplier_contact  in number)
IS
BEGIN

   IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  htp.htmlopen;
  htp.headOpen;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');
  htp.headClose;
  htp.bodyOpen;
  htp.p('<body bgcolor=#cccccc>');

  htp.p('<table width=100% bgcolor=#CCCCCC cellpadding=0 cellspacing=0 border=0>');

 /* if the supplier is not set up for the user dont show the enter criteria message. instead
    clear the frame so that a message is shown in the criteris frame */
  if l_supplier_contact <> -1 then
-- Row with 'Enter Criteria ; * means required field
      htp.p('<TR><TD VALIGN=CENTER ALIGN=LEFT BGCOLOR=#CCCCCC NOWRAP><FONT CLASS=helptext>&nbsp;' ||
        fnd_message.get_string('ICX','ICX_POS_ACK_ENTER_CRITERIA') || '</FONT></TD></TR>');

  else
     htp.p('<TR><TD VALIGN=CENTER ALIGN=LEFT BGCOLOR=#CCCCCC NOWRAP><FONT CLASS=helptext>&nbsp;' ||
        '</FONT></TD></TR>');
  end if;

  htp.p('</TABLE>');

  htp.bodyClose;
  htp.htmlClose;
END FIXED_FRAME;

PROCEDURE COUNTER_FRAME (
						p_first		IN	NUMBER DEFAULT 0,
						p_last		IN	NUMBER DEFAULT 0,
						p_total		IN	NUMBER DEFAULT 0
						)
IS

  l_msg         VARCHAR2(2000);

BEGIN

   IF NOT icx_sec.validatesession THEN
    RETURN;
   END IF;

  htp.htmlopen;
  htp.headOpen;
  	htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');
  htp.headClose;
  htp.bodyOpen;
  htp.p('<body bgcolor=#cccccc>');
  htp.p('<hr size=1 noshade width=100%>');
  if p_total > 0 then
    l_msg := fnd_message.get_string('ICX','ICX_POS_ACK_PO_COUNTER');

    l_msg := replace(l_msg, '&TOTAL', to_char(p_total));
    l_msg := replace(l_msg, '&FROM', to_char(p_first));
    l_msg := replace(l_msg, '&TO', to_char(p_last));

    --htp.p(l_msg);

	htp.p('<table width=100% cellspacing=0 cellpadding=0 border=0>
			<tr>
			<td valign=middle align=left bgcolor=#cccccc nowrap>
				<font class=helptext>' ||
				fnd_message.get_string('ICX', 'ICX_POS_ACK_SELECT_RESULT') ||
				'</font> </td>
			<td valign=middle align=right bgcolor=#cccccc nowrap>
				<font class=promptblack>' ||
				l_msg ||
				'</font> </td> </tr> </table>'
		);

  end if;
  htp.bodyClose;
  htp.htmlClose;
END COUNTER_FRAME;

PROCEDURE BLANK_FRAME (
						l_called_from	IN	NUMBER DEFAULT 0,
						l_rows_inserted	IN	NUMBER	DEFAULT 0
					)
IS
  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_msg			VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;
  l_responsibility_id  NUMBER;
BEGIN

   IF NOT icx_sec.validatesession THEN
    RETURN;
   END IF;

  veera_debug('Start Blank_Frame');
  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
  l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);

  veera_debug('Org Id: ' || to_char(l_org_id) || 'User Id: ' ||
	to_char(l_user_id) || 'Resp ID: ' || to_char(l_responsibility_id) ||
	'Session Id: ' || to_char(l_session_id));

  htp.htmlOpen;
  htp.headOpen;
  	js.scriptOpen;
  	icx_util.LOVscript;
	htp.p('

	      function openDlg(l_rows) {
	      var winWidth = 400;
	      var winHeight = 200;
	      var winAttributes = "menubar=no,location=no,toolbar=no," +
                      "width=" + winWidth + ",height=" + winHeight +
                      ",screenX=" + (screen.width - winWidth)/2 +
                      ",screenY=" + (screen.height - winHeight)/2 +
                      ",resizable=yes,scrollbars=yes";
	       var url = parent.scriptName + "/pos_ack_window_util.dialogbox?" + "l_rows=" + l_rows;
	       open(url, "Cancel",winAttributes);
	      }

		function SubmitDlg(p_start, p_end, p_total, p_rows_inserted, p_string)
		{
			var l_URL = parent.scriptName + "/POS_ACK_SEARCH.COUNTER_FRAME?" +
                                "p_first=" + p_start +
                                "&p_last=" + p_end +
                                "&p_total=" + p_total;

	               parent.counter.location.href = l_URL;

			var l_URL2 = parent.scriptName + "/POS_ACK_SEARCH.ADD_FRAME?" +
                		"p_total=" + p_total;

			parent.add.location.href = l_URL2;

			openDlg(p_rows_inserted);
		}
	');
  	js.scriptClose;
  htp.headClose;
  htp.bodyOpen;
  if l_called_from <> 0 then
    l_msg := fnd_message.get_string('ICX','ICX_POS_ACK_TOTAL_PO_SUB');

    l_msg := replace(l_msg, '&TOTAL', to_char(l_rows_inserted));
  	htp.p('<body bgcolor=#cccccc onload="javascript:SubmitDlg(0,0,0,' ||
		to_char(l_rows_inserted) || ', ''' || l_msg || ''')">');
  else
  	htp.p('<body bgcolor=#cccccc >');
  end if;
  htp.bodyClose;
  htp.htmlClose;
  veera_debug('End Blank_Frame');
END BLANK_FRAME;

PROCEDURE ADD_FRAME (
					p_total		IN	NUMBER	default 0
					)
IS

  l_msg         VARCHAR2(2000);

BEGIN

   -- Bug 1785297 mji
  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  htp.htmlOpen;
  htp.headOpen;
  htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');
  htp.headClose;
  htp.bodyOpen;

   -- Bug 1785297 mji
  l_msg := fnd_message.get_string('ICX', 'ICX_POS_ACK_SUBMIT');

  htp.p('<script Language=JavaScript>

	function cancelClicked() {
	      var winWidth = 400;
	      var winHeight = 200;
	      var winAttributes = "menubar=no,location=no,toolbar=no," +
                      "width=" + winWidth + ",height=" + winHeight +
                      ",screenX=" + (screen.width - winWidth)/2 +
                      ",screenY=" + (screen.height - winHeight)/2 +
                      ",resizable=yes,scrollbars=yes";
	       var url = parent.scriptName + "/pos_ack_window_util.dialogbox?";
	       open(url, "Cancel",winAttributes);
	      }

     function NextSet()
     {
		if (top.criteria.document.POS_ACK_SEARCH.POS_ACK_SR_ROW_NUM.value== "0")
		{
			top.criteria.document.POS_ACK_SEARCH.POS_ACK_SR_ROW_NUM.value =
			top.criteria.document.POS_ACK_SEARCH.POS_ACK_SR_ROW_NUM.value - (-26)
		}
		else
		{
			top.criteria.document.POS_ACK_SEARCH.POS_ACK_SR_ROW_NUM.value =
			top.criteria.document.POS_ACK_SEARCH.POS_ACK_SR_ROW_NUM.value - (-25)
		}
        top.criteria.document.POS_ACK_SEARCH.submit();
     }

     function PreviousSet()
     {
		if (top.criteria.document.POS_ACK_SEARCH.POS_ACK_SR_ROW_NUM.value != "0" || top.criteria.document.POS_ACK_SEARCH.POS_ACK_SR_ROW_NUM.value != "1")
		{
			top.criteria.document.POS_ACK_SEARCH.POS_ACK_SR_ROW_NUM.value =
			top.criteria.document.POS_ACK_SEARCH.POS_ACK_SR_ROW_NUM.value  - 25;
		}
        	top.criteria.document.POS_ACK_SEARCH.submit();
		}


		function SubmitAcknowledge()
                {
		  var temp1 = confirm(''' || l_msg || ''');
		  if (temp1 == true)
		    parent.frames["result"].document.forms["POS_EDIT_POS"].submit();
		}
	 </script>
	');
  htp.p('<body bgcolor=#cccccc>');

  if p_total > 0 then

  	button('javascript:SubmitAcknowledge()',
        fnd_message.get_string('ICX', 'ICX_POS_SUBMIT'),
        'javascript:cancelClicked()',
        --'javascript:top.submitDlg()',
        fnd_message.get_string('ICX', 'ICX_POS_BTN_CANCEL'));

  end if;

  htp.bodyClose;
  htp.htmlClose;
END ADD_FRAME;

FUNCTION GET_SUPPLIER_ID
(
	p_user_id IN NUMBER
)	RETURN NUMBER

IS

  l_supplier_id NUMBER;

BEGIN

  select vs.vendor_id
    into l_supplier_id
    from po_vendor_sites     vs,
         po_vendor_contacts  vc,
         fnd_user            fu
   where fu.user_id = p_user_id
     and fu.supplier_id = vc.vendor_contact_id
     and vc.vendor_site_id = vs.vendor_site_id;

  return(l_supplier_id);
EXCEPTION
 WHEN NO_DATA_FOUND THEN
     l_supplier_id := -1;
     return(l_supplier_id);
END GET_SUPPLIER_ID;


PROCEDURE Paint_Search_Fields
(
	p_advance_flag	IN	VARCHAR2,
	l_po_number	IN	VARCHAR2  DEFAULT null
)
IS
  l_attribute_index  NUMBER;
  l_result_index     NUMBER;
  l_current_col      NUMBER;
  l_current_row      NUMBER;
  l_row		     NUMBER := 0;
  l_session_id NUMBER := icx_sec.getID(icx_sec.PV_SESSION_ID);
  l_where_clause     VARCHAR2(2000) := '';
BEGIN
   Veera_Debug('Paint_Search: Po Number: ' || l_po_number);
   htp.p('<table width=100% cellpadding=0 cellspacing=0 border=0>');

   htp.p('<!-- This row contains the help text -->');
   htp.p('<tr bgcolor=#cccccc>');
   htp.p('<td valign=top>' ||
         '<font class=helptext>&nbsp;' ||
         ' ' ||
         '</font></td>');
   htp.p('</tr>');
   htp.p('</table>');

   ak_query_pkg.exec_query(p_parent_region_appl_id   =>  178,
                          p_parent_region_code      =>  'POS_ACK_SEARCH_R',
                          p_where_clause            =>  l_where_clause,
                          p_responsibility_id       =>  icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID),
                          p_user_id                 =>  icx_sec.getID(icx_sec.PV_WEB_USER_ID),
                          p_return_parents          =>  'F',
                          p_return_children         =>  'F');

   l_attribute_index := ak_query_pkg.g_items_table.FIRST;
   l_result_index    := ak_query_pkg.g_results_table.FIRST;

   htp.p('<table width=100% cellpadding=0 cellspacing=0 border=0>');

   htp.p('<tr cellspacing=5 bgcolor=#cccccc>');

   l_current_col := 0;

   WHILE (l_attribute_index IS NOT NULL) LOOP

     l_current_col := l_current_col + 1;

    IF (item_style(l_attribute_index) = 'HIDDEN') THEN
       htp.p('<!-- ' || item_code(l_attribute_index) ||
             ' - '   || item_style(l_attribute_index) || ' -->');
	   IF item_code(l_attribute_index) = 'POS_ACK_SR_ROW_NUM' then
            htp.p('<input name="' || item_code(l_attribute_index) ||
             '" type="HIDDEN" VALUE="' ||
               '0'|| '">');
	   ELSIF item_code(l_attribute_index) = 'POS_ACK_SR_ACC_STATUS' then
            htp.p('<input name="' || item_code(l_attribute_index) ||
             '" type="HIDDEN" VALUE="' ||
               'None'|| '">');
	   ELSE
       		htp.p('<input name="' || item_code(l_attribute_index) ||
             '" type="HIDDEN" VALUE="' ||
               get_result_value(l_result_index, l_current_col) ||
             '">');
	   END IF;
    ELSIF item_displayed(l_attribute_index)  THEN
		IF (item_style(l_attribute_index) = 'TEXT') THEN
			IF item_updateable(l_attribute_index) THEN
				htp.p('<td nowrap bgcolor=#cccccc' || item_halign(l_attribute_index) ||
					item_valign(l_attribute_index) || ' WIDTH=30% ' || '>' ||
					item_reqd(l_attribute_index) || '<font class=promptblack>'
					|| item_name(l_attribute_index) || ' ' || '</font>' ||
                    '&nbsp;</td>');

				IF item_code(l_attribute_index) = 'POS_ACK_SR_PO_NUMBER' THEN
				veera_debug('Inside if of pos_ack_sr_po_number');
				htp.p('<td nowrap ' || ' VALIGN=MIDDLE ALIGN=LEFT '||
					 '>' || '<B><font class=datablack>'||
					'<input type=text size=12 name="' ||
					item_code(l_attribute_index) || '"' || ' value="' ||
					nvl(l_po_number, '') ||
					'" ></font></B>');
				else
				veera_debug('Inside else of pos_ack_sr_po_number');
				htp.p('<td nowrap ' || ' VALIGN=MIDDLE ALIGN=LEFT '||
					 '>' || '<B><font class=datablack>'||
					'<input type=text size=12 name="' ||
					item_code(l_attribute_index) || '"' || ' value="' ||
					nvl(get_result_value(l_result_index, l_current_col), '') ||
					'" ></font></B>');
				end if;
	        	IF (ak_query_pkg.g_items_table(l_attribute_index).lov_region_code IS NOT NULL AND ak_query_pkg.g_items_table(l_attribute_index).lov_attribute_code IS NOT NULL) THEN
	            	htp.p('<A HREF="javascript:call_LOV('''||
						ak_query_pkg.g_items_table(l_attribute_index).attribute_code ||
						''')"' || '><IMG SRC="/OA_MEDIA/FNDLSTOV.gif"
						BORDER=0 WIDTH=23 HEIGHT=21 border=no align=absmiddle>
						</A>');
        		END IF;
				IF item_code(l_attribute_index) = 'POS_ACK_SR_ACC_REQD_START_DATE' THEN
					l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);
					l_current_col := l_current_col + 1;
					htp.p('<FONT CLASS=promptblack>' ||
						ak_query_pkg.g_items_table(l_attribute_index).attribute_label_long ||
						'</FONT>&nbsp;<FONT CLASS=datablack>');
					htp.p('<INPUT NAME="'||
						ak_query_pkg.g_items_table(l_attribute_index).attribute_code ||
						'" TYPE="text"' || ' VALUE="" SIZE=12'||
						' MAXLENGTH='||
						ak_query_pkg.g_items_table(l_attribute_index).attribute_value_length||
						'></FONT>');
				END IF;
				htp.p('</td>');
			ELSE
				htp.p('<td nowrap bgcolor=#cccccc ' ||
					item_halign(l_attribute_index) ||
					item_valign(l_attribute_index) || ' WIDTH=175 ' || '>' ||
					'<font class=promptblack>' || item_name(l_attribute_index)
					|| '</font>' || '</td>');

				htp.p('<td ' || item_halign(l_attribute_index) ||
					item_valign(l_attribute_index) ||
					'>' || '<B><font class=tabledata>' ||
					nvl(get_result_value(l_result_index, l_current_col), '&nbs
p') ||
					'</font></B></td>');

			END IF;
		ELSIF (item_style(l_attribute_index) = 'POPLIST') THEN
			IF item_updateable(l_attribute_index) THEN
				htp.p('<td bgcolor=#cccccc' || item_halign(l_attribute_index) ||
					item_valign(l_attribute_index) || ' WIDTH=30% ' || '>' ||
					'<font class=promptblack>' || item_name(l_attribute_index)
					|| ' ' || '</font>' || '</td>');

				htp.p('<td nowrap ' ||  ' VALIGN=MIDDLE ALIGN=LEFT '||
					' WIDTH=350 ' || '>' || '<B><font class=datablack>'||
					'<select name="' || item_code(l_attribute_index) || '">' ||
					get_option_string(l_attribute_index) ||
					'</select> </font></B></td>');
            ELSE
				htp.p('<td bgcolor=#cccccc ' ||
					item_halign(l_attribute_index) ||
					item_valign(l_attribute_index) || ' WIDTH=175 ' || '>' ||
					'<font class=promptblack>' || item_name(l_attribute_index)
					|| '</font>' || '</td>');
				htp.p('<td ' || item_halign(l_attribute_index) ||
					item_valign(l_attribute_index) || ' WIDTH=350 ' || '>' ||
					'<B><font class=tabledata>' ||
					nvl(get_result_value(l_result_index, l_current_col), '&nbsp') ||
				'</font></B></td>');
			END IF;
        ELSIF (item_style(l_attribute_index) = 'IMAGE') THEN
			null;
		END IF;
      END IF;
    l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);

    if ((l_current_col mod 1) = 0) THEN
		l_row := l_row + 1;
	 	IF l_row = 1 THEN
        	htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT WIDTH=100 BGCOLOR=#CCCCCC>');

        	--button('javascript:top.SearchPOs()', fnd_message.get_string('ICX', 'ICX_POS_SEARCH'));
		button('javascript:document.POS_ACK_SEARCH.submit(); ', fnd_message.get_string('ICX', 'ICX_POS_SEARCH'));

          htp.p('</TD>');
          htp.p('<TD VALIGN=MIDDLE ALIGN=LEFT WIDTH=100 BGCOLOR=#CCCCCC>');

          button('javascript:clearsearchfields()', fnd_message.get_string('ICX', 'ICX_POS_CLEAR'));

          htp.p('</TD>');


	 	END IF;
        htp.p('</tr>');
        htp.p('<tr bgcolor=#cccccc>');
    end if;

   END LOOP;

   htp.p('</tr>');
   htp.p('</table>');

END Paint_Search_Fields;

PROCEDURE RESULT_POS
(
	p_advance_flag			        IN	VARCHAR2    DEFAULT 'N',
	pos_ack_sr_acc_status			IN	VARCHAR2    DEFAULT null,
	pos_ack_sr_acc_reqd			IN	VARCHAR2    DEFAULT null,
	pos_ack_sr_acc_reqd_start_date   	IN	VARCHAR2    DEFAULT null,
	pos_ack_sr_acc_reqd_end_date	        IN	VARCHAR2    DEFAULT null,
	pos_ack_sr_po_number			IN	VARCHAR2    DEFAULT null,
	pos_ack_sr_supplier_site_id		IN	VARCHAR2    DEFAULT null,
	pos_ack_supplier_site			IN	VARCHAR2    DEFAULT null,
        pos_ack_sr_doc_type                     IN      VARCHAR2    DEFAULT null,
	pos_ack_sr_row_num			IN	VARCHAR2    DEFAULT null
)
IS
  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;
  l_responsibility_id  NUMBER;
  l_start_row	NUMBER;
  l_end_row		NUMBER;
  l_count		NUMBER;
BEGIN

  veera_debug('Start Result_POS');

/*Bug:1688799
  Bcos the session was not validated, the org context was not set
  appropriately and hence the query returned no rows.
*/

  IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

 /* bug 1361618 :  setting the org context */
     fnd_client_info.set_org_context(l_org_id);
     fnd_global.apps_initialize(l_user_id, l_responsibility_id, 178);

     select responsibility_id into g_responsibility_id from ICX_SESSIONS
     WHERE session_id = l_session_id;
     select user_id into g_user_id from ICX_SESSIONS
     WHERE session_id = l_session_id;
  veera_debug('RESULT_PO: Org Id: ' || to_char(l_org_id) || 'User Id: ' ||
	to_char(g_user_id) || 'Resp ID: ' || to_char(g_responsibility_id) ||
	'Session Id: ' || to_char(l_session_id));

  if to_number(pos_ack_sr_row_num) = 0 then
	begin
		Find_Matching_Rows (
						l_Acceptance_Status => pos_ack_sr_acc_status,
						l_Acceptance_Reqd_Flag => pos_ack_sr_acc_reqd,
						l_Start_Date => pos_ack_sr_acc_reqd_start_date,
						l_End_Date => pos_ack_sr_acc_reqd_end_date,
						l_PO_Number => pos_ack_sr_po_number,
						l_Supplier_Site_Id => pos_ack_sr_supplier_site_id,
						l_Document_Type_Code => pos_ack_sr_doc_type
					 );
	exception
		when others then
			delete from pos_ack_select;
	end;
	l_start_row := 1;
	l_end_row := 99999;
	--l_end_row := 25;
  else
	l_start_row := to_number(pos_ack_sr_row_num);
	l_end_row := l_start_row + 25 -1;
  end if;

  htp.htmlOpen;
-- Header Start

  htp.headOpen;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');
    js.scriptOpen;
    icx_util.LOVscript;
    htp.p('

		function LoadCounter(p_start, p_end, p_total)
		{
			var l_URL = parent.scriptName + "/POS_ACK_SEARCH.COUNTER_FRAME?" +
				"p_first=" + p_start +
				"&p_last=" + p_end +
				"&p_total=" + p_total;
				/*
				"&p_total=" + result.document.POS_ACK_TEMP.POS_ACK_ACC_TOTAL_ROWS.value;
				*/

  			parent.counter.location.href = l_URL;

            	var l_URL2 = parent.scriptName + "/POS_ACK_SEARCH.ADD_FRAME?" +
                "p_total=" + p_total;

  			parent.add.location.href = l_URL2;

		}

			var acc_type;
			var acc_type_code;
			var r_row;
			var r_attribute_code;
			var intervalID;

		function call_LOV(c_attribute_code, c_row, l_script)
		{
  			var c_js_where_clause = "";
  			var interval = 100;

  			if (c_attribute_code == "POS_ACK_ACC_TYPE")
   			{
    			if (document.POS_EDIT_POS.POS_ACK_ACC_TYPE[c_row] == null)
     			{
       				acc_type = document.POS_EDIT_POS.POS_ACK_ACC_TYPE;
       				acc_type_code = document.POS_EDIT_POS.POS_ACK_ACC_TYPE_CODE;
     			}
    			else
     			{
       				acc_type = document.POS_EDIT_POS.POS_ACK_ACC_TYPE[c_row];
       				acc_type_code = document.POS_EDIT_POS.POS_ACK_ACC_TYPE_CODE[c_row];
     			}

    			document.POS_ACK_TEMP.POS_ACK_ACC_TYPE.value = acc_type.value;
    			document.POS_ACK_TEMP.POS_ACK_ACC_TYPE_CODE.value = acc_type_code.value;
   			}

  			r_row = c_row;
  			r_attribute_code = c_attribute_code;

  			c_js_where_clause = escape(c_js_where_clause, 1);

  			lov_win = window.open(l_script + "/icx_util.LOV?c_attribute_app_id=178" +
                         "&c_attribute_code=" + c_attribute_code +
                         "&c_region_app_id=178" +
                         "&c_region_code=POS_ACK_EDIT_R" +
                         "&c_form_name=POS_ACK_TEMP"  +
                         "&c_frame_name=result" +
                         "&c_where_clause=" +
                         "&c_js_where_clause=" + c_js_where_clause,"LOV",
                         "resizable=yes,menubar=yes,scrollbars=yes,width=780,height=300");


  			intervalID = window.setInterval("watchme()", interval);

			}

			  function changePromisedDate(resp_id,po_num)
			  {
			  var winWidth = 800;
			var winHeight = 600;
			var winAttributes = "menubar=no,location=no,toolbar=no," +
                      "width=" + winWidth + ",height=" + winHeight +
                      ",screenX=" + (screen.width - winWidth)/2 +
                      ",screenY=" + (screen.height - winHeight)/2 +
                      ",resizable=yes,scrollbars=yes";

			var scriptName = parent.scriptName;
			var url = scriptName + "/POS_UPD_DATE.SEARCH_PO?l_po_number="+ po_num +"&p_resp_id="+resp_id;
                        open(url, "test", winAttributes);
			}

		function watchme()
		{
  			if (lov_win.closed)
  			{
   				if (r_attribute_code == "POS_ACK_ACC_TYPE")
    			{
					acc_type.value = document.POS_ACK_TEMP.POS_ACK_ACC_TYPE.value;
					acc_type_code.value = document.POS_ACK_TEMP.POS_ACK_ACC_TYPE_CODE.value;
    			}
   				clearInterval(intervalID);
   				return;
  			}
		}


  	');
    js.scriptClose;
  htp.headClose;

-- Header End
/*
  select count(*) into  l_count
  from pos_ack_select;
*/
  ak_query_pkg.exec_query(p_parent_region_appl_id   =>  178,
                          p_parent_region_code      =>  'POS_ACK_EDIT_R',
                          p_where_clause            =>  '',
                          p_responsibility_id       =>  g_responsibility_id,
                          p_user_id                 =>  g_user_id,
                          p_return_parents          =>  'T',
                          p_return_children         =>  'F');
  l_count := ak_query_pkg.g_results_table.count;
  veera_debug('SearchPO: no of rows: ' || to_char(l_count));

  htp.p('<body bgcolor=#cccccc onLoad="javascript:LoadCounter(' ||
		'1, ' || to_char(l_count) || ',' || to_char(l_count) ||
		')">');


  if l_count > 0 then
  	htp.p('<form name="POS_ACK_TEMP">' ||
        '<input name="POS_ACK_ACC_TYPE" type="HIDDEN" VALUE="">' ||
        '<input name="POS_ACK_ACC_TYPE_CODE" type="HIDDEN" VALUE="">' ||
        '<input name="POS_ACK_ACC_TOTAL_ROWS" type="HIDDEN" VALUE="">' ||
        '</form>');
  	htp.p('<form name="POS_EDIT_POS" ACTION="' || l_script_name ||
        '/POS_ACK_SEARCH.ACKNOWLEDGE_POS" target="result" method="POST">');


  	veera_debug('Row num in result pos: ' || pos_ack_sr_row_num);
  	paint_edit_pos(to_number(pos_ack_sr_row_num));
  	htp.p('</form>');
  else
	htp.p('<B>');
	htp.p(fnd_message.get_string('ICX','ICX_POS_NO_RECORDS'));
	htp.p('</B>');
  end if;

  htp.p('</body>');
  htp.htmlClose;
END RESULT_POS;

PROCEDURE SHOW_POS(
					pos_ack_sr_row_num IN VARCHAR2 default '0',
					l_rows_inserted		IN NUMBER	default 0
					)
IS
	l_count	NUMBER	:= 0;
	l_script_name VARCHAR2(240);
	l_msg1		  VARCHAR2(240);
	l_msg2		  VARCHAR2(240);
BEGIN
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  htp.htmlOpen;

  htp.headOpen;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');
    js.scriptOpen;
    icx_util.LOVscript;
    htp.p('

		function call_LOV1(c_attribute_code)
		{
  			var c_where_clause = "";

    		LOV("178", c_attribute_code, "178", "POS_ACK_EDIT_R",
					"POS_EDIT_POS", "result", "", c_where_clause);
		}

		function LoadCounter(p_start, p_end, p_total, p_rows_inserted, p_string1, p_string2)
		{
			if (p_rows_inserted > 0)
				alert(p_string1);
			alert(p_string2);
			var l_URL = parent.scriptName + "/POS_ACK_SEARCH.COUNTER_FRAME?" +
				"p_first=" + p_start +
				"&p_last=" + p_end +
				"&p_total=" + p_total;

  			parent.counter.location.href = l_URL;

            var l_URL2 = parent.scriptName + "/POS_ACK_SEARCH.ADD_FRAME?" +
                "p_total=" + p_total;

  			parent.add.location.href = l_URL2;

		}

			var acc_type;
			var acc_type_code;
			var r_row;
			var r_attribute_code;
			var intervalID;

		function call_LOV(c_attribute_code, c_row, l_script)
		{
  			var c_js_where_clause = "";
  			var interval = 100;

  			if (c_attribute_code == "POS_ACK_ACC_TYPE")
   			{
    			if (document.POS_EDIT_POS.POS_ACK_ACC_TYPE[c_row] == null)
     			{
       				acc_type = document.POS_EDIT_POS.POS_ACK_ACC_TYPE;
       				acc_type_code = document.POS_EDIT_POS.POS_ACK_ACC_TYPE_CODE;
     			}
    			else
     			{
       				acc_type = document.POS_EDIT_POS.POS_ACK_ACC_TYPE[c_row];
       				acc_type_code = document.POS_EDIT_POS.POS_ACK_ACC_TYPE_CODE[c_row];
     			}

    			document.POS_ACK_TEMP.POS_ACK_ACC_TYPE.value = acc_type.value;
    			document.POS_ACK_TEMP.POS_ACK_ACC_TYPE_CODE.value = acc_type_code.value;
   			}

  			r_row = c_row;
  			r_attribute_code = c_attribute_code;

  			c_js_where_clause = escape(c_js_where_clause, 1);

  			lov_win = window.open(l_script + "/icx_util.LOV?c_attribute_app_id=178" +
                         "&c_attribute_code=" + c_attribute_code +
                         "&c_region_app_id=178" +
                         "&c_region_code=POS_ACK_EDIT_R" +
                         "&c_form_name=POS_ACK_TEMP"  +
                         "&c_frame_name=result" +
                         "&c_where_clause=" +
                         "&c_js_where_clause=" + c_js_where_clause,"LOV",
                         "resizable=yes,menubar=yes,scrollbars=yes,width=780,height=300");


  			intervalID = window.setInterval("watchme()", interval);

		}

		function watchme()
		{
  			if (lov_win.closed)
  			{
   				if (r_attribute_code == "POS_ACK_ACC_TYPE")
    			{
					acc_type.value = document.POS_ACK_TEMP.POS_ACK_ACC_TYPE.value;
					acc_type_code.value = document.POS_ACK_TEMP.POS_ACK_ACC_TYPE_CODE.value;
    			}
   				clearInterval(intervalID);
   				return;
  			}
		}

  	');
    js.scriptClose;
  htp.headClose;

  select count(*) into  l_count
  from pos_ack_select;

    l_msg1 := fnd_message.get_string('ICX','ICX_POS_ACK_TOTAL_PO_SUB2');
    l_msg1 := replace(l_msg1, '&TOTAL', to_char(l_rows_inserted));

    l_msg2 := fnd_message.get_string('ICX','ICX_POS_ACK_ACC_TYPE_ERR');

  veera_debug('no of rows inserted: ' || to_char(l_rows_inserted));
  htp.p('<body bgcolor=#cccccc onLoad="javascript:LoadCounter(' ||
		'1, ' || to_char(l_count) || ',' || to_char(l_count) ||
		 ',' || to_char(l_rows_inserted) ||
		', ''' || l_msg1 || ''',''' || l_msg2 || '''' ||
		')">');


  if l_count > 0 then
--test
  htp.p('<form name="POS_ACK_TEMP">' ||
        '<input name="POS_ACK_ACC_TYPE" type="HIDDEN" VALUE="">' ||
        '<input name="POS_ACK_ACC_TYPE_CODE" type="HIDDEN" VALUE="">' ||
        '<input name="POS_ACK_ACC_TOTAL_ROWS" type="HIDDEN" VALUE="">' ||
        '</form>');
--test
  	htp.p('<form name="POS_EDIT_POS" ACTION="' || l_script_name ||
        '/POS_ACK_SEARCH.ACKNOWLEDGE_POS" target="result" method="POST">');


  	veera_debug('Row num in result pos: ' || pos_ack_sr_row_num);
  	paint_edit_pos(to_number(pos_ack_sr_row_num));
  	htp.p('</form>');
  else
	htp.p(fnd_message.get_string('ICX','ICX_POS_NO_RECORDS'));
  end if;

  htp.p('</body>');
  htp.htmlClose;
END SHOW_POS;

FUNCTION item_color(l_index in number) RETURN VARCHAR2 IS
BEGIN
   IF ak_query_pkg.g_items_table(l_index).required_flag = 'Y' THEN
   	RETURN ' bgcolor=#FFFF00 ';
   ELSE
	RETURN ' ';
   END IF;

END item_color;

FUNCTION item_halign(l_index in number) RETURN VARCHAR2 IS
BEGIN

   RETURN ' align=' ||
           ak_query_pkg.g_items_table(l_index).horizontal_alignment;

END item_halign;

FUNCTION item_lov(l_index in number) RETURN BOOLEAN IS
BEGIN

 RETURN (ak_query_pkg.g_items_table(l_index).lov_region_code IS NOT NULL AND
                   ak_query_pkg.g_items_table(l_index).lov_attribute_code IS NOT
 NULL);

END item_lov;

FUNCTION item_valign(l_index in number) RETURN VARCHAR2 IS
BEGIN

   RETURN ' valign=' ||
          ak_query_pkg.g_items_table(l_index).vertical_alignment;

END item_valign;

FUNCTION item_name(l_index in number) RETURN VARCHAR2 IS
BEGIN

   RETURN ak_query_pkg.g_items_table(l_index).attribute_label_long;

END item_name;

FUNCTION item_code(l_index in number) RETURN VARCHAR2 IS
BEGIN

   RETURN ak_query_pkg.g_items_table(l_index).attribute_code;

END item_code;

FUNCTION get_option_string(l_index in number)  RETURN VARCHAR2 IS
	l_temp1	VARCHAR2(2000);
	l_temp2	VARCHAR2(2000);
	l_temp3	VARCHAR2(2000);
BEGIN
	if item_code(l_index) = 'POS_ACK_SR_ACC_STATUS' or item_code(l_index) = 'POS_ACK_ACCEPT' then
		l_temp1 := fnd_message.get_string('ICX','ICX_POS_ACK_ACCEPTED');
		l_temp2 := fnd_message.get_string('ICX','ICX_POS_ACK_REJECTED');
		l_temp3 := fnd_message.get_string('ICX','ICX_POS_ACK_NONE');
		return '<OPTION value = "Y">' || l_temp1 || '</OPTION> <OPTION value = "N">' || l_temp2 || '</OPTION> <OPTION selected value = "None">' || l_temp3 || '</OPTION>';
	elsif item_code(l_index) = 'POS_ACK_SR_ACC_REQD' then
		l_temp1 := fnd_message.get_string('ICX','ICX_POS_ACK_YES');
		l_temp2 := fnd_message.get_string('ICX','ICX_POS_ACK_NO');
		return '<OPTION selected value = "Yes">' || l_temp1 || '</OPTION> <OPTION value = "No">' || l_temp2 || '</OPTION>';
	end if;
END get_option_string;

FUNCTION item_style(l_index in number) RETURN VARCHAR2 IS
BEGIN

  RETURN ak_query_pkg.g_items_table(l_index).item_style;

END item_style;

FUNCTION item_displayed(l_index in number) RETURN BOOLEAN IS
BEGIN

  RETURN (ak_query_pkg.g_items_table(l_index).node_display_flag = 'Y');

END item_displayed;

FUNCTION item_updateable(l_index in number) RETURN BOOLEAN IS
BEGIN

 RETURN (ak_query_pkg.g_items_table(l_index).update_flag = 'Y');

END item_updateable;

FUNCTION item_size (l_index in number) RETURN VARCHAR2 IS
BEGIN

  RETURN ' size='  || to_char(ak_query_pkg.g_items_table(l_index).display_value_length);

END item_size;

FUNCTION item_reqd(l_index in number) RETURN VARCHAR2 IS
BEGIN
   if ak_query_pkg.g_items_table(l_index).required_flag = 'Y' then
      return  '<IMG src=/OA_MEDIA/FNDIREQD.gif border=no>';
   else
      return '';
   end if;
END item_reqd;

function get_result_value(p_index in number, p_col in number) return varchar2 is
    sql_statement   VARCHAR2(300);
    l_cursor       INTEGER;
    l_execute      INTEGER;
    l_result       VARCHAR2(2000);
BEGIN
/*
      sql_statement := 'begin ' ||
                       ':l_result := ak_query_pkg.g_results_table(:p_index).value' ||
                                             to_char(p_col) || '; ' ||
                       ' end;';

      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(l_cursor, sql_statement, dbms_sql.v7);
      dbms_sql.bind_variable(l_cursor, 'l_result', l_result, 2000);
      dbms_sql.bind_variable(l_cursor, 'p_index', p_index);

      l_execute := dbms_sql.execute(l_cursor);
      dbms_sql.variable_value(l_cursor, 'l_result', l_result);
      return l_result;
*/
  if ak_query_pkg.g_results_table.count = 0 then
	 return NULL;
  end if;
  if p_col = 1 then
    return ak_query_pkg.g_results_table(p_index).value1;
  elsif p_col = 2 then
    return ak_query_pkg.g_results_table(p_index).value2;
  elsif p_col = 3 then
    return ak_query_pkg.g_results_table(p_index).value3;
  elsif p_col = 4 then
    return ak_query_pkg.g_results_table(p_index).value4;
  elsif p_col = 5 then
    return ak_query_pkg.g_results_table(p_index).value5;
  elsif p_col = 6 then
    return ak_query_pkg.g_results_table(p_index).value6;
  elsif p_col = 7 then
    return ak_query_pkg.g_results_table(p_index).value7;
  elsif p_col = 8 then
    return ak_query_pkg.g_results_table(p_index).value8;
  elsif p_col = 9 then
    return ak_query_pkg.g_results_table(p_index).value9;
  elsif p_col = 10 then
    return ak_query_pkg.g_results_table(p_index).value10;
  elsif p_col = 11 then
    return ak_query_pkg.g_results_table(p_index).value11;
  elsif p_col = 12 then
    return ak_query_pkg.g_results_table(p_index).value12;
  elsif p_col = 13 then
    return ak_query_pkg.g_results_table(p_index).value13;
  elsif p_col = 14 then
    return ak_query_pkg.g_results_table(p_index).value14;
  elsif p_col = 15 then
    return ak_query_pkg.g_results_table(p_index).value15;
  elsif p_col = 16 then
    return ak_query_pkg.g_results_table(p_index).value16;
  elsif p_col = 17 then
    return ak_query_pkg.g_results_table(p_index).value17;
  elsif p_col = 18 then
    return ak_query_pkg.g_results_table(p_index).value18;
  elsif p_col = 19 then
    return ak_query_pkg.g_results_table(p_index).value19;
  elsif p_col = 20 then
    return ak_query_pkg.g_results_table(p_index).value20;
  elsif p_col = 21 then
    return ak_query_pkg.g_results_table(p_index).value21;
  elsif p_col = 22 then
    return ak_query_pkg.g_results_table(p_index).value22;
  elsif p_col = 23 then
    return ak_query_pkg.g_results_table(p_index).value23;
  elsif p_col = 24 then
    return ak_query_pkg.g_results_table(p_index).value24;
  elsif p_col = 25 then
    return ak_query_pkg.g_results_table(p_index).value25;
  elsif p_col = 26 then
    return ak_query_pkg.g_results_table(p_index).value26;
  elsif p_col = 27 then
    return ak_query_pkg.g_results_table(p_index).value27;
  elsif p_col = 28 then
    return ak_query_pkg.g_results_table(p_index).value28;
  elsif p_col = 29 then
    return ak_query_pkg.g_results_table(p_index).value29;
  elsif p_col = 30 then
    return ak_query_pkg.g_results_table(p_index).value30;
  elsif p_col = 31 then
    return ak_query_pkg.g_results_table(p_index).value29;
  elsif p_col = 32 then
    return ak_query_pkg.g_results_table(p_index).value30;
  elsif p_col = 33 then
    return ak_query_pkg.g_results_table(p_index).value29;
  elsif p_col = 34 then
    return ak_query_pkg.g_results_table(p_index).value30;
  end if;

END get_result_value;

procedure button(src IN varchar2,
                 txt IN varchar2) IS
BEGIN

htp.p('
         <table cellpadding=0 cellspacing=0 border=0>
          <tr>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif ></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif ></td>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif ></td>
          </tr>
          <tr>
           <td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>
          </tr>
          <tr>
           <td bgcolor=#cccccc height=20 nowrap><a
href="' || src || '"><font class=button>'|| txt || '</font></a></td>
          </tr>
          <tr>
           <td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>
          </tr>
          <tr>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
          </tr>
         </table>
');

END button;

PROCEDURE button(src1 IN varchar2,
                 txt1 IN varchar2,
                 src2 IN varchar2,
                 txt2 IN varchar2) IS
BEGIN

  htp.p('
         <table cellpadding=0 cellspacing=0 border=0>
          <tr>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif ></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif ></td>
           <td rowspan=5><img src=/OA_MEDIA/FNDBSQRR.gif ></td>
           <td width=15 rowspan=5></td>
           <td rowspan=5><img src=/OA_MEDIA/FNDBSQRL.gif ></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif ></td>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif ></td>
          </tr>
          <tr>
           <td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>
           <td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>
          </tr>
          <tr>
           <td bgcolor=#cccccc height=20 nowrap><a
href="' || src1 || '"><font class=button>'|| txt1 || '</font></a></td>
           <td bgcolor=#cccccc height=20 nowrap><a
href="' || src2 || '"><font class=button>'|| txt2 || '</font></a></td>
          </tr>
          <tr>
           <td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>
           <td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>
          </tr>
          <tr>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
          </tr>
         </table>
       ');

END button;

PROCEDURE PAINT_EDIT_POS(l_row_num	NUMBER default 0)
IS
  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_responsibility_id     NUMBER;
  l_session_id  NUMBER;

  l_attribute_index  NUMBER;
  l_result_index     NUMBER;
  l_current_col      NUMBER;
  l_current_row      NUMBER;
  l_where_clause     VARCHAR2(2000);
  l_start_row		NUMBER;
  l_end_row		NUMBER;

  l_buyer_id		NUMBER;
  l_po_num		VARCHAR2(240);
  l_po_header_id    NUMBER;
  l_hidden_fields_string VARCHAR2(32000);
BEGIN

  veera_debug('Row Number:' || to_char(l_row_num));
  if l_row_num = 0 then
  	l_start_row := 1;
  else
  	l_start_row := l_row_num;
  end if;
  --l_end_row := l_start_row + 25 - 1;
  l_end_row := 99999;

  veera_debug('Inside Paint_Edit_POS');
  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

  --l_where_clause :=  'SESSION_ID = ' || to_char(l_session_id);
  l_where_clause :=  '';

  veera_debug('User Id: ' || to_char(l_user_id) || 'Resp ID: ' || to_char(l_responsibility_id) );

  ak_query_pkg.exec_query(p_parent_region_appl_id   =>  178,
                          p_parent_region_code      =>  'POS_ACK_EDIT_R',
                          p_where_clause            =>  l_where_clause,
                          p_responsibility_id       =>  l_responsibility_id,
                          p_user_id                 =>  l_user_id,
                          p_return_parents          =>  'T',
                          p_return_children         =>  'F');

  l_attribute_index := ak_query_pkg.g_items_table.FIRST;
  veera_debug('After AK Select' || to_char(ak_query_pkg.g_items_table.count));

  htp.p('<table width=96% bgcolor=#999999 cellpadding=2 cellspacing=0 border=0>'
);
  htp.p('<tr><td>');


 -- Print the table heading
  htp.p('<table align=center bgcolor=#999999 cellpadding=2 cellspacing=1 border=0>');

  htp.p('<tr>');

  WHILE (l_attribute_index IS NOT NULL) LOOP
    IF (item_style(l_attribute_index) = 'HIDDEN') THEN
       htp.p('<!-- ' ||  item_code(l_attribute_index)  ||
             ' - '   ||  item_style(l_attribute_index) || ' -->' );
    ELSIF item_displayed(l_attribute_index)  THEN
          htp.p('<td bgcolor=#336699' ||
                 item_halign(l_attribute_index) ||
                 --item_valign(l_attribute_index) ||
				 ' valign=bottom' ||
                '>' ||
                item_reqd(l_attribute_index)
                );
          --htp.p('<font class=promptwhite>' || item_name(l_attribute_index) || '</font>');
          htp.p('<font color=#FFFFFF>' || item_name(l_attribute_index) || '</font>');
          htp.p('</td>');
    END IF;

    l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);
  END LOOP;
--test promise date
  htp.p('<td bgcolor=#336699><font color=#FFFFFF>&nbsp</font></td>');
--test promise date

  htp.p('</tr>');

 ----- end print table heading ----


 ----- print contents -----------

  veera_debug('After AK Select: no of rows:' || to_char(ak_query_pkg.g_results_table.count));
  IF ak_query_pkg.g_results_table.count > 0 THEN
    l_result_index := ak_query_pkg.g_results_table.FIRST;
    l_current_row := 0;
    WHILE (l_result_index IS NOT NULL) LOOP
             l_hidden_fields_string := '';
      l_current_row := l_current_row + 1;
--
	  IF (get_result_value(l_result_index, 1) < l_start_row) or (get_result_value(l_result_index, 1) > l_end_row) then
		GOTO my_point2;
	  end if;
--
      if ((l_current_row mod 2) = 0) THEN
         htp.p('<tr BGCOLOR=''#ffffff'' >');
      else
        htp.p('<tr BGCOLOR=''#99ccff'' >');
      end if;
      l_attribute_index := ak_query_pkg.g_items_table.FIRST;
      l_current_col := 0;
      WHILE (l_attribute_index IS NOT NULL) LOOP
        l_current_col := l_current_col + 1;
	    -- hardcode radio buttons
		IF (item_code(l_attribute_index) = 'POS_ACK_ACCEPT') THEN
			htp.p('<td nowrap ' ||
                        item_halign(l_attribute_index) ||
                        item_valign(l_attribute_index) ||
                  '>' ||
                  '<font class=datablack>' ||					'<select name="POS_ACK_ACCEPT">' ||
					get_option_string(l_attribute_index) ||
					'</seLect>' ||
                  '</font>' ||
                  '</td>');
			GOTO my_point;
		ELSIF (item_code(l_attribute_index) =  'POS_ACK_REJECT') THEN
            htp.p('<td nowrap ' ||
                        item_halign(l_attribute_index) ||
                        item_valign(l_attribute_index) ||
                  '>' ||
                  '<font class=datablack>' ||
                      '<input type=radio name="POS_ACK_ACCEPT_REJECT" value="reject"' ||
                  '</font>' ||
                  '</td>');
			GOTO my_point;

		ELSIF (item_code(l_attribute_index) =  'POS_ACK_PO_NUMBER') THEN
   					htp.p('<td  nowrap' || item_halign(l_attribute_index) || item_valign(l_attribute_index) || '>');
      				htp.p('<a  target="PONUM" href="' || po_num(get_result_value(l_result_index, l_current_col), l_po_header_id) ||'">' || nvl(get_result_value(l_result_index, l_current_col), '&nbsp') || '</a> ');
      				--htp.p('<a  target="PONUM" href="' || 'xyz' ||'">' || nvl(get_result_value(l_result_index, l_current_col), '&nbsp') || '</a> ');
   					htp.p('</td>');
					l_po_num := get_result_value(l_result_index, l_current_col);
			GOTO my_point;

		ELSIF (item_code(l_attribute_index) =  'POS_ACK_BUYER') THEN
   					htp.p('<td  nowrap' || item_halign(l_attribute_index) || item_valign(l_attribute_index) || '>');
      				htp.p('<a  target="PONUM" href="' || buyer(l_po_num, l_po_header_id) ||'">' || nvl(get_result_value(l_result_index, l_current_col), '&nbsp') || '</a> ');
      				--htp.p('<a  target="PONUM" href="' || 'xyz' ||'">' || nvl(get_result_value(l_result_index, l_current_col), '&nbsp') || '</a> ');
   					htp.p('</td>');
			GOTO my_point;

		END IF;
        IF (item_style(l_attribute_index) = 'HIDDEN') THEN
		   IF  (item_code(l_attribute_index) =  'POS_ACK_BUYER_ID') THEN
				l_buyer_id :=  get_result_value(l_result_index, l_current_col);
		   elsif (item_code(l_attribute_index) =  'POS_ACK_PO_HEADER_ID') THEN
				l_po_header_id := get_result_value(l_result_index, l_current_col);
		   END IF;

		   l_hidden_fields_string := l_hidden_fields_string || '<input name="' || item_code(l_attribute_index) ||'" type="HIDDEN" VALUE="' || get_result_value(l_result_index, l_current_col) ||'">' ;

           /*htp.p('<input name="' || item_code(l_attribute_index) ||
                 '" type="HIDDEN" VALUE="' || get_result_value(l_result_index, l_current_col) ||
                 '">'); */
        ELSE
         IF item_displayed(l_attribute_index)  THEN
           IF (item_style(l_attribute_index) = 'TEXT' ) THEN
              IF item_updateable(l_attribute_index) THEN
                htp.p('<td nowrap ' ||
                        item_halign(l_attribute_index) ||
                        item_valign(l_attribute_index) ||
                      '>' ||
                      '<font class=datablack>' ||
                      '<input type=text ' || item_size(l_attribute_index) ||
                        ' name="' || item_code(l_attribute_index)  || '"' ||
                      ' value="' || nvl(get_result_value(l_result_index, l_current_col),'')  ||
--                       '" ></font>' ||
--LOV Test
                       '" ></font>'
		);
	        IF (ak_query_pkg.g_items_table(l_attribute_index).lov_region_code IS NOT NULL AND ak_query_pkg.g_items_table(l_attribute_index).lov_attribute_code IS NOT NULL) THEN
/*
	            htp.p('<A HREF="javascript:call_LOV('''||
                  ak_query_pkg.g_items_table(l_attribute_index).attribute_code || ''')"' ||
                  '><IMG SRC="/OA_MEDIA/FNDLSTOV.gif" BORDER=0 WIDTH=23 HEIGHT=21 border=no align=absmiddle></A></TD>');
*/
	            htp.p('<A HREF="javascript:call_LOV('''||
                  ak_query_pkg.g_items_table(l_attribute_index).attribute_code || ''''|| ',' || ''''|| to_char(l_current_row-1) || '''' || ',' || ''''|| l_script_name ||
				  ''')"' ||
                  '><IMG SRC="/OA_MEDIA/FNDLSTOV.gif" BORDER=0 WIDTH=23 HEIGHT=21 border=no align=absmiddle></A></TD>');
        	END IF;
                       htp.p('</td>');

--LOV Test
--                       '</td>');
              ELSE
              		htp.p('<td nowrap ' ||
                        item_halign(l_attribute_index) ||
                        item_valign(l_attribute_index) ||
                      '>' ||
                     '<font class=tabledata>' ||
                       nvl(get_result_value(l_result_index, l_current_col), '&nbsp') ||
                     '</font></td>');

              END IF;
           ELSIF (item_style(l_attribute_index) = 'CHECKBOX') THEN
               l_current_col := l_current_col -1;
               htp.p('<td nowrap ' ||
                        item_halign(l_attribute_index) ||
                        item_valign(l_attribute_index) ||
                      '>' ||
                      '<B><font class=datablack>' ||
                      '<input type="checkbox"  name="' ||
                        item_code(l_attribute_index) || '"' ||
                      ' value="' || to_char(l_current_row) ||
                       '" ></font></B></td>');
           ELSIF (item_style(l_attribute_index) = 'IMAGE') THEN
                l_current_col := l_current_col -1;
    		htp.p('<td nowrap ' ||
                        item_halign(l_attribute_index) ||
                        item_valign(l_attribute_index) ||
                      '>' ||
                     '<a href="javascript:details(' ||
                       to_char(l_current_row-1) || ')"' ||
                     ' target="_self"><IMG NAME="' ||
                       item_code(l_attribute_index) ||
                     '" src=/OA_MEDIA/FNDIITMD.gif border=no></a></td>');
          END IF;
         END IF;
        END IF;
		  <<my_point>>
          l_attribute_index := ak_query_pkg.g_items_table.NEXT(l_attribute_index);
        END LOOP;
-- test promise date
		htp.p('
			<td align=left valign=center nowrap><a href="javascript:changePromisedDate('|| icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID)  || ',' ||
			''''|| l_po_num ||'''' || ')"> <font class=tabledata>' ||
			fnd_message.get_string('ICX','ICX_POS_ACK_PROMISED_DATE') ||
			'</font></a>' || l_hidden_fields_string || '</td>');
-- test promise date
        htp.p('</tr>');
		<<my_point2>>
        l_result_index := ak_query_pkg.g_results_table.NEXT(l_result_index);
    END LOOP;
  END IF;

  htp.p('</table>');
  htp.p('</td></tr></table>');

END paint_edit_pos;

PROCEDURE  Find_Matching_Rows (
                        l_Acceptance_Status 	IN VARCHAR2 default null,
                        l_Acceptance_Reqd_Flag 	IN VARCHAR2 default null,
                        l_Start_Date			IN VARCHAR2 default null,
                        l_End_Date				IN VARCHAR2 default null,
                        l_PO_Number				IN VARCHAR2 default null,
                        l_Supplier_Site_Id		IN VARCHAR2 default null,
						l_Document_Type_Code	IN VARCHAR2 default null
                     )
IS

	l_format_mask        icx_sessions.DATE_FORMAT_MASK%TYPE;
	l_session_id         number;

	CURSOR l_cursor IS
		select *
		from pos_ack_select_v
		where
			acceptance_status =  nvl(l_acceptance_status, acceptance_status)
 			and acceptance_required = nvl(l_Acceptance_Reqd_Flag, acceptance_required)
		--	and acceptance_required_by between nvl(l_Start_Date, acceptance_required_by) and nvl(l_End_Date, acceptance_required_by)
			and ( acceptance_required_by >= decode(l_Start_Date, null, acceptance_required_by, fnd_date.chardate_to_date(l_Start_Date)) or (acceptance_required_by is null and l_Start_Date is null) )
			and (acceptance_required_by <= decode(l_End_Date, null, acceptance_required_by, fnd_date.chardate_to_date(l_End_Date))  or (acceptance_required_by is null and l_End_Date is null) )
			and po_number like nvl(l_PO_Number, po_number)
			and supplier_site_id = nvl(l_Supplier_Site_Id, supplier_site_id)
			and document_type_code = nvl(l_Document_Type_Code, document_type_code) order by po_number;
	l_po_rec l_cursor%ROWTYPE;
	l_rows	NUMBER := 0;
	l_temp1	VARCHAR2(2000);
	l_temp2	VARCHAR2(2000);
BEGIN
	Veera_Debug('Acceptance Status:' || l_acceptance_status);
	Veera_Debug('Acceptance Required:' || l_Acceptance_Reqd_Flag);
	Veera_Debug('Acceptance Required By:' || l_start_date || 'to' || l_end_date);
	Veera_Debug('supplier_site_id :' || l_Supplier_Site_Id);
	Veera_Debug('Document Type :' || l_Document_Type_Code);
	delete from pos_ack_select;

	l_temp1 := fnd_message.get_string('ICX','ICX_POS_ACK_YES');
	l_temp2 := fnd_message.get_string('ICX','ICX_POS_ACK_NO');

	l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);

	-- Bug 1196968

  	select date_format_mask
    	  into l_format_mask
    	  from icx_sessions
   	where session_id = l_session_id;

  	fnd_date.initialize(l_format_mask);

	open l_cursor;
	LOOP
		fetch l_cursor into l_po_rec;
		EXIT WHEN l_cursor%NOTFOUND;

		insert into pos_ack_select
			(
			acceptance_flag,
			accept,
			reject,
			acceptance_type_code,
            		acceptance_type,
   			comments,
			po_header_id,
			po_release_id,
			po_number,
			release_number,
			revision_number,
			document_type_code,
			document_type,
			currency_code,
			total,
			acceptance_required,
			acceptance_status,
			acceptance_required_by,
			approval_status,
			shipto_location_id,
			shipto_location,
			carrier_code,
			carrier,
			buyer_id,
			buyer_name,
			supplier_org_id,
			supplier_id,
			supplier_name,
			supplier_site_id,
			supplier_site,
			row_num
			)
			values
			(
			l_po_rec.acceptance_flag,
			l_po_rec.accept,
			l_po_rec.reject,
			nvl(l_po_rec.acceptance_type_code,'-99999'),
            l_po_rec.acceptance_type,
   			l_po_rec.comments,
			l_po_rec.po_header_id,
			l_po_rec.po_release_id,
			l_po_rec.po_number,
			l_po_rec.release_number,
			l_po_rec.revision_number,
			l_po_rec.document_type_code,
			l_po_rec.document_type,
			l_po_rec.currency_code,
			l_po_rec.total,
			decode(l_po_rec.acceptance_required, 'Yes', l_temp1, l_temp2),
			l_po_rec.acceptance_status,
			l_po_rec.acceptance_required_by,
			l_po_rec.approval_status,
			l_po_rec.shipto_location_id,
			l_po_rec.shipto_location,
			l_po_rec.carrier_code,
			l_po_rec.carrier,
			l_po_rec.buyer_id,
			l_po_rec.buyer_name,
			l_po_rec.supplier_org_id,
			l_po_rec.supplier_id,
			l_po_rec.supplier_name,
			l_po_rec.supplier_site_id,
			l_po_rec.supplier_site,
			l_rows+1
			);
		l_rows := l_rows + 1;
	END LOOP;
	close l_cursor;
	Veera_Debug('No of Rows Selected: ' || to_char(l_rows));
END Find_Matching_Rows;

PROCEDURE ACKNOWLEDGE_POS (
	pos_ack_row_num			IN	g_text_table default g_dummy_tbl,
	pos_ack_accept			IN	g_text_table default g_dummy_tbl,
	pos_ack_acc_type		IN	g_text_table default g_dummy_tbl,
	pos_ack_comments		IN	g_text_table default g_dummy_tbl,
	--pos_ack_document_type	IN	g_text_table default g_dummy_tbl,
	--pos_ack_currency		IN	g_text_table default g_dummy_tbl,
	--pos_ack_total			IN	g_text_table default g_dummy_tbl,
	--pos_ack_approval_status	IN	g_text_table default g_dummy_tbl,
	pos_ack_shipto_loc		IN	g_text_table default g_dummy_tbl,
	pos_ack_carrier			IN	g_text_table default g_dummy_tbl,
	pos_ack_po_header_id		IN	g_text_table default g_dummy_tbl,
	pos_ack_release_id		IN	g_text_table default g_dummy_tbl,
	pos_ack_buyer_id		IN	g_text_table default g_dummy_tbl,
	pos_ack_acc_type_code		IN	g_text_table default g_dummy_tbl
	)
IS
	l_temp1			VARCHAR2(2000);
	l_acceptance_id		NUMBER;
	l_revision_num		NUMBER;
	l_rows_inserted		NUMBER := 0;
	l_error			NUMBER := 0;
  	l_user_id     		NUMBER;
	l_doc_id		NUMBER;
	l_doc_type		VARCHAR2(10);
        l_seq_val               NUMBER;
	l_item_type        	VARCHAR2(100)   := 'POSNOTB';
	l_item_key         	VARCHAR2(100);
	l_org_id	   	NUMBER;
	l_accp_res		VARCHAR2(20);
	l_accp_type		VARCHAR2(80);

BEGIN
   veera_debug('Start Acknowledge_pos');

   IF NOT icx_sec.validatesession THEN
    RETURN;
   END IF;

	l_temp1 := fnd_message.get_string('ICX','ICX_POS_ACK_WEB');
  	l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

	FOR l_counter IN 1..pos_ack_po_header_id.count LOOP
		IF POS_ACK_ACCEPT(l_counter) <> 'None' then
			veera_debug('Acc Type Code: ' || pos_ack_acc_type_code(l_counter));
			IF pos_ack_acc_type_code(l_counter) <> '-99999' then

				l_rows_inserted := l_rows_inserted + 1;
				select po_acceptances_s.nextval into l_acceptance_id
				from dual;

				select revision_num,org_id into l_revision_num , l_org_id
				from po_headers_all
				where po_header_id = pos_ack_po_header_id(l_counter);

				select description into l_accp_type
				from POS_ACK_ACC_TYPE_LOV_V
				where LOOKUP_CODE =  pos_ack_acc_type_code(l_counter);


				if to_number(pos_ack_release_id(l_counter)) = -1 then
					l_doc_id := to_number(pos_ack_po_header_id(l_counter));
					l_doc_type := 'PO';
				else
					l_doc_id := to_number(pos_ack_release_id(l_counter));
					l_doc_type := 'RELEASE';
				end if;

				insert into po_acceptances (
						acceptance_id,
						last_update_Date,
						last_updated_by,
						last_update_login,
						creation_date,
						created_by,
						po_header_id,
						po_release_id,
						action,
						action_date,
						employee_id,
						revision_num,
						accepted_flag,
						acceptance_lookup_code,
						note
						)
				values (
						l_acceptance_id,
						sysdate,
						l_user_id,
						l_user_id,
						sysdate,
						l_user_id,
						pos_ack_po_header_id(l_counter),
						decode(pos_ack_release_id(l_counter), -1,null,pos_ack_release_id(l_counter)),
						l_temp1,
						sysdate,
						pos_ack_buyer_id(l_counter),
						l_revision_num,
						pos_ack_accept(l_counter),
						pos_ack_acc_type_code(l_counter),
						pos_ack_comments(l_counter)
					);

-- Call the workflow for sending notification to the Buyer
       				   select po_wf_itemkey_s.nextval
				   into l_seq_val
   				   from dual;

				   l_item_key := 'POS_PO_ACK_' || l_doc_id || '_' || to_char(l_seq_val);

					wf_engine.createProcess(ItemType => l_item_type,
                            		ItemKey     => l_item_key,
                            		Process     => 'MAIN_PROCESS');

   			    		wf_engine.SetItemAttrNumber (
                            		ItemType    => l_item_type,
                            		ItemKey     => l_item_key,
                            		aname       => 'DOCUMENT_ID',
                            		avalue      => l_doc_id);

   			    		wf_engine.SetItemAttrText (
                            		ItemType    => l_item_type,
                            		ItemKey     => l_item_key,
                            		aname       => 'DOCUMENT_TYPE_CODE',
                            		avalue      => l_doc_type);

   		            		wf_engine.SetItemAttrNumber(
                            		ItemType    => l_item_type,
                            		ItemKey     => l_item_key,
                            		aname       => 'ORG_ID',
                            		avalue      => l_org_id);

					if pos_ack_accept(l_counter) = 'Y' then
					   l_accp_res := fnd_message.get_string('ICX','ICX_POS_ACCEPT');
					else
					   l_accp_res := fnd_message.get_string('ICX','ICX_POS_REJECT');
					end if;

   		            		wf_engine.SetItemAttrText (
                            		ItemType    => l_item_type,
                            		ItemKey     => l_item_key,
                            		aname       => 'ACCEPTANCE_RESULT',
                            		avalue      => l_accp_res);

   		            		wf_engine.SetItemAttrText (
                            		ItemType    => l_item_type,
                            		ItemKey     => l_item_key,
                            		aname       => 'ACCEPTANCE_TYPE',
                            		avalue      => l_accp_type);

   		            		wf_engine.SetItemAttrText (
                            		ItemType    => l_item_type,
                            		ItemKey     => l_item_key,
                            		aname       => 'ACCEPTANCE_COMMENTS',
                            		avalue      =>  pos_ack_comments(l_counter));

  			    		wf_engine.StartProcess( ItemType => l_item_type,
                           			ItemKey  => l_item_key );



				delete from pos_ack_select
				where row_num = to_number(pos_ack_row_num(l_counter));
				POS_WF_PO_ACKNOWLEDGE.Abort_Notification(l_doc_id, l_revision_num, l_doc_type);
			else
				l_error := -1;
			end if;
		else
			delete from pos_ack_select
			where row_num = to_number(pos_ack_row_num(l_counter));
		end if;
	END LOOP;
	veera_debug('Rows Inserted in PO ACKs :' || to_char(l_rows_inserted));
	veera_debug('l_error: :' || to_char(l_error));
	IF l_error = 0 then
		blank_frame(1, l_rows_inserted);
	ELSE
		show_pos(l_rows_inserted => l_rows_inserted);
	END IF;
END ACKNOWLEDGE_POS;

FUNCTION po_num(seg1 in varchar2, po_header_id in number default null) RETURN VARCHAR2 IS
  p_rowid    VARCHAR2(2000);
  l_param    VARCHAR2(2000);
  Y          VARCHAR2(2000);
  header_id  NUMBER;

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;
  l_responsibility_id  NUMBER;
BEGIN

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
  l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);

  fnd_client_info.set_org_context(l_org_id);

  select  rowidtochar(ROWID)
  into    p_rowid
  from    AK_FLOW_REGION_RELATIONS
  where   FROM_REGION_CODE = 'ICX_PO_HEADERS_D'
  and     FROM_REGION_APPL_ID = 178
  and     FROM_PAGE_CODE = 'ICX_PO_HEADERS_D'
  and     FROM_PAGE_APPL_ID = 178
  and     TO_PAGE_CODE = 'ICX_PO_HEADERS_DTL_D'
  and     TO_PAGE_APPL_ID = 178
  and     FLOW_CODE = 'ICX_INQUIRIES'
  and     FLOW_APPLICATION_ID = 178;

/*
  select po_header_id
  into header_id
  from po_headers
  where segment1 = decode(instrb(seg1,'-'), 0, seg1, substr(seg1, 1, (instrb(seg1,'-')-1)));
*/
  header_id := po_header_id;

  l_param :=  icx_on_utilities.buildOracleONstring(p_rowid => p_rowid,
                                                   p_primary_key => 'ICX_PO_SUPPLIER_ORDERS_PK',
                                                   p1 => to_char(header_id));

  Y := icx_call.encrypt2(l_param,l_session_id);

  return l_script_name || '/OracleOn.IC?Y=' || Y;

END po_num;

FUNCTION buyer(seg1 in varchar2, po_header_id in number default null) RETURN VARCHAR2 IS
  p_rowid    VARCHAR2(2000);
  l_param    VARCHAR2(2000);
  Y          VARCHAR2(2000);
  header_id  NUMBER;

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;
  l_responsibility_id  NUMBER;
BEGIN

  l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
  l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
  l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
  l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);

  fnd_client_info.set_org_context(l_org_id);

  select  rowidtochar(ROWID)
  into    p_rowid
  from    AK_FLOW_REGION_RELATIONS
  where   FROM_REGION_CODE = 'ICX_PO_HEADERS_D'
  and     FROM_REGION_APPL_ID = 178
  and     FROM_PAGE_CODE = 'ICX_PO_HEADERS_D'
  and     FROM_PAGE_APPL_ID = 178
  and     TO_PAGE_CODE = 'ICX_PO_BUYER_DTL'
  and     TO_PAGE_APPL_ID = 178
  and     FLOW_CODE = 'ICX_INQUIRIES'
  and     FLOW_APPLICATION_ID = 178;

/*
  select po_header_id
  into header_id
  from po_headers
  where segment1 = decode(instrb(seg1,'-'), 0, seg1, substr(seg1, 1, (instrb(seg1,'-')-1)));
*/
  header_id := po_header_id;

  l_param :=  icx_on_utilities.buildOracleONstring(p_rowid => p_rowid,
                                                   p_primary_key => 'ICX_PO_SUPPLIER_ORDERS_PK',
                                                   p1 => to_char(header_id));

  Y := icx_call.encrypt2(l_param,l_session_id);

  return l_script_name || '/OracleOn.IC?Y=' || Y;

END buyer;

PROCEDURE CLEAR_LOG
IS
BEGIN
--  delete from veera_debug;
--  commit;
  htp.htmlOpen;
  htp.headOpen;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');
	htp.p('<script LANGUAGE="JavaScript"> top.close </script>');
  htp.headClose;
  htp.bodyOpen;
  htp.bodyClose;
  htp.htmlClose;
END CLEAR_LOG;

PROCEDURE DISPLAY_LOG
IS
debug_string	VARCHAR2(2000);
CURSOR debug_cursor IS
	select sysdate from dual;
BEGIN
  open debug_cursor;
  htp.htmlOpen;
  htp.headOpen;
  	htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');
  htp.headClose;
  htp.bodyOpen;
  htp.p('<body bgcolor=#cccccc>');

  LOOP
    FETCH debug_cursor
    INTO debug_string;
    htp.p(debug_string || '<BR>');
    EXIT WHEN debug_cursor%NOTFOUND;
  END LOOP;
  CLOSE debug_cursor;

  htp.bodyClose;
  htp.htmlClose;
END DISPLAY_LOG;

END POS_ACK_SEARCH;

/
