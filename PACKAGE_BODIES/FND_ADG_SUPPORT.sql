--------------------------------------------------------
--  DDL for Package Body FND_ADG_SUPPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ADG_SUPPORT" as
/* $Header: AFDGSUPB.pls 120.7.12010000.4 2010/11/19 21:56:23 rsanders noship $ */

G_IS_STANDBY	boolean	:= null;
G_IS_PRIMARY    boolean := null;
G_IS_NO_DML	boolean := null;
G_IS_TRUE_STANDBY boolean := null;
G_HANDLE_REQUEST_ROW_ALL boolean := null;
G_HANDLE_REQUEST_ROW_PRIMARY boolean := null;

C_OPEN_READ_ONLY	constant 	varchar2(30) := 'READ ONLY';
C_OPEN_READ_WRITE	constant 	varchar2(30) := 'READ WRITE';
C_STANDBY_ROLE		constant        varchar2(30) := 'PHYSICAL STANDBY';
C_PRIMARY_ROLE		constant        varchar2(30) := 'PRIMARY';

C_REPORTWRITER		constant        varchar2(30) := 'P';
C_STATUS_NORMAL		constant	varchar2(10) := 'C';
C_PHASE_COMPLETE	constant        varchar2(10) := 'C';

	-- use real CR to get passed arcs!

LF			constant        varchar2(10) := '
';

/*==========================================================================*/

procedure set_is_no_dml
as
begin

	-- This routine currently does nothing but separates is_standby
	-- from dml.

  G_IS_NO_DML := true;

end;

/*==========================================================================*/

procedure set_handle_request_row_change
as
begin

  G_HANDLE_REQUEST_ROW_ALL := false;
  G_HANDLE_REQUEST_ROW_PRIMARY := false;

  if ( fnd_adg_utility.is_standby_access_supported )
  then
     if ( fnd_adg_utility.is_adg_support_enabled )
     then
        G_HANDLE_REQUEST_ROW_ALL := true;
     end if;

     if ( fnd_adg_utility.is_always_collect_primary_data )
     then
        G_HANDLE_REQUEST_ROW_PRIMARY := true;
     end if;
  end if;

end;

/*==========================================================================*/

	-- Currently unused and removed from spec.

function is_standby_no_dml return boolean
as
begin

  if ( not is_standby )
  then
     return false;
  end if;

  if ( G_IS_NO_DML is null )
  then
     set_is_no_dml;
  end if;

  return G_IS_NO_DML;

end;

/*==========================================================================*/

procedure set_is_standby
as
cursor c1 is select a.open_mode,a.database_role
               from v$database a;
begin

  G_IS_STANDBY := false;

	-- To keep in sync with RPC usage and to avoid redundant checks
	-- always return false unless compile directive is in force.

$if fnd_adg_compile_directive.enable_rpc
$then

  if ( fnd_adg_utility.is_standby_access_supported and
       fnd_adg_utility.is_adg_support_enabled )
  then

     for f_rec in c1 loop

       if ( instr(f_rec.open_mode,C_OPEN_READ_ONLY) > 0 and
            f_rec.database_role= C_STANDBY_ROLE )
       then
          G_IS_STANDBY := true;
       end if;
     end loop;

     if ( not G_IS_STANDBY )
     then
	-- Allow for simulated standby if running on primary.

        if ( fnd_adg_utility.is_session_simulated_standby and is_primary )
        then
           if ( not is_rpc_from_standby ) -- only true when slave rpc
           then
              G_IS_STANDBY := true; -- rpc client is now simulated as standby.
           end if;
        end if;
     end if;

  end if;

$else
     null;
$end

end;

/*==========================================================================*/

procedure set_is_true_standby
as
cursor c1 is select a.open_mode,a.database_role
               from v$database a;
begin

  G_IS_TRUE_STANDBY := false;

  if ( fnd_adg_utility.is_standby_access_supported )
  then
     for f_rec in c1 loop

       if ( instr(f_rec.open_mode,C_OPEN_READ_ONLY) > 0 and
            f_rec.database_role= C_STANDBY_ROLE )
       then
          G_IS_TRUE_STANDBY := true;
       end if;
     end loop;
  end if;

end;

/*==========================================================================*/

procedure set_is_primary
as
cursor c1 is select a.open_mode,a.database_role
               from v$database a;
begin

  G_IS_PRIMARY := false;

  for f_rec in c1 loop

    if ( f_rec.open_mode    = C_OPEN_READ_WRITE    and
         f_rec.database_role= C_PRIMARY_ROLE )
    then
       G_IS_PRIMARY := true;
    end if;
  end loop;

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

