--------------------------------------------------------
--  DDL for Package Body IGF_SL_REL_DISB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_REL_DISB" AS
/* $Header: IGFSL27B.pls 120.8 2006/08/10 16:32:01 museshad noship $ */

   /*
   ||  Created By : pssahni
   ||  Created On : 23-Sep-2004
   ||  Purpose    : Disbursement Process evaluates  disbursements for
   ||               various checks in Fund Setup so that these can be
   ||               picked up by SF Integration Process which will
   ||               credit / debit the disbursement.
   ||  Known limitations, enhancements or remarks :
   ||
   ||  (reverse chronological order - newest change first)
   ||  who           WHEN            what
   ||  museshad      10-Aug-2006     Bug 5337555. Build FA 163. TBH Impact.
   ||                23-Sep-2004     Creation of the file
   ||                                FA149 -
   */
------------------------------------------------------------------------------------------
-- who           when            what
------------------------------------------------------------------------------------------
-- sjadhav       09-Nov-2004     added following checks
--                               DRI should not set if the Pell or Loan is Sent
--                               DRI should not be set for accepted FFELP loan is not
--                               Release-4
------------------------------------------------------------------------------------------


   l_fund_type                   VARCHAR2(1);


------------------------------------------------------------------------------------------

   FUNCTION get_fund_desc(p_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
      RETURN VARCHAR2
   IS

--------------------------------------------------------------------------------------------
--
--   Purpose            :       Returns fund code + description of the fund id passed
--
--------------------------------------------------------------------------------------------

      CURSOR cur_fund_des(p_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
      IS
         SELECT fund_code fdesc
           FROM igf_aw_fund_mast
          WHERE fund_id = p_fund_id;

      fund_des_rec                  cur_fund_des%ROWTYPE;
   BEGIN
      OPEN cur_fund_des(p_fund_id);
      FETCH cur_fund_des INTO fund_des_rec;

      IF cur_fund_des%NOTFOUND
      THEN
         CLOSE cur_fund_des;
         RETURN NULL;
      ELSE
         CLOSE cur_fund_des;
         RETURN fund_des_rec.fdesc;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME', 'IGF_SL_REL_DISB.GET_FUND_DESC ' || SQLERRM);
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END get_fund_desc;

   FUNCTION chk_attendance(
   p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
      p_load_cal_type igs_ca_inst_all.cal_type%TYPE,
      p_load_seq_number igs_ca_inst_all.sequence_number%TYPE,
      p_min_att_type igs_en_atd_type_all.attendance_type%TYPE,
      p_result OUT NOCOPY VARCHAR2
   )
      RETURN BOOLEAN
   AS

--------------------------------------------------------------------------------------------
--
--   Purpose            :       This Process evaluates min attendance for student
--
--------------------------------------------------------------------------------------------

      CURSOR cur_get_range(
      p_load_cal_type igs_ca_inst_all.cal_type%TYPE,
         p_min_att_type igs_en_atd_type_all.attendance_type%TYPE
      )
      IS
         SELECT upper_enr_load_range
           FROM igs_en_atd_type_load
          WHERE cal_type = p_load_cal_type
                AND attendance_type = p_min_att_type;

      get_range_rec                 cur_get_range%ROWTYPE;
      l_min_range                   igs_en_atd_type_all.upper_enr_load_range%TYPE;
      l_key_range                   igs_en_atd_type_all.upper_enr_load_range%TYPE;
      l_key_att_type                igs_en_atd_type_all.attendance_type%TYPE;
      l_credit_pts                  NUMBER;
      l_fte                         VARCHAR2(10);
   BEGIN
      OPEN cur_get_range(p_load_cal_type, p_min_att_type);
      FETCH cur_get_range INTO get_range_rec;

      IF cur_get_range%NOTFOUND
      THEN
         l_min_range := 0;
         CLOSE cur_get_range;
      ELSE
         l_min_range := get_range_rec.upper_enr_load_range;
         CLOSE cur_get_range;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.chk_attendance.debug', 'l_min_range='|| l_min_range);
      END IF;

      BEGIN
         igs_en_prc_load.enrp_get_inst_latt(
            igf_gr_gen.get_person_id(p_base_id), p_load_cal_type,
            p_load_seq_number, l_key_att_type, l_credit_pts, l_fte
         );
      EXCEPTION
         WHEN OTHERS
         THEN
            p_result := fnd_message.get;
            RETURN FALSE;
      END;

      OPEN cur_get_range(p_load_cal_type, l_key_att_type);
      FETCH cur_get_range INTO get_range_rec;

      IF cur_get_range%NOTFOUND
      THEN
         l_key_range := 0;
         CLOSE cur_get_range;
      ELSE
         l_key_range := get_range_rec.upper_enr_load_range;
         CLOSE cur_get_range;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.chk_attendance.debug', 'l_key_range='|| l_key_range);
      END IF;

      IF l_key_range >= l_min_range
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token(
            'NAME', 'igf_sl_rel_disb.chk_attendance' || SQLERRM
         );
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END chk_attendance;

   FUNCTION chk_fed_elig(
   p_base_id igf_ap_fa_base_rec_all.base_id%TYPE, p_fund_type VARCHAR2
   )
      RETURN BOOLEAN
   AS

--------------------------------------------------------------------------------------------
--
--   Purpose            :       This routine is for Federal Eligibility Check
--
--------------------------------------------------------------------------------------------

--Get the eligibility status of the student for an active ISIR for the context Award Year

      CURSOR cur_fedl_elig(p_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
      IS
         SELECT
		fabaserec.NSLDS_DATA_OVERRIDE_FLG,
		match.nslds_match_flag
           FROM
		igf_ap_isir_matched match ,
		igf_ap_fa_base_rec_all fabaserec
          WHERE
		match.base_id = p_base_id and
 	        match.active_isir = 'Y' and
 	        fabaserec.base_id =p_base_id;

      fedl_elig_rec                 cur_fedl_elig%ROWTYPE;
      l_return_status               VARCHAR2(30);
   BEGIN
      OPEN cur_fedl_elig(p_base_id);
      FETCH cur_fedl_elig INTO fedl_elig_rec;
      CLOSE cur_fedl_elig;

      IF  p_fund_type IN ('D', 'F') AND ((NVL(fedl_elig_rec.nslds_match_flag, 'N') = '1') OR (fedl_elig_rec.NSLDS_DATA_OVERRIDE_FLG ='Y'))
      THEN
         RETURN TRUE;
      ELSIF p_fund_type = 'P'
      THEN
         --
         -- Use the new wrapper to determine Pell Elig
         -- FA131 Check
         --
         igf_gr_pell_calc.pell_elig(p_base_id, l_return_status);

         IF NVL(l_return_status, '*') <> 'E'
         THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token(
            'NAME', 'IGF_SL_REL_DISB.CHK_FED_ELIG ' || SQLERRM
         );
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END chk_fed_elig;

   FUNCTION chk_loan_active(p_loan_id igf_sl_loans_all.loan_id%TYPE)
      RETURN BOOLEAN
   AS
      /*
      ||  Created By : pssahni
      ||  Created On : 3-Oct-2004
      ||  Purpose : To Check whether a loan is active or not
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      */

-- Get the details of loan status
      CURSOR cur_loan_active(p_loan_id igf_sl_loans_all.loan_id%TYPE)
      IS
         SELECT active
           FROM igf_sl_loans_all
          WHERE loan_id = p_loan_id;

      loan_active_rec               cur_loan_active%ROWTYPE;
   BEGIN
      OPEN cur_loan_active(p_loan_id);
      FETCH cur_loan_active INTO loan_active_rec;
      CLOSE cur_loan_active;

      IF loan_active_rec.active = 'Y' OR loan_active_rec.active = 'y'
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token(
            'NAME', 'IGF_SL_REL_DISB.CHK_FED_ELIG ' || SQLERRM
         );
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END chk_loan_active;

   FUNCTION per_in_fa(
   p_person_id igf_ap_fa_base_rec_all.person_id%TYPE, p_ci_cal_type VARCHAR2,
      p_ci_sequence_number NUMBER, p_base_id OUT NOCOPY NUMBER
   )

--------------------------------------------------------------------------------------------
--
--  Purpose            :       Returns person number for the person id passed
--
--------------------------------------------------------------------------------------------

      RETURN VARCHAR2
   IS
      CURSOR cur_get_pers_num(
      p_person_id igf_ap_fa_base_rec_all.person_id%TYPE
      )
      IS
         SELECT person_number
           FROM igs_pe_person_base_v
          WHERE person_id = p_person_id;

      get_pers_num_rec              cur_get_pers_num%ROWTYPE;

      CURSOR cur_get_base(
      p_cal_type igs_ca_inst_all.cal_type%TYPE,
         p_sequence_number igs_ca_inst_all.sequence_number%TYPE,
         p_person_id igf_ap_fa_base_rec_all.person_id%TYPE
      )
      IS
         SELECT base_id
           FROM igf_ap_fa_base_rec
          WHERE person_id = p_person_id AND ci_cal_type = p_cal_type
                AND ci_sequence_number = p_sequence_number;
   BEGIN
      OPEN cur_get_pers_num(p_person_id);
      FETCH cur_get_pers_num INTO get_pers_num_rec;

      IF cur_get_pers_num%NOTFOUND
      THEN
         CLOSE cur_get_pers_num;
         RETURN NULL;
      ELSE
         CLOSE cur_get_pers_num;
         OPEN cur_get_base(p_ci_cal_type, p_ci_sequence_number, p_person_id);
         FETCH cur_get_base INTO p_base_id;
         CLOSE cur_get_base;
         RETURN get_pers_num_rec.person_number;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME', 'IGF_SL_REL_DISB.PER_IN_FA ' || SQLERRM);
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END per_in_fa;


----------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE log_parameters(
   p_alt_code VARCHAR2, p_fund_id NUMBER, p_base_id NUMBER, p_loan_id NUMBER,
      p_trans_type VARCHAR2, p_per_grp_id NUMBER, p_fund_code VARCHAR2
   )

------------------------------------------------------------------------------------------------------------------------------------
--
-- Purpose:  This process log the parameters in the log file
--
------------------------------------------------------------------------------------------------------------------------------------
   IS

-- Get the values from the lookups
      CURSOR cur_get_fund_code(p_fund_id NUMBER)
      IS
         SELECT fund_code
           FROM igf_aw_fund_mast_all
          WHERE fund_id = p_fund_id;

      get_fund_code_rec             cur_get_fund_code%ROWTYPE;

      CURSOR cur_get_fed_fund_code(p_fund_id NUMBER)
      IS
         SELECT fcat.fed_fund_code
           FROM igf_aw_fund_mast_all fmast,igf_aw_fund_cat_all fcat
          WHERE fmast.fund_id = p_fund_id
            AND fmast.fund_code = fcat.fund_code;

      get_fed_fund_code             cur_get_fed_fund_code%ROWTYPE;

      CURSOR cur_get_grp_name(p_per_grp_id NUMBER)
      IS
         SELECT group_cd
           FROM igs_pe_persid_group_all
          WHERE GROUP_ID = p_per_grp_id;

      get_grp_name_rec              cur_get_grp_name%ROWTYPE;

      CURSOR cur_get_trans_type(p_trans_type VARCHAR2,p_lookup_type VARCHAR2)
      IS
         SELECT meaning
           FROM igf_lookups_view
          WHERE lookup_type = p_lookup_type
                AND lookup_code = p_trans_type;

      get_trans_type_rec            cur_get_trans_type%ROWTYPE;

      CURSOR c_get_parameters
      IS
         SELECT meaning, lookup_code
           FROM igf_lookups_view
          WHERE lookup_type = 'IGF_GE_PARAMETERS'
                AND lookup_code IN (
                                    'AWARD_YEAR',
                                    'FUND_CODE',
                                    'PERSON_NUMBER',
                                    'LOAN_ID',
                                    'TRANS_TYPE',
                                    'PERSON_ID_GROUP'
                                   );

      parameter_rec                 c_get_parameters%ROWTYPE;
      l_award_year                  VARCHAR2(80);
      l_fund_code                   VARCHAR2(80);
      l_person_number               VARCHAR2(80);
      l_loan_id                     VARCHAR2(80);
      l_trans_type                  VARCHAR2(80);
      l_person_id_group             VARCHAR2(80);
   BEGIN
      OPEN c_get_parameters;

      LOOP
         FETCH c_get_parameters INTO parameter_rec;
         EXIT WHEN c_get_parameters%NOTFOUND;

         IF parameter_rec.lookup_code = 'AWARD_YEAR'
         THEN
            l_award_year := TRIM(parameter_rec.meaning);
         ELSIF parameter_rec.lookup_code = 'FUND_CODE'
         THEN
            l_fund_code := TRIM(parameter_rec.meaning);
         ELSIF parameter_rec.lookup_code = 'PERSON_NUMBER'
         THEN
            l_person_number := TRIM(parameter_rec.meaning);
         ELSIF parameter_rec.lookup_code = 'LOAN_ID'
         THEN
            l_loan_id := TRIM(parameter_rec.meaning);
         ELSIF parameter_rec.lookup_code = 'TRANS_TYPE'
         THEN
            l_trans_type := TRIM(parameter_rec.meaning);
         ELSIF parameter_rec.lookup_code = 'PERSON_ID_GROUP'
         THEN
            l_person_id_group := TRIM(parameter_rec.meaning);
         END IF;
      END LOOP;

      CLOSE c_get_parameters;

      IF p_fund_id IS NOT NULL
      THEN
         OPEN cur_get_fund_code(p_fund_id);
         FETCH cur_get_fund_code INTO get_fund_code_rec;
         CLOSE cur_get_fund_code;
      END IF;

      IF p_per_grp_id IS NOT NULL
      THEN
         OPEN cur_get_grp_name(p_per_grp_id);
         FETCH cur_get_grp_name INTO get_grp_name_rec;
         CLOSE cur_get_grp_name;
      END IF;

      IF p_trans_type IS NOT NULL
      THEN
         OPEN cur_get_fed_fund_code(p_fund_id);
         FETCH cur_get_fed_fund_code INTO get_fed_fund_code;
         CLOSE cur_get_fed_fund_code;

         IF get_fed_fund_code.fed_fund_code IN ('FLP','FLS','FLU','ALT') THEN
           OPEN cur_get_trans_type(p_trans_type,'IGF_DB_TRANS_TYPE');
           FETCH cur_get_trans_type INTO get_trans_type_rec;
           CLOSE cur_get_trans_type;
         ELSIF get_fed_fund_code.fed_fund_code IN ('DLP','DLS','DLU','PELL') THEN
           OPEN cur_get_trans_type(p_trans_type,'IGF_GR_TRANS_TYPE');
           FETCH cur_get_trans_type INTO get_trans_type_rec;
           CLOSE cur_get_trans_type;
         END IF;
      END IF;

      fnd_file.new_line(fnd_file.log, 1);
      fnd_file.put_line(
         fnd_file.log, igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PARAMETER_PASS')
      );
      fnd_file.new_line(fnd_file.log, 1);
      fnd_file.put_line(
         fnd_file.log, RPAD(l_award_year, 40) || ' : ' || p_alt_code
      );
      fnd_file.put_line(
         fnd_file.log, RPAD(l_fund_code, 40) || ' : '
                       || get_fund_code_rec.fund_code
      );
      fnd_file.put_line(
         fnd_file.log, RPAD(l_person_number, 40) || ' : '
                       || igf_gr_gen.get_per_num(p_base_id)
      );
      fnd_file.put_line(fnd_file.log, RPAD(l_loan_id, 40) || ' : ' || p_loan_id);

      fnd_file.put_line(
         fnd_file.log, RPAD(l_trans_type, 40) || ' : '
                       || get_trans_type_rec.meaning
      );

      fnd_file.put_line(
         fnd_file.log, RPAD(l_person_id_group, 40) || ' : '
                       || get_grp_name_rec.group_cd
      );
      fnd_file.new_line(fnd_file.log, 1);
      fnd_file.put_line(
         fnd_file.log,
         '--------------------------------------------------------'
      );
      fnd_file.new_line(fnd_file.log, 1);
   EXCEPTION
      WHEN OTHERS
      THEN
         IF fnd_log.level_exception >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_rel_dis.log_parameters.exception','Exception:' || SQLERRM);
         END IF;

         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME', 'IGF_SL_REL_DISB.LOG_PARAMETERS');
         igs_ge_msg_stack.ADD;
   END log_parameters;

   FUNCTION chk_fund_meth_dl(
   p_ci_cal_type igs_ca_inst_all.cal_type%TYPE,
      p_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE,
      p_award_id igf_aw_award_all.award_id%TYPE,
      p_disb_num igf_aw_awd_disb_all.disb_num%TYPE
   )
      RETURN BOOLEAN
   AS
      /*-------------------------------------------------------------------------------------------------------
      ||  Created By : pssahni
      ||  Created On : 3-10-2004
      ||  Purpose : Returns true only for a valid combination of Funding method and number of days
                    Return NULL if the funding method is not valid
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      --------------------------------------------------------------------------------------------------------*/

-- Get the funding method for direct loan
      CURSOR cur_get_fund_meth(
      p_ci_cal_type igs_ca_inst_all.cal_type%TYPE,
         p_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE
      )
      IS
         SELECT funding_method
           FROM igf_sl_dl_setup_all
          WHERE p_ci_cal_type = ci_cal_type
                AND p_ci_sequence_number = ci_sequence_number;

      get_fund_meth_rec             cur_get_fund_meth%ROWTYPE;


-- Get the disbursment date
      CURSOR cur_get_disb_date(
      p_award_id igf_aw_awd_disb_all.award_id%TYPE,
         p_disb_num igf_aw_awd_disb_all.disb_num%TYPE
      )
      IS
         SELECT disb_date
           FROM igf_aw_awd_disb_all
          WHERE p_award_id = award_id AND p_disb_num = disb_num;

      get_disb_date_rec             cur_get_disb_date%ROWTYPE;
   BEGIN
      OPEN cur_get_fund_meth(p_ci_cal_type, p_ci_sequence_number);
      FETCH cur_get_fund_meth INTO get_fund_meth_rec;

      IF cur_get_fund_meth%NOTFOUND
      THEN
         CLOSE cur_get_fund_meth;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.chk_fund_meth_dl.debug','cur_get_fund_meth%NOTFOUND');
         END IF;

         RETURN NULL;
      ELSE
         CLOSE cur_get_fund_meth;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.chk_fund_meth_dl.debug','cur_get_fund_meth%FOUND');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.chk_fund_meth_dl.debug','funding method code = ' || get_fund_meth_rec.funding_method);
         END IF;

         OPEN cur_get_disb_date(p_award_id, p_disb_num);
         FETCH cur_get_disb_date INTO get_disb_date_rec;

         IF cur_get_disb_date%NOTFOUND
         THEN
            CLOSE cur_get_disb_date;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.chk_fund_meth_dl.debug','cur_get_disb_date%NOTFOUND');
            END IF;

            RETURN NULL;
         ELSE
            CLOSE cur_get_disb_date;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.chk_fund_meth_dl.debug','cur_get_disb_date%FOUND');
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.chk_fund_meth_dl.debug','disbursment date =' || get_disb_date_rec.disb_date);
            END IF;

            IF get_fund_meth_rec.funding_method IN ('A', 'P', 'CM1')
            THEN
               -- If Funding method is advance pay, pushed cash or CM1 then DRI can be set to true 7 days before disbursment date
               IF (TRUNC(SYSDATE) + 7) <= get_disb_date_rec.disb_date
               THEN
                  RETURN FALSE;
               ELSE
                  RETURN TRUE;
               END IF;
            ELSIF get_fund_meth_rec.funding_method IN ('R', 'CM2')
            THEN
               -- If funding method is CM2 or reimbursment then DRI cant be set true
               IF TRUNC(SYSDATE) <= get_disb_date_rec.disb_date
               THEN
                  RETURN FALSE;
               ELSE
                  RETURN TRUE;
               END IF;
            ELSE
               -- Funding method specified is not correct
               RETURN NULL;
            END IF;
         END IF;
      END IF;
   END chk_fund_meth_dl;

   FUNCTION chk_fund_meth_pell(
   p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
      p_ci_cal_type igs_ca_inst_all.cal_type%TYPE,
      p_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE,
      p_award_id igf_aw_award_all.award_id%TYPE,
      p_disb_num igf_aw_awd_disb_all.disb_num%TYPE,
      cp_return_status IN OUT NOCOPY VARCHAR2,
      cp_message IN OUT NOCOPY VARCHAR2
   )
      RETURN BOOLEAN
   AS
      /*-------------------------------------------------------------------------------------------------------
      ||  Created By : pssahni
      ||  Created On : 3-10-2004
      ||  Purpose : Returns true only for a valid combination of Funding method and number of days
                    Return NULL if the funding method is not valid
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      --------------------------------------------------------------------------------------------------------*/

-- Get the funding method for pell grant
      CURSOR cur_get_fund_meth(
      p_pell_seq_id igf_gr_pell_setup_all.pell_seq_id%TYPE
      )
      IS
         SELECT funding_method
           FROM igf_gr_pell_setup_all
          WHERE p_pell_seq_id = pell_seq_id;

      get_fund_meth_rec             cur_get_fund_meth%ROWTYPE;


-- Get the disbursment date
      CURSOR cur_get_disb_date(
      p_award_id igf_aw_awd_disb_all.award_id%TYPE,
         p_disb_num igf_aw_awd_disb_all.disb_num%TYPE
      )
      IS
         SELECT disb_date
           FROM igf_aw_awd_disb_all
          WHERE p_award_id = award_id AND p_disb_num = disb_num;

      get_disb_date_rec             cur_get_disb_date%ROWTYPE;
      l_pell_setup_rec              igf_gr_pell_setup_all%ROWTYPE;
      l_program_cd                  igs_en_stdnt_ps_att_all.course_cd%TYPE;
      l_program_version             igs_en_stdnt_ps_att_all.version_number%TYPE;
      l_message                     fnd_new_messages.message_text%TYPE;
      l_return_status               VARCHAR2(30);
   BEGIN
      -- Get the students key program details
      -- Based on these details the Pell Setup record is arrived at
      igf_ap_gen_001.get_key_program(
         cp_base_id => p_base_id, cp_course_cd => l_program_cd,
         cp_version_number => l_program_version
      );

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.chk_fund_meth_pell.debug','Key Program > Course cd>' || l_program_cd || ' Version >'|| TO_CHAR(l_program_version));
      END IF;

      -- Get the Pell Setup
      igf_gr_pell_calc.get_pell_setup(
         cp_base_id         => p_base_id,
         cp_course_cd       => l_program_cd,
         cp_version_number  => l_program_version,
         cp_cal_type        => p_ci_cal_type,
         cp_sequence_number => p_ci_sequence_number,
         cp_pell_setup_rec  => l_pell_setup_rec,
         cp_message         => l_message,
         cp_return_status   => l_return_status
      );

      IF l_return_status = 'E'
      THEN
         cp_message := l_message;
         cp_return_status := 'E';
         RETURN NULL;
      END IF;

      OPEN cur_get_fund_meth(l_pell_setup_rec.pell_seq_id);
      FETCH cur_get_fund_meth INTO get_fund_meth_rec;

      IF cur_get_fund_meth%NOTFOUND
      THEN
         CLOSE cur_get_fund_meth;
         RETURN NULL;
      ELSE
         CLOSE cur_get_fund_meth;
         OPEN cur_get_disb_date(p_award_id, p_disb_num);
         FETCH cur_get_disb_date INTO get_disb_date_rec;

         IF cur_get_disb_date%NOTFOUND
         THEN
            CLOSE cur_get_disb_date;
            RETURN NULL;
         ELSE
            CLOSE cur_get_disb_date;

            IF get_fund_meth_rec.funding_method = 'A'
            THEN
               -- If Funding method is advance pay then DRI can be set to true 30 days before disbursment date
               IF (TRUNC(SYSDATE) + 30) <= get_disb_date_rec.disb_date
               THEN
                  RETURN FALSE;
               ELSE
                  RETURN TRUE;
               END IF;
            ELSIF get_fund_meth_rec.funding_method IN ('P', 'CM1', 'J')
            THEN
               -- If funding method is Pushed cash or CM1 or JIT then DRI cant be set true 7 days before disbursment date
               IF (TRUNC(SYSDATE) + 7) <= get_disb_date_rec.disb_date
               THEN
                  RETURN FALSE;
               ELSE
                  RETURN TRUE;
               END IF;
            ELSIF get_fund_meth_rec.funding_method IN ('R', 'CM2')
            THEN
               -- If funding method is CM2 or reimbursment then DRI cant be set true
               IF TRUNC(SYSDATE) <= get_disb_date_rec.disb_date
               THEN
                  RETURN FALSE;
               ELSE
                  RETURN TRUE;
               END IF;
            ELSE
               -- Funding method specified is not correct
               RETURN NULL;
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token(
            'NAME', 'IGF_SL__REL_DISB.CHK_FUND_METHOD_PELL ' || SQLERRM
         );
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END chk_fund_meth_pell;

   FUNCTION chk_credit_status(p_award_id igf_aw_award_all.award_id%TYPE)
      RETURN BOOLEAN
   AS
      /*------------------------------------------------------------------------------------------------
      ||  Created By : pssahni
      ||  Created On : 04-Oct-2004
      ||  Purpose : To check the credit status of Direct Plus loans. Returns true if the DRI can be set to true
                    otherwise false
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
     -------------------------------------------------------------------------------------------------- */

      CURSOR cur_get_crdt_status(p_award_id igf_aw_award_all.award_id%TYPE)
      IS
         SELECT lor.crdt_decision_status status, lor.credit_override override
           FROM igf_sl_lor_all lor, igf_sl_loans_all loan
          WHERE loan.loan_id = lor.loan_id AND loan.award_id = p_award_id;

      get_crdt_status_rec           cur_get_crdt_status%ROWTYPE;
   BEGIN
      OPEN cur_get_crdt_status(p_award_id);
      FETCH cur_get_crdt_status INTO get_crdt_status_rec;

      IF cur_get_crdt_status%NOTFOUND
      THEN
         CLOSE cur_get_crdt_status;
         RETURN TRUE;
      ELSE
         CLOSE cur_get_crdt_status;

         IF NVL(get_crdt_status_rec.status, '*') = 'A'
            OR NVL(get_crdt_status_rec.override, '*') = 'C'
            OR NVL(get_crdt_status_rec.override, '*') = 'E'
         THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token(
            'NAME', 'IGF_SL_REL_DISB.CHK_CREDIT_STATUS ' || SQLERRM
         );
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END chk_credit_status;

   FUNCTION chk_todo_result(
   p_message_name OUT NOCOPY VARCHAR2,
      p_fund_id IN igf_aw_fund_mast_all.fund_id%TYPE,
      p_base_id IN igf_ap_fa_base_rec_all.base_id%TYPE
   )
      RETURN BOOLEAN
   AS
      /*
      ||  Created By : sjadhav
      ||  Created On : 07-Jan-2002
      ||  Purpose    : This routine checks for app process statuses.
      ||
      ||  Known limitations, enhancements or remarks :
      ||  Change History : (reverse chronological order - newest change first)
      ||  Who           When            What
      ||  brajendr      18-Oct-2002     Bug : 2591643
      ||                                Modified the Code for FA104- To Do Enhancements
      */



      CURSOR c_student_details(
      cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
      )
      IS
         SELECT manual_disb_hold, fa_process_status
           FROM igf_ap_fa_base_rec
          WHERE base_id = cp_base_id;

      CURSOR c_fund_details(cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
      IS
         SELECT ver_app_stat_override
           FROM igf_aw_fund_mast
          WHERE fund_id = cp_fund_id;

      CURSOR c_chk_verif_status(
      cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
      )
      IS
         SELECT fed_verif_status
           FROM igf_ap_fa_base_rec fab
          WHERE fab.base_id = p_base_id
                AND fab.fed_verif_status IN (
                                             'ACCURATE',
                                             'CALCULATED',
                                             'NOTVERIFIED',
                                             'NOTSELECTED',
                                             'REPROCESSED',
                                             'TOLERANCE',
                                             'WAIVED'
                                            );

    CURSOR c_fnd_todo(
                      cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                      cp_fund_id igf_aw_fund_mast_all.fund_id%TYPE,
                      cp_status  igf_ap_td_item_inst_all.status%TYPE,
                      cp_inactive igf_ap_td_item_inst_all.inactive_flag%TYPE
                     ) IS
      SELECT 'x'
        FROM igf_aw_fund_mast_all fmast,
             igf_aw_fund_td_map_all fndtd,
             igf_ap_td_item_inst_all tdinst,
             igf_ap_td_item_mst_all tdmst
       WHERE fmast.fund_id = cp_fund_id
         AND tdinst.base_id = cp_base_id
         AND fndtd.fund_id = fmast.fund_id
         AND fndtd.item_sequence_number = tdinst.item_sequence_number
         AND fndtd.item_sequence_number = tdmst.todo_number
         AND NVL(tdmst.career_item,'N') = 'N'
         AND tdinst.status <> cp_status
         AND tdinst.inactive_flag <> cp_inactive
      UNION
      SELECT 'x'
        FROM igf_aw_fund_mast_all fmast,
             igf_aw_fund_td_map_all fndtd,
             igf_ap_td_item_inst_v tdinst,
             igf_ap_td_item_mst_all tdmst,
             igf_ap_fa_base_rec_all fa
       WHERE fmast.fund_id = cp_fund_id
         AND fa.base_id = cp_base_id
         AND fa.person_id = tdinst.person_id
         AND fndtd.fund_id = fmast.fund_id
         AND fndtd.item_sequence_number = tdinst.item_sequence_number
         AND fndtd.item_sequence_number = tdmst.todo_number
         AND NVL(tdmst.career_item,'N') = 'Y'
         AND tdinst.status <> cp_status
         AND tdinst.inactive_flag <> cp_inactive;

      lc_student_details_rec        c_student_details%ROWTYPE;
      lc_fund_details_rec           c_fund_details%ROWTYPE;
      lc_chk_verif_status_rec       c_chk_verif_status%ROWTYPE;
      l_fnd_todo                    c_fnd_todo%ROWTYPE;
      lb_result                     BOOLEAN;
   BEGIN
      lb_result := TRUE;
      OPEN c_fund_details(p_fund_id);
      FETCH c_fund_details INTO lc_fund_details_rec;
      CLOSE c_fund_details;

      lc_chk_verif_status_rec := NULL;
      OPEN c_chk_verif_status( p_base_id);
      FETCH c_chk_verif_status INTO lc_chk_verif_status_rec;
      CLOSE c_chk_verif_status;

      -- Return TRUE if Fund has "Verification and Applicaitons status Override" is present, else check for other status
      IF NVL(lc_fund_details_rec.ver_app_stat_override, 'N') = 'Y' THEN
        /*
          bug 4747156 - check for incomplete to do items attached to the fund
          these have to be complete.
        */
        OPEN c_fnd_todo(p_base_id,p_fund_id,'COM','Y');
        FETCH c_fnd_todo INTO l_fnd_todo;
        IF c_fnd_todo%FOUND THEN
          CLOSE c_fnd_todo;
          p_message_name := 'IGF_DB_FAIL_TODO';
          lb_result      := FALSE;
        ELSE
          CLOSE c_fnd_todo;
          p_message_name := NULL;
          lb_result      := TRUE;
        END IF;
      ELSE
         OPEN c_student_details(p_base_id);
         FETCH c_student_details INTO lc_student_details_rec;
         CLOSE c_student_details;

         --
         -- Return FALSE if "Disbursement Hold for manual Re-Award" is present
         --
         IF NVL(lc_student_details_rec.manual_disb_hold, 'N') = 'Y'
         THEN
            p_message_name := 'IGF_DB_FAIL_DISB_HOLD_RE_AWD';
            lb_result := FALSE;
         --
         -- Return FALSE if students Application Process is not completed i.e. stuatus is not "Applicaiton Complete"
         --
         ELSIF lc_student_details_rec.fa_process_status <> 'COMPLETE'
         THEN
            p_message_name := 'IGF_DB_FAIL_APPL_NOT_CMPLT';
            lb_result := FALSE;
         --
         -- Return TRUE if students has "Verification Status" as "Termial" status.
         --
         ELSIF lc_chk_verif_status_rec.fed_verif_status IS NULL THEN
           p_message_name := 'IGF_DB_FAIL_VER_NOT_TERMINAL';
           lb_result := FALSE;
         ELSE
           /*
             bug 4747156 - check for incomplete to do items attached to the fund
             these have to be complete.
           */
           OPEN c_fnd_todo(p_base_id,p_fund_id,'COM','Y');
           FETCH c_fnd_todo INTO l_fnd_todo;
           IF c_fnd_todo%FOUND THEN
             CLOSE c_fnd_todo;
             p_message_name := 'IGF_DB_FAIL_TODO';
             lb_result      := FALSE;
           ELSE
             CLOSE c_fnd_todo;
           END IF;
         END IF;
      END IF;

      RETURN lb_result;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token(
            'NAME', 'IGF_SL_REL_DISB.CHK_TODO_RESULT ' || SQLERRM
         );
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END chk_todo_result;

   PROCEDURE insert_pays_prg_uts(
   p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
      p_acad_cal_type igs_ca_inst_all.cal_type%TYPE,
      p_acad_ci_seq_num igs_ca_inst_all.sequence_number%TYPE
   )
   AS

--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This routine inserts Pays Only Programs, Units into
--                              temporary table igf_db_pays_prg_t
--
--------------------------------------------------------------------------------------------

-- Get all the teaching periods for the academic calendar instance
      CURSOR cur_get_acad_tp(
      p_acad_ci_cal_type igs_ca_inst_all.cal_type%TYPE,
         p_acad_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE
      )
      IS
         SELECT sub_cal_type tp_cal_type,
                sub_ci_sequence_number tp_sequence_number
           FROM igs_ca_inst_rel cr_1, igs_ca_type ct_1, igs_ca_type ct_2
          WHERE ct_1.cal_type = cr_1.sup_cal_type
                AND ct_1.s_cal_cat = 'ACADEMIC'
                AND ct_2.cal_type = cr_1.sub_cal_type
                AND ct_2.s_cal_cat = 'TEACHING'
                AND cr_1.sup_cal_type = p_acad_ci_cal_type
                AND cr_1.sup_ci_sequence_number = p_acad_ci_sequence_number;

      get_acad_tp_rec               cur_get_acad_tp%ROWTYPE;


-- Get all the programs,unit attempts in which student has 'enrolled'

      CURSOR cur_get_att(
      p_person_id igf_ap_fa_base_rec_all.person_id%TYPE,
         p_acad_cal_type igs_ca_inst_all.cal_type%TYPE,
         p_tp_cal_type igs_ca_inst_all.cal_type%TYPE,
         p_tp_sequence_number igs_ca_inst_all.sequence_number%TYPE
      )
      IS
         SELECT pg.course_cd prg_course_cd, pg.version_number prg_ver_num,
                su.unit_cd unit_course_cd, su.version_number unit_ver_num
           FROM igs_en_su_attempt su, igs_en_stdnt_ps_att pg
          WHERE su.person_id = p_person_id AND pg.person_id = su.person_id
                AND su.unit_attempt_status IN
                                         ('COMPLETED', 'ENROLLED', 'DUPLICATE')
                AND su.cal_type = p_tp_cal_type
                AND su.ci_sequence_number = p_tp_sequence_number
                AND pg.cal_type = p_acad_cal_type
                AND pg.course_cd(+) = su.course_cd;

      get_att_rec                   cur_get_att%ROWTYPE;
      l_acad_cal_type               igs_ca_inst_all.cal_type%TYPE;
      l_acad_seq_num                igs_ca_inst_all.sequence_number%TYPE;
      l_acad_alt_code               igs_ca_inst_all.alternate_code%TYPE;
      dbpays_rec                    igf_db_pays_prg_t%ROWTYPE;
      l_rowid                       ROWID;
   BEGIN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.insert_pays_prg_uts.debug','p_acad_cal_type:' || p_acad_cal_type);
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.insert_pays_prg_uts.debug','p_acad_ci_seq_num:' || p_acad_ci_seq_num);
      END IF;

      FOR get_acad_tp_rec IN cur_get_acad_tp(
                                p_acad_cal_type, p_acad_ci_seq_num
                             )
      LOOP
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.insert_pays_prg_uts.debug','igf_gr_gen.get_person_id(' || p_base_id || '):'|| igf_gr_gen.get_person_id(p_base_id));
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.insert_pays_prg_uts.debug','get_acad_tp_rec.tp_cal_type:' || get_acad_tp_rec.tp_cal_type);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.insert_pays_prg_uts.debug','get_acad_tp_rec.tp_sequence_number:'|| get_acad_tp_rec.tp_sequence_number);
         END IF;

         FOR get_att_rec IN cur_get_att(
                               igf_gr_gen.get_person_id(p_base_id),
                               p_acad_cal_type, get_acad_tp_rec.tp_cal_type,
                               get_acad_tp_rec.tp_sequence_number
                            )
         LOOP
            dbpays_rec.base_id := p_base_id;
            dbpays_rec.program_cd := get_att_rec.prg_course_cd;
            dbpays_rec.prg_ver_num := get_att_rec.prg_ver_num;
            dbpays_rec.unit_cd := get_att_rec.unit_course_cd;
            dbpays_rec.unit_ver_num := get_att_rec.unit_ver_num;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.insert_pays_prg_uts.debug','dbpays_rec.program_cd:' || dbpays_rec.program_cd);
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.insert_pays_prg_uts.debug','dbpays_rec.prg_ver_num:' || dbpays_rec.prg_ver_num);
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.insert_pays_prg_uts.debug','dbpays_rec.unit_cd:' || dbpays_rec.unit_cd);
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.insert_pays_prg_uts.debug','dbpays_rec.unit_ver_num:' || dbpays_rec.unit_ver_num);
            END IF;

            l_rowid := NULL;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.insert_pays_prg_uts.debug','inserting to igf_db_pays_prg_t');
            END IF;

            igf_db_pays_prg_t_pkg.insert_row(
               x_rowid => l_rowid, x_dbpays_id => dbpays_rec.dbpays_id,
               x_base_id => dbpays_rec.base_id,
               x_program_cd => dbpays_rec.program_cd,
               x_prg_ver_num => dbpays_rec.prg_ver_num,
               x_unit_cd => dbpays_rec.unit_cd,
               x_unit_ver_num => dbpays_rec.unit_ver_num, x_mode => 'R'
            );
         END LOOP;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token(
            'NAME', 'IGF_SL_REL_DISB.INSERT_PAYS_PRG_UTS ' || SQLERRM
         );
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END insert_pays_prg_uts;

   FUNCTION chk_pays_prg(
   p_fund_id igf_aw_fund_mast_all.fund_id%TYPE,
      p_base_id igf_ap_fa_base_rec_all.base_id%TYPE
   )
      RETURN BOOLEAN
   AS

--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This routine Pays Only Program Check
--
--------------------------------------------------------------------------------------------

--
-- This cursor will retreive records which are
-- common to temp table ( igf_db_pays_prg_t ) and fund setup for pays only program
-- If there are no records, the check is failed else passed
--

      CURSOR cur_std_pays(
      p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
         p_fund_id igf_aw_fund_mast_all.fund_id%TYPE
      )
      IS
         SELECT program_cd, prg_ver_num
           FROM igf_db_pays_prg_t
          WHERE base_id = p_base_id
         INTERSECT
         SELECT course_cd, version_number
           FROM igf_aw_fund_prg_v fprg
          WHERE fprg.fund_id = p_fund_id;

      std_pays_rec                  cur_std_pays%ROWTYPE;


--
-- This cursor will retreive records from fund setup for pays only program
-- If there are no records, then the pays only prog check is passed
--
      CURSOR cur_fund_pprg(p_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
      IS
         SELECT course_cd, version_number
           FROM igf_aw_fund_prg_v fprg
          WHERE fprg.fund_id = p_fund_id;

      fund_pprg_rec                 cur_fund_pprg%ROWTYPE;
   BEGIN
      OPEN cur_fund_pprg(p_fund_id);
      FETCH cur_fund_pprg INTO fund_pprg_rec;

      IF cur_fund_pprg%NOTFOUND
      THEN
         CLOSE cur_fund_pprg;
         RETURN TRUE;
      ELSIF cur_fund_pprg%FOUND
      THEN
         CLOSE cur_fund_pprg;
         OPEN cur_std_pays(p_base_id, p_fund_id);
         FETCH cur_std_pays INTO std_pays_rec;

         IF cur_std_pays%FOUND
         THEN
            CLOSE cur_std_pays;
            RETURN TRUE;
         ELSIF cur_std_pays%NOTFOUND
         THEN
            CLOSE cur_std_pays;
            RETURN FALSE;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME', 'IGF_DB_DISB.CHK_PAYS_PRG ' || SQLERRM);
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END chk_pays_prg;

   FUNCTION chk_pays_uts(
   p_fund_id igf_aw_fund_mast_all.fund_id%TYPE,
      p_base_id igf_ap_fa_base_rec_all.base_id%TYPE
   )
      RETURN BOOLEAN
   AS

--------------------------------------------------------------------------------------------
--
--   Created By         :       sjadhav
--   Date Created By    :       Jan 07,2002
--   Purpose            :       This routine Pays Only Units Check
--                              previous run of eligibility checks
--
--------------------------------------------------------------------------------------------
--
-- This cursor will retreive records which are
-- common to temp table ( igf_db_pays_prg_t ) and fund setup for pays only units
-- If there are no records, the check is failed else passed
--

      CURSOR cur_std_pays(
      p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
         p_fund_id igf_aw_fund_mast_all.fund_id%TYPE
      )
      IS
         SELECT unit_cd, unit_ver_num
           FROM igf_db_pays_prg_t
          WHERE base_id = p_base_id
         INTERSECT
         SELECT unit_cd, version_number
           FROM igf_aw_fund_unit_v funit
          WHERE funit.fund_id = p_fund_id;

      std_pays_rec                  cur_std_pays%ROWTYPE;


--
-- This cursor will retreive records from fund setup for pays only program
-- If there are no records, then the pays only prog check is passed
--
      CURSOR cur_fund_unit(p_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
      IS
         SELECT unit_cd, version_number
           FROM igf_aw_fund_unit_v funit
          WHERE funit.fund_id = p_fund_id;

      fund_unit_rec                 cur_fund_unit%ROWTYPE;
   BEGIN
      OPEN cur_fund_unit(p_fund_id);
      FETCH cur_fund_unit INTO fund_unit_rec;

      IF cur_fund_unit%NOTFOUND
      THEN
         CLOSE cur_fund_unit;
         RETURN TRUE;
      ELSIF cur_fund_unit%FOUND
      THEN
         CLOSE cur_fund_unit;
         OPEN cur_std_pays(p_base_id, p_fund_id);
         FETCH cur_std_pays INTO std_pays_rec;

         IF cur_std_pays%FOUND
         THEN
            CLOSE cur_std_pays;
            RETURN TRUE;
         ELSIF cur_std_pays%NOTFOUND
         THEN
            CLOSE cur_std_pays;
            RETURN FALSE;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME', 'IGF_DB_DISB.CHK_PAYS_UTS ' || SQLERRM);
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END chk_pays_uts;

   FUNCTION chk_fclass_result(
   p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
      p_fund_id igf_aw_fund_mast_all.fund_id%TYPE,
      p_ld_cal_type igs_ca_inst_all.cal_type%TYPE,
      p_ld_sequence_number igs_ca_inst_all.sequence_number%TYPE
   )
      RETURN BOOLEAN
   AS

--------------------------------------------------------------------------------------------
--
--   Created By         :       pssahni
--   Date Created By    :       Oct 4,2004
--   Purpose            :       This Process evaluates student for fee class
--
--------------------------------------------------------------------------------------------


      p_fee_cal_type                igs_ca_inst_all.cal_type%TYPE;
      p_fee_ci_sequence_number      igs_ca_inst_all.sequence_number%TYPE;
      p_message_name                fnd_new_messages.message_name%TYPE;


--
-- This cursor will retreive records from fund setup for pays only Fee Class
-- If there are no records, then the pays only fee class check is passed
--
      CURSOR cur_fund_fcls(p_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
      IS
         SELECT fee_class
           FROM igf_aw_fund_feeclas
          WHERE fund_id = p_fund_id;

      fund_fcls_rec                 cur_fund_fcls%ROWTYPE;


--
-- This cursor will return common fee classes from
-- fund setup and persons charges
--

      CURSOR cur_fee_cls(
      p_fund_id igf_aw_fund_mast_all.fund_id%TYPE,
         p_fee_cal_type igs_ca_inst_all.cal_type%TYPE,
         p_fee_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE,
         p_person_id igf_ap_fa_base_rec_all.person_id%TYPE
      )
      IS
         SELECT fee_class
           FROM igf_aw_fund_feeclas
          WHERE fund_id = p_fund_id
         INTERSECT
         SELECT fee_class
           FROM igs_fi_inv_igf_v
          WHERE fee_cal_type = p_fee_cal_type
                AND fee_ci_sequence_number = p_fee_ci_sequence_number
                AND person_id = p_person_id;

      fee_cls_rec                   cur_fee_cls%ROWTYPE;
      lv_bool                       BOOLEAN;
   BEGIN
      OPEN cur_fund_fcls(p_fund_id);
      FETCH cur_fund_fcls INTO fund_fcls_rec;

      IF cur_fund_fcls%NOTFOUND
      THEN
         CLOSE cur_fund_fcls;
         RETURN TRUE;
      ELSIF cur_fund_fcls%FOUND
      THEN
         CLOSE cur_fund_fcls;
         lv_bool := igs_fi_gen_001.finp_get_lfci_reln(
                       p_ld_cal_type, p_ld_sequence_number, 'LOAD',
                       p_fee_cal_type, p_fee_ci_sequence_number,
                       p_message_name
                    );

         IF p_message_name IS NULL
         THEN
            OPEN cur_fee_cls(
               p_fund_id, p_fee_cal_type, p_fee_ci_sequence_number,
               igf_gr_gen.get_person_id(p_base_id)
            );
            FETCH cur_fee_cls INTO fee_cls_rec;

            IF cur_fee_cls%FOUND
            THEN
               CLOSE cur_fee_cls;
               RETURN TRUE;
            ELSIF cur_fee_cls%NOTFOUND
            THEN
               CLOSE cur_fee_cls;
               RETURN FALSE;
            END IF;
         ELSE
            --
            -- The message if not null means the relation does not exist
            --
            RETURN FALSE;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token(
            'NAME', 'IGF_DB_DISB.CHK_FCLASS_RESULT ' || SQLERRM
         );
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END chk_fclass_result;

   PROCEDURE delete_pays
   AS

--------------------------------------------------------------------------------------------
--
--   Created By         :       pssahni
--   Date Created By    :       04-Oct-2004
--   Purpose            :       This routine truncates pays only data used in
--                              previous run of eligibility checks
--
--------------------------------------------------------------------------------------------
      CURSOR cur_pays_prg
      IS
         SELECT db.ROWID row_id, db.*
           FROM igf_db_pays_prg_t db;

      pays_prg_rec                  cur_pays_prg%ROWTYPE;
   BEGIN
      OPEN cur_pays_prg;

      LOOP
         FETCH cur_pays_prg INTO pays_prg_rec;
         EXIT WHEN cur_pays_prg%NOTFOUND;
         igf_db_pays_prg_t_pkg.delete_row(pays_prg_rec.row_id);

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.delete_pays.debug','deleted from igf_db_pays_prg_t');
         END IF;
      END LOOP;

      CLOSE cur_pays_prg;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token(
            'NAME', 'IGF_SL_REL_DISB.DELETE_PAYS ' || SQLERRM
         );
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END delete_pays;

   FUNCTION get_loan_num(p_loan_id igf_sl_loans_all.loan_id%TYPE)
      RETURN VARCHAR2
   AS
      /*
      ||  Created By : pssahni
      ||  Created On :
      ||  Purpose : To get loan number from a loan id
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      */

-- Get loan number
      CURSOR cur_get_loan_num(p_loan_id igf_sl_loans_all.loan_id%TYPE)
      IS
         SELECT loan_number
           FROM igf_sl_loans
          WHERE p_loan_id = loan_id;

      get_loan_num_rec              cur_get_loan_num%ROWTYPE;
   BEGIN
      OPEN cur_get_loan_num(p_loan_id);
      FETCH cur_get_loan_num INTO get_loan_num_rec;

      IF cur_get_loan_num%NOTFOUND
      THEN
         CLOSE cur_get_loan_num;
         RETURN NULL;
      ELSE --cur_fund_fcls%FOUND THEN
         CLOSE cur_get_loan_num;
         RETURN get_loan_num_rec.loan_number;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token(
            'NAME', 'IGF_SL_REL_DISB.DELETE_PAYS ' || SQLERRM
         );
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END get_loan_num;

   FUNCTION get_cut_off_dt(
   p_ld_seq_num igs_ca_inst_all.sequence_number%TYPE,
      p_disb_date igf_aw_awd_disb_all.disb_date%TYPE
   )
      RETURN DATE
   IS

-----------------------------------------------------------------------------------------
-- sjadhav,May.30.2002.
-- Bug 2387496
--
-- This function will return the cut off date
-- to be paased to enrolment api for getting
-- poin-in-time credit points
-----------------------------------------------------------------------------------------

      CURSOR cur_get_eff_date(
      p_ld_seq_num igs_ca_inst_all.sequence_number%TYPE
      )
      IS
         SELECT start_dt, end_dt
           FROM igs_ca_inst_all
          WHERE p_ld_seq_num = sequence_number;

      get_eff_date_rec              cur_get_eff_date%ROWTYPE;
      ld_cut_off_dt                 igf_aw_awd_disb_all.disb_date%TYPE;
      ld_system_dt                  igf_aw_awd_disb_all.disb_date%TYPE;
      ld_start_dt                   igf_aw_awd_disb_all.disb_date%TYPE;
      ld_end_dt                     igf_aw_awd_disb_all.disb_date%TYPE;
   BEGIN
      ld_system_dt := TRUNC(SYSDATE);
      ld_cut_off_dt := ld_system_dt;
      OPEN cur_get_eff_date(p_ld_seq_num);
      FETCH cur_get_eff_date INTO get_eff_date_rec;
      CLOSE cur_get_eff_date;
      ld_start_dt := TRUNC(get_eff_date_rec.start_dt);
      ld_end_dt := TRUNC(get_eff_date_rec.end_dt);


-- 1.

      IF p_disb_date < ld_system_dt
      THEN
         IF  p_disb_date >= ld_start_dt AND p_disb_date <= ld_end_dt
         THEN
            ld_cut_off_dt := ld_system_dt;
         END IF;
      END IF;


-- 2.

      IF p_disb_date < ld_start_dt
      THEN
         IF  ld_system_dt > ld_start_dt AND ld_system_dt < ld_end_dt
         THEN
            ld_cut_off_dt := ld_system_dt;
         END IF;
      END IF;


-- 3.

      IF  p_disb_date < ld_system_dt AND ld_system_dt < ld_start_dt
      THEN
         ld_cut_off_dt := ld_start_dt;
      END IF;


-- 4.

      IF p_disb_date > ld_end_dt
      THEN
         ld_cut_off_dt := ld_end_dt;
      END IF;

      RETURN ld_cut_off_dt;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token(
            'NAME', 'IGF_DB_DISB.GET_CUT_OFF_DT ' || SQLERRM
         );
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END get_cut_off_dt;

   PROCEDURE set_dri_true(
   p_award_id igf_aw_awd_disb_all.award_id%TYPE,
      p_disb_num igf_aw_awd_disb_all.disb_num%TYPE,
      p_fund_id igf_aw_fund_mast_all.fund_id%TYPE, p_fund_type VARCHAR2
   )
   AS

--------------------------------------------------------------------------------------------
--
--   Created By         :       pssahni
--   Date Created By    :       Oct 7,2004
--   Purpose            :       This routine sets the Disbursment Release Indicator to true
--
--------------------------------------------------------------------------------------------


      CURSOR cur_get_adisb(
      p_award_id igf_aw_awd_disb_all.award_id%TYPE,
         p_disb_num igf_aw_awd_disb_all.disb_num%TYPE
      )
      IS
         SELECT        ROWID row_id, adisb.*
                  FROM igf_aw_awd_disb_all adisb
                 WHERE adisb.award_id = p_award_id
                       AND adisb.disb_num = p_disb_num
         FOR UPDATE OF elig_status NOWAIT;

      get_adisb_rec                 cur_get_adisb%ROWTYPE;
      lv_rowid                      ROWID;
      lv_called_from                VARCHAR2(30);
   BEGIN
      OPEN cur_get_adisb(p_award_id, p_disb_num);
      FETCH cur_get_adisb INTO get_adisb_rec;
      CLOSE cur_get_adisb;

-- Update DRI to true
      lv_called_from := NULL;

      IF p_fund_type IN ('P', 'D')
      THEN
         get_adisb_rec.hold_rel_ind := 'TRUE';
      ELSIF p_fund_type = 'F'
      THEN
         get_adisb_rec.hold_rel_ind := 'R';
         lv_called_from := 'IGFSL27B';
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.set_dri_true .debug','set Disbursment Release Indicator to True');
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_db_disb.create_actual.debug','updating igf_aw_awd_disb for award ' || get_adisb_rec.award_id);
      END IF;

      igf_aw_awd_disb_pkg.update_row(
                x_rowid => get_adisb_rec.row_id,
                x_award_id => get_adisb_rec.award_id,
                x_disb_num => get_adisb_rec.disb_num,
                x_tp_cal_type => get_adisb_rec.tp_cal_type,
                x_tp_sequence_number => get_adisb_rec.tp_sequence_number,
                x_disb_gross_amt => get_adisb_rec.disb_gross_amt,
                x_fee_1 => get_adisb_rec.fee_1,x_fee_2 => get_adisb_rec.fee_2,
                x_disb_net_amt => get_adisb_rec.disb_net_amt,
                x_disb_date => get_adisb_rec.disb_date,
                x_trans_type => get_adisb_rec.trans_type,
                x_elig_status => get_adisb_rec.elig_status,
                x_elig_status_date => get_adisb_rec.elig_status_date,
                x_affirm_flag => get_adisb_rec.affirm_flag,
                x_hold_rel_ind => get_adisb_rec.hold_rel_ind,
                x_manual_hold_ind => get_adisb_rec.manual_hold_ind,
                x_disb_status => get_adisb_rec.disb_status,
                x_disb_status_date => get_adisb_rec.disb_status_date,
                x_late_disb_ind => get_adisb_rec.late_disb_ind,
                x_fund_dist_mthd => get_adisb_rec.fund_dist_mthd,
                x_prev_reported_ind => get_adisb_rec.prev_reported_ind,
                x_fund_release_date => get_adisb_rec.fund_release_date,
                x_fund_status => get_adisb_rec.fund_status,
                x_fund_status_date => get_adisb_rec.fund_status_date,
                x_fee_paid_1 => get_adisb_rec.fee_paid_1,
                x_fee_paid_2 => get_adisb_rec.fee_paid_2,
                x_cheque_number => get_adisb_rec.cheque_number,
                x_ld_cal_type => get_adisb_rec.ld_cal_type,
                x_ld_sequence_number => get_adisb_rec.ld_sequence_number,
                x_disb_accepted_amt => get_adisb_rec.disb_accepted_amt,
                x_disb_paid_amt => get_adisb_rec.disb_paid_amt,
                x_rvsn_id => get_adisb_rec.rvsn_id,
                x_int_rebate_amt => get_adisb_rec.int_rebate_amt,
                x_force_disb => get_adisb_rec.force_disb,
                x_min_credit_pts => get_adisb_rec.min_credit_pts,
                x_disb_exp_dt => get_adisb_rec.disb_exp_dt,
                x_verf_enfr_dt => get_adisb_rec.verf_enfr_dt,
                x_fee_class => get_adisb_rec.fee_class,
                x_show_on_bill => get_adisb_rec.show_on_bill,
                x_attendance_type_code => get_adisb_rec.attendance_type_code,
                x_base_attendance_type_code => get_adisb_rec.base_attendance_type_code,
                x_mode => 'R',
                x_called_from => lv_called_from,
                x_payment_prd_st_date  => get_adisb_rec.payment_prd_st_date,
                x_change_type_code     => get_adisb_rec.change_type_code,
                x_fund_return_mthd_code => get_adisb_rec.fund_return_mthd_code,
                x_direct_to_borr_flag   => get_adisb_rec.direct_to_borr_flag
     );
   EXCEPTION
      WHEN app_exception.record_lock_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         fnd_message.CLEAR;
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME', 'IGF_DB_DISB.CREATE_ACTUAL ' || SQLERRM);
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.initialize;
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END set_dri_true;


--------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE process_student(
   p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
      p_result IN OUT NOCOPY VARCHAR2,
      p_fund_id igf_aw_fund_mast_all.fund_id%TYPE,
      p_award_id igf_aw_award_all.award_id%TYPE,
      p_loan_id igf_sl_loans_all.loan_id%TYPE,
      p_disb_num igf_aw_awd_disb_all.disb_num%TYPE, p_trans_type VARCHAR2
   )
   AS

--------------------------------------------------------------------------------------------
--   Purpose            :       This Process performs various validations required
--                              inorder to set the disbursment hold indicator to true
--The checks that are to be done for a fund in the award year context are:
--1.  To Do Item Validations
--2.  Pays Only Program
--3.  Pays Only Units
--4.  Eligibility check for getting loans (NSLDS_ELIGIBLE)
--5.  Eligibility check for getting PELL Grant (PELL_ELIGIBLE)
--Award Year Level checks are to be done only for the first disbursement record for the Fund

--Checks that should be done for an Award
--6.  Active Loan
--7.  System holds

--Checks for an Award should be done only once and the result should be stored

--The checks that are to be done at the term level

--10. Pays Only Fee Class
--11. Minimum Attendance type if specified


--Term Level checks should be done only once for the first disbursement record for a Term

--The cheks that are to be done at the disbursement level for disbursing a fund

--12. Cumulative Current Credit Points
--13. Fuding method check
--14. Credit Status Check (Applicable for PLUS-Direct Loans only)

--------------------------------------------------------------------------------------------

      skip_record                   EXCEPTION;


--Get all the awards and corresponding disbursements for the student for a given fund in case of Direct Loans
      CURSOR cur_awd_disb_dl(
      p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
         p_fund_id igf_aw_fund_mast_all.fund_id%TYPE,
         p_award_id igf_aw_award_all.award_id%TYPE,
         p_disb_num igf_aw_awd_disb_all.disb_num%TYPE,
         p_trans_type igf_aw_awd_disb_all.trans_type%TYPE
      )
      IS
         SELECT   adisb.*, awd.base_id, fmast.ci_cal_type,
                  fmast.ci_sequence_number, fmast.fund_id, fmast.fund_code,
                  cat.fed_fund_code
             FROM igf_aw_awd_disb_all adisb, igf_aw_fund_mast_all fmast,
                  igf_aw_award_all awd, igf_aw_fund_cat_all cat
            WHERE adisb.award_id = awd.award_id
                  AND fmast.fund_code = cat.fund_code
                  AND fmast.fund_id = awd.fund_id AND awd.base_id = p_base_id
                  AND awd.fund_id = p_fund_id
                  AND cat.fed_fund_code IN ('PELL', 'DLP', 'DLS', 'DLU')
                  AND adisb.award_id = NVL(p_award_id, adisb.award_id)
                  AND adisb.disb_num = NVL(p_disb_num, adisb.disb_num)
                  AND (
                        (adisb.trans_type = 'A') OR
                        (p_trans_type = 'P' AND adisb.trans_type = 'P')
                       )
                  AND (adisb.hold_rel_ind = 'FALSE' OR adisb.hold_rel_ind IS NULL)
         ORDER BY awd.fund_id, awd.award_id, adisb.disb_num;


--Get all the awards and corresponding disbursements for the student for a given fund
-- in case of FFELP Loans and if transaction type is specified
      CURSOR cur_awd_disb_fed(
      p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
         p_fund_id igf_aw_fund_mast_all.fund_id%TYPE,
         p_award_id igf_aw_award_all.award_id%TYPE,
         p_disb_num igf_aw_awd_disb_all.disb_num%TYPE, p_trans_type VARCHAR2
      )
      IS
         SELECT   adisb.*, awd.base_id, fmast.ci_cal_type,
                  fmast.ci_sequence_number, fmast.fund_id, fmast.fund_code,
                  cat.fed_fund_code
             FROM igf_aw_awd_disb_all adisb, igf_aw_fund_mast_all fmast,
                  igf_aw_award_all awd, igf_aw_fund_cat_all cat
            WHERE adisb.award_id = awd.award_id
                  AND fmast.fund_code = cat.fund_code
                  AND fmast.fund_id = awd.fund_id AND awd.base_id = p_base_id
                  AND awd.fund_id = p_fund_id
                  AND cat.fed_fund_code IN ('ALT', 'FLP', 'FLS', 'FLU')
                  AND adisb.award_id = NVL(p_award_id, adisb.award_id)
                  AND adisb.disb_num = NVL(p_disb_num, adisb.disb_num)
                  AND (adisb.hold_rel_ind = 'H' OR adisb.hold_rel_ind IS NULL)
                  AND adisb.trans_type = p_trans_type
         ORDER BY awd.fund_id, awd.award_id, adisb.disb_num;


--Get all the awards and corresponding disbursements for the student for a given fund
-- in case of FFELP Loans and if transaction type is not specified
      CURSOR cur_awd_disb_fed_no_trans(
      p_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
         p_fund_id igf_aw_fund_mast_all.fund_id%TYPE,
         p_award_id igf_aw_award_all.award_id%TYPE,
         p_disb_num igf_aw_awd_disb_all.disb_num%TYPE
      )
      IS
         SELECT   adisb.*, awd.base_id, fmast.ci_cal_type,
                  fmast.ci_sequence_number, fmast.fund_id, fmast.fund_code,
                  cat.fed_fund_code
             FROM igf_aw_awd_disb_all adisb, igf_aw_fund_mast_all fmast,
                  igf_aw_award_all awd, igf_aw_fund_cat_all cat
            WHERE adisb.award_id = awd.award_id
                  AND fmast.fund_code = cat.fund_code
                  AND fmast.fund_id = awd.fund_id AND awd.base_id = p_base_id
                  AND awd.fund_id = p_fund_id
                  AND cat.fed_fund_code IN ('ALT', 'FLP', 'FLS', 'FLU')
                  AND adisb.award_id = NVL(p_award_id, adisb.award_id)
                  AND adisb.disb_num = NVL(p_disb_num, adisb.disb_num)
                  AND (adisb.hold_rel_ind = 'H' OR adisb.hold_rel_ind IS NULL)
                  AND adisb.disb_date <= TRUNC(SYSDATE)
                  AND adisb.trans_type IN ('A', 'P')
         ORDER BY awd.fund_id, awd.award_id, adisb.disb_num;

      awd_disb_rec                  cur_awd_disb_dl%ROWTYPE;


-- Cursor to get Verification Status of Student

      CURSOR cur_get_ver(p_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
      IS
         SELECT NVL(fed_verif_status, '*') fed_verif_status
           FROM igf_ap_fa_base_rec
          WHERE base_id = p_base_id;

      get_ver_rec                   cur_get_ver%ROWTYPE;

      -- Get the loan generated for this award
      CURSOR cur_get_loans(p_award_id NUMBER, p_loan_id NUMBER)
      IS
         SELECT loan_id, loan_number, loan_status, active, loan_chg_status
           FROM igf_sl_loans_all
          WHERE award_id = p_award_id AND loan_id = NVL(loan_id, p_loan_id);

      get_loans_rec                 cur_get_loans%ROWTYPE;

      CURSOR cur_get_pell(p_award_id igf_aw_award_all.award_id%TYPE)
      IS
         SELECT orig_action_code, origination_id
           FROM igf_gr_rfms_all
          WHERE award_id = p_award_id;

      get_pell_rec                  cur_get_pell%ROWTYPE;

      -- Get the fed fund code of the fund
      CURSOR cur_get_fed_fund_code(
      p_fund_id igf_aw_fund_mast_all.fund_id%TYPE
      )
      IS
         SELECT cat.fed_fund_code
           FROM igf_aw_fund_cat_all cat, igf_aw_fund_mast_all fmast
          WHERE fmast.fund_code = cat.fund_code AND fmast.fund_id = p_fund_id;

      get_fed_fund_code_rec         cur_get_fed_fund_code%ROWTYPE;
      l_acad_cal_type               igs_ca_inst_all.cal_type%TYPE;
      l_acad_seq_num                igs_ca_inst_all.sequence_number%TYPE;
      l_acad_alt_code               igs_ca_inst_all.alternate_code%TYPE;
      l_message_name                fnd_new_messages.message_text%TYPE;
      l_credit_pts                  igf_aw_awd_disb_all.min_credit_pts%TYPE;

--Variables to Store the validation results

      l_pays_prg                    BOOLEAN := TRUE; -- Pays Only Program Result
      l_fclass_result               BOOLEAN := TRUE; -- Fee Class Result
      l_pays_uts                    BOOLEAN := TRUE; -- Pays Only Units Result
      l_att_result                  BOOLEAN := TRUE; -- Attendance Type Result
      l_crdt_pt_result              BOOLEAN := TRUE; -- Credit Points Result
      l_active_result               BOOLEAN := TRUE; -- Loan Active Result
      l_sys_hold_result             BOOLEAN := TRUE; -- System Hold Result
      l_ac_hold_result              BOOLEAN := TRUE; -- Academic Hold Result
      l_elig_result                 BOOLEAN := TRUE; -- DL and PELL Federal Eligibility Result
      l_todo_result                 BOOLEAN := TRUE; -- To Do Result
      l_fund_meth_result            BOOLEAN := TRUE; -- Funding method check
      l_crdt_st_check_plus          BOOLEAN := TRUE; -- Credit status check for PLUS loans

-- following variables are used to make sure that the fund level,award level and term level
-- checks are not repeated for each disbursement belonging to the same fund/award/term

      l_old_fund                    igf_aw_fund_mast_all.fund_id%TYPE;
      l_new_fund                    igf_aw_fund_mast_all.fund_id%TYPE;
      l_old_awd                     igf_aw_award_all.award_id%TYPE;
      l_new_awd                     igf_aw_award_all.award_id%TYPE;
      l_old_ld_cal                  igf_aw_fund_tp_all.tp_cal_type%TYPE;
      l_old_ld_seq                  igf_aw_fund_tp_all.tp_sequence_number%TYPE;
      l_new_ld_cal                  igf_aw_fund_tp_all.tp_cal_type%TYPE;
      l_new_ld_seq                  igf_aw_fund_tp_all.tp_sequence_number%TYPE;
      p_message                     VARCHAR2(1000);
      l_status                      VARCHAR2(1);
      l_record_found                BOOLEAN;
   BEGIN
      -- First we need to check if the fund being disbrused is of type Direct  or PELL
      -- Store the type of fund as we need it in subsequent processing

      OPEN cur_get_fed_fund_code(p_fund_id);
      FETCH cur_get_fed_fund_code INTO get_fed_fund_code_rec;
      CLOSE cur_get_fed_fund_code;
      l_fund_type := 'G'; -- General Fund

      IF igf_sl_gen.chk_dl_fed_fund_code(get_fed_fund_code_rec.fed_fund_code) =
                                                                       'TRUE'
      THEN
         l_fund_type := 'D'; -- Direct Loan Fund
      ELSIF igf_sl_gen.chk_cl_fed_fund_code(
               get_fed_fund_code_rec.fed_fund_code
            ) = 'TRUE'
      THEN
         l_fund_type := 'F'; -- FFELP Fund
      ELSIF get_fed_fund_code_rec.fed_fund_code = 'PELL'
      THEN
         l_fund_type := 'P'; -- Pell Fund
      ELSE
         l_fund_type := 'X'; -- These fund types are not supported
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug', 'fund code ='|| l_fund_type);
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','trans type =' || p_trans_type);
      END IF;

      -- Open the cursor according to the fund code and transaction type specified
      IF l_fund_type IN ('D', 'P')
      THEN
         OPEN cur_awd_disb_dl(p_base_id, p_fund_id, p_award_id, p_disb_num,p_trans_type);
         FETCH cur_awd_disb_dl INTO awd_disb_rec;

         IF cur_awd_disb_dl%NOTFOUND
         THEN
            l_record_found := FALSE;
            CLOSE cur_awd_disb_dl;
         ELSE
            l_record_found := TRUE;
         END IF;
      ELSIF  l_fund_type = 'F' AND p_trans_type IS NOT NULL
      THEN
         OPEN cur_awd_disb_fed(
            p_base_id, p_fund_id, p_award_id, p_disb_num, p_trans_type
         );
         FETCH cur_awd_disb_fed INTO awd_disb_rec;

         IF cur_awd_disb_fed%NOTFOUND
         THEN
            l_record_found := FALSE;
            CLOSE cur_awd_disb_fed;
         ELSE
            l_record_found := TRUE;
         END IF;
      ELSIF  l_fund_type = 'F' AND p_trans_type IS NULL
      THEN
         OPEN cur_awd_disb_fed_no_trans(
            p_base_id, p_fund_id, p_award_id, p_disb_num
         );
         FETCH cur_awd_disb_fed_no_trans INTO awd_disb_rec;

         IF cur_awd_disb_fed_no_trans%NOTFOUND
         THEN
            l_record_found := FALSE;
            CLOSE cur_awd_disb_fed_no_trans;
         ELSE
            l_record_found := TRUE;
         END IF;
      END IF;

      IF NOT (l_record_found)
      THEN
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','no records found');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','p_base_id =' || p_base_id);
         END IF;


-- No  Disbursements found for Student <person number> and Fund  <fund desc>)
         fnd_message.set_name('IGF', 'IGF_SL_NO_DISB_TO_REL');
         fnd_message.set_token('PER_NUM', igf_gr_gen.get_per_num(p_base_id));
         fnd_message.set_token('FDESC', get_fund_desc(p_fund_id));

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','no disbursments availaible for release'|| igf_gr_gen.get_per_num(p_base_id));
         END IF;

         p_result := fnd_message.get;
         fnd_file.put_line(fnd_file.log, RPAD(' ', 10) || p_result);
      ELSE -- record found then
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','cur_awd_disb%FOUND');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','calling delete_pays');
         END IF;

         -- truncate previous records that were used in determining eligibility of the student in the previous run
         delete_pays();

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','called delete_pays');
         END IF;

         l_old_fund := -1;
         l_new_fund := 0;
         l_old_awd := -1;
         l_new_awd := 0;
         l_old_ld_cal := '-1';
         l_old_ld_seq := -1;
         l_new_ld_cal := '0';
         l_new_ld_seq := 0;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','calling get_acad_cal_from_awd with the following info');
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','awd_disb_rec.ci_cal_type:' || awd_disb_rec.ci_cal_type);
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','awd_disb_rec.ci_sequence_number:'|| awd_disb_rec.ci_sequence_number);
         END IF;

         -- Get Academic Calendar Information
         igf_ap_oss_integr.get_acad_cal_from_awd(
            awd_disb_rec.ci_cal_type, awd_disb_rec.ci_sequence_number,
            l_acad_cal_type, l_acad_seq_num, l_acad_alt_code
         );

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','get_acad_cal_from_awd returned the following info');
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','l_acad_cal_type:'||l_acad_cal_type);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','l_acad_seq_num:'||l_acad_seq_num);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','l_acad_alt_code:'||l_acad_alt_code);
         END IF;


--
-- First get all the enrolled programs, unit sets for the student and insert into IGF_DB_PAYS_PRG_T
-- We are doing this before starting the main loop.
-- It may very well happen that there are no Pays only units or programs defined in fund setup
-- Still we need to have the the enrolled programs, unit sets for the student into IGF_DB_PAYS_PRG_T
--

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','calling insert_pays_prg_uts');
         END IF;

         insert_pays_prg_uts(awd_disb_rec.base_id, l_acad_cal_type, l_acad_seq_num);

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','called insert_pays_prg_uts');
         END IF;

         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','starting processing for ' || igf_gr_gen.get_per_num(p_base_id)|| ' ' || get_fund_desc(awd_disb_rec.fund_id));
         END IF;

         -- FOR all the records IN CUR_AWD_DISB
         LOOP
            BEGIN
               -- clear message stack
               fnd_message.CLEAR;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','l_fund_type:' || l_fund_type);
               END IF;

               l_old_fund := l_new_fund;
               l_new_fund := awd_disb_rec.fund_id;

               IF l_old_fund = 0
                  OR (l_old_fund <> l_new_fund AND l_old_fund > 1)
               THEN
                  fnd_file.new_line(fnd_file.log, 1);
                  fnd_message.set_name('IGF', 'IGF_DB_PROCESS_STD_FUND');
                  fnd_message.set_token('PER_NUM', igf_gr_gen.get_per_num(p_base_id));
                  fnd_message.set_token('FDESC', get_fund_desc(awd_disb_rec.fund_id));
                  fnd_file.put_line(
                     fnd_file.log, RPAD(' ', 10) || fnd_message.get
                  );
               END IF;

               fnd_file.new_line(fnd_file.log, 1);
               fnd_message.set_name('IGF', 'IGF_DB_PROCESS_AWD_DISB');
               -- 'Processing disbursement for award <award id > ,disbursement <disbursement   number>'
               fnd_message.set_token('AWARD_ID', TO_CHAR(awd_disb_rec.award_id));
               fnd_message.set_token('DISB_NUM', TO_CHAR(awd_disb_rec.disb_num));
               fnd_file.put_line(fnd_file.log, RPAD(' ', 15) || fnd_message.get);
               fnd_file.new_line(fnd_file.log, 1);

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','awd_disb_rec.award_id:' || awd_disb_rec.award_id);
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','awd_disb_rec.disb_num:' || awd_disb_rec.disb_num);
               END IF;

-- Validations
--
-- The checks that are to be done for a fund in the award year context are:
-- 1. To Do Item Validations
-- 2. Pays Only Program
-- 3. Pays Only Units
-- 4. Eligibility check for getting loans (NSLDS_ELIGIBLE)
-- 5. Eligibility check for getting PELL Grant (PELL_ELIGIBLE)
--
               IF l_old_fund <> l_new_fund
               THEN
                  IF fnd_log.level_statement >=fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','processing in award year context '|| igf_gr_gen.get_per_num(p_base_id) || ' '|| get_fund_desc(awd_disb_rec.fund_id));
                  END IF;

                  -- For each new fund that is visible within this scope,
                  -- the result variables are initialized

                  l_todo_result := TRUE;
                  l_pays_prg := TRUE;
                  l_pays_uts := TRUE;
                  l_elig_result := TRUE;
                  l_ac_hold_result := TRUE;

                  IF igf_aw_gen_005.get_stud_hold_effect(
                        'D', igf_gr_gen.get_person_id(p_base_id),
                        awd_disb_rec.fund_code
                     ) = 'F'
                  THEN
                     l_ac_hold_result := FALSE;
                  END IF;

                  l_todo_result := chk_todo_result(
                                      l_message_name, awd_disb_rec.fund_id,
                                      awd_disb_rec.base_id
                                   );
                  l_pays_prg := chk_pays_prg(
                                   awd_disb_rec.fund_id, awd_disb_rec.base_id
                                );
                  l_pays_uts := chk_pays_uts(
                                   awd_disb_rec.fund_id, awd_disb_rec.base_id
                                );
                  l_elig_result := chk_fed_elig(
                                      awd_disb_rec.base_id, l_fund_type
                                   );

                  IF NOT l_ac_hold_result
                  THEN
                     fnd_message.set_name('IGF', 'IGF_SL_DISB_FUND_HOLD_FAIL');
                     p_result := fnd_message.get;
                     fnd_file.put_line(
                        fnd_file.log, RPAD(' ', 17) || p_result
                     );
                  END IF;

                  IF  NOT l_todo_result AND l_message_name IS NOT NULL
                  THEN
                     fnd_message.set_name('IGF', l_message_name);
                     -- 'Disbursement failed Fund To Do check'
                     p_result := fnd_message.get;
                     fnd_file.put_line(
                        fnd_file.log, RPAD(' ', 17) || p_result
                     );
                  END IF;

                  IF NOT l_pays_prg
                  THEN
                     fnd_message.set_name('IGF', 'IGF_DB_FAIL_PPRG');
                     -- 'Disbursement failed Fund Pays Only Program check'
                     p_result := fnd_message.get;
                     fnd_file.put_line(
                        fnd_file.log, RPAD(' ', 17) || p_result
                     );
                  END IF;

                  IF NOT l_pays_uts
                  THEN
                     fnd_message.set_name('IGF', 'IGF_DB_FAIL_PUNT');
                     -- 'Disbursement failed Fund Pays Only Unit check'
                     p_result := fnd_message.get;
                     fnd_file.put_line(
                        fnd_file.log, RPAD(' ', 17) || p_result
                     );
                  END IF;

                  IF NOT l_elig_result
                  THEN
                     IF l_fund_type = 'P'
                     THEN
                        fnd_message.set_name('IGF', 'IGF_GR_PELL_INELIGIBLE');
                     -- 'Disbursement failed Pell Eligiblity check'
                     END IF;

                     IF l_fund_type = 'D'
                     THEN
                        fnd_message.set_name('IGF', 'IGF_DB_FAIL_FEDL_ELIG');
                     -- 'Disbursement failed NSLDS Eligiblity check'
                     END IF;

                     p_result := fnd_message.get;
                     fnd_file.put_line(fnd_file.log, RPAD(' ', 17) || p_result);
                  END IF;

                  IF fnd_log.level_statement >=fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','fund level validation results');
                     IF NOT l_ac_hold_result THEN
                       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','disbursment hold exist');
                     ELSE
                       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','disbursment hold do not exist');
                     END IF;

                     IF NOT l_todo_result THEN
                       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','failed to do items check');
                     ELSE
                       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','passed to do items check');
                     END IF;

                     IF NOT l_pays_prg THEN
                       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','failed pays only prog check');
                     ELSE
                       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','passed pays only prog check');
                     END IF;

                     IF NOT l_pays_uts THEN
                       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','failed pays only units check');
                     ELSE
                       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','passed pays only units check');
                     END IF;

                     IF NOT l_elig_result THEN

                       IF l_fund_type = 'P' THEN
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','failed pell eligibilty check');
                       ELSE
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student..debug','passed pell eligibilty check');
                       END IF;

                       IF l_fund_type ='D' THEN
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','failed NSLDS eligibilty check');
                       ELSE
                         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','passed NSLDS eligibilty check');
                       END IF;
                     END IF; -- Pell Elig
                  END IF; -- FND Log End If
               END IF; -- old fund id not new fund
--
-- Validations
-- Checks that should be done at Award Level
-- 1.Active Loan
-- 2.Credit Status
               l_old_awd := l_new_awd;
               l_new_awd := awd_disb_rec.award_id;

               IF l_old_awd <> l_new_awd
               THEN
                  -- For each new fund that is visible within this scope,
                  -- the result variables are initialized
                  l_active_result := TRUE;

                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'performing awd level validations'
                     );
                  END IF;

                  IF l_fund_type IN ('D', 'F')
                  THEN -- for direct loan and pell
                     -- if loan id is not specified then get the loans generated for this awd
                     OPEN cur_get_loans(awd_disb_rec.award_id, p_loan_id);
                     FETCH cur_get_loans INTO get_loans_rec;

                     IF cur_get_loans%NOTFOUND
                     THEN
                        l_active_result := FALSE;
                        CLOSE cur_get_loans;
                        fnd_message.set_name('IGF', 'IGF_SL_LOAN_ID_NOT_FOUND');
                        p_result := fnd_message.get;
                        fnd_file.put_line(
                           fnd_file.log, RPAD(' ', 17) || p_result
                        );

                        -- message ' Loan Not created for this award <Award ID>'
                        IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.string(
                              fnd_log.level_statement,
                              'igf.plsql.igf_sl_rel_disb.process_student.debug',
                              'cur_get_loans%NOTFOUND'
                           );
                        END IF;
                     ELSIF cur_get_loans%FOUND
                     THEN
                        CLOSE cur_get_loans;

                        IF NVL(get_loans_rec.active, 'N') <> 'Y'
                        THEN
                           fnd_message.set_name('IGF', 'IGF_SL_LOAN_INACTIVE_DRI');
                           fnd_message.set_token(
                              'LOAN_NUMBER', get_loans_rec.loan_number
                           );
                           p_result := fnd_message.get;
                           fnd_file.put_line(
                              fnd_file.log, RPAD(' ', 17) || p_result
                           );
                           l_active_result := FALSE;

                           IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                           THEN
                              fnd_log.string(
                                 fnd_log.level_statement,
                                 'igf.plsql.igf_sl_rel_disb.process_student.debug',
                                 'loan ' || get_loans_rec.loan_number
                                 || ' is inactive'
                              );
                           END IF;
                        END IF;

                        IF get_loans_rec.loan_status = 'S'
                           OR NVL(get_loans_rec.loan_chg_status, '*') = 'S'
                        THEN
                           fnd_message.set_name('IGF', 'IGF_SL_LOAN_SENT_DRI');
                           fnd_message.set_token('LOAN_NUMBER', get_loans_rec.loan_number);
                           p_result := fnd_message.get;
                           fnd_file.put_line(fnd_file.log, RPAD(' ', 17) || p_result);
                           l_active_result := FALSE;

                           IF fnd_log.level_statement >=fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug','loan ' || get_loans_rec.loan_number
                                 || ' is sent'
                              );
                           END IF;
                        END IF;

                        IF get_loans_rec.loan_status = 'R'
                           OR NVL(get_loans_rec.loan_chg_status, '*') = 'R'
                        THEN
                           fnd_message.set_name('IGF', 'IGF_SL_LOAN_REJ_DRI'); -- Rejected Loan
                           fnd_message.set_token(
                              'LOAN_NUMBER', get_loans_rec.loan_number
                           );
                           p_result := fnd_message.get;
                           fnd_file.put_line(
                              fnd_file.log, RPAD(' ', 17) || p_result
                           );
                           l_active_result := FALSE;

                           IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                           THEN
                              fnd_log.string(
                                 fnd_log.level_statement,
                                 'igf.plsql.igf_sl_rel_disb.process_student.debug',
                                 'loan ' || get_loans_rec.loan_number
                                 || ' is rejected'
                              );
                           END IF;
                        END IF;

                        IF  l_fund_type = 'F' THEN
                          IF get_loans_rec.loan_status = 'A'THEN
                             IF igf_sl_award.get_loan_cl_version(awd_disb_rec.award_id) <> 'RELEASE-4'  THEN
                                fnd_message.set_name('IGF', 'IGF_SL_LOAN_RELEASE4_DRI'); -- not a release 4 loan
                                fnd_message.set_token('LOAN_NUMBER', get_loans_rec.loan_number);
                                p_result := fnd_message.get;
                                fnd_file.put_line(fnd_file.log, RPAD(' ', 17) || p_result);
                                l_active_result := FALSE;
                                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
                                    THEN fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_rel_disb.process_student.debug',
                                   'loan ' || get_loans_rec.loan_number || ' is not release-4');
                                END IF;
                             END IF; -- release 4
                          END IF; -- loan status 'A'
                        END IF; --fund type 'F'
                     END IF; -- ( cur_get_loans%NOTFOUND)
                  END IF; -- fund = 'D', 'F'

                  IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     IF NOT l_active_result
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'loan not active'
                        );
                     ELSE
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'loan active'
                        );
                     END IF;
                  END IF;
