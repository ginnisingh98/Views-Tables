--------------------------------------------------------
--  DDL for Package Body FND_WEBFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WEBFILE" as
  /* $Header: AFCPFILB.pls 120.7.12010000.5 2017/05/22 20:38:31 pferguso ship $ */


/*   Shared APPLTOP/APPLCSF Matrix
This matrix explains the 4 combinations of shared APPLTOP/APPLCSF and the results of setting
the FS_XFR_MODE profile option.
'FAILOVER' is the default and will be used if not set or set to any other value.

                                   APPLTOP
               Shared                                 Not shared
             -----------------------------------------------------------------------------
             | SINGLE - single alias, no bypass     | SINGLE - single alias, no bypass   |
   Shared    | FAILOVER - failover alias, no bypass | FAILOVER - single alias, no bypass |
             | NONE - failover alias, use bypass    | NONE - single alias, use bypass    |
             |                                      |                                    |
APPLCSF      |----------------------------------------------------------------------------
             | SINGLE - single alias, no bypass     | SINGLE - single alias, no bypass   |
 Not shared  | FAILOVER - do not use                | FAILOVER - single alias, no bypass |
             | NONE - do not use                    | NONE - single alias, no bypass     |
             |                                      |                                    |
             |----------------------------------------------------------------------------
*/

debug varchar2(1) := 'N';


/*--
 *-- GENERIC_ERROR (Internal)
 *--
 *-- Set error message and raise exception for unexpected sql errors.
 *--
 */
procedure GENERIC_ERROR(routine in varchar2,
  errcode in number,
  errmsg in varchar2) is
begin
   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
   fnd_message.set_token('ROUTINE', routine);
   fnd_message.set_token('ERRNO', errcode);
   fnd_message.set_token('REASON', errmsg);
end;

/*--
 *-- UPDATE SVC (Internal)
 *--
 *-- Update registered node with full service denotation (for generic services)
 *-- Created to be autonomous transaction so no commit would occur in get_url
 *--
 */
procedure UPDATE_SVC(id in number,
  svc in varchar2) is
   PRAGMA AUTONOMOUS_TRANSACTION;
begin
   update fnd_file_temp
     set node_name = svc
     where file_id = id;

   commit;
exception
   when others then
     rollback;
end update_svc;

/*
 *  Procedure:  update_cfg_info
 *     Internal use only
 *
 *  Purpose :
 *    Update registered node with full context file information
 *
 */
procedure update_cfg_info(id in number,
  dest_file in varchar2,
  dest_svc  in varchar2,
  tran_type in varchar2) is
   PRAGMA AUTONOMOUS_TRANSACTION;
begin
   update fnd_file_temp
     set destination_node = dest_svc,
     destination_file = dest_file,
     transfer_type = tran_type
     where file_id = id;

   commit;
exception
   when others then
     rollback;
end update_cfg_info;

/*
 *procedure: update_page_info
 *            is called from get_url function to update the page information(page_number and page_size column).
 *            It is an internal procedure.
 *
 *
 *
 */
procedure update_page_info(id in number,
  p_page_no in number,
  p_page_size in number,
  p_tran_type in varchar2) is
   PRAGMA AUTONOMOUS_TRANSACTION;
begin
   update fnd_file_temp
     set page_number = p_page_no,
     page_size = p_page_size,
     transfer_type = p_tran_type
     where file_id =id;

   commit;
exception
   when others then
     rollback;

end update_page_info;




