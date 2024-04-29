--------------------------------------------------------
--  DDL for Package Body IGF_AP_BATCH_AW_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_BATCH_AW_MAP_PKG" AS
/* $Header: IGFAI22B.pls 120.1 2005/07/12 08:23:37 appldev ship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_AP_BATCH_AW_MAP_PKG
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | This package has a flag on the end of some of the procedures called   |
 | X_MODE. Pass either 'R' for runtime, or 'I' for Install-time.         |
 | This will control how the who columns are filled in; If you are       |
 | running in runtime mode, they are taken from the profiles, whereas in |
 | install-time mode they get defaulted with special values to indicate  |
 | that they were inserted by datamerge.                                 |
 |                                                                       |
 | The ADD_ROW routine will see whether a row exists by selecting        |
 | based on the primary key, and updates the row if it exists,           |
 | or inserts the row if it doesn't already exist.                       |
 |                                                                       |
 | This module is called by AutoInstall (afplss.drv) on install and      |
 | upgrade.  The WHENEVER SQLERROR and EXIT (at bottom) are required.    |
 |                                                                       |
 | HISTORY                                                               |
 | Who           When         What                                       |
 | bannamal      29-Sep-2004  3416863 cod xml changes for pell and       |
 |                            direct loan. added two new columns         |
 | cdcruz        06-Jun-2003  # 2858504  FA 118.1 Legacy Import          |
 |                            Added  new column : award_year_status_code |
 | masehgal      17-Oct-2002  # 2613546  FA 105_108 Multiple Award Years |
 |                            Added unique check on system award year    |
 |                            Added  new column :                        |
 |                            sys_award_year                             |
 | masehgal      14-Jun-2002  # 2413695   Changed message to             |
 |                             'IGF','IGF_AP_BAM_CI_FK'                  |
 |                                                                       |
 | brajendr      04-Jul-2002  Bug # 2436484 - FACR009 Calendar Relations |
 |                            Following columns are obsoleted. Signature |
 |                            of PKG is retained and all the references  |
 |                            are removed                                |
 |                              ci_sequence_number_acad                  |
 |                              ci_cal_type_acad                         |
 |                              ci_cal_type_adm                          |
 |                              ci_sequence_number_adm                   |
 |                                                                       |
 *=======================================================================*/

  l_rowid VARCHAR2(25);
  old_references igf_ap_batch_aw_map_all%ROWTYPE;
  new_references igf_ap_batch_aw_map_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2 ,
    x_rowid                             IN     VARCHAR2 ,
    x_batch_year                        IN     NUMBER   ,
    x_ci_sequence_number                IN     NUMBER   ,
    x_ci_cal_type                       IN     VARCHAR2 ,
    x_ci_sequence_number_acad           IN     NUMBER   ,
    x_ci_cal_type_acad                  IN     VARCHAR2 ,
    x_ci_cal_type_adm                   IN     VARCHAR2 ,
    x_ci_sequence_number_adm            IN     NUMBER   ,
    x_bam_id                            IN     NUMBER   ,
    x_css_academic_year                 IN     NUMBER   ,
    x_efc_frml                          IN     VARCHAR2 ,
    x_num_days_divisor                  IN     NUMBER   ,
    x_roundoff_fact                     IN     VARCHAR2 ,
    x_efc_dob                           IN     DATE     ,
    x_dl_code                           IN     VARCHAR2 ,
    x_ffel_code                         IN     VARCHAR2 ,
    x_pell_code                         IN     VARCHAR2 ,
    x_isir_code                         IN     VARCHAR2 ,
    x_profile_code                      IN     VARCHAR2 ,
    x_tolerance_limit                   IN     NUMBER   ,
    x_sys_award_year                    IN     VARCHAR2 ,
    x_award_year_status_code            IN     VARCHAR2   DEFAULT NULL,
    x_pell_participant_code             IN     VARCHAR2 ,
    x_dl_participant_code               IN     VARCHAR2 ,
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER,
    x_publish_in_ss_flag                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 28-MAR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
       SELECT   *
       FROM     igf_ap_batch_aw_map_all
       WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
       CLOSE cur_old_ref_values;
       FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
       RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.batch_year                        := x_batch_year;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number_acad           := NULL;
    new_references.ci_cal_type_acad                  := NULL;
    new_references.ci_cal_type_adm                   := NULL;
    new_references.ci_sequence_number_adm            := NULL;
    new_references.bam_id                            := x_bam_id;
    new_references.css_academic_year                 := x_css_academic_year;
    new_references.efc_frml                          := x_efc_frml ;
    new_references.num_days_divisor                  := x_num_days_divisor ;
    new_references.roundoff_fact                     := x_roundoff_fact ;
    new_references.efc_dob                           := x_efc_dob ;
    new_references.dl_code                           := x_dl_code;
    new_references.ffel_code                         := x_ffel_code;
    new_references.pell_code                         := x_pell_code;
    new_references.isir_code                         := x_isir_code;
    new_references.profile_code                      := x_profile_code;
    new_references.tolerance_limit                   := x_tolerance_limit ;
    new_references.sys_award_year                    := x_sys_award_year ;
    new_references.award_year_status_code            := x_award_year_status_code ;
    new_references.pell_participant_code             := x_pell_participant_code;
    new_references.dl_participant_code               := x_dl_participant_code;
    new_references.publish_in_ss_flag                := x_publish_in_ss_flag;

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
  ||  Created By : prchandr
  ||  Created On : 28-MAR-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  masehgal        18-oct-2002     # 2613546  Multiple Award Years Enhancements
  ||                                  Added uniqueness check for system award year
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk2_for_validation ( new_references.ci_cal_type,
                                  new_references.ci_sequence_number )) THEN
       FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF ( get_uk6_for_validation ( new_references.sys_award_year )) THEN
       FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : prchandr
  ||  Created On : 28-MAR-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (   (     (old_references.ci_cal_type = new_references.ci_cal_type)
             AND (old_references.ci_sequence_number = new_references.ci_sequence_number))
        OR (     (new_references.ci_cal_type IS NULL)
             OR  (new_references.ci_sequence_number IS NULL))) THEN
        NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation ( new_references.ci_cal_type,
                                                      new_references.ci_sequence_number ) THEN
       FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation ( x_bam_id            IN     NUMBER  )
           RETURN BOOLEAN AS
  /*
  ||  Created By : prchandr
  ||  Created On : 28-MAR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
       SELECT   rowid
       FROM     igf_ap_batch_aw_map_all
       WHERE    bam_id = x_bam_id
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


  FUNCTION get_uk2_for_validation ( x_ci_cal_type                       IN     VARCHAR2,
                                    x_ci_sequence_number                IN     NUMBER  )
           RETURN BOOLEAN AS
  /*
  ||  Created By : prchandr
  ||  Created On : 28-MAR-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
       SELECT   rowid
       FROM     igf_ap_batch_aw_map_all
       WHERE    ci_cal_type = x_ci_cal_type
       AND      ci_sequence_number = x_ci_sequence_number
       AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

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

  END get_uk2_for_validation ;


 FUNCTION get_uk6_for_validation ( x_sys_award_year      IN    VARCHAR2 )
          RETURN BOOLEAN AS
  /*
  ||  Created By : masehgal
  ||  Created On : 18-Oct-2002
  ||  Purpose : Validates the Unique Key ( System Award Year ) of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
       SELECT   rowid
       FROM     igf_ap_batch_aw_map_all
       WHERE    sys_award_year = x_sys_award_year
       AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

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

  END get_uk6_for_validation ;


  PROCEDURE get_fk_igs_ca_inst ( x_cal_type                          IN     VARCHAR2,
                                 x_sequence_number                   IN     NUMBER  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 28-MAR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  masehgal        14-Jun-2002     # 2413695   Changed message to
  ||                                  'IGF','IGF_AP_BAM_CI_FK'
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
       SELECT   rowid
       FROM     igf_ap_batch_aw_map_all
       WHERE   ((ci_cal_type = x_cal_type) AND
                (ci_sequence_number = x_sequence_number))
       OR      ((ci_cal_type_acad = x_cal_type) AND
                (ci_sequence_number_acad = x_sequence_number)) ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
       CLOSE cur_rowid;
       FND_MESSAGE.SET_NAME ('IGF','IGF_AP_BAM_CI_FK');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
       RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2 ,
    x_rowid                             IN     VARCHAR2 ,
    x_batch_year                        IN     NUMBER   ,
    x_ci_sequence_number                IN     NUMBER   ,
    x_ci_cal_type                       IN     VARCHAR2 ,
    x_ci_sequence_number_acad           IN     NUMBER   ,
    x_ci_cal_type_acad                  IN     VARCHAR2 ,
    x_ci_cal_type_adm                   IN     VARCHAR2 ,
    x_ci_sequence_number_adm            IN     NUMBER   ,
    x_bam_id                            IN     NUMBER   ,
    x_css_academic_year                 IN     NUMBER   ,
    x_efc_frml                          IN     VARCHAR2 ,
    x_num_days_divisor                  IN     NUMBER   ,
    x_roundoff_fact                     IN     VARCHAR2 ,
    x_efc_dob                           IN     DATE     ,
    x_dl_code                           IN     VARCHAR2 ,
    x_ffel_code                         IN     VARCHAR2 ,
    x_pell_code                         IN     VARCHAR2 ,
    x_isir_code                         IN     VARCHAR2 ,
    x_profile_code                      IN     VARCHAR2 ,
    x_tolerance_limit                   IN     NUMBER   ,
    x_sys_award_year                    IN     VARCHAR2 ,
    x_award_year_status_code            IN     VARCHAR2 ,
    x_pell_participant_code             IN     VARCHAR2 ,
    x_dl_participant_code               IN     VARCHAR2 ,
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER,
    x_publish_in_ss_flag                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 28-MAR-2001
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
      x_batch_year,
      x_ci_sequence_number,
      x_ci_cal_type,
      x_ci_sequence_number_acad,
      x_ci_cal_type_acad,
      x_ci_cal_type_adm,
      x_ci_sequence_number_adm,
      x_bam_id,
      x_css_academic_year,
      x_efc_frml ,
      x_num_days_divisor ,
      x_roundoff_fact ,
      x_efc_dob,
      x_dl_code,
      x_ffel_code,
      x_pell_code,
      x_isir_code,
      x_profile_code,
      x_tolerance_limit,
      x_sys_award_year,
      x_award_year_status_code,
      x_pell_participant_code,
      x_dl_participant_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_publish_in_ss_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation( new_references.bam_id )) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       check_uniqueness;
       check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
       -- Call all the procedures related to Before Insert.
       IF ( get_pk_for_validation ( new_references.bam_id ) ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;
       check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       check_uniqueness;

    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2 ,
    x_batch_year                        IN     NUMBER   ,
    x_ci_sequence_number                IN     NUMBER   ,
    x_ci_cal_type                       IN     VARCHAR2 ,
    x_ci_sequence_number_acad           IN     NUMBER   ,
    x_ci_cal_type_acad                  IN     VARCHAR2 ,
    x_ci_cal_type_adm                   IN     VARCHAR2 ,
    x_ci_sequence_number_adm            IN     NUMBER   ,
    x_bam_id                            IN OUT NOCOPY NUMBER   ,
    x_css_academic_year                 IN     NUMBER   ,
    x_efc_frml                          IN     VARCHAR2 ,
    x_num_days_divisor                  IN     NUMBER   ,
    x_roundoff_fact                     IN     VARCHAR2 ,
    x_efc_dob                           IN     DATE     ,
    x_dl_code                           IN     VARCHAR2 ,
    x_ffel_code                         IN     VARCHAR2 ,
    x_pell_code                         IN     VARCHAR2 ,
    x_isir_code                         IN     VARCHAR2 ,
    x_profile_code                      IN     VARCHAR2 ,
    x_tolerance_limit                   IN     NUMBER   ,
    x_sys_award_year                    IN     VARCHAR2 ,
    x_award_year_status_code            IN     VARCHAR2 ,
    x_pell_participant_code             IN     VARCHAR2 ,
    x_dl_participant_code               IN     VARCHAR2 ,
    x_mode                              IN     VARCHAR2,
    x_publish_in_ss_flag                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 28-MAR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_ap_batch_aw_map_all
      WHERE    bam_id  = x_bam_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

    l_org_id                     igf_ap_batch_aw_map_all.org_id%TYPE  := igf_aw_gen.get_org_id;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
        x_last_updated_by := 1;
        x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
        x_last_updated_by := FND_GLOBAL.USER_ID;
        IF (x_last_updated_by IS NULL) THEN
            x_last_updated_by := -1;
        END IF;

        x_last_update_login := FND_GLOBAL.LOGIN_ID;

        IF (x_last_update_login IS NULL) THEN
            x_last_update_login := -1;
        END IF;
    ELSE
      FND_MESSAGE.SET_NAME ('FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    SELECT igf_ap_batch_aw_map_all_s.NEXTVAL INTO x_bam_id FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_batch_year                        => x_batch_year,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number_acad           => x_ci_sequence_number_acad,
      x_ci_cal_type_acad                  => x_ci_cal_type_acad,
      x_ci_cal_type_adm                   => x_ci_cal_type_adm,
      x_ci_sequence_number_adm            => x_ci_sequence_number_adm,
      x_bam_id                            => x_bam_id,
      x_css_academic_year                 => x_css_academic_year,
      x_efc_frml                          => x_efc_frml,
      x_num_days_divisor                  => x_num_days_divisor,
      x_roundoff_fact                     => x_roundoff_fact,
      x_efc_dob                           => x_efc_dob,
      x_dl_code                           => x_dl_code,
      x_ffel_code                         => x_ffel_code,
      x_pell_code                         => x_pell_code,
      x_isir_code                         => x_isir_code,
      x_profile_code                      => x_profile_code,
      x_tolerance_limit                   => x_tolerance_limit ,
      x_sys_award_year                    => x_sys_award_year ,
      x_award_year_status_code            => x_award_year_status_code,
      x_pell_participant_code             => x_pell_participant_code,
      x_dl_participant_code               => x_dl_participant_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_publish_in_ss_flag                => x_publish_in_ss_flag
    );

    INSERT INTO igf_ap_batch_aw_map_all (
      batch_year,
      ci_sequence_number,
      ci_cal_type,
      ci_sequence_number_acad,
      ci_cal_type_acad,
      ci_cal_type_adm,
      ci_sequence_number_adm,
      bam_id,
      css_academic_year,
      efc_frml ,
      num_days_divisor,
      roundoff_fact,
      efc_dob,
      dl_code,
      ffel_code,
      pell_code,
      isir_code,
      profile_code,
      tolerance_limit ,
      sys_award_year ,
      award_year_status_code ,
      pell_participant_code ,
      dl_participant_code ,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id,
      publish_in_ss_flag
    ) VALUES (
      new_references.batch_year,
      new_references.ci_sequence_number,
      new_references.ci_cal_type,
      NULL,
      NULL,
      NULL,
      NULL,
      new_references.bam_id,
      new_references.css_academic_year,
      new_references.efc_frml ,
      new_references.num_days_divisor,
      new_references.roundoff_fact,
      new_references.efc_dob,
      new_references.dl_code,
      new_references.ffel_code,
      new_references.pell_code,
      new_references.isir_code,
      new_references.profile_code,
      new_references.tolerance_limit ,
      new_references.sys_award_year ,
      new_references.award_year_status_code ,
      new_references.pell_participant_code ,
      new_references.dl_participant_code ,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      l_org_id,
      new_references.publish_in_ss_flag
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
    x_rowid                             IN     VARCHAR2 ,
    x_batch_year                        IN     NUMBER   ,
    x_ci_sequence_number                IN     NUMBER   ,
    x_ci_cal_type                       IN     VARCHAR2 ,
    x_ci_sequence_number_acad           IN     NUMBER   ,
    x_ci_cal_type_acad                  IN     VARCHAR2 ,
    x_ci_cal_type_adm                   IN     VARCHAR2 ,
    x_ci_sequence_number_adm            IN     NUMBER   ,
    x_bam_id                            IN     NUMBER   ,
    x_css_academic_year                 IN     NUMBER   ,
    x_efc_frml                          IN     VARCHAR2 ,
    x_num_days_divisor                  IN     NUMBER   ,
    x_roundoff_fact                     IN     VARCHAR2 ,
    x_efc_dob                           IN     DATE     ,
    x_dl_code                           IN     VARCHAR2 ,
    x_ffel_code                         IN     VARCHAR2 ,
    x_pell_code                         IN     VARCHAR2 ,
    x_isir_code                         IN     VARCHAR2 ,
    x_profile_code                      IN     VARCHAR2 ,
    x_tolerance_limit                   IN     NUMBER   ,
    x_sys_award_year                    IN     VARCHAR2 ,
    x_award_year_status_code            IN     VARCHAR2 ,
    x_pell_participant_code             IN     VARCHAR2 ,
    x_dl_participant_code               IN     VARCHAR2,
    x_publish_in_ss_flag                IN     VARCHAR2

  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 28-MAR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT batch_year,
             ci_sequence_number,
             ci_cal_type,
             css_academic_year,
             efc_frml ,
             num_days_divisor ,
             roundoff_fact  ,
             efc_dob,
             dl_code,
             ffel_code,
             pell_code,
             isir_code,
             profile_code,
             tolerance_limit,
             sys_award_year,
	     award_year_status_code,
             pell_participant_code,
             dl_participant_code,
             publish_in_ss_flag
      FROM   igf_ap_batch_aw_map_all
      WHERE  rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
       IGS_GE_MSG_STACK.ADD;
       CLOSE c1;
       APP_EXCEPTION.RAISE_EXCEPTION;
       RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.batch_year = x_batch_year)
        AND (tlinfo.ci_sequence_number = x_ci_sequence_number)
        AND (tlinfo.ci_cal_type = x_ci_cal_type)
        AND (tlinfo.css_academic_year = x_css_academic_year) OR  ((tlinfo.css_academic_year IS NULL) AND (x_css_academic_year IS NULL))
        AND (tlinfo.efc_frml = x_efc_frml) OR  ((tlinfo.efc_frml IS NULL) AND (x_efc_frml IS NULL))
        AND (tlinfo.num_days_divisor = x_efc_frml) OR  ((tlinfo.num_days_divisor IS NULL) AND (x_num_days_divisor IS NULL))
        AND (tlinfo.roundoff_fact = x_roundoff_fact) OR  ((tlinfo.roundoff_fact IS NULL) AND (x_roundoff_fact IS NULL))
        AND (tlinfo.efc_dob = x_efc_dob) OR  ((tlinfo.efc_dob IS NULL) AND (x_efc_dob IS NULL))
        AND (tlinfo.dl_code = x_dl_code) OR  ((tlinfo.dl_code IS NULL) AND (x_dl_code IS NULL))
        AND (tlinfo.ffel_code = x_ffel_code) OR  ((tlinfo.ffel_code IS NULL) AND (x_ffel_code IS NULL))
        AND (tlinfo.pell_code = x_pell_code) OR  ((tlinfo.pell_code IS NULL) AND (x_pell_code IS NULL))
        AND (tlinfo.isir_code = x_isir_code) OR  ((tlinfo.isir_code IS NULL) AND (x_isir_code IS NULL))
        AND (tlinfo.profile_code = x_profile_code) OR  ((tlinfo.profile_code IS NULL) AND (x_profile_code IS NULL))
        AND (tlinfo.tolerance_limit = x_tolerance_limit) OR  ((tlinfo.tolerance_limit IS NULL) AND (x_tolerance_limit IS NULL))
        AND (tlinfo.sys_award_year = x_sys_award_year) OR  ((tlinfo.sys_award_year IS NULL) AND (x_sys_award_year IS NULL))
        AND (tlinfo.award_year_status_code = x_award_year_status_code) OR  ((tlinfo.award_year_status_code IS NULL) AND (x_award_year_status_code IS NULL))
        AND (tlinfo.pell_participant_code = x_pell_participant_code) OR ((tlinfo.pell_participant_code IS NULL) AND (x_pell_participant_code IS NULL))
        AND (tlinfo.dl_participant_code = x_dl_participant_code) OR ((tlinfo.dl_participant_code IS NULL) AND (x_dl_participant_code IS NULL))
        AND ((tlinfo.publish_in_ss_flag = x_publish_in_ss_flag) OR ((tlinfo.publish_in_ss_flag IS NULL) AND (x_publish_in_ss_flag IS NULL)))
       ) THEN
      NULL;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2 ,
    x_batch_year                        IN     NUMBER   ,
    x_ci_sequence_number                IN     NUMBER   ,
    x_ci_cal_type                       IN     VARCHAR2 ,
    x_ci_sequence_number_acad           IN     NUMBER   ,
    x_ci_cal_type_acad                  IN     VARCHAR2 ,
    x_ci_cal_type_adm                   IN     VARCHAR2 ,
    x_ci_sequence_number_adm            IN     NUMBER   ,
    x_bam_id                            IN     NUMBER   ,
    x_css_academic_year                 IN     NUMBER   ,
    x_efc_frml                          IN     VARCHAR2 ,
    x_num_days_divisor                  IN     NUMBER   ,
    x_roundoff_fact                     IN     VARCHAR2 ,
    x_efc_dob                           IN     DATE     ,
    x_dl_code                           IN     VARCHAR2 ,
    x_ffel_code                         IN     VARCHAR2 ,
    x_pell_code                         IN     VARCHAR2 ,
    x_isir_code                         IN     VARCHAR2 ,
    x_profile_code                      IN     VARCHAR2 ,
    x_tolerance_limit                   IN     NUMBER   ,
    x_sys_award_year                    IN     VARCHAR2 ,
    x_award_year_status_code            IN     VARCHAR2 ,
    x_pell_participant_code             IN     VARCHAR2 ,
    x_dl_participant_code               IN     VARCHAR2 ,
    x_mode                              IN     VARCHAR2,
    x_publish_in_ss_flag                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 28-MAR-2001
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
        x_last_updated_by := FND_GLOBAL.USER_ID;
        IF x_last_updated_by IS NULL THEN
           x_last_updated_by := -1;
        END IF;

        x_last_update_login := FND_GLOBAL.LOGIN_ID;

        IF (x_last_update_login IS NULL) THEN
            x_last_update_login := -1;
        END IF;
    ELSE
       FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_batch_year                        => x_batch_year,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number_acad           => x_ci_sequence_number_acad,
      x_ci_cal_type_acad                  => x_ci_cal_type_acad,
      x_ci_cal_type_adm                   => x_ci_cal_type_adm,
      x_ci_sequence_number_adm            => x_ci_sequence_number_adm,
      x_bam_id                            => x_bam_id,
      x_css_academic_year                 => x_css_academic_year,
      x_efc_frml                          => x_efc_frml,
      x_num_days_divisor                  => x_num_days_divisor,
      x_roundoff_fact                     => x_roundoff_fact,
      x_efc_dob                           => x_efc_dob,
      x_dl_code                           => x_dl_code,
      x_ffel_code                         => x_ffel_code,
      x_pell_code                         => x_pell_code,
      x_isir_code                         => x_isir_code,
      x_profile_code                      => x_profile_code,
      x_tolerance_limit                   => x_tolerance_limit ,
      x_sys_award_year                    => x_sys_award_year ,
      x_award_year_status_code            => x_award_year_status_code ,
      x_pell_participant_code             => x_pell_participant_code ,
      x_dl_participant_code               => x_dl_participant_code ,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_publish_in_ss_flag                => x_publish_in_ss_flag
    );

    UPDATE igf_ap_batch_aw_map_all
      SET
        batch_year                        = new_references.batch_year,
        ci_sequence_number                = new_references.ci_sequence_number,
        ci_cal_type                       = new_references.ci_cal_type,
        css_academic_year                 = new_references.css_academic_year,
        efc_frml                          = new_references.efc_frml,
        num_days_divisor                  = new_references.num_days_divisor,
        roundoff_fact                     = new_references.roundoff_fact,
        efc_dob                           = new_references.efc_dob,
        dl_code                           = new_references.dl_code,
        ffel_code                         = new_references.ffel_code,
        pell_code                         = new_references.pell_code,
        isir_code                         = new_references.isir_code,
        profile_code                      = new_references.profile_code,
        tolerance_limit                   = new_references.tolerance_limit ,
        sys_award_year                    = new_references.sys_award_year ,
        award_year_status_code            = new_references.award_year_status_code ,
        pell_participant_code             = new_references.pell_participant_code,
        dl_participant_code               = new_references.dl_participant_code,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        publish_in_ss_flag                = new_references.publish_in_ss_flag
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2 ,
    x_batch_year                        IN     NUMBER   ,
    x_ci_sequence_number                IN     NUMBER   ,
    x_ci_cal_type                       IN     VARCHAR2 ,
    x_ci_sequence_number_acad           IN     NUMBER   ,
    x_ci_cal_type_acad                  IN     VARCHAR2 ,
    x_ci_cal_type_adm                   IN     VARCHAR2 ,
    x_ci_sequence_number_adm            IN     NUMBER   ,
    x_bam_id                            IN OUT NOCOPY NUMBER   ,
    x_css_academic_year                 IN     NUMBER   ,
    x_efc_frml                          IN     VARCHAR2 ,
    x_num_days_divisor                  IN     NUMBER   ,
    x_roundoff_fact                     IN     VARCHAR2 ,
    x_efc_dob                           IN     DATE     ,
    x_dl_code                           IN     VARCHAR2 ,
    x_ffel_code                         IN     VARCHAR2 ,
    x_pell_code                         IN     VARCHAR2 ,
    x_isir_code                         IN     VARCHAR2 ,
    x_profile_code                      IN     VARCHAR2 ,
    x_tolerance_limit                   IN     NUMBER   ,
    x_sys_award_year                    IN     VARCHAR2 ,
    x_award_year_status_code            IN     VARCHAR2 ,
    x_pell_participant_code             IN     VARCHAR2 ,
    x_dl_participant_code               IN     VARCHAR2 ,
    x_mode                              IN     VARCHAR2,
    x_publish_in_ss_flag                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 28-MAR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_batch_aw_map_all
      WHERE    bam_id = x_bam_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_batch_year,
        x_ci_sequence_number,
        x_ci_cal_type,
        x_ci_sequence_number_acad,
        x_ci_cal_type_acad,
        x_ci_cal_type_adm,
        x_ci_sequence_number_adm,
        x_bam_id,
        x_efc_frml  ,
        x_num_days_divisor,
        x_roundoff_fact   ,
        x_efc_dob,
        x_dl_code,
        x_ffel_code,
        x_pell_code,
        x_isir_code,
        x_profile_code,
        x_tolerance_limit ,
        x_sys_award_year ,
	x_award_year_status_code,
        x_pell_participant_code,
        x_dl_participant_code,
        x_mode,
        x_publish_in_ss_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_batch_year,
      x_ci_sequence_number,
      x_ci_cal_type,
      x_ci_sequence_number_acad,
      x_ci_cal_type_acad,
      x_ci_cal_type_adm,
      x_ci_sequence_number_adm,
      x_bam_id,
      x_css_academic_year,
      x_efc_frml   ,
      x_num_days_divisor ,
      x_roundoff_fact    ,
      x_efc_dob,
      x_dl_code,
      x_ffel_code,
      x_pell_code,
      x_isir_code,
      x_profile_code,
      x_tolerance_limit ,
      x_sys_award_year ,
      x_award_year_status_code,
      x_pell_participant_code,
      x_dl_participant_code,
      x_mode,
      x_publish_in_ss_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 28-MAR-2001
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

    DELETE FROM igf_ap_batch_aw_map_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_batch_aw_map_pkg;

/
