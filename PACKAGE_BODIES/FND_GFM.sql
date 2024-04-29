--------------------------------------------------------
--  DDL for Package Body FND_GFM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_GFM" AS
/* $Header: AFGFMB.pls 120.17.12010000.26 2019/08/19 13:31:06 ctilley ship $ */

-----------------------------------------------------------------------------
--global variable to indicate wether we are are in R12 env or 11i
--in a broad way we use the 'TYPE' of function 'FND_FNDFLUPL to
--obtain the same 11i = TYPE = WWW / R12 = TYPE = JSP respectively
--setter and getter methods are used to access the same.

g_release_version number := 0;

/*--------------------------------------------------------------------------*/
/*
 * file_handle - internal file descriptor
 *   Files are referenced by a numeric file identifier, which is an index
 *   into the open_file_handles table.  Due to an odd PL/SQL API for tables,
 *   we do not actually delete old elements in the table, but simply nullify
 *   them.  Thus, on new file openings, we first traverse the table looking
 *   for empty slots.
 */
TYPE file_handle IS RECORD ( fid NUMBER, offset INTEGER );
TYPE file_handles IS TABLE OF file_handle;
open_file_handles file_handles := file_handles();
/*--------------------------------------------------------------------------*/
/*
 * err_msg - (PRIVATE) shortcut for building standard gfm error message
 */
PROCEDURE err_msg(name varchar2) is
begin
  fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
  fnd_message.set_token('ROUTINE', 'FND_GFM.'||name);
  fnd_message.set_token('ERRNO', SQLCODE);
  fnd_message.set_token('REASON', SQLERRM);
end err_msg;
/*--------------------------------------------------------------------------*/
/*
 * authenticate - validate the specified access key
 */
FUNCTION authenticate(access_id  number,
                      file_id    number default -1) RETURN boolean
is
  rowcount number;
begin
  select count(*) into rowcount
  from   fnd_lob_access
  where  nvl(file_id,-1) = nvl(authenticate.file_id, -1)
  and    access_id = authenticate.access_id
  and    timestamp > sysdate;

  if (rowcount=1) then
    return TRUE;
  end if;
  return FALSE;
exception
  when others then
    fnd_gfm.err_msg('authenticate');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * authorize - generate an authorized access key, good for one day.
 */
FUNCTION authorize(file_id number) return number is
pragma autonomous_transaction;
  result number;
begin
 loop
     begin
	  insert into fnd_lob_access (access_id, file_id, timestamp)
	  values (fnd_crypto.RANDOMNUMBER,
			  file_id, sysdate+1)
	  returning access_id into result;
	  commit;
	  return result;
	exception
	  when DUP_VAL_ON_INDEX then
	    null;
        end;
 end loop;
 exception
     when others then
		fnd_gfm.err_msg('authorize');
		raise;
end;

/*--------------------------------------------------------------------------*/
/*
 * construct_download_URL - construct a download URL
 *   Very little work is done here but the knowledge of the exact
 *   syntax of the URL is self-contained.  If the purge option is
 *   indicated, we set the expiration date to the near future, so
 *   that the file is purged whether or not the URL is issued.
 */
FUNCTION construct_download_url2(gfm_agent     varchar2,
				file_id       number,
				purge_on_view boolean default FALSE,
				modplsql      boolean default FALSE,
			        authenticate  boolean,
                                user_name     varchar2 default NULL,
                                lifespan      number default NULL)
	 return varchar2 is
pragma autonomous_transaction;
  access_id  varchar2(100);
  url        varchar2(2000);
  file_ext   varchar2(10);
  file_name  varchar2(300);
  export_mime varchar2(30);
  ext_length number;
  l_module_source varchar2(80) := 'FND_GFM.CONSTRUCT_DOWNLOAD_URL2';
  l_user varchar2(255);
  l_gfmauth varchar2(10) := 'Y';
  l_lifespan number;
  l_user_id number;
begin

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Begin');
  end if;

  -- Bug 28772297: Now using ticketing - see below one_time_use_store call
  --access_id := fnd_gfm.authorize(file_id);

 /*  Changed url structure to be gfmagent/fndgfm/fnd_gfm.get/arg1/arg2/fnd_gfm.ext
  *  to eliminate the dependancy on the desktop having the content/mime type set
  *  correctly.  Now the file downloaded will have the correct extension so as long
  *  as the file ext is associated to an application it will open successfully/correctly.
  *  Temporarily hardcoding the most common export file types until a lookup can be created.
 */

  -- purge_on_view is TRUE then exporting

 if purge_on_view then

    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'PURGE_ON_VIEW is TRUE - set expiration date of LOB only for export');
    end if;

    export_mime := fnd_profile.value('FND_EXPORT_MIME_TYPE');

    if export_mime = 'text/tab-separated-values' then
       file_ext := '.tsv';
    elsif
       export_mime = 'text/comma-separated-values' then
       file_ext := '.csv';
    elsif
       export_mime = 'text/plain' then
       file_ext := '.txt';
    elsif
       export_mime like '%excel' then
       file_ext := '.xls';
    elsif
       export_mime = 'text/html' then
       file_ext := '.htm';
    elsif
       export_mime like 'application/%msword' then
       file_ext := '.doc';
    else
       file_ext := '';
    end if;

    file_name := 'fnd_gfm'||file_ext;

    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'export only: set expiration date for file_id: '||construct_download_url2.file_id);
    end if;

    /*  Added program_name to where condition to expire ONLY export data */
    update fnd_lobs set fnd_lobs.expiration_date = sysdate + 0.5
    where  fnd_lobs.file_id = construct_download_url2.file_id
    and lower(program_name) = 'export';

 else
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'PURGE ON VIEW is FALSE - do not set expiration date of export LOB');
    end if;

    select instr(file_name,'.',-1) into ext_length
    from fnd_lobs
    where file_id = construct_download_url2.file_id;

    if ext_length > 0 then
       select substr(file_name,instr(file_name,'/',-1)+1) into file_name
       from fnd_lobs
       where file_id = construct_download_url2.file_id;
    else
       file_name := 'fnd_gfm';
    end if;
 end if;

  -- Bug 28772297:
  -- GFM will now require authentication by default.  Use a preference to override and revert to old behavior
  -- Authentication order of precedence:
  -- API authenticate parameter (if false)
  -- Preference
  -- Default true
   l_gfmauth := nvl(fnd_preference.get('#INTERNAL','FNDGFM','FILE_DOWNLOAD_AUTH'),'Y');

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Get auth preference - override default? '||l_gfmauth);
   end if;


   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Auth parameter passed default is true');
   end if;
   if (NOT authenticate OR l_gfmauth='N') then
       if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Auth parameter passed is false or preference is N - no auth');
       end if;

       l_gfmauth := 'N';
   else
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Auth parameter passed is true and pref not set - auth');
      end if;
      l_gfmauth := 'Y';
   end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Auth required? '||l_gfmauth);
  end if;


  -- Determine user access
  if (upper(l_gfmauth) = 'Y') then
      l_user := nvl(user_name,fnd_global.user_name);
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        select user_id into l_user_id from fnd_user where user_name = l_user;
	fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Restrict to user: '|| l_user_id);
      end if;
  else
      -- No auth required. Use generic value
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'default user');
      end if;

      l_user := 'GFMGUEST';
  end if;

  -- Calculate lifespan of file access
  fnd_profile.get('FND_GFM_ACCESS_DURATION',l_lifespan);

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'File access time limit profile (lifespan): '||l_lifespan);
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'lifespan parameter '||lifespan);
  end if;

  -- lifespan parameter takes precedence but first verify it is within limits
  if (lifespan is not null and lifespan between 1 and 1440) then
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'lifespan parameter is within limits - use this value: '||lifespan);
      end if;

      l_lifespan := lifespan;
  else
      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'lifespan parameter is null or invalid.  Default will be used.');
      end if;
  end if;

  if (l_lifespan is not null and l_lifespan between 1 and 1440) then
     -- expect this to be passed in minutes - convert to seconds.
     l_lifespan := l_lifespan*60;
     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'lifespan override is within limits: convert to seconds '||l_lifespan);
     end if;
  else
     if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Use default lifespan - either no value is configured or it is not valid ');
     end if;

     l_lifespan := 300;
  end if;
  -- Done verifying and calculating lifespan of file access

  -- Get access_id/ticket
  access_id := one_time_use_store(file_id||':'||l_user,l_lifespan,'GFM_TICKET');

  -- Bug 28772297: done with ticket creation

  --check the release
  if (fnd_gfm.getRelease = 11) then
     url := fnd_web_config.trail_slash(gfm_agent)||'fndgfm/fnd_gfm.get/'||access_id||'/'||file_id||'/'||file_name;
  else
    -- we take all this trouble only if we are on R12
    --construct the download URL
    if (modplsql) then
       url := fnd_web_config.trail_slash(gfm_agent)||'fndgfm/fnd_gfm.get/'||access_id||'/'||file_id||'/'||file_name;
    else
      -- Bug 28772297: authenticate will be determined by gfa parameter
       url := fnd_web_config.trail_slash(fnd_profile.value('APPS_FRAMEWORK_AGENT'))||'OA_HTML/fndgfm.jsp?mode=download_blob'||'&'||'fid='||file_id||'&'||'accessid='||access_id||'&'||'gfa='||l_gfmauth;
    end if; -- end of modplsql check
  end if; -- end of release check
  commit;

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'URL is: '||url);
   end if;

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'End');
   end if;

  return url;
