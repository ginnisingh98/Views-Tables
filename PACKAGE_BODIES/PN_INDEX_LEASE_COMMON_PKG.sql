--------------------------------------------------------
--  DDL for Package Body PN_INDEX_LEASE_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_INDEX_LEASE_COMMON_PKG" AS
-- $Header: PNINCOMB.pls 120.6 2007/01/02 07:41:01 pseeram ship $

--============================================================================+
--                 Copyright (c) 2001 Oracle Corporation
--                    Redwood Shores, California, USA
--                         All rights reserved.
-- ===========================================================================+
--   Name
--     pn_index_lease_common_pkgBKUP
--
--   Description
--     This package contains procedures used by some of index lease
--     feature of Property Manager.
--
--
--  History :
--  09-APR-01 jreyes        o Created
--  10-AUG-01 psidhu        o Added function GET_MAX_SCHEDULE_DATE
--  14-AUG-01 psidhu        o Added function GET_PROJECT_NAME
--  24-AUG-01 psidhu        o Added procedure GET_EXCLUDE_TERM
--  12-SEP-01 psidhu        o Added procedure GET_AP_ORGANIZATION_NAME
--  13-DEC-01 Mrinal Misra  o Added dbdrv command.
--  15-JAN-02 Mrinal Misra  o In dbdrv command changed phase=pls to phase=plb.
--  07-MAR-02 achauhan      o Changed the select statements in
--                            chk_for_approved_index_periods
--                            to make the queries more performant.
--  11-MAR-02 Lakshmikanth  o Fix for the GSCC issues.
--            Katputur        Added the following line at the beginning
--  12-AUG-02 Pooja Sidhu   o Added parameter p_carry_forward_flag to
--                            get_index_lease.
--  29-Oct-02 Pooja Sidhu   o Removed default null clause from parameters.
--                            Fix for GSCC warning
--                            "No default parameter values in package body".
--  15-JUN-04 Anand         o Added proc defn UPDATE_LOCATION_FOR_IR_TERMS.
--  24-JUN-05 piagrawa      o Overloaded get_ar_trx_type, get_ap_tax_details,
--                            get_tax_group, get_po_number, get_distribution_set,
--                            get_project_name for use with MOAC
--  14-MAR-06 Hareesha      o Bug #4756588 Removed procedure get_ap_tax_details,
--                            get_ar_tax_code_name, get_tax_group
--  24-MAR-06 Hareesha      o Bug # 5116270 Added org_id parameter to
--                            get_salesperson
--  09-NOV-06 Prabhakar     o Added parameter p_index_multiplier to get_index_lease
--                            Added paramenter p_index_multiplier to get_index_period
--  08-DEC-06 Prabhakar     o Added parameters proration_rule,proration_period_start_date
--                            to get_index_lease
--============================================================================+

-------------------------------------------------------------------------------
-- PROCDURE     : chk_for_approved_index_periods
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_lease_periods,
--                     pn_payment_terms with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE chk_for_approved_index_periods
(
   p_index_lease_id          IN              NUMBER
  ,p_index_lease_period_id   IN              NUMBER
  ,p_chk_index_ind           IN              VARCHAR2
  ,p_msg                     IN OUT NOCOPY   VARCHAR2
)
AS
   v                CHAR (1) := 0;
   l_zero_period    NUMBER := 0;

BEGIN
   --
   -- p_msg
   --    - PN_APPROVED_PERIODS_NOT_FOUND - no index lease found
   --    - PN_APPROVED_PERIODS_FOUND - no index lease period with this id was found
   --

   BEGIN
      IF p_index_lease_period_id IS NULL
      THEN
         SELECT '1'
         INTO v
         FROM DUAL
         WHERE EXISTS (
                   SELECT 1
                   FROM   pn_index_lease_periods_all pilp
                         ,pn_payment_terms_all ppt
                   WHERE pilp.index_period_id = ppt.index_period_id
                   AND ppt.status = 'APPROVED'
                   AND pilp.index_lease_id = p_index_lease_id
                   AND ppt.index_period_id > l_zero_period
                   AND (       p_chk_index_ind = 'Y'
                              AND ppt.index_term_indicator IN
                                        (
                                         pn_index_amount_pkg.c_index_pay_term_type_recur
                                        ,pn_index_amount_pkg.c_index_pay_term_type_backbill)
                           OR NVL (p_chk_index_ind, 'N') = 'N'));
      ELSE
         SELECT '1'
         INTO v
         FROM DUAL
         WHERE EXISTS (
                        SELECT 1
                        FROM pn_payment_terms_all ppt
                        WHERE ppt.index_period_id = p_index_lease_period_id
                        AND ppt.status = 'APPROVED'
                        AND (       p_chk_index_ind = 'Y'
                              AND ppt.index_term_indicator IN
                                        (
                                         pn_index_amount_pkg.c_index_pay_term_type_recur
                                        ,pn_index_amount_pkg.c_index_pay_term_type_backbill)
                           OR NVL (p_chk_index_ind, 'N') = 'N'));
      END IF; --p_index_lease_period_id is null
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         v := '0';
         p_msg := 'PN_APPROVED_PERIODS_NOT_FOUND';
   END;

   IF v = '1'
   THEN
      p_msg := 'PN_APPROVED_PERIODS_FOUND';
   END IF;
END chk_for_approved_index_periods;

-------------------------------------------------------------------------------
-- PROCEDURE    : chk_for_exported_items
-- DESCRIPTION  : This procedure will check if an index rent period has
--                payment items that have been exported to ap or ar
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_payment_terms, pn_payment_items
--                     with _ALL table.
-------------------------------------------------------------------------------

PROCEDURE chk_for_exported_items
(
   ip_index_period_id   IN           NUMBER
  ,op_msg               OUT NOCOPY   VARCHAR2
)
AS
   v   CHAR (1) := 0;
