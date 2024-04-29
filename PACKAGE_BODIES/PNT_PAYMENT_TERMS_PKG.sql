--------------------------------------------------------
--  DDL for Package Body PNT_PAYMENT_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PNT_PAYMENT_TERMS_PKG" AS
  -- $Header: PNTPYTRB.pls 120.16.12010000.5 2010/02/02 09:51:00 jsundara ship $


-------------------------------------------------------------------
-- PROCEDURE UPDATE_PNT_ITEMS_AMT
-------------------------------------------------------------------
PROCEDURE UPDATE_PNT_ITEMS_AMT
        (p_pnt_term_id IN pn_payment_items.payment_term_id%TYPE,
         p_old_est_amt IN pn_payment_items.estimated_amount%TYPE,
         p_new_est_amt IN pn_payment_items.estimated_amount%TYPE,
         p_lease_id    IN pn_payment_terms.lease_id%TYPE,
         p_trm_str_dt  IN DATE,
         p_trm_end_dt  IN DATE,
         p_freq_code   IN pn_payment_terms.frequency_code%TYPE);

-------------------------------------------------------------------
-- PROCEDURE UPDATE_PNT_ITEMS_RATE
-------------------------------------------------------------------
PROCEDURE UPDATE_PNT_ITEMS_RATE(p_pnt_term_id pn_payment_items.payment_item_id%TYPE,
                                p_new_rate    pn_payment_items.rate%TYPE);

-------------------------------------------------------------------
-- PROCEDURE : CHECK_PAYMENT_AMOUNTS
-------------------------------------------------------------------
PROCEDURE CHECK_PAYMENT_AMOUNTS (
                        X_RETURN_STATUS        IN OUT NOCOPY VARCHAR2
                       ,X_ACTUAL_AMOUNT        IN            NUMBER
                       ,X_ESTIMATED_AMOUNT     IN            NUMBER
                     )
IS
BEGIN
   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.CHECK_PAYMENT_AMOUNTS (+)');
   IF ((X_ACTUAL_AMOUNT    IS NULL) AND
       (X_ESTIMATED_AMOUNT IS NULL))
   THEN
      fnd_message.set_name ('PN','PN_PAYMENT_AMOUNT_NULL');
      x_return_status := 'E';
   END IF;

   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.CHECK_PAYMENT_AMOUNTS (-) RetStat: '||x_return_status);
END CHECK_PAYMENT_AMOUNTS;

--------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 04-DEC-03  ftanudja  o Added parameter area_type_code, area. 3257508.
-- 17-DEC-03  ATUPPAD   o Added parameter grouping_rule_id.
--                        Part of Grouping Logic for Invoices
-- 05-JUL-05  sdmahesh  o Bug 4284035 - Replaced pn_payment_terms with _ALL
--                        table.
-- 15-JUL-05  ftanudja  o R12 changes. #4495054, #4497295
-- 24-NOV-05  Kiran     o rounding for amounts done based on currency precision
-- 17-APR-06  Hareesha  o Bug 5115291 Passed norm_start_date while inserting
--                        into pn_payment_terms_all
-- 14-AUG-06  Pikhar    o Set update_nbp_flag to 'Y' on insert
-- 21-SEP-06  Hareesha  o Removed populating pn_index_exclude_term basing on
--                        profile option, since we are using a systemoption
-- 09-JAN-07  Lokesh    o Removed call to CHECK_APPROVED_SCHEDULE_EXISTS which
--                        checks for schedule day conflicts ,for M28 item #11
-- 02-JAn-07  Hareesha  o M28#16 Added x_recur_bb_calc_date.
-- 06-MAR-07 Prabhakar  o Added opex_agr_id, opex_recon_id and opex_type
--                       for insert row handlers.
--------------------------------------------------------------------------------
PROCEDURE INSERT_ROW (
                       X_ROWID                         IN OUT NOCOPY VARCHAR2,
                       X_PAYMENT_TERM_ID               IN OUT NOCOPY NUMBER,
                       X_PAYMENT_PURPOSE_CODE          IN     VARCHAR2,
                       X_PAYMENT_TERM_TYPE_CODE        IN     VARCHAR2,
                       X_FREQUENCY_CODE                IN     VARCHAR2,
                       X_LEASE_ID                      IN     NUMBER,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_START_DATE                    IN     DATE,
                       X_END_DATE                      IN     DATE,
                       X_VENDOR_ID                     IN     NUMBER,
                       X_VENDOR_SITE_ID                IN     NUMBER,
                       X_CUSTOMER_ID                   IN     NUMBER,
                       X_CUSTOMER_SITE_USE_ID          IN     NUMBER,
                       X_TARGET_DATE                   IN     DATE,
                       X_ACTUAL_AMOUNT                 IN     NUMBER,
                       X_ESTIMATED_AMOUNT              IN     NUMBER,
                       X_SET_OF_BOOKS_ID               IN     NUMBER,
                       X_CURRENCY_CODE                 IN     VARCHAR2,
                       X_RATE                          IN     NUMBER,
                       X_NORMALIZE                     IN     VARCHAR2,
                       X_LOCATION_ID                   IN     NUMBER,
                       X_SCHEDULE_DAY                  IN     NUMBER,
                       X_CUST_SHIP_SITE_ID             IN     NUMBER,
                       X_AP_AR_TERM_ID                 IN     NUMBER,
                       X_CUST_TRX_TYPE_ID              IN     NUMBER,
                       X_PROJECT_ID                    IN     NUMBER,
                       X_TASK_ID                       IN     NUMBER,
                       X_ORGANIZATION_ID               IN     NUMBER,
                       X_EXPENDITURE_TYPE              IN     VARCHAR2,
                       X_EXPENDITURE_ITEM_DATE         IN     DATE,
                       X_TAX_GROUP_ID                  IN     NUMBER,
                       X_TAX_CODE_ID                   IN     NUMBER,
                       X_TAX_CLASSIFICATION_CODE       IN     VARCHAR2,
                       X_TAX_INCLUDED                  IN     VARCHAR2,
                       X_DISTRIBUTION_SET_ID           IN     NUMBER,
                       X_INV_RULE_ID                   IN     NUMBER,
                       X_ACCOUNT_RULE_ID               IN     NUMBER,
                       X_SALESREP_ID                   IN     NUMBER,
                       X_APPROVED_BY                   IN     NUMBER,
                       X_STATUS                        IN     VARCHAR2,
                       X_INDEX_PERIOD_ID               IN     NUMBER,
                       X_INDEX_TERM_INDICATOR          IN     VARCHAR2,
                       X_PO_HEADER_ID                  IN     NUMBER,
                       X_CUST_PO_NUMBER                IN     VARCHAR2,
                       X_RECEIPT_METHOD_ID             IN     NUMBER,
                       X_VAR_RENT_INV_ID               IN     NUMBER ,
                       X_VAR_RENT_TYPE                 IN     VARCHAR2,
                       X_PERIOD_BILLREC_ID             IN     NUMBER,
                       X_REC_AGR_LINE_ID               IN     NUMBER,
                       X_AMOUNT_TYPE                   IN     VARCHAR2,
                       X_CHANGED_FLAG                  IN     VARCHAR2,
                       X_TERM_TEMPLATE_ID              IN     NUMBER,
                       X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
                       X_ATTRIBUTE1                    IN     VARCHAR2,
                       X_ATTRIBUTE2                    IN     VARCHAR2,
                       X_ATTRIBUTE3                    IN     VARCHAR2,
                       X_ATTRIBUTE4                    IN     VARCHAR2,
                       X_ATTRIBUTE5                    IN     VARCHAR2,
                       X_ATTRIBUTE6                    IN     VARCHAR2,
                       X_ATTRIBUTE7                    IN     VARCHAR2,
                       X_ATTRIBUTE8                    IN     VARCHAR2,
                       X_ATTRIBUTE9                    IN     VARCHAR2,
                       X_ATTRIBUTE10                   IN     VARCHAR2,
                       X_ATTRIBUTE11                   IN     VARCHAR2,
                       X_ATTRIBUTE12                   IN     VARCHAR2,
                       X_ATTRIBUTE13                   IN     VARCHAR2,
                       X_ATTRIBUTE14                   IN     VARCHAR2,
                       X_ATTRIBUTE15                   IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE_CATEGORY    IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE1            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE2            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE3            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE4            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE5            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE6            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE7            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE8            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE9            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE10           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE11           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE12           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE13           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE14           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE15           IN     VARCHAR2,
                       X_CREATION_DATE                 IN     DATE,
                       X_CREATED_BY                    IN     NUMBER,
                       X_LAST_UPDATE_DATE              IN     DATE,
                       X_LAST_UPDATED_BY               IN     NUMBER,
                       X_LAST_UPDATE_LOGIN             IN     NUMBER,
                       X_CALLING_FORM                  IN     VARCHAR2 ,
                       x_org_id                        IN     NUMBER,
                       x_lease_status                  IN     VARCHAR2,
                       x_recoverable_flag              IN     VARCHAR2,
                       x_area_type_code                IN     VARCHAR2,
                       x_area                          IN     NUMBER,
                       x_grouping_rule_id              IN     NUMBER,
                       x_term_altered_flag             IN     VARCHAR2,
                       x_source_code                   IN     VARCHAR2,
                       x_term_comments                 IN     VARCHAR2,
                       x_norm_start_date               IN     DATE,
                       x_parent_term_id                IN     NUMBER ,
                       x_index_norm_flag               IN     VARCHAR2,
                       x_include_in_var_rent           IN     VARCHAR2 DEFAULT NULL,
                       x_recur_bb_calc_date            IN     DATE,
                       x_opex_agr_id                   IN     NUMBER,
                       x_opex_recon_id                 IN     NUMBER,
                       x_opex_type                     IN     VARCHAR2

                     )
IS
   CURSOR c IS
   SELECT ROWID
   FROM   pn_payment_terms_all
   WHERE payment_term_id = x_payment_term_id;

   l_legal_entity_id pn_payment_terms.legal_entity_id%TYPE;
   l_return_status VARCHAR2(2) := NULL;

   CURSOR org_cur IS
     SELECT org_id FROM pn_leases_all WHERE lease_id = X_LEASE_ID;
   l_org_id NUMBER;

   l_precision                    NUMBER;
   l_ext_precision                NUMBER;
   l_min_acct_unit                NUMBER;


   l_update_nbp_flag              VARCHAR2(1);

   CURSOR index_rents_csr IS
      SELECT index_lease_id
             ,lease_id
      FROM   pn_index_leases_all
      WHERE  lease_id = x_lease_id
      AND    GROSS_FLAG = 'Y';


BEGIN
   pnp_debug_pkg.debug ('PNT_PAYMENT_TERMS_PKG.INSERT_ROW (+)');

   -- Check IF both Estimated AND actual amount are NULL
   l_return_status        := NULL;
   PNT_PAYMENT_TERMS_PKG.CHECK_PAYMENT_AMOUNTS (
                        l_RETURN_STATUS
                       ,X_ACTUAL_AMOUNT
                       ,X_ESTIMATED_AMOUNT);
   IF (l_return_status IS NOT NULL) THEN
      app_exception.Raise_Exception;
   END IF;

   /* checking if updation of Natural breakpoints is required */
   IF x_include_in_var_rent IN ('BASETERM','INCLUDE_RI') THEN
      l_update_nbp_flag := 'Y';
   ELSE
      l_update_nbp_flag := NULL;
   END IF;

   IF pn_r12_util_pkg.is_r12 THEN
     IF x_vendor_site_id IS NOT NULL THEN /* PAYABLES */
       l_legal_entity_id :=
          pn_r12_util_pkg.get_le_for_ap(
            p_code_combination_id => null
           ,p_location_id         => x_vendor_site_id
           ,p_org_id              => x_org_id
          );
     ELSIF x_customer_id IS NOT NULL THEN/* 9162932 */
       l_legal_entity_id :=
          pn_r12_util_pkg.get_le_for_ar(
            p_customer_id         => x_customer_id
           ,p_transaction_type_id => x_cust_trx_type_id
           ,p_org_id              => x_org_id
          );
     END IF;
   END IF;

   IF x_org_id IS NOT NULL THEN
     l_org_id := x_org_id;
   ELSIF x_org_id IS NULL THEN
     FOR rec IN org_cur LOOP
       l_org_id := rec.org_id;
     END LOOP;
   END IF;

   /* get currency info for rounding */
   fnd_currency.get_info( currency_code => x_currency_code
                         ,precision     => l_precision
                         ,ext_precision => l_ext_precision
                         ,min_acct_unit => l_min_acct_unit);

   BEGIN
      INSERT INTO pn_payment_terms_all
      (
         PAYMENT_TERM_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         PAYMENT_PURPOSE_CODE,
         PAYMENT_TERM_TYPE_CODE,
         FREQUENCY_CODE,
         LEASE_ID,
         LEASE_CHANGE_ID,
         START_DATE,
         END_DATE,
         VENDOR_ID,
         VENDOR_SITE_ID,
         CUSTOMER_ID,
         CUSTOMER_SITE_USE_ID,
         TARGET_DATE,
         ACTUAL_AMOUNT,
         ESTIMATED_AMOUNT,
         SET_OF_BOOKS_ID,
         CURRENCY_CODE,
         RATE,
         NORMALIZE,
         LOCATION_ID,
         SCHEDULE_DAY,
         CUST_SHIP_SITE_ID,
         AP_AR_TERM_ID,
         CUST_TRX_TYPE_ID,
         PROJECT_ID,
         TASK_ID,
         ORGANIZATION_ID,
         EXPENDITURE_TYPE,
         EXPENDITURE_ITEM_DATE,
         TAX_GROUP_ID,
         TAX_CODE_ID,
         TAX_CLASSIFICATION_CODE,
         TAX_INCLUDED,
         DISTRIBUTION_SET_ID,
         INV_RULE_ID,
         ACCOUNT_RULE_ID,
         SALESREP_ID,
         APPROVED_BY,
         STATUS,
         INDEX_PERIOD_ID,
         INDEX_TERM_INDICATOR,
         PO_HEADER_ID,
         CUST_PO_NUMBER,
         RECEIPT_METHOD_ID,
         VAR_RENT_INV_ID ,
         VAR_RENT_TYPE,
         PERIOD_BILLREC_ID,
         REC_AGR_LINE_ID,
         AMOUNT_TYPE,
         CHANGED_FLAG,
         TERM_TEMPLATE_ID,
         LEGAL_ENTITY_ID,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         PROJECT_ATTRIBUTE_CATEGORY,
         PROJECT_ATTRIBUTE1,
         PROJECT_ATTRIBUTE2,
         PROJECT_ATTRIBUTE3,
         PROJECT_ATTRIBUTE4,
         PROJECT_ATTRIBUTE5,
         PROJECT_ATTRIBUTE6,
         PROJECT_ATTRIBUTE7,
         PROJECT_ATTRIBUTE8,
         PROJECT_ATTRIBUTE9,
         PROJECT_ATTRIBUTE10,
         PROJECT_ATTRIBUTE11,
         PROJECT_ATTRIBUTE12,
         PROJECT_ATTRIBUTE13,
         PROJECT_ATTRIBUTE14,
         PROJECT_ATTRIBUTE15,
         ORG_ID,
         LEASE_STATUS,
         RECOVERABLE_FLAG,
         AREA_TYPE_CODE,
         AREA,
         GROUPING_RULE_ID,
         TERM_ALTERED_FLAG,
         SOURCE_CODE,
         TERM_COMMENTS,
         NORM_START_DATE,
         PARENT_TERM_ID,
         INDEX_NORM_FLAG,
         INCLUDE_IN_VAR_RENT,
         UPDATE_NBP_FLAG,
         RECUR_BB_CALC_DATE,
         OPEX_AGR_ID,
         OPEX_RECON_ID,
         OPEX_TYPE
      )
      VALUES
      (
         NVL(X_PAYMENT_TERM_ID,pn_payment_terms_s.NEXTVAL),
         X_LAST_UPDATE_DATE,
         X_LAST_UPDATED_BY,
         X_CREATION_DATE,
         X_CREATED_BY,
         X_LAST_UPDATE_LOGIN,
         X_PAYMENT_PURPOSE_CODE,
         X_PAYMENT_TERM_TYPE_CODE,
         X_FREQUENCY_CODE,
         X_LEASE_ID,
         X_LEASE_CHANGE_ID,
         X_START_DATE,
         X_END_DATE,
         X_VENDOR_ID,
         X_VENDOR_SITE_ID,
         X_CUSTOMER_ID,
         X_CUSTOMER_SITE_USE_ID,
         X_TARGET_DATE,
         ROUND(X_ACTUAL_AMOUNT, l_precision),
         ROUND(X_ESTIMATED_AMOUNT, l_precision),
         X_SET_OF_BOOKS_ID,
         X_CURRENCY_CODE,
         X_RATE,
         X_NORMALIZE,
         X_LOCATION_ID,
         X_SCHEDULE_DAY,
         X_CUST_SHIP_SITE_ID,
         X_AP_AR_TERM_ID,
         X_CUST_TRX_TYPE_ID,
         X_PROJECT_ID,
         X_TASK_ID,
         X_ORGANIZATION_ID,
         X_EXPENDITURE_TYPE,
         X_EXPENDITURE_ITEM_DATE,
         X_TAX_GROUP_ID,
         X_TAX_CODE_ID,
         X_TAX_CLASSIFICATION_CODE,
         X_TAX_INCLUDED,
         X_DISTRIBUTION_SET_ID,
         X_INV_RULE_ID,
         X_ACCOUNT_RULE_ID,
         X_SALESREP_ID,
         X_APPROVED_BY,
         X_STATUS,
         X_INDEX_PERIOD_ID,
         X_INDEX_TERM_INDICATOR,
         X_PO_HEADER_ID,
         X_CUST_PO_NUMBER,
         X_RECEIPT_METHOD_ID,
         X_VAR_RENT_INV_ID,
         X_VAR_RENT_TYPE,
         X_PERIOD_BILLREC_ID,
         X_REC_AGR_LINE_ID,
         X_AMOUNT_TYPE,
         X_CHANGED_FLAG,
         X_TERM_TEMPLATE_ID,
         l_legal_entity_id,
         X_ATTRIBUTE_CATEGORY,
         X_ATTRIBUTE1,
         X_ATTRIBUTE2,
         X_ATTRIBUTE3,
         X_ATTRIBUTE4,
         X_ATTRIBUTE5,
         X_ATTRIBUTE6,
         X_ATTRIBUTE7,
         X_ATTRIBUTE8,
         X_ATTRIBUTE9,
         X_ATTRIBUTE10,
         X_ATTRIBUTE11,
         X_ATTRIBUTE12,
         X_ATTRIBUTE13,
         X_ATTRIBUTE14,
         X_ATTRIBUTE15,
         X_PROJECT_ATTRIBUTE_CATEGORY,
         X_PROJECT_ATTRIBUTE1,
         X_PROJECT_ATTRIBUTE2,
         X_PROJECT_ATTRIBUTE3,
         X_PROJECT_ATTRIBUTE4,
         X_PROJECT_ATTRIBUTE5,
         X_PROJECT_ATTRIBUTE6,
         X_PROJECT_ATTRIBUTE7,
         X_PROJECT_ATTRIBUTE8,
         X_PROJECT_ATTRIBUTE9,
         X_PROJECT_ATTRIBUTE10,
         X_PROJECT_ATTRIBUTE11,
         X_PROJECT_ATTRIBUTE12,
         X_PROJECT_ATTRIBUTE13,
         X_PROJECT_ATTRIBUTE14,
         X_PROJECT_ATTRIBUTE15,
         L_ORG_ID,
         X_LEASE_STATUS,
         X_RECOVERABLE_FLAG,
         X_AREA_TYPE_CODE,
         X_AREA,
         X_GROUPING_RULE_ID,
         X_TERM_ALTERED_FLAG,
         X_SOURCE_CODE,
         X_TERM_COMMENTS,
         X_NORM_START_DATE,
         X_PARENT_TERM_ID,
         X_INDEX_NORM_FLAG,
         X_INCLUDE_IN_VAR_RENT,
         l_update_nbp_flag,
         X_RECUR_BB_CALC_DATE,
         X_OPEX_AGR_ID,
         X_OPEX_RECON_ID,
         X_OPEX_TYPE
      )
      RETURNING payment_term_id INTO X_PAYMENT_TERM_ID;

   EXCEPTION
     WHEN OTHERS THEN
      NULL;
   END;

   OPEN c;
      FETCH c INTO x_rowid;
      IF (c%NOTFOUND) THEN
         CLOSE c;
        RAISE NO_DATA_FOUND;
      END IF;
   CLOSE c;

   pnp_debug_pkg.debug ('PNT_PAYMENT_TERMS_PKG.INSERT_ROW (-)');
END insert_row;

