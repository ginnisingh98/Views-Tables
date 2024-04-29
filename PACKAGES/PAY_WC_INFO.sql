--------------------------------------------------------
--  DDL for Package PAY_WC_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_WC_INFO" AUTHID CURRENT_USER AS
/* $Header: pyuswcfn.pkh 120.0 2005/05/29 10:13:33 appldev noship $ */
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

    Name        : PAY_WC_INFO

    Description : Called from the Workers Comp Formula.

    Uses        :

    Change List
    -----------
     Date        Name     Vers    Bug No     Description
     ----        ----     ------  ------     -----------
     15-OCT-2000 hmaclean 115.0              Created.

*/

FUNCTION get_wc_carrier(  p_assignment_id IN NUMBER )
RETURN NUMBER;

END PAY_WC_INFO;

 

/
