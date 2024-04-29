--------------------------------------------------------
--  DDL for Package PAY_US_OVER_LIMIT_TAX_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_OVER_LIMIT_TAX_RPT_PKG" 
/* $Header: pyusoltx.pkh 120.0.12000000.1 2007/01/18 02:44:46 appldev noship $ */
/* ******************************************************************
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

    Name        : pyusoltx.pkh


    Description :

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No     Description
    ----------- -------- ------  --------   -----------
    01-NOV-1999 hzhao    110.0              Initial Version.
    22-NOV-1999 hzhao    110.1              Moved Header below Create Stmt.
    06-DEC-2001 tmehra   110.2              Added dbdrv command.
    04-FEB-2002 meshah   115.2    2166701   Added procedure load_data.
    05-FEB-2002 meshah   115.3              Added checkfile entry to the file.
    04-APR-2002 meshah   115.4              Removed the PRAGMA from
                                            get_taxable_balance.
    25-NOV-2002 irgonzal 115.5    2664340   Added logic to handle Catchup
                                            balances.
    18-MAY-2003 vgunasek 115.6    2938556   report rewrite including support for
   					    new balance reporting architecture (run
   					    balances) and multi threading.
    02-JUN-2003 vgunasek 115.7    2938556   Added Comments and change history.
    02-JUN-2003 vgunasek 115.8    2938556   Commented Pragma restrict references.
    02-JUN-2003 vgunasek 115.9    2938556   Corrections to change history.
    02-JUN-2003 vgunasek 115.10   2938556   Corrections to change history.

***************************************************************************/
AS

  -- Removed the Overloaded function and global limit variables for bug # 2938556

  -- As part of bug # 2938556 the parameters of the function are changed
  -- to receive balance id instead of attributes from pay_balance_sets

  FUNCTION get_taxable_balance (
           p_assignment_id           IN NUMBER
          ,p_effective_date          IN DATE
          ,p_assignment_action_id    IN NUMBER
          ,p_tax_unit_id             IN NUMBER
          ,p_tax_group               IN VARCHAR2
          ,p_jurisdiction_code       IN VARCHAR2
          ,p_tax_type                IN VARCHAR2
          ,p_balance_id              IN NUMBER
	)
  RETURN NUMBER;

  -- The parameter of this function is changed from tax limit name to tax type

  FUNCTION get_state_limit(
           p_state_code              IN NUMBER
          ,p_tax_type          IN VARCHAR2 )
  RETURN NUMBER;

  -- Additional parameters assignment_id, assignment_action_id and tax unit id
  -- were added for bug # 2938556.

procedure load_data
(  pactid     in     number,     /* payroll action id */
   chnkno     in     number,
   p_assignment_id     		IN	NUMBER,
   p_assignment_action_id    	IN 	NUMBER,
   p_tax_unit_id             	IN 	NUMBER
);

--  PRAGMA RESTRICT_REFERENCES(get_taxable_balance, WNDS,WNPS);
--  PRAGMA RESTRICT_REFERENCES(get_state_limit, WNDS);


END pay_us_over_limit_tax_rpt_pkg;

 

/
