--------------------------------------------------------
--  DDL for Package Body FUN_NET_AGREEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_NET_AGREEMENTS_PKG" AS
/* $Header: funntagb.pls 120.0 2005/12/09 08:31:09 vgadde noship $ */

    PROCEDURE Insert_Row (
        x_agreement_id              IN OUT NOCOPY NUMBER,
        x_object_version_number     IN     NUMBER,
        x_agreement_name            IN     VARCHAR2,
        x_partner_reference         IN     VARCHAR2,
        x_agreement_start_date      IN     DATE,
        x_agreement_end_date        IN     DATE,
        x_in_process_flag           IN     VARCHAR2,
        x_sel_rec_past_due_txns_flag IN    VARCHAR2,
        x_days_past_due             IN     NUMBER,
        x_net_currency_rule_code    IN     VARCHAR2,
        x_net_order_rule_code       IN     VARCHAR2,
        x_net_balance_rule_code     IN     VARCHAR2,
        x_shikyu_rule_code          IN     VARCHAR2,
        x_bank_account_id           IN     NUMBER,
        x_net_currency_code         IN     VARCHAR2,
        x_approver_name             IN     VARCHAR2,
        x_non_response_action_code  IN     VARCHAR2,
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

        l_agreement_id  fun_net_agreements_all.agreement_id%TYPE;
    BEGIN

        IF x_agreement_id IS NULL THEN
            SELECT fun_net_agreements_s.NEXTVAL INTO l_agreement_id FROM DUAL;
            x_agreement_id := l_agreement_id;
        ELSE
            l_agreement_id := x_agreement_id;
        END IF;

        INSERT INTO fun_net_agreements (
            agreement_id,
            object_version_number,
            agreement_name,
            partner_reference,
            agreement_start_date,
            agreement_end_date,
            in_process_flag,
            sel_rec_past_due_txns_flag,
            days_past_due,
            net_currency_rule_code,
            net_order_rule_code,
            net_balance_rule_code,
            shikyu_rule_code,
            bank_account_id,
            net_currency_code,
            approver_name,
            non_response_action_code,
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
            l_agreement_id,
            x_object_version_number,
            x_agreement_name,
            x_partner_reference,
            x_agreement_start_date,
            x_agreement_end_date,
            x_in_process_flag,
            x_sel_rec_past_due_txns_flag,
            x_days_past_due,
            x_net_currency_rule_code,
            x_net_order_rule_code,
            x_net_balance_rule_code,
            x_shikyu_rule_code,
            x_bank_account_id,
            x_net_currency_code,
            x_approver_name,
            x_non_response_action_code,
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

        IF ( SQL%NOTFOUND ) THEN
            RAISE NO_DATA_FOUND;
        END IF;

    END Insert_Row;


    PROCEDURE Update_Row (
        x_agreement_id              IN     NUMBER,
        x_object_version_number     IN     NUMBER,
        x_agreement_name            IN     VARCHAR2,
        x_partner_reference         IN     VARCHAR2,
        x_agreement_start_date      IN     DATE,
        x_agreement_end_date        IN     DATE,
        x_in_process_flag           IN     VARCHAR2,
        x_sel_rec_past_due_txns_flag IN    VARCHAR2,
        x_days_past_due             IN     NUMBER,
        x_net_currency_rule_code    IN     VARCHAR2,
        x_net_order_rule_code       IN     VARCHAR2,
        x_net_balance_rule_code     IN     VARCHAR2,
        x_shikyu_rule_code          IN     VARCHAR2,
        x_bank_account_id           IN     NUMBER,
        x_net_currency_code         IN     VARCHAR2,
        x_approver_name             IN     VARCHAR2,
        x_non_response_action_code  IN     VARCHAR2,
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

        UPDATE fun_net_agreements SET
            agreement_id             =    x_agreement_id,
            object_version_number    =    x_object_version_number,
            agreement_name           =    x_agreement_name,
            partner_reference        =    x_partner_reference,
            agreement_start_date     =    x_agreement_start_date,
            agreement_end_date       =    x_agreement_end_date,
            in_process_flag          =    x_in_process_flag,
            sel_rec_past_due_txns_flag    =    x_sel_rec_past_due_txns_flag,
            days_past_due            =    x_days_past_due,
            net_currency_rule_code   =    x_net_currency_rule_code,
            net_order_rule_code      =    x_net_order_rule_code,
            net_balance_rule_code    =    x_net_balance_rule_code,
            shikyu_rule_code         =    x_shikyu_rule_code,
            bank_account_id          =    x_bank_account_id,
            net_currency_code        =    x_net_currency_code,
            approver_name            =    x_approver_name,
            non_response_action_code =    x_non_response_action_code,
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
            last_update_login        = DECODE(FND_GLOBAL.conc_login_id,null,FND_GLOBAL.login_id,-1,FND_GLOBAL.login_id,FND_GLOBAL.conc_login_id),
            last_update_date         = SYSDATE,
            last_updated_by          = NVL(FND_GLOBAL.user_id,-1)
        WHERE agreement_id = x_agreement_id;

        IF ( SQL%NOTFOUND ) THEN
            RAISE NO_DATA_FOUND;
        END IF;

    END Update_Row;

    PROCEDURE Update_Row (
        x_agreement_id              IN     NUMBER,
        x_in_process_flag           IN     VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        UPDATE fun_net_agreements
        SET in_process_flag = x_in_process_flag
        WHERE agreement_id = x_agreement_id;

        IF SQL%FOUND THEN
            COMMIT;
        ELSE
            ROLLBACK;
        END IF;
    END Update_Row;

    PROCEDURE Select_Row (
        x_agreement_id              IN OUT NOCOPY      NUMBER,
        x_object_version_number     IN OUT NOCOPY      NUMBER,
        x_agreement_name            IN OUT NOCOPY      VARCHAR2,
        x_partner_reference         IN OUT NOCOPY      VARCHAR2,
        x_agreement_start_date      IN OUT NOCOPY      DATE,
        x_agreement_end_date        IN OUT NOCOPY      DATE,
        x_in_process_flag           IN OUT NOCOPY      VARCHAR2,
        x_sel_rec_past_due_txns_flag IN OUT NOCOPY     VARCHAR2,
        x_days_past_due             IN OUT NOCOPY      NUMBER,
        x_net_currency_rule_code    IN OUT NOCOPY      VARCHAR2,
        x_net_order_rule_code       IN OUT NOCOPY      VARCHAR2,
        x_net_balance_rule_code     IN OUT NOCOPY      VARCHAR2,
        x_shikyu_rule_code          IN OUT NOCOPY      VARCHAR2,
        x_bank_account_id           IN OUT NOCOPY      NUMBER,
        x_net_currency_code         IN OUT NOCOPY      VARCHAR2,
        x_approver_name             IN OUT NOCOPY      VARCHAR2,
        x_non_response_action_code  IN OUT NOCOPY      VARCHAR2,
        x_org_id                    IN OUT NOCOPY      NUMBER,
        x_attribute_category        IN OUT NOCOPY      VARCHAR2,
        x_attribute1                IN OUT NOCOPY      VARCHAR2,
        x_attribute2                IN OUT NOCOPY      VARCHAR2,
        x_attribute3                IN OUT NOCOPY      VARCHAR2,
        x_attribute4                IN OUT NOCOPY      VARCHAR2,
        x_attribute5                IN OUT NOCOPY      VARCHAR2,
        x_attribute6                IN OUT NOCOPY      VARCHAR2,
        x_attribute7                IN OUT NOCOPY      VARCHAR2,
        x_attribute8                IN OUT NOCOPY      VARCHAR2,
        x_attribute9                IN OUT NOCOPY      VARCHAR2,
        x_attribute10               IN OUT NOCOPY      VARCHAR2,
        x_attribute11               IN OUT NOCOPY      VARCHAR2,
        x_attribute12               IN OUT NOCOPY      VARCHAR2,
        x_attribute13               IN OUT NOCOPY      VARCHAR2,
        x_attribute14               IN OUT NOCOPY      VARCHAR2,
        x_attribute15               IN OUT NOCOPY      VARCHAR2,
        x_attribute16               IN OUT NOCOPY      VARCHAR2,
        x_attribute17               IN OUT NOCOPY      VARCHAR2,
        x_attribute18               IN OUT NOCOPY      VARCHAR2,
        x_attribute19               IN OUT NOCOPY      VARCHAR2,
        x_attribute20               IN OUT NOCOPY      VARCHAR2
    ) IS

    BEGIN

        SELECT
            agreement_id,
            object_version_number,
            agreement_name,
            partner_reference,
            agreement_start_date,
            agreement_end_date,
            in_process_flag,
            sel_rec_past_due_txns_flag,
            days_past_due,
            net_currency_rule_code,
            net_order_rule_code,
            net_balance_rule_code,
            shikyu_rule_code,
            bank_account_id,
            net_currency_code,
            approver_name,
            non_response_action_code,
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
            x_agreement_id,
            x_object_version_number,
            x_agreement_name,
            x_partner_reference,
            x_agreement_start_date,
            x_agreement_end_date,
            x_in_process_flag,
            x_sel_rec_past_due_txns_flag,
            x_days_past_due,
            x_net_currency_rule_code,
            x_net_order_rule_code,
            x_net_balance_rule_code,
            x_shikyu_rule_code,
            x_bank_account_id,
            x_net_currency_code,
            x_approver_name,
            x_non_response_action_code,
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
        FROM fun_net_agreements
        WHERE agreement_id = x_agreement_id;

        IF ( SQL%NOTFOUND ) THEN
            RAISE NO_DATA_FOUND;
        END IF;

    END Select_Row;


    PROCEDURE Delete_Row (
        x_agreement_id     				 IN				 NUMBER
    ) IS

    BEGIN

        DELETE fun_net_agreements
        WHERE  agreement_id = x_agreement_id;

        IF ( SQL%NOTFOUND ) THEN
            RAISE NO_DATA_FOUND;
        END IF;

    END Delete_Row;


END FUN_NET_AGREEMENTS_PKG;

/
