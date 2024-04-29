--------------------------------------------------------
--  DDL for Package WFA_HTML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WFA_HTML" AUTHID CURRENT_USER as
/* $Header: wfhtms.pls 120.2.12010000.1 2008/07/25 14:42:07 appldev ship $ */

--base_url       VARCHAR2(2000) := wf_core.translate('WF_WEB_AGENT');

image_loc      VARCHAR2(80) := '/OA_MEDIA/';

--
-- Types
--

-- complex name#type identifiers from the web page
type name_array is table of varchar2(240) index by binary_integer;

-- values from the web page.
type value_array is table of varchar2(4000) index by binary_integer;

--
-- Homemenu
--   Generate menu on Home page.
-- IN
--   message - optional message
-- NOTE
--   This page links to all other workflow web interfaces.
procedure Homemenu(
  message in varchar2 default null,
  origin in varchar2 default 'NORMAL');

procedure Home_float;


--
-- Home
--   Generates Home page.
-- IN
--   message - optional message
procedure Home(
  message in varchar2 default null);

procedure logout;

procedure Header;

--
-- Login
--   Generate login page.
-- IN
--   message - optional login message
-- NOTE
--   This page is only used to enable access when no external security
--   is installed.  Normally users are authenticated by the chosen
--   security system (IC, WebServer native, etc) and can then access
--   the Workflow Notification pages (Worklist, Detail) directly.
--
--
--  CTILLEY    Added i_direct arg - bug 1838410
--

procedure Login(
  message in varchar2 default null,
  i_direct in varchar2 default null);

--
-- Viewer
--   Validate user from Login page, then show worklist.
-- IN
--   user_id  - user name
--   password - user password
-- NOTE
--   This page is only used to enable access when no external security
--   is installed.  Normally users are authenticated by the chosen
--   security system (IC, WebServer native, etc) and can then access
--   the Workflow Notification pages (Worklist, Detail) directly.
--
--
--  CTILLEY    Added i_direct arg - bug 1838410
--

procedure Viewer(
  user_id in varchar2 default null,
  password in varchar2 default null,
  i_direct in varchar2 default null);

--
-- Find
--   Filter page to find notifications of user
--
procedure Find ;


--
-- WorkList
--   Construct the worklist (summary page) for user.
-- IN
--   orderkey - Key to order by (default PRIORITY)
--              Valid values are PRIORITY, MESSAGE_TYPE, SUBJECT, BEGIN_DATE,
--              DUE_DATE, END_DATE, STATUS.
--   status - Status to query (default OPEN)
--            Valid values are OPEN, CLOSED, CANCELED, ERROR.
--            If null query any status.
--   user - User to query notifications for.  If null query current user.
--          Note: only WF_ADMIN_ROLE can query other than the current user.
--   fromlogin - flag to indicate if coming from apps login screen,
--             - if non-zero, force an exception
--            - so that cookie value is not being used
--
procedure WorkList(
  nid      in number default null,
  orderkey in varchar2 default null,
  status in varchar2 default null,
  owner in varchar2 default null,
  display_owner in varchar2 default null,
  user in varchar2 default null,
  display_user in varchar2 default null,
  fromuser in varchar2 default null,
  display_fromuser in varchar2 default null,
  ittype in varchar2 default null,
  msubject in varchar2 default null,
  beg_sent in varchar2 default null,
  end_sent in varchar2 default null,
  beg_due in varchar2 default null,
  end_due in varchar2 default null,
  priority in varchar2 default null,
  delegatedto in varchar2 default null,
  display_delegatedto in varchar2 default null,
  delegated_by_me in number default 0,
  resetcookie in number default 0 ,
  clearbanner in varchar2 default 'FALSE',
  fromfindscreen in number default 0,
  fromlogin in number default 0);

--
-- DetailFrame
--   generate Detail notification screen
-- IN
--   nid - notification id
--   nkey - notification access key (for mailed html only)
--   agent - web agent (OBSOLETE)
--   showforms - show form attributes
--
procedure DetailFrame(
  nid in varchar2 default null,
  nkey in varchar2 default null,
  agent in varchar2 default null,
  showforms in varchar2 default null);

-- ResponseFrame
--   generate response frame contents
-- IN
--   nid - notification id
--   nkey - notification access key (for mailed html only)
--   agent - web agent (OBSOLETE)
--   showforms - show form attributes
procedure ResponseFrame(
  nid in varchar2 default null,
  nkey in varchar2 default null,
  agent in varchar2 default null,
  showforms in varchar2 default null);

