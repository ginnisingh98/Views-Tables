--------------------------------------------------------
--  DDL for Package Body ICX_QUESTIONS_ADMIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_QUESTIONS_ADMIN" AS
/* $Header: ICXQUADB.pls 115.2 1999/12/09 22:54:02 pkm ship      $ */

/*
** We need need to fetch URL prefix from WF_WEB_AGENT in wf_resources
** since this function gets called from the forms environment
** which doesn't know anything about the cgi variables.
*/
dm_base_url varchar2(240) := wf_core.translate('WF_WEB_AGENT');

--
-- Error (PRIVATE)
--   Print a page with an error message.
--   Errors are retrieved from these sources in order:
--     1. wf_core errors
--     2. Oracle errors
--     3. Unspecified INTERNAL error
--
procedure Error
as
  error_name      varchar2(30);
  error_message   varchar2(2000);
  error_stack     varchar2(32000);
begin
    htp.htmlOpen;
    htp.headOpen;
    htp.title(wf_core.translate('ERROR'));
    htp.headClose;

    begin
      wfa_sec.Header(background_only=>TRUE);
    exception
      when others then
        htp.bodyOpen;
    end;

    htp.header(nsize=>1, cheader=>wf_core.translate('ERROR'));

    wf_core.get_error(error_name, error_message, error_stack);

    if (error_name is not null) then
        htp.p(error_message);
    else
        htp.p(sqlerrm);
    end if;

    htp.hr;
    htp.p(wf_core.translate('WFENG_ERRNAME')||':  '||error_name);
    htp.br;
    htp.p(wf_core.translate('WFENG_ERRSTACK')||': '||
          replace(error_stack,wf_core.newline,'<br>'));

    wfa_sec.Footer;
    htp.htmlClose;

end Error;

--
-- set_find_criteria  (PRIVATE)
--   Set the concatenated find criteria that will be used to
--   get_display_syntax to redraw the questions page.
--
function set_find_criteria (
P_APPLICATION_SHORT_NAME IN VARCHAR2,
P_QUESTION_CODE   IN VARCHAR2,
P_QUESTION        IN VARCHAR2)
RETURN VARCHAR2

as

begin

    return (wfa_html.conv_special_url_chars(P_APPLICATION_SHORT_NAME||
                               ':'||P_QUESTION_CODE||':'||P_QUESTION));

exception
    when others then
        raise;

END;


--
-- get_display_syntax  (PRIVATE)
--   Parse the different components of the find criteria and build
--   the url to get back to the display questions page
--
function get_display_syntax (p_find_criteria   IN    VARCHAR2) RETURN VARCHAR2
as

l_application_id            varchar2(80);
l_application_short_name    varchar2(80);
l_question_code             varchar2(30);
l_question                  varchar2(4000);
l_colon                     number;
l_temp_str                  varchar2(4000);

begin

    -- Set the l_temp_str
    l_temp_str := p_find_criteria;

    -- Parse application short name  from document information
    l_colon := instr(l_temp_str, ':');

    if ((l_colon <> 0) and (l_colon < 80)) then

       l_application_short_name := substrb(l_temp_str, 1, l_colon-1);

       -- get the document id and name off the rest of the string
       l_temp_str := substrb(l_temp_str, l_colon+1);

    end if;

    -- Parse question_code from document information
    l_colon := instr(l_temp_str, ':');

    if ((l_colon <> 0) and (l_colon < 80)) then

       l_question_code := substrb(l_temp_str, 1, l_colon-1);

       -- get the document id and name off the rest of the string
       l_temp_str := substrb(l_temp_str, l_colon+1);

    end if;

    -- Parse document id from document information
    l_colon := instr(l_temp_str, ':');

    l_question := substrb(l_temp_str, l_colon+1);


     return (wfa_html.base_url||'/icx_questions_admin.display_questions'||
             '?p_application_short_name='||wfa_html.conv_special_url_chars(l_application_short_name)||
             '&p_question_code='||wfa_html.conv_special_url_chars(l_question_code)||
             '&p_question='||wfa_html.conv_special_url_chars(l_question));

exception
    when others then
        raise;

END;

--
-- FIND_QUESTIONS
--   Search for questions
--
procedure FIND_QUESTIONS

IS

l_username           varchar2(80);
l_media              varchar2(240) := wfa_html.image_loc;
l_icon               varchar2(30) := 'FNDILOV.gif';
l_text               varchar2(30) := '';
l_onmouseover        varchar2(30) := wf_core.translate ('WFPREF_LOV');
l_url                varchar2(4000);
l_error_msg          varchar2(240);

BEGIN

  -- Check current user has admin authority
  wfa_sec.GetSession(l_username);

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('ICX_FIND_QUESTIONS_TITLE'));
  wfa_html.create_help_function('wf/links/dmr.htm?DMREP');
  fnd_document_management.get_open_dm_display_window;
  wf_lov.OpenLovWinHtml;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE, '', wf_core.translate('ICX_FIND_QUESTIONS_TITLE'), TRUE);

  htp.tableopen(calign=>'CENTER');

  htp.p('<FORM NAME="ICX_FIND_QUESTIONS" ACTION="icx_questions_admin.display_questions" METHOD="POST">');

  -- Application Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('ICX_APPLICATION'),
                calign=>'right');

    -- add LOV here: Note:bottom is name of frame.
    -- Note: The REPLACE function replaces all the space characters with
    -- the proper escape sequence.
    l_url := 'javascript:fnd_open_dm_display_window('||''''||
             REPLACE('wf_lov.display_lov?p_lov_name='||'questions'||
             '&p_display_name='||wf_core.translate('ICX_APPLICATION')||
             '&p_validation_callback=icx_questions_admin.application_lov'||
             '&p_dest_hidden_field=top.opener.document.ICX_FIND_QUESTIONS.p_application_short_name.value'||
             '&p_current_value=top.opener.document.ICX_FIND_QUESTIONS.p_application_short_name.value'||
             '&p_dest_display_field=top.opener.document.ICX_FIND_QUESTIONS.p_application_short_name.value',
               ' ', '%20')||''''||',400,500)';

  htp.tableData(htf.formText(cname=>'p_application_short_name', csize=>'25',
                             cvalue=>null, cmaxlength=>'50')||
                            '<A href='||l_url|| ' '||l_onmouseover||'>'||
                            '<IMG src="'||l_media||l_icon||
                            '" border=0></A>');

  htp.tablerowclose;


  -- Question Code
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('ICX_QUESTION_CODE'),
                calign=>'right');

  htp.tableData(htf.formText(cname=>'p_question_code', csize=>'25',
                             cvalue=>null, cmaxlength=>'30'));

  htp.tableRowClose;

  -- Question
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('ICX_QUESTION'),
                calign=>'right');

  htp.tableData(htf.formText(cname=>'p_question', csize=>'50',
                             cvalue=>null, cmaxlength=>'240'));

  htp.tableRowClose;

  htp.tableclose;

  htp.br;

  htp.tableopen(calign=>'CENTER');

  --Submit Button

  htp.tableRowOpen;

  htp.p('<TD>');

  wfa_html.create_reg_button ('javascript:document.ICX_FIND_QUESTIONS.submit()',
                              wf_core.translate ('FIND'),
                              wfa_html.image_loc,
                              'fndfind.gif',
                              wf_core.translate ('FIND'));

  htp.p('</TD>');

  htp.tableRowClose;

  htp.tableclose;

  htp.formClose;

  wfa_sec.Footer;
  htp.htmlClose;