/* Function: GET_URL
 *
 * Purpose: Constructs and returns the URL for a Concurrent Processing
 *          log or output file.
 *
 * Arguments:
 *  file_type - Specifies the type of file desired:
 *       fnd_webfile.process_log = The log of the concurrent process identified
 *                                 by the parameter ID.
 *       fnd_webfile.icm_log     = The log of the ICM process identified by ID.
 *                                 Or, the log of the ICM process that spawned
 *                                 the concurrent process identified by ID.
 *                                 Or, the log of the most recent ICM process
 *                                 if ID is null.
 *       fnd_webfile.request_log = The log of the request identified by ID.
 *       fnd_webfile.request_out = The output of the request identified by ID.
 *       fnd_webfile.request_mgr = The log of the concurrent process that ran
 *                                 the request identified by ID.
 *       fnd_webfile.frd_log     = The log of the forms process identified
 *                                 by ID.
 *       fnd_webfile.generic_log = The log file identified by ID.
 *       fnd_webfile.generic_trc = The trace file identified by ID.
 *       fnd_webfile.generic_ora = The ora file identified by ID.
 *       fnd_webfile.generic_cfg = The config file identified by ID.
 *       fnd_webfile.context_file= The context file identified by ID.
 *       fnd_webfile.generic_text= Generic file using text transfer mode.
 *       fnd_webfile.generic_binary = Generic file using binary transfer mode.
 *       fnd_webfile.request_xml_output = The XML output of Concurrent Request.
 *
 *  id        - A concurrent process ID, concurrent request ID, or file ID
 *                 depending on the file type specified.
 *              For fnd_webfile.context_file,fnd_webfile.generic_text,
 *              fnd_webfile.generic_binary this value is null.
 *
 *  gwyuid    - The value of the environment variable GWYUID used in
 *                 constructing the URL. No longer used.
 *
 *  two_task  - The database two_task, used in constructing the URL. No longer used.
 *
 *  expire_time - The number of minutes for which this URL will remain
 *                   valid.
 *  source_file - Source file name with full patch
 *
 *  source_node - Source node name.
 *
 *  dest_file   - Destination file name
 *
 *  dest_node   - Destination node name
 *
 *  page_no	    - Current page number
 *
 *  page_size	- Number of lines in a page
 *
 *  Returns NULL on error.  Check the FND message stack.
 *
 * Note that gwyuid and two_task are no longer used. They are retained for
 * compatibility only.
 *
 */
function get_url(  file_type  IN number,
                          id  IN number,
                      gwyuid  IN varchar2,
                    two_task  IN varchar2,
                 expire_time  IN number,
                 source_file  IN varchar2 default null,
                 source_node  IN varchar2 default null,
                   dest_file  IN varchar2 default null,
                   dest_node  IN varchar2 default null,
                     page_no  IN number   default null,
                   page_size  IN number   default null) return varchar2
is
     base            varchar2(257);
     base_type       varchar2(3) := 'CGI';
     url             varchar2(512);
     fname           varchar2(255);
     node            fnd_concurrent_processes.node_name%type;
     mtype           varchar2(80) := 'text/plain';
     x_mode          varchar2(30) := 'TEXT';
     ffcode          varchar2(30);
     fs_enabled      varchar2(2);
     temp_id         varchar2(32);
     pos             number;
     svc             varchar2(254);
     dest_svc        varchar2(254);
     t_node          fnd_oam_context_files.node_name%type;
     req_id          number;
     controlling_mgr number;
     cpid            number;
     fsize           number;
     save_out        varchar2(2);
     ext             varchar2(32);
     cmpext          varchar2(32);
     sqlstmt         varchar2(200);
     ncenc           varchar2(1) := 'N';
     prog_name       varchar2(30) := null;
     appl_name       varchar2(30) := null;
     action_publish_count  number;
