--------------------------------------------------------
--  DDL for Package MRP_BAL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_BAL_UTILS" AUTHID CURRENT_USER AS
/* $Header: MRPUBALS.pls 120.0 2005/05/25 03:37:59 appldev noship $  */

TYPE number_arr IS TABLE OF number;
TYPE char18_arr IS TABLE of varchar2(18);
TYPE char80_arr IS TABLE of varchar2(80);

TYPE mrp_oe_rec IS RECORD (line_id             number_arr:=number_arr(),
			   ship_set_id         number_arr:=number_arr(),
			   arrival_set_id      number_arr:=number_arr(),
			   seq_num             number_arr:=number_arr(),
                           ato_line_id         number_arr:=number_arr(),
                           top_model_line_id   number_arr:=number_arr(),
                           item_type_code      char80_arr:=char80_arr(),
                           order_number        number_arr:=number_arr());

TYPE seq_alter IS RECORD(order_line_id       number_arr:=number_arr(),
			 ship_set_id         number_arr:=number_arr(),
			 arrival_set_id      number_arr:=number_arr(),
			 seq_diff            number_arr:=number_arr(),
                         seq_num             number_arr:=number_arr(),
                         orig_seq_num        number_arr:=number_arr());


PROCEDURE populate_temp_table (p_session_id   NUMBER,
			       p_order_by     VARCHAR2,
			       p_where        VARCHAR2,
			       p_overwrite    NUMBER,
			       p_org_id       NUMBER);

PROCEDURE undemand_orders (p_session_id       NUMBER);

PROCEDURE schedule_orders (p_session_id             NUMBER,
			   x_msg_count       OUT    NoCopy NUMBER,
			   x_msg_data        OUT    NoCopy VARCHAR2,
			   x_return_status   OUT    NoCopy VARCHAR2);

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
		     p_seq_alter       IN OUT   NoCopy seq_alter,
		     x_msg_count       OUT      NoCopy NUMBER,
		     x_msg_data        OUT      NoCopy VARCHAR2,
		     x_return_status   OUT      NoCopy VARCHAR2);

PROCEDURE extend( p_nodes IN OUT NoCopy seq_alter , extend_amount NUMBER );


END MRP_BAL_UTILS;

 

/
