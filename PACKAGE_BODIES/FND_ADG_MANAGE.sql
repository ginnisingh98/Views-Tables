--------------------------------------------------------
--  DDL for Package Body FND_ADG_MANAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ADG_MANAGE" as
/* $Header: AFDGMGRB.pls 120.0.12010000.2 2010/09/17 16:29:11 rsanders noship $ */

G_SESS_STANDY_TO_PROD_VALID boolean := null;

G_SESSION_IS_SLAVE_TO_STANDBY boolean := false; -- always starts as false.
				                -- no need for null.
G_SESS_HANDLE_SLAVE_RPC_DEBUG boolean := false; -- always starts as false.
G_SESS_HANDLE_RPC_DEBUG boolean := false; -- always starts as false.

G_SLAVE_SESSION_ID      number := null;
G_SESS_MAX_COMMIT_WAIT_TIME number := null;

C_COMMIT_WAIT_SLEEP_TIME  constant       number := 1;

C_DEBUG_TRACE		  constant       number := 1;

/*==========================================================================*/

procedure raise_rpc_exec_error(p_rpcDescriptor rpcDescriptor,
                               p_location varchar2,
                               p_additional_info varchar2 default null)
as
begin

  fnd_adg_exception.raise_error(fnd_adg_exception.C_MGRERR_RPC_EXEC_ERROR,
                  'O='||p_rpcDescriptor.owner ||
                  ' P='||p_rpcDescriptor.package_name ||
                  ' RP='||p_rpcDescriptor.rpc_package_name ||
                  ' RS='||p_rpcDescriptor.rpc_synonym_name ||
                  ' M='||p_rpcDescriptor.method_name ||
                  ' : Location='||p_location ||
                  ' : Addtl Info='||p_additional_info
                                );
end;

/*==========================================================================*/

function boolean_to_char(p_bool boolean) return varchar2
as
begin

  if ( p_bool is null )
  then
     return 'NULL';
  else
     if ( p_bool )
     then
        return 'TRUE';
     else
        return 'FALSE';
     end if;
  end if;

end;

/*==========================================================================*/

function is_session_slave_to_standby return boolean
as
begin
  return G_SESSION_IS_SLAVE_TO_STANDBY;
end;

/*==========================================================================*/

procedure validate_primary_private(p_dbid number, p_dbname varchar2,
                                   p_slave_session_id out nocopy number,
               	                   p_sid number, p_serial number,
                                   p_audsid number,p_is_true_standby boolean,
                                   p_valid out nocopy number)
as
cursor c1 is select a.dbid,a.name
               from v$database a;

cursor c2 is select a.sid,a.serial#,a.audsid
               from v$session a
              where a.sid = ( select distinct b.sid from v$mystat b);

begin

  p_slave_session_id := -1;

  p_valid := 2;

  if ( not fnd_adg_support.is_primary )
  then
     p_valid := 1;
     return;
  end if;

  for f_rec in c1 loop

    if ( f_rec.dbid = p_dbid and f_rec.name = p_dbname )
    then
       p_valid := 0;
    end if;

    exit;

  end loop;

  if ( p_valid <> 0 )
  then
     return;
  end if;

     -- Mark this session as slave to standby. This ensures SV_* cannot be
     -- run directly and allows users to suppress commits. However,
     -- with the use of autotx flag , user suppress should not be needed.

     -- This is fine as this routine is only
     -- ever called under the fnd_adg_manage_remote synonym and we would
     -- never have got here unless we'd come from standby.

     -- We also use this flag to determine where we are in simulated standby,
     -- to ensure that the real call [ under SV_* ] returns is_standby as
     -- false but the originator [ on primary also ] returns true.

  if ( fnd_adg_utility.is_session_simulated_standby and not p_is_true_standby )
                                     -- originator could be standby or primary.
                                     -- only care when not true standby.
  then

     p_valid := 3;

     if ( p_sid <> -1 and p_serial <> -1 and p_audsid <> -1 )
     then

        for f_rec in c2 loop

