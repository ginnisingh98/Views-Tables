--------------------------------------------------------
--  DDL for Package PAY_PAYSLIP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYSLIP_UTIL" AUTHID CURRENT_USER as
/* $Header: paypaysliputil.pkh 120.1.12010000.2 2009/03/31 10:18:01 sudedas ship $ */
--
/*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Description: This package is used for all functions and procedures
                for Online Payslip for all legislations.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   02-FEB-2004  vpandya     115.0            Created.
   26-JUN-2006  sodhingr    115.1 5033776    added new function, get_leg_rule_state
   31-MAR-2009  sudedas     115.2 3816988    Introduced new parameter p_effective_date
                                             for function get_id_for_employer_address
*/
--

  FUNCTION get_legislation_code( p_business_group_id   in number )
  RETURN VARCHAR2;

  FUNCTION get_id_for_employer_address( p_business_group_id in number
                                       ,p_tax_unit_id       in number
                                       ,p_organization_id   in number
                                       ,p_effective_date    in date default fnd_date.canonical_to_date('1990/01/01'))
  RETURN NUMBER;

  FUNCTION get_leg_rule_state( p_business_group_id   in number)
  RETURN VARCHAR2 ;

  gv_legislation_code varchar2(30) := NULL;
  gv_employer_addr_cd varchar2(30) := NULL;

end pay_payslip_util;

/