BEGIN
   --
   -- p_msg
   --    - PN_EXPORTED_ITEM_NOT_FOUND - no index lease found
   --    - PN_EXPORTED_ITEM_FOUND - no index lease period with this id was found
   --

   BEGIN
      SELECT '1'
        INTO v
        FROM DUAL
       WHERE EXISTS ( SELECT 1
                      FROM pn_payment_items_all ppi, pn_payment_terms_all ppt
                      WHERE ppt.payment_term_id = ppi.payment_term_id
                      AND ppi.payment_item_type_lookup_code = 'CASH'
                      AND (   ppi.transferred_to_ap_flag = 'Y'
                           OR ppi.transferred_to_ar_flag = 'Y')
                      AND ppt.index_period_id = ip_index_period_id);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         v := '0';
         op_msg := 'PN_EXPORTED_ITEM_NOT_FOUND';
   END;

   IF v = '1'
   THEN
      op_msg := 'PN_EXPORTED_ITEM_FOUND';
   END IF;
END chk_for_exported_items;



-------------------------------------------------------------------------------
-- PROCDURE     : chk_for_payment_reqd_fields
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 10-Jul-01 psidhu  o Bug # 1875457 - Commented check for code_combination_id
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_leases, pn_payment_terms with
--                     _ALL table.
-------------------------------------------------------------------------------
   PROCEDURE chk_for_payment_reqd_fields (
      p_payment_term_id   IN       NUMBER
     ,p_msg               OUT NOCOPY      VARCHAR2) IS
      CURSOR curr_payment_term (
         ip_payment_term_id   IN   NUMBER) IS
         SELECT pl.lease_id
               ,pl.lease_num
               ,pl.lease_class_code
               ,ppt.payment_term_id
               ,ppt.payment_purpose_code
               ,ppt.payment_term_type_code
               ,ppt.frequency_code
               ,ppt.start_date
               ,ppt.end_date
               ,ppt.schedule_day
               ,ppt.vendor_id
               ,ppt.vendor_site_id
               ,ppt.customer_id
               ,ppt.customer_site_use_id
               ,ppt.code_combination_id
           FROM pn_leases_all pl, pn_payment_terms_all ppt
          WHERE pl.lease_id = ppt.lease_id
            AND ppt.payment_term_id = ip_payment_term_id;

      rec_payment_term   curr_payment_term%ROWTYPE;
   BEGIN
      --
      -- getting payment termdetails
      --
      OPEN curr_payment_term (p_payment_term_id);
      FETCH curr_payment_term INTO rec_payment_term;

      --
      -- if payment term is found...
      --
      IF curr_payment_term%FOUND THEN
         --
         -- checking if any of required fields for a direct lease is missing
         -- if any field is missing, returning message
         --

         IF (rec_payment_term.lease_class_code = pn_index_amount_pkg.c_lease_class_direct) THEN
            IF (   rec_payment_term.payment_term_id IS NULL
                OR rec_payment_term.payment_purpose_code IS NULL
                OR rec_payment_term.payment_term_type_code IS NULL
                OR rec_payment_term.frequency_code IS NULL
                OR rec_payment_term.start_date IS NULL
                OR rec_payment_term.end_date IS NULL
                OR rec_payment_term.schedule_day IS NULL
                OR rec_payment_term.vendor_id IS NULL
                OR rec_payment_term.vendor_site_id IS NULL
            --  OR rec_payment_term.code_combination_id IS NULL
               )
               THEN
               p_msg := 'PN_REQD_FLDS_PAY_DIRECT';
            END IF;
         -- if any field is missing, returning message
         --
         -- checking if any of required fields for a 3rd class lease is missing
         -- if any field is missing, returning message
         --
         ELSIF (   rec_payment_term.payment_term_id IS NULL
                OR rec_payment_term.payment_purpose_code IS NULL
                OR rec_payment_term.payment_term_type_code IS NULL
                OR rec_payment_term.frequency_code IS NULL
                OR rec_payment_term.start_date IS NULL
                OR rec_payment_term.end_date IS NULL
                OR rec_payment_term.schedule_day IS NULL
                OR rec_payment_term.customer_id IS NULL
                OR rec_payment_term.customer_site_use_id IS NULL
           --   OR rec_payment_term.code_combination_id IS NULL
               )
                THEN
            p_msg := 'PN_REQD_FLDS_PAY_3CLASS';
         END IF;
      END IF; --curr_payment_term%FOUND

      CLOSE curr_payment_term;
   END chk_for_payment_reqd_fields;



------------------------------------------------------------------------
-- PROCEDURE : put_log
------------------------------------------------------------------------
   PROCEDURE put_log (
      p_string   VARCHAR2) IS
   BEGIN
         fnd_file.put_line (fnd_file.LOG, p_string);
   END put_log;


------------------------------------------------------------------------
-- PROCEDURE : put_OUTPUT
------------------------------------------------------------------------
   PROCEDURE put_output (
      p_string   VARCHAR2) IS
   BEGIN
         fnd_file.put_line (fnd_file.LOG, p_string);
         fnd_file.put_line (fnd_file.output, p_string);
   END put_output;


