--------------------------------------------------------
--  DDL for Package PN_LEASE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_LEASE_DETAILS_PKG" AUTHID CURRENT_USER AS
-- $Header: PNTLSDTS.pls 115.26 2003/12/19 17:40:47 atuppad ship $

PROCEDURE Insert_Row
        (
                 x_rowid                         IN OUT NOCOPY VARCHAR2
                ,x_lease_detail_id               IN OUT NOCOPY NUMBER
                ,x_lease_change_id               IN     NUMBER
                ,x_lease_id                      IN     NUMBER
                ,x_responsible_user              IN     NUMBER
                ,x_expense_account_id            IN     NUMBER
                ,x_lease_commencement_date       IN     DATE
                ,x_lease_termination_date        IN     DATE
                ,x_lease_execution_date          IN     DATE
                ,x_creation_date                 IN     DATE
                ,x_created_by                    IN     NUMBER
                ,x_last_update_date              IN     DATE
                ,x_last_updated_by               IN     NUMBER
                ,x_last_update_login             IN     NUMBER
                ,x_accrual_account_id            IN     NUMBER
                ,x_receivable_account_id         IN     NUMBER
                ,x_term_template_id              IN     NUMBER   DEFAULT NULL
                ,x_grouping_rule_id              IN     NUMBER   DEFAULT NULL
                ,x_attribute_category            IN     VARCHAR2
                ,x_attribute1                    IN     VARCHAR2
                ,x_attribute2                    IN     VARCHAR2
                ,x_attribute3                    IN     VARCHAR2
                ,x_attribute4                    IN     VARCHAR2
                ,x_attribute5                    IN     VARCHAR2
                ,x_attribute6                    IN     VARCHAR2
                ,x_attribute7                    IN     VARCHAR2
                ,x_attribute8                    IN     VARCHAR2
                ,x_attribute9                    IN     VARCHAR2
                ,x_attribute10                   IN     VARCHAR2
                ,x_attribute11                   IN     VARCHAR2
                ,x_attribute12                   IN     VARCHAR2
                ,x_attribute13                   IN     VARCHAR2
                ,x_attribute14                   IN     VARCHAR2
                ,x_attribute15                   IN     VARCHAR2
                ,x_org_id                        IN     NUMBER
        );

PROCEDURE Lock_Row
        (
                 x_lease_detail_id               IN     NUMBER
                ,x_lease_change_id               IN     NUMBER
                ,x_lease_id                      IN     NUMBER
                ,x_responsible_user              IN     NUMBER
                ,x_expense_account_id            IN     NUMBER
                ,x_lease_commencement_date       IN     DATE
                ,x_lease_termination_date        IN     DATE
                ,x_lease_execution_date          IN     DATE
                ,x_accrual_account_id            IN     NUMBER
                ,x_receivable_account_id         IN     NUMBER
                ,x_term_template_id              IN     NUMBER
                ,x_grouping_rule_id              IN     NUMBER    DEFAULT NULL
                ,x_attribute_category            IN     VARCHAR2
                ,x_attribute1                    IN     VARCHAR2
                ,x_attribute2                    IN     VARCHAR2
                ,x_attribute3                    IN     VARCHAR2
                ,x_attribute4                    IN     VARCHAR2
                ,x_attribute5                    IN     VARCHAR2
                ,x_attribute6                    IN     VARCHAR2
                ,x_attribute7                    IN     VARCHAR2
                ,x_attribute8                    IN     VARCHAR2
                ,x_attribute9                    IN     VARCHAR2
                ,x_attribute10                   IN     VARCHAR2
                ,x_attribute11                   IN     VARCHAR2
                ,x_attribute12                   IN     VARCHAR2
                ,x_attribute13                   IN     VARCHAR2
                ,x_attribute14                   IN     VARCHAR2
                ,x_attribute15                   IN     VARCHAR2
                ,x_name                          IN     VARCHAR2 DEFAULT NULL
                ,x_lease_num                     IN     VARCHAR2 DEFAULT NULL
                ,x_lease_status                  IN     VARCHAR2 DEFAULT NULL
                ,x_lease_extension_end_date      IN     DATE     DEFAULT NULL
        );

PROCEDURE Update_Row
        (
                 x_lease_detail_id               IN     NUMBER
                ,x_lease_change_id               IN     NUMBER
                ,x_lease_id                      IN     NUMBER
                ,x_responsible_user              IN     NUMBER
                ,x_expense_account_id            IN     NUMBER
                ,x_lease_commencement_date       IN     DATE
                ,x_lease_termination_date        IN     DATE
                ,x_lease_execution_date          IN     DATE
                ,x_last_update_date              IN     DATE
                ,x_last_updated_by               IN     NUMBER
                ,x_last_update_login             IN     NUMBER
                ,x_accrual_account_id            IN     NUMBER
                ,x_receivable_account_id         IN     NUMBER
                ,x_term_template_id              IN     NUMBER
                ,x_grouping_rule_id              IN     NUMBER    DEFAULT NULL
                ,x_attribute_category            IN     VARCHAR2
                ,x_attribute1                    IN     VARCHAR2
                ,x_attribute2                    IN     VARCHAR2
                ,x_attribute3                    IN     VARCHAR2
                ,x_attribute4                    IN     VARCHAR2
                ,x_attribute5                    IN     VARCHAR2
                ,x_attribute6                    IN     VARCHAR2
                ,x_attribute7                    IN     VARCHAR2
                ,x_attribute8                    IN     VARCHAR2
                ,x_attribute9                    IN     VARCHAR2
                ,x_attribute10                   IN     VARCHAR2
                ,x_attribute11                   IN     VARCHAR2
                ,x_attribute12                   IN     VARCHAR2
                ,x_attribute13                   IN     VARCHAR2
                ,x_attribute14                   IN     VARCHAR2
                ,x_attribute15                   IN     VARCHAR2
                ,x_lease_extension_end_date      IN     DATE     DEFAULT NULL
        );

PROCEDURE Delete_Row
        (
                 x_lease_detail_id               IN     NUMBER
        );

END pn_lease_details_pkg;

 

/
