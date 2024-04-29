--------------------------------------------------------
--  DDL for Package Body OKC_ARTICLE_KEYWORD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ARTICLE_KEYWORD_PVT" as
-- $Header: OKCVAKWB.pls 120.6.12010000.3 2009/05/22 07:05:28 harchand ship $

retcode_success   constant varchar2(1) := '0';
retcode_warning   constant varchar2(1) := '1';
retcode_error     constant varchar2(1) := '2';

starting constant number := 0;
finish   constant number := 1;

rindex   BINARY_INTEGER;
slno     BINARY_INTEGER;

index_parallel NUMBER; -- Bug# 7508004

function l_debug return varchar2
is
begin
   return nvl(fnd_profile.value('AFLOG_ENABLED'),'N');
end;

--
-- our concurrent programs:
--
-- OKCARTCRTCTX
-- OKCARTSYNCCTX
-- OKCARTOPTCTX
--
function request_id(prog_name varchar2)
return fnd_concurrent_requests.request_id%type
is
   result fnd_concurrent_requests.request_id%type;
begin
   select request_id into result
   from fnd_concurrent_requests
   where concurrent_program_id in (
      select concurrent_program_id
      from fnd_concurrent_programs
      where concurrent_program_name = prog_name
   )
   and phase_code = 'R';
   return result;
exception when others then
   return 0;
end;

procedure sync is
begin
   ad_ctx_ddl.set_effective_schema('okc');
   ad_ctx_ddl.sync_index('okc_articles_ctx');
exception when others then raise;
end;

procedure optimize is
begin
   ad_ctx_ddl.set_effective_schema('okc');
   ad_ctx_ddl.optimize_index (
      idx_name => 'okc_articles_ctx',
      optlevel => ad_ctx_ddl.optlevel_full,
      maxtime  => ad_ctx_ddl.maxtime_unlimited
  );
exception when others then raise;
end;

function article_title(p_article_version_id in number) return varchar2
as
l_art_title okc_articles_all.article_title%type;
begin
	select article_title into l_art_title
	from okc_articles_all a, okc_article_versions v
	where a.article_id = v.article_id
   and article_version_id = p_article_version_id;
	return l_art_title;
exception when others then
	return null;
end;

function check_pending_rows(start_finish number) return number
as
   counter number;
   cursor pending_rows IS
      select
         to_char(pnd_timestamp,'DD-Mon-YYYY HH24:MI:SS') time,
         a.article_id art_id,
         article_version_id ver_id,
         org_id,
         v.article_language lang
      from
         ctxsys.ctx_pending p,
         okc_article_versions v,
         okc_articles_all a
      where pnd_index_name = 'OKC_ARTICLES_CTX'
      and a.article_id = v.article_id
      and v.rowid = pnd_rowid;
begin
   counter := 0;
   if start_finish not in (starting, finish) then
      return counter;
   end if;
   begin
      if start_finish = starting then
         fnd_file.put_line(fnd_file.log, 'Pending rows before synchronization:');
      elsif start_finish = finish then
         fnd_file.put_line(fnd_file.log, 'Pending rows after synchronization:');
      end if;
      for pending in pending_rows
      loop
         counter := counter + 1;
         fnd_file.put_line(fnd_file.log,  ' row# '||  counter  ||
                                          ' time= '|| pending.time   ||
                                          ' article_id= '|| pending.art_id ||
                                          ' article_version_id= '||  pending.ver_id ||
                                          ' org_id= '||  pending.org_id ||
                                          ' language= '||   pending.lang);
      end loop;
   exception when others then
	   counter := 0;
   end;
   if start_finish = starting then
      fnd_file.put_line(fnd_file.log, ' '|| counter ||' rows in pending state and should be synchronized');
   elsif start_finish = finish then
      fnd_file.put_line(fnd_file.log, ' '|| counter ||' rows in pending state after synchronization');
   end if;
   return counter;
end;

procedure sync_ctx(errbuf out nocopy varchar2, retcode out nocopy varchar2)
as
   counter number;
   request_id fnd_concurrent_requests.request_id%type;