/*===========================================================================+
 | PROCEDURE
 |   Find_Base_Index
 |
 | DESCRIPTION
 |   Finds the base Index value for an Index and Base year
 |
 | ARGUMENTS: index_id, base-year
 |
 | NOTES:
 |   Called at all Debug points spread across this file
 |
 | USED BY:
 |   PNTINDEX
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/


   FUNCTION find_base_index (
      p_index_id    IN   NUMBER
     ,p_base_year   IN   DATE )
      RETURN NUMBER IS
      v_base_index   NUMBER := NULL;
   BEGIN
      BEGIN
         SELECT lines.index_figure
           INTO v_base_index
           FROM pn_index_history_lines lines, pn_index_history_headers headers
          WHERE lines.index_id = headers.index_id
            AND TO_CHAR (lines.index_date, 'MON-RRRR') = TO_CHAR (p_base_year, 'MON-RRRR')
            AND lines.index_id = p_index_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_base_index := NULL;
      END;

      RETURN v_base_index;
   END find_base_index;

-------------------------------------------------------------------------------
-- PROCDURE     : get_index_lease
-- INVOKED FROM :
-- PURPOSE      : Procedure to get Index Lease details
-- HISTORY      :
-- 26-NOV-03 DThota o bug 3271061 - Added parameters p_aggregation_flag,
--                    p_index_finder_months to get_index_lease.
-- 11-JUL-05 hrodda o Bug 4284035 - Replaced pn_index_leases with _ALL table.
-- 09-NOV-06 Prabhakar o Added p_index_multiplier parameter.
-- 08-DEC-06 Prabhakar o Added proration_rule,proratio_period_start_date
--                       to get_index_lease
-------------------------------------------------------------------------------
PROCEDURE get_index_lease
(
   p_index_lease_id          IN              NUMBER
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
  ,p_proration_period_start_date OUT NOCOPY  DATE
)
AS

   v   CHAR (1) := 0;
   CURSOR c IS
      SELECT *
      FROM pn_index_leases_all
      WHERE index_lease_id = p_index_lease_id;
BEGIN
   FOR c_rec IN c
   LOOP
      p_commencement_date := c_rec.commencement_date;
      p_termination_date := c_rec.termination_date;
      p_assessment_date := c_rec.assessment_date;
      p_assessment_interval := c_rec.assessment_interval;
      p_relationship_default := c_rec.relationship_default;
      p_spread_frequency := c_rec.spread_frequency;
      p_basis_percent_default := c_rec.basis_percent_default;
      p_intial_basis := c_rec.initial_basis;
      p_base_index := c_rec.base_index;
      p_index_finder_method := c_rec.index_finder_method;
      p_negative_rent_type := c_rec.negative_rent_type;
      p_increase_on := c_rec.increase_on;
      p_basis_type := c_rec.basis_type;
      p_reference_period := c_rec.reference_period;
      p_base_year := c_rec.base_year;
      p_rounding_flag := c_rec.rounding_flag;
      p_gross_flag := c_rec.gross_flag;
      p_carry_forward_flag := c_rec.carry_forward_flag;
      p_aggregation_flag   := c_rec.aggregation_flag;
      p_index_finder_months := c_rec.index_finder_months;
      p_index_multiplier := nvl (c_rec.index_multiplier, 1);
      p_proration_rule := nvl (c_rec.proration_rule, 'NO_PRORATION');
      p_proration_period_start_date := c_rec.proration_period_start_date;
   END LOOP;
END get_index_lease;

-------------------------------------------------------------------------------
-- PROCDURE     : get_index_period
-- INVOKED FROM :
-- PURPOSE      : Procedure to get Index Period details
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_lease_periods with _ALL
--                     table.
-- 09-NOV-06  Prabhakar o Added index_multiplier
-------------------------------------------------------------------------------
PROCEDURE get_index_period
(
   p_index_period_id        IN              NUMBER
  ,p_basis_start_date       OUT NOCOPY      DATE
  ,p_basis_end_date         OUT NOCOPY      DATE
  ,p_index_finder_date      OUT NOCOPY      DATE
  ,p_current_basis          OUT NOCOPY      NUMBER
  ,p_relationship           OUT NOCOPY      VARCHAR2
  ,p_index_percent_change   OUT NOCOPY      NUMBER
  ,p_basis_percent_change   OUT NOCOPY      NUMBER
  ,p_index_multiplier       OUT NOCOPY      NUMBER
)
AS
   v   CHAR (1) := 0;

   CURSOR c IS
      SELECT *
        FROM pn_index_lease_periods_all
       WHERE index_period_id = p_index_period_id;
BEGIN
   FOR c_rec IN c
   LOOP
      p_basis_start_date := c_rec.basis_start_date;
      p_basis_end_date := c_rec.basis_end_date;
      p_index_finder_date := c_rec.index_finder_date;
      p_current_basis := c_rec.current_basis;
      p_relationship := c_rec.relationship;
      p_index_percent_change := c_rec.index_percent_change;
      p_basis_percent_change := c_rec.basis_percent_change;
      p_index_multiplier := nvl (c_rec.index_multiplier, 1);
   END LOOP;
END get_index_period;




-------------------------------------------------------------------------------
-- PROCDURE     : get_index_start_end_dates
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_lease_details, pn_leases,
--                     pn_index_lease_periods, pn_index_leases with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE get_index_start_end_dates
(
   p_index_period_id        IN       NUMBER
  ,p_commencement_date      OUT NOCOPY      DATE
  ,p_termination_date       OUT NOCOPY      DATE
)
AS
   CURSOR c IS
      SELECT index_leases.commencement_date, lease_det.lease_termination_date
      FROM   pn_index_lease_periods_all periods, pn_index_leases_all index_leases,
             pn_leases_all leases, pn_lease_details_all lease_det
      WHERE  periods.index_period_id = p_index_period_id
      AND    index_leases.index_lease_id = periods.index_lease_id
      AND    index_leases.lease_id = leases.lease_id
      AND    leases.lease_id = lease_det.lease_id
      AND    rownum = 1;
BEGIN
   FOR c_rec IN c
   LOOP
      p_commencement_date := c_rec.commencement_date;
      p_termination_date := c_rec.lease_termination_date;
   END LOOP;
END get_index_start_end_dates;



   /*===========================================================================+
 | PROCEDURE
 |   get_index_details
 |
 | DESCRIPTION
 |   Procedure to get Index Type details
 |
 | ARGUMENTS:
 |
 | NOTES:
 |
 | MODIFICATION HISTORY
 |
 |
 +===========================================================================*/
   PROCEDURE get_index_details (
      p_index_line_id   IN       NUMBER
     ,p_index_date      OUT NOCOPY      DATE
     ,p_index_figure    OUT NOCOPY      NUMBER) AS
      v   CHAR (1) := 0;

      CURSOR c IS
         SELECT *
           FROM pn_index_history_lines
          WHERE index_line_id = p_index_line_id;
   BEGIN
      FOR c_rec IN c
      LOOP
         p_index_date := c_rec.index_date;
         p_index_figure := c_rec.index_figure;
      END LOOP;
   END get_index_details;


------------------------------------------------------------------------
-- PROCEDURE : GET_AR_PAYMENT_TERM
-- HISTORY:
-- 28-NOV-05 pikhar o Changed ra_terms_v to ra_terms
------------------------------------------------------------------------

   FUNCTION get_ar_payment_term (
      p_term_id   NUMBER)
      RETURN VARCHAR2 IS
      l_name   VARCHAR2 (15);
   BEGIN
      SELECT name
        INTO l_name
        FROM ra_terms
       WHERE term_id = p_term_id;
      RETURN l_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_ar_payment_term;


