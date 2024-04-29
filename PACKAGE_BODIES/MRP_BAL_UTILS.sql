--------------------------------------------------------
--  DDL for Package Body MRP_BAL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_BAL_UTILS" AS
/* $Header: MRPUBALB.pls 115.19 2003/03/24 23:41:28 cnazarma ship $  */


/*
PROCEDURE extend( p_nodes IN OUT NoCopy mrp_oe_rec , extend_amount NUMBER );
PROCEDURE trim( p_nodes IN OUT NoCopy mrp_oe_rec , trim_amount NUMBER );
*/

PROCEDURE populate_temp_table (p_session_id NUMBER,
			       p_order_by   VARCHAR2,
			       p_where      VARCHAR2,
			       p_overwrite  NUMBER,
			       p_org_id     NUMBER) IS
BEGIN
	MSC_BAL_UTILS.populate_temp_table(
		p_session_id,
                p_order_by,
                p_where,
                p_overwrite,
                p_org_id);
END populate_temp_table;

PROCEDURE undemand_orders (p_session_id NUMBER) IS
x_msg_count     NUMBER;
x_msg_data      VARCHAR2(100);
x_return_status VARCHAR2(1);

BEGIN
	MSC_BAL_UTILS.undemand_orders (p_session_id,
                           x_msg_count,
                           x_msg_data ,
                           x_return_status);

END undemand_orders;

PROCEDURE schedule_orders (p_session_id NUMBER,
			   x_msg_count       OUT    NoCopy NUMBER,
			   x_msg_data        OUT    NoCopy varchar2,
			   x_return_status   OUT    NoCopy varchar2
			   ) IS
BEGIN
	MSC_BAL_UTILS. schedule_orders(
		p_session_id,
                x_msg_count,
                x_msg_data,
                x_return_status);
END schedule_orders;


PROCEDURE execute_command (p_command VARCHAR2,
			   p_user_command NUMBER,
			   x_msg_data        OUT    NoCopy varchar2,
			   x_return_status   OUT    NoCopy varchar2 )
  IS
BEGIN
	MSC_BAL_UTILS.execute_command(
		p_command,
                p_user_command,
                x_msg_data,
                x_return_status);
END execute_command;


PROCEDURE extend( p_nodes IN OUT NoCopy seq_alter , extend_amount NUMBER ) IS
BEGIN
	MSC_BAL_UTILS.extend(p_nodes, extend_amount);
END extend;

/*
PROCEDURE extend( p_nodes IN OUT NoCopy mrp_oe_rec, extend_amount NUMBER ) IS
BEGIN
	MSC_BAL_UTILS.extend(p_nodes, extend_amount);
END extend;

PROCEDURE trim( p_nodes IN OUT NoCopy mrp_oe_rec, trim_amount NUMBER ) IS
BEGIN
	MSC_BAL_UTILS.trim(p_nodes, trim_amount);
END trim;
*/

PROCEDURE call_oe_api (p_session_id NUMBER,
		       x_msg_count       OUT    NoCopy NUMBER,
		       x_msg_data        OUT    NoCopy varchar2,
		       x_return_status   OUT    NoCopy varchar2
		       )
  IS
BEGIN
	MSC_BAL_UTILS.call_oe_api(
		p_session_id,
                x_msg_count,
                x_msg_data,
                x_return_status);
END call_oe_api;


PROCEDURE call_oe_api (p_atp_rec                MRP_ATP_PUB.atp_rec_typ,
		       x_msg_count       OUT    NoCopy NUMBER,
		       x_msg_data        OUT    NoCopy VARCHAR2,
		       x_return_status   OUT    NoCopy VARCHAR2)
  IS
BEGIN
	MSC_BAL_UTILS.call_oe_api(
		p_atp_rec,
                x_msg_count,
                x_msg_data,
                x_return_status);
END call_oe_api;

PROCEDURE update_seq(p_session_id               NUMBER,
		     p_seq_alter       IN OUT   NoCopy seq_alter,
		     x_msg_count       OUT      NoCopy NUMBER,
		     x_msg_data        OUT      NoCopy VARCHAR2,
		     x_return_status   OUT      NoCopy VARCHAR2)
  IS
BEGIN
	MSC_BAL_UTILS.update_seq(
		p_session_id,
                p_seq_alter,
                x_msg_count,
                x_msg_data,
                x_return_status);
END update_seq;

END MRP_BAL_UTILS;

/