/*
          dbms_system.ksdwrt(1,
            'SLAVE=' || f_rec.sid || ' ' || f_rec.serial# || ' ' ||
                        f_rec.audsid || ' RPC=' || p_sid || ' ' || p_serial
                       || ' ' || p_audsid );
*/

          if ( f_rec.sid = p_sid and
               f_rec.serial# = p_serial and
               f_rec.audsid = p_audsid
             )
          then
             null;
          else
             p_valid := 0;
          end if;

          exit;

        end loop;
     end if;
  end if;

  if ( p_valid <> 0 )
  then
     return;
  end if;

  G_SESSION_IS_SLAVE_TO_STANDBY := true;

  -- Record session id.

  G_SLAVE_SESSION_ID := userenv('SESSIONID');

  p_slave_session_id := G_SLAVE_SESSION_ID;

end;

/*==========================================================================*/

procedure validate_standby_to_primary(p_err out nocopy number,
                                      p_msg out nocopy varchar2,
                                      p_once_per_session boolean default false)
as
cursor c1 is select a.dbid,a.name
               from v$database a;

	-- Don't use SESSIONID as invalid on standby!

cursor c2 is select a.sid,a.serial#,a.audsid
               from v$session a
              where a.sid = ( select distinct b.sid from v$mystat b);

l_valid	number;
l_slave_session_id number;
l_sid   number  := -1;
l_serial number := -1;
l_audsid number := -1;

begin

  p_err := 0;
  p_msg := null;

  if ( p_once_per_session )
  then
     if ( G_SESS_STANDY_TO_PROD_VALID is not null )
     then
       if ( G_SESS_STANDY_TO_PROD_VALID )
       then
          return;
       else
          p_err := fnd_adg_exception.C_MGRERR_FAILED_PREV_SES_CHK;
          p_msg := fnd_adg_exception.get_error_msg
                               (fnd_adg_exception.C_MGRERR_FAILED_PREV_SES_CHK);
          return;
       end if;
     end if;
  end if;

  if ( not fnd_adg_support.is_standby )
  then
     p_err := fnd_adg_exception.C_MGRERR_NOT_STANDBY;
     p_msg := fnd_adg_exception.get_error_msg(fnd_adg_exception.C_MGRERR_NOT_STANDBY);
     G_SESS_STANDY_TO_PROD_VALID := false;
     return;
  end if;

	-- If simulated standby and we're really primary, need to
	-- pass sid,serial, audsid to make sure slave is not a loopback.

  if ( fnd_adg_utility.is_session_simulated_standby and
                  fnd_adg_support.is_primary )
  then
     for f_rec in c2 loop

       l_sid := f_rec.sid;
       l_serial := f_rec.serial#;
       l_audsid := f_rec.audsid;

       exit;
     end loop;
  end if;

  for f_rec in c1 loop

    begin

$if fnd_adg_compile_directive.enable_rpc
$then
      fnd_adg_manage_remote.validate_primary_private
                                       (f_rec.dbid,f_rec.name,
                                        l_slave_session_id,
                                        l_sid,l_serial,l_audsid,
                                        fnd_adg_support.is_true_standby,
                                        l_valid);
    exception when others
         then l_valid := -1;
$else
    l_valid := -1;
$end

    end;

    if ( l_valid <> 0 )
    then
       case l_valid
         when 1 then
                     p_err := fnd_adg_exception.C_MGRERR_REMOTE_NOT_PRIMARY;
                     p_msg := fnd_adg_exception.get_error_msg
                                         (fnd_adg_exception.C_MGRERR_REMOTE_NOT_PRIMARY);
         when 2 then
                     p_err := fnd_adg_exception.C_MGRERR_REMOTE_DOESNT_MATCH;
                     p_msg := fnd_adg_exception.get_error_msg
                                         (fnd_adg_exception.C_MGRERR_REMOTE_DOESNT_MATCH);
         when 3 then
                     p_err := fnd_adg_exception.C_MGRERR_REMOTE_IS_LOOPBACK;
                     p_msg := fnd_adg_exception.get_error_msg
                                         (fnd_adg_exception.C_MGRERR_REMOTE_IS_LOOPBACK);
         when -1 then
                     p_err := fnd_adg_exception.C_MGRERR_REMOTE_RESOLVE;
                     p_msg := fnd_adg_exception.get_error_msg
                                         (fnd_adg_exception.C_MGRERR_REMOTE_RESOLVE);
                else
                     p_err := fnd_adg_exception.C_MGRERR_UNKNOWN_REMOTE_ERROR;
                     p_msg := fnd_adg_exception.get_error_msg
                                         (fnd_adg_exception.C_MGRERR_UNKNOWN_REMOTE_ERROR);
       end case;
       G_SESS_STANDY_TO_PROD_VALID := false;
       return;
    end if;

    exit;

  end loop;

  G_SESS_STANDY_TO_PROD_VALID := true;

	-- Session is valid - record slave session id.

  G_SLAVE_SESSION_ID := l_slave_session_id;

