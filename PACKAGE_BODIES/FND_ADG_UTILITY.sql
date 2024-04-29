--------------------------------------------------------
--  DDL for Package Body FND_ADG_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ADG_UTILITY" as
/* $Header: AFDGUTLB.pls 120.0.12010000.6 2010/11/19 21:58:23 rsanders noship $ */

C_CONTROL_KEY		constant	number 	:= 1;

C_FORCE_PUBLIC_DBLINK   constant        boolean      := true;

C_MAX_STANDBY_SYSTEMS   constant        number  := 5;

G_SESS_SIMULATED_STDBY_ENABLED boolean := null;
G_SESS_COMMIT_WAIT_ENABLED  boolean := null;
G_MAGIC_SWITCH_ENABLED      boolean  := false;

G_ENABLE_CONTROL_CACHE	    boolean  := false;
G_CONTROL_CACHE_LOADED	    boolean  := false;
G_CACHED_CONTROL_REC	    fnd_adg_control%rowtype;

	/* RPC state */

C_RPC_SYSTEM_ENABLED    constant        number  := 1;
C_RPC_SIMULATION_VALIDATED constant	number  := 2;
C_RPC_ADG_VALIDATED	constant	number	:= 4;
C_RPC_ADG_ENABLED       constant        number  := 8;
C_RPC_SYSTEM_PREPARED   constant        number  := 16;
C_RPC_RUNT_VALIDATE_TIMESTAMP
                        constant	number	:= 32;

C_OPEN_READ_ONLY        constant        varchar2(30) := 'READ ONLY';
C_OPEN_READ_WRITE       constant        varchar2(30) := 'READ WRITE';
C_STANDBY_ROLE          constant        varchar2(30) := 'PHYSICAL STANDBY';
C_PRIMARY_ROLE          constant        varchar2(30) := 'PRIMARY';

C_MAGIC_SWITCH_EVENT_ON constant	varchar2(255) :=
                            '3177 trace name context forever, level 1';
C_MAGIC_SWITCH_EVENT_OFF constant	varchar2(255) :=
                            '3177 trace name context forever, level 0';
C_MAGIC_SWITCH_IDENT    constant 	varchar2(255) :=
			    '*** READ-ONLY VIOLATION BY MODULE ';
			    -- '*ADG-ACCESS-VIOLATION-INFO: *';

	/* Thresholds */

C_STD_ERROR_THRESHOLD	constant	number	     := 5;
C_MIN_ERROR_THRESHOLD	constant	number	     := 0;
C_MAX_ERROR_THRESHOLD	constant	number	     := 25;

	/* CHECK MODE */

	/* Access codes */

G_CONC_PROGRAM_ACCESS_CODE	number;

	/* Database triggers */

C_ERROR_TRIGGER		constant	varchar2(30) := 'FND_ADG_ERROR_TRIGGER';
C_LOGON_TRIGGER		constant        varchar2(30) := 'FND_ADG_LOGON_TRIGGER';
C_LOGOFF_TRIGGER	constant        varchar2(30) := 'FND_ADG_LOGOFF_TRIGGER';

	/* CONCURRENT REQUEST TRIGGERS */

C_CP_BEFORE_INSERT	constant varchar2(30) := 'FND_ADG_CONCURRENT_REQUEST_I';
C_CP_AFTER_UPDATE       constant varchar2(30) := 'FND_ADG_CONCURRENT_REQUEST_U';

	/* Max length of CONNSTR. */

C_MAX_CONNSTR_LENGTH	constant        number       := 128;

/*==========================================================================*/

procedure check_standby_support
as
begin

  if ( not is_standby_access_supported )
  then
     fnd_adg_exception.raise_error(fnd_adg_exception.C_UTLERR_INVALID_DB_RELEASE);
  end if;

end;

/*==========================================================================*/

procedure check_connection_type(p_type number)
as
begin

  case p_type
    when C_CONNECT_STANDBY_TO_PRIMARY   then return;
    when C_CONNECT_PRIMARY_TO_STANDBY   then return;
    when C_CONNECT_TO_SIMULATED_STANDBY then return;
    else
       fnd_adg_exception.raise_error(fnd_adg_exception.C_UTLERR_INVALID_CONNECT_TYPE);
  end case;

end;

/*==========================================================================*/

procedure check_standby_number(p_standby_number number)
as
begin

  if ( p_standby_number is null )
  then
     fnd_adg_exception.raise_error(fnd_adg_exception.C_UTLERR_STANDBY_NULL);
  end if;

  if ( p_standby_number < 1 or p_standby_number > C_MAX_STANDBY_SYSTEMS )
  then
     fnd_adg_exception.raise_error(fnd_adg_exception.C_UTLERR_STANDBY_OUT_OF_RANGE);
  end if;

end;

/*==========================================================================*/

function is_rpc_state(p_rec fnd_adg_control%rowtype,
                      p_flag number
                     ) return boolean
as
begin

  if ( bitand(p_rec.rpc_system_state,p_flag) <> 0 )
  then
     return true;
  else
     return false;
  end if;

end;

/*==========================================================================*/

procedure set_rpc_state(p_rec in out nocopy fnd_adg_control%rowtype,
                        p_flag number)
as
begin

  if ( not is_rpc_state(p_rec,p_flag) )
  then
     p_rec.rpc_system_state := p_rec.rpc_system_state + p_flag;
  end if;

end;

/*==========================================================================*/

procedure clr_rpc_state(p_rec in out nocopy fnd_adg_control%rowtype,
                        p_flag number)
as
begin

  if ( is_rpc_state(p_rec,p_flag) )
  then
     p_rec.rpc_system_state := p_rec.rpc_system_state - p_flag;
  end if;

end;

/*==========================================================================*/

function boolean_to_yn(p_bool boolean) return varchar2
as
begin

  if ( p_bool is null )
  then
     return null;
  end if;

  if ( p_bool )
  then
     return 'Y';
  else
     return 'N';
  end if;

end;

/*==========================================================================*/

function yn_to_boolean(p_yn varchar2) return boolean
as
begin

  if ( p_yn is null )
  then
     return null;
  end if;

  if ( upper(p_yn) = 'Y' )
  then
     return true;
  else
     return false;
  end if;

end;

/*==========================================================================*/

procedure set_program_access_code
as
begin

  G_CONC_PROGRAM_ACCESS_CODE := dbms_random.value;

end;

/*==========================================================================*/

function is_new_style_magic_switch return boolean
as
l_db_version varchar2(128);
l_db_compat varchar2(128);
l_minor_version number;
l_major_version number;
l_minor_str varchar2(128);

begin

  dbms_utility.db_version(l_db_version,l_db_compat);

  l_major_version:=to_number(substr(l_db_version,1,instr(l_db_version,'.')-1));

  l_minor_str := substr(l_db_version,instr(l_db_version,'.')+1);

  l_minor_version:=to_number(substr(l_minor_str,1,instr(l_minor_str,'.')-1));

  if ( l_major_version > 11 )
  then
     return true;
  else
     if ( l_minor_version = 1 )
     then
        return false;
     else
        return true;
     end if;
  end if;

end;

/*==========================================================================*/

procedure init_adg_control(p_rec in out nocopy fnd_adg_control%rowtype)
as
begin

  p_rec.control_key                  := C_CONTROL_KEY;
  p_rec.enable_adg_support           := 'N';
  p_rec.rpc_system_state             := 0;
  p_rec.enable_commit_wait           := 'Y';
  p_rec.max_commit_wait_time         := 60;
  p_rec.runtime_validate_timestamp   := 'Y';
  p_rec.always_collect_primary_data  := 'Y';
  p_rec.enable_redirect_if_valid     := 'N';
  p_rec.standby_error_threshold      := C_STD_ERROR_THRESHOLD;
  p_rec.simulation_error_threshold   := C_STD_ERROR_THRESHOLD;
  p_rec.enable_standby_error_checks  := 'Y';
  p_rec.enable_automatic_redirection := 'N';
  p_rec.stndby_to_primary_link_owner := null;
  p_rec.stndby_to_primary_link_name  := null;
  p_rec.stndby_to_primary_link_valid := 'N';
  p_rec.stndby_to_primary_connstr    := null;
  p_rec.enable_simulated_standby     := 'Y';
  p_rec.enable_auto_simulated_standby:= 'N';
  p_rec.simulated_standby_service    := null;
  p_rec.simulated_stndby_link_owner  := null;
  p_rec.simulated_stndby_link_name   := null;
  p_rec.simulated_stndby_link_valid  := 'N';
  p_rec.simulated_stndby_connstr     := null;
  p_rec.simulated_stndby_trc_dir_obj := null;
  p_rec.primary_to_stndby1_link_owner:= null;
  p_rec.primary_to_stndby1_link_name := null;
  p_rec.primary_to_stndby1_link_valid:= 'N';
  p_rec.primary_to_stndby1_connstr   := null;
  p_rec.mgr_stndby1_req_class_app_id := null;
  p_rec.mgr_stndby1_req_class_id     := null;
  p_rec.primary_to_stndby2_link_owner:= null;
  p_rec.primary_to_stndby2_link_name := null;
  p_rec.primary_to_stndby2_link_valid:= 'N';
  p_rec.primary_to_stndby2_connstr   := null;
  p_rec.mgr_stndby2_req_class_app_id := null;
  p_rec.mgr_stndby2_req_class_id     := null;
  p_rec.primary_to_stndby3_link_owner:= null;
  p_rec.primary_to_stndby3_link_name := null;
  p_rec.primary_to_stndby3_link_valid:= 'N';
  p_rec.primary_to_stndby3_connstr   := null;
  p_rec.mgr_stndby3_req_class_app_id := null;
  p_rec.mgr_stndby3_req_class_id     := null;
  p_rec.primary_to_stndby4_link_owner:= null;
  p_rec.primary_to_stndby4_link_name := null;
  p_rec.primary_to_stndby4_link_valid:= 'N';
  p_rec.primary_to_stndby4_connstr   := null;
  p_rec.mgr_stndby4_req_class_app_id := null;
  p_rec.mgr_stndby4_req_class_id     := null;
  p_rec.primary_to_stndby5_link_owner:= null;
  p_rec.primary_to_stndby5_link_name := null;
  p_rec.primary_to_stndby5_link_valid:= 'N';
  p_rec.primary_to_stndby5_connstr   := null;
  p_rec.mgr_stndby5_req_class_app_id := null;
  p_rec.mgr_stndby5_req_class_id     := null;
  p_rec.debug_slave_rpc              := 0;
  p_rec.debug_rpc                    := 0;

