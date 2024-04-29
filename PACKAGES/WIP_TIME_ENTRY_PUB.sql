--------------------------------------------------------
--  DDL for Package WIP_TIME_ENTRY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_TIME_ENTRY_PUB" AUTHID CURRENT_USER AS
/* $Header: wipwsils.pls 120.2 2008/01/22 04:35:16 sisankar noship $ */

type t_wip_time_intf is table of wip_time_entry_interface%rowtype index by binary_integer;

procedure  process_interface_records(retcode out nocopy number,
                                     errbuf  out nocopy varchar2,
                                     p_organization_id in number);

procedure get_time_preferences(p_organization_id IN NUMBER default null,
                               x_shift_enabled OUT NOCOPY boolean,
                               x_clock_enabled OUT NOCOPY boolean);

procedure process(p_wip_time_intf_tbl in t_wip_time_intf,
                  x_ret_status out nocopy number);

procedure write_to_log(p_interface_id in number,
                       p_error_msg in varchar2,
                       p_stmt_num in number);

function is_emp_invalid(p_org_id in number,
                        p_dep_id in number,
                        p_res_id in number,
                        p_emp_id in number)
return boolean;

function default_job_id(p_org_id   in number,
                        p_job_name in varchar2)
return number;

function is_job_invalid(p_org_id in number,
                        p_we_id  in number)
return boolean;

function get_op_dept_id(p_org_id in number,
                        p_we_id  in number,
                        p_op_seq in number)
return number;

function default_res_id(p_org_id   in number,
                        p_res_name in varchar)
return number;

function is_res_invalid(p_org_id in number,
                        p_dep_id in number,
                        p_res_id in number)
return boolean;

function is_emp_shift_in(p_wip_entity_id in number,
                         p_employee_id   in number)
return boolean;

END WIP_TIME_ENTRY_PUB;

/
