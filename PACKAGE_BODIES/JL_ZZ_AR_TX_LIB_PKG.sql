--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AR_TX_LIB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AR_TX_LIB_PKG" AS
/* $Header: jlzzxlib.pls 120.11.12010000.3 2009/01/23 02:02:35 sachandr ship $ */

FUNCTION get_tax_category_id(p_vat_tax_id IN NUMBER) RETURN NUMBER IS

  l_tax_category_id NUMBER;
BEGIN
  l_tax_category_id := NULL;
  BEGIN
    SELECT global_attribute1
    INTO   l_tax_category_id
    FROM   ar_vat_tax
    WHERE  vat_tax_id = p_vat_tax_id;
  EXCEPTION
    WHEN OTHERS THEN
         l_tax_category_id := NULL;
  END;
  RETURN l_tax_category_id;
END get_tax_category_id;

FUNCTION get_tax_inclusive_flag(p_tax_category_id IN NUMBER) RETURN VARCHAR2 IS

  l_tax_inclusive_flag VARCHAR2(1);
BEGIN
  l_tax_inclusive_flag := NULL;
  BEGIN
     SELECT tax_inclusive
     INTO   l_tax_inclusive_flag
     FROM   jl_zz_ar_tx_categry
     WHERE  tax_category_id = p_tax_category_id;
  EXCEPTION
    WHEN OTHERS THEN
         l_tax_inclusive_flag := NULL;
  END;
  RETURN l_tax_inclusive_flag;
END get_tax_inclusive_flag;

-- Bug 3610797
PROCEDURE get_item_fsc_txn_nat_code(p_inv_item_id   IN NUMBER,
                                    p_item_org      IN OUT NOCOPY VARCHAR2,
                                    p_item_fsc_type IN OUT NOCOPY VARCHAR2,
                                    p_fed_trib      IN OUT NOCOPY VARCHAR2,
                                    p_state_trib    IN OUT NOCOPY VARCHAR2) IS

  l_item_org      varchar2(150);
  l_item_ft       varchar2(150);
  l_fed_trib      varchar2(150);
  l_sta_trib      varchar2(150);
  l_org_id        NUMBER;

BEGIN
  l_item_org := NULL;
  l_item_ft  := NULL;
  l_fed_trib := NULL;
  l_sta_trib := NULL;

  BEGIN

    l_org_id := mo_global.get_current_org_id;

    SELECT mtl.global_attribute3,
           mtl.global_attribute4,
           mtl.global_attribute5,
           mtl.global_attribute6
    INTO   l_item_org,
           l_item_ft,
           l_fed_trib,
           l_sta_trib
    FROM   mtl_system_items mtl
    WHERE  mtl.organization_id = oe_sys_parameters.value('MASTER_ORGANIZATION_ID',l_org_id)
    AND    mtl.inventory_item_id = p_inv_item_id;
  EXCEPTION
    WHEN OTHERS THEN
         l_item_org := NULL;
         l_item_ft  := NULL;
         l_fed_trib := NULL;
         l_sta_trib := NULL;
  END;

  p_item_org      := l_item_org;
  p_item_fsc_type := l_item_ft;
  p_fed_trib      := l_fed_trib;
  p_state_trib    := l_sta_trib;
END get_item_fsc_txn_nat_code;

-- Bug 3610797
PROCEDURE get_memo_fsc_txn_nat_code(p_memo_line_id  IN NUMBER,
                                    p_item_org      IN OUT NOCOPY VARCHAR2,
                                    p_item_fsc_type IN OUT NOCOPY VARCHAR2,
                                    p_fed_trib      IN OUT NOCOPY VARCHAR2,
                                    p_state_trib    IN OUT NOCOPY VARCHAR2) IS

  l_item_org      varchar2(150);
  l_item_ft       varchar2(150);
  l_fed_trib      varchar2(150);
  l_sta_trib      varchar2(150);

BEGIN
  l_item_org := NULL;
  l_item_ft  := NULL;
  l_fed_trib := NULL;
  l_sta_trib := NULL;

  BEGIN

    SELECT aml.global_attribute3,
           aml.global_attribute4,
           aml.global_attribute5,
           aml.global_attribute6
    INTO   l_item_org,
           l_item_ft,
           l_fed_trib,
           l_sta_trib
    FROM   ar_memo_lines aml
    WHERE  aml.memo_line_id = p_memo_line_id;
  EXCEPTION
    WHEN OTHERS THEN
         l_item_org := NULL;
         l_item_ft  := NULL;
         l_fed_trib := NULL;
         l_sta_trib := NULL;
  END;
  p_item_org      := l_item_org;
  p_item_fsc_type := l_item_ft;
  p_fed_trib      := l_fed_trib;
  p_state_trib    := l_sta_trib;
