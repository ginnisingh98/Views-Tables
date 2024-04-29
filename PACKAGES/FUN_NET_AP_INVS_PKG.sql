--------------------------------------------------------
--  DDL for Package FUN_NET_AP_INVS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_NET_AP_INVS_PKG" AUTHID CURRENT_USER AS
/* $Header: funntaps.pls 120.0 2005/12/09 08:31:56 vgadde noship $ */

    PROCEDURE Insert_Row (
        x_rowid                     IN OUT NOCOPY VARCHAR2,
        x_batch_id                  IN     NUMBER,
        x_invoice_id                IN     NUMBER,
        x_object_version_number     IN     NUMBER,
        x_ap_txn_rank               IN     NUMBER,
        x_invoice_amt               IN     NUMBER,
        x_netted_amt                IN     NUMBER,
        x_open_amt                  IN     NUMBER,
        x_check_id                  IN     NUMBER,
        x_org_id                    IN     NUMBER,
        x_attribute_category        IN     VARCHAR2,
        x_attribute1                IN     VARCHAR2,
        x_attribute2                IN     VARCHAR2,
        x_attribute3                IN     VARCHAR2,
        x_attribute4                IN     VARCHAR2,
        x_attribute5                IN     VARCHAR2,
        x_attribute6                IN     VARCHAR2,
        x_attribute7                IN     VARCHAR2,
        x_attribute8                IN     VARCHAR2,
        x_attribute9                IN     VARCHAR2,
        x_attribute10               IN     VARCHAR2,
        x_attribute11               IN     VARCHAR2,
        x_attribute12               IN     VARCHAR2,
        x_attribute13               IN     VARCHAR2,
        x_attribute14               IN     VARCHAR2,
        x_attribute15               IN     VARCHAR2,
        x_attribute16               IN     VARCHAR2,
        x_attribute17               IN     VARCHAR2,
        x_attribute18               IN     VARCHAR2,
        x_attribute19               IN     VARCHAR2,
        x_attribute20               IN     VARCHAR2
    );


    PROCEDURE Update_Row (
        x_batch_id                  IN     NUMBER,
        x_invoice_id                IN     NUMBER,
        x_object_version_number     IN     NUMBER,
        x_ap_txn_rank               IN     NUMBER,
        x_invoice_amt               IN     NUMBER,
        x_netted_amt                IN     NUMBER,
        x_open_amt                  IN     NUMBER,
        x_check_id                  IN     NUMBER,
        x_org_id                    IN     NUMBER,
        x_attribute_category        IN     VARCHAR2,
        x_attribute1                IN     VARCHAR2,
        x_attribute2                IN     VARCHAR2,
        x_attribute3                IN     VARCHAR2,
        x_attribute4                IN     VARCHAR2,
        x_attribute5                IN     VARCHAR2,
        x_attribute6                IN     VARCHAR2,
        x_attribute7                IN     VARCHAR2,
        x_attribute8                IN     VARCHAR2,
        x_attribute9                IN     VARCHAR2,
        x_attribute10               IN     VARCHAR2,
        x_attribute11               IN     VARCHAR2,
        x_attribute12               IN     VARCHAR2,
        x_attribute13               IN     VARCHAR2,
        x_attribute14               IN     VARCHAR2,
        x_attribute15               IN     VARCHAR2,
        x_attribute16               IN     VARCHAR2,
        x_attribute17               IN     VARCHAR2,
        x_attribute18               IN     VARCHAR2,
        x_attribute19               IN     VARCHAR2,
        x_attribute20               IN     VARCHAR2
    );


    PROCEDURE Select_Row (
        x_batch_id                  IN OUT NOCOPY     NUMBER,
        x_invoice_id                IN OUT NOCOPY     NUMBER,
        x_object_version_number     IN OUT NOCOPY     NUMBER,
        x_ap_txn_rank               IN OUT NOCOPY     NUMBER,
        x_invoice_amt               IN OUT NOCOPY     NUMBER,
        x_netted_amt                IN OUT NOCOPY     NUMBER,
        x_open_amt                  IN OUT NOCOPY     NUMBER,
        x_check_id                  IN OUT NOCOPY     NUMBER,
        x_org_id                    IN OUT NOCOPY     NUMBER,
        x_attribute_category        IN OUT NOCOPY     VARCHAR2,
        x_attribute1                IN OUT NOCOPY     VARCHAR2,
        x_attribute2                IN OUT NOCOPY     VARCHAR2,
        x_attribute3                IN OUT NOCOPY     VARCHAR2,
        x_attribute4                IN OUT NOCOPY     VARCHAR2,
        x_attribute5                IN OUT NOCOPY     VARCHAR2,
        x_attribute6                IN OUT NOCOPY     VARCHAR2,
        x_attribute7                IN OUT NOCOPY     VARCHAR2,
        x_attribute8                IN OUT NOCOPY     VARCHAR2,
        x_attribute9                IN OUT NOCOPY     VARCHAR2,
        x_attribute10               IN OUT NOCOPY     VARCHAR2,
        x_attribute11               IN OUT NOCOPY     VARCHAR2,
        x_attribute12               IN OUT NOCOPY     VARCHAR2,
        x_attribute13               IN OUT NOCOPY     VARCHAR2,
        x_attribute14               IN OUT NOCOPY     VARCHAR2,
        x_attribute15               IN OUT NOCOPY     VARCHAR2,
        x_attribute16               IN OUT NOCOPY     VARCHAR2,
        x_attribute17               IN OUT NOCOPY     VARCHAR2,
        x_attribute18               IN OUT NOCOPY     VARCHAR2,
        x_attribute19               IN OUT NOCOPY     VARCHAR2,
        x_attribute20               IN OUT NOCOPY     VARCHAR2
    );


    PROCEDURE Delete_Row (
        x_batch_id                  IN             NUMBER,
        x_invoice_id                IN             NUMBER
    );


END FUN_NET_AP_INVS_PKG; -- Package spec

 

/