end;

/*==========================================================================*/

	-- auto_init_adg

	-- This is a one time boot function to auto create data.

procedure auto_init_adg
as
PRAGMA AUTONOMOUS_TRANSACTION;
l_rec fnd_adg_control%rowtype;
begin

  init_adg_control(l_rec);

  begin

    insert into fnd_adg_control values l_rec;

  exception
    when DUP_VAL_ON_INDEX then
         commit;
         return;	-- someone got here first.
  end;

	-- If we're here then we've locked the control rec.

  fnd_adg_object.init_package_list;

  commit;

end;

/*==========================================================================*/

function get_adg_control return fnd_adg_control%rowtype
as
l_adg_control_rec fnd_adg_control%rowtype;
begin

  if ( G_ENABLE_CONTROL_CACHE and G_CONTROL_CACHE_LOADED )
  then
     l_adg_control_rec := G_CACHED_CONTROL_REC;
     return l_adg_control_rec;
  end if;

  begin

    select a.*
      into l_adg_control_rec
      from fnd_adg_control a
     where a.control_key = C_CONTROL_KEY;

  exception
     when no_data_found then

        auto_init_adg;

        select a.*
          into l_adg_control_rec
          from fnd_adg_control a
         where a.control_key = C_CONTROL_KEY;

  end;

  if ( G_ENABLE_CONTROL_CACHE )
  then
     G_CACHED_CONTROL_REC := l_adg_control_rec;
     G_CONTROL_CACHE_LOADED := true;
  end if;

  return l_adg_control_rec;

end;

/*==========================================================================*/

function get_and_lock_adg_control return fnd_adg_control%rowtype
as
l_adg_control_rec fnd_adg_control%rowtype;
begin

	-- Updates always disable cache

  disable_control_cache;

  select a.*
    into l_adg_control_rec
    from fnd_adg_control a
   where a.control_key = C_CONTROL_KEY
     for update of a.control_key;

  return l_adg_control_rec;

end;

/*==========================================================================*/

function compile_directive_state return boolean
as
l_compile_state number := -1 ;
begin

  execute immediate
          ' declare l_rc number := 0 ; ' ||
          ' begin ' ||
          '   if ( fnd_adg_compile_directive.enable_rpc ) ' ||
          '   then ' ||
          '       l_rc := 1; ' ||
          '   end if; ' ||
          '   :1 := l_rc; ' ||
          ' end; '
          using in out l_compile_state;

  if ( l_compile_state = 1)
  then
     return true;
  else
     return false;
  end if;

end;

/*==========================================================================*/

procedure check_rpc_state(p_state_on boolean)
as
l_rec fnd_adg_control%rowtype;
l_compile_state boolean;

begin

  l_rec := get_adg_control;

  if ( p_state_on )
  then
     if ( not is_rpc_state(l_rec,C_RPC_SYSTEM_ENABLED) )
     then
        fnd_adg_exception.raise_error(fnd_adg_exception.C_UTLERR_RPC_SYSTEM_OFF);
     end if;
  else
     if ( is_rpc_state(l_rec,C_RPC_SYSTEM_ENABLED) )
     then
        fnd_adg_exception.raise_error(fnd_adg_exception.C_UTLERR_RPC_SYSTEM_ON);
     end if;
  end if;

	/* Consistency check */

  l_compile_state := compile_directive_state;

  if ( ( l_compile_state and p_state_on ) or
       ( not l_compile_state and not p_state_on ) )
  then
     null;
  else
     fnd_adg_exception.raise_error
                    (fnd_adg_exception.C_UTLERR_DIRECTIVE_MISMATCH);
  end if;

end;

/*==========================================================================*/

procedure check_adg_state(p_state_on boolean)
as
l_rec fnd_adg_control%rowtype;
begin

  l_rec := get_adg_control;

  if ( p_state_on )
  then
     if ( not is_rpc_state(l_rec,C_RPC_ADG_ENABLED   ) )
     then
        fnd_adg_exception.raise_error(fnd_adg_exception.C_UTLERR_RPC_ADG_OFF);
     end if;
  else
     if ( is_rpc_state(l_rec,C_RPC_ADG_ENABLED   ) )
     then
        fnd_adg_exception.raise_error(fnd_adg_exception.C_UTLERR_RPC_ADG_ON);
     end if;
  end if;

	/* Consistency check */

  if ( ( l_rec.enable_adg_support = 'Y' and p_state_on ) or
       ( l_rec.enable_adg_support = 'N' and not p_state_on ) )
  then
     null;
  else
     fnd_adg_exception.raise_error(fnd_adg_exception.C_UTLERR_INCONSISTENT_ADGSTATE);
  end if;

end;

/*==========================================================================*/

procedure set_session_simulated_stdby
as
l_rec fnd_adg_control%rowtype;

cursor c1 is select a.service_name
               from v$session a
              where a.sid = ( select distinct b.sid from v$mystat b);

begin

  G_SESS_SIMULATED_STDBY_ENABLED := false;

  if ( not is_standby_access_supported )
  then
     return;
  end if;

  if ( not is_adg_support_enabled )
  then
     return;
  end if;

  l_rec := get_adg_control;

  if ( is_simulated_standby_enabled )
  then
     for f_sess in c1 loop

       if ( upper(f_sess.service_name) = l_rec.simulated_standby_service )
       then
          G_SESS_SIMULATED_STDBY_ENABLED := true;
       end if;

       exit;
     end loop;

  end if;

end;

/*==========================================================================*/

procedure set_commit_wait_enabled
as
l_rec fnd_adg_control%rowtype;
begin

  G_SESS_COMMIT_WAIT_ENABLED := false;

  l_rec := get_adg_control;

  if ( yn_to_boolean(l_rec.enable_commit_wait) )
  then
     G_SESS_COMMIT_WAIT_ENABLED := true;
  end if;

end;

/*==========================================================================*/
procedure log_adg_violations(p_request_id number,
                             p_adg_violations number,
                             p_magic_switch_enabled varchar2,
                             p_trace_file varchar2,
                             p_trace_error number)
as
PRAGMA AUTONOMOUS_TRANSACTION;
cursor c1 is select b.pid,b.spid,a.audsid,a.process
               from v$session a,v$process b
              where a.sid = ( select distinct c.sid from v$mystat c)
                and a.paddr = b.addr;

begin

  for f_rec in c1 loop

    insert into fnd_adg_simulated_stndby_trc
        (
          log_seq               ,
          ORACLE_PROCESS_ID     ,
          OS_PROCESS_ID         ,
          ORACLE_SESSION_ID     ,
          REQUEST_ID            ,
          magic_switch_enabled  ,
          read_only_violations  ,
          trace_file_name      ,
          trace_access_error
        )
      values
        (
          fnd_adg_simulated_stndby_trc_s.nextval,
          f_rec.spid,
          substr(f_rec.process,1,50),
          f_rec.audsid,
          p_request_id,
          p_magic_switch_enabled,
          p_adg_violations          ,
          p_trace_file,
          p_trace_error
        );

    exit;

  end loop;

  commit;

end;

/*==========================================================================*/

procedure set_adg_control(p_rec in out nocopy fnd_adg_control%rowtype)
as
begin

  p_rec.enable_adg_support           := 'N';
  p_rec.enable_commit_wait           := 'Y';
  p_rec.max_commit_wait_time         := 60;
  p_rec.runtime_validate_timestamp   := 'Y';
  p_rec.always_collect_primary_data  := 'Y';
  p_rec.enable_redirect_if_valid     := 'N';
  p_rec.standby_error_threshold      := C_STD_ERROR_THRESHOLD;
  p_rec.simulation_error_threshold   := C_STD_ERROR_THRESHOLD;
  p_rec.enable_standby_error_checks  := 'Y';
  p_rec.enable_automatic_redirection := 'N';
  p_rec.stndby_to_primary_link_owner := null;
  p_rec.stndby_to_primary_link_name  := null;
  p_rec.stndby_to_primary_link_valid := 'N';
  p_rec.stndby_to_primary_connstr    := null;
  p_rec.enable_simulated_standby     := 'Y';
  p_rec.enable_auto_simulated_standby:= 'N';
  p_rec.simulated_standby_service    := null;
  p_rec.simulated_stndby_link_owner  := null;
  p_rec.simulated_stndby_link_name   := null;
  p_rec.simulated_stndby_link_valid  := 'N';
  p_rec.simulated_stndby_connstr     := null;
  p_rec.simulated_stndby_trc_dir_obj := null;
  p_rec.primary_to_stndby1_link_owner:= null;
  p_rec.primary_to_stndby1_link_name := null;
  p_rec.primary_to_stndby1_link_valid:= 'N';
  p_rec.primary_to_stndby1_connstr   := null;
  p_rec.mgr_stndby1_req_class_app_id := null;
  p_rec.mgr_stndby1_req_class_id     := null;
  p_rec.primary_to_stndby2_link_owner:= null;
  p_rec.primary_to_stndby2_link_name := null;
  p_rec.primary_to_stndby2_link_valid:= 'N';
  p_rec.primary_to_stndby2_connstr   := null;
  p_rec.mgr_stndby2_req_class_app_id := null;
  p_rec.mgr_stndby2_req_class_id     := null;
  p_rec.primary_to_stndby3_link_owner:= null;
  p_rec.primary_to_stndby3_link_name := null;
  p_rec.primary_to_stndby3_link_valid:= 'N';
  p_rec.primary_to_stndby3_connstr   := null;
  p_rec.mgr_stndby3_req_class_app_id := null;
  p_rec.mgr_stndby3_req_class_id     := null;
  p_rec.primary_to_stndby4_link_owner:= null;
  p_rec.primary_to_stndby4_link_name := null;
  p_rec.primary_to_stndby4_link_valid:= 'N';
  p_rec.primary_to_stndby4_connstr   := null;
  p_rec.mgr_stndby4_req_class_app_id := null;
  p_rec.mgr_stndby4_req_class_id     := null;
  p_rec.primary_to_stndby5_link_owner:= null;
  p_rec.primary_to_stndby5_link_name := null;
  p_rec.primary_to_stndby5_link_valid:= 'N';
  p_rec.primary_to_stndby5_connstr   := null;
  p_rec.mgr_stndby5_req_class_app_id := null;
  p_rec.mgr_stndby5_req_class_id     := null;
  p_rec.debug_slave_rpc              := 0;
  p_rec.debug_rpc                    := 0;

end;

/*==========================================================================*/

