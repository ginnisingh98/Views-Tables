--------------------------------------------------------
--  DDL for Package Body IGF_SL_AWARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_AWARD" AS
/* $Header: IGFSL13B.pls 120.5 2006/08/10 16:16:24 museshad ship $ */

--
----------------------------------------------------------------------------------------
-- Created By : venagara
-- Date Created On : 2000/12/12
-- Purpose :
-- Know limitations, enhancements or remarks
-- Change History
----------------------------------------------------------------------------------------
--   Who          When            What
----------------------------------------------------------------------------------------
--   museshad     10-Aug-2006     Bug 5337555. Build FA 163. TBH Impact.
----------------------------------------------------------------------------------------
--   museshad     20-Sep-2005     Bug 3943742.
--                                When the Preferred lender relationship code
--                                has an override, it was not being considered.
--                                Fixed this issue.
----------------------------------------------------------------------------------------
--   museshad     06-May-2005     Bug# 4346258 Modified the entire logic in the function
--                                'get_loan_cl_version()' so that it arrives at the
--                                correct CL version#
----------------------------------------------------------------------------------------
--   mnade        8-Feb-2005      Bug 4127250 chk_disb_date call changed to pass the dates being set
--                                for checking if that is covering all the disbursements.
----------------------------------------------------------------------------------------
--   pssahni      20-Dec-2004     Bug #4059136 Allow DML operations if loan status is accepted
--------------------------------------------------------------------------------------------
--   ridas        14-Sep-2004     bug 3847105 - Log message in case the Loan is created using Default Lender setup
--                                despite of Preferred Lender as the Preferred Lender is not setup for the Award Year.
------------------------------------------------------------------------

