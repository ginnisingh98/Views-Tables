--------------------------------------------------------
--  DDL for Package PN_LEASES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_LEASES_PKG" AUTHID CURRENT_USER AS
-- $Header: PNTLEASS.pls 120.1.12010000.2 2009/05/26 07:09:54 rthumma ship $
------------------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
-- HISTORY   : Modified    19-MAR-2002   lkatputu
--           : Added Send_Entries into the table handler
--             as per the 'DO NOT SEND' enhancement requirement.
------------------------------------------------------------------------
PROCEDURE Insert_Row
        (
                x_rowid                         IN OUT NOCOPY VARCHAR2,
                x_lease_id                      IN OUT NOCOPY NUMBER,
                x_lease_change_id               IN OUT NOCOPY NUMBER,
                x_lease_detail_id               IN OUT NOCOPY NUMBER,
                x_name                          IN     VARCHAR2,
                x_lease_num                     IN OUT NOCOPY VARCHAR2,
                x_parent_lease_id               IN     NUMBER,
                x_lease_type_code               IN     VARCHAR2,
                x_lease_class_code              IN     VARCHAR2,
                x_payment_term_proration_rule   IN     NUMBER,
                x_abstracted_by_user            IN     NUMBER,
                x_status                        IN     VARCHAR2,
                x_lease_status                  IN     VARCHAR2,
                x_creation_date                 IN     DATE,
                x_created_by                    IN     NUMBER,
                x_last_update_date              IN     DATE,
                x_last_updated_by               IN     NUMBER,
                x_last_update_login             IN     NUMBER,
                x_responsible_user              IN     NUMBER,
                x_expense_account_id            IN     NUMBER,
                x_accrual_account_id            IN     NUMBER,
                x_receivable_account_id         IN     NUMBER,
                x_term_template_id              IN     NUMBER    DEFAULT NULL,
                x_lease_commencement_date       IN     DATE,
                x_lease_termination_date        IN     DATE,
                x_lease_execution_date          IN     DATE,
                x_attribute_category            IN     VARCHAR2,
                x_attribute1                    IN     VARCHAR2,
                x_attribute2                    IN     VARCHAR2,
                x_attribute3                    IN     VARCHAR2,
                x_attribute4                    IN     VARCHAR2,
                x_attribute5                    IN     VARCHAR2,
                x_attribute6                    IN     VARCHAR2,
                x_attribute7                    IN     VARCHAR2,
                x_attribute8                    IN     VARCHAR2,
                x_attribute9                    IN     VARCHAR2,
                x_attribute10                   IN     VARCHAR2,
                x_attribute11                   IN     VARCHAR2,
                x_attribute12                   IN     VARCHAR2,
                x_attribute13                   IN     VARCHAR2,
                x_attribute14                   IN     VARCHAR2,
                x_attribute15                   IN     VARCHAR2,
                x_org_id                        IN     NUMBER,
                x_location_id                   IN     NUMBER,
                x_customer_id                   IN     NUMBER,
                x_grouping_rule_id              IN     NUMBER    DEFAULT NULL,
		x_calendar_year_start_date      IN     VARCHAR2  DEFAULT NULL  --Bug#7022608
        );

------------------------------------------------------------------------
-- PROCEDURE : LOCK_ROW
-- HISTORY   : Modified    19-MAR-2002   lkatputu
--           : Added Send_Entries into the table handler
--             as per the 'DO NOT SEND' enhancement requirement.
------------------------------------------------------------------------
PROCEDURE Lock_Row
        (
                x_lease_id                      IN     NUMBER,
                x_lease_detail_id               IN     NUMBER,
                x_lease_change_id               IN     NUMBER,
                x_name                          IN     VARCHAR2,
                x_lease_num                     IN     VARCHAR2,
                x_parent_lease_id               IN     NUMBER,
                x_lease_type_code               IN     VARCHAR2,
                x_lease_class_code              IN     VARCHAR2,
                x_payment_term_proration_rule   IN     NUMBER,
                x_abstracted_by_user            IN     NUMBER,
                x_status                        IN     VARCHAR2,
                x_lease_status                  IN     VARCHAR2,
                x_responsible_user              IN     NUMBER,
                x_expense_account_id            IN     NUMBER,
                x_accrual_account_id            IN     NUMBER,
                x_receivable_account_id         IN     NUMBER,
                x_term_template_id              IN     NUMBER,
                x_lease_commencement_date       IN     DATE,
                x_lease_termination_date        IN     DATE,
                x_lease_execution_date          IN     DATE,
                x_attribute_category            IN     VARCHAR2,
                x_attribute1                    IN     VARCHAR2,
                x_attribute2                    IN     VARCHAR2,
                x_attribute3                    IN     VARCHAR2,
                x_attribute4                    IN     VARCHAR2,
                x_attribute5                    IN     VARCHAR2,
                x_attribute6                    IN     VARCHAR2,
                x_attribute7                    IN     VARCHAR2,
                x_attribute8                    IN     VARCHAR2,
                x_attribute9                    IN     VARCHAR2,
                x_attribute10                   IN     VARCHAR2,
                x_attribute11                   IN     VARCHAR2,
                x_attribute12                   IN     VARCHAR2,
                x_attribute13                   IN     VARCHAR2,
                x_attribute14                   IN     VARCHAR2,
                x_attribute15                   IN     VARCHAR2,
                x_location_id                   IN     NUMBER,
                x_customer_id                   IN     NUMBER,
                x_grouping_rule_id              IN     NUMBER    DEFAULT NULL,
		x_calendar_year_start_date      IN     VARCHAR2    DEFAULT NULL   --Bug#7022608
        );


