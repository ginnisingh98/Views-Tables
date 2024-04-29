--------------------------------------------------------
--  DDL for Package Body FND_WEBATTCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WEBATTCH" as
/* $Header: AFATCHMB.pls 120.3.12010000.4 2012/08/01 22:41:47 ctilley ship $ */


-- Package Variables which stores the seed data for attachments.
g_function_name	varchar2(30) := null;
g_entity_name	varchar2(40) := null;
g_pk1_value	varchar2(100) := null;
g_pk2_value	varchar2(100) := null;
g_pk3_value	varchar2(100) := null;
g_pk4_value	varchar2(150) := null;
g_pk5_value	varchar2(150) := null;
g_chr_newline	varchar2(1) :='
'; -- NewLine Character


-- GetSummaryStatus
-- IN
--	function_name	--Function name of the form
--	entity_name	- Entity name for which attachment is made.
--	pk1_value	- First Primary Key value of the entity.
--	  to
--	pk5_value	- Fifth Primary key value of the entity.
-- OUT
-- 	attchmt_status	- Indicates Attachment Status -
--				 'EMPTY','FULL','DISABLED'.
--
procedure GetSummaryStatus (
	x_function_name		in varchar2,
	x_entity_name		in varchar2,
	x_pk1_value		in varchar2,
	x_pk2_value		in varchar2	default NULL,
	x_pk3_value		in varchar2	default NULL,
	x_pk4_value		in varchar2	default NULL,
	x_pk5_value		in varchar2	default NULL,
	attchmt_status		out NOCOPY varchar2
)
as
  attchmt_exists	varchar2(1);
  attachment_defined_flag	boolean;
  l_function_type 	varchar2(1) := 'F';
begin


  -- Validate the session
  /*if NOT (icx_sec.ValidateSession(null)) then
     return;
  end if; */

  -- Set the parameters to package global
  g_function_name := x_function_name;
  g_entity_name	:= x_entity_name;
  g_pk1_value	:= x_pk1_value;
  g_pk2_value	:= x_pk2_value;
  g_pk3_value	:= x_pk3_value;
  g_pk4_value	:= x_pk4_value;
  g_pk5_value	:= x_pk5_value;

  -- Find out if attachment is enabled in this function.
  fnd_attachment_util_pkg.init_atchmt (
			g_function_name,
			attachment_defined_flag,
			l_function_type);

  -- If the attachment is enabled then enable the link.
  if ( attachment_defined_flag = TRUE ) then

      -- Set the link to 'FULL' or 'EMPTY'.
      attchmt_exists:=fnd_attachment_util_pkg.get_atchmt_exists (
			g_entity_name,
			g_pk1_value,
			g_pk2_value,
			g_pk3_value,
			g_pk4_value,
			g_pk5_value,
			g_function_name,
			l_function_type);
     if (attchmt_exists = 'Y') then
	attchmt_status := 'FULL';
     elsif (attchmt_exists = 'N') then
        attchmt_status := 'EMPTY';
     end if;
  else
	attchmt_status := 'DISABLED';
  end if;
exception
  when others then
    attchmt_status := 'DISABLED';
end GetSummaryStatus;

-- GetSummaryList
--  IN
-- 	attchmt_status	- Indicates Attachment Status -
--				 EMPTY, FULL, DISABLED.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
-- OUT
--	URL		- URL string to linked to the attachment button.
--

procedure GetSummaryList (
	attchmt_status	in varchar2	default 'DISABLED',
	from_url	in varchar2,
	query_only	in varchar2	default 'N',
	package_name	in varchar2	default 'FND_WEBATTCH',
	URL		out NOCOPY varchar2
)
as
begin

  -- Check if the attachment status.
  if    (attchmt_status <>  'DISABLED') then
     URL := fnd_web_config.plsql_agent || package_name
	||'.Summary?function_name=' || icx_call.encrypt2(g_function_name)
	||'&'||'entity_name='|| icx_call.encrypt2(g_entity_name)
	||'&'||'pk1_value='|| icx_call.encrypt2(g_pk1_value)
	||'&'||'pk2_value='|| icx_call.encrypt2(g_pk2_value)
	||'&'||'pk3_value='|| icx_call.encrypt2(g_pk3_value)
	||'&'||'pk4_value='|| icx_call.encrypt2(g_pk4_value)
	||'&'||'pk5_value='|| icx_call.encrypt2(g_pk5_value)
	||'&'||'from_url=' || icx_call.encrypt2(from_url)
	||'&'||'query_only='|| icx_call.encrypt2(query_only);
  end if;

end GetSummaryList;

--
-- Summary
--	Construct the list of attachments for an entity.
--
procedure Summary (
	function_name		in varchar2,
	entity_name		in varchar2,
	pk1_value		in varchar2,
	pk2_value		in varchar2	default NULL,
	pk3_value		in varchar2	default NULL,
	pk4_value		in varchar2	default NULL,
	pk5_value		in varchar2	default NULL,
	from_url		in varchar2,
	query_only		in varchar2	default 'N'
) as

  l_function_name     varchar2(30) := icx_call.decrypt2(summary.function_name);
  l_entity_name	varchar2(40)  := icx_call.decrypt2(summary.entity_name);
  l_pk1_value	varchar2(100) := icx_call.decrypt2(summary.pk1_value);
  l_pk2_value	varchar2(100) := icx_call.decrypt2(summary.pk2_value);
  l_pk3_value	varchar2(100) := icx_call.decrypt2(summary.pk3_value);
  l_pk4_value	varchar2(150) := icx_call.decrypt2(summary.pk4_value);
  l_pk5_value	varchar2(150) := icx_call.decrypt2(summary.pk5_value);
  l_from_url	varchar2(2000) := icx_call.decrypt2(summary.from_url);
  l_query_only	varchar2(100) := icx_call.decrypt2(summary.query_only);
  l_lang	varchar2(24);
  l_dcdname	varchar2(80):= owa_util.get_cgi_env('SCRIPT_NAME');
  l_packagename	varchar2(80) := 'FND_WEBATTCH';
begin

  -- Validate the session
  if NOT (icx_sec.ValidateSession(null)) then
     return;
  end if;

  -- Set the language
  l_lang :=  icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);


  -- Show attachment summary and document info in frames.
  htp.htmlOpen;
  htp.headOpen;

  htp.framesetopen(crows=>'60, *, *', cattributes =>'frameborder=no border=0');

  -- Call the procedure that prints header
  htp.frame (csrc => l_dcdname || '/fnd_webattch.Header?Lang='||l_lang,
		cname => 'header_frame', cmarginheight=>'0',
		cmarginwidth=> '0', cscrolling => 'NO',
		cnoresize => 'NORESIZE', cattributes => 'FRAMEBORDER=NO');

  -- Print The Body of the Summary page.
  htp.frame (csrc => l_dcdname ||'/'||
		'fnd_webattch.PrintSummary?package_name='|| l_packagename ||
		'&'||'function_name='||l_function_name ||
		'&'||'entity_name='||l_entity_name ||
		'&'||'pk1_value='||l_pk1_value ||
		'&'||'pk2_value='||l_pk2_value ||
		'&'||'pk3_value='||l_pk3_value ||
		'&'||'pk4_value='||l_pk4_value ||
		'&'||'pk5_value='||l_pk5_value||
		'&'||'from_url='||l_from_url ||
		'&'||'query_only='||l_query_only,
		cname => 'list_frame',
	     cmarginheight=>'0', cmarginwidth=> '10', cscrolling => 'AUTO',
	     cnoresize => 'NORESIZE', cattributes => 'FRAMEBORDER=NO');

  -- Make an empty frame for document data.
  htp.frame (csrc => l_dcdname || '/'||'fnd_webattch.PrintBlankPage',
		cname => 'document_frame', cmarginheight=>'0',
		cmarginwidth=> '10', cscrolling => 'AUTO',
		cnoresize => 'NORESIZE', cattributes => 'FRAMEBORDER=NO');

  -- Close the frameset.
  htp.framesetclose;

end Summary;

-- procedure DocumentInformation (Private Procedure)
-- IN
--	x_datatype_id	- 0 if all the document info.type are blank.
--	x_short_text	- Short text document Info.
--	x_long_text	- Long text document Info.
--	x_file_name	- File / URL info. : File Name when datatype_id is 6
--					     URL when datatype_id is 5
--
procedure DocumentInformation (
	x_datatype_id	in number				,
	x_short_text	in varchar2		default NULL	,
	x_long_text	in long			default NULL	,
	x_file_name	in varchar2		default NULL
) as

   l_callback_url       varchar2(4000);
   l_search_document_url       varchar2(4000);
   l_username                  varchar2(80);

begin

  -- Construct the text document Information.
  if (x_datatype_id = 1 ) then

     --htp.tableOpen( cattributes => ' border=0 cellpadding=2 cellspacing=0');
     --htp.tableRowOpen( cvalign => 'TOP' );
     htp.tableRowOpen;
     htp.p('<TD align=right valign=top height=5 width=35%>');
     htp.p('</TD>');
     htp.p('<TD align=left>');
     htp.p('<FONT class=datablack><TEXTAREA NAME ="text"  ROWS=4 + COLS=38>'||
           x_short_text || '</TEXTAREA></FONT>');
     /*htp.tableData( htf.formTextareaOpen2( cname => 'text', nrows => '8',
                    ncolumns => '60', cwrap => 'virtual') ||
                    x_short_text ||
                    htf.formTextareaClose);*/
     htp.tableRowClose;
     htp.tableClose;
     htp.formHidden ( cname =>'file_name', cvalue=>'');
     htp.formHidden ( cname =>'url', cvalue=>'');
  elsif(x_datatype_id = 2) then

     --htp.tableOpen( cattributes => ' border=0 cellpadding=2 cellspacing=0');
     --htp.tableRowOpen( cvalign => 'TOP' );
     htp.tableRowOpen;
     htp.p('<TD align=right valign=top height=5 width=35%>');
     htp.p('</TD>');
     htp.p('<TD align=left>');
     htp.p('<FONT class=datablack><TEXTAREA NAME ="text"  ROWS=4 + COLS=38>'||
	   x_long_text || '</TEXTAREA></FONT>');
     /*htp.tableData( htf.formTextareaOpen2( cname => 'text', nrows => '8',
                    ncolumns => '60', cwrap => 'virtual') ||
                    x_long_text ||
                    htf.formTextareaClose);*/
     htp.tableRowClose;
     htp.tableClose;
     htp.formHidden ( cname =>'file_name', cvalue=>'');
     htp.formHidden ( cname =>'url', cvalue=>'');

  -- Construct file type document information
  elsif (x_datatype_id = 6 ) then

     htp.formHidden ( cname =>'text', cvalue=>'');
     --htp.tableOpen(  cattributes => ' border=0 cellpadding=2 cellspacing=0' );
     --htp.tableRowOpen( cvalign => 'TOP' );
     htp.tableRowOpen;
     htp.p('<TD align=right valign=top height=5 width=35%>');
     htp.p('</TD>');
     htp.p('<TD align=left>');
     htp.p('<FONT class=datablack><INPUT TYPE="File" NAME="file_name"'||
           'VALUE="'||x_file_name||'" SIZE="32"></FONT>');

     /*htp.tableData( '<INPUT TYPE="File" NAME="file_name" VALUE="Upload File" SIZE="60">', calign => 'left');*/
     htp.tableRowClose;
     htp.tableClose;
     htp.formHidden ( cname =>'url', cvalue=>'');

  -- Construct the URL document information
  elsif (x_datatype_id = 5 ) then
     htp.formHidden ( cname =>'text', cvalue=>'');
     htp.formHidden ( cname =>'file_name', cvalue=>'');

     --htp.tableOpen(  cattributes => ' border=0 cellpadding=2 cellspacing=0' );
     --htp.tableRowOpen( cvalign => 'TOP' );
     htp.tableRowOpen;
     htp.p('<TD align=right valign=top height=5 width=35%>');
     htp.p('</TD>');
     htp.p('<TD align=left>');
     htp.p('<FONT class=datablack><INPUT TYPE="Text" NAME="url" '||
	   'VALUE="'|| x_file_name ||'" SIZE="40"></FONT>');
     /*htp.tableData( htf.formText( cname => 'url', csize => '70',
                    cmaxlength => '100', cvalue =>x_file_name ),
         calign => 'left');*/
     htp.tableRowClose;
     htp.tableClose;
  elsif (x_datatype_id = 7 ) then
     /*
     ** Create the callback syntax to update the local fields
     */
     fnd_document_management.set_document_id_html (
        null,
        'FNDATTACH',
        'dmid',
        'dmname',
        l_callback_url);

     -- Get the url syntax for performing a search
     fnd_document_management.get_launch_attach_url (
        l_username,
        l_callback_url,
        TRUE,
        l_search_document_URL);

     -- DM Datatype
     --htp.tableOpen(  cattributes => ' border=0 cellpadding=2 cellspacing=0' );
     --htp.tableRowOpen( cvalign => 'TOP' );
     htp.tableRowOpen;
     htp.p('<TD align=right valign=top height=5 width=35%>');
     htp.p('</TD>');
     htp.p('<TD align=left>');
     htp.p('<FONT class=datablack><INPUT TYPE="Text" NAME="dmid" '||
	   'VALUE="'||x_file_name|| '" SIZE="40"></FONT>'||
	   l_search_document_URL);
     /*htp.tableData( htf.formText( cname => 'dmid', csize => '70',
		cvalue=>x_file_name)|| l_search_document_URL,
		calign => 'left');*/
     htp.tableRowClose;
     htp.tableClose;

     htp.formHidden ( cname =>'text', cvalue=>'');
     htp.formHidden ( cname =>'url', cvalue=>'');
  end if;

