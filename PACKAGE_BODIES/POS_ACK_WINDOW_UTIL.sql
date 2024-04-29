--------------------------------------------------------
--  DDL for Package Body POS_ACK_WINDOW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ACK_WINDOW_UTIL" AS
/* $Header: POSWNDUB.pls 115.4 2001/06/05 18:49:50 pkm ship      $ */

  /* DialogBox
   * ---------
   */
  PROCEDURE DialogBox (l_rows in varchar2 default null) IS
    l_script_name VARCHAR2(240);
    l_msg	  VARCHAR2(240);
    l_title	  VARCHAR2(2000);
  BEGIN

    l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
    pos_ack_search.veera_debug('Rows: From Dialog Box:' || l_rows);

     IF NOT icx_sec.validatesession THEN
    RETURN;
  END IF;

    htp.htmlOpen;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

    htp.headOpen;

    htp.p('<script src="/OA_HTML/POSWUTIL.js"></script>');
    htp.p('<script src="/OA_HTML/POSEVENT.js"></script>');

    l_title := fnd_message.get_string('ICX','ICX_POS_BTN_CANCEL');

    htp.p('<title>' || l_title || '</title>');


    js.scriptOpen;

    htp.p('
  	  function drawMe(doc, p_string)
  	  {
    	    var htmlString = "<html>" +
                             "<LINK REL=STYLESHEET HREF=/OA_HTML/US/POSSTYLE.css TYPE=text/css>" +
                             "<body bgcolor=#cccccc><center>" +
                             "<table width=100% height=100%>" +
                             "<tr><td width=20% align=center valign=center>" +
                                 "<img src=/OA_MEDIA/FNDIWARN.gif>" +
                             "</td><td valign=center><font class=datablack>" +
                           p_string +
                             "</font></td></tr></table></body></html>" ;
    	    doc.write(htmlString);
    	    doc.close();
  	  }

	 function continueWork(p_win)
	  {
	   p_win.close();
	  }

	  function discard(p_win)
	  {
	    p_win.close();
	  }

    ');

    js.scriptClose;

    htp.headClose;

    htp.p('
			<frameset cols="3,*,3" border=0>');
    		htp.p('
				<frame
					src=/OA_HTML/US/POSBLBOR.htm
					name=borderLeft
					marginwidth=0
					scrolling=no> ');
    		htp.p('
				<frameset rows="15,*,7,45" border=0 >');
    			htp.p('
					<frame
                  		src=/OA_HTML/US/POSDLTOP.htm
        	  			name=alert_cancel_top
        	  			marginwidth=0
       		  			scrolling=no> ');
				if l_rows = '-1' then
					-- called from modify promise date
					l_msg :=  fnd_message.get_string('ICX','ICX_POS_UPD_SUBMIT');
				else
					l_msg :=  fnd_message.get_string('ICX','ICX_POS_ACK_TOTAL_PO_SUB');
					l_msg := l_rows || ' ' || l_msg;
				end if;
    			htp.p('
					<frame
        	  			src="javascript:top.drawMe(document' ||', '''|| l_msg || '''' ||');"
        	  			name=alert_cancel_content
        	  			marginwidth=6
		  				marginheight=2
       		  			scrolling=auto> ');

    				-- lower banner with curved edge
    			htp.p('
					<frame src="/OA_HTML/US/POSLWBAN.htm"');
    					htp.p(' name=lowerbanner');
    					htp.p(' marginwidth=0');
    					htp.p(' marginheight=2');
    					htp.p(' frameborder=no');
    					htp.p(' scrolling=no> ');

    			htp.p('
					<frame src="' || l_script_name ||
          				'/pos_ack_window_util.buildbuttons?p_button1Name=ICX_POS_EXIT&p_button1Function=discard(top)&p_button2Name=&p_button2Function=&p_button3Name=ICX_POS_CONTINUE_WORKING&p_button3Function=continueWork(top)"');

    					htp.p('	name=alert_cancel_bottom');
    					htp.p('     marginwidth=0');
    					htp.p('     scrolling=no >');
    		htp.p('
				</frameset> ');

    		htp.p('
				<frame src=/OA_HTML/US/POSBLBOR.htm
	       			name=borderRight
	       			marginwidth=0
	       			marginheight=0
	       			scrolling=no> ');

    	htp.p('
			</frameset>');

    htp.htmlClose;

  END DialogBox;


  /* BuildButtons
   * ------------
   */
  PROCEDURE BuildButtons(p_button1Name VARCHAR2, p_button1Function VARCHAR2,
                         p_button2Name VARCHAR2, p_button2Function VARCHAR2,
                         p_button3Name VARCHAR2, p_button3Function VARCHAR2)
	      IS
	       l_msg	  VARCHAR2(2000);
	      BEGIN

	      IF NOT icx_sec.validatesession THEN
	      RETURN;
	      END IF;

    htp.htmlOpen;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

    htp.headOpen;
    htp.headClose;
    htp.bodyOpen(NULL, 'bgcolor=#336699');

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
    htp.p('<a href="javascript:top.' || p_button1Function || ';">');
    htp.p('<font class=button>');
	  htp.p('<SCRIPT>');
	  l_msg := fnd_message.get_string('ICX',p_button1Name);
	    htp.p('document.write("' || l_msg ||'")');
    htp.p('</SCRIPT></font></td>');


    IF (p_button2Name is NOT NULL) THEN
      htp.p('<td bgcolor=#cccccc height=20 nowrap>');
      htp.p('<a href="javascript:top.' || p_button2Function || ';">');
      htp.p('<font class=button>');
	  htp.p('<SCRIPT>');

	  l_msg := fnd_message.get_string('ICX',p_button2Name);
	  htp.p('document.write("' || l_msg ||'")');

      htp.p('</SCRIPT></font></td>');
    ELSE
      htp.p('<td></td>');
	  END IF;


    htp.p('<td bgcolor=#cccccc height=20 nowrap>');
    htp.p('<a href="javascript:top.' || p_button3Function || ';">');
    htp.p('<font class=button>');
	  htp.p('<SCRIPT>');

	   l_msg := fnd_message.get_string('ICX',p_button3Name);
	  htp.p('document.write("' || l_msg ||'")');

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

END POS_ACK_WINDOW_UTIL;

/
