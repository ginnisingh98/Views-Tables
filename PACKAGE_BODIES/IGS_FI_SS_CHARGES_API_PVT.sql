--------------------------------------------------------
--  DDL for Package Body IGS_FI_SS_CHARGES_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_SS_CHARGES_API_PVT" AS
/* $Header: IGSFI71B.pls 120.4 2006/06/27 14:18:00 skharida ship $ */
  ------------------------------------------------------------------
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --skharida  26-Jun-2006      Bug: 5208136 Modified proc create_charge, removed the obsoleted columns from IGS_FI_INV_INT_PKG.update_row
  --agairola  28-Apr-2006      Bug: 5177774 added callout to Charges TBH
  --svuppala  09-Sep-2005      Enh#4506599 Added x_waiver_amount as OUT parameter
  --svuppala  04-AUG-2005      Enh 3392095 - Tution Waivers build
  --                           Impact of Charges API version Number change
  --                           Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
  --vvutukur  15-Nov-2002  Enh#2584986.Modification done in procedure create_charge.
  --vvutukur  19-Sep-2002  Enh#2564643.Removed references to subaccount_id from procedure create_charge,
  --                       Also removed DEFAULT clause from package body to avoid File.Pkg.22 gscc
  --                       warning.
  ------------------------------------------------------------------

PROCEDURE create_charge(
                        p_api_version                    IN  NUMBER,
                        p_init_msg_list                  IN  VARCHAR2,
                        p_commit                         IN  VARCHAR2,
                        p_validation_level               IN  NUMBER,
                        p_person_id                      IN  NUMBER,
                        p_fee_type                       IN  VARCHAR2,
                        p_fee_cat                        IN  VARCHAR2,
                        p_fee_cal_type                   IN  VARCHAR2,
                        p_fee_ci_sequence_number         IN  NUMBER,
                        p_course_cd                      IN  VARCHAR2,
                        p_attendance_type                IN  VARCHAR2,
                        p_attendance_mode                IN  VARCHAR2,
                        p_invoice_amount                 IN  NUMBER,
                        p_invoice_creation_date          IN  DATE,
                        p_invoice_desc                   IN  VARCHAR2,
                        p_transaction_type               IN  VARCHAR2,
                        p_currency_cd                    IN  VARCHAR2,
                        p_exchange_rate                  IN  NUMBER,
                        p_effective_date                 IN  DATE,
                        p_waiver_flag                    IN  VARCHAR2,
                        p_waiver_reason                  IN  VARCHAR2,
                        p_source_transaction_id          IN  NUMBER,
                        p_invoice_id                    OUT NOCOPY  NUMBER,
                        x_return_status                 OUT NOCOPY  VARCHAR2,
                        x_msg_count                     OUT NOCOPY  NUMBER,
                        x_msg_data                      OUT NOCOPY  VARCHAR2,
                        x_waiver_amount                 OUT NOCOPY  NUMBER
                       ) IS
