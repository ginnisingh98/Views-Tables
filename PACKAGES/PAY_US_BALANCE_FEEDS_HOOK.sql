--------------------------------------------------------
--  DDL for Package PAY_US_BALANCE_FEEDS_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_BALANCE_FEEDS_HOOK" AUTHID CURRENT_USER AS
/* $Header: pyuspbfr.pkh 120.0 2006/03/05 22:07:13 rdhingra noship $ */
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

    Name        : PAY_US_BALANCE_FEEDS_HOOK
    File Name   : pyuspbfr.pkb

    Description : This package is called from the AFTER INSERT User Hook.
                  The following are the functionalities present in this
		  User Hook

                  1. Puts time_definition_type as 'G' in pay_element_types_f
		     whenever that element feeds a balance for which defined
		     balance exists with dimensions:
		     _ASG_GRE_TD_RUN
		     _ASG_GRE_TD_BD_RUN

    Change List
    -----------
    Name           Date          Version Bug      Text
    -------------- -----------   ------- -------  -----------------------------
    rdhingra       06-MAR-2006   115.0   5073515  Created

******************************************************************************/


/******************************************************************************
   Name           : INSERT_USER_HOOK (After Insert User Hook Call)
   User Hook Type : This is AFTER INSERT Row Level handler User Hook and is
                    called from user hook provided in PAY_BALANCE_FEEDS_API.
                    (PAY_PBF_RKI.AFTER_INSERT)
   Description    : This is a generalized USER HOOK at Balance Feeds level.
                    Any functionality to be implemented via Balance Feeds User
		    Hook can be added in this User Hook as a Procedural call
		    to a procedure implemented in this package.
******************************************************************************/
PROCEDURE INSERT_USER_HOOK(
   p_effective_date     IN  DATE
  ,p_balance_type_id	IN  NUMBER
  ,p_input_value_id	IN  NUMBER
  ,p_scale		IN  NUMBER    DEFAULT NULL
  ,p_business_group_id  IN  NUMBER    DEFAULT NULL
  ,p_legislation_code	IN  VARCHAR2  DEFAULT NULL
  );


END PAY_US_BALANCE_FEEDS_HOOK;

 

/