exception
  when others then
    fnd_gfm.err_msg('construct_download_url2');
    raise;
end;

--------------------------------------------------------------------------------------
/*  Original construct_download_url2 that now calls the API that does all the processing
 *  Added for GFM Restriction project
*/

FUNCTION construct_download_url2(gfm_agent     varchar2,
                                file_id       number,
                                purge_on_view boolean default FALSE,
                                modplsql      boolean default FALSE,
                                authenticate  boolean default TRUE)
         return varchar2 is
begin

 return construct_download_url2(gfm_agent,file_id,purge_on_view,modplsql,authenticate,user_name => NULL,lifespan => null);

exception when others then
  fnd_gfm.err_msg('construct_download_url2');
  raise;
end;


/*--------------------------------------------------------------------------*/
/*
 * construct_upload_URL - construct an upload URL
 *   Very little work is done here but the knowledge of the exact
 *   syntax of the URL is self-contained.
 */
FUNCTION construct_upload_URL(gfm_agent     VARCHAR2,
                              proc          VARCHAR2,
			      access_id     NUMBER)
return varchar2 is
--sqlbuf   varchar2(1000);
params_passed  varchar2(2000);
func_id  number;
user_id  number;
resp_id  number;
resp_appl_id number;
sec_grp_id number :=0;
begin
  if (fnd_gfm.getRelease = 12) then

    user_id := fnd_profile.value('USER_ID');
    resp_id := fnd_profile.value('RESP_ID');
    resp_appl_id := fnd_profile.value('RESP_APPL_ID');
    sec_grp_id := fnd_profile.value('SECURITY_GROUP_ID');

    params_passed := 'access_id'||access_id;

    begin
      select function_id
      into   func_id
      from   fnd_form_functions
      where  function_name = 'FND_FNDFLUPL';
    exception
      when no_data_found then
         return fnd_web_config.trail_slash(gfm_agent)||proc;
      when too_many_rows then
         select function_id
         into   func_id
         from   fnd_form_functions
         where  function_name = 'FND_FNDFLUPL'
         and    upper(type) = 'JSP';
      when others then
         fnd_gfm.err_msg('construct_upload_url_r12');
         raise;
    end;

    return FND_RUN_FUNCTION.GET_RUN_FUNCTION_URL(
                              P_FUNCTION_ID => func_id,
                              P_RESP_APPL_ID => resp_appl_id,
                              P_RESP_ID => resp_id,
                              P_SECURITY_GROUP_ID => sec_grp_id,
                              P_PARAMETERS => params_passed);

    /*
      As of now there seems no way to open from pl/sql block this
      OA Framework page. If we do we could incorporate the below code
      for a generic callback
    */

    --block the call till we have a submit
    --fnd_gfm.wait_for_upload('FND_GFM_ALERT' || to_char(access_id));
    --if we can create a unfirom structure for the callback
    --we could invoke a callback here things we can provide is
    --file_id , access_id etc as of now aniticipating a maximum
    --these params
    --if (proc is NOT null) then
     -- sqlbuf := 'begin ' || proc || ' (:v1, :v2, :v3, :v4, :v5); end;';
      --   execute immediate sqlbuf using
       --    in access_id,
        --   in fid,
         --  in out result;
      --if (result = true)
       -- return 'SUCCESS';
      --else
        --fnd_gfm.err_msg('construct_upload_url.failed_callback');
        --raise;
      --end if;
    --end if;

  else
    return fnd_web_config.trail_slash(gfm_agent)||proc;
  end if;

exception
  when others then
    fnd_gfm.err_msg('construct_upload_url');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * construct_get_url - construct a get request URL
 *   Very little work is done here but the knowledge of the exact
 *   syntax of the URL is self-contained.
 */
FUNCTION construct_get_url(gfm_agent  varchar2,
			   proc       varchar2,
                           path       varchar2) return varchar2 is
pragma autonomous_transaction;
begin
  return fnd_web_config.trail_slash(gfm_agent)||
         fnd_gfm.construct_relative_get(proc,path);
exception
  when others then
    fnd_gfm.err_msg('construct_get_url');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * construct_relative_get - construct a relative get request URL
 *   fragment without the plsql_agent/dad info.
 *
 *   This function constructs a URL that may be presented to the browser
 *   as a relative url to a document that has already been "gotten".
 *
 *   proc   Procedure to run
 *   path   Argument path
 */
FUNCTION construct_relative_get(proc  varchar2,
                                path  varchar2) return varchar2 is
pragma autonomous_transaction;
begin
  return 'fndgfm/'||proc||'/'||path;
exception
  when others then
    fnd_gfm.err_msg('construct_relative_get');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * confirm_upload - confirm the completion of an upload
 *   This procedure must be called from within the user's PL/SQL upload
 *   procedure to authenticate the upload and move the blob into the
 *   fnd_lobs table.  The new generated file_id is returned to the caller.
 *
 *   access_id        The access identifier that authorized the upload
 *   file_name        The file_name as stored in the fnd_lobs_document table
 *                    by WebDB...the value of the file type input field.
 *   program_name     The application short name to record
 *   program_tag      The application tag to record
 *   expiration_date  The expiration date to record; typically, this is null
 *                    which means that the LOB never expires, but must be
 *                    explicitly deleted
 *   language         The document language; defaults to userenv('LANG')
 *   wakeup           If TRUE, indicates that wait_for_upload is expected to
 *                    be called on the original authorization key; the GFM
 *                    can associate the given file identifier to the original
 *                    authorization key and wake up the identified waiter.
 *
 *                    BUG#2461866 Added fn to parse out file_name.
 */
FUNCTION confirm_upload(
    access_id         number,
    file_name         varchar2,
    program_name      varchar2 default null,
    program_tag       varchar2 default null,
    expiration_date   date     default null,
    language          varchar2 default userenv('LANG'),
    wakeup            boolean  default FALSE)
return number is
  fid number := -1;
  fn  varchar2(256);
  mt  varchar2(240);
  bloblength number;       -- bug 3045375, added variable to set length of blob.
  ufslim number;
