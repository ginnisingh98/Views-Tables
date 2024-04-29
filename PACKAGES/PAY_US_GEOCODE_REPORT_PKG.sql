--------------------------------------------------------
--  DDL for Package PAY_US_GEOCODE_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_GEOCODE_REPORT_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusgeoa.pkh 120.0.12010000.1 2008/07/27 23:51:31 appldev ship $ */
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

    Name        : pay_us_geocode_report_pkg

    Description : Package for the geocode upgrade reporting
                      - HTML

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     12-SEP-2005 tclewis   115.0             Created.

*/

   PROCEDURE extract_data
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
             ,p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             );
end pay_us_geocode_report_pkg;

/
