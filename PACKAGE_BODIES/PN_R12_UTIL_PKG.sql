--------------------------------------------------------
--  DDL for Package Body PN_R12_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_R12_UTIL_PKG" AS
/* $Header: PNUTL12B.pls 120.11 2008/02/11 13:39:42 rthumma ship $ */

--------------------------------------------------------------------------
-- FUNCTION    : get_tcc
-- RETURNS     : gets tax classification code given a tax id
-- NOTES       : for R12 release uptake
-- HISTORY
-- 09-MAY-05 ftanudja o created.
--------------------------------------------------------------------------
FUNCTION get_tcc (
            p_tax_code_id        pn_payment_terms.tax_code_id%TYPE,
            p_lease_class_code   pn_leases.lease_class_code%TYPE,
            p_as_of_date         pn_payment_terms.start_date%TYPE)
RETURN VARCHAR2
IS
 CURSOR tcc_info (p_source VARCHAR2) IS
   SELECT tax_classification_code
     FROM zx_id_tcc_mapping
    WHERE p_as_of_date BETWEEN nvl(effective_from, p_as_of_date)
                       AND nvl(effective_to, p_as_of_date)
      AND tax_rate_code_id = p_tax_code_id
      AND source = p_source;

 l_source   VARCHAR2(30);
 l_tcc      pn_payment_terms.tax_classification_code%TYPE;
 l_desc     VARCHAR2(100);

BEGIN

   l_desc := 'pn_r12_util_pkg.get_tcc';

   pnp_debug_pkg.log(l_desc ||' (+)');

   IF p_lease_class_code IN ('DIRECT','PAY','PAYMENT') THEN
      l_source := 'AP';
   ELSIF p_lease_class_code IN ('THIRD_PARTY','SUBLEASE','REC','BILLING') THEN
      l_source := 'AR';
   END IF;

   FOR fetch_info IN tcc_info(l_source) LOOP
      l_tcc := fetch_info.tax_classification_code;
   END LOOP;

   pnp_debug_pkg.log(l_desc ||' (-)');

   RETURN l_tcc;

END get_tcc;

--------------------------------------------------------------------------
-- FUNCTION    : get_tcc_name
-- RETURNS     : gets tax classification code name given the code
-- NOTES       : for R12 release uptake
-- HISTORY
-- 09-MAY-05 ftanudja o created.
-- 03-MAY-06 sdmahesh o Bug 5192203
--                      Rewrote the procedure to fetch TCC Billing/Payment
--                      from E Tax Views
--------------------------------------------------------------------------
FUNCTION get_tcc_name (
            p_tcc                pn_payment_terms.tax_classification_code%TYPE,
            p_lease_class_code   pn_leases.lease_class_code%TYPE,
            p_org_id             pn_term_templates.org_id%TYPE)

RETURN VARCHAR2
IS

CURSOR csr_bill IS
  SELECT meaning
  FROM zx_output_classifications_v
  WHERE enabled_flag = 'Y'
  AND trunc(SYSDATE) BETWEEN TRUNC(nvl(start_date_active,SYSDATE)) AND TRUNC(nvl(end_date_active,SYSDATE))
  AND org_id = p_org_id
  AND lookup_code = p_tcc;

CURSOR csr_pay IS
  SELECT meaning
  FROM ZX_INPUT_CLASSIFICATIONS_V
  WHERE lookup_type = 'ZX_INPUT_CLASSIFICATIONS'
  AND enabled_flag = 'Y'
  AND trunc(SYSDATE) BETWEEN TRUNC(nvl(start_date_active, SYSDATE)) AND TRUNC(nvl(end_date_active, SYSDATE))
  AND org_id = p_org_id
  AND lookup_code = p_tcc;

 l_tcc_name VARCHAR2(80);
 l_desc     VARCHAR2(100);

BEGIN

   l_desc := 'pn_r12_util_pkg.get_tcc_name';

   pnp_debug_pkg.log(l_desc ||' (+)');

   IF p_lease_class_code IN ('DIRECT','PAY') THEN

     FOR rec IN csr_pay LOOP
       l_tcc_name := rec.meaning;
     END LOOP;

   ELSIF p_lease_class_code IN ('THIRD_PARTY','SUBLEASE','REC') THEN

     FOR rec IN csr_bill LOOP
       l_tcc_name := rec.meaning;
     END LOOP;

   END IF;

   pnp_debug_pkg.log(l_desc ||' (-)');

   RETURN l_tcc_name;

