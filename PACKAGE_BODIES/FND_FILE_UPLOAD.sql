--------------------------------------------------------
--  DDL for Package Body FND_FILE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FILE_UPLOAD" as
/* $Header: AFAKFUPB.pls 120.5 2006/03/13 10:58:54 blash ship $ */


-- UploadCompleteMessage
--
--    Displays file upload compelte message.
--

procedure UploadCompleteMessage( file	varchar2,
				 access_id	number)
is
  l_file_id	number;
  invchr        number;
  fn            varchar2(256);
begin
if (icx_sec.ValidateSession) then
  l_file_id := fnd_gfm.confirm_upload(access_id    => access_id,
				      file_name	   => file,
				      program_name => 'FNDATTCH');

  fn := SUBSTR(file, INSTR(file,'/')+1);

/*  Backed out the change for invalid characters per bug 47309

  invchr := INSTR(fn,'&');
  if invchr > 0 then
     l_file_id := -2;
  end if;
  invchr := INSTR(fn,'%');
  if invchr > 0 then
     l_file_id := -2;
  end if;
  invchr := INSTR(fn,'?');
  if invchr > 0 then
     l_file_id := -2;
  end if;
 */

    -- bug 3045375, changed <> to > so <0 l_file_id goes to else.
  if (l_file_id > -1) then -- File upload completed
    htp.htmlOpen;
    htp.headOpen;
    htp.title(fnd_message.get_string('FND','FILE-UPLOAD PAGE TITLE'));
    htp.headClose;
    htp.bodyOpen;
    htp.img2('/OA_MEDIA/FNDLOGOS.gif',calign => 'Left',calt => 'Logo');
    htp.br;
    htp.br;
    htp.p('<h4>'||fnd_message.get_string('FND','FILE-UPLOAD PAGE HEADING')
                                                                ||'</h4>');
    htp.hr;
    htp.p (
       htf.bold(fnd_message.get_string('FND','FILE-UPLOAD COMPLETED MESSAGE')));
    htp.br;
    htp.p ('<h4>'||fnd_message.get_string('FND','FILE-UPLOAD CLOSE WEB BROWSER')
                                                                ||'</h4>');
    htp.p ('<h4>'||fnd_message.get_string('FND','FILE-UPLOAD CONFIRM UPLOAD')
                                                                ||'</h4>');
    htp.br;
    htp.bodyClose;
    htp.htmlClose;
  else -- File upload failed.
    htp.htmlOpen;
    htp.headOpen;
    htp.title(fnd_message.get_string('FND','FILE-UPLOAD PAGE TITLE'));
    htp.headClose;
    htp.bodyOpen;
    htp.img2('/OA_MEDIA/FNDLOGOS.gif',calign => 'Left',calt => 'Logo');
    htp.br;
    htp.br;
    htp.p('<h4>'||fnd_message.get_string('FND','FILE-UPLOAD PAGE HEADING')
                                                                ||'</h4>');
    htp.hr;
    -- bug 3045375, added if to throw invalid file message when l_file_id=-2
    if l_file_id <> -2 then
       htp.p (
         htf.bold(fnd_message.get_string('FND','FILE-UPLOAD FAILED')));
    else
       htp.p (
         htf.bold(fnd_message.get_string('FND','UPLOAD_FILESIZE_LIMIT')));
    end if;
    htp.br;
    htp.bodyClose;
    htp.htmlClose;
  end if;
end if;

end UploadCompleteMessage;

-- CancelProcess
--    Displays the file upload cancel message page.
--  IN
--	file_id	- Unique process to autenticate the file upload process.
--

procedure CancelProcess as

begin

if (icx_sec.ValidateSession) then

  -- Show a message page
  htp.htmlOpen;
  htp.headOpen;
  htp.title(fnd_message.get_string('FND','FILE-UPLOAD PAGE TITLE'));
  htp.headClose;
  htp.bodyOpen;
  htp.img2('/OA_MEDIA/FNDLOGOS.gif',calign => 'Left',calt => 'Logo');
  htp.br;
  htp.br;
  htp.p('<h4>'||fnd_message.get_string('FND','FILE-UPLOAD PAGE HEADING')
                                                                ||'</h4>');
  htp.hr;
  htp.p (htf.bold(fnd_message.get_string('FND','FILE-UPLOAD CANCEL MESSAGE')));
  htp.br;
  htp.p ('<h4>'||fnd_message.get_string('FND','FILE-UPLOAD CLOSE WEB BROWSER')
                                                                ||'</h4>');
  htp.p ('<h4>'|| fnd_message.get_string('FND','FILE-UPLOAD REJECT UPLOAD')
                                                                ||'</h4>');
  htp.br;
  htp.br;
  htp.br;
  htp.bodyClose;
  htp.htmlClose;