begin
  if (getRelease = 12) then
     begin
       --we already through the OA page has inserted the
       --data into fnd_lobs table
       --return the file_id corresponding to this access_id
       select  file_id
       into    fid
       from    fnd_lob_access
       where   access_id = confirm_upload.access_id;

       --raise the alert back so that the wait is ended
       if wakeup then
        dbms_alert.signal('FND_GFM_ALERT'||to_char(access_id), to_char(fid));
       end if;

       return fid;
     exception
       when others then
        return -1;
     end;
  else
   if (fnd_gfm.authenticate(confirm_upload.access_id)) then

     if (verify_file_type(file_name => confirm_upload.file_name) = 'Y') then
         select fnd_lobs_s.nextval into fid from dual;

        fn := SUBSTR(confirm_upload.file_name, INSTR(confirm_upload.file_name,'/')+1);

        -- bug 3045375, added select to get length of BLOB.
        select dbms_lob.getlength(blob_content), mime_type
        into bloblength, mt
        from fnd_lobs_document
        where name = confirm_upload.file_name
        and rownum=1;

        -- bug 3045375, added if to check length of blob.
        -- bug 4279252. added UPLOAD_FILE_SIZE_LIMIT check.

       if fnd_profile.value('UPLOAD_FILE_SIZE_LIMIT') is null then
           ufslim := bloblength;
       else
         /* The profile is not limited to being a numeric value.  Stripping off any
            reference to kilobytes. */

         if (instr(upper(fnd_profile.value('UPLOAD_FILE_SIZE_LIMIT')),'K')>0) then
            ufslim := substr(fnd_profile.value('UPLOAD_FILE_SIZE_LIMIT'),1,
                      instr(upper(fnd_profile.value('UPLOAD_FILE_SIZE_LIMIT')),'K')-1);
         else
           ufslim := fnd_profile.value('UPLOAD_FILE_SIZE_LIMIT');
         end if;

           /* Bug 6490050 - profile is defined to be in KB so we need to convert
            here.  Consistent with the fwk code.  */

           ufslim := ufslim * 1000;
       end if;

        if bloblength BETWEEN 1 and ufslim then
          insert into fnd_lobs (file_id,
                              file_name,
                              file_content_type,
                              file_data,
                              upload_date,
                              expiration_date,
                              program_name,
                              program_tag,
                              language,
                              file_format)
          (select confirm_upload.fid,
                fn,
                ld.mime_type,
                ld.blob_content,
                sysdate,
                confirm_upload.expiration_date,
                confirm_upload.program_name,
                confirm_upload.program_tag,
                confirm_upload.language,
                fnd_gfm.set_file_format(mt)
           from   fnd_lobs_document ld
           where  ld.name = confirm_upload.file_name
           and    rownum=1);

          if (sql%rowcount <> 1) then
            raise no_data_found;
          end if;

          update fnd_lob_access set file_id = fid
          where  access_id = confirm_upload.access_id;

          if wakeup then
            dbms_alert.signal('FND_GFM_ALERT'||to_char(access_id), to_char(fid));
          end if;
        -- bug 3045375, added else to return fid = -2.
        else
       -- This indicates that an invalid file size has been uploaded.
       fid := -2;
    end if;
  else
     -- bug 9276419 - indicate a restricted file by returning -3
       fid := -3;
  end if;
    delete from fnd_lobs_document;
    delete from fnd_lobs_documentpart;
  end if;
 end if;
  return fid;
exception
  when others then
    delete from fnd_lobs_document;
    delete from fnd_lobs_documentpart;

    fnd_gfm.err_msg('confirm_upload');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * get_file_id
 *   This function retrieves the file_id for the corresponding access_id
 *   from the fnd_lob_access table.
 *
 *   access_id     the access id
 */
FUNCTION get_file_id(access_id number) return number is
  fid number := -1;
begin
  select file_id into fid
  from   fnd_lob_access
  where  access_id = get_file_id.access_id;

  if (sql%rowcount <> 1) then
    raise no_data_found;
  end if;

  return fid;
exception
  when others then
    fnd_gfm.err_msg('get_file_id');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * dispatch
 *   This procedure takes a single argument in the form of
 *       <proc>/<arg>
 *
 *   and executes the proc, passing along the single arg.
 *
 *   p_path     <proc>/<arg>
 */
PROCEDURE dispatch(p_path in varchar2) is
  proc              varchar2(256);
  arg               varchar2(1000);
  slash             number;
  cmd               varchar2(1300);

begin
  cmd := ltrim(p_path, '/');
  slash := nvl(instr(cmd, '/'), 0);
  proc := upper(substr(cmd, 1, slash-1));
  arg := substr(cmd, slash);

  if (fnd_web_config.check_enabled(proc) = 'Y') then
    cmd := 'begin '||proc||'(:1); end;';
    execute immediate cmd using in arg;
  else
    htp.htmlOpen;
    htp.headOpen;
    htp.title('Access Denied');
    htp.headClose;
    htp.bodyOpen;
    htp.p('<b>Access Denied</b>');
    htp.hr;

    -- If the procedure contains an HTML tag, don't display it.
    --
    if (instr(proc,'<') > 0) then
      htp.p('Not authorized to access procedure.');
    else
      htp.p('Not authorized to access '||proc||'.');
    end if;

    htp.bodyClose;
    htp.htmlClose;
  end if;

exception
  when others then
    fnd_gfm.err_msg('dispatch');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * wait_for_upload - wait for upload confirmation
 */
PROCEDURE wait_for_upload(access_id     number,
                          timeout       number,
			  file_id   out NOCOPY number) is
pragma autonomous_transaction;
  name     varchar2(64);
  message  varchar2(32);
  status   integer;
begin
  name := 'FND_GFM_ALERT' || to_char(access_id);
  dbms_alert.register(name);
  dbms_alert.waitone(name, message, status, timeout);
  dbms_alert.remove(name);

  if status = 1 then
    file_id := null;
  else
    file_id := to_number(message);
  end if;
  commit;
end;

/*--------------------------------------------------------------------------*/
/*
 * purge_expired - purge all expired rows in GFM tables
 * Default purging orphaned attachment LOBs to 'N'
 */
PROCEDURE purge_expired(program_name varchar2 default null) is

begin
   purge_expired(program_name => program_name,
                 purge_orph_attch => 'N');
end;


/*--------------------------------------------------------------------------*/
/*
 * purge_expired - purge all expired rows in GFM tables
 */
PROCEDURE purge_expired(program_name varchar2 default null, purge_orph_attch varchar2) is
pragma autonomous_transaction;

  CURSOR c_orph_attch_lob IS
        SELECT file_id
        FROM FND_LOBS FL
        WHERE NOT EXISTS (SELECT '1'
                          FROM FND_DOCUMENTS FD
                          WHERE FD.MEDIA_ID = FL.FILE_ID
                          AND FD.DATATYPE_ID = 6)
        AND PROGRAM_NAME = 'FNDATTCH'
        AND EXPIRATION_DATE IS NULL;

  l_file_id number;
  l_doc_cnt number;
  l_doc_cnt_tl number;
  l_module_source varchar2(256) := 'FND_GFM.PURGE_EXPIRED';

