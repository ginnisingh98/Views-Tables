--------------------------------------------------------
--  DDL for Package PN_INDEX_AMOUNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_INDEX_AMOUNT_PKG" AUTHID CURRENT_USER AS
-- $Header: PNINAMTS.pls 120.5 2007/01/30 09:40:09 hrodda ship $

-- +===========================================================================+
-- |                Copyright (c) 2001 Oracle Corporation
-- |                   Redwood Shores, California, USA
-- |                        All rights reserved.
-- +===========================================================================+
-- |  Name
-- |    pn_index_amount_pkg
-- |
-- |  Description
-- |    This package contains procedures used to calculate index amounts.
-- |
-- |
-- |  History
-- | 27-MAR-01 jreyes    Created
-- | 19-JUN-01 jreyes    Adding call to create schedules and items..
-- | 21-JUN-01 jreyes    Adding call to get amount precision from fnd_currency.
-- |                     get_info...
-- | 24-JUN-01 jreyes    Opened increase on types to all payment term types
-- |                     (LOOKUP Code: PN_PAYMENT_TERM_TYPE)
-- | 25-JUl-01 jreyes    Added NVL clause to all cursors that use increase_on
-- |                     of pn_index_leases.
-- | 26-JUl-01 jreyes    Removed CCID parm of PNT_PAYMENT_TERMS_PKG.
-- | 03-AUG-01 jreyes    Incorporated payment aggregation.
-- | 20-SEP-01 psidhu    Added param p_called_from to CREATE_PAYMENT_TERM_RECORD
-- | 05-dec-01 achauhan  In create_payment_term_record added out NOCOPY param
-- |                     op_payment_term_id.
-- | 15-JAN-02 Mrinal    Added dbdrv command.
-- | 01-FEB-02 Mrinal    Added checkfile command.
-- | 06-May-02 psidhu    bug 2356045 - Added parameter p_negative_rent_type to
-- |                     procedure create_payment_terms.
-- | 19-Jul-02 psidhu    bug 2452909. Added procedure process_currency_code.
-- | 01-Aug-02 psidhu    Changes for carry forward funtionality. Added param
-- |                     p_index_period_id, p_carry_forward_flag,
-- |                     op_constraint_applied_amount,op_carry_forward_amount
-- |                     to derive_constrained_rent. Added functions
-- |                     derive_carry_forward_amount, derive_prev_negative_rent,
-- |                     get_increase_over_constraint and get_max_assessment_dt.
-- |                     Added procedure calculate_subsequent_periods.
-- | 17-Oct-02 psidhu    Changes for carry forward funtionality.Removed function
-- |                     derive_carry_forward_amount. Added function
-- |                     derive_cum_carry_forward.Added param
-- |                     op_carry_forward_percent and
-- |                     op_constraint_applied_percent to derive_constrained_rent
-- |                     Added param op_constraint_applied_percent and
-- |                     op_carry_forward_percent to calculate_period.
-- | 06-AUG-04 ftanudja  o add parameter ip_auto_find_sch_day in
-- |                       approve_index_pay_term_batch. #3701195.
-- | 08-OCT-04 stripath  o BUG 3961117, added new param p_calculate_date to
-- |                       create_payment_terms, create_payment_term_record.
-- | 19-OCT-04 stripath  o Added function Get_Calculate_Date.
-- | 19-SEP-05 piagrawa  o Overload Get_Calculate_Date for R12 - use ORG_ID
-- | 05-MAY-06 Hareesha  o Bug # 5115291 Added paramater p_norm_st_date to
-- |                       procedure create_payment_term_record.
-- | 01-Nov-06 Prabhakar o Added parameter p_end_date to create_payment_term_record.
-- | 12-DEC-06 Prabhakar o Added p_prorate_factor parameter to derive_constrined_rent and
-- |                       create_payemnt_terms procedures.
-- +===========================================================================+


   g_currency_code                  pn_index_leases.currency_code%TYPE;
   g_calculate_date                 DATE := TO_DATE('01/01/0001', 'MM/DD/YYYY');
   --
   -- These are constants used throught this package.
   --
   -- BASIS TYPES
   c_basis_type_fixed               CONSTANT CHAR (5)                              := 'FIXED';
   c_basis_type_rolling             CONSTANT CHAR (7)                              := 'ROLLING';
   c_basis_type_compound            CONSTANT CHAR (8)                              := 'COMPOUND';
   -- INCREASE ON
   c_increase_on_base_rent          CONSTANT CHAR (9)                              := 'BASE_RENT';
   c_increase_on_oper_expenses      CONSTANT CHAR (12)                             := 'OPER_EXPENSE';
   c_increase_on_gross              CONSTANT CHAR (5)                              := 'GROSS';
   -- RELATION TYPES
   c_relation_basis_only            CONSTANT CHAR (10)                             := 'BASIS_ONLY';
   c_relation_greater_of            CONSTANT CHAR (10)                             := 'GREATER_OF';
   c_relation_index_only            CONSTANT CHAR (10)                             := 'INDEX_ONLY';
   c_relation_lesser_of             CONSTANT CHAR (9)                              := 'LESSER_OF';
   -- RELATION TYPES
   c_constraint_period_to_period    CONSTANT CHAR (16)                             := 'PERIOD_TO_PERIOD';
   c_constraint_rent_due            CONSTANT CHAR (8)                              := 'RENT_DUE';
   -- INDEX FINDER TYPES
   c_index_finder_backbill          CONSTANT CHAR (8)                              := 'BACKBILL';
   c_index_finder_finder_date       CONSTANT CHAR (11)                             := 'FINDER_DATE';
   c_index_finder_most_recent       CONSTANT CHAR (11)                             := 'MOST_RECENT';
   -- REFERENCE TYPES
   c_ref_period_base_year           CONSTANT CHAR (9)                              := 'BASE_YEAR';
   c_ref_period_prev_year_asmt_dt           CONSTANT CHAR (24)                             := 'PREV_YEAR_ASSMT_DATE_DUR';
   c_ref_period_prev_year_prv_cpi           CONSTANT CHAR (26)                             := 'PREV_YEAR_PREV_CURRENT_CPI';
   -- INVOICE SPREAD TYPES
   c_spread_frequency_monthly       CONSTANT CHAR (3)                              := 'MON';
   c_spread_frequency_one_time      CONSTANT CHAR (2)                              := 'OT';
   c_spread_frequency_quarterly     CONSTANT CHAR (3)                              := 'QTR';
   c_spread_frequency_semiannual    CONSTANT CHAR (2)                              := 'SA';
   c_spread_frequency_annually      CONSTANT CHAR (2)                              := 'YR';
   -- NEGATIVE RENT TYPES
   c_negative_rent_this_period      CONSTANT CHAR (11)                             := 'THIS_PERIOD';
   c_negative_rent_ignore           CONSTANT CHAR (6)                              := 'IGNORE';
   c_negative_rent_next_period      CONSTANT CHAR (11)                             := 'NEXT_PERIOD';
   -- LEASE CLASS
   c_lease_class_direct             CONSTANT CHAR (6)                              := 'DIRECT';
   -- PAYMENT TERM
   c_payment_term_type_index        CONSTANT CHAR (4)                              := 'INDX';
   -- PAYMENT TERM STATUS
   c_payment_term_status_draft      CONSTANT CHAR (5)                              := 'DRAFT';
   c_payment_term_status_approved   CONSTANT CHAR (8)                              := 'APPROVED';
   --ACCOUNT CLASS
   c_account_class_liability        CONSTANT CHAR (3)                              := 'LIA';
   c_account_class_receivable       CONSTANT CHAR (3)                              := 'REC';
   c_account_class_expenses         CONSTANT CHAR (3)                              := 'EXP';
   c_account_class_revenue          CONSTANT CHAR (3)                              := 'REV';
   c_account_class_accurual         CONSTANT CHAR (3)                              := 'ACC';
   c_account_class_unearn           CONSTANT CHAR (6)                              := 'UNEARN';
   --INDEX PAYMENT TERM TYPE
   c_index_pay_term_type_atlst      CONSTANT CHAR (7)                              := 'ATLEAST';
   c_index_pay_term_type_atlst_bb   CONSTANT CHAR (16)                             := 'ATLEAST-BACKBILL';
   c_index_pay_term_type_recur      CONSTANT CHAR (9)                              := 'RECURRING';
   c_index_pay_term_type_backbill   CONSTANT CHAR (8)                              := 'BACKBILL';
   g_include_in_var_rent            VARCHAR2(30)                                   := NULL;
   g_include_in_var_check           VARCHAR2(1)                                    := NULL;
   g_create_terms_ext_period        VARCHAR2(1)                                    := NULL;

   TYPE item_rec IS  RECORD (payment_term_id NUMBER, amount NUMBER);

   item_sum_rec item_rec;

   TYPE item_sum IS TABLE OF item_sum_rec%TYPE
      INDEX BY BINARY_INTEGER;

   item_amt_tab   item_sum;