exception
  when others then
    wf_core.context('icx_questions_admin', 'find_questions');
    icx_questions_admin.error;

END find_questions;

--
-- DISPLAY_QUESTIONS
--   Display a list of existing questions based on the query criteria provided
--
procedure DISPLAY_QUESTIONS
(
 P_APPLICATION_SHORT_NAME       IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION		        IN  VARCHAR2     DEFAULT NULL
)
is

  username varchar2(30);   -- Username to query

  l_error_msg varchar2(240);

  l_url                varchar2(240);
  l_media              varchar2(240) := wfa_html.image_loc;
  l_icon               varchar2(30);
  l_text               varchar2(30);
  l_onmouseover        varchar2(30);

  l_find_criteria      varchar2(4000);

  cursor quest_cursor is
    SELECT  FND.APPLICATION_SHORT_NAME,
            ICX.APPLICATION_ID,
            ICX.QUESTION_CODE,
            ICX.QUESTION
    FROM    ICX_QUESTIONS_VL ICX, FND_APPLICATION_VL FND
    WHERE   ICX.QUESTION_CODE LIKE UPPER(P_QUESTION_CODE) || '%'
    AND     ICX.QUESTION LIKE '%' ||P_QUESTION || '%'
    AND     ICX.TYPE = 'QUESTION'
    AND     (FND.APPLICATION_SHORT_NAME LIKE
                UPPER(P_APPLICATION_SHORT_NAME)||'%' OR
            P_APPLICATION_SHORT_NAME IS NULL)
    AND     FND.APPLICATION_ID = ICX.APPLICATION_ID
    ORDER   BY FND.APPLICATION_SHORT_NAME, ICX.QUESTION_CODE;

  l_questions   quest_cursor%rowtype;

  rowcount number;

begin

  /*
  ** Set the find criteria field so you don't have to pass an unlimited
  ** number of fields around to store the original search criteria
  */
  l_find_criteria :=
       icx_questions_admin.set_find_criteria (
           P_APPLICATION_SHORT_NAME, P_QUESTION_CODE, P_QUESTION);

  -- Check current user has admin authority
  wfa_sec.GetSession(username);

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.p('<BASE TARGET="_top">');
  htp.title(wf_core.translate('ICX_QUESTIONS_TITLE'));
  wfa_html.create_help_function('wf/links/dmr.htm?DMREP');
  htp.headClose;
  wfa_sec.Header(FALSE, 'icx_questions_admin.find_questions',wf_core.translate('ICX_QUESTIONS_TITLE'), FALSE);
  htp.br;

  -- Column headers
  htp.tableOpen('border=1 cellpadding=3 bgcolor=white width="100%"');
  htp.tableRowOpen(cattributes=>'bgcolor=#006699');

  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('ICX_APPLICATION')||'</font>',
		  calign=>'Center');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('ICX_QUESTION_CODE')||'</font>',
		  calign=>'Center');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('ICX_QUESTION')||'</font>',
		  calign=>'Center');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('ICX_EDIT_FUNCTIONS')||'</font>',
		  calign=>'Center');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('DELETE')||'</font>',
		  calign=>'Center');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableRowClose;

  -- Show all nodes
  for questions in quest_cursor loop

    htp.tableRowOpen(null, 'TOP');

    htp.tableData(questions.application_short_name, 'left');

    htp.tableData(htf.anchor2(
                    curl=>wfa_html.base_url||
                      '/icx_questions_admin.edit_question'||
                      '?p_application_id='||questions.application_id||
                      '&p_question_code='||wfa_html.conv_special_url_chars(questions.question_code)||
                      '&p_insert=FALSE'||
                      '&p_find_criteria='||l_find_criteria,
                  ctext=>questions.question_code, ctarget=>'_top'),
                  'Left');

    htp.tableData(questions.question, 'left');

    htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
                      '/icx_questions_admin.display_functions'||
                      '?p_question_code='||wfa_html.conv_special_url_chars(questions.question_code)||
                      '&p_find_criteria='||l_find_criteria,
                      ctext=>'<IMG SRC="'||wfa_html.image_loc||'FNDJLFOK.gif" BORDER=0>'),
                      'center', cattributes=>'valign="MIDDLE"');

    htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
                      '/icx_questions_admin.question_confirm_delete'||
                      '?p_application_id='||questions.application_id||
                      '&p_question_code='||wfa_html.conv_special_url_chars(questions.question_code)||
                      '&p_find_criteria='||l_find_criteria,
                      ctext=>'<IMG SRC="'||wfa_html.image_loc||'FNDIDELR.gif" BORDER=0>'),
                      'center', cattributes=>'valign="MIDDLE"');

  end loop;

  htp.tableclose;

  htp.br;

  htp.tableopen(calign=>'CENTER');

  --Add new node Button
  htp.tableRowOpen;

  l_url         := wfa_html.base_url||'/icx_questions_admin.edit_question'||
                      '?p_insert=TRUE'||
                      '&p_find_criteria='||l_find_criteria;
  l_icon        := 'FNDADD11.gif';
  l_text        := wf_core.translate ('WFDM_CREATE');
  l_onmouseover := wf_core.translate ('WFDM_CREATE');

  htp.p('<TD>');

  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  htp.tableRowClose;

  htp.tableclose;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    wf_core.context('icx_questions_admin', 'DISPLAY_QUESTIONS');
    icx_questions_admin.error;
end DISPLAY_QUESTIONS;

