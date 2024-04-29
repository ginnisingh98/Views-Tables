--------------------------------------------------------
--  DDL for Package Body OKI_ALERT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_ALERT_UTIL_PVT" AS
/* $Header: OKIRAUTB.pls 115.12 2002/04/30 16:37:01 pkm ship     $*/
/*---------------------------------------------------------------------------+
|                                                                            |
|  PACKAGE: OKI_ALERT_UTIL                                                   |
|                                                                            |
|  								             |
|  FILE   : OKIRAUTB.pls                                                     |
|                                                                            |
*-------------------------------------------------------------------------- */
--------------------------------------------------------------------------------
--
--  HISTORY:
--  03-DEC-2001 brrao    created
--  29-JAN-2001 mezra    Added get_gv_prev_x_qtr_end_date and dflt_gv_qed for
--                       functions for the oki_expiration_graph graph component
--                       for the bins.
--  04-FEB-2002 mezra    Change get_gv_prev_x_qtr_end_date and dflt_gv_qed
--                       function to remove hard coded 'DD-MON-YY format
--                       mask.
--  30-APR-2002 mezra    Added dbdrv command and correct header syntax.
--
--------------------------------------------------------------------------------



   PROCEDURE Send_email      (ERRBUF              OUT VARCHAR2
                             ,RETCODE             OUT NUMBER
                             ,subject 			IN   VARCHAR2
	        	     ,body 			IN   VARCHAR2
                             ,email_list 		IN   VARCHAR2 )
   IS
   return_status VARCHAR2(1)   ;
   x_msg_count   number        ;
   x_msg_data    varchar2(2000);

   BEGIN

   OKI_ALERT_UTIL_PVT.Send_Email (
	                p_api_version	=>  1,
	                p_commit		=>  FND_API.g_false,
	                p_init_msg_list	=>  FND_API.g_false,
                        email_list 	    =>  email_list,
                        subject 		=>  subject,
	                body 			=>  body,
                        return_status   => return_status,
                	x_msg_count	    => x_msg_count,
                	x_msg_data		=> x_msg_data  );
    --IF return_status ='S'then
    --   dbms_output.put_line('its success');
    --END IF;
    END SEND_EMAIL ;

    PROCEDURE Send_Email (
	                p_api_version		IN 	NUMBER,
	                p_commit			IN	VARCHAR2 := FND_API.g_false,
	                p_init_msg_list	IN	VARCHAR2 := FND_API.g_false,
                     email_list 		IN   VARCHAR2,
                     subject 			IN   VARCHAR2,
	        		 body 			 IN   VARCHAR2,
                     return_status      OUT  VARCHAR2,
                	 x_msg_count		OUT	NUMBER,
                	 x_msg_data		OUT	VARCHAR2
			)
        IS

                wf_itemkey_seq INTEGER;
			 wf_itemkey VARCHAR2(30);
			 role_name VARCHAR2(30);
			 role_display_name VARCHAR2(30);
        BEGIN
          fnd_file.put_line(  which => fnd_file.log
                            , buff => 'Alert Subject   :'||subject);
          fnd_file.put_line(  which => fnd_file.log
                            , buff => 'Alert Body      :'||body);
          fnd_file.put_line(  which => fnd_file.log
                            , buff => 'Email List      :'||email_list);

                return_status := FND_API.g_ret_sts_success;


        select OKI_ALERT_WF_S1.NEXTVAL into wf_itemkey_seq from dual;
	   wf_itemkey := 'OKI_MAIL_' || wf_itemkey_seq;

	   role_name := 'OKI_EMAIL_LIST_' || wf_itemkey_seq ;
	   role_display_name := 'OKI_EMAIL_LIST_' || wf_itemkey_seq ;

        wf_directory.CreateAdHocUser(
						   name => role_name,
						   display_name => role_display_name,
						   notification_preference => 'MAILTEXT',
                           email_address => email_list,
						   expiration_date => sysdate + 1
						  );

	   wf_engine.CreateProcess (
						   itemtype => 'OKI_MAIL',
						   itemkey  =>  wf_itemkey,
						   process  => 'OKI_SEND_EMAIL'
						  );
	   wf_engine.SetItemUserKey (
						   itemtype => 'OKI_MAIL',
						   itemkey  =>  wf_itemkey,
						   userkey  => 'OKI Alert Notification' || wf_itemkey_seq
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'OKI_MAIL',
						   itemkey  =>  wf_itemkey,
						   aname    => 'ROLE_TO_NOTIFY',
						   avalue   =>  role_name
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'OKI_MAIL',
						   itemkey  =>  wf_itemkey,
						   aname    => 'NOTIFICATION_SUBJECT',
						   avalue   =>  subject
						  );
	   wf_engine.SetItemAttrText (
						   itemtype => 'OKI_MAIL',
						   itemkey  =>  wf_itemkey,
						   aname    => 'NOTIFICATION_BODY',
						   avalue   =>  body
						  );
	   wf_engine.SetItemOwner (
						   itemtype => 'OKI_MAIL',
						   itemkey  =>  wf_itemkey,
						   owner    =>  role_name
						 );
	   wf_engine.StartProcess (
						   itemtype => 'OKI_MAIL',
						   itemkey  =>  wf_itemkey
						 );

        EXCEPTION
                When others then

                return_status := FND_API.g_ret_sts_error;
                x_msg_count := 0;

			 wf_core.context('OKI_ALERT_WF',
						  'Send_Email',
		                   email_list,
						   subject,
						   body
						 );
                raise;
   END Send_Email;



   PROCEDURE myprint(p_str IN VARCHAR2)
   IS
   BEGIN
