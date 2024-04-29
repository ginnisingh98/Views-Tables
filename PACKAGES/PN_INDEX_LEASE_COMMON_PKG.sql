--------------------------------------------------------
--  DDL for Package PN_INDEX_LEASE_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_INDEX_LEASE_COMMON_PKG" AUTHID CURRENT_USER AS
-- $Header: PNINCOMS.pls 120.4 2007/01/02 07:40:30 pseeram ship $

-- +==========================================================================+
-- |                Copyright (c) 2001 Oracle Corporation
-- |                   Redwood Shores, California, USA
-- |                        All rights reserved.
-- +==========================================================================+
-- |  Name
-- |    pn_index_lease_common_pkgBKUP
-- |
-- |  Description
-- |    This package contains procedures used by some of index lease
-- |    feature of Property Manager.
-- |
-- |
-- |  History
-- |   09-APR-01 jreyes    o Created
-- |   10-AUG-01 psidhu    o Added function GET_MAX_SCHEDULE_DATE
-- |   14-AUG-01 psidhu    o Added function GET_PROJECT_NAME
-- |   24-AUG-01 psidhu    o Added procedure GET_EXCLUDE_TERM
-- |   12-SEP-01 psidhu    o Added function GET_AP_ORGANIZATION_NAME
-- |   13-DEC-01 Mrinal    o Added dbdrv command.
-- |   12-AUG-02 Pooja     o Added param p_carry_forward_flag to get_index_lease.
-- |   26-NOV-03 Daniel    o Added parameters p_aggregation_flag,
-- |                         p_index_finder_months to get_index_lease.
-- |                         Fix for bug 3271061
-- |   15-JUN-04 Anand     o Added proc spec UPDATE_LOCATION_FOR_IR_TERMS
-- |   24-JUN-05 piagrawa  o Overloaded get_ar_trx_type, get_ap_tax_details,
-- |                         get_tax_group, get_po_number, get_distribution_set,
-- |                         get_project_name for use with MOAC
-- |   14-MAR-06 Hareesha  o Bug #4756588 Removed procedure get_ap_tax_details,
-- |                         get_ar_tax_code,get_tax_group
-- |   24-MAR-06 Hareesha  o Bug # 5116270 Added org_id parameter to
-- |                         get_salesperson
-- |   09-NOV-06 Prabhakar o Added parameter p_index_multiplier to get_index_lease
-- |                         Added p_index_multiplier to get_index_period.
-- |   08-DEC-06 Prabhakar o Added parameters proration_rule,proration_period_start_date
-- |                          to get_index_lease
-- +==========================================================================+


   TYPE tax_data_rec IS RECORD (
      tax_code                      ap_tax_codes.name%TYPE
     ,group_code                    ap_awt_groups.name%TYPE);


------------------------------------------------------------------------
-- PROCEDURE : chk_for_approved_index_periods
------------------------------------------------------------------------
   PROCEDURE chk_for_approved_index_periods (
      p_index_lease_id          IN       NUMBER
     ,p_index_lease_period_id   IN       NUMBER DEFAULT NULL
     ,p_chk_index_ind           IN       VARCHAR2 DEFAULT NULL
     ,p_msg                     IN OUT NOCOPY   VARCHAR2);


------------------------------------------------------------------------
-- PROCEDURE : chk_for_payment_required_fields
------------------------------------------------------------------------
   PROCEDURE chk_for_payment_reqd_fields (
      p_payment_term_id   IN       NUMBER
     ,p_msg               OUT NOCOPY      VARCHAR2);

------------------------------------------------------------------------
-- PROCEDURE : chk_for_exported_items
-- DESCRIPTION:  This procedure will check if an index rent period has
--               payment items that have been exported to ap or ar
------------------------------------------------------------------------

   PROCEDURE chk_for_exported_items (
      ip_index_period_id   IN       NUMBER
     ,op_msg               OUT NOCOPY      VARCHAR2);

------------------------------------------------------------------------
-- PROCEDURE : put_log
------------------------------------------------------------------------
   PROCEDURE put_log (
      p_string   VARCHAR2);


------------------------------------------------------------------------
-- PROCEDURE : put_output
------------------------------------------------------------------------
   PROCEDURE put_output (
      p_string   VARCHAR2);


