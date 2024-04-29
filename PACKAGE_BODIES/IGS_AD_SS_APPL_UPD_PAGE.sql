--------------------------------------------------------
--  DDL for Package Body IGS_AD_SS_APPL_UPD_PAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_SS_APPL_UPD_PAGE" AS
/* $Header: IGSADC5B.pls 115.5 2003/10/30 13:18:27 rghosh noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_appl_perstat%ROWTYPE;
  new_references igs_ad_appl_perstat%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_appl_perstat_id                   IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_admission_appl_number             IN     NUMBER      ,
    x_persl_stat_type                   IN     VARCHAR2    ,
    x_date_received                     IN     DATE        ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : tray
  ||  Created On : 22-Oct-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ad_appl_perstat
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.appl_perstat_id                   := x_appl_perstat_id;
    new_references.person_id                         := x_person_id;
    new_references.admission_appl_number             := x_admission_appl_number;
    new_references.persl_stat_type                   := x_persl_stat_type;
    new_references.date_received                     := x_date_received;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : tray
  ||  Created On : 22-OCT-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.persl_stat_type = new_references.persl_stat_type)) OR
        ((new_references.persl_stat_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_per_stm_typ_pkg.get_pk_for_validation (
                new_references.persl_stat_type ,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

    FUNCTION get_pk_for_validation (
    x_appl_perstat_id                      IN     NUMBER,
    x_person_id                            IN     NUMBER,
    x_admission_appl_number                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : tray
  ||  Created On : 22-OCT-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_appl_perstat
      WHERE    appl_perstat_id = x_appl_perstat_id AND
               person_id =  x_person_id AND
               admission_appl_number = x_admission_appl_number
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_pk_for_validation;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_appl_perstat_id                   IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_admission_appl_number             IN     NUMBER      ,
    x_persl_stat_type                   IN     VARCHAR2    ,
    x_date_received                     IN     DATE        ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : tray
  ||  Created On : 22-OCT-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_appl_perstat_id,
      x_person_id,
      x_admission_appl_number,
      x_persl_stat_type,
      x_date_received,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(  new_references.appl_perstat_id,
                                   new_references.person_id,
                                   new_references.admission_appl_number )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    END IF;
  END before_dml;


  PROCEDURE create_perstat_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_perstat_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_persl_stat_type                   IN     VARCHAR2,
    x_date_received                     IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : tray
  ||  Created On : 22-OCT-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_appl_perstat
      WHERE    appl_perstat_id = x_appl_perstat_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_appl_perstat_id                   => x_appl_perstat_id,
      x_person_id                         => x_person_id,
      x_admission_appl_number             => x_admission_appl_number,
      x_persl_stat_type                   => x_persl_stat_type,
      x_date_received                     => x_date_received,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ad_appl_perstat (
      appl_perstat_id,
      person_id,
      admission_appl_number,
      persl_stat_type,
      date_received,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      igs_ad_appl_perstat_s.NEXTVAL,
      new_references.person_id,
      new_references.admission_appl_number,
      new_references.persl_stat_type,
      new_references.date_received,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    )RETURNING appl_perstat_id INTO x_appl_perstat_id;
    commit;
    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END create_perstat_row;

-- To Be called from Process Req and navigate to dialog page with appropriate dialog page
 PROCEDURE check_adm_due_date_isvalid (
    p_adm_cal_type IN VARCHAR2 ,
    p_adm_ci_sequence_number IN NUMBER ,
    p_adm_cat IN VARCHAR2 ,
    p_s_adm_prc_type IN VARCHAR2 ,
    p_acad_cal_type IN VARCHAR2 ,
    l_msg_count OUT NOCOPY NUMBER,
    l_msg_data  OUT NOCOPY VARCHAR2 ,
    l_return_status OUT NOCOPY VARCHAR2) AS

     CURSOR adm_cal_conf_cur IS
     SELECT adm_appl_due_dt_alias
     FROM igs_ad_cal_conf
     WHERE s_control_num = 1;

     l_adm_appl_due_dt_alias igs_ca_da_inst.dt_alias%TYPE;

     CURSOR override_cur ( c_adm_cal_type VARCHAR2,
                                        c_adm_sequence_number NUMBER,
                                        c_adm_cat VARCHAR2,
                                        c_acad_cal_type VARCHAR2,
                                        c_s_adm_prcs_type VARCHAR2
                                )  IS
        SELECT IGS_CA_GEN_001.calp_set_alias_value(
                      dai.absolute_val,
                      IGS_CA_GEN_002.cals_clc_dt_from_dai(
                            dai.ci_sequence_number, dai.CAL_TYPE, dai.DT_ALIAS, dai.sequence_number) ) adm_appl_due_dt_alias
          FROM igs_ad_pecrs_ofop_dt pod, igs_ca_da_inst dai
         WHERE dai.dt_alias = pod.dt_alias
              AND dai.sequence_number = pod.dai_sequence_number
              AND pod.adm_cal_type = c_adm_cal_type
              AND pod.adm_ci_sequence_number = c_adm_sequence_number
              AND pod.admission_cat = c_adm_cat
              AND pod.s_admission_process_type = c_s_adm_prcs_type
              AND NVL( pod.acad_cal_type, c_acad_cal_type) = c_acad_cal_type
              AND dai.dt_alias = l_adm_appl_due_dt_alias;

     CURSOR default_set_cur (c_adm_cal_type VARCHAR2,
                                c_adm_sequence_number NUMBER
                                ) IS
        SELECT IGS_CA_GEN_001.calp_set_alias_value(
                      ca.absolute_val,
                      IGS_CA_GEN_002.cals_clc_dt_from_dai(
                            ca.ci_sequence_number, ca.CAL_TYPE, ca.DT_ALIAS, ca.sequence_number) ) alias_val
           FROM IGS_CA_DA_INST ca, igs_ca_inst ci
         WHERE ca.dt_alias = l_adm_appl_due_dt_alias
                and ci.cal_type = ca.cal_type
                and ci.sequence_number = ca.ci_sequence_number
                and ci.cal_type = c_adm_cal_type
                and ci.sequence_number = c_adm_sequence_number
        ORDER BY 1 desc;

       l_adm_due_date_alias igs_ca_da_inst_v.alias_val%TYPE;
       l_adm_cal_type igs_ca_inst.cal_type%TYPE;
       l_adm_sequence_number igs_ca_inst.sequence_number%TYPE;
       l_admission_cat igs_ad_cat.admission_cat%TYPE;
       l_s_adm_prcs_type igs_ad_pecrs_ofop_dt.s_admission_process_type%TYPE;
       l_acad_cal_type igs_ca_inst.cal_type%TYPE;


 BEGIN
   l_adm_due_date_alias:=NVL(l_adm_due_date_alias,NULL);
   l_adm_cal_type:=p_adm_cal_type;
   l_adm_sequence_number:=p_adm_ci_sequence_number;
   l_admission_cat:=p_adm_cat;
   l_s_adm_prcs_type:=p_s_adm_prc_type;
   l_acad_cal_type:=p_acad_cal_type;

   OPEN adm_cal_conf_cur;
   FETCH adm_cal_conf_cur INTO l_adm_appl_due_dt_alias;
   CLOSE adm_cal_conf_cur;
   -- If the DUE-DATE alias is not defined then throw a warning message to the user
   IF l_adm_appl_due_dt_alias IS NULL THEN
     l_msg_count:=1;
     l_msg_data:='IGS_AD_DUEDT_NOT_DEF';
     l_return_status:='W';
     RETURN;
   END IF;

   -- If the due date is defined check if there is any override for the
   -- Admission calendar instance, admission category, academic calendar
   OPEN override_cur ( l_adm_cal_type, l_adm_sequence_number, l_admission_cat, l_acad_cal_type, l_s_adm_prcs_type);
   FETCH override_cur INTO l_adm_due_date_alias;
   CLOSE override_cur;

  -- If the DUE-DATE alias is not defined then check the default value
  IF l_adm_due_date_alias IS NOT NULL THEN
    IF TRUNC(l_adm_due_date_alias) <  TRUNC(SYSDATE) THEN
      l_msg_count:=1;
      l_msg_data:='IGS_AD_FINDUEDT_PASD_NEWAPPL';
      l_return_status:='W';
      RETURN;
    END IF;
  ELSE
    OPEN default_set_cur ( l_adm_cal_type, l_adm_sequence_number);
    FETCH default_set_cur INTO l_adm_due_date_alias;
    CLOSE default_set_cur;
    IF TRUNC(l_adm_due_date_alias) <  TRUNC(SYSDATE) THEN
      l_msg_count:=1;
      l_msg_data:='IGS_AD_FINDUEDT_PASD_NEWAPPL';
      l_return_status:='W';
      RETURN;
    END IF;
  END IF;
   l_msg_count:=0;
   l_msg_data:=null;
   l_return_status:=null;
   RETURN;
 END check_adm_due_date_isvalid;

 PROCEDURE validate_due_final_dt(
 p_adm_cal_type IN VARCHAR2,
 p_adm_ci_sequence_number IN NUMBER,
 p_adm_cat IN VARCHAR2,
 p_s_adm_prc_type IN VARCHAR2,
 p_course_cd IN VARCHAR2,
 p_crv_version_number IN NUMBER,
 p_acad_cal_type IN VARCHAR2,
 p_location_cd IN VARCHAR2,
 p_attendance_mode IN VARCHAR2,
 p_attendance_type IN VARCHAR2,
 l_msg_count OUT NOCOPY NUMBER,
 l_msg_data  OUT NOCOPY VARCHAR2,
 l_return_status OUT NOCOPY VARCHAR2) AS

	v_adm_appl_due_dt_alias         IGS_AD_CAL_CONF.adm_appl_due_dt_alias%TYPE;
	v_adm_appl_final_dt_alias       IGS_AD_CAL_CONF.adm_appl_final_dt_alias%TYPE;
        v_due_dt                        DATE;
        v_final_dt                      DATE;
        l_max_duedt                     DATE;

	CURSOR c_sacc IS
        SELECT  adm_appl_due_dt_alias,
                adm_appl_final_dt_alias
        FROM    IGS_AD_CAL_CONF
        WHERE   s_control_num = 1;

	l_adm_cal_type igs_ca_inst.cal_type%TYPE ;
	l_adm_sequence_number igs_ca_inst.sequence_number%TYPE;
	l_adm_cat IGS_AD_PRCS_CAT_STEP.ADMISSION_CAT%TYPE;
	l_s_adm_prc_typ IGS_AD_PRCS_CAT_STEP.S_ADMISSION_PROCESS_TYPE%TYPE;
	l_late_appl_exists VARCHAR2(2000);


        CURSOR c_dai IS
        SELECT MAX( IGS_CA_GEN_001.calp_set_alias_value(
                      dai.absolute_val,
                      IGS_CA_GEN_002.cals_clc_dt_from_dai(
                            dai.ci_sequence_number, dai.CAL_TYPE, dai.DT_ALIAS, dai.sequence_number) )) alias_val
        FROM   igs_ca_da da, igs_ca_da_inst dai
        WHERE  da.s_cal_cat = 'ADMISSION'
        AND da.dt_alias = v_adm_appl_due_dt_alias
        AND da.dt_alias = dai.dt_alias
        AND dai.cal_type = l_adm_cal_type
        AND dai.ci_sequence_number = l_adm_sequence_number;

	CURSOR c_apcs (
                cp_admission_cat                IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
                cp_s_admission_process_type     IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
        SELECT  'X'
        FROM    IGS_AD_PRCS_CAT_STEP apcs,
                IGS_LOOKUPS_VIEW sasty
        WHERE   apcs.admission_cat = cp_admission_cat AND
                apcs.s_admission_process_type = cp_s_admission_process_type AND
                apcs.s_admission_step_type = 'LATE-APP' AND
                sasty.step_group_type = 'APPL-VAL' AND
                sasty.lookup_type = 'ADMISSION_STEP_TYPE' AND
                sasty.lookup_code = apcs.s_admission_step_type
        ORDER BY apcs.s_admission_step_type;

 BEGIN
   l_adm_cal_type:=l_adm_cal_type;
   l_adm_sequence_number:=l_adm_sequence_number;
   l_adm_cat:=p_adm_cat;
   l_s_adm_prc_typ:=p_s_adm_prc_type;

   OPEN c_sacc;
   FETCH c_sacc INTO
   v_adm_appl_due_dt_alias,
   v_adm_appl_final_dt_alias;

   IF c_sacc%NOTFOUND OR v_adm_appl_due_dt_alias IS NULL THEN --1
     CLOSE c_sacc;
     l_msg_count:=1;
     l_msg_data:='IGS_AD_DUEDT_NOT_DEF';
     l_return_status:='W';
     RETURN;
   ELSE --1
     CLOSE c_sacc;
     OPEN c_dai;
     FETCH c_dai INTO l_max_duedt;
     IF c_dai%NOTFOUND OR l_max_duedt IS NULL THEN --2
       CLOSE c_dai;
       l_msg_count:=1;
       l_msg_data:='IGS_AD_DUEDT_INST_NOT_MAP';
       l_return_status:='W';
       RETURN;
     ELSE --2
       CLOSE c_dai;
       IF l_max_duedt  < TRUNC(SYSDATE) THEN --3
         l_msg_count:=1;
         l_msg_data:='IGS_AD_FINDUEDT_PASD';
         l_return_status:='W';
         RETURN;
       END IF; --3
     END IF; --2
   END IF; --1

   OPEN c_apcs(l_adm_cat,l_s_adm_prc_typ);
   FETCH c_apcs INTO l_late_appl_exists;
   CLOSE c_apcs;
   IF l_late_appl_exists IS NOT NULL THEN
     IF v_adm_appl_due_dt_alias IS NOT NULL THEN
	v_due_dt := IGS_AD_GEN_003.ADMP_GET_ADM_PERD_DT(
				v_adm_appl_due_dt_alias,
				p_adm_cal_type,
				p_adm_ci_sequence_number,
				p_adm_cat,
				p_s_adm_prc_type,
				p_course_cd,
				p_crv_version_number,
				p_acad_cal_type,
				p_location_cd,
				p_attendance_mode,
				p_attendance_type);
	IF v_due_dt IS NULL THEN
          l_msg_count:=1;
          l_msg_data:='IGS_AD_NO_DUEDT_POO';
          l_return_status:='W';
          RETURN;
	END IF;
     END IF;
   ELSE
     IF v_adm_appl_final_dt_alias IS NOT NULL THEN
       v_final_dt := IGS_AD_GEN_003.ADMP_GET_ADM_PERD_DT(
				v_adm_appl_due_dt_alias,
				p_adm_cal_type,
				p_adm_ci_sequence_number,
				p_adm_cat,
				p_s_adm_prc_type,
				p_course_cd,
				p_crv_version_number,
				p_acad_cal_type,
				p_location_cd,
				p_attendance_mode,
				p_attendance_type);

     IF v_final_dt IS NULL THEN
          l_msg_count:=1;
          l_msg_data:='IGS_AD_NO_FINALDT_POO';
          l_return_status:='W';
          RETURN;
     END IF;
     END IF;
   END IF;
   l_msg_count:=0;
   l_msg_data:=null;
   l_return_status:=null;
   RETURN;
 END validate_due_final_dt;

 PROCEDURE validate_pref_unique(
    p_person_id IN  IGS_AD_PS_APPL_INST.person_id%TYPE,
    p_adm_appl_no IN IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
    p_course_cd IN IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
    p_seq_number IN IGS_AD_PS_APPL_INST.sequence_number%TYPE,
    p_pref_number IN NUMBER,
    l_msg_count OUT NOCOPY NUMBER,
    l_msg_data  OUT NOCOPY VARCHAR2,
    l_return_status OUT NOCOPY VARCHAR2) AS
        CURSOR c_acai (
                cp_person_id                    IGS_AD_PS_APPL_INST.person_id%TYPE,
                cp_admission_appl_number        IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
                cp_nominated_course_cd          IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
                cp_acai_sequence_number         IGS_AD_PS_APPL_INST.sequence_number%TYPE) IS
        SELECT  acai.preference_number
        FROM    IGS_AD_PS_APPL_INST acai
        WHERE   acai.person_id = cp_person_id AND
                acai.admission_appl_number = cp_admission_appl_number AND
                NOT (acai.nominated_course_cd = cp_nominated_course_cd AND
                acai.sequence_number = cp_acai_sequence_number)
        ORDER BY
                acai.preference_number;
    BEGIN
        FOR v_acai IN c_acai (
                        p_person_id,
                        p_adm_appl_no,
                        p_course_cd,
                        p_seq_number) LOOP
                IF v_acai.preference_number = p_pref_number THEN
                        l_msg_count:=1;
			l_msg_data:= 'IGS_AD_PREFNUM_NOT_UNIQUE';
                        l_return_status:='E';
                        RETURN;
                END IF;
        END LOOP;
                        l_msg_count:=0;
			l_msg_data:= null;
                        l_return_status:=null;
                        RETURN;
    END validate_pref_unique;

 FUNCTION admp_val_chg_of_pref(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  l_message_name OUT NOCOPY VARCHAR2 )RETURN VARCHAR2 AS
  lv_return_value VARCHAR2(2000);
BEGIN
 IF IGS_AD_VAL_ACAI.admp_val_chg_of_pref(
  p_adm_cal_type  ,
  p_adm_ci_sequence_number ,
  p_admission_cat  ,
  p_s_admission_process_type ,
  p_course_cd ,
  p_crv_version_number ,
  p_acad_cal_type ,
  p_location_cd ,
  p_attendance_mode ,
  p_attendance_type ,
  l_message_name) THEN
    lv_return_value:='TRUE';
  ELSE
    lv_return_value:='FALSE';
  END IF;
  RETURN lv_return_value;
END admp_val_chg_of_pref;

  FUNCTION admp_val_acai_update(
  p_adm_appl_status IN VARCHAR2 ,
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_update_non_enrol_detail_ind OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 AS
    lv_return_value VARCHAR2(2000);
  BEGIN
    IF IGS_AD_VAL_ACAI.admp_val_acai_update
    (  p_adm_appl_status  ,
       p_person_id ,
       p_admission_appl_number ,
       p_nominated_course_cd ,
       p_acai_sequence_number ,
       p_message_name ,
       p_update_non_enrol_detail_ind ) THEN
      lv_return_value:='TRUE';
    ELSE
      lv_return_value:='FALSE';
    END IF;
    RETURN lv_return_value;
  END admp_val_acai_update;

  FUNCTION admp_val_acai_pref(
  p_preference_number IN NUMBER ,
  p_pref_allowed IN VARCHAR2 ,
  p_pref_limit IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )  RETURN VARCHAR2 AS
      lv_return_value VARCHAR2(2000);
  BEGIN
    IF IGS_AD_VAL_ACAI.admp_val_acai_pref (
     p_preference_number ,
     p_pref_allowed ,
     p_pref_limit ,
     p_s_admission_process_type ,
     p_message_name  ) THEN
      lv_return_value:='TRUE';
    ELSE
      lv_return_value:='FALSE';
    END IF;
    RETURN lv_return_value;
  END admp_val_acai_pref;

FUNCTION admp_val_acai_opt(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 AS
        lv_return_value VARCHAR2(2000);
BEGIN
  IF IGS_AD_VAL_ACAI.admp_val_acai_opt
  (
  p_course_cd  ,
  p_version_number  ,
  p_acad_cal_type  ,
  p_acad_ci_sequence_number  ,
  p_location_cd  ,
  p_attendance_mode ,
  p_attendance_type  ,
  p_adm_cal_type  ,
  p_adm_ci_sequence_number  ,
  p_admission_cat  ,
  p_s_admission_process_type  ,
  p_offer_ind  ,
  p_appl_dt  ,
  p_late_appl_allowed  ,
  p_message_name
  ) THEN
      lv_return_value:='TRUE';
    ELSE
      lv_return_value:='FALSE';
    END IF;
    RETURN lv_return_value;
END admp_val_acai_opt;

  FUNCTION admp_val_acai_us(
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 ,
  p_unit_set_appl IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 AS
        lv_return_value VARCHAR2(2000);
BEGIN
  IF
  IGS_AD_VAL_ACAI.admp_val_acai_us
  (
  p_unit_set_cd ,
  p_us_version_number ,
  p_course_cd  ,
  p_crv_version_number  ,
  p_acad_cal_type  ,
  p_location_cd  ,
  p_attendance_mode  ,
  p_attendance_type  ,
  p_admission_cat  ,
  p_offer_ind  ,
  p_unit_set_appl  ,
  p_message_name  ,
  p_return_type
  ) THEN
      lv_return_value:='TRUE';
    ELSE
      lv_return_value:='FALSE';
    END IF;
    RETURN lv_return_value;
END admp_val_acai_us;

FUNCTION admp_val_aa_update(
  p_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 AS
   lv_return_value VARCHAR2(2000);
BEGIN
    IF IGS_AD_VAL_AA.admp_val_aa_update
    ( p_adm_appl_status  ,
      p_message_name
    ) THEN
      lv_return_value:='TRUE';
    ELSE
      lv_return_value:='FALSE';
    END IF;
    RETURN lv_return_value;
END;

PROCEDURE final_scrn_intw_event(
            p_person_id                   IN NUMBER,
            p_admission_appl_number       IN NUMBER,
            p_nominated_course_cd         IN VARCHAR2,
            p_sequence_number             IN NUMBER,
            p_final_screening_decision    IN VARCHAR2,
            p_final_screening_date        IN DATE,
            p_panel_code                  IN VARCHAR2,
            p_raised_for                  IN VARCHAR2
) AS
  ----------------------------------------------------------------
  --Created by  : Navin Sinha
  --Date created: 19-Jun-03
  --
  --Purpose: BUG NO : 1366894 - Interview Build.
  --   This procedure would trigger the Final Screening Decision business event.
  --   It is triggered from the form IGS_AD_PANEL_DTLS_PKG (TBH for IGS_AD_PANEL_DTLS)
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------

    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);

    -- Getting the Profile value for the profile IGS_WF_ENABLE, to check if workflow is installed in the environment
    CURSOR cur_prof_value IS
        SELECT  FND_PROFILE.VALUE('IGS_WF_ENABLE') value
        FROM dual;

    l_cur_prof_value   cur_prof_value%ROWTYPE;

    -- Gets a unique sequence number
    CURSOR c_seq_num IS
          SELECT igs_ad_wf_scrn_intw_s.NEXTVAL
          FROM  dual;

    l_seq_val_screen_int_s            NUMBER;

BEGIN
  -- Checking if the Workflow is installed at the environment or not.
    OPEN cur_prof_value;
    FETCH cur_prof_value INTO l_cur_prof_value;
    CLOSE cur_prof_value;

   IF (l_cur_prof_value.value = 'Y') THEN

     -- Get the sequence value
     OPEN  c_seq_num;
     FETCH c_seq_num INTO l_seq_val_screen_int_s ;
     CLOSE c_seq_num ;

     -- initialize the wf_event_t object
     wf_event_t.Initialize(l_event_t);

     -- Adding the parameters to the parameter list
     wf_event.AddParameterToList (p_name => 'P_PERSON_ID',p_value=> p_person_id ,p_parameterlist => l_parameter_list_t);
     wf_event.AddParameterToList (p_name => 'P_ADMISSION_APPL_NUMBER', p_value => p_admission_appl_number, p_parameterlist => l_parameter_list_t);
     wf_event.AddParameterToList (p_name => 'P_NOMINATED_COURSE_CD', p_value => p_nominated_course_cd, p_ParameterList => l_parameter_list_t);
     wf_event.AddParameterToList (p_name => 'P_SEQUENCE_NUMBER', p_value => p_sequence_number, p_parameterlist => l_parameter_list_t);
     wf_event.AddParameterToList (p_name => 'P_FINAL_SCREENING_DECISION', p_value => p_final_screening_decision, p_parameterlist => l_parameter_list_t);
     wf_event.AddParameterToList (p_name => 'P_FINAL_SCREENING_DATE', p_value => p_final_screening_date, p_parameterlist => l_parameter_list_t);
     wf_event.AddParameterToList (p_name => 'P_PANEL_CODE', p_value => p_panel_code, p_parameterlist => l_parameter_list_t);

     IF p_raised_for = 'SCREENING' THEN
       -- Raise the Event
       -- Generate a unique value for the event key by concatenating the event name with a sequence value
       -- (IGS_AD_SCREEN_INT_S) and Raise the business event
       WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.ad.interview.finalscreening',
                         p_event_key  => 'FINALSCREENING' || l_seq_val_screen_int_s,
                         p_parameters => l_parameter_list_t);

       -- Deleting the Parameter list after the event is raised
       l_parameter_list_t.delete;
     ELSIF p_raised_for = 'INTERVIEW' THEN
       -- Raise the Event
       WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.ad.interview.finalinterview',
                         p_event_key  => 'FINALINTERVIEW' || l_seq_val_screen_int_s,
                         p_parameters => l_parameter_list_t);

       -- Deleting the Parameter list after the event is raised
       l_parameter_list_t.delete;
     END IF;
   END IF;
END final_scrn_intw_event;

END igs_ad_ss_appl_upd_page;

/
