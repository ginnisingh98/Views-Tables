--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERSON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERSON_PKG" AS
/* $Header: IGSNI19B.pls 120.6 2006/01/20 05:42:17 skpandey ship $ */

------------------------------------------------------------------
-- Change History
--
-- Bug ID : 2000408
-- who      when          what
-- CDCRUZ   Sep 24,2002   Modified calls to IGS_PE_ALT_PERS_ID_PKG
--  vrathi  2003/07/11    Bug No:3045079 The sysdate should be truncated before inserting into
--                        IGS_PE_ALT_PERS_ID to eliminate the time component
-- asbala   13-APR-2004   Removed DEFAULT NULL from the parameters of Set_Column_Values procedure
--                        since the parameters of Before_Dml are DEFAULT NULL
------------------------------------------------------------------

  l_rowid VARCHAR2(25);
  old_references igs_pe_person%ROWTYPE;
  new_references igs_pe_person%ROWTYPE;
  v_person_rec   hz_party_v2pub.person_rec_type;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_person_id IN NUMBER,
    x_person_number IN VARCHAR2,
    x_surname IN VARCHAR2,
    x_middle_name IN VARCHAR2,
    x_given_names IN VARCHAR2,
    x_sex IN VARCHAR2,
    x_title IN VARCHAR2,
    x_staff_member_ind IN VARCHAR2,
    x_deceased_ind IN VARCHAR2,
    x_suffix IN VARCHAR2,
    x_pre_name_adjunct IN VARCHAR2,
    x_archive_exclusion_ind IN VARCHAR2,
    x_archive_dt IN DATE,
    x_purge_exclusion_ind IN VARCHAR2,
    x_purge_dt IN DATE,
    x_deceased_date IN DATE,
    x_proof_of_ins IN VARCHAR2,
    x_proof_of_immu IN VARCHAR2,
    x_birth_dt IN DATE,
    x_salutation IN VARCHAR2,
    x_oracle_username IN VARCHAR2,
    x_preferred_given_name IN VARCHAR2,
    x_email_addr IN VARCHAR2,
    x_level_of_qual_id IN NUMBER,
    x_military_service_reg IN VARCHAR2,
    x_veteran IN VARCHAR2,
    x_hz_parties_ovn IN NUMBER,
    x_status IN VARCHAR2,
    x_attribute_category IN VARCHAR2,
    x_attribute1 IN VARCHAR2,
    x_attribute2 IN VARCHAR2,
    x_attribute3 IN VARCHAR2,
    x_attribute4 IN VARCHAR2,
    x_attribute5 IN VARCHAR2,
    x_attribute6 IN VARCHAR2,
    x_attribute7 IN VARCHAR2,
    x_attribute8 IN VARCHAR2,
    x_attribute9 IN VARCHAR2,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_attribute21 IN VARCHAR2 DEFAULT NULL,
    x_attribute22 IN VARCHAR2 DEFAULT NULL,
    x_attribute23 IN VARCHAR2 DEFAULT NULL,
    x_attribute24 IN VARCHAR2 DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		  2000/05/11	  Changed according the new table structure.
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_PERSON
      WHERE    row_id = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;

      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;
    -- Populate New Values.

    -- there are 2 record types in the p_person_rec of HZ_PARTY_PUB, one is party_rec and the other one is person_rec
    -- so while creating a record type this should be very clearly note. SSAWHNEY

    v_person_rec.party_rec.party_id := x_person_id;
    v_person_rec.party_rec.party_number := x_person_number;
    v_person_rec.person_pre_name_adjunct := x_pre_name_adjunct;  -- ssawhney v2 API change
    v_person_rec.person_first_name	:= x_given_names;
    v_person_rec.person_middle_name	:= x_middle_name;
    v_person_rec.person_last_name	:= x_surname;
    v_person_rec.person_name_suffix	:= x_suffix;
    v_person_rec.person_title		:= x_title;

    v_person_rec.known_as	:= x_preferred_given_name;
    v_person_rec.date_of_birth	:= x_birth_dt;
    v_person_rec.date_of_death	:= x_deceased_date;
    v_person_rec.gender 	:= x_sex;

    v_person_rec.party_rec.status := x_status;
    v_person_rec.party_rec.attribute_category := x_attribute_category;
    v_person_rec.party_rec.attribute1 := x_attribute1;
    v_person_rec.party_rec.attribute2 := x_attribute2;
    v_person_rec.party_rec.attribute3 := x_attribute3;
    v_person_rec.party_rec.attribute4 := x_attribute4;
    v_person_rec.party_rec.attribute5 := x_attribute5;
    v_person_rec.party_rec.attribute6 := x_attribute6;
    v_person_rec.party_rec.attribute7 := x_attribute7;
    v_person_rec.party_rec.attribute8 := x_attribute8;
    v_person_rec.party_rec.attribute9 := x_attribute9;
    v_person_rec.party_rec.attribute10 := x_attribute10;
    v_person_rec.party_rec.attribute11 := x_attribute11;
    v_person_rec.party_rec.attribute12 := x_attribute12;
    v_person_rec.party_rec.attribute13 := x_attribute13;
    v_person_rec.party_rec.attribute14 := x_attribute14;
    v_person_rec.party_rec.attribute15 := x_attribute15;
    v_person_rec.party_rec.attribute16 := x_attribute16;
    v_person_rec.party_rec.attribute17 := x_attribute17;
    v_person_rec.party_rec.attribute18 := x_attribute18;
    v_person_rec.party_rec.attribute19 := x_attribute19;
    v_person_rec.party_rec.attribute20 := x_attribute20;
    v_person_rec.party_rec.attribute21 := x_attribute21;
    v_person_rec.party_rec.attribute22 := x_attribute22;
    v_person_rec.party_rec.attribute23 := x_attribute23;
    v_person_rec.party_rec.attribute24 := x_attribute24;

    new_references.person_id := x_person_id;
    new_references.person_number := x_person_number;
    new_references.surname := x_surname;
    new_references.middle_name := x_middle_name;
    new_references.given_names := x_given_names;
    new_references.sex := x_sex;
    new_references.title := x_title;
    new_references.staff_member_ind := x_staff_member_ind;
    new_references.deceased_ind := x_deceased_ind;
    new_references.suffix := x_suffix;
    new_references.pre_name_adjunct := x_pre_name_adjunct;
    new_references.archive_exclusion_ind := x_archive_exclusion_ind;
    new_references.archive_dt := x_archive_dt;
    new_references.purge_exclusion_ind := x_purge_exclusion_ind;
    new_references.purge_dt := x_purge_dt;
    new_references.deceased_date := x_deceased_date;
    new_references.proof_of_ins := x_proof_of_ins;
    new_references.proof_of_immu := x_proof_of_immu;
    new_references.birth_dt := x_birth_dt;
    new_references.salutation := x_salutation;
    new_references.oracle_username := x_oracle_username;
    new_references.preferred_given_name := x_preferred_given_name;
    new_references.email_addr := x_email_addr;
    new_references.level_of_qual_id := x_level_of_qual_id;
    new_references.military_service_reg := x_military_service_reg;
    new_references.veteran := x_veteran;
    new_references.object_version_number := x_hz_parties_ovn;
    new_references.status := x_status;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;
    new_references.attribute21 := x_attribute21;
    new_references.attribute22 := x_attribute22;
    new_references.attribute23 := x_attribute23;
    new_references.attribute24 := x_attribute24;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;

    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
  END Set_Column_Values;


  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   sraj            2000/05/05      the table structure has been changed
   asbala          12-APR-2004     3313276: Validation for gender not done
                                   against igs_lookup_values anymore.
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN

      NULL;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER
    ) RETURN BOOLEAN AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  skpandey        19-JAN-2006     Bug#4937960: Changed chk_igs_pe_hz_party definition to optimize query
   sraj            2000/05/05      the table structure has been changed
   mmkumar         18-Jul-2005     added a new parameter x_oss_org_unit_cd for party_number impact
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid(cp_person_id hz_parties.party_id%TYPE) IS
      SELECT   rowid
      FROM     hz_parties
      WHERE    party_id = cp_person_id;

    lv_rowid cur_rowid%ROWTYPE;

    CURSOR chk_igs_pe_hz_party(cp_person_id hz_parties.party_id%TYPE) is
    SELECT rowid
    FROM igs_pe_hz_parties
    WHERE party_id = cp_person_id;

   pehz_rowid  varchar2(25);

  BEGIN
    OPEN cur_rowid(x_person_id);
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;

      -- check if the person exits in teh IGS_PE_HZ_PARTIES
      OPEN chk_igs_pe_hz_party(x_person_id);
      FETCH chk_igs_pe_hz_party INTO pehz_rowid;

      -- if the person does not exist tehn insert with the minimum required data
      IF (chk_igs_pe_hz_party%NOTFOUND) THEN

        pehz_rowid := null;

	   IGS_PE_HZ_PARTIES_PKG.INSERT_ROW(
		 X_ROWID                        => pehz_rowid,
		 X_PARTY_ID                     => X_PERSON_ID,
		 X_DECEASED_IND                 => NULL,
		 X_ARCHIVE_EXCLUSION_IND        => NULL,
		 X_ARCHIVE_DT                   => NULL,
		 X_PURGE_EXCLUSION_IND          => NULL,
		 X_PURGE_DT                     => NULL,
		 X_ORACLE_USERNAME              => NULL,
		 X_PROOF_OF_INS                 => NULL,
		 X_PROOF_OF_IMMU                => NULL,
		 X_LEVEL_OF_QUAL                => NULL,
		 X_MILITARY_SERVICE_REG         => NULL,
		 X_VETERAN                      => NULL,
		 X_INSTITUTION_CD               => NULL,
		 X_OI_LOCAL_INSTITUTION_IND     => NULL,
		 X_OI_OS_IND                    => NULL,
		 X_OI_GOVT_INSTITUTION_CD       => NULL,
		 X_OI_INST_CONTROL_TYPE         => NULL,
		 X_OI_INSTITUTION_TYPE          => NULL,
		 X_OI_INSTITUTION_STATUS        => NULL,
		 X_OU_START_DT                  => NULL,
		 X_OU_END_DT                    => NULL,
		 X_OU_MEMBER_TYPE               => NULL,
		 X_OU_ORG_STATUS                => NULL,
		 X_OU_ORG_TYPE                  => NULL,
		 X_INST_ORG_IND                 => NULL,
		 X_FUND_AUTHORIZATION   	=> NULL,
		 X_PE_INFO_VERIFY_TIME          => NULL,
		 X_birth_city                   => NULL,
		 X_birth_country                => NULL,
		 x_oss_org_unit_cd              => NULL,  --mmkumar, party_number impact
		 X_felony_convicted_flag	=> NULL,
		 X_MODE				=> 'R'
	       );

      END IF;

      CLOSE chk_igs_pe_hz_party;

      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;
  END Get_PK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_person_id IN NUMBER,
    x_person_number IN VARCHAR2,
    x_surname IN VARCHAR2,
    x_middle_name IN VARCHAR2,
    x_given_names IN VARCHAR2,
    x_sex IN VARCHAR2,
    x_title IN VARCHAR2,
    x_staff_member_ind IN VARCHAR2,
    x_deceased_ind IN VARCHAR2,
    x_suffix IN VARCHAR2,
    x_pre_name_adjunct IN VARCHAR2,
    x_archive_exclusion_ind IN VARCHAR2,
    x_archive_dt IN DATE,
    x_purge_exclusion_ind IN VARCHAR2,
    x_purge_dt IN DATE,
    x_deceased_date IN DATE,
    x_proof_of_ins IN VARCHAR2,
    x_proof_of_immu IN VARCHAR2,
    x_birth_dt IN DATE,
    x_salutation IN VARCHAR2,
    x_oracle_username IN VARCHAR2,
    x_preferred_given_name IN VARCHAR2,
    x_email_addr IN VARCHAR2,
    x_level_of_qual_id IN NUMBER,
    x_military_service_reg IN VARCHAR2,
    x_veteran IN VARCHAR2,
    x_hz_parties_ovn IN NUMBER,
    x_status IN VARCHAR2,
    x_attribute_category IN VARCHAR2,
    x_attribute1 IN VARCHAR2,
    x_attribute2 IN VARCHAR2,
    x_attribute3 IN VARCHAR2,
    x_attribute4 IN VARCHAR2,
    x_attribute5 IN VARCHAR2,
    x_attribute6 IN VARCHAR2,
    x_attribute7 IN VARCHAR2,
    x_attribute8 IN VARCHAR2,
    x_attribute9 IN VARCHAR2,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_attribute21 IN VARCHAR2,
    x_attribute22 IN VARCHAR2,
    x_attribute23 IN VARCHAR2,
    x_attribute24 IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_person_number,
      x_surname,
      x_middle_name,
      x_given_names,
      x_sex,
      x_title,
      x_staff_member_ind,
      x_deceased_ind,
      x_suffix,
      x_pre_name_adjunct,
      x_archive_exclusion_ind,
      x_archive_dt,
      x_purge_exclusion_ind,
      x_purge_dt,
      x_deceased_date,
      x_proof_of_ins,
      x_proof_of_immu,
      x_birth_dt,
      x_salutation,
      x_oracle_username,
      x_preferred_given_name,
      x_email_addr,
      x_level_of_qual_id,
      x_military_service_reg,
      x_veteran,
      x_hz_parties_ovn,
      x_status,
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
      x_attribute21,
      x_attribute22,
      x_attribute23,
      x_attribute24
    );
    --The following validations with Birth Date and Deceased Date have been moved here from plds to aviod duplication of
    --code in IGSAD032, IGSEN022, IGSAD034, and IGSAD045. bug 2389837
    IF (p_action IN ('INSERT','UPDATE')) THEN
     IF(x_birth_dt IS NOT NULL AND x_birth_dt > sysdate) THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_AD_BIRTH_DT');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
     END IF;
     IF(x_deceased_date IS NOT NULL AND x_deceased_date > sysdate) THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_AD_DEC_DT');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
     END IF;
     IF(x_deceased_date IS NOT NULL AND x_birth_dt IS NOT NULL AND x_deceased_date < x_birth_dt) THEN
      Fnd_Message.Set_Name('IGS','IGS_AD_DEC_BIRTH_DT');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
     END IF;
    END IF;
     IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      IF  Get_PK_For_Validation (
          new_references.person_id ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Parent_Existance; -- if procedure present
     ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       Check_Parent_Existance; -- if procedure present
     ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
	 NULL;
     ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
         new_references.person_id  ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
     ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	NULL;
     ELSIF (p_action = 'VALIDATE_DELETE') THEN
	NULL;
     END IF;
  END Before_DML;

 PROCEDURE INSERT_ROW (
       X_MSG_COUNT OUT NOCOPY NUMBER,
       X_MSG_DATA  OUT NOCOPY VARCHAR2,
       X_RETURN_STATUS OUT NOCOPY VARCHAR2,
       X_ROWID IN OUT NOCOPY VARCHAR2,
       x_PERSON_ID IN OUT NOCOPY NUMBER,
       x_PERSON_NUMBER IN OUT NOCOPY VARCHAR2,
       x_SURNAME IN VARCHAR2,
       x_middle_name IN VARCHAR2,
       x_GIVEN_NAMES IN VARCHAR2,
       x_SEX IN VARCHAR2,
       x_TITLE IN VARCHAR2,
       x_STAFF_MEMBER_IND IN VARCHAR2,
       x_DECEASED_IND IN VARCHAR2,
       x_SUFFIX IN VARCHAR2,
       x_pre_name_adjunct IN VARCHAR2,
       x_ARCHIVE_EXCLUSION_IND IN VARCHAR2,
       x_ARCHIVE_DT IN DATE,
       x_PURGE_EXCLUSION_IND IN VARCHAR2,
       x_PURGE_DT IN DATE,
       x_DECEASED_DATE IN DATE,
       x_PROOF_OF_INS IN VARCHAR2,
       x_PROOF_OF_IMMU IN VARCHAR2,
       x_BIRTH_DT IN DATE,
       x_SALUTATION IN VARCHAR2,
       x_ORACLE_USERNAME IN VARCHAR2,
       x_PREFERRED_GIVEN_NAME IN VARCHAR2,
       x_EMAIL_ADDR IN VARCHAR2,
       x_LEVEL_OF_QUAL_ID IN NUMBER,
       x_MILITARY_SERVICE_REG IN VARCHAR2,
       x_VETERAN IN VARCHAR2,
       x_HZ_PARTIES_OVN IN OUT NOCOPY NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_API_PERSON_ID IN VARCHAR2,
       X_STATUS IN VARCHAR2,
       X_MODE IN VARCHAR2,
       x_ATTRIBUTE21 IN VARCHAR2,
       x_ATTRIBUTE22 IN VARCHAR2,
       x_ATTRIBUTE23 IN VARCHAR2,
       x_ATTRIBUTE24 IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   skpandey        19-JAN-2005    Bug#4937960
                                  Changed c_pe_rowid  cursor definition to optimize query
   ssawhney        feb15          customer creation removed. 2225917 SWCR008
   sraj            2000/05/05     the table structure has been changed
   kumma           23-MAY-2002    Added the condition in cursor ptc to fetch
                                  only those record which are not closed., Bug # 2379840
  (reverse chronological order - newest change first)
  ***************************************************************/

     lv_rowid 		VARCHAR2(30);
     lv_rowid1 		VARCHAR2(30);
     ln_type_instance_id IGS_PE_TYP_INSTANCES.TYPE_INSTANCE_ID%TYPE;
     x_profile_id 	 HZ_PERSON_PROFILES.PERSON_PROFILE_ID%TYPE;
     lv_Person_Type_Code IGS_PE_PERSON_TYPES.person_type_code%TYPE;

     CURSOR c_pe_rowid (cp_person_id HZ_PARTIES.PARTY_ID%TYPE) IS
       SELECT ROWID
       FROM HZ_PARTIES
       WHERE party_id = cp_person_id ;

	-- AND  party_number = cp_person_number; -- ssawhney 2203778 this is not required, party no is the primary key.


     CURSOR ptc IS
       SELECT pt.person_type_code
       FROM igs_pe_person_types pt
       WHERE pt.system_type = 'OTHER'
       AND pt.closed_ind = 'N';


       l_tmp_var1          VARCHAR2(2000);
       l_tmp_var          VARCHAR2(2000);



-- Cursor to check if automatic customer numbering is ON/OFF. (tray,18-04-2001)
-- removed from OSS, SWCR008 : 2225917 : ssawhney

       l_person_number   hz_parties.party_number%TYPE ;
       -- new parameter, this is the out NOCOPY parameter from hz_cust_account pub
       -- ssawhney 2203778. HZ F api doesnt return the out NOCOPY parameter person_number
       -- if its already passed. Bug with HZ F
 BEGIN


   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_person_id=>X_PERSON_ID,
 	       x_person_number => X_PERSON_NUMBER,
 	       x_surname=>X_SURNAME,
 	       x_middle_name=>X_middle_name,
 	       x_given_names=>X_GIVEN_NAMES,
 	       x_sex=>X_SEX,
 	       x_title=>X_TITLE,
 	       x_staff_member_ind=>NVL(X_STAFF_MEMBER_IND,'N' ),
 	       x_deceased_ind=>NVL(X_DECEASED_IND,'N' ),
 	       x_suffix=>X_SUFFIX,
 	       x_pre_name_adjunct=>X_pre_name_adjunct,
 	       x_archive_exclusion_ind=>NVL(X_ARCHIVE_EXCLUSION_IND,'N' ),
 	       x_archive_dt=>X_ARCHIVE_DT,
 	       x_purge_exclusion_ind=>NVL(X_PURGE_EXCLUSION_IND,'N' ),
 	       x_purge_dt=>X_PURGE_DT,
 	       x_deceased_date=>X_DECEASED_DATE,
 	       x_proof_of_ins=>X_PROOF_OF_INS,
 	       x_proof_of_immu=>X_PROOF_OF_IMMU,
 	       x_birth_dt=>X_BIRTH_DT,
 	       x_salutation=>X_SALUTATION,
 	       x_oracle_username=>X_ORACLE_USERNAME,
 	       x_preferred_given_name=>X_PREFERRED_GIVEN_NAME,
 	       x_email_addr=>X_EMAIL_ADDR,
 	       x_level_of_qual_id =>X_LEVEL_OF_QUAL_ID,
 	       x_military_service_reg=>X_MILITARY_SERVICE_REG,
 	       x_veteran=>X_VETERAN,
               x_hz_parties_ovn =>x_HZ_PARTIES_OVN,
	       x_status => x_status,
	       x_attribute_category=>X_ATTRIBUTE_CATEGORY,
 	       x_attribute1=>X_ATTRIBUTE1,
 	       x_attribute2=>X_ATTRIBUTE2,
 	       x_attribute3=>X_ATTRIBUTE3,
 	       x_attribute4=>X_ATTRIBUTE4,
 	       x_attribute5=>X_ATTRIBUTE5,
 	       x_attribute6=>X_ATTRIBUTE6,
 	       x_attribute7=>X_ATTRIBUTE7,
 	       x_attribute8=>X_ATTRIBUTE8,
 	       x_attribute9=>X_ATTRIBUTE9,
 	       x_attribute10=>X_ATTRIBUTE10,
 	       x_attribute11=>X_ATTRIBUTE11,
 	       x_attribute12=>X_ATTRIBUTE12,
 	       x_attribute13=>X_ATTRIBUTE13,
 	       x_attribute14=>X_ATTRIBUTE14,
 	       x_attribute15=>X_ATTRIBUTE15,
 	       x_attribute16=>X_ATTRIBUTE16,
 	       x_attribute17=>X_ATTRIBUTE17,
 	       x_attribute18=>X_ATTRIBUTE18,
 	       x_attribute19=>X_ATTRIBUTE19,
 	       x_attribute20=>X_ATTRIBUTE20,
 	       x_attribute21=>X_ATTRIBUTE21,
 	       x_attribute22=>X_ATTRIBUTE22,
 	       x_attribute23=>X_ATTRIBUTE23,
 	       x_attribute24=>X_ATTRIBUTE24
	       );

   -- these 2 new parameters are to be used only in case of INSERT.
      v_person_rec.content_source_type:='USER_ENTERED';
      v_person_rec.created_by_module :='IGS';

  HZ_PARTY_V2PUB.CREATE_PERSON(

	P_PERSON_REC		=>	v_person_rec,
	X_RETURN_STATUS		=>	x_RETURN_STATUS,
	X_MSG_COUNT		=>	x_MSG_COUNT,
	X_MSG_DATA		=>	x_MSG_DATA,
	X_PARTY_ID		=>	x_PERSON_ID,
	X_PARTY_NUMBER		=>	x_PERSON_NUMBER,
	X_PROFILE_ID		=>	x_PROFILE_ID

    );


IF X_RETURN_STATUS  IN ('E','U') THEN
   --code added by sbaliga as part of 2338473
     IF x_msg_count > 1 THEN
        FOR i IN 1..x_msg_count
        LOOP
          l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
        END LOOP;
        x_msg_data := l_tmp_var1;
      END IF;


ELSE


	v_person_rec.party_rec.PARTY_ID := X_PERSON_ID;
	v_person_rec.party_rec.PARTY_number := X_PERSON_number;
    x_HZ_PARTIES_OVN := 1;


-- Code to resolve Design issue for bug#1700178 (tray,18-04-2001)
-- removed that code SSAWHNEY : 2225917
-- If party creation is successful, create records in OSS

	   IGS_PE_HZ_PARTIES_PKG.INSERT_ROW(
		 X_ROWID                        => l_rowid,
		 X_PARTY_ID                     => X_PERSON_ID,
		 X_DECEASED_IND                 => new_references.deceased_ind,
		 X_ARCHIVE_EXCLUSION_IND        => new_references.archive_exclusion_ind,
		 X_ARCHIVE_DT                   => new_references.archive_dt,
		 X_PURGE_EXCLUSION_IND          => new_references.purge_exclusion_ind,
		 X_PURGE_DT                     => new_references.purge_dt,
		 X_ORACLE_USERNAME              => new_references.oracle_username,
		 X_PROOF_OF_INS                 => new_references.proof_of_ins,
		 X_PROOF_OF_IMMU                => new_references.proof_of_immu,
		 X_LEVEL_OF_QUAL                => new_references.level_of_qual_id,
		 X_MILITARY_SERVICE_REG         => new_references.military_service_reg,
		 X_VETERAN                      => new_references.veteran,
		 X_INSTITUTION_CD               => NULL,
		 X_OI_LOCAL_INSTITUTION_IND     => NULL,
		 X_OI_OS_IND                    => NULL,
		 X_OI_GOVT_INSTITUTION_CD       => NULL,
		 X_OI_INST_CONTROL_TYPE         => NULL,
		 X_OI_INSTITUTION_TYPE          => NULL,
		 X_OI_INSTITUTION_STATUS        => NULL,
		 X_OU_START_DT                  => NULL,
		 X_OU_END_DT                    => NULL,
		 X_OU_MEMBER_TYPE               => NULL,
		 X_OU_ORG_STATUS                => NULL,
		 X_OU_ORG_TYPE                  => NULL,
		 X_INST_ORG_IND                 => NULL,
 		 X_FUND_AUTHORIZATION		=> NULL,
	         X_PE_INFO_VERIFY_TIME          => NULL,
	         X_birth_city                   => NULL,
	         X_birth_country                => NULL,
		 x_oss_org_unit_cd              => NULL,  --mmkumar, party_number impact
 		 X_felony_convicted_flag	=> NULL,
		 X_MODE				=> X_MODE -- gmaheswa Security
	       );


            IF x_api_person_id IS NOT NULL AND x_person_id_type IS NOT NULL THEN
		 IGS_PE_ALT_PERS_ID_PKG.INSERT_ROW (
		    X_ROWID => lv_rowid,
		    X_PE_PERSON_ID  => X_PERSON_ID,
		    X_API_PERSON_ID => x_api_person_id,
		    X_PERSON_ID_TYPE  => x_person_id_type,
		    X_START_DT   => trunc(SYSDATE),
		    X_END_DT => NULL,
                    X_ATTRIBUTE_CATEGORY => NULL,
                    X_ATTRIBUTE1         => NULL,
                    X_ATTRIBUTE2         => NULL,
                    X_ATTRIBUTE3         => NULL,
                    X_ATTRIBUTE4         => NULL,
                    X_ATTRIBUTE5         => NULL,
                    X_ATTRIBUTE6         => NULL,
                    X_ATTRIBUTE7         => NULL,
                    X_ATTRIBUTE8         => NULL,
                    X_ATTRIBUTE9         => NULL,
                    X_ATTRIBUTE10        => NULL,
                    X_ATTRIBUTE11        => NULL,
                    X_ATTRIBUTE12        => NULL,
                    X_ATTRIBUTE13        => NULL,
                    X_ATTRIBUTE14        => NULL,
                    X_ATTRIBUTE15        => NULL,
                    X_ATTRIBUTE16        => NULL,
                    X_ATTRIBUTE17        => NULL,
                    X_ATTRIBUTE18        => NULL,
                    X_ATTRIBUTE19        => NULL,
                    X_ATTRIBUTE20        => NULL,
		    X_REGION_CD          => NULL,
		    X_MODE =>  'R'
		    );
	     END IF;

	  FOR ptc1 IN ptc LOOP
	    lv_Person_Type_Code := ptc1.person_type_code;
	  END LOOP;

          Igs_Pe_Typ_Instances_Pkg.INSERT_ROW (
		 X_ROWID => lv_rowid1,
		 x_PERSON_ID  => X_PERSON_ID,-- new_references.PERSON_ID,
		 x_COURSE_CD => NULL,
		 x_TYPE_INSTANCE_ID => ln_TYPE_INSTANCE_ID,
		 x_PERSON_TYPE_CODE  => lv_Person_Type_Code,
		 x_CC_VERSION_NUMBER => NULL,
		 x_FUNNEL_STATUS => NULL,
		 x_ADMISSION_APPL_NUMBER   => NULL,
		 x_NOMINATED_COURSE_CD   => NULL,
		 x_NCC_VERSION_NUMBER    => NULL,
		 x_SEQUENCE_NUMBER => NULL,
		 x_START_DATE  => SYSDATE,
		 x_END_DATE => NULL,
		 x_CREATE_METHOD  => 'PERSON_CREATED' ,
		 x_ENDED_BY => NULL,
		 x_END_METHOD => NULL,
		 X_ORG_ID => FND_PROFILE.VALUE('ORG_ID'),
		 X_MODE =>  'R',
                 X_EMPLMNT_CATEGORY_CODE => null
	      );

	   OPEN c_pe_rowid (X_PERSON_ID);
	   FETCH c_pe_rowid INTO X_ROWID;
           IF c_pe_rowid%NOTFOUND THEN
	     CLOSE c_pe_rowid;
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	   END IF;
	   CLOSE c_pe_rowid;

     END IF;

  END INSERT_ROW;

 PROCEDURE UPDATE_ROW (
       X_LAST_UPDATE_DATE IN OUT NOCOPY DATE,
       X_MSG_COUNT OUT NOCOPY NUMBER,
       X_MSG_DATA  OUT NOCOPY VARCHAR2,
       X_RETURN_STATUS OUT NOCOPY VARCHAR2,
       X_ROWID IN VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_PERSON_NUMBER IN OUT NOCOPY VARCHAR2,
       x_SURNAME IN VARCHAR2,
       x_middle_name IN VARCHAR2,
       x_GIVEN_NAMES IN VARCHAR2,
       x_SEX IN VARCHAR2,
       x_TITLE IN VARCHAR2,
       x_STAFF_MEMBER_IND IN VARCHAR2,
       x_DECEASED_IND IN VARCHAR2,
       x_SUFFIX IN VARCHAR2,
       x_pre_name_adjunct IN VARCHAR2,
       x_ARCHIVE_EXCLUSION_IND IN VARCHAR2,
       x_ARCHIVE_DT IN DATE,
       x_PURGE_EXCLUSION_IND IN VARCHAR2,
       x_PURGE_DT IN DATE,
       x_DECEASED_DATE IN DATE,
       x_PROOF_OF_INS IN VARCHAR2,
       x_PROOF_OF_IMMU IN VARCHAR2,
       x_BIRTH_DT IN DATE,
       x_SALUTATION IN VARCHAR2,
       x_ORACLE_USERNAME IN VARCHAR2,
       x_PREFERRED_GIVEN_NAME IN VARCHAR2,
       x_EMAIL_ADDR IN VARCHAR2,
       x_LEVEL_OF_QUAL_ID IN NUMBER,
       x_MILITARY_SERVICE_REG IN VARCHAR2,
       x_VETERAN IN VARCHAR2,
       x_HZ_PARTIES_OVN IN OUT NOCOPY NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_API_PERSON_ID IN VARCHAR2,
       X_STATUS IN VARCHAR2,
       X_MODE IN VARCHAR2,
       x_ATTRIBUTE21 IN VARCHAR2,
       x_ATTRIBUTE22 IN VARCHAR2,
       x_ATTRIBUTE23 IN VARCHAR2,
       x_ATTRIBUTE24 IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   sraj            2000/05/05      the table structure has been changed
   vrathi          2003/07/11      Bug No:3045079 The sysdate should be truncated before inserting into
                                   IGS_PE_ALT_PERS_ID to eliminate the time component
  (reverse chronological order - newest change first)
  ***************************************************************/
     x_profile_id 	 HZ_PERSON_PROFILES.PERSON_PROFILE_ID%TYPE;

     lv_rowid VARCHAR2(25);

     CURSOR c1 IS
     SELECT P_ID.ROWID,P_ID.*
     FROM IGS_PE_ALT_PERS_ID P_ID
     WHERE pe_person_id = x_person_id AND
     person_id_type = x_person_id_type AND
     sysdate between start_dt AND NVL(end_dt, sysdate);

     tlinfo c1%ROWTYPE;

     CURSOR c2 IS
     SELECT pehz.ROWID, pehz.*
     FROM IGS_PE_HZ_PARTIES pehz
     WHERE party_id =  x_person_id;

     tlinfo2 c2%ROWTYPE;
     l_tmp_var1          VARCHAR2(2000);
     l_tmp_var          VARCHAR2(2000);

 BEGIN
   Before_DML(
 	       p_action=>'UPDATE',
 	       x_rowid=>X_ROWID,
 	       x_person_id=>X_PERSON_ID,
 	       x_person_number =>X_PERSON_NUMBER,
 	       x_surname=>X_SURNAME,
 	       x_middle_name=>X_middle_name,
 	       x_given_names=>X_GIVEN_NAMES,
 	       x_sex=>X_SEX,
 	       x_title=>X_TITLE,
 	       x_staff_member_ind=>NVL(X_STAFF_MEMBER_IND,'N' ),
 	       x_deceased_ind=>NVL(X_DECEASED_IND,'N' ),
 	       x_suffix=>X_SUFFIX,
 	       x_pre_name_adjunct=>X_pre_name_adjunct,
 	       x_archive_exclusion_ind=>NVL(X_ARCHIVE_EXCLUSION_IND,'N' ),
 	       x_archive_dt=>X_ARCHIVE_DT,
 	       x_purge_exclusion_ind=>NVL(X_PURGE_EXCLUSION_IND,'N' ),
 	       x_purge_dt=>X_PURGE_DT,
 	       x_deceased_date=>X_DECEASED_DATE,
 	       x_proof_of_ins=>X_PROOF_OF_INS,
 	       x_proof_of_immu=>X_PROOF_OF_IMMU,
 	       x_birth_dt=>X_BIRTH_DT,
 	       x_salutation=>X_SALUTATION,
 	       x_oracle_username=>X_ORACLE_USERNAME,
 	       x_preferred_given_name=>X_PREFERRED_GIVEN_NAME,
 	       x_email_addr=>X_EMAIL_ADDR,
 	       x_level_of_qual_id =>X_LEVEL_OF_QUAL_ID,
 	       x_military_service_reg=>X_MILITARY_SERVICE_REG,
 	       x_veteran=>X_VETERAN,
               x_hz_parties_ovn =>x_HZ_PARTIES_OVN,
	       x_status => x_status,
 	       x_attribute_category=>NVL(X_ATTRIBUTE_CATEGORY,FND_API.G_MISS_CHAR),
 	       x_attribute1=>NVL(X_ATTRIBUTE1,FND_API.G_MISS_CHAR),
 	       x_attribute2=>NVL(X_ATTRIBUTE2,FND_API.G_MISS_CHAR),
 	       x_attribute3=>NVL(X_ATTRIBUTE3,FND_API.G_MISS_CHAR),
 	       x_attribute4=>NVL(X_ATTRIBUTE4,FND_API.G_MISS_CHAR),
 	       x_attribute5=>NVL(X_ATTRIBUTE5,FND_API.G_MISS_CHAR),
 	       x_attribute6=>NVL(X_ATTRIBUTE6,FND_API.G_MISS_CHAR),
 	       x_attribute7=>NVL(X_ATTRIBUTE7,FND_API.G_MISS_CHAR),
 	       x_attribute8=>NVL(X_ATTRIBUTE8,FND_API.G_MISS_CHAR),
 	       x_attribute9=>NVL(X_ATTRIBUTE9,FND_API.G_MISS_CHAR),
 	       x_attribute10=>NVL(X_ATTRIBUTE10,FND_API.G_MISS_CHAR),
 	       x_attribute11=>NVL(X_ATTRIBUTE11,FND_API.G_MISS_CHAR),
 	       x_attribute12=>NVL(X_ATTRIBUTE12,FND_API.G_MISS_CHAR),
 	       x_attribute13=>NVL(X_ATTRIBUTE13,FND_API.G_MISS_CHAR),
 	       x_attribute14=>NVL(X_ATTRIBUTE14,FND_API.G_MISS_CHAR),
 	       x_attribute15=>NVL(X_ATTRIBUTE15,FND_API.G_MISS_CHAR),
 	       x_attribute16=>NVL(X_ATTRIBUTE16,FND_API.G_MISS_CHAR),
 	       x_attribute17=>NVL(X_ATTRIBUTE17,FND_API.G_MISS_CHAR),
 	       x_attribute18=>NVL(X_ATTRIBUTE18,FND_API.G_MISS_CHAR),
 	       x_attribute19=>NVL(X_ATTRIBUTE19,FND_API.G_MISS_CHAR),
 	       x_attribute20=>NVL(X_ATTRIBUTE20,FND_API.G_MISS_CHAR),
 	       x_attribute21=>NVL(X_ATTRIBUTE21,FND_API.G_MISS_CHAR),
 	       x_attribute22=>NVL(X_ATTRIBUTE22,FND_API.G_MISS_CHAR),
 	       x_attribute23=>NVL(X_ATTRIBUTE23,FND_API.G_MISS_CHAR),
 	       x_attribute24=>NVL(X_ATTRIBUTE24,FND_API.G_MISS_CHAR)
	     );


      -- explicity the record variables are assigned here and not in Before DML, as there were
      -- validations getting fired after before DML due to initialization of variables.

      v_person_rec.person_pre_name_adjunct := NVL(x_pre_name_adjunct,FND_API.G_MISS_CHAR);
      v_person_rec.person_first_name	   := NVL(x_given_names,FND_API.G_MISS_CHAR);
      v_person_rec.person_middle_name	   := NVL(x_middle_name,FND_API.G_MISS_CHAR);
      v_person_rec.person_last_name	   := NVL(x_surname,FND_API.G_MISS_CHAR);
      v_person_rec.person_name_suffix	   := NVL(x_suffix,FND_API.G_MISS_CHAR);
      v_person_rec.person_title		   := NVL(x_title,FND_API.G_MISS_CHAR);
      v_person_rec.known_as	           := NVL(x_preferred_given_name,FND_API.G_MISS_CHAR);
      v_person_rec.date_of_birth	   := NVL(x_birth_dt,FND_API.G_MISS_DATE);
      v_person_rec.date_of_death	   := NVL(x_deceased_date,FND_API.G_MISS_DATE);
      v_person_rec.gender 	           := NVL(x_sex,FND_API.G_MISS_CHAR);


      HZ_PARTY_V2PUB.UPDATE_PERSON (
	p_party_object_version_number  => x_hz_parties_ovn,
	p_person_rec		 => v_person_rec,
	x_profile_id             => x_profile_id,
	x_return_status		 =>x_return_status,
	x_msg_count		 => x_msg_count,
	x_msg_data		 => x_msg_data
          );



    IF X_RETURN_STATUS  IN ('E','U') THEN
       --code added by sbaliga as part of 2338473
      IF x_msg_count > 1 THEN
        FOR i IN 1..x_msg_count
        LOOP
          l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
        END LOOP;
        x_msg_data := l_tmp_var1;
      END IF;
    ELSE

	  OPEN c2;
	  FETCH c2 INTO tlinfo2;

	  IF c2%FOUND THEN

	       IGS_PE_HZ_PARTIES_PKG.UPDATE_ROW(
		 X_ROWID                        => tlinfo2.ROWID,
		 X_PARTY_ID                     => X_PERSON_ID,
		 X_DECEASED_IND                 => new_references.deceased_ind,
		 X_ARCHIVE_EXCLUSION_IND        => new_references.archive_exclusion_ind,
		 X_ARCHIVE_DT                   => new_references.archive_dt,
		 X_PURGE_EXCLUSION_IND          => new_references.purge_exclusion_ind,
		 X_PURGE_DT                     => new_references.purge_dt,
		 X_ORACLE_USERNAME              => new_references.oracle_username,
		 X_PROOF_OF_INS                 => new_references.proof_of_ins,
		 X_PROOF_OF_IMMU                => new_references.proof_of_immu,
		 X_LEVEL_OF_QUAL                => new_references.level_of_qual_id,
		 X_MILITARY_SERVICE_REG         => new_references.military_service_reg,
		 X_VETERAN                      => new_references.VETERAN,
		 X_INSTITUTION_CD               => tlinfo2.INSTITUTION_CD,
		 X_OI_LOCAL_INSTITUTION_IND     => tlinfo2.OI_LOCAL_INSTITUTION_IND,
		 X_OI_OS_IND                    => tlinfo2.OI_OS_IND,
		 X_OI_GOVT_INSTITUTION_CD       => tlinfo2.OI_GOVT_INSTITUTION_CD,
		 X_OI_INST_CONTROL_TYPE         => tlinfo2.OI_INST_CONTROL_TYPE,
		 X_OI_INSTITUTION_TYPE          => tlinfo2.OI_INSTITUTION_TYPE,
		 X_OI_INSTITUTION_STATUS        => tlinfo2.OI_INSTITUTION_STATUS,
		 X_OU_START_DT                  => tlinfo2.OU_START_DT,
		 X_OU_END_DT                    => tlinfo2.OU_END_DT,
		 X_OU_MEMBER_TYPE               => tlinfo2.OU_MEMBER_TYPE,
		 X_OU_ORG_STATUS                => tlinfo2.OU_ORG_STATUS,
		 X_OU_ORG_TYPE                  => tlinfo2.OU_ORG_TYPE,
		 X_INST_ORG_IND			=> tlinfo2.INST_ORG_IND,
 		 X_FUND_AUTHORIZATION		=> tlinfo2.FUND_AUTHORIZATION,
		 X_PE_INFO_VERIFY_TIME          => tlinfo2.PE_INFO_VERIFY_TIME,
		 X_birth_city                   => tlinfo2.birth_city,
		 X_birth_country                => tlinfo2.birth_country,
		 x_oss_org_unit_cd              => tlinfo2.oss_org_unit_cd,          --mmkumar, party_number impact
		 X_felony_convicted_flag	=> tlinfo2.felony_convicted_flag,
		 X_MODE			        => x_mode -- gmaheswa Security
		);
	END IF;
	CLOSE c2;

	IF x_api_person_id IS NOT NULL AND x_person_id_type IS NOT NULL THEN
	     OPEN c1; FETCH c1 INTO tlinfo;
	     IF c1%NOTFOUND THEN
	        CLOSE c1;
		IGS_PE_ALT_PERS_ID_PKG.INSERT_ROW (
		    X_ROWID => lv_rowid,
		    X_PE_PERSON_ID  => new_references.person_id ,
		    X_API_PERSON_ID => x_api_person_id,
		    X_PERSON_ID_TYPE  => x_person_id_type,
		    X_START_DT   => TRUNC(SYSDATE),
		    X_END_DT => NULL,
                    X_ATTRIBUTE_CATEGORY => NULL,
                    X_ATTRIBUTE1         => NULL,
                    X_ATTRIBUTE2         => NULL,
                    X_ATTRIBUTE3         => NULL,
                    X_ATTRIBUTE4         => NULL,
                    X_ATTRIBUTE5         => NULL,
                    X_ATTRIBUTE6         => NULL,
                    X_ATTRIBUTE7         => NULL,
                    X_ATTRIBUTE8         => NULL,
                    X_ATTRIBUTE9         => NULL,
                    X_ATTRIBUTE10        => NULL,
                    X_ATTRIBUTE11        => NULL,
                    X_ATTRIBUTE12        => NULL,
                    X_ATTRIBUTE13        => NULL,
                    X_ATTRIBUTE14        => NULL,
                    X_ATTRIBUTE15        => NULL,
                    X_ATTRIBUTE16        => NULL,
                    X_ATTRIBUTE17        => NULL,
                    X_ATTRIBUTE18        => NULL,
                    X_ATTRIBUTE19        => NULL,
                    X_ATTRIBUTE20        => NULL,
                    X_REGION_CD          => NULL,
	            X_MODE =>  'R'
		  );
	     END IF;
       END IF;

    END IF;
END UPDATE_ROW;

END Igs_Pe_Person_Pkg;

/
