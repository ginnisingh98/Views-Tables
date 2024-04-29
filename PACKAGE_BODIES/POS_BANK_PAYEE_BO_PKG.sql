--------------------------------------------------------
--  DDL for Package Body POS_BANK_PAYEE_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_BANK_PAYEE_BO_PKG" AS
/* $Header: POSSPBAPB.pls 120.0.12010000.5 2014/04/14 23:54:36 dalu noship $ */
    /*#
    * Use this routine to get bank payee bo
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_party_id The party id
    * @param x_pos_bank_payee_bo_tbl The bank payee bo table
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Get POS Bank Payee BO Table
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */

    PROCEDURE get_pos_bank_payee_bo_tbl(p_api_version           IN NUMBER DEFAULT NULL,
                                        p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
                                        p_party_id              IN NUMBER,
                                        p_orig_system           IN VARCHAR2,
                                        p_orig_system_reference VARCHAR2,
                                        x_pos_bank_payee_bo_tbl OUT NOCOPY pos_bank_payee_bo_tbl,
                                        x_return_status         OUT NOCOPY VARCHAR2,
                                        x_msg_count             OUT NOCOPY NUMBER,
                                        x_msg_data              OUT NOCOPY VARCHAR2) IS

        l_pos_bank_payee_bo_tbl pos_bank_payee_bo_tbl := pos_bank_payee_bo_tbl();
        l_party_id              NUMBER;
    BEGIN

        IF p_party_id IS NULL OR p_party_id = 0 THEN
            l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                           p_orig_system_reference);
        ELSE
            l_party_id := p_party_id;
        END IF;


        SELECT pos_bank_payee_bo(payee.ext_payee_id,
                                 payee.payee_party_id,
                                 payee.payment_function,
                                 payee.exclusive_payment_flag,
                                 payee.created_by,
                                 payee.creation_date,
                                 payee.last_updated_by,
                                 payee.last_update_date,
                                 payee.last_update_login,
                                 payee.object_version_number,
                                 payee.party_site_id,
                                 payee.supplier_site_id,
                                 payee.org_id,
                                 payee.org_type,
                                 payee.default_payment_method_code,
                                 payee.ece_tp_location_code,
                                 payee.bank_charge_bearer,
                                 payee.bank_instruction1_code,
                                 payee.bank_instruction2_code,
                                 payee.bank_instruction_details,
                                 payee.payment_reason_code,
                                 payee.payment_reason_comments,
                                 payee.inactive_date,
                                 payee.payment_text_message1,
                                 payee.payment_text_message2,
                                 payee.payment_text_message3,
                                 payee.delivery_channel_code,
                                 payee.payment_format_code,
                                 payee.settlement_priority,
                                 payee.remit_advice_delivery_method,
                                 payee.remit_advice_email,
                                 payee.remit_advice_fax,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 instr.instrument_id,        -- Bug 12903268: add bank account id into the object
                                 instr.order_of_preference,  -- Bug 13529064: add account details
                                 instr.start_date,
                                 instr.end_date,
                                 instr.attribute_category,   -- Bug 18556731: add DFF fields of payment instrument assignments
                                 instr.attribute1,
                                 instr.attribute2,
                                 instr.attribute3,
                                 instr.attribute4,
                                 instr.attribute5,
                                 instr.attribute6,
                                 instr.attribute7,
                                 instr.attribute8,
                                 instr.attribute9,
                                 instr.attribute10,
                                 instr.attribute11,
                                 instr.attribute12,
                                 instr.attribute13,
                                 instr.attribute14,
                                 instr.attribute15) BULK COLLECT
        INTO   l_pos_bank_payee_bo_tbl
        FROM   iby_external_payees_all payee, iby_pmt_instr_uses_all instr
        WHERE  payee_party_id = l_party_id
        AND    payee.ext_payee_id = instr.ext_pmt_party_id (+);  -- Bug 12903268: Associate bank account id with payee.

        x_pos_bank_payee_bo_tbl := l_pos_bank_payee_bo_tbl;
    EXCEPTION
        WHEN fnd_api.g_exc_error THEN

            x_return_status := fnd_api.g_ret_sts_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN fnd_api.g_exc_unexpected_error THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            x_msg_count     := 1;
            x_msg_data      := SQLCODE || SQLERRM;
        WHEN OTHERS THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;

            x_msg_count := 1;
            x_msg_data  := SQLCODE || SQLERRM;
    END get_pos_bank_payee_bo_tbl;
    /*#
    * Use this routine to create bank payee bo
    * @param p_api_version The version of API
    * @param p_init_msg_list The Initialization message list
    * @param p_ext_payee_tab The external payee table
    * @param x_pos_bank_payee_bo_tbl The bank payee bo table - iby_disbursement_setup_pub.external_payee_tab_type
    * @param x_return_status The return status
    * @param x_msg_count The message count
    * @param x_msg_data The message data
    * @param x_ext_payee_id_tab The external payee id table -iby_disbursement_setup_pub.ext_payee_id_tab_type
    * @param x_ext_payee_status_tab The external payee status table -  iby_disbursement_setup_pub.ext_payee_create_tab_type
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create POS Bank Payee BO Table
    * @rep:catagory BUSSINESS_ENTITY AP_SUPPLIER
    */
    PROCEDURE create_pos_bank_payee_bo_tbl(p_api_version           IN NUMBER,
                                           p_init_msg_list         IN VARCHAR2 DEFAULT fnd_api.g_false,
                                           p_pos_bank_payee_bo_tbl IN pos_bank_payee_bo_tbl,
                                           p_party_id              IN NUMBER,
                                           p_orig_system           IN VARCHAR2,
                                           p_orig_system_reference IN VARCHAR2,
                                           p_create_update_flag    IN VARCHAR2,
                                           x_return_status         OUT NOCOPY VARCHAR2,
                                           x_msg_count             OUT NOCOPY NUMBER,
                                           x_msg_data              OUT NOCOPY VARCHAR2) IS
        v_row_exists           NUMBER := 0;
        p_ext_payee_tab        iby_disbursement_setup_pub.external_payee_tab_type;
        x_ext_payee_id_tab     iby_disbursement_setup_pub.ext_payee_id_tab_type;
        x_ext_payee_status_tab iby_disbursement_setup_pub.ext_payee_create_tab_type;
        x_ext_payee_update_status_tab iby_disbursement_setup_pub.Ext_Payee_Update_Tab_Type;
        l_party_id             NUMBER;
        p_ext_payee_id_tab     iby_disbursement_setup_pub.Ext_Payee_ID_Tab_Type;
