--------------------------------------------------------
--  DDL for Package Body FND_HELP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_HELP" as
/* $Header: AFMLHLPB.pls 120.3.12010000.2 2010/02/10 07:13:19 nchiring ship $ */

-----------------------------------------------------------------------------
-- GetLangCode (PRIVATE)
--   Parse the langpath and return the language code (ie "US")
-----------------------------------------------------------------------------
function GetLangCode(
  langpath in varchar2)
return varchar2
is
  delim     number;
  langcode  varchar2(4);
begin
  delim := instr(langpath, '@');
  if (delim = 0) then
    langcode := upper(langpath);   -- no localization code tacked on
  else
    langcode := upper(substr(langpath, 1, delim-1));
  end if;
  return(langcode);
end;

-----------------------------------------------------------------------------
-- GetLocalizationCode (PRIVATE)
--   Parse the langpath and return the localization code (ie "@UK")
-----------------------------------------------------------------------------
function GetLocalizationCode(
  langpath in varchar2)
return varchar2
is
  delim  number;
  hlc    varchar2(100);
begin
  delim := instr(langpath, '@');
  if (delim = 0) then
    hlc := '';
  else
    hlc := upper(substr(langpath, delim));
  end if;
  return(hlc);
end;

-----------------------------------------------------------------------------
-- Get_As_File (PRIVATE)
--   Look up document via filename
-----------------------------------------------------------------------------
function Get_As_File(
  file      in varchar2,
  app       in varchar2,
  langpath  in varchar2,
  file_id  out nocopy varchar2)
return boolean
is
  hlc           varchar2(100);
  langcode      varchar2(4);
  results_head  varchar2(100);
  found         boolean := FALSE;
  fid           number;

  cursor file_languages is
    select distinct
           l.description    longlang,
           hd.language      lang,
           hd.title         title,
           hd.file_name     fn
    from   fnd_help_documents hd,
           fnd_languages_vl   l
    where  hd.file_name    = file
    and    hd.application  = app
    and    l.language_code = hd.language
    order by l.description;

begin
  hlc := GetLocalizationCode(langpath);
  langcode := GetLangCode(langpath);

  -------------------------------------
  -- First, look in current language --
  -------------------------------------
  begin
    select hd.file_id into fid
    from   fnd_help_documents hd
    where  hd.application  = app
    and    hd.file_name    = file
    and    hd.language     = langcode
    and    rownum=1
    and    hd.custom_level =
	  (select max(hd2.custom_level)
	   from   fnd_help_documents hd2
	   where  hd2.file_name   = hd.file_name
	   and    hd2.language    = hd.language
  	   and    hd2.application = hd.application);

    file_id := fid;
    return TRUE;

  exception
    when no_data_found then
      null;
    when others then
      return FALSE;
  end;

  ----------------------------------------------------------
  -- If the file is a .GIF file, it may not be translated --
  -- For this special case (bug 1762401) we'll look in US --
  ----------------------------------------------------------
  if (langcode <> 'US' AND substr(file, -3) = 'GIF') then
    begin
      select hd.file_id into fid
      from   fnd_help_documents hd
      where  hd.application  = app
      and    hd.file_name    = file
      and    hd.language     = 'US'
      and    rownum=1
      and    hd.custom_level =
  	  (select max(hd2.custom_level)
  	   from   fnd_help_documents hd2
  	   where  hd2.file_name   = hd.file_name
  	   and    hd2.language    = hd.language
    	   and    hd2.application = hd.application);

      file_id := fid;
      return TRUE;

    exception
      when no_data_found then
        null;
      when others then
        return FALSE;
    end;
  end if;
return FALSE;
exception
  when others then
  return FALSE;
end;

-----------------------------------------------------------------------------
-- Get_As_Target (PRIVATE)
--   Look up document via target
-----------------------------------------------------------------------------
function Get_As_Target(
  target    in varchar2,
  app       in varchar2,
  langpath  in varchar2,
  file_id   out nocopy  varchar2)
return boolean
is
  results_head  varchar2(100);
  found         boolean := FALSE;
  hlc           varchar2(100);
  langcode      varchar2(4) := GetLangCode(langpath);
  fid           number;

  cursor target_languages is
    select distinct
           l.description   longlang,
           hd.language     lang,
           hd.title        title,
           hd.file_name    fn
    from   fnd_help_targets   ht,
           fnd_help_documents hd,
           fnd_languages_vl   l
    where  ht.file_id      = hd.file_id
    and    ht.target_name  = target
    and    hd.application  = app
    and    l.language_code = hd.language
    order by l.description;

  cursor current_language is
    select hd.file_id
    from   fnd_help_targets   ht,
           fnd_help_documents hd
    where  ht.file_id     = hd.file_id
    and    ht.target_name = target
    and    hd.language    = langcode
    and    hd.application = app
    and    hd.custom_level =
          (select max(hd2.custom_level)
   	   from   fnd_help_documents hd2,
                  fnd_help_targets ht2
	   where  ht2.target_name = ht.target_name
           and    ht2.file_id     = hd2.file_id
           and    hd2.language    = hd.language
	   and    hd2.application = hd.application)
    order by hd.file_id desc;

