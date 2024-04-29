--------------------------------------------------------
--  DDL for Package Body PN_TERM_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_TERM_TEMPLATES_PKG" AS
-- $Header: PNTTRMTB.pls 120.4 2005/12/01 08:35:18 appldev ship $


/*============================================================================+
|                Copyright (c) 2001 Oracle Corporation
|                   Redwood Shores, California, USA
|                        All rights reserved.
| DESCRIPTION
|
|  These procedures consist are used a table handlers for the PN_TERM_TEMPLATES table.
|  They include:
|         INSERT_ROW - insert a row into PN_TERM_TEMPLATES.
|         DELETE_ROW - deletes a row from PN_TERM_TEMPLATES.
|         UPDATE_ROW - updates a row from PN_TERM_TEMPLATES.
|         LOCKS_ROW - will check if a row has been modified since being queried by form.
|
|
| HISTORY
| 08-MAY-01  jbreyes        o Created
| 13-DEC-01  Mrinal Misra   o Added dbdrv command.
| 15-JAN-02  Mrinal Misra   o In dbdrv command changed phase=pls to phase=plb.
|                             Added checkfile.Ref. Bug# 2184724.
| 05-JUN-02  Daniel Thota   o Added org_id as a parameter to insert_row
|                             as part of Multi-Org
| 20-JUL-02  Mrinal Misra   o Changed lock_row procedure for currency_code made
|                             null column in base table.
| 05-AUG-02  Mrinal Misra   o Added x_location_id parameter for location_id
|                             column in table.
| 18-MAY-04  ftanudja       o Add logic for term template type. 3539408.
| 15-JUL-2005  ftanudja       o R12: add tax_classification_code. 4495054.
| 25-Jul-05  sdmahesh       o overloaded delete_row proc to take PK as parameter
+===========================================================================*/

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 13-JUL-05 sdmahesh o Bug 4284035 - Replaced pn_term_templates with _ALL
--                      table.
-------------------------------------------------------------------------------
PROCEDURE insert_row (
   x_rowid                     IN OUT NOCOPY    VARCHAR2
   ,x_term_template_id         IN OUT NOCOPY    NUMBER
   ,x_name                     IN               VARCHAR2
   ,x_set_of_books_id          IN               NUMBER
   ,x_currency_code            IN               VARCHAR2
   ,x_last_update_date         IN               DATE
   ,x_last_updated_by          IN               NUMBER
   ,x_creation_date            IN               DATE
   ,x_created_by               IN               NUMBER
   ,x_normalize                IN               VARCHAR2
   ,x_schedule_day             IN               NUMBER
   ,x_payment_purpose_code     IN               VARCHAR2
   ,x_payment_term_type_code   IN               VARCHAR2
   ,x_accrual_account_id       IN               NUMBER
   ,x_project_id               IN               NUMBER
   ,x_task_id                  IN               NUMBER
   ,x_organization_id          IN               NUMBER
   ,x_expenditure_type         IN               VARCHAR2
   ,x_expenditure_item_date    IN               DATE
   ,x_vendor_id                IN               NUMBER
   ,x_vendor_site_id           IN               NUMBER
   ,x_customer_id              IN               NUMBER
   ,x_customer_site_use_id     IN               NUMBER
   ,x_cust_ship_site_id        IN               NUMBER
   ,x_ap_ar_term_id            IN               NUMBER
   ,x_cust_trx_type_id         IN               NUMBER
   ,x_tax_group_id             IN               NUMBER
   ,x_tax_code_id              IN               NUMBER
   ,x_tax_classification_code  IN               VARCHAR2
   ,x_distribution_set_id      IN               NUMBER
   ,x_inv_rule_id              IN               NUMBER
   ,x_account_rule_id          IN               NUMBER
   ,x_salesrep_id              IN               NUMBER
   ,x_tax_included             IN               VARCHAR2
   ,x_po_header_id             IN               NUMBER
   ,x_cust_po_number           IN               VARCHAR2
   ,x_receipt_method_id        IN               NUMBER
   ,x_location_id              IN               NUMBER
   ,x_active                   IN               VARCHAR2
   ,x_description              IN               VARCHAR2
   ,x_term_template_type       IN               VARCHAR2
   ,x_last_update_login        IN               NUMBER
   ,x_attribute_category       IN               VARCHAR2
   ,x_attribute1               IN               VARCHAR2
   ,x_attribute2               IN               VARCHAR2
   ,x_attribute3               IN               VARCHAR2
   ,x_attribute4               IN               VARCHAR2
   ,x_attribute5               IN               VARCHAR2
   ,x_attribute6               IN               VARCHAR2
   ,x_attribute7               IN               VARCHAR2
   ,x_attribute8               IN               VARCHAR2
   ,x_attribute9               IN               VARCHAR2
   ,x_attribute10              IN               VARCHAR2
   ,x_attribute11              IN               VARCHAR2
   ,x_attribute12              IN               VARCHAR2
   ,x_attribute13              IN               VARCHAR2
   ,x_attribute14              IN               VARCHAR2
   ,x_attribute15              IN               VARCHAR2
   ,x_org_id                                    NUMBER
)
IS
   CURSOR c IS
      SELECT ROWID
      FROM pn_term_templates_all
      WHERE term_template_id = x_term_template_id;

   l_return_status   VARCHAR2 (30) := NULL;
   l_rowid           VARCHAR2 (18) := NULL;
