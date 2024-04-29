--------------------------------------------------------
--  DDL for Package Body WF_ITEM_DEFINITION_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_ITEM_DEFINITION_UTIL_PUB" AS
/* $Header: wfdefb.pls 120.1 2005/07/02 03:43:48 appldev ship $  */

/*===========================================================================
  PACKAGE NAME:         wf_item_definition_util_pub

  DESCRIPTION:

  OWNER:                GKELLNER

  TABLES/RECORDS:

  PROCEDURES/FUNCTIONS:

============================================================================*/

/*===========================================================================
  PROCEDURE NAME:       draw_custom_protect_details

  DESCRIPTION:          Writes out the custom and protect prompts and values
                        for a detailed listing of a workflow object.

============================================================================*/
PROCEDURE draw_custom_protect_details
                        (p_customization_level    IN  VARCHAR2,
                         p_protection_level       IN  VARCHAR2) IS


BEGIN

      /*
      ** Create the customization row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_CUSTOMIZATION_LEVEL'),
         p_customization_level);

      /*
      ** Create the protection level row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_PROTECTION_LEVEL'),
         p_protection_level);

      EXCEPTION
      WHEN OTHERS THEN
         Wf_Core.Context('wf_item_definition_util_pub',
            'draw_custom_protect_details',
            p_customization_level,
            p_protection_level);

         wf_item_definition.Error;

END draw_custom_protect_details;

/*===========================================================================
  PROCEDURE NAME:       draw_read_write_exe_details

  DESCRIPTION:          Writes out the read, write, execute role prompts
                        and values for a detailed listing of a workflow object.

============================================================================*/
PROCEDURE draw_read_write_exe_details
                        (p_read_role              IN  VARCHAR2,
                         p_write_role             IN  VARCHAR2,
                         p_execute_role           IN  VARCHAR2,
                         p_draw_execute_role      IN  BOOLEAN) IS

BEGIN

      /*
      ** Create the read role row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_READ_ROLE'),
         p_read_role);

      /*
      ** Create the write role row in the table
      */
      wf_item_definition_util_pub.draw_detail_prompt_value_pair (
         wf_core.translate('WFITD_WRITE_ROLE'),
         p_write_role);

      IF (p_draw_execute_role = TRUE) THEN

         /*
         ** Create the execute role row in the table
         */
         wf_item_definition_util_pub.draw_detail_prompt_value_pair (
            wf_core.translate('WFITD_EXECUTE_ROLE'),
            p_execute_role);

      END IF;

      EXCEPTION
      WHEN OTHERS THEN
         Wf_Core.Context('wf_item_definition_util_pub',
            'draw_read_write_exe_details',
            p_read_role,
            p_write_role,
            p_execute_role);

         wf_item_definition.Error;

END draw_read_write_exe_details;

/*===========================================================================
  PROCEDURE NAME:       create_hotlink_to_details

  DESCRIPTION:

   The creation of the anchor from the summary frame to the detail
   frame was very complex so I've extracted the function into its
   own routine.  I used the straight tabledata call rather than
   the htf.anchor2 web server call because the anchor2 created an
   HREF string that would never seem to create the proper syntax

   How this call works is that the A HREF is preceeded by the indent
   characters.  This is so the indent characters are not part of the
   anchor and therefore do not appear as underlined text.  The second
   component is the link to the url for the details frame.  When using
   frames and anchors you must provide the full url that was used to
   create the frame including all the parameters.  Since I don't store
   this parameter in any of my pl*sql tables, I had to add this parameter
   to all the procedures so I could pass it through.
   The next component is the tag within the detail frame that you
   are going to navigate to.  The tag is composed of two parts.
   The first part is the  object_type_prefix
   (ATTRIBUTE, PROCESS, NOTIFICATION, MESSAGE, MESSAGE_ATTR, etc.)
   with a '#' in front of it to tell it that its a local
   link in the existing frame.  The second part is the internal name
   of the object.  This is followed by the frame target which is
   DETAILS, and then the name that is displayed to the user
   as the link name which is the display name for the object.
   The alignment is always left and I  prevented wrapping so you
   don't get every line being double spaced if one attribute or
   some other object is a bit longer than what fits in the summary
   frame.  This is especially effective if the user resizes the
   summary frame down to something small.

============================================================================*/
PROCEDURE create_hotlink_to_details (
             p_item_type             IN VARCHAR2,
             p_effective_date        IN DATE,
             p_object_type_prefix    IN VARCHAR2,
             p_internal_name         IN VARCHAR2,
             p_display_name          IN VARCHAR2,
             p_detail_prompt         IN VARCHAR2,
             p_indent_level          IN NUMBER) IS

