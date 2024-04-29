--------------------------------------------------------
--  DDL for Package WIP_WS_LABOR_METRIC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WS_LABOR_METRIC_PUB" AUTHID CURRENT_USER AS
/* $Header: wipwslms.pls 120.3 2007/11/20 05:23:53 hvutukur noship $ */

function get_calendar_code(p_organization_id in number)
return varchar2;

function is_time_uom(p_uom_code in varchar2)
return number;

function get_period_end(p_calendar_code in varchar2,
                        p_date in date)
return date;

function get_period_start(p_org_id in number,
                          p_date in date)
return date;

function get_date_for_seq(p_org_id in number,
                          p_seq_num in number,
                          p_shift_num in number)
return date;

function get_date(p_org_id in number,
                  p_seq_num in number,
                  p_shift_num in number)
return date;

function get_index_for_date(p_date in date,
                            p_organization_id in number,
                            p_dept_id in number,
                            p_resource_id in number)
return varchar2;

procedure handle_error(p_error_msg in varchar2,
                       p_stmt_num in number,
                       p_proc_name in varchar2);


procedure calculate_metrics(retcode out nocopy number,
                            errbuf  out nocopy varchar2,
                            p_organization_id in number);

function get_client_date(p_date in Date)
return date;

END WIP_WS_LABOR_METRIC_PUB;

/