begin

   /* Get URL base. */

   --First check IF there is a url base defined FOR CGI - enh# 4477258
   IF (fnd_profile.defined('APPS_CGI_AGENT')) THEN
      fnd_profile.get('APPS_CGI_AGENT', base);
   END IF;

   --IF CGI agent is null then check the web agent
   --Also set the base_type to WEB
   IF (base IS NULL) THEN
      fnd_profile.get('APPS_WEB_AGENT', base);
      base_type := 'WEB';
   END IF;

   if (base is null) then
     fnd_message.set_name('FND', 'FS-NO URL');
     return null;
   end if;


   if (file_type = process_log) then
     /* Concurrent process log */
     begin
       select logfile_name, node_name
         into fname, node
         from fnd_concurrent_processes
        where concurrent_process_id = id;
     exception
       when no_data_found then
         fnd_message.set_name('FND', 'CONC-PROCESS MISSING');
         fnd_message.set_token('ROUTINE','FND_WEBFILE.GET_URL');
         fnd_message.set_token('CPID', id);
         return null;
     end;
     if (fname is null) then
         fnd_message.set_name('FND', 'SYSTEM-MANAGER LOGFILE NULL');
         fnd_message.set_token('PROCESS_ID', id);
         return null;
     end if;

   elsif (file_type = icm_log) then
     /* ICM log */
     begin
       select logfile_name, node_name
         into fname, node
         from fnd_concurrent_processes
        where (((id is not null)
               and concurrent_process_id =
                 ( select max(p.concurrent_process_id)
                   from fnd_concurrent_processes p,
                        fnd_concurrent_processes p2
                  where p.queue_application_id = 0
                    and p.concurrent_queue_id  = 1
                    and p2.concurrent_process_id= id
                    and p.process_start_date <=
                          nvl(p2.process_start_date, sysdate) ) )
           or
              ((id is null) and concurrent_process_id =
                ( select max(p.concurrent_process_id)
                    from fnd_concurrent_processes p
                   where p.queue_application_id = 0
                     and p.concurrent_queue_id  = 1 ) ));
     exception
       when no_data_found then
         fnd_message.set_name('FND', 'CONC-PROCESS MISSING');
         fnd_message.set_token('ROUTINE','FND_WEBFILE.GET_URL');
         fnd_message.set_token('CPID', id);
         return null;
     end;
     if (fname is null) then
         fnd_message.set_name('FND', 'SYSTEM-MANAGER LOGFILE NULL');
         fnd_message.set_token('PROCESS_ID', id);
         return null;
     end if;

   elsif (file_type = request_log) then
     /* Request Log */