--
-- EDIT_QUESTION
--   Edit question content
--
procedure EDIT_QUESTION
(
 P_APPLICATION_ID 	        IN  VARCHAR2     DEFAULT NULL,
 P_APPLICATION_SHORT_NAME       IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_ERROR_MESSAGE                IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION                     IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL,
 P_INSERT                       IN  VARCHAR2     DEFAULT NULL
)
IS

L_APPLICATION_SHORT_NAME VARCHAR2(50)   := NULL;
L_APPLICATION_ID         NUMBER         := NULL;
L_QUESTION_CODE          VARCHAR2(30)   := NULL;
L_QUESTION               VARCHAR2(4000) := NULL;

l_username           varchar2(80);
l_media              varchar2(240) := wfa_html.image_loc;
l_icon               varchar2(30) := 'FNDILOV.gif';
l_text               varchar2(30) := '';
l_onmouseover        varchar2(30) := wf_core.translate ('WFPREF_LOV');
l_url                varchar2(4000);
l_error_msg          varchar2(240);

BEGIN

  -- Check current user has admin authority
  wfa_sec.GetSession(l_username);

  if (P_INSERT = 'FALSE' AND P_ERROR_MESSAGE IS NULL) THEN

     SELECT  FND.APPLICATION_SHORT_NAME,
             ICX.APPLICATION_ID,
             ICX.QUESTION_CODE,
             ICX.QUESTION
     INTO    L_APPLICATION_SHORT_NAME,
             L_APPLICATION_ID,
             L_QUESTION_CODE,
             L_QUESTION
     FROM    ICX_QUESTIONS_VL ICX, FND_APPLICATION_VL FND
     WHERE   ICX.QUESTION_CODE = P_QUESTION_CODE
     AND     ICX.TYPE = 'QUESTION'
     AND     ICX.APPLICATION_ID = P_APPLICATION_ID
     AND     FND.APPLICATION_ID = ICX.APPLICATION_ID;

  elsif (P_ERROR_MESSAGE IS NOT NULL) THEN

     L_APPLICATION_SHORT_NAME := P_APPLICATION_SHORT_NAME;
     L_APPLICATION_ID := P_APPLICATION_ID;
     L_QUESTION_CODE := P_QUESTION_CODE;
     L_QUESTION := P_QUESTION;

  end if;

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('ICX_EDIT_QUESTION_TITLE'));
  wfa_html.create_help_function('wf/links/dmr.htm?DMREP');
  fnd_document_management.get_open_dm_display_window;
  wf_lov.OpenLovWinHtml;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE, 'icx_questions_admin.find_questions', wf_core.translate('ICX_EDIT_QUESTION_TITLE'), TRUE);

  -- Print the error message if there is one
  if (P_ERROR_MESSAGE IS NOT NULL) THEN

     htp.br;
     htp.p('<B>'||wf_core.translate(P_ERROR_MESSAGE)||'</B>');
     htp.br;

  end if;

  htp.tableopen(calign=>'CENTER');

  if (P_INSERT = 'FALSE') THEN

     htp.p('<FORM NAME="ICX_EDIT_QUESTION" ACTION="icx_questions_admin.update_question" METHOD="POST">');

  else

     htp.p('<FORM NAME="ICX_EDIT_QUESTION" ACTION="icx_questions_admin.insert_question" METHOD="POST">');

  end if;

  htp.formHidden(cname=>'p_application_id', cvalue=>l_application_id);
  htp.formHidden(cname=>'p_find_criteria',  cvalue=>p_find_criteria);

  -- Application Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('ICX_APPLICATION'),
                calign=>'right');

    -- add LOV here: Note:bottom is name of frame.
    -- Note: The REPLACE function replaces all the space characters with
    -- the proper escape sequence.
    l_url := 'javascript:fnd_open_dm_display_window('||''''||
             REPLACE('wf_lov.display_lov?p_lov_name='||'questions'||
             '&p_display_name='||wf_core.translate('ICX_APPLICATION')||
             '&p_validation_callback=icx_questions_admin.application_lov'||
             '&p_dest_hidden_field=top.opener.document.ICX_EDIT_QUESTION.p_application_short_name.value'||
             '&p_current_value=top.opener.document.ICX_EDIT_QUESTION.p_application_short_name.value'||
             '&p_dest_display_field=top.opener.document.ICX_EDIT_QUESTION.p_application_short_name.value',
               ' ', '%20')||''''||',400,500)';

  htp.tableData(htf.formText(cname=>'p_application_short_name', csize=>'25',
                             cvalue=>l_application_short_name, cmaxlength=>'50')||
                            '<A href='||l_url|| ' '||l_onmouseover||'>'||
                            '<IMG src="'||l_media||l_icon||
                            '" border=0></A>');

  htp.tablerowclose;


  -- Question Code
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('ICX_QUESTION_CODE'),
                calign=>'right');

  IF (P_INSERT = 'FALSE') THEN

     htp.formHidden(cname=>'p_question_code',  cvalue=>l_question_code);

     htp.tableData(cvalue=>'<B>'||l_question_code||'</B>',
                   calign=>'left');

  ELSE

     htp.tableData(htf.formText(cname=>'p_question_code', csize=>'25',
                             cvalue=>l_question_code, cmaxlength=>'30'));

  END IF;

  htp.tableRowClose;

  -- question
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('ICX_QUESTION'),
                calign=>'right', cattributes=>'VALIGN="TOP"');

  htp.p ('<TD>');

  htp.formTextareaOpen(cname=>'p_question', nrows=>'8',
                              ncolumns=>'50',
                              cattributes=>'WRAP="SOFT"');

  htp.p (l_question);

  htp.formTextareaClose;

  htp.p ('</TD>');

  htp.tableRowClose;

  htp.tableclose;

  htp.br;

  htp.tableopen(calign=>'CENTER');

  --Submit Button

  htp.tableRowOpen;

  l_url         := 'javascript:document.ICX_EDIT_QUESTION.submit()';
  l_icon        := 'FNDJLFOK.gif';
  l_text        := wf_core.translate ('WFMON_OK');
  l_onmouseover := wf_core.translate ('WFMON_OK');

  htp.p('<TD>');

  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  l_url         := icx_questions_admin.get_display_syntax (p_find_criteria);
  l_icon        := 'FNDJLFCN.gif';
  l_text        := wf_core.translate ('CANCEL');
  l_onmouseover := wf_core.translate ('CANCEL');

  htp.p('<TD>');

  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  htp.tableRowClose;

  htp.tableclose;

  htp.formClose;

  wfa_sec.Footer;
  htp.htmlClose;