END get_tcc_name;

--------------------------------------------------------------------------
-- FUNCTION    : validate_term_template_tax
-- RETURNS     : FALSE if tax classification code does not exist for a given
--               tax code or tax group
-- NOTES       : for R12 release uptake
-- HISTORY
-- 09-MAY-05 ftanudja o created.
--------------------------------------------------------------------------
FUNCTION validate_term_template_tax(
           p_term_temp_id   IN    NUMBER,
           p_lease_cls_code IN    VARCHAR2)
RETURN BOOLEAN IS

   l_answer BOOLEAN := TRUE;
   l_tcc      pn_payment_terms.tax_classification_code%TYPE;
   l_desc   VARCHAR2(100);

   CURSOR term_temp_cur(p_term_temp_id IN NUMBER) IS
      SELECT tax_code_id, tax_group_id, tax_classification_code
      FROM   pn_term_templates
      WHERE  term_template_id = p_term_temp_id;

BEGIN

   l_desc := 'pn_r12_util_pkg.validate_term_template_tax';

   pnp_debug_pkg.log(l_desc ||' (+)');

   FOR tp_rec IN term_temp_cur(p_term_temp_id) LOOP

      IF (tp_rec.tax_code_id IS NOT NULL OR
          tp_rec.tax_group_id IS NOT NULL)
        AND
         tp_rec.tax_classification_code IS NULL
      THEN

       l_tcc := pn_r12_util_pkg.get_tcc(
                  p_tax_code_id       => nvl(tp_rec.tax_code_id, tp_rec.tax_group_id),
                  p_lease_class_code  => p_lease_cls_code,
                  p_as_of_date        => SYSDATE);

       IF l_tcc IS NULL THEN
          l_answer := FALSE;
       END IF;
      END IF;
   END LOOP;

   pnp_debug_pkg.log(l_desc ||' (-)');

   RETURN l_answer;

END validate_term_template_tax;

------------------------------------------------------------------------
-- FUNCTION    : is_le_compatible
-- RETURNS     : FALSE if Legal entity is different from LE associated with
--               existing account distributions.
-- LOGIC       :
--         LE API CALL:
--         o Get LE given p_ccid1 => X
--         o Get LE given p_ccid2 => Y
--
--         IF X <> Y THEN RETURN FALSE; ELSE RETURN TRUE
-- HISTORY     :
-- 26-MAY-05 ftanudja o created.
-- 28-JUL-05 ftanudja o split from main procedure
-- 25-AUG-05 ftanudja o Removed p_location_id from is_le_compatible.
-- 17-SEP-05 sdmahesh o Added parameter p_le_id_old to get the existing
--                      legal_entity_id
------------------------------------------------------------------------

FUNCTION is_le_compatible(
           p_ccid1            IN pn_distributions.account_id%TYPE,
           p_ccid2            IN pn_distributions.account_id%TYPE,
           p_le_id_old        IN NUMBER,
           p_vendor_site_id   IN pn_payment_terms.vendor_site_id%TYPE,
           p_org_id           IN pn_payment_terms.org_id%TYPE)

RETURN BOOLEAN IS

   l_le_rec_new  xle_businessinfo_grp.ptop_le_rec;
   l_le_rec_old  xle_businessinfo_grp.ptop_le_rec;
   l_msg_data    VARCHAR2(250);
   l_ret_status  VARCHAR2(1);
   l_answer      BOOLEAN := TRUE;
   l_desc        VARCHAR2(100);
   l_le_id_old   NUMBER(15) NULL;

