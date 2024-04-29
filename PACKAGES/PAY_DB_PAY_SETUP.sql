--------------------------------------------------------
--  DDL for Package PAY_DB_PAY_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DB_PAY_SETUP" AUTHID CURRENT_USER as
/* $Header: pypsetup.pkh 120.0.12010000.1 2008/07/27 23:28:16 appldev ship $ */
--
/*

   ******************************************************************
   *                                                                *
   *  Copyright (C) 1989 Oracle Corporation UK Ltd.,                *
   *                   Richmond, England.                           *
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

    Name        : pay_db_pay_setup

    Description : This package holds building blocks for payroll

    Uses        : hr_elements
                  hr_utility
                  hr_balances
                  hr_payrolls

    Used By     : db_pay_vol_setup

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    22-Dec-92   J.S.Hobbs     3.0                Date Created with ;-
                                                 create_consolidation_set
                                                 create_element
                                                 create_input_value
                                                 create_payroll
                                                 create_balance_type
                                                 create_balance_classification
                                                 create_defined_balance
                                                 set_session_date
                                                 create_owner_definitions
                                                 create_element_link
    19-Jan-93   J.S.Hobbs     3.1                Changed interface to
                                                 create_payroll.
    20-Jan-92   J.S.Hobbs     3.2                Altered interface to allow the
                                                 passing of dates.
    26-Jan-93   J.S.Hobbs     3.3                Changed default of mid point
                                                 offset to -15.
    11-MAR-93   N Khan        3.4                added 'exit' to the end
    27-APR-93   P.K.Attwood   3.5                Added:-
                                                 insert_customize_restriction
                                                 insert_restriction_values
    04-AUG-93   D.E.Saxby     3.6                Removed p_legislation_code
                                                 from create_input_value.
    21-Sep-93   J.S.Hobbs    40.02/     B231     Removed references to
                             30.10               SUPPLEMENTARY_RUN_FLAG.
                                        Re: X12  Added
                                              MULTIPLE_ENTRIES_ALLOWED_FLAG and
                                                  FORMULA_ID to create_element..
    29-Sep-93   J.S.Hobbs    40.03/     X3     Added
                             30.11              ASSIGNMENT_REMUNERATION_FLAG to
                                              create_balance_type.
    08-Oct-93   D.E.Saxby    40.4/               No longer need to supply a
                             30.12               default payment method
                                                 for a payroll.
    28-MAR-94   R.Neale      40.5                Added header info
    31-MAR-94   A.McGhee     40.6                Moved header line into a
						 comment section.
    19-JUN-95   N. Bristow   40.10            Added new parameter to
                                              create_element, to indicate that
                                              its a third party payment.
                                              (p_third_party_pay_only)
    15-JUL-96   S.Sinha       40.11           Added new parameter p_legislation_code
                                              to create_input_value for starup logic.
    29-Apr-01   V.Mehta      115.1            Added support for the following
                                              'new' columns:
                                              retro_summ_ele_id,
                                              iterative_formula_id,
                                              iterative_priority,
                                              process_mode,
                                              grossup_flag,
                                              advance_indicator,
                                              advance_payable,
                                              advance_deduction,
                                              process_advance_entry,
                                              proration_group_id
    03-JAN-02  J.Tomkins     115.2            Added dbdrv information
    23-AUG-02  prsundar      115.4            Modified procedure create_elelment
    					      to suppport the 2 newly added
    					      columns proration_formula_id and
    					      recalc_event_group_id on table
    					      pay_element_types_f as part of
    					      continuous calculation enhancement
    03-OCT-02  M.Reid        115.5            Added uom code parameter to
                                              create balance type
   15-OCT-2002  RThirlby     115.6            Added support for new columns on
                                              table pay_balance types -
                                              balance_category_id, primary_
                                              balance and base_balance - to
                                              create_balance_type procedure.
                                              Added support for save_run_balance
                                              flag on pay_defined_balances to
                                              create_defined_balance, either by
                                              being passed in directly or
                                              defaulted from category and
                                              dimension.
   17-OCT-2002 RThirlby     115.7             Overwrote 115.5 changes made by
                                              M.Reid. Reinserting changes
                                              and correcting version numbers.
   12-MAR-2003 RThirlby     115.8   2831667   New parameter p_warn_error_code
                                              added to create_input_value.
                                              Required for MLS.
   07-JUL-2003 Scchakra     115.9   1253330   Added function
                                              get_default_currency.
   10-JUL-2003 Scchakra     115.10  1253330   Defaulted p_rule_type to 'DC' in
                                              get_default_currency.
   24-MAY-2004 ALogue       115.11  3644216   Support of p_once_each_period_flag
                                              in create_element.
                                                                              */
