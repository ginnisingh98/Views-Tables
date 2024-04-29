--------------------------------------------------------
--  DDL for Package PAY_US_GARN_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_GARN_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: pyusgrup.pkh 120.0.12000000.1 2007/01/18 02:34:46 appldev noship $ */

/******************************************************************************
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

    Name        : pay_us_garn_upgrade

    Description : This package is called by a concurrent program.
                  In this package we upgrade all old architectural
                  Garnishment Elements to New architecture.

                  NOTE : Customer needs to recompile all uncompiled
                         formulas after running the Upgrade Process.

    Change List
    -----------
        Date       Name     Ver     Bug No    Description
     ----------- -------- -------  ---------  -------------------------------
     30-Sep-2004 kvsankar  115.0    3549298   Created.

******************************************************************************/

PROCEDURE upgrade_garnishment
           (p_elem_type_id in number);

PROCEDURE qual_elem_upg(p_object_id varchar2,
                        p_qualified    out nocopy varchar2);

end pay_us_garn_upgrade;

 

/