function boolean_to_ynu(p_bool boolean) return varchar2
as
begin

  if ( p_bool is null )
  then
     return 'U';
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

  if ( upper(p_yn) = 'Y' )
  then
     return true;
  else
     return false;
  end if;

end;

/*==========================================================================*/

function ynu_to_boolean(p_yn varchar2) return boolean
as
begin

  if ( upper(p_yn) = 'Y' )
  then
     return true;
  else
     if ( upper(p_yn) = 'N' )
     then
        return false;
     else
        return null;
     end if;
  end if;

end;

/*==========================================================================*/
/*==================== Start of concurrent program methods =================*/
/*==========================================================================*/

/*==========================================================================*/

function init_program_change_rec return fnd_adg_concurrent_program%rowtype
as
l_cp_rec fnd_adg_concurrent_program%rowtype;
begin

  l_cp_rec.Application_Id 		       := null;
  l_cp_rec.Concurrent_Program_Id               := null;
  l_cp_rec.Supported_Executable_Type           := null;
  l_cp_rec.Has_Run_On_Primary                  := null;
  l_cp_rec.Has_Run_In_Simulated_Standby        := null;
  l_cp_rec.Run_On_Standby                      := null;
  l_cp_rec.No_Standby_Failures                 := null;
  l_cp_rec.Max_Standby_Failures                := null;
  l_cp_rec.No_Simulated_Standby_Failures       := null;
  l_cp_rec.Max_Simulated_Standby_Failures      := null;
  l_cp_rec.always_redirect_if_valid	       := null;
  l_cp_rec.use_automatic_redirection	       := null;

  return l_cp_rec;

end;

/*==========================================================================*/

procedure update_conc_program_rec(p_cp_rec fnd_adg_concurrent_program%rowtype,
                                  p_cp_chng_rec
                                           fnd_adg_concurrent_program%rowtype,
                                  p_util_caller boolean default false)
as
PRAGMA AUTONOMOUS_TRANSACTION;
l_curr_cp_rec fnd_adg_concurrent_program%rowtype;
begin

  select a.*
    into l_curr_cp_rec
    from fnd_adg_concurrent_program a
   where a.Application_Id = p_cp_rec.Application_Id
     and a.Concurrent_Program_Id = p_cp_rec.Concurrent_Program_Id
     for update of a.Application_Id;

  if ( p_cp_chng_rec.Supported_Executable_Type is not null )
  then
     l_curr_cp_rec.Supported_Executable_Type :=
                                  p_cp_chng_rec.Supported_Executable_Type;
  end if;

  if ( p_cp_chng_rec.Has_Run_On_Primary is not null )
  then
     l_curr_cp_rec.Has_Run_On_Primary    := p_cp_chng_rec.Has_Run_On_Primary;
  end if;

  if ( p_cp_chng_rec.Has_Run_In_Simulated_Standby is not null )
  then
     l_curr_cp_rec.Has_Run_In_Simulated_Standby :=
                                  p_cp_chng_rec.Has_Run_In_Simulated_Standby;
  end if;

  if ( p_cp_chng_rec.Run_On_Standby is not null )
  then
     if ( l_curr_cp_rec.Run_On_Standby <> p_cp_chng_rec.Run_On_Standby )
     then
        if ( ynu_to_boolean(l_curr_cp_rec.Run_On_Standby) is null or
             ynu_to_boolean(l_curr_cp_rec.Run_On_Standby) or p_util_caller )
        then
           l_curr_cp_rec.Run_On_Standby        := p_cp_chng_rec.Run_On_Standby;
        end if;
     end if;
  end if;

  if ( p_cp_chng_rec.No_Standby_Failures is not null )
  then
     l_curr_cp_rec.No_Standby_Failures   := p_cp_chng_rec.No_Standby_Failures;
  end if;

  if ( p_cp_chng_rec.Max_Standby_Failures is not null )
  then
     l_curr_cp_rec.Max_Standby_Failures  := p_cp_chng_rec.Max_Standby_Failures;
  end if;

  if ( p_cp_chng_rec.No_Simulated_Standby_Failures is not null )
  then
     l_curr_cp_rec.No_Simulated_Standby_Failures :=
                                  p_cp_chng_rec.No_Simulated_Standby_Failures;
  end if;

  if ( p_cp_chng_rec.Max_Simulated_Standby_Failures is not null )
  then
     l_curr_cp_rec.Max_Simulated_Standby_Failures :=
                                  p_cp_chng_rec.Max_Simulated_Standby_Failures;
  end if;

  if ( p_cp_chng_rec.always_redirect_if_valid is not null )
  then
     l_curr_cp_rec.always_redirect_if_valid :=
                       p_cp_chng_rec.always_redirect_if_valid;
  end if;

  if ( p_cp_chng_rec.use_automatic_redirection is not null )
  then
     l_curr_cp_rec.use_automatic_redirection :=
                       p_cp_chng_rec.use_automatic_redirection;
  end if;

  update fnd_adg_concurrent_program a
     set row = l_curr_cp_rec
   where a.Application_Id = p_cp_rec.Application_Id
     and a.Concurrent_Program_Id = p_cp_rec.Concurrent_Program_Id;

  commit;