begin
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Begin');
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Purging orphaned attachment data: '||purge_orph_attch);
  end if;

  -- For performance a check for orphaned attachment lobs will be done when
  -- explicitly purging FNDATTCH program data

  if (program_name = 'FNDATTCH' and purge_orph_attch = 'Y') then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'PROGRAM_NAME=FNDATTCH - set expiration date for orphaned Attachment lobs');
     end if;

     -- Set expiration_date for orphaned lobs
     -- Limiting to One time documents (for now)
     open c_orph_attch_lob;

     LOOP
        fetch c_orph_attch_lob into l_file_id;
        EXIT WHEN c_orph_attch_lob%NOTFOUND;

        select count(*) into l_doc_cnt
        from fnd_documents
        where datatype_id = 6
        and media_id = l_file_id;

        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Number of fnd_documents for file_id: '||l_file_id||' is '||l_doc_cnt);
        end if;


        select count(*) into l_doc_cnt_tl
        from fnd_documents fd, fnd_documents_tl fdtl
        where fd.datatype_id = 6
        and fd.document_id = fdtl.document_id
        and fdtl.media_id = l_file_id;

        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Number of fnd_documents_tl for file_id: '||l_file_id||' is '||l_doc_cnt_tl);
        end if;


        if (l_doc_cnt = 0 and l_doc_cnt_tl = 0) then -- set expiration date
             if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                 fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Set expiration date and purge orphaned fnd_lobs record: '||l_file_id);
             end if;

            update fnd_lobs fl
            set expiration_date = sysdate-1
            where program_name = 'FNDATTCH'
            and file_id = l_file_id;
        end if;

    END LOOP;
     close c_orph_attch_lob;
     commit;
  end if;

  if purge_expired.program_name is null then
    delete from fnd_lobs       where sysdate > expiration_date;
    delete from fnd_lob_access where sysdate > timestamp;
    commit;
  else
    delete from fnd_lobs
    where fnd_lobs.program_name = purge_expired.program_name
    and sysdate > expiration_date;
    commit;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'End');
  end if;

exception
  when others then
    fnd_gfm.err_msg('purge_expired');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * purge_set - purge selected rows from the LOB table
 */
PROCEDURE purge_set(program_name varchar2,
		                program_tag  varchar2 default null) is
pragma autonomous_transaction;
begin
  if program_tag is null then
    delete from fnd_lobs where fnd_lobs.program_name = purge_set.program_name
    and program_name <> 'FNDATTCH';
  else
    delete from fnd_lobs
    where  fnd_lobs.program_name = purge_set.program_name
    and    fnd_lobs.program_tag  = purge_set.program_tag;
  end if;
  commit;
exception
  when others then
    fnd_gfm.err_msg('purge_set');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * purge - CM cover routine for purge_set and purge_expired
 */
PROCEDURE purge(errbuf        out NOCOPY varchar2,
                retcode       out NOCOPY varchar2,
                expired       in   varchar2 default 'Y',
                program_name  in   varchar2 default null,
                program_tag   in   varchar2 default null,
                purge_orph_attch in   varchar2)
is
begin
  if (purge.expired <> 'N') then
    fnd_gfm.purge_expired(purge.program_name,purge.purge_orph_attch);

  elsif (purge.program_name is not null) then
    fnd_gfm.purge_set(purge.program_name, purge.program_tag);

  end if;

  retcode := '0';                     -- (successful completion)
  errbuf  := '';

exception
  when others then
    retcode := '2';                   -- (error)
    fnd_message.retrieve(errbuf);
end;


/*--------------------------------------------------------------------------*/
/*
 * purge - CM cover routine for purge_set and purge_expired
 */
PROCEDURE purge(errbuf        out NOCOPY varchar2,
                retcode       out NOCOPY varchar2,
                expired       in   varchar2 default 'Y',
                program_name  in   varchar2 default null,
                program_tag   in   varchar2 default null)
is
x_errbuf varchar2(80);
x_retcode varchar2(80);
begin

   purge(errbuf => x_errbuf,
         retcode => x_retcode,
         expired => expired,
         program_name => program_name,
         program_tag => program_tag,
         purge_orph_attch => 'N');

exception
  when others then
    x_retcode := '2';                   -- (error)
    fnd_message.retrieve(x_errbuf);
end;




/*--------------------------------------------------------------------------*/
/*
 * file_create - create a new empty file
 */
FUNCTION file_create(file_name     varchar2 default null,
		     content_type  varchar2 default 'text/plain',
		     program_name  varchar2 default null,
		     program_tag   varchar2 default null) return number is
pragma autonomous_transaction;
  fd             integer;
  fh             file_handle;
  l_lang         varchar2(4):= userenv('LANG');
  l_file_format	 varchar2(10) := 'binary';
  iana_cs        varchar2(150);
  ocs            varchar2(30);
  ct             varchar2(100);
begin
  -- get a file handle slot
  fd := null;
  for i in 1..open_file_handles.count loop
    if open_file_handles(i).fid is null then
      fd := i;
      exit;
    end if;
  end loop;

  -- Set file format
  if(upper(substr(content_type,1,4)) = 'TEXT' ) then
    l_file_format := 'text';
  end if;

  -- Determine the IANA Charset and add to content-type, if necessary
  if (instr(content_type,'charset=') > 0) then
    iana_cs := substr(content_type, instr(content_type,'=',-1)+1);
    ct := content_type;
  else
    iana_cs := fnd_gfm.get_iso_charset;
    ct := content_type||'; charset='||iana_cs;
  end if;

  if fd is null then
    open_file_handles.extend;
    fd := open_file_handles.count;
  end if;

  insert into fnd_lobs (file_id, file_name, file_content_type,
	file_data, upload_date, expiration_date, program_name, program_tag,
	language,oracle_charset,file_format)
  values (fnd_lobs_s.nextval, file_name, ct,
	  EMPTY_BLOB(), sysdate, sysdate + 1, program_name, program_tag,
	  l_lang, fnd_gfm.iana_to_oracle(iana_cs), l_file_format)
  returning file_id into fh.fid;

  fh.offset := 1;
  open_file_handles(fd) := fh;

  commit;
  return fd;
exception
  when others then
    fnd_gfm.err_msg('file_create');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * file_close - close a file
 */
FUNCTION file_close(fd number) return number is
pragma autonomous_transaction;
  fh file_handle;
begin
  fh := open_file_handles(fd);
  open_file_handles(fd) := null;

  update fnd_lobs set expiration_date = null where file_id = fh.fid;
  commit;

  return fh.fid;
exception
  when others then
    fnd_gfm.err_msg('file_close');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * file_write - write raw data to a file
 */
PROCEDURE file_write(fd number, amount binary_integer, buffer raw) is
pragma autonomous_transaction;
  fh    file_handle;
  flob  blob;
  ocs   varchar2(30);
  l_len number := utl_raw.length(buffer);
  l_pos number := 1;
  l_str raw(6000) := null;
begin
  fh := open_file_handles(fd);

  -- Re-open blob and get data. We must re-open every time instead of
  -- caching so that procedures can be made autonomous.
  select file_data, oracle_charset into flob, ocs
  from   fnd_lobs
  where  file_id = fh.fid
  for update of file_data;

  -- BUG#1449494, created while loop to bypass convert() limitation.
  while (l_len > 1000) loop
    l_str := utl_raw.substr(buffer,l_pos, 1000);
    dbms_lob.write(flob,1000,fh.offset, convert(l_str,ocs));
    l_pos := l_pos + 1000;
    l_len := l_len - 1000;
    fh.offset := fh.offset + 1000;
  end loop;
  l_str := utl_raw.substr(buffer, l_pos);
  dbms_lob.write(flob, l_len, fh.offset, convert(l_str,ocs));
  fh.offset := fh.offset + l_len;
  open_file_handles(fd) := fh;
  commit;
exception
  when others then
    fnd_gfm.err_msg('file_write');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * file_write - write a line of text to a file
 */
PROCEDURE file_write(fd number, buffer varchar2) IS
  -- NOTE: This procedure is implicitly Autonomous Transaction,
  --       because file_write(..<raw>..) is autonomous.
begin
  if buffer is not null then
    file_write(fd, lengthb(buffer), utl_raw.cast_to_raw(buffer));
  end if;
end;
/*--------------------------------------------------------------------------*/
/*
 * file_write_line - write a line of text to a file with a line terminator
 */
PROCEDURE file_write_line(fd number, buffer varchar2) is
  -- NOTE: This procedure is implicitly Autonomous Transaction,
  --       because file_write(..<raw>..) is autonomous.
  --       BUG#1811196
  --       Combined 2 file_write() calls to 1 for performance gain.