------------------------------------------------------------------------
-- PROCEDURE : GET_AP_PAYMENT_TERM
-- HISTORY:
-- 28-NOV-05 pikhar o Changed ap_terms_v to ap_terms
------------------------------------------------------------------------

   FUNCTION get_ap_payment_term (
      p_term_id   NUMBER)
      RETURN VARCHAR2 IS
      l_name   VARCHAR2 (50);
   BEGIN
      SELECT name
        INTO l_name
        FROM ap_terms
       WHERE term_id = p_term_id;
      RETURN l_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_ap_payment_term;


--------------------------------------------------------------------------------
-- PROCEDURE : GET_AR_TRX_TYPE
-- HISTORY
-- 28-NOV-05 pikhar o Replaced ra_cust_trx_types with _ALL table.
-- REDUNDANT FUNCTION - DO NOT USE!!
--------------------------------------------------------------------------------

   FUNCTION get_ar_trx_type (
      p_cust_trx_type_id   NUMBER)
      RETURN VARCHAR2 IS
      l_name   VARCHAR2 (20);
   BEGIN
      SELECT name
        INTO l_name
        FROM ra_cust_trx_types
       WHERE cust_trx_type_id = p_cust_trx_type_id;
      RETURN l_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_ar_trx_type;


-------------------------------------------------------------------------------
-- PROCDURE     : get_index_period_details
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_lease_periods with _ALL
--                     table.
-------------------------------------------------------------------------------

FUNCTION get_index_period_details (
   p_index_period_id   NUMBER)
   RETURN index_lease_periods_rec
IS
   l_index_lease_periods_rec   index_lease_periods_rec;
BEGIN
   SELECT current_basis
      ,constraint_rent_due
      ,unconstraint_rent_due
      ,index_percent_change
      ,current_index_line_id
      ,current_index_line_value
      ,previous_index_line_id
      ,previous_index_line_value
   INTO l_index_lease_periods_rec
   FROM pn_index_lease_periods_all
   WHERE index_period_id = p_index_period_id;
   RETURN l_index_lease_periods_rec;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END get_index_period_details;


-------------------------------------------------------------------------------
-- PROCDURE     : get_lease_change_id
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_lease_changes with _ALL table.
-------------------------------------------------------------------------------

FUNCTION get_lease_change_id (
   p_lease_id   NUMBER)
   RETURN NUMBER
IS
   l_lease_change_id   NUMBER;
BEGIN
   SELECT lease_change_id
   INTO l_lease_change_id
   FROM pn_lease_changes_all
   WHERE lease_change_number IS NULL
   AND lease_id = p_lease_id;
   RETURN l_lease_change_id;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END get_lease_change_id;

-------------------------------------------------------------------------------
-- PROCDURE     : delete_index_payment_term
-- PURPOSE      : This procedure will delete index payment terms and its associated
--                records in the intersection table for an index period
-- ARGUMENTS    : IN : index_period_id - index rent period id (MANDATORY)
--                     payment_period_id - payment period id (OPTIONAL);
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_payment_terms with _ALL table.
-------------------------------------------------------------------------------

PROCEDURE delete_index_payment_term (
   p_index_period_id   IN       NUMBER
  ,p_payment_term_id   IN       NUMBER
  ,p_msg               OUT NOCOPY      VARCHAR2) IS
   l_tax_data_rec   tax_data_rec;
BEGIN
   DELETE FROM  pn_payment_terms_all
   WHERE (   payment_term_id = p_payment_term_id
          OR p_payment_term_id IS NULL)
   AND index_period_id = p_index_period_id;

   --      IF SQL%NOTFOUND
   --      THEN
   --         --DBMS_OUTPUT.put_line ('NO ROWS DELETED');
   --      ELSE
   --         --DBMS_OUTPUT.put_line ('ROWS DELETED FROM pn_payment_terms');
   --      END IF;


   --      IF SQL%NOTFOUND
   --      THEN
   --         --DBMS_OUTPUT.put_line ('NO ROWS DELETED');
   --      ELSE
   --         --DBMS_OUTPUT.put_line ('ROWS DELETED FROM pn_index_period_terms');
   --      END IF;
END delete_index_payment_term;


-------------------------------------------------------------------------------
-- PROCDURE     : find_if_period_exists
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_lease_periods with _ALL
--                     table.
-------------------------------------------------------------------------------
FUNCTION find_if_period_exists (
   p_index_lease_id   NUMBER)
   RETURN NUMBER
IS
   l_period_exists   NUMBER;
BEGIN
   SELECT 1
   INTO l_period_exists
   FROM DUAL
   WHERE EXISTS ( SELECT periods.index_period_id
                  FROM pn_index_lease_periods_all periods
                 WHERE periods.index_lease_id = p_index_lease_id);
   RETURN l_period_exists;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END find_if_period_exists;


-------------------------------------------------------------------------------
-- PROCDURE     : find_if_term_exists
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_payment_terms with _ALL table.
-------------------------------------------------------------------------------
FUNCTION find_if_term_exists (
   p_index_period_id   NUMBER)
   RETURN NUMBER
 IS
   l_term_exists   NUMBER;
BEGIN
   SELECT 1
   INTO l_term_exists
   FROM DUAL
   WHERE EXISTS ( SELECT ppt.payment_term_id
                  FROM pn_payment_terms_all ppt
                  WHERE ppt.index_period_id = p_index_period_id);
   RETURN l_term_exists;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END find_if_term_exists;


-------------------------------------------------------------------------------
-- PROCDURE     : find_if_norm_term_exists
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_payment_terms with _ALL table.
-------------------------------------------------------------------------------
FUNCTION find_if_norm_term_exists (
   p_index_period_id   NUMBER)
   RETURN NUMBER
IS
   l_term_exists   NUMBER;
BEGIN
   SELECT 1
   INTO l_term_exists
   FROM DUAL
   WHERE EXISTS ( SELECT ppt.payment_term_id
                  FROM pn_payment_terms_all ppt
                  WHERE ppt.index_period_id = p_index_period_id
                  AND ppt.status = 'APPROVED');
   RETURN l_term_exists;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END find_if_norm_term_exists;


-------------------------------------------------------------------------------
-- PROCDURE     : find_if_template_used
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_leases, pn_term_templates
--                     with _ALL table.
-------------------------------------------------------------------------------
FUNCTION find_if_template_used (
   p_term_template_id   NUMBER)
   RETURN NUMBER
IS
   l_template_used   NUMBER;
