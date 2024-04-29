--------------------------------------------------------
--  DDL for Package Body IEM_TEXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_TEXT_PVT" as
/* $Header: iemtextb.pls 120.12.12010000.2 2009/08/10 09:18:18 sanjrao ship $*/

 PROCEDURE GetThemes(p_message_id     IN   number,
				p_part_id in number,
				xbuf	 OUT NOCOPY iem_text_pvt.theme_Table,
                    errtext   OUT NOCOPY   VARCHAR2) IS
	l_part_id		number;
	TYPE theme_type is TABLE OF iem_imt_keywords.keyword%type;
	TYPE score_type is TABLE OF iem_imt_keywords.weight%type;
	theme_tbl theme_type:=theme_type();
	score_tbl score_type:=score_type();
 -- Below cursor will check for existing data for the message
 cursor c_weight is select keyword,weight from iem_imt_keywords
 where message_id=p_message_id and message_type=1 and message_part=l_part_id and message_format=1 ;
cursor c1 is select rowid from iem_imt_texts
 where message_id=p_message_id and message_type=1 and message_part=l_part_id and message_format=1 ;
	l_theme_buf	THEME_TABLE;
	l_count 		number:=0;
	l_status		varchar2(10);
	l_schema		varchar2(100);
begin
		l_schema:='IEM';
		IF p_part_id is null then
			l_part_id:=9999;
		ELSE
			l_part_id:=p_part_id;
		END IF;
	-- First check for existing message
	for v_theme in c_weight loop
			l_count:=l_count+1;
			xbuf(l_count).theme:=v_theme.keyword;
			xbuf(l_count).weight:=v_theme.weight;
	end loop;
 IF l_count=0 then		-- Need to Generate Themes
	IEM_TEXT_PVT.IEM_PROCESS_PARTS(p_message_id,1,p_part_id,null,l_status);
for v1 in c1 loop
CTX_DOC.THEMES(l_schema||'.IEM_IMT_INDEX',
       CTX_DOC.PKENCODE(v1.rowid), l_theme_buf, full_themes => FALSE);
end loop;
		-- Insert Into iem_imt_keywords Table for Future Use
		IF l_theme_buf.count>0 THEN
		for i in l_theme_buf.first..l_theme_buf.last LOOP
			xbuf(i).theme:=l_theme_buf(i).theme;
			xbuf(i).weight:=l_theme_buf(i).weight;
			theme_tbl.extend;
			theme_tbl(theme_tbl.last):=l_theme_buf(i).theme;
			score_tbl.extend;
			score_tbl(score_tbl.last):=l_theme_buf(i).weight;
		END LOOP;
		FORALL j in indices of theme_tbl
	insert into iem_imt_keywords(message_id,message_type,message_part,message_format,keyword,weight)
	values(p_message_id,1,l_part_id,1,theme_tbl(j),score_tbl(j));
		END IF;
 END IF;
END GetThemes;

 PROCEDURE GetTokens(p_message_id     IN   number,
 				p_part_id    in number,
				p_lang	in varchar2,
				xbuf	 OUT NOCOPY iem_text_pvt.token_table,
                    errtext   OUT  NOCOPY VARCHAR2) IS
	l_part_id		number;
	TYPE theme_type is TABLE OF iem_imt_keywords.keyword%type;
	theme_tbl theme_type:=theme_type();
 cursor c_weight is select keyword  from iem_imt_keywords
 where message_id=p_message_id and message_type=1 and message_part=l_part_id and message_format=2
 order by 1;
cursor c1 is select rowid from iem_imt_texts where
	message_id=p_message_id and message_type=1 and message_part=l_part_id and message_format=2;
	l_token_buf	TOKEN_TABLE;
	l_count 		number:=0;
	l_status		varchar2(10);
	l_schema		varchar2(10);
	l_keyword		iem_imt_keywords.keyword%type;
	l_counter		number;
	dml_errors EXCEPTION;
	PRAGMA exception_init(dml_errors, -24381);
     l_start		number:=1;
