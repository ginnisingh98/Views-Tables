--------------------------------------------------------
--  DDL for Package Body FND_CONC_MAINTAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_MAINTAIN" as
/* $Header: AFCPMNTB.pls 120.2.12010000.4 2015/01/23 20:32:20 ckclark ship $ */

  C_PKG_NAME 	CONSTANT VARCHAR2(30) := 'FND_CONC_MAINTAIN';
  C_LOG_HEAD 	CONSTANT VARCHAR2(30) := 'fnd.plsql.FND_CONC_MAINTAIN.';

  G_ALREADY_INITED       varchar2(1)  := 'N';

/* APPS_INITIALIZE_FOR_MGR-
**   Initialize the application context (userid, respid, etc) if it hasn't
**   already been set.  This will point to a special user APPSMGR which
**   is used for running requests to maintain the data.
**   This should be called before submitting requests in places like loaders
**   where there is no user signed in.
*/
PROCEDURE apps_initialize_for_mgr
  IS
     l_api_name     CONSTANT VARCHAR2(30) := 'APPS_INITIALIZE_FOR_MGR';
     l_user_id      NUMBER := 5; /* Hardcoded userid of APPSMGR */
     l_resp_id      NUMBER := fnd_global.resp_id;
     l_resp_appl_id NUMBER := fnd_global.resp_appl_id;
BEGIN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name);
   end if;

   if ((G_ALREADY_INITED = 'Y') AND (fnd_global.user_id = l_user_id)) then
     if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end_quick',
          c_pkg_name || '.' ||l_api_name|| 'Already inited so no work.');
     end if;
     return;
   end if;
   --
   -- Set the Apps Context to APPSMGR user (a special user for this purpose)
   -- and the System Administrator Resp.
   --
   begin
      SELECT r.application_id, r.responsibility_id
	INTO l_resp_appl_id, l_resp_id
	FROM fnd_application a, fnd_responsibility r
	WHERE r.application_id = a.application_id
	AND a.application_short_name = 'SYSADMIN'
	AND r.responsibility_key = 'SYSTEM_ADMINISTRATOR';
   exception
     when others then
     /* If there is any problem with the SQL, just use the seeded resp id*/
     l_resp_appl_id := 1;
     l_resp_id := 20420;
   end;

   fnd_global.apps_initialize(user_id      => l_user_id,
				 resp_id      => l_resp_id,
				 resp_appl_id => l_resp_appl_id);

    g_already_inited := 'Y';
      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,
          c_log_head || l_api_name || '.',
          'We set Apps Context to ' ||
          '(user_id=' || l_user_id ||
          ', resp_id=' || l_resp_id ||
          ', resp_appl_id=' || l_resp_appl_id || ')'
         );
      end if;

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
   fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          c_pkg_name || '.' ||l_api_name|| ' Returning');
   end if;
END apps_initialize_for_mgr;

/*
** GET_PENDING_REQUEST_ID-
** Returns zero if the request ID isn't pending right away.
*/
FUNCTION get_pending_request_id
  (p_application_short_name  IN VARCHAR2,
   p_concurrent_program_name IN VARCHAR2)
RETURN number
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'GET_PENDING_REQUEST_ID';
   l_request_id NUMBER;
BEGIN
       if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.begin',
          c_pkg_name || '.' ||l_api_name ||'( p_application_short_name:'||
          p_application_short_name || ' p_concurrent_program_name:'||
          p_concurrent_program_name ||')');
       end if;

	SELECT request_id
	  INTO l_request_id
	  FROM fnd_concurrent_requests fcr,
	       fnd_concurrent_programs fcp,
	       fnd_application fa
	  WHERE fa.application_short_name = p_application_short_name
	  AND fcp.application_id = fa.application_id
	  AND fcp.concurrent_program_name = p_concurrent_program_name
	  AND fcr.program_application_id = fcp.application_id
	  AND fcr.concurrent_program_id  = fcp.concurrent_program_id
	  AND fcr.status_code in ('I', 'Q', 'R')
	  AND fcr.phase_code = 'P'
	  AND ROWNUM = 1;

       if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
          c_log_head || l_api_name || '.end',
          c_pkg_name || '.' ||l_api_name|| ' Returning request id:'
          ||l_request_id);
       end if;
	RETURN(l_request_id);
EXCEPTION
   WHEN OTHERS THEN
      RETURN(0);
END get_pending_request_id;