begin
   rindex := dbms_application_info.set_session_longops_nohint;
   request_id := okc_article_keyword_pvt.request_id('OKCARTSYNCCTX');
   dbms_application_info.set_session_longops(rindex, slno,
   'Synchronize Clause Text Index', request_id, 0, 0, 1,
   'OKCARTSYNCCTX concurrent program', 'steps');

--Modified for performance bug 6943402. Removing counter since its taking long time to fetch the value of counter.
   IF nvl(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N') = 'Y' THEN
        counter := check_pending_rows(starting);
   END IF;


--   if counter > 0 then
      fnd_file.put_line(fnd_file.log, 'Start synchronization ...');
      sync;
      fnd_file.put_line(fnd_file.log, 'Synchronization complete');

    IF FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
      counter := check_pending_rows(finish);
    END IF;

      dbms_application_info.set_session_longops( rindex, slno, null, request_id, 0, 1, 1);
/*   else
      fnd_file.put_line(fnd_file.log, 'Skipped synchronization (no pending rows)');

      dbms_application_info.set_session_longops( rindex, slno, null, request_id, 0, 0, 1);
   end if;*/


   errbuf := 'OKC_ARTICLES_CTX text index has been synchronized successfully';
   retcode := retcode_success;
exception when others then
   retcode := retcode_error;
   errbuf := substr(sqlerrm,1,200);
   fnd_file.put_line(fnd_file.log, sqlerrm);
end;

procedure optimize_ctx(errbuf out nocopy varchar2, retcode out nocopy varchar2)
as
   request_id fnd_concurrent_requests.request_id%type;
begin
   rindex := dbms_application_info.set_session_longops_nohint;
   request_id := okc_article_keyword_pvt.request_id('OKCARTOPTCTX');
   dbms_application_info.set_session_longops(rindex, slno,
   'Optimize Clause Text Index', request_id, 0, 0, 2,
   'OKCARTOPTCTX concurrent program', 'steps');

   begin
      sync;
      retcode := retcode_success;
      errbuf := 'OKC_ARTICLES_CTX text index has been synchronized successfully';
   exception when others then
      retcode := retcode_error;
      errbuf := substr(sqlerrm,1,200);
      fnd_file.put_line(fnd_file.log, sqlerrm);
   end;

   if retcode <> retcode_success then
      fnd_file.put_line(fnd_file.log, 'ERROR: Synchronization failed (have to skip optimization)');
      dbms_application_info.set_session_longops( rindex, slno, null, request_id, 0, 0, 2);
      return;
   end if;

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, 0, 1, 2);
   fnd_file.put_line(fnd_file.log, 'Start optimization ...');
   optimize;

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, 0, 2, 2);
   fnd_file.put_line(fnd_file.log, 'Optimization complete');
   errbuf := 'OKC_ARTICLES_CTX text index has been optimized successfully';
   retcode := retcode_success;
exception when others then
   retcode := retcode_error;
   errbuf := substr(sqlerrm,1,200);
   fnd_file.put_line(fnd_file.log, sqlerrm);
end;

procedure create_ctx(errbuf out nocopy varchar2, retcode out nocopy varchar2,p_index_parallel number)
is
   request_id fnd_concurrent_requests.request_id%type;
begin
   rindex := dbms_application_info.set_session_longops_nohint;
   request_id := okc_article_keyword_pvt.request_id('OKCARTCRTCTX');
   dbms_application_info.set_session_longops(rindex, slno,
   'Create Clause Text Index', request_id, request_id, 0, 18,
   'OKCARTCRTCTX concurrent program', 'steps');

   retcode := retcode_success;
   errbuf := 'OKC_ARTICLES_CTX text index has been created successfully';
   index_parallel:=p_index_parallel;                                         --Bug# 7508004
   fnd_file.put_line(fnd_file.log,'index_parallel '||index_parallel);        --Bug# 7508004
   crt;
exception when others then
   retcode := retcode_error;
   errbuf := 'ERROR: Couldn''t create OKC_ARTICLES_CTX text index';
end;

procedure crt is
   apps  sys.dba_objects.owner%type;
   okc   sys.dba_objects.owner%type;
   cmd   varchar2(4000);

   generic  exception;

   request_id fnd_concurrent_requests.request_id%type;
