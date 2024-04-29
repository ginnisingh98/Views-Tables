--------------------------------------------------------
--  DDL for Package CSY_KPI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSY_KPI_PKG" AUTHID CURRENT_USER AS
/* $Header: csykpis.pls 115.1 2004/07/02 23:40:08 pleuzzi noship $ */
g_seq             number := 1;
g_user_id         number;
g_login_user_id   number;
g_conc_program_id number;
g_conc_login_id   number;
g_conc_appl_id    number;
g_conc_request_id number;

-- procedure to upload changed data in the audit and cs tables to
-- refresh materialized views. Used with the concurrent manager program
-- CS_CSY_KPI_LOAD_INCREMENTAL
procedure incremental_data_load(p_errbuf out nocopy varchar2,
                                p_retcode out nocopy number);

-- procedure to initally load data into materialized views
-- Used with the concurrent manager program
-- CS_CSY_KPI_LOAD_INITIAL
procedure initial_data_load(p_errbuf out nocopy varchar2,
                                p_retcode out nocopy number);

-- procedure to refresh the materialized views
-- Used with concurrent manager program
-- CS_CSY_KPI_REFRESH_MV
procedure refresh_mvs(p_errbuf out nocopy varchar2,
                      p_retcode out nocopy number);
procedure debug(l_msg varchar2);

-- procedure to find the number of service requests between a given date range
-- finds number of service request responded each day and time
-- spent with agent and others before request was responded.
procedure get_response_timings    (p_from_date in date,
                                   p_to_date   in date);

-- procedure to find out amount of time resolved requests spent in various stages
-- such as With support, Agent, External Organization, internal organization etc
procedure get_resolution_timings  (p_from_date in date,
                                   p_to_date   in date);

-- procedure finds out number of resolutions, rework and repeated reworks.
-- used in the Requests Resolved per Agent report
procedure get_sr_resolutions      (p_from_date in date,
                                   p_to_date   in date);

-- procedure finds out total number of service requests assigned to agents
-- and reassigned to some other agent for each day.
procedure get_sr_agent_assignments(p_from_date in date,
                                   p_to_date   in date);
-- procedure finds out total number of service requests assigned to a group
-- and reassigned to some others group for each day.
procedure get_sr_group_assignments(p_from_date in date,
                                   p_to_date   in date);

-- procedure finds out number of pending service requests for agents, group and severity
procedure get_sr_backlog          (p_from_date in date,
                                   p_to_date   in date);
function get_agents_time(p_resource_id number,
                        p_start_date date,
                        p_end_date date) return number;
function  sev_names               (p_imp_lvl  in number) return varchar2;
end;

 

/
