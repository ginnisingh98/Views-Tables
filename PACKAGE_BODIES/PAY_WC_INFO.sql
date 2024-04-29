--------------------------------------------------------
--  DDL for Package Body PAY_WC_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_WC_INFO" AS
/* $Header: pyuswcfn.pkb 120.0 2005/05/29 10:13:22 appldev noship $ */
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

  FUNCTION get_wc_carrier( p_assignment_id IN NUMBER )
  RETURN NUMBER IS

     cursor c_get_carrier_id is
       select wci.org_information8
       from per_assignments_f           asg,
            hr_soft_coding_keyflex      flx,
            hr_organization_information wci
       where p_assignment_id                 = asg.assignment_id
         and asg.soft_coding_keyflex_id      = flx.soft_coding_keyflex_id
         and wci.organization_id             = flx.segment1
         and wci.org_information_context||'' = 'State Tax Rules';

     l_carrier_id  NUMBER;

   BEGIN

     open  c_get_carrier_id;
     fetch c_get_carrier_id into l_carrier_id;
     close c_get_carrier_id;

     IF l_carrier_id IS NULL THEN
        l_carrier_id := -10000;
     END IF;

     RETURN l_carrier_id;

   END get_wc_carrier;

END PAY_WC_INFO;

/
