--------------------------------------------------------
--  DDL for Package MRP_DEFAULT_FLOW_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_DEFAULT_FLOW_SCHEDULE" AUTHID CURRENT_USER AS
/* $Header: MRPDSCNS.pls 115.5 2002/11/29 17:48:44 sjagan ship $ */

--  Procedure Attributes
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/

PROCEDURE Attributes
(   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_iteration                     IN  NUMBER DEFAULT NULL
,   x_flow_schedule_rec             IN  OUT NOCOPY MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
);

END MRP_Default_Flow_Schedule;

 

/
