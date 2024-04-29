--------------------------------------------------------
--  DDL for Package PYUSEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYUSEXC" AUTHID CURRENT_USER AS
/* $Header: pyusexc.pkh 120.0 2005/05/29 02:19:28 appldev noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
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

    Name        : pyusexc.pkb

    Description : PaYroll US legislation EXpiry Checking code.
                  Contains the expiry checking code associated with the US
                  balance dimensions.  Following the change
                  to latest balance functionality, these need to be contained
                  as packaged procedures.

    Change List
    -----------
    Date        Name       Vers   Bug No  Description
    ----------- ---------- ------ ------- --------------------------------------
    30-JUL-1996 J ALLOUN                  Added error handling.
    12-aug-2000 d Joshi                   Added the date_ec overloaded function
                                          for as per the requirement of balance
                                          adjustment
    14-MAR-2005 Saurgupt                  Make the gscc changes.
    18-MAY-2005 ahanda      115.3         Added procedure start_tdptd_date.

*/

PROCEDURE date_ec
(
   p_owner_payroll_action_id    in     number,   -- run created balance.
   p_user_payroll_action_id     in     number,   -- current run.
   p_owner_assignment_action_id in     number,   -- assact created balance.
   p_user_assignment_action_id  in     number,   -- current assact..
   p_owner_effective_date       in     date,     -- eff date of balance.
   p_user_effective_date        in     date,     -- eff date of current run.
   p_dimension_name             in     varchar2, -- balance dimension name.
   p_expiry_information            out nocopy number    -- dimension expired flag.
);

PROCEDURE date_ec
(
   p_owner_payroll_action_id    in     number,   -- run created balance.
   p_user_payroll_action_id     in     number,   -- current run.
   p_owner_assignment_action_id in     number,   -- assact created balance.
   p_user_assignment_action_id  in     number,   -- current assact..
   p_owner_effective_date       in     date,     -- eff date of balance.
   p_user_effective_date        in     date,     -- eff date of current run.
   p_dimension_name             in     varchar2, -- balance dimension name.
   p_expiry_information         out  nocopy   date     -- dimension expired date.
);


PROCEDURE start_tdptd_date(p_effective_date IN  DATE
                          ,p_start_date     OUT NOCOPY DATE
                          ,p_payroll_id     IN  NUMBER DEFAULT NULL
                          ,p_bus_grp        IN  NUMBER DEFAULT NULL
                          ,p_asg_action     IN  NUMBER DEFAULT NULL);

end pyusexc;

 

/