begin
   request_id := okc_article_keyword_pvt.request_id('OKCARTCRTCTX');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_CTX text index creation started');

begin
   fnd_file.put_line(fnd_file.log,'Checking OKC_ARTICLE_KEYWORD_PVT package ...');
   select owner into apps
   from sys.dba_objects
   where object_name = 'OKC_ARTICLE_KEYWORD_PVT'
   and object_type = 'PACKAGE';
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLE_KEYWORD_PVT package exists');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLE_KEYWORD_PVT package owner is '||apps);

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 1, 18);

exception when others then
   fnd_file.put_line(fnd_file.log,'ERROR: OKC_ARTICLE_KEYWORD_PVT package doesn''t exist');
   raise generic;
end;

begin
   fnd_file.put_line(fnd_file.log,'Checking OKC_ARTICLES_ALL table ...');
   select owner into okc
   from sys.dba_tables
   where table_name = 'OKC_ARTICLES_ALL';
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_ALL table exists');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_ALL table owner is '||okc);

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 2, 18);

exception when others then
   fnd_file.put_line(fnd_file.log,'ERROR: OKC_ARTICLES_ALL table doesn''t exist');
   raise generic;
end;

begin
   execute immediate 'grant execute on '||apps||'.OKC_ARTICLE_KEYWORD_PVT to '||okc;
   fnd_file.put_line(fnd_file.log,'Granted execute on '||apps||'.OKC_ARTICLE_KEYWORD_PVT to '||okc);

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 3, 18);

exception when others then
   fnd_file.put_line(fnd_file.log,'ERROR: Couldn''t grant execute on '||apps||'.OKC_ARTICLE_KEYWORD_PVT to '||okc);
   raise generic;
end;

-- ===================================================================
-- Create context index preferences
-- ===================================================================
-- context index searches through columns:
--    article_title
--    display_name
--    article_description
--    article_text
--    additional_instructions
-- -------------------------------------------------------------------
-- Create datastore okc_articles_datastore
-- -------------------------------------------------------------------
begin
-- DATASTORE
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_DATASTORE preference creation ...');
begin
   ad_ctx_ddl.drop_preference('okc_articles_datastore');
   fnd_file.put_line(fnd_file.log,'Re-creating old OKC_ARTICLES_DATASTORE preference');
exception when others then
   fnd_file.put_line(fnd_file.log,'Creating new OKC_ARTICLES_DATASTORE preference');
end;
   ad_ctx_ddl.create_preference('okc_articles_datastore','multi_column_datastore');
   ad_ctx_ddl.set_attribute('okc_articles_datastore','columns',
      apps||'.okc_article_keyword_pvt.article_title(article_version_id) art_title,
      display_name art_disp, article_description art_descr, article_text art_text, additional_instructions art_instr');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_DATASTORE preference has been created successfully as MULTI_COLUMN_DATASTORE');

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 4, 18);

end;

-- -------------------------------------------------------------------
-- Create section group okc_article_sections
-- -------------------------------------------------------------------
begin
-- SECTION GROUP
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLE_SECTIONS section group creation ...');
begin
   ad_ctx_ddl.drop_section_group('okc_article_sections');
   fnd_file.put_line(fnd_file.log,'Re-creating old OKC_ARTICLE_SECTIONS section group');
exception when others then
   fnd_file.put_line(fnd_file.log,'Creating new OKC_ARTICLE_SECTIONS section group');
end;
   ad_ctx_ddl.create_section_group('okc_article_sections', 'BASIC_SECTION_GROUP');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLE_SECTIONS: add field section Title');
   ad_ctx_ddl.add_field_section('okc_article_sections', 'Title', '<ART_TITLE>', true);
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLE_SECTIONS: add field section Display');
   ad_ctx_ddl.add_field_section('okc_article_sections', 'Display', '<ART_DISP>', true);
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLE_SECTIONS: add field section Description');
   ad_ctx_ddl.add_field_section('okc_article_sections', 'Description', '<ART_DESCR>', true);
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLE_SECTIONS: add field section Instruction');
   ad_ctx_ddl.add_field_section('okc_article_sections', 'Instruction', '<ART_INSTR>', true);
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLE_SECTIONS: add field section Text');
   ad_ctx_ddl.add_field_section('okc_article_sections', 'Text', '<ART_TEXT>', true);
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLE_SECTIONS section group has been created successfully as BASIC_SECTION_GROUP');

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 5, 18);

