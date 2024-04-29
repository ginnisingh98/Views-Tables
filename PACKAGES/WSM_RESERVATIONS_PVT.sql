--------------------------------------------------------
--  DDL for Package WSM_RESERVATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_RESERVATIONS_PVT" AUTHID CURRENT_USER as
/* $Header: WSMVRSVS.pls 120.0 2005/06/29 22:00:15 mprathap noship $ */

Procedure modify_reservations_wlt (	p_txn_header 		IN 	   WSM_WIP_LOT_TXN_PVT.WLTX_TRANSACTIONS_REC_TYPE,
					p_starting_jobs_tbl 	IN 	   WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
					p_resulting_jobs_tbl 	IN 	   WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
					p_rep_job_index 	IN	   NUMBER,
					p_sj_also_rj_index   	IN 	   NUMBER,
					x_return_status 	OUT NOCOPY VARCHAR2,
					x_msg_count 		OUT NOCOPY NUMBER,
					x_msg_data 		OUT NOCOPY VARCHAR2) ;

Procedure modify_reservations_move (	p_wip_entity_id 	IN 	   NUMBER,
					P_inventory_item_id  	IN 	   NUMBER,
					P_org_id 		IN         NUMBER,
					P_txn_type 		IN 	   NUMBER,
					P_net_qty 		IN 	   NUMBER,
					x_return_status 	OUT NOCOPY VARCHAR2,
					x_msg_count 		OUT NOCOPY NUMBER,
					x_msg_data 		OUT NOCOPY VARCHAR2);

Procedure modify_reservations_jobupdate (p_wip_entity_id 	IN         NUMBER,
					P_old_net_qty 		IN 	   NUMBER ,
					P_new_net_qty 		IN 	   NUMBER,
					P_inventory_item_id 	IN 	   NUMBER,
					P_org_id 		IN 	   NUMBER,
					P_status_type 		IN         NUMBER,
					x_return_status 	OUT NOCOPY VARCHAR2,
					x_msg_count 		OUT NOCOPY NUMBER,
					x_msg_data 		OUT NOCOPY VARCHAR2);

Function check_reservation_quantity (p_wip_entity_id 		IN NUMBER,
					P_org_id 		IN NUMBER,
					P_inventory_item_id 	IN NUMBER
					)
Return NUMBER ;

Function check_reservation_exists (p_wip_entity_id 		IN NUMBER,
					P_org_id 		IN NUMBER,
					P_inventory_item_id 	IN NUMBER
				  )
Return BOOLEAN ;
end WSM_RESERVATIONS_PVT;

 

/