end;

/*==========================================================================*/

function is_standalone_executable(p_cp_rec fnd_adg_concurrent_program%rowtype)
                                    return boolean
as
begin

	-- We currently only support standalone executables. If this
	-- ever changes this function needs to be changed. Why? Because with
	-- standalone we update simulation stats on logoff whereas
	-- for embedded stats are done under the update trigger.
	-- This only applies to simulation stats.

  return true;

end;

/*==========================================================================*/

function is_conc_program_supported(p_program_application_id number,
                                   p_concurrent_program_id number)
                                                           return boolean
as
l_Execution_Method_Code varchar2(10);
begin

  begin

    select a.Execution_Method_Code
      into l_Execution_Method_Code
      from fnd_concurrent_programs a
     where a.APPLICATION_ID = p_program_application_id
       and a.CONCURRENT_PROGRAM_ID = p_concurrent_program_id;

    if ( l_Execution_Method_Code = C_REPORTWRITER )
    then
       return true;
    else
       return false;
    end if;

  exception
      when no_data_found then
            return null;
  end;

end;

/*==========================================================================*/

function create_conc_program_rec(p_program_application_id number,
                                 p_concurrent_program_id number)
                               return fnd_adg_concurrent_program%rowtype
as
PRAGMA AUTONOMOUS_TRANSACTION;
l_new_cp_rec fnd_adg_concurrent_program%rowtype;
l_is_supported_exe_type boolean;
begin

  l_is_supported_exe_type :=
        is_conc_program_supported(p_program_application_id,
                                  p_concurrent_program_id);

  if ( l_is_supported_exe_type is null ) -- conc. program doesn't exist!
  then
     l_new_cp_rec.Application_Id                 := null;
     l_new_cp_rec.Concurrent_Program_Id          := null;
     commit;
     return l_new_cp_rec;
  end if;

  l_new_cp_rec.Application_Id                 := p_program_application_id;
  l_new_cp_rec.Concurrent_Program_Id          := p_concurrent_program_id;
  l_new_cp_rec.Supported_Executable_Type      :=
                                         boolean_to_yn(l_is_supported_exe_type);
  l_new_cp_rec.Has_Run_On_Primary             := boolean_to_yn(false);
  l_new_cp_rec.Has_Run_In_Simulated_Standby   := boolean_to_yn(false);
  l_new_cp_rec.Run_On_Standby                 := boolean_to_ynu(null);
  l_new_cp_rec.No_Standby_Failures            := 0;
  l_new_cp_rec.Max_Standby_Failures           := 0;
  l_new_cp_rec.No_Simulated_Standby_Failures  := 0;
  l_new_cp_rec.Max_Simulated_Standby_Failures := 0;
  l_new_cp_rec.always_redirect_if_valid       := boolean_to_yn(true);
  l_new_cp_rec.use_automatic_redirection      := boolean_to_yn(false);

  begin

    insert into fnd_adg_concurrent_program values l_new_cp_rec ;

    commit;

  exception

    when DUP_VAL_ON_INDEX then   -- somebody got there first

       select a.*
         into l_new_cp_rec
         from fnd_adg_concurrent_program a
        where a.Application_Id = p_program_application_id
          and a.Concurrent_Program_Id = p_concurrent_program_id;

  end;

  return l_new_cp_rec;

end;

/*==========================================================================*/

function get_conc_program_rec(p_program_application_id number,
                              p_concurrent_program_id number)
                               return fnd_adg_concurrent_program%rowtype
as
l_cp_rec fnd_adg_concurrent_program%rowtype;
begin

  begin

    select a.*
      into l_cp_rec
      from fnd_adg_concurrent_program a
     where a.Application_Id = p_program_application_id
       and a.Concurrent_Program_Id = p_concurrent_program_id;

  exception

    when no_data_found then

         l_cp_rec := create_conc_program_rec(p_program_application_id,
                                             p_concurrent_program_id);
  end;

  return l_cp_rec;

end;

/*==========================================================================*/

function is_conc_program_changes(p_cp_chng_rec
                                    fnd_adg_concurrent_program%rowtype)
                                               return boolean