-- Procedure
--   MOVE_REQUEST_FILES
--
-- Purpose
--   Changes the location of a single request's logfile, output file or both.
--   Updates the directory only, does not change the file names.
--   Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which     - LOG, OUT or BOTH
--   reqid     - Concurrent request id
--   directory - New directory the files are located in
--   updated   - number of requests updated
--
procedure move_request_files(which     in  number,
                             reqid     in  number,
                             directory in  varchar2,
                             updated   out nocopy number) is

  sep  char := '/';
  user_id  number := fnd_global.user_id;
  login_id number := fnd_global.login_id;
begin

  -- Check for file separator
  if instr(directory, '\') > 0 then
    sep := '\';
  end if;

  -- Must use absolute path. Return unless file separator present
  if instr(directory, sep) = 0 then
     return;
  end if;

  if which = FND_CONC_MAINTAIN.LOG or which = FND_CONC_MAINTAIN.BOTH then
    update fnd_concurrent_requests
      set logfile_name = regexp_replace(logfile_name, '^.+' || sep, directory || sep),
      last_update_date = sysdate,
      last_updated_by = user_id,
      last_update_login = login_id
      where request_id = reqid
      and phase_code = 'C';

    updated := sql%rowcount;

  end if;

  if which = FND_CONC_MAINTAIN.OUT or which = FND_CONC_MAINTAIN.BOTH then
    update fnd_concurrent_requests
      set outfile_name = regexp_replace(outfile_name, '^.+' || sep, directory || sep),
      last_update_date = sysdate,
      last_updated_by = user_id,
      last_update_login = login_id
      where request_id = reqid
      and phase_code = 'C';

    updated := sql%rowcount;

    update fnd_conc_req_outputs
      set file_name = regexp_replace(file_name, '^.+' || sep, directory || sep)
      where concurrent_request_id = reqid;

  end if;

end move_request_files;




-- Procedure
--   MOVE_REQUEST_FILES
--
-- Purpose
--   Changes the location of the logfile, output file or both for a list of requests.
--   Updates the directory only, does not change the file names.
--   Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which     - LOG, OUT or BOTH
--   requests  - List of request ids
--   directory - New directory the files are located in
--   updated   - number of requests updated
--
procedure move_request_files(which     in  number,
                             requests  in  request_list,
                             directory in  varchar2,
                             updated   out nocopy number) is

  sep  char := '/';
  user_id  number := fnd_global.user_id;
  login_id number := fnd_global.login_id;
begin

  -- Check for file separator
  if instr(directory, '\') > 0 then
    sep := '\';
  end if;
  updated := 0;

  -- Must use absolute path. Return unless file separator present
  if instr(directory, sep) = 0 then
     return;
  end if;

  if which = FND_CONC_MAINTAIN.LOG or which = FND_CONC_MAINTAIN.BOTH then
    forall i in requests.FIRST .. requests.LAST
      update fnd_concurrent_requests
        set logfile_name = regexp_replace(logfile_name, '^.+' || sep, directory || sep),
        last_update_date = sysdate,
        last_updated_by = user_id,
        last_update_login = login_id
        where request_id = requests(i)
        and phase_code = 'C';

      updated := sql%rowcount;

  end if;

  if which = FND_CONC_MAINTAIN.OUT or which = FND_CONC_MAINTAIN.BOTH then
    forall i in requests.FIRST .. requests.LAST
      update fnd_concurrent_requests
        set outfile_name = regexp_replace(outfile_name, '^.+' || sep, directory || sep),
        last_update_date = sysdate,
        last_updated_by = user_id,
        last_update_login = login_id
        where request_id = requests(i)
        and phase_code = 'C';

      if (updated <= sql%rowcount) then
        updated := sql%rowcount;
      end if;

    forall i in requests.FIRST .. requests.LAST
      update fnd_conc_req_outputs
        set file_name = regexp_replace(file_name, '^.+' || sep, directory || sep)
	where concurrent_request_id = requests(i);

  end if;

end move_request_files;

-- Procedure
--   MOVE_REQUEST_FILES
--
-- Purpose
--   Changes the location of the logfile, output file or both for requests within a
--   date range (inclusive). Updates the directory only, does not change the file names.
--   Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which     - LOG, OUT or BOTH
--   min_compldate  - Minimum completion date of requests
--   max_compldate  - Maximum completion date of requests
--   directory - New directory the files are located in
--   updated - number of requests updated
--
procedure move_request_files(which         in  number,
                             min_compldate in  date,
                             max_compldate in  date,
                             directory     in  varchar2,
                             updated       out nocopy number) is

  cursor c1 is
      select request_id
        from fnd_concurrent_requests
       where actual_completion_date between min_compldate and max_compldate
         and phase_code = 'C'
    order by request_id;

  requests request_list;
  i number := 0;


begin
  if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'fnd.plsql.fnd_conc_maintain.move_request_files',
                 'Move request files for requests completed '||to_char(min_compldate,'dd-mm-yyyy hh24:mi')||
                 ' through '||to_char(max_compldate,'dd-mm-yyyy hh24:mi')||' to '||directory);
  end if;
  for l_rec in c1 loop
     requests(i) := l_rec.request_id;
     i := i+1;
  end loop;

  move_request_files(which, requests, directory, updated);

end move_request_files;

-- Procedure
--   MOVE_REQUEST_FILES
--
-- Purpose
--   Changes the location of the logfile, output file or both for requests within a
--   range (inclusive) of request_id's. Updates the directory only, does not change
--   the file names.  Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which      - LOG, OUT or BOTH
--   min_reqid  - Minimum request_id for set of requests
--   max_reqid  - Maximum request_id for set of requests
--   directory  - New directory the files are located in
--   updated - number of requests updated
--
procedure move_request_files(which     in number,
                             min_reqid in  number,
                             max_reqid in  number,
                             directory in  varchar2,
                             updated   out nocopy number) is

  cursor c1 is
      select request_id
        from fnd_concurrent_requests
       where request_id between min_reqid and max_reqid
         and phase_code = 'C'
    order by request_id;

  requests request_list;
  i number := 0;


begin
  if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'fnd.plsql.fnd_conc_maintain.move_request_files',
                 'Move request files for requests '||to_char(min_reqid)||
                 ' through '||to_char(max_reqid)||' to '||directory);
  end if;

  for l_rec in c1 loop
     requests(i) := l_rec.request_id;
     i := i+1;
  end loop;

  move_request_files(which, requests, directory, updated);

