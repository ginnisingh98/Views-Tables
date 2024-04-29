--------------------------------------------------------
--  DDL for Package PA_XLA_INTF_REV_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_XLA_INTF_REV_EVENTS" AUTHID CURRENT_USER AS
/* $Header: PAXLARVS.pls 120.5 2005/09/05 04:46:49 lveerubh noship $ */

/*----------------------------------------------------------------------------------------+
|   Procedure  :   create_events                                                          |
|   Purpose    :   Will create accounting event for revenues eligible for transfer to SLA |
|                  by calling XLA Create_Event API.
|   Parameters :                                                                          |
|     ==================================================================================  |
|     Name                    Mode            Description                                 |
|     ==================================================================================  |
|                                                                                         |
|      p_request_id           IN              Request id of the run                       |
|                                                                                         |
|      p_return_status        OUT NOCOPY      Return status of the API                    |
|                                                                                         |
|     ==================================================================================  |
+----------------------------------------------------------------------------------------*/

PROCEDURE create_events (p_request_id 		NUMBER,
			 p_return_status OUT NOCOPY VARCHAR2);
 FUNCTION Get_Sla_Ccid( P_Acct_Event_Id                IN PA_Draft_Revenues_All.Event_Id%TYPE
                        ,P_Transfer_Status_Code         IN PA_draft_revenues_All.Transfer_Status_Code%TYPE
                        ,P_Source_Distribution_Id_Num_1 IN XLA_Distribution_Links.Source_Distribution_Id_Num_1%TYPE
                        ,P_Source_Distribution_Id_Num_2 IN XLA_Distribution_Links.Source_Distribution_Id_Num_2%TYPE
                        ,P_Distribution_Type            IN XLA_Distribution_Links.SOURCE_DISTRIBUTION_TYPE%TYPE
                        ,P_Ledger_Id                    IN PA_Implementations_All.Set_Of_Books_Id%TYPE
                       ) RETURN NUMBER;

END PA_XLA_INTF_REV_EVENTS;

 

/
