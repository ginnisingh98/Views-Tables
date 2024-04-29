--------------------------------------------------------
--  DDL for Package FND_CONC_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_GLOBAL" AUTHID CURRENT_USER as
/* $Header: AFCPGBLS.pls 120.3.12010000.2 2019/03/08 20:45:25 ckclark ship $ */
/*#
 * This package is used for submitting sub-requests from PL/SQL concurrent programs.
 * @rep:scope public
 * @rep:product FND
 * @rep:displayname Concurrent Global package
 * @rep:category BUSINESS_ENTITY FND_CP_REQUEST
 * @rep:lifecycle active
 * @rep:compatibility S
 */

/*
** CONC_COPIES - Number of copies to print for a concurrent process
*/
function CONC_COPIES return number;
pragma restrict_references (CONC_COPIES, WNDS, WNPS);

/*
** CONC_HOLD - Temporarily hold a concurrent process
*/
function CONC_HOLD return varchar2;
pragma restrict_references (CONC_HOLD, WNDS, WNPS);

/*
** CONC_PRIORITY - Priority for running a concurrent process
*/
function CONC_PRIORITY return number;
pragma restrict_references (CONC_PRIORITY, WNDS, WNPS);

/*
** CONC_SAVE_OUTPUT - Save the output form a concurrent process
*/
function CONC_SAVE_OUTPUT return varchar2;
pragma restrict_references (CONC_SAVE_OUTPUT, WNDS, WNPS);

/*
** CONC_SINGLE_THREAD - Single thread process the concurrent process
*/
function CONC_SINGLE_THREAD return varchar2;
pragma restrict_references (CONC_SINGLE_THREAD, WNDS, WNPS);

/*
** PRINTER
*/
function PRINTER return varchar2;
pragma restrict_references (PRINTER, WNDS, WNPS);

/*
** CONC_PRIORITY_REQUEST
*/
function CONC_PRIORITY_REQUEST return number;
pragma restrict_references (CONC_PRIORITY_REQUEST, WNDS, WNPS);

/*
** CONC_PRINT_TOGETHER
*/
function CONC_PRINT_TOGETHER return varchar2;
pragma restrict_references (CONC_PRINT_TOGETHER, WNDS, WNPS);

/*
** CONC_PRINT_OUTPUT
*/
function CONC_PRINT_OUTPUT return varchar2;
pragma restrict_references (CONC_PRINT_OUTPUT, WNDS, WNPS);

/*
** REQUEST_DATA
*/

/*#
 * Returns the state information saved by the parent request prior to being paused.
 * @return Returns Request data
 * @rep:displayname Get Request Data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
function REQUEST_DATA return varchar2;
pragma restrict_references (REQUEST_DATA, WNDS, WNPS);

/*
** Override_OPS_INST_NUM
** Used by Transaction Managers and Concurrent Managers.
** INTERNAL AOL USE ONLY
*/
procedure Override_OPS_INST_NUM(Inst_num in number);

/*
** OPS_INST_NUM
*/
function OPS_INST_NUM return number;
pragma restrict_references (OPS_INST_NUM, WNDS, WNPS);

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
		     db_temp_dir in varchar2);

/*
** GET_REQ_GLOBALS
** Used by CM to get values for special globals.
** INTERNAL AOL USE ONLY
*/
procedure GET_REQ_GLOBALS(conc_status         out nocopy varchar2,
		          request_data        out nocopy varchar2,
		          conc_restart_time   out nocopy varchar2,
			  release_sub_request out nocopy varchar2);

/*
** SET_REQ_GLOBALS
** Used by CM to set values for special globals.
** INTERNAL AOL USE ONLY
*/
/*#
 * Set the values for special global variables.
 * @param conc_status Status of the parent request. This must be set to 'PAUSED'.
 * @param request_data State information of the parent request. This will be used when the request is restarted.
 * @param conc_restart_time Time (in the future) at which the parent should be restarted.
 * @param release_sub_request Obsolete parameter (Do not use).
 * @rep:displayname Set Request Globals
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 */
procedure SET_REQ_GLOBALS(conc_status         in varchar2 default null,
		          request_data        in varchar2 default null,
		          conc_restart_time   in varchar2 default null,
			  release_sub_request in varchar2 default null);


/*
** SET_FORM_GLOBALS
** Used by CM to set values for special form globals.
** request_grp_code - Name of non-default request group passed as form parameter
** request_grp_appl_name - Application short name of non-default request group passed as form parameter
** INTERNAL AOL USE ONLY
*/
procedure SET_FORM_GLOBALS(request_grp_code  in varchar2 default null,
		          request_grp_appl_name   in varchar2 default null);

/*
** REQUEST_GRP_CODE
*/
function REQUEST_GRP_CODE return varchar2;
pragma restrict_references (REQUEST_GRP_CODE, WNDS, WNPS);

/*
** REQUEST_GRP_APPL_NAME
*/
function REQUEST_GRP_APPL_NAME return varchar2;
pragma restrict_references (REQUEST_GRP_APPL_NAME, WNDS, WNPS);

end FND_CONC_GLOBAL;

/