-- ForwardFrame
--   generate forward frame contents
-- IN
--   nid - notification id
--   nkey - notification access key (for mailed html only)
procedure ForwardFrame(
  nid in varchar2 default null,
  nkey in varchar2 default null);

--
-- AttributeInfo
--   Generate page with details about a response attribute
-- IN
--   nid - notification id
--   name - attribute name
--
procedure AttributeInfo(
  nid in varchar2,
  name in varchar2);

-- Detail (PROCEDURE)
--   generate detail screen
-- IN
--   notification id
-- NOTE
--   Detail is overloaded.
--   This version is used by the Web notifications page.
procedure Detail(
  nid in varchar2 default null);

-- Detail (FUNCTION)
--   return standalone detail screen text
-- IN
--   nid - notification id
--   nkey - notification key
--   agent - web agent URL root
-- NOTE
--   Detail is overloaded.
--   This produces the version used by the mailer.
function Detail(
    nid   in number,
    nkey  in varchar2,
    agent in varchar2)
return varchar2;

-- Detail2 (FUNCTION)
--   return standalone detail screen text
-- IN
--   nid - notification id
--   nkey - notification key
--   agent - web agent URL root
-- NOTE
--   Detail is overloaded.
--   This produces the version used by the mailer.
function Detail2(
    nid   in number,
    nkey  in varchar2,
    agent in varchar2)
return varchar2;

-- DetailLink
--   display standalone detail screen text
-- IN
--   nid - notification id
--   nkey - notification key
--   agent - web agent URL root
-- NOTE
--   Detaillink called function Detail above.
--   This produces the version used by the mailer.
procedure DetailLink(
    nid   in number,
    nkey  in varchar2,
    agent in varchar2);


-- SubmitForward
--   Submit notification forward
-- IN
--   h_nid - notification id
--   forwardee - new recipient field
--   display_forwardee - display name for the new recipient
--   comments - forwarding comments field
--   fmode - reassign mode can be:
--           transfer - transferring responsibility
--           delegate - delegate responsibility
--   submit - submit forward button
--   cancel - cancel forward button
--   nkey - access key for mailed html
procedure SubmitForward(
  h_nid               in varchar2,
  forwardee           in varchar2,
  display_forwardee   in varchar2,
  comments            in varchar2 default null,
  fmode               in varchar2 default null,
  submit              in varchar2 default null,
  cancel              in varchar2 default null,
  nkey                in varchar2 default null);

-- SubmitResponse
--   Submit notification response
-- IN
--   h_nid - notification id
--   h_fnames - array of field names
--   h_fvalues - array of field values
--   h_fdocnames - array of documentnames
--   h_counter - number of fields passed in fnames and fvalues
--   submit - submit response button
--   forward - forward button
--   nkey - access key for mailed html
procedure SubmitResponse(
  h_nid        in varchar2,
  h_fnames     in Name_Array,
  h_fvalues    in Value_Array,
  h_fdocnames  in Value_Array,
  h_counter    in varchar2,
  submit       in varchar2 default null,
  forward      in varchar2 default null,
  nkey         in varchar2 default null);

-- SubmitSelectedResponse
--   Submit selected notification response
-- IN
--   nids    - notification ids
--   close   - close response button
--   forward - forward button
--   showto  - display the TO column
--   nkey    - access key for mailed html
procedure SubmitSelectedResponse(
  nids         in Name_Array,
  close        in varchar2 default null,
  forward      in varchar2 default null,
  showto       in varchar2 default 'F',
  nkey         in varchar2 default null);

-- ForwardNids
--   Forward (Delegating) for each notification ids
-- IN
--   h_nids - hidden notification ids
--   forwardee - forwardee role specified
--   display_forwardee - display name for the new recipient
--   comments -  comments included
--   fmode -     reassign mode can be:
--               transfer -  transferring responsibility
--               delegate -  delegate responsibility
--   submit   -  submit the reassign request
--   cancel - cancel button
procedure ForwardNids(
  h_nids               in Name_Array,
  forwardee            in varchar2,
  display_forwardee    in varchar2,
  comments             in varchar2 default null,
  fmode                in varchar2 default null,
  submit               in varchar2 default null,
  cancel               in varchar2 default null,
  nkey                 in varchar2 default null);