end;

-- -------------------------------------------------------------------
-- Create lexer okc_articles_lexer
-- -------------------------------------------------------------------
begin
-- LEXER
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_LEXER preference creation ...');
begin
   ad_ctx_ddl.drop_preference('okc_articles_lexer');
   fnd_file.put_line(fnd_file.log,'Re-creating old OKC_ARTICLES_LEXER preference');
exception when others then
   fnd_file.put_line(fnd_file.log,'Creating new OKC_ARTICLES_LEXER preference');
end;
   ad_ctx_ddl.create_preference('okc_articles_lexer','multi_lexer');
begin
   ad_ctx_ddl.drop_preference('okc_blexer');
   fnd_file.put_line(fnd_file.log,'Re-creating old OKC_BLEXER preference');
exception when others then
   fnd_file.put_line(fnd_file.log,'Creating new OKC_BLEXER preference');
end;
   ad_ctx_ddl.create_preference('okc_blexer','basic_lexer');
   fnd_file.put_line(fnd_file.log,'OKC_BLEXER: set attribute index_themes=false');
   ad_ctx_ddl.set_attribute('okc_blexer','index_themes','false');
   fnd_file.put_line(fnd_file.log,'OKC_BLEXER: set attribute index_text=true');
   ad_ctx_ddl.set_attribute('okc_blexer','index_text','true');
   fnd_file.put_line(fnd_file.log,'OKC_BLEXER: set attribute base_letter=true');
   ad_ctx_ddl.set_attribute('okc_blexer','base_letter','true');
   fnd_file.put_line(fnd_file.log,'OKC_BLEXER: set attribute mixed_case=false');
   ad_ctx_ddl.set_attribute('okc_blexer','mixed_case','false');
   fnd_file.put_line(fnd_file.log,'OKC_BLEXER preference has been created as BASIC_LEXER');

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 6, 18);

-- Chinese lexer
begin
   ad_ctx_ddl.drop_preference('okc_clexer');
   fnd_file.put_line(fnd_file.log,'Re-creating old OKC_CLEXER preference');
exception when others then
   fnd_file.put_line(fnd_file.log,'Creating new OKC_CLEXER preference');
end;

declare
   yes_no varchar2(1);
begin
   begin
      select 'Y' into yes_no
      from ctx_objects
      where obj_class = 'LEXER'
      and obj_name = 'CHINESE_LEXER';
   exception when others then
      yes_no := 'N';
   end;
   if yes_no = 'Y' then
      ad_ctx_ddl.create_preference('okc_clexer','chinese_lexer');
      fnd_file.put_line(fnd_file.log,'OKC_CLEXER preference has been created as CHINESE_LEXER');
   else
      ad_ctx_ddl.create_preference('okc_clexer','chinese_vgram_lexer');
      fnd_file.put_line(fnd_file.log,'OKC_CLEXER preference has been created as CHINESE_VGRAM_LEXER');
   end if;

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 7, 18);

end;

-- Japanese lexer
begin
   ad_ctx_ddl.drop_preference('okc_jlexer');
   fnd_file.put_line(fnd_file.log,'Re-creating old OKC_JLEXER preference');
exception
when others then
   fnd_file.put_line(fnd_file.log,'Creating new OKC_JLEXER preference');
end;

declare
   yes_no varchar2(1);
begin
   begin
      select 'Y' into yes_no
      from ctx_objects
      where obj_class = 'LEXER'
      and obj_name = 'JAPANESE_LEXER';
   exception
   when others then
      yes_no := 'N';
   end;
   if yes_no = 'Y' then
      ad_ctx_ddl.create_preference('okc_jlexer','japanese_lexer');
      fnd_file.put_line(fnd_file.log,'OKC_JLEXER preference has been created as JAPANESE_LEXER');
   else
      ad_ctx_ddl.create_preference('okc_jlexer','japanese_vgram_lexer');
      fnd_file.put_line(fnd_file.log,'OKC_JLEXER preference has been created as JAPANESE_VGRAM_LEXER');
   end if;

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 8, 18);

