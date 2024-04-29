--------------------------------------------------------
--  DDL for Package BIS_CREATE_REQUESTSET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_CREATE_REQUESTSET" AUTHID CURRENT_USER AS
/*$Header: BISCRSTS.pls 120.2 2006/09/07 14:33:27 aguwalan noship $*/


Type varcharTableType is Table of varchar2(30) index by binary_integer;
---this procedure is for creating a request set and add it to a report group for given responsibility
procedure create_set_all(p_setname in varchar2,p_setlongname in varchar2,p_setapp in varchar2);
procedure delete_set_all(p_setname in varchar2,p_setlongname in varchar2,p_setapp in varchar2);
procedure get_stage_sequence(p_set_name in varchar2,
                               p_set_app in varchar2,
                               p_process_name in varchar2,
                               p_process_app in varchar2,
                               x_stage out NOCOPY varchar2,
                               x_sequence out NOCOPY number);

function get_max_prog_sequence(p_set_name in varchar2,
                                 p_set_app in varchar2,
                                 p_stage_name varchar2) return number  ;







/**
*this api is a wrapper of add_portlet_to_set and add_table_to_set and add_page_to_set
*parameter description:
*(1)p_object_type:from bis_obj_dependency table object_type, like 'PAGE', 'TABLE','PORTLET','MV', etc
 (2)p_object_name:table name, portlet internal name etc
 (3)p_object_owner: from bis_obj_dependency table, 'FII','POA', etc
 (4)p_setname : request set short name
 (5)p_setapp: request set application short name
 (6)p_option: create the request set per portlet,per page or for all. Currently only support 'ALL'
 (7)p_analyze_table: 'Y'--add fnd_stats call for MVs
 (8)p_refresh_mode:'INCR'--incremental refresh,'INIT'--initial refresh,'INIT_INCR'--Initial and Incremental refresh
 (9)p_portal_exist: 'Y' if portal installed in the same instance, null---not installed
**/
procedure add_object_to_set(p_object_type in varchar2,
                            p_object_name in varchar2,
                            p_object_owner in varchar2,
                            p_setname in varchar2,
                            p_setapp in varchar2,
                            p_option in varchar2,
                            p_analyze_table in varchar2,
                            p_refresh_mode in varchar2,
                            p_portal_exist in varchar2,
                            p_force_full_refresh in varchar2);



function set_in_group(p_set_name varchar2,
                      p_setapp varchar2,
                      p_group_name varchar2,
                      p_group_app varchar2) return varchar2;

procedure remove_empty_stages(p_set_name varchar2,
                               p_setapp varchar2);

procedure wrapup( p_setname in varchar2,
                     p_setapp in varchar2,
                     p_option in varchar2,
                     p_analyze_table in varchar2,
                     p_refresh_mode in varchar2,
                     p_force_full_refresh in varchar2,
                     p_alert_flag in varchar2);

function is_stage_empty(p_setapp_id number,
                        p_set_id number,
                        p_set_stage_id number) return varchar2;

procedure get_stats_stage_sequence(p_set_name in varchar2,
                               p_set_app in varchar2,
                               p_process_name in varchar2,
                               p_parameter_value in varchar2,
                               p_parameter_type in varchar2,
                               x_stage out NOCOPY varchar2,
                               x_sequence out NOCOPY number);

function get_object_owner(p_obj_name in varchar2,p_obj_type in varchar2) return varchar2;

---this function will return 'N' if the object has no direct dependency except dimensions
function dependency_exist(p_object_name in varchar2, p_object_type in varchar2) return varchar2;

function object_has_data(p_object_name in varchar2, p_object_type in varchar2,p_object_owner in varchar2) return varchar2;

procedure add_first_last_stages(p_set_name in varchar2,p_set_app in varchar2,p_max_stage in number,p_min_stage in number,
                                p_rsg_history_flag in varchar2);

procedure create_rs_option(p_set_name in varchar2, p_set_app in varchar2,
p_refresh_mode in varchar2, p_analyze_table in varchar2,p_force_full in varchar2,
p_alert_flag in varchar2, p_rsg_history_flag in VARCHAR2);

procedure create_rs_objects(p_set_name in varchar2, p_set_app in varchar2,
p_object_type in varchar2, p_object_name in varchar2, p_object_owner in
varchar2);

procedure delete_rs_objects(p_set_name in varchar2, p_set_app in varchar2 );

procedure delete_rs_option(p_set_name in varchar2, p_set_app in varchar2);

procedure preparation_conc(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR,
    p_request_set_code	   IN VARCHAR
);

procedure finalization_conc(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR,
    p_request_set_code	   IN VARCHAR
);

FUNCTION get_apps_schema_name RETURN VARCHAR2;

procedure bsc_loader_wrapper(
    p_request_set_code	   IN VARCHAR
);

function get_indicator(p_object_name varchar2) return varchar2;

procedure analyze_objects_in_set(
    p_request_set_code	   IN VARCHAR2,
    p_set_app              IN varchar2
);

procedure seed_data_validation(
        errbuf  			   OUT NOCOPY VARCHAR2,
        retcode		           OUT NOCOPY VARCHAR,
     p_request_set_code	   IN VARCHAR2,
     p_set_app              IN varchar2
) ;

procedure add_any_object_to_set(p_object_name in varchar2,
                             p_object_type in varchar2,
                             p_setname in varchar2,
                             p_set_application in varchar2,
                             p_option in varchar2,
                             p_analyze_table in varchar2,
                             p_refresh_mode in varchar2,
                             p_force_full_refresh in varchar2) ;

PROCEDURE add_link_history_stage ( p_set_name  IN varchar2,
                                    p_set_app   IN varchar2,
                                    p_max_stage IN number,
                                    p_rsg_history_flag IN VARCHAR2);

function get_bsc_schema_name return varchar;
function get_mv_log (p_object_name in varchar2,p_schema_name in varchar2 ) return varchar2 ;
function get_report_type(p_object_name in varchar2) return varchar2 ;
function get_indicator_auto_gen(p_object_name in varchar2) return number;

/*
 * Added for Bug#4881518 :: API to check the status of all the request inside the request
 */
PROCEDURE set_rs_status(errbuf   OUT NOCOPY VARCHAR2,
                        retcode  OUT NOCOPY VARCHAR) ;

/*
 * API to return the value of the request set option='HISTORY_COLLECT' :: Enh#4418520-aguwalan
 */
FUNCTION is_history_collect_on(p_request_set_name IN VARCHAR2,
                               p_request_app_id IN NUMBER) RETURN BOOLEAN;

/*
 * Overloading is_history_collect_on API to take the root_Request_id and return the request set
 * option='HISTORY_COLLECT' :: Enh#4418520-aguwalan
 */
FUNCTION is_history_collect_on(p_root_request_id IN NUMBER) RETURN BOOLEAN;

/*
 * Overloading wrapup api to support Enh#4418520-aguwalan
 */
PROCEDURE wrapup( p_setname in varchar2,
                     p_setapp in varchar2,
                     p_option in varchar2,
                     p_analyze_table in varchar2,
                    p_refresh_mode in varchar2,
                    p_force_full_refresh in varchar2,
                    p_alert_flag in varchar2,
                    p_rsg_history_flag in varchar2);

END BIS_CREATE_REQUESTSET;


 

/
