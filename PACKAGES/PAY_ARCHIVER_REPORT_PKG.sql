--------------------------------------------------------
--  DDL for Package PAY_ARCHIVER_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ARCHIVER_REPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: pyempdtl.pkh 120.0.12010000.1 2008/07/27 22:31:35 appldev ship $ */
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

    Name        : pay_archiver_report_pkg

    Description : Package for Employee Periodic Report. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML
                      - CSV

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----------- ----      ------  -------   -----------
     06-Mar-2002 ekim      115.0             Created.
     24-Mar-2002 ahanda    115.1             Fixed GSCC warnings.
     01-Apr-2002 ekim      115.2             Removed p_is_city_mandatory
                                             parameter from archiver_extract.
     15-Apr-2002 ekim      115.3             Removed p_is_county_mandatory.
     13-Jun-2003 ekim      115.4             Fixed GSCC warnings.

*/

  PROCEDURE archiver_extract
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
             ,p_business_group_id         in  number
             ,p_beginning_date            in  varchar2
             ,p_end_date                  in  varchar2
             ,p_jurisdiction_level        in  varchar2
             ,p_detail_level              in  varchar2
             ,p_is_byRun                  in  varchar2
             ,p_organization_id           in  number
             ,p_location_id               in  number
             ,p_is_summary                in  varchar2
             ,p_is_state                  in  varchar2
             ,p_state_id                  in  varchar2
             ,p_is_county                 in  varchar2
             ,p_is_state_mandatory        in  varchar2
             ,p_county_id                 in  varchar2
             ,p_is_city                   in  varchar2
             ,p_city_id                   in  varchar2
             ,p_is_school                 in  varchar2
             ,p_school_id                 in  varchar2
             ,p_payroll_id                in  number
             ,p_consolidation_set_id      in  number
             ,p_tax_unit_id               in  varchar2
             ,p_assignment_set_id         in  number
             ,p_output_file_type          in  varchar2
             );

end pay_archiver_report_pkg;

/
