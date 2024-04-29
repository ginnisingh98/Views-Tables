--------------------------------------------------------
--  DDL for Package Body IGS_AD_SS_APPL_PGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_SS_APPL_PGS_PKG" AS
/* $Header: IGSAIF9B.pls 120.2 2005/08/01 05:47:44 appldev ship $ */

  PROCEDURE reset_checklist_data(p_admission_application_type IN igs_ad_ss_appl_pgs.admission_application_type%TYPE);

  l_rowid VARCHAR2(25);
  old_references igs_ad_ss_appl_pgs%ROWTYPE;
  new_references igs_ad_ss_appl_pgs%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_page_name                         IN     VARCHAR2    DEFAULT NULL,
    x_admission_application_type        IN     VARCHAR2    DEFAULT NULL,
    x_include_ind                       IN     VARCHAR2    DEFAULT NULL,
    x_required_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_disp_order                        IN     NUMBER      DEFAULT NULL,
    x_page_disp_name                    IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ad_ss_appl_pgs
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
    new_references.page_name                         := x_page_name;
    new_references.admission_application_type        := x_admission_application_type;
    new_references.include_ind                       := x_include_ind;
    new_references.required_ind                      := x_required_ind;
    new_references.disp_order                        := x_disp_order;
    new_references.page_disp_name                    := x_page_disp_name;


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
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.admission_application_type = new_references.admission_application_type)) OR
        ((new_references.admission_application_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_ss_appl_typ_pkg.get_pk_for_validation (
                new_references.admission_application_type ,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_page_name                         IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_ss_appl_pgs
      WHERE    page_name = x_page_name
      AND      admission_application_type = x_admission_application_type
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




PROCEDURE Check_Constraints (
	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
	 Column_Value 	IN	VARCHAR2	DEFAULT NULL
	)
	 AS
BEGIN
 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'INCLUDE_IND' then
     new_references.include_ind := column_value;
 END IF;

IF upper(column_name) = 'INCLUDE_IND' OR
     column_name is null Then
     IF NOT (new_references.include_ind  IN ('Y','N')) THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
	END IF;
END IF;

END Check_Constraints;


PROCEDURE get_fk_igs_ad_ss_appl_typ (
    x_admission_appl_type               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_ss_appl_pgs
      WHERE   ((admission_application_type = x_admission_appl_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_SSAT_SSPG_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_ss_appl_typ;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_page_name                         IN     VARCHAR2    DEFAULT NULL,
    x_admission_application_type        IN     VARCHAR2    DEFAULT NULL,
    x_include_ind                       IN     VARCHAR2    DEFAULT NULL,
    x_required_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_disp_order                        IN     NUMBER      DEFAULT NULL,
    x_page_disp_name                    IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
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
      x_page_name,
      x_admission_application_type,
      x_include_ind,
      x_required_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_disp_order,
      x_page_disp_name
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.page_name,
             new_references.admission_application_type
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.page_name,
             new_references.admission_application_type
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;
    IF (p_action = 'UPDATE') THEN
      reset_checklist_data(p_admission_application_type=>new_references.admission_application_type);
    END IF;

  END After_DML;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_page_name                         IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_include_ind                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R' ,
    x_required_ind                      IN     VARCHAR2,
    x_disp_order                        IN     NUMBER,
    x_page_disp_name                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_ss_appl_pgs
      WHERE    page_name                         = x_page_name
      AND      admission_application_type        = x_admission_application_type;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

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
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_page_name                         => x_page_name,
      x_admission_application_type        => x_admission_application_type,
      x_include_ind                       => x_include_ind,
      x_required_ind                      => x_required_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_disp_order                        => x_disp_order,
      x_page_disp_name                    => x_page_disp_name
    );

    INSERT INTO igs_ad_ss_appl_pgs (
      page_name,
      admission_application_type,
      include_ind,
      required_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      disp_order,
      page_disp_name
    ) VALUES (
      new_references.page_name,
      new_references.admission_application_type,
      new_references.include_ind,
      new_references.required_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_disp_order,
      x_page_disp_name
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_page_name                         IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_include_ind                       IN     VARCHAR2,
    x_required_ind                      IN     VARCHAR2,
    x_disp_order                        IN     NUMBER      DEFAULT NULL,
    x_page_disp_name                    IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        include_ind,
        page_disp_name
      FROM  igs_ad_ss_appl_pgs
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
        ((tlinfo.include_ind = x_include_ind) OR ((tlinfo.include_ind IS NULL) AND (x_include_ind IS NULL)))
	AND ((tlinfo.page_disp_name = x_page_disp_name) OR ((tlinfo.page_disp_name IS NULL) AND (x_page_disp_name IS NULL)))
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
    x_page_name                         IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_include_ind                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R' ,
    x_required_ind                      IN     VARCHAR2,
    x_disp_order                        IN     NUMBER,
    x_page_disp_name                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
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
      x_page_name                         => x_page_name,
      x_admission_application_type        => x_admission_application_type,
      x_include_ind                       => x_include_ind,
      x_required_ind                      => x_required_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_disp_order                        => x_disp_order,
      x_page_disp_name                    => x_page_disp_name
    );

    UPDATE igs_ad_ss_appl_pgs
      SET
        include_ind                       = new_references.include_ind,
        required_ind                      = new_references.required_ind,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        disp_order                        = new_references.disp_order,
        page_disp_name                    = new_references.page_disp_name
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  After_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID
  );



  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_page_name                         IN     VARCHAR2,
    x_admission_application_type        IN     VARCHAR2,
    x_include_ind                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R' ,
    x_required_ind                      IN     VARCHAR2,
    x_disp_order                        IN     NUMBER,
    x_page_disp_name                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_ss_appl_pgs
      WHERE    page_name                         = x_page_name
      AND      admission_application_type        = x_admission_application_type;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_page_name,
        x_admission_application_type,
        x_include_ind,
        x_mode ,
	x_required_ind,
	x_disp_order,
	x_page_disp_name
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_page_name,
      x_admission_application_type,
      x_include_ind,
      x_mode ,
      x_required_ind,
      x_disp_order,
      x_page_disp_name
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : veereshwar.dixit@oracle.com
  ||  Created On : 10-DEC-2001
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igs_ad_ss_appl_pgs
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

PROCEDURE reset_checklist_data(p_admission_application_type IN igs_ad_ss_appl_pgs.admission_application_type%TYPE) AS
  /*
  ||  Created By : tray
  ||  Created On : 18-DEC-2002
  ||  Purpose : Refreshes Checklist data on setup change
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
CURSOR c_get_incomplete_appl_data IS
SELECT  ss_adm_appl_id, person_id, admission_application_type
FROM IGS_SS_ADM_APPL_STG
WHERE admission_application_type = p_admission_application_type;

CURSOR c_get_section_status(cp_person_id igs_ss_adm_appl_stg.person_id%TYPE,cp_appl_id igs_ss_adm_appl_stg.ss_adm_appl_id%TYPE,cp_section_name igs_ad_ss_appl_pgs.page_name%TYPE) IS
SELECT section, completion_status
FROM IGS_SS_AD_SEC_STAT
WHERE ss_adm_appl_id=cp_appl_id
AND   person_id=cp_person_id
AND   section=cp_section_name;

CURSOR c_get_page_setup IS
SELECT *
FROM IGS_AD_SS_APPL_PGS
WHERE admission_application_type = p_admission_application_type;

c_get_section_status_record  c_get_section_status%ROWTYPE;

BEGIN
  FOR c_get_page_setup_rec IN c_get_page_setup LOOP --1
    IF c_get_page_setup_rec.include_ind='N' THEN
      FOR c_get_incomplete_appl_data_rec IN c_get_incomplete_appl_data LOOP --1.5
        FOR c_get_section_status_rec IN c_get_section_status(c_get_incomplete_appl_data_rec.person_id,c_get_incomplete_appl_data_rec.ss_adm_appl_id,c_get_page_setup_rec.page_name) LOOP --1.75
          IF  c_get_page_setup_rec.page_name = c_get_section_status_rec.section THEN
	    DELETE
	    FROM IGS_SS_AD_SEC_STAT
	    WHERE section = c_get_page_setup_rec.page_name
	    AND   person_id = c_get_incomplete_appl_data_rec.person_id
	    AND   ss_adm_appl_id = c_get_incomplete_appl_data_rec.ss_adm_appl_id;
	  ELSE
	    NULL;
	  END IF;
        END LOOP; --1.75
      END LOOP; --1.5
    ELSIF c_get_page_setup_rec.include_ind='Y' THEN
      FOR c_get_incomplete_appl_data_rec IN c_get_incomplete_appl_data LOOP --1.5
        OPEN c_get_section_status(c_get_incomplete_appl_data_rec.person_id,c_get_incomplete_appl_data_rec.ss_adm_appl_id,c_get_page_setup_rec.page_name);
	FETCH c_get_section_status INTO c_get_section_status_record;
	  IF c_get_section_status%NOTFOUND THEN
	     INSERT INTO igs_ss_ad_sec_stat
	        (
		    ss_adm_appl_id ,
		    person_id      ,
 		    section,
		    completion_status ,
		    last_updated_by  ,
		    last_update_date,
		    creation_date    ,
   		    created_by      ,
	  	    last_update_login
    	        )
	         VALUES
                (
                   c_get_incomplete_appl_data_rec.ss_adm_appl_id,
                   c_get_incomplete_appl_data_rec.person_id,
                   c_get_page_setup_rec.page_name,
                   'NOTSTARTED',
                   c_get_page_setup_rec.last_updated_by,
                   sysdate,
                   sysdate,
                   c_get_page_setup_rec.created_by,
                   c_get_page_setup_rec.last_update_login
	        );
	  END IF;
	CLOSE c_get_section_status;
      END LOOP; --1.5
    END IF;
  END LOOP; --1
END reset_checklist_data ;

END igs_ad_ss_appl_pgs_pkg;

/
