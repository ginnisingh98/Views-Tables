--------------------------------------------------------
--  DDL for Package Body IGS_GR_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_GEN_001" AS
/* $Header: IGSGR13B.pls 120.3 2006/02/21 01:00:29 sepalani noship $ */
  --
  g_module_head CONSTANT VARCHAR2(40) := 'igs.plsql.igs_gr_gen_001.';
  --
  -- Deletes the Graduand Award Ceremony History records.
  --
  FUNCTION grdp_del_gac_hist (
    p_person_id                    IN     igs_gr_awd_crmn.person_id%TYPE,
    p_create_dt                    IN     igs_gr_awd_crmn.create_dt%TYPE,
    p_grd_cal_type                 IN     igs_gr_awd_crmn.grd_cal_type%TYPE,
    p_grd_ci_sequence_number       IN     igs_gr_awd_crmn.grd_ci_sequence_number%TYPE,
    p_ceremony_number              IN     igs_gr_awd_crmn.ceremony_number%TYPE,
    p_award_course_cd              IN     igs_gr_awd_crmn.award_course_cd%TYPE,
    p_award_crs_version_number     IN     igs_gr_awd_crmn.award_crs_version_number%TYPE,
    p_award_cd                     IN     igs_gr_awd_crmn.award_cd%TYPE,
    p_message_name                 OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN AS
  BEGIN -- grdp_del_gac_hist
    --
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_procedure, g_module_head || 'grdp_del_gac_hist.begin',
        'In Params: p_person_id=>' || p_person_id || ';' ||
        'p_create_dt=>' || p_create_dt || ';' ||
        'p_grd_cal_type=>' || p_grd_cal_type || ';' ||
        'p_grd_ci_sequence_number=>' || p_grd_ci_sequence_number || ';' ||
        'p_ceremony_number=>' || p_ceremony_number || ';' ||
        'p_award_course_cd=>' || p_award_course_cd || ';' ||
        'p_award_crs_version_number=>' || p_award_crs_version_number || ';' ||
        'p_award_cd=>' || p_award_cd || ';'
      );
    END IF;
    --
    DECLARE
      CURSOR c_gach (
        cp_person_id                          igs_gr_awd_crmn.person_id%TYPE,
        cp_create_dt                          igs_gr_awd_crmn.create_dt%TYPE,
        cp_grd_cal_type                       igs_gr_awd_crmn.grd_cal_type%TYPE,
        cp_grd_ci_sequence_number             igs_gr_awd_crmn.grd_ci_sequence_number%TYPE,
        cp_ceremony_number                    igs_gr_awd_crmn.ceremony_number%TYPE,
        cp_award_course_cd                    igs_gr_awd_crmn.award_course_cd%TYPE,
        cp_award_crs_version_number           igs_gr_awd_crmn.award_crs_version_number%TYPE,
        cp_award_cd                           igs_gr_awd_crmn.award_cd%TYPE
      ) IS
        SELECT person_id
        FROM   igs_gr_awd_crmn_hist
        WHERE  person_id = cp_person_id
        AND    create_dt = cp_create_dt
        AND    grd_cal_type = cp_grd_cal_type
        AND    grd_ci_sequence_number = cp_grd_ci_sequence_number
        AND    ceremony_number = cp_ceremony_number
        AND    award_course_cd = cp_award_course_cd
        AND    award_crs_version_number = cp_award_crs_version_number
        AND    award_cd = cp_award_cd;
      --
      v_gach_rec c_gach%ROWTYPE;
      --
      -- This function will simply return false if the Graduand Award Ceremony History
      -- table or rows are locked. Otherwise, it will delete the appropriate records
      -- from the table and return true.
      --
      FUNCTION grdpl_del_if_not_locked (
        pl_person_id                   IN     igs_gr_awd_crmn.person_id%TYPE,
        pl_create_dt                   IN     igs_gr_awd_crmn.create_dt%TYPE,
        pl_grd_cal_type                IN     igs_gr_awd_crmn.grd_cal_type%TYPE,
        pl_grd_ci_sequence_number      IN     igs_gr_awd_crmn.grd_ci_sequence_number%TYPE,
        pl_ceremony_number             IN     igs_gr_awd_crmn.ceremony_number%TYPE,
        pl_award_course_cd             IN     igs_gr_awd_crmn.award_course_cd%TYPE,
        pl_award_crs_version_number    IN     igs_gr_awd_crmn.award_crs_version_number%TYPE,
        pl_award_cd                    IN     igs_gr_awd_crmn.award_cd%TYPE
      ) RETURN BOOLEAN AS
        --
        e_resource_busy_exception EXCEPTION;
        PRAGMA EXCEPTION_INIT (e_resource_busy_exception, -54);
        --
      BEGIN -- grdpl_del_if_not_locked
        --
        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string (
            fnd_log.level_procedure, g_module_head || 'grdpl_del_if_not_locked.begin',
            'In Params: pl_person_id=>' || pl_person_id || ';' ||
            'pl_create_dt=>' || pl_create_dt || ';' ||
            'pl_grd_cal_type=>' || pl_grd_cal_type || ';' ||
            'pl_grd_ci_sequence_number=>' || pl_grd_ci_sequence_number || ';' ||
            'pl_ceremony_number=>' || pl_ceremony_number || ';' ||
            'pl_award_course_cd=>' || pl_award_course_cd || ';' ||
            'pl_award_crs_version_number=>' || pl_award_crs_version_number || ';' ||
            'pl_award_cd=>' || pl_award_cd || ';'
          );
        END IF;
        --
        DECLARE
          CURSOR c_gach (
            cp_person_id                          igs_gr_awd_crmn.person_id%TYPE,
            cp_create_dt                          igs_gr_awd_crmn.create_dt%TYPE,
            cp_grd_cal_type                       igs_gr_awd_crmn.grd_cal_type%TYPE,
            cp_grd_ci_sequence_number             igs_gr_awd_crmn.grd_ci_sequence_number%TYPE,
            cp_ceremony_number                    igs_gr_awd_crmn.ceremony_number%TYPE,
            cp_award_course_cd                    igs_gr_awd_crmn.award_course_cd%TYPE,
            cp_award_crs_version_number           igs_gr_awd_crmn.award_crs_version_number%TYPE,
            cp_award_cd                           igs_gr_awd_crmn.award_cd%TYPE
          ) IS
            SELECT        ROWID,
                          person_id
            FROM          igs_gr_awd_crmn_hist
            WHERE         person_id = cp_person_id
            AND           create_dt = cp_create_dt
            AND           grd_cal_type = cp_grd_cal_type
            AND           grd_ci_sequence_number = cp_grd_ci_sequence_number
            AND           ceremony_number = cp_ceremony_number
            AND           award_course_cd = cp_award_course_cd
            AND           award_crs_version_number = cp_award_crs_version_number
            AND           award_cd = cp_award_cd
            FOR UPDATE OF person_id NOWAIT;
        BEGIN
          --
          FOR v_gach_rec IN c_gach (
                              p_person_id,
                              p_create_dt,
                              p_grd_cal_type,
                              p_grd_ci_sequence_number,
                              p_ceremony_number,
                              p_award_course_cd,
                              p_award_crs_version_number,
                              p_award_cd
                            ) LOOP
            igs_gr_awd_crmn_hist_pkg.delete_row (x_rowid => v_gach_rec.ROWID);
          END LOOP;
          --
          RETURN TRUE;
        END;
      EXCEPTION
        WHEN e_resource_busy_exception THEN
          RETURN FALSE;
        WHEN OTHERS THEN
          IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string (
              fnd_log.level_exception, g_module_head || 'grdpl_del_if_not_locked.e_resource_busy_exception',
              'Error: ' || SQLERRM
            );
          END IF;
          app_exception.raise_exception;
      END grdpl_del_if_not_locked;
    BEGIN
      --
      p_message_name := NULL;
      --
      IF grdpl_del_if_not_locked (
           p_person_id,
           p_create_dt,
           p_grd_cal_type,
           p_grd_ci_sequence_number,
           p_ceremony_number,
           p_award_course_cd,
           p_award_crs_version_number,
           p_award_cd
         ) = FALSE THEN
        OPEN c_gach (
               p_person_id,
               p_create_dt,
               p_grd_cal_type,
               p_grd_ci_sequence_number,
               p_ceremony_number,
               p_award_course_cd,
               p_award_crs_version_number,
               p_award_cd
             );
        FETCH c_gach INTO v_gach_rec;
        IF c_gach%FOUND THEN
          CLOSE c_gach;
          p_message_name := 'IGS_GR_CANNOT_DEL_GRD_AWD_CER';
          RETURN FALSE;
        END IF;
        --
        CLOSE c_gach;
      END IF;
      --
      RETURN TRUE;
      --
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string (
          fnd_log.level_exception, g_module_head || 'grdp_del_gac_hist.exit_exception',
          'Error: ' || SQLERRM
        );
      END IF;
      app_exception.raise_exception;
  END grdp_del_gac_hist;
  --
  -- Clean up the Graduand and Graduand Award Ceremony records for the specfied
  -- Graduation Ceremony Round which have a Graduand Status of POTENTIAL.
  -- Block for Parameter Validation/Splitting of Parameters
  --
  PROCEDURE grdp_del_gr_gac (
    errbuf                         OUT NOCOPY VARCHAR2,
    retcode                        OUT NOCOPY NUMBER,
    p_grd_period                   IN     VARCHAR2,
    p_org_id                       IN     NUMBER
  ) AS
    --
    p_grd_cal_type           igs_gr_crmn_round_all.grd_cal_type%TYPE;
    p_grd_ci_sequence_number igs_gr_crmn_round_all.grd_ci_sequence_number%TYPE;
    --
  BEGIN -- grdp_del_gr_gac

    IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054
    --
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_procedure, g_module_head || 'grdp_del_gr_gac.begin',
        'In Params: p_grd_period=>' || p_grd_period || ';' ||
        'p_org_id=>' || p_org_id || ';'
      );
    END IF;
    --
    retcode := 0;
    p_grd_cal_type := RTRIM (SUBSTR (p_grd_period, 1, 10));
    p_grd_ci_sequence_number := TO_NUMBER (RTRIM (SUBSTR (p_grd_period, 11, 10)));
    --
    DECLARE
      --
      e_resource_busy EXCEPTION;
      PRAGMA EXCEPTION_INIT (e_resource_busy, -54);
      v_person_id     igs_gr_graduand_all.person_id%TYPE;
      v_create_dt     igs_gr_graduand_all.create_dt%TYPE;
      v_gac_locked    VARCHAR2 (1);
      --
      CURSOR c_gr IS
        SELECT gr.person_id,
               gr.create_dt
        FROM   igs_gr_graduand_all gr,
               igs_gr_stat gst
        WHERE  gr.grd_cal_type = p_grd_cal_type
        AND    gr.grd_ci_sequence_number = p_grd_ci_sequence_number
        AND    gr.graduand_status = gst.graduand_status
        AND    gst.s_graduand_status = 'POTENTIAL'
        AND    gr.grd_cal_type = p_grd_cal_type
        AND    gr.grd_ci_sequence_number = p_grd_ci_sequence_number;
      --
      CURSOR c_gr_del (
        cp_gr_person_id igs_gr_graduand_all.person_id%TYPE,
        cp_gr_create_dt igs_gr_graduand_all.create_dt%TYPE
      ) IS
        SELECT        ROWID
        FROM          igs_gr_graduand_all gr
        WHERE         gr.person_id = cp_gr_person_id
        AND           gr.create_dt = cp_gr_create_dt
        AND           NOT EXISTS (SELECT 'X'
                                  FROM   igs_gr_awd_crmn gac
                                  WHERE  gac.person_id = cp_gr_person_id
                                  AND    gac.create_dt = cp_gr_create_dt)
        FOR UPDATE OF gr.person_id NOWAIT;
      --
      CURSOR c_grh_del (
        cp_gr_person_id                       igs_gr_graduand_all.person_id%TYPE,
        cp_gr_create_dt                       igs_gr_graduand_all.create_dt%TYPE
      ) IS
        SELECT        ROWID
        FROM          igs_gr_graduand_hist grh
        WHERE         grh.person_id = cp_gr_person_id
        AND           grh.create_dt = cp_gr_create_dt
        FOR UPDATE OF grh.person_id NOWAIT;
      --
      CURSOR c_gac (
        cp_gr_person_id igs_gr_graduand_all.person_id%TYPE,
        cp_gr_create_dt igs_gr_graduand_all.create_dt%TYPE
      ) IS
        SELECT        ROWID
        FROM          igs_gr_awd_crmn gac
        WHERE         gac.person_id = cp_gr_person_id
        AND           gac.create_dt = cp_gr_create_dt
        FOR UPDATE OF gac.person_id NOWAIT;
      --
      CURSOR c_gach (
        cp_gr_person_id igs_gr_graduand_all.person_id%TYPE,
        cp_gr_create_dt igs_gr_graduand_all.create_dt%TYPE
      ) IS
        SELECT        ROWID
        FROM          igs_gr_awd_crmn_hist gach
        WHERE         gach.person_id = cp_gr_person_id
        AND           gach.create_dt = cp_gr_create_dt
        AND           gach.grd_cal_type = p_grd_cal_type
        AND           gach.grd_ci_sequence_number = p_grd_ci_sequence_number
        FOR UPDATE OF gach.person_id NOWAIT;
      --
    BEGIN
      --
      -- 1. Check parameters
      --
      IF p_grd_cal_type IS NULL
         OR p_grd_ci_sequence_number IS NULL THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INSUFFICIENT_PARAMETER');
        app_exception.raise_exception;
      END IF;
      --
      v_gac_locked := 'N';
      --
      -- 2. Loop through all of the Graduation Ceremony records which match the specifed parameters.
      --
      FOR v_gr_rec IN c_gr LOOP
        --
        -- 3. Check if the Graduand has any related Graduand Award Ceremony records and delete them.
        --
        v_person_id := v_gr_rec.person_id;
        v_create_dt := v_gr_rec.create_dt;
        --
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string (
            fnd_log.level_statement, g_module_head || 'grdp_del_gr_gac.c_gr_values',
            'person_id=>' || v_gr_rec.person_id || ';' ||
            'create_dt=>' || v_gr_rec.create_dt || ';'
          );
        END IF;
        --
        BEGIN
          --
          -- 4.1  Delete any Graduand Award Ceremony records found.
          --
          FOR v_gac_rec IN c_gac (v_gr_rec.person_id, v_gr_rec.create_dt) LOOP
            igs_gr_awd_crmn_pkg.delete_row (x_rowid => v_gac_rec.ROWID);
          END LOOP;
          --
          -- 4.2  Delete any Graduand Award Ceremony History records found.
          --
          FOR v_gach_rec IN c_gach (v_gr_rec.person_id, v_gr_rec.create_dt) LOOP
            igs_gr_awd_crmn_hist_pkg.delete_row (x_rowid => v_gach_rec.ROWID);
          END LOOP;
          --
        EXCEPTION
          WHEN e_resource_busy THEN
            fnd_file.put_line (fnd_file.LOG, fnd_message.get_string ('IGS', 'IGS_GE_RECORD_LOCKED'));
            v_gac_locked := 'Y';
        END;
        --
        -- 5. Delete any Graduand records found.
        --
        IF v_gac_locked = 'N' THEN
          BEGIN
            --
            -- 5.1  Delete any Graduand records found.
            --
            FOR v_gr_del_rec IN c_gr_del (v_gr_rec.person_id, v_gr_rec.create_dt) LOOP
              igs_gr_graduand_pkg.delete_row (x_rowid => v_gr_del_rec.ROWID);
            END LOOP;
            --
            -- 5.1  Delete any Graduand History records found.
            --
            FOR v_grh_del_rec IN c_grh_del (v_gr_rec.person_id, v_gr_rec.create_dt) LOOP
              igs_gr_graduand_hist_pkg.delete_row (x_rowid => v_grh_del_rec.ROWID);
            END LOOP;
            --
          EXCEPTION
            WHEN e_resource_busy THEN
              fnd_file.put_line (fnd_file.LOG, fnd_message.get_string ('IGS', 'IGS_GE_RECORD_LOCKED'));
          END;
        ELSE
          v_gac_locked := 'N';
        END IF;
      END LOOP;
      --
      COMMIT;
      RETURN;
      --
    EXCEPTION
      WHEN OTHERS THEN
        IF c_gr%ISOPEN THEN
          CLOSE c_gr;
        END IF;
        IF c_gr%ISOPEN THEN
          CLOSE c_gr_del;
        END IF;
        IF c_gr%ISOPEN THEN
          CLOSE c_grh_del;
        END IF;
        IF c_gac%ISOPEN THEN
          CLOSE c_gac;
        END IF;
        IF c_gac%ISOPEN THEN
          CLOSE c_gach;
        END IF;
        RAISE;
    END;
    --
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string (
          fnd_log.level_exception, g_module_head || 'grdp_del_gr_gac.exit_exception',
          'Error: ' || SQLERRM
        );
      END IF;
      app_exception.raise_exception;
  END grdp_del_gr_gac;
  --
  -- This function gets the title for the unit set group if an override title is not set.
  --
  FUNCTION grdp_get_acusg_title (
    p_grd_cal_type                 IN     VARCHAR2,
    p_grd_ci_sequence_number       IN     NUMBER,
    p_ceremony_number              IN     NUMBER,
    p_award_course_cd              IN     CHAR,
    p_award_crs_version_number     IN     NUMBER,
    p_award_cd                     IN     VARCHAR2,
    p_us_group_number              IN     NUMBER
  ) RETURN VARCHAR2 AS
  BEGIN -- grdp_get_acusg_title
    --
    -- Get the Award Ceremony Unit Set Group title
    --
    DECLARE
      v_group_title VARCHAR2 (500);
      v_us_title    VARCHAR2 (100);
      --
      CURSOR c_acusg IS
        SELECT acusg.override_title
        FROM   igs_gr_awd_crm_us_gp acusg
        WHERE  acusg.grd_cal_type = p_grd_cal_type
        AND    acusg.grd_ci_sequence_number = p_grd_ci_sequence_number
        AND    acusg.ceremony_number = p_ceremony_number
        AND    acusg.award_course_cd = p_award_course_cd
        AND    acusg.award_crs_version_number = p_award_crs_version_number
        AND    acusg.award_cd = p_award_cd
        AND    acusg.us_group_number = p_us_group_number
        AND    acusg.override_title IS NOT NULL;
      --
      CURSOR c_us IS
        SELECT   us.short_title
        FROM     igs_en_unit_set us,
                 igs_gr_awd_crm_ut_st acus
        WHERE    acus.grd_cal_type = p_grd_cal_type
        AND      acus.grd_ci_sequence_number = p_grd_ci_sequence_number
        AND      acus.ceremony_number = p_ceremony_number
        AND      acus.award_course_cd = p_award_course_cd
        AND      acus.award_crs_version_number = p_award_crs_version_number
        AND      acus.award_cd = p_award_cd
        AND      acus.us_group_number = p_us_group_number
        AND      acus.unit_set_cd = us.unit_set_cd
        AND      acus.us_version_number = us.version_number
        ORDER BY acus.order_in_group;
      --
    BEGIN
      --
      OPEN c_acusg;
      FETCH c_acusg
      INTO  v_us_title;
      --
      IF c_acusg%FOUND THEN
        CLOSE c_acusg;
        RETURN v_us_title;
      END IF;
      CLOSE c_acusg;
      --
      OPEN c_us;
      LOOP
        FETCH c_us
        INTO  v_us_title;
        --
        IF c_us%NOTFOUND THEN
          CLOSE c_us;
          EXIT;
        END IF;
        --
        IF v_group_title IS NULL THEN
          v_group_title := v_us_title;
        ELSE
          v_group_title := v_group_title || ' & ' || v_us_title;
        END IF;
        --
        v_group_title := SUBSTR (v_group_title, 1, 255);
      END LOOP;
      --
      RETURN v_group_title;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END grdp_get_acusg_title;
  --
  -- Retrieves and formats the graduation name from a student's person detail.
  --
  FUNCTION grdp_get_grad_name (p_person_id IN NUMBER)
    RETURN VARCHAR2 AS
  BEGIN
    --
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_procedure, g_module_head || 'grdp_get_grad_name.begin',
        'In Params: p_person_id=>' || p_person_id || ';'
      );
    END IF;
    --
    DECLARE
      cst_person      CONSTANT VARCHAR2 (6)                           := 'PERSON';
      cst_title       CONSTANT VARCHAR2 (5)                           := 'TITLE';
      cst_given_names CONSTANT VARCHAR2 (11)                          := 'GIVEN_NAMES';
      cst_surname     CONSTANT VARCHAR2 (7)                           := 'SURNAME';
      v_surname                igs_pe_person_base_v.last_name%TYPE        DEFAULT NULL;
      v_given_names            igs_pe_person_base_v.first_name%TYPE       DEFAULT NULL;
      v_title                  igs_pe_person_base_v.title%TYPE            DEFAULT NULL;
      v_graduation_name        igs_gr_graduand_all.graduation_name%TYPE   DEFAULT '';
      --
      CURSOR c_pe IS
        SELECT pe.last_name,
               pe.first_name,
               pe.title
        FROM   igs_pe_person_base_v pe
        WHERE  pe.person_id = p_person_id;
      --
      --
      --
      FUNCTION grdpl_surname_initcap (surname VARCHAR2)
        RETURN VARCHAR2 AS
        name_start VARCHAR2 (4);
      BEGIN
        --
        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string (
            fnd_log.level_procedure, g_module_head || 'grdpl_surname_initcap.begin',
            'In Params: surname=>' || surname || ';'
          );
        END IF;
        --
        name_start := SUBSTR (surname, 1, 3);
        --
        IF name_start = 'MAC' THEN
          RETURN 'Mac' || INITCAP (SUBSTR (surname, 4, LENGTH (surname)));
        ELSIF name_start LIKE 'MC%' THEN
          RETURN 'Mc' || INITCAP (SUBSTR (surname, 3, LENGTH (surname)));
        ELSE
          RETURN INITCAP (surname);
        END IF;
      END grdpl_surname_initcap;
    BEGIN
      --
      OPEN c_pe;
      FETCH c_pe
      INTO  v_surname,
            v_given_names,
            v_title;
      --
      IF c_pe%NOTFOUND THEN
        CLOSE c_pe;
        RAISE NO_DATA_FOUND;
      END IF;
      --
      CLOSE c_pe;
      --
      -- the code commented out below can be uncommented if 'Title' is a required
      -- component in the Graduand name.
      --
      /*IF v_title IS NOT NULL THEN
        -- IF column is forced uppercase, re-Capitalise.
        IF IGS_GE_GEN_001.genp_chk_col_upper( cst_title,
              cst_person) THEN
          v_graduation_name := RTRIM(INITCAP(v_title));
        ELSE
          v_graduation_name := RTRIM(v_title);
        END IF;
      END IF;*/
      --
      IF v_given_names IS NOT NULL THEN
        -- If column is forced uppercase, re-Capitalise.
        IF igs_ge_gen_001.genp_chk_col_upper (cst_given_names, cst_person) THEN
          v_graduation_name := v_graduation_name || ' ' || RTRIM (INITCAP (v_given_names));
        ELSE
          v_graduation_name := v_graduation_name || ' ' || RTRIM (v_given_names);
        END IF;
      END IF;
      --
      IF v_surname IS NOT NULL THEN
        --
        -- If column is forced uppercase, re-Capitalise.
        -- Allow for mid-name capitals (like McDonald).
        --
        IF igs_ge_gen_001.genp_chk_col_upper (cst_surname, cst_person) THEN
          v_graduation_name := v_graduation_name || ' ' || RTRIM (grdpl_surname_initcap (v_surname));
        ELSE
          v_graduation_name := v_graduation_name || ' ' || RTRIM (v_surname);
        END IF;
      END IF;
      --
      RETURN v_graduation_name;
      --
    EXCEPTION
      WHEN OTHERS THEN
        IF c_pe%ISOPEN THEN
          CLOSE c_pe;
        END IF;
        --
        RAISE;
    END;
    --
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string (
          fnd_log.level_exception, g_module_head || 'grdp_get_grad_name.exit_exception',
          'Error: ' || SQLERRM
        );
      END IF;
      app_exception.raise_exception;
  END grdp_get_grad_name;
  --
  -- Retrieves the government honours level from a student's Graduand detail.
  --
  FUNCTION grdp_get_gr_ghl (p_person_id IN NUMBER, p_course_cd IN VARCHAR2)
    RETURN VARCHAR2 AS
  BEGIN -- grdp_get_gr_ghl
    --
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_procedure, g_module_head || 'grdp_get_gr_ghl.begin',
        'In Params: p_person_id=>' || p_person_id || ';' ||
        'p_course_cd=>' || p_course_cd || ';'
      );
    END IF;
    --
    DECLARE
      --
      v_govt_honours_level igs_gr_honours_level.govt_honours_level%TYPE;
      --
      CURSOR c_gr_gst_aw_hl IS
        SELECT hl.govt_honours_level
        FROM   igs_gr_graduand_all gr,
               igs_gr_stat gst,
               igs_ps_awd aw,
               igs_gr_honours_level hl
        WHERE  gr.person_id = p_person_id
        AND    gr.course_cd = p_course_cd
        AND    gr.award_course_cd = gr.course_cd
        AND    gst.graduand_status = gr.graduand_status
        AND    gst.s_graduand_status = 'GRADUATED'
        AND    aw.award_cd = gr.award_cd
        AND    aw.s_award_type = 'COURSE'
        AND    hl.honours_level = gr.honours_level;
      --
    BEGIN
      --
      OPEN c_gr_gst_aw_hl;
      FETCH c_gr_gst_aw_hl
      INTO  v_govt_honours_level;
      --
      IF c_gr_gst_aw_hl%NOTFOUND THEN
        CLOSE c_gr_gst_aw_hl;
        --
        RETURN 1; -- Student not granted honours level
      ELSE
        CLOSE c_gr_gst_aw_hl;
        --
        RETURN v_govt_honours_level;
      END IF;
      --
    EXCEPTION
      WHEN OTHERS THEN
        IF c_gr_gst_aw_hl%ISOPEN THEN
          CLOSE c_gr_gst_aw_hl;
        END IF;
        --
        RAISE;
    END;
    --
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string (
          fnd_log.level_exception, g_module_head || 'grdp_get_gr_ghl.exit_exception',
          'Error: ' || SQLERRM
        );
      END IF;
      app_exception.raise_exception;
  END grdp_get_gr_ghl;
  --
  -- Insert Graduand Award Ceremony History
  --
  PROCEDURE grdp_ins_gac_hist (
    p_person_id                           igs_gr_awd_crmn.person_id%TYPE,
    p_create_dt                           igs_gr_awd_crmn.create_dt%TYPE,
    p_grd_cal_type                        igs_gr_awd_crmn.grd_cal_type%TYPE,
    p_grd_ci_sequence_number              igs_gr_awd_crmn.grd_ci_sequence_number%TYPE,
    p_ceremony_number                     igs_gr_awd_crmn.ceremony_number%TYPE,
    p_award_course_cd                     igs_gr_awd_crmn.award_course_cd%TYPE,
    p_award_crs_version_number            igs_gr_awd_crmn.award_crs_version_number%TYPE,
    p_award_cd                            igs_gr_awd_crmn.award_cd%TYPE,
    p_old_us_group_number                 igs_gr_awd_crmn.us_group_number%TYPE,
    p_new_us_group_number                 igs_gr_awd_crmn.us_group_number%TYPE,
    p_old_order_in_presentation           igs_gr_awd_crmn.order_in_presentation%TYPE,
    p_new_order_in_presentation           igs_gr_awd_crmn.order_in_presentation%TYPE,
    p_old_graduand_seat_number            igs_gr_awd_crmn.graduand_seat_number%TYPE,
    p_new_graduand_seat_number            igs_gr_awd_crmn.graduand_seat_number%TYPE,
    p_old_name_pronunciation              igs_gr_awd_crmn.name_pronunciation%TYPE,
    p_new_name_pronunciation              igs_gr_awd_crmn.name_pronunciation%TYPE,
    p_old_name_announced                  igs_gr_awd_crmn.name_announced%TYPE,
    p_new_name_announced                  igs_gr_awd_crmn.name_announced%TYPE,
    p_old_academic_dress_rqrd_ind         igs_gr_awd_crmn.academic_dress_rqrd_ind%TYPE,
    p_new_academic_dress_rqrd_ind         igs_gr_awd_crmn.academic_dress_rqrd_ind%TYPE,
    p_old_academic_gown_size              igs_gr_awd_crmn.academic_gown_size%TYPE,
    p_new_academic_gown_size              igs_gr_awd_crmn.academic_gown_size%TYPE,
    p_old_academic_hat_size               igs_gr_awd_crmn.academic_hat_size%TYPE,
    p_new_academic_hat_size               igs_gr_awd_crmn.academic_hat_size%TYPE,
    p_old_guest_tickets_requested         igs_gr_awd_crmn.guest_tickets_requested%TYPE,
    p_new_guest_tickets_requested         igs_gr_awd_crmn.guest_tickets_requested%TYPE,
    p_old_guest_tickets_allocated         igs_gr_awd_crmn.guest_tickets_allocated%TYPE,
    p_new_guest_tickets_allocated         igs_gr_awd_crmn.guest_tickets_allocated%TYPE,
    p_old_guest_seats                     igs_gr_awd_crmn.guest_seats%TYPE,
    p_new_guest_seats                     igs_gr_awd_crmn.guest_seats%TYPE,
    p_old_fees_paid_ind                   igs_gr_awd_crmn.fees_paid_ind%TYPE,
    p_new_fees_paid_ind                   igs_gr_awd_crmn.fees_paid_ind%TYPE,
    p_old_update_who                      igs_gr_awd_crmn.last_updated_by%TYPE,
    p_new_update_who                      igs_gr_awd_crmn.last_updated_by%TYPE,
    p_old_update_on                       igs_gr_awd_crmn.last_update_date%TYPE,
    p_new_update_on                       igs_gr_awd_crmn.last_update_date%TYPE,
    p_old_special_requirements            igs_gr_awd_crmn.special_requirements%TYPE,
    p_new_special_requirements            igs_gr_awd_crmn.special_requirements%TYPE,
    p_old_comments                        igs_gr_awd_crmn.comments%TYPE,
    p_new_comments                        igs_gr_awd_crmn.comments%TYPE
  ) AS
  BEGIN -- grdp_ins_gr_hist
    --
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string (
        fnd_log.level_procedure, g_module_head || 'grdp_ins_gac_hist.begin',
        'In Params: p_person_id=>' || p_person_id || ';' ||
        'p_create_dt=>' || p_create_dt || ';' ||
        'p_grd_cal_type=>' || p_grd_cal_type || ';' ||
        'p_grd_ci_sequence_number=>' || p_grd_ci_sequence_number || ';' ||
        'p_ceremony_number=>' || p_ceremony_number || ';' ||
        'p_award_course_cd=>' || p_award_course_cd || ';' ||
        'p_award_crs_version_number=>' || p_award_crs_version_number || ';' ||
        'p_award_cd=>' || p_award_cd || ';' ||
        'p_old_us_group_number=>' || p_old_us_group_number || ';' ||
        'p_new_us_group_number=>' || p_new_us_group_number || ';' ||
        'p_old_order_in_presentation=>' || p_old_order_in_presentation || ';' ||
        'p_new_order_in_presentation=>' || p_new_order_in_presentation || ';' ||
        'p_old_graduand_seat_number=>' || p_old_graduand_seat_number || ';' ||
        'p_new_graduand_seat_number=>' || p_new_graduand_seat_number || ';' ||
        'p_old_name_pronunciation=>' || p_old_name_pronunciation || ';' ||
        'p_new_name_pronunciation=>' || p_new_name_pronunciation || ';' ||
        'p_old_name_announced=>' || p_old_name_announced || ';' ||
        'p_new_name_announced=>' || p_new_name_announced || ';' ||
        'p_old_academic_dress_rqrd_ind=>' || p_old_academic_dress_rqrd_ind || ';' ||
        'p_new_academic_dress_rqrd_ind=>' || p_new_academic_dress_rqrd_ind || ';' ||
        'p_old_academic_gown_size=>' || p_old_academic_gown_size || ';' ||
        'p_new_academic_gown_size=>' || p_new_academic_gown_size || ';' ||
        'p_old_academic_hat_size=>' || p_old_academic_hat_size || ';' ||
        'p_new_academic_hat_size=>' || p_new_academic_hat_size || ';' ||
        'p_old_guest_tickets_requested=>' || p_old_guest_tickets_requested || ';' ||
        'p_new_guest_tickets_requested=>' || p_new_guest_tickets_requested || ';' ||
        'p_old_guest_tickets_allocated=>' || p_old_guest_tickets_allocated || ';' ||
        'p_new_guest_tickets_allocated=>' || p_new_guest_tickets_allocated || ';' ||
        'p_old_guest_seats=>' || p_old_guest_seats || ';' ||
        'p_new_guest_seats=>' || p_new_guest_seats || ';' ||
        'p_old_fees_paid_ind=>' || p_old_fees_paid_ind || ';' ||
        'p_new_fees_paid_ind=>' || p_new_fees_paid_ind || ';' ||
        'p_old_update_who=>' || p_old_update_who || ';' ||
        'p_new_update_who=>' || p_new_update_who || ';' ||
        'p_old_update_on=>' || p_old_update_on || ';' ||
        'p_new_update_on=>' || p_new_update_on || ';' ||
        'p_old_special_requirements=>' || p_old_special_requirements || ';' ||
        'p_new_special_requirements=>' || p_new_special_requirements || ';' ||
        'p_old_comments=>' || p_old_comments || ';' ||
        'p_new_comments=>' || p_new_comments || ';'
      );
    END IF;
    --
    DECLARE
      v_gac_rec        igs_gr_awd_crmn_hist%ROWTYPE;
      v_create_history BOOLEAN DEFAULT FALSE;
    BEGIN
      --
      -- If any of the old values (p_old_<column_name>) are different from the
      -- associated new values (p_new_<column_name>) (with the exception of
      -- the last_update_date and last_updated_by columns) then create a
      -- Graduand Award Ceremony History record with the old values
      -- (p_old_<column_name>). Do not set the last_updated_by and last_update_date
      -- columns when creating the history record.
      --
      IF NVL (p_new_us_group_number, 0) <> NVL (p_old_us_group_number, 0) THEN
        v_gac_rec.us_group_number := p_old_us_group_number;
        v_create_history := TRUE;
      END IF;
      --
      IF NVL (p_new_order_in_presentation, 0) <> NVL (p_old_order_in_presentation, 0) THEN
        v_gac_rec.order_in_presentation := p_old_order_in_presentation;
        v_create_history := TRUE;
      END IF;
      --
      IF NVL (p_new_graduand_seat_number, 'NULL') <> NVL (p_old_graduand_seat_number, 'NULL') THEN
        v_gac_rec.graduand_seat_number := p_old_graduand_seat_number;
        v_create_history := TRUE;
      END IF;
      --
      IF NVL (p_new_name_pronunciation, 'NULL') <> NVL (p_old_name_pronunciation, 'NULL') THEN
        v_gac_rec.name_pronunciation := p_old_name_pronunciation;
        v_create_history := TRUE;
      END IF;
      --
      IF NVL (p_new_name_announced, 'NULL') <> NVL (p_old_name_announced, 'NULL') THEN
        v_gac_rec.name_announced := p_old_name_announced;
        v_create_history := TRUE;
      END IF;
      --
      IF p_new_academic_dress_rqrd_ind <> p_old_academic_dress_rqrd_ind THEN
        v_gac_rec.academic_dress_rqrd_ind := p_old_academic_dress_rqrd_ind;
        v_create_history := TRUE;
      END IF;
      --
      IF NVL (p_new_academic_gown_size, 'NULL') <> NVL (p_old_academic_gown_size, 'NULL') THEN
        v_gac_rec.academic_gown_size := p_old_academic_gown_size;
        v_create_history := TRUE;
      END IF;
      --
      IF NVL (p_new_academic_hat_size, 'NULL') <> NVL (p_old_academic_hat_size, 'NULL') THEN
        v_gac_rec.academic_hat_size := p_old_academic_hat_size;
        v_create_history := TRUE;
      END IF;
      --
      IF NVL (p_new_guest_tickets_requested, 0) <> NVL (p_old_guest_tickets_requested, 0) THEN
        v_gac_rec.guest_tickets_requested := p_old_guest_tickets_requested;
        v_create_history := TRUE;
      END IF;
      --
      IF NVL (p_new_guest_tickets_allocated, 0) <> NVL (p_old_guest_tickets_allocated, 0) THEN
        v_gac_rec.guest_tickets_allocated := p_old_guest_tickets_allocated;
        v_create_history := TRUE;
      END IF;
      --
      IF NVL (p_new_guest_seats, 'NULL') <> NVL (p_old_guest_seats, 'NULL') THEN
        v_gac_rec.guest_seats := p_old_guest_seats;
        v_create_history := TRUE;
      END IF;
      --
      IF p_new_fees_paid_ind <> p_old_fees_paid_ind THEN
        v_gac_rec.fees_paid_ind := p_old_fees_paid_ind;
        v_create_history := TRUE;
      END IF;
      --
      IF NVL (p_new_special_requirements, 'NULL') <> NVL (p_old_special_requirements, 'NULL') THEN
        v_gac_rec.special_requirements := p_old_special_requirements;
        v_create_history := TRUE;
      END IF;
      --
      IF NVL (p_new_comments, 'NULL') <> NVL (p_old_comments, 'NULL') THEN
        v_gac_rec.comments := p_old_comments;
        v_create_history := TRUE;
      END IF;
      --
      -- Insert history record.
      --
      IF v_create_history THEN
        v_gac_rec.person_id := p_person_id;
        v_gac_rec.create_dt := p_create_dt;
        v_gac_rec.grd_cal_type := p_grd_cal_type;
        v_gac_rec.grd_ci_sequence_number := p_grd_ci_sequence_number;
        v_gac_rec.ceremony_number := p_ceremony_number;
        v_gac_rec.award_course_cd := p_award_course_cd;
        v_gac_rec.award_crs_version_number := p_award_crs_version_number;
        v_gac_rec.award_cd := p_award_cd;
        v_gac_rec.hist_start_dt := p_old_update_on;
        v_gac_rec.hist_end_dt := p_new_update_on;
        v_gac_rec.hist_who := p_old_update_who;
        --
        -- Remove one second from the hist_start_dt value when the hist_start_dt
        -- and hist_end_dt are the same to avoid a primary key constraint from
        -- occurring when saving the record
        --
        IF (v_gac_rec.hist_start_dt = v_gac_rec.hist_end_dt) THEN
          v_gac_rec.hist_start_dt := v_gac_rec.hist_start_dt - 1 / (60 * 24 * 60);
        END IF;
        --
        DECLARE
          lv_rowid VARCHAR2 (25);
          lv_seqnc NUMBER;
        BEGIN
          igs_gr_awd_crmn_hist_pkg.insert_row (
            x_rowid                        => lv_rowid,
            x_gach_id                      => lv_seqnc,
            x_name_pronunciation           => v_gac_rec.name_pronunciation,
            x_name_announced               => v_gac_rec.name_announced,
            x_academic_dress_rqrd_ind      => v_gac_rec.academic_dress_rqrd_ind,
            x_academic_gown_size           => v_gac_rec.academic_gown_size,
            x_academic_hat_size            => v_gac_rec.academic_hat_size,
            x_guest_tickets_requested      => v_gac_rec.guest_tickets_requested,
            x_guest_tickets_allocated      => v_gac_rec.guest_tickets_allocated,
            x_guest_seats                  => v_gac_rec.guest_seats,
            x_fees_paid_ind                => v_gac_rec.fees_paid_ind,
            x_special_requirements         => v_gac_rec.special_requirements,
            x_comments                     => v_gac_rec.comments,
            x_person_id                    => v_gac_rec.person_id,
            x_create_dt                    => v_gac_rec.create_dt,
            x_grd_cal_type                 => v_gac_rec.grd_cal_type,
            x_graduand_seat_number         => v_gac_rec.graduand_seat_number,
            x_hist_who                     => v_gac_rec.hist_who,
            x_us_group_number              => v_gac_rec.us_group_number,
            x_order_in_presentation        => v_gac_rec.order_in_presentation,
            x_hist_end_dt                  => v_gac_rec.hist_end_dt,
            x_grd_ci_sequence_number       => v_gac_rec.grd_ci_sequence_number,
            x_ceremony_number              => v_gac_rec.ceremony_number,
            x_award_course_cd              => v_gac_rec.award_course_cd,
            x_award_crs_version_number     => v_gac_rec.award_crs_version_number,
            x_award_cd                     => v_gac_rec.award_cd,
            x_hist_start_dt                => v_gac_rec.hist_start_dt,
            x_mode                         => 'R'
          );
        END;
      END IF;
    END;
    --
  EXCEPTION
    WHEN OTHERS THEN
      IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string (
          fnd_log.level_exception, g_module_head || 'grdp_ins_gac_hist.exit_exception',
          'Error: ' || SQLERRM
        );
      END IF;
      app_exception.raise_exception;
  END grdp_ins_gac_hist;
END igs_gr_gen_001;

/