BEGIN

   --PNP_DEBUG_PKG.debug (' PN_TERM_TEMPLATES_PKG.insert_row (+)');
   -- If no TERM_TEMPLATE_ID is provided, get one from sequence

   pn_term_templates_pkg.check_unq_term_template (
      l_return_status
     ,x_term_template_id
     ,x_name
     ,x_org_id
   );

   IF (l_return_status IS NOT NULL) THEN
      app_exception.raise_exception;
   END IF;


   -- IF (l_return_status IS NOT NULL) THEN APP_EXCEPTION.Raise_Exception; END IF;
   INSERT INTO pn_term_templates_all
   (
       term_template_id
      ,name
      ,set_of_books_id
      ,currency_code
      ,last_update_date
      ,last_updated_by
      ,creation_date
      ,created_by
      ,normalize
      ,schedule_day
      ,payment_purpose_code
      ,payment_term_type_code
      ,accrual_account_id
      ,project_id
      ,task_id
      ,organization_id
      ,expenditure_type
      ,expenditure_item_date
      ,vendor_id
      ,vendor_site_id
      ,customer_id
      ,customer_site_use_id
      ,cust_ship_site_id
      ,ap_ar_term_id
      ,cust_trx_type_id
      ,tax_group_id
      ,tax_code_id
      ,tax_classification_code
      ,distribution_set_id
      ,inv_rule_id
      ,account_rule_id
      ,salesrep_id
      ,tax_included
      ,po_header_id
      ,cust_po_number
      ,receipt_method_id
      ,location_id
      ,active
      ,description
      ,term_template_type
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
      ,org_id
   )
   VALUES
   (
      NVL(x_term_template_id,pn_term_templates_s.NEXTVAL)
      ,x_name
      ,x_set_of_books_id
      ,x_currency_code
      ,x_last_update_date
      ,x_last_updated_by
      ,x_creation_date
      ,x_created_by
      ,x_normalize
      ,x_schedule_day
      ,x_payment_purpose_code
      ,x_payment_term_type_code
      ,x_accrual_account_id
      ,x_project_id
      ,x_task_id
      ,x_organization_id
      ,x_expenditure_type
      ,x_expenditure_item_date
      ,x_vendor_id
      ,x_vendor_site_id
      ,x_customer_id
      ,x_customer_site_use_id
      ,x_cust_ship_site_id
      ,x_ap_ar_term_id
      ,x_cust_trx_type_id
      ,x_tax_group_id
      ,x_tax_code_id
      ,x_tax_classification_code
      ,x_distribution_set_id
      ,x_inv_rule_id
      ,x_account_rule_id
      ,x_salesrep_id
      ,x_tax_included
      ,x_po_header_id
      ,x_cust_po_number
      ,x_receipt_method_id
      ,x_location_id
      ,x_active
      ,x_description
      ,x_term_template_type
      ,x_last_update_login
      ,x_attribute_category
      ,x_attribute1
      ,x_attribute2
      ,x_attribute3
      ,x_attribute4
      ,x_attribute5
      ,x_attribute6
      ,x_attribute7
      ,x_attribute8
      ,x_attribute9
      ,x_attribute10
      ,x_attribute11
      ,x_attribute12
      ,x_attribute13
      ,x_attribute14
      ,x_attribute15
      ,x_org_id
   )
   RETURNING term_template_id INTO x_term_template_id;

   -- Check if a valid record was created.
   OPEN c;
   FETCH c INTO x_rowid;

   IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
   END IF;

   CLOSE c;

   --PNP_DEBUG_PKG.debug (' PN_TERM_TEMPLATES_PKG.insert_row (-)');