begin
	l_schema:='IEM';
		IF p_part_id is null then
			l_part_id:=9999;
		ELSE
			l_part_id:=p_part_id;
		END IF;
	-- First check for existing message
	for v_theme in c_weight loop
			l_count:=l_count+1;
			xbuf(l_count).token:=v_theme.keyword;
	end loop;
 IF l_count=0 then		-- Need to Generate Tokens
	IEM_TEXT_PVT.IEM_PROCESS_PARTS(p_message_id,1,p_part_id,p_lang,l_status);
for v1 in c1 loop
CTX_DOC.TOKENS(l_schema||'.IEM_IMT_INDEX',
       CTX_DOC.PKENCODE(v1.rowid), l_token_buf);
end loop;
		-- Insert Into iem_imt_keywords Table for Future Use
		IF l_token_buf.count>0 THEN
			for i in l_token_buf.first..l_token_buf.last LOOP
			theme_tbl.extend;
			theme_tbl(theme_tbl.last):=l_token_buf(i).token;
			END LOOP;
     LOOP
		BEGIN
		FORALL j in l_start..theme_tbl.count
	insert into iem_imt_keywords(message_id,message_type,message_part,message_format,keyword,weight)
	values(p_message_id,1,l_part_id,2,theme_tbl(j),null);
		EXIT;
         EXCEPTION WHEN OTHERS THEN
			l_start := l_start + sql%rowcount + 1;
	    END;
     END LOOP;
	END IF;
		-- populate the out buffer
		theme_tbl.delete;
		open c_weight;
		LOOP
			fetch c_weight bulk collect into theme_tbl;
			exit when c_weight%notfound;
		end loop;
		close c_weight;
		l_counter:=1;
		for i in theme_tbl.first..theme_tbl.last LOOP
			xbuf(l_counter).token:=theme_tbl(i);
			l_counter:=l_counter+1;
		end loop;
 END IF;
exception when others then
	null;
end GetTokens;

PROCEDURE IEM_INSERT_TEXTS(p_clob in clob,
					  p_lang  in varchar2,
					  x_id	OUT NOCOPY NUMBER,
					  x_status out nocopy varchar2) IS
l_seq		number;
l_msgformat	number;
l_imt_format	varchar2(100);
begin
l_imt_format:='TEXT';
	IF p_lang is null then
		l_msgformat:=1;
	ELSE
		l_msgformat:=2;
	END IF;
	select  nvl(max(message_id),0)+1 into l_Seq
	from iem_imt_texts where message_type=2;
		insert into iem_imt_texts
		(
		message_ID,
 		message_TYPE,
 		message_PART,
		message_format,
 		IMT_FORMAT,
 		IMT_CHARSET,
 		IMT_LANG,
		message_text)
 VALUES
		(l_seq
		,2
		,9999
		,l_msgformat
		,l_imt_format
		,null		-- May be defaulted to database char set.
		,p_lang
		,p_clob);
	x_status:='S';
	x_id:=l_seq;
EXCEPTION WHEN OTHERS THEN
	x_status:='E';
end;


-- Api for returning thems/token for Creation of Intent. Only to be used by Email Center
procedure iem_get_tokens(p_intent_id in number,
				p_type in number,		-- 1 for theme 2 for token
				p_lang	in varchar2,
				p_qtext	in varchar2,
				p_rtext	in varchar2,
				x_qtokens		OUT NOCOPY jtf_varchar2_Table_2000,
				x_rtokens		OUT NOCOPY jtf_varchar2_Table_2000,
				x_status	OUT NOCOPY varchar2)
