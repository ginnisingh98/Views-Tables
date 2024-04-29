--------------------------------------------------------
--  DDL for Package Body IGS_PS_SCH_OCR_CFIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_SCH_OCR_CFIG_PKG" AS
/* $Header: IGSPI3QB.pls 120.1 2005/09/08 14:46:34 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ps_sch_ocr_cfig%ROWTYPE;
  new_references igs_ps_sch_ocr_cfig%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ocr_cfig_id                       IN     NUMBER,
    x_to_be_announced_roll_flag               IN     VARCHAR2,
    x_day_roll_flag                          IN     VARCHAR2,
    x_time_roll_flag                         IN     VARCHAR2,
    x_instructor_roll_flag                   IN     VARCHAR2,
    x_facility_roll_flag                     IN     VARCHAR2,
    x_schd_not_rqd_roll_flag                 IN     VARCHAR2,
    x_ref_cd_roll_flag                       IN     VARCHAR2,
    x_preferred_bld_roll_flag                IN     VARCHAR2,
    x_preferred_room_roll_flag               IN     VARCHAR2,
    x_dedicated_bld_roll_flag                IN     VARCHAR2,
    x_dedicated_room_roll_flag               IN     VARCHAR2,
    x_scheduled_bld_roll_flag                IN     VARCHAR2,
    x_scheduled_room_roll_flag               IN     VARCHAR2,
    x_preferred_region_roll_flag             IN     VARCHAR2,
    x_occur_flexfield_roll_flag              IN     VARCHAR2,
    x_inc_ins_cng_notfy_roll_flag            IN     VARCHAR2,
    x_date_ovrd_flag                         IN     VARCHAR2,
    x_day_ovrd_flag                          IN     VARCHAR2,
    x_time_ovrd_flag                         IN     VARCHAR2,
    x_instructor_ovrd_flag                   IN     VARCHAR2,
    x_scheduled_bld_ovrd_flag                IN     VARCHAR2,
    x_scheduled_room_ovrd_flag               IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : somnath.mukherjee@oracle.com
  ||  Created On : 10-MAY-2005
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ps_sch_ocr_cfig
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
    new_references.ocr_cfig_id                       := x_ocr_cfig_id;
    new_references.to_be_announced_roll_flag               := x_to_be_announced_roll_flag;
    new_references.day_roll_flag                          := x_day_roll_flag;
    new_references.time_roll_flag                         := x_time_roll_flag;
    new_references.instructor_roll_flag                   := x_instructor_roll_flag;
    new_references.facility_roll_flag                     := x_facility_roll_flag;
    new_references.schd_not_rqd_roll_flag                 := x_schd_not_rqd_roll_flag;
    new_references.ref_cd_roll_flag                       := x_ref_cd_roll_flag;
    new_references.preferred_bld_roll_flag                := x_preferred_bld_roll_flag;
    new_references.preferred_room_roll_flag               := x_preferred_room_roll_flag;
    new_references.dedicated_bld_roll_flag                := x_dedicated_bld_roll_flag;
    new_references.dedicated_room_roll_flag               := x_dedicated_room_roll_flag;
    new_references.scheduled_bld_roll_flag                := x_scheduled_bld_roll_flag;
    new_references.scheduled_room_roll_flag               := x_scheduled_room_roll_flag;
    new_references.preferred_region_roll_flag             := x_preferred_region_roll_flag;
    new_references.occur_flexfield_roll_flag              := x_occur_flexfield_roll_flag;
    new_references.inc_ins_change_notfy_roll_flag         := x_inc_ins_cng_notfy_roll_flag;
    new_references.date_ovrd_flag                         := x_date_ovrd_flag;
    new_references.day_ovrd_flag                          := x_day_ovrd_flag;
    new_references.time_ovrd_flag                         := x_time_ovrd_flag;
    new_references.instructor_ovrd_flag                   := x_instructor_ovrd_flag;
    new_references.scheduled_bld_ovrd_flag                := x_scheduled_bld_ovrd_flag;
    new_references.scheduled_room_ovrd_flag               := x_scheduled_room_ovrd_flag;

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


  FUNCTION get_pk_for_validation (
    x_ocr_cfig_id                       IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : somnath.mukherjee@oracle.com
  ||  Created On : 10-MAY-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_sch_ocr_cfig
      WHERE    ocr_cfig_id = x_ocr_cfig_id
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
    x_rowid                             IN     VARCHAR2,
    x_ocr_cfig_id                       IN     NUMBER,
    x_to_be_announced_roll_flag               IN     VARCHAR2,
    x_day_roll_flag                          IN     VARCHAR2,
    x_time_roll_flag                         IN     VARCHAR2,
    x_instructor_roll_flag                   IN     VARCHAR2,
    x_facility_roll_flag                     IN     VARCHAR2,
    x_schd_not_rqd_roll_flag                 IN     VARCHAR2,
    x_ref_cd_roll_flag                       IN     VARCHAR2,
    x_preferred_bld_roll_flag                IN     VARCHAR2,
    x_preferred_room_roll_flag               IN     VARCHAR2,
    x_dedicated_bld_roll_flag                IN     VARCHAR2,
    x_dedicated_room_roll_flag               IN     VARCHAR2,
    x_scheduled_bld_roll_flag                IN     VARCHAR2,
    x_scheduled_room_roll_flag               IN     VARCHAR2,
    x_preferred_region_roll_flag             IN     VARCHAR2,
    x_occur_flexfield_roll_flag              IN     VARCHAR2,
    x_inc_ins_cng_notfy_roll_flag         IN     VARCHAR2,
    x_date_ovrd_flag                         IN     VARCHAR2,
    x_day_ovrd_flag                          IN     VARCHAR2,
    x_time_ovrd_flag                         IN     VARCHAR2,
    x_instructor_ovrd_flag                   IN     VARCHAR2,
    x_scheduled_bld_ovrd_flag                IN     VARCHAR2,
    x_scheduled_room_ovrd_flag               IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : somnath.mukherjee@oracle.com
  ||  Created On : 10-MAY-2005
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
      x_ocr_cfig_id,
      x_to_be_announced_roll_flag,
      x_day_roll_flag,
      x_time_roll_flag,
      x_instructor_roll_flag,
      x_facility_roll_flag,
      x_schd_not_rqd_roll_flag,
      x_ref_cd_roll_flag,
      x_preferred_bld_roll_flag,
      x_preferred_room_roll_flag,
      x_dedicated_bld_roll_flag,
      x_dedicated_room_roll_flag,
      x_scheduled_bld_roll_flag,
      x_scheduled_room_roll_flag,
      x_preferred_region_roll_flag,
      x_occur_flexfield_roll_flag,
      x_inc_ins_cng_notfy_roll_flag,
      x_date_ovrd_flag,
      x_day_ovrd_flag,
      x_time_ovrd_flag,
      x_instructor_ovrd_flag,
      x_scheduled_bld_ovrd_flag,
      x_scheduled_room_ovrd_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ocr_cfig_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.ocr_cfig_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ocr_cfig_id                       IN OUT NOCOPY NUMBER,
    x_to_be_announced_roll_flag               IN     VARCHAR2,
    x_day_roll_flag                          IN     VARCHAR2,
    x_time_roll_flag                         IN     VARCHAR2,
    x_instructor_roll_flag                   IN     VARCHAR2,
    x_facility_roll_flag                     IN     VARCHAR2,
    x_schd_not_rqd_roll_flag                 IN     VARCHAR2,
    x_ref_cd_roll_flag                       IN     VARCHAR2,
    x_preferred_bld_roll_flag                IN     VARCHAR2,
    x_preferred_room_roll_flag               IN     VARCHAR2,
    x_dedicated_bld_roll_flag                IN     VARCHAR2,
    x_dedicated_room_roll_flag               IN     VARCHAR2,
    x_scheduled_bld_roll_flag                IN     VARCHAR2,
    x_scheduled_room_roll_flag               IN     VARCHAR2,
    x_preferred_region_roll_flag             IN     VARCHAR2,
    x_occur_flexfield_roll_flag              IN     VARCHAR2,
    x_inc_ins_cng_notfy_roll_flag         IN     VARCHAR2,
    x_date_ovrd_flag                         IN     VARCHAR2,
    x_day_ovrd_flag                          IN     VARCHAR2,
    x_time_ovrd_flag                         IN     VARCHAR2,
    x_instructor_ovrd_flag                   IN     VARCHAR2,
    x_scheduled_bld_ovrd_flag                IN     VARCHAR2,
    x_scheduled_room_ovrd_flag               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : somnath.mukherjee@oracle.com
  ||  Created On : 10-MAY-2005
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
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
      fnd_message.set_token ('ROUTINE', 'IGS_PS_SCH_OCR_CFIG_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_ocr_cfig_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_ocr_cfig_id                       => x_ocr_cfig_id,
      x_to_be_announced_roll_flag               => x_to_be_announced_roll_flag,
      x_day_roll_flag                          => x_day_roll_flag,
      x_time_roll_flag                         => x_time_roll_flag,
      x_instructor_roll_flag                   => x_instructor_roll_flag,
      x_facility_roll_flag                     => x_facility_roll_flag,
      x_schd_not_rqd_roll_flag                 => x_schd_not_rqd_roll_flag,
      x_ref_cd_roll_flag                       => x_ref_cd_roll_flag,
      x_preferred_bld_roll_flag                => x_preferred_bld_roll_flag,
      x_preferred_room_roll_flag               => x_preferred_room_roll_flag,
      x_dedicated_bld_roll_flag                => x_dedicated_bld_roll_flag,
      x_dedicated_room_roll_flag               => x_dedicated_room_roll_flag,
      x_scheduled_bld_roll_flag                => x_scheduled_bld_roll_flag,
      x_scheduled_room_roll_flag               => x_scheduled_room_roll_flag,
      x_preferred_region_roll_flag             => x_preferred_region_roll_flag,
      x_occur_flexfield_roll_flag              => x_occur_flexfield_roll_flag,
      x_inc_ins_cng_notfy_roll_flag         => x_inc_ins_cng_notfy_roll_flag,
      x_date_ovrd_flag                         => x_date_ovrd_flag,
      x_day_ovrd_flag                          => x_day_ovrd_flag,
      x_time_ovrd_flag                         => x_time_ovrd_flag,
      x_instructor_ovrd_flag                   => x_instructor_ovrd_flag,
      x_scheduled_bld_ovrd_flag                => x_scheduled_bld_ovrd_flag,
      x_scheduled_room_ovrd_flag               => x_scheduled_room_ovrd_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ps_sch_ocr_cfig (
      ocr_cfig_id,
      to_be_announced_roll_flag,
      day_roll_flag,
      time_roll_flag,
      instructor_roll_flag,
      facility_roll_flag,
      schd_not_rqd_roll_flag,
      ref_cd_roll_flag,
      preferred_bld_roll_flag,
      preferred_room_roll_flag,
      dedicated_bld_roll_flag,
      dedicated_room_roll_flag,
      scheduled_bld_roll_flag,
      scheduled_room_roll_flag,
      preferred_region_roll_flag,
      occur_flexfield_roll_flag,
      inc_ins_change_notfy_roll_flag,
      date_ovrd_flag,
      day_ovrd_flag,
      time_ovrd_flag,
      instructor_ovrd_flag,
      scheduled_bld_ovrd_flag,
      scheduled_room_ovrd_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_ps_sch_ocr_cfig_s.NEXTVAL,
      new_references.to_be_announced_roll_flag,
      new_references.day_roll_flag,
      new_references.time_roll_flag,
      new_references.instructor_roll_flag,
      new_references.facility_roll_flag,
      new_references.schd_not_rqd_roll_flag,
      new_references.ref_cd_roll_flag,
      new_references.preferred_bld_roll_flag,
      new_references.preferred_room_roll_flag,
      new_references.dedicated_bld_roll_flag,
      new_references.dedicated_room_roll_flag,
      new_references.scheduled_bld_roll_flag,
      new_references.scheduled_room_roll_flag,
      new_references.preferred_region_roll_flag,
      new_references.occur_flexfield_roll_flag,
      new_references.inc_ins_change_notfy_roll_flag,
      new_references.date_ovrd_flag,
      new_references.day_ovrd_flag,
      new_references.time_ovrd_flag,
      new_references.instructor_ovrd_flag,
      new_references.scheduled_bld_ovrd_flag,
      new_references.scheduled_room_ovrd_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, ocr_cfig_id INTO x_rowid, x_ocr_cfig_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ocr_cfig_id                       IN     NUMBER,
    x_to_be_announced_roll_flag               IN     VARCHAR2,
    x_day_roll_flag                          IN     VARCHAR2,
    x_time_roll_flag                         IN     VARCHAR2,
    x_instructor_roll_flag                   IN     VARCHAR2,
    x_facility_roll_flag                     IN     VARCHAR2,
    x_schd_not_rqd_roll_flag                 IN     VARCHAR2,
    x_ref_cd_roll_flag                       IN     VARCHAR2,
    x_preferred_bld_roll_flag                IN     VARCHAR2,
    x_preferred_room_roll_flag               IN     VARCHAR2,
    x_dedicated_bld_roll_flag                IN     VARCHAR2,
    x_dedicated_room_roll_flag               IN     VARCHAR2,
    x_scheduled_bld_roll_flag                IN     VARCHAR2,
    x_scheduled_room_roll_flag               IN     VARCHAR2,
    x_preferred_region_roll_flag             IN     VARCHAR2,
    x_occur_flexfield_roll_flag              IN     VARCHAR2,
    x_inc_ins_cng_notfy_roll_flag         IN     VARCHAR2,
    x_date_ovrd_flag                         IN     VARCHAR2,
    x_day_ovrd_flag                          IN     VARCHAR2,
    x_time_ovrd_flag                         IN     VARCHAR2,
    x_instructor_ovrd_flag                   IN     VARCHAR2,
    x_scheduled_bld_ovrd_flag                IN     VARCHAR2,
    x_scheduled_room_ovrd_flag               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : somnath.mukherjee@oracle.com
  ||  Created On : 10-MAY-2005
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        to_be_announced_roll_flag,
        day_roll_flag,
        time_roll_flag,
        instructor_roll_flag,
        facility_roll_flag,
        schd_not_rqd_roll_flag,
        ref_cd_roll_flag,
        preferred_bld_roll_flag,
        preferred_room_roll_flag,
        dedicated_bld_roll_flag,
        dedicated_room_roll_flag,
        scheduled_bld_roll_flag,
        scheduled_room_roll_flag,
        preferred_region_roll_flag,
        occur_flexfield_roll_flag,
        inc_ins_change_notfy_roll_flag,
        date_ovrd_flag,
        day_ovrd_flag,
        time_ovrd_flag,
        instructor_ovrd_flag,
        scheduled_bld_ovrd_flag,
        scheduled_room_ovrd_flag
      FROM  igs_ps_sch_ocr_cfig
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
        (tlinfo.to_be_announced_roll_flag = x_to_be_announced_roll_flag)
        AND (tlinfo.day_roll_flag = x_day_roll_flag)
        AND (tlinfo.time_roll_flag = x_time_roll_flag)
        AND (tlinfo.instructor_roll_flag = x_instructor_roll_flag)
        AND (tlinfo.facility_roll_flag = x_facility_roll_flag)
        AND (tlinfo.schd_not_rqd_roll_flag = x_schd_not_rqd_roll_flag)
        AND (tlinfo.ref_cd_roll_flag = x_ref_cd_roll_flag)
        AND (tlinfo.preferred_bld_roll_flag = x_preferred_bld_roll_flag)
        AND (tlinfo.preferred_room_roll_flag = x_preferred_room_roll_flag)
        AND (tlinfo.dedicated_bld_roll_flag = x_dedicated_bld_roll_flag)
        AND (tlinfo.dedicated_room_roll_flag = x_dedicated_room_roll_flag)
        AND (tlinfo.scheduled_bld_roll_flag = x_scheduled_bld_roll_flag)
        AND (tlinfo.scheduled_room_roll_flag = x_scheduled_room_roll_flag)
        AND (tlinfo.preferred_region_roll_flag = x_preferred_region_roll_flag)
        AND (tlinfo.occur_flexfield_roll_flag = x_occur_flexfield_roll_flag)
        AND (tlinfo.inc_ins_change_notfy_roll_flag = x_inc_ins_cng_notfy_roll_flag)
        AND (tlinfo.date_ovrd_flag = x_date_ovrd_flag)
        AND (tlinfo.day_ovrd_flag = x_day_ovrd_flag)
        AND (tlinfo.time_ovrd_flag = x_time_ovrd_flag)
        AND (tlinfo.instructor_ovrd_flag = x_instructor_ovrd_flag)
        AND (tlinfo.scheduled_bld_ovrd_flag = x_scheduled_bld_ovrd_flag)
        AND (tlinfo.scheduled_room_ovrd_flag = x_scheduled_room_ovrd_flag)
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
    x_ocr_cfig_id                       IN     NUMBER,
    x_to_be_announced_roll_flag               IN     VARCHAR2,
    x_day_roll_flag                          IN     VARCHAR2,
    x_time_roll_flag                         IN     VARCHAR2,
    x_instructor_roll_flag                   IN     VARCHAR2,
    x_facility_roll_flag                     IN     VARCHAR2,
    x_schd_not_rqd_roll_flag                 IN     VARCHAR2,
    x_ref_cd_roll_flag                       IN     VARCHAR2,
    x_preferred_bld_roll_flag                IN     VARCHAR2,
    x_preferred_room_roll_flag               IN     VARCHAR2,
    x_dedicated_bld_roll_flag                IN     VARCHAR2,
    x_dedicated_room_roll_flag               IN     VARCHAR2,
    x_scheduled_bld_roll_flag                IN     VARCHAR2,
    x_scheduled_room_roll_flag               IN     VARCHAR2,
    x_preferred_region_roll_flag             IN     VARCHAR2,
    x_occur_flexfield_roll_flag              IN     VARCHAR2,
    x_inc_ins_cng_notfy_roll_flag         IN     VARCHAR2,
    x_date_ovrd_flag                         IN     VARCHAR2,
    x_day_ovrd_flag                          IN     VARCHAR2,
    x_time_ovrd_flag                         IN     VARCHAR2,
    x_instructor_ovrd_flag                   IN     VARCHAR2,
    x_scheduled_bld_ovrd_flag                IN     VARCHAR2,
    x_scheduled_room_ovrd_flag               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : somnath.mukherjee@oracle.com
  ||  Created On : 10-MAY-2005
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
      fnd_message.set_token ('ROUTINE', 'IGS_PS_SCH_OCR_CFIG_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_ocr_cfig_id                       => x_ocr_cfig_id,
      x_to_be_announced_roll_flag               => x_to_be_announced_roll_flag,
      x_day_roll_flag                          => x_day_roll_flag,
      x_time_roll_flag                         => x_time_roll_flag,
      x_instructor_roll_flag                   => x_instructor_roll_flag,
      x_facility_roll_flag                     => x_facility_roll_flag,
      x_schd_not_rqd_roll_flag                 => x_schd_not_rqd_roll_flag,
      x_ref_cd_roll_flag                       => x_ref_cd_roll_flag,
      x_preferred_bld_roll_flag                => x_preferred_bld_roll_flag,
      x_preferred_room_roll_flag               => x_preferred_room_roll_flag,
      x_dedicated_bld_roll_flag                => x_dedicated_bld_roll_flag,
      x_dedicated_room_roll_flag               => x_dedicated_room_roll_flag,
      x_scheduled_bld_roll_flag                => x_scheduled_bld_roll_flag,
      x_scheduled_room_roll_flag               => x_scheduled_room_roll_flag,
      x_preferred_region_roll_flag             => x_preferred_region_roll_flag,
      x_occur_flexfield_roll_flag              => x_occur_flexfield_roll_flag,
      x_inc_ins_cng_notfy_roll_flag         => x_inc_ins_cng_notfy_roll_flag,
      x_date_ovrd_flag                         => x_date_ovrd_flag,
      x_day_ovrd_flag                          => x_day_ovrd_flag,
      x_time_ovrd_flag                         => x_time_ovrd_flag,
      x_instructor_ovrd_flag                   => x_instructor_ovrd_flag,
      x_scheduled_bld_ovrd_flag                => x_scheduled_bld_ovrd_flag,
      x_scheduled_room_ovrd_flag               => x_scheduled_room_ovrd_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ps_sch_ocr_cfig
      SET
        to_be_announced_roll_flag               = new_references.to_be_announced_roll_flag,
        day_roll_flag                          = new_references.day_roll_flag,
        time_roll_flag                         = new_references.time_roll_flag,
        instructor_roll_flag                   = new_references.instructor_roll_flag,
        facility_roll_flag                     = new_references.facility_roll_flag,
        schd_not_rqd_roll_flag                 = new_references.schd_not_rqd_roll_flag,
        ref_cd_roll_flag                       = new_references.ref_cd_roll_flag,
        preferred_bld_roll_flag                = new_references.preferred_bld_roll_flag,
        preferred_room_roll_flag               = new_references.preferred_room_roll_flag,
        dedicated_bld_roll_flag                = new_references.dedicated_bld_roll_flag,
        dedicated_room_roll_flag               = new_references.dedicated_room_roll_flag,
        scheduled_bld_roll_flag                = new_references.scheduled_bld_roll_flag,
        scheduled_room_roll_flag               = new_references.scheduled_room_roll_flag,
        preferred_region_roll_flag             = new_references.preferred_region_roll_flag,
        occur_flexfield_roll_flag              = new_references.occur_flexfield_roll_flag,
        inc_ins_change_notfy_roll_flag         = new_references.inc_ins_change_notfy_roll_flag,
        date_ovrd_flag                         = new_references.date_ovrd_flag,
        day_ovrd_flag                          = new_references.day_ovrd_flag,
        time_ovrd_flag                         = new_references.time_ovrd_flag,
        instructor_ovrd_flag                   = new_references.instructor_ovrd_flag,
        scheduled_bld_ovrd_flag                = new_references.scheduled_bld_ovrd_flag,
        scheduled_room_ovrd_flag               = new_references.scheduled_room_ovrd_flag,
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
    x_ocr_cfig_id                       IN OUT NOCOPY NUMBER,
    x_to_be_announced_roll_flag               IN     VARCHAR2,
    x_day_roll_flag                          IN     VARCHAR2,
    x_time_roll_flag                         IN     VARCHAR2,
    x_instructor_roll_flag                   IN     VARCHAR2,
    x_facility_roll_flag                     IN     VARCHAR2,
    x_schd_not_rqd_roll_flag                 IN     VARCHAR2,
    x_ref_cd_roll_flag                       IN     VARCHAR2,
    x_preferred_bld_roll_flag                IN     VARCHAR2,
    x_preferred_room_roll_flag               IN     VARCHAR2,
    x_dedicated_bld_roll_flag                IN     VARCHAR2,
    x_dedicated_room_roll_flag               IN     VARCHAR2,
    x_scheduled_bld_roll_flag                IN     VARCHAR2,
    x_scheduled_room_roll_flag               IN     VARCHAR2,
    x_preferred_region_roll_flag             IN     VARCHAR2,
    x_occur_flexfield_roll_flag              IN     VARCHAR2,
    x_inc_ins_cng_notfy_roll_flag         IN     VARCHAR2,
    x_date_ovrd_flag                         IN     VARCHAR2,
    x_day_ovrd_flag                          IN     VARCHAR2,
    x_time_ovrd_flag                         IN     VARCHAR2,
    x_instructor_ovrd_flag                   IN     VARCHAR2,
    x_scheduled_bld_ovrd_flag                IN     VARCHAR2,
    x_scheduled_room_ovrd_flag               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : somnath.mukherjee@oracle.com
  ||  Created On : 10-MAY-2005
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ps_sch_ocr_cfig
      WHERE    ocr_cfig_id                       = x_ocr_cfig_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ocr_cfig_id,
        x_to_be_announced_roll_flag,
        x_day_roll_flag,
        x_time_roll_flag,
        x_instructor_roll_flag,
        x_facility_roll_flag,
        x_schd_not_rqd_roll_flag,
        x_ref_cd_roll_flag,
        x_preferred_bld_roll_flag,
        x_preferred_room_roll_flag,
        x_dedicated_bld_roll_flag,
        x_dedicated_room_roll_flag,
        x_scheduled_bld_roll_flag,
        x_scheduled_room_roll_flag,
        x_preferred_region_roll_flag,
        x_occur_flexfield_roll_flag,
        x_inc_ins_cng_notfy_roll_flag,
        x_date_ovrd_flag,
        x_day_ovrd_flag,
        x_time_ovrd_flag,
        x_instructor_ovrd_flag,
        x_scheduled_bld_ovrd_flag,
        x_scheduled_room_ovrd_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ocr_cfig_id,
      x_to_be_announced_roll_flag,
      x_day_roll_flag,
      x_time_roll_flag,
      x_instructor_roll_flag,
      x_facility_roll_flag,
      x_schd_not_rqd_roll_flag,
      x_ref_cd_roll_flag,
      x_preferred_bld_roll_flag,
      x_preferred_room_roll_flag,
      x_dedicated_bld_roll_flag,
      x_dedicated_room_roll_flag,
      x_scheduled_bld_roll_flag,
      x_scheduled_room_roll_flag,
      x_preferred_region_roll_flag,
      x_occur_flexfield_roll_flag,
      x_inc_ins_cng_notfy_roll_flag,
      x_date_ovrd_flag,
      x_day_ovrd_flag,
      x_time_ovrd_flag,
      x_instructor_ovrd_flag,
      x_scheduled_bld_ovrd_flag,
      x_scheduled_room_ovrd_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : somnath.mukherjee@oracle.com
  ||  Created On : 10-MAY-2005
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

    DELETE FROM igs_ps_sch_ocr_cfig
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ps_sch_ocr_cfig_pkg;

/