--Fix for bug 9244546
-- Enabling Native Client Encoding for Request Log
-- MBURRA
   ncenc := 'Y';

     begin
       select logfile_name, logfile_node_name
         into fname, node
         from fnd_concurrent_requests
        where request_id = id;
        req_id := id;
     exception
       when no_data_found then
         fnd_message.set_name('FND', 'CONC-REQUEST MISSING');
         fnd_message.set_token('ROUTINE','FND_WEBFILE.GET_URL');
         fnd_message.set_token('REQUEST', id);
         return null;
     end;
     if (fname is null) then
         fnd_message.set_name('FND', 'SYSTEM-REQUEST LOGFILE NULL');
         fnd_message.set_token('REQUEST_ID', id);
         return null;
     end if;

   elsif (file_type = request_out or file_type = request_xml_output) then
     /* Request Output */
     ncenc := 'Y';
     begin
       select fcr.outfile_name, fcr.outfile_node_name, fmt.mime_type,
              fcr.save_output_flag, fcr.ofile_size, fmt.file_format_code,
              fcp.concurrent_program_name, a.application_short_name
         into fname, node, mtype, save_out, fsize, ffcode, prog_name,appl_name
         from fnd_concurrent_requests fcr, fnd_mime_types_vl fmt,
              fnd_concurrent_programs fcp, fnd_application a
        where fcr.request_id = id
          and upper(fcr.output_file_type) = upper(fmt.file_format_code)
          and fcp.concurrent_program_id = fcr.concurrent_program_id
          and fcp.application_id = fcr.program_application_id
          and fcp.application_id = a.application_id
          and rownum = 1;

          /* Bug 6040814. Supporting output file display for FNDREPRINT (REPRINT and REPULISH) programs.
          *  First check whether the program is a FNDREPRINT program.
          *  1) YES - case a. whether it is a REPRINT and REPUBLISH - check for output details in fnd_conc_req_outputs
          *           case b. Only REPRINT
          *                 Check whether the parent program supports republish
          *                 1) YES - Check for output details in fnd_conc_req_outputs which request id as parent request id.
          *                 2) NO - Check for output details in fnd_concurrent_requests with REPRINT request id.
          *  2) NO (NOT FNDREPRINT)
          *         case a. If the program is layout enabled - check for output details in fnd_conc_req_outputs
          *         case b. Check for the output details in fnd_concurrent_requests as already done in the above sql.
          */

        /* Check whether the program is a FNDREPRINT program */
        if (prog_name = 'FNDREPRINT' and appl_name ='FND') then

               select count(1) into action_publish_count from fnd_conc_pp_actions
               where concurrent_request_id=id and action_type=6;

               if(action_publish_count=1) then /* Check if it is a REPRINT and REPUBLISH request */
                   begin
                      select file_type,file_name,file_node_name,file_size, fmt.mime_type
                        into ffcode, fname, node, fsize, mtype
                        from fnd_conc_req_outputs RO, fnd_mime_types_vl fmt
                       where concurrent_request_id = id
                         and RO.file_type = fmt.file_format_code
                         and rownum = 1;
                   exception
                         when no_data_found then
                            fnd_message.set_name('FND', 'CONC-NO OUTPUT FILE');
                            fnd_message.set_token('REQUEST_ID', id);
                            return null;
                   end;
               else /* Only a REPRINT request */
                   begin
                      /* Find the parent program for the REPRINT request */
                      select fcp.concurrent_program_name, a.application_short_name
                        into prog_name, appl_name
                        from fnd_concurrent_programs fcp, fnd_application a, fnd_concurrent_requests fcr
                      where fcp.concurrent_program_id = fcr.concurrent_program_id
                        and fcp.application_id = fcr.program_application_id
                        and fcp.application_id = a.application_id
                        and fcr.request_id = (select to_number(argument1) from fnd_concurrent_requests where request_id=id);
                    exception
                       when no_data_found then
                         fnd_message.set_name('FND', 'CONC-REQUEST MISSING');
                         fnd_message.set_token('ROUTINE','FND_WEBFILE.GET_URL');
                         fnd_message.set_token('REQUEST', id);
                         return null;
                     end;

                    /* Check if the parent program is layout enabled */
                    if (fnd_conc_sswa.layout_enabled(appl_name, prog_name)) then
                       begin
                         select file_type,file_name,file_node_name,file_size, fmt.mime_type
                          into ffcode, fname, node, fsize, mtype
                          from fnd_conc_req_outputs RO, fnd_mime_types_vl fmt
                         where concurrent_request_id = (select to_number(argument1) from fnd_concurrent_requests where request_id=id)
                          and RO.file_type = fmt.file_format_code
                          and rownum = 1;
                       exception
                        when no_data_found then
                            fnd_message.set_name('FND', 'CONC-NO OUTPUT FILE');
                            fnd_message.set_token('REQUEST_ID', id);
                            return null;
                       end;
                    else /* Parent program is not layout enabled*/
                       begin
                          select output_file_type, outfile_name, outfile_node_name, ofile_size, fmt.mime_type
                            into ffcode, fname, node, fsize, mtype
                          from fnd_concurrent_requests fcr, fnd_mime_types_vl fmt
                          where request_id = id
                            and fcr.output_file_type = fmt.file_format_code
                            and rownum = 1;
                       exception
                          when no_data_found then
                            fnd_message.set_name('FND', 'CONC-NO OUTPUT FILE');
                            fnd_message.set_token('REQUEST_ID', id);
                            return null;
                       end;
                    end if;
               end if;
        elsif(fnd_conc_sswa.layout_enabled(appl_name, prog_name) and file_type=request_out) then /* Not a FNDREPRINT request */
              begin
              select file_type,file_name,file_node_name,file_size, fmt.mime_type
                into ffcode, fname, node, fsize, mtype
                from fnd_conc_req_outputs RO, fnd_mime_types_vl fmt
               where concurrent_request_id = id
                 and RO.file_type = fmt.file_format_code
                 and rownum = 1;
              exception
                 when no_data_found then
                    fnd_message.set_name('FND', 'CONC-NO OUTPUT FILE');
                    fnd_message.set_token('REQUEST_ID', id);
                    return null;
              end;
        end if;

         req_id := id;
     exception
       when no_data_found then
         fnd_message.set_name('FND', 'CONC-REQUEST MISSING');
         fnd_message.set_token('ROUTINE','FND_WEBFILE.GET_URL');
         fnd_message.set_token('REQUEST', id);
         return null;
     end;
     if (save_out = 'N') then
       fnd_message.set_name('FND', 'CONC-Output file not saved');
       return null;
     end if;
     if (fname is null) then
         fnd_message.set_name('FND', 'SYSTEM-REQUEST OUTFILE NULL');
         fnd_message.set_token('REQUEST_ID', id);
         return null;
     end if;

     /* Decide the transfer mode, after getting the fnd_file_format datamodal
    we have to replace these hardcoded values */
     if ( upper(ffcode) in ('PDF','PS','PCL','EXCEL')) then
    x_mode := 'BINARY';
     end if;

   elsif (file_type = request_mgr) then
     begin
       select p.logfile_name, p.node_name, r.controlling_manager,
              p.concurrent_process_id
         into fname, node, controlling_mgr, cpid
         from fnd_concurrent_requests r, fnd_concurrent_processes p
        where r.request_id = id
          and r.controlling_manager = p.concurrent_process_id(+);
       /* The outer join makes sure that we don't say that the request
          row is missing, when the manager row is missing.  We know that
          the manager row was missing if cpid is null. */
     exception
       when no_data_found then
         fnd_message.set_name('FND', 'CONC-REQUEST MISSING');
         fnd_message.set_token('ROUTINE','FND_WEBFILE.GET_URL');
         fnd_message.set_token('REQUEST', id);
         return null;
     end;
     if (cpid is null) then
         fnd_message.set_name('FND', 'CONC-PROCESS MISSING');
         fnd_message.set_token('ROUTINE','FND_WEBFILE.GET_URL');
         fnd_message.set_token('CPID', controlling_mgr);
         return null;
     end if;
     if (fname is null) then
         fnd_message.set_name('FND', 'SYSTEM-MANAGER LOGFILE NULL');
         fnd_message.set_token('PROCESS_ID', cpid);
         return null;
     end if;

   elsif (file_type = frd_log) then
     begin
    sqlstmt := 'select node from fnd_oam_forms_rti where rti_id = :id';
    EXECUTE IMMEDIATE sqlstmt INTO node USING id;

    sqlstmt := 'select filename from fnd_oam_frd_log where rti_id = :id';
    EXECUTE IMMEDIATE sqlstmt INTO fname USING id;

     exception
       when no_data_found then
         fnd_message.set_name('FND', 'CONC-ROW MISSING');
         return null;

     end;
     if (fname is null) then
         fnd_message.set_name('FND', 'SYSTEM-LOGFILE NULL');
         return null;
     end if;

   elsif (file_type >= generic_log and file_type <= generic_cfg) then
     begin
    select filename, node_name
      into fname, node
      from fnd_file_temp
     where file_id = id;

    pos := instr(fname, '.', -1, 1);
    ext := substr(fname, (pos + 1));

     exception
       when no_data_found then
         fnd_message.set_name('FND', 'CONC-ROW MISSING');
         return null;
     end;
     if (fname is null) then
         fnd_message.set_name('FND', 'SYSTEM-LOGFILE NULL');
         return null;
     end if;

     if(file_type = generic_log) then
    cmpext := 'LOG';
     elsif (file_type = generic_trc) then
    cmpext := 'TRC';
     elsif (file_type = generic_ora) then
    cmpext := 'ORA';
     elsif (file_type = generic_cfg) then
    cmpext := 'CFG';
     end if;

     if (upper(ext) <> cmpext) then
         fnd_message.set_name('FND', 'CONC-BAD EXTENSION');
         return null;
     end if;

   elsif ( file_type in (context_file, generic_text, generic_binary) ) then
     if ( file_type = context_file ) then
      begin
         select node_name into t_node
           from fnd_oam_context_files
          where path = dest_file
            and node_name = dest_node
            and rownum = 1;
      exception
         when no_data_found then
            fnd_message.set_name('FND', 'CONC-ROW MISSING');
            return null;
      end;
     end if;

      node := source_node;
      fname := source_file;

      if (fnd_profile.defined('FS_SVC_PREFIX')) then
        fnd_profile.get('FS_SVC_PREFIX', dest_svc);
        if (dest_svc is not null) then
          dest_svc := substr(dest_svc || dest_node, 1, 254);
        else
          dest_svc := 'FNDFS_' || dest_node;
        end if;
      else
        dest_svc := 'FNDFS_' || dest_node;
      end if;

   end if;


   if (fnd_profile.defined('FS_SVC_PREFIX')) then
     fnd_profile.get('FS_SVC_PREFIX', svc);
     if (svc is not null) then
       svc := substr(svc || node, 1, 254);
     else
       svc := 'FNDFS_' || node;
     end if;
   else
     svc := 'FNDFS_' || node;
   end if;

   if (file_type >= generic_log and file_type <= generic_cfg) then
       temp_id := id;
    update_svc(id, svc);
   else
      if ( file_type = generic_binary ) then
         x_mode := 'BINARY';
      end if;

      temp_id := fnd_webfile.create_id(fname,
                                       svc,
                                       expire_time,
                                       mtype,
                                       req_id,
                                       x_mode,
                                       ncenc);
   end if;

   -- finally update destination file and node name, transfer_type
   if ( file_type in ( context_file, generic_text, generic_binary) ) then
      update_cfg_info(temp_id, dest_file, dest_svc, 'W');
   end if;

   --It updates the page information. That is page size and page number.It is required to enance a functionallity for
   --viewing output/log file(only text file) page by page.
   IF ((page_no IS NOT null) and (page_size IS NOT null)) THEN
      if(x_mode = 'TEXT') THEN
         update_page_info(temp_id, page_no, page_size, 'P');
      end if;
   end if;

   base := Ltrim(Rtrim(base));

   IF (base_type = 'WEB') THEN
      -- Strip any file path from the base URL by truncating at the
      -- third '/'.
      -- This leaves us with something like 'http://ap363sun:8000'.
      pos := instr(base, '/', 1, 3);
      if (pos > 0) then
         base := substr(base, 1, pos - 1);
      end if;
      -- 2638328 - security violation - removing login information from URL
      url := base || '/OA_CGI/FNDWRR.exe?' || 'temp_id=' || temp_id;
   ELSIF (base_type = 'CGI') THEN
      IF (substr(base, length(base)) <> '/') THEN
         base := base || '/';
      END IF;
      url := base || 'FNDWRR.exe?' || 'temp_id=' || temp_id;
   END IF;

   RETURN url;