is
	l_kw_tbl		iem_text_pvt.keyword_Rec_tbl;
	l_theme_enabled	varchar2(1);
	l_count		number:=1;
	cursor c_query is select keyword,weight from iem_intent_dtls
	where intent_id=p_intent_id
	and query_Response='Q';
	cursor c_resp is select keyword,weight from iem_intent_dtls
	where intent_id=p_intent_id
	and query_Response='R';
	l_flag		number;
	begin
		select decode(p_type,1,'Y','N') into l_theme_enabled from dual;
			l_kw_tbl.delete;
			x_qtokens:=jtf_varchar2_Table_2000();
			x_rtokens:=jtf_varchar2_Table_2000();
		IF p_qtext is not null then
			iem_text_pvt.get_tokens(p_type,p_lang,p_qtext,l_kw_tbl);
			IF l_kw_tbl.count>0 then
				for i in l_kw_tbl.first..l_kw_tbl.last LOOP
					-- Compare with existing intent keyword and donot allow duplicate keyword
					l_flag:=0;
					for v1 in c_query LOOP
					if l_kw_tbl(i).keyword = v1.keyword then
						l_flag:=1;
					end if;
					END LOOP;
					if l_flag=0 then		-- No match new keyword
						x_qtokens.extend;
						x_qtokens(l_count):=l_kw_tbl(i).keyword;
						l_count:=l_count+1;
					end if;
				END LOOP;
			END IF;
		END IF;
			l_kw_tbl.delete;
			l_count:=1;
		IF p_rtext is not null then
			iem_text_pvt.get_tokens(p_type,p_lang,p_rtext,l_kw_tbl);
			IF l_kw_tbl.count>0 then
				for i in l_kw_tbl.first..l_kw_tbl.last LOOP
					-- Compare with existing intent keyword and donot allow duplicate keyword
					l_flag:=0;
					for v1 in c_resp LOOP
					if l_kw_tbl(i).keyword = v1.keyword then
						l_flag:=1;
					end if;
					END LOOP;
					if l_flag=0 then
						x_rtokens.extend;
						x_rtokens(l_count):=l_kw_tbl(i).keyword;
					l_count:=l_count+1;
					end if;
				END LOOP;
			END IF;
		END IF;
		x_status:='S';
EXCEPTION WHEN OTHERS THEN
	x_status:='E';

END;


procedure get_tokens(p_type in number,		-- 1 for theme 2 for token
				p_lang	in varchar2,
				p_text	in CLOB,
				xbuf OUT NOCOPY iem_text_pvt.keyword_rec_tbl) IS
    l_seq		number;
    l_text	raw(32767);
    l_errortext	varchar2(100);
    l_tokenbuf		iem_text_pvt.token_Table;
	l_token_buf	TOKEN_TABLE;
    l_status		varchar2(10);
	l_theme_buf	THEME_TABLE;
	l_schema		varchar2(100);
	l_message_id	number;
	l_counter		number;
	TYPE theme_type is TABLE OF iem_imt_keywords.keyword%type;
	theme_tbl theme_type:=theme_type();
	l_start		number:=1;
cursor c1 is select rowid from iem_imt_texts
 where message_id=l_seq  and message_type=2 ;
 cursor c_Weight is select keyword from iem_imt_keywords where message_id=l_message_id;
begin
-- Insert the content into IEM_IMT_TEXTS
	iem_insert_texts(p_text,p_lang,l_seq,l_status);
	l_schema:='IEM';
    if p_type=1 then
    for v1 in c1 LOOP
CTX_DOC.THEMES(l_schema||'.IEM_IMT_INDEX',
       CTX_DOC.PKENCODE(v1.rowid), l_theme_buf, full_themes => FALSE);
	  END LOOP;
		IF l_theme_buf.count>0 THEN
		for i in l_theme_buf.first..l_theme_buf.last LOOP
			xbuf(i).keyword:=l_theme_buf(i).theme;
			xbuf(i).weight:=l_theme_buf(i).weight;
		end loop;
		end if;
    elsif p_type=2 then
for v1 in c1 loop
CTX_DOC.TOKENS(l_schema||'.IEM_IMT_INDEX',
       CTX_DOC.PKENCODE(v1.rowid), l_token_buf);