end if;

end CancelProcess;

--
-- DisplayGFMForm
--   access_id -  Access id for file in fnd_lobs
--   l_server_url - Obsolete, not used anymore
--
PROCEDURE DisplayGFMForm(access_id IN NUMBER, l_server_url VARCHAR2) IS
  l_cancel_url VARCHAR2(255);
  l_start_pos NUMBER := 1;
  l_length NUMBER := 0;
  upload_action VARCHAR2(2000);
  l_language varchar2(80);
BEGIN

if (icx_sec.ValidateSession) then

  -- Set the upload action
  upload_action := fnd_gfm.construct_upload_url(fnd_web_config.gfm_agent,
                                'fnd_file_upload.uploadcompletemessage',
                                access_id);

  -- Set page title and toolbar.
  htp.htmlOpen;
  htp.headOpen;
  htp.p( '<SCRIPT LANGUAGE="JavaScript">');
  htp.p( ' function processclick (cancel_url) {
                 if (confirm('||'"'||
		 fnd_message.get_string ('FND','FILE-UPLOAD CONFIRM CANCEL')
		 ||'"'||'))
                 {
                        parent.location=cancel_url
                 }
              }');
  htp.print(  '</SCRIPT>' );
  htp.title(fnd_message.get_string('FND','FILE-UPLOAD PAGE TITLE'));
  htp.headClose;
  htp.bodyOpen;
  htp.img2('/OA_MEDIA/FNDLOGOS.gif',calign => 'Left',calt => 'Logo');
  htp.br;
  htp.br;
  htp.p('<h4>'||fnd_message.get_string('FND','FILE-UPLOAD PAGE HEADING')
                                                                ||'</h4>');
  htp.hr;
  htp.br;
  htp.print( '</LEFT>' );

  htp.formOpen( curl => upload_action, cmethod => 'POST',
		cenctype=> 'multipart/form-data');
  htp.tableOpen(  cattributes => ' border=0 cellpadding=2 cellspacing=0' );
  htp.tableRowOpen;
  htp.tableRowClose;

  htp.tableRowOpen( cvalign => 'TOP' );
  htp.p('<TD>');
  htp.p('</TD>');
  htp.p('<label> '||fnd_message.get_string('FND','ATCHMT-FILE-PROMPT')||' </label>');
  htp.tableData( '<INPUT TYPE="File" NAME="file" SIZE="60">',
                                                        calign => 'left');
  htp.tableRowClose;
  htp.tableClose;

  -- Send access is as a hidden value
  htp.formHidden ( cname =>'access_id', cvalue=> to_char(access_id) );
  -- Submit and Reset Buttons.
--   l_cancel_url := RTRIM(l_server_url, '/') ||
--                   '/fnd_file_upload.cancelprocess';
  l_cancel_url := rtrim(fnd_web_config.plsql_agent, '/') ||
                  '/fnd_file_upload.cancelprocess';

  htp.br;
  htp.tableOpen(  cattributes => ' border=0 cellpadding=2 cellspacing=0' );
  htp.tableRowOpen( cvalign => 'TOP' );
  htp.tableData( '<INPUT TYPE="Submit" VALUE="' ||
		fnd_message.get_string('FND','OK')||
		'" SIZE="50">', calign => 'left');
  htp.tableData( '<INPUT TYPE="Button" NAME="cancel" VALUE="' ||
	       fnd_message.get_string('FND','FILE-UPLOAD CANCEL BUTTON TEXT')||
	       '"' || ' onClick="processclick('''||l_cancel_url||
	       ''') " SIZE="50">', calign => 'left');
  htp.tableRowClose;
  htp.tableClose;
  htp.formClose;

  htp.bodyClose;
  htp.htmlClose;
END IF;
END;

end FND_FILE_UPLOAD;

/