exception
  when others then
    wf_core.context('icx_questions_admin', 'edit_question');
    icx_questions_admin.error;

END edit_question;

--
-- INSERT_QUESTION
--   Insert a new question
--
procedure INSERT_QUESTION
(
 P_APPLICATION_ID               IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_APPLICATION_SHORT_NAME       IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION     	        IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
)
IS

L_ROWID            VARCHAR2(64);
L_APPLICATION_ID   NUMBER;
L_COUNT            NUMBER;
L_ERROR_MSG        VARCHAR2(80);

BEGIN

   SELECT COUNT(*)
   INTO   l_count
   FROM   FND_APPLICATION_VL FND
   WHERE  FND.APPLICATION_SHORT_NAME = UPPER(P_APPLICATION_SHORT_NAME);

   if (l_count = 0) THEN

     l_error_msg := 'ICX_INVALID_APPLICATION';

   end if;

   SELECT count(*)
   INTO   l_count
   FROM   ICX_QUESTIONS ICX
   WHERE  ICX.QUESTION_CODE = UPPER(P_QUESTION_CODE);

   if (l_count > 0) THEN

     l_error_msg := 'ICX_DUPLICATE_QUESTION_CODE';

   end if;

   if (P_QUESTION IS NULL OR P_QUESTION_CODE IS NULL) THEN

     l_error_msg := 'ICX_ALL_FIELDS_REQUIRED';

   end if;


   if (l_error_msg IS NOT NULL) THEN

      owa_util.redirect_url(curl=>wfa_html.base_url||'/'||'icx_questions_admin.edit_question'||
            '?p_application_id='||p_application_id||
            '&p_error_message='||l_error_msg||
            '&p_application_short_name='||UPPER(p_application_short_name)||
            '&p_question_code='||wfa_html.conv_special_url_chars(UPPER(p_question_code))||
            '&p_insert=TRUE'||
            '&p_find_criteria='||wfa_html.conv_special_url_chars(p_find_criteria)||
            '&p_question='||wfa_html.conv_special_url_chars(p_question),
   		    bclose_header=>TRUE);

   else

      SELECT APPLICATION_ID
      INTO   L_APPLICATION_ID
      FROM   FND_APPLICATION_VL FND
      WHERE  FND.APPLICATION_SHORT_NAME = UPPER(P_APPLICATION_SHORT_NAME);

      ICX_QUESTIONS_PKG.INSERT_ROW (
          L_ROWID,
          UPPER(P_QUESTION_CODE),
          L_APPLICATION_ID,
          'QUESTION',
          P_QUESTION,
          sysdate,
          1,
          sysdate,
          1,
         1);

      -- use owa_util.redirect_url to redirect the URL to the home page
      owa_util.redirect_url(curl=>icx_questions_admin.get_display_syntax (p_find_criteria),
	  		    bclose_header=>TRUE);

    END IF;



exception
  when others then
    wf_core.context('icx_questions_admin', 'insert_question');
    icx_questions_admin.error;

END insert_question;

--
-- UPDATE_QUESTION
--   Update question content
--
procedure UPDATE_QUESTION
(
 P_APPLICATION_ID               IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_APPLICATION_SHORT_NAME       IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION     	        IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
)
IS

L_COUNT            NUMBER;
L_ERROR_MSG        VARCHAR2(80);

BEGIN

   SELECT COUNT(*)
   INTO   l_count
   FROM   FND_APPLICATION_VL FND
   WHERE  FND.APPLICATION_SHORT_NAME = UPPER(P_APPLICATION_SHORT_NAME);

   if (l_count = 0) THEN

     l_error_msg := 'ICX_INVALID_APPLICATION';

   end if;

   if (P_QUESTION IS NULL OR P_QUESTION_CODE IS NULL) THEN

     l_error_msg := 'ICX_ALL_FIELDS_REQUIRED';

   end if;


   if (l_error_msg IS NOT NULL) THEN

      owa_util.redirect_url(curl=>wfa_html.base_url||'/'||'icx_questions_admin.edit_question'||
            '?p_application_id='||p_application_id||
            '&p_error_message='||l_error_msg||
            '&p_application_short_name='||UPPER(p_application_short_name)||
            '&p_question_code='||wfa_html.conv_special_url_chars(p_question_code)||
            '&p_insert=FALSE'||
            '&p_find_criteria='||wfa_html.conv_special_url_chars(p_find_criteria)||
            '&p_question='||wfa_html.conv_special_url_chars(p_question),
   		    bclose_header=>TRUE);

   else

      ICX_QUESTIONS_PKG.UPDATE_ROW (
          P_QUESTION_CODE,
          P_APPLICATION_ID,
          'QUESTION',
          P_QUESTION,
          sysdate,
         1,
         1);

      -- use owa_util.redirect_url to redirect the URL to the home page
     owa_util.redirect_url(curl=>icx_questions_admin.get_display_syntax (p_find_criteria),
			    bclose_header=>TRUE);

   end if;

exception
  when others then
    wf_core.context('icx_questions_admin', 'update_question');
    icx_questions_admin.error;

END update_question;

/*===========================================================================

Function	question_confirm_delete

Purpose		Provide a confirmation message to delete a message

============================================================================*/
procedure question_confirm_delete
(p_application_id  IN VARCHAR2   DEFAULT NULL,
p_question_code   IN VARCHAR2   DEFAULT NULL,
p_find_criteria   IN VARCHAR2   DEFAULT NULL
)
IS
  username             varchar2(240);
  l_url                varchar2(240);
  l_media              varchar2(240) := wfa_html.image_loc;
  l_icon               varchar2(30);
  l_text               varchar2(30);
  l_onmouseover        varchar2(30);
  l_error_msg          varchar2(2000);
  s0                   varchar2(2000);
