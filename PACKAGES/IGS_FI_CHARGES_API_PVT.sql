--------------------------------------------------------
--  DDL for Package IGS_FI_CHARGES_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_CHARGES_API_PVT" AUTHID CURRENT_USER AS
/* $Header: IGSFI53S.pls 120.2 2005/08/10 04:11:24 appldev ship $ */

-- Start of Comments
-- API Name               : Create_Charge
-- Type                   : Private
-- Pre-reqs               : None
-- Function               : Creates a charge in the Charges and Charges Lines table
-- Parameters
-- IN                       p_api_version
-- IN                       p_init_msg_list
-- IN                       p_commit
-- IN                       p_validation_level
-- IN                       p_header_rec
--                          This parameter contains the Charge Header record
--                          information
-- IN                       p_line_tbl
--                          The contains the Charge Lines record information
-- OUT NOCOPY                      x_invoice_id
--                          This returns to the calling program the Charge Id
--                          of the charge created
-- OUT NOCOPY                      x_line_id_tbl
--                          This returns to the calling program the Charges Lines
--                          Ids
-- OUT NOCOPY                      x_return_status
--                          returns the status of the charges API - S if Successful,
--                          E if Expected Error and U if Unexpected Error
-- OUT NOCOPY                      x_msg_count
-- OUT NOCOPY                      x_msg_data
-- OUT NOCOPY               x_waiver_amount
--                          This contains waiver amount for furthur processing
-- Version                  Current Version 2.0
--                             Added OUT parameter x_waiver_amount
--                          Previous Version 1.0
-- End of Comments
/*******************************************************************************************************
Who                                 When                               What
svuppala                            07-JUL-2005                Enh 3392095 - Tution Waivers build
                                                               Modified HEADER_REC_TYPE -- included waiver_name.
                                                               Modified Create_charge
gurprsin                            02-Jun-2005                Enh# 3442712 Unit level Fee Assesment Build.
                                                               Added p_n_unit_type_id,p_v_unit_class,p_v_unit_mode,
                                                               p_v_unit_level in line_rec_type record.
vvutukur                            17-May-2003                Enh#2831572.Financial Accounting Build. Added p_v_residency_status_cd in line_rec_type.
pathipat                            14-Nov-2002                Enh# 2584986 - Added p_d_gl_date in line_rec_type
vvutukur                            17-Sep-2002                Enh#2564643.removed reference to
                                                               subaccount_id from header_rec_type.
jbegum                              20 Feb 02                          As part of Enh bug #2228910
                                                                       Changed the type declaration of
                                                                       p_source_transaction_id in the
                                                                       header_rec_type record structure
                                                                       from IGS_FI_INV_INT.Source_Transaction_Id%TYPE
                                                                       to IGS_FI_INV_INT.Invoice_Id%TYPE
Change done by : jbegum
Change date    : 24-Sep-2001
Change         : As part of the bug #1962286 the record data structure line_rec_type has been modified.
                 The fields p_unit_cd , p_unit_version_number , p_unit_location_cd , p_cal_type ,
                 p_ci_sequence_number and p_unit_class have been removed.
                 Two new fields p_location_cd and p_uoo_id have been added.
                 Also the record structure attribute_rec_type was removed as it was not used anywhere
********************************************************************************************************/

  TYPE header_rec_type IS RECORD(p_person_id                        igs_fi_inv_int.person_id%TYPE,
                                 p_fee_type                         igs_fi_inv_int.fee_type%TYPE,
                                 p_fee_cat                          igs_fi_inv_int.fee_cat%TYPE,
                                 p_fee_cal_type                     igs_fi_inv_int.fee_cal_type%TYPE,
                                 p_fee_ci_sequence_number           igs_fi_inv_int.fee_ci_sequence_number%TYPE,
                                 p_course_cd                        igs_fi_inv_int.course_cd%TYPE,
                                 p_attendance_type                  igs_fi_inv_int.attendance_type%TYPE,
                                 p_attendance_mode                  igs_fi_inv_int.attendance_mode%TYPE,
                                 p_invoice_amount                   igs_fi_inv_int.invoice_amount%TYPE,
                                 p_invoice_creation_date            igs_fi_inv_int.invoice_creation_date%TYPE,
                                 p_invoice_desc                     igs_fi_inv_int.invoice_desc%TYPE,
                                 p_transaction_type                 igs_fi_inv_int.transaction_type%TYPE,
                                 p_currency_cd                      igs_fi_inv_int.currency_cd%TYPE,
                                 p_exchange_rate                    igs_fi_inv_int.exchange_rate%TYPE,
                                 p_effective_date                   igs_fi_inv_int.effective_date%TYPE,
                                 p_waiver_flag                      igs_fi_inv_int.waiver_flag%TYPE,
                                 p_waiver_reason                    igs_fi_inv_int.waiver_reason%TYPE,
                                 p_source_transaction_id            igs_fi_inv_int.invoice_id%TYPE,
                                 p_waiver_name                      igs_fi_inv_int.waiver_name%TYPE := NULL,
                                 p_reverse_flag                     igs_fi_inv_int.waiver_flag%TYPE);