-------------------------------------------------------------------------------
-- PROCDURE     : LOCK_ROW
-- INVOKED FROM : LOCK_ROW procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 04-DEC-03  ftanudja  o Added parameter area_type_code, area. 3257508.
-- 15-JUL-05  ftanudja  o R12 changes. #4495054, #4497295
-- 14-SEP-06  sdmahesh  o Bug # 5525354
--                        Modified the check for tax_included for expense side
--                        upgraded terms
-- 02-JAn-07  Hareesha  o M28#16 Added X_RECUR_BB_CALC_DATE
-- 06-MAR-07 Prabhakar  o Added opex_agr_id, opex_recon_id and opex_type
--                       for lock row handlers.
-------------------------------------------------------------------------------
PROCEDURE LOCK_ROW (
                       X_PAYMENT_TERM_ID               IN     NUMBER,
                       X_PAYMENT_PURPOSE_CODE          IN     VARCHAR2,
                       X_PAYMENT_TERM_TYPE_CODE        IN     VARCHAR2,
                       X_FREQUENCY_CODE                IN     VARCHAR2,
                       X_LEASE_ID                      IN     NUMBER,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_START_DATE                    IN     DATE,
                       X_END_DATE                      IN     DATE,
                       X_VENDOR_ID                     IN     NUMBER,
                       X_VENDOR_SITE_ID                IN     NUMBER,
                       X_CUSTOMER_ID                   IN     NUMBER,
                       X_CUSTOMER_SITE_USE_ID          IN     NUMBER,
                       X_TARGET_DATE                   IN     DATE,
                       X_ACTUAL_AMOUNT                 IN     NUMBER,
                       X_ESTIMATED_AMOUNT              IN     NUMBER,
                       X_SET_OF_BOOKS_ID               IN     NUMBER,
                       X_CURRENCY_CODE                 IN     VARCHAR2,
                       X_RATE                          IN     NUMBER,
                       X_NORMALIZE                     IN     VARCHAR2,
                       X_LOCATION_ID                   IN     NUMBER,
                       X_SCHEDULE_DAY                  IN     NUMBER,
                       X_CUST_SHIP_SITE_ID             IN     NUMBER,
                       X_AP_AR_TERM_ID                 IN     NUMBER,
                       X_CUST_TRX_TYPE_ID              IN     NUMBER,
                       X_PROJECT_ID                    IN     NUMBER,
                       X_TASK_ID                       IN     NUMBER,
                       X_ORGANIZATION_ID               IN     NUMBER,
                       X_EXPENDITURE_TYPE              IN     VARCHAR2,
                       X_EXPENDITURE_ITEM_DATE         IN     DATE,
                       X_TAX_GROUP_ID                  IN     NUMBER,
                       X_TAX_CODE_ID                   IN     NUMBER,
                       X_TAX_CLASSIFICATION_CODE       IN     VARCHAR2,
                       X_TAX_INCLUDED                  IN     VARCHAR2,
                       X_DISTRIBUTION_SET_ID           IN     NUMBER,
                       X_INV_RULE_ID                   IN     NUMBER,
                       X_ACCOUNT_RULE_ID               IN     NUMBER,
                       X_SALESREP_ID                   IN     NUMBER,
                       X_APPROVED_BY                   IN     NUMBER,
                       X_STATUS                        IN     VARCHAR2,
                       X_INDEX_PERIOD_ID               IN     NUMBER,
                       X_INDEX_TERM_INDICATOR          IN     VARCHAR2,
                       X_PO_HEADER_ID                  IN     NUMBER,
                       X_CUST_PO_NUMBER                IN     VARCHAR2,
                       X_RECEIPT_METHOD_ID             IN     NUMBER,
                       X_VAR_RENT_INV_ID               IN     NUMBER ,
                       X_VAR_RENT_TYPE                 IN     VARCHAR2,
                       X_CHANGED_FLAG                  IN     VARCHAR2,
                       X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
                       X_ATTRIBUTE1                    IN     VARCHAR2,
                       X_ATTRIBUTE2                    IN     VARCHAR2,
                       X_ATTRIBUTE3                    IN     VARCHAR2,
                       X_ATTRIBUTE4                    IN     VARCHAR2,
                       X_ATTRIBUTE5                    IN     VARCHAR2,
                       X_ATTRIBUTE6                    IN     VARCHAR2,
                       X_ATTRIBUTE7                    IN     VARCHAR2,
                       X_ATTRIBUTE8                    IN     VARCHAR2,
                       X_ATTRIBUTE9                    IN     VARCHAR2,
                       X_ATTRIBUTE10                   IN     VARCHAR2,
                       X_ATTRIBUTE11                   IN     VARCHAR2,
                       X_ATTRIBUTE12                   IN     VARCHAR2,
                       X_ATTRIBUTE13                   IN     VARCHAR2,
                       X_ATTRIBUTE14                   IN     VARCHAR2,
                       X_ATTRIBUTE15                   IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE_CATEGORY    IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE1            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE2            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE3            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE4            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE5            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE6            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE7            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE8            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE9            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE10           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE11           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE12           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE13           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE14           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE15           IN     VARCHAR2,
                       x_recoverable_flag              IN     VARCHAR2,
                       x_area_type_code                IN     VARCHAR2,
                       x_area                          IN     NUMBER,
                       x_grouping_rule_id              IN     NUMBER,
                       x_term_comments                 IN     VARCHAR2,
                       X_TERM_TEMPLATE_ID              IN     NUMBER,
                       x_include_in_var_rent           IN     VARCHAR2 DEFAULT NULL,
                       X_RECUR_BB_CALC_DATE            IN     DATE,
                       x_opex_agr_id                   IN     NUMBER,
                       x_opex_recon_id                 IN     NUMBER,
                       x_opex_type                     IN     VARCHAR2

                     )
IS
   CURSOR c1 IS
      SELECT *
      FROM   PN_PAYMENT_TERMS_ALL
      WHERE  PAYMENT_TERM_ID = X_PAYMENT_TERM_ID
      FOR UPDATE OF payment_term_id NOWAIT;

  --tlinfo c1%rowtype;

