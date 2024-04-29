--------------------------------------------------------
--  DDL for Package PAY_US_PDT_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_PDT_VALIDATE" AUTHID CURRENT_USER as
/* $Header: pypdtuvd.pkh 115.0 99/07/17 06:21:33 porting ship $ */

/*
/*
   ******************************************************************
   *                                                                *
   * Copyright (C) 1993 Oracle Corporation.                         *
   * All rights reserved.                                           *
   *                                                                *
   * This material has been provided pursuant to an agreement       *
   * containing restrictions on its use.  The material is also      *
   * protected by copyright law.  No part of this material may      *
   * be copied or distributed, transmitted or transcribed, in       *
   * any form or by any means, electronic, mechanical, magnetic,    *
   * manual, or otherwise, or disclosed to third parties without    *
   * the express written permission of Oracle Corporation,          *
   * 500 Oracle Parkway, Redwood City, CA, 94065.                   *
   *                                                                *
   ******************************************************************

    Name : pay_us_pdt_validate

    Description : This package contains the procedure validate_business_rules,
                  which is used for user_defined validation.  The procedure
		  is called from the PayMIX package.

    Uses : hr_utility

    Change List
    -----------
    Date        Name      Vers  Bug No  Description
    ----        ----      ----  ------  -----------
    11-MAR-96   RAMURTHY   1.0  345572  Created.


*/

PROCEDURE validate_business_rules(
          p_batch_type          IN              VARCHAR2,
          p_process_mode        IN              VARCHAR2,
          p_num_warnings        IN OUT          NUMBER,
          p_batch_id            IN              NUMBER,
          p_line_id             IN              NUMBER,
          p_period_start_date   IN              DATE,
          p_period_end_date     IN              DATE,
          p_num_inp_values      IN              NUMBER,
          p_line_status         IN OUT          VARCHAR2,
          p_assignment_id       IN              NUMBER,
          p_element_type_id     IN              NUMBER,
          p_hours_worked        IN              NUMBER,
          p_date_earned         IN              DATE);

END pay_us_pdt_validate;

 

/
