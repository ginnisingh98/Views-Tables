--------------------------------------------------------
--  DDL for Package PAY_CA_YEER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_YEER_PKG" AUTHID CURRENT_USER AS
/* $Header: pycayeer.pkh 120.0.12000000.1 2007/01/17 17:44:36 appldev noship $ */
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

    Name        : pay_ca_yeer_pkg

    Description : Package for the Elements Reports. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML
                      - CSV

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     28-NOV-2000 vpandya   115.0             Created
     10-NOV-2001 vpandya   115.1             Added set veify off at top as per
                                             GSCC
     12-NOV-2001 vpandya   115.2             Added dbdrv line.
     10-AUG-2002 vpandya   115.4             Added OSERROR command at top.
     19-DEC-2002 vpandya   115.5             Added nocopy with out parameter.
     13-NOV-2003 ssouresr  115.6             Passing p_pre instead of p_qin

*/

  PROCEDURE pier_yeer
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
             ,p_reporting_year            in  varchar2
             ,p_pier_yeer                 in  varchar2
             ,p_fed_prov                  in  varchar2
             ,p_gre                       in  number
             ,p_pre                       in  number
             ,p_b_g_id                    in  number
             );


  /**************************************************************
  ** PL/SQL table of records to store archived item name and value
  ** PL/SQL table of records to store messages and required column
  ** name.
  ***************************************************************/
  TYPE rec_dbi  IS RECORD ( dbi_name  varchar2(240),
			    dbi_value  varchar2(240),
		            dbi_short_name  varchar2(240),
			    archive_item_id number(15));
  TYPE tab_mesg IS TABLE OF varchar2(100) INDEX BY BINARY_INTEGER;
  TYPE tab_col_name IS TABLE OF varchar2(240) INDEX BY BINARY_INTEGER;
  TYPE tab_dbi IS TABLE OF rec_dbi INDEX BY BINARY_INTEGER;

end pay_ca_yeer_pkg;

 

/