begin
  file_write(fd, (lengthb(buffer)+2),
  (utl_raw.concat(utl_raw.cast_to_raw(buffer), hextoraw('0D0A'))));
end;
/*--------------------------------------------------------------------------*/
/*
 * test - testing procedure
 *   This procedure exists to give the GFM cartridge a test target
 *   in the database.
 */
PROCEDURE test is
begin
  htp.print('Success');
end;
/*--------------------------------------------------------------------------*/
/*
 * get_iso_charset
 *   This procedure retrieves the iso equivalent of the db's character set.
 */
FUNCTION get_iso_charset return varchar2 is
  charset varchar2(150);
  charmap constant varchar2(30) := 'FND_ISO_CHARACTER_SET_MAP';
begin
  select tag into charset
  from   fnd_lookup_values_vl
  where  lookup_type = charmap
  and    lookup_code = substr(userenv('LANGUAGE'),
                            instr(userenv('LANGUAGE'),'.')+1);
  return charset;
exception
  when others then
    fnd_gfm.err_msg('get_iso_charset');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * iana_to_oracle
 *   This procedure retrieves the oracle equivalent of the specified iana
 *   charset.
 */
FUNCTION iana_to_oracle(ics varchar2) return varchar2 is
  cs varchar2(50);
  charmap constant varchar2(30) := 'FND_IANA_TO_ORACLE_CHARSET_MAP';
begin
  select tag into cs
  from   fnd_lookup_values_vl
  where  lookup_type = charmap
  and    upper(lookup_code) = upper(ics);

  if (sql%rowcount <> 1) then
    raise no_data_found;
  end if;

  return cs;
exception
  when others then
    fnd_gfm.err_msg('iana_to_oracle');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * oracle_to_iana
 *   This procedure retrieves the iana equivalent of the specified oracle
 *   charset
 */
FUNCTION oracle_to_iana (cs varchar2) return varchar2 is
  ics varchar2(150);
  charmap constant varchar2(30) := 'FND_ISO_CHARACTER_SET_MAP';
begin
  select tag into ics
  from   fnd_lookup_values_vl
  where  lookup_type = charmap
  and    upper(lookup_code) = upper(cs)
  and    rownum = 1;

  if (sql%rowcount <> 1) then
    raise no_data_found;
  end if;

  return ics;
exception
  when others then
    fnd_gfm.err_msg('oracle_to_iana');
    raise;
end;
/*--------------------------------------------------------------------------*/
/*
 * download -
 *   This procedure processes a download request
 *   If purge is specified, then the row is deleted immediately
 */
PROCEDURE download(file_id number,
                   access  number,
                   purge   varchar2 default NULL) is
  doc  blob;
  ct   varchar2(100);
begin
  if (fnd_gfm.authenticate(access, file_id) = FALSE) then
    htp.p(Fnd_Message.Get_String('PAY','HR_51401_WEB_NOT_AUTHORIZED'));
  else
    fnd_gfm.download_blob(file_id);

    if (purge = 'yes') then
 /*  Instead of deleting the data immediatlely we are setting the
  *  expiration data.
  *  delete from fnd_lobs where file_id = download.file_id;  */
    update fnd_lobs
      set fnd_lobs.expiration_date = sysdate + 0.5
     where fnd_lobs.file_id = download.file_id
      and program_name <> 'FNDATTCH';
    end if;
  end if;
exception
  when others then
    fnd_gfm.err_msg('download');
    raise;
end download;
/*--------------------------------------------------------------------------*/
/*
** download_blob -
**   encapsulate the actual downloading of the blob using webdb's procedure
*/
PROCEDURE download_blob(fid number) is
  ct    varchar2(255);
  ctype varchar2(255);
  doc   blob;
  cs    varchar2(150);
  semi  number;
  eq    number;
  len	number;
  bb    boolean;
  buffer	raw(32000);
  amount	number :=16000;
  b_amount	number;
  lenvarb	number;
  offset 	number :=1;
  offset2 	number :=1;
  lob_loc	blob;
  nce		varchar2(120);
  ocs		varchar2(120);
  var		varchar2(32000);
  pn            varchar2(32);
  fn            varchar2(256);
  c_browser     varchar2(400) := owa_util.get_cgi_env('HTTP_USER_AGENT');


begin
  select file_content_type, oracle_charset, program_name, file_data, file_name
  into   ct, ocs, pn, doc, fn
  from   fnd_lobs
  where  file_id = download_blob.fid;

  semi := instr(ct, ';');
  -- Bug 3966022 - looking now specifically for charset value
  -- eq   := instr(ct, '=');
  eq := instr(upper(ct), 'CHARSET=');

  if (semi = 0) then
    ctype := ct;
  else
    ctype := substr(ct, 1, semi-1);
  end if;

  if (eq = 0) then  -- no charset so pass null
    cs := null;
  else
    eq := eq + 8; -- Add 8 to account for the length of charset=
    semi := instr(ct,';', eq);
    if (semi = 0) then
      cs := substr(ct, eq);
    else
      cs := substr(ct, eq, semi-eq);
    end if;
  end if;

  fnd_profile.get_specific('FND_NATIVE_CLIENT_ENCODING',fnd_global.user_id,NULL,NULL,nce,bb);

  if (pn = 'export' and nce is not null) then
    cs	:= fnd_gfm.oracle_to_iana(nce);
    nce := 'american_america.'||nce;
    ocs := 'american_america.'||ocs;
    dbms_lob.createtemporary(lob_loc,TRUE);
    dbms_lob.open(doc, DBMS_LOB.LOB_READONLY);
    len := dbms_lob.getlength(doc);
    loop
	if len > amount
	then
    		dbms_lob.read(doc, amount, offset, buffer);
                var :=utl_raw.cast_to_varchar2(buffer);
		lenvarb :=lengthb(var);
		if length(var) > 10
		then
		var := substr(var, 1, length(var) - 10);
		end if;
		lenvarb := lenvarb - lengthb(var);
		buffer := utl_raw.cast_to_raw(var);
    		buffer := utl_raw.convert(buffer, nce, ocs);
    		b_amount := utl_raw.length(buffer);
    		dbms_lob.write(lob_loc, b_amount, offset2, buffer);
		len := len - amount + lenvarb;
		offset := offset + amount - lenvarb;
		offset2 := offset2 + b_amount;
	else
    		dbms_lob.read(doc, len, offset, buffer);
    		buffer := utl_raw.convert(buffer, nce, ocs);
    		amount := utl_raw.length(buffer);
    		dbms_lob.write(lob_loc, amount, offset2, buffer);
	exit;
	end if;
    end loop;
  end if;

  owa_util.mime_header(ctype, FALSE, cs);

  -- Mime sniffing bug 11706983: force to download as an attachment in IE

  if ((instr(c_browser,'MSIE') > 0) and pn <> 'export' and ct='text/plain') then
       htp.p('Content-Disposition: attachment; filename='||'"'||fn||'"');
  end if;

  if (pn = 'export' and nce is not null) then
     htp.p( 'Content-length: ' || dbms_lob.getlength(lob_loc));
  else
     htp.p( 'Content-length: ' || dbms_lob.getlength(doc));
  end if;
/* Commenting out the following do resolve the issue with Export
   failing on Internet Explorer.
  htp.p( 'Cache-Control: no-cache' ); */
  owa_util.http_header_close;
  if (pn = 'export' and nce is not null) then
     wpg_docload.download_file(lob_loc);
     dbms_lob.freetemporary(lob_loc);
     dbms_lob.close(doc);
  else
     wpg_docload.download_file(doc);
  end if;

