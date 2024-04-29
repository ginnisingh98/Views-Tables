--------------------------------------------------------
--  DDL for Package MSC_NETCHANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_NETCHANGE_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCNETCS.pls 120.0 2005/05/25 17:32:30 appldev noship $ */

Procedure compare_plans(from_plan number,
                       to_plan number,
                       options_flag number,
                       p_folder_id number,
                       exception_list varchar2,
                       p_criteria_id number,
                       option_query_id out nocopy number,
                       exception_query_id out nocopy number
                       );
Function convert_condition(operator number) RETURN varchar2;
Procedure compare_options;
Procedure compare_aggregate;
Procedure compare_optimize;
Procedure compare_orgs;
Procedure compare_schedules;
Procedure compare_constraints;
Procedure compare_goalprog;

Procedure compare_exceptions(
                       exception_list varchar2,
                       item_where_clause varchar2,
                       resource_where_clause varchar2);

Procedure populate_all_exceptions(p_plan_id number,p_report_id number);

function calculate_start_date (p_org_id               IN NUMBER,
                               p_sr_instance_id       IN    NUMBER,
                               p_plan_start_date      IN    DATE,
                               p_daily_cutoff_bucket  IN    NUMBER,
                               p_weekly_cutoff_bucket IN    NUMBER,
                               p_period_cutoff_bucket IN    NUMBER)
                          return varchar2 ;

Procedure checkPlanStatus(p_from_plan in number,
                            p_to_plan in number,
                            p_status out nocopy number,
                            p_report_id out nocopy number);


Procedure compare_all_exceptions(errbuf             OUT NOCOPY VARCHAR2,
                                 retcode            OUT NOCOPY NUMBER,
                                 p_from_plan         IN  NUMBER,
                                 p_to_plan          IN  NUMBER);

Procedure compare_each_exception(p_report_id number);

Procedure filter_data(p_report_id number,
                              p_excp_type number,
                              where_clause varchar2);

Function category_name(p_org_id number, p_instance_id number,
                       p_item_id number,
                       p_plan_id number) return varchar2;

Procedure compare_plan_need_refresh(p_plan_id number);

Procedure purge_plan(errbuf  OUT NOCOPY VARCHAR2,
                     retcode OUT NOCOPY NUMBER,
                     p_plan_id IN NUMBER);

END Msc_Netchange_Pkg;

 

/
