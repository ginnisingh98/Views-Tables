--------------------------------------------------------
--  DDL for Package PAY_LIVEARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_LIVEARCHIVE_PKG" AUTHID CURRENT_USER AS
/* $Header: pyuslvar.pkh 115.2 2003/09/26 03:02:45 ardsouza noship $ */
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

    Name        : pay_livearchive_pkg

    Description : Packge header for Year End Reconsilation Report

    Change List
    -----------
     Date        Name      Vers    Bug No  Description
     ----        ----      ------  ------- -----------
     01-oct-2002 djoshi    115.0  2202647  Created.
     02-dec-2002 djoshi    115.1           Corrected to have
                                           nocopy with out parameter
     25-sep-2003 ardsouza  115.2  2554865  Added parameter p_box_type
                                           to procedure select_employee
*/

function  get_archive_value (     p_assignment_action_id number,
                                  p_balance_name varchar2,
                                  p_tax_unit_id number,
                                  p_jurisdiction   varchar2,
                                  p_jurisdiction_level number
                             ) return number ;

function  get_live_value (
                           p_balance_name varchar2
                         ) return number ;

 PROCEDURE SELECT_EMPLOYEE
           (errbuf                       OUT nocopy varchar2,
            retcode                      OUT nocopy number,
            p_year                IN      VARCHAR2,
            p_tax_unit_id         IN      NUMBER,
            p_fed_state           IN      VARCHAR2,
            p_is_state            IN      VARCHAR2,
            p_state_code          IN      VARCHAR2 default null,
            p_box_type            IN      VARCHAR2,  /* Bug 2554865 */
            p_box_name            IN      VARCHAR2 default null,
            p_output_file_type    IN      VARCHAR2
           );


  /**************************************************************
  ** PL/SQL table of records to store element name and value
  ***************************************************************/
/*
  TYPE rec_element  IS RECORD (element_name  varchar(100),
                               value         number);
  TYPE tab_element IS TABLE OF rec_element INDEX BY BINARY_INTEGER;
*/
  TYPE rec_for_balanace  IS RECORD (bal_name  varchar(100)
                                    ,bal_id         number
                                    ,bal_value      number);


/* following code is for future usage when we move to comparing all the
    balances.
*/
  TYPE live_bal_tab IS TABLE OF rec_for_balanace INDEX BY BINARY_INTEGER;
  TYPE arch_bal_tab IS TABLE OF rec_for_balanace  INDEX BY BINARY_INTEGER;

end pay_livearchive_pkg;

 

/
