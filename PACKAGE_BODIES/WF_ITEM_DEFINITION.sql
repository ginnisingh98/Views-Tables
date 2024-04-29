--------------------------------------------------------
--  DDL for Package Body WF_ITEM_DEFINITION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ITEM_DEFINITION" AS
/* $Header: wfdefb.pls 120.1 2005/07/02 03:43:48 appldev ship $  */

/*===========================================================================
  PACKAGE NAME:         wf_item_definition

  DESCRIPTION:

  OWNER:                GKELLNER

============================================================================*/

/*===========================================================================
  PROCEDURE NAME:       find_item_type

  DESCRIPTION:
                        Main Find View drawing routine.  This is the
                        main entry point into the Item Type
                        Definition View.  This view has two attributes: The
                        Item Type List shows all the Items Types that
                        are currently stored in the Workflow database
                        repository.  The effective date allows you to
                        chose which date you would like the view to be
                        effective for.   Since activities can
                        have multiple versions and have effective date ranges
                        for each of those version we need a specific value
                        to determine which of those versions is requested.
                        Once the user clicks on the Find buttton from
                        this view, the draw_item_type function takes over to
                        create the Item Type Definition.

 MODIFICATION LOG:
     06-JUN-2001 JWSMITH BUG 1819232 -Added ID attr for TD tag for ADA
                 - Added summary attr for table tag

============================================================================*/
PROCEDURE find_item_type IS

  l_username            VARCHAR2(320);
  l_admin_role          VARCHAR2(320);
  l_admin_privilege     BOOLEAN;

  l_char_date           VARCHAR2(80);
  l_date_date           DATE;
  l_valid_date          BOOLEAN;
  l_expected_format     VARCHAR2(80);

  /*
  ** List of all item types based no security or admin access
  */
  CURSOR admin_itemtypes IS
  SELECT display_name, name
  FROM   wf_item_types_vl
  ORDER BY 1;

  /*
  ** List of item types based on owner access for a given user.
  */
  CURSOR user_itemtypes IS
  SELECT distinct wit.display_name, wit.name
  FROM   wf_item_types_vl wit, wf_items wik
  WHERE  wik.owner_role = l_username
  AND    wik.item_type = wit.name
  ORDER BY 1;

  CURSOR all_users IS
  SELECT distinct wik.owner_role owner_role
  FROM   wf_items wik
  ORDER BY 1;

