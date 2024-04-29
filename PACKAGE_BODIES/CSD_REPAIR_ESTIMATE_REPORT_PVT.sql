--------------------------------------------------------
--  DDL for Package Body CSD_REPAIR_ESTIMATE_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REPAIR_ESTIMATE_REPORT_PVT" AS
/* $Header: csdvertb.pls 120.3 2008/03/20 20:44:15 rfieldma noship $ */



    /*--------------------------------------------------*/
    /* procedure name: BEFORE_REPORT                    */
    /* description   : auto gen by XDO converter        */
    /*                 may have data source logic later */
    /*                                                  */
    /*--------------------------------------------------*/
function BeforeReport return boolean is
begin


/*SRW.USER_EXIT('FND SRWINIT');*/null;

  return (TRUE);
end;



    /*--------------------------------------------------*/
    /* procedure name: AFTER_REPORT                     */
    /* description   : auto gen by XDO converter        */
    /*                 may have data source logic later */
    /*                                                  */
    /*--------------------------------------------------*/
function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;


   /*---------------------------------------------------*/
   /*procedure name:CF_CUST_POFormula                   */
   /* description  :Procedure to return the PO number of*/
   /*                 repair order line                 */
   /*---------------------------------------------------*/


function CF_CUST_POFormula return varchar2 is
l_po_number csd_repair_estimate.po_number%type;
begin

select po_number
INTO l_po_number
from csd_repair_estimate cre
where cre.repair_line_id =P_REPAIR_LINE_ID;

Return  l_po_number;

   /*------------------------------------------------------*/
   /*Exceptions                                            */
   /* description  :  Incase of exceptions returning null. */
   /*------------------------------------------------------*/


Exception
When Others then
   return ' ';
end;

--Functions to refer Oracle report placeholders--

END CSD_Repair_Estimate_Report_Pvt;

/