as
begin

  if (
       p_cp_chng_rec.Application_Id                      is not null or
       p_cp_chng_rec.Concurrent_Program_Id               is not null or
       p_cp_chng_rec.Supported_Executable_Type           is not null or
       p_cp_chng_rec.Has_Run_On_Primary                  is not null or
       p_cp_chng_rec.Has_Run_In_Simulated_Standby        is not null or
       p_cp_chng_rec.Run_On_Standby                      is not null or
       p_cp_chng_rec.No_Standby_Failures                 is not null or
       p_cp_chng_rec.Max_Standby_Failures                is not null or
       p_cp_chng_rec.No_Simulated_Standby_Failures       is not null or
       p_cp_chng_rec.Max_Simulated_Standby_Failures      is not null or
       p_cp_chng_rec.always_redirect_if_valid		 is not null or
       p_cp_chng_rec.use_automatic_redirection           is not null
     )
  then
     return true;
  else
     return false;
  end if;

end;

/*==========================================================================*/

procedure do_handle_request_row_update(p_cp_rec
                                          fnd_adg_concurrent_program%rowtype,
                                       p_cp_chng_rec in out nocopy
                                          fnd_adg_concurrent_program%rowtype,
                                       p_connstr1 in out nocopy varchar2,
                                       p_phase_code varchar2,
                                       p_status_code varchar2
                                      )
as
l_request_success boolean;
l_standby_exists boolean;
l_standby_valid boolean;
l_simulation_connstr varchar2(255);
l_simulation_valid boolean;
l_mgr_stndby_req_class_app_id number;
l_mgr_stndby_req_class_id number;
begin

  if ( p_status_code = C_STATUS_NORMAL and
       p_phase_code  = C_PHASE_COMPLETE )
  then
     l_request_success := true;
  else
     l_request_success := false;
  end if;

       -- Handle PRIMARY only functions first.

  if ( l_request_success and is_primary and
                not yn_to_boolean(p_cp_rec.Has_Run_On_Primary))
  then
     p_cp_chng_rec.Has_Run_On_Primary := boolean_to_yn(true);
  end if;

  if ( not G_HANDLE_REQUEST_ROW_ALL )
  then
     return;
  end if;

        -- Nothing to do if connstr is null;

  if ( p_connstr1 is null )
  then
     return;
  end if;

  fnd_adg_utility.find_registered_standby
             (p_connstr1,l_standby_exists,l_standby_valid,
              l_mgr_stndby_req_class_app_id,l_mgr_stndby_req_class_id);

  fnd_adg_utility.get_connection_data
                  (fnd_adg_utility.C_CONNECT_TO_SIMULATED_STANDBY,
                   l_simulation_valid, l_simulation_connstr);

  if ( not l_standby_exists )
  then
     if ( l_simulation_valid and l_simulation_connstr = p_connstr1 )
     then
        null;
     else
        return;
     end if;
  end if;

  if ( l_request_success )
  then
     if ( l_simulation_valid and p_connstr1 = l_simulation_connstr )
     then
        if ( not yn_to_boolean(p_cp_rec.Has_Run_In_Simulated_Standby) )
        then
           p_cp_chng_rec.Has_Run_In_Simulated_Standby := boolean_to_yn(true);
        end if;

        if ( p_cp_rec.No_Standby_Failures <= p_cp_rec.Max_Standby_Failures and
             p_cp_rec.No_Simulated_Standby_Failures <=
                            p_cp_rec.Max_Simulated_Standby_Failures )
        then

           if ( fnd_adg_utility.is_simulated_standby_enabled )
           then
              p_cp_chng_rec.Run_On_Standby := boolean_to_ynu(true);
           end if;
        end if;
     end if;
  else

     if ( l_standby_valid )
     then
        if ( p_cp_rec.No_Standby_Failures > p_cp_rec.Max_Standby_Failures )
        then
           if ( ynu_to_boolean(p_cp_rec.Run_On_Standby) is null or
                ynu_to_boolean(p_cp_rec.Run_On_Standby) )
           then
              p_cp_chng_rec.Run_On_Standby := boolean_to_ynu(false);
           end if;
        end if;
     else
         if ( p_cp_rec.No_Simulated_Standby_Failures >
                            p_cp_rec.Max_Simulated_Standby_Failures )
         then
            if ( ynu_to_boolean(p_cp_rec.Run_On_Standby) is null or
                 ynu_to_boolean(p_cp_rec.Run_On_Standby) )
            then
               p_cp_chng_rec.Run_On_Standby := boolean_to_ynu(false);
            end if;
         end if;
     end if;

  end if;

end;

/*==========================================================================*/

