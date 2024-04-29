--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_TRAVELER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_TRAVELER_PVT" AS
/* $Header: csdvtvlb.pls 120.3 2008/03/20 20:47:57 rfieldma noship $ */

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------

G_PKG_NAME             CONSTANT VARCHAR2(30) := 'CSD_REPAIR_TRAVELER_PVT';
G_FILE_NAME            CONSTANT VARCHAR2(12) := 'csdvtvlb.pls';
g_debug                         NUMBER       := Csd_Gen_Utility_Pvt.g_debug_level;
G_DEBUG_LEVEL          CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

-- ---------------------------------------------------------
-- functions and procedures
-- ---------------------------------------------------------

/*--------------------------------------------------*/
/* procedure name: BEFORE_REPORT                    */
/* description   : auto gen by XDO converter        */
/*                 may have data source logic later */
/*                                                  */
/*--------------------------------------------------*/
FUNCTION BEFORE_REPORT RETURN BOOLEAN IS
BEGIN
    /*SRW.USER_EXIT('FND SRWINIT');*/
    null;
    return (TRUE);
END; -- Before_Report


/*--------------------------------------------------*/
/* procedure name: AFTER_REPORT                    */
/* description   : auto gen by XDO converter        */
/*                 may have data source logic later */
/*                                                  */
/*--------------------------------------------------*/
FUNCTION AFTER_REPORT RETURN BOOLEAN IS
BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT');*/
    null;
    return (TRUE);
END; -- After_Report


--Functions to refer Oracle report placeholders--
END CSD_Repair_Traveler_Pvt ;

/