END insert_row;


-------------------------------------------------------------------------------
-- PROCDURE     : update_row
-- INVOKED FROM : update_row procedure
-- PURPOSE      : upadtes the row
-- HISTORY      :
-- 13-JUL-05 sdmahesh o Bug 4284035 - Replaced pn_term_templates with _ALL
--                      table.Also changed the where clause for update stmt.
-------------------------------------------------------------------------------
PROCEDURE update_row (
    x_rowid                    IN   VARCHAR2
   ,x_term_template_id         IN   NUMBER
   ,x_name                     IN   VARCHAR2
   ,x_set_of_books_id          IN   NUMBER
   ,x_currency_code            IN   VARCHAR2
   ,x_last_update_date         IN   DATE
   ,x_last_updated_by          IN   NUMBER
   ,x_normalize                IN   VARCHAR2
   ,x_schedule_day             IN   NUMBER
   ,x_payment_purpose_code     IN   VARCHAR2
   ,x_payment_term_type_code   IN   VARCHAR2
   ,x_accrual_account_id       IN   NUMBER
   ,x_project_id               IN   NUMBER
   ,x_task_id                  IN   NUMBER
   ,x_organization_id          IN   NUMBER
   ,x_expenditure_type         IN   VARCHAR2
   ,x_expenditure_item_date    IN   DATE
   ,x_vendor_id                IN   NUMBER
   ,x_vendor_site_id           IN   NUMBER
   ,x_customer_id              IN   NUMBER
   ,x_customer_site_use_id     IN   NUMBER
   ,x_cust_ship_site_id        IN   NUMBER
   ,x_ap_ar_term_id            IN   NUMBER
   ,x_cust_trx_type_id         IN   NUMBER
   ,x_tax_group_id             IN   NUMBER
   ,x_tax_code_id              IN   NUMBER
   ,x_tax_classification_code  IN   VARCHAR2
   ,x_distribution_set_id      IN   NUMBER
   ,x_inv_rule_id              IN   NUMBER
   ,x_account_rule_id          IN   NUMBER
   ,x_salesrep_id              IN   NUMBER
   ,x_tax_included             IN   VARCHAR2
   ,x_po_header_id             IN   NUMBER
   ,x_cust_po_number           IN   VARCHAR2
   ,x_receipt_method_id        IN   NUMBER
   ,x_location_id              IN   NUMBER
   ,x_active                   IN   VARCHAR2
   ,x_description              IN   VARCHAR2
   ,x_term_template_type       IN   VARCHAR2
   ,x_last_update_login        IN   NUMBER
   ,x_attribute_category       IN   VARCHAR2
   ,x_attribute1               IN   VARCHAR2
   ,x_attribute2               IN   VARCHAR2
   ,x_attribute3               IN   VARCHAR2
   ,x_attribute4               IN   VARCHAR2
   ,x_attribute5               IN   VARCHAR2
   ,x_attribute6               IN   VARCHAR2
   ,x_attribute7               IN   VARCHAR2
   ,x_attribute8               IN   VARCHAR2
   ,x_attribute9               IN   VARCHAR2
   ,x_attribute10              IN   VARCHAR2
   ,x_attribute11              IN   VARCHAR2
   ,x_attribute12              IN   VARCHAR2
   ,x_attribute13              IN   VARCHAR2
   ,x_attribute14              IN   VARCHAR2
   ,x_attribute15              IN   VARCHAR2
)
IS
   l_return_status   VARCHAR2 (30) := NULL;
   l_org_id          NUMBER;