--   veramach    July 2004        FA 151 HR Integration (bug#3709292)
--                                Impacts of obsoleting columns from igf_aw_awd_disb_all
---------------------------------------------------------------------------------
--   sjadhav      18-Feb-2004     Modified get_loan_fee1 call so that
--                                pick_setup is invoked only for FFELP/ALT
--                                Loan calculations
----------------------------------------------------------------------------------------
--   veramach     1-NOV-2003      FA 125 Multiple Distr Methods
--                                Changed calll to igf_aw_awd_disb_pkg.update_row to
--                                reflect the addition of attendance_type_code
----------------------------------------------------------------------------------------
--   sjalasut     30 OCT 03       Uncommented the Code to get associated org
--                                for the Person as part of FA126 Multiple FA
--                                Office Build. Bug 3102439. Also added local
--                                variable declarations that are out parameters
----------------------------------------------------------------------------------------
--   sjadhav      8-Oct-2003      Bug 3104228 FA 122
--                                added cursor find lender
--                                corrected upd lock process
----------------------------------------------------------------------------------------
--   bkkumar      07-oct-2003     Bug 3104228 Used the global variables g_rel_code,
--                                g_party_id instead of calling pick_setup everytime.
--                                Also removed the select_org procedure
----------------------------------------------------------------------------------------
--   bkkumar      30-sep-2003     FA 122 Loan Enhancents
--                                Added new function get_cl_auto_late_ind,
--                                pick_setup and changed  get_loan_fee1,get_loan_fee2,
--                                get_cl_hold_rel_ind, recalc_fees
----------------------------------------------------------------------------------------
--


  l_dl_fee1_staf  igf_sl_dl_setup.orig_fee_perct_stafford%TYPE;
  l_dl_fee1_plus  igf_sl_dl_setup.orig_fee_perct_plus%TYPE;
  l_dl_int_rebate igf_sl_dl_setup.int_rebate%TYPE;


  l_cl_fee1       igf_sl_cl_setup.est_orig_fee_perct%TYPE;
  l_cl_alt_fee1   igf_sl_cl_setup.est_alt_orig_fee_perct%TYPE;

  CURSOR c_dlsetup (p_ci_cal_type    igs_ca_inst_all.cal_type%TYPE,
                    p_ci_seq_num     igs_ca_inst_all.sequence_number%TYPE)IS
  SELECT orig_fee_perct_stafford,
         orig_fee_perct_plus,
         int_rebate
  FROM   igf_sl_dl_setup
  WHERE  ci_cal_type        = p_ci_cal_type
  AND    ci_sequence_number = p_ci_seq_num;

  CURSOR c_get_fed_fund_code (
                              cp_award_id igf_sl_loans.award_id%TYPE
                             )
  IS
  SELECT fed_fund_code
  FROM   igf_aw_award awd,
         igf_aw_fund_mast fundmast,
         igf_aw_fund_cat fundcat
  WHERE  awd.award_id = cp_award_id
  AND    awd.fund_id = fundmast.fund_id
  AND    fundmast.fund_code = fundcat.fund_code;

FUNCTION get_cl_hold_rel_ind(p_fed_fund_code  igf_aw_fund_cat.fed_fund_code%TYPE,
                             p_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                             p_ci_seq_num     igs_ca_inst.sequence_number%TYPE,
                             p_base_id        igf_aw_award_all.base_id%TYPE,
                             p_alt_rel_code   igf_aw_fund_cat_all.alt_rel_code%TYPE)
RETURN VARCHAR2
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  bkkumar        02-04-04         FACR116 - Added the paramter p_alt_rel_code
  bkkumar        30-sep-2003      FA 122 Loan Enhancements
                                  Added p_base_id and call to
                                  Pick_setup
  (reverse chronological order - newest change first)
  ***************************************************************/
  l_hold_rel_ind igf_sl_cl_setup.hold_rel_ind%TYPE;
  l_rel_code      igf_sl_cl_setup.relationship_cd%TYPE;
  l_party_id      igf_sl_cl_setup.party_id%TYPE;
  l_person_id     igf_sl_cl_pref_lenders.person_id%TYPE;
  CURSOR c_clsetup(
                    cp_rel_code      igf_sl_cl_setup.relationship_cd%TYPE,
                    cp_party_id      igf_sl_cl_setup.party_id%TYPE
                   ) IS
  SELECT hold_rel_ind FROM igf_sl_cl_setup
  WHERE ci_cal_type        = p_ci_cal_type
  AND   ci_sequence_number = p_ci_seq_num
  AND   NVL(relationship_cd,'*') = cp_rel_code
  AND   NVL(party_id,-1000) = NVL(cp_party_id,-1000);
BEGIN

  l_rel_code   := NULL;
  l_party_id   := NULL;
  l_person_id  := NULL;

  -- pick the values from the setup base on the base_id
  igf_sl_award.pick_setup(p_base_id,p_ci_cal_type,p_ci_seq_num,l_rel_code,l_person_id,l_party_id,p_alt_rel_code);
  g_rel_code  := l_rel_code;
  g_party_id  := l_party_id;
   -- put debug log messages
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_award.get_cl_hold_rel_ind.debug','The value pick_setup returned rel_code: '||l_rel_code);
  END IF;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_award.get_cl_hold_rel_ind.debug','The value pick_setup returned party_id: '||l_party_id);
  END IF;


  IF igf_sl_gen.chk_cl_fed_fund_code(p_fed_fund_code) = 'TRUE' THEN
    OPEN c_clsetup(g_rel_code,g_party_id);
    FETCH c_clsetup INTO l_hold_rel_ind;
    CLOSE c_clsetup;
  END IF;

  RETURN l_hold_rel_ind;

  EXCEPTION WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_award.get_cl_hold_rel_ind.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_AWARD.GET_CL_HOLD_REL_IND');
    igs_ge_msg_stack.conc_exception_hndl;
    app_exception.raise_exception;

END get_cl_hold_rel_ind;

-- Created as part of FA 122 Loans Enhancements
FUNCTION get_cl_auto_late_ind(p_fed_fund_code  igf_aw_fund_cat.fed_fund_code%TYPE,
                              p_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                              p_ci_seq_num     igs_ca_inst.sequence_number%TYPE,
                              p_base_id        igf_aw_award_all.base_id%TYPE,
                              p_alt_rel_code   igf_aw_fund_cat_all.alt_rel_code%TYPE)
RETURN VARCHAR2
AS
  /*************************************************************
  Created By : bkkumar
  Date Created On : 2003/09/30
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  bkkumar        02-04-04         FACR116 - Added the paramter p_alt_rel_code
  bkkumar        30-sep-2003      FA 122 Loan Enhancements
                                  To get the auto_late_disb_ind.

  (reverse chronological order - newest change first)
  ***************************************************************/

  l_auto_late_disb_ind igf_sl_cl_setup.auto_late_disb_ind%TYPE;
  l_rel_code      igf_sl_cl_setup.relationship_cd%TYPE;
  l_party_id      igf_sl_cl_setup.party_id%TYPE;
  l_person_id     igf_sl_cl_pref_lenders.person_id%TYPE;
  CURSOR c_clsetup(
                    cp_rel_code      igf_sl_cl_setup.relationship_cd%TYPE,
                    cp_party_id      igf_sl_cl_setup.party_id%TYPE
                   ) IS
  SELECT  auto_late_disb_ind
  FROM igf_sl_cl_setup
  WHERE ci_cal_type        = p_ci_cal_type
  AND   ci_sequence_number = p_ci_seq_num
  AND   NVL(relationship_cd,'*') = cp_rel_code
  AND   NVL(party_id,-1000) = NVL(cp_party_id,-1000);
BEGIN

  l_rel_code := NULL;
  l_party_id := NULL;
  l_person_id  := NULL;

  --
  -- pick the values from the setup base on the base_id
  --

  igf_sl_award.pick_setup(p_base_id,p_ci_cal_type,p_ci_seq_num,l_rel_code,l_person_id,l_party_id,p_alt_rel_code);
  g_rel_code := l_rel_code ;
  g_party_id := l_party_id;
  --
  -- put debug log messages
  --
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_award.get_cl_auto_late_ind.debug','The value pick_setup returned rel_code: '||l_rel_code);
  END IF;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_award.get_cl_auto_late_ind.debug','The value pick_setup returned party_id: '||l_party_id);
  END IF;

  IF igf_sl_gen.chk_cl_fed_fund_code(p_fed_fund_code) = 'TRUE' THEN
    OPEN c_clsetup(g_rel_code,g_party_id);
    FETCH c_clsetup INTO l_auto_late_disb_ind;
    CLOSE c_clsetup;
  END IF;

  RETURN l_auto_late_disb_ind;

  EXCEPTION WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_award.get_cl_auto_late_ind.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_AWARD.GET_CL_AUTO_LATE_IND');
    igs_ge_msg_stack.conc_exception_hndl;
    app_exception.raise_exception;

END get_cl_auto_late_ind;

FUNCTION get_loan_fee1(p_fed_fund_code  igf_aw_fund_cat.fed_fund_code%TYPE,
                       p_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                       p_ci_seq_num     igs_ca_inst.sequence_number%TYPE,
                       p_base_id        igf_aw_award_all.base_id%TYPE,
                       p_rel_code       VARCHAR2,
                       p_alt_rel_code   igf_aw_fund_cat_all.alt_rel_code%TYPE)
RETURN NUMBER
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who              When              What
  bkkumar          02-04-04         Added the paramter p_alt_rel_code
  akonatha         08-MAY-2001       Added Functionality to check for alternate loans
  bkkumar          30-sep-2003       FA 122 Loan Enhancements
                                     Added p_base_id and call to
                                     Pick_setup
  (reverse chronological order - newest change first)
  ***************************************************************/


  CURSOR c_clsetup (
                    cp_rel_code      igf_sl_cl_setup.relationship_cd%TYPE,
                    cp_party_id      igf_sl_cl_setup.party_id%TYPE
                   )
  IS
  SELECT est_orig_fee_perct,
         est_alt_orig_fee_perct
  FROM  igf_sl_cl_setup
  WHERE ci_cal_type        = p_ci_cal_type
  AND   ci_sequence_number = p_ci_seq_num
  AND   NVL(relationship_cd,'*') = cp_rel_code
  AND   NVL(party_id,-1000) = NVL(cp_party_id,-1000);

  l_rel_code      igf_sl_cl_setup.relationship_cd%TYPE;
  l_party_id      igf_sl_cl_setup.party_id%TYPE;
  l_person_id     igf_sl_cl_pref_lenders.person_id%TYPE;

BEGIN

  l_dl_int_rebate := NULL;

  IF igf_sl_gen.chk_dl_fed_fund_code(p_fed_fund_code) = 'TRUE' THEN

    OPEN c_dlsetup(p_ci_cal_type,p_ci_seq_num);
    FETCH c_dlsetup INTO l_dl_fee1_staf, l_dl_fee1_plus,l_dl_int_rebate;
    CLOSE c_dlsetup;

    l_dl_int_rebate := NVL(l_dl_int_rebate,0);

    IF igf_sl_gen.chk_dl_stafford(p_fed_fund_code) = 'TRUE' THEN
        RETURN  NVL(l_dl_fee1_staf,0);
    ELSIF igf_sl_gen.chk_dl_plus(p_fed_fund_code) = 'TRUE' THEN
        RETURN  NVL(l_dl_fee1_plus,0);
    END IF;

  ELSIF igf_sl_gen.chk_cl_alt(p_fed_fund_code) = 'TRUE' THEN

    l_rel_code   := NULL;
    l_party_id   := NULL;
    l_person_id  := NULL;
    --
    -- call this only if the p_rel_code param is NULL
    --
    IF p_rel_code IS NULL THEN
       pick_setup(p_base_id,p_ci_cal_type,p_ci_seq_num,l_rel_code,l_person_id,l_party_id,p_alt_rel_code);
       g_rel_code := l_rel_code;
    ELSE
       g_rel_code := p_rel_code;
    END IF;

    g_party_id := l_party_id;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_award.get_loan_fee1.debug','The value pick_setup returned rel_code: '||l_rel_code);
    END IF;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_award.get_loan_fee1.debug','The value pick_setup returned party_id: '||l_party_id);
    END IF;

    OPEN c_clsetup(g_rel_code,g_party_id);
    FETCH c_clsetup INTO l_cl_fee1,l_cl_alt_fee1;
    CLOSE c_clsetup;

    RETURN NVL(l_cl_alt_fee1,0);

  ELSIF igf_sl_gen.chk_cl_fed_fund_code(p_fed_fund_code) = 'TRUE' THEN

    l_rel_code   := NULL;
    l_party_id   := NULL;
    l_person_id  := NULL;
    --
    -- call this only if the p_rel_code param is NULL
    --
    IF p_rel_code IS NULL THEN
       pick_setup(p_base_id,p_ci_cal_type,p_ci_seq_num,l_rel_code,l_person_id,l_party_id,p_alt_rel_code);
       g_rel_code := l_rel_code;
    ELSE
       g_rel_code := p_rel_code;
    END IF;

    g_party_id := l_party_id;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_award.get_loan_fee1.debug','The value pick_setup returned rel_code: '||l_rel_code);
    END IF;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_award.get_loan_fee1.debug','The value pick_setup returned party_id: '||l_party_id);
    END IF;

    OPEN c_clsetup(g_rel_code,g_party_id);
    FETCH c_clsetup INTO l_cl_fee1,l_cl_alt_fee1;
    CLOSE c_clsetup;

    RETURN NVL(l_cl_fee1,0);

  END IF;

  RETURN 0;
  EXCEPTION WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_award.get_loan_fee1.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_AWARD.GET_LOAN_FEE1');
    igs_ge_msg_stack.conc_exception_hndl;
    app_exception.raise_exception;

END get_loan_fee1;



FUNCTION get_loan_fee2(p_fed_fund_code  igf_aw_fund_cat.fed_fund_code%TYPE,
                       p_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                       p_ci_seq_num     igs_ca_inst.sequence_number%TYPE,
                       p_base_id        igf_aw_award_all.base_id%TYPE,
                       p_rel_code       VARCHAR2,
                       p_alt_rel_code   igf_aw_fund_cat_all.alt_rel_code%TYPE)
RETURN NUMBER
AS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/20
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who              When             What
  bkkumar          02-04-04         Added the paramter p_alt_rel_code
  akonatha         08-MAY-2001      Added Functionality to check for alternate loans
  bkkumar          30-sep-2003      FA 122 Loan Enhancements
                                    Added p_base_id and call to
                                    Pick_setup
  (reverse chronological order - newest change first)
  ***************************************************************/

  l_cl_fee2  igf_sl_cl_setup.est_guarnt_fee_perct%TYPE;
  l_cl_alt_fee2   igf_sl_cl_setup.est_alt_orig_fee_perct%TYPE;

  CURSOR c_clsetup  (
                    cp_rel_code      igf_sl_cl_setup.relationship_cd%TYPE,
                    cp_party_id      igf_sl_cl_setup.party_id%TYPE
                   )
  IS
  SELECT est_guarnt_fee_perct,
        est_alt_guarnt_fee_perct
  FROM  igf_sl_cl_setup
  WHERE ci_cal_type        = p_ci_cal_type
  AND   ci_sequence_number = p_ci_seq_num
  AND   NVL(relationship_cd,'*') = cp_rel_code
  AND   NVL(party_id,-1000) = NVL(cp_party_id,-1000);

  l_rel_code      igf_sl_cl_setup.relationship_cd%TYPE;
  l_party_id      igf_sl_cl_setup.party_id%TYPE;
  l_person_id     igf_sl_cl_pref_lenders.person_id%TYPE;

BEGIN

   l_rel_code := NULL;
   l_party_id := NULL;
   l_person_id  := NULL;

   --
   -- pick the values from the setup base on the base_id
   --
   --
   -- call this only if the p_rel_code param is NULL
   --

   IF p_rel_code IS NULL THEN
     pick_setup(p_base_id,p_ci_cal_type,p_ci_seq_num,l_rel_code,l_person_id,l_party_id,p_alt_rel_code);
     g_rel_code := l_rel_code;
   ELSE
     g_rel_code := p_rel_code;
   END IF;

   g_party_id := l_party_id;
   --
   -- put debug log messages
   --
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_award.get_loan_fee2.debug','The value pick_setup returned rel_code: '||l_rel_code);
   END IF;
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_award.get_loan_fee2.debug','The value pick_setup returned party_id: '||l_party_id);
   END IF;


   IF igf_sl_gen.chk_cl_alt(p_fed_fund_code) = 'TRUE' THEN

    OPEN c_clsetup(g_rel_code,g_party_id);
    FETCH c_clsetup INTO l_cl_fee2,l_cl_alt_fee2;
    CLOSE c_clsetup;
    RETURN NVL(l_cl_alt_fee2,0);

   ELSIF igf_sl_gen.chk_cl_fed_fund_code(p_fed_fund_code) = 'TRUE' THEN

    OPEN c_clsetup(g_rel_code,g_party_id);
    FETCH c_clsetup INTO l_cl_fee2,l_cl_alt_fee2;
    CLOSE c_clsetup;
    RETURN NVL(l_cl_fee2,0);
  END IF;
 RETURN 0;

EXCEPTION WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_award.get_loan_fee2.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_AWARD.GET_LOAN_FEE2');
    igs_ge_msg_stack.conc_exception_hndl;
    app_exception.raise_exception;
END get_loan_fee2;


FUNCTION chk_disb_date(p_award_id               igf_sl_loans.award_id%TYPE,
                       p_loan_per_begin_date    igf_sl_loans_all.loan_per_begin_date%TYPE,
                       p_loan_per_end_date      igf_sl_loans_all.loan_per_end_date%TYPE
)
RETURN VARCHAR2 AS
  /* -------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smadathi       14-OCT-2004     Bug 3416936.Changes as per TD
  ------------------------------------------------------------------*/

  CURSOR c_loans (cp_n_award_id             igf_aw_award_all.award_id%TYPE,
                  cp_loan_per_begin_date    igf_sl_loans_all.loan_per_begin_date%TYPE,
                  cp_loan_per_end_date      igf_sl_loans_all.loan_per_end_date%TYPE) IS
  SELECT  disb.award_id
         ,disb.disb_date
         ,disb.disb_num
  FROM  igf_aw_awd_disb_all disb
       ,igf_sl_loans_all    loans
  WHERE loans.award_id=disb.award_id
  AND   loans.award_id = cp_n_award_id
  AND   ( disb.disb_date  < NVL(cp_loan_per_begin_date, loans.loan_per_begin_date)
        OR disb.disb_date > NVL(cp_loan_per_end_date, loans.loan_per_end_date));

  l_v_disb_num_desc  igs_lookup_values.meaning%TYPE;
  l_v_disb_date_desc igs_lookup_values.meaning%TYPE;
  l_v_return_val      VARCHAR2(4000);
BEGIN
  l_v_return_val := NULL;
  FOR  rec_c_loans IN c_loans (cp_n_award_id           => p_award_id,
                               cp_loan_per_begin_date  => p_loan_per_begin_date,
                               cp_loan_per_end_date    => p_loan_per_end_date)
  LOOP
    l_v_return_val :=  l_v_return_val ||l_v_disb_num_desc  || ' '|| rec_c_loans.disb_num ||' ';
    l_v_return_val :=  l_v_return_val ||l_v_disb_date_desc || ' '|| rec_c_loans.disb_date ;
  END LOOP;

  RETURN l_v_return_val;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_award.chk_disb_date.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_AWARD.CHK_DISB_DATE');
    igs_ge_msg_stack.conc_exception_hndl;
    app_exception.raise_exception;

END chk_disb_date;

-- FACR116 This function returns the alt_rel_code for the passed fund_Code.
FUNCTION get_alt_rel_code(p_fund_code  igf_aw_fund_cat_all.fund_code%TYPE)
RETURN VARCHAR2
AS
  l_alt_rel_code  igf_aw_fund_cat_all.alt_rel_code%TYPE;

  CURSOR c_rel_code (cp_fund_code igf_aw_fund_cat_all.fund_code%TYPE)
  IS
  SELECT alt_rel_code
  FROM   igf_aw_fund_cat_all
  WHERE fund_code  = cp_fund_code;

BEGIN

  l_alt_rel_code := NULL;
  OPEN c_rel_code(p_fund_code);
  FETCH c_rel_code INTO l_alt_rel_code;
  CLOSE c_rel_code;

  RETURN l_alt_rel_code;
EXCEPTION WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_award.get_alt_rel_code.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_AWARD.get_alt_rel_code');
    igs_ge_msg_stack.conc_exception_hndl;
    app_exception.raise_exception;

END get_alt_rel_code;

FUNCTION chk_loan_upd_lock(p_award_id  igf_sl_loans.award_id%TYPE)
RETURN VARCHAR2
AS
  /* -------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smadathi       14-OCT-2004     Bug 3416936.Changes as per TD
  ------------------------------------------------------------------*/
  l_loan_id         igf_sl_loans.loan_id%TYPE;
  l_loan_status     igf_sl_loans.loan_status%TYPE;
  l_loan_chg_status igf_sl_loans.loan_chg_status%TYPE;

  l_get_fed_fund_code  c_get_fed_fund_code%ROWTYPE;

  CURSOR c_loans (p_award_id NUMBER)IS
  SELECT  loan_id
         ,loan_status
         ,loan_chg_status
  FROM   igf_sl_loans
  WHERE  award_id = p_award_id;

  l_n_cl_version    igf_sl_cl_setup_all.cl_version%TYPE;

BEGIN

  -- If Loan Application Record is Created, then Check whether the
  -- Loan Status or Loan Change Status is SENT. If SENT, then should
  -- not allow to update anything in Awards Table. So, returning
  -- FALSE, saying do not allow update to awards.

    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_award.chk_loan_upd_lock.Award_id', p_award_id);
    END IF;

  OPEN c_loans(p_award_id);
  FETCH c_loans INTO l_loan_id, l_loan_status, l_loan_chg_status;
  CLOSE c_loans;

  IF l_loan_id IS NOT NULL THEN

    -- get the loan version for the input award id
    l_n_cl_version  := igf_sl_award.get_loan_cl_version(p_n_award_id => p_award_id);

    -- FA 122 Loan Enhancements BKKUMAR 30-SEP-2003
    -- first get the fund code to see if it is a DL Record or FFELP Loan Record
    l_get_fed_fund_code := NULL;
    OPEN  c_get_fed_fund_code(p_award_id);
    FETCH c_get_fed_fund_code INTO l_get_fed_fund_code;
    CLOSE c_get_fed_fund_code;
    IF igf_sl_gen.chk_dl_fed_fund_code(l_get_fed_fund_code.fed_fund_code) = 'TRUE' THEN
      IF l_loan_status = 'S' OR NVL(l_loan_chg_status,'*') = 'S' THEN
         RETURN 'TRUE';
      END IF;
      RETURN 'FALSE';
    -- for FFELP loans
    ELSIF igf_sl_gen.chk_cl_fed_fund_code(l_get_fed_fund_code.fed_fund_code) = 'TRUE' THEN
      -- if the common line release version is 'RELEASE-4' and either of loan
      -- status or loan change status in Sent or cancelled, NO DML operation should
      -- be allowed
      -- if the common line release version is 'RELEASE-5' and loan status
      -- Sent or cancelled, NO DML operation should be allowed
      -- Bug #4059136 Allow DML operations if loan status is accepted
      IF (l_n_cl_version = 'RELEASE-5') THEN
        IF (l_loan_status IN ('S','C')) THEN
          RETURN 'TRUE';
        END IF;
        RETURN 'FALSE';
      END IF;
      IF (l_n_cl_version = 'RELEASE-4') THEN
        IF (((l_loan_status = 'S') OR (NVL (l_loan_chg_status,'*') = 'S')) OR
            ((l_loan_status = 'C') OR  (NVL(l_loan_chg_status,'*') = 'C'))) THEN
          RETURN 'TRUE';
        END IF;
        RETURN 'FALSE';
      END IF;
    END IF;
  END IF;
  RETURN 'FALSE';
  EXCEPTION WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_award.chk_loan_upd_lock.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_AWARD.CHK_LOAN_UPD_LOCK');
    igs_ge_msg_stack.conc_exception_hndl;
    app_exception.raise_exception;

END chk_loan_upd_lock;

PROCEDURE  get_loan_amts(p_ci_cal_type   IN   igs_ca_inst_all.cal_type%TYPE,
                         p_ci_seq_num    IN   igs_ca_inst_all.sequence_number%TYPE,
                         p_fed_fund_code IN   igf_aw_fund_cat_all.fed_fund_code%TYPE,
                         p_gross_amt     IN   igf_aw_awd_disb_all.disb_gross_amt%TYPE,
                         p_rebate_amt    OUT NOCOPY  igf_aw_awd_disb_all.int_rebate_amt%TYPE,
                         p_loan_fee_amt  OUT NOCOPY  igf_aw_awd_disb_all.fee_1%TYPE,
                         p_net_amt       OUT NOCOPY  igf_aw_awd_disb_all.disb_net_amt%TYPE)
IS
-----------------------------------------------------------------------------------
--
-- sjadhav, Jan 23,2002
-- This procedure calculates loan fee amount, interest rebate amount
-- combined fee int rebate anount and disb net amonut for Direct Loans
-- This net amount does not include the Fee Paid
-----------------------------------------------------------------------------------


ln_comb_int_pct   igf_sl_dl_setup_all.int_rebate%TYPE;
ln_comb_int_amt   igf_aw_awd_disb_all.disb_net_amt%TYPE;

BEGIN

--
-- 1. Get Combined Fee/Int Reb Pctg and Amt
--

   ln_comb_int_pct :=  get_loan_fee1 (p_fed_fund_code,p_ci_cal_type,p_ci_seq_num) / 100  -
                       l_dl_int_rebate / 100;

   ln_comb_int_amt :=  TRUNC(ln_comb_int_pct * p_gross_amt);


--
-- 2.Get Net Disb Amount
--

   p_net_amt       :=  p_gross_amt - ln_comb_int_amt;


--
-- 3. Get Loan Fee Amount
--

   p_loan_fee_amt  :=  TRUNC (p_gross_amt * get_loan_fee1 (p_fed_fund_code,p_ci_cal_type,p_ci_seq_num) / 100 );

--
-- 4. Get Int Rebate Amount
--
   p_rebate_amt    :=  p_net_amt - ( p_gross_amt - p_loan_fee_amt);

 EXCEPTION WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_award.get_loan_amts.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_AWARD.GET_LOAN_AMTS');
    igs_ge_msg_stack.conc_exception_hndl;
    app_exception.raise_exception;


END  get_loan_amts;

PROCEDURE recalc_fees(
                       p_base_id           IN  igf_aw_award_all.base_id%TYPE,
                       p_cal_type          IN  igs_ca_inst_all.cal_type%TYPE,
                       p_sequence_number   IN  igs_ca_inst_all.sequence_number%TYPE,
                       p_rel_code          IN  igf_sl_cl_setup.relationship_cd%TYPE,
                       p_award_id          IN  igf_sl_loans.award_id%TYPE
                     )
IS
    /*************************************************************
    Created By : bkkumar
    Date Created On : 05-Sep-2003
    Purpose : FA 122 Loans Enhancements
    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    museshad        20-Sep-2005     Bug 3943742.
                                    When the Preferred lender relationship code
                                    has an override, it was not being considered.
                                    Fixed this by passing NULL (instead of the
                                    derived rel code) for p_rel_code to get_loan_fee1()
                                    and get_loan_fee2(). To get the override relationship
                                    code details from setup, the party_id of the Org Unit
                                    is needed. This does not get set if the relationship code
                                    is passed to get_loan_fee1() and get_loan_fee2(). Both
                                    get_loan_fee1() and get_loan_fee2() make an inherent
                                    call to pick_setup() to arrive at the correct rel code
                                    and party_id.
    bkkumar         02-04-04        FACR116 Added the paramter to the pick_setup routine.
    bkkumar         30-sep-2003     FA 122 Loans Enhancements
                                    This is to recalculate teh fees
                                    based on the setup choosen for the
                                    student
    veramach        1-NOV-2003      FA 125 Multiple Distr Methods
                                    Changed calll to igf_aw_awd_disb_pkg.update_row to reflect the addition of attendance_type_code
    (reverse chronological order - newest change first)
    ***************************************************************/

  l_rel_code      igf_sl_cl_setup.relationship_cd%TYPE;
  l_party_id      igf_sl_cl_setup.party_id%TYPE;
  l_person_id     igf_sl_cl_pref_lenders.person_id%TYPE;

  CURSOR cur_get_adisb (cp_award_id igf_sl_loans.award_id%TYPE)
  IS
  SELECT *
  FROM  igf_aw_awd_disb adisb
  WHERE adisb.award_id = p_award_id;

  CURSOR c_get_alt_code (cp_award_id igf_aw_award_all.award_id%TYPE)
  IS
  select
  fcat.alt_rel_code alt_rel_code
  from
  igf_aw_award_all        awd,
  igf_aw_fund_mast_all fmast,
  igf_aw_fund_cat_all  fcat
  where
  awd.fund_id = fmast.fund_id
  and fmast.fund_code = fcat.fund_code
  and awd.award_id = cp_award_id ;


  get_adisb_rec   cur_get_adisb%ROWTYPE;
  l_get_fed_fund_code  c_get_fed_fund_code%ROWTYPE;
  l_fee1         igf_aw_awd_disb.fee_1%TYPE;
  l_fee2         igf_aw_awd_disb.fee_2%TYPE;
  l_net_amt      igf_aw_awd_disb.disb_net_amt%TYPE;
  l_alt_rel_code igf_aw_fund_cat_all.alt_rel_code%TYPE;
BEGIN

    l_rel_code := NULL;
    l_party_id := NULL;
    l_person_id  := NULL;
    l_alt_rel_code := NULL;

    OPEN c_get_alt_code(p_award_id);
    FETCH c_get_alt_code INTO l_alt_rel_code;
    CLOSE c_get_alt_code;

    -- pick the values from the setup base on the base_id
    igf_sl_award.pick_setup(p_base_id,p_cal_type,p_sequence_number,l_rel_code,l_person_id,l_party_id,l_alt_rel_code);
    IF l_rel_code = p_rel_code THEN
      g_party_id := l_party_id;
    ELSE
      g_party_id := NULL;
    END IF;
    -- put debug log messages
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_award.recalc_fees.debug','The value pick_setup returned rel_code: '||l_rel_code);
    END IF;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_award.recalc_fees.debug','The value pick_setup returned party_id: '||l_party_id);
    END IF;

    g_rel_code := p_rel_code;

    l_get_fed_fund_code := NULL;
    OPEN  c_get_fed_fund_code(p_award_id);
    FETCH c_get_fed_fund_code INTO l_get_fed_fund_code;
    CLOSE c_get_fed_fund_code;

    -- museshad (Bug 3943742). Passed NULL for p_rel_code in both get_loan_fee1() and get_loan_fee2()
    -- get the fee1 and fee2 for the setup
    l_fee1 := igf_sl_award.get_loan_fee1(
                                          p_fed_fund_code     =>    l_get_fed_fund_code.fed_fund_code,
                                          p_ci_cal_type       =>    p_cal_type,
                                          p_ci_seq_num        =>    p_sequence_number,
                                          p_base_id           =>    p_base_id,
                                          p_rel_code          =>    NULL,
                                          p_alt_rel_code      =>    NULL
                                        );

    l_fee2 := igf_sl_award.get_loan_fee2(
                                          p_fed_fund_code     =>    l_get_fed_fund_code.fed_fund_code,
                                          p_ci_cal_type       =>    p_cal_type,
                                          p_ci_seq_num        =>    p_sequence_number,
                                          p_base_id           =>    p_base_id,
                                          p_rel_code          =>    NULL,
                                          p_alt_rel_code      =>    NULL
                                        );

    get_adisb_rec := NULL;


    FOR get_adisb_rec IN cur_get_adisb(p_award_id) LOOP

    -- first calculate the net amount
      IF NVL(get_adisb_rec.disb_accepted_amt,0) = 0 THEN
        l_net_amt := 0;
      ELSE
        l_net_amt := NVL(get_adisb_rec.disb_accepted_amt,0) - (l_fee1 * NVL(get_adisb_rec.disb_accepted_amt,0)) / 100
                     - (l_fee2 * NVL(get_adisb_rec.disb_accepted_amt,0)) / 100 + NVL(get_adisb_rec.fee_paid_1,0)
                     + NVL(get_adisb_rec.fee_paid_2,0);

      END IF;
    -- update the amounts and the fees as calculated above
     igf_aw_awd_disb_pkg.update_row(    x_rowid                     =>    get_adisb_rec.row_id             ,
                                        x_award_id                  =>    get_adisb_rec.award_id           ,
                                        x_disb_num                  =>    get_adisb_rec.disb_num           ,
                                        x_tp_cal_type               =>    get_adisb_rec.tp_cal_type        ,
                                        x_tp_sequence_number        =>    get_adisb_rec.tp_sequence_number ,
                                        x_disb_gross_amt            =>    get_adisb_rec.disb_gross_amt     ,
                                        x_fee_1                     =>    (l_fee1 * NVL(get_adisb_rec.disb_accepted_amt,0)) / 100,
                                        x_fee_2                     =>    (l_fee2 * NVL(get_adisb_rec.disb_accepted_amt,0)) / 100,
                                        x_disb_net_amt              =>    l_net_amt,
                                        x_disb_date                 =>    get_adisb_rec.disb_date          ,
                                        x_trans_type                =>    get_adisb_rec.trans_type         ,
                                        x_elig_status               =>    get_adisb_rec.elig_status        ,
                                        x_elig_status_date          =>    get_adisb_rec.elig_status_date   ,
                                        x_affirm_flag               =>    get_adisb_rec.affirm_flag        ,
                                        x_hold_rel_ind              =>    get_adisb_rec.hold_rel_ind       ,
                                        x_manual_hold_ind           =>    get_adisb_rec.manual_hold_ind    ,
                                        x_disb_status               =>    get_adisb_rec.disb_status        ,
                                        x_disb_status_date          =>    get_adisb_rec.disb_status_date   ,
                                        x_late_disb_ind             =>    get_adisb_rec.late_disb_ind      ,
                                        x_fund_dist_mthd            =>    get_adisb_rec.fund_dist_mthd     ,
                                        x_prev_reported_ind         =>    get_adisb_rec.prev_reported_ind  ,
                                        x_fund_release_date         =>    get_adisb_rec.fund_release_date  ,
                                        x_fund_status               =>    get_adisb_rec.fund_status        ,
                                        x_fund_status_date          =>    get_adisb_rec.fund_status_date   ,
                                        x_fee_paid_1                =>    get_adisb_rec.fee_paid_1         ,
                                        x_fee_paid_2                =>    get_adisb_rec.fee_paid_2         ,
                                        x_cheque_number             =>    get_adisb_rec.cheque_number      ,
                                        x_ld_cal_type               =>    get_adisb_rec.ld_cal_type        ,
                                        x_ld_sequence_number        =>    get_adisb_rec.ld_sequence_number ,
                                        x_disb_accepted_amt         =>    get_adisb_rec.disb_accepted_amt  ,
                                        x_disb_paid_amt             =>    get_adisb_rec.disb_paid_amt      ,
                                        x_rvsn_id                   =>    get_adisb_rec.rvsn_id            ,
                                        x_int_rebate_amt            =>    get_adisb_rec.int_rebate_amt     ,
                                        x_force_disb                =>    get_adisb_rec.force_disb         ,
                                        x_min_credit_pts            =>    get_adisb_rec.min_credit_pts     ,
                                        x_disb_exp_dt               =>    get_adisb_rec.disb_exp_dt        ,
                                        x_verf_enfr_dt              =>    get_adisb_rec.verf_enfr_dt       ,
                                        x_fee_class                 =>    get_adisb_rec.fee_class          ,
                                        x_show_on_bill              =>    get_adisb_rec.show_on_bill       ,
                                        x_mode                      =>    'R',
                                        x_attendance_type_code      =>    get_adisb_rec.attendance_type_code,
                                        x_base_attendance_type_code =>    get_adisb_rec.base_attendance_type_code,
                                        x_payment_prd_st_date       =>    get_adisb_rec.payment_prd_st_date,
                                        x_change_type_code          =>    get_adisb_rec.change_type_code,
                                        x_fund_return_mthd_code     =>    get_adisb_rec.fund_return_mthd_code,
                                        x_direct_to_borr_flag       =>    get_adisb_rec.direct_to_borr_flag
                                        );

    END LOOP;

   EXCEPTION WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_award.recalc_fees.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_AWARD.RECALC_FEES');
    igs_ge_msg_stack.conc_exception_hndl;
    app_exception.raise_exception;

END recalc_fees;

PROCEDURE pick_setup(
                       p_base_id           IN  igf_aw_award_all.base_id%TYPE,
                       p_cal_type          IN  igs_ca_inst_all.cal_type%TYPE,
                       p_sequence_number   IN  igs_ca_inst_all.sequence_number%TYPE,
                       p_rel_code          OUT NOCOPY  igf_sl_cl_setup.relationship_cd%TYPE,
                       p_person_id         OUT NOCOPY  igf_sl_cl_pref_lenders.person_id%TYPE,
                       p_party_id          OUT NOCOPY  igf_sl_cl_setup.party_id%TYPE, -- this is used in FA 126
                       p_alt_rel_code      IN  igf_aw_fund_cat_all.alt_rel_code%TYPE )
IS
    /*************************************************************
    Created By : bkkumar
    Date Created On : 05-Sep-2003
    Purpose : FA 122 Loans Enhancements
    Know limitations, enhancements or remarks
    Change History
    Who             When            What
    bkkumar         02-Apr-04       FACR116 Added a new paramter p_alt_rel_code
                                    which will change check for the lender set up for teh p_alt_rel_code
                                    in case of teh 'ALT' loans instead of the preffered lender setup.
    veramach        12-Nov-2003     Changes to c_chk_pref_lender cursor
    bkkumar         30-sep-2003     FA 122 Loans Enhancemnts
                                     This picks up the set up
                                     applicable to the particular setup
                                     based on teh preferred lender setup
    (reverse chronological order - newest change first)
    ***************************************************************/
    CURSOR c_get_details (
                          cp_base_id  igf_aw_award_all.base_id%TYPE
                         )
    IS
    SELECT person_id
    FROM   igf_ap_fa_base_rec_all
    WHERE  base_id = cp_base_id;

    l_get_details   c_get_details%ROWTYPE;


    CURSOR c_chk_pref_lender (
                              cp_person_id  igf_sl_cl_pref_lenders.person_id%TYPE
                             )
    IS
    SELECT relationship_cd
    FROM   igf_sl_cl_pref_lenders
    WHERE  person_id = cp_person_id
    AND    SYSDATE BETWEEN start_date AND NVL(end_date,SYSDATE);

    l_chk_pref_lender   c_chk_pref_lender%ROWTYPE;

    CURSOR c_get_default_lender (
                                 cp_cal_type          igs_ca_inst_all.cal_type%TYPE,
                                 cp_sequence_number   igs_ca_inst_all.sequence_number%TYPE,
                                 cp_default_flag      igf_sl_cl_setup.default_flag%TYPE
                                )
    IS
    SELECT relationship_cd
    FROM   igf_sl_cl_setup
    WHERE  ci_cal_type = cp_cal_type
    AND    ci_sequence_number = cp_sequence_number
    AND    NVL(default_flag,'N') = cp_default_flag
    AND    party_id IS NULL;

    l_get_default_lender   c_get_default_lender%ROWTYPE;

    CURSOR c_get_ovrd_lender (
                                 cp_cal_type          igs_ca_inst_all.cal_type%TYPE,
                                 cp_sequence_number   igs_ca_inst_all.sequence_number%TYPE,
                                 cp_rel_code          igf_sl_cl_setup.relationship_cd%TYPE,
                                 cp_party_id          igf_sl_cl_setup.party_id%TYPE
                             )
    IS
    SELECT relationship_cd
    FROM   igf_sl_cl_setup
    WHERE  ci_cal_type = cp_cal_type
    AND    ci_sequence_number = cp_sequence_number
    AND    cp_rel_code = NVL(relationship_cd,'*')
    AND    cp_party_id = NVL(party_id,-1000);

    l_get_ovrd_lender   c_get_ovrd_lender%ROWTYPE;

    CURSOR c_get_ovrd_default_lender (
                                      cp_cal_type          igs_ca_inst_all.cal_type%TYPE,
                                      cp_sequence_number   igs_ca_inst_all.sequence_number%TYPE,
                                      cp_party_id          igf_sl_cl_setup.party_id%TYPE,
                                      cp_default_flag      igf_sl_cl_setup.default_flag%TYPE
                                     )
    IS
    SELECT relationship_cd
    FROM   igf_sl_cl_setup
    WHERE  ci_cal_type = cp_cal_type
    AND    ci_sequence_number = cp_sequence_number
    AND    NVL(default_flag,'N') = cp_default_flag
    AND    NVL(party_id,-1000) = cp_party_id;

    l_get_ovrd_default_lender   c_get_ovrd_default_lender%ROWTYPE;


    CURSOR cur_find_lender (
                                 cp_cal_type          igs_ca_inst_all.cal_type%TYPE,
                                 cp_sequence_number   igs_ca_inst_all.sequence_number%TYPE,
                                 cp_rel_code          igf_sl_cl_setup.relationship_cd%TYPE
                             )
    IS
    SELECT relationship_cd
    FROM   igf_sl_cl_setup
    WHERE  ci_cal_type        = cp_cal_type
    AND    ci_sequence_number = cp_sequence_number
    AND    cp_rel_code        = relationship_cd
    AND    party_id IS NULL;

    find_lender_rec   cur_find_lender%ROWTYPE;

    lv_party_number hz_parties.party_number%TYPE;
    lv_module VARCHAR2(2);
    lv_return_status VARCHAR2(1);
    lv_msg_data fnd_new_messages.message_name%TYPE;

BEGIN

      g_base_id := p_base_id;
      igf_sl_gen.get_associated_org(g_base_id, lv_party_number, g_party_id, lv_module, lv_return_status, lv_msg_data);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_award.pick_setup.debug','The value select_org returned : '||g_party_id);
      END IF;
      --FACR116
      -- If the alt_rel_code passed is NOT NULL means it has to be done for the Alternative Loans
      IF p_alt_rel_code IS NOT NULL THEN
         g_rel_code := p_alt_rel_code;
         IF g_party_id IS NOT NULL THEN

            l_get_ovrd_lender := NULL;
            OPEN  c_get_ovrd_lender(p_cal_type,p_sequence_number,g_rel_code,g_party_id);
            FETCH c_get_ovrd_lender INTO l_get_ovrd_lender;
            CLOSE c_get_ovrd_lender;

            IF l_get_ovrd_lender.relationship_cd IS NULL THEN

              --
              -- This means there is no override for the party
              -- then check if the relationship code setup exists
              --

              OPEN  cur_find_lender(p_cal_type,p_sequence_number,g_rel_code);
              FETCH cur_find_lender INTO find_lender_rec;
              CLOSE cur_find_lender;

              IF find_lender_rec.relationship_cd IS NULL THEN
                 g_rel_code := NULL;
              END IF;
              g_party_id := NULL;
            END IF;
         ELSE -- party_id is NULL
            OPEN  cur_find_lender(p_cal_type,p_sequence_number,g_rel_code);
            FETCH cur_find_lender INTO find_lender_rec;
            CLOSE cur_find_lender;
            IF find_lender_rec.relationship_cd IS NULL THEN
               g_rel_code := NULL;
            END IF;

         END IF; -- party_id NOT NULL

      ELSE -- the Loan in consideration is not a ALTERNATIVE loan

        l_get_default_lender := NULL;
        OPEN  c_get_default_lender(p_cal_type,p_sequence_number,'Y');
        FETCH c_get_default_lender INTO l_get_default_lender;
        CLOSE c_get_default_lender;

        -- get the person id of this person from the igf_ap_fa_base_rec_all;

        l_get_details := NULL;
        OPEN  c_get_details(g_base_id);
        FETCH c_get_details INTO l_get_details;
        CLOSE c_get_details;

        p_person_id := l_get_details.person_id;

        l_chk_pref_lender := NULL;
        OPEN  c_chk_pref_lender(p_person_id);
        FETCH c_chk_pref_lender INTO l_chk_pref_lender;
        CLOSE c_chk_pref_lender;

      IF g_party_id IS NOT NULL THEN
        --
        -- this is implemented for FA126
        -- if the person has a preferred lender then assign g_rel_code to this value
        --

        IF l_chk_pref_lender.relationship_cd IS NOT NULL THEN

          g_rel_code := l_chk_pref_lender.relationship_cd;

          l_get_ovrd_lender := NULL;
          OPEN  c_get_ovrd_lender(p_cal_type,p_sequence_number,g_rel_code,g_party_id);
          FETCH c_get_ovrd_lender INTO l_get_ovrd_lender;
          CLOSE c_get_ovrd_lender;

          IF l_get_ovrd_lender.relationship_cd IS NULL THEN

              --
              -- This means there is no override for the party
              -- then check if the relationship code setup exists
              --

              OPEN  cur_find_lender(p_cal_type,p_sequence_number,g_rel_code);
              FETCH cur_find_lender INTO find_lender_rec;
              CLOSE cur_find_lender;

              IF find_lender_rec.relationship_cd IS NULL THEN
                 --bug #3847105 - Log message in case the Loan is created using Default Lender setup
                 --despite of Preferred Lender as the Preferred Lender is not setup for the Award Year.
                 fnd_message.set_name('IGF','IGF_SL_DFLT_LEN_LOAN');
                 fnd_message.set_token('DEFAULT_LEN',l_get_default_lender.relationship_cd);
                 fnd_message.set_token('PREFER_LEN',l_chk_pref_lender.relationship_cd);
                 fnd_message.set_token('AWARD_YEAR',igf_gr_gen.get_alt_code(p_cal_type,p_sequence_number));
                 fnd_file.put_line(fnd_file.log, fnd_message.get);

                 g_rel_code := l_get_default_lender.relationship_cd;
              END IF;

              g_party_id := NULL;

          END IF;

        ELSE
         -- if it does not have a preferred lender check for default lender in override form
          l_get_ovrd_default_lender := NULL;

          OPEN  c_get_ovrd_default_lender(p_cal_type,p_sequence_number,g_party_id,'Y');
          FETCH c_get_ovrd_default_lender INTO l_get_ovrd_default_lender;
          CLOSE c_get_ovrd_default_lender;

          IF l_get_ovrd_default_lender.relationship_cd IS NOT NULL THEN

            g_rel_code := l_get_ovrd_default_lender.relationship_cd;

          ELSE
            -- get the default setup
            g_rel_code := l_get_default_lender.relationship_cd;
            -- check for the override for this lender
            l_get_ovrd_lender := NULL;
            OPEN  c_get_ovrd_lender(p_cal_type,p_sequence_number,g_rel_code,g_party_id);
            FETCH c_get_ovrd_lender INTO l_get_ovrd_lender;
            CLOSE c_get_ovrd_lender;

            IF l_get_ovrd_lender.relationship_cd IS NULL THEN
              g_party_id := NULL;
            END IF;

          END IF;

        END IF;

      ELSE
         --
         -- if the party_id is NULL then no organization linked to the student
         --
         IF l_chk_pref_lender.relationship_cd IS NOT NULL THEN

           g_rel_code := l_chk_pref_lender.relationship_cd;
           --
           -- If there is no record in the setup table
           -- for this rel code then use the default lender
           -- for the award year
           --
           OPEN  cur_find_lender(p_cal_type,p_sequence_number,g_rel_code);
           FETCH cur_find_lender INTO find_lender_rec;
           CLOSE cur_find_lender;

           IF find_lender_rec.relationship_cd IS NULL THEN
               --bug #3847105 - Log message in case the Loan is created using Default Lender setup
               --despite of Preferred Lender as the Preferred Lender is not setup for the Award Year.
               fnd_message.set_name('IGF','IGF_SL_DFLT_LEN_LOAN');
               fnd_message.set_token('DEFAULT_LEN',l_get_default_lender.relationship_cd);
               fnd_message.set_token('PREFER_LEN',l_chk_pref_lender.relationship_cd);
               fnd_message.set_token('AWARD_YEAR',igf_gr_gen.get_alt_code(p_cal_type,p_sequence_number));
               g_rel_code := l_get_default_lender.relationship_cd;
               fnd_file.put_line(fnd_file.log, fnd_message.get);
           END IF;

         ELSE
           g_rel_code := l_get_default_lender.relationship_cd;
         END IF;

      END IF;
   END IF;
   p_rel_code := g_rel_code;
   p_party_id := g_party_id;

   EXCEPTION WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_award.pick_setup.exception',SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_AWARD.PICK_SETUP');
    igs_ge_msg_stack.conc_exception_hndl;
    app_exception.raise_exception;

  END pick_setup;

  FUNCTION chk_chg_enable (p_n_award_id igf_aw_award_all.award_id%TYPE)
  RETURN   BOOLEAN AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 14 October 2004
