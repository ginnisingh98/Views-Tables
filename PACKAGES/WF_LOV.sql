--------------------------------------------------------
--  DDL for Package WF_LOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_LOV" AUTHID CURRENT_USER as
/* $Header: wflovs.pls 115.27 2002/11/11 06:15:40 rosthoma ship $ */

/*===========================================================================

  PL*SQL TABLE NAME:    wf_lov_define_rec

  DESCRIPTION:          Stores list of values definition information


  total_rows is the number of rows that match the search criteria.
  You need to execute a count before the real query every time you
  get rows since we are in a stateless environment.

  add_attr_title1..5 columns are for extra attributes that you wish
  to display in the lov

============================================================================*/

TYPE wf_lov_define_rec IS RECORD
(
   total_rows         NUMBER,
   add_attr1_title    VARCHAR2(80),
   add_attr2_title    VARCHAR2(80),
   add_attr3_title    VARCHAR2(80),
   add_attr4_title    VARCHAR2(80),
   add_attr5_title    VARCHAR2(80)
);

/*===========================================================================

  PL*SQL TABLE NAME:    wf_lov_value_rec

  DESCRIPTION:          Stores list of values information

  Hidden Key value is what gets returned to the hidden value on the
  notification form.

  Display value is what gets returned to the displayed field on the
  notification form.  If there is no need for a hidden primary key value
  then make both these values the same.

  add_attr_value1..5 columns are for extra attributes that you wish
  to display in the lov
============================================================================*/

TYPE wf_lov_value_rec IS RECORD
(
   hidden_key         VARCHAR2(320),
   display_value      VARCHAR2(4000),
   add_attr1_value    VARCHAR2(320),
   add_attr2_value    VARCHAR2(240),
   add_attr3_value    VARCHAR2(240),
   add_attr4_value    VARCHAR2(240),
   add_attr5_value    VARCHAR2(240)
);

 TYPE wf_lov_values_tbl IS TABLE OF
    wf_lov.wf_lov_value_rec
 INDEX BY BINARY_INTEGER;


/*===========================================================================

  GLOBAL PL*SQL RECORD NAME:    g_define_rec

  DESCRIPTION:          Stores list of values  definition information

  You cannot pass plsql tables or records the execute immediate so you
  need all procedures that generate LOV data to use this global to set
  up the total number of rows in the list and the column headers.
============================================================================*/
g_define_rec wf_lov.wf_lov_define_rec;

/*===========================================================================

  GLOBAL PL*SQL RECORD NAME:    g_value_tbl

  DESCRIPTION:          Stores list of values row information

  You cannot pass plsql tables or records the execute immediate so you
  need all procedures that generate LOV data to use this global to set
  up the rows you can choose from in the LOV.
============================================================================*/
g_value_tbl  wf_lov.wf_lov_values_tbl;

/*===========================================================================
  PROCEDURE NAME:       display_lov

  DESCRIPTION:          Display the two frame lov list

  PARAMETERS:

============================================================================*/
procedure display_lov
(
p_lov_name      in varchar2 default null,
p_display_name        in varchar2 default null,
p_validation_callback in varchar2 default null,
p_dest_hidden_field   in varchar2 default null,
p_dest_display_field  in varchar2 default null,
p_current_value       in varchar2 default null,
p_param1              in varchar2 default null,
p_param2              in varchar2 default null,
p_param3              in varchar2 default null,
p_param4              in varchar2 default null,
p_param5              in varchar2 default null,
p_display_key         in varchar2 default 'N');

/*===========================================================================
  PROCEDURE NAME:       display_lov_find

  DESCRIPTION:          Display the find criteria for the lov

  PARAMETERS:

============================================================================*/
procedure display_lov_find (
p_lov_name          in varchar2 default null,
p_display_name            in varchar2 default null,
p_validation_callback     in varchar2 default null,
p_dest_hidden_field       in varchar2 default null,
p_dest_display_field      in varchar2 default null,
p_current_value           in varchar2 default null,
p_autoquery               in varchar2 default 'Y',
p_display_key             in varchar2 default 'N');

