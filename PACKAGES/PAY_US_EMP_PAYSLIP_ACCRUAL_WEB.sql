--------------------------------------------------------
--  DDL for Package PAY_US_EMP_PAYSLIP_ACCRUAL_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_EMP_PAYSLIP_ACCRUAL_WEB" 
/* $Header: pyusacrw.pkh 120.1 2006/10/03 16:34:18 ahanda noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material AUTHID CURRENT_USER is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_emp_payslip_accrual_web

    Description : Package gets all the Accrual plans for an
                  Employee and populates a PL/SQL table -
                  LTR_ASSIGNMENT_ACCRUALS.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No     Description
    ----        ----     ----    ------     -----------
    01-JUL-1999 ahanda   110.0           Created.
    24-DEC-1999 ahanda   110.1/  1115325 Added paramter to procedure
                         115.0           get_emp_net_accrual to return the
                                         total no. of Accrual Categories.
    18-feb-2001 djoshi   115.1           Added procedure to delete
                                         global pl/sql table. Procedure
                                         Name is delete_ltr_assgnment_
                                         accrual
    06-Aug-2003 vpandya  115.5           Added NOCOPY with out parameter.
    02-OCT-2006 ahanda   115.6           Added accrual_code in pl/sql code
  *******************************************************************/
  AS

  /*****************************************************************
  ** PROCEDURE: get_emp_net_accrual
  ******************************************************************
  **
  ** Description:
  **     This procedure gets the Current and Net Accrual Balance and
  **     stores it in a PL/SQL Table.
  **
  ** Pre Conditions:
  **
  ** In Arguments:
  **     p_assignment_action_id - Assignment Action ID
  **     p_assignment_id        - Assignment ID
  **     p_cur_earned_date      - Earned Date of Pre Payment.
  **
  ** Out Arguments:
  **
  ** In Out Arguments:
  **
  ** Post Success:
  **     Stores the Accrual Info in a PL/SQL Table.
  **
  ** Post Failure:
  **
  ** Access Status:
  **     Public.
  **
  ******************************************************************/
  PROCEDURE get_emp_net_accrual (
                    p_assignment_action_id  in  number
                   ,p_assignment_id         in  number
                   ,p_cur_earned_date       in  date
                   ,p_total_acc_category    out NOCOPY number
                  );

  /******************************************************************
  ** Record Variable to Store Accrual Info
  ******************************************************************/
  TYPE accruals_rec IS RECORD
     ( accrual_code      varchar2(50)
      ,accrual_category  varchar2(100)
      ,accrual_cur_value number(10,2)
      ,accrual_net_value number(10,2)
     );

  /******************************************************************
  ** Table - Record Variable to Store Multiple Accrual Info
  ******************************************************************/
  TYPE accruals_tab_rec IS TABLE OF
      accruals_rec
  INDEX BY BINARY_INTEGER;

  /******************************************************************
  ** Package Variable
  ******************************************************************/
  ltr_assignment_accruals accruals_tab_rec;

  /*****************************************************************
  ** PROCEDURE: delete_ltr_assignment_accrual
  ******************************************************************
  **
  ** Description:
  **     This procedure deletes ie re-initalize  in a PL/SQL Table.
  **
  ** Pre Conditions:
  **
  ** In Arguments:
  **
  ** Out Arguments:
  **
  ** In Out Arguments:
  **
  ** Post Success:
  **
  ** Post Failure:
  **
  ** Access Status:
  *****************************************************************/
  procedure delete_ltr_assignment_accrual;

END pay_us_emp_payslip_accrual_web;

/
