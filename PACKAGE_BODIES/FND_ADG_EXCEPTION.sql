--------------------------------------------------------
--  DDL for Package Body FND_ADG_EXCEPTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ADG_EXCEPTION" as
/* $Header: AFDGEXEB.pls 120.0.12010000.2 2010/09/17 16:26:05 rsanders noship $ */

	/* Error Handling */

type error_table	 is table of varchar2(255) index by pls_integer;

G_ERR	error_table;

C_ERR_NULL		constant       			number := 0;
C_ERR_UNKNOWN		constant       			number := -1;
C_ERR_INVALID_MSG_NO	constant       			number := -2;

/*==========================================================================*/

procedure init_error_table
as
begin

	/* Internal Errors */

  G_ERR(C_ERR_NULL)    := 'Error number is null!';
  G_ERR(C_ERR_UNKNOWN) := 'Unknown error message number';
  G_ERR(C_ERR_INVALID_MSG_NO)
		       := 'Error message number must > 0';

	/* Utility Errors */

  G_ERR(C_UTLERR_INVALID_DB_RELEASE) :=
                      'DB Release does not support ADG';
  G_ERR(C_UTLERR_REGISTER_LINK_IS_NULL) :=
                      'Register connection - owner/name cannot be null';
  G_ERR(C_UTLERR_OWNER_NOT_PUBLIC) :=
                      'Register connection - owner must be public';
  G_ERR(C_UTLERR_REG_LINK_NOT_FOUND) :=
                      'Register connection - link not found';
  G_ERR(C_UTLERR_STANDBY_OUT_OF_RANGE) :=
                      'Standby number out of range - max 5 systems supported';
  G_ERR(C_UTLERR_LINK_HOST_MISMATCH) :=
                      'Database link exists but connect string does not match';
  G_ERR(C_UTLERR_STDBY_P_LINKS_MATCH) :=
                      'Standby->Primary and Primary->standby links are the same';
  G_ERR(C_UTLERR_RPC_SYSTEM_ON) :=
                      'RPC system needs to be disabled for this operation';
  G_ERR(C_UTLERR_RPC_SYSTEM_OFF) :=
                      'RPC system needs to be enabled for this operation';
  G_ERR(C_UTLERR_RPC_ADG_ON) :=
                      'ADG support needs to be disabled for this operation';
  G_ERR(C_UTLERR_RPC_ADG_OFF) :=
                      'ADG support needs to be enabled for this operation';
  G_ERR(C_UTLERR_INCONSISTENT_ADGSTATE) :=
                      'ADG state inconsistent with rpc system';
  G_ERR(C_UTLERR_DIRECTIVE_MISMATCH) :=
                      'RPC state mismatch with compile directive';
  G_ERR(C_UTLERR_INVALID_CONNECT_TYPE) :=
                      'Invalid ADG connection type';
  G_ERR(C_UTLERR_STANDBY_NULL) :=
                      'Standby number cannot be null for selected connection type';
  G_ERR(C_UTLERR_RPC_SYSTEM_NOT_PREPED) :=
                      'RPC must be prepared before requested action can be processed';
  G_ERR(C_UTLERR_LINKCHK_NULL) :=
                      'Validate connection - link is null';
  G_ERR(C_UTLERR_LINKCHK_TNS) :=
                      'Validate connection - cannot connect via link';
  G_ERR(C_UTLERR_LINKCHK_LOOPBACK) :=
                      'Validate connection - link cannot be a loopback';
  G_ERR(C_UTLERR_LINKCHK_BAD_DBID) :=
                      'Validate connection - remote DBID/name mismatch';
  G_ERR(C_UTLERR_LINKCHK_BAD_DB_ROLE) :=
                   'Validate connection - remote database must be rw primary';
  G_ERR(C_UTLERR_LINKCHK_RPC_IS_CLONE) :=
                   'Validate connection - DBIDs match but remote database is not the same as this database';
  G_ERR(C_UTLERR_LINKCHK_BAD_STANDBY) :=
                   'Validate connection - remote database must be ro standby';
  G_ERR(C_UTLERR_RPC_SYSTEM_LINK_BAD) :=
                   'RPC primary link must be valid before RPC can be enabled';
  G_ERR(C_UTLERR_LINKCHK_BAD_SERVICE) :=
                   'RPC simulated standby service name mismatch';
  G_ERR(C_UTLERR_BAD_DIR_OBJECT) :=
                   'Simulated standby directory object does not exist';
  G_ERR(C_UTLERR_REG_CM_NOT_DEFINED) :=
                   'Standby manager not defined for request type';
  G_ERR(C_UTLERR_CDATA_EXISTS) :=
                   ' Duplicate connection data entry';
  G_ERR(C_UTLERR_CONNSTR_TOO_LONG) :=
                   'Register connection - connect string too long. Max ';

	/* Manager Errors */

  G_ERR(C_MGRERR_NOT_STANDBY) :=
                      'Validate must be run from standby';
  G_ERR(C_MGRERR_REMOTE_NOT_PRIMARY) :=
                      'Validate: remote is not primary';
  G_ERR(C_MGRERR_REMOTE_DOESNT_MATCH) :=
                      'Validate: remote db doesn''t match standby';
  G_ERR(C_MGRERR_REMOTE_RESOLVE) :=
                      'Validate: cannot execute remote operation';
  G_ERR(C_MGRERR_UNKNOWN_REMOTE_ERROR) :=
                      'Validate: unknown remote error';
  G_ERR(C_MGRERR_FAILED_PREV_SES_CHK) :=
                      'Validate: Previous session check failed';
  G_ERR(C_MGRERR_REMOTE_IS_LOOPBACK) :=
                      'Validate: remote session is same as standby';
  G_ERR(C_MGRERR_RPC_EXEC_ERROR) :=
                      'RPC-EXEC';

	/* Object Errors */

  G_ERR(C_OBJERR_GEN_MISSING_METHOD) :=
                         'Generate : Missing method';
  G_ERR(C_OBJERR_GEN_OVERLOADED) :=
                         'Generate : Method overloaded';
  G_ERR(C_OBJERR_GEN_INCOMPAT) :=
                         'Generate : One or more method incompatibilities';
  G_ERR(C_OBJERR_UNSUPPORTD_DATA_TY) :=
                         'Generate : Only date,varchar2,number and boolean supported';
  G_ERR(C_OBJERR_UNSUPPORTD_IO_MODE) :=
                         'Generate : Invalid in/out mode';
  G_ERR(C_OBJERR_COMPILE_ERROR) :=
                         'Compile Error: ';
  G_ERR(C_OBJERR_COMPILE_NOT_DEFINED) :=
                         'Compile: Package not defined - ';
  G_ERR(C_OBJERR_COMPILE_NO_CODE) :=
                         'Compile: Code is empty - ';
  G_ERR(C_OBJERR_USAGE_NOT_VALID) :=
       'Object Validate: Package/body not valid - recompile required';
  G_ERR(C_OBJERR_USAGE_RPC_NOT_VALID) :=
       'Object Validate: RPC Package/body not valid - recompile required';
  G_ERR(C_OBJERR_USAGE_NO_DEP) :=
       'Object Validate: Package body has no RPC dependents - either a recompile is required or RPC usage patch is missing';
  G_ERR(C_OBJERR_USAGE_LIST_IS_EMPTY) :=
       'Object Validate: No RPC packages defined - RPC system is invalid';

	/* Support Errors */

  G_ERR(C_SUPERR_PROGRAM_ACCESS_CODE) :=
                         'Illegal access - this method cannot be called directly. Use fnd_adg_utility.manage_concurrent_program';

  G_ERR(C_SUPERR_INVALID_CONC_PROGRAM) :=
                         'Concurrent Application/Program not defined';

  G_ERR(C_SUPERR_VALIDATE_PRIMARY) := 'DB Link does not resolve to primary';