-- GotoURL
--   GotoURL let you open an url in a specify place.  This is very useful
--   when you need to go from a child frame to the full browser window,
--   for instnace.
-- IN
--   url - Fully qualified universal resouce location
--   location - Where you want to open it.  Samples of values are
--              _blank  - unnamed window
--              _self   - the current frame
--              _parent - the parent frame of the current one
--              _top    - the full Web browser window
--              "myWin" - name of the new window
--
procedure GotoURL(
  url in varchar2,
  location in varchar2 default '_self',
  attributes in varchar2 default NULL
);


/*===========================================================================
  PROCEDURE NAME:       create_help_function

  DESCRIPTION:
                        Create the java script function to support the Help
                        Icon from the header

  PARAMETERS:

        p_help_file IN  Name of .htl help file you would like to display in
                        help window.

============================================================================*/
procedure create_help_function (p_help_file IN VARCHAR2);


/*===========================================================================
  FUNCTION NAME:        conv_special_url_chars

  DESCRIPTION:
                        Convert all of the ASCII special characters that are
                        disallowed as a part of a URL.  The encoding requires
                        that we convert the special characters to HEX for
                        any characters in a URL string that is built
                        manually outside a form get/post.
                        This API now also converts multibyte characters
                        into their HEX equivalent.

  PARAMETERS:

        p_url_token IN  Token that will be converted

  NOTE:
                        This api allows double-encoding.
============================================================================*/
FUNCTION conv_special_url_chars (p_url_token IN VARCHAR2) RETURN VARCHAR2;

/*===========================================================================
  FUNCTION NAME:        encode_url (PRIVATE)

  DESCRIPTION:
                        Convert all of the ASCII special characters that are
                        disallowed as a part of a URL.  The encoding requires
                        that we convert the special characters to HEX for
                        any characters in a URL string that is built
                        manually outside a form get/post.
                        This API now also converts multibyte characters
                        into their HEX equivalent.

                        URL encoding was documented in RFC 1738.
                        We have put some "unsafe" characters in the encode
                        list for purpose of encoding them.

  NOTE:                 This private api does not allow double-encoding.
============================================================================*/
FUNCTION encode_url (p_url_token IN VARCHAR2) RETURN VARCHAR2;

--
-- User_LOV
--   Create the data for the User List of Values
--
procedure User_LOV (p_titles_only     IN VARCHAR2 DEFAULT NULL,
                    p_find_criteria IN VARCHAR2 DEFAULT NULL);

--
-- create_reg_button
--   Create a button that is an anchor.
--
procedure create_reg_button (
when_pressed_url  IN VARCHAR2,
onmouseover       IN VARCHAR2,
icon_top          IN VARCHAR2,
icon_name         IN VARCHAR2,
show_text         IN VARCHAR2);

-- show_plsql_doc
--   Show the content of a plsql document in a browser window
--   Called from the related documents function
procedure show_plsql_doc (
  nid in number,
  aname in varchar2,
  nkey in varchar2 default null);

-- base_url
-- Get the base url for the current browser where you have launched the
-- login for Workflow
function base_url (get_from_resources BOOLEAN default FALSE) return varchar2;

--
-- wf_user_val
--   Create the lov content for our user lov.  This function
--   is called by the generic lov function
-- IN
-- RETURNS
--
procedure  wf_user_val (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out nocopy varchar2,
p_display_value  in out nocopy varchar2,
p_result         out nocopy number);

-- replace_onMouseOver_quotes
-- The replace_quotes function takes a string as an in parameter, and
-- returns a string with all single and double quotes preceeded with a \.
-- This function is designed to escape out all quotes in a phrase that is
-- used with javascript.  The \ character is the escape character for
-- javascript.  If a string with quotes already preceeded by the \ escape
-- character is passed to the replace_quotes function, the return string
-- will only have one \ infront of each quote.
function replace_onMouseOver_quotes(p_string in varchar2) return varchar2;

-- validate_display_name
-- Validates that a display name is both unique and valid.  If the display
-- name is passed in then it will set the internal user name.
procedure validate_display_name (
p_display_name in varchar2,
p_user_name    in out nocopy varchar2);

-- LongDesc
--  Displays an html page with the token message.  This is called from
--  frames for the LONGDESC attribute.
procedure LongDesc (
p_token   in varchar2);

end WFA_HTML;

/
