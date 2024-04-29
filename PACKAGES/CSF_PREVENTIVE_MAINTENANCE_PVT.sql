--------------------------------------------------------
--  DDL for Package CSF_PREVENTIVE_MAINTENANCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_PREVENTIVE_MAINTENANCE_PVT" AUTHID CURRENT_USER as
/* $Header: csfvpmts.pls 120.0 2005/05/24 17:36:22 appldev noship $ */
-- Start of Comments
-- Package name     : CSF_Preventive_Maintenance_PVT
-- Purpose          : Preventive Maintenance concurrent program API
-- History          : Initial Version for release 11.5.9
-- NOTE             :
-- End of Comments
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   Generate_SR_tasks procedure queries ahl_unit_effectivities_b,
--   csi_item_instances tables and generates Service Request for each UMP
--   record and task for each record in ahl_routes_b corresponding to UMP.
--   API Name:  Generate_SR_Tasks
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number 	IN   NUMBER  Required
--       p_period_size	   	IN   NUMBER  Required
--   OUT:
--       retcode           	OUT NOCOPY NUMBER
--       errbuf               	OUT NOCOPY VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Generate_SR_Tasks (
    errbuf			 OUT NOCOPY VARCHAR2,
    retcode			 OUT NOCOPY NUMBER,
    P_Api_Version_Number         IN   NUMBER,
    p_period_size		 IN   NUMBER
    );

--   *******************************************************
--   Start of Comments
--   *******************************************************
--   Update_Ump procedure would update UMP to ACCOMPLISHED status with
--   counter values when the Service request generated
--   for this UMP is Closed . This procedure is available as a concurrent
--   program and it is recommended that this concurrent program run before
--   the new UMP generation.
--   API Name:  Update_Ump
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--   P_Api_Version_Number        IN   NUMBER Required
--   OUT :
--   retcode			 OUT  NOCOPY NUMBER
--   errbuf			 OUT  NOCOPY VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE update_ump (
    errbuf			 OUT  NOCOPY VARCHAR2,
    retcode			 OUT  NOCOPY NUMBER,
    P_Api_Version_Number         IN   NUMBER);

--   *******************************************************
--   Start of Comments
--   *******************************************************
--   Update_Sr_Tasks procedure would cancel the SR and associated tasks
--   when the UMP for which the SR is generated is cancelled.
--   This procedure would run as a concurrent program and it is recommended
--   to run the concurrent program after the UMP generation.
--   API Name:  update_sr_tasks
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN  :
--   P_Api_Version_Number        IN   NUMBER Required
--   OUT :
--   retcode			 OUT  NOCOPY NUMBER
--   errbuf			 OUT  NOCOPY VARCHAR2
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE update_sr_tasks (
    errbuf			 OUT  NOCOPY VARCHAR2,
    retcode			 OUT  NOCOPY NUMBER,
    P_Api_Version_Number         IN   NUMBER);

END CSF_PREVENTIVE_MAINTENANCE_PVT;

 

/