BEGIN
   pnp_debug_pkg.debug ('PNT_PAYMENT_TERMS_PKG.LOCK_ROW (+)');

   OPEN c1;
      FETCH c1 INTO tlinfo;
      IF (c1%NOTFOUND) THEN
         CLOSE c1;
         RETURN;
      END IF;
   CLOSE c1;

   IF NOT (tlinfo.PAYMENT_TERM_ID = X_PAYMENT_TERM_ID) THEN
      pn_var_rent_pkg.lock_row_exception('PAYMENT_TERM_ID',tlinfo.PAYMENT_TERM_ID);
   END IF;

   IF NOT (tlinfo.PAYMENT_PURPOSE_CODE = X_PAYMENT_PURPOSE_CODE) THEN
      pn_var_rent_pkg.lock_row_exception('PAYMENT_PURPOSE_CODE',tlinfo.PAYMENT_PURPOSE_CODE);
   END IF;

   IF NOT (tlinfo.PAYMENT_TERM_TYPE_CODE = X_PAYMENT_TERM_TYPE_CODE) THEN
      pn_var_rent_pkg.lock_row_exception('PAYMENT_TERM_TYPE_CODE',tlinfo.PAYMENT_TERM_TYPE_CODE);
   END IF;

   IF NOT (tlinfo.FREQUENCY_CODE = X_FREQUENCY_CODE) THEN
      pn_var_rent_pkg.lock_row_exception('FREQUENCY_CODE',tlinfo.FREQUENCY_CODE);
   END IF;

   IF NOT (tlinfo.LEASE_ID = X_LEASE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_ID',tlinfo.LEASE_ID);
   END IF;

   IF NOT (tlinfo.LEASE_CHANGE_ID = X_LEASE_CHANGE_ID) THEN
      pn_var_rent_pkg.lock_row_exception('LEASE_CHANGE_ID',tlinfo.LEASE_CHANGE_ID);
   END IF;

   IF NOT (tlinfo.START_DATE = X_START_DATE) THEN
      pn_var_rent_pkg.lock_row_exception('START_DATE',tlinfo.START_DATE);
   END IF;

   IF NOT (tlinfo.END_DATE = X_END_DATE) THEN
      pn_var_rent_pkg.lock_row_exception('END_DATE',tlinfo.END_DATE);
   END IF;

   IF NOT ((tlinfo.VENDOR_ID = X_VENDOR_ID)
       OR ((tlinfo.VENDOR_ID IS NULL) AND (X_VENDOR_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('VENDOR_ID',tlinfo.VENDOR_ID);
   END IF;

   IF NOT ((tlinfo.VENDOR_SITE_ID = X_VENDOR_SITE_ID)
       OR ((tlinfo.VENDOR_SITE_ID IS NULL) AND (X_VENDOR_SITE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('VENDOR_SITE_ID',tlinfo.VENDOR_SITE_ID);
   END IF;

   IF NOT ((tlinfo.CUSTOMER_ID = X_CUSTOMER_ID)
       OR ((tlinfo.CUSTOMER_ID IS NULL) AND (X_CUSTOMER_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CUSTOMER_ID',tlinfo.CUSTOMER_ID);
   END IF;

   IF NOT ((tlinfo.CUSTOMER_SITE_USE_ID = X_CUSTOMER_SITE_USE_ID)
       OR ((tlinfo.CUSTOMER_SITE_USE_ID IS NULL) AND (X_CUSTOMER_SITE_USE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CUSTOMER_SITE_USE_ID',tlinfo.CUSTOMER_SITE_USE_ID);
   END IF;

   IF NOT ((tlinfo.TARGET_DATE = X_TARGET_DATE)
       OR ((tlinfo.TARGET_DATE IS NULL) AND (X_TARGET_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('TARGET_DATE',tlinfo.TARGET_DATE);
   END IF;

   IF NOT ((tlinfo.ACTUAL_AMOUNT = X_ACTUAL_AMOUNT)
       OR ((tlinfo.ACTUAL_AMOUNT IS NULL) AND (X_ACTUAL_AMOUNT IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ACTUAL_AMOUNT',tlinfo.ACTUAL_AMOUNT);
   END IF;

   IF NOT ((tlinfo.ESTIMATED_AMOUNT = X_ESTIMATED_AMOUNT)
       OR ((tlinfo.ESTIMATED_AMOUNT IS NULL) AND (X_ESTIMATED_AMOUNT IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ESTIMATED_AMOUNT',tlinfo.ESTIMATED_AMOUNT);
   END IF;

   IF NOT (tlinfo.SET_OF_BOOKS_ID = X_SET_OF_BOOKS_ID) THEN
      pn_var_rent_pkg.lock_row_exception('SET_OF_BOOKS_ID',tlinfo.SET_OF_BOOKS_ID);
   END IF;

   IF NOT (tlinfo.CURRENCY_CODE = X_CURRENCY_CODE) THEN
      pn_var_rent_pkg.lock_row_exception('CURRENCY_CODE',tlinfo.CURRENCY_CODE);
   END IF;

   IF NOT ((tlinfo.RATE = X_RATE)
       OR ((tlinfo.RATE IS NULL) AND (X_RATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RATE',tlinfo.RATE);
   END IF;

   IF NOT ((tlinfo.NORMALIZE = X_NORMALIZE)
       OR ((tlinfo.NORMALIZE IS NULL) AND (X_NORMALIZE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('NORMALIZE',tlinfo.NORMALIZE);
   END IF;

   IF NOT ((tlinfo.LOCATION_ID = X_LOCATION_ID)
       OR ((tlinfo.LOCATION_ID IS NULL) AND (X_LOCATION_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('LOCATION_ID',tlinfo.LOCATION_ID);
   END IF;

   IF NOT ((tlinfo.SCHEDULE_DAY = X_SCHEDULE_DAY)
       OR ((tlinfo.SCHEDULE_DAY IS NULL) AND (X_SCHEDULE_DAY IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('SCHEDULE_DAY',tlinfo.SCHEDULE_DAY);
   END IF;

   IF NOT ((tlinfo.CUST_SHIP_SITE_ID = X_CUST_SHIP_SITE_ID)
       OR ((tlinfo.CUST_SHIP_SITE_ID IS NULL) AND (X_CUST_SHIP_SITE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CUST_SHIP_SITE_ID',tlinfo.CUST_SHIP_SITE_ID);
   END IF;

   IF NOT ((tlinfo.AP_AR_TERM_ID = X_AP_AR_TERM_ID)
       OR ((tlinfo.AP_AR_TERM_ID IS NULL) AND (X_AP_AR_TERM_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AP_AR_TERM_ID',tlinfo.AP_AR_TERM_ID);
   END IF;

   IF NOT ((tlinfo.CUST_TRX_TYPE_ID = X_CUST_TRX_TYPE_ID)
       OR ((tlinfo.CUST_TRX_TYPE_ID IS NULL) AND (X_CUST_TRX_TYPE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CUST_TRX_TYPE_ID',tlinfo.CUST_TRX_TYPE_ID);
   END IF;

   IF NOT ((tlinfo.PROJECT_ID = X_PROJECT_ID)
       OR ((tlinfo.PROJECT_ID IS NULL) AND (X_PROJECT_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ID',tlinfo.PROJECT_ID);
   END IF;

   IF NOT ((tlinfo.TASK_ID = X_TASK_ID)
       OR ((tlinfo.TASK_ID IS NULL) AND (X_TASK_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('TASK_ID',tlinfo.TASK_ID);
   END IF;

   IF NOT ((tlinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
       OR ((tlinfo.ORGANIZATION_ID IS NULL) AND (X_ORGANIZATION_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ORGANIZATION_ID',tlinfo.ORGANIZATION_ID);
   END IF;

   IF NOT ((tlinfo.EXPENDITURE_TYPE = X_EXPENDITURE_TYPE)
       OR ((tlinfo.EXPENDITURE_TYPE IS NULL) AND (X_EXPENDITURE_TYPE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('EXPENDITURE_TYPE',tlinfo.EXPENDITURE_TYPE);
   END IF;

   IF NOT ((tlinfo.EXPENDITURE_ITEM_DATE = X_EXPENDITURE_ITEM_DATE)
       OR ((tlinfo.EXPENDITURE_ITEM_DATE IS NULL) AND (X_EXPENDITURE_ITEM_DATE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('EXPENDITURE_ITEM_DATE',tlinfo.EXPENDITURE_ITEM_DATE);
   END IF;

   IF pn_r12_util_pkg.is_r12 AND
      NOT ((tlinfo.TAX_CLASSIFICATION_CODE = X_TAX_CLASSIFICATION_CODE)
       OR ((tlinfo.TAX_CLASSIFICATION_CODE IS NULL) AND (X_TAX_CLASSIFICATION_CODE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('TAX_GROUP_ID',tlinfo.TAX_CLASSIFICATION_CODE);
   END IF;

   IF NOT pn_r12_util_pkg.is_r12 AND
      NOT ((tlinfo.TAX_GROUP_ID = X_TAX_GROUP_ID)
       OR ((tlinfo.TAX_GROUP_ID IS NULL) AND (X_TAX_GROUP_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('TAX_GROUP_ID',tlinfo.TAX_GROUP_ID);
   END IF;

   IF NOT pn_r12_util_pkg.is_r12 AND
      NOT ((tlinfo.TAX_CODE_ID = X_TAX_CODE_ID)
       OR ((tlinfo.TAX_CODE_ID IS NULL) AND (X_TAX_CODE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('TAX_CODE_ID',tlinfo.TAX_CODE_ID);
   END IF;

   IF ((tlinfo.TAX_INCLUDED = 'Y')  AND
        (tlinfo.VENDOR_SITE_ID IS NOT NULL) AND
        (pn_r12_util_pkg.is_r12)) THEN

     IF X_TAX_INCLUDED <> 'A' THEN

       pn_var_rent_pkg.lock_row_exception('TAX_INCLUDED',tlinfo.TAX_INCLUDED);

     END IF;

   ELSIF NOT ((tlinfo.TAX_INCLUDED = X_TAX_INCLUDED)
         OR ((tlinfo.TAX_INCLUDED IS NULL) AND (X_TAX_INCLUDED IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('TAX_INCLUDED',tlinfo.TAX_INCLUDED);

   END IF;

   IF NOT ((tlinfo.DISTRIBUTION_SET_ID = X_DISTRIBUTION_SET_ID)
       OR ((tlinfo.DISTRIBUTION_SET_ID IS NULL) AND (X_DISTRIBUTION_SET_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('DISTRIBUTION_SET_ID',tlinfo.DISTRIBUTION_SET_ID);
   END IF;

   IF NOT ((tlinfo.INV_RULE_ID = X_INV_RULE_ID)
       OR ((tlinfo.INV_RULE_ID IS NULL) AND (X_INV_RULE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('INV_RULE_ID',tlinfo.INV_RULE_ID);
   END IF;

   IF NOT ((tlinfo.ACCOUNT_RULE_ID = X_ACCOUNT_RULE_ID)
       OR ((tlinfo.ACCOUNT_RULE_ID IS NULL) AND (X_ACCOUNT_RULE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ACCOUNT_RULE_ID',tlinfo.ACCOUNT_RULE_ID);
   END IF;

   IF NOT ((tlinfo.SALESREP_ID = X_SALESREP_ID)
       OR ((tlinfo.SALESREP_ID IS NULL) AND (X_SALESREP_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('SALESREP_ID',tlinfo.SALESREP_ID);
   END IF;

   IF NOT ((tlinfo.APPROVED_BY = X_APPROVED_BY)
       OR ((tlinfo.APPROVED_BY IS NULL) AND (X_APPROVED_BY IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('APPROVED_BY',tlinfo.APPROVED_BY);
   END IF;

   IF NOT ((tlinfo.STATUS = X_STATUS)
       OR ((tlinfo.STATUS IS NULL) AND (X_STATUS IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('STATUS',tlinfo.STATUS);
   END IF;

   IF NOT ((tlinfo.INDEX_PERIOD_ID = X_INDEX_PERIOD_ID)
       OR ((tlinfo.INDEX_PERIOD_ID IS NULL) AND (X_INDEX_PERIOD_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_PERIOD_ID',tlinfo.INDEX_PERIOD_ID);
   END IF;

   IF NOT ((tlinfo.INDEX_TERM_INDICATOR = X_INDEX_TERM_INDICATOR)
       OR ((tlinfo.INDEX_TERM_INDICATOR IS NULL) AND (X_INDEX_TERM_INDICATOR IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('INDEX_TERM_INDICATOR',tlinfo.INDEX_TERM_INDICATOR);
   END IF;

   IF NOT ((tlinfo.PO_HEADER_ID = X_PO_HEADER_ID)
       OR ((tlinfo.PO_HEADER_ID IS NULL) AND (X_PO_HEADER_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PO_HEADER_ID',tlinfo.PO_HEADER_ID);
   END IF;

   IF NOT ((tlinfo.CUST_PO_NUMBER = X_CUST_PO_NUMBER)
       OR ((tlinfo.CUST_PO_NUMBER IS NULL) AND (X_CUST_PO_NUMBER IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('CUST_PO_NUMBER',tlinfo.CUST_PO_NUMBER);
   END IF;

   IF NOT ((tlinfo.RECEIPT_METHOD_ID = X_RECEIPT_METHOD_ID)
       OR ((tlinfo.RECEIPT_METHOD_ID IS NULL) AND (X_RECEIPT_METHOD_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RECEIPT_METHOD_ID',tlinfo.RECEIPT_METHOD_ID);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
       OR ((tlinfo.ATTRIBUTE_CATEGORY IS NULL) AND (X_ATTRIBUTE_CATEGORY IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE_CATEGORY',tlinfo.ATTRIBUTE_CATEGORY);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
       OR ((tlinfo.ATTRIBUTE1 IS NULL) AND (X_ATTRIBUTE1 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE1',tlinfo.ATTRIBUTE1);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
       OR ((tlinfo.ATTRIBUTE2 IS NULL) AND (X_ATTRIBUTE2 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE2',tlinfo.ATTRIBUTE2);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
       OR ((tlinfo.ATTRIBUTE3 IS NULL) AND (X_ATTRIBUTE3 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE3',tlinfo.ATTRIBUTE3);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
       OR ((tlinfo.ATTRIBUTE4 IS NULL) AND (X_ATTRIBUTE4 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE4',tlinfo.ATTRIBUTE4);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
       OR ((tlinfo.ATTRIBUTE5 IS NULL) AND (X_ATTRIBUTE5 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE5',tlinfo.ATTRIBUTE5);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
       OR ((tlinfo.ATTRIBUTE6 IS NULL) AND (X_ATTRIBUTE6 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE6',tlinfo.ATTRIBUTE6);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
       OR ((tlinfo.ATTRIBUTE7 IS NULL) AND (X_ATTRIBUTE7 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE7',tlinfo.ATTRIBUTE7);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
       OR ((tlinfo.ATTRIBUTE8 IS NULL) AND (X_ATTRIBUTE8 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE8',tlinfo.ATTRIBUTE8);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
       OR ((tlinfo.ATTRIBUTE9 IS NULL) AND (X_ATTRIBUTE9 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE9',tlinfo.ATTRIBUTE9);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
       OR ((tlinfo.ATTRIBUTE10 IS NULL) AND (X_ATTRIBUTE10 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE10',tlinfo.ATTRIBUTE10);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
       OR ((tlinfo.ATTRIBUTE11 IS NULL) AND (X_ATTRIBUTE11 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE11',tlinfo.ATTRIBUTE11);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((tlinfo.ATTRIBUTE12 IS NULL) AND (X_ATTRIBUTE12 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE12',tlinfo.ATTRIBUTE12);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
       OR ((tlinfo.ATTRIBUTE13 IS NULL) AND (X_ATTRIBUTE13 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE13',tlinfo.ATTRIBUTE13);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
       OR ((tlinfo.ATTRIBUTE14 IS NULL) AND (X_ATTRIBUTE14 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE14',tlinfo.ATTRIBUTE14);
   END IF;

   IF NOT ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
       OR ((tlinfo.ATTRIBUTE15 IS NULL) AND (X_ATTRIBUTE15 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE15',tlinfo.ATTRIBUTE15);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE_CATEGORY = X_PROJECT_ATTRIBUTE_CATEGORY)
       OR ((tlinfo.PROJECT_ATTRIBUTE_CATEGORY IS NULL) AND (X_PROJECT_ATTRIBUTE_CATEGORY IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE_CATEGORY',tlinfo.PROJECT_ATTRIBUTE_CATEGORY);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE1 = X_PROJECT_ATTRIBUTE1)
       OR ((tlinfo.PROJECT_ATTRIBUTE1 IS NULL) AND (X_PROJECT_ATTRIBUTE1 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE1',tlinfo.PROJECT_ATTRIBUTE1);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE2 = X_PROJECT_ATTRIBUTE2)
       OR ((tlinfo.PROJECT_ATTRIBUTE2 IS NULL) AND (X_PROJECT_ATTRIBUTE2 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE2',tlinfo.PROJECT_ATTRIBUTE2);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE3 = X_PROJECT_ATTRIBUTE3)
       OR ((tlinfo.PROJECT_ATTRIBUTE3 IS NULL) AND (X_PROJECT_ATTRIBUTE3 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE3',tlinfo.PROJECT_ATTRIBUTE3);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE4 = X_PROJECT_ATTRIBUTE4)
       OR ((tlinfo.PROJECT_ATTRIBUTE4 IS NULL) AND (X_PROJECT_ATTRIBUTE4 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE4',tlinfo.PROJECT_ATTRIBUTE4);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE5 = X_PROJECT_ATTRIBUTE5)
       OR ((tlinfo.PROJECT_ATTRIBUTE5 IS NULL) AND (X_PROJECT_ATTRIBUTE5 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE5',tlinfo.PROJECT_ATTRIBUTE5);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE6 = X_PROJECT_ATTRIBUTE6)
       OR ((tlinfo.PROJECT_ATTRIBUTE6 IS NULL) AND (X_PROJECT_ATTRIBUTE6 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE6',tlinfo.PROJECT_ATTRIBUTE6);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE7 = X_PROJECT_ATTRIBUTE7)
       OR ((tlinfo.PROJECT_ATTRIBUTE7 IS NULL) AND (X_PROJECT_ATTRIBUTE7 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE7',tlinfo.PROJECT_ATTRIBUTE7);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE8 = X_PROJECT_ATTRIBUTE8)
       OR ((tlinfo.PROJECT_ATTRIBUTE8 IS NULL) AND (X_PROJECT_ATTRIBUTE8 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE8',tlinfo.PROJECT_ATTRIBUTE8);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE9 = X_PROJECT_ATTRIBUTE9)
       OR ((tlinfo.PROJECT_ATTRIBUTE9 IS NULL) AND (X_PROJECT_ATTRIBUTE9 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE9',tlinfo.PROJECT_ATTRIBUTE9);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE10 = X_PROJECT_ATTRIBUTE10)
       OR ((tlinfo.PROJECT_ATTRIBUTE10 IS NULL) AND (X_PROJECT_ATTRIBUTE10 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE10',tlinfo.PROJECT_ATTRIBUTE10);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE11 = X_PROJECT_ATTRIBUTE11)
       OR ((tlinfo.PROJECT_ATTRIBUTE11 IS NULL) AND (X_PROJECT_ATTRIBUTE11 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE11',tlinfo.PROJECT_ATTRIBUTE11);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE12 = X_PROJECT_ATTRIBUTE12)
       OR ((tlinfo.PROJECT_ATTRIBUTE12 IS NULL) AND (X_PROJECT_ATTRIBUTE12 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE12',tlinfo.PROJECT_ATTRIBUTE12);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE13 = X_PROJECT_ATTRIBUTE13)
       OR ((tlinfo.PROJECT_ATTRIBUTE13 IS NULL) AND (X_PROJECT_ATTRIBUTE13 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE13',tlinfo.PROJECT_ATTRIBUTE13);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE14 = X_PROJECT_ATTRIBUTE14)
       OR ((tlinfo.PROJECT_ATTRIBUTE14 IS NULL) AND (X_PROJECT_ATTRIBUTE14 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE14',tlinfo.PROJECT_ATTRIBUTE14);
   END IF;

   IF NOT ((tlinfo.PROJECT_ATTRIBUTE15 = X_PROJECT_ATTRIBUTE15)
       OR ((tlinfo.PROJECT_ATTRIBUTE15 IS NULL) AND (X_PROJECT_ATTRIBUTE15 IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ATTRIBUTE15',tlinfo.PROJECT_ATTRIBUTE15);
   END IF;

   IF NOT ((tlinfo.VAR_RENT_INV_ID = X_VAR_RENT_INV_ID)
       OR ((tlinfo.VAR_RENT_INV_ID IS NULL) AND (X_VAR_RENT_INV_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('VAR_RENT_INV_ID',tlinfo.VAR_RENT_INV_ID);
   END IF;

   IF NOT ((tlinfo.VAR_RENT_TYPE = X_VAR_RENT_TYPE)
       OR ((tlinfo.VAR_RENT_TYPE IS NULL) AND (X_VAR_RENT_TYPE IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('VAR_RENT_TYPE',tlinfo.VAR_RENT_TYPE);
   END IF;

   IF NOT ((tlinfo.recoverable_flag = x_recoverable_flag)
       OR ((tlinfo.recoverable_flag IS NULL) AND (x_recoverable_flag IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RECOVERABLE_FLAG',tlinfo.recoverable_flag);
   END IF;

   IF NOT ((tlinfo.area_type_code = x_area_type_code)
       OR ((tlinfo.area_type_code IS NULL) AND (x_area_type_code IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AREA_TYPE_CODE',tlinfo.area_type_code);
   END IF;

   IF NOT ((tlinfo.area = x_area)
       OR ((tlinfo.area IS NULL) AND (x_area IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('AREA',tlinfo.area);
   END IF;

   IF NOT ((tlinfo.grouping_rule_id = x_grouping_rule_id)
       OR ((tlinfo.grouping_rule_id IS NULL) AND (x_grouping_rule_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('GROUPING_RULE_ID',tlinfo.grouping_rule_id);
   END IF;

   IF NOT ((tlinfo.term_comments = x_term_comments)
       OR ((tlinfo.term_comments IS NULL) AND (x_term_comments IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('TERM_COMMENTS',tlinfo.term_comments);
   END IF;

   IF NOT ((tlinfo.TERM_TEMPLATE_ID = X_TERM_TEMPLATE_ID)
       OR ((tlinfo.TERM_TEMPLATE_ID IS NULL) AND (X_TERM_TEMPLATE_ID IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('TERM_TEMPLATE_ID',tlinfo.TERM_TEMPLATE_ID);
   END IF;

   IF NOT ((tlinfo.include_in_var_rent = x_include_in_var_rent)
       OR ((tlinfo.include_in_var_rent IS NULL) AND (x_include_in_var_rent IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('INCLUDE_IN_VAR_RENT',tlinfo.include_in_var_rent);
   END IF;

   IF NOT ((tlinfo.recur_bb_calc_date = x_recur_bb_calc_date)
       OR ((tlinfo.recur_bb_calc_date IS NULL) AND (x_recur_bb_calc_date IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RECUR_BB_CALC_DATE',tlinfo.recur_bb_calc_date);
   END IF;

   IF NOT ((tlinfo.opex_agr_id = x_opex_agr_id)
       OR ((tlinfo.opex_agr_id IS NULL) AND (x_opex_agr_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OPEX_AGR_ID',tlinfo.opex_agr_id);
   END IF;

   IF NOT ((tlinfo.opex_recon_id = x_opex_recon_id)
       OR ((tlinfo.opex_recon_id IS NULL) AND (x_opex_recon_id IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('OPEX_RECON_ID',tlinfo.opex_recon_id);
   END IF;

   IF NOT ((tlinfo.opex_type = x_opex_type)
       OR ((tlinfo.opex_type IS NULL) AND (x_opex_type IS NULL))) THEN
      pn_var_rent_pkg.lock_row_exception('RECUR_BB_CALC_DATE',tlinfo.opex_type);
   END IF;

   pnp_debug_pkg.debug ('PNT_PAYMENT_TERMS_PKG.LOCK_ROW (-)');

END LOCK_ROW;

-------------------------------------------------------------------------------=
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : UPDATE_ROW procedure
-- PURPOSE      : updates a term
-- HISTORY      :
-- 04-DEC-03  ftanudja o Added parameter area_type_code, area. 3257508.
-- 15-JUL-05  ftanudja o R12 changes. #4495054, #4497295
-- 25-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_payment_terms, pn_leases
--                       with _ALL table.
-- 24-NOV-05  Kiran     o rounding for amounts done based on currency precision
-- 01-DEC-05  Hareesha  o Fetched legal_entity_id into l_legal_entity_id
--                        for handling incase it has distributions.
-- 14-AUG-06  Pikhar    o Set update_nbp_flag to 'Y' on update
-- 27-SEP-06  Pikhar    o Bug 5550641. Added NVL to include_in_var_rent
-- 02-JAN-07  Hareesha  o M28#16 Added X_RECUR_BB_CALC_DATE
-- 06-MAR-07 Prabhakar  o Added opex_agr_id, opex_recon_id and opex_type
--                       for update row handlers.
-- 11-DEC-09  rthumma   o Bug 9089546 : Modified call to UPDATE_PNT_ITEMS_AMT
--                        to pass x_frequency_code.
--------------------------------------------------------------------------------
PROCEDURE UPDATE_ROW (
                       X_PAYMENT_TERM_ID               IN     NUMBER,
                       X_PAYMENT_PURPOSE_CODE          IN     VARCHAR2,
                       X_PAYMENT_TERM_TYPE_CODE        IN     VARCHAR2,
                       X_FREQUENCY_CODE                IN     VARCHAR2,
                       X_LEASE_ID                      IN     NUMBER,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_START_DATE                    IN     DATE,
                       X_END_DATE                      IN     DATE,
                       X_VENDOR_ID                     IN     NUMBER,
                       X_VENDOR_SITE_ID                IN     NUMBER,
                       X_CUSTOMER_ID                   IN     NUMBER,
                       X_CUSTOMER_SITE_USE_ID          IN     NUMBER,
                       X_TARGET_DATE                   IN     DATE,
                       X_ACTUAL_AMOUNT                 IN     NUMBER,
                       X_ESTIMATED_AMOUNT              IN     NUMBER,
                       X_SET_OF_BOOKS_ID               IN     NUMBER,
                       X_CURRENCY_CODE                 IN     VARCHAR2,
                       X_RATE                          IN     NUMBER,
                       X_NORMALIZE                     IN     VARCHAR2,
                       X_LOCATION_ID                   IN     NUMBER,
                       X_SCHEDULE_DAY                  IN     NUMBER,
                       X_CUST_SHIP_SITE_ID             IN     NUMBER,
                       X_AP_AR_TERM_ID                 IN     NUMBER,
                       X_CUST_TRX_TYPE_ID              IN     NUMBER,
                       X_PROJECT_ID                    IN     NUMBER,
                       X_TASK_ID                       IN     NUMBER,
                       X_ORGANIZATION_ID               IN     NUMBER,
                       X_EXPENDITURE_TYPE              IN     VARCHAR2,
                       X_EXPENDITURE_ITEM_DATE         IN     DATE,
                       X_TAX_GROUP_ID                  IN     NUMBER,
                       X_TAX_CODE_ID                   IN     NUMBER,
                       X_TAX_CLASSIFICATION_CODE       IN     VARCHAR2,
                       X_TAX_INCLUDED                  IN     VARCHAR2,
                       X_DISTRIBUTION_SET_ID           IN     NUMBER,
                       X_INV_RULE_ID                   IN     NUMBER,
                       X_ACCOUNT_RULE_ID               IN     NUMBER,
                       X_SALESREP_ID                   IN     NUMBER,
                       X_APPROVED_BY                   IN     NUMBER,
                       X_STATUS                        IN     VARCHAR2,
                       X_INDEX_PERIOD_ID               IN     NUMBER,
                       X_INDEX_TERM_INDICATOR          IN     VARCHAR2,
                       X_PO_HEADER_ID                  IN     NUMBER,
                       X_CUST_PO_NUMBER                IN     VARCHAR2,
                       X_RECEIPT_METHOD_ID             IN     NUMBER,
                       X_VAR_RENT_INV_ID               IN     NUMBER,
                       X_VAR_RENT_TYPE                 IN     VARCHAR2,
                       X_CHANGED_FLAG                  IN     VARCHAR2,
                       X_ATTRIBUTE_CATEGORY            IN     VARCHAR2,
                       X_ATTRIBUTE1                    IN     VARCHAR2,
                       X_ATTRIBUTE2                    IN     VARCHAR2,
                       X_ATTRIBUTE3                    IN     VARCHAR2,
                       X_ATTRIBUTE4                    IN     VARCHAR2,
                       X_ATTRIBUTE5                    IN     VARCHAR2,
                       X_ATTRIBUTE6                    IN     VARCHAR2,
                       X_ATTRIBUTE7                    IN     VARCHAR2,
                       X_ATTRIBUTE8                    IN     VARCHAR2,
                       X_ATTRIBUTE9                    IN     VARCHAR2,
                       X_ATTRIBUTE10                   IN     VARCHAR2,
                       X_ATTRIBUTE11                   IN     VARCHAR2,
                       X_ATTRIBUTE12                   IN     VARCHAR2,
                       X_ATTRIBUTE13                   IN     VARCHAR2,
                       X_ATTRIBUTE14                   IN     VARCHAR2,
                       X_ATTRIBUTE15                   IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE_CATEGORY    IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE1            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE2            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE3            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE4            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE5            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE6            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE7            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE8            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE9            IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE10           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE11           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE12           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE13           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE14           IN     VARCHAR2,
                       X_PROJECT_ATTRIBUTE15           IN     VARCHAR2,
                       X_LAST_UPDATE_DATE              IN     DATE,
                       X_LAST_UPDATED_BY               IN     NUMBER,
                       X_LAST_UPDATE_LOGIN             IN     NUMBER,
                       x_recoverable_flag              IN     VARCHAR2,
                       x_area_type_code                IN     VARCHAR2,
                       x_area                          IN     NUMBER,
                       x_grouping_rule_id              IN     NUMBER,
                       x_term_altered_flag             IN     VARCHAR2,
                       x_source_code                   IN     VARCHAR2,
                       x_term_comments                 IN     VARCHAR2,
                       X_TERM_TEMPLATE_ID              IN     NUMBER,
                       x_include_in_var_rent           IN     VARCHAR2 DEFAULT NULL,
                       X_RECUR_BB_CALC_DATE            IN     DATE,
                       x_opex_agr_id                   IN     NUMBER,
                       x_opex_recon_id                 IN     NUMBER,
                       x_opex_type                     IN     VARCHAR2
                     )
IS
   CURSOR has_distributions IS
    SELECT 'Y'
    FROM dual
    WHERE EXISTS (SELECT 'Y' FROM pn_distributions_all
                  WHERE payment_term_id = x_payment_term_id);

   l_legal_entity_id       pn_payment_terms.legal_entity_id%TYPE;
   l_org_id                pn_payment_terms.org_id%TYPE;
   l_find_le               BOOLEAN;
   l_return_status         VARCHAR2 (2) := NULL;
   l_old_est               NUMBER;
   l_status                PN_LEASES.status%TYPE;
   l_context               varchar2(240);
   l_rate                  pn_payment_terms.rate%TYPE;
   l_precision             NUMBER;
   l_ext_precision         NUMBER;
   l_min_acct_unit         NUMBER;
   l_update_nbp_flag       VARCHAR2(1);

BEGIN

   pnp_debug_pkg.debug ('PNT_PAYMENT_TERMS_PKG.UPDATE_ROW (+)');

   -- Check IF both Estimated AND actual amount are NULL
   l_context := 'checking est AND actual amt';
   l_return_status        := NULL;
   PNT_PAYMENT_TERMS_PKG.CHECK_PAYMENT_AMOUNTS (
                                 l_RETURN_STATUS
                                ,X_ACTUAL_AMOUNT
                                ,X_ESTIMATED_AMOUNT
                                                );

   IF (l_return_status IS NOT NULL) THEN
      app_exception.Raise_Exception;
   END IF;


   IF ( tlinfo.start_date           <> X_START_DATE
     OR tlinfo.end_date             <> X_END_DATE
     OR tlinfo.actual_amount        <> X_ACTUAL_AMOUNT
     OR NVL(tlinfo.include_in_var_rent,'N')   <> NVL(X_INCLUDE_IN_VAR_RENT,'N')) THEN

     l_update_nbp_flag := 'Y';
   ELSE
     l_update_nbp_flag := NULL;
   END IF;

   -----------------------------------------------------------------------------
   --  Bug Fix : 1668495.
   --  Removed the call to the
   --  following PROCEDURE
   --  PNT_PAYMENT_TERMS_PKG.CHECK_APPROVED_SCHEDULE_EXISTS
   --  form the UPDATE TABLE HANDLER
   --  to allow the user to change the
   --  Vendor Information , Customer Information
   --  AND also the GL Account even when the
   --  approved payment schedules exists.
   -----------------------------------------------------------------------------

   /*
       Added the following IF statement logic in response to bug ID #1845607
       Please refer to PROCEDURE UPDATE_PNT_ITEMS_AMT
   */


   IF nvl(X_NORMALIZE,'N') = 'N' THEN

      l_context := 'SELECTing lease status';

      SELECT status
      INTO   l_status
      FROM   pn_leases_all
      WHERE  lease_id = X_LEASE_ID;

      l_context := 'SELECTing estimated amt';

      SELECT estimated_amount
      INTO l_old_est
      FROM pn_payment_terms_all
      WHERE payment_term_id = X_PAYMENT_TERM_ID;

      IF (l_status = 'F' AND l_old_est <> X_ESTIMATED_AMOUNT) THEN

         l_context := 'updating payment items amount';
         UPDATE_PNT_ITEMS_AMT(X_PAYMENT_TERM_ID,
                              l_old_est,
                              X_ESTIMATED_AMOUNT,
                              X_LEASE_ID,
                              X_START_DATE,
                              X_END_DATE,
                              X_FREQUENCY_CODE);
      END IF;

   END IF;

   l_context := 'Selecting old rate and org_id';

   SELECT rate, org_id,legal_entity_id
   INTO   l_rate, l_org_id,l_legal_entity_id
   FROM   pn_payment_terms_all
   WHERE  payment_term_id = X_PAYMENT_TERM_ID;

   l_context := 'updating payment items rate IF rate IS changed';

   -- use the fact that rate must be greater than zero
   IF (nvl(l_rate,0) <> nvl(X_RATE,-1)) THEN
      UPDATE_PNT_ITEMS_RATE(X_PAYMENT_TERM_ID, X_RATE);
   END IF;

   l_context := 'updating vendor AND customer info';

   PNT_PAYMENT_TERMS_PKG.UPDATE_VENDOR_AND_CUST (
                             X_PAYMENT_TERM_ID
                            ,X_VENDOR_ID
                            ,X_VENDOR_SITE_ID
                            ,X_LAST_UPDATE_DATE
                            ,X_LAST_UPDATED_BY
                            ,X_LAST_UPDATE_LOGIN
                            ,X_CUSTOMER_ID
                            ,X_CUSTOMER_SITE_USE_ID
                            ,X_CUST_SHIP_SITE_ID
                           );

   l_context := 'checking if legal entity changed';

   IF pn_r12_util_pkg.is_r12 THEN
     IF x_vendor_site_id IS NOT NULL THEN -- PAYABLES
       l_find_le := TRUE;
      IF l_legal_entity_id is NOT NULL THEN
       FOR chk_distributions IN has_distributions LOOP
          l_find_le := FALSE;
       END LOOP;
      END IF; /* 9162932 */

       IF l_find_le THEN
         l_legal_entity_id :=
            pn_r12_util_pkg.get_le_for_ap(
              p_code_combination_id => null
             ,p_location_id         => x_vendor_site_id
             ,p_org_id              => l_org_id
            );
       END IF;
     ELSIF x_customer_id is NOT NULL THEN    -- RECEIVABLES
       l_legal_entity_id :=
          pn_r12_util_pkg.get_le_for_ar(
            p_customer_id         => x_customer_id
           ,p_transaction_type_id => x_cust_trx_type_id
           ,p_org_id              => l_org_id
          );
     END IF;
   END IF;

   /* get currency info for rounding */
   fnd_currency.get_info( currency_code => x_currency_code
                         ,precision     => l_precision
                         ,ext_precision => l_ext_precision
                         ,min_acct_unit => l_min_acct_unit);

   l_context := 'updating payment terms';

   UPDATE PN_PAYMENT_TERMS_ALL
   SET    PAYMENT_TERM_ID                 = X_PAYMENT_TERM_ID,
          PAYMENT_PURPOSE_CODE            = X_PAYMENT_PURPOSE_CODE,
          PAYMENT_TERM_TYPE_CODE          = X_PAYMENT_TERM_TYPE_CODE,
          FREQUENCY_CODE                  = X_FREQUENCY_CODE,
          LEASE_ID                        = X_LEASE_ID,
          LEASE_CHANGE_ID                 = X_LEASE_CHANGE_ID,
          START_DATE                      = X_START_DATE,
          END_DATE                        = X_END_DATE,
          VENDOR_ID                       = X_VENDOR_ID,
          VENDOR_SITE_ID                  = X_VENDOR_SITE_ID,
          CUSTOMER_ID                     = X_CUSTOMER_ID,
          CUSTOMER_SITE_USE_ID            = X_CUSTOMER_SITE_USE_ID,
          TARGET_DATE                     = X_TARGET_DATE,
          ACTUAL_AMOUNT                   = ROUND(X_ACTUAL_AMOUNT, l_precision),
          ESTIMATED_AMOUNT                = ROUND(X_ESTIMATED_AMOUNT, l_precision),
          SET_OF_BOOKS_ID                 = X_SET_OF_BOOKS_ID,
          CURRENCY_CODE                   = X_CURRENCY_CODE,
          RATE                            = X_RATE,
          NORMALIZE                       = X_NORMALIZE,
          LOCATION_ID                     = X_LOCATION_ID,
          SCHEDULE_DAY                    = X_SCHEDULE_DAY,
          CUST_SHIP_SITE_ID               = X_CUST_SHIP_SITE_ID,
          AP_AR_TERM_ID                   = X_AP_AR_TERM_ID,
          CUST_TRX_TYPE_ID                = X_CUST_TRX_TYPE_ID,
          PROJECT_ID                      = X_PROJECT_ID,
          TASK_ID                         = X_TASK_ID,
          ORGANIZATION_ID                 = X_ORGANIZATION_ID,
          EXPENDITURE_TYPE                = X_EXPENDITURE_TYPE,
          EXPENDITURE_ITEM_DATE           = X_EXPENDITURE_ITEM_DATE,
          TAX_GROUP_ID                    = X_TAX_GROUP_ID,
          TAX_CODE_ID                     = X_TAX_CODE_ID,
          TAX_CLASSIFICATION_CODE         = X_TAX_CLASSIFICATION_CODE,
          TAX_INCLUDED                    = X_TAX_INCLUDED,
          DISTRIBUTION_SET_ID             = X_DISTRIBUTION_SET_ID,
          INV_RULE_ID                     = X_INV_RULE_ID,
          ACCOUNT_RULE_ID                 = X_ACCOUNT_RULE_ID,
          SALESREP_ID                     = X_SALESREP_ID,
          APPROVED_BY                     = X_APPROVED_BY,
          STATUS                          = X_STATUS,
          INDEX_PERIOD_ID                 = X_INDEX_PERIOD_ID,
          INDEX_TERM_INDICATOR            = X_INDEX_TERM_INDICATOR,
          PO_HEADER_ID                    = X_PO_HEADER_ID,
          CUST_PO_NUMBER                  = X_CUST_PO_NUMBER,
          RECEIPT_METHOD_ID               = X_RECEIPT_METHOD_ID,
          VAR_RENT_INV_ID                 = X_VAR_RENT_INV_ID,
          VAR_RENT_TYPE                   = X_VAR_RENT_TYPE,
          CHANGED_FLAG                    = X_CHANGED_FLAG,
          LEGAL_ENTITY_ID                 = L_LEGAL_ENTITY_ID,
          ATTRIBUTE_CATEGORY              = X_ATTRIBUTE_CATEGORY,
          ATTRIBUTE1                      = X_ATTRIBUTE1,
          ATTRIBUTE2                      = X_ATTRIBUTE2,
          ATTRIBUTE3                      = X_ATTRIBUTE3,
          ATTRIBUTE4                      = X_ATTRIBUTE4,
          ATTRIBUTE5                      = X_ATTRIBUTE5,
          ATTRIBUTE6                      = X_ATTRIBUTE6,
          ATTRIBUTE7                      = X_ATTRIBUTE7,
          ATTRIBUTE8                      = X_ATTRIBUTE8,
          ATTRIBUTE9                      = X_ATTRIBUTE9,
          ATTRIBUTE10                     = X_ATTRIBUTE10,
          ATTRIBUTE11                     = X_ATTRIBUTE11,
          ATTRIBUTE12                     = X_ATTRIBUTE12,
          ATTRIBUTE13                     = X_ATTRIBUTE13,
          ATTRIBUTE14                     = X_ATTRIBUTE14,
          ATTRIBUTE15                     = X_ATTRIBUTE15,
          PROJECT_ATTRIBUTE_CATEGORY      = X_PROJECT_ATTRIBUTE_CATEGORY,
          PROJECT_ATTRIBUTE1              = X_PROJECT_ATTRIBUTE1,
          PROJECT_ATTRIBUTE2              = X_PROJECT_ATTRIBUTE2,
          PROJECT_ATTRIBUTE3              = X_PROJECT_ATTRIBUTE3,
          PROJECT_ATTRIBUTE4              = X_PROJECT_ATTRIBUTE4,
          PROJECT_ATTRIBUTE5              = X_PROJECT_ATTRIBUTE5,
          PROJECT_ATTRIBUTE6              = X_PROJECT_ATTRIBUTE6,
          PROJECT_ATTRIBUTE7              = X_PROJECT_ATTRIBUTE7,
          PROJECT_ATTRIBUTE8              = X_PROJECT_ATTRIBUTE8,
          PROJECT_ATTRIBUTE9              = X_PROJECT_ATTRIBUTE9,
          PROJECT_ATTRIBUTE10             = X_PROJECT_ATTRIBUTE10,
          PROJECT_ATTRIBUTE11             = X_PROJECT_ATTRIBUTE11,
          PROJECT_ATTRIBUTE12             = X_PROJECT_ATTRIBUTE12,
          PROJECT_ATTRIBUTE13             = X_PROJECT_ATTRIBUTE13,
          PROJECT_ATTRIBUTE14             = X_PROJECT_ATTRIBUTE14,
          PROJECT_ATTRIBUTE15             = X_PROJECT_ATTRIBUTE15,
          LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY                 = X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN,
          RECOVERABLE_FLAG                = X_RECOVERABLE_FLAG,
          AREA_TYPE_CODE                  = X_AREA_TYPE_CODE,
          AREA                            = X_AREA,
          GROUPING_RULE_ID                = X_GROUPING_RULE_ID,
          TERM_ALTERED_FLAG               = X_TERM_ALTERED_FLAG,
          SOURCE_CODE                     = X_SOURCE_CODE,
          TERM_COMMENTS                   = X_TERM_COMMENTS,
          TERM_TEMPLATE_ID                = X_TERM_TEMPLATE_ID,
          INCLUDE_IN_VAR_RENT             = X_INCLUDE_IN_VAR_RENT,
          UPDATE_NBP_FLAG                 = l_update_nbp_flag,
          RECUR_BB_CALC_DATE              = X_RECUR_BB_CALC_DATE,
          OPEX_AGR_ID                     = X_OPEX_AGR_ID,
          OPEX_RECON_ID                   = X_OPEX_RECON_ID,
          OPEX_TYPE                       = X_OPEX_TYPE
   WHERE  PAYMENT_TERM_ID                 = X_PAYMENT_TERM_ID;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;


   pnp_debug_pkg.debug ('PNT_PAYMENT_TERMS_PKG.UPDATE_ROW (-)');

EXCEPTION
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,'Error while ' || l_context || to_char(sqlcode));
      app_exception.Raise_Exception;

END UPDATE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : DELETE_ROW
-- INVOKED FROM : DELETE_ROW procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_payment_terms with _ALL
--                       table.
-------------------------------------------------------------------------------
PROCEDURE DELETE_ROW (
                       X_PAYMENT_TERM_ID IN NUMBER
                     )
IS
BEGIN

   pnp_debug_pkg.debug ('PNT_PAYMENT_TERMS_PKG.DELETE_ROW (+)');

   DELETE FROM pn_payment_terms_all
   WHERE payment_term_id = x_payment_term_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   pnp_debug_pkg.debug ('PNT_PAYMENT_TERMS_PKG.DELETE_ROW (-)');
END DELETE_ROW;

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_VENDOR_AND_CUST
-- INVOKED FROM :
-- PURPOSE      : UPDATE each item with the new vendor AND vendor site
-- HISTORY      :
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_payment_items with _ALL
--                       table.
-------------------------------------------------------------------------------
PROCEDURE UPDATE_VENDOR_AND_CUST
(
    X_PAYMENT_TERM_ID               IN     NUMBER
   ,X_VENDOR_ID                     IN     NUMBER
   ,X_VENDOR_SITE_ID                IN     NUMBER
   ,X_LAST_UPDATE_DATE              IN     DATE
   ,X_LAST_UPDATED_BY               IN     NUMBER
   ,X_LAST_UPDATE_LOGIN             IN     NUMBER
   ,X_CUSTOMER_ID                   IN     NUMBER
   ,X_CUSTOMER_SITE_USE_ID          IN     NUMBER
   ,X_CUST_SHIP_SITE_ID             IN     NUMBER
)
IS
   CURSOR c1 IS
      SELECT ppi.payment_item_id
      FROM   pn_payment_items_all  ppi
      WHERE  ppi.payment_term_id = X_PAYMENT_TERM_ID
      AND    ppi.transferred_to_ap_flag IS NULL
      AND    ppi.transferred_to_ar_flag IS NULL
      FOR UPDATE OF ppi.payment_item_id NOWAIT;

BEGIN
   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.UPDATE_VENDOR_AND_CUST (+)');
   -- UPDATE each item with the new vendor AND vendor site
   FOR eachItem IN c1 LOOP

      UPDATE pn_payment_items_all
      SET    VENDOR_ID                       = X_VENDOR_ID
            ,VENDOR_SITE_ID                  = X_VENDOR_SITE_ID
            ,LAST_UPDATE_DATE                = X_LAST_UPDATE_DATE
            ,LAST_UPDATED_BY                 = X_LAST_UPDATED_BY
            ,LAST_UPDATE_LOGIN               = X_LAST_UPDATE_LOGIN
            ,CUSTOMER_ID                     = X_CUSTOMER_ID
            ,CUSTOMER_SITE_USE_ID            = X_CUSTOMER_SITE_USE_ID
            ,CUST_SHIP_SITE_ID               = X_CUST_SHIP_SITE_ID
      WHERE  payment_item_id = eachItem.payment_item_id;

   END LOOP;

   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.UPDATE_VENDOR_AND_CUST (-)');
END UPDATE_VENDOR_AND_CUST;

-------------------------------------------------------------------------------
-- PROCEDURE  : CHECK_APPROVED_SCHEDULE_EXISTS
-- DESCRIPTION: This PROCEDURE will check IF an approved payment
--              schedule exists BETWEEN the given start AND end
--              date OF the payment term we are trying to create.
-- HISTORY    :
-- 23-SEP-03  ATUPPAD  o Changed the procedure to handle the One Time terms as in
--                       this case start and end dates are the same.
--                       Also, the query now executes through Cursor.
--                       Also, optmized the query by not joining with tables
--                       pn_payment_items and pn_leases. (bug#3140238)
-- 05-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_leases with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE Check_Approved_Schedule_Exists (
                       x_return_status                 IN OUT NOCOPY VARCHAR2
                      ,x_lease_id                      IN     NUMBER
                      ,x_start_date                    IN     DATE
                      ,x_end_date                      IN     DATE
                      ,x_schedule_day                  IN     NUMBER
                     )
IS
   l_leaseNumber                   VARCHAR2(30) := NULL;
   l_startDate                     DATE         := NULL;
   l_endDate                       DATE         := NULL;

   -- Get the details of Approved Schedules
   CURSOR c_chk_app_sch IS
   SELECT lease_num
   FROM   pn_leases_all
   WHERE  lease_id = x_lease_id
   AND    EXISTS
         (
             SELECT pps.lease_id
             FROM   pn_payment_schedules_all pps
             WHERE  pps.lease_id = x_lease_id
             AND    pps.payment_status_lookup_code = 'APPROVED'
             AND    TO_CHAR(pps.schedule_date, 'DD') = x_schedule_day
             AND    pps.schedule_date BETWEEN l_startDate AND l_endDate
          );

BEGIN
   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.CHECK_APPROVED_SCHEDULE_EXISTS (+)');

   SELECT TRUNC(x_start_date, 'MM')
         ,LAST_DAY(x_end_date)
   INTO   l_startDate
         ,l_endDate
   FROM   DUAL;

   OPEN c_chk_app_sch;
   FETCH c_chk_app_sch INTO l_leaseNumber;
   IF (c_chk_app_sch%NOTFOUND) THEN
     CLOSE c_chk_app_sch;
     RETURN;
   END IF;

   CLOSE c_chk_app_sch;

   x_return_status := 'E';
   fnd_message.set_name('PN','PN_LEASES_APPROVED_PMT_EXISTS');
   fnd_message.set_token('LEASE_NUMBER', l_leaseNumber);
   fnd_message.set_token('START_DATE',   l_startDate);
   fnd_message.set_token('END_DATE',     l_endDate);

   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.CHECK_APPROVED_SCHEDULE_EXISTS (-) RetStat: '||x_return_status);
END Check_Approved_Schedule_Exists;

--------------------------------------------------------------------------------
-- PROCEDURE : UPDATE_PNT_ITEMS_AMT
-- PURPOSE   : updates scheduled items FOR non-normalized payment terms
-- OTHER REF : bug ID # 1845607
-- SCOPE     : local / private
-- NOTE      : Logic FOR PROCEDURE UPDATE_PNT_ITEMS_AMT:
--             FOR each payment item with status 'draft'
--               - do UPDATE OF estimated amount
--               - IF the actual amount equals the old estimated amount
--                 (which means that it hasn't been changed)
--                 THEN set actual amount equal to new estimated amount
--                 taking INTO account proration rules
--
-- HISTORY:
-- 28-DEC-01  FTANUDJA  o Created
-- 11-OCT-04  STripathi o Fixed for BUG# 3942284. Changed paramater p_freq
--                        to p_freq_code. For OT terms, update amount with
--                        the p_new_est_amt.
-- 05-JUL-05  sdmahesh  o Bug 4284035 - Replaced pn_payment_items,
--                        pn_payment_schedules, pn_leases with _ALL table.
-- 24-NOV-05  Kiran     o rounding for amounts done based on currency precision
--------------------------------------------------------------------------------

PROCEDURE UPDATE_PNT_ITEMS_AMT (
                       p_pnt_term_id                   IN pn_payment_items.payment_term_id%TYPE,
                       p_old_est_amt                   IN pn_payment_items.estimated_amount%TYPE,
                       p_new_est_amt                   IN pn_payment_items.estimated_amount%TYPE,
                       p_lease_id                      IN pn_payment_terms.lease_id%TYPE,
                       p_trm_str_dt                    IN DATE,
                       p_trm_end_dt                    IN DATE,
                       p_freq_code                     IN pn_payment_terms.frequency_code%TYPE
                     )
IS

   l_prorate_rule        NUMBER;
   l_act_amt             NUMBER;
   l_est_amt             NUMBER;
   l_sch_str_dt          DATE;
   l_sch_end_dt          DATE;
   l_last_sch_dt         DATE;
   l_context             VARCHAR2(240);
   l_first_last          VARCHAR2(1);
   l_freq                NUMBER;

   CURSOR pnt_cursor IS
      SELECT   ppi.payment_item_id
             , pps.payment_schedule_id
             , ppi.actual_amount
             , ppi.estimated_amount
             , pps.schedule_date
             , ppi.currency_code
      FROM   pn_payment_items_all ppi,
             pn_payment_schedules_all pps
      WHERE  ppi.payment_term_id = p_pnt_term_id
      AND    ppi.payment_item_type_lookup_code = 'CASH'
      AND    pps.payment_schedule_id = ppi.payment_schedule_id
      AND    pps.payment_status_lookup_code = 'DRAFT';

   l_precision     NUMBER;
   l_ext_precision NUMBER;
   l_min_acct_unit NUMBER;
   l_first         BOOLEAN;
BEGIN

   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.UPDATE_PNT_ITEMS_AMT (+) TermId: '
                       ||p_pnt_term_id||', OldEstAmt: '||p_old_est_amt
                       ||', NewEstAmt: '||p_new_est_amt||', Freq: '||p_freq_code);
   l_context:= 'Updating for OneTime term';

   IF p_freq_code = 'OT' THEN
      l_est_amt := p_new_est_amt;
      l_act_amt := p_new_est_amt;

      l_first := TRUE;

      FOR pnt_rec IN pnt_cursor LOOP
         IF l_first THEN
            fnd_currency.get_info ( currency_code => pnt_rec.currency_code
                                   ,precision     => l_precision
                                   ,ext_precision => l_ext_precision
                                   ,min_acct_unit => l_min_acct_unit);
            l_first := FALSE;
         END IF;

         UPDATE pn_payment_items_all
         SET    estimated_amount = ROUND(l_est_amt, l_precision)
               ,actual_amount = ROUND(l_act_amt, l_precision)
               ,export_currency_amount = ROUND(l_act_amt, l_precision)
               ,last_update_date = SYSDATE
               ,last_updated_by  = NVL(fnd_profile.value('USER_ID'),0)
               ,last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
         WHERE  payment_item_id = pnt_rec.payment_item_id;

         EXIT;
      END LOOP;

   ELSE

      l_context:= 'getting proration rule';
      l_freq := pn_schedules_items.get_frequency(p_freq_code);

      SELECT payment_term_proration_rule
      INTO   l_prorate_rule
      FROM   pn_leases_all
      WHERE  lease_id = p_lease_id;

      l_context:= 'entering UPDATE loop';

      l_first := TRUE;

      FOR pnt_rec IN pnt_cursor LOOP

         /* get currency info the first time */
         IF l_first THEN
            fnd_currency.get_info ( currency_code => pnt_rec.currency_code
                                   ,precision     => l_precision
                                   ,ext_precision => l_ext_precision
                                   ,min_acct_unit => l_min_acct_unit);
            l_first := FALSE;
         END IF;

         /** pro-rating part*/

         l_sch_str_dt := TO_DATE('01/'||TO_CHAR(pnt_rec.schedule_date,'MM/YYYY'),'DD/MM/YYYY');
         -- the above copied FROM FIRST_DAY in PNSCHITB.pls as OF 01/02/2002

         l_sch_end_dt := least(LAST_DAY(p_trm_end_dt),
                               LAST_DAY(ADD_MONTHS(l_sch_str_dt, (l_freq-1))));

         IF l_sch_end_dt = LAST_DAY(p_trm_end_dt) THEN

            l_last_sch_dt := PN_SCHEDULES_ITEMS.FIRST_DAY(ADD_MONTHS(p_trm_end_dt,((l_freq -1) * -1)));

         END IF;

         /* We would need to do the pro-ration only IF the schedule IS the first or the last
            schedule */

         l_context:= 'taking into account various dates';

         IF to_char(pnt_rec.schedule_date,'MM/YYYY') = to_char(p_trm_str_dt,'MM/YYYY') OR
            to_char(pnt_rec.schedule_date,'MM/YYYY') = to_char(l_last_sch_dt,'MM/YYYY') THEN

            PN_SCHEDULES_ITEMS.GET_AMOUNT(
                                      l_sch_str_dt,
                                      l_sch_end_dt,
                                      p_trm_str_dt,
                                      p_trm_end_dt,
                                      pnt_rec.actual_amount,
                                      p_new_est_amt,
                                      l_freq,
                                      TO_CHAR(l_prorate_rule),
                                      l_act_amt,
                                      l_est_amt
                                   );
            pnp_debug_pkg.debug('Get Amt; SchStrDt: '||l_sch_str_dt||', SchEndDt: '||l_sch_end_dt
                                ||', ActAmt: '||l_act_amt||', EstAmt: '||l_est_amt);

            l_first_last := 'Y';

         ELSE

            l_est_amt := p_new_est_amt;
            l_first_last := 'N';

         END IF;

         l_context := 'figuring out NOCOPY amounts';

         IF (l_first_last = 'Y' AND nvl(pnt_rec.actual_amount,0) <> nvl(pnt_rec.estimated_amount,0)) OR
            (l_first_last = 'N' AND nvl(pnt_rec.actual_amount,0) <> nvl(p_old_est_amt,0)) THEN

            l_act_amt := pnt_rec.actual_amount;

         ELSE

            l_act_amt := l_est_amt;

         END IF;

         /** updates estimated amount AND actual amount accordingly in the items table */
         l_context := 'updates items table';

         UPDATE pn_payment_items_all
         SET    estimated_amount = ROUND(l_est_amt, l_precision)
               ,actual_amount = ROUND(l_act_amt, l_precision)
               ,export_currency_amount = ROUND(l_act_amt, l_precision)
               ,last_update_date = SYSDATE
               ,last_updated_by  = NVL(fnd_profile.value('USER_ID'),0)
               ,last_update_login= NVL(fnd_profile.value('LOGIN_ID'),0)
         WHERE  payment_item_id = pnt_rec.payment_item_id;

      END LOOP;

   END IF; -- p_freq_code = 'OT'

   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.UPDATE_PNT_ITEMS_AMT (-)');
EXCEPTION
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,'Error while ' || l_context || TO_CHAR(sqlcode));
      app_exception.Raise_Exception;

   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.UPDATE_PNT_ITEMS_AMT (-)');
END UPDATE_PNT_ITEMS_AMT;

-------------------------------------------------------------------------------
-- PROCEDURE   : UPDATE_PNT_ITEMS_RATE
-- PURPOSE     : cascade changed rate FROM term level to item level
-- SCOPE       : local / private
-- DESCRIPTION : The logic IS as follows:
--               o Given a particular payment term
--               o UPDATE items in schedules still in DRAFT
--               o Implicit: item IS not exported
--               o Implicit: term has been finalized
-- HISTORY:
-- 15-MAY-02  ftanudja  o Created
-- 05-JUL-05  sdmahesh  o Bug 4284035 - Replaced pn_payment_items with _ALL
--                        table.
-------------------------------------------------------------------------------

PROCEDURE UPDATE_PNT_ITEMS_RATE(p_pnt_term_id pn_payment_items.payment_item_id%TYPE,
                                p_new_rate    pn_payment_items.rate%TYPE)
IS
   l_context VARCHAR2(240);

   CURSOR pnt_cursor IS
      SELECT payment_item_id
      FROM   pn_payment_items_all ppi
      WHERE  ppi.payment_term_id = p_pnt_term_id
      AND    ppi.export_to_ap_flag IS NULL
      AND    ppi.export_to_ar_flag IS NULL;

BEGIN

   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.UPDATE_PNT_ITEMS_RATE (+)');
   l_context := 'opening payment rate cursor';

   FOR pnt_rec IN pnt_cursor LOOP

      l_context := 'updating payment item ID: '||pnt_rec.payment_item_id||' with new rate';
      UPDATE pn_payment_items_all
      SET    rate = p_new_rate
      WHERE  payment_item_id = pnt_rec.payment_item_id;

   END LOOP;

   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.UPDATE_PNT_ITEMS_RATE (-)');
EXCEPTION
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,'Error while ' || l_context || TO_CHAR(sqlcode));
      app_exception.Raise_Exception;
   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.UPDATE_PNT_ITEMS_RATE (-)');
END UPDATE_PNT_ITEMS_RATE;

-------------------------------------------------------------------------------
-- PROCEDURE  : create_hist_corr_upd
-- DESCRIPTION: This procedure creates history for the term record when the
--              term record is 'corrected' or 'updated' in the Leases UI.
-- HISTORY
-- 15-OCT-04  Mrinal   o Created.
-- 15-JUL-05  ftanudja o R12 changes - #4495054, #4497295
-- 25-JUL-05  sdmahesh o Bug 4284035 - Replaced pn_payment_terms with _ALL
--                       table.
-------------------------------------------------------------------------------
PROCEDURE create_hist_corr_upd(p_term_id       IN NUMBER,
                               p_dist_changed  IN NUMBER,
                               p_hist_dist_tab IN dist_type,
                               p_change_mode   IN VARCHAR2,
                               p_eff_str_dt    IN DATE,
                               p_eff_end_dt    IN DATE) IS

   term_rec                PN_PAYMENT_TERMS_ALL%ROWTYPE;
   n                       NUMBER(1);
   l_dist_change_id        NUMBER(15);
   l_prev_term_hist_id     NUMBER(15);
   l_new_term_id           NUMBER(15);
   l_new_dist_id           NUMBER(15);
   l_term_id               NUMBER(15);
   l_dist_id               NUMBER(15);
   l_str_dt                DATE;
   l_end_dt                DATE;
   l_last_update_date      DATE;
   l_last_updated_by       NUMBER;
   l_creation_date         DATE;
   l_created_by            NUMBER;
   l_last_update_login     NUMBER;
   l_insert_dist_hist      VARCHAR2(1);
   l_adj_type_code         pn_payment_terms_history.adjustment_type_code%TYPE;
   l_term_comments         pn_payment_terms_history.term_comments%TYPE;
   l_changed_flag          pn_payment_terms.changed_flag%TYPE;

   CURSOR get_term_cur(p_term_id IN NUMBER) IS
      SELECT *
      FROM   pn_payment_terms_all
      WHERE  payment_term_id = p_term_id;

   CURSOR get_dist_cur(p_term_id IN NUMBER) IS
      SELECT *
      FROM   pn_distributions_all
      WHERE  payment_term_id = p_term_id;

   CURSOR get_max_dist_change_id_cur(p_term_id IN NUMBER) IS
      SELECT MAX(pdh.distribution_change_id)
      FROM   pn_distributions_history pdh,
             pn_distributions_all pd
      WHERE  pdh.distribution_id = pd.distribution_id
      AND    pd.payment_term_id = p_term_id;

   CURSOR get_max_term_hist_id_cur(p_term_id IN NUMBER) IS
      SELECT MAX(term_history_id)
      FROM   pn_payment_terms_history
      WHERE  payment_term_id = p_term_id;
BEGIN

   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.create_hist_corr_upd (+)');
   pnp_debug_pkg.debug('create_hist_corr_upd - IN : p_term_id             :'||p_term_id);
   pnp_debug_pkg.debug('create_hist_corr_upd - IN : p_dist_changed        :'||p_dist_changed);
   pnp_debug_pkg.debug('create_hist_corr_upd - IN : p_hist_dist_tab.count :'||p_hist_dist_tab.count);
   pnp_debug_pkg.debug('create_hist_corr_upd - IN : p_change_mode         :'||p_change_mode);
   pnp_debug_pkg.debug('create_hist_corr_upd - IN : p_eff_str_dt          :'||p_eff_str_dt);
   pnp_debug_pkg.debug('create_hist_corr_upd - IN : p_eff_end_dt          :'||p_eff_end_dt);

   l_dist_change_id      := NULL;
   l_prev_term_hist_id   := NULL;
   l_new_term_id         := NULL;
   l_new_dist_id         := NULL;
   l_term_id             := NULL;
   l_dist_id             := NULL;
   l_adj_type_code       := NULL;
   l_changed_flag        := NULL;

   OPEN get_term_cur(p_term_id);
   FETCH get_term_cur INTO term_rec;
   CLOSE get_term_cur;

   IF pn_r12_util_pkg.is_r12 THEN
      term_rec.tax_group_id := null;
      term_rec.tax_code_id := null;
      tlinfo.tax_group_id := null;
      tlinfo.tax_code_id := null;

   ELSE
      term_rec.tax_classification_code := null;
      tlinfo.tax_classification_code := null;
   END IF;

   IF (NVL(term_rec.location_id, -9999)           <> NVL(tlinfo.location_id, -9999) OR
       term_rec.start_date                        <> tlinfo.start_date OR
       term_rec.end_date                          <> tlinfo.end_date OR
       NVL(term_rec.estimated_amount, -9999)      <> NVL(tlinfo.estimated_amount, -9999) OR
       NVL(term_rec.actual_amount, -9999)         <> NVL(tlinfo.actual_amount, -9999) OR
       NVL(term_rec.vendor_id, -9999)             <> NVL(tlinfo.vendor_id, -9999) OR
       NVL(term_rec.vendor_site_id, -9999)        <> NVL(tlinfo.vendor_site_id, -9999) OR
       NVL(term_rec.ap_ar_term_id, -9999)         <> NVL(tlinfo.ap_ar_term_id, -9999) OR
       NVL(term_rec.tax_group_id, -9999)          <> NVL(tlinfo.tax_group_id, -9999) OR
       NVL(term_rec.tax_code_id, -9999)           <> NVL(tlinfo.tax_code_id, -9999) OR
       NVL(term_rec.tax_classification_code, 'X') <> NVL(tlinfo.tax_classification_code, 'X') OR
       NVL(term_rec.tax_included, 'N')            <> NVL(tlinfo.tax_included, 'N') OR
       NVL(term_rec.distribution_set_id, -9999)   <> NVL(tlinfo.distribution_set_id, -9999) OR
       NVL(term_rec.project_id, -9999)            <> NVL(tlinfo.project_id, -9999) OR
       NVL(term_rec.task_id, -9999)               <> NVL(tlinfo.task_id, -9999) OR
       term_rec.expenditure_type                  <> tlinfo.expenditure_type OR
       term_rec.expenditure_item_date             <> tlinfo.expenditure_item_date OR
       NVL(term_rec.organization_id, -9999)       <> NVL(tlinfo.organization_id, -9999) OR
       NVL(term_rec.customer_id, -9999)           <> NVL(tlinfo.customer_id, -9999) OR
       NVL(term_rec.customer_site_use_id, -9999)  <> NVL(tlinfo.customer_site_use_id, -9999) OR
       NVL(term_rec.cust_ship_site_id, -9999)     <> NVL(tlinfo.cust_ship_site_id, -9999) OR
       NVL(term_rec.cust_trx_type_id, -9999)      <> NVL(tlinfo.cust_trx_type_id, -9999) OR
       NVL(term_rec.receipt_method_id, -9999)     <> NVL(tlinfo.receipt_method_id, -9999) OR
       NVL(term_rec.cust_po_number, -9999)        <> NVL(tlinfo.cust_po_number, -9999) OR
       NVL(term_rec.inv_rule_id, -9999)           <> NVL(tlinfo.inv_rule_id, -9999) OR
       NVL(term_rec.account_rule_id, -9999)       <> NVL(tlinfo.account_rule_id, -9999) OR
       NVL(term_rec.salesrep_id, -9999)           <> NVL(tlinfo.salesrep_id, -9999)) OR
      NVL(p_dist_changed, 0) > 0
   THEN

      pnp_debug_pkg.debug('create_hist_corr_upd : p_dist_changed          :'||p_dist_changed);
      pnp_debug_pkg.debug('create_hist_corr_upd : term_altered_flag       :'||tlinfo.term_altered_flag);

      IF NVL(p_dist_changed, 0) >= 0 THEN

         IF NVL(p_hist_dist_tab.count,0) <> 0 AND
            NVL(tlinfo.term_altered_flag, 'N') = 'N' THEN

            SELECT pn_distributions_history_s1.NEXTVAL
            INTO   l_dist_change_id
            FROM   DUAL;

            pnp_debug_pkg.debug('create_hist_corr_upd : l_dist_change_id        :'||l_dist_change_id);

            FOR i in 1..p_hist_dist_tab.count LOOP

               pnp_debug_pkg.debug('create_hist_corr_upd : Inserting in Dist. Hist. for very first time');

               INSERT INTO pn_distributions_history
               (
                   DISTRIBUTION_HISTORY_ID
                  ,LAST_UPDATE_DATE
                  ,LAST_UPDATED_BY
                  ,CREATION_DATE
                  ,CREATED_BY
                  ,LAST_UPDATE_LOGIN
                  ,DISTRIBUTION_CHANGE_ID
                  ,DISTRIBUTION_ID
                  ,ACCOUNT_ID
                  ,ACCOUNT_CLASS
                  ,PERCENTAGE
                  ,LINE_NUMBER
                  ,ATTRIBUTE_CATEGORY
                  ,ATTRIBUTE1
                  ,ATTRIBUTE2
                  ,ATTRIBUTE3
                  ,ATTRIBUTE4
                  ,ATTRIBUTE5
                  ,ATTRIBUTE6
                  ,ATTRIBUTE7
                  ,ATTRIBUTE8
                  ,ATTRIBUTE9
                  ,ATTRIBUTE10
                  ,ATTRIBUTE11
                  ,ATTRIBUTE12
                  ,ATTRIBUTE13
                  ,ATTRIBUTE14
                  ,ATTRIBUTE15)
               VALUES
               (
                    pn_distributions_history_s.NEXTVAL
                   ,SYSDATE
                   ,FND_GLOBAL.USER_ID
                   ,SYSDATE
                   ,FND_GLOBAL.USER_ID
                   ,FND_GLOBAL.LOGIN_ID
                   ,l_dist_change_id
                   ,p_hist_dist_tab(i).DISTRIBUTION_ID
                   ,p_hist_dist_tab(i).ACCOUNT_ID
                   ,p_hist_dist_tab(i).ACCOUNT_CLASS
                   ,p_hist_dist_tab(i).PERCENTAGE
                   ,p_hist_dist_tab(i).LINE_NUMBER
                   ,p_hist_dist_tab(i).ATTRIBUTE_CATEGORY
                   ,p_hist_dist_tab(i).ATTRIBUTE1
                   ,p_hist_dist_tab(i).ATTRIBUTE2
                   ,p_hist_dist_tab(i).ATTRIBUTE3
                   ,p_hist_dist_tab(i).ATTRIBUTE4
                   ,p_hist_dist_tab(i).ATTRIBUTE5
                   ,p_hist_dist_tab(i).ATTRIBUTE6
                   ,p_hist_dist_tab(i).ATTRIBUTE7
                   ,p_hist_dist_tab(i).ATTRIBUTE8
                   ,p_hist_dist_tab(i).ATTRIBUTE9
                   ,p_hist_dist_tab(i).ATTRIBUTE10
                   ,p_hist_dist_tab(i).ATTRIBUTE11
                   ,p_hist_dist_tab(i).ATTRIBUTE12
                   ,p_hist_dist_tab(i).ATTRIBUTE13
                   ,p_hist_dist_tab(i).ATTRIBUTE14
                   ,p_hist_dist_tab(i).ATTRIBUTE15
               );
            END LOOP;

            pnp_debug_pkg.debug('create_hist_corr_upd : Inserting in Term Hist. for very first time');

            INSERT INTO pn_payment_terms_history
            (
                TERM_HISTORY_ID
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_LOGIN
               ,PAYMENT_TERM_ID
               ,DISTRIBUTION_CHANGE_ID
               ,PREV_TERM_HISTORY_ID
               ,ADJUSTMENT_TYPE_CODE
               ,TOTAL_ADJ_AMOUNT
               ,PAYMENT_PURPOSE_CODE
               ,PAYMENT_TERM_TYPE_CODE
               ,FREQUENCY_CODE
               ,LEASE_ID
               ,LEASE_CHANGE_ID
               ,START_DATE
               ,END_DATE
               ,VENDOR_ID
               ,VENDOR_SITE_ID
               ,TARGET_DATE
               ,ACTUAL_AMOUNT
               ,ESTIMATED_AMOUNT
               ,SET_OF_BOOKS_ID
               ,CURRENCY_CODE
               ,RATE
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,CUSTOMER_ID
               ,CUSTOMER_SITE_USE_ID
               ,NORMALIZE
               ,LOCATION_ID
               ,SCHEDULE_DAY
               ,CUST_SHIP_SITE_ID
               ,AP_AR_TERM_ID
               ,CUST_TRX_TYPE_ID
               ,PROJECT_ID
               ,TASK_ID
               ,ORGANIZATION_ID
               ,EXPENDITURE_TYPE
               ,EXPENDITURE_ITEM_DATE
               ,TAX_GROUP_ID
               ,TAX_CODE_ID
               ,TAX_CLASSIFICATION_CODE
               ,TAX_INCLUDED
               ,DISTRIBUTION_SET_ID
               ,INV_RULE_ID
               ,ACCOUNT_RULE_ID
               ,SALESREP_ID
               ,APPROVED_BY
               ,STATUS
               ,INDEX_PERIOD_ID
               ,INDEX_TERM_INDICATOR
               ,PO_HEADER_ID
               ,CUST_PO_NUMBER
               ,RECEIPT_METHOD_ID
               ,LEGAL_ENTITY_ID
               ,PROJECT_ATTRIBUTE_CATEGORY
               ,PROJECT_ATTRIBUTE1
               ,PROJECT_ATTRIBUTE2
               ,PROJECT_ATTRIBUTE3
               ,PROJECT_ATTRIBUTE4
               ,PROJECT_ATTRIBUTE5
               ,PROJECT_ATTRIBUTE6
               ,PROJECT_ATTRIBUTE7
               ,PROJECT_ATTRIBUTE8
               ,PROJECT_ATTRIBUTE9
               ,PROJECT_ATTRIBUTE10
               ,PROJECT_ATTRIBUTE11
               ,PROJECT_ATTRIBUTE12
               ,PROJECT_ATTRIBUTE13
               ,PROJECT_ATTRIBUTE14
               ,PROJECT_ATTRIBUTE15
               ,VAR_RENT_INV_ID
               ,VAR_RENT_TYPE
               ,CHANGED_FLAG
               ,NORM_START_DATE
               ,TERM_TEMPLATE_ID
               ,EVENT_TYPE_CODE
               ,LEASE_STATUS
               ,NORM_END_DATE
               ,RECOVERABLE_FLAG
               ,PERIOD_BILLREC_ID
               ,AMOUNT_TYPE
               ,REC_AGR_LINE_ID
               ,GROUPING_RULE_ID
               ,AREA_TYPE_CODE
               ,AREA
               ,TERM_COMMENTS)
            VALUES
               (PN_PAYMENT_TERMS_HISTORY_S.NEXTVAL
               ,SYSDATE
               ,FND_GLOBAL.USER_ID
               ,SYSDATE
               ,FND_GLOBAL.USER_ID
               ,FND_GLOBAL.LOGIN_ID
               ,tlinfo.PAYMENT_TERM_ID
               ,l_dist_change_id
               ,NULL                     -- PREV_TERM_HISTORY_ID
               ,NULL                     -- ADJUSTMENT_TYPE_CODE
               ,NULL                     -- TOTAL_ADJ_AMOUNT
               ,tlinfo.PAYMENT_PURPOSE_CODE
               ,tlinfo.PAYMENT_TERM_TYPE_CODE
               ,tlinfo.FREQUENCY_CODE
               ,tlinfo.LEASE_ID
               ,tlinfo.LEASE_CHANGE_ID
               ,tlinfo.START_DATE
               ,tlinfo.END_DATE
               ,tlinfo.VENDOR_ID
               ,tlinfo.VENDOR_SITE_ID
               ,tlinfo.TARGET_DATE
               ,tlinfo.ACTUAL_AMOUNT
               ,tlinfo.ESTIMATED_AMOUNT
               ,tlinfo.SET_OF_BOOKS_ID
               ,tlinfo.CURRENCY_CODE
               ,tlinfo.RATE
               ,tlinfo.ATTRIBUTE_CATEGORY
               ,tlinfo.ATTRIBUTE1
               ,tlinfo.ATTRIBUTE2
               ,tlinfo.ATTRIBUTE3
               ,tlinfo.ATTRIBUTE4
               ,tlinfo.ATTRIBUTE5
               ,tlinfo.ATTRIBUTE6
               ,tlinfo.ATTRIBUTE7
               ,tlinfo.ATTRIBUTE8
               ,tlinfo.ATTRIBUTE9
               ,tlinfo.ATTRIBUTE10
               ,tlinfo.ATTRIBUTE11
               ,tlinfo.ATTRIBUTE12
               ,tlinfo.ATTRIBUTE13
               ,tlinfo.ATTRIBUTE14
               ,tlinfo.ATTRIBUTE15
               ,tlinfo.CUSTOMER_ID
               ,tlinfo.CUSTOMER_SITE_USE_ID
               ,tlinfo.NORMALIZE
               ,tlinfo.LOCATION_ID
               ,tlinfo.SCHEDULE_DAY
               ,tlinfo.CUST_SHIP_SITE_ID
               ,tlinfo.AP_AR_TERM_ID
               ,tlinfo.CUST_TRX_TYPE_ID
               ,tlinfo.PROJECT_ID
               ,tlinfo.TASK_ID
               ,tlinfo.ORGANIZATION_ID
               ,tlinfo.EXPENDITURE_TYPE
               ,tlinfo.EXPENDITURE_ITEM_DATE
               ,tlinfo.TAX_GROUP_ID
               ,tlinfo.TAX_CODE_ID
               ,tlinfo.TAX_CLASSIFICATION_CODE
               ,tlinfo.TAX_INCLUDED
               ,tlinfo.DISTRIBUTION_SET_ID
               ,tlinfo.INV_RULE_ID
               ,tlinfo.ACCOUNT_RULE_ID
               ,tlinfo.SALESREP_ID
               ,tlinfo.APPROVED_BY
               ,tlinfo.STATUS
               ,tlinfo.INDEX_PERIOD_ID
               ,tlinfo.INDEX_TERM_INDICATOR
               ,tlinfo.PO_HEADER_ID
               ,tlinfo.CUST_PO_NUMBER
               ,tlinfo.RECEIPT_METHOD_ID
               ,tlinfo.LEGAL_ENTITY_ID
               ,tlinfo.PROJECT_ATTRIBUTE_CATEGORY
               ,tlinfo.PROJECT_ATTRIBUTE1
               ,tlinfo.PROJECT_ATTRIBUTE2
               ,tlinfo.PROJECT_ATTRIBUTE3
               ,tlinfo.PROJECT_ATTRIBUTE4
               ,tlinfo.PROJECT_ATTRIBUTE5
               ,tlinfo.PROJECT_ATTRIBUTE6
               ,tlinfo.PROJECT_ATTRIBUTE7
               ,tlinfo.PROJECT_ATTRIBUTE8
               ,tlinfo.PROJECT_ATTRIBUTE9
               ,tlinfo.PROJECT_ATTRIBUTE10
               ,tlinfo.PROJECT_ATTRIBUTE11
               ,tlinfo.PROJECT_ATTRIBUTE12
               ,tlinfo.PROJECT_ATTRIBUTE13
               ,tlinfo.PROJECT_ATTRIBUTE14
               ,tlinfo.PROJECT_ATTRIBUTE15
               ,tlinfo.VAR_RENT_INV_ID
               ,tlinfo.VAR_RENT_TYPE
               ,tlinfo.CHANGED_FLAG
               ,tlinfo.NORM_START_DATE
               ,tlinfo.TERM_TEMPLATE_ID
               ,tlinfo.EVENT_TYPE_CODE
               ,tlinfo.LEASE_STATUS
               ,tlinfo.NORM_END_DATE
               ,tlinfo.RECOVERABLE_FLAG
               ,tlinfo.PERIOD_BILLREC_ID
               ,tlinfo.AMOUNT_TYPE
               ,tlinfo.REC_AGR_LINE_ID
               ,tlinfo.GROUPING_RULE_ID
               ,tlinfo.AREA_TYPE_CODE
               ,tlinfo.AREA
               ,NULL);

            pnp_debug_pkg.debug('create_hist_corr_upd : Updating Term Altered Flag in pn_payment_terms_all');

            UPDATE pn_payment_terms_all
            SET    term_altered_flag = 'Y'
            WHERE  payment_term_id = p_term_id;
         END IF;

         IF NVL(p_dist_changed, 0) > 0 AND
            p_change_mode = 'CORRECT' THEN

            SELECT pn_distributions_history_s1.NEXTVAL
            INTO   l_dist_change_id
            FROM   DUAL;

            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- l_dist_change_id : '||l_dist_change_id);

            FOR dist_rec IN get_dist_cur(p_term_id) LOOP

               pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- Inserting into Dist. Hist.');

               INSERT INTO pn_distributions_history
               (
                   DISTRIBUTION_HISTORY_ID
                  ,LAST_UPDATE_DATE
                  ,LAST_UPDATED_BY
                  ,CREATION_DATE
                  ,CREATED_BY
                  ,LAST_UPDATE_LOGIN
                  ,DISTRIBUTION_CHANGE_ID
                  ,DISTRIBUTION_ID
                  ,ACCOUNT_ID
                  ,ACCOUNT_CLASS
                  ,PERCENTAGE
                  ,LINE_NUMBER
                  ,ATTRIBUTE_CATEGORY
                  ,ATTRIBUTE1
                  ,ATTRIBUTE2
                  ,ATTRIBUTE3
                  ,ATTRIBUTE4
                  ,ATTRIBUTE5
                  ,ATTRIBUTE6
                  ,ATTRIBUTE7
                  ,ATTRIBUTE8
                  ,ATTRIBUTE9
                  ,ATTRIBUTE10
                  ,ATTRIBUTE11
                  ,ATTRIBUTE12
                  ,ATTRIBUTE13
                  ,ATTRIBUTE14
                  ,ATTRIBUTE15)
               VALUES
               (
                   pn_distributions_history_s.NEXTVAL
                  ,SYSDATE
                  ,FND_GLOBAL.USER_ID
                  ,SYSDATE
                  ,FND_GLOBAL.USER_ID
                  ,FND_GLOBAL.LOGIN_ID
                  ,l_dist_change_id
                  ,dist_rec.DISTRIBUTION_ID
                  ,dist_rec.ACCOUNT_ID
                  ,dist_rec.ACCOUNT_CLASS
                  ,dist_rec.PERCENTAGE
                  ,dist_rec.LINE_NUMBER
                  ,dist_rec.ATTRIBUTE_CATEGORY
                  ,dist_rec.ATTRIBUTE1
                  ,dist_rec.ATTRIBUTE2
                  ,dist_rec.ATTRIBUTE3
                  ,dist_rec.ATTRIBUTE4
                  ,dist_rec.ATTRIBUTE5
                  ,dist_rec.ATTRIBUTE6
                  ,dist_rec.ATTRIBUTE7
                  ,dist_rec.ATTRIBUTE8
                  ,dist_rec.ATTRIBUTE9
                  ,dist_rec.ATTRIBUTE10
                  ,dist_rec.ATTRIBUTE11
                  ,dist_rec.ATTRIBUTE12
                  ,dist_rec.ATTRIBUTE13
                  ,dist_rec.ATTRIBUTE14
                  ,dist_rec.ATTRIBUTE15);

            END LOOP;
         END IF;
      END IF;

      OPEN get_max_dist_change_id_cur(p_term_id);
      FETCH get_max_dist_change_id_cur INTO l_dist_change_id;
      CLOSE get_max_dist_change_id_cur;

      pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- get_max_dist_change_id : '||l_dist_change_id);

      OPEN get_max_term_hist_id_cur(p_term_id);
      FETCH get_max_term_hist_id_cur INTO l_prev_term_hist_id;
      CLOSE get_max_term_hist_id_cur;

      pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- get_max_term_hist_id : '||l_prev_term_hist_id);

      IF p_change_mode = 'CORRECT' THEN

         IF (term_rec.start_date > tlinfo.start_date AND
             term_rec.end_date = tlinfo.end_date AND
             term_rec.actual_amount = tlinfo.actual_amount) OR
            (term_rec.start_date = tlinfo.start_date AND
             term_rec.end_date < tlinfo.end_date AND
             term_rec.actual_amount = tlinfo.actual_amount) OR
            (term_rec.start_date > tlinfo.start_date AND
             term_rec.end_date < tlinfo.end_date AND
             term_rec.actual_amount = tlinfo.actual_amount) THEN

            l_adj_type_code := 'ADJ-PCON';

         ELSIF (term_rec.start_date < tlinfo.start_date AND
             term_rec.end_date = tlinfo.end_date AND
             term_rec.actual_amount = tlinfo.actual_amount) OR
            (term_rec.start_date = tlinfo.start_date AND
             term_rec.end_date > tlinfo.end_date AND
             term_rec.actual_amount = tlinfo.actual_amount) OR
            (term_rec.start_date < tlinfo.start_date AND
             term_rec.end_date > tlinfo.end_date AND
             term_rec.actual_amount = tlinfo.actual_amount) THEN

            l_adj_type_code := 'ADJ-PEXP';

         ELSIF (term_rec.start_date = tlinfo.start_date AND
            term_rec.end_date = tlinfo.end_date AND
            term_rec.actual_amount <> tlinfo.actual_amount) THEN

            l_adj_type_code := 'ADJ-AMT';

         ELSE
            l_adj_type_code := 'ADJ-MUL';
         END IF;

         pnp_debug_pkg.debug('create_hist_corr_upd : l_adj_type_code        :'||l_adj_type_code);
         pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- Inserting into Term Hist.');

         INSERT INTO pn_payment_terms_history
            (TERM_HISTORY_ID
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_LOGIN
            ,PAYMENT_TERM_ID
            ,DISTRIBUTION_CHANGE_ID
            ,PREV_TERM_HISTORY_ID
            ,ADJUSTMENT_TYPE_CODE
            ,TOTAL_ADJ_AMOUNT
            ,PAYMENT_PURPOSE_CODE
            ,PAYMENT_TERM_TYPE_CODE
            ,FREQUENCY_CODE
            ,LEASE_ID
            ,LEASE_CHANGE_ID
            ,START_DATE
            ,END_DATE
            ,VENDOR_ID
            ,VENDOR_SITE_ID
            ,TARGET_DATE
            ,ACTUAL_AMOUNT
            ,ESTIMATED_AMOUNT
            ,SET_OF_BOOKS_ID
            ,CURRENCY_CODE
            ,RATE
            ,ATTRIBUTE_CATEGORY
            ,ATTRIBUTE1
            ,ATTRIBUTE2
            ,ATTRIBUTE3
            ,ATTRIBUTE4
            ,ATTRIBUTE5
            ,ATTRIBUTE6
            ,ATTRIBUTE7
            ,ATTRIBUTE8
            ,ATTRIBUTE9
            ,ATTRIBUTE10
            ,ATTRIBUTE11
            ,ATTRIBUTE12
            ,ATTRIBUTE13
            ,ATTRIBUTE14
            ,ATTRIBUTE15
            ,CUSTOMER_ID
            ,CUSTOMER_SITE_USE_ID
            ,NORMALIZE
            ,LOCATION_ID
            ,SCHEDULE_DAY
            ,CUST_SHIP_SITE_ID
            ,AP_AR_TERM_ID
            ,CUST_TRX_TYPE_ID
            ,PROJECT_ID
            ,TASK_ID
            ,ORGANIZATION_ID
            ,EXPENDITURE_TYPE
            ,EXPENDITURE_ITEM_DATE
            ,TAX_GROUP_ID
            ,TAX_CODE_ID
            ,TAX_CLASSIFICATION_CODE
            ,TAX_INCLUDED
            ,DISTRIBUTION_SET_ID
            ,INV_RULE_ID
            ,ACCOUNT_RULE_ID
            ,SALESREP_ID
            ,APPROVED_BY
            ,STATUS
            ,INDEX_PERIOD_ID
            ,INDEX_TERM_INDICATOR
            ,PO_HEADER_ID
            ,CUST_PO_NUMBER
            ,RECEIPT_METHOD_ID
            ,LEGAL_ENTITY_ID
            ,PROJECT_ATTRIBUTE_CATEGORY
            ,PROJECT_ATTRIBUTE1
            ,PROJECT_ATTRIBUTE2
            ,PROJECT_ATTRIBUTE3
            ,PROJECT_ATTRIBUTE4
            ,PROJECT_ATTRIBUTE5
            ,PROJECT_ATTRIBUTE6
            ,PROJECT_ATTRIBUTE7
            ,PROJECT_ATTRIBUTE8
            ,PROJECT_ATTRIBUTE9
            ,PROJECT_ATTRIBUTE10
            ,PROJECT_ATTRIBUTE11
            ,PROJECT_ATTRIBUTE12
            ,PROJECT_ATTRIBUTE13
            ,PROJECT_ATTRIBUTE14
            ,PROJECT_ATTRIBUTE15
            ,VAR_RENT_INV_ID
            ,VAR_RENT_TYPE
            ,CHANGED_FLAG
            ,NORM_START_DATE
            ,TERM_TEMPLATE_ID
            ,EVENT_TYPE_CODE
            ,LEASE_STATUS
            ,NORM_END_DATE
            ,RECOVERABLE_FLAG
            ,PERIOD_BILLREC_ID
            ,AMOUNT_TYPE
            ,REC_AGR_LINE_ID
            ,GROUPING_RULE_ID
            ,AREA_TYPE_CODE
            ,AREA
            ,TERM_COMMENTS)
         VALUES
            (PN_PAYMENT_TERMS_HISTORY_S.NEXTVAL
            ,SYSDATE
            ,FND_GLOBAL.USER_ID
            ,SYSDATE
            ,FND_GLOBAL.USER_ID
            ,FND_GLOBAL.LOGIN_ID
            ,tlinfo.payment_term_id
            ,l_dist_change_id
            ,l_prev_term_hist_id
            ,l_adj_type_code
            ,NULL                              -- TOTAL_ADJ_AMOUNT
            ,term_rec.PAYMENT_PURPOSE_CODE
            ,term_rec.PAYMENT_TERM_TYPE_CODE
            ,term_rec.FREQUENCY_CODE
            ,term_rec.LEASE_ID
            ,term_rec.LEASE_CHANGE_ID
            ,term_rec.START_DATE
            ,term_rec.END_DATE
            ,term_rec.VENDOR_ID
            ,term_rec.VENDOR_SITE_ID
            ,term_rec.TARGET_DATE
            ,term_rec.ACTUAL_AMOUNT
            ,term_rec.ESTIMATED_AMOUNT
            ,term_rec.SET_OF_BOOKS_ID
            ,term_rec.CURRENCY_CODE
            ,term_rec.RATE
            ,term_rec.ATTRIBUTE_CATEGORY
            ,term_rec.ATTRIBUTE1
            ,term_rec.ATTRIBUTE2
            ,term_rec.ATTRIBUTE3
            ,term_rec.ATTRIBUTE4
            ,term_rec.ATTRIBUTE5
            ,term_rec.ATTRIBUTE6
            ,term_rec.ATTRIBUTE7
            ,term_rec.ATTRIBUTE8
            ,term_rec.ATTRIBUTE9
            ,term_rec.ATTRIBUTE10
            ,term_rec.ATTRIBUTE11
            ,term_rec.ATTRIBUTE12
            ,term_rec.ATTRIBUTE13
            ,term_rec.ATTRIBUTE14
            ,term_rec.ATTRIBUTE15
            ,term_rec.CUSTOMER_ID
            ,term_rec.CUSTOMER_SITE_USE_ID
            ,term_rec.NORMALIZE
            ,term_rec.LOCATION_ID
            ,term_rec.SCHEDULE_DAY
            ,term_rec.CUST_SHIP_SITE_ID
            ,term_rec.AP_AR_TERM_ID
            ,term_rec.CUST_TRX_TYPE_ID
            ,term_rec.PROJECT_ID
            ,term_rec.TASK_ID
            ,term_rec.ORGANIZATION_ID
            ,term_rec.EXPENDITURE_TYPE
            ,term_rec.EXPENDITURE_ITEM_DATE
            ,term_rec.TAX_GROUP_ID
            ,term_rec.TAX_CODE_ID
            ,term_rec.TAX_CLASSIFICATION_CODE
            ,term_rec.TAX_INCLUDED
            ,term_rec.DISTRIBUTION_SET_ID
            ,term_rec.INV_RULE_ID
            ,term_rec.ACCOUNT_RULE_ID
            ,term_rec.SALESREP_ID
            ,term_rec.APPROVED_BY
            ,term_rec.STATUS
            ,term_rec.INDEX_PERIOD_ID
            ,term_rec.INDEX_TERM_INDICATOR
            ,term_rec.PO_HEADER_ID
            ,term_rec.CUST_PO_NUMBER
            ,term_rec.RECEIPT_METHOD_ID
            ,term_rec.LEGAL_ENTITY_ID
            ,term_rec.PROJECT_ATTRIBUTE_CATEGORY
            ,term_rec.PROJECT_ATTRIBUTE1
            ,term_rec.PROJECT_ATTRIBUTE2
            ,term_rec.PROJECT_ATTRIBUTE3
            ,term_rec.PROJECT_ATTRIBUTE4
            ,term_rec.PROJECT_ATTRIBUTE5
            ,term_rec.PROJECT_ATTRIBUTE6
            ,term_rec.PROJECT_ATTRIBUTE7
            ,term_rec.PROJECT_ATTRIBUTE8
            ,term_rec.PROJECT_ATTRIBUTE9
            ,term_rec.PROJECT_ATTRIBUTE10
            ,term_rec.PROJECT_ATTRIBUTE11
            ,term_rec.PROJECT_ATTRIBUTE12
            ,term_rec.PROJECT_ATTRIBUTE13
            ,term_rec.PROJECT_ATTRIBUTE14
            ,term_rec.PROJECT_ATTRIBUTE15
            ,term_rec.VAR_RENT_INV_ID
            ,term_rec.VAR_RENT_TYPE
            ,term_rec.CHANGED_FLAG
            ,tlinfo.NORM_START_DATE
            ,tlinfo.TERM_TEMPLATE_ID
            ,tlinfo.EVENT_TYPE_CODE
            ,tlinfo.LEASE_STATUS
            ,tlinfo.NORM_END_DATE
            ,term_rec.RECOVERABLE_FLAG
            ,tlinfo.PERIOD_BILLREC_ID
            ,tlinfo.AMOUNT_TYPE
            ,tlinfo.REC_AGR_LINE_ID
            ,term_rec.GROUPING_RULE_ID
            ,term_rec.AREA_TYPE_CODE
            ,term_rec.AREA
            ,term_rec.TERM_COMMENTS);
      END IF;

      IF p_change_mode = 'UPDATE' THEN

         pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- p_eff_str_dt : '||p_eff_str_dt);
         pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- p_eff_end_dt : '||p_eff_end_dt);
         pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- term_str_dt  : '||term_rec.start_date);
         pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- term_end_dt  : '||term_rec.end_date);

         IF (p_eff_str_dt > term_rec.start_date AND
             NVL(p_eff_end_dt, term_rec.end_date) <= term_rec.end_date) THEN

            SELECT pn_payment_terms_s.nextval
            INTO   l_new_term_id
            FROM   DUAL;

            l_adj_type_code := NULL;
            l_term_comments := NULL;

            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- l_new_term_id: '||l_new_term_id);
            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- Updating term with new Term Id');

            UPDATE pn_payment_terms_all
            SET    start_date = p_eff_str_dt,
                   end_date   = NVL(p_eff_end_dt,term_rec.end_date),
                   term_altered_flag = 'Y',
                   changed_flag      = 'N',
                   payment_term_id = l_new_term_id
            WHERE  payment_term_id = p_term_id;

            SELECT pn_distributions_history_s1.NEXTVAL
            INTO   l_dist_change_id
            FROM   DUAL;

            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- l_dist_change_id: '||l_dist_change_id);

            FOR dist_rec IN get_dist_cur(p_term_id) LOOP

               l_new_dist_id := NULL;
               SELECT pn_distributions_s.nextval
               INTO   l_new_dist_id
               FROM   DUAL;

               pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- l_new_dist_id : '||l_new_dist_id);

               UPDATE pn_distributions_all
               SET    distribution_id = l_new_dist_id,
                      payment_term_id = l_new_term_id
               WHERE  distribution_id = dist_rec.distribution_id;

               pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- Inserting into Dist. Hist.');

               INSERT INTO pn_distributions_history
                  (DISTRIBUTION_HISTORY_ID
                  ,LAST_UPDATE_DATE
                  ,LAST_UPDATED_BY
                  ,CREATION_DATE
                  ,CREATED_BY
                  ,LAST_UPDATE_LOGIN
                  ,DISTRIBUTION_CHANGE_ID
                  ,DISTRIBUTION_ID
                  ,ACCOUNT_ID
                  ,ACCOUNT_CLASS
                  ,PERCENTAGE
                  ,LINE_NUMBER
                  ,ATTRIBUTE_CATEGORY
                  ,ATTRIBUTE1
                  ,ATTRIBUTE2
                  ,ATTRIBUTE3
                  ,ATTRIBUTE4
                  ,ATTRIBUTE5
                  ,ATTRIBUTE6
                  ,ATTRIBUTE7
                  ,ATTRIBUTE8
                  ,ATTRIBUTE9
                  ,ATTRIBUTE10
                  ,ATTRIBUTE11
                  ,ATTRIBUTE12
                  ,ATTRIBUTE13
                  ,ATTRIBUTE14
                  ,ATTRIBUTE15)
               VALUES
                  (pn_distributions_history_s.NEXTVAL
                  ,SYSDATE
                  ,FND_GLOBAL.USER_ID
                  ,SYSDATE
                  ,FND_GLOBAL.USER_ID
                  ,FND_GLOBAL.LOGIN_ID
                  ,l_dist_change_id
                  ,l_new_dist_id
                  ,dist_rec.ACCOUNT_ID
                  ,dist_rec.ACCOUNT_CLASS
                  ,dist_rec.PERCENTAGE
                  ,dist_rec.LINE_NUMBER
                  ,dist_rec.ATTRIBUTE_CATEGORY
                  ,dist_rec.ATTRIBUTE1
                  ,dist_rec.ATTRIBUTE2
                  ,dist_rec.ATTRIBUTE3
                  ,dist_rec.ATTRIBUTE4
                  ,dist_rec.ATTRIBUTE5
                  ,dist_rec.ATTRIBUTE6
                  ,dist_rec.ATTRIBUTE7
                  ,dist_rec.ATTRIBUTE8
                  ,dist_rec.ATTRIBUTE9
                  ,dist_rec.ATTRIBUTE10
                  ,dist_rec.ATTRIBUTE11
                  ,dist_rec.ATTRIBUTE12
                  ,dist_rec.ATTRIBUTE13
                  ,dist_rec.ATTRIBUTE14
                  ,dist_rec.ATTRIBUTE15);

            END LOOP;

         ELSIF (p_eff_str_dt = term_rec.start_date AND
               NVL(p_eff_end_dt, term_rec.end_date) <= term_rec.end_date) THEN

            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- Updating term with Eff. End Date');

            UPDATE pn_payment_terms_all
            SET    end_date = NVL(p_eff_end_dt, term_rec.end_date),
                   term_altered_flag = 'Y',
                   changed_flag = 'Y'
            WHERE  payment_term_id = p_term_id;

            l_new_term_id := tlinfo.payment_term_id;
            l_adj_type_code := 'ADJ-PCON';
            l_term_comments := term_rec.term_comments;

            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- l_new_term_id: '||l_new_term_id);

         END IF;

         IF (p_eff_str_dt >= term_rec.start_date AND
             NVL(p_eff_end_dt, term_rec.end_date) <= term_rec.end_date) THEN

            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- l_new_term_id: '||l_new_term_id);
            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- l_dist_change_id: '||l_dist_change_id);
            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- Inserting into Term Hist.');

            INSERT INTO pn_payment_terms_history
               (TERM_HISTORY_ID
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_LOGIN
               ,PAYMENT_TERM_ID
               ,DISTRIBUTION_CHANGE_ID
               ,PREV_TERM_HISTORY_ID
               ,ADJUSTMENT_TYPE_CODE
               ,TOTAL_ADJ_AMOUNT
               ,PAYMENT_PURPOSE_CODE
               ,PAYMENT_TERM_TYPE_CODE
               ,FREQUENCY_CODE
               ,LEASE_ID
               ,LEASE_CHANGE_ID
               ,START_DATE
               ,END_DATE
               ,VENDOR_ID
               ,VENDOR_SITE_ID
               ,TARGET_DATE
               ,ACTUAL_AMOUNT
               ,ESTIMATED_AMOUNT
               ,SET_OF_BOOKS_ID
               ,CURRENCY_CODE
               ,RATE
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,CUSTOMER_ID
               ,CUSTOMER_SITE_USE_ID
               ,NORMALIZE
               ,LOCATION_ID
               ,SCHEDULE_DAY
               ,CUST_SHIP_SITE_ID
               ,AP_AR_TERM_ID
               ,CUST_TRX_TYPE_ID
               ,PROJECT_ID
               ,TASK_ID
               ,ORGANIZATION_ID
               ,EXPENDITURE_TYPE
               ,EXPENDITURE_ITEM_DATE
               ,TAX_GROUP_ID
               ,TAX_CODE_ID
               ,TAX_CLASSIFICATION_CODE
               ,TAX_INCLUDED
               ,DISTRIBUTION_SET_ID
               ,INV_RULE_ID
               ,ACCOUNT_RULE_ID
               ,SALESREP_ID
               ,APPROVED_BY
               ,STATUS
               ,INDEX_PERIOD_ID
               ,INDEX_TERM_INDICATOR
               ,PO_HEADER_ID
               ,CUST_PO_NUMBER
               ,RECEIPT_METHOD_ID
               ,LEGAL_ENTITY_ID
               ,PROJECT_ATTRIBUTE_CATEGORY
               ,PROJECT_ATTRIBUTE1
               ,PROJECT_ATTRIBUTE2
               ,PROJECT_ATTRIBUTE3
               ,PROJECT_ATTRIBUTE4
               ,PROJECT_ATTRIBUTE5
               ,PROJECT_ATTRIBUTE6
               ,PROJECT_ATTRIBUTE7
               ,PROJECT_ATTRIBUTE8
               ,PROJECT_ATTRIBUTE9
               ,PROJECT_ATTRIBUTE10
               ,PROJECT_ATTRIBUTE11
               ,PROJECT_ATTRIBUTE12
               ,PROJECT_ATTRIBUTE13
               ,PROJECT_ATTRIBUTE14
               ,PROJECT_ATTRIBUTE15
               ,VAR_RENT_INV_ID
               ,VAR_RENT_TYPE
               ,CHANGED_FLAG
               ,NORM_START_DATE
               ,TERM_TEMPLATE_ID
               ,EVENT_TYPE_CODE
               ,LEASE_STATUS
               ,NORM_END_DATE
               ,RECOVERABLE_FLAG
               ,PERIOD_BILLREC_ID
               ,AMOUNT_TYPE
               ,REC_AGR_LINE_ID
               ,GROUPING_RULE_ID
               ,AREA_TYPE_CODE
               ,AREA
               ,TERM_COMMENTS)
            VALUES
               (PN_PAYMENT_TERMS_HISTORY_S.NEXTVAL
               ,SYSDATE
               ,FND_GLOBAL.USER_ID
               ,SYSDATE
               ,FND_GLOBAL.USER_ID
               ,FND_GLOBAL.LOGIN_ID
               ,l_new_term_id
               ,l_dist_change_id
               ,l_prev_term_hist_id
               ,l_adj_type_code
               ,NULL                     -- TOTAL_ADJ_AMOUNT
               ,term_rec.PAYMENT_PURPOSE_CODE
               ,term_rec.PAYMENT_TERM_TYPE_CODE
               ,term_rec.FREQUENCY_CODE
               ,term_rec.LEASE_ID
               ,term_rec.LEASE_CHANGE_ID
               ,p_eff_str_dt
               ,NVL(p_eff_end_dt,term_rec.end_date)
               ,term_rec.VENDOR_ID
               ,term_rec.VENDOR_SITE_ID
               ,term_rec.TARGET_DATE
               ,term_rec.ACTUAL_AMOUNT
               ,term_rec.ESTIMATED_AMOUNT
               ,term_rec.SET_OF_BOOKS_ID
               ,term_rec.CURRENCY_CODE
               ,term_rec.RATE
               ,term_rec.ATTRIBUTE_CATEGORY
               ,term_rec.ATTRIBUTE1
               ,term_rec.ATTRIBUTE2
               ,term_rec.ATTRIBUTE3
               ,term_rec.ATTRIBUTE4
               ,term_rec.ATTRIBUTE5
               ,term_rec.ATTRIBUTE6
               ,term_rec.ATTRIBUTE7
               ,term_rec.ATTRIBUTE8
               ,term_rec.ATTRIBUTE9
               ,term_rec.ATTRIBUTE10
               ,term_rec.ATTRIBUTE11
               ,term_rec.ATTRIBUTE12
               ,term_rec.ATTRIBUTE13
               ,term_rec.ATTRIBUTE14
               ,term_rec.ATTRIBUTE15
               ,term_rec.CUSTOMER_ID
               ,term_rec.CUSTOMER_SITE_USE_ID
               ,term_rec.NORMALIZE
               ,term_rec.LOCATION_ID
               ,term_rec.SCHEDULE_DAY
               ,term_rec.CUST_SHIP_SITE_ID
               ,term_rec.AP_AR_TERM_ID
               ,term_rec.CUST_TRX_TYPE_ID
               ,term_rec.PROJECT_ID
               ,term_rec.TASK_ID
               ,term_rec.ORGANIZATION_ID
               ,term_rec.EXPENDITURE_TYPE
               ,term_rec.EXPENDITURE_ITEM_DATE
               ,term_rec.TAX_GROUP_ID
               ,term_rec.TAX_CODE_ID
               ,term_rec.TAX_CLASSIFICATION_CODE
               ,term_rec.TAX_INCLUDED
               ,term_rec.DISTRIBUTION_SET_ID
               ,term_rec.INV_RULE_ID
               ,term_rec.ACCOUNT_RULE_ID
               ,term_rec.SALESREP_ID
               ,term_rec.APPROVED_BY
               ,term_rec.STATUS
               ,term_rec.INDEX_PERIOD_ID
               ,term_rec.INDEX_TERM_INDICATOR
               ,term_rec.PO_HEADER_ID
               ,term_rec.CUST_PO_NUMBER
               ,term_rec.RECEIPT_METHOD_ID
               ,term_rec.LEGAL_ENTITY_ID
               ,term_rec.PROJECT_ATTRIBUTE_CATEGORY
               ,term_rec.PROJECT_ATTRIBUTE1
               ,term_rec.PROJECT_ATTRIBUTE2
               ,term_rec.PROJECT_ATTRIBUTE3
               ,term_rec.PROJECT_ATTRIBUTE4
               ,term_rec.PROJECT_ATTRIBUTE5
               ,term_rec.PROJECT_ATTRIBUTE6
               ,term_rec.PROJECT_ATTRIBUTE7
               ,term_rec.PROJECT_ATTRIBUTE8
               ,term_rec.PROJECT_ATTRIBUTE9
               ,term_rec.PROJECT_ATTRIBUTE10
               ,term_rec.PROJECT_ATTRIBUTE11
               ,term_rec.PROJECT_ATTRIBUTE12
               ,term_rec.PROJECT_ATTRIBUTE13
               ,term_rec.PROJECT_ATTRIBUTE14
               ,term_rec.PROJECT_ATTRIBUTE15
               ,term_rec.VAR_RENT_INV_ID
               ,term_rec.VAR_RENT_TYPE
               ,term_rec.CHANGED_FLAG
               ,tlinfo.NORM_START_DATE
               ,tlinfo.TERM_TEMPLATE_ID
               ,tlinfo.EVENT_TYPE_CODE
               ,tlinfo.LEASE_STATUS
               ,tlinfo.NORM_END_DATE
               ,term_rec.RECOVERABLE_FLAG
               ,tlinfo.PERIOD_BILLREC_ID
               ,tlinfo.AMOUNT_TYPE
               ,tlinfo.REC_AGR_LINE_ID
               ,term_rec.GROUPING_RULE_ID
               ,term_rec.AREA_TYPE_CODE
               ,term_rec.AREA
               ,l_term_comments);

         END IF;

         pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- Setting value of counter n');

         IF p_eff_str_dt <> term_rec.start_date THEN
            IF NVL(p_eff_end_dt, term_rec.end_date) = term_rec.end_date THEN
               n := 1;
            ELSIF NVL(p_eff_end_dt, term_rec.end_date) < term_rec.end_date THEN
               n := 2;
            END IF;
         ELSIF p_eff_str_dt = term_rec.start_date THEN
            n := 1;
         END IF;

         pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- Check counter value n :'||n);

         FOR i in 1..n LOOP

            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- In Term Loop for i :'||i);

            IF p_eff_str_dt <> term_rec.start_date AND
               i = 1 THEN

               l_term_id := p_term_id;
               l_str_dt := term_rec.start_date;
               l_end_dt := p_eff_str_dt - 1;
               l_adj_type_code := 'ADJ-PCON';
               l_term_comments := term_rec.term_comments;
               l_last_update_date := SYSDATE;
               l_last_updated_by := FND_GLOBAL.USER_ID;
               l_creation_date := tlinfo.creation_date;
               l_created_by := tlinfo.created_by;
               l_last_update_login := FND_GLOBAL.LOGIN_ID;
               l_changed_flag := 'Y';

            ELSIF (p_eff_str_dt <> term_rec.start_date AND
                   i = 2) OR
               (p_eff_str_dt = term_rec.start_date AND
                i = 1) THEN

               SELECT pn_payment_terms_s.nextval
               INTO   l_term_id
               FROM DUAL;

               l_str_dt := NVL(p_eff_end_dt, term_rec.end_date) + 1;
               l_end_dt := term_rec.end_date;
               l_adj_type_code := NULL;
               l_term_comments := NULL;
               l_last_update_date := SYSDATE;
               l_last_updated_by := FND_GLOBAL.USER_ID;
               l_creation_date := SYSDATE;
               l_created_by := FND_GLOBAL.USER_ID;
               l_last_update_login := FND_GLOBAL.LOGIN_ID;
               l_changed_flag := 'N';

            END IF;

            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- l_term_id : '||l_term_id);
            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- l_str_dt  : '||l_str_dt);
            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- l_end_dt  : '||l_end_dt);
            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- Inserting into Terms table.');

            INSERT INTO pn_payment_terms_all
               (PAYMENT_TERM_ID
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_LOGIN
               ,PAYMENT_PURPOSE_CODE
               ,PAYMENT_TERM_TYPE_CODE
               ,FREQUENCY_CODE
               ,LEASE_ID
               ,LEASE_CHANGE_ID
               ,START_DATE
               ,END_DATE
               ,VENDOR_ID
               ,VENDOR_SITE_ID
               ,CUSTOMER_ID
               ,CUSTOMER_SITE_USE_ID
               ,TARGET_DATE
               ,ACTUAL_AMOUNT
               ,ESTIMATED_AMOUNT
               ,SET_OF_BOOKS_ID
               ,CURRENCY_CODE
               ,RATE
               ,NORMALIZE
               ,LOCATION_ID
               ,SCHEDULE_DAY
               ,CUST_SHIP_SITE_ID
               ,AP_AR_TERM_ID
               ,CUST_TRX_TYPE_ID
               ,PROJECT_ID
               ,TASK_ID
               ,ORGANIZATION_ID
               ,EXPENDITURE_TYPE
               ,EXPENDITURE_ITEM_DATE
               ,TAX_GROUP_ID
               ,TAX_CODE_ID
               ,TAX_CLASSIFICATION_CODE
               ,TAX_INCLUDED
               ,DISTRIBUTION_SET_ID
               ,INV_RULE_ID
               ,ACCOUNT_RULE_ID
               ,SALESREP_ID
               ,APPROVED_BY
               ,STATUS
               ,INDEX_PERIOD_ID
               ,INDEX_TERM_INDICATOR
               ,PO_HEADER_ID
               ,CUST_PO_NUMBER
               ,RECEIPT_METHOD_ID
               ,VAR_RENT_INV_ID
               ,VAR_RENT_TYPE
               ,PERIOD_BILLREC_ID
               ,REC_AGR_LINE_ID
               ,AMOUNT_TYPE
               ,CHANGED_FLAG
               ,TERM_TEMPLATE_ID
               ,LEGAL_ENTITY_ID
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,PROJECT_ATTRIBUTE_CATEGORY
               ,PROJECT_ATTRIBUTE1
               ,PROJECT_ATTRIBUTE2
               ,PROJECT_ATTRIBUTE3
               ,PROJECT_ATTRIBUTE4
               ,PROJECT_ATTRIBUTE5
               ,PROJECT_ATTRIBUTE6
               ,PROJECT_ATTRIBUTE7
               ,PROJECT_ATTRIBUTE8
               ,PROJECT_ATTRIBUTE9
               ,PROJECT_ATTRIBUTE10
               ,PROJECT_ATTRIBUTE11
               ,PROJECT_ATTRIBUTE12
               ,PROJECT_ATTRIBUTE13
               ,PROJECT_ATTRIBUTE14
               ,PROJECT_ATTRIBUTE15
               ,org_id
               ,lease_status
               ,recoverable_flag
               ,area_type_code
               ,area
               ,grouping_rule_id
               ,term_altered_flag
               ,source_code
               ,term_comments)
            VALUES
               (l_term_id
               ,l_last_update_date
               ,l_last_updated_by
               ,l_creation_date
               ,l_created_by
               ,l_last_update_login
               ,tlinfo.PAYMENT_PURPOSE_CODE
               ,tlinfo.PAYMENT_TERM_TYPE_CODE
               ,tlinfo.FREQUENCY_CODE
               ,tlinfo.LEASE_ID
               ,term_rec.LEASE_CHANGE_ID
               ,l_str_dt
               ,l_end_dt
               ,tlinfo.VENDOR_ID
               ,tlinfo.VENDOR_SITE_ID
               ,tlinfo.CUSTOMER_ID
               ,tlinfo.CUSTOMER_SITE_USE_ID
               ,tlinfo.TARGET_DATE
               ,tlinfo.ACTUAL_AMOUNT
               ,tlinfo.ESTIMATED_AMOUNT
               ,tlinfo.SET_OF_BOOKS_ID
               ,tlinfo.CURRENCY_CODE
               ,tlinfo.RATE
               ,tlinfo.NORMALIZE
               ,tlinfo.LOCATION_ID
               ,tlinfo.SCHEDULE_DAY
               ,tlinfo.CUST_SHIP_SITE_ID
               ,tlinfo.AP_AR_TERM_ID
               ,tlinfo.CUST_TRX_TYPE_ID
               ,tlinfo.PROJECT_ID
               ,tlinfo.TASK_ID
               ,tlinfo.ORGANIZATION_ID
               ,tlinfo.EXPENDITURE_TYPE
               ,tlinfo.EXPENDITURE_ITEM_DATE
               ,tlinfo.TAX_GROUP_ID
               ,tlinfo.TAX_CODE_ID
               ,tlinfo.TAX_CLASSIFICATION_CODE
               ,tlinfo.TAX_INCLUDED
               ,tlinfo.DISTRIBUTION_SET_ID
               ,tlinfo.INV_RULE_ID
               ,tlinfo.ACCOUNT_RULE_ID
               ,tlinfo.SALESREP_ID
               ,tlinfo.APPROVED_BY
               ,tlinfo.STATUS
               ,tlinfo.INDEX_PERIOD_ID
               ,tlinfo.INDEX_TERM_INDICATOR
               ,tlinfo.PO_HEADER_ID
               ,tlinfo.CUST_PO_NUMBER
               ,tlinfo.RECEIPT_METHOD_ID
               ,tlinfo.VAR_RENT_INV_ID
               ,tlinfo.VAR_RENT_TYPE
               ,tlinfo.PERIOD_BILLREC_ID
               ,tlinfo.REC_AGR_LINE_ID
               ,tlinfo.AMOUNT_TYPE
               ,l_changed_flag
               ,tlinfo.TERM_TEMPLATE_ID
               ,tlinfo.LEGAL_ENTITY_ID
               ,tlinfo.ATTRIBUTE_CATEGORY
               ,tlinfo.ATTRIBUTE1
               ,tlinfo.ATTRIBUTE2
               ,tlinfo.ATTRIBUTE3
               ,tlinfo.ATTRIBUTE4
               ,tlinfo.ATTRIBUTE5
               ,tlinfo.ATTRIBUTE6
               ,tlinfo.ATTRIBUTE7
               ,tlinfo.ATTRIBUTE8
               ,tlinfo.ATTRIBUTE9
               ,tlinfo.ATTRIBUTE10
               ,tlinfo.ATTRIBUTE11
               ,tlinfo.ATTRIBUTE12
               ,tlinfo.ATTRIBUTE13
               ,tlinfo.ATTRIBUTE14
               ,tlinfo.ATTRIBUTE15
               ,tlinfo.PROJECT_ATTRIBUTE_CATEGORY
               ,tlinfo.PROJECT_ATTRIBUTE1
               ,tlinfo.PROJECT_ATTRIBUTE2
               ,tlinfo.PROJECT_ATTRIBUTE3
               ,tlinfo.PROJECT_ATTRIBUTE4
               ,tlinfo.PROJECT_ATTRIBUTE5
               ,tlinfo.PROJECT_ATTRIBUTE6
               ,tlinfo.PROJECT_ATTRIBUTE7
               ,tlinfo.PROJECT_ATTRIBUTE8
               ,tlinfo.PROJECT_ATTRIBUTE9
               ,tlinfo.PROJECT_ATTRIBUTE10
               ,tlinfo.PROJECT_ATTRIBUTE11
               ,tlinfo.PROJECT_ATTRIBUTE12
               ,tlinfo.PROJECT_ATTRIBUTE13
               ,tlinfo.PROJECT_ATTRIBUTE14
               ,tlinfo.PROJECT_ATTRIBUTE15
               ,tlinfo.org_id
               ,tlinfo.lease_status
               ,tlinfo.recoverable_flag
               ,tlinfo.area_type_code
               ,tlinfo.area
               ,tlinfo.grouping_rule_id
               ,'Y'
               ,tlinfo.source_code
               ,tlinfo.term_comments);

            IF NVL(p_hist_dist_tab.count,0) <> 0 THEN

               SELECT pn_distributions_history_s1.NEXTVAL
               INTO   l_dist_change_id
               FROM   DUAL;

               l_insert_dist_hist := 'N';

               FOR j in 1..p_hist_dist_tab.count LOOP

                  pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- In Dist. Loop for j :'||j);

                  IF p_eff_str_dt <> term_rec.start_date AND
                     i = 1 THEN

                     l_dist_id := p_hist_dist_tab(j).distribution_id;
                     l_insert_dist_hist := 'N';

                  ELSIF (p_eff_str_dt <> term_rec.start_date AND
                         i = 2) OR
                     (p_eff_str_dt = term_rec.start_date AND
                      i = 1) THEN

                     SELECT pn_distributions_s.NEXTVAL
                     INTO   l_dist_id
                     FROM   DUAL;

                     l_insert_dist_hist := 'Y';

                  END IF;

                  pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- l_dist_id : '||l_dist_id);
                  pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- l_insert_dist_hist: '||l_insert_dist_hist);
                  pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- Inserting into Dist. table.');

                  INSERT INTO pn_distributions_all
                     (distribution_id
                     ,account_id
                     ,payment_term_id
                     ,term_template_id
                     ,account_class
                     ,percentage
                     ,line_number
                     ,last_update_date
                     ,last_updated_by
                     ,creation_date
                     ,created_by
                     ,last_update_login
                     ,attribute_category
                     ,attribute1
                     ,attribute2
                     ,attribute3
                     ,attribute4
                     ,attribute5
                     ,attribute6
                     ,attribute7
                     ,attribute8
                     ,attribute9
                     ,attribute10
                     ,attribute11
                     ,attribute12
                     ,attribute13
                     ,attribute14
                     ,attribute15
                     ,org_id)
                  VALUES
                     (l_dist_id
                     ,p_hist_dist_tab(j).account_id
                     ,l_term_id
                     ,p_hist_dist_tab(j).term_template_id
                     ,p_hist_dist_tab(j).account_class
                     ,p_hist_dist_tab(j).percentage
                     ,p_hist_dist_tab(j).line_number
                     ,l_last_update_date
                     ,l_last_updated_by
                     ,l_creation_date
                     ,l_created_by
                     ,l_last_update_login
                     ,p_hist_dist_tab(j).attribute_category
                     ,p_hist_dist_tab(j).attribute1
                     ,p_hist_dist_tab(j).attribute2
                     ,p_hist_dist_tab(j).attribute3
                     ,p_hist_dist_tab(j).attribute4
                     ,p_hist_dist_tab(j).attribute5
                     ,p_hist_dist_tab(j).attribute6
                     ,p_hist_dist_tab(j).attribute7
                     ,p_hist_dist_tab(j).attribute8
                     ,p_hist_dist_tab(j).attribute9
                     ,p_hist_dist_tab(j).attribute10
                     ,p_hist_dist_tab(j).attribute11
                     ,p_hist_dist_tab(j).attribute12
                     ,p_hist_dist_tab(j).attribute13
                     ,p_hist_dist_tab(j).attribute14
                     ,p_hist_dist_tab(j).attribute15
                     ,p_hist_dist_tab(j).org_id);

                  IF l_insert_dist_hist = 'Y' THEN

                     pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- Inserting into Dist. Hist. table.');

                     INSERT INTO pn_distributions_history
                        (DISTRIBUTION_HISTORY_ID
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATED_BY
                        ,CREATION_DATE
                        ,CREATED_BY
                        ,LAST_UPDATE_LOGIN
                        ,DISTRIBUTION_CHANGE_ID
                        ,DISTRIBUTION_ID
                        ,ACCOUNT_ID
                        ,ACCOUNT_CLASS
                        ,PERCENTAGE
                        ,LINE_NUMBER
                        ,ATTRIBUTE_CATEGORY
                        ,ATTRIBUTE1
                        ,ATTRIBUTE2
                        ,ATTRIBUTE3
                        ,ATTRIBUTE4
                        ,ATTRIBUTE5
                        ,ATTRIBUTE6
                        ,ATTRIBUTE7
                        ,ATTRIBUTE8
                        ,ATTRIBUTE9
                        ,ATTRIBUTE10
                        ,ATTRIBUTE11
                        ,ATTRIBUTE12
                        ,ATTRIBUTE13
                        ,ATTRIBUTE14
                        ,ATTRIBUTE15)
                     VALUES
                        (pn_distributions_history_s.NEXTVAL
                        ,SYSDATE
                        ,FND_GLOBAL.USER_ID
                        ,SYSDATE
                        ,FND_GLOBAL.USER_ID
                        ,FND_GLOBAL.LOGIN_ID
                        ,l_dist_change_id
                        ,l_dist_id
                        ,p_hist_dist_tab(j).ACCOUNT_ID
                        ,p_hist_dist_tab(j).ACCOUNT_CLASS
                        ,p_hist_dist_tab(j).PERCENTAGE
                        ,p_hist_dist_tab(j).LINE_NUMBER
                        ,p_hist_dist_tab(j).ATTRIBUTE_CATEGORY
                        ,p_hist_dist_tab(j).ATTRIBUTE1
                        ,p_hist_dist_tab(j).ATTRIBUTE2
                        ,p_hist_dist_tab(j).ATTRIBUTE3
                        ,p_hist_dist_tab(j).ATTRIBUTE4
                        ,p_hist_dist_tab(j).ATTRIBUTE5
                        ,p_hist_dist_tab(j).ATTRIBUTE6
                        ,p_hist_dist_tab(j).ATTRIBUTE7
                        ,p_hist_dist_tab(j).ATTRIBUTE8
                        ,p_hist_dist_tab(j).ATTRIBUTE9
                        ,p_hist_dist_tab(j).ATTRIBUTE10
                        ,p_hist_dist_tab(j).ATTRIBUTE11
                        ,p_hist_dist_tab(j).ATTRIBUTE12
                        ,p_hist_dist_tab(j).ATTRIBUTE13
                        ,p_hist_dist_tab(j).ATTRIBUTE14
                        ,p_hist_dist_tab(j).ATTRIBUTE15);
                  END IF;
               END LOOP;

               IF l_insert_dist_hist = 'N' THEN

                  OPEN get_max_dist_change_id_cur(p_term_id);
                  FETCH get_max_dist_change_id_cur INTO l_dist_change_id;
                  CLOSE get_max_dist_change_id_cur;

                  pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- get_max_dist_change_id : '||l_dist_change_id);
               END IF;
            END IF;

            pnp_debug_pkg.debug('create_hist_corr_upd : '||p_change_mode|| '- Inserting into Term Hist. table.');

            INSERT INTO pn_payment_terms_history
               (TERM_HISTORY_ID
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_LOGIN
               ,PAYMENT_TERM_ID
               ,DISTRIBUTION_CHANGE_ID
               ,PREV_TERM_HISTORY_ID
               ,ADJUSTMENT_TYPE_CODE
               ,TOTAL_ADJ_AMOUNT
               ,PAYMENT_PURPOSE_CODE
               ,PAYMENT_TERM_TYPE_CODE
               ,FREQUENCY_CODE
               ,LEASE_ID
               ,LEASE_CHANGE_ID
               ,START_DATE
               ,END_DATE
               ,VENDOR_ID
               ,VENDOR_SITE_ID
               ,TARGET_DATE
               ,ACTUAL_AMOUNT
               ,ESTIMATED_AMOUNT
               ,SET_OF_BOOKS_ID
               ,CURRENCY_CODE
               ,RATE
               ,ATTRIBUTE_CATEGORY
               ,ATTRIBUTE1
               ,ATTRIBUTE2
               ,ATTRIBUTE3
               ,ATTRIBUTE4
               ,ATTRIBUTE5
               ,ATTRIBUTE6
               ,ATTRIBUTE7
               ,ATTRIBUTE8
               ,ATTRIBUTE9
               ,ATTRIBUTE10
               ,ATTRIBUTE11
               ,ATTRIBUTE12
               ,ATTRIBUTE13
               ,ATTRIBUTE14
               ,ATTRIBUTE15
               ,CUSTOMER_ID
               ,CUSTOMER_SITE_USE_ID
               ,NORMALIZE
               ,LOCATION_ID
               ,SCHEDULE_DAY
               ,CUST_SHIP_SITE_ID
               ,AP_AR_TERM_ID
               ,CUST_TRX_TYPE_ID
               ,PROJECT_ID
               ,TASK_ID
               ,ORGANIZATION_ID
               ,EXPENDITURE_TYPE
               ,EXPENDITURE_ITEM_DATE
               ,TAX_GROUP_ID
               ,TAX_CODE_ID
               ,TAX_CLASSIFICATION_CODE
               ,TAX_INCLUDED
               ,DISTRIBUTION_SET_ID
               ,INV_RULE_ID
               ,ACCOUNT_RULE_ID
               ,SALESREP_ID
               ,APPROVED_BY
               ,STATUS
               ,INDEX_PERIOD_ID
               ,INDEX_TERM_INDICATOR
               ,PO_HEADER_ID
               ,CUST_PO_NUMBER
               ,RECEIPT_METHOD_ID
               ,LEGAL_ENTITY_ID
               ,PROJECT_ATTRIBUTE_CATEGORY
               ,PROJECT_ATTRIBUTE1
               ,PROJECT_ATTRIBUTE2
               ,PROJECT_ATTRIBUTE3
               ,PROJECT_ATTRIBUTE4
               ,PROJECT_ATTRIBUTE5
               ,PROJECT_ATTRIBUTE6
               ,PROJECT_ATTRIBUTE7
               ,PROJECT_ATTRIBUTE8
               ,PROJECT_ATTRIBUTE9
               ,PROJECT_ATTRIBUTE10
               ,PROJECT_ATTRIBUTE11
               ,PROJECT_ATTRIBUTE12
               ,PROJECT_ATTRIBUTE13
               ,PROJECT_ATTRIBUTE14
               ,PROJECT_ATTRIBUTE15
               ,VAR_RENT_INV_ID
               ,VAR_RENT_TYPE
               ,CHANGED_FLAG
               ,NORM_START_DATE
               ,TERM_TEMPLATE_ID
               ,EVENT_TYPE_CODE
               ,LEASE_STATUS
               ,NORM_END_DATE
               ,RECOVERABLE_FLAG
               ,PERIOD_BILLREC_ID
               ,AMOUNT_TYPE
               ,REC_AGR_LINE_ID
               ,GROUPING_RULE_ID
               ,AREA_TYPE_CODE
               ,AREA
               ,TERM_COMMENTS)
            VALUES
               (PN_PAYMENT_TERMS_HISTORY_S.NEXTVAL
               ,SYSDATE
               ,FND_GLOBAL.USER_ID
               ,SYSDATE
               ,FND_GLOBAL.USER_ID
               ,FND_GLOBAL.LOGIN_ID
               ,l_term_id
               ,l_dist_change_id
               ,l_prev_term_hist_id
               ,l_adj_type_code
               ,NULL                     -- TOTAL_ADJ_AMOUNT
               ,tlinfo.PAYMENT_PURPOSE_CODE
               ,tlinfo.PAYMENT_TERM_TYPE_CODE
               ,tlinfo.FREQUENCY_CODE
               ,tlinfo.LEASE_ID
               ,term_rec.LEASE_CHANGE_ID
               ,l_str_dt
               ,l_end_dt
               ,tlinfo.VENDOR_ID
               ,tlinfo.VENDOR_SITE_ID
               ,tlinfo.TARGET_DATE
               ,tlinfo.ACTUAL_AMOUNT
               ,tlinfo.ESTIMATED_AMOUNT
               ,tlinfo.SET_OF_BOOKS_ID
               ,tlinfo.CURRENCY_CODE
               ,tlinfo.RATE
               ,tlinfo.ATTRIBUTE_CATEGORY
               ,tlinfo.ATTRIBUTE1
               ,tlinfo.ATTRIBUTE2
               ,tlinfo.ATTRIBUTE3
               ,tlinfo.ATTRIBUTE4
               ,tlinfo.ATTRIBUTE5
               ,tlinfo.ATTRIBUTE6
               ,tlinfo.ATTRIBUTE7
               ,tlinfo.ATTRIBUTE8
               ,tlinfo.ATTRIBUTE9
               ,tlinfo.ATTRIBUTE10
               ,tlinfo.ATTRIBUTE11
               ,tlinfo.ATTRIBUTE12
               ,tlinfo.ATTRIBUTE13
               ,tlinfo.ATTRIBUTE14
               ,tlinfo.ATTRIBUTE15
               ,tlinfo.CUSTOMER_ID
               ,tlinfo.CUSTOMER_SITE_USE_ID
               ,tlinfo.NORMALIZE
               ,tlinfo.LOCATION_ID
               ,tlinfo.SCHEDULE_DAY
               ,tlinfo.CUST_SHIP_SITE_ID
               ,tlinfo.AP_AR_TERM_ID
               ,tlinfo.CUST_TRX_TYPE_ID
               ,tlinfo.PROJECT_ID
               ,tlinfo.TASK_ID
               ,tlinfo.ORGANIZATION_ID
               ,tlinfo.EXPENDITURE_TYPE
               ,tlinfo.EXPENDITURE_ITEM_DATE
               ,tlinfo.TAX_GROUP_ID
               ,tlinfo.TAX_CODE_ID
               ,tlinfo.TAX_CLASSIFICATION_CODE
               ,tlinfo.TAX_INCLUDED
               ,tlinfo.DISTRIBUTION_SET_ID
               ,tlinfo.INV_RULE_ID
               ,tlinfo.ACCOUNT_RULE_ID
               ,tlinfo.SALESREP_ID
               ,tlinfo.APPROVED_BY
               ,tlinfo.STATUS
               ,tlinfo.INDEX_PERIOD_ID
               ,tlinfo.INDEX_TERM_INDICATOR
               ,tlinfo.PO_HEADER_ID
               ,tlinfo.CUST_PO_NUMBER
               ,tlinfo.RECEIPT_METHOD_ID
               ,tlinfo.LEGAL_ENTITY_ID
               ,tlinfo.PROJECT_ATTRIBUTE_CATEGORY
               ,tlinfo.PROJECT_ATTRIBUTE1
               ,tlinfo.PROJECT_ATTRIBUTE2
               ,tlinfo.PROJECT_ATTRIBUTE3
               ,tlinfo.PROJECT_ATTRIBUTE4
               ,tlinfo.PROJECT_ATTRIBUTE5
               ,tlinfo.PROJECT_ATTRIBUTE6
               ,tlinfo.PROJECT_ATTRIBUTE7
               ,tlinfo.PROJECT_ATTRIBUTE8
               ,tlinfo.PROJECT_ATTRIBUTE9
               ,tlinfo.PROJECT_ATTRIBUTE10
               ,tlinfo.PROJECT_ATTRIBUTE11
               ,tlinfo.PROJECT_ATTRIBUTE12
               ,tlinfo.PROJECT_ATTRIBUTE13
               ,tlinfo.PROJECT_ATTRIBUTE14
               ,tlinfo.PROJECT_ATTRIBUTE15
               ,tlinfo.VAR_RENT_INV_ID
               ,tlinfo.VAR_RENT_TYPE
               ,tlinfo.CHANGED_FLAG
               ,tlinfo.NORM_START_DATE
               ,tlinfo.TERM_TEMPLATE_ID
               ,tlinfo.EVENT_TYPE_CODE
               ,tlinfo.LEASE_STATUS
               ,tlinfo.NORM_END_DATE
               ,tlinfo.RECOVERABLE_FLAG
               ,tlinfo.PERIOD_BILLREC_ID
               ,tlinfo.AMOUNT_TYPE
               ,tlinfo.REC_AGR_LINE_ID
               ,tlinfo.GROUPING_RULE_ID
               ,tlinfo.AREA_TYPE_CODE
               ,tlinfo.AREA
               ,l_term_comments);
         END LOOP;
      END IF;
   END IF;

   pnp_debug_pkg.debug('PNT_PAYMENT_TERMS_PKG.create_hist_corr_upd (-)');

END create_hist_corr_upd;

--------------------------------------------------------------------------------
-- FUNCTION     : return_agreement_number
-- INVOKED FROM : pn_payment_terms_v form view (PNPTERMV.sql)
-- PURPOSE      : returns the agreement number to which the payment term is associated.
-- HISTORY      :
--
-- 12-MAR-07   Prabhakar    o  Created.
--------------------------------------------------------------------------------
FUNCTION return_agreement_number( p_payment_term_id IN NUMBER) RETURN VARCHAR2 IS

l_agreement_number  VARCHAR2(30) := NULL;

CURSOR c1 IS
SELECT opex_agr_id,index_period_id,var_rent_inv_id,rec_agr_line_id
FROM  pn_payment_terms_all
where payment_term_id = p_payment_term_id;

BEGIN

FOR rec1 IN c1 LOOP
  IF rec1.index_period_id IS NOT NULL THEN

     SELECT pil.index_lease_number
     INTO l_agreement_number
     FROM pn_index_lease_periods_all pilp,
          pn_index_leases_all pil
     WHERE pilp.index_lease_id = pil.index_lease_id
     AND pilp.index_period_id = rec1.index_period_id;

  ELSIF rec1.opex_agr_id IS NOT NULL THEN

     SELECT agr_num
     INTO l_agreement_number
     FROM pn_opex_agreements_all
     WHERE agreement_id = rec1.opex_agr_id;

  ELSIF rec1.var_rent_inv_id IS NOT NULL THEN

     SELECT var.rent_num
     INTO l_agreement_number
     FROM pn_var_rents_all var,
          pn_var_rent_inv_all inv
     WHERE var.var_rent_id = inv.var_rent_id
     AND inv.var_rent_inv_id = rec1.var_rent_inv_id;

  ELSIF rec1.rec_agr_line_id IS NOT NULL THEN

     SELECT rec.rec_agreement_num
     INTO l_agreement_number
     FROM pn_rec_agreements_all rec,
          pn_rec_agr_lines_all rlines
     WHERE rlines.rec_agreement_id = rec.rec_agreement_id
     AND   rlines.rec_agr_line_id  = rec1.rec_agr_line_id;

 ELSE

    SELECT NULL
    INTO l_agreement_number
    FROM DUAL;

 END IF;
END LOOP;

RETURN l_agreement_number;

END  return_agreement_number;

--------------------------------------------------------------------------------
-- FUNCTION     : CHECK_IF_OPEX_TERM
-- INVOKED FROM :
-- PURPOSE      : Checks whether or not the term is created from Opex UI.
-- HISTORY      :
--
-- 09-MAY-07   Prabhakar    o  Created.
--------------------------------------------------------------------------------
FUNCTION CHECK_IF_OPEX_TERM ( p_payment_term_id IN NUMBER,
                              p_opex_agr_id     IN NUMBER  )
RETURN BOOLEAN IS

   l_dummy              NUMBER := 0;

   CURSOR dummy  IS
   SELECT 1 flag
   FROM   pn_opex_est_payments_all
   WHERE  (payment_term_id = p_payment_term_id or catch_up_term_id = p_payment_term_id)
   AND    agreement_id = p_opex_agr_id;

BEGIN

   FOR rec IN dummy LOOP
      l_dummy := rec.flag;
   END LOOP;

   IF l_dummy = 1 THEN return(TRUE);
   ELSE return(FALSE);
   END IF;

END CHECK_IF_OPEX_TERM;

--------------------------------------------------------------------------------
-- FUNCTION     : get_source_module_type
-- INVOKED FROM : pn_payment_terms_v form view (PNPTERMV.sql)
-- PURPOSE      : returns the source of the term from which it is created.
-- HISTORY      :
--
-- 09-MAY-07   Prabhakar    o  Created.
--------------------------------------------------------------------------------
FUNCTION get_source_module_type( p_payment_term_id IN NUMBER) RETURN VARCHAR2 IS

l_source_module  VARCHAR2(30) := NULL;

CURSOR c1 IS
SELECT  opex_agr_id,
        opex_recon_id,
        index_period_id,
        var_rent_inv_id,
        rec_agr_line_id,
        source_code
FROM  pn_payment_terms_all
where payment_term_id = p_payment_term_id;

BEGIN

FOR rec1 IN c1 LOOP

  IF (rec1.opex_agr_id IS NOT NULL AND
      CHECK_IF_OPEX_TERM (p_payment_term_id, rec1.opex_agr_id) ) OR
      rec1.opex_recon_id IS NOT NULL THEN
        l_source_module := 'OPEX';
  ELSIF rec1.index_period_id IS NOT NULL THEN
     l_source_module := 'RI';
  ELSIF rec1.var_rent_inv_id IS NOT NULL THEN
     l_source_module := 'VR';
  ELSIF rec1.rec_agr_line_id IS NOT NULL THEN
     l_source_module := 'REC';
  ELSE
     l_source_module := rec1.source_code;
  END IF;

END LOOP;

RETURN l_source_module;

END  get_source_module_type;

PROCEDURE MODIFY_ROW ( x_payment_term_id IN NUMBER
                      ,x_var_rent_inv_id IN NUMBER
                      ,x_changed_flag    IN VARCHAR2)
IS
BEGIN

pnp_debug_pkg.debug ('PNT_PAYMENT_TERMS_PKG.MODIFY_ROW (+)');

 UPDATE pn_payment_terms_all
 SET changed_flag = x_changed_flag
 WHERE payment_term_id = NVL(x_payment_term_id ,payment_term_id )
 AND var_rent_inv_id = x_var_rent_inv_id;

pnp_debug_pkg.debug ('PNT_PAYMENT_TERMS_PKG.MODIFY_ROW (-)');

EXCEPTION
  WHEN others THEN
    NULL;
END MODIFY_ROW;



END PNT_PAYMENT_TERMS_PKG;

/
