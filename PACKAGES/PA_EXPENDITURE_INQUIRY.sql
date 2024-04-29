--------------------------------------------------------
--  DDL for Package PA_EXPENDITURE_INQUIRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_EXPENDITURE_INQUIRY" AUTHID CURRENT_USER As
-- $Header: PAXEXINS.pls 120.1 2005/08/11 10:11:44 eyefimov noship $
--  Define the global package variable that will be returned by
--  the function Get_Mode

      X_Calling_Mode       VARCHAR2(20) ;

--  Define the global package variable that will be returned by
--  the function Get_Criteria (Bug#680401)

      X_Query_criteria     VARCHAR2(20) ;

--  This function will be used in the view to determine the mode

      FUNCTION Get_Mode RETURN  VARCHAR2 ;
      pragma RESTRICT_REFERENCES  ( Get_Mode, WNDS, WNPS );

--  The procedure that will be used to pass the value of the mode
--  from the form

--  This function will be used in the view to determine the Query criteria (Bug# 680401)

      FUNCTION Get_Criteria RETURN  VARCHAR2 ;
      pragma RESTRICT_REFERENCES  ( Get_Criteria, WNDS, WNPS );

--  The procedure that will be used to pass the value of the mode
--  from the form

  PROCEDURE  pa_expenditure_inquiry_driver (
                          x_Mode                IN      VARCHAR2);

--  The procedure that will be used to pass the value of the Query Criteria
--  from the form (Bug#680401)

  PROCEDURE  pa_expenditure_criteria_driver (
                          x_Criteria            IN      VARCHAR2);

  PROCEDURE pa_get_cdl_details( p_expenditure_item_id    IN NUMBER,
                                x_vendor_id              IN OUT NOCOPY NUMBER,
                                x_system_reference2      IN OUT NOCOPY VARCHAR2,
                                x_vendor_name            IN OUT NOCOPY VARCHAR2,
                                x_vendor_number          IN OUT NOCOPY VARCHAR2,
				                x_burden_sum_rej_code    IN OUT NOCOPY VARCHAR2) ;

END pa_expenditure_inquiry ;

 

/
