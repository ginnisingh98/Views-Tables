--------------------------------------------------------
--  DDL for Package Body IGS_AD_APLINS_ADMREQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_APLINS_ADMREQ_PKG" AS
/* $Header: IGSAIE6B.pls 120.3 2005/10/03 08:23:34 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_aplins_admreq%ROWTYPE;
  new_references igs_ad_aplins_admreq%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_aplins_admreq_id                  IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_admission_appl_number             IN     NUMBER      ,
    x_course_cd                         IN     VARCHAR2    ,
    x_sequence_number                   IN     NUMBER      ,
    x_tracking_id                       IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 22-JUL-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_APLINS_ADMREQ
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
    new_references.aplins_admreq_id                  := x_aplins_admreq_id;
    new_references.person_id                         := x_person_id;
    new_references.admission_appl_number             := x_admission_appl_number;
    new_references.course_cd                         := x_course_cd;
    new_references.sequence_number                   := x_sequence_number;
    new_references.tracking_id                       := x_tracking_id;

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


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 22-JUL-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.admission_appl_number,
           new_references.course_cd,
           new_references.person_id,
           new_references.sequence_number,
           new_references.tracking_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 22-JUL-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.admission_appl_number = new_references.admission_appl_number) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.sequence_number = new_references.sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.admission_appl_number IS NULL) OR
         (new_references.course_cd IS NULL) OR
         (new_references.sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Ps_Appl_Inst_Pkg.Get_PKNolock_For_Validation (    -- changed the function call from  Igs_Ad_Ps_Appl_Inst_Pkg.Get_PK_For_Validation to
                new_references.person_id, 									      -- Igs_Ad_Ps_Appl_Inst_Pkg.Get_PKNolock_For_Validation (For Bug 2760811 - ADCR061
                new_references.admission_appl_number, 					      -- locking issues -- rghosh )
                new_references.course_cd,
                new_references.sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.tracking_id = new_references.tracking_id)) OR
        ((new_references.tracking_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_tr_item_pkg.get_pk_for_validation (
                new_references.tracking_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_aplins_admreq_id                  IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 22-JUL-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_aplins_admreq
      WHERE    aplins_admreq_id = x_aplins_admreq_id
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


  FUNCTION get_uk_for_validation (
    x_admission_appl_number             IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_sequence_number                   IN     NUMBER,
    x_tracking_id                       IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 22-JUL-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_aplins_admreq
      WHERE    admission_appl_number = x_admission_appl_number
      AND      course_cd = x_course_cd
      AND      person_id = x_person_id
      AND      sequence_number = x_sequence_number
      AND      tracking_id = x_tracking_id
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


  PROCEDURE get_fk_igs_ad_ps_appl_inst_all (
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 22-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  rghosh	      08-nov-2002    changed the message name in the
  ||                                 procedure get_fk_igs_ad_ps_appl_inst_all (bug #2619603)
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_aplins_admreq
      WHERE   ((admission_appl_number = x_admission_appl_number) AND
               (course_cd = x_nominated_course_cd) AND
               (person_id = x_person_id) AND
               (sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      --changed the message name -rghosh (bug #2619603)
      fnd_message.set_name ('IGS', 'IGS_AD_APLINS_ACAI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_ps_appl_inst_all;


  PROCEDURE get_fk_igs_tr_item_all (
    x_tracking_id                       IN     NUMBER
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 22-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_aplins_admreq
      WHERE   ((tracking_id = x_tracking_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_tr_item_all;

  PROCEDURE check_appl_compl_stat (
                x_tracking_id IN NUMBER,
                x_person_id IN NUMBER,
                x_admission_appl_number IN NUMBER,
                x_course_cd IN VARCHAR2 ,
                x_sequence_number IN NUMBER
              ) IS
  /*************************************************************
  Created By : rghosh
  Date Created By : 20-Feb-2003
  Purpose : When a record is getting created , the requirements do not get added after the
                    application completion status is set to SATISFIED for an application instance
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
           CURSOR c_get_adm_doc_status (
                                                  p_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
                                                  p_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
						  p_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
						  p_sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE ) IS
              SELECT  'X'
              FROM igs_ad_ps_appl_inst_all
              WHERE person_id = p_person_id
              AND admission_appl_number = p_admission_appl_number
              AND nominated_course_cd = p_nominated_course_cd
              AND sequence_number = p_sequence_number
              AND  IGS_AD_GEN_007.ADMP_GET_SADS (adm_doc_status) = 'SATISFIED';

	   CURSOR c_not_post_adm (cp_tracking_id igs_tr_item.tracking_id%TYPE) IS
	      SELECT 'X'
              FROM  igs_tr_item a,
                    igs_tr_type b
              WHERE a.tracking_id   = cp_tracking_id
              AND   b.tracking_type = a.tracking_type
              AND   b.S_TRACKING_TYPE <> 'POST_ADMISSION' ;

	  l_get_adm_doc_status VARCHAR2(1);
	  l_not_post_adm        VARCHAR2(1);

BEGIN

           OPEN c_get_adm_doc_status (
                         x_person_id,
                         x_admission_appl_number,
                         x_course_cd,
                         x_sequence_number  );
	 FETCH c_get_adm_doc_status INTO l_get_adm_doc_status;
	  OPEN c_not_post_adm (x_tracking_id) ;
	 FETCH c_not_post_adm INTO l_not_post_adm ;
         IF c_get_adm_doc_status % FOUND AND c_not_post_adm%FOUND THEN
	    Fnd_Message.Set_name('IGS','IGS_AD_NOT_INST_UPD_REQ_DOC');
            IGS_GE_MSG_STACK.ADD;
            CLOSE c_get_adm_doc_status;
            CLOSE c_not_post_adm;
	    App_Exception.Raise_Exception;
	 END IF;
         CLOSE c_get_adm_doc_status;
         CLOSE c_not_post_adm;

END  check_appl_compl_stat;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2	   ,
    x_aplins_admreq_id                  IN     NUMBER      ,
    x_person_id                         IN     NUMBER      ,
    x_admission_appl_number             IN     NUMBER      ,
    x_course_cd                         IN     VARCHAR2    ,
    x_sequence_number                   IN     NUMBER      ,
    x_tracking_id                       IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 22-JUL-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  apadegal        2-09-2005      changed teh call for check_adm_appl_inst_stat for IGS.M
  */

  --begin apadegal adtd001 igs.m
  -- cursor to find the System Tracking type of the given Tracking item
  CURSOR c_track_type (cp_tracking_id igs_tr_item.tracking_id%TYPE) IS
  SELECT ttype.S_TRACKING_TYPE
  FROM  igs_tr_item  titem, igs_tr_type ttype
  WHERE titem.tracking_id   = cp_tracking_id  AND
        titem.tracking_type = ttype.tracking_type;

  lv_tracking_type IGS_TR_TYPE.S_TRACKING_TYPE%TYPE;

    --end  apadegal adtd001 igs.m
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_aplins_admreq_id,
      x_person_id,
      x_admission_appl_number,
      x_course_cd,
      x_sequence_number,
      x_tracking_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );


   OPEN c_track_type(x_tracking_id);
   FETCH c_track_type INTO lv_tracking_type;
   CLOSE c_track_type;

   -- BEGIN APADEGAL adtd001 igs.m

    IF 	lv_tracking_type ='ADM_PROCESSING'
    THEN
	    igs_ad_gen_002.check_adm_appl_inst_stat(
	      nvl(x_person_id,old_references.person_id),
	      nvl(x_admission_appl_number,old_references.admission_appl_number),
	      nvl(x_course_cd,old_references.course_cd),
	      nvl(x_sequence_number,old_references.sequence_number),
	      'N'		 -- reconsider phase, (cannot assign admission processing requirements in proceed phase);
	    );
    END IF;
    IF 	lv_tracking_type ='POST_ADMISSION'
    THEN
	    igs_ad_gen_002.check_adm_appl_inst_stat(
	      nvl(x_person_id,old_references.person_id),
	      nvl(x_admission_appl_number,old_references.admission_appl_number),
	      nvl(x_course_cd,old_references.course_cd),
	      nvl(x_sequence_number,old_references.sequence_number),
	      'Y'	      -- proceed phase, (cann assign post admission  requirements in proceed phase);
	    );
    END IF;

   -- END APADEGAL adtd001 igs.m
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.aplins_admreq_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
      check_appl_compl_stat  (
                         new_references.tracking_id,
                         new_references.person_id,
                         new_references.admission_appl_number,
                         new_references.course_cd,
                         new_references.sequence_number  );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
      check_appl_compl_stat  (
                         new_references.tracking_id,
                         new_references.person_id,
                         new_references.admission_appl_number,
                         new_references.course_cd,
                         new_references.sequence_number  );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.aplins_admreq_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_appl_compl_stat  (
                         new_references.tracking_id,
                         new_references.person_id,
                         new_references.admission_appl_number,
                         new_references.course_cd,
                         new_references.sequence_number  );
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_appl_compl_stat  (
                         new_references.tracking_id,
                         new_references.person_id,
                         new_references.admission_appl_number,
                         new_references.course_cd,
                         new_references.sequence_number  );
    END IF;
    l_rowid := NULL; --Bug:2863832
  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_aplins_admreq_id                  IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_tracking_id                       IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 22-JUL-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  ravishar      05/30/05        Security related changes
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_aplins_admreq
      WHERE    aplins_admreq_id                  = x_aplins_admreq_id;

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
    ELSIF (X_MODE IN ('R', 'S')) THEN
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

    x_aplins_admreq_id := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_aplins_admreq_id                  => x_aplins_admreq_id,
      x_person_id                         => x_person_id,
      x_admission_appl_number             => x_admission_appl_number,
      x_course_cd                         => x_course_cd,
      x_sequence_number                   => x_sequence_number,
      x_tracking_id                       => x_tracking_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

  IF (x_mode = 'S') THEN
     igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_ad_aplins_admreq (
      aplins_admreq_id,
      person_id,
      admission_appl_number,
      course_cd,
      sequence_number,
      tracking_id,
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
      igs_ad_aplins_admreq_s.NEXTVAL,
      new_references.person_id,
      new_references.admission_appl_number,
      new_references.course_cd,
      new_references.sequence_number,
      new_references.tracking_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    )RETURNING aplins_admreq_id INTO x_aplins_admreq_id;
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

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
    x_aplins_admreq_id                  IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_tracking_id                       IN     NUMBER
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 22-JUL-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        admission_appl_number,
        course_cd,
        sequence_number,
        tracking_id
      FROM  igs_ad_aplins_admreq
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
        (tlinfo.person_id = x_person_id)
        AND (tlinfo.admission_appl_number = x_admission_appl_number)
        AND (tlinfo.course_cd = x_course_cd)
        AND (tlinfo.sequence_number = x_sequence_number)
        AND (tlinfo.tracking_id = x_tracking_id)
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
    x_aplins_admreq_id                  IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_tracking_id                       IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 22-JUL-2001
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
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_aplins_admreq_id                  => x_aplins_admreq_id,
      x_person_id                         => x_person_id,
      x_admission_appl_number             => x_admission_appl_number,
      x_course_cd                         => x_course_cd,
      x_sequence_number                   => x_sequence_number,
      x_tracking_id                       => x_tracking_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF (X_MODE IN ('R', 'S')) THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_ad_aplins_admreq
      SET
        person_id                         = new_references.person_id,
        admission_appl_number             = new_references.admission_appl_number,
        course_cd                         = new_references.course_cd,
        sequence_number                   = new_references.sequence_number,
        tracking_id                       = new_references.tracking_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
       igs_sc_gen_001.set_ctx('R');
     END IF;
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
 END IF;


EXCEPTION
  WHEN OTHERS THEN
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
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
    x_aplins_admreq_id                  IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_tracking_id                       IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 22-JUL-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_aplins_admreq
      WHERE    aplins_admreq_id                  = x_aplins_admreq_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_aplins_admreq_id,
        x_person_id,
        x_admission_appl_number,
        x_course_cd,
        x_sequence_number,
        x_tracking_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_aplins_admreq_id,
      x_person_id,
      x_admission_appl_number,
      x_course_cd,
      x_sequence_number,
      x_tracking_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 22-JUL-2001
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ravishar      05/27/05        Security related changes
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
 DELETE FROM igs_ad_aplins_admreq
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
       igs_sc_gen_001.set_ctx('R');
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


END igs_ad_aplins_admreq_pkg;

/
