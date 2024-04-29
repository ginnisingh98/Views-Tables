--------------------------------------------------------
--  DDL for Package Body POS_LOWER_BANNER_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_LOWER_BANNER_SV" AS
/* $Header: POSLWBNB.pls 115.0 99/08/20 11:09:37 porting sh $*/


  /* -------------- Private Procedures -------------- */
  PROCEDURE InitializeBanner;
  PROCEDURE CloseBanner;


  /* -------------- Private Procedure Implementation -------------- */

  /* InitializeBanner
   * ----------------
   */
  PROCEDURE InitializeBanner IS
  BEGIN

    htp.p('<table width=100% cellpadding=0 cellspacing=0 border=0>');
    htp.p('<tr>');
    htp.p('  <td rowspan=3><img src=/OA_MEDIA/FNDCTBL.gif></td>');
    htp.p('  <td colspan=2 bgcolor=#cccccc height=5 width=1000>');
    htp.p('     <img src=/OA_MEDIA/FNDPXG5.gif height=2></td>');
    htp.p('  <td rowspan=3><img src=/OA_MEDIA/FNDCTBR.gif></td>');
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

  /* PaintLowerBanner
   * ----------------
   */
  PROCEDURE PaintLowerBanner IS
  BEGIN

    htp.htmlOpen;
    htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');
--    htp.p('<LINK REL=STYLESHEET HREF="/OA_HTML/US/PORSTYLE.css" TYPE="text/css">');
    htp.title('Web Suppliers Bottom Banner');
    htp.headOpen;
    htp.headClose;

    htp.bodyOpen(NULL, 'bgcolor=#cccccc');

    InitializeBanner;
    CloseBanner;

    htp.bodyClose;
    htp.htmlClose;

  END PaintLowerBanner;


END POS_LOWER_BANNER_SV;

/
