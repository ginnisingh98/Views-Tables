--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: pyelerep.pkh 120.0.12010000.1 2008/07/27 22:30:57 appldev ship $ */
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

    Name        : pay_element_extract_pkg

    Description : Package for the Elements Reports. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML
                      - CSV

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     04-AUG-2000 ahanda    115.0             Created.
     14-SEP-2000 ahanda    115.1   1407284   Corrected package name.
     04-DEC-2002 dsaxby    115.3   2692195   Nocopy changes.
     19-JUL-2004 schauhan  115.4   3731178   Added function get_element_type_id which returns
					     element_type_id from which Pay value is calculated.
     19-JUL-2004 schauhan  115.5   3731178   Reverted back to version 115.3
     10-MAR-2005 rajeesha  115.6   4214739   Status added in TYPE rec_element
*/

  PROCEDURE element_extract
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
             ,p_business_group_id         in  number
             ,p_start_date                in  varchar2
             ,p_end_date                  in  varchar2
             ,p_selection_criteria        in  varchar2
             ,p_is_ele_set                in  varchar2
             ,p_element_set_id            in  number
             ,p_is_ele_class              in  varchar2
             ,p_element_classification_id in  number
             ,p_is_ele                    in  varchar2
             ,p_element_type_id           in  number
             ,p_payroll_id                in  number
             ,p_consolidation_set_id      in  number
             ,p_tax_unit_id               in  number
             ,p_organization_id           in  number
             ,p_location_id               in  number
             ,p_person_id                 in  number
             ,p_assignment_set_id         in  number
             ,p_output_file_type          in  varchar2
             );


  /**************************************************************
  ** PL/SQL table of records to store element name and value
  ***************************************************************/
  TYPE rec_element  IS RECORD (element_name  varchar(100),
                               value         number,
			       Status        varchar2(2));
  TYPE tab_element IS TABLE OF rec_element INDEX BY BINARY_INTEGER;

end pay_element_extract_pkg;

/
