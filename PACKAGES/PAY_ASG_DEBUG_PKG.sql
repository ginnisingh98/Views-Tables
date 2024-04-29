--------------------------------------------------------
--  DDL for Package PAY_ASG_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ASG_DEBUG_PKG" AUTHID CURRENT_USER AS
/* $Header: pyacdebg.pkh 120.1 2005/10/05 03:01:37 schauhan noship $ */
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

    Name        : pay_asg_debug_pkg

    Description : Package for the Elements Reports. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
    15-MAR-02    rsirigir  115.0   2254026   GSCC Compliance inclusions
*/

procedure write_data
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
	     ,p_assignment_id		  in  number);


end pay_asg_debug_pkg;

 

/