-------------------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
-- HISTORY   : Modified    19-MAR-2002   lkatputu
--           : Added Send_Entries into the table handler
--             as per the 'DO NOT SEND' enhancement requirement.
-- 02-FEB-05  Vivek o Added lease extension end date as one of the input
--                    parameters. Fix for bug# 4142423
-------------------------------------------------------------------------------
PROCEDURE Update_Row
        (
                x_lease_id                      IN     NUMBER,
                x_lease_detail_id               IN     NUMBER,
                x_lease_change_id               IN     NUMBER,
                x_name                          IN     VARCHAR2,
                x_lease_num                     IN     VARCHAR2,
                x_parent_lease_id               IN     NUMBER,
                x_lease_type_code               IN     VARCHAR2,
                x_lease_class_code              IN     VARCHAR2,
                x_payment_term_proration_rule   IN     NUMBER,
                x_abstracted_by_user            IN     NUMBER,
                x_status                        IN     VARCHAR2,
                x_lease_status                  IN     VARCHAR2,
                x_last_update_date              IN     DATE,
                x_last_updated_by               IN     NUMBER,
                x_last_update_login             IN     NUMBER,
                x_responsible_user              IN     NUMBER,
                x_expense_account_id            IN     NUMBER,
                x_accrual_account_id            IN     NUMBER,
                x_receivable_account_id         IN     NUMBER,
                x_term_template_id              IN     NUMBER,
                x_lease_commencement_date       IN     DATE,
                x_lease_termination_date        IN     DATE,
                x_lease_execution_date          IN     DATE,
                x_attribute_category            IN     VARCHAR2,
                x_attribute1                    IN     VARCHAR2,
                x_attribute2                    IN     VARCHAR2,
                x_attribute3                    IN     VARCHAR2,
                x_attribute4                    IN     VARCHAR2,
                x_attribute5                    IN     VARCHAR2,
                x_attribute6                    IN     VARCHAR2,
                x_attribute7                    IN     VARCHAR2,
                x_attribute8                    IN     VARCHAR2,
                x_attribute9                    IN     VARCHAR2,
                x_attribute10                   IN     VARCHAR2,
                x_attribute11                   IN     VARCHAR2,
                x_attribute12                   IN     VARCHAR2,
                x_attribute13                   IN     VARCHAR2,
                x_attribute14                   IN     VARCHAR2,
                x_attribute15                   IN     VARCHAR2,
                x_location_id                   IN     NUMBER,
                x_customer_id                   IN     NUMBER,
                x_grouping_rule_id              IN     NUMBER    DEFAULT NULL,
                x_lease_extension_end_date      IN     DATE,
		x_calendar_year_start_date      IN     VARCHAR2 DEFAULT NULL             --Bug#7022608
        );

------------------------------------------------------------------------
-- PROCEDURE : DELETE_ROW --delete logic....8/11/1999
------------------------------------------------------------------------
PROCEDURE Delete_Row
        (
        x_lease_id                      IN     NUMBER
        );

------------------------------------------------------------------------
-- PROCEDURE : CHECK_UNIQUE_LEASE_NUMBER
------------------------------------------------------------------------
PROCEDURE check_unique_lease_number
        (
                x_return_status                 IN OUT NOCOPY VARCHAR2,
                x_lease_id                      IN     NUMBER,
                x_lease_number                  IN     VARCHAR2
        );

/* overloaded functions and procedures for MOAC */
------------------------------------------------------------------------
-- PROCEDURE : CHECK_UNIQUE_LEASE_NUMBER
------------------------------------------------------------------------
PROCEDURE check_unique_lease_number
        (
                x_return_status                 IN OUT NOCOPY VARCHAR2,
                x_lease_id                      IN     NUMBER,
                x_lease_number                  IN     VARCHAR2,
		x_org_id                        IN     NUMBER
        );

END pn_leases_pkg;

/