/*===========================================================================
  PROCEDURE NAME:       display_lov_details

  DESCRIPTION:          Calls the validation callback to get the content
                        and display an HTML LOV.

  PARAMETERS:

============================================================================*/
procedure display_lov_details   (
p_lov_name          in varchar2 default null,
p_display_name            in varchar2 default null,
p_validation_callback     in varchar2 default null,
p_dest_hidden_field       in varchar2 default null,
p_dest_display_field      in varchar2 default null,
p_current_value           in varchar2 default null,
p_start_row               in varchar2 default '1',
p_autoquery               in varchar2 default 'Y',
p_param1                  in varchar2 default null,
p_param2                  in varchar2 default null,
p_param3                  in varchar2 default null,
p_param4                  in varchar2 default null,
p_param5                  in varchar2 default null,
p_display_key             in varchar2 default 'N');

/*===========================================================================
  PROCEDURE NAME:       OpenLovWinHtml

  DESCRIPTION:          Generates javascript required to run the HTML LOV.
                        Insert the javascript statements in the header of
                        the Document that will call the LOV window.

  PARAMETERS:

     p_jscript_tag -    Tells the procedure whether you want to include the
                        <SCRIPT> tag in the header or not.  ICX cannot have
                        extra <SCRIPT> and </SCRIPT> tags in their header
                        so this must be eliminated.  Values are Y or N.

============================================================================*/
procedure OpenLovWinHtml(p_jscript_tag     IN Varchar2 DEFAULT 'Y');

