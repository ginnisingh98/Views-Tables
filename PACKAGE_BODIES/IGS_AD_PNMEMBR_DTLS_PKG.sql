--------------------------------------------------------
--  DDL for Package Body IGS_AD_PNMEMBR_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PNMEMBR_DTLS_PKG" AS
/* $Header: IGSAIH2B.pls 120.4 2006/01/29 22:29:30 pfotedar ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_pnmembr_dtls%ROWTYPE;
  new_references igs_ad_pnmembr_dtls%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_role_type_code                         IN     VARCHAR2,
    x_member_person_id                  IN     NUMBER,
    x_interview_date                    IN     DATE,
    x_interview_time                    IN     DATE,
    x_location_cd                       IN     VARCHAR2,
    x_room_id                           IN     NUMBER,
    x_member_decision_code              IN     VARCHAR2,
    x_member_decision_type              IN     VARCHAR2,
    x_member_decision_date              IN     DATE,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ad_pnmembr_dtls
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;
    old_references := NULL;

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
    new_references.panel_dtls_id                     := x_panel_dtls_id;
    new_references.role_type_code                         := x_role_type_code;
    new_references.member_person_id                  := x_member_person_id;
    new_references.interview_date                    := TRUNC(x_interview_date);
    new_references.interview_time                    := x_interview_time;
    new_references.location_cd                       := x_location_cd;
    new_references.room_id                           := x_room_id;
    new_references.member_decision_code              := x_member_decision_code;
    new_references.member_decision_type              := x_member_decision_type;
    new_references.member_decision_date              := TRUNC(x_member_decision_date);
    new_references.attribute_category                := x_attribute_category;
    new_references.attribute1                        := x_attribute1;
    new_references.attribute2                        := x_attribute2;
    new_references.attribute3                        := x_attribute3;
    new_references.attribute4                        := x_attribute4;
    new_references.attribute5                        := x_attribute5;
    new_references.attribute6                        := x_attribute6;
    new_references.attribute7                        := x_attribute7;
    new_references.attribute8                        := x_attribute8;
    new_references.attribute9                        := x_attribute9;
    new_references.attribute10                       := x_attribute10;
    new_references.attribute11                       := x_attribute11;
    new_references.attribute12                       := x_attribute12;
    new_references.attribute13                       := x_attribute13;
    new_references.attribute14                       := x_attribute14;
    new_references.attribute15                       := x_attribute15;
    new_references.attribute16                       := x_attribute16;
    new_references.attribute17                       := x_attribute17;
    new_references.attribute18                       := x_attribute18;
    new_references.attribute19                       := x_attribute19;
    new_references.attribute20                       := x_attribute20;

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
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.panel_dtls_id = new_references.panel_dtls_id)) OR
        ((new_references.panel_dtls_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_panel_dtls_pkg.get_pk_for_validation (
                new_references.panel_dtls_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.member_decision_code = new_references.member_decision_code) AND
         (old_references.member_decision_type = new_references.member_decision_type)) OR
        ((new_references.member_decision_code IS NULL) OR
         (new_references.member_decision_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_code_classes_pkg.get_uk_For_validation (
                new_references.member_decision_code,
                new_references.member_decision_type ,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_location_pkg.get_pk_for_validation (
                new_references.location_cd ,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.room_id = new_references.room_id)) OR
        ((new_references.room_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_room_pkg.get_pk_for_validation (
                new_references.room_id ,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.member_person_id = new_references.member_person_id)) OR
        ((new_references.member_person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.member_person_id
        )THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
         IGS_AD_GEN_001.SET_TOKEN('From IGS_PE_PERSON  ->Parameter: Person_Id ');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;


  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    igs_ad_pnmembr_nots_pkg.get_fk_igs_ad_pnmembr_dtls (
      old_references.panel_dtls_id,
      old_references.member_person_id
    );
  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_panel_dtls_id                     IN     NUMBER,
    x_member_person_id                  IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_pnmembr_dtls
      WHERE    panel_dtls_id = x_panel_dtls_id
      AND      member_person_id = x_member_person_id
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


  PROCEDURE get_fk_igs_ad_panel_dtls (
    x_panel_dtls_id                     IN     NUMBER
  ) AS
  /*
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_pnmembr_dtls
      WHERE   ((panel_dtls_id = x_panel_dtls_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_PNLMBMR_PNDTLS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_panel_dtls;


  PROCEDURE get_ufk_igs_ad_code_classes (
    x_name                              IN     VARCHAR2,
    x_class                             IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_pnmembr_dtls
      WHERE   ((member_decision_code = x_name) AND
               (member_decision_type = x_class));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_PNLMBMR_CODE_CLS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ad_code_classes;


  PROCEDURE get_fk_igs_ad_location (
    x_location_cd                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_pnmembr_dtls
      WHERE   ((location_cd = x_location_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_PNLMBMR_LOC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_location;


  PROCEDURE get_fk_igs_ad_room (
    x_room_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_pnmembr_dtls
      WHERE   ((room_id = x_room_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_PNLMBMR_ROOM_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_room;

  PROCEDURE beforerowinsertupdatedelete1 (
                             p_inserting BOOLEAN,
                             p_updating BOOLEAN,
                             p_deleting BOOLEAN ) IS

    ----------------------------------------------------------------
    --Created by  : Navin Sinha
    --Date created: 16-Jun-03
    --
    --Purpose: BUG NO : 1366894 - Interview Build.
    --
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What
    ----------------------------------------------------------------
    -- Cursor to check if person type of interviewer exists.
    CURSOR c_interviewer_exist IS
      SELECT 'x'
      FROM   IGS_PE_TYP_INSTANCES_ALL TI,
        IGS_PE_PERSON_TYPES PT
       WHERE  ti.person_id = new_references.member_person_id
      AND pt.system_type = 'INTERVIEWER'
      AND    (ti.end_date is NULL OR (ti.end_date IS NOT NULL AND trunc(ti.end_date) > trunc(SYSDATE)))
      AND     TI.PERSON_TYPE_CODE = PT.PERSON_TYPE_CODE;

    l_interviewer_exist VARCHAR2(1);

    -- Cursor to check the application date of the application
    CURSOR c_appl_dt IS
    SELECT appl_dt
    FROM   igs_ad_panel_dtls pd,
           igs_ad_appl aa
    WHERE  pd.panel_dtls_id =  new_references.panel_dtls_id
    AND    pd.admission_appl_number = aa.admission_appl_number
    AND    pd.person_id = aa.person_id;

    l_appl_dt          igs_ad_appl.appl_dt%TYPE;

    -- Cursor to check final decision associated to panel code.
    CURSOR c_chk_final_decision (cp_panel_dtls_id igs_ad_panel_dtls.panel_dtls_id%TYPE) IS
    SELECT *
    FROM   igs_ad_panel_dtls
    WHERE  panel_dtls_id = cp_panel_dtls_id;

    rec_chk_final_decision c_chk_final_decision%ROWTYPE;
    l_final_decision igs_ad_code_classes.system_status%TYPE;

    l_member_decision igs_ad_code_classes.system_status%TYPE;
    l_old_member_decision igs_ad_code_classes.system_status%TYPE;

   -- Cursor to check if member Decisions is mapped to the system defaulted Decisions of 'PENDING'
   CURSOR cur_dflt_panl_cd IS
   SELECT *
   FROM   igs_ad_code_classes
   WHERE  system_status = 'PENDING'
   AND    name = new_references.member_decision_code
   AND    class = new_references.member_decision_type
   AND    closed_ind = 'N'
   AND    CLASS_TYPE_CODE='ADM_CODE_CLASSES';

   rec_dflt_panl_cd    cur_dflt_panl_cd%ROWTYPE;

    CURSOR c_instance_dets  IS
   SELECT  person_id,admission_appl_number,nominated_course_Cd,sequence_number
   FROM  igs_ad_panel_dtls pdtls,
         igs_Ad_pnmembr_Dtls  pmbr
   WHERE  pdtls.panel_Dtls_id = pmbr.panel_dtls_id
   AND    pmbr.panel_dtls_id = NVL(old_references.panel_dtls_id, new_references.panel_dtls_id);

    instance_dets_rec    c_instance_dets%ROWTYPE;

   CURSOR c_intvw_pnl_exsts (cp_instance_rec c_instance_dets%ROWTYPE   )  IS
   SELECT   'X'
   FROM igs_ad_intvw_pnls pnls,
        igs_ad_panel_dtls pdtls
   WHERE  pnls.panel_type_code='INTERVIEW'
   AND  pnls.panel_code = pdtls.panel_code
   AND pdtls.person_id = cp_instance_rec.person_id
   AND  pdtls.admission_appl_number = cp_instance_rec.admission_appl_number
   AND  pdtls.nominated_course_Cd  = cp_instance_rec.nominated_course_Cd
   AND pdtls.sequence_number  = cp_instance_rec.sequence_number;

   intvw_pnl_exsts_rec      c_intvw_pnl_exsts%ROWTYPE;

   -- Cursor to get the system defaulted Decisions mapped to 'PENDING'
   CURSOR cur_dflt_panlm_cd(cp_panel_type_code igs_ad_intvw_pnls.panel_type_code%TYPE) IS
   SELECT *
   FROM   igs_ad_code_classes
   WHERE  system_status = 'PENDING'
   AND    class = cp_panel_type_code           --'INTERVIEW', 'SCREENING', 'FINAL_SCREENING', 'FINAL_INTERVIEW'
   AND    NVL(system_default, 'N') = 'Y'
   AND    closed_ind = 'N'
   AND    CLASS_TYPE_CODE='ADM_CODE_CLASSES';

   rec_dflt_panlm_cd cur_dflt_panlm_cd%ROWTYPE;

   --get the panel type code
   CURSOR c_panel_type_code  IS
   SELECT ip.panel_type_Code
   FROM   igs_ad_intvw_pnls ip,
	  igs_ad_panel_dtls pd
   WHERE  ip.panel_code = pd.panel_code
     AND pd.panel_dtls_id = new_references.panel_dtls_id;

   l_panel_type_Code igs_ad_intvw_pnls.panel_type_Code%TYPE;

   -- Cursor to get the meaning for lookup code
   CURSOR c_lkup_cd_mean(cp_lookup_type igs_lookups_view.lookup_type%TYPE, cp_lookup_code igs_lookups_view.lookup_code%TYPE) IS
   SELECT meaning
   FROM   igs_lookups_view
   WHERE  lookup_type = cp_lookup_type
   AND    lookup_code = cp_lookup_code;

   l_class_meaning    igs_lookups_view.meaning%TYPE;
   l_sys_stat_meaning igs_lookups_view.meaning%TYPE;
   l_dec_type igs_ad_code_classes.class%TYPE;

  BEGIN
    IF NVL(p_inserting,FALSE) THEN
      -- A Person added to a panel must have the system person type of Interviewer. Else raise an error message.
      OPEN c_interviewer_exist;
      FETCH c_interviewer_exist INTO l_interviewer_exist;
        IF c_interviewer_exist%NOTFOUND THEN
          CLOSE c_interviewer_exist;
          fnd_message.set_name('IGS','IGS_AD_NO_INTERVIEWER_PTY'); -- Message: The person you are adding does not have the person type of Interviewer.
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
        END IF;
        IF c_interviewer_exist%ISOPEN THEN
          CLOSE c_interviewer_exist;
        END IF;

       IF  new_references.member_decision_code IS NULL THEN
         --get the panel type code
         OPEN c_panel_type_code;
         FETCH c_panel_type_code INTO l_panel_type_Code;
         CLOSE c_panel_type_code;

	 IF l_panel_type_Code = 'SCREENING' THEN
                l_dec_type :=  'SCREENING';
         ELSE
                l_dec_type :=  'INTERVIEW';
         END IF;

	 OPEN  cur_dflt_panlm_cd(l_dec_type);
         FETCH cur_dflt_panlm_cd INTO rec_dflt_panlm_cd;
          IF cur_dflt_panlm_cd%NOTFOUND THEN
             CLOSE cur_dflt_panlm_cd;
            -- Get the value for message token CLASS_MEANING
            OPEN  c_lkup_cd_mean(l_dec_type, 'PENDING');
            FETCH c_lkup_cd_mean INTO l_class_meaning;
            CLOSE c_lkup_cd_mean;

            -- Get the value for message token SYS_STAT_MEANING
            OPEN  c_lkup_cd_mean('INTR_DECSN', l_dec_type);
            FETCH c_lkup_cd_mean INTO l_sys_stat_meaning;
            CLOSE c_lkup_cd_mean;

            fnd_message.set_name('IGS','IGS_AD_NO_DECISION_CD_SETUP');  -- Message: Unable to assign panel members to the application instance.
            fnd_message.set_token('CLASS_MEANING', l_class_meaning);
            fnd_message.set_token('SYS_STAT_MEANING', l_sys_stat_meaning);
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
          ELSE
            --defaulting final_decision_type, final_decision_type
            new_references.member_decision_code := rec_dflt_panlm_cd.name;
            new_references.member_decision_type :=  rec_dflt_panlm_cd.class;
	    CLOSE cur_dflt_panlm_cd;
          END IF;
       END IF;
    END IF;

    IF NVL(p_inserting,FALSE) OR NVL(p_updating,FALSE) THEN
        -- Check if member Decisions is mapped to the system defaulted Decisions of 'PENDING'
        OPEN cur_dflt_panl_cd;
        FETCH cur_dflt_panl_cd INTO rec_dflt_panl_cd;
        IF cur_dflt_panl_cd%NOTFOUND THEN
          CLOSE cur_dflt_panl_cd;

          IF ((new_references.member_decision_date IS NULL AND new_references.member_decision_code  IS NOT NULL) OR
             (new_references.member_decision_date IS NOT NULL AND new_references.member_decision_code  IS NULL)) THEN
            -- Decision Date must be entered if a Decision is entered. If the Decision is saved without Decision Date then raise an error message.
            fnd_message.set_name('IGS','IGS_AD_MAND_DECISION_INFO'); -- Message: Decision and Decision Date must be entered.
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
          END IF;
        ELSE
           IF new_references.member_decision_date IS NOT NULL  THEN
                fnd_message.set_name('IGS','IGS_AD_MAND_DECISION_INFO'); -- Message: Decision and Decision Date must be entered.
                igs_ge_msg_stack.add;
                app_exception.raise_exception;
           END IF;
        END IF;
        IF cur_dflt_panl_cd%ISOPEN THEN
          CLOSE cur_dflt_panl_cd;
        END IF;

        OPEN  c_appl_dt;
        FETCH c_appl_dt INTO l_appl_dt;
        CLOSE c_appl_dt;

        IF  NVL(new_references.interview_date,sysdate)  < l_appl_dt THEN
             fnd_message.set_name('IGS','IGS_AD_APPL_DATE_ERROR');        -- NAME cannot be less than Application Date
             fnd_message.set_token ('NAME',fnd_message.get_string('IGS','IGS_AD_INTVW_DATE'));  -- Message: Decision Date
             igs_ge_msg_stack.add;
             app_exception.raise_exception;
        END IF;

        IF new_references.member_decision_date IS NOT NULL THEN
          -- Decision Date entered must be greater than or equal to the Application Date. Else raise an Error message.
          IF  new_references.member_decision_date  < l_appl_dt OR new_references.member_decision_date > SYSDATE THEN
             fnd_message.set_name('IGS','IGS_AD_DECISION_DATE'); -- Decision Date Can Neither  be greater than System Date nor be less than Application Date
             igs_ge_msg_stack.add;
             app_exception.raise_exception;
          END IF;
        END IF;
        -- A screening decision for a reviewer may be updated if no final screening decision exists for the panel. Else raise an Error message.
        -- Check final decision associated to panel code.
        OPEN  c_chk_final_decision(new_references.panel_dtls_id);
        FETCH c_chk_final_decision INTO rec_chk_final_decision;
        CLOSE c_chk_final_decision;
        l_final_decision := igs_ad_gen_013.get_sys_code_status(rec_chk_final_decision.final_decision_code,
                                                             rec_chk_final_decision.final_decision_type);

        IF NVL(l_final_decision,'PENDING') <> 'PENDING' THEN
              fnd_message.set_name('IGS','IGS_AD_PNL_FNL_DECISION_EXITS');  -- Message: Cannot update/insert  panel member's information when the panel final decision is already recorded.
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
       END IF;
     END IF;

    IF  NVL(p_inserting,FALSE) OR NVL(p_updating,FALSE) OR NVL(p_deleting,FALSE) THEN
      IF new_references.member_decision_type = 'SCREENING' OR old_references.member_decision_type = 'SCREENING' THEN
          OPEN  c_instance_dets;
          FETCH c_instance_dets INTO instance_dets_rec;
          CLOSE c_instance_dets;

          OPEN c_intvw_pnl_exsts(instance_dets_rec);
          FETCH c_intvw_pnl_exsts INTO intvw_pnl_exsts_rec;
          IF c_intvw_pnl_exsts%FOUND THEN
              CLOSE c_intvw_pnl_exsts;
              fnd_message.set_name('IGS','IGS_AD_INTVW_PNL_EXITS');  -- Message: Cannot update screening information when interview panel is already associated to the application instance.
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
          END IF;
          CLOSE c_intvw_pnl_exsts;
      END IF;
      -- If a panel is closed then the interviewer decisions cannot be entered/updated and adding/deleting of interviewers is prohibited.
      -- Check closed flag associated to panel code.
      OPEN  c_chk_final_decision(NVL(old_references.panel_dtls_id, new_references.panel_dtls_id));
      FETCH c_chk_final_decision INTO rec_chk_final_decision;
      CLOSE c_chk_final_decision;

      IF NVL(rec_chk_final_decision.closed_flag,'N') <> 'N' THEN
        fnd_message.set_name('IGS','IGS_AD_PNL_IS_CLOSED');  -- Message: Cannot update or delete a closed panel.
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF NVL(p_updating,FALSE) THEN

      -- If a screening decision entered, is mapped to the system screening decision of 'VOIDED' then the screening decision may not be updated for the reviewer.
      -- Throw an error message if the screening decision is attempted to be updated from 'VOIDED' to any other status.
      -- Check the member's decision associated with panel member.
      l_member_decision := igs_ad_gen_013.get_sys_code_status(new_references.member_decision_code,
                                                              new_references.member_decision_type);
      -- Check the old member's decision associated with panel member.
      l_old_member_decision := igs_ad_gen_013.get_sys_code_status(old_references.member_decision_code,
                                                                  old_references.member_decision_type);
      IF l_old_member_decision = 'VOIDED' AND l_member_decision <> 'VOIDED' THEN
        fnd_message.set_name('IGS','IGS_AD_NO_UPD_VOID_DECISION');  -- Message: Cannot update the reviewer's decision as it is mapped to a status of Voided.
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

    END IF;

    IF NVL(p_deleting,FALSE) THEN
      -- A reviewer may be deleted from a panel if there is no existing screening decision and no final screening decision exists for the panel.
      -- If a reviewer having screening decision is deleted then raise an error message and fail deletion.

      -- Check final decision associated to panel code.
      OPEN  c_chk_final_decision(old_references.panel_dtls_id);
      FETCH c_chk_final_decision INTO rec_chk_final_decision;
      CLOSE c_chk_final_decision;
      l_final_decision := igs_ad_gen_013.get_sys_code_status(rec_chk_final_decision.final_decision_code,
                                                             rec_chk_final_decision.final_decision_type);

      -- Check member decision associated with panel member.
      l_member_decision := igs_ad_gen_013.get_sys_code_status(old_references.member_decision_code,
                                                              old_references.member_decision_type);

      IF NVL(l_final_decision,'*') <> 'PENDING' OR NVL(l_member_decision,'*') <> 'PENDING' THEN
        fnd_message.set_name('IGS','IGS_AD_PNL_DECISION_EXITS');  -- Message: Cannot delete the panel member when the decision is already recorded.
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
  END beforerowinsertupdatedelete1;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_role_type_code                         IN     VARCHAR2,
    x_member_person_id                  IN     NUMBER,
    x_interview_date                    IN     DATE,
    x_interview_time                    IN     DATE,
    x_location_cd                       IN     VARCHAR2,
    x_room_id                           IN     NUMBER,
    x_member_decision_code              IN     VARCHAR2,
    x_member_decision_type              IN     VARCHAR2,
    x_member_decision_date              IN     DATE,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
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
      x_panel_dtls_id,
      x_role_type_code,
      x_member_person_id,
      x_interview_date,
      x_interview_time,
      x_location_cd,
      x_room_id,
      x_member_decision_code,
      x_member_decision_type,
      x_member_decision_date,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.panel_dtls_id,
             new_references.member_person_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      beforerowinsertupdatedelete1( p_inserting => TRUE , p_updating => FALSE, p_deleting=> FALSE);
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      beforerowinsertupdatedelete1( p_inserting => FALSE , p_updating => TRUE, p_deleting=> FALSE);
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      beforerowinsertupdatedelete1( p_inserting => FALSE , p_updating => FALSE, p_deleting=> TRUE);
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.panel_dtls_id,
             new_references.member_person_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      beforerowinsertupdatedelete1( p_inserting => TRUE , p_updating => FALSE, p_deleting=> FALSE);
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      beforerowinsertupdatedelete1( p_inserting => FALSE , p_updating => FALSE, p_deleting=> TRUE);
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_role_type_code                         IN     VARCHAR2,
    x_member_person_id                  IN     NUMBER,
    x_interview_date                    IN     DATE,
    x_interview_time                    IN     DATE,
    x_location_cd                       IN     VARCHAR2,
    x_room_id                           IN     NUMBER,
    x_member_decision_code              IN     VARCHAR2,
    x_member_decision_type              IN     VARCHAR2,
    x_member_decision_date              IN     DATE,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ravishar      05/27/05        Security related changes
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_mode                       VARCHAR2(1);
  BEGIN
      l_mode := NVL(x_mode, 'R');
    x_last_update_date := SYSDATE;
    IF (l_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (l_mode IN ('R','S')) THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'IGS_AD_PNMEMBR_DTLS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_panel_dtls_id                     => x_panel_dtls_id,
      x_role_type_code                         => x_role_type_code,
      x_member_person_id                  => x_member_person_id,
      x_interview_date                    => x_interview_date,
      x_interview_time                    => x_interview_time,
      x_location_cd                       => x_location_cd,
      x_room_id                           => x_room_id,
      x_member_decision_code              => x_member_decision_code,
      x_member_decision_type              => x_member_decision_type,
      x_member_decision_date              => x_member_decision_date,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_ad_pnmembr_dtls (
      panel_dtls_id,
      role_type_code,
      member_person_id,
      interview_date,
      interview_time,
      location_cd,
      room_id,
      member_decision_code,
      member_decision_type,
      member_decision_date,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.panel_dtls_id,
      new_references.role_type_code,
      new_references.member_person_id,
      new_references.interview_date,
      new_references.interview_time,
      new_references.location_cd,
      new_references.room_id,
      new_references.member_decision_code,
      new_references.member_decision_type,
      new_references.member_decision_date,
      new_references.attribute_category,
      new_references.attribute1,
      new_references.attribute2,
      new_references.attribute3,
      new_references.attribute4,
      new_references.attribute5,
      new_references.attribute6,
      new_references.attribute7,
      new_references.attribute8,
      new_references.attribute9,
      new_references.attribute10,
      new_references.attribute11,
      new_references.attribute12,
      new_references.attribute13,
      new_references.attribute14,
      new_references.attribute15,
      new_references.attribute16,
      new_references.attribute17,
      new_references.attribute18,
      new_references.attribute19,
      new_references.attribute20,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


EXCEPTION
  WHEN OTHERS THEN
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
 END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_role_type_code                         IN     VARCHAR2,
    x_member_person_id                  IN     NUMBER,
    x_interview_date                    IN     DATE,
    x_interview_time                    IN     DATE,
    x_location_cd                       IN     VARCHAR2,
    x_room_id                           IN     NUMBER,
    x_member_decision_code              IN     VARCHAR2,
    x_member_decision_type              IN     VARCHAR2,
    x_member_decision_date              IN     DATE,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        role_type_code,
        interview_date,
        interview_time,
        location_cd,
        room_id,
        member_decision_code,
        member_decision_type,
        member_decision_date,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20
      FROM  igs_ad_pnmembr_dtls
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.role_type_code = x_role_type_code)
        AND ((TRUNC(tlinfo.interview_date) = TRUNC(x_interview_date)) OR ((tlinfo.interview_date IS NULL) AND (X_interview_date IS NULL)))
        AND ((tlinfo.interview_time = x_interview_time) OR ((tlinfo.interview_time IS NULL) AND (X_interview_time IS NULL)))
        AND ((tlinfo.location_cd = x_location_cd) OR ((tlinfo.location_cd IS NULL) AND (X_location_cd IS NULL)))
        AND ((tlinfo.room_id = x_room_id) OR ((tlinfo.room_id IS NULL) AND (X_room_id IS NULL)))
        AND (tlinfo.member_decision_code = x_member_decision_code)
        AND (tlinfo.member_decision_type = x_member_decision_type)
        AND ((TRUNC(tlinfo.member_decision_date) = TRUNC(x_member_decision_date)) OR ((tlinfo.member_decision_date IS NULL) AND (X_member_decision_date IS NULL)))
        AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (X_attribute_category IS NULL)))
        AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (X_attribute1 IS NULL)))
        AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (X_attribute2 IS NULL)))
        AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (X_attribute3 IS NULL)))
        AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (X_attribute4 IS NULL)))
        AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (X_attribute5 IS NULL)))
        AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (X_attribute6 IS NULL)))
        AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (X_attribute7 IS NULL)))
        AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (X_attribute8 IS NULL)))
        AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (X_attribute9 IS NULL)))
        AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (X_attribute10 IS NULL)))
        AND ((tlinfo.attribute11 = x_attribute11) OR ((tlinfo.attribute11 IS NULL) AND (X_attribute11 IS NULL)))
        AND ((tlinfo.attribute12 = x_attribute12) OR ((tlinfo.attribute12 IS NULL) AND (X_attribute12 IS NULL)))
        AND ((tlinfo.attribute13 = x_attribute13) OR ((tlinfo.attribute13 IS NULL) AND (X_attribute13 IS NULL)))
        AND ((tlinfo.attribute14 = x_attribute14) OR ((tlinfo.attribute14 IS NULL) AND (X_attribute14 IS NULL)))
        AND ((tlinfo.attribute15 = x_attribute15) OR ((tlinfo.attribute15 IS NULL) AND (X_attribute15 IS NULL)))
        AND ((tlinfo.attribute16 = x_attribute16) OR ((tlinfo.attribute16 IS NULL) AND (X_attribute16 IS NULL)))
        AND ((tlinfo.attribute17 = x_attribute17) OR ((tlinfo.attribute17 IS NULL) AND (X_attribute17 IS NULL)))
        AND ((tlinfo.attribute18 = x_attribute18) OR ((tlinfo.attribute18 IS NULL) AND (X_attribute18 IS NULL)))
        AND ((tlinfo.attribute19 = x_attribute19) OR ((tlinfo.attribute19 IS NULL) AND (X_attribute19 IS NULL)))
        AND ((tlinfo.attribute20 = x_attribute20) OR ((tlinfo.attribute20 IS NULL) AND (X_attribute20 IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_role_type_code                         IN     VARCHAR2,
    x_member_person_id                  IN     NUMBER,
    x_interview_date                    IN     DATE,
    x_interview_time                    IN     DATE,
    x_location_cd                       IN     VARCHAR2,
    x_room_id                           IN     NUMBER,
    x_member_decision_code              IN     VARCHAR2,
    x_member_decision_type              IN     VARCHAR2,
    x_member_decision_date              IN     DATE,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ravishar      05/27/05        Security related changes
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_mode                       VARCHAR2(1);
  BEGIN
      l_mode := NVL(x_mode, 'R');
    x_last_update_date := SYSDATE;
    IF (l_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (l_mode IN ('R','S')) THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'IGS_AD_PNMEMBR_DTLS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_panel_dtls_id                     => x_panel_dtls_id,
      x_role_type_code                         => x_role_type_code,
      x_member_person_id                  => x_member_person_id,
      x_interview_date                    => x_interview_date,
      x_interview_time                    => x_interview_time,
      x_location_cd                       => x_location_cd,
      x_room_id                           => x_room_id,
      x_member_decision_code              => x_member_decision_code,
      x_member_decision_type              => x_member_decision_type,
      x_member_decision_date              => x_member_decision_date,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_ad_pnmembr_dtls
      SET
        role_type_code                         = new_references.role_type_code,
        interview_date                    = new_references.interview_date,
        interview_time                    = new_references.interview_time,
        location_cd                       = new_references.location_cd,
        room_id                           = new_references.room_id,
        member_decision_code              = new_references.member_decision_code,
        member_decision_type              = new_references.member_decision_type,
        member_decision_date              = new_references.member_decision_date,
        attribute_category                = new_references.attribute_category,
        attribute1                        = new_references.attribute1,
        attribute2                        = new_references.attribute2,
        attribute3                        = new_references.attribute3,
        attribute4                        = new_references.attribute4,
        attribute5                        = new_references.attribute5,
        attribute6                        = new_references.attribute6,
        attribute7                        = new_references.attribute7,
        attribute8                        = new_references.attribute8,
        attribute9                        = new_references.attribute9,
        attribute10                       = new_references.attribute10,
        attribute11                       = new_references.attribute11,
        attribute12                       = new_references.attribute12,
        attribute13                       = new_references.attribute13,
        attribute14                       = new_references.attribute14,
        attribute15                       = new_references.attribute15,
        attribute16                       = new_references.attribute16,
        attribute17                       = new_references.attribute17,
        attribute18                       = new_references.attribute18,
        attribute19                       = new_references.attribute19,
        attribute20                       = new_references.attribute20,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

 IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
        igs_sc_gen_001.unset_ctx('R');
     END IF;
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
 END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
    END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_role_type_code                         IN     VARCHAR2,
    x_member_person_id                  IN     NUMBER,
    x_interview_date                    IN     DATE,
    x_interview_time                    IN     DATE,
    x_location_cd                       IN     VARCHAR2,
    x_room_id                           IN     NUMBER,
    x_member_decision_code              IN     VARCHAR2,
    x_member_decision_type              IN     VARCHAR2,
    x_member_decision_date              IN     DATE,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_pnmembr_dtls
      WHERE    panel_dtls_id                     = x_panel_dtls_id
      AND      member_person_id                  = x_member_person_id;
      l_mode   VARCHAR2(1);
  BEGIN
      l_mode := NVL(x_mode, 'R');
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_panel_dtls_id,
        x_role_type_code,
        x_member_person_id,
        x_interview_date,
        x_interview_time,
        x_location_cd,
        x_room_id,
        x_member_decision_code,
        x_member_decision_type,
        x_member_decision_date,
        x_attribute_category,
        x_attribute1,
        x_attribute2,
        x_attribute3,
        x_attribute4,
        x_attribute5,
        x_attribute6,
        x_attribute7,
        x_attribute8,
        x_attribute9,
        x_attribute10,
        x_attribute11,
        x_attribute12,
        x_attribute13,
        x_attribute14,
        x_attribute15,
        x_attribute16,
        x_attribute17,
        x_attribute18,
        x_attribute19,
        x_attribute20,
        l_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_panel_dtls_id,
      x_role_type_code,
      x_member_person_id,
      x_interview_date,
      x_interview_time,
      x_location_cd,
      x_room_id,
      x_member_decision_code,
      x_member_decision_type,
      x_member_decision_date,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      l_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : Navin Sinha
  ||  Created On : 16-JUN-2003
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ravishar      5/30/2005        Security related changes
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_ad_pnmembr_dtls
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
     END IF;
     app_exception.raise_exception;
 END IF;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (x_mode = 'S') THEN
      igs_sc_gen_001.unset_ctx('R');
    END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
  END delete_row;


END igs_ad_pnmembr_dtls_pkg;

/
