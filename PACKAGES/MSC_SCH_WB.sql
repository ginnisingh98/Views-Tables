--------------------------------------------------------
--  DDL for Package MSC_SCH_WB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_SCH_WB" AUTHID CURRENT_USER AS
/* $Header: MSCOSCWS.pls 120.2.12010000.1 2008/11/18 00:34:59 cmsops ship $ */

-- krajan : 2400676:
-- Variable used for propagating error code to UI from View Alloc WB
G_ATP_ERROR_CODE        NUMBER := 0;

PROCEDURE get_Supply_Sources_local(
				   x_dblink             IN      VARCHAR2,
				   x_session_id         IN      NUMBER,
				   x_sr_instance_id     IN      NUMBER,
				   x_assignment_set_id  IN      NUMBER,
				   x_plan_id            IN      NUMBER,
				   x_calling_inst       IN      VARCHAR2,
				   x_ret_status         OUT     NoCopy VARCHAR2,
				   x_error_mesg         OUT     NoCopy VARCHAR2
				   );

PROCEDURE GET_ATP_RESULT (
			  x_session_id       IN     NUMBER,
			  commit_flag        IN     NUMBER,
			  call_oe            IN     NUMBER,
			  x_msg_count        OUT    NoCopy number,
			  x_msg_data         OUT    NoCopy varchar2,
			  x_return_status    OUT    NoCopy varchar2,
			  p_diagnostic_atp     IN   NUMBER DEFAULT 2
                           );

PROCEDURE cleanup_data (p_session_id in number);

FUNCTION get_alloc_rule_variables return NUMBER;

FUNCTION get_label(p_demand_class varchar2) return varchar2;

PROCEDURE get_atp_rule_name (
			     dblink         VARCHAR2,
			     item_id        NUMBER,
			     org_id         NUMBER,
			     sr_instance_id NUMBER,
			     atp_rule_name  OUT NoCopy VARCHAR2,
			     inst           VARCHAR2);

PROCEDURE get_msc_assign_set(x_dblink                   VARCHAR2,
                             x_assignment_set_id   IN  OUT NoCopy NUMBER,
                             x_sr_instance_id           NUMBER,
                             x_ret_code             OUT NoCopy VARCHAR2,
                             x_err_mesg             OUT NoCopy VARCHAR2);

PROCEDURE get_assignment_set (
			      x_dblink                   VARCHAR2,
			      x_assignment_set_id    OUT NoCopy NUMBER,
			      x_assignment_set_name  OUT NoCopy VARCHAR2,
			      x_plan_id              OUT NoCopy NUMBER,
			      x_plan_name            OUT NoCopy VARCHAR2,
			      x_sr_instance_id           NUMBER,
			      x_inst                     VARCHAR2,
			      x_ret_code             OUT NoCopy VARCHAR2,
			      x_err_mesg             OUT NoCopy VARCHAR2);

PROCEDURE MRP_TIMING(buf IN VARCHAR2);
PROCEDURE atp_debug(buf IN VARCHAR2);

PROCEDURE get_period_atp_strings(
                                 p_is_allocated		BOOLEAN,
                                 p_session_id		NUMBER,
                                 p_old_session_id	number,
                                 p_dmd_flag		number,
				 p_end_pegging_id	   number,
				 p_pegging_id           NUMBER,
				 p_organization_id      NUMBER,
				 p_sr_instance_id       NUMBER,
				 p_inst                 VARCHAR2,
				 p_supply_str    OUT    NoCopy VARCHAR2,
				 p_demand_str    OUT    NoCopy VARCHAR2,
				 p_bkd_demand_str    OUT    NoCopy VARCHAR2,
				 p_net_atp_str   OUT    NoCopy VARCHAR2,
				 p_cum_atp_str   OUT    NoCopy VARCHAR2,
				 p_row_hdr_str   OUT    NoCopy VARCHAR2,
				 p_date_str      OUT    NoCopy VARCHAR2,
				 p_week_str      OUT    NoCopy VARCHAR2,
				 p_period_str    OUT    NoCopy VARCHAR2
				 );


PROCEDURE calc_exceptions(
			  p_session_id         IN    NUMBER,
			  x_return_status      OUT   NoCopy VARCHAR2,
			  x_msg_data           OUT   NoCopy VARCHAR2,
			  x_msg_count          OUT   NoCopy NUMBER
			  );

PROCEDURE pipe_utility(
		       p_session_id         IN       NUMBER,
		       p_command            IN       VARCHAR2,
		       p_message            IN OUT   NoCopy VARCHAR2,
		       p_message_count      OUT      NoCopy NUMBER,
		       x_return_status      OUT      NoCopy VARCHAR2,
		       x_msg_data           OUT      NoCopy VARCHAR2,
		       x_msg_count          OUT      NoCopy NUMBER
		       );

PROCEDURE set_session_id(p_session_id   IN NUMBER);
PROCEDURE get_master_org(p_master_org_id OUT NoCopy NUMBER);

PROCEDURE delete_lines
  ( p_session_id NUMBER, p_where_clause varchar2);

FUNCTION get_supply_demand_source_name
     (
      organization_id           IN NUMBER,
      supply_demand_source_type IN NUMBER,
      supply_demand_source_id   IN NUMBER
      ) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (get_supply_demand_source_name, WNDS);

PROCEDURE  extend_other_cols(x_other_cols IN OUT NoCopy order_sch_wb.other_cols_typ,
			     amount NUMBER);

PROCEDURE commit_db;
PROCEDURE get_profile(profile_name VARCHAR2, profile_value OUT NoCopy NUMBER);

PROCEDURE get_session_id(p_db_link in varchar2 default NULL,p_session_id out NoCopy varchar2 ) ;

-- 2400676: krajan
-- Returns the global aTp error code to UI for view_allocation fix.
PROCEDURE get_g_atp_error_code(x_atp_err_code OUT NoCopy NUMBER);
PROCEDURE update_constraint_path(p_session_id       IN            NUMBER,
                                 p_return_error     IN OUT NoCopy VARCHAR2);


PROCEDURE get_ato_comp_details(p_session_id        IN       NUMBER,
                               p_child_ato_id      IN       NUMBER,
                               p_organization_id   IN       NUMBER,
                               x_days_late         IN OUT   NoCopy NUMBER,
                               x_error_code        IN OUT   NoCopy VARCHAR2);

END msc_sch_wb;

/
