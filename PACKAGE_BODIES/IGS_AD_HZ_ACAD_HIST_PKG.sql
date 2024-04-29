--------------------------------------------------------
--  DDL for Package Body IGS_AD_HZ_ACAD_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_HZ_ACAD_HIST_PKG" AS
/* $Header: IGSAIB7B.pls 120.1 2005/06/28 04:24:21 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_hz_acad_hist%ROWTYPE;
  new_references igs_ad_hz_acad_hist%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_recalc_total_cp_attempted         IN     NUMBER      DEFAULT NULL,
    x_recalc_total_cp_earned            IN     NUMBER      DEFAULT NULL,
    x_recalc_total_unit_gp              IN     NUMBER      DEFAULT NULL,
    x_recalc_tot_gpa_uts_attempted      IN     NUMBER      DEFAULT NULL,
    x_recalc_inst_gpa                   IN     VARCHAR2    DEFAULT NULL,
    x_recalc_grading_scale_id           IN     NUMBER      DEFAULT NULL,
    x_selfrep_total_cp_attempted        IN     NUMBER      DEFAULT NULL,
    x_selfrep_total_cp_earned           IN     NUMBER      DEFAULT NULL,
    x_selfrep_total_unit_gp             IN     NUMBER      DEFAULT NULL,
    x_selfrep_tot_gpa_uts_attemp        IN     NUMBER      DEFAULT NULL,
    x_selfrep_inst_gpa                  IN     VARCHAR2    DEFAULT NULL,
    x_selfrep_grading_scale_id          IN     NUMBER      DEFAULT NULL,
    x_selfrep_weighted_gpa              IN     VARCHAR2    DEFAULT NULL,
    x_selfrep_rank_in_class             IN     NUMBER      DEFAULT NULL,
    x_selfrep_weighed_rank              IN     VARCHAR2    DEFAULT NULL,
    x_selfrep_class_size                IN     NUMBER      DEFAULT NULL,
    x_attribute_category                IN     VARCHAR2    DEFAULT NULL,
    x_attribute1                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute2                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute3                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute4                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute5                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute6                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute7                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute8                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute9                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute10                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute11                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute12                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute13                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute14                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute15                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute16                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute17                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute18                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute19                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute20                       IN     VARCHAR2    DEFAULT NULL,
    x_hz_acad_hist_id                   IN     NUMBER      DEFAULT NULL,
    x_education_id                      IN     NUMBER      DEFAULT NULL,
    x_current_inst                      IN     VARCHAR2    DEFAULT NULL,
    x_degree_attempted                  IN     VARCHAR2    DEFAULT NULL,
    x_comments                          IN     VARCHAR2    DEFAULT NULL,
    x_planned_completion_date           IN     DATE        DEFAULT NULL,
    x_transcript_required               IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vdixit.in	      23-JULY-2001      Added new column transcript_required
  ||					to the tbh calls

  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_HZ_ACAD_HIST
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
    new_references.recalc_total_cp_attempted         := x_recalc_total_cp_attempted;
    new_references.recalc_total_cp_earned            := x_recalc_total_cp_earned;
    new_references.recalc_total_unit_gp              := x_recalc_total_unit_gp;
    new_references.recalc_tot_gpa_uts_attempted      := x_recalc_tot_gpa_uts_attempted;
    new_references.recalc_inst_gpa                   := x_recalc_inst_gpa;
    new_references.recalc_grading_scale_id           := x_recalc_grading_scale_id;
    new_references.selfrep_total_cp_attempted        := x_selfrep_total_cp_attempted;
    new_references.selfrep_total_cp_earned           := x_selfrep_total_cp_earned;
    new_references.selfrep_total_unit_gp             := x_selfrep_total_unit_gp;
    new_references.selfrep_tot_gpa_uts_attemp        := x_selfrep_tot_gpa_uts_attemp;
    new_references.selfrep_inst_gpa                  := x_selfrep_inst_gpa;
    new_references.selfrep_grading_scale_id          := x_selfrep_grading_scale_id;
    new_references.selfrep_weighted_gpa              := x_selfrep_weighted_gpa;
    new_references.selfrep_rank_in_class             := x_selfrep_rank_in_class;
    new_references.selfrep_weighed_rank              := x_selfrep_weighed_rank;
    new_references.selfrep_class_size                := x_selfrep_class_size;
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
    new_references.hz_acad_hist_id                   := x_hz_acad_hist_id;
    new_references.education_id                      := x_education_id;
    new_references.current_inst                      := x_current_inst;
    new_references.degree_attempted            := x_degree_attempted;
    new_references.comments                          := x_comments;
    new_references.planned_completion_date           := TRUNC(x_planned_completion_date);
    new_references.transcript_required               := x_transcript_required;

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


  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By : Veereshwar Dixit
  Date Created By : 24-July-2001
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  vdixit.in	      23-JULY-2001      Added check constraint for the
					new column transcript_required

  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'TRANSCRIPT_REQUIRED'  THEN
        new_references.transcript_required := column_value;
      END IF;


      /*IF Upper(Column_Name) = 'TRANSCRIPT_REQUIRED' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.transcript_required in ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;*/

  END Check_Constraints;
  PROCEDURE check_parent_existance AS
  CURSOR cur_rowid IS
         SELECT   rowid
         FROM     hz_education
         WHERE    education_id = new_references.education_id ;
       lv_rowid cur_rowid%RowType;
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vdixit.in	      23-JULY-2001      Added new column transcript_required
  ||					to the tbh calls
  */
  BEGIN

    IF (((old_references.education_id = new_references.education_id)) OR
        ((new_references.education_id IS NULL))) THEN
      NULL;
    ELSE
     Open cur_rowid;
       Fetch cur_rowid INTO lv_rowid;
       IF (cur_rowid%NOTFOUND) THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
       END IF;
     Close cur_rowid;

    END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_hz_acad_hist_id            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vdixit.in	      23-JULY-2001      Added new column transcript_required
  ||					to the tbh calls
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_hz_acad_hist
      WHERE    hz_acad_hist_id = x_hz_acad_hist_id
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

  PROCEDURE get_fk_hz_education (
    x_education_id                       IN     NUMBER
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_hz_acad_hist
      WHERE   ((education_id = x_education_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_education;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_recalc_total_cp_attempted         IN     NUMBER      DEFAULT NULL,
    x_recalc_total_cp_earned            IN     NUMBER      DEFAULT NULL,
    x_recalc_total_unit_gp              IN     NUMBER      DEFAULT NULL,
    x_recalc_tot_gpa_uts_attempted      IN     NUMBER      DEFAULT NULL,
    x_recalc_inst_gpa                   IN     VARCHAR2    DEFAULT NULL,
    x_recalc_grading_scale_id           IN     NUMBER      DEFAULT NULL,
    x_selfrep_total_cp_attempted        IN     NUMBER      DEFAULT NULL,
    x_selfrep_total_cp_earned           IN     NUMBER      DEFAULT NULL,
    x_selfrep_total_unit_gp             IN     NUMBER      DEFAULT NULL,
    x_selfrep_tot_gpa_uts_attemp        IN     NUMBER      DEFAULT NULL,
    x_selfrep_inst_gpa                  IN     VARCHAR2    DEFAULT NULL,
    x_selfrep_grading_scale_id          IN     NUMBER      DEFAULT NULL,
    x_selfrep_weighted_gpa              IN     VARCHAR2    DEFAULT NULL,
    x_selfrep_rank_in_class             IN     NUMBER      DEFAULT NULL,
    x_selfrep_weighed_rank              IN     VARCHAR2    DEFAULT NULL,
    x_selfrep_class_size                IN     NUMBER      DEFAULT NULL,
    x_attribute_category                IN     VARCHAR2    DEFAULT NULL,
    x_attribute1                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute2                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute3                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute4                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute5                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute6                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute7                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute8                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute9                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute10                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute11                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute12                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute13                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute14                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute15                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute16                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute17                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute18                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute19                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute20                       IN     VARCHAR2    DEFAULT NULL,
    x_hz_acad_hist_id                   IN     NUMBER      DEFAULT NULL,
    x_education_id                      IN     NUMBER      DEFAULT NULL,
    x_current_inst                      IN     VARCHAR2    DEFAULT NULL,
    x_degree_attempted                  IN     VARCHAR2 ,
    x_program_type_attempted            IN     VARCHAR2 ,
    x_comments                          IN     VARCHAR2    DEFAULT NULL,
    x_planned_completion_date           IN     DATE        DEFAULT NULL,
    x_transcript_required               IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vdixit.in	      23-JULY-2001      Added new column transcript_required
  ||					to the tbh calls
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_recalc_total_cp_attempted,
      x_recalc_total_cp_earned,
      x_recalc_total_unit_gp,
      x_recalc_tot_gpa_uts_attempted,
      x_recalc_inst_gpa,
      x_recalc_grading_scale_id,
      x_selfrep_total_cp_attempted,
      x_selfrep_total_cp_earned,
      x_selfrep_total_unit_gp,
      x_selfrep_tot_gpa_uts_attemp,
      x_selfrep_inst_gpa,
      x_selfrep_grading_scale_id,
      x_selfrep_weighted_gpa,
      x_selfrep_rank_in_class,
      x_selfrep_weighed_rank,
      x_selfrep_class_size,
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
      x_hz_acad_hist_id,
      x_education_id,
      x_current_inst,
      x_degree_attempted,
      x_comments,
      x_planned_completion_date,
      x_transcript_required,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
		new_references.hz_acad_hist_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      Check_Constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
    NULL;
      -- Call all the procedures related to Before Delete.
     -- check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
		new_references.hz_acad_hist_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      Check_Constraints;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_recalc_total_cp_attempted         IN     NUMBER,
    x_recalc_total_cp_earned            IN     NUMBER,
    x_recalc_total_unit_gp              IN     NUMBER,
    x_recalc_tot_gpa_uts_attempted      IN     NUMBER,
    x_recalc_inst_gpa                   IN     VARCHAR2,
    x_recalc_grading_scale_id           IN     NUMBER,
    x_selfrep_total_cp_attempted        IN     NUMBER,
    x_selfrep_total_cp_earned           IN     NUMBER,
    x_selfrep_total_unit_gp             IN     NUMBER,
    x_selfrep_tot_gpa_uts_attemp        IN     NUMBER,
    x_selfrep_inst_gpa                  IN     VARCHAR2,
    x_selfrep_grading_scale_id          IN     NUMBER,
    x_selfrep_weighted_gpa              IN     VARCHAR2,
    x_selfrep_rank_in_class             IN     NUMBER,
    x_selfrep_weighed_rank              IN     VARCHAR2,
    x_selfrep_class_size                IN     NUMBER DEFAULT NULL,
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
    x_hz_acad_hist_id                   IN OUT NOCOPY NUMBER,
    x_education_id                      IN     NUMBER,
    x_current_inst                      IN     VARCHAR2,
    x_degree_attempted                  IN     VARCHAR2 ,
    x_program_type_attempted            IN     VARCHAR2 ,
    x_comments                          IN     VARCHAR2,
    x_planned_completion_date           IN     DATE,
    x_transcript_required               IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN VARCHAR2
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vdixit.in	      23-JULY-2001      Added new column transcript_required
  ||					to the tbh calls
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_hz_acad_hist
      WHERE    hz_acad_hist_id	= x_hz_acad_hist_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_mode VARCHAR2(1);
  BEGIN

    l_mode := NVL(x_mode,'R');

    x_last_update_date := SYSDATE;
    IF (l_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (l_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
      x_request_id:=FND_GLOBAL.CONC_REQUEST_ID;
      x_program_id:=FND_GLOBAL.CONC_PROGRAM_ID;
      x_program_application_id:=FND_GLOBAL.PROG_APPL_ID;
      IF (x_request_id = -1 ) THEN
        x_request_id:=NULL;
        x_program_id:=NULL;
        x_program_application_id:=NULL;
        x_program_update_date:=NULL;
      ELSE
        x_program_update_date:=SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    X_HZ_ACAD_HIST_ID := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_recalc_total_cp_attempted         => x_recalc_total_cp_attempted,
      x_recalc_total_cp_earned            => x_recalc_total_cp_earned,
      x_recalc_total_unit_gp              => x_recalc_total_unit_gp,
      x_recalc_tot_gpa_uts_attempted      => x_recalc_tot_gpa_uts_attempted,
      x_recalc_inst_gpa                   => x_recalc_inst_gpa,
      x_recalc_grading_scale_id           => x_recalc_grading_scale_id,
      x_selfrep_total_cp_attempted        => x_selfrep_total_cp_attempted,
      x_selfrep_total_cp_earned           => x_selfrep_total_cp_earned,
      x_selfrep_total_unit_gp             => x_selfrep_total_unit_gp,
      x_selfrep_tot_gpa_uts_attemp        => x_selfrep_tot_gpa_uts_attemp,
      x_selfrep_inst_gpa                  => x_selfrep_inst_gpa,
      x_selfrep_grading_scale_id          => x_selfrep_grading_scale_id,
      x_selfrep_weighted_gpa              => x_selfrep_weighted_gpa,
      x_selfrep_rank_in_class             => x_selfrep_rank_in_class,
      x_selfrep_weighed_rank              => x_selfrep_weighed_rank,
      x_selfrep_class_size                => x_selfrep_class_size,
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
      x_hz_acad_hist_id                   => x_hz_acad_hist_id,
      x_education_id                      => x_education_id,
      x_current_inst                      => x_current_inst,
      x_degree_attempted            => x_degree_attempted,
      x_comments                          => x_comments,
      x_planned_completion_date           => x_planned_completion_date,
      x_transcript_required               => x_transcript_required,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );


     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_ad_hz_acad_hist (
      recalc_total_cp_attempted,
      recalc_total_cp_earned,
      recalc_total_unit_gp,
      recalc_tot_gpa_uts_attempted,
      recalc_inst_gpa,
      recalc_grading_scale_id,
      selfrep_total_cp_attempted,
      selfrep_total_cp_earned,
      selfrep_total_unit_gp,
      selfrep_tot_gpa_uts_attemp,
      selfrep_inst_gpa,
      selfrep_grading_scale_id,
      selfrep_weighted_gpa,
      selfrep_rank_in_class,
      selfrep_weighed_rank,
      selfrep_class_size,
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
      hz_acad_hist_id,
      education_id,
      current_inst,
      degree_attempted,
      comments,
      planned_completion_date,
      transcript_required,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_application_id,
      program_update_date,
      program_id
    ) VALUES (
      new_references.recalc_total_cp_attempted,
      new_references.recalc_total_cp_earned,
      new_references.recalc_total_unit_gp,
      new_references.recalc_tot_gpa_uts_attempted,
      new_references.recalc_inst_gpa,
      new_references.recalc_grading_scale_id,
      new_references.selfrep_total_cp_attempted,
      new_references.selfrep_total_cp_earned,
      new_references.selfrep_total_unit_gp,
      new_references.selfrep_tot_gpa_uts_attemp,
      new_references.selfrep_inst_gpa,
      new_references.selfrep_grading_scale_id,
      new_references.selfrep_weighted_gpa,
      new_references.selfrep_rank_in_class,
      new_references.selfrep_weighed_rank,
      new_references.selfrep_class_size,
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
      IGS_AD_HZ_ACAD_HIST_S.NEXTVAL,
      new_references.education_id,
      new_references.current_inst,
      new_references.degree_attempted,
      new_references.comments,
      new_references.planned_completion_date,
      new_references.transcript_required,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_request_id,
      x_program_application_id,
      x_program_update_date,
      x_program_id
    )RETURNING HZ_ACAD_HIST_ID INTO X_HZ_ACAD_HIST_ID;
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
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_recalc_total_cp_attempted         IN     NUMBER,
    x_recalc_total_cp_earned            IN     NUMBER,
    x_recalc_total_unit_gp              IN     NUMBER,
    x_recalc_tot_gpa_uts_attempted      IN     NUMBER,
    x_recalc_inst_gpa                   IN     VARCHAR2,
    x_recalc_grading_scale_id           IN     NUMBER,
    x_selfrep_total_cp_attempted        IN     NUMBER,
    x_selfrep_total_cp_earned           IN     NUMBER,
    x_selfrep_total_unit_gp             IN     NUMBER,
    x_selfrep_tot_gpa_uts_attemp        IN     NUMBER,
    x_selfrep_inst_gpa                  IN     VARCHAR2,
    x_selfrep_grading_scale_id          IN     NUMBER,
    x_selfrep_weighted_gpa              IN     VARCHAR2,
    x_selfrep_rank_in_class             IN     NUMBER,
    x_selfrep_weighed_rank              IN     VARCHAR2,
    x_selfrep_class_size                IN     NUMBER DEFAULT NULL,
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
    x_hz_acad_hist_id                   IN     NUMBER,
    x_education_id                      IN     NUMBER,
    x_current_inst                      IN     VARCHAR2,
    x_degree_attempted                  IN     VARCHAR2 ,
    x_program_type_attempted            IN     VARCHAR2 ,
    x_comments                          IN     VARCHAR2,
    x_planned_completion_date           IN     DATE,
    x_transcript_required               IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vdixit.in	      23-JULY-2001      Added new column transcript_required
  ||					to the tbh calls
  */
    CURSOR c1 IS
      SELECT
        recalc_total_cp_attempted,
        recalc_total_cp_earned,
        recalc_total_unit_gp,
        recalc_tot_gpa_uts_attempted,
        recalc_inst_gpa,
        recalc_grading_scale_id,
        selfrep_total_cp_attempted,
        selfrep_total_cp_earned,
        selfrep_total_unit_gp,
        selfrep_tot_gpa_uts_attemp,
        selfrep_inst_gpa,
        selfrep_grading_scale_id,
        selfrep_weighted_gpa,
        selfrep_rank_in_class,
        selfrep_weighed_rank,
        selfrep_class_size,
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
        hz_acad_hist_id,
        education_id,
        current_inst,
        degree_attempted,
        comments,
        planned_completion_date,
        transcript_required
      FROM  igs_ad_hz_acad_hist
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
        ((tlinfo.recalc_total_cp_attempted = x_recalc_total_cp_attempted) OR ((tlinfo.recalc_total_cp_attempted IS NULL) AND (X_recalc_total_cp_attempted IS NULL)))
        AND ((tlinfo.recalc_total_cp_earned = x_recalc_total_cp_earned) OR ((tlinfo.recalc_total_cp_earned IS NULL) AND (X_recalc_total_cp_earned IS NULL)))
        AND ((tlinfo.recalc_total_unit_gp = x_recalc_total_unit_gp) OR ((tlinfo.recalc_total_unit_gp IS NULL) AND (X_recalc_total_unit_gp IS NULL)))
        AND ((tlinfo.recalc_tot_gpa_uts_attempted = x_recalc_tot_gpa_uts_attempted) OR ((tlinfo.recalc_tot_gpa_uts_attempted IS NULL) AND (X_recalc_tot_gpa_uts_attempted IS NULL)))
        AND ((tlinfo.recalc_inst_gpa = x_recalc_inst_gpa) OR ((tlinfo.recalc_inst_gpa IS NULL) AND (X_recalc_inst_gpa IS NULL)))
        AND ((tlinfo.recalc_grading_scale_id = x_recalc_grading_scale_id) OR ((tlinfo.recalc_grading_scale_id IS NULL) AND (X_recalc_grading_scale_id IS NULL)))
        AND ((tlinfo.selfrep_total_cp_attempted = x_selfrep_total_cp_attempted) OR ((tlinfo.selfrep_total_cp_attempted IS NULL) AND (X_selfrep_total_cp_attempted IS NULL)))
        AND ((tlinfo.selfrep_total_cp_earned = x_selfrep_total_cp_earned) OR ((tlinfo.selfrep_total_cp_earned IS NULL) AND (X_selfrep_total_cp_earned IS NULL)))
        AND ((tlinfo.selfrep_total_unit_gp = x_selfrep_total_unit_gp) OR ((tlinfo.selfrep_total_unit_gp IS NULL) AND (X_selfrep_total_unit_gp IS NULL)))
        AND ((tlinfo.selfrep_tot_gpa_uts_attemp  =  x_selfrep_tot_gpa_uts_attemp ) OR ((tlinfo.selfrep_tot_gpa_uts_attemp IS NULL) AND ( x_selfrep_tot_gpa_uts_attemp  IS NULL)))
        AND ((tlinfo.selfrep_inst_gpa = x_selfrep_inst_gpa) OR ((tlinfo.selfrep_inst_gpa IS NULL) AND (X_selfrep_inst_gpa IS NULL)))
        AND ((tlinfo.selfrep_grading_scale_id = x_selfrep_grading_scale_id) OR ((tlinfo.selfrep_grading_scale_id IS NULL) AND (X_selfrep_grading_scale_id IS NULL)))
        AND ((tlinfo.selfrep_weighted_gpa = x_selfrep_weighted_gpa) OR ((tlinfo.selfrep_weighted_gpa IS NULL) AND (X_selfrep_weighted_gpa IS NULL)))
        AND ((tlinfo.selfrep_rank_in_class = x_selfrep_rank_in_class) OR ((tlinfo.selfrep_rank_in_class IS NULL) AND (X_selfrep_rank_in_class IS NULL)))
        AND ((tlinfo.selfrep_weighed_rank = x_selfrep_weighed_rank) OR ((tlinfo.selfrep_weighed_rank IS NULL) AND (X_selfrep_weighed_rank IS NULL)))
        AND ((tlinfo.selfrep_class_size = x_selfrep_class_size) OR ((tlinfo.selfrep_class_size IS NULL) AND (X_selfrep_class_size IS NULL)))
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
        AND (tlinfo.hz_acad_hist_id = x_hz_acad_hist_id)
        AND (tlinfo.education_id = x_education_id)
        AND (tlinfo.current_inst = x_current_inst)
        AND ((tlinfo.degree_attempted = x_degree_attempted) OR ((tlinfo.degree_attempted IS NULL) AND (X_degree_attempted IS NULL)))
        AND ((tlinfo.comments = x_comments) OR ((tlinfo.comments IS NULL) AND (X_comments IS NULL)))
        AND ((TRUNC(tlinfo.planned_completion_date) = TRUNC(x_planned_completion_date)) OR ((tlinfo.planned_completion_date IS NULL) AND (X_planned_completion_date IS NULL)))
        AND ((tlinfo.transcript_required = x_transcript_required) OR ((tlinfo.transcript_required IS NULL) AND (X_transcript_required IS NULL)))
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
    x_recalc_total_cp_attempted         IN     NUMBER,
    x_recalc_total_cp_earned            IN     NUMBER,
    x_recalc_total_unit_gp              IN     NUMBER,
    x_recalc_tot_gpa_uts_attempted      IN     NUMBER,
    x_recalc_inst_gpa                   IN     VARCHAR2,
    x_recalc_grading_scale_id           IN     NUMBER,
    x_selfrep_total_cp_attempted        IN     NUMBER,
    x_selfrep_total_cp_earned           IN     NUMBER,
    x_selfrep_total_unit_gp             IN     NUMBER,
    x_selfrep_tot_gpa_uts_attemp        IN     NUMBER,
    x_selfrep_inst_gpa                  IN     VARCHAR2,
    x_selfrep_grading_scale_id          IN     NUMBER,
    x_selfrep_weighted_gpa              IN     VARCHAR2,
    x_selfrep_rank_in_class             IN     NUMBER,
    x_selfrep_weighed_rank              IN     VARCHAR2,
    x_selfrep_class_size                IN     NUMBER DEFAULT NULL,
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
    x_hz_acad_hist_id                   IN     NUMBER,
    x_education_id                      IN     NUMBER,
    x_current_inst                      IN     VARCHAR2,
    x_degree_attempted            IN     VARCHAR2,
    x_program_type_attempted            IN     VARCHAR2 ,
    x_comments                          IN     VARCHAR2,
    x_planned_completion_date           IN     DATE,
    x_transcript_required               IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN  VARCHAR2
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vdixit.in	      23-JULY-2001      Added new column transcript_required
  ||					to the tbh calls
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_mode VARCHAR2(1);
  BEGIN

    l_mode := NVL(x_mode,'R');

    x_last_update_date := SYSDATE;
    IF (l_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (l_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
      x_request_id:=FND_GLOBAL.CONC_REQUEST_ID;
      x_program_id:=FND_GLOBAL.CONC_PROGRAM_ID;
      x_program_application_id:=FND_GLOBAL.PROG_APPL_ID;
      IF (x_request_id = -1 ) THEN
        x_request_id:=NULL;
        x_program_id:=NULL;
        x_program_application_id:=NULL;
        x_program_update_date:=NULL;
      ELSE
        x_program_update_date:=SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_recalc_total_cp_attempted         => x_recalc_total_cp_attempted,
      x_recalc_total_cp_earned            => x_recalc_total_cp_earned,
      x_recalc_total_unit_gp              => x_recalc_total_unit_gp,
      x_recalc_tot_gpa_uts_attempted      => x_recalc_tot_gpa_uts_attempted,
      x_recalc_inst_gpa                   => x_recalc_inst_gpa,
      x_recalc_grading_scale_id           => x_recalc_grading_scale_id,
      x_selfrep_total_cp_attempted        => x_selfrep_total_cp_attempted,
      x_selfrep_total_cp_earned           => x_selfrep_total_cp_earned,
      x_selfrep_total_unit_gp             => x_selfrep_total_unit_gp,
      x_selfrep_tot_gpa_uts_attemp        => x_selfrep_tot_gpa_uts_attemp,
      x_selfrep_inst_gpa                  => x_selfrep_inst_gpa,
      x_selfrep_grading_scale_id          => x_selfrep_grading_scale_id,
      x_selfrep_weighted_gpa              => x_selfrep_weighted_gpa,
      x_selfrep_rank_in_class             => x_selfrep_rank_in_class,
      x_selfrep_weighed_rank              => x_selfrep_weighed_rank,
      x_selfrep_class_size                => x_selfrep_class_size,
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
      x_hz_acad_hist_id                   => x_hz_acad_hist_id,
      x_education_id                      => x_education_id,
      x_current_inst                      => x_current_inst,
      x_degree_attempted            => x_degree_attempted,
      x_comments                          => x_comments,
      x_planned_completion_date           => x_planned_completion_date,
      x_transcript_required               => x_transcript_required,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_ad_hz_acad_hist
      SET
        recalc_total_cp_attempted         = new_references.recalc_total_cp_attempted,
        recalc_total_cp_earned            = new_references.recalc_total_cp_earned,
        recalc_total_unit_gp              = new_references.recalc_total_unit_gp,
        recalc_tot_gpa_uts_attempted      = new_references.recalc_tot_gpa_uts_attempted,
        recalc_inst_gpa                   = new_references.recalc_inst_gpa,
        recalc_grading_scale_id           = new_references.recalc_grading_scale_id,
        selfrep_total_cp_attempted        = new_references.selfrep_total_cp_attempted,
        selfrep_total_cp_earned           = new_references.selfrep_total_cp_earned,
        selfrep_total_unit_gp             = new_references.selfrep_total_unit_gp,
        selfrep_tot_gpa_uts_attemp        = new_references.selfrep_tot_gpa_uts_attemp,
        selfrep_inst_gpa                  = new_references.selfrep_inst_gpa,
        selfrep_grading_scale_id          = new_references.selfrep_grading_scale_id,
        selfrep_weighted_gpa              = new_references.selfrep_weighted_gpa,
        selfrep_rank_in_class             = new_references.selfrep_rank_in_class,
        selfrep_weighed_rank              = new_references.selfrep_weighed_rank,
        selfrep_class_size                = new_references.selfrep_class_size,
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
        hz_acad_hist_id                   = new_references.hz_acad_hist_id,
        education_id                      = new_references.education_id,
        current_inst                      = new_references.current_inst,
        degree_attempted            = new_references.degree_attempted,
        comments                          = new_references.comments,
        planned_completion_date           = new_references.planned_completion_date,
        transcript_required               = new_references.transcript_required,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        request_id                        = x_request_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        program_id                        = x_program_id
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;



EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_recalc_total_cp_attempted         IN     NUMBER,
    x_recalc_total_cp_earned            IN     NUMBER,
    x_recalc_total_unit_gp              IN     NUMBER,
    x_recalc_tot_gpa_uts_attempted      IN     NUMBER,
    x_recalc_inst_gpa                   IN     VARCHAR2,
    x_recalc_grading_scale_id           IN     NUMBER,
    x_selfrep_total_cp_attempted        IN     NUMBER,
    x_selfrep_total_cp_earned           IN     NUMBER,
    x_selfrep_total_unit_gp             IN     NUMBER,
    x_selfrep_tot_gpa_uts_attemp        IN     NUMBER,
    x_selfrep_inst_gpa                  IN     VARCHAR2,
    x_selfrep_grading_scale_id          IN     NUMBER,
    x_selfrep_weighted_gpa              IN     VARCHAR2,
    x_selfrep_rank_in_class             IN     NUMBER,
    x_selfrep_weighed_rank              IN     VARCHAR2,
    x_selfrep_class_size                IN     NUMBER DEFAULT NULL,
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
    x_hz_acad_hist_id                   IN OUT NOCOPY NUMBER,
    x_education_id                      IN     NUMBER,
    x_current_inst                      IN     VARCHAR2,
    x_degree_attempted            IN     VARCHAR2,
    x_program_type_attempted            IN     VARCHAR2 ,
    x_comments                          IN     VARCHAR2,
    x_planned_completion_date           IN     DATE,
    x_transcript_required               IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN  VARCHAR2
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vdixit.in	      23-JULY-2001      Added new column transcript_required
  ||					to the tbh calls
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_hz_acad_hist
      WHERE    hz_acad_hist_id	= x_hz_acad_hist_id;
    l_mode VARCHAR2(1);
  BEGIN

    l_mode := NVL(x_mode,'R');

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid =>                           x_rowid,
        x_recalc_total_cp_attempted =>       x_recalc_total_cp_attempted,
        x_recalc_total_cp_earned =>          x_recalc_total_cp_earned,
        x_recalc_total_unit_gp =>            x_recalc_total_unit_gp,
        x_recalc_tot_gpa_uts_attempted =>    x_recalc_tot_gpa_uts_attempted,
        x_recalc_inst_gpa =>                 x_recalc_inst_gpa,
        x_recalc_grading_scale_id =>         x_recalc_grading_scale_id,
        x_selfrep_total_cp_attempted =>      x_selfrep_total_cp_attempted,
        x_selfrep_total_cp_earned =>         x_selfrep_total_cp_earned,
        x_selfrep_total_unit_gp =>           x_selfrep_total_unit_gp,
        x_selfrep_tot_gpa_uts_attemp =>      x_selfrep_tot_gpa_uts_attemp,
        x_selfrep_inst_gpa =>                x_selfrep_inst_gpa,
        x_selfrep_grading_scale_id =>        x_selfrep_grading_scale_id,
        x_selfrep_weighted_gpa =>            x_selfrep_weighted_gpa,
        x_selfrep_rank_in_class =>           x_selfrep_rank_in_class,
        x_selfrep_weighed_rank =>            x_selfrep_weighed_rank,
        x_selfrep_class_size =>              x_selfrep_class_size,
        x_attribute_category =>              x_attribute_category,
        x_attribute1 =>                      x_attribute1,
        x_attribute2 =>                      x_attribute2,
        x_attribute3 =>                      x_attribute3,
        x_attribute4 =>                      x_attribute4,
        x_attribute5 =>                      x_attribute5,
        x_attribute6 =>                      x_attribute6,
        x_attribute7 =>                      x_attribute7,
        x_attribute8 =>                      x_attribute8,
        x_attribute9 =>                      x_attribute9,
        x_attribute10 =>                     x_attribute10,
        x_attribute11 =>                     x_attribute11,
        x_attribute12 =>                     x_attribute12,
        x_attribute13 =>                     x_attribute13,
        x_attribute14 =>                     x_attribute14,
        x_attribute15 =>                     x_attribute15,
        x_attribute16 =>                     x_attribute16,
        x_attribute17 =>                     x_attribute17,
        x_attribute18 =>                     x_attribute18,
        x_attribute19 =>                     x_attribute19,
        x_attribute20 =>                     x_attribute20,
        x_hz_acad_hist_id =>                 x_hz_acad_hist_id,
        x_education_id =>                    x_education_id,
        x_current_inst =>                    x_current_inst,
        x_degree_attempted =>                x_degree_attempted,
        x_comments =>                        x_comments,
        x_planned_completion_date =>         x_planned_completion_date,
        x_transcript_required =>             x_transcript_required,
        x_mode              =>               l_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
        x_rowid =>                           x_rowid,
        x_recalc_total_cp_attempted =>       x_recalc_total_cp_attempted,
        x_recalc_total_cp_earned =>          x_recalc_total_cp_earned,
        x_recalc_total_unit_gp =>            x_recalc_total_unit_gp,
        x_recalc_tot_gpa_uts_attempted =>    x_recalc_tot_gpa_uts_attempted,
        x_recalc_inst_gpa =>                 x_recalc_inst_gpa,
        x_recalc_grading_scale_id =>         x_recalc_grading_scale_id,
        x_selfrep_total_cp_attempted =>      x_selfrep_total_cp_attempted,
        x_selfrep_total_cp_earned =>         x_selfrep_total_cp_earned,
        x_selfrep_total_unit_gp =>           x_selfrep_total_unit_gp,
        x_selfrep_tot_gpa_uts_attemp =>      x_selfrep_tot_gpa_uts_attemp,
        x_selfrep_inst_gpa =>                x_selfrep_inst_gpa,
        x_selfrep_grading_scale_id =>        x_selfrep_grading_scale_id,
        x_selfrep_weighted_gpa =>            x_selfrep_weighted_gpa,
        x_selfrep_rank_in_class =>           x_selfrep_rank_in_class,
        x_selfrep_weighed_rank =>            x_selfrep_weighed_rank,
        x_selfrep_class_size =>              x_selfrep_class_size,
        x_attribute_category =>              x_attribute_category,
        x_attribute1 =>                      x_attribute1,
        x_attribute2 =>                      x_attribute2,
        x_attribute3 =>                      x_attribute3,
        x_attribute4 =>                      x_attribute4,
        x_attribute5 =>                      x_attribute5,
        x_attribute6 =>                      x_attribute6,
        x_attribute7 =>                      x_attribute7,
        x_attribute8 =>                      x_attribute8,
        x_attribute9 =>                      x_attribute9,
        x_attribute10 =>                     x_attribute10,
        x_attribute11 =>                     x_attribute11,
        x_attribute12 =>                     x_attribute12,
        x_attribute13 =>                     x_attribute13,
        x_attribute14 =>                     x_attribute14,
        x_attribute15 =>                     x_attribute15,
        x_attribute16 =>                     x_attribute16,
        x_attribute17 =>                     x_attribute17,
        x_attribute18 =>                     x_attribute18,
        x_attribute19 =>                     x_attribute19,
        x_attribute20 =>                     x_attribute20,
        x_hz_acad_hist_id =>                 x_hz_acad_hist_id,
        x_education_id =>                    x_education_id,
        x_current_inst =>                    x_current_inst,
        x_degree_attempted =>                x_degree_attempted,
        x_comments =>                        x_comments,
        x_planned_completion_date =>         x_planned_completion_date,
        x_transcript_required =>             x_transcript_required,
        x_mode              =>               l_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
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

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_ad_hz_acad_hist
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


  END delete_row;


END igs_ad_hz_acad_hist_pkg;

/
