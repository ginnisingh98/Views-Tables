--------------------------------------------------------
--  DDL for Package ORACLEAPPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ORACLEAPPS" AUTHID CURRENT_USER as
/* $Header: ICXSEXS.pls 120.0 2005/10/07 12:20:38 gjimenez noship $ */

-- added to support menu
TYPE menuItem IS RECORD (
	menuId		number,
        userMenuName    varchar2(80),
        menuURL         varchar2(2000));

TYPE menuItemTable IS TABLE OF menuItem
        index by binary_integer;

type l_v80_table is table of varchar2(80)
        index by binary_integer;

type l_v240_table is table of varchar2(240)
        index by binary_integer;

type l_v2000_table is table of varchar2(2000)
        index by binary_integer;

procedure VL(i_1    in      varchar2 default NULL,
            i_2     in      varchar2 default NULL,
	    i_3	    in	    varchar2 default NULL,
	    home_url in     varchar2 default NULL);

procedure DMM;

procedure DRM;

/* Bug 1545083 - added E param for forms call to use one time ticket */
procedure LF(F in      varchar2 default NULL,
             P in      varchar2 default NULL,
             E IN      varchar2 default NULL);

function createRFLink( p_text			varchar2,
		       p_application_id		number,
		       p_responsibility_id      number,
		       p_security_group_id      number,
		       p_function_id            number,
                       p_target                 varchar2 default '_top',
                       p_session_id             number   default null )
         return varchar2;

procedure RF(F in      varchar2,
             P in      varchar2 default NULL);

function Login(i_1    in      varchar2 default NULL,
               i_2     in      varchar2 default NULL,
	       i_3     out    nocopy number)
return BOOLEAN;

function Login(i_1	in	varchar2 default NULL,
               i_2	in	varchar2 default NULL,
	       i_3	in	varchar2,
	       i_4	out nocopy number)
return BOOLEAN;

procedure displayLogin(c_message in varchar2 default null,
		       c_display in varchar2 default 'IC',
		       c_logo    in varchar2 default 'Y',
                       i_direct IN VARCHAR2 DEFAULT NULL,
                       i_mode IN NUMBER DEFAULT '2',
                       recreate IN VARCHAR2 DEFAULT NULL,
                       p_home_url IN VARCHAR2 DEFAULT NULL);

procedure redirectURL(i_1 in varchar2,
                      i_2 in varchar2,
                      URL in varchar2,
                      A   in varchar2 default null,
                      R   in varchar2 default null,
                      S   in varchar2 default null);

procedure redirectURL(i_1 in varchar2,
                      i_2 in varchar2,
                      URL in varchar2,
                      F   in varchar2,
                      A   in varchar2 default null,
                      R   in varchar2 default null,
                      S   in varchar2 default null);

procedure displayResps(nri in varchar2 default NULL,
		       c_toolbar in varchar2 default 'Y');

procedure DSM(Q		in	varchar2);

procedure DSM_frame(Q 	in 	varchar2);

procedure runFunction(c_function_id in number,
		      n_session_id  in number,
                      c_parameters  in varchar2 default null,
                      p_resp_appl_id in number default null,
                      p_responsibility_id in number default null,
                      p_security_group_id in number default null,
                      p_menu_id in number default null,
                      p_function_type in varchar2 default null,
                      p_page_id in number default null);

procedure unpackParameters(p_parameters in varchar2,
                          p_names       out nocopy l_v80_table,
                          p_values      out nocopy l_v2000_table);

procedure unpackParameters(p_parameters	in varchar2,
		  	  p_names	out nocopy l_v80_table,
			  p_values	out nocopy l_v240_table);

function getFunctions
	return varchar2;

procedure DU;

procedure displayWebUser;
procedure displayWebUserlocal(p_message_flag varchar2 default 'Y');

