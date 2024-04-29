--------------------------------------------------------
--  DDL for Package Body FND_CONC_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_GLOBAL" as
/* $Header: AFCPGBLB.pls 120.2.12010000.2 2019/03/08 20:43:50 ckclark ship $ */


    zconc_copies number := NULL;
    zconc_hold varchar2(1) := NULL;
    zconc_priority number := NULL;
    zconc_save_output varchar2(1) := NULL;
    zconc_single_thread varchar2(1) := NULL;
    zprinter varchar2(255) := NULL;
    zconc_priority_request number := NULL;
    zconc_print_together varchar2(1) := NULL;
    zconc_print_output varchar2(1) := NULL;
    zrequest_data varchar2(240) := NULL;
    zconc_status varchar(30) := 'NONE';
    zconc_restart_time varchar2(50) := NULL;
    zrelease_sub_request varchar2(1) := NULL;
    zops_inst_num number := NULL;
    zrequest_grp_code varchar2(30) := NULL;
    zrequest_grp_appl_name varchar2(50) := NULL;

/*
** GENERIC_ERROR (Internal)
**
** Set error message and raise exception for unexpected sql errors
*/
procedure GENERIC_ERROR(routine in varchar2,
			errcode in number,
			errmsg in varchar2) is
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
    app_exception.raise_exception;
end;

/*
** CONC_COPIES - Number of copies to print for a concurrent process
*/
function CONC_COPIES return number is
begin
    return(zconc_copies);
end CONC_COPIES;

/*
** CONC_HOLD - Temporarily hold a concurrent process
*/
function CONC_HOLD return varchar2 is
begin
    return(zconc_hold);
end CONC_HOLD;

/*
** CONC_PRIORITY - Priority for running a concurrent process
*/
function CONC_PRIORITY return number is
begin
    return(zconc_priority);
end CONC_PRIORITY;

/*
** CONC_SAVE_OUTPUT - Save the output form a concurrent process
*/
function CONC_SAVE_OUTPUT return varchar2 is
begin
    return(zconc_save_output);
end CONC_SAVE_OUTPUT;

/*
** CONC_SINGLE_THREAD - Single thread process the concurrent process
*/
function CONC_SINGLE_THREAD return varchar2 is
begin
    return(zconc_single_thread);
end CONC_SINGLE_THREAD;

/*
** PRINTER
*/
function PRINTER return varchar2 is
begin
    return(zprinter);
end PRINTER;

/*
** CONC_PRIORITY_REQUEST
*/
function CONC_PRIORITY_REQUEST return number is
begin
    return(zconc_priority_request);
end CONC_PRIORITY_REQUEST;

/*
** CONC_PRINT_TOGETHER
*/
function CONC_PRINT_TOGETHER return varchar2 is
begin
    return(zconc_print_together);
end CONC_PRINT_TOGETHER;

/*
** CONC_PRINT_OUTPUT
*/
function CONC_PRINT_OUTPUT return varchar2 is
begin
    return(zconc_print_output);
end CONC_PRINT_OUTPUT;

/*
** CONC_PRINT_OUTPUT
*/
function REQUEST_DATA return varchar2 is
begin
    return(zrequest_data);
end REQUEST_DATA;

/*
** Override_OPS_INST_NUM
** Used by Transaction Managers and Concurrent Managers.
** INTERNAL AOL USE ONLY
*/
procedure Override_OPS_INST_NUM(Inst_num in number) is
begin
  if (Inst_num is not null) then
    zops_inst_num := Inst_num;
  else
    select instance_number
    into zops_inst_num
    from v$instance;
  end if;
end Override_OPS_INST_NUM;


/*
** OPS_INST_NUM
*/
function OPS_INST_NUM return number is
begin
    return(zops_inst_num);
end OPS_INST_NUM;


/*
** INITIALIZE
** Set new values for CPM globals.
** INTERNAL AOL USE ONLY
*/
procedure INITIALIZE(conc_copies in number,
		     conc_hold in varchar2,
		     conc_priority in number,
		     conc_save_output in varchar2,
		     conc_single_thread in varchar2,
		     printer in varchar2,
		     conc_priority_request in number,
		     conc_print_together in varchar2,
		     conc_print_output in varchar2,
		     request_data in varchar2,
		     db_temp_dir in varchar2) is