procedure do_handle_request_row_insert(p_cp_rec
                                          fnd_adg_concurrent_program%rowtype,
                                       p_cp_chng_rec in out nocopy
                                          fnd_adg_concurrent_program%rowtype,
                                       p_connstr1 in out nocopy varchar2,
                                       p_nodename1 in out nocopy varchar2,
                                       p_request_class_application_id
                                                     in out nocopy number,
                                       p_concurrent_request_class_id
                                                     in out nocopy number
                                      )
as
l_mgr_stndby_req_class_app_id number;
l_mgr_stndby_req_class_id number;
l_auto_stndby_req_class_app_id number;
l_auto_stndby_req_class_id number;
l_standby_exists boolean;
l_standby_valid boolean;
l_simulation_connstr varchar2(255);
l_simulation_valid boolean;
l_manager_must_be_running boolean;
l_auto_valid boolean;
l_auto_connstr1 varchar(255);
l_known_adg_connection boolean;
l_is_standby_mgr_defined boolean;

begin

	-- Must be ALL processing for INSERT.

  if ( not G_HANDLE_REQUEST_ROW_ALL )
  then
     return;
  end if;

  l_auto_valid := false;

	-- Special handling when automatic redirection is enabled.


  if ( fnd_adg_utility.is_automatic_redirection and
       yn_to_boolean(p_cp_rec.use_automatic_redirection ) )
  then
     for i in 1..fnd_adg_utility.get_max_standby_systems loop

       fnd_adg_utility.get_connection_data
                       (fnd_adg_utility.C_CONNECT_PRIMARY_TO_STANDBY,
                        l_auto_valid,l_auto_connstr1,i);

        if ( l_auto_valid )
        then
           fnd_adg_utility.get_standby_cm_class(i,l_auto_stndby_req_class_app_id,
                                               l_auto_stndby_req_class_id);
           exit;
        end if;
     end loop;
  end if;

	-- Nothing to do if connstr is null and no automatic redirection;

  if ( p_connstr1 is null and not l_auto_valid )
  then
     return;
  end if;

	-- Connstr could be standby or simulation

  fnd_adg_utility.find_registered_standby
             (p_connstr1,l_standby_exists,l_standby_valid,
              l_mgr_stndby_req_class_app_id,l_mgr_stndby_req_class_id);

  fnd_adg_utility.get_connection_data
                  (fnd_adg_utility.C_CONNECT_TO_SIMULATED_STANDBY,
                   l_simulation_valid,l_simulation_connstr);

	-- If supplied connstr exists then we use it and ignore
	-- automatic redirection even if it turns out to be invalid. After
	-- all user supplied it.

  if ( l_standby_exists )
  then
     l_auto_valid := false;
  end if;

	-- Now determine whether supplied connect string is known by
	-- ADG. At the same time set the on-validation return string - i.e.
	-- if we're using automatic redirection but the report is not a
	-- candidate we need to return string as is - it could be an instance
	-- connect string.

  l_known_adg_connection := false;

  if ( p_connstr1 is not null )
  then
     if ( l_standby_exists )
     then
	-- Doesn't matter whether valid or not we always return null
	-- except for the final switch.

        l_known_adg_connection := true;
     else
        if ( l_simulation_connstr is not null and
             l_simulation_connstr = p_connstr1 )
        then
           l_known_adg_connection := true;
        end if;
     end if;
  end if;

  	-- If connstr not standby or simulation and not
	-- auto redirection enabled then nothing to do with us.

  if ( not l_auto_valid )
  then
     if ( l_known_adg_connection )
     then
        if ( l_standby_exists )
        then
           if ( not l_standby_valid )
           then
              p_connstr1 := null;
              return;
           end if;
        else
           if ( not l_simulation_valid )
           then
              p_connstr1 := null;
              return;
           end if;
        end if;
     else
        return;
     end if;
  end if;

	-- Only allow supported program types.

  if ( not yn_to_boolean(p_cp_rec.Supported_Executable_Type) )
  then
     if ( l_known_adg_connection )
     then
        p_connstr1 := null;
     end if;

     return;
  end if;

	-- Need to first run on primary before being a standby candidate.

  if ( not yn_to_boolean(p_cp_rec.Has_Run_On_Primary) )
  then
     if ( l_known_adg_connection )
     then
        p_connstr1 := null;
     end if;

     return;
  end if;

	-- If connect string is known and not standby then must be simulated
	-- standby.

  if ( l_known_adg_connection and not l_standby_exists )
  then
     if ( not l_auto_valid ) -- use simulation only if auto-redirect not in effect
     then
        if ( l_simulation_valid )
        then
           p_connstr1 := l_simulation_connstr;
        else
           p_connstr1 := null;
        end if;

        return;
     end if;
  end if;

	-- Need to have run on simulated standby before real standby.

  if ( not yn_to_boolean(p_cp_rec.Has_Run_In_Simulated_Standby) )
  then
     	-- If auto simulation enabled and valid, then use simulation
        -- connect string.

	-- This will redirect for null and instance strings. It's not clear
	-- we really want this happen but we can just disable auto-simulation.

     if ( fnd_adg_utility.is_simulated_standby_enabled and
          fnd_adg_utility.is_auto_simulation_enabled and l_simulation_valid )
     then
        p_connstr1 := l_simulation_connstr;
        return;
     end if;

     if ( l_known_adg_connection )
     then
        p_connstr1 := null;
     end if;

     return;
  end if;

	-- If Run_On_Standby not set then return.

  if ( ynu_to_boolean(p_cp_rec.Run_On_Standby) is null or
       not ynu_to_boolean(p_cp_rec.Run_On_Standby) )
  then
     if ( l_known_adg_connection )
     then
        p_connstr1 := null;
     end if;

     return;
  end if;

	-- Ready to go - make sure manager is running for class id.

	-- Does manager have to be running - can be put in queue for later.

  if ( fnd_adg_utility.is_enable_redirect_if_valid and
       yn_to_boolean(p_cp_rec.always_redirect_if_valid) )
  then
     l_manager_must_be_running := false;
  else
     l_manager_must_be_running := true;
  end if;

  if ( not l_auto_valid )
  then
     l_is_standby_mgr_defined :=
                  fnd_adg_utility.is_standby_manager_defined
                                      (l_mgr_stndby_req_class_app_id,
                                       l_mgr_stndby_req_class_id,
                                       l_manager_must_be_running);
  else
     l_is_standby_mgr_defined :=
                  fnd_adg_utility.is_standby_manager_defined
                                      (l_auto_stndby_req_class_app_id,
                                       l_auto_stndby_req_class_id,
                                       l_manager_must_be_running);
  end if;

  if ( l_is_standby_mgr_defined )
  then

	-- Redirect to ADG manager.

	-- Auto-redirection will not be valid if connstr was standby

     if ( not l_auto_valid )
     then

        p_request_class_application_id := l_mgr_stndby_req_class_app_id;
        p_concurrent_request_class_id  := l_mgr_stndby_req_class_id;

     else

        p_connstr1		       := l_auto_connstr1;
        p_request_class_application_id := l_auto_stndby_req_class_app_id;
        p_concurrent_request_class_id  := l_auto_stndby_req_class_id;

     end if;

     if ( p_nodename1 is not null )
     then
        p_nodename1 := null;  -- use class not node for standby control.
     end if;

     return;

  else
     if ( l_known_adg_connection )
     then
        p_connstr1 := null;
     end if;

     return;
  end if;