procedure create_adg_control(p_commit boolean default true,
                             p_ignore_row_exists boolean default false)
as
l_rec fnd_adg_control%rowtype;
begin

  init_adg_control(l_rec);

  insert into fnd_adg_control values l_rec;

  if ( p_commit )
  then
     commit;
  end if;

exception
  when DUP_VAL_ON_INDEX then

       if ( p_ignore_row_exists )
       then
          null;
       else
          raise;
       end if;

end;

/*==========================================================================*/

procedure update_adg_control(p_adg_control_rec fnd_adg_control%rowtype,
                             p_commit boolean default true)
as
begin

  update fnd_adg_control a
     set row = p_adg_control_rec
   where a.control_key = C_CONTROL_KEY;

  if ( p_commit )
  then
     commit;
  end if;

end;

/*==========================================================================*/

procedure clean_adg_control(p_commit boolean default true,
                            p_clean_all boolean default false,
                            p_create_on_demand boolean default false)
as
l_rec fnd_adg_control%rowtype;
begin

	-- Dummy get_adg_control. This ensure that on a fresh system
	-- we auto_init the required data.

  l_rec := get_adg_control;

  if ( p_create_on_demand )
  then
     create_adg_control(false,true);
  end if;

  l_rec := get_and_lock_adg_control;

  if ( p_clean_all )
  then
     init_adg_control(l_rec);
  else
     set_adg_control(l_rec);
  end if;

  update_adg_control(l_rec,false);

  if ( p_commit )
  then
     commit;
  end if;

end;

/*==========================================================================*/

function find_primary_to_standby(p_rec fnd_adg_control%rowtype,
                                 p_standby_number number,
                                 p_connstr varchar2) return boolean
as
begin

  case p_standby_number

    when 1 then
                if ( p_rec.primary_to_stndby1_connstr is not null and
                     p_rec.primary_to_stndby1_connstr = p_connstr )
                then
                   return true;
                end if;
    when 2 then
                if ( p_rec.primary_to_stndby2_connstr is not null and
                     p_rec.primary_to_stndby2_connstr = p_connstr )
                then
                   return true;
                end if;
    when 3 then
                if ( p_rec.primary_to_stndby3_connstr is not null and
                     p_rec.primary_to_stndby3_connstr = p_connstr )
                then
                   return true;
                end if;
    when 4 then
                if ( p_rec.primary_to_stndby4_connstr is not null and
                     p_rec.primary_to_stndby4_connstr = p_connstr )
                then
                   return true;
                end if;
    when 5 then
                if ( p_rec.primary_to_stndby5_connstr is not null and
                     p_rec.primary_to_stndby5_connstr = p_connstr )
                then
                   return true;
                end if;
  end case;

  return false;

end;

/*==========================================================================*/

procedure set_cm_class_data(p_rec in out nocopy fnd_adg_control%rowtype,
                            p_standby_number number,
                            p_req_class_app_id number,
                            p_req_class_id number )
as
begin

  case p_standby_number

      when 1 then
                  p_rec.mgr_stndby1_req_class_app_id := p_req_class_app_id;
                  p_rec.mgr_stndby1_req_class_id     := p_req_class_id;
      when 2 then
                  p_rec.mgr_stndby2_req_class_app_id := p_req_class_app_id;
                  p_rec.mgr_stndby2_req_class_id     := p_req_class_id;
      when 3 then
                  p_rec.mgr_stndby3_req_class_app_id := p_req_class_app_id;
                  p_rec.mgr_stndby3_req_class_id     := p_req_class_id;
      when 4 then
                  p_rec.mgr_stndby4_req_class_app_id := p_req_class_app_id;
                  p_rec.mgr_stndby4_req_class_id     := p_req_class_id;
      when 5 then
                  p_rec.mgr_stndby5_req_class_app_id := p_req_class_app_id;
                  p_rec.mgr_stndby5_req_class_id     := p_req_class_id;

    end case;

end;

/*==========================================================================*/

procedure get_cm_class_data(p_rec in fnd_adg_control%rowtype,
                            p_standby_number number,
                            p_req_class_app_id in out nocopy number,
                            p_req_class_id in out nocopy number )
as
begin

  case p_standby_number

      when 1 then
                  p_req_class_app_id := p_rec.mgr_stndby1_req_class_app_id ;
                  p_req_class_id     := p_rec.mgr_stndby1_req_class_id     ;
      when 2 then
                  p_req_class_app_id := p_rec.mgr_stndby2_req_class_app_id ;
                  p_req_class_id     := p_rec.mgr_stndby2_req_class_id     ;
      when 3 then
                  p_req_class_app_id := p_rec.mgr_stndby3_req_class_app_id ;
                  p_req_class_id     := p_rec.mgr_stndby3_req_class_id     ;
      when 4 then
                  p_req_class_app_id := p_rec.mgr_stndby4_req_class_app_id ;
                  p_req_class_id     := p_rec.mgr_stndby4_req_class_id     ;
      when 5 then
                  p_req_class_app_id := p_rec.mgr_stndby5_req_class_app_id ;
                  p_req_class_id     := p_rec.mgr_stndby5_req_class_id     ;

  end case;

end;

/*==========================================================================*/

procedure get_connection_data(p_type number,
                              p_rec in fnd_adg_control%rowtype,
                              p_standby_number number,
                              p_link_name in out nocopy varchar2,
                              p_link_owner in out nocopy varchar2,
                              p_link_connstr in out nocopy varchar2,
                              p_link_valid in out nocopy varchar2,
                              p_link_service in out nocopy varchar2
                             )
as
begin

  case p_type

    when C_CONNECT_STANDBY_TO_PRIMARY then

         p_link_owner   := p_rec.stndby_to_primary_link_owner;
         p_link_name    := p_rec.stndby_to_primary_link_name;
         p_link_valid   := p_rec.stndby_to_primary_link_valid;
         p_link_connstr := p_rec.stndby_to_primary_connstr;
         p_link_service := null;

    when C_CONNECT_PRIMARY_TO_STANDBY then

         p_link_service := null;

         case p_standby_number

           when 1 then
                       p_link_owner   := p_rec.primary_to_stndby1_link_owner;
                       p_link_name    := p_rec.primary_to_stndby1_link_name ;
                       p_link_valid   := p_rec.primary_to_stndby1_link_valid;
                       p_link_connstr := p_rec.primary_to_stndby1_connstr   ;
           when 2 then
                       p_link_owner   := p_rec.primary_to_stndby2_link_owner;
                       p_link_name    := p_rec.primary_to_stndby2_link_name ;
                       p_link_valid   := p_rec.primary_to_stndby2_link_valid;
                       p_link_connstr := p_rec.primary_to_stndby2_connstr   ;
           when 3 then
                       p_link_owner   := p_rec.primary_to_stndby3_link_owner;
                       p_link_name    := p_rec.primary_to_stndby3_link_name ;
                       p_link_valid   := p_rec.primary_to_stndby3_link_valid;
                       p_link_connstr := p_rec.primary_to_stndby3_connstr   ;
           when 4 then
                       p_link_owner   := p_rec.primary_to_stndby4_link_owner;
                       p_link_name    := p_rec.primary_to_stndby4_link_name ;
                       p_link_valid   := p_rec.primary_to_stndby4_link_valid;
                       p_link_connstr := p_rec.primary_to_stndby4_connstr   ;
           when 5 then
                       p_link_owner   := p_rec.primary_to_stndby5_link_owner;
                       p_link_name    := p_rec.primary_to_stndby5_link_name ;
                       p_link_valid   := p_rec.primary_to_stndby5_link_valid;
                       p_link_connstr := p_rec.primary_to_stndby5_connstr   ;

         end case;

    when C_CONNECT_TO_SIMULATED_STANDBY then

         p_link_owner   := p_rec.simulated_stndby_link_owner;
         p_link_name    := p_rec.simulated_stndby_link_name;
         p_link_valid   := p_rec.simulated_stndby_link_valid;
         p_link_connstr := p_rec.simulated_stndby_connstr;
         p_link_service := p_rec.simulated_standby_service;

  end case;

end;

/*==========================================================================*/

procedure set_connection_valid(p_type number,
                               p_rec in out nocopy fnd_adg_control%rowtype,
                               p_status boolean,
                               p_standby_number number)
as
begin

  case p_type

    when C_CONNECT_STANDBY_TO_PRIMARY then

         p_rec.stndby_to_primary_link_valid := boolean_to_yn(p_status);

    when C_CONNECT_PRIMARY_TO_STANDBY then

         case p_standby_number

           when 1 then
                  p_rec.primary_to_stndby1_link_valid:= boolean_to_yn(p_status);
           when 2 then
                  p_rec.primary_to_stndby2_link_valid:= boolean_to_yn(p_status);
           when 3 then
                  p_rec.primary_to_stndby3_link_valid:= boolean_to_yn(p_status);
           when 4 then
                  p_rec.primary_to_stndby4_link_valid:= boolean_to_yn(p_status);
           when 5 then
                  p_rec.primary_to_stndby5_link_valid:= boolean_to_yn(p_status);
         end case;

    when C_CONNECT_TO_SIMULATED_STANDBY then

         p_rec.simulated_stndby_link_valid := boolean_to_yn(p_status);

  end case;

end;

/*==========================================================================*/

function get_connection_type_info(p_type number,
                                  p_standby_number number default null)
                                     return varchar2
as
l_standby_no_info varchar2(100);
begin

  if ( p_standby_number is null )
  then
     l_standby_no_info := '';
  else
     l_standby_no_info := ' Number ' || p_standby_number;
  end if;

  case p_type

    when C_CONNECT_STANDBY_TO_PRIMARY   then

         return 'Standby->Primary' || l_standby_no_info;

    when C_CONNECT_PRIMARY_TO_STANDBY   then

         return 'Primary->Standby' || l_standby_no_info;

    when C_CONNECT_TO_SIMULATED_STANDBY then

         return 'Simulated Standby' || l_standby_no_info;

  end case;

end;

/*==========================================================================*/

procedure match_connection_data(p_type number,
                                p_rec fnd_adg_control%rowtype,
                                p_standby_number number,
                                p_link_name varchar2,
                                p_link_owner varchar2,
                                p_link_connstr varchar2,
                                p_type_info varchar2)
