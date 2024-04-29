--------------------------------------------------------
--  DDL for Package Body IGF_AW_ROLLOVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_ROLLOVER" AS
/* $Header: IGFAW08B.pls 120.11 2006/02/01 02:58:55 ridas ship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGF_AW_ROLLOVER                         |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 |                                                                       |
 | HISTORY                                                               |
 | Who             When          What                                    |
 | ridas           16-MAY-2005   Build #4382389                          |
 |                               Rolling over all the award based setups |
 |                                                                       |
 *=======================================================================*/

  --Create fund todo items for the target award year
  FUNCTION create_fund_todo   (p_ref_fund_id            IN   igf_aw_fund_mast_all.fund_id%TYPE,
                               p_new_fund_id            IN   igf_aw_fund_mast_all.fund_id%TYPE,
                               p_frm_cal_type           IN   igs_ca_inst_all.cal_type%TYPE,
                               p_frm_sequence_number    IN   igs_ca_inst_all.sequence_number%TYPE,
                               p_to_cal_type            IN   igs_ca_inst_all.cal_type%TYPE,
                               p_to_sequence_number     IN   igs_ca_inst_all.sequence_number%TYPE,
                               p_todo_item              OUT NOCOPY  igf_ap_td_item_mst_all.item_code%TYPE
                              )
                              RETURN BOOLEAN IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 16-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    --Cursor to fetch the todo details attached to the fund id
    CURSOR c_get_fund_todo ( cp_ref_fund_id  igf_aw_fund_excl_all.fund_id%TYPE
                           ) IS
     SELECT DISTINCT mst.*
       FROM igf_ap_td_item_mst_all mst,
            igf_aw_fund_td_map_all map
      WHERE map.fund_id = cp_ref_fund_id
        AND map.item_sequence_number = mst.todo_number;

    l_get_fund_todo   c_get_fund_todo%ROWTYPE;


    --Cursor to fetch the todo items attached to the fund id
    CURSOR c_fund_td ( cp_ref_fund_id  igf_aw_fund_excl_all.fund_id%TYPE
                     ) IS
     SELECT  tdm.item_code,
             tdm.career_item
       FROM  igf_aw_fund_td_map_all  ftodo,
             igf_ap_td_item_mst_all  tdm
      WHERE	 tdm.todo_number = ftodo.item_sequence_number
        AND  ftodo.fund_id	= cp_ref_fund_id;

    l_fund_td     c_fund_td%ROWTYPE;


    --Cursor to fetch the todo number of a career item code
    CURSOR c_get_cr_td_number( cp_item_code         igf_ap_td_item_mst_all.item_code%TYPE
                             ) IS
      SELECT todo_number
        FROM igf_ap_td_item_mst_all
       WHERE ci_cal_type        IS NULL
         AND ci_sequence_number IS NULL
         AND item_code            = cp_item_code
         AND NVL(career_item,'N') = 'Y';


    --Cursor to fetch the todo number of an item code for the To Award Year
    CURSOR c_get_td_number( cp_to_cal_type          igs_ca_inst_all.cal_type%TYPE,
                            cp_to_sequence_number   igs_ca_inst_all.sequence_number%TYPE,
                            cp_item_code            igf_ap_td_item_mst_all.item_code%TYPE
                          ) IS
      SELECT todo_number
        FROM igf_ap_td_item_mst_all
       WHERE item_code          = cp_item_code
         AND ci_cal_type        = cp_to_cal_type
         AND ci_sequence_number = cp_to_sequence_number
         AND NVL(career_item,'N')  = 'N';


    l_rowid                   VARCHAR2(25);
    l_todo_number             igf_ap_td_item_mst.todo_number%TYPE;
    l_ftodo_id                igf_aw_fund_td_map.ftodo_id%TYPE;
    l_item_sequence_number    igf_aw_fund_td_map_all.item_sequence_number%TYPE;
    l_todo_item               igf_ap_td_item_mst_all.item_code%TYPE := NULL;
    lv_return_flg             VARCHAR2(1);

  BEGIN

    FOR l_get_fund_todo IN c_get_fund_todo(p_ref_fund_id)
    LOOP
      IF (l_get_fund_todo.ci_cal_type IS NOT NULL AND l_get_fund_todo.ci_sequence_number IS NOT NULL AND NVL(l_get_fund_todo.career_item,'N')='N') THEN
        OPEN c_get_td_number(p_to_cal_type, p_to_sequence_number, l_get_fund_todo.item_code);
        FETCH c_get_td_number INTO l_item_sequence_number;
        l_todo_item := l_get_fund_todo.item_code;

        IF c_get_td_number%NOTFOUND THEN
          l_rowid       := NULL;
          l_todo_number := NULL;

          BEGIN
              igf_ap_td_item_mst_pkg.insert_row(
                                                 x_rowid                 => l_rowid,
                                                 x_todo_number           => l_todo_number,
                                                 x_item_code             => l_get_fund_todo.item_code,
                                                 x_ci_cal_type           => p_to_cal_type,
                                                 x_ci_sequence_number    => p_to_sequence_number,
                                                 x_description           => l_get_fund_todo.description,
                                                 x_corsp_mesg            => l_get_fund_todo.corsp_mesg,
                                                 x_career_item           => l_get_fund_todo.career_item,
                                                 x_required_for_application => l_get_fund_todo.required_for_application,
                                                 x_freq_attempt             => l_get_fund_todo.freq_attempt,
                                                 x_max_attempt              => l_get_fund_todo.max_attempt,
                                                 x_mode                     => 'R',
                                                 x_system_todo_type_code => l_get_fund_todo.system_todo_type_code,
                                                 x_application_code      => l_get_fund_todo.application_code,
                                                 x_display_in_ss_flag    => l_get_fund_todo.display_in_ss_flag,
                                                 x_ss_instruction_txt    => l_get_fund_todo.ss_instruction_txt,
                                                 x_allow_attachment_flag => l_get_fund_todo.allow_attachment_flag,
                                                 x_document_url_txt      => l_get_fund_todo.document_url_txt
                                                );

              IF l_get_fund_todo.system_todo_type_code = 'INSTAPP' THEN
                 lv_return_flg := rollover_inst_attch_todo (  p_frm_cal_type         => p_frm_cal_type,
                                                              p_frm_sequence_number  => p_frm_sequence_number,
                                                              p_to_cal_type          => p_to_cal_type,
                                                              p_to_sequence_number   => p_to_sequence_number,
                                                              p_application_code     => l_get_fund_todo.application_code
                                                              );

                IF lv_return_flg = 'Y' THEN
                   p_todo_item := l_todo_item;

                   fnd_message.set_name('IGF','IGF_AP_INST_ATTCH_TODO_ERR');
                   fnd_message.set_token('APPLICATION',l_get_fund_todo.application_code);
                   fnd_message.set_token('ITEM',l_todo_item);
                   fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

                   RETURN FALSE;
                END IF;
              END IF;
          EXCEPTION
            WHEN OTHERS THEN
              CLOSE c_get_td_number;
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.create_fund_todo.exception','Error while creating To Do Items');
              END IF;

              p_todo_item := l_todo_item;
              RETURN FALSE;
          END;
        END IF;
        CLOSE c_get_td_number;
      END IF;
    END LOOP;


    FOR l_fund_td IN c_fund_td (p_ref_fund_id)
    LOOP
      l_item_sequence_number := NULL;

      IF NVL(l_fund_td.career_item,'N') = 'Y' THEN
        OPEN  c_get_cr_td_number (l_fund_td.item_code);
        FETCH c_get_cr_td_number INTO l_item_sequence_number;

        l_todo_item := l_fund_td.item_code;
        CLOSE c_get_cr_td_number;
      ELSE
        OPEN  c_get_td_number (p_to_cal_type, p_to_sequence_number, l_fund_td.item_code);
        FETCH c_get_td_number INTO l_item_sequence_number;

        l_todo_item := l_fund_td.item_code;
        CLOSE c_get_td_number;
      END IF;

      l_rowid     :=  NULL;
      l_ftodo_id  :=  NULL;
      igf_aw_fund_td_map_pkg.insert_row (
                                          x_rowid                => l_rowid,
                                          x_ftodo_id             => l_ftodo_id,
                                          x_fund_id              => p_new_fund_id,
                                          x_item_sequence_number => l_item_sequence_number
                                        );

    END LOOP;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      p_todo_item := l_todo_item;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.create_fund_todo.exception','Error while creating To Do Item mapping with fund');
      END IF;
      RETURN FALSE;

  END create_fund_todo;


  --Create pay feeclass for the target award year
  FUNCTION create_pay_feeclass(p_ref_fund_id        IN          igf_aw_fund_mast_all.fund_id%TYPE,
                               p_new_fund_id        IN          igf_aw_fund_mast_all.fund_id%TYPE,
                               p_fee_class          OUT NOCOPY  igf_aw_fund_feeclas_all.fee_class%TYPE
                              )
                              RETURN BOOLEAN IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 16-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- Get the details of the feeclasses for a given Fund ID
    CURSOR  c_get_feeclass ( cp_ref_fund_id  igf_aw_fund_excl_all.fund_id%TYPE
                           ) IS
      SELECT  fcls.fclass_id, fcls.fee_class
      FROM    igf_aw_fund_feeclas_all fcls
      WHERE   fund_id = cp_ref_fund_id;

    l_rowid       VARCHAR2(25);
    l_fclass_id   igf_aw_fund_feeclas_all.fclass_id%TYPE;

  BEGIN
    FOR l_get_feeclass IN c_get_feeclass( p_ref_fund_id ) LOOP
        l_rowid       := NULL;
        l_fclass_id   := NULL;
        p_fee_class   := l_get_feeclass.fee_class;


        igf_aw_fund_feeclas_pkg.insert_row(
                                           x_rowid                => l_rowid,
                                           x_fclass_id            => l_fclass_id,
                                           x_fund_id              => p_new_fund_id,
                                           x_fee_class            => l_get_feeclass.fee_class
                                          );
    END LOOP;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.create_pay_feeclass.exception','Error while creating feeclass');
      END IF;

      RETURN FALSE;

  END create_pay_feeclass;


  --Create pay units for the target award year
  FUNCTION create_pay_unit    (p_ref_fund_id         IN         igf_aw_fund_mast_all.fund_id%TYPE,
                               p_new_fund_id         IN         igf_aw_fund_mast_all.fund_id%TYPE,
                               p_pay_unit            OUT NOCOPY igf_aw_fund_unit_all.unit_cd%TYPE
                              )
                              RETURN BOOLEAN IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 16-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- Get the details of the pay units for a given Fund ID
    CURSOR  c_get_units ( cp_ref_fund_id  igf_aw_fund_excl_all.fund_id%TYPE
                        ) IS
      SELECT  unt.unit_cd
      FROM    igf_aw_fund_unit_all unt
      WHERE   fund_id = cp_ref_fund_id;

    -- Cursor to fetch all the existing versions for the UNIT
    CURSOR  c_get_unit_ver ( cp_unit_code     igs_ps_unit_ver_all.unit_cd%TYPE
                           ) IS
      SELECT  version_number
      FROM    igs_ps_unit_ver_all
      WHERE   unit_cd = cp_unit_code
    ORDER BY  version_number asc;

    l_rowid     VARCHAR2(25);
    l_funit_id  igf_aw_fund_unit_all.funit_id%TYPE;

  BEGIN
    FOR l_get_units IN c_get_units( p_ref_fund_id ) LOOP
      FOR l_get_unit_ver IN c_get_unit_ver (l_get_units.unit_cd)
      LOOP
        l_rowid     := NULL;
        l_funit_id  := NULL;
        p_pay_unit  := l_get_units.unit_cd;

        igf_aw_fund_unit_pkg.insert_row(
                                     x_rowid             => l_rowid,
                                     x_funit_id          => l_funit_id,
                                     x_fund_id           => p_new_fund_id,
                                     x_unit_cd           => l_get_units.unit_cd,
                                     x_version_number    => l_get_unit_ver.version_number
                                   );
      END LOOP;
    END LOOP;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.create_pay_unit.exception','Error while creating pay units');
      END IF;

      RETURN FALSE;

  END create_pay_unit;



  --Create pay programs for the target award year
  FUNCTION create_pay_program (p_ref_fund_id         IN         igf_aw_fund_mast_all.fund_id%TYPE,
                               p_new_fund_id         IN         igf_aw_fund_mast_all.fund_id%TYPE,
                               p_pay_program         OUT NOCOPY igf_aw_fund_prg_all.course_cd%TYPE
                              )
                              RETURN BOOLEAN IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 16-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- Get the details of the pay programs for a given Fund ID
    CURSOR  c_get_programs ( cp_ref_fund_id  igf_aw_fund_excl_all.fund_id%TYPE
                           ) IS
      SELECT  prg.course_cd
      FROM    igf_aw_fund_prg_all prg
      WHERE   fund_id = cp_ref_fund_id;

    -- Cursor to fetch all the existing versions for the program type
    CURSOR  c_get_program_ver ( cp_program_code     igs_ps_ver_all.course_cd%TYPE
                              ) IS
      SELECT  version_number
      FROM    igs_ps_ver_all
      WHERE   course_cd = cp_program_code
    ORDER BY  version_number asc;


    l_rowid     VARCHAR2(25);
    l_fprg_id   igf_aw_fund_prg_all.fprg_id%TYPE;

  BEGIN
    FOR l_get_programs IN c_get_programs( p_ref_fund_id ) LOOP
        FOR l_get_program_ver IN c_get_program_ver (l_get_programs.course_cd)
        LOOP
            l_rowid           := NULL;
            l_fprg_id         := NULL;
            p_pay_program     := l_get_programs.course_cd;

            igf_aw_fund_prg_pkg.insert_row (
                                              x_rowid             => l_rowid,
                                              x_fprg_id           => l_fprg_id,
                                              x_fund_id           => p_new_fund_id,
                                              x_course_cd         => l_get_programs.course_cd,
                                              x_version_number    => l_get_program_ver.version_number
                                            );
        END LOOP;
    END LOOP;
    RETURN TRUE;

    EXCEPTION
      WHEN OTHERS THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.create_pay_program.exception','Error while creating pay programs');
        END IF;
        RETURN FALSE;

  END create_pay_program;



  --Create exclusive fund for the target award year
  FUNCTION create_exclusive_fund (p_ref_fund_id            IN   igf_aw_fund_mast_all.fund_id%TYPE,
                                  p_new_fund_id            IN   igf_aw_fund_mast_all.fund_id%TYPE,
                                  p_frm_cal_type           IN   igs_ca_inst_all.cal_type%TYPE,
                                  p_frm_sequence_number    IN   igs_ca_inst_all.sequence_number%TYPE,
                                  p_exclusive_fund         OUT NOCOPY igf_aw_fund_mast_all.fund_code%TYPE
                                  )
                                  RETURN BOOLEAN IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 16-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- Get the details of the existing Exclusive Funds for a given Fund ID
    CURSOR c_fund_excl( cp_ref_fund_id  igf_aw_fund_excl_all.fund_id%TYPE
                      ) IS
      SELECT excl.fund_code
      FROM igf_aw_fund_excl_all excl
      WHERE excl.fund_id = cp_ref_fund_id;

    -- check whether the fund is a discontinued fund or not
    CURSOR c_chk_disc_fund( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                            cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                            cp_fund_code            igf_aw_fund_mast_all.fund_code%TYPE
                          ) IS
      SELECT discontinue_fund
      FROM igf_aw_fund_mast_all fnd
      WHERE fnd.ci_cal_type         = cp_frm_cal_type
        AND fnd.ci_sequence_number  = cp_frm_sequence_number
        AND fnd.fund_code           = cp_fund_code;

    l_discontinue_fund    igf_aw_fund_mast_all.discontinue_fund%TYPE;
    l_rowid               VARCHAR2(25);

  BEGIN
    FOR l_fund_excl_rec IN c_fund_excl( p_ref_fund_id ) LOOP
        l_discontinue_fund  := NULL;
        p_exclusive_fund    := l_fund_excl_rec.fund_code;

        OPEN  c_chk_disc_fund(p_frm_cal_type, p_frm_sequence_number, l_fund_excl_rec.fund_code);
        FETCH c_chk_disc_fund INTO l_discontinue_fund;
        CLOSE c_chk_disc_fund;

        IF l_discontinue_fund = 'Y' THEN
          RETURN FALSE;
        END IF;


        l_rowid   := NULL;
        igf_aw_fund_excl_pkg.insert_row(
                                  x_rowid          => l_rowid,
                                  x_fund_id        => p_new_fund_id,
                                  x_fund_code      => l_fund_excl_rec.fund_code
                                  );
    END LOOP;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.create_exclusive_fund.exception','Error while creating exclusive fund');
      END IF;
      RETURN FALSE;

  END create_exclusive_fund;


  --Create inclusive fund for the target award year
  FUNCTION create_inclusive_fund (p_ref_fund_id            IN   igf_aw_fund_mast_all.fund_id%TYPE,
                                  p_new_fund_id            IN   igf_aw_fund_mast_all.fund_id%TYPE,
                                  p_frm_cal_type           IN   igs_ca_inst_all.cal_type%TYPE,
                                  p_frm_sequence_number    IN   igs_ca_inst_all.sequence_number%TYPE,
                                  p_inclusive_fund         OUT NOCOPY igf_aw_fund_mast_all.fund_code%TYPE
                                  )
                                  RETURN BOOLEAN IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 16-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- Get the details of the existing Inclusive Funds for a given Fund ID
    CURSOR c_fund_incl( cp_ref_fund_id  igf_aw_fund_incl_all.fund_id%TYPE
                      ) IS
      SELECT incl.fund_code
      FROM igf_aw_fund_incl_all incl
      WHERE incl.fund_id = cp_ref_fund_id;

    -- check whether the fund is a discontinued fund or not
    CURSOR c_chk_disc_fund( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                            cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                            cp_fund_code            igf_aw_fund_mast_all.fund_code%TYPE
                          ) IS
      SELECT discontinue_fund
      FROM igf_aw_fund_mast_all fnd
      WHERE fnd.ci_cal_type         = cp_frm_cal_type
        AND fnd.ci_sequence_number  = cp_frm_sequence_number
        AND fnd.fund_code           = cp_fund_code;

    l_discontinue_fund    igf_aw_fund_mast_all.discontinue_fund%TYPE;
    l_rowid               VARCHAR2(25);

  BEGIN
    FOR l_fund_incl_rec IN c_fund_incl( p_ref_fund_id )
    LOOP
      l_discontinue_fund  := NULL;
      p_inclusive_fund    := l_fund_incl_rec.fund_code;

      OPEN  c_chk_disc_fund(p_frm_cal_type, p_frm_sequence_number, l_fund_incl_rec.fund_code);
      FETCH c_chk_disc_fund INTO l_discontinue_fund;
      CLOSE c_chk_disc_fund;

      IF l_discontinue_fund = 'Y' THEN
        RETURN FALSE;
      END IF;

      l_rowid   := NULL;
      igf_aw_fund_incl_pkg.insert_row(
                                  x_rowid          => l_rowid,
                                  x_fund_id        => p_new_fund_id,
                                  x_fund_code      => l_fund_incl_rec.fund_code
                                  );
    END LOOP;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.create_inclusive_fund.exception','Error while creating inclusive fund');
      END IF;
      RETURN FALSE;

  END create_inclusive_fund;


  -- Function to check the existence of the fund in the target award year
  -- IF exists return TRUE, else return FALSE
  FUNCTION fund_exists (  p_fund_code            IN   igf_aw_fund_mast_all.fund_code%TYPE,
                          p_to_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                          p_to_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                       )
                       RETURN BOOLEAN IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 16-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- check whether the fund already present
    CURSOR c_fund_exists( cp_to_cal_type         igs_ca_inst_all.cal_type%TYPE,
                          cp_to_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                          cp_fund_code           igf_aw_fund_mast_all.fund_code%TYPE
                        ) IS
      SELECT 'X' exist
      FROM igf_aw_fund_mast_all fnd
      WHERE fnd.ci_cal_type         = cp_to_cal_type
        AND fnd.ci_sequence_number  = cp_to_sequence_number
        AND fnd.fund_code           = cp_fund_code;

    l_fund_exists     c_fund_exists%ROWTYPE;

  BEGIN

    OPEN c_fund_exists(p_to_cal_type, p_to_sequence_number, p_fund_code);
    FETCH c_fund_exists INTO l_fund_exists;
      IF c_fund_exists%NOTFOUND THEN
        CLOSE c_fund_exists;
        RETURN FALSE;
      END IF;

    CLOSE c_fund_exists;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.fund_exists.debug','Fund already exists :'||p_fund_code);
    END IF;

    RETURN TRUE;

  END fund_exists;


  -- Procedure to create a new fund for the target award year
  FUNCTION create_new_fund (  p_fund_rec             IN   igf_aw_fund_mast_all%ROWTYPE,
                              p_to_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                              p_to_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                              )
                              RETURN igf_aw_fund_mast_all.fund_id%TYPE IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 16-MAY-2005

  -- Change History:
  -- Who         When            What
  -- museshad    14-Jul-2005     Build FA 140: Modified TBH call, since new columns
  --                             have got added to igf_aw_fund_mast_all.
  --------------------------------------------------------------------------------

    l_rowid              VARCHAR2(25):= NULL;
    l_fund_id            igf_aw_fund_mast_all.fund_id%TYPE  := NULL;

  BEGIN
    igf_aw_fund_mast_pkg.insert_row(
                            x_rowid                    => l_rowid,
                            x_fund_id                  => l_fund_id,
                            x_fund_code                => p_fund_rec.fund_code,
                            x_ci_cal_type              => p_to_cal_type,
                            x_ci_sequence_number       => p_to_sequence_number,
                            x_description              => p_fund_rec.description,
                            x_discontinue_fund         => p_fund_rec.discontinue_fund,
                            x_entitlement              => p_fund_rec.entitlement,
                            x_auto_pkg                 => p_fund_rec.auto_pkg,
                            x_self_help                => p_fund_rec.self_help,
                            x_allow_man_pkg            => p_fund_rec.allow_man_pkg,
                            x_update_need              => p_fund_rec.update_need,
                            x_disburse_fund            => p_fund_rec.disburse_fund,
                            x_available_amt            => p_fund_rec.available_amt,
                            x_offered_amt              => 0,
                            x_pending_amt              => 0,
                            x_accepted_amt             => 0,
                            x_declined_amt             => 0,
                            x_cancelled_amt            => 0,
                            x_remaining_amt            => p_fund_rec.available_amt,
                            x_enrollment_status        => p_fund_rec.enrollment_status,
                            x_prn_award_letter         => p_fund_rec.prn_award_letter,
                            x_over_award_amt           => p_fund_rec.over_award_amt,
                            x_over_award_perct         => p_fund_rec.over_award_perct,
                            x_min_award_amt            => p_fund_rec.min_award_amt,
                            x_max_award_amt            => p_fund_rec.max_award_amt,
                            x_max_yearly_amt           => p_fund_rec.max_yearly_amt,
                            x_max_life_amt             => p_fund_rec.max_life_amt,
                            x_max_life_term            => p_fund_rec.max_life_term,
                            x_fm_fc_methd              => p_fund_rec.fm_fc_methd,
                            x_roundoff_fact            => p_fund_rec.roundoff_fact,
                            x_replace_fc               => p_fund_rec.replace_fc,
                            x_allow_overaward          => p_fund_rec.allow_overaward,
                            x_pckg_awd_stat            => p_fund_rec.pckg_awd_stat,
                            x_org_record_req           => p_fund_rec.org_record_req,
                            x_disb_record_req          => p_fund_rec.disb_record_req,
                            x_prom_note_req            => p_fund_rec.prom_note_req,
                            x_min_num_disb             => p_fund_rec.min_num_disb,
                            x_max_num_disb             => p_fund_rec.max_num_disb,
                            x_fee_type                 => p_fund_rec.fee_type,
                            x_total_offered            => 0,
                            x_total_accepted           => 0,
                            x_total_declined           => 0,
                            x_total_revoked            => 0,
                            x_total_cancelled          => 0,
                            x_total_disbursed          => 0,
                            x_total_committed          => 0,
                            x_committed_amt            => 0,
                            x_disbursed_amt            => 0,
                            x_awd_notice_txt           => p_fund_rec.awd_notice_txt,
                            x_attribute_category       => p_fund_rec.attribute_category,
                            x_attribute1               => p_fund_rec.attribute1,
                            x_attribute2               => p_fund_rec.attribute2,
                            x_attribute3               => p_fund_rec.attribute3,
                            x_attribute4               => p_fund_rec.attribute4,
                            x_attribute5               => p_fund_rec.attribute5,
                            x_attribute6               => p_fund_rec.attribute6,
                            x_attribute7               => p_fund_rec.attribute7,
                            x_attribute8               => p_fund_rec.attribute8,
                            x_attribute9               => p_fund_rec.attribute9,
                            x_attribute10              => p_fund_rec.attribute10,
                            x_attribute11              => p_fund_rec.attribute11,
                            x_attribute12              => p_fund_rec.attribute12,
                            x_attribute13              => p_fund_rec.attribute13,
                            x_attribute14              => p_fund_rec.attribute14,
                            x_attribute15              => p_fund_rec.attribute15,
                            x_attribute16              => p_fund_rec.attribute16,
                            x_attribute17              => p_fund_rec.attribute17,
                            x_attribute18              => p_fund_rec.attribute18,
                            x_attribute19              => p_fund_rec.attribute19,
                            x_attribute20              => p_fund_rec.attribute20,
                            x_disb_verf_da             => p_fund_rec.disb_verf_da,
                            x_fund_exp_da              => p_fund_rec.fund_exp_da,
                            x_nslds_disb_da            => p_fund_rec.nslds_disb_da ,
                            x_disb_exp_da              => p_fund_rec.disb_exp_da,
                            x_fund_recv_reqd           => p_fund_rec.fund_recv_reqd,
                            x_show_on_bill             => p_fund_rec.show_on_bill,
                            x_bill_desc                => p_fund_rec.bill_desc,
                            x_credit_type_id           => p_fund_rec.credit_type_id,
                            x_spnsr_ref_num            => NULL,
                            x_party_id                 => p_fund_rec.party_id,
                            x_spnsr_fee_type           => NULL,
                            x_min_credit_points        => p_fund_rec.min_credit_points,
                            x_group_id                 => p_fund_rec.group_id ,
                            x_spnsr_attribute_category => NULL,
                            x_spnsr_attribute1         => NULL,
                            x_spnsr_attribute2         => NULL,
                            x_spnsr_attribute3         => NULL,
                            x_spnsr_attribute4         => NULL,
                            x_spnsr_attribute5         => NULL,
                            x_spnsr_attribute6         => NULL,
                            x_spnsr_attribute7         => NULL,
                            x_spnsr_attribute8         => NULL,
                            x_spnsr_attribute9         => NULL,
                            x_spnsr_attribute10        => NULL,
                            x_spnsr_attribute11        => NULL,
                            x_spnsr_attribute12        => NULL,
                            x_spnsr_attribute13        => NULL,
                            x_spnsr_attribute14        => NULL,
                            x_spnsr_attribute15        => NULL,
                            x_spnsr_attribute16        => NULL,
                            x_spnsr_attribute17        => NULL,
                            x_spnsr_attribute18        => NULL,
                            x_spnsr_attribute19        => NULL,
                            x_spnsr_attribute20        => NULL,
                            x_threshold_perct          => p_fund_rec.threshold_perct,
                            x_threshold_value          => p_fund_rec.threshold_value,
                            x_gift_aid                 => p_fund_rec.gift_aid,
                            x_send_without_doc         => p_fund_rec.send_without_doc,
                            x_ver_app_stat_override    => p_fund_rec.ver_app_stat_override,
                            x_re_pkg_verif_flag        => p_fund_rec.re_pkg_verif_flag,
                            x_donot_repkg_if_code      => p_fund_rec.donot_repkg_if_code,
                            x_lock_award_flag          => p_fund_rec.lock_award_flag,
                            x_mode                     => 'R',
                            x_view_only_flag           => p_fund_rec.view_only_flag,
                            x_accept_less_amt_flag     => p_fund_rec.accept_less_amt_flag,
                            x_allow_inc_post_accept_flag    => p_fund_rec.allow_inc_post_accept_flag,
                            x_min_increase_amt              => p_fund_rec.min_increase_amt,
                            x_allow_dec_post_accept_flag    => p_fund_rec.allow_dec_post_accept_flag,
                            x_min_decrease_amt              => p_fund_rec.min_decrease_amt,
                            x_allow_decln_post_accept_flag  => p_fund_rec.allow_decln_post_accept_flag,
                            x_status_after_decline          => p_fund_rec.status_after_decline,
                            x_fund_information_txt          => p_fund_rec.fund_information_txt,
                            x_disb_rounding_code            => p_fund_rec.disb_rounding_code
                          );

        RETURN l_fund_id;

  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.create_new_fund.exception','Error while creating new fund :'||p_fund_rec.fund_code);
      END IF;
      RETURN NULL;

  END create_new_fund;



  -- Procedure to rollover fund attributes
  PROCEDURE rollover_fund_attributes (  p_frm_cal_type         IN   igs_ca_inst_all.cal_type%TYPE,
                                        p_frm_sequence_number  IN   igs_ca_inst_all.sequence_number%TYPE,
                                        p_to_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                                        p_to_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                                     )
                                     IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 16-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- Get the funds for the source award year
    CURSOR c_fund( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                   cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                  ) IS
      SELECT fnd.*
      FROM  igf_aw_fund_mast_all fnd,igf_aw_fund_cat_all fcat
      WHERE fnd.ci_cal_type         = cp_frm_cal_type
        AND fnd.ci_sequence_number  = cp_frm_sequence_number
        AND fnd.fund_code           = fcat.fund_code
        AND fcat.sys_fund_type <> 'SPONSOR'
      ORDER BY fnd.fund_id;

    l_new_fund_id         igf_aw_fund_mast_all.fund_id%TYPE  := NULL;
    E_SKIP_FUND           EXCEPTION;
    l_pay_program		      igf_aw_fund_prg_all.course_cd%TYPE;
    l_pay_unit		        igf_aw_fund_unit_all.unit_cd%TYPE;
    l_fee_class		        igf_aw_fund_feeclas_all.fee_class%TYPE;
    l_todo_item		        igf_ap_td_item_mst_all.item_code%TYPE;
    l_inclusive_fund      igf_aw_fund_mast_all.fund_code%TYPE;
    l_exclusive_fund      igf_aw_fund_mast_all.fund_code%TYPE;
    l_discontinued_flg    VARCHAR2(1) := 'N';

  BEGIN

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','FUND_ATTRIBUTE')||':' );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_fund_attributes.debug','Processing Fund Attributes');
    END IF;

    FOR l_fund IN c_fund(p_frm_cal_type, p_frm_sequence_number)
    LOOP
        BEGIN
          fnd_message.set_name('IGF','IGF_AW_PROC_FUND');
          fnd_message.set_token('FUND',l_fund.fund_code);
          fnd_file.put_line(fnd_file.log, RPAD(' ',5)|| fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_fund_attributes.debug','Fund :'||l_fund.fund_code);
          END IF;

          --Check whether the fund already got rolled over
          IF fund_exists(l_fund.fund_code, p_to_cal_type, p_to_sequence_number) THEN
            fnd_message.set_name('IGF','IGF_AW_FND_ALRDY_PRSNT');
            fnd_message.set_token('FUND',l_fund.fund_code);
            fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

            RAISE E_SKIP_FUND;
          END IF;

          --Check for discontinued fund
          IF l_fund.discontinue_fund = 'Y' THEN
            fnd_message.set_name('IGF','IGF_AW_FND_RLOVR_DISCONT');
            fnd_message.set_token('FUND',l_fund.fund_code);
            fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_fund_attributes.debug','Discontinued Fund');
            END IF;

            l_discontinued_flg  := 'Y';
            RAISE E_SKIP_FUND;
          END IF;

          SAVEPOINT rollover_fund_attributes;

          --Create new fund for the target award year
          l_new_fund_id := create_new_fund( p_fund_rec            => l_fund,
                                            p_to_cal_type         => p_to_cal_type,
                                            p_to_sequence_number  => p_to_sequence_number
                                          );

          IF l_new_fund_id IS NULL THEN
            fnd_message.set_name('IGF','IGF_AW_INSERT_FUND_ERR');
            fnd_message.set_token('FUND',l_fund.fund_code);
            fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

            ROLLBACK TO rollover_fund_attributes;
            RAISE E_SKIP_FUND;

          ELSE
            l_inclusive_fund  := NULL;
            --Skip the fund if creation of inclusive fund is not successful
            IF NOT create_inclusive_fund(l_fund.fund_id, l_new_fund_id, p_frm_cal_type, p_frm_sequence_number, l_inclusive_fund) THEN
              fnd_message.set_name('IGF','IGF_AW_FND_RLOVR_INCL_FLD');
              fnd_message.set_token('FUND',l_inclusive_fund);
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

              ROLLBACK TO rollover_fund_attributes;
              RAISE E_SKIP_FUND;
            END IF;

            l_exclusive_fund  := NULL;
            --Skip the fund if creation of exclusive fund is not successful
            IF NOT create_exclusive_fund(l_fund.fund_id, l_new_fund_id, p_frm_cal_type, p_frm_sequence_number, l_exclusive_fund) THEN
              fnd_message.set_name('IGF','IGF_AW_FND_RLOVR_EXCL_FLD');
              fnd_message.set_token('FUND',l_exclusive_fund);
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

              ROLLBACK TO rollover_fund_attributes;
              RAISE E_SKIP_FUND;
            END IF;

            l_pay_program := NULL;
            --Skip the fund if creation of pay program is not successful
            IF NOT create_pay_program(l_fund.fund_id, l_new_fund_id, l_pay_program) THEN
              fnd_message.set_name('IGF','IGF_AW_FND_PRG_ROLL');
              fnd_message.set_token('PROGRAM',l_pay_program);
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

              ROLLBACK TO rollover_fund_attributes;
              RAISE E_SKIP_FUND;
            END IF;

            l_pay_unit := NULL;
            --Skip the fund if creation of pay unit is not successful
            IF NOT create_pay_unit(l_fund.fund_id, l_new_fund_id, l_pay_unit) THEN
              fnd_message.set_name('IGF','IGF_AW_FND_UNIT_ROLL');
              fnd_message.set_token('UNIT',l_pay_unit);
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

              ROLLBACK TO rollover_fund_attributes;
              RAISE E_SKIP_FUND;
            END IF;

            l_fee_class := NULL;
            --Skip the fund if creation of pay feeclass is not successful
            IF NOT create_pay_feeclass(l_fund.fund_id, l_new_fund_id, l_fee_class) THEN
              fnd_message.set_name('IGF','IGF_AW_FND_FEECLS_ROLL');
              fnd_message.set_token('FEE_CLASS',l_fee_class);
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

              ROLLBACK TO rollover_fund_attributes;
              RAISE E_SKIP_FUND;
            END IF;

            l_todo_item := NULL;
            --Skip the fund if creation of fund todo is not successful
            IF NOT create_fund_todo(l_fund.fund_id,l_new_fund_id,p_frm_cal_type,p_frm_sequence_number,p_to_cal_type,p_to_sequence_number,l_todo_item) THEN
              fnd_message.set_name('IGF','IGF_AW_FND_TODO_ROLL');
              fnd_message.set_token('TODO_ITEM',l_todo_item);
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

              ROLLBACK TO rollover_fund_attributes;
              RAISE E_SKIP_FUND;
            END IF;

          END IF;

          COMMIT;
          fnd_message.set_name('IGF','IGF_AW_FND_RLOVR_FND_SUCCFL');
          fnd_message.set_token('FUND',l_fund.fund_code);
          fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_fund_attributes.debug','Successfully rolled over fund :'||l_fund.fund_code);
          END IF;
        EXCEPTION
          WHEN E_SKIP_FUND THEN
            IF l_discontinued_flg  = 'N' THEN
              fnd_message.set_name('IGF','IGF_AW_SKIPPING_FUND');
              fnd_message.set_token('FUND_CODE',l_fund.fund_code);
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);
            END IF;

            l_discontinued_flg  := 'N';

            IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_fund_attributes.exception','Skipping the fund :'||l_fund.fund_code);
            END IF;

          WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','igf_aw_rollover.rollover_fund_attributes :' || SQLERRM);
            IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_fund_attributes.exception','sql error:'||SQLERRM);
            END IF;

            app_exception.raise_exception;
        END;
    END LOOP;

  END rollover_fund_attributes;


  -- Function to check mapping (Award Year/ Term/ Teaching Period)
  -- IF exists return TRUE, else return FALSE
  FUNCTION chk_calendar_mapping ( p_frm_cal_type          IN  igs_ca_inst_all.cal_type%TYPE,
                                  p_frm_sequence_number   IN  igs_ca_inst_all.sequence_number%TYPE,
                                  p_to_cal_type           OUT NOCOPY igs_ca_inst_all.cal_type%TYPE,
                                  p_to_sequence_number    OUT NOCOPY igs_ca_inst_all.sequence_number%TYPE
                                )
                                RETURN BOOLEAN IS

    CURSOR c_map_details( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                          cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                        ) IS
      SELECT cr_cal_type,
             sc_sequence_number
        FROM igf_aw_cal_rel_all
       WHERE cr_cal_type          = cp_frm_cal_type
         AND cr_sequence_number   = cp_frm_sequence_number
         AND NVL(active,'N') =  'Y';


  BEGIN
    OPEN c_map_details(p_frm_cal_type, p_frm_sequence_number);
    FETCH c_map_details INTO p_to_cal_type, p_to_sequence_number;
      IF c_map_details%NOTFOUND THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.chk_calendar_mapping.debug','Calendar Mapping does not exist');
        END IF;

        CLOSE c_map_details;
        RETURN FALSE;
      END IF;

    CLOSE c_map_details;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.chk_calendar_mapping.debug','Calendar Mapping exists');
    END IF;

    RETURN TRUE;

  END chk_calendar_mapping;


  -- Function to check the existence of the rate based setup in the target award year
  -- IF exists return TRUE, else return FALSE
  FUNCTION rate_setup_exists (  p_item_code            IN   igf_aw_coa_rate_det.item_code%TYPE,
                                p_to_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                                p_to_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                             )
                             RETURN BOOLEAN IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 17-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- check whether the item code is present or not
    CURSOR c_item_exists( cp_to_cal_type         igs_ca_inst_all.cal_type%TYPE,
                          cp_to_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                          cp_item_code           igf_aw_coa_rate_det.item_code%TYPE
                        ) IS
      SELECT 'X' exist
        FROM igf_aw_coa_rate_det item
       WHERE item.ci_cal_type         = cp_to_cal_type
         AND item.ci_sequence_number  = cp_to_sequence_number
         AND item.item_code           = cp_item_code
         AND rownum = 1;

    l_item_exists  c_item_exists%ROWTYPE;

  BEGIN

    OPEN c_item_exists(p_to_cal_type, p_to_sequence_number, p_item_code);
    FETCH c_item_exists INTO l_item_exists;
      IF c_item_exists%NOTFOUND THEN
        CLOSE c_item_exists;
        RETURN FALSE;
      END IF;

    CLOSE c_item_exists;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rate_setup_exists.debug','Item already exists :'||p_item_code);
    END IF;

    RETURN TRUE;

  END rate_setup_exists;


  -- Procedure to rollover Cost of Attendance Rate Table Setup
  PROCEDURE rollover_rate_setups (  p_frm_cal_type         IN   igs_ca_inst_all.cal_type%TYPE,
                                    p_frm_sequence_number  IN   igs_ca_inst_all.sequence_number%TYPE,
                                    p_to_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                                    p_to_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                                  )
                                  IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 17-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- Get distinct item code from the source award year
    CURSOR c_get_itm_code( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                           cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                         ) IS
      SELECT item_code
        FROM igf_aw_coa_rate_det
       WHERE ci_cal_type         = cp_frm_cal_type
         AND ci_sequence_number  = cp_frm_sequence_number
    GROUP BY item_code
    ORDER BY item_code;


    -- Get the rate table setup details for the source award year
    CURSOR c_rate_setup( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                         cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                         cp_item_code            igf_aw_coa_rate_det.item_code%TYPE
                       ) IS
      SELECT rate.*
        FROM igf_aw_coa_rate_det rate
       WHERE rate.ci_cal_type         = cp_frm_cal_type
         AND rate.ci_sequence_number  = cp_frm_sequence_number
         AND rate.item_code           = cp_item_code;

    l_to_ld_cal_type          igs_ca_inst_all.cal_type%TYPE;
    l_to_ld_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
    l_rowid                   VARCHAR2(25);
    E_SKIP_ITEM               EXCEPTION;
    l_error_occurred          VARCHAR2(1) := 'N';

  BEGIN

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','COA_RATE_TABLE')||':' );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_rate_setups.debug','Processing Rate Based Setups');
    END IF;

    FOR l_get_itm_code IN c_get_itm_code(p_frm_cal_type, p_frm_sequence_number)
    LOOP
      BEGIN
        SAVEPOINT rollover_rate_setups;

        fnd_message.set_name('IGF','IGF_AW_PROC_COA_ITEM');
        fnd_message.set_token('ITEM',l_get_itm_code.item_code);
        fnd_file.put_line(fnd_file.log, RPAD(' ',5)|| fnd_message.get);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_rate_setups.debug','COA Item :'||l_get_itm_code.item_code);
        END IF;

        --Check whether the item already got rolled over
        IF rate_setup_exists(l_get_itm_code.item_code, p_to_cal_type, p_to_sequence_number) THEN
          fnd_message.set_name('IGF','IGF_AW_ITM_ALRDY_EXISTS');
          fnd_message.set_token('ITEM',l_get_itm_code.item_code);
          fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_rate_setups.debug','COA Item already ecists :'||l_get_itm_code.item_code);
          END IF;
          RAISE E_SKIP_ITEM;
        END IF;

        l_error_occurred  := 'N';
        FOR l_rate_setup IN c_rate_setup(p_frm_cal_type, p_frm_sequence_number, l_get_itm_code.item_code)
        LOOP
            l_to_ld_cal_type          := NULL;
            l_to_ld_sequence_number   := NULL;

            IF l_rate_setup.ld_cal_type IS NOT NULL AND l_rate_setup.ld_sequence_number IS NOT NULL THEN
              IF NOT chk_calendar_mapping(l_rate_setup.ld_cal_type,l_rate_setup.ld_sequence_number,l_to_ld_cal_type,l_to_ld_sequence_number) THEN
                fnd_message.set_name('IGF','IGF_AW_TRM_NT_EXISTS');
                fnd_message.set_token('ITEM',l_rate_setup.item_code);
                fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(l_rate_setup.ld_cal_type,l_rate_setup.ld_sequence_number));

                fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);
                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_rate_setups.debug','Calendar Mapping does not exist');
                END IF;

                l_error_occurred  := 'Y';
              END IF;
            END IF;

            IF l_error_occurred = 'N' THEN
              l_rowid := NULL;
              igf_aw_coa_rate_det_pkg.insert_row (
                                            x_mode                      =>  'R',
                                            x_rowid                     =>  l_rowid,
                                            x_ci_cal_type               =>  p_to_cal_type,
                                            x_ci_sequence_number        =>  p_to_sequence_number,
                                            x_item_code                 =>  l_rate_setup.item_code,
                                            x_rate_order_num            =>  l_rate_setup.rate_order_num,
                                            x_pid_group_cd              =>  l_rate_setup.pid_group_cd,
                                            x_org_unit_cd               =>  l_rate_setup.org_unit_cd,
                                            x_program_type              =>  l_rate_setup.program_type,
                                            x_program_location_cd       =>  l_rate_setup.program_location_cd,
                                            x_program_cd                =>  l_rate_setup.program_cd,
                                            x_class_standing            =>  l_rate_setup.class_standing,
                                            x_residency_status_code     =>  l_rate_setup.residency_status_code,
                                            x_housing_status_code       =>  l_rate_setup.housing_status_code,
                                            x_attendance_type           =>  l_rate_setup.attendance_type,
                                            x_attendance_mode           =>  l_rate_setup.attendance_mode,
                                            x_ld_cal_type               =>  l_to_ld_cal_type,
                                            x_ld_sequence_number        =>  l_to_ld_sequence_number,
                                            x_mult_factor_code          =>  l_rate_setup.mult_factor_code,
                                            x_mult_amount_num           =>  l_rate_setup.mult_amount_num
                                           );
            END IF;

        END LOOP;

        IF l_error_occurred = 'N' THEN
          COMMIT;

          fnd_message.set_name('IGF','IGF_AW_RT_RLOVR_SUCCFL');
          fnd_message.set_token('ITEM',l_get_itm_code.item_code);
          fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_rate_setups.debug','Successfully rolled over coa item :'||l_get_itm_code.item_code);
          END IF;
        ELSE
          RAISE E_SKIP_ITEM;
        END IF;

      EXCEPTION
        WHEN E_SKIP_ITEM THEN
            ROLLBACK TO rollover_rate_setups;
            fnd_message.set_name('IGF','IGF_AW_SKIPPING_ITEM');
            fnd_message.set_token('ITEM',l_get_itm_code.item_code);
            fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

          IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_rate_setups.exception','Skipping the item :'||l_get_itm_code.item_code);
          END IF;

        WHEN OTHERS THEN
          fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
          fnd_message.set_token('NAME','igf_aw_rollover.rollover_rate_setups :' || SQLERRM);
          IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_rate_setups.exception','sql error:'||SQLERRM);
          END IF;

          app_exception.raise_exception;
      END;
    END LOOP;
  END rollover_rate_setups;



  -- Procedure to rollover Institutional Application Setup
  PROCEDURE rollover_inst_applications (  p_frm_cal_type         IN   igs_ca_inst_all.cal_type%TYPE,
                                          p_frm_sequence_number  IN   igs_ca_inst_all.sequence_number%TYPE,
                                          p_to_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                                          p_to_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                                        )
                                        IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 19-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- Get distinct Application Code from the source award year
    CURSOR c_get_appln_code( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                             cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                           ) IS
      SELECT appln.application_code
        FROM igf_ap_appl_setup_all appln
       WHERE appln.ci_cal_type         = cp_frm_cal_type
         AND appln.ci_sequence_number  = cp_frm_sequence_number
         AND NVL(appln.active_flag,'N')= 'Y'
    GROUP BY appln.application_code
    ORDER BY appln.application_code;


    -- Get the institutional application setup details for the source award year
    CURSOR c_inst_appln_setup( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                               cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                               cp_application_code     igf_ap_appl_setup_all.application_code%TYPE
                             ) IS
      SELECT appln.*
        FROM igf_ap_appl_setup_all appln
       WHERE appln.ci_cal_type         = cp_frm_cal_type
         AND appln.ci_sequence_number  = cp_frm_sequence_number
         AND appln.application_code    = cp_application_code
         AND NVL(appln.active_flag,'N')= 'Y'
    ORDER BY appln.question_id;


    -- Check whether the application exists or not
    CURSOR c_appln_exists( cp_to_cal_type         igs_ca_inst_all.cal_type%TYPE,
                           cp_to_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                           cp_application_code    igf_ap_appl_setup_all.application_code%TYPE
                         ) IS
      SELECT 'X' exist
        FROM igf_ap_appl_setup_all appln
       WHERE appln.ci_cal_type         = cp_to_cal_type
         AND appln.ci_sequence_number  = cp_to_sequence_number
         AND appln.application_code    = cp_application_code
         AND NVL(appln.active_flag,'N')= 'Y';

    l_appln_exists            c_appln_exists%ROWTYPE;

    l_rowid                   VARCHAR2(25);
    E_SKIP_APPLICATION        EXCEPTION;
    l_error_occurred          VARCHAR2(1) := 'N';
    l_to_ld_cal_type          igs_ca_inst_all.cal_type%TYPE;
    l_to_ld_sequence_number   igs_ca_inst_all.sequence_number%TYPE;

  BEGIN
    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','INST_APPLICATION')||':' );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_inst_applications.debug','Processing Institutional Applications');
    END IF;

    FOR l_get_appln_code IN c_get_appln_code(p_frm_cal_type, p_frm_sequence_number)
    LOOP
     BEGIN
      SAVEPOINT rollover_inst_applications;

      fnd_message.set_name('IGF','IGF_AP_PROC_INST_APLN');
      fnd_message.set_token('APPLICATION',l_get_appln_code.application_code);
      fnd_file.put_line(fnd_file.log, RPAD(' ',5)|| fnd_message.get);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_inst_applications.debug','Application :'||l_get_appln_code.application_code);
      END IF;

      --Check whether the application already got rolled over
      OPEN c_appln_exists(p_to_cal_type, p_to_sequence_number, l_get_appln_code.application_code);
      FETCH c_appln_exists INTO l_appln_exists;
        IF c_appln_exists%FOUND THEN
          CLOSE c_appln_exists;
          fnd_message.set_name('IGF','IGF_AP_INST_APLN_ALRDY_EXT');
          fnd_message.set_token('APPLICATION',l_get_appln_code.application_code);
          fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_inst_applications.debug','Application already exists');
          END IF;
          RAISE E_SKIP_APPLICATION;
        END IF;
      CLOSE c_appln_exists;

      l_error_occurred  := 'N';

      FOR l_inst_appln_setup IN c_inst_appln_setup(p_frm_cal_type, p_frm_sequence_number, l_get_appln_code.application_code)
      LOOP
        BEGIN
          l_to_ld_cal_type          := NULL;
          l_to_ld_sequence_number   := NULL;

          IF l_inst_appln_setup.ld_cal_type IS NOT NULL AND l_inst_appln_setup.ld_sequence_number IS NOT NULL THEN
            IF NOT chk_calendar_mapping(l_inst_appln_setup.ld_cal_type,l_inst_appln_setup.ld_sequence_number,l_to_ld_cal_type,l_to_ld_sequence_number) THEN
              fnd_message.set_name('IGF','IGF_AP_QUES_TRM_NT_EXISTS');
              fnd_message.set_token('QUESTION',l_inst_appln_setup.question);
              fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(l_inst_appln_setup.ld_cal_type,l_inst_appln_setup.ld_sequence_number));

              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);
              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_inst_applications.debug','Calendar Mapping does not exist');
              END IF;

              l_error_occurred  := 'Y';
            END IF;
          END IF;

          IF l_error_occurred = 'N' THEN
            l_rowid  := NULL;
            l_inst_appln_setup.question_id := NULL;

            --insert into the application setup table
            igf_ap_appl_setup_pkg.insert_row (
              x_mode                              => 'R',
              x_rowid                             => l_rowid,
              x_enabled                           => l_inst_appln_setup.enabled,
              x_org_id                            => l_inst_appln_setup.org_id,
              x_ci_cal_type                       => p_to_cal_type,
              x_ci_sequence_number                => p_to_sequence_number,
              x_question_id                       => l_inst_appln_setup.question_id,
              x_question                          => l_inst_appln_setup.question,
              x_application_code                  => l_inst_appln_setup.application_code,
              x_application_name                  => l_inst_appln_setup.application_name,
              x_active_flag                       => l_inst_appln_setup.active_flag,
              x_answer_type_code                  => l_inst_appln_setup.answer_type_code,
              x_destination_txt                   => l_inst_appln_setup.destination_txt,
              x_ld_cal_type                       => l_to_ld_cal_type,
              x_ld_sequence_number                => l_to_ld_sequence_number,
              x_all_terms_flag                    => l_inst_appln_setup.all_terms_flag,
              x_override_exist_ant_data_flag      => l_inst_appln_setup.override_exist_ant_data_flag,
              x_required_flag                     => l_inst_appln_setup.required_flag,
              x_minimum_value_num                 => l_inst_appln_setup.minimum_value_num,
              x_maximum_value_num                 => l_inst_appln_setup.maximum_value_num,
              x_minimum_date                      => l_inst_appln_setup.minimum_date,
              x_maximium_date                     => l_inst_appln_setup.maximium_date,
              x_lookup_code                       => l_inst_appln_setup.lookup_code,
              x_hint_txt                          => l_inst_appln_setup.hint_txt
              );
          END IF;


        EXCEPTION
          WHEN OTHERS THEN
            l_error_occurred  := 'Y';

            fnd_message.set_name('IGF','IGF_AP_APLN_QUES_ROLL');
            fnd_message.set_token('QUESTION',l_inst_appln_setup.question);
            fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

            IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_inst_applications.exception','Skipping Question ID :'||l_inst_appln_setup.question_id);
            END IF;
        END;
      END LOOP;

      IF l_error_occurred = 'N' THEN
        COMMIT;

        fnd_message.set_name('IGF','IGF_AP_APLN_RLOVR_SUCCFL');
        fnd_message.set_token('APPLICATION',l_get_appln_code.application_code);
        fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_inst_applications.debug','Successfully rolled over Application :'||l_get_appln_code.application_code);
        END IF;
      ELSE
        RAISE E_SKIP_APPLICATION;
      END IF;

     EXCEPTION
      WHEN E_SKIP_APPLICATION THEN
        ROLLBACK TO rollover_inst_applications;

        fnd_message.set_name('IGF','IGF_AP_SKIPPING_INST_APLN');
        fnd_message.set_token('APPLICATION',l_get_appln_code.application_code);
        fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_inst_applications.exception','Skipping the application :'||l_get_appln_code.application_code);
        END IF;

      WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','igf_aw_rollover.rollover_inst_applications :' || SQLERRM);
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_inst_applications.exception','sql error:'||SQLERRM);
        END IF;

        app_exception.raise_exception;
     END;
    END LOOP;
  END rollover_inst_applications;



  -- Procedure to create a new award distribution plan for the target award year
  FUNCTION create_new_plan (  p_plan_rec             IN   igf_aw_awd_dist_plans%ROWTYPE,
                              p_to_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                              p_to_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                           )
                           RETURN igf_aw_awd_dist_plans.adplans_id%TYPE IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 20-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    l_rowid              VARCHAR2(25):= NULL;
    l_adplans_id         igf_aw_awd_dist_plans.adplans_id%TYPE  := NULL;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.create_new_plan.debug','Insert an Award Distribution Plan');
    END IF;

    igf_aw_awd_dist_plans_pkg.insert_row (
        x_mode                              => 'R',
        x_rowid                             => l_rowid,
        x_adplans_id                        => l_adplans_id,
        x_awd_dist_plan_cd                  => p_plan_rec.awd_dist_plan_cd,
        x_cal_type                          => p_to_cal_type,
        x_sequence_number                   => p_to_sequence_number,
        x_awd_dist_plan_cd_desc             => p_plan_rec.awd_dist_plan_cd_desc,
        x_active_flag                       => p_plan_rec.active_flag,
        x_dist_plan_method_code             => p_plan_rec.dist_plan_method_code
    );

    RETURN l_adplans_id;

  END create_new_plan;


  -- Procedure to create a new distribution plan term for the target award year
  FUNCTION create_new_plan_term (  p_adplans_id              IN   igf_aw_awd_dist_plans.adplans_id%TYPE,
                                   p_plan_term_rec           IN   igf_aw_dp_terms%ROWTYPE,
                                   p_to_ld_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                                   p_to_ld_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                                )
                                RETURN igf_aw_dp_terms.adterms_id%TYPE IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 20-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    l_rowid              VARCHAR2(25):= NULL;
    l_adterms_id         igf_aw_dp_terms.adterms_id%TYPE  := NULL;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.create_new_plan_term.debug','Insert term attached to the plan');
    END IF;

    igf_aw_dp_terms_pkg.insert_row (
        x_mode                              => 'R',
        x_rowid                             => l_rowid,
        x_adterms_id                        => l_adterms_id,
        x_adplans_id                        => p_adplans_id,
        x_ld_cal_type                       => p_to_ld_cal_type,
        x_ld_sequence_number                => p_to_ld_sequence_number,
        x_ld_perct_num                      => p_plan_term_rec.ld_perct_num
      );

    RETURN l_adterms_id;

  END create_new_plan_term;


  -- Procedure to create a new distribution plan teaching period for the target award year
  FUNCTION create_new_plan_tp (  p_adterms_id              IN   igf_aw_dp_terms.adterms_id%TYPE,
                                 p_plan_tp_rec             IN   igf_aw_dp_teach_prds%ROWTYPE,
                                 p_to_tp_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                                 p_to_tp_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                              )
                              RETURN igf_aw_dp_teach_prds.adteach_id%TYPE IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 20-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    l_rowid              VARCHAR2(25):= NULL;
    l_adteach_id         igf_aw_dp_teach_prds.adteach_id%TYPE  := NULL;

  BEGIN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.create_new_plan_tp.debug','Insert teaching period attached to the term');
    END IF;

    igf_aw_dp_teach_prds_pkg.insert_row (
        x_mode                              => 'R',
        x_rowid                             => l_rowid,
        x_adteach_id                        => l_adteach_id,
        x_adterms_id                        => p_adterms_id,
        x_tp_cal_type                       => p_to_tp_cal_type,
        x_tp_sequence_number                => p_to_tp_sequence_number,
        x_tp_perct_num                      => p_plan_tp_rec.tp_perct_num,
        x_date_offset_cd                    => p_plan_tp_rec.date_offset_cd,
        x_attendance_type_code              => p_plan_tp_rec.attendance_type_code,
        x_credit_points_num                 => p_plan_tp_rec.credit_points_num
      );

    RETURN l_adteach_id;

  END create_new_plan_tp;


  -- Procedure to rollover Award Distribution Plan Setup
  PROCEDURE rollover_distribution_plans ( p_frm_cal_type         IN   igs_ca_inst_all.cal_type%TYPE,
                                          p_frm_sequence_number  IN   igs_ca_inst_all.sequence_number%TYPE,
                                          p_to_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                                          p_to_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                                        )
                                        IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 19-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- Get the Award Distribution Plans for the source award year
    CURSOR c_distb_plan_setup( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                               cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                             ) IS
      SELECT plan.*
        FROM igf_aw_awd_dist_plans plan
       WHERE plan.cal_type         = cp_frm_cal_type
         AND plan.sequence_number  = cp_frm_sequence_number
    ORDER BY plan.awd_dist_plan_cd;

    -- Check whether the fund already exists or not
    CURSOR c_plan_exists( cp_to_cal_type         igs_ca_inst_all.cal_type%TYPE,
                          cp_to_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                          cp_awd_dist_plan_cd    igf_aw_awd_dist_plans.awd_dist_plan_cd%TYPE
                        ) IS
      SELECT 'X' exist
        FROM igf_aw_awd_dist_plans plan
       WHERE plan.cal_type         = cp_to_cal_type
         AND plan.sequence_number  = cp_to_sequence_number
         AND plan.awd_dist_plan_cd = cp_awd_dist_plan_cd;

    l_plan_exists       c_plan_exists%ROWTYPE;

    -- Get the Award Distribution Plan Terms attached to the Plan Id
    CURSOR c_distb_plan_term( cp_adplans_id    igf_aw_awd_dist_plans.adplans_id%TYPE
                            ) IS
      SELECT plan_term.*
        FROM igf_aw_dp_terms plan_term
       WHERE plan_term.adplans_id     = cp_adplans_id
    ORDER BY plan_term.adterms_id;


    -- Get the Award Distribution Plan Teaching Periods attached to the Plan Term Id
    CURSOR c_distb_plan_tp( cp_adterms_id    igf_aw_dp_terms.adterms_id%TYPE
                           ) IS
      SELECT plan_tp.*
        FROM igf_aw_dp_teach_prds plan_tp
       WHERE plan_tp.adterms_id     = cp_adterms_id
    ORDER BY plan_tp.adteach_id;


    l_to_ld_cal_type          igs_ca_inst_all.cal_type%TYPE;
    l_to_ld_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
    l_to_tp_cal_type          igs_ca_inst_all.cal_type%TYPE;
    l_to_tp_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
    l_rowid                   VARCHAR2(25);
    l_new_plan_id             igf_aw_awd_dist_plans.adplans_id%TYPE := NULL;
    l_adterms_id              igf_aw_dp_terms.adterms_id%TYPE       := NULL;
    l_adteach_id              igf_aw_dp_teach_prds.adteach_id%TYPE  := NULL;
    E_SKIP_PLAN               EXCEPTION;
    l_error_occurred          VARCHAR2(1) := 'N';

  BEGIN

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWD_DISTRIBUTION_PLAN')||':' );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_distribution_plans.debug','Processing Award Distribution Plans');
    END IF;


    FOR l_distb_plan_setup IN c_distb_plan_setup(p_frm_cal_type, p_frm_sequence_number)
    LOOP
        BEGIN
          SAVEPOINT rollover_distribution_plans;

          fnd_message.set_name('IGF','IGF_AW_PROC_DIST_PLAN');
          fnd_message.set_token('PLAN',l_distb_plan_setup.awd_dist_plan_cd);
          fnd_file.put_line(fnd_file.log, RPAD(' ',5)|| fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_distribution_plans.debug','Distribution Plan :'||l_distb_plan_setup.awd_dist_plan_cd);
          END IF;

          --Check whether the distribution plan already got rolled over or not
          OPEN c_plan_exists(p_to_cal_type, p_to_sequence_number, l_distb_plan_setup.awd_dist_plan_cd);
          FETCH c_plan_exists INTO l_plan_exists;
            IF c_plan_exists%FOUND THEN
              CLOSE c_plan_exists;
              fnd_message.set_name('IGF','IGF_AW_PLN_ALRDY_EXISTS');
              fnd_message.set_token('PLAN',l_distb_plan_setup.awd_dist_plan_cd);
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_distribution_plans.debug','Distribution Plan already exists');
              END IF;
              RAISE E_SKIP_PLAN;
            END IF;
          CLOSE c_plan_exists;

          l_error_occurred  := 'N';
          l_new_plan_id     := NULL;
          --Create new award distribution plan for the target award year
          l_new_plan_id := create_new_plan( p_plan_rec            => l_distb_plan_setup,
                                            p_to_cal_type         => p_to_cal_type,
                                            p_to_sequence_number  => p_to_sequence_number
                                          );

          IF l_new_plan_id IS NULL THEN
            RAISE E_SKIP_PLAN;
          ELSE
            --Loop for Plan Terms
            FOR l_distb_plan_term IN c_distb_plan_term(l_distb_plan_setup.adplans_id)
            LOOP
              l_to_ld_cal_type          := NULL;
              l_to_ld_sequence_number   := NULL;

              --chech whether term mapping exists or not
              IF NOT chk_calendar_mapping(l_distb_plan_term.ld_cal_type,l_distb_plan_term.ld_sequence_number,l_to_ld_cal_type,l_to_ld_sequence_number) THEN
                fnd_message.set_name('IGF','IGF_AW_TRM_MAP_NT_FND');
                fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(l_distb_plan_term.ld_cal_type,l_distb_plan_term.ld_sequence_number));
                fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

                l_error_occurred  := 'Y';
              END IF;

              l_adterms_id := NULL;

              IF l_error_occurred = 'N' THEN
                --Create new award distribution plan term for the target award year
                l_adterms_id := create_new_plan_term( p_adplans_id            => l_new_plan_id,
                                                      p_plan_term_rec         => l_distb_plan_term,
                                                      p_to_ld_cal_type        => l_to_ld_cal_type,
                                                      p_to_ld_sequence_number => l_to_ld_sequence_number
                                                    );
              END IF;

              IF l_adterms_id IS NULL AND l_error_occurred = 'N' THEN
                RAISE E_SKIP_PLAN;
              ELSE
                --Loop for Plan Teaching Periods
                FOR l_distb_plan_tp IN c_distb_plan_tp(l_distb_plan_term.adterms_id)
                LOOP
                  l_to_tp_cal_type          := NULL;
                  l_to_tp_sequence_number   := NULL;

                  --chech whether teaching period mapping exists or not
                  IF NOT chk_calendar_mapping(l_distb_plan_tp.tp_cal_type,l_distb_plan_tp.tp_sequence_number,l_to_tp_cal_type,l_to_tp_sequence_number) THEN
                    fnd_message.set_name('IGF','IGF_AW_TP_MAP_NT_FND');
                    fnd_message.set_token('PERIOD',igf_gr_gen.get_alt_code(l_distb_plan_tp.tp_cal_type,l_distb_plan_tp.tp_sequence_number));
                    fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

                    l_error_occurred  := 'Y';
                  END IF;

                  l_adteach_id := NULL;

                  IF l_error_occurred = 'N' THEN
                    --Create new award distribution plan teaching period for the target award year
                    l_adteach_id := create_new_plan_tp( p_adterms_id            => l_adterms_id,
                                                        p_plan_tp_rec           => l_distb_plan_tp,
                                                        p_to_tp_cal_type        => l_to_tp_cal_type,
                                                        p_to_tp_sequence_number => l_to_tp_sequence_number
                                                      );
                  END IF;

                  IF l_adteach_id IS NULL AND l_error_occurred = 'N' THEN
                    RAISE E_SKIP_PLAN;
                  END IF;

                END LOOP; --End of FOR LOOP for Plan Teaching Periods
              END IF;
            END LOOP; --End of FOR LOOP for Plan Terms
          END IF;

          IF l_error_occurred = 'N' THEN
            COMMIT;

            fnd_message.set_name('IGF','IGF_AW_PLN_RLOVR_SUCCFL');
            fnd_message.set_token('PLAN',l_distb_plan_setup.awd_dist_plan_cd);
            fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_distribution_plans.debug','Successfully rolled over distribution plan :'||l_distb_plan_setup.awd_dist_plan_cd);
            END IF;
          ELSE
            RAISE E_SKIP_PLAN;
          END IF;

        EXCEPTION
          WHEN E_SKIP_PLAN THEN
            ROLLBACK TO rollover_distribution_plans;
            fnd_message.set_name('IGF','IGF_AW_SKIPPING_PLAN');
            fnd_message.set_token('PLAN',l_distb_plan_setup.awd_dist_plan_cd);
            fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

            IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_distribution_plans.exception','Skipping the distribution plan :'||l_distb_plan_setup.awd_dist_plan_cd);
            END IF;

          WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','igf_aw_rollover.rollover_distribution_plans :' || SQLERRM);
            IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_distribution_plans.exception','sql error:'||SQLERRM);
            END IF;

            app_exception.raise_exception;
        END;
    END LOOP;
  END rollover_distribution_plans;



  -- Procedure to rollover Cost of Attendance Group Setup
  PROCEDURE rollover_coa_groups ( p_frm_cal_type         IN   igs_ca_inst_all.cal_type%TYPE,
                                  p_frm_sequence_number  IN   igs_ca_inst_all.sequence_number%TYPE,
                                  p_to_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                                  p_to_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                                )
                                IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 20-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- Get the Cost of Attendance Group Setup for the source award year
    CURSOR c_coa_grp_setup( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                            cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                          ) IS
      SELECT coa.*
        FROM igf_aw_coa_group_all coa
       WHERE coa.ci_cal_type         = cp_frm_cal_type
         AND coa.ci_sequence_number  = cp_frm_sequence_number
    ORDER BY coa.coa_code;

    -- check the existence of the COA Group in the target award year
    CURSOR c_coa_grp_exists( cp_to_cal_type         igs_ca_inst_all.cal_type%TYPE,
                             cp_to_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                             cp_coa_code            igf_aw_coa_group_all.coa_code%TYPE
                           ) IS
      SELECT 'X' exist
        FROM igf_aw_coa_group_all coa
       WHERE coa.ci_cal_type         = cp_to_cal_type
         AND coa.ci_sequence_number  = cp_to_sequence_number
         AND coa.coa_code            = cp_coa_code;

    l_coa_grp_exists          c_coa_grp_exists%ROWTYPE;


    -- Get the COA Items attached to the COA Group
    CURSOR c_coa_item( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                       cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                       cp_coa_code             igf_aw_coa_group_all.coa_code%TYPE
                      ) IS
      SELECT coa_item.*
        FROM igf_aw_coa_grp_item_all coa_item
       WHERE coa_item.ci_cal_type         = cp_frm_cal_type
         AND coa_item.ci_sequence_number  = cp_frm_sequence_number
         AND coa_item.coa_code            = cp_coa_code
         AND coa_item.active              = 'Y'
    ORDER BY coa_item.item_code;


    --Check the existence of the COA Item in the rate table
    CURSOR c_coa_itm_exists (cp_cal_type         igs_ca_inst_all.cal_type%TYPE,
                             cp_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                             cp_item_code        igf_aw_coa_rate_det.item_code%TYPE
                            ) IS
      SELECT 'X' exist
        FROM igf_aw_coa_rate_det
       WHERE ci_cal_type         = cp_cal_type
         AND ci_sequence_number  = cp_sequence_number
         AND item_code           = cp_item_code
         AND rownum = 1;

    l_frm_coa_itm_exists     c_coa_itm_exists%ROWTYPE;
    l_to_coa_itm_exists      c_coa_itm_exists%ROWTYPE;


    -- Get the load percentage split up attached to the COA Group
    CURSOR c_ld_coa ( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                      cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                      cp_coa_code             igf_aw_coa_group_all.coa_code%TYPE
                    ) IS
      SELECT ld_coa.*
        FROM igf_aw_coa_ld_all ld_coa
       WHERE ld_coa.ci_cal_type         = cp_frm_cal_type
         AND ld_coa.ci_sequence_number  = cp_frm_sequence_number
         AND ld_coa.coa_code            = cp_coa_code;


    -- Get the overridden items attached to the COA Group
    CURSOR c_overridden_item ( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                               cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                               cp_coa_code             igf_aw_coa_group_all.coa_code%TYPE
                             ) IS
      SELECT over.*
        FROM igf_aw_cit_ld_ovrd_all over
       WHERE over.ci_cal_type         = cp_frm_cal_type
         AND over.ci_sequence_number  = cp_frm_sequence_number
         AND over.coa_code            = cp_coa_code;


    l_rowid                   VARCHAR2(25):= NULL;
    l_to_ld_cal_type          igs_ca_inst_all.cal_type%TYPE;
    l_to_ld_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
    l_coald_id                igf_aw_coa_ld_all.coald_id%TYPE     := NULL;
    l_cldo_id                 igf_aw_cit_ld_ovrd_all.cldo_id%TYPE := NULL;
    E_SKIP_COA_GRP            EXCEPTION;
    l_error_occurred          VARCHAR2(1) := 'N';

  BEGIN

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','COA_GROUP')||':' );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_coa_groups.debug','Processing COA Groups');
    END IF;


    FOR l_coa_grp_setup IN c_coa_grp_setup(p_frm_cal_type, p_frm_sequence_number)
    LOOP
        BEGIN
          SAVEPOINT rollover_coa_groups;

          fnd_message.set_name('IGF','IGF_AW_PROC_COA_GROUP');
          fnd_message.set_token('COA_GROUP',l_coa_grp_setup.coa_code);
          fnd_file.put_line(fnd_file.log, RPAD(' ',5)|| fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_coa_groups.debug','COA Group :'||l_coa_grp_setup.coa_code);
          END IF;


          --Check whether the COA Group already got rolled over or not
          OPEN c_coa_grp_exists(p_to_cal_type, p_to_sequence_number, l_coa_grp_setup.coa_code);
          FETCH c_coa_grp_exists INTO l_coa_grp_exists;
            IF c_coa_grp_exists%FOUND THEN
              CLOSE c_coa_grp_exists;
              fnd_message.set_name('IGF','IGF_AW_COA_GRP_ALRDY_EXISTS');
              fnd_message.set_token('COA_GROUP',l_coa_grp_setup.coa_code);
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_coa_groups.debug','COA Group already exists');
              END IF;

              RAISE E_SKIP_COA_GRP;
            END IF;
          CLOSE c_coa_grp_exists;

          l_rowid   :=  NULL;
          --Create new COA Group for the target award year
          igf_aw_coa_group_pkg.insert_row (
                x_mode                              => 'R',
                x_rowid                             => l_rowid,
                x_coa_code                          => l_coa_grp_setup.coa_code,
                x_ci_cal_type                       => p_to_cal_type,
                x_ci_sequence_number                => p_to_sequence_number,
                x_rule_order                        => NULL,
                x_s_rule_call_cd                    => NULL,
                x_rul_sequence_number               => NULL,
                x_pell_coa                          => NULL,
                x_pell_alt_exp                      => NULL,
                x_coa_grp_desc                      => l_coa_grp_setup.coa_grp_desc
              );

          l_error_occurred  := 'N';

          FOR l_coa_item IN c_coa_item(p_frm_cal_type, p_frm_sequence_number, l_coa_grp_setup.coa_code)
          LOOP

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_coa_groups.debug','COA Item :'||l_coa_item.item_code);
            END IF;

              --check the COA Item in the rate table for the source award year
            --OPEN c_coa_itm_exists(p_frm_cal_type, p_frm_sequence_number, l_coa_item.item_code);
            --FETCH c_coa_itm_exists INTO l_frm_coa_itm_exists;
            IF l_coa_item.default_value IS NULL THEN
              --CLOSE c_coa_itm_exists;

              --If present, check in the rate table for the target award year
              OPEN c_coa_itm_exists(p_to_cal_type, p_to_sequence_number, l_coa_item.item_code);
              FETCH c_coa_itm_exists INTO l_to_coa_itm_exists;

              IF c_coa_itm_exists%NOTFOUND THEN
                fnd_message.set_name('IGF','IGF_AW_RT_SETUP_NT_EXISTS');
                fnd_message.set_token('ITEM',l_coa_item.item_code);
                fnd_message.set_token('AWARD_YEAR',igf_gr_gen.get_alt_code(p_to_cal_type,p_to_sequence_number));
                fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_coa_groups.debug','Rate Setup does not exist in the target award year');
                END IF;

                --l_error_occurred  := 'Y';
              END IF;
              CLOSE c_coa_itm_exists;
            --ELSE
              --CLOSE c_coa_itm_exists;
            END IF; --end of c_chk_coa_itm%FOUND

            IF l_error_occurred = 'N' THEN
              l_rowid  := NULL;
              -- create new COA group items for the target award year
              igf_aw_coa_grp_item_pkg.insert_row (
                    x_mode                              => 'R',
                    x_rowid                             => l_rowid,
                    x_coa_code                          => l_coa_item.coa_code,
                    x_ci_cal_type                       => p_to_cal_type,
                    x_ci_sequence_number                => p_to_sequence_number,
                    x_item_code                         => l_coa_item.item_code,
                    x_default_value                     => l_coa_item.default_value,
                    x_fixed_cost                        => l_coa_item.fixed_cost,
                    x_pell_coa                          => l_coa_item.pell_coa,
                    x_active                            => l_coa_item.active,
                    x_pell_amount                       => l_coa_item.pell_amount,
                    x_pell_alternate_amt                => l_coa_item.pell_alternate_amt,
                    x_item_dist                         => l_coa_item.item_dist,
                    x_lock_flag                         => l_coa_item.lock_flag
                  );
            END IF;

          END LOOP; -- end of FOR l_coa_item IN c_coa_item


          FOR l_ld_coa IN c_ld_coa(p_frm_cal_type, p_frm_sequence_number, l_coa_grp_setup.coa_code)
          LOOP
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_coa_groups.debug','Term attached to the Item');
            END IF;

            l_to_ld_cal_type        := NULL;
            l_to_ld_sequence_number := NULL;

            --chech whether term mapping exists or not
            IF NOT chk_calendar_mapping(l_ld_coa.ld_cal_type,l_ld_coa.ld_sequence_number,l_to_ld_cal_type,l_to_ld_sequence_number) THEN
              fnd_message.set_name('IGF','IGF_AW_TRM_MAP_NT_FND');
              fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(l_ld_coa.ld_cal_type,l_ld_coa.ld_sequence_number));
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

              l_error_occurred  := 'Y';
            END IF;

            IF l_error_occurred = 'N' THEN
              l_rowid := NULL;
              igf_aw_coa_ld_pkg.insert_row (
                    x_mode                              => 'R',
                    x_rowid                             => l_rowid,
                    x_coald_id                          => l_coald_id,
                    x_coa_code                          => l_ld_coa.coa_code,
                    x_ci_cal_type                       => p_to_cal_type,
                    x_ci_sequence_number                => p_to_sequence_number,
                    x_ld_cal_type                       => l_to_ld_cal_type,
                    x_ld_sequence_number                => l_to_ld_sequence_number,
                    x_ld_perct                          => l_ld_coa.ld_perct
                  );
            END IF;
          END LOOP; -- end of FOR l_ld_coa IN c_ld_coa

          FOR l_overridden_item IN c_overridden_item(p_frm_cal_type, p_frm_sequence_number, l_coa_grp_setup.coa_code)
          LOOP
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_coa_groups.debug','Overridden COA Item :'||l_overridden_item.item_code);
            END IF;

            l_to_ld_cal_type        := NULL;
            l_to_ld_sequence_number := NULL;

            --check whether term mapping exists or not
            IF NOT chk_calendar_mapping(l_overridden_item.ld_cal_type,l_overridden_item.ld_sequence_number,l_to_ld_cal_type,l_to_ld_sequence_number) THEN
              --fnd_message.set_name('IGF','IGF_AW_TRM_MAP_NT_FND');
              fnd_message.set_name('IGF','IGF_AW_TRM_NT_EXISTS');
              fnd_message.set_token('ITEM',l_overridden_item.item_code);
              fnd_message.set_token('TERM',igf_gr_gen.get_alt_code(l_overridden_item.ld_cal_type,l_overridden_item.ld_sequence_number));
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

              l_error_occurred  := 'Y';
            END IF;

            IF l_error_occurred = 'N' THEN
              l_rowid   :=  NULL;
              igf_aw_cit_ld_ovrd_pkg.insert_row (
                     x_mode                              => 'R',
                     x_rowid                             => l_rowid,
                     x_cldo_id                           => l_cldo_id,
                     x_coa_code                          => l_overridden_item.coa_code,
                     x_ci_cal_type                       => p_to_cal_type,
                     x_ci_sequence_number                => p_to_sequence_number,
                     x_item_code                         => l_overridden_item.item_code,
                     x_ld_cal_type                       => l_to_ld_cal_type,
                     x_ld_sequence_number                => l_to_ld_sequence_number,
                     x_ld_perct                          => l_overridden_item.ld_perct
                     );
            END IF;

          END LOOP; -- end of FOR l_overridden_item IN c_overridden_item

          IF l_error_occurred = 'N' THEN
            COMMIT;
            fnd_message.set_name('IGF','IGF_AW_COA_GRP_RLOVR_SUCCFL');
            fnd_message.set_token('COA_GROUP',l_coa_grp_setup.coa_code);
            fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_coa_groups.debug','Successfully rolled over coa group :'||l_coa_grp_setup.coa_code);
            END IF;
          ELSE
            RAISE E_SKIP_COA_GRP;
          END IF;

        EXCEPTION
          WHEN E_SKIP_COA_GRP THEN
            ROLLBACK TO rollover_coa_groups;
            fnd_message.set_name('IGF','IGF_AW_SKIPPING_COA_GRP');
            fnd_message.set_token('COA_GROUP',l_coa_grp_setup.coa_code);
            fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

            IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_coa_groups.exception','Skipping the COA group :'||l_coa_grp_setup.coa_code);
            END IF;

          WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','igf_aw_rollover.rollover_coa_groups :' || SQLERRM);
            IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_coa_groups.exception','sql error:'||SQLERRM);
            END IF;

            app_exception.raise_exception;
        END;
    END LOOP;
  END rollover_coa_groups;


  -- Procedure to rollover To Do Item Setup
  PROCEDURE rollover_todo_items ( p_frm_cal_type         IN   igs_ca_inst_all.cal_type%TYPE,
                                  p_frm_sequence_number  IN   igs_ca_inst_all.sequence_number%TYPE,
                                  p_to_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                                  p_to_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                                )
                                IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 23-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- Get the To Do Item details for the source award year
    CURSOR c_todo_item_setup(  cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                               cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                             ) IS
      SELECT todo.*
        FROM igf_ap_td_item_mst_all todo
       WHERE todo.ci_cal_type         = cp_frm_cal_type
         AND todo.ci_sequence_number  = cp_frm_sequence_number
    ORDER BY todo.item_code;

    -- Check whether the todo item already got rolled over or not
    CURSOR c_todo_exists(cp_to_cal_type         igs_ca_inst_all.cal_type%TYPE,
                         cp_to_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                         cp_item_code           igf_ap_td_item_mst_all.item_code%TYPE
                        ) IS
      SELECT 'X' exist
        FROM igf_ap_td_item_mst_all todo
       WHERE todo.ci_cal_type         = cp_to_cal_type
         AND todo.ci_sequence_number  = cp_to_sequence_number
         AND todo.item_code           = cp_item_code;

    l_todo_exists               c_todo_exists%ROWTYPE;

    l_to_ld_cal_type          igs_ca_inst_all.cal_type%TYPE;
    l_to_ld_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
    l_rowid                   VARCHAR2(25):= NULL;
    l_todo_number             igf_ap_td_item_mst_all.todo_number%TYPE;
    E_SKIP_TODO               EXCEPTION;
    lv_return_flg             VARCHAR2(1);

  BEGIN

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','TODO_ITEM')||':' );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_todo_items.debug','Processing To Do Items');
    END IF;


    FOR l_todo_item_setup IN c_todo_item_setup(p_frm_cal_type, p_frm_sequence_number)
    LOOP
        BEGIN
          SAVEPOINT rollover_todo_items;

          fnd_message.set_name('IGF','IGF_AP_PROC_TODO_ITEM');
          fnd_message.set_token('ITEM',l_todo_item_setup.item_code);
          fnd_file.put_line(fnd_file.log, RPAD(' ',5)|| fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_todo_items.debug','To Do Item :'||l_todo_item_setup.item_code);
          END IF;

          --Check whether the todo item already got rolled over
          OPEN c_todo_exists(p_to_cal_type, p_to_sequence_number, l_todo_item_setup.item_code);
          FETCH c_todo_exists INTO l_todo_exists;
            IF c_todo_exists%FOUND THEN
              CLOSE c_todo_exists;
              fnd_message.set_name('IGF','IGF_AP_TODO_ALRDY_EXISTS');
              fnd_message.set_token('ITEM',l_todo_item_setup.item_code);
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_todo_items.debug','To Do Item already exists');
              END IF;

              RAISE E_SKIP_TODO;
            END IF;
          CLOSE c_todo_exists;

          l_rowid := NULL;
          l_todo_number := NULL;
          --insert into the To Do Items table
          igf_ap_td_item_mst_pkg.insert_row (
                x_rowid                             => l_rowid,
                x_todo_number                       => l_todo_number,
                x_item_code                         => l_todo_item_setup.item_code,
                x_ci_cal_type                       => p_to_cal_type,
                x_ci_sequence_number                => p_to_sequence_number,
                x_description                       => l_todo_item_setup.description,
                x_corsp_mesg                        => l_todo_item_setup.corsp_mesg,
                x_career_item                       => l_todo_item_setup.career_item,
                x_required_for_application          => l_todo_item_setup.required_for_application,
                x_freq_attempt                      => l_todo_item_setup.freq_attempt,
                x_max_attempt                       => l_todo_item_setup.max_attempt,
                x_mode                              => 'R',
                x_system_todo_type_code             => l_todo_item_setup.system_todo_type_code,
                x_application_code                  => l_todo_item_setup.application_code,
                x_display_in_ss_flag                => l_todo_item_setup.display_in_ss_flag,
                x_ss_instruction_txt                => l_todo_item_setup.ss_instruction_txt,
                x_allow_attachment_flag             => l_todo_item_setup.allow_attachment_flag,
                x_document_url_txt                  => l_todo_item_setup.document_url_txt
              );

          IF l_todo_item_setup.system_todo_type_code = 'INSTAPP' THEN
             lv_return_flg := rollover_inst_attch_todo (  p_frm_cal_type         => p_frm_cal_type,
                                                          p_frm_sequence_number  => p_frm_sequence_number,
                                                          p_to_cal_type          => p_to_cal_type,
                                                          p_to_sequence_number   => p_to_sequence_number,
                                                          p_application_code     => l_todo_item_setup.application_code
                                                          );

            IF lv_return_flg = 'Y' THEN
              fnd_message.set_name('IGF','IGF_AP_INST_ATTCH_TODO_ERR');
              fnd_message.set_token('APPLICATION',l_todo_item_setup.application_code);
              fnd_message.set_token('ITEM',l_todo_item_setup.item_code);
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

              RAISE E_SKIP_TODO;
            END IF;
          END IF;

          COMMIT;

          fnd_message.set_name('IGF','IGF_AP_TODO_RLOVR_SUCCFL');
          fnd_message.set_token('ITEM',l_todo_item_setup.item_code);
          fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_todo_items.debug','Successfully rolled over To Do Item :'||l_todo_item_setup.item_code);
          END IF;

        EXCEPTION
          WHEN E_SKIP_TODO THEN
              fnd_message.set_name('IGF','IGF_AP_SKIPPING_TODO');
              fnd_message.set_token('ITEM',l_todo_item_setup.item_code);
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

            IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_todo_items.exception','Skipping the To Do Item :'||l_todo_item_setup.item_code);
            END IF;

          WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','igf_aw_rollover.rollover_todo_items :' || SQLERRM);
            IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_todo_items.exception','sql error:'||SQLERRM);
            END IF;

            app_exception.raise_exception;
        END;
    END LOOP;
  END rollover_todo_items;


  --Function to return Award Distribution Plan Code
  FUNCTION get_plan_cd(
                          p_adplans_id        IN   igf_aw_awd_dist_plans.adplans_id%TYPE,
                          p_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                          p_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                         )
                         RETURN igf_aw_awd_dist_plans.awd_dist_plan_cd%TYPE AS
  ------------------------------------------------------------------
  --Created by  : ridas, Oracle India
  --Date created: 24-MAY-2005
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get plan code
  CURSOR c_plan(
                cp_adplans_id           igf_aw_awd_dist_plans.adplans_id%TYPE,
                cp_cal_type             igs_ca_inst_all.cal_type%TYPE,
                cp_sequence_number      igs_ca_inst_all.sequence_number%TYPE
               ) IS
    SELECT awd_dist_plan_cd
      FROM igf_aw_awd_dist_plans
     WHERE adplans_id      = cp_adplans_id
       AND cal_type        = cp_cal_type
       AND sequence_number = cp_sequence_number;

  l_plan c_plan%ROWTYPE;

  BEGIN
    OPEN c_plan(p_adplans_id, p_cal_type, p_sequence_number);
    FETCH c_plan INTO l_plan;
    CLOSE c_plan;

    RETURN l_plan.awd_dist_plan_cd;
  END get_plan_cd;


  --Function to return fund code
  FUNCTION get_fund_cd  (
                          p_fund_id           IN   igf_aw_fund_mast_all.fund_id%TYPE,
                          p_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                          p_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                         )
                         RETURN igf_aw_fund_mast_all.fund_code%TYPE AS
  ------------------------------------------------------------------
  --Created by  : ridas, Oracle India
  --Date created: 24-MAY-2005
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get get fund code
  CURSOR c_fund(
                cp_fund_id              igf_aw_fund_mast_all.fund_id%TYPE,
                cp_cal_type             igs_ca_inst_all.cal_type%TYPE,
                cp_sequence_number      igs_ca_inst_all.sequence_number%TYPE
               ) IS
    SELECT fund_code
      FROM igf_aw_fund_mast_all
     WHERE fund_id            = cp_fund_id
       AND ci_cal_type        = cp_cal_type
       AND ci_sequence_number = cp_sequence_number;

  l_fund c_fund%ROWTYPE;

  BEGIN
    OPEN c_fund(p_fund_id, p_cal_type, p_sequence_number);
    FETCH c_fund INTO l_fund;
    CLOSE c_fund;

    RETURN l_fund.fund_code;
  END get_fund_cd;


  -- Procedure to rollover Award Group Setup
  PROCEDURE rollover_award_groups ( p_frm_cal_type         IN   igs_ca_inst_all.cal_type%TYPE,
                                    p_frm_sequence_number  IN   igs_ca_inst_all.sequence_number%TYPE,
                                    p_to_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                                    p_to_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE
                                  )
                                  IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 23-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- Get the Award Group details for the source award year
    CURSOR c_award_grp_setup(  cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                               cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                             ) IS
      SELECT grp.*
        FROM igf_aw_target_grp_all grp
       WHERE grp.cal_type         = cp_frm_cal_type
         AND grp.sequence_number  = cp_frm_sequence_number
    ORDER BY grp.group_cd;


    -- Check whether the award group already got rolled over or not
    CURSOR c_grp_exists (cp_to_cal_type         igs_ca_inst_all.cal_type%TYPE,
                         cp_to_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                         cp_group_cd            igf_aw_target_grp_all.group_cd%TYPE
                        ) IS
      SELECT 'X' exist
        FROM igf_aw_target_grp_all grp
       WHERE grp.cal_type         = cp_to_cal_type
         AND grp.sequence_number  = cp_to_sequence_number
         AND grp.group_cd         = cp_group_cd;

    l_grp_exists               c_grp_exists%ROWTYPE;


    -- Get the sequence of funds attached to the formulas for the source award year
    CURSOR c_formula_setup(  cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                             cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                             cp_group_cd             igf_aw_target_grp_all.group_cd%TYPE
                          ) IS
      SELECT frm.*
        FROM igf_aw_awd_frml_det_all frm
       WHERE frm.ci_cal_type         = cp_frm_cal_type
         AND frm.ci_sequence_number  = cp_frm_sequence_number
         AND frm.formula_code        = cp_group_cd
    ORDER BY frm.adplans_id;


    -- Check whether the Distribution Plan got rolled over
    CURSOR c_plan_exists (cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                          cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                          cp_to_cal_type          igs_ca_inst_all.cal_type%TYPE,
                          cp_to_sequence_number   igs_ca_inst_all.sequence_number%TYPE,
                          cp_adplans_id           igf_aw_awd_dist_plans.adplans_id%TYPE
                        ) IS
      SELECT plan.adplans_id
        FROM igf_aw_awd_dist_plans plan
       WHERE plan.cal_type         = cp_to_cal_type
         AND plan.sequence_number  = cp_to_sequence_number
         AND plan.awd_dist_plan_cd  IN
                      ( SELECT plan_cd.awd_dist_plan_cd
                          FROM igf_aw_awd_dist_plans plan_cd
                         WHERE plan_cd.cal_type        = cp_frm_cal_type
                           AND plan_cd.sequence_number = cp_frm_sequence_number
                           AND plan_cd.adplans_id      = cp_adplans_id
                      );

    l_plan_exists             c_plan_exists%ROWTYPE;


    -- Check whether the Funds got rolled over
    CURSOR c_fund_exists (cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                          cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                          cp_to_cal_type          igs_ca_inst_all.cal_type%TYPE,
                          cp_to_sequence_number   igs_ca_inst_all.sequence_number%TYPE,
                          cp_fund_id              igf_aw_fund_mast_all.fund_id%TYPE
                        ) IS
      SELECT fnd.fund_id
        FROM igf_aw_fund_mast_all fnd
       WHERE fnd.ci_cal_type         = cp_to_cal_type
         AND fnd.ci_sequence_number  = cp_to_sequence_number
         AND fnd.fund_code    IN
                      ( SELECT fnd_cd.fund_code
                          FROM igf_aw_fund_mast_all fnd_cd
                         WHERE fnd_cd.ci_cal_type        = cp_frm_cal_type
                           AND fnd_cd.ci_sequence_number = cp_frm_sequence_number
                           AND fnd_cd.fund_id            = cp_fund_id
                      );

    l_fund_exists             c_fund_exists%ROWTYPE;


    l_to_ld_cal_type          igs_ca_inst_all.cal_type%TYPE;
    l_to_ld_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
    l_rowid                   VARCHAR2(25):= NULL;
    l_tgrp_id                 igf_aw_target_grp_all.tgrp_id%TYPE;
    E_SKIP_AWARD_GRP          EXCEPTION;
    l_error_occurred          VARCHAR2(1) := 'N';
    l_adplans_id              igf_aw_awd_dist_plans.adplans_id%TYPE := NULL;

  BEGIN

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWD_GROUP')||':' );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_award_groups.debug','Processing Award Groups');
    END IF;

    FOR l_award_grp_setup IN c_award_grp_setup(p_frm_cal_type, p_frm_sequence_number)
    LOOP
        BEGIN
          SAVEPOINT rollover_award_groups;
          l_error_occurred := 'N';

          fnd_message.set_name('IGF','IGF_AW_PROC_AWD_GROUP');
          fnd_message.set_token('AWD_GROUP',l_award_grp_setup.group_cd);
          fnd_file.put_line(fnd_file.log, RPAD(' ',5)|| fnd_message.get);

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_award_groups.debug','Award Group :'||l_award_grp_setup.group_cd);
          END IF;


          --Check whether the award group already got rolled over
          OPEN c_grp_exists(p_to_cal_type, p_to_sequence_number, l_award_grp_setup.group_cd);
          FETCH c_grp_exists INTO l_grp_exists;
            IF c_grp_exists%FOUND THEN
              CLOSE c_grp_exists;
              fnd_message.set_name('IGF','IGF_AW_AWD_GRP_ALRDY_EXISTS');
              fnd_message.set_token('AWD_GROUP',l_award_grp_setup.group_cd);
              fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

              IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_award_groups.debug','Award Group already exists');
              END IF;

              RAISE E_SKIP_AWARD_GRP;
            END IF;
          CLOSE c_grp_exists;

          l_plan_exists := NULL;

          IF l_award_grp_setup.adplans_id IS NOT NULL THEN
            --Check the existence of the distribution plan in the target award year
            OPEN c_plan_exists(p_frm_cal_type, p_frm_sequence_number, p_to_cal_type, p_to_sequence_number, l_award_grp_setup.adplans_id);
            FETCH c_plan_exists INTO l_plan_exists;
              IF c_plan_exists%NOTFOUND THEN
                fnd_message.set_name('IGF','IGF_AW_DIST_PLN_NT_EXISTS');
                fnd_message.set_token('PLAN',get_plan_cd(l_award_grp_setup.adplans_id, p_frm_cal_type, p_frm_sequence_number));
                fnd_message.set_token('AWARD_YEAR',igf_gr_gen.get_alt_code(p_to_cal_type,p_to_sequence_number));
                fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_award_groups.debug','Distribution Plan does not exist');
                END IF;

                l_error_occurred := 'Y';
              END IF;
            CLOSE c_plan_exists;
          END IF;

          IF l_error_occurred = 'N' THEN
            l_rowid   := NULL;
            l_tgrp_id := NULL;

            --insert into the Award Groups table
            igf_aw_target_grp_pkg.insert_row (
                  x_mode                              => 'R',
                  x_rowid                             => l_rowid,
                  x_group_cd                          => l_award_grp_setup.group_cd,
                  x_description                       => l_award_grp_setup.description,
                  x_active                            => l_award_grp_setup.active,
                  x_max_grant_amt                     => l_award_grp_setup.max_grant_amt,
                  x_max_grant_perct                   => l_award_grp_setup.max_grant_perct,
                  x_max_grant_perct_fact              => l_award_grp_setup.max_grant_perct_fact,
                  x_max_loan_amt                      => l_award_grp_setup.max_loan_amt,
                  x_max_loan_perct                    => l_award_grp_setup.max_loan_perct,
                  x_max_loan_perct_fact               => l_award_grp_setup.max_loan_perct_fact,
                  x_max_work_amt                      => l_award_grp_setup.max_work_amt,
                  x_max_work_perct                    => l_award_grp_setup.max_work_perct,
                  x_max_work_perct_fact               => l_award_grp_setup.max_work_perct_fact,
                  x_max_shelp_amt                     => l_award_grp_setup.max_shelp_amt,
                  x_max_shelp_perct                   => l_award_grp_setup.max_shelp_perct,
                  x_max_shelp_perct_fact              => l_award_grp_setup.max_shelp_perct_fact,
                  x_max_gap_amt                       => l_award_grp_setup.max_gap_amt,
                  x_max_gap_perct                     => l_award_grp_setup.max_gap_perct,
                  x_max_gap_perct_fact                => l_award_grp_setup.max_gap_perct_fact,
                  x_use_fixed_costs                   => l_award_grp_setup.use_fixed_costs,
                  x_max_aid_pkg                       => l_award_grp_setup.max_aid_pkg,
                  x_max_gift_amt                      => l_award_grp_setup.max_gift_amt,
                  x_max_gift_perct                    => l_award_grp_setup.max_gift_perct,
                  x_max_gift_perct_fact               => l_award_grp_setup.max_gift_perct_fact,
                  x_max_schlrshp_amt                  => l_award_grp_setup.max_schlrshp_amt,
                  x_max_schlrshp_perct                => l_award_grp_setup.max_schlrshp_perct,
                  x_max_schlrshp_perct_fact           => l_award_grp_setup.max_schlrshp_perct_fact,
                  x_cal_type                          => p_to_cal_type,
                  x_sequence_number                   => p_to_sequence_number,
                  x_rule_order                        => l_award_grp_setup.rule_order,
                  x_s_rule_call_cd                    => l_award_grp_setup.s_rule_call_cd,
                  x_rul_sequence_number               => l_award_grp_setup.rul_sequence_number,
                  x_tgrp_id                           => l_tgrp_id,
                  x_adplans_id                        => l_plan_exists.adplans_id
                );
          END IF;

          l_adplans_id  := NULL;

          -- Get the sequence of funds attached to the formula
          FOR l_formula_setup IN c_formula_setup(p_frm_cal_type, p_frm_sequence_number, l_award_grp_setup.group_cd)
          LOOP
            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_award_groups.debug','Formula Code :'||l_formula_setup.formula_code);
            END IF;

            --Check the existence of the FUND in the target award year
            OPEN c_fund_exists(p_frm_cal_type, p_frm_sequence_number, p_to_cal_type, p_to_sequence_number, l_formula_setup.fund_id);
            FETCH c_fund_exists INTO l_fund_exists;
              IF c_fund_exists%NOTFOUND THEN
                fnd_message.set_name('IGF','IGF_AW_FUND_NT_EXISTS');
                fnd_message.set_token('FUND',get_fund_cd(l_formula_setup.fund_id, p_frm_cal_type, p_frm_sequence_number));
                fnd_message.set_token('AWARD_YEAR',igf_gr_gen.get_alt_code(p_to_cal_type,p_to_sequence_number));
                fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

                IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                  fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_award_groups.debug','Fund does not exist');
                END IF;

                l_error_occurred := 'Y';
              END IF;
            CLOSE c_fund_exists;

            l_plan_exists := NULL;

            IF l_formula_setup.adplans_id IS NOT NULL AND NVL(l_adplans_id,0) <> NVL(l_formula_setup.adplans_id,0) THEN
              --Check the existence of the distribution plan in the target award year
              OPEN c_plan_exists(p_frm_cal_type, p_frm_sequence_number, p_to_cal_type, p_to_sequence_number, l_formula_setup.adplans_id);
              FETCH c_plan_exists INTO l_plan_exists;
                IF c_plan_exists%NOTFOUND THEN
                  fnd_message.set_name('IGF','IGF_AW_DIST_PLN_OVR_NT_EXISTS');
                  fnd_message.set_token('PLAN',get_plan_cd(l_formula_setup.adplans_id, p_frm_cal_type, p_frm_sequence_number));
                  fnd_message.set_token('AWARD_YEAR',igf_gr_gen.get_alt_code(p_to_cal_type,p_to_sequence_number));
                  fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_award_groups.debug','Award Distribution Plan does not exist');
                  END IF;

                  l_error_occurred := 'Y';
                END IF;
              CLOSE c_plan_exists;
            END IF;

            l_adplans_id := l_formula_setup.adplans_id;

            IF l_error_occurred = 'N' THEN
              l_rowid := NULL;
              --Insert the sequence of funds for the award group
              igf_aw_awd_frml_det_pkg.insert_row (
                    x_mode                              => 'R',
                    x_rowid                             => l_rowid,
                    x_formula_code                      => l_formula_setup.formula_code,
                    x_fund_id                           => l_fund_exists.fund_id,
                    x_min_award_amt                     => l_formula_setup.min_award_amt,
                    x_max_award_amt                     => l_formula_setup.max_award_amt,
                    x_seq_no                            => l_formula_setup.seq_no,
                    x_ci_cal_type                       => p_to_cal_type,
                    x_ci_sequence_number                => p_to_sequence_number,
                    x_replace_fc                        => l_formula_setup.replace_fc,
                    x_pe_group_id                       => l_formula_setup.pe_group_id,
                    x_adplans_id                        => l_plan_exists.adplans_id,
                    x_lock_award_flag                   => l_formula_setup.lock_award_flag
                 );

            END IF;

          END LOOP;

          IF l_error_occurred = 'N' THEN
            COMMIT;

            fnd_message.set_name('IGF','IGF_AW_AWD_GRP_RLOVR_SUCCFL');
            fnd_message.set_token('AWD_GROUP',l_award_grp_setup.group_cd);
            fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_award_groups.debug','Successfully rolled over award group :'||l_award_grp_setup.group_cd);
            END IF;
          ELSE
            RAISE E_SKIP_AWARD_GRP;
          END IF;

        EXCEPTION
          WHEN E_SKIP_AWARD_GRP THEN
            ROLLBACK TO rollover_award_groups;
            fnd_message.set_name('IGF','IGF_AW_SKIPPING_AWD_GRP');
            fnd_message.set_token('AWD_GROUP',l_award_grp_setup.group_cd);
            fnd_file.put_line(fnd_file.log, RPAD(' ',10)|| fnd_message.get);

            IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
               fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_award_groups.exception','Skipping the Award Group :'||l_award_grp_setup.group_cd);
            END IF;

          WHEN OTHERS THEN
            fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
            fnd_message.set_token('NAME','igf_aw_rollover.rollover_award_groups :' || SQLERRM);
            IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_award_groups.exception','sql error:'||SQLERRM);
            END IF;

            app_exception.raise_exception;
        END;
    END LOOP;
  END rollover_award_groups;


  -- Procedure to rollover Institutional Application Setup attached to TO DO item
  FUNCTION  rollover_inst_attch_todo (  p_frm_cal_type         IN   igs_ca_inst_all.cal_type%TYPE,
                                        p_frm_sequence_number  IN   igs_ca_inst_all.sequence_number%TYPE,
                                        p_to_cal_type          IN   igs_ca_inst_all.cal_type%TYPE,
                                        p_to_sequence_number   IN   igs_ca_inst_all.sequence_number%TYPE,
                                        p_application_code     IN   igf_ap_appl_setup_all.application_code%TYPE
                                        )
                                        RETURN VARCHAR IS
  --------------------------------------------------------------------------------
  -- Created by  : ridas, Oracle India
  -- Date created: 20-OCT-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    -- Get the institutional application setup details for the source award year
    CURSOR c_inst_appln_setup( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                               cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                               cp_application_code     igf_ap_appl_setup_all.application_code%TYPE
                             ) IS
      SELECT appln.*
        FROM igf_ap_appl_setup_all appln
       WHERE appln.ci_cal_type         = cp_frm_cal_type
         AND appln.ci_sequence_number  = cp_frm_sequence_number
         AND appln.application_code    = cp_application_code
         AND NVL(appln.active_flag,'N')= 'Y'
    ORDER BY appln.question_id;


    -- Check whether the application exists or not
    CURSOR c_appln_exists( cp_to_cal_type         igs_ca_inst_all.cal_type%TYPE,
                           cp_to_sequence_number  igs_ca_inst_all.sequence_number%TYPE,
                           cp_application_code    igf_ap_appl_setup_all.application_code%TYPE
                         ) IS
      SELECT 'X' exist
        FROM igf_ap_appl_setup_all appln
       WHERE appln.ci_cal_type         = cp_to_cal_type
         AND appln.ci_sequence_number  = cp_to_sequence_number
         AND appln.application_code    = cp_application_code
         AND NVL(appln.active_flag,'N')= 'Y';

    l_appln_exists            c_appln_exists%ROWTYPE;

    l_rowid                   VARCHAR2(25);
    E_SKIP_APPLICATION        EXCEPTION;
    l_error_occurred          VARCHAR2(1) := 'N';
    l_to_ld_cal_type          igs_ca_inst_all.cal_type%TYPE;
    l_to_ld_sequence_number   igs_ca_inst_all.sequence_number%TYPE;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_inst_attch_todo.debug','Processing Institutional Applications');
    END IF;

    SAVEPOINT rollover_inst_attch_todo;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_inst_attch_todo.debug','Application :'||p_application_code);
    END IF;

    --Check whether the application already got rolled over
    OPEN c_appln_exists(p_to_cal_type, p_to_sequence_number, p_application_code);
    FETCH c_appln_exists INTO l_appln_exists;
      IF c_appln_exists%FOUND THEN
        CLOSE c_appln_exists;

        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_inst_attch_todo.debug','Application already exists');
        END IF;
        RETURN 'N';
      END IF;
    CLOSE c_appln_exists;


    FOR l_inst_appln_setup IN c_inst_appln_setup(p_frm_cal_type, p_frm_sequence_number, p_application_code)
    LOOP
      BEGIN
        l_to_ld_cal_type          := NULL;
        l_to_ld_sequence_number   := NULL;

        IF l_inst_appln_setup.ld_cal_type IS NOT NULL AND l_inst_appln_setup.ld_sequence_number IS NOT NULL THEN
          IF NOT chk_calendar_mapping(l_inst_appln_setup.ld_cal_type,l_inst_appln_setup.ld_sequence_number,l_to_ld_cal_type,l_to_ld_sequence_number) THEN

            IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
              fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_inst_attch_todo.debug','Calendar Mapping does not exist');
            END IF;

            l_error_occurred  := 'Y';
          END IF;
        END IF;

        IF l_error_occurred = 'N' THEN
          l_rowid  := NULL;
          l_inst_appln_setup.question_id := NULL;

          --insert into the application setup table
          igf_ap_appl_setup_pkg.insert_row (
            x_mode                              => 'R',
            x_rowid                             => l_rowid,
            x_enabled                           => l_inst_appln_setup.enabled,
            x_org_id                            => l_inst_appln_setup.org_id,
            x_ci_cal_type                       => p_to_cal_type,
            x_ci_sequence_number                => p_to_sequence_number,
            x_question_id                       => l_inst_appln_setup.question_id,
            x_question                          => l_inst_appln_setup.question,
            x_application_code                  => l_inst_appln_setup.application_code,
            x_application_name                  => l_inst_appln_setup.application_name,
            x_active_flag                       => l_inst_appln_setup.active_flag,
            x_answer_type_code                  => l_inst_appln_setup.answer_type_code,
            x_destination_txt                   => l_inst_appln_setup.destination_txt,
            x_ld_cal_type                       => l_to_ld_cal_type,
            x_ld_sequence_number                => l_to_ld_sequence_number,
            x_all_terms_flag                    => l_inst_appln_setup.all_terms_flag,
            x_override_exist_ant_data_flag      => l_inst_appln_setup.override_exist_ant_data_flag,
            x_required_flag                     => l_inst_appln_setup.required_flag,
            x_minimum_value_num                 => l_inst_appln_setup.minimum_value_num,
            x_maximum_value_num                 => l_inst_appln_setup.maximum_value_num,
            x_minimum_date                      => l_inst_appln_setup.minimum_date,
            x_maximium_date                     => l_inst_appln_setup.maximium_date,
            x_lookup_code                       => l_inst_appln_setup.lookup_code,
            x_hint_txt                          => l_inst_appln_setup.hint_txt
            );
        END IF;


      EXCEPTION
        WHEN OTHERS THEN
          l_error_occurred  := 'Y';

          IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
             fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_inst_attch_todo.exception','Skipping Question ID :'||l_inst_appln_setup.question_id);
          END IF;
      END;
    END LOOP;

    IF l_error_occurred = 'N' THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.rollover_inst_attch_todo.debug','Successfully rolled over Application :'||p_application_code);
      END IF;

      RETURN 'N';
    ELSE
      RAISE E_SKIP_APPLICATION;
    END IF;

  EXCEPTION
   WHEN E_SKIP_APPLICATION THEN
    ROLLBACK TO rollover_inst_attch_todo;

    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_inst_attch_todo.exception','Skipping the application :'||p_application_code);
    END IF;

    RETURN 'Y';

   WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_aw_rollover.rollover_inst_attch_todo :' || SQLERRM);
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_aw_rollover.rollover_inst_attch_todo.exception','sql error:'||SQLERRM);
    END IF;
    app_exception.raise_exception;

  END rollover_inst_attch_todo;


 PROCEDURE main(
                 errbuf                OUT NOCOPY  VARCHAR2,
                 retcode               OUT NOCOPY  NUMBER,
                 p_frm_award_year      IN  VARCHAR2,
                 p_fund_attribute      IN  VARCHAR2,
                 p_org_id              IN  igf_aw_award_all.org_id%TYPE,
                 p_rate_table          IN  VARCHAR2,
                 p_inst_application    IN  VARCHAR2,
                 p_distribution_plan   IN  VARCHAR2,
                 p_coa_group           IN  VARCHAR2,
                 p_todo                IN  VARCHAR2,
                 p_award_grp           IN  VARCHAR2
               ) IS
  --------------------------------------------------------------------------------
  -- This is the main procedure which is called by the concurrent process
  -- 'Rollover Financial Aid Setups'.
  --
  -- Created by  : ridas, Oracle India
  -- Date created: 12-MAY-2005

  -- Change History:
  -- Who         When            What
  --
  --------------------------------------------------------------------------------

    --Cursor to fetch To Award Year
    CURSOR c_get_to_awdyr( cp_frm_cal_type         igs_ca_inst_all.cal_type%TYPE,
                           cp_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE
                         ) IS
      SELECT  sc_cal_type,
              sc_sequence_number,
              sc_alternate_code
      FROM    igf_aw_cal_rel_v
      WHERE   cr_cal_type         = cp_frm_cal_type
        AND   cr_sequence_number  = cp_frm_sequence_number
        AND   NVL(active,'N') =  'Y';

    l_get_to_awdyr    c_get_to_awdyr%ROWTYPE;

    lv_frm_cal_type         igs_ca_inst_all.cal_type%TYPE;
    ln_frm_sequence_number  igs_ca_inst_all.sequence_number%TYPE;
    lv_to_cal_type          igs_ca_inst_all.cal_type%TYPE;
    ln_to_sequence_number   igs_ca_inst_all.sequence_number%TYPE;
    lv_to_award_year        igs_ca_inst_all.alternate_code%TYPE;
    to_awdyr_exception      EXCEPTION;

 BEGIN

    igf_aw_gen.set_org_id(NULL);

    retcode                 := 0;
    errbuf                  := NULL;
    lv_frm_cal_type         := LTRIM(RTRIM(SUBSTR(p_frm_award_year,1,10)));
    ln_frm_sequence_number  := TO_NUMBER(SUBSTR(p_frm_award_year,11));

    --get To Award year
    OPEN  c_get_to_awdyr(lv_frm_cal_type, ln_frm_sequence_number);
    FETCH c_get_to_awdyr INTO l_get_to_awdyr;

    IF c_get_to_awdyr%FOUND THEN
      lv_to_cal_type          := l_get_to_awdyr.sc_cal_type;
      ln_to_sequence_number   := l_get_to_awdyr.sc_sequence_number;
      lv_to_award_year        := l_get_to_awdyr.sc_alternate_code;
    ELSE
      RAISE to_awdyr_exception;
    END IF;
    CLOSE c_get_to_awdyr;


    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','p_frm_award_year:'||p_frm_award_year);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','p_to_award_year:'||lv_to_award_year);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','p_fund_attribute:'||p_fund_attribute);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','p_rate_table:'||p_rate_table);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','p_inst_application:'||p_inst_application);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','p_distribution_plan:'||p_distribution_plan);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','p_coa_group:'||p_coa_group);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','p_todo:'||p_todo);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','p_award_grp:'||p_award_grp);
    END IF;

    fnd_file.new_line(fnd_file.log,1);

    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PARAMETER_PASS'));
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','FROM_AWD_YEAR'),60) || igf_gr_gen.get_alt_code(lv_frm_cal_type,ln_frm_sequence_number));
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','TO_AWD_YEAR'),60) || igf_gr_gen.get_alt_code(lv_to_cal_type,ln_to_sequence_number));

    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','FUND_ATTRIBUTE'),60) ||p_fund_attribute );
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','COA_RATE_TABLE'),60) ||p_rate_table );
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','INST_APPLICATION'),60) ||p_inst_application );
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWD_DISTRIBUTION_PLAN'),60) ||p_distribution_plan );
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','COA_GROUP'),60) ||p_coa_group );
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','TODO_ITEM'),60) ||p_todo );
    fnd_file.put_line(fnd_file.log,RPAD(igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWD_GROUP'),60) ||p_award_grp );

    fnd_file.new_line(fnd_file.log,2);

    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------');


    -- Rollover Fund Attribute Setup
    IF NVL(p_fund_attribute,'N') = 'Y' THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','Calling Fund rollover sub-process');
      END IF;

      rollover_fund_attributes( p_frm_cal_type        => lv_frm_cal_type,
                                p_frm_sequence_number => ln_frm_sequence_number,
                                p_to_cal_type         => lv_to_cal_type,
                                p_to_sequence_number  => ln_to_sequence_number
                              );
    END IF;

    -- Rollover Cost of Attendance Rate Table Setup
    IF NVL(p_rate_table,'N') = 'Y' THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','Calling Cost of Attendance Rate Table rollover sub-process');
      END IF;

      rollover_rate_setups( p_frm_cal_type        => lv_frm_cal_type,
                            p_frm_sequence_number => ln_frm_sequence_number,
                            p_to_cal_type         => lv_to_cal_type,
                            p_to_sequence_number  => ln_to_sequence_number
                          );
    END IF;


    -- Rollover Institutional Application Setup
    IF NVL(p_inst_application,'N') = 'Y' THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','Calling Institutional Application rollover sub-process');
      END IF;


      rollover_inst_applications( p_frm_cal_type        => lv_frm_cal_type,
                                  p_frm_sequence_number => ln_frm_sequence_number,
                                  p_to_cal_type         => lv_to_cal_type,
                                  p_to_sequence_number  => ln_to_sequence_number
                                );
    END IF;


    -- Rollover Award Distribution Plan Setup
    IF NVL(p_distribution_plan,'N') = 'Y' THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','Calling Award Distribution Plan rollover sub-process');
      END IF;

      rollover_distribution_plans(p_frm_cal_type        => lv_frm_cal_type,
                                  p_frm_sequence_number => ln_frm_sequence_number,
                                  p_to_cal_type         => lv_to_cal_type,
                                  p_to_sequence_number  => ln_to_sequence_number
                                 );
    END IF;

    -- Rollover Cost of Attendance Group Setup
    IF NVL(p_coa_group,'N') = 'Y' THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','Calling Cost of Attendance Group rollover sub-process');
      END IF;

      rollover_coa_groups(p_frm_cal_type        => lv_frm_cal_type,
                          p_frm_sequence_number => ln_frm_sequence_number,
                          p_to_cal_type         => lv_to_cal_type,
                          p_to_sequence_number  => ln_to_sequence_number
                         );
    END IF;

    -- Rollover To Do Item Setup
    IF NVL(p_todo,'N') = 'Y' THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','Calling To Do Item rollover sub-process');
      END IF;

      rollover_todo_items(p_frm_cal_type        =>  lv_frm_cal_type,
                          p_frm_sequence_number =>  ln_frm_sequence_number,
                          p_to_cal_type         =>  lv_to_cal_type,
                          p_to_sequence_number  =>  ln_to_sequence_number
                         );
    END IF;

    -- Rollover Award Group Setup
    IF NVL(p_award_grp,'N') = 'Y' THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_aw_rollover.main.debug','Calling Award Group rollover sub-process');
      END IF;

      rollover_award_groups(p_frm_cal_type        => lv_frm_cal_type,
                            p_frm_sequence_number => ln_frm_sequence_number,
                            p_to_cal_type         => lv_to_cal_type,
                            p_to_sequence_number  => ln_to_sequence_number
                           );
    END IF;


    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log,'-------------------------------------------------------');

    COMMIT;

 EXCEPTION
    WHEN to_awdyr_exception THEN
      retcode:=2;
      fnd_message.set_name('IGF','IGF_AW_AWD_NT_EXISTS');
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

END igf_aw_rollover;

/