/*===========================================================================
  FUNCTION NAME:        GenerateLovURL

  DESCRIPTION:          Generates the URL syntax required to launch
                        the lov window for the given field.

  PARAMETERS:

     form_name     IN - The name of the HTML form where you would like
                        to return the selected value from the LOV.

                        Example:

                        opener.document.WF_PREF

                        where WF_PREF is the form name given in the
                        <FORM...> tag

                        NOTE: The Form name is CASE sensitive.
                        Also if your are calling the LOV from a HTML window
                        using frames then the syntax for the form name
                        should be:

                        opener.parent.opener.bottomframe.document.WF_PREF

                        where bottomframe is the name of the frame given
                        in the <FRAME...> tag and WF_PREF is the form
                        name given in the <FORM...> tag


     query_plsql  IN -  PLSQL procedure to call to generate LOV column headers,
                        column data, display vs. non display columns, and
                        column order.  The output format for this function
                        is very specific and must make use of the htp.p
                        function to provide this information.

                        The signature for the LOV data definition procedure
                        must include a p_titles_only and a p_find_criteria
                        parameter.  The p_titles_only parameter is used for
                        longlist LOV's and must be implemented in the
                        procedure as a mechanism for fetching the definition
                        information for the LOV.  The p_find_criteria is
                        populated by the LOV window from the Find field and
                        allows you to restrict the data that is shown in the
                        LOV window.

                        Example:

                        procedure FetchLOVData (
                            p_titles_only     IN VARCHAR2 DEFAULT NULL,
                            p_find_criteria   IN VARCHAR2 DEFAULT NULL);


                        The above function is called when the LOV is
                        initially envoked or when the user clicks on the
                        Find button.  The data that is defined in this
                        function should be in the following format:

                        HTP.P ('Lov Title');
                        HTP.P ('Number of Columns in LOV');
                        HTP.P ('Number of Rows'); -- See NOTE A/B Below

                        The title, # columns, and # rows information should
                        then be followed by a list of column names and
                        % space that column should consume in the LOV.
                        The column name value should be a translated string
                        since this will be displayed as the column header.
                        The % should be defined as a whole
                        number value.  The total percentages for all
                        columns in your LOV should add up 100%.
                        If you have a column that you want
                        to include as a non display column then the %
                        space should be 0.  This is important for
                        unique id'select that represent the data being
                        displayed.

                        The first column in the list is the key column.
                        Although you control the search and the sort criteria
                        it is assumed that the first column in the list will
                        be the column that the list is sorted and queried on.
                        The user can reorder the columns in the list but this
                        is strictly for viewing convenience.  The auto
                        reduction mechanism within the LOV will only ever
                        operate on the first column.

                        HTP.P ('Column1 Name');
                        HTP.P ('% of space the column1 should consume');
                        HTP.P ('Column2 Name');
                        HTP.P ('% of space the column2 should consume');
                        HTP.P ('Column...');
                        HTP.P ('% of space the column... should consume');

                        The column title and space information should
                        then be followed by the actual LOV data.
                        You should open a cursor for the results of
                        your query and return the results in the cursor
                        loop.

                        Example:

                        if (p_titles_only = 'N') then

                            open c_user_lov (p_find_criteria); -- See NOTE B

                            loop

                               fetch c_user_lov into
                                  l_name, l_display_name;

                               exit when c_user_lov%notfound;

                               HTP.P (l_name);
                               HTP.P (l_display_name);

                            end loop;

                        end if;


                        NOTE A:

                        To fill in the Number of Rows value you need to
                        implement a select in your FetchLOVData function
                        to get the count of the
                        number of rows that will be returned by the query.

                        Example:

                        select count(1)
                        into   x_count
                        from   your_tables
                        where  UPPER(your_first_table_column) LIKE
                                 UPPER(p_find_criteria)||'%'

                        NOTE B:

                        If you are defining a LONGLIST LOV then your
                        count and fetch query should be consistent with how
                        FORMS constructs LOV queries to ensure optimal
                        performance

                        select count(1)
                        into   x_count
                        from   your_tables
                        where  UPPER(your_first_table_column) LIKE
                                 UPPER(p_find_criteria)||'%'
                        and    (your_first_table_column  LIKE
                                 LOWER(SUBSTR(p_find_criteria, 1, 2))||'%'
                        or    your_first_table_column  LIKE
                                 LOWER(SUBSTR(p_find_criteria, 1, 1))||
                                 UPPER(SUBSTR(p_find_criteria, 2, 1))||'%'
                        or    your_first_table_column  LIKE
                                 INITCAP(SUBSTR(p_find_criteria, 1, 2))||'%'
                        or    your_first_table_column  LIKE
                                 UPPER(SUBSTR(p_find_criteria, 1, 2))||'%')


                        -- The resulting select would parse out to look
                        -- something like the following:

                        select count(1)
                        into   x_count
                        from   fnd_form_vl
                        where  upper(form_name) like 'FND%'
                        and    (form_name like 'fn%'
                        or      form_name like 'fN%'
                        or      form_name like 'Fn%'
                        or      form_name like 'FN%')


     query_params IN -  Any extra parameters that you would like to hardcode
                        and pass to this specific implementation of the LOV
                        defined in the query_plsql routine.  This gives you
                        an opportunity to have one query_plsql routine that
                        may vary slightly based on the implementation of the
                        LOV on a specific form

     column_names IN -  Comma separated list of field names on your form
                        where you would like to return the values. The column
                        names are based the name you give your entry fields
                        using the <INPUT..> tag.  Do not include any spaces
                        in your list of columns. If you don't care about a
                        column that is presented in the LOV then use a column
                        name of NULL.

                        Example:

                        If your query_plsql function creates a three column
                        LOV that includes a list of languages,
                        language short names and territories but you only
                        care about the language and the territory and want
                        to discard the language short name then the syntax
                        might be:

                        p_language,NULL,p_territory


     longlist     IN -  Defines whether this a longlist LOV or not.

                        Values: Y/N

                        If you define a list to be a longlist then the
                        LOV window is initially display with just the column
                        headers and no data.  The user must then enter some
                        text in the Find Criteria and click on Find to
                        display any data to choose from.  If the LOV is not
                        defined as a longlist then the columns and data are
                        immediately displayed when the window is envoked.

     callback     IN -  Name of javascript function to envoke when the user
                        clicks on OK from LOV window.  If you would like to
                        envoke a javascript function to perform other special
                        functionality within your HTML form you can pass a
                        javascript function to execute when the OK button is
                        pressed.  This javascript function should be defined
                        in the header of the window where the LOV will be
                        envoked.  That javascript function should be defined
                        to take the same number of parameters as you have
                        defined columns in your query_plsql routine.  We
                        will take the javascript function and append the
                        selected values from the LOV data selected as a
                        comma delimited list and then execute the javascript
                        function.

     callback_params IN - Column values that you would like to pass to
                        javascript callback function.  This parameter is
                        passed in the format of col#,col#  where col# is
                        the column number in the list that you define that
                        you would like to pass as a parmater.  For example
                        If you would like to pass column 2 as the first
                        parameter, and column 3 as the second parameter,
                        and not pass column 1 to the javascript function
                        then the callback_params value should be 1,2.  Note
                        that the column numbering starts with 0...


     width        IN -  The width in pixels of the LOV Window

     height       IN  -  The height in pixels of the LOV Window
     prompt       IN  -  String to be displayed when MouseOver


============================================================================*/
function GenerateLovURL (p_form_name       IN Varchar2,
                         p_query_plsql     IN Varchar2,
                         p_query_params    IN Varchar2,
                         p_column_names    IN Varchar2,
                         p_longlist        IN Varchar2,
                         p_callback        IN Varchar2 DEFAULT NULL,
                         p_callback_params IN Varchar2 DEFAULT NULL,
                         p_init_find_field IN Varchar2 DEFAULT NULL,
                         p_width           IN Varchar2,
                         p_height          IN Varchar2,
                         p_prompt          IN Varchar2 DEFAULT NULL,
                         p_window_title    IN Varchar2 DEFAULT NULL)