end loop;
	IF l_token_buf.count>0 THEN
	select nvl(max(message_id),0)+1 into l_message_id from iem_imt_keywords;
			for i in l_token_buf.first..l_token_buf.last LOOP
			theme_tbl.extend;
			theme_tbl(theme_tbl.last):=l_token_buf(i).token;
			END LOOP;
     LOOP
		BEGIN
		FORALL j in l_start..theme_tbl.count
	insert into iem_imt_keywords(message_id,message_type,message_part,message_format,keyword,weight)
	values(l_message_id,1,0,2,theme_tbl(j),null);
		EXIT;
         EXCEPTION WHEN OTHERS THEN
			l_start := l_start + sql%rowcount + 1;
	    END;
     END LOOP;

		-- populate the out buffer
		theme_tbl.delete;
		open c_weight;
		LOOP
			fetch c_weight bulk collect into theme_tbl;
			exit when c_weight%notfound;
		end loop;
		close c_weight;
		l_counter:=1;
		for i in theme_tbl.first..theme_tbl.last LOOP
			xbuf(l_counter).keyword:=theme_tbl(i);
			l_counter:=l_counter+1;
          end loop;
	delete from iem_imt_keywords where message_id=l_message_id;
	END IF;
 end if;
end get_tokens;

PROCEDURE IEM_PROCESS_PARTS(p_message_id	in number,
					p_message_type in number,
					p_part_id in number,
					p_lang	in varchar2,
					x_status	out nocopy varchar2) IS
	l_status		varchar2(10);
	l_error_text	varchar2(100);
	l_count		number:=0;
	l_buf			CLOB;
	l_text			CLOB;
	l_rowid			rowid;
	l_charset			varchar2(100);
	l_msgformat		number;
	l_schema			varchar2(10);
	l_subject			iem_ms_base_headers.subject%type;
	l_blob			BLOB;
 cursor c1 is select mime_msg from iem_ms_mimemsgs where
 message_id=p_message_id;
cursor c2 is select part_type,part_id,part_charset,part_data from iem_ms_msgparts
where message_id=p_message_id
and part_id=p_part_id;
l_imt_format   varchar2(100);
l_part_id		number:=-1;

BEGIN
	l_schema:='IEM';
	IF p_lang is null then
		l_msgformat:=1;			-- Theme
	ELSE
		l_msgformat:=2;			-- Token
	END IF;
		l_imt_format:='TEXT';
	IF p_part_id is null then		-- For all parts
	-- Create an entry for all parts
	for v1 in c1 Loop
          ctx_doc.policy_filter( 'IEM_MAIL_FILTER_POLICY', v1.mime_msg, l_text, false );
		insert into iem_imt_texts
		(
		message_ID,
 		message_TYPE,
 		message_PART,
		message_format,
 		IMT_FORMAT,
 		IMT_LANG,
		message_text)
 VALUES
		(p_message_id
		,p_message_type
		,9999
		,l_msgformat
		,'TEXT'
		,p_lang
		,l_text
		);
		end loop;
ELSE
	for v2 in c2 Loop
          ctx_doc.policy_filter( 'my_policy', v2.part_data, l_text, false );
		insert into iem_imt_texts
		(
		message_ID,
 		message_TYPE,
 		message_PART,
		message_format,
 		IMT_FORMAT,
 		IMT_LANG,
		message_text)
 VALUES
		(p_message_id
		,p_message_type
		,v2.part_id
		,l_msgformat
		,l_imt_format
		,p_lang
		,l_text);
	END LOOP;
END IF;
		x_status:='S';
EXCEPTION WHEN OTHERS THEN
		x_status:='E';
END IEM_PROCESS_PARTS;
PROCEDURE RETRIEVE_DOC(p_intent_id	in varchar2,
			        x_status	out nocopy varchar2) IS
 cursor c1 is
 select keyword,weight from iem_intent_dtls where intent_id=p_intent_id
 and query_response='R';
	l_imt_string	varchar2(32767):=' ';
  l_return_status      VARCHAR2(20);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(400);