BEGIN

   /*
   ** Make sure the user has signed on
   */
   wfa_sec.GetSession(l_username);

   /*
   ** Check what security controls are enabled
   */
   l_admin_role := wf_core.Translate('WF_ADMIN_ROLE');

   IF (l_admin_role <> '*')  THEN

       IF (wf_directory.IsPerformer(l_username, l_admin_role)) THEN

          l_admin_privilege := TRUE;

       ELSE

          l_admin_privilege := FALSE;

       END IF;

   ELSE

       /*
       ** No security is enabled so everyone has admin privileges.
       */
       l_admin_privilege := TRUE;

   END IF;

   /*
   ** Create a standard title page with the item_type display name as the title
   */
   wf_item_definition.draw_header(
      NULL,
      NULL,
      'FIND');

   /*
   ** We use the simple GET method, when the form is submitted it
   ** generates a URL of the form
   **
   **    http://...wf_item_definition.draw_item_type?x_process=<name>&x_ident= ...
   **
   ** which is what our instance_list procedure (defined later) is
   ** expecting to get passed.
   */
  htp.formOpen(curl=>'wf_item_definition.draw_item_type',
               cmethod=>'GET', cattributes=>'NAME="WF_FIND"');

   /*
   ** Create a table for the find attributes.
   */
   htp.tableOpen(calign=>'CENTER', cattributes=>'border=0 cellpadding=2 cellspacing=0 summary=""');

   /*
   ** Create the prompt for the item type poplist
   */
   htp.tableRowOpen;
   htp.tableData(cvalue=>'<LABEL FOR="i_item_type">' ||
                 wf_core.translate('ITEMTYPE') || '</LABEL>',
                 calign=>'right',
                 cattributes=>'valign=middle id=""');


   /*
   ** Create the item type poplist
   */
   htp.p('<TD ID="' || wf_core.translate('ITEMTYPE') || '">');
   htp.formSelectOpen(cname=>'p_item_type',cattributes=>'id="i_item_type"');

   /*
   ** Create the item type poplist.  If you have admin privs then show
   ** all item types
   */
   IF (l_admin_privilege) THEN

     FOR it IN admin_itemtypes LOOP

       /*
       ** Take care of the case where the item type has a space in it.
       ** We used a + to represent the space in the list of values since you
       ** can escape it in a poplist and pass it through the post.
       */
       htp.formSelectOption(cvalue=>it.display_name,
                            cattributes=>'value='||REPLACE(it.name,' ', '+'));

     END LOOP;

   ELSE

     /*
     ** If you do not have admin privs then show only those item types
     ** for which you have owner access
     */
     FOR it IN user_itemtypes LOOP

       htp.formSelectOption(cvalue=>it.display_name,
                            cattributes=>'value='||REPLACE(it.name,' ', '+'));

     END LOOP;

   END IF;

   htp.formSelectClose;

   htp.p('</TD>');

   htp.tableRowClose;


   /*
   ** Create the prompt for the Effective poplist
   */
   htp.tableRowOpen;

   htp.tableData(cvalue=>'<LABEL FOR="i_effective_date">' ||
                 wf_core.translate('WFITD_EFFECTIVE_DATE') || '</LABEL>',
                 calign=>'right',
                 cattributes=>'valign=middle id=""');

   /*
   ** Get the expected format for the date.  You don't care about the
   ** validation stuff
   */
   wf_item_definition_util_pub.validate_date (
      TO_CHAR(sysdate),
      l_date_date,
      l_valid_date,
      l_expected_format);

   /*
   ** Set the default Effective Date value based on the l_expected_format
   */
   l_char_date := TO_CHAR(SYSDATE, l_expected_format);

   htp.tableData(cvalue=>htf.formText(cname=>'p_effective_date',
                                       csize=>'30',
                                       cmaxlength=>'240',
                                       cvalue=>l_char_date,
                 cattributes=>'id="i_effective_date"'),
                 calign=>'left', cattributes=>'id=""');

   htp.tableRowClose;

   htp.tableClose;
   htp.formClose;

   -- Add submit button
   htp.tableopen(calign=>'CENTER',cattributes=>'summary=""');
   htp.tableRowOpen;

   htp.p('<TD ID="">');

   wfa_html.create_reg_button ('javascript:document.WF_FIND.submit()',
                              wf_core.translate ('FIND'),
                              wfa_html.image_loc,
                              'fndfind.gif',
                              wf_core.translate ('FIND'));

   htp.p('</TD>');

   htp.tableRowClose;
   htp.tableClose;

   wfa_sec.footer;
   htp.htmlClose;

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('wf_item_definition', 'find_item_type');
      wf_item_definition.Error;

END find_item_type;

/*===========================================================================
  PROCEDURE NAME:       draw_item_type

  DESCRIPTION:          Main routine that will create a three framed
                        view that shows the complete definition of an
                        item type.  The top frame is the view header.
                        It show the title of the view along with
                        controls to return to the find window, return
                        to the main menu or exit the system.  It then
                        displays the Item Type Summary and Item Type
                        Details in two separate frame below the header frame.
                        The left frame consists of the hierarchical summary
                        of the Item Type Definition showing all display
                        names for attributes, processes, notifications,
                        functions, etc.  The right frame consists of
                        a complete listing of all the objects and their
                        associated properties for the given item type.


============================================================================*/
PROCEDURE draw_item_type (
  p_item_type           VARCHAR2 ,
  p_effective_date      VARCHAR2 )
 IS

l_username            VARCHAR2(320);
l_valid_date          BOOLEAN;
l_date_date           DATE;
l_effective_date      VARCHAR2(80);
l_expected_format     VARCHAR2(80);
l_item_type           VARCHAR2(30);

