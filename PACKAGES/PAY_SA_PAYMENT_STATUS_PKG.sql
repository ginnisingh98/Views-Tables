--------------------------------------------------------
--  DDL for Package PAY_SA_PAYMENT_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SA_PAYMENT_STATUS_PKG" 
/* $Header: pysastat.pkh 120.0.12010000.2 2009/06/09 13:20:18 bkeshary noship $ */
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

    Name        : pay_sa_payment_status_pkg


    Description : Package contains function for checking the status of payment
                  for Saudi Payroll Register

    Uses        :

    Change List
    -----------
    Date          Name     Vers    Bug No  Description
    ----          ----     ----    ------  -----------

    08-Jun-2009 BKeshary   115.0   7648285 Created

   ****************************************************************************/
  AS

  FUNCTION get_sa_payment_status (p_assignment_action_id in number)
  return varchar2;

  --
END PAY_SA_PAYMENT_STATUS_PKG;

/
