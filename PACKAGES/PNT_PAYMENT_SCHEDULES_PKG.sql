--------------------------------------------------------
--  DDL for Package PNT_PAYMENT_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PNT_PAYMENT_SCHEDULES_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNTPYSCS.pls 120.0 2005/05/29 11:40:47 appldev noship $

PROCEDURE check_payment_schedule_date (
                       x_lease_id                      IN     NUMBER,
                       x_schedule_date                 IN     DATE,
                       x_payment_status_lookup_code    IN     VARCHAR2,
                       x_rowid                         IN     VARCHAR2
                     );

PROCEDURE check_payment_status (
                       x_payment_schedule_id           IN     NUMBER,
                       x_payment_status_lookup_code    IN     VARCHAR,
                       x_error_flag                    IN OUT NOCOPY VARCHAR2
                     );

PROCEDURE get_next_payment_schedule (
                       x_lease_id                      IN     NUMBER,
                       x_schedule_date                 IN     DATE,
                       x_next_payment_schedule_id      IN OUT NOCOPY NUMBER
                     );

PROCEDURE mark_pmt_items_exportable (
                       x_payment_status_lookup_code    IN     VARCHAR2,
                       x_payment_schedule_id           IN     NUMBER,
                       x_export_flag                   IN     VARCHAR2
                     );

PROCEDURE mark_billing_items_exportable (
                       x_payment_status_lookup_code    IN     VARCHAR2,
                       x_payment_schedule_id           IN     NUMBER,
                       x_export_flag                   IN     VARCHAR2
                     );

PROCEDURE check_on_hold (
                       x_lease_id                      IN     NUMBER,
                       x_schedule_date                 IN     DATE
                     );


PROCEDURE check_payment_items_acct_amt (
                      p_payment_schedule_id            IN     NUMBER,
                       p_functional_currency           IN     VARCHAR2,
                       p_error_flag                       OUT NOCOPY VARCHAR2
                     );

PROCEDURE update_accounted_amount (
                      p_pnt_sched_id                   IN     NUMBER,
                       p_payment_status_lookup_code    IN     VARCHAR2 DEFAULT 'DRAFT',
                       p_lease_functional_currency     IN     VARCHAR2,
                       p_last_updated_by               IN     NUMBER,
                       p_last_update_date              IN     DATE,
                       p_last_update_login             IN     NUMBER
                     );

PROCEDURE Insert_Row (
                       X_CONTEXT                       IN      VARCHAR2,
                       X_ROWID                         IN OUT NOCOPY VARCHAR2,
                       X_PAYMENT_SCHEDULE_ID           IN OUT NOCOPY NUMBER,
                       X_SCHEDULE_DATE                 IN     DATE,
                       X_LEASE_CHANGE_ID               IN     NUMBER,
                       X_LEASE_ID                      IN     NUMBER,
                       X_APPROVED_BY_USER_ID           IN     NUMBER,
                       X_TRANSFERRED_BY_USER_ID        IN     NUMBER,
                       X_PAYMENT_STATUS_LOOKUP_CODE    IN     VARCHAR2,
                       X_APPROVAL_DATE                 IN     DATE,
                       X_TRANSFER_DATE                 IN     DATE,
                       X_PERIOD_NAME                   IN     VARCHAR2,
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
                       X_CREATION_DATE                 IN     DATE,
                       X_CREATED_BY                    IN     NUMBER,
                       X_LAST_UPDATE_DATE              IN     DATE,
                       X_LAST_UPDATED_BY               IN     NUMBER,
                       X_LAST_UPDATE_LOGIN             IN     NUMBER,
                       x_org_id                        IN     NUMBER
                     );

PROCEDURE Lock_Row (
                       X_PAYMENT_SCHEDULE_ID           IN     NUMBER,
                       X_APPROVED_BY_USER_ID           IN     NUMBER,
                       X_TRANSFERRED_BY_USER_ID        IN     NUMBER,
                       X_PAYMENT_STATUS_LOOKUP_CODE    IN     VARCHAR2,
                       X_APPROVAL_DATE                 IN     DATE,
                       X_TRANSFER_DATE                 IN     DATE,
                       X_PERIOD_NAME                   IN     VARCHAR2,
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
                       X_ATTRIBUTE15                   IN     VARCHAR2
                     );

PROCEDURE Update_Row (
                       X_CONTEXT                       IN     VARCHAR2,
                       X_PAYMENT_SCHEDULE_ID           IN     NUMBER,
                       X_SCHEDULE_DATE                 IN     DATE,
                       X_APPROVED_BY_USER_ID           IN     NUMBER,
                       X_TRANSFERRED_BY_USER_ID        IN     NUMBER,
                       X_PAYMENT_STATUS_LOOKUP_CODE    IN     VARCHAR2,
                       X_LEASE_FUNCTIONAL_CURRENCY     IN     VARCHAR2 DEFAULT NULL,
                       X_APPROVAL_DATE                 IN     DATE,
                       X_TRANSFER_DATE                 IN     DATE,
                       X_PERIOD_NAME                   IN     VARCHAR2,
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
                       X_LAST_UPDATE_DATE              IN     DATE,
                       X_LAST_UPDATED_BY               IN     NUMBER,
                       X_LAST_UPDATE_LOGIN             IN     NUMBER
                     );

PROCEDURE Delete_Row (
                       X_PAYMENT_SCHEDULE_ID           IN     NUMBER
                     );


PROCEDURE update_rate (
                       p_pnt_sched_id                  IN     NUMBER,
                       p_payment_status_lookup_code    IN     VARCHAR2,
                       p_lease_functional_currency     IN     VARCHAR2,
                       p_last_updated_by               IN     NUMBER,
                       p_last_update_date              IN     DATE,
                       p_last_update_login             IN     NUMBER
                     );

END pnt_payment_schedules_pkg;

 

/
