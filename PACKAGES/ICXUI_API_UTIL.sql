--------------------------------------------------------
--  DDL for Package ICXUI_API_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICXUI_API_UTIL" AUTHID CURRENT_USER as
/* $Header: ICXUIUTS.pls 115.0 99/10/28 23:26:53 porting ship    $ */

   /**
    * Draw the Title Bar
    *
    * This routine generates the title bar used
    * in the wizard, tabset and the dialog.
    *
    * The Title Bar consists of the Main Title and
    * the Secondary Title displayed on the left side
    * and the Help Icon displayed on the right side.
    *
    * @param p_title main title
    * @param p_sec_title secondary title
    * @param p_help_url valid URL for the help icon
    */
    procedure draw_title
    (
        p_title     in varchar2
    );

   /**
    * Draw the Image
    *
    * This routine draws the image associated
    * with the wizard/tabset and dialog.
    *
    * @param p_image image to be displayed
    */
    procedure draw_image
    (
        p_image in varchar2
    );


   /**
    * Draw the Footer
    *
    * This routine draws the footer associated with the wizard/tabset
    * and dialog
    *
    */
    procedure draw_footer;


   /**
    * Draw the Subheader
    *
    * This routine draws the subheader associated
    * with the wizard/tabset and dialog.
    *
    * @param p_subheader_text subheader to be displayed
    */
    procedure draw_subheader
    (
        p_subheader_text in varchar2
    );

   /**
    * Draw the Help Text
    *
    * This routine draws the help (hint) text
    * associated with the wizard/tabset and dialog.
    *
    * @param p_help_text help text to be displayed
    */
    procedure draw_helptext
    (
        p_help_text in varchar2
    );

   /**
    * Draw the Buttons
    *
    * This routine draws the required buttons
    *
    * @param p_buttons list of buttons to be displayed
    */
    procedure draw_buttons
    (
        p_buttons icxui_api_button_list
    );


    function formButton
    (
        cname       in varchar2 DEFAULT NULL,
        cvalue      in varchar2 DEFAULT NULL,
        cattributes in varchar2 DEFAULT NULL
    )
    return varchar2;

   /**
    * Get the Text Style
    *
    * This routine returns the text with the font
    * settings that is used for the wizard,
    * tabsets and the dialog.
    *
    * @param p_str text to be formatted
    * @returns the formatted text.
    */
    function get_text_style
    (
        p_str in varchar2
    )
    return varchar2;

   /**
    * Draw the Path Text
    *
    * This routine draws the path text (folder path,
    * page path) associated with the wizard/tabset
    * and dialog.
    *
    * @param p_path_text path to be displayed
    */
    procedure draw_path_text
    (
        p_path_text in varchar2
    );

end icxui_api_util;

 

/
