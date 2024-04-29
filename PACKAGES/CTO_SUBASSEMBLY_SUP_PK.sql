--------------------------------------------------------
--  DDL for Package CTO_SUBASSEMBLY_SUP_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_SUBASSEMBLY_SUP_PK" AUTHID CURRENT_USER as
/* $Header: CTOSUBSS.pls 120.3 2006/09/21 07:41:43 kkonada ship $ */


/*
------------------------------------------------------------------------------------------
|      Copyright  (C) 1993 Oracle Corporation Belmont, California, USA                    |
|				All rights reserved.                                      |
|                               Oracle Manufacturing                                      |
|                                                                                         |
|	FILE NAME	:	CTOSUBSS.pls                                              |
|                                                                                         |
|	DESCRIPTION	:	New package created for MLSUPPLY fetaure                  |
|                                                                                         |
|                                                                                         |
|	HISTORY    	:       Created on 12-DEC-2002   KIRAN KOANDA                     |
|
|                               02-05-2004  Kiran Konada
|                                --bugfix 3418102
|
  -----------------------------------------------------------------------------------------
*/

-- rkaza. 05/02/2005. Added sourcing org field to the record.

TYPE r_mlsupply_items IS RECORD(

     order_line_id		 number, --sales order line id
     t_item_details_index        number,
     item_id			 bom_inventory_components.component_item_id%type,
     item_name			 mtl_system_items_kfv.concatenated_segments%type,
     item_quantity		 bom_inventory_components.component_quantity%type,
     needed_item_qty              bom_inventory_components.component_quantity%type,
     OPERATION_LEAD_TIME_PERCENT bom_inventory_components.OPERATION_LEAD_TIME_PERCENT%type,
     operation_seq_num		 bom_inventory_components.OPERATION_seq_num%type,
     cfm_routing_flag            bom_operational_routings.cfm_routing_flag%type,
     routing_sequence_id         bom_operational_routings.routing_sequence_id%type,
     fixed_lead_time             mtl_system_items_kfv.fixed_lead_time%type,
     variable_lead_time          mtl_system_items_kfv.variable_lead_time%type,
     processing_lead_time        mtl_system_items_kfv.full_lead_time%type,
     postprocessing_lead_time   mtl_system_items_kfv.postprocessing_lead_time%type,
     bom_item_type               bom_inventory_components.bom_item_type%type,
     auto_config_flag            mtl_system_items_kfv.auto_created_config_flag%type,
     parent_index                number,
     job_start_date               date,
     job_completion_date          date,
     populate_start_date         number,  -- value of 1 implies 1implies insert satrt date in wjsi instead of completion date, while finite scheduler is on
     line_id                     bom_operational_routings.line_id%type,
     line_code                   wip_lines.line_code%type,
     source_type               number, --buy =3 ,make =2 , transfer (sourced ) =1
     job_name			varchar2(240),
     feeder_run               varchar2(1),
     flow_start_index          number,
     flow_end_index            number,
     comment                   varchar2(240),

     pegging_flag              varchar2(1),
     sourcing_org                number,
     basis_type                number,     /* LBM Project */
     wip_supply_type           number,
     actual_parent_idx         number
     );

TYPE t_item_details IS TABLE OF r_mlsupply_items INDEX BY BINARY_INTEGER;


Procedure get_child_configurations
              (
	        pParentItemId     in number,
		pOrganization_id  in      number,
		pLower_Supplytype        in number,
		pParent_index       in number,
		pitems_table      in out nocopy t_item_details,
		x_return_status         out  NOCOPY varchar2,
		x_error_message         out  NOCOPY VARCHAR2,  /* 70 bytes to hold  msg */
		x_message_name          out  NOCOPY VARCHAR2 /* 30 bytes to hold  name */


              );


Procedure create_subassembly_jobs
          (

	       p_mlsupply_parameter     in number,
               p_Top_Assembly_LineId	in number,
	       pSupplyQty		in number,
               p_wip_seq               in   number,
               p_status_type           in  number,
               p_class_code            in  varchar2,
               p_conc_request_id       IN  NUMBER,
               p_conc_program_id       IN  NUMBER,
               p_conc_login_id         IN  NUMBER,
               p_user_id               IN  NUMBER,
               p_appl_conc_program_id  IN  NUMBER,
               x_return_status         out  NOCOPY varchar2,
	       x_error_message         out  NOCOPY VARCHAR2,  /* 70 bytes to hold  msg */
		x_message_name          out  NOCOPY VARCHAR2 /* 30 bytes to hold  name */
          );



end CTO_SUBASSEMBLY_SUP_PK;


 

/