l_indent_string        VARCHAR2(80) := '';
ii                     NUMBER := 0;

BEGIN

   /*
   ** Add three blank spaces for every indent level to preceed the
   ** link with
   */
   FOR ii IN 1..p_indent_level LOOP

     l_indent_string := l_indent_string || '&nbsp &nbsp &nbsp ';

   END LOOP;

   htp.tableRowOpen(calign=>'left', cvalign=>'top');

   /*
   ** If this is a all from the detail region then you'll have a two
   ** column format and you need to put this prompt on.  Otherwise it's
   ** a one column table for the summary frame.
   */
   IF (p_detail_prompt IS NOT NULL) THEN

       wf_item_definition_util_pub.draw_detail_prompt(
          p_detail_prompt);

   END IF;

   htp.tableData(
       cvalue=>l_indent_string||
               '<A HREF="'||
               owa_util.get_owa_service_path||
               'wf_item_definition.draw_item_details?p_item_type='||
               wfa_html.conv_special_url_chars(p_item_type)||
               '&p_effective_date='||
               TO_CHAR(p_effective_date)||
               TO_CHAR(p_effective_date,'+hh24:mi:ss')||
               '#'||p_object_type_prefix||':'||
               p_internal_name||
               '" TARGET="DETAILS">'||
               p_display_name||
               '</A>',
       calign=>'Left',
       cnowrap=>'NOWRAP');

   htp.tableRowClose;

  EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('wf_item_definition_util_pub',
        'create_hotlink_to_details',
        p_item_type,
        TO_CHAR(p_effective_date),
        p_object_type_prefix,
        p_internal_name,
        p_display_name);
     wf_item_definition.Error;

END create_hotlink_to_details;


/*===========================================================================
  PROCEDURE NAME:       create_details_hotlink_target

  DESCRIPTION:
   Creates the destination target in the detail frame for a hotlink.
   The destination target name is based on the a name comprised of
   two parts.  The first part is the  object_type_prefix
   (ATTRIBUTE, PROCESS, NOTIFICATION, MESSAGE, MESSAGE_ATTR, etc.)
   The second part is the internal name of the object.

============================================================================*/
PROCEDURE create_details_hotlink_target (
             p_object_type_prefix    IN VARCHAR2,
             p_internal_name         IN VARCHAR2,
             p_display_name          IN VARCHAR2,
             p_display_prompt        IN VARCHAR2,
             p_indent_level          IN NUMBER) IS

l_indent_string        VARCHAR2(80) := '';
ii                     NUMBER := 0;

BEGIN

   /*
   ** Add three blank spaces for every indent level to preceed the
   ** link with
   */
   FOR ii IN 1..p_indent_level LOOP

     l_indent_string := l_indent_string || '&nbsp &nbsp &nbsp ';

   END LOOP;

   /*
   ** Create the display name row in the table
   */
   htp.tableRowOpen(calign=>'middle', cvalign=>'top');

   /*
   ** The destination target name is based on the a name comprised of
   ** two parts.  The first part is the  object_type_prefix
   ** (ATTRIBUTE, PROCESS, NOTIFICATION, MESSAGE, MESSAGE_ATTR, etc.)
   ** The second part is the internal name of the object.
   */
   htp.p('<A NAME='||
           '"'||p_object_type_prefix||
           ':'||p_internal_name||'"'||
           '>');

   wf_item_definition_util_pub.draw_detail_prompt(p_display_prompt);

   htp.p ('</A>');

   wf_item_definition_util_pub.draw_detail_value(p_display_name);

   htp.tableRowClose;

  EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('wf_item_definition_util_pub',
        'create_details_hotlink_target',
        p_object_type_prefix,
        p_internal_name,
        p_display_name,
        p_display_prompt);

     wf_item_definition.Error;

END create_details_hotlink_target;