--
-- Purpose     : Generic Function
-- Invoked     :
-- Function    :
--
-- Parameters  : p_n_award_id    : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
CURSOR  c_chk_chg_enable (cp_n_award_id  igf_aw_award_all.award_id%TYPE) IS
SELECT  loans.loan_number
FROM    igf_sl_lor_all lor
       ,igf_sl_loans_all loans
       ,igf_aw_award_all awd
       ,igf_aw_fund_mast_all fmast
       ,igf_sl_cl_setup_all  clset
WHERE  loans.loan_id  = lor.loan_id
AND    loans.award_id = cp_n_award_id
AND    lor.prc_type_code IN ('GO','GP')
AND    ( lor.guarnt_status_code = '40' OR  lor.cl_rec_status IN ('B','G'))
AND    loans.loan_status = 'A'
AND    NVL (loans.loan_chg_status,'*') <> 'S'
AND    awd.award_id   = loans.award_id
AND    fmast.fund_id  = awd.fund_id
AND    fmast.ci_cal_type = clset.ci_cal_type
AND    fmast.ci_sequence_number = clset.ci_sequence_number
AND    lor.relationship_cd = clset.relationship_cd
AND    clset.cl_version = 'RELEASE-4';

l_v_loan_number           igf_sl_loans_all.loan_number%TYPE;
BEGIN
  OPEN   c_chk_chg_enable (cp_n_award_id => p_n_award_id);
  FETCH  c_chk_chg_enable INTO l_v_loan_number;
  IF c_chk_chg_enable%NOTFOUND THEN
    CLOSE c_chk_chg_enable;
    RETURN FALSE;
  END IF;
  CLOSE c_chk_chg_enable;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_exception,'igf_sl_award.chk_chg_enable exception',SQLERRM);
    END IF;
   fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_award.chk_chg_enable');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END chk_chg_enable;


