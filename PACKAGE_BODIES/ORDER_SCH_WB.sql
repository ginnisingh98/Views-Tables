--------------------------------------------------------
--  DDL for Package Body ORDER_SCH_WB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ORDER_SCH_WB" AS
/* $Header: MRPOSCWB.pls 115.56 2003/08/29 00:30:13 mahamed ship $ */


PROCEDURE GET_ATP_RESULT (
	x_session_id		IN	NUMBER,
	commit_flag		IN	NUMBER,
	call_oe			IN	NUMBER,
	x_msg_count		OUT	NoCopy NUMBER,
	x_msg_data		OUT	NoCopy VARCHAR2,
	x_return_status		OUT	NoCopy VARCHAR2
			  )
IS
BEGIN
	MSC_SCH_WB.GET_ATP_RESULT (
		x_session_id,
		commit_flag,
		call_oe,
		x_msg_count,
		x_msg_data,
		x_return_status,
                NULL);


EXCEPTION
   WHEN OTHERS THEN
      IF order_sch_wb.mr_debug in ('Y', 'C') THEN
         atp_debug(' Exception in get_atp_results '||Substr(Sqlerrm,1,100));
      END IF;
      x_return_status := 'E';
      x_msg_data := Substr(Sqlerrm,1,100);
END get_atp_result;

PROCEDURE delete_lines
  ( p_session_id NUMBER,
    p_where_clause varchar2) IS
BEGIN
	MSC_SCH_WB.delete_lines(p_session_id, p_where_clause);

END delete_lines;

PROCEDURE get_supply_sources_local(
				   x_dblink             IN      VARCHAR2,
				   x_session_id         IN      NUMBER,
				   x_sr_instance_id     IN      NUMBER,
				   x_assignment_set_id  IN      NUMBER,
				   x_plan_id            IN      NUMBER,
				   x_calling_inst       IN      VARCHAR2,
				   x_ret_status         OUT     NoCopy VARCHAR2,
				   x_error_mesg         OUT     NoCopy VARCHAR2)
  IS
BEGIN
	MSC_SCH_WB.get_supply_sources_local(
		x_dblink,
		x_session_id,
		x_sr_instance_id,
		x_assignment_set_id,
		x_plan_id,
		x_calling_inst,
		x_ret_status,
		x_error_mesg);
END get_supply_sources_local;


PROCEDURE get_atp_rule_name (
			     dblink         VARCHAR2,
			     item_id        NUMBER,
			     org_id         NUMBER,
			     sr_instance_id NUMBER,
			     atp_rule_name  OUT NoCopy VARCHAR2,
			     inst           VARCHAR2)
  IS
BEGIN
	MSC_SCH_WB.get_atp_rule_name (
		dblink,
		item_id,
		org_id,
		sr_instance_id,
		atp_rule_name,
		inst);
END get_atp_rule_name;


PROCEDURE get_assignment_set (
			      x_dblink                   VARCHAR2,
			      x_assignment_set_id    OUT NoCopy NUMBER,
			      -- This we return what is on the server (MSC)
			      x_assignment_set_name  OUT NoCopy VARCHAR2,
			      x_plan_id              OUT NoCopy NUMBER,
			      x_plan_name            OUT NoCopy VARCHAR2,
			      x_sr_instance_id           NUMBER,
			      x_inst                     VARCHAR2,
			      x_ret_code             OUT NoCopy VARCHAR2,
			      x_err_mesg             OUT NoCopy VARCHAR2)
  IS
BEGIN
	MSC_SCH_WB.get_assignment_set (
		x_dblink,
		x_assignment_set_id,
		x_assignment_set_name,
		x_plan_id,
		x_plan_name,
		x_sr_instance_id,
		x_inst,
		x_ret_code,
		x_err_mesg);
EXCEPTION
   WHEN no_data_found THEN
      x_ret_code := 'E';
      x_err_mesg :=  substr(sqlerrm,1,100);
END get_assignment_set;

PROCEDURE atp_debug(buf IN VARCHAR2) IS
BEGIN
	MSC_SCH_WB.atp_debug(buf);
END atp_debug;

PROCEDURE MRP_TIMING(buf IN VARCHAR2)
IS
BEGIN
	MSC_SCH_WB.mrp_timing(buf);
EXCEPTION
   WHEN OTHERS THEN
      --dbms_output.put_line('Exception in mrp_timing '||Sqlerrm);
      return;
END MRP_TIMING;