-- Credit Status
                  l_crdt_st_check_plus := TRUE;

                  IF awd_disb_rec.fed_fund_code = 'DLP'
                  THEN
                     -- If plus loan then credit status check must be passed

                     l_crdt_st_check_plus := chk_credit_status(
                                                awd_disb_rec.award_id
                                             );

                     IF NOT l_crdt_st_check_plus
                     THEN
                        fnd_message.set_name(
                           'IGF', 'IGF_SL_DLP_CRDT_STATUS_FAIL'
                        );
                        p_result := fnd_message.get;
                        fnd_file.put_line(
                           fnd_file.log, RPAD(' ', 17) || p_result
                        );

                        IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.string(
                              fnd_log.level_statement,
                              'igf.plsql.igf_sl_rel_disb.process_student.debug',
                              'credit status check failed'
                           );
                        END IF;
                     ELSE
                        IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.string(
                              fnd_log.level_statement,
                              'igf.plsql.igf_sl_rel_disb.process_student.debug',
                              'credit status check passed'
                           );
                        END IF;
                     END IF;
                  END IF;

                  IF l_fund_type = 'P'
                  THEN
                     OPEN cur_get_pell(awd_disb_rec.award_id);
                     FETCH cur_get_pell INTO get_pell_rec;
                     CLOSE cur_get_pell;

                     IF NVL(get_pell_rec.orig_action_code, '*') = 'S'
                     THEN
                        fnd_message.set_name('IGF', 'IGF_SL_PELL_SENT_DRI');
                        fnd_message.set_token(
                           'ORIGINATION_ID', get_pell_rec.origination_id
                        );
                        p_result := fnd_message.get;
                        fnd_file.put_line(
                           fnd_file.log, RPAD(' ', 17) || p_result
                        );
                        l_active_result := FALSE;

                        IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.string(
                              fnd_log.level_statement,
                              'igf.plsql.igf_sl_rel_disb.process_student.debug',
                              'pell ' || get_pell_rec.origination_id
                              || ' is in sent'
                           );
                        END IF;
                     END IF;

                     IF NVL(get_pell_rec.orig_action_code, '*') = 'E'
                     THEN -- Rejected Pell
                        fnd_message.set_name('IGF', 'IGF_SL_PELL_REJ_DRI');
                        fnd_message.set_token(
                           'ORIGINATION_ID', get_pell_rec.origination_id
                        );
                        p_result := fnd_message.get;
                        fnd_file.put_line(
                           fnd_file.log, RPAD(' ', 17) || p_result
                        );
                        l_active_result := FALSE;

                        IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.string(
                              fnd_log.level_statement,
                              'igf.plsql.igf_sl_rel_disb.process_student.debug',
                              'pell ' || get_pell_rec.origination_id
                              || ' is in Rejected'
                           );
                        END IF;
                     END IF;
                  END IF;
               END IF; -- (IF l_old_awd <> l_new_awd)


