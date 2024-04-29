--------------------------------------------------------
--  DDL for Package Body IGS_LOOKUPS_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_LOOKUPS_VAL_PKG" AS
/* $Header: IGSMI17B.pls 120.0 2005/06/01 20:41:23 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_lookups_val%ROWTYPE;
  new_references igs_lookups_val%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_lookup_type                       IN     VARCHAR2    DEFAULT NULL,
    x_lookup_code                       IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_security_allowed_ind              IN     VARCHAR2    DEFAULT NULL,
    x_step_type_restriction_num_in     IN     VARCHAR2    DEFAULT NULL,
    x_unit_outcome_ind                  IN     VARCHAR2    DEFAULT NULL,
    x_display_name                      IN     VARCHAR2    DEFAULT NULL,
    x_display_order                     IN     NUMBER      DEFAULT NULL,
    x_step_order_applicable_ind         IN     VARCHAR2    DEFAULT NULL,
    x_academic_transcript_ind           IN     VARCHAR2    DEFAULT NULL,
    x_cmpltn_requirements_ind           IN     VARCHAR2    DEFAULT NULL,
    x_fee_ass_ind                       IN     VARCHAR2    DEFAULT NULL,
    x_step_group_type                   IN     VARCHAR2    DEFAULT NULL,
    x_final_result_ind                  IN     VARCHAR2    DEFAULT NULL,
    x_system_generated_ind              IN     VARCHAR2    DEFAULT NULL,
    x_transaction_cat                   IN     VARCHAR2    DEFAULT NULL,
    x_encumbrance_level                 IN     NUMBER      DEFAULT NULL,
    x_open_for_enrollments              IN     VARCHAR2    DEFAULT NULL,
    x_system_calculated                 IN     VARCHAR2    DEFAULT NULL,
    x_system_mandatory_ind              IN     VARCHAR2    DEFAULT NULL,
    x_default_display_seq               IN     NUMBER      DEFAULT NULL,
    x_av_transcript_disp_options        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Amitlinfo.Gairola@oracle.com
  ||  Created On : 27-SEP-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_LOOKUPS_VAL
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
    new_references.lookup_type                       := x_lookup_type;
    new_references.lookup_code                       := x_lookup_code;
    new_references.closed_ind                        := x_closed_ind;
    new_references.security_allowed_ind              := x_security_allowed_ind;
    new_references.step_type_restriction_num_ind     := x_step_type_restriction_num_in;
    new_references.unit_outcome_ind                  := x_unit_outcome_ind;
    new_references.display_name                      := x_display_name;
    new_references.display_order                     := x_display_order;
    new_references.step_order_applicable_ind         := x_step_order_applicable_ind;
    new_references.academic_transcript_ind           := x_academic_transcript_ind;
    new_references.cmpltn_requirements_ind           := x_cmpltn_requirements_ind;
    new_references.fee_ass_ind                       := x_fee_ass_ind;
    new_references.step_group_type                   := x_step_group_type;
    new_references.final_result_ind                  := x_final_result_ind;
    new_references.system_generated_ind              := x_system_generated_ind;
    new_references.transaction_cat                   := x_transaction_cat;
    new_references.encumbrance_level                 := x_encumbrance_level;
    new_references.open_for_enrollments              := x_open_for_enrollments;
    new_references.system_calculated                 := x_system_calculated;
    new_references.system_mandatory_ind              := x_system_mandatory_ind;
    new_references.default_display_seq               := x_default_display_seq;
    new_references.av_transcript_disp_options        := x_av_transcript_disp_options;

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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_lookup_type                       IN     VARCHAR2    DEFAULT NULL,
    x_lookup_code                       IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_security_allowed_ind              IN     VARCHAR2    DEFAULT NULL,
    x_step_type_restriction_num_in     IN     VARCHAR2    DEFAULT NULL,
    x_unit_outcome_ind                  IN     VARCHAR2    DEFAULT NULL,
    x_display_name                      IN     VARCHAR2    DEFAULT NULL,
    x_display_order                     IN     NUMBER      DEFAULT NULL,
    x_step_order_applicable_ind         IN     VARCHAR2    DEFAULT NULL,
    x_academic_transcript_ind           IN     VARCHAR2    DEFAULT NULL,
    x_cmpltn_requirements_ind           IN     VARCHAR2    DEFAULT NULL,
    x_fee_ass_ind                       IN     VARCHAR2    DEFAULT NULL,
    x_step_group_type                   IN     VARCHAR2    DEFAULT NULL,
    x_final_result_ind                  IN     VARCHAR2    DEFAULT NULL,
    x_system_generated_ind              IN     VARCHAR2    DEFAULT NULL,
    x_transaction_cat                   IN     VARCHAR2    DEFAULT NULL,
    x_encumbrance_level                 IN     NUMBER      DEFAULT NULL,
    x_open_for_enrollments              IN     VARCHAR2    DEFAULT NULL,
    x_system_calculated                 IN     VARCHAR2    DEFAULT NULL,
    x_system_mandatory_ind              IN     VARCHAR2    DEFAULT NULL,
    x_default_display_seq               IN     NUMBER      DEFAULT NULL,
    x_av_transcript_disp_options        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Amitlinfo.Gairola@oracle.com
  ||  Created On : 27-SEP-2001
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
      x_lookup_type,
      x_lookup_code,
      x_closed_ind,
      x_security_allowed_ind,
      x_step_type_restriction_num_in,
      x_unit_outcome_ind,
      x_display_name,
      x_display_order,
      x_step_order_applicable_ind,
      x_academic_transcript_ind,
      x_cmpltn_requirements_ind,
      x_fee_ass_ind,
      x_step_group_type,
      x_final_result_ind,
      x_system_generated_ind,
      x_transaction_cat,
      x_encumbrance_level,
      x_open_for_enrollments,
      x_system_calculated,
      x_system_mandatory_ind,
      x_default_display_seq,
      x_av_transcript_disp_options,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insertlinfo.
      /*IF ( get_pk_for_validation(x_lookup_type,x_lookup_code

           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insertlinfo.
      IF ( get_pk_for_validation (x_lookup_type,x_lookup_code

           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

      END IF;
      */
      NULL;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lookup_type                       IN OUT NOCOPY VARCHAR2,
    x_lookup_code                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_security_allowed_ind              IN     VARCHAR2,
    x_step_type_restriction_num_in     IN     VARCHAR2,
    x_unit_outcome_ind                  IN     VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_step_order_applicable_ind         IN     VARCHAR2,
    x_academic_transcript_ind           IN     VARCHAR2,
    x_cmpltn_requirements_ind           IN     VARCHAR2,
    x_fee_ass_ind                       IN     VARCHAR2,
    x_step_group_type                   IN     VARCHAR2,
    x_final_result_ind                  IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_transaction_cat                   IN     VARCHAR2,
    x_encumbrance_level                 IN     NUMBER,
    x_open_for_enrollments              IN     VARCHAR2,
    x_system_calculated                 IN     VARCHAR2,
    x_system_mandatory_ind              IN     VARCHAR2,
    x_default_display_seq               IN     NUMBER,
    x_av_transcript_disp_options        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Amitlinfo.Gairola@oracle.com
  ||  Created On : 27-SEP-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  ssawhney                        For perf reasons, used DML returning to return the ROWID
  */



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
      x_lookup_type                       => x_lookup_type,
      x_lookup_code                       => x_lookup_code,
      x_closed_ind                        => x_closed_ind,
      x_security_allowed_ind              => x_security_allowed_ind,
      x_step_type_restriction_num_in     => x_step_type_restriction_num_in,
      x_unit_outcome_ind                  => x_unit_outcome_ind,
      x_display_name                      => x_display_name,
      x_display_order                     => x_display_order,
      x_step_order_applicable_ind         => x_step_order_applicable_ind,
      x_academic_transcript_ind           => x_academic_transcript_ind,
      x_cmpltn_requirements_ind           => x_cmpltn_requirements_ind,
      x_fee_ass_ind                       => x_fee_ass_ind,
      x_step_group_type                   => x_step_group_type,
      x_final_result_ind                  => x_final_result_ind,
      x_system_generated_ind              => x_system_generated_ind,
      x_transaction_cat                   => x_transaction_cat,
      x_encumbrance_level                 => x_encumbrance_level,
      x_open_for_enrollments              => x_open_for_enrollments,
      x_system_calculated                 => x_system_calculated,
      x_system_mandatory_ind              => x_system_mandatory_ind,
      x_default_display_seq               => x_default_display_seq,
      x_av_transcript_disp_options        => x_av_transcript_disp_options,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_lookups_val (
      lookup_type,
      lookup_code,
      closed_ind,
      security_allowed_ind,
      step_type_restriction_num_ind,
      unit_outcome_ind,
      display_name,
      display_order,
      step_order_applicable_ind,
      academic_transcript_ind,
      cmpltn_requirements_ind,
      fee_ass_ind,
      step_group_type,
      final_result_ind,
      system_generated_ind,
      transaction_cat,
      encumbrance_level,
      open_for_enrollments,
      system_calculated,
      system_mandatory_ind,
      default_display_seq,
      av_transcript_disp_options,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.lookup_type,
      new_references.lookup_code,
      new_references.closed_ind,
      new_references.security_allowed_ind,
      new_references.step_type_restriction_num_ind,
      new_references.unit_outcome_ind,
      new_references.display_name,
      new_references.display_order,
      new_references.step_order_applicable_ind,
      new_references.academic_transcript_ind,
      new_references.cmpltn_requirements_ind,
      new_references.fee_ass_ind,
      new_references.step_group_type,
      new_references.final_result_ind,
      new_references.system_generated_ind,
      new_references.transaction_cat,
      new_references.encumbrance_level,
      new_references.open_for_enrollments,
      new_references.system_calculated,
      new_references.system_mandatory_ind,
      new_references.default_display_seq,
      new_references.av_transcript_disp_options,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;


  END insert_row;

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_lookup_type                       IN     VARCHAR2,
    x_lookup_code                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_security_allowed_ind              IN     VARCHAR2,
    x_step_type_restriction_num_in     IN     VARCHAR2,
    x_unit_outcome_ind                  IN     VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_step_order_applicable_ind         IN     VARCHAR2,
    x_academic_transcript_ind           IN     VARCHAR2,
    x_cmpltn_requirements_ind           IN     VARCHAR2,
    x_fee_ass_ind                       IN     VARCHAR2,
    x_step_group_type                   IN     VARCHAR2,
    x_final_result_ind                  IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_transaction_cat                   IN     VARCHAR2,
    x_encumbrance_level                 IN     NUMBER,
    x_open_for_enrollments              IN     VARCHAR2,
    x_system_calculated                 IN     VARCHAR2,
    x_system_mandatory_ind              IN     VARCHAR2,
    x_default_display_seq               IN     NUMBER,
    x_av_transcript_disp_options        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Amitlinfo.Gairola@oracle.com
  ||  Created On : 27-SEP-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        lookup_type,
        lookup_code,
        closed_ind,
        security_allowed_ind,
        step_type_restriction_num_ind,
        unit_outcome_ind,
        display_name,
        display_order,
        step_order_applicable_ind,
        academic_transcript_ind,
        cmpltn_requirements_ind,
        fee_ass_ind,
        step_group_type,
        final_result_ind,
        system_generated_ind,
        transaction_cat,
        encumbrance_level,
        open_for_enrollments,
        system_calculated,
        system_mandatory_ind,
        default_display_seq,
        av_transcript_disp_options
      FROM  igs_lookups_val
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
        (tlinfo.lookup_type = x_lookup_type)
        AND (tlinfo.lookup_code = x_lookup_code)
        AND ((tlinfo.closed_ind = x_closed_ind) OR ((tlinfo.closed_ind IS NULL) AND (X_closed_ind IS NULL)))
        AND ((tlinfo.security_allowed_ind = x_security_allowed_ind) OR ((tlinfo.security_allowed_ind IS NULL) AND (X_security_allowed_ind IS NULL)))
        AND ((tlinfo.step_type_restriction_num_ind = x_step_type_restriction_num_in) OR ((tlinfo.step_type_restriction_num_ind IS NULL) AND (X_step_type_restriction_num_in IS NULL)))
        AND ((tlinfo.unit_outcome_ind = x_unit_outcome_ind) OR ((tlinfo.unit_outcome_ind IS NULL) AND (X_unit_outcome_ind IS NULL)))
        AND ((tlinfo.display_name = x_display_name) OR ((tlinfo.display_name IS NULL) AND (X_display_name IS NULL)))
        AND ((tlinfo.display_order = x_display_order) OR ((tlinfo.display_order IS NULL) AND (X_display_order IS NULL)))
        AND ((tlinfo.step_order_applicable_ind = x_step_order_applicable_ind) OR ((tlinfo.step_order_applicable_ind IS NULL) AND (X_step_order_applicable_ind IS NULL)))
        AND ((tlinfo.academic_transcript_ind = x_academic_transcript_ind) OR ((tlinfo.academic_transcript_ind IS NULL) AND (X_academic_transcript_ind IS NULL)))
        AND ((tlinfo.cmpltn_requirements_ind = x_cmpltn_requirements_ind) OR ((tlinfo.cmpltn_requirements_ind IS NULL) AND (X_cmpltn_requirements_ind IS NULL)))
        AND ((tlinfo.fee_ass_ind = x_fee_ass_ind) OR ((tlinfo.fee_ass_ind IS NULL) AND (X_fee_ass_ind IS NULL)))
        AND ((tlinfo.step_group_type = x_step_group_type) OR ((tlinfo.step_group_type IS NULL) AND (X_step_group_type IS NULL)))
        AND ((tlinfo.final_result_ind = x_final_result_ind) OR ((tlinfo.final_result_ind IS NULL) AND (X_final_result_ind IS NULL)))
        AND ((tlinfo.system_generated_ind = x_system_generated_ind) OR ((tlinfo.system_generated_ind IS NULL) AND (X_system_generated_ind IS NULL)))
        AND ((tlinfo.transaction_cat = x_transaction_cat) OR ((tlinfo.transaction_cat IS NULL) AND (X_transaction_cat IS NULL)))
        AND ((tlinfo.encumbrance_level = x_encumbrance_level) OR ((tlinfo.encumbrance_level IS NULL) AND (X_encumbrance_level IS NULL)))
        AND ((tlinfo.open_for_enrollments = x_open_for_enrollments) OR ((tlinfo.open_for_enrollments IS NULL) AND (X_open_for_enrollments IS NULL)))
        AND ((tlinfo.system_calculated = x_system_calculated) OR ((tlinfo.system_calculated IS NULL) AND (X_system_calculated IS NULL)))
        AND ((tlinfo.system_mandatory_ind = x_system_mandatory_ind) OR ((tlinfo.system_mandatory_ind IS NULL) AND (X_system_mandatory_ind IS NULL)))
        AND ((tlinfo.default_display_seq = x_default_display_seq) OR ((tlinfo.default_display_seq IS NULL) AND (X_default_display_seq IS NULL)))
        AND ((tlinfo.av_transcript_disp_options = x_av_transcript_disp_options) OR ((tlinfo.av_transcript_disp_options IS NULL) AND (X_av_transcript_disp_options IS NULL)))
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
    x_lookup_type                       IN     VARCHAR2,
    x_lookup_code                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_security_allowed_ind              IN     VARCHAR2,
    x_step_type_restriction_num_in     IN     VARCHAR2,
    x_unit_outcome_ind                  IN     VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_step_order_applicable_ind         IN     VARCHAR2,
    x_academic_transcript_ind           IN     VARCHAR2,
    x_cmpltn_requirements_ind           IN     VARCHAR2,
    x_fee_ass_ind                       IN     VARCHAR2,
    x_step_group_type                   IN     VARCHAR2,
    x_final_result_ind                  IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_transaction_cat                   IN     VARCHAR2,
    x_encumbrance_level                 IN     NUMBER,
    x_open_for_enrollments              IN     VARCHAR2,
    x_system_calculated                 IN     VARCHAR2,
    x_system_mandatory_ind              IN     VARCHAR2,
    x_default_display_seq               IN     NUMBER,
    x_av_transcript_disp_options        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Amitlinfo.Gairola@oracle.com
  ||  Created On : 27-SEP-2001
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
      x_lookup_type                       => x_lookup_type,
      x_lookup_code                       => x_lookup_code,
      x_closed_ind                        => x_closed_ind,
      x_security_allowed_ind              => x_security_allowed_ind,
      x_step_type_restriction_num_in     => x_step_type_restriction_num_in,
      x_unit_outcome_ind                  => x_unit_outcome_ind,
      x_display_name                      => x_display_name,
      x_display_order                     => x_display_order,
      x_step_order_applicable_ind         => x_step_order_applicable_ind,
      x_academic_transcript_ind           => x_academic_transcript_ind,
      x_cmpltn_requirements_ind           => x_cmpltn_requirements_ind,
      x_fee_ass_ind                       => x_fee_ass_ind,
      x_step_group_type                   => x_step_group_type,
      x_final_result_ind                  => x_final_result_ind,
      x_system_generated_ind              => x_system_generated_ind,
      x_transaction_cat                   => x_transaction_cat,
      x_encumbrance_level                 => x_encumbrance_level,
      x_open_for_enrollments              => x_open_for_enrollments,
      x_system_calculated                 => x_system_calculated,
      x_system_mandatory_ind              => x_system_mandatory_ind,
      x_default_display_seq               => x_default_display_seq,
      x_av_transcript_disp_options        => x_av_transcript_disp_options,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_lookups_val
      SET
        av_transcript_disp_options        = new_references.av_transcript_disp_options,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lookup_type                       IN OUT NOCOPY VARCHAR2,
    x_lookup_code                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_security_allowed_ind              IN     VARCHAR2,
    x_step_type_restriction_num_in     IN     VARCHAR2,
    x_unit_outcome_ind                  IN     VARCHAR2,
    x_display_name                      IN     VARCHAR2,
    x_display_order                     IN     NUMBER,
    x_step_order_applicable_ind         IN     VARCHAR2,
    x_academic_transcript_ind           IN     VARCHAR2,
    x_cmpltn_requirements_ind           IN     VARCHAR2,
    x_fee_ass_ind                       IN     VARCHAR2,
    x_step_group_type                   IN     VARCHAR2,
    x_final_result_ind                  IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_transaction_cat                   IN     VARCHAR2,
    x_encumbrance_level                 IN     NUMBER,
    x_open_for_enrollments              IN     VARCHAR2,
    x_system_calculated                 IN     VARCHAR2,
    x_system_mandatory_ind              IN     VARCHAR2,
    x_default_display_seq               IN     NUMBER,
    x_av_transcript_disp_options        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Amitlinfo.Gairola@oracle.com
  ||  Created On : 27-SEP-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_lookups_val
      WHERE    lookup_type =  x_lookup_type AND
               lookup_code = x_lookup_code ;



  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_lookup_type,
        x_lookup_code,
        x_closed_ind,
        x_security_allowed_ind,
        x_step_type_restriction_num_in,
        x_unit_outcome_ind,
        x_display_name,
        x_display_order,
        x_step_order_applicable_ind,
        x_academic_transcript_ind,
        x_cmpltn_requirements_ind,
        x_fee_ass_ind,
        x_step_group_type,
        x_final_result_ind,
        x_system_generated_ind,
        x_transaction_cat,
        x_encumbrance_level,
        x_open_for_enrollments,
        x_system_calculated,
        x_system_mandatory_ind,
        x_default_display_seq,
        x_av_transcript_disp_options,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_lookup_type,
      x_lookup_code,
      x_closed_ind,
      x_security_allowed_ind,
      x_step_type_restriction_num_in,
      x_unit_outcome_ind,
      x_display_name,
      x_display_order,
      x_step_order_applicable_ind,
      x_academic_transcript_ind,
      x_cmpltn_requirements_ind,
      x_fee_ass_ind,
      x_step_group_type,
      x_final_result_ind,
      x_system_generated_ind,
      x_transaction_cat,
      x_encumbrance_level,
      x_open_for_enrollments,
      x_system_calculated,
      x_system_mandatory_ind,
      x_default_display_seq,
      x_av_transcript_disp_options,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Amitlinfo.Gairola@oracle.com
  ||  Created On : 27-SEP-2001
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

    DELETE FROM igs_lookups_val
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_lookups_val_pkg;

/
