--------------------------------------------------------
--  DDL for Package PN_LEASE_CHANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_LEASE_CHANGES_PKG" AUTHID CURRENT_USER AS
-- $Header: PNTLCHGS.pls 120.2 2006/01/20 03:57:00 appldev ship $

PROCEDURE Insert_Row
        (
                X_ROWID                         IN OUT NOCOPY VARCHAR2,
                X_LEASE_CHANGE_ID               IN OUT NOCOPY NUMBER,
                X_LEASE_ID                      IN     NUMBER,
                X_LEASE_CHANGE_NUMBER           IN OUT NOCOPY NUMBER,
                X_LEASE_CHANGE_NAME             IN     VARCHAR2,
                X_RESPONSIBLE_USER              IN     NUMBER,
                X_CHANGE_COMMENCEMENT_DATE      IN     DATE,
                X_CHANGE_TERMINATION_DATE       IN     DATE,
                X_CHANGE_TYPE_LOOKUP_CODE       IN     VARCHAR2,
                X_CHANGE_EXECUTION_DATE         IN     DATE,
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
                X_ABSTRACTED_BY_USER            IN     NUMBER,
                X_CREATION_DATE                 IN     DATE,
                X_CREATED_BY                    IN     NUMBER,
                X_LAST_UPDATE_DATE              IN     DATE,
                X_LAST_UPDATED_BY               IN     NUMBER,
                X_LAST_UPDATE_LOGIN             IN     NUMBER,
                x_org_id                        IN     NUMBER,
		x_cutoff_date                   IN     DATE DEFAULT NULL
        );

PROCEDURE Lock_Row
        (
                X_LEASE_CHANGE_ID               IN NUMBER,
                X_RESPONSIBLE_USER              IN NUMBER,
                X_CHANGE_COMMENCEMENT_DATE      IN DATE,
                X_CHANGE_TERMINATION_DATE       IN DATE,
                X_CHANGE_TYPE_LOOKUP_CODE       IN VARCHAR2,
                X_CHANGE_EXECUTION_DATE         IN DATE,
                X_ATTRIBUTE_CATEGORY            IN VARCHAR2,
                X_ATTRIBUTE1                    IN VARCHAR2,
                X_ATTRIBUTE2                    IN VARCHAR2,
                X_ATTRIBUTE3                    IN VARCHAR2,
                X_ATTRIBUTE4                    IN VARCHAR2,
                X_ATTRIBUTE5                    IN VARCHAR2,
                X_ATTRIBUTE6                    IN VARCHAR2,
                X_ATTRIBUTE7                    IN VARCHAR2,
                X_ATTRIBUTE8                    IN VARCHAR2,
                X_ATTRIBUTE9                    IN VARCHAR2,
                X_ATTRIBUTE10                   IN VARCHAR2,
                X_ATTRIBUTE11                   IN VARCHAR2,
                X_ATTRIBUTE12                   IN VARCHAR2,
                X_ATTRIBUTE13                   IN VARCHAR2,
                X_ATTRIBUTE14                   IN VARCHAR2,
                X_ATTRIBUTE15                   IN VARCHAR2,
                X_LEASE_ID                      IN NUMBER,
                X_LEASE_TRANSACTION_ID          IN NUMBER,
                X_LEASE_CHANGE_NUMBER           IN NUMBER,
                X_LEASE_CHANGE_NAME             IN VARCHAR2,
                X_ABSTRACTED_BY_USER            IN NUMBER
        );

PROCEDURE Update_Row
        (
                X_LEASE_CHANGE_ID               IN NUMBER,
                X_RESPONSIBLE_USER              IN NUMBER,
                X_CHANGE_COMMENCEMENT_DATE      IN DATE,
                X_CHANGE_TERMINATION_DATE       IN DATE,
                X_CHANGE_TYPE_LOOKUP_CODE       IN VARCHAR2,
                X_CHANGE_EXECUTION_DATE         IN DATE,
                X_ATTRIBUTE_CATEGORY            IN VARCHAR2,
                X_ATTRIBUTE1                    IN VARCHAR2,
                X_ATTRIBUTE2                    IN VARCHAR2,
                X_ATTRIBUTE3                    IN VARCHAR2,
                X_ATTRIBUTE4                    IN VARCHAR2,
                X_ATTRIBUTE5                    IN VARCHAR2,
                X_ATTRIBUTE6                    IN VARCHAR2,
                X_ATTRIBUTE7                    IN VARCHAR2,
                X_ATTRIBUTE8                    IN VARCHAR2,
                X_ATTRIBUTE9                    IN VARCHAR2,
                X_ATTRIBUTE10                   IN VARCHAR2,
                X_ATTRIBUTE11                   IN VARCHAR2,
                X_ATTRIBUTE12                   IN VARCHAR2,
                X_ATTRIBUTE13                   IN VARCHAR2,
                X_ATTRIBUTE14                   IN VARCHAR2,
                X_ATTRIBUTE15                   IN VARCHAR2,
                X_LEASE_ID                      IN NUMBER,
                X_LEASE_TRANSACTION_ID          IN NUMBER,
                X_LEASE_CHANGE_NUMBER           IN NUMBER,
                X_LEASE_CHANGE_NAME             IN VARCHAR2,
                X_ABSTRACTED_BY_USER            IN NUMBER,
                X_LAST_UPDATE_DATE              IN DATE,
                X_LAST_UPDATED_BY               IN NUMBER,
                X_LAST_UPDATE_LOGIN             IN NUMBER
        );

PROCEDURE Delete_Row
        (
                X_LEASE_CHANGE_ID               IN NUMBER
        );

PROCEDURE delete_row_transactions
        (
                X_LEASE_TRANSACTION_ID          IN NUMBER
        );

PROCEDURE check_unique_change_number
        (
                 x_return_status                IN OUT NOCOPY VARCHAR2
                ,X_LEASE_ID                     IN     NUMBER
                ,X_CHANGE_TYPE_LOOKUP_CODE      IN     VARCHAR2
                ,X_LEASE_CHANGE_NUMBER          IN     VARCHAR2
        );

END pn_lease_changes_pkg;

 

/
