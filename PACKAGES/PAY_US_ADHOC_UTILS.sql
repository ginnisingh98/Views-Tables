--------------------------------------------------------
--  DDL for Package PAY_US_ADHOC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_ADHOC_UTILS" AUTHID CURRENT_USER as
/* $Header: pyusdisc.pkh 120.2 2005/06/03 06:49:46 sdhole noship $ */
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


    Name        : PAY_US_ADHOC_UTILS

    Description : This package is created for the discoverer W2
		  (Year End) Reporting purpose for getting the
		  details about common pay agent, locality name
		  In future we can use the same package by adding
		  more functions, for the other reporting purpose.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -----------------------------------
    09-NOV-2004 sdhole     115.0            Created.
    09-NOV-2004 sdhole     115.1            Added function
					    get_secprofile_bg_id.
    26-APR-2005 sdhole     115.3   4226022  Removed the code added in 115.2
                                            version and it has been moved
					    to PAY_ADHOC_UTILS_PKG.
    26-APR-2005 sdhole     115.4   4226022  Added global valrables and function
                                            get_balance_valid_load_date
    30-MAY-2005 sdhole     115.5   4400526  Modified get_balance_valid_load_date
                                            function.
    03-JUN-2005 sdhole     115.6   4400526  Code for the function
                                            get_balance_valid_load_date moved to
                                            PAY_ADHOC_UTILS_PKG. No longer needed
                                            in US utils package.
    ---------------------------------------------------------------------------
*/
--
--
function get_locality_name(p_tax_type        VARCHAR2,
                           p_state_abbrev    VARCHAR2,
                           p_assig_action_id NUMBER,
                           p_locality_name   VARCHAR2,
                           p_jurisdiction    VARCHAR2) return varchar2;
--
--
function get_common_pay_agent_id(p_year varchar2) return number;
--
--
function get_commonpay_agent_details(p_year varchar2,
                                     p_commonpay_agent_id number,
                                     p_type varchar2) return varchar2 ;
--
--
FUNCTION get_secprofile_bg_id
            RETURN   per_security_profiles.business_group_id%TYPE;
--
--
END PAY_US_ADHOC_UTILS;

 

/
