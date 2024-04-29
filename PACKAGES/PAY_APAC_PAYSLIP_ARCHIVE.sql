--------------------------------------------------------
--  DDL for Package PAY_APAC_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_APAC_PAYSLIP_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pyapacps.pkh 120.1 2006/12/13 07:49:41 aaagarwa noship $ */
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

    Name        : pay_apac_payslip_archive

    Description : This is a common package to archive the payroll
                  action level data for APAC countries SS payslip.
                  Different procedures defined are called by the
                  APAC countries legislative Payslip Data Archiver.



    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    22-APR-2002 kaverma   115.0            Created.
    23-APR-2002 kaverma   115.1   2306309  Changes after code review comments
    30-APR-2002 kaverma   115.2   2306309  added p_archive to get_eit_definitions
    02-MAY-2002 kaverma   115.3            added range_code procedure
    03-NOV-2002 Ragovind  115.4   2689226  Added NOCOPY for function get_legislative_parameters.
    19-Apr-2004 bramajey  115.5   3578040  Renamed procedure range_code to
                                           archive_payroll_level_data
    04-May-2004 bramajey  115.6   3604206  Reverted back changes done for bug 3578040
    02-Jul-2004 punmehta  115.7   3731940  Modified for GSCC warnings
    12-Dec-2006 aaagarwa  115.8   5048802  Added deinitialization_code
*******************************************************************/


TYPE balance_rec IS RECORD (
  balance_type_id      NUMBER,
  balance_dimension_id NUMBER,
  defined_balance_id   NUMBER,
  balance_narrative    VARCHAR2(150),
  balance_name         pay_balance_types.reporting_name%TYPE,
  database_item_suffix pay_balance_dimensions.database_item_suffix%TYPE,
  legislation_code     pay_balance_dimensions.legislation_code%TYPE);

TYPE element_rec IS RECORD (
  element_type_id      NUMBER,
  input_value_id       NUMBER,
  formula_id           NUMBER,
  element_narrative    VARCHAR2(100));


TYPE balance_table   IS TABLE OF balance_rec   INDEX BY BINARY_INTEGER;
TYPE element_table   IS TABLE OF element_rec   INDEX BY BINARY_INTEGER;

g_user_balance_table              balance_table;
g_element_table                   element_table;

g_max_user_element_index          PLS_INTEGER; --3731940
g_max_user_balance_index          PLS_INTEGER; -- 3731940


g_balance_context        VARCHAR2(30); --3731940
g_element_context        VARCHAR2(30);

g_bg_context             VARCHAR2(30); --3731940


-- Bug 3604206

/*********************************************************************
   Name      : range_code
   Purpose   : Calls private procedure the process_eit to archive the EIT details and
               also archives the payroll level data  -
               Messages and Emploer address details.
  *********************************************************************/

PROCEDURE range_code(p_payroll_action_id IN pay_payroll_actions.payroll_action_id%TYPE);



/*********************************************************************
   Name      : initialization_code
   Purpose   : Calls the private procedure process_eit to populate EIT values into
               golbal tables.
  *********************************************************************/

PROCEDURE initialization_code(p_payroll_action_id IN pay_payroll_actions.payroll_action_id%type);



/*********************************************************************
   Name      : archive_user_elements
   Purpose   : Archives the EIT values for input values defined in the
               EIT definition
  *********************************************************************/

PROCEDURE archive_user_elements(p_arch_assignment_action_id  IN NUMBER,
                                p_pre_assignment_action_id   IN NUMBER,
                                p_latest_run_assact_id       IN NUMBER,
                                p_pre_effective_date	     IN DATE);



/*********************************************************************
   Name      : archive_user_balances
   Purpose   : Archives the EIT values for the defined balances dimension
  *********************************************************************/

PROCEDURE archive_user_balances(p_arch_assignment_action_id IN NUMBER,
                                p_run_assignment_action_id  IN NUMBER,
                                p_pre_effective_date	    IN DATE);



/*********************************************************************
   Name      : get_eit_definitions
   Purpose   : Archives the payroll level information ofuser defined
               elements and balances defined using EIT
  *********************************************************************/


PROCEDURE get_eit_definitions(p_payroll_action_id         IN  NUMBER,
	    	              p_business_group_id    	  IN  NUMBER,
	   	              p_pre_payroll_action_id	  IN  NUMBER,
	   	              p_pre_effective_date        IN  DATE,
                              p_archive                   IN  VARCHAR2 );



  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : DEINITIALIZATION_CODE                               --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to archive the PA level data if quick     --
  --                  archive has been run.                               --
  --                  called are                                          --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id          NUMBER                 --
  --            OUT : N/A                                                 --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 06-Dec-2006    aaagarwa   Initial Version                      --
  --------------------------------------------------------------------------
  PROCEDURE deinitialization_code
    (
      p_payroll_action_id    IN  NUMBER
    );

/*********************************************************************
   Name      : get_legislative_parameters
   Purpose   : gets the value of legislative parameters from the
               Archive run.
  *********************************************************************/


PROCEDURE get_legislative_parameters(p_payroll_action_id    IN pay_payroll_actions.payroll_action_id%type,
                                     p_payroll_id	    OUT NOCOPY NUMBER,
                                     p_consolidation	    OUT NOCOPY NUMBER,
                                     p_business_group_id    OUT NOCOPY NUMBER,
                                     p_start_date	    OUT NOCOPY VARCHAR2,
				     p_end_date 	    OUT NOCOPY VARCHAR2);


END pay_apac_payslip_archive;

/