begin
  hlc := GetLocalizationCode(langpath);
  langcode := GetLangCode(langpath);

  -------------------------------------
  -- First, look in current language --
  -------------------------------------

  begin

  open current_language;
  fetch current_language into fid;
  if (current_language%notfound) then
    raise no_data_found;
  end if;
  close current_language;

   file_id := fid;
  return TRUE;

  exception
    when no_data_found then
      null;
  end;
  return FALSE;
exception
  when others then
  return FALSE;
end;

-----------------------------------------------------------------------------
-- GetHTTPLang (PRIVATE)
--   Return the lang code for HTML pages that meet ADA Standards
--   Produces the same result as the java function
--   oracle.apps.fnd.i18n.util.SSOMapper.getHttpLangFromOracle.
-----------------------------------------------------------------------------
function GetHTTPLang(
  langpath in varchar2)
return varchar2
is
  delim number;
  langcode  varchar2(4);
  httplang  varchar2(30);
begin

  delim := instr(langpath, '@');
  if (delim = 0) then
    langcode := upper(langpath);   -- no localization code tacked on
  else
    langcode := upper(substr(langpath, 1, delim-1));
  end if;

  begin
     select lower(iso_language)||'-'||iso_territory
       into httplang
     from fnd_languages where language_code = langcode;
  exception when no_data_found then
     httplang := langcode;
  end;

  return(httplang);
end;


-----------------------------------------------------------------------------
-- Get_Url
--   Creates the URL to launch the help system with help document based
--   on the specified target.
-- IN
--   appsname   - app code for the document's owning application
--   target     - name of the help target
--   helpsystem - indicates whether user wants to launch full help system
--                if FALSE, means they just want to fetch the document.
--   targettype - specifies whether the target is a help target or filename.
--                (valid values are TARGET or FILE)
-- HELPCONTEXT when false, then help root is taken for the global help content, typically
--             represented by FND:LIBRARY.
--             When true, then system displays context sensitive help content.

-----------------------------------------------------------------------------
function Get_Url(
  appsname   in varchar2,
  target     in varchar2,
  HELPSYSTEM in boolean  default TRUE,
  TARGETTYPE in varchar2 default 'TARGET',
  CONTEXTHELP in boolean  default TRUE )
return varchar2
is
  help_url varchar2(2000);
  rapp varchar2(50);
  language varchar2(50);
  ora_language varchar2(50);
  ora_territory varchar2(50);
  hlc varchar2(100);
  ind varchar2(2) := '';
  help_target varchar2(512);
  delim number;
  helpAgent varchar2(2000);
  paramChar varchar2(1);
  rootVal varchar2(512);
begin

  delim := instr(target,'#');

  if (delim = 0) then
    help_target := target;
  else
    help_target := substr(target,1,delim-1) || '%23' || substr(target,delim+1);
  end if;

 helpAgent := fnd_profile.value('HELP_WEB_AGENT');
  if(helpAgent is null) then
      help_url := fnd_profile.value('APPS_SERVLET_AGENT');

      if (help_url is null) then
         return(null);
      end if;

      if ( length(help_url) <> instr(help_url,'/',-1) )then
         help_url := help_url || '/';
      end if;

      help_url:= help_url||'help';
  else
      help_url := helpAgent;
  end if;

  paramChar := '?';

  hlc := fnd_profile.value('HELP_LOCALIZATION_CODE');
  if (hlc is not null) then
    hlc := '@'||hlc;
  end if;

  if (targettype = 'TARGET') then
    ind := '@';
  end if;

  ------------------------------------------------------------
  -- There is a legacy historical mapping between different --
  -- applications because some share help bases with others --
  ------------------------------------------------------------
  rapp := upper(appsname);
  if (rapp in ('SQLGL', 'RG')) then
     rapp := 'GL';
  -- Bug3770297 Added products PQP,PQH,SSP,HRI
  elsif (rapp in ('DT', 'FF', 'PAY', 'BEN', 'GHR', 'HR','PQP','PQH','SSP','HRI')) then
     rapp := 'PER';
  elsif (rapp = 'SQLAP') then
     rapp := 'AP';
  elsif (rapp = 'OFA')then
     rapp := 'FA';
  elsif (rapp = 'CST')then
     rapp := 'BOM';
  end if;

  select userenv('language')
    into language
    from dual;

