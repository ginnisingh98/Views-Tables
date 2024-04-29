--------------------------------------------------------
--  DDL for Package CSD_REPAIR_ESTIMATE_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_ESTIMATE_REPORT_PVT" AUTHID CURRENT_USER AS
   /* $Header: csdverts.pls 120.1 2008/03/20 20:46:27 rfieldma noship $ */

	 /*--------------------------------------------------*/
	 /* declare vars required by XDO exe                 */
	 /*--------------------------------------------------*/

        P_REPAIR_LINE_ID        number;
        P_CONC_REQUEST_ID       number;

    /*--------------------------------------------------*/
    /* procedure name: BEFORE_REPORT                    */
    /* description   : auto gen by XDO converter        */
    /*                 may have data source logic later */
    /*                                                  */
    /*--------------------------------------------------*/
        function BeforeReport return boolean  ;

    /*--------------------------------------------------*/
    /* procedure name: AFTER_REPORT                     */
    /* description   : auto gen by XDO converter        */
    /*                 may have data source logic later */
    /*                                                  */
    /*--------------------------------------------------*/
        function AfterReport return boolean  ;

   /*---------------------------------------------------*/
   /*procedure name:CF_CUST_POFormula			*/
   /* description  :Procedure to return the PO number of*/
   /*		      repair order line 		*/
   /*---------------------------------------------------*/
        function CF_CUST_POFormula return varchar2  ;

END CSD_Repair_Estimate_Report_Pvt;

/