exception
  when no_data_found then
    htp.htmlOpen;
    htp.headOpen; htp.title('404 Not Found'); htp.headClose;
    htp.bodyOpen; htp.hr; htp.header(nsize=>1, cheader=>'HTTP Error 404');
    htp.hr;
    htp.p(Fnd_Message.Get_String('GMD','LM_BAD_FILENAME'));
    htp.bodyClose; htp.htmlClose;
  when others then
    fnd_gfm.err_msg('download_blob');
    raise;
end download_blob;

/*
 * one_time_use_store
 *   Store a value in the FND_LOB_ACCESS table and return a one-time-use
 *   ticket that can be used by one_time_use_retrieve() to fetch the value.
 */

FUNCTION one_time_use_store(value number) RETURN number IS
pragma autonomous_transaction;
  ticket number;
begin
  for i in 1..10 loop
    begin
      ticket    := fnd_crypto.RANDOMNUMBER;
      INSERT INTO fnd_lob_access (access_id, file_id, timestamp)
        VALUES (ticket, value, sysdate+1);
      commit;
      return ticket;
    exception
      when dup_val_on_index then
        null;
    end;
  end loop;
  -- More then 10 duplicates return -1 (error)
  return -1;

exception
  when others then
    rollback;
    return -1;
end;

/*
 * one_time_use_store
 * A more secure API with a large entropy.
 * It returns a string that expires after lifespan
 * seconds. Opcode is a verification code used
 * when retrieving ticket value.
 */
function one_time_use_store( value in varchar2 ,
                             lifespan in number default null,
                             opcode in varchar2 default null)
                     return varchar2 is
  l_lifespan number;
begin
   if ( lifespan is not null) then
        return FND_HTTP_TICKET.CREATE_TICKET_STRING(opcode, value, lifespan);
   else
        return FND_HTTP_TICKET.CREATE_TICKET_STRING(opcode, value);
   end if;
end;

/*
 * one_time_use_retrieve
 *   Retrieve a value from the FND_LOB_ACCESS table, given a one-time-use
 *   ticket that was generated by one_time_use_store().
 */
FUNCTION one_time_use_retrieve(ticket number) return number is
pragma autonomous_transaction;
  value number;
begin
  select file_id into value from fnd_lob_access
    where access_id = ticket for update;
  delete from fnd_lob_access where access_id = ticket;
  commit;
  return value;
exception
  when others then
    rollback;
    return -1;
end;

/*
 * one_time_use_retrieve
 *   Retrieves value given a one-time-use
 *   ticket that was generated by one_time_use_store().
 *   if opcode passed, the API verifies the opcode value
 *   against the opcode value passed in one_time_use_store.
 */
function one_time_use_retrieve( ticket in varchar2 ,
                                opcode in varchar2 default null)
                     return varchar2 is
  l_args varchar2(4000);
  l_operation varchar2(4000);
begin
    -- bug 6772298
    if(FND_HTTP_TICKET.CHECK_ONETIME_TICKET_STRING(ticket,
                                       l_operation,
                                       l_args) )
    then
          if(l_operation is null AND opcode is null)
          then
                return l_args;
          end if;

          if(l_operation = opcode)
          then
                return l_args;
          end if;
    end if;

    return null;
end;
/*--------------------------------------------------------------------------*/
/*
 * Get -
 *   This procedure processes a download request
 *   If purge is specified, then the row is deleted immediately
 */
PROCEDURE get(p_path varchar2)  is
  doc  blob;
  l_file_id   number;
  access number;
  bool boolean;
  prog_name varchar2(30);
  exp_date date;
  p_purge_on_view varchar2(1) := 'N';
  l_module_source varchar2(256);
begin
  l_module_source := 'FND_GFM.GET';

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Begin');
  end if;

  bool := icx_sec.validatesession();
  access := substr(p_path,instr(p_path,'/',1)+1,instr(p_path,'/',2)-2);
  l_file_id := substr(p_path,instr(p_path,'/',2)+1,(instr(p_path,'/',-1)-instr(p_path,'/',2)-1));

  if (fnd_gfm.authenticate(access, l_file_id) = FALSE) then
    htp.p(Fnd_Message.Get_String('PAY','HR_51401_WEB_NOT_AUTHORIZED'));
  else

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Downloading file_id '||to_char(l_file_id));
    end if;

    fnd_gfm.download_blob(l_file_id);

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Done downloading file.  Determine if this was an export that needs to be purged');
    end if;

    select lower(program_name),expiration_date
    into prog_name, exp_date
    from fnd_lobs
    where file_id = l_file_id;

    if (prog_name = 'export' and exp_date is not null) then
        fnd_profile.get('FND_EXPORT_PURGE_ON_VIEW',p_purge_on_view);

       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Export - purge on view: '||p_purge_on_view);
       end if;

       if (p_purge_on_view = 'Y') then
           if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Deleting lob');
            end if;

           fnd_gfm.delete_lob(l_file_id);
       end if;
    end if;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'End');
  end if;

exception
  when others then
    fnd_gfm.err_msg('get');
    raise;
end get;
/*--------------------------------------------------------------------------*/
/*
 *   copy_lob - This function copies one lob to another
 *   Returns the file_id of the new lob.
 */
FUNCTION copy_lob(fid_from number) return number is
  fid_to    number;
  fnd_usr_rec fnd_user%ROWTYPE;
  fnd_lobs_rec fnd_lobs%ROWTYPE;
begin

  SELECT fnd_lobs_s.nextval
  INTO fid_to
  FROM dual;

  SELECT file_id,
         file_name,
         file_content_type,
         upload_date,
         expiration_date,
         program_name,
         program_tag,
         file_data,
         language,
         oracle_charset,
         file_format
  INTO fnd_lobs_rec.file_id,
       fnd_lobs_rec.file_name,
       fnd_lobs_rec.file_content_type,
       fnd_lobs_rec.upload_date,
       fnd_lobs_rec.expiration_date,
       fnd_lobs_rec.program_name,
       fnd_lobs_rec.program_tag,
       fnd_lobs_rec.file_data,
       fnd_lobs_rec.language,
       fnd_lobs_rec.oracle_charset,
       fnd_lobs_rec.file_format
  FROM fnd_lobs
  WHERE file_id = fid_from;

  INSERT INTO fnd_lobs (file_id,
                        file_name,
                        file_content_type,
                        upload_date,
                        expiration_date,
                        program_name,
                        program_tag,
                        file_data,
                        language,
                        oracle_charset,
                        file_format)
  VALUES  (fid_to,
           fnd_lobs_rec.file_name,
           fnd_lobs_rec.file_content_type,
           fnd_lobs_rec.upload_date,
           fnd_lobs_rec.expiration_date,
           fnd_lobs_rec.program_name,
           fnd_lobs_rec.program_tag,
           fnd_lobs_rec.file_data,
           fnd_lobs_rec.language,
           fnd_lobs_rec.oracle_charset,
           fnd_lobs_rec.file_format);

  return fid_to;

exception
  when others then
    fnd_gfm.err_msg('copy_lob');
    raise;
end copy_lob;
/*--------------------------------------------------------------------------*/
/*
 *   set_file_format - This function sets the file_format for fnd_lobs CTX
 *   Returns file_format derived from file_content_type in fnd_lobs.
 */
FUNCTION set_file_format(l_file_content_type VARCHAR2) RETURN VARCHAR2 IS
l_semicol_exists    number;
l_mime_type         varchar2(256);
l_file_format       varchar2(10);

BEGIN
 -- Check l_file_content_type for a ;
 l_semicol_exists := instrb(l_file_content_type, ';', 1, 1);

 IF substr(l_file_content_type, 1, 5) = 'text/' THEN
   return('TEXT');
 ELSIF l_semicol_exists > 0 THEN
         l_mime_type := substr(l_file_content_type, 1, l_semicol_exists-1);
 ELSIF l_semicol_exists = 0 THEN
   l_mime_type := l_file_content_type;
 ELSE
   return('IGNORE');
 END IF;

 -- Bug 9276419 - Added distinct to this query since duplicate mime_types may
 -- exist as the unique index has been altered to now include file_ext
 -- i.e (mime_type,file_ext)

 SELECT distinct ctx_format_code
 INTO l_file_format
 FROM fnd_mime_types
 WHERE mime_type = l_mime_type;

 return(l_file_format);

 exception
 when others then
   return('IGNORE');