------------------------------------------------------------------------
-- PROCEDURE : GET_INDEX_LEASE
------------------------------------------------------------------------
   PROCEDURE get_index_lease (
      p_index_lease_id          IN       NUMBER DEFAULT NULL
     ,p_commencement_date       OUT NOCOPY      DATE
     ,p_termination_date        OUT NOCOPY      DATE
     ,p_assessment_date         OUT NOCOPY      DATE
     ,p_assessment_interval     OUT NOCOPY      NUMBER
     ,p_relationship_default    OUT NOCOPY      VARCHAR2
     ,p_spread_frequency        OUT NOCOPY      VARCHAR2
     ,p_basis_percent_default   OUT NOCOPY      NUMBER
     ,p_intial_basis            OUT NOCOPY      NUMBER
     ,p_base_index              OUT NOCOPY      NUMBER
     ,p_index_finder_method     OUT NOCOPY      VARCHAR2
     ,p_negative_rent_type      OUT NOCOPY      VARCHAR2
     ,p_increase_on             OUT NOCOPY      VARCHAR2
     ,p_basis_type              OUT NOCOPY      VARCHAR2
     ,p_reference_period        OUT NOCOPY      VARCHAR2
     ,p_base_year               OUT NOCOPY      DATE
     ,p_rounding_flag           OUT NOCOPY      VARCHAR2
     ,p_gross_flag              OUT NOCOPY      VARCHAR2
     ,p_carry_forward_flag      OUT NOCOPY      VARCHAR2
     ,p_aggregation_flag        OUT NOCOPY      VARCHAR2
     ,p_index_finder_months     OUT NOCOPY      NUMBER
     ,p_index_multiplier        OUT NOCOPY      NUMBER
     ,p_proration_rule          OUT NOCOPY      VARCHAR2
     ,p_proration_period_start_date OUT NOCOPY  DATE);


------------------------------------------------------------------------
-- PROCEDURE : GET_INDEX_PERIOD
------------------------------------------------------------------------
   PROCEDURE get_index_period (
      p_index_period_id        IN       NUMBER DEFAULT NULL
     ,p_basis_start_date       OUT NOCOPY      DATE
     ,p_basis_end_date         OUT NOCOPY      DATE
     ,p_index_finder_date      OUT NOCOPY      DATE
     ,p_current_basis          OUT NOCOPY      NUMBER
     ,p_relationship           OUT NOCOPY      VARCHAR2
     ,p_index_percent_change   OUT NOCOPY      NUMBER
     ,p_basis_percent_change   OUT NOCOPY      NUMBER
     ,p_index_multiplier       OUT NOCOPY      NUMBER);



------------------------------------------------------------------------
-- PROCEDURE : GET_INDEX_START_END_DATES
------------------------------------------------------------------------
   PROCEDURE get_index_start_end_dates (
      p_index_period_id        IN       NUMBER DEFAULT NULL
     ,p_commencement_date      OUT NOCOPY      DATE
     ,p_termination_date       OUT NOCOPY      DATE );


------------------------------------------------------------------------
-- PROCEDURE : GET_INDEX_DETAILS
------------------------------------------------------------------------
   PROCEDURE get_index_details (
      p_index_line_id   IN       NUMBER DEFAULT NULL
     ,p_index_date      OUT NOCOPY      DATE
     ,p_index_figure    OUT NOCOPY      NUMBER);


------------------------------------------------------------------------
-- PROCEDURE : GET_AR_PAYMENT_TERM
------------------------------------------------------------------------

   FUNCTION get_ar_payment_term (
      p_term_id   NUMBER)
      RETURN VARCHAR2;


------------------------------------------------------------------------
-- PROCEDURE : GET_AP_PAYMENT_TERM
------------------------------------------------------------------------

   FUNCTION get_ap_payment_term (
      p_term_id   NUMBER)
      RETURN VARCHAR2;


------------------------------------------------------------------------
-- PROCEDURE : GET_AR_TRX_TYPE
------------------------------------------------------------------------

   FUNCTION get_ar_trx_type (
      p_cust_trx_type_id   NUMBER)
      RETURN VARCHAR2;


  TYPE index_lease_periods_rec IS RECORD (
      current_basis                 pn_index_lease_periods.current_basis%TYPE
     ,constraint_rent_due           pn_index_lease_periods.constraint_rent_due%TYPE
     ,unconstraint_rent_due         pn_index_lease_periods.unconstraint_rent_due%TYPE
     ,index_percent_change          pn_index_lease_periods.index_percent_change%TYPE
     ,current_index_line_id         pn_index_lease_periods.current_index_line_id%TYPE
     ,current_index_line_value      pn_index_lease_periods.current_index_line_value%TYPE
     ,previous_index_line_id        pn_index_lease_periods.previous_index_line_id%TYPE
     ,previous_index_line_value     pn_index_lease_periods.previous_index_line_value%TYPE);