exception
   when others then
      generic_error('fnd_webfile.get_url', SQLCODE, SQLERRM);
      return null;
end get_url;








/* Function: get_req_log_urls
 *
 * Purpose: Constructs and returns the URLs for a concurrent request log
 *          and the log of the manager that ran the request..
 *
 * Arguments:
 *  request_id  - Desired request_id.
 *
 *  gwyuid    - The value of the environment variable GWYUID used in
 *                 constructing the URL.
 *
 *  two_task  - The database two_task, used in constructing the URL.
 *
 *  expire_time - The number of minutes for which this URL will remain
 *                valid.
 *
 *  req_log - Output URL for the request log.
 *
 *  mgr_log - Output URL for the manager log.
 *
 *  Returns FALSE on error.  Check the FND message stack.
 */

function get_req_log_urls( request_id IN  number,
                               gwyuid IN  varchar2,
                             two_task IN  varchar2,
                          expire_time IN  number,
                              req_log IN OUT NOCOPY varchar2,
                              mgr_log IN OUT NOCOPY varchar2) return boolean is
begin
  req_log := get_url(request_log, request_id, gwyuid, two_task, expire_time);
  mgr_log := get_url(request_mgr, request_id, gwyuid, two_task, expire_time);

  if (req_log is not null and mgr_log is not null) then
    return true;
  else
    return false;
  end if;
