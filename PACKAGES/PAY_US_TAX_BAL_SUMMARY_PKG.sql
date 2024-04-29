--------------------------------------------------------
--  DDL for Package PAY_US_TAX_BAL_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAX_BAL_SUMMARY_PKG" AUTHID CURRENT_USER as
/* $Header: pyustxbs.pkh 120.0.12010000.1 2008/07/27 23:57:44 appldev ship $ */
/*
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

    Name        : pay_us_tax_bal_summary_pkg

    Description : This package is used by the Tax Balance Summary form
    		  to fetch tax balances. Balances and their values for
    		  different time dimensions are populated into PL/SQL
    		  tables and returned back to Tax Balance Summary form.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    05-DEC-2003 sdahiya    115.0   3129694  Created.
    22-DEC-2003 sdahiya    115.1   3129694  Component 'prompt' of taxes_rec
                                            record declared using %type.

  *****************************************************************************/


-- record to store tax name and values for different time dimensions

TYPE taxes_rec IS RECORD (
                          prompt pay_us_tax_balances.balance_category_code%type,
                          ptd_val number,
                          mtd_val number,
                          qtd_val number,
                          ytd_val number
                          );

TYPE tab_taxes IS TABLE of taxes_rec INDEX BY BINARY_INTEGER;


 /*****************************************************************************
   Name      :  GET_FED
   Purpose   :  This procedure obtains federal EE/ER balances for a given
   		assignment action and populates them into a PL/SQL table. This
   		table is returned as an out parameter to the calling procedure
   		of Tax Balance Summary form.
 *****************************************************************************/

PROCEDURE GET_FED (p_ee_er IN VARCHAR2
                 , p_assg_id IN NUMBER
                 , p_asact_id IN NUMBER
                 , p_tax_unit_id IN NUMBER
                 , p_fed_taxes_tab OUT NOCOPY tab_taxes);



 /*****************************************************************************
   Name      :  GET_STATE
   Purpose   :  This procedure obtains state EE/ER balances for a given
   		state and populates them into a PL/SQL table. This
   		table is returned as an out parameter to the calling procedure
   		of Tax Balance Summary form.
 *****************************************************************************/

PROCEDURE GET_STATE (p_ee_er IN VARCHAR2
                    , p_assg_id IN NUMBER
                    , p_asact_id IN NUMBER
                    , p_tax_unit_id IN NUMBER
                    , p_state_code IN VARCHAR2
                    , p_state_taxes_tab OUT NOCOPY tab_taxes);


 /*****************************************************************************
   Name      :  GET_LOCAL
   Purpose   :  This procedure obtains local EE balances for a given
   		jurisdiction code and populates them into a PL/SQL table. This
   		table is returned as an out parameter to the calling procedure
   		of Tax Balance Summary form.
 *****************************************************************************/
PROCEDURE GET_LOCAL (p_ee_er IN VARCHAR2
                   , p_assg_id IN NUMBER
                   , p_asact_id IN NUMBER
                   , p_tax_unit_id NUMBER
                   , p_jurisdiction IN VARCHAR2
                   , p_school IN VARCHAR2
                   , p_local_taxes_tab OUT NOCOPY tab_taxes);

end;

/
