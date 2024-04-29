--------------------------------------------------------
--  DDL for Package MSC_NATP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_NATP_PVT" AUTHID CURRENT_USER AS
/* $Header: MSCNATPS.pls 120.1 2007/12/12 10:30:25 sbnaik ship $  */


PROCEDURE Call_Schedule_New(
          p_session_id          IN    		NUMBER,
          p_atp_table           IN    		MRP_ATP_PUB.ATP_Rec_Typ,
          p_instance_id        	IN    		NUMBER,
          p_assign_set_id       IN    		NUMBER,
          p_refresh_number      IN    		NUMBER,
          x_atp_table          	OUT   		NoCopy MRP_ATP_PUB.ATP_Rec_Typ,
          x_return_status      	OUT   		NoCopy VARCHAR2,
          x_msg_data           	OUT   		NoCopy VARCHAR2,
          x_msg_count          	OUT   		NoCopy NUMBER,
          x_atp_supply_demand  	OUT NOCOPY 	MRP_ATP_PUB.ATP_Supply_Demand_Typ,
          x_atp_period         	OUT NOCOPY 	MRP_ATP_PUB.ATP_Period_Typ,
          x_atp_details        	OUT NOCOPY 	MRP_ATP_PUB.ATP_Details_Typ
);


END MSC_NATP_PVT;

/