end;

/*==========================================================================*/

	-- Private method - no access code check

procedure do_handle_concurrent_program
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
l_cp_chng_rec fnd_adg_concurrent_program%rowtype;
l_cp_rec fnd_adg_concurrent_program%rowtype;
begin

  l_cp_rec := get_conc_program_rec(p_application_id,
                                   p_concurrent_program_id);

	-- Does concurrent program exist

  if ( l_cp_rec.Application_Id is null and
       l_cp_rec.Concurrent_Program_Id is null )
  then
     fnd_adg_exception.raise_error(
                     fnd_adg_exception.C_SUPERR_INVALID_CONC_PROGRAM);
  end if;

  l_cp_chng_rec := init_program_change_rec;

  l_cp_chng_rec.Has_Run_On_Primary       := boolean_to_yn(p_has_run_on_primary);
  l_cp_chng_rec.Has_Run_In_Simulated_Standby  :=
                                boolean_to_yn(p_has_run_on_simulated_standby);

  if ( p_run_on_standby is not null )
  then
     l_cp_chng_rec.Run_On_Standby        := boolean_to_ynu(p_run_on_standby);
  end if;

  l_cp_chng_rec.No_Standby_Failures           := p_no_standby_failures;
  l_cp_chng_rec.Max_Standby_Failures          := p_max_standby_failures;
  l_cp_chng_rec.No_Simulated_Standby_Failures := p_no_simulated_stdby_failures;
  l_cp_chng_rec.Max_Simulated_Standby_Failures:= p_max_simulated_stdby_failures;

  l_cp_chng_rec.always_redirect_if_valid
				:= boolean_to_yn(p_always_redirect_if_valid);

  l_cp_chng_rec.use_automatic_redirection
                                := boolean_to_yn(p_use_automatic_redirection);

  if ( is_conc_program_changes(l_cp_chng_rec) )
  then
     update_conc_program_rec(l_cp_rec,l_cp_chng_rec,true);
  end if;

end;

/*==========================================================================*/
/*==================== Start of public methods =============================*/
/*==========================================================================*/

/*==========================================================================*/