END set_file_format;
/*--------------------------------------------------------------------------*/
/*
 *   clob_to_blob This function takes my_clob which can be a varchar2, long,
 *   or clob and creates a file in fnd_lobs.  It will create a file id if none
 *   is passed in.  file_name will need an extension.
 */

PROCEDURE CLOB_TO_BLOB (
    my_clob           clob,
    file_name         varchar2,
    fid               in out nocopy number,
    file_content_type varchar2 default null,
    language          varchar2 default null,
    x_return_status OUT   NOCOPY Varchar2,
    x_msg_count     OUT   NOCOPY Number,
    x_msg_data      OUT   NOCOPY Varchar2
                           ) IS
v_InputOffset      BINARY_INTEGER;
v_LOBLength        BINARY_INTEGER;
v_CurrentChunkSize BINARY_INTEGER;
v_ChunkSize        NUMBER := 10000;
varbuf             VARCHAR2(32767);
l_blob_loc         blob;
v_content_type     varchar2(100);
v_language         varchar2(20);
retval             INTEGER;
G_EXC_ERROR        EXCEPTION;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  if file_name is null then
    fnd_message.set_name('FND','GR_FILE_DATA_NULL');
    raise G_EXC_ERROR;
  end if;

  if fid is null then
    select fnd_lobs_s.nextval into fid from dual;
  end if;

  if file_content_type is null then
    v_content_type := 'text/plain';
  else
    v_content_type := file_content_type;
  end if;

  if language is null then
     v_language := userenv('LANG');
  else
     v_language := language;
  end if;

    INSERT INTO fnd_lobs (
       file_id,
       file_name,
       file_content_type,
       upload_date,
       expiration_date,
       program_name,
       program_tag,
       file_data,
       language,
       oracle_charset,
       file_format )
     VALUES (
       fid,
       file_name,
       v_content_type,
       sysdate,
       null,
       'FNDAPI',
       null,
       empty_blob(),
       v_language,
       fnd_gfm.iana_to_oracle(fnd_gfm.get_iso_charset),
       fnd_gfm.set_file_format(v_content_type));

select file_data into l_blob_loc from fnd_lobs
where file_id = fid;


DBMS_LOB.OPEN (l_blob_loc, DBMS_LOB.LOB_READWRITE);

-- First determine the input LOB length.
v_LOBLength := DBMS_LOB.GETLENGTH(my_clob);

-- Set up the initial offsets.  The input offset starts at the
-- beginning, the output offset at the end.
v_InputOffset := 1;

  -- Loop through the input LOB, and write each chunk to the output
  -- LOB.
  LOOP
    -- Exit the loop when we've done all the chunks, indicated by
    -- v_InputOffset passing v_LOBLength.
    EXIT WHEN v_InputOffset > v_LOBLength;
    -- If at least v_ChunkSize remains in the input LOB, copy that
    -- much.  Otherwise, copy only however much remains.
      IF (v_LOBLength - v_InputOffset + 1) > v_ChunkSize THEN
           v_CurrentChunkSize := v_ChunkSize;
      ELSE
           v_CurrentChunkSize := v_LOBLength - v_InputOffset + 1;
      END IF;

      dbms_lob.read(my_clob, v_CurrentChunkSize, v_InputOffset, varbuf);

      -- Write the current chunk.
      DBMS_LOB.writeappend(l_blob_loc, lengthb(varbuf), UTL_RAW.cast_to_raw(varbuf));

      -- Increment the input offset by the current chunk size.
      v_InputOffset := v_InputOffset + v_CurrentChunkSize;
  END LOOP;

DBMS_LOB.CLOSE(l_blob_loc);
--return x_return_status;

exception
   when G_EXC_ERROR  then
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data => x_msg_data);
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    fnd_msg_pub.count_and_get(p_count => x_msg_count,
                              p_data => x_msg_data);

    END clob_to_blob;
/*--------------------------------------------------------------------------*/

/*
 * delete_lob - this api deletes a lob in fnd_lobs using file_id.
 *
*/
PROCEDURE DELETE_LOB (fid number) IS

l_module varchar2(30) := 'fnd_gfm.delete_lob';
l_lob_cnt number;

BEGIN
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Begin - file_id passed: '||fid);
  end if;

   select count(1) into l_lob_cnt from fnd_lobs where file_id = fid;

  if (l_lob_cnt > 0) then
     if (verify_orphaned_lob(fid)) then
         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'This LOB appears to be orphaned - now deleting' );
        end if;
        delete from fnd_lobs where file_id = fid;
     else
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Parent document found or unknown file type - not deleting lob' );
            fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Verify data and call API with force=Y to force purge' );
        end if;
     end if;
  else
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'LOB does not exist - do nothing');
     end if;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'End');
  end if;
commit;
exception
  when others then
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_EXCEPTION,l_module,'In delete_lob exception');
    end if;
    fnd_gfm.err_msg('delete_lob');
    raise;
END delete_lob;


/*--------------------------------------------------------------------------*/

/*
 * delete_lob - this api deletes a lob in fnd_lobs using file_id.
 *
*/
PROCEDURE DELETE_LOB (fid number, force varchar2) IS

l_module varchar2(30) := 'fnd_gfm.delete_lob';
BEGIN
  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Begin - file_id passed: '||fid);
  end if;

  if (force='Y') then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Force deletion of lob - no check performed - deleting lob' );
     end if;
     delete from fnd_lobs where file_id = fid;
  else
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Force=N - will confirm this LOB is not an orphaned document before deleting');
     end if;
         DELETE_LOB(fid => fid);
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'End');
  end if;
commit;
exception
  when others then
    if (fnd_log.LEVEL_EXCEPTION >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_EXCEPTION,l_module,'In delete_lob exception');
    end if;
    fnd_gfm.err_msg('delete_lob');
    raise;
END delete_lob;

-----------------------------------------------------------------------------------
/* Additional args:
 * authenticate
 * user_name
 * lifespan
 */
FUNCTION construct_download_url(gfm_agent     varchar2,
                                file_id       number,
                                purge_on_view boolean default FALSE,
                                modplsql      boolean default FALSE,
                                authenticate  boolean,
                                user_name     varchar2 default NULL,
                                lifespan      number  default NULL)
 return varchar2 is

begin

  -- Bug 28772297: pass authenticate, user_name and lifespan
   return construct_download_url2(gfm_agent,file_id,purge_on_view,FALSE,authenticate,user_name,lifespan);
exception
  when others then
    fnd_gfm.err_msg('construct_download_url');
    raise;
end;

/*--------------------------------------------------------------------------*/

FUNCTION construct_download_url(gfm_agent     varchar2,
                                file_id       number,
                                purge_on_view boolean default FALSE)
         return varchar2 is
l_gfmauth varchar2(10);
l_module_source varchar2(80) :=  'FND_GFM.CONSTRUCT_DOWNLOAD_URL';
begin
 l_gfmauth := nvl(fnd_preference.get('#INTERNAL','FNDGFM','FILE_DOWNLOAD_AUTH'),'Y');

if (l_gfmauth = 'N') then
    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Get auth preference - override default? '||l_gfmauth);
   end if;

  -- Bug 28772297: pass authenticate
   return construct_download_url(gfm_agent => gfm_agent,
                                 file_id => file_id,
                                 purge_on_view => purge_on_view,
                                 authenticate => FALSE);