------------------------------------------------------------------------
-- PROCEDURE : GET_INDEX_PERIOD_DETAILS
------------------------------------------------------------------------

   FUNCTION get_index_period_details (
      p_index_period_id   NUMBER)
      RETURN index_lease_periods_rec;


------------------------------------------------------------------------
-- PROCEDURE : GET_LEASE_CHANGE_ID
------------------------------------------------------------------------

   FUNCTION get_lease_change_id (
      p_lease_id   NUMBER)
      RETURN NUMBER;

   PROCEDURE delete_index_payment_term (
      p_index_period_id   IN       NUMBER
     ,p_payment_term_id   IN       NUMBER DEFAULT NULL
     ,p_msg               OUT NOCOPY      VARCHAR2);


------------------------------------------------------------------------
-- PROCEDURE : Find if period Exists
------------------------------------------------------------------------

   FUNCTION find_if_period_exists (
      p_index_lease_id   NUMBER)
      RETURN NUMBER;


------------------------------------------------------------------------
-- PROCEDURE : Find if Term Exists
------------------------------------------------------------------------

   FUNCTION find_if_term_exists (
      p_index_period_id   NUMBER)
      RETURN NUMBER;


------------------------------------------------------------------------
-- PROCEDURE : Find if Any Normalized Payment Term Exists
------------------------------------------------------------------------

   FUNCTION find_if_norm_term_exists (
      p_index_period_id   NUMBER)
      RETURN NUMBER;


------------------------------------------------------------------------
-- PROCEDURE : Find if Template is used by any Index Lease
------------------------------------------------------------------------

   FUNCTION find_if_template_used (
      p_term_template_id   NUMBER)
      RETURN NUMBER;


------------------------------------------------------------------------
-- PROCEDURE : GET TERM STATUS
------------------------------------------------------------------------

   FUNCTION get_term_status (
      p_payment_term_id   NUMBER)
      RETURN VARCHAR2;


------------------------------------------------------------------------
-- PROCEDURE : GET PO NUMBER
------------------------------------------------------------------------

   FUNCTION get_po_number (
      p_po_header_id   NUMBER)
      RETURN VARCHAR2;


------------------------------------------------------------------------
-- PROCEDURE : GET RECEIPT METHOD
------------------------------------------------------------------------

    FUNCTION get_receipt_method (
            p_receipt_method_id   NUMBER)
         RETURN VARCHAR2;


------------------------------------------------------------------------
-- PROCEDURE : GET LOCATION CODE
------------------------------------------------------------------------

   FUNCTION get_location (
      p_location_id   NUMBER)
      RETURN VARCHAR2;


----------
--------------------------------------------------------------
-- PROCEDURE : lookup_index_history
-- DESCRIPTION: This procedure will derive the cpi value and index history id using
--              finder date provided.
--
------------------------------------------------------------------------

   PROCEDURE lookup_index_history (
      p_index_history_id    IN       NUMBER
     ,p_index_finder_date   IN       DATE
     ,op_cpi_value          OUT NOCOPY      NUMBER
     ,op_cpi_id             OUT NOCOPY      NUMBER
     ,op_msg                OUT NOCOPY      VARCHAR2);


------------------------------------------------------------------------
-- PROCEDURE : GET_TERM_TEMPLATE
------------------------------------------------------------------------

   FUNCTION get_term_template (
      p_term_template_id   NUMBER)
      RETURN VARCHAR2;


------------------------------------------------------------------------
-- PROCEDURE : GET_APPROVER
------------------------------------------------------------------------

   FUNCTION get_approver (
      p_approved_by   NUMBER)
      RETURN VARCHAR2;


------------------------------------------------------------------------
-- PROCEDURE : GET_LEASE_CLASS
------------------------------------------------------------------------

   FUNCTION get_lease_class (
      p_lease_id   NUMBER)
      RETURN VARCHAR2;

   PROCEDURE append_msg (
      p_new_msg   IN       VARCHAR2
     ,p_all_msg   IN OUT NOCOPY   VARCHAR2);


------------------------------------------------------------------------
-- PROCEDURE : GET_SALESPERSON
------------------------------------------------------------------------

   FUNCTION get_salesperson (
      p_salesrep_id   NUMBER,
      p_org_id NUMBER)
      RETURN VARCHAR2;