/*===========================================================================
  PROCEDURE NAME:       draw_summary_section_title

  DESCRIPTION:
                        Draws the bold section title for an object type
                        in the summary frame.

============================================================================*/
PROCEDURE draw_summary_section_title (
             p_section_title         IN VARCHAR2,
             p_indent_level          IN NUMBER) IS

l_indent_string        VARCHAR2(80) := '';
ii                     NUMBER := 0;

BEGIN

   /*
   ** Add three blank spaces for every indent level to preceed the
   ** link with
   */
   FOR ii IN 1..p_indent_level LOOP

     l_indent_string := l_indent_string || '&nbsp &nbsp &nbsp ';

   END LOOP;

  /*
  ** Open a row in the summary table, put on the the section title.
  ** and then close the row.
  */
  htp.tableRowOpen(calign=>'left', cvalign=>'top');

  htp.tableData(
      cvalue=>l_indent_string||'<B>'||p_section_title||'</B>',
      calign=>'Left',
      cnowrap=>'NOWRAP');

  htp.tableRowClose;

  EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('wf_item_definition_util_pub',
        'draw_summary_section_title',
        p_section_title,
        p_indent_level);

     wf_item_definition.Error;

END draw_summary_section_title;

/*===========================================================================
  PROCEDURE NAME:       draw_detail_section_title

  DESCRIPTION:
                        Draws the bold section title and the thick line
                        for an object type in the detail frame.

============================================================================*/
PROCEDURE draw_detail_section_title (
             p_section_title         IN VARCHAR2,
             p_indent_level          IN NUMBER) IS

BEGIN

  /*
  ** Draw the detail section title
  */
  htp.bold(p_section_title);

  /*
  ** Put a line across the form
  */
  htp.p('<BR><HR size="2">');

  EXCEPTION
  WHEN OTHERS THEN
     Wf_Core.Context('wf_item_definition_util_pub',
        'draw_detail_section_title',
         p_section_title);


     wf_item_definition.Error;

END draw_detail_section_title;

/*===========================================================================
  PROCEDURE NAME:       draw_detail_prompt_value_pair

  DESCRIPTION:
                        Draws the bold detail section prompt and its
                        corresponding value in the detail frame

============================================================================*/
PROCEDURE draw_detail_prompt_value_pair
                        (p_prompt IN VARCHAR2,
                         p_value  IN VARCHAR2) IS

BEGIN

      htp.tableRowOpen(calign=>'middle', cvalign=>'top');

      htp.tableData(cvalue=>p_prompt||' ',
                    calign=>'Right',
                    cnowrap=>'NOWRAP');

      htp.tableData('<B>'||p_value||'</B>', 'Left');

      htp.tableRowClose;

      EXCEPTION
      WHEN OTHERS THEN
         Wf_Core.Context('wf_item_definition_util_pub',
            'draw_detail_prompt_value_pair',
            p_prompt,
            p_value);

         wf_item_definition.Error;

END draw_detail_prompt_value_pair;

/*===========================================================================
  PROCEDURE NAME:       draw_detail_prompt

  DESCRIPTION:
                        Draws the bold detail section prompt

============================================================================*/
PROCEDURE draw_detail_prompt
                        (p_prompt IN VARCHAR2) IS

BEGIN

      htp.tableData(p_prompt||' ', 'Right');

      EXCEPTION
      WHEN OTHERS THEN
         Wf_Core.Context('wf_item_definition_util_pub',
            'draw_detail_prompt',
            p_prompt);
         wf_item_definition.Error;

END draw_detail_prompt;

/*===========================================================================
  PROCEDURE NAME:       draw_detail_value

  DESCRIPTION:
                        Draws the value of an attribute

============================================================================*/
PROCEDURE draw_detail_value
                        (p_value IN VARCHAR2) IS

BEGIN

      htp.tableData('<B>'||p_value||'</B>', 'Left');

      EXCEPTION
      WHEN OTHERS THEN
         Wf_Core.Context('wf_item_definition_util_pub',
            'draw_detail_value',
            p_value);
         wf_item_definition.Error;

END draw_detail_value;

