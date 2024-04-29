--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_SP_FEES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_SP_FEES" AS
/* $Header: IGSFI89B.pls 120.9 2006/06/28 06:15:49 akandreg ship $ */
/************************************************************************
  Created By : Priya Athipatla
  Date Created By : 15-Oct-2003
  Purpose : Core Routine for Special Fees - Invoked from the Concurrent
  Process and Self Service package

  Known limitations,enhancements,remarks:
  Change History
  Who           When            What
  akandreg      27-Jun-2006     Bug 5104339 -Modified procedure assess_fees and validate_params
  skharida      16-JUN-06       Bug 5094077 - Modified the procedure validate_params to output correct log messages.
  akandreg      09-Jun-2006     Bug 5107755 - Replaced the cursor c_get_alt_code by the cursor c_get_alt_code_desc,
                                which queries both alternate code and description so that both of them
                                can be logged into the log file.

  akandreg      25-May-2006     Bug 5134636 - Modified process_special_fees
                                Added new functions fisp_lock_records , fisp_insert_record
  abshriva      17-May-2006     Bug 5113295 - Modified assess_fees_pvt: Added invocation of function chk_unit_prg_transfer
  abshriva      12-MAy-2006     Bug 5217319 Amount precision change in assess_fees_pvt
  abshriva       5 May-2006     Bug 5178077: Modification done in assess_fees
  uudayapr     14-Sep-2005      Bug 4609164 - Modfied call_charges_api to passes the Unit level values
  svuppala     04-AUG-2005      Enh 3392095 - Tution Waivers build
                                Impact of Charges API version Number change
                                Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
  svuppala     29-MAR-05        Bug 4240402 Timezone impact; Truncating the time part in calling place of the table handlers
                                of the table IGS_FI_SPECIAL_FEES.
                                Modified the sysdate entries as Trunc(Sysdate).
  uudayapr     21-Mar-05        Bug#4224392  Modified call_charges_api
  rmaddipa     20-Sep-04        Enh#3880438  Modified assess_fees_pvt
  rmaddipa     26-July-04       Enh#3787816  Manual Reversal Build
                                Modified assess_fees_pvt
*************************************************************************/

g_v_seperator      CONSTANT VARCHAR2(1)  := '-';
g_v_retention      CONSTANT VARCHAR2(10) := 'RETENTION';
g_v_special        CONSTANT VARCHAR2(10) := 'SPECIAL';
g_v_yes            CONSTANT VARCHAR2(1)  := 'Y';
g_v_no             CONSTANT VARCHAR2(1)  := 'N';
g_v_sua_status     CONSTANT VARCHAR2(20) := 'UNIT_ATTEMPT_STATUS';
g_v_alternatecode igs_ca_inst.alternate_code%TYPE;

FUNCTION  fisp_lock_records(p_n_person_id                  IN igs_fi_spa_fee_prds.person_id%TYPE,
                             p_v_course_cd                 IN igs_fi_spa_fee_prds.course_cd%TYPE,
                             p_v_fee_cal_type              IN igs_fi_spa_fee_prds.fee_cal_type%TYPE,
                             p_n_fee_ci_sequence_number    IN igs_fi_spa_fee_prds.fee_ci_sequence_number%TYPE)  RETURN BOOLEAN;

PROCEDURE log_details(p_v_person_number         IN hz_parties.party_number%TYPE,
                      p_v_fee_period            IN VARCHAR2,
                      p_v_unit_section_desc     IN VARCHAR2,
                      p_v_fee_type              IN igs_fi_fee_type.fee_type%TYPE)AS
/******************************************************************
 Created By      :   Priya Athipatla
 Date Created By :   15-Oct-2003
 Purpose         :   Logs details as follows-
    Person Number: <Value>
    Fee Assessment Period: <Value>
    Unit Section: <Value>
    Fee Type: <Value>
 Known limitations,enhancements,remarks:
 Change History
 Who        When         What
 akandreg   09-Jun-2006    Bug 5107755 - Modified signature of the method by passing parameter
                           p_v_fee_period instead of p_v_fee_period_alt_code.

 ******************************************************************/
BEGIN
    -- Seperator: ------------
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',RPAD(g_v_seperator,77,g_v_seperator));
    fnd_msg_pub.add;
    -- Person Number:
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON')||': '||p_v_person_number);
    fnd_msg_pub.add;
    --Logging  Fee Assessment Period.
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_ASS_PERIOD')||': '|| p_v_fee_period );
    fnd_msg_pub.add;
    -- Unit Section:
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','USEC')||': '||p_v_unit_section_desc);
    fnd_msg_pub.add;
    -- Fee Type:
    IF p_v_fee_type IS NOT NULL THEN
      fnd_message.set_name('IGS','IGS_FI_END_DATE');
      fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_TYPE')||': '||p_v_fee_type);
      fnd_msg_pub.add;
    END IF;
END log_details;


PROCEDURE call_charges_api(p_n_person_id              IN hz_parties.party_id%TYPE,
                           p_v_fee_type               IN igs_fi_f_typ_ca_inst.fee_type%TYPE,
                           p_v_fee_cal_type           IN igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                           p_n_fee_ci_sequence_number IN igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                           p_v_course_cd              IN igs_ps_ver.course_cd%TYPE,
                           p_n_uoo_id                 IN igs_en_su_attempt.uoo_id%TYPE,
                           p_n_amount                 IN igs_fi_invln_int.amount%TYPE,
                           p_v_transaction_type       IN igs_fi_inv_int.transaction_type%TYPE,
                           p_v_currency_cd            IN igs_fi_control.currency_cd%TYPE,
                           p_d_gl_date                IN igs_fi_invln_int.gl_date%TYPE,
                           p_n_source_invoice_id      IN igs_fi_inv_int.invoice_id%TYPE,
                           p_v_sua_status             IN igs_en_su_attempt.unit_attempt_status%TYPE,
                           p_n_invoice_id             OUT NOCOPY igs_fi_inv_int.invoice_id%TYPE,
                           p_v_ret_status             OUT NOCOPY VARCHAR2) AS
/******************************************************************
 Created By      :   Priya Athipatla
 Date Created By :   15-Oct-2003
 Purpose         :   Invokes Charges API for creating a charge
 Known limitations,enhancements,remarks:
 Change History
 Who        When         What
 uudayapr  14-Sep-2005  Bug 4609164 -Added the Cursor c_unit_level_detail to retive the unit level details
                        to be passed to the Charges Api.
 svuppala  04-AUG-2005  Enh 3392095 - Tution Waivers build
                        Impact of Charges API version Number change
                        Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
 uudayapr   21-MAR-05  Bug# 4224392 Added the cursors c_org_unit_cd to retreive the
                       Org_cd and location cd and pass it to the create_charge.
 ******************************************************************/
CURSOR cur_fee_type_desc(cp_v_fee_type   igs_fi_fee_type.fee_type%TYPE) IS
  SELECT description
  FROM  igs_fi_fee_type
  WHERE fee_type = cp_v_fee_type;

--Cursor to select the org unit cd and location cd from igs_en_su_attempt
CURSOR  c_org_unit_cd(cp_person_id IN igs_en_su_attempt_all.person_id%TYPE,
                      cp_course_cd in igs_en_su_attempt_all.course_cd%TYPE,
                      cp_uoo_id IN igs_en_su_attempt_all.uoo_id%TYPE
                      ) IS
  SELECT  org_unit_cd ,location_cd
  FROM    igs_en_su_attempt su
  WHERE   su.person_id = cp_person_id
  AND     su.course_cd = cp_course_cd
  AND     su.uoo_id   = cp_uoo_id;

--Cursor to select the org unit cd  whene it is not identified in the c_org_unit_cd cursor.

