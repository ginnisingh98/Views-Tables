--------------------------------------------------------
--  DDL for Package Body IGS_PE_HZ_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_HZ_PARTIES_PKG" AS
/* $Header: IGSNI77B.pls 120.5 2006/02/22 06:24:28 vredkar ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_hz_parties%ROWTYPE;
  new_references igs_pe_hz_parties%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_party_id                          IN     NUMBER      ,
    x_deceased_ind                      IN     VARCHAR2    ,
    x_archive_exclusion_ind             IN     VARCHAR2    ,
    x_archive_dt                        IN     DATE        ,
    x_purge_exclusion_ind               IN     VARCHAR2    ,
    x_purge_dt                          IN     DATE        ,
    x_oracle_username                   IN     VARCHAR2    ,
    x_proof_of_ins                      IN     VARCHAR2    ,
    x_proof_of_immu                     IN     VARCHAR2    ,
    x_level_of_qual                     IN     NUMBER      ,
    x_military_service_reg              IN     VARCHAR2    ,
    x_veteran                           IN     VARCHAR2    ,
    x_institution_cd                    IN     VARCHAR2    ,
    x_oi_local_institution_ind          IN     VARCHAR2    ,
    x_oi_os_ind                         IN     VARCHAR2    ,
    x_oi_govt_institution_cd            IN     VARCHAR2    ,
    x_oi_inst_control_type              IN     VARCHAR2    ,
    x_oi_institution_type               IN     VARCHAR2    ,
    x_oi_institution_status             IN     VARCHAR2    ,
    x_ou_start_dt                       IN     DATE        ,
    x_ou_end_dt                         IN     DATE        ,
    x_ou_member_type                    IN     VARCHAR2    ,
    x_ou_org_status                     IN     VARCHAR2    ,
    x_ou_org_type                       IN     VARCHAR2    ,
    x_inst_org_ind                      IN     VARCHAR2    ,
    x_inst_priority_cd                  IN     VARCHAR2    ,
    x_inst_eps_code                     IN     VARCHAR2    ,
    x_inst_phone_country_code           IN     VARCHAR2    ,
    x_inst_phone_area_code              IN     VARCHAR2    ,
    x_inst_phone_number                 IN     VARCHAR2    ,
    x_adv_studies_classes               IN     NUMBER      ,
    x_honors_classes                    IN     NUMBER      ,
    x_class_size                        IN     NUMBER      ,
    x_sec_school_location_id            IN     NUMBER      ,
    x_percent_plan_higher_edu           IN     NUMBER      ,
    x_fund_authorization                IN     VARCHAR2    ,
    x_pe_info_verify_time		IN     DATE     ,
    x_birth_city                        IN     VARCHAR2    ,
    x_birth_country                     IN     VARCHAR2    ,
    x_oss_org_unit_cd			IN     VARCHAR2,
    x_felony_convicted_flag		IN     VARCHAR2,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Sameer.Manglm@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_HZ_PARTIES
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
    new_references.party_id                          := x_party_id;
    new_references.deceased_ind                      := x_deceased_ind;
    new_references.archive_exclusion_ind             := x_archive_exclusion_ind;
    new_references.archive_dt                        := x_archive_dt;
    new_references.purge_exclusion_ind               := x_purge_exclusion_ind;
    new_references.purge_dt                          := x_purge_dt;
    new_references.oracle_username                   := x_oracle_username;
    new_references.proof_of_ins                      := x_proof_of_ins;
    new_references.proof_of_immu                     := x_proof_of_immu;
    new_references.level_of_qual                     := x_level_of_qual;
    new_references.military_service_reg              := x_military_service_reg;
    new_references.veteran                           := x_veteran;
    new_references.institution_cd                    := x_institution_cd;
    new_references.oi_local_institution_ind          := x_oi_local_institution_ind;
    new_references.oi_os_ind                         := x_oi_os_ind;
    new_references.oi_govt_institution_cd            := x_oi_govt_institution_cd;
    new_references.oi_inst_control_type              := x_oi_inst_control_type;
    new_references.oi_institution_type               := x_oi_institution_type;
    new_references.oi_institution_status             := x_oi_institution_status;
    new_references.ou_start_dt                       := x_ou_start_dt;
    new_references.ou_end_dt                         := x_ou_end_dt;
    new_references.ou_member_type                    := x_ou_member_type;
    new_references.ou_org_status                     := x_ou_org_status;
    new_references.ou_org_type                       := x_ou_org_type;
    new_references.inst_org_ind                      := x_inst_org_ind;
    new_references.inst_priority_cd                  := x_inst_priority_cd;
    new_references.inst_eps_code                     := x_inst_eps_code;
    new_references.inst_phone_country_code           := x_inst_phone_country_code;
    new_references.inst_phone_area_code              := x_inst_phone_area_code;
    new_references.inst_phone_number                 := x_inst_phone_number;
    new_references.adv_studies_classes               := x_adv_studies_classes;
    new_references.honors_classes                    := x_honors_classes;
    new_references.class_size                        := x_class_size;
    new_references.sec_school_location_id            := x_sec_school_location_id;
    new_references.percent_plan_higher_edu           := x_percent_plan_higher_edu;
    new_references.fund_authorization                := x_fund_authorization;
    new_references.pe_info_verify_time               := x_pe_info_verify_time;
    new_references.birth_city                        := x_birth_city;
    new_references.birth_country                     := x_birth_country;
    new_references.oss_org_unit_cd		     := x_oss_org_unit_cd;
    new_references.felony_convicted_flag	     := x_felony_convicted_flag;

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
    x_party_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Sameer.Manglm@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_hz_parties
      WHERE    party_id = x_party_id
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

  PROCEDURE get_uk_for_validation (
    x_oss_org_unit_cd                   IN     VARCHAR2 ,
    x_inst_org_ind			IN     VARCHAR2
  )AS
  /*
  ||  Created By : gayam.maheswari@oracle.com
  ||  Created On : 19-AUG-2005
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_org_unit_exists(cp_oss_org_unit_cd VARCHAR2) IS
    SELECT 'X'
    FROM igs_pe_hz_parties
    WHERE oss_org_unit_cd = cp_oss_org_unit_cd;

    l_exists VARCHAR2(1);
  BEGIN
    OPEN cur_org_unit_exists(x_oss_org_unit_cd);
    FETCH cur_org_unit_exists INTO l_exists;
    IF cur_org_unit_exists%FOUND THEN
      CLOSE cur_org_unit_exists;
      FND_MESSAGE.Set_Name('IGS','IGS_OR_INST_UNIQUE');
      IF x_inst_org_ind = 'O' THEN
          FND_MESSAGE.SET_TOKEN('ORG_INST_CD',FND_MESSAGE.GET_STRING('IGS','IGS_ORG_UNIT_CD'));
      ELSIF x_inst_org_ind = 'I' THEN
          FND_MESSAGE.SET_TOKEN('ORG_INST_CD',FND_MESSAGE.GET_STRING('IGS','IGS_OR_INSTITUTION_CODE'));
      END IF;
      IGS_GE_MSG_STACK.Add;
      APP_EXCEPTION.Raise_Exception;
      RETURN;
    END IF;

    CLOSE cur_org_unit_exists;
  END get_uk_for_validation;

  PROCEDURE get_fk_igs_ad_code_classes1(x_code_id NUMBER) AS
  /*
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 09-AUG-2001
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT rowid
      FROM   igs_pe_hz_parties
      WHERE  ((sec_school_location_id = x_code_id));

    lv_rowid   cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF cur_rowid%FOUND THEN
      CLOSE cur_rowid;
      FND_MESSAGE.Set_Name('IGS','IGS_OR_PHP1_ACC');
      IGS_GE_MSG_STACK.Add;
      APP_EXCEPTION.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_code_classes1;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Sameer.Manglm@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : To check for the existence of parent records
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || ssawhney         6FEB2002      veteran is now a lookup, so get pk from IGS_LOOKUPS_VIEW_PKG
  */

    FUNCTION validate_pk(x_party_id NUMBER) RETURN BOOLEAN IS
      CURSOR cur_rowid IS
        SELECT   rowid
        FROM     HZ_PARTIES
        WHERE    party_id = x_party_id
        FOR UPDATE NOWAIT;
      lv_rowid cur_rowid%RowType;
    BEGIN
      Open cur_rowid;
      Fetch cur_rowid INTO lv_rowid;

      IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
 	    RETURN(TRUE);
      ELSE
        Close cur_rowid;
	    RETURN(FALSE);
      END IF;

    END validate_pk;

  BEGIN
    IF (((old_references.party_id = new_references.party_id)) OR
        ((new_references.party_id IS NULL))) THEN
      NULL;
    ELSE
      if Not validate_pk ( new_references.party_id )  then
		 Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		 IGS_GE_MSG_STACK.ADD;
		 App_Exception.Raise_Exception;
      end if;
    END IF;

