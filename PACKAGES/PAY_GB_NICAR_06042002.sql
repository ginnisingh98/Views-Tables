--------------------------------------------------------
--  DDL for Package PAY_GB_NICAR_06042002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_NICAR_06042002" AUTHID CURRENT_USER as
/* $Header: pygbncpl.pkh 115.8 2002/12/09 18:35:57 rmakhija noship $
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1989 Oracle Corporation UK Ltd.,                *
   *                   Richmond, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

    Name        : pay_gb_nicar_2002

    Description : This package contains calculations for use in processing
	of NI Car Primary and Secondary elements

    Uses        :

    Used By     : NI Car fast formulas for tax year 2002/3


    Change List :

    Version     Date     Author         Description
    -------     -----    --------       ----------------

   115.0       20/8/01   GBUTLER        Created
   115.1       04/12/01  vmkhande       Modified some functions
                                        such that they can be used to
                                        do the calculation for P11D element
                                        verifications
   115.4       18/1/02	 GButler	Added nicar_main procedure; this is now
   					called by NI Car fast formulas. Also
   					removed specific parameters for P11d as
   					no longer required. Removed get_next_pay_date
   					function
   115.5       24/4/02   GButler	Removed p_message parameter from
   					nicar_nicable_value_non_co2 as obsolete
   					following updates to message handling
   115.6       10/5/02   GButler	Replaced p_message parameter as used
   					by P11D calculation
   115.7       29/11/02  RMAKHIJA       added Whenever OSERROR on the rop
   115.8       09/12/02  RMAKHIJA       Added NOCOPY to out parameters to fix GSCC warning
*/

/* Function to calculate taxable / NICable value based on CO2 emissions data for car */
/* Parameters p_business_group_id, p_assignment_id, p_element_type_id provided by */
/* context-set variables */
function nicar_nicable_value_CO2
( p_assignment_id				   IN NUMBER,
  p_element_type_id				   IN NUMBER,
  p_business_group_id			           IN NUMBER,
  /* Import direct from fast formula */
  p_car_price 				           IN NUMBER,
  p_reg_date  					   IN DATE,
  p_fuel_type 					   IN VARCHAR2,
  p_engine_size 				   IN NUMBER,
  p_fuel_scale					   IN NUMBER DEFAULT NULL,
  p_payment					   IN NUMBER,
  p_CO2_emissions 				   IN NUMBER DEFAULT NULL,
  p_start_date					   IN DATE,
  p_end_date					   IN DATE,
  p_end_of_period_date			    	   IN DATE,
  p_emp_term_date				   IN DATE,
  p_session_date				   IN DATE,
  p_message					   OUT NOCOPY VARCHAR2,
  p_number_of_days                 		   IN NUMBER DEFAULT 0)
return NUMBER;


/* Function to calculate taxable / NICable value based on engine capacity for cars without */
/* approved CO2 emissions ratings */
/* Parameter p_business_group_id provided by context-set variable */
function nicar_nicable_value_non_CO2
( p_assignment_id				   IN NUMBER,
  p_element_type_id				   IN NUMBER,
  p_business_group_id			           IN NUMBER,
  /* Import direct from fast formula */
  p_car_price 				           IN NUMBER,
  p_reg_date  					   IN DATE,
  p_fuel_type 					   IN VARCHAR2,
  p_engine_size 				   IN NUMBER,
  p_fuel_scale					   IN NUMBER DEFAULT NULL,
  p_payment					   IN NUMBER,
  p_start_date					   IN DATE,
  p_end_date					   IN DATE,
  p_end_of_period_date			    	   IN DATE,
  p_emp_term_date				   IN DATE,
  p_session_date				   IN DATE,
  p_message					   OUT NOCOPY VARCHAR2,
  p_number_of_days                 		   IN NUMBER DEFAULT 0)
return NUMBER;

/* Round CO2 emissions figure down to nearest multiple of 5 */
function round_CO2_val
(p_value 	   	   IN NUMBER)
return NUMBER;

/* Return applicable percentage charge based on CO2 emissions for car */
function get_CO2_percentage
(p_business_group_id 	           IN NUMBER,
 p_co2_emissions		   IN NUMBER,
 p_session_date		   	   IN DATE)
return NUMBER;


/* Return applicable percentage based on engine size */
function get_cc_percentage
( p_business_group_id  	          IN NUMBER,
  p_engine_size			  IN NUMBER,
  p_reg_date			  IN DATE,
  p_session_date		  IN DATE)
return NUMBER;

/* Return fixed discount percentage for certain alternative fuel cars */
function get_discount
( p_fuel_type 		 	 IN VARCHAR2,
  p_session_date	 	 IN DATE)
return NUMBER;


/* Primary function for pay_gb_nicar_06042002 */
/* Called by fast formula and NI Car Detail report */
/* Calls nicar_nicable_value_CO2 and nicar_nicable_value_non_CO2 as appropriate */
function nicar_main
( /* Context set parameters */
  p_assignment_id 		   		  IN number,
  p_element_type_id				  IN number,
  p_business_group_id			          IN number,
  /* Fast formula parameters */
  p_pay_periods_per_year	   	  	  IN number,
  p_curr_payroll_period			          IN number,
  p_curr_payroll_period_end_date  	          IN date,
  p_emp_term_date				  IN date,
  p_session_date				  IN date,
  /* OUT parameter */
  p_message_1		   	 	          OUT NOCOPY varchar2,
  p_message_2					  OUT NOCOPY varchar2,
  p_message_3					  OUT NOCOPY varchar2,
  p_message_4					  OUT NOCOPY varchar2)
return number;


/* End of package */
end pay_gb_nicar_06042002;

 

/
