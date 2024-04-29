--------------------------------------------------------
--  DDL for Package Body IGF_AW_COA_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_COA_GEN" AS
/* $Header: IGFAW17B.pls 120.7 2006/04/19 01:17:34 akomurav noship $ */
------------------------------------------------------------------
--Created by  : veramach, Oracle India
--Date created: 07-OCT-2004
--
--Purpose:
--   Generic APIs for the COA module
--
--Known limitations/enhancements and/or remarks:
--
--
--Change History:
--Who         When            What
--veramach    21-Dec-2004     Bug 4078547
--                            Modified cursors c_org,c_prg_type,c_prog_loc,c_prog_code,c_att_type,c_att_mode
--
--ridas       09-Aug-2005     Bug #4164450. Added new validations to check
--                            the program offering options
-------------------------------------------------------------------

  g_unlock_level NUMBER;

  FUNCTION coa_amount(
                      p_base_id           igf_ap_fa_base_rec_all.base_id%TYPE,
                      p_awd_prd_code      igf_aw_award_prd.award_prd_cd%TYPE,
                      p_use_direct_costs  igf_aw_coa_items.fixed_cost%TYPE
                     ) RETURN NUMBER AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 07-OCT-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  CURSOR c_coa_amount(
                      cp_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                      cp_awd_prd_code       igf_aw_award_prd.award_prd_cd%TYPE,
                      cp_use_direct_costs   igf_aw_coa_items.fixed_cost%TYPE
                     ) IS
    SELECT SUM(coa.amount)
      FROM igf_aw_coa_itm_terms coa,
           igf_aw_awd_prd_term trms,
           igf_ap_fa_base_rec_all fa,
           igf_aw_coa_items item
     WHERE fa.base_id = coa.base_id
       AND fa.ci_cal_type = trms.ci_cal_type
       AND fa.ci_sequence_number = trms.ci_sequence_number
       AND coa.ld_cal_type = trms.ld_cal_type
       AND coa.ld_sequence_number = trms.ld_sequence_number
       AND fa.base_id = cp_base_id
       AND trms.award_prd_cd = cp_awd_prd_code
       AND item.base_id = coa.base_id
       AND item.item_code = coa.item_code
       AND (
               (cp_use_direct_costs = 'Y' AND NVL(item.fixed_cost, 'N') = 'Y')
            OR (cp_use_direct_costs = 'N' AND NVL(item.fixed_cost, 'N') IN ('Y','N')
           ));

  ln_coa NUMBER;

  CURSOR c_coa_amount_awd(
                          cp_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                          cp_use_direct_costs   igf_aw_coa_items.fixed_cost%TYPE
                         ) IS
    SELECT SUM(coa.amount)
      FROM igf_aw_coa_itm_terms coa,
           igf_aw_coa_items item
     WHERE coa.base_id = cp_base_id
       AND item.base_id = coa.base_id
       AND item.item_code = coa.item_code
       AND (
               (cp_use_direct_costs = 'Y' AND NVL(item.fixed_cost, 'N') = 'Y')
            OR (cp_use_direct_costs = 'N' AND NVL(item.fixed_cost, 'N') IN('Y','N')
           ));

  BEGIN

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.coa_amount.debug','p_base_id:'||p_base_id);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.coa_amount.debug','p_awd_prd_code:'||p_awd_prd_code);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.coa_amount.debug','p_use_direct_costs:'||p_use_direct_costs);
     END IF;

    IF p_awd_prd_code IS NOT NULL THEN
      ln_coa := NULL;
      OPEN c_coa_amount(p_base_id,p_awd_prd_code,NVL(p_use_direct_costs,'N'));
      FETCH c_coa_amount INTO ln_coa;
      CLOSE c_coa_amount;
    ELSE
      ln_coa := NULL;
      OPEN c_coa_amount_awd(p_base_id,NVL(p_use_direct_costs,'N'));
      FETCH c_coa_amount_awd INTO ln_coa;
      CLOSE c_coa_amount_awd;
    END IF;
    RETURN ln_coa;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_COA_GEN.COA_AMOUNT ' || SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END coa_amount;

  FUNCTION award_amount(
                        p_base_id      igf_ap_fa_base_rec_all.base_id%TYPE,
                        p_awd_prd_code igf_aw_award_prd.award_prd_cd%TYPE,
                        p_award_id     igf_aw_award_all.award_id%TYPE DEFAULT NULL
                       ) RETURN NUMBER AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 07-OCT-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR c_award_amount(
                        cp_base_id      igf_ap_fa_base_rec_all.base_id%TYPE,
                        cp_awd_prd_code igf_aw_award_prd.award_prd_cd%TYPE,
                        cp_award_id     igf_aw_award_all.award_id%TYPE
                       ) IS
    SELECT SUM(NVL(disb.disb_gross_amt, 0)) award_amount
      FROM igf_aw_award_all awd,
           igf_aw_awd_disb_all disb,
           igf_aw_awd_prd_term aprd,
           igf_ap_fa_base_rec_all fa
     WHERE disb.award_id = awd.award_id
       AND awd.base_id = cp_base_id
       AND awd.base_id = fa.base_id
       AND awd.award_status IN('OFFERED', 'ACCEPTED')
       AND disb.trans_type <> 'C'
       AND disb.ld_cal_type = aprd.ld_cal_type
       AND disb.ld_sequence_number = aprd.ld_sequence_number
       AND aprd.award_prd_cd = cp_awd_prd_code
       AND aprd.ci_cal_type = fa.ci_cal_type
       AND aprd.ci_sequence_number = fa.ci_sequence_number
       AND awd.award_id = NVL(cp_award_id,awd.award_id);

   ln_award NUMBER;

  CURSOR c_award_amount_awd(
                            cp_base_id      igf_ap_fa_base_rec_all.base_id%TYPE,
                            cp_award_id     igf_aw_award_all.award_id%TYPE
                           ) IS
    SELECT SUM(NVL(disb.disb_gross_amt, 0)) award_amount
      FROM igf_aw_award_all awd,
           igf_aw_awd_disb_all disb
     WHERE disb.award_id = awd.award_id
       AND awd.base_id = cp_base_id
       AND awd.award_status IN ('OFFERED', 'ACCEPTED')
       AND disb.trans_type <> 'C'
       AND awd.award_id = NVL(cp_award_id,awd.award_id);

   BEGIN

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.award_amount.debug','p_base_id:'||p_base_id);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.award_amount.debug','p_awd_prd_code:'||p_awd_prd_code);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.award_amount.debug','p_award_id:'||p_award_id);
     END IF;
     IF p_awd_prd_code IS NOT NULL THEN
       ln_award := NULL;
       OPEN c_award_amount(p_base_id,p_awd_prd_code,p_award_id);
       FETCH c_award_amount INTO ln_award;
       CLOSE c_award_amount;
     ELSE
       ln_award := NULL;
       OPEN c_award_amount_awd(p_base_id,p_award_id);
       FETCH c_award_amount_awd INTO ln_award;
       CLOSE c_award_amount_awd;
     END IF;
     RETURN ln_award;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_COA_GEN.AWARD_AMOUNT ' || SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END award_amount;

  FUNCTION isCoaLocked(
                       p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                       p_item_code           igf_aw_item.item_code%TYPE DEFAULT NULL,
                       p_ld_cal_type         igs_ca_inst.cal_type%TYPE DEFAULT NULL,
                       p_ld_sequence_number  igs_ca_inst.sequence_number%TYPE DEFAULT NULL
                      ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 07-OCT-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get item/term level lock
  CURSOR c_item_term(
                     cp_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                     cp_item_code           igf_aw_item.item_code%TYPE,
                     cp_ld_cal_type         igs_ca_inst.cal_type%TYPE,
                     cp_ld_sequence_number  igs_ca_inst.sequence_number%TYPE
                    ) IS
    SELECT NVL(lock_flag,'N') lock_flag
      FROM igf_aw_coa_itm_terms
     WHERE base_id            = cp_base_id
       AND item_code          = cp_item_code
       AND ld_cal_type        = cp_ld_cal_type
       AND ld_sequence_number = cp_ld_sequence_number;
  l_item_term c_item_term%ROWTYPE;

  -- Get item level lock
  CURSOR c_item(
                cp_base_id   igf_ap_fa_base_rec_all.base_id%TYPE,
                cp_item_code igf_aw_item.item_code%TYPE
               ) IS
    SELECT NVL(lock_flag,'N') lock_flag
      FROM igf_aw_coa_items
     WHERE base_id            = cp_base_id
       AND item_code          = cp_item_code;
  l_item c_item%ROWTYPE;

  -- Get base record level lock
  CURSOR c_base(
                cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
               ) IS
    SELECT NVL(lock_coa_flag,'N') lock_coa_flag
      FROM igf_ap_fa_base_rec_all
     WHERE base_id            = cp_base_id;
  l_base c_base%ROWTYPE;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.isCoaLocked.debug','p_base_id:'||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.isCoaLocked.debug','p_item_code:'||p_item_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.isCoaLocked.debug','p_ld_cal_type:'||p_ld_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.isCoaLocked.debug','p_ld_sequence_number:'||p_ld_sequence_number);
    END IF;

    IF p_base_id IS NOT NULL AND p_item_code IS NOT NULL AND p_ld_cal_type IS NOT NULL AND p_ld_sequence_number IS NOT NULL THEN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.isCoaLocked.debug','Scenario 1');
      END IF;

      l_item_term := NULL;
      OPEN c_item_term(p_base_id,p_item_code,p_ld_cal_type,p_ld_sequence_number);
      FETCH c_item_term INTO l_item_term;
      IF c_item_term%FOUND THEN

        CLOSE c_item_term;
        IF l_item_term.lock_flag = 'Y' THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
      ELSE
        CLOSE c_item_term;
        RETURN FALSE;
      END IF;
    ELSIF p_base_id IS NOT NULL AND p_item_code IS NOT NULL AND p_ld_cal_type IS NULL AND p_ld_sequence_number IS NULL THEN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.isCoaLocked.debug','Scenario 2');
      END IF;

      l_item := NULL;
      OPEN c_item(p_base_id,p_item_code);
      FETCH c_item INTO l_item;
      IF c_item%FOUND THEN

        CLOSE c_item;
        IF l_item.lock_flag = 'Y' THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
      ELSE
        CLOSE c_item;
        RETURN FALSE;
      END IF;
    ELSIF p_base_id IS NOT NULL AND p_item_code IS NULL AND p_ld_cal_type IS NULL AND p_ld_sequence_number IS NULL THEN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.isCoaLocked.debug','Scenario 3');
      END IF;

      l_base := NULL;
      OPEN c_base(p_base_id);
      FETCH c_base INTO l_base;
      IF c_base%FOUND THEN

        CLOSE c_base;
        IF l_base.lock_coa_flag = 'Y' THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
      ELSE
        CLOSE c_base;
        RETURN FALSE;
      END IF;
    ELSE
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.isCoaLocked.debug','Scenario 4');
      END IF;
      RETURN FALSE;
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_COA_GEN.ISCOALOCKED ' || SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END isCoaLocked;

  PROCEDURE updateLock(
                       p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                       p_mode                VARCHAR2,
                       p_item_code           igf_aw_item.item_code%TYPE DEFAULT NULL,
                       p_ld_cal_type         igs_ca_inst.cal_type%TYPE DEFAULT NULL,
                       p_ld_sequence_number  igs_ca_inst.sequence_number%TYPE DEFAULT NULL
                      );

  PROCEDURE doLockInternal(
                           p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_item_code           igf_aw_item.item_code%TYPE DEFAULT NULL,
                           p_ld_cal_type         igs_ca_inst.cal_type%TYPE DEFAULT NULL,
                           p_ld_sequence_number  igs_ca_inst.sequence_number%TYPE DEFAULT NULL
                          ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 07-OCT-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doLockInternal.debug','p_base_id:'||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doLockInternal.debug','p_item_code:'||p_item_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doLockInternal.debug','p_ld_cal_type:'||p_ld_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doLockInternal.debug','p_ld_sequence_number:'||p_ld_sequence_number);
    END IF;

    updateLock(p_base_id,'Y',p_item_code,p_ld_cal_type,p_ld_sequence_number);
  END doLockInternal;

  PROCEDURE doUnlockInternal(
                             p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                             p_item_code           igf_aw_item.item_code%TYPE DEFAULT NULL,
                             p_ld_cal_type         igs_ca_inst.cal_type%TYPE DEFAULT NULL,
                             p_ld_sequence_number  igs_ca_inst.sequence_number%TYPE DEFAULT NULL
                            ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 07-OCT-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doUnlockInternal.debug','p_base_id:'||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doUnlockInternal.debug','p_item_code:'||p_item_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doUnlockInternal.debug','p_ld_cal_type:'||p_ld_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doUnlockInternal.debug','p_ld_sequence_number:'||p_ld_sequence_number);
    END IF;

    updateLock(p_base_id,'N',p_item_code,p_ld_cal_type,p_ld_sequence_number);
  END doUnlockInternal;

  PROCEDURE updateLock(
                       p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                       p_mode                VARCHAR2,
                       p_item_code           igf_aw_item.item_code%TYPE DEFAULT NULL,
                       p_ld_cal_type         igs_ca_inst.cal_type%TYPE DEFAULT NULL,
                       p_ld_sequence_number  igs_ca_inst.sequence_number%TYPE DEFAULT NULL
                      ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 07-OCT-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR c_item_term(
                     cp_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                     cp_item_code           igf_aw_item.item_code%TYPE,
                     cp_ld_cal_type         igs_ca_inst.cal_type%TYPE,
                     cp_ld_sequence_number  igs_ca_inst.sequence_number%TYPE
                    ) IS
    SELECT terms.rowid row_id,
           terms.*
      FROM igf_aw_coa_itm_terms terms
     WHERE base_id            = cp_base_id
       AND item_code          = cp_item_code
       AND ld_cal_type        = cp_ld_cal_type
       AND ld_sequence_number = cp_ld_sequence_number;
  l_item_term c_item_term%ROWTYPE;

  CURSOR c_item(
                cp_base_id   igf_ap_fa_base_rec_all.base_id%TYPE,
                cp_item_code igf_aw_item.item_code%TYPE
               ) IS
    SELECT items.rowid row_id,
           items.*
      FROM igf_aw_coa_items items
     WHERE base_id            = cp_base_id
       AND item_code          = cp_item_code;
  l_item  c_item%ROWTYPE;

  CURSOR c_base(
                cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
               ) IS
    SELECT fa.rowid row_id,
           fa.*
      FROM igf_ap_fa_base_rec_all fa
     WHERE base_id = cp_base_id;
  l_base c_base%ROWTYPE;

  CURSOR c_terms(
                 cp_base_id   igf_ap_fa_base_rec_all.base_id%TYPE,
                 cp_item_code igf_aw_item.item_code%TYPE
                ) IS
    SELECT terms.ld_cal_type,
           terms.ld_sequence_number
      FROM igf_aw_coa_itm_terms terms
     WHERE base_id   = cp_base_id
       AND item_code = cp_item_code;


  CURSOR c_items(
                 cp_base_id   igf_ap_fa_base_rec_all.base_id%TYPE
                ) IS
    SELECT items.item_code
      FROM igf_aw_coa_items items
     WHERE base_id = cp_base_id;


  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.updateLock.debug','p_base_id:'||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.updateLock.debug','p_mode:'||p_mode);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.updateLock.debug','p_item_code:'||p_item_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.updateLock.debug','p_ld_cal_type:'||p_ld_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.updateLock.debug','p_ld_sequence_number:'||p_ld_sequence_number);
    END IF;

    IF p_mode = 'Y' THEN
      --starting lock mode
      IF p_base_id IS NOT NULL AND p_item_code IS NOT NULL AND p_ld_cal_type IS NOT NULL AND p_ld_sequence_number IS NOT NULL THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.updateLock.debug','Scenario 1');
        END IF;

        IF NOT isCoaLocked(p_base_id,p_item_code,p_ld_cal_type,p_ld_sequence_number) THEN
          --lock only if its not already locked
          l_item_term := NULL;
          OPEN c_item_term(p_base_id,p_item_code,p_ld_cal_type,p_ld_sequence_number);
          FETCH c_item_term INTO l_item_term;
          CLOSE c_item_term;

          fnd_message.set_name('IGF','IGF_AW_ITM_TRM_LOCK');
          fnd_message.set_token('ITEM',p_item_code);
          fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_ld_cal_type,p_ld_sequence_number));
          fnd_file.put_line(fnd_file.log,RPAD(' ',8)||fnd_message.get);


          igf_aw_coa_itm_terms_pkg.update_row(
                                              x_rowid              => l_item_term.row_id,
                                              x_base_id            => l_item_term.base_id,
                                              x_item_code          => l_item_term.item_code,
                                              x_amount             => l_item_term.amount,
                                              x_ld_cal_type        => l_item_term.ld_cal_type,
                                              x_ld_sequence_number => l_item_term.ld_sequence_number,
                                              x_mode               => 'R',
                                              x_lock_flag           => 'Y'
                                             );
        END IF;

        RETURN;

      ELSIF p_base_id IS NOT NULL AND p_item_code IS NOT NULL AND p_ld_cal_type IS NULL AND p_ld_sequence_number IS NULL THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.updateLock.debug','Scenario 2');
        END IF;

        IF NOT isCoaLocked(p_base_id,p_item_code) THEN

          l_item := NULL;
          OPEN c_item(p_base_id,p_item_code);
          FETCH c_item INTO l_item;
          CLOSE c_item;

          igf_aw_coa_items_pkg.update_row(
                                          x_rowid              => l_item.row_id,
                                          x_base_id            => l_item.base_id,
                                          x_item_code          => l_item.item_code,
                                          x_amount             => l_item.amount,
                                          x_pell_coa_amount    => l_item.pell_coa_amount,
                                          x_alt_pell_amount    => l_item.alt_pell_amount,
                                          x_fixed_cost         => l_item.fixed_cost,
                                          x_legacy_record_flag => l_item.legacy_record_flag,
                                          x_mode               => 'R',
                                          x_lock_flag           => 'Y'
                                         );
        END IF;

        FOR l_terms IN c_terms(p_base_id,p_item_code) LOOP
          --Locks are cascaded to the terms attached the item
          doLockInternal(p_base_id,p_item_code,l_terms.ld_cal_type,l_terms.ld_sequence_number);
        END LOOP;
        RETURN;

      ELSIF p_base_id IS NOT NULL AND p_item_code IS NULL AND p_ld_cal_type IS NULL AND p_ld_sequence_number IS NULL THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.updateLock.debug','Scenario 3');
        END IF;

        IF NOT isCoaLocked(p_base_id) THEN

          l_base := NULL;
          OPEN c_base(p_base_id);
          FETCH c_base INTO l_base;
          CLOSE c_base;

          fnd_message.set_name('IGF','IGF_AW_BUDGET_LOCK');
          fnd_file.put_line(fnd_file.log,RPAD(' ',4)||fnd_message.get);


          igf_ap_fa_base_rec_pkg.update_row(
                                            x_rowid                        => l_base.row_id,
                                            x_base_id                      => l_base.base_id,
                                            x_ci_cal_type                  => l_base.ci_cal_type,
                                            x_person_id                    => l_base.person_id,
                                            x_ci_sequence_number           => l_base.ci_sequence_number,
                                            x_org_id                       => l_base.org_id,
                                            x_coa_pending                  => l_base.coa_pending,
                                            x_verification_process_run     => l_base.verification_process_run,
                                            x_inst_verif_status_date       => l_base.inst_verif_status_date,
                                            x_manual_verif_flag            => l_base.manual_verif_flag,
                                            x_fed_verif_status             => l_base.fed_verif_status,
                                            x_fed_verif_status_date        => l_base.fed_verif_status_date,
                                            x_inst_verif_status            => l_base.inst_verif_status,
                                            x_nslds_eligible               => l_base.nslds_eligible,
                                            x_ede_correction_batch_id      => l_base.ede_correction_batch_id,
                                            x_fa_process_status_date       => l_base.fa_process_status_date,
                                            x_isir_corr_status             => l_base.isir_corr_status,
                                            x_isir_corr_status_date        => l_base.isir_corr_status_date,
                                            x_isir_status                  => l_base.isir_status,
                                            x_isir_status_date             => l_base.isir_status_date,
                                            x_coa_code_f                   => l_base.coa_code_f,
                                            x_coa_code_i                   => l_base.coa_code_i,
                                            x_coa_f                        => l_base.coa_f,
                                            x_coa_i                        => l_base.coa_i,
                                            x_disbursement_hold            => l_base.disbursement_hold,
                                            x_fa_process_status            => l_base.fa_process_status,
                                            x_notification_status          => l_base.notification_status,
                                            x_notification_status_date     => l_base.notification_status_date,
                                            x_packaging_hold               => l_base.packaging_hold,
                                            x_packaging_status             => l_base.packaging_status,
                                            x_packaging_status_date        => l_base.packaging_status_date,
                                            x_total_package_accepted       => l_base.total_package_accepted,
                                            x_total_package_offered        => l_base.total_package_offered,
                                            x_admstruct_id                 => l_base.admstruct_id,
                                            x_admsegment_1                 => l_base.admsegment_1,
                                            x_admsegment_2                 => l_base.admsegment_2,
                                            x_admsegment_3                 => l_base.admsegment_3,
                                            x_admsegment_4                 => l_base.admsegment_4,
                                            x_admsegment_5                 => l_base.admsegment_5,
                                            x_admsegment_6                 => l_base.admsegment_6,
                                            x_admsegment_7                 => l_base.admsegment_7,
                                            x_admsegment_8                 => l_base.admsegment_8,
                                            x_admsegment_9                 => l_base.admsegment_9,
                                            x_admsegment_10                => l_base.admsegment_10,
                                            x_admsegment_11                => l_base.admsegment_11,
                                            x_admsegment_12                => l_base.admsegment_12,
                                            x_admsegment_13                => l_base.admsegment_13,
                                            x_admsegment_14                => l_base.admsegment_14,
                                            x_admsegment_15                => l_base.admsegment_15,
                                            x_admsegment_16                => l_base.admsegment_16,
                                            x_admsegment_17                => l_base.admsegment_17,
                                            x_admsegment_18                => l_base.admsegment_18,
                                            x_admsegment_19                => l_base.admsegment_19,
                                            x_admsegment_20                => l_base.admsegment_20,
                                            x_packstruct_id                => l_base.packstruct_id,
                                            x_packsegment_1                => l_base.packsegment_1,
                                            x_packsegment_2                => l_base.packsegment_2,
                                            x_packsegment_3                => l_base.packsegment_3,
                                            x_packsegment_4                => l_base.packsegment_4,
                                            x_packsegment_5                => l_base.packsegment_5,
                                            x_packsegment_6                => l_base.packsegment_6,
                                            x_packsegment_7                => l_base.packsegment_7,
                                            x_packsegment_8                => l_base.packsegment_8,
                                            x_packsegment_9                => l_base.packsegment_9,
                                            x_packsegment_10               => l_base.packsegment_10,
                                            x_packsegment_11               => l_base.packsegment_11,
                                            x_packsegment_12               => l_base.packsegment_12,
                                            x_packsegment_13               => l_base.packsegment_13,
                                            x_packsegment_14               => l_base.packsegment_14,
                                            x_packsegment_15               => l_base.packsegment_15,
                                            x_packsegment_16               => l_base.packsegment_16,
                                            x_packsegment_17               => l_base.packsegment_17,
                                            x_packsegment_18               => l_base.packsegment_18,
                                            x_packsegment_19               => l_base.packsegment_19,
                                            x_packsegment_20               => l_base.packsegment_20,
                                            x_miscstruct_id                => l_base.miscstruct_id,
                                            x_miscsegment_1                => l_base.miscsegment_1,
                                            x_miscsegment_2                => l_base.miscsegment_2,
                                            x_miscsegment_3                => l_base.miscsegment_3,
                                            x_miscsegment_4                => l_base.miscsegment_4,
                                            x_miscsegment_5                => l_base.miscsegment_5,
                                            x_miscsegment_6                => l_base.miscsegment_6,
                                            x_miscsegment_7                => l_base.miscsegment_7,
                                            x_miscsegment_8                => l_base.miscsegment_8,
                                            x_miscsegment_9                => l_base.miscsegment_9,
                                            x_miscsegment_10               => l_base.miscsegment_10,
                                            x_miscsegment_11               => l_base.miscsegment_11,
                                            x_miscsegment_12               => l_base.miscsegment_12,
                                            x_miscsegment_13               => l_base.miscsegment_13,
                                            x_miscsegment_14               => l_base.miscsegment_14,
                                            x_miscsegment_15               => l_base.miscsegment_15,
                                            x_miscsegment_16               => l_base.miscsegment_16,
                                            x_miscsegment_17               => l_base.miscsegment_17,
                                            x_miscsegment_18               => l_base.miscsegment_18,
                                            x_miscsegment_19               => l_base.miscsegment_19,
                                            x_miscsegment_20               => l_base.miscsegment_20,
                                            x_prof_judgement_flg           => l_base.prof_judgement_flg,
                                            x_nslds_data_override_flg      => l_base.nslds_data_override_flg,
                                            x_target_group                 => l_base.target_group,
                                            x_coa_fixed                    => l_base.coa_fixed,
                                            x_coa_pell                     => l_base.coa_pell,
                                            x_mode                         => 'R',
                                            x_profile_status               => l_base.profile_status,
                                            x_profile_status_date          => l_base.profile_status_date,
                                            x_profile_fc                   => l_base.profile_fc,
                                            x_tolerance_amount             => l_base.tolerance_amount,
                                            x_manual_disb_hold             => l_base.manual_disb_hold,
                                            x_pell_alt_expense             => l_base.pell_alt_expense,
                                            x_assoc_org_num                => l_base.assoc_org_num,
                                            x_award_fmly_contribution_type => l_base.award_fmly_contribution_type,
                                            x_isir_locked_by               => l_base.isir_locked_by,
                                            x_adnl_unsub_loan_elig_flag    => l_base.adnl_unsub_loan_elig_flag,
                                            x_lock_coa_flag                => 'Y',
                                            x_lock_awd_flag                => l_base.lock_awd_flag
                                           );

        END IF;

        FOR l_items IN c_items(p_base_id) LOOP
          --Cascade lock to items.
          doLockInternal(p_base_id,l_items.item_code);
        END LOOP;
        RETURN;

      ELSIF p_base_id IS NOT NULL AND p_item_code IS NULL AND p_ld_cal_type IS NOT NULL AND p_ld_sequence_number IS NOT NULL THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.updateLock.debug','Scenario 4');
        END IF;

        FOR l_items IN c_items(p_base_id) LOOP
          doLockInternal(p_base_id,l_items.item_code,p_ld_cal_type,p_ld_sequence_number);
        END LOOP;
        RETURN;
      END IF;

    ELSIF p_mode = 'N' THEN
      --starting unlock mode
      IF p_base_id IS NOT NULL AND p_item_code IS NOT NULL AND p_ld_cal_type IS NOT NULL AND p_ld_sequence_number IS NOT NULL THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.updateLock.debug','Scenario 5');
        END IF;

        IF isCoaLocked(p_base_id,p_item_code,p_ld_cal_type,p_ld_sequence_number) THEN
          --unlock only if its already locked
          l_item_term := NULL;
          OPEN c_item_term(p_base_id,p_item_code,p_ld_cal_type,p_ld_sequence_number);
          FETCH c_item_term INTO l_item_term;
          CLOSE c_item_term;

          fnd_message.set_name('IGF','IGF_AW_ITM_TRM_UNLOCK');
          fnd_message.set_token('ITEM',p_item_code);
          fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_ld_cal_type,p_ld_sequence_number));
          fnd_file.put_line(fnd_file.log,RPAD(' ',4)||fnd_message.get);


          igf_aw_coa_itm_terms_pkg.update_row(
                                              x_rowid              => l_item_term.row_id,
                                              x_base_id            => l_item_term.base_id,
                                              x_item_code          => l_item_term.item_code,
                                              x_amount             => l_item_term.amount,
                                              x_ld_cal_type        => l_item_term.ld_cal_type,
                                              x_ld_sequence_number => l_item_term.ld_sequence_number,
                                              x_mode               => 'R',
                                              x_lock_flag           => 'N'
                                             );
        END IF;

        IF g_unlock_level = 3 THEN
          --Remove item level lock
          doUnlockInternal(p_base_id,p_item_code);
          --Remove student level lock
          doUnlockInternal(p_base_id);
        END IF;
        RETURN;

      ELSIF p_base_id IS NOT NULL AND p_item_code IS NOT NULL AND p_ld_cal_type IS NULL AND p_ld_sequence_number IS NULL THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.updateLock.debug','Scenario 6');
        END IF;

        IF isCoaLocked(p_base_id,p_item_code) THEN

          l_item := NULL;
          OPEN c_item(p_base_id,p_item_code);
          FETCH c_item INTO l_item;
          CLOSE c_item;

          igf_aw_coa_items_pkg.update_row(
                                          x_rowid              => l_item.row_id,
                                          x_base_id            => l_item.base_id,
                                          x_item_code          => l_item.item_code,
                                          x_amount             => l_item.amount,
                                          x_pell_coa_amount    => l_item.pell_coa_amount,
                                          x_alt_pell_amount    => l_item.alt_pell_amount,
                                          x_fixed_cost         => l_item.fixed_cost,
                                          x_legacy_record_flag => l_item.legacy_record_flag,
                                          x_mode               => 'R',
                                          x_lock_flag           => 'N'
                                         );
        END IF;

        IF g_unlock_level <= 2 THEN
          FOR l_terms IN c_terms(p_base_id,p_item_code) LOOP
            --Unlocks are cascaded to the terms attached the item
            doUnlockInternal(p_base_id,p_item_code,l_terms.ld_cal_type,l_terms.ld_sequence_number);
          END LOOP;
        END IF;
        IF g_unlock_level = 2 THEN
          --Remove student level lock
          doUnlockInternal(p_base_id);
        END IF;
        RETURN;

      ELSIF p_base_id IS NOT NULL AND p_item_code IS NULL AND p_ld_cal_type IS NULL AND p_ld_sequence_number IS NULL THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.updateLock.debug','Scenario 7');
        END IF;

        IF isCoaLocked(p_base_id) THEN

          l_base := NULL;
          OPEN c_base(p_base_id);
          FETCH c_base INTO l_base;
          CLOSE c_base;

          fnd_message.set_name('IGF','IGF_AW_BUDGET_UNLOCK');
          fnd_file.put_line(fnd_file.log,RPAD(' ',8)||fnd_message.get);


          igf_ap_fa_base_rec_pkg.update_row(
                                            x_rowid                        => l_base.row_id,
                                            x_base_id                      => l_base.base_id,
                                            x_ci_cal_type                  => l_base.ci_cal_type,
                                            x_person_id                    => l_base.person_id,
                                            x_ci_sequence_number           => l_base.ci_sequence_number,
                                            x_org_id                       => l_base.org_id,
                                            x_coa_pending                  => l_base.coa_pending,
                                            x_verification_process_run     => l_base.verification_process_run,
                                            x_inst_verif_status_date       => l_base.inst_verif_status_date,
                                            x_manual_verif_flag            => l_base.manual_verif_flag,
                                            x_fed_verif_status             => l_base.fed_verif_status,
                                            x_fed_verif_status_date        => l_base.fed_verif_status_date,
                                            x_inst_verif_status            => l_base.inst_verif_status,
                                            x_nslds_eligible               => l_base.nslds_eligible,
                                            x_ede_correction_batch_id      => l_base.ede_correction_batch_id,
                                            x_fa_process_status_date       => l_base.fa_process_status_date,
                                            x_isir_corr_status             => l_base.isir_corr_status,
                                            x_isir_corr_status_date        => l_base.isir_corr_status_date,
                                            x_isir_status                  => l_base.isir_status,
                                            x_isir_status_date             => l_base.isir_status_date,
                                            x_coa_code_f                   => l_base.coa_code_f,
                                            x_coa_code_i                   => l_base.coa_code_i,
                                            x_coa_f                        => l_base.coa_f,
                                            x_coa_i                        => l_base.coa_i,
                                            x_disbursement_hold            => l_base.disbursement_hold,
                                            x_fa_process_status            => l_base.fa_process_status,
                                            x_notification_status          => l_base.notification_status,
                                            x_notification_status_date     => l_base.notification_status_date,
                                            x_packaging_hold               => l_base.packaging_hold,
                                            x_packaging_status             => l_base.packaging_status,
                                            x_packaging_status_date        => l_base.packaging_status_date,
                                            x_total_package_accepted       => l_base.total_package_accepted,
                                            x_total_package_offered        => l_base.total_package_offered,
                                            x_admstruct_id                 => l_base.admstruct_id,
                                            x_admsegment_1                 => l_base.admsegment_1,
                                            x_admsegment_2                 => l_base.admsegment_2,
                                            x_admsegment_3                 => l_base.admsegment_3,
                                            x_admsegment_4                 => l_base.admsegment_4,
                                            x_admsegment_5                 => l_base.admsegment_5,
                                            x_admsegment_6                 => l_base.admsegment_6,
                                            x_admsegment_7                 => l_base.admsegment_7,
                                            x_admsegment_8                 => l_base.admsegment_8,
                                            x_admsegment_9                 => l_base.admsegment_9,
                                            x_admsegment_10                => l_base.admsegment_10,
                                            x_admsegment_11                => l_base.admsegment_11,
                                            x_admsegment_12                => l_base.admsegment_12,
                                            x_admsegment_13                => l_base.admsegment_13,
                                            x_admsegment_14                => l_base.admsegment_14,
                                            x_admsegment_15                => l_base.admsegment_15,
                                            x_admsegment_16                => l_base.admsegment_16,
                                            x_admsegment_17                => l_base.admsegment_17,
                                            x_admsegment_18                => l_base.admsegment_18,
                                            x_admsegment_19                => l_base.admsegment_19,
                                            x_admsegment_20                => l_base.admsegment_20,
                                            x_packstruct_id                => l_base.packstruct_id,
                                            x_packsegment_1                => l_base.packsegment_1,
                                            x_packsegment_2                => l_base.packsegment_2,
                                            x_packsegment_3                => l_base.packsegment_3,
                                            x_packsegment_4                => l_base.packsegment_4,
                                            x_packsegment_5                => l_base.packsegment_5,
                                            x_packsegment_6                => l_base.packsegment_6,
                                            x_packsegment_7                => l_base.packsegment_7,
                                            x_packsegment_8                => l_base.packsegment_8,
                                            x_packsegment_9                => l_base.packsegment_9,
                                            x_packsegment_10               => l_base.packsegment_10,
                                            x_packsegment_11               => l_base.packsegment_11,
                                            x_packsegment_12               => l_base.packsegment_12,
                                            x_packsegment_13               => l_base.packsegment_13,
                                            x_packsegment_14               => l_base.packsegment_14,
                                            x_packsegment_15               => l_base.packsegment_15,
                                            x_packsegment_16               => l_base.packsegment_16,
                                            x_packsegment_17               => l_base.packsegment_17,
                                            x_packsegment_18               => l_base.packsegment_18,
                                            x_packsegment_19               => l_base.packsegment_19,
                                            x_packsegment_20               => l_base.packsegment_20,
                                            x_miscstruct_id                => l_base.miscstruct_id,
                                            x_miscsegment_1                => l_base.miscsegment_1,
                                            x_miscsegment_2                => l_base.miscsegment_2,
                                            x_miscsegment_3                => l_base.miscsegment_3,
                                            x_miscsegment_4                => l_base.miscsegment_4,
                                            x_miscsegment_5                => l_base.miscsegment_5,
                                            x_miscsegment_6                => l_base.miscsegment_6,
                                            x_miscsegment_7                => l_base.miscsegment_7,
                                            x_miscsegment_8                => l_base.miscsegment_8,
                                            x_miscsegment_9                => l_base.miscsegment_9,
                                            x_miscsegment_10               => l_base.miscsegment_10,
                                            x_miscsegment_11               => l_base.miscsegment_11,
                                            x_miscsegment_12               => l_base.miscsegment_12,
                                            x_miscsegment_13               => l_base.miscsegment_13,
                                            x_miscsegment_14               => l_base.miscsegment_14,
                                            x_miscsegment_15               => l_base.miscsegment_15,
                                            x_miscsegment_16               => l_base.miscsegment_16,
                                            x_miscsegment_17               => l_base.miscsegment_17,
                                            x_miscsegment_18               => l_base.miscsegment_18,
                                            x_miscsegment_19               => l_base.miscsegment_19,
                                            x_miscsegment_20               => l_base.miscsegment_20,
                                            x_prof_judgement_flg           => l_base.prof_judgement_flg,
                                            x_nslds_data_override_flg      => l_base.nslds_data_override_flg,
                                            x_target_group                 => l_base.target_group,
                                            x_coa_fixed                    => l_base.coa_fixed,
                                            x_coa_pell                     => l_base.coa_pell,
                                            x_mode                         => 'R',
                                            x_profile_status               => l_base.profile_status,
                                            x_profile_status_date          => l_base.profile_status_date,
                                            x_profile_fc                   => l_base.profile_fc,
                                            x_tolerance_amount             => l_base.tolerance_amount,
                                            x_manual_disb_hold             => l_base.manual_disb_hold,
                                            x_pell_alt_expense             => l_base.pell_alt_expense,
                                            x_assoc_org_num                => l_base.assoc_org_num,
                                            x_award_fmly_contribution_type => l_base.award_fmly_contribution_type,
                                            x_isir_locked_by               => l_base.isir_locked_by,
                                            x_adnl_unsub_loan_elig_flag    => l_base.adnl_unsub_loan_elig_flag,
                                            x_lock_coa_flag                => 'N',
                                            x_lock_awd_flag                => l_base.lock_awd_flag
                                           );
        END IF;
        IF g_unlock_level = 1 THEN
          FOR l_items IN c_items(p_base_id) LOOP
            --Cascade unlock to items.
            doUnlockInternal(p_base_id,l_items.item_code);
          END LOOP;
        END IF;

      ELSIF p_base_id IS NOT NULL AND p_item_code IS NULL AND p_ld_cal_type IS NOT NULL AND p_ld_sequence_number IS NOT NULL THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.updateLock.debug','Scenario 8');
        END IF;

        FOR l_items IN c_items(p_base_id) LOOP
          doUnlockInternal(p_base_id,l_items.item_code,p_ld_cal_type,p_ld_sequence_number);
        END LOOP;
        RETURN;
      END IF;

    END IF;

  END updateLock;

  FUNCTION doLock(
                  p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                  p_item_code           igf_aw_item.item_code%TYPE DEFAULT NULL,
                  p_ld_cal_type         igs_ca_inst.cal_type%TYPE DEFAULT NULL,
                  p_ld_sequence_number  igs_ca_inst.sequence_number%TYPE DEFAULT NULL
                 ) RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 07-OCT-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doLock.debug','p_base_id:'||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doLock.debug','p_item_code:'||p_item_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doLock.debug','p_ld_cal_type:'||p_ld_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doLock.debug','p_ld_sequence_number:'||p_ld_sequence_number);
    END IF;

    SAVEPOINT IGF_AW_COA_GEN_DOLOCK;
    doLockInternal(p_base_id,p_item_code,p_ld_cal_type,p_ld_sequence_number);
    RETURN 'Y';

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO IGF_AW_COA_GEN_DOLOCK;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_COA_GEN.DOLOCK ' || SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END doLock;

  FUNCTION doUnlock(
                    p_base_id             igf_ap_fa_base_rec_all.base_id%TYPE,
                    p_item_code           igf_aw_item.item_code%TYPE DEFAULT NULL,
                    p_ld_cal_type         igs_ca_inst.cal_type%TYPE DEFAULT NULL,
                    p_ld_sequence_number  igs_ca_inst.sequence_number%TYPE DEFAULT NULL
                   ) RETURN VARCHAR2 AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 07-OCT-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doUnlock.debug','p_base_id:'||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doUnlock.debug','p_item_code:'||p_item_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doUnlock.debug','p_ld_cal_type:'||p_ld_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doUnlock.debug','p_ld_sequence_number:'||p_ld_sequence_number);
    END IF;

    SAVEPOINT IGF_AW_COA_GEN_DOUNLOCK;
    IF p_ld_cal_type IS NOT NULL AND p_ld_sequence_number IS NOT NULL THEN
      g_unlock_level := 3;
    ELSIF p_item_code IS NOT NULL THEN
      g_unlock_level := 2;
    ELSE
      g_unlock_level := 1;
    END IF;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.doUnlock.debug','g_unlock_level:'||g_unlock_level);
    END IF;
    doUnlockInternal(p_base_id,p_item_code,p_ld_cal_type,p_ld_sequence_number);
    RETURN 'Y';

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO IGF_AW_COA_GEN_DOUNLOCK;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_COA_GEN.DOUNLOCK ' || SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END doUnlock;

  PROCEDURE get_coa_months(
                           p_base_id      IN igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE DEFAULT NULL,
                           p_start_dt     OUT NOCOPY DATE,
                           p_end_dt       OUT NOCOPY DATE,
                           p_coa_months   OUT NOCOPY NUMBER
                          ) IS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 6-OCT-2003
  --
  --Purpose:
  --   To check if anticipated values can be used if actual values are not used
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  CURSOR c_terms(
                 cp_base_id       igf_ap_fa_base_rec.base_id%TYPE,
                 cp_awd_prd_code  igf_aw_awd_prd_term.award_prd_cd%TYPE
                ) IS
    SELECT coa.ld_cal_type,
           coa.ld_sequence_number
      FROM igf_aw_awd_prd_term ap,
           igf_ap_fa_base_rec_all fa,
           igf_aw_coa_itm_terms coa
     WHERE fa.base_id = cp_base_id
       AND fa.ci_cal_type = ap.ci_cal_type
       AND fa.ci_sequence_number = ap.ci_sequence_number
       AND coa.base_id = cp_base_id
       AND coa.ld_cal_type = ap.ld_cal_type
       AND coa.ld_sequence_number = ap.ld_sequence_number
       AND ap.award_prd_cd = cp_awd_prd_code
     GROUP BY coa.ld_cal_type,coa.ld_sequence_number;

  CURSOR c_terms_awd(
                     cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                    ) IS
    SELECT coa.ld_cal_type,
           coa.ld_sequence_number
      FROM igf_aw_coa_itm_terms coa
     WHERE coa.base_id = cp_base_id
     GROUP BY coa.ld_cal_type,coa.ld_sequence_number;

  CURSOR get_round_off(
                       cp_base_id igf_ap_fa_base_rec.base_id%TYPE
                      ) IS
     SELECT num_days_divisor, roundoff_fact
       FROM igf_ap_efc_v efc,
            igf_ap_fa_base_rec_all  fabase
      WHERE efc.ci_cal_type       = fabase.ci_cal_type
       AND efc.ci_sequence_number = fabase.ci_sequence_number
       AND fabase.base_id         = cp_base_id;
  lv_round_off_rec get_round_off%ROWTYPE;

  l_start_dt DATE;
  l_end_dt   DATE;
  l_first_cycle VARCHAR2(1);
  l_no_of_months NUMBER;

  BEGIN
    l_first_cycle := 'Y' ;
    IF p_awd_prd_code IS NOT NULL THEN
      FOR l_terms IN c_terms(p_base_id,p_awd_prd_code) LOOP
        igf_ap_gen_001.get_term_dates(
                                      p_base_id             => p_base_id,
                                      p_ld_cal_type         => l_terms.ld_cal_type,
                                      p_ld_sequence_number  => l_terms.ld_sequence_number,
                                      p_ld_start_date       => l_start_dt,
                                      p_ld_end_date         => l_end_dt
                                     );
        IF l_first_cycle = 'Y' THEN
          p_start_dt := l_start_dt;
          p_end_dt := l_end_dt;
          l_first_cycle := 'N';
        ELSE
          p_start_dt := LEAST(p_start_dt,l_start_dt);
          p_end_dt := GREATEST(p_end_dt,l_end_dt);
        END IF;
      END LOOP;
    ELSE
      FOR l_terms IN c_terms_awd(p_base_id) LOOP
        igf_ap_gen_001.get_term_dates(
                                      p_base_id             => p_base_id,
                                      p_ld_cal_type         => l_terms.ld_cal_type,
                                      p_ld_sequence_number  => l_terms.ld_sequence_number,
                                      p_ld_start_date       => l_start_dt,
                                      p_ld_end_date         => l_end_dt
                                     );
        IF l_first_cycle = 'Y' THEN
          p_start_dt := l_start_dt;
          p_end_dt := l_end_dt;
          l_first_cycle := 'N';
        ELSE
          p_start_dt := LEAST(p_start_dt,l_start_dt);
          p_end_dt := GREATEST(p_end_dt,l_end_dt);
        END IF;
      END LOOP;
    END IF;
    OPEN get_round_off(p_base_id);
    FETCH get_round_off INTO lv_round_off_rec;
    CLOSE get_round_off;

    l_no_of_months := (p_end_dt - p_start_dt) / NVL(lv_round_off_rec.num_days_divisor,30);

    IF (lv_round_off_rec.roundoff_fact = 'RU') THEN
      -- Round up to the nearest whole number
      l_no_of_months := CEIL( l_no_of_months );
    ELSIF (lv_round_off_rec.roundoff_fact = 'RD' ) THEN
      -- Round down to the nearest whole number
      l_no_of_months := FLOOR( l_no_of_months );
    ELSE
      -- Round off factor is 'RH', Round to the nearest whole number
      l_no_of_months := ROUND( l_no_of_months );
    END IF;
    p_coa_months := l_no_of_months;
  END get_coa_months;

  FUNCTION coa_duration(
                        p_base_id      IN igf_ap_fa_base_rec_all.base_id%TYPE,
                        p_awd_prd_code IN igf_aw_awd_prd_term.award_prd_cd%TYPE
                       ) RETURN NUMBER AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created:
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  l_start_dt DATE;
  l_end_dt   DATE;
  l_coa_duration NUMBER;
  BEGIN
    get_coa_months(
                   p_base_id      => p_base_id,
                   p_awd_prd_code => p_awd_prd_code,
                   p_start_dt     => l_start_dt,
                   p_end_dt       => l_end_dt,
                   p_coa_months   => l_coa_duration
                  );
    RETURN l_coa_duration;
  END coa_duration;

  FUNCTION canUseAnticipVal RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 6-OCT-2003
  --
  --Purpose:
  --   To check if anticipated values can be used if actual values are not used
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  lv_profile_value   VARCHAR2(10);
  BEGIN
    fnd_profile.get('IGF_AW_USE_ANT_DATA',lv_profile_value);
    IF lv_profile_value ='Y' THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END canUseAnticipVal;

  FUNCTION getBaseDetails(
                          p_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                          p_ld_cal_type        igs_ca_inst.cal_type%TYPE,
                          p_ld_sequence_number igs_ca_inst.sequence_number%TYPE
                         ) RETURN base_details AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 11-Oct-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --museshad    16-Sep-2005     Bug# 4604393
  --                            Changed the logic for deriving Actual/Predictive
  --                            Class Standing
  -------------------------------------------------------------------

  l_term_start DATE;
  l_term_end   DATE;

  lv_usage VARCHAR2(1); -- 1 -> Actual, 2 -> Actual,if not available then Anticipated, 3 -> Anticipated.

  l_person_id hz_parties.party_id%TYPE;

  l_base_det  base_details;

  -- Get person_id
  CURSOR c_person_id(
                     cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                    ) IS
    SELECT person_id
      FROM igf_ap_fa_base_rec_all
     WHERE base_id = cp_base_id;

  -- Get anticipated values
  CURSOR c_anticip(
                   cp_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                   cp_ld_cal_type        igs_ca_inst.cal_type%TYPE,
                   cp_ld_sequence_number igs_ca_inst.sequence_number%TYPE
                  ) IS
    SELECT org_unit_cd,
           program_type,
           program_location_cd,
           program_cd,
           class_standing,
           residency_status_code,
           housing_status_code,
           attendance_type,
           attendance_mode,
           months_enrolled_num,
           credit_points_num
      FROM igf_ap_fa_ant_data
     WHERE base_id            = cp_base_id
       AND ld_cal_type        = cp_ld_cal_type
       AND ld_sequence_number = cp_ld_sequence_number;

  l_anticip   c_anticip%ROWTYPE;

  -- Get org unit
  CURSOR c_org(
               cp_person_id          hz_parties.party_id%TYPE,
               cp_ld_cal_type        igs_ca_inst.cal_type%TYPE,
               cp_ld_sequence_number igs_ca_inst.sequence_number%TYPE
              ) IS
    SELECT ps.responsible_org_unit_cd,1 record_order
      FROM igs_en_spa_terms key,
           igs_ps_ver ps
     WHERE key.key_program_flag = 'Y'
       AND person_id = cp_person_id
       AND ps.course_cd = key.program_cd
       AND ps.version_number = key.program_version
       AND key.term_cal_type = cp_ld_cal_type
       AND key.term_sequence_number = cp_ld_sequence_number
    UNION ALL
    SELECT ps.responsible_org_unit_cd,
           2 record_order
      FROM igs_en_stdnt_ps_att att,
           igs_ps_ver ps
     WHERE att.person_id = cp_person_id
       AND att.key_program = 'Y'
       AND att.course_cd = ps.course_cd
       AND att.version_number = ps.version_number
    ORDER BY record_order;

  -- Get program type
  CURSOR c_prg_type(
                    cp_person_id          hz_parties.party_id%TYPE,
                    cp_ld_cal_type        igs_ca_inst.cal_type%TYPE,
                    cp_ld_sequence_number igs_ca_inst.sequence_number%TYPE
                   ) IS
    SELECT pt.course_type,1 record_order
      FROM igs_en_spa_terms sp,
           igs_ps_ver pv,
           igs_ps_type_v pt
     WHERE sp.key_program_flag = 'Y'
       AND sp.program_cd = pv.course_cd
       AND sp.program_version = pv.version_number
       AND pv.course_type = pt.course_type
       AND sp.person_id = cp_person_id
       AND sp.term_cal_type = cp_ld_cal_type
       AND sp.term_sequence_number = cp_ld_sequence_number
    UNION ALL
    SELECT pt.course_type,2 record_order
      FROM igs_en_stdnt_ps_att sp,
           igs_ps_ver pv,
           igs_ps_type_v pt
    WHERE sp.key_program = 'Y'
      AND sp.course_cd = pv.course_cd
      AND sp.version_number = pv.version_number
      AND pv.course_type = pt.course_type
      AND sp.person_id = cp_person_id
    ORDER BY record_order;

  -- Get program location
  CURSOR c_prog_loc(
                    cp_person_id          hz_parties.party_id%TYPE,
                    cp_ld_cal_type        igs_ca_inst.cal_type%TYPE,
                    cp_ld_sequence_number igs_ca_inst.sequence_number%TYPE
                   ) IS
    SELECT location_cd,
           1 record_order
      FROM igs_en_spa_terms
     WHERE key_program_flag = 'Y'
       AND person_id = cp_person_id
       AND term_cal_type = cp_ld_cal_type
       AND term_sequence_number = cp_ld_sequence_number
    UNION ALL
    SELECT location_cd,
           2 record_order
      FROM igs_en_stdnt_ps_att
     WHERE key_program = 'Y'
       AND person_id = cp_person_id
    ORDER BY record_order;

  -- Get get program code
  CURSOR c_prog_code(
                     cp_person_id          hz_parties.party_id%TYPE,
                     cp_ld_cal_type        igs_ca_inst.cal_type%TYPE,
                     cp_ld_sequence_number igs_ca_inst.sequence_number%TYPE
                    ) IS
    SELECT program_cd,
           program_version,
           1 record_order
      FROM igs_en_spa_terms
     WHERE key_program_flag = 'Y'
       AND person_id = cp_person_id
       AND term_cal_type = cp_ld_cal_type
       AND term_sequence_number = cp_ld_sequence_number
    UNION ALL
    SELECT course_cd program_cd,
           version_number program_version,
           2 record_order
      FROM igs_en_stdnt_ps_att
     WHERE key_program = 'Y'
       AND person_id = cp_person_id
    ORDER BY record_order;


  -- Get attendance type
  CURSOR c_att_type(
                    cp_person_id          hz_parties.party_id%TYPE,
                    cp_ld_cal_type        igs_ca_inst.cal_type%TYPE,
                    cp_ld_sequence_number igs_ca_inst.sequence_number%TYPE
                   ) IS
    SELECT attendance_type,
           1 record_order
      FROM igs_en_spa_terms
     WHERE key_program_flag = 'Y'
       AND person_id = cp_person_id
       AND term_cal_type = cp_ld_cal_type
       AND term_sequence_number = cp_ld_sequence_number
    UNION ALL
    SELECT attendance_type,
           2 record_order
      FROM igs_en_stdnt_ps_att
     WHERE key_program = 'Y'
       AND person_id = cp_person_id
    ORDER BY record_order;

  -- Get attendance mode
  CURSOR c_att_mode(
                    cp_person_id          hz_parties.party_id%TYPE,
                    cp_ld_cal_type        igs_ca_inst.cal_type%TYPE,
                    cp_ld_sequence_number igs_ca_inst.sequence_number%TYPE
                   ) IS
    SELECT attendance_mode,
           1 record_order
      FROM igs_en_spa_terms
     WHERE key_program_flag = 'Y'
       AND person_id = cp_person_id
       AND term_cal_type = cp_ld_cal_type
       AND term_sequence_number = cp_ld_sequence_number
    UNION ALL
    SELECT attendance_mode,
           2 record_order
      FROM igs_en_stdnt_ps_att
     WHERE key_program = 'Y'
       AND person_id = cp_person_id
    ORDER BY record_order;


  l_attendance    igs_en_atd_type_load.attendance_type%TYPE;
  l_credit_points igs_en_su_attempt.override_achievable_cp%TYPE;
  l_fte           igs_en_su_attempt.override_achievable_cp%TYPE;

  -- Get residency status
  l_residency_class   igs_pe_res_dtls.residency_class_cd%TYPE;

  -- Get housing status
  CURSOR c_housing_status(
                          cp_person_id          hz_parties.party_id%TYPE,
                          cp_ld_cal_type        igs_ca_inst.cal_type%TYPE,
                          cp_ld_sequence_number igs_ca_inst.sequence_number%TYPE
                         ) IS
    SELECT teach_period_resid_stat_cd
      FROM igs_pe_teach_periods_all
     WHERE person_id = cp_person_id
       AND cal_type = cp_ld_cal_type
       AND sequence_number = cp_ld_sequence_number;

  l_term_duration NUMBER;

  CURSOR get_round_off(
                       cp_base_id igf_ap_fa_base_rec.base_id%TYPE
                      ) IS
     SELECT num_days_divisor, roundoff_fact
       FROM igf_ap_efc_v efc,
            igf_ap_fa_base_rec_all  fabase
      WHERE efc.ci_cal_type       = fabase.ci_cal_type
       AND efc.ci_sequence_number = fabase.ci_sequence_number
       AND fabase.base_id         = cp_base_id;
  lv_round_off_rec get_round_off%ROWTYPE;
  l_dummy_number NUMBER;

  -- museshad (Bug# 4604393)
  l_term_start_date   DATE := NULL;
  l_pred_flag         VARCHAR2(1);
  -- museshad (Bug# 4604393)
  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','p_base_id:'||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','p_ld_cal_type:'||p_ld_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','p_ld_sequence_number:'||p_ld_sequence_number);
    END IF;

    l_term_start := NULL;
    l_term_end   := NULL;
    lv_usage     := NULL;
    l_term_duration := NULL;

    igf_ap_gen_001.get_term_dates(
                                  p_base_id            => p_base_id,
                                  p_ld_cal_type        => p_ld_cal_type,
                                  p_ld_sequence_number => p_ld_sequence_number,
                                  p_ld_start_date      => l_term_start,
                                  p_ld_end_date        => l_term_end
                                 );
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_term_start:'||l_term_start);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_term_end:'||l_term_end);
    END IF;

    IF l_term_end < SYSDATE THEN
      --past term. Use actual values
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','-------------Past Term-------------');
      END IF;
      IF canUseAnticipVal THEN
        lv_usage := '2';
      ELSE
        lv_usage := '1';
      END IF;
    ELSIF SYSDATE BETWEEN l_term_start AND l_term_end THEN
      --Current term. Use actual values
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','-------------Current Term-------------');
      END IF;
      IF canUseAnticipVal THEN
        lv_usage := '2';
      ELSE
        lv_usage := '1';
      END IF;
    ELSE
      --Future term. Use anticipated values
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','-------------Future Term-------------');
      END IF;
      lv_usage := '3';
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','lv_usage:'||lv_usage);
    END IF;

    --Derive person id first
    l_person_id := NULL;
    OPEN c_person_id(p_base_id);
    FETCH c_person_id INTO l_person_id;
    CLOSE c_person_id;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_person_id:'||l_person_id);
    END IF;

    l_base_det := NULL;

    l_anticip := NULL;

    IF lv_usage IN ('2','3') THEN
      --derive anticipated values. For usage type '2', the values will be used only if actuals are not available
      l_anticip := NULL;
      OPEN c_anticip(p_base_id,p_ld_cal_type,p_ld_sequence_number);
      FETCH c_anticip INTO l_anticip;
      CLOSE c_anticip;
    END IF;

    IF lv_usage IN ('1','2') THEN

      --derive actual org unit code
      OPEN c_org(l_person_id,p_ld_cal_type,p_ld_sequence_number);
      FETCH c_org INTO l_base_det.org_unit_cd,l_dummy_number;
      CLOSE c_org;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_base_det.org_unit_cd:'||l_base_det.org_unit_cd);
      END IF;

      IF l_base_det.org_unit_cd IS NULL AND lv_usage = '2' THEN
        --Use anticipated org unit code
        l_base_det.org_unit_cd := l_anticip.org_unit_cd;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_anticip.org_unit_cd:'||l_anticip.org_unit_cd);
        END IF;
      END IF;

      --derive actual program type code
      OPEN c_prg_type(l_person_id,p_ld_cal_type,p_ld_sequence_number);
      FETCH c_prg_type INTO l_base_det.program_type,l_dummy_number;
      CLOSE c_prg_type;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_base_det.program_type:'||l_base_det.program_type);
      END IF;

      IF l_base_det.program_type IS NULL AND lv_usage = '2' THEN
        --Use anticipated prog type
        l_base_det.program_type := l_anticip.program_type;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_anticip.program_type:'||l_anticip.program_type);
        END IF;
      END IF;

      --derive actual program location
      OPEN c_prog_loc(l_person_id,p_ld_cal_type,p_ld_sequence_number);
      FETCH c_prog_loc INTO l_base_det.program_location_cd,l_dummy_number;
      CLOSE c_prog_loc;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_base_det.program_location_cd:'||l_base_det.program_location_cd);
      END IF;

      IF l_base_det.program_location_cd IS NULL AND lv_usage = '2' THEN
        --use anticipated program location
        l_base_det.program_location_cd := l_anticip.program_location_cd;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_anticip.program_location_cd:'||l_anticip.program_location_cd);
        END IF;
      END IF;

      --derive actual program code
      OPEN c_prog_code(l_person_id,p_ld_cal_type,p_ld_sequence_number);
      FETCH c_prog_code INTO l_base_det.program_cd,l_base_det.version_number,l_dummy_number;
      CLOSE c_prog_code;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_base_det.program_cd:'||l_base_det.program_cd);
      END IF;

      IF l_base_det.program_cd IS NULL AND lv_usage = '2' THEN
        --use anticipated program code
        l_base_det.program_cd   := l_anticip.program_cd;
        l_base_det.version_number := NULL;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_anticip.program_cd:'||l_anticip.program_cd);
        END IF;
      END IF;

      -- museshad (Bug# 4604393)
      -- Derive OSS class standing
      l_term_start_date := igf_aw_packaging.get_term_start_date(
                                                                  p_base_id             =>  p_base_id,
                                                                  p_ld_cal_type         =>  p_ld_cal_type,
                                                                  p_ld_sequence_number  =>  p_ld_sequence_number
                                                               );

      IF l_term_start_date IS NOT NULL THEN
        IF l_term_start_date > TRUNC(SYSDATE) THEN
          -- Predictive Class Standing
          l_pred_flag := 'Y';

          -- Log message
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,
                          'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                          'Computing PREDICTIVE class standing for date ' || TO_CHAR(l_term_start_date, 'DD-MON-YYYY'));
          END IF;
        ELSE
          -- Actual Class Standing
          l_pred_flag := 'N';

          -- Log message
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,
                          'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                          'Computing ACTUAL class standing for date ' || TO_CHAR(l_term_start_date, 'DD-MON-YYYY'));
          END IF;
        END IF;

        -- Get the Class Standing
        l_base_det.class_standing := igs_pr_get_class_std.get_class_standing(
                                                                              p_person_id               =>  l_person_id,
                                                                              p_course_cd               =>  l_base_det.program_cd,
                                                                              p_predictive_ind          =>  l_pred_flag,
                                                                              p_effective_dt            =>  l_term_start_date,
                                                                              p_load_cal_type           =>  NULL,
                                                                              p_load_ci_sequence_number =>  NULL
                                                                            );

        -- Log message
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,
                        'igf.plsql.igf_aw_packng_subfns.get_class_stnd.debug',
                        'Class Standing= ' || l_base_det.class_standing);
        END IF;
      ELSE
        -- Cannot compute the start date of the term.
        -- So, cannot derive Class Standing
        l_base_det.class_standing := NULL;

        -- Log
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,
                         'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug',
                         'Person_Id= ' ||l_person_id|| ', ld_cal_type= ' ||p_ld_cal_type|| ', ld_sequence_number= ' ||p_ld_sequence_number||
                         '. Cannot derive class standing bcoz the start date of the term is not defined');
        END IF;
      END IF;
      -- museshad (Bug# 4604393)

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_base_det.class_standing:'||l_base_det.class_standing);
      END IF;

      IF l_base_det.class_standing IS NULL AND lv_usage = '2' THEN
        --use anticipated class standing
        l_base_det.class_standing := l_anticip.class_standing;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_anticip.class_standing:'||l_anticip.class_standing);
        END IF;
      END IF;

      --derive actual attendance mode
      OPEN c_att_mode(l_person_id,p_ld_cal_type,p_ld_sequence_number);
      FETCH c_att_mode INTO l_base_det.attendance_mode,l_dummy_number;
      CLOSE c_att_mode;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_base_det.attendance_mode:'||l_base_det.attendance_mode);
      END IF;

      IF l_base_det.attendance_mode IS NULL AND lv_usage = '2' THEN
        --use anticipated attendance mode
        l_base_det.attendance_mode   := l_anticip.attendance_mode;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_anticip.attendance_mode:'||l_anticip.attendance_mode);
        END IF;
      END IF;

      BEGIN
        --derive actual credit points
        igs_en_prc_load.enrp_get_inst_latt(
                                           p_person_id       => l_person_id,
                                           p_load_cal_type   => p_ld_cal_type,
                                           p_load_seq_number => p_ld_sequence_number,
                                           p_attendance      => l_attendance,
                                           p_credit_points   => l_base_det.credit_points_num,
                                           p_fte             => l_fte
                                          );
        EXCEPTION
          WHEN OTHERS THEN
            l_base_det.credit_points_num := NULL;
	    l_attendance := NULL;
      END;
      IF l_base_det.credit_points_num IS NULL AND lv_usage = '2' THEN
        --derive anticipated credit points
        l_base_det.credit_points_num := l_anticip.credit_points_num;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_anticip.credit_points_num:'||l_anticip.credit_points_num);
        END IF;

      END IF;

      --derive actual attendance_type--the value of the l_attendance is derived from the above function call i.e enrp_get_inst_latt
      l_base_det.attendance_type := l_attendance;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_base_det.attendance_type'||l_base_det.attendance_type);
      END IF;

      IF l_base_det.attendance_type IS NULL AND lv_usage = '2' THEN
          --use anticipated attendance type
	l_base_det.attendance_type   := l_anticip.attendance_type;

	IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
		  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_anticip.attendance_type:'||l_anticip.attendance_type);
	END IF;

      END IF;

      --derive months enrolled
      OPEN get_round_off(p_base_id);
      FETCH get_round_off INTO lv_round_off_rec;
      CLOSE get_round_off;

      l_term_duration := (l_term_end - l_term_start) / NVL(lv_round_off_rec.num_days_divisor,30);

      IF (lv_round_off_rec.roundoff_fact = 'RU') THEN
        l_term_duration := CEIL( l_term_duration );
      ELSIF (lv_round_off_rec.roundoff_fact = 'RD' ) THEN
        l_term_duration := FLOOR( l_term_duration );
      ELSE
        l_term_duration := ROUND( l_term_duration );
      END IF;

      l_base_det.months_enrolled_num := l_term_duration;
      IF l_base_det.months_enrolled_num < 0 THEN
        l_base_det.months_enrolled_num := 0;
      END IF;
      IF l_base_det.months_enrolled_num IS NULL AND lv_usage = '2' THEN
        l_base_det.months_enrolled_num := l_anticip.months_enrolled_num;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_anticip.months_enrolled_num:'||l_anticip.months_enrolled_num);
        END IF;
      END IF;

      --derive residency status
      --first derive the residency class
      fnd_profile.get('IGS_FI_RES_CLASS_ID',l_residency_class);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_residency_class:'||l_residency_class);
      END IF;

      l_base_det.residency_status_code := igs_pe_gen_001.Get_Res_Status(l_person_id,l_residency_class,p_ld_cal_type,p_ld_sequence_number);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_base_det.residency_status_code:'||l_base_det.residency_status_code);
      END IF;

      IF l_base_det.residency_status_code IS NULL AND lv_usage = '2' THEN
        --derive anticipated residency status
        l_base_det.residency_status_code := l_anticip.residency_status_code;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen..debug','l_anticip.residency_status_code:'||l_anticip.residency_status_code);
        END IF;
      END IF;

      --derive housing status
      OPEN c_housing_status(l_person_id,p_ld_cal_type,p_ld_sequence_number);
      FETCH c_housing_status INTO l_base_det.housing_status_code;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_base_det.housing_status_code:'||l_base_det.housing_status_code);
      END IF;
      CLOSE c_housing_status;
      IF l_base_det.housing_status_code IS NULL AND lv_usage = '2' THEN
        --derive anticipated housing status
        l_base_det.housing_status_code := l_anticip.housing_status_code;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.getBaseDetails.debug','l_base_det.housing_status_code:'||l_base_det.housing_status_code);
        END IF;
      END IF;

    ELSIF lv_usage = '3' THEN
      --derive only anticipated values for all student attributes
      l_base_det.attendance_mode        := l_anticip.attendance_mode;
      l_base_det.attendance_type        := l_anticip.attendance_type;
      l_base_det.class_standing         := l_anticip.class_standing;
      l_base_det.credit_points_num      := l_anticip.credit_points_num;
      l_base_det.housing_status_code    := l_anticip.housing_status_code;
      l_base_det.months_enrolled_num    := l_anticip.months_enrolled_num;
      l_base_det.org_unit_cd            := l_anticip.org_unit_cd;
      l_base_det.program_cd             := l_anticip.program_cd;
      l_base_det.program_location_cd    := l_anticip.program_location_cd;
      l_base_det.program_type           := l_anticip.program_type;
      l_base_det.residency_status_code  := l_anticip.residency_status_code;
      l_base_det.version_number         := NULL;
    END IF;

    RETURN l_base_det;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_COA_GEN.GETBASEDETAILS ' || SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END getBaseDetails;

  PROCEDURE ins_coa_todo(
                         p_person_id      hz_parties.party_id%TYPE,
                         p_calling_module VARCHAR2,
                         p_program_code   igs_ps_ver.course_cd%TYPE,
                         p_version_number igs_ps_ver.version_number%TYPE
                        ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 07-OCT-2004
  --
  --Purpose:
  -- Inserts records into IGS_PE_STD_TODO and IGS_PE_STD_TODO_REF for the given person_id,
  -- thereby scheduling a COA Recomputation via concurrent process for the given person, in all open award years
  --
  -- Parameters:
  --  IN Parameters:
  --    1.p_person_id      - person_id of the student for whom COA needs to be recomputed
  --    2.p_calling_module - Module which schedules the COA recomputation because of a change in student attributes
  --    3.p_program_code   - This is passed when the key program is changed for the person
  --    4.p_version_number - This is passed when the key program is changed for the person
  --  OUT Parameters:
  --    None
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get all open award years
  CURSOR c_base_records(
                        cp_person_id hz_parties.party_id%TYPE
                       ) IS
    SELECT batch.ci_cal_type,
           batch.ci_sequence_number
      FROM igf_ap_batch_aw_map_all batch,
           igf_ap_fa_base_rec_all fa,
           igf_aw_coa_items coa
     WHERE batch.award_year_status_code = 'O'
       AND fa.ci_cal_type = batch.ci_cal_type
       AND fa.ci_sequence_number = batch.ci_sequence_number
       AND fa.base_id = coa.base_id
       AND fa.person_id = cp_person_id
     GROUP BY batch.ci_cal_type,
              batch.ci_sequence_number;

  l_seqnum igs_pe_std_todo.sequence_number%TYPE;

  -- Get persons with specified key program
  CURSOR c_persons(
                   cp_program_code   igs_ps_ver.course_cd%TYPE,
                   cp_version_number igs_ps_ver.version_number%TYPE
                  ) IS
    SELECT person_id
      FROM igs_en_spa_terms
     WHERE key_program_flag = 'Y'
       AND program_cd = cp_program_code
       AND program_version = cp_version_number;

  BEGIN
    SAVEPOINT IGFAW17B_INS_COA_TODO;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.ins_coa_todo.debug','p_person_id:'||p_person_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.ins_coa_todo.debug','p_calling_module:'||p_calling_module);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.ins_coa_todo.debug','p_program_code:'||p_program_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.ins_coa_todo.debug','p_version_number:'||p_version_number);
    END IF;

    IF p_person_id IS NOT NULL THEN
      --have to recompute COA for a single student only
      --insert a master record.
      --also insert child records for all open award years, in which the student has a financial aid base record
      l_seqnum := igs_ge_gen_003.genp_ins_stdnt_todo(
                                                     p_person_id           => p_person_id,
                                                     p_s_student_todo_type => 'IGF_COA_COMP',
                                                     p_todo_dt             => TRUNC(SYSDATE),
                                                     p_single_entry_ind    => 'Y'
                                                    );

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.ins_coa_todo.debug','l_seqnum:'||l_seqnum);
      END IF;

      FOR l_base_records IN c_base_records(p_person_id) LOOP
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.ins_coa_todo.debug','l_base_records.ci_cal_type:'||l_base_records.ci_cal_type);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_gen.ins_coa_todo.debug','l_base_records.ci_sequence_number:'||l_base_records.ci_sequence_number);
        END IF;
        igs_ge_gen_003.genp_ins_todo_ref(
                                         p_person_id           => p_person_id,
                                         p_s_student_todo_type => 'IGF_COA_COMP',
                                         p_sequence_number     => l_seqnum,
                                         p_cal_type            => l_base_records.ci_cal_type,
                                         p_ci_sequence_number  => l_base_records.ci_sequence_number,
                                         p_course_cd           => NULL,
                                         p_unit_cd             => NULL,
                                         p_other_reference     => NULL,
                                         p_uoo_id              => NULL
                                        );
      END LOOP;
    ELSE
      --wrapper has been called for a course code/version number
      --find all the persons who have this program/version as the key program
      --recompute COA for those persons
      FOR l_persons IN c_persons(p_program_code,p_version_number) LOOP
        igf_aw_coa_gen.ins_coa_todo(
                                    p_person_id      => l_persons.person_id,
                                    p_calling_module => p_calling_module,
                                    p_program_code   => NULL,
                                    p_version_number => NULL
                                   );
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO IGFAW17B_INS_COA_TODO;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_COA_GEN.INS_COA_TODO ' || SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END ins_coa_todo;

 -- This procedure is to set and return the Awarding Process Status
 FUNCTION set_awd_proc_status(
                                p_base_id             IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                                p_award_prd_code      IN  igf_aw_award_prd.award_prd_cd%TYPE DEFAULT NULL
                              ) RETURN VARCHAR2 AS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 27-OCT-2004

  -- Change History:
  -- Who         When            What
  --------------------------------------------------------------------------------

    --Cursor to filter out those awards that fall within the awarding period
    CURSOR c_award_prd(
                        c_base_id              igf_ap_fa_base_rec_all.base_id%TYPE ,
                        c_award_prd_code       igf_aw_award_prd.award_prd_cd%TYPE
                       ) IS
      SELECT awd.rowid row_id,
             awd.*
        FROM igf_aw_award_all      awd
       WHERE awd.base_id  =  c_base_id
         AND (awd.awd_proc_status_code = 'AWARDED' OR awd.awd_proc_status_code IS NULL)
         AND NOT EXISTS
               (SELECT disb.ld_cal_type,
                       disb.ld_sequence_number
                FROM   igf_aw_awd_disb_all  disb
                WHERE  disb.award_id  =  awd.award_id
                MINUS
                SELECT apt.ld_cal_type,
                       apt.ld_sequence_number
                FROM   igf_ap_fa_base_rec_all   fab,
                       igf_aw_awd_prd_term      apt
                WHERE  fab.base_id            =   c_base_id             AND
                       apt.ci_cal_type        =   fab.ci_cal_type       AND
                       apt.ci_sequence_number = fab.ci_sequence_number  AND
                       apt.award_prd_cd     = c_award_prd_code
               );


    --Cursor to fetch all the awards for the base id
    CURSOR c_awards(
                        c_base_id              igf_ap_fa_base_rec_all.base_id%TYPE
                       ) IS
      SELECT awd.rowid row_id,
             awd.*
        FROM igf_aw_award_all      awd
       WHERE awd.base_id  =  c_base_id
         AND (awd.awd_proc_status_code = 'AWARDED' OR awd.awd_proc_status_code IS NULL);

    lv_profile_value   VARCHAR2(10);
    lv_status          VARCHAR2(50);
    ln_counter         NUMBER;

  BEGIN
    ln_counter := 0;

    fnd_profile.get('IGF_AW_REV_REPKG',lv_profile_value);

    IF lv_profile_value = 'Y' THEN
        lv_status :=  'REVIEW';
    ELSE
        lv_status :=  'READY';
    END IF;


    IF (p_base_id IS NOT NULL AND p_award_prd_code IS NULL) THEN
        FOR l_awards IN c_awards(p_base_id)
        LOOP
        ln_counter := 1;

        igf_aw_award_pkg.update_row(
                                 x_mode                 => 'R',
                                 x_rowid                => l_awards.row_id               ,
                                 x_award_id             => l_awards.award_id             ,
                                 x_fund_id              => l_awards.fund_id              ,
                                 x_base_id              => l_awards.base_id              ,
                                 x_offered_amt          => l_awards.offered_amt          ,
                                 x_accepted_amt         => l_awards.accepted_amt         ,
                                 x_paid_amt             => l_awards.paid_amt             ,
                                 x_packaging_type       => l_awards.packaging_type       ,
                                 x_batch_id             => l_awards.batch_id             ,
                                 x_manual_update        => l_awards.manual_update        ,
                                 x_rules_override       => l_awards.rules_override       ,
                                 x_award_date           => l_awards.award_date           ,
                                 x_award_status         => l_awards.award_status         ,
                                 x_attribute_category   => l_awards.attribute_category   ,
                                 x_attribute1           => l_awards.attribute1           ,
                                 x_attribute2           => l_awards.attribute2           ,
                                 x_attribute3           => l_awards.attribute3           ,
                                 x_attribute4           => l_awards.attribute4           ,
                                 x_attribute5           => l_awards.attribute5           ,
                                 x_attribute6           => l_awards.attribute6           ,
                                 x_attribute7           => l_awards.attribute7           ,
                                 x_attribute8           => l_awards.attribute8           ,
                                 x_attribute9           => l_awards.attribute9           ,
                                 x_attribute10          => l_awards.attribute10          ,
                                 x_attribute11          => l_awards.attribute11          ,
                                 x_attribute12          => l_awards.attribute12          ,
                                 x_attribute13          => l_awards.attribute13          ,
                                 x_attribute14          => l_awards.attribute14          ,
                                 x_attribute15          => l_awards.attribute15          ,
                                 x_attribute16          => l_awards.attribute16          ,
                                 x_attribute17          => l_awards.attribute17          ,
                                 x_attribute18          => l_awards.attribute18          ,
                                 x_attribute19          => l_awards.attribute19          ,
                                 x_attribute20          => l_awards.attribute20          ,
                                 x_rvsn_id              => l_awards.rvsn_id              ,
                                 x_alt_pell_schedule    => l_awards.alt_pell_schedule    ,
                                 x_award_number_txt     => l_awards.award_number_txt     ,
                                 x_legacy_record_flag   => l_awards.legacy_record_flag   ,
                                 x_adplans_id           => l_awards.adplans_id           ,
                                 x_lock_award_flag      => l_awards.lock_award_flag      ,
                                 x_app_trans_num_txt    => l_awards.app_trans_num_txt    ,
                                 x_awd_proc_status_code => lv_status                      ,
                                 x_notification_status_code	=> l_awards.notification_status_code,
                                 x_notification_status_date	=> l_awards.notification_status_date,
                                 x_publish_in_ss_flag       => l_awards.publish_in_ss_flag
                                );

        END LOOP;
    ELSIF (p_base_id IS NOT NULL AND p_award_prd_code IS NOT NULL) THEN
        FOR l_award_prd IN c_award_prd(p_base_id,p_award_prd_code)
        LOOP
        ln_counter := 1;

        igf_aw_award_pkg.update_row(
                                 x_mode                 => 'R',
                                 x_rowid                => l_award_prd.row_id               ,
                                 x_award_id             => l_award_prd.award_id             ,
                                 x_fund_id              => l_award_prd.fund_id              ,
                                 x_base_id              => l_award_prd.base_id              ,
                                 x_offered_amt          => l_award_prd.offered_amt          ,
                                 x_accepted_amt         => l_award_prd.accepted_amt         ,
                                 x_paid_amt             => l_award_prd.paid_amt             ,
                                 x_packaging_type       => l_award_prd.packaging_type       ,
                                 x_batch_id             => l_award_prd.batch_id             ,
                                 x_manual_update        => l_award_prd.manual_update        ,
                                 x_rules_override       => l_award_prd.rules_override       ,
                                 x_award_date           => l_award_prd.award_date           ,
                                 x_award_status         => l_award_prd.award_status         ,
                                 x_attribute_category   => l_award_prd.attribute_category   ,
                                 x_attribute1           => l_award_prd.attribute1           ,
                                 x_attribute2           => l_award_prd.attribute2           ,
                                 x_attribute3           => l_award_prd.attribute3           ,
                                 x_attribute4           => l_award_prd.attribute4           ,
                                 x_attribute5           => l_award_prd.attribute5           ,
                                 x_attribute6           => l_award_prd.attribute6           ,
                                 x_attribute7           => l_award_prd.attribute7           ,
                                 x_attribute8           => l_award_prd.attribute8           ,
                                 x_attribute9           => l_award_prd.attribute9           ,
                                 x_attribute10          => l_award_prd.attribute10          ,
                                 x_attribute11          => l_award_prd.attribute11          ,
                                 x_attribute12          => l_award_prd.attribute12          ,
                                 x_attribute13          => l_award_prd.attribute13          ,
                                 x_attribute14          => l_award_prd.attribute14          ,
                                 x_attribute15          => l_award_prd.attribute15          ,
                                 x_attribute16          => l_award_prd.attribute16          ,
                                 x_attribute17          => l_award_prd.attribute17          ,
                                 x_attribute18          => l_award_prd.attribute18          ,
                                 x_attribute19          => l_award_prd.attribute19          ,
                                 x_attribute20          => l_award_prd.attribute20          ,
                                 x_rvsn_id              => l_award_prd.rvsn_id              ,
                                 x_alt_pell_schedule    => l_award_prd.alt_pell_schedule    ,
                                 x_award_number_txt     => l_award_prd.award_number_txt     ,
                                 x_legacy_record_flag   => l_award_prd.legacy_record_flag   ,
                                 x_adplans_id           => l_award_prd.adplans_id           ,
                                 x_lock_award_flag      => l_award_prd.lock_award_flag      ,
                                 x_app_trans_num_txt    => l_award_prd.app_trans_num_txt    ,
                                 x_awd_proc_status_code => lv_status                        ,
                                 x_notification_status_code	=> l_award_prd.notification_status_code,
                                 x_notification_status_date	=> l_award_prd.notification_status_date,
                                 x_publish_in_ss_flag       => l_award_prd.publish_in_ss_flag
                                );
        END LOOP;
    END IF;

    IF ln_counter = 1 THEN
        RETURN lv_status;
    ELSE
        RETURN NULL;
    END IF;

  END set_awd_proc_status;

  PROCEDURE get_award_period_dates(
                                   p_ci_cal_type        IN igs_ca_inst.cal_type%TYPE,
                                   p_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                                   p_award_prd_code     IN  igf_aw_awd_prd_term.award_prd_cd%TYPE,
                                   p_start_date         OUT NOCOPY DATE,
                                   p_end_date           OUT NOCOPY DATE
                                  ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 29-Oct-2004
  --
  --Purpose: Get Awarding period start end dates
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get all terms attached to the awarding period
  CURSOR c_load_cal(
                    cp_ci_cal_type         igs_ca_inst.cal_type%TYPE,
                    cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE,
                    cp_award_prd_code      igf_aw_awd_prd_term.award_prd_cd%TYPE
                   ) IS
    SELECT MIN(cal.start_dt) start_date,
           MAX(cal.end_dt) end_date
      FROM igf_aw_awd_prd_term aprd,
           igs_ca_inst cal
     WHERE aprd.ci_cal_type = cp_ci_cal_type
       AND aprd.ci_sequence_number = cp_ci_sequence_number
       AND aprd.award_prd_cd = cp_award_prd_code
       AND aprd.ld_cal_type = cal.cal_type
       AND aprd.ld_sequence_number = cal.sequence_number;

  BEGIN
    p_start_date   := NULL;
    p_end_date     := NULL;

    OPEN c_load_cal(p_ci_cal_type,p_ci_sequence_number,p_award_prd_code);
    FETCH c_load_cal INTO p_start_date,p_end_date;
    CLOSE c_load_cal;

  END get_award_period_dates;

  PROCEDURE check_oss_attrib(
                             p_org_unit_code        IN  igf_ap_fa_ant_data.org_unit_cd%TYPE,
                             p_program_code         IN  igf_ap_fa_ant_data.program_cd%TYPE,
                             p_program_type         IN  igf_ap_fa_ant_data.program_type%TYPE,
                             p_program_location     IN  igf_ap_fa_ant_data.program_location_cd%TYPE,
                             p_attend_type          IN  igf_ap_fa_ant_data.attendance_type%TYPE,
                             p_attend_mode          IN  igf_ap_fa_ant_data.attendance_mode%TYPE,
                             p_ret_status           OUT NOCOPY VARCHAR2
                            ) IS
    ------------------------------------------------------------------
    --Created by  : ridas, Oracle India
    --Date created: 02-NOV-2004
    --
    --Purpose:
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    --ridas       09-Aug-2005     Bug #4164450. Added new validations to check
    --                            the program offering options
    -------------------------------------------------------------------

    -- Cursor to check whether the anticipated org unit is a responsible/owning org unit
    -- for the specified anticipated key program or not
    CURSOR c_chk_org (cp_org_unit         igf_ap_fa_ant_data.org_unit_cd%TYPE,
                      cp_program_code     igf_ap_fa_ant_data.program_cd%TYPE)
          IS
      SELECT 'x'
        FROM igs_ps_ver
       WHERE course_cd = cp_program_code
         AND ( responsible_org_unit_cd = cp_org_unit
              OR EXISTS (SELECT 'x'
                           FROM igs_ps_own
                          WHERE course_cd = cp_program_code
                            AND org_unit_cd = cp_org_unit
                        )
            );

    l_chk_org     c_chk_org%ROWTYPE;


    -- Cursor to check the Anticipated Key Program specified is of Anticipated Program Type or not
    CURSOR c_chk_prog (cp_program_code     igf_ap_fa_ant_data.program_cd%TYPE,
                       cp_program_type     igf_ap_fa_ant_data.program_type%TYPE)
          IS
      SELECT 'x'
       FROM igs_ps_ver
      WHERE course_cd = cp_program_code
        AND course_type = cp_program_type;

    l_chk_prog    c_chk_prog%ROWTYPE;

    -- Cursor to check Key Program at the specified Program Location
    CURSOR c_chk_prog_offer  (cp_program_code     igf_ap_fa_ant_data.program_cd%TYPE,
                              cp_location_code    igf_ap_fa_ant_data.program_location_cd%TYPE)
          IS
      SELECT 'x'
       FROM igs_ps_ofr_opt_all  offering
      WHERE offering.course_cd    = cp_program_code
        AND offering.location_cd  = cp_location_code;

    l_chk_prog_offer    c_chk_prog_offer%ROWTYPE;


    -- Cursor to check the existence of the program offering option for the combination of Key Program,
    -- Program Location, Anticipated Attendance Type and Anticipated Attendance Mode
    CURSOR c_chk_prog_option  (cp_program_code     igf_ap_fa_ant_data.program_cd%TYPE,
                               cp_location_code    igf_ap_fa_ant_data.program_location_cd%TYPE,
                               cp_attend_type      igf_ap_fa_ant_data.attendance_type%TYPE,
                               cp_attend_mode      igf_ap_fa_ant_data.attendance_mode%TYPE)
          IS
      SELECT 'x'
       FROM igs_ps_ofr_opt_all  offering,
            igs_ps_ofr_pat      offering_pattern
      WHERE offering.course_cd    = cp_program_code
        AND offering.location_cd  = cp_location_code
        AND offering.attendance_mode  = cp_attend_mode
        AND offering.attendance_type  = cp_attend_type
        AND offering.delete_flag      = 'N'
        AND offering.coo_id = offering_pattern.coo_id
        AND offering_pattern.offered_ind = 'Y';

    l_chk_prog_option     c_chk_prog_option%ROWTYPE;


  BEGIN
    p_ret_status := 'S' ;

    IF (p_program_code IS NOT NULL AND p_org_unit_code IS NOT NULL)  THEN
        -- Check responsible/owning org unit
        OPEN c_chk_org(p_org_unit_code,
                       p_program_code);

        FETCH c_chk_org INTO l_chk_org;

        IF c_chk_org%NOTFOUND THEN
            p_ret_status := 'W' ;
            fnd_message.set_name('IGF','IGF_AW_NOT_RESP_ORG_UNIT');
            fnd_message.set_token('ORG_UNIT',p_org_unit_code);
            fnd_message.set_token('PROG_CODE',p_program_code);
            igs_ge_msg_stack.add;
        END IF;
        CLOSE c_chk_org;
    END IF;


    IF (p_program_code IS NOT NULL AND p_program_type IS NOT NULL)  THEN
        -- Check the type of the anticipated key program
        OPEN c_chk_prog(p_program_code,
                        p_program_type);

        FETCH c_chk_prog INTO l_chk_prog;

        IF c_chk_prog%NOTFOUND THEN
            p_ret_status := 'W' ;
            fnd_message.set_name('IGF','IGF_AW_PROG_NOT_OF_TYPE');
            fnd_message.set_token('PROG_CODE',p_program_code);
            fnd_message.set_token('PROG_TYPE',p_program_type);
            igs_ge_msg_stack.add;
        END IF;
        CLOSE c_chk_prog;
    END IF;


    IF (p_program_code IS NOT NULL AND p_program_location IS NOT NULL)  THEN
        -- Check the program location
        OPEN c_chk_prog_offer(p_program_code,
                              p_program_location
                             );

        FETCH c_chk_prog_offer INTO l_chk_prog_offer;
        IF c_chk_prog_offer%NOTFOUND THEN
            p_ret_status := 'W' ;
            fnd_message.set_name('IGF','IGF_AW_PRG_NT_OFFER');
            fnd_message.set_token('PROG_CODE',p_program_code);
            fnd_message.set_token('PROG_LOC',p_program_location);
            igs_ge_msg_stack.add;
        END IF;
        CLOSE c_chk_prog_offer;
    END IF;


    IF (p_program_code IS NOT NULL AND p_program_location IS NOT NULL AND p_attend_type IS NOT NULL AND p_attend_mode IS NOT NULL)  THEN
        -- Check the program offering options
        OPEN c_chk_prog_option(p_program_code,
                               p_program_location,
                               p_attend_type,
                               p_attend_mode);

        FETCH c_chk_prog_option INTO l_chk_prog_option;
        IF c_chk_prog_option%NOTFOUND THEN
            p_ret_status := 'W' ;
            fnd_message.set_name('IGF','IGF_AW_NO_PROG_LOC');
            fnd_message.set_token('PROG_CODE',p_program_code);
            fnd_message.set_token('PROG_LOC',p_program_location);
            fnd_message.set_token('ATTND_TYPE',p_attend_type);
            fnd_message.set_token('ATTND_MODE',p_attend_mode);
            igs_ge_msg_stack.add;
        END IF;
        CLOSE c_chk_prog_option;
    END IF;

  END check_oss_attrib;

END igf_aw_coa_gen;

/