END get_memo_fsc_txn_nat_code;

PROCEDURE get_tax_base_rate_amount
     (p_cust_trx_line_id IN NUMBER,
      p_tax_base_rate    IN OUT NOCOPY NUMBER,
      p_tax_base_amount  IN OUT NOCOPY NUMBER,
      p_org_id           IN     NUMBER) IS    --Bugfix 2367111

  l_base_rate   NUMBER;
  l_base_amount NUMBER;
  l_org_id      NUMBER;

BEGIN
  l_base_rate   := NULL;
  l_base_amount := NULL;

  IF p_org_id IS NULL THEN
    -- l_org_id := to_number(fnd_profile.value('ORG_ID'));
       l_org_id := mo_global.get_current_org_id;
  ELSE
       l_org_id := p_org_id;
  END IF;

  BEGIN
    SELECT global_attribute11,
	   global_attribute12
    INTO   l_base_amount,
           l_base_rate
    FROM ra_customer_trx_lines_all               --Bugfix 2367111
    WHERE customer_trx_line_id = p_cust_trx_line_id
    AND nvl(org_id,-99) = nvl(l_org_id,-99);     --Bugfix 2367111
  EXCEPTION
    WHEN OTHERS THEN
         l_base_rate   := NULL;
         l_base_amount := NULL;
  END;
  p_tax_base_rate := l_base_rate;
  p_tax_base_amount := l_base_amount;
END get_tax_base_rate_amount;

-- Bug 3610797
FUNCTION get_tax_method
     (p_org_id           IN     NUMBER) RETURN VARCHAR2 IS --Bugfix 2367111

  l_tax_method zx_product_options.tax_method_code%type;
  l_org_id  NUMBER;

  CURSOR get_tax_method_csr
    ( c_org_id             NUMBER)
  IS
   SELECT prod.tax_method_code
    FROM zx_product_options_all prod,
         ar_system_parameters_all sys            --Bugfix 2367111
   WHERE prod.application_id = 222
   AND sys.org_id = prod.org_id
   AND nvl(sys.org_id,-99) = nvl(c_org_id,-99);  --Bugfix 2367111;

BEGIN

  IF p_org_id IS NULL THEN
    -- l_org_id := to_number(fnd_profile.value('ORG_ID'));
       l_org_id := mo_global.get_current_org_id;
  ELSE
    l_org_id := p_org_id;
  END IF;

  OPEN get_tax_method_csr(l_org_id);
  FETCH get_tax_method_csr INTO l_tax_method;
  IF get_tax_method_csr%NOTFOUND THEN
    --
    -- Bug#4544623- return default value to avoid
    -- ORA-06503: PL/SQL: Function returned without value
    --
    l_tax_method := 'XXX';
  END IF;

  CLOSE get_tax_method_csr;

  RETURN l_tax_method;

  EXCEPTION
    WHEN OTHERS THEN
         l_tax_method := NULL;
END get_tax_method;

FUNCTION contributor_class_exists(p_address_id             IN NUMBER,
                                  p_contributor_class_code IN VARCHAR2)
RETURN BOOLEAN IS

  l_contributor_class_code VARCHAR2(150);
  l_cls_exists             BOOLEAN;

BEGIN
  l_contributor_class_code := NULL;

  BEGIN
    SELECT global_attribute8
    INTO   l_contributor_class_code
    FROM   hz_cust_acct_sites
    WHERE  cust_acct_site_id = p_address_id;

    IF substr(p_contributor_class_code,1,30) <>
                                      substr(l_contributor_class_code,1,30) THEN
       l_cls_exists := TRUE;
    ELSE
       l_cls_exists := FALSE;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
         l_cls_exists := FALSE;
  END;
  RETURN l_cls_exists;

END contributor_class_exists;

/* This Function replaces the above Function
   contributor_class_exists in JL library*/

FUNCTION contributor_class_check(p_address_id             IN NUMBER,
                                  p_contributor_class_code IN VARCHAR2)
RETURN BOOLEAN IS

  l_cls_exists             BOOLEAN;
  l_cnt                    NUMBER :=0;