procedure UUI(
                i_1     in      varchar2,
                i_2     in      varchar2,
                i_3     in      varchar2,
                i_4     in      varchar2,
                i_5     in      varchar2,
                i_6     in      varchar2,
                i_7     in      varchar2,
                i_8     in      varchar2 default null,
                i_9     in      varchar2,
                i_10    in      varchar2,
                i_11    IN      VARCHAR2 DEFAULT NULL,
                i_12    IN      VARCHAR2 DEFAULT NULL);

procedure updateWebUser(
                c_KNOWN_AS in varchar2 default null,
                c_LANGUAGE in varchar2 default null,
		          c_DATE_FORMAT in varchar2 default null,
                c_PASSWORD1 in varchar2 default null,
                c_PASSWORD2 in varchar2 default null,
                c_PASSWORD3 in varchar2 default null,
                c_MAILPREF  in varchar2 default null,
                c_DMPREF    in varchar2 default null,
                c_NUMERIC_CHARACTERS in varchar2 default null,
                c_TERRITORY in varchar2 default null,
                c_TIMEZONE IN VARCHAR2 DEFAULT NULL,
                c_ENCODING IN VARCHAR2 DEFAULT NULL);

procedure NP;

procedure displayNewPassword(i_1    in   varchar2 default null,
                             c_url  in   varchar2 default null,
                             c_mode_code in varchar2 default '115P');

procedure UNP(
                i_1         in  varchar2,
                i_2         in  varchar2,
                i_3         in  varchar2,
                i_4         in  varchar2,
                c_mode_code in  varchar2,
                c_url       in  varchar2 default null);

procedure updateNewFndPassword(
                c_USERNAME  in varchar2 default null,
                c_PASSWORD1 in varchar2 default null,
                c_PASSWORD2 in varchar2 default null,
                c_PASSWORD3 in varchar2 default null,
                p_mode_code in varchar2,
                c_url       in varchar2);

procedure updateNewPassword(
                c_USERNAME  in varchar2 default null,
                c_PASSWORD1 in varchar2 default null,
                c_PASSWORD2 in varchar2 default null,
                c_PASSWORD3 in varchar2 default null);

procedure icxLogin (rmode in number,
                    i_1   in varchar2,
                    i_2   in varchar2);

--added DF mputman 793404
PROCEDURE DF(i_direct IN VARCHAR2 DEFAULT NULL,
             i_mode IN NUMBER DEFAULT NULL);


c_ampersand constant varchar2(1) := '&';

G_RED	    constant varchar2(7) := 'CC0000';
G_GREEN	    constant varchar2(7) := '006666';
G_BROWN	    constant varchar2(7) := '993300';
G_PURPLE    constant varchar2(7) := '6600CC';

G_BLUE	    constant varchar2(7) := '0033FF';
G_OLIVE	    constant varchar2(7) := '426300';

/* Bug 1673370 - wrapper function for FORMS call to get one time ticket
NOTE: this should only be called from the FORMS tier, never via the web */
function FormsLF_prep(	c_string varchar2,
			c_session_id number default null) return varchar2;

PROCEDURE recreate_session (i_1 IN VARCHAR2,
                           i_2 IN VARCHAR2,
                           p_enc_session IN VARCHAR2,
                           p_mode IN VARCHAR2 DEFAULT '115p');

procedure ForgotPwd(c_user_name in varchar2);

procedure connectLogin(c_message in varchar2 default null,
                       c_display in varchar2 default 'IC',
                       c_logo    in varchar2 default 'Y',
                       c_mode IN NUMBER DEFAULT '2',
                       c_lang IN VARCHAR2 DEFAULT NULL);

procedure convertSession(c_token in VARCHAR2,
                      i_1 IN VARCHAR2 DEFAULT NULL,
                      i_2 IN VARCHAR2 DEFAULT NULL,
                      i_S IN VARCHAR2 DEFAULT NULL,
                      c_message in varchar2 default null);


end OracleApps;

 

/