BEGIN

   --PNP_DEBUG_PKG.debug (' PN_TERM_TEMPLATES_PKG.update_row (+)');

   SELECT org_id
   INTO l_org_id
   FROM pn_term_templates_all
   WHERE term_template_id = x_term_template_id;

   pn_term_templates_pkg.check_unq_term_template (
                                                    l_return_status
                                                   ,x_term_template_id
                                                   ,x_name
                                                   ,l_org_id
                                                   );

   IF (l_return_status IS NOT NULL) THEN
      app_exception.raise_exception;
   END IF;

   UPDATE pn_term_templates_all
   SET name = x_name
   ,set_of_books_id = x_set_of_books_id
   ,currency_code = x_currency_code
   ,last_update_date = x_last_update_date
   ,last_updated_by = x_last_updated_by
   ,normalize = x_normalize
   ,schedule_day = x_schedule_day
   ,payment_purpose_code = x_payment_purpose_code
   ,payment_term_type_code = x_payment_term_type_code
   ,accrual_account_id = x_accrual_account_id
   ,project_id = x_project_id
   ,task_id = x_task_id
   ,organization_id = x_organization_id
   ,expenditure_type = x_expenditure_type
   ,expenditure_item_date = x_expenditure_item_date
   ,vendor_id = x_vendor_id
   ,vendor_site_id = x_vendor_site_id
   ,customer_id = x_customer_id
   ,customer_site_use_id = x_customer_site_use_id
   ,cust_ship_site_id = x_cust_ship_site_id
   ,ap_ar_term_id = x_ap_ar_term_id
   ,cust_trx_type_id = x_cust_trx_type_id
   ,tax_group_id = x_tax_group_id
   ,tax_code_id = x_tax_code_id
   ,tax_classification_code = x_tax_classification_code
   ,distribution_set_id = x_distribution_set_id
   ,inv_rule_id = x_inv_rule_id
   ,account_rule_id = x_account_rule_id
   ,salesrep_id = x_salesrep_id
   ,tax_included = x_tax_included
   ,po_header_id = x_po_header_id
   ,cust_po_number = x_cust_po_number
   ,receipt_method_id = x_receipt_method_id
   ,location_id = x_location_id
   ,active = x_active
   ,description = x_description
   ,term_template_type = x_term_template_type
   ,last_update_login = x_last_update_login
   ,attribute_category = x_attribute_category
   ,attribute1 = x_attribute1
   ,attribute2 = x_attribute2
   ,attribute3 = x_attribute3
   ,attribute4 = x_attribute4
   ,attribute5 = x_attribute5
   ,attribute6 = x_attribute6
   ,attribute7 = x_attribute7
   ,attribute8 = x_attribute8
   ,attribute9 = x_attribute9
   ,attribute10 = x_attribute10
   ,attribute11 = x_attribute11
   ,attribute12 = x_attribute12
   ,attribute13 = x_attribute13
   ,attribute14 = x_attribute14
   ,attribute15 = x_attribute15
   WHERE term_template_id = x_term_template_id;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   --PNP_DEBUG_PKG.debug (' PN_TERM_TEMPLATES_PKG.update_row (-)');
END update_row;


