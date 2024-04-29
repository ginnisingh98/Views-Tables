--------------------------------------------------------
--  DDL for Package MSC_BAL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_BAL_UTILS" AUTHID CURRENT_USER AS
/* $Header: MSCUBALS.pls 120.1 2006/03/28 14:10:55 cnazarma noship $  */

/*
TYPE number_arr IS TABLE OF number;
TYPE char18_arr IS TABLE of varchar2(18);

TYPE mrp_oe_rec IS RECORD (line_id             number_arr,
			   ship_set_id         number_arr,
			   arrival_set_id      number_arr,
			   seq_num             number_arr);

TYPE seq_alter IS RECORD(order_line_id       number_arr,
			 ship_set_id         number_arr,
			 arrival_set_id      number_arr,
			 seq_diff            number_arr);
*/


--bwb
TYPE number_arr IS TABLE OF number;

g_om_status varchar2(20);
g_om_req_id NUMBER;

TYPE ATP_QTY_ORDERED_TYP is RECORD (
quantity_ordered  number_arr := number_arr(),
order_line_id     number_arr := number_arr(),
session_id        number_arr := number_arr()
  );

PROCEDURE populate_temp_table (p_session_id   NUMBER,
			       p_order_by     VARCHAR2,
			       p_where        VARCHAR2,
			       p_overwrite    NUMBER,
			       p_org_id       NUMBER,
                               p_exclude_picked NUMBER DEFAULT 0);

PROCEDURE cmt_schedule(   p_user_id         IN            NUMBER,
                          p_resp_id         IN            NUMBER,
                          p_appl_id         IN            NUMBER,
                          p_session_id      IN            NUMBER,
                          x_msg_count       OUT    NoCopy NUMBER,
                          x_msg_data        OUT    NoCopy varchar2,
                          x_return_status   OUT    NoCopy varchar2,
                          p_tcf BOOLEAN default TRUE);


PROCEDURE undemand_orders (p_session_id                    NUMBER,
                           x_msg_count      IN  OUT    NoCopy NUMBER ,
                           x_msg_data       IN  OUT    NoCopy VARCHAR2 ,
                           x_return_status  IN  OUT    NoCopy VARCHAR2);

PROCEDURE  update_schedule_qties(p_atp_qty_ordered_temp IN MSC_BAL_UTILS.ATP_QTY_ORDERED_TYP,
                        p_return_status out nocopy VARCHAR2,
                        p_error_message out nocopy VARCHAR2 );

PROCEDURE reschedule(p_session_id NUMBER,
                           x_msg_count       OUT    NoCopy NUMBER,
                           x_msg_data        OUT    NoCopy varchar2,
                           x_return_status   OUT    NoCopy varchar2,
                           p_tcf BOOLEAN default TRUE) ;

PROCEDURE schedule_orders (p_session_id             NUMBER,
			   x_msg_count       OUT    NoCopy NUMBER,
			   x_msg_data        OUT    NoCopy VARCHAR2,
			   x_return_status   OUT    NoCopy VARCHAR2,
                           p_tcf BOOLEAN default TRUE);

PROCEDURE call_oe_api (p_session_id             NUMBER,
		       x_msg_count       OUT    NoCopy NUMBER,
		       x_msg_data        OUT    NoCopy VARCHAR2,
		       x_return_status   OUT    NoCopy VARCHAR2);

PROCEDURE call_oe_api (p_atp_rec                MRP_ATP_PUB.atp_rec_typ,
		       x_msg_count       OUT    NoCopy NUMBER,
		       x_msg_data        OUT    NoCopy VARCHAR2,
		       x_return_status   OUT    NoCopy VARCHAR2);

PROCEDURE execute_command (p_command                VARCHAR2,
			   p_user_command           NUMBER,
			   x_msg_data        OUT    NoCopy VARCHAR2,
			   x_return_status   OUT    NoCopy VARCHAR2);

PROCEDURE update_seq(p_session_id               NUMBER,
		     p_seq_alter       IN OUT   NoCopy MRP_BAL_UTILS.seq_alter,
		     x_msg_count       OUT      NoCopy NUMBER,
		     x_msg_data        OUT      NoCopy VARCHAR2,
		     x_return_status   OUT      NoCopy VARCHAR2);

PROCEDURE extend( p_nodes IN OUT NoCopy MRP_BAL_UTILS.seq_alter , extend_amount NUMBER );



END MSC_BAL_UTILS;

 

/
