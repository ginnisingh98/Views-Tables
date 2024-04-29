--------------------------------------------------------
--  DDL for Package AHL_LTP_ASCP_ORDERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_ASCP_ORDERS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLSCMRS.pls 115.2 2004/01/29 00:05:41 ssurapan noship $*/
--
--
TYPE Sched_Orders_Rec IS RECORD
(Order_line_id            Number, -- Line id (Schedule Mat Id)
 Org_id			  Number, -- Org Id the line belongs to
 Header_id		  Number, -- Order Header (Visit Task Id)
 Schedule_ship_date 	  Date,   -- Ship date (Dmd_Satisfied_date)
 Schedule_arrival_date	  Date,   -- Arrival Date
 Earliest_ship_date       Date,   -- Earliest available date
 Quantity_By_Due_Date     Number);

TYPE Sched_Orders_Tbl IS TABLE OF Sched_Orders_Rec
INDEX BY BINARY_INTEGER;

-- Start of Comments --
--  Procedure name    : Update_Sheduling_Results
--  Type        : Public
--  Function    : This procedure Updates Scheduled Materials table with scheduled date
--                Quantity from APS
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--
--  Update_Scheduling_Results :
--
--
--
PROCEDURE Update_Scheduling_Results (
   p_api_version             IN    NUMBER    := 1.0,
   p_init_msg_list           IN    VARCHAR2  := FND_API.g_false,
   p_commit                  IN    VARCHAR2  := FND_API.g_false,
   p_validation_level        IN    NUMBER    := FND_API.g_valid_level_full,
   p_sched_Orders_Tbl        IN    Sched_Orders_Tbl,
   x_return_status               OUT NOCOPY VARCHAR2);


END AHL_LTP_ASCP_ORDERS_PVT;

 

/
