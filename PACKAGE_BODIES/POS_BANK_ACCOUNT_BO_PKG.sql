--------------------------------------------------------
--  DDL for Package Body POS_BANK_ACCOUNT_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_BANK_ACCOUNT_BO_PKG" AS
/* $Header: POSSPBAAB.pls 120.0.12010000.8 2013/02/13 21:33:57 riren noship $ */
    /*#
    * Use this routine to get bank accont bo
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_party_id The party_id
    * @param x_pos_bank_account_bo_tbl The bank account bo
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Get POS Bank Account BO Table
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
    PROCEDURE get_pos_bank_account_bo_tbl(p_api_version             IN NUMBER DEFAULT NULL,
                                          p_init_msg_list           IN VARCHAR2 DEFAULT NULL,
                                          p_party_id                IN NUMBER,
                                          p_orig_system             IN VARCHAR2,
                                          p_orig_system_reference   IN VARCHAR2,
                                          x_pos_bank_account_bo_tbl OUT NOCOPY pos_bank_account_bo_tbl,
                                          x_return_status           OUT NOCOPY VARCHAR2,
                                          x_msg_count               OUT NOCOPY NUMBER,
                                          x_msg_data                OUT NOCOPY VARCHAR2) IS

        l_pos_bank_account_bo_tbl pos_bank_account_bo_tbl := pos_bank_account_bo_tbl();
        l_party_id                NUMBER := 0;

    BEGIN

        IF p_party_id IS NULL THEN
            l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                               p_orig_system_reference);
        ELSE
            l_party_id := p_party_id;
        END IF;

        -- Bug 12795884: Removed hash columns for account number and IBAN to avoid XML conversion error
        SELECT pos_bank_account_bo(eb.ext_bank_account_id,
                                   eb.bank_id,
                                   eb.country_code,
                                   bp.party_name,
                                   bapr.bank_or_branch_number,
                                   eb.branch_id,
                                   br.party_name,
                                   brpr.bank_or_branch_number,
                                   branchca.class_code,
                                   s.location_id,
                                   branchcp.eft_swift_code,
                                   eb.ext_bank_account_id,
                                   eb.bank_account_name,
                                   eb.masked_bank_account_num,
                                   eb.currency_code,
                                   eb.description,
                                   eb.check_digits,
                                   decode(eb.currency_code, NULL, 'Y', 'N'),
                                   eb.bank_account_name_alt,
                                   eb.short_acct_name,
                                   eb.account_suffix,
                                   eb.masked_iban,
                                   ow.account_owner_party_id,
                                   op.party_name,
                                   eb.account_classification,
                                   eb.bank_account_type,
                                   eb.agency_location_code,
                                   eb.start_date,
                                   eb.end_date,
                                   eb.payment_factor_flag,
                                   eb.foreign_payment_use_flag,
                                   eb.exchange_rate_agreement_num,
                                   eb.exchange_rate_agreement_type,
                                   eb.exchange_rate,
                                   eb.hedging_contract_reference,
                                   eb.secondary_account_reference,
                                   eb.attribute_category,
                                   eb.attribute1,
                                   eb.attribute2,
                                   eb.attribute3,
                                   eb.attribute4,
                                   eb.attribute5,
                                   eb.attribute6,
                                   eb.attribute7,
                                   eb.attribute8,
                                   eb.attribute9,
                                   eb.attribute10,
                                   eb.attribute11,
                                   eb.attribute12,
                                   eb.attribute13,
                                   eb.attribute14,
                                   eb.attribute15,
                                   eb.object_version_number,
                                   eb.bank_account_num_electronic,
                                   NULL,
                                   NULL,
                                   NULL
                                   /*,
                                   brpr.bank_code,
                                   eb.encrypted*/)

               BULK COLLECT
        INTO   l_pos_bank_account_bo_tbl
        FROM   hz_organization_profiles bapr,
               hz_organization_profiles brpr,
               hz_parties               bp,
               hz_party_sites           s,
               iby_account_owners       ow,
               hz_parties               br,
               hz_parties               op,
               iby_ext_bank_accounts    eb,
               hz_code_assignments      branchca,
               hz_contact_points        branchcp,

         -- Bug 13096283/13586778: Publish bank account info for non-primary owners of factor account
         -- Part 1: Get all suppliers that own same bank account(s) with the current supplier (l_party_id)
              (SELECT DISTINCT a1.account_owner_party_id,
                      a1.ext_bank_account_id
               FROM   iby_account_owners a1,
						          iby_external_payees_all payee,
                      iby_pmt_instr_uses_all  instr
				       WHERE  payee.ext_payee_id     = instr.ext_pmt_party_id
				       AND    payee_party_id         = l_party_id
				       AND    instr.instrument_id    = a1.ext_bank_account_id
               AND    instr.instrument_type  = 'BANKACCOUNT'
				       AND    instr.payment_function = 'PAYABLES_DISB'
              ) supp
          -- End Bug 13096283 Part 1
        WHERE  eb.bank_id = bp.party_id(+)
        AND    eb.bank_id = bapr.party_id(+)
        AND    eb.branch_id = br.party_id(+)
        AND    eb.branch_id = brpr.party_id(+)
        AND    eb.ext_bank_account_id = ow.ext_bank_account_id(+)
        AND    ow.primary_flag(+) = 'Y'
        AND    nvl(ow.end_date, SYSDATE + 10) > SYSDATE
        AND    ow.account_owner_party_id = op.party_id(+)
        AND    (br.party_id = s.party_id(+))
        AND    (s.identifying_address_flag(+) = 'Y')
        AND    (branchcp.owner_table_name(+) = 'HZ_PARTIES')
        AND    (branchcp.owner_table_id(+) = eb.branch_id)
        AND    (branchcp.contact_point_type(+) = 'EFT')
        AND    (nvl(branchcp.status(+), 'A') = 'A')
        AND    (branchca.class_category(+) = 'BANK_BRANCH_TYPE')  -- Bug 13586778: Publish Branch Type
        AND    (branchca.owner_table_name(+) = 'HZ_PARTIES')
        AND    (branchca.owner_table_id(+) = eb.branch_id)
        AND    SYSDATE BETWEEN              -- Bug 14621927: Check effect end date to prevent publishing ineffective bank record
               trunc(bapr.effective_start_date) AND
               nvl(trunc(bapr.effective_end_date), SYSDATE + 1)
        AND    SYSDATE BETWEEN
               trunc(brpr.effective_start_date) AND
               nvl(trunc(brpr.effective_end_date), SYSDATE + 1)
        AND    op.party_id = supp.account_owner_party_id  -- Bug 13096283 Part 2: Join to get primary owner info for the bank account
        AND    eb.ext_bank_account_id = supp.ext_bank_account_id  -- Bug 13586778: only select account that belongs to the current supplier.
        AND    branchca.primary_flag = 'Y';  -- Bug 16205262: Check primary_flag to prevent publishing duplicated bank account info.

        x_pos_bank_account_bo_tbl := l_pos_bank_account_bo_tbl;
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

    END get_pos_bank_account_bo_tbl;

    /*#
    * Use this routine to create bank account bo
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_ext_bank_acct_rec The external bank account record
    * @param x_acct_id The bank account id
    * @param x_response The result record type
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create POS Bank Account BO
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */

    PROCEDURE create_pos_bank_account_bo(p_api_version   IN NUMBER,
                                         p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.g_false,
                                         p_party_id              IN NUMBER,
                                         p_orig_system           IN VARCHAR2,
                                         p_orig_system_reference IN VARCHAR2,
                                         p_create_update_flag    IN VARCHAR2,
                                         p_pos_bank_account_bo   IN pos_bank_account_bo_tbl,
                                         x_acct_id               OUT NOCOPY NUMBER,
                                         x_return_status         OUT NOCOPY VARCHAR2,
                                         x_msg_count             OUT NOCOPY NUMBER,
                                         x_msg_data              OUT NOCOPY VARCHAR2)

     IS
        v_row_exists        NUMBER := 0;
        l_ext_bank_acct_rec iby_ext_bankacct_pub.extbankacct_rec_type;
        l_response          iby_fndcpt_common_pub.result_rec_type;

    BEGIN

        /*l_ext_bank_acct_rec := p_ext_bank_acct_rec;*/
        FOR i IN p_pos_bank_account_bo.first .. p_pos_bank_account_bo.last LOOP
            l_ext_bank_acct_rec.bank_account_id              := p_pos_bank_account_bo(i).bank_account_id;
            l_ext_bank_acct_rec.country_code                 := p_pos_bank_account_bo(i).country_code;
            l_ext_bank_acct_rec.branch_id                    := p_pos_bank_account_bo(i).branch_id;
            l_ext_bank_acct_rec.bank_id                      := p_pos_bank_account_bo(i).bank_id;
            l_ext_bank_acct_rec.acct_owner_party_id          := p_pos_bank_account_bo(i).primary_acct_owner_party_id;
            l_ext_bank_acct_rec.bank_account_name            := p_pos_bank_account_bo(i).bank_account_name;
            l_ext_bank_acct_rec.bank_account_num             := p_pos_bank_account_bo(i).bank_account_number;
            l_ext_bank_acct_rec.currency                     := p_pos_bank_account_bo(i).currency_code;
            l_ext_bank_acct_rec.iban                         := p_pos_bank_account_bo(i).iban_number;
            l_ext_bank_acct_rec.check_digits                 := p_pos_bank_account_bo(i).check_digits;
            l_ext_bank_acct_rec.multi_currency_allowed_flag  := p_pos_bank_account_bo(i).multi_currency_allowed_flag;
            l_ext_bank_acct_rec.alternate_acct_name          := p_pos_bank_account_bo(i).alternate_account_name;
            l_ext_bank_acct_rec.short_acct_name              := p_pos_bank_account_bo(i).short_acct_name;
            l_ext_bank_acct_rec.acct_type                    := p_pos_bank_account_bo(i).bank_account_type;
            l_ext_bank_acct_rec.acct_suffix                  := p_pos_bank_account_bo(i).account_suffix;
            l_ext_bank_acct_rec.description                  := p_pos_bank_account_bo(i).description;
            l_ext_bank_acct_rec.agency_location_code         := p_pos_bank_account_bo(i).agency_location_code;
            l_ext_bank_acct_rec.foreign_payment_use_flag     := p_pos_bank_account_bo(i).foreign_payment_use_flag;
            l_ext_bank_acct_rec.exchange_rate_agreement_num  := p_pos_bank_account_bo(i).exchange_rate_agreement_num;
            l_ext_bank_acct_rec.exchange_rate_agreement_type := p_pos_bank_account_bo(i).exchange_rate_agreement_type;
            l_ext_bank_acct_rec.exchange_rate                := p_pos_bank_account_bo(i).exchange_rate;
            l_ext_bank_acct_rec.payment_factor_flag          := p_pos_bank_account_bo(i).payment_factor_flag;
            l_ext_bank_acct_rec.status                       := p_pos_bank_account_bo(i).status;
            l_ext_bank_acct_rec.end_date                     := p_pos_bank_account_bo(i).end_date;
            l_ext_bank_acct_rec.start_date                   := p_pos_bank_account_bo(i).start_date;
            l_ext_bank_acct_rec.hedging_contract_reference   := p_pos_bank_account_bo(i).hedging_contract_reference;
            l_ext_bank_acct_rec.attribute_category           := p_pos_bank_account_bo(i).attribute_category;
            l_ext_bank_acct_rec.attribute1                   := p_pos_bank_account_bo(i).attribute1;
            l_ext_bank_acct_rec.attribute2                   := p_pos_bank_account_bo(i).attribute2;
            l_ext_bank_acct_rec.attribute3                   := p_pos_bank_account_bo(i).attribute3;
            l_ext_bank_acct_rec.attribute4                   := p_pos_bank_account_bo(i).attribute4;
            l_ext_bank_acct_rec.attribute5                   := p_pos_bank_account_bo(i).attribute5;
            l_ext_bank_acct_rec.attribute6                   := p_pos_bank_account_bo(i).attribute6;
            l_ext_bank_acct_rec.attribute7                   := p_pos_bank_account_bo(i).attribute7;
            l_ext_bank_acct_rec.attribute8                   := p_pos_bank_account_bo(i).attribute8;
            l_ext_bank_acct_rec.attribute9                   := p_pos_bank_account_bo(i).attribute9;
            l_ext_bank_acct_rec.attribute10                  := p_pos_bank_account_bo(i).attribute10;
            l_ext_bank_acct_rec.attribute11                  := p_pos_bank_account_bo(i).attribute11;
            l_ext_bank_acct_rec.attribute12                  := p_pos_bank_account_bo(i).attribute12;
            l_ext_bank_acct_rec.attribute13                  := p_pos_bank_account_bo(i).attribute13;
            l_ext_bank_acct_rec.attribute14                  := p_pos_bank_account_bo(i).attribute14;
            l_ext_bank_acct_rec.attribute15                  := p_pos_bank_account_bo(i).attribute15;
            l_ext_bank_acct_rec.object_version_number        := p_pos_bank_account_bo(i).object_version_number;
            l_ext_bank_acct_rec.secondary_account_reference  := p_pos_bank_account_bo(i).secondary_account_reference;
            IF p_create_update_flag = 'C' THEN
                iby_ext_bankacct_pub.create_ext_bank_acct(p_api_version,
                                                          p_init_msg_list,
                                                          l_ext_bank_acct_rec,
                                                          x_acct_id,
                                                          x_return_status,
                                                          x_msg_count,
                                                          x_msg_data,
                                                          l_response);
            ELSIF p_create_update_flag = 'U' THEN
                iby_ext_bankacct_pub.update_ext_bank_acct(p_api_version,
                                                          p_init_msg_list,
                                                          l_ext_bank_acct_rec,
                                                          x_return_status,
                                                          x_msg_count,
                                                          x_msg_data,
                                                          l_response);
            END IF;
        END LOOP;
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END create_pos_bank_account_bo;

END pos_bank_account_bo_pkg;

/