BEGIN
   SELECT 1
   INTO l_template_used
   FROM DUAL
   WHERE EXISTS ( SELECT pil.index_lease_id
                  FROM pn_index_leases_all pil, pn_term_templates_all ptt
                  WHERE ptt.term_template_id = pil.term_template_id
                  AND ptt.term_template_id = p_term_template_id);
   RETURN l_template_used;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END find_if_template_used;


-------------------------------------------------------------------------------
-- PROCDURE     : get_term_status
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_payment_terms with _ALL table.
-------------------------------------------------------------------------------
FUNCTION get_term_status (
   p_payment_term_id   NUMBER)
   RETURN VARCHAR2
IS
   l_term_status   VARCHAR2 (30);
BEGIN
   SELECT status
   INTO l_term_status
   FROM pn_payment_terms_all
   WHERE payment_term_id = p_payment_term_id;
   RETURN l_term_status;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END get_term_status;

----------------------------------------------------------------------
-- PROCEDURE : GET PO NUMBER
-- HISTORY:
-- 28-NOV-05 pikhar o Replaced  po_headers with _all Table
------------------------------------------------------------------------

FUNCTION get_po_number (
   p_po_header_id   NUMBER)
   RETURN VARCHAR2
IS
   l_po_number   VARCHAR2 (30);
BEGIN
   SELECT segment1
   INTO l_po_number
   FROM po_headers_all
   WHERE po_header_id = p_po_header_id;
   RETURN l_po_number;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END get_po_number;


------------------------------------------------------------------------
-- PROCEDURE : GET RECEIPT METHOD
------------------------------------------------------------------------

      FUNCTION get_receipt_method (
         p_receipt_method_id   NUMBER)
         RETURN VARCHAR2 IS
         l_receipt_method   VARCHAR2 (30);
      BEGIN
         SELECT name
           INTO l_receipt_method
           FROM ar_receipt_methods
          WHERE receipt_method_id = p_receipt_method_id;
         RETURN l_receipt_method;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN NULL;
      END get_receipt_method;


------------------------------------------------------------------------
-- PROCEDURE : GET LOCATION CODE
-- 30-oct-2002 - date effectivity change
------------------------------------------------------------------------

   FUNCTION get_location (
      p_location_id   NUMBER)
      RETURN VARCHAR2 IS
      l_location_code   VARCHAR2 (90);
   BEGIN
      SELECT location_code
        INTO l_location_code
        FROM pn_locations_all
       WHERE location_id = p_location_id
       AND ROWNUM < 2;
      RETURN l_location_code ;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_location;


------------------------------------------------------------------------
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
     ,op_msg                OUT NOCOPY      VARCHAR2) IS
      v_index_line_id   pn_index_history_lines.index_line_id%TYPE;
      v_index_figure    pn_index_history_lines.index_figure%TYPE;
   BEGIN
      --put_log ('..In lookup_index_history');
      --
      -- Do a lookup on index history using finder date
      --
      SELECT phl.index_line_id
            ,phl.index_figure
        INTO v_index_line_id
            ,v_index_figure
        FROM pn_index_history_lines phl
       WHERE phl.index_id = p_index_history_id
         AND TO_CHAR (phl.index_date, 'Mm-YYYY') =
                                                  TO_CHAR (p_index_finder_date, 'Mm-YYYY');
      --
      -- Only return value and id if the index value is populated
      --
      op_cpi_value := v_index_figure;
      op_cpi_id := v_index_line_id;
   EXCEPTION
      WHEN TOO_MANY_ROWS
      THEN
         put_log ('      Cannot Derive Index Amount - TOO_MANY_ROWS');
      WHEN NO_DATA_FOUND
      THEN
         --put_log ('      Cannot Derive Index Amount - NO_DATA_FOUND');
         put_log (
               '      Cannot Find Index Record for '
            || NVL (TO_CHAR (p_index_finder_date, 'mon-yy'), 'No Finder Date Provided'));
      WHEN OTHERS
      THEN
         put_log (   '      Cannot Derive Index Amount - Unknow Error:'
                  || SQLERRM);
   END lookup_index_history;


-------------------------------------------------------------------------------
-- PROCDURE     : get_term_template
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_term_templates with _ALL table.
-------------------------------------------------------------------------------
FUNCTION get_term_template (
   p_term_template_id   NUMBER)
   RETURN VARCHAR2
IS
   l_term_template   VARCHAR2 (100);
BEGIN
   SELECT name
   INTO l_term_template
   FROM pn_term_templates_all
   WHERE term_template_id = p_term_template_id;
   RETURN l_term_template;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END get_term_template;


------------------------------------------------------------------------
-- PROCEDURE : GET_APPROVER
------------------------------------------------------------------------

   FUNCTION get_approver (
      p_approved_by   NUMBER)
      RETURN VARCHAR2 IS
      l_approver   VARCHAR2 (100);
   BEGIN
      SELECT user_name
        INTO l_approver
        FROM fnd_user
       WHERE user_id = p_approved_by;
      RETURN l_approver;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_approver;


-------------------------------------------------------------------------------
-- PROCDURE     : get_lease_class
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_leases with _ALL table.
-------------------------------------------------------------------------------

FUNCTION get_lease_class (
   p_lease_id   NUMBER)
   RETURN VARCHAR2
IS
   l_lease_class   VARCHAR2 (30);
BEGIN
   SELECT lease_class_code
   INTO l_lease_class
   FROM pn_leases_all
   WHERE lease_id = p_lease_id;
   RETURN l_lease_class;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END get_lease_class;


------------------------------------------------------------------------
-- PROCEDURE : append_msg
-- DESCRIPTION: This procedure will append the new message (p_new_messages) to
--              existing messages.
--
------------------------------------------------------------------------

   PROCEDURE append_msg (
      p_new_msg   IN       VARCHAR2
     ,p_all_msg   IN OUT NOCOPY   VARCHAR2) IS
      v_existing_msg   VARCHAR2 (1000);
   BEGIN
      v_existing_msg := p_all_msg;

      IF p_new_msg IS NOT NULL
      THEN
         IF    p_all_msg = 'PN_INDEX_SUCCESS'
            OR p_all_msg IS NULL
         THEN
            p_all_msg := p_new_msg;
         ELSE
            -- checking if error already has been recorded
            IF INSTR (v_existing_msg, p_new_msg) = 0
            THEN
               p_all_msg :=    v_existing_msg
                            || ','
                            || p_new_msg;
            END IF; --INSTR (v_existing_msg, p_new_msg) = 0
         END IF; --
      END IF; --p_new_msg IS NOT NULL
   END append_msg;


