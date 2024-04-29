--------------------------------------------------------
--  DDL for Package MSC_AATP_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_AATP_PROC" AUTHID CURRENT_USER AS
/* $Header: MSCPAATS.pls 120.1 2007/12/12 10:33:18 sbnaik ship $  */

PROCEDURE Add_to_current_atp (
	p_steal_atp            		IN OUT  NOCOPY MRP_ATP_PVT.ATP_Info,
	p_current_atp        		IN OUT	NOCOPY MRP_ATP_PVT.ATP_Info,
	x_return_status 		OUT     NOCOPY VARCHAR2);

PROCEDURE Atp_Forward_Consume (
        p_atp_period      IN      MRP_ATP_PUB.date_arr,
        p_atf_date        IN      DATE,
        p_atp_qty         IN OUT  NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status   OUT     NOCOPY VARCHAR2);

PROCEDURE Atp_Adjusted_Cum (
        p_current_atp		IN OUT  NOCOPY MRP_ATP_PVT.ATP_Info,
        p_unallocated_atp	IN OUT  NOCOPY MRP_ATP_PVT.ATP_Info,
        x_return_status 	OUT     NOCOPY VARCHAR2);

PROCEDURE Atp_Remove_Negatives (
        p_atp_qty         IN OUT NOCOPY MRP_ATP_PUB.number_arr,
        x_return_status   OUT    NOCOPY VARCHAR2);

PROCEDURE get_unalloc_data_from_SD_temp(
  x_atp_period                  OUT NOCOPY  	MRP_ATP_PUB.ATP_Period_Typ,
  p_unallocated_atp		IN OUT NOCOPY 	MRP_ATP_PVT.ATP_Info,
  x_return_status 		OUT NOCOPY 	VARCHAR2
);

END MSC_AATP_PROC;


/
