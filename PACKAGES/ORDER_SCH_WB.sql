--------------------------------------------------------
--  DDL for Package ORDER_SCH_WB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ORDER_SCH_WB" AUTHID CURRENT_USER AS
/* $Header: MRPOSCWS.pls 115.36 2003/08/29 00:29:47 mahamed ship $ */

mr_debug             VARCHAR2(1) := NVL(fnd_profile.value('MSC_ATP_DEBUG'),'N');
file_or_terminal     NUMBER := 1;  -- 2 = dbms_output
debug_session_id     NUMBER := 0;
sys_yes    CONSTANT          NUMBER := 1;
sys_no     CONSTANT          NUMBER := 2;
delim      CONSTANT          VARCHAR2(1) := fnd_global.local_chr(13);
file_dir                     varchar2(512);  -- bug 2124950

apps   CONSTANT VARCHAR2(10) := 'APPS';
server CONSTANT VARCHAR2(10) := 'SERVER';
mrd_canonical_date CONSTANT VARCHAR2(10) := 'MM/DD/YYYY';
mrn_canonical_num  CONSTANT VARCHAR2(50) :=  'FM999999999999999999999.99999999999999999999';

BACKLOG_MODE CONSTANT NUMBER := 1;
OE_MODE  CONSTANT NUMBER := 2;
INV_MODE CONSTANT NUMBER := 3;

TYPE char7_arr IS TABLE of varchar2(7);
TYPE char18_arr IS TABLE of varchar2(18);
TYPE char80_arr IS TABLE of varchar2(80);
TYPE number_arr IS TABLE OF number;
TYPE date_arr   IS TABLE OF date;

-- This will be set by the form before the SD_DETAIL
-- is queried, and will be updated if it changes
parameter_chart_of_accounts_id NUMBER;
form_field_c_column1           VARCHAR2(30);

TYPE other_cols_typ IS RECORD (
			       row_index            number_arr:= number_arr(),
			       org_code             char7_arr:= char7_arr(),
			       ship_method_text     char80_arr:= char80_arr(),
			       vendor_name          char80_arr:= char80_arr(),
			       sr_supplier_id       number_arr:= number_arr(),
			       vendor_site_name     char80_arr:= char80_arr(),
			       sr_supplier_site_id  number_arr:= number_arr());

TYPE mast_typ IS RECORD (
			 rowid_char          char18_arr:= char18_arr(),
			 sr_instance_id      number_arr:= number_arr(),
			 inventory_item_id   number_arr:= number_arr(),
			 organization_id     number_arr:= number_arr(),
			 customer_id         number_arr:= number_arr(),
			 customer_site_id    number_arr:= number_arr()
			 );

TYPE ATP_Period_String_typ is Record (
				      Total_Supply_Quantity
                                        number_arr:= number_arr(),
				      Total_Demand_Quantity
                                        number_arr:= number_arr(),
				      Period_Start_Date
                                        date_arr:= date_arr(),
				      Period_End_Date
                                        date_arr:= date_arr(),
				      Period_Quantity
                                        number_arr:= number_arr(),
				      Cumulative_Quantity
                                        number_arr:= number_arr(),
				      Bucketed_Quantity
                                        number_arr:= number_arr()
				      );

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
			  x_return_status    OUT    NoCopy varchar2
                           );


PROCEDURE get_atp_rule_name (
			     dblink         VARCHAR2,
			     item_id        NUMBER,
			     org_id         NUMBER,
			     sr_instance_id NUMBER,
			     atp_rule_name  OUT NoCopy VARCHAR2,
			     inst           VARCHAR2);

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

TYPE excp_rec_typ IS RECORD (
			     exception1     number_arr:=number_arr(),
			     exception2     number_arr:=number_arr(),
			     exception3     number_arr:=number_arr(),
			     exception4     number_arr:=number_arr(),
			     exception5     number_arr:=number_arr(),
			     exception6     number_arr:=number_arr(),
			     exception7     number_arr:=number_arr(),
			     exception8     number_arr:=number_arr(),
			     exception9     number_arr:=number_arr(),
			     exception10    number_arr:=number_arr(),
			     exception11    number_arr:=number_arr(),
			     exception12    number_arr:=number_arr(),
			     exception13    number_arr:=number_arr(),
			     exception14    number_arr:=number_arr(),
			     exception15    number_arr:=number_arr()
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

PROCEDURE  extend_other_cols(x_other_cols IN OUT NoCopy other_cols_typ,
			     amount NUMBER);

PROCEDURE commit_db;
PROCEDURE get_profile(profile_name VARCHAR2, profile_value OUT NoCopy NUMBER);

END order_sch_wb;

 

/