/*===========================================================================
  PROCEDURE NAME:       activity_titles_list

  DESCRIPTION:
     Check how many activity types got printed.  If the list didn't
     to one of the activity types because there weren't any of that
     then catch it here and print it.


  PARAMETERS:


============================================================================*/
PROCEDURE activity_titles_list (
p_highest_level  IN  NUMBER,
p_current_level  IN  NUMBER,
p_indent_level   IN  NUMBER
) IS

ii                       NUMBER := 0;
l_summary_section_title  VARCHAR2(240);

BEGIN

  /*
  ** Check how many activity types got printed.  If the list didn't
  ** to one of the activity types because there weren't any of that
  ** then catch it here and print it.  Subtract 1 from the current
  ** level since the index is 1 and the current is always going to be
  ** one higher than the starting point in the for loop.
  */
  FOR ii IN p_highest_level..p_current_level - 1 LOOP

     IF (ii = 1) THEN

        /*
        ** Set the the processes title.
        */
        l_summary_section_title := wf_core.translate('PROCESSES');

        wf_item_definition_util_pub.draw_summary_section_title(
           l_summary_section_title,
           p_indent_level);


     ELSIF (ii = 2) THEN

        /*
        ** Set the the notifications title.
        */
        l_summary_section_title := wf_core.translate('WFITD_NOTIFICATIONS');

        wf_item_definition_util_pub.draw_summary_section_title(
           l_summary_section_title,
           p_indent_level);


     ELSIF (ii = 3) THEN

        /*
        ** Set the functions title.
        */
        l_summary_section_title := wf_core.translate('WFITD_FUNCTIONS');

        wf_item_definition_util_pub.draw_summary_section_title(
           l_summary_section_title,
           p_indent_level);

     END IF;

   END LOOP;

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('wf_item_definition_util_pub',
         'activity_titles_list');

         wf_item_definition.Error;

END activity_titles_list;

/*===========================================================================
  PROCEDURE NAME:       activity_titles_details

  DESCRIPTION:
     Check how many activity types got printed.  If the list didn't
     to one of the activity types because there weren't any of that
     then catch it here and print it.


  PARAMETERS:


============================================================================*/
PROCEDURE activity_titles_details (
p_highest_level  IN  NUMBER,
p_current_level  IN  NUMBER
) IS

ii                       NUMBER := 0;
l_detail_section_title  VARCHAR2(240);

BEGIN

  /*
  ** Check how many activity types got printed.  If the list didn't
  ** to one of the activity types because there weren't any of that
  ** then catch it here and print it.  Subtract 1 from the current
  ** level since the index is 1 and the current is always going to be
  ** one higher than the starting point in the for loop.
  */
  FOR ii IN p_highest_level..p_current_level - 1 LOOP

     IF (ii = 1) THEN

        /*
        ** Set the the processes title.
        */
        l_detail_section_title := wf_core.translate('WFITD_PROCESS_DETAILS');

        wf_item_definition_util_pub.draw_detail_section_title(
           l_detail_section_title,
           0);

        /*
        ** Create some blank space around the title
        */
        htp.p ('<BR><BR>');


     ELSIF (ii = 2) THEN

        /*
        ** Set the the notifications title.
        */
        l_detail_section_title := wf_core.translate('WFITD_NOTIFICATION_DETAILS');

        wf_item_definition_util_pub.draw_detail_section_title(
           l_detail_section_title,
           0);

        /*
        ** Create some blank space around the title
        */
        htp.p ('<BR><BR>');


     ELSIF (ii = 3) THEN

        /*
        ** Set the functions title.
        */
        l_detail_section_title := wf_core.translate('WFITD_FUNCTION_DETAILS');

        wf_item_definition_util_pub.draw_detail_section_title(
           l_detail_section_title,
           0);

     END IF;

   END LOOP;

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('wf_item_definition_util_pub',
         'activity_titles_details');

         wf_item_definition.Error;

END activity_titles_details;

/*===========================================================================
  PROCEDURE NAME:       validate date

  DESCRIPTION:
                        Validates and converts a char datatype date string
                        to a date datatype that the user has entered
                        is in a valid format based on the NLS_DATE_FORMAT
                        parameter.

============================================================================*/
PROCEDURE validate_date (p_char_date IN VARCHAR2,
                         p_date_date OUT NOCOPY DATE,
                         p_valid_date OUT NOCOPY BOOLEAN,
                         p_expected_format OUT NOCOPY VARCHAR2) IS