--.
 -------------------------------- create element -----------------------------
 /*
 NAME
   create_element
 DESCRIPTION
   This is a function that creates an element type according to the parameters
   passed to it.
 NOTES
   If the element to be created is a payroll element then it will also create a
   default PAY_VALUE and status processing rule. Balance feeds will also be
   created for balance fed by the same classification as that of the element.
 */
--
FUNCTION create_element(p_element_name           varchar2,
                        p_description            varchar2 default NULL,
                        p_reporting_name         varchar2 default NULL,
                        p_classification_name    varchar2,
                        p_input_currency_code    varchar2 default NULL,
                        p_output_currency_code   varchar2 default NULL,
                        p_processing_type        varchar2 default 'R',
                        p_mult_entries_allowed   varchar2 default 'N',
                        p_formula_id             number   default NULL,
                        p_processing_priority    number   default NULL,
                        p_closed_for_entry_flag  varchar2 default 'N',
                        p_standard_link_flag     varchar2 default 'N',
                        p_qual_length_of_service number   default NULL,
                        p_qual_units             varchar2 default NULL,
                        p_qual_age               number   default NULL,
                        p_process_in_run_flag    varchar2 default 'Y',
                        p_post_termination_rule  varchar2,
                        p_indirect_only_flag     varchar2 default 'N',
                        p_adjustment_only_flag   varchar2 default 'N',
                        p_add_entry_allowed_flag varchar2 default 'N',
                        p_multiply_value_flag    varchar2 default 'N',
                        p_effective_start_date   date     default NULL,
                        p_effective_end_date     date     default NULL,
                        p_business_group_name    varchar2 default NULL,
                        p_legislation_code       varchar2 default NULL,
                        p_legislation_subgroup   varchar2 default NULL,
                        p_third_party_pay_only   varchar2 default 'N',
                        p_retro_summ_ele_id		number default null,
                        p_iterative_flag                varchar2 default null,
                        p_iterative_formula_id          number default null,
                        p_iterative_priority            number default null,
                        p_process_mode                  varchar2 default null,
                        p_grossup_flag                  varchar2 default null,
                        p_advance_indicator             varchar2 default null,
                        p_advance_payable               varchar2 default null,
                        p_advance_deduction             varchar2 default null,
                        p_process_advance_entry         varchar2 default null,
                        p_proration_group_id            number default null,
                        p_proration_formula_id		number default null,
                        p_recalc_event_group_id		number default null,
                        p_once_each_period_flag         varchar2 default null
)
                                                               RETURN number;
--..
--.
 ---------------------------- create_input_value -----------------------------
 /*
 NAME
   create_input_value
 DESCRIPTION
   This is a function that creates an input value for an element according to
   the parameters passed to it.
 NOTES
   If the input value is a PAY_VALUE then balance feeds fed by the same
   classification as that of the element will be created.
 */