--
-- Validations
-- Checks that should be done at Term Level
-- This has to be done if the Fund Changes,
-- but terms are same
--
-- 1. Pays Only Fee Class
-- 2. System Hold

               l_old_ld_cal := l_new_ld_cal;
               l_old_ld_seq := l_new_ld_seq;
               l_new_ld_cal := awd_disb_rec.ld_cal_type;
               l_new_ld_seq := awd_disb_rec.ld_sequence_number;

               IF (l_old_ld_cal <> l_new_ld_cal
                   AND l_old_ld_seq <> l_new_ld_seq
                  )
                  OR (l_old_fund <> l_new_fund)
               THEN
                  l_fclass_result := TRUE;
                  l_sys_hold_result := TRUE;

                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'pays only fee class check'
                     );
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'fund_id' || awd_disb_rec.fund_id
                     );
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'ld_cal_type' || awd_disb_rec.ld_cal_type
                     );
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'ld_sequence_number'
                        || awd_disb_rec.ld_sequence_number
                     );
                  END IF;

                  l_fclass_result := chk_fclass_result(
                                        awd_disb_rec.base_id,
                                        awd_disb_rec.fund_id,
                                        awd_disb_rec.ld_cal_type,
                                        awd_disb_rec.ld_sequence_number
                                     );

                  IF l_fund_type IN ('D', 'F')
                  THEN
                     IF NVL(awd_disb_rec.manual_hold_ind, 'N') = 'Y'
                     THEN
                        --Hold exsists
                        l_sys_hold_result := FALSE;
                     ELSE
                        l_sys_hold_result := TRUE;
                     END IF;
                  END IF;

                  IF NOT l_fclass_result
                  THEN
                     fnd_message.set_name('IGF', 'IGF_DB_FAIL_FCLS');
                     --Disbursement failed Pays Only Fee Class Check
                     p_result := fnd_message.get;
                     fnd_file.put_line(
                        fnd_file.log, RPAD(' ', 17) || p_result
                     );
                  END IF;

                  IF NOT l_sys_hold_result
                  THEN
                     fnd_message.set_name('IGF', 'IGF_SL_SYS_HOLD_FAIL');
                     --System hold exsist on the disbursment
                     p_result := fnd_message.get;
                     fnd_file.put_line(
                        fnd_file.log, RPAD(' ', 17) || p_result
                     );
                  END IF;

                  IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     IF NOT l_fclass_result
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'failed pays only fees class check'
                        );
                     ELSE
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'passed pays only fees class check'
                        );
                     END IF;

                     IF NOT l_sys_hold_result
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'system hold exsist on the disbursment'
                        );
                     ELSE
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'system hold do not exsist on the disbursment'
                        );
                     END IF;
                  END IF;
               END IF; --  OLD <> NEW