end DocumentInformation;

--
-- UpdateAttachment
--	Displays the attachment information for update.
-- IN
--	attached_document_id
--	function_name	--Function name of the form
--	entity_name	- Entity name for which attachment is made.
--	pk1_value	- First Primary Key value of the entity.
--	  to
--	pk5_value	- Fifth Primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--

procedure UpdateAttachment(
	attached_document_id		in varchar2,
	function_name			in varchar2,
	entity_name			in varchar2,
	pk1_value			in varchar2,
	pk2_value			in varchar2	default NULL,
	pk3_value			in varchar2	default NULL,
	pk4_value			in varchar2	default NULL,
	pk5_value			in varchar2	default NULL,
	from_url			in varchar2,
	query_only			in varchar2	default 'N'
)
as
l_attached_document_id	varchar2(16);
l_function_name	varchar2(30);
l_entity_name	varchar2(40);
l_pk1_value	varchar2(100);
l_pk2_value	varchar2(100);
l_pk3_value	varchar2(150);
l_pk4_value	varchar2(150);
l_pk5_value	varchar2(150);
l_from_url	varchar2(2000);
l_query_only	varchar2(1);
l_lang		varchar2(24);
l_dcdname	varchar2(80):= owa_util.get_cgi_env('SCRIPT_NAME');
l_packagename	varchar2(80) := 'FND_WEBATTCH';

begin

  -- Validate the session
  if NOT (icx_sec.ValidateSession(null)) then
     return;
  end if;

  -- Set the language
  l_lang :=  icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

  -- Decrypt all parameters.
  l_attached_document_id :=
		icx_call.decrypt2(UpdateAttachment.attached_document_id);
  l_function_name := icx_call.decrypt2(UpdateAttachment.function_name);
  l_entity_name	:= icx_call.decrypt2(UpdateAttachment.entity_name);
  l_pk1_value := icx_call.decrypt2(UpdateAttachment.pk1_value);
  l_pk2_value := icx_call.decrypt2(UpdateAttachment.pk2_value);
  l_pk3_value := icx_call.decrypt2(UpdateAttachment.pk3_value);
  l_pk4_value := icx_call.decrypt2(UpdateAttachment.pk4_value);
  l_pk5_value := icx_call.decrypt2(UpdateAttachment.pk5_value);
  l_from_url := icx_call.decrypt2(UpdateAttachment.from_url);
  l_query_only := icx_call.decrypt2(UpdateAttachment.query_only);

  -- Call the procedure that prints header
  htp.htmlOpen;
  htp.headOpen;

  htp.framesetopen(crows=>'60, *', cattributes =>'frameborder=no border=0');

  -- Call the procedure that prints header
  htp.frame (csrc => l_dcdname || '/fnd_webattch.Header?Lang='||l_lang,
		cname => 'top_frame', cmarginheight=>'0',
		cmarginwidth=> '0', cscrolling => 'NO',
		cnoresize => 'NORESIZE', cattributes => 'FRAMEBORDER=NO');

  -- Print The Body of the Add Attachment page.
  htp.frame (csrc => l_dcdname ||
		'/fnd_webattch.PrintUpdateAttachment?attached_document_id='||
						l_attached_document_id ||
		'&'||'package_name='|| l_packagename ||
		'&'||'function_name='||l_function_name ||
		'&'||'entity_name='||l_entity_name ||
		'&'||'pk1_value='||l_pk1_value ||
		'&'||'pk2_value='||l_pk2_value ||
		'&'||'pk3_value='||l_pk3_value ||
		'&'||'pk4_value='||l_pk4_value ||
		'&'||'pk5_value='||l_pk5_value||
		'&'||'from_url='||l_from_url ||
		'&'||'query_only='||l_query_only,
		cname => 'main_frame',
	     cmarginheight=>'0', cmarginwidth=> '10', cscrolling => 'AUTO',
	     cnoresize => 'NORESIZE', cattributes => 'FRAMEBORDER=NO');

  -- Close the frameset.
  htp.framesetclose;

end UpdateAttachment;


-- DeleteAttachment
--	Deletes the attachment and document.
-- IN
--	attached_document_id
--

procedure DeleteAttachment(
	attached_document_id	in varchar2,
	function_name		in varchar2,
	entity_name		in varchar2,
	pk1_value		in varchar2,
	pk2_value		in varchar2	default NULL,
	pk3_value		in varchar2	default NULL,
	pk4_value		in varchar2	default NULL,
	pk5_value		in varchar2	default NULL,
	from_url		in varchar2,
	query_only		in varchar2	default 'N'
)
as
   cursor delatt_cursor (x_attached_document_id varchar2) is
	select datatype_id,file_name,media_id
	  from fnd_attached_docs_form_vl
	 where attached_document_id =  to_number(x_attached_document_id);

 deldatarec	delatt_cursor%ROWTYPE;

 l_datatype_id 		number;
 l_media_id 		number;
 l_file_name 		varchar2(255);
 l_attached_document_id	varchar2(16) :=
		icx_call.decrypt2(deleteattachment.attached_document_id);
begin

  -- Validate the session
  if NOT (icx_sec.ValidateSession(null)) then
     return;
  end if;

  -- Get the datatype_id for the attachment.
  open delatt_cursor (l_attached_document_id);
  fetch delatt_cursor into deldatarec;
  if delatt_cursor%NOTFOUND then
     return;
  end if;

  l_datatype_id := deldatarec.datatype_id ;
  l_file_name := deldatarec.file_name;
  l_media_id := deldatarec.media_id;

  -- Call the procedure to delete the attachment and document.
  fnd_attached_documents3_pkg.delete_row ( l_attached_document_id,
					   l_datatype_id, 'Y' );

  -- Delete the file from fnd_lobs.
  if (l_datatype_id = 6 ) then
      DELETE FROM fnd_lobs WHERE file_id = l_media_id;
  end if;

  -- Redirect the URL to the file location
  owa_util.redirect_url (curl => owa_util.get_owa_service_path||
      'fnd_webattch.Summary?function_name=' || function_name
        ||'&'||'entity_name='||entity_name
        ||'&'||'pk1_value='||pk1_value
        ||'&'||'pk2_value='||pk2_value
        ||'&'||'pk3_value='||pk3_value
        ||'&'||'pk4_value='||pk4_value
        ||'&'||'pk5_value='||pk5_value
        ||'&'||'from_url='||from_url
        ||'&'||'query_only='||query_only);

end DeleteAttachment;

--
-- AddAttachment
--	Creates an attachment and document.
-- IN
--	function_name	- Function name of the web function
--	entity_name	- Entity name to which the attachment is made.
--	pk1_value	- First primary key of the entity.
--	 through
--	pk5_value	- Fifth primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--

procedure AddAttachment(
	function_name		in varchar2,
	entity_name		in varchar2,
	pk1_value		in varchar2,
	pk2_value		in varchar2	default NULL,
	pk3_value		in varchar2	default NULL,
	pk4_value		in varchar2	default NULL,
	pk5_value		in varchar2	default NULL,
	from_url		in varchar2,
	query_only		in varchar2	default 'N'
) as

  l_function_name varchar2(30);
  l_entity_name	varchar2(40) ;
  l_pk1_value	varchar2(100);
  l_pk2_value	varchar2(100);
  l_pk3_value	varchar2(150);
  l_pk4_value	varchar2(150);
  l_pk5_value	varchar2(150);
  l_from_url	varchar2(2000);
  l_query_only	varchar2(1);
  l_lang	varchar2(24);
  l_dcdname	varchar2(80):= owa_util.get_cgi_env('SCRIPT_NAME');
  l_packagename	varchar2(80) := 'FND_WEBATTCH';

  begin

  -- Validate the session
  if NOT (icx_sec.ValidateSession(null)) then
     return;
  end if;

  -- Set the language
  l_lang :=  icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

  -- Decrypt all the parameters.
  l_function_name :=icx_call.decrypt2(AddAttachment.function_name);
  l_entity_name	:= icx_call.decrypt2(AddAttachment.entity_name);
  l_pk1_value	:= icx_call.decrypt2(AddAttachment.pk1_value);
  l_pk2_value	:= icx_call.decrypt2(AddAttachment.pk2_value);
  l_pk3_value	:= icx_call.decrypt2(AddAttachment.pk3_value);
  l_pk4_value	:= icx_call.decrypt2(AddAttachment.pk4_value);
  l_pk5_value	:= icx_call.decrypt2(AddAttachment.pk5_value);
  l_from_url	:= icx_call.decrypt2(AddAttachment.from_url);
  l_query_only	:= icx_call.decrypt2(AddAttachment.query_only);

  -- Call the procedure that prints header
  htp.htmlOpen;
  htp.headOpen;

  htp.framesetopen(crows=>'60, *', cattributes =>'frameborder=no border=0');

  -- Call the procedure that prints header
  htp.frame (csrc => l_dcdname || '/fnd_webattch.Header?Lang='||l_lang,
		cname => 'tooolbar_frame', cmarginheight=>'0',
		cmarginwidth=> '0', cscrolling => 'NO',
		cnoresize => 'NORESIZE', cattributes => 'FRAMEBORDER=NO');

  -- Print The Body of the Add Attachment page.
  htp.frame (csrc => l_dcdname ||
		'/fnd_webattch.PrintAddAttachment?package_name='||
						l_packagename ||
		'&'||'function_name='||l_function_name ||
		'&'||'entity_name='||l_entity_name ||
		'&'||'pk1_value='||l_pk1_value ||
		'&'||'pk2_value='||l_pk2_value ||
		'&'||'pk3_value='||l_pk3_value ||
		'&'||'pk4_value='||l_pk4_value ||
		'&'||'pk5_value='||l_pk5_value||
		'&'||'from_url='||l_from_url ||
		'&'||'query_only='||l_query_only,
		cname => 'form_frame',
	     cmarginheight=>'0', cmarginwidth=> '10', cscrolling => 'AUTO',
	     cnoresize => 'NORESIZE', cattributes => 'FRAMEBORDER=NO');

  -- Close the frameset.
  htp.framesetclose;

end AddAttachment;

-- ViewTextDocument
-- IN
--	media_id	- Key to retrive the document info.
--	datatype_id	- 1 if it is 'Short Text'
--			  2 if it is 'Long Text'.
--	function_name	- Function name of the form
--	entity_name	- Entity name for which attachment is made.
--	pk1_value	- First Primary Key value of the entity.
--	  to
--	pk5_value	- Fifth Primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.

procedure ViewTextDocument (
	attached_document_id	in varchar2		,
	function_name		in varchar2		,
	entity_name		in varchar2		,
	pk1_value		in varchar2		,
	pk2_value		in varchar2		,
	pk3_value		in varchar2		,
	pk4_value		in varchar2		,
	pk5_value		in varchar2		,
	from_url		in varchar2		,
	query_only		in varchar2	default 'N'
)as

  l_lang		varchar2(24);

begin

  -- Validate the session
  if NOT (icx_sec.ValidateSession(null)) then
     return;
  end if;

  -- Set the language
  l_lang :=  icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);

  -- Call the procedure that prints header
  --Header(fnd_message.get_string('FND', 'FND-WEBATCH-VIEWTEXT-TITLE'),l_lang);

  -- Call PrintTextDocument with the packagename
  PrintTextDocument (
		package_name		=> 'FND_WEBATTCH'	,
		attached_document_id 	=> attached_document_id	,
		function_name		=> function_name	,
        	entity_name		=> entity_name	,
        	pk1_value		=> pk1_value		,
        	pk2_value		=> pk2_value		,
        	pk3_value		=> pk3_value		,
        	pk4_value		=> pk4_value		,
        	pk5_value		=> pk5_value		,
        	from_url		=> from_url		,
        	query_only		=> query_only	);

end ViewTextDocument;

-- ViewFileDocument
--	Displays the file document.
-- IN
--	attached_document_id - Unique id for an attachment.
--	function_name	- Function name of the form
--	entity_name	- Entity name for which attachment is made.
--	pk1_value	- First Primary Key value of the entity.
--	  to
--	pk5_value	- Fifth Primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--

procedure ViewFileDocument (
	attached_document_id	in varchar2
) as

   cursor filename_cursor (l_attached_document_id varchar2) is
     select dt.file_name, dt.media_id
     from fnd_attached_documents ad, fnd_documents_tl dt
     where  ad.document_id = dt.document_id
     and  ad.attached_document_id = to_number(l_attached_document_id);

 l_url			varchar2(255);
 l_file_name		varchar2(255);
 l_attached_document_id	varchar2(16) := icx_call.decrypt2
				(viewfiledocument.attached_document_id);
 gfm_agent      varchar2(255);
 l_script_name          varchar2(255);
 l_media_id             number;