--      UTL_FILE.PUT_LINE(g_output_stream,p_str);
      fnd_file.put_line(  which => fnd_file.output
                        , buff =>  p_str);

   END; -- myprint


   procedure create_page( p_title IN varchar2) IS
   BEGIN
	myprint('<HTML>');
	myprint('<HEAD>');
	myprint('<TITLE>');
	myprint(p_title);
	myprint('</TITLE>');
        myprint('<META http-equiv="Expires" content="0">');  -- for no caching of page..
	myprint('<link rel="stylesheet" href="'||g_oki_parent_url||'/jtfucss.css">');
	myprint('</HEAD>');
	myprint('<BODY text=#000000 bgColor=#ffffff>');
   END;

   procedure create_mainheader( p_title IN varchar2,p_run_date IN DATE) IS
   BEGIN
	myprint('<TABLE width="100%">');
	myprint('<TBODY><tr>');
	myprint('<TD bgColor=#336699 colSpan=2>
		 <FONT face="arial, helvetica, sans-serif";>
		 <FONT color=#ffffff><FONT size=+1 ;>');
	myprint('<A name="report_top">' ||p_title || ' as of '||
	           to_char(p_run_date));
	myprint('</a></FONT></FONT></FONT></TD></TR></TBODY></TABLE><BR>');
   END;


   procedure reportHeaderCell(p_str IN VARCHAR2, p_ref in VARCHAR2) IS
   BEGIN
	myprint('<TABLE cellSpacing=0 cellPadding=0 width="100%" border=0><TBODY>');
	myprint('<TR><TD width="70%" bgColor=#f7f7e7><b>
                 <font face="arial, helvetica, sans-serif" color="#999966" size="+0">
                 <a name="'||p_ref||'">'||p_str||'</a></font></b></TD></TR>');
	myprint('<TR><TD colSpan=2 height=25>
                 <FONT face="arial, helvetica, sans-serif" color=#336699 size=-1>&'||'nbsp'||';
                 </FONT></TD></TR></TBODY></TABLE>');
   END;

   procedure start_table( p_align IN varchar2 default 'L',
			  p_cellpadding IN NUMBER default 0,
			  p_bdr in NUMBER default 0) IS
   BEGIN

	IF p_align = 'C'
 	THEN
    		myprint('<TABLE BORDER="'||to_char(p_bdr)||'" cellspacing="1"
			  ALIGN="CENTER" width="100%" CELLPADDING="' ||
			  to_char(p_cellpadding)||'">');
 	ELSE
    		myprint('<TABLE BORDER="'||to_char(p_bdr)||'" cellspacing="1"
			  width="100%" CELLPADDING="'|| to_char(p_cellpadding) || '">');
	END IF;

   END;


   procedure start_row IS
   BEGIN
 	myprint('<TR BGCOLOR="#f7f7e7">');
   END;


   procedure end_row IS
   BEGIN
	myprint('</TR>');
   END;

   procedure create_crumb( p_title IN varchar2,
			   p_link IN VARCHAR2,
			   flag in VARCHAR2) IS
   BEGIN
	IF flag IS NULL THEN
   		myprint('<TABLE width="100%">');
   		myprint('<TBODY><tr>');
   		myprint('<td align="left"><table><tr>');
   		myprint(' <td align="left" style="font-size:10pt">');
   		myprint('<a href="'||p_link||'">'||p_title||'</a> </td>');
 	ELSIF(p_title IS NULL AND flag = 'END') THEN
   		myprint('</td></TABLE><br>');
 	ELSE
   		myprint('<td align="left" style="font-size:10pt">');
	        myprint('> <a href="'||p_link||'">'||p_title||'</a>  </td>');
 	END IF;
   END;


   procedure populateCell(p_str IN VARCHAR2,
			  p_align IN VARCHAR2,
			  p_link IN VARCHAR2,
			  p_class in VARCHAR2,
			  p_width in VARCHAR2) IS
   l_class VARCHAR2(100);
   BEGIN
	myprint('<td align="'||p_align||'" nowrap ');

        IF(p_str = 'ERROR')
        THEN
           l_class := 'errorMessage';
        ELSE
           l_class := p_class;
        END IF;

        IF p_class IS NOT NULL THEN
           myprint(' class="'||l_class||'"');
        END IF;
	IF p_width IS NOT NULL THEN
		myprint(' width="'||p_width||'%">');
	ELSE
	  myprint('>');
	END IF;
	IF p_str IS NULL
	THEN
		myprint('&'||'nbsp'||';');
	ELSE
     	  IF p_link IS NULL THEN
        	myprint(p_str);
   	  ELSE
        	myprint('<A HREF="'||g_oki_alert_url||'/'||p_link||'">');
        	myprint(p_str);
        	myprint('</A>');
   	  END IF;
	END IF;
 	myprint('</TD>');
   END;

   procedure spaceCell(p_space in VARCHAR2,p_str IN VARCHAR2,
		       p_align IN VARCHAR2, p_link IN VARCHAR2,
		       p_class in VARCHAR2, p_width in VARCHAR2) IS

   BEGIN
	myprint('<td align="'||p_align||'" nowrap ');
	IF p_class IS NOT NULL THEN
		myprint(' class="'||p_class||'"');
	END IF;
	IF p_width IS NOT NULL THEN
		myprint(' width="'||p_width||'%">');
	ELSE
  		myprint('>');
	END IF;
	IF p_str IS NULL
	THEN
		myprint('&'||'nbsp'||';');
	ELSE
   		IF p_link IS NULL THEN
        		myprint(p_str);
   		ELSE
        		myprint(p_space);
        		myprint('<A HREF="'||g_oki_alert_url||'/'||p_link||'">');
        		myprint(p_str);
        		myprint('</A>');
   		END IF;
	END IF;
	myprint('</TD>');
   END;


   procedure end_table(p_run_date IN DATE)  IS
   BEGIN
	myprint('<TR><TD colSpan=4><FONT face="arial, helvetica, sans-serif"
	          size=-2>last refreshed on '|| to_char(p_run_date)||'</FONT>
		 </TD></TR>');
	myprint('</FONT></TD></TR></TBODY>');
	myprint('</TABLE>');
	myprint('</p>');
	myprint('</TABLE>');
   END;



   FUNCTION set_output_stream(p_file_name IN VARCHAR2)
               RETURN BOOLEAN
   IS
   BEGIN
--      g_output_stream := UTL_FILE.FOPEN(g_utl_file_dest,
--                                        p_file_name,'W');
      fnd_file.put_line(  which => fnd_file.output
                        , buff => 'FILEOKI:   '||p_file_name);

      RETURN TRUE;
   EXCEPTION
      WHEN UTL_FILE.INVALID_PATH THEN
         RAISE_APPLICATION_ERROR(-20100,'Invalid Path');
         RETURN FALSE;

      WHEN UTL_FILE.INVALID_MODE THEN
         RAISE_APPLICATION_ERROR(-20101,'Invalid Mode');
         RETURN FALSE;

      WHEN UTL_FILE.INVALID_FILEHANDLE THEN
         RAISE_APPLICATION_ERROR(-20102,'Invalid Filehandle');
         RETURN FALSE;

      WHEN UTL_FILE.INVALID_OPERATION THEN
         RAISE_APPLICATION_ERROR(-20103,'Invalid Operation -- May signal a file locked by the OS');
         RETURN FALSE;

      WHEN UTL_FILE.WRITE_ERROR THEN
         RAISE_APPLICATION_ERROR(-20105,'Write Error');
         RETURN FALSE;

      WHEN UTL_FILE.INTERNAL_ERROR THEN
         RAISE_APPLICATION_ERROR(-20106,'Internal Error');
         RETURN FALSE;

      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20109,'Unknown UTL_FILE Error');
         RETURN FALSE;
   END;
       -- 1. Success
       -- 0. Failure
   PROCEDURE end_output_stream
   IS
   BEGIN
--      UTL_FILE.FCLOSE(g_output_stream);
        NULL;
   END;

   PROCEDURE print_error(p_string IN VARCHAR2)
   IS
   BEGIN
      myprint('<FONT COLOR="#CC0000">');
      myprint(p_string);
      myprint('</FONT>');
   END;


  -- This function returns the quarter end date.  It takes the quarter and year
  -- parameter as the starting date and uses the number of quarters parameter
  -- to determine the number of quarters to go back to determine the "true"
  -- quarter start date.
  FUNCTION get_gv_prev_x_qtr_end_date
  (  p_qtr_end_date   IN DATE   DEFAULT NULL
   , p_number_of_qtrs IN NUMBER DEFAULT NULL
  ) RETURN DATE IS

  l_end_date DATE := NULL ;
  -- The message id when an error occurs
  l_message_id  VARCHAR2(40) := NULL ;

  BEGIN
    l_end_date := TO_CHAR(ADD_MONTHS(p_qtr_end_date, ((3 * p_number_of_qtrs) * -1)),
                   fnd_profile.value('ICX_DATE_FORMAT_MASK'));

    RETURN l_end_date ;

  EXCEPTION
    WHEN OTHERS THEN
      -- return the error number to the calling program;
      l_message_id := substr(sqlerrm, 1, (instr(sqlerrm, ':') - 1) ) ;
      return l_message_id ;
  END get_gv_prev_x_qtr_end_date ;

/* Commented by Ravi 02-11-2001
  -- This function defaults the current quarter start date.
  FUNCTION dflt_gv_qed
  (  p_name IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS

  --  Holds the sysdate
  l_curr_date         DATE         := NULL ;
  -- Holds the quarter end date of the sysdate
  l_qtr_end_date      DATE         := NULL ;
  -- The message id when an error occurs
  l_message_id        VARCHAR2(40) := null ;
   -- Holds the organization id
  l_authoring_org_id  NUMBER       := NULL ;

    -- Cursor to get the quarter end date for the given date
  CURSOR get_qtr_end_date_csr
  (  p_curr_date        IN DATE
   , p_authoring_org_id IN NUMBER
  ) IS
  SELECT qtr_end_date
  FROM   oki_graph_values
  WHERE  p_curr_date between qtr_start_date and qtr_end_date
  AND graph_code = 'OKI_SEQ_GRW'
  AND authoring_org_id = p_authoring_org_id
  AND ROWNUM < 2
  ;
  rec_get_qtr_end_date_csr get_qtr_end_date_csr%ROWTYPE ;

  BEGIN
    l_authoring_org_id := jtfb_dcf.get_parameter_value(p_name,'P_AUTHORING_ORG_ID');

    l_curr_date := TRUNC(SYSDATE) ;
    OPEN get_qtr_end_date_csr ( l_curr_date, l_authoring_org_id );
    FETCH get_qtr_end_date_csr INTO rec_get_qtr_end_date_csr ;
      l_qtr_end_date := rec_get_qtr_end_date_csr.qtr_end_date ;
    CLOSE get_qtr_end_date_csr ;

    RETURN TO_CHAR(l_qtr_end_date, fnd_profile.value('ICX_DATE_FORMAT_MASK')) ;

  EXCEPTION
    WHEN OTHERS THEN
      -- return the error number to the calling program;
      l_message_id := substr(sqlerrm, 1, (instr(sqlerrm, ':') - 1) ) ;
      return l_message_id ;
  END dflt_gv_qed ;
*/
BEGIN
     -- Initialization Block
   g_alert_dist_list   :=       fnd_profile.value('OKI_ALERT_DIST_LIST');
   g_alert_publish_dir :=       fnd_profile.value('OKI_ALERT_PUBLISH_DIR');
   g_utl_file_dest     :=       fnd_profile.value('OKI_UTL_FILE_DEST');
   g_oki_parent_url    :=       fnd_profile.value('OKI_ALERT_URL');

   fnd_file.put_line(  which => fnd_file.log
                     , buff => 'Alert Dist List   :'||g_alert_dist_list);
   fnd_file.put_line(  which => fnd_file.log
                     , buff => 'Alert Publish Dir :'||g_alert_publish_dir);
   fnd_file.put_line(  which => fnd_file.log
                     , buff => 'Utl File Dest     :'||g_utl_file_dest);
   fnd_file.put_line(  which => fnd_file.log
                     , buff => 'Alert URL         :'||g_oki_parent_url);

END; -- Package Body OKI_ALERT_UTIL_PVT

/
