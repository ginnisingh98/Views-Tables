--------------------------------------------------------
--  DDL for Package Body POS_TOOLBAR_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_TOOLBAR_SV" AS
/* $Header: POSTLBRB.pls 115.3 2001/10/30 16:27:56 pkm ship $*/


  /* -------------- Private Procedures -------------- */
  PROCEDURE InitializeToolbar;
  PROCEDURE CloseToolbar;
  PROCEDURE PaintToolbarEdge;
  PROCEDURE PaintCancel;
  PROCEDURE PaintTitle(p_title VARCHAR2);
  PROCEDURE PaintDivider;
  PROCEDURE PaintSave;
  PROCEDURE PaintPrint;
  PROCEDURE PaintReload;
  PROCEDURE PaintStop;
  PROCEDURE PaintUserPref;
  PROCEDURE PaintHelp;
  PROCEDURE PaintAppsLogo;



  /* -------------- Private Procedure Implementation -------------- */

  /* InitializeToolbar
   * -----------------
   */
  PROCEDURE InitializeToolbar IS
  BEGIN

    htp.p('<!--Outer table containing toolbar and logo cells-->');
    htp.p('<TABLE width=100% Cellpadding=0 Cellspacing=0 border=0>');
    htp.p('<TR>');
    htp.p('  <td width=10></td> <!--spacer cell-->');
    htp.p('  <td>');

  END InitializeToolbar;


  /* CloseToolbar
   * ------------
   */
  PROCEDURE CloseToolbar IS
  BEGIN

    htp.p('</TR>');
    htp.p('</TABLE>');

  END CloseToolbar;


  /* PaintToolbarEdge
   * ----------------
   */
  PROCEDURE PaintToolbarEdge IS
  BEGIN

    htp.p('<tr>');
    htp.p('  <td rowspan=3><img src=/OA_MEDIA/FNDGTBL.gif></td>');
    htp.p('  <td bgcolor=#ffffff height=1 colspan=3>
                <img src=/OA_MEDIA/FNDPX6.gif></td>');
    htp.p('  <td rowspan=3><img src=/OA_MEDIA/FNDGTBR.gif></td>');
    htp.p('</tr>');

  END PaintToolbarEdge;


  /* PaintCancel
   * -----------
   */
  PROCEDURE PaintCancel IS
  BEGIN

    htp.p('<td bgcolor=#cccccc nowrap height=30 align=middle>');
    -- need javascript link here
    htp.p('<a href="javascript:top.cancelClicked()"
            onmousedown = "document.cancel.src=cancel_down.src"
            onmouseover = "document.cancel.src=cancel_over.src"
            onmouseout  = "document.cancel.src=cancel_out.src">');
    htp.p('<script>document.write("<img name = cancel src = /OA_MEDIA/FNDIWHOM.gif border=no align=absmiddle alt = ''" + window.top.FND_MESSAGES["ICX_POS_TLB_CANCEL"] + "''>") </script></a>');

    PaintDivider;
    htp.p('</td>');

  END PaintCancel;


  /* PaintTitle
   * ----------
   */
  PROCEDURE PaintTitle(p_title VARCHAR2) IS
  BEGIN

    htp.p('<td bgcolor=#cccccc nowrap height=30 align=middle>');
    htp.p('  <font class=dropdownmenu>');
    htp.p('  &nbsp; ' ||
          nvl(fnd_message.get_string('ICX', p_title), p_title) ||
          ' &nbsp;');
    htp.p('  </font>');
    htp.p('</td>');

  END PaintTitle;


  /* PaintDivider
   * ------------
   */
  PROCEDURE PaintDivider IS
  BEGIN

    htp.p('<img src=/OA_MEDIA/FNDIWDVD.gif align=absmiddle>');

  END PaintDivider;


  /* PaintSave
   * ---------
   */
  PROCEDURE PaintSave IS
  BEGIN

    -- need javascript link
    --htp.p('<img src=/OA_MEDIA/FNDIWSAV.gif border=no align=absmiddle></a>');
    -- disable button for the mean time
/*
    htp.p('<a href      = ""
            onMouseDown = "document.save.src=save_down.src"
            onMouseOver = "document.save.src=save_over.src"
            onMouseOut  = "document.save.src=save_out.src">');
*/
    htp.p('<script>document.write("<img name = save src = /OA_MEDIA/FNDIWSAD.gif border=no align=absmiddle alt = ''" + window.top.FND_MESSAGES["ICX_POS_TLB_SAVE"] + "''>") </script></a>');

  END PaintSave;


  /* PaintPrint
   * ----------
   */
  PROCEDURE PaintPrint IS
  BEGIN

    -- need javascript link
    --htp.p('<img src=/OA_MEDIA/FNDIWPRT.gif border=no align=absmiddle></a>');
    htp.p('<a href      = "javascript:top.printWindow()"
            onMouseDown = "document.print.src=print_down.src"
            onMouseOver = "document.print.src=print_over.src"
            onMouseOut  = "document.print.src=print_out.src">');
    htp.p('<script>document.write("<img name = print src = /OA_MEDIA/FNDIWPRT.gif border=no align=absmiddle alt = ''" + window.top.FND_MESSAGES["ICX_POS_TLB_PRINT"] + "''>") </script></a>');

  END PaintPrint;


  /* PaintReload
   * -----------
   */
  PROCEDURE PaintReload IS
  BEGIN

    -- need javascript link
    --htp.p('<img src=/OA_MEDIA/FNDIWRLD.gif border=no align=absmiddle></a>');
    htp.p('<a href      = "javascript:top.refreshFrame()"
            onMouseDown = "document.reload.src=reload_down.src"
            onMouseOver = "document.reload.src=reload_over.src"
            onMouseOut  = "document.reload.src=reload_out.src">');
    htp.p('<script>document.write("<img name = reload src = /OA_MEDIA/FNDIWRLD.gif border=no align=absmiddle alt = ''" + window.top.FND_MESSAGES["ICX_POS_TLB_RELOAD"] + "''>") </script></a>');

  END PaintReload;


  /* PaintStop
   * ---------
   */
  PROCEDURE PaintStop IS
  BEGIN

    -- need javascript link
    --htp.p('<img src=/OA_MEDIA/FNDIWSTP.gif border=no align=absmiddle></a>');
    htp.p('<a href      = "javascript:top.stopLoading()"
            onMouseDown = "document.stop.src=stop_down.src"
            onMouseOver = "document.stop.src=stop_over.src"
            onMouseOut  = "document.stop.src=stop_out.src">');
    htp.p('<script>document.write("<img name = stop src = /OA_MEDIA/FNDIWSTP.gif border=no align=absmiddle alt = ''" + window.top.FND_MESSAGES["ICX_POS_TLB_STOP"] + "''>") </script></a>');

  END PaintStop;


  /* PaintUserPref
   * -------------
   */
  PROCEDURE PaintUserPref IS
  BEGIN

    -- need javascript link
    -- htp.p('<img src=/OA_MEDIA/FNDIWPPR.gif border=no align=absmiddle></a>');
-- disable button for the mean time...
/*
    htp.p('<a href      = ""
            onMouseDown = "document.prefs.src=prefs_down.src"
            onMouseOver = "document.prefs.src=prefs_over.src"
            onMouseOut  = "document.prefs.src=prefs_out.src">');
*/
    htp.p('<script>document.write("<img name = prefs src = /OA_MEDIA/FNDIWPPD.gif border=no align=absmiddle alt = ''" + window.top.FND_MESSAGES["ICX_POS_TLB_PREFS"] + "''>") </script></a>');

  END PaintUserPref;


  /* PaintHelp
   * ---------
   */
  PROCEDURE PaintHelp IS
  BEGIN

    -- iHelp javascript link
    js.scriptOpen;
    icx_admin_sig.help_win_script('smp_top',
                                  icx_sec.getID(icx_sec.PV_LANGUAGE_CODE));
    js.scriptClose;

    htp.p('<a href      = "javascript:help_window()"
            onMouseDown = "document.help.src=help_down.src"
            onMouseOver = "document.help.src=help_over.src"
            onMouseOut  = "document.help.src=help_out.src">');
    htp.p('<script>document.write("<img name = help src = /OA_MEDIA/FNDIWHLP.gif border=no align=absmiddle alt = ''" + window.top.FND_MESSAGES["ICX_POS_TLB_HELP"] + "''>") </script></a>');

  END PaintHelp;


  /* PaintToolbarBottom
   * ------------------
   */
  PROCEDURE PaintToolbarBottom IS
  BEGIN

    htp.p('<tr>');
    htp.p('  <td bgcolor=#666666 height=1 colspan=3>
                <img src=/OA_MEDIA/FNDPX1.gif></td>');
    htp.p('</tr>');

  END PaintToolbarBottom;



  /* PaintAppsLogo
   * -------------
   */
  PROCEDURE PaintAppsLogo IS
  BEGIN

     htp.p('<TD rowspan=5 width=100% align=right>
            <IMG src=/OA_MEDIA/FNDLWAPP.gif></TD>');

  END PaintAppsLogo;





  /* -------------- Public Procedure Implementation -------------- */

  /* PaintToolBar
   * ------------
   */
  PROCEDURE PaintToolBar(p_title VARCHAR2) IS
  BEGIN

      IF NOT icx_sec.validatesession THEN
         RETURN;
      END IF;

      htp.htmlOpen;
-- don't think i really need this title
      htp.title('Web Suppliers Toolbar');

      htp.headOpen;
      htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

      htp.p('  <script src="/OA_HTML/POSICONS.js" language="JavaScript">');
      htp.p('  </script>');

      htp.headClose;

      htp.bodyOpen(NULL,'bgcolor=#336699');

      InitializeToolbar;

        htp.p('<!--inner table to define toolbar-->');
        htp.p('<table Cellpadding=0 Cellspacing=0 Border=0>');
        PaintToolbarEdge;
        PaintCancel;

        PaintTitle(p_title);

        htp.p('<td bgcolor=#cccccc nowrap height=30 align=middle>');
        PaintDivider;
--        PaintSave;
        PaintPrint;
        PaintDivider;

        PaintReload;
        PaintStop;
        PaintDivider;

--        PaintUserPref;
--        PaintDivider;
        PaintHelp;

        PaintToolbarBottom;
        htp.p('</td>');
        htp.p('</table>');


      PaintAppsLogo;

      CloseToolbar;


      htp.bodyClose;
      htp.htmlClose;

  END PaintToolBar;



END POS_TOOLBAR_SV;

/
