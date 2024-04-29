--------------------------------------------------------
--  DDL for Package WF_ITEM_DEFINITION_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ITEM_DEFINITION_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: wfdefs.pls 115.18 2002/12/03 01:12:21 dlam ship $  */

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

  PARAMETERS:
        p_customization_level IN
                        Customization Level value
        p_protection_level IN
                        Protection Level value


============================================================================*/
PROCEDURE draw_custom_protect_details
                        (p_customization_level    IN  VARCHAR2,
                         p_protection_level       IN  VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       draw_read_write_execute_details

  DESCRIPTION:          Writes out the read, write, execute role prompts
                        and values for a detailed listing of a workflow object.

  PARAMETERS:
        p_read_role IN  Read role value

        p_write_role IN
                        Write role value

        p_execute_role IN
                        Execute role value

        p_draw_execute_role IN
                        Not all activity objects (Notifications) have an
                        execute role.  This parameters prevents that prompt
                        from being listed.


============================================================================*/
PROCEDURE draw_read_write_exe_details
                        (p_read_role              IN  VARCHAR2,
                         p_write_role             IN  VARCHAR2,
                         p_execute_role           IN  VARCHAR2,
                         p_draw_execute_role      IN  BOOLEAN);

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

  PARAMETERS:
        p_item_type IN  Frame parameter for the item type

        p_effective_date IN
                        Frame parameter for the effective date

        p_object_type_prefix IN
                        Type of workflow object that you are going to create

        p_internal_name IN
                        Internal name of that object

        p_display_name IN
                        Display name of the object

        p_detail_prompt IN
                        If this is a link between a detail object and other
                        detail object then what prompt would you like to
                        preceed the value with

        p_indent_level IN
                        How many space would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
PROCEDURE create_hotlink_to_details (
             p_item_type             IN VARCHAR2,
             p_effective_date        IN DATE,
             p_object_type_prefix    IN VARCHAR2,
             p_internal_name         IN VARCHAR2,
             p_display_name          IN VARCHAR2,
             p_detail_prompt         IN VARCHAR2,
             p_indent_level          IN NUMBER);



/*===========================================================================
  PROCEDURE NAME:       create_details_hotlink_target

  DESCRIPTION:
   Creates the destination target in the detail frame for a hotlink.
   The destination target name is based on the a name comprised of
   two parts.  The first part is the  object_type_prefix
   (ATTRIBUTE, PROCESS, NOTIFICATION, MESSAGE, MESSAGE_ATTR, etc.)
   The second part is the internal name of the object.

  PARAMETERS:

        p_object_type_prefix IN
                        Type of workflow object that you are going to create

        p_internal_name IN
                        Internal name of that object

        p_display_name IN
                        Display name of the object

        p_display_prompt IN
                        The prompt would you like to preceed the value with

        p_indent_level IN
                        How many space would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
PROCEDURE create_details_hotlink_target (
             p_object_type_prefix    IN VARCHAR2,
             p_internal_name         IN VARCHAR2,
             p_display_name          IN VARCHAR2,
             p_display_prompt        IN VARCHAR2,
             p_indent_level          IN NUMBER);


/*===========================================================================
  PROCEDURE NAME:       draw_summary_section_title

  DESCRIPTION:
                        Draws the bold section title for an object type
                        in the summary frame.

  PARAMETERS:

        p_section_title IN
                        Section title

        p_indent_level IN
                        How many space would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
PROCEDURE draw_summary_section_title (
             p_section_title         IN VARCHAR2,
             p_indent_level          IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:       draw_detail_section_title

  DESCRIPTION:
                        Draws the bold section title and the thick line
                        for an object type in the detail frame.

  PARAMETERS:

        p_section_title IN
                        Section title

        p_indent_level IN
                        How many space would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
PROCEDURE draw_detail_section_title (
             p_section_title         IN VARCHAR2,
             p_indent_level          IN NUMBER);

/*===========================================================================
  PROCEDURE NAME:       draw_detail_prompt_value_pair

  DESCRIPTION:
                        Draws the bold detail section prompt and its
                        corresponding value in the detail frame

  PARAMETERS:

        p_prompt IN     Prompt to be shown in bold

        p_value IN      Value corresponding to the prompt

============================================================================*/
PROCEDURE draw_detail_prompt_value_pair
                        (p_prompt IN VARCHAR2,
                         p_value  IN VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       draw_detail_prompt

  DESCRIPTION:
                        Draws the bold detail section prompt

  PARAMETERS:

        p_prompt IN     Prompt to be shown in bold

============================================================================*/
PROCEDURE draw_detail_prompt
                        (p_prompt                 IN  VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       draw_detail_value

  DESCRIPTION:
                        Draws the value of an attribute

  PARAMETERS:

        p_value IN      Value to be drawn

============================================================================*/
PROCEDURE draw_detail_value
                        (p_value                 IN  VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:       activity_titles_list

  DESCRIPTION:
     Check how many activity types got printed.  If the list didn't
     to one of the activity types because there weren't any of that
     then catch it here and print it.


  PARAMETERS:
        p_highest_level  IN
                        What was the highest activity type reached

        p_current_level  IN
                        What is the current activity level

        p_indent_level IN
                        How many space would you like to indent this
                        listing from the left border of the screen.

============================================================================*/
PROCEDURE activity_titles_list (
p_highest_level  IN  NUMBER,
p_current_level  IN  NUMBER,
p_indent_level   IN  NUMBER);

/*===========================================================================
  PROCEDURE NAME:       activity_titles_details

  DESCRIPTION:
     Check how many activity types got printed.  If the list didn't
     to one of the activity types because there weren't any of that
     then catch it here and print it.


  PARAMETERS:
        p_highest_level  IN
                        What was the highest activity type reached

        p_current_level  IN
                        What is the current activity level

============================================================================*/
PROCEDURE activity_titles_details (
p_highest_level  IN  NUMBER,
p_current_level  IN  NUMBER);

/*===========================================================================
  PROCEDURE NAME:       validate date

  DESCRIPTION:
                        Validates and converts a char datatype date string
                        to a date datatype that the user has entered
                        is in a valid format based on teh NLS_DATE_FORMAT
                        parameter.

  PARAMETERS:

        p_char_date IN  Char datatype date string
        p_date_date OUT Return the date as a date datatype
        p_valid_date OUT
                        Tells the caller whether the string could be
                        converted to a date or not.
        p_expected_format OUT
                        Tells the caller what is the expected format is
                        for the date

============================================================================*/
PROCEDURE validate_date (p_char_date IN VARCHAR2,
                         p_date_date OUT NOCOPY DATE,
                         p_valid_date OUT NOCOPY BOOLEAN,
                         p_expected_format OUT NOCOPY VARCHAR2);



/*===========================================================================
  PROCEDURE NAME:       create_checkbox

  DESCRIPTION:
                        Create a checkbox entry in a table

  PARAMETERS:
             p_name IN  Name of the checkbox

             p_value IN Value that is returned as a parameter when
                        this checkbox is checked

             p_checked IN
                        Is the default value checked or unchecked
                        (Values = 'Y' or 'N')

             p_prompt IN Checkbox prompt show to user

             p_image_name IN
                        Icon name for the checkbox

============================================================================*/
PROCEDURE create_checkbox (
 p_name       IN VARCHAR2,
 p_value      IN VARCHAR2,
 p_checked    IN VARCHAR2,
 p_prompt     IN VARCHAR2,
 p_image_name IN VARCHAR2   DEFAULT NULL,
 p_new_row    IN BOOLEAN    DEFAULT FALSE
);

END wf_item_definition_util_pub;

 

/