BEGIN
  -- Check current user has admin authority
  wfa_sec.GetSession(username);

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.p('<BASE TARGET="_top">');
  htp.title(wf_core.translate('ICX_CONFIRMTITLE'));
  wfa_html.create_help_function('wf/links/dmn.htm?DMND');
  htp.headClose;
  wfa_sec.Header(FALSE, 'icx_questions_admin.find_questions',wf_core.translate('ICX_CONFIRMTITLE'), FALSE);
  htp.br;

  htp.bodyOpen(cattributes=>'bgcolor="#CCCCCC"');
  htp.tableOpen(calign=>'CENTER');
  htp.tableRowOpen;
  htp.tabledata('<IMG SRC="'||wfa_html.image_loc||'prohibit.gif">');
  htp.tabledata(wf_core.translate('ICX_CONFIRM_DELETE_MESSAGE') || ':&nbsp' ||
                '<B>'||p_question_code||'</B>');
   htp.tableRowClose;
   htp.tableClose;
  htp.br;
  htp.tableopen(calign=>'CENTER');
  --Submit Button
  htp.tableRowOpen;
  l_url         := wfa_html.base_url||'/icx_questions_admin.delete_question'||
                   '?p_application_id='||p_application_id||
                   '&p_question_code='||wfa_html.conv_special_url_chars(p_question_code)||
                   '&p_find_criteria='||wfa_html.conv_special_url_chars(p_find_criteria);
  l_icon        := 'FNDJLFOK.gif';
  l_text        := wf_core.translate ('WFMON_OK');
  l_onmouseover := wf_core.translate ('WFMON_OK');

  htp.p('<TD>');
  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);
  htp.p('</TD>');

  l_url         := icx_questions_admin.get_display_syntax (p_find_criteria);
  l_icon        := 'FNDJLFCN.gif';
  l_text        := wf_core.translate ('CANCEL');
  l_onmouseover := wf_core.translate ('CANCEL');

  htp.p('<TD>');
  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);
  htp.p('</TD>');

  htp.tableRowClose;
  htp.tableclose;
  htp.formClose;
  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    rollback;
    wf_core.context('icx_questions_admin', 'question_confirm_delete');
    icx_questions_admin.Error;
END Question_Confirm_Delete;


--
-- DELETE_QUESTION
--   Delete question content
--
procedure DELETE_QUESTION
(
 P_APPLICATION_ID               IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
)
IS

BEGIN

   delete from icx_question_functions where question_code = p_question_code;
   delete from icx_questions_tl where question_code = p_question_code;
   delete from icx_questions where question_code = p_question_code;

   -- use owa_util.redirect_url to redirect the URL to the home page
   owa_util.redirect_url(curl=>icx_questions_admin.get_display_syntax (p_find_criteria),
			    bclose_header=>TRUE);

exception
  when others then
    wf_core.context('icx_questions_admin', 'delete_question');
    icx_questions_admin.error;

END delete_question;

--
-- application_lov
--   Create the data for the applications list of values
--

procedure  application_LOV (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out varchar2,
p_display_value  in out varchar2,
p_result         out number)

IS

CURSOR c_application_lov (c_find_criteria IN VARCHAR2) IS
SELECT
 application_id,
 application_short_name,
 application_name
FROM   fnd_application_vl
WHERE  application_short_name like UPPER(c_find_criteria)
ORDER  BY application_short_name;

CURSOR c_application_display_value (c_id IN VARCHAR2) IS
SELECT
 application_short_name
FROM   fnd_application_vl
WHERE  application_id = c_id;

ii           NUMBER := 0;
nn           NUMBER := 0;
l_total_rows NUMBER := 0;
l_id         NUMBER;
l_name       VARCHAR2 (30);
l_display_name       VARCHAR2 (240);
l_result     NUMBER := 1;  -- This is the return value for each mode

BEGIN

if (p_mode = 'LOV') then

   /*
   ** Need to get a count on the number of rows that will meet the
   ** criteria before actually executing the fetch to show the user
   ** how many matches are available.
   */
   select count(*)
   into   l_total_rows
   FROM   fnd_application_vl
   WHERE  application_short_name like UPPER(p_display_value||'%');

   wf_lov.g_define_rec.total_rows := l_total_rows;

   wf_lov.g_define_rec.add_attr1_title := wf_core.translate ('ICX_APPLICATION_FULLNAME');

   open c_application_lov (p_display_value||'%');

   LOOP

     FETCH c_application_lov INTO l_id, l_name, l_display_name;

     EXIT WHEN c_application_lov%NOTFOUND OR nn >= p_max_rows;

     ii := ii + 1;

     IF (ii >= p_start_row) THEN

        nn := nn + 1;

        wf_lov.g_value_tbl(nn).hidden_key      := l_name;
        wf_lov.g_value_tbl(nn).display_value   := l_name;
        wf_lov.g_value_tbl(nn).add_attr1_value := l_display_name;

     END IF;

   END LOOP;

   l_result := 1;

elsif (p_mode = 'GET_DISPLAY_VAL') THEN

   l_result := 1;

elsif (p_mode = 'VALIDATE') THEN

   l_result := 1;

end if;

p_result := l_result;

exception
  when others then
    rollback;
    wf_core.context('Wfa_Html', 'wf_user_val');
    raise;
end application_lov;

--
-- DISPLAY_FUNCTIONS
--   Display a list of existing questions based on the query criteria provided
--
procedure DISPLAY_FUNCTIONS
(
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA		IN  VARCHAR2     DEFAULT NULL
)
is

  username varchar2(30);   -- Username to query

  l_error_msg varchar2(240);

  l_url                varchar2(240);
  l_media              varchar2(240) := wfa_html.image_loc;
  l_icon               varchar2(30);
  l_text               varchar2(30);
  l_onmouseover        varchar2(30);

  cursor function_cursor is
    SELECT  FND.FUNCTION_NAME,
            FND.FUNCTION_ID,
            FND.USER_FUNCTION_NAME
    FROM    ICX_QUESTION_FUNCTIONS ICX, FND_FORM_FUNCTIONS_VL FND
    WHERE   ICX.QUESTION_CODE = P_QUESTION_CODE
    AND     ICX.FUNCTION_NAME = FND.FUNCTION_NAME
    ORDER   BY FND.FUNCTION_NAME;

  l_functions   function_cursor%rowtype;

  rowcount number;

