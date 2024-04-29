--------------------------------------------------------
--  DDL for Package CSD_REPAIR_TRAVELER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_TRAVELER_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvtvls.pls 120.3 2008/03/20 20:49:51 rfieldma noship $ */

    /*---------------------------------------------------*/
    /* declare vars required by XDO exe                  */
    /*---------------------------------------------------*/
    P_REPAIR_LINE_ID        number;
    P_CONC_REQUEST_ID       number;

    /*--------------------------------------------------*/
    /* procedure name: BEFORE_REPORT                    */
    /* description   : auto gen by XDO converter        */
    /*                 may have data source logic later */
    /*                                                  */
    /*--------------------------------------------------*/
    FUNCTION BEFORE_REPORT RETURN BOOLEAN;


    /*--------------------------------------------------*/
    /* procedure name: AFTER_REPORT                     */
    /* description   : auto gen by XDO converter        */
    /*                 may have data source logic later */
    /*                                                  */
    /*--------------------------------------------------*/
    FUNCTION AFTER_REPORT RETURN BOOLEAN;


END CSD_Repair_Traveler_Pvt;

/