end;

/*==========================================================================*/

function get_error_message(p_err number,p_errmsg varchar2) return varchar2
as
l_err_idx       number;
l_err_no_str    varchar2(255);
begin

  if ( p_err is null )
  then
     l_err_idx := C_ERR_NULL;
  else
     if ( p_err <= 0 )
     then
        l_err_idx := C_ERR_INVALID_MSG_NO;
     else
        if ( G_ERR.exists(p_err) )
        then
           l_err_idx := p_err;
        else
           l_err_idx := C_ERR_UNKNOWN;
        end if;
     end if;
  end if;

  l_err_no_str := to_char(l_err_idx);

  if ( p_err is not null )
  then
     if ( l_err_idx <> p_err )
     then
        l_err_no_str := l_err_no_str || '[' || p_err || ']';
     end if;
  end if;

  if ( p_errmsg is null )
  then
     return substr('ADG-ERR '||l_err_no_str||': '||G_ERR(l_err_idx),1,2048);
  else
     return substr('ADG-ERR '||l_err_no_str||': '||G_ERR(l_err_idx)
                             ||' ['||p_errmsg||']',1,2048);
  end if;

end;

/*==========================================================================*/

function get_error_msg(p_err number) return varchar2
as
begin

  return get_error_message(p_err,null);

end;

/*==========================================================================*/

procedure raise_error(p_err number, p_errmsg varchar2 default null)
as
begin
  raise_application_error(-20001,get_error_message(p_err,p_errmsg));
end;

/*==========================================================================*/

begin
  init_error_table;
end fnd_adg_exception;

/