--        x_ext_payee_status_tab iby_disbursement_setup_pub.ext_payee_update_tab_type;
    BEGIN

        IF p_party_id IS NULL OR p_party_id = 0 THEN
            l_party_id := pos_supplier_bo_dep_pkg.get_party_id(p_orig_system,
                                                           p_orig_system_reference);
        ELSE
            l_party_id := p_party_id;
        END IF;

        FOR i IN p_pos_bank_payee_bo_tbl.first .. p_pos_bank_payee_bo_tbl.last LOOP
            p_ext_payee_tab(i).payee_party_id := l_party_id; -- p_pos_bank_payee_bo_tbl.payee_party_id;
            p_ext_payee_tab(i).payment_function := p_pos_bank_payee_bo_tbl(i)
                                                   .payment_function;
            p_ext_payee_tab(i).exclusive_pay_flag := p_pos_bank_payee_bo_tbl(i)
                                                     .exclusive_payment_flag;
            p_ext_payee_tab(i).payee_party_site_id := p_pos_bank_payee_bo_tbl(i)
                                                      .party_site_id;
            p_ext_payee_tab(i).supplier_site_id := p_pos_bank_payee_bo_tbl(i)
                                                   .supplier_site_id;
            p_ext_payee_tab(i).payer_org_id := p_pos_bank_payee_bo_tbl(i)
                                               .org_id;
            p_ext_payee_tab(i).payer_org_type := p_pos_bank_payee_bo_tbl(i)
                                                 .org_type;
            p_ext_payee_tab(i).default_pmt_method := p_pos_bank_payee_bo_tbl(i)
                                                     .default_payment_method_code;
            p_ext_payee_tab(i).ece_tp_loc_code := p_pos_bank_payee_bo_tbl(i)
                                                  .ece_tp_location_code;
            p_ext_payee_tab(i).bank_charge_bearer := p_pos_bank_payee_bo_tbl(i)
                                                     .bank_charge_bearer;
            p_ext_payee_tab(i).bank_instr1_code := p_pos_bank_payee_bo_tbl(i)
                                                   .bank_instruction1_code;
            p_ext_payee_tab(i).bank_instr2_code := p_pos_bank_payee_bo_tbl(i)
                                                   .bank_instruction2_code;
            p_ext_payee_tab(i).bank_instr_detail := p_pos_bank_payee_bo_tbl(i)
                                                    .bank_instruction_details;
            p_ext_payee_tab(i).pay_reason_code := p_pos_bank_payee_bo_tbl(i)
                                                  .payment_reason_code;
            p_ext_payee_tab(i).pay_reason_com := p_pos_bank_payee_bo_tbl(i)
                                                 .payment_reason_comments;
            p_ext_payee_tab(i).inactive_date := p_pos_bank_payee_bo_tbl(i)
                                                .inactive_date;
            p_ext_payee_tab(i).pay_message1 := p_pos_bank_payee_bo_tbl(i)
                                               .payment_text_message1;
            p_ext_payee_tab(i).pay_message2 := p_pos_bank_payee_bo_tbl(i)
                                               .payment_text_message2;
            p_ext_payee_tab(i).pay_message3 := p_pos_bank_payee_bo_tbl(i)
                                               .payment_text_message3;
            p_ext_payee_tab(i).delivery_channel := p_pos_bank_payee_bo_tbl(i)
                                                   .delivery_channel_code;
            p_ext_payee_tab(i).pmt_format := p_pos_bank_payee_bo_tbl(i)
                                             .payment_format_code;
            p_ext_payee_tab(i).settlement_priority := p_pos_bank_payee_bo_tbl(i)
                                                      .settlement_priority;
            p_ext_payee_tab(i).remit_advice_delivery_method := p_pos_bank_payee_bo_tbl(i)
                                                               .remit_advice_delivery_method;
            p_ext_payee_tab(i).remit_advice_email := p_pos_bank_payee_bo_tbl(i)
                                                     .remit_advice_email;
            p_ext_payee_tab(i).edi_payment_format := p_pos_bank_payee_bo_tbl(i)
                                                     .payment_format_code;
            p_ext_payee_tab(i).edi_transaction_handling := p_pos_bank_payee_bo_tbl(i)
                                                           .edi_transaction_handling;
            p_ext_payee_tab(i).edi_payment_method := p_pos_bank_payee_bo_tbl(i)
                                                     .edi_payment_method;
            p_ext_payee_tab(i).edi_remittance_method := p_pos_bank_payee_bo_tbl(i)
                                                        .edi_remittance_method;
            p_ext_payee_tab(i).edi_remittance_instruction := p_pos_bank_payee_bo_tbl(i)
                                                             .edi_remittance_instruction;
            p_ext_payee_id_tab(i).ext_payee_id := p_pos_bank_payee_bo_tbl(i)
                                                  .ext_payee_id;
        END LOOP;
        IF p_create_update_flag = 'U' THEN

            iby_disbursement_setup_pub.update_external_payee(p_api_version,
                                                             p_init_msg_list,
                                                             p_ext_payee_tab,
                                                             p_ext_payee_id_tab,
                                                             x_return_status,
                                                             x_msg_count,
                                                             x_msg_data,
                                                             x_ext_payee_update_status_tab);
        ELSIF p_create_update_flag = 'C' THEN

            iby_disbursement_setup_pub.create_external_payee(p_api_version,
                                                             p_init_msg_list,
                                                             p_ext_payee_tab,
                                                             x_return_status,
                                                             x_msg_count,
                                                             x_msg_data,
                                                             x_ext_payee_id_tab,
                                                             x_ext_payee_status_tab);
        END IF;
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

    END;

END pos_bank_payee_bo_pkg;

/