end;

-- Korean lexer
begin
   ad_ctx_ddl.drop_preference('okc_klexer');
   fnd_file.put_line(fnd_file.log,'Re-creating old OKC_KLEXER preference');
exception when others then
   fnd_file.put_line(fnd_file.log,'Creating new OKC_KLEXER preference');
end;

declare
   yes_no varchar2(1);
begin
   begin
      select 'Y' into yes_no
      from ctx_objects
      where obj_class = 'LEXER'
      and obj_name = 'KOREAN_MORPH_LEXER';
   exception when others then
      yes_no := 'N';
   end;
   if yes_no = 'Y' then
      ad_ctx_ddl.create_preference('okc_klexer', 'korean_morph_lexer');
      fnd_file.put_line(fnd_file.log,'OKC_KLEXER preference has been created as KOREAN_MORPH_LEXER');
   else
      ad_ctx_ddl.create_preference('okc_klexer', 'korean_lexer');
      fnd_file.put_line(fnd_file.log,'OKC_KLEXER preference has been created as KOREAN_LEXER');
   end if;
   fnd_file.put_line(fnd_file.log,'OKC_KLEXER: set attribute one_char_word=true');
   ad_ctx_ddl.set_attribute('okc_klexer', 'one_char_word', 'true');
   fnd_file.put_line(fnd_file.log,'OKC_KLEXER: set attribute number=true');
   ad_ctx_ddl.set_attribute('okc_klexer', 'number', 'true');

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 9, 18);

end;

-- sublexers
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_LEXER: add sublexer default=okc_blexer');
   ad_ctx_ddl.add_sub_lexer('okc_articles_lexer','default','okc_blexer');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_LEXER: add sublexer ja=okc_jlexer');
   ad_ctx_ddl.add_sub_lexer('okc_articles_lexer','ja','okc_jlexer');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_LEXER: add sublexer ko=okc_klexer');
   ad_ctx_ddl.add_sub_lexer('okc_articles_lexer','ko','okc_klexer');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_LEXER: add sublexer zhs=okc_clexer');
   ad_ctx_ddl.add_sub_lexer('okc_articles_lexer','zhs','okc_clexer');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_LEXER: add sublexer zht=okc_clexer');
   ad_ctx_ddl.add_sub_lexer('okc_articles_lexer','zht','okc_clexer');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_LEXER preference has been created as MULTI_LEXER');

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 10, 18);

end;

-- -------------------------------------------------------------------
-- Create stoplist okc_articles_stoplist
-- -------------------------------------------------------------------
begin
-- STOPLIST
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_STOPLIST preference creation ...');
   ad_ctx_ddl.create_stoplist ('okc_articles_stoplist', 'multi_stoplist');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_STOPLIST preference has been created as MULTI_STOPLIST');
exception when others then
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_STOPLIST preference already exists');
end;

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 11, 18);

-- -------------------------------------------------------------------
-- Create wordlist okc_articles_wordlist
-- -------------------------------------------------------------------
begin
-- WORDLIST
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_WORDLIST preference creation ...');
begin
   ad_ctx_ddl.drop_preference('okc_articles_wordlist');
   fnd_file.put_line(fnd_file.log,'Re-creating old OKC_ARTICLES_WORDLIST preference');
exception when others then
   fnd_file.put_line(fnd_file.log,'Creating new OKC_ARTICLES_WORDLIST preference');
end;
   ad_ctx_ddl.create_preference('okc_articles_wordlist','basic_wordlist');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_WORDLIST: set attribute stemmer=auto');
   ad_ctx_ddl.set_attribute('okc_articles_wordlist','stemmer','auto');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_WORDLIST: set attribute fuzzy_match=auto');
   ad_ctx_ddl.set_attribute('okc_articles_wordlist','fuzzy_match','auto');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_WORDLIST: set attribute prefix_index=true');
   ad_ctx_ddl.set_attribute('okc_articles_wordlist','prefix_index','true');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_WORDLIST: set attribute prefix_min_length=3');
   ad_ctx_ddl.set_attribute('okc_articles_wordlist','prefix_min_length',3);
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_WORDLIST: set attribute prefix_max_length=5');
   ad_ctx_ddl.set_attribute('okc_articles_wordlist','prefix_max_length',5);