-- added by ssawhney 2203778. veteran is now a lookup so validate.

    IF  (((old_references.veteran = new_references.veteran)) OR
        ((new_references.veteran IS NULL))) THEN
       NULL;
    ELSE
       IF NOT IGS_LOOKUPS_VIEW_PKG.get_pk_for_validation('VETERAN_STATUS',new_references.veteran) THEN
          FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
	  IGS_GE_MSG_STACK.ADD;
	  APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF  (((old_references.inst_priority_cd = new_references.inst_priority_cd)) OR
        ((new_references.inst_priority_cd IS NULL))) THEN
       NULL;
    ELSE
       IF NOT IGS_LOOKUPS_VIEW_PKG.get_pk_for_validation('OR_INST_PRIORITY_CD',new_references.inst_priority_cd) THEN
          FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
    	  IGS_GE_MSG_STACK.ADD;
	      APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

  END check_parent_existance;

  PROCEDURE validate_local_ind
  IS
/*
  ||  Created By : kumma
  ||  Created On : 01-JUL-2002
  ||  Purpose : validation for local indicator for institutions
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  ssawhney        30-sep          institution_cd is only for ORG, so new cursor introduced to get party_number
  ||  gmaheswa        11-sep-2003     local indicator is set only for a single institution based on the profile value.
  ||  pkpatel         11-DEC-2003     Bug 2863933 (Modified the update statement and called it conditionally)
  ||  gmaheswa	      07-01-2003      Bug 3354341 (Loop is kept to make local instituion ind to 'N' for all institutions whose
  ||                                  local instituion indicator is set to 'Y'. This is useful when there is corrupt data i.e
  ||                                  having more than one local instituion.
  */
	e_resource_busy                 EXCEPTION;
    PRAGMA EXCEPTION_INIT (e_resource_busy, -54);

	CURSOR local_inst_cur  IS
	SELECT party_id
	FROM igs_pe_hz_parties
	WHERE oi_local_institution_ind ='Y'
	FOR UPDATE NOWAIT;

	l_inst_rec local_inst_cur%ROWTYPE;
  BEGIN
       -- set old records local institution indicator to N to make sure that the local indicator is set only
       -- for a single institution.

	    --explicitly lock the record.
            -- #3354341 gmaheswa : Sets Local institution indicator to Y for a single record.
	    OPEN local_inst_cur;
	    LOOP
                  FETCH local_inst_cur INTO l_inst_rec;
                  EXIT WHEN local_inst_cur%NOTFOUND;
		  UPDATE igs_pe_hz_parties
		  SET oi_local_institution_ind = 'N'
		  WHERE party_id = l_inst_rec.party_id;
	    END LOOP;
	    CLOSE local_inst_cur;

  EXCEPTION
  WHEN e_resource_busy THEN
       -- ssawhney just raise the exception.
       APP_EXCEPTION.RAISE_EXCEPTION;

  END validate_local_ind ;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_party_id                          IN     NUMBER      ,
    x_deceased_ind                      IN     VARCHAR2    ,
    x_archive_exclusion_ind             IN     VARCHAR2    ,
    x_archive_dt                        IN     DATE        ,
    x_purge_exclusion_ind               IN     VARCHAR2    ,
    x_purge_dt                          IN     DATE        ,
    x_oracle_username                   IN     VARCHAR2    ,
    x_proof_of_ins                      IN     VARCHAR2    ,
    x_proof_of_immu                     IN     VARCHAR2    ,
    x_level_of_qual                     IN     NUMBER      ,
    x_military_service_reg              IN     VARCHAR2    ,
    x_veteran                           IN     VARCHAR2    ,
    x_institution_cd                    IN     VARCHAR2    ,
    x_oi_local_institution_ind          IN     VARCHAR2    ,
    x_oi_os_ind                         IN     VARCHAR2    ,
    x_oi_govt_institution_cd            IN     VARCHAR2    ,
    x_oi_inst_control_type              IN     VARCHAR2    ,
    x_oi_institution_type               IN     VARCHAR2    ,
    x_oi_institution_status             IN     VARCHAR2    ,
    x_ou_start_dt                       IN     DATE        ,
    x_ou_end_dt                         IN     DATE        ,
    x_ou_member_type                    IN     VARCHAR2    ,
    x_ou_org_status                     IN     VARCHAR2    ,
    x_ou_org_type                       IN     VARCHAR2    ,
    x_inst_org_ind                      IN     VARCHAR2    ,
    x_inst_priority_cd                  IN     VARCHAR2    ,
    x_inst_eps_code                     IN     VARCHAR2    ,
    x_inst_phone_country_code           IN     VARCHAR2    ,
    x_inst_phone_area_code              IN     VARCHAR2    ,
    x_inst_phone_number                 IN     VARCHAR2    ,
    x_adv_studies_classes               IN     NUMBER      ,
    x_honors_classes                    IN     NUMBER      ,
    x_class_size                        IN     NUMBER      ,
    x_sec_school_location_id            IN     NUMBER      ,
    x_percent_plan_higher_edu           IN     NUMBER      ,
    x_fund_authorization                IN     VARCHAR2    ,
    x_pe_info_verify_time		IN     DATE        ,
    x_birth_city                        IN     VARCHAR2    ,
    x_birth_country                     IN     VARCHAR2    ,
    x_oss_org_unit_cd			IN     VARCHAR2,
    x_felony_convicted_flag		IN     VARCHAR2,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Sameer.Manglm@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  kumma           28-JUN-2002     Added validations to make sure that only one
  ||                                  institution should be marked local, 2425349
  || ssawhney                         x_institution_cd changed to x_party_id
  || gmaheswa         15-sep-2003     validation to check only one institution should be
  ||                                  marked as local is deleted in before insert, as it is taken
  ||				      care by other modules,2863933
  ||  (reverse chronological order - newest change first)
  */


  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_party_id,
      x_deceased_ind,
      x_archive_exclusion_ind,
      x_archive_dt,
      x_purge_exclusion_ind,
      x_purge_dt,
      x_oracle_username,
      x_proof_of_ins,
      x_proof_of_immu,
      x_level_of_qual,
      x_military_service_reg,
      x_veteran,
      x_institution_cd,
      x_oi_local_institution_ind,
      x_oi_os_ind,
      x_oi_govt_institution_cd,
      x_oi_inst_control_type,
      x_oi_institution_type,
      x_oi_institution_status,
      x_ou_start_dt,
      x_ou_end_dt,
      x_ou_member_type,
      x_ou_org_status,
      x_ou_org_type,
      x_inst_org_ind,
      x_inst_priority_cd,
      x_inst_eps_code ,
      x_inst_phone_country_code,
      x_inst_phone_area_code,
      x_inst_phone_number,
      x_adv_studies_classes,
      x_honors_classes,
      x_class_size,
      x_sec_school_location_id,
      x_percent_plan_higher_edu,
      x_fund_authorization,
      x_pe_info_verify_time,
      x_birth_city ,
      x_birth_country,
      x_oss_org_unit_cd,
      x_felony_convicted_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN

      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.party_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

      IF new_references.oss_org_unit_cd IS NOT NULL THEN
         get_uk_for_validation(new_references.oss_org_unit_cd,new_references.inst_org_ind);
      END IF;

      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
       -- validate the local indicator
       -- Bug #3354341:gmaheswa:NVL check is introduced for old_references.oi_local_institution_ind
	   IF new_references.inst_org_ind = 'I' AND
	       (new_references.oi_local_institution_ind = 'Y' AND NVL(old_references.oi_local_institution_ind,'N') = 'N') THEN

           validate_local_ind;

       END IF;

      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.party_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

      IF new_references.oss_org_unit_cd IS NOT NULL THEN
         get_uk_for_validation(new_references.oss_org_unit_cd,new_references.inst_org_ind);
      END IF;

    END IF;

  END before_dml;



  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_deceased_ind                      IN     VARCHAR2,
    x_archive_exclusion_ind             IN     VARCHAR2,
    x_archive_dt                        IN     DATE,
    x_purge_exclusion_ind               IN     VARCHAR2,
    x_purge_dt                          IN     DATE,
    x_oracle_username                   IN     VARCHAR2,
    x_proof_of_ins                      IN     VARCHAR2,
    x_proof_of_immu                     IN     VARCHAR2,
    x_level_of_qual                     IN     NUMBER,
    x_military_service_reg              IN     VARCHAR2,
    x_veteran                           IN     VARCHAR2,
    x_institution_cd                    IN     VARCHAR2,
    x_oi_local_institution_ind          IN     VARCHAR2,
    x_oi_os_ind                         IN     VARCHAR2,
    x_oi_govt_institution_cd            IN     VARCHAR2,
    x_oi_inst_control_type              IN     VARCHAR2,
    x_oi_institution_type               IN     VARCHAR2,
    x_oi_institution_status             IN     VARCHAR2,
    x_ou_start_dt                       IN     DATE,
    x_ou_end_dt                         IN     DATE,
    x_ou_member_type                    IN     VARCHAR2,
    x_ou_org_status                     IN     VARCHAR2,
    x_ou_org_type                       IN     VARCHAR2,
    x_inst_org_ind                      IN     VARCHAR2,
    x_inst_priority_cd                  IN     VARCHAR2    ,
    x_inst_eps_code                     IN     VARCHAR2    ,
    x_inst_phone_country_code           IN     VARCHAR2    ,
    x_inst_phone_area_code              IN     VARCHAR2    ,
    x_inst_phone_number                 IN     VARCHAR2    ,
    x_adv_studies_classes               IN     NUMBER      ,
    x_honors_classes                    IN     NUMBER      ,
    x_class_size                        IN     NUMBER      ,
    x_sec_school_location_id            IN     NUMBER      ,
    x_percent_plan_higher_edu           IN     NUMBER      ,
    x_fund_authorization                IN     VARCHAR2    ,
    x_pe_info_verify_time		IN     DATE     ,
    x_birth_city                        IN     VARCHAR2    ,
    x_birth_country                     IN     VARCHAR2    ,
    x_oss_org_unit_cd			IN     VARCHAR2,
    x_felony_convicted_flag		IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Sameer.Manglm@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_pe_hz_parties
      WHERE    party_id = x_party_id;

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


    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_party_id                          => x_party_id,
      x_deceased_ind                      => x_deceased_ind,
      x_archive_exclusion_ind             => x_archive_exclusion_ind,
      x_archive_dt                        => x_archive_dt,
      x_purge_exclusion_ind               => x_purge_exclusion_ind,
      x_purge_dt                          => x_purge_dt,
      x_oracle_username                   => x_oracle_username,
      x_proof_of_ins                      => x_proof_of_ins,
      x_proof_of_immu                     => x_proof_of_immu,
      x_level_of_qual                     => x_level_of_qual,
      x_military_service_reg              => x_military_service_reg,
      x_veteran                           => x_veteran,
      x_institution_cd                    => x_institution_cd,
      x_oi_local_institution_ind          => x_oi_local_institution_ind,
      x_oi_os_ind                         => x_oi_os_ind,
      x_oi_govt_institution_cd            => x_oi_govt_institution_cd,
      x_oi_inst_control_type              => x_oi_inst_control_type,
      x_oi_institution_type               => x_oi_institution_type,
      x_oi_institution_status             => x_oi_institution_status,
      x_ou_start_dt                       => x_ou_start_dt,
      x_ou_end_dt                         => x_ou_end_dt,
      x_ou_member_type                    => x_ou_member_type,
      x_ou_org_status                     => x_ou_org_status,
      x_ou_org_type                       => x_ou_org_type,
      x_inst_org_ind                      => x_inst_org_ind,
      x_inst_priority_cd                  => x_inst_priority_cd,
      x_inst_eps_code                     => x_inst_eps_code,
      x_inst_phone_country_code           => x_inst_phone_country_code,
      x_inst_phone_area_code              => x_inst_phone_area_code,
      x_inst_phone_number                 => x_inst_phone_number,
      x_adv_studies_classes               => x_adv_studies_classes,
      x_honors_classes                    => x_honors_classes,
      x_class_size                        => x_class_size,
      x_sec_school_location_id            => x_sec_school_location_id,
      x_percent_plan_higher_edu           => x_percent_plan_higher_edu,
      x_fund_authorization                => x_fund_authorization,
      x_pe_info_verify_time		  =>  x_pe_info_verify_time,
      x_birth_city                        => x_birth_city,
      x_birth_country                     => x_birth_country,
      x_oss_org_unit_cd			  => x_oss_org_unit_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_felony_convicted_flag             => x_felony_convicted_flag
    );
     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;


 INSERT INTO igs_pe_hz_parties (
      party_id,
      deceased_ind,
      archive_exclusion_ind,
      archive_dt,
      purge_exclusion_ind,
      purge_dt,
      oracle_username,
      proof_of_ins,
      proof_of_immu,
      level_of_qual,
      military_service_reg,
      veteran,
      institution_cd,
      oi_local_institution_ind,
      oi_os_ind,
      oi_govt_institution_cd,
      oi_inst_control_type,
      oi_institution_type,
      oi_institution_status,
      ou_start_dt,
      ou_end_dt,
      ou_member_type,
      ou_org_status,
      ou_org_type,
      inst_org_ind,
      inst_priority_cd,
      inst_eps_code ,
      inst_phone_country_code,
      inst_phone_area_code,
      inst_phone_number,
      adv_studies_classes,
      honors_classes,
      class_size,
      sec_school_location_id,
      percent_plan_higher_edu,
      fund_authorization,
      pe_info_verify_time,
      birth_city   ,
      birth_country,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date ,
      oss_org_unit_cd,
      felony_convicted_flag
    ) VALUES (
      new_references.party_id,
      new_references.deceased_ind,
      new_references.archive_exclusion_ind,
      new_references.archive_dt,
      new_references.purge_exclusion_ind,
      new_references.purge_dt,
      new_references.oracle_username,
      new_references.proof_of_ins,
      new_references.proof_of_immu,
      new_references.level_of_qual,
      new_references.military_service_reg,
      new_references.veteran,
      new_references.institution_cd,
      new_references.oi_local_institution_ind,
      new_references.oi_os_ind,
      new_references.oi_govt_institution_cd,
      new_references.oi_inst_control_type,
      new_references.oi_institution_type,
      new_references.oi_institution_status,
      new_references.ou_start_dt,
      new_references.ou_end_dt,
      new_references.ou_member_type,
      new_references.ou_org_status,
      new_references.ou_org_type,
      new_references.inst_org_ind,
      new_references.inst_priority_cd,
      new_references.inst_eps_code,
      new_references.inst_phone_country_code,
      new_references.inst_phone_area_code,
      new_references.inst_phone_number,
      new_references.adv_studies_classes,
      new_references.honors_classes,
      new_references.class_size,
      new_references.sec_school_location_id,
      new_references.percent_plan_higher_edu,
      new_references.fund_authorization,
      new_references.pe_info_verify_time,
      new_references.birth_city   ,
      new_references.birth_country,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date ,
      new_references.oss_org_unit_cd,
      new_references.felony_convicted_flag
    );
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
    x_party_id                          IN     NUMBER,
    x_deceased_ind                      IN     VARCHAR2,
    x_archive_exclusion_ind             IN     VARCHAR2,
    x_archive_dt                        IN     DATE,
    x_purge_exclusion_ind               IN     VARCHAR2,
    x_purge_dt                          IN     DATE,
    x_oracle_username                   IN     VARCHAR2,
    x_proof_of_ins                      IN     VARCHAR2,
    x_proof_of_immu                     IN     VARCHAR2,
    x_level_of_qual                     IN     NUMBER,
    x_military_service_reg              IN     VARCHAR2,
    x_veteran                           IN     VARCHAR2,
    x_institution_cd                    IN     VARCHAR2,
    x_oi_local_institution_ind          IN     VARCHAR2,
    x_oi_os_ind                         IN     VARCHAR2,
    x_oi_govt_institution_cd            IN     VARCHAR2,
    x_oi_inst_control_type              IN     VARCHAR2,
    x_oi_institution_type               IN     VARCHAR2,
    x_oi_institution_status             IN     VARCHAR2,
    x_ou_start_dt                       IN     DATE,
    x_ou_end_dt                         IN     DATE,
    x_ou_member_type                    IN     VARCHAR2,
    x_ou_org_status                     IN     VARCHAR2,
    x_ou_org_type                       IN     VARCHAR2,
    x_inst_org_ind                      IN     VARCHAR2,
    x_inst_priority_cd                  IN     VARCHAR2    ,
    x_inst_eps_code                     IN     VARCHAR2    ,
    x_inst_phone_country_code           IN     VARCHAR2    ,
    x_inst_phone_area_code              IN     VARCHAR2    ,
    x_inst_phone_number                 IN     VARCHAR2    ,
    x_adv_studies_classes               IN     NUMBER      ,
    x_honors_classes                    IN     NUMBER      ,
    x_class_size                        IN     NUMBER      ,
    x_sec_school_location_id            IN     NUMBER      ,
    x_percent_plan_higher_edu           IN     NUMBER      ,
    x_fund_authorization                IN     VARCHAR2    ,
    x_pe_info_verify_time		IN     DATE        ,
    x_birth_city                        IN     VARCHAR2    ,
    x_birth_country                     IN     VARCHAR2    ,
    x_oss_org_unit_cd			IN     VARCHAR2,
    x_felony_convicted_flag		IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Sameer.Manglm@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        deceased_ind,
        archive_exclusion_ind,
        archive_dt,
        purge_exclusion_ind,
        purge_dt,
        oracle_username,
        proof_of_ins,
        proof_of_immu,
        level_of_qual,
        military_service_reg,
        veteran,
        institution_cd,
        oi_local_institution_ind,
        oi_os_ind,
        oi_govt_institution_cd,
        oi_inst_control_type,
        oi_institution_type,
        oi_institution_status,
        ou_start_dt,
        ou_end_dt,
        ou_member_type,
        ou_org_status,
        ou_org_type,
        inst_org_ind,
        inst_priority_cd,
        inst_eps_code ,
        inst_phone_country_code,
        inst_phone_area_code,
        inst_phone_number,
        adv_studies_classes,
        honors_classes,
        class_size,
        sec_school_location_id,
        percent_plan_higher_edu,
	fund_authorization,
	pe_info_verify_time,
        birth_city    ,
        birth_country,
	oss_org_unit_cd,
        felony_convicted_flag
      FROM  igs_pe_hz_parties
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
        ((tlinfo.deceased_ind = x_deceased_ind) OR ((tlinfo.deceased_ind IS NULL) AND (X_deceased_ind IS NULL)))
        AND ((tlinfo.archive_exclusion_ind = x_archive_exclusion_ind) OR ((tlinfo.archive_exclusion_ind IS NULL) AND (X_archive_exclusion_ind IS NULL)))
        AND ((tlinfo.archive_dt = x_archive_dt) OR ((tlinfo.archive_dt IS NULL) AND (X_archive_dt IS NULL)))
        AND ((tlinfo.purge_exclusion_ind = x_purge_exclusion_ind) OR ((tlinfo.purge_exclusion_ind IS NULL) AND (X_purge_exclusion_ind IS NULL)))
        AND ((tlinfo.purge_dt = x_purge_dt) OR ((tlinfo.purge_dt IS NULL) AND (X_purge_dt IS NULL)))
        AND ((tlinfo.oracle_username = x_oracle_username) OR ((tlinfo.oracle_username IS NULL) AND (X_oracle_username IS NULL)))
        AND ((tlinfo.proof_of_ins = x_proof_of_ins) OR ((tlinfo.proof_of_ins IS NULL) AND (X_proof_of_ins IS NULL)))
        AND ((tlinfo.proof_of_immu = x_proof_of_immu) OR ((tlinfo.proof_of_immu IS NULL) AND (X_proof_of_immu IS NULL)))
        AND ((tlinfo.level_of_qual = x_level_of_qual) OR ((tlinfo.level_of_qual IS NULL) AND (X_level_of_qual IS NULL)))
        AND ((tlinfo.military_service_reg = x_military_service_reg) OR ((tlinfo.military_service_reg IS NULL) AND (X_military_service_reg IS NULL)))
        AND ((tlinfo.veteran = x_veteran) OR ((tlinfo.veteran IS NULL) AND (X_veteran IS NULL)))
        AND ((tlinfo.institution_cd = x_institution_cd) OR ((tlinfo.institution_cd IS NULL) AND (X_institution_cd IS NULL)))
        AND ((tlinfo.oi_local_institution_ind = x_oi_local_institution_ind) OR ((tlinfo.oi_local_institution_ind IS NULL) AND (X_oi_local_institution_ind IS NULL)))
        AND ((tlinfo.oi_os_ind = x_oi_os_ind) OR ((tlinfo.oi_os_ind IS NULL) AND (X_oi_os_ind IS NULL)))
        AND ((tlinfo.oi_govt_institution_cd = x_oi_govt_institution_cd) OR ((tlinfo.oi_govt_institution_cd IS NULL) AND (X_oi_govt_institution_cd IS NULL)))
        AND ((tlinfo.oi_inst_control_type = x_oi_inst_control_type) OR ((tlinfo.oi_inst_control_type IS NULL) AND (X_oi_inst_control_type IS NULL)))
        AND ((tlinfo.oi_institution_type = x_oi_institution_type) OR ((tlinfo.oi_institution_type IS NULL) AND (X_oi_institution_type IS NULL)))
        AND ((tlinfo.oi_institution_status = x_oi_institution_status) OR ((tlinfo.oi_institution_status IS NULL) AND (X_oi_institution_status IS NULL)))
        AND ((tlinfo.ou_start_dt = x_ou_start_dt) OR ((tlinfo.ou_start_dt IS NULL) AND (X_ou_start_dt IS NULL)))
        AND ((tlinfo.ou_end_dt = x_ou_end_dt) OR ((tlinfo.ou_end_dt IS NULL) AND (X_ou_end_dt IS NULL)))
        AND ((tlinfo.ou_member_type = x_ou_member_type) OR ((tlinfo.ou_member_type IS NULL) AND (X_ou_member_type IS NULL)))
        AND ((tlinfo.ou_org_status = x_ou_org_status) OR ((tlinfo.ou_org_status IS NULL) AND (X_ou_org_status IS NULL)))
        AND ((tlinfo.ou_org_type = x_ou_org_type) OR ((tlinfo.ou_org_type IS NULL) AND (X_ou_org_type IS NULL)))
        AND ((tlinfo.inst_org_ind = x_inst_org_ind) OR ((tlinfo.inst_org_ind IS NULL) AND (X_inst_org_ind IS NULL)))
        AND ((tlinfo.inst_priority_cd = x_inst_priority_cd) OR ((tlinfo.inst_priority_cd IS NULL) AND (x_inst_priority_cd IS NULL)))
        AND ((tlinfo.inst_eps_code = x_inst_eps_code) OR ((tlinfo.inst_eps_code IS NULL) AND (x_inst_eps_code IS NULL)))
        AND ((tlinfo.inst_phone_country_code = x_inst_phone_country_code) OR ((tlinfo.inst_phone_country_code IS NULL) AND (x_inst_phone_country_code IS NULL)))
        AND ((tlinfo.inst_phone_area_code  = x_inst_phone_area_code) OR ((tlinfo.inst_phone_area_code IS NULL) AND (x_inst_phone_area_code IS NULL)))
        AND ((tlinfo.inst_phone_number = x_inst_phone_number) OR ((tlinfo.inst_phone_number IS NULL) AND (x_inst_phone_number IS NULL)))
        AND ((tlinfo.adv_studies_classes = x_adv_studies_classes) OR ((tlinfo.adv_studies_classes IS NULL) AND (x_adv_studies_classes IS NULL)))
        AND ((tlinfo.honors_classes = x_honors_classes) OR ((tlinfo.honors_classes IS NULL) AND (x_honors_classes IS NULL)))
        AND ((tlinfo.class_size = x_class_size) OR ((tlinfo.class_size IS NULL) AND (x_class_size IS NULL)))
        AND ((tlinfo.sec_school_location_id = x_sec_school_location_id) OR ((tlinfo.sec_school_location_id IS NULL) AND (x_sec_school_location_id IS NULL)))
        AND ((tlinfo.percent_plan_higher_edu = x_percent_plan_higher_edu) OR ((tlinfo.percent_plan_higher_edu IS NULL) AND (x_percent_plan_higher_edu IS NULL)))
        AND ((tlinfo.fund_authorization = x_fund_authorization) OR ((tlinfo.fund_authorization IS NULL) AND (x_fund_authorization IS NULL)))
        AND ((tlinfo.pe_info_verify_time = x_pe_info_verify_time) OR ((tlinfo.pe_info_verify_time IS NULL) AND (x_pe_info_verify_time IS NULL)))
        AND ((tlinfo.birth_city = x_birth_city) OR ((tlinfo.birth_city IS NULL) AND (x_birth_city IS NULL)))
        AND ((tlinfo.birth_country = x_birth_country) OR ((tlinfo.birth_country IS NULL) AND (x_birth_country IS NULL)))
	AND ((tlinfo.oss_org_unit_cd = x_oss_org_unit_cd) OR ((tlinfo.oss_org_unit_cd IS NULL) AND (x_oss_org_unit_cd IS NULL)))
	AND ((tlinfo.felony_convicted_flag = x_felony_convicted_flag) OR ((tlinfo.felony_convicted_flag IS NULL) AND (x_felony_convicted_flag IS NULL)))
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
    x_party_id                          IN     NUMBER,
    x_deceased_ind                      IN     VARCHAR2,
    x_archive_exclusion_ind             IN     VARCHAR2,
    x_archive_dt                        IN     DATE,
    x_purge_exclusion_ind               IN     VARCHAR2,
    x_purge_dt                          IN     DATE,
    x_oracle_username                   IN     VARCHAR2,
    x_proof_of_ins                      IN     VARCHAR2,
    x_proof_of_immu                     IN     VARCHAR2,
    x_level_of_qual                     IN     NUMBER,
    x_military_service_reg              IN     VARCHAR2,
    x_veteran                           IN     VARCHAR2,
    x_institution_cd                    IN     VARCHAR2,
    x_oi_local_institution_ind          IN     VARCHAR2,
    x_oi_os_ind                         IN     VARCHAR2,
    x_oi_govt_institution_cd            IN     VARCHAR2,
    x_oi_inst_control_type              IN     VARCHAR2,
    x_oi_institution_type               IN     VARCHAR2,
    x_oi_institution_status             IN     VARCHAR2,
    x_ou_start_dt                       IN     DATE,
    x_ou_end_dt                         IN     DATE,
    x_ou_member_type                    IN     VARCHAR2,
    x_ou_org_status                     IN     VARCHAR2,
    x_ou_org_type                       IN     VARCHAR2,
    x_inst_org_ind                      IN     VARCHAR2,
    x_inst_priority_cd                  IN     VARCHAR2    ,
    x_inst_eps_code                     IN     VARCHAR2    ,
    x_inst_phone_country_code           IN     VARCHAR2    ,
    x_inst_phone_area_code              IN     VARCHAR2    ,
    x_inst_phone_number                 IN     VARCHAR2    ,
    x_adv_studies_classes               IN     NUMBER      ,
    x_honors_classes                    IN     NUMBER      ,
    x_class_size                        IN     NUMBER      ,
    x_sec_school_location_id            IN     NUMBER      ,
    x_percent_plan_higher_edu           IN     NUMBER      ,
    x_fund_authorization                IN     VARCHAR2    ,
    x_pe_info_verify_time               IN     DATE        ,
    x_birth_city                        IN     VARCHAR2    ,
    x_birth_country                     IN     VARCHAR2    ,
    x_oss_org_unit_cd			IN     VARCHAR2,
    x_felony_convicted_flag		IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Sameer.Manglm@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
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
      x_party_id                          => x_party_id,
      x_deceased_ind                      => x_deceased_ind,
      x_archive_exclusion_ind             => x_archive_exclusion_ind,
      x_archive_dt                        => x_archive_dt,
      x_purge_exclusion_ind               => x_purge_exclusion_ind,
      x_purge_dt                          => x_purge_dt,
      x_oracle_username                   => x_oracle_username,
      x_proof_of_ins                      => x_proof_of_ins,
      x_proof_of_immu                     => x_proof_of_immu,
      x_level_of_qual                     => x_level_of_qual,
      x_military_service_reg              => x_military_service_reg,
      x_veteran                           => x_veteran,
      x_institution_cd                    => x_institution_cd,
      x_oi_local_institution_ind          => x_oi_local_institution_ind,
      x_oi_os_ind                         => x_oi_os_ind,
      x_oi_govt_institution_cd            => x_oi_govt_institution_cd,
      x_oi_inst_control_type              => x_oi_inst_control_type,
      x_oi_institution_type               => x_oi_institution_type,
      x_oi_institution_status             => x_oi_institution_status,
      x_ou_start_dt                       => x_ou_start_dt,
      x_ou_end_dt                         => x_ou_end_dt,
      x_ou_member_type                    => x_ou_member_type,
      x_ou_org_status                     => x_ou_org_status,
      x_ou_org_type                       => x_ou_org_type,
      x_inst_org_ind                      => x_inst_org_ind,
      x_inst_priority_cd                  => x_inst_priority_cd,
      x_inst_eps_code                     => x_inst_eps_code,
      x_inst_phone_country_code           => x_inst_phone_country_code,
      x_inst_phone_area_code              => x_inst_phone_area_code,
      x_inst_phone_number                 => x_inst_phone_number,
      x_adv_studies_classes               => x_adv_studies_classes,
      x_honors_classes                    => x_honors_classes,
      x_class_size                        => x_class_size,
      x_sec_school_location_id            => x_sec_school_location_id,
      x_percent_plan_higher_edu           => x_percent_plan_higher_edu,
      x_fund_authorization                => x_fund_authorization,
      x_birth_city                        => x_birth_city,
      x_birth_country                     => x_birth_country,
      x_oss_org_unit_cd			  => x_oss_org_unit_cd,
      x_felony_convicted_flag		  => x_felony_convicted_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_pe_info_verify_time               => x_pe_info_verify_time
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
 UPDATE igs_pe_hz_parties
      SET
        deceased_ind                      = new_references.deceased_ind,
        archive_exclusion_ind             = new_references.archive_exclusion_ind,
        archive_dt                        = new_references.archive_dt,
        purge_exclusion_ind               = new_references.purge_exclusion_ind,
        purge_dt                          = new_references.purge_dt,
        oracle_username                   = new_references.oracle_username,
        proof_of_ins                      = new_references.proof_of_ins,
        proof_of_immu                     = new_references.proof_of_immu,
        level_of_qual                     = new_references.level_of_qual,
        military_service_reg              = new_references.military_service_reg,
        veteran                           = new_references.veteran,
        institution_cd                    = new_references.institution_cd,
        oi_local_institution_ind          = new_references.oi_local_institution_ind,
        oi_os_ind                         = new_references.oi_os_ind,
        oi_govt_institution_cd            = new_references.oi_govt_institution_cd,
        oi_inst_control_type              = new_references.oi_inst_control_type,
        oi_institution_type               = new_references.oi_institution_type,
        oi_institution_status             = new_references.oi_institution_status,
        ou_start_dt                       = new_references.ou_start_dt,
        ou_end_dt                         = new_references.ou_end_dt,
        ou_member_type                    = new_references.ou_member_type,
        ou_org_status                     = new_references.ou_org_status,
        ou_org_type                       = new_references.ou_org_type,
        inst_org_ind                      = new_references.inst_org_ind,
        inst_priority_cd                  = new_references.inst_priority_cd,
        inst_eps_code                     = new_references.inst_eps_code,
        inst_phone_country_code           = new_references.inst_phone_country_code,
        inst_phone_area_code              = new_references.inst_phone_area_code,
        inst_phone_number                 = new_references.inst_phone_number,
        adv_studies_classes               = new_references.adv_studies_classes,
        honors_classes                    = new_references.honors_classes,
        class_size                        = new_references.class_size,
        sec_school_location_id            = new_references.sec_school_location_id,
        percent_plan_higher_edu           = new_references.percent_plan_higher_edu,
        fund_authorization                = new_references.fund_authorization,
    	pe_info_verify_time               = new_references.pe_info_verify_time,
        birth_city                        = new_references.birth_city,
        birth_country                     = new_references.birth_country,
	oss_org_unit_cd			  = new_references.oss_org_unit_cd,
	felony_convicted_flag		  = new_references.felony_convicted_flag,
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
    x_party_id                          IN     NUMBER,
    x_deceased_ind                      IN     VARCHAR2,
    x_archive_exclusion_ind             IN     VARCHAR2,
    x_archive_dt                        IN     DATE,
    x_purge_exclusion_ind               IN     VARCHAR2,
    x_purge_dt                          IN     DATE,
    x_oracle_username                   IN     VARCHAR2,
    x_proof_of_ins                      IN     VARCHAR2,
    x_proof_of_immu                     IN     VARCHAR2,
    x_level_of_qual                     IN     NUMBER,
    x_military_service_reg              IN     VARCHAR2,
    x_veteran                           IN     VARCHAR2,
    x_institution_cd                    IN     VARCHAR2,
    x_oi_local_institution_ind          IN     VARCHAR2,
    x_oi_os_ind                         IN     VARCHAR2,
    x_oi_govt_institution_cd            IN     VARCHAR2,
    x_oi_inst_control_type              IN     VARCHAR2,
    x_oi_institution_type               IN     VARCHAR2,
    x_oi_institution_status             IN     VARCHAR2,
    x_ou_start_dt                       IN     DATE,
    x_ou_end_dt                         IN     DATE,
    x_ou_member_type                    IN     VARCHAR2,
    x_ou_org_status                     IN     VARCHAR2,
    x_ou_org_type                       IN     VARCHAR2,
    x_inst_org_ind                      IN     VARCHAR2,
    x_inst_priority_cd                  IN     VARCHAR2    ,
    x_inst_eps_code                     IN     VARCHAR2    ,
    x_inst_phone_country_code           IN     VARCHAR2    ,
    x_inst_phone_area_code              IN     VARCHAR2    ,
    x_inst_phone_number                 IN     VARCHAR2    ,
    x_adv_studies_classes               IN     NUMBER      ,
    x_honors_classes                    IN     NUMBER      ,
    x_class_size                        IN     NUMBER      ,
    x_sec_school_location_id            IN     NUMBER      ,
    x_percent_plan_higher_edu           IN     NUMBER      ,
    x_fund_authorization                IN     VARCHAR2    ,
    x_pe_info_verify_time		IN     DATE        ,
    x_birth_city                        IN     VARCHAR2    ,
    x_birth_country                     IN     VARCHAR2    ,
    x_oss_org_unit_cd			IN     VARCHAR2,
    x_felony_convicted_flag		IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Sameer.Manglm@oracle.com
  ||  Created On : 28-AUG-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_hz_parties
      WHERE    party_id                          = x_party_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_party_id,
        x_deceased_ind,
        x_archive_exclusion_ind,
        x_archive_dt,
        x_purge_exclusion_ind,
        x_purge_dt,
        x_oracle_username,
        x_proof_of_ins,
        x_proof_of_immu,
        x_level_of_qual,
        x_military_service_reg,
        x_veteran,
        x_institution_cd,
        x_oi_local_institution_ind,
        x_oi_os_ind,
        x_oi_govt_institution_cd,
        x_oi_inst_control_type,
        x_oi_institution_type,
        x_oi_institution_status,
        x_ou_start_dt,
        x_ou_end_dt,
        x_ou_member_type,
        x_ou_org_status,
        x_ou_org_type,
        x_inst_org_ind,
        x_inst_priority_cd,
        x_inst_eps_code ,
        x_inst_phone_country_code,
        x_inst_phone_area_code,
        x_inst_phone_number,
        x_adv_studies_classes,
        x_honors_classes,
        x_class_size,
        x_sec_school_location_id,
        x_percent_plan_higher_edu,
        x_fund_authorization,
        x_pe_info_verify_time,
        x_birth_city   ,
        x_birth_country,
	x_oss_org_unit_cd,
	x_felony_convicted_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_party_id,
      x_deceased_ind,
      x_archive_exclusion_ind,
      x_archive_dt,
      x_purge_exclusion_ind,
      x_purge_dt,
      x_oracle_username,
      x_proof_of_ins,
      x_proof_of_immu,
      x_level_of_qual,
      x_military_service_reg,
      x_veteran,
      x_institution_cd,
      x_oi_local_institution_ind,
      x_oi_os_ind,
      x_oi_govt_institution_cd,
      x_oi_inst_control_type,
      x_oi_institution_type,
      x_oi_institution_status,
      x_ou_start_dt,
      x_ou_end_dt,
      x_ou_member_type,
      x_ou_org_status,
      x_ou_org_type,
      x_inst_org_ind,
      x_inst_priority_cd,
      x_inst_eps_code ,
      x_inst_phone_country_code,
      x_inst_phone_area_code,
      x_inst_phone_number,
      x_adv_studies_classes,
      x_honors_classes,
      x_class_size,
      x_sec_school_location_id,
      x_percent_plan_higher_edu,
      x_fund_authorization,
      x_pe_info_verify_time,
      x_birth_city   ,
      x_birth_country,
      x_oss_org_unit_cd,
      x_felony_convicted_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : Sameer.Manglm@oracle.com
  ||  Created On : 28-AUG-2000
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
 DELETE FROM igs_pe_hz_parties
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

END igs_pe_hz_parties_pkg;

/