begin

  -- Check current user has admin authority
  wfa_sec.GetSession(username);

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.p('<BASE TARGET="_top">');
  htp.title(wf_core.translate('ICX_FUNCTIONS_TITLE'));
  wfa_html.create_help_function('wf/links/dmr.htm?DMREP');
  htp.headClose;
  wfa_sec.Header(FALSE, 'icx_questions_admin.find_questions',wf_core.translate('ICX_FUNCTIONS_TITLE'), FALSE);
  htp.br;

  -- Column headers
  htp.tableOpen('border=1 cellpadding=3 bgcolor=white width="100%"');
  htp.tableRowOpen(cattributes=>'bgcolor=#006699');

  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('ICX_QUESTION')||'</font>',
		  calign=>'Center');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('ICX_FUNCTION')||'</font>',
		  calign=>'Center');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('ICX_USER_FUNCTION')||'</font>',
		  calign=>'Center');
  htp.tableHeader(cvalue=>'<font color=#FFFFFF>'||
		  wf_core.translate('DELETE')||'</font>',
		  calign=>'Center');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableRowClose;

  -- Show all nodes
  for functions in function_cursor loop

    htp.tableRowOpen(null, 'TOP');

    htp.tableData(p_question_code, 'left');

    htp.tableData(htf.anchor2(
                    curl=>wfa_html.base_url||
                      '/icx_questions_admin.edit_function'||
                      '?p_question_code='||wfa_html.conv_special_url_chars(p_question_code)||
                      '&p_function_id='||functions.function_id||
                      '&p_function_name='||wfa_html.conv_special_url_chars(functions.function_name)||
                      '&p_insert=FALSE'||
                      '&p_find_criteria='||wfa_html.conv_special_url_chars(p_find_criteria),
                  ctext=>functions.function_name, ctarget=>'_top'),
                  'Left');

    htp.tableData(functions.user_function_name, 'left');

    htp.tableData(htf.anchor2(curl=>wfa_html.base_url||
                      '/icx_questions_admin.delete_function'||
                      '?p_question_code='||wfa_html.conv_special_url_chars(p_question_code)||
                      '&p_function_name='||wfa_html.conv_special_url_chars(functions.function_name)||
                      '&p_find_criteria='||wfa_html.conv_special_url_chars(p_find_criteria),
                      ctext=>'<IMG SRC="'||wfa_html.image_loc||'FNDIDELR.gif" BORDER=0>'),
                      'center', cattributes=>'valign="MIDDLE"');

  end loop;

  htp.tableclose;

  htp.br;

  htp.tableopen(calign=>'CENTER');

  --Add new node Button
  htp.tableRowOpen;

  l_url         := wfa_html.base_url||'/icx_questions_admin.edit_function'||
                      '?p_question_code='||wfa_html.conv_special_url_chars(p_question_code)||
                      '&p_insert=TRUE'||
                      '&p_find_criteria='||wfa_html.conv_special_url_chars(p_find_criteria);
  l_icon        := 'FNDADD11.gif';
  l_text        := wf_core.translate ('WFDM_CREATE');
  l_onmouseover := wf_core.translate ('WFDM_CREATE');

  htp.p('<TD>');

  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  l_url         := icx_questions_admin.get_display_syntax (p_find_criteria);
  l_icon        := 'FNDJLFCN.gif';
  l_text        := wf_core.translate ('ICX_RETURN_TO_QUESTIONS');
  l_onmouseover := wf_core.translate ('ICX_RETURN_TO_QUESTIONS');

  htp.p('<TD>');

  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  htp.tableRowClose;

  htp.tableclose;

  wfa_sec.Footer;
  htp.htmlClose;

exception
  when others then
    wf_core.context('icx_questions_admin', 'DISPLAY_FUNCTIONS');
    icx_questions_admin.error;
end DISPLAY_FUNCTIONS;


--
-- EDIT_FUNCTION
--   Edit function content
--
procedure EDIT_FUNCTION
(
 P_QUESTION_CODE		IN  VARCHAR2     DEFAULT NULL,
 P_FUNCTION_ID                  IN  VARCHAR2     DEFAULT NULL,
 P_FUNCTION_NAME                IN  VARCHAR2     DEFAULT NULL,
 P_INSERT                       IN  VARCHAR2     DEFAULT NULL,
 P_ERROR_MESSAGE                IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
)
IS

L_FUNCTION_ID            NUMBER         := 0;
L_FUNCTION_NAME          VARCHAR2(30)   := NULL;
L_USER_FUNCTION_NAME     VARCHAR2(80)   := NULL;

l_username           varchar2(80);
l_media              varchar2(240) := wfa_html.image_loc;
l_icon               varchar2(30) := 'FNDILOV.gif';
l_text               varchar2(30) := '';
l_onmouseover        varchar2(30) := wf_core.translate ('WFPREF_LOV');
l_url                varchar2(4000);
l_error_msg          varchar2(240);