-------------------------------------------------------------------------------
-- PROCDURE     : lock_row
-- INVOKED FROM : lock_row procedure
-- PURPOSE      : locks the row
-- HISTORY      :
-- 13-JUL-05 sdmahesh o Bug 4284035 - Replaced pn_term_templates with _ALL
--                      table.Also changed the where clause in cursor
-------------------------------------------------------------------------------
PROCEDURE lock_row (
   x_rowid                    IN   VARCHAR2
  ,x_term_template_id         IN   NUMBER
  ,x_name                     IN   VARCHAR2
  ,x_set_of_books_id          IN   NUMBER
  ,x_currency_code            IN   VARCHAR2
  ,x_normalize                IN   VARCHAR2
  ,x_schedule_day             IN   NUMBER
  ,x_payment_purpose_code     IN   VARCHAR2
  ,x_payment_term_type_code   IN   VARCHAR2
  ,x_accrual_account_id       IN   NUMBER
  ,x_project_id               IN   NUMBER
  ,x_task_id                  IN   NUMBER
  ,x_organization_id          IN   NUMBER
  ,x_expenditure_type         IN   VARCHAR2
  ,x_expenditure_item_date    IN   DATE
  ,x_vendor_id                IN   NUMBER
  ,x_vendor_site_id           IN   NUMBER
  ,x_customer_id              IN   NUMBER
  ,x_customer_site_use_id     IN   NUMBER
  ,x_cust_ship_site_id        IN   NUMBER
  ,x_ap_ar_term_id            IN   NUMBER
  ,x_cust_trx_type_id         IN   NUMBER
  ,x_tax_group_id             IN   NUMBER
  ,x_tax_code_id              IN   NUMBER
  ,x_tax_classification_code  IN   VARCHAR2
  ,x_distribution_set_id      IN   NUMBER
  ,x_inv_rule_id              IN   NUMBER
  ,x_account_rule_id          IN   NUMBER
  ,x_salesrep_id              IN   NUMBER
  ,x_tax_included             IN   VARCHAR2
  ,x_po_header_id             IN   NUMBER
  ,x_cust_po_number           IN   VARCHAR2
  ,x_receipt_method_id        IN   NUMBER
  ,x_location_id              IN   NUMBER
  ,x_active                   IN   VARCHAR2
  ,x_description              IN   VARCHAR2
  ,x_attribute_category       IN   VARCHAR2
  ,x_attribute1               IN   VARCHAR2
  ,x_attribute2               IN   VARCHAR2
  ,x_attribute3               IN   VARCHAR2
  ,x_attribute4               IN   VARCHAR2
  ,x_attribute5               IN   VARCHAR2
  ,x_attribute6               IN   VARCHAR2
  ,x_attribute7               IN   VARCHAR2
  ,x_attribute8               IN   VARCHAR2
  ,x_attribute9               IN   VARCHAR2
  ,x_attribute10              IN   VARCHAR2
  ,x_attribute11              IN   VARCHAR2
  ,x_attribute12              IN   VARCHAR2
  ,x_attribute13              IN   VARCHAR2
  ,x_attribute14              IN   VARCHAR2
  ,x_attribute15              IN   VARCHAR2
) IS
   CURSOR c1 IS
      SELECT *
      FROM pn_term_templates_all
      WHERE term_template_id  = x_term_template_id
      FOR UPDATE OF term_template_id NOWAIT;

   tlinfo   c1%ROWTYPE;

