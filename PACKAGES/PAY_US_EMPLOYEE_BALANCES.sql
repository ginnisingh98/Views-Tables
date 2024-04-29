--------------------------------------------------------
--  DDL for Package PAY_US_EMPLOYEE_BALANCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_EMPLOYEE_BALANCES" AUTHID CURRENT_USER AS
/* $Header: pyusempb.pkh 120.0.12000000.1 2007/01/18 02:24:19 appldev noship $ */

/******************************************************************************
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_employee_balances

    Description : The package fetches the earnings and Non-Tax Deduction
    	   	  balances and populates them in the PL/SQL tables.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    26-DEC-2003 kaverma    115.0   3311781  Created.
    13-JAN-2004	kaverma    115.1   3311781  Modified the procedure
                                            'populate_element_info'
    19-MAR-2004 kvsankar   115.2   3311781  Modified earn_rec, dedn_rec to
                                            have rowid as another coloumn.
******************************************************************************/

/******************************************************************************
 * This package is used by the Employee Balances form to get the value of
 * balances for different  earnings and Non-Tax deduction elements.The
 * procedure defined inside this package fetches the balance values and
 * populates a PL/SQL table.The PL/SQL tables are then passed to the form and
 * the values in these tables are displayed in the form.
******************************************************************************/

 -- Record to store earning elements
 TYPE earn_rec IS RECORD
 (row_id               ROWID
,element_name          pay_element_types_f.element_name%TYPE
 ,ptd		        number
 ,month		        number
 ,qtd		        number
 ,ytd		        number
 ,element_type_id       pay_element_types_f.element_type_id%TYPE
 ,classification_id     pay_element_types_f.classification_id%TYPE
 ,element_information10 pay_element_types_f.element_information10%TYPE
 ,element_information11 pay_element_types_f.element_information11%TYPE
 ,element_information12 pay_element_types_f.element_information12%TYPE
 ,element_information14 pay_element_types_f.element_information14%TYPE
 );


 -- Record to store deduction elements
 TYPE dedn_rec IS RECORD
 (row_id                ROWID
 ,element_name          pay_element_types_f.element_name%TYPE
 ,ptd		        number
 ,month		        number
 ,qtd		        number
 ,ytd		        number
 ,accrued               number
 ,arrears	        number
 ,tobond	        number
 ,element_type_id       pay_element_types_f.element_type_id%TYPE
 ,classification_id     pay_element_types_f.classification_id%TYPE
 ,element_information10 pay_element_types_f.element_information10%TYPE
 ,element_information11 pay_element_types_f.element_information11%TYPE
 ,element_information12 pay_element_types_f.element_information12%TYPE
 ,element_information14 pay_element_types_f.element_information14%TYPE
 );


 -- Declare tables for records
 TYPE earn_tbl IS TABLE OF
 earn_rec INDEX BY BINARY_INTEGER;

 TYPE dedn_tbl IS TABLE OF
 dedn_rec INDEX BY BINARY_INTEGER;

TYPE temp_tab IS RECORD
( accrued pay_balance_types.balance_name%TYPE,
  arrears pay_balance_types.balance_name%TYPE,
 tobond pay_balance_types.balance_name%TYPE
);
TYPE P_dedn_data_temp_tbl
 is
TABLE OF temp_tab index by binary_integer
;
/******************************************************************************
 * Name    : populate_element_info
 * Purpose : This procedure fetches the elements for which the balances are to
 *           be retrieved.It then finds out the corresponding balance values
 *           and stores them in a PL/SQL table.This PL/SQL table is passed to
 *           the form as an OUT parameter.
******************************************************************************/
 PROCEDURE populate_element_info( p_assignment_id       in  number,
				 p_assignment_action_id in  number,
				 p_classification_id    in  pay_element_classifications.classification_id%TYPE,
				 p_classification_name  in  pay_element_classifications.classification_name%TYPE,
				 p_session_date         in  pay_element_types_f.effective_start_date%TYPE,
				 p_action_date          in  pay_element_types_f.effective_start_date%TYPE,
			  	 p_pay_start_date       in  pay_element_types_f.effective_start_date%TYPE,
				 p_tax_unit_id          in  number,
			  	 p_per_month		in  number,
				 p_per_qtd 		in  number,
				 p_per_ytd		in  number,
				 p_asg_ptd 		in  number,
				 p_asg_month 		in  number,
				 p_asg_qtd 		in  number,
				 p_asg_ytd		in  number,
				 p_asg_itd		in  number,
				 p_legislation_code     in  pay_element_types_f.legislation_code%TYPE,
				 p_business_group_id    in  pay_element_types_f.business_group_id%TYPE,
				 p_balance_level        in  varchar2,
				 p_earn_data            out nocopy earn_tbl,
				 p_dedn_data 	        out nocopy dedn_tbl,
                                 p_element_type_id      in  out nocopy number,
                                 p_flag                 out nocopy varchar2,
                                 p_balance_status       in  varchar2);

END pay_us_employee_balances;

 

/