return VARCHAR2;

/*===========================================================================
                        PRIVATE PROCEDURES

  DESCRIPTION:          Do not call these procedures directly since their
                        prototype may change.

============================================================================*/
procedure Error;

procedure LovApplet(doc_name        varchar2,
                    column_names    varchar2,
                    query_params    varchar2,
                    query_plsql     varchar2,
                    callback        varchar2 default null,
                    callback_params varchar2 default null,
                    longlist        varchar2,
                    initial_find    varchar2 default null,
                    width           varchar2,
                    height          varchar2,
                    window_title    varchar2 default null);

/*
** This procedure is a combination of display_lov, display_lov_find and
** display_lov_details for new UI design with no frame
 */
procedure display_lov_no_frame
(
p_lov_name            in varchar2 default null,
p_display_name        in varchar2 default null,
p_validation_callback in varchar2 default null,
p_dest_hidden_field   in varchar2 default null,
p_dest_display_field  in varchar2 default null,
p_current_value       in varchar2 default null,
p_start_row           in varchar2 default null,
p_autoquery           in varchar2 default 'Y',
p_language	      in varchar2 default 'US'
);

/*
** Bug 1380107. Pass in the non-translated key p_display_name_key
** instead of the translated multibyte value in p_display_name.
** This routine will use the key to find the translated value and call
** the procedure display_lov_no_frame.
 */
procedure display_lov_no_frame_key
(
p_lov_name            in varchar2 default null,
p_display_name_key    in varchar2 default null,
p_validation_callback in varchar2 default null,
p_dest_hidden_field   in varchar2 default null,
p_dest_display_field  in varchar2 default null,
p_current_value       in varchar2 default null,
p_start_row           in varchar2 default null,
p_autoquery           in varchar2 default 'Y',
p_language            in varchar2 default 'US'
);

/*  Bug 1904844

procedure display_lov_key
(
p_lov_name      in varchar2 default null,
p_display_name_key        in varchar2 default null,
p_validation_callback in varchar2 default null,
p_dest_hidden_field   in varchar2 default null,
p_dest_display_field  in varchar2 default null,
p_current_value       in varchar2 default null,
p_param1              in varchar2 default null,
p_param2              in varchar2 default null,
p_param3              in varchar2 default null,
p_param4              in varchar2 default null,
p_param5              in varchar2 default null
);  */

end WF_LOV;

 

/