end get_req_log_urls;



function create_id(     name     IN varchar2,
                        node     IN varchar2,
                        lifetime IN number   default 10,
                        type     IN varchar2 default 'text/plain',
                        req_id   IN number   default 0,
                        x_mode   IN varchar2 default 'TEXT',
                        ncenc    IN varchar2 default 'N') return varchar2
is
PRAGMA AUTONOMOUS_TRANSACTION;
my_file_id  varchar2(32);
fuid        number;
frand       number;
collision   number;
nc_encoding varchar2(240) := NULL;
allow_enc   varchar2(1);
fs_prefix   varchar2(254) := NULL;
nmptr       number;
svc         varchar2(254) := NULL;
ftype       fnd_concurrent_requests.output_file_type%TYPE := NULL;
fs_mode     varchar2(254) := NULL;
xfr_mode    varchar2(30)  := x_mode;

begin

   collision := 1;
   while (collision > 0) loop
      my_file_id := fnd_concurrent_file.get_file_id;

      select count(*)
        into collision
        from fnd_file_temp T
        where T.file_id = my_file_id;
   end loop;


   if (ncenc = 'Y') then

      if (req_id <> 0) then
        begin
           select upper(output_file_type)
             into ftype
             from fnd_concurrent_requests
            where request_id = req_id;
        exception
         when others then
           null;
        end;
      end if;

      begin
         select allow_client_encoding
           into allow_enc
           from fnd_mime_types_vl
           where mime_type = type
             and ((ftype is not null and upper(file_format_code) = ftype)
              or (ftype is null and rownum = 1));
      exception
         when others then
           allow_enc := 'N';
      end;

      if allow_enc = 'Y' then
         fnd_profile.get('FND_NATIVE_CLIENT_ENCODING', nc_encoding);
         if (nc_encoding is null) then
            fnd_message.set_name('CONC', 'CONC-Cannot get profile value');
            fnd_message.set_token('ROUTINE', 'CREATE_ID');
            fnd_message.set_token('PROFILE', 'FND_NATIVE_CLIENT_ENCODING');
            fnd_message.set_token('REASON', 'Check if profile is set');
         end if;
      end if;
   end if;


   if (fnd_profile.defined('FS_XFR_MODE')) then
     fnd_profile.get('FS_XFR_MODE', fs_mode);
   end if;

   fs_mode := upper(fs_mode);