begin

  -- Validate the session
  if NOT (icx_sec.ValidateSession(null)) then
     return;
  end if;

  -- Get the file_name which also has the file_content_type.
  open filename_cursor (l_attached_document_id);
  fetch filename_cursor into l_file_name, l_media_id;
  if filename_cursor%NOTFOUND then
	owa_util.status_line(404, 'File Not Found', TRUE);
	RETURN;
  end if;

  l_script_name := owa_util.get_cgi_env('SCRIPT_NAME');
  /*web_plsql_agent := SUBSTR(l_script_name, 2,
			 INSTR(l_script_name, '/', 2) - 1);
  web_server_prefix := 'http://' || owa_util.get_cgi_env('SERVER_NAME') ||
        ':' || owa_util.get_cgi_env('SERVER_PORT'); */
  gfm_agent := fnd_web_config.gfm_agent;

  l_url := fnd_gfm.construct_download_URL( gfm_agent, l_media_id, FALSE);

  -- Redirect the URL to display the file
  owa_util.redirect_url( l_url );

end ViewFileDocument;

PROCEDURE add_attachment_gfm_wrapper(
	access_id NUMBER,
        seq_num VARCHAR2 ,
        category_id VARCHAR2,
        document_description VARCHAR2,
        datatype_id VARCHAR2,
        text VARCHAR2 DEFAULT NULL,
        file_name VARCHAR2 DEFAULT NULL,
        url VARCHAR2 DEFAULT NULL,
        function_name VARCHAR2 DEFAULT NULL,
        entity_name VARCHAR2 DEFAULT NULL,
        pk1_value VARCHAR2 DEFAULT NULL,
        pk2_value VARCHAR2 DEFAULT NULL,
        pk3_value VARCHAR2 DEFAULT NULL,
        pk4_value VARCHAR2 DEFAULT NULL,
        pk5_value VARCHAR2 DEFAULT NULL,
        from_url VARCHAR2 DEFAULT NULL,
        query_only VARCHAR2 DEFAULT NULL,
        user_id    VARCHAR2 DEFAULT NULL,
        dmid       VARCHAR2 DEFAULT NULL,
        dmname     VARCHAR2 DEFAULT NULL,
        package_name VARCHAR2,
        dm_node                 in number   DEFAULT NULL,
        dm_folder_path          in varchar2 DEFAULT NULL,
        dm_type                 in varchar2 DEFAULT NULL,
        dm_document_id          in number   DEFAULT NULL,
        dm_version_number       in varchar2 DEFAULT NULL,
        title                   in varchar2 DEFAULT NULL
  ) AS
  l_media_id NUMBER;
  l_file_name VARCHAR2(255);
BEGIN

  IF TO_NUMBER(datatype_id) = 6  THEN
    l_media_id := fnd_gfm.confirm_upload(access_id    => access_id,
                                      	file_name    => file_name,
                                      	program_name => 'ADD_ATTACHMENT');
    l_file_name := 'INTERNAL';
  ELSIF TO_NUMBER(datatype_id) = 7 THEN
    l_file_name := dmid;
  END IF;

  Add_Attachment(seq_num => seq_num,
                 category_id => category_id,
                 document_description => document_description,
                 datatype_id => datatype_id,
                 text => text,
                 file_name => l_file_name,
                 url => url,
                 function_name => function_name,
                 entity_name => entity_name,
                 pk1_value => pk1_value,
                 pk2_value => pk2_value,
                 pk3_value => pk3_value,
                 pk4_value => pk4_value,
                 pk5_value => pk5_value,
                 media_id => l_media_id,
                 user_id => user_id,
                 title => title,
                 dm_node => dm_node,
                 dm_folder_path => dm_folder_path,
                 dm_type => dm_type,
                 dm_document_id => dm_document_id,
                 dm_version_number => dm_version_number);

  -- This htp call is required for webDB implementation.
  htp.p('');

END;

-- Add_Attachment
-- IN
--	seq_num		- Attachment Seq Number.
--	category_description
--	document_description
--	datatype_name	- Datatype identifier
--	document_text	- Document Text Input.
--	file_name	- File name
--	URL		- URL
--	function_name	- Function name of the form
--	entity_name	- Entity name for which attachment is made.
--	pk1_value	- First Primary Key value of the entity.
--	  to
--	pk5_value	- Fifth Primary key value of the entity.
--	from_url	- URL from which the attachments is invoked from.
--			  This is required to set the back link.
--	query_only	- Query flag is set 'Y' when called in query only
--			  mode.
--	media_id	- Document Content reference.
--	user_id		- Login id of the user
--      usage_type      - one-time or standard or template.
--

procedure Add_Attachment (
	seq_num			in varchar2			,
	category_id		in varchar2			,
	document_description	in varchar2			,
	datatype_id		in varchar2			,
	text			in long				,
	file_name		in varchar2			,
	url			in varchar2			,
	function_name		in varchar2			,
	entity_name		in varchar2			,
	pk1_value		in varchar2			,
	pk2_value		in varchar2			,
	pk3_value		in varchar2			,
	pk4_value		in varchar2			,
	pk5_value		in varchar2			,
	media_id		in number			,
	user_id			in varchar2			,
        usage_type              in varchar2 DEFAULT 'O'		,
	title			in varchar2 DEFAULT NULL        ,
        dm_node                 in number   DEFAULT NULL        ,
        dm_folder_path          in varchar2 DEFAULT NULL        ,
        dm_type                 in varchar2 DEFAULT NULL        ,
        dm_document_id          in number   DEFAULT NULL        ,
        dm_version_number       in varchar2 DEFAULT NULL
) as

 l_rowid 		varchar2(30);
 l_attached_document_id	number;
 l_media_id		number:= add_attachment.media_id;
 l_document_id		number;

 l_file_name		varchar2(255);
 l_creation_date	date := SYSDATE;
 l_created_by		number;
 l_last_update_date	date := SYSDATE;
 l_last_updated_by	number;
 l_lang			varchar2(40);

begin

  -- Set file name
  -- Bug 14332737: Restore setting file_name for url to
  -- resolve a regression in product team code.
  -- This should not adversely affect attachment functionality
  if (to_number(datatype_id) = 5) then
     l_file_name := url;
  elsif (to_number(datatype_id) in (6,7) ) then
	l_file_name := add_attachment.file_name;
  end if;

  -- Set the WHO Columns.
  l_created_by := to_number(user_id);
  l_last_updated_by := l_created_by;

  -- Attached Document Id has to be populated from the sequence.
  select fnd_attached_documents_s.nextval
  into l_attached_document_id
  from sys.dual;

  -- Set the language parameter
  select userenv ('LANG')
  into l_lang
  from dual;

  -- Call the server side package for adding the attachment and documents.
  fnd_attached_documents_pkg.insert_row (
	x_rowid			=> l_rowid			,
	x_attached_document_id	=> l_attached_document_id	,
	x_document_id		=> l_document_id		,
	x_creation_date		=> l_creation_date		,
	x_created_by		=> l_created_by			,
	x_last_update_date	=> l_last_update_date		,
	x_last_updated_by	=> l_last_updated_by		,
	x_last_update_login	=> NULL				,
	x_seq_num		=> to_number(seq_num)		,
	x_entity_name		=> entity_name			,
	x_column1		=> NULL				,
	x_pk1_value		=> pk1_value			,
	x_pk2_value		=> pk2_value			,
	x_pk3_value		=> pk3_value			,
	x_pk4_value		=> pk4_value			,
	x_pk5_value		=> pk5_value			,
	x_automatically_added_flag	=> 'N'			,
	x_request_id		=> NULL				,
	x_program_application_id	=>NULL			,
	x_program_id		=> NULL				,
	x_program_update_date	=> NULL				,
	x_attribute_category	=> NULL				,
	x_attribute1		=> NULL				,
	x_attribute2		=> NULL				,
	x_attribute3		=> NULL				,
	x_attribute4		=> NULL				,
	x_attribute5		=> NULL				,
	x_attribute6		=> NULL				,
	x_attribute7		=> NULL				,
	x_attribute8		=> NULL				,
	x_attribute9		=> NULL				,
	x_attribute10		=> NULL				,
	x_attribute11		=> NULL				,
	x_attribute12		=> NULL				,
	x_attribute13		=> NULL				,
	x_attribute14		=> NULL				,
	x_attribute15		=> NULL				,
	x_datatype_id		=> to_number(datatype_id)	,
	x_category_id		=> to_number(category_id)	,
	x_security_type		=> 4				,
	x_security_id		=> NULL				,
	x_publish_flag		=> 'Y'				,
	x_image_type		=> NULL				,
	x_storage_type		=> NULL				,
	x_usage_type		=> usage_type			,
	x_language		=> l_lang			,
	x_description		=> document_description		,
	x_file_name		=> l_file_name			,
	x_media_id		=> l_media_id			,
	x_doc_attribute_category	=> NULL			,
	x_doc_attribute1	=> NULL				,
	x_doc_attribute2	=> NULL				,
	x_doc_attribute3	=> NULL				,
	x_doc_attribute4	=> NULL				,
	x_doc_attribute5	=> NULL				,
	x_doc_attribute6	=> NULL				,
	x_doc_attribute7	=> NULL				,
	x_doc_attribute8	=> NULL				,
	x_doc_attribute9	=> NULL				,
	x_doc_attribute10	=> NULL				,
	x_doc_attribute11	=> NULL				,
	x_doc_attribute12	=> NULL				,
	x_doc_attribute13	=> NULL				,
	x_doc_attribute14	=> NULL				,
	x_doc_attribute15	=> NULL				,
	x_create_doc		=> 'N'				,
	x_url			=> url				,
	x_title			=> title                        ,
        x_dm_node               => dm_node                      ,
        x_dm_folder_path        => dm_folder_path               ,
        x_dm_type               => dm_type                      ,
        x_dm_document_id        => dm_document_id               ,
        x_dm_version_number     => dm_version_number
  );

  -- Commit the transaction
  commit;

  -- After the data is inserted into fnd_attached_documents, fnd_documents and
  -- fnd_documents_tl table using the above procedure we get the media_id
  -- which will be used to insert the text into fnd_document_short_text table.
  if (to_number(datatype_id) = 2 ) then -- Text Datatype
  	INSERT INTO fnd_documents_long_text(
       		media_id,
       		long_text) VALUES (
       		l_media_id,
       		text);

        -- Commit the transaction
        commit;
  elsif (to_number(datatype_id) = 1 ) then -- Short text Type Documents.
  	INSERT INTO fnd_documents_short_text(
       		media_id,
       		short_text) VALUES (
       		l_media_id,
       		text);

        -- Commit the transaction
        commit;
  end if;

exception
  when others then
  rollback;

end Add_Attachment;

PROCEDURE update_attachment_gfm_wrapper(
        seq_num varchar2,
        category_id varchar2,
        document_description varchar2 DEFAULT NULL,
        text varchar2 DEFAULT NULL,
        file_name varchar2 DEFAULT NULL,
        url varchar2 DEFAULT NULL,
        attached_document_id varchar2 DEFAULT NULL,
        datatype_id varchar2,
        function_name varchar2 DEFAULT NULL,
        entity_name varchar2 DEFAULT NULL,
        pk1_value varchar2 DEFAULT NULL,
        pk2_value varchar2 DEFAULT NULL,
        pk3_value varchar2 DEFAULT NULL,
        pk4_value varchar2 DEFAULT NULL,
        pk5_value varchar2 DEFAULT NULL,
        from_url varchar2 DEFAULT NULL,
        query_only varchar2 DEFAULT NULL,
        dmid       VARCHAR2 DEFAULT NULL,
        dmname     VARCHAR2 DEFAULT NULL,
        package_name varchar2,
        dm_node    NUMBER DEFAULT NULL,
        dm_folder_path VARCHAR2 DEFAULT NULL,
        dm_type        VARCHAR2 DEFAULT NULL,
        dm_document_id NUMBER DEFAULT NULL,
        dm_version_number VARCHAR2 DEFAULT NULL,
        title             VARCHAR2 DEFAULT NULL
  ) AS
  l_media_id NUMBER;
  l_file_name VARCHAR2(255);
  l_user_id	VARCHAR2(24);
  l_package_name	VARCHAR2(64);
  l_access_id NUMBER;
  l_start_pos NUMBER :=1;
  l_length NUMBER := 0 ;
BEGIN

  -- Parse the packagename into package name, access_id and user_id.
  l_length := instr(package_name,';',l_start_pos) - l_start_pos;
  l_user_id := substr(package_name,l_start_pos,l_length);

  l_start_pos := l_start_pos + l_length + 1 ;
  l_length := instr(package_name,';',l_start_pos) - l_start_pos;
  l_package_name := substr(package_name,l_start_pos,l_length);


  l_start_pos := l_start_pos + l_length + 1 ;
  l_length := instr(package_name,';',l_start_pos) - l_start_pos;
  l_access_id := to_number(substr(package_name,l_start_pos,l_length));

  IF TO_NUMBER(datatype_id) = 6 THEN
    l_media_id := fnd_gfm.confirm_upload(access_id    => l_access_id,
                                        file_name    => file_name,
                                        program_name => 'UPDATE_ATTACHMENT');
    l_file_name := 'INTERNAL';
  ELSIF TO_NUMBER(datatype_id) = 7 THEN
    l_file_name := dmid;
  END IF;

  Update_Attachment(seq_num => seq_num,
                    category_id => category_id,
                    document_description => document_description,
                    text => text,
                    file_name => l_file_name,
                    url => url,
                    attached_document_id => attached_document_id,
                    datatype_id => datatype_id,
                    function_name => function_name,
                    entity_name => entity_name,
                    pk1_value => pk1_value,
                    pk2_value => pk2_value,
                    pk3_value => pk3_value,
                    pk4_value => pk4_value,
                    pk5_value => pk5_value,
                    media_id => l_media_id,
                    user_id => l_user_id,
                    dm_node => dm_node,
                    dm_folder_path => dm_folder_path,
                    dm_type => dm_type,
                    dm_document_id => dm_document_id,
                    dm_version_number => dm_version_number,
                    title => title);

  -- This htp call is required for webDB implementation.
  htp.p('');