--
FUNCTION create_input_value(p_element_name           varchar2,
                            p_name                   varchar2,
                            p_uom                    varchar2 default null,
                            p_uom_code               varchar2 default null,
                            p_mandatory_flag         varchar2 default 'N',
                            p_generate_db_item_flag  varchar2 default 'N',
                            p_default_value          varchar2 default NULL,
                            p_min_value              varchar2 default NULL,
                            p_max_value              varchar2 default NULL,
                            p_warning_or_error       varchar2 default NULL,
                            p_warn_or_error_code     varchar2 default NULL,
                            p_lookup_type            varchar2 default NULL,
                            p_formula_id             number   default NULL,
                            p_hot_default_flag       varchar2 default 'N',
                            p_display_sequence       number,
                            p_business_group_name    varchar2 default NULL,
                            p_effective_start_date   date     default NULL,
                            p_effective_end_date     date     default NULL,
                            p_legislation_code       varchar2 default NULL)
                                                               RETURN number;
--..
--.
 -------------------------------- create_payroll -----------------------------
 /*
 NAME
   create_payroll
 DESCRIPTION
   This function creates a payroll and passes back the payroll_id for future
   reference.
 NOTES
   On creation it will create a calendar for the payroll.
 */
--
FUNCTION create_payroll(p_payroll_name               varchar2,
                        p_number_of_years            number,
                        p_period_type                varchar2,
                        p_first_period_end_date      date,
                        p_dflt_payment_method        varchar2 default NULL,
                        p_pay_date_offset            number   default 0,
                        p_direct_deposit_date_offset number   default 0,
                        p_pay_advice_date_offset     number   default 0,
                        p_cut_off_date_offset        number   default 0,
                        p_consolidation_set_name     varchar2,
                        p_negative_pay_allowed_flag  varchar2 default 'N',
                        p_organization_name          varchar2 default NULL,
                        p_midpoint_offset            number   default 0,
                        p_workload_shifting_level    varchar2 default 'N',
                        p_cost_all_keyflex_id        number   default NULL,
                        p_gl_set_of_books_id         number   default NULL,
                        p_soft_coding_keyflex_id     number   default NULL,
                        p_effective_start_date       date     default NULL,
                        p_effective_end_date         date     default NULL,
                        p_business_group_name        varchar2)
                                                           RETURN number;
--..
--.
 ---------------------------- create_consoldation_set ------------------------
 /*
 NAME
   create_consoldation_set
 DESCRIPTION
   This function creates a consolidation set and passes back the
   consolidation_set_id for future use.
 NOTES
 */
--
FUNCTION create_consolidation_set(p_consolidation_set_name  varchar2,
                                  p_business_group_name     varchar2)
                                                              RETURN number;
--..
--.
 -------------------------- create_owner_definitions --------------------------
 /*
 NAME
   create_owner_definitions
 DESCRIPTION
   This procedure populates the product name for the current session into the
   owner defintions table. This mis used when creating startup data to
   identify which products the data is for.
 NOTES
 */
--
PROCEDURE create_owner_definitions(p_app_short_name  varchar2);
--..
--.
 -------------------------- set_session_dates ---------------------------------
 /*
 NAME
   set_session_date
 DESCRIPTION
   Sets the session date for use in creating date tracked information
 NOTES
 */
--
PROCEDURE set_session_date(p_session_date  date);
--..
--.
 -------------------------- create_element_link -------------------------------
 /*
 NAME
   create_element_link
 DESCRIPTION
   This procedure creates sn element link for an element type.
 NOTES
 */
--
FUNCTION create_element_link(p_payroll_name          varchar2 default NULL,
                             p_job_name              varchar2 default NULL,
                             p_position_name         varchar2 default NULL,
                             p_people_group_name     varchar2 default NULL,
                             p_cost_all_keyflex_id   number   default NULL,
                             p_organization_name     varchar2 default NULL,
                             p_element_name          varchar2,
                             p_location_id           number   default NULL,
                             p_grade_name            varchar2 default NULL,
                             p_balancing_keyflex_id  number   default NULL,
                             p_element_set_id        number   default NULL,
                             p_costable_type         varchar2 default 'N',
                             p_link_to_all_pyrlls_fl varchar2 default 'N',
                             p_multiply_value_flag   varchar2 default 'N',
                             p_standard_link_flag    varchar2 default NULL,
                             p_transfer_to_gl_flag   varchar2 default 'N',
                             p_qual_age              number   default NULL,
                             p_qual_lngth_of_service number   default NULL,
                             p_qual_units            varchar2 default NULL,
                             p_effective_start_date  date     default NULL,
                             p_effective_end_date    date     default NULL,
                             p_business_group_name   varchar2)
                                                            RETURN number;