FUNCTION chk_add_new_disb (p_n_award_id igf_aw_award_all.award_id%TYPE)
RETURN   BOOLEAN AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 14 October 2004
--
-- Purpose     : Generic Function
-- Invoked     :
-- Function    :
--
-- Parameters  : p_n_award_id    : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
CURSOR  c_igf_sl_loans (cp_n_award_id  igf_aw_award_all.award_id%TYPE) IS
SELECT  'X'
FROM    igf_sl_loans_all lar
WHERE   lar.award_id =  cp_n_award_id;

rec_c_igf_sl_loans  c_igf_sl_loans%ROWTYPE;

CURSOR  c_igf_aw_awd_disb (cp_n_award_id  igf_aw_award_all.award_id%TYPE) IS
SELECT  adisb.disb_num
FROM    igf_aw_awd_disb_all adisb
WHERE   adisb.award_id=cp_n_award_id
AND     NVL(adisb.fund_status,'N') = 'N';

l_disb_num   igf_aw_awd_disb_all.disb_num%TYPE;
l_n_award_id igf_aw_award_all.award_id%TYPE;
l_return_val BOOLEAN;
BEGIN
  l_n_award_id := p_n_award_id;
  OPEN  c_igf_sl_loans(cp_n_award_id => l_n_award_id);
  FETCH c_igf_sl_loans INTO rec_c_igf_sl_loans;
  -- check if loan record is created or not
  IF c_igf_sl_loans%NOTFOUND THEN
    CLOSE c_igf_sl_loans;
    RETURN TRUE;
  END IF;
  CLOSE c_igf_sl_loans;
  --if loan records exists, check if new disbursement can be added or not
  OPEN  c_igf_aw_awd_disb(cp_n_award_id => l_n_award_id);
  FETCH c_igf_aw_awd_disb INTO l_disb_num;
  CLOSE c_igf_aw_awd_disb ;

  l_return_val:= igf_sl_award.chk_chg_enable (p_n_award_id => l_n_award_id);

  IF NOT (l_return_val) THEN
    RETURN TRUE;
  END IF;

  IF (l_disb_num IS NULL) THEN
    RETURN FALSE;
  END IF;
  RETURN TRUE;



