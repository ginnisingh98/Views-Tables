--------------------------------------------------------
--  DDL for Package Body FUN_NET_AR_TXNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_NET_AR_TXNS_PKG" AS
/* $Header: funntarb.pls 120.0 2005/12/09 08:33:15 vgadde noship $ */

    PROCEDURE Insert_Row (
        x_rowid                     IN OUT NOCOPY VARCHAR2,
        x_batch_id                  IN     NUMBER,
        x_customer_trx_id           IN     NUMBER,
        x_object_version_number     IN     NUMBER,
        x_ar_txn_rank               IN     NUMBER,
        x_transaction_amt           IN     NUMBER,
        x_netted_amt                IN     NUMBER,
        x_open_amt                  IN     NUMBER,
        x_cash_receipt_id           IN     NUMBER,
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
    ) IS

    BEGIN

        INSERT INTO fun_net_ar_txns_all (
            batch_id,
            customer_trx_id,
            object_version_number,
            ar_txn_rank,
            transaction_amt,
            netted_amt,
            open_amt,
            cash_receipt_id,
            org_id,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            attribute16,
            attribute17,
            attribute18,
            attribute19,
            attribute20,
            created_by,
            creation_date,
            last_update_login,
            last_update_date,
            last_updated_by
        )
        VALUES (
            x_batch_id,
            x_customer_trx_id,
            x_object_version_number,
            x_ar_txn_rank,
            x_transaction_amt,
            x_netted_amt,
            x_open_amt,
            x_cash_receipt_id,
            x_org_id,
            x_attribute_category,
            x_attribute1,
            x_attribute2,
            x_attribute3,
            x_attribute4,
            x_attribute5,
            x_attribute6,
            x_attribute7,
            x_attribute8,
            x_attribute9,
            x_attribute10,
            x_attribute11,
            x_attribute12,
            x_attribute13,
            x_attribute14,
            x_attribute15,
            x_attribute16,
            x_attribute17,
            x_attribute18,
            x_attribute19,
            x_attribute20,
            NVL(FND_GLOBAL.user_id,-1),
            SYSDATE,
            DECODE(FND_GLOBAL.conc_login_id,null,FND_GLOBAL.login_id,-1,FND_GLOBAL.login_id,FND_GLOBAL.conc_login_id),
            SYSDATE,
            NVL(FND_GLOBAL.user_id,-1)
        )RETURNING ROWID INTO x_rowid;

        IF ( SQL%NOTFOUND ) THEN
            RAISE NO_DATA_FOUND;
        END IF;

    END Insert_Row;


    PROCEDURE Update_Row (
        x_batch_id                  IN     NUMBER,
        x_customer_trx_id           IN     NUMBER,
        x_object_version_number     IN     NUMBER,
        x_ar_txn_rank               IN     NUMBER,
        x_transaction_amt           IN     NUMBER,
        x_netted_amt                IN     NUMBER,
        x_open_amt                  IN     NUMBER,
        x_cash_receipt_id           IN     NUMBER,
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
    ) IS

    BEGIN

        UPDATE fun_net_ar_txns_all SET
            batch_id                 =    x_batch_id,
            customer_trx_id          =    x_customer_trx_id,
            object_version_number    =    x_object_version_number,
            ar_txn_rank              =    x_ar_txn_rank,
            transaction_amt          =    x_transaction_amt,
            netted_amt               =    x_netted_amt,
            open_amt                 =    x_open_amt,
            cash_receipt_id          =    x_cash_receipt_id,
            org_id                   =    x_org_id,
            attribute_category       =    x_attribute_category,
            attribute1               =    x_attribute1,
            attribute2               =    x_attribute2,
            attribute3               =    x_attribute3,
            attribute4               =    x_attribute4,
            attribute5               =    x_attribute5,
            attribute6               =    x_attribute6,
            attribute7               =    x_attribute7,
            attribute8               =    x_attribute8,
            attribute9               =    x_attribute9,
            attribute10              =    x_attribute10,
            attribute11              =    x_attribute11,
            attribute12              =    x_attribute12,
            attribute13              =    x_attribute13,
            attribute14              =    x_attribute14,
            attribute15              =    x_attribute15,
            attribute16              =    x_attribute16,
            attribute17              =    x_attribute17,
            attribute18              =    x_attribute18,
            attribute19              =    x_attribute19,
            attribute20              =    x_attribute20,
            last_update_login      = DECODE(FND_GLOBAL.conc_login_id,null,FND_GLOBAL.login_id,-1,FND_GLOBAL.login_id,FND_GLOBAL.conc_login_id),
            last_update_date       = SYSDATE,
            last_updated_by        = NVL(FND_GLOBAL.user_id,-1)
        WHERE batch_id = x_batch_id
        AND customer_trx_id = x_customer_trx_id;

        IF ( SQL%NOTFOUND ) THEN
            RAISE NO_DATA_FOUND;
        END IF;

    END Update_Row;


    PROCEDURE Select_Row (
        x_batch_id                  IN OUT NOCOPY     NUMBER,
        x_customer_trx_id           IN OUT NOCOPY     NUMBER,
        x_object_version_number     IN OUT NOCOPY     NUMBER,
        x_ar_txn_rank               IN OUT NOCOPY     NUMBER,
        x_transaction_amt           IN OUT NOCOPY     NUMBER,
        x_netted_amt                IN OUT NOCOPY     NUMBER,
        x_open_amt                  IN OUT NOCOPY     NUMBER,
        x_cash_receipt_id           IN OUT NOCOPY     NUMBER,
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
    ) IS

    BEGIN

        SELECT
            batch_id,
            customer_trx_id,
            object_version_number,
            ar_txn_rank,
            transaction_amt,
            netted_amt,
            open_amt,
            cash_receipt_id,
            org_id,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            attribute16,
            attribute17,
            attribute18,
            attribute19,
            attribute20
        INTO
            x_batch_id,
            x_customer_trx_id,
            x_object_version_number,
            x_ar_txn_rank,
            x_transaction_amt,
            x_netted_amt,
            x_open_amt,
            x_cash_receipt_id,
            x_org_id,
            x_attribute_category,
            x_attribute1,
            x_attribute2,
            x_attribute3,
            x_attribute4,
            x_attribute5,
            x_attribute6,
            x_attribute7,
            x_attribute8,
            x_attribute9,
            x_attribute10,
            x_attribute11,
            x_attribute12,
            x_attribute13,
            x_attribute14,
            x_attribute15,
            x_attribute16,
            x_attribute17,
            x_attribute18,
            x_attribute19,
            x_attribute20
        FROM fun_net_ar_txns_all
        WHERE batch_id = x_batch_id
        AND customer_trx_id = x_customer_trx_id;

        IF ( SQL%NOTFOUND ) THEN
            RAISE NO_DATA_FOUND;
        END IF;

    END Select_Row;


    PROCEDURE Delete_Row (
        x_batch_id                  IN             NUMBER,
        x_customer_trx_id           IN             NUMBER
    ) IS

    BEGIN

        DELETE fun_net_ar_txns_all
        WHERE  batch_id = x_batch_id
        AND customer_trx_id = x_customer_trx_id;

        IF ( SQL%NOTFOUND ) THEN
            RAISE NO_DATA_FOUND;
        END IF;

    END Delete_Row;


END FUN_NET_AR_TXNS_PKG;

/
