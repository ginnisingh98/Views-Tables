--------------------------------------------------------
--  DDL for Package EGO_MASS_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_MASS_UPDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: EGOMUPGS.pls 120.0 2005/07/15 03:34:11 ajerome noship $ */

--========================================================================
-- PROCEDURE :  Item_Org_Assignment     PUBLIC
-- PARAMETERS:  p_batch_id           IN  NUMBER                 Batch Id for records in Temp Table
--             ,p_all_request_ids    OUT NOCOPY VARCHAR2(300)   Concatenated Request Ids
--             ,x_return_status      OUT NOCOPY VARCHAR2        Standard OUT Parameter
--             ,x_msg_count          OUT NOCOPY NUMBER          Standard OUT Parameter
--             ,x_msg_data           OUT NOCOPY VARCHAR2        Standard OUT Parameter
--
-- DESCRIPTION   : This procedure Assigns Items to Organizations in
--		   in Mass Update flows. Items and Orgs for the assignment are
--		   obtained from temporary tables
--=========================================================================

PROCEDURE  item_org_assignment
    ( p_batch_id           IN  NUMBER
     ,p_all_request_ids    OUT NOCOPY VARCHAR2
     ,x_return_status      OUT NOCOPY VARCHAR2
     ,x_msg_count          OUT NOCOPY NUMBER
     ,x_msg_data           OUT NOCOPY VARCHAR2
    );

--========================================================================
-- PROCEDURE :  Write_Debug
-- PARAMETERS:  p_msg  IN  VARCHAR2
--
-- DESCRIPTION   : Debug Message Logger
--=========================================================================

PROCEDURE Write_Debug (p_msg  IN  VARCHAR2);

--========================================================================
-- PROCEDURE :  clear_temp_tables
-- PARAMETERS:  errbuf out NOCOPY varchar2
-- PARAMETERS:  retcode out NOCOPY varchar2
-- PARAMETERS:  hours IN NUMBER
--
-- DESCRIPTION   : Clears Massupdate temp Tables
--=========================================================================

PROCEDURE clear_temp_tables(  errbuf OUT NOCOPY VARCHAR2,
                              retcode OUT NOCOPY NUMBER,
                              hours NUMBER) ;

END EGO_MASS_UPDATE_PVT;

 

/