EXCEPTION
  WHEN OTHERS THEN
    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_exception,'igf_sl_award.chk_add_new_disb exception',SQLERRM);
    END IF;
   fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_award.chk_add_new_disb');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END chk_add_new_disb;


FUNCTION chk_loan_increase (p_n_award_id igf_aw_award_all.award_id%TYPE)
RETURN   BOOLEAN AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 14 October 2004
--
-- Purpose     : Generic Function
-- Invoked     :
-- Function    :
--
-- Parameters  : p_n_award_id    : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
CURSOR  c_igf_sl_loans (cp_n_award_id  igf_aw_award_all.award_id%TYPE) IS
SELECT  'X'
FROM    igf_sl_loans_all lar
WHERE   lar.award_id =  cp_n_award_id;

rec_c_igf_sl_loans  c_igf_sl_loans%ROWTYPE;

CURSOR  c_igf_aw_awd_disb (cp_n_award_id  igf_aw_award_all.award_id%TYPE) IS
SELECT  adisb.disb_num
FROM    igf_aw_awd_disb_all adisb
WHERE   adisb.award_id=cp_n_award_id
AND     NVL(adisb.fund_status,'N') = 'N';

CURSOR  c_chk_chg_enable (cp_n_award_id  igf_aw_award_all.award_id%TYPE) IS
SELECT   loans.loan_number loan_number
        ,clset.cl_version  cl_version
        ,loans.loan_status loan_status
