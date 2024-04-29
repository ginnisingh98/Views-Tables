--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_LOCKBOX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_LOCKBOX" AUTHID CURRENT_USER AS
/* $Header: IGSFI85S.pls 115.4 2003/08/27 09:48:58 shtatiko noship $ */

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Package for the Lockbox Processes

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     shtatiko   28-AUG-203   Enh# 3045007, Added two columns, dflt_cr_type_id and balance_amount to LB_RECEIPT_REC
     pathipat   21-Aug-2003  Enh 3076768 - Automatic Release of Holds build
                             Added column holds_released_yn to LB_RECEIPT_REC
    ***************************************************************** */

  TYPE LB_INT_REC IS RECORD(row_id                       ROWID,
                            lockbox_interface_id         igs_fi_lockbox_ints.lockbox_interface_id%TYPE,
                            record_identifier_cd         igs_fi_lockbox_ints.record_identifier_cd%TYPE,
                            record_status                igs_fi_lockbox_ints.record_status%TYPE,
                            deposit_date                 igs_fi_lockbox_ints.deposit_date%TYPE,
                            transmission_record_count    igs_fi_lockbox_ints.transmission_record_count%TYPE,
                            transmission_amt             igs_fi_lockbox_ints.transmission_amt%TYPE,
                            lockbox_name                 igs_fi_lockbox_ints.lockbox_name%TYPE,
                            lockbox_batch_count          igs_fi_lockbox_ints.lockbox_batch_count%TYPE,
                            lockbox_record_count         igs_fi_lockbox_ints.lockbox_record_count%TYPE,
                            lockbox_amt                  igs_fi_lockbox_ints.lockbox_amt%TYPE,
                            batch_name                   igs_fi_lockbox_ints.batch_name%TYPE,
                            batch_amt                    igs_fi_lockbox_ints.batch_amt%TYPE,
                            batch_record_count           igs_fi_lockbox_ints.batch_record_count%TYPE,
                            item_number                  igs_fi_lockbox_ints.item_number%TYPE,
                            receipt_amt                  igs_fi_lockbox_ints.receipt_amt%TYPE,
                            check_cd                     igs_fi_lockbox_ints.check_cd%TYPE,
                            party_number                 igs_fi_lockbox_ints.party_number%TYPE,
                            payer_name                   igs_fi_lockbox_ints.payer_name%TYPE,
                            charge_cd1                   igs_fi_lockbox_ints.charge_cd1%TYPE,
                            charge_cd2                   igs_fi_lockbox_ints.charge_cd2%TYPE,
                            charge_cd3                   igs_fi_lockbox_ints.charge_cd3%TYPE,
                            charge_cd4                   igs_fi_lockbox_ints.charge_cd4%TYPE,
                            charge_cd5                   igs_fi_lockbox_ints.charge_cd5%TYPE,
                            charge_cd6                   igs_fi_lockbox_ints.charge_cd6%TYPE,
                            charge_cd7                   igs_fi_lockbox_ints.charge_cd7%TYPE,
                            charge_cd8                   igs_fi_lockbox_ints.charge_cd8%TYPE,
                            applied_amt1                 igs_fi_lockbox_ints.applied_amt1%TYPE,
                            applied_amt2                 igs_fi_lockbox_ints.applied_amt2%TYPE,
                            applied_amt3                 igs_fi_lockbox_ints.applied_amt3%TYPE,
                            applied_amt4                 igs_fi_lockbox_ints.applied_amt4%TYPE,
                            applied_amt5                 igs_fi_lockbox_ints.applied_amt5%TYPE,
                            applied_amt6                 igs_fi_lockbox_ints.applied_amt6%TYPE,
                            applied_amt7                 igs_fi_lockbox_ints.applied_amt7%TYPE,
                            applied_amt8                 igs_fi_lockbox_ints.applied_amt8%TYPE,
                            credit_type_cd               igs_fi_lockbox_ints.credit_type_cd%TYPE,
                            fee_cal_instance_cd          igs_fi_lockbox_ints.fee_cal_instance_cd%TYPE,
                            adm_application_id           igs_fi_lockbox_ints.adm_application_id%TYPE,
                            attribute_category           igs_fi_lockbox_ints.attribute_category%TYPE,
                            attribute1                   igs_fi_lockbox_ints.attribute1%TYPE,
                            attribute2                   igs_fi_lockbox_ints.attribute2%TYPE,
                            attribute3                   igs_fi_lockbox_ints.attribute3%TYPE,
                            attribute4                   igs_fi_lockbox_ints.attribute4%TYPE,
                            attribute5                   igs_fi_lockbox_ints.attribute5%TYPE,
                            attribute6                   igs_fi_lockbox_ints.attribute6%TYPE,
                            attribute7                   igs_fi_lockbox_ints.attribute7%TYPE,
                            attribute8                   igs_fi_lockbox_ints.attribute8%TYPE,
                            attribute9                   igs_fi_lockbox_ints.attribute9%TYPE,
                            attribute10                  igs_fi_lockbox_ints.attribute10%TYPE,
                            attribute11                  igs_fi_lockbox_ints.attribute11%TYPE,
                            attribute12                  igs_fi_lockbox_ints.attribute12%TYPE,
                            attribute13                  igs_fi_lockbox_ints.attribute13%TYPE,
                            attribute14                  igs_fi_lockbox_ints.attribute14%TYPE,
                            attribute15                  igs_fi_lockbox_ints.attribute15%TYPE,
                            attribute16                  igs_fi_lockbox_ints.attribute16%TYPE,
                            attribute17                  igs_fi_lockbox_ints.attribute17%TYPE,
                            attribute18                  igs_fi_lockbox_ints.attribute18%TYPE,
                            attribute19                  igs_fi_lockbox_ints.attribute19%TYPE,
                            attribute20                  igs_fi_lockbox_ints.attribute20%TYPE,
                            system_record_identifier     igs_lookup_values.lookup_code%TYPE);

  TYPE LB_RECEIPT_REC IS RECORD(row_id                          ROWID,
                                lockbox_interface_id            igs_fi_lb_rect_errs.lockbox_interface_id%TYPE,
                                system_record_identifier        igs_lookup_values.lookup_code%TYPE,
                                deposit_date                    igs_fi_lb_rect_errs.deposit_date%TYPE,
                                lockbox_name                    igs_fi_lb_rect_errs.lockbox_name%TYPE,
                                batch_name                      igs_fi_lb_rect_errs.batch_name%TYPE,
                                item_number                     igs_fi_lb_rect_errs.item_number%TYPE,
                                receipt_amt                     igs_fi_lb_rect_errs.receipt_amt%TYPE,
                                check_cd                        igs_fi_lb_rect_errs.check_cd%TYPE,
                                party_number                    igs_fi_lb_rect_errs.party_number%TYPE,
                                mapped_party_id                 hz_parties.party_id%TYPE,
                                payer_name                      igs_fi_lb_rect_errs.payer_name%TYPE,
                                charge_cd1                      igs_fi_lb_rect_errs.charge_cd1%TYPE,
                                charge_cd2                      igs_fi_lb_rect_errs.charge_cd2%TYPE,
                                charge_cd3                      igs_fi_lb_rect_errs.charge_cd3%TYPE,
                                charge_cd4                      igs_fi_lb_rect_errs.charge_cd4%TYPE,
                                charge_cd5                      igs_fi_lb_rect_errs.charge_cd5%TYPE,
                                charge_cd6                      igs_fi_lb_rect_errs.charge_cd6%TYPE,
                                charge_cd7                      igs_fi_lb_rect_errs.charge_cd7%TYPE,
                                charge_cd8                      igs_fi_lb_rect_errs.charge_cd8%TYPE,
                                applied_amt1                    igs_fi_lb_rect_errs.applied_amt1%TYPE,
                                applied_amt2                    igs_fi_lb_rect_errs.applied_amt2%TYPE,
                                applied_amt3                    igs_fi_lb_rect_errs.applied_amt3%TYPE,
                                applied_amt4                    igs_fi_lb_rect_errs.applied_amt4%TYPE,
                                applied_amt5                    igs_fi_lb_rect_errs.applied_amt5%TYPE,
                                applied_amt6                    igs_fi_lb_rect_errs.applied_amt6%TYPE,
                                applied_amt7                    igs_fi_lb_rect_errs.applied_amt7%TYPE,
                                applied_amt8                    igs_fi_lb_rect_errs.applied_amt8%TYPE,
                                credit_type_cd                  igs_fi_lb_rect_errs.credit_type_cd%TYPE,
                                mapped_credit_type_id           igs_fi_cr_types.credit_type_id%TYPE,
                                fee_cal_instance_cd             igs_fi_lb_rect_errs.fee_cal_instance_cd%TYPE,
                                mapped_fee_cal_type             igs_ca_inst.cal_type%TYPE,
                                mapped_fee_ci_sequence_numbeR   igs_ca_inst.sequence_number%TYPE,
                                adm_application_id              igs_fi_lb_rect_errs.adm_application_id%TYPE,
                                attribute_category              igs_fi_lb_rect_errs.attribute_category%TYPE,
                                attribute1                      igs_fi_lb_rect_errs.attribute1%TYPE,
                                attribute2                      igs_fi_lb_rect_errs.attribute2%TYPE,
                                attribute3                      igs_fi_lb_rect_errs.attribute3%TYPE,
                                attribute4                      igs_fi_lb_rect_errs.attribute4%TYPE,
                                attribute5                      igs_fi_lb_rect_errs.attribute5%TYPE,
                                attribute6                      igs_fi_lb_rect_errs.attribute6%TYPE,
                                attribute7                      igs_fi_lb_rect_errs.attribute7%TYPE,
                                attribute8                      igs_fi_lb_rect_errs.attribute8%TYPE,
                                attribute9                      igs_fi_lb_rect_errs.attribute9%TYPE,
                                attribute10                     igs_fi_lb_rect_errs.attribute10%TYPE,
                                attribute11                     igs_fi_lb_rect_errs.attribute11%TYPE,
                                attribute12                     igs_fi_lb_rect_errs.attribute12%TYPE,
                                attribute13                     igs_fi_lb_rect_errs.attribute13%TYPE,
                                attribute14                     igs_fi_lb_rect_errs.attribute14%TYPE,
                                attribute15                     igs_fi_lb_rect_errs.attribute15%TYPE,
                                attribute16                     igs_fi_lb_rect_errs.attribute16%TYPE,
                                attribute17                     igs_fi_lb_rect_errs.attribute17%TYPE,
                                attribute18                     igs_fi_lb_rect_errs.attribute18%TYPE,
                                attribute19                     igs_fi_lb_rect_errs.attribute19%TYPE,
                                attribute20                     igs_fi_lb_rect_errs.attribute20%TYPE,
                                credit_id                       igs_fi_credits.credit_id%TYPE,
                                record_status                   igs_lookup_values.lookup_code%TYPE,
                                target_invoice_id1              igs_fi_inv_int.invoice_id%TYPE,
                                target_invoice_id2              igs_fi_inv_int.invoice_id%TYPE,
                                target_invoice_id3              igs_fi_inv_int.invoice_id%TYPE,
                                target_invoice_id4              igs_fi_inv_int.invoice_id%TYPE,
                                target_invoice_id5              igs_fi_inv_int.invoice_id%TYPE,
                                target_invoice_id6              igs_fi_inv_int.invoice_id%TYPE,
                                target_invoice_id7              igs_fi_inv_int.invoice_id%TYPE,
                                target_invoice_id8              igs_fi_inv_int.invoice_id%TYPE,
                                act_applied_amt1                igs_fi_applications.amount_applied%TYPE,
                                act_applied_amt2                igs_fi_applications.amount_applied%TYPE,
                                act_applied_amt3                igs_fi_applications.amount_applied%TYPE,
                                act_applied_amt4                igs_fi_applications.amount_applied%TYPE,
                                act_applied_amt5                igs_fi_applications.amount_applied%TYPE,
                                act_applied_amt6                igs_fi_applications.amount_applied%TYPE,
                                act_applied_amt7                igs_fi_applications.amount_applied%TYPE,
                                act_applied_amt8                igs_fi_applications.amount_applied%TYPE,
                                gl_date                         DATE,
                                source_transaction_type         igs_fi_credits.source_transaction_type%TYPE,
                                eligible_to_apply_yn            VARCHAR2(5),
                                receipt_number                  NUMBER(38),
                                holds_released_yn               VARCHAR2(5),
                                balance_amount                  igs_fi_lb_rect_errs.receipt_amt%TYPE,
                                dflt_cr_type_id                 igs_fi_cr_types.credit_type_id%TYPE);


  TYPE LB_INT_TAB IS TABLE OF LB_INT_REC
    INDEX BY BINARY_INTEGER;

  TYPE LB_RECEIPT_TAB IS TABLE OF LB_RECEIPT_REC
    INDEX BY BINARY_INTEGER;

  PROCEDURE import_interface_lockbox(errbuf            OUT NOCOPY VARCHAR2,
                                     retcode           OUT NOCOPY NUMBER,
                                     p_v_lockbox_name      VARCHAR2,
                                     p_d_gl_date           VARCHAR2,
                                     p_v_test_run          VARCHAR2);

  PROCEDURE import_error_lockbox( errbuf                OUT NOCOPY VARCHAR2,
                                  retcode               OUT NOCOPY NUMBER,
                                  p_v_lockbox_name      IN  VARCHAR2,
                                  p_d_gl_date           IN  VARCHAR2,
                                  p_v_test_run          IN  VARCHAR2);
END igs_fi_prc_lockbox;

 

/
