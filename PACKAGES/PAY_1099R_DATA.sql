--------------------------------------------------------
--  DDL for Package PAY_1099R_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_1099R_DATA" AUTHID CURRENT_USER AS
/* $Header: py1099rd.pkh 115.0 99/07/17 05:40:54 porting ship $ */
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

    Name        : pay_1099R_data

    Description :  Sets up the data to provide 1099R reporting.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No     Description
    ----        ----     ----    ------     -----------
    07-AUG-96   ATAYLOR  40.0               Created.

*/
--
-- Define start / end of time constants.
--
	c_start_of_time constant date := to_date('01/01/0001','DD/MM/YYYY');
	c_end_of_time   constant date := to_date('31/12/4712','DD/MM/YYYY');
--
TYPE char30_data_table IS TABLE OF VARCHAR2(30)
                                  INDEX BY BINARY_INTEGER;
--
TYPE char250_data_table IS TABLE OF VARCHAR2(250)
                                  INDEX BY BINARY_INTEGER;
--
TYPE numeric_data_table IS TABLE OF NUMBER
                                  INDEX BY BINARY_INTEGER;
--
TYPE boolean_data_table IS TABLE OF BOOLEAN
                                  INDEX BY BINARY_INTEGER;
--
procedure setup;
--
end pay_1099R_data;

 

/