end move_request_files;

-- Procedure
--   SET_REQUEST_FILES
--
-- Purpose
--   Changes the location of a single request's logfile, output file or both.
--   Sets the filename to the passed-in value, which should be a complete path
--   and filename.
--   Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
--   USE THIS API AT YOUR OWN RISK!
--   This API will completely rename the request's files, and does not update the
--   potentially new size of the file. It also does not take published output into account.
--   Use this API only if you know what you are doing.
--
-- Arguments
--   reqid     - Concurrent request id
--   logfile   - New logfile name, can be null
--   outfile   - New outfile name, can be null
--
procedure set_request_files(reqid in number, logfile in varchar2, outfile in varchar2, updated out nocopy number) is

  user_id  number := fnd_global.user_id;
  login_id number := fnd_global.login_id;
begin

  if logfile is not null then
    update fnd_concurrent_requests
      set logfile_name = logfile,
      last_update_date = sysdate,
      last_updated_by = user_id,
      last_update_login = login_id
      where request_id = reqid
      and phase_code = 'C';

    updated := sql%rowcount;
  end if;

  if outfile is not null then
    update fnd_concurrent_requests
      set outfile_name = outfile,
      last_update_date = sysdate,
      last_updated_by = user_id,
      last_update_login = login_id
      where request_id = reqid
      and phase_code = 'C';

    updated := sql%rowcount;
  end if;

end set_request_files;



-- Procedure
--   SET_REQUEST_NODE
--
-- Purpose
--   Changes the logfile node, output file node or both for a single request.
--   Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which     - LOG, OUT or BOTH
--   reqid     - Concurrent request id
--   node      - New node name
--
procedure set_request_node(which in number,  reqid in number, node in varchar2, updated out nocopy number) is

  user_id  number := fnd_global.user_id;
  login_id number := fnd_global.login_id;
begin

  updated := 0;

  if which = FND_CONC_MAINTAIN.LOG or which = FND_CONC_MAINTAIN.BOTH then
    update fnd_concurrent_requests
      set logfile_node_name = node,
      last_update_date = sysdate,
      last_updated_by = user_id,
      last_update_login = login_id
      where request_id = reqid
      and phase_code = 'C';

    updated := sql%rowcount;
  end if;

  if which = FND_CONC_MAINTAIN.OUT or which = FND_CONC_MAINTAIN.BOTH then
    update fnd_concurrent_requests
      set outfile_node_name = node,
      last_update_date = sysdate,
      last_updated_by = user_id,
      last_update_login = login_id
      where request_id = reqid
      and phase_code = 'C';

    if (updated <= sql%rowcount) then
        updated := sql%rowcount;
      end if;

    update fnd_conc_req_outputs
      set file_node_name = node
      where concurrent_request_id = reqid;

  end if;