BEGIN

   l_desc := 'pn_r12_util_pkg.is_le_compatible - internal';

   pnp_debug_pkg.log(l_desc ||' (+)');

  /*
      LE API CALL:
      o Get LE given p_ccid1 => X
      o Get LE given p_ccid2 => Y

      IF X <> Y THEN RETURN FALSE; ELSE RETURN TRUE
   */
  l_le_id_old := p_le_id_old;
  IF l_le_id_old IS NULL THEN
     xle_businessinfo_grp.get_purchasetopay_info(
      x_return_status       => l_ret_status
     ,x_msg_data            => l_msg_data
     ,p_code_combination_id => p_ccid1
     ,p_registration_code   => null
     ,p_registration_number => null
     ,p_location_id         => p_vendor_site_id
     ,p_operating_unit_id   => p_org_id
     ,x_ptop_le_info        => l_le_rec_old
     );
     l_le_id_old := l_le_rec_old.legal_entity_id;
  END IF;

  xle_businessinfo_grp.get_purchasetopay_info(
     x_return_status       => l_ret_status
    ,x_msg_data            => l_msg_data
    ,p_code_combination_id => p_ccid2
    ,p_registration_code   => null
    ,p_registration_number => null
    ,p_location_id         => p_vendor_site_id
    ,p_operating_unit_id   => p_org_id
    ,x_ptop_le_info        => l_le_rec_new
   );

   IF NOT(l_le_rec_new.legal_entity_id = l_le_id_old OR
          (l_le_rec_new.legal_entity_id IS NULL AND
           l_le_id_old IS NULL))
   THEN
      l_answer := FALSE;
   END IF;

   pnp_debug_pkg.log(l_desc ||' (-)');

   RETURN l_answer;

END is_le_compatible;

------------------------------------------------------------------------
-- FUNCTION    : is_le_compatible
-- RETURNS     : FALSE if Legal entity is different from LE associated with
--               existing account distributions.
--               TRUE if no account distribution exists or if LE is the
--               same for all existing account distributions.
--
-- NOTES       : for R12 release uptake
--             : This should be called for PAYABLES side only !!
-- HISTORY
-- 26-MAY-05 ftanudja o created.
-- 28-JUL-05 ftanudja o added p_distr_id, p_mode, p_term_templ_id.
-- 25-AUG-05 ftanudja o Removed p_location_id from is_le_compatible.
-- 16-OCT-05 sdmahesh o Modified cursors to fetch legal_entity_id
--------------------------------------------------------------------------
FUNCTION is_le_compatible(
           p_ccid             IN pn_distributions.account_id%TYPE,
           p_payment_term_id  IN pn_payment_terms.payment_term_id%TYPE,
           p_term_template_id IN pn_payment_terms.term_template_id%TYPE,
           p_vendor_site_id   IN pn_payment_terms.vendor_site_id%TYPE,
           p_org_id           IN pn_payment_terms.org_id%TYPE,
           p_distribution_id  IN pn_distributions.distribution_id%TYPE,
           p_mode             IN VARCHAR2)
RETURN BOOLEAN IS

   l_answer      BOOLEAN := TRUE;
   l_desc        VARCHAR2(100);

   -- cursor for checking distr in INSERT mode using term ID
   CURSOR chk_other_dist_ins IS
      SELECT ppt.legal_entity_id       le_id,
             dist.account_id           cc_id
      FROM   pn_distributions dist,
             pn_payment_terms_all ppt
      WHERE  dist.payment_term_id = p_payment_term_id
        AND  ppt.payment_term_id = p_payment_term_id
        AND  rownum < 2;

   -- cursor for checking distr in INSERT mode using template ID
   CURSOR chk_other_dist_templ_ins IS
      SELECT dist.account_id       cc_id,
             NULL             AS   le_id
      FROM   pn_distributions dist
      WHERE  dist.term_template_id = p_term_template_id
        AND  rownum < 2;

   -- cursor for checking distr in UPDATE mode using term ID
   CURSOR chk_other_dist_upd IS
      SELECT ppt.legal_entity_id       le_id,
             dist.account_id           cc_id
      FROM   pn_distributions dist,
             pn_payment_terms_all ppt
      WHERE  dist.payment_term_id = p_payment_term_id
        AND  ppt.payment_term_id = p_payment_term_id
        AND  distribution_id <> p_distribution_id
        AND  rownum < 2;

   -- cursor for checking distr in UPDATE mode using template ID
   CURSOR chk_other_dist_templ_upd IS
      SELECT dist.account_id       cc_id,
             NULL             AS   le_id
      FROM   pn_distributions dist
      WHERE  dist.term_template_id = p_term_template_id
        AND  distribution_id <> p_distribution_id
        AND  rownum < 2;