FROM    igf_sl_lor_all lor
       ,igf_sl_loans_all loans
       ,igf_aw_award_all awd
       ,igf_aw_fund_mast_all fmast
       ,igf_sl_cl_setup_all  clset
WHERE  loans.loan_id  = lor.loan_id
AND    loans.award_id = cp_n_award_id
AND    lor.prc_type_code IN ('GO','GP')
AND    loans.loan_status <> 'S'
AND    NVL (loans.loan_chg_status,'*') <> 'S'
AND    awd.award_id   = loans.award_id
AND    fmast.fund_id  = awd.fund_id
AND    fmast.ci_cal_type = clset.ci_cal_type
AND    fmast.ci_sequence_number = clset.ci_sequence_number
AND    lor.relationship_cd = clset.relationship_cd ;

l_v_loan_number   igf_sl_loans_all.loan_number%TYPE;
l_n_cl_version    igf_sl_cl_setup_all.cl_version%TYPE;
l_v_loan_status   igf_sl_loans_all.loan_status%TYPE;
l_disb_num        igf_aw_awd_disb_all.disb_num%TYPE;
l_n_award_id      igf_aw_award_all.award_id%TYPE;

BEGIN
  l_n_award_id := p_n_award_id;
  OPEN  c_igf_sl_loans(cp_n_award_id => l_n_award_id);
  FETCH c_igf_sl_loans INTO rec_c_igf_sl_loans;
  -- check if loan record is created or not
  IF c_igf_sl_loans%NOTFOUND THEN
    CLOSE c_igf_sl_loans;
    RETURN TRUE;
  END IF;
  CLOSE c_igf_sl_loans;
  --if loan records exists, check if new disbursement can be added or not
  OPEN  c_igf_aw_awd_disb(cp_n_award_id => l_n_award_id);
  FETCH c_igf_aw_awd_disb INTO l_disb_num;
  CLOSE c_igf_aw_awd_disb ;

  OPEN  c_chk_chg_enable (cp_n_award_id => l_n_award_id);
  FETCH c_chk_chg_enable  INTO l_v_loan_number,l_n_cl_version,l_v_loan_status;
  IF    c_chk_chg_enable%NOTFOUND THEN
    CLOSE c_chk_chg_enable;
    RETURN TRUE;
  END IF;
  CLOSE c_chk_chg_enable;

  IF (l_n_cl_version = 'RELEASE-4')THEN
    IF l_disb_num IS NOT NULL THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  ELSIF (l_n_cl_version = 'RELEASE-5')THEN
    -- if loan status is accepted or sent
    IF l_v_loan_status IN ('A','S') THEN
      RETURN FALSE;
    END IF;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_exception,'igf_sl_award.chk_loan_increase exception',SQLERRM);
    END IF;
   fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_award.chk_loan_increase');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END chk_loan_increase;