BEGIN


  /*
  ** Make sure the user has signed on
  */
  wfa_sec.GetSession(l_username);

  /*
  ** Create the three frames for the Item Definition Summary.
  ** The frames are constructed in the following manner:
  ** ______________________
  **|                     |
  **|       HEADER        |
  **|---------------------|
  **|          |          |
  **|          |          |
  **| SUMMARY  |  DETAILS |
  **|          |          |
  **|          |          |
  **|---------------------|
  */

  htp.title(wf_core.translate('WFITD_ITEM_TYPE_DEFINITION'));

  /*
  ** Take care of the case where the item type has a space in it.
  ** We used a + to represent the space in the list of values since you
  ** can escape it in a poplist and pass it through the post.  Here we'll
  ** switch it back and let the convert function take care of it.
  */
  l_item_type := REPLACE(p_item_type, '+', ' ');

  /*
  ** Check if there is a time included with the search criteria
  ** If not the add midnight to the time so the activities will always
  ** be after the given date on the same day.
  */
  /*
  ** Do not replace + here, because we are to encode them later on
  IF (INSTR(p_effective_date, ':') = 0) THEN

     l_effective_date := p_effective_date || '+23:59:59';

  ELSE

     l_effective_date := REPLACE(p_effective_date, ' ', '+');

  END IF;
  */

  IF (INSTR(p_effective_date, ':') = 0) THEN

     l_effective_date := p_effective_date || ' 23:59:59';

  END IF;

  /*
  ** Create the top header frameset and the bottom summary/detail frameset
  */
  htp.p ('<FRAMESET ROWS="10%,90%" BORDER=0
           TITLE="' || WF_CORE.Translate('WFITD_ITEM_TYPE_DEFINITION') || '" LONGDESC="' ||           owa_util.get_owa_service_path ||
           'wfa_html.LongDesc?p_token=WFITD_ITEM_TYPE_DEFINITION">');

  /*
  ** Create the header frame
  */
  htp.p ('<FRAME NAME=HEADER '||
          'SRC='||
           owa_util.get_owa_service_path||
           'wf_item_definition.draw_header?p_item_type='||
            wfa_html.conv_special_url_chars(l_item_type)||
           '&p_effective_date='||
            wfa_html.conv_special_url_chars(l_effective_date)||
            '&p_caller=DISPLAY'||
           ' MARGINHEIGHT=10 MARGINWIDTH=10 '||
           'NORESIZE SCROLLING="NO" FRAMEBORDER=YES'||
           '" TITLE="' ||
           WF_CORE.Translate('WFITD_ITEM_TYPE_DEFINITION') || '" LONGDESC="' ||
           owa_util.get_owa_service_path ||
           'wfa_html.LongDesc?p_token=WFITD_ITEM_TYPE_DEFINITION">');




  /*
  ** Check the effective date that was passed in.  If it is invalid
  ** Then just show a frame with an error.  Otherwise show the
  ** frameset for the summary and details.
  */
  wf_item_definition_util_pub.validate_date (
     l_effective_date,
     l_date_date,
     l_valid_date,
     l_expected_format);

  /*
  ** The date that was passed in is good so continue to draw the
  ** frameset for the summary and details.
  */
  IF (l_valid_date = TRUE) THEN

     /*
     ** Now create the summary/detail frameset
     */
     htp.p ('<FRAMESET COLS="35%,65%" BORDER=0 BGCOLOR="#CCCCCC"
              TITLE="' || WF_CORE.Translate('WFITD_ITEM_TYPE_DEFINITION') || '"
              LONGDESC="' ||           owa_util.get_owa_service_path ||
              'wfa_html.LongDesc?p_token=WFITD_ITEM_TYPE_DEFINITION">');

     /*
     ** Create the summary frame
     */
     htp.p ('<FRAME NAME=SUMMARY '||
            'SRC='||
            owa_util.get_owa_service_path||
            'wf_item_definition.draw_item_summary?p_item_type='||
            wfa_html.conv_special_url_chars(l_item_type)||
            '&p_effective_date='||
            wfa_html.conv_special_url_chars(l_effective_date)||
            ' MARGINHEIGHT=10 MARGINWIDTH=10 FRAMEBORDER=0 WRAP=OFF' ||
            '" TITLE="' ||
           WF_CORE.Translate('WFITD_ITEM_TYPE_DEFINITION') || '" LONGDESC="' ||
           owa_util.get_owa_service_path ||
           'wfa_html.LongDesc?p_token=WFITD_ITEM_TYPE_DEFINITION">');

     /*
     ** Create the details frame
     */
     htp.p ('<FRAME NAME=DETAILS '||
            'SRC='||
            owa_util.get_owa_service_path||
            'wf_item_definition.draw_item_details?p_item_type='||
            wfa_html.conv_special_url_chars(l_item_type)||
            '&p_effective_date='||
            wfa_html.conv_special_url_chars(l_effective_date)||
            ' MARGINHEIGHT=10 MARGINWIDTH=10 FRAMEBORDER=YES' ||
            '" TITLE="' ||
           WF_CORE.Translate('WFITD_ITEM_TYPE_DEFINITION') || '" LONGDESC="' ||
           owa_util.get_owa_service_path ||
           'wfa_html.LongDesc?p_token=WFITD_ITEM_TYPE_DEFINITION">');

     /*
     ** Close the summary/details frameset
     */
     htp.p ('</FRAMESET>');

   ELSE

     /*
     ** Create the error frame
     */
     htp.p ('<FRAME NAME=DETAILS '||
            'SRC='||
            owa_util.get_owa_service_path||
            'wf_item_definition.draw_error?p_effective_date='||
             wfa_html.conv_special_url_chars(l_effective_date)||
            '&p_expected_format='||l_expected_format||
            ' MARGINHEIGHT=10 MARGINWIDTH=10 FRAMEBORDER=YES'||
            '" TITLE="' ||
           WF_CORE.Translate('WFITD_ITEM_TYPE_DEFINITION') || '" LONGDESC="' ||
           owa_util.get_owa_service_path ||
           'wfa_html.LongDesc?p_token=WFITD_ITEM_TYPE_DEFINITION">');

  END IF;

  /*
  ** Close the header and summary/details frameset
  */
  htp.p ('</FRAMESET>');

  htp.htmlClose;

  EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('wf_item_definition',
        'draw_item_type',
         p_item_type,
         p_effective_date);

     wf_item_definition.Error;

