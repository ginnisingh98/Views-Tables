--------------------------------------------------------
--  DDL for Package MSC_ATP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ATP_UTILS" AUTHID CURRENT_USER AS
/* $Header: MSCUATPS.pls 120.2 2007/12/12 10:43:08 sbnaik ship $  */


SYS_YES                      CONSTANT NUMBER := 1;
SYS_NO                       CONSTANT NUMBER := 2;
REQUEST_MODE                 CONSTANT NUMBER := 1;
RESULTS_MODE                 CONSTANT NUMBER := 2;


PROCEDURE put_into_temp_table(
	x_dblink		IN   	VARCHAR2,
	x_session_id         	IN   	NUMBER,
	x_atp_rec            	IN   	MRP_ATP_PUB.atp_rec_typ,
	x_atp_supply_demand  	IN   	MRP_ATP_PUB.ATP_Supply_Demand_Typ,
	x_atp_period         	IN   	MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_details        	IN   	MRP_ATP_PUB.ATP_Details_Typ,
	x_mode               	IN   	NUMBER,
	x_return_status      	OUT   	NoCopy VARCHAR2,
	x_msg_data           	OUT   	NoCopy VARCHAR2,
	x_msg_count          	OUT   	NoCopy NUMBER
   );

PROCEDURE get_from_temp_table(
	x_dblink		IN   	VARCHAR2,
	x_session_id         	IN   	NUMBER,
	x_atp_rec            	OUT   	NoCopy MRP_ATP_PUB.atp_rec_typ,
	x_atp_supply_demand  	OUT   	NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
	x_atp_period         	OUT   	NoCopy MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_details        	OUT   	NoCopy MRP_ATP_PUB.ATP_Details_Typ,
	x_mode               	IN   	NUMBER,
	x_return_status      	OUT   	NoCopy VARCHAR2,
	x_msg_data           	OUT   	NoCopy VARCHAR2,
	x_msg_count          	OUT   	NoCopy NUMBER,
        p_details_flag            IN      NUMBER
   );

FUNCTION Call_ATP_11(
	p_group_id      		NUMBER,
	p_session_id    		NUMBER,
	p_insert_flag   		NUMBER,
	p_partial_flag  		NUMBER,
	p_err_message   	IN OUT 	NoCopy VARCHAR2)
RETURN NUMBER;


PROCEDURE extend_mast(
	mast_rec      		IN OUT	NoCopy MRP_ATP_UTILS.mrp_atp_schedule_temp_typ,
	x_ret_code    		OUT 	NoCopy varchar2,
	x_ret_status  		OUT 	NoCopy varchar2);

PROCEDURE trim_mast(
	mast_rec     		IN OUT  NoCopy MRP_ATP_UTILS.mrp_atp_schedule_temp_typ,
	x_ret_code   		OUT	NoCopy varchar2,
	x_ret_status 		OUT 	NoCopy varchar2);

/* 2974324 Procedure just for testing. Removed
PROCEDURE test(x_session_id NUMBER);
*/

-- Added on 10/16 by ngoel for inserting BOM data into MSC_BOM_TEMP
-- table when ATP is called with CTO models from OM or Configurator.

PROCEDURE put_into_bom_temp_table(
        p_session_id         	IN    NUMBER,
	p_dblink             	IN    VARCHAR2,
        p_atp_bom_rec        	IN    MRP_ATP_PUB.ATP_BOM_Rec_Typ,
	x_return_status      	OUT   NoCopy VARCHAR2,
	x_msg_data           	OUT   NoCopy VARCHAR2,
	x_msg_count          	OUT   NoCopy NUMBER);

PROCEDURE Put_SD_Data (
        p_atp_supply_demand     IN      MRP_ATP_PUB.ATP_Supply_Demand_Typ,
        p_dblink                IN      VARCHAR2,
        p_session_id            IN      NUMBER );

PROCEDURE Put_Period_Data (
        p_atp_period            IN      MRP_ATP_PUB.ATP_Period_Typ,
        p_dblink                IN      VARCHAR2,
        p_session_id            IN      NUMBER );

PROCEDURE Put_Pegging_data (p_session_id IN NUMBER,
                            p_dblink     IN VARCHAR2);

Procedure Put_Scheduling_data(p_atp_rec            IN   MRP_ATP_PUB.atp_rec_typ,
                              p_mode               IN   NUMBER,
                              p_dblink             IN   VARCHAR2,
                              p_session_id         IN   NUMBER );

Procedure Process_Supply_Demand_details( p_dblink             IN    varchar2,
                                         p_session_id         IN    number,
                                         x_atp_supply_demand  OUT   NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ);

PROCEDURE Transfer_mrp_atp_details_temp(
	p_dblink	IN		VARCHAR2,
	p_session_id	IN		NUMBER
);

PROCEDURE Retrieve_Period_and_SD_Data(
	p_session_id	IN		NUMBER,
	x_atp_period	OUT NOCOPY	MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_supply_demand OUT NOCOPY	MRP_ATP_PUB.ATP_Supply_Demand_Typ
);

PROCEDURE Copy_MRP_SD_Recs(
	p_old_pegging_id NUMBER,
	p_pegging_id	 NUMBER
);

procedure Put_Sch_Data_Request_Mode(p_atp_rec IN   MRP_ATP_PUB.atp_rec_typ,
                                           p_session_id   IN NUMBER);


Procedure Put_Sch_data_result_mode(p_atp_rec IN  MRP_ATP_PUB.atp_rec_typ,
                                          p_dblink             IN   VARCHAR2,
                                          p_session_id         IN   NUMBER);

Procedure Transfer_Scheduling_data(p_session_id IN Number,
                                   p_dblink     IN  VARCHAR2,
                                   p_mode       IN  NUMBER);

procedure Update_Line_Item_Properties(p_session_id IN NUMBER,
                                      Action       IN NUMBER DEFAULT NULL); --3720018

/* Bug 5598066: Function to Truncate demand to 6 decimal places.
 Also if the 7th point if 9, it will be a 1 increase in the 6th point. */

FUNCTION Truncate_Demand (p_demand_qty IN NUMBER)
  Return NUMBER;

END MSC_ATP_UTILS;


/