l_nls_date_format   VARCHAR2(80);
l_date_date         DATE;

BEGIN

   /*
   ** Set the l_date_date to null
   */
   l_date_date := NULL;

   /*
   ** Get the current date format from the v$nls_parameters view
   */
   SELECT MAX(value)
   INTO   l_nls_date_format
   FROM   v$nls_parameters
   WHERE  parameter = 'NLS_DATE_FORMAT';

   /*
   ** If no parameter can be found then set it to something
   */
   IF (l_nls_date_format IS NULL) THEN

       l_nls_date_format := 'DD-MON-RRRR';

   END IF;

   /*
   ** Convert YY or YYYY in the l_nls_date_format to RRRR since
   ** this is the most flexible format
   */
   l_nls_date_format := REPLACE (l_nls_date_format, 'YYYY', 'RRRR');
   l_nls_date_format := REPLACE (l_nls_date_format, 'YY', 'RRRR');

   /*
   ** Check to see if you need to add the time to the date format in case
   ** the char string has a time element on it.  This check
   ** is based on having a ':' in the date value string and not having a ':'
   ** in the nls string
   */
   IF (INSTR(p_char_date, ':') > 0 AND INSTR(l_nls_date_format, ':') = 0) THEN

      l_nls_date_format := l_nls_date_format || ' HH24:MI:SS';

   END IF;

   /*
   ** Now try to convert the char date string to a date datatype.  If any
   ** exception occurs then tell the caller that the
   */
   p_valid_date := TRUE;

   BEGIN

      SELECT TO_DATE(p_char_date, l_nls_date_format)
      INTO   l_date_date
      FROM   dual;

   EXCEPTION
      WHEN OTHERS THEN
         p_valid_date := FALSE;
   END;

   p_date_date := l_date_date;
   p_expected_format := l_nls_date_format;

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('wf_item_definition_util_pub',
         'validate_date');

         wf_item_definition.Error;

END validate_date;


/*===========================================================================
  PROCEDURE NAME:       create_checkbox

  DESCRIPTION:
                        Create a checkbox entry in a table

============================================================================*/
PROCEDURE create_checkbox (
 p_name       IN VARCHAR2,
 p_value      IN VARCHAR2,
 p_checked    IN VARCHAR2,
 p_prompt     IN VARCHAR2,
 p_image_name IN VARCHAR2 ,
 p_new_row    IN BOOLEAN
) IS

BEGIN

  IF (p_new_row = TRUE) THEN

     /*
     ** Open the checkboxes row
     */
     htp.tableRowOpen;

  END IF;

  /*
  ** Create the checkbox for Top Level Process Only List
  ** add nbsp; to space out the checkboxes
  */
  IF (p_image_name IS NOT NULL) THEN
     htp.tableData(
        cvalue=>
            htf.formcheckbox(
                cname=>p_name,
                cvalue=>p_value,
                cchecked=>p_checked,
                cattributes=>NULL)||'&nbsp;'||
                   htf.img(
                      curl=>wfa_html.image_loc||p_image_name,
                      calign=>'absmiddle',
                      calt=>null,
                      cismap=>null,
                      cattributes=>'height=26')||
                    '&nbsp;'||p_prompt||'&nbsp;&nbsp;&nbsp;',
        calign=>'left');

  ELSE

     htp.tableData(
        cvalue=>
            htf.formcheckbox(
                cname=>p_name,
                cvalue=>p_value,
                cchecked=>p_checked,
                cattributes=>NULL)||
                '&nbsp;'||p_prompt||'&nbsp;&nbsp;&nbsp;',
        calign=>'left',
        cattributes=>'valign="TOP"');

  END IF;

  IF (p_new_row = TRUE) THEN

     /*
     ** Close the checkboxes row
     */
     htp.tableRowClose;

  END IF;

   EXCEPTION
   WHEN OTHERS THEN
      Wf_Core.Context('wf_item_definition_util_pub',
         'create_checkbox',
          p_name,
          p_value,
          p_checked,
          p_prompt);

         wf_item_definition.Error;

END create_checkbox;

END wf_item_definition_util_pub;

/