END draw_item_type;

/*===========================================================================
  PROCEDURE NAME:       draw_header

  DESCRIPTION:
                        Draws the top frame of the Item Definition View.
                        It show the title of the view along with
                        controls to return to the find window, return
                        to the main menu or exit the system.

============================================================================*/
PROCEDURE draw_header (
  p_item_type           VARCHAR2 ,
  p_effective_date      VARCHAR2 ,
  p_caller              VARCHAR2 ) IS

l_username                  VARCHAR2(320);
l_item_type_display_name    VARCHAR2(240) := NULL;
l_title                     VARCHAR2(240) := NULL;
l_wf_item_types_vl_tbl      wf_item_types_vl_pub.wf_item_types_vl_tbl_type;

BEGIN

 -- Make sure user has signed on
  wfa_sec.GetSession(l_username);


  /*
  ** Get the display name for the item type if it was passed in
  */
  IF (p_item_type IS NOT NULL) THEN

     wf_item_types_vl_pub.fetch_item_type
        (p_item_type,
         l_wf_item_types_vl_tbl);

     l_item_type_display_name := '('||l_wf_item_types_vl_tbl(1).display_name||')';

     /*
     ** Add the effective date to the item type display name
     ** if it was passed in
     */
/*
** Don't like this but I can see it coming up so I'll leave it here.
*/
/*
     IF (p_effective_date IS NOT NULL) THEN

       l_item_type_display_name := l_item_type_display_name || ' - ' ||
         p_effective_date || ')';

     ELSE

       l_item_type_display_name := l_item_type_display_name || ')';

     END IF;
*/

  END IF;

  IF (p_caller = 'FIND') THEN

     l_title := wf_core.translate('WFITD_FIND_ITEM_TYPE');

  ELSIF (p_caller = 'DISPLAY') THEN

    l_title := wf_core.translate('WFITD_ITEM_TYPE_DEFINITION');

    --call get session again to set icx values.
    --this is important when comming from find screen because this
    --will be executed in a new frame, which is a new session

  END IF;

  /*
  ** Create the  Window title
  */
  htp.htmlOpen;
  htp.headOpen;
  htp.title(l_title);
