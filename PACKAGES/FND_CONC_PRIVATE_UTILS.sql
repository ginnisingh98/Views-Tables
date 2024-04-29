--------------------------------------------------------
--  DDL for Package FND_CONC_PRIVATE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_PRIVATE_UTILS" AUTHID CURRENT_USER as
/* $Header: AFCPSCRS.pls 120.4.12010000.4 2018/05/07 16:54:33 pferguso ship $ */


/* Gets the service name based on given node and the value of FS_SVC_PREVIX
profile option. */
function get_fs_svc_name(node in varchar2) return varchar2;

/*returns either error or (possibly null) resubmission time */
function get_resub_time(req_id in number) Return varchar2;

/* returns notification id */
function send_simple_done_msg(req_id in number,
                              stat in varchar2,
                              recip in varchar2,
                              completion in date,
	                      etext out NOCOPY varchar2,
       		              estack out NOCOPY varchar2
                             ) Return number;

/* Overloaded: records use of a temp file in fnd_temp_files */
procedure record_temp_file_use(filename in varchar, node in varchar);

/* Overloaded: records use of a temp file in fnd_temp_files
 * type_codes: F=Fnd_file context; R=Request context; O=Other context
 */
procedure record_temp_file_use( filename in varchar, node in varchar,
				type_code in varchar, req_id in number);

/* deletes record of a temp file from fnd_temp_files */
procedure erase_temp_file_use(filename in varchar, node in varchar, type in varchar);

/* returns 1 if temp file has been recorded, else returns 0 */
function check_temp_file_use (filename in varchar, node in varchar, type in varchar) return number;


Procedure call_pp_plsql(user_id in number,
                        resp_id in number,
                        resp_appl_id in number,
                        security_group_id in number,
                        site_id in number,
                        login_id in number,
                        conc_login_id in number,
                        prog_appl_id in number,
                        conc_program_id in number,
                        conc_request_id in number,
                        conc_priority_request in number,
                        program in varchar2,
                        step in number,
                        errbuf out NOCOPY varchar2,
                        retcode out NOCOPY number);


/*
 * Switch a manager's resource consumer group to the group it is assigned to
 * in FND_CONCURRENT_QUEUES, or the default group if one is not assigned.
 */
procedure set_mgr_rcg(qaid in number, qid in number);


/*
 * Switch multiorg context
 * Not for use in 11i
 */
procedure set_multiorg_context(org_type in varchar2, org_id in number);


/*
 * When a request is taken off hold it is possible that its original start date
 * may have been missed. If it is scheduled to run on a specific day, it may not
 * currently be that day, and the request should not run immediately.
 * Call get_resub_time for specific-dats requests, and return a new start date if needed.
 * Return null if the start date does not need to be changed.
 *
*/
function adjust_start_date(req_id in number) return varchar2;

end FND_CONC_PRIVATE_UTILS;


/
