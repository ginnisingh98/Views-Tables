--------------------------------------------------------
--  DDL for Package XDP_DRC_UTIL_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_DRC_UTIL_CUHK" AUTHID CURRENT_USER AS
/* $Header: XDPDRCHS.pls 120.2 2005/07/07 02:16:22 appldev ship $ */

-- PL/SQL Specification
-- Datastructure Definitions


 -- API specifications

 /*
  This procedure is used for the customer to add
  customization PRIOR to the Process_DRC_Order API
  */

  Procedure Process_DRC_order_Pre( p_workitem_id 	IN OUT NOCOPY NUMBER,
			           p_task_parameter 	IN OUT NOCOPY XDP_TYPES.ORDER_PARAMETER_LIST,
			           p_sdp_order_id 	IN OUT NOCOPY NUMBER,
			           x_data		IN OUT NOCOPY VARCHAR2,
			           x_count		IN OUT NOCOPY NUMBER,
			           x_return_code	IN OUT NOCOPY VARCHAR2
			         );

 /*
  This procedure is used for the customer to add
  customization AFTER the Process_DRC_Order API
  */

   Procedure Process_DRC_order_Post( p_workitem_id 	IN OUT NOCOPY NUMBER,
			            p_task_parameter 	IN OUT NOCOPY XDP_TYPES.ORDER_PARAMETER_LIST,
			            p_sdp_order_id 	IN OUT NOCOPY NUMBER,
			            x_data		IN OUT NOCOPY VARCHAR2,
			            x_count		IN OUT NOCOPY NUMBER,
			            x_return_code	IN OUT NOCOPY VARCHAR2
			          );

 /*
  This function is called prior to generating message
 */

    Function Ok_to_Generate_msg(p_workitem_id      NUMBER,
                                p_task_parameter   XDP_TYPES.ORDER_PARAMETER_LIST,
		                p_sdp_order_id     NUMBER
		                )  return Boolean;

END XDP_DRC_UTIL_CUHK;

 

/