------------------------------------------------------------------------
-- PROCEDURE : GET_SALESPERSON
-- HISTORY
-- 24-MAR-06 Hareesha  o Bug # 5116270 Added org_id parameter to
--                      get_salesperson
------------------------------------------------------------------------
   FUNCTION get_salesperson (
      p_salesrep_id   NUMBER,
      p_org_id NUMBER) RETURN VARCHAR2 IS

      l_salesperson   ra_salesreps.name%type;

      CURSOR get_salesrep_cur IS
         SELECT name
         FROM ra_salesreps
         WHERE salesrep_id = p_salesrep_id
         AND org_id = p_org_id;

   BEGIN
      FOR rec IN get_salesrep_cur LOOP
         l_salesperson := rec.name;
      END LOOP;

      RETURN l_salesperson;
   EXCEPTION
      WHEN OTHERS THEN
         RAISE;

   END get_salesperson;


------------------------------------------------------------------------
-- PROCEDURE : GET_INVOICING_RULE
------------------------------------------------------------------------

   FUNCTION get_invoicing_rule (
      p_rule_id   NUMBER)
      RETURN VARCHAR2 IS
      l_invoicing_rule   VARCHAR2 (100);
   BEGIN
      SELECT name
        INTO l_invoicing_rule
        FROM ra_rules
       WHERE rule_id = p_rule_id;
      RETURN l_invoicing_rule;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_invoicing_rule;

   ------------------------------------------------------------------------
-- PROCEDURE : GET_ACCOUNTING_RULE
------------------------------------------------------------------------

   FUNCTION get_accounting_rule (
      p_rule_id   NUMBER)
      RETURN VARCHAR2 IS
      l_accounting_rule   VARCHAR2 (100);
   BEGIN
      SELECT name
        INTO l_accounting_rule
        FROM ra_rules
       WHERE rule_id = p_rule_id;
      RETURN l_accounting_rule;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_accounting_rule;


------------------------------------------------------------------------
-- PROCEDURE : GET_DISTRIBUTION_SET
-- HISTORY:
-- 28-NOV-05 pikhar o Replaced ap_distribution_set with _ALL table
------------------------------------------------------------------------

   FUNCTION get_distribution_set (
      p_distribution_set_id   NUMBER)
      RETURN VARCHAR2 IS
      l_distribution_set   VARCHAR2 (100);
   BEGIN
      SELECT distribution_set_name
        INTO l_distribution_set
        FROM ap_distribution_sets_all
       WHERE distribution_set_id = p_distribution_set_id;
      RETURN l_distribution_set;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_distribution_set;


/*============================================================================+
--  NAME         : get_project_details
--  DESCRIPTION  : This FUNCTION RETURNs details of a project for a project id.
--  SCOPE        : PUBLIC
--  INVOKED FROM : forms libraries
--  ARGUMENTS    : IN : p_project_id, p_project_name, p_organization
--  RETURNS      : Transaction Type
--  HISTORY      :
--  24-Jun-05 piagrawa o Bug 4284035 - Replaced pa_projects with _all tables.
+============================================================================*/
PROCEDURE get_project_details (
   p_project_id     IN              NUMBER
  ,p_project_name   OUT NOCOPY      VARCHAR2
  ,p_organization   OUT NOCOPY      VARCHAR2) AS
   CURSOR c IS
      SELECT projects.name project_name
            ,org.name organization
      FROM pa_projects_all projects, hr_organization_units org
      WHERE projects.project_id = p_project_id
      AND projects.carrying_out_organization_id = org.organization_id;
BEGIN
   FOR c_rec IN c
   LOOP
      p_project_name := c_rec.project_name;
      p_organization := c_rec.ORGANIZATION;
   END LOOP;
END get_project_details;

-------------------------------------------------------------------------------
-- PROCDURE     : find_if_hist_line_used
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_lease_periods,
--                     with _ALL table.
-------------------------------------------------------------------------------
FUNCTION find_if_hist_line_used (
   p_index_line_id   NUMBER)
   RETURN NUMBER IS
   l_hist_line_used   NUMBER;
BEGIN
   BEGIN
      SELECT 1
        INTO l_hist_line_used
        FROM DUAL
       WHERE EXISTS ( SELECT periods.previous_index_line_id
                      FROM pn_index_lease_periods_all periods
                            ,pn_index_history_lines lines
                      WHERE periods.previous_index_line_id = lines.index_line_id
                      AND lines.index_line_id = p_index_line_id);
      RETURN l_hist_line_used;
   EXCEPTION
      WHEN OTHERS
      THEN
         l_hist_line_used := NULL;
   END;

   IF l_hist_line_used IS NULL
   THEN
      BEGIN
         SELECT 2
           INTO l_hist_line_used
           FROM DUAL
          WHERE EXISTS ( SELECT periods.current_index_line_id
                         FROM pn_index_lease_periods_all periods
                               ,pn_index_history_lines lines
                         WHERE periods.current_index_line_id = lines.index_line_id
                         AND lines.index_line_id = p_index_line_id);
         RETURN l_hist_line_used;
      EXCEPTION
         WHEN OTHERS
         THEN
            l_hist_line_used := NULL;
      END;
   END IF;

   RETURN l_hist_line_used;
END find_if_hist_line_used;

-------------------------------------------------------------------------------
-- PROCDURE     : find_if_calc_exists
-- INVOKED FROM :
-- PURPOSE      : Find if Calculation is Done
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_payment_terms,pn_index_leases
--                     pn_index_lease_periods with _ALL table.
-------------------------------------------------------------------------------
FUNCTION find_if_calc_exists (
   p_index_lease_id   NUMBER)
   RETURN NUMBER IS
   l_calc_exists   NUMBER;
BEGIN
   SELECT 1
   INTO l_calc_exists
   FROM DUAL
   WHERE EXISTS ( SELECT terms.payment_term_id
                  FROM pn_payment_terms_all terms
                      ,pn_index_leases_all lease
                      ,pn_index_lease_periods_all periods
                  WHERE terms.index_period_id = periods.index_period_id
                  AND periods.index_lease_id = lease.index_lease_id
                  AND lease.index_lease_id = p_index_lease_id);
   RETURN l_calc_exists;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END find_if_calc_exists;