FUNCTION get_loan_cl_version (p_n_award_id igf_aw_award_all.award_id%TYPE)
RETURN igf_sl_cl_setup_all.cl_version%TYPE AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 14 October 2004
--
-- Purpose     : Generic Function
-- Invoked     :
-- Function    :
--
-- Parameters  : p_n_award_id    : IN parameter. Required.
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
--museshad    06-May-2005     Bug# 4346258
--                            Modified the entire logic in the function so that
--                            it arrives at the correct CL version# by
--                            taking into account any CL version# override
--                            for any particular Organization Unit setup in
--                            FFELP Setup override.
------------------------------------------------------------------

/* Cursor Variable */
CURSOR c_get_loan_details(cp_n_award_id  igf_aw_award_all.award_id%TYPE)
IS
    SELECT
            awd.award_id,
            awd.base_id,
            fmast.ci_cal_type,
            fmast.ci_sequence_number,
            lor.relationship_cd
    FROM
            igf_sl_lor_all lor,
            igf_sl_loans_all loans,
            igf_aw_award_all awd,
            igf_aw_fund_mast_all fmast
    WHERE
            loans.loan_id  =  lor.loan_id     AND
            awd.award_id   =  loans.award_id  AND
            fmast.fund_id  =  awd.fund_id     AND
            awd.award_id   =  cp_n_award_id;

