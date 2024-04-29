--------------------------------------------------------
--  DDL for Package ICX_ADMIN_SIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_ADMIN_SIG" AUTHID CURRENT_USER as
/* $Header: ICXADSIS.pls 120.0 2005/10/07 12:11:54 gjimenez noship $ */

/* Procedure help_win_script should be called from within the header section
   of an html page to insert javascript code that can then be called to
   display the help text in a seperate browser window.

   Parameters:

   defHlp:   This is the target that you wish to call for the given
             Self Service Applications Page that is currently being
             displayed.  The Technical Writers should be adding the
             appropriate targets in the documentation to support your calling
             the proper help page with the correct context.

   language_code:
             This is the language you wish to display the help content in.
             If for some reason you do not plan to translate some or all of
             you help content then you can override the users current
             language preference setting with a hardcoded value.
             I recommend you do not pass a value for this setting
             so that the function will use the current language preference
             for that user.
             If the help content does not exist for the given target
             and language then the user will be presented with a list of
             languages where the target does exist.

     application_short_name:
             This tells the iHelp system which product owns the
             iHelp documentation content.  This application_short_name
             will be used to select the appropriate target for a
             given product.  The documentation would have been staged
             under this product when it was originally loaded
             into the system.
*/
procedure help_win_script (
defHlp in varchar2 default null,
language_code in varchar2 default null,
application_short_name in varchar2 default 'ICX');

/* Called by OAPageLayoutBean in the OA framework to implement the
   Global Menu help button.  Need this API because JDBC setBoolean API
   does not work with Oracle.  Since we need to call the
   we can't use the fnd_help.get_url with helpsystem parameter set to
   false - we have to create this api to pass in the appropriate value.
*/

function icx_fnd_help (
defHlp in varchar2 default null,
p_application_id in number default 178) return varchar2;


/*
**  Return the proper syntax for generating the help_win javascript function
**  but don't pipe it out to htp.  This is used by BIS in their reports.
*/
function help_win_syntax (
defHlp in varchar2 default null,
language_code in varchar2 default null,
application_short_name in varchar2 default 'ICX') return VARCHAR2;

/* function background returns the url to the background gif */
function background (language_code in varchar2 default null ) return varchar2;

/* procedure header paints the header used by all of the admin screens.
   This header contains the ICXLOGO.gif and icons that link to Functions,
   Responsibilities, Register Web Users, Universal Home Page, and Help text */
procedure Openheader(defStatus in varchar2 default null, extraOnLoad in varchar2 default null,language_code in varchar2 default null);
procedure Closeheader (language_code in varchar2 default null);
procedure Closeheader2 (language_code in varchar2 default null);

/*
** displays the toolbar
** Parameters:
**    language_code	- language ex. 'US'
**    disp_find		- 'Y' display the find button on toolbar
**			  'N' do not dislay the find button
**    disp_wizard	- 'Y' display the wizard button on the toolbar
**			  'N' do not display the wizard
**    disp_help		- 'Y' display the help button on the toolbar
**                        'N' do not display the help
**    disp_export       - 'Y' display the export button on the toolbar
**                        'N' do not display the help
**    disp_exit         - 'Y' display the exit button on the toolbar
**                        'N' do not display the exit
*/
procedure toolbar (language_code in varchar2 default null,
		   disp_find	 in varchar2 default null,
		   disp_mainmenu in varchar2 default 'Y',
		   disp_wizard   in varchar2 default 'N',
		   disp_help	 in varchar2 default 'Y',
		   disp_export   in varchar2 default null,
		   disp_exit     in varchar2 default 'Y');

procedure Startover(language_code in varchar2 default null);
/* procedure footer paints the footer used by all of the admin screens.
   This folter contains the WebApps email address. */
procedure footer;

/* procedure error_screen displays an error message in its own html page.
   This screen is used to display database-side errors from the admin pages.
   It displays an icon with a link to the previous page, and the error text.
   If api_msg_count and api_msg_data are passed then error_screen will also
   display all of the sessions api error messages */
procedure error_screen (title varchar2,
                        language_code in varchar2 default null,
			api_msg_count in number default null,
			api_msg_data in varchar2 default null);

/*procedure showTable displays an table with retrieved rows from a pl/sql table
  and put it in a nice formatted html table. In the procedure that calls
  showTable has to define a table as type of pp_table. row_count is the number
  of rows to pass, col_num is the number of colmns to display with passed data
  other parameters are html specifications. */

type pp_table is table of varchar2(5000) index by binary_integer;
procedure showTable(p_table pp_table,
		    row_count in binary_integer default 0,
                    col_num in binary_integer default 0,
                    p_border in binary_integer default 0,
                    p_cellpadding in binary_integer default 0,
                    p_cellspacing in binary_integer default 0,
                    p_width in binary_integer default 0,
		    p_cell_width in binary_integer default 0,
		    p_indent in binary_integer default 0,
		    img in varchar2 default 'FNDIBLBL.gif');

procedure displayTable(wlcm_table pp_table,
		    row_count in binary_integer default 0,
                    col_num in binary_integer default 0,
		    language_code in varchar2 default null,
		    img in varchar2 default 'FNDIGRBL.gif');
end icx_admin_sig;

 

/