------------------------------------------------------------------------
-- PROCEDURE : calculate
-- DESCRIPTION: This procedure will perform the following calculations
--
------------------------------------------------------------------------
   PROCEDURE calculate (
      ip_index_lease_id          IN       NUMBER
     ,ip_index_lease_period_id   IN       NUMBER
     ,ip_recalculate             IN       VARCHAR2
     ,ip_commit                  IN       VARCHAR2 DEFAULT 'N'
     ,op_msg                     OUT NOCOPY      VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : calculate_period
-- DESCRIPTION: This procedure will calculate the index amount for a period
--
--                 - Calculate Basis Amount
--                 - Calculate Index Percentage Change (if necessary)
--                 asdasdfas
--
------------------------------------------------------------------------
  PROCEDURE calculate_period (
      ip_index_lease_id              IN       NUMBER
     ,ip_index_lease_period_id       IN       NUMBER
     ,ip_recalculate                 IN       VARCHAR2
     ,op_current_basis               OUT NOCOPY      NUMBER
     ,op_unconstraint_rent_due       OUT NOCOPY      NUMBER
     ,op_constraint_rent_due         OUT NOCOPY      NUMBER
     ,op_index_percent_change        OUT NOCOPY      NUMBER
     ,op_current_index_line_id       OUT NOCOPY      NUMBER
     ,op_current_index_line_value    OUT NOCOPY      NUMBER
     ,op_previous_index_line_id      OUT NOCOPY      NUMBER
     ,op_previous_index_line_value   OUT NOCOPY      NUMBER
     ,op_previous_index_amount       IN OUT NOCOPY   NUMBER
     ,op_previous_asmt_date          IN OUT NOCOPY   DATE
     ,op_constraint_applied_amount   OUT NOCOPY      NUMBER
     ,op_carry_forward_amount        OUT NOCOPY      NUMBER
     ,op_constraint_applied_percent  OUT NOCOPY      NUMBER
     ,op_carry_forward_percent       OUT NOCOPY      NUMBER
     ,op_msg                         OUT NOCOPY      VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : calculate_initial_basis
-- DESCRIPTION: This procedure will derive the initial basis;
--
------------------------------------------------------------------------

   PROCEDURE calculate_initial_basis (
      p_index_lease_id   IN       NUMBER
     ,op_basis_amount    OUT NOCOPY      NUMBER
     ,op_msg             OUT NOCOPY      VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : calculate_basis_amount
-- DESCRIPTION: This procedure will calculate the basis amount for a given index rent period
--
------------------------------------------------------------------------
   PROCEDURE calculate_basis_amount (
      p_index_lease_id      IN       NUMBER
     ,p_basis_start_date    IN       DATE
     ,p_basis_end_date      IN       DATE
     ,p_assessment_date     IN       DATE
     ,p_initial_basis       IN       NUMBER
     ,p_line_number         IN       NUMBER
     ,p_increase_on         IN       VARCHAR2
     ,p_basis_type          IN       VARCHAR2
     ,p_prev_index_amount   IN       NUMBER DEFAULT NULL
     ,p_recalculate         IN       VARCHAR2
     ,op_basis_amount       OUT NOCOPY      NUMBER
     ,op_msg                OUT NOCOPY      VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : calculate_index_amount
-- DESCRIPTION: This procedure will calculate the UNCONSTRAINED index amount for
--              a given index rent period
--
------------------------------------------------------------------------
   PROCEDURE calculate_index_amount (
      p_relationship                IN       VARCHAR2
     ,p_basis_percent_change        IN       NUMBER
     ,p_adj_index_percent_change    IN       NUMBER
     ,p_current_basis               IN       NUMBER
     ,op_index_amount               OUT NOCOPY      NUMBER
     ,op_msg                        OUT NOCOPY      VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : derive_constrained_rent
-- DESCRIPTION: This procedure will apply all constraints that have been defined
--              for a given index rent
--
------------------------------------------------------------------------
   PROCEDURE derive_constrained_rent (
      p_index_lease_id              IN       NUMBER
     ,p_current_basis               IN       NUMBER
     ,p_index_period_id             IN       NUMBER
     ,p_assessment_date             IN       DATE
     ,p_negative_rent_type          IN       VARCHAR2
     ,p_unconstrained_rent_amount   IN       NUMBER
     ,p_prev_index_amount           IN       NUMBER DEFAULT NULL
     ,p_carry_forward_flag          IN       VARCHAR2
     ,p_prorate_factor              IN       NUMBER
     ,op_constrained_rent_amount    OUT NOCOPY      NUMBER
     ,op_constraint_applied_amount  OUT NOCOPY      NUMBER
     ,op_constraint_applied_percent OUT NOCOPY      NUMBER
     ,op_carry_forward_amount       OUT NOCOPY      NUMBER
     ,op_carry_forward_percent      OUT NOCOPY      NUMBER
     ,op_msg                        OUT NOCOPY      VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : sum_payment_items
-- DESCRIPTION: This procedure will sum all the CASH payment items that is
--              within the date range specified of the type specified.
--
------------------------------------------------------------------------
   PROCEDURE sum_payment_items (
      p_index_lease_id     IN       NUMBER
     ,p_basis_start_date   IN       DATE
     ,p_basis_end_date     IN       DATE
     ,p_type_code          IN       VARCHAR2
     ,p_include_index_items in   VARCHAR2 DEFAULT 'Y'
     ,op_sum_amount        OUT NOCOPY      NUMBER
   );


------------------------------------------------------------------------
-- PROCEDURE : calculate_index_percentage
-- DESCRIPTION: This procedure will derive the current and previous CPI for a given index period.
--              It will also calculate the index change percentage
--
------------------------------------------------------------------------
   PROCEDURE calculate_index_percentage (
      p_index_finder_type       IN       VARCHAR2
     ,p_reference_period_type   IN       VARCHAR2
     ,p_index_finder_date       IN       DATE
     ,p_index_history_id        IN       NUMBER
     ,p_base_index              IN       NUMBER
     ,p_base_index_line_id      IN       NUMBER
     ,p_index_lease_id          IN       NUMBER
     ,p_assessment_date         IN       DATE
     ,p_prev_assessment_date    IN       DATE
     ,op_current_cpi_value      IN OUT NOCOPY   NUMBER
     ,op_current_cpi_id         IN OUT NOCOPY   NUMBER
     ,op_previous_cpi_value     IN OUT NOCOPY   NUMBER
     ,op_previous_cpi_id        IN OUT NOCOPY   NUMBER
     ,op_index_percent_change   OUT NOCOPY      NUMBER
     ,op_msg                    OUT NOCOPY      VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : lookup_index_history
-- DESCRIPTION: This procedure will derive the cpi value and index history id using
--              finder date provided.  This procedure
--
------------------------------------------------------------------------
   PROCEDURE lookup_index_history (
      p_index_history_id    IN       NUMBER
     ,p_index_finder_date   IN       DATE
     ,op_cpi_value          OUT NOCOPY      NUMBER
     ,op_cpi_id             OUT NOCOPY      NUMBER
     ,op_msg                OUT NOCOPY      VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : create_payment_terms
-- DESCRIPTION: This procedure will create payment terms for a particular index
--              period id.
--
------------------------------------------------------------------------
   PROCEDURE create_payment_terms (
      p_lease_id               IN       NUMBER
     ,p_index_lease_id         IN       NUMBER
     ,p_location_id            IN       NUMBER
     ,p_purpose_code           IN       VARCHAR2
     ,p_index_period_id        IN       NUMBER
     ,p_term_template_id       IN       NUMBER
     ,p_relationship           IN       VARCHAR2
     ,p_assessment_date        IN       DATE
     ,p_basis_amount           IN       NUMBER
     ,p_basis_percent_change   IN       NUMBER
     ,p_spread_frequency       IN       VARCHAR2
     ,p_rounding_flag          IN       VARCHAR2
     ,p_index_amount           IN       NUMBER
     ,p_index_finder_type      IN       VARCHAR2
     ,p_basis_type             IN       VARCHAR2
     ,p_basis_start_date       IN       DATE
     ,p_basis_end_date         IN       DATE
     ,p_increase_on            IN       VARCHAR2
     ,p_negative_rent_type     IN       VARCHAR2
     ,p_carry_forward_flag     IN       VARCHAR2
     ,p_calculate_date         IN       DATE   DEFAULT g_calculate_date
     ,p_prorate_factor         IN       NUMBER
     ,op_msg                   OUT NOCOPY      VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : create_payment_term_record
-- DESCRIPTION: This procedure will insert records to the following tables \
--              necessary to create a complete index rent payment record.
-- 05-MAY-06  Hareesha  o Bug#5115291 Added parameter p_norm_st_date
-- 10-AUG-06  Pikhar    0 Codev. Added include_in_var_rent
-- 01-NOV-06  Prabhakar o Added p_end_date parameter.
-- 02-JAN-07  Hareesha  o M28#16 Added p_recur_bb_calc_date
------------------------------------------------------------------------
   PROCEDURE create_payment_term_record (
      p_lease_id               IN       NUMBER
     ,p_location_id            IN       NUMBER
     ,p_purpose_code           IN       VARCHAR2
     ,p_index_period_id        IN       NUMBER
     ,p_term_template_id       IN       NUMBER
     ,p_spread_frequency       IN       VARCHAR2
     ,p_rounding_flag          IN       VARCHAR2
     ,p_payment_amount         IN       NUMBER
     ,p_normalized             IN       VARCHAR2
     ,p_start_date             IN       DATE
     ,p_index_term_indicator   IN       VARCHAR2
     ,p_payment_term_id        IN       NUMBER
     ,p_basis_relationship     IN       VARCHAR2
     ,p_called_from            IN       VARCHAR2
     ,p_calculate_date         IN       DATE   DEFAULT g_calculate_date
     ,p_norm_st_date           IN       DATE   DEFAULT NULL
     ,p_end_date               IN       DATE
     ,p_recur_bb_calc_date     IN       DATE   DEFAULT NULL
     ,op_payment_term_id       OUT NOCOPY      NUMBER
     ,op_msg                   OUT NOCOPY      VARCHAR2
     ,p_include_in_var_rent    IN       VARCHAR2 DEFAULT NULL
   );


------------------------------------------------------------------------
-- PROCEDURE : print_basis_periods
-- DESCRIPTION: This procedure is will print basis information for a given
--              index lease.
--
------------------------------------------------------------------------
   PROCEDURE print_basis_periods (
      p_index_lease_id    IN   NUMBER
     ,p_index_period_id   IN   NUMBER
   );


------------------------------------------------------------------------
-- PROCEDURE : calculate_batch
-- DESCRIPTION: This procedure is used by concurrent process that will
--       allow user to choose on or more index leases to process
--
------------------------------------------------------------------------
   PROCEDURE calculate_batch (
      errbuf                        OUT NOCOPY      VARCHAR2
     ,retcode                       OUT NOCOPY      VARCHAR2
     ,ip_index_lease_number_lower   IN       VARCHAR2
     ,ip_index_lease_number_upper   IN       VARCHAR2
     ,ip_assessment_date_lower      IN       VARCHAR2
     ,ip_assessment_date_upper      IN       VARCHAR2
     ,ip_lease_class                IN       VARCHAR2
     ,ip_main_lease_number          IN       VARCHAR2
     ,ip_location_code              IN       VARCHAR2
     ,ip_user_responsible           IN       VARCHAR2
     ,ip_recalculate                IN       VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : update_index_hist_line
-- DESCRIPTION: This procedure is by the index history window u
--
------------------------------------------------------------------------
   PROCEDURE update_index_hist_line (
      ip_index_history_line_id   IN       NUMBER
     ,ip_recalculate             IN       VARCHAR2
     ,op_msg                     OUT NOCOPY      VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : update_index_hist_line_batch
-- DESCRIPTION: This procedure is used by the index history window any time index
--             history line is updated.  It will be submitted as a batch program
--             by the form.
--
------------------------------------------------------------------------
   PROCEDURE update_index_hist_line_batch (
      errbuf                OUT NOCOPY      VARCHAR2
     ,retcode               OUT NOCOPY      VARCHAR2
     ,ip_index_history_id   IN       NUMBER
     ,ip_recalculate        IN       VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : approve_index_pay_term
-- DESCRIPTION: This procedure is called every time a index rent payment is term
--              is approved.
--
------------------------------------------------------------------------

   PROCEDURE approve_index_pay_term (
      ip_lease_id            IN       NUMBER
     ,ip_index_pay_term_id   IN       NUMBER
     ,op_msg                 OUT NOCOPY      VARCHAR2
   );


------------------------------------------------------------------------
-- PROCEDURE : approve_index_pay_term_batch
-- DESCRIPTION: This procedure is called every time a index rent payment is term
--              is approved.
-- HISTORY
-- 06-AUG-04 ftanudja o add parameter ip_auto_find_sch_day. #3701195.
------------------------------------------------------------------------

   PROCEDURE approve_index_pay_term_batch (
      errbuf                        OUT NOCOPY      VARCHAR2
     ,retcode                       OUT NOCOPY      VARCHAR2
     ,ip_index_lease_number_lower   IN       VARCHAR2
     ,ip_index_lease_number_upper   IN       VARCHAR2
     ,ip_assessment_date_lower      IN       VARCHAR2
     ,ip_assessment_date_upper      IN       VARCHAR2
     ,ip_lease_class                IN       VARCHAR2
     ,ip_main_lease_number_lower    IN       VARCHAR2
     ,ip_main_lease_number_upper    IN       VARCHAR2
     ,ip_location_code              IN       VARCHAR2
     ,ip_user_responsible           IN       VARCHAR2
     ,ip_payment_start_date_lower   IN       VARCHAR2
     ,ip_payment_start_date_upper   IN       VARCHAR2
     ,ip_approve_normalize_only     IN       VARCHAR2
     ,ip_index_period_id            IN       VARCHAR2
     ,ip_payment_status             IN       VARCHAR2
     ,ip_auto_find_sch_day          IN       VARCHAR2
   );



   FUNCTION build_distributions_string (
      ip_payment_term_id IN NUMBER
) RETURN VARCHAR2 ;


------------------------------------------------------------------------
-- PROCEDURE  : process_currency_code
-- DESCRIPTION: This procedure is called by the index rent form
--              when the currency_code field is changed. Fix for
--              bug# 2452909.
------------------------------------------------------------------------

PROCEDURE process_currency_code (p_index_lease_id in number);


------------------------------------------------------------------------
-- PROCEDURE  : derive_cum_carry_forward
-- DESCRIPTION: Derive the value of the column carry_forward_amount and
--              carry_forward_percent of the period prior to the current period.
--
------------------------------------------------------------------------
  PROCEDURE derive_cum_carry_forward (
      p_index_lease_id    IN       NUMBER,
      p_assessment_date   IN       DATE,
      op_carry_forward_amount OUT NOCOPY NUMBER,
      op_carry_forward_percent OUT NOCOPY NUMBER);

------------------------------------------------------------------------
-- FUNCTION   : derive_prev_negative_rent
-- DESCRIPTION: If the negative rent option for the index rent agreement
--              is next period for the current period derive the negative
--              unconstrained rent amounts of the previous periods.
------------------------------------------------------------------------

FUNCTION derive_prev_negative_rent (
    p_index_lease_id    IN       NUMBER
   ,p_assessment_date   IN       DATE)
RETURN number;

------------------------------------------------------------------------
-- FUNCTION : get_increase_over_constraint
-- DESCRIPTION :
--
------------------------------------------------------------------------

FUNCTION get_increase_over_constraint (
      p_carry_forward_flag     IN VARCHAR2,
      p_constraint_amount      IN NUMBER,
      p_unconstrained_rent     IN NUMBER,
      p_constrained_rent       IN NUMBER)
RETURN number;


------------------------------------------------------------------------
-- FUNCTION   : get_max_assessment_dt
-- DESCRIPTION: get the maximum assessment date after the current assessment
--              date for which the rent increase has been calcuated.
--
------------------------------------------------------------------------

FUNCTION get_max_assessment_dt(p_index_lease_id IN NUMBER,
                               p_assessment_date IN DATE)
RETURN DATE;


-------------------------------------------------------------------------------
--  FUNCTION   : Get_Calculate_Date
--  DESCRIPTION: This function returns the lease of assessment date and
--               the profile option cut off date (change from Legacy to PN).
-------------------------------------------------------------------------------
FUNCTION Get_Calculate_Date (p_assessment_date  IN DATE,
                             p_period_str_date  IN DATE)
RETURN   DATE;

-------------------------------------------------------------------------------
--  FUNCTION   : Get_Calculate_Date (Overloaded)
--  DESCRIPTION: This function returns the lease of assessment date and
--               the profile option cut off date (change from Legacy to PN).
--  IMP - Use this function in R12. The one with 2 params is for backward
--        compatiability ONLY.
-------------------------------------------------------------------------------
FUNCTION Get_Calculate_Date (p_assessment_date  IN DATE,
                             p_period_str_date  IN DATE,
                             p_org_id           IN NUMBER)
RETURN   DATE;


------------------------------------------------------------------------
-- PROCEDURE   : calculate_subsequent_periods
-- DESCRIPTION:  This procedure is called by pn_index_periods_pkg
--               while calculating rent increase for an index lease
--               period. If carry forward flag is 'Y' then calculate for
--               all subsequent periods after the current period.
--
------------------------------------------------------------------------

PROCEDURE calculate_subsequent_periods(p_index_lease_id  IN NUMBER,
                                       p_assessment_date IN DATE);


END pn_index_amount_pkg;



/
