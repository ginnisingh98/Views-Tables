--------------------------------------------------------
--  DDL for Package Body MSC_NATP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_NATP_PVT" AS
/* $Header: MSCNATPB.pls 120.1 2007/12/12 10:30:05 sbnaik ship $  */


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
)
IS
BEGIN
	MSC_ATP_PVT.Call_Schedule(
          p_session_id,
          p_atp_table,
          p_instance_id,
          p_assign_set_id,
          p_refresh_number,
          x_atp_table,
          x_return_status,
          x_msg_data,
          x_msg_count,
          x_atp_supply_demand,
          x_atp_period,
          x_atp_details);
END;


END MSC_NATP_PVT;

/