-- Validations to be performed at disbursment level
-- 1. Cumulative Current Credit Points
-- 2. Min Att Type if specified
-- 3. Funding method
-- 4. Credit status for PLUS- Direct loans

-- Min Credit Points

               l_crdt_pt_result := TRUE;

               IF awd_disb_rec.min_credit_pts IS NOT NULL
               THEN
                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'awd_disb_rec.min_credit_pts:'
                        || awd_disb_rec.min_credit_pts
                     );
                  END IF;

                  igs_en_prc_load.enrp_clc_cp_upto_tp_start_dt(
                     igf_gr_gen.get_person_id(awd_disb_rec.base_id),
                     awd_disb_rec.ld_cal_type, awd_disb_rec.ld_sequence_number,
                     'Y', get_cut_off_dt(
                             awd_disb_rec.ld_sequence_number,
                             awd_disb_rec.disb_date
                          ), l_credit_pts
                  );

                  IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'l_credit_pts:' || l_credit_pts
                     );
                  END IF;

                  IF NVL(l_credit_pts, 0) <
                                           NVL(awd_disb_rec.min_credit_pts, 0)
                  THEN
                     l_crdt_pt_result := FALSE;
                     fnd_message.set_name('IGF', 'IGF_DB_FAIL_CRP');
                     p_result := fnd_message.get;
                     fnd_file.put_line(
                        fnd_file.log, RPAD(' ', 17) || p_result
                     );

                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'min credit check failed'
                        );
                     END IF;
                  ELSE
                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'min credit check passed'
                        );
                     END IF;
                  END IF;
               ELSE -- (awd_disb_rec.min_credit_pts IS NOT NULL)
                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'awd_disb_rec.min_credit_pts is NULL'
                     );
                  END IF;
               END IF; -- (IF awd_disb_rec.min_credit_pts IS NOT NULL )

               -- Attendance type
               l_att_result := TRUE;

               IF awd_disb_rec.attendance_type_code IS NOT NULL
               THEN
                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_db_disb.process_student.debug',
                        'awd_disb_rec.attendance_type_code:'
                        || awd_disb_rec.attendance_type_code
                     );
                  END IF;

                  p_message := NULL;
                  l_att_result := chk_attendance(
                                     awd_disb_rec.base_id,
                                     awd_disb_rec.ld_cal_type,
                                     awd_disb_rec.ld_sequence_number,
                                     awd_disb_rec.attendance_type_code,
                                     p_message
                                  );
               END IF;

               IF NOT l_att_result
               THEN
                  fnd_message.set_name('IGF', 'IGF_DB_FAIL_ATT');
                  --Disbursement failed Attendance Type Check
                  p_result := fnd_message.get;

                  IF p_message IS NOT NULL
                  THEN
                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'message = ' || p_message
                        );
                     END IF;

                     --p_result := p_message ||fnd_global.newline ||p_result;
                     p_result := p_message || ' ' || p_result;
                  END IF;

                  fnd_file.put_line(fnd_file.log, RPAD(' ', 17) || p_result);

                  IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'min attendance type check failed'
                     );
                  END IF;
               ELSE
                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'min attendance type check passed'
                     );
                  END IF;
               END IF;

               -- Funding method

               IF l_fund_type = 'D'
               THEN -- funding method check for direct loans
                  l_fund_meth_result := chk_fund_meth_dl(
                                           awd_disb_rec.ci_cal_type,
                                           awd_disb_rec.ci_sequence_number,
                                           awd_disb_rec.award_id,
                                           awd_disb_rec.disb_num
                                        );

                  IF l_fund_meth_result IS NULL
                  THEN
                     -- null is returned if the funding type is incorrect
                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'result of funding method check is NULL'
                        );
                     END IF;

                     fnd_message.set_name('IGF', 'IGF_SL_FUND_METH_NOT_CORR');
                     p_result := fnd_message.get;
                     fnd_file.put_line(fnd_file.log, RPAD(' ', 17) || p_result);
                     RAISE skip_record;

                     IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'error in funding method'
                        );
                     END IF;
                  ELSIF NOT l_fund_meth_result
                  THEN
                     -- funding method check failed so DRI can't be set to true

                     fnd_message.set_name('IGF', 'IGF_SL_FUND_METH_CHK_FAIL');
                     p_result := fnd_message.get;
                     fnd_file.put_line(
                        fnd_file.log, RPAD(' ', 17) || p_result
                     );

                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'funding method check failed'
                        );
                     END IF;
                  ELSE
                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'funding method check passed'
                        );
                     END IF;
                  END IF;
               ELSIF l_fund_type = 'P'
               THEN -- funding method check for pell
                  l_fund_meth_result := chk_fund_meth_pell(
                                           p_base_id,
                                           awd_disb_rec.ci_cal_type,
                                           awd_disb_rec.ci_sequence_number,
                                           awd_disb_rec.award_id,
                                           awd_disb_rec.disb_num, l_status,
                                           p_message
                                        );

                  IF l_fund_meth_result IS NULL
                  THEN
                     IF l_status = 'E'
                     THEN
                        -- error message is returned by the method
                        p_result := p_message;
                        fnd_file.put_line(
                           fnd_file.log, RPAD(' ', 17) || p_result
                        );
                        RAISE skip_record;

                        IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.string(
                              fnd_log.level_statement,
                              'igf.plsql.igf_sl_rel_disb.process_student.debug',
                              'error returned by function chk_fund_meth_pell'
                           );
                        END IF;
                     ELSE
                        -- null is returned if the funding type is incorrect
                        fnd_message.set_name(
                           'IGF', 'IGF_SL_FUND_METH_NOT_CORR'
                        );
                        p_result := fnd_message.get;
                        fnd_file.put_line(
                           fnd_file.log, RPAD(' ', 17) || p_result
                        );
                        RAISE skip_record;

                        IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.string(
                              fnd_log.level_statement,
                              'igf.plsql.igf_sl_rel_disb.process_student.debug',
                              'error in funding method'
                           );
                        END IF;
                     END IF;
                  ELSIF NOT l_fund_meth_result
                  THEN
                     -- funding method check failed so DRI can't be set to true

                     fnd_message.set_name('IGF', 'IGF_SL_FUND_METH_CHK_FAIL');
                     p_result := fnd_message.get;
                     fnd_file.put_line(
                        fnd_file.log, RPAD(' ', 17) || p_result
                     );

                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'funding method check failed'
                        );
                     END IF;
                  ELSE
                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'funding method check passed'
                        );
                     END IF;
                  END IF;
               END IF;