BEGIN

   l_desc := 'pn_r12_util_pkg.is_le_compatible';

   pnp_debug_pkg.log(l_desc ||' (+)');

   IF p_mode = 'INSERT' THEN
     IF p_payment_term_id IS NOT NULL THEN
       FOR validation_rec IN chk_other_dist_ins LOOP
         l_answer := is_le_compatible(
                      p_le_id_old      => validation_rec.le_id
                     ,p_ccid1          => validation_rec.cc_id
                     ,p_ccid2          => p_ccid
                     ,p_vendor_site_id => p_vendor_site_id
                     ,p_org_id         => p_org_id);

       END LOOP;
     ELSIF p_term_template_id IS NOT NULL THEN
       FOR validation_rec IN chk_other_dist_templ_ins LOOP
         l_answer := is_le_compatible(
                      p_le_id_old      => validation_rec.le_id
                     ,p_ccid1          => validation_rec.cc_id
                     ,p_ccid2          => p_ccid
                     ,p_vendor_site_id => p_vendor_site_id
                     ,p_org_id         => p_org_id);

       END LOOP;
     END IF;
   ELSIF p_mode = 'UPDATE' THEN
     IF p_payment_term_id IS NOT NULL THEN
       FOR validation_rec IN chk_other_dist_upd LOOP
         l_answer := is_le_compatible(
                      p_le_id_old      => validation_rec.le_id
                     ,p_ccid1          => validation_rec.cc_id
                     ,p_ccid2          => p_ccid
                     ,p_vendor_site_id => p_vendor_site_id
                     ,p_org_id         => p_org_id);

       END LOOP;
     ELSIF p_term_template_id IS NOT NULL THEN
       FOR validation_rec IN chk_other_dist_templ_upd LOOP
         l_answer := is_le_compatible(
                      p_le_id_old      => validation_rec.le_id
                     ,p_ccid1          => validation_rec.cc_id
                     ,p_ccid2          => p_ccid
                     ,p_vendor_site_id => p_vendor_site_id
                     ,p_org_id         => p_org_id);

       END LOOP;
     END IF;

   END IF;

   pnp_debug_pkg.log(l_desc ||' (-)');

   RETURN l_answer;

END is_le_compatible;


--------------------------------------------------------------------------
-- FUNCTION    : is_r12
-- RETURNS     : FALSE if release 11i, TRUE if release 12
-- HISTORY
-- 26-MAY-05 ftanudja o created.
--------------------------------------------------------------------------
FUNCTION is_r12
RETURN BOOLEAN IS
BEGIN
   RETURN TRUE;
END is_r12;

--------------------------------------------------------------------------
-- FUNCTION    : Wrapper function for LE API for AP
-- RETURNS     : LE given the specified parameters
-- NOTES       : for R12 release uptake
-- HISTORY
-- 11-JUL-05 ftanudja o created.
--------------------------------------------------------------------------
FUNCTION get_le_for_ap(
           p_code_combination_id pn_distributions.account_id%TYPE
          ,p_location_id         pn_payment_terms.vendor_site_id%TYPE
          ,p_org_id              pn_payment_terms.org_id%TYPE)
RETURN NUMBER IS

 l_le_rec_pay  xle_businessinfo_grp.ptop_le_rec;
 l_msg_data    VARCHAR2(250);
 l_ret_status  VARCHAR2(1);
 l_desc        VARCHAR2(100);

BEGIN


   l_desc := 'pn_r12_util_pkg.get_let_for_ap';

   pnp_debug_pkg.log(l_desc ||' (+)');

   xle_businessinfo_grp.get_purchasetopay_info(
      x_return_status       => l_ret_status
     ,x_msg_data            => l_msg_data
     ,p_registration_code   => null
     ,p_registration_number => null
     ,p_location_id         => p_location_id
     ,p_code_combination_id => p_code_combination_id
     ,p_operating_unit_id   => p_org_id
     ,x_ptop_le_info        => l_le_rec_pay
   );

   pnp_debug_pkg.log(l_desc ||' (-)');

   RETURN l_le_rec_pay.legal_entity_id;

END get_le_for_ap;