END;

-- Update_Attachment
-- IN
--	seq_num		- Attachment Seq Number.
--	category_description
--	document_description
--	datatype_name	- Datatype identifier
--	document_text	- Document Text Input.
--	file_name	- File name
--	URL		- URL
--	function_name	--Function name of the form
--	entity_name	- Entity name for which attachment is made.
--	pk1_value	- First Primary Key value of the entity.
--	  to
--	pk5_value	- Fifth Primary key value of the entity.
--      user_id         - Login id of the user
--	media_id	- Document Content reference.
--

procedure Update_Attachment (
	seq_num			in varchar2			,
	category_id		in varchar2			,
	document_description	in varchar2			,
	text			in long				,
	file_name		in varchar2			,
	url			in varchar2			,
	attached_document_id	in varchar2			,
	datatype_id		in varchar2			,
	function_name		in varchar2			,
	entity_name		in varchar2			,
	pk1_value		in varchar2			,
	pk2_value		in varchar2			,
	pk3_value		in varchar2			,
	pk4_value		in varchar2			,
	pk5_value		in varchar2			,
	media_id		in number			,
        user_id                 in varchar2                     ,
        dm_node                 in NUMBER DEFAULT NULL          ,
        dm_folder_path          in VARCHAR2 DEFAULT NULL        ,
        dm_type                 in VARCHAR2 DEFAULT NULL        ,
        dm_document_id          in NUMBER DEFAULT NULL          ,
        dm_version_number       in VARCHAR2 DEFAULT NULL        ,
        title                   in VARCHAR2 DEFAULT NULL
) as
   cursor update_att_cursor (x_attached_document_id varchar2,
			     x_function_name varchar2) is
	select	row_id, document_id, media_id, start_date_active,
		end_date_active, datatype_id
	from 	fnd_attached_docs_form_vl
	where attached_document_id = to_number(x_attached_document_id)
	and   function_name= x_function_name
	and   function_type = 'F';

  upddatarec	update_att_cursor%ROWTYPE;

 l_datatype_id	number;
 l_file_name	varchar2(255);
 l_last_update_date	date := SYSDATE;
 l_last_updated_by	number;

 l_document_id	number;
 l_media_id	number;
 l_attached_document_id	varchar2(16):= update_attachment.attached_document_id;
 l_function_name	varchar2(32):= update_attachment.function_name;
 l_lang		varchar2(40);

begin

  -- Reterive the data for the attachment.
  open update_att_cursor (l_attached_document_id,l_function_name);
  fetch update_att_cursor into upddatarec;
  if update_att_cursor%NOTFOUND then
     close update_att_cursor;
     return;
  end if;

  -- Set file name and media id depending on datatype id.
  if (to_number(datatype_id) = 5 ) then
        -- Bug 14332737: Restore setting file_name to resolve
        -- a regression in product team code
        l_file_name := url;
	l_media_id  := null;
  elsif (to_number(datatype_id) = 6) then
	l_media_id := update_attachment.media_id;
	l_file_name := update_attachment.file_name;
  elsif (to_number(datatype_id) = 7 ) then
	l_file_name := update_attachment.file_name;
	l_media_id  := null;
  else
	l_file_name := update_attachment.file_name;
  	l_media_id := upddatarec.media_id;
  end if;

  -- Set the WHO Columns.
  l_last_updated_by := to_number(Update_Attachment.user_id);

  -- Set the language
  select USERENV('LANG')
  into l_lang
  from dual;

  -- Call the server side package for adding the attachment and documents.
  fnd_attached_documents_pkg.update_row (
	x_rowid	=> upddatarec.row_id				,
	x_attached_document_id	=> attached_document_id	,
	x_document_id	=> upddatarec.document_id		,
	x_last_update_date	=> l_last_update_date	,
	x_last_updated_by	=> l_last_updated_by	,
	x_last_update_login	=> NULL			,
	x_seq_num	=> to_number(seq_num)		,
	x_entity_name	=> entity_name			,
	x_column1	=> NULL				,
	x_pk1_value	=> pk1_value			,
	x_pk2_value	=> pk2_value			,
	x_pk3_value	=> pk3_value			,
	x_pk4_value	=> pk4_value			,
	x_pk5_value	=> pk5_value			,
	x_automatically_added_flag	=> 'N'		,
	x_request_id	=> NULL				,
	x_program_application_id	=>NULL		,
	x_program_id	=> NULL				,
	x_program_update_date	=> NULL			,
	x_attribute_category	=> NULL			,
	x_attribute1	=> NULL				,
	x_attribute2	=> NULL				,
	x_attribute3	=> NULL				,
	x_attribute4	=> NULL				,
	x_attribute5	=> NULL				,
	x_attribute6	=> NULL				,
	x_attribute7	=> NULL				,
	x_attribute8	=> NULL				,
	x_attribute9	=> NULL				,
	x_attribute10	=> NULL				,
	x_attribute11	=> NULL				,
	x_attribute12	=> NULL				,
	x_attribute13	=> NULL				,
	x_attribute14	=> NULL				,
	x_attribute15	=> NULL				,
	x_datatype_id	=> datatype_id			,
	x_category_id	=> to_number(category_id)	,
	x_security_type	=> 4				,
	x_security_id	=> NULL				,
	x_publish_flag	=> 'Y'				,
	x_image_type	=> NULL				,
	x_storage_type	=> NULL				,
	x_usage_type	=> 'O'				,
	x_start_date_active => upddatarec.start_date_active	,
	x_end_date_active => upddatarec.end_date_active	,
	x_language	=> l_lang		,
	x_description	=> document_description		,
	x_file_name	=> l_file_name			,
	x_media_id	=> l_media_id			,
	x_doc_attribute_category	=> NULL		,
	x_doc_attribute1	=> NULL			,
	x_doc_attribute2	=> NULL			,
	x_doc_attribute3	=> NULL			,
	x_doc_attribute4	=> NULL			,
	x_doc_attribute5	=> NULL			,
	x_doc_attribute6	=> NULL			,
	x_doc_attribute7	=> NULL			,
	x_doc_attribute8	=> NULL			,
	x_doc_attribute9	=> NULL			,
	x_doc_attribute10	=> NULL			,
	x_doc_attribute11	=> NULL			,
	x_doc_attribute12	=> NULL			,
	x_doc_attribute13	=> NULL			,
	x_doc_attribute14	=> NULL			,
	x_doc_attribute15	=> NULL	                ,
        x_url                   => url                  ,
        x_title                 => title                ,
        x_dm_node               => dm_node              ,
        x_dm_folder_path        => dm_folder_path       ,
        x_dm_type               => dm_type              ,
        x_dm_document_id        => dm_document_id       ,
        x_dm_version_number     => dm_version_number
  );

  -- Commit the transaction.
  commit;

  -- When the text is altered the the fnd_documents_short_text
  -- needs to be updated.  When the file type is altered we have to
  -- upload the file.
  if (datatype_id = 1 )  then -- Short Text Datatype
     UPDATE fnd_documents_short_text
     set short_text = text
     where media_id = l_media_id;

     -- Commit the transaction.
     commit;

  elsif (datatype_id = 2 ) then -- Long Text Document
     UPDATE fnd_documents_long_text
     set long_text = text
     where media_id = l_media_id;

     -- Commit the transaction.
     commit;
  end if;

exception
  when others then
    rollback;
    if (update_att_cursor%ISOPEN) then
	close update_att_cursor;
    end if;
end Update_Attachment;

-- ReloadSummary
-- IN
--      package_name    - Calling package name.
--      function_name   - Function name of the form
--      entity_name     - Entity name for which attachment is made.
--      pk1_value       - First Primary Key value of the entity.
--        to
--      pk5_value       - Fifth Primary key value of the entity.
--      from_url        - URL from which the attachments is invoked from.
--                        This is required to set the back link.
--      query_only      - Query flag is set 'Y' when called in query only
--                        mode.
--

procedure ReloadSummary(
        package_name            in varchar2     default 'FND_WEBATTCH',
        function_name           in varchar2,
        entity_name             in varchar2,
        pk1_value               in varchar2,
        pk2_value               in varchar2     default NULL,
        pk3_value               in varchar2     default NULL,
        pk4_value               in varchar2     default NULL,
        pk5_value               in varchar2     default NULL,
        from_url                in varchar2                 ,
        query_only              in varchar2     default 'N'
) as

begin

  -- Redirect the URL to the file location
  owa_util.redirect_url (curl => owa_util.get_owa_service_path|| package_name||
      '.Summary?function_name='|| icx_call.encrypt2(function_name)
        ||'&'||'entity_name='||icx_call.encrypt2(entity_name)
        ||'&'||'pk1_value='||icx_call.encrypt2(pk1_value)
        ||'&'||'pk2_value='||icx_call.encrypt2(pk2_value)
        ||'&'||'pk3_value='||icx_call.encrypt2(pk3_value)
        ||'&'||'pk4_value='||icx_call.encrypt2(pk4_value)
        ||'&'||'pk5_value='||icx_call.encrypt2(pk5_value)
        ||'&'||'from_url=' ||icx_call.encrypt2(from_url)
        ||'&'||'query_only='||icx_call.encrypt2(query_only));

end ReloadSummary;

-- Header
--      Creates Header for Attachment pages.
-- IN
--      Title   - Title of the page.
--	Lang	- Language of the Title.
--
procedure Header( Lang	in varchar2
) as
begin

  -- Validate the session
  if NOT (icx_sec.ValidateSession(null)) then
	return;
  end if;

  htp.htmlOpen;
  htp.bodyOpen;
  -- Body background color.
  htp.p('<BODY bgcolor="#cccccc">');

  icx_admin_sig.toolbar(language_code => Header.Lang);

  -- Style sheet declaration.
  htp.p('<LINK REL=STYLESHEET HREF="/OA_HTML/US/osswa.css" TYPE="text/css">');

  htp.bodyClose;
  htp.htmlClose;

end Header;

-- PrintSummary
--      Prints the attachment summary page body (No Titles and Links).
-- IN
--	package_name	- Calling package name.
--      function_name   - Function name of the web function
--      entity_name     - Entity name to which the attachment is made.
--      pk1_value       - First primary key of the entity.
--       through
--      pk5_value       - Fifth primary key value of the entity.
--      from_url        - URL from which the attachments is invoked from.
--                        This is required to set the back link.
--      query_only      - Query flag is set 'Y' when called in query only
--                        mode.
--

procedure PrintSummary(
	package_name            in varchar2     default 'FND_WEBATTCH',
        function_name           in varchar2,
        entity_name             in varchar2,
        pk1_value               in varchar2,
        pk2_value               in varchar2     default NULL,
        pk3_value               in varchar2     default NULL,
        pk4_value               in varchar2     default NULL,
        pk5_value               in varchar2     default NULL,
        from_url                in varchar2,
        query_only              in varchar2     default 'N'
) as
  cursor al_cursor is
    select SEQ_NUM ,
           CATEGORY_DESCRIPTION,
           DOCUMENT_DESCRIPTION,
           DATATYPE_NAME,
           DATATYPE_ID,
           FILE_NAME,
           USAGE_TYPE,
           USER_ENTITY_NAME,
           MEDIA_ID,
           ATTACHED_DOCUMENT_ID
    from   FND_ATTACHED_DOCS_FORM_VL
    where  FUNCTION_NAME =printsummary.function_name
    and    FUNCTION_TYPE ='F'
    and   (SECURITY_TYPE = 4 OR PUBLISH_FLAG = 'Y')
    and   (ENTITY_NAME= printsummary.entity_name and
	  	PK1_VALUE=printsummary.pk1_value and
            decode(printsummary.pk2_value,null,'*',PK2_VALUE)=
  	    decode(printsummary.pk2_value,null,'*',printsummary.pk2_value) and
            decode(printsummary.pk3_value,null,'*',PK3_VALUE)=
	    decode(printsummary.pk3_value,null,'*',printsummary.pk3_value) and
            decode(printsummary.pk4_value,null,'*',PK4_VALUE)=
	    decode(printsummary.pk4_value,null,'*',printsummary.pk4_value) and
            decode(printsummary.pk5_value,null,'*',PK5_VALUE)=
	    decode(printsummary.pk5_value,null,'*',printsummary.pk5_value))
    order by USER_ENTITY_NAME,SEQ_NUM;

  atlstrec 		al_cursor%ROWTYPE;
  link_string		varchar2(2000);
  l_del_msg	varchar2(255);
  l_title	varchar2(164);
  l_lang	varchar2(24);
  l_username	varchar2(80);
  j		number := 1.0;