--..
--.
 --------------------------- create_balance_type ------------------------------
 /*
 NAME
   create_balance_type
 DESCRIPTION
   Creates a new balance.
 NOTES
 */
--
FUNCTION create_balance_type(p_balance_name          varchar2,
                             p_uom                   varchar2,
                             p_uom_code              varchar2 default NULL,
                             p_ass_remuneration_flag varchar2 default 'N',
                             p_currency_code         varchar2 default NULL,
                             p_reporting_name        varchar2 default NULL,
                             p_business_group_name   varchar2 default NULL,
                             p_legislation_code      varchar2 default NULL,
                             p_legislation_subgroup  varchar2 default NULL,
                             p_balance_category      varchar2 default null,
                             p_bc_leg_code           varchar2 default null,
                             p_effective_date        date     default null,
                             p_base_balance_name     varchar2 default null,
                             p_primary_element_name  varchar2 default null,
                             p_primary_iv_name       varchar2 default null)
                                                              RETURN number;
--..
--.
 ----------------------- create_balance_classification ------------------------
 /*
 NAME
   create_balance_classification
 DESCRIPTION
   This procedure adds a new classification to the balance.
 NOTES
   Balance feeds will be created for any elements with a PAY VALUE that matches
   the balance.
 */
--
PROCEDURE create_balance_classification
                          (p_balance_name            varchar2,
                           p_balance_classification  varchar2,
                           p_scale                   varchar2,
                           p_business_group_name     varchar2 default NULL,
                           p_legislation_code        varchar2 default NULL);
--..
--.
 --------------------------- create_defined_balance ---------------------------
 /*
 NAME
   create_defined_balance
 DESCRIPTION
   Associates a balance with a dimension.
 NOTES
 */
--
PROCEDURE create_defined_balance
                          (p_balance_name            varchar2,
                           p_balance_dimension       varchar2,
                           p_frce_ltst_balance_flag  varchar2 default 'N',
                           p_business_group_name     varchar2 default NULL,
                           p_legislation_code        varchar2 default NULL,
                           p_save_run_bal            varchar2 default null,
                           p_effective_date          date     default null);
--..

--.
------------------------ insert_customize_restriction ------------------------
/*
 NAME
   insert_customize_restriction
 DESCRIPTION
   Creates a new customize restriction type.
 NOTES
   This function returns the customized_restriction_id of the row it has
   created and inserted into pay_customized_restrictions.
 */
--
FUNCTION insert_customize_restriction
                     ( p_business_group_id     number default NULL,
                       p_name                  varchar2,
                       p_form_name             varchar2,
                       p_query_form_title      varchar2,
                       p_standard_form_title   varchar2,
                       p_enabled_flag          varchar2 default 'N',
                       p_legislation_subgroup  varchar2 default NULL,
                       p_legislation_code      varchar2 default NULL
                     ) return number;
--
------------------------- insert_restriction_values --------------------------
 /*
 NAME
   insert_restriction_values
 DESCRIPTION
   This procedure adds a new restriction value for the specified customization
   restriction.
 NOTES */
--
PROCEDURE insert_restriction_values
                     ( p_customized_restriction_id number,
                       p_restriction_code          varchar2,
                       p_value                     varchar2
                     );

--..
--.
------------------------ get_default_currency ------------------------
/*
 NAME
   get_default_currency
 DESCRIPTION
   Fetches the default currency for a given legislation.
 NOTES
   This function returns the default currency code from the 'DC'
   legislation rule. If not found then fetches the enabled currency
   from fnd_currencies table.
 */
--
FUNCTION get_default_currency
  (p_rule_type        in varchar2 default 'DC'
  ,p_legislation_code in varchar2
  ) return varchar2;

--..

end pay_db_pay_setup;

/