-- If the profile option is set to SINGLE, just use the single-node alias
  if (fs_mode = 'SINGLE') then
    svc := node;

-- If the profile is not set, or set to any other value this indicates that APPLCSF is shared.
-- Try to get a failover TNS alias. If unsuccessful, use the single-node alias
   else


     if (fnd_profile.defined('FS_SVC_PREFIX')) then
       fnd_profile.get('FS_SVC_PREFIX', fs_prefix);
     end if;

     if (fs_prefix is null) then
	fs_prefix := 'FNDFS_';
     end if;

    -- If prefix already attached - switch node and reattach later
     if (node LIKE (fs_prefix || '%'))  then
	nmptr := length(fs_prefix) + 1;
     else -- No prefix, only switch node
	nmptr := 1;
	fs_prefix := NULL;
     end if;

    begin
      select substr(fs_prefix || 'APPLTOP_' || b.name, 1, 254)
       into svc
       from fnd_nodes n, fnd_appl_tops a, fnd_appl_tops b
      where n.node_name = substr(node, nmptr, length(node))
        and n.node_id = a.node_id
        and a.name = b.name
        and b.node_id <> a.node_id
        and ROWNUM = 1;

    exception when NO_DATA_FOUND then
      svc := node;
    end;


  end if;


-- Now, if the profile is set to NONE, indicate to FNDWRR to try to bypass FNDFS completely
-- and read the file directly. We still pass an alias so that FNDWRR can fall back to using it
-- if it cannot find the file.
  if (fs_mode = 'NONE' ) then
    xfr_mode := 'L' || xfr_mode;
  end if;


   insert into fnd_file_temp(  file_id,
                               filename,
                               node_name,
                               mime_type,
                               request_id,
                               expires,
                               transfer_mode,
                               native_client_encoding,
			       enable_logging)
    values (my_file_id, name, svc, type, req_id,
            sysdate + (lifetime/1440), xfr_mode, nc_encoding,
	     debug);
    commit;

    return my_file_id;

exception
    when OTHERS then
      generic_error('fnd_webfile.create_id', SQLCODE, SQLERRM);
      rollback;
      return null;

end create_id;


procedure set_debug(dbg IN boolean) IS
begin
   if dbg then
      debug := 'Y';
   else
      debug := 'N';
   end if;

end set_debug;



end;

/
