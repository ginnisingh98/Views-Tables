--------------------------------------------------------
--  DDL for Package PER_MX_SSAFFL_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MX_SSAFFL_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: pemxssrp.pkh 115.1 2004/05/16 18:43:32 kthirmiy noship $ */
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

    Name        : per_mx_ssaffl_extract_pkg

    Description : Package for the SS Affiliation Reports. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML
                      - CSV

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     07-MAY-2004 kthirmiy    115.0             Created.

*/

  PROCEDURE ssaffl_extract
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
             ,p_business_group_id         in  number
             ,p_tax_unit_id               in  number
             ,p_affl_type                 in  varchar2
             ,p_output_file_type          in  varchar2
             );


  FUNCTION formated_data_string
             (p_input_string     in varchar2
             )
  RETURN VARCHAR2 ;


end per_mx_ssaffl_extract_pkg;

 

/
