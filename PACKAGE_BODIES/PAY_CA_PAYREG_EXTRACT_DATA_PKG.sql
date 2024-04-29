--------------------------------------------------------
--  DDL for Package Body PAY_CA_PAYREG_EXTRACT_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_PAYREG_EXTRACT_DATA_PKG" AS
/* $Header: pycaprpd.pkb 115.2 2001/12/20 00:57:45 pkm ship        $ */
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

    Name        : pay_ca_payreg_extract_data_pkg

    Description : Package for the Payment Report.
                  The package can be used by the users to add columns
                  which they want on the report.
                  The data is printed at the end of the report for
                  each assignment. The package is passed the following
                  paramaters to the report which can be used for
                  retreiving data.
                        - assignment_id
                        - person_id
                        - assignment_action_id
                        - effective_date from pay_payroll_actions

    Change List

    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     10-OCT-2001 ssattini  115.0             Created.
     20-NOV-2001 ssattini  115.1             Added dbdrv line.
     20-DEC-2001 ssattini  115.2             Added checkfile line.

*/

  PROCEDURE populate_table (p_assignment_id         in number
                           ,p_person_id             in number
                           ,p_assignment_action_id  in number
                           ,p_effective_date        in date
                           )
  IS

  BEGIN

    null;

  END populate_table;


END pay_ca_payreg_extract_data_pkg;

/