else
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Default to authenticate');
  end if;

  return construct_download_url(gfm_agent => gfm_agent,
                                 file_id => file_id,
                                 purge_on_view => purge_on_view,
                                 authenticate => TRUE);
end if;
exception
  when others then
    fnd_gfm.err_msg('construct_download_url');
    raise;
end;

------------------------------------------------------------------------------

/*
 *  setRelease - returnes the current major release
 *
 */
FUNCTION setRelease
return number is
begin

/* Bug 9860032 - release should not be based on this function definition
 * Backporting the R12 JAVA File Upload requires this to be changed.
 * Now using FND_RELEASE.  Removed exception as it is no longer needed.
 *
 * Please see bug and previous version for details
 *
*/

   return fnd_release.major_version;


end;


------------------------------------------------------------------------------

/*
 *  getRelease - returns the current major release
 *
 */
FUNCTION getRelease
return number is
begin
   if (g_release_version = 0) then
      --call the SetRelease for the first time
      g_release_version := setRelease;
   end if;

   return g_release_version;
exception
  when others then
    fnd_gfm.err_msg('getRelease');
    raise;
end;


------------------------------------------------------------------------------

/* verify_file_type - returns whether a file type is allowed to be uploaded into
 *   fnd_lobs
 *   return Y=do not retrict this filetype
 *   return N=restrict this filetype
 */
FUNCTION verify_file_type (file_name varchar2, file_ext varchar2)
return varchar2 is
 l_module_source varchar2(256);
 l_allow varchar2(1);
 l_cnt number;
 l_file_ext varchar2(10);
 l_dflt_allow varchar2(1);
 l_ext_pos number;
 l_file_name varchar2(256);

 begin

  l_module_source := 'FND_GFM.VERIFY_FILE_TYPE';
  l_file_ext  := trim(file_ext);
  l_file_ext  := trim('.' from l_file_ext);
  l_file_name := trim(file_name);

  if (fnd_log.level_statement >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'Begin - file_name is: '||file_name||' file_ext is: '||file_ext);
  end if;

  l_dflt_allow := fnd_profile.value('FND_SECURITY_FILETYPE_RESTRICT_DFLT');

  if (fnd_log.level_statement >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'Profile value is: '||nvl(l_dflt_allow,'Profile not set'));
  end if;


  if (l_dflt_allow is null) then

     -- Profile not defined default to allow
      l_dflt_allow := 'Y';

     if (fnd_log.level_statement >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'Profile value is null...default to Y');
     end if;

  end if;

  if (l_file_ext is null and l_file_name is null) then
      return l_dflt_allow;
  elsif (l_file_ext is null and l_file_name is not null) then
      l_ext_pos := instr(l_file_name,'.',-1);

      if (fnd_log.level_statement >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_Log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'extension position is: '||l_ext_pos);
      end if;

      if (l_ext_pos > 0) then
         l_file_ext := trim(substr(l_file_name,instr(l_file_name,'.',-1)+1));

         if (fnd_log.level_statement >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_Log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'Got extension from filename - '||l_file_ext);
      end if;
      else
         l_file_ext := 'null';

        if (fnd_log.level_statement >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_Log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'No file extension - default extension to null');
        end if;

      end if;
  end if;

       if (fnd_log.level_statement >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'file extension is: '||l_file_ext);
       end if;

       select count(distinct(upper(allow_file_upload))) into l_cnt
       from fnd_mime_types where lower(file_ext) = lower(l_file_ext);

       if (l_cnt > 1) then

          if (fnd_log.level_statement >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
              fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'Same filetype exists with conflicting values - most restricted takes precedence');
          end if;

          select distinct upper(allow_file_upload) into l_allow
          from fnd_mime_types where lower(file_ext) = lower(l_file_ext)
          and upper(allow_file_upload) = 'N';

       else

          select distinct upper(allow_file_upload) into l_allow
          from fnd_mime_types where lower(file_ext) = lower(l_file_ext);

       end if;

       if (fnd_log.level_statement >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'File type: '||l_file_ext||' allowed: '||l_allow);
       end if;

       if (l_allow in ('Y','N')) then
           return l_allow;
       else

         if (fnd_log.level_statement >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
             fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'allow_file_upload is null or an invalid value...default to profile value');
         end if;

           return l_dflt_allow;

       end if;

 exception
    when no_data_found then
        if (fnd_log.level_statement >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'Default to profile value - No data found for file type: '||l_file_ext);
       end if;

       return l_dflt_allow;
    when others then
        if (fnd_log.level_statement >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module_source,'When others exception occurred');
       end if;

       fnd_gfm.err_msg('verify_file_type');
       raise;
end verify_file_type;

FUNCTION verify_orphaned_lob (fid number) return boolean
IS

l_prog_name varchar2(30);
l_doc_cnt number;
l_doc_cnt_tl number;
l_module varchar2(80) := 'fnd_gfm.verify_orphaned_lob';

begin
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Begin - verify file_id: '||fid);
    end if;

    select program_name into l_prog_name from fnd_lobs where file_id = fid;

    -- Check for Attachment documents associated with this file_id
    select count(1) into l_doc_cnt from fnd_documents where datatype_id = 6 and media_id = fid;
    select count(1) into l_doc_cnt_tl from fnd_documents fd, fnd_documents_tl fdtl
        where fd.datatype_id = 6
        and fd.document_id = fdtl.document_id
        and fdtl.media_id = fid;

    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Count fnd_documents found: '||l_doc_cnt);
        fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Count fnd_documents_tl found: '||l_doc_cnt_tl);
    end if;

    if (l_doc_cnt > 0 or l_doc_cnt_tl > 0) then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Parent found - delete parent before the lob can be deleted');
       end if;
      return false;
    elsif (l_prog_name in ('FNDATTCH','REST_Service')) then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Attachment LOB with no document record - orphaned record');
       end if;
      return true;
    end if;

    -- Check for Help documents associated with this file_id
    select count(1) into l_doc_cnt from fnd_help_documents where file_id = fid;
    if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Count FND_HELP documents found: '||l_doc_cnt);
    end if;

    if (l_doc_cnt > 0) then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Parent found - delete parent before the lob can be deleted');
       end if;
      return false;
    elsif (l_prog_name = 'FND_HELP') then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'HELP LOB with no document record - orphaned record');
       end if;
       return true;
    end if;

    -- Check for others - export is the only other known FND related data
    if (l_prog_name = 'export') then
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'export data - should be safe to  purge');
        end if;
      return true;
    else
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'Unknown file type - more analysis is required for program_name '||nvl(l_prog_name,'Null value')||' - not deleting');
      end if;
      return false;
    end if;

 exception
   when no_data_found then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'file does not exist');
     end if;
     return false;
   when others then
        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT,l_module,'In others exception');
     end if;
     return false;
END verify_orphaned_lob;

/* Bug 28772297
 * check_ticket
 *   Retrieves value given a one-time-use ticket
 *   that was generated by one_time_use_store().
 *   if opcode passed, the API verifies the opcode value
 *   against the opcode value passed in one_time_use_store.
 */
function check_ticket(ticket in varchar2 ,
                      opcode in varchar2 default null)
                     return varchar2 is
  l_args varchar2(4000);
  l_operation varchar2(4000);
  l_module_source varchar2(100) := 'FND_GFM.AUTHENTICATE';
begin

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Begin');
   end if;

   -- Use check_ticket_string instead of one_time_use_retrieve which deletes the ticket

    if(FND_HTTP_TICKET.CHECK_TICKET_STRING(ticket,
                                       l_operation,
                                       l_args) )
    then
          if(l_operation is null AND opcode is null)
          then
             if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                 fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Returning: '||l_args);
             end if;

             return l_args;
          end if;

          if(l_operation = opcode)
          then
             if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                 fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Returning: '||l_args);
             end if;

             return l_args;
          end if;
    end if;

    return 'false';
end;


end FND_GFM;

/