--
-- Based on these results, set DRI to true
--
               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.string(
                     fnd_log.level_statement,
                     'igf.plsql.igf_sl_rel_disb.process_student.debug',
                     'checking the result of all eligibilty checks'
                  );
                  fnd_log.string(
                     fnd_log.level_statement,
                     'igf.plsql.igf_sl_rel_disb.process_student.debug',
                     'fed_fund_code' || awd_disb_rec.fed_fund_code
                  );

                  IF NOT l_pays_prg
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'l_pays_prg passed'
                     );
                  END IF;

                  IF NOT l_fclass_result
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'l_fclass_result'
                     );
                  END IF;

                  IF NOT l_pays_uts
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'l_pays_uts'
                     );
                  END IF;

                  IF NOT l_att_result
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'l_att_result'
                     );
                  END IF;

                  IF NOT l_active_result
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'l_active_result'
                     );
                  END IF;

                  IF NOT l_sys_hold_result
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'l_sys_hold_result'
                     );
                  END IF;

                  IF NOT l_ac_hold_result
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'l_ac_hold_result'
                     );
                  END IF;

                  IF NOT l_todo_result
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'l_elig_result'
                     );
                  END IF;

                  IF NOT l_fund_meth_result
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'l_fund_meth_result'
                     );
                  END IF;

                  IF NOT l_crdt_st_check_plus
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'l_crdt_st_check_PLUS '
                     );
                  END IF;
               END IF;

               IF awd_disb_rec.fed_fund_code = 'DLP'
               THEN
                  IF  l_pays_prg AND l_fclass_result AND l_pays_uts
                      AND l_att_result AND l_crdt_pt_result
                      AND l_active_result AND l_sys_hold_result
                      AND l_ac_hold_result AND l_elig_result AND l_todo_result
                      AND l_fund_meth_result AND l_crdt_st_check_plus
                  THEN
                     set_dri_true(
                        awd_disb_rec.award_id, awd_disb_rec.disb_num,
                        awd_disb_rec.fund_id, l_fund_type
                     );

                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'called set_dri_true with fund_id '
                           || awd_disb_rec.fund_id
                        );
                     END IF;
                  END IF;
               ELSIF l_fund_type IN ('D', 'P')
               THEN
                  IF  l_pays_prg AND l_fclass_result AND l_pays_uts
                      AND l_att_result AND l_crdt_pt_result
                      AND l_active_result AND l_sys_hold_result
                      AND l_ac_hold_result AND l_elig_result AND l_todo_result
                      AND l_fund_meth_result
                  THEN
                     set_dri_true(
                        awd_disb_rec.award_id, awd_disb_rec.disb_num,
                        awd_disb_rec.fund_id, l_fund_type
                     );

                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'called set_dri_true with fund_id '
                           || awd_disb_rec.fund_id
                        );
                     END IF;
                  END IF;
               ELSIF l_fund_type = 'F'
               THEN
                  IF  l_pays_prg AND l_fclass_result AND l_pays_uts
                      AND l_att_result AND l_crdt_pt_result
                      AND l_active_result AND l_sys_hold_result
                      AND l_ac_hold_result AND l_elig_result AND l_todo_result
                  THEN
                     set_dri_true(
                        awd_disb_rec.award_id, awd_disb_rec.disb_num,
                        awd_disb_rec.fund_id, l_fund_type
                     );

                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.process_student.debug',
                           'called set_dri_true with fund_id '
                           || awd_disb_rec.fund_id
                        );
                     END IF;
                  END IF;
               END IF;

               IF l_fund_type IN ('D', 'P')
               THEN
                  FETCH cur_awd_disb_dl INTO awd_disb_rec;
                  EXIT WHEN cur_awd_disb_dl%NOTFOUND;

                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'exiting with fund type' || l_fund_type
                     );
                  END IF;
               ELSIF  l_fund_type = 'F' AND p_trans_type IS NOT NULL
               THEN
                  FETCH cur_awd_disb_fed INTO awd_disb_rec;
                  EXIT WHEN cur_awd_disb_fed%NOTFOUND;

                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'exiting with fund type' || l_fund_type
                     );
                  END IF;
               ELSIF  l_fund_type = 'F' AND p_trans_type IS NULL
               THEN
                  FETCH cur_awd_disb_fed_no_trans INTO awd_disb_rec;
                  EXIT WHEN cur_awd_disb_fed_no_trans%NOTFOUND;

                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'exiting with fund type' || l_fund_type
                     );
                  END IF;
               ELSE
                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.process_student.debug',
                        'exiting with fund type' || l_fund_type
                     );
                  END IF;

                  EXIT;
               END IF;
            EXCEPTION
               WHEN app_exception.record_lock_exception
               THEN
                  RAISE;
               WHEN skip_record
               THEN
                  -- clear message stack
                  fnd_message.CLEAR;

                  IF l_fund_type IN ('D', 'P')
                  THEN
                     FETCH cur_awd_disb_dl INTO awd_disb_rec;
                     EXIT WHEN cur_awd_disb_dl%NOTFOUND;
                  ELSIF  l_fund_type = 'F' AND p_trans_type IS NOT NULL
                  THEN
                     FETCH cur_awd_disb_fed INTO awd_disb_rec;
                     EXIT WHEN cur_awd_disb_fed%NOTFOUND;
                  ELSIF  l_fund_type = 'F' AND p_trans_type IS NULL
                  THEN
                     FETCH cur_awd_disb_fed_no_trans INTO awd_disb_rec;
                     EXIT WHEN cur_awd_disb_fed_no_trans%NOTFOUND;
                  ELSE
                     EXIT;
                  END IF;
            END;
         END LOOP; -- (-- FOR all the records IN CUR_AWD_DISB)

         -- Close the cursors
         IF cur_awd_disb_dl%ISOPEN
         THEN
            CLOSE cur_awd_disb_dl;
         END IF;

         IF cur_awd_disb_fed%ISOPEN
         THEN
            CLOSE cur_awd_disb_fed;
         END IF;

         IF cur_awd_disb_fed_no_trans%ISOPEN
         THEN
            CLOSE cur_awd_disb_fed_no_trans;
         END IF;
      END IF; --(IF cur_awd_disb%NOTFOUND)
   EXCEPTION
      WHEN app_exception.record_lock_exception
      THEN
         RAISE;
      WHEN OTHERS
      THEN
         fnd_message.set_name('IGF', 'IGF_GE_UNHANDLED_EXP');
         fnd_message.set_token(
            'NAME', 'IGF_DB_DISB.PROCESS_STUDENT' || SQLERRM
         );
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         app_exception.raise_exception;
   END process_student;