l_rows_returned cs_kb_number_tbl_type :=cs_kb_number_tbl_type();
l_next_row_pos cs_kb_number_tbl_type :=cs_kb_number_tbl_type();
l_total_row_cnt cs_kb_number_tbl_type :=cs_kb_number_tbl_type();
l_logmessage		varchar2(500);
l_level			varchar2(20):='STATEMENT';
l_app_id		number;
l_part		number;
l_flag		number:=1;
l_ret		number;
l_search		varchar2(100);
l_theme		   varchar2(200);
l_tstr		   varchar2(2000);
l_errtext		   varchar2(200);
l_score			number;
l_class          NUMBER;
l_count          NUMBER;
l_next_row_tbl	cs_kb_number_tbl_type:=cs_kb_number_tbl_type();
l_total_row_tbl	cs_kb_number_tbl_type:=cs_kb_number_tbl_type();
l_area_array    AMV_SEARCH_PVT.amv_char_varray_type:=null;
l_result_array       cs_kb_result_varray_type;
l_amv_result_array    AMV_SEARCH_PVT.amv_searchres_varray_type;
l_content_array AMV_SEARCH_PVT.amv_char_varray_type:=null;
l_param_array AMV_SEARCH_PVT.amv_searchpar_varray_type;
l_rep	cs_kb_varchar100_tbl_type ;
l_category_id	AMV_SEARCH_PVT.amv_number_varray_type:=AMV_SEARCH_PVT.amv_number_varray_type();
l_tag1		number;
l_cnt		number;
l_res1		varchar2(10);
l_res2		varchar2(10);
l_search_repos		varchar2(10);
l_days  number ;
l_user_id number ;
l_rows_req cs_kb_number_tbl_type ;
l_rows		number;
l_start_row cs_kb_number_tbl_type:=cs_kb_number_tbl_type(1,1);
l_sms_string	varchar2(255);
l_sms_count    number;
l_counter    number:=1;
l_cat_map_id	number;
l_cat_counter	number;
l_search_type		varchar2(100);
G_APP_ID		number;
l_intent_id	number;
l_number	number;
begin
	l_intent_id:=to_number(p_intent_id);
	for v1 in c1 loop
		l_imt_string:=l_imt_string||'about ('||v1.keyword||')*'||v1.weight||',';
	end loop;

	l_imt_string:=substr(l_imt_string,1,length(l_imt_string)-1);
					l_search_repos:='ALL';
		l_rows:=10;	-- Number of Document Retrieved...
	l_rows_req :=cs_kb_number_tbl_type(l_rows,l_rows);
	G_APP_ID:=520;
 l_area_array := AMV_SEARCH_PVT.amv_char_varray_type();
 l_area_array.extend;
l_area_array(1) := 'ITEM';
l_content_array := AMV_SEARCH_PVT.amv_char_varray_type();
l_content_array.extend;
l_content_array(1) := 'CONTENT';
l_content_array.extend;
 l_param_array := AMV_SEARCH_PVT.amv_searchpar_varray_type();
		l_rep	:=cs_kb_varchar100_tbl_type() ;
		l_rep	:=cs_kb_varchar100_tbl_type('MES') ;
  cs_knowledge_grp.Specific_Search(
      p_api_version => 1.0,
      p_init_msg_list => fnd_api.g_true,
      --p_validation_level => p_validation_level,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      p_repository_tbl => l_rep,
      p_search_string => l_imt_string,
      p_updated_in_days => l_days,
      p_check_login_user => FND_API.G_FALSE,
      p_application_id => G_APP_ID,
        p_area_array => l_area_array,
        p_content_array => l_content_array,
        p_param_array => l_param_array,
        p_user_id => l_user_id,
        p_category_id => l_category_id,
        p_include_subcats   => FND_API.G_FALSE,
        p_external_contents => FND_API.G_TRUE,
      p_rows_requested_tbl => l_rows_req,
      p_start_row_pos_tbl  => l_start_row,
      p_get_total_cnt_flag => 'T',
      x_rows_returned_tbl => l_rows_returned,
      x_next_row_pos_tbl => l_next_row_pos,
      x_total_row_cnt_tbl => l_total_row_cnt,
      x_result_array  => l_result_array);