/***********************************************************************************************

Created By     :    kkillams

Date Created By:    04-02-2002

Purpose        : Private charges API for self service application will create header record and
                 corresponding line record. i.e. one header record and one line record.

Known limitations,enhancements,remarks:
Change History

Who        When       What
skharida  26-Jun-2006  Bug 5208136 - Removed the obsoleted columns from IGS_FI_INV_INT_PKG.update_row
agairola  28-Apr-2006      Bug: 5177774 added callout to Charges TBH
svuppala  04-AUG-2005  Enh 3392095 - Tution Waivers build
                       Impact of Charges API version Number change
                       Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
vvutukur 15-Nov-2002 Enh#2584986.Passed SYSDATE to the call to charges API for the parameter
                     l_chg_line_tbl(1).p_gl_date.
vvutukur 19-Sep-2002 Enh#2564643.Removed reference to subaccount_id.
********************************************************************************************** */

    l_chg_rec             IGS_FI_CHARGES_API_PVT.Header_Rec_Type;
    l_chg_line_tbl        IGS_FI_CHARGES_API_PVT.Line_Tbl_Type;
    l_line_id_tbl         IGS_FI_CHARGES_API_PVT.Line_Id_Tbl_Type;
    l_chg_mtd             IGS_FI_F_TYP_CA_INST.s_chg_method_type%TYPE DEFAULT NULL;
    l_fee_desc            IGS_FI_FEE_TYPE.description%TYPE DEFAULT NULL;

    CURSOR cur_chg IS SELECT s_chg_method_type FROM igs_fi_f_typ_ca_inst
                      WHERE fee_type =p_fee_type
                      AND   fee_cal_type=p_fee_cal_type
                      AND   fee_ci_sequence_number =p_fee_ci_sequence_number;
    CURSOR cur_fee_desc IS  SELECT description  FROM   igs_fi_fee_type
                            WHERE  fee_type = p_fee_type;

    CURSOR cur_inv(cp_invoice_id    igs_fi_inv_int.invoice_id%TYPE) IS
      SELECT inv.*
      FROM   igs_fi_inv_int inv
      WHERE  invoice_id = cp_invoice_id;

    l_rec_chg  cur_inv%ROWTYPE;
  BEGIN
    --Getting the charge method
    OPEN cur_chg;
    FETCH cur_chg INTO l_chg_mtd;
    CLOSE cur_chg;

    --Getting the fee type description
    OPEN cur_fee_desc;
    FETCH cur_fee_desc INTO l_fee_desc;
    CLOSE cur_fee_desc;

    l_chg_rec.p_person_id                := p_person_id;
    l_chg_rec.p_fee_type                 := p_fee_type;
    l_chg_rec.p_fee_cat                  := p_fee_cat;
    l_chg_rec.p_fee_cal_type             := p_fee_cal_type;
    l_chg_rec.p_fee_ci_sequence_number   := p_fee_ci_sequence_number;
    l_chg_rec.p_course_cd                := p_course_cd;
    l_chg_rec.p_attendance_type          := p_attendance_type;
    l_chg_rec.p_attendance_mode          := p_attendance_mode;
    l_chg_rec.p_invoice_amount           := p_invoice_amount;
    l_chg_rec.p_invoice_creation_date    := p_invoice_creation_date;
    l_chg_rec.p_invoice_desc             := p_invoice_desc;
    l_chg_rec.p_transaction_type         := p_transaction_type;
    l_chg_rec.p_currency_cd              := p_currency_cd;
    l_chg_rec.p_exchange_rate            := p_exchange_rate;
    l_chg_rec.p_effective_date           := p_effective_date;
    l_chg_rec.p_waiver_flag              := p_waiver_flag;
    l_chg_rec.p_waiver_reason            := p_waiver_reason;
    l_chg_rec.p_source_transaction_id    := p_source_transaction_id;

    IF p_waiver_flag = 'Y' THEN
      l_chg_rec.p_reverse_flag             := 'Y';
    END IF;

    l_chg_line_tbl(1).p_s_chg_method_type         := l_chg_mtd;
    l_chg_line_tbl(1).p_description               := l_fee_desc;
    l_chg_line_tbl(1).p_chg_elements              := '1';
    l_chg_line_tbl(1).p_amount                    := p_invoice_amount;
    l_chg_line_tbl(1).p_unit_attempt_status       := NULL;
    l_chg_line_tbl(1).p_eftsu                     := NULL;
    l_chg_line_tbl(1).p_credit_points             := NULL;
    l_chg_line_tbl(1).p_org_unit_cd               := NULL;
    l_chg_line_tbl(1).p_attribute_category        := NULL;
    l_chg_line_tbl(1).p_attribute1                := NULL;
    l_chg_line_tbl(1).p_attribute2                := NULL;
    l_chg_line_tbl(1).p_attribute3                := NULL;
    l_chg_line_tbl(1).p_attribute4                := NULL;
    l_chg_line_tbl(1).p_attribute5                := NULL;
    l_chg_line_tbl(1).p_attribute6                := NULL;
    l_chg_line_tbl(1).p_attribute7                := NULL;
    l_chg_line_tbl(1).p_attribute8                := NULL;
    l_chg_line_tbl(1).p_attribute9                := NULL;
    l_chg_line_tbl(1).p_attribute10               := NULL;
    l_chg_line_tbl(1).p_attribute11               := NULL;
    l_chg_line_tbl(1).p_attribute12               := NULL;
    l_chg_line_tbl(1).p_attribute13               := NULL;
    l_chg_line_tbl(1).p_attribute14               := NULL;
    l_chg_line_tbl(1).p_attribute15               := NULL;
    l_chg_line_tbl(1).p_attribute16               := NULL;
    l_chg_line_tbl(1).p_attribute17               := NULL;
    l_chg_line_tbl(1).p_attribute18               := NULL;
    l_chg_line_tbl(1).p_attribute19               := NULL;
    l_chg_line_tbl(1).p_attribute20               := NULL;
    l_chg_line_tbl(1).p_override_dr_rec_ccid      := NULL;
    l_chg_line_tbl(1).p_override_cr_rev_ccid      := NULL;
    l_chg_line_tbl(1).p_override_dr_rec_account_cd :=NULL;
    l_chg_line_tbl(1).p_override_cr_rev_account_cd :=NULL;
    l_chg_line_tbl(1).p_location_cd                :=NULL;
    l_chg_line_tbl(1).p_uoo_id                     :=NULL;
    l_chg_line_tbl(1).p_d_gl_date                  :=TRUNC(SYSDATE);

     -- calling igs_fi_charges_api_pvt.create_charge api
     igs_fi_charges_api_pvt.create_charge(
                                           p_api_version           =>p_api_version,
                                           p_init_msg_list         =>p_init_msg_list,
                                           p_commit                =>p_commit,
                                           p_validation_level      =>p_validation_level,
                                           p_header_rec            =>l_chg_rec,
                                           p_line_tbl              =>l_chg_line_tbl,
                                           x_invoice_id            =>p_invoice_id,
                                           x_line_id_tbl           =>l_line_id_tbl,
                                           x_return_status         =>x_return_status,
                                           x_msg_count             =>x_msg_count,
                                           x_msg_data              =>x_msg_data,
                                           x_waiver_amount         =>x_waiver_amount
                                          );