--------------------------------------------------------------------------
-- FUNCTION    : Wrapper function for LE API for AR
-- RETURNS     : LE given the specified parameters
-- NOTES       : for R12 release uptake
-- HISTORY
-- 11-JUL-05 ftanudja o created.
-- 05-AUG-05 ftanudja o added call to mo_global. #4526616,#4497295.
--------------------------------------------------------------------------
FUNCTION get_le_for_ar(
           p_customer_id         pn_payment_terms.customer_id%TYPE
          ,p_transaction_type_id pn_payment_terms.cust_trx_type_id%TYPE
          ,p_org_id              pn_payment_terms.org_id%TYPE)
RETURN NUMBER IS

 l_le_rec_rec  xle_businessinfo_grp.otoc_le_rec;
 l_msg_data    VARCHAR2(250);
 l_ret_status  VARCHAR2(1);
 l_desc        VARCHAR2(100);

BEGIN

   l_desc := 'pn_r12_util_pkg.get_let_for_ar';

   pnp_debug_pkg.log(l_desc ||' (+)');

   mo_global.set_org_access(p_org_id, null, 'AR');

   xle_businessinfo_grp.get_ordertocash_info(
      x_return_status       => l_ret_status
     ,x_msg_data            => l_msg_data
     ,p_customer_type       => 'BILL_TO'
     ,p_customer_id         => p_customer_id
     ,p_transaction_type_id => p_transaction_type_id
     ,p_batch_source_id     => 24
     ,p_operating_unit_id   => p_org_id
     ,x_otoc_le_info        => l_le_rec_rec
   );

   pnp_debug_pkg.log(l_desc ||' (-)');

   RETURN l_le_rec_rec.legal_entity_id;

END get_le_for_ar;

--------------------------------------------------------------------------
-- FUNCTION    : get_tax_flag
-- RETURNS     : auto_tax_calc_flag
-- HISTORY
-- 05-SEP-05 SatyaDeep o created.Retreives auto_tax_calc_flag
--                        in 11i
-- 05-APR-06 sdmahesh  o  Retreived INCLUSIVE_TAX_FLAG
--                        in R12
-- 25-Sep-07 bnoorbha  o  Bug 6413109: Added cursor to retrieve
--                        inclusive_tax_flag from supplier site also.
--------------------------------------------------------------------------
FUNCTION get_tax_flag (p_vendor_id      IN NUMBER,
                       p_vendor_site_id IN NUMBER)
RETURN VARCHAR2 IS

CURSOR get_flag_value IS
   SELECT DECODE( NVL(inclusive_tax_flag,'Y'),'Y','S','N') tax_flag
   FROM   zx_party_tax_profile zpt,
         po_vendors pov
   WHERE  pov.vendor_id = p_vendor_id
   AND    zpt.party_id = pov.party_id
   AND    party_type_code = 'THIRD_PARTY';

-- Added for Bug #6413109
CURSOR get_site_flag_value IS
   SELECT DECODE( NVL(inclusive_tax_flag,'Y'),'Y','S','N') tax_flag
   FROM   zx_party_tax_profile zpt,
          po_vendor_sites_all pvsa
   WHERE  pvsa.VENDOR_SITE_ID = p_vendor_site_id
   AND    zpt.party_id = pvsa.party_site_id
   AND    party_type_code = 'THIRD_PARTY_SITE';

   l_answer      VARCHAR2(1);

BEGIN

   pnp_debug_pkg.log('pn_r12_util_pkg.get_tax_flag (+)');

   -- Added IF condition for Bug 6413109
   IF p_vendor_site_id IS NOT NULL THEN
       FOR info_rec IN get_site_flag_value LOOP

         l_answer := info_rec.tax_flag;

       END LOOP;
   ELSE

       FOR info_rec IN get_flag_value LOOP

         l_answer := info_rec.tax_flag;

       END LOOP;
   END IF;

   pnp_debug_pkg.log('pn_r12_util_pkg.get_tax_flag (-)');

   RETURN l_answer;

END get_tax_flag;