--------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--   Know limitations, enhancements or remarks
--   Change History:
-----------------------------------------------------------------------------------
--   Who      When             What
--tsailaja      15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
-----------------------------------------------------------------------------------
   PROCEDURE rel_disb_process_dl(
   errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER,
      p_award_year IN VARCHAR2, p_pell_dummy IN VARCHAR2,
      p_dl_dummy IN VARCHAR2, p_fund_id IN igf_aw_fund_mast_all.fund_id%TYPE,
      p_base_id IN igf_ap_fa_base_rec_all.base_id%TYPE, p_per_dummy IN NUMBER,
      p_loan_id IN NUMBER, p_loan_dummy IN NUMBER, p_per_grp_id IN NUMBER,
      p_trans_type IN igf_aw_awd_disb_all.trans_type%TYPE
   )

------------------------------------------------------------------------------------------------------------------------------------
--
--                              This process would be called from concurrent mananger for Direct Loans
--                              This process, depending on the input parameters passed
--                              will call the main process ie process_student()

------------------------------------------------------------------------------------------------------------------------------------
   IS
   BEGIN
    igf_aw_gen.set_org_id(NULL);
      rel_disb_process(
         errbuf, retcode, p_award_year, p_fund_id, p_base_id, p_loan_id, p_trans_type,
         p_per_grp_id
      );
   END rel_disb_process_dl;


