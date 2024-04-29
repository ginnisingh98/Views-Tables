--------------------------------------------------------
--  DDL for Package PAY_US_RSRW_UPGREV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_RSRW_UPGREV" AUTHID CURRENT_USER AS
/* $Header: payusrsrwupg.pkh 120.0.12010000.4 2009/07/06 05:43:46 sudedas noship $ */

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

    Name        : pay_us_rsrw_upgrev

    Description : This package is called by a concurrent program.
                  In this package we upgrade Old Seeded Earnings
                  Elements "Regular Salary" and "Regular Wages"
                  to New Architecture (with Enabled Functionality
                  of Core Proration) for US Legislation.

                  NOTE : Customer needs to Re-Compile Fast Formula
                 'REGULAR_SALARY', 'REGULAR_WAGES' after Upgradation.

    Change List
    -----------
        Date       Name     Ver     Bug No    Description
     ----------- -------- -------  ---------  -------------------------------
     11-Aug-2008 sudedas  115.0    5895804
                                   3556204
                                ER 3855241    Created.
     27-Apr-2009 sudedas  115.1    8464127    Added functions get_upgrade_flag
                                              and get_payprd_per_fiscal_yr.
     22-Jun-2009 sudedas  115.2               Added fnc get_assignment_status.
     06-Jul-2009 sudedas  115.3    8637053    Added context element_type_id to
                                              function get_payprd_per_fiscal_yr

******************************************************************************/

/*****************************************************************************
  Name        : upgrade_reg_salarywages

  Description : This Procedure is responsible for Upgrading Seeded Earnings
                Elements "Regular Salary" or, "Regular Salary" depending on
                the parameter passed p_ele_name. This would be called by
                Concurrent Program "Upgrade Seeded Earnings Element for US"
                and later will be converted into Generic Upgrade Mechanism
*****************************************************************************/

PROCEDURE upgrade_reg_salarywages(errbuf out nocopy varchar2
                                 ,retcode out nocopy number);

/*****************************************************************************
  Name        : revert_upg_reg_salarywages

  Description : This Procedure is responsible for Reverting Back the Upgradation
                of Seeded Earnings Elements "Regular Salary" and "Regula Wages"
                done by the earlier Upgradation Process. This is called by
                Concurrent Program "Revert back upgradation of Seeded Earnings
                Elements for US" and a temporary arrangement. This will be
                removed once the program will be transferred to Generic Upgrade
                Mechanism.
*****************************************************************************/

PROCEDURE revert_upg_reg_salarywages(errbuf out nocopy varchar2
                                    ,retcode out nocopy number);

/*****************************************************************************
  Name        : get_upgrade_flag

  Description : This Function checks record from pay_upgrade_status and
                pay_upgrade_definitions tables for Upgrade of seeded
                Regular Earnings elements "Regular Salary" and "Regular
                Wages" and return 'Y' or 'N' to be used by respective
                Fast Formula to determine what logic is to be used.
*****************************************************************************/

FUNCTION get_upgrade_flag(p_ctx_ele_typ_id IN NUMBER) RETURN VARCHAR2;

/*****************************************************************************
  Name        : get_payprd_per_fiscal_yr

  Description : This Function returns number of pay periods in the current
                fiscal year. This can be different from standard number
                of pay periods per fiscal year especially in case of
                "Weekly" and "Bi-Weekly" payroll.
*****************************************************************************/

FUNCTION get_payprd_per_fiscal_yr(p_ctx_bg_id in number
                                 ,p_ctx_payroll_id in number
                                 ,p_eletyp_ctx_id in number
                                 ,p_period_end_date in date) RETURN NUMBER;

/*****************************************************************************
  Name        : get_assignment_status

  Description : This function checks system status type for assignment
                effective on the prorate_end date passed to it as parameter.
*****************************************************************************/

FUNCTION get_assignment_status(p_ctx_asg_id IN NUMBER
                              ,p_prorate_end_dt IN DATE) RETURN VARCHAR2;

end pay_us_rsrw_upgrev;

/