as
l_match_link_owner         varchar2(30) := null;
l_match_link_name          varchar2(128) := null;
l_match_link_connstr       varchar2(255) := null;
begin

  case p_type

    when C_CONNECT_STANDBY_TO_PRIMARY then

         l_match_link_owner   := p_rec.stndby_to_primary_link_owner;
         l_match_link_name    := p_rec.stndby_to_primary_link_name;
         l_match_link_connstr := p_rec.stndby_to_primary_connstr;

    when C_CONNECT_PRIMARY_TO_STANDBY then

         case p_standby_number

           when 1 then
                   l_match_link_owner   := p_rec.primary_to_stndby1_link_owner;
                   l_match_link_name    := p_rec.primary_to_stndby1_link_name ;
                   l_match_link_connstr := p_rec.primary_to_stndby1_connstr   ;
           when 2 then
                   l_match_link_owner   := p_rec.primary_to_stndby2_link_owner;
                   l_match_link_name    := p_rec.primary_to_stndby2_link_name ;
                   l_match_link_connstr := p_rec.primary_to_stndby2_connstr   ;
           when 3 then
                   l_match_link_owner   := p_rec.primary_to_stndby3_link_owner;
                   l_match_link_name    := p_rec.primary_to_stndby3_link_name ;
                   l_match_link_connstr := p_rec.primary_to_stndby3_connstr   ;
           when 4 then
                   l_match_link_owner   := p_rec.primary_to_stndby4_link_owner;
                   l_match_link_name    := p_rec.primary_to_stndby4_link_name ;
                   l_match_link_connstr := p_rec.primary_to_stndby4_connstr   ;
           when 5 then
                   l_match_link_owner   := p_rec.primary_to_stndby5_link_owner;
                   l_match_link_name    := p_rec.primary_to_stndby5_link_name ;
                   l_match_link_connstr := p_rec.primary_to_stndby5_connstr   ;

         end case;

    when C_CONNECT_TO_SIMULATED_STANDBY then

         l_match_link_owner   := p_rec.simulated_stndby_link_owner;
         l_match_link_name    := p_rec.simulated_stndby_link_name;
         l_match_link_connstr := p_rec.simulated_stndby_connstr;

  end case;

  if ( l_match_link_owner   is not null and
       l_match_link_name    is not null and
       l_match_link_connstr is not null and
       (
            ( l_match_link_owner = upper(p_link_owner) and
              l_match_link_name  = upper(p_link_name) )
         or
            ( l_match_link_connstr = upper(p_link_connstr) )
       )
     )
  then
     fnd_adg_exception.raise_error
               (fnd_adg_exception.C_UTLERR_CDATA_EXISTS,p_type_info);
  end if;

end;

/*==========================================================================*/

procedure check_connection_data(p_type number,
                                p_rec fnd_adg_control%rowtype,
                                p_standby_number number,
                                p_link_name varchar2,
                                p_link_owner varchar2,
                                p_link_connstr varchar2)
as
l_type_info  varchar2(100);
begin

  l_type_info := get_connection_type_info(p_type,p_standby_number);

  case p_type

    when C_CONNECT_STANDBY_TO_PRIMARY then

	 null;  -- can be same as simulated standby.

    when C_CONNECT_PRIMARY_TO_STANDBY then

         match_connection_data(C_CONNECT_STANDBY_TO_PRIMARY,p_rec,
                               null,p_link_name,p_link_owner,p_link_connstr,
                               l_type_info);
         match_connection_data(C_CONNECT_TO_SIMULATED_STANDBY,p_rec,
                               null,p_link_name,p_link_owner,p_link_connstr,
                               l_type_info);

    when C_CONNECT_TO_SIMULATED_STANDBY then

         null;  -- can be same as standby to primary

  end case;

  for i in 1..C_MAX_STANDBY_SYSTEMS loop

    if ( ( p_type <> C_CONNECT_PRIMARY_TO_STANDBY ) or
         ( p_type = C_CONNECT_PRIMARY_TO_STANDBY and i <> p_standby_number ) )
    then
         match_connection_data(C_CONNECT_PRIMARY_TO_STANDBY,p_rec,
                               i,p_link_name,p_link_owner,p_link_connstr,
                               l_type_info);
    end if;
  end loop;

end;

/*==========================================================================*/

procedure set_connection_data(p_type number,
                              p_rec in out nocopy fnd_adg_control%rowtype,
                              p_standby_number number,
                              p_link_name varchar2,
                              p_link_owner varchar2,
                              p_link_connstr varchar2)
as
begin

  case p_type

    when C_CONNECT_STANDBY_TO_PRIMARY then

         p_rec.stndby_to_primary_link_owner := upper(p_link_owner);
         p_rec.stndby_to_primary_link_name  := upper(p_link_name);
         p_rec.stndby_to_primary_link_valid := 'N';
         p_rec.stndby_to_primary_connstr    := upper(p_link_connstr);

    when C_CONNECT_PRIMARY_TO_STANDBY then

         case p_standby_number

           when 1 then
                       p_rec.primary_to_stndby1_link_owner:= p_link_owner;
                       p_rec.primary_to_stndby1_link_name := p_link_name;
                       p_rec.primary_to_stndby1_link_valid:= 'N';
                       p_rec.primary_to_stndby1_connstr   := p_link_connstr;
           when 2 then
                       p_rec.primary_to_stndby2_link_owner:= p_link_owner;
                       p_rec.primary_to_stndby2_link_name := p_link_name;
                       p_rec.primary_to_stndby2_link_valid:= 'N';
                       p_rec.primary_to_stndby2_connstr   := p_link_connstr;
           when 3 then
                       p_rec.primary_to_stndby3_link_owner:= p_link_owner;
                       p_rec.primary_to_stndby3_link_name := p_link_name;
                       p_rec.primary_to_stndby3_link_valid:= 'N';
                       p_rec.primary_to_stndby3_connstr   := p_link_connstr;
           when 4 then
                       p_rec.primary_to_stndby4_link_owner:= p_link_owner;
                       p_rec.primary_to_stndby4_link_name := p_link_name;
                       p_rec.primary_to_stndby4_link_valid:= 'N';
                       p_rec.primary_to_stndby4_connstr   := p_link_connstr;
           when 5 then
                       p_rec.primary_to_stndby5_link_owner:= p_link_owner;
                       p_rec.primary_to_stndby5_link_name := p_link_name;
                       p_rec.primary_to_stndby5_link_valid:= 'N';
                       p_rec.primary_to_stndby5_connstr   := p_link_connstr;
         end case;

    when C_CONNECT_TO_SIMULATED_STANDBY then

         p_rec.simulated_stndby_link_owner := upper(p_link_owner);
         p_rec.simulated_stndby_link_name  := upper(p_link_name);
         p_rec.simulated_stndby_link_valid := 'N';
         p_rec.simulated_stndby_connstr    := upper(p_link_connstr);

  end case;

end;

/*==========================================================================*/

procedure check_connection_dbid(p_type number,
                                p_link_name varchar2,
                                p_link_service varchar2,
                                p_type_info varchar2)
as
l_rc number;
l_sid number;
l_serial number;
l_rpc_sid number;
l_rpc_serial number;
l_dbid number;
l_dbname varchar2(30);
l_rpc_dbid number;
l_rpc_dbname varchar2(30);
l_rpc_open_mode varchar2(30);
l_rpc_database_role varchar2(30);
l_sysguid   varchar2(64);
l_rpc_client_info varchar2(64);
l_rpc_service_name varchar2(64);

begin

  if ( p_link_name is null )
  then
     fnd_adg_exception.raise_error
               (fnd_adg_exception.C_UTLERR_LINKCHK_NULL,p_type_info);
  end if;

  begin

    execute immediate 'select 1 from dual@' || p_link_name
            into l_rc;

  exception
    when others then

       fnd_adg_exception.raise_error
               (fnd_adg_exception.C_UTLERR_LINKCHK_TNS,
                    p_type_info||' '||sqlerrm);

  end;

	/* Get my sid/serial */

  select a.sid,a.serial#
    into l_sid,l_serial
    from v$session a
   where a.sid = ( select distinct b.sid from v$mystat b);

	/* Make sure not a loopback session */

   execute immediate
           'select a.sid,a.serial#,a.service_name ' ||
           '  from v$session@'||p_link_name|| ' a' ||
           ' where a.sid = ' ||
               ' ( select distinct b.sid from v$mystat@'||p_link_name||' b)'
      into l_rpc_sid,l_rpc_serial,l_rpc_service_name;

/*
   sys.dbms_output.put_line
	( 'l_sid='||l_sid || ' l_serial='|| l_serial ||
          ' l_rpc_sid='|| l_rpc_sid || ' l_rpc_serial='|| l_rpc_serial);
*/

   if ( l_sid = l_rpc_sid and
        l_serial = l_rpc_serial )
   then
      fnd_adg_exception.raise_error
               (fnd_adg_exception.C_UTLERR_LINKCHK_LOOPBACK,
                                  p_type_info);
   end if;

	/* Make sure same dbid,name */

   select a.dbid,a.name
     into l_dbid,l_dbname
     from v$database a;

   execute immediate
           'select a.dbid,a.name,a.open_mode,a.database_role ' ||
           '  from v$database@'||p_link_name|| ' a'
      into l_rpc_dbid,l_rpc_dbname,l_rpc_open_mode,l_rpc_database_role;

   if ( l_dbid <> l_rpc_dbid or
        l_dbname <> l_rpc_dbname )
   then
      fnd_adg_exception.raise_error
               (fnd_adg_exception.C_UTLERR_LINKCHK_BAD_DBID,
                p_type_info||' This DBID/Name '|| l_dbid || '-' || l_dbname
                           ||' RPC DBID/Name '|| l_rpc_dbid||'-'|| l_rpc_dbname
               );
   end if;

	/* Handle read-write/read only */

   if ( p_type = C_CONNECT_STANDBY_TO_PRIMARY or
        p_type = C_CONNECT_TO_SIMULATED_STANDBY )
   then
	/* Make sure rpc is primary and read write. */

      if ( l_rpc_open_mode <> C_OPEN_READ_WRITE or
           l_rpc_database_role <> C_PRIMARY_ROLE )
      then
         fnd_adg_exception.raise_error
                  (fnd_adg_exception.C_UTLERR_LINKCHK_BAD_DB_ROLE,
                   p_type_info);
      end if;

	/* And just in case db is a clone with same dbid see if remote
	   can find my session.
	*/

      l_sysguid := rawtohex(sys_guid);

      DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_sysguid);

      begin

         execute immediate
                 'select a.client_info ' ||
                 '  from v$session@'||p_link_name|| ' a' ||
                 ' where a.sid = ' || l_sid ||
                 '   and a.serial# = ' || l_serial
            into l_rpc_client_info;

      exception
        when no_data_found then

             l_rpc_client_info := null;
      end;

      if ( l_rpc_client_info is null or
           l_rpc_client_info <> l_sysguid )
      then
         fnd_adg_exception.raise_error
                  (fnd_adg_exception.C_UTLERR_LINKCHK_RPC_IS_CLONE,
                   p_type_info);
      end if;

   end if;

   if ( p_type = C_CONNECT_PRIMARY_TO_STANDBY )
   then

        /* Make sure rpc is standby and read only. */

      if ( instr(l_rpc_open_mode,C_OPEN_READ_ONLY) = 0 or
           l_rpc_database_role <> C_STANDBY_ROLE )
      then
         fnd_adg_exception.raise_error
                  (fnd_adg_exception.C_UTLERR_LINKCHK_BAD_STANDBY,
                   p_type_info);
      end if;

   end if;

   if ( p_type = C_CONNECT_TO_SIMULATED_STANDBY )
   then
        /* Make sure matching service */

      if ( p_link_service is null or l_rpc_service_name is null or
           upper(p_link_service) <> upper(l_rpc_service_name) )
      then
         fnd_adg_exception.raise_error
                  (fnd_adg_exception.C_UTLERR_LINKCHK_BAD_SERVICE,
                   p_type_info);
      end if;

   end if;