-- Insert The Data into IEM_INTENT_DOCUMENTS
	delete from iem_intent_documents where intent_id=l_intent_id;
	if l_result_array.count>0 then
		FOR l_count IN 1..l_result_array.count LOOP
	insert into iem_intent_documents
	(intent_id,
	docname,
	repos_id,
	doc_id,
	url_string,
	score)
	values
	(l_intent_id,
	l_result_array(l_count).title,
	1,							-- 1 for MES and 2 for SMS
	l_result_array(l_count).id,
	l_result_array(l_count).url_string,
	l_result_array(l_count).score);
	END LOOP;
	end if;

		l_rep	:=cs_kb_varchar100_tbl_type('SMS') ;
  IF length(l_imt_string)>255 THEN
		l_sms_string:=substr(l_imt_string,1,255);
		l_sms_count:=instr(l_sms_string,',about',-1,1);
		l_imt_string:=substr(l_sms_string,1,l_sms_count-1);
  END IF;
  cs_knowledge_grp.Specific_Search(
      p_api_version => 1.0,
      p_init_msg_list => fnd_api.g_true,
      --p_validation_level => p_validation_level,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data,
      p_repository_tbl => l_rep,
      p_search_string => l_imt_string,
      p_updated_in_days => l_days,
      p_check_login_user => FND_API.G_FALSE,
      p_application_id => G_APP_ID,
        p_area_array => l_area_array,
        p_content_array => l_content_array,
        p_param_array => l_param_array,
        p_user_id => l_user_id,
        p_category_id => l_category_id,
        p_include_subcats   => FND_API.G_TRUE,
        p_external_contents => FND_API.G_TRUE,
      p_rows_requested_tbl => l_rows_req,
      p_start_row_pos_tbl  => l_start_row,
      p_get_total_cnt_flag => 'T',
      x_rows_returned_tbl => l_rows_returned,
      x_next_row_pos_tbl => l_next_row_pos,
      x_total_row_cnt_tbl => l_total_row_cnt,
      x_result_array  => l_result_array);
	if l_result_array.count>0 then
		FOR l_count IN 1..l_result_array.count LOOP
--select set_number into l_number
--from CS_KB_SETS_B where set_id=l_result_array(l_count).id;
	insert into iem_intent_documents
	(intent_id,
	docname,
	repos_id,
	doc_id,
	url_string,
	score)
	values
	(l_intent_id,
	l_result_array(l_count).title,
	2,							-- 1 for MES and 2 for SMS
	l_result_array(l_count).document_number,
--	l_number,
	l_result_array(l_count).url_string,
	l_result_array(l_count).score);
	END LOOP;
	end if;
	commit;
end RETRIEVE_DOC ;
PROCEDURE RETRIEVE_TEXT(p_message_id	in number,
				    x_text	OUT NOCOPY varchar2,
			         x_status	out nocopy varchar2)  IS
l_data	clob;
l_text	varchar2(32767):=' ';
l_text1	varchar2(32767):=' ';
cursor c1 is select value,type from iem_ms_msgbodys
where message_id=p_message_id
order by order_id;
l_html_flag	number;
l_index		number;
begin
 dbms_lob.createtemporary(l_data, TRUE);
l_html_flag:=0;		-- Plain Text
for v1 in c1 loop
l_text:=l_text||ltrim(v1.value,' ');
if v1.type like '%html%' then
	l_html_flag:=1;
end if;
exit when length(l_text)>=2000;
end loop;
l_text:=substr(l_text,1,2000);
if l_html_flag=1 then
	ctx_doc.policy_filter('IEM_HTML_EXTRACT_POLICY',l_text,l_data,TRUE,null,null,null);
	l_text:=dbms_lob.substr(l_data,dbms_lob.getlength(l_data),1);
	x_text:=ltrim(ltrim(l_text),fnd_global.local_chr(10));
else
 x_text:=ltrim(l_text,' ');		--Return the plain text as is.
end if;
dbms_lob.freetemporary(l_data);
x_status:='S';
exception when others then
x_status:='E';
end RETRIEVE_TEXT;
end IEM_TEXT_PVT ;

/