/* Local Variables */
l_n_cl_version           igf_sl_cl_setup_all.cl_version%TYPE;
l_n_award_id             igf_aw_award_all.award_id%TYPE;
l_n_base_id              igf_aw_award_all.base_id%TYPE;
l_v_ci_cal_type          igf_aw_fund_mast_all.ci_cal_type%TYPE;
l_n_ci_sequence_number   igf_aw_fund_mast_all.ci_sequence_number%TYPE;
l_v_relationship_cd      igf_sl_lor_all.relationship_cd%TYPE;

BEGIN
     -- Get Base_Id and related details
     OPEN c_get_loan_details(cp_n_award_id => p_n_award_id);
     FETCH  c_get_loan_details INTO l_n_award_id, l_n_base_id, l_v_ci_cal_type,
                                    l_n_ci_sequence_number, l_v_relationship_cd;
     CLOSE  c_get_loan_details;

     -- Get CL Version#
     l_n_cl_version := igf_sl_gen.get_cl_version(p_ci_cal_type      =>  l_v_ci_cal_type,
                                                 p_ci_seq_num       =>  l_n_ci_sequence_number,
                                                 p_relationship_cd  =>  l_v_relationship_cd,
                                                 p_base_id          =>  l_n_base_id);
  RETURN l_n_cl_version;

EXCEPTION
  WHEN OTHERS THEN
    IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_exception,'igf_sl_award.get_loan_cl_version exception',SQLERRM);
    END IF;
   fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_award.get_loan_cl_version');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END get_loan_cl_version;

FUNCTION chk_fund_st_chg ( p_n_award_id   IN igf_aw_award_all.award_id%TYPE,
                           p_n_disb_num   IN igf_aw_awd_disb_all.disb_num%TYPE
                         )
RETURN BOOLEAN AS
------------------------------------------------------------------
--Created by  : Sanil Madathil, Oracle IDC
--Date created: 14 October 2004
--
-- Purpose     : Generic Function
-- Invoked     :
-- Function    :
--
-- Parameters  : p_n_award_id           : IN parameter. Required.
--               p_n_disb_num           : IN parameter. Required.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------
CURSOR c_chk_fund_st_chg_1 (cp_n_award_id   IN igf_aw_award_all.award_id%TYPE,
                            cp_n_disb_num   IN igf_aw_awd_disb_all.disb_num%TYPE) IS
SELECT  dbresp.disb_num
FROM    igf_db_cl_disb_resp dbresp
       ,igf_sl_loans_all loans
       ,igf_aw_award_all awd
WHERE  dbresp.disb_num   = cp_n_disb_num
AND    loans.loan_number = dbresp.loan_number
AND    awd.award_id      = loans.award_id
AND    awd.award_id      = cp_n_award_id
ORDER BY cdbr_id DESC;

CURSOR c_chk_fund_st_chg_2 (cp_n_award_id   IN igf_aw_award_all.award_id%TYPE,
                            cp_n_disb_num   IN igf_aw_awd_disb_all.disb_num%TYPE) IS
SELECT chg.disbursement_number
FROM   igf_sl_clchsn_dtls chg
      ,igf_sl_loans_all loans
      ,igf_aw_award_all awd
WHERE chg.disbursement_number    = cp_n_disb_num
AND   chg.change_record_type_txt = '10'
AND   chg.status_code <> ('D')
AND   chg.loan_number_txt = loans.loan_number
AND   loans.award_id = awd.award_id
AND   awd.award_id   = cp_n_award_id ;

l_n_disb_num  igf_aw_awd_disb_all.disb_num%TYPE;

BEGIN

-- Fund Status would determine if the Disbursement Change is to be considered as Pre or Post Disbursement,
-- Fund Status once set to "Funded" cannot be updated if
-- There are roster response present for the disbursement, or
-- Post Disbursement Change Records are present in the Change Send table for this disbursement
  OPEN   c_chk_fund_st_chg_1 (cp_n_award_id => p_n_award_id,
                              cp_n_disb_num => p_n_disb_num
                             );
  FETCH c_chk_fund_st_chg_1 INTO l_n_disb_num;
  IF c_chk_fund_st_chg_1%FOUND THEN
    CLOSE  c_chk_fund_st_chg_1;
    RETURN FALSE;
  END IF;
  CLOSE c_chk_fund_st_chg_1;
  OPEN   c_chk_fund_st_chg_2 (cp_n_award_id => p_n_award_id,
                              cp_n_disb_num => p_n_disb_num
                             );
  FETCH c_chk_fund_st_chg_2 INTO l_n_disb_num;
  IF    c_chk_fund_st_chg_2%FOUND THEN
    CLOSE  c_chk_fund_st_chg_2;
    RETURN FALSE;
  END IF;
  CLOSE c_chk_fund_st_chg_2 ;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
   IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string(fnd_log.level_exception,'igf_sl_award.chk_fund_st_chg exception',SQLERRM);
   END IF;
   fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_award.chk_fund_st_chg');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END chk_fund_st_chg;

END igf_sl_award;

/
