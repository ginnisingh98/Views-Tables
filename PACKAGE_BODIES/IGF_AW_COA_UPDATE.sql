--------------------------------------------------------
--  DDL for Package Body IGF_AW_COA_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_COA_UPDATE" AS
/* $Header: IGFAW16B.pls 120.6 2006/02/08 23:40:48 ridas noship $ */

------------------------------------------------------------------------------
-- Who        When          What
--------------------------------------------------------------------------------

  -- Procedure to update TO DO Items where p_run_type IN ('S','Y','P')
  PROCEDURE update_to_do_items (p_base_id             IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                                p_ci_cal_type         IN igs_ca_inst.cal_type%TYPE,
                                p_ci_sequence_number  IN igs_ca_inst.sequence_number%TYPE
                               )
                               IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 27-DEC-2004

  -- Change History:
  -- Who         When            What
  -- ridas       27-DEC-2004     Bug #4087686
  --------------------------------------------------------------------------------

    --Cursor to fetch persons from todo ref table
    CURSOR  c_person_ref(
                        c_ci_cal_type          igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                        c_ci_sequence_number   igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                        c_person_id            igs_pe_std_todo_ref.person_id%TYPE,
                        c_s_student_todo_type  igs_pe_std_todo_ref.s_student_todo_type%TYPE,
                        c_sequence_number      igs_pe_std_todo_ref.sequence_number%TYPE
                       ) IS
      SELECT tref.rowid row_id,
             tref.*
        FROM igs_pe_std_todo_ref  tref
       WHERE tref.person_id           = c_person_id
         AND tref.s_student_todo_type = c_s_student_todo_type
         AND tref.sequence_number     = c_sequence_number
         AND tref.cal_type            = c_ci_cal_type
         AND tref.ci_sequence_number  = c_ci_sequence_number
         AND tref.s_student_todo_type = 'IGF_COA_COMP'
         AND tref.logical_delete_dt IS NULL;


    --Cursor to fetch persons from todo table
    CURSOR  c_person_todo(
                        c_person_id            igs_pe_std_todo.person_id%TYPE,
                        c_s_student_todo_type  igs_pe_std_todo.s_student_todo_type%TYPE,
                        c_sequence_number      igs_pe_std_todo.sequence_number%TYPE
                         ) IS
      SELECT todo.rowid row_id,
             todo.*
        FROM igs_pe_std_todo  todo
       WHERE todo.person_id           = c_person_id
         AND todo.s_student_todo_type = c_s_student_todo_type
         AND todo.sequence_number     = c_sequence_number
         AND todo.logical_delete_dt IS NULL
         AND NOT EXISTS
                   (SELECT          tref.person_id,
                                    tref.s_student_todo_type,
                                    tref.sequence_number
                      FROM igs_pe_std_todo_ref  tref
                     WHERE tref.person_id           = todo.person_id
                       AND tref.s_student_todo_type = todo.s_student_todo_type
                       AND tref.sequence_number     = todo.sequence_number
                       AND tref.s_student_todo_type = 'IGF_COA_COMP'
                       AND tref.logical_delete_dt IS NULL
                       GROUP BY tref.person_id, tref.s_student_todo_type, tref.sequence_number
                    );

    l_person_todo   c_person_todo%ROWTYPE;

    --Cursor to fetch the person who have a "COA Re-computation" as a "Person To Do"
    CURSOR  cur_person_dtls(
			                  c_person_id	           igf_ap_fa_base_rec_all.person_id%TYPE,
                        c_ci_cal_type          igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                        c_ci_sequence_number   igf_ap_fa_base_rec_all.ci_sequence_number%TYPE
                       ) IS
      SELECT distinct todo.person_id,
                      todo.s_student_todo_type,
                      todo.sequence_number
        FROM igs_pe_std_todo      todo,
             igs_pe_std_todo_ref  tref
       WHERE todo.person_id	          = c_person_id
	       AND tref.person_id           = todo.person_id
         AND tref.s_student_todo_type = todo.s_student_todo_type
         AND tref.sequence_number     = todo.sequence_number
         AND tref.cal_type            = c_ci_cal_type
         AND tref.ci_sequence_number  = c_ci_sequence_number
         AND todo.s_student_todo_type = 'IGF_COA_COMP'
         AND todo.logical_delete_dt IS NULL
         AND tref.logical_delete_dt IS NULL;

    l_person_dtls           cur_person_dtls%ROWTYPE;


    --Cursor to fetch person id
    CURSOR cur_get_person_id(
			                  c_base_id	             igf_ap_fa_base_rec_all.base_id%TYPE,
                        c_ci_cal_type          igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                        c_ci_sequence_number   igf_ap_fa_base_rec_all.ci_sequence_number%TYPE
                       ) IS
      SELECT person_id
        FROM igf_ap_fa_base_rec_all
       WHERE base_id            = c_base_id
         AND ci_cal_type        = c_ci_cal_type
         AND ci_sequence_number = c_ci_sequence_number;

    l_get_person_id        cur_get_person_id%ROWTYPE;

  BEGIN
     --Get the person id from the base id
     OPEN  cur_get_person_id(p_base_id,p_ci_cal_type,p_ci_sequence_number);
     FETCH cur_get_person_id INTO l_get_person_id;
     CLOSE cur_get_person_id;

     IF l_get_person_id.person_id IS NOT NULL THEN
       OPEN  cur_person_dtls(l_get_person_id.person_id,p_ci_cal_type,p_ci_sequence_number);
       FETCH cur_person_dtls INTO l_person_dtls;
       CLOSE cur_person_dtls;

       --If To Do
       IF l_person_dtls.person_id IS NOT NULL THEN
          FOR l_person_ref IN c_person_ref(p_ci_cal_type,p_ci_sequence_number,l_person_dtls.person_id,l_person_dtls.s_student_todo_type,l_person_dtls.sequence_number)
          LOOP
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.update_to_do_items.debug','Updating table igs_pe_std_todo for person id: '||l_person_dtls.person_id);
              END IF;

              igs_pe_std_todo_ref_pkg.update_row(
                                              x_rowid		              => l_person_ref.row_id,
                                              x_person_id		          => l_person_ref.person_id,
                                              x_s_student_todo_type   => l_person_ref.s_student_todo_type,
                                              x_sequence_number	      => l_person_ref.sequence_number,
                                              x_reference_number	    => l_person_ref.reference_number,
                                              x_cal_type		          => l_person_ref.cal_type,
                                              x_ci_sequence_number	  => l_person_ref.ci_sequence_number,
                                              x_course_cd		          => l_person_ref.course_cd,
                                              x_unit_cd		            => l_person_ref.unit_cd,
                                              x_other_reference	      => l_person_ref.other_reference,
                                              x_logical_delete_dt	    => sysdate,
                                              x_mode 		              => 'R',
                                              x_uoo_id		            => l_person_ref.uoo_id
                                              );
          END LOOP;

          OPEN  c_person_todo(l_person_dtls.person_id,l_person_dtls.s_student_todo_type,l_person_dtls.sequence_number);
          FETCH c_person_todo INTO l_person_todo;

          IF c_person_todo%FOUND THEN

             IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.update_to_do_items.debug','c_person_todo%FOUND');
             END IF;

             igs_pe_std_todo_pkg.update_row(
                            x_rowid		            => l_person_todo.row_id,
                            x_person_id		        => l_person_todo.person_id,
                            x_s_student_todo_type => l_person_todo.s_student_todo_type,
                            x_sequence_number	    => l_person_todo.sequence_number,
                            x_todo_dt		          => l_person_todo.todo_dt,
                            x_logical_delete_dt	  => sysdate,
                            x_mode 		            => 'R'
                            );
          END IF;
          CLOSE c_person_todo;

       END IF;
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_aw_coa_update.update_to_do_items :' || SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_coa_update.update_to_do_items.exception','sql error:'||SQLERRM);
      END IF;
      igs_ge_msg_stack.conc_exception_hndl;
      app_exception.raise_exception;

  END update_to_do_items;




  -- This function check whether the student attributes are matching with the COA Rate Order or not
  -- If matching it returns the new calculated amount
  FUNCTION is_attrib_matching(
                              p_base_id               IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_base_details          IN igf_aw_coa_gen.base_details,
                              p_ci_cal_type           IN igs_ca_inst.cal_type%TYPE,
                              p_ci_sequence_number    IN igs_ca_inst.sequence_number%TYPE,
                              p_ld_cal_type           IN igs_ca_inst.cal_type%TYPE,
                              p_ld_sequence_number    IN igs_ca_inst.sequence_number%TYPE,
                              p_item_code             IN igf_aw_item.item_code%TYPE,
                              p_amount                OUT NOCOPY NUMBER,
                              p_rate_order_num        OUT NOCOPY NUMBER
                              ) RETURN BOOLEAN IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 26-OCT-2004

  -- Change History:
  -- Who         When            What
  -- ridas       08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in
  --                             call to igf_ap_ss_pkg.get_pid
  --------------------------------------------------------------------------------

    -- Variables for the dynamic person id group
    lv_status         VARCHAR2(1);
    lv_sql_stmt       VARCHAR(32767) ;
    lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

    TYPE CperexistCurTyp IS REF CURSOR ;
    c_chk_per_exist CperexistCurTyp ;
    lv_chk_per_exist    NUMBER(1);

    CURSOR c_rate_order (
                         c_ci_cal_type           igs_ca_inst.cal_type%TYPE,
                         c_ci_sequence_number    igs_ca_inst.sequence_number%TYPE,
                         c_item_code             igf_aw_item.item_code%TYPE
                        ) IS
      SELECT rate.*
        FROM igf_aw_coa_rate_det  rate
       WHERE ci_cal_type        = c_ci_cal_type
         AND ci_sequence_number = c_ci_sequence_number
         AND item_code          = c_item_code
       ORDER BY rate_order_num ASC;

    l_rate_order    c_rate_order%ROWTYPE;

    --Cursor to fetch Group ID
    CURSOR c_grp_id (
                     c_grp_code     igs_pe_persid_group_all.group_cd%TYPE
                    ) IS
      SELECT group_id
        FROM igs_pe_persid_group_all
       WHERE group_cd = c_grp_code;

    l_grp_id  c_grp_id%ROWTYPE;

    l_counter       NUMBER;

  BEGIN
    l_counter := 0;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.is_attrib_matching.debug','OPEN c_rate_order');
    END IF;

    OPEN  c_rate_order(p_ci_cal_type,p_ci_sequence_number,p_item_code);
    FETCH c_rate_order INTO l_rate_order;
    IF c_rate_order%NOTFOUND THEN
        CLOSE c_rate_order;
        RETURN FALSE;
    END IF;

    LOOP

      IF ((l_rate_order.org_unit_cd              = p_base_details.org_unit_cd         OR l_rate_order.org_unit_cd  IS NULL)
         AND (l_rate_order.program_type          = p_base_details.program_type        OR l_rate_order.program_type IS NULL)
         AND (l_rate_order.program_location_cd   = p_base_details.program_location_cd OR l_rate_order.program_location_cd IS NULL)
         AND (l_rate_order.program_cd            = p_base_details.program_cd          OR l_rate_order.program_cd IS NULL)
         AND (l_rate_order.class_standing        = p_base_details.class_standing      OR l_rate_order.class_standing IS NULL)
         AND (l_rate_order.residency_status_code = p_base_details.residency_status_code OR l_rate_order.residency_status_code IS NULL)
         AND (l_rate_order.housing_status_code   = p_base_details.housing_status_code   OR l_rate_order.housing_status_code IS NULL)
         AND (l_rate_order.attendance_type       = p_base_details.attendance_type       OR l_rate_order.attendance_type IS NULL)
         AND (l_rate_order.attendance_mode       = p_base_details.attendance_mode       OR l_rate_order.attendance_mode IS NULL)
         AND (NVL(l_rate_order.ld_cal_type,p_ld_cal_type)                              = p_ld_cal_type)
         AND (NVL(l_rate_order.ld_sequence_number,p_ld_sequence_number)                = p_ld_sequence_number)
         )
      THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.is_attrib_matching.debug','inside if condition');
        END IF;

        IF l_rate_order.pid_group_cd IS NOT NULL THEN
          OPEN c_grp_id(l_rate_order.pid_group_cd);
          FETCH c_grp_id INTO l_grp_id;
          CLOSE c_grp_id;

          IF l_grp_id.group_id IS NOT NULL THEN
              -- To check whether the person exist in the group or not
              -- Bug #5021084
              lv_sql_stmt := igf_ap_ss_pkg.get_pid(l_grp_id.group_id,lv_status,lv_group_type);

              --Bug #5021084. Passing Group ID if the group type is STATIC.
              IF lv_group_type = 'STATIC' THEN
                OPEN  c_chk_per_exist FOR 'SELECT 1
                                               FROM igf_ap_fa_base_rec fabase
                                              WHERE fabase.base_id   = :base_id
                                                AND fabase.person_id in ( '||lv_sql_stmt||') ' USING  p_base_id,l_grp_id.group_id;
              ELSIF lv_group_type = 'DYNAMIC' THEN
                OPEN  c_chk_per_exist FOR 'SELECT 1
                                               FROM igf_ap_fa_base_rec fabase
                                              WHERE fabase.base_id   = :base_id
                                                AND fabase.person_id in ( '||lv_sql_stmt||') ' USING  p_base_id;
              END IF;

              FETCH c_chk_per_exist INTO lv_chk_per_exist;

              IF c_chk_per_exist%NOTFOUND THEN
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.is_attrib_matching.debug','c_chk_per_exist%NOTFOUND');
                  END IF;

              ELSE
                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.is_attrib_matching.debug','person found in the person group id');
                  END IF;

                  l_counter := 1;
                  CLOSE c_chk_per_exist;
                  EXIT;
              END IF;
              CLOSE c_chk_per_exist;
          ELSE
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.is_attrib_matching.debug','l_grp_id.group_id IS NULL');
              END IF;
          END IF;

        ELSE
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.is_attrib_matching.debug','l_rate_order.pid_group_cd IS NULL');
          END IF;

          l_counter := 1;
          EXIT;
        END IF;

      ELSE

        IF l_rate_order.org_unit_cd IS NOT NULL AND p_base_details.org_unit_cd IS NULL THEN
            fnd_message.set_name('IGF','IGF_AW_STD_ATTRIB');
            fnd_message.set_token('ATTRIBUTE',igf_aw_gen.lookup_desc('IGF_AW_COA_GEN','ORG_UNIT_CD'));
            fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_ld_cal_type, p_ld_sequence_number));
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

            l_counter := 2;
        END IF;

        IF l_rate_order.program_type IS NOT NULL AND p_base_details.program_type IS NULL THEN
            fnd_message.set_name('IGF','IGF_AW_STD_ATTRIB');
            fnd_message.set_token('ATTRIBUTE',igf_aw_gen.lookup_desc('IGF_AW_COA_GEN','PROGRAM_TYPE'));
            fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_ld_cal_type, p_ld_sequence_number));
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

            l_counter := 2;
        END IF;

        IF l_rate_order.program_location_cd IS NOT NULL AND p_base_details.program_location_cd IS NULL THEN
            fnd_message.set_name('IGF','IGF_AW_STD_ATTRIB');
            fnd_message.set_token('ATTRIBUTE',igf_aw_gen.lookup_desc('IGF_AW_COA_GEN','PROGRAM_LOCATION_CD'));
            fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_ld_cal_type, p_ld_sequence_number));
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

            l_counter := 2;
        END IF;

        IF l_rate_order.program_cd IS NOT NULL AND p_base_details.program_cd IS NULL THEN
            fnd_message.set_name('IGF','IGF_AW_STD_ATTRIB');
            fnd_message.set_token('ATTRIBUTE',igf_aw_gen.lookup_desc('IGF_AW_COA_GEN','PROGRAM_CD'));
            fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_ld_cal_type, p_ld_sequence_number));
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

            l_counter := 2;
        END IF;

        IF l_rate_order.class_standing IS NOT NULL AND p_base_details.class_standing IS NULL THEN
            fnd_message.set_name('IGF','IGF_AW_STD_ATTRIB');
            fnd_message.set_token('ATTRIBUTE',igf_aw_gen.lookup_desc('IGF_AW_COA_GEN','CLASS_STANDING'));
            fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_ld_cal_type, p_ld_sequence_number));
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

            l_counter := 2;
        END IF;

        IF l_rate_order.residency_status_code IS NOT NULL AND p_base_details.residency_status_code IS NULL THEN
            fnd_message.set_name('IGF','IGF_AW_STD_ATTRIB');
            fnd_message.set_token('ATTRIBUTE',igf_aw_gen.lookup_desc('IGF_AW_COA_GEN','RESIDENCY_STATUS_CODE'));
            fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_ld_cal_type, p_ld_sequence_number));
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

            l_counter := 2;
        END IF;

        IF l_rate_order.housing_status_code IS NOT NULL AND p_base_details.housing_status_code IS NULL THEN
            fnd_message.set_name('IGF','IGF_AW_STD_ATTRIB');
            fnd_message.set_token('ATTRIBUTE',igf_aw_gen.lookup_desc('IGF_AW_COA_GEN','HOUSING_STATUS_CODE'));
            fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_ld_cal_type, p_ld_sequence_number));
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

            l_counter := 2;
        END IF;

        IF l_rate_order.attendance_type IS NOT NULL AND p_base_details.attendance_type IS NULL THEN
            fnd_message.set_name('IGF','IGF_AW_STD_ATTRIB');
            fnd_message.set_token('ATTRIBUTE',igf_aw_gen.lookup_desc('IGF_AW_COA_GEN','ATTENDANCE_TYPE'));
            fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_ld_cal_type, p_ld_sequence_number));
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

            l_counter := 2;
        END IF;

        IF l_rate_order.attendance_mode IS NOT NULL AND p_base_details.attendance_mode IS NULL THEN
            fnd_message.set_name('IGF','IGF_AW_STD_ATTRIB');
            fnd_message.set_token('ATTRIBUTE',igf_aw_gen.lookup_desc('IGF_AW_COA_GEN','ATTENDANCE_MODE'));
            fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(p_ld_cal_type, p_ld_sequence_number));
            fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

            l_counter := 2;
        END IF;

        IF l_counter = 2 THEN
            EXIT;
        END IF;
      END IF;

      FETCH c_rate_order INTO l_rate_order;
      EXIT WHEN c_rate_order%NOTFOUND;
    END LOOP;
    CLOSE c_rate_order;

    IF l_counter = 1 THEN
      IF l_rate_order.mult_factor_code = 'ME' THEN
          p_amount  :=  NVL(p_base_details.months_enrolled_num,0)*NVL(l_rate_order.mult_amount_num,0);
      ELSIF l_rate_order.mult_factor_code = 'CP' THEN
          p_amount  :=  NVL(p_base_details.credit_points_num,0)*NVL(l_rate_order.mult_amount_num,0);
      ELSIF l_rate_order.mult_factor_code = 'FA' THEN
          p_amount  :=  NVL(l_rate_order.mult_amount_num,0);
      END IF;

      p_rate_order_num  := l_rate_order.rate_order_num;

      RETURN TRUE;
    ELSE

      IF l_counter = 2 THEN
        p_rate_order_num := -1;
      END IF;
      RETURN FALSE;
    END IF;

  END is_attrib_matching;


 -- This procedure is to evaluate the COA re-computation amount
 PROCEDURE evaluate(
                    p_base_id             IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                    p_ci_cal_type         IN  igs_ca_inst.cal_type%TYPE,
                    p_ci_sequence_number  IN  igs_ca_inst.sequence_number%TYPE
                   ) IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 26-OCT-2004

  -- Change History:
  -- Who         When            What
  --------------------------------------------------------------------------------

   --This cursor is to fetch person details
    CURSOR  c_base_rec (
                          c_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                         ) IS
      SELECT NVL(fab.lock_coa_flag,'N') lock_coa_flag
        FROM igf_ap_fa_base_rec fab
       WHERE fab.base_id = c_base_id;

    l_base_rec         c_base_rec%ROWTYPE;


    --This cursor is to fetch items details for a person
    CURSOR  c_items(
                     c_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                   ) IS
      SELECT items.*
        FROM igf_aw_coa_items   items
       WHERE items.base_id = c_base_id;


    --This cursor is to fetch terms details against an item
    CURSOR c_terms(
                    c_base_id   igf_ap_fa_base_rec_all.base_id%TYPE,
                    c_item_code igf_aw_item.item_code%TYPE
                  ) IS
      SELECT terms.rowid row_id,
             terms.*
        FROM igf_aw_coa_itm_terms terms
       WHERE base_id   = c_base_id
         AND item_code = c_item_code;


    --Cursor to fetch the sum amount of all the terms for the Item code
    CURSOR c_sum_amt(
                   c_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                   c_item_code	        igf_aw_coa_itm_terms.item_code%TYPE
                  ) IS
        SELECT SUM(NVL(amount,0)) amount
          FROM igf_aw_coa_itm_terms   term
         WHERE base_id   = c_base_id
           AND item_code = c_item_code;

      l_sum_amt     c_sum_amt%ROWTYPE;


    --Cursor to fetch item details for the base id
    CURSOR c_item(
                   c_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                   c_item_code          igf_aw_coa_itm_terms.item_code%TYPE
                  ) IS
        SELECT item.rowid   row_id,
               item.*
          FROM igf_aw_coa_items   item
         WHERE base_id    = c_base_id
           AND item_code  = c_item_code;

      l_item     c_item%ROWTYPE;

    CURSOR c_rate_ord_exists (
                               cp_ci_cal_type           igs_ca_inst.cal_type%TYPE,
                               cp_ci_sequence_number    igs_ca_inst.sequence_number%TYPE,
                               cp_item_code             igf_aw_item.item_code%TYPE
                              ) IS
      SELECT 'X' exist
        FROM igf_aw_coa_rate_det  rate
       WHERE ci_cal_type        = cp_ci_cal_type
         AND ci_sequence_number = cp_ci_sequence_number
         AND item_code          = cp_item_code
         AND ROWNUM = 1;

    l_rate_ord_exists         c_rate_ord_exists%ROWTYPE;

    l_base_details        igf_aw_coa_gen.base_details;
    ln_amount             NUMBER;
    ln_rate_order         NUMBER;
    lv_coa_itm_update     VARCHAR2(1);
    lv_award_proc_status  igf_aw_award_all.awd_proc_status_code%TYPE;
    E_SKIP_STUDENT        EXCEPTION;

  BEGIN
    lv_coa_itm_update :=  'N';

    SAVEPOINT start_evaluate;

    OPEN  c_base_rec(p_base_id);
    FETCH c_base_rec INTO l_base_rec;
    CLOSE c_base_rec;

    IF l_base_rec.lock_coa_flag = 'Y' THEN

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.evaluate.debug','base_id:'||p_base_id||' is locked');
        END IF;

        fnd_message.set_name('IGF','IGF_AW_STUD_SKIP');
        fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
    ELSE
        FOR l_items IN c_items(p_base_id)
        LOOP
            IF l_items.lock_flag = 'Y' THEN

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.evaluate.debug','l_items.item_code:'||l_items.item_code||' is locked');
                END IF;

                fnd_message.set_name('IGF','IGF_AW_SKP_LK_ITM');
                fnd_message.set_token('ITEM_CODE',l_items.item_code);
                fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

            ELSE
                --cursor to check whether the COA item exists in the rate based setup table or not
                OPEN c_rate_ord_exists(p_ci_cal_type, p_ci_sequence_number, l_items.item_code);
                FETCH c_rate_ord_exists INTO l_rate_ord_exists;
                IF c_rate_ord_exists%NOTFOUND THEN
                  CLOSE c_rate_ord_exists;

                  fnd_message.set_name('IGF','IGF_AW_SKIP_NON_RATE');
                  fnd_message.set_token('ITEM',l_items.item_code);
                  fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

                ELSIF c_rate_ord_exists%FOUND THEN
                  CLOSE c_rate_ord_exists;

                  FOR l_terms IN c_terms(p_base_id, l_items.item_code)
                  LOOP
                    IF l_terms.lock_flag = 'Y' THEN

                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.evaluate.debug','term:'||igf_gr_gen.get_alt_code(l_terms.ld_cal_type,l_terms.ld_sequence_number)||' is locked');
                        END IF;

                        fnd_message.set_name('IGF','IGF_AW_SKP_LK_TRM');
                        fnd_message.set_token('TERM_CODE',igf_gr_gen.get_alt_code(l_terms.ld_cal_type,l_terms.ld_sequence_number));
                        fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
                    ELSE
                        --Execute the COA re-calculation logic
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.evaluate.debug','Fetching student attributes for base_id:'||p_base_id);
                        END IF;

                        l_base_details := igf_aw_coa_gen.getBaseDetails(p_base_id,l_terms.ld_cal_type,l_terms.ld_sequence_number);

                        --Rate Order found against the student attributes
                        IF is_attrib_matching(p_base_id,
                                              l_base_details,
                                              p_ci_cal_type,
                                              p_ci_sequence_number,
                                              l_terms.ld_cal_type,
                                              l_terms.ld_sequence_number,
                                              l_items.item_code,
                                              ln_amount,
                                              ln_rate_order
                                              ) THEN

                            IF ln_amount <> l_terms.amount THEN
                                fnd_message.set_name('IGF','IGF_AW_UPD_ITM');
                                fnd_message.set_token('ITEM_CODE',l_items.item_code);
                                fnd_message.set_token('TERM_CODE',igf_gr_gen.get_alt_code(l_terms.ld_cal_type,l_terms.ld_sequence_number));
                                fnd_message.set_token('RATE_ORDER',ln_rate_order);
                                fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);

                                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.evaluate.debug','ln_amount <> l_terms.amount for base_id:'||p_base_id);
                                END IF;

                                igf_aw_coa_itm_terms_pkg.update_row(
                                                                    x_rowid              => l_terms.row_id,
                                                                    x_base_id            => l_terms.base_id,
                                                                    x_item_code          => l_terms.item_code,
                                                                    x_amount             => ln_amount,
                                                                    x_ld_cal_type        => l_terms.ld_cal_type,
                                                                    x_ld_sequence_number => l_terms.ld_sequence_number,
                                                                    x_mode               => 'R',
                                                                    x_lock_flag           => l_terms.lock_flag
                                                                    );
                                lv_coa_itm_update := 'Y';
                            END IF;
                        ELSE
                            IF NVL(ln_rate_order,0) <> -1 THEN
                                fnd_message.set_name('IGF','IGF_AW_ITEM_SKIP');
                                fnd_message.set_token('ITEM_CODE',l_items.item_code);
                                fnd_message.set_token('TERM_CODE',igf_gr_gen.get_alt_code(l_terms.ld_cal_type,l_terms.ld_sequence_number));
                                fnd_file.put_line(fnd_file.log,RPAD(' ',5)||fnd_message.get);
                            END IF;

                            RAISE E_SKIP_STUDENT;
                        END IF; -- End of IF is_attrib_matching()
                    END IF;
                  END LOOP;
                END IF; -- End of IF c_rate_ord_exists%NOTFOUND THEN

                OPEN c_sum_amt(p_base_id,l_items.item_code);
                FETCH c_sum_amt INTO l_sum_amt;
                CLOSE c_sum_amt;

                IF l_sum_amt.amount IS NOT NULL THEN
                  OPEN c_item(p_base_id,l_items.item_code);
                  FETCH c_item INTO l_item;
                  CLOSE c_item;

                igf_aw_coa_items_pkg.update_row(
                                          x_rowid               => l_item.row_id,
                                          x_base_id             => l_item.base_id,
                                          x_item_code           => l_item.item_code,
                                          x_amount              => l_sum_amt.amount,
                                          x_pell_coa_amount     => l_item.pell_coa_amount,
                                          x_alt_pell_amount     => l_item.alt_pell_amount,
                                          x_fixed_cost          => l_item.fixed_cost,
                                          x_legacy_record_flag  => l_item.legacy_record_flag,
                                          x_mode                => 'R',
                                          x_lock_flag           => l_item.lock_flag
                                         );

                END IF;
            END IF;
        END LOOP;
    END IF;

    IF lv_coa_itm_update = 'Y' THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.evaluate.debug','lv_coa_itm_update = Y');
        END IF;

        lv_award_proc_status := igf_aw_coa_gen.set_awd_proc_status(p_base_id);
    END IF;

  EXCEPTION
    WHEN E_SKIP_STUDENT  THEN
       ROLLBACK TO start_evaluate;
       fnd_message.set_name('IGF','IGF_AW_RATE_NOT_AVAIL');
       fnd_file.put_line(fnd_file.log,RPAD(' ',5)|| fnd_message.get());

       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_coa_update.evaluate.exception','sql error message:'||SQLERRM);
       END IF;

    WHEN OTHERS THEN
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','igf_aw_coa_update.evaluate :' || SQLERRM);
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_coa_update.evaluate.exception','sql error:'||SQLERRM);
      END IF;
      igs_ge_msg_stack.conc_exception_hndl;
      app_exception.raise_exception;

  END evaluate;


 -- This procedure is the callable from concurrent manager
 PROCEDURE main(
                errbuf                        OUT NOCOPY VARCHAR2,
                retcode                       OUT NOCOPY NUMBER,
                p_award_year                  IN  VARCHAR2,
                p_run_type                    IN  VARCHAR2,
                p_pid_group                   IN  igs_pe_prsid_grp_mem_all.group_id%TYPE,
                p_base_id                     IN  igf_ap_fa_base_rec_all.base_id%TYPE
               ) IS
  --------------------------------------------------------------------------------
  -- this procedure is called from concurrent manager.
  -- if the parameters passed are not correct then procedure exits
  -- giving reasons for errors.
  -- Created by  : ridas, Oracle India
  -- Date created: 26-OCT-2004

  -- Change History:
  -- Who				 When            What
  -- ridas       08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in
  --                             call to igf_ap_ss_pkg.get_pid
  -- tsailaja		 13/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
  --------------------------------------------------------------------------------

    param_exception  EXCEPTION;

    -- Variables for the dynamic person id group
    lv_status        VARCHAR2(1);
    lv_sql_stmt      VARCHAR(32767);
    lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

    TYPE CpregrpCurTyp IS REF CURSOR ;
    cur_per_grp CpregrpCurTyp ;

    TYPE CpergrpTyp IS RECORD(
                              person_id     igf_ap_fa_base_rec_all.person_id%TYPE,
                              person_number igs_pe_person_base_v.person_number%TYPE
                             );
    per_grp_rec CpergrpTyp ;


    --Cursor below retrieves all the students belonging to a given AWARD YEAR
    CURSOR c_per_awd_yr(
                        c_ci_cal_type          igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                        c_ci_sequence_number   igf_ap_fa_base_rec_all.ci_sequence_number%TYPE
                       ) IS
      SELECT fa.base_id
        FROM igf_ap_fa_base_rec_all fa
       WHERE fa.ci_cal_type        =  c_ci_cal_type
         AND fa.ci_sequence_number =  c_ci_sequence_number
       ORDER BY fa.base_id;

    l_per_awd_rec   c_per_awd_yr%ROWTYPE;


    --Cursor below retrieves the group code for the given group id
    CURSOR c_group_code(
                        c_grp_id igs_pe_prsid_grp_mem_all.group_id%TYPE
                       ) IS
      SELECT group_cd
        FROM igs_pe_persid_group_all
       WHERE group_id = c_grp_id;

    l_grp_cd    c_group_code%ROWTYPE;


    --Cursor to fetch person no based on person id
    CURSOR  c_person_no (
                          c_person_id  hz_parties.party_id%TYPE
                        ) IS
      SELECT party_number
        FROM hz_parties
       WHERE party_id = c_person_id;

    l_person_no  c_person_no%ROWTYPE;


    --Cursor to fetch all persons who have a "COA Re-computation" as a "Person To Do"
    CURSOR  cur_person_id(
                        c_ci_cal_type          igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                        c_ci_sequence_number   igf_ap_fa_base_rec_all.ci_sequence_number%TYPE
                       ) IS
      SELECT distinct todo.person_id,
                      todo.s_student_todo_type,
                      todo.sequence_number
        FROM igs_pe_std_todo      todo,
             igs_pe_std_todo_ref  tref
       WHERE tref.person_id           = todo.person_id
         AND tref.s_student_todo_type = todo.s_student_todo_type
         AND tref.sequence_number     = todo.sequence_number
         AND tref.cal_type            = c_ci_cal_type
         AND tref.ci_sequence_number  = c_ci_sequence_number
         AND todo.s_student_todo_type = 'IGF_COA_COMP'
         AND todo.logical_delete_dt IS NULL
         AND tref.logical_delete_dt IS NULL;


    --Cursor to fetch persons from todo ref table
    CURSOR  c_person_ref(
                        c_ci_cal_type          igf_ap_fa_base_rec_all.ci_cal_type%TYPE,
                        c_ci_sequence_number   igf_ap_fa_base_rec_all.ci_sequence_number%TYPE,
                        c_person_id            igs_pe_std_todo_ref.person_id%TYPE,
                        c_s_student_todo_type  igs_pe_std_todo_ref.s_student_todo_type%TYPE,
                        c_sequence_number      igs_pe_std_todo_ref.sequence_number%TYPE
                       ) IS
      SELECT tref.rowid row_id,
             tref.*
        FROM igs_pe_std_todo_ref  tref
       WHERE tref.person_id           = c_person_id
         AND tref.s_student_todo_type = c_s_student_todo_type
         AND tref.sequence_number     = c_sequence_number
         AND tref.cal_type            = c_ci_cal_type
         AND tref.ci_sequence_number  = c_ci_sequence_number
         AND tref.s_student_todo_type = 'IGF_COA_COMP'
         AND tref.logical_delete_dt IS NULL;


    --Cursor to fetch persons from todo table
    CURSOR  c_person_todo(
                        c_person_id            igs_pe_std_todo.person_id%TYPE,
                        c_s_student_todo_type  igs_pe_std_todo.s_student_todo_type%TYPE,
                        c_sequence_number      igs_pe_std_todo.sequence_number%TYPE
                         ) IS
      SELECT todo.rowid row_id,
             todo.*
        FROM igs_pe_std_todo  todo
       WHERE todo.person_id           = c_person_id
         AND todo.s_student_todo_type = c_s_student_todo_type
         AND todo.sequence_number     = c_sequence_number
         AND todo.logical_delete_dt IS NULL
         AND NOT EXISTS
                   (SELECT          tref.person_id,
                                    tref.s_student_todo_type,
                                    tref.sequence_number
                      FROM igs_pe_std_todo_ref  tref
                     WHERE tref.person_id           = todo.person_id
                       AND tref.s_student_todo_type = todo.s_student_todo_type
                       AND tref.sequence_number     = todo.sequence_number
                       AND tref.s_student_todo_type = 'IGF_COA_COMP'
                       AND tref.logical_delete_dt IS NULL
                       GROUP BY tref.person_id, tref.s_student_todo_type, tref.sequence_number
                    );

    l_person_todo   c_person_todo%ROWTYPE;

    lv_ci_cal_type         igs_ca_inst_all.cal_type%TYPE;
    ln_ci_sequence_number  igs_ca_inst_all.sequence_number%TYPE;
    ln_base_id             igf_ap_fa_base_rec_all.base_id%TYPE;
    lv_err_msg             fnd_new_messages.message_name%TYPE;
    lv_return_flag         VARCHAR2(1);


  BEGIN
	igf_aw_gen.set_org_id(NULL);
    retcode               := 0;
    errbuf                := NULL;
    lv_ci_cal_type        := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
    ln_ci_sequence_number := TO_NUMBER(SUBSTR(p_award_year,11));
    lv_status             := 'S';  /*Defaulted to 'S' and the function will return 'F' in case of failure */


    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','p_award_year:'||p_award_year);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','p_run_type:'||p_run_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','p_pid_group:'||p_pid_group);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','p_base_id:'||p_base_id);
    END IF;

    fnd_file.new_line(fnd_file.log,1);

    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PARAMETER_PASS'));
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWARD_YEAR'),60) || igf_gr_gen.get_alt_code(lv_ci_cal_type,ln_ci_sequence_number));

    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','RUN_TYPE'),60) ||p_run_type );

    OPEN  c_group_code(p_pid_group);
    FETCH c_group_code INTO l_grp_cd;
    CLOSE c_group_code;

    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'),60) || l_grp_cd.group_cd);
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER'),60) || igf_gr_gen.get_per_num(p_base_id));

    fnd_file.new_line(fnd_file.log,2);

    IF (p_award_year IS NULL) OR (p_run_type IS NULL) THEN
      RAISE param_exception;

    ELSIF lv_ci_cal_type IS NULL OR ln_ci_sequence_number IS NULL THEN
      RAISE param_exception;

    ELSIF (p_pid_group IS NOT NULL) AND (p_base_id IS NOT NULL) THEN
      RAISE param_exception;

    --If person selection is for all persons in the Person ID Group and
    --Person ID Group is NULL then log error with exception
    ELSIF p_run_type = 'P' AND p_pid_group IS NULL THEN
      fnd_message.set_name('IGF','IGF_AW_COA_PARAM_EX_P');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE param_exception;

    --If person selection is for a single person and
    --Base ID is NULL then log error with exception
    ELSIF p_run_type = 'S' AND p_base_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_AW_COA_PARAM_EX_S');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE param_exception;

    END IF;


    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------');

    --COMPUTATION ONLY IF PERSON NUMBER IS PRESENT
    IF p_run_type = 'S' AND (p_pid_group IS NULL) AND (p_base_id IS NOT NULL) THEN

       fnd_file.new_line(fnd_file.log,1);
       fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
       fnd_message.set_token('STDNT',igf_gr_gen.get_per_num(p_base_id));
       fnd_file.put_line(fnd_file.log,fnd_message.get);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','Starting Run_Type=S with base_id:'||p_base_id);
      END IF;

      --Call evaluate procedure for COA re-computation
      evaluate(p_base_id,lv_ci_cal_type,ln_ci_sequence_number);

      --Update To Do Items
      update_to_do_items(p_base_id,lv_ci_cal_type,ln_ci_sequence_number);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','Run_Type=S done');
      END IF;

    --COMPUTATION FOR AWARD YEAR ONLY
    ELSIF p_run_type = 'Y' AND (p_pid_group IS NULL) AND (p_base_id IS NULL) THEN
      FOR l_per_awd_rec IN c_per_awd_yr(lv_ci_cal_type,ln_ci_sequence_number)
      LOOP
       fnd_file.new_line(fnd_file.log,1);
       fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
       fnd_message.set_token('STDNT',igf_gr_gen.get_per_num(l_per_awd_rec.base_id));
       fnd_file.put_line(fnd_file.log,fnd_message.get);

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','Starting Run_Type=Y with base_id:'||l_per_awd_rec.base_id);
       END IF;

       --Call evaluate procedure for COA re-computation
       evaluate(l_per_awd_rec.base_id,lv_ci_cal_type,ln_ci_sequence_number);

       --Update To Do Items
       update_to_do_items(l_per_awd_rec.base_id,lv_ci_cal_type,ln_ci_sequence_number);

      END LOOP;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','Run_Type=Y done');
      END IF;

    --COMPUTATION FOR ALL PERSONS IN THE PERSON ID GROUP
    ELSIF (p_run_type = 'P' AND p_pid_group IS NOT NULL) THEN
          --Bug #5021084
          lv_sql_stmt   := igf_ap_ss_pkg.get_pid(p_pid_group,lv_status,lv_group_type);

          --Bug #5021084. Passing Group ID if the group type is STATIC.
          IF lv_group_type = 'STATIC' THEN
            OPEN cur_per_grp FOR
            'SELECT person_id,
                    person_number
               FROM igs_pe_person_base_v
              WHERE person_id IN ('||lv_sql_stmt||') ' USING p_pid_group;
          ELSIF lv_group_type = 'DYNAMIC' THEN
            OPEN cur_per_grp FOR
            'SELECT person_id,
                    person_number
               FROM igs_pe_person_base_v
              WHERE person_id IN ('||lv_sql_stmt||')';
          END IF;

          FETCH cur_per_grp INTO per_grp_rec;

          IF (cur_per_grp%NOTFOUND) THEN
            fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
          ELSE
            LOOP
              -- check if person has a fa base record
              ln_base_id := NULL;
              lv_err_msg := NULL;

              igf_gr_gen.get_base_id(
                                     lv_ci_cal_type,
                                     ln_ci_sequence_number,
                                     per_grp_rec.person_id,
                                     ln_base_id,
                                     lv_err_msg
                                     );

              IF lv_err_msg = 'NULL' THEN
                    fnd_file.new_line(fnd_file.log,1);
                    fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
                    fnd_message.set_token('STDNT',igf_gr_gen.get_per_num(ln_base_id));
                    fnd_file.put_line(fnd_file.log,fnd_message.get);

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','Starting Run_Type=P with base_id:'||ln_base_id);
                    END IF;

                    --Call evaluate procedure for COA re-computation
                    evaluate(ln_base_id,lv_ci_cal_type,ln_ci_sequence_number);

                    --Update To Do Items
                    update_to_do_items(ln_base_id,lv_ci_cal_type,ln_ci_sequence_number);

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','Run_Type=P done');
                    END IF;

              ELSE
                OPEN  c_person_no(per_grp_rec.person_id);
                FETCH c_person_no INTO l_person_no;
                CLOSE c_person_no;

                fnd_message.set_name('IGF','IGF_AP_NO_BASEREC');
                fnd_message.set_token('STUD',l_person_no.party_number);
                fnd_file.new_line(fnd_file.log,1);
                fnd_file.put_line(fnd_file.log,fnd_message.get);
              END IF;

              FETCH cur_per_grp INTO per_grp_rec;
              EXIT WHEN cur_per_grp%NOTFOUND;
            END LOOP;
            CLOSE cur_per_grp;

          END IF; -- end of IF (cur_per_grp%NOTFOUND)


    --COMPUTATION FOR AUTO SELECT PERSONS ONLY
    ELSIF p_run_type = 'A' AND (p_pid_group IS NULL) AND (p_base_id IS NULL) THEN

      FOR l_person_id IN cur_person_id(lv_ci_cal_type,ln_ci_sequence_number)
      LOOP
              -- check if person has a fa base record
              ln_base_id := NULL;
              lv_err_msg := NULL;

              igf_gr_gen.get_base_id(
                                     lv_ci_cal_type,
                                     ln_ci_sequence_number,
                                     l_person_id.person_id,
                                     ln_base_id,
                                     lv_err_msg
                                     );

              IF lv_err_msg = 'NULL' THEN
                    fnd_file.new_line(fnd_file.log,1);
                    fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
                    fnd_message.set_token('STDNT',igf_gr_gen.get_per_num(ln_base_id));
                    fnd_file.put_line(fnd_file.log,fnd_message.get);

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','Starting Run_Type=A with base_id:'||ln_base_id);
                    END IF;

                    --Call evaluate procedure for COA re-computation
                    evaluate(ln_base_id,lv_ci_cal_type,ln_ci_sequence_number);

                    FOR l_person_ref IN c_person_ref(lv_ci_cal_type,ln_ci_sequence_number,l_person_id.person_id,l_person_id.s_student_todo_type,l_person_id.sequence_number)
                    LOOP
                        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','Updating table igs_pe_std_todo for person id: '||l_person_id.person_id);
                        END IF;

                        igs_pe_std_todo_ref_pkg.update_row(
                                                        x_rowid		              => l_person_ref.row_id,
                                                        x_person_id		          => l_person_ref.person_id,
                                                        x_s_student_todo_type   => l_person_ref.s_student_todo_type,
                                                        x_sequence_number	      => l_person_ref.sequence_number,
                                                        x_reference_number	    => l_person_ref.reference_number,
                                                        x_cal_type		          => l_person_ref.cal_type,
                                                        x_ci_sequence_number	  => l_person_ref.ci_sequence_number,
                                                        x_course_cd		          => l_person_ref.course_cd,
                                                        x_unit_cd		            => l_person_ref.unit_cd,
                                                        x_other_reference	      => l_person_ref.other_reference,
                                                        x_logical_delete_dt	    => sysdate,
                                                        x_mode 		              => 'R',
                                                        x_uoo_id		            => l_person_ref.uoo_id
                                                        );
                    END LOOP;

                    OPEN  c_person_todo(l_person_id.person_id,l_person_id.s_student_todo_type,l_person_id.sequence_number);
                    FETCH c_person_todo INTO l_person_todo;

                    IF c_person_todo%FOUND THEN

                       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','c_person_todo%FOUND');
                       END IF;

                       igs_pe_std_todo_pkg.update_row(
                                      x_rowid		            => l_person_todo.row_id,
                                      x_person_id		        => l_person_todo.person_id,
                                      x_s_student_todo_type => l_person_todo.s_student_todo_type,
                                      x_sequence_number	    => l_person_todo.sequence_number,
                                      x_todo_dt		          => l_person_todo.todo_dt,
                                      x_logical_delete_dt	  => sysdate,
                                      x_mode 		            => 'R'
                                      );
                    END IF;
                    CLOSE c_person_todo;

                    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_coa_update.main.debug','Run_Type=A done');
                    END IF;

              ELSE
                OPEN  c_person_no(l_person_id.person_id);
                FETCH c_person_no INTO l_person_no;
                CLOSE c_person_no;

                fnd_message.set_name('IGF','IGF_AP_NO_BASEREC');
                fnd_message.set_token('STUD',l_person_no.party_number);
                fnd_file.new_line(fnd_file.log,1);
                fnd_file.put_line(fnd_file.log,fnd_message.get);
              END IF;

      END LOOP;

    END IF;

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------');


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
        errbuf := fnd_message.get || SQLERRM;
  END main;

END igf_aw_coa_update;

/
