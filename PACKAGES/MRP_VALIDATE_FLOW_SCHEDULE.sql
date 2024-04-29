--------------------------------------------------------
--  DDL for Package MRP_VALIDATE_FLOW_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_VALIDATE_FLOW_SCHEDULE" AUTHID CURRENT_USER AS
/* $Header: MRPLSCNS.pls 115.5 2002/11/29 17:47:29 sjagan ship $ */

--  Procedure Entity
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_old_flow_schedule_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
);

--  Procedure Attributes
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
,   p_old_flow_schedule_rec         IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
);

--  Procedure Entity_Delete
/*
Enhancement : 2665434
Description : Changed the usage of the record type from old record type
(MRP_FLow_Schedule_PUB.Flow_Schedule_Rec_Type) to new record type
(MRP_FLow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type)
*/

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY VARCHAR2
,   p_flow_schedule_rec             IN  MRP_Flow_Schedule_PVT.Flow_Schedule_PVT_Rec_Type
);

END MRP_Validate_Flow_Schedule;

 

/