------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
--   Know limitations, enhancements or remarks
--   Change History:
-----------------------------------------------------------------------------------
--   Who      When             What
--tsailaja      15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
-----------------------------------------------------------------------------------
   PROCEDURE rel_disb_process_fed(
   errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY NUMBER,
      p_award_year IN VARCHAR2,
      p_fund_id IN igf_aw_fund_mast_all.fund_id%TYPE,
      p_base_id IN igf_ap_fa_base_rec_all.base_id%TYPE, p_per_dummy IN NUMBER,
      p_loan_id IN NUMBER, p_loan_dummy IN NUMBER, p_trans_type IN VARCHAR2,
      p_per_grp_id IN NUMBER
   )

------------------------------------------------------------------------------------------------------------------------------------
--
--                              This process would be called from concurrent mananger for Direct Loans
--                              This process, depending on the input parameters passed
--                              will call the main process ie process_student()

------------------------------------------------------------------------------------------------------------------------------------
   IS
   BEGIN
    igf_aw_gen.set_org_id(NULL);
      rel_disb_process(
         errbuf, retcode, p_award_year, p_fund_id, p_base_id, p_loan_id,
         p_trans_type, p_per_grp_id
      );
   END rel_disb_process_fed;


------------------------------------------------------------------------------------------------------------------------------------



   PROCEDURE rel_disb_process(
   p_errbuf OUT NOCOPY VARCHAR2, p_retcode OUT NOCOPY NUMBER,
      p_award_year IN VARCHAR2,
      p_fund_id IN igf_aw_fund_mast_all.fund_id%TYPE,
      p_base_id IN igf_ap_fa_base_rec_all.base_id%TYPE, p_loan_id IN NUMBER,
      p_trans_type IN VARCHAR2, p_per_grp_id IN NUMBER
   )
   IS
      param_exception               EXCEPTION;
      l_ci_cal_type                 igs_ca_inst_all.cal_type%TYPE;
      l_ci_sequence_number          igs_ca_inst_all.sequence_number%TYPE;
      l_list                        VARCHAR2(32767);
      l_status                      VARCHAR2(1);
      l_base_id                     NUMBER;
      l_person_number               VARCHAR2(30);
      l_result                      VARCHAR2(4000) := NULL;

      TYPE cur_person_id_type IS REF CURSOR;

      cur_per_grp                   cur_person_id_type;
      l_person_id                   hz_parties.party_id%TYPE;


-- Cursor to get alternate code for the calendar instance
      CURSOR cur_awdyear(cp_cal_type VARCHAR2, cp_seq_number NUMBER)
      IS
         SELECT alternate_code
           FROM igs_ca_inst_all
          WHERE cal_type = cp_cal_type AND sequence_number = cp_seq_number;

      awdyear_rec                   cur_awdyear%ROWTYPE;


