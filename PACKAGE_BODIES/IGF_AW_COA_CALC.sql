--------------------------------------------------------
--  DDL for Package Body IGF_AW_COA_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_COA_CALC" AS
/* $Header: IGFAW01B.pls 120.4 2006/02/08 23:36:46 ridas ship $ */

------------------------------------------------------------------------------
-- Who        When          What
-- veramach   21-Dec-2004   bug # 4081158 Resolved unhandled exception
-- cdcruz     12-Jan-2004   Bug # 3355361 FA CCR 118 COA Updates
--                          Reviewed and review comments incorporated
-- veramach   08-Jan-2004   Bug # 3355361 FA CCR 118 COA Updates
--                          Revamped the code. Added new parameters to run-
--                          p_update_coa and p_update_method
--                          added procedures overaward_amount,coa_needs_update,
--                          does_term_mismatch,delete_coa
--
-- masehgal  10-Jun-2003    # 2858504   FA118.1    Added legacy_record_flag field
--
-- sjadhav    23-Dec-2002   Bug 2695347
--                          1. Implemented proper exception handling in all
--                             inner routines and main exe
--                          2. Re-formatted log and output files
--                          3. Added proces_student routine to remove repeated
--                             code
--                          4. modified add_coa_items routine so that output
--                             file is created and fa base is updated only iff
--                             there is change in coa for a student
--                          5. Cursor to pick up coa items is modified to pick
--                             up only ACTIVE coa items
--                          6. Modified person group ref cursor.
--
---------------------------------------------------------------------------------
-- gmuralid   23-Oct-2002   FA 105/FA108 Awarding enhancements COA calculation
--                          changes
--                          Completely modfied the Run Procedure
--                          Added new procedures
--                          1) populate_setup_table
--                          2) add_coa_items
--                          3) print_output_file
------------------------------------------------------------------------------
-- masehgal   25-Sep-2002   FA 104 - To Do Enhancements
--                          Added manual_disb_hold  in FA Base update
------------------------------------------------------------------------------
-- Bug ID : 2331724         The Pell Amount should not split across
--                          load Calendars
------------------------------------------------------------------------------
-- adhawan   26-Apr-02      Cost of attendance groups are being set up with
--                          Pell amounts on IGFAW005 Cost
--                          of Attendance Assignment.  After executing the job
--                          Cost of Attendance--Compute Cost of Attendance, the
--                          field labeled Pell is the Pell budget which should
--                          never split up.The Pell amount should be the full
--                          amount entered on the setup form.
--------------------------------------------------------------------------------
-- Bug ID : 2201787
-- who       when           what
-- brajendr  19-Jun-2001    1. Changed the cursor c_stud_det. removed the for
--                             update clause from the cursor.
------------------------------------------------------------------------------
-- Bug ID : 1606850
-- who      when           what
-- sjadhav  19-Jun-2001    1. enhancement for November Release.
------------------------------------------------------------------------------
-- Bug ID : 1796006
-- who      when           what
-- sjadhav  23-May-2001    1. changed the sequence of
--                            parameters to
--                            Run Type / Award year /Base ID
------------------------------------------------------------------------------
-- Bug ID : 1723272
-- who       when          what
-- mesriniv  20-Apr-2001    1.Change has been done in the cursor c_stud_det
--                            to fetch the data from IGF_AP_FA_CON_V
--                            instead of IGF_AP_FA_BASE_REC.
--------------------------------------------------------------------------------
-- Bug ID : 1731302 COA not calcuated for the whole award year
-- avenkatr   18-Apr-01     1.  When the award year IS split and before
--                              it is assigned to the cal_type it IS trimmed
--------------------------------------------------------------------------------

g_b_header            BOOLEAN;
g_coa_updated         VARCHAR2(1) ;
g_cal_type            igs_ca_inst.cal_type%TYPE;
g_sequence_number     igs_ca_inst.sequence_number%TYPE;