--   ad_ctx_ddl.set_attribute('okc_articles_wordlist','fuzzy_score',60);
--   ad_ctx_ddl.set_attribute('okc_articles_wordlist','fuzzy_numresults',100);
--   ad_ctx_ddl.set_attribute('okc_articles_wordlist','substring_index','true');
   fnd_file.put_line(fnd_file.log,'OKC_ARTICLES_WORDLIST preference has been created as BASIC_WORDLIST');

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 12, 18);

end;

-- -------------------------------------------------------------------
-- Drop context index okc_articles_ctx (if exists)
-- -------------------------------------------------------------------
begin
   fnd_file.put_line(fnd_file.log, okc||'.OKC_ARTICLES_CTX text index creation:');
   execute immediate 'drop index '||okc||'.okc_articles_ctx force';
exception when others then
   null;
end;

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 13, 18);

   fnd_file.put_line(fnd_file.log, 'Generating '||okc||'.OKC_ARTICLES_CTX text index creation DDL ...');
-- -------------------------------------------------------------------
-- Create context index okc_articles_ctx
-- -------------------------------------------------------------------
declare
   max_memory    number;
   cpu_count     number;
   db_version    number;
   sync  varchar2(18);
begin
   max_memory := 0;
   cpu_count := 0;
   db_version := 0;
--   sync := ' sync (on commit) ';
   sync := '';
begin
   select par_value into max_memory
   from ctx_parameters
   where par_name = 'MAX_INDEX_MEMORY';
   fnd_file.put_line(fnd_file.log,'max_memory='||max_memory);
exception when others then
   null;
end;

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 14, 18);

begin
   select value into cpu_count
   from v$parameter
   where name = 'cpu_count';
   fnd_file.put_line(fnd_file.log,'cpu_count='||cpu_count);
exception when others then
   null;
end;

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 15, 18);

begin
   select to_number(substr(version,0,2)) into db_version
   from v$instance;
   fnd_file.put_line(fnd_file.log,'db_version='||db_version);
exception
when others then
   null;
end;

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 16, 18);

   max_memory := round(max_memory/2);
   cpu_count := round(cpu_count/2);
-- Bug# 7508004
   if index_parallel = -1 then
      index_parallel:= cpu_count;
      fnd_file.put_line(fnd_file.log,'index_parallel2 '||index_parallel);
   end if;

   if db_version < 10 then sync := ' '; end if;
   cmd :=
   'create index '||okc||'.okc_articles_ctx on okc_article_versions(article_text)
    indextype is ctxsys.context
    parameters ('''||sync||'
      memory '||max_memory||'
      datastore '||apps||'.okc_articles_datastore
      filter ctxsys.null_filter
      lexer	'||apps||'.okc_articles_lexer language column article_language
      section group '||apps||'.okc_article_sections
      stoplist	'||apps||'.okc_articles_stoplist
      wordlist	'||apps||'.okc_articles_wordlist'') parallel '||index_parallel;
   fnd_file.put_line(fnd_file.log, 'Executing '||okc||'.OKC_ARTICLES_CTX text index creation DDL ...');
   fnd_file.put_line(fnd_file.log, cmd);

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 17, 18);

   execute immediate cmd;

   dbms_application_info.set_session_longops( rindex, slno, null, request_id, request_id, 18, 18);

   fnd_file.put_line(fnd_file.log, okc||'.OKC_ARTICLES_CTX text index has been created successfully');
exception when others then
   fnd_file.put_line(fnd_file.log, 'ERROR: Couldn''t create '||okc||'.OKC_ARTICLES_CTX text index');
   begin
      execute immediate 'drop index '||okc||'.okc_articles_ctx force';
   exception when others then
      null;
   end;
   fnd_file.put_line(fnd_file.log, cmd);
   raise generic;
end;

end;

end;

/

  GRANT EXECUTE ON "APPS"."OKC_ARTICLE_KEYWORD_PVT" TO "OKC";
