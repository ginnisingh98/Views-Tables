--------------------------------------------------------
--  DDL for Package MSC_GET_BIS_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_GET_BIS_VALUES" AUTHID CURRENT_USER AS
/* $Header: MSCBISUS.pls 120.1.12010000.2 2008/07/24 23:50:06 hulu ship $  */

FUNCTION late_orders(arg_plan_id IN NUMBER,
                       arg_instance_id IN NUMBER,
                       arg_organization_id IN NUMBER,
                       arg_start_date  IN DATE,
			arg_end_date IN DATE,
                        arg_inventory_item_Id   IN NUMBER DEFAULT NULL,
                        arg_project_id IN NUMBER DEFAULT NULL,
                        arg_task_id IN NUMBER DEFAULT NULL,
                       arg_category_id IN NUMBER DEFAULT NULL,
                       arg_category_name IN VARCHAR2 DEFAULT NULL,
                       arg_category_set_id IN NUMBER DEFAULT NULL,
                       arg_product_family_id IN NUMBER DEFAULT NULL)
               RETURN NUMBER;
/*satyagi ds enhancement :--------------------------------------------------------------------------------*/
FUNCTION get_actuals(p_plan_id IN NUMBER,
                       p_instance_id IN NUMBER,
				p_organization_id IN NUMBER,
				i IN NUMBER,
                        p_inventory_item_id IN NUMBER DEFAULT NULL,
                        p_project_id IN NUMBER DEFAULT NULL,
                        p_task_id IN NUMBER DEFAULT NULL,
                        p_dept_id IN NUMBER DEFAULT NULL,
                        p_res_id IN NUMBER DEFAULT NULL,
                        p_dept_class IN VARCHAR2 DEFAULT NULL,
                        p_res_group IN VARCHAR2 DEFAULT NULL,
                        p_category_id IN NUMBER DEFAULT NULL,
                        p_category_name IN VARCHAR2 DEFAULT NULL,
                        p_category_set_id IN NUMBER DEFAULT NULL,
                        p_product_family_id IN NUMBER DEFAULT NULL,
                        p_sup_id IN NUMBER DEFAULT NULL,
                        p_sup_site_id IN NUMBER DEFAULT NULL ,
			p_res_instance_id IN NUMBER DEFAULT NULL ,
			p_res_inst_serial_number IN varchar2 DEFAULT NULL) RETURN number;

/*-------------------------------------------------------------------------------satyagi ds enhancement */

FUNCTION check_periods(p_plan_id IN NUMBER) RETURN NUMBER;

PROCEDURE populate_plan_date(p_plan_id IN NUMBER);

PROCEDURE get_item_margin(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER,
                     p_out1 OUT NOCOPY NUMBER,
                     p_out2 OUT NOCOPY NUMBER,
                     p_out3 OUT NOCOPY NUMBER);

PROCEDURE get_margin(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_product_family_id IN number,
                     p_chart IN NUMBER,
                     p_out1 OUT NOCOPY NUMBER,
                     p_out2 OUT NOCOPY NUMBER,
                     p_out3 OUT NOCOPY NUMBER,
                     p_out4 OUT NOCOPY NUMBER,
                     p_out5 OUT NOCOPY NUMBER);

PROCEDURE get_item_margin_trend(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER,
                     p_out1 OUT NOCOPY VARCHAR2,
                     p_out2 OUT NOCOPY VARCHAR2,
                     p_out3 OUT NOCOPY VARCHAR2);

PROCEDURE get_margin_trend(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_product_family_id in number,
                     p_chart IN NUMBER,
                     p_out1 OUT NOCOPY VARCHAR2,
                     p_out2 OUT NOCOPY VARCHAR2,
                     p_out3 OUT NOCOPY VARCHAR2,
                     p_out4 OUT NOCOPY VARCHAR2,
                     p_out5 OUT NOCOPY VARCHAR2
                     );

PROCEDURE get_margin_by_org(p_plan_id IN NUMBER,
                            p_row_count OUT NOCOPY NUMBER,
                            p_org OUT NOCOPY VARCHAR2,
                            p_margin OUT NOCOPY VARCHAR2);


PROCEDURE get_period_name(p_period_list OUT NOCOPY VARCHAR2,
                          p_period_count OUT NOCOPY NUMBER);

/*satyagi ds enhancement :--------------------------------------------------------------------------------*/
PROCEDURE get_trend_actuals(p_plan_id IN NUMBER,
                           p_instance_id IN NUMBER,
				p_org_id IN NUMBER,
				i IN NUMBER,
                        p_inventory_item_id IN NUMBER DEFAULT NULL,
                        p_project_id IN NUMBER DEFAULT NULL,
                        p_task_id IN NUMBER DEFAULT NULL,
                        p_dept_id IN NUMBER DEFAULT NULL,
                        p_res_id IN NUMBER DEFAULT NULL,
                        p_dept_class IN VARCHAR2 DEFAULT NULL,
                        p_res_group IN VARCHAR2 DEFAULT NULL,
                        p_category_id IN NUMBER DEFAULT NULL,
                        p_category_name IN VARCHAR2 DEFAULT NULL,
                        p_category_set_id IN NUMBER DEFAULT NULL,
                        p_product_family_id IN NUMBER DEFAULT NULL,
                        p_sup_id IN NUMBER DEFAULT NULL,
                        p_sup_site_id IN NUMBER DEFAULT NULL,
                        p_value_string OUT NOCOPY VARCHAR2 ,
			p_res_instance_id IN NUMBER DEFAULT NULL,
			p_res_inst_serial_number IN varchar2 DEFAULT NULL
                        );