--------------------------------------------------------------------------
-- FUNCTION    : get_ap_tax_code_name
-- RETURNS     : Tax Code Name
-- HISTORY
-- 14-MAR-06 Hareesha o Bug #4756588 Created.Stub for R12.
--                      Retrieves Tax Code Name in 11i.
-- DO NOT USE IN R12
--------------------------------------------------------------------------
FUNCTION get_ap_tax_code_name(p_tax_id IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
   RETURN NULL;
END get_ap_tax_code_name;


--------------------------------------------------------------------------
-- FUNCTION    : get_ar_tax_code_name
-- RETURNS     : Tax Code Name
-- HISTORY
-- 14-MAR-06 Hareesha o Bug #4756588 Created.Stub for R12.
--                      Retrieves Tax Code Name in 11i.
-- DO NOT USE IN R12
--------------------------------------------------------------------------
FUNCTION get_ar_tax_code_name (p_tax_id IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
   RETURN NULL;
END get_ar_tax_code_name;

--------------------------------------------------------------------------
-- FUNCTION    : get_tax_group
-- RETURNS     : Tax Group Name
-- HISTORY
-- 14-MAR-06 Hareesha o Bug #4756588 Created.Stub for R12.
--                      Retrieves Tax Group Name in 11i.
-- DO NOT USE IN R12
--------------------------------------------------------------------------
FUNCTION get_tax_group (p_tax_group_id IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
   RETURN NULL;
END get_tax_group;


-------------------------------------------------------------------------------
-- FUNCTION    : check_tax_upgrade
-- RETURNS     : Tax-classification-code if exists, else ERROR-CODE
-- NOTES       : for R12 release uptake
-- HISTORY
-- 09-JUN-06  Hareesha o Bug #5305903 Created.
-------------------------------------------------------------------------------
FUNCTION check_tax_upgrade (p_tax_code_id  pn_payment_terms.tax_code_id%TYPE,
                            p_tax_group_id pn_payment_terms.tax_group_id%TYPE,
                            p_run_mode     pn_leases.lease_class_code%TYPE)
RETURN VARCHAR2 IS

l_tcc              pn_payment_terms.tax_classification_code%TYPE;

BEGIN
   IF (p_tax_code_id IS NOT NULL OR p_tax_group_id IS NOT NULL)
   THEN
      l_tcc := pn_r12_util_pkg.get_tcc(
                       p_tax_code_id      => nvl(p_tax_code_id, p_tax_group_id),
                       p_lease_class_code => p_run_mode,
                       p_as_of_date       => SYSDATE);

      IF l_tcc IS NULL THEN
         RETURN 'PN_NO_TCC_FOUND';
      ELSE
         RETURN l_tcc;
      END IF;
   END IF;

END check_tax_upgrade;


-------------------------------------------------------------------------------
-- FUNCTION    : check_tax_upgrade
-- RETURNS     : 'PN_UPG_TCC' if tax-classification-code exists,
--                else PN_NO_TCC_FOUND
-- NOTES       : for R12 release uptake
-- HISTORY
-- 09-JUN-06  Hareesha o Bug #5305903 Created.
-------------------------------------------------------------------------------
FUNCTION check_tax_upgrade (p_term_template_id pn_term_templates.term_template_id%TYPE)
RETURN VARCHAR2 IS

CURSOR get_term_temp_details IS
   SELECT org_id,
          tax_code_id,
          tax_group_id,
          tax_classification_code,
          term_template_type
   FROM pn_term_templates_all
   WHERE term_template_id = p_term_template_id;

l_tcc          pn_payment_terms.tax_classification_code%TYPE;

BEGIN

   FOR rec IN get_term_temp_details LOOP

      IF rec.tax_classification_code IS NULL AND
         ( rec.tax_code_id IS NOT NULL OR rec.tax_group_id IS NOT NULL)
      THEN

         l_tcc := pn_r12_util_pkg.get_tcc(
                       p_tax_code_id      => nvl(rec.tax_code_id, rec.tax_group_id),
                       p_lease_class_code => rec.term_template_type,
                       p_as_of_date       => SYSDATE);

         IF l_tcc IS NULL THEN
            RETURN 'PN_NO_TCC_FOUND';
         ELSE
            UPDATE pn_term_templates_all
            SET tax_classification_code = l_tcc,
                tax_code_id = NULL,
                tax_group_id = NULL
            WHERE term_template_id = p_term_template_id;

            COMMIT;
            RETURN 'PN_UPG_TCC';
        END IF;
     END IF;
     RETURN NULL;

   END LOOP;
END check_tax_upgrade;


END pn_r12_util_pkg;


/