------------------------------------------------------------------------
-- PROCEDURE : GET_INVOICING_RULE
------------------------------------------------------------------------

   FUNCTION get_invoicing_rule (
      p_rule_id   NUMBER)
      RETURN VARCHAR2;


------------------------------------------------------------------------
-- PROCEDURE : GET_ACCOUNTING_RULE
------------------------------------------------------------------------

   FUNCTION get_accounting_rule (
      p_rule_id   NUMBER)
      RETURN VARCHAR2;


------------------------------------------------------------------------
-- PROCEDURE : GET_DISTRIBUTION_SET
------------------------------------------------------------------------

   FUNCTION get_distribution_set (
      p_distribution_set_id   NUMBER)
      RETURN VARCHAR2;


------------------------------------------------------------------------
-- PROCEDURE : GET_PROJECT_DETAILS
------------------------------------------------------------------------


   PROCEDURE get_project_details (
      p_project_id     IN       NUMBER DEFAULT NULL
     ,p_project_name   OUT NOCOPY      VARCHAR2
     ,p_organization   OUT NOCOPY      VARCHAR2);


------------------------------------------------------------------------
-- PROCEDURE : Find if Index History Line is Used by an Index Lease
------------------------------------------------------------------------

   FUNCTION find_if_hist_line_used (
      p_index_line_id   NUMBER)
      RETURN NUMBER;


------------------------------------------------------------------------
-- PROCEDURE : Find if Calculation is Done
------------------------------------------------------------------------

   FUNCTION find_if_calc_exists (
      p_index_lease_id   NUMBER)
      RETURN NUMBER;

------------------------------------------------------------------------
-- PROCEDURE : Find if Current Basis Exists for any period
------------------------------------------------------------------------

  FUNCTION find_if_basis_exists (
      p_index_lease_id  NUMBER)
      RETURN NUMBER;

------------------------------------------------------------------------
-- FUNCTION : GET_MAX_SCHEDULE_DATE
--
--             Get the max schedule date from pn_payment_schedules
--             that has exported items associated with it.
------------------------------------------------------------------------

  FUNCTION GET_MAX_SCHEDULE_DATE (
      p_index_leaseId       IN NUMBER)
      RETURN    DATE;

------------------------------------------------------------------------
-- FUNCTION : GET_PROJECT_NAME
------------------------------------------------------------------------

  FUNCTION get_project_name (
      p_project_id   NUMBER)
      RETURN VARCHAR2;

------------------------------------------------------------------------
-- PROCEDURE : GET_EXCLUDE_FLAG
------------------------------------------------------------------------

  PROCEDURE get_exclude_term ( p_index_lease_id        IN NUMBER,
                               p_payment_term_id       IN NUMBER,
                               p_exclude_flag          OUT NOCOPY VARCHAR2,
                               p_index_exclude_term_id OUT NOCOPY NUMBER);

------------------------------------------------------------------------
-- FUNCTION : GET_AP_ORGANIZATION_NAME
------------------------------------------------------------------------

 FUNCTION get_ap_organization_name (
     p_organization_id NUMBER )
     RETURN VARCHAR2;

-------------------------------------------------------------------------------
-- PROCEDURE to update the index rent terms with the changed location
-------------------------------------------------------------------------------
PROCEDURE UPDATE_LOCATION_FOR_IR_TERMS(
          p_index_lease_id   IN  NUMBER,
          p_location_id      IN  NUMBER,
          p_return_status    OUT NOCOPY VARCHAR2);

/* overloaded functions and procedures for MOAC */
-------------------------------------------------------------------------------
-- To return Transaction Type for a given Customer Transaction Type
-- Id from Receivables.
-- USE THIS IN R12
-------------------------------------------------------------------------------
FUNCTION get_ar_trx_type (p_cust_trx_type_id   NUMBER, p_org_id NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------------------
-- FUNCTION to return po number
-------------------------------------------------------------------------------
FUNCTION get_po_number ( p_po_header_id   NUMBER,p_org_id   NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------------------
-- FUNCTION to return distribution set
-------------------------------------------------------------------------------
FUNCTION get_distribution_set (p_distribution_set_id   NUMBER, p_org_id  NUMBER)
RETURN VARCHAR2;

-------------------------------------------------------------------------------
-- FUNCTION to return project name
-------------------------------------------------------------------------------
FUNCTION get_project_name ( p_project_id   NUMBER, p_org_id       NUMBER)
RETURN VARCHAR2;

END pn_index_lease_common_pkg;





/
