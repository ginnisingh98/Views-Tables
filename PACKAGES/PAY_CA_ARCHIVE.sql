--------------------------------------------------------
--  DDL for Package PAY_CA_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pycaarch.pkh 120.0.12000000.1 2007/01/17 16:44:59 appldev noship $ */
--
/*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation US Ltd.,                *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation USA Ltd, *
   *  USA.                                                          *
   *                                                                *
   ******************************************************************

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   06-MAY-1999  pganguly    40.0            Created.
   23-NOV-1999  jgoswami    110.1           Changed script to make it
                                            adcheck driver complient
   11-MAR-2002  pganguly    115.1           Added new procedure to create
                                            /delete assignment sets for Mass
                                            ROE.
   31-DEC-2002  pganguly    115.2           Added nocopy for GSCC.
   03-MAR-2003  pganguly    115.3           Added a record/table type variable
                                            declaration for ROE Box 17C.
*/
--
TYPE char240_data_type_table IS TABLE OF VARCHAR2(240)
                                  INDEX BY BINARY_INTEGER;

procedure range_cursor(pactid in  number,
                       sqlstr out nocopy varchar2);
procedure archinit(p_payroll_action_id in number);

procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number);

procedure archive_data(p_assactid in number,
			p_effective_date in date);

procedure create_asg_set_records(p_assignment_set_name in varchar2,
                                 p_assignment_id in number,
                                 p_business_group_id in number);

procedure delete_asg_set_records(p_assignment_set_name in varchar2,
                                 p_assignment_id in number,
                                 p_business_group_id in number);

TYPE rec_box17c IS RECORD(code varchar2(1),
                          balance_name varchar2(80));

TYPE tab_box17c is table of rec_box17c
                   index by binary_integer;

box17c_bal_table   tab_box17c;


end pay_ca_archive;

 

/