function is_standby return boolean
as
l_err number;
l_msg varchar2(255);

begin

  if ( G_IS_STANDBY is null )
  then
     set_is_standby;

	-- check that we're using the right primary.

     if ( G_IS_STANDBY )
     then

	-- validate will call back into is_standby. That's ok as G_IS_STANDBY
	-- will be not null and this code path will not be reached.
	-- Otherwise we'd recurse into oblivion...

        fnd_adg_manage.validate_standby_to_primary(l_err,l_msg,true);

        if ( l_err <> 0 )
        then
           G_IS_STANDBY := false;

           fnd_adg_exception.raise_error(
                           fnd_adg_exception.C_SUPERR_VALIDATE_PRIMARY,l_msg);
        end if;

        fnd_adg_manage.handle_rpc_debug(true);  -- enable debug trace.

     end if;
  end if;

  return G_IS_STANDBY;

end;

/*==========================================================================*/

function is_true_standby return boolean
as
begin

  if ( G_IS_TRUE_STANDBY is null )
  then
     set_is_true_standby;
  end if;

  return G_IS_TRUE_STANDBY;

end;

/*==========================================================================*/

function is_rpc_from_standby return boolean
as
begin

  return fnd_adg_manage.is_session_slave_to_standby;

end;

/*==========================================================================*/

function is_primary return boolean
as
begin

  if ( G_IS_PRIMARY is null )
  then
     set_is_primary;
  end if;

  return G_IS_PRIMARY;

end;

/*==========================================================================*/

procedure log_unhandled_exception(p_location varchar2,p_sqlerr varchar2)
as
begin

   dbms_system.ksdwrt(1,'ADGEBS: Unhandled Exception : ' ||p_location||
                          ' SQLERRM='||p_sqlerr);

   dbms_system.ksdwrt(1,'ADGEBS: Backtrace : ' ||p_location||LF||
                      dbms_utility.format_error_backtrace);

end;

/*==========================================================================*/

function is_connstr_registered(p_connstr varchar2,
                               p_check_valid boolean default false,
                               p_check_available boolean default false)
                     return boolean
as
begin

  return fnd_adg_utility.is_connection_registered(p_connstr,p_check_valid,
                                                  p_check_available);

end;

/*==========================================================================*/

function is_connstr_registered(p_connstr varchar2,
                               p_check_valid number,
                               p_check_available number)
                     return number
as
l_bool_check_valid boolean := false;
l_bool_check_available boolean := false;
begin

  if ( p_check_valid = 1 )
  then
     l_bool_check_valid := true;
  end if;

  if ( p_check_available = 1 )
  then
     l_bool_check_available := true;
  end if;

  if ( fnd_adg_utility.is_connection_registered(p_connstr,
                                                l_bool_check_valid,
                                                l_bool_check_available) )
  then
     return 1;
  else
     return 0;
  end if;

end;

/*==========================================================================*/

procedure handle_request_row_change(p_is_inserting boolean,
                                    p_program_application_id number,
                                    p_concurrent_program_id number,
                                    p_connstr1 in out nocopy varchar2,
                                    p_nodename1 in out nocopy varchar2,
                                    p_request_class_application_id
                                                  in out nocopy number,
                                    p_concurrent_request_class_id
                                                  in out nocopy number,
                                    p_phase_code varchar2,
                                    p_status_code varchar2
                                   )
as
l_cp_chng_rec fnd_adg_concurrent_program%rowtype;
l_cp_rec fnd_adg_concurrent_program%rowtype;
l_cache_state boolean := null;
begin

	-- Use the control cache to avoid repeated reads.

  l_cache_state := fnd_adg_utility.enable_control_cache;

	-- Always check state

  set_handle_request_row_change;

  if ( G_HANDLE_REQUEST_ROW_ALL or G_HANDLE_REQUEST_ROW_PRIMARY )
  then
     null;
  else
     fnd_adg_utility.disable_control_cache(l_cache_state);
     return;
  end if;

	-- If someone tries to insert nulls we just ignore the row as
	-- cols are defined as not null!

  if ( p_program_application_id is null or
       p_concurrent_program_id is null )
  then
     fnd_adg_utility.disable_control_cache(l_cache_state);
     return;
  end if;

  l_cp_rec := get_conc_program_rec(p_program_application_id,
                                   p_concurrent_program_id);

  if ( l_cp_rec.Application_Id is null and
       l_cp_rec.Concurrent_Program_Id is null ) -- concurrent program doesn't
                                                -- exist - can't happen!
  then
     fnd_adg_utility.disable_control_cache(l_cache_state);
     return;
  end if;

	-- Now the real processing starts.

  l_cp_chng_rec := init_program_change_rec;

  if ( p_is_inserting )
  then
     do_handle_request_row_insert(l_cp_rec,l_cp_chng_rec,
                                  p_connstr1, p_nodename1,
                                  p_request_class_application_id,
                                  p_concurrent_request_class_id);
  else

        -- If embedded then we need to calculate simulation errors now.
        -- Currently we only support standalone so this code path is
        -- never executed.

     if ( not is_standalone_executable(l_cp_rec) )
     then
        fnd_adg_utility.process_adg_violations(false,
                                               p_program_application_id,
                                               p_concurrent_program_id);

        l_cp_rec := get_conc_program_rec(p_program_application_id,
                                         p_concurrent_program_id);
     end if;

     do_handle_request_row_update(l_cp_rec,l_cp_chng_rec,
                                  p_connstr1,p_phase_code,p_status_code);
  end if;

  if ( is_conc_program_changes(l_cp_chng_rec) )
  then
     update_conc_program_rec(l_cp_rec,l_cp_chng_rec);
  end if;

  fnd_adg_utility.disable_control_cache(l_cache_state);