begin

  -- Validate the session
  if NOT (icx_sec.ValidateSession(null)) then
	return;
  end if;

  -- Set the language
  l_lang :=  icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
  l_username := UPPER(ICX_SEC.GetID(99));

  -- Retrive the delete message from the message dictionary
  l_del_msg := fnd_message.get_string('FND','ATCHMT-DELETE-ATCHMT');

  -- Set the title
  l_title := fnd_message.get_string('FND','FND-WEBATCH-SUMMARY-TITLE');

  htp.htmlOpen;
  htp.headOpen;
  htp.p( '<SCRIPT LANGUAGE="JavaScript">');
  htp.p( ' function delete_attachment (del_url) {
      if (confirm('||'"'||l_del_msg||'"'||'))
      {
       	  parent.location=del_url
      }
    }');
  htp.print('function help_window(){
      help_win = window.open('||
	fnd_help.get_url('ICX','@T_ATTACH')||
	', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,'||
	'height=250");
      help_win = window.open('||
	fnd_help.get_url('ICX','@T_ATTACH')||
	', "help_win","resizable=yes,scrollbars=yes,toolbar=yes,width=450,'||
	'height=250")}');
  htp.print(  '</SCRIPT>' );
  htp.title(l_title);

  -- Add the java script to the header to open the dm window for
  -- any DM function that is executed.
  fnd_document_management.get_open_dm_attach_window;

  -- Add java script to the header to open display window
  fnd_document_management.get_open_dm_display_window;

  -- Style sheet declaration.
  htp.p('<LINK REL=STYLESHEET HREF="/OA_HTML/US/osswa.css" TYPE="text/css">');

  htp.headClose;
  htp.bodyOpen;

  -- Body background color.
  htp.p('<BODY bgcolor="#cccccc">');
  htp.br;


  -- Process the cursor
  open al_cursor;
  fetch al_cursor into atlstrec;
  if al_cursor%NOTFOUND then
     close al_cursor;
     htp.bold(fnd_message.get_string('FND','FND-WEBATCH-SUMMARY-NOATCHMTS'));
     htp.br;
     htp.print( '</LEFT>' );
     htp.br;
     htp.br;
     --htp.tableOpen( cattributes => ' border=1 cellpadding=3 bgcolor=white' );
     -- Branch to the bottom header
     GOTO bottom_header;
  end if;

  -- Create a header.
  htp.p('<table width=98% cellpadding=0 cellspacing=0 border=0>');
  htp.p('<tr bgcolor=#336699>');
  htp.p('<td><font color=#336699>.</font></td>');
  htp.p('<TD width=100% nowrap><FONT CLASS=containertitle>'||
		fnd_message.get_string('FND','FND-WEBATCH-SUMMARY-HEADING')
		||' : '||atlstrec.user_entity_name||'</FONT></TD>');
  htp.tableRowClose;
  htp.tableClose;
  htp.br;

  -- There are some attachments for the entity. Construct the page.
  htp.p('<table width=98% bgcolor=#999999 cellpadding=2 '||
						'cellspacing=0 border=0>');
  htp.p('<tr><td>');

  htp.p('<table width=100% cellpadding=2 cellspacing=1 border=0>');
  htp.p('<TR BGColor="336699">');

  --Top Column Headings
  htp.p('<TD align=center valign=bottom bgcolor="336699"> '||
                '<FONT class=promptwhite>'||
                fnd_message.get_string('FND','FND-WEBATCH-DOCUMENT-DETAILS')||
                               '</TD>');
  htp.p('<TD align=center valign=bottom bgcolor="336699"> '||
                '<FONT class=promptwhite>'||
                fnd_message.get_string('FND','FND-WEBATCH-DOCUMENT-SEQUENCE')||
                               '</TD>');
  htp.p('<TD align=center valign=bottom bgcolor="336699"> '||
                '<FONT class=promptwhite>'||
                fnd_message.get_string('FND','FND-WEBATCH-DOCUMENT-DESCRIPTI')||
                               '</TD>');
  htp.p('<TD align=center valign=bottom bgcolor="336699"> '||
                '<FONT class=promptwhite>'||
                fnd_message.get_string('FND','FND-WEBATCH-DOCUMENT-CATEGORY')||
                               '</TD>');
  htp.p('<TD align=center valign=bottom bgcolor="336699"> '||
                '<FONT class=promptwhite>'||
                fnd_message.get_string('FND','FND-WEBATCH-DOCUMENT-DATATYPE')||
                               '</TD>');
  if (query_only <> 'Y') then
     htp.p('<TD align=center valign=bottom bgcolor="336699"> '||
                '<FONT class=promptwhite>'||
                fnd_message.get_string('FND','FND-WEBATCH-EDIT-ATCHMT')||
                               '</TD>');
     htp.p('<TD align=center valign=bottom bgcolor="336699"> '||
                '<FONT class=promptwhite>'||
                fnd_message.get_string('FND','FND-WEBATCH-REMOVE-ATCHMT')||
                               '</TD>');
  end if;

  -- Create Attachment List to displayed.
  loop

    -- Make altenate rows with different background.
    if (round(j/2) = j/2) then
        htp.p('<TR BGColor="ffffff">');
    else
        htp.p('<TR BGColor="99ccff">');
    end if;

    --Construct the one html line per row fetched.
    if (atlstrec.datatype_id = 6) then
      htp.p('<TD ><FONT class=tabledata>'||
		htf.anchor2(owa_util.get_owa_service_path
		||'fnd_webattch.ViewFileDocument?attached_document_id='
                ||icx_call.encrypt2(to_char(atlstrec.attached_document_id)),
         	htf.img2( '/OA_MEDIA/FNDIITMD.gif',
			calt => fnd_message.get_string('FND','HE_VIEW')
			||' '||atlstrec.datatype_name,
			cattributes => 'border=no'),
		ctarget=>'document_frame') ||'</TD>');
    elsif(atlstrec.datatype_id = 5) then
      htp.p('<TD ><FONT class=tabledata>'||
	    htf.anchor2(atlstrec.file_name,
         	htf.img2( '/OA_MEDIA/FNDIITMD.gif',
			calt => fnd_message.get_string('FND','HE_VIEW')
			||' '||atlstrec.datatype_name,
			cattributes => 'border=no'),
		ctarget=>'document_frame')
	  ||'</TD>');
    elsif(atlstrec.datatype_id = 7) then
          -- Get the HTML text for displaying the document
       fnd_document_management.get_launch_document_url (
	      l_username,
              atlstrec.file_name,
              FALSE,
              link_string);
      htp.p('<TD ><FONT class=tabledata>'||
		htf.anchor2(link_string, htf.img2( '/OA_MEDIA/FNDIITMD.gif',
			calt => fnd_message.get_string('FND','HE_VIEW')
			||' '||atlstrec.datatype_name,
			cattributes => 'border=no'),
		ctarget=>'document_frame')
	  ||'</TD>');
    elsif(atlstrec.datatype_id = 1) OR
	 (atlstrec.datatype_id = 2) then
	htp.p('<TD ><FONT class=tabledata>'||
		htf.anchor2(owa_util.get_owa_service_path|| package_name
		||'.ViewTextDocument?attached_document_id='||
                icx_call.encrypt2(to_char(atlstrec.attached_document_id))
		||'&'||'function_name='||icx_call.encrypt2(function_name)
            	||'&'||'entity_name='||icx_call.encrypt2(entity_name)
            	||'&'||'pk1_value='||icx_call.encrypt2(pk1_value)
            	||'&'||'pk2_value='||icx_call.encrypt2(pk2_value)
            	||'&'||'pk3_value='||icx_call.encrypt2(pk3_value)
            	||'&'||'pk4_value='||icx_call.encrypt2(pk4_value)
            	||'&'||'pk5_value='||icx_call.encrypt2(pk5_value)
            	||'&'||'from_url='||icx_call.encrypt2(from_url)
            	||'&'||'query_only='||icx_call.encrypt2(query_only),
         	htf.img2( '/OA_MEDIA/FNDIITMD.gif',
			calt => fnd_message.get_string('FND','HE_VIEW')
			||' '||atlstrec.datatype_name,
			cattributes => 'border=no'),
		ctarget=>'document_frame')
	  ||'</TD>');
    end if;
    htp.p('<TD ><FONT class=tabledata>'|| atlstrec.seq_num|| '</TD>');
    htp.p('<TD ><FONT class=tabledata>'|| atlstrec.document_description||
	  '</TD>');
    htp.p('<TD ><FONT class=tabledata>'|| atlstrec.category_description ||
	  '</TD>');
    htp.p('<TD ><FONT class=tabledata>'|| atlstrec.datatype_name|| '</TD>');

    if  (atlstrec.usage_type <> 'S') and
        (query_only <> 'Y') then
	htp.p('<TD ><FONT class=tabledata>'||
		htf.anchor2(owa_util.get_owa_service_path|| package_name
		||'.UpdateAttachment?attached_document_id='||
           	icx_call.encrypt2(to_char(atlstrec.attached_document_id))
           	||'&'||'function_name='||icx_call.encrypt2(function_name)
           	||'&'||'entity_name='||icx_call.encrypt2(entity_name)
           	||'&'||'pk1_value='||icx_call.encrypt2(pk1_value)
           	||'&'||'pk2_value='||icx_call.encrypt2(pk2_value)
           	||'&'||'pk3_value='||icx_call.encrypt2(pk3_value)
           	||'&'||'pk4_value='||icx_call.encrypt2(pk4_value)
           	||'&'||'pk5_value='||icx_call.encrypt2(pk5_value)
           	||'&'||'from_url='|| icx_call.encrypt2
					(replace(from_url,'&','%26'))
           	||'&'||'query_only='||icx_call.encrypt2(query_only),
         	htf.img2( '/OA_MEDIA/FNDIEDIT.gif', calign => 'CENTER',
            	calt => '''Edit Attachment''',
            	cattributes => 'border=yes width=17 height=16'),
            	cattributes=>'target="_top"')
	  ||'</TD>');
    end if;

    if (query_only <> 'Y' ) then
	htp.p('<TD ><FONT class=tabledata>'||
		htf.anchor2('javascript:delete_attachment('''
		|| owa_util.get_owa_service_path
		||'fnd_webattch.DeleteAttachment?attached_document_id='
		||icx_call.encrypt2(to_char(atlstrec.attached_document_id))
           	||'&'||'function_name='||icx_call.encrypt2(function_name)
           	||'&'||'entity_name='||icx_call.encrypt2(entity_name)
           	||'&'||'pk1_value='||icx_call.encrypt2(pk1_value)
           	||'&'||'pk2_value='||icx_call.encrypt2(pk2_value)
           	||'&'||'pk4_value='||icx_call.encrypt2(pk4_value)
           	||'&'||'pk5_value='||icx_call.encrypt2(pk5_value)
           	||'&'||'from_url='||
               	 icx_call.encrypt2(replace(from_url,'&','%26'))
           	||'&'||'query_only='||icx_call.encrypt2(query_only)||''')',
                htf.img2( '/OA_MEDIA/FNDIDELR.gif',
                   calign => 'CENTER', calt => '''Delete Attachment''',
                   cattributes => 'border=yes width=17 height=16'))
	  ||'</TD>');
    end if;
    htp.tableRowClose;

    j := j + 1 ;

    fetch al_cursor into atlstrec;
    exit when al_cursor%NOTFOUND;
  end loop;
  close al_cursor;

  htp.tableClose;
  htp.p('</TD>');
  htp.p('</TR>');
  htp.p('</TABLE>');

  <<bottom_header>>
  htp.br;
  htp.p ('<LEFT>');
  if (query_only <> 'Y' ) then
     -- Create buttons for adding and back links.
     htp.p('<!-- This is a button table containing 2 buttons. The first'||
		' row defines the edges and tops-->');
     htp.p('<TD ALIGN="LEFT" WIDTH="100%">');
     htp.p('<table cellpadding=0 cellspacing=0 border=0>');
     htp.p('<tr>');
     htp.p('<!-- left hand button, round left side and square right side-->');
     htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif></td>');
     htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
     htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBSQRR.gif></td>');
     htp.p('<!-- standard spacer between square button images-->        ');
     htp.p('<td width=2 rowspan=5></td>');

     htp.p('<!-- right hand button, square left side and round right side-->');
     htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBSQRL.gif></td>');
     htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
     htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif></td>');
     htp.p('</tr>');
     htp.p('<tr>');
     htp.p('<!-- one cell of this type required for every button -->');
     htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
     htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
     htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
     htp.p('</tr>');
     htp.p('<tr>');
     htp.p('<!-- Text and links for each button are listed here-->');
     htp.p('<td bgcolor=#cccccc height=20 nowrap><a href="'
	||owa_util.get_owa_service_path ||package_name
	||'.AddAttachment?function_name='||icx_call.encrypt2(function_name)
        ||'&'||'entity_name='||icx_call.encrypt2(entity_name)
        ||'&'||'pk1_value='||icx_call.encrypt2(pk1_value)
        ||'&'||'pk2_value='||icx_call.encrypt2(pk2_value)
        ||'&'||'pk3_value='||icx_call.encrypt2(pk3_value)
        ||'&'||'pk4_value='||icx_call.encrypt2(pk4_value)
        ||'&'||'pk5_value='||icx_call.encrypt2(pk5_value)
        ||'&'||'from_url='||icx_call.encrypt2(replace(from_url,'&','%26'))
        ||'&'||'query_only='||icx_call.encrypt2(query_only)
	||'"target="_parent"><font class=button>'
	||fnd_message.get_string('FND','FND-WEBATCH-SUMMARY-ADD'));
     htp.p('</FONT></TD>');
     htp.p('<TD bgcolor=#cccccc height=20 nowrap><A href="'
	|| from_url|| '" target="_parent" ><FONT class=button>'
	|| fnd_message.get_string('FND','FND-WEBATCH-SUMMARY-EXIT'));
     htp.p('</FONT></TD>');
     htp.p('</FONT></A></TD>');
     htp.p('</TR>');

     htp.p('<TR>');
     htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('</TR>');
     htp.p('<TR>');
     htp.p('<TD bgcolor=#333333><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('<TD bgcolor=#333333><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('<TD bgcolor=#333333><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('</TR>');
     htp.p('</TABLE>');
  else
     htp.p('<!-- This is a button table containing 1 buttons. The first'||
				' row defines the edges and tops-->');
     htp.p('<TD ALIGN="LEFT" WIDTH="100%">');
     htp.p('<table cellpadding=0 cellspacing=0 border=0>');
     htp.p('<tr>');
     htp.p('<!-- button, round left side and right side-->');
     htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif></td>');
     htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
     htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif></td>');

     htp.p('<tr>');
     htp.p('<!-- one cell of this type required for every button -->');
     htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
     htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
     htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
     htp.p('</tr>');
     htp.p('<tr>');
     htp.p('<!-- Text and links for each button are listed here-->');
     htp.p('<TD bgcolor=#cccccc height=20 nowrap><A href="'
	|| from_url|| '"><FONT class=button>'
	|| fnd_message.get_string('FND','FND-WEBATCH-SUMMARY-EXIT'));
     htp.p('</FONT></TD>');
     htp.p('</FONT></A></TD>');
     htp.p('</TR>');

     htp.p('<TR>');
     htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('</TR>');
     htp.p('</TABLE>');
  end if;

  htp.bodyClose;
  htp.htmlClose;

  exception
    when others then
    rollback;
    if (al_cursor%isopen) then
       close al_cursor;
    end if;
end PrintSummary;

-- PrintTextDocument
--      Print the web page that displays text document information.
-- IN
--      package_name    - Calling package name.
--      attached_document_id - Reference to the attached document
--      function_name   - Function name of the web function
--      entity_name     - Entity name to which the attachment is made.
--      pk1_value       - First primary key of the entity.
--       through
--      pk5_value       - Fifth primary key value of the entity.
--      from_url        - URL from which the attachments is invoked from.
--                        This is required to set the back link.
--      query_only      - Query flag is set 'Y' when called in query only
--                        mode.
--

procedure PrintTextDocument(
        package_name            in varchar2     default 'FND_WEBATTCH',
        attached_document_id    in varchar2,
        function_name           in varchar2     ,
        entity_name             in varchar2     ,
        pk1_value               in varchar2     ,
        pk2_value               in varchar2     default NULL,
        pk3_value               in varchar2     default NULL,
        pk4_value               in varchar2     default NULL,
        pk5_value               in varchar2     default NULL,
        from_url                in varchar2,
        query_only              in varchar2     default 'N'
 ) as


  l_seq_num			number;
  l_datatype_id			number;
  l_text			long;
  l_category_description	varchar2(255);
  l_document_description	varchar2(255);
  l_html_text			varchar2(32000);
  l_function_name     varchar2(30) :=
			icx_call.decrypt2(PrintTextDocument.function_name);
  l_attached_document_id	varchar2(16):=
                icx_call.decrypt2(PrintTextDocument.attached_document_id);

begin

  -- Find out the datatype of text being displayed.
  select fd.datatype_id
  into l_datatype_id
  from fnd_documents fd, fnd_attached_documents fad
  where fd.document_id = fad.document_id
   and  fad.attached_document_id = to_number(l_attached_document_id);

  -- Get the document text for the attachment.
  if (l_datatype_id = 2) then
     select  fdfv.seq_num, fdfv.category_description,
             fdfv.document_description, fdlt.long_text
     into  l_seq_num,l_category_description,l_document_description,l_text
     from  fnd_attached_docs_form_vl fdfv, fnd_documents_long_text fdlt
     where fdfv.media_id = fdlt.media_id
      and  fdfv.attached_document_id = to_number(l_attached_document_id)
      and  fdfv.function_name = l_function_name
      and  fdfv.function_type = 'F';
  else
     select  fdfv.seq_num, fdfv.category_description,
             fdfv.document_description, fdst.short_text
     into  l_seq_num,l_category_description,l_document_description,l_text
     from  fnd_attached_docs_form_vl fdfv, fnd_documents_short_text fdst
     where fdfv.media_id = fdst.media_id
      and  fdfv.attached_document_id = to_number(l_attached_document_id)
      and  fdfv.function_name = l_function_name
      and  fdfv.function_type = 'F';
  end if;

  -- Replace all newline character with <BR> and newline character.
  l_html_text := substrb(replace(l_text, fnd_webattch.g_chr_newline,
                                 '<BR>'||fnd_webattch.g_chr_newline),
                          	 1, 32000);

  htp.bodyClose;
  htp.htmlClose;
  htp.p('<BODY bgcolor="#cccccc">');

  -- Display the text
  htp.formOpen('','','','','NAME="displaytext"');
  htp.tableOpen(  cattributes => ' border=0 cellpadding=2 cellspacing=0' );
  htp.tableRowOpen;
  htp.p('<TD>');
  htp.p('</TD>');
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableData( l_html_text);
  htp.tableRowClose;
  htp.tableClose;

  htp.formClose;
  htp.bodyClose;
  htp.htmlClose;

exception

  when NO_DATA_FOUND then
    htp.p(fnd_message.get_string('FND','FND-WEBATCH-ERROR-RETRIEVING'));
    htp.bodyClose;
    htp.htmlClose;

end PrintTextDocument;

-- PrintUpdateAttachment
--      Prints the HTML form to update attachment and document information.
-- IN
--      package_name    - Calling package name.
--      seq_num         - Attachment Seq Number.
--      attached_document_id
--      function_name   - Function name of the web function
--      entity_name     - Entity name to which the attachment is made.
--      pk1_value       - First primary key of the entity.
--       through
--      pk5_value       - Fifth primary key value of the entity.
--      from_url        - URL from which the attachments is invoked from.
--                        This is required to set the back link.
--      query_only      - Query flag is set 'Y' when called in query only
--                        mode.
--

procedure PrintUpdateAttachment (
        package_name            in varchar2     default 'FND_WEBATTCH',
        attached_document_id    in varchar2,
        function_name           in varchar2,
        entity_name             in varchar2,
        pk1_value               in varchar2,
        pk2_value               in varchar2     default NULL,
        pk3_value               in varchar2     default NULL,
        pk4_value               in varchar2     default NULL,
        pk5_value               in varchar2     default NULL,
        from_url                in varchar2,
        query_only      	in varchar2     default 'N'
) as
  cursor att_doc_cursor is
    select	seq_num,
   		category_description,
   		document_description,
   		datatype_id,
   		media_id,
   		file_name
    from fnd_attached_docs_form_vl
    where attached_document_id = PrintUpdateAttachment.attached_document_id;

  cursor doc_cat_cursor is
    select user_name,category_id,default_datatype_name,default_datatype_id
    from fnd_doc_categories_active_vl
    where category_id in
       (select fdcu.category_id
        from fnd_doc_category_usages fdcu, fnd_attachment_functions af
   	where af.attachment_function_id = fdcu.attachment_function_id
   	 and  af.function_name = PrintUpdateAttachment.function_name
         and  af.function_type = 'F'
   	 and  fdcu.enabled_flag = 'Y')
	order by user_name;

  attdocrec	att_doc_cursor%ROWTYPE;

  document_short_text		varchar2(2000);
  document_long_text		long;
  x_seq_num			number;
  x_category_description	varchar2(255);
  x_document_description	varchar2(255);
  x_datatype_id			number;
  x_media_id			number;
  x_file_name			varchar2(255);
  l_lang			varchar2(24);
  access_id                  	number;
  upload_action			varchar2(2000);
  l_username			varchar2(80);
  l_reload_url			varchar2(2000);

  begin

   -- Validate the session
   if NOT (icx_sec.ValidateSession(null)) then
	return;
   end if;

   -- Set the language
   l_lang :=  icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
   l_username := UPPER(ICX_SEC.GetID(99));

   -- Construct reload URL.
   l_reload_url := owa_util.get_owa_service_path|| package_name||
        '.Summary?function_name='|| icx_call.encrypt2(function_name)
        ||'&'||'entity_name='||icx_call.encrypt2(entity_name)
        ||'&'||'pk1_value='||icx_call.encrypt2(pk1_value)
        ||'&'||'pk2_value='||icx_call.encrypt2(pk2_value)
        ||'&'||'pk3_value='||icx_call.encrypt2(pk3_value)
        ||'&'||'pk4_value='||icx_call.encrypt2(pk4_value)
        ||'&'||'pk5_value='||icx_call.encrypt2(pk5_value)
        ||'&'||'from_url=' ||icx_call.encrypt2(from_url)
        ||'&'||'query_only='||icx_call.encrypt2(query_only);

   htp.htmlOpen;
   htp.headOpen;

   -- Add the java script to the header to open the dm window for
   -- any DM function that is executed.
   fnd_document_management.get_open_dm_attach_window;

   -- Add java script to the header to open display window
   fnd_document_management.get_open_dm_display_window;

   -- Add java script to open the summary window.
   htp.p( '<SCRIPT LANGUAGE="JavaScript">');
   htp.p( ' function applySubmit(url) {
       document.UPDATE_ATCHMT.submit();
       top.location.href = url;
   }');
   htp.print(  '</SCRIPT>' );

   -- Style sheet declaration.
   htp.p('<LINK REL=STYLESHEET HREF="/OA_HTML/US/osswa.css" '||
                                                    'TYPE="text/css">');

   htp.headClose;
   htp.bodyOpen;

   -- Body background color.
   htp.p('<BODY bgcolor="#cccccc">');
   htp.br;

   -- Print the Page Header.
   htp.p('<table width=98% cellpadding=0 cellspacing=0 border=0>');
   htp.p('<tr bgcolor=#336699>');
   htp.p('<td><font color=#336699>.</font></td>');
   htp.p('<TD width=100% nowrap><FONT CLASS=containertitle>'||
         fnd_message.get_string('FND','FND-WEBATCH-EDIT-ATCHMT-HEADIN')
         ||'</FONT></TD>');
   htp.tableRowClose;
   htp.tableClose;
   htp.br;

   -- Select the updatable information.
   open att_doc_cursor;
   fetch att_doc_cursor into attdocrec;
   if att_doc_cursor%NOTFOUND then
     close att_doc_cursor;
     htp.p(fnd_message.get_string('FND','FND-WEBATCH-ERROR-RETRIEVING')
								||'for update');
     htp.print( '</LEFT>' );
     htp.bodyClose;
     htp.htmlclose;
     return;
   end if;

   loop
      x_seq_num 	:= attdocrec.seq_num;
      x_datatype_id:= attdocrec.datatype_id;
      x_media_id 	:= attdocrec.media_id;
      x_file_name 	:= attdocrec.file_name;
      x_category_description := attdocrec.category_description;
      x_document_description := attdocrec.document_description;

      fetch att_doc_cursor into attdocrec;
      exit when att_doc_cursor%NOTFOUND;
   end loop;
   close att_doc_cursor;

   -- GFM Preparation
   access_id := fnd_gfm.authorize(NULL);
   upload_action := 'fnd_webattch.update_attachment_gfm_wrapper';

   htp.formOpen( curl => upload_action, cattributes=>'NAME="UPDATE_ATCHMT"',
                cmethod => 'POST',cenctype=> 'multipart/form-data');

   -- Set the Attachment Information.
   htp.p('<table width=97% cellpadding=0 cellspacing=0 border=0>');
   htp.p('<!-- This row contains the help text -->');
   htp.p('<tr bgcolor=#cccccc>');

   htp.p('<td valign=top>');
   htp.p('<FONT CLASS=helptext>'||'&'||'nbsp;  '||
         '<IMG src=/OA_MEDIA/FNDIREQD.gif align=top>'||
         fnd_message.get_string('FND', 'FND-WEBATCH-REQ-FIELDS')||
         '</FONT>');
   htp.p('</TD>');
   htp.p('</TR>');
   htp.p('</TABLE>');
   htp.br;

   --Set the Attachment Information.
   htp.tableOpen(  cattributes => ' border=0 cellpadding=0 '||
                                  'width=97% cellspacing=0' );
   htp.tableRowOpen;
   htp.p('<TD align=right valign=top height=5 width=15%>'||
         '<IMG src=/OA_MEDIA/FNDIREQD.gif border=no>'||
	 '<FONT class=promptblack>'||
         fnd_message.get_string('FND', 'FND-WEBATCH-DOCUMENT-SEQUENCE')
         || ' </FONT></TD>');

   htp.p('<TD  VALIGN=CENTER ALIGN=LEFT>'||
         '<FONT class=datablack><INPUT NAME='||'"seq_num"'||
         ' TYPE='||'"text"'||'  VALUE='|| to_char(x_seq_num)||
	 ' SIZE=4 MAXLENGTH=20></FONT></TD>');
   htp.tableRowClose;

   --Process the category poplist.
   htp.tableRowOpen;
   htp.p('<TD align=right valign=top>'||
         '<IMG src=/OA_MEDIA/FNDIREQD.gif border=no>'||
         '<FONT class=promptblack>'||
         fnd_message.get_string('FND', 'FND-WEBATCH-DOCUMENT-CATEGORY')
         || ' </FONT></TD>');
   htp.p('<TD><font class=datablack>');
   htp.formSelectOpen( cname => 'category_id' );
   FOR dc in doc_cat_cursor LOOP
     if (dc.user_name <> ' ' ) then
        if (dc.user_name <> x_category_description ) then
           htp.p('<OPTION value='||to_char(dc.category_id)||'>'||dc.user_name);
        else
	   htp.p('<OPTION SELECTED value='||to_char(dc.category_id)||
                 '>'||dc.user_name);
        end if;
     else
        htp.p('<OPTION value>'||x_category_description);
     end if;
   END LOOP;
   htp.formSelectClose;
   htp.p('</FONT></TD>');
   htp.tableRowClose;

   -- Display Document Description.
   htp.tableRowOpen;
   htp.p('<TD align=right valign=top>'||
                '<IMG src=/OA_MEDIA/FNDIREQD.gif border=no>'||
                '<FONT class=promptblack>'||
                fnd_message.get_string('FND', 'FND-WEBATCH-DOCUMENT-DESCRIPTI')
                || ' </FONT></TD>');
     htp.p('<TD  VALIGN=CENTER ALIGN=LEFT>'||
           '<FONT class=datablack><INPUT NAME='||'"document_description"'||
           ' TYPE='||'"text"'|| '  VALUE="'|| x_document_description ||
	   '" SIZE=25 MAXLENGTH=80></FONT></TD>');
   htp.tableRowClose;
   htp.tableRowOpen;

   htp.p('<td colspan=5 valign=bottom height=30 VALIGN=CENTER ALIGN=LEFT>');
   htp.p('<FONT CLASS=datablack>'||
         fnd_message.get_string('FND', 'FND-WEBATCH-DOC-INFO-HEADING')||
         '</FONT></TD></TR>');
   htp.p('<TR><TD colspan=5 height=1 bgcolor=black>'||
         '<IMG src=/OA_MEDIA/FNDPX1.gif></TD></TR>');
   htp.p('<TR><TD height=10></TD></TR>');
   --htp.tableClose;

   -- Query the text from the database.
   if (x_datatype_id = 1 ) then
      select short_text
        into document_short_text
      from fnd_documents_short_text
      where media_id = x_media_id;

      -- Display the blank text information for Update.
      DocumentInformation (x_datatype_id => x_datatype_id,
			  x_short_text => document_short_text);

   elsif (x_datatype_id = 2) then
      select long_text
        into document_long_text
      from fnd_documents_long_text
      where media_id = x_media_id;

      -- Display the blank text information for Update.
      DocumentInformation (x_datatype_id => x_datatype_id,
                          x_long_text => document_long_text);

   elsif (x_datatype_id = 6) then

      -- Display the File Information for update.
      DocumentInformation (x_datatype_id => x_datatype_id,
			  x_file_name => x_file_name);

   elsif (x_datatype_id = 5) then

      -- Display blank URL document Information for Update
      DocumentInformation (x_datatype_id => x_datatype_id,
			  x_file_name => x_file_name);
   elsif (x_datatype_id = 7) then

      -- Display blank URL document Information for Update
      DocumentInformation (x_datatype_id => x_datatype_id,
			  x_file_name => x_file_name);
   else
      htp.formHidden ( cname =>'text', cvalue=>'');
      htp.formHidden ( cname =>'file_name', cvalue=>'');
      htp.formHidden ( cname =>'url', cvalue=>'');
   end if;

   -- Set the data needed for displaying summary as hidden field.
   htp.formHidden ( cname =>'attached_document_id',
					cvalue=> attached_document_id );
   htp.formHidden ( cname =>'datatype_id', cvalue=> to_char(x_datatype_id));
   htp.formHidden ( cname =>'function_name', cvalue=> function_name );

   htp.formHidden ( cname =>'entity_name', cvalue=> entity_name);
   htp.formHidden ( cname =>'pk1_value', cvalue=> pk1_value);
   htp.formHidden ( cname =>'pk2_value', cvalue=> pk2_value);
   htp.formHidden ( cname =>'pk3_value', cvalue=> pk3_value);
   htp.formHidden ( cname =>'pk4_value', cvalue=> pk4_value);
   htp.formHidden ( cname =>'pk5_value', cvalue=> pk5_value);
   htp.formHidden ( cname =>'from_url',  cvalue=> from_url);
   htp.formHidden ( cname =>'query_only', cvalue=> query_only);
   htp.formHidden ( cname =>'package_name', cvalue=>
	icx_sec.getID(icx_sec.PV_WEB_USER_ID)||';'
	|| PrintUpdateAttachment.package_name ||';'||to_char(access_id)||';');
   htp.br;

   -- Create buttons for adding and back links.
   htp.p('<!-- This is a button table containing 2 buttons. The first'||
         ' row defines the edges and tops-->');
   htp.p('<TD ALIGN="LEFT" WIDTH="100%">');
   htp.p('<table cellpadding=0 cellspacing=0 border=0>');
   htp.p('<tr>');
   htp.p('<!-- left hand button, round left side and square right side-->');
   htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif></td>');
   htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
   htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBSQRR.gif></td>');
   htp.p('<!-- standard spacer between square button images-->        ');
   htp.p('<td width=2 rowspan=5></td>');

   htp.p('<!-- right hand button, square left side and round right side-->');
   htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBSQRL.gif></td>');
   htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
   htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif></td>');
   htp.p('</tr>');
   htp.p('<tr>');
   htp.p('<!-- one cell of this type required for every button -->');
   htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
   htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
   htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
   htp.p('</tr>');
   htp.p('<tr>');
   htp.p('<!-- Text and links for each button are listed here-->');
   htp.p('<td bgcolor=#cccccc height=20 nowrap>'||
         '<A href="javascript:applySubmit('''||l_reload_url||''')"'||
         '  OnMouseOver="window.status='''||'OK'||''';return true">'||
         '<font class=button>'||
         fnd_message.get_string('FND','FND-WEBATCH-UPDATE-ATTACHMENT'));
   htp.p('</FONT></TD>');
   htp.p('<td bgcolor=#cccccc height=20 nowrap>'||
         '<A href="javascript:document.UPDATE_ATCHMT.reset()"'||
         '  OnMouseOver="window.status='''||'Reset'||''';return true">'||
         '<font class=button>'||
         fnd_message.get_string('FND','FND-WEBATCH-FORM-RESET'));
   htp.p('</FONT></TD>');
   htp.p('</FONT></A></TD>');
   htp.p('</TR>');

   htp.p('<TR>');
   htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
   htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
   htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
   htp.p('</TR>');
   htp.p('<TR>');
   htp.p('<TD bgcolor=#333333><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
   htp.p('<TD bgcolor=#333333><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
   htp.p('<TD bgcolor=#333333><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
   htp.p('</TR>');
   htp.p('</TABLE>');

   htp.formClose;
   htp.bodyClose;
   htp.htmlClose;

   exception
   when others then
     rollback;
     if (doc_cat_cursor%isopen) then
       close doc_cat_cursor;
     end if;
     if (att_doc_cursor%isopen) then
       close att_doc_cursor;
     end if;
end PrintUpdateAttachment;

-- PrintAddAttachment
--      Prints the HTML form to add attachment and document information.
-- IN
--      package_name    - Calling package name.
--      function_name   - Function name of the web function
--      entity_name     - Entity name to which the attachment is made.
--      pk1_value       - First primary key of the entity.
--       through
--      pk5_value       - Fifth primary key value of the entity.
--      from_url        - URL from which the attachments is invoked from.
--                        This is required to set the back link.
--      query_only      - Query flag is set 'Y' when called in query only
--                        mode.
--

Procedure PrintAddAttachment(
        package_name    in varchar2     default 'FND_WEBATTCH',
        function_name   in varchar2,
        entity_name     in varchar2,
        pk1_value       in varchar2,
        pk2_value       in varchar2     default NULL,
        pk3_value       in varchar2     default NULL,
        pk4_value       in varchar2     default NULL,
        pk5_value       in varchar2     default NULL,
        from_url        in varchar2,
        query_only      in varchar2     default 'N'
 ) as
   cursor dc_cursor is
	select user_name,category_id,default_datatype_name,default_datatype_id
	from fnd_doc_categories_active_vl
	where category_id in
	 (select fdcu.category_id
	  from fnd_doc_category_usages fdcu, fnd_attachment_functions af
	  where af.attachment_function_id = fdcu.attachment_function_id
	   and     af.function_name = PrintAddAttachment.function_name
           and     af.function_type = 'F'
	   and     fdcu.enabled_flag = 'Y')
	order by user_name;

   cursor sm_cursor is
    select NVL(max(seq_num),0) + 10
      from fnd_attached_documents
     where entity_name = PrintAddAttachment.entity_name
     and   pk1_value   = PrintAddAttachment.pk1_value
     and decode(PrintAddAttachment.pk2_value,null,'*',PK2_VALUE) =
    decode(PrintAddAttachment.pk2_value,null,'*',PrintAddAttachment.pk2_value)
     and decode(PrintAddAttachment.pk3_value,null,'*',PK3_VALUE)=
    decode(PrintAddAttachment.pk3_value,null,'*',PrintAddAttachment.pk3_value)
     and decode(PrintAddAttachment.pk4_value,null,'*',PK4_VALUE)=
    decode(PrintAddAttachment.pk4_value,null,'*', PrintAddAttachment.pk4_value)
     and decode(PrintAddAttachment.pk5_value,null,'*',PK5_VALUE)=
    decode(PrintAddAttachment.pk5_value,null,'*',PrintAddAttachment.pk5_value);

   seq_num	 	number := 10;
   l_lang		varchar2(24);
   access_id     	number;
   upload_action	varchar2(2000);
   l_callback_url       varchar2(4000);
   l_search_document_url       varchar2(4000);
   l_username                  varchar2(80);
   l_reload_url       varchar2(2000);

   begin

     -- Validate the session
     if NOT (icx_sec.ValidateSession(null)) then
	return;
     end if;

     -- Set the language
     l_lang :=  icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
     l_username := UPPER(ICX_SEC.GetID(99));

     l_reload_url := owa_util.get_owa_service_path|| package_name||
        '.Summary?function_name='|| icx_call.encrypt2(function_name)
	||'&'||'entity_name='||icx_call.encrypt2(entity_name)
	||'&'||'pk1_value='||icx_call.encrypt2(pk1_value)
	||'&'||'pk2_value='||icx_call.encrypt2(pk2_value)
	||'&'||'pk3_value='||icx_call.encrypt2(pk3_value)
	||'&'||'pk4_value='||icx_call.encrypt2(pk4_value)
	||'&'||'pk5_value='||icx_call.encrypt2(pk5_value)
	||'&'||'from_url=' ||icx_call.encrypt2(from_url)
	||'&'||'query_only='||icx_call.encrypt2(query_only);

     htp.htmlOpen;
     htp.headOpen;

     -- Add the java script to the header to open the dm window for
     -- any DM function that is executed.
     fnd_document_management.get_open_dm_attach_window;

     -- Add java script to the header to open display window
     fnd_document_management.get_open_dm_display_window;

     htp.p( '<SCRIPT LANGUAGE="JavaScript">');
     htp.p( ' function applySubmit(url) {
         document.ADD_ATCHMT.submit();
	 top.location.href = url;
     }');
     htp.print(  '</SCRIPT>' );

     -- Style sheet declaration.
     htp.p('<LINK REL=STYLESHEET HREF="/OA_HTML/US/osswa.css" '||
							'TYPE="text/css">');

     htp.headClose;
     htp.bodyOpen;

     -- Body background color.
     htp.p('<BODY bgcolor="#cccccc">');
     htp.br;

     -- Print the Page Header.
     htp.p('<table width=98% cellpadding=0 cellspacing=0 border=0>');
     htp.p('<tr bgcolor=#336699>');
     htp.p('<td><font color=#336699>.</font></td>');
     htp.p('<TD width=100% nowrap><FONT CLASS=containertitle>'||
            fnd_message.get_string('FND','FND-WEBATCH-ADDATCHMT-HEADING')
            ||'</FONT></TD>');
     htp.tableRowClose;
     htp.tableClose;
     htp.br;

     -- GFM Preparation
     access_id := fnd_gfm.authorize(NULL);
     upload_action := 'fnd_webattch.add_attachment_gfm_wrapper';

     htp.formOpen( curl => upload_action , cattributes=>'NAME="ADD_ATCHMT"',
                cmethod => 'POST',cenctype=> 'multipart/form-data');

     htp.p('<table width=97% cellpadding=0 cellspacing=0 border=0>');
     htp.p('<!-- This row contains the help text -->');
     htp.p('<tr bgcolor=#cccccc>');

     htp.p('<td valign=top>');
     htp.p('<FONT CLASS=helptext>'||'&'||'nbsp;  '||
           fnd_message.get_string('FND', 'FND-WEBATCH-ATCHMT-INFO-HEADIN')||'  '
	   ||'<IMG src=/OA_MEDIA/FNDIREQD.gif align=top>'||
     	   fnd_message.get_string('FND', 'FND-WEBATCH-REQ-FIELDS')||'  '||
	   '</FONT>');
     htp.p('</TD>');
     htp.p('</TR>');
     htp.p('</TABLE>');
     htp.br;

     --Set the Attachment Information.
     htp.tableOpen(  cattributes => ' border=0 cellpadding=0 '||
					'width=97% cellspacing=0' );

     -- Get the max Sequence Number and set it seq_num.
     open sm_cursor;
     fetch sm_cursor into seq_num;
     close sm_cursor;

     htp.tableRowOpen;
     htp.p('<TD align=right valign=top height=5 width=35%>'||
		'<IMG src=/OA_MEDIA/FNDIREQD.gif border=no>'||
		'<FONT class=promptblack>'||
		fnd_message.get_string('FND', 'FND-WEBATCH-DOCUMENT-SEQUENCE')
		|| ' </FONT></TD>');

     htp.p('<TD  VALIGN=CENTER ALIGN=LEFT>'||
	   '<FONT class=datablack><INPUT NAME='||'"seq_num"'||
	   ' TYPE='||'"text"'||'  VALUE='||
	   to_char(seq_num)||' SIZE=4 MAXLENGTH=20></FONT></TD>');
     htp.tableRowClose;

     --Process the category poplist.
     htp.tableRowOpen;
     htp.p('<TD align=right valign=top>'||
		'<IMG src=/OA_MEDIA/FNDIREQD.gif border=no>'||
		'<FONT class=promptblack>'||
		fnd_message.get_string('FND', 'FND-WEBATCH-DOCUMENT-CATEGORY')
		|| ' </FONT></TD>');
     htp.p('<TD><FONT class=datablack>');
     htp.formSelectOpen( cname => 'category_id' );
     FOR dc in dc_cursor LOOP
         if (dc.user_name <> ' ' ) then
           htp.p('<OPTION value='||to_char(dc.category_id)||'>'|| dc.user_name);
         else
           htp.p('<OPTION value>'||dc.user_name);
         end if;
     END LOOP;
     htp.formSelectClose;
     htp.p('</FONT></TD>');
     htp.tableRowClose;

     -- Display Document Description.
     htp.tableRowOpen;
     htp.p('<TD align=right valign=top>'||
		'<IMG src=/OA_MEDIA/FNDIREQD.gif border=no>'||
		'<FONT class=promptblack>'||
		fnd_message.get_string('FND', 'FND-WEBATCH-DOCUMENT-DESCRIPTI')
		|| ' </FONT></TD>');
     htp.p('<TD  VALIGN=CENTER ALIGN=LEFT>'||
	   '<FONT class=datablack><INPUT NAME='||'"document_description"'||
	   ' TYPE='||'"text"'|| ' SIZE=25 MAXLENGTH=80></FONT></TD>');
     htp.tableRowClose;

     -- Construct the Document Information area.
     -- Text datatype
     htp.tableRowOpen;

     htp.p('<td colspan=5 valign=bottom height=30 VALIGN=CENTER ALIGN=LEFT>');
     htp.p('<FONT CLASS=datablack>'||
     	   fnd_message.get_string('FND', 'FND-WEBATCH-DOC-INFO-HEADING')||
	   '</FONT></TD></TR>');
     htp.p('<TR><TD colspan=5 height=1 bgcolor=black>'||
	   '<IMG src=/OA_MEDIA/FNDPX1.gif></TD></TR>');
     htp.p('<TR><TD height=10></TD></TR>');

     htp.tableRowOpen;
     htp.p('<TD align=left valign=top>');
     htp.p('<FONT class=promptblack><INPUT name="datatype_id"'||
	   'type=radio checked value="2">'||
	   fnd_message.get_string('FND','FND-WEBATCH-TEXT-DATATYPE')||'</TD>');
     htp.p('<TD  VALIGN=CENTER ALIGN=LEFT>');
     htp.p('<FONT class=datablack><TEXTAREA NAME ="text"  ROWS=4 + COLS=38>'||
							'</TEXTAREA></FONT>');
     htp.tableRowClose;

     -- File Datatype
     htp.tableRowOpen;
     htp.p('<TD align=left>');
     htp.p('<FONT class=promptblack><INPUT name="datatype_id"'||
	   'type=radio value="6">'||
	   fnd_message.get_string('FND','FND-WEBATCH-FILE-DATATYPE')||'</TD>');
     htp.p('<TD  VALIGN=CENTER ALIGN=LEFT>');
     htp.p('<FONT class=datablack><INPUT TYPE="File" NAME="file_name"'||
					' SIZE="32"></FONT>');
     htp.tableRowClose;

     -- URL Datatype
     htp.tableRowOpen;
     htp.p('<TD align=left>');
     htp.p('<FONT class=promptblack><INPUT name="datatype_id"'||
	 'type=radio value="5">'||
	 fnd_message.get_string('FND','FND-WEBATCH-WEBPAGE-DATATYPE')||'</TD>');
     htp.p('<TD  VALIGN=CENTER ALIGN=LEFT>');
     htp.p('<FONT class=datablack><INPUT TYPE="Text" NAME="url"'||
					' SIZE="40"></FONT>');
     htp.tableRowClose;

     /*
     ** Create the callback syntax to update the local fields
     */
     fnd_document_management.set_document_id_html (
        null,
        'FNDATTACH',
        'dmid',
        'dmname',
        l_callback_url);

     -- Get the url syntax for performing a search
     fnd_document_management.get_launch_attach_url (
        l_username,
        l_callback_url,
        TRUE,
        l_search_document_URL);

     -- DM Datatype
     htp.tableRowOpen;
     htp.p('<TD align=left width=35% NOWRAP>');
     htp.p('<FONT class=promptblack><INPUT name="datatype_id"'||
	   'type=radio value="5">'||
	   fnd_message.get_string('FND','FND-WEBATCH-DM-DATATYPE')||'</TD>');
     htp.p('<TD  VALIGN=CENTER ALIGN=LEFT>');
     htp.p('<FONT class=datablack><INPUT TYPE="Text" NAME="dmid"'||
	   ' SIZE="40"></FONT>'||l_search_document_URL);
     htp.tableRowClose;
     htp.tableClose;

     -- Set the data needed for add attachment as hidden field.
     htp.formHidden (cname =>'access_id', cvalue=> to_char(access_id));
     htp.formHidden (cname =>'function_name', cvalue=> function_name);
     htp.formHidden (cname =>'entity_name', cvalue=> entity_name);
     htp.formHidden (cname =>'pk1_value', cvalue=> pk1_value);
     htp.formHidden (cname =>'pk2_value', cvalue=> pk2_value);
     htp.formHidden (cname =>'pk3_value', cvalue=> pk3_value);
     htp.formHidden (cname =>'pk4_value', cvalue=> pk4_value);
     htp.formHidden (cname =>'pk5_value', cvalue=> pk5_value);
     htp.formHidden (cname =>'from_url',  cvalue=> from_url);
     htp.formHidden (cname =>'query_only',cvalue=> query_only);
     htp.formHidden (cname =>'user_id',
                        cvalue=> icx_sec.getID(icx_sec.PV_WEB_USER_ID));
     htp.formHidden (cname =>'package_name',cvalue=>
				PrintAddAttachment.package_name );

     -- Submit and Reset Buttons.
     -- Create buttons for adding and back links.
     htp.br;
     htp.p('<!-- This is a button table containing 2 buttons. The first'||
                ' row defines the edges and tops-->');
     htp.p('<TD ALIGN="LEFT" WIDTH="100%">');
     htp.p('<table cellpadding=0 cellspacing=0 border=0>');
     htp.p('<tr>');
     htp.p('<!-- left hand button, round left side and square right side-->');
     htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBRNDL.gif></td>');
     htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
     htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBSQRR.gif></td>');
     htp.p('<!-- standard spacer between square button images-->        ');
     htp.p('<td width=2 rowspan=5></td>');

     htp.p('<!-- right hand button, square left side and round right side-->');
     htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBSQRL.gif></td>');
     htp.p('<td bgcolor=#333333><img src=/OA_MEDIA/FNDPX3.gif></td>');
     htp.p('<td rowspan=5><img src=/OA_MEDIA/FNDBRNDR.gif></td>');
     htp.p('</tr>');
     htp.p('<tr>');
     htp.p('<!-- one cell of this type required for every button -->');
     htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
     htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
     htp.p('<td bgcolor=#ffffff><img src=/OA_MEDIA/FNDPX6.gif></td>');
     htp.p('</tr>');
     htp.p('<tr>');
     htp.p('<!-- Text and links for each button are listed here-->');
     htp.p('<td bgcolor=#cccccc height=20 nowrap>'||
	   '<A href="javascript:applySubmit('''||l_reload_url||''')"'||
	   '  OnMouseOver="window.status='''||'OK'||''';return true">'||
           '<font class=button>'||
           fnd_message.get_string('FND','FND-WEBATCH-ADD-ATTACHMENT'));
     htp.p('</FONT></TD>');
     htp.p('<td bgcolor=#cccccc height=20 nowrap>'||
	   '<A href="javascript:document.ADD_ATCHMT.reset()"'||
	   '  OnMouseOver="window.status='''||'Reset'||''';return true">'||
           '<font class=button>'||
           fnd_message.get_string('FND','FND-WEBATCH-FORM-RESET'));
     htp.p('</FONT></TD>');
     htp.p('</FONT></A></TD>');
     htp.p('</TR>');

     htp.p('<TR>');
     htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('<TD bgcolor=#666666><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('</TR>');
     htp.p('<TR>');
     htp.p('<TD bgcolor=#333333><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('<TD bgcolor=#333333><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('<TD bgcolor=#333333><IMG src=/OA_MEDIA/FNDPX3.gif></TD>');
     htp.p('</TR>');
     htp.p('</TABLE>');
     htp.formClose;
     htp.bodyClose;
     htp.htmlClose;

   exception
     when others then
       htp.print('Error occured and control in exception');
       rollback;
       if (dc_cursor%isopen) then
         close dc_cursor;
       end if;
end PrintAddAttachment;

PROCEDURE PrintBlankPage
IS
BEGIN
  htp.htmlOpen;
  htp.bodyOpen;

  -- Body background color.
  htp.p('<BODY bgcolor="#cccccc">');

  htp.bodyClose;
  htp.htmlClose;
END PrintBlankPage;

/*===========================================================================

Function        set_document_identifier

Purpose         This is call back implemented to pass the document reference
                identifier to the attachments.


file_id - A unique access key for document reference attributes
                        being attached to a application entity.

document_identifier - full concatenated document attribute strings.
        nodeid:libraryid:documentid:version:document_name

============================================================================*/
PROCEDURE set_document_identifier (
p_file_id         IN  VARCHAR2,
p_document_id     IN  VARCHAR2)

IS

BEGIN
  /*
  ** Update FND_TEMP_FILE_PARAMETERS
  */
  IF (p_file_id IS NOT NULL) THEN
        UPDATE  fnd_temp_file_parameters
        SET     FILE_PARAMETERS = p_document_id
        WHERE   FILE_ID = p_file_id;

        if (SQL%NOTFOUND) then
          RAISE NO_DATA_FOUND;
        end if;
  END IF;


   htp.headOpen;
   htp.title(wf_core.translate('WFDM_TRANSPORT_WINDOW'));
   htp.headClose;

   htp.htmlopen;

   htp.p('<body bgcolor="#CCCCCC" onLoad="javascript:top.window.close();'||
         'return true;">');

   htp.htmlclose;


END set_document_identifier;

/*===========================================================================

Function        authorizeDMTransaction

Purpose         This will provide a secure key for DM transaction from forms.


file_id -       A unique access key for document reference attributes
                being attached to a application entity.

============================================================================*/
procedure authorizeDMTransaction(
		file_id OUT NOCOPY VARCHAR2)
IS
  pragma AUTONOMOUS_TRANSACTION;
  l_file_id	varchar2(32);
BEGIN
  -- Generate Random Number for secured access key
  fnd_random_pkg.init(7);
  fnd_random_pkg.seed(to_number(to_char(sysdate, 'JSSSSS')), 10, false);
  l_file_id := fnd_random_pkg.get_next;

  -- Store the file attributes for secured access and commit the
  -- transaction.
  insert into fnd_temp_file_parameters (file_id, file_parameters)
  values (l_file_id, null);

  -- Commit the transaction
  COMMIT;

  -- Set the file id to the ouput parameter
  file_id := l_file_id;

END;

end FND_WEBATTCH;

/
