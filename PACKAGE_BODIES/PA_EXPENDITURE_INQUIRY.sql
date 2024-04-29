--------------------------------------------------------
--  DDL for Package Body PA_EXPENDITURE_INQUIRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EXPENDITURE_INQUIRY" AS
 -- $Header: PAXEXINB.pls 120.1 2005/08/11 10:11:56 eyefimov noship $
--================================================================


--  This function will be used in the view to determine the mode
  FUNCTION  Get_Mode  RETURN VARCHAR2 IS
  BEGIN
         RETURN(pa_expenditure_inquiry.X_Calling_Mode);
  END Get_Mode ;

--  This function will be used in the view to determine the criteria(Bug#680401)
  FUNCTION  Get_Criteria  RETURN VARCHAR2 IS
  BEGIN
         RETURN(pa_expenditure_inquiry.X_Query_criteria);
  END Get_Criteria ;


  PROCEDURE  pa_expenditure_inquiry_driver (
                          x_Mode        IN      VARCHAR2) IS
  BEGIN
       X_Calling_Mode      :=      x_Mode ;
  END pa_expenditure_inquiry_driver;

-- (Bug#680401)
  PROCEDURE  pa_expenditure_criteria_driver (
                          x_Criteria    IN      VARCHAR2) IS
  BEGIN
       X_Query_criteria    :=      x_Criteria ;
  END pa_expenditure_criteria_driver;

  PROCEDURE pa_get_cdl_details( p_expenditure_item_id    IN  NUMBER,
                                x_vendor_id              IN OUT NOCOPY NUMBER,
                                x_system_reference2      IN OUT NOCOPY VARCHAR2,
                                x_vendor_name            IN OUT NOCOPY VARCHAR2,
                                x_vendor_number          IN OUT NOCOPY VARCHAR2,
				                x_burden_sum_rej_code    IN OUT NOCOPY VARCHAR2) is

    cursor GetCdlInfo is
       select vend.vendor_id,
              cdl.system_reference2,
              vend.vendor_name,
              vend.segment1,
	      cdl.burden_sum_rejection_code
         from po_vendors vend,
              PA_COST_DIST_LINES_ALL_BAS cdl
        where cdl.expenditure_item_id = p_expenditure_item_id
          and cdl.line_num (+)        = 1
/* Added the getNumericString wrapper over systeem_reference1  for bug3158748 */
          and pa_utils4.getNumericString(cdl.system_reference1)  = vend.vendor_id (+) ;

  BEGIN

     open GetCdlInfo ;
     fetch GetCdlInfo
      into x_vendor_id,
           x_system_reference2,
           x_vendor_name,
           x_vendor_number,
           x_burden_sum_rej_code ;

  EXCEPTION
     when no_data_found then
            x_vendor_id := Null;
            x_system_reference2 := Null;
            x_vendor_name := Null;
            x_vendor_number := Null;
            x_burden_sum_rej_code := Null;
            NULL ;
     when others then
            x_vendor_id := Null;
            x_system_reference2 := Null;
            x_vendor_name := Null;
            x_vendor_number := Null;
            x_burden_sum_rej_code := Null;
            RAISE ;

 END pa_get_cdl_details;

END pa_expenditure_inquiry ;

/