BEGIN

  -- Check current user has admin authority
  wfa_sec.GetSession(l_username);

  if (P_INSERT = 'FALSE' AND P_ERROR_MESSAGE IS NULL) THEN

     SELECT  FND.FUNCTION_ID,
             FND.FUNCTION_NAME,
             FND.USER_FUNCTION_NAME
     INTO    L_FUNCTION_ID,
             L_FUNCTION_NAME,
             L_USER_FUNCTION_NAME
     FROM    FND_FORM_FUNCTIONS_VL FND
     WHERE   FND.FUNCTION_ID = P_FUNCTION_ID;

  elsif (P_ERROR_MESSAGE IS NOT NULL) THEN

    L_FUNCTION_ID := P_FUNCTION_ID;
    L_FUNCTION_NAME := P_FUNCTION_NAME;

  end if;

  -- Set page title
  htp.htmlOpen;
  htp.headOpen;
  htp.title(wf_core.translate('ICX_EDIT_FUNCTION_TITLE'));
  wfa_html.create_help_function('wf/links/dmr.htm?DMREP');
  fnd_document_management.get_open_dm_display_window;
  wf_lov.OpenLovWinHtml;

  htp.headClose;

  -- Page header
  wfa_sec.Header(FALSE, 'icx_questions_admin.find_questions', wf_core.translate('ICX_EDIT_FUNCTION_TITLE'), TRUE);

  -- Print the error message if there is one
  if (P_ERROR_MESSAGE IS NOT NULL) THEN

     htp.br;
     htp.p('<B>'||wf_core.translate(P_ERROR_MESSAGE)||'</B>');
     htp.br;

  end if;

  htp.tableopen(calign=>'CENTER');

  if (P_INSERT = 'FALSE') THEN

     htp.p('<FORM NAME="ICX_EDIT_FUNCTION" ACTION="icx_questions_admin.update_function" METHOD="POST">');

  else

     htp.p('<FORM NAME="ICX_EDIT_FUNCTION" ACTION="icx_questions_admin.insert_function" METHOD="POST">');

  end if;

  htp.formHidden(cname=>'p_function_id', cvalue=>p_function_id);
  htp.formHidden(cname=>'p_old_function_name',  cvalue=>p_function_name);
  htp.formHidden(cname=>'p_find_criteria',  cvalue=>p_find_criteria);

  -- Question Code
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('ICX_QUESTION_CODE'),
                calign=>'right');

  htp.formHidden(cname=>'p_question_code',  cvalue=>p_question_code);

  htp.tableData(cvalue=>'<B>'||p_question_code||'</B>',
                calign=>'left');


  htp.tableRowClose;

  -- Function Name
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('ICX_FUNCTION'),
                calign=>'right');

    -- add LOV here: Note:bottom is name of frame.
    -- Note: The REPLACE function replaces all the space characters with
    -- the proper escape sequence.
    l_url := 'javascript:fnd_open_dm_display_window('||''''||
             REPLACE('wf_lov.display_lov?p_lov_name='||'functions'||
             '&p_display_name='||wf_core.translate('ICX_FUNCTION')||
             '&p_validation_callback=icx_questions_admin.function_lov'||
             '&p_dest_hidden_field=top.opener.document.ICX_EDIT_FUNCTION.p_function_name.value'||
             '&p_current_value=top.opener.document.ICX_EDIT_FUNCTION.p_function_name.value'||
             '&p_dest_display_field=top.opener.document.ICX_EDIT_FUNCTION.p_function_name.value',
               ' ', '%20')||''''||',400,500)';


  htp.tableData(htf.formText(cname=>'p_function_name', csize=>'25',
                             cvalue=>l_function_name, cmaxlength=>'50')||
                            '<A href='||l_url|| ' '||l_onmouseover||'>'||
                            '<IMG src="'||l_media||l_icon||
                            '" border=0></A>');

  htp.tablerowclose;

  -- Function Desciption
  htp.tableRowOpen;
  htp.tableData(cvalue=>wf_core.translate('ICX_FUNCTION_DESCRIPTION'),
                calign=>'right');

  htp.tableData(htf.formText(cname=>'p_user_function_name', csize=>'40',
                             cvalue=>l_user_function_name, cmaxlength=>'240'));

  htp.tableRowClose;

  htp.tableclose;

  htp.br;

  htp.tableopen(calign=>'CENTER');

  --Submit Button

  htp.tableRowOpen;

  l_url         := 'javascript:document.ICX_EDIT_FUNCTION.submit()';
  l_icon        := 'FNDJLFOK.gif';
  l_text        := wf_core.translate ('WFMON_OK');
  l_onmouseover := wf_core.translate ('WFMON_OK');

  htp.p('<TD>');

  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  l_url         := wfa_html.base_url||'/'||'icx_questions_admin.display_functions'||
                   '?p_question_code='||wfa_html.conv_special_url_chars(p_question_code)||
                   '&p_find_criteria='||wfa_html.conv_special_url_chars(p_find_criteria);
  l_icon        := 'FNDJLFCN.gif';
  l_text        := wf_core.translate ('CANCEL');
  l_onmouseover := wf_core.translate ('CANCEL');

  htp.p('<TD>');

  wf_pref.create_reg_button (l_url, l_onmouseover, l_media, l_icon, l_text);

  htp.p('</TD>');

  htp.tableRowClose;

  htp.tableclose;

  htp.formClose;

  wfa_sec.Footer;
  htp.htmlClose;


exception
  when others then
    wf_core.context('icx_questions_admin', 'edit_function');
    icx_questions_admin.error;

END edit_function;


--
-- function_lov
--   Create the data for the function list of values
--

procedure  function_lov (
p_mode           in varchar2,
p_lov_name       in varchar2,
p_start_row      in number,
p_max_rows       in number,
p_hidden_value   in out varchar2,
p_display_value  in out varchar2,
p_result         out number)

IS

CURSOR c_function_lov (c_find_criteria IN VARCHAR2) IS
SELECT FND.FUNCTION_ID,
       FND.FUNCTION_NAME,
       FND.USER_FUNCTION_NAME
FROM   FND_FORM_FUNCTIONS_VL FND
WHERE  FND.FUNCTION_NAME like upper(c_find_criteria)
ORDER  BY fnd.function_name;

CURSOR c_function_display_value (c_id IN VARCHAR2) IS
SELECT
 application_short_name
FROM   fnd_application_vl
WHERE  application_id = c_id;

ii           NUMBER := 0;
nn           NUMBER := 0;
l_total_rows NUMBER := 0;
l_id         NUMBER;
l_name       VARCHAR2 (240);
l_display_name       VARCHAR2 (2000);
l_result     NUMBER := 1;  -- This is the return value for each mode

BEGIN

if (p_mode = 'LOV') then

   /*
   ** Need to get a count on the number of rows that will meet the
   ** criteria before actually executing the fetch to show the user
   ** how many matches are available.
   */
   select count(*)
   into   l_total_rows
   FROM   FND_FORM_FUNCTIONS_VL FND
   WHERE  FND.FUNCTION_NAME like upper(p_display_value||'%');

   wf_lov.g_define_rec.total_rows := l_total_rows;

   wf_lov.g_define_rec.add_attr1_title := wf_core.translate ('ICX_USER_FUNCTION');

   open c_function_lov (p_display_value||'%');

   LOOP

     FETCH c_function_lov INTO l_id, l_name, l_display_name;

     EXIT WHEN c_function_lov%NOTFOUND OR nn >= p_max_rows;

     ii := ii + 1;

     IF (ii >= p_start_row) THEN

        nn := nn + 1;

        wf_lov.g_value_tbl(nn).hidden_key      := l_name;
        wf_lov.g_value_tbl(nn).display_value   := l_name;
        wf_lov.g_value_tbl(nn).add_attr1_value := l_display_name;

     END IF;

   END LOOP;

   l_result := 1;

elsif (p_mode = 'GET_DISPLAY_VAL') THEN

   l_result := 1;

elsif (p_mode = 'VALIDATE') THEN

   l_result := 1;

end if;

p_result := l_result;

exception
  when others then
    rollback;
    wf_core.context('Wfa_Html', 'wf_user_val');
    raise;
end function_lov;


--
-- INSERT_FUNCTION
--   Insert a new function
--
procedure INSERT_FUNCTION
(
 P_FUNCTION_ID                  IN  VARCHAR2     DEFAULT NULL,
 P_OLD_FUNCTION_NAME		IN  VARCHAR2     DEFAULT NULL,
 P_FUNCTION_NAME		IN  VARCHAR2     DEFAULT NULL,
 P_USER_FUNCTION_NAME           IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE     	        IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
)
IS

L_ROWID            VARCHAR2(64);
L_COUNT            NUMBER;
L_ERROR_MSG        VARCHAR2(80);

