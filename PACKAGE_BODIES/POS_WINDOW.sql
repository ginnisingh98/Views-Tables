--------------------------------------------------------
--  DDL for Package Body POS_WINDOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_WINDOW" AS
/* $Header: POSASLWB.pls 115.1 99/10/14 16:18:24 porting shi $ */

  /* DialogBox
   * ---------
   */
  PROCEDURE dialogbox IS
    l_script_name VARCHAR2(240);
  BEGIN

    l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');

    htp.htmlOpen;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

    htp.headOpen;

    htp.p('<script src="/OA_HTML/POSWUTIL.js"></script>');

    htp.p('<SCRIPT>
           document.write("<title>" +
           top.getTop().FND_MESSAGES["ICX_POS_CAP_CONFIRM"] + "</title>")
           </SCRIPT>');

    js.scriptOpen;

    htp.p('

  function drawMe(doc)
  {

    var htmlString = "<html><LINK REL=STYLESHEET HREF=/OA_HTML/US/POSSTYLE.css TYPE=text/css><body bgcolor=#cccccc><center><table width=100% height=100%><tr><td width=20% align=center valign=center></td><td valign=center><font class=datablack>" +
                          top.getTop().FND_MESSAGES[''ICX_POS_CAP_SUBMIT_CONFIRM''] +
                     "</font></td></tr></table></body></html>" ;
    doc.write(htmlString);
    doc.close();
  }

    ');

    js.scriptClose;

    htp.headClose;

    htp.p('<frameset cols="3,*,3" border=0>');
    htp.p('   <frame
		src=/OA_HTML/US/POSBLBOR.htm
		name=borderLeft
		marginwidth=0
		scrolling=no>');
    htp.p('   <frameset rows="15,*,7,45" border=0 >');
    htp.p('      <frame
                  src=/OA_HTML/US/POSDLTOP.htm
        	  name=alert_cancel_top
        	  marginwidth=0
       		  scrolling=no>');
    htp.p('      <frame
        	  src="javascript:top.drawMe(document);"
        	  name=alert_cancel_content
        	  marginwidth=6
		  marginheight=2
       		  scrolling=auto>');

    -- lower banner with curved edge
    htp.p('      <frame src="/OA_HTML/US/POSLWBAN.htm"');
    htp.p('       name=lowerbanner');
    htp.p('       marginwidth=0');
    htp.p('       marginheight=2');
    htp.p('       frameborder=no');
    htp.p('       scrolling=no>');


    htp.p('	  <frame src="' || l_script_name ||
          '/pos_window_sv.buildbuttons?p_button1Name=ICX_POS_ASN_EDIT_EXIT_BUT&p_button1Function=AslDiscard()&p_button2Name=&p_button2Function=&p_button3Name=ICX_POS_CAP_CREATE&p_button3Function=AslCreateEntry(top)"');

    htp.p('	name=alert_cancel_bottom');
    htp.p('     marginwidth=0');
    htp.p('     scrolling=no>');
    htp.p('   </frameset>');

    htp.p('   <frame
	       src=/OA_HTML/US/POSBLBOR.htm
	       name=borderRight
	       marginwidth=0
	       marginheight=0
	       scrolling=no>');

    htp.p('</frameset>');

    htp.htmlClose;

  END dialogbox;


  /* BuildButtons
   * ------------
   */
  PROCEDURE BuildButtons(p_button1Name VARCHAR2, p_button1Function VARCHAR2,
                         p_button2Name VARCHAR2, p_button2Function VARCHAR2,
                         p_button3Name VARCHAR2, p_button3Function VARCHAR2)
  IS
  BEGIN

    htp.htmlOpen;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

    htp.headOpen;
    htp.headClose;
    htp.bodyOpen(NULL, 'bgcolor=#336699');
/*
    htp.p('
      <table width=100% cellpadding=0 cellspacing=0 border=0>
      <tr bgcolor=#cccccc>
      <td><img src=/OA_MEDIA/FNDCTBL.gif></td>
      <td width=100%><img src=/OA_MEDIA/FNDPXG5.gif></td>
      <td><img src=/OA_MEDIA/FNDCTBR.gif></td>
      </tr>
      </table>');
*/
    htp.p('
      <table width=100% bgcolor=#336699 cellpadding=0 cellspacing=0 border=0>
      <tr><td height=3><img src=/OA_MEDIA/FNDPX3.gif></td></tr>
      <TR>
      <TD align=right>');

    -- This is a button table containing 3 buttons.
    -- The first row defines the edges and tops
    htp.p('
      <table cellpadding=0 cellspacing=0 border=0>
      <tr>
      <!-- left hand button, round left side and square right side-->
      <td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif></td>
      <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
      <td rowspan=5><img src=/OA_MEDIA/FNDBSQRR.gif></td>');

    htp.p('<!-- standard spacer between square button images-->
           <td width=2 rowspan=5></td>');

    IF (p_button2Name is NOT NULL) THEN
      htp.p('
         <!-- middle button with squared ends on both left and right-->
         <td rowspan=5><img src=/OA_MEDIA/FNDBSQRL.gif></td>
         <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
         <td rowspan=5><img src=/OA_MEDIA/FNDBSQRR.gif></td>
         <!-- standard spacer between square button images-->
         <td width=2 rowspan=5></td>');
    ELSE
      htp.p('
         <!-- middle button with squared ends on both left and right-->
         <td rowspan=5></td>
         <td></td>
         <td rowspan=5></td>
         <!-- standard spacer between square button images-->
         <td width=2 rowspan=5></td>');
    END IF;

    htp.p('
      <!-- right hand button, square left side and round right side-->
      <td rowspan=5><img src=/OA_MEDIA/FNDBSQRL.gif></td>
      <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
      <td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif></td>
      <td width=10 rowspan=5></td>
      </tr>
      <tr>');

    htp.p('<!-- one cell of this type required for every button -->');
    htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
    IF (p_button2Name is NOT NULL) THEN
      htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
    ELSE
      htp.p('<td></td>');
    END IF;
    htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
    htp.p('</tr>');
    htp.p('<tr>');

    htp.p('<!-- Text and links for each button are listed here-->');
    htp.p('<td bgcolor=#cccccc height=20 nowrap>');
    htp.p('<a href="javascript:top.getTop().' || p_button1Function || ';">');
    htp.p('<font class=button>');
    htp.p('<SCRIPT>');
    htp.p('document.write(window.top.getTop().FND_MESSAGES["' ||
          p_button1Name || '"])');
    htp.p('</SCRIPT></font></td>');


    IF (p_button2Name is NOT NULL) THEN
      htp.p('<td bgcolor=#cccccc height=20 nowrap>');
      htp.p('<a href="javascript:top.getTop().' || p_button2Function || ';">');
      htp.p('<font class=button>');
      htp.p('<SCRIPT>');
      htp.p('document.write(window.top.getTop().FND_MESSAGES["' ||
             p_button2Name || '"])');
      htp.p('</SCRIPT></font></td>');
    ELSE
      htp.p('<td></td>');
    END IF;

    htp.p('<td bgcolor=#cccccc height=20 nowrap>');
    htp.p('<a href="javascript:top.getTop().' || p_button3Function || ';">');
    htp.p('<font class=button>');
    htp.p('<SCRIPT>');
    htp.p('document.write(window.top.getTop().FND_MESSAGES["' ||
          p_button3Name || '"])');
    htp.p('</SCRIPT></font></td>');

    htp.p('
      </tr>
      <tr>');

    htp.p('<!-- one cell of this type required for every button -->');
    htp.p('<td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>');
    IF (p_button2Name is NOT NULL) THEN
      htp.p('<td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>');
    ELSE
      htp.p('<td></td>');
    END IF;
    htp.p('<td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>');
    htp.p('</tr>');

    htp.p('<tr>');
    htp.p('<!-- one cell of this type required for every button -->');
    htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
    IF (p_button2Name is NOT NULL) THEN
      htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
    ELSE
      htp.p('<td></td>');
    END IF;
    htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
    htp.p('</tr>');

    htp.p('</table>');

    htp.p('
      </td>
      </tr>
      <TR><td height=30><img src=/OA_MEDIA/FNDPX3.gif></td></TR>
      </table>
      </body>
      </html>
      ');

  END BuildButtons;




  /* ModalWindow
   * -----------
   */
  PROCEDURE ModalWindow(p_asn_line_id VARCHAR2,
                        p_asn_line_split_id VARCHAR2,
                        p_quantity VARCHAR2) IS
     l_language    VARCHAR2(5);
     l_script_name VARCHAR2(240);
     l_org_id      NUMBER;
     l_user_id     NUMBER;
     l_session_id  NUMBER;
     l_responsibility_id NUMBER;
  BEGIN


     IF NOT icx_sec.validatesession THEN
       RETURN;
     END IF;

     l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
     l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
     l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
     l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);
     l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
     l_responsibility_id := icx_sec.getID(icx_sec.PV_RESPONSIBILITY_ID);

     fnd_client_info.set_org_context(l_org_id);

     htp.htmlOpen;
     htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

     htp.headOpen;

     htp.p('<script src="/OA_HTML/POSWUTIL.js"></script>');

     htp.p('<SCRIPT>
           document.write("<title>" +
           top.getTop().FND_MESSAGES["ICX_POS_ASN_SHIPMENT_DETAILS"] + "</title>")
           </SCRIPT>');

     js.scriptOpen;

     js.scriptClose;

     htp.headClose;

     htp.p('<frameset cols="3,*,3" border=0 framespacing=0>');

       -- blue border frame
       htp.p('<frame src="/OA_HTML/US/POSBLBOR.htm"
                     name=borderLeft
                     marginwidth=0
                     frameborder=no
                     scrolling=no>');

       -- new frameset
       htp.p('<frameset rows="3,50,10,*,8,40" border=0 framespacing=0>');

         -- blue border frame
         htp.p('<frame src="/OA_HTML/US/POSBLBOR.htm"');
         htp.p('       name=borderTop');
         htp.p('       marginwidth=0');
         htp.p('       frameborder=no');
         htp.p('       scrolling=no>');

         -- title bar and logo
         htp.p('<frame src="' || l_script_name || '/pos_upper_banner_sv.ModalWindowTitle?p_title=ICX_POS_ASN_SHIPMENT_DETAILS"');
         htp.p('       name=titlebar');
         htp.p('       marginwidth=0');
         htp.p('       frameborder=no');
         htp.p('       scrolling=no>');

         -- upper banner with the curved edge
         htp.p('<frame src="/OA_HTML/US/POSUPBAN.htm"');
         --htp.p('<frame src="' || l_script_name || '/pos_upper_banner_sv.PaintUpperBanner"');
         htp.p('       name=upperbanner');
         htp.p('       marginwidth=0');
         htp.p('       frameborder=no');
         htp.p('       scrolling=no>');


         -- content frame
         htp.p('<frame src="' || l_script_name ||
                 '/pos_asn_details_s.show_details?p_asn_line_id=' ||
                 p_asn_line_id ||
                 '&p_asn_line_split_id=' ||
                 p_asn_line_split_id ||
                 '&p_quantity=' ||
                 p_quantity || '"');
         htp.p('       name=content');
         htp.p('       marginwidth=3');
         htp.p('       frameborder=no');
         htp.p('       scrolling=auto>');

         -- lower banner with curved edge
         htp.p('<frame src="/OA_HTML/US/POSLWBAN.htm"');
         --htp.p('<frame src="' || l_script_name || '/pos_lower_banner_sv.PaintLowerBanner"');
         htp.p('       name=lowerbanner');
         htp.p('       marginwidth=0');
         htp.p('       marginheight=2');
         htp.p('       frameborder=no');
         htp.p('       scrolling=no>');

         -- lower button frame
         htp.p('<frame src="' || l_script_name ||
               '/pos_window_sv.buildbuttons?p_button1Name=ICX_POS_BTN_OK&p_button1Function=acceptShipmentDetails(top)&p_button2Name=&p_button2Function=&p_button3Name=ICX_POS_BTN_CANCEL&p_button3Function=cancelShipmentDetails(top)"');
         htp.p('       name=controlregion');
         htp.p('       marginwidth=0');
         htp.p('       frameborder=no');
         htp.p('       scrolling=no>');

       htp.p('</frameset>');

       -- blue border frame
       htp.p('<frame src="/OA_HTML/US/POSBLBOR.htm"
                     name=borderRight
                     marginwidth=0
                     frameborder=no
                     scrolling=no>');

     htp.p('</frameset>');


    htp.htmlClose;

  END ModalWindow;


END POS_WINDOW;

/
