--------------------------------------------------------
--  DDL for Package Body IGS_AD_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_INTERFACE_PKG" AS
/* $Header: IGSAIB3B.pls 120.2 2005/09/22 23:52:29 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_interface_all%ROWTYPE;
  new_references igs_ad_interface_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_number                     IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_interface_id                      IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_source_type_id                    IN     NUMBER      DEFAULT NULL,
    x_surname                           IN     VARCHAR2    DEFAULT NULL,
    x_middle_name                       IN     VARCHAR2    DEFAULT NULL,
    x_given_names                       IN     VARCHAR2    DEFAULT NULL,
    x_preferred_given_name              IN     VARCHAR2    DEFAULT NULL,
    x_sex                               IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt                          IN     DATE        DEFAULT NULL,
    x_title                             IN     VARCHAR2    DEFAULT NULL,
    x_suffix                            IN     VARCHAR2    DEFAULT NULL,
    x_pre_name_adjunct                  IN     VARCHAR2    DEFAULT NULL,
    x_level_of_qual                     IN     NUMBER      DEFAULT NULL,
    x_proof_of_insurance                IN     VARCHAR2    DEFAULT NULL,
    x_proof_of_immun                    IN     VARCHAR2    DEFAULT NULL,
    x_pref_alternate_id                 IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_military_service_reg              IN     VARCHAR2    DEFAULT NULL,
    x_veteran                           IN     VARCHAR2    DEFAULT NULL,
    x_match_ind                         IN     VARCHAR2    DEFAULT NULL,
    x_person_match_ind                  IN     VARCHAR2    DEFAULT NULL,
    x_error_code                        IN     VARCHAR2    DEFAULT NULL,
    x_record_status                     IN     VARCHAR2    DEFAULT NULL,
    x_interface_run_id                  IN     NUMBER      DEFAULT NULL,
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
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_person_type_code                  IN     VARCHAR2    DEFAULT NULL,
    x_funnel_status                     IN     VARCHAR2    DEFAULT NULL,
    x_birth_city                        IN     VARCHAR2    DEFAULT NULL,
    x_birth_country                     IN     VARCHAR2    DEFAULT NULL,
    x_attribute21                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute22                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute23                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute24                       IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 21-NOV-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_INTERFACE_ALL
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
    new_references.person_number                     := x_person_number;
    new_references.org_id                            := x_org_id;
    new_references.interface_id                      := x_interface_id;
    new_references.batch_id                          := x_batch_id;
    new_references.source_type_id                    := x_source_type_id;
    new_references.surname                           := x_surname;
    new_references.middle_name                       := x_middle_name;
    new_references.given_names                       := x_given_names;
    new_references.preferred_given_name              := x_preferred_given_name;
    new_references.sex                               := x_sex;
    new_references.birth_dt                          := x_birth_dt;
    new_references.title                             := x_title;
    new_references.suffix                            := x_suffix;
    new_references.pre_name_adjunct                  := x_pre_name_adjunct;
    new_references.level_of_qual                     := x_level_of_qual;
    new_references.proof_of_insurance                := x_proof_of_insurance;
    new_references.proof_of_immun                    := x_proof_of_immun;
    new_references.pref_alternate_id                 := x_pref_alternate_id;
    new_references.person_id                         := x_person_id;
    new_references.status                            := x_status;
    new_references.military_service_reg              := x_military_service_reg;
    new_references.veteran                           := x_veteran;
    new_references.match_ind                         := x_match_ind;
    new_references.person_match_ind                  := x_person_match_ind;
    new_references.error_code                        := x_error_code;
    new_references.record_status                     := x_record_status;
    new_references.interface_run_id                  := x_interface_run_id;
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
    new_references.person_type_code                  := x_person_type_code;
    new_references.funnel_status                     := x_funnel_status;
    new_references.birth_city                        := x_birth_city;
    new_references.birth_country                     := x_birth_country;
    new_references.attribute21                       := x_attribute21;
    new_references.attribute22                       := x_attribute22;
    new_references.attribute23                       := x_attribute23;
    new_references.attribute24                       := x_attribute24;

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
  Created By : Ramesh.Rengarajan@Oracle.com
  Date Created On : 21-Nov-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'STATUS'  THEN
        new_references.status := column_value;
      ELSIF  UPPER(column_name) = 'SEX'  THEN
        new_references.sex := column_value;
      ELSIF  UPPER(column_name) = 'RECORD_STATUS'  THEN
        new_references.record_status := column_value;
        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'STATUS' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.status IN ('1','2','3','4'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'SEX' OR
      	Column_Name IS NULL THEN
        IF new_references.sex IS NOT NULL AND NOT (igs_pe_pers_imp_001.validate_lookup_type_code
	           ('HZ_GENDER', UPPER(new_references.sex),222)) THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'RECORD_STATUS' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.record_status IN ('1', '2', '3'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By : Ramesh.Rengarajan@Oracle.com
  Date Created On : 21-Nov-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Ad_Imp_Near_Mtch_Pkg.Get_FK_Igs_Ad_Interface (
      old_references.interface_id
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_interface_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : Ramesh.Rengarajan@Oracle.com
  Date Created On : 21-Nov-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_interface_all
      WHERE    interface_id = x_interface_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;
  END Get_PK_For_Validation;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_number                     IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_interface_id                      IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_source_type_id                    IN     NUMBER      DEFAULT NULL,
    x_surname                           IN     VARCHAR2    DEFAULT NULL,
    x_middle_name                       IN     VARCHAR2    DEFAULT NULL,
    x_given_names                       IN     VARCHAR2    DEFAULT NULL,
    x_preferred_given_name              IN     VARCHAR2    DEFAULT NULL,
    x_sex                               IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt                          IN     DATE        DEFAULT NULL,
    x_title                             IN     VARCHAR2    DEFAULT NULL,
    x_suffix                            IN     VARCHAR2    DEFAULT NULL,
    x_pre_name_adjunct                  IN     VARCHAR2    DEFAULT NULL,
    x_level_of_qual                     IN     NUMBER      DEFAULT NULL,
    x_proof_of_insurance                IN     VARCHAR2    DEFAULT NULL,
    x_proof_of_immun                    IN     VARCHAR2    DEFAULT NULL,
    x_pref_alternate_id                 IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_military_service_reg              IN     VARCHAR2    DEFAULT NULL,
    x_veteran                           IN     VARCHAR2    DEFAULT NULL,
    x_match_ind                         IN     VARCHAR2    DEFAULT NULL,
    x_person_match_ind                  IN     VARCHAR2    DEFAULT NULL,
    x_error_code                        IN     VARCHAR2    DEFAULT NULL,
    x_record_status                     IN     VARCHAR2    DEFAULT NULL,
    x_interface_run_id                  IN     NUMBER      DEFAULT NULL,
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
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_person_type_code                  IN     VARCHAR2    DEFAULT NULL,
    x_funnel_status                     IN     VARCHAR2    DEFAULT NULL,
    x_birth_city                        IN     VARCHAR2    DEFAULT NULL,
    x_birth_country                     IN     VARCHAR2    DEFAULT NULL,
    x_attribute21                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute22                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute23                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute24                       IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 21-NOV-2000
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
      x_person_number,
      x_org_id,
      x_interface_id,
      x_batch_id,
      x_source_type_id,
      x_surname,
      x_middle_name,
      x_given_names,
      x_preferred_given_name,
      x_sex,
      x_birth_dt,
      x_title,
      x_suffix,
      x_pre_name_adjunct,
      x_level_of_qual,
      x_proof_of_insurance,
      x_proof_of_immun,
      x_pref_alternate_id,
      x_person_id,
      x_status,
      x_military_service_reg,
      x_veteran,
      x_match_ind,
      x_person_match_ind,
      x_error_code,
      x_record_status,
      x_interface_run_id,
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
      x_last_update_login,
      x_person_type_code,
      x_funnel_status,
      x_birth_city,
      x_birth_country,
      x_attribute21,
      x_attribute22,
      x_attribute23,
      x_attribute24
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_Pk_For_Validation(
	new_references.interface_id)  THEN
	Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
	new_references.interface_id)  THEN
	Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

 END before_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_number                     IN     VARCHAR2,
    x_org_id                            IN     NUMBER DEFAULT NULL,
    x_interface_id                      IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_source_type_id                    IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_preferred_given_name              IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_title                             IN     VARCHAR2,
    x_suffix                            IN     VARCHAR2,
    x_pre_name_adjunct                  IN     VARCHAR2,
    x_level_of_qual                     IN     NUMBER,
    x_proof_of_insurance                IN     VARCHAR2,
    x_proof_of_immun                    IN     VARCHAR2,
    x_pref_alternate_id                 IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_military_service_reg              IN     VARCHAR2,
    x_veteran                           IN     VARCHAR2,
    x_match_ind                         IN     VARCHAR2,
    x_person_match_ind                  IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_record_status                     IN     VARCHAR2,
    x_interface_run_id                  IN     NUMBER,
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
    x_mode                              IN     VARCHAR2 DEFAULT NULL,
    x_person_type_code                  IN     VARCHAR2 DEFAULT NULL,
    x_funnel_status                     IN     VARCHAR2 DEFAULT NULL,
    x_birth_city                        IN     VARCHAR2 DEFAULT NULL,
    x_birth_country                     IN     VARCHAR2 DEFAULT NULL,
    x_attribute21                       IN     VARCHAR2,
    x_attribute22                       IN     VARCHAR2,
    x_attribute23                       IN     VARCHAR2,
    x_attribute24                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 21-NOV-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smvk	      13-Feb-2002     Call to igs_ge_gen_003.get_org_id
  ||				      w.r.t. SWCR006
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_interface_all
      WHERE    interface_id = x_interface_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (NVL(x_mode,'R') = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (NVL(x_mode,'R') = 'R') THEN
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
      x_person_number                     => x_person_number,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_interface_id                      => x_interface_id,
      x_batch_id                          => x_batch_id,
      x_source_type_id                    => x_source_type_id,
      x_surname                           => x_surname,
      x_middle_name                       => x_middle_name,
      x_given_names                       => x_given_names,
      x_preferred_given_name              => x_preferred_given_name,
      x_sex                               => x_sex,
      x_birth_dt                          => x_birth_dt,
      x_title                             => x_title,
      x_suffix                            => x_suffix,
      x_pre_name_adjunct                  => x_pre_name_adjunct,
      x_level_of_qual                     => x_level_of_qual,
      x_proof_of_insurance                => x_proof_of_insurance,
      x_proof_of_immun                    => x_proof_of_immun,
      x_pref_alternate_id                 => x_pref_alternate_id,
      x_person_id                         => x_person_id,
      x_status                            => x_status,
      x_military_service_reg              => x_military_service_reg,
      x_veteran                           => x_veteran,
      x_match_ind                         => x_match_ind,
      x_person_match_ind                  => x_person_match_ind,
      x_error_code                        => x_error_code,
      x_record_status                     => x_record_status,
      x_interface_run_id                  => x_interface_run_id,
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
      x_last_update_login                 => x_last_update_login,
      x_person_type_code                  => x_person_type_code,
      x_funnel_status                     => x_funnel_status,
      x_birth_city                        => x_birth_city,
      x_birth_country                     => x_birth_country,
      x_attribute21                       => x_attribute21,
      x_attribute22                       => x_attribute22,
      x_attribute23                       => x_attribute23,
      x_attribute24                       => x_attribute24
    );

    INSERT INTO igs_ad_interface_all (
      person_number,
      org_id,
      interface_id,
      batch_id,
      source_type_id,
      surname,
      middle_name,
      given_names,
      preferred_given_name,
      sex,
      birth_dt,
      title,
      suffix,
      pre_name_adjunct,
      level_of_qual,
      proof_of_insurance,
      proof_of_immun,
      pref_alternate_id,
      person_id,
      status,
      military_service_reg,
      veteran,
      match_ind,
      person_match_ind,
      error_code,
      record_status,
      interface_run_id,
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
      person_type_code,
      funnel_status,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      birth_city,
      birth_country,
      attribute21,
      attribute22,
      attribute23,
      attribute24
    ) VALUES (
      new_references.person_number,
      new_references.org_id,
      new_references.interface_id,
      new_references.batch_id,
      new_references.source_type_id,
      new_references.surname,
      new_references.middle_name,
      new_references.given_names,
      new_references.preferred_given_name,
      new_references.sex,
      new_references.birth_dt,
      new_references.title,
      new_references.suffix,
      new_references.pre_name_adjunct,
      new_references.level_of_qual,
      new_references.proof_of_insurance,
      new_references.proof_of_immun,
      new_references.pref_alternate_id,
      new_references.person_id,
      new_references.status,
      new_references.military_service_reg,
      new_references.veteran,
      new_references.match_ind,
      new_references.person_match_ind,
      new_references.error_code,
      new_references.record_status,
      new_references.interface_run_id,
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
      new_references.person_type_code,
      new_references.funnel_status,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      new_references.birth_city,
      new_references.birth_country,
      new_references.attribute21,
      new_references.attribute22,
      new_references.attribute23,
      new_references.attribute24
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
    x_person_number                     IN     VARCHAR2,
    x_org_id                            IN     NUMBER DEFAULT NULL,
    x_interface_id                      IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_source_type_id                    IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_preferred_given_name              IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_title                             IN     VARCHAR2,
    x_suffix                            IN     VARCHAR2,
    x_pre_name_adjunct                  IN     VARCHAR2,
    x_level_of_qual                     IN     NUMBER,
    x_proof_of_insurance                IN     VARCHAR2,
    x_proof_of_immun                    IN     VARCHAR2,
    x_pref_alternate_id                 IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_military_service_reg              IN     VARCHAR2,
    x_veteran                           IN     VARCHAR2,
    x_match_ind                         IN     VARCHAR2,
    x_person_match_ind                  IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_record_status                     IN     VARCHAR2,
    x_interface_run_id                  IN     NUMBER,
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
    x_person_type_code                  IN     VARCHAR2 DEFAULT NULL,
    x_funnel_status                     IN     VARCHAR2 DEFAULT NULL,
    x_birth_city                        IN     VARCHAR2 DEFAULT NULL,
    x_birth_country                     IN     VARCHAR2 DEFAULT NULL,
    x_attribute21                       IN     VARCHAR2,
    x_attribute22                       IN     VARCHAR2,
    x_attribute23                       IN     VARCHAR2,
    x_attribute24                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 21-NOV-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smvk	      13-Feb-2002     Removed org_id from cursor declaration
  ||  				      and conditional checking. w.r.t. SWCR006
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_number,
        interface_id,
        batch_id,
        source_type_id,
        surname,
        middle_name,
        given_names,
        preferred_given_name,
        sex,
        birth_dt,
        title,
        suffix,
        pre_name_adjunct,
        level_of_qual,
        proof_of_insurance,
        proof_of_immun,
        pref_alternate_id,
        person_id,
        status,
        military_service_reg,
        veteran,
        match_ind,
        person_match_ind,
        error_code,
        record_status,
        interface_run_id,
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
        person_type_code,
        funnel_status,
        birth_city,
        birth_country,
        attribute21,
        attribute22,
        attribute23,
        attribute24
      FROM  igs_ad_interface_all
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
        ((tlinfo.person_number = x_person_number) OR ((tlinfo.person_number IS NULL) AND (X_person_number IS NULL)))
        AND (tlinfo.interface_id = x_interface_id)
        AND (tlinfo.batch_id = x_batch_id)
        AND (tlinfo.source_type_id = x_source_type_id)
        AND (tlinfo.surname = x_surname)
        AND ((tlinfo.middle_name = x_middle_name) OR ((tlinfo.middle_name IS NULL) AND (X_middle_name IS NULL)))
        AND (tlinfo.given_names = x_given_names)
        AND ((tlinfo.preferred_given_name = x_preferred_given_name) OR ((tlinfo.preferred_given_name IS NULL) AND (X_preferred_given_name IS NULL)))
        AND ((tlinfo.sex = x_sex) OR ((tlinfo.sex IS NULL) AND (X_sex IS NULL)))
        AND ((tlinfo.birth_dt = x_birth_dt) OR ((tlinfo.birth_dt IS NULL) AND (X_birth_dt IS NULL)))
        AND ((tlinfo.title = x_title) OR ((tlinfo.title IS NULL) AND (X_title IS NULL)))
        AND ((tlinfo.suffix = x_suffix) OR ((tlinfo.suffix IS NULL) AND (X_suffix IS NULL)))
        AND ((tlinfo.pre_name_adjunct = x_pre_name_adjunct) OR ((tlinfo.pre_name_adjunct IS NULL) AND (X_pre_name_adjunct IS NULL)))
        AND ((tlinfo.level_of_qual = x_level_of_qual) OR ((tlinfo.level_of_qual IS NULL) AND (X_level_of_qual IS NULL)))
        AND ((tlinfo.proof_of_insurance = x_proof_of_insurance) OR ((tlinfo.proof_of_insurance IS NULL) AND (X_proof_of_insurance IS NULL)))
        AND ((tlinfo.proof_of_immun = x_proof_of_immun) OR ((tlinfo.proof_of_immun IS NULL) AND (X_proof_of_immun IS NULL)))
        AND ((tlinfo.pref_alternate_id = x_pref_alternate_id) OR ((tlinfo.pref_alternate_id IS NULL) AND (X_pref_alternate_id IS NULL)))
        AND ((tlinfo.person_id = x_person_id) OR ((tlinfo.person_id IS NULL) AND (X_person_id IS NULL)))
        AND (tlinfo.status = x_status)
        AND ((tlinfo.military_service_reg = x_military_service_reg) OR ((tlinfo.military_service_reg IS NULL) AND (X_military_service_reg IS NULL)))
        AND ((tlinfo.veteran = x_veteran) OR ((tlinfo.veteran IS NULL) AND (X_veteran IS NULL)))
        AND ((tlinfo.match_ind = x_match_ind) OR ((tlinfo.match_ind IS NULL) AND (X_match_ind IS NULL)))
        AND ((tlinfo.person_match_ind = x_person_match_ind) OR ((tlinfo.person_match_ind IS NULL) AND (X_person_match_ind IS NULL)))
        AND ((tlinfo.error_code = x_error_code) OR ((tlinfo.error_code IS NULL) AND (X_error_code IS NULL)))
        AND (tlinfo.record_status = x_record_status)
        AND ((tlinfo.interface_run_id = x_interface_run_id) OR ((tlinfo.interface_run_id IS NULL) AND (X_interface_run_id IS NULL)))
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
        AND ((tlinfo.person_type_code = x_person_type_code) OR ((tlinfo.person_type_code IS NULL) AND (X_person_type_code IS NULL)))
        AND ((tlinfo.funnel_status = x_funnel_status) OR ((tlinfo.funnel_status IS NULL) AND (X_funnel_status IS NULL)))
        AND ((tlinfo.birth_city = x_birth_city) OR ((tlinfo.birth_city IS NULL) AND (X_birth_city IS NULL)))
        AND ((tlinfo.birth_country = x_birth_country) OR ((tlinfo.birth_country IS NULL) AND (X_birth_country IS NULL)))
        AND ((tlinfo.attribute21 = x_attribute21) OR ((tlinfo.attribute21 IS NULL) AND (X_attribute21 IS NULL)))
        AND ((tlinfo.attribute22 = x_attribute22) OR ((tlinfo.attribute22 IS NULL) AND (X_attribute22 IS NULL)))
        AND ((tlinfo.attribute23 = x_attribute23) OR ((tlinfo.attribute23 IS NULL) AND (X_attribute23 IS NULL)))
        AND ((tlinfo.attribute24 = x_attribute24) OR ((tlinfo.attribute24 IS NULL) AND (X_attribute24 IS NULL)))
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
    x_person_number                     IN     VARCHAR2,
    x_org_id                            IN     NUMBER  DEFAULT NULL,
    x_interface_id                      IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_source_type_id                    IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_preferred_given_name              IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_title                             IN     VARCHAR2,
    x_suffix                            IN     VARCHAR2,
    x_pre_name_adjunct                  IN     VARCHAR2,
    x_level_of_qual                     IN     NUMBER,
    x_proof_of_insurance                IN     VARCHAR2,
    x_proof_of_immun                    IN     VARCHAR2,
    x_pref_alternate_id                 IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_military_service_reg              IN     VARCHAR2,
    x_veteran                           IN     VARCHAR2,
    x_match_ind                         IN     VARCHAR2,
    x_person_match_ind                  IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_record_status                     IN     VARCHAR2,
    x_interface_run_id                  IN     NUMBER,
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
    x_mode                              IN     VARCHAR2 DEFAULT NULL,
    x_person_type_code                  IN     VARCHAR2 DEFAULT NULL,
    x_funnel_status                     IN     VARCHAR2 DEFAULT NULL,
    x_birth_city                        IN     VARCHAR2 DEFAULT NULL,
    x_birth_country                     IN     VARCHAR2 DEFAULT NULL,
    x_attribute21                       IN     VARCHAR2,
    x_attribute22                       IN     VARCHAR2,
    x_attribute23                       IN     VARCHAR2,
    x_attribute24                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 21-NOV-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smvk	      13-Feb-2002     Call to igs_ge_gen_003.get_org_id
  ||				      w.r.t. SWCR006
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
    IF (NVL(x_mode,'R') = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (NVL(x_mode,'R') = 'R') THEN
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
      x_person_number                     => x_person_number,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_interface_id                      => x_interface_id,
      x_batch_id                          => x_batch_id,
      x_source_type_id                    => x_source_type_id,
      x_surname                           => x_surname,
      x_middle_name                       => x_middle_name,
      x_given_names                       => x_given_names,
      x_preferred_given_name              => x_preferred_given_name,
      x_sex                               => x_sex,
      x_birth_dt                          => x_birth_dt,
      x_title                             => x_title,
      x_suffix                            => x_suffix,
      x_pre_name_adjunct                  => x_pre_name_adjunct,
      x_level_of_qual                     => x_level_of_qual,
      x_proof_of_insurance                => x_proof_of_insurance,
      x_proof_of_immun                    => x_proof_of_immun,
      x_pref_alternate_id                 => x_pref_alternate_id,
      x_person_id                         => x_person_id,
      x_status                            => x_status,
      x_military_service_reg              => x_military_service_reg,
      x_veteran                           => x_veteran,
      x_match_ind                         => x_match_ind,
      x_person_match_ind                  => x_person_match_ind,
      x_error_code                        => x_error_code,
      x_record_status                     => x_record_status,
      x_interface_run_id                  => x_interface_run_id,
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
      x_last_update_login                 => x_last_update_login,
      x_person_type_code                  => x_person_type_code,
      x_funnel_status                     => x_funnel_status,
      x_birth_city                        => x_birth_city,
      x_birth_country                     => x_birth_country,
      x_attribute21                       => x_attribute21,
      x_attribute22                       => x_attribute22,
      x_attribute23                       => x_attribute23,
      x_attribute24                       => x_attribute24
    );

    IF (NVL(x_mode,'R') = 'R') THEN
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

    UPDATE igs_ad_interface_all
      SET
        person_number                     = new_references.person_number,
        interface_id                      = new_references.interface_id,
        batch_id                          = new_references.batch_id,
        source_type_id                    = new_references.source_type_id,
        surname                           = new_references.surname,
        middle_name                       = new_references.middle_name,
        given_names                       = new_references.given_names,
        preferred_given_name              = new_references.preferred_given_name,
        sex                               = new_references.sex,
        birth_dt                          = new_references.birth_dt,
        title                             = new_references.title,
        suffix                            = new_references.suffix,
        pre_name_adjunct                  = new_references.pre_name_adjunct,
        level_of_qual                     = new_references.level_of_qual,
        proof_of_insurance                = new_references.proof_of_insurance,
        proof_of_immun                    = new_references.proof_of_immun,
        pref_alternate_id                 = new_references.pref_alternate_id,
        person_id                         = new_references.person_id,
        status                            = new_references.status,
        military_service_reg              = new_references.military_service_reg,
        veteran                           = new_references.veteran,
        match_ind                         = new_references.match_ind,
        person_match_ind                  = new_references.person_match_ind,
        error_code                        = new_references.error_code,
        record_status                     = new_references.record_status,
        interface_run_id                  = new_references.interface_run_id,
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
        person_type_code                  = new_references.person_type_code,
        funnel_status                     = new_references.funnel_status,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        birth_city                        = new_references.birth_city,
        birth_country                     = new_references.birth_country,
        felony_convicted_flag             = old_references.felony_convicted_flag,
        attribute21                       = new_references.attribute21,
        attribute22                       = new_references.attribute22,
        attribute23                       = new_references.attribute23,
        attribute24                       = new_references.attribute24
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_number                     IN     VARCHAR2,
    x_org_id                            IN     NUMBER  DEFAULT NULL,
    x_interface_id                      IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_source_type_id                    IN     NUMBER,
    x_surname                           IN     VARCHAR2,
    x_middle_name                       IN     VARCHAR2,
    x_given_names                       IN     VARCHAR2,
    x_preferred_given_name              IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_title                             IN     VARCHAR2,
    x_suffix                            IN     VARCHAR2,
    x_pre_name_adjunct                  IN     VARCHAR2,
    x_level_of_qual                     IN     NUMBER,
    x_proof_of_insurance                IN     VARCHAR2,
    x_proof_of_immun                    IN     VARCHAR2,
    x_pref_alternate_id                 IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_military_service_reg              IN     VARCHAR2,
    x_veteran                           IN     VARCHAR2,
    x_match_ind                         IN     VARCHAR2,
    x_person_match_ind                  IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_record_status                     IN     VARCHAR2,
    x_interface_run_id                  IN     NUMBER,
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
    x_mode                              IN     VARCHAR2 DEFAULT NULL,
    x_person_type_code                  IN     VARCHAR2 DEFAULT NULL,
    x_funnel_status                     IN     VARCHAR2 DEFAULT NULL,
    x_birth_city                        IN     VARCHAR2 DEFAULT NULL,
    x_birth_country                     IN     VARCHAR2 DEFAULT NULL,
    x_attribute21                       IN     VARCHAR2,
    x_attribute22                       IN     VARCHAR2,
    x_attribute23                       IN     VARCHAR2,
    x_attribute24                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 21-NOV-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_interface_all
      WHERE    interface_id = x_interface_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_person_number,
        x_org_id,
        x_interface_id,
        x_batch_id,
        x_source_type_id,
        x_surname,
        x_middle_name,
        x_given_names,
        x_preferred_given_name,
        x_sex,
        x_birth_dt,
        x_title,
        x_suffix,
        x_pre_name_adjunct,
        x_level_of_qual,
        x_proof_of_insurance,
        x_proof_of_immun,
        x_pref_alternate_id,
        x_person_id,
        x_status,
        x_military_service_reg,
        x_veteran,
        x_match_ind,
        x_person_match_ind,
        x_error_code,
        x_record_status,
        x_interface_run_id,
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
        NVL(x_mode,'R'),
        x_person_type_code,
        x_funnel_status,
        x_birth_city,
        x_birth_country,
        x_attribute21,
        x_attribute22,
        x_attribute23,
        x_attribute24
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_person_number,
      x_org_id,
      x_interface_id,
      x_batch_id,
      x_source_type_id,
      x_surname,
      x_middle_name,
      x_given_names,
      x_preferred_given_name,
      x_sex,
      x_birth_dt,
      x_title,
      x_suffix,
      x_pre_name_adjunct,
      x_level_of_qual,
      x_proof_of_insurance,
      x_proof_of_immun,
      x_pref_alternate_id,
      x_person_id,
      x_status,
      x_military_service_reg,
      x_veteran,
      x_match_ind,
      x_person_match_ind,
      x_error_code,
      x_record_status,
      x_interface_run_id,
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
      NVL(x_mode,'R'),
      x_person_type_code,
      x_funnel_status,
      x_birth_city,
      x_birth_country,
      x_attribute21,
      x_attribute22,
      x_attribute23,
      x_attribute24
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.com
  ||  Created On : 21-NOV-2000
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

    DELETE FROM igs_ad_interface_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ad_interface_pkg;

/
