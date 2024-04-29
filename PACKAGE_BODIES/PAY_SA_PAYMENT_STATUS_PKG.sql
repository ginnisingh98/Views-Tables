--------------------------------------------------------
--  DDL for Package Body PAY_SA_PAYMENT_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SA_PAYMENT_STATUS_PKG" 
/* $Header: pysastat.pkb 120.0.12010000.1 2009/06/09 10:56:36 bkeshary noship $ */
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

    Name        : pay_sa_payment_status_pkg

    Description : Package contains functions for checking the status of payment
                  for Saudi Payroll Register

    Uses        :

    Change List
    -----------
    Date           Name      Vers    Bug No  Description
    ----           ----      ----    ------  -----------

    08-Jun-2009  BKeshary    115.0    7648285  Created.
  ****************************************************************************/
  AS

  function  get_sa_payment_status  (p_assignment_action_id in number)
   return varchar2 is

   cursor c_purge_run(p_assignment_action_id in number) is
            select 1
              from pay_assignment_actions paa
             where paa.assignment_action_id = p_assignment_action_id
               and not exists
                  (select 1
                     from pay_action_interlocks ai
                    where ai.locking_action_id = paa.assignment_action_id )
               and exists
                   (select 1 from pay_assignment_actions paa2,
                           pay_payroll_actions ppa2
                     where paa2.assignment_id = paa.assignment_id
                       and paa2.payroll_action_id = ppa2.payroll_action_id
                       and ppa2.action_type = 'Z');

   cursor c_get_archived(p_assignment_action_id in number) is
         select count(*)
           from pay_action_information
          where action_context_id = p_assignment_action_id
            and action_information_category = 'EMEA ELEMENT INFO'
			and action_information3 in ('E','D');

   cursor c_get_prepay_id(p_assignment_action_id in number) is
          SELECT paa.assignment_action_id,ppp.pre_payment_id
          FROM pay_action_interlocks pai
             ,pay_assignment_actions paa
             ,pay_payroll_actions ppa
             ,pay_pre_payments ppp
         WHERE    pai.locked_action_id =  paa.assignment_action_id
         AND      paa.payroll_action_id = ppa.payroll_action_id
         AND      ppa.action_type in ('P','U')
         AND      ppa.action_status = 'C'
         AND      paa.assignment_action_id = ppp.assignment_action_id
         AND      pai.locking_action_id = p_assignment_action_id;



   l_purge_run                VARCHAR2(1);
   ln_count                    NUMBER;
   l_status                   VARCHAR2(10);
   l_pre_pay_asg_id           NUMBER;
   l_pre_pay_id               NUMBER;

   begin

     ln_count := 0;

     open c_purge_run(p_assignment_action_id);
            fetch c_purge_run into l_purge_run;
            if c_purge_run%found then
	      open c_get_archived(p_assignment_action_id);
	      fetch c_get_archived into ln_count;
	      /*Check whether archive data exists for this assignment_action_id*/
                 if (ln_count <> 0) then
		  return('Unavailable');
		 end if;
	      close c_get_archived;
	    else
	    open c_get_prepay_id(p_assignment_action_id);
	    fetch c_get_prepay_id into l_pre_pay_asg_id,l_pre_pay_id;
	    /* Fetch the Pre-payment assignmnt action id, pre payment id */
	    if c_get_prepay_id%found then
	      l_status := pay_assignment_actions_pkg.get_payment_status(l_pre_pay_asg_id,l_pre_pay_id);
             return l_status;
	     end if;
	    close c_get_prepay_id;
	   end if;
      close c_purge_run;

  end get_sa_payment_status;

--
END PAY_SA_PAYMENT_STATUS_PKG;

/