BEGIN

   SELECT COUNT(*)
   INTO   l_count
   FROM   FND_FORM_FUNCTIONS_VL FND
   WHERE  FND.FUNCTION_NAME = P_FUNCTION_NAME;

   if (l_count = 0) THEN

     l_error_msg := 'ICX_INVALID_FUNCTION';

   end if;

   SELECT COUNT(*)
   INTO   l_count
   FROM   ICX_QUESTION_FUNCTIONS ICX
   WHERE  ICX.FUNCTION_NAME = P_FUNCTION_NAME
   AND    ICX.QUESTION_CODE = P_QUESTION_CODE;

   if (l_count > 0) THEN

     l_error_msg := 'ICX_DUPLICATE_FUNCTION';

   end if;


   if (l_error_msg IS NOT NULL) THEN

      owa_util.redirect_url(curl=>wfa_html.base_url||'/'||'icx_questions_admin.edit_function'||
            '?p_question_code='||wfa_html.conv_special_url_chars(p_question_code)||
            '&p_function_id='||p_function_id||
            '&p_function_name='||wfa_html.conv_special_url_chars(p_function_name)||
            '&p_insert=TRUE'||
            '&p_error_message='||l_error_msg||
            '&p_find_criteria='||wfa_html.conv_special_url_chars(p_find_criteria),
   		    bclose_header=>TRUE);

   else

      INSERT INTO ICX_QUESTION_FUNCTIONS
      (QUESTION_CODE,
       FUNCTION_NAME,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY
     )
     VALUES
       (P_QUESTION_CODE,
       P_FUNCTION_NAME,
       sysdate,
       1,
       sysdate,
       1
      );

      -- use owa_util.redirect_url to redirect the URL to the home page
      owa_util.redirect_url(curl=>wfa_html.base_url||'/'||'icx_questions_admin.display_functions'||
                      '?p_question_code='||wfa_html.conv_special_url_chars(p_question_code)||
                      '&p_find_criteria='||wfa_html.conv_special_url_chars(p_find_criteria),
			    bclose_header=>TRUE);

    end if;

exception
  when others then
    wf_core.context('icx_questions_admin', 'insert_function');
    icx_questions_admin.error;

END insert_function;

--
-- UPDATE_FUNCTION
--   Update an existing function
--
procedure UPDATE_FUNCTION
(
 P_FUNCTION_ID                  IN  VARCHAR2     DEFAULT NULL,
 P_OLD_FUNCTION_NAME		IN  VARCHAR2     DEFAULT NULL,
 P_FUNCTION_NAME		IN  VARCHAR2     DEFAULT NULL,
 p_USER_FUNCTION_NAME           IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE     	        IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
)
IS

L_ROWID        VARCHAR2(64);
L_COUNT            NUMBER;
L_ERROR_MSG        VARCHAR2(80);

BEGIN

   SELECT COUNT(*)
   INTO   l_count
   FROM   FND_FORM_FUNCTIONS_VL FND
   WHERE  FND.FUNCTION_NAME = P_FUNCTION_NAME;

   if (l_count = 0) THEN

     l_error_msg := 'ICX_INVALID_FUNCTION';

   end if;

   SELECT COUNT(*)
   INTO   l_count
   FROM   ICX_QUESTION_FUNCTIONS ICX
   WHERE  ICX.FUNCTION_NAME = P_FUNCTION_NAME
   AND    ICX.QUESTION_CODE = P_QUESTION_CODE;

   if (l_count > 0) THEN

     l_error_msg := 'ICX_DUPLICATE_FUNCTION';

   end if;

   if (l_error_msg IS NOT NULL) THEN

      owa_util.redirect_url(curl=>wfa_html.base_url||'/'||'icx_questions_admin.edit_function'||
            '?p_question_code='||wfa_html.conv_special_url_chars(p_question_code)||
            '&p_function_id='||p_function_id||
            '&p_function_name='||wfa_html.conv_special_url_chars(p_function_name)||
            '&p_insert=TRUE'||
            '&p_error_message='||l_error_msg||
            '&p_find_criteria='||wfa_html.conv_special_url_chars(p_find_criteria),
   		    bclose_header=>TRUE);

   else

      UPDATE ICX_QUESTION_FUNCTIONS
      SET    FUNCTION_NAME = P_FUNCTION_NAME,
             LAST_UPDATE_DATE = sysdate,
             LAST_UPDATED_BY  = 1,
             LAST_UPDATE_LOGIN  = 1
      WHERE  QUESTION_CODE = P_QUESTION_CODE
      AND    FUNCTION_NAME   = P_OLD_FUNCTION_NAME;

      -- use owa_util.redirect_url to redirect the URL to the home page

      owa_util.redirect_url(curl=>wfa_html.base_url||'/'||'icx_questions_admin.display_functions'||
                      '?p_question_code='||wfa_html.conv_special_url_chars(p_question_code)||
                      '&p_find_criteria='||wfa_html.conv_special_url_chars(p_find_criteria),
		  	    bclose_header=>TRUE);

   end if;

exception
  when others then
    wf_core.context('icx_questions_admin', 'update_function');
    icx_questions_admin.error;

END update_function;


--
-- DELETE_FUNCTION
--   Delete an existing function
--
procedure DELETE_FUNCTION
(
 P_FUNCTION_ID                  IN  VARCHAR2     DEFAULT NULL,
 P_FUNCTION_NAME		IN  VARCHAR2     DEFAULT NULL,
 P_QUESTION_CODE     	        IN  VARCHAR2     DEFAULT NULL,
 P_FIND_CRITERIA                IN  VARCHAR2     DEFAULT NULL
)
IS

L_ROWID        VARCHAR2(64);

BEGIN

   DELETE FROM ICX_QUESTION_FUNCTIONS
   WHERE  QUESTION_CODE = P_QUESTION_CODE
   AND    FUNCTION_NAME = P_FUNCTION_NAME;

   -- use owa_util.redirect_url to redirect the URL to the home page
   owa_util.redirect_url(curl=>wfa_html.base_url||'/'||'icx_questions_admin.display_functions'||
                   '?p_question_code='||wfa_html.conv_special_url_chars(p_question_code)||
                   '&p_find_criteria='||wfa_html.conv_special_url_chars(p_find_criteria),
			    bclose_header=>TRUE);

exception
  when others then
    wf_core.context('icx_questions_admin', 'delete_function');
    icx_questions_admin.error;

END delete_function;

END icx_questions_admin;


/
