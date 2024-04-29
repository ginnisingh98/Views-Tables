--------------------------------------------------------
--  DDL for Package PN_TERM_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_TERM_TEMPLATES_PKG" AUTHID CURRENT_USER AS
-- $Header: PNTTRMTS.pls 120.2 2005/07/26 05:17:27 appldev ship $

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
| 13-JUN-02  Daniel Thota   o Added x_org_id as an IN parameter in the
|                             INSERT_ROW check_unq_term_template
|                             procedures for Shared Srevices Project
| 05-AUG-02  Mrinal Misra   o Added x_location_id parameter.
| 19-AUG-02  Mrinal Misra   o Added check file command.
| 18-MAY-04  ftanudja       o Add logic for term template type. 3539408.
| 05-Jul-05  sdmahesh       o overloaded delete_row proc to take PK as parameter
+===========================================================================*/
/**** SPECIFICATIONS ****/
------------------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
------------------------------------------------------------------------
   PROCEDURE insert_row (
      x_rowid                    IN OUT NOCOPY   VARCHAR2
     ,x_term_template_id         IN OUT NOCOPY   NUMBER
     ,x_name                     IN       VARCHAR2
     ,x_set_of_books_id          IN       NUMBER
     ,x_currency_code            IN       VARCHAR2
     ,x_last_update_date         IN       DATE
     ,x_last_updated_by          IN       NUMBER
     ,x_creation_date            IN       DATE
     ,x_created_by               IN       NUMBER
     ,x_normalize                IN       VARCHAR2
     ,x_schedule_day             IN       NUMBER
     ,x_payment_purpose_code     IN       VARCHAR2
     ,x_payment_term_type_code   IN       VARCHAR2
     ,x_accrual_account_id       IN       NUMBER
     ,x_project_id               IN       NUMBER
     ,x_task_id                  IN       NUMBER
     ,x_organization_id          IN       NUMBER
     ,x_expenditure_type         IN       VARCHAR2
     ,x_expenditure_item_date    IN       DATE
     ,x_vendor_id                IN       NUMBER
     ,x_vendor_site_id           IN       NUMBER
     ,x_customer_id              IN       NUMBER
     ,x_customer_site_use_id     IN       NUMBER
     ,x_cust_ship_site_id        IN       NUMBER
     ,x_ap_ar_term_id            IN       NUMBER
     ,x_cust_trx_type_id         IN       NUMBER
     ,x_tax_group_id             IN       NUMBER
     ,x_tax_code_id              IN       NUMBER
     ,x_tax_classification_code  IN       VARCHAR2
     ,x_distribution_set_id      IN       NUMBER
     ,x_inv_rule_id              IN       NUMBER
     ,x_account_rule_id          IN       NUMBER
     ,x_salesrep_id              IN       NUMBER
     ,x_tax_included             IN       VARCHAR2
     ,x_po_header_id             IN       NUMBER
     ,x_cust_po_number           IN       VARCHAR2
     ,x_receipt_method_id        IN       NUMBER
     ,x_location_id              IN       NUMBER
     ,x_active                   IN       VARCHAR2
     ,x_description              IN       VARCHAR2
     ,x_term_template_type       IN       VARCHAR2
     ,x_last_update_login        IN       NUMBER
     ,x_attribute_category       IN       VARCHAR2
     ,x_attribute1               IN       VARCHAR2
     ,x_attribute2               IN       VARCHAR2
     ,x_attribute3               IN       VARCHAR2
     ,x_attribute4               IN       VARCHAR2
     ,x_attribute5               IN       VARCHAR2
     ,x_attribute6               IN       VARCHAR2
     ,x_attribute7               IN       VARCHAR2
     ,x_attribute8               IN       VARCHAR2
     ,x_attribute9               IN       VARCHAR2
     ,x_attribute10              IN       VARCHAR2
     ,x_attribute11              IN       VARCHAR2
     ,x_attribute12              IN       VARCHAR2
     ,x_attribute13              IN       VARCHAR2
     ,x_attribute14              IN       VARCHAR2
     ,x_attribute15              IN       VARCHAR2
     ,x_org_id                            NUMBER default NULL
   );


------------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
------------------------------------------------------------------------
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
   );


------------------------------------------------------------------------
-- PROCEDURE : LOCK_ROW
------------------------------------------------------------------------
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
   );


------------------------------------------------------------------------
-- PROCEDURE : DELETE_ROW
------------------------------------------------------------------------
   PROCEDURE delete_row (
      x_rowid   IN   VARCHAR2
   );

------------------------------------------------------------------------
-- PROCEDURE : DELETE_ROW
------------------------------------------------------------------------
   PROCEDURE delete_row (
      x_term_template_id   IN NUMBER
   );


---------------------------------------------------------------------------
-- PROCEDURE : check Unique template name
------------------------------------------------------------------------
   PROCEDURE check_unq_term_template (
      x_return_status      IN OUT NOCOPY   VARCHAR2
     ,x_term_template_id   IN       NUMBER
     ,x_name               IN       VARCHAR2
     ,x_org_id             IN       NUMBER default NULL
   );
END pn_term_templates_pkg;

 

/