-- If the charge is getting reversed and the charges API callout has been successful
-- update the charge table with the waiver reason.

    IF ((p_waiver_flag = 'Y') AND (p_invoice_amount < 0) AND (x_return_status = 'S')) THEN
      OPEN cur_inv(p_source_transaction_id);
      FETCH cur_inv INTO l_rec_chg;
      CLOSE cur_inv;

      igs_fi_inv_int_pkg.update_row(x_rowid                         => l_rec_chg.row_id,
                                    x_invoice_id                    => l_rec_chg.invoice_id,
                                    x_person_id                     => l_rec_chg.person_id,
                                    x_fee_type                      => l_rec_chg.fee_type,
                                    x_fee_cat                       => l_rec_chg.fee_cat,
                                    x_fee_cal_type                  => l_rec_chg.fee_cal_type,
                                    x_fee_ci_sequence_number        => l_rec_chg.fee_ci_sequence_number,
                                    x_course_cd                     => l_rec_chg.course_cd,
                                    x_attendance_mode               => l_rec_chg.attendance_mode,
                                    x_attendance_type               => l_rec_chg.attendance_type,
                                    x_invoice_amount_due            => l_rec_chg.invoice_amount_due,
                                    x_invoice_creation_date         => l_rec_chg.invoice_creation_date,
                                    x_invoice_desc                  => l_rec_chg.invoice_desc,
                                    x_transaction_type              => l_rec_chg.transaction_type,
                                    x_currency_cd                   => l_rec_chg.currency_cd,
                                    x_status                        => l_rec_chg.status,
                                    x_attribute_category            => l_rec_chg.attribute_category,
                                    x_attribute1                    => l_rec_chg.attribute1,
                                    x_attribute2                    => l_rec_chg.attribute2,
                                    x_attribute3                    => l_rec_chg.attribute3,
                                    x_attribute4                    => l_rec_chg.attribute4,
                                    x_attribute5                    => l_rec_chg.attribute5,
                                    x_attribute6                    => l_rec_chg.attribute6,
                                    x_attribute7                    => l_rec_chg.attribute7,
                                    x_attribute8                    => l_rec_chg.attribute8,
                                    x_attribute9                    => l_rec_chg.attribute9,
                                    x_attribute10                   => l_rec_chg.attribute10,
                                    x_invoice_amount                => l_rec_chg.invoice_amount,
                                    x_bill_id                       => l_rec_chg.bill_id,
                                    x_bill_number                   => l_rec_chg.bill_number,
                                    x_bill_date                     => l_rec_chg.bill_date,
                                    x_waiver_flag                   => p_waiver_flag,
                                    x_waiver_reason                 => p_waiver_reason,
                                    x_effective_date                => l_rec_chg.effective_date,
                                    x_invoice_number                => l_rec_chg.invoice_number,
                                    x_exchange_rate                 => l_rec_chg.exchange_rate,
                                    x_bill_payment_due_date         => l_rec_chg.bill_payment_due_date,
                                    x_optional_fee_flag             => l_rec_chg.optional_fee_flag,
                                    x_reversal_gl_date              => sysdate,
                                    x_tax_year_code                 => l_rec_chg.tax_year_code,
				    x_waiver_name                   => l_rec_chg.waiver_name);
    END IF;
  EXCEPTION
    WHEN Others THEN
      FND_MESSAGE.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      FND_MESSAGE.Set_Token('NAME','IGS_FI_SS_CHARGES_API_PVT.create_charge');
      IGS_GE_MSG_STACK.Add;
      APP_EXCEPTION.Raise_Exception;
END create_charge;


END IGS_FI_SS_CHARGES_API_PVT;

/