BEGIN

  BEGIN
    SELECT count(*)
    INTO   l_cnt
    FROM   jl_zz_ar_tx_cus_cls
    WHERE  address_id = p_address_id
      AND  tax_attr_class_code = p_contributor_class_code;

  IF l_cnt > 0 THEN
     l_cls_exists := TRUE;
  ELSE
     l_cls_exists := FALSE;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
         l_cls_exists := FALSE;
  END;
  RETURN l_cls_exists;

END contributor_class_check;

PROCEDURE populate_cus_cls_details(p_address_id             IN NUMBER,
                                   p_contributor_class_code IN VARCHAR2) IS

  l_dummy NUMBER(15);

BEGIN

-- Bugfix 1783986. Customer Site Profile values (JL_ZZ_AR_TX_CUS_CLS) should not
-- be populated with values from JL_ZZ_AR_TX_ATT_CLS due to functional change in
-- populating such records. Only changed records of Contributor Class Code will
-- be stored in Customer Site Profile (JL_ZZ_AR_TX_CUS_CLS)
--
-- A data cleanup script (JLZZUCAC) is provided to match existing records of
-- JL_ZZ_AR_TX_ATT_CLS and JL_ZZ_AR_TX_CUS_CLS for Contributor Class code and
-- will update HZ_CUST_ACCT_SITES.GLOBAL_ATTRIBUTE9 with 'Y' if there are
-- differences and will update with 'N' if there are NO differences where
-- HZ_CUST_ACCT_SITES.GLOBAL_ATTRIBUTE8 is NOT NULL.
--
-- For records whose GLOBAL_ATTRIBUTE8 is NOT NULL, Tax Engine would look
-- JL_ZZ_AR_TX_CUS_CLS if value of HZ_CUST_ACCT_SITES.GLOBAL_ATTRIBUTE9='Y' and
-- JL_ZZ_AR_TX_ATT_CLS if value of HZ_CUST_ACCT_SITES.GLOBAL_ATTRIBUTE9='N'
-- NULL value of GLOBAL_ATTRIBUTE9 will be interpreted as 'Y'

return;

/*
  l_dummy := 0;

  BEGIN
    SELECT count(*)
    INTO   l_dummy
    FROM   jl_zz_ar_tx_cus_cls
    WHERE  address_id = p_address_id
    AND    tax_attr_class_code = p_contributor_class_code;
  EXCEPTION
    WHEN OTHERS THEN
         l_dummy := 0;
  END;

  IF l_dummy = 0 THEN
     JL_ZZ_AR_TX_CUS_CLS_PKG.Populate_Cus_Cls_Rows(
                 X_address_id      => p_address_id,
                 X_class_code      => p_contributor_class_code);

  END IF;

*/

END populate_cus_cls_details;


FUNCTION get_lookup_meaning(p_lookup_code IN VARCHAR2,
                            p_lookup_type IN VARCHAR2) RETURN VARCHAR2 IS

l_meaning VARCHAR2(80);

BEGIN

  l_meaning := NULL;

  IF p_lookup_code IS NOT NULL THEN
    BEGIN
      SELECT meaning
      INTO  l_meaning
      FROM  fnd_lookups
      WHERE lookup_code = p_lookup_code
      AND   lookup_type = p_lookup_type
      AND   enabled_flag = 'Y'
      AND   SYSDATE BETWEEN NVL(start_date_active,SYSDATE)
                    AND     NVL(end_date_active,SYSDATE);
    EXCEPTION
      WHEN OTHERS THEN
           l_meaning := NULL;
    END;
  ELSE
    l_meaning := NULL;
  END IF;

  RETURN l_meaning;

END get_lookup_meaning;

PROCEDURE set_mo_org_id(p_org_id number) AS
BEGIN
   jl_zz_ar_tx_lib_pkg.mo_org_id := p_org_id;
END;

FUNCTION get_mo_org_id RETURN NUMBER IS
BEGIN
   return jl_zz_ar_tx_lib_pkg.mo_org_id ;
END;

FUNCTION validate_loc_classification(p_geo_type IN VARCHAR2,
                                     p_country_code IN VARCHAR2
                                     )
 RETURN VARCHAR2 IS
 l_exists VARCHAR2(1);
BEGIN
  BEGIN
    SELECT 'Y'
    INTO   l_exists
    FROM   hz_geo_structure_levels
    WHERE  geography_type = p_geo_type
    AND    country_code = p_country_code
    AND    rownum = 1;
  EXCEPTION
    WHEN OTHERS THEN
         l_exists:= 'N';
  END;
  RETURN l_exists;
END validate_loc_classification;


END JL_ZZ_AR_TX_LIB_PKG;

/