--  wfa_html.create_help_function('wfnew/wfnew49.htm');
  wfa_html.create_help_function('wf/links/itt.htm?ITTDEFPG');

  /*
  ** Open body and draw standard header
  */
  if (p_caller = 'FIND') THEN

     wfa_sec.header(FALSE, '', l_title, FALSE);

  else

     wfa_sec.header(FALSE, 'wf_item_definition.find_item_type', l_title,FALSE);

  end if;

  htp.p('</BODY>');

  EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('wf_item_definition',
         'draw_header',
         p_item_type,
         p_effective_date,
         p_caller);

     wf_item_definition.Error;

END draw_header;

/*===========================================================================
  PROCEDURE NAME:       draw_item_summary

  DESCRIPTION:          Draws a hierarchical summary of the Item
                        Type Definition showing all display names for
                        attributes, processes, notifications, functions,
                        etc.  The following is an example of the output:

============================================================================*/
PROCEDURE draw_item_summary (
  p_item_type           VARCHAR2 ,
  p_effective_date      VARCHAR2 )
 IS

  l_valid_date                BOOLEAN;
  l_effective_date            DATE;
  l_item_type                 VARCHAR2(30);
  l_username                  VARCHAR2(320);
  l_expected_format           VARCHAR2(80);

  l_wf_item_types_vl_tbl      wf_item_types_vl_pub.wf_item_types_vl_tbl_type;
  l_wf_item_attributes_vl_tbl wf_item_attributes_vl_pub.wf_item_attributes_vl_tbl_type;
  l_wf_activities_vl_tbl       wf_activities_vl_pub.wf_activities_vl_tbl_type;
  l_wf_activity_attr_vl_tbl    wf_activities_vl_pub.wf_activity_attr_vl_tbl_type;
  l_wf_messages_vl_tbl         wf_messages_vl_pub.wf_messages_vl_tbl_type;
  l_wf_message_attr_vl_tbl     wf_messages_vl_pub.wf_message_attr_vl_tbl_type;
  l_wf_lookup_types_tbl        wf_lookup_types_pub.wf_lookup_types_tbl_type;
  l_wf_lookups_tbl             wf_lookup_types_pub.wf_lookups_tbl_type;

BEGIN

  /*
  ** Make sure the user has signed on
  */
  wfa_sec.GetSession(l_username);

  l_item_type := p_item_type;

  /*
  ** Check the effective date that was passed in.  If it is invalid
  ** Then just show a frame with an error.  Otherwise show the
  ** frameset for the summary and details.
  */
  wf_item_definition_util_pub.validate_date (
     p_effective_date,
     l_effective_date,
     l_valid_date,
     l_expected_format);

  /*
  ** Get all the information about this item type
  */
  wf_item_types_vl_pub.fetch_item_type
     (l_item_type,
      l_wf_item_types_vl_tbl);


  /*
  ** Fetch all the item attributes associtated with this item type
  */
  wf_item_attributes_vl_pub.fetch_item_attributes
          (l_item_type,
           null,
           l_wf_item_attributes_vl_tbl);

  /*
  ** Fetch all the activity information into a list.
  ** This function will fetch all types of
  ** activities order by Processes, Notfications, Functions, and then by
  ** their display name
  */
  wf_activities_vl_pub.fetch_activities
          (l_item_type,
           null,
           l_effective_date,
           null,
           l_wf_activities_vl_tbl,
           l_wf_activity_attr_vl_tbl);

  /*
  ** Fetch all the messages and their associated attributes for this item type
  */
  wf_messages_vl_pub.fetch_messages
          (l_item_type,
           null,
           l_wf_messages_vl_tbl,
           l_wf_message_attr_vl_tbl);


  /*
  ** Fetch all the lookup types associtated with this item type
  */
  wf_lookup_types_pub.fetch_lookup_types
          (l_item_type,
           null,
           l_wf_lookup_types_tbl,
           l_wf_lookups_tbl);

  /*
  ** Open body and draw standard header
  */
  wfa_sec.header(background_only=>TRUE);

  /*
  ** Open a new table for each attribute so you can control the spacing
  ** between each attribute
  */
  htp.tableOpen(cattributes=>'border=0 cellpadding=0 cellspacing=0 summary=""');

  /*
  ** List all the item type names
  */
  wf_item_types_vl_pub.draw_item_type_list
          (l_wf_item_types_vl_tbl,
           l_effective_date,
           0);

  /*
  ** List all the item attribute names
  */
  wf_item_attributes_vl_pub.draw_item_attribute_list
          (l_wf_item_attributes_vl_tbl,
           l_effective_date,
           1);

  /*
  ** List all the activity names.  This function will list all type of
  ** activities order by Processes, Notfications, Functions, and then
  ** by their display name.  This is based on how the list was created, not
  ** by any special processing by the draw_activity_list function
  */
  wf_activities_vl_pub.draw_activity_list
          (l_wf_activities_vl_tbl,
           l_wf_activity_attr_vl_tbl,
           l_effective_date,
           1);

  /*
  ** List all the message names
  */
  wf_messages_vl_pub.draw_message_list
          (l_wf_messages_vl_tbl,
           l_wf_message_attr_vl_tbl,
           l_effective_date,
           1);

  /*
  ** List all the lookup type names
  */
  wf_lookup_types_pub.draw_lookup_type_list
          (l_wf_lookup_types_tbl,
           l_wf_lookups_tbl,
           l_effective_date,
           1);


  /*
  ** Table is created so close it out
  */
  htp.tableClose;

  EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('wf_item_definition',
         'draw_item_summary',
         p_item_type,
         p_effective_date);

     wf_item_definition.Error;