end;

/*==========================================================================*/

procedure scan_trace_file_for_violations(p_adg_control fnd_adg_control%rowtype,
                                         p_adg_violations in out nocopy number,
                                         p_trace_error in out nocopy number,
                                         p_trace_file_name in out
                                                              nocopy varchar2)
as
l_trace_fno utl_file.file_type;
l_trace_rec varchar2(32767);
l_idx number;
l_directory_path varchar2(4000);
l_tracefile     varchar2(2048) := null;

begin

  p_adg_violations := 0;
  p_trace_error := 0;
  p_trace_file_name := null;

  if ( p_adg_control.simulated_stndby_trc_dir_obj is null )
  then
     return;
  end if;

  begin

    select DIRECTORY_PATH
      into l_directory_path
      from all_directories
     where DIRECTORY_NAME=p_adg_control.simulated_stndby_trc_dir_obj
       and owner= 'SYS';

  exception

     when others then
              return;

  end;

        -- Backwards compatibility - tracefile doesn't exit in 10g.

  l_tracefile := null;

  begin

    execute immediate
             'select b.tracefile ' ||
             '   from v$session a,v$process b ' ||
             '  where a.sid = ( select distinct c.sid from v$mystat c) ' ||
             '    and a.paddr = b.addr'
       into l_tracefile;

  exception
     when no_data_found then

          l_tracefile := null;
  end;

  if ( l_tracefile is null )
  then
     return;
  end if;

  p_trace_error := 0;

  begin

    p_trace_file_name := substr(l_tracefile,length(l_directory_path)+2);

    l_trace_fno := utl_file.fopen(p_adg_control.simulated_stndby_trc_dir_obj,
                                  p_trace_file_name,'r',32767);

  exception
     when utl_file.INVALID_PATH
        then
           p_trace_error := 1;
     when utl_file.INVALID_OPERATION
        then
           p_trace_error := 2;
     when others
        then
           p_trace_error := 3;
  end;

  if ( p_trace_error = 0 )
  then

    loop

      begin

        utl_file.get_line(l_trace_fno,l_trace_rec);

      exception
        when no_data_found
             then exit;

        when others
             then
                p_trace_error := 4;
                exit;
      end;

      l_idx := instr(l_trace_rec,C_MAGIC_SWITCH_IDENT);

      -- if ( l_idx > 0 )
      if ( l_idx = 1 )
      then
         p_adg_violations := p_adg_violations + 1;
      end if;

    end loop;

    utl_file.fclose(l_trace_fno);

  end if;

end;

/*==========================================================================*/

procedure do_process_adg_violations(p_logoff boolean,
                                    p_application_id number default null,
                                    p_concurrent_program_id number default null)
as
l_rec fnd_adg_control%rowtype;

l_adg_violations number := 0;
l_trace_violations number := 0;
l_trace_error number := 0;
l_trace_file_name varchar2(1000);
l_magic_switch_enabled boolean;
l_request_id number;
l_new_style_magic_switch boolean;

begin

  l_magic_switch_enabled := G_MAGIC_SWITCH_ENABLED;

  disable_violation_trace;

	-- Cannot do DML if on standby  - but we can't just check
	-- is_standby as in simulation mode it will return true on primary.
	-- Use is_true_standby

  if ( fnd_adg_support.is_true_standby )
  then
     return;
  end if;

  if ( not is_session_simulated_standby )
  then
     return;
  end if;

	/* We can't be here unless supported release. Check
	   whether new style magic switch. */

  l_new_style_magic_switch := is_new_style_magic_switch;

  l_rec := get_adg_control;

	/* Try scanning the trace file. */

  scan_trace_file_for_violations(l_rec,l_trace_violations,l_trace_error,
                                 l_trace_file_name);

	/* Now V$ */

  l_adg_violations := 0;

  if ( l_new_style_magic_switch )
  then

      begin

        select a.value
          into l_adg_violations
          from v$mystat a, v$statname b
         where a.statistic# = b.statistic#
           and b.name = 'read-only violation count';

      exception
         when others then
              l_adg_violations := 0;
      end;

  else

      begin

        select a.value
          into l_adg_violations
          from v$mystat a, v$statname b
         where a.statistic# = b.statistic#
           and b.name = 'spare statistic 1';

      exception
         when others then
              l_adg_violations := 0;
      end;

  end if;

	/* Which one to choose ! */

  if ( l_trace_violations <> l_adg_violations )
  then
     if ( l_trace_violations > l_adg_violations )
     then
        l_trace_error := l_trace_error + 100;
        l_adg_violations := l_trace_violations;
     else
        l_trace_error := l_trace_error + 200;
     end if;
  end if;

  begin
    l_request_id := fnd_global.conc_request_id;
  exception
    when others then
         l_request_id := null;
  end;

  log_adg_violations(l_request_id,l_adg_violations,
                     boolean_to_yn(l_magic_switch_enabled),
                     l_trace_file_name, l_trace_error);

  if ( l_adg_violations > get_simulation_error_threshold )
  then
     if ( p_logoff )
     then
        fnd_adg_support.handle_standby_error
                     (l_request_id,true,p_logoff,
                      l_adg_violations - get_simulation_error_threshold);
     else
        fnd_adg_support.handle_standby_error
                     (p_application_id,p_concurrent_program_id,true,p_logoff,
                      l_adg_violations - get_simulation_error_threshold);
     end if;
  end if;

end;

/*==========================================================================*/

procedure set_database_triggers(p_enable boolean)
as
cursor c1 is select a.status,a.object_name
               from dba_objects a
              where a.owner = user
                and a.object_name in
                        ( C_ERROR_TRIGGER,C_LOGON_TRIGGER,C_LOGOFF_TRIGGER )
                and a.object_type = 'TRIGGER';

begin

  check_standby_support;

  check_rpc_state(true);
  check_adg_state(false);

  for f_rec in c1 loop

    if ( not p_enable )
    then
       execute immediate 'alter trigger ' || f_rec.object_name || ' disable';
    else
       if ( f_rec.status = 'INVALID' )
       then
          execute immediate 'alter trigger ' || f_rec.object_name || ' compile';
       end if;

       execute immediate 'alter trigger ' || f_rec.object_name || ' enable';
    end if;

  end loop;

end;

/*==========================================================================*/
/*==================== Start of public methods =============================*/
/*==========================================================================*/

/*==========================================================================*/

function get_program_access_code return number
as
l_access_code number;
begin

  l_access_code := G_CONC_PROGRAM_ACCESS_CODE;

  set_program_access_code;

  return l_access_code;

end;

/*==========================================================================*/

procedure clone_clean(p_commit boolean default true)
as
l_rec fnd_adg_control%rowtype;
begin

        -- Dummy get_adg_control. This ensure that on a fresh system
        -- we auto_init the required data.

  l_rec := get_adg_control;

  check_standby_support;

  delete from fnd_adg_commit_wait;
  delete from fnd_adg_simulated_stndby_trc;

  clean_adg_control(false);

  if ( p_commit )
  then
     commit;
  end if;

end;

/*==========================================================================*/

procedure clean_all(p_commit boolean default true)
as
l_rec fnd_adg_control%rowtype;
begin

        -- Dummy get_adg_control. This ensure that on a fresh system
        -- we auto_init the required data.

  l_rec := get_adg_control;

  check_standby_support;

  clean_adg_control(false,true,true);

  delete from fnd_adg_concurrent_program;

  clone_clean(false);

  fnd_adg_object.init_package_list;

  if ( p_commit )
  then
     commit;
  end if;

end;

/*==========================================================================*/

function get_standby_to_primary_dblink return varchar2
as
l_rec fnd_adg_control%rowtype;
begin

  check_standby_support;

  l_rec := get_adg_control;

  return l_rec.stndby_to_primary_link_name;

end;

/*==========================================================================*/

function is_connection_registered(p_connstr varchar2,
                                  p_check_valid boolean default false,
                                  p_check_available boolean default false)
              return boolean
as
l_rec fnd_adg_control%rowtype;

l_standby_number number := 0;
l_found_connection boolean := false;

l_link_name varchar2(128);
l_link_owner varchar2(30);
l_link_valid varchar2(10);
l_connstr    varchar2(255);
l_link_service varchar2(64);
l_connection_type number;

l_type_info  varchar2(255);

begin

  if ( not is_standby_access_supported )
  then
     return false;
  end if;

  if ( p_connstr is null )
  then
     return false;
  end if;

  l_rec := get_adg_control;

  for i in 1..C_MAX_STANDBY_SYSTEMS loop

    if ( find_primary_to_standby(l_rec,i,upper(p_connstr)) )
    then
       l_standby_number := i;
       l_connection_type := C_CONNECT_PRIMARY_TO_STANDBY;
       l_found_connection := true;
       exit;
    end if;

  end loop;

  if ( not l_found_connection )
  then
     l_connection_type := C_CONNECT_TO_SIMULATED_STANDBY;
  end if;

  get_connection_data(l_connection_type,l_rec,l_standby_number,
                      l_link_name,l_link_owner,l_connstr,l_link_valid,
                      l_link_service);

  if ( l_connstr is null )
  then
     return false;
  end if;

  if ( l_connstr <> upper(p_connstr) )
  then
     return false;
  end if;

  if ( not p_check_valid and not p_check_available )
  then
     return true;
  end if;

	-- No point going any further if ADG support has not been enabled.

  if ( not is_adg_support_enabled )
  then
     return false;
  end if;

  if ( p_check_valid and not yn_to_boolean(l_link_valid) )
  then
     return false;
  end if;

  if ( p_check_available )
  then

     l_type_info := get_connection_type_info(l_connection_type,
                                             l_standby_number);

     begin

       check_connection_dbid(l_connection_type,l_link_name,l_link_service,
                             l_type_info);
     exception
         when others then
              return false;
     end;

  end if;

  return true;

