--------------------------------------------------------
--  DDL for Package PAY_GROUP_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GROUP_EVENT_PKG" 
/* $Header: pygrpevn.pkh 120.0.12000000.1 2007/04/10 09:56:56 ckesanap noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material AUTHID CURRENT_USER is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_group_event_pkg

    Description : delivery of event qulaifier for group level events
		          criteria , for retro notif

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No  Description
    ----        ----     ----    ------  -----------
    09-APR-2007 ckesanap 120.0  5562866  Copied the file from 11i

  *******************************************************************/
AS


FUNCTION ff_global_check(p_assignment_id in number,
                         p_surrogate_key in number)  return  varchar2;

FUNCTION ff_global_qualifier  return  varchar2;

FUNCTION pay_user_table_check(p_assignment_id in number,
                              p_surrogate_key in number)  return  varchar2;

FUNCTION pay_user_table_qualifier  return  varchar2;

end pay_group_event_pkg;
 

/