end;

/*==========================================================================*/

function  validate_rpc_timestamp(p_rpcDescriptor rpcDescriptor) return boolean
as
cursor c1 is select 1
               from dba_objects a,dba_objects b
              where a.owner = p_rpcDescriptor.owner
                and a.object_name = p_rpcDescriptor.package_name
                and a.object_type = 'PACKAGE'
                and b.owner = p_rpcDescriptor.owner
                and b.object_name = p_rpcDescriptor.rpc_package_name
                and b.object_type = 'PACKAGE'
                and to_date(b.timestamp,'YYYY-MM-DD:HH24:MI:SS') >=
                       to_date(a.timestamp,'YYYY-MM-DD:HH24:MI:SS') ;
begin

  if ( not fnd_adg_utility.is_runtime_validate_timestamp )
  then
     return true;
  end if;

  for f_rec in c1 loop

    return true;

  end loop;

  return false;

end;

/*==========================================================================*/

function  validate_rpc_synonym(p_rpcDescriptor rpcDescriptor) return boolean
as
cursor c1 is select 1
               from dba_synonyms a, dba_synonyms b
              where a.owner = p_rpcDescriptor.owner
                and a.synonym_name = fnd_adg_object.C_ADG_MANAGE_NAME_REMOTE
                and ( a.table_owner = p_rpcDescriptor.owner or
                      a.table_owner is null )
                and a.table_name  = fnd_adg_object.C_ADG_MANAGE_PACKAGE
                and b.owner = p_rpcDescriptor.owner
                and b.synonym_name = p_rpcDescriptor.rpc_synonym_name
                and ( b.table_owner = p_rpcDescriptor.owner or
                      b.table_owner is null )
                and b.table_name  = p_rpcDescriptor.rpc_package_name
                and a.db_link     = b.db_link
                and a.db_link is not null
                and b.db_link is not null;
begin

  for f_rec in c1 loop

    return true;

  end loop;

  return false;

end;

/*==========================================================================*/

procedure handle_runtime_debug(p_is_slave boolean)
as
l_debug_rpc number;
l_debug_slave_rpc number;
begin

  fnd_adg_utility.get_rpc_debug(l_debug_rpc,l_debug_slave_rpc);

  if ( p_is_slave and bitand(l_debug_slave_rpc,C_DEBUG_TRACE) <> 0 )
  then
     execute immediate 'alter session set sql_trace true';
  end if;

  if ( not p_is_slave and bitand(l_debug_rpc,C_DEBUG_TRACE) <> 0  )
  then
     execute immediate 'alter session set sql_trace true';
  end if;

end;

/*==========================================================================*/

procedure handle_rpc_debug(p_once_per_session boolean default true)
as
begin

  if ( p_once_per_session )
  then
     if ( G_SESS_HANDLE_RPC_DEBUG )
     then
        return;
     end if;
  end if;

 handle_runtime_debug(false);

 G_SESS_HANDLE_RPC_DEBUG := true;

end;

/*==========================================================================*/

procedure handle_slave_rpc_debug(p_once_per_session boolean default true)
as
begin

  if ( p_once_per_session )
  then
     if ( G_SESS_HANDLE_SLAVE_RPC_DEBUG )
     then
        return;
     end if;
  end if;

 handle_runtime_debug(true);

 G_SESS_HANDLE_SLAVE_RPC_DEBUG := true;

end;

/*==========================================================================*/

function get_commit_wait_seq(p_rpcDescriptor rpcDescriptor) return number
as
l_commit_count number;
begin

  if ( G_SLAVE_SESSION_ID is null ) -- should never happen
  then
     raise_rpc_exec_error(p_rpcDescriptor,'get_commit_wait_seq',
                          'G_SLAVE_SESSION_ID is null!');
  end if;

	-- Initial insert takes place on slave so row may not exist yet.
  begin

    select a.commit_count
      into l_commit_count
      from fnd_adg_commit_wait a
     where a.session_id = G_SLAVE_SESSION_ID;

  exception
     when no_data_found
       then l_commit_count := null;
  end ;

  return l_commit_count;