BEGIN

   PNP_DEBUG_PKG.debug (' PN_TERM_TEMPLATES_PKG.lock_row (+)');

   OPEN c1;
   FETCH c1 INTO tlinfo;

   IF (c1%NOTFOUND) THEN
      CLOSE c1;
      RETURN;
   END IF;

   CLOSE c1;

   IF NOT (tlinfo.term_template_id = x_term_template_id ) THEN
      pn_var_rent_pkg.lock_row_exception('TERM_TEMPLATE_ID',tlinfo.term_template_id);
   END IF;

   IF NOT (tlinfo.name = x_name ) THEN
      pn_var_rent_pkg.lock_row_exception('NAME',tlinfo.name);
   END IF;

   IF NOT (tlinfo.set_of_books_id = x_set_of_books_id ) THEN
      pn_var_rent_pkg.lock_row_exception('SET_OF_BOOKS_ID',tlinfo.set_of_books_id);
   END IF;

   IF NOT ((tlinfo.currency_code = x_currency_code ) OR
           (tlinfo.currency_code = null) AND (x_currency_code = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('CURRENCY_CODE',tlinfo.currency_code);
   END IF;

   IF NOT ((tlinfo.normalize = x_normalize ) OR
           (tlinfo.normalize = null) AND (x_normalize = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('NORMALIZE',tlinfo.normalize);
   END IF;

   IF NOT ((tlinfo.schedule_day = x_schedule_day ) OR
           (tlinfo.schedule_day = null) AND (x_schedule_day = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('SCHEDULE_DAY',tlinfo.schedule_day);
   END IF;

   IF NOT ((tlinfo.payment_purpose_code = x_payment_purpose_code ) OR
           (tlinfo.payment_purpose_code = null) AND (x_payment_purpose_code = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('PAYMENT_PURPOSE_CODE',tlinfo.payment_purpose_code);
   END IF;

   IF NOT ((tlinfo.payment_term_type_code = x_payment_term_type_code ) OR
           (tlinfo.payment_term_type_code = null) AND (x_payment_term_type_code = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('PAYMENT_TERM_TYPE_CODE',tlinfo.payment_term_type_code);
   END IF;

   IF NOT ((tlinfo.accrual_account_id = x_accrual_account_id ) OR
           (tlinfo.accrual_account_id = null) AND (x_accrual_account_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ACCRUAL_ACCOUNT_ID',tlinfo.accrual_account_id);
   END IF;

   IF NOT ((tlinfo.project_id = x_project_id ) OR
           (tlinfo.project_id = null) AND (x_project_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('PROJECT_ID',tlinfo.project_id);
   END IF;

   IF NOT ((tlinfo.task_id = x_task_id ) OR
           (tlinfo.task_id = null) AND (x_task_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('TASK_ID',tlinfo.task_id);
   END IF;

   IF NOT ((tlinfo.organization_id = x_organization_id ) OR
           (tlinfo.organization_id = null) AND (x_organization_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ORGANIZATION_ID',tlinfo.organization_id);
   END IF;

   IF NOT ((tlinfo.expenditure_type = x_expenditure_type ) OR
           (tlinfo.expenditure_type = null) AND (x_expenditure_type = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('EXPENDITURE_TYPE',tlinfo.expenditure_type);
   END IF;

   IF NOT ((tlinfo.expenditure_item_date = x_expenditure_item_date ) OR
           (tlinfo.expenditure_item_date = null) AND (x_expenditure_item_date = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('EXPENDITURE_ITEM_DATE',tlinfo.expenditure_item_date);
   END IF;

   IF NOT ((tlinfo.vendor_id = x_vendor_id ) OR
           (tlinfo.vendor_id = null) AND (x_vendor_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('VENDOR_ID',tlinfo.vendor_id);
   END IF;

   IF NOT ((tlinfo.vendor_site_id = x_vendor_site_id ) OR
           (tlinfo.vendor_site_id = null) AND (x_vendor_site_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('VENDOR_SITE_ID',tlinfo.vendor_site_id);
   END IF;

   IF NOT ((tlinfo.customer_id = x_customer_id ) OR
           (tlinfo.customer_id = null) AND (x_customer_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('CUSTOMER_ID',tlinfo.customer_id);
   END IF;

   IF NOT ((tlinfo.customer_site_use_id = x_customer_site_use_id ) OR
           (tlinfo.customer_site_use_id = null) AND (x_customer_site_use_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('CUSTOMER_SITE_USE_ID',tlinfo.customer_site_use_id);
   END IF;

   IF NOT ((tlinfo.cust_ship_site_id = x_cust_ship_site_id ) OR
           (tlinfo.cust_ship_site_id = null) AND (x_cust_ship_site_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('CUST_SHIP_SITE_ID',tlinfo.cust_ship_site_id);
   END IF;

   IF NOT ((tlinfo.ap_ar_term_id = x_ap_ar_term_id ) OR
           (tlinfo.ap_ar_term_id = null) AND (x_ap_ar_term_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('AP_AR_TERM_ID',tlinfo.ap_ar_term_id);
   END IF;

   IF NOT ((tlinfo.cust_trx_type_id = x_cust_trx_type_id ) OR
           (tlinfo.cust_trx_type_id = null) AND (x_cust_trx_type_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('CUST_TRX_TYPE_ID',tlinfo.cust_trx_type_id);
   END IF;

   IF pn_r12_util_pkg.is_r12 AND
      NOT ((tlinfo.tax_classification_code = x_tax_classification_code ) OR
           (tlinfo.tax_classification_code = null) AND (x_tax_classification_code = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('TAX_CLASSIFICATION_CODE',tlinfo.tax_classification_code);
   END IF;

   IF NOT pn_r12_util_pkg.is_r12 AND
      NOT ((tlinfo.tax_group_id = x_tax_group_id ) OR
           (tlinfo.tax_group_id = null) AND (x_tax_group_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('TAX_GROUP_ID',tlinfo.tax_group_id);
   END IF;

   IF NOT pn_r12_util_pkg.is_r12 AND
      NOT ((tlinfo.tax_code_id = x_tax_code_id ) OR
           (tlinfo.tax_code_id = null) AND (x_tax_code_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('TAX_CODE_ID',tlinfo.tax_code_id);
   END IF;

   IF NOT ((tlinfo.distribution_set_id = x_distribution_set_id ) OR
           (tlinfo.distribution_set_id = null) AND (x_distribution_set_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('DISTRIBUTION_SET_ID',tlinfo.distribution_set_id);
   END IF;

   IF NOT ((tlinfo.inv_rule_id = x_inv_rule_id ) OR
           (tlinfo.inv_rule_id = null) AND (x_inv_rule_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('INV_RULE_ID',tlinfo.inv_rule_id);
   END IF;

   IF NOT ((tlinfo.account_rule_id = x_account_rule_id ) OR
           (tlinfo.account_rule_id = null) AND (x_account_rule_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ACCOUNT_RULE_ID',tlinfo.account_rule_id);
   END IF;

   IF NOT ((tlinfo.salesrep_id = x_salesrep_id ) OR
           (tlinfo.salesrep_id = null) AND (x_salesrep_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('SALESREP_ID',tlinfo.salesrep_id);
   END IF;

   IF NOT ((tlinfo.tax_included = x_tax_included ) OR
           (tlinfo.tax_included = null) AND (x_tax_included = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('TAX_INCLUDED',tlinfo.tax_included);
   END IF;

   IF NOT ((tlinfo.po_header_id = x_po_header_id ) OR
           (tlinfo.po_header_id = null) AND (x_po_header_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('PO_HEADER_ID',tlinfo.po_header_id);
   END IF;

   IF NOT ((tlinfo.cust_po_number = x_cust_po_number ) OR
           (tlinfo.cust_po_number = null) AND (x_cust_po_number = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('CUST_PO_NUMBER',tlinfo.cust_po_number);
   END IF;

   IF NOT ((tlinfo.receipt_method_id = x_receipt_method_id ) OR
           (tlinfo.receipt_method_id = null) AND (x_receipt_method_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('RECEIPT_METHOD_ID',tlinfo.receipt_method_id);
   END IF;

   IF NOT ((tlinfo.active = x_active ) OR
           (tlinfo.active = null) AND (x_active = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ACTIVE',tlinfo.active);
   END IF;

   IF NOT ((tlinfo.description = x_description ) OR
           (tlinfo.description = null) AND (x_description = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('DESCRIPTION',tlinfo.description);
   END IF;

   IF NOT ((tlinfo.location_id = x_location_id ) OR
           (tlinfo.location_id = null) AND (x_location_id = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('LOCATION_ID',tlinfo.location_id);
   END IF;

   IF NOT ((tlinfo.attribute_category = x_attribute_category ) OR
           (tlinfo.attribute_category = null) AND (x_attribute_category = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE_CATEGORY',tlinfo.attribute_category);
   END IF;

   IF NOT ((tlinfo.attribute1 = x_attribute1 ) OR
           (tlinfo.attribute1 = null) AND (x_attribute1 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE1',tlinfo.attribute1);
   END IF;

   IF NOT ((tlinfo.attribute2 = x_attribute2 ) OR
           (tlinfo.attribute2 = null) AND (x_attribute2 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE2',tlinfo.attribute2);
   END IF;

   IF NOT ((tlinfo.attribute3 = x_attribute3 ) OR
           (tlinfo.attribute3 = null) AND (x_attribute3 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE3',tlinfo.attribute3);
   END IF;

   IF NOT ((tlinfo.attribute4 = x_attribute4 ) OR
           (tlinfo.attribute4 = null) AND (x_attribute4 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE4',tlinfo.attribute4);
   END IF;

   IF NOT ((tlinfo.attribute5 = x_attribute5 ) OR
           (tlinfo.attribute5 = null) AND (x_attribute5 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE5',tlinfo.attribute5);
   END IF;

   IF NOT ((tlinfo.attribute6 = x_attribute6 ) OR
           (tlinfo.attribute6 = null) AND (x_attribute6 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE6',tlinfo.attribute6);
   END IF;

   IF NOT ((tlinfo.attribute7 = x_attribute7 ) OR
           (tlinfo.attribute7 = null) AND (x_attribute7 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE7',tlinfo.attribute7);
   END IF;

   IF NOT ((tlinfo.attribute8 = x_attribute8 ) OR
           (tlinfo.attribute8 = null) AND (x_attribute8 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE8',tlinfo.attribute8);
   END IF;

   IF NOT ((tlinfo.attribute9 = x_attribute9 ) OR
           (tlinfo.attribute9 = null) AND (x_attribute9 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE9',tlinfo.attribute9);
   END IF;

   IF NOT ((tlinfo.attribute10 = x_attribute10 ) OR
           (tlinfo.attribute10 = null) AND (x_attribute10 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE10',tlinfo.attribute10);
   END IF;

   IF NOT ((tlinfo.attribute11 = x_attribute11 ) OR
           (tlinfo.attribute11 = null) AND (x_attribute11 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE11',tlinfo.attribute11);
   END IF;

   IF NOT ((tlinfo.attribute12 = x_attribute12 ) OR
           (tlinfo.attribute12 = null) AND (x_attribute12 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE12',tlinfo.attribute12);
   END IF;

   IF NOT ((tlinfo.attribute13 = x_attribute13 ) OR
           (tlinfo.attribute13 = null) AND (x_attribute13 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE13',tlinfo.attribute13);
   END IF;

   IF NOT ((tlinfo.attribute14 = x_attribute14 ) OR
           (tlinfo.attribute14 = null) AND (x_attribute14 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE14',tlinfo.attribute14);
   END IF;

   IF NOT ((tlinfo.attribute15 = x_attribute15 ) OR
           (tlinfo.attribute15 = null) AND (x_attribute15 = null))
   THEN
      pn_var_rent_pkg.lock_row_exception('ATTRIBUTE15',tlinfo.attribute15);
   END IF;

   PNP_DEBUG_PKG.debug (' PN_TERM_TEMPLATES_PKG.lock_row (-)');

END lock_row;

-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 21-JUN-05  sdmahesh o Bug 4284035 - Replaced pn_term_templates with _ALL table.
-------------------------------------------------------------------------------
PROCEDURE delete_row
(
   x_rowid   IN   VARCHAR2
)
IS
BEGIN

   DELETE FROM pn_term_templates_all
   WHERE ROWID = x_rowid;

   IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
   END IF;

END delete_row;

-------------------------------------------------------------------------------
-- PROCDURE     : delete_row
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- NOTE         : overloaded this procedure to take PK as In parameter
-- HISTORY      :
-- 21-JUN-05  piagrawa o Bug 4284035 - Created
-------------------------------------------------------------------------------
PROCEDURE delete_row
(
   x_term_template_id IN NUMBER
)
IS
BEGIN

   DELETE FROM pn_term_templates_all
   WHERE term_template_id = x_term_template_id;

   IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
   END IF;
END delete_row;

-------------------------------------------------------------------------------
-- PROCDURE     : check_unq_term_template
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : checks unique term template
-- HISTORY      :
-- 13-JUL-05 sdmahesh o Bug 4284035 - Replaced pn_term_templates with _ALL
--                      table.
-------------------------------------------------------------------------------
PROCEDURE check_unq_term_template
(
    x_return_status      IN OUT NOCOPY   VARCHAR2
   ,x_term_template_id   IN              NUMBER
   ,x_name               IN              VARCHAR2
   ,x_org_id             IN              NUMBER
)
IS
   l_dummy   NUMBER;
BEGIN
   SELECT 1
   INTO l_dummy
   FROM DUAL
   WHERE NOT EXISTS ( SELECT 1
                      FROM   pn_term_templates_all
                      WHERE name = x_name
                      AND   ((x_term_template_id IS NULL)
                      OR (term_template_id <> x_term_template_id)
                      AND   org_id = x_org_id
                      ));
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
      fnd_message.set_name ('PN', 'PN_DUP_TERM_TEMPLATE');

      --         fnd_message.set_token ('NAME', x_name);
      x_return_status := 'E';
END check_unq_term_template;

END pn_term_templates_pkg;

/
