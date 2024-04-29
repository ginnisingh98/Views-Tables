--------------------------------------------------------
--  DDL for Package MSC_REL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_REL_WF" AUTHID CURRENT_USER AS
/*$Header: MSCRLWFS.pls 120.2 2007/10/02 02:11:31 eychen ship $ */

    TYPE NumTblTyp IS TABLE OF NUMBER;
    WIP_DIS_MASS_LOAD       CONSTANT INTEGER := 1;
    WIP_REP_MASS_LOAD       CONSTANT INTEGER := 2;
    WIP_DIS_MASS_RESCHEDULE CONSTANT INTEGER := 4;

    LOT_BASED_JOB_LOAD      CONSTANT INTEGER := 5;
    LOT_BASED_JOB_RESCHEDULE      CONSTANT INTEGER := 6;

    PURCHASE_REQ_MASS_LOAD            CONSTANT INTEGER := 8;
    PURCHASE_REQ_RESCHEDULE      CONSTANT INTEGER := 16;
    PURCHASE_ORDER_RESCHEDULE      CONSTANT INTEGER := 20;
    EAM_DIS_MASS_RESCHEDULE        CONSTANT INTEGER := 21;
    PURCHASE_ORDER      CONSTANT INTEGER := 1;   -- order type lookup
    PURCHASE_REQ           CONSTANT INTEGER := 2;
    WORK_ORDER          CONSTANT INTEGER := 3;

PROCEDURE release_supplies
(
errbuf                  OUT NOCOPY VARCHAR2
,retcode                 OUT NOCOPY NUMBER
, arg_plan_id			IN      NUMBER
, arg_org_id 		IN 	NUMBER
, arg_instance           IN      NUMBER
, arg_owning_org_id 			IN 	NUMBER
, arg_owning_instance               IN      NUMBER);

PROCEDURE DeleteActivities( p_item_key varchar2,
                            p_dblink varchar2 default null);

PROCEDURE Select_buyer_supplier( itemtype  in varchar2,
                         itemkey   in varchar2,
                         actid     in number,
                         funcmode  in varchar2,
                         resultout out NOCOPY varchar2 );
Procedure start_reschedule_po_wf(p_plan_id number,
                              p_transaction_id number,
                              p_instance_id number,
                              p_load_type number);
Procedure notify_planner_program(p_plan_id number,
                                p_transaction_id number,
                                p_planner varchar2,
                                p_process varchar2);
Procedure notify_planner_decline(
                           errbuf OUT NOCOPY VARCHAR2,
                           retcode OUT NOCOPY NUMBER,
                                p_plan_id number,
                                p_transaction_id number,
                                p_planner varchar2,
                                p_process varchar2);
Procedure reset_load_type (p_plan_id number, p_transaction_id number);

FUNCTION GET_DOCK_DATE (p_instance_id NUMBER,
                         p_receiving_calendar VARCHAR2,
                         p_delivery_calendar VARCHAR2,
                         p_implement_date DATE,
                         p_lead_time NUMBER ) RETURN date;

PROCEDURE reschedule_purchase_orders
( arg_plan_id			IN      NUMBER
, arg_org_id 		IN 	NUMBER
, arg_instance              IN      NUMBER
, arg_owning_org 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_count                       OUT NOCOPY NUMBER
, arg_released_instance         IN OUT NOCOPY NumTblTyp
, arg_po_res_id 		IN OUT NOCOPY NumTblTyp
, arg_po_res_count              IN OUT NOCOPY NumTblTyp
, arg_po_pwb_count              IN OUT NOCOPY NumTblTyp);

PROCEDURE release_sales_orders
( arg_plan_id			IN      NUMBER
, arg_org_id 		IN 	NUMBER
, arg_instance              IN      NUMBER
, arg_owning_org 		IN 	NUMBER
, arg_owning_instance           IN      NUMBER
, arg_released_instance         IN OUT NOCOPY NumTblTyp
, arg_so_rel_id 		IN OUT NOCOPY NumTblTyp
, arg_so_rel_count              IN OUT NOCOPY NumTblTyp
, arg_so_pwb_count              IN OUT NOCOPY NumTblTyp);

Function get_job_seq_from_source(p_instance_id number) RETURN number;

PROCEDURE validate_proj_in_source(
                                  p_org_id          NUMBER,
                                  p_project_id      NUMBER,
                                  p_task_id         NUMBER,
                                  p_start_date      DATE,
                                  p_completion_date DATE,
                                  p_instance_id     NUMBER,
                                  p_valid           OUT NOCOPY VARCHAR2,
                                  p_error           OUT NOCOPY VARCHAR2)  ;

FUNCTION  is_pjm_valid(p_org_id          NUMBER,
                       p_project_id      NUMBER,
                       p_task_id         NUMBER,
                       p_start_date      DATE,
                       p_completion_date DATE,
                       p_instance_id     NUMBER) RETURN NUMBER;

FUNCTION get_acc_class_from_source(p_org_id number, p_item_id number,
             p_project_id number,p_instance_id number) RETURN varchar2;

Function is_source_db_up(p_instance_id number) RETURN boolean;

Procedure get_load_type(itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    resultout out NOCOPY varchar2 );

Procedure start_release_batch_wf(p_plan_id number,
                              p_org_id number,
                              p_instance_id number,
                              p_owning_org number,
                              p_owning_instance number,
                              p_dblink varchar2,
                              p_load_type number,
                              p_instance_code varchar2) ;

Procedure insert_temp_table(itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    resultout out NOCOPY varchar2 ) ;

Procedure start_source_program(itemtype  in varchar2,
                    itemkey   in varchar2,
                    actid     in number,
                    funcmode  in varchar2,
                    resultout out NOCOPY varchar2 );

Procedure get_supply_data(p_plan_id in number,
                      p_transaction_id in number,
                      p_query_id in number,
                      p_dblink in varchar2);

PROCEDURE init_db(p_user_name varchar2);

PROCEDURE get_profile_value(p_profile_name   IN   varchar2,
                            p_instance_id    IN   number,
                            p_calling_source IN   varchar2 DEFAULT 'FORM',
                            p_profile_value  OUT  NOCOPY varchar2);

FUNCTION get_offset_date(p_calendar_code in varchar2,
                         p_inst_id       in number,
                         p_lead_time     in number,
                         p_date          in date) return date;

PROCEDURE update_so_dates(p_plan_id number, p_demand_id number,
                           p_inst_id number, p_implement_date date,
                           p_ship_date out nocopy date,
                           p_arrival_date out nocopy date,
                           p_earliest_date out nocopy date);

PROCEDURE unrelease_so_set(p_plan_id number, p_demand_id number,
                           p_instance_id number);

FUNCTION verify_so_release(p_plan_id number, p_demand_id number,
                           p_inst_id number)
         RETURN varchar2;
PROCEDURE so_release_workflow_program(p_batch_id in number,
                                    p_instance_id in number,
                                    p_planner in varchar2,
                                    p_request_id out nocopy number);
PROCEDURE start_so_release_workflow(
errbuf                  OUT NOCOPY VARCHAR2
,retcode                 OUT NOCOPY NUMBER,
p_batch_id number,
p_instance_id number);

FUNCTION verify_so_dates(p_old_schedule_date date,
                         p_request_date date,
                         p_new_schedule_date date) RETURN date;

FUNCTION date_offset(p_org_id number, p_instance_id number,
                     p_bucket_type number,
                     p_date date, p_offset_days number) return date;

END msc_rel_wf;

/
