--------------------------------------------------------
--  DDL for Package CSD_REPAIR_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_TYPES_PVT" AUTHID CURRENT_USER as
/* $Header: csdvrtds.pls 120.0 2005/06/30 21:10:00 vkjain noship $ */

/*--------------------------------------------------*/
/* procedure name: GET_START_FLOW_STATUS            */
/* description   : The procedure returns the start  */
/*                 flow status and status or        */
/*                 a given repair type.             */
/*                                                  */
/*--------------------------------------------------*/
PROCEDURE GET_START_FLOW_STATUS
(
   x_return_status             OUT  NOCOPY    VARCHAR2,
   x_msg_count                 OUT  NOCOPY    NUMBER,
   x_msg_data                  OUT  NOCOPY    VARCHAR2,
   p_repair_type_id 		 IN             NUMBER,
   x_start_flow_status_id 	 OUT  NOCOPY    NUMBER,
   x_start_flow_status_code    OUT  NOCOPY    VARCHAR2,
   x_start_flow_status_meaning OUT  NOCOPY    VARCHAR2,
   x_status_code 		       OUT  NOCOPY    VARCHAR2
);

End CSD_REPAIR_TYPES_PVT;

 

/