exception
  when others then
       fnd_adg_utility.disable_control_cache(l_cache_state);
       raise;

end;

/*==========================================================================*/

procedure handle_concurrent_program
                       (p_code                        number,
                        p_application_id              number,
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
l_access_code number;
l_cp_chng_rec fnd_adg_concurrent_program%rowtype;
l_cp_rec fnd_adg_concurrent_program%rowtype;
begin

  l_access_code := fnd_adg_utility.get_program_access_code;

  if ( p_code is null or l_access_code is null or p_code <> l_access_code )
  then
     fnd_adg_exception.raise_error(
                     fnd_adg_exception.C_SUPERR_PROGRAM_ACCESS_CODE);
  end if;

  do_handle_concurrent_program(p_application_id              ,
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

procedure handle_standby_error ( p_program_application_id number,
                                 p_concurrent_program_id number,
                                 p_simulation boolean,
                                 p_logoff boolean,
                                 p_error_count number)
as
l_cp_rec fnd_adg_concurrent_program%rowtype;
l_run_on_standby boolean;
l_No_Standby_Failures number;
l_No_Simulated_Failures number;
begin

  if ( p_program_application_id is null or p_concurrent_program_id is null or
       p_simulation is null or p_error_count is null or
       p_error_count <= 0 or p_logoff is null )
  then
     return;
  end if;

	-- All the error checking has already taken place so
	-- just update the run flag.

  l_run_on_standby := null;
  l_No_Standby_Failures := null;
  l_No_Simulated_Failures := null;

  l_cp_rec := get_conc_program_rec(p_program_application_id,
                                   p_concurrent_program_id);

  if ( not p_simulation )
  then
     l_No_Standby_Failures := l_cp_rec.No_Standby_Failures + p_error_count;

     if ( l_No_Standby_Failures >= l_cp_rec.Max_Standby_Failures )
     then
        l_run_on_standby := false;
     end if;
  else
     if ( ( is_standalone_executable(l_cp_rec) and p_logoff ) or
          ( not is_standalone_executable(l_cp_rec) and not p_logoff ) )
     then
        l_No_Simulated_Failures :=
                  l_cp_rec.No_Simulated_Standby_Failures + p_error_count;
     end if;
  end if;

  do_handle_concurrent_program
                  (
                    p_application_id       => p_program_application_id,
                    p_concurrent_program_id=> p_concurrent_program_id,
                    p_run_on_standby       => l_run_on_standby,
                    p_No_Standby_Failures  => l_No_Standby_Failures,
                    p_no_simulated_stdby_failures =>
                                       l_No_Simulated_Failures
                  );

exception
  when others then
       null;  -- called from error handler so nothing we can do!

end;

/*==========================================================================*/

	-- This entry point is only valid outside of trigger code
	-- due to mutating errors.

procedure handle_standby_error ( p_request_id number,
                                 p_simulation boolean,
                                 p_logoff boolean,
                                 p_error_count number)
as
cursor c1 is select R.Program_APPLICATION_ID,R.CONCURRENT_PROGRAM_ID
               from FND_CONCURRENT_REQUESTS r
              where R.request_id = p_request_id;
begin

  if ( p_request_id is null )
  then
     return;
  end if;

  for f_rec in c1 loop

      handle_standby_error(f_rec.Program_APPLICATION_ID,
                           f_rec.CONCURRENT_PROGRAM_ID,
                           p_simulation,
                           p_logoff,
                           p_error_count);

      exit;

  end loop;

exception
  when others then
       null;  -- called from error handler so nothing we can do!

end;

/*==========================================================================*/

begin
  null;
end fnd_adg_support;

/
