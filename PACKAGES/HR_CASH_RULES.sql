--------------------------------------------------------
--  DDL for Package HR_CASH_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CASH_RULES" AUTHID CURRENT_USER as
/* $Header: pycshrle.pkh 115.0 99/07/17 05:55:30 porting ship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1993 Oracle Corporation UK Ltd.,                *
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

 ======================================================================


 Change List
 ===========

 Version Date       Author    ER/CR No. Description of Change
 -------+---------+----------+---------+-------------------------------
 3.0     11/03/93  H.MINTON            Added copyright and exit line
110.1  19-mar-98   WMcVeagh            Change create or replace 'as' not 'is'
 ----------------------------------------------------------------------
*/
/*
 * ---------------------------------------------------------------------------
   Copyright (c) Oracle Corporation (UK) Ltd 1992.
   All Rights Reserved.
  --
  --
  PRODUCT
    Oracle*Payroll
  NAME
    hr_cash_rules (hrpca.pkh)
  NOTES
     Package available to user for implementation of cash analysis rules.
  USAGE
    See hrpca.pkb
  MODIFIED
    --
    amcinnes    28-JAN-1993  Created
  --
  ---------------------------------------------------------------------------
*/
  procedure user_rule(cash_rule in varchar2);
  --
end hr_cash_rules;

 

/