end set_request_node;



-- Procedure
--   SET_REQUEST_NODE
--
-- Purpose
--   Changes the logfile node, output file node or both for a list of requests.
--   Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which     - LOG, OUT or BOTH
--   requests  - List of request ids
--   node      - New node name
--
procedure set_request_node(which in number,  requests in request_list, node in varchar2, updated out nocopy number) is

  user_id  number := fnd_global.user_id;
  login_id number := fnd_global.login_id;
begin

  updated := 0;

  if which = FND_CONC_MAINTAIN.LOG or which = FND_CONC_MAINTAIN.BOTH then
    forall i in requests.FIRST .. requests.LAST
      update fnd_concurrent_requests
        set logfile_node_name = node,
        last_update_date = sysdate,
        last_updated_by = user_id,
        last_update_login = login_id
        where request_id = requests(i)
        and phase_code = 'C';

      updated := sql%rowcount;

  end if;

  if which = FND_CONC_MAINTAIN.OUT or which = FND_CONC_MAINTAIN.BOTH then
    forall i in requests.FIRST .. requests.LAST
      update fnd_concurrent_requests
        set outfile_node_name = node,
        last_update_date = sysdate,
        last_updated_by = user_id,
        last_update_login = login_id
        where request_id = requests(i)
        and phase_code = 'C';

     if (updated <= sql%rowcount) then
        updated := sql%rowcount;
      end if;

    forall i in requests.FIRST .. requests.LAST
      update fnd_conc_req_outputs
        set file_node_name = node
	where concurrent_request_id = requests(i);

  end if;

end set_request_node;

-- Procedure
--   SET_REQUEST_NODE
--
-- Purpose
--   Changes the logfile node, output file node or both for requests within a
--   date range (inclusive). Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.

-- Arguments
--   which          - LOG, OUT or BOTH
--   min_compldate  - Minimum completion date of requests
--   max_compldate  - Maximum completion date of requests
--   node      - New node name
--   updated - number of requests updated
--

procedure set_request_node  (which         in  number,
                             min_compldate in  date,
                             max_compldate in  date,
                             node          in  varchar2,
                             updated       out nocopy number) is

  cursor c1 is
      select request_id
        from fnd_concurrent_requests
       where actual_completion_date between min_compldate and max_compldate
         and phase_code = 'C'
    order by request_id;

  requests request_list;
  i number := 0;


begin
  if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'fnd.plsql.fnd_conc_maintain.set_request_node',
                 'Set request node for requests completed '||to_char(min_compldate,'dd-mm-yyyy hh24:mi')||
                 ' through '||to_char(max_compldate,'dd-mm-yyyy hh24:mi')||' to '||node);
  end if;
  for l_rec in c1 loop
     requests(i) := l_rec.request_id;
     i := i+1;
  end loop;

  set_request_node(which, requests, node, updated);

end set_request_node;

-- Procedure
--   SET_REQUEST_NODE
--
-- Purpose
--   Changes the logfile node, output file node or both for requests within a
-- Purpose
--   Changes the location of the logfile, output file or both for requests within a
--   range (inclusive) of request_id's. Updates the directory only, does not change
--   the file names.  Only updates completed requests.
--   Does not actually move the files, only updates the locations in the table.
--
-- Arguments
--   which      - LOG, OUT or BOTH
--   min_reqid  - Minimum request_id for set of requests
--   max_reqid  - Maximum request_id for set of requests
--   node       - New directory the files are located in
--   updated    - number of requests updated
--

procedure set_request_node  (which         in  number,
                             min_reqid     in  number,
                             max_reqid     in  number,
                             node          in  varchar2,
                             updated       out nocopy number) is

  cursor c1 is
      select request_id
        from fnd_concurrent_requests
       where request_id between min_reqid and max_reqid
         and phase_code = 'C'
    order by request_id;

  requests request_list;
  i number := 0;


begin
  if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'fnd.plsql.fnd_conc_maintain.set_request_node',
                 'Set request node for requests '||to_char(min_reqid)||
                 ' through '||to_char(max_reqid)||' to '||node);
  end if;
  for l_rec in c1 loop
     requests(i) := l_rec.request_id;
     i := i+1;
  end loop;

  set_request_node(which, requests, node, updated);

end set_request_node;


end FND_CONC_MAINTAIN;

/
