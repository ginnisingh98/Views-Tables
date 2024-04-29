--------------------------------------------------------
--  DDL for Package Body IGS_FI_FTCI_ACCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FTCI_ACCTS_PKG" AS
/* $Header: IGSSID0B.pls 120.3 2005/06/05 23:42:09 appldev  $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_ftci_accts%ROWTYPE;
  new_references igs_fi_ftci_accts%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_acct_id                           IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_natural_account_segment           IN     VARCHAR2,
    x_rev_account_cd                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_version_number               IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_residency_status_cd               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_unit_level                        IN     VARCHAR2,
    x_unit_type_id                      IN     NUMBER,
    x_unit_mode                         IN     VARCHAR2,
    x_unit_class                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gurprsin     02-Jun-2005      Enh 3442712, Added 4 new columns.
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_ftci_accts
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
    new_references.acct_id                           := x_acct_id;
    new_references.fee_type                          := x_fee_type;
    new_references.fee_cal_type                      := x_fee_cal_type;
    new_references.fee_ci_sequence_number            := x_fee_ci_sequence_number;
    new_references.order_sequence                    := x_order_sequence;
    new_references.natural_account_segment           := x_natural_account_segment;
    new_references.rev_account_cd                    := x_rev_account_cd;
    new_references.location_cd                       := x_location_cd;
    new_references.attendance_type                   := x_attendance_type;
    new_references.attendance_mode                   := x_attendance_mode;
    new_references.course_cd                         := x_course_cd;
    new_references.crs_version_number                := x_crs_version_number;
    new_references.unit_cd                           := x_unit_cd;
    new_references.unit_version_number               := x_unit_version_number;
    new_references.org_unit_cd                       := x_org_unit_cd;
    new_references.residency_status_cd               := x_residency_status_cd;
    new_references.uoo_id                            := x_uoo_id;
    new_references.unit_level                        := x_unit_level;
    new_references.unit_type_id                      := x_unit_type_id;
    new_references.unit_mode                         := x_unit_mode;
    new_references.unit_class                        := x_unit_class;

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
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gurprsin     02-Jun-2005      Enh 3442712, Added 4 new columns. in get_uk2_for_validation method
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk1_for_validation (
           new_references.fee_type,
           new_references.fee_cal_type,
           new_references.fee_ci_sequence_number,
           new_references.order_sequence
         )
       ) THEN
      fnd_message.set_name ('IGS','IGS_FI_ACCT_DUP_SEQ');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF ( get_uk2_for_validation (
           new_references.fee_type,
           new_references.fee_cal_type,
           new_references.fee_ci_sequence_number,
           new_references.location_cd,
           new_references.attendance_type,
           new_references.attendance_mode,
           new_references.course_cd,
           new_references.crs_version_number,
           new_references.unit_cd,
           new_references.unit_version_number,
           new_references.org_unit_cd,
           new_references.residency_status_cd,
           new_references.uoo_id,
           new_references.unit_level,
           new_references.unit_type_id,
           new_references.unit_mode,
           new_references.unit_class
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_FI_ACCT_ATTR_COMB_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;


  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gurprsin     02-Jun-2005      Enh 3442712, Added 4 new methods to check unit_level,unit_type_id,
  ||                                unit_clss,unit_mode existence in respective master table
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_type IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_f_typ_ca_inst_pkg.get_pk_for_validation (
                new_references.fee_type,
                new_references.fee_cal_type,
                new_references.fee_ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.rev_account_cd = new_references.rev_account_cd)) OR
        ((new_references.rev_account_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_acc_pkg.get_pk_for_validation (
                new_references.rev_account_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_location_pkg.get_pk_for_validation (
                new_references.location_cd,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_atd_type_pkg.get_pk_for_validation (
                new_references.attendance_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.attendance_mode = new_references.attendance_mode)) OR
        ((new_references.attendance_mode IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_atd_mode_pkg.get_pk_for_validation (
                new_references.attendance_mode
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.crs_version_number = new_references.crs_version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.crs_version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_ver_pkg.get_pk_for_validation (
                new_references.course_cd,
                new_references.crs_version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.unit_version_number = new_references.unit_version_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.unit_version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ver_pkg.get_pk_for_validation (
                new_references.unit_cd,
                new_references.unit_version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (
                new_references.uoo_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_level = new_references.unit_level)) OR
        ((new_references.unit_level IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_level_pkg.get_pk_for_validation (
                new_references.unit_level
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_type_id = new_references.unit_type_id)) OR
        ((new_references.unit_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_type_lvl_pkg.get_pk_for_validation (
                new_references.unit_type_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_mode = new_references.unit_mode)) OR
        ((new_references.unit_mode IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_unit_mode_pkg.get_pk_for_validation (
                new_references.unit_mode
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_class = new_references.unit_class)) OR
        ((new_references.unit_class IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_unit_class_pkg.get_pk_for_validation (
                new_references.unit_class
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_acct_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ftci_accts
      WHERE    acct_id = x_acct_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%ROWTYPE;

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


  FUNCTION get_uk1_for_validation (
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_order_sequence                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ftci_accts
      WHERE    fee_type = x_fee_type
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      order_sequence = x_order_sequence
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (TRUE);
    ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk1_for_validation;

  FUNCTION get_uk2_for_validation (
    x_fee_type                IN     VARCHAR2,
    x_fee_cal_type            IN     VARCHAR2,
    x_fee_ci_sequence_number  IN     NUMBER,
    x_location_cd             IN     VARCHAR2,
    x_attendance_type         IN     VARCHAR2,
    x_attendance_mode         IN     VARCHAR2,
    x_course_cd               IN     VARCHAR2,
    x_crs_version_number      IN     NUMBER,
    x_unit_cd                 IN     VARCHAR2,
    x_unit_version_number     IN     NUMBER,
    x_org_unit_cd             IN     VARCHAR2,
    x_residency_status_cd     IN     VARCHAR2,
    x_uoo_id                  IN     NUMBER,
    x_unit_level              IN     VARCHAR2,
    x_unit_type_id            IN     NUMBER,
    x_unit_mode               IN     VARCHAR2,
    x_unit_class              IN     VARCHAR2
  )RETURN BOOLEAN AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gurprsin     02-Jun-2005      Enh 3442712, Added 4 new columns.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ftci_accts
      WHERE    fee_type = x_fee_type
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      ((location_cd = x_location_cd) OR (x_location_cd IS NULL AND location_cd IS NULL))
      AND      ((attendance_type = x_attendance_type) OR (x_attendance_type IS NULL AND attendance_type IS NULL))
      AND      ((attendance_mode = x_attendance_mode) OR (x_attendance_mode IS NULL AND attendance_mode IS NULL))
      AND      ((course_cd = x_course_cd) OR (x_course_cd IS NULL AND course_cd IS NULL))
      AND      ((crs_version_number = x_crs_version_number) OR (x_crs_version_number IS NULL AND crs_version_number IS NULL))
      AND      ((unit_cd = x_unit_cd) OR (x_unit_cd IS NULL OR unit_cd IS NULL))
      AND      ((unit_version_number = x_unit_version_number) OR (x_unit_version_number IS NULL AND unit_version_number IS NULL))
      AND      ((org_unit_cd = x_org_unit_cd) OR (x_org_unit_cd IS NULL AND org_unit_cd IS NULL))
      AND      ((residency_status_cd = x_residency_status_cd) OR (x_residency_status_cd IS NULL AND residency_status_cd IS NULL))
      AND      ((uoo_id = x_uoo_id) OR (x_uoo_id IS NULL AND uoo_id IS NULL))
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
      AND      ((unit_level = x_unit_level) OR (x_unit_level IS NULL AND unit_level IS NULL))
      AND      ((unit_type_id = x_unit_type_id) OR (x_unit_type_id IS NULL AND unit_type_id IS NULL))
      AND      ((unit_mode = x_unit_mode) OR (x_unit_mode IS NULL AND unit_mode IS NULL))
      AND      ((unit_class = x_unit_class) OR (x_unit_class IS NULL AND unit_class IS NULL));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (TRUE);
    ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;
  END get_uk2_for_validation;

  PROCEDURE get_fk_igs_fi_f_typ_ca_inst (
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ftci_accts
      WHERE   ((fee_cal_type = x_fee_cal_type) AND
               (fee_ci_sequence_number = x_fee_ci_sequence_number) AND
               (fee_type = x_fee_type));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FICA_FTCI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_f_typ_ca_inst;


  PROCEDURE get_fk_igs_fi_acc (
    x_account_cd                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ftci_accts
      WHERE   ((rev_account_cd = x_account_cd));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FICA_ACC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_acc;


  PROCEDURE get_fk_igs_ad_location (
    x_location_cd                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ftci_accts
      WHERE   ((location_cd = x_location_cd));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FICA_LOC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_location;


  PROCEDURE get_fk_igs_en_atd_type (
    x_attendance_type                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ftci_accts
      WHERE   ((attendance_type = x_attendance_type));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FICA_ATT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_atd_type;


  PROCEDURE get_fk_igs_en_atd_mode (
    x_attendance_mode                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ftci_accts
      WHERE   ((attendance_mode = x_attendance_mode));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FICA_AM_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_atd_mode;


  PROCEDURE get_fk_igs_ps_ver (
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ftci_accts
      WHERE   ((course_cd = x_course_cd) AND
               (crs_version_number = x_version_number));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FICA_SCA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_ver;

  PROCEDURE get_fk_igs_ps_unit_ver (
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ftci_accts
      WHERE   ((unit_cd = x_unit_cd) AND
               (unit_version_number = x_version_number));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FICA_UN_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_unit_ver;




  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ftci_accts
      WHERE   ((uoo_id = x_uoo_id));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_FICA_UOO_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ps_unit_ofr_opt;

  PROCEDURE get_fk_igs_as_unit_mode (
   x_unit_mode              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : gurpreet.s.singh@oracle.com
  ||  Created On : 03-MAY-2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_ftci_accts
      WHERE   ((unit_mode = x_unit_mode));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_ACCTS_UM_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_as_unit_mode;



  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_acct_id                           IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_natural_account_segment           IN     VARCHAR2,
    x_rev_account_cd                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_version_number               IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_residency_status_cd               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_unit_level                        IN     VARCHAR2,
    x_unit_type_id                      IN     NUMBER,
    x_unit_mode                         IN     VARCHAR2,
    x_unit_class                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gurprsin     02-Jun-2005      Enh 3442712, Added 4 new columns.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_acct_id,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_order_sequence,
      x_natural_account_segment,
      x_rev_account_cd,
      x_location_cd,
      x_attendance_type,
      x_attendance_mode,
      x_course_cd,
      x_crs_version_number,
      x_unit_cd,
      x_unit_version_number,
      x_org_unit_cd,
      x_residency_status_cd,
      x_uoo_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_unit_level,
      x_unit_type_id,
      x_unit_mode,
      x_unit_class
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.acct_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.acct_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

    l_rowid := NULL;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_acct_id                           IN OUT NOCOPY NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_natural_account_segment           IN     VARCHAR2,
    x_rev_account_cd                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_version_number               IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_residency_status_cd               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_unit_level                        IN     VARCHAR2,
    x_unit_type_id                      IN     NUMBER,
    x_unit_mode                         IN     VARCHAR2,
    x_unit_class                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gurprsin     02-Jun-2005      Enh 3442712, Added 4 new columns.
  ||  (reverse chronological order - newest change first)
  */

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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_FTCI_ACCTS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT igs_fi_ftci_accts_s.NEXTVAL INTO x_acct_id FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_acct_id                           => x_acct_id,
      x_fee_type                          => x_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_order_sequence                    => x_order_sequence,
      x_natural_account_segment           => x_natural_account_segment,
      x_rev_account_cd                    => x_rev_account_cd,
      x_location_cd                       => x_location_cd,
      x_attendance_type                   => x_attendance_type,
      x_attendance_mode                   => x_attendance_mode,
      x_course_cd                         => x_course_cd,
      x_crs_version_number                => x_crs_version_number,
      x_unit_cd                           => x_unit_cd,
      x_unit_version_number               => x_unit_version_number,
      x_org_unit_cd                       => x_org_unit_cd,
      x_residency_status_cd               => x_residency_status_cd,
      x_uoo_id                            => x_uoo_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_unit_level                        => x_unit_level,
      x_unit_type_id                      => x_unit_type_id,
      x_unit_mode                         => x_unit_mode,
      x_unit_class                        => x_unit_class
    );

    INSERT INTO igs_fi_ftci_accts (
      acct_id,
      fee_type,
      fee_cal_type,
      fee_ci_sequence_number,
      order_sequence,
      natural_account_segment,
      rev_account_cd,
      location_cd,
      attendance_type,
      attendance_mode,
      course_cd,
      crs_version_number,
      unit_cd,
      unit_version_number,
      org_unit_cd,
      residency_status_cd,
      uoo_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      unit_level,
      unit_type_id,
      unit_mode,
      unit_class
    ) VALUES (
      new_references.acct_id,
      new_references.fee_type,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.order_sequence,
      new_references.natural_account_segment,
      new_references.rev_account_cd,
      new_references.location_cd,
      new_references.attendance_type,
      new_references.attendance_mode,
      new_references.course_cd,
      new_references.crs_version_number,
      new_references.unit_cd,
      new_references.unit_version_number,
      new_references.org_unit_cd,
      new_references.residency_status_cd,
      new_references.uoo_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      new_references.unit_level,
      new_references.unit_type_id,
      new_references.unit_mode,
      new_references.unit_class
    ) RETURNING ROWID,ACCT_ID INTO x_rowid,x_acct_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_acct_id                           IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_natural_account_segment           IN     VARCHAR2,
    x_rev_account_cd                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_version_number               IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_residency_status_cd               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_level                        IN     VARCHAR2,
    x_unit_type_id                      IN     NUMBER,
    x_unit_mode                         IN     VARCHAR2,
    x_unit_class                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gurprsin     02-Jun-2005      Enh 3442712, Added 4 new columns.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        fee_type,
        fee_cal_type,
        fee_ci_sequence_number,
        order_sequence,
        natural_account_segment,
        rev_account_cd,
        location_cd,
        attendance_type,
        attendance_mode,
        course_cd,
        crs_version_number,
        unit_cd,
        unit_version_number,
        org_unit_cd,
        residency_status_cd,
        uoo_id,
        unit_level,
        unit_type_id,
        unit_mode,
        unit_class
      FROM  igs_fi_ftci_accts
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
        (tlinfo.fee_type = x_fee_type)
        AND (tlinfo.fee_cal_type = x_fee_cal_type)
        AND (tlinfo.fee_ci_sequence_number = x_fee_ci_sequence_number)
        AND (tlinfo.order_sequence = x_order_sequence)
        AND ((tlinfo.natural_account_segment = x_natural_account_segment) OR ((tlinfo.natural_account_segment IS NULL) AND (x_natural_account_segment IS NULL)))
        AND ((tlinfo.rev_account_cd = x_rev_account_cd) OR ((tlinfo.rev_account_cd IS NULL) AND (X_rev_account_cd IS NULL)))
        AND ((tlinfo.location_cd = x_location_cd) OR ((tlinfo.location_cd IS NULL) AND (X_location_cd IS NULL)))
        AND ((tlinfo.attendance_type = x_attendance_type) OR ((tlinfo.attendance_type IS NULL) AND (X_attendance_type IS NULL)))
        AND ((tlinfo.attendance_mode = x_attendance_mode) OR ((tlinfo.attendance_mode IS NULL) AND (X_attendance_mode IS NULL)))
        AND ((tlinfo.course_cd = x_course_cd) OR ((tlinfo.course_cd IS NULL) AND (X_course_cd IS NULL)))
        AND ((tlinfo.crs_version_number = x_crs_version_number) OR ((tlinfo.crs_version_number IS NULL) AND (X_crs_version_number IS NULL)))
        AND ((tlinfo.unit_cd = x_unit_cd) OR ((tlinfo.unit_cd IS NULL) AND (X_unit_cd IS NULL)))
        AND ((tlinfo.unit_version_number = x_unit_version_number) OR ((tlinfo.unit_version_number IS NULL) AND (X_unit_version_number IS NULL)))
        AND ((tlinfo.org_unit_cd = x_org_unit_cd) OR ((tlinfo.org_unit_cd IS NULL) AND (X_org_unit_cd IS NULL)))
        AND ((tlinfo.residency_status_cd = x_residency_status_cd) OR ((tlinfo.residency_status_cd IS NULL) AND (X_residency_status_cd IS NULL)))
        AND ((tlinfo.uoo_id = x_uoo_id) OR ((tlinfo.uoo_id IS NULL) AND (X_uoo_id IS NULL)))
        AND ((tlinfo.unit_level = x_unit_level) OR ((tlinfo.unit_level IS NULL) AND (X_unit_level IS NULL)))
        AND ((tlinfo.unit_type_id = x_unit_type_id) OR ((tlinfo.unit_type_id IS NULL) AND (X_unit_type_id IS NULL)))
        AND ((tlinfo.unit_mode = x_unit_mode) OR ((tlinfo.unit_mode IS NULL) AND (X_unit_mode IS NULL)))
        AND ((tlinfo.unit_class = x_unit_class) OR ((tlinfo.unit_class IS NULL) AND (X_unit_class IS NULL)))
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
    x_acct_id                           IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_natural_account_segment           IN     VARCHAR2,
    x_rev_account_cd                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_version_number               IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_residency_status_cd               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_unit_level                        IN     VARCHAR2,
    x_unit_type_id                      IN     NUMBER,
    x_unit_mode                         IN     VARCHAR2,
    x_unit_class                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gurprsin     02-Jun-2005      Enh 3442712, Added 4 new columns.
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_FTCI_ACCTS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_acct_id                           => x_acct_id,
      x_fee_type                          => x_fee_type,
      x_fee_cal_type                      => x_fee_cal_type,
      x_fee_ci_sequence_number            => x_fee_ci_sequence_number,
      x_order_sequence                    => x_order_sequence,
      x_natural_account_segment           => x_natural_account_segment,
      x_rev_account_cd                    => x_rev_account_cd,
      x_location_cd                       => x_location_cd,
      x_attendance_type                   => x_attendance_type,
      x_attendance_mode                   => x_attendance_mode,
      x_course_cd                         => x_course_cd,
      x_crs_version_number                => x_crs_version_number,
      x_unit_cd                           => x_unit_cd,
      x_unit_version_number               => x_unit_version_number,
      x_org_unit_cd                       => x_org_unit_cd,
      x_residency_status_cd               => x_residency_status_cd,
      x_uoo_id                            => x_uoo_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_unit_level                        => x_unit_level,
      x_unit_type_id                      => x_unit_type_id,
      x_unit_mode                         => x_unit_mode,
      x_unit_class                        => x_unit_class
    );

    IF (x_mode = 'R') THEN
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

    UPDATE igs_fi_ftci_accts
      SET
        fee_type                          = new_references.fee_type,
        fee_cal_type                      = new_references.fee_cal_type,
        fee_ci_sequence_number            = new_references.fee_ci_sequence_number,
        order_sequence                    = new_references.order_sequence,
        natural_account_segment           = new_references.natural_account_segment,
        rev_account_cd                    = new_references.rev_account_cd,
        location_cd                       = new_references.location_cd,
        attendance_type                   = new_references.attendance_type,
        attendance_mode                   = new_references.attendance_mode,
        course_cd                         = new_references.course_cd,
        crs_version_number                = new_references.crs_version_number,
        unit_cd                           = new_references.unit_cd,
        unit_version_number               = new_references.unit_version_number,
        org_unit_cd                       = new_references.org_unit_cd,
        residency_status_cd               = new_references.residency_status_cd,
        uoo_id                            = new_references.uoo_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        unit_level                        = new_references.unit_level,
        unit_type_id                      = new_references.unit_type_id,
        unit_mode                         = new_references.unit_mode,
        unit_class                        = new_references.unit_class
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_acct_id                           IN OUT NOCOPY NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_natural_account_segment           IN     VARCHAR2,
    x_rev_account_cd                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_version_number               IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_residency_status_cd               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_unit_level                        IN     VARCHAR2,
    x_unit_type_id                      IN     NUMBER,
    x_unit_mode                         IN     VARCHAR2,
    x_unit_class                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gurprsin     02-Jun-2005      Enh 3442712, Added 4 new columns.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_ftci_accts
      WHERE    acct_id                           = x_acct_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_acct_id,
        x_fee_type,
        x_fee_cal_type,
        x_fee_ci_sequence_number,
        x_order_sequence,
        x_natural_account_segment,
        x_rev_account_cd,
        x_location_cd,
        x_attendance_type,
        x_attendance_mode,
        x_course_cd,
        x_crs_version_number,
        x_unit_cd,
        x_unit_version_number,
        x_org_unit_cd,
        x_residency_status_cd,
        x_uoo_id,
        x_mode,
        x_unit_level,
        x_unit_type_id,
        x_unit_mode,
        x_unit_class
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_acct_id,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_order_sequence,
      x_natural_account_segment,
      x_rev_account_cd,
      x_location_cd,
      x_attendance_type,
      x_attendance_mode,
      x_course_cd,
      x_crs_version_number,
      x_unit_cd,
      x_unit_version_number,
      x_org_unit_cd,
      x_residency_status_cd,
      x_uoo_id,
      x_mode,
      x_unit_level,
      x_unit_type_id,
      x_unit_mode,
      x_unit_class
    );

  END add_row;

  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : venkata.vutukuri@oracle.com
  ||  Created On : 15-MAY-2003
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

    DELETE FROM igs_fi_ftci_accts
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_ftci_accts_pkg;

/