language := substr(language,1,instr(language,'.') - 1);
ora_language := substr(language, 1,instr(language,'_')-1);
ora_territory := substr(language,instr(language,'_')+1);

if(CONTEXTHELP) then
  	  rootVal := fnd_profile.value('HELP_TREE_ROOT');
else
 	  rootVal := fnd_profile.VALUE_SPECIFIC('HELP_TREE_ROOT', -1, -1, -1, -1, -1);
end if;

 return help_url || paramChar ||
      'locale='||UTL_I18N.MAP_LOCALE_TO_ISO(ora_language,ora_territory)||
      '&'||'group='||rootVal||':'||fnd_global.current_language||      '&'||'topic='||fnd_global.current_language||hlc||'/'||
      rapp||'/'||ind||help_target;

end Get_Url;

-----------------------------------------------------------------------------
-- Get
--   Get GFM identifier for help target
-- IN
--   path - Relative path of target, in the format:
--          /<lang>/<app>/<file>
--	    /<lang>/<app>/@<[app:]target>[,[app:]target,[app:]target...]
--
-- RETURNS
-- returns file_id of the document
-----------------------------------------------------------------------------
function Get(
  path in varchar2,
  file_id out nocopy varchar2)
return boolean
is
  lpath      varchar2(2000);
  langpath   varchar2(105);
  langcode   varchar2(4);
  hlc        varchar2(100);
  app        varchar2(50);
  slash      number;
  delim      number;
  ok         boolean := FALSE;
  bad_req    exception;

begin
  if (path is null) then
     return false;
 end if;

  lpath := ltrim(path, '/');

  -- Extract language information --
  slash := nvl(instr(lpath, '/'), 0);
  langpath := upper(substr(lpath, 1, slash-1));
  langcode := GetLangCode(langpath);
  hlc := GetLocalizationCode(langpath);
  lpath := substr(lpath, slash+1);

  -- Extract application --
  slash := nvl(instr(lpath, '/'), 0);
  app := upper(substr(lpath, 1, slash-1));
  lpath := substr(lpath, slash+1);

  -----------------------------------------------------------------
  -- Remainder of lpath is either the target name, file name, or --
  -- list of targets.                                            --
  --                                                             --
  -- If it starts with "@", we know we are dealing with targets, --
  -- otherwise we have got a file name.                          --
  --                                                             --
  -- Furthermore, we handle lists of targets differently than    --
  -- single target names.                                        --
  -----------------------------------------------------------------
  if (substr(lpath, 1, 1) <> '@') then
    ok := Get_As_File(upper(lpath), app, langpath,file_id);
  else
    -- we have a single target --
    -- synch target translation with load_target() --
    lpath := upper(translate(substr(lpath, 2),'.','_'));

    -- append the localization code if none specified --
    if (instr(lpath, '@') = 0) then
      lpath := lpath||hlc;
    end if;

    ok := Get_As_Target(lpath, app, langpath,file_id);

    if (ok = FALSE) then
      -- remove the localization code and try again --
      delim := instr(lpath, '@');
      if (delim <> 0) then
        lpath := substr(lpath, 1, delim-1);
        ok := Get_As_Target(lpath, app, langpath,file_id);
      end if;
    end if;
  end if;

  if (ok = FALSE) then
    raise bad_req;
  end if;
return ok;
exception
  when bad_req then
    Fnd_Message.Set_Name('FND', 'HELP_BAD_TARGET');
--    Fnd_Message.Set_Token('TARGET', app||'/'||lpath);
    Fnd_Message.Set_Token('TARGET', '');  -- Bug 3391291
    return FALSE;
  when others then
    return FALSE;
end Get;

----------------------------------------------------------------------------
-- Help_Search
--   Implement search
-- IN
--   find_string - string to search for
-- IN OUT
--   results - array of links.
--
-- This procedure implements the Help Document search and can be called
-- by other folks who wish to include help documents in their own search
-- results.  Takes the search string, parses and reshapes it behave more
-- like standard browser searches, finds the matching Help Documents,
-- and returns them as an array of links to be displayed by the caller.
----------------------------------------------------------------------------
procedure Help_Search(
  find_string  in     varchar2 default null,
  scores       in out nocopy results_tab,
  apps         in out nocopy results_tab,
  titles       in out nocopy results_tab,
  file_names   in out nocopy results_tab,
  langpath     in     varchar2 default userenv('LANG'),
  appname      in     varchar2 default null,
  lang         in     varchar2 default null,
  row_limit    in     number default null)
