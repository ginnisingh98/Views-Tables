--------------------------------------------------------
--  DDL for Package Body FUN_NET_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_NET_BATCHES_PKG" AS
/* $Header: funntbab.pls 120.1 2006/08/04 10:52:42 akonatha noship $ */

--===========================FND_LOG.START=====================================

g_state_level NUMBER;
g_proc_level  NUMBER;
g_event_level NUMBER;
g_excep_level NUMBER;
g_error_level NUMBER;
g_unexp_level NUMBER;
g_path        VARCHAR2(100);

--===========================FND_LOG.END=======================================

    PROCEDURE Insert_Row (
        x_batch_id                  IN OUT NOCOPY NUMBER,
        x_object_version_number     IN            NUMBER,
        x_agreement_id              IN            NUMBER,
        x_batch_name                IN            VARCHAR2,
        x_batch_number              IN            NUMBER,
        x_review_netting_batch_flag IN            VARCHAR2,
        x_batch_currency            IN            VARCHAR2,
        x_batch_status_code         IN            VARCHAR2,
        x_total_netted_amt          IN            NUMBER,
        x_transaction_due_date      IN            DATE,
        x_settlement_date           IN            DATE,
        x_response_date             IN            DATE,
        x_exchange_rate_type        IN            VARCHAR2,
        x_exchange_rate             IN            NUMBER,
        x_gl_date                   IN            DATE,
        x_org_id                    IN            NUMBER,
        x_attribute_category        IN            VARCHAR2,
        x_attribute1                IN            VARCHAR2,
        x_attribute2                IN            VARCHAR2,
        x_attribute3                IN            VARCHAR2,
        x_attribute4                IN            VARCHAR2,
        x_attribute5                IN            VARCHAR2,
        x_attribute6                IN            VARCHAR2,
        x_attribute7                IN            VARCHAR2,
        x_attribute8                IN            VARCHAR2,
        x_attribute9                IN            VARCHAR2,
        x_attribute10               IN            VARCHAR2,
        x_attribute11               IN            VARCHAR2,
        x_attribute12               IN            VARCHAR2,
        x_attribute13               IN            VARCHAR2,
        x_attribute14               IN            VARCHAR2,
        x_attribute15               IN            VARCHAR2,
        x_attribute16               IN            VARCHAR2,
        x_attribute17               IN            VARCHAR2,
        x_attribute18               IN            VARCHAR2,
        x_attribute19               IN            VARCHAR2,
        x_attribute20               IN            VARCHAR2
    ) IS

        l_batch_id      fun_net_batches_all.batch_id%TYPE;
        l_batch_number  fun_net_batches_all.batch_number%TYPE;
        l_path 	        VARCHAR2(100);
    BEGIN

        l_path  := g_path||'Insert_Row';
        fun_net_util.Log_String(g_proc_level,l_path,'Before inserting into fun_net_batches_all');

        IF x_batch_id IS NULL THEN
            SELECT fun_net_batches_s.NEXTVAL INTO l_batch_id FROM DUAL;
            x_batch_id := l_batch_id;
        ELSE
            l_batch_id := x_batch_id;
        END IF;
        fun_net_util.Log_String(g_state_level,l_path,'batch_id:'||l_batch_id);

        IF x_batch_number IS NULL THEN
            l_batch_number := l_batch_id;
        ELSE
            l_batch_number := x_batch_number;
        END IF;

        INSERT INTO fun_net_batches (
            batch_id,
            object_version_number,
            agreement_id,
            batch_name,
            batch_number,
            review_netting_batch_flag,
            batch_currency,
            batch_status_code,
            total_netted_amt,
            transaction_due_date,
            settlement_date,
            response_date,
            exchange_rate_type,
            exchange_rate,
            gl_date,
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
            l_batch_id,
            x_object_version_number,
            x_agreement_id,
            x_batch_name,
            l_batch_number,
            x_review_netting_batch_flag,
            x_batch_currency,
            x_batch_status_code,
            x_total_netted_amt,
            x_transaction_due_date,
            x_settlement_date,
            x_response_date,
            x_exchange_rate_type,
            x_exchange_rate,
            x_gl_date,
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
        );

        IF SQL%NOTFOUND THEN
            fun_net_util.Log_String(g_excep_level,l_path,'Could not insert batch record');
            RAISE NO_DATA_FOUND;
        END IF;
        fun_net_util.Log_String(g_proc_level,l_path,'Successfully inserted batch record');
    END Insert_Row;


    PROCEDURE Update_Row (
        x_batch_id                  IN            NUMBER,
        x_object_version_number     IN            NUMBER,
        x_agreement_id              IN            NUMBER,
        x_batch_name                IN            VARCHAR2,
        x_batch_number              IN            NUMBER,
        x_review_netting_batch_flag IN            VARCHAR2,
        x_batch_currency            IN            VARCHAR2,
        x_batch_status_code         IN            VARCHAR2,
        x_total_netted_amt          IN            NUMBER,
        x_transaction_due_date      IN            DATE,
        x_settlement_date           IN            DATE,
        x_response_date             IN            DATE,
        x_exchange_rate_type        IN            VARCHAR2,
        x_exchange_rate             IN            NUMBER,
        x_gl_date                   IN            DATE,
        x_org_id                    IN            NUMBER,
        x_attribute_category        IN            VARCHAR2,
        x_attribute1                IN            VARCHAR2,
        x_attribute2                IN            VARCHAR2,
        x_attribute3                IN            VARCHAR2,
        x_attribute4                IN            VARCHAR2,
        x_attribute5                IN            VARCHAR2,
        x_attribute6                IN            VARCHAR2,
        x_attribute7                IN            VARCHAR2,
        x_attribute8                IN            VARCHAR2,
        x_attribute9                IN            VARCHAR2,
        x_attribute10               IN            VARCHAR2,
        x_attribute11               IN            VARCHAR2,
        x_attribute12               IN            VARCHAR2,
        x_attribute13               IN            VARCHAR2,
        x_attribute14               IN            VARCHAR2,
        x_attribute15               IN            VARCHAR2,
        x_attribute16               IN            VARCHAR2,
        x_attribute17               IN            VARCHAR2,
        x_attribute18               IN            VARCHAR2,
        x_attribute19               IN            VARCHAR2,
        x_attribute20               IN            VARCHAR2
    ) IS

        l_path 	        VARCHAR2(100);
    BEGIN
        l_path  := g_path||'Update_Row';
        fun_net_util.Log_String(g_proc_level,l_path,'Before updating fun_net_batches_all');

        UPDATE FUN_NET_BATCHES_ALL SET
            batch_id               =   x_batch_id,
            object_version_number  =   x_object_version_number,
            agreement_id           =   x_agreement_id,
            batch_name             =   x_batch_name,
            batch_number           =   x_batch_number,
            review_netting_batch_flag =   x_review_netting_batch_flag,
            batch_currency         =   x_batch_currency,
            batch_status_code      =   x_batch_status_code,
            total_netted_amt       =   x_total_netted_amt,
            transaction_due_date   =   x_transaction_due_date,
            settlement_date        =   x_settlement_date,
            response_date          =   x_response_date,
            exchange_rate_type     =   x_exchange_rate_type,
            exchange_rate          =   x_exchange_rate,
            gl_date                =   x_gl_date,
            org_id                 =   x_org_id,
            attribute_category     =   x_attribute_category,
            attribute1             =   x_attribute1,
            attribute2             =   x_attribute2,
            attribute3             =   x_attribute3,
            attribute4             =   x_attribute4,
            attribute5             =   x_attribute5,
            attribute6             =   x_attribute6,
            attribute7             =   x_attribute7,
            attribute8             =   x_attribute8,
            attribute9             =   x_attribute9,
            attribute10            =   x_attribute10,
            attribute11            =   x_attribute11,
            attribute12            =   x_attribute12,
            attribute13            =   x_attribute13,
            attribute14            =   x_attribute14,
            attribute15            =   x_attribute15,
            attribute16            =   x_attribute16,
            attribute17            =   x_attribute17,
            attribute18            =   x_attribute18,
            attribute19            =   x_attribute19,
            attribute20            =   x_attribute20,
            last_update_login      = DECODE(FND_GLOBAL.conc_login_id,null,FND_GLOBAL.login_id,-1,FND_GLOBAL.login_id,FND_GLOBAL.conc_login_id),
            last_update_date       = SYSDATE,
            last_updated_by        = NVL(FND_GLOBAL.user_id,-1)
        WHERE batch_id = x_batch_id;

        IF ( SQL%NOTFOUND ) THEN
            fun_net_util.Log_String(g_excep_level,l_path,'Could not update record for batch_id:'||x_batch_id);
            RAISE NO_DATA_FOUND;
        END IF;
        fun_net_util.Log_String(g_proc_level,l_path,'Successfully updated batch record');
    END Update_Row;


    PROCEDURE Update_Row (
        x_batch_id                  IN            NUMBER,
        x_batch_status_code         IN            VARCHAR2
    ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE fun_net_batches_all
        SET batch_status_code = x_batch_status_code
        WHERE batch_id = x_batch_id;

        IF SQL%FOUND THEN
            COMMIT;
        ELSE
            ROLLBACK;
        END IF;
    END Update_Row;

    PROCEDURE Select_Row (
        x_batch_id                  IN OUT NOCOPY NUMBER,
        x_object_version_number     IN OUT NOCOPY NUMBER,
        x_agreement_id              IN OUT NOCOPY NUMBER,
        x_batch_name                IN OUT NOCOPY VARCHAR2,
        x_batch_number              IN OUT NOCOPY NUMBER,
        x_review_netting_batch_flag IN OUT NOCOPY VARCHAR2,
        x_batch_currency            IN OUT NOCOPY VARCHAR2,
        x_batch_status_code         IN OUT NOCOPY VARCHAR2,
        x_total_netted_amt          IN OUT NOCOPY NUMBER,
        x_transaction_due_date      IN OUT NOCOPY DATE,
        x_settlement_date           IN OUT NOCOPY DATE,
        x_response_date             IN OUT NOCOPY DATE,
        x_exchange_rate_type        IN OUT NOCOPY VARCHAR2,
        x_exchange_rate             IN OUT NOCOPY NUMBER,
        x_gl_date                   IN OUT NOCOPY DATE,
        x_org_id                    IN OUT NOCOPY NUMBER,
        x_attribute_category        IN OUT NOCOPY VARCHAR2,
        x_attribute1                IN OUT NOCOPY VARCHAR2,
        x_attribute2                IN OUT NOCOPY VARCHAR2,
        x_attribute3                IN OUT NOCOPY VARCHAR2,
        x_attribute4                IN OUT NOCOPY VARCHAR2,
        x_attribute5                IN OUT NOCOPY VARCHAR2,
        x_attribute6                IN OUT NOCOPY VARCHAR2,
        x_attribute7                IN OUT NOCOPY VARCHAR2,
        x_attribute8                IN OUT NOCOPY VARCHAR2,
        x_attribute9                IN OUT NOCOPY VARCHAR2,
        x_attribute10               IN OUT NOCOPY VARCHAR2,
        x_attribute11               IN OUT NOCOPY VARCHAR2,
        x_attribute12               IN OUT NOCOPY VARCHAR2,
        x_attribute13               IN OUT NOCOPY VARCHAR2,
        x_attribute14               IN OUT NOCOPY VARCHAR2,
        x_attribute15               IN OUT NOCOPY VARCHAR2,
        x_attribute16               IN OUT NOCOPY VARCHAR2,
        x_attribute17               IN OUT NOCOPY VARCHAR2,
        x_attribute18               IN OUT NOCOPY VARCHAR2,
        x_attribute19               IN OUT NOCOPY VARCHAR2,
        x_attribute20               IN OUT NOCOPY VARCHAR2
    ) IS

    BEGIN

        SELECT
            batch_id,
            object_version_number,
            agreement_id,
            batch_name,
            batch_number,
            review_netting_batch_flag,
            batch_currency,
            batch_status_code,
            total_netted_amt,
            transaction_due_date,
            settlement_date,
            response_date,
            exchange_rate_type,
            exchange_rate,
            gl_date,
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
            x_object_version_number,
            x_agreement_id,
            x_batch_name,
            x_batch_number,
            x_review_netting_batch_flag,
            x_batch_currency,
            x_batch_status_code,
            x_total_netted_amt,
            x_transaction_due_date,
            x_settlement_date,
            x_response_date,
            x_exchange_rate_type,
            x_exchange_rate,
            x_gl_date,
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
        FROM FUN_NET_BATCHES_ALL
        WHERE batch_id = x_batch_id;

        IF SQL%NOTFOUND THEN
            RAISE NO_DATA_FOUND;
        END IF;

    END Select_Row;


    PROCEDURE Delete_Row (
        x_batch_id     				 IN				 NUMBER
    ) IS

    BEGIN

        DELETE fun_net_batches_all
        WHERE  batch_id = x_batch_id;

        IF ( SQL%NOTFOUND ) THEN
            RAISE NO_DATA_FOUND;
        END IF;

    END Delete_Row;

BEGIN
    --===========================FND_LOG.START=====================================

    g_state_level :=	FND_LOG.LEVEL_STATEMENT;
    g_proc_level  :=	FND_LOG.LEVEL_PROCEDURE;
    g_event_level :=	FND_LOG.LEVEL_EVENT;
    g_excep_level :=	FND_LOG.LEVEL_EXCEPTION;
    g_error_level :=	FND_LOG.LEVEL_ERROR;
    g_unexp_level :=	FND_LOG.LEVEL_UNEXPECTED;
    g_path        :=    'FUN.PLSQL.funntbab.FUN_NET_BATCHES_PKG.';

    --===========================FND_LOG.END=======================================


END FUN_NET_BATCHES_PKG;

/