END draw_item_summary;

/*===========================================================================
  PROCEDURE NAME:       draw_item_details

  DESCRIPTION:          Draws a complete listing of all the objects and their
                        associated properties for the given item type.
                        The following is an example of the output:

============================================================================*/
PROCEDURE draw_item_details (
  p_item_type           VARCHAR2 ,
  p_effective_date      VARCHAR2 )
 IS

  l_valid_date                BOOLEAN;
  l_effective_date            DATE;
  l_username                  VARCHAR2(320);
  l_item_type                 VARCHAR2(30);
  l_expected_format           VARCHAR2(80);

  l_wf_item_types_vl_tbl      wf_item_types_vl_pub.wf_item_types_vl_tbl_type;
  l_wf_item_attributes_vl_tbl wf_item_attributes_vl_pub.wf_item_attributes_vl_tbl_type;
  l_wf_activities_vl_tbl       wf_activities_vl_pub.wf_activities_vl_tbl_type;
  l_wf_activity_attr_vl_tbl    wf_activities_vl_pub.wf_activity_attr_vl_tbl_type;
  l_wf_messages_vl_tbl         wf_messages_vl_pub.wf_messages_vl_tbl_type;
  l_wf_message_attr_vl_tbl     wf_messages_vl_pub.wf_message_attr_vl_tbl_type;
  l_wf_lookup_types_tbl        wf_lookup_types_pub.wf_lookup_types_tbl_type;
  l_wf_lookups_tbl             wf_lookup_types_pub.wf_lookups_tbl_type;