end;

/*==========================================================================*/

procedure increment_commit_count(p_rpcDescriptor rpcDescriptor)
as
l_commit_count number;
begin

  if ( G_SLAVE_SESSION_ID is null ) -- should never happen
  then
     raise_rpc_exec_error(p_rpcDescriptor,'increment_commit_count',
                          'G_SLAVE_SESSION_ID is null!');
  end if;

  update fnd_adg_commit_wait a
     set a.commit_count = a.commit_count + 1
   where a.session_id = G_SLAVE_SESSION_ID;

  if ( sql%notfound ) -- first time?
  then
     insert into fnd_adg_commit_wait(session_id,commit_count)
                       values (G_SLAVE_SESSION_ID,0);
  end if;

  -- debug_dump_state;

	-- commit happens in the rpc.
end;

/*==========================================================================*/

procedure set_sess_max_commit_wait_time
as
begin

  G_SESS_MAX_COMMIT_WAIT_TIME := -1;

  G_SESS_MAX_COMMIT_WAIT_TIME := fnd_adg_utility.get_max_commit_wait_time;

end;

/*==========================================================================*/

function wait_for_commit_count(p_rpcDescriptor rpcDescriptor,
                               p_wait_seq number) return boolean
as
l_commit_wait_time number;
l_actual_wait_time number;
l_commit_count number;

begin

  if ( G_SLAVE_SESSION_ID is null ) -- should never happen
  then
     raise_rpc_exec_error(p_rpcDescriptor,'wait_for_commit_count',
                          'G_SLAVE_SESSION_ID is null!');
  end if;

  if ( G_SESS_MAX_COMMIT_WAIT_TIME is null )
  then
     set_sess_max_commit_wait_time;
  end if;

  if ( G_SESS_MAX_COMMIT_WAIT_TIME < 0 )
  then
     raise_rpc_exec_error(p_rpcDescriptor,'wait_for_commit_count',
                          'commit count is -ve!');
  end if;

  if ( G_SESS_MAX_COMMIT_WAIT_TIME > fnd_adg_utility.C_MAX_COMMIT_WAIT_TIME )
  then
     l_commit_wait_time := fnd_adg_utility.C_MAX_COMMIT_WAIT_TIME;
  else
     l_commit_wait_time := G_SESS_MAX_COMMIT_WAIT_TIME;
  end if;

  l_actual_wait_time := 0;

  loop

    if ( l_actual_wait_time > l_commit_wait_time )
    then
        return false;
    end if;

    begin

      select a.commit_count
        into l_commit_count
        from fnd_adg_commit_wait a
       where a.session_id = G_SLAVE_SESSION_ID;

    exception
       when no_data_found
         then l_commit_count := null;

    end;

    if ( l_commit_count is not null )
    then
       if ( p_wait_seq is null ) -- first time so any non-null count is ok
       then
          exit;
       else
          if ( l_commit_count > p_wait_seq )
          then
             exit;  --ok
          end if;
       end if;
    else
       if ( p_wait_seq is not null )  -- can't happen!
       then
          raise_rpc_exec_error(p_rpcDescriptor,'wait_for_commit_count',
                             'commit count is null but wait seq isn''t!');
       end if;
    end if;

    dbms_lock.sleep(C_COMMIT_WAIT_SLEEP_TIME);

    l_actual_wait_time := l_actual_wait_time + C_COMMIT_WAIT_SLEEP_TIME;

  end loop;

  -- debug_dump_state;

  return true;

end;

/*==========================================================================*/

procedure invoke_standby_error_handler(p_request_id number)
as
begin
	-- This procedure is the rpc wrapper for handle_standby_error.

  fnd_adg_support.handle_standby_error(p_request_id,false,false,1);

end;

/*==========================================================================*/

procedure rpc_invoke_standby_error ( p_request_id number)
as
begin

$if fnd_adg_compile_directive.enable_rpc
$then

  fnd_adg_manage_remote.invoke_standby_error_handler(p_request_id);

$else

  null;

$end

end;

/*==========================================================================*/

begin
  null;
end fnd_adg_manage;

/