-- Cursor to retreive Persons from Person Group
-- The code can handle dynamic person id groups
      CURSOR cur_per_grp_name(
      p_per_grp_id igs_pe_persid_group_all.GROUP_ID%TYPE
      )
      IS
         SELECT group_cd --Code of a person ID group.
                         --A person ID group also has a unique system generated sequencenumber or group ID
           FROM igs_pe_persid_group
          WHERE GROUP_ID = p_per_grp_id;

      per_grp_rec                   cur_per_grp_name%ROWTYPE;

      -- Cursor to retreive Student having awards for a given fund
      CURSOR cur_award_std(p_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
      IS
         SELECT DISTINCT awd.base_id base_id, fcat.fed_fund_code
                               fed_fund_code
                    FROM igf_aw_award awd, igf_aw_fund_mast fmast,
                         igf_aw_fund_cat fcat
                   WHERE awd.fund_id = p_fund_id
                         AND awd.fund_id = fmast.fund_id
                         AND fmast.fund_code = fcat.fund_code
                         AND awd.award_status = 'ACCEPTED';

      award_std_rec                 cur_award_std%ROWTYPE;


--  Cursor to get award_id from a loan_id

      CURSOR cur_get_awd_id(p_loan_id igf_sl_loans_all.loan_id%TYPE)
      IS
         SELECT award_id
           FROM igf_sl_loans_all
          WHERE loan_id = p_loan_id;

      get_awd_id_rec                cur_get_awd_id%ROWTYPE;

      -- Get the fund type
      CURSOR cur_get_fund_type(p_fund_id igf_aw_fund_mast_all.fund_id%TYPE)
      IS
         SELECT cat.fed_fund_code fed_fund_code
           FROM igf_aw_fund_cat_all cat, igf_aw_fund_mast_all mast
          WHERE mast.fund_code = cat.fund_code AND mast.fund_id = p_fund_id;

      get_fund_type_rec         cur_get_fund_type%ROWTYPE;
      lv_group_type             igs_pe_persid_group_v.group_type%TYPE;

   BEGIN
      p_errbuf := NULL;
      p_retcode := 0;
      l_ci_cal_type := RTRIM(SUBSTR(p_award_year, 1, 10));
      l_ci_sequence_number := RTRIM(SUBSTR(p_award_year, 11));

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.string(
            fnd_log.level_statement,
            'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
            'l_ci_cal_type:' || l_ci_cal_type
         );
         fnd_log.string(
            fnd_log.level_statement,
            'igf.plsql.igf_sl_rel_disb.rel_rel_disb_process.debug',
            'l_ci_sequence_number:' || l_ci_sequence_number
         );
         fnd_log.string(
            fnd_log.level_statement,
            'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug', 'p_fund_id:'
                                                                || p_fund_id
         );
         fnd_log.string(
            fnd_log.level_statement,
            'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug', 'p_base_id:'
                                                                || p_base_id
         );
         fnd_log.string(
            fnd_log.level_statement,
            'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug', 'p_loan_id:'
                                                                || p_loan_id
         );
         fnd_log.string(
            fnd_log.level_statement,
            'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
            'p_trans_type:' || p_trans_type
         );
         fnd_log.string(
            fnd_log.level_statement,
            'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
            'p_per_grp_id:' || p_per_grp_id
         );
      END IF;

      --- Print all the parameters in log file
      OPEN cur_awdyear(l_ci_cal_type, l_ci_sequence_number);
      FETCH cur_awdyear INTO awdyear_rec;

      IF cur_awdyear%NOTFOUND
      THEN
         fnd_message.set_name('IGF', 'IGF_SL_AWD_YR_NOT_FOUND');
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         fnd_file.new_line(fnd_file.log, 1);
         CLOSE cur_awdyear;
         RETURN;
      ELSE
         CLOSE cur_awdyear;
      END IF;

      OPEN cur_get_fund_type(p_fund_id);
      FETCH cur_get_fund_type INTO get_fund_type_rec;

      IF cur_get_fund_type%NOTFOUND
      THEN
         fnd_message.set_name('IGF', 'IGF_AW_NO_SUCH_FUND');
         fnd_message.set_token('FUND_ID', p_fund_id);
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         fnd_file.new_line(fnd_file.log, 1);
         CLOSE cur_get_fund_type;
         RETURN;
      ELSE
         CLOSE cur_get_fund_type;
      END IF;

      log_parameters(
         awdyear_rec.alternate_code, p_fund_id, p_base_id, p_loan_id,
         p_trans_type, p_per_grp_id, get_fund_type_rec.fed_fund_code
      );

      -- Check for valid input combinations of Parameters

      -- Award year and Fund Id cannot be NULL

      IF l_ci_cal_type IS NULL OR l_ci_sequence_number IS NULL
         OR p_fund_id IS NULL
      THEN
         fnd_message.set_name('IGF', 'IGF_SL_REL_DISB_PARAM_EX');
         fnd_file.new_line(fnd_file.log, 2);
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         fnd_file.new_line(fnd_file.log, 2);
         RAISE param_exception;
      END IF;

      -- Person ID Group would not pick up any value in case the Person Number or Loan Number is populated

      IF p_per_grp_id IS NOT NULL
      THEN
         -- If Person ID Group is specified then cannot specify values for Person Number or Loan number
         IF p_base_id IS NOT NULL OR p_loan_id IS NOT NULL
         THEN
            fnd_message.set_name('IGF', 'IGF_SL_REL_DISB_PARAM_EX');
            fnd_file.new_line(fnd_file.log, 2);
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            fnd_file.new_line(fnd_file.log, 2);
            RAISE param_exception;
         END IF;
      END IF;

      IF p_per_grp_id IS NOT NULL
      THEN
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.string(
               fnd_log.level_statement,
               'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
               'Starting to process person group ' || p_per_grp_id
            );
         END IF;

         --- If person id group is specified then Get all the persons in person group
         --Bug #5021084
         l_list := igf_ap_ss_pkg.get_pid(p_per_grp_id, l_status, lv_group_type);

         --Bug #5021084. Passing Group ID if the group type is STATIC.
         IF lv_group_type = 'STATIC' THEN
            OPEN cur_per_grp FOR ' SELECT party_id FROM hz_parties WHERE party_id IN ('
                                  || l_list || ') ' USING p_per_grp_id;
         ELSIF lv_group_type = 'DYNAMIC' THEN
            OPEN cur_per_grp FOR ' SELECT party_id FROM hz_parties WHERE party_id IN ('
                                  || l_list || ') ';
         END IF;

         FETCH cur_per_grp INTO l_person_id;

         -- If no student found in Person Group
         IF cur_per_grp%NOTFOUND
         THEN
            CLOSE cur_per_grp;
            fnd_message.set_name('IGF', 'IGF_DB_NO_PER_GRP');
            fnd_file.put_line(fnd_file.log, RPAD(' ', 5) || fnd_message.get);

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.string(
                  fnd_log.level_statement,
                  'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                  'No persons in group ' || p_per_grp_id
               );
            END IF;
         ELSE
            -- IF cur_per_grp%FOUND THEN
            fnd_message.set_name('IGF', 'IGF_DB_PROCESS_PER_GRP');
            -- Processing Disbursements for Person Group
            OPEN cur_per_grp_name(p_per_grp_id);
            FETCH cur_per_grp_name INTO per_grp_rec;
            CLOSE cur_per_grp_name;
            fnd_file.put_line(
               fnd_file.log, RPAD(' ', 5) || fnd_message.get || '  '
                             || per_grp_rec.group_cd
            );

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.string(
                  fnd_log.level_statement,
                  'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                  'Processing for ' || p_per_grp_id
               );
            END IF;

            -- Check if the person exists in FA.

            LOOP
               l_base_id := 0;
               l_person_number := NULL;
               l_person_number := per_in_fa(
                                     l_person_id, l_ci_cal_type,
                                     l_ci_sequence_number, l_base_id
                                  );

               IF l_person_number IS NOT NULL
               THEN
                  IF l_base_id IS NOT NULL
                  THEN
                     fnd_message.set_name('IGF', 'IGF_AW_PROC_STUD');
                     fnd_message.set_token('STDNT', l_person_number);
                     fnd_file.put_line(
                        fnd_file.log, RPAD(' ', 10) || fnd_message.get
                     );

                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                           'Processing student ' || l_person_number
                        );
                     END IF;

                     --
                     -- Check for Academic Holds, only if con job is run
                     --
                     IF igf_aw_gen_005.get_stud_hold_effect(
                           'D', igf_gr_gen.get_person_id(l_base_id)
                        ) = 'F'
                     THEN
                        fnd_message.set_name(
                           'IGF', 'IGF_SL_DISB_FUND_HOLD_FAIL'
                        );
                        fnd_file.put_line(
                           fnd_file.log, RPAD(' ', 10) || fnd_message.get
                        );

                        IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.string(
                              fnd_log.level_statement,
                              'igf.plsql.igf_sl_rel_disb.disb_process.debug',
                              'get_stud_hold_effect returned F'
                           );
                        END IF;
                     ELSE
                        IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.string(
                              fnd_log.level_statement,
                              'igf.plsql.igf_sl_rel_disb.disb_process.debug',
                              'calling process_student for base_id 1'
                              || l_base_id
                           );
                        END IF;

                        process_student(
                           p_base_id => l_base_id, p_result => l_result,
                           p_fund_id => p_fund_id, p_award_id => NULL,
                           p_loan_id => NULL, p_disb_num => NULL,
                           p_trans_type => p_trans_type
                        );
                     END IF;

                     fnd_message.set_name('IGF', 'IGF_DB_END_PROC_PER'); -- if hold exsist
                     -- End of processing for person number
                     fnd_message.set_token('PER_NUM', l_person_number);
                     fnd_file.put_line(
                        fnd_file.log, RPAD(' ', 10) || fnd_message.get
                     );
                     fnd_file.new_line(fnd_file.log, 1);

                     IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                           'end processing ' || l_person_number
                        );
                     END IF;
                  ELSE -- l_base_id IS NULL THEN
                       -- log a message and skip this person since the person doesnt exsist in FA
                     fnd_message.set_name('IGF', 'IGF_GR_LI_PER_INVALID');
                     fnd_message.set_token('PERSON_NUMBER', l_person_number);
                     fnd_message.set_token(
                        'AWD_YR', awdyear_rec.alternate_code
                     );
                     -- Person PER_NUM does not exist in FA
                     fnd_file.put_line(
                        fnd_file.log, RPAD(' ', 10) || fnd_message.get
                     );

                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                           igf_gr_gen.get_per_num_oss(l_person_id)
                           || ' not in FA'
                        );
                     END IF;
                  END IF; -- (IF l_base_id IS NOT NULL)
               ELSE -- IF l_person_number IS NULL THEN
                  fnd_message.set_name('IGF', 'IGF_AP_PE_NOT_EXIST');
                  fnd_file.put_line(
                     fnd_file.log, RPAD(' ', 5) || fnd_message.get
                  );
               END IF; ---- (IF l_person_number IS NOT NULL)

               FETCH cur_per_grp INTO l_person_id;
               EXIT WHEN cur_per_grp%NOTFOUND;
            END LOOP;

            CLOSE cur_per_grp;
         END IF; -- (IF cur_per_grp%NOTFOUND)
      ELSE -- IF  p_per_grp_id IS  NULL
           -- we need to check if person no is provided or not. then we will process for that student otherwise for award
           --
         IF p_base_id IS NULL
         THEN
            --  if person no is not given then process for all the students whom that award is given.

            IF p_fund_id IS NOT NULL
            THEN
               -- Get all the Students for which the Award is given
               OPEN cur_award_std(p_fund_id);
               FETCH cur_award_std INTO award_std_rec;

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.string(
                     fnd_log.level_statement,
                     'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                     'starting processing for fund_id ' || p_fund_id
                  );
               END IF;

               IF cur_award_std%NOTFOUND
               THEN
                  CLOSE cur_award_std;
                  fnd_message.set_name('IGF', 'IGF_DB_NO_AWARDS');
                  fnd_message.set_token('FDESC', get_fund_desc(p_fund_id));
                  -- No Awards found for this Fund <fund code > : < fund desc >
                  fnd_file.put_line(
                     fnd_file.log, RPAD(' ', 5) || fnd_message.get
                  );

                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                        'No award for fund ' || get_fund_desc(p_fund_id)
                     );
                  END IF;
               ELSE
                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                        'award_std_rec.fed_fund_code:'
                        || award_std_rec.fed_fund_code
                     );
                  END IF;

                  IF award_std_rec.fed_fund_code NOT IN
                                 ('FWS', 'SPNSR', 'PRK')
                  THEN
                     -- process only for PELL and Direct Loans.
                     LOOP
                        IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.string(
                              fnd_log.level_statement,
                              'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                              'award_std_rec.base_id: '
                              || award_std_rec.base_id
                           );
                        END IF;

                        l_person_number := igf_gr_gen.get_per_num(
                                              award_std_rec.base_id
                                           );

                        IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.string(
                              fnd_log.level_statement,
                              'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                              'l_person_number:' || l_person_number
                           );
                        END IF;

                        fnd_message.set_name('IGF', 'IGF_AW_PROC_STUD');
                        fnd_message.set_token('STDNT', l_person_number);
                        fnd_file.put_line(
                           fnd_file.log, RPAD(' ', 10) || fnd_message.get
                        );

                        IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.string(
                              fnd_log.level_statement,
                              'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                              'starting processing ' || l_person_number
                           );
                        END IF;

                        --
                        -- Check for Academic Holds, only if con job is run
                        --
                        IF igf_aw_gen_005.get_stud_hold_effect(
                              'D',
                              igf_gr_gen.get_person_id(award_std_rec.base_id)
                           ) = 'F'
                        THEN
                           fnd_message.set_name(
                              'IGF', 'IGF_SL_DISB_FUND_HOLD_FAIL'
                           );
                           fnd_file.put_line(
                              fnd_file.log, RPAD(' ', 10) || fnd_message.get
                           );

                           IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                           THEN
                              fnd_log.string(
                                 fnd_log.level_statement,
                                 'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                                 'get_stud_hold_effect returned F'
                              );
                           END IF;
                        ELSE
                           IF p_loan_id IS NULL
                           THEN
                              IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                              THEN
                                 fnd_log.string(
                                    fnd_log.level_statement,
                                    'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                                    'calling process_student for base_id 2'
                                    || award_std_rec.base_id
                                    || 'wihtout loan_id'
                                 );
                              END IF;

                              process_student(
                                 p_base_id => award_std_rec.base_id,
                                 p_result => l_result, p_fund_id => p_fund_id,
                                 p_award_id => NULL, p_loan_id => NULL,
                                 p_disb_num => NULL,
                                 p_trans_type => p_trans_type
                              );
                           ELSE
                              -- extract award id from loan_id
                              OPEN cur_get_awd_id(p_loan_id);
                              FETCH cur_get_awd_id INTO get_awd_id_rec;
                              CLOSE cur_get_awd_id;

                              IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                              THEN
                                 fnd_log.string(
                                    fnd_log.level_statement,
                                    'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                                    'calling process_student for base_id 3'
                                    || award_std_rec.base_id || 'wiht loan_id'
                                    || p_loan_id
                                 );
                              END IF;

                              process_student(
                                 p_base_id => award_std_rec.base_id,
                                 p_result => l_result, p_fund_id => p_fund_id,
                                 p_award_id => get_awd_id_rec.award_id,
                                 p_loan_id => p_loan_id, p_disb_num => NULL,
                                 p_trans_type => p_trans_type
                              );
                           END IF;
                        END IF;

                        fnd_message.set_name('IGF', 'IGF_DB_END_PROC_PER');
                        -- End of processing for person number
                        fnd_message.set_token('PER_NUM', l_person_number);
                        fnd_file.put_line(
                           fnd_file.log, RPAD(' ', 10) || fnd_message.get
                        );
                        fnd_file.new_line(fnd_file.log, 1);

                        IF fnd_log.level_statement >=
                                               fnd_log.g_current_runtime_level
                        THEN
                           fnd_log.string(
                              fnd_log.level_statement,
                              'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                              'end processing ' || l_person_number
                           );
                        END IF;

                        FETCH cur_award_std INTO award_std_rec;
                        EXIT WHEN cur_award_std%NOTFOUND;
                     END LOOP;

                     CLOSE cur_award_std;
                  ELSE -- Fund code is not PELL or Direct Loan so raise an error
                     fnd_message.set_name('IGF', 'IGF_SL_ONLY_PELL_LOANS');
                     fnd_file.put_line(
                        fnd_file.log, RPAD(' ', 10) || fnd_message.get
                     );

                     IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                     THEN
                        fnd_log.string(
                           fnd_log.level_statement,
                           'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                           'unsupported fund type '
                           || award_std_rec.fed_fund_code
                        );
                     END IF;
                  END IF; -- (IF award_std_rec.fed_fund_code NOT IN ('FWS','SPNSR','PRK'))
               END IF; -- (IF cur_award_std%NOTFOUND)
            ELSE
               -- Fund Id is NULL so raise error
               fnd_message.set_name('IGF', 'IGF_SL_REL_DISB_PARAM_EX');
               fnd_file.new_line(fnd_file.log, 2);
               fnd_file.put_line(fnd_file.log, fnd_message.get);
               fnd_file.new_line(fnd_file.log, 2);
               RAISE param_exception;
            END IF; -- (IF p_fund_id IS NOT NULL)
         ELSE
            -- i.e, base_id is specified therefore process for the particular student only

            l_person_number := igf_gr_gen.get_per_num(p_base_id);
            fnd_message.set_name('IGF', 'IGF_AW_PROC_STUD');
            fnd_message.set_token('STDNT', l_person_number);
            fnd_file.put_line(fnd_file.log, RPAD(' ', 10) || fnd_message.get);

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.string(
                  fnd_log.level_statement,
                  'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                  'Starting processing single student ' || l_person_number
               );
            END IF;

            --
            -- Check for Academic Holds, only if con job is run
            --

            IF igf_aw_gen_005.get_stud_hold_effect(
                  'D', igf_gr_gen.get_person_id(p_base_id)
               ) = 'F'
            THEN
               fnd_message.set_name('IGF', 'IGF_SL_DISB_FUND_HOLD_FAIL');
               fnd_file.put_line(
                  fnd_file.log, RPAD(' ', 10) || fnd_message.get
               );

               IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
               THEN
                  fnd_log.string(
                     fnd_log.level_statement,
                     'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                     'get_stud_hold_effect returned F'
                  );
               END IF;
            ELSE
               IF p_loan_id IS NULL
               THEN
                  process_student(
                     p_base_id => p_base_id, p_result => l_result,
                     p_fund_id => p_fund_id, p_award_id => NULL,
                     p_loan_id => NULL, p_disb_num => NULL,
                     p_trans_type => p_trans_type
                  );

                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.disb_process.debug',
                        'calling process_student for base_id 4' || p_base_id
                        || 'without loan_id'
                     );
                  END IF;
               ELSE
                  -- extract award id from loan_id
                  OPEN cur_get_awd_id(p_loan_id);
                  FETCH cur_get_awd_id INTO get_awd_id_rec;
                  CLOSE cur_get_awd_id;

                  IF fnd_log.level_statement >=
                                              fnd_log.g_current_runtime_level
                  THEN
                     fnd_log.string(
                        fnd_log.level_statement,
                        'igf.plsql.igf_sl_rel_disb.disb_process.debug',
                        'calling process_student for base_id 5' || p_base_id
                        || 'with loan_id' || p_loan_id
                     );
                  END IF;

                  process_student(
                     p_base_id => p_base_id, p_result => l_result,
                     p_fund_id => p_fund_id,
                     p_award_id => get_awd_id_rec.award_id,
                     p_loan_id => p_loan_id, p_disb_num => NULL,
                     p_trans_type => p_trans_type
                  );
               END IF;
            END IF;

            fnd_message.set_name('IGF', 'IGF_DB_END_PROC_PER');
            -- End of processing for person number
            fnd_message.set_token('PER_NUM', l_person_number);
            fnd_file.put_line(fnd_file.log, RPAD(' ', 10) || fnd_message.get);
            fnd_file.new_line(fnd_file.log, 1);

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
            THEN
               fnd_log.string(
                  fnd_log.level_statement,
                  'igf.plsql.igf_sl_rel_disb.rel_disb_process.debug',
                  'end processing ' || l_person_number
               );
            END IF;
         END IF; -- (IF  p_base_id IS NULL)
      END IF; -- (p_per_grp_id IS NOT NULL)


--- more

      COMMIT;
   EXCEPTION
      WHEN param_exception
      THEN
         ROLLBACK;
         p_retcode := 2;
         fnd_message.set_name('IGF', 'IGF_SL_REL_DISB_PARAM_EX');
         igs_ge_msg_stack.ADD;
         igs_ge_msg_stack.conc_exception_hndl;
      WHEN app_exception.record_lock_exception
      THEN
         ROLLBACK;
         p_retcode := 2;
         fnd_message.set_name('IGF', 'IGF_GE_LOCK_ERROR');
         igs_ge_msg_stack.ADD;
         p_errbuf := fnd_message.get;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_retcode := 2;
         fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.ADD;
         p_errbuf := fnd_message.get;
   END rel_disb_process;
END igf_sl_rel_disb;

/