BEGIN

  l_item_type := p_item_type;

  /*
  ** Make sure the user has signed on
  */
  wfa_sec.GetSession(l_username);

  /*
  ** Check the effective date that was passed in.  If it is invalid
  ** Then just show a frame with an error.  Otherwise show the
  ** frameset for the summary and details.
  */
  wf_item_definition_util_pub.validate_date (
     p_effective_date,
     l_effective_date,
     l_valid_date,
     l_expected_format);

  /*
  ** Get all the information about this item type
  */
  wf_item_types_vl_pub.fetch_item_type
     (l_item_type,
      l_wf_item_types_vl_tbl);

  /*
  ** Fetch all the item attributes associtated with this item type
  */
  wf_item_attributes_vl_pub.fetch_item_attributes
          (l_item_type,
           null,
           l_wf_item_attributes_vl_tbl);

  /*
  ** Fetch all the activity information into a list.
  ** This function will fetch all types of
  ** activities order by Processes, Notfications, Functions, and then by
  ** their display name
  */
  wf_activities_vl_pub.fetch_activities
          (l_item_type,
           null,
           l_effective_date,
           null,
           l_wf_activities_vl_tbl,
           l_wf_activity_attr_vl_tbl);

  /*
  ** Fetch all the messages and their associated attributes for this item type
  */
  wf_messages_vl_pub.fetch_messages
          (l_item_type,
           null,
           l_wf_messages_vl_tbl,
           l_wf_message_attr_vl_tbl);

  /*
  ** Fetch all the lookup types associtated with this item type
  */
  wf_lookup_types_pub.fetch_lookup_types
          (l_item_type,
           null,
           l_wf_lookup_types_tbl,
           l_wf_lookups_tbl);

  /*
  ** Open body and draw standard header
  */
  wfa_sec.header(background_only=>TRUE);

  /*
  ** List all the item type details
  */
  wf_item_types_vl_pub.draw_item_type_details
          (l_wf_item_types_vl_tbl,
           1);

  /*
  ** Finish off the list with a couple of blank rows
  */
  htp.p ('<BR><BR>');

  /*
  ** List all the item attribute details
  */
  wf_item_attributes_vl_pub.draw_item_attribute_details
          (l_wf_item_attributes_vl_tbl,
           1);

  /*
  ** Finish off the list with a couple of blank rows
  */
  htp.p ('<BR><BR>');

  /*
  ** List all the activity details
  */
  wf_activities_vl_pub.draw_activity_details
          (l_wf_activities_vl_tbl,
           l_wf_activity_attr_vl_tbl,
           l_effective_date,
           1,
           TRUE,
           TRUE);

  /*
  ** Finish off the list with a couple of blank rows
  */
  htp.p ('<BR><BR>');

  /*
  ** List all the message details
  */
  wf_messages_vl_pub.draw_message_details
          (l_wf_messages_vl_tbl,
           l_wf_message_attr_vl_tbl,
           1);

  /*
  ** Finish off the list with a couple of blank rows
  */
  htp.p ('<BR><BR>');

  /*
  ** List all the lookup type details
  */
  wf_lookup_types_pub.draw_lookup_type_details
          (l_wf_lookup_types_tbl,
           l_wf_lookups_tbl,
           1);

  EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('wf_item_definition',
         'draw_item_details',
         p_item_type,
         p_effective_date);

     wf_item_definition.Error;

END draw_item_details;

/*===========================================================================
  PROCEDURE NAME:       error

  DESCRIPTION:
                        Print a page with an error message.
                        Errors are retrieved from these sources in order:
                             1. wf_core errors
                             2. Oracle errors
                             3. Unspecified INTERNAL error

============================================================================*/
PROCEDURE error IS
BEGIN

null;
end Error;

/*===========================================================================
  PROCEDURE NAME:       draw_error

  DESCRIPTION:          Draws the bottom frame for the error message if an
                        invalid date has been entered

============================================================================*/
PROCEDURE draw_error (p_effective_date          VARCHAR2 ,
                      p_expected_format         VARCHAR2 ) IS

BEGIN
  wfa_sec.header(background_only=>TRUE);

  /*
  ** skip a line
  */
  htp.p('<BR>');

  /*
  ** Write the error message in bold
  */
  htp.bold(wf_core.translate('WFITD_INVALID_EFFECTIVE'));

  /*
  ** Write the value the user entered normally
  */
  htp.p(' '||p_effective_date);

  /*
  ** skip a line
  */
  htp.p('<BR><BR>');

  /*
  ** Show the expected format
  */
  htp.p(wf_core.translate('WFITD_USE_FORMAT')||' '||
      TO_CHAR(sysdate, p_expected_format));

  wfa_sec.footer;

  EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('wf_item_definition', 'draw_error');
     wf_item_definition.Error;

END draw_error;

/*===========================================================================
  PROCEDURE NAME:       fetch_item_definition_url

  DESCRIPTION:          Fetches the url address to initiate the
                        Item Definition View

============================================================================*/
PROCEDURE fetch_item_definition_url (p_item_definition_url OUT NOCOPY VARCHAR2) IS

BEGIN

   p_item_definition_url := owa_util.get_owa_service_path||
      'wf_item_definition.find_item_type';

  EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('wf_item_definition', 'fetch_item_definition_url');
     wf_item_definition.Error;

END fetch_item_definition_url;

END wf_item_definition;

/
