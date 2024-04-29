--------------------------------------------------------
--  DDL for Package PER_PERSON_INFORMATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERSON_INFORMATION" AUTHID CURRENT_USER AS
/* $Header: peperinf.pkh 115.0 2003/04/10 13:07:31 pkakar noship $ */
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

    Name        : per_person_information

    Description : Package for the Person Reports. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
    08-APR-03   pkakar     115.0             File Created
*/

procedure write_data
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
	     ,p_person_id		  in  number);


end per_person_information;

 

/