PROCEDURE get_period_atp_strings(
 				 p_is_allocated		BOOLEAN,
				 p_session_id		NUMBER,
 				 p_old_session_id	number,
				 p_dmd_flag		number,
				 p_end_pegging_id	number,
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
				 ) is
BEGIN
	MSC_SCH_WB.get_period_atp_strings(
 		p_is_allocated,
		p_session_id,
 		p_old_session_id,
		p_dmd_flag,
		p_end_pegging_id,
		p_pegging_id,
		p_organization_id,
		p_sr_instance_id,
		p_inst,
		p_supply_str,
		p_demand_str,
		p_bkd_demand_str,
		p_net_atp_str,
		p_cum_atp_str,
		p_row_hdr_str,
		p_date_str,
		p_week_str,
		p_period_str);
EXCEPTION
   WHEN OTHERS THEN
      IF order_sch_wb.mr_debug in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('get_period_atp_strings: ' || ' excp in get_period_strings '||substr(Sqlerrm, 1, 100));
      END IF;
END get_period_atp_strings;

PROCEDURE calc_exceptions(
			  p_session_id         IN    NUMBER,
			  x_return_status      OUT   NoCopy VARCHAR2,
			  x_msg_data           OUT   NoCopy VARCHAR2,
			  x_msg_count          OUT   NoCopy NUMBER
			  )
  IS
     PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	MSC_SCH_WB.calc_exceptions(
		p_session_id,
		x_return_status,
		x_msg_data,
		x_msg_count);
EXCEPTION
   WHEN OTHERS THEN
      IF order_sch_wb.mr_debug in ('Y', 'C') THEN
         atp_debug('calc_exceptions: ' || ' exception in calc_excep  - '||substr(sqlerrm,1,100));
      END IF;
      x_return_status := 'E';
END calc_exceptions;

FUNCTION get_supply_demand_source_name (
   organization_id           IN NUMBER,
   supply_demand_source_type IN NUMBER,
   supply_demand_source_id   IN NUMBER
   ) RETURN VARCHAR2 IS
BEGIN
   RETURN MSC_SCH_WB.get_supply_demand_source_name (
		organization_id,
		supply_demand_source_type,
		supply_demand_source_id);

END get_supply_demand_source_name;

PROCEDURE pipe_utility(
		       p_session_id         IN       NUMBER,
		       p_command            IN       VARCHAR2,
		       p_message            IN OUT   NoCopy VARCHAR2,
		       p_message_count      OUT      NoCopy NUMBER,   -- Right now just 0 or 1
		       x_return_status      OUT      NoCopy VARCHAR2,
		       x_msg_data           OUT      NoCopy VARCHAR2,
		       x_msg_count          OUT      NoCopy NUMBER
		       )
  IS
     ret        NUMBER;
     empty_pipe EXCEPTION;
     PRAGMA     EXCEPTION_INIT (EMPTY_PIPE, -6556);
BEGIN
	MSC_SCH_WB.pipe_utility(
		  p_session_id,
		  p_command,
		  p_message,
		  p_message_count,
		  x_return_status,
		  x_msg_data,
		  x_msg_count);
EXCEPTION
   WHEN EMPTY_PIPE THEN
      NULL;
   WHEN OTHERS THEN
      IF order_sch_wb.mr_debug in ('Y', 'C') THEN
         atp_debug(' Exception in pipe_utility '||p_command||Substr(Sqlerrm,1,100));
      END IF;
      x_return_status := 'E';
      x_msg_data := Substr(Sqlerrm,1,100);
END pipe_utility;

PROCEDURE set_session_id(p_session_id   IN NUMBER)
  IS
BEGIN
	MSC_SCH_WB.set_session_id(p_session_id);
END set_session_id;

PROCEDURE  extend_other_cols(x_other_cols IN OUT NoCopy other_cols_typ, amount NUMBER)
  IS
BEGIN
	MSC_SCH_WB.extend_other_cols(x_other_cols, amount);
END extend_other_cols;

PROCEDURE commit_db IS
BEGIN
   COMMIT;
END commit_db;

PROCEDURE get_master_org(p_master_org_id OUT NoCopy NUMBER)
  IS
BEGIN
	MSC_SCH_WB.get_master_org(p_master_org_id);
END get_master_org;

PROCEDURE get_profile(profile_name VARCHAR2, profile_value OUT NoCopy NUMBER)
  IS
BEGIN
	MSC_SCH_WB.get_profile(profile_name, profile_value);
END get_profile;

END ORDER_SCH_WB;

/