/*-------------------------------------------------------------------------------satyagi ds enhancement :*/

FUNCTION get_targets(p_chart_type IN NUMBER, p_instance_id IN NUMBER,
	p_org_id IN NUMBER,
        p_time_level varchar2 DEFAULT NULL) RETURN NUMBER;

FUNCTION get_targets_trend(p_chart_type IN NUMBER, p_instance_id IN NUMBER,
	p_org_id IN NUMBER) RETURN VARCHAR2;

-- PRAGMA RESTRICT_REFERENCES(get_actuals, WNDS, WNPS);
-- PRAGMA RESTRICT_REFERENCES(get_trend_actuals, WNDS, WNPS);
-- PRAGMA RESTRICT_REFERENCES (late_orders, WNDS, WNPS);

FUNCTION construct_res_where(p_organization_id number,
                             p_instance_id number,
                             p_dept_id number,
                             p_res_id number,
                             p_res_group varchar2,
                             p_dept_class varchar2,
                             p_start_date date default null,
                             p_end_date date default null) RETURN varchar2;

/*satyagi ds enhancement :--------------------------------------------------------------------------------*/

FUNCTION construct_res_instance_where(p_organization_id number,
					     p_instance_id number,
					     p_dept_id number,
					     p_res_id number,
					     p_res_group varchar2,
					     p_dept_class varchar2,
					     p_start_date date default null,
					     p_end_date date default null ,
					     p_res_instance_id number ,
					     p_res_inst_serial_number varchar2 ) RETURN varchar2 ;

/*-------------------------------------------------------------------------------satyagi ds enhancement :*/

FUNCTION construct_bis_where(p_date boolean,
                             p_organization_id number,
                             p_instance_id number,
                             p_inventory_item_id number,
                             p_project_id number,
                             p_task_id number,
                             p_category_id number,
                             p_category_name IN VARCHAR2 DEFAULT NULL,
                             p_category_set_id number,
                             p_product_family_id number,
                             p_start_date date default null,
                             p_end_date date default null) RETURN varchar2;
FUNCTION get_service_level(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER,
                     p_start_date date default null,
                     p_end_date date default null,
                     p_use_old_demand_qty number default null ) RETURN NUMBER;
FUNCTION service_data_exist(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER) RETURN BOOLEAN;
FUNCTION service_target(p_plan IN NUMBER, p_instance_id IN NUMBER,
	p_org_id IN NUMBER, p_item_id IN NUMBER) RETURN NUMBER;
FUNCTION service_target_trend(p_plan_id IN NUMBER, p_instance_id IN NUMBER,
	p_org_id IN NUMBER, p_item_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_inventory_value(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER) return NUMBER;

FUNCTION inventory_value_trend(p_plan_id  IN NUMBER,
                     p_instance_id        IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id            IN NUMBER
                     ) return VARCHAR2;

FUNCTION construct_sup_where(p_organization_id number,
                             p_instance_id number,
                             p_item_id number,
                             p_sup_id number,
                             p_sup_site_id number) RETURN varchar2;


--Procedure call_get_actuals;

Procedure refresh_data(errbuf OUT NOCOPY VARCHAR2,
                       retcode OUT NOCOPY NUMBER,
                       p_plan_id number,
                       p_plan_type number);

Procedure refresh_data(errbuf OUT NOCOPY VARCHAR2,
                       retcode OUT NOCOPY NUMBER,
                       p_plan_id number);

Function IsKPIAvail(p_plan_id number) return number;

PROCEDURE set_kpi_refresh_status(p_plan_id number,p_status varchar2);
Procedure refresh_kpi_data(p_plan_id number);

Procedure refresh_one_table(errbuf OUT NOCOPY VARCHAR2,
                       retcode OUT NOCOPY NUMBER,
                       p_plan_id number,
                       p_kpi_table number,
                       p_plan_type number);

Procedure ui_post_plan(errbuf OUT NOCOPY VARCHAR2,
                       retcode OUT NOCOPY NUMBER,
                       p_plan_id IN number);

FUNCTION get_tp_cost(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER,
                     p_start_date date default null,
                     p_end_date date default null,
                     p_planner_code varchar2 default null) RETURN NUMBER;

FUNCTION get_target_service_level(p_plan_id IN NUMBER,
                     p_instance_id IN NUMBER,
                     p_organization_id    IN NUMBER,
                     p_item_id IN NUMBER,
                     p_start_date date default null,
                     p_end_date date default null) RETURN NUMBER;
END msc_get_bis_values;

/