CURSOR c_org_unit_sec_cd(cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT owner_org_unit_cd
  FROM   igs_ps_unit_ofr_opt uoo
  WHERE  uoo_id = cp_uoo_id;

--cursor to select the Unit Program Type Level, Unit Class and Unit Mode attributes when creating
--a Special Fee charge.
CURSOR c_unit_level_detail(cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT uv.unit_type_id,
         asuc.unit_class,
         asuc.unit_mode,
         uv.unit_level
  FROM igs_ps_unit_ver uv,
       igs_ps_unit_ofr_opt_all uoo,
       igs_as_unit_class asuc
  WHERE uv.unit_cd = uoo.unit_cd
  AND   uv.version_number = uoo.version_number
  AND asuc.unit_class = uoo.unit_class
  AND uoo.uoo_id = cp_uoo_id;

l_v_fee_type_desc       igs_fi_fee_type.description%TYPE := NULL;
l_rec_chg_header        igs_fi_charges_api_pvt.header_rec_type;
l_rec_chg_line_tbl      igs_fi_charges_api_pvt.line_tbl_type;
l_rec_chg_line_id_tbl   igs_fi_charges_api_pvt.line_id_tbl_type;
l_v_return_status       VARCHAR2(1) := NULL;
l_n_msg_count           NUMBER      := 0;
l_v_msg_data            VARCHAR2(4000) := NULL;

--local parameters to hold the org unit code and loaction code values from the cursor.
l_rec_cur_org_unit_cd c_org_unit_cd%ROWTYPE;
l_v_derived_org_unit_cd igs_en_su_attempt_all.org_unit_cd%TYPE;
--CUROSR
l_c_unit_level_detail c_unit_level_detail%ROWTYPE;

l_n_waiver_amount NUMBER;

BEGIN

   OPEN cur_fee_type_desc(p_v_fee_type);
   FETCH cur_fee_type_desc INTO l_v_fee_type_desc;
   CLOSE cur_fee_type_desc;

-- To derive the org unit code and location code from igs_en_su_attempt table
   l_v_derived_org_unit_cd := NULL;
   OPEN c_org_unit_cd(p_n_person_id,
                      p_v_course_cd,
                      p_n_uoo_id);
   FETCH c_org_unit_cd INTO l_rec_cur_org_unit_cd;
   CLOSE c_org_unit_cd;

   --if org unit code is not derived from the student unit attempts then derive it from the
   --Unit Section table of IGS_PS_UNIT_OFR_OPT.
   IF l_rec_cur_org_unit_cd.org_unit_cd IS NULL THEN
     OPEN c_org_unit_sec_cd(p_n_uoo_id);
     FETCH c_org_unit_sec_cd INTO l_v_derived_org_unit_cd;
     CLOSE c_org_unit_sec_cd;
   ELSE
     l_v_derived_org_unit_cd := l_rec_cur_org_unit_cd.org_unit_cd;
   END IF;
   --Code Logic for Getting the Unit level details.
   OPEN  c_unit_level_detail(p_n_uoo_id);
   FETCH c_unit_level_detail INTO l_c_unit_level_detail;
   CLOSE c_unit_level_detail;

   l_rec_chg_header.p_person_id              := p_n_person_id;
   l_rec_chg_header.p_fee_type               := p_v_fee_type;
   l_rec_chg_header.p_fee_cal_type           := p_v_fee_cal_type;
   l_rec_chg_header.p_fee_ci_sequence_number := p_n_fee_ci_sequence_number;
   l_rec_chg_header.p_course_cd              := p_v_course_cd;
   l_rec_chg_header.p_invoice_amount         := p_n_amount;
   l_rec_chg_header.p_transaction_type       := p_v_transaction_type;
   l_rec_chg_header.p_currency_cd            := p_v_currency_cd;
   l_rec_chg_header.p_invoice_creation_date  := TRUNC(SYSDATE);
   l_rec_chg_header.p_effective_date         := TRUNC(SYSDATE);
   l_rec_chg_header.p_source_transaction_id  := p_n_source_invoice_id;
   l_rec_chg_header.p_invoice_desc           := l_v_fee_type_desc;

   l_rec_chg_line_tbl(1).p_uoo_id               := p_n_uoo_id;
   l_rec_chg_line_tbl(1).p_d_gl_date            := p_d_gl_date;
   l_rec_chg_line_tbl(1).p_amount               := p_n_amount;
   l_rec_chg_line_tbl(1).p_description          := l_v_fee_type_desc;
   l_rec_chg_line_tbl(1).p_unit_attempt_status  := p_v_sua_status;
   -- Set the value of Location Code and org unit code
   l_rec_chg_line_tbl(1).p_location_cd := l_rec_cur_org_unit_cd.location_cd;
   l_rec_chg_line_tbl(1).p_org_unit_cd := l_v_derived_org_unit_cd;
   --setting the Values for the Unit level details
   l_rec_chg_line_tbl(1).p_unit_type_id        := l_c_unit_level_detail.unit_type_id;
   l_rec_chg_line_tbl(1).p_unit_class          := l_c_unit_level_detail.unit_class;
   l_rec_chg_line_tbl(1).p_unit_mode           := l_c_unit_level_detail.unit_mode;
   l_rec_chg_line_tbl(1).p_unit_level          := l_c_unit_level_detail.unit_level;

   igs_fi_charges_api_pvt.create_charge(p_api_version      => 2.0,
                                        p_init_msg_list    => 'F',
                                        p_commit           => 'F',
                                        p_validation_level => 100,
                                        p_header_rec       => l_rec_chg_header,
                                        p_line_tbl         => l_rec_chg_line_tbl,
                                        x_invoice_id       => p_n_invoice_id,
                                        x_line_id_tbl      => l_rec_chg_line_id_tbl,
                                        x_return_status    => p_v_ret_status,
                                        x_msg_count        => l_n_msg_count,
                                        x_msg_data         => l_v_msg_data,
                                        x_waiver_amount    => l_n_waiver_amount);

END call_charges_api;


PROCEDURE assess_fees_pvt(p_n_person_id               IN  PLS_INTEGER,
                          p_v_person_number           IN  VARCHAR2,
                          p_v_course_cd               IN  VARCHAR2,
                          p_n_uoo_id                  IN  PLS_INTEGER,
                          p_v_fee_cal_type            IN  VARCHAR2,
                          p_n_fee_ci_sequence_number  IN  PLS_INTEGER,
                          p_v_fee_period              IN VARCHAR2,
                          p_v_load_cal_type           IN  VARCHAR2,
                          p_n_load_ci_sequence_number IN  PLS_INTEGER,
                          p_d_gl_date                 IN  DATE,
                          p_b_log_messages            IN  BOOLEAN DEFAULT TRUE,
                          x_return_status             OUT NOCOPY VARCHAR2,
                          x_msg_count                 OUT NOCOPY NUMBER,
                          x_msg_data                  OUT NOCOPY VARCHAR2) AS
/******************************************************************
 Created By      :   Priya Athipatla
 Date Created By :   15-Oct-2003
 Purpose         :   Main routine for assessing Special Fees
 Known limitations,enhancements,remarks:
 Change History
 Who        When         What
 akandreg   09-Jun-2006  Bug 5107755 - Modified signature of the method by passing parameter
                         p_v_fee_period instead of p_v_fee_period_alt_code. Also passed p_v_fee_period
                         instead of p_v_fee_period_alt_code to log_details procedure log_details.

 abshriva   17-May-2006  Bug 5113295 - Added invocation of function chk_unit_prg_transfer
                         Modified cursor cur_sua_status - selected dcnt_reason_cd
 abshriva   12-May-2006  Bug 5217319:- Amount Precision change, added API call to allow correct precison into DB
 rmaddipa    20-Sep-04    Enh#3880438 Retention Enhancement. Modified to incorporate
                                      teaching period level, unit section level, Complete withdrawal retention rules.
 rmaddipa    26-July-04   Enh#3787816
                         Modified to prevent re-assessment of manually
                         reversed charges.
                         Obsoleted the cursor CUR_FEE_DECLINED
 ******************************************************************/

TYPE sp_fees_rec_type IS RECORD( person_id               hz_parties.party_id%TYPE,
                                 course_cd               igs_ps_ver.course_cd%TYPE,
                                 uoo_id                  igs_ps_unit_ofr_opt.uoo_id%TYPE,
                                 fee_type                igs_fi_fee_type.fee_type%TYPE,
                                 fee_cal_type            igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                                 fee_ci_sequence_number  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                                 old_amount              igs_fi_special_fees.fee_amt%TYPE,
                                 new_amount              igs_fi_special_fees.fee_amt%TYPE,
                                 invoice_id              igs_fi_inv_int.invoice_id%TYPE);

TYPE sp_fees_tab IS TABLE OF sp_fees_rec_type INDEX BY BINARY_INTEGER;

-- plsql table initialization
l_sp_fees_tbl            sp_fees_tab;

-- Cursor to determine sum of Special Fees for a student from the special fees table
-- This does not include the Retention Fees
CURSOR cur_get_sum_sp_fees(cp_n_person_id               hz_parties.party_id%TYPE,
                           cp_v_course_cd               igs_ps_ver.course_cd%TYPE,
                           cp_n_uoo_id                  igs_ps_unit_ofr_opt.uoo_id%TYPE,
                           cp_v_fee_cal_type            igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                           cp_n_fee_ci_sequence_number  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                           cp_v_transaction_type_cd     igs_fi_special_fees.s_transaction_type_code%TYPE) IS
  SELECT fee_type,
         invoice_id,
         SUM(fee_amt) fee_amt
  FROM  igs_fi_special_fees
  WHERE person_id = cp_n_person_id
  AND   course_cd = cp_v_course_cd
  AND   uoo_id    = cp_n_uoo_id
  AND   fee_cal_type = cp_v_fee_cal_type
  AND   fee_ci_sequence_number = cp_n_fee_ci_sequence_number
  AND   s_transaction_type_code <> cp_v_transaction_type_cd
  GROUP BY fee_type, invoice_id;

-- Cursor to determine if the current unit attempt is assessable or not
CURSOR cur_unit_load(cp_n_person_id        hz_parties.party_id%TYPE,
                     cp_v_course_cd        igs_ps_ver.course_cd%TYPE,
                     cp_n_uoo_id           igs_ps_unit_ofr_opt.uoo_id%TYPE,
                     cp_v_unit_att_status  igs_lookups_view.lookup_type%TYPE,
                     cp_v_fee_ass_ind      igs_lookups_view.fee_ass_ind%TYPE) IS
  SELECT sua.cal_type,
         sua.ci_sequence_number, sua.discontinued_dt,
         sua.administrative_unit_status, sua.unit_attempt_status,
         sua.no_assessment_ind
  FROM   igs_en_su_attempt sua,
         igs_lookups_view lkp
  WHERE sua.person_id = cp_n_person_id
  AND   sua.course_cd = cp_v_course_cd
  AND   sua.uoo_id = cp_n_uoo_id
  AND   lkp.lookup_type = cp_v_unit_att_status
  AND   lkp.fee_ass_ind = cp_v_fee_ass_ind
  AND   sua.unit_attempt_status = lkp.lookup_code;

-- Cursor to determine the SUA status
CURSOR cur_sua_status(cp_n_person_id    igs_en_su_attempt.person_id%TYPE,
                      cp_n_uoo_id       igs_en_su_attempt.uoo_id%TYPE,
                      cp_v_course_cd    igs_en_su_attempt_all.course_cd%TYPE) IS
  SELECT sua.unit_attempt_status,
         sua.discontinued_dt,
         sua.dcnt_reason_cd
  FROM igs_en_su_attempt sua
  WHERE sua.person_id = cp_n_person_id
  AND sua.uoo_id = cp_n_uoo_id
  AND sua.course_cd = cp_v_course_cd;

-- Cursor to obtain all fee types from the Special Fees Rate setup
CURSOR cur_usec_sp_fees(cp_n_uoo_id    igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT sp_fee_amt,
         fee_type
  FROM   igs_ps_usec_sp_fees
  WHERE  uoo_id = cp_n_uoo_id
  AND    closed_flag = g_v_no;

-- Variables to hold transactional values
l_rec_unit_load          cur_unit_load%ROWTYPE;
l_v_currency_cd          igs_fi_control.currency_cd%TYPE := NULL;
l_v_currency_desc        fnd_currencies_tl.name%TYPE := NULL;
l_v_message_name         fnd_new_messages.message_name%TYPE := NULL;
l_n_invoice_id           igs_fi_inv_int.invoice_id%TYPE := NULL;
l_n_source_invoice_id    igs_fi_inv_int.invoice_id%TYPE := NULL;
l_n_special_fee_id       igs_fi_special_fees.special_fee_id%TYPE := NULL;
l_n_net_amount           igs_fi_special_fees.fee_amt%TYPE := 0.0;
l_n_retention_amt        igs_fi_special_fees.fee_amt%TYPE := 0.0;
l_v_unit_section_desc    VARCHAR2(4000) := NULL;

-- Temporary variables
l_n_counter              PLS_INTEGER := 0;
l_v_temp                 VARCHAR2(1) := NULL;
l_v_load_incurred        VARCHAR2(1) := NULL;
l_v_ret_status           VARCHAR2(1) := NULL;
l_b_unit_assessable      BOOLEAN := FALSE;
l_rowid                  ROWID := NULL;
e_expected_error         EXCEPTION;

l_b_no_data_found        BOOLEAN := FALSE;

l_v_invoice_number igs_fi_inv_int_all.invoice_number%TYPE;
l_b_chg_decl_rev   BOOLEAN;

l_v_ret_level              igs_fi_f_typ_ca_inst_all.retention_level_code%TYPE;
l_v_complete_withdr_ret    igs_fi_f_typ_ca_inst_all.complete_ret_flag%TYPE;
l_v_sua_status             igs_en_su_attempt.unit_attempt_status%TYPE := NULL;
l_d_disc_dt                igs_en_su_attempt.discontinued_dt%TYPE := NULL;

-- Cursor to get optional payment Indicator for a given fee type
CURSOR cur_optional_payment_ind(cp_fee_type igs_fi_fee_type_all.fee_type%TYPE) IS
    SELECT optional_payment_ind
    FROM igs_fi_fee_type
    WHERE fee_type = cp_fee_type;

l_v_optional_payment_ind igs_fi_fee_type_all.optional_payment_ind%TYPE;
l_v_unit_transferred     VARCHAR2(1);

l_v_disc_reason          igs_en_su_attempt.dcnt_reason_cd%TYPE;

BEGIN
   x_return_status := 'S';

   -- Initialize the stack if log messages = True
   IF p_b_log_messages THEN
      fnd_msg_pub.initialize;
   END IF;

   -- If any of the mandatory parameters have not been provided, log the message
   IF (p_n_person_id IS NULL) OR(p_v_course_cd IS NULL) OR (p_n_uoo_id IS NULL) OR
      (p_v_fee_cal_type IS NULL) OR (p_n_fee_ci_sequence_number IS NULL) OR
      (p_v_load_cal_type IS NULL) OR (p_n_load_ci_sequence_number IS NULL) OR
      (p_d_gl_date IS NULL) OR (p_b_log_messages IS NULL) THEN
         IF p_b_log_messages THEN
            fnd_message.set_name('IGS','IGS_FI_PARAMETER_NULL');
            fnd_msg_pub.add;
         END IF;
         RAISE e_expected_error;
   END IF;

   -- Determine the Unit Section description if logging is enabled
   IF p_b_log_messages THEN
      l_v_unit_section_desc := igs_fi_gen_apint.get_unit_section_desc(p_n_uoo_id  => p_n_uoo_id);
   END IF;

   -- Determine the Currency Code and description
   igs_fi_gen_gl.finp_get_cur(p_v_currency_cd  => l_v_currency_cd,
                              p_v_curr_desc    => l_v_currency_desc,
                              p_v_message_name => l_v_message_name);
   IF l_v_message_name IS NOT NULL THEN
      IF p_b_log_messages THEN
         fnd_message.set_name('IGS',l_v_message_name);
         fnd_msg_pub.add;
      END IF;
      RAISE e_expected_error;
   END IF;

   -- Loop through existing records of the special fees table
   FOR l_rec_get_sum_sp_fees IN cur_get_sum_sp_fees(cp_n_person_id              => p_n_person_id,
                                                    cp_v_course_cd              => p_v_course_cd,
                                                    cp_n_uoo_id                 => p_n_uoo_id,
                                                    cp_v_fee_cal_type           => p_v_fee_cal_type,
                                                    cp_n_fee_ci_sequence_number => p_n_fee_ci_sequence_number,
                                                    cp_v_transaction_type_cd    => g_v_retention)
   LOOP
     -- If sum of special fees is greater than zero, initialize the plsql table
     IF l_rec_get_sum_sp_fees.fee_amt > 0.0 THEN
        l_sp_fees_tbl(l_n_counter).person_id              := p_n_person_id;
        l_sp_fees_tbl(l_n_counter).course_cd              := p_v_course_cd;
        l_sp_fees_tbl(l_n_counter).uoo_id                 := p_n_uoo_id;
        l_sp_fees_tbl(l_n_counter).fee_type               := l_rec_get_sum_sp_fees.fee_type;
        l_sp_fees_tbl(l_n_counter).fee_cal_type           := p_v_fee_cal_type;
        l_sp_fees_tbl(l_n_counter).fee_ci_sequence_number := p_n_fee_ci_sequence_number;
        l_sp_fees_tbl(l_n_counter).old_amount             := l_rec_get_sum_sp_fees.fee_amt;
        l_sp_fees_tbl(l_n_counter).new_amount             := 0.0;
        l_sp_fees_tbl(l_n_counter).invoice_id             := l_rec_get_sum_sp_fees.invoice_id;
        l_n_counter := l_n_counter + 1;
     END IF; -- End of check for fee_amt > 0
   END LOOP; -- End loop for records cursor cur_get_sum_sp_fees

   -- For the current unit attempt, determine if the unit is fee assessable
   OPEN cur_unit_load(cp_n_person_id       => p_n_person_id,
                      cp_v_course_cd       => p_v_course_cd,
                      cp_n_uoo_id          => p_n_uoo_id,
                      cp_v_unit_att_status => g_v_sua_status,
                      cp_v_fee_ass_ind     => g_v_yes);
   FETCH cur_unit_load INTO l_rec_unit_load;
   IF cur_unit_load%FOUND THEN
      l_b_unit_assessable := TRUE;
   ELSE
      l_b_unit_assessable := FALSE;
      l_b_no_data_found := TRUE;
   END IF;
   CLOSE cur_unit_load;

   IF l_b_unit_assessable THEN
      -- If load is incurred, EN api returns 'Y', else returns 'N'
      -- The parameter p_include_audit to be uncommented when the EN api is available
      -- after the modifications.
      --removed the comment p_include_audit as there should not be any commented code
      l_v_load_incurred := igs_en_prc_load.enrp_get_load_apply(p_teach_cal_type             => l_rec_unit_load.cal_type,
                                                               p_teach_sequence_number      => l_rec_unit_load.ci_sequence_number,
                                                               p_discontinued_dt            => l_rec_unit_load.discontinued_dt,
                                                               p_administrative_unit_status => l_rec_unit_load.administrative_unit_status,
                                                               p_unit_attempt_status        => l_rec_unit_load.unit_attempt_status,
                                                               p_no_assessment_ind          => l_rec_unit_load.no_assessment_ind,
                                                               p_load_cal_type              => p_v_load_cal_type,
                                                               p_load_sequence_number       => p_n_load_ci_sequence_number,
                                                               p_include_audit              => g_v_yes);

      IF (l_v_load_incurred = g_v_yes) THEN
         -- If there are any records in the pl/sql table, then initialize new amount to the old amount
         IF l_sp_fees_tbl.COUNT > 0 THEN
            FOR l_n_tbl_cnt IN l_sp_fees_tbl.FIRST .. l_sp_fees_tbl.LAST LOOP
                IF l_sp_fees_tbl.EXISTS(l_n_tbl_cnt) THEN
                   l_sp_fees_tbl(l_n_tbl_cnt).new_amount := l_sp_fees_tbl(l_n_tbl_cnt).old_amount;
                END IF;
            END LOOP;
         ELSE
            -- If there are no records in the plsql table, fetch all fee types from
            -- the Special Fees rate setup information and for each record, initialize
            -- the plsql table
            l_n_counter := 0;
            FOR l_rec_usec_sp_fees IN cur_usec_sp_fees(cp_n_uoo_id  => p_n_uoo_id) LOOP
                l_sp_fees_tbl(l_n_counter).person_id              := p_n_person_id;
                l_sp_fees_tbl(l_n_counter).course_cd              := p_v_course_cd;
                l_sp_fees_tbl(l_n_counter).uoo_id                 := p_n_uoo_id;
                l_sp_fees_tbl(l_n_counter).fee_type               := l_rec_usec_sp_fees.fee_type;
                l_sp_fees_tbl(l_n_counter).fee_cal_type           := p_v_fee_cal_type;
                l_sp_fees_tbl(l_n_counter).fee_ci_sequence_number := p_n_fee_ci_sequence_number;
                l_sp_fees_tbl(l_n_counter).old_amount             := 0.0;
                l_sp_fees_tbl(l_n_counter).new_amount             := l_rec_usec_sp_fees.sp_fee_amt;
                l_sp_fees_tbl(l_n_counter).invoice_id             := NULL;
                l_n_counter := l_n_counter + 1;
            END LOOP;

            IF l_n_counter = 0 THEN
              l_b_no_data_found := TRUE;
            END IF;
         END IF; -- End for table count > 0
      ELSE
        l_b_no_data_found := TRUE;
      END IF; -- End for load_incurred = g_v_yes

   END IF; -- End for unit_assessable = True

   IF l_sp_fees_tbl.COUNT > 0 THEN
      FOR l_n_tbl_cnt IN l_sp_fees_tbl.FIRST .. l_sp_fees_tbl.LAST LOOP
          IF l_sp_fees_tbl.EXISTS(l_n_tbl_cnt) THEN

             -- Log context information in the log file
             IF p_b_log_messages THEN
                 log_details(p_v_person_number       => p_v_person_number,
                             p_v_fee_period          => p_v_fee_period,
                             p_v_unit_section_desc   => l_v_unit_section_desc,
                             p_v_fee_type            => l_sp_fees_tbl(l_n_tbl_cnt).fee_type);
             END IF;

             -- Check if the fee has already been declined.
             -- If declined, that charge has to be skipped while processing
             l_b_chg_decl_rev:=FALSE;
             IF (l_sp_fees_tbl(l_n_tbl_cnt).invoice_id IS NOT NULL) THEN
                 igs_fi_gen_008.chk_chg_adj(p_n_person_id  => NULL,
                                            p_v_location_cd => NULL,
                                            p_v_course_cd => NULL,
                                            p_v_fee_cal_type => NULL,
                                            p_v_fee_cat => NULL,
                                            p_n_fee_ci_sequence_number => NULL,
                                            p_v_fee_type => NULL,
                                            p_n_uoo_id => NULL,
                                            p_v_transaction_type => NULL,
                                            p_n_invoice_id => l_sp_fees_tbl(l_n_tbl_cnt).invoice_id,
                                            p_v_invoice_num => l_v_invoice_number,
                                            p_b_chg_decl_rev => l_b_chg_decl_rev);

             END IF;
             IF (l_b_chg_decl_rev) THEN
                 -- Charge is reversed or declined. skip the record
                 IF p_b_log_messages THEN
                    -- Message that the fee has been declined, so no further processing would happen
                    fnd_message.set_name('IGS','IGS_FI_SP_FEE_DECLINED');
                    fnd_message.set_token('INVOICE_NUM',l_v_invoice_number);
                    fnd_msg_pub.add;
                 END IF;
             ELSE
                -- Charge not reversed or declined.
                -- Continue normal processing for charges that are not declined
                l_n_net_amount := l_sp_fees_tbl(l_n_tbl_cnt).new_amount - l_sp_fees_tbl(l_n_tbl_cnt).old_amount;

                -- If net amount <> 0 then charge has to be either created or reversed
                IF l_n_net_amount <> 0.0 THEN
                   -- If net amount is negative, then already created special charge has to be reversed
                   -- Check if Retention applies to this charge

                   l_n_source_invoice_id      := l_sp_fees_tbl(l_n_tbl_cnt).invoice_id;

                   --Get the optional payment indicator for the fee type
                   OPEN cur_optional_payment_ind(cp_fee_type => l_sp_fees_tbl(l_n_tbl_cnt).fee_type);
                   FETCH cur_optional_payment_ind INTO l_v_optional_payment_ind;
                   CLOSE cur_optional_payment_ind;

                   IF (l_n_net_amount < 0.0 AND l_v_optional_payment_ind = 'N') THEN
                      -- Get student unit attempt status and discontinued date
                      OPEN cur_sua_status(l_sp_fees_tbl(l_n_tbl_cnt).person_id,
                                          l_sp_fees_tbl(l_n_tbl_cnt).uoo_id,
                                          l_sp_fees_tbl(l_n_tbl_cnt).course_cd);
                      FETCH cur_sua_status INTO l_v_sua_status, l_d_disc_dt, l_v_disc_reason;
                      CLOSE cur_sua_status;

                      IF (l_v_sua_status <> 'INVALID') THEN
                          -- Check if the unit attempt has been dropped due to a Program Transfer, in which case retention
                          -- need not be calculated.
                          l_v_unit_transferred := igs_fi_gen_008.chk_unit_prg_transfer(l_v_disc_reason);
                          -- If the unit was not part of a Program Transfer (function returns N), calculate retention
                          IF (l_v_unit_transferred = 'N') THEN
                          -- Get the retention level and complete withdrawal retention flag
                          igs_fi_gen_008.get_retention_params(p_v_fee_cal_type           => l_sp_fees_tbl(l_n_tbl_cnt).fee_cal_type,
                                                              p_n_fee_ci_sequence_number => l_sp_fees_tbl(l_n_tbl_cnt).fee_ci_sequence_number,
                                                              p_v_fee_type               => l_sp_fees_tbl(l_n_tbl_cnt).fee_type,
                                                              p_v_ret_level              => l_v_ret_level,
                                                              p_v_complete_withdr_ret    => l_v_complete_withdr_ret
                                                             );

                         IF (l_v_ret_level = 'FEE_PERIOD') THEN
                             l_n_retention_amt := igs_fi_gen_008.get_fee_retention_amount(p_v_fee_cat                => NULL,
                                                                                          p_v_fee_type               => l_sp_fees_tbl(l_n_tbl_cnt).fee_type,
                                                                                          p_v_fee_cal_type           => l_sp_fees_tbl(l_n_tbl_cnt).fee_cal_type,
                                                                                          p_n_fee_ci_sequence_number => l_sp_fees_tbl(l_n_tbl_cnt).fee_ci_sequence_number,
                                                                                          p_n_diff_amount            => ABS(l_n_net_amount));
                         ELSIF (l_v_ret_level = 'TEACH_PERIOD') THEN
                             l_n_retention_amt := igs_fi_gen_008.get_special_retention_amt(p_n_uoo_id                   => l_sp_fees_tbl(l_n_tbl_cnt).uoo_id,
                                                                                           p_v_fee_cal_type             => l_sp_fees_tbl(l_n_tbl_cnt).fee_cal_type,
                                                                                           p_n_fee_ci_sequence_number   => l_sp_fees_tbl(l_n_tbl_cnt).fee_ci_sequence_number,
                                                                                           p_v_fee_type                 => l_sp_fees_tbl(l_n_tbl_cnt).fee_type,
                                                                                           p_d_effective_date           => l_d_disc_dt,
                                                                                           p_n_diff_amount              => l_n_net_amount);
                         END IF;

                         IF l_n_retention_amt > 0.0 THEN
                              -- If retention amount is greater than 0, a retention charge has to be created.
                              call_charges_api(p_n_person_id              => l_sp_fees_tbl(l_n_tbl_cnt).person_id,
                                               p_v_fee_type               => l_sp_fees_tbl(l_n_tbl_cnt).fee_type,
                                               p_v_fee_cal_type           => l_sp_fees_tbl(l_n_tbl_cnt).fee_cal_type,
                                               p_n_fee_ci_sequence_number => l_sp_fees_tbl(l_n_tbl_cnt).fee_ci_sequence_number,
                                               p_v_course_cd              => l_sp_fees_tbl(l_n_tbl_cnt).course_cd,
                                               p_n_uoo_id                 => l_sp_fees_tbl(l_n_tbl_cnt).uoo_id,
                                               p_n_amount                 => l_n_retention_amt,
                                               p_v_transaction_type       => g_v_retention,
                                               p_v_currency_cd            => l_v_currency_cd,
                                               p_d_gl_date                => p_d_gl_date,
                                               p_n_source_invoice_id      => NULL,
                                               p_v_sua_status             => l_v_sua_status,
                                               p_n_invoice_id             => l_n_invoice_id,
                                               p_v_ret_status             => l_v_ret_status);
                              IF l_v_ret_status <> 'S' THEN
                                 -- Message that no transactions have been carried out due to some error
                                 fnd_message.set_name('IGS','IGS_FI_SP_NO_CHARGE');
                                 fnd_message.set_token('PERSON_NUMBER',p_v_person_number);
                                 fnd_msg_pub.add;
                                 RAISE e_expected_error;
                              END IF;

                              -- After creation of retention charge, insert a record into the Special Fees table
                              -- Modified transaction_date entry as Trunc(Sysdate) as part of Bug 4240402: Timezone impact
                              l_n_special_fee_id := NULL;
                              l_rowid            := NULL;
                              igs_fi_special_fees_pkg.insert_row ( x_rowid                    => l_rowid,
                                                                   x_special_fee_id           => l_n_special_fee_id,
                                                                   x_person_id                => l_sp_fees_tbl(l_n_tbl_cnt).person_id,
                                                                   x_course_cd                => l_sp_fees_tbl(l_n_tbl_cnt).course_cd,
                                                                   x_uoo_id                   => l_sp_fees_tbl(l_n_tbl_cnt).uoo_id,
                                                                   x_fee_type                 => l_sp_fees_tbl(l_n_tbl_cnt).fee_type,
                                                                   x_fee_cal_type             => l_sp_fees_tbl(l_n_tbl_cnt).fee_cal_type,
                                                                   x_fee_ci_sequence_number   => l_sp_fees_tbl(l_n_tbl_cnt).fee_ci_sequence_number,
                                                                   x_fee_amt                  => igs_fi_gen_gl.get_formatted_amount(l_n_retention_amt),
                                                                   x_transaction_date         => TRUNC(SYSDATE),
                                                                   x_s_transaction_type_code  => g_v_retention,
                                                                   x_invoice_id               => l_n_invoice_id,
                                                                   x_mode                     => 'R'
                                                                 );
                         END IF;  -- End for retention_amt > 0
                          END IF; -- End for l_v_unit_transferred = 'N'
                      END IF; --unit_attempt_status <> 'INVALID'
                   END IF;  -- End if for l_n_net_amount < 0
                   IF l_n_net_amount > 0.0 THEN
                      l_n_source_invoice_id := NULL;
                   END IF;

                   -- If net_amount > 0, new charge is created, in which case source_invoice_id is NULL
                   -- If net_amount < 0, already existing charge is reversed, in which case invoice_id is
                   -- passed as the source_invoice_id
                   l_v_ret_status := NULL;
                   call_charges_api(p_n_person_id              => l_sp_fees_tbl(l_n_tbl_cnt).person_id,
                                    p_v_fee_type               => l_sp_fees_tbl(l_n_tbl_cnt).fee_type,
                                    p_v_fee_cal_type           => l_sp_fees_tbl(l_n_tbl_cnt).fee_cal_type,
                                    p_n_fee_ci_sequence_number => l_sp_fees_tbl(l_n_tbl_cnt).fee_ci_sequence_number,
                                    p_v_course_cd              => l_sp_fees_tbl(l_n_tbl_cnt).course_cd,
                                    p_n_uoo_id                 => l_sp_fees_tbl(l_n_tbl_cnt).uoo_id,
                                    p_n_amount                 => l_n_net_amount,
                                    p_v_transaction_type       => g_v_special,
                                    p_v_currency_cd            => l_v_currency_cd,
                                    p_d_gl_date                => p_d_gl_date,
                                    p_n_source_invoice_id      => l_n_source_invoice_id,
                                    p_v_sua_status             => l_v_sua_status,
                                    p_n_invoice_id             => l_n_invoice_id,
                                    p_v_ret_status             => l_v_ret_status
                                   );
                   IF l_v_ret_status <> 'S' THEN
                      -- Message that no transactions have been carried out due to some error
                      fnd_message.set_name('IGS','IGS_FI_SP_NO_CHARGE');
                      fnd_message.set_token('PERSON_NUMBER',p_v_person_number);
                      fnd_msg_pub.add;
                      RAISE e_expected_error;
                   END IF;

                   -- After creation of a special charge, insert a record into the Special Fees table
                   -- Modified transaction_date entry as Trunc(Sysdate) as part of Bug 4240402: Timezone impact
                   l_n_special_fee_id := NULL;
                   l_rowid            := NULL;
                   igs_fi_special_fees_pkg.insert_row ( x_rowid                    => l_rowid,
                                                        x_special_fee_id           => l_n_special_fee_id,
                                                        x_person_id                => l_sp_fees_tbl(l_n_tbl_cnt).person_id,
                                                        x_course_cd                => l_sp_fees_tbl(l_n_tbl_cnt).course_cd,
                                                        x_uoo_id                   => l_sp_fees_tbl(l_n_tbl_cnt).uoo_id,
                                                        x_fee_type                 => l_sp_fees_tbl(l_n_tbl_cnt).fee_type,
                                                        x_fee_cal_type             => l_sp_fees_tbl(l_n_tbl_cnt).fee_cal_type,
                                                        x_fee_ci_sequence_number   => l_sp_fees_tbl(l_n_tbl_cnt).fee_ci_sequence_number,
                                                        x_fee_amt                  => igs_fi_gen_gl.get_formatted_amount(l_n_net_amount),
                                                        x_transaction_date         => TRUNC(SYSDATE),
                                                        x_s_transaction_type_code  => g_v_special,
                                                        x_invoice_id               => NVL(l_n_invoice_id,l_n_source_invoice_id),
                                                        x_mode                     => 'R'
                                                       );

                   -- Log messages for any creation/reversal of charges
                   IF p_b_log_messages THEN
                      IF l_n_net_amount > 0.0 THEN
                         -- Message that a new charge has been created
                         fnd_message.set_name('IGS','IGS_FI_SPECIAL_FEE_CREATED');
                         fnd_message.set_token('INVOICE_NUMBER',igs_fi_gen_008.get_invoice_number(l_n_invoice_id));
                         fnd_message.set_token('AMT',l_n_net_amount);
                         fnd_msg_pub.add;
                      ELSIF l_n_net_amount < 0.0 THEN
                         -- Message that the charge has been reversed
                         fnd_message.set_name('IGS','IGS_FI_SPECIAL_FEE_REVERSED');
                         fnd_message.set_token('INVOICE_NUMBER',igs_fi_gen_008.get_invoice_number(l_sp_fees_tbl(l_n_tbl_cnt).invoice_id));
                         fnd_message.set_token('AMT',l_sp_fees_tbl(l_n_tbl_cnt).old_amount);
                         fnd_msg_pub.add;
                         IF l_n_retention_amt > 0.0 THEN
                              -- Message that a retention charge has been created
                              fnd_message.set_name('IGS','IGS_FI_RET_TRANSACTION_AMT');
                              fnd_message.set_token('AMOUNT',l_n_retention_amt);
                              fnd_msg_pub.add;
                         END IF;
                      END IF; -- End of check for l_n_net_amount
                   END IF; -- End of log_messages = 'TRUE'

                ELSE
                   IF p_b_log_messages THEN
                       -- Message that there is no change in the charge amount
                       fnd_message.set_name('IGS','IGS_FI_SP_FEE_NO_CHANGE');
                       fnd_msg_pub.add;
                   END IF;
                END IF; -- End for net_amount <> 0

             END IF;  -- End for l_b_chg_decl_rev

          END IF;  -- End if for plsql record EXISTS

      END LOOP; -- End loop for all records in plsql table

   ELSE
     IF p_b_log_messages AND l_b_no_data_found THEN
       log_details(p_v_person_number       => p_v_person_number,
                   p_v_fee_period          => p_v_fee_period,
                   p_v_unit_section_desc   => l_v_unit_section_desc,
                   p_v_fee_type            => NULL);
       fnd_message.set_name('IGF', 'IGF_AP_NO_DATA_FOUND');
       fnd_msg_pub.add;
     END IF;
   END IF; -- End for tbl count > 0

   fnd_msg_pub.count_and_get(p_count      => x_msg_count,
                             p_data       => x_msg_data);

EXCEPTION
   WHEN e_expected_error THEN
      ROLLBACK;
      x_return_status := 'E';
      -- If FND logging is enabled, then send message to the FND log table
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN

         -- Get the message from fnd_msg_pub and put it onto fnd_message stack so that it is logged in fnd_log_messages.
         fnd_msg_pub.count_and_get(p_count      => x_msg_count,
                                   p_data       => x_msg_data);
         IF (x_msg_count = 1) THEN
           fnd_message.set_encoded(x_msg_data);
         ELSIF (x_msg_count > 1) THEN
           x_msg_data := fnd_msg_pub.get(p_msg_index=>fnd_msg_pub.G_LAST);
           fnd_message.set_encoded(x_msg_data);
         END IF;

         -- Log message in FND tables, but do not pop the message from the Stack, hence pass False
         fnd_log.message(fnd_log.level_error, 'igs.patch.115.sql.igs_fi_prc_sp_fees.assess_fees_pvt',FALSE);
      ELSE
        fnd_msg_pub.count_and_get(p_count      => x_msg_count,
                                  p_data       => x_msg_data);
      END IF;
   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := 'U';
      -- If FND logging is enabled, log message as Unexpected error
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
         -- Get the message from fnd_msg_pub and put it onto fnd_message stack so that it is logged in fnd_log_messages.
         fnd_msg_pub.count_and_get(p_count      => x_msg_count,
                                   p_data       => x_msg_data);
         IF (x_msg_count = 1) THEN
           fnd_message.set_encoded(x_msg_data);
         ELSIF (x_msg_count > 1) THEN
           x_msg_data := fnd_msg_pub.get(p_msg_index=>fnd_msg_pub.G_LAST);
           fnd_message.set_encoded(x_msg_data);
         END IF;
          fnd_log.message(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_fi_prc_sp_fees.assess_fees_pvt',FALSE);
          fnd_log.string(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_fi_prc_sp_fees.assess_fees_pvt',SQLERRM);
      ELSE
        fnd_msg_pub.count_and_get(p_count      => x_msg_count,
                                  p_data       => x_msg_data);
      END IF;
END assess_fees_pvt;

PROCEDURE validate_params( p_n_person_id              IN igs_pe_person_base_v.person_id%TYPE,
                           p_n_person_grp_id          IN igs_pe_persid_group_v.group_id%TYPE,
                           p_v_fee_period             IN VARCHAR2,
                           p_v_test_run               IN VARCHAR2,
                           p_d_gl_date                IN VARCHAR2,
                           p_v_fee_cal_type           OUT NOCOPY igs_ca_inst.cal_type%TYPE,
                           p_n_fee_ci_sequence_number OUT NOCOPY igs_ca_inst.sequence_number%TYPE,
                           p_v_ld_cal_type            OUT NOCOPY igs_ca_inst.cal_type%TYPE,
                           p_n_ld_ci_sequence_number  OUT NOCOPY igs_ca_inst.sequence_number%TYPE,
                           p_val_status               OUT NOCOPY BOOLEAN)   IS
------------------------------------------------------------------
  --Created by  :Umesh Udayaprakash, Oracle India (in)
  --Date created: 17-OCT-2003
  --
  --Purpose: To Validate the input parameters and log message to the
  --         Log File.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --akandreg    27-Jun-2006     Bug 5104339: Modified token value passed to 'IGS_FI_INVALID_GL_DATE' using
  --                            igs_ge_date.igsdate().
  --skharida    16-JUN-06   Bug 5094077 changed the log msg when both person number and person grp
  --                        are given as parameter
-------------------------------------------------------------------

--Cursor for Checking the peson_id
CURSOR c_person_id (cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
SELECT person_number
FROM IGS_PE_PERSON_BASE_V
WHERE person_id = cp_person_id;

--Cursor for checking Person Group

CURSOR c_person_grp_id(cp_person_grp_id igs_pe_persid_group_v.group_id%TYPE) IS
 SELECT 'X'
 FROM igs_pe_persid_group_v
 WHERE group_id = cp_person_grp_id
 AND   closed_ind = 'N';

 l_b_parameter_val_status BOOLEAN;
 l_person_id  c_person_id%ROWTYPE;
 l_person_grp_id c_person_grp_id%ROWTYPE;

 l_v_ld_cal_type igs_ca_inst.cal_type%TYPE;
 l_n_ld_ci_sequence_number igs_ca_inst.sequence_number%TYPE;
 l_v_message_name fnd_new_messages.message_name%TYPE;
 l_b_return_stat  BOOLEAN;
 l_v_closing_status  igs_fi_gl_periods_v.closing_status%TYPE;

 l_v_fee_cal_type igs_ca_inst.cal_type%TYPE;
 l_n_fee_ci_sequence_number igs_ca_inst.sequence_number%TYPE;

BEGIN

   l_b_parameter_val_status := TRUE;
   l_v_fee_cal_type := NULL;
   l_n_fee_ci_sequence_number := NULL;
   l_v_ld_cal_type := NULL;
   l_n_ld_ci_sequence_number := NULL;
   fnd_file.new_line(fnd_file.log,1);
-- To Check Whether The Person Id Is Valid If It Is Provided
 IF (p_n_person_id IS NOT NULL) THEN
  OPEN  c_person_id(p_n_person_id);
  FETCH c_person_id INTO l_person_id;
    IF c_person_id%NOTFOUND THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON'));
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_b_parameter_val_status := FALSE;
    END IF;
  CLOSE c_person_id;
 END IF;

-- To Check Whether The Person Group Id Is Valid If It Is Provided

 IF (p_n_person_grp_id IS NOT NULL) THEN
   OPEN  c_person_grp_id(p_n_person_grp_id);
   FETCH c_person_grp_id INTO l_person_grp_id;
     IF c_person_grp_id%NOTFOUND THEN
       fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
       fnd_message.set_token('PARAMETER',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON_GROUP'));
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       l_b_parameter_val_status := FALSE;
     END IF;
   CLOSE c_person_grp_id;
 END IF;

  IF p_v_fee_period IS NOT NULL THEN
   l_v_fee_cal_type := RTRIM(SUBSTR(p_v_fee_period,1,10));
   l_n_fee_ci_sequence_number := TO_NUMBER(RTRIM(SUBSTR(p_v_fee_period,12)));

      IF igs_fi_crdapi_util.validate_cal_inst( p_v_cal_type           => l_v_fee_cal_type,
                                               p_n_ci_sequence_number => l_n_fee_ci_sequence_number,
                                               p_v_s_cal_cat          => 'FEE') THEN
             -- Call To The Procedure To Check Whether The Fee Calendar Instance Has
             -- One To One Relation With Load Calendar Instance
                igs_fi_crdapi_util.validate_fci_lci_reln(p_v_fee_cal_type           => l_v_fee_cal_type,
                                                         p_n_fee_ci_sequence_number => l_n_fee_ci_sequence_number,
                                                         p_v_ld_cal_type            => l_v_ld_cal_type ,
                                                         p_n_ld_ci_sequence_number  => l_n_ld_ci_sequence_number ,
                                                         p_v_message_name           => l_v_message_name ,
                                                         p_b_return_stat            =>l_b_return_stat);
                IF NOT l_b_return_stat THEN
                  fnd_message.set_name('IGS',l_v_message_name);
                  fnd_file.put_line(fnd_file.log,fnd_message.get);
                  l_b_parameter_val_status := FALSE;
                END IF;
       ELSE
           -- The Message 'Invalid Fee Period Parameters Passed To The Process.' Is Logged If
           -- The Function Returns False.
               fnd_message.set_name('IGS','IGS_FI_FCI_NOTFOUND');
               fnd_file.put_line(fnd_file.log,fnd_message.get);
               l_b_parameter_val_status := FALSE;
      END IF;
  END IF;  -- end of p_v_fee_period validation

  -- To Validate The Parameter Test Run
  IF (p_v_test_run IS NULL) OR (p_d_gl_date IS NULL ) THEN
      fnd_message.set_name('IGS','IGS_UC_NO_MANDATORY_PARAMS');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_b_parameter_val_status := FALSE;
  END IF;

  IF p_v_test_run NOT IN ('Y','N')  THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','TEST_RUN'));
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_b_parameter_val_status := FALSE;
  END IF;
 -- To Validate The Parameter Gl Date

  igs_fi_gen_gl.get_period_status_for_date(p_d_date           => igs_ge_date.igsdate(p_d_gl_date),
                                           p_v_closing_status => l_v_closing_status,
                                           p_v_message_name   => l_v_message_name);
  IF l_v_closing_status NOT IN ('O','F') THEN
     fnd_message.set_name('IGS','IGS_FI_INVALID_GL_DATE');
     fnd_message.set_token('GL_DATE',igs_ge_date.igsdate(p_d_gl_date));
     fnd_file.put_line(fnd_file.log,fnd_message.get);
     l_b_parameter_val_status := FALSE;
  END IF;

 -- To Check Whether Both Person_id And Person Group Values Are Provided.
  IF (p_n_person_id IS NOT NULL) AND (p_n_person_grp_id IS NOT NULL)THEN
    fnd_message.set_name('IGS','IGS_FI_NO_PERS_PGRP');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    l_b_parameter_val_status := FALSE;
  END IF;
   --Assign The Values To The Out Parameters.
  p_v_fee_cal_type  :=l_v_fee_cal_type;
  p_n_fee_ci_sequence_number :=l_n_fee_ci_sequence_number;
  p_v_ld_cal_type := l_v_ld_cal_type;
  p_n_ld_ci_sequence_number := l_n_ld_ci_sequence_number;
  p_val_status := l_b_parameter_val_status;

END validate_params;

PROCEDURE assess_fees( errbuf              OUT NOCOPY VARCHAR2,
                       retcode             OUT NOCOPY NUMBER,
                       p_n_person_id       IN  NUMBER,
                       p_n_person_grp_id   IN  NUMBER,
                       p_v_fee_period      IN  VARCHAR2,
                       p_v_test_run        IN  VARCHAR2,
                       p_d_gl_date         IN  VARCHAR2 ) IS

------------------------------------------------------------------
  --Created by  :Umesh Udayaprakash, Oracle India (in)
  --Date created: 17-OCT-2003
  --
  --Purpose: To Validate the input parameters and log message to the
  --         Log File and call the Process_special_fees procedure.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --akandreg   27-Jun-2006      Bug 5104339 -Made code modification to change display format of GL date in log file by
  --                           using igs_ge_date.igsdate().
  --akandreg    09-Jun-2006     Bug 5107755 - Replaced the cursor c_get_alt_code by cursor c_get_alt_code_desc,
  --                            which queries both alternate code and description so that both of them
  --                            can be logged into the log file.
  --abshriva   5-May-2006   Bug 5178077: Introduced igs_ge_gen_003.set_org_id
-------------------------------------------------------------------
  TYPE person_grp_ref_cur_type IS REF CURSOR;
  c_ref_person_grp person_grp_ref_cur_type;

  l_n_person_id igs_pe_std_todo.person_id%TYPE;
  l_dynamic_sql VARCHAR2(32767);
  l_v_status    VARCHAR2(1);
  l_v_manage_acc       igs_fi_control_all.manage_accounts%TYPE;
  l_v_message_name     fnd_new_messages.message_name%TYPE;
-- Out Parameters from the Process_special_fees procedure.
  l_b_recs_found BOOLEAN;
  l_b_person_grp_data_found BOOLEAN;
  l_v_return_status VARCHAR2(1);
  l_b_validate_parm_status BOOLEAN;
  l_v_fee_cal_type igs_ca_inst.cal_type%TYPE;
  l_n_fee_ci_seq_number igs_ca_inst.sequence_number%TYPE;
  l_v_load_cal_type igs_ca_inst.cal_type%TYPE;
  l_n_load_ci_seq_number igs_ca_inst.sequence_number%TYPE;
  l_org_id     VARCHAR2(15);
--Cursor For  Getting The Alternate Code and Description For The Fee Period.
  CURSOR c_get_alt_code_desc(cp_v_cal_type igs_ca_inst.cal_type%TYPE,
                      cp_n_sequence_number igs_ca_inst.sequence_number%TYPE) IS
    SELECT alternate_code, description
    FROM igs_ca_inst
    WHERE cal_type = cp_v_cal_type
    AND   sequence_number = cp_n_sequence_number;
    l_c_alt_code_desc c_get_alt_code_desc%ROWTYPE;
--Cursor For Getting The Group Code For The Group Id
  CURSOR c_get_person_grp (c_group_id igs_pe_persid_group_v.group_id%TYPE) IS
    SELECT group_cd
    FROM  igs_pe_persid_group_v
    WHERE group_id = c_group_id;
  l_c_get_person_grp c_get_person_grp%ROWTYPE;
  l_v_alt_code_msg VARCHAR2(500) DEFAULT NULL;

BEGIN
  BEGIN
     l_org_id := NULL;
     igs_ge_gen_003.set_org_id(l_org_id);
  EXCEPTION
    WHEN OTHERS THEN
       fnd_file.put_line (fnd_file.log, fnd_message.get);
       retcode:=2;
       RETURN;
  END;
    retcode := 0;
    l_b_person_grp_data_found :=FALSE;
  --Logging of all the Parameter to the Log File.
  --Logging  Person Number.
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON')||': '||igs_fi_gen_008.get_party_number(p_n_person_id));
    fnd_file.put_line(fnd_file.log,fnd_message.get);

   --Logging  Person Group.
    OPEN c_get_person_grp(p_n_person_grp_id);
    FETCH c_get_person_grp INTO l_c_get_person_grp;
    CLOSE c_get_person_grp;
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON_GROUP')||': '||l_c_get_person_grp.group_cd);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

  --Logging  Fee Assesment Period.
    OPEN c_get_alt_code_desc(cp_v_cal_type        => RTRIM(SUBSTR(p_v_fee_period,1,10)),
                         cp_n_sequence_number => TO_NUMBER(RTRIM(SUBSTR(p_v_fee_period,12))));
    FETCH c_get_alt_code_desc INTO l_c_alt_code_desc ;
    CLOSE c_get_alt_code_desc;
    --storing the Alternate Code into the Global Variable for passing it to the  assess_fees_pvt procedure
    g_v_alternatecode := l_c_alt_code_desc.alternate_code;
    fnd_message.set_name('IGS','IGS_FI_END_DATE');

    IF l_c_alt_code_desc.alternate_code IS NOT NULL THEN
        l_v_alt_code_msg := ' ( ' || l_c_alt_code_desc.alternate_code || ' ) ';
    END IF;
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_ASS_PERIOD')||': '||l_c_alt_code_desc.description || l_v_alt_code_msg );
    fnd_file.put_line(fnd_file.log,fnd_message.get);
   --Logging  Test run.
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','TEST_RUN')||': '||igs_fi_gen_gl.get_lkp_meaning('YES_NO',p_v_test_run));
    fnd_file.put_line(fnd_file.log,fnd_message.get);

   --Logging  GL Date.
    fnd_message.set_name('IGS','IGS_FI_END_DATE');
    fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','GL_DATE')||': '||igs_ge_date.igsdate(p_d_gl_date));
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    igs_fi_com_rec_interface.chk_manage_account(p_v_manage_acc   => l_v_manage_acc,
                                                p_v_message_name => l_v_message_name);

     IF l_v_manage_acc IS NULL THEN
       fnd_message.set_name('IGS',l_v_message_name);
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       retcode := 2;
       RETURN;
     END IF;
        -- To Validate The Parameters And Log The Message.
         validate_params(    p_n_person_id              => p_n_person_id,
                             p_n_person_grp_id          => p_n_person_grp_id,
                             p_v_fee_period             => p_v_fee_period,
                             p_v_test_run               => p_v_test_run,
                             p_d_gl_date                => p_d_gl_date,
                             p_v_fee_cal_type           => l_v_fee_cal_type,
                             p_n_fee_ci_sequence_number => l_n_fee_ci_seq_number,
                             p_v_ld_cal_type            => l_v_load_cal_type,
                             p_n_ld_ci_sequence_number  => l_n_load_ci_seq_number,
                             p_val_status               => l_b_validate_parm_status) ;

   IF l_b_validate_parm_status THEN
       -- If Person Id Has Been Given or Both person_id and person_group is not provided.
         IF (p_n_person_id IS NOT NULL) OR (p_n_person_id IS  NULL AND p_n_person_grp_id IS  NULL) THEN
            process_special_fees(p_n_person_id          => p_n_person_id,
                                 p_v_fee_cal_type       => l_v_fee_cal_type,
                                 p_n_fee_ci_seq_number  => l_n_fee_ci_seq_number,
                                 p_v_load_cal_type      => l_v_load_cal_type,
                                 p_n_load_ci_seq_number => l_n_load_ci_seq_number,
                                 p_d_gl_date            => igs_ge_date.igsdate(p_d_gl_date),
                                 p_v_test_run           => p_v_test_run,
                                 p_b_log_messages       => TRUE,
                                 p_b_recs_found         => l_b_recs_found,
                                 p_v_return_status      => l_v_return_status);
                 IF  NOT (l_b_recs_found ) THEN
                    fnd_message.set_name('IGS','IGS_FI_END_DATE');
                    fnd_message.set_token('END_DATE',RPAD(g_v_seperator,77,g_v_seperator));
                    fnd_file.put_line(fnd_file.log,fnd_message.get);
                    fnd_message.set_name('IGF','IGF_AP_NO_DATA_FOUND');
                    fnd_file.put_line(fnd_file.log,fnd_message.get);
                    fnd_message.set_name('IGS','IGS_FI_END_DATE');
                    fnd_message.set_token('END_DATE',RPAD(g_v_seperator,77,g_v_seperator));
                    fnd_file.put_line(fnd_file.log,fnd_message.get);
                 END IF;

                 IF l_v_return_status = 'W' THEN
                   retcode := 1;
                 END IF;
         END IF ;

         -- If The Person Group Id Has Been Given As Parameter
         IF p_n_person_grp_id IS NOT NULL THEN
             l_dynamic_sql := igs_pe_dynamic_persid_group.igs_get_dynamic_sql(p_n_person_grp_id,l_v_status );

              IF l_v_status <> 'S' THEN
             --Log the error message and stop the processing.
                 fnd_message.set_name('IGF','IGF_AP_INVALID_QUERY');
                 fnd_file.put_line(fnd_file.log,fnd_message.get);
                 retcode := 2;
                 RETURN;
              END IF;
             OPEN c_ref_person_grp FOR l_dynamic_sql;
           -- Looping Across All The Valid Person Ids In The Group.
                LOOP
                  FETCH c_ref_person_grp INTO l_n_person_id;
                  EXIT WHEN c_ref_person_grp%NOTFOUND;
                  process_special_fees(p_n_person_id          =>l_n_person_id,
                                       p_v_fee_cal_type       =>l_v_fee_cal_type,
                                       p_n_fee_ci_seq_number  =>l_n_fee_ci_seq_number,
                                       p_v_load_cal_type      =>l_v_load_cal_type,
                                       p_n_load_ci_seq_number =>l_n_load_ci_seq_number,
                                       p_d_gl_date            =>igs_ge_date.igsdate(p_d_gl_date),
                                       p_v_test_run           =>p_v_test_run,
                                       p_b_log_messages       =>TRUE,
                                       p_b_recs_found         =>l_b_recs_found,
                                       p_v_return_status      =>l_v_return_status);
                  IF NOT (l_b_person_grp_data_found) AND l_b_recs_found THEN
                    l_b_person_grp_data_found := TRUE;
                  END IF;
                  IF  l_v_return_status = 'W' THEN
                      retcode := 1;
                  END IF;
                END LOOP;
                CLOSE c_ref_person_grp;
                IF NOT (l_b_person_grp_data_found) THEN
                  fnd_message.set_name('IGS','IGS_FI_END_DATE');
                  fnd_message.set_token('END_DATE',RPAD(g_v_seperator,77,g_v_seperator));
                  fnd_file.put_line(fnd_file.log,fnd_message.get);
                  fnd_message.set_name('IGF','IGF_AP_NO_DATA_FOUND');
                  fnd_file.put_line(fnd_file.log,fnd_message.get);
                  fnd_message.set_name('IGS','IGS_FI_END_DATE');
                  fnd_message.set_token('END_DATE',RPAD(g_v_seperator,77,g_v_seperator));
                  fnd_file.put_line(fnd_file.log,fnd_message.get);
                END IF;
         END IF; -- End Of Person Group id based derivation
      --To Log The Message If The Process Is A Test Run .
        IF p_v_test_run = 'Y' THEN
          fnd_message.set_name('IGS','IGS_FI_PRC_TEST_RUN');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        END IF;
   ELSE
    retcode :=2;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
      retcode := 2;
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_fi_prc_sp_fees.assess_fees',SQLERRM);
      END IF;
      errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION') || ' : ' || SQLERRM;
      igs_ge_msg_stack.conc_exception_hndl;
END assess_fees;

PROCEDURE log_error_message(p_v_person_number hz_parties.party_number%TYPE,
                            p_v_fee_period VARCHAR2,
                            p_uooid  igs_pe_std_todo_ref.uoo_id%TYPE,
                            p_v_message_name  VARCHAR2 ) IS
------------------------------------------------------------------
  --Created by  :Umesh Udayaprakash, Oracle India (in)
  --Date created: 21-OCT-2003
  --
  --Purpose: To Log The Error Message
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --akandreg    09-Jun-2006     Bug 5107755 - Modified signature of the method by passing parameter
  --                            p_v_fee_period instead of p_v_fee_period_alt_code.

-------------------------------------------------------------------
l_unit_section  VARCHAR2(4000);
BEGIN
   fnd_message.set_name('IGS','IGS_FI_END_DATE');
  fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON')||': '||p_v_person_number);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  --To Log The Fee Assesment Period.
  fnd_message.set_name('IGS','IGS_FI_END_DATE');
  fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_ASS_PERIOD')||': '||p_v_fee_period);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  -- To Log The Unit Section .
  l_unit_section := igs_fi_gen_apint.get_unit_section_desc(   p_n_uoo_id              =>p_uooid,
                                                               p_v_unit_cd            =>NULL,
                                                               p_n_version_number     =>NULL,
                                                               p_v_cal_type           =>NULL,
                                                               p_n_ci_sequence_number =>NULL,
                                                               p_v_location_cd        =>NULL,
                                                               p_v_unit_class         =>NULL );
  fnd_message.set_name('IGS','IGS_FI_END_DATE');
  fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','USEC')||': '||l_unit_section);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
  -- To Log The Message
  fnd_message.set_name('IGS',p_v_message_name);
  fnd_file.put_line(fnd_file.log,fnd_message.get);
 -- Logging of Separator
  fnd_message.set_name('IGS','IGS_FI_END_DATE');
  fnd_message.set_token('END_DATE',RPAD(g_v_seperator,77,g_v_seperator));
  fnd_file.put_line(fnd_file.log,fnd_message.get);
END log_error_message;

PROCEDURE process_special_fees(p_n_person_id            IN PLS_INTEGER,
                               p_v_fee_cal_type         IN VARCHAR2,
                               p_n_fee_ci_seq_number    IN PLS_INTEGER,
                               p_v_load_cal_type        IN VARCHAR2,
                               p_n_load_ci_seq_number   IN PLS_INTEGER,
                               p_d_gl_date              IN DATE,
                               p_v_test_run             IN VARCHAR2,
                               p_b_log_messages         IN BOOLEAN,
                               p_b_recs_found           OUT NOCOPY BOOLEAN,
                               p_v_return_status        OUT NOCOPY VARCHAR2) IS
------------------------------------------------------------------
  --Created by  :Umesh Udayaprakash, Oracle India (in)
  --Date created: 21-OCT-2003
  --
  --Purpose:To identify the records to be processed by the assess_fees_pvt procedure
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --akandreg   09-Jun-2006      Bug 5107755 - Replaced the cursor c_get_alt_code by cursor c_get_alt_code_desc,
  --                            which queries both alternate code and description so that both of them
  --                            can be logged into the log file. Also passed l_v_fee_period instead
  --                            of l_v_alt_code_desc for log_details and assess_fees_pvt procedures.
  --akandreg   25-May-2006      Bug 5134636 - Modified exception section for Lock exception
  --                            to include logging of Person Number
  --                            Added call to new function fisp_lock_records
  --                            Added logic to lock records before processing
 -------------------------------------------------------------------
  -- Exception raised when a lock could not be obtained in the Temp table.
     e_lock_exception                EXCEPTION;
     PRAGMA EXCEPTION_INIT(e_lock_exception, -54);

CURSOR c_get_todo_recs(cp_n_person_id igs_pe_std_todo.person_id%TYPE, cp_v_todo_type igs_pe_std_todo.s_student_todo_type%TYPE ) IS
  SELECT igs_pe_std_todo.rowid , igs_pe_std_todo.*
  FROM igs_pe_std_todo
  WHERE (person_id = cp_n_person_id OR cp_n_person_id IS NULL)
  AND    s_student_todo_type = cp_v_todo_type
  AND    logical_delete_dt is NULL;


CURSOR c_get_todo_ref_recs(cp_n_person_id igs_pe_std_todo.person_id%TYPE,
                           cp_n_sequence_number igs_pe_std_todo_ref.sequence_number%TYPE,
                           cp_v_todo_type igs_pe_std_todo.s_student_todo_type%TYPE,
                           cp_v_ld_cal_type igs_pe_std_todo_ref.cal_type%TYPE,
                           cp_n_ld_seq_number igs_pe_std_todo_ref.ci_sequence_number%TYPE) IS
      SELECT tref.rowid , tref.*
      FROM igs_pe_std_todo_ref tref
      WHERE tref.person_id = cp_n_person_id
      AND   tref.sequence_number = cp_n_sequence_number
      AND   tref.s_student_todo_type = cp_v_todo_type
      AND   tref.logical_delete_dt IS NULL
      AND   (
             (tref.cal_type = cp_v_ld_cal_type)
             OR
             (cp_v_ld_cal_type IS NULL)
            )
      AND
           ( tref.ci_sequence_number = cp_n_ld_seq_number
              OR
             (cp_n_ld_seq_number IS NULL)
           );

      --Cursor To Get The Alternate Code For The Cal_type And sequence number
CURSOR c_get_alt_code_desc(cp_v_cal_type igs_ca_inst.cal_type%TYPE,
                      cp_n_sequence_number igs_ca_inst.sequence_number%TYPE) IS
    SELECT alternate_code,description
    FROM igs_ca_inst
    WHERE cal_type = cp_v_cal_type
    AND   sequence_number = cp_n_sequence_number;
  CURSOR c_check_child_exists(cp_n_person_id igs_pe_std_todo.person_id%TYPE,
                              cp_n_sequence_number igs_pe_std_todo_ref.sequence_number%TYPE,
                              cp_v_todo_type igs_pe_std_todo.s_student_todo_type%TYPE ) IS
    SELECT 'X'
    FROM igs_pe_std_todo_ref tref
    WHERE tref.person_id = cp_n_person_id
    AND   tref.s_student_todo_type = cp_v_todo_type
    AND   tref.sequence_number = cp_n_sequence_number
    AND   logical_delete_dt is NULL;
l_check_child_exists c_check_child_exists%ROWTYPE;
l_c_get_todo_recs c_get_todo_recs%ROWTYPE;
l_c_get_todo_ref_recs c_get_todo_ref_recs%ROWTYPE;
l_c_alt_code_desc c_get_alt_code_desc%ROWTYPE;
l_v_alt_code_desc igs_ca_inst.alternate_code%TYPE;
l_v_ci_desc igs_ca_inst.description%TYPE;

l_v_person_number hz_parties.party_number%TYPE;
l_unit_section  VARCHAR2(4000);

l_message_name fnd_new_messages.message_name%TYPE;
-- To identify whether any  records are found for given the input criteria.
l_v_return_status     VARCHAR2(1);
l_count               NUMBER(5);
l_msg                 VARCHAR2(2000);
l_v_fee_cal_type igs_ca_inst.cal_type%TYPE;
l_n_fee_ci_sequence_number PLS_INTEGER;
l_n_msg_count NUMBER;
l_v_msg_data VARCHAR2(32767);
l_b_rel_exists BOOLEAN;
l_b_error   BOOLEAN;
l_v_fee_period VARCHAR2(4000);
BEGIN
 -- Used to check whether any records are found for the input criteria.
  p_b_recs_found := FALSE;
  l_v_fee_cal_type := p_v_fee_cal_type;
  l_n_fee_ci_sequence_number  := p_n_fee_ci_seq_number;
  -- Set The Error And Success Flags To Null
  l_b_error   := FALSE;
  l_v_alt_code_desc:= g_v_alternatecode; --Storing The Alternate Code Description Into The  Local Variable
  FOR l_c_get_todo_recs IN  c_get_todo_recs( cp_n_person_id => p_n_person_id,
                                             cp_v_todo_type => 'SPECIAL_FEE' )
      LOOP
            IF  p_b_log_messages = TRUE THEN
              l_v_person_number := IGS_FI_GEN_008.GET_PARTY_NUMBER(l_c_get_todo_recs.person_id);
            END IF; -- End Of P_b_log_messages
            FOR l_c_get_todo_ref_recs IN  c_get_todo_ref_recs(cp_n_person_id       => l_c_get_todo_recs.person_id  ,
                                                              cp_n_sequence_number => l_c_get_todo_recs.sequence_number,
                                                              cp_v_todo_type       => l_c_get_todo_recs.s_student_todo_type ,
                                                              cp_v_ld_cal_type     => p_v_load_cal_type,
                                                              cp_n_ld_seq_number   => p_n_load_ci_seq_number )
               LOOP
                --If fee period is provided
                -- Before processing, obtain a lock in table IGS_FI_SPA_FEE_PRDS for the given Person-Course-Fee Period.
                IF (l_v_fee_cal_type IS NOT NULL) AND (l_n_fee_ci_sequence_number IS NOT NULL) THEN
                   IF  NOT fisp_lock_records (p_n_person_id            => l_c_get_todo_ref_recs.person_id,
                                           p_v_course_cd               => l_c_get_todo_ref_recs.course_cd,
                                           p_v_fee_cal_type            => l_v_fee_cal_type,
                                           p_n_fee_ci_sequence_number  => l_n_fee_ci_sequence_number) THEN
                        -- If lock could not be obtained, error out.
                       RAISE e_lock_exception;
                   END IF;
                END IF;
                 p_b_recs_found := TRUE;
                 IF (l_c_get_todo_ref_recs.cal_type IS NOT NULL AND l_c_get_todo_ref_recs.ci_sequence_number IS NOT NULL) THEN
                           l_b_rel_exists := TRUE;
                           IF (p_v_fee_cal_type IS NULL)  OR (p_n_fee_ci_seq_number IS NULL ) THEN
                           -- To Check Whether One To One Relation
                           -- The Function Will Return False When No Relation Is Found
                                  IF NOT igs_fi_gen_001.finp_get_lfci_reln  ( p_cal_type               => l_c_get_todo_ref_recs.cal_type,
                                                                              p_ci_sequence_number     => l_c_get_todo_ref_recs.ci_sequence_number,
                                                                              p_cal_category           => 'LOAD',
                                                                              p_ret_cal_type           => l_v_fee_cal_type,
                                                                              p_ret_ci_sequence_number => l_n_fee_ci_sequence_number,
                                                                              p_message_name            =>l_message_name) THEN
                                           -- If P_b_log_messages Is True Then Log To The Log File
                                           l_b_rel_exists := FALSE;
                                           l_b_error := TRUE;
                                           IF p_b_log_messages THEN
                                             -- to log the person number
                                              log_error_message(   p_v_person_number  =>l_v_person_number,
                                                                   p_v_fee_period     =>NULL,
                                                                   p_uooid            =>l_c_get_todo_ref_recs.uoo_id,
                                                                   p_v_message_name   =>l_message_name);
                                           END IF;
                                  END IF ; --igs_fi_gen_001

                                  -- Before processing, obtain a lock in table IGS_FI_SPA_FEE_PRDS for the given Person-Course-Fee Period.
                                  -- if fee period is not provided
                                 IF  NOT fisp_lock_records (p_n_person_id            => l_c_get_todo_ref_recs.person_id,
                                                         p_v_course_cd               => l_c_get_todo_ref_recs.course_cd,
                                                         p_v_fee_cal_type            => l_v_fee_cal_type,
                                                         p_n_fee_ci_sequence_number  => l_n_fee_ci_sequence_number) THEN
                                      -- If lock could not be obtained, error out.
                                     RAISE e_lock_exception;
                                 END IF;

                                 -- To Get The Alt Code and description
                                  IF p_b_log_messages AND l_b_rel_exists = TRUE THEN
                                    OPEN c_get_alt_code_desc(cp_v_cal_type        => l_v_fee_cal_type,
                                                        cp_n_sequence_number => l_n_fee_ci_sequence_number);
                                    FETCH c_get_alt_code_desc INTO l_c_alt_code_desc ;
                                    l_v_alt_code_desc :=l_c_alt_code_desc.alternate_code;
                                    l_v_ci_desc := l_c_alt_code_desc.description;
                                    -- for logging fee period
                                    l_v_fee_period := l_v_ci_desc ;
                                    IF l_v_alt_code_desc IS NOT NULL THEN
                                        l_v_fee_period := l_v_fee_period || ' ( ' || l_v_alt_code_desc || ' ) ';
                                    END IF;
                                   CLOSE c_get_alt_code_desc;
                                  END IF;
                                  -- If condition to check whether the Load calendar instance is active
                                  IF l_b_rel_exists = TRUE AND (NOT igs_fi_crdapi_util.validate_cal_inst( p_v_cal_type           => l_c_get_todo_ref_recs.cal_type,
                                                                              p_n_ci_sequence_number => l_c_get_todo_ref_recs.CI_SEQUENCE_NUMBER,
                                                                              p_v_s_cal_cat          => 'LOAD') ) THEN
                                      l_b_rel_exists := FALSE;
                                      l_b_error := TRUE;
                                      IF p_b_log_messages THEN
                                         log_error_message(p_v_person_number  =>l_v_person_number,
                                                           p_v_fee_period     => l_v_fee_period,
                                                           p_uooid            =>l_c_get_todo_ref_recs.uoo_id,
                                                           p_v_message_name   =>'IGS_FI_LOAD_CAL_NOT_ACTIVE');
                                      END IF; --End Of Logging Mesage
                                  END IF;    -- To Check Whether The Load Calendar Is Active Or Not.

                                  IF l_b_rel_exists = TRUE AND (NOT igs_fi_crdapi_util.validate_cal_inst(p_v_cal_type           => l_v_fee_cal_type,
                                                                              p_n_ci_sequence_number => l_n_fee_ci_sequence_number,
                                                                              p_v_s_cal_cat          =>'FEE') ) THEN
                                      l_b_rel_exists := FALSE;
                                      l_b_error := TRUE;
                                      IF p_b_log_messages THEN
                                        log_error_message(p_v_person_number  =>l_v_person_number,
                                                          p_v_fee_period     => l_v_fee_period,
                                                          p_uooid            =>l_c_get_todo_ref_recs.uoo_id,
                                                          p_v_message_name   =>'IGS_FI_FCI_NOTFOUND');
                                      END IF;
                                  END IF; -- End If Part Of Check For Validation Fee Instance Is Active Or Not
                           END IF; -- End If For The Check Of Fee Calendar Instance Variable.
                           -- To Check Whether The Fee Calendar Instance Is Active Or Not
                           --  igs_fi_crdapi_util.validate_cal_inst Returns False When The It Is Not Active.
                     IF l_b_rel_exists THEN
                               assess_fees_pvt(p_n_person_id               => l_c_get_todo_ref_recs.person_id,
                                               p_v_person_number           => l_v_person_number,
                                               p_v_course_cd               => l_c_get_todo_ref_recs.course_cd,
                                               p_n_uoo_id                  => l_c_get_todo_ref_recs.uoo_id,
                                               p_v_fee_cal_type            => l_v_fee_cal_type,
                                               p_n_fee_ci_sequence_number  => l_n_fee_ci_sequence_number,
                                               p_v_fee_period              => l_v_fee_period,
                                               p_v_load_cal_type           => l_c_get_todo_ref_recs.cal_type,
                                               p_n_load_ci_sequence_number => l_c_get_todo_ref_recs.ci_sequence_number,
                                               p_d_gl_date                 => p_d_gl_date,
                                               p_b_log_messages            => p_b_log_messages,
                                               x_return_status             => l_v_return_status,
                                               x_msg_count                 => l_n_msg_count,
                                               x_msg_data                  => l_v_msg_data);
                              -- If The Return Status From Assess_fees_pvt Is S Then Processing Is Sucessfull
                                 IF l_v_return_status = 'S' THEN
                                    -- If The Special Fees Co Routine Has Been Processed Sucessfully The Update The Logical Delete Date To Sysdate.
                                      igs_pe_std_todo_ref_pkg.update_row  (x_rowid                  =>l_c_get_todo_ref_recs.rowid,
                                                                           x_person_id              =>l_c_get_todo_ref_recs.person_id,
                                                                           x_s_student_todo_type    =>l_c_get_todo_ref_recs.s_student_todo_type,
                                                                           x_sequence_number        =>l_c_get_todo_ref_recs.sequence_number,
                                                                           x_reference_number       =>l_c_get_todo_ref_recs.reference_number,
                                                                           x_cal_type               =>l_c_get_todo_ref_recs.cal_type,
                                                                           x_ci_sequence_number     =>l_c_get_todo_ref_recs.ci_sequence_number,
                                                                           x_course_cd              =>l_c_get_todo_ref_recs.course_cd,
                                                                           x_unit_cd                =>l_c_get_todo_ref_recs.unit_cd,
                                                                           x_other_reference        =>l_c_get_todo_ref_recs.other_reference,
                                                                           x_logical_delete_dt      =>SYSDATE,
                                                                           x_uoo_id                 =>l_c_get_todo_ref_recs.uoo_id );
                                 ELSE
                                    --To Indicate Some Of The Record Has Error Out
                                    l_b_error := TRUE;
                                 END IF;   -- End if of Check For The L_return_status
                                  -- Code To Unravel The Message Stack And Put It In The Log File.
                                 IF l_n_msg_count = 1 THEN
                                    fnd_message.set_encoded(l_v_msg_data);
                                    fnd_file.put_line(fnd_file.log,fnd_message.get);
                                    fnd_message.set_name('IGS','IGS_FI_END_DATE');
                                    fnd_message.set_token('END_DATE',RPAD(g_v_seperator,77,g_v_seperator));
                                    fnd_file.put_line(fnd_file.log,fnd_message.get);
                                 ELSIF l_n_msg_count <> 0 THEN
                                     FOR l_count IN 1 .. l_n_msg_count LOOP
                                          l_msg := fnd_msg_pub.get(p_msg_index => l_count, p_encoded => 'T');
                                          fnd_message.set_encoded(l_msg);
                                          fnd_file.put_line(fnd_file.log,fnd_message.get);
                                     END LOOP;
                                     fnd_message.set_name('IGS','IGS_FI_END_DATE');
                                     fnd_message.set_token('END_DATE',RPAD(g_v_seperator,77,g_v_seperator));
                                     fnd_file.put_line(fnd_file.log,fnd_message.get);
                                 END IF;
                       END IF;  --end if of l_b_rel_exists
                 END IF;
               END LOOP; -- End Loop Of Cursor c_get_todo_ref_recs
                      -- This Flag Will Be True If All The Records Identified By The Cursor Are Processed Sucessfully By The
                      -- Assess_fee_pvt Procedure Then Update The Igs_pe_std_todo Table Logical_delete Date With The System Date.
                   OPEN c_check_child_exists(cp_n_person_id       =>l_c_get_todo_recs.person_id,
                                             cp_n_sequence_number =>l_c_get_todo_recs.sequence_number,
                                             cp_v_todo_type       =>'SPECIAL_FEE' );
                   FETCH c_check_child_exists INTO l_check_child_exists;
                   IF c_check_child_exists%NOTFOUND THEN
                           igs_pe_std_todo_pkg.update_row(x_rowid                 =>l_c_get_todo_recs.rowid,
                                                          x_person_id             =>l_c_get_todo_recs.person_id,
                                                          x_s_student_todo_type   =>l_c_get_todo_recs.s_student_todo_type,
                                                          x_sequence_number       =>l_c_get_todo_recs.sequence_number,
                                                          x_todo_dt               =>l_c_get_todo_recs.todo_dt ,
                                                          x_logical_delete_dt     =>SYSDATE );
                   END IF;
                   CLOSE c_check_child_exists;
                   IF p_v_test_run = 'N' THEN
                      COMMIT;
                   ELSE
                      ROLLBACK;
                   END IF;
      END LOOP ;--End Loop Of Cursor c_get_todo_recs
--Code for setting the return status
    -- 1) If all the records are processed sucessfully the return status is sucess
    -- 2) If all the records have errored out then the return status is Error
    -- 3) If some of the Records have completed sucessfully and some errored out the status is warning.
   IF  l_b_error = FALSE  THEN
       p_v_return_status := 'S';
   ELSE
       p_v_return_status := 'W';
   END IF;
    EXCEPTION
     WHEN e_lock_exception THEN
             fnd_message.set_name('IGS','IGS_FI_END_DATE');
             fnd_message.set_token('END_DATE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON')||': '||l_v_person_number);
             fnd_file.put_line(fnd_file.log,fnd_message.get);
             fnd_message.set_name('IGS', 'IGS_FI_RFND_REC_LOCK');
             fnd_file.put_line(fnd_file.log,fnd_message.get);
             fnd_file.new_line(fnd_file.log);
             -- Set status to 'Warning'
             p_v_return_status := 'W';
     WHEN OTHERS THEN
              fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXP');
              fnd_Message.Set_Token('NAME','igs_fi_prc_sp_fees.process_special_fees-'||SUBSTR(sqlerrm,1,500));
              igs_ge_msg_stack.ADD;
              App_Exception.Raise_Exception;

END process_special_fees;


FUNCTION fisp_insert_record(p_n_person_id                  IN igs_fi_spa_fee_prds.person_id%TYPE,
                             p_v_course_cd                 IN igs_fi_spa_fee_prds.course_cd%TYPE,
                             p_v_fee_cal_type              IN igs_fi_spa_fee_prds.fee_cal_type%TYPE,
                             p_n_fee_ci_sequence_number    IN igs_fi_spa_fee_prds.fee_ci_sequence_number%TYPE)
RETURN BOOLEAN
IS
PRAGMA AUTONOMOUS_TRANSACTION;
/*************************************************************
 Created By : akandreg
 Date Created By : 25-May-2006
 Purpose : This function locks the record in the table IGS_FI_SPA_FEE_PRDS
           based on the combination of Person-Course-Fee Period that is
           passed as the input parameters. Added as a fix to prevent
           concurrent running of multiple instances of the process.

           Returns TRUE if locking was successful, FALSE otherwise.

 Know limitations, enhancements or remarks
 Change History
 Who            When        What
***************************************************************/

l_rowid                ROWID;

BEGIN

   l_rowid := NULL;
   igs_fi_spa_fee_prds_pkg.insert_row ( x_rowid                   => l_rowid,
                                        x_person_id               => p_n_person_id,
                                        x_course_cd               => p_v_course_cd,
                                        x_fee_cal_type            => p_v_fee_cal_type,
                                        x_fee_ci_sequence_number  => p_n_fee_ci_sequence_number,
                                        x_mode                    => 'R',
                                        x_transaction_type        => 'SPECIAL'
                                      );

   --commiting
   COMMIT;

   RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
     IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_fi_prc_sp_fees.fisp_insert_record',SQLERRM);
     END IF;
     RETURN FALSE;

END fisp_insert_record;

FUNCTION  fisp_lock_records(p_n_person_id                  IN igs_fi_spa_fee_prds.person_id%TYPE,
                             p_v_course_cd                 IN igs_fi_spa_fee_prds.course_cd%TYPE,
                             p_v_fee_cal_type              IN igs_fi_spa_fee_prds.fee_cal_type%TYPE,
                             p_n_fee_ci_sequence_number    IN igs_fi_spa_fee_prds.fee_ci_sequence_number%TYPE)
RETURN BOOLEAN IS
/*************************************************************
 Created By : akandreg
 Date Created By : 25-May-2006
 Purpose : Bug 5134636. This function locks the record in the table IGS_FI_SPA_FEE_PRDS
           based on the combination of Person-Course-Fee Period that is
           passed as the input parameters. Added as a fix to prevent
           concurrent running of multiple instances of the process.

           Returns TRUE if locking was successful, FALSE otherwise.

 Know limitations, enhancements or remarks
 Change History
 Who            When        What
***************************************************************/

CURSOR cur_fee_spa (cp_person_id               igs_fi_spa_fee_prds.person_id%TYPE,
                    cp_course_cd               igs_fi_spa_fee_prds.course_cd%TYPE,
                    cp_fee_cal_type            igs_fi_spa_fee_prds.fee_cal_type%TYPE,
                    cp_fee_ci_sequence_number  igs_fi_spa_fee_prds.fee_ci_sequence_number%TYPE,
                    cp_transaction_type        igs_fi_spa_fee_prds.transaction_type%TYPE) IS
  SELECT 'x'
  FROM igs_fi_spa_fee_prds
  WHERE person_id = cp_person_id
  AND course_cd = cp_course_cd
  AND fee_cal_type = cp_fee_cal_type
  AND fee_ci_sequence_number = cp_fee_ci_sequence_number
  AND transaction_type = cp_transaction_type
  FOR UPDATE NOWAIT;

l_v_dummy  VARCHAR2(2) := NULL;   -- Dummy variable to hold the value selected in cur_fee_spa

BEGIN

   OPEN cur_fee_spa(p_n_person_id,
                    p_v_course_cd,
                    p_v_fee_cal_type,
                    p_n_fee_ci_sequence_number,
                    'SPECIAL');
   FETCH cur_fee_spa INTO l_v_dummy;
   IF cur_fee_spa%NOTFOUND THEN
       -- If the record does not exist in igs_fi_spa_fee_period table, then insert into the table.
       CLOSE cur_fee_spa;
       -- Call autonomous function to insert into IGS_FI_SPA_FEE_PRDS
       IF fisp_insert_record(p_n_person_id,
                              p_v_course_cd,
                              p_v_fee_cal_type,
                              p_n_fee_ci_sequence_number) THEN
         -- After insertion (if insertion was successful), lock the record
         OPEN cur_fee_spa(p_n_person_id,
                          p_v_course_cd,
                          p_v_fee_cal_type,
                          p_n_fee_ci_sequence_number,
                          'SPECIAL');
         FETCH cur_fee_spa INTO l_v_dummy;
         CLOSE cur_fee_spa;
         RETURN TRUE;
       ELSE
         -- Insertion failed, return FALSE
         RETURN FALSE;
       END IF;
   ELSE
       -- If record exists in table igs_fi_spa_fee_period, then lock the record.
       CLOSE cur_fee_spa;
       RETURN TRUE;
   END IF;  -- End if for cursor cur_fee_spa NOTFOUND

EXCEPTION
  WHEN OTHERS THEN
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_fi_prc_sp_fees.fisp_lock_records',SQLERRM);
      END IF;
     RETURN FALSE;

END fisp_lock_records;

END igs_fi_prc_sp_fees;

/