begin
    /*
    ** Set globals from parameters
    */
    zconc_copies := conc_copies;
    zconc_hold := conc_hold;
    zconc_priority := conc_priority;
    zconc_save_output := conc_save_output;
    zconc_single_thread := conc_single_thread;
    zprinter := printer;
    zconc_priority_request := conc_priority_request;
    zconc_print_together := conc_print_together;
    zconc_print_output := conc_print_output;
    zrequest_data := request_data;
    zconc_status := 'NONE';
    zconc_restart_time := NULL;
    zrelease_sub_request := NULL;

    /*
    ** Select any name globals that were not directly passed.
    ** Example:
    **   begin
    **   select u.user_name
    **       into zuser_name
    **       from fnd_user u
    **       where u.user_id = initialize.user_id;
    **   exception
    **   when no_data_found then
    **       zuser_name := NULL;
    **   end;
    */

    /*
    ** Put special values to profile cache.
    ** ### This is for backward compatibility.  Users should
    ** ### reference these globals instead.
    */
    fnd_profile.put('CONC_COPIES', to_char(zconc_copies));
    fnd_profile.put('CONC_HOLD', zconc_hold);
    fnd_profile.put('CONC_PRIORITY', to_char(zconc_priority));
    fnd_profile.put('CONC_SAVE_OUTPUT', zconc_save_output);
    fnd_profile.put('CONC_SINGLE_THREAD', zconc_single_thread);
    fnd_profile.put('CONC_PRINT_TOGETHER', zconc_print_together);
    fnd_profile.put('CONC_DB_TMP_DIR', db_temp_dir);

exception
when others then
    generic_error('FND_CONC_GLOBAL.INITIALIZE', SQLCODE, SQLERRM);
end INITIALIZE;


/*
** GET_REQ_GLOBALS
** Used by CM to get values for special globals.
** INTERNAL AOL USE ONLY
*/
procedure GET_REQ_GLOBALS(conc_status         out nocopy varchar2,
		          request_data        out nocopy varchar2,
		          conc_restart_time   out nocopy varchar2,
			  release_sub_request out nocopy varchar2) is
begin
  conc_status := zconc_status;
  request_data := zrequest_data;
  conc_restart_time := zconc_restart_time;

  --Bug 4113291.  Parameter release_sub_request  is
  --obsolete. Returning NULL value for this parameter.
  release_sub_request := NULL;
exception
when others then
    generic_error('FND_CONC_GLOBAL.GET_REQ_GLOBALS', SQLCODE, SQLERRM);
end GET_REQ_GLOBALS;


/*
** SET_REQ_GLOBALS
** Used by CM to set values for special globals.
** INTERNAL AOL USE ONLY
*/
procedure SET_REQ_GLOBALS(conc_status         in varchar2 default null,
		          request_data        in varchar2 default null,
		          conc_restart_time   in varchar2 default null,
			  release_sub_request in varchar2 default null) is
begin
  zconc_status := nvl(conc_status, 'NONE');
  zrequest_data := request_data;
  zconc_restart_time := conc_restart_time;

  --Bug 4113291. Parameter release_sub_request  is
  --obsolete. Ignoreing the value of this parameter.
  zrelease_sub_request := NULL;

  if (release_sub_request is not null) then
    if( FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )then

      fnd_log.string(
            FND_LOG.LEVEL_EVENT,
            'fnd.plsql.FND_CONC_GLOBAL.SET_REQ_GLOBALS',
            'The release_sub_request parammeter is obsolete now'||
	                            'and it''s value is ignored.');
    end if;
  end if;

exception
when others then
    generic_error('FND_CONC_GLOBAL.GET_REQ_GLOBALS', SQLCODE, SQLERRM);
end SET_REQ_GLOBALS;

/*
** SET_FORM_GLOBALS
** Used by CM to set values for special form globals.
** request_grp_code - Name of non-default request group passed as form parameter
** request_grp_appl - Application short name of non-default request group passed as form parameter
** INTERNAL AOL USE ONLY
*/
procedure SET_FORM_GLOBALS(request_grp_code  in varchar2 default null,
		          request_grp_appl_name   in varchar2 default null) is
begin
  zrequest_grp_code := nvl(request_grp_code, 'NONE');
  zrequest_grp_appl_name := nvl(request_grp_appl_name, 'NONE');

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )then

      fnd_log.string(
            FND_LOG.LEVEL_STATEMENT,
            'fnd.plsql.FND_CONC_GLOBAL.SET_FORM_GLOBALS',
            'Set form globals: request_grp_code = '||zrequest_grp_code||
            'request_grp_appl = '||zrequest_grp_appl_name);
  end if;

exception
when others then
    generic_error('FND_CONC_GLOBAL.GET_FORM_GLOBALS', SQLCODE, SQLERRM);
end SET_FORM_GLOBALS;


/*
** REQUEST_GRP_CODE
*/
function REQUEST_GRP_CODE return varchar2 is
begin
    return(zrequest_grp_code);
end REQUEST_GRP_CODE;

/*
** REQUEST_GRP_APPL_NAME
*/
function REQUEST_GRP_APPL_NAME return varchar2 is
begin
    return(zrequest_grp_appl_name);
end REQUEST_GRP_APPL_NAME;


begin
  select instance_number
    into zops_inst_num
    from v$instance;
  /* v$instance should contain exactly one row.  I
   * can't think of any exceptions that we should be
   * catching here.
   */
end FND_CONC_GLOBAL;

/
