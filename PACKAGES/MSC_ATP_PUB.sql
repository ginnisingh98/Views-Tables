--------------------------------------------------------
--  DDL for Package MSC_ATP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_PUB" AUTHID CURRENT_USER AS
/* $Header: MSCEATPS.pls 120.1 2007/12/12 10:26:05 sbnaik ship $  */

/* Exception for invalid objects */
/* Error Handlng Modifications */
ATP_INVALID_OBJECTS_FOUND       Exception;
PRAGMA  EXCEPTION_INIT(ATP_INVALID_OBJECTS_FOUND, -6508);
G_ATP_CHECK        VARCHAR2(1) := 'N';


PROCEDURE Call_ATP (
	p_session_id	     IN OUT 	NoCopy NUMBER,
	p_atp_rec            IN    	MRP_ATP_PUB.ATP_Rec_Typ,
	x_atp_rec            OUT NOCOPY	MRP_ATP_PUB.ATP_Rec_Typ,
	x_atp_supply_demand  OUT NOCOPY	MRP_ATP_PUB.ATP_Supply_Demand_Typ,
	x_atp_period         OUT NOCOPY	MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_details        OUT NOCOPY	MRP_ATP_PUB.ATP_Details_Typ,
	x_return_status      OUT   	NoCopy VARCHAR2,
	x_msg_data           OUT   	NoCopy VARCHAR2,
	x_msg_count          OUT   	NoCopy NUMBER
);

PROCEDURE Call_ATP_No_Commit (
               p_session_id         IN OUT      NoCopy NUMBER,
               p_atp_rec            IN          MRP_ATP_PUB.ATP_Rec_Typ,
               x_atp_rec            OUT NOCOPY  MRP_ATP_PUB.ATP_Rec_Typ,
               x_atp_supply_demand  OUT NOCOPY  MRP_ATP_PUB.ATP_Supply_Demand_Typ,
               x_atp_period         OUT NOCOPY  MRP_ATP_PUB.ATP_Period_Typ,
               x_atp_details        OUT NOCOPY  MRP_ATP_PUB.ATP_Details_Typ,
               x_return_status      OUT         NoCopy VARCHAR2,
               x_msg_data           OUT         NoCopy VARCHAR2,
               x_msg_count          OUT         NoCopy NUMBER
);

-- Commented out as part of NGOEL Fixes by krajan
-- Procedure Subst_Workflow(p_atp_rec  IN MRP_ATP_PUB.ATP_Rec_Typ);
PROCEDURE UPDATE_TABLES (
                p_summary_flag IN  VARCHAR2,
                p_end_refresh_number IN NUMBER ,
                p_refresh_number IN NUMBER ,
                p_session_id IN NUMBER
                         );


END MSC_ATP_PUB;

/
