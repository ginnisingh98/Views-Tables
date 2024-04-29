--------------------------------------------------------
--  DDL for Package PAY_CA_PAYREG_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_PAYREG_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: pycaprpe.pkh 120.0.12000000.1 2007/01/17 17:14:53 appldev noship $ */
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

    Name        : pay_ca_payreg_extract_pkg

    Description : Package for the Payment Report. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML
                      - CSV

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     10-OCT-2001 ssattini  115.0             Created.
     20-NOV-2001 ssattini  115.1             Added dbdrv line.
     19-DEC-2001 ssattini  115.2             Added checkfile line.
     22-JAN-2003 ssattini  115.3             Added NOCOPY for GSCC.

*/

  PROCEDURE payment_extract
             (errbuf                      out NOCOPY varchar2
             ,retcode                     out NOCOPY number
             ,p_business_group_id         in  number
             ,p_start_date                in  varchar2
             ,p_end_date                  in  varchar2
             ,p_payroll_id                in  number default NULL
             ,p_consolidation_set_id      in  number
             ,p_tax_unit_id               in  number default NULL
	     ,p_payment_type_id           in  number default NULL
	     ,p_payment_method_id         in  number default NULL
             ,p_output_file_type          in  varchar2
             );

end pay_ca_payreg_extract_pkg;

 

/