end;

/*==========================================================================*/

procedure find_registered_standby(p_connstr varchar2,
                                  p_exists  out nocopy boolean,
                                  p_valid   out nocopy boolean,
                                  p_req_class_app_id out nocopy number,
                                  p_req_class_id out nocopy number
                                 )
as
l_rec fnd_adg_control%rowtype;
l_link_name varchar2(128);
l_link_owner varchar2(30);
l_link_valid varchar2(10);
l_connstr    varchar2(255);
l_link_service varchar2(64);
l_req_class_app_id number;
l_req_class_id number;
begin

       -- No rpc checks as should only call be embedded clients. And
       -- it's just a look up.

  p_exists := false;
  p_valid  := false;
  p_req_class_app_id := -1;
  p_req_class_id := -1;

  if ( p_connstr is null )
  then
     return;
  end if;

  l_rec := get_adg_control;

  for i in 1..C_MAX_STANDBY_SYSTEMS loop

    if ( find_primary_to_standby(l_rec,i,upper(p_connstr)) )
    then

       p_exists := true;

       get_connection_data(C_CONNECT_PRIMARY_TO_STANDBY,l_rec,i,
                           l_link_name,l_link_owner,l_connstr,l_link_valid,
                           l_link_service);

       p_valid  := yn_to_boolean(l_link_valid);

       get_cm_class_data(l_rec,i,l_req_class_app_id,l_req_class_id);

       p_req_class_app_id := l_req_class_app_id;
       p_req_class_id     := l_req_class_id;

       return;

    end if;

  end loop;

  return;

end;

/*==========================================================================*/

procedure register_connection(p_type number,
                              p_link_name varchar2,
                              p_link_owner varchar2 default 'PUBLIC',
                              p_link_connstr varchar2 default null,
                              p_create_db_link_if_undefined
                                               boolean default false,
                              p_standby_number number default null
                             )
as
cursor c1 is select a.owner,a.DB_LINK,upper(a.host) host
               from all_db_links a
              where a.owner = upper(p_link_owner)
                and a.DB_LINK = upper(p_link_name);

l_rec fnd_adg_control%rowtype;

found_db_link boolean := false;
l_connstr1 varchar2(2000);

begin

  check_standby_support;
  check_connection_type(p_type);

	-- RPC state can be on or off except for standby_to_primary.

  if ( p_type = C_CONNECT_STANDBY_TO_PRIMARY )
  then
     check_rpc_state(false);
  end if;

  check_adg_state(false);

  if ( p_type = C_CONNECT_PRIMARY_TO_STANDBY )
  then
     check_standby_number(p_standby_number);
  end if;

  if ( p_link_owner is null or p_link_name is null )
  then
     fnd_adg_exception.raise_error(fnd_adg_exception.C_UTLERR_REGISTER_LINK_IS_NULL);
  end if;

  if ( C_FORCE_PUBLIC_DBLINK and upper(p_link_owner) <> 'PUBLIC' )
  then
     fnd_adg_exception.raise_error(fnd_adg_exception.C_UTLERR_OWNER_NOT_PUBLIC);
  end if;

  if ( p_link_connstr is not null and
       length(p_link_connstr) > C_MAX_CONNSTR_LENGTH )
  then
     fnd_adg_exception.raise_error(fnd_adg_exception.C_UTLERR_CONNSTR_TOO_LONG,
                                   to_char(C_MAX_CONNSTR_LENGTH));
  end if;

  l_rec := get_adg_control;

  if ( p_type = C_CONNECT_PRIMARY_TO_STANDBY )
  then
     if ( l_rec.stndby_to_primary_link_owner is not null and
          l_rec.stndby_to_primary_link_name is not null and
          l_rec.stndby_to_primary_link_owner = upper(p_link_owner) and
          l_rec.stndby_to_primary_link_name = upper(p_link_name) )
     then
        fnd_adg_exception.raise_error
             (fnd_adg_exception.C_UTLERR_STDBY_P_LINKS_MATCH,p_link_name);
     end if;
  end if;

  check_connection_data(p_type,l_rec,p_standby_number,
                        p_link_name,p_link_owner,p_link_connstr);

  for f_rec in c1 loop

    found_db_link := true;

    if ( p_link_connstr is not null and
         f_rec.host <> upper(p_link_connstr) )
    then
       fnd_adg_exception.raise_error
                        (fnd_adg_exception.C_UTLERR_LINK_HOST_MISMATCH,
                         p_link_name );
    end if;

    l_connstr1 := f_rec.host;

    exit;

  end loop;

  if ( not found_db_link )
  then
     if ( p_create_db_link_if_undefined and C_FORCE_PUBLIC_DBLINK  and
          p_link_connstr is not null )
     then
        execute immediate
           ' create public database link ' || p_link_name || ' using ' ||
              '''' || upper(p_link_connstr) || '''' ;

        l_connstr1 := upper(p_link_connstr);
     else
        fnd_adg_exception.raise_error(fnd_adg_exception.C_UTLERR_REG_LINK_NOT_FOUND,
                                   p_link_name );
     end if;
  end if;

  l_rec := get_and_lock_adg_control;

  set_connection_data(p_type,l_rec,p_standby_number,
                      upper(p_link_name),upper(p_link_owner),
                      upper(l_connstr1));

  update_adg_control(l_rec);

end;

/*==========================================================================*/

procedure clear_connection(p_type number,
                           p_standby_number number default null)
as
l_rec fnd_adg_control%rowtype;

found_db_link boolean := false;
l_connstr1 varchar2(2000);

begin

  check_standby_support;
  check_connection_type(p_type);

        -- RPC state can be on or off except for standby_to_primary.

  if ( p_type = C_CONNECT_STANDBY_TO_PRIMARY )
  then
     check_rpc_state(false);
  end if;

  check_adg_state(false);

  if ( p_type = C_CONNECT_PRIMARY_TO_STANDBY )
  then
     if ( p_standby_number is not null ) -- allow for cleanup of all entries
     then
        check_standby_number(p_standby_number);
     end if;
  end if;

  l_rec := get_and_lock_adg_control;

  if ( p_type = C_CONNECT_PRIMARY_TO_STANDBY and p_standby_number is null )
  then
     for i in 1..C_MAX_STANDBY_SYSTEMS loop

       set_connection_data(p_type,l_rec,i,null,null,null);

     end loop;
  else
     set_connection_data(p_type,l_rec,p_standby_number,null,null,null);
  end if;

  update_adg_control(l_rec);

end;

/*==========================================================================*/

procedure validate_connection(p_type number,
                              p_standby_number number default null)
as
l_rec fnd_adg_control%rowtype;
l_link_name varchar2(128);
l_link_owner varchar2(30);
l_link_valid varchar2(10);
l_connstr    varchar2(255);
l_link_service varchar2(64);
l_type_info  varchar2(255);

begin

  check_standby_support;
  check_connection_type(p_type);

        -- RPC state can be on or off except for standby_to_primary.

  if ( p_type = C_CONNECT_STANDBY_TO_PRIMARY )
  then
     check_rpc_state(false);
  end if;

  check_adg_state(false);

  if ( p_type = C_CONNECT_PRIMARY_TO_STANDBY )
  then
     check_standby_number(p_standby_number);
  end if;

	-- First mark as invalid in case of errors.

  l_rec := get_and_lock_adg_control;

  set_connection_valid(p_type,l_rec,false,p_standby_number);

  update_adg_control(l_rec);

  l_rec := get_adg_control;

  get_connection_data(p_type,l_rec,p_standby_number,
                      l_link_name,l_link_owner,l_connstr,l_link_valid,
                      l_link_service);

  l_type_info := get_connection_type_info(p_type,p_standby_number);

  check_connection_dbid(p_type,l_link_name,l_link_service,l_type_info);

  l_rec := get_and_lock_adg_control;

  set_connection_valid(p_type,l_rec,true,p_standby_number);

  update_adg_control(l_rec);

end;

/*==========================================================================*/

procedure get_connection_data(p_type number,
                              p_valid out nocopy boolean,
                              p_connstr out nocopy varchar2,
                              p_standby_number number default null
                             )
as
l_rec fnd_adg_control%rowtype;
l_link_name varchar2(128);
l_link_owner varchar2(30);
l_link_valid varchar2(10);
l_connstr    varchar2(255);
l_link_service varchar2(64);
begin

	-- No rpc checks as should only call be embedded clients. And
        -- it's just a look up.

  check_connection_type(p_type);

  if ( p_type = C_CONNECT_PRIMARY_TO_STANDBY )
  then
     if ( p_standby_number is not null )
     then
        check_standby_number(p_standby_number);
     end if;
  end if;

  l_rec := get_adg_control;

  get_connection_data(p_type,l_rec,p_standby_number,
                      l_link_name,l_link_owner,l_connstr,l_link_valid,
                      l_link_service);


  p_valid := yn_to_boolean(l_link_valid);
  p_connstr := l_connstr;

end;

/*==========================================================================*/

procedure get_standby_cm_class       (p_standby_number number,
                                      p_req_class_app_id out nocopy number,
                                      p_req_class_id out nocopy number )
as
l_rec fnd_adg_control%rowtype;
begin

  check_standby_number(p_standby_number);

  l_rec := get_adg_control;

  p_req_class_app_id := null;
  p_req_class_id := null;

  get_cm_class_data(l_rec,p_standby_number,p_req_class_app_id,p_req_class_id);

end;

/*==========================================================================*/

procedure register_standby_cm_class  (p_standby_number number,
                                      p_req_class_app_id number,
                                      p_req_class_id number )
as
l_rec fnd_adg_control%rowtype;
begin

  check_standby_support;

        -- RPC state can be on or off

  check_adg_state(false);

  check_standby_number(p_standby_number);

  if ( not is_standby_manager_defined(p_req_class_app_id,p_req_class_id,false))
  then
     fnd_adg_exception.raise_error
                          (fnd_adg_exception.C_UTLERR_REG_CM_NOT_DEFINED);
  end if;

  l_rec := get_and_lock_adg_control;

  set_cm_class_data(l_rec,p_standby_number,p_req_class_app_id,p_req_class_id);

  update_adg_control(l_rec);