-------------------------------------------------------------------------------
-- PROCDURE     : find_if_basis_exists
-- INVOKED FROM :
-- PURPOSE      : Find if Current Basis Exists for any period
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_lease_periods with _ALL
--                     table.
-------------------------------------------------------------------------------
FUNCTION find_if_basis_exists (
   p_index_lease_id   NUMBER)
   RETURN NUMBER
IS
   l_basis_exists   NUMBER;
BEGIN
   SELECT 1
   INTO l_basis_exists
   FROM DUAL
   WHERE EXISTS ( SELECT current_basis
                  FROM   pn_index_lease_periods_all
                  WHERE  index_lease_id = p_index_lease_id
                  AND    current_basis is null);
   RETURN l_basis_exists;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN NULL;
END find_if_basis_exists;

-------------------------------------------------------------------------------
-- PROCDURE     : GET_MAX_SCHEDULE_DATE
-- INVOKED FROM :
-- PURPOSE      : Get the max schedule date from pn_payment_schedules
--                that has exported items associated with it.
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_payment_schedules with _ALL table.
-------------------------------------------------------------------------------
FUNCTION GET_MAX_SCHEDULE_DATE (p_index_leaseId       IN NUMBER
                               ) RETURN    DATE
IS

l_max_sch_date       DATE ;

BEGIN
    BEGIN
      SELECT max(SCHEDULE_DATE)
      INTO   l_max_sch_date
      FROM pn_index_lease_periods_all pilp,
           pn_payment_terms_all     ppt,
           pn_payment_items_all     ppi,
           pn_payment_schedules_all pps
      WHERE pilp.index_period_id=ppt.index_period_id
      AND   ppt.payment_term_id=ppi.payment_term_id
      AND   pps.payment_schedule_id=ppi.payment_schedule_id
      AND   (ppi.export_to_ar_flag='Y' OR
          ppi.export_to_ap_flag='Y' )
      AND  pilp.index_lease_id=p_index_leaseId;

    EXCEPTION
    when NO_DATA_FOUND then
         return NULL;
    END;
      return l_max_sch_date;
END GET_MAX_SCHEDULE_DATE;

  ------------------------------------------------------------------------
  -- FUNCTION : GET_PROJECT_NAME
  -- HISTORY
  -- 23-APR-04 ftanudja o Changed pa_projects_expend_v to pa_projects
  --                      for performance. #3239094.
  -- 28-NOV-05 pikhar   o replaced pa_projects with _ALL table
  ------------------------------------------------------------------------

   FUNCTION get_project_name (
      p_project_id   NUMBER)
      RETURN VARCHAR2 IS
      l_project_name   VARCHAR2 (100);
   BEGIN
      SELECT name
        INTO l_project_name
        FROM pa_projects_all
       WHERE project_id = p_project_id;
      RETURN l_project_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_project_name;

-------------------------------------------------------------------------------
-- PROCDURE     : chk_for_approved_index_periods
-- INVOKED FROM :
-- PURPOSE      :
-- HISTORY      :
-- 11-JUL-05  hrodda o Bug 4284035 - Replaced pn_index_exclude_term with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE get_exclude_term ( p_index_lease_id        IN NUMBER,
                             p_payment_term_id       IN NUMBER,
                             p_exclude_flag          OUT NOCOPY VARCHAR2,
                             p_index_exclude_term_id OUT NOCOPY NUMBER)
IS
BEGIN
     SELECT 'N' ,index_exclude_term_id
     INTO p_exclude_flag,p_index_exclude_term_id
     FROM  pn_index_exclude_term_all
     WHERE index_lease_id=p_index_lease_id
     AND payment_term_id=p_payment_term_id;

EXCEPTION
     WHEN OTHERS
     THEN
        NULL;
END get_exclude_term;

------------------------------------------------------------------------
-- FUNCTION : GET_AP_ORGANIZATION_NAME
-- HISTORY :
--   25-MAR-2004   Mrinal Misra   o Changed view name in SELECT statement.
------------------------------------------------------------------------

   FUNCTION get_ap_organization_name (
      p_organization_id NUMBER )
      RETURN VARCHAR2 IS
      l_organization_name   VARCHAR2 (60);
   BEGIN
     SELECT name
     INTO l_organization_name
     FROM pa_organizations_expend_v
     WHERE organization_id = p_organization_id;
     RETURN l_organization_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_ap_organization_name;

-------------------------------------------------------------------------------
--  NAME         : UPDATE_LOCATION_FOR_IR_TERMS()
--  PURPOSE      : Updates the location ID for the terms assocaited with IR
--  DESCRIPTION  : Updates the location ID for the terms assocaited with IR
--                 whenever the location associated with IR agreement is
--                 updated.
--  SCOPE        : PUBLIC
--  ARGUMENTS    : p_index_lease_id : index lease ID.
--                 p_location_id : new location ID that terms to be updated with
--                 p_return_status : return status of the procedure
--  RETURNS      : None
--  HISTORY      :
--   03-JUN-04  ATUPPAD  o Created.
--                         For 'Edit location at IR Agreement' enhancement.
-------------------------------------------------------------------------------
PROCEDURE UPDATE_LOCATION_FOR_IR_TERMS(
          p_index_lease_id   IN  NUMBER,
          p_location_id      IN  NUMBER,
          p_return_status    OUT NOCOPY VARCHAR2)
IS

CURSOR C_UPD_TERMS IS
  SELECT ppt.payment_term_id,
         NVL(ppt.status, 'X')
  FROM   PN_PAYMENT_TERMS_ALL ppt,
         PN_INDEX_LEASE_PERIODS_ALL pilp
  WHERE  ppt.status = 'DRAFT'
  AND    ppt.index_period_id = pilp.index_period_id
  AND    pilp.index_lease_id = p_index_lease_id
  UNION ALL
  SELECT ppt.payment_term_id,
         NVL(ppt.status, 'X')
  FROM   PN_PAYMENT_TERMS_ALL ppt,
         PN_INDEX_LEASE_PERIODS_ALL pilp,
         PN_LEASES_ALL pl
  WHERE  ppt.status = 'APPROVED'
  AND    ppt.lease_id = pl.lease_id
  AND    ppt.index_period_id = pilp.index_period_id
  AND    pilp.index_lease_id = p_index_lease_id
  AND    EXISTS (SELECT NULL
                 FROM   PN_PAYMENT_ITEMS_ALL ppi
                 WHERE  DECODE(pl.lease_class_code,
                              'DIRECT',      NVL(ppi.transferred_to_ap_flag,'N'),
                              'THIRD_PARTY', NVL(ppi.transferred_to_ar_flag,'N'),
                              'SUB_LEASE',   NVL(ppi.transferred_to_ar_flag,'N')) = 'N'
                 AND    ppi.payment_term_id = ppt.payment_term_id);

TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE char_tbl_type   IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
l_payment_term_id      number_tbl_type;
l_payment_status       char_tbl_type;
l_flag                 BOOLEAN := FALSE;

BEGIN
  PNP_DEBUG_PKG.debug ('PN_INDEX_LEASE_COMMON_PKG.UPDATE_LOCATION_FOR_IR_TERMS (+)');

  OPEN C_UPD_TERMS;
  LOOP
    FETCH C_UPD_TERMS
      BULK COLLECT INTO l_payment_term_id, l_payment_status
      LIMIT 1000;

    FORALL i IN 1..l_payment_term_id.COUNT
      UPDATE PN_PAYMENT_TERMS_ALL
      SET    location_id = p_location_id
      WHERE  payment_term_id = l_payment_term_id(i);

    FOR i IN 1..l_payment_term_id.COUNT LOOP
      IF (l_payment_status(i) = 'APPROVED') THEN
        l_flag := TRUE;
        EXIT;
      END IF;
    END LOOP;

    EXIT WHEN C_UPD_TERMS%NOTFOUND;

  END LOOP;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_flag THEN
    p_return_status := 'SUCCESS_FIRE_RECALC';
  END IF;

  PNP_DEBUG_PKG.debug ('PN_INDEX_LEASE_COMMON_PKG.UPDATE_LOCATION_FOR_IR_TERMS (-)');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     p_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END UPDATE_LOCATION_FOR_IR_TERMS;

/* --- OVERLOADED functions and procedures for MOAC START --- */
/*============================================================================+
--  NAME         : get_ar_trx_type
--  DESCRIPTION  : This FUNCTION RETURNs Transaction Type for a given Customer
--                 Transaction Type Id FROM Receivables.
--  SCOPE        : PUBLIC
--  INVOKED FROM : forms libraries
--  ARGUMENTS    : IN : p_trx_id, p_org_id
--  RETURNS      : Transaction Type
--  HISTORY      :
--  24-Jun-05  piagrawa o Created
--  IMPORTANT - Use this function once MOAC is enabled. All form libraries
--              must call this.
-- 28-NOV-05 pikhar     o replaced ra_cust_trx_types with _ALL table.
+============================================================================*/

FUNCTION get_ar_trx_type ( p_cust_trx_type_id   NUMBER
                          ,p_org_id IN NUMBER) RETURN VARCHAR2 IS
l_name   VARCHAR2 (20);
BEGIN
   SELECT name
   INTO l_name
   FROM ra_cust_trx_types_all
   WHERE cust_trx_type_id = p_cust_trx_type_id
   AND   org_id = p_org_id;

   RETURN l_name;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_ar_trx_type;

-----------------------------------------------------------------------
--  NAME         : get_po_number
--  DESCRIPTION  : This FUNCTION returns the po number
--  SCOPE        : PUBLIC
--  INVOKED FROM : forms libraries
--  ARGUMENTS    : IN : p_po_header_id, p_org_id
--  RETURNS      : po number
--  HISTORY      :
--  24-Jun-05  piagrawa    o Created
--  IMPORTANT - Use this function once MOAC is enabled. All form libraries
--              must call this.
------------------------------------------------------------------------

FUNCTION get_po_number ( p_po_header_id   NUMBER
                        ,p_org_id         NUMBER) RETURN VARCHAR2
IS
   l_po_number   VARCHAR2 (30);
BEGIN
   SELECT segment1
   INTO l_po_number
   FROM po_headers_all
   WHERE po_header_id = p_po_header_id
   AND   org_id = p_org_id;

   RETURN l_po_number;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_po_number;



------------------------------------------------------------------------
--  NAME         : get_distribution_set
--  DESCRIPTION  : This FUNCTION returns the distribution set
--  SCOPE        : PUBLIC
--  INVOKED FROM : forms libraries
--  ARGUMENTS    : IN : p_distribution_set_id, p_org_id
--  RETURNS      : distribution set
--  HISTORY      :
--  24-Jun-05  piagrawa    o Created
--  IMPORTANT - Use this function once MOAC is enabled. All form libraries
--              must call this.
--  28-Nov-05  pikhar      o replaced ap_distribution_sets with _ALL
------------------------------------------------------------------------

FUNCTION get_distribution_set (p_distribution_set_id   NUMBER
                               , p_org_id              NUMBER) RETURN VARCHAR2 IS
   l_distribution_set   VARCHAR2 (100);
BEGIN
   SELECT distribution_set_name
   INTO l_distribution_set
   FROM ap_distribution_sets_all
   WHERE distribution_set_id = p_distribution_set_id
   AND   org_id = p_org_id;

   RETURN l_distribution_set;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_distribution_set;


------------------------------------------------------------------------
--  NAME         : get_project_name
--  DESCRIPTION  : This FUNCTION returns the project name.
--  SCOPE        : PUBLIC
--  INVOKED FROM : forms libraries
--  ARGUMENTS    : IN : p_project_id, p_org_id
--  RETURNS      : project name
--  HISTORY      :
--  24-Jun-05  piagrawa    o Created
--  IMPORTANT - Use this function once MOAC is enabled. All form libraries
--              must call this.
------------------------------------------------------------------------
FUNCTION get_project_name ( p_project_id   NUMBER
                           ,p_org_id       NUMBER) RETURN VARCHAR2 IS
   l_project_name   VARCHAR2 (100);
BEGIN
   SELECT name
   INTO l_project_name
   FROM pa_projects_all
   WHERE project_id = p_project_id
   AND   org_id     = p_org_id;

   RETURN l_project_name;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_project_name;
/* --- OVERLOADED functions and procedures for MOAC END --- */

END pn_index_lease_common_pkg;

/