--Added new columns - p_unit_type_id,p_unit_class,p_unit_mode,p_cd,p_version_number,p_unit_level.
  TYPE line_rec_type IS RECORD(p_s_chg_method_type                  igs_fi_invln_int.s_chg_method_type%TYPE,
                               p_description                        igs_fi_invln_int.description%TYPE,
                               p_chg_elements                       igs_fi_invln_int.chg_elements%TYPE,
                               p_amount                             igs_fi_invln_int.amount%TYPE,
                               p_unit_attempt_status                igs_fi_invln_int.unit_attempt_status%TYPE,
                               p_eftsu                              igs_fi_invln_int.eftsu%TYPE,
                               p_credit_points                      igs_fi_invln_int.credit_points%TYPE,
                               p_org_unit_cd                        igs_fi_invln_int.org_unit_cd%TYPE,
                               p_override_dr_rec_ccid               igs_fi_invln_int.rec_gl_ccid%TYPE,
                               p_override_cr_rev_ccid               igs_fi_invln_int.rev_gl_ccid%TYPE,
                               p_override_dr_rec_account_cd         igs_fi_invln_int.rec_account_cd%TYPE,
                               p_override_cr_rev_account_cd         igs_fi_invln_int.rev_account_cd%TYPE,
                               p_attribute_category                 igs_fi_invln_int.attribute_category%TYPE,
                               p_attribute1                         igs_fi_invln_int.attribute1%TYPE,
                               p_attribute2                         igs_fi_invln_int.attribute2%TYPE,
                               p_attribute3                         igs_fi_invln_int.attribute3%TYPE,
                               p_attribute4                         igs_fi_invln_int.attribute4%TYPE,
                               p_attribute5                         igs_fi_invln_int.attribute5%TYPE,
                               p_attribute6                         igs_fi_invln_int.attribute6%TYPE,
                               p_attribute7                         igs_fi_invln_int.attribute7%TYPE,
                               p_attribute8                         igs_fi_invln_int.attribute8%TYPE,
                               p_attribute9                         igs_fi_invln_int.attribute9%TYPE,
                               p_attribute10                        igs_fi_invln_int.attribute10%TYPE,
                               p_attribute11                        igs_fi_invln_int.attribute11%TYPE,
                               p_attribute12                        igs_fi_invln_int.attribute12%TYPE,
                               p_attribute13                        igs_fi_invln_int.attribute13%TYPE,
                               p_attribute14                        igs_fi_invln_int.attribute14%TYPE,
                               p_attribute15                        igs_fi_invln_int.attribute15%TYPE,
                               p_attribute16                        igs_fi_invln_int.attribute16%TYPE,
                               p_attribute17                        igs_fi_invln_int.attribute17%TYPE,
                               p_attribute18                        igs_fi_invln_int.attribute18%TYPE,
                               p_attribute19                        igs_fi_invln_int.attribute19%TYPE,
                               p_attribute20                        igs_fi_invln_int.attribute20%TYPE,
                               p_location_cd                        igs_ad_location_all.location_cd%TYPE,
                               p_uoo_id                             igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                               p_d_gl_date                          igs_fi_invln_int.gl_date%TYPE,
                               p_residency_status_cd                igs_fi_ftci_accts.residency_status_cd%TYPE,
                               p_unit_type_id                       igs_ps_unit_type_lvl.unit_type_id%TYPE,
                               p_unit_class                         igs_as_unit_class.unit_class%TYPE,
                               p_unit_mode                          igs_as_unit_mode.unit_mode%TYPE,
                               p_unit_level                         igs_ps_unit_level_all.unit_level%TYPE
                               );

  TYPE line_tbl_type IS TABLE OF line_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE line_id_tbl_type IS TABLE OF igs_fi_invln_int.invoice_lines_id%TYPE
    INDEX BY BINARY_INTEGER;

  PROCEDURE create_charge(p_api_version            IN               NUMBER,
                          p_init_msg_list          IN               VARCHAR2 := FND_API.G_FALSE,
                          p_commit                 IN               VARCHAR2 := FND_API.G_FALSE ,
                          p_validation_level       IN               NUMBER := FND_API.G_VALID_LEVEL_FULL ,
                          p_header_rec             IN               header_rec_type,
                          p_line_tbl               IN               line_tbl_type,
                          x_invoice_id            OUT NOCOPY        NUMBER,
                          x_line_id_tbl           OUT NOCOPY        line_id_tbl_type,
                          x_return_status         OUT NOCOPY        VARCHAR2,
                          x_msg_count             OUT NOCOPY        NUMBER,
                          x_msg_data              OUT NOCOPY        VARCHAR2,
                          x_waiver_amount         OUT NOCOPY        NUMBER);

END igs_fi_charges_api_pvt;

 

/