is
  selc      varchar2(2000) := ' ';
  andc      varchar2(2000) := ' ';
  mainc     varchar2(2000);
  orderc    varchar2(100);
  pct       varchar2(4);
  title     varchar2(256);
  app       varchar2(50);
  fn	    varchar2(256);
  source    varchar2(256);
  langcode  varchar2(4);
  nlslang   varchar2(256);
  appnameClause varchar2(80);

  i      number;
  rows   number :=0;
  cur    integer;
  atg    boolean := FALSE;


begin

  if (lang is null) then
    langcode := GetLangCode(langpath);
  else
    langcode := lang;
  end if;

  if (appname is null) then
     appnameClause := '';
  else
     appnameClause := ' and hd.application = '''||appname||'''';
  end if;

  -- Set NLS_LANGUAGE if the language code doesn't match userenv('LANG').
  if (langcode <> userenv('LANG')) then
    begin
      select ''''||nls_language||'''' into nlslang from fnd_languages
        where language_code = langcode;
      exception
        when others then
          nlslang := 'AMERICAN';
    end;
    dbms_session.set_nls('NLS_LANGUAGE', nlslang);
  end if;


    mainc := '        hd.title title,                             '||
           '        hd.application app,                         '||
           '        hd.file_name fn                             '||
           ' from   fnd_lobs lob,                               '||
           '        fnd_help_documents hd                       '||
           ' where  lob.program_name = ''FND_HELP''             '||
           ' and    upper(lob.file_format) = ''TEXT''           '||
           ' and    hd.file_id = lob.file_id                    '||
           ' and    hd.language = '''||langcode||'''            '||
           appnameClause ||
           ' and    hd.file_name <> ''ATGRP.GIF''               '||
           ' and    hd.title is not null                        '||
           ' and    hd.custom_level =                           '||
           '   (select  /*+no_unnest*/ max(hd2.custom_level)    '||
           '       from   fnd_help_documents hd2                '||
           '       where  hd2.file_name = hd.file_name          '||
           '       and    hd2.language = hd.language            '||
           '       and    hd2.application = hd.application)     ';


  orderc := ' order by pct desc, title ';

  source := rtrim(find_string, ' ');
  if (source is NULL) then
     return;
  end if;

  ------------------------------------------------------------
  -- Check for special debug indicator; when TRUE, displays --
  -- generated where and select clauses                     --
  ------------------------------------------------------------

  if (instr(source, 'atgrp') = 1) then
     atg := TRUE;
  end if;

  fnd_imutl.parse_search(source, selc, andc, 'LOB.FILE_DATA');

  ------------------------------------------
  -- Build and execute dynamic SQL cursor --
  ------------------------------------------
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(cur, selc||mainc||andc||orderc, dbms_sql.v7);

  dbms_sql.define_column(cur, 1, pct,   3);
  dbms_sql.define_column(cur, 2, title, 256);
  dbms_sql.define_column(cur, 3, app,   50);
  dbms_sql.define_column(cur, 4, fn,    256);

  rows := dbms_sql.execute(cur);


  i := 1;
  while (TRUE) loop
     rows := dbms_sql.fetch_rows(cur);

  -- Bug 3315934 Added row_limit to resolve performance issues
  -- Will display all rows if no limit is specified.
     if (rows = 0 or (row_limit is not null and i > row_limit)) then
	exit;
     end if;

     dbms_sql.column_value(cur, 1, pct);
     dbms_sql.column_value(cur, 2, title);
     dbms_sql.column_value(cur, 3, app);
     dbms_sql.column_value(cur, 4, fn);

     scores(i) := pct;
     titles(i) := title;
     apps(i)   := app;
     file_names(i) := fn;

     i := i + 1;
  end loop;
  dbms_sql.close_cursor(cur);

  if (atg = TRUE) then

     scores(i) := 0;
     titles(i) := 'Suprise';
     apps(i)   := 'FND';
     file_names(i) := 'ATGRP.GIF';

  end if;
end Help_Search;

-----------------------------------------------------------------------------
-- Load_Doc
--   Load a help document into the database (called by FNDGFH and FNDGFU)
--
--   If the help document is already there, update it.
--   Otherwise, insert a new one.
-----------------------------------------------------------------------------
procedure Load_Doc (
  x_file_id	  in varchar2,
  x_language	  in varchar2,
  x_application	  in varchar2,
  x_file_name	  in varchar2,
  x_custom_level  in varchar2,
  x_title	  in varchar2,
  x_version	  in varchar2 ) is
  num_file_id      number := to_number(x_file_id);
  num_custom_level number := to_number(x_custom_level);
begin
  update fnd_help_documents set
    title   = x_title,
    version = x_version
  where file_id = num_file_id;

  if SQL%NOTFOUND then
    insert into fnd_help_documents (
      file_id,
      language,
      application,
      file_name,
      custom_level,
      title,
      version)
    values (
      num_file_id,
      upper(x_language),
      upper(x_application),
      upper(x_file_name),
      num_custom_level,
      x_title,
      x_version);
  end if;
end Load_Doc;

-----------------------------------------------------------------------------
-- load_target
--   Load a help target into the database (called by FNDGFH and FNDGFU)
--
--   x_file_id     - the file_id of the owning help document
--   x_target_name - the target to load
--
-- Warning!  We are modifying the target here. Therefore, all target
--           searches need to do the same modifications in order to
--           successfully find the target.  Search for keyword 'synch'.
-----------------------------------------------------------------------------
procedure load_target (
  x_file_id 	 in varchar2,
  x_target_name	 in varchar2 ) is
  num_file_id number := to_number(x_file_id);
begin
  insert into fnd_help_targets (file_id, target_name)
  values (num_file_id, upper(translate(x_target_name,'.','_')));

  exception
     when dup_val_on_index then
       return;
end load_target;

-----------------------------------------------------------------------------
-- cull_row
--   Cleanup obsolete rows from fnd_lobs, fnd_help_documents, and
--   fnd_help_targets (called by FNDGFH and FNDGFU)
--
--   Usual case: a new version for this file_id, language, app, file_name
--   and custom level has been created.  Therefore, it is desirable
--   to remove the obsolete records to avoid querying and storing them.
--
--   Assumption: We can delete all other versions for this record
--               because we will always be adding the newest version.
--               That is, we don't have to worry about erroneously
--               deleting a newer version.
--
--   Additionally, since there is no other way to delete obsolete targets
--   AND all targets for a document are always loaded, it is safest
--   to ALWAYS delete ALL of the targets so that we're always up-to-date.
-----------------------------------------------------------------------------
procedure cull_row (
  x_file_id 	  in varchar2,
  x_language      in varchar2,
  x_application   in varchar2,
  x_file_name 	  in varchar2,
  x_custom_level  in varchar2 )
is
  num_file_id      number := to_number(x_file_id);
  num_custom_level number := to_number(x_custom_level);
  cursor fileid_cursor is
 	 select file_id from fnd_help_documents
	 where  upper(language)    =  upper(x_language)
         and    upper(application) =  upper(x_application)
         and    upper(file_name)   =  upper(x_file_name)
         and    custom_level       =  num_custom_level
	 and    file_id            <> num_file_id;
begin
  for f in fileid_cursor loop
     delete from fnd_help_targets   where file_id = f.file_id;
     delete from fnd_lobs           where file_id = f.file_id;
     delete from fnd_help_documents where file_id = f.file_id;
  end loop;
  -----------------------------------------------
  -- Remove ALL help targets for this document --
  -----------------------------------------------
  delete from fnd_help_targets where file_id = x_file_id;
end cull_row;

-----------------------------------------------------------------------------
-- delete_doc
--   Delete a document from the iHelp system
-- IN:
--   x_application - Application shortname of file owner
--   x_file_name - Name of file to delete
--   x_language - Language to delete (null for all)
--   x_custom_level - Custom level to delete (null for all)
-----------------------------------------------------------------------------
procedure delete_doc (
  x_application   in varchar2,
  x_file_name 	  in varchar2,
  x_language      in varchar2 default null,
  x_custom_level  in varchar2 default null)
is
  num_custom_level number := to_number(x_custom_level);
  cursor fileid_cursor is
 	 select fhd.file_id
         from fnd_help_documents fhd
         where  upper(fhd.application) =  upper(x_application)
         and    upper(fhd.file_name)   =  upper(x_file_name)
	 and    upper(fhd.language)    =  upper(nvl(x_language, fhd.language))
         and    fhd.custom_level       =  nvl(num_custom_level,
                                              fhd.custom_level);
begin

  for f in fileid_cursor loop
    -- Delete all help targets
    delete from fnd_help_targets fht
    where fht.file_id = f.file_id;

    -- Help documents...
    delete from fnd_help_documents fhd
    where fhd.file_id = f.file_id;

    -- Lobs table...
    delete from fnd_lobs
    where file_id = f.file_id;

  end loop;

end delete_doc;

end fnd_help;

/
