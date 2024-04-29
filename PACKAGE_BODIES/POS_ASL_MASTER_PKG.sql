--------------------------------------------------------
--  DDL for Package Body POS_ASL_MASTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ASL_MASTER_PKG" AS
/* $Header: POSASLMB.pls 115.2 2001/10/29 17:18:31 pkm ship $*/


   /* ShowFrameSet
    * ------------
    */
   PROCEDURE ShowFrameSet(p_respID VARCHAR2) IS
     l_language    VARCHAR2(5);
     l_script_name VARCHAR2(240);
     l_org_id	   NUMBER;
     l_user_id	   NUMBER;
     l_session_id  NUMBER;
   BEGIN

     -- Bug 1891728 mji
     POS_INIT_SESSION_PKG.InitSession(p_respID);

     l_session_id := icx_sec.getID(icx_sec.PV_SESSION_ID);
     l_org_id := icx_sec.getID(icx_sec.PV_ORG_ID);
     l_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
     l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
     l_user_id := icx_sec.getID(icx_sec.PV_WEB_USER_ID);

     htp.htmlOpen;
     htp.title(fnd_message.get_string('ICX', 'POS_ASL_ATTRIBUTES'));


     htp.headOpen;
     icx_util.copyright;

     htp.linkRel('STYLESHEET', '/OA_HTML/US/POSSTYLE.css');

     js.scriptOpen;
     pos_global_vars_sv.InitializeMessageArray;
     pos_global_vars_sv.InitializeOtherVars(l_script_name);
     js.scriptClose;
     htp.p('  <script src="/OA_HTML/POSCUTIL.js" language="JavaScript">');
     htp.p('  </script>');
     htp.p('  <script src="/OA_HTML/POSWUTIL.js" language="JavaScript">');
     htp.p('  </script>');
     htp.p('  <script src="/OA_HTML/POSEVENT.js" language="JavaScript">');
     htp.p('  </script>');
     htp.p('  <script src="/OA_HTML/posaslet.js" language="JavaScript">');
     htp.p('  </script>');
     --icx_util.LOVscript;


     htp.headClose;
--     htp.bodyOpen(NULL, 'bgcolor=#336699');


     -- Here, we are using nested framesets.  The illusion that
     -- we want to achieve is as follows:
     --
     -- ************************************
     -- *	     toolbar		   *
     -- ************************************
     -- *  *	    upperbanner 	*  *
     -- *  ******************************  *
     -- *  *	      search		*  *
     -- *  ******************************  *
     -- *  *	      results		*  *
     -- *  ******************************  *
     -- *  *	    lowerbanner 	*  *
     -- ************************************
     -- *	    controlregion	   *
     -- ************************************

     -- these partitions should probably be in percentages
     htp.p('<frameset rows="50,*,40" border=0>');

       -- Toolbar frame
       htp.p('<frame src="' || l_script_name || '/pos_toolbar_sv.PaintToolbar?p_title=POS_ASL_ATTRIBUTES"');

       htp.p('	     name=toolbar');
       htp.p('	     marginwidth=6');
       htp.p('	     marginheight=2');
       htp.p('	     scrolling=no>');

       -- these partitions should probably be in percentages
       htp.p('<frameset cols="3,*,3" border=0>');

	 -- blue border frame
	 htp.p('<frame src="/OA_HTML/US/POSBLBOR.htm"
		       name=borderLeft
		       marginwidth=0
		       marginheight=0
		       scrolling=no>');
	 -- these partitions should probably be in percentages
	 htp.p('<frameset rows="15,*,5" border=0>');

	   -- upper banner frame
	   htp.p('<frame src="/OA_HTML/US/POSUPBAN.htm"');

--	     htp.p('<frame src="' || l_script_name || '/pos_upper_banner_sv.PaintUpperBanner?p_product=ICX&p_title=POS_ASL_ATTRIBUTES"');

	   htp.p('	 name=upperbanner');
	   htp.p('	 marginwidth=0');
	   htp.p('	 marginheight=0');
	   htp.p('	 scrolling=no>');

	   -- search frame
	   htp.p('<frame src="' || l_script_name || '/pos_asl_modifiers_search_pkg.search_page"');

	   htp.p('	 name=content');
	   htp.p('	 marginwidth=0');
	   htp.p('	 marginheight=0');
	   htp.p('	 scrolling=no>');

	   -- ASL modifiers frame
	   --htp.p('<frame src="' || l_script_name || '/pos_asl_search_pkg.asl_order_modifiers_frame"');

	   -- lower banner frame
	   htp.p('<frame src="/OA_HTML/US/POSLWBAN.htm"');
	   htp.p('	 name=lowerbanner');
	   htp.p('	 marginwidth=0');
	   htp.p('	 marginheight=0');
	   htp.p('	 scrolling=no>');

	 htp.p('</frameset>');

	 -- blue border frame
	 htp.p('<frame src="/OA_HTML/US/POSBLBOR.htm"
		       name=borderRight
		       marginwidth=0
		       marginheight=0
		       scrolling=no>');

       htp.p('</frameset>');

       -- control region frame
       htp.p('<frame src="' || l_script_name || '/pos_asl_control_region_sv.PaintControlRegion?p_position=SUBMIT"');

       htp.p('	     name=controlregion');
       htp.p('	     marginwidth=0');
       htp.p('	     marginheight=0');
       htp.p('	     scrolling=no>');

     htp.p('</frameset>');


--    htp.bodyClose;
    htp.htmlClose;

   END ShowFrameSet;

END POS_ASL_MASTER_PKG;


/
