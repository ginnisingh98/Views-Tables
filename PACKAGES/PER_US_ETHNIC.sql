--------------------------------------------------------
--  DDL for Package PER_US_ETHNIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_ETHNIC" AUTHID CURRENT_USER AS
/* $Header: peusethnic.pkh 120.0.12000000.1 2007/02/06 14:47:42 appldev noship $ */
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

    Name        : per_us_ethnic

    Description : Package that is used to update ethnic code 9 with
                  ethnic code 3

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
    29-OCT-06    ssouresr  115.0             Created.
*/

PROCEDURE ethnic_code_upd (errbuf     out nocopy varchar2,
                           retcode    out nocopy number);

END per_us_ethnic;

 

/
