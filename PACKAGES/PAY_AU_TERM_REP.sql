--------------------------------------------------------
--  DDL for Package PAY_AU_TERM_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_TERM_REP" AUTHID CURRENT_USER AS
/*  $Header: pyautrm.pkh 120.1.12010000.4 2010/01/29 05:48:02 pmatamsr ship $ */
/*
**
**  Copyright (c) 1999 Oracle Corporation
**  All Rights Reserved
**
**  Procedures and functions used in AU terminations reporting
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  ====================================================
**  05-NOV-2000 rayyadev 115.0     Created.
**  06-NOV-2000 rayyadev 115.1     Changed the Name of the package.
**  07-JUL-2001 apunekar 115.2     Added function to get invalidity balances.
**  10-OCT-2001 ragovind 115.3     Added parameter p_invalidity_component to the
**                                 function ETP_PREPAYMENT_INFORMATION
**  05-DEC-2001 nnaresh  115.5      Updated for GSCC Standards.
**  04-DEC-2002 Ragovind 115.6     Added NOCOPY for the functions etp_payment_information,etp_prepayment_information
**  23-JUL-2003 Nanuradh 115.7     Bug#2984390 - Added an extra parameter to the function ETP_prepayment_information - ETP Pre/post Enhancement
**  21-Nov-2007 tbakashi 115.8     Bug#6470561 - STATUTORY UPDATE: MUTIPLE ETP IMPACT ON TERMINATION REPORT
**  ============== Formula Fuctions ====================
**  Package contains Reporting Details for the Termination
**  report in AU localisatons.
**  07-Sep-2009 pmatamsr 115.9     Bug#8769345 - Added a new function get_etp_pre_post_components
**                                 as part of statutory changes to ETP Super rollover.
**  07-Sep-2009 pmatamsr 115.10    Bug#8769345 - Added two new output parameters for ETP_prepayment_information and ETP_payment_information
**                                 functions.
**  28-Jan-2010 pmatamsr 115.11    Bug#9322314 - Added two new input parameters to function get_etp_pre_post_components.
*/
  --
  -------------------------------------------------------------------------------------------------
  --
  -- FUNCTION ETP_prepayment_information
  --
  -- Returns :
  --           1 if function runs successfully
  --           0 otherwise
  --
  -- Purpose : Return the Values of ETP Prepayment information
  --
  -- In :      p_assignment_id       - assignment which is terminated for
  --                                    which report is requiered
  --           p_Hire_date           - date Of commencement of the assignment
  --           p_Termination_date    - date Of Termination Date
  --
  -- Out :     p_pre_01Jul1983_days   - no Of Days in the Pre Jul 1983
  --           p_post_30jun1983_days  - no Of Days in the Post Jul 1983
  --           p_pre_01jul1983_ratio  -ratio Of Days in the Pre Jul 1983
  --           p_post_30jun1983_ratio -ratio Of Days in the Post Jul 1983
  --           P_Gross_ETP            -gross ETP With out super annuation
  --           P_Maximum_Rollover     -Maximum rollover amount
  --           p_Lump_sum_d           -Lump sum D Tax free amount
  --           P_INVALIDITY_COMPONENT -Invalidity Component amount
  --
  -- Uses :
  --           pay_au_terminations
  --           hr_utility
  --
  ------------------------------------------------------------------------------------------------

  function ETP_prepayment_information
  (p_assignment_id        in  number
  ,P_hire_date            in  Date
  ,p_Termination_date      in  date
  ,P_Assignment_action_id in Number
  ,p_pre_01Jul1983_days   out NOCOPY number
  ,p_post_30jun1983_days  out NOCOPY number
  ,p_pre_01jul1983_ratio  out NOCOPY number
  ,p_post_30jun1983_ratio out NOCOPY number
  ,P_Gross_ETP            out NOCOPY number
  ,P_Maximum_Rollover     out NOCOPY number
  ,p_Lump_sum_d           out NOCOPY number
  ,p_invalidity_component out NOCOPY number
  ,p_etp_service_date     out NOCOPY date        /* Bug#2984390 */
  ,p_taxable_max_rollover out NOCOPY number /* Start 8769345 */
  ,p_tax_free_max_rollover out NOCOPY number  /* End 8769345 */

  ) return number;

  function ETP_payment_information
  (p_assignment_id        in  number
  ,P_hire_date            in  Date
  ,p_Termination_date      in  date
  ,P_Assignment_action_id in Number
  ,P_transitional       in varchar2            /* 6470561 */
  ,P_ETP_Payment            out NOCOPY number
  ,P_superAnnuation_rollover    out NOCOPY number
  ,p_Lump_sum_d           out NOCOPY number
  ,P_ETP_TAX              out NOCOPY number
  ,p_invalidity_component out NOCOPY number    /* 6470561 */
  ,p_taxable_rollover     out NOCOPY number   /* Start 8769345 */
  ,p_tax_free_rollover    out NOCOPY number   /* End 8769345 */
  )
return number ;

--function to get the invalidity balance
function get_invalidity_pay_bal(p_assignment_action_id in number,
                                p_assignment_id  in number
                                  )  return number;

/* Bug 8769345 - Added new function which will be called from Termination report to retrieve
                 the values of taxable and tax-free components after rollover for transitional ETP */

/* Bug 9322314 - Added two input parameters to the function to pass pre and post '83 ratios
                 for calculating ETP taxable and tax free components */

function get_etp_pre_post_components(p_assignment_action_id in    number,
                                       p_assignment_id        in    number,
                                       p_pre_jul83_ratio      in    number,
                                       p_post_jun83_ratio     in    number,
                                       p_etp_tax_free_amt   out nocopy number,
                                       p_etp_taxable_amt     out nocopy number
                                       ) return number ;

end pay_au_term_rep;

/