E_SKIP_STUDENT        EXCEPTION;
E_SKIP_STD_NO_ITEMS   EXCEPTION;
E_SKIP_STD_NO_TERMS   EXCEPTION;

  FUNCTION overaward_amount(
                            p_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                           ) RETURN NUMBER AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 08-JAN-2004
  --

  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  l_resource_f NUMBER;
  l_resource_i NUMBER;
  l_unmet_need_f NUMBER;
  l_unmet_need_i NUMBER;
  l_resource_f_fc NUMBER;
  l_resource_i_fc NUMBER;

  BEGIN

    igf_aw_gen_002.get_resource_need(
                                     p_base_id,
                                     l_resource_f,
                                     l_resource_i,
                                     l_unmet_need_f,
                                     l_unmet_need_i,
                                     l_resource_f_fc,
                                     l_resource_i_fc
                                    );

    RETURN -1 * l_unmet_need_f;

  END overaward_amount;

  FUNCTION coa_needs_update(
                            p_item_code          igf_aw_coa_items.item_code%TYPE,
                            p_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_amount             igf_aw_coa_items.amount%TYPE,
                            p_pell_coa_amount    igf_aw_coa_items.pell_coa_amount%TYPE,
                            p_alt_pell_amount    igf_aw_coa_items.alt_pell_amount%TYPE,
                            p_fixed_cost         igf_aw_coa_items.fixed_cost%TYPE
                           ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 07-JAN-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ridas       09-09-2005      Bug #4226096. Added a new CURSOR 'c_get_lock_flg'
  --                            to fetch lock flag.
  -------------------------------------------------------------------

  -- check if the student's COA item needs update or not
  CURSOR c_coa_item(
                    cp_item_code       igf_aw_coa_items.item_code%TYPE,
                    cp_base_id         igf_ap_fa_base_rec_all.base_id%TYPE,
                    cp_amount          igf_aw_coa_items.amount%TYPE,
                    cp_pell_coa_amount igf_aw_coa_items.pell_coa_amount%TYPE,
                    cp_alt_pell_amount igf_aw_coa_items.alt_pell_amount%TYPE,
                    cp_fixed_cost      igf_aw_coa_items.fixed_cost%TYPE
                   ) IS
    SELECT lock_flag
      FROM igf_aw_coa_items
     WHERE item_code               = cp_item_code
       AND base_id                 = cp_base_id
       AND amount                  = cp_amount
       AND NVL(pell_coa_amount,-1) = NVL(cp_pell_coa_amount,-1)
       AND NVL(alt_pell_amount,-1) = NVL(cp_alt_pell_amount,-1)
       AND NVL(fixed_cost,'*')     = NVL(cp_fixed_cost,'*');

  l_coa_item   c_coa_item%ROWTYPE;


  -- get lock flag
  CURSOR c_get_lock_flg(
                        cp_item_code       igf_aw_coa_items.item_code%TYPE,
                        cp_base_id         igf_ap_fa_base_rec_all.base_id%TYPE
                       ) IS
    SELECT lock_flag
      FROM igf_aw_coa_items
     WHERE item_code               = cp_item_code
       AND base_id                 = cp_base_id;

  l_get_lock_flg   c_get_lock_flg%ROWTYPE;

  BEGIN
    OPEN c_coa_item(p_item_code,p_base_id,p_amount,p_pell_coa_amount,p_alt_pell_amount,p_fixed_cost);
    FETCH c_coa_item INTO l_coa_item;

    IF c_coa_item%FOUND THEN
      CLOSE c_coa_item;
      RETURN FALSE;
    ELSE
      CLOSE c_coa_item;

      l_get_lock_flg := NULL;

      OPEN c_get_lock_flg(p_item_code,p_base_id);
      FETCH c_get_lock_flg INTO l_get_lock_flg;
      CLOSE c_get_lock_flg;

      IF l_get_lock_flg.lock_flag='N' OR l_get_lock_flg.lock_flag IS NULL THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END IF;
  END coa_needs_update;

  FUNCTION does_term_mismatch(
                              p_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_process_id NUMBER
                             ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 29-DEC-2003
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  --Cursor to check for load calandar match
  CURSOR c_load_cal_chk(
                        c_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                        c_process_id NUMBER
                       ) IS
    SELECT DISTINCT ld_cal_type,ld_sequence_number
      FROM igf_aw_coa_itm_terms
     WHERE base_id = c_base_id
    MINUS
    SELECT DISTINCT ld_cal_type,ld_sequence_number
      FROM igf_aw_award_t
     WHERE process_id = c_process_id;

  c_cal_chk_rec   c_load_cal_chk%ROWTYPE;

  -- New cursor Added on 20-DEC-02 for for terms inconsistency check
  CURSOR c_load_cal_chk1(
                         c_base_id          igf_ap_fa_base_rec_all.base_id%TYPE,
                         c_process_id       NUMBER
                        ) IS
    SELECT DISTINCT ld_cal_type,ld_sequence_number
      FROM igf_aw_award_t
     WHERE process_id = c_process_id
    MINUS
    SELECT DISTINCT ld_cal_type,ld_sequence_number
      FROM igf_aw_coa_itm_terms
     WHERE base_id = c_base_id;

  c_cal_chk_rec1   c_load_cal_chk1%ROWTYPE;

  BEGIN

    OPEN c_load_cal_chk(p_base_id,p_process_id);
    FETCH c_load_cal_chk INTO c_cal_chk_rec;

    IF c_load_cal_chk%FOUND THEN
      CLOSE c_load_cal_chk;
      RETURN TRUE;

    ELSE
      CLOSE c_load_cal_chk;

      OPEN c_load_cal_chk1(p_base_id,p_process_id);
      FETCH c_load_cal_chk1 INTO c_cal_chk_rec1;

      IF c_load_cal_chk1%FOUND THEN
        CLOSE c_load_cal_chk1;
        RETURN TRUE;
      ELSE
        CLOSE c_load_cal_chk1;
        RETURN FALSE;
      END IF;
    END IF;
  END does_term_mismatch;


  FUNCTION iscoalocked(
                       p_base_id     IN   igf_ap_fa_base_rec_all.base_id%TYPE
                      ) RETURN BOOLEAN AS
  ------------------------------------------------------------------
  --Created by  : ridas, Oracle India
  --Date created: 01-Nov-2004
  --
  --Purpose:
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR c_coa(
               cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
              ) IS
    SELECT rowid      row_id,
           item_code,
           lock_flag
      FROM igf_aw_coa_items
     WHERE base_id = cp_base_id;

  CURSOR c_coa_terms(
                     cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                     cp_item_code igf_aw_coa_items.item_code%TYPE
                    ) IS
    SELECT rowid    row_id,
           lock_flag
      FROM igf_aw_coa_itm_terms
     WHERE base_id   = cp_base_id
       AND item_code = cp_item_code;


  BEGIN
    FOR coa_rec IN c_coa(p_base_id) LOOP
      IF coa_rec.lock_flag = 'Y' THEN
        fnd_message.set_name('IGF','IGF_AW_COA_ITM_NOT_DEL');
        fnd_message.set_token('ITEM_CODE',coa_rec.item_code);
        fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);


        RETURN FALSE;
      END IF;

      FOR coa_terms_rec IN c_coa_terms(p_base_id,coa_rec.item_code) LOOP
        IF coa_terms_rec.lock_flag = 'Y' THEN
          fnd_message.set_name('IGF','IGF_AW_COA_ITM_NOT_DEL');
          fnd_message.set_token('ITEM_CODE',coa_rec.item_code);
          fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);

          RETURN FALSE;
        END IF;
      END LOOP;
    END LOOP;

    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_COA_CALC.ISCOALOCKED' || ' '|| SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_coa_calc.iscoalocked.exception','sql error: '||SQLERRM);
      END IF;
      igs_ge_msg_stack.conc_exception_hndl;
      app_exception.raise_exception;
  END iscoalocked;




  PROCEDURE delete_coa(
                       p_base_id     IN   igf_ap_fa_base_rec_all.base_id%TYPE
                      ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 26-Dec-2003
  --
  --Purpose: Delete COA item and terms associated with a base_id
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR c_coa(
               cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
              ) IS
    SELECT rowid      row_id,
           item_code
      FROM igf_aw_coa_items
     WHERE base_id = cp_base_id;

  CURSOR c_coa_terms(
                     cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE,
                     cp_item_code igf_aw_coa_items.item_code%TYPE
                    ) IS
    SELECT rowid    row_id
      FROM igf_aw_coa_itm_terms
     WHERE base_id   = cp_base_id
       AND item_code = cp_item_code;


  BEGIN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.delete_coa.debug','Starting delete_coa with base_id:'||p_base_id);
    END IF;
    FOR coa_rec IN c_coa(p_base_id) LOOP

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.delete_coa.debug','deleting item '||coa_rec.item_code);
      END IF;
      FOR coa_terms_rec IN c_coa_terms(p_base_id,coa_rec.item_code) LOOP

        igf_aw_coa_itm_terms_pkg.delete_row(
                                            x_rowid => coa_terms_rec.row_id
                                           );
      END LOOP;

      igf_aw_coa_items_pkg.delete_row(
                                      x_rowid => coa_rec.row_id
                                     );
      fnd_message.set_name('IGF','IGF_AW_COA_ITEM_DEL');
      fnd_message.set_token('ITEM_CODE',coa_rec.item_code);
      fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);

    END LOOP;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.delete_coa.debug','delete_coa done');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_COA_CALC.DELETE_COA' ||  ' '|| SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_coa_calc.delete_coa.exception','sql error: '||SQLERRM);
      END IF;
      igs_ge_msg_stack.conc_exception_hndl;
      app_exception.raise_exception;
  END delete_coa;


  ---------------------------------------------------------------------------------------
   -- The procedure populate_setup_table populates the temporary table igf_aw_award_t
   -- CREATED BY:gmuralid
  --------------------------------------------------------------------------------------
   PROCEDURE populate_setup_table(
                                  p_grp_coa_code        IN igf_aw_coa_grp_item.coa_code%TYPE,
                                  p_ci_cal_type         IN igf_aw_coa_grp_item.ci_cal_type%TYPE,
                                  p_ci_sequence_number  IN igf_aw_coa_grp_item.ci_sequence_number%TYPE,
                                  l_process_id          IN NUMBER
                                 ) IS

  -- Cursor retrieves all item and term information for a given group code and award year

    CURSOR c_item_term_info(
                            c_coa_code                igf_aw_coa_grp_item.coa_code%TYPE,
                            c_ci_cal_type             igf_aw_coa_grp_item.ci_cal_type%TYPE,
                            c_ci_sequence_number      igf_aw_coa_grp_item.ci_sequence_number%TYPE
                           ) IS
      SELECT  grp.item_code,
              grp.fixed_cost,
              grp.default_value  item_amount,
              grp.pell_amount,
              grp.pell_alternate_amt,
              grp.lock_flag,
              def.ld_cal_type,
              def.ld_sequence_number,
              def.ld_perct
      FROM    igf_aw_coa_grp_item   grp,
              igf_aw_coa_ld def
      WHERE   grp.coa_code    = c_coa_code
        AND   grp.ci_cal_type = c_ci_cal_type
        AND   grp.ci_sequence_number = c_ci_sequence_number
        AND   grp.coa_code    = def.coa_code
        AND   grp.ci_cal_type = def.ci_cal_type
        AND   grp.ci_sequence_number = def.ci_sequence_number
        AND   grp.active      = 'Y'
        AND   grp.item_dist   = 'N'

     UNION ALL

     SELECT   ovrd.item_code,
              grp.fixed_cost,
              grp.default_value  item_amount,
              grp.pell_amount,
              grp.pell_alternate_amt,
              grp.lock_flag,
              ovrd.ld_cal_type,
              ovrd.ld_sequence_number,
              ovrd.ld_perct
       FROM   igf_aw_cit_ld_overide ovrd  ,
              igf_aw_coa_grp_item   grp
      WHERE   grp.coa_code  = c_coa_code
        AND   grp.ci_cal_type = c_ci_cal_type
        AND   grp.ci_sequence_number = c_ci_sequence_number
        AND   grp.coa_code  = ovrd.coa_code
        AND   grp.ci_cal_type = ovrd.ci_cal_type
        AND   grp.ci_sequence_number = ovrd.ci_sequence_number
        AND   grp.item_code = ovrd.item_code
        AND   grp.active      = 'Y'
        AND   grp.item_dist   = 'Y' ;

      items_rec               c_item_term_info%ROWTYPE;
      item_term_amount        igf_aw_award_t.accepted_amt%TYPE;

      l_rowid      ROWID;
      l_sl_number  NUMBER(15);

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.populate_setup_table.debug','starting populate_setup_table with ' ||
                                                                                                     'p_grp_coa_code->'||p_grp_coa_code||
                                                                                                      'p_ci_cal_type->'||p_ci_cal_type||
                                                                                                      'p_ci_sequence_number->'||p_ci_sequence_number);
    END IF;
    OPEN c_item_term_info(p_grp_coa_code,p_ci_cal_type,p_ci_sequence_number);
    LOOP
      FETCH c_item_term_info INTO items_rec;
      EXIT WHEN c_item_term_info%NOTFOUND;

      l_rowid          := NULL;
      l_sl_number      := NULL;

      IF items_rec.item_amount IS NOT NULL THEN
            item_term_amount := items_rec.item_amount * (NVL(items_rec.ld_perct,0)/100);
      ELSE
            item_term_amount := NULL;
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.populate_setup_table.debug','inserting item->'||items_rec.item_code||
                                                                                                      'item_term_amount->'||item_term_amount||
                                                                                                      'ld_cal->'||items_rec.ld_cal_type||
                                                                                                      'ld_seq->'||items_rec.ld_sequence_number);
      END IF;

      igf_aw_award_t_pkg.insert_row(
                                    x_rowid               =>  l_rowid,
                                    x_process_id          =>  l_process_id,
                                    x_sl_number           =>  l_sl_number,
                                    x_fund_id             =>  NULL,
                                    x_base_id             =>  NULL,
                                    x_offered_amt         =>  items_rec.item_amount,        --this is the item amount
                                    x_accepted_amt        =>  item_term_amount,             --this is the term amount
                                    x_paid_amt            =>  items_rec.pell_amount,        --this is the pell amount
                                    x_need_reduction_amt  =>  items_rec.pell_alternate_amt, --this is the pell alternate amount
                                    x_flag                =>  'GR',
                                    x_temp_num_val1       =>  NULL,
                                    x_temp_num_val2       =>  NULL,
                                    x_temp_char_val1      =>  items_rec.item_code,           --item code
                                    x_tp_cal_type         =>  items_rec.fixed_cost,
                                    x_tp_sequence_number  =>  NULL,
                                    x_ld_cal_type         =>  items_rec.ld_cal_type,
                                    x_ld_sequence_number  =>  items_rec.ld_sequence_number,
                                    x_mode                => 'R',
                                    x_adplans_id          =>  NULL,
                                    x_app_trans_num_txt   =>  NULL,
                                    x_award_id            =>  NULL,
                                    x_lock_award_flag      =>  items_rec.lock_flag,
                                    x_temp_val3_num       =>  NULL,
                                    x_temp_val4_num       =>  NULL,
                                    x_temp_char2_txt      =>  NULL,
                                    x_temp_char3_txt      =>  NULL

                                   );

    END LOOP;
    CLOSE c_item_term_info;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_COA_CALC.POPULATE_SETUP_TABLE' || ' '|| SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_coa_calc.populate_setup_table.exception','sql error message: '||SQLERRM);
      END IF;
      igs_ge_msg_stack.conc_exception_hndl;
      app_exception.raise_exception;
  END populate_setup_table;


  ------------------------------------------------------------------------------------------------
  --Porcedure add_coa_items calculates the cost of attendance for a student
  --CREATED BY :gmuralid
  -------------------------------------------------------------------------------------------------
  PROCEDURE add_coa_items(
                          p_base_id    IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                          p_grp_code   IN  igf_aw_coa_grp_item.coa_code%TYPE,
                          exeorder     IN  VARCHAR2,
                          l_process_id IN  NUMBER,
                          result       OUT NOCOPY VARCHAR2
                         ) IS

  ------------------------------------------------------------------
  --Created by  : gmuralid
  --Date created:
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --veramach    08-Jan-2004     FA CCR 118 COA Updates
  --                            Added new logic based on p_update_coa and p_update_method values
  -------------------------------------------------------------------

    --
    -- cursor retrieves inforamtion from temporary table to calcualte COA only for student who
    -- does not have prior cost of attendance
    --

    CURSOR c_first_coa(
                       c_process_id  NUMBER
                      ) IS
      SELECT DISTINCT temp_char_val1 item_code,
             offered_amt             item_amount,
             paid_amt                pell_amount,
             need_reduction_amt      pell_alternate_amount,
             tp_cal_type             fixed_cost,
             lock_award_flag
        FROM igf_aw_award_t
       WHERE process_id = c_process_id
      ORDER BY  temp_char_val1;
      first_coa_rec           c_first_coa%ROWTYPE;

    --
    --cursor retrieves inforamtion ( this includes the term information as well) from
    --temporary table to calcualte COA only for student who
    --does not have prior cost of attendance
    --


    CURSOR c_first_itm_term(
                            c_item_code   igf_aw_award_t.temp_char_val1%TYPE,
                            c_process_id  NUMBER
                           ) IS
      SELECT temp_char_val1        item_code,
             accepted_amt          item_term_amount,
             paid_amt              pell_amount,
             need_reduction_amt    pell_alternate_amount,
             tp_cal_type           fixed_cost,
             ld_cal_type,
             ld_sequence_number,
             lock_award_flag
        FROM igf_aw_award_t
       WHERE temp_char_val1 = c_item_code
         AND process_id=c_process_id;

    first_itm_term_rec    c_first_itm_term%ROWTYPE;


  --Cursor to retrieve item-term information for a student who already has some COA items assigned
  CURSOR c_second_item_term(
                            c_item_code   igf_aw_award_t.temp_char_val1%TYPE,
                            c_process_id  NUMBER
                           ) IS
    SELECT temp_char_val1     item_code,
           accepted_amt       item_term_amount,
           paid_amt           pell_amount,
           need_reduction_amt pell_alternate_amount,
           tp_cal_type        fixed_cost,
           ld_cal_type,
           ld_sequence_number,
           lock_award_flag
      FROM igf_aw_award_t
     WHERE temp_char_val1 = c_item_code
       AND process_id     = c_process_id;
  sec_itm_term_rec  c_second_item_term%ROWTYPE;

  l_rowid          ROWID;

  -- Cursor to check for item match
  CURSOR c_check_item_match(
                            c_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                            c_process_id NUMBER
                           ) IS
    SELECT DISTINCT coa_group_items.new_item,
                    coa_group_items.item_amount,
                    coa_group_items.pell_amt,
                    coa_group_items.pell_alt_amt,
                    coa_group_items.fixed_cost,
                    coa_group_items.lock_award_flag,
                    assigned_coa.existing_item,
                    assigned_coa.row_id
    FROM
    (
     SELECT DISTINCT temp_char_val1 new_item,
            offered_amt         item_amount,
            paid_amt            pell_amt,
            need_reduction_amt  pell_alt_amt,
            tp_cal_type         fixed_cost,
            lock_award_flag
       FROM igf_aw_award_t
      WHERE process_id = c_process_id
    ) coa_group_items,
    (
     SELECT rowid     row_id,
            item_code existing_item
       FROM igf_aw_coa_items
      WHERE base_id = c_base_id
    ) assigned_coa
    WHERE coa_group_items.new_item = assigned_coa.existing_item(+);

  chk_item_match_rec   c_check_item_match%ROWTYPE;

  -- select item's terms and term amount
  CURSOR c_item_term(
                     cp_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                     cp_item_code          igf_aw_coa_itm_terms.item_code%TYPE,
                     cp_ld_cal_type        igf_aw_coa_itm_terms.ld_cal_type%TYPE,
                     cp_ld_sequence_number igf_aw_coa_itm_terms.ld_sequence_number%TYPE
                    ) IS
    SELECT rowid row_id,
           lock_flag
      FROM igf_aw_coa_itm_terms
     WHERE base_id             = cp_base_id
       AND item_code           = cp_item_code
       AND ld_cal_type         = cp_ld_cal_type
       AND ld_sequence_number  = cp_ld_sequence_number;

    l_item_term           c_item_term%ROWTYPE;


  --Cursor to fetch item details for the base id
  CURSOR c_items(
                 c_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                 c_item_code          igf_aw_coa_itm_terms.item_code%TYPE
                ) IS
      SELECT item.rowid   row_id,
             item.*
        FROM igf_aw_coa_items   item
       WHERE base_id    = c_base_id
         AND item_code  = c_item_code;

    l_items     c_items%ROWTYPE;

  --Cursor to fetch the sum amount of all the terms for the base id
  CURSOR c_terms(
                 c_base_id            igf_ap_fa_base_rec_all.base_id%TYPE
                ) IS
      SELECT item_code,
             SUM(NVL(amount,0)) amount
        FROM igf_aw_coa_itm_terms   term
       WHERE base_id   = c_base_id
    GROUP BY item_code;

    l_terms     c_terms%ROWTYPE;


    l_base_details        igf_aw_coa_gen.base_details;
    lv_terms_updated      VARCHAR2(1);
    lv_item_assigned      VARCHAR2(1);
    lv_term_not_asgn      VARCHAR2(1);
    ln_amount             NUMBER;
    ln_rate_order         NUMBER;


  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','starting add_coa_items with '||
                                                                                             'p_base_id/p_grp_code/exeorder/l_process_id:'||
                                                                                             p_base_id || ' / ' || p_grp_code || ' / ' || exeorder || ' /' || l_process_id);
    END IF;

    result            := 'N';
    lv_terms_updated  := 'N';
    lv_term_not_asgn  := 'Y';


    IF (exeorder='FIRST') THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','exeorder:'||exeorder);
      END IF;
      result:='Y';

      FOR first_coa_rec IN c_first_coa(l_process_id) LOOP
        l_rowid           :=  NULL;
        lv_item_assigned  :=  'N';

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','calling items.insert with base_id/item_code -> ' ||
                                                                                                 p_base_id || ' / '|| first_coa_rec.item_code);
        END IF;
        g_coa_updated     := 'Y' ;

        igf_aw_coa_items_pkg.insert_row(
                                        x_rowid              =>  l_rowid,
                                        x_base_id            =>  p_base_id,
                                        x_item_code          =>  first_coa_rec.item_code,
                                        x_amount             =>  NVL(first_coa_rec.item_amount,0),
                                        x_pell_coa_amount    =>  first_coa_rec.pell_amount,
                                        x_alt_pell_amount    =>  first_coa_rec.pell_alternate_amount,
                                        x_fixed_cost         =>  first_coa_rec.fixed_cost,
                                        x_legacy_record_flag =>  NULL,
                                        x_mode               =>  'R',
                                        x_lock_flag           =>  first_coa_rec.lock_award_flag
                                       );


        FOR first_itm_term_rec IN c_first_itm_term(first_coa_rec.item_code,l_process_id) LOOP
            l_rowid    :=   NULL;
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','calling items.insert with base_id/item_code/ld_cal/ld_seq -> ' ||
                                                                                                 p_base_id || ' / '|| first_itm_term_rec.item_code ||
                                                                                                 ' / ' || first_itm_term_rec.ld_cal_type || ' / ' || first_itm_term_rec.ld_sequence_number);
            END IF;

            --if the amount is NULL Rate Order Setup is used
            IF first_itm_term_rec.item_term_amount IS NULL THEN
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','first_itm_term_rec.item_term_amount IS NULL '||
                                                          'and calling igf_aw_coa_gen.getBaseDetails');
                END IF;

                l_base_details := igf_aw_coa_gen.getBaseDetails(p_base_id,first_itm_term_rec.ld_cal_type,first_itm_term_rec.ld_sequence_number);

                --Rate Order found against the student attributes
                IF igf_aw_coa_update.is_attrib_matching(
                                     p_base_id               => p_base_id,
                                     p_base_details          => l_base_details,
                                     p_ci_cal_type           => g_cal_type,
                                     p_ci_sequence_number    => g_sequence_number,
                                     p_ld_cal_type           => first_itm_term_rec.ld_cal_type,
                                     p_ld_sequence_number    => first_itm_term_rec.ld_sequence_number,
                                     p_item_code             => first_itm_term_rec.item_code,
                                     p_amount                => ln_amount,
                                     p_rate_order_num        => ln_rate_order
                                     ) THEN

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','is_attrib_matching found');
                    END IF;

                    g_coa_updated     := 'Y';
                    lv_terms_updated  := 'Y';
                    lv_item_assigned  := 'Y';

                    igf_aw_coa_itm_terms_pkg.insert_row(
                                                x_rowid              => l_rowid,
                                                x_base_id            => p_base_id,
                                                x_item_code          => first_itm_term_rec.item_code,
                                                x_amount             => ln_amount,
                                                x_ld_cal_type        => first_itm_term_rec.ld_cal_type,
                                                x_ld_sequence_number => first_itm_term_rec.ld_sequence_number,
                                                x_mode               => 'R',
                                                x_lock_flag           => first_itm_term_rec.lock_award_flag
                                               );

                --skip the term if Rate Order Setup is not available
                ELSE
                  lv_term_not_asgn  := 'N';

                  IF NVL(ln_rate_order,0) <> -1 THEN
                    fnd_message.set_name('IGF','IGF_AW_ITEM_SKIP');
                    fnd_message.set_token('ITEM_CODE',first_itm_term_rec.item_code);
                    fnd_message.set_token('TERM_CODE',igf_gr_gen.get_alt_code(first_itm_term_rec.ld_cal_type,first_itm_term_rec.ld_sequence_number));
                    fnd_file.put_line(fnd_file.log,RPAD(' ',10)||fnd_message.get);
                  END IF;
                END IF;

            --if the amount is NOT NULL COA Group Setup is used
            ELSE
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','first_itm_term_rec.item_term_amount IS NOT NULL');
                END IF;

                g_coa_updated     := 'Y';
                lv_terms_updated  := 'Y';
                lv_item_assigned  := 'Y';

                igf_aw_coa_itm_terms_pkg.insert_row(
                                                x_rowid              => l_rowid,
                                                x_base_id            => p_base_id,
                                                x_item_code          => first_itm_term_rec.item_code,
                                                x_amount             => first_itm_term_rec.item_term_amount,
                                                x_ld_cal_type        => first_itm_term_rec.ld_cal_type,
                                                x_ld_sequence_number => first_itm_term_rec.ld_sequence_number,
                                                x_mode               => 'R',
                                                x_lock_flag           => first_itm_term_rec.lock_award_flag
                                               );
            END IF;
        END LOOP;

        IF lv_item_assigned = 'Y' THEN
            fnd_message.set_name('IGF','IGF_AW_COA_ITEM_ADD');
            fnd_message.set_token('ITEM_CODE',first_coa_rec.item_code);
            fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
        ELSE
            fnd_message.set_name('IGF','IGF_AW_COA_ITEM_NTADD');
            fnd_message.set_token('ITEM_CODE',first_coa_rec.item_code);
            fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
        END IF;

        IF lv_term_not_asgn  = 'N' THEN
            RAISE E_SKIP_STD_NO_TERMS;
        END IF;
      END LOOP;

      IF lv_terms_updated = 'N' THEN
        RAISE E_SKIP_STD_NO_ITEMS;
      END IF;

    ELSIF (exeorder='SECOND')  THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','exeorder:'||exeorder);
      END IF;
      result := 'N';

      IF g_update_coa = 'N' THEN
        IF does_term_mismatch(p_base_id,l_process_id) THEN
          fnd_message.set_name('IGF','IGF_AW_COA_INCONSTENT_TERMS');
          fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);

        ELSE
          result  := 'N';
          FOR chk_item_match_rec IN c_check_item_match(p_base_id,l_process_id) LOOP
            IF chk_item_match_rec.existing_item IS NULL THEN
              l_rowid:=  NULL;
              result := 'Y';
              g_coa_updated := 'Y' ;
              lv_item_assigned  :=  'N';

              igf_aw_coa_items_pkg.insert_row(
                                              x_rowid           => l_rowid,
                                              x_base_id         => p_base_id,
                                              x_item_code       => chk_item_match_rec.new_item,
                                              x_amount          => NVL(chk_item_match_rec.item_amount,0),
                                              x_pell_coa_amount => chk_item_match_rec.pell_amt,
                                              x_alt_pell_amount => chk_item_match_rec.pell_alt_amt,
                                              x_fixed_cost      => chk_item_match_rec.fixed_cost,
                                              x_mode            => 'R',
                                              x_lock_flag        => chk_item_match_rec.lock_award_flag
                                             );


              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','added item '||chk_item_match_rec.new_item);
              END IF;
              FOR sec_itm_term_rec IN c_second_item_term( chk_item_match_rec.new_item,l_process_id) LOOP
                l_rowid := NULL;

                --if the amount is NULL Rate Order Setup is used
                IF sec_itm_term_rec.item_term_amount IS NULL THEN
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','sec_itm_term_rec.item_term_amount IS NULL '||
                                                            'and calling igf_aw_coa_gen.getBaseDetails');
                  END IF;

                  l_base_details := igf_aw_coa_gen.getBaseDetails(p_base_id,sec_itm_term_rec.ld_cal_type,sec_itm_term_rec.ld_sequence_number);

                  --Rate Order found against the student attributes
                IF igf_aw_coa_update.is_attrib_matching(
                                     p_base_id               => p_base_id,
                                     p_base_details          => l_base_details,
                                     p_ci_cal_type           => g_cal_type,
                                     p_ci_sequence_number    => g_sequence_number,
                                     p_ld_cal_type           => sec_itm_term_rec.ld_cal_type,
                                     p_ld_sequence_number    => sec_itm_term_rec.ld_sequence_number,
                                     p_item_code             => sec_itm_term_rec.item_code,
                                     p_amount                => ln_amount,
                                     p_rate_order_num        => ln_rate_order
                                     ) THEN

                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','is_attrib_matching found');
                      END IF;

                      g_coa_updated     := 'Y';
                      lv_terms_updated  := 'Y';
                      lv_item_assigned  := 'Y';

                      igf_aw_coa_itm_terms_pkg.insert_row(
                                                    x_rowid              => l_rowid,
                                                    x_base_id            => p_base_id,
                                                    x_item_code          => sec_itm_term_rec.item_code,
                                                    x_amount             => ln_amount,
                                                    x_ld_cal_type        => sec_itm_term_rec.ld_cal_type,
                                                    x_ld_sequence_number => sec_itm_term_rec.ld_sequence_number,
                                                    x_mode               => 'R',
                                                    x_lock_flag           => sec_itm_term_rec.lock_award_flag
                                                  );

                  --skip the term if Rate Order Setup is not available
                  ELSE
                    lv_term_not_asgn  := 'N';

                    IF NVL(ln_rate_order,0) <> -1 THEN
                        fnd_message.set_name('IGF','IGF_AW_ITEM_SKIP');
                        fnd_message.set_token('ITEM_CODE',sec_itm_term_rec.item_code);
                        fnd_message.set_token('TERM_CODE',igf_gr_gen.get_alt_code(sec_itm_term_rec.ld_cal_type,sec_itm_term_rec.ld_sequence_number));
                        fnd_file.put_line(fnd_file.log,RPAD(' ',10)||fnd_message.get);
                    END IF;
                  END IF;

                --if the amount is NOT NULL COA Group Setup is used
                ELSE
                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','sec_itm_term_rec.item_term_amount IS NOT NULL');
                    END IF;

                    g_coa_updated     := 'Y';
                    lv_terms_updated  := 'Y';
                    lv_item_assigned  := 'Y';

                    igf_aw_coa_itm_terms_pkg.insert_row(
                                                    x_rowid              => l_rowid,
                                                    x_base_id            => p_base_id,
                                                    x_item_code          => sec_itm_term_rec.item_code,
                                                    x_amount             => sec_itm_term_rec.item_term_amount,
                                                    x_ld_cal_type        => sec_itm_term_rec.ld_cal_type,
                                                    x_ld_sequence_number => sec_itm_term_rec.ld_sequence_number,
                                                    x_mode               => 'R',
                                                    x_lock_flag           => sec_itm_term_rec.lock_award_flag
                                                   );
                END IF;

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','ld_cal/ld_seq/amount->'||
                                                                                                         sec_itm_term_rec.ld_cal_type || ' / '||
                                                                                                         sec_itm_term_rec.ld_sequence_number || ' / ' ||
                                                                                                         sec_itm_term_rec.item_term_amount);
                END IF;
              END LOOP;
            END IF;

            IF lv_item_assigned = 'Y' THEN
                fnd_message.set_name('IGF','IGF_AW_COA_ITEM_ADD');
                fnd_message.set_token('ITEM_CODE',chk_item_match_rec.new_item);
                fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
            ELSE
                fnd_message.set_name('IGF','IGF_AW_COA_ITEM_NTADD');
                fnd_message.set_token('ITEM_CODE',chk_item_match_rec.new_item);
                fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
            END IF;

            IF lv_term_not_asgn  = 'N' THEN
                RAISE E_SKIP_STD_NO_TERMS;
            END IF;
          END LOOP;

          IF lv_terms_updated = 'N' THEN
            RAISE E_SKIP_STD_NO_ITEMS;
          END IF;

        END IF;
      ELSIF g_update_coa = 'Y' THEN
        IF g_update_method = 'SKIP' THEN
          IF does_term_mismatch(p_base_id,l_process_id) THEN
            --log an error message
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','g_override_inconsistent_terms = N!so erroring out');
            END IF;
            fnd_message.set_name('IGF','IGF_AW_COA_INCONSTENT_TERMS');
            fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
            result := 'N';
          ELSE
            FOR chk_item_match_rec IN c_check_item_match(p_base_id,l_process_id) LOOP
              l_rowid := NULL;
              IF chk_item_match_rec.existing_item IS NULL THEN
                --the COA item is not assigned
                --so insert the item
                g_coa_updated := 'Y' ;
                lv_item_assigned  :=  'N';

                igf_aw_coa_items_pkg.insert_row(
                                                x_rowid           => l_rowid,
                                                x_base_id         => p_base_id,
                                                x_item_code       => chk_item_match_rec.new_item,
                                                x_amount          => NVL(chk_item_match_rec.item_amount,0),
                                                x_pell_coa_amount => chk_item_match_rec.pell_amt,
                                                x_alt_pell_amount => chk_item_match_rec.pell_alt_amt,
                                                x_fixed_cost      => chk_item_match_rec.fixed_cost,
                                                x_mode            => 'R',
                                                x_lock_flag        => chk_item_match_rec.lock_award_flag
                                               );

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','added item '||chk_item_match_rec.new_item);
                END IF;

                -- start adding terms and term amounts
                FOR sec_itm_term_rec IN c_second_item_term(chk_item_match_rec.new_item,l_process_id) LOOP
                  l_rowid := NULL;

                  --if the amount is NULL Rate Order Setup is used
                  IF sec_itm_term_rec.item_term_amount IS NULL THEN
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','sec_itm_term_rec.item_term_amount IS NULL '||
                                                                'and calling igf_aw_coa_gen.getBaseDetails');
                      END IF;

                      l_base_details := igf_aw_coa_gen.getBaseDetails(p_base_id,sec_itm_term_rec.ld_cal_type,sec_itm_term_rec.ld_sequence_number);

                      --Rate Order found against the student attributes
                  IF igf_aw_coa_update.is_attrib_matching(
                                     p_base_id               => p_base_id,
                                     p_base_details          => l_base_details,
                                     p_ci_cal_type           => g_cal_type,
                                     p_ci_sequence_number    => g_sequence_number,
                                     p_ld_cal_type           => sec_itm_term_rec.ld_cal_type,
                                     p_ld_sequence_number    => sec_itm_term_rec.ld_sequence_number,
                                     p_item_code             => sec_itm_term_rec.item_code,
                                     p_amount                => ln_amount,
                                     p_rate_order_num        => ln_rate_order
                                     ) THEN

                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','is_attrib_matching found');
                        END IF;

                        g_coa_updated     := 'Y';
                        lv_terms_updated  := 'Y';
                        lv_item_assigned  := 'Y';

                        igf_aw_coa_itm_terms_pkg.insert_row(
                                                      x_rowid              => l_rowid,
                                                      x_base_id            => p_base_id,
                                                      x_item_code          => sec_itm_term_rec.item_code,
                                                      x_amount             => ln_amount,
                                                      x_ld_cal_type        => sec_itm_term_rec.ld_cal_type,
                                                      x_ld_sequence_number => sec_itm_term_rec.ld_sequence_number,
                                                      x_mode               => 'R',
                                                      x_lock_flag           => sec_itm_term_rec.lock_award_flag
                                                     );

                      --skip the term if Rate Order Setup is not available
                      ELSE
                        lv_term_not_asgn  := 'N';

                        IF NVL(ln_rate_order,0) <> -1 THEN
                          fnd_message.set_name('IGF','IGF_AW_ITEM_SKIP');
                          fnd_message.set_token('ITEM_CODE',sec_itm_term_rec.item_code);
                          fnd_message.set_token('TERM_CODE',igf_gr_gen.get_alt_code(sec_itm_term_rec.ld_cal_type,sec_itm_term_rec.ld_sequence_number));
                          fnd_file.put_line(fnd_file.log,RPAD(' ',10)||fnd_message.get);
                        END IF;
                      END IF;

                  --if the amount is NOT NULL COA Group Setup is used
                  ELSE
                      g_coa_updated     := 'Y';
                      lv_terms_updated  := 'Y';
                      lv_item_assigned  := 'Y';

                      igf_aw_coa_itm_terms_pkg.insert_row(
                                                          x_rowid              => l_rowid,
                                                          x_base_id            => p_base_id,
                                                          x_item_code          => sec_itm_term_rec.item_code,
                                                          x_amount             => sec_itm_term_rec.item_term_amount,
                                                          x_ld_cal_type        => sec_itm_term_rec.ld_cal_type,
                                                          x_ld_sequence_number => sec_itm_term_rec.ld_sequence_number,
                                                          x_mode               => 'R',
                                                          x_lock_flag           => sec_itm_term_rec.lock_award_flag
                                                         );

                  END IF;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','ld_cal/ld_seq/amount->'||
                                                                                                           sec_itm_term_rec.ld_cal_type || ' / '||
                                                                                                           sec_itm_term_rec.ld_sequence_number || ' / ' ||
                                                                                                           sec_itm_term_rec.item_term_amount);
                  END IF;

                END LOOP;

                IF lv_item_assigned = 'Y' THEN
                    fnd_message.set_name('IGF','IGF_AW_COA_ITEM_ADD');
                    fnd_message.set_token('ITEM_CODE',chk_item_match_rec.new_item);
                    fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
                ELSE
                    fnd_message.set_name('IGF','IGF_AW_COA_ITEM_NTADD');
                    fnd_message.set_token('ITEM_CODE',chk_item_match_rec.new_item);
                    fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
                END IF;

                IF lv_term_not_asgn  = 'N' THEN
                    RAISE E_SKIP_STD_NO_TERMS;
                END IF;

              ELSE
                --the student has the COA item assigned
                --so if it needs update, update it
                IF coa_needs_update(chk_item_match_rec.new_item,p_base_id,chk_item_match_rec.item_amount,chk_item_match_rec.pell_amt,chk_item_match_rec.pell_alt_amt,chk_item_match_rec.fixed_cost) THEN
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','updating item '||chk_item_match_rec.new_item);
                  END IF;
                  igf_aw_coa_items_pkg.update_row(
                                                  x_rowid           => chk_item_match_rec.row_id,
                                                  x_base_id         => p_base_id,
                                                  x_item_code       => chk_item_match_rec.new_item,
                                                  x_amount          => NVL(chk_item_match_rec.item_amount,0),
                                                  x_pell_coa_amount => chk_item_match_rec.pell_amt,
                                                  x_alt_pell_amount => chk_item_match_rec.pell_alt_amt,
                                                  x_fixed_cost      => chk_item_match_rec.fixed_cost,
                                                  x_mode            => 'R',
                                                  x_lock_flag        => chk_item_match_rec.lock_award_flag
                                                 );
                  g_coa_updated := 'Y' ;
                  lv_item_assigned  :=  'N';


                  FOR sec_itm_term_rec IN c_second_item_term(chk_item_match_rec.new_item,l_process_id) LOOP
                    l_rowid := NULL;
                    OPEN c_item_term(p_base_id,sec_itm_term_rec.item_code,sec_itm_term_rec.ld_cal_type,sec_itm_term_rec.ld_sequence_number);
                    FETCH c_item_term INTO l_item_term;
                    CLOSE c_item_term;

                    IF  l_item_term.row_id is null THEN
                       RAISE E_SKIP_STUDENT;
                    END IF;

                    --skip the item if it is locked
                    IF l_item_term.lock_flag = 'Y' THEN
                      fnd_message.set_name('IGF','IGF_AW_SKP_LK_ITM');
                      fnd_message.set_token('ITEM_CODE',l_items.item_code);
                      fnd_file.put_line(fnd_file.log,RPAD(' ',10)||fnd_message.get);
                    ELSE
                      --if the amount is NULL Rate Order Setup is used
                      IF sec_itm_term_rec.item_term_amount IS NULL THEN
                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','sec_itm_term_rec.item_term_amount IS NULL '||
                                                                    'and calling igf_aw_coa_gen.getBaseDetails');
                          END IF;

                          l_base_details := igf_aw_coa_gen.getBaseDetails(p_base_id,sec_itm_term_rec.ld_cal_type,sec_itm_term_rec.ld_sequence_number);

                          --Rate Order found against the student attributes
                          IF igf_aw_coa_update.is_attrib_matching(
                                     p_base_id               => p_base_id,
                                     p_base_details          => l_base_details,
                                     p_ci_cal_type           => g_cal_type,
                                     p_ci_sequence_number    => g_sequence_number,
                                     p_ld_cal_type           => sec_itm_term_rec.ld_cal_type,
                                     p_ld_sequence_number    => sec_itm_term_rec.ld_sequence_number,
                                     p_item_code             => sec_itm_term_rec.item_code,
                                     p_amount                => ln_amount,
                                     p_rate_order_num        => ln_rate_order
                                     ) THEN

                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','is_attrib_matching found');
                            END IF;

                            g_coa_updated     := 'Y';
                            lv_terms_updated  := 'Y';
                            lv_item_assigned  := 'Y';

                            igf_aw_coa_itm_terms_pkg.update_row(
                                                              x_rowid              => l_item_term.row_id,
                                                              x_base_id            => p_base_id,
                                                              x_item_code          => sec_itm_term_rec.item_code,
                                                              x_amount             => ln_amount,
                                                              x_ld_cal_type        => sec_itm_term_rec.ld_cal_type,
                                                              x_ld_sequence_number => sec_itm_term_rec.ld_sequence_number,
                                                              x_mode               => 'R',
                                                              x_lock_flag           => sec_itm_term_rec.lock_award_flag
                                                             );

                          --skip the term if Rate Order Setup is not available
                          ELSE
                              lv_term_not_asgn  := 'N';

                              IF NVL(ln_rate_order,0) <> -1 THEN
                                fnd_message.set_name('IGF','IGF_AW_ITEM_SKIP');
                                fnd_message.set_token('ITEM_CODE',sec_itm_term_rec.item_code);
                                fnd_message.set_token('TERM_CODE',igf_gr_gen.get_alt_code(sec_itm_term_rec.ld_cal_type,sec_itm_term_rec.ld_sequence_number));
                                fnd_file.put_line(fnd_file.log,RPAD(' ',10)||fnd_message.get);
                              END IF;
                          END IF;

                      --if the amount is NOT NULL COA Group Setup is used
                      ELSE
                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','sec_itm_term_rec.item_term_amount IS NOT NULL');
                            END IF;

                            igf_aw_coa_itm_terms_pkg.update_row(
                                                                x_rowid              => l_item_term.row_id,
                                                                x_base_id            => p_base_id,
                                                                x_item_code          => sec_itm_term_rec.item_code,
                                                                x_amount             => sec_itm_term_rec.item_term_amount,
                                                                x_ld_cal_type        => sec_itm_term_rec.ld_cal_type,
                                                                x_ld_sequence_number => sec_itm_term_rec.ld_sequence_number,
                                                                x_mode               => 'R',
                                                                x_lock_flag           => sec_itm_term_rec.lock_award_flag
                                                               );


                            g_coa_updated     := 'Y';
                            lv_terms_updated  := 'Y';
                            lv_item_assigned  := 'Y';
                      END IF;

                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','ld_cal/ld_seq/amount->'||
                                                                                                               sec_itm_term_rec.ld_cal_type || ' / '||
                                                                                                               sec_itm_term_rec.ld_sequence_number || ' / ' ||
                                                                                                               sec_itm_term_rec.item_term_amount);
                      END IF;
                    END IF;
                  END LOOP;

                  IF lv_item_assigned = 'Y' THEN
                      fnd_message.set_name('IGF','IGF_AW_COA_ITM_ATTR_CHNG');
                      fnd_message.set_token('ITEM_CODE',chk_item_match_rec.new_item);
                      fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
                  ELSE
                      fnd_message.set_name('IGF','IGF_AW_COA_ITM_ATTR_NTCHNG');
                      fnd_message.set_token('ITEM_CODE',chk_item_match_rec.new_item);
                      fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
                  END IF;

                  IF lv_term_not_asgn  = 'N' THEN
                      RAISE E_SKIP_STD_NO_TERMS;
                  END IF;

                END IF;
              END IF;
            END LOOP;

            IF lv_terms_updated = 'N' THEN
              RAISE E_SKIP_STD_NO_ITEMS;
            END IF;

            result := 'Y';
          END IF;
        ELSIF g_update_method = 'OVERWRITE' THEN
          IF does_term_mismatch(p_base_id,l_process_id) THEN
            --delete and recreate COA
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','calling delete_coa');
            END IF;

            --delete only if it is unlock
            IF NOT iscoalocked(p_base_id) THEN
              RAISE E_SKIP_STD_NO_ITEMS;
            END IF;

            delete_coa(p_base_id);

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','calling add_coa_items with exeorder=FIRST');
            END IF;

            add_coa_items(
                          p_base_id,
                          p_grp_code,
                          'FIRST',
                          l_process_id,
                          result
                         );
          ELSE
            FOR chk_item_match_rec IN c_check_item_match(p_base_id,l_process_id) LOOP
              l_rowid := NULL;
              IF chk_item_match_rec.existing_item IS NULL THEN
                --the COA item is not assigned
                --so insert the item
                g_coa_updated := 'Y' ;
                lv_item_assigned  :=  'N';

                igf_aw_coa_items_pkg.insert_row(
                                                x_rowid           => l_rowid,
                                                x_base_id         => p_base_id,
                                                x_item_code       => chk_item_match_rec.new_item,
                                                x_amount          => NVL(chk_item_match_rec.item_amount,0),
                                                x_pell_coa_amount => chk_item_match_rec.pell_amt,
                                                x_alt_pell_amount => chk_item_match_rec.pell_alt_amt,
                                                x_fixed_cost      => chk_item_match_rec.fixed_cost,
                                                x_mode            => 'R',
                                                x_lock_flag        => chk_item_match_rec.lock_award_flag
                                               );


                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','added item '||chk_item_match_rec.new_item);
                END IF;

                -- start adding terms and term amounts
                FOR sec_itm_term_rec IN c_second_item_term(chk_item_match_rec.new_item,l_process_id) LOOP
                  l_rowid := NULL;

                  --if the amount is NULL Rate Order Setup is used
                  IF sec_itm_term_rec.item_term_amount IS NULL THEN
                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','sec_itm_term_rec.item_term_amount IS NULL '||
                                                                'and calling igf_aw_coa_gen.getBaseDetails');
                      END IF;

                      l_base_details := igf_aw_coa_gen.getBaseDetails(p_base_id,sec_itm_term_rec.ld_cal_type,sec_itm_term_rec.ld_sequence_number);

                      --Rate Order found against the student attributes
                      IF igf_aw_coa_update.is_attrib_matching(
                                     p_base_id               => p_base_id,
                                     p_base_details          => l_base_details,
                                     p_ci_cal_type           => g_cal_type,
                                     p_ci_sequence_number    => g_sequence_number,
                                     p_ld_cal_type           => sec_itm_term_rec.ld_cal_type,
                                     p_ld_sequence_number    => sec_itm_term_rec.ld_sequence_number,
                                     p_item_code             => sec_itm_term_rec.item_code,
                                     p_amount                => ln_amount,
                                     p_rate_order_num        => ln_rate_order
                                     ) THEN

                            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','is_attrib_matching found');
                            END IF;

                            g_coa_updated     := 'Y';
                            lv_terms_updated  := 'Y';
                            lv_item_assigned  := 'Y';

                            igf_aw_coa_itm_terms_pkg.insert_row(
                                                                x_rowid              => l_rowid,
                                                                x_base_id            => p_base_id,
                                                                x_item_code          => sec_itm_term_rec.item_code,
                                                                x_amount             => ln_amount,
                                                                x_ld_cal_type        => sec_itm_term_rec.ld_cal_type,
                                                                x_ld_sequence_number => sec_itm_term_rec.ld_sequence_number,
                                                                x_mode               => 'R',
                                                                x_lock_flag           => sec_itm_term_rec.lock_award_flag
                                                               );

                      --skip the term if Rate Order Setup is not available
                      ELSE
                          lv_term_not_asgn  := 'N';

                          IF NVL(ln_rate_order,0) <> -1 THEN
                            fnd_message.set_name('IGF','IGF_AW_ITEM_SKIP');
                            fnd_message.set_token('ITEM_CODE',sec_itm_term_rec.item_code);
                            fnd_message.set_token('TERM_CODE',igf_gr_gen.get_alt_code(sec_itm_term_rec.ld_cal_type,sec_itm_term_rec.ld_sequence_number));
                            fnd_file.put_line(fnd_file.log,RPAD(' ',10)||fnd_message.get);
                          END IF;
                      END IF;

                  --if the amount is NOT NULL COA Group Setup is used
                  ELSE
                      g_coa_updated     := 'Y';
                      lv_terms_updated  := 'Y';
                      lv_item_assigned  := 'Y';

                      igf_aw_coa_itm_terms_pkg.insert_row(
                                                          x_rowid              => l_rowid,
                                                          x_base_id            => p_base_id,
                                                          x_item_code          => sec_itm_term_rec.item_code,
                                                          x_amount             => sec_itm_term_rec.item_term_amount,
                                                          x_ld_cal_type        => sec_itm_term_rec.ld_cal_type,
                                                          x_ld_sequence_number => sec_itm_term_rec.ld_sequence_number,
                                                          x_mode               => 'R',
                                                          x_lock_flag           => sec_itm_term_rec.lock_award_flag
                                                         );
                  END IF;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','ld_cal/ld_seq/amount->'||
                                                                                                           sec_itm_term_rec.ld_cal_type || ' / '||
                                                                                                           sec_itm_term_rec.ld_sequence_number || ' / ' ||
                                                                                                           sec_itm_term_rec.item_term_amount);
                  END IF;
                END LOOP;

                IF lv_item_assigned = 'Y' THEN
                    fnd_message.set_name('IGF','IGF_AW_COA_ITEM_ADD');
                    fnd_message.set_token('ITEM_CODE',chk_item_match_rec.new_item);
                    fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
                ELSE
                    fnd_message.set_name('IGF','IGF_AW_COA_ITEM_NTADD');
                    fnd_message.set_token('ITEM_CODE',chk_item_match_rec.new_item);
                    fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
                END IF;

                IF lv_term_not_asgn  = 'N' THEN
                    RAISE E_SKIP_STD_NO_TERMS;
                END IF;

              ELSE
                --the student has the COA item assigned
                --so if it needs update, update it
                IF coa_needs_update(chk_item_match_rec.new_item,p_base_id,chk_item_match_rec.item_amount,chk_item_match_rec.pell_amt,chk_item_match_rec.pell_alt_amt,chk_item_match_rec.fixed_cost) THEN
                  igf_aw_coa_items_pkg.update_row(
                                                  x_rowid           => chk_item_match_rec.row_id,
                                                  x_base_id         => p_base_id,
                                                  x_item_code       => chk_item_match_rec.new_item,
                                                  x_amount          => NVL(chk_item_match_rec.item_amount,0),
                                                  x_pell_coa_amount => chk_item_match_rec.pell_amt,
                                                  x_alt_pell_amount => chk_item_match_rec.pell_alt_amt,
                                                  x_fixed_cost      => chk_item_match_rec.fixed_cost,
                                                  x_mode            => 'R',
                                                  x_lock_flag        => chk_item_match_rec.lock_award_flag
                                                 );
                  g_coa_updated := 'Y' ;
                  lv_item_assigned  :=  'N';


                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','changed item '||chk_item_match_rec.new_item);
                  END IF;

                  FOR sec_itm_term_rec IN c_second_item_term(chk_item_match_rec.new_item,l_process_id) LOOP
                    l_rowid := NULL;
                    OPEN c_item_term(p_base_id,sec_itm_term_rec.item_code,sec_itm_term_rec.ld_cal_type,sec_itm_term_rec.ld_sequence_number);
                    FETCH c_item_term INTO l_item_term;
                    CLOSE c_item_term;

                    IF  l_item_term.row_id is null THEN
                       RAISE E_SKIP_STUDENT;
                    END IF;

                    --skip the item if it is locked
                    IF l_item_term.lock_flag = 'Y' THEN
                      fnd_message.set_name('IGF','IGF_AW_SKP_LK_ITM');
                      fnd_message.set_token('ITEM_CODE',l_items.item_code);
                      fnd_file.put_line(fnd_file.log,RPAD(' ',10)||fnd_message.get);
                    ELSE

                      --if the amount is NULL Rate Order Setup is used
                      IF sec_itm_term_rec.item_term_amount IS NULL THEN
                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','sec_itm_term_rec.item_term_amount IS NULL '||
                                                                    'and calling igf_aw_coa_gen.getBaseDetails');
                          END IF;

                          l_base_details := igf_aw_coa_gen.getBaseDetails(p_base_id,sec_itm_term_rec.ld_cal_type,sec_itm_term_rec.ld_sequence_number);

                          --Rate Order found against the student attributes
                          IF igf_aw_coa_update.is_attrib_matching(
                                     p_base_id               => p_base_id,
                                     p_base_details          => l_base_details,
                                     p_ci_cal_type           => g_cal_type,
                                     p_ci_sequence_number    => g_sequence_number,
                                     p_ld_cal_type           => sec_itm_term_rec.ld_cal_type,
                                     p_ld_sequence_number    => sec_itm_term_rec.ld_sequence_number,
                                     p_item_code             => sec_itm_term_rec.item_code,
                                     p_amount                => ln_amount,
                                     p_rate_order_num        => ln_rate_order
                                     ) THEN

                                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','is_attrib_matching found');
                                END IF;

                                g_coa_updated     := 'Y';
                                lv_terms_updated  := 'Y';
                                lv_item_assigned  := 'Y';

                                igf_aw_coa_itm_terms_pkg.update_row(
                                                                    x_rowid              => l_item_term.row_id,
                                                                    x_base_id            => p_base_id,
                                                                    x_item_code          => sec_itm_term_rec.item_code,
                                                                    x_amount             => ln_amount,
                                                                    x_ld_cal_type        => sec_itm_term_rec.ld_cal_type,
                                                                    x_ld_sequence_number => sec_itm_term_rec.ld_sequence_number,
                                                                    x_mode               => 'R',
                                                                    x_lock_flag           => sec_itm_term_rec.lock_award_flag
                                                                   );

                          --skip the term if Rate Order Setup is not available
                          ELSE
                              lv_term_not_asgn  := 'N';

                              IF NVL(ln_rate_order,0) <> -1 THEN
                                fnd_message.set_name('IGF','IGF_AW_ITEM_SKIP');
                                fnd_message.set_token('ITEM_CODE',sec_itm_term_rec.item_code);
                                fnd_message.set_token('TERM_CODE',igf_gr_gen.get_alt_code(sec_itm_term_rec.ld_cal_type,sec_itm_term_rec.ld_sequence_number));
                                fnd_file.put_line(fnd_file.log,RPAD(' ',10)||fnd_message.get);
                              END IF;
                          END IF;

                      --if the amount is NOT NULL COA Group Setup is used
                      ELSE
                          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','sec_itm_term_rec.item_term_amount IS NOT NULL');
                          END IF;

                          igf_aw_coa_itm_terms_pkg.update_row(
                                                              x_rowid              => l_item_term.row_id,
                                                              x_base_id            => p_base_id,
                                                              x_item_code          => sec_itm_term_rec.item_code,
                                                              x_amount             => sec_itm_term_rec.item_term_amount,
                                                              x_ld_cal_type        => sec_itm_term_rec.ld_cal_type,
                                                              x_ld_sequence_number => sec_itm_term_rec.ld_sequence_number,
                                                              x_mode               => 'R',
                                                              x_lock_flag           => sec_itm_term_rec.lock_award_flag
                                                             );
                          g_coa_updated     := 'Y';
                          lv_terms_updated  := 'Y';
                          lv_item_assigned  := 'Y';
                      END IF;

                      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.add_coa_items.debug','ld_cal/ld_seq/amount->'||
                                                                                                               sec_itm_term_rec.ld_cal_type || ' / '||
                                                                                                               sec_itm_term_rec.ld_sequence_number || ' / ' ||
                                                                                                               sec_itm_term_rec.item_term_amount);
                      END IF;
                    END IF;
                  END LOOP;

                  IF lv_item_assigned = 'Y' THEN
                      fnd_message.set_name('IGF','IGF_AW_COA_ITM_ATTR_CHNG');
                      fnd_message.set_token('ITEM_CODE',chk_item_match_rec.new_item);
                      fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
                  ELSE
                      fnd_message.set_name('IGF','IGF_AW_COA_ITM_ATTR_NTCHNG');
                      fnd_message.set_token('ITEM_CODE',chk_item_match_rec.new_item);
                      fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
                  END IF;

                  IF lv_term_not_asgn  = 'N' THEN
                      RAISE E_SKIP_STD_NO_TERMS;
                  END IF;

                END IF;
              END IF;
            END LOOP;

            IF lv_terms_updated = 'N' THEN
              RAISE E_SKIP_STD_NO_ITEMS;
            END IF;
            result := 'Y';
          END IF;
        END IF;
      END IF;
    END IF;


    FOR l_terms IN c_terms(p_base_id)
    LOOP

    --if the item code is NOT NULL insert
    IF l_terms.item_code IS NOT NULL THEN
        OPEN c_items(p_base_id,l_terms.item_code);
        FETCH c_items INTO l_items;
        CLOSE c_items;

        igf_aw_coa_items_pkg.update_row(
                                        x_rowid               => l_items.row_id,
                                        x_base_id             => l_items.base_id,
                                        x_item_code           => l_items.item_code,
                                        x_amount              => l_terms.amount,
                                        x_pell_coa_amount     => l_items.pell_coa_amount,
                                        x_alt_pell_amount     => l_items.alt_pell_amount,
                                        x_fixed_cost          => l_items.fixed_cost,
                                        x_legacy_record_flag  => l_items.legacy_record_flag,
                                        x_mode                => 'R',
                                        x_lock_flag            => l_items.lock_flag
                                       );

    END IF;
    END LOOP;

  EXCEPTION
    WHEN E_SKIP_STUDENT THEN
      RAISE E_SKIP_STUDENT;
    WHEN E_SKIP_STD_NO_ITEMS THEN
      RAISE E_SKIP_STD_NO_ITEMS;
    WHEN E_SKIP_STD_NO_TERMS THEN
      RAISE E_SKIP_STD_NO_TERMS;
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AW_COA_CALC.ADD_COA_ITEMS' || ' '|| SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_coa_calc.add_coa_items.exception','sql error message: '||SQLERRM);
      END IF;

      igs_ge_msg_stack.conc_exception_hndl;
      app_exception.raise_exception;

  END add_coa_items;



  ---------------------------------------------------------------------------------
  --Procedure to print output file
  --CREATED BY:gmuralid
  -------------------------------------------------------------------------------
  PROCEDURE print_output_file(
                              p_base_id IN igf_ap_fa_base_rec_all.base_id%TYPE
                             ) IS

  CURSOR c_out_file(
                    c_base_id  igf_ap_fa_base_rec_all.base_id%TYPE
                   ) IS
    SELECT ca.alternate_code term,
           SUM(NVL(terms.amount,0)) amount
      FROM igf_aw_coa_itm_terms terms,
           igs_ca_inst ca
     WHERE ca.cal_type = terms.ld_cal_type
       AND ca.sequence_number = terms.ld_sequence_number
       AND terms.base_id = c_base_id
     GROUP BY base_id,
              alternate_code
     ORDER BY 1;
  c_out_file_rec    c_out_file%ROWTYPE;

  CURSOR c_total_coa(
                     c_base_id  igf_ap_fa_base_rec_all.base_id%TYPE
                    ) IS
    SELECT coa_f total
      FROM igf_ap_fa_base_rec
     WHERE base_id = c_base_id;
  c_total_coa_rec c_total_coa%ROWTYPE;

  BEGIN

    IF g_b_header THEN
      fnd_message.set_name('IGF','IGF_AW_COA_PRINT_DTLS');
      fnd_file.put_line(fnd_file.output,fnd_message.get);
      fnd_file.put_line(fnd_file.output,RPAD('-',60,'-'));
      fnd_file.new_line(fnd_file.output,1);
      g_b_header := FALSE;
    END IF;

    fnd_file.new_line(fnd_file.output,1);
    fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','PERSON_NUMBER'),15)
                                      ||LPAD(igf_gr_gen.get_per_num(p_base_id),15));
    fnd_file.new_line(fnd_file.output,1);


    fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','TERM'),30)
                                      || LPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','COA_TP_TOT'),30));
    FOR c_out_file_rec IN c_out_file(p_base_id) LOOP
         fnd_file.put_line(fnd_file.output,RPAD(c_out_file_rec.term,30)
                                           ||LPAD(TO_CHAR(c_out_file_rec.amount,'FM9999999990D90'),30));
    END LOOP;

    OPEN c_total_coa(p_base_id);
    FETCH c_total_coa INTO c_total_coa_rec;
    fnd_file.new_line(fnd_file.output,1);
    fnd_file.put_line(fnd_file.output,RPAD('-',60,'-'));
    fnd_file.put_line(fnd_file.output,RPAD(igf_aw_gen.lookup_desc('IGF_AW_LOOKUPS_MSG','COA_TOT'),30)
                                      ||LPAD(TO_CHAR(c_total_coa_rec.total,'FM9999999990D90'),30));
    CLOSE c_total_coa;

    fnd_file.put_line(fnd_file.output,RPAD('-',60,'-'));
  EXCEPTION
    WHEN OTHERS THEN
       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGF_AW_COA_CALC.PRINT_OUTPUT_FILE' || ' '|| SQLERRM);
       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_coa_calc.print_output_file.exception','sql error message: '||SQLERRM);
       END IF;
       igs_ge_msg_stack.conc_exception_hndl;
       app_exception.raise_exception;
  END print_output_file;



  PROCEDURE process_student(
                            p_base_id    igf_ap_fa_base_rec_all.base_id%TYPE,
                            p_grp_code   igf_aw_coa_grp_item.coa_code%TYPE,
                            p_process_id NUMBER
                           ) IS
  ------------------------------------------------------------------
  --Created by  :
  --Date created:
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --veramach    08-Jan-2004     FA CCR 118 COA Updates
  --                            Added validations for overaward situation and PELL COA change
  -------------------------------------------------------------------

  -- Cursor below retrieves all existing COA information for a student
  CURSOR cur_per_coa(
                     p_base_id   igf_ap_fa_base_rec_all.base_id%TYPE
                    ) IS
    SELECT 'x'
      FROM igf_aw_coa_itm_terms coa
     WHERE coa.base_id = p_base_id
       AND rownum      = 1;

  l_cur_per_coa cur_per_coa%ROWTYPE;
  lv_result     VARCHAR2(5);

  -- Get pell COA amounts
  CURSOR c_pell_coa(
                    cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                   ) IS
    SELECT SUM(NVL(pell_coa_amount,0)) pell_coa,
           SUM(NVL(alt_pell_amount,0)) alt_pell_coa
      FROM igf_aw_coa_items
     WHERE base_id = cp_base_id;

  l_old_coa c_pell_coa%ROWTYPE;
  l_new_coa c_pell_coa%ROWTYPE;

  -- check whether the student has pell award
  CURSOR c_pell_award(
                      cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                    ) IS
    SELECT 'x'
      FROM igf_aw_fund_cat_all fcat,
           igf_aw_fund_mast_all fmast,
           igf_aw_award_all awd
     WHERE fcat.fed_fund_code = 'PELL'
       AND fcat.fund_code = fmast.fund_code
       AND fmast.fund_id = awd.fund_id
       AND awd.award_status IN ('ACCEPTED','OFFERED')
       AND awd.base_id   = cp_base_id;

  l_pell_award   c_pell_award%ROWTYPE;


   --This cursor is to fetch person details
    CURSOR  c_base_rec (
                          c_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                         ) IS
      SELECT NVL(fab.lock_coa_flag,'N') lock_coa_flag
        FROM igf_ap_fa_base_rec fab
       WHERE fab.base_id = c_base_id;

    l_base_rec         c_base_rec%ROWTYPE;


  ln_overaward NUMBER := 0;

  BEGIN

    OPEN c_pell_coa(p_base_id);
    FETCH c_pell_coa INTO l_old_coa;
    CLOSE c_pell_coa;

    SAVEPOINT start_coa_calc;
    g_coa_updated := 'N' ;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.process_student.debug','starting process_student with ' ||
                                                                                               'base_id/group->' ||
                                                                                               p_base_id || ' / ' ||
                                                                                               p_grp_code);
    END IF;

    fnd_file.put_line(fnd_file.log,'     --------------------------------------------------------');
    fnd_message.set_name('IGF','IGF_AW_COA_PROCESS_STD');
    fnd_file.put_line(fnd_file.log,RPAD(' ',5) || RPAD(fnd_message.get,55) || igf_gr_gen.get_per_num(p_base_id));
    fnd_file.new_line(fnd_file.log,1);

    OPEN  c_base_rec(p_base_id);
    FETCH c_base_rec INTO l_base_rec;
    CLOSE c_base_rec;

    IF l_base_rec.lock_coa_flag = 'Y' THEN
        fnd_message.set_name('IGF','IGF_AW_STUD_SKIP');
        fnd_file.put_line(fnd_file.log,RPAD(' ',10)||fnd_message.get);
    ELSE
        OPEN cur_per_coa(p_base_id);
        FETCH cur_per_coa INTO l_cur_per_coa ;

        IF cur_per_coa%FOUND THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.process_student.debug','calling add_coa_items with exeorder SECOND');
          END IF;
          add_coa_items(
                        p_base_id,
                        p_grp_code,
                        'SECOND',
                        p_process_id,
                        lv_result
                       );
        ELSIF cur_per_coa%NOTFOUND THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.process_student.debug','calling add_coa_items with exeorder FIRST');
          END IF;
          add_coa_items(
                        p_base_id,
                        p_grp_code,
                        'FIRST',
                        p_process_id,
                        lv_result
                       );
        END IF;
        CLOSE cur_per_coa;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.process_student.debug','add_coa_items_returned lv_result:'||lv_result);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.process_student.debug','calling igf_aw_gen_003.updating_coa_in_fa_base');
        END IF;
        igf_aw_gen_003.updating_coa_in_fa_base(p_base_id);

        IF lv_result = 'Y' AND g_coa_updated = 'Y' THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.process_student.debug','calling print_output_file, and checking overaward');
          END IF;

          print_output_file(p_base_id);

          IF igf_aw_packng_subfns.is_over_award_occured(p_base_id) THEN
            fnd_message.set_name('IGF','IGF_AW_COA_RSLT_OVERAWD');
            fnd_message.set_token('OVER_AWD_AMT',overaward_amount(p_base_id));
            fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
          END IF;

          OPEN c_pell_award(p_base_id);
          FETCH c_pell_award INTO l_pell_award;

          IF c_pell_award%FOUND THEN

            OPEN c_pell_coa(p_base_id);
            FETCH c_pell_coa INTO l_new_coa;
            CLOSE c_pell_coa;

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.process_student.debug','l_old_coa.pell_coa:'||l_old_coa.pell_coa);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.process_student.debug','l_new_coa.pell_coa:'||l_new_coa.pell_coa);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.process_student.debug','l_old_coa.alt_pell_coa:'||l_old_coa.alt_pell_coa);
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.process_student.debug','l_new_coa.alt_pell_coa:'||l_new_coa.alt_pell_coa);
            END IF;

            IF l_old_coa.pell_coa <> l_new_coa.pell_coa OR l_old_coa.alt_pell_coa <> l_new_coa.alt_pell_coa THEN
              fnd_message.set_name('IGF','IGF_AW_PELL_COA_CHNG');
              fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
            END IF;

          END IF;

        END IF;

        IF g_coa_updated = 'N' THEN
          fnd_message.set_name('IGF','IGF_AW_NO_CHNG');
          fnd_file.put_line(fnd_file.log,RPAD(' ',10,' ') || fnd_message.get);
        END IF;

        fnd_message.set_name('IGF','IGF_AW_COA_ASSIGN_COMP');
        fnd_message.set_token('PERSON_NUMBER',igf_gr_gen.get_per_num(p_base_id));
        fnd_file.put_line(fnd_file.log,RPAD(' ',10) || fnd_message.get);
        fnd_file.new_line(fnd_file.log,1);

        COMMIT;

    END IF;


  EXCEPTION
    WHEN E_SKIP_STUDENT  THEN
       ROLLBACK TO start_coa_calc;
       fnd_message.set_name('IGF','IGF_AW_INCON_ITM_TERMS');
       fnd_file.put_line(fnd_file.log,RPAD(' ',10,' ') || fnd_message.get());

       fnd_message.set_name('IGF','IGF_SL_SKIPPING');
       fnd_file.put_line(fnd_file.log,RPAD(' ',10,' ') || fnd_message.get());

       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_coa_calc.process_student.exception','sql error message: '||SQLERRM);
       END IF;

    WHEN E_SKIP_STD_NO_ITEMS  THEN
       ROLLBACK TO start_coa_calc;
       fnd_message.set_name('IGF','IGF_AW_STD_SKIP_ASSGN');
       fnd_file.put_line(fnd_file.log,RPAD(' ',10,' ') || fnd_message.get());

       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_coa_calc.process_student.exception','sql error message: '||SQLERRM);
       END IF;

    WHEN E_SKIP_STD_NO_TERMS THEN
        ROLLBACK TO start_coa_calc;
        fnd_message.set_name('IGF','IGF_AW_COA_SKIP_STD');
        fnd_file.put_line(fnd_file.log,RPAD(' ',10,' ') || fnd_message.get());

        fnd_message.set_name('IGF','IGF_AW_RATE_NOT_AVAIL');
        fnd_file.put_line(fnd_file.log,RPAD(' ',10,' ') || fnd_message.get());

        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_coa_calc.process_student.exception','sql error message: '||SQLERRM);
        END IF;

    WHEN OTHERS THEN
       ROLLBACK TO start_coa_calc;

       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_coa_calc.process_student.exception','sql error message: '||SQLERRM);
       END IF;

       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGF_AW_COA_CALC.PROCESS_STUDENT' || ' '||SQLERRM);
       fnd_file.put_line(fnd_file.log,RPAD(' ',10,' ') || fnd_message.get());

       fnd_message.set_name('IGF','IGF_AW_RATE_NOT_AVAIL');
       fnd_file.put_line(fnd_file.log,RPAD(' ',10)|| fnd_message.get());

  END process_student;



  --
  -- This procedure is the callable from concurrent manager
  --

  PROCEDURE run(
                errbuf                        OUT NOCOPY VARCHAR2,
                retcode                       OUT NOCOPY NUMBER,
                p_award_year                  IN  VARCHAR2,
                p_grp_code                    IN  igf_aw_coa_grp_item.coa_code%TYPE,
                p_update_coa                  IN  VARCHAR2,
                p_update_method               IN  VARCHAR2,
                l_run_type                    IN  VARCHAR2,
                p_pergrp_id                   IN  igs_pe_prsid_grp_mem_all.group_id%TYPE,
                p_base_id                     IN  igf_ap_fa_base_rec_all.base_id%TYPE
               ) IS
  --------------------------------------------------------------------------------
  -- this procedure is called from concurrent manager.
  -- if the parameters passed are not correct then procedure exits
  -- giving reasons for errors.
  -- Created By : cdcruz
  -- Modified By : gmuralid
  --Change History:
  --Who         When            What
  --ridas       08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
  --tsailaja	  13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
  --veramach    08-Jan-2004     FA CCR 118 COA Updates
  --                            Added 2 new parameters p_update_coa and p_update_method
  --                            Added validations on the 2 new parameters
  --------------------------------------------------------------------------------


    l_ci_cal_type        VARCHAR2(10) ;
    l_ci_sequence_number NUMBER(15) ;

    param_exception EXCEPTION;

    --Cursor below retrieves all the person belonging to a person id group

    -- Variables for the dynamic person id group
    lv_status         VARCHAR2(1)    := 'S';  /*Defaulted to 'S' and the function will return 'F' in case of failure */
    lv_group_type     igs_pe_persid_group_v.group_type%TYPE;
    lv_sql_stmt       VARCHAR(32767);


    TYPE CpregrpCurTyp IS REF CURSOR ;
    cur_per_grp CpregrpCurTyp ;
    TYPE CpergrpTyp IS RECORD(
                              person_id     igf_ap_fa_base_rec_all.person_id%TYPE,
                              person_number igs_pe_person_base_v.person_number%TYPE
                             );
    per_grp_rec CpergrpTyp ;

    l_process_id NUMBER(15);

    --Cursor below retrieves all the students belonging to a given AWARD YEAR

    CURSOR c_per_awd_yr(
                        c_ci_cal_type          igf_ap_fa_base_rec.ci_cal_type%TYPE,
                        c_ci_sequence_number   igf_ap_fa_base_rec.ci_sequence_number%TYPE
                       ) IS
      SELECT fa.base_id
        FROM igf_ap_fa_base_rec_all fa
       WHERE fa.ci_cal_type        =  c_ci_cal_type
         AND fa.ci_sequence_number =  c_ci_sequence_number;
    per_awd_rec   c_per_awd_yr%ROWTYPE;

    CURSOR c_temp_del(
                      c_process_id NUMBER
                     ) IS
      SELECT row_id rid
        FROM igf_aw_award_t
       WHERE process_id = c_process_id;
    temp_del_rec    c_temp_del%ROWTYPE;

    CURSOR c_group_code(
                        c_grp_id igs_pe_prsid_grp_mem_all.group_id%TYPE
                       ) IS
      SELECT group_cd
        FROM igs_pe_persid_group_all
       WHERE group_id = c_grp_id;
    c_grp_cd    c_group_code%ROWTYPE;

    ln_base_id  igf_ap_fa_base_rec_all.base_id%TYPE;
    lv_err_msg  fnd_new_messages.message_name%TYPE;

  BEGIN
	igf_aw_gen.set_org_id(NULL);
    retcode              := 0;
    errbuf               := NULL;
    g_b_header           := TRUE;
    l_ci_cal_type        := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
    l_ci_sequence_number := TO_NUMBER(SUBSTR(p_award_year,11));

    g_cal_type           := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
    g_sequence_number    := TO_NUMBER(SUBSTR(p_award_year,11));
    g_update_coa         := p_update_coa;
    g_update_method      := p_update_method;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.run.debug','p_award_year:'||p_award_year);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.run.debug','p_grp_code:'||p_grp_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.run.debug','l_run_type:'||l_run_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.run.debug','p_pergrp_id:'||p_pergrp_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.run.debug','p_base_id:'||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.run.debug','p_update_coa:'||p_update_coa);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.run.debug','p_update_method:'||p_update_method);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.run.debug','l_ci_cal_type:'||l_ci_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_calc.run.debug','l_ci_sequence_number:'||l_ci_sequence_number);
    END IF;

    fnd_file.new_line(fnd_file.log,1);

    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PARAMETER_PASS'));
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWARD_YEAR'),60) || igf_gr_gen.get_alt_code(l_ci_cal_type,l_ci_sequence_number));
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_AP_RULE','GROUP_CODE'),60) || p_grp_code);
    OPEN  c_group_code(p_pergrp_id);
    FETCH c_group_code INTO c_grp_cd;
    CLOSE c_group_code;
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'),60) || c_grp_cd.group_cd);
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER'),60) || igf_gr_gen.get_per_num(p_base_id));
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','UPDATE_COA'),60) || p_update_coa);
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','UPDATE_METHOD'),60) || igf_aw_gen.lookup_desc('IGF_AW_COA_UPD_MTHD',p_update_method));

    fnd_file.new_line(fnd_file.log,2);
    fnd_message.set_name('IGF','IGF_AW_PROCESS_COA_CAL');
    fnd_file.put_line(fnd_file.log,RPAD(fnd_message.get,60) || igf_gr_gen.get_alt_code(l_ci_cal_type,l_ci_sequence_number));

    fnd_file.new_line(fnd_file.log,1);

    IF p_award_year IS NULL OR p_grp_code IS NULL THEN
      RAISE param_exception;

    ELSIF l_ci_cal_type IS NULL OR l_ci_sequence_number IS NULL THEN
      RAISE param_exception;

    ELSIF (p_pergrp_id IS NOT NULL) AND (p_base_id IS NOT NULL) THEN
      RAISE param_exception;

    ELSIF l_run_type = 'P' AND p_pergrp_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_AW_COA_PARAM_EX_P');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE param_exception;

    ELSIF l_run_type = 'S' AND p_base_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_AW_COA_PARAM_EX_S');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE param_exception;

    ELSIF p_update_coa = 'Y' AND p_update_method IS NULL THEN
      fnd_message.set_name('IGF','IGF_AW_COA_PARAM_UPD');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE param_exception;

    ELSIF l_run_type = 'P' AND (p_pergrp_id IS NOT NULL) THEN
          --Bug #5021084
          lv_sql_stmt   := igf_ap_ss_pkg.get_pid(p_pergrp_id,lv_status,lv_group_type);

          --Bug #5021084. Passing Group ID if the group type is STATIC.
          IF lv_group_type = 'STATIC' THEN
            OPEN cur_per_grp FOR
            'SELECT party_id      person_id,
                    party_number  person_number
               FROM hz_parties
              WHERE party_id IN ('||lv_sql_stmt||') 'USING p_pergrp_id;
          ELSIF lv_group_type = 'DYNAMIC' THEN
            OPEN cur_per_grp FOR
            'SELECT party_id      person_id,
                    party_number  person_number
               FROM hz_parties
              WHERE party_id IN ('||lv_sql_stmt||')';
          END IF;

          FETCH cur_per_grp INTO per_grp_rec;

          IF (cur_per_grp%NOTFOUND) THEN
            fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
          ELSE
            SELECT igf_aw_process_s.nextval INTO l_process_id FROM dual ;
            populate_setup_table(p_grp_code,l_ci_cal_type,l_ci_sequence_number,l_process_id);

            OPEN c_group_code(p_pergrp_id);
            FETCH c_group_code INTO c_grp_cd;

            fnd_message.set_name('IGF','IGF_AW_PERSON_ID_GROUP');
            fnd_message.set_token('P_PER_GRP',c_grp_cd.group_cd);
            fnd_file.put_line(fnd_file.log,fnd_message.get );
            fnd_file.new_line(fnd_file.log,1);

            CLOSE c_group_code;

            LOOP
              --
              -- check if person has a fa base record
              --
              ln_base_id := NULL;
              lv_err_msg := NULL;

              igf_gr_gen.get_base_id(
                                     l_ci_cal_type,
                                     l_ci_sequence_number,
                                     per_grp_rec.person_id,
                                     ln_base_id,
                                     lv_err_msg
                                    );

              IF lv_err_msg = 'NULL' THEN
                process_student(
                                ln_base_id,
                                p_grp_code,
                                l_process_id
                               );
              ELSE
                fnd_message.set_name('IGF','IGF_AW_NO_FA_BASE_EXISTS');
                fnd_message.set_token('PERS_NUM',per_grp_rec.person_number);
                fnd_message.set_token('AWD_YR',igf_gr_gen.get_alt_code(l_ci_cal_type,l_ci_sequence_number));
                fnd_file.put_line(fnd_file.log,RPAD(' ',5) || fnd_message.get);
                fnd_file.new_line(fnd_file.log,1);
              END IF;

              FETCH cur_per_grp INTO per_grp_rec;
              EXIT WHEN cur_per_grp%NOTFOUND;
            END LOOP;
            CLOSE cur_per_grp;
          END IF;

      --COMPUTATION ONLY IF PERSON NUMBER IS PRESENT

    ELSIF l_run_type = 'S' AND (p_pergrp_id is NULL) AND (p_base_id IS NOT NULL) THEN
      SELECT igf_aw_process_s.nextval INTO l_process_id FROM dual ;
      populate_setup_table(
                           p_grp_code,
                           l_ci_cal_type,
                           l_ci_sequence_number,
                           l_process_id
                          );
      process_student(
                      p_base_id,
                      p_grp_code,
                      l_process_id
                     );

    --COMPUTATION FOR AWARD YEAR ONLY
    ELSIF l_run_type = 'Y' AND (p_pergrp_id IS NULL) AND (p_base_id is NULL) THEN
      OPEN  c_per_awd_yr(l_ci_cal_type,l_ci_sequence_number);
      FETCH c_per_awd_yr INTO per_awd_rec;

      IF (c_per_awd_yr%NOTFOUND) THEN
        fnd_message.set_name('IGF','IGF_AW_COA_NO_STDS');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_file.new_line(fnd_file.log,1);
      ELSE
        SELECT igf_aw_process_s.nextval INTO l_process_id FROM dual ;
        populate_setup_table(
                             p_grp_code,
                             l_ci_cal_type,
                             l_ci_sequence_number,
                             l_process_id
                            );

        fnd_message.set_name('IGF','IGF_AW_PROC_AWD');
        fnd_message.set_token('AWD_YR',p_award_year);
        fnd_file.put_line(fnd_file.log,fnd_message.get );
        fnd_file.new_line(fnd_file.log,1);

        LOOP
          IF per_awd_rec.base_id IS NOT NULL THEN
            process_student(
                            per_awd_rec.base_id,
                            p_grp_code,
                            l_process_id
                           );
          END IF;
          FETCH c_per_awd_yr INTO per_awd_rec;
          EXIT WHEN c_per_awd_yr%NOTFOUND;
        END LOOP;

        CLOSE c_per_awd_yr;
        END IF;
      END IF;

    FOR temp_del_rec IN c_temp_del(l_process_id) LOOP
      igf_aw_award_t_pkg.delete_row(temp_del_rec.rid);
    END LOOP;

    COMMIT;

    EXCEPTION
      WHEN param_exception THEN
        retcode:=2;
        fnd_message.set_name('IGF','IGF_AW_PARAM_ERR');
        igs_ge_msg_stack.add;
        errbuf := fnd_message.get;

      WHEN app_exception.record_lock_exception THEN
        ROLLBACK;
        retcode:=2;
        fnd_message.set_name('IGF','IGF_GE_LOCK_ERROR');
        igs_ge_msg_stack.add;
        errbuf := fnd_message.get;

      WHEN OTHERS THEN
        ROLLBACK;
        retcode:=2;
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
        igs_ge_msg_stack.add;
        errbuf := fnd_message.get ||  ' '|| SQLERRM;
  END run;

END igf_aw_coa_calc;

/
