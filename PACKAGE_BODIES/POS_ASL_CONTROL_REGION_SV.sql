--------------------------------------------------------
--  DDL for Package Body POS_ASL_CONTROL_REGION_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ASL_CONTROL_REGION_SV" AS
/* $Header: POSASLCB.pls 115.1 1999/11/12 14:16:12 pkm ship     $*/


  /* -------------- Private Procedures -------------- */
  PROCEDURE InitializeRegion;
  PROCEDURE CloseRegion;
  PROCEDURE PaintButtons(p_position VARCHAR2,p_mode VARCHAR2 DEFAULT NULL);
  PROCEDURE PaintButtonTops(p_position VARCHAR2);
  PROCEDURE PaintCancelButton;
  PROCEDURE PaintBackButton(p_position VARCHAR2);
  PROCEDURE PaintRoadMap(p_position VARCHAR2);
  PROCEDURE PaintNextButton(p_position VARCHAR2);
  PROCEDURE PaintSubmitbutton(p_position VARCHAR2,p_mode VARCHAR2 DEFAULT NULL);
  PROCEDURE PaintButtonBottoms;


  /* -------------- Private Procedure Implementation -------------- */

  /* InitializeRegion
   * ----------------
   */
  PROCEDURE InitializeRegion IS
  BEGIN

    htp.p('
          <table width=100% cellpadding=0 cellspacing=0 border=0>

          <tr>
          <td width=100%><img src=/OA_MEDIA/FNDPX3.gif></td>
          </tr>

          </TABLE>

          <!-- a table is built for the control buttons so that the cell can be right justified-->

          <TABLE bgcolor=#336699 width=100% cellpadding=0 cellspacing=0 border=0>
          <TR><td height=3><img src=/OA_MEDIA/FNDPX3.gif></td></TR>
          <TR>
          <TD align=right>
          <!-- button table for the lower buttons.  See notes above on strucure-->
          <table cellpadding=0 cellspacing=0 border=0>

         ');

  END InitializeRegion;


  /* CloseBanner
   * -----------
   */
  PROCEDURE CloseRegion IS
  BEGIN

    htp.p('
          </table>
          </td></tr>
          </table>
          ');
--     htp.tableClose;

  END CloseRegion;


  /* PaintButtonTops
   * ---------------
   */
  PROCEDURE PaintButtonTops(p_position VARCHAR2) IS
  BEGIN

    htp.p('<tr>');


    htp.p('<!- Cancel button -->
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif></td>');

    htp.p('<td width=15 rowspan=5></td>');


/*    htp.p('<!- Back button -->');
    IF (upper(p_position) = 'SELECT') THEN
      htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBPSD.gif></td>');
    ELSE
      htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBPS.gif></td>');
    END IF;
    htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
    htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBSQRR.gif></td>');

    htp.p('<td width=3 rowspan=5></td>');

    htp.p('<!-- where you are -->
           <td rowspan=5><img src=/OA_MEDIA/FNDBWHRL.gif></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
           <td rowspan=5><img src=/OA_MEDIA/FNDBWHRR.gif></td>');

    htp.p('<td width=3 rowspan=5></td>');

    htp.p('<!-- Next button -->');
    htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBSQRL.gif></td>');
    htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
    IF (upper(p_position) = 'REVIEW') THEN
      htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBNSD.gif></td>');
    ELSE
      htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBNS.gif></td>');
    END IF;
*/
    htp.p('<td width=15 rowspan=5></td>');

    htp.p('<!- Finish button -->
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
           <td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif></td>');

    htp.p('<td width=10 rowspan=5></td>');

    htp.p('</tr>');

    htp.p('
           <tr>
           <td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>
           <td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>
           <td></td>
           <td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>
           <td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>
           </tr>
          ');

  END PaintButtonTops;


  PROCEDURE PaintButtons(p_position VARCHAR2,p_mode VARCHAR2 DEFAULT NULL) IS
  BEGIN

    PaintButtonTops(p_position);
    htp.p('<tr>');
    PaintCancelButton;
--    PaintBackButton(p_position);
--    PaintRoadMap(p_position);
--    PaintNextButton(p_position);
    PaintSubmitButton(p_position,p_mode);
    htp.p('</tr>');
    PaintButtonBottoms;

  END PaintButtons;

  /* PaintCancelButton
   * -----------------
   * if no callback function, disable button.
   */
  PROCEDURE PaintCancelButton
  IS
  BEGIN

    htp.p('<td bgcolor=#cccccc height=20 nowrap>');
    htp.p('<a href="javascript:top.cancelClicked()">');
    htp.p('<font class=button>');
    htp.p('<SCRIPT>
           document.write(top.FND_MESSAGES["ICX_POS_BTN_CANCEL"])
           </SCRIPT>');
    htp.p('</font></a></td>');

  END PaintCancelButton;


  PROCEDURE PaintBackButton(p_position VARCHAR2) IS
  BEGIN

    htp.p('<td bgcolor=#cccccc height=20 nowrap>');

    IF (upper(p_position) = 'SELECT') THEN
      htp.p('<font class=disabledbutton>');
    ELSE
      htp.p('<a href="javascript:top.backClicked()">');
      htp.p('<font class=button>');
    END IF;

    htp.p('<SCRIPT>
           document.write(top.FND_MESSAGES["ICX_POS_BTN_BACK"])
           </SCRIPT>');
    htp.p('</font></td>');

  END PaintBackButton;


  PROCEDURE PaintRoadMap(p_position VARCHAR2) IS
  BEGIN

    htp.p('<td height=20 nowrap><font class=promptwhite>');

    IF (upper(p_position) = 'SELECT') THEN
      htp.p(' <b><SCRIPT>
              document.write(top.FND_MESSAGES["ICX_POS_ROADMAP_SELECT"])
              </SCRIPT></b> &gt; ');
      htp.p(' <SCRIPT>
              document.write(top.FND_MESSAGES["ICX_POS_ROADMAP_EDIT"])
              </SCRIPT> &gt; ');
      htp.p(' <SCRIPT>
              document.write(top.FND_MESSAGES["ICX_POS_ROADMAP_REVIEW"])
              </SCRIPT> ');
    ELSIF (upper(p_position) = 'EDIT') THEN
      htp.p(' <SCRIPT>
              document.write(top.FND_MESSAGES["ICX_POS_ROADMAP_SELECT"])
              </SCRIPT> &gt; ');
      htp.p(' <b><SCRIPT>
              document.write(top.FND_MESSAGES["ICX_POS_ROADMAP_EDIT"])
              </SCRIPT></b> &gt; ');
      htp.p(' <SCRIPT>
              document.write(top.FND_MESSAGES["ICX_POS_ROADMAP_REVIEW"])
              </SCRIPT> ');
    ELSIF (upper(p_position) = 'REVIEW') THEN
      htp.p(' <SCRIPT>
              document.write(top.FND_MESSAGES["ICX_POS_ROADMAP_SELECT"])
              </SCRIPT> &gt; ');
      htp.p(' <SCRIPT>
              document.write(top.FND_MESSAGES["ICX_POS_ROADMAP_EDIT"])
              </SCRIPT> &gt; ');
      htp.p(' <b><SCRIPT>
              document.write(top.FND_MESSAGES["ICX_POS_ROADMAP_REVIEW"])
              </SCRIPT></b> ');
    END IF;

    htp.p('</font></td>');

  END PaintRoadMap;


  PROCEDURE PaintNextButton(p_position VARCHAR2) IS
  BEGIN

    htp.p('<td bgcolor=#cccccc height=20 nowrap>');

    IF (upper(p_position) = 'REVIEW') THEN
      htp.p('<font class=disabledbutton>');
    ELSE
      htp.p('<a href="javascript:top.nextClicked()">');
      htp.p('<font class=button>');
    END IF;

    htp.p('<SCRIPT>
           document.write(top.FND_MESSAGES["ICX_POS_BTN_NEXT"])
           </SCRIPT>');
    htp.p('</font></a></td>');

  END PaintNextButton;


  PROCEDURE PaintSubmitButton(p_position VARCHAR2,
		              p_mode VARCHAR2 DEFAULT NULL) IS
  BEGIN

    htp.p('<td bgcolor=#cccccc height=20 nowrap>');

    IF (upper(p_position) = 'SELECT') THEN
      htp.p('<font class=disabledbutton>');
    ELSE
      if (upper(p_mode) = 'WF') then
        htp.p('<a href="javascript:top.AslSubmitClicked(top)">');
      else
        htp.p('<a href="javascript:top.AslSubmitClicked(top.content)">');
	  end if;
      htp.p('<font class=button>');
    END IF;

    htp.p('<SCRIPT>
           document.write(top.FND_MESSAGES["ICX_POS_BTN_FINISH"])
           </SCRIPT>');
    htp.p('</font></td>');

  END PaintSubmitButton;


  PROCEDURE PaintButtonBottoms IS
  BEGIN

    htp.p('
           <tr>
           <td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>
           <td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>
           <td></td>
           <td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>
           <td bgcolor=#666666><img src=/OA_MEDIA/FNDPX3.gif></td>
           </tr>

           <tr>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
           <td bgcolor=#6699cc><img src=/OA_MEDIA/FNDPX4.gif></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>
           <td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>

           </tr>

           <TR><td colspan=2 height=30><img src=/OA_MEDIA/FNDPX3.gif></td></TR>
         ');

  END PaintButtonBottoms;



  /* -------------- Public Procedure Implementation -------------- */

  /* PaintControlRegion
   * ------------------
   */
  PROCEDURE PaintControlRegion(p_position VARCHAR2,
			       p_mode VARCHAR2 DEFAULT NULL) IS
  BEGIN

    htp.htmlOpen;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

    htp.title('Web Suppliers Control Region');
    htp.headOpen;
    htp.headClose;

    htp.bodyOpen(NULL, 'bgcolor=#336699');

    InitializeRegion;
    PaintButtons(p_position,p_mode);
    CloseRegion;

    htp.bodyClose;
    htp.htmlClose;

  END PaintControlRegion;


END POS_ASL_CONTROL_REGION_SV;

/