end;

/*==========================================================================*/

procedure set_simulated_standby_options(p_enable_simulated_standby
                                               boolean default null,
                                        p_enable_auto_simulation
                                               boolean default null,
                                        p_simulated_standby_service
                                                 varchar2 default null,
                                        p_simulation_error_threshold
                                                 number default null,
                                        p_trace_directory_obj
                                                 varchar2 default null)

as
l_rec fnd_adg_control%rowtype;
l_dir_obj_ok number;
begin

  check_standby_support;

       -- RPC state can be on or off as we're just registering options.

  check_adg_state(false);

  l_rec := get_and_lock_adg_control;

  if ( p_enable_auto_simulation is not null )
  then
     l_rec.enable_auto_simulated_standby :=
                  boolean_to_yn(p_enable_auto_simulation);
  end if;

  if ( p_simulated_standby_service is not null )
  then
     l_rec.simulated_standby_service := upper(p_simulated_standby_service);
  end if;

  if ( p_enable_simulated_standby is not null )
  then
     l_rec.enable_simulated_standby :=
                   boolean_to_yn(p_enable_simulated_standby);
  end if;

  if ( p_trace_directory_obj is not null )
  then

     select count(*)
       into l_dir_obj_ok
       from all_directories
      where DIRECTORY_NAME=p_trace_directory_obj
        and owner= 'SYS';

     if ( l_dir_obj_ok <> 1 )
     then
        fnd_adg_exception.raise_error
			(fnd_adg_exception.C_UTLERR_BAD_DIR_OBJECT);
     end if;

     l_rec.simulated_stndby_trc_dir_obj := p_trace_directory_obj;

  end if;

  if ( p_simulation_error_threshold is not null )
  then
     if ( p_simulation_error_threshold >= C_MIN_ERROR_THRESHOLD and
          p_simulation_error_threshold <= C_MAX_ERROR_THRESHOLD )
     then
        l_rec.simulation_error_threshold := p_simulation_error_threshold;
     end if;
  end if;

  update_adg_control(l_rec);

end;

/*==========================================================================*/

procedure validate_adg_support(p_no_standby_systems number default null)
as
l_rec fnd_adg_control%rowtype;
l_no_standby_systems number;
begin

  check_standby_support;

  check_rpc_state(false);
  check_adg_state(false);

  if ( p_no_standby_systems is null )
  then
     l_no_standby_systems := C_MAX_STANDBY_SYSTEMS;
  else
     l_no_standby_systems := p_no_standby_systems;
  end if;

  if ( l_no_standby_systems <> 0 )
  then
     check_standby_number(l_no_standby_systems);
  end if;

  validate_connection(fnd_adg_utility.C_CONNECT_STANDBY_TO_PRIMARY);
  validate_connection(fnd_adg_utility.C_CONNECT_TO_SIMULATED_STANDBY);

  for i in 1..l_no_standby_systems loop

    validate_connection(fnd_adg_utility.C_CONNECT_PRIMARY_TO_STANDBY,i);

  end loop;

end;

/*==========================================================================*/

procedure enable_adg_support
as
l_rec fnd_adg_control%rowtype;
begin

  check_standby_support;

  check_rpc_state(true);
  check_adg_state(false);

	-- Check that RPC packages are enabled and being used.

  fnd_adg_object.validate_package_usage(true);

  l_rec := get_and_lock_adg_control;

  set_rpc_state(l_rec,C_RPC_ADG_ENABLED);

  l_rec.enable_adg_support := 'Y';

  update_adg_control(l_rec);

end;

/*==========================================================================*/

procedure disable_adg_support
as
l_rec fnd_adg_control%rowtype;
begin

  check_standby_support;

  check_rpc_state(true);
  check_adg_state(true);

  l_rec := get_and_lock_adg_control;

  clr_rpc_state(l_rec,C_RPC_ADG_ENABLED);

  l_rec.enable_adg_support := 'N';

  update_adg_control(l_rec);

end;

/*==========================================================================*/

procedure set_control_options(p_enable_commit_wait boolean default null,
                              p_max_commit_wait_time number default null,
                              p_runtime_validate_timestamp
                                                     boolean default null,
                              p_always_collect_primary_data
                                                     boolean default null,
                              p_enable_redirect_if_valid
                                                     boolean default null,
                              p_enable_standby_error_checks
                                                     boolean default null,
                              p_enable_automatic_redirection
                                                     boolean default null,
                              p_standby_error_threshold number default null,
                              p_debug_rpc number default null,
                              p_debug_slave_rpc number default null
                             )
as
l_rec fnd_adg_control%rowtype;
begin

  check_standby_support;

       -- RPC state can be on or off as we're just registering options.

  check_adg_state(false);

  l_rec := get_and_lock_adg_control;

  if ( p_enable_commit_wait is not null )
  then
     l_rec.enable_commit_wait := boolean_to_yn(p_enable_commit_wait);
  end if;

  if ( p_max_commit_wait_time is not null )
  then
     if ( p_max_commit_wait_time >= 1 and
          p_max_commit_wait_time <= C_MAX_COMMIT_WAIT_TIME )
     then
        l_rec.max_commit_wait_time := p_max_commit_wait_time;
     end if;
  end if;

  if ( p_debug_rpc is not null )
  then
     l_rec.debug_rpc := p_debug_rpc;
  end if;

  if ( p_debug_slave_rpc is not null )
  then
     l_rec.debug_slave_rpc := p_debug_slave_rpc;
  end if;

  if ( p_runtime_validate_timestamp is not null )
  then
     l_rec.runtime_validate_timestamp
                 := boolean_to_yn(p_runtime_validate_timestamp);
  end if;

  if ( p_always_collect_primary_data is not null )
  then
     l_rec.always_collect_primary_data
                 := boolean_to_yn(p_always_collect_primary_data);
  end if;

  if ( p_enable_redirect_if_valid is not null )
  then
     l_rec.enable_redirect_if_valid
                 := boolean_to_yn(p_enable_redirect_if_valid);
  end if;

  if ( p_enable_standby_error_checks is not null )
  then
      l_rec.enable_standby_error_checks
                     := boolean_to_yn(p_enable_standby_error_checks);
  end if;

  if ( p_enable_automatic_redirection is not null )
  then
      l_rec.enable_automatic_redirection
                     := boolean_to_yn(p_enable_automatic_redirection);
  end if;

  if ( p_standby_error_threshold is not null )
  then
     if ( p_standby_error_threshold >= C_MIN_ERROR_THRESHOLD and
          p_standby_error_threshold <= C_MAX_ERROR_THRESHOLD )
     then
        l_rec.standby_error_threshold := p_standby_error_threshold;
     end if;
  end if;

  update_adg_control(l_rec);

end;

/*==========================================================================*/

procedure prepare_for_rpc_system
as
l_rec fnd_adg_control%rowtype;
begin

  check_standby_support;

  check_rpc_state(false);
  check_adg_state(false);

        -- First mark as invalid in case of errors.

  l_rec := get_and_lock_adg_control;

  clr_rpc_state(l_rec,C_RPC_SYSTEM_PREPARED);

  update_adg_control(l_rec);

	-- Build/compile

  fnd_adg_object.build_all_packages;

	-- Build remote synonyms - may be null but they will be
	-- rebuilt during switch.
	-- Otherwise first time through compile will fail.

  fnd_adg_object.build_all_synonyms;

  fnd_adg_object.compile_all_packages;

  l_rec := get_and_lock_adg_control;

  set_rpc_state(l_rec,C_RPC_SYSTEM_PREPARED);

  update_adg_control(l_rec);

end;

/*==========================================================================*/

procedure switch_rpc_system_on
as
l_rec fnd_adg_control%rowtype;
begin

  check_standby_support;

  check_rpc_state(false);
  check_adg_state(false);

  l_rec := get_adg_control;

  if ( not is_rpc_state(l_rec,C_RPC_SYSTEM_PREPARED) )
  then
     fnd_adg_exception.raise_error
                 (fnd_adg_exception.C_UTLERR_RPC_SYSTEM_NOT_PREPED);
  end if;

	-- Check that RPC packages are using adg_compile_directive.
	-- Best guess pre-enable that packages are the correct version.

  fnd_adg_object.validate_package_usage(false);

	-- Validate connection

  validate_connection(C_CONNECT_STANDBY_TO_PRIMARY);

  l_rec := get_adg_control;

  if ( not yn_to_boolean(l_rec.stndby_to_primary_link_valid) )
  then
     fnd_adg_exception.raise_error
                 (fnd_adg_exception.C_UTLERR_RPC_SYSTEM_LINK_BAD);
  end if;

  fnd_adg_object.build_all_synonyms;

  fnd_adg_object.compile_directive(true);

  l_rec := get_and_lock_adg_control;

  set_rpc_state(l_rec,C_RPC_SYSTEM_ENABLED);

  update_adg_control(l_rec);

end;

/*==========================================================================*/

procedure switch_rpc_system_off
as
l_rec fnd_adg_control%rowtype;
begin

  check_standby_support;

  check_rpc_state(true);
  check_adg_state(false);

  fnd_adg_object.compile_directive(false);

  l_rec := get_and_lock_adg_control;

  clr_rpc_state(l_rec,C_RPC_SYSTEM_ENABLED);

  update_adg_control(l_rec);

end;

/*==========================================================================*/

procedure resync_compile_directive
as
l_rec fnd_adg_control%rowtype;
l_compile_state boolean;
l_rpc_state boolean;
begin

	-- If the compile directive is out of sync with RPC state,
	-- then resync - source of truth is RPC state. This procedure
	-- doesn't check rpc/adg state as these assume directive
	-- is in sync.

  l_rec := get_adg_control;

  l_rpc_state := is_rpc_state(l_rec,C_RPC_SYSTEM_ENABLED) ;

  l_compile_state := compile_directive_state;

  if ( ( l_compile_state and l_rpc_state ) or
       ( not l_compile_state and not l_rpc_state ) )
  then
     null;
  else
     fnd_adg_object.compile_directive(l_rpc_state);
  end if;

end;

/*==========================================================================*/

