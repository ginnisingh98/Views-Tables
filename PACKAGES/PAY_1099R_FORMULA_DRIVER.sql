--------------------------------------------------------
--  DDL for Package PAY_1099R_FORMULA_DRIVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_1099R_FORMULA_DRIVER" AUTHID CURRENT_USER AS
/* $Header: py1099fd.pkh 115.0 99/07/17 05:40:47 porting ship $ */
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
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

    Name        : pay_1099R_formula_driver

    Description : Allows the creation of formulas which are neccessary
		  for 1099R reporting on a federal level. This set of
		  formulas includes the following :
			US_1099R_FILE_TOTALS
			US_1099R_PAYEES
			US_1099R_PAYER
			US_1099R_PAYER_TOTALS
			US_1099R_STATE_TOTALS
			US_1099R_TRANSMITTER

    Uses        : For any 1099R installation.

    Change List
    -----------
    Date        Name     Vers    Bug No     Description
    ----        ----     ----    ------     -----------
    05-NOV-96   GPERRY   40.0               Created.

*/
--
-- Define start / end of time constants.
--
	c_start_of_time constant date := to_date('01/01/0001','DD/MM/YYYY');
	c_end_of_time   constant date := to_date('31/12/4712','DD/MM/YYYY');
--
TYPE char240_data_table IS TABLE OF VARCHAR2(240)
                                  INDEX BY BINARY_INTEGER;
--
TYPE char80_data_table IS TABLE OF VARCHAR2(80)
				  INDEX BY BINARY_INTEGER;
--
procedure setup;
--
end pay_1099R_formula_driver;

 

/
