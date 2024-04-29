--------------------------------------------------------
--  DDL for Package Body POS_UPPER_BANNER_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_UPPER_BANNER_SV" AS
/* $Header: POSUPBNB.pls 115.2 2001/10/22 17:09:41 pkm ship $*/


  /* -------------- Private Procedures -------------- */
  PROCEDURE InitializeBanner(p_product VARCHAR2, p_title VARCHAR2);
  PROCEDURE CloseBanner;


  /* -------------- Private Procedure Implementation -------------- */

  /* InitializeBanner
   * ----------------
   */
  PROCEDURE InitializeBanner(p_product VARCHAR2, p_title VARCHAR2) IS
  BEGIN

    htp.p('<table width=100% cellpadding=0 cellspacing=0 border=0>');
    -- paint title
    htp.p('<tr bgcolor=#336699>');
    htp.p('<td valign=bottom nowrap><font class=containertitle>');
    htp.p('&nbsp; ' || nvl(fnd_message.get_string(p_product, p_title), p_title));
    htp.p('</font></td></tr>');
    -- paint banner
    htp.p('<tr bgcolor=#cccccc>');
    htp.p('<TD align=left valign=top><img src=/OA_MEDIA/FNDCTTL.gif></TD>');
    htp.p('<TD bgcolor=#cccccc height=50><img src=/OA_MEDIA/FNDPXG5.gif></td>');
    htp.p('<TD valign=top align=right><img src=/OA_MEDIA/FNDCTTR.gif></TD>');
    htp.p('</tr>');

  END InitializeBanner;


  /* CloseBanner
   * -----------
   */
  PROCEDURE CloseBanner IS
  BEGIN

     htp.tableClose;

  END CloseBanner;


  /* -------------- Public Procedure Implementation -------------- */

  /* PaintUpperBanner
   * ----------------
   */
  PROCEDURE PaintUpperBanner(p_product VARCHAR2, p_title VARCHAR2) IS
  BEGIN

    IF NOT icx_sec.validatesession THEN
      RETURN;
    END IF;

    htp.htmlOpen;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');
--    htp.p('<LINK REL=STYLESHEET HREF="/OA_HTML/US/PORSTYLE.css" TYPE="text/css">');
    htp.title('Web Suppliers Upper Banner');
    htp.headOpen;
    htp.headClose;

    htp.bodyOpen(NULL, 'bgcolor=#336699');

    InitializeBanner(p_product, p_title);
    CloseBanner;

    htp.bodyClose;
    htp.htmlClose;

  END PaintUpperBanner;



  /* ModalWindowTitle
   * ----------------
   * p_title needs to be a message name!!!
   */
  PROCEDURE ModalWindowTitle(p_title VARCHAR2) IS
  BEGIN

    htp.htmlOpen;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');
    htp.headOpen;
    htp.headClose;

    htp.bodyOpen(NULL, 'bgcolor=#336699');

    htp.p('<table cellpadding=0 cellspacing=0 border=0 width=100%>
           <tr>
           <td align=left valign=bottom nowrap><font class=containertitle>');

    htp.p('<SCRIPT>');
    htp.p('document.write(top.getTop().FND_MESSAGES["' ||
          p_title || '"])');
    htp.p('</SCRIPT></font></td>');

    htp.p('
           <td align=right><img src=/OA_MEDIA/FNDLNAPP.gif></td>

           </tr>
           </table>');

    htp.bodyClose;
    htp.htmlClose;

  END ModalWindowTitle;



END POS_UPPER_BANNER_SV;

/
