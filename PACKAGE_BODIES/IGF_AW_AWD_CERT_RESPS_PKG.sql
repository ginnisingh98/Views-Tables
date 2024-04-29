--------------------------------------------------------
--  DDL for Package Body IGF_AW_AWD_CERT_RESPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_AWD_CERT_RESPS_PKG" AS
/* $Header: IGFWI75B.pls 120.0 2005/09/09 17:13:40 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_awd_cert_resps%ROWTYPE;
  new_references igf_aw_awd_cert_resps%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_award_prd_cd                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_awd_cert_code                     IN     VARCHAR2,
    x_response_txt                      IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 05-JUL-2005
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_aw_awd_cert_resps
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
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.award_prd_cd                      := x_award_prd_cd;
    new_references.base_id                           := x_base_id;
    new_references.awd_cert_code                     := x_awd_cert_code;
    new_references.response_txt                      := x_response_txt;
    new_references.object_version_number             := x_object_version_number;

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
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_award_prd_cd                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_awd_cert_code                     IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 05-JUL-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_awd_cert_resps
      WHERE    ci_cal_type = x_ci_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      award_prd_cd = x_award_prd_cd
      AND      base_id = x_base_id
      AND      awd_cert_code = x_awd_cert_code
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

  PROCEDURE after_dml(
                      p_action IN     VARCHAR2
                     ) AS
  /*
  ||  Created By : veramach
  ||  Created On : 26/August/2005
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR c_update_funds_auth(
                             cp_ci_cal_type          igf_aw_awd_cert_resps.ci_cal_type%TYPE,
                             cp_ci_sequence_number   igf_aw_awd_cert_resps.ci_sequence_number%TYPE,
                             cp_award_prd_cd         igf_aw_awd_cert_resps.award_prd_cd%TYPE,
                             cp_awd_cert_code        igf_aw_awd_cert_resps.awd_cert_code%TYPE
                            ) IS
    SELECT update_funds_auth_flag
      FROM igf_aw_award_certs
     WHERE ci_cal_type        = cp_ci_cal_type
       AND ci_sequence_number = cp_ci_sequence_number
       AND award_prd_cd       = cp_award_prd_cd
       AND awd_cert_code      = cp_awd_cert_code;
    l_funds_auth igf_aw_award_certs.update_funds_auth_flag%TYPE;

  CURSOR c_pe_hz_parties(
                         cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                        ) IS
    SELECT pe.ROWID row_id,
           pe.*
      FROM igs_pe_hz_parties pe,
           igf_ap_fa_base_rec_all fa
     WHERE pe.party_id = fa.person_id
       AND fa.base_id   = cp_base_id;
  l_pe_hz_parties  c_pe_hz_parties%ROWTYPE;

  BEGIN
    IF p_action = 'INSERT'  THEN
      l_funds_auth := NULL;
      OPEN c_update_funds_auth(
                               new_references.ci_cal_type,
                               new_references.ci_sequence_number,
                               new_references.award_prd_cd,
                               new_references.awd_cert_code
                              );
      FETCH c_update_funds_auth INTO l_funds_auth;
      CLOSE c_update_funds_auth;

      IF NVL(l_funds_auth,'N') = 'Y' THEN
        /*
          Update student's authorization flag
        */
        OPEN c_pe_hz_parties(new_references.base_id);
        FETCH c_pe_hz_parties INTO l_pe_hz_parties;
        CLOSE c_pe_hz_parties;

        igs_pe_hz_parties_pkg.update_row(
                                         x_rowid                    => l_pe_hz_parties.row_id,
                                         x_party_id                 => l_pe_hz_parties.party_id,
                                         x_deceased_ind             => l_pe_hz_parties.deceased_ind,
                                         x_archive_exclusion_ind    => l_pe_hz_parties.archive_exclusion_ind,
                                         x_archive_dt               => l_pe_hz_parties.archive_dt,
                                         x_purge_exclusion_ind      => l_pe_hz_parties.purge_exclusion_ind,
                                         x_purge_dt                 => l_pe_hz_parties.purge_dt,
                                         x_oracle_username          => l_pe_hz_parties.oracle_username,
                                         x_proof_of_ins             => l_pe_hz_parties.proof_of_ins,
                                         x_proof_of_immu            => l_pe_hz_parties.proof_of_immu,
                                         x_level_of_qual            => l_pe_hz_parties.level_of_qual,
                                         x_military_service_reg     => l_pe_hz_parties.military_service_reg,
                                         x_veteran                  => l_pe_hz_parties.veteran,
                                         x_institution_cd           => l_pe_hz_parties.institution_cd,
                                         x_oi_local_institution_ind => l_pe_hz_parties.oi_local_institution_ind,
                                         x_oi_os_ind                => l_pe_hz_parties.oi_os_ind,
                                         x_oi_govt_institution_cd   => l_pe_hz_parties.oi_govt_institution_cd,
                                         x_oi_inst_control_type     => l_pe_hz_parties.oi_inst_control_type,
                                         x_oi_institution_type      => l_pe_hz_parties.oi_institution_type,
                                         x_oi_institution_status    => l_pe_hz_parties.oi_institution_status,
                                         x_ou_start_dt              => l_pe_hz_parties.ou_start_dt,
                                         x_ou_end_dt                => l_pe_hz_parties.ou_end_dt,
                                         x_ou_member_type           => l_pe_hz_parties.ou_member_type,
                                         x_ou_org_status            => l_pe_hz_parties.ou_org_status,
                                         x_ou_org_type              => l_pe_hz_parties.ou_org_type,
                                         x_inst_org_ind             => l_pe_hz_parties.inst_org_ind,
                                         x_inst_priority_cd         => l_pe_hz_parties.inst_priority_cd,
                                         x_inst_eps_code            => l_pe_hz_parties.inst_eps_code,
                                         x_inst_phone_country_code  => l_pe_hz_parties.inst_phone_country_code,
                                         x_inst_phone_area_code     => l_pe_hz_parties.inst_phone_area_code,
                                         x_inst_phone_number        => l_pe_hz_parties.inst_phone_number,
                                         x_adv_studies_classes      => l_pe_hz_parties.adv_studies_classes,
                                         x_honors_classes           => l_pe_hz_parties.honors_classes,
                                         x_class_size               => l_pe_hz_parties.class_size,
                                         x_sec_school_location_id   => l_pe_hz_parties.sec_school_location_id,
                                         x_percent_plan_higher_edu  => l_pe_hz_parties.percent_plan_higher_edu,
                                         x_fund_authorization       => new_references.response_txt,
                                         x_pe_info_verify_time      => l_pe_hz_parties.pe_info_verify_time,
                                         x_birth_city               => l_pe_hz_parties.birth_city,
                                         x_birth_country            => l_pe_hz_parties.birth_country,
                                         x_oss_org_unit_cd          => l_pe_hz_parties.oss_org_unit_cd,
                                         x_felony_convicted_flag    => l_pe_hz_parties.felony_convicted_flag,
                                         x_mode                     => 'R'
                                        );

      END IF;
    END IF;

    IF p_action = 'UPDATE' THEN
      l_funds_auth := NULL;
      OPEN c_update_funds_auth(
                               new_references.ci_cal_type,
                               new_references.ci_sequence_number,
                               new_references.award_prd_cd,
                               new_references.awd_cert_code
                              );
      FETCH c_update_funds_auth INTO l_funds_auth;
      CLOSE c_update_funds_auth;

      IF NVL(l_funds_auth,'N') = 'Y' AND
         old_references.response_txt IS NOT NULL AND
         new_references.response_txt IS NOT NULL AND
         old_references.response_txt <> new_references.response_txt THEN
        /*
          Update student's authorization flag
        */
        OPEN c_pe_hz_parties(new_references.base_id);
        FETCH c_pe_hz_parties INTO l_pe_hz_parties;
        CLOSE c_pe_hz_parties;

        igs_pe_hz_parties_pkg.update_row(
                                         x_rowid                    => l_pe_hz_parties.row_id,
                                         x_party_id                 => l_pe_hz_parties.party_id,
                                         x_deceased_ind             => l_pe_hz_parties.deceased_ind,
                                         x_archive_exclusion_ind    => l_pe_hz_parties.archive_exclusion_ind,
                                         x_archive_dt               => l_pe_hz_parties.archive_dt,
                                         x_purge_exclusion_ind      => l_pe_hz_parties.purge_exclusion_ind,
                                         x_purge_dt                 => l_pe_hz_parties.purge_dt,
                                         x_oracle_username          => l_pe_hz_parties.oracle_username,
                                         x_proof_of_ins             => l_pe_hz_parties.proof_of_ins,
                                         x_proof_of_immu            => l_pe_hz_parties.proof_of_immu,
                                         x_level_of_qual            => l_pe_hz_parties.level_of_qual,
                                         x_military_service_reg     => l_pe_hz_parties.military_service_reg,
                                         x_veteran                  => l_pe_hz_parties.veteran,
                                         x_institution_cd           => l_pe_hz_parties.institution_cd,
                                         x_oi_local_institution_ind => l_pe_hz_parties.oi_local_institution_ind,
                                         x_oi_os_ind                => l_pe_hz_parties.oi_os_ind,
                                         x_oi_govt_institution_cd   => l_pe_hz_parties.oi_govt_institution_cd,
                                         x_oi_inst_control_type     => l_pe_hz_parties.oi_inst_control_type,
                                         x_oi_institution_type      => l_pe_hz_parties.oi_institution_type,
                                         x_oi_institution_status    => l_pe_hz_parties.oi_institution_status,
                                         x_ou_start_dt              => l_pe_hz_parties.ou_start_dt,
                                         x_ou_end_dt                => l_pe_hz_parties.ou_end_dt,
                                         x_ou_member_type           => l_pe_hz_parties.ou_member_type,
                                         x_ou_org_status            => l_pe_hz_parties.ou_org_status,
                                         x_ou_org_type              => l_pe_hz_parties.ou_org_type,
                                         x_inst_org_ind             => l_pe_hz_parties.inst_org_ind,
                                         x_inst_priority_cd         => l_pe_hz_parties.inst_priority_cd,
                                         x_inst_eps_code            => l_pe_hz_parties.inst_eps_code,
                                         x_inst_phone_country_code  => l_pe_hz_parties.inst_phone_country_code,
                                         x_inst_phone_area_code     => l_pe_hz_parties.inst_phone_area_code,
                                         x_inst_phone_number        => l_pe_hz_parties.inst_phone_number,
                                         x_adv_studies_classes      => l_pe_hz_parties.adv_studies_classes,
                                         x_honors_classes           => l_pe_hz_parties.honors_classes,
                                         x_class_size               => l_pe_hz_parties.class_size,
                                         x_sec_school_location_id   => l_pe_hz_parties.sec_school_location_id,
                                         x_percent_plan_higher_edu  => l_pe_hz_parties.percent_plan_higher_edu,
                                         x_fund_authorization       => new_references.response_txt,
                                         x_pe_info_verify_time      => l_pe_hz_parties.pe_info_verify_time,
                                         x_birth_city               => l_pe_hz_parties.birth_city,
                                         x_birth_country            => l_pe_hz_parties.birth_country,
                                         x_oss_org_unit_cd          => l_pe_hz_parties.oss_org_unit_cd,
                                         x_felony_convicted_flag    => l_pe_hz_parties.felony_convicted_flag,
                                         x_mode                     => 'R'
                                        );
      END IF;
    END IF;
  END after_dml;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_award_prd_cd                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_awd_cert_code                     IN     VARCHAR2,
    x_response_txt                      IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 05-JUL-2005
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
      x_ci_cal_type,
      x_ci_sequence_number,
      x_award_prd_cd,
      x_base_id,
      x_awd_cert_code,
      x_response_txt,
      x_object_version_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ci_cal_type,
             new_references.ci_sequence_number,
             new_references.award_prd_cd,
             new_references.base_id,
             new_references.awd_cert_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.ci_cal_type,
             new_references.ci_sequence_number,
             new_references.award_prd_cd,
             new_references.base_id,
             new_references.awd_cert_code
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
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_award_prd_cd                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_awd_cert_code                     IN     VARCHAR2,
    x_response_txt                      IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 05-JUL-2005
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
      fnd_message.set_token ('ROUTINE', 'IGF_AW_AWD_CERT_RESPS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_award_prd_cd                      => x_award_prd_cd,
      x_base_id                           => x_base_id,
      x_awd_cert_code                     => x_awd_cert_code,
      x_response_txt                      => x_response_txt,
      x_object_version_number             => x_object_version_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_aw_awd_cert_resps (
      ci_cal_type,
      ci_sequence_number,
      award_prd_cd,
      base_id,
      awd_cert_code,
      response_txt,
      object_version_number,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
      new_references.award_prd_cd,
      new_references.base_id,
      new_references.awd_cert_code,
      new_references.response_txt,
      new_references.object_version_number,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

    after_dml(
              p_action => 'INSERT'
             );
  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_award_prd_cd                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_awd_cert_code                     IN     VARCHAR2,
    x_response_txt                      IN     VARCHAR2,
    x_object_version_number             IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 05-JUL-2005
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        response_txt,
        object_version_number
      FROM  igf_aw_awd_cert_resps
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
        (tlinfo.response_txt = x_response_txt)
        AND (tlinfo.object_version_number = x_object_version_number)
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
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_award_prd_cd                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_awd_cert_code                     IN     VARCHAR2,
    x_response_txt                      IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 05-JUL-2005
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
      fnd_message.set_token ('ROUTINE', 'IGF_AW_AWD_CERT_RESPS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_award_prd_cd                      => x_award_prd_cd,
      x_base_id                           => x_base_id,
      x_awd_cert_code                     => x_awd_cert_code,
      x_response_txt                      => x_response_txt,
      x_object_version_number             => x_object_version_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_aw_awd_cert_resps
      SET
        response_txt                      = new_references.response_txt,
        object_version_number             = new_references.object_version_number,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    after_dml(
              p_action => 'UPDATE'
             );

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_award_prd_cd                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_awd_cert_code                     IN     VARCHAR2,
    x_response_txt                      IN     VARCHAR2,
    x_object_version_number             IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 05-JUL-2005
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_awd_cert_resps
      WHERE    ci_cal_type                       = x_ci_cal_type
      AND      ci_sequence_number                = x_ci_sequence_number
      AND      award_prd_cd                      = x_award_prd_cd
      AND      base_id                           = x_base_id
      AND      awd_cert_code                     = x_awd_cert_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_award_prd_cd,
        x_base_id,
        x_awd_cert_code,
        x_response_txt,
        x_object_version_number,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_award_prd_cd,
      x_base_id,
      x_awd_cert_code,
      x_response_txt,
      x_object_version_number,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 05-JUL-2005
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

    DELETE FROM igf_aw_awd_cert_resps
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_awd_cert_resps_pkg;

/