procedure compile_rpc_dependents
as
l_rec fnd_adg_control%rowtype;
begin

  check_standby_support;

	-- rpc state can be on or off

  check_adg_state(false);

  l_rec := get_adg_control;

  if ( not is_rpc_state(l_rec,C_RPC_SYSTEM_PREPARED) )
  then
     fnd_adg_exception.raise_error
                 (fnd_adg_exception.C_UTLERR_RPC_SYSTEM_NOT_PREPED);
  end if;

  fnd_adg_object.compile_rpc_dependents;

	-- Finally one extra case - FND_ADG_SUPPORT - which has a
	-- compile directive dependency.

  execute immediate 'alter package FND_ADG_SUPPORT compile body';

  execute immediate 'alter trigger ' || C_CP_BEFORE_INSERT || ' compile';
  execute immediate 'alter trigger ' || C_CP_AFTER_UPDATE || ' compile';

end;

/*==========================================================================*/

function is_standby_access_supported return boolean
as
l_db_version varchar2(128);
l_db_compat varchar2(128);
l_major_version number;

begin

  dbms_utility.db_version(l_db_version,l_db_compat);

  l_major_version:=to_number(substr(l_db_version,1,instr(l_db_version,'.')-1));

  if ( l_major_version >= 11 )
  then
     return true;
  else
     return false;
  end if;

end;

/*==========================================================================*/

function is_adg_support_enabled return boolean
as
l_rec fnd_adg_control%rowtype;
begin

  l_rec := get_adg_control;

  if ( is_rpc_state(l_rec,C_RPC_ADG_ENABLED)  and
       yn_to_boolean(l_rec.enable_adg_support) )
  then
     return true;
  else
     return false;
  end if;

end;

/*==========================================================================*/

procedure manage_concurrent_program
                       (p_application_id              number,
                        p_concurrent_program_id       number,
                        p_has_run_on_primary          boolean default null,
                        p_has_run_on_simulated_standby boolean default null,
                        p_run_on_standby              boolean default null,
                        p_no_standby_failures         number default null,
                        p_max_standby_failures        number default null,
                        p_no_simulated_stdby_failures number default null,
                        p_max_simulated_stdby_failures number default null,
                        p_always_redirect_if_valid    boolean default null,
                        p_use_automatic_redirection   boolean default null
                       )
as
l_code number;
begin

  check_standby_support;

	-- ADG state can only be true when RPC is true.

  check_adg_state(true);

  set_program_access_code;

  l_code := G_CONC_PROGRAM_ACCESS_CODE; -- use global as get_ method
				        -- resets code - i.e. use once by
				        -- client.

  fnd_adg_support.handle_concurrent_program
                       (l_code,
                        p_application_id              ,
                        p_concurrent_program_id       ,
                        p_has_run_on_primary          ,
                        p_has_run_on_simulated_standby,
                        p_run_on_standby              ,
                        p_no_standby_failures         ,
                        p_max_standby_failures        ,
                        p_no_simulated_stdby_failures ,
                        p_max_simulated_stdby_failures,
                        p_always_redirect_if_valid,
                        p_use_automatic_redirection
                       );

end;

/*==========================================================================*/

function is_runtime_validate_timestamp return boolean
as
l_rec fnd_adg_control%rowtype;
begin

  l_rec := get_adg_control;

  if ( yn_to_boolean(l_rec.runtime_validate_timestamp) )
  then
     return true;
  else
     return false;
  end if;

end;

/*==========================================================================*/

function is_always_collect_primary_data return boolean
as
l_rec fnd_adg_control%rowtype;
begin

  l_rec := get_adg_control;

  if ( yn_to_boolean(l_rec.always_collect_primary_data) )
  then
     return true;
  else
     return false;
  end if;

end;

/*==========================================================================*/

function is_enable_redirect_if_valid return boolean
as
l_rec fnd_adg_control%rowtype;
begin

  l_rec := get_adg_control;

  if ( yn_to_boolean(l_rec.enable_redirect_if_valid) )
  then
     return true;
  else
     return false;
  end if;

end;

/*==========================================================================*/

function is_standby_error_checking return boolean
as
l_rec fnd_adg_control%rowtype;
begin

  l_rec := get_adg_control;

  if ( yn_to_boolean(l_rec.enable_standby_error_checks) )
  then
     return true;
  else
     return false;
  end if;

end;

/*==========================================================================*/

function is_automatic_redirection return boolean
as
l_rec fnd_adg_control%rowtype;
begin

  l_rec := get_adg_control;

  if ( yn_to_boolean(l_rec.enable_automatic_redirection) )
  then
     return true;
  else
     return false;
  end if;

end;

/*==========================================================================*/

function get_standby_error_threshold return number
as
l_rec fnd_adg_control%rowtype;
begin

  l_rec := get_adg_control;

  return l_rec.standby_error_threshold;

end;

/*==========================================================================*/

function get_simulation_error_threshold return number
as
l_rec fnd_adg_control%rowtype;
begin

  l_rec := get_adg_control;

  return l_rec.simulation_error_threshold;

end;

/*==========================================================================*/

function is_simulated_standby_enabled return boolean
as
l_rec fnd_adg_control%rowtype;
begin

  l_rec := get_adg_control;

  return yn_to_boolean(l_rec.enable_simulated_standby);

end;

/*==========================================================================*/

function is_session_simulated_standby return boolean
as
begin

  if ( G_SESS_SIMULATED_STDBY_ENABLED is not null )
  then
     return G_SESS_SIMULATED_STDBY_ENABLED;
  end if;

  set_session_simulated_stdby;

  return G_SESS_SIMULATED_STDBY_ENABLED;

end;

/*==========================================================================*/

function is_auto_simulation_enabled return boolean
as
l_rec fnd_adg_control%rowtype;
begin

  l_rec := get_adg_control;

  return yn_to_boolean(l_rec.enable_auto_simulated_standby);

end;

/*==========================================================================*/

function is_commit_wait_enabled return boolean
as
begin

  if ( G_SESS_COMMIT_WAIT_ENABLED is not null )
  then
     return G_SESS_COMMIT_WAIT_ENABLED;
  end if;

  set_commit_wait_enabled;

  return G_SESS_COMMIT_WAIT_ENABLED;
end;

/*==========================================================================*/

function is_standby_manager_defined(p_req_class_app_id number,
                                    p_req_class_id     number,
                                    p_must_be_running boolean) return boolean
as
cursor c1 is select a.QUEUE_APPLICATION_ID,a.CONCURRENT_QUEUE_ID,
                    a.TYPE_APPLICATION_ID,a.type_id,
                    a.include_flag,a.type_code,
                    b.Max_Processes,b.Running_Processes
               from FND_CONCURRENT_QUEUE_CONTENT a,fnd_concurrent_queues b
              where a.QUEUE_APPLICATION_ID = b.Application_Id
                and a.CONCURRENT_QUEUE_ID  = b.concurrent_queue_id
                and a.type_code = 'R'
                and a.include_flag = 'I'
                and a.TYPE_APPLICATION_ID = p_req_class_app_id
                and a.type_id             = p_req_class_id;

l_defined boolean ;
begin

  l_defined := false;

  for f_rec in c1 loop

    if ( not p_must_be_running )
    then
       l_defined := true;
       exit;
    end if;

    if ( f_rec.Max_Processes > 0 and f_rec.Running_Processes > 0 )
    then
       l_defined := true;
       exit;
    end if;

  end loop;

  return l_defined;

end;

/*==========================================================================*/

procedure get_rpc_debug(p_debug_rpc out nocopy number,
                        p_debug_slave_rpc out nocopy number)
as
l_rec fnd_adg_control%rowtype;
begin

  l_rec := get_adg_control;

  p_debug_rpc := l_rec.debug_rpc;
  p_debug_slave_rpc := l_rec.debug_slave_rpc;

end;

/*==========================================================================*/

function get_max_commit_wait_time return number
as
l_rec fnd_adg_control%rowtype;
begin

  l_rec := get_adg_control;

  return l_rec.max_commit_wait_time;

end;

/*==========================================================================*/

function get_max_standby_systems return number
as
begin

  return C_MAX_STANDBY_SYSTEMS;

end;

/*==========================================================================*/

procedure process_adg_violations(p_logoff boolean,
                                 p_application_id number default null,
                                 p_concurrent_program_id number default null)

as
l_cache_state boolean := null;
begin

  l_cache_state := enable_control_cache;

  do_process_adg_violations(p_logoff,p_application_id,p_concurrent_program_id);

  disable_control_cache(l_cache_state);

exception
  when others then
     disable_control_cache(l_cache_state);
     raise;
end;

/*==========================================================================*/

procedure enable_violation_trace
as
begin

  if ( is_new_style_magic_switch )
  then
     execute immediate
          'alter session set log_read_only_violations = true';
  else
     execute immediate
          'alter session set events ''' || C_MAGIC_SWITCH_EVENT_ON || '''';
  end if;

  G_MAGIC_SWITCH_ENABLED := true;

end;

/*==========================================================================*/

procedure disable_violation_trace
as
begin

  if ( is_new_style_magic_switch )
  then
     execute immediate
          'alter session set log_read_only_violations = false';
  else
     execute immediate
          'alter session set events ''' || C_MAGIC_SWITCH_EVENT_OFF || '''';
  end if;

  G_MAGIC_SWITCH_ENABLED := false;

end;

/*==========================================================================*/

procedure purge_commit_wait_data
as
begin

	-- We can purge at any time so long as this session has a valid
	-- audsid.

  if ( user <> 'SYS' and uid <> 0 )
  then

     delete from fnd_adg_commit_wait a
      where a.session_id < userenv('SESSIONID')
        and not exists
            ( select 1
                from gv$session b
               where b.audsid = a.session_id
            );

     commit;

  end if;

end;

/*==========================================================================*/

function enable_control_cache return boolean
as
l_previous_state boolean;
begin

  l_previous_state := G_ENABLE_CONTROL_CACHE;

  G_ENABLE_CONTROL_CACHE := true;
  G_CONTROL_CACHE_LOADED := false;

  return l_previous_state;

end;

/*==========================================================================*/

procedure disable_control_cache(p_previous_state boolean default false)
as
begin

  if ( p_previous_state is not null )
  then
     G_ENABLE_CONTROL_CACHE := p_previous_state;
  end if;

end;

/*==========================================================================*/

procedure refresh_control_cache
as
begin

  G_CONTROL_CACHE_LOADED := false;

end;

/*==========================================================================*/

procedure enable_database_triggers
as
begin

  set_database_triggers(true);

end;

/*==========================================================================*/

procedure disable_database_triggers
as
begin

  set_database_triggers(false);

end;

/*==========================================================================*/

begin
  null;
end fnd_adg_utility;

/
