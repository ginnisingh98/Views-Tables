--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_002" AS
/* $Header: IGSAD80B.pls 120.21 2006/06/23 05:50:10 gmaheswa ship $ */

cst_mi_val_18 CONSTANT  VARCHAR2(2) := '18';
cst_mi_val_19 CONSTANT  VARCHAR2(2) := '19';
cst_mi_val_20 CONSTANT  VARCHAR2(2) := '20';
cst_mi_val_23 CONSTANT  VARCHAR2(2) := '23';

cst_stat_val_1 CONSTANT  VARCHAR2(2) := '1';
cst_stat_val_3 CONSTANT  VARCHAR2(2) := '3';

PROCEDURE validate_oss_ext_attr(p_person_rec IN igs_ad_interface_dtl_dscp_v%ROWTYPE,
                                p_person_id  IN NUMBER,
                                p_validation_success OUT NOCOPY VARCHAR2)
IS
/*
  ||  Created By : pkpatel
  ||  Created On : 24-JUL-2003
  ||  Change History :
  ||  Who             When            What
*/

     -- Cursor to check veteran
  CURSOR level_of_qual_cur(cp_class igs_ad_code_classes.class%TYPE,
                            cp_code_id igs_ad_code_classes.code_id%TYPE,
                            cp_closed_ind igs_ad_code_classes.closed_ind%TYPE)IS
    SELECT 'X'
    FROM  igs_ad_code_classes
    WHERE class = cp_class
      AND code_id = cp_code_id
      AND closed_ind = cp_closed_ind;

  l_var  VARCHAR2(1);
  validation_failed  EXCEPTION;
  l_error_code  VARCHAR2(30);
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_felony_validation VARCHAR2(30);

BEGIN

    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_prog_label := 'igs.plsql.igs_ad_imp_002.validate_oss_ext_attr';
    l_label := 'igs.plsql.igs_ad_imp_002.validate_oss_ext_attr.';

  IF  p_person_rec.PROOF_OF_INS  NOT IN ('Y','N') THEN
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E273','IGS_AD_INTERFACE_ALL');
    END IF;
    l_error_code := 'E273';
    RAISE validation_failed;
  END IF;

  IF  p_person_rec.PROOF_OF_IMMU  NOT IN ('Y','N') THEN
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E274','IGS_AD_INTERFACE_ALL');
    END IF;
    l_error_code := 'E274';
    RAISE validation_failed;
  END IF;

  IF  p_person_rec.MILITARY_SERVICE_REG  NOT IN ('Y','N') THEN
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E275','IGS_AD_INTERFACE_ALL');
    END IF;
    l_error_code := 'E275';
    RAISE validation_failed;
  END IF;

  IF p_person_rec.level_of_qual_id IS NOT NULL THEN
    OPEN level_of_qual_cur('LEVEL_OF_QUAL',p_person_rec.level_of_qual_id,'N');
    FETCH level_of_qual_cur INTO l_var;
    IF level_of_qual_cur%NOTFOUND THEN
      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E276','IGS_AD_INTERFACE_ALL');
      END IF;

      CLOSE level_of_qual_cur;
      l_error_code := 'E276';
      RAISE validation_failed;
    END IF;
    CLOSE level_of_qual_cur;
  END IF;

  IF p_person_rec.birth_country IS NOT NULL THEN
    IF NOT
    (igs_pe_pers_imp_001.validate_country_code(p_person_rec.birth_country))   -- change for country code inconsistency bug 3738488
    THEN
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E576','IGS_AD_INTERFACE_ALL');
    END IF;
    l_error_code := 'E576';
    RAISE validation_failed;
  END IF;
  END IF;

  IF p_person_rec.veteran IS NOT NULL THEN
    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('VETERAN_STATUS',p_person_rec.veteran,8405))
    THEN
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E174','IGS_AD_INTERFACE_ALL');
    END IF;
      l_error_code := 'E174';
      RAISE validation_failed;
    END IF;
  END IF;
  IF  (p_person_rec.felony_convicted_flag  NOT IN ('Y','N',FND_API.G_MISS_CHAR)
                AND p_person_rec.felony_convicted_flag IS NOT NULL ) THEN
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E164','IGS_AD_INTERFACE_ALL');
    END IF;
    l_error_code := 'E164';
    RAISE validation_failed;
  END IF;

  IF p_person_rec.felony_convicted_flag IS NOT NULL THEN

    IF P_Person_Rec.felony_convicted_flag = FND_API.G_MISS_CHAR THEN
       l_felony_validation := igs_pe_gen_004.validate_felony(p_person_id,NULL);
    ELSE
      l_felony_validation := igs_pe_gen_004.validate_felony(p_person_id,P_Person_Rec.felony_convicted_flag);
    END IF;

    IF l_felony_validation IS NOT NULL THEN
        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E165','IGS_AD_INTERFACE_ALL');
        END IF;
        l_error_code := 'E165';
        RAISE validation_failed;
    END IF;
  END IF;

  p_validation_success := 'Y';

  EXCEPTION
    WHEN validation_failed THEN

      p_validation_success := 'N';

      UPDATE igs_ad_interface_all
      SET    ERROR_CODE = l_error_code,
             status       = '3'
      WHERE  interface_id = p_person_rec.interface_id;

END validate_oss_ext_attr;


PROCEDURE CREATE_PERSON(P_person_rec IN IGS_AD_INTERFACE_DTL_DSCP_V%ROWTYPE,
                         P_ADDR_TYPE  IN VARCHAR2,
                         P_PERSON_ID_TYPE IN VARCHAR2,
                         P_PERSON_ID OUT NOCOPY IGS_PE_PERSON.PERSON_ID%TYPE) AS
        /*
          ||  Created By : nsinha
          ||  Created On : 22-JUN-2001
          ||  Purpose : This procedure process the Application
          ||  Known limitations, enhancements or remarks :
          ||  Change History :
          ||  Who             When           What
          ||  skpandey        21-SEP-2005    Bug: 3663505
          ||                                 Description: Added ATTRIBUTES 21 TO 24 to store additional information
          ||  pkpatel       25-DEC-2002      Bug No: 2702536
          ||                                 Added commit after the processing each person record.
          ||  asbala        12-APR-2004      3313276: Use lookup_type HZ_GENDER to validate Gender
          ||  mmkumar       19-JUL-2005      party number impact , passed NULL for x_oss_org_unit_cd in uupdate_row
          ||  (reverse chronological order - newest change first)
        */

  L_MISS_person_rec       HZ_PARTY_V2PUB.person_rec_TYPE;

  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_message_name  VARCHAR2(30);
  l_app           VARCHAR2(50);

  CURSOR STAT_cur (lnInterfaceID NUMBER) IS
    SELECT SI.*
    FROM IGS_AD_STAT_INT_all SI, IGS_AD_INTERFACE_all I
    WHERE si.interface_id = lnInterfaceID
      AND I.INTERFACE_ID = SI.INTERFACE_ID
      AND SI.STATUS = '2'
      AND I.STATUS IN ('1','4');  --4035277, if address errors out, it sets status =4 for ad_interface
                                  -- furture processing should happen..so always check for 1,4 in ad_interface


  stat_rec stat_cur%ROWTYPE;
  l_statistice_id NUMBER;
  l_error_code  VARCHAR2(100);


  CURSOR addr_cur(cp_interface_id igs_ad_interface_all.interface_id%TYPE) IS
    SELECT ai.*
    FROM   igs_ad_addr_int_all ai,
           igs_ad_interface_all i
    WHERE  ai.interface_id = cp_interface_id
      AND    ai.status  = '2'
      AND     i.interface_id = ai.interface_id
      AND     i.status IN ('1','4'); --4035277, if address errors out, it sets status =4 for ad_interface
                                     --furture processing should happen..so always check for 1,4 in ad_interface


  addr_rec ADDR_cur%ROWTYPE;

  CURSOR  API_cur ( cp_interface_id igs_ad_interface_all.interface_id%TYPE) IS
    SELECT  api.*
    FROM    igs_ad_api_int_all api,
            igs_ad_interface_all ai
    WHERE   api.interface_id = cp_interface_id
      AND     api.status = '2'
      AND     api.interface_id = ai.interface_id
      AND     ai.status IN ('1','4');  --4035277, if address errors out, it sets status =4 for ad_interface
                                       -- furture processing should happen..so always check for 1,4 in ad_interface

 -- Cursor to get format mask to validate person alternate id.
  CURSOR api_type_cur(cp_person_id_type igs_pe_person_id_typ.person_id_type%TYPE) IS
    SELECT format_mask
    FROM   igs_pe_person_id_typ
    WHERE  person_id_type = cp_person_id_type;

  api_type_rec  api_type_cur%ROWTYPE;
  api_rec api_cur%ROWTYPE;


        /* Following cursor is added as a fix for bug number 2333026 */
  CURSOR c_pref_alt_id_type IS
    SELECT PERSON_ID_TYPE
    FROM  IGS_PE_PERSON_ID_TYP
    WHERE PREFERRED_IND  ='Y';

  CURSOR pe_hz_parties_cur(cp_person_id igs_pe_hz_parties.party_id%TYPE) IS
    SELECT pehz.ROWID, pehz.*
    FROM IGS_PE_HZ_PARTIES pehz
    WHERE party_id =  cp_person_id;

  l_pref_altid_type IGS_PE_PERSON_ID_TYP.PERSON_ID_TYPE%TYPE;
  l_pref_altid p_person_rec.PREF_ALTERNATE_ID%TYPE;
  tlinfo2 pe_hz_parties_cur%ROWTYPE;
  l_rowid VARCHAR2(25);
  l_person_id  IGS_PE_PERSON.PERSON_ID%TYPE;
  l_person_number VARCHAR2(30);
  l_PrefPersonIDType IGS_PE_PERSON_ID_TYP.PERSON_ID_TYPE%TYPE;
  l_statistics_id NUMBER;
  l_Return_Status VARCHAR2(1);
  l_Status                VARCHAR2(1);
  l_Msg_Data      VARCHAR2(4000);
  l_Party_Id      NUMBER;
  l_Party_Number  VARCHAR2(100);
  l_Profile_Id    NUMBER;
  l_Msg_Count     NUMBER;
  l_Count              NUMBER;
  lnDupExist      NUMBER;
  l_location_id   NUMBER;
  l_party_last_update_date        DATE;
  l_person_profile_id             NUMBER;
  l_generate_party_number         VARCHAR2(1);
  l_var        VARCHAR2(1);
  l_object_version_number NUMBER;
  l_oss_ext_attr_val  VARCHAR2(1);
  l_preferred_given_name igs_ad_interface_all.PREFERRED_GIVEN_NAME%TYPE;
  l_felony_convicted_flag VARCHAR2(1);
BEGIN
    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_prog_label := 'igs.plsql.igs_ad_imp_002.create_person';
    l_label := 'igs.plsql.igs_ad_imp_002.create_person.';
    l_rowid := '';
    l_oss_ext_attr_val := 'Y';

    -- Call Log header
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_002.create_person.begin';
    l_debug_str := 'Interface Id : ' || P_person_rec.INTERFACE_ID;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  SAVEPOINT before_insert;
  BEGIN
               -- Validate the title
    IF P_Person_Rec.pre_name_adjunct IS NOT NULL THEN
      IF NOT
      (igs_pe_pers_imp_001.validate_lookup_type_code('CONTACT_TITLE',P_Person_Rec.pre_name_adjunct,222))
      THEN
        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_id,'E201','IGS_AD_INTERFACE_ALL');
        END IF;
        UPDATE IGS_AD_INTERFACE_ALL
        SET ERROR_CODE = 'E201',
            STATUS       = '3'
        WHERE INTERFACE_ID = P_Person_Rec.Interface_Id;
        RETURN;
      END IF;
    END IF;

                -- Validate Sex.
    IF P_Person_Rec.sex IS NOT NULL THEN
      IF NOT
      (igs_pe_pers_imp_001.validate_lookup_type_code('HZ_GENDER',P_Person_Rec.sex,222))
      THEN
        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E202','IGS_AD_INTERFACE_ALL');
        END IF;

        UPDATE IGS_AD_INTERFACE_ALL
        SET ERROR_CODE = 'E202',
            STATUS       = '3'
        WHERE INTERFACE_ID = P_Person_Rec.Interface_Id;
        RETURN;
      END IF;
    END IF;
                -- Validate birth_dt
    IF (((P_Person_Rec.birth_dt IS NOT NULL) AND (P_Person_Rec.birth_dt > SYSDATE))  )  THEN
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E203','IGS_AD_INTERFACE_ALL');
    END IF;
      UPDATE IGS_AD_INTERFACE_ALL
      SET ERROR_CODE = 'E203',
          STATUS       = '3'
      WHERE INTERFACE_ID = P_Person_Rec.Interface_Id;
      RETURN;
    END IF;


    l_generate_party_number := fnd_profile.VALUE('HZ_GENERATE_PARTY_NUMBER');
    IF (l_generate_party_number = 'N') THEN
      IF (p_person_rec.person_number IS NULL) THEN
        UPDATE IGS_AD_INTERFACE_all
        SET STATUS = '3' ,
            ERROR_CODE = 'E204'
        WHERE INTERFACE_ID = P_person_rec.INTERFACE_ID;
        P_PERSON_ID := NULL;
        IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E204','IGS_AD_INTERFACE_ALL');
        END IF;
        RETURN;
      ELSE
        l_person_number := p_person_rec.person_number;
      END IF;
    END IF;

    IF p_person_rec.pref_alternate_id IS NOT NULL THEN
            -- Added as a fix for Bug Number 2333026
      OPEN c_pref_alt_id_type;
      FETCH c_pref_alt_id_type INTO l_pref_altid_type;
      IF (c_pref_alt_id_type%NOTFOUND) THEN
        l_pref_altid_type := NULL;
        l_pref_altid := NULL;

               -- (pathipat) For Bug: 2485638
        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E285','IGS_AD_INTERFACE_ALL');
        END IF;

        UPDATE IGS_AD_INTERFACE_ALL
        SET   ERROR_CODE = 'E285', STATUS       = '3'
        WHERE INTERFACE_ID = P_Person_Rec.Interface_Id;
        CLOSE c_pref_alt_id_type;
        RETURN;

      ELSE
                           --validate Person ID type
        OPEN  api_type_cur(l_pref_altid_type);
        FETCH api_type_cur INTO api_type_rec;
        CLOSE api_type_cur;

            -- Validate the format mask
        IF api_type_rec.format_mask IS NOT NULL THEN
          IF NOT igs_en_val_api.fm_equal(p_person_rec.PREF_ALTERNATE_ID,api_type_rec.format_mask) THEN
        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E268','IGS_AD_INTERFACE_ALL');
        END IF;

            UPDATE IGS_AD_INTERFACE_ALL
            SET ERROR_CODE = 'E268',
                STATUS       = '3'
            WHERE INTERFACE_ID = P_Person_Rec.Interface_Id;
            CLOSE c_pref_alt_id_type;
            RETURN;
          END IF;
        END IF;
        l_pref_altid := p_person_rec.PREF_ALTERNATE_ID;

      END IF;
      CLOSE c_pref_alt_id_type;
    ELSE
      l_pref_altid_type := NULL;
      l_pref_altid := NULL;
    END IF;

        -- Validate the OSS extensible attributes
    validate_oss_ext_attr(p_person_rec,P_person_rec.person_id,l_oss_ext_attr_val);

    IF l_oss_ext_attr_val = 'N' THEN
                  -- The validation failed for OSS extensible attributes. The record would have updated with status and error code in the above procedure validate_oss_ext_attr
      RETURN;
    END IF;

  -- nsidana bug 4063206 : Preferred given name to be derived from given names.
  IF (p_person_rec.preferred_given_name IS NULL)
  THEN
    -- Copy the first part of the first name
    IF (instr(p_person_rec.given_names,' ') = 0) then
      l_preferred_given_name := substr(p_person_rec.given_names,1,length(p_person_rec.given_names));
    ELSE
      l_preferred_given_name := substr(p_person_rec.given_names,1,instr(p_person_rec.given_names,' '));
    END IF;
  ELSE
      l_preferred_given_name := p_person_rec.preferred_given_name;
  END IF;

    IGS_PE_PERSON_PKG.INSERT_ROW( X_MSG_COUNT => l_msg_count,
                                X_MSG_DATA => l_msg_data,
                                X_RETURN_STATUS=> l_return_status,
                                X_ROWID=> l_rowid,
                                X_PERSON_ID => l_person_id,
                                X_PERSON_NUMBER => l_person_number,
                                X_SURNAME => p_person_rec.surname,
                                X_MIDDLE_NAME => p_person_rec.middle_name,
                                X_GIVEN_NAMES=> p_person_rec.given_names,
                                X_SEX => p_person_rec.sex,
                                X_TITLE => p_person_rec.title,
                                X_STAFF_MEMBER_IND => NULL,
                                X_DECEASED_IND      => 'N',
                                X_SUFFIX => p_person_rec.suffix,
                                X_PRE_NAME_ADJUNCT => p_person_rec.pre_name_adjunct,
                                X_ARCHIVE_EXCLUSION_IND    => 'N',
                                X_ARCHIVE_DT => NULL,
                                X_PURGE_EXCLUSION_IND=> 'N',
                                X_PURGE_DT => NULL,
                                X_DECEASED_DATE =>    NULL,
                                X_PROOF_OF_INS  => NVL(p_person_rec.proof_of_ins,'N'),
                                X_PROOF_OF_IMMU=>  NVL(p_person_rec.proof_of_immu,'N'),
                                X_BIRTH_DT=>p_person_rec.birth_dt,
                                X_SALUTATION  => NULL,
                                X_ORACLE_USERNAME     => NULL,
                                X_PREFERRED_GIVEN_NAME=> l_preferred_given_name,
                                X_EMAIL_ADDR=> NULL,
                                X_LEVEL_OF_QUAL_ID  => p_person_rec.level_of_qual_id,
                                X_MILITARY_SERVICE_REG=>NVL(p_person_rec.MILITARY_SERVICE_REG,'N'),
                                X_VETERAN=> NVL(p_person_rec.veteran,'VETERAN_NOT'),  -- ssawhney 2203778, lookup_code
                                x_hz_parties_ovn => l_object_version_number,
                                X_attribute_CATEGORY => p_person_rec.attribute_category,
                                X_attribute1 => p_person_rec.attribute1,
                                X_attribute2 => p_person_rec.attribute2,
                                X_attribute3 => p_person_rec.attribute3,
                                X_attribute4 => p_person_rec.attribute4,
                                X_attribute5 => p_person_rec.attribute5,
                                X_attribute6 => p_person_rec.attribute6,
                                X_attribute7 => p_person_rec.attribute7,
                                X_attribute8 => p_person_rec.attribute8,
                                X_attribute9 => p_person_rec.attribute9,
                                X_attribute10 => p_person_rec.attribute10,
                                X_attribute11 => p_person_rec.attribute11,
                                X_attribute12 => p_person_rec.attribute12,
                                X_attribute13 => p_person_rec.attribute13,
                                X_attribute14 => p_person_rec.attribute14,
                                X_attribute15 => p_person_rec.attribute15,
                                X_attribute16 => p_person_rec.attribute16,
                                X_attribute17 => p_person_rec.attribute17,
                                X_attribute18 => p_person_rec.attribute18,
                                X_attribute19 => p_person_rec.attribute19,
                                X_attribute20 => p_person_rec.attribute20,
                                X_PERSON_ID_TYPE=> l_pref_altid_type,
                                X_API_PERSON_ID         => l_pref_altid,
                                X_MODE => 'R',
                                X_attribute21 => p_person_rec.attribute21,
                                X_attribute22 => p_person_rec.attribute22,
                                X_attribute23 => p_person_rec.attribute23,
                                X_attribute24 => p_person_rec.attribute24
                                );

    IF p_person_rec.birth_city IS NOT NULL OR p_person_rec.birth_country IS NOT NULL OR p_person_rec.felony_convicted_flag IS NOT NULL THEN
      OPEN pe_hz_parties_cur(l_person_id);
      FETCH pe_hz_parties_cur INTO tlinfo2;

      IF pe_hz_parties_cur%FOUND THEN
        IGS_PE_HZ_PARTIES_PKG.UPDATE_ROW(
                 X_ROWID                        => tlinfo2.ROWID,
                 X_PARTY_ID                     => tlinfo2.party_id,
                 X_DECEASED_IND                 => tlinfo2.deceased_ind,
                 X_ARCHIVE_EXCLUSION_IND        => tlinfo2.archive_exclusion_ind,
                 X_ARCHIVE_DT                   => tlinfo2.archive_dt,
                 X_PURGE_EXCLUSION_IND          => tlinfo2.purge_exclusion_ind,
                 X_PURGE_DT                     => tlinfo2.purge_dt,
                 X_ORACLE_USERNAME              => tlinfo2.oracle_username,
                 X_PROOF_OF_INS                 => tlinfo2.proof_of_ins,
                 X_PROOF_OF_IMMU                => tlinfo2.proof_of_immu,
                 X_LEVEL_OF_QUAL                => tlinfo2.level_of_qual,
                 X_MILITARY_SERVICE_REG         => tlinfo2.military_service_reg,
                 X_VETERAN                      => tlinfo2.veteran,
                 X_INSTITUTION_CD               => tlinfo2.institution_cd,
                 X_OI_LOCAL_INSTITUTION_IND     => tlinfo2.oi_local_institution_ind,
                 X_OI_OS_IND                    => tlinfo2.oi_os_ind,
                 X_OI_GOVT_INSTITUTION_CD       => tlinfo2.oi_govt_institution_cd,
                 X_OI_INST_CONTROL_TYPE         => tlinfo2.oi_inst_control_type,
                 X_OI_INSTITUTION_TYPE          => tlinfo2.oi_institution_type,
                 X_OI_INSTITUTION_STATUS        => tlinfo2.oi_institution_status,
                 X_OU_START_DT                  => tlinfo2.ou_start_dt,
                 X_OU_END_DT                    => tlinfo2.ou_end_dt,
                 X_OU_MEMBER_TYPE               => tlinfo2.ou_member_type,
                 X_OU_ORG_STATUS                => tlinfo2.ou_org_status,
                 X_OU_ORG_TYPE                  => tlinfo2.ou_org_type,
                 X_INST_ORG_IND                 => tlinfo2.inst_org_ind,
                 X_FUND_AUTHORIZATION           => tlinfo2.fund_authorization,
                 X_PE_INFO_VERIFY_TIME          => tlinfo2.pe_info_verify_time,
                 X_birth_city                   => p_person_rec.birth_city,
                 X_birth_country                => p_person_rec.birth_country,
                 x_oss_org_unit_cd              => NULL, --mmkumar, party number impact
                 X_felony_convicted_flag        => p_person_rec.felony_convicted_flag,
                 X_MODE                         => 'R'
                );
      END IF;
      CLOSE pe_hz_parties_cur;
    END IF;

    IF (l_Return_Status IN ('E','U') ) THEN
      ROLLBACK TO BEFORE_INSERT;
      P_PERSON_ID := NULL;

          UPDATE IGS_AD_INTERFACE_all
          SET status = '3',
              error_code = 'E322'
          WHERE interface_id = p_person_rec.interface_id;

                       -- Call Log detail

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_002.create_person.exception'||'E322';

            l_debug_str :=  'Interface ID:'||p_person_rec.interface_id||' Person Creation Failed HZMessage: '||l_msg_data||' SQLERRM:' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E322','IGS_AD_INTERFACE_ALL');
        END IF;
      RETURN;
    ELSE
      UPDATE  IGS_AD_INTERFACE_all
      SET     STATUS = '1',
              ERROR_CODE = NULL --ssomani, added this 3/15/01
      WHERE   INTERFACE_ID = P_person_rec.INTERFACE_ID;
      P_PERSON_ID := l_person_id;
                                -- Record is successfully processed, commit the record
      COMMIT;
    END IF;

    EXCEPTION WHEN OTHERS THEN
                        -- Person creation failed
      ROLLBACK TO BEFORE_INSERT;
      IF pe_hz_parties_cur%ISOPEN THEN
        CLOSE pe_hz_parties_cur;
      END IF;

          FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

          IF l_message_name = 'IGS_PE_UNIQUE_PID' THEN
              l_error_code := 'E567';
          ELSE
              l_error_code := 'E322';
          END IF;

          UPDATE IGS_AD_INTERFACE_all
          SET status = '3',
              error_code = l_error_code
          WHERE interface_id = p_person_rec.interface_id;

                        -- Call Log detail
      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_002.create_person.exception'||l_error_code;

          l_debug_str :=  'IGS_AD_IMP_002.Create_Person' || ' Exception from IGS_PE_PERSON_PKG '|| ' Interface Id : ' || (P_person_rec.INTERFACE_ID) ||
          ' Status : 3' ||  ' ErrorCode:'||l_error_code||' SQLERRM '|| SQLERRM ;

            fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str,NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(p_person_rec.interface_id,l_error_code,'IGS_AD_INTERFACE_ALL');
        END IF;

      P_PERSON_ID := NULL;

      RETURN;
    END;
-- stats creation starts here
    DECLARE
      l_rowId VARCHAR2(25);
    BEGIN
      OPEN stat_cur(p_person_rec.INTERFACE_ID);
      FETCH stat_cur INTO stat_rec;
      SAVEPOINT before_insert_stats;
      IF stat_cur%FOUND THEN
             -- marital status and ethnic origin are made case insensitive
        stat_rec.marital_status := UPPER(stat_rec.marital_status);
        stat_rec.ethnic_origin := UPPER(stat_rec.ethnic_origin);
        BEGIN
   --Validation check of Descriptive Flexfield
  -- Added as a part of bug number 2203778
          IF NOT igs_ad_imp_018.validate_desc_flex(
                                 p_attribute_category =>stat_rec.attribute_category,
                                 p_attribute1         =>stat_rec.attribute1  ,
                                 p_attribute2         =>stat_rec.attribute2  ,
                                 p_attribute3         =>stat_rec.attribute3  ,
                                 p_attribute4         =>stat_rec.attribute4  ,
                                 p_attribute5         =>stat_rec.attribute5  ,
                                 p_attribute6         =>stat_rec.attribute6  ,
                                 p_attribute7         =>stat_rec.attribute7  ,
                                 p_attribute8         =>stat_rec.attribute8  ,
                                 p_attribute9         =>stat_rec.attribute9  ,
                                 p_attribute10        =>stat_rec.attribute10 ,
                                 p_attribute11        =>stat_rec.attribute11 ,
                                 p_attribute12        =>stat_rec.attribute12 ,
                                 p_attribute13        =>stat_rec.attribute13 ,
                                 p_attribute14        =>stat_rec.attribute14 ,
                                 p_attribute15        =>stat_rec.attribute15 ,
                                 p_attribute16        =>stat_rec.attribute16 ,
                                 p_attribute17        =>stat_rec.attribute17 ,
                                 p_attribute18        =>stat_rec.attribute18 ,
                                 p_attribute19        =>stat_rec.attribute19 ,
                                 p_attribute20        =>stat_rec.attribute20 ,
                                 p_desc_flex_name     =>'IGS_PE_PERS_STAT' ) THEN
            l_error_code := 'E170' ;
            RAISE NO_DATA_FOUND;
          END IF;
          IF stat_rec.RELIGION_CD IS NOT NULL THEN
            BEGIN
        IF NOT
        (igs_pe_pers_imp_001.validate_lookup_type_code('PE_RELIGION',stat_rec.religion_cd,8405))
        THEN
          IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(stat_rec.INTERFACE_STAT_ID,'E205','IGS_AD_STAT_INT_ALL');
          END IF;
              l_error_code := 'E205' ;
              RAISE NO_DATA_FOUND;
            END IF;
            END;
      END IF;
          IF stat_rec.MARITAL_STATUS IS NOT NULL THEN
            BEGIN
        IF NOT
        (igs_pe_pers_imp_001.validate_lookup_type_code('MARITAL_STATUS',stat_rec.MARITAL_STATUS,222))
        THEN
          IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(stat_rec.INTERFACE_STAT_ID,'E206','IGS_AD_STAT_INT_ALL');
          END IF;
              l_error_code :='E206';
              RAISE NO_DATA_FOUND;
            END IF;
            END;
      END IF;
          IF stat_rec.MARITAL_STATUS_EFFECTIVE_DATE IS NOT NULL THEN
            DECLARE
              CURSOR c_mar_eff_dt(cp_person_id igs_pe_person.person_id%TYPE) IS
                SELECT  BIRTH_DATE
                FROM    IGS_PE_PERSON_BASE_V WHERE
                        PERSON_ID =cp_person_id;
            l_birth_date IGS_PE_PERSON_BASE_V.BIRTH_DATE%TYPE;
            BEGIN
              IF l_birth_date IS NOT NULL THEN
                OPEN c_mar_eff_dt(p_person_id);
                FETCH c_mar_eff_dt INTO l_birth_date;
                CLOSE c_mar_eff_dt;
                IF stat_rec.MARITAL_STATUS_EFFECTIVE_DATE < l_birth_date THEN
                  RAISE NO_DATA_FOUND;
                END IF;
              END IF;
              EXCEPTION
                WHEN NO_DATA_FOUND  THEN
              IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(stat_rec.INTERFACE_STAT_ID,'E277','IGS_AD_STAT_INT_ALL');
              END IF;
                  l_error_code :='E277';
                  RAISE NO_DATA_FOUND;
            END;
          END IF;
          IF stat_rec.ETHNIC_ORIGIN  IS NOT NULL THEN
            DECLARE
              l_object_version_number NUMBER;
            BEGIN
            IF NOT
            (igs_pe_pers_imp_001.validate_lookup_type_code('IGS_ETHNIC_ORIGIN',stat_rec.ETHNIC_ORIGIN,8405))
            THEN
          IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(stat_rec.INTERFACE_STAT_ID,'E207','IGS_AD_STAT_INT_ALL');
          END IF;
              l_error_code := 'E207' ;
              RAISE NO_DATA_FOUND;
            END IF;
            END;
          END IF;
        igs_pe_stat_pkg.insert_row(
                    X_ACTION=> 'INSERT',
                    X_ROWID=> l_rowid,
                    X_PERSON_ID => p_person_id,
                    X_ETHNIC_ORIGIN_ID  =>stat_rec.ethnic_origin,
                    X_MARITAL_STATUS      => stat_rec.marital_status,
                    X_MARITAL_STAT_EFFECT_DT => stat_rec.marital_status_effective_date,
                    X_ANN_FAMILY_INCOME=> NULL,
                    X_NUMBER_IN_FAMILY=> NULL,
                    X_CONTENT_SOURCE_TYPE => 'USER_ENTERED',
                    X_INTERNAL_FLAG=> NULL,
                    X_PERSON_NUMBER => NULL,
                    X_EFFECTIVE_START_DATE => SYSDATE,
                    X_EFFECTIVE_END_DATE => NULL,
                    X_ETHNIC_ORIGIN => NULL,
                    X_RELIGION=> stat_rec.religion_cd,
                    X_NEXT_TO_KIN  => NULL,
                    X_NEXT_TO_KIN_MEANING  => NULL,
                    X_PLACE_OF_BIRTH => stat_rec.place_of_birth,
                    X_SOCIO_ECO_STATUS  => NULL,
                    X_SOCIO_ECO_STATUS_DESC   => NULL,
                    X_FURTHER_EDUCATION   => NULL,
                    X_FURTHER_EDUCATION_DESC => NULL,
                    X_IN_STATE_TUITION=> NULL,
                    X_TUITION_ST_DATE=> NULL,
                    X_TUITION_END_DATE       => NULL,
                    X_PERSON_INITIALS      => NULL,
                    X_PRIMARY_CONTACT_ID      => NULL,
                    X_PERSONAL_INCOME         => NULL,
                    X_HEAD_OF_HOUSEHOLD_FLAG => NULL,
                    X_CONTENT_SOURCE_NUMBER => NULL,
                    x_hz_parties_ovn => l_object_version_number,
                    X_attribute_category  => stat_rec.attribute_category,
                    X_attribute1  => stat_rec.attribute1  ,
                    X_attribute2  => stat_rec.attribute2  ,
                    X_attribute3  => stat_rec.attribute3  ,
                    X_attribute4  => stat_rec.attribute4  ,
                    X_attribute5  => stat_rec.attribute5  ,
                    X_attribute6  => stat_rec.attribute6  ,
                    X_attribute7  => stat_rec.attribute7  ,
                    X_attribute8  => stat_rec.attribute8  ,
                    X_attribute9  => stat_rec.attribute9  ,
                    X_attribute10 => stat_rec.attribute10  ,
                    X_attribute11 => stat_rec.attribute11  ,
                    X_attribute12 => stat_rec.attribute12  ,
                    X_attribute13 => stat_rec.attribute13  ,
                    X_attribute14 => stat_rec.attribute14  ,
                    X_attribute15 => stat_rec.attribute15  ,
                    X_attribute16 => stat_rec.attribute16  ,
                    X_attribute17 => stat_rec.attribute17  ,
                    X_attribute18 => stat_rec.attribute18  ,
                    X_attribute19 => stat_rec.attribute19  ,
                    X_attribute20 => stat_rec.attribute20   ,
                    X_GLOBAL_attribute_CATEGORY     => NULL,
                    X_GLOBAL_attribute1           => NULL,
                    X_GLOBAL_attribute2             => NULL,
                    X_GLOBAL_attribute3            => NULL,
                    X_GLOBAL_attribute4 => NULL,
                    X_GLOBAL_attribute5      => NULL,
                    X_GLOBAL_attribute6      => NULL,
                    X_GLOBAL_attribute7        => NULL,
                    X_GLOBAL_attribute8  => NULL,
                    X_GLOBAL_attribute9    => NULL,
                    X_GLOBAL_attribute10     => NULL,
                    X_GLOBAL_attribute11      => NULL,
                    X_GLOBAL_attribute12     => NULL,
                    X_GLOBAL_attribute13     => NULL,
                    X_GLOBAL_attribute14  => NULL,
                    X_GLOBAL_attribute15     => NULL,
                    X_GLOBAL_attribute16     => NULL,
                    X_GLOBAL_attribute17     => NULL,
                    X_GLOBAL_attribute18     => NULL,
                    X_GLOBAL_attribute19      => NULL,
                    X_GLOBAL_attribute20       => NULL,
                    X_PARTY_LAST_UPDATE_DATE =>  L_party_last_update_date,
                    X_PERSON_PROFILE_ID=> l_person_profile_id,
                    X_MATR_CAL_TYPE => NULL,
                    X_MATR_SEQUENCE_NUMBER => NULL,
                    X_INIT_CAL_TYPE => NULL,
                    X_INIT_SEQUENCE_NUMBER => NULL,
                    X_RECENT_CAL_TYPE => NULL,
                    X_RECENT_SEQUENCE_NUMBER => NULL,
                    X_CATALOG_CAL_TYPE => NULL,
                    X_CATALOG_SEQUENCE_NUMBER => NULL,
                    Z_RETURN_STATUS    => l_return_status,
                    Z_MSG_COUNT  => l_msg_count,
                    Z_MSG_DATA => l_msg_data,
		    X_BIRTH_CNTRY_RESN_CODE  => NULL   --- prbhardw
                    );

          IF l_return_status IN ('E','U') THEN
            ROLLBACK TO before_insert_stats;
            UPDATE  IGS_AD_STAT_INT_ALL
            SET   STATUS = '3',
                  ERROR_CODE = 'E005'
            WHERE  INTERFACE_STAT_ID = stat_rec.INTERFACE_STAT_ID;

            UPDATE igs_ad_interface_all
            SET status = '4',
                error_code = 'E005'
            WHERE interface_id = p_person_rec.interface_id;

                                        -- Call Log detail
        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

          IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
          END IF;

          l_label := 'igs.plsql.IGS_AD_IMP_002.create_person.exception:E005';

          l_debug_str := 'IGS_AD_IMP_002.Create_Person ' || 'Error from IGS_PE_STAT_PKG. HzMesg : '
                               || l_msg_data || ' Interface stat ID : ' || stat_rec.interface_stat_id||' Status : 3' ||  ' ErrorCode : E005';

          fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(stat_rec.interface_stat_id,'E005','IGS_AD_STAT_INT_ALL');
        END IF;

          ELSE
            UPDATE IGS_AD_STAT_INT_ALL
            SET    STATUS = '1',
                   ERROR_CODE = NULL, --ssomani, added this 3/15/01
                   PERSON_ID = P_PERSON_ID
            WHERE  INTERFACE_STAT_ID = stat_rec.INTERFACE_STAT_ID;
          END IF;



          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              ROLLBACK TO before_insert_stats;
              L_MSG_DATA := SQLERRM;
              UPDATE        IGS_AD_STAT_INT_ALL
              SET     status = '3',
                      error_code = l_error_code
              WHERE   INTERFACE_STAT_ID = stat_rec.INTERFACE_STAT_ID;

             UPDATE igs_ad_interface_all
             SET status = '4',
                error_code = 'E005'
             WHERE interface_id = p_person_rec.interface_id;

            WHEN OTHERS THEN
              L_MSG_DATA := SQLERRM;
              ROLLBACK TO before_insert_stats;

              UPDATE    IGS_AD_STAT_INT_ALL
              SET   STATUS = '3',
                    ERROR_CODE = 'E005'
              WHERE INTERFACE_STAT_ID = stat_rec.INTERFACE_STAT_ID;

            UPDATE igs_ad_interface_all
            SET status = '4',
                error_code = 'E005'
            WHERE interface_id = p_person_rec.interface_id;

                         -- Call Log detail
      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;
            l_label := 'igs.plsql.igs_ad_imp_002.create_person.exception'||'E005';

          l_debug_str :=  'IGS_AD_IMP_002.Create_Person ' || 'Error from IGS_PE_STAT_PKG' || l_msg_data ||
            ' Interface Stat Id : ' || stat_rec.interface_stat_id
            || ' Status : 3' ||  ' ErrorCode: E005 SQLERRM:' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(stat_rec.interface_stat_id,'E005','IGS_AD_STAT_INT_ALL');
    END IF;

        END;
      END IF;
      CLOSE stat_cur;
    END;

    IF stat_cur%ISOPEN THEN
      CLOSE stat_cur;
    END IF;
                -- End Statistics


                -- Begin Address
    DECLARE
      CURSOR check_addr_dup_cur(cp_person_id hz_party_sites.party_id%TYPE,
                                     cp_addr_rec addr_cur%ROWTYPE) IS
       SELECT site.location_id, site.party_site_id
       FROM   hz_locations loc, hz_party_sites site
       WHERE  site.party_id  = cp_person_id
       AND    site.location_id  = loc.location_id
       AND    UPPER(NVL(loc.address1,'X')) = UPPER(NVL(cp_addr_rec.addr_line_1,'X'))
       AND    UPPER(NVL(loc.address2,'X')) = UPPER(NVL(cp_addr_rec.addr_line_2,'X'))
       AND    UPPER(NVL(loc.address3,'X')) = UPPER(NVL(cp_addr_rec.addr_line_3,'X'))
       AND    UPPER(NVL(loc.address4,'X')) = UPPER(NVL(cp_addr_rec.addr_line_4,'X'))
       AND    UPPER(NVL(loc.city,'X'))     = UPPER(NVL(cp_addr_rec.city,'X'))
       AND    UPPER(NVL(loc.state,'X'))    = UPPER(NVL(cp_addr_rec.state,'X'))
       AND    loc.country           = cp_addr_rec.country
       AND     UPPER(NVL(loc.county,'X'))   = UPPER(NVL(cp_addr_rec.county,'X'))
       AND     UPPER(NVL(loc.province,'X')) = UPPER(NVL(cp_addr_rec.province,'X'));

       l_party_site_id  hz_party_sites.party_site_id%TYPE;
    BEGIN
       g_addr_process := FALSE;

    OPEN ADDR_CUR(p_person_rec.INTERFACE_ID);
    LOOP
       FETCH addr_cur INTO ADDR_REC;
       EXIT WHEN addr_cur%NOTFOUND;

       ADDR_REC.country := UPPER(ADDR_REC.country);
       l_location_id    := NULL;

       OPEN check_addr_dup_cur(p_person_id,addr_rec);
       FETCH check_addr_dup_cur INTO l_location_id, l_party_site_id;
       CLOSE check_addr_dup_cur;


        IF l_location_id IS NOT NULL THEN
            --Make a call to IGS_AD_UPDATE_ADDRESS with the following parameters.
            -- since this address exists already. Update it.
            UPDATE_ADDRESS(
                  P_ADDR_REC   => ADDR_REC,
                  P_PERSON_ID   => p_person_id,
                  P_LOCATION_ID => l_location_id,
                  p_party_site_id => l_party_site_id);
           ELSE
            -- Address not exists. Create it.
             CREATE_ADDRESS(P_addr_rec  => addr_rec,
                   P_PERSON_ID =>p_person_id,
                   P_STATUS=>l_Status,
                   p_error_code=>l_Error_Code);
        END IF;

        IF l_status = '3' THEN
           UPDATE   igs_ad_interface_all
           SET      status = '4',
                error_code = 'E006'
           WHERE    interface_id = p_person_rec.interface_id;

              IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(P_person_rec.INTERFACE_ID,'E006','IGS_AD_INTERFACE_ALL');
              END IF;
        END IF;
        END LOOP;
        CLOSE ADDR_CUR;

        IF g_addr_process THEN
          igs_pe_wf_gen.ti_addr_chg_persons(NVL(igs_pe_wf_gen.ti_addr_chg_persons.LAST,0)+1) := p_person_id;
        END IF;
    END;
                -- End address

    BEGIN
    OPEN api_cur(p_person_rec.interface_id);
    LOOP
        FETCH api_cur INTO api_rec;
        EXIT WHEN api_cur%NOTFOUND;
          api_rec.person_id_type := UPPER(api_rec.person_id_type);
          api_rec.alternate_id   := UPPER(api_rec.alternate_id);
        create_api(p_api_rec =>api_rec,
                p_person_id =>l_person_id,
                p_status =>l_status,
                p_error_code => l_error_code);

        IF l_status = '3' THEN

            UPDATE igs_ad_api_int_all
            SET status = l_status,
                error_code = l_error_code
            WHERE interface_api_id = api_rec.interface_api_id;
            UPDATE igs_ad_interface_all
            SET status = '4',
                error_code = 'E007'
            WHERE interface_id = p_person_rec.interface_id;
              IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(P_person_rec.INTERFACE_ID,'E007','IGS_AD_INTERFACE_ALL');
              END IF;

        ELSIF l_status = '1' THEN

              UPDATE igs_ad_api_int_all
              SET status = '1',
              error_code = null
              WHERE interface_api_id = api_rec.interface_api_id;


        END IF;
    END LOOP;
    CLOSE api_cur;

    END;
END CREATE_PERSON;

PROCEDURE UPDATE_PERSON( p_person_rec IN IGS_AD_INTERFACE_DTL_DSCP_V%ROWTYPE,
                         P_ADDR_TYPE  IN VARCHAR2,
                         P_PERSON_ID_TYPE IN VARCHAR2,
                         P_PERSON_ID IN  IGS_PE_PERSON.PERSON_ID%TYPE) AS
        /*
          ||  Created By : nsinha
          ||  Created On : 22-JUN-2001
          ||  Purpose : This procedure process the Application
          ||  Known limitations, enhancements or remarks :
          ||  Change History :
          ||  Who             When            What
          ||  skpandey        21-SEP-2005    Bug: 3663505
          ||                                 Description: Added ATTRIBUTES 21 TO 24 to store additional information
          ||  pkpatel       22-JUN-2001      Bug no.1834307 :For Modeling and Forecasting DLD
          ||                                 Modified the signature by changing the datatype of parameter from
          ||                                 igs_ad_interface_all%ROWTYPE to igs_ad_interface_dtl_dscp_v%ROWTYPE
          ||  nsinha        08-Apr-2002      Bug no.2028066: Added Cursor for Null handling Rule.
          ||  pkpatel       25-DEC-2002      Bug No: 2702536
          ||                                 Added commit after the processing each person record.
          ||  vrathi        25-jun-2003      Bug No:3019813
          ||                                 Added check to set error code and status if the person already exists in HR
          ||  asbala        12-APR-2004      3313276: Use lookup_type HZ_GENDER to validate Gender
          ||  mmkumar       19-JUL-2005      passed NULL for x_oss_org_unit_cd in add_row call to igs_pe_hz_parties_pkg,
          ||  (reverse chronological order - newest change first)
        */

      l_miss_person_rec       HZ_PARTY_V2PUB.person_rec_TYPE;
      l_prog_label  VARCHAR2(4000);
      l_label  VARCHAR2(4000);
      l_debug_str VARCHAR2(4000);
      l_enable_log VARCHAR2(1);
      l_request_id NUMBER(10);
      l_message_name  VARCHAR2(30);
      l_app           VARCHAR2(50);

        CURSOR addr_cur(cp_interface_id IGS_AD_ADDR_INT_ALL.INTERFACE_ID%TYPE) IS
        SELECT AI.*
        FROM IGS_AD_ADDR_INT_ALL AI
        WHERE (AI.INTERFACE_ID = cp_interface_id)
              AND NVL(AI.STATUS, '2')  = '2';


        addr_rec ADDR_cur%ROWTYPE;


        CURSOR API_cur(cp_interface_id  IGS_AD_API_INT_ALL.INTERFACE_ID%TYPE) IS
        SELECT *
        FROM IGS_AD_API_INT_ALL
        WHERE INTERFACE_ID =  cp_interface_id
              AND     NVL(STATUS, '2')  = '2'; --  The mandatory data restriction for other person type is removed
                                                         -- Therefore the person ID type check is removed

        api_rec api_cur%ROWTYPE;

        -- Cursor for Null handling Rule.
        -- Cursor for Null handling Rule
          CURSOR  c_null_hdlg_per_cur(cp_person_id igs_pe_person.person_id%TYPE) IS
          SELECT
          p.rowid row_id,
          p.party_id person_id,
          p.party_number person_number,
          p.party_name person_name,
          NULL staff_member_ind,
          p.person_last_name surname,
          p.person_first_name given_names,
          p.person_middle_name middle_name,
          p.person_name_suffix suffix,
          p.person_pre_name_adjunct pre_name_adjunct,
          p.person_title title,
          p.email_address email_addr,
          p.salutation,
          p.known_as preferred_given_name,
          pd.proof_of_ins,
          pd.proof_of_immu,
          pd.level_of_qual level_of_qual_id,
          pd.military_service_reg,
          pd.veteran,
          DECODE(pp.date_of_death,NULL,NVL(pd.deceased_ind,'N'),'Y') deceased_ind,
          pp.gender sex,
          pp.date_of_death deceased_date,
          pp.date_of_birth birth_dt,
          pd.archive_exclusion_ind,
          pd.archive_dt,
          pd.purge_exclusion_ind,
          pd.purge_dt,
          pit.person_id_type,
          pit.api_person_id,
          pd.fund_authorization,
          p.attribute_category,
          p.attribute1,
          p.attribute2,
          p.attribute3,
          p.attribute4,
          p.attribute5,
          p.attribute6,
          p.attribute7,
          p.attribute8,
          p.attribute9,
          p.attribute10,
          p.attribute11,
          p.attribute12,
          p.attribute13,
          p.attribute14,
          p.attribute15,
          p.attribute16,
          p.attribute17,
          p.attribute18,
          p.attribute19,
          p.attribute20,
          p.attribute21,
          p.attribute22,
          p.attribute23,
          p.attribute24,
          pd.oracle_username ,
          pd.birth_city,
          pd.birth_country,
          p.object_version_number,
          p.status,
          pd.felony_convicted_flag
          FROM
          hz_parties p,
          igs_pe_hz_parties pd,
          hz_person_profiles pp,
          igs_pe_person_id_type_v pit
          WHERE p.party_id = cp_person_id
          AND p.party_id = pit.pe_person_id (+)
          AND p.party_id  = pd.party_id (+)
          AND p.party_id = pp.party_id
          AND SYSDATE BETWEEN pp.effective_start_date AND NVL(pp.effective_end_date,SYSDATE);

     -- Cursor to get format mask to validate person alternate id.
      CURSOR api_type_cur(cp_person_id_type igs_pe_person_id_typ.person_id_type%TYPE) IS
      SELECT format_mask
      FROM   igs_pe_person_id_typ
      WHERE  person_id_type = cp_person_id_type;

      api_type_rec  api_type_cur%ROWTYPE;

      CURSOR c_pref_alt_id_type IS
      SELECT PERSON_ID_TYPE
      FROM IGS_PE_PERSON_ID_TYP
      WHERE PREFERRED_IND  ='Y';

      CURSOR pe_hz_parties_cur(cp_person_id igs_pe_hz_parties.party_id%TYPE) IS
      SELECT pehz.ROWID, pehz.*
      FROM IGS_PE_HZ_PARTIES pehz
      WHERE party_id =  cp_person_id;

      CURSOR hz_parties_cur(cp_person_id  hz_parties.party_id%TYPE)IS
      SELECT last_update_date, ROWID
      FROM   hz_parties
      WHERE  party_id = cp_person_id;

        l_pref_altid_type IGS_PE_PERSON_ID_TYP.PERSON_ID_TYPE%TYPE;
        l_pref_altid p_person_rec.PREF_ALTERNATE_ID%TYPE;
        tlinfo2 pe_hz_parties_cur%ROWTYPE;
        c_null_hdlg_per_rec   c_null_hdlg_per_cur%ROWTYPE;
        lv_deceased_ind igs_pe_hz_parties.deceased_ind%TYPE;

        l_location_Id   NUMBER;
        l_rowid VARCHAR2(25);
        l_person_id  IGS_PE_PERSON.PERSON_ID%TYPE;
        l_PrefPersonIDType IGS_PE_PERSON_ID_TYP.PERSON_ID_TYPE%TYPE;
        l_status VARCHAR2(2);
        l_error_code VARCHAR2(6);
        l_Last_Update_Date      DATE;
        l_Error_Code_Num NUMBER;
        lnDupExist               NUMBER;
        l_Return_Status VARCHAR2(1);
        l_Msg_Data      VARCHAR2(4000);
        l_Party_Id      NUMBER;
        l_Party_Number  VARCHAR2(100);
        l_Profile_Id    NUMBER;
        l_Msg_Count     NUMBER;
        l_var VARCHAR2(1);
        l_object_version_number NUMBER;
        l_oss_ext_attr_val  VARCHAR2(1);
        l_preferred_given_name igs_ad_interface_all.PREFERRED_GIVEN_NAME%TYPE;
        l_felony_convicted_flag VARCHAR2(1);
BEGIN

    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_prog_label := 'igs.plsql.igs_ad_imp_002.update_person';
    l_label := 'igs.plsql.igs_ad_imp_002.update_person.';
    l_oss_ext_attr_val := 'Y';

    -- Call Log header
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_002.update_person.begin';
    l_debug_str := 'Interface Id : ' || P_person_rec.INTERFACE_ID;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

-- validations before update

 -- Validate the title
  IF P_Person_Rec.pre_name_adjunct IS NOT NULL THEN
    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('CONTACT_TITLE',P_Person_Rec.pre_name_adjunct,222))
    THEN
      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E201','IGS_AD_INTERFACE_ALL');
      END IF;

      UPDATE IGS_AD_INTERFACE_ALL
      SET ERROR_CODE = 'E201',
          STATUS       = '3'
      WHERE INTERFACE_ID = P_Person_Rec.Interface_Id;
      RETURN;
    END IF;
  END IF;

                -- Validate Sex.
  IF P_Person_Rec.sex IS NOT NULL THEN
    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('HZ_GENDER',p_Person_Rec.sex,222))
    THEN
      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E202','IGS_AD_INTERFACE_ALL');
      END IF;

      UPDATE IGS_AD_INTERFACE_ALL
      SET ERROR_CODE = 'E202',
          STATUS       = '3'
      WHERE INTERFACE_ID = P_Person_Rec.Interface_Id;
      RETURN;
    END IF;
  END IF;

                -- Validate birth_dt
  IF   (  ((P_Person_Rec.birth_dt IS NOT NULL) AND (P_Person_Rec.birth_dt > SYSDATE))  )  THEN
      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E203','IGS_AD_INTERFACE_ALL');
      END IF;

    UPDATE IGS_AD_INTERFACE_ALL
    SET ERROR_CODE = 'E203',
        STATUS       = '3'
    WHERE INTERFACE_ID = P_Person_Rec.Interface_Id;
    RETURN;
  END IF;

  IF p_person_rec.pref_alternate_id IS NOT NULL THEN
            -- Added as a fix for Bug Number 2333026
    OPEN c_pref_alt_id_type;
    FETCH c_pref_alt_id_type INTO l_pref_altid_type;
    IF (c_pref_alt_id_type%NOTFOUND) THEN
      l_pref_altid_type := NULL;
      l_pref_altid := NULL;

               -- (pathipat) For Bug: 2485638
      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E285','IGS_AD_INTERFACE_ALL');
      END IF;

      UPDATE IGS_AD_INTERFACE_ALL
      SET ERROR_CODE = 'E285',
          STATUS       = '3'
      WHERE INTERFACE_ID = P_Person_Rec.Interface_Id;
      CLOSE c_pref_alt_id_type;
      RETURN;

    ELSE
                                                                           --validate Person ID type
      OPEN  api_type_cur(l_pref_altid_type);
      FETCH api_type_cur INTO api_type_rec;
      CLOSE api_type_cur;

                                                -- Validate the format mask
      IF api_type_rec.format_mask IS NOT NULL THEN
        IF NOT igs_en_val_api.fm_equal(p_person_rec.PREF_ALTERNATE_ID,api_type_rec.format_mask) THEN
      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E268','IGS_AD_INTERFACE_ALL');
      END IF;

          UPDATE IGS_AD_INTERFACE_ALL
          SET ERROR_CODE = 'E268',
              STATUS       = '3'
          WHERE INTERFACE_ID = P_Person_Rec.Interface_Id;
          CLOSE c_pref_alt_id_type;
          RETURN;
        END IF;
      END IF;
      l_pref_altid := p_person_rec.PREF_ALTERNATE_ID;

    END IF;
    CLOSE c_pref_alt_id_type;
  ELSE
    l_pref_altid_type := NULL;
    l_pref_altid := NULL;
  END IF;


  OPEN hz_parties_cur(p_person_id);
  FETCH hz_parties_cur INTO l_last_update_date, l_rowid;
  IF hz_parties_cur%NOTFOUND THEN
      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E019','IGS_AD_INTERFACE_ALL');
      END IF;

    UPDATE IGS_AD_INTERFACE_ALL
    SET    ERROR_CODE = 'E019',
           STATUS       = '3'
    WHERE  INTERFACE_ID = P_Person_Rec.Interface_Id;
    CLOSE hz_parties_cur;

    RETURN;
  END IF;
  CLOSE hz_parties_cur;

        -- Validate the OSS extensible attributes
  validate_oss_ext_attr(p_person_rec,P_PERSON_ID,l_oss_ext_attr_val);

  IF l_oss_ext_attr_val = 'N' THEN
                  -- The validation failed for OSS extensible attributes. The record would have updated with status and error code in the above procedure validate_oss_ext_attr
    RETURN;
  END IF;


    -- Open Cursor for the ADMISSION table for the particular person to import the
    -- selected attributes from the INTERFACE table
  OPEN  c_null_hdlg_per_cur(p_person_id);
  FETCH c_null_hdlg_per_cur INTO c_null_hdlg_per_rec;
  CLOSE c_null_hdlg_per_cur;

  IF (p_person_rec.preferred_given_name IS NOT NULL)
  THEN
    l_preferred_given_name := p_person_rec.preferred_given_name;
  ELSE
    IF (p_person_rec.given_names = c_null_hdlg_per_rec.given_names)
    THEN
      l_preferred_given_name := null;
    ELSE
      -- nsidana bug 4063206 : Preferred given name to be derived from given names.
        -- Copy the first part of the first name
        IF (instr(p_person_rec.given_names,' ') = 0) then
          l_preferred_given_name := substr(p_person_rec.given_names,1,length(p_person_rec.given_names));
        ELSE
          l_preferred_given_name := substr(p_person_rec.given_names,1,instr(p_person_rec.given_names,' '));
        END IF;
    END IF;
  END IF;

  SAVEPOINT BEFORE_UPDATE;

  BEGIN
        -- Update Person
    IGS_PE_PERSON_PKG.UPDATE_ROW(
                X_LAST_UPDATE_DATE => l_last_update_date,
                X_MSG_COUNT => l_msg_count,
                X_MSG_DATA => l_msg_data,
                X_RETURN_STATUS=> l_return_status,
                X_ROWID=> l_rowid,
                X_PERSON_ID => p_person_id,
                X_PERSON_NUMBER => c_null_hdlg_per_rec.person_number,
                X_SURNAME => NVL(p_person_rec.surname,c_null_hdlg_per_rec.surname),
                X_MIDDLE_NAME => NVL(p_person_rec.middle_name,c_null_hdlg_per_rec.middle_name),
                X_GIVEN_NAMES=> NVL(p_person_rec.given_names,c_null_hdlg_per_rec.given_names),
                X_SEX => NVL(p_person_rec.sex,c_null_hdlg_per_rec.sex),
                X_TITLE => NVL(p_person_rec.title,c_null_hdlg_per_rec.title),
                X_STAFF_MEMBER_IND => c_null_hdlg_per_rec.staff_member_ind,
                X_DECEASED_IND      => c_null_hdlg_per_rec.deceased_ind,
                X_SUFFIX => NVL(p_person_rec.suffix,c_null_hdlg_per_rec.suffix),
                X_PRE_NAME_ADJUNCT => NVL(p_person_rec.pre_name_adjunct,c_null_hdlg_per_rec.pre_name_adjunct), ---here
                X_ARCHIVE_EXCLUSION_IND    => c_null_hdlg_per_rec.archive_exclusion_ind,
                X_ARCHIVE_DT => c_null_hdlg_per_rec.archive_dt,
                X_PURGE_EXCLUSION_IND => c_null_hdlg_per_rec.purge_exclusion_ind,
                X_PURGE_DT => c_null_hdlg_per_rec.purge_dt,
                X_DECEASED_DATE =>    c_null_hdlg_per_rec.deceased_date,
                X_PROOF_OF_INS  => NVL(p_person_rec.proof_of_ins,c_null_hdlg_per_rec.proof_of_ins),
                X_PROOF_OF_IMMU=>  NVL(p_person_rec.proof_of_immu,c_null_hdlg_per_rec.proof_of_immu),
                X_BIRTH_DT => NVL(p_person_rec.birth_dt,c_null_hdlg_per_rec.birth_dt),
                X_SALUTATION  => c_null_hdlg_per_rec.salutation,
                X_ORACLE_USERNAME     => c_null_hdlg_per_rec.oracle_username,
                X_PREFERRED_GIVEN_NAME=> NVL(l_preferred_given_name,c_null_hdlg_per_rec.preferred_given_name),
                X_EMAIL_ADDR=> c_null_hdlg_per_rec.email_addr,
                X_LEVEL_OF_QUAL_ID  => NVL(p_person_rec.level_of_qual_id,c_null_hdlg_per_rec.level_of_qual_id),
                X_MILITARY_SERVICE_REG=> NVL( p_person_rec.military_service_reg,c_null_hdlg_per_rec.military_service_reg),
                X_VETERAN=> NVL(p_person_rec.veteran,'VETERAN_NOT'),  --ssawhney 2203778 lookup_code
                x_hz_parties_ovn => c_null_hdlg_per_rec.object_version_number,
                X_attribute_CATEGORY => NVL( p_person_rec.attribute_category,c_null_hdlg_per_rec.attribute_category),
                X_attribute1 => NVL(p_person_rec.attribute1,c_null_hdlg_per_rec.attribute1),
                X_attribute2 => NVL(p_person_rec.attribute2,c_null_hdlg_per_rec.attribute2),
                X_attribute3 => NVL(p_person_rec.attribute3,c_null_hdlg_per_rec.attribute3),
                X_attribute4 => NVL(p_person_rec.attribute4,c_null_hdlg_per_rec.attribute4),
                X_attribute5 => NVL(p_person_rec.attribute5,c_null_hdlg_per_rec.attribute5),
                X_attribute6 => NVL(p_person_rec.attribute6,c_null_hdlg_per_rec.attribute6),
                X_attribute7 => NVL(p_person_rec.attribute7,c_null_hdlg_per_rec.attribute7),
                X_attribute8 => NVL(p_person_rec.attribute8,c_null_hdlg_per_rec.attribute8),
                X_attribute9 => NVL(p_person_rec.attribute9,c_null_hdlg_per_rec.attribute9),
                X_attribute10 => NVL(p_person_rec.attribute10,c_null_hdlg_per_rec.attribute10),
                X_attribute11 => NVL(p_person_rec.attribute11,c_null_hdlg_per_rec.attribute11),
                X_attribute12 => NVL(p_person_rec.attribute12,c_null_hdlg_per_rec.attribute12),
                X_attribute13 => NVL(p_person_rec.attribute13,c_null_hdlg_per_rec.attribute13),
                X_attribute14 => NVL(p_person_rec.attribute14,c_null_hdlg_per_rec.attribute14),
                X_attribute15 => NVL(p_person_rec.attribute15,c_null_hdlg_per_rec.attribute15),
                X_attribute16 => NVL(p_person_rec.attribute16,c_null_hdlg_per_rec.attribute16),
                X_attribute17 => NVL(p_person_rec.attribute17,c_null_hdlg_per_rec.attribute17),
                X_attribute18 => NVL(p_person_rec.attribute18,c_null_hdlg_per_rec.attribute18),
                X_attribute19 => NVL(p_person_rec.attribute19,c_null_hdlg_per_rec.attribute19),
                X_attribute20 => NVL(p_person_rec.attribute20,c_null_hdlg_per_rec.attribute20),
                X_PERSON_ID_TYPE=> l_pref_altid_type,
                X_API_PERSON_ID         => l_pref_altid,
                X_MODE => 'R',
                X_attribute21 => NVL(p_person_rec.attribute21,c_null_hdlg_per_rec.attribute21),
                X_attribute22 => NVL(p_person_rec.attribute22,c_null_hdlg_per_rec.attribute22),
                X_attribute23 => NVL(p_person_rec.attribute23,c_null_hdlg_per_rec.attribute23),
                X_attribute24 => NVL(p_person_rec.attribute24,c_null_hdlg_per_rec.attribute24)
                );
    IF p_person_rec.level_of_qual_id IS NOT NULL OR p_person_rec.proof_of_ins  IS NOT NULL OR p_person_rec.proof_of_immu  IS NOT NULL OR
       p_person_rec.military_service_reg  IS NOT NULL OR p_person_rec.veteran  IS NOT NULL OR p_person_rec.birth_city  IS NOT NULL OR
       p_person_rec.birth_country  IS NOT NULL OR p_person_rec.felony_convicted_flag IS NOT NULL THEN

      OPEN pe_hz_parties_cur(p_person_id);
      FETCH pe_hz_parties_cur INTO tlinfo2;
      CLOSE pe_hz_parties_cur;

        IF p_person_rec.felony_convicted_flag = FND_API.G_MISS_CHAR THEN
          l_felony_convicted_flag := NULL;
        ELSE
          l_felony_convicted_flag := NVL(p_person_rec.felony_convicted_flag,tlinfo2.felony_convicted_flag);
        END IF;

        IGS_PE_HZ_PARTIES_PKG.ADD_ROW(
                 X_ROWID                        => tlinfo2.ROWID,
                 X_PARTY_ID                     => p_person_id,
                 X_DECEASED_IND                 => tlinfo2.deceased_ind,
                 X_ARCHIVE_EXCLUSION_IND        => tlinfo2.archive_exclusion_ind,
                 X_ARCHIVE_DT                   => tlinfo2.archive_dt,
                 X_PURGE_EXCLUSION_IND          => tlinfo2.purge_exclusion_ind,
                 X_PURGE_DT                     => tlinfo2.purge_dt,
                 X_ORACLE_USERNAME              => tlinfo2.oracle_username,
                 X_PROOF_OF_INS                 => NVL(p_person_rec.proof_of_ins,tlinfo2.proof_of_ins),
                 X_PROOF_OF_IMMU                => NVL(p_person_rec.proof_of_immu,tlinfo2.proof_of_immu),
                 X_LEVEL_OF_QUAL                => NVL(p_person_rec.level_of_qual_id,tlinfo2.level_of_qual),
                 X_MILITARY_SERVICE_REG         => NVL(p_person_rec.military_service_reg,tlinfo2.military_service_reg),
                 X_VETERAN                      => NVL(p_person_rec.veteran,tlinfo2.veteran),
                 X_INSTITUTION_CD               => tlinfo2.institution_cd,
                 X_OI_LOCAL_INSTITUTION_IND     => tlinfo2.oi_local_institution_ind,
                 X_OI_OS_IND                    => tlinfo2.oi_os_ind,
                 X_OI_GOVT_INSTITUTION_CD       => tlinfo2.oi_govt_institution_cd,
                 X_OI_INST_CONTROL_TYPE         => tlinfo2.oi_inst_control_type,
                 X_OI_INSTITUTION_TYPE          => tlinfo2.oi_institution_type,
                 X_OI_INSTITUTION_STATUS        => tlinfo2.oi_institution_status,
                 X_OU_START_DT                  => tlinfo2.ou_start_dt,
                 X_OU_END_DT                    => tlinfo2.ou_end_dt,
                 X_OU_MEMBER_TYPE               => tlinfo2.ou_member_type,
                 X_OU_ORG_STATUS                => tlinfo2.ou_org_status,
                 X_OU_ORG_TYPE                  => tlinfo2.ou_org_type,
                 X_INST_ORG_IND                 => tlinfo2.inst_org_ind,
                 X_FUND_AUTHORIZATION           => tlinfo2.fund_authorization,
                 X_PE_INFO_VERIFY_TIME          => tlinfo2.pe_info_verify_time,
                 X_birth_city                   => NVL(p_person_rec.birth_city,tlinfo2.birth_city),
                 X_birth_country                => NVL(p_person_rec.birth_country,tlinfo2.birth_country),
                 x_oss_org_unit_cd              => NULL, --mmkumar, party number impact
                 X_felony_convicted_flag        => l_felony_convicted_flag,
                 X_MODE                         => 'R'
                );
    END IF;

    EXCEPTION
      WHEN OTHERS THEN

        ROLLBACK TO BEFORE_UPDATE;

          IF pe_hz_parties_cur%ISOPEN THEN
            CLOSE pe_hz_parties_cur;
          END IF;
          FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

          IF l_message_name = 'IGS_PE_UNIQUE_PID' THEN
              l_error_code := 'E567';
          ELSE
              l_error_code := 'E014';
          END IF;

          UPDATE IGS_AD_INTERFACE_all
          SET status = '3',
              error_code = l_error_code
          WHERE interface_id = p_person_rec.interface_id;


      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
          l_msg_data := SQLERRM ; --ssomani, added this 3/15/01
            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_002.update_person.exception'||l_error_code;

          l_debug_str :=  'IGS_AD_IMP_002.Update_Person' || ' Exception from IGS_PE_PERSON_PKG ' ||
                                      ' Interface Id : ' || ( P_person_rec.INTERFACE_ID) ||
                                      ' Status : 3' ||  ' ErrorCode : '||l_error_code||' SQLERRM:' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,l_label,l_debug_str, NULL,NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

        IF l_enable_log = 'Y' THEN
             igs_ad_imp_001.logerrormessage(p_person_rec.interface_id,l_error_code,'IGS_AD_INTERFACE_ALL');
        END IF;
        RETURN;
  END;

  IF (l_Return_Status IN ('E','U') ) THEN

    l_msg_data := l_msg_data ||'-'||SQLERRM;

    ROLLBACK TO BEFORE_UPDATE;

    UPDATE IGS_AD_INTERFACE_all
    SET    STATUS = '3',
           ERROR_CODE = 'E014'
    WHERE  INTERFACE_ID = P_person_rec.INTERFACE_ID;

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_002.update_person.exception'||'E014';

          l_debug_str :=  'IGS_AD_IMP_002.Update_Person ' || 'Error from IGS_PE_PERSON_PKG. HzMesg : '  || l_msg_data ||
                              ' Interface Id : ' || (P_person_rec.INTERFACE_ID) ||
                              ' Status : 3' ||  ' ErrorCode : E014';

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(P_person_rec.INTERFACE_ID,'E014','IGS_AD_INTERFACE_ALL');
    END IF;
    RETURN;

  ELSE
    UPDATE  IGS_AD_INTERFACE_all
    SET     STATUS = '1',
            ERROR_CODE = NULL --ssomani, added this 3/15/01
    WHERE   INTERFACE_ID = P_person_rec.INTERFACE_ID;

    COMMIT;
  END IF;


  DECLARE
    CURSOR check_addr_dup_cur(cp_person_id hz_party_sites.party_id%TYPE,
                                    cp_addr_rec addr_cur%ROWTYPE) IS
    SELECT site.location_id , site.party_site_id
    FROM   hz_locations loc, hz_party_sites site
    WHERE  site.party_id  = cp_person_id
              AND    site.location_id  = loc.location_id
              AND    UPPER(NVL(loc.address1,'X')) = UPPER(NVL(cp_addr_rec.addr_line_1,'X'))
              AND    UPPER(NVL(loc.address2,'X')) = UPPER(NVL(cp_addr_rec.addr_line_2,'X'))
              AND    UPPER(NVL(loc.address3,'X')) = UPPER(NVL(cp_addr_rec.addr_line_3,'X'))
              AND    UPPER(NVL(loc.address4,'X')) = UPPER(NVL(cp_addr_rec.addr_line_4,'X'))
              AND    UPPER(NVL(loc.city,'X'))     = UPPER(NVL(cp_addr_rec.city,'X'))
              AND    UPPER(NVL(loc.state,'X'))    = UPPER(NVL(cp_addr_rec.state,'X'))
              AND    loc.country           = cp_addr_rec.country
              AND     UPPER(NVL(loc.county,'X'))   = UPPER(NVL(cp_addr_rec.county,'X'))
              AND     UPPER(NVL(loc.province,'X')) = UPPER(NVL(cp_addr_rec.province,'X'));

    l_party_site_id   hz_party_sites.party_site_id%TYPE;

  BEGIN

    g_addr_process := FALSE;

    OPEN addr_cur(P_person_rec.Interface_Id);
    LOOP
      FETCH addr_cur INTO addr_rec;

      EXIT WHEN addr_cur%NOTFOUND;

      ADDR_REC.country := UPPER(ADDR_REC.country);
      l_location_id := NULL;

      OPEN check_addr_dup_cur(p_person_id,addr_rec);
      FETCH check_addr_dup_cur INTO l_location_id,l_party_site_id;
      CLOSE check_addr_dup_cur;

      IF l_location_id IS NOT NULL  THEN
      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

        IF (l_request_id IS NULL) THEN
          l_request_id := fnd_global.conc_request_id;
        END IF;

        l_label := 'igs.plsql.igs_ad_imp_002.update_person.duplicate_address_exists';
        l_debug_str := 'Interface Id : ' || P_person_rec.INTERFACE_ID;

        fnd_log.string_with_context( fnd_log.level_procedure,
                      l_label,
                      l_debug_str, NULL,
                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

        UPDATE_ADDRESS(   P_ADDR_REC   => ADDR_REC,
              P_PERSON_ID   => p_person_id,
              P_LOCATION_ID => l_location_id,
              p_party_site_id => l_party_site_id);
      ELSE
                                        -- Address not exists. Create it.
      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

        IF (l_request_id IS NULL) THEN
          l_request_id := fnd_global.conc_request_id;
        END IF;

        l_label := 'igs.plsql.igs_ad_imp_002.update_person.duplicate_address_doesnot_exist';
        l_debug_str := 'Interface Id : ' || P_person_rec.INTERFACE_ID;

        fnd_log.string_with_context( fnd_log.level_procedure,
                      l_label,
                      l_debug_str, NULL,
                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;


        CREATE_ADDRESS(P_addr_rec  => addr_rec,
            P_PERSON_ID =>p_person_id,
            P_STATUS=>L_STATUS,
            p_error_code=>L_ERROR_CODE);
      END IF;
    END LOOP;
    CLOSE addr_cur;

    IF g_addr_process THEN
      igs_pe_wf_gen.ti_addr_chg_persons(NVL(igs_pe_wf_gen.ti_addr_chg_persons.LAST,0)+1) := p_person_id;
    END IF;
  END;

  BEGIN
    OPEN api_cur(p_person_rec.interface_id);
    LOOP
      FETCH api_cur INTO api_rec;
      EXIT WHEN api_cur%NOTFOUND;

        api_rec.person_id_type := UPPER(api_rec.person_id_type);
        api_rec.alternate_id   := UPPER(api_rec.alternate_id);

        create_api(p_api_rec =>api_rec,
                   p_person_id =>p_person_id,
                   p_status =>l_status,
                   p_error_code => l_error_code);

        IF l_status = '3' THEN
          UPDATE igs_ad_api_int_all
          SET status = l_status,
              ERROR_CODE = l_error_code
          WHERE interface_api_id = api_rec.interface_api_id;
          UPDATE igs_ad_interface_all
          SET status = '4',
              ERROR_CODE = 'E007'
          WHERE interface_id = p_person_rec.interface_id;

      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(P_Person_Rec.Interface_Id,'E007','IGS_AD_INTERFACE_ALL');
      END IF;

        ELSIF l_status = '1' THEN

          UPDATE igs_ad_api_int_all
          SET status = '1',
            ERROR_CODE = NULL
          WHERE interface_api_id = api_rec.interface_api_id;

        END IF;
    END LOOP;
    CLOSE api_cur;
  END;
END UPDATE_PERSON;


PROCEDURE CREATE_API(p_api_rec IN IGS_AD_API_INT_ALL%ROWTYPE,
                     p_person_id IN  IGS_PE_PERSON.PERSON_ID%TYPE,
                     p_status OUT NOCOPY VARCHAR2,
                     p_error_code OUT NOCOPY VARCHAR2) AS

   /*
      ||  Created By : pkpatel
      ||  Created On : 10-JUN-2002
      ||  Purpose : Bug No:2402077 Validate the Person ID type and Format mask for Alternate ID
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
      ||  pkpatel        15-JAN-2003     Bug NO: 2397876
      ||                                 Added all the missing validations and replaced E008 with proper error codes
      ||  asbala         12-nov-03       3227107: address changes - signature of igs_pe_person_addr_pkg.insert_row changed
   */

  CURSOR source_type_cur(cp_source_type igs_pe_src_types_all.source_type%TYPE) Is
  SELECT source_type_id
  FROM  igs_pe_src_types_all
  WHERE source_type = cp_source_type;

  l_rowid VARCHAR2(25);
  lnDupExist NUMBER;
  l_start_dt IGS_AD_API_INT.START_DT%TYPE;
  l_message_name  VARCHAR2(30);
  l_app           VARCHAR2(50);
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_ucas_action          VARCHAR2(1);
  l_ucas_error_code VARCHAR2(10);
  l_call_ucas_user_hook BOOLEAN;
  l_source_type_id1 NUMBER;
  l_source_type_id2 NUMBER;

  FUNCTION validate_api(p_api_rec IN IGS_AD_API_INT_ALL%ROWTYPE )
    RETURN BOOLEAN AS
   /*
      ||  Created By : pkpatel
      ||  Created On : 10-JUN-2002
      ||  Purpose : Bug No:2402077 Validate the Person ID type and Format mask for Alternate ID
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  skpandey        09-Jan-2006     Changed the definition of region_cd_cur cursor as a part of New Geography Model
      ||  gmaheswa      29-Sep-2004     Bug:3787210 Added Closed indicator check for the Alternate Person Id type.
      ||  (reverse chronological order - newest change first)
   */

    l_exists  VARCHAR2(1);

    CURSOR api_type_cur(cp_person_id_type igs_pe_person_id_typ.person_id_type%TYPE) IS
    SELECT format_mask, region_ind
    FROM   igs_pe_person_id_typ
    WHERE  person_id_type = cp_person_id_type
    AND closed_ind = 'N';

    CURSOR region_cd_cur(cp_geography_type hz_geographies.geography_type%TYPE,
                         cp_geography_cd hz_geographies.geography_code%TYPE,
                         cp_country_cd hz_geographies.country_code%TYPE) IS
    SELECT 'X'
    FROM hz_geographies
    WHERE GEOGRAPHY_TYPE = cp_geography_type
    AND geography_code = cp_geography_cd
    AND country_code = cp_country_cd;

    api_type_rec  api_type_cur%ROWTYPE;
  BEGIN

           --validate Alternate Person ID descriptive Flex field
      IF NOT igs_ad_imp_018.validate_desc_flex(
                                 p_attribute_category =>p_api_rec.attribute_category,
                                 p_attribute1         =>p_api_rec.attribute1  ,
                                 p_attribute2         =>p_api_rec.attribute2  ,
                                 p_attribute3         =>p_api_rec.attribute3  ,
                                 p_attribute4         =>p_api_rec.attribute4  ,
                                 p_attribute5         =>p_api_rec.attribute5  ,
                                 p_attribute6         =>p_api_rec.attribute6  ,
                                 p_attribute7         =>p_api_rec.attribute7  ,
                                 p_attribute8         =>p_api_rec.attribute8  ,
                                 p_attribute9         =>p_api_rec.attribute9  ,
                                 p_attribute10        =>p_api_rec.attribute10 ,
                                 p_attribute11        =>p_api_rec.attribute11 ,
                                 p_attribute12        =>p_api_rec.attribute12 ,
                                 p_attribute13        =>p_api_rec.attribute13 ,
                                 p_attribute14        =>p_api_rec.attribute14 ,
                                 p_attribute15        =>p_api_rec.attribute15 ,
                                 p_attribute16        =>p_api_rec.attribute16 ,
                                 p_attribute17        =>p_api_rec.attribute17 ,
                                 p_attribute18        =>p_api_rec.attribute18 ,
                                 p_attribute19        =>p_api_rec.attribute19 ,
                                 p_attribute20        =>p_api_rec.attribute20 ,
                                 p_desc_flex_name     =>'IGS_PE_ALT_PERS_ID_FLEX' ) THEN

      p_error_code:='E255';
      RAISE NO_DATA_FOUND;
    END IF;

            --validate Person ID type
    OPEN  api_type_cur(p_api_rec.person_id_type);
    FETCH api_type_cur INTO api_type_rec;
    IF api_type_cur%NOTFOUND THEN
      CLOSE api_type_cur;
      p_error_code:='E258';
      RAISE NO_DATA_FOUND;
    ELSE
      CLOSE api_type_cur;
    END IF;

            -- Validate the format mask
    IF api_type_rec.format_mask IS NOT NULL THEN
      IF NOT igs_en_val_api.fm_equal(p_api_rec.alternate_id,api_type_rec.format_mask) THEN
        p_error_code:='E268';
        RAISE NO_DATA_FOUND;
      END IF;
    END IF;

          -- Validation for Region Code
    IF api_type_rec.region_ind IS NULL OR api_type_rec.region_ind = 'N' THEN
      IF p_api_rec.region_cd IS NOT NULL THEN
        p_error_code:='E573';
        RAISE NO_DATA_FOUND;
      END IF;
    ELSE
      IF p_api_rec.region_cd IS NULL THEN
        p_error_code:='E574';
        RAISE NO_DATA_FOUND;
      ELSE
        OPEN region_cd_cur('STATE',p_api_rec.region_cd,FND_PROFILE.VALUE('OSS_COUNTRY_CODE'));
        FETCH region_cd_cur INTO l_exists;
        IF region_cd_cur%NOTFOUND THEN
          CLOSE region_cd_cur;
          p_error_code:='E575';
          RAISE NO_DATA_FOUND;
        END IF;
        CLOSE region_cd_cur;
      END IF;
    END IF;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      p_status := '3';
      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;
            l_label := 'igs.plsql.igs_ad_imp_002.validate_api.exception'||p_error_code;
          l_debug_str :=  'Igs_Ad_Imp_002.Create_Api.validate_api'
                                   ||'Validation Failed'
                                   ||'Interface_Api_Id:'
                                   ||(p_api_rec.Interface_api_Id)
                                   ||' Status:3 '
                                   ||'Error Code: '||p_error_code ||' SQLERRM: '||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(p_api_rec.Interface_api_Id,p_error_code,'IGS_AD_API_INT_ALL');
    END IF;

      RETURN FALSE;
  END validate_api;

  BEGIN

    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_prog_label := 'igs.plsql.igs_ad_imp_002.create_api';
    l_label := 'igs.plsql.igs_ad_imp_002.create_api.';

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_002.create_api.begin';
    l_debug_str := 'start of create_api proc';

    fnd_log.string_with_context( fnd_log.level_procedure,
                  l_label,
                  l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  OPEN source_type_cur('UCAS PER');
  FETCH source_type_cur INTO l_source_type_id1;
  CLOSE source_type_cur;

  OPEN source_type_cur('UCAS APPL');
  FETCH source_type_cur INTO l_source_type_id2;
  CLOSE source_type_cur;

  IF ((l_source_type_id1 = Igs_Pe_Identify_Dups.g_source_type_id) OR (l_source_type_id2 = Igs_Pe_Identify_Dups.g_source_type_id))THEN
    -- source cat is UCAS PER / UCAS APPL.
    l_call_ucas_user_hook := TRUE;
  END IF;

  IF ((l_call_ucas_user_hook) AND (p_api_rec.person_id_type IN ('UCASID','NMASID','SWASID','GTTRID','UCASREGNO')))
  THEN
    igs_pe_pers_imp_001.validate_ucas_id(p_api_rec.alternate_id,p_person_id,p_api_rec.person_id_type,l_ucas_action,l_ucas_error_code);

    /* S - Skip record.   P - Process record.   E - Error out record.  */

    IF (l_ucas_action = 'S')
    THEN
      p_status := '1';
      p_error_code := null;
      RETURN;
    ELSIF (l_ucas_action = 'E')
    THEN
      p_status := '3';
      p_error_code := 'E560';
      RETURN;
    END IF;

  END IF;

      IF validate_api(p_api_rec) THEN

        IF p_api_rec.start_dt IS NULL THEN
          l_start_dt := TRUNC(SYSDATE);
        ELSE
          l_start_dt := TRUNC(p_api_rec.start_dt);
        END IF;

        IF (l_ucas_action = 'P')
        THEN
          lnDupExist := 0;
        ELSE
          SELECT COUNT(*)
          INTO   lnDupExist
          FROM   IGS_PE_ALT_PERS_ID
          WHERE  PE_PERSON_ID = P_PERSON_ID
            AND    API_PERSON_ID  = P_API_REC.ALTERNATE_ID
            AND    PERSON_ID_TYPE = P_API_REC.PERSON_ID_TYPE
            AND    TRUNC(START_DT) = l_start_dt;
        END IF;

        IF lnDupExist = 0 THEN

        BEGIN
        SAVEPOINT  before_insert;

        Igs_Pe_Alt_Pers_Id_Pkg.insert_row(
                  X_ROWID          => l_rowid,
                  X_PE_PERSON_ID   => P_PERSON_ID,
                  X_API_PERSON_ID  => p_api_rec.ALTERNATE_ID,
                  X_PERSON_ID_TYPE =>  p_api_rec.PERSON_ID_TYPE,
                  X_START_DT       => l_start_dt,
                  X_END_DT         =>  p_api_rec.end_dt,
                  x_attribute_category  => p_api_rec.attribute_category,
                  x_attribute1          => p_api_rec.attribute1,
                  x_attribute2          => p_api_rec.attribute2,
                  x_attribute3          => p_api_rec.attribute3,
                  x_attribute4          => p_api_rec.attribute4,
                  x_attribute5          => p_api_rec.attribute5,
                  x_attribute6          => p_api_rec.attribute6,
                  x_attribute7          => p_api_rec.attribute7,
                  x_attribute8          => p_api_rec.attribute8,
                  x_attribute9          => p_api_rec.attribute9,
                  x_attribute10         => p_api_rec.attribute10,
                  x_attribute11         => p_api_rec.attribute11,
                  x_attribute12         => p_api_rec.attribute12,
                  x_attribute13         => p_api_rec.attribute13,
                  x_attribute14         => p_api_rec.attribute14,
                  x_attribute15         => p_api_rec.attribute15,
                  x_attribute16         => p_api_rec.attribute16,
                  x_attribute17         => p_api_rec.attribute17,
                  x_attribute18         => p_api_rec.attribute18,
                  x_attribute19         => p_api_rec.attribute19,
                  x_attribute20         => p_api_rec.attribute20,
                  x_region_cd           => p_api_rec.region_cd,
                  X_MODE=>'R');
          p_status :='1';
          p_error_code:= NULL;
          RETURN;
        EXCEPTION
          WHEN OTHERS THEN

            ROLLBACK TO before_insert;
            FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

            IF l_message_name IN ('IGS_PE_PERS_ID_PRD_OVRLP', 'IGS_PE_SSN_PERS_ID_PRD_OVRLP') THEN
              p_error_code := 'E560';
              p_status := '3';
            ELSIF l_message_name = 'IGS_PE_UNIQUE_PID' THEN
              p_error_code := 'E567';
              p_status := '3';
            ELSIF l_message_name = 'IGS_AD_STRT_DT_LESS_BIRTH_DT' THEN
              p_error_code := 'E222';
              p_status := '3';
            ELSIF l_message_name = 'IGS_GE_INVALID_DATE' THEN
              p_error_code := 'E208';
              p_status := '3';
            ELSE
          p_error_code := 'E007';
          p_status := '3';
            END IF;

        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

          IF (l_request_id IS NULL) THEN
            l_request_id := fnd_global.conc_request_id;
          END IF;

          l_label := 'igs.plsql.igs_ad_imp_002.create_api.exception'||p_error_code;

          l_debug_str := 'IGS_AD_IMP_002.create_api ' ||'Interface Api Id : '
             || p_api_rec.interface_api_id ||' Status : 3 '
             ||  'ErrorCode : '||p_error_code||' SQLERRM:' ||  SQLERRM;

          fnd_log.string_with_context( fnd_log.level_exception,
                      l_label,
                      l_debug_str, NULL,
                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(p_api_rec.interface_api_id,p_error_code,'IGS_AD_API_INT_ALL');
        END IF;
            RETURN;
          END;
    ELSE

      DECLARE
    CURSOR c_null_hdlg_alt_pers_cur(cp_api_person_id igs_pe_alt_pers_id.api_person_id%TYPE,
                     cp_person_id_type igs_pe_alt_pers_id.person_id_type%TYPE,
                     cp_start_dt igs_pe_alt_pers_id.start_dt%TYPE,
                     cp_person_id igs_pe_alt_pers_id.pe_person_id%TYPE)IS
         SELECT api.rowid,api.*
         FROM   igs_pe_alt_pers_id api
         WHERE  pe_person_id = cp_person_id
     AND    api_person_id  = cp_api_person_id
     AND    person_id_type = cp_person_id_type
     AND    TRUNC(start_dt) = cp_start_dt;
     c_null_hdlg_alt_pers_cur_rec c_null_hdlg_alt_pers_cur%ROWTYPE;
     BEGIN
       SAVEPOINT before_api_update;
       OPEN  c_null_hdlg_alt_pers_cur(p_api_rec.alternate_id,
                     p_api_rec.person_id_type,
                     l_start_dt,
                     p_person_id);
      FETCH c_null_hdlg_alt_pers_cur INTO c_null_hdlg_alt_pers_cur_rec;
      CLOSE c_null_hdlg_alt_pers_cur;

      igs_pe_alt_pers_id_pkg.update_row(
       x_rowid              =>c_null_hdlg_alt_pers_cur_rec.rowid,
       x_pe_person_id       =>c_null_hdlg_alt_pers_cur_rec.pe_person_id,
       x_api_person_id      =>c_null_hdlg_alt_pers_cur_rec.api_person_id,
       x_person_id_type     => c_null_hdlg_alt_pers_cur_rec.person_id_type,
       x_start_dt           => NVL(p_api_rec.start_dt,c_null_hdlg_alt_pers_cur_rec.start_dt),
       x_end_dt             => NVL(p_api_rec.end_dt,c_null_hdlg_alt_pers_cur_rec.end_dt),
       x_mode               => 'R',
       X_ATTRIBUTE_CATEGORY =>NVL(p_api_rec.attribute_category  ,c_null_hdlg_alt_pers_cur_rec.attribute_category),
       X_ATTRIBUTE1         =>NVL(p_api_rec.attribute1  ,c_null_hdlg_alt_pers_cur_rec.attribute1),
       X_ATTRIBUTE2         =>NVL(p_api_rec.attribute2  ,c_null_hdlg_alt_pers_cur_rec.attribute2),
       X_ATTRIBUTE3         =>NVL(p_api_rec.attribute3  ,c_null_hdlg_alt_pers_cur_rec.attribute3),
       X_ATTRIBUTE4         =>NVL(p_api_rec.attribute4  ,c_null_hdlg_alt_pers_cur_rec.attribute4),
       X_ATTRIBUTE5         =>NVL(p_api_rec.attribute5  ,c_null_hdlg_alt_pers_cur_rec.attribute5),
       X_ATTRIBUTE6         =>NVL(p_api_rec.attribute6  ,c_null_hdlg_alt_pers_cur_rec.attribute6),
       X_ATTRIBUTE7         =>NVL(p_api_rec.attribute7  ,c_null_hdlg_alt_pers_cur_rec.attribute7),
       X_ATTRIBUTE8         =>NVL(p_api_rec.attribute8  ,c_null_hdlg_alt_pers_cur_rec.attribute8),
       X_ATTRIBUTE9         =>NVL(p_api_rec.attribute9  ,c_null_hdlg_alt_pers_cur_rec.attribute9),
       X_ATTRIBUTE10        =>NVL(p_api_rec.attribute10 ,c_null_hdlg_alt_pers_cur_rec.attribute10),
       X_ATTRIBUTE11        =>NVL(p_api_rec.attribute11 ,c_null_hdlg_alt_pers_cur_rec.attribute11),
       X_ATTRIBUTE12        =>NVL(p_api_rec.attribute12 ,c_null_hdlg_alt_pers_cur_rec.attribute12),
       X_ATTRIBUTE13        =>NVL(p_api_rec.attribute13 ,c_null_hdlg_alt_pers_cur_rec.attribute13),
       X_ATTRIBUTE14        =>NVL(p_api_rec.attribute14 ,c_null_hdlg_alt_pers_cur_rec.attribute14),
       X_ATTRIBUTE15        =>NVL(p_api_rec.attribute15 ,c_null_hdlg_alt_pers_cur_rec.attribute15),
       X_ATTRIBUTE16        =>NVL(p_api_rec.attribute16 ,c_null_hdlg_alt_pers_cur_rec.attribute16),
       X_ATTRIBUTE17        =>NVL(p_api_rec.attribute17 ,c_null_hdlg_alt_pers_cur_rec.attribute17),
       X_ATTRIBUTE18        =>NVL(p_api_rec.attribute18 ,c_null_hdlg_alt_pers_cur_rec.attribute18),
       X_ATTRIBUTE19        =>NVL(p_api_rec.attribute19 ,c_null_hdlg_alt_pers_cur_rec.attribute19),
       X_ATTRIBUTE20        =>NVL(p_api_rec.attribute20 ,c_null_hdlg_alt_pers_cur_rec.attribute20),
       X_REGION_CD          =>NVL(p_api_rec.region_cd   ,c_null_hdlg_alt_pers_cur_rec.region_cd));

    p_status :='1';
    p_error_code:= NULL;
    RETURN;

    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO before_api_update;
                   -- To find the message name raised from the TBH
        FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

        IF l_message_name IN ('IGS_PE_PERS_ID_PRD_OVRLP', 'IGS_PE_SSN_PERS_ID_PRD_OVRLP') THEN
          p_error_code := 'E560';
        ELSIF l_message_name = 'IGS_PE_ALT_END_DT_VAL' THEN
          p_error_code := 'E581';
        ELSIF l_message_name = 'IGS_AD_STRT_DT_LESS_BIRTH_DT' THEN
          p_error_code := 'E222';
        ELSIF l_message_name = 'IGS_GE_INVALID_DATE' THEN
          p_error_code := 'E208';
        ELSE
          p_error_code := 'E014';
        END IF;
    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
          IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
      END IF;

      l_label := 'igs.plsql.igs_ad_imp_002.create_api.exception1'||p_error_code;

      l_debug_str :=  'IGS_AD_IMP_002.create_api (UPDATE) ' ||'Interface Api Id : '
             || p_api_rec.interface_api_id ||'Status : 3'
         ||  'ErrorCode : '||p_error_code||' SQLERRM:' ||SQLERRM;

      fnd_log.string_with_context( fnd_log.level_exception,
                      l_label,
                      l_debug_str, NULL,
                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(p_api_rec.interface_api_id,p_error_code,'IGS_AD_API_INT_ALL');
    END IF;
    p_status := '3';
    RETURN;
      END;
    END IF;
  ELSE -- validation failed
    p_status :='3';
  END IF;
END create_api;

PROCEDURE CREATE_ADDRESS(P_addr_rec IN IGS_ad_Addr_int_all%ROWTYPE,
                         P_PERSON_ID IN  IGS_PE_PERSON.PERSON_ID%TYPE,
                         P_STATUS OUT NOCOPY VARCHAR2,
                        p_error_code OUT NOCOPY VARCHAR2) AS
  l_rowid VARCHAR2(25);
  l_return_status VARCHAR2(100);
  l_msg_data VARCHAR2(4000);
  l_location_id NUMBER;
  l_party_site_id NUMBER;
  l_party_site_use_id     NUMBER;
  l_last_update_date DATE;
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_party_site_ovn hz_party_sites.object_version_number%TYPE;
  l_location_ovn hz_locations.object_version_number%TYPE;

-- local procedure to check whether duplicate record exists for hz_party_site_uses for a party site id
PROCEDURE check_dup_addr_usage(l_party_site_id  IN HZ_PARTY_SITE_USES.PARTY_SITE_ID%TYPE,
                               l_site_use_code IN HZ_PARTY_SITE_USES.SITE_USE_TYPE%TYPE,
                               l_dup_var OUT NOCOPY VARCHAR2 ) AS

     l_var varchar2(5);

     CURSOR check_dup_cur(cp_party_site_id HZ_PARTY_SITE_USES.party_site_id%TYPE,
                          cp_site_use_code HZ_PARTY_SITE_USES.site_use_type%TYPE) IS
     SELECT 'X'
     FROM  HZ_PARTY_SITE_USES
     WHERE party_site_id = cp_party_site_id
     AND   site_use_type = cp_site_use_code;

 BEGIN
     OPEN  check_dup_cur(l_party_site_id,l_site_use_code);
     FETCH check_dup_cur INTO l_var;
       IF check_dup_cur%FOUND THEN
         l_dup_var := 'TRUE';
       ELSE
         l_dup_var := 'FALSE';
       END IF;
     CLOSE check_dup_cur;

END check_dup_addr_usage;

--- local procedure to import address usage
PROCEDURE process_addrusage(l_interface_addr_id IN igs_ad_addr_int.interface_addr_id%TYPE) AS

        CURSOR c_usage ( cp_interface_addr_id NUMBER) IS
        SELECT  *
        FROM    IGS_AD_ADDRUSAGE_INT_all
        WHERE   interface_addr_id = cp_interface_addr_id
        AND     status = '2';

        l_exists VARCHAR2(1);
        l_error_code  VARCHAR2(30);
        l_dup_var VARCHAR2(10);
        l_profile_last_update_date DATE;
        l_site_use_last_update_date DATE;
        l_interface_addrusage_id igs_ad_addrusage_int.interface_addrusage_id%TYPE;
        l_failure_child  NUMBER(3);
        l_object_version_number NUMBER;
BEGIN

  l_failure_child := 0;
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_002.create_address.process_addrusage_begin';
    l_debug_str := 'Interface Addr Id : ' || l_interface_addr_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  FOR c_usage_rec IN c_usage(l_interface_addr_id)
    LOOP
    BEGIN
    c_usage_rec.site_use_code := UPPER(c_usage_rec.site_use_code);
    l_interface_addrusage_id  := c_usage_rec.interface_addrusage_id;
    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('PARTY_SITE_USE_CODE',c_usage_rec.site_use_code,222))
    THEN
      l_error_code := 'E211';
      RAISE NO_DATA_FOUND;
    END IF;
    l_dup_var := NULL;
    check_dup_addr_usage(l_party_site_id , c_usage_rec.site_use_code,l_dup_var);

         IF l_dup_var = 'TRUE' THEN
            -- Update is not allowed in party site usage except the STATUS
            -- But there is no status column in the interface table hence removing
            -- the unnecessary update.
            UPDATE  IGS_AD_ADDRUSAGE_INT_all
            SET     STATUS = '1',
                ERROR_CODE = NULL
            WHERE   interface_addrusage_id = c_usage_rec.interface_addrusage_id;


         ELSIF l_dup_var = 'FALSE' THEN

        l_party_site_use_id := NULL;
        l_rowid := NULL;

        IGS_PE_PARTY_SITE_USE_PKG.HZ_PARTY_SITE_USES_AK(
            p_action                      => 'INSERT',
            p_rowid                       => l_rowid,
            p_party_site_use_id           => l_party_site_use_id,
            p_party_site_id               => l_party_site_id,
            p_site_use_type               => c_usage_rec.site_use_code,
            p_status                      => 'A',
            p_return_status               => l_return_status  ,
            p_msg_data                    => l_msg_data,
            p_last_update_date            => l_last_update_date,
            p_site_use_last_update_date   => l_site_use_last_update_date,
            p_profile_last_update_date    => l_profile_last_update_date,
            p_hz_party_site_use_ovn       => l_object_version_number
        );

        IF (l_return_status IN ('E','U') ) THEN

          l_error_code := 'E244';
          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_002.process_addrusage.exception'||'E224';

              l_debug_str :=  'Interface Address Usage ID: '||c_usage_rec.interface_addrusage_id||' HZMessage: '||l_msg_data||' SQLERRM:' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;
          RAISE NO_DATA_FOUND;
        ELSE
            UPDATE  IGS_AD_ADDRUSAGE_INT_ALL
            SET     STATUS = '1',
                ERROR_CODE = NULL
            WHERE   interface_addrusage_id = c_usage_rec.interface_addrusage_id;
        END IF;

        END IF;
       EXCEPTION
        WHEN NO_DATA_FOUND THEN

        l_failure_child := 1;

        UPDATE  IGS_AD_ADDRUSAGE_INT_ALL
        SET     STATUS = '3',
            ERROR_CODE = l_error_code
        WHERE   interface_addrusage_id = c_usage_rec.interface_addrusage_id;

          IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(l_interface_addrusage_id,l_error_code,'IGS_AD_ADDRUSAGE_INT_ALL');
          END IF;

       END;

  END LOOP;

    -- Update the parent if any of the child fails.
    IF l_failure_child = 1 THEN

    UPDATE  igs_ad_addr_int_all
    SET     status = '4',
        error_code = 'E244'
    WHERE   interface_addr_id = l_interface_addr_id;

    END IF;

  EXCEPTION
       WHEN OTHERS THEN
                UPDATE  IGS_AD_ADDRUSAGE_INT_ALL
                SET     STATUS = '3',
                        ERROR_CODE = 'E244'
                WHERE   interface_addrusage_id = l_interface_addrusage_id;

                UPDATE  igs_ad_addr_int_all
                SET     status = '4',
                        error_code = 'E244'
                WHERE   interface_addr_id = l_interface_addr_id;

          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_002.process_addrusage.exception'||'E244';

              l_debug_str :=  'IGS_AD_IMP_002.Create_Address.process_addrusage ' ||
                              'Error from process_addrusage ' ||
                                       ' for Interface addrusage Id : ' || (l_interface_addrusage_id) ||' '|| SQLERRM ;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(l_interface_addrusage_id,'E244','IGS_AD_ADDRUSAGE_INT_ALL');
        END IF;

 END process_addrusage;

BEGIN

    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_prog_label := 'igs.plsql.igs_ad_imp_002.create_address';
    l_label := 'igs.plsql.igs_ad_imp_002.create_address.';

    -- Call Log header
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_002.create_address.begin';
    l_debug_str := 'Start of create_address proc';

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

        /* Validate all columns before Inserting. */
        validate_address( p_addr_rec  => p_addr_rec,
                          p_person_id => p_person_id,
                          p_status    => p_status,
                          p_error_code  => p_error_code);

        IF ( p_status = '2' ) THEN

                IGS_PE_PERSON_ADDR_PKG.Insert_Row(
                                P_ACTION  => 'INSERT',
                                P_ROWID  => l_RowId,
                                P_LOCATION_ID  => l_location_Id,
                                P_START_DT  => p_addr_rec.Start_date,
                                P_END_DT => p_addr_rec.End_Date,
                                P_COUNTRY => p_addr_rec.country,
                                P_ADDRESS_STYLE => NULL,
                                P_ADDR_LINE_1  =>  p_addr_rec.addr_line_1,
                                P_ADDR_LINE_2  =>  p_addr_rec.addr_line_2,
                                P_ADDR_LINE_3  =>  p_addr_rec.addr_line_3,
                                P_ADDR_LINE_4  =>  p_addr_rec.addr_line_4,
                                P_DATE_LAST_VERIFIED  => p_addr_rec.Date_Last_Verified,
                                P_CORRESPONDENCE => p_addr_rec.CORRESPONDENCE_FLAG,
                                P_CITY  => p_addr_rec.city,
                                P_STATE  => p_addr_rec.state,
                                P_PROVINCE => p_addr_rec.province,
                                P_COUNTY => p_addr_rec.county,
                                P_POSTAL_CODE => p_addr_rec.postcode,
                                P_ADDRESS_LINES_PHONETIC => NULL,
                                P_DELIVERY_POINT_CODE => p_addr_rec.delivery_point_code,
                                P_OTHER_DETAILS_1 => p_addr_rec.other_details_1,
                                P_OTHER_DETAILS_2 => p_addr_rec.other_details_2,
                                P_OTHER_DETAILS_3 => p_addr_rec.other_details_3,
                                L_RETURN_STATUS => l_Return_Status,
                                L_MSG_DATA => l_Msg_Data,
                                P_PARTY_ID  => P_PERSON_ID,
                                P_PARTY_SITE_ID => l_Party_Site_Id,
                                P_PARTY_TYPE  => 'PERSON',
                                P_LAST_UPDATE_DATE => l_last_update_date,
                                p_party_site_ovn   => l_party_site_ovn,
                                p_location_ovn     => l_location_ovn,
                                p_status           => 'A'
                                );

                        IF (l_return_status IN ('E','U') ) THEN

                                UPDATE  IGS_AD_ADDR_INT_ALL
                                SET     STATUS = '3',
                                        ERROR_CODE = 'E006'
                                WHERE   INTERFACE_ADDR_ID = p_ADDR_REC.INTERFACE_ADDR_ID;

                                UPDATE   igs_ad_interface_all
                                SET      status = '4',
                                         error_code = 'E006'
                                WHERE    interface_id = p_addr_rec.interface_id;

                              IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                                IF (l_request_id IS NULL) THEN
                                  l_request_id := fnd_global.conc_request_id;
                                END IF;

                                l_label := 'igs.plsql.igs_ad_imp_002.create_address.exception'||'E006';

                                  l_debug_str :=  'IGS_AD_IMP_002.Create_Address '
                                || 'Error from IGS_PE_PERSON_ADDR_PKG.INSERT_ROW  HzMesg : '  || l_msg_data
                                || ' Interface Addr Id : ' || p_addr_rec.interface_addr_id
                                || ' Status : 3' ||  ' ErrorCode : E006';

                                fnd_log.string_with_context( fnd_log.level_exception,
                                              l_label,
                                              l_debug_str, NULL,
                                              NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                              END IF;

                            IF l_enable_log = 'Y' THEN
                              igs_ad_imp_001.logerrormessage(p_addr_rec.interface_addr_id,'E006','IGS_AD_ADDR_INT_ALL');
                            END IF;
                        ELSE
			   IF l_return_status = 'W' THEN
                                UPDATE  IGS_AD_ADDR_INT_ALL
                                SET     STATUS = '4',
                                        ERROR_CODE = 'E073'
                                WHERE   INTERFACE_ADDR_ID = p_ADDR_REC.INTERFACE_ADDR_ID;

                               IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                                IF (l_request_id IS NULL) THEN
                                  l_request_id := fnd_global.conc_request_id;
                                END IF;

                                l_label := 'igs.plsql.igs_ad_imp_002.create_address.warning'||'E073';

                                  l_debug_str :=  'IGS_AD_IMP_002.Create_Address '
                                || 'Warning from IGS_PE_PERSON_ADDR_PKG.INSERT_ROW  HzMesg : '  || l_msg_data
                                || ' Interface Addr Id : ' || p_addr_rec.interface_addr_id
                                || ' Status : 4' ||  ' ErrorCode : E073';

                                fnd_log.string_with_context( fnd_log.level_exception,
                                              l_label,
                                              l_debug_str, NULL,
                                              NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                              END IF;
                              IF l_enable_log = 'Y' THEN
                                  igs_ad_imp_001.logerrormessage(p_addr_rec.interface_addr_id,'E073','IGS_AD_ADDR_INT_ALL');
                              END IF;
			   ELSE
                                UPDATE  IGS_AD_ADDR_INT_ALL
                                SET     STATUS = '1',
                                        ERROR_CODE = NULL --ssomani, added this 3/15/01
                                WHERE   INTERFACE_ADDR_ID = P_ADDR_REC.INTERFACE_ADDR_ID;

                                p_status := '1';
                                p_error_code := NULL;
			   END IF;
                                g_addr_process := TRUE;
                                process_addrusage(p_addr_rec.interface_addr_id);

                        END IF;
        ELSE
               UPDATE  IGS_AD_ADDR_INT_ALL
               SET     STATUS = '3',
                        ERROR_CODE = p_error_code
               WHERE   INTERFACE_ADDR_ID = p_ADDR_REC.INTERFACE_ADDR_ID;

               UPDATE   igs_ad_interface_all
               SET      status = '4',
                        error_code = 'E006'
               WHERE    interface_id = p_addr_rec.interface_id;

      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(P_addr_REC.INTERFACE_addr_ID,'E006','IGS_AD_ADDR_INT_ALL');
      END IF;
                p_status := '3';
        END IF;
EXCEPTION
        WHEN OTHERS THEN
               l_msg_data := SQLERRM;
               p_status := '3';
               p_error_code := 'E006';

               UPDATE  IGS_AD_ADDR_INT_ALL
               SET     STATUS = '3',
                        ERROR_CODE = 'E006'
               WHERE   INTERFACE_ADDR_ID = p_ADDR_REC.INTERFACE_ADDR_ID;

               UPDATE   igs_ad_interface_all
               SET      status = '4',
                        error_code = 'E006'
               WHERE    interface_id = p_addr_rec.interface_id;

          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_002.create_address.exception'||'E006';

              l_debug_str :=  'IGS_AD_IMP_002.Create_Address '
                    || 'Error from IGS_PE_PERSON_ADDR_PKG .INSERT_ROW :'  || l_msg_data
                || ' Interface addr Id : ' || P_addr_REC.INTERFACE_addr_ID
            || ' Status : 3' ||  ' ErrorCode : E006';

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(P_addr_REC.INTERFACE_addr_ID,'E006','IGS_AD_ADDR_INT_ALL');
        END IF;

END CREATE_ADDRESS;


PROCEDURE UPDATE_ADDRESS(
                        p_addr_rec IN IGS_AD_ADDR_INT_ALL%ROWTYPE,
                        p_person_id IN  IGS_PE_PERSON.PERSON_ID%TYPE,
                        p_location_id IN hz_party_sites.location_id%TYPE,
                        p_party_site_id IN hz_party_sites.party_site_id%TYPE) AS

  l_rowid VARCHAR2(25);
  l_return_status VARCHAR2(100);
  l_msg_data VARCHAR2(4000);
  l_location_id    hz_party_sites.location_id%TYPE;
  l_party_site_id  hz_party_sites.party_site_id%TYPE;
  l_party_site_use_id          NUMBER;
  l_date hz_party_sites.last_update_date%TYPE;
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_party_site_ovn hz_party_sites.object_version_number%TYPE;
  l_location_ovn hz_locations.object_version_number%TYPE;


        CURSOR null_hand_addr_cur(cp_location_id IGS_PE_PERSON_ADDR_V.location_id%TYPE,
                              cp_party_site_id IGS_PE_PERSON_ADDR_V.party_site_id%TYPE)IS
        SELECT *
        FROM   IGS_PE_PERSON_ADDR_V
        WHERE location_id = cp_location_id AND
              party_site_id = cp_party_site_id;

        null_hand_addr_rec null_hand_addr_cur%ROWTYPE;
        l_last_update_date DATE;
        p_status VARCHAR2(1);
        p_error_code VARCHAR2(100);

-- local procedure to check whether duplicate record exists for hz_party_site_uses for a party site id
PROCEDURE check_dup_addr_usage(l_party_site_id  IN HZ_PARTY_SITE_USES.PARTY_SITE_ID%TYPE,
                               l_site_use_code IN HZ_PARTY_SITE_USES.SITE_USE_TYPE%TYPE,
                               l_dup_var OUT NOCOPY VARCHAR2 ) AS

     l_var VARCHAR2(5);

     CURSOR check_dup_cur (cp_party_site_id hz_party_site_uses.party_site_id%TYPE,
                           cp_site_use_code hz_party_site_uses.site_use_type%TYPE) IS
     SELECT 'X'
     FROM  HZ_PARTY_SITE_USES
     WHERE party_site_id = cp_party_site_id
     AND   site_use_type = cp_site_use_code;

 BEGIN
     OPEN  check_dup_cur(l_party_site_id,l_site_use_code);
     FETCH check_dup_cur INTO l_var;
       IF check_dup_cur%FOUND THEN
         l_dup_var := 'TRUE';
       ELSE
         l_dup_var := 'FALSE';
       END IF;
     CLOSE check_dup_cur;

END check_dup_addr_usage;

--- local procedure to import address usage
PROCEDURE process_addrusage(l_interface_addr_id IN igs_ad_addr_int.interface_addr_id%TYPE) AS

        CURSOR c_usage ( cp_interface_addr_id NUMBER) IS
        SELECT  *
        FROM    IGS_AD_ADDRUSAGE_INT_ALL
        WHERE   interface_addr_id = cp_interface_addr_id
        AND     status = '2';

        l_exists VARCHAR2(1);
        l_error_code  VARCHAR2(30);
        l_dup_var VARCHAR2(10);
        l_profile_last_update_date DATE;
        l_site_use_last_update_date DATE;
        l_interface_addrusage_id igs_ad_addrusage_int.interface_addrusage_id%TYPE;
        l_failure_child  NUMBER(3);
        l_object_version_number NUMBER;
BEGIN
  l_failure_child := 0;
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_006.update_address.process_addrusage_begin';
    l_debug_str := 'Interface addr Id : ' || l_interface_addr_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;


     FOR c_usage_rec IN c_usage(l_interface_addr_id)
         LOOP
               BEGIN
                    c_usage_rec.site_use_code := UPPER(c_usage_rec.site_use_code);
                    l_interface_addrusage_id  := c_usage_rec.interface_addrusage_id;
            IF NOT
            (igs_pe_pers_imp_001.validate_lookup_type_code('PARTY_SITE_USE_CODE',c_usage_rec.site_use_code,222))
            THEN
                      l_error_code := 'E211';
                      RAISE NO_DATA_FOUND;
                    END IF;
                    l_dup_var := NULL;
                    check_dup_addr_usage(l_party_site_id , c_usage_rec.site_use_code,l_dup_var);

                     IF l_dup_var = 'TRUE' THEN
                            -- Update is not allowed in party site usage except the STATUS
                            -- But there is no status column in the interface table hence removing
                            -- the unnecessary update.
                            UPDATE  IGS_AD_ADDRUSAGE_INT_ALL
                            SET     STATUS = '1',
                                    ERROR_CODE = NULL
                            WHERE   interface_addrusage_id = c_usage_rec.interface_addrusage_id;


                     ELSIF l_dup_var = 'FALSE' THEN

                        l_party_site_use_id := NULL;
                        l_rowid := NULL;

                        IGS_PE_PARTY_SITE_USE_PKG.HZ_PARTY_SITE_USES_AK(
                                p_action                      => 'INSERT',
                                p_rowid                       => l_rowid,
                                p_party_site_use_id           => l_party_site_use_id,
                                p_party_site_id               => l_party_site_id,
                                p_site_use_type               => c_usage_rec.site_use_code,
                                p_status                      => 'A',
                                p_return_status               => l_return_status  ,
                                p_msg_data                    => l_msg_data,
                                p_last_update_date            => l_last_update_date,
                                p_site_use_last_update_date   => l_site_use_last_update_date,
                                p_profile_last_update_date    => l_profile_last_update_date,
                                p_hz_party_site_use_ovn       => l_object_version_number
                        );

                        IF (l_return_status IN ('E','U') ) THEN

                          l_error_code := 'E244';
              IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                IF (l_request_id IS NULL) THEN
                  l_request_id := fnd_global.conc_request_id;
                END IF;

                l_label := 'igs.plsql.igs_ad_imp_002.process_addrusage.exception'||'E244';

                  l_debug_str :=  'Interface Address Usage ID: '||c_usage_rec.interface_addrusage_id||'HZMess: '||l_msg_data||' SQLERRM: '||  SQLERRM;

                fnd_log.string_with_context( fnd_log.level_exception,
                              l_label,
                              l_debug_str, NULL,
                              NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
              END IF;
                          RAISE NO_DATA_FOUND;
                        ELSE
                                UPDATE  IGS_AD_ADDRUSAGE_INT_ALL
                                SET     STATUS = '1',
                                        ERROR_CODE = NULL
                                WHERE   interface_addrusage_id = c_usage_rec.interface_addrusage_id;
                        END IF;

                    END IF;
               EXCEPTION
                    WHEN NO_DATA_FOUND THEN

                        l_failure_child := 1;

                        UPDATE  IGS_AD_ADDRUSAGE_INT_ALL
                        SET     STATUS = '3',
                                ERROR_CODE = l_error_code
                        WHERE   interface_addrusage_id = c_usage_rec.interface_addrusage_id;

              IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(l_interface_addrusage_id,l_error_code,'IGS_AD_ADDRUSAGE_INT_ALL');
              END IF;

               END;

         END LOOP;

            -- Update the parent if any of the child fails.
            IF l_failure_child = 1 THEN

                UPDATE  igs_ad_addr_int_all
                SET     status = '4',
                        error_code = 'E244'
                WHERE   interface_addr_id = l_interface_addr_id;

            END IF;

  EXCEPTION
       WHEN OTHERS THEN
                UPDATE  IGS_AD_ADDRUSAGE_INT_ALL
                SET     STATUS = '3',
                        ERROR_CODE = 'E244'
                WHERE   interface_addrusage_id = l_interface_addrusage_id;

                UPDATE  igs_ad_addr_int_all
                SET     status = '4',
                        error_code = 'E244'
                WHERE   interface_addr_id = l_interface_addr_id;

          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_002.process_addrusage.exception'||'E244';

              l_debug_str := 'IGS_AD_IMP_002.Create_Address.process_addrusage ' ||
                    'Error from process_addrusage ' ||
                    ' for Interface addrusage Id : ' || (l_interface_addrusage_id) ||' '|| SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(l_interface_addrusage_id,'E244','IGS_AD_ADDRUSAGE_INT_ALL');
        END IF;

 END process_addrusage;

BEGIN

    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_prog_label := 'igs.plsql.igs_ad_imp_002.update_address';
    l_label := 'igs.plsql.igs_ad_imp_002.update_address.';
    l_location_id := p_location_id;
    l_party_site_id := p_party_site_id;
    p_status := '2';

    -- Call Log header
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_002.Update_Address.begin';
    l_debug_str := 'start of update_address';

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

        validate_address( p_addr_rec  => p_addr_rec,
                          p_person_id => p_person_id,
                          p_status => p_status,
                          p_error_code  => p_error_code);

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_002.validate_address.exception'||p_error_code;

          l_debug_str :=  'p_status :'||p_status||'p_error_code :'||p_error_code;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;


        IF p_status = '3' THEN
            RAISE NO_DATA_FOUND;
        END IF;

        IF p_status = '2' THEN


            OPEN null_hand_addr_cur(p_location_id,p_party_site_id);
            FETCH null_hand_addr_cur INTO null_hand_addr_rec;
                IF null_hand_addr_cur%NOTFOUND THEN
                  CLOSE null_hand_addr_cur;
                  RAISE NO_DATA_FOUND;
                END IF;
            CLOSE null_hand_addr_cur;

        l_location_ovn := null_hand_addr_rec.location_ovn;
        l_party_site_ovn := null_hand_addr_rec.party_site_ovn;
        l_location_id    := p_location_id;
        l_party_site_id  := p_party_site_id;

        IGS_PE_PERSON_ADDR_PKG.Update_Row(
                        P_ACTION  => 'UPDATE',
                        P_ROWID  => l_RowId,
                        P_LOCATION_ID  => l_location_Id,
                        P_START_DT  => nvl(p_addr_rec.Start_date,null_hand_addr_rec.start_dt),
                        P_END_DT => nvl(p_addr_rec.End_Date,null_hand_addr_rec.end_dt),
                        P_COUNTRY => p_addr_rec.country,
                        P_ADDRESS_STYLE => NULL,
                        P_ADDR_LINE_1  =>  nvl(p_addr_rec.addr_line_1,null_hand_addr_rec.addr_line_1),
                        P_ADDR_LINE_2  =>  nvl(p_addr_rec.addr_line_2,null_hand_addr_rec.addr_line_2),
                        P_ADDR_LINE_3  =>  nvl(p_addr_rec.addr_line_3,null_hand_addr_rec.addr_line_3),
                        P_ADDR_LINE_4  =>  nvl(p_addr_rec.addr_line_4,null_hand_addr_rec.addr_line_4),
                        P_DATE_LAST_VERIFIED  => nvl(p_addr_rec.Date_Last_Verified,null_hand_addr_rec.date_last_verified),
                        P_CORRESPONDENCE => nvl(p_addr_rec.CORRESPONDENCE_FLAG,null_hand_addr_rec. CORRESPONDENCE_IND),
                        P_CITY  => nvl(p_addr_rec.city,null_hand_addr_rec.city),
                        P_STATE  => nvl(p_addr_rec.state,null_hand_addr_rec.state),
                        P_PROVINCE => nvl(p_addr_rec.province,null_hand_addr_rec.province),
                        P_COUNTY => nvl(p_addr_rec.county,null_hand_addr_rec.county),
                        P_POSTAL_CODE => nvl(p_addr_rec.postcode,null_hand_addr_rec.postal_code),
                        P_ADDRESS_LINES_PHONETIC => NULL,
                        P_DELIVERY_POINT_CODE => nvl(p_addr_rec.delivery_point_code,null_hand_addr_rec.delivery_point_code),
                        P_OTHER_DETAILS_1 => nvl(p_addr_rec.other_details_1,null_hand_addr_rec.other_details_1),
                        P_OTHER_DETAILS_2 => nvl(p_addr_rec.other_details_2,null_hand_addr_rec.other_details_2),
                        P_OTHER_DETAILS_3 => nvl(p_addr_rec.other_details_3,null_hand_addr_rec.other_details_3),
                        L_RETURN_STATUS => l_Return_Status,
                        L_MSG_DATA => l_Msg_Data,
                        P_PARTY_ID  => P_PERSON_ID,
                        P_PARTY_SITE_ID => l_party_site_id,
                        P_PARTY_TYPE  => 'PERSON',
                        P_LAST_UPDATE_DATE => l_date,
                        p_party_site_ovn => l_location_ovn,
                        p_location_ovn   => l_party_site_ovn,
                        p_status         => null_hand_addr_rec.status
                  );
         IF (l_return_status IN ('E','U') ) THEN

                UPDATE  igs_ad_addr_int_all
                SET     status = '3', error_code = 'E014'
                WHERE   interface_addr_id = p_addr_rec.interface_addr_id;

                UPDATE  igs_ad_interface_all
                SET     status = '4', error_code = 'E014'
                WHERE   interface_id = p_addr_rec.interface_id;

                p_error_code := 'E014';
                  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                    IF (l_request_id IS NULL) THEN
                      l_request_id := fnd_global.conc_request_id;
                    END IF;

                    l_label := 'igs.plsql.igs_ad_imp_002.update_address.exception'||p_error_code;

                      l_debug_str :=  'IGS_AD_IMP_002.Update_Address ' || 'Error from IGS_PE_PERSON_ADDRESS_PKG : HzMesg'
                                 || l_msg_data || ' Interface Addr Id : '
                                         || (P_addr_REC.INTERFACE_ADDR_ID)  ||' Status : 3' ||  ' ErrorCode : E014 ';

                    fnd_log.string_with_context( fnd_log.level_exception,
                                  l_label,
                                  l_debug_str, NULL,
                                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                  END IF;

                IF l_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(P_addr_REC.INTERFACE_ADDR_ID,p_error_code,'IGS_AD_ADDR_INT_ALL');
                END IF;
	  ELSE
	     IF l_return_status = 'W' THEN
                UPDATE  igs_ad_addr_int_all
                SET     status = '4', error_code = 'E073'
                WHERE   interface_addr_id = p_addr_rec.interface_addr_id;

                p_error_code := 'E073';
                IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                    IF (l_request_id IS NULL) THEN
                      l_request_id := fnd_global.conc_request_id;
                    END IF;

                    l_label := 'igs.plsql.igs_ad_imp_002.update_address.warning'||p_error_code;

                    l_debug_str :=  'IGS_AD_IMP_002.Update_Address ' || 'Warning from IGS_PE_PERSON_ADDRESS_PKG : HzMesg'
                                 || l_msg_data || ' Interface Addr Id : '
                                         || (P_addr_REC.INTERFACE_ADDR_ID)  ||' Status : 4' ||  ' ErrorCode : E073';

                    fnd_log.string_with_context( fnd_log.level_exception,
                                  l_label,
                                  l_debug_str, NULL,
                                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                  END IF;

                IF l_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(P_addr_REC.INTERFACE_ADDR_ID,p_error_code,'IGS_AD_ADDR_INT_ALL');
                END IF;
	     ELSE
                UPDATE  igs_ad_addr_int_all
                SET     status = '1',
                        ERROR_CODE = NULL
                WHERE   interface_addr_id = p_addr_rec.interface_addr_id;
	     END IF;
                g_addr_process := TRUE;
                process_addrusage(p_addr_rec.interface_addr_id);

          END IF;

        END IF;
EXCEPTION
        WHEN OTHERS THEN

        l_msg_data := SQLERRM;
        UPDATE  igs_ad_addr_int_all
        SET     status = '3', error_code = p_error_code
        WHERE   interface_addr_id = p_addr_rec.interface_addr_id;

        UPDATE  igs_ad_interface_all
        SET     status = '4', error_code = 'E014'
        WHERE   interface_id = p_addr_rec.interface_id;

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_002.update_address.exception'||'E014';

          l_debug_str :=  'IGS_AD_IMP_002.Update_Address ' || 'Exception from IGS_PE_PERSON_ADDRESS_PKG : HzMesg '
                          || l_msg_data || ' Interface Addr Id : '
                      || (P_addr_REC.INTERFACE_ADDR_ID)  || ' Status : 3' ||
                  ' ErrorCode : '||p_error_code;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(P_addr_REC.INTERFACE_ADDR_ID,'E014','IGS_AD_ADDR_INT_ALL');
    END IF;

END UPDATE_ADDRESS;


PROCEDURE prc_pe_dtls(p_d_batch_id IN NUMBER,
                      p_d_source_type_id IN NUMBER,
                      p_match_set_id     IN NUMBER)
AS
 /*
  ||  Created By : nsinha
  ||  Created On : 22-jun-2001
  ||  Purpose : This procedure process the person details.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel        22-Jun-2001     For Modeling and Forecasting DLD modified the code
  ||                                  to handle the details level descripancy rule.
  ||                                 Modified all SELECT Query into Cursors.
  ||  pkpatel        25-DEC-2002     Bug No: 2702536
  ||                                 Added the new duplicate checking process. This will happen for each record, instead of at batch level
  ||  asbala          23-SEP-2003    Bug 3130316, Duplicate Person Matching Performance Improvements
  ||  pkpatel        23-Feb-2006     Bug 4869740 (Modified the datatype in cursor c_get_global_var for cp_match_set_id)
  ||  (reverse chronological order - newest change first)
  */
  l_lvcAction       VARCHAR2(1);
  l_lvcRecordExist  VARCHAR2(1);
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_int_pk_where_clause VARCHAR2(2000);
  l_ad_pk_where_clause  VARCHAR2(2000);
  l_discrepancy_exists  BOOLEAN;
  l_attribute_action    VARCHAR2(1);
  l_default_date  DATE;
  l_person_id           igs_ad_interface.person_id%TYPE;

        -- cursor to populate global variable g_partial_if_null and g_primary_addr_flag
  CURSOR c_get_global_var(cp_match_set_id igs_pe_match_sets_all.match_set_id%TYPE) IS
  SELECT partial_if_null,primary_addr_flag, exclude_inactive_ind
  FROM igs_pe_match_sets_all
  WHERE match_set_id = cp_match_set_id;

  CURSOR c_matchset_data_cur(cp_match_set_id igs_pe_mtch_set_data_all.match_set_id%TYPE) IS
  SELECT data_element, drop_if_null, partial_include, exact_include
  FROM igs_pe_mtch_set_data_all
  WHERE match_set_id = cp_match_set_id;

        --Bug no.1834307 MOdified the source table from igs_ad_interface to igs_ad_interface_dtl_dscp_v
  CURSOR  person_cur(cp_d_batch_id igs_ad_interface_dtl_dscp_v.batch_id%TYPE,
                       cp_d_source_type_id igs_ad_interface_dtl_dscp_v.source_type_id%TYPE) IS
  SELECT  ai.*
  FROM    igs_ad_interface_dtl_dscp_v ai
  WHERE   status = '2'
    AND     batch_id = cp_d_batch_id
    AND     source_type_id = cp_d_source_type_id;

        -- Cursor for Null handling Rule
  CURSOR  c_null_hdlg_per_cur(cp_person_id igs_pe_person.person_id%TYPE) IS
  SELECT
  p.person_last_name surname,
  p.person_first_name given_names,
  p.person_middle_name middle_name,
  p.person_name_suffix suffix,
  p.person_pre_name_adjunct pre_name_adjunct,
  p.person_title title,
  p.known_as preferred_given_name,
  pd.level_of_qual level_of_qual_id,
  pp.gender sex,
  pp.date_of_birth birth_dt
  FROM
  hz_parties p,
  igs_pe_hz_parties pd,
  hz_person_profiles pp
  WHERE p.party_id = cp_person_id
  AND p.party_id  = pd.party_id (+)
  AND p.party_id = pp.party_id
  AND SYSDATE BETWEEN pp.effective_start_date AND NVL(pp.effective_end_date,SYSDATE);

  CURSOR Status_cur(cp_interface_id IGS_AD_INTERFACE_ALL.INTERFACE_ID%TYPE) IS
  SELECT status
  FROM IGS_AD_INTERFACE_all
  WHERE  interface_id = cp_interface_id;

        -- Cursor to check whether the set up is done for Address type/person id type in th ematch set.
  CURSOR addr_personid_type_cur(cp_match_set_id igs_pe_mtch_set_data.match_set_id%TYPE,
                                  cp_type igs_pe_mtch_set_data.data_element%TYPE) IS
  SELECT  value
  FROM    igs_pe_mtch_set_data md
  WHERE   match_set_id = cp_match_set_id
    AND   md.data_element =cp_type;


        --Cursor for record level Review
  CURSOR  discrepancy_exist_cur(cp_person_id igs_pe_person.person_id%TYPE,
                                  c_person_rec person_cur%ROWTYPE) IS
  SELECT     'X'
  FROM hz_parties p,
       igs_pe_hz_parties pd,
       hz_person_profiles pp,
       igs_pe_person_id_type_v pit
  WHERE p.party_id  = cp_person_id
    AND p.party_id  = pit.pe_person_id (+)
    AND p.party_id  = pd.party_id (+)
    AND p.party_id  = pp.party_id
    AND SYSDATE BETWEEN pp.effective_start_date AND NVL(pp.effective_end_date,SYSDATE)
    AND NVL(p.person_last_name, '*')     = NVL(c_person_rec.surname, '*')
    AND NVL(p.person_first_name, '*') = NVL(c_person_rec.given_names, '*')
    AND NVL(p.person_name_suffix, '*')      = NVL(c_person_rec.suffix, '*')
    AND NVL(pp.gender, '*')         = NVL(c_person_rec.sex, '*')
    AND NVL(p.person_title, '*')       = NVL(c_person_rec.title, '*')
    AND NVL(pp.date_of_birth, l_default_date)  = NVL(c_person_rec.birth_dt, l_default_date)
    AND NVL(pd.proof_of_ins, '*')         = NVL(c_person_rec.proof_of_ins, '*')
    AND NVL(pd.proof_of_immu, '*')        = NVL(c_person_rec.proof_of_immu, '*')
    AND NVL(pd.level_of_qual, -99)     = NVL(c_person_rec.level_of_qual_id, -99)
    AND NVL(pd.military_service_reg, '*') = NVL(c_person_rec.military_service_reg, '*')
    AND NVL(pd.veteran, '*')              = NVL(c_person_rec.veteran, '*')
    AND NVL(p.known_as, '*') = NVL(c_person_rec.preferred_given_name, '*')
    AND NVL(p.attribute_category, '*')   = NVL(c_person_rec.attribute_category, '*')
    AND NVL(p.person_middle_name,'*')           = NVL(c_person_rec.middle_name,'*')
    AND NVL(p.person_pre_name_adjunct,'*')      = NVL(c_person_rec.pre_name_adjunct,'*')
    AND NVL(p.attribute1, '*') = NVL(c_person_rec.attribute1, '*')
    AND NVL(p.attribute2, '*') = NVL(c_person_rec.attribute2, '*')
    AND NVL(p.attribute3, '*') = NVL(c_person_rec.attribute3, '*')
    AND NVL(p.attribute4, '*') = NVL(c_person_rec.attribute4, '*')
    AND NVL(p.attribute5, '*') = NVL(c_person_rec.attribute5, '*')
    AND NVL(p.attribute6, '*') = NVL(c_person_rec.attribute6, '*')
    AND NVL(p.attribute7, '*') = NVL(c_person_rec.attribute7, '*')
    AND NVL(p.attribute8, '*') = NVL(c_person_rec.attribute8, '*')
    AND NVL(p.attribute9, '*') = NVL(c_person_rec.attribute9, '*')
    AND NVL(p.attribute10, '*') = NVL(c_person_rec.attribute10, '*')
    AND NVL(p.attribute11, '*') = NVL(c_person_rec.attribute11, '*')
    AND NVL(p.attribute12, '*') = NVL(c_person_rec.attribute12, '*')
    AND NVL(p.attribute13, '*') = NVL(c_person_rec.attribute13, '*')
    AND NVL(p.attribute14, '*') = NVL(c_person_rec.attribute14, '*')
    AND NVL(p.attribute15, '*') = NVL(c_person_rec.attribute15, '*')
    AND NVL(p.attribute16, '*') = NVL(c_person_rec.attribute16, '*')
    AND NVL(p.attribute17, '*') = NVL(c_person_rec.attribute17, '*')
    AND NVL(p.attribute18, '*') = NVL(c_person_rec.attribute18, '*')
    AND NVL(p.attribute19, '*') = NVL(c_person_rec.attribute19, '*')
    AND NVL(p.attribute20, '*') = NVL(c_person_rec.attribute20, '*')
    AND NVL(p.attribute21, '*') = NVL(c_person_rec.attribute21, '*')
    AND NVL(p.attribute22, '*') = NVL(c_person_rec.attribute22, '*')
    AND NVL(p.attribute23, '*') = NVL(c_person_rec.attribute23, '*')
    AND NVL(p.attribute24, '*') = NVL(c_person_rec.attribute24, '*')
    AND NVL(pd.felony_convicted_flag, '*') = NVL(c_person_rec.felony_convicted_flag, '*')
    AND NVL(pd.birth_city, '*') = NVL(c_person_rec.birth_city, '*')
    AND NVL(pd.birth_country, '*') = NVL(c_person_rec.birth_country, '*')
    AND NVL(pit.api_person_id, '*') = NVL(c_person_rec.pref_alternate_id, '*');

    c_null_hdlg_per_rec   c_null_hdlg_per_cur%ROWTYPE;
    person_rec            person_cur%ROWTYPE;
    status_rec            status_cur%ROWTYPE;
    get_global_var_rec    c_get_global_var%ROWTYPE;
    matchset_data_rec     c_matchset_data_cur%ROWTYPE;
    l_count_exact         NUMBER;
    l_count_partial       NUMBER;
    l_addrtype            igs_pe_mtch_set_data.VALUE%TYPE;
    l_personidtype        igs_pe_mtch_set_data.VALUE%TYPE;
    l_match_ind           igs_ad_interface.match_ind%TYPE;

  BEGIN

    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_prog_label := 'igs.plsql.igs_ad_imp_002.prc_pe_dtls';
    l_label := 'igs.plsql.igs_ad_imp_002.prc_pe_dtls.';
       -- populate global variables
    Igs_Pe_Identify_Dups.g_match_set_id   := p_match_set_id;
    Igs_Pe_Identify_Dups.g_source_type_id := p_d_source_type_id;
    l_default_date  := TRUNC(SYSDATE);
    l_addrtype      := NULL;
    l_personidtype  := NULL;

    OPEN c_get_global_var(p_match_set_id);
    FETCH c_get_global_var INTO get_global_var_rec;
       Igs_Pe_Identify_Dups.g_partial_if_null := get_global_var_rec.partial_if_null;
       Igs_Pe_Identify_Dups.g_primary_addr_flag := get_global_var_rec.primary_addr_flag;
       Igs_Pe_Identify_Dups.g_exclude_inactive_ind := get_global_var_rec.exclude_inactive_ind;
    CLOSE c_get_global_var;

    l_count_exact := 1;
    l_count_partial := 1;

    FOR matchset_data_rec IN c_matchset_data_cur(p_match_set_id) LOOP
      IF matchset_data_rec.data_element NOT IN ('SURNAME','GIVEN_NAME_1_CHAR') THEN
        IF matchset_data_rec.exact_include = 'Y' THEN
          Igs_Pe_Identify_Dups.g_matchset_exact(l_count_exact).data_element := matchset_data_rec.data_element;
          Igs_Pe_Identify_Dups.g_matchset_exact(l_count_exact).drop_if_null := matchset_data_rec.drop_if_null;
          l_count_exact := l_count_exact + 1;
        END IF;
        IF matchset_data_rec.partial_include = 'Y' THEN
          Igs_Pe_Identify_Dups.g_matchset_partial(l_count_partial).data_element := matchset_data_rec.data_element;
          Igs_Pe_Identify_Dups.g_matchset_partial(l_count_partial).drop_if_null := matchset_data_rec.drop_if_null;
          l_count_partial := l_count_partial + 1;
        END IF;

        IF matchset_data_rec.data_element = 'ADDR_TYPE' THEN
          Igs_Pe_Identify_Dups.g_addr_type_din := matchset_data_rec.drop_if_null;
        END IF;
        IF matchset_data_rec.data_element = 'PERSON_ID_TYPE' THEN
          Igs_Pe_Identify_Dups.g_person_id_type_din := matchset_data_rec.drop_if_null;
        END IF;
      END IF;
    END LOOP;

    OPEN addr_personid_type_cur(p_match_set_id,'ADDR_TYPE');
    FETCH addr_personid_type_cur INTO l_addrtype;
    CLOSE addr_personid_type_cur;

    OPEN addr_personid_type_cur(p_match_set_id,'PERSON_ID_TYPE');
    FETCH addr_personid_type_cur INTO l_personidtype;
    CLOSE addr_personid_type_cur;

    l_lvcAction := Igs_Ad_Imp_001.FIND_SOURCE_CAT_RULE(p_d_source_type_id,'PERSON');
    IF l_lvcAction = 'D' THEN
      -- Get the attribute level discrepancy rule.
      l_attribute_action := Igs_Ad_Imp_023.find_attribute_rule(
                                     p_source_type_id => p_d_source_type_id,
                                     p_category => 'PERSON');
    END IF;


         -- Open the cursor and iterate on the cursor
    OPEN person_cur(p_d_batch_id,p_d_source_type_id);
    LOOP
      FETCH person_cur INTO person_rec;
      EXIT WHEN person_cur%NOTFOUND;

      l_match_ind := person_rec.match_ind;
            -- Call the procedure Identify Imports Duplicate Record.
      Igs_Ad_Imp_009.IGS_AD_IMP_FIND_DUP_PERSONS(
                p_d_batch_id,
                p_d_source_type_id ,
                p_match_set_id,
                person_rec.interface_id,
                l_match_ind,
                l_person_id,
                l_addrtype,
                l_personidtype);


       person_rec.pre_name_adjunct := UPPER(person_rec.pre_name_adjunct);
       person_rec.Sex := UPPER(person_rec.Sex);
       person_rec.veteran := UPPER(person_rec.veteran);
       person_rec.PROOF_OF_INS := UPPER(person_rec.PROOF_OF_INS);
       person_rec.PROOF_OF_IMMU  := UPPER(person_rec.PROOF_OF_IMMU );
       person_rec.MILITARY_SERVICE_REG := UPPER(person_rec.MILITARY_SERVICE_REG);
       person_rec.PREF_ALTERNATE_ID := UPPER(person_rec.PREF_ALTERNATE_ID);
       person_rec.birth_country := UPPER(person_rec.birth_country);

    IF l_match_ind IN ('12','15') THEN  --12 -Match To Single Person

        IF l_match_ind = '15' THEN
           l_person_id := person_rec.person_id;
        END IF;

        IF l_lvcAction = 'E' THEN
            UPDATE igs_ad_interface_all
            SET person_match_ind = cst_mi_val_19,  --19 -Match exists and retained existing values
                status = cst_stat_val_1,
                ERROR_CODE = NULL --ssomani, added this 3/15/01
            WHERE interface_id = person_rec.interface_id;

        ELSIF l_lvcAction = 'I' THEN

            update_person
            (p_person_rec=>person_rec,
            p_addr_type=> NULL ,
            p_person_id_type=> NULL ,
            p_person_id=> l_person_id);

            OPEN status_cur(person_rec.interface_id);
            FETCH status_cur INTO status_rec;
            IF status_cur%FOUND THEN
              IF status_rec.status = '1' THEN
                UPDATE   igs_ad_interface_all
                SET person_match_ind = cst_mi_val_18,  --18 -Match occured and used import values
                    status = cst_stat_val_1,
                    ERROR_CODE = NULL
                WHERE interface_id = person_rec.interface_id;
              END IF;
            END IF;
            CLOSE status_cur;

        ELSIF l_lvcAction = 'R' THEN
            IF person_rec.person_match_ind = '21' THEN  --21 -Match reviewed and to be imported

                  update_person (p_person_rec=>person_rec,
                          p_addr_type=> NULL ,
                          p_person_id_type=> NULL ,
                          p_person_id=>l_person_id);

                  OPEN status_cur(person_rec.interface_id);
                  FETCH status_cur INTO status_rec;
                  IF status_cur%FOUND THEN
                     IF status_rec.status = '1' THEN
                       UPDATE   igs_ad_interface_all
                       SET person_match_ind = cst_mi_val_18,  --18 -Match occured and used import values
                       status = cst_stat_val_1,
                       ERROR_CODE = NULL
                       WHERE interface_id = person_rec.interface_id;
                     END IF;
                  END IF;
                  CLOSE status_cur;

            ELSIF NVL(person_rec.person_match_ind,'-1')  NOT IN('20','23') THEN  --20 - Match To Be Reviewed For Discrepancy
                                           --23 - Match to be reviewed, but there was no discrepancy
                                           --      and so retaining the existing values
            --Bug no.1834307 :Added the primary key where clause and modified the Default values in the NVL
                BEGIN
                    OPEN   discrepancy_exist_cur(l_person_id,person_rec);
                    FETCH  discrepancy_exist_cur  INTO  l_lvcrecordexist;
                    IF  discrepancy_exist_cur%NOTFOUND  THEN
                       RAISE  NO_DATA_FOUND;
                    END IF;
                    CLOSE  discrepancy_exist_cur;

                    UPDATE igs_ad_interface_all
                    SET person_match_ind = cst_mi_val_23, --ssomani corrected the status updation 3/15/01
                        status = cst_stat_val_1,   --23 - Match to be reviewed, but there was no discrepancy
                        ERROR_CODE = NULL   --      and so retaining the existing values
                    WHERE interface_id = person_rec.interface_id;
                EXCEPTION
                    WHEN OTHERS THEN
                        IF discrepancy_exist_cur%ISOPEN  THEN
                          CLOSE  discrepancy_exist_cur;
                        END  IF;

                        UPDATE igs_ad_interface_all
                        SET person_match_ind = cst_mi_val_20, --20 - Match To Be Reviewed For Discrepancy
                            status = cst_stat_val_3--ssomani corrected the status updation 3/15/01
                        WHERE   interface_id = person_rec.interface_id;
                END;
            ELSE
              IF person_rec.person_match_ind = '20' THEN
                        UPDATE igs_ad_interface_all
                        SET status = cst_stat_val_3  -- Record must have been processed in a previous run
                        WHERE   interface_id = person_rec.interface_id;
              ELSIF person_rec.person_match_ind = '23' THEN
                        UPDATE igs_ad_interface_all
                        SET status = cst_stat_val_1  -- Record must have been processed in a previous run
                        WHERE   interface_id = person_rec.interface_id;
              END IF;
            END IF;  -- End IF for person_match_ind

     ELSIF l_lvcAction  = 'D' THEN
            /*
           ||  Added By : Prabhat.Patel@Oracle.com
           ||  Added On : 22-Jun-2001
           ||  Purpose : This part of code is enhanced to handle the attribute level discrepancy rule,
           ||            as part of Modeling and Forecasting DLD.
          */

            -- Open Cursor for the ADMISSION table for the particular person to import the
            -- selected attributes from the INTERFACE table
           OPEN  c_null_hdlg_per_cur(l_person_id);
           FETCH c_null_hdlg_per_cur INTO c_null_hdlg_per_rec;
           CLOSE c_null_hdlg_per_cur;

         IF l_attribute_action = 'E' THEN
           --
           -- All the columns are marked as Keep('E') and nothing is marked for Review or Import.
            -- Only update the interface table with match_ind = '19', status = '1' and error_code = NULL.
             --
             UPDATE igs_ad_interface_all
             SET    person_match_ind = cst_mi_val_19,--19 -Match exists and retained existing values
                    status = cst_stat_val_1,
                    error_code = NULL
             WHERE  interface_id = person_rec.interface_id;


          ELSIF l_attribute_action = 'I' THEN
           --
           -- Few of the columns are marked for Import and nothing is marked for Review.
            -- Process the record by evaluating only 'Keep' and 'Import' Discrepancy Rules.
            -- Evaluate the Discrepancy Rules for each column and re-prepare the person_rec.
            --
            person_rec.SURNAME := Igs_Ad_Imp_023.get_discrepancy_result(
                           p_attribute_name  =>  'SURNAME',
                           p_ad_col_value    =>  c_null_hdlg_per_rec.SURNAME,
                           p_int_col_value   =>  person_rec.SURNAME,
                           p_source_type_id  =>  p_d_source_type_id,
                           p_category        => 'PERSON'
                           );

            person_rec.MIDDLE_NAME := Igs_Ad_Imp_023.get_discrepancy_result(
                           p_attribute_name  =>  'MIDDLE_NAME',
                           p_ad_col_value    =>  c_null_hdlg_per_rec.MIDDLE_NAME,
                           p_int_col_value   =>  person_rec.MIDDLE_NAME,
                           p_source_type_id  =>  p_d_source_type_id,
                           p_category        => 'PERSON'
                           );

            person_rec.GIVEN_NAMES := Igs_Ad_Imp_023.get_discrepancy_result(
                           p_attribute_name  =>  'GIVEN_NAMES',
                           p_ad_col_value    =>  c_null_hdlg_per_rec.GIVEN_NAMES,
                           p_int_col_value   =>  person_rec.GIVEN_NAMES,
                           p_source_type_id  =>  p_d_source_type_id,
                           p_category        =>  'PERSON'
                           );

            person_rec.PREFERRED_GIVEN_NAME := Igs_Ad_Imp_023.get_discrepancy_result(
                           p_attribute_name  =>  'PREFERRED_GIVEN_NAME',
                           p_ad_col_value    =>  c_null_hdlg_per_rec.PREFERRED_GIVEN_NAME,
                           p_int_col_value   =>  person_rec.PREFERRED_GIVEN_NAME,
                           p_source_type_id  =>  p_d_source_type_id,
                           p_category        =>  'PERSON'
                           );

            person_rec.SEX := Igs_Ad_Imp_023.get_discrepancy_result(
                           p_attribute_name  =>  'SEX',
                           p_ad_col_value    =>  c_null_hdlg_per_rec.SEX,
                           p_int_col_value   =>  person_rec.SEX,
                           p_source_type_id  =>  p_d_source_type_id,
                           p_category        =>  'PERSON'
                           );

            person_rec.BIRTH_DT := Igs_Ad_Imp_023.get_discrepancy_result(
                           p_attribute_name  =>  'BIRTH_DT',
                           p_ad_col_value    =>  c_null_hdlg_per_rec.BIRTH_DT,
                           p_int_col_value   =>  person_rec.BIRTH_DT,
                           p_source_type_id  =>  p_d_source_type_id,
                           p_category        => 'PERSON'
                           );

            person_rec.TITLE := Igs_Ad_Imp_023.get_discrepancy_result(
                           p_attribute_name  =>  'TITLE',
                           p_ad_col_value    =>  c_null_hdlg_per_rec.TITLE,
                           p_int_col_value   =>  person_rec.TITLE,
                           p_source_type_id  =>  p_d_source_type_id,
                           p_category        => 'PERSON'
                           );

            person_rec.SUFFIX := Igs_Ad_Imp_023.get_discrepancy_result(
                           p_attribute_name  =>  'SUFFIX',
                           p_ad_col_value    =>  c_null_hdlg_per_rec.SUFFIX,
                           p_int_col_value   =>  person_rec.SUFFIX,
                           p_source_type_id  =>  p_d_source_type_id,
                           p_category        =>  'PERSON'
                           );

           person_rec.PRE_NAME_ADJUNCT := Igs_Ad_Imp_023.get_discrepancy_result(
                           p_attribute_name  =>  'PRE_NAME_ADJUNCT',
                           p_ad_col_value    =>  c_null_hdlg_per_rec.PRE_NAME_ADJUNCT,
                           p_int_col_value   =>  person_rec.PRE_NAME_ADJUNCT,
                           p_source_type_id  =>  p_d_source_type_id,
                           p_category        =>  'PERSON'
                           );

           person_rec.LEVEL_OF_QUAL_ID := Igs_Ad_Imp_023.get_discrepancy_result(
                           p_attribute_name  =>  'LEVEL_OF_QUAL_ID',
                           p_ad_col_value    =>  c_null_hdlg_per_rec.LEVEL_OF_QUAL_ID,
                           p_int_col_value   =>  person_rec.LEVEL_OF_QUAL_ID,
                           p_source_type_id  =>  p_d_source_type_id,
                           p_category        =>  'PERSON'
                           );

           update_person
            (p_person_rec=>person_rec,
             p_addr_type=> NULL ,
             p_person_id_type=> NULL ,
             p_person_id=> l_person_id);


          OPEN status_cur(person_rec.interface_id);
          FETCH status_cur INTO status_rec;
          IF status_cur%FOUND THEN
            IF status_rec.status = '1' THEN
                UPDATE igs_ad_interface_all
                SET person_match_ind = cst_mi_val_18,  --18 -Match occured and used import values
                    status = cst_stat_val_1,
                    ERROR_CODE = NULL
                WHERE interface_id = person_rec.interface_id;
            END IF;
          END IF;
          CLOSE status_cur;

        ELSIF l_attribute_action = 'R' THEN
           -- Few of the columns are marked for review

          IF person_rec.person_match_ind = '21' THEN  --21 -Match reviewed and to be imported

                update_person
                 (p_person_rec=>person_rec,
                  p_addr_type=> NULL ,
                  p_person_id_type=> NULL ,
                  p_person_id=>l_person_id);

                OPEN status_cur(person_rec.interface_id);
                FETCH status_cur INTO status_rec;
                IF status_cur%FOUND THEN
                   IF status_rec.status = '1' THEN
                        UPDATE igs_ad_interface_all
                        SET person_match_ind = cst_mi_val_18,  --18 -Match occured and used import values
                            status = cst_stat_val_1,
                            ERROR_CODE = NULL
                        WHERE interface_id = person_rec.interface_id;
                    END IF;
                END IF;
                CLOSE status_cur;

          ELSIF NVL(person_rec.person_match_ind,'-1')  NOT IN('20','23') THEN   --20 - Match To Be Reviewed For Discrepancy
                                                                                --23 - Match to be reviewed, but there was no discrepancy
                                                                                --       and so retaining the existing values
                           -- Then check to see if discrepancy exists at detail level.
			   --gmaheswa: modified to Fix literals issue.
                   l_discrepancy_exists := Igs_Ad_Imp_023.find_detail_discrepancy_rule(p_source_type_id   => p_d_source_type_id,
                                               p_category            => 'PERSON',
                                               p_int_pk_col_name =>  'INTERFACE_ID',
                                               p_int_pk_col_val  => person_rec.interface_id,
					       p_ad_pk_col_name	 => 'PERSON_ID',
					       p_ad_pk_col_val   => l_person_id);

                   IF l_discrepancy_exists THEN
                         --Discrepancy exists.
                         --Update the match_ind = '20',  status = '3' and error_code = NULL IN THE INTERFACE TABLE.

                          UPDATE igs_ad_interface_all
                          SET    person_match_ind = cst_mi_val_20, --20 - Match To Be Reviewed For Discrepancy
                                 status = cst_stat_val_3,
                                 error_code = NULL
                          WHERE  interface_id = person_rec.interface_id;

                   ELSE
                        --Discrepancy does not exist.
                        --Update the match_ind = '23',  status = '1' and error_code = NULL IN THE INTERFACE TABLE.

                        UPDATE igs_ad_interface_all
                        SET    person_match_ind = cst_mi_val_23, --23 - Match to be reviewed, but there was no discrepancy
                                                       --      and so retaining the existing values
                               status = cst_stat_val_1,
                               error_code = NULL
                        WHERE  interface_id = person_rec.interface_id;
                   END IF;
                 ELSE
                   IF person_rec.person_match_ind = '20' THEN
                        UPDATE igs_ad_interface_all
                        SET status = '3'  -- Record must have been processed in a previous run
                        WHERE   interface_id = person_rec.interface_id;
                    ELSIF person_rec.person_match_ind = '23' THEN
                        UPDATE igs_ad_interface_all
                        SET status = '1'  -- Record must have been processed in a previous run
                        WHERE   interface_id = person_rec.interface_id;
                    END IF;
                  END IF; --   person_match_ind check
                END IF; --   l_attribute_action check for 'I','R' or 'E'
              END IF; -- End IF for l_lvcAction = 'E','I','R' OR 'D'

            ELSIF l_match_ind IN ('11','16') THEN --No Match

                CREATE_PERSON(P_person_rec => person_rec,
                                      P_ADDR_TYPE => NULL ,
                                      P_PERSON_ID_TYPE => NULL ,
                                      P_PERSON_ID => person_rec.person_id );

                -- We need to populate the person_id into the table igs_ad_interface
                -- since it has been created just now
                -- if we are not updating the person_id in igs_ad_interface
                -- next time when we run the import process
                -- we can't update the person
                IF person_rec.person_id IS NOT NULL THEN
                        UPDATE igs_ad_interface_all
                        SET person_id = person_rec.person_id
                        WHERE interface_id = person_rec.interface_id;
                END IF;
              END IF;-- End If for person_rec.match_ind
        -- This process should update the interface_run_id for each processed row
        -- in the IGS_AD_INTERFACE with the interface_run_id passed as the parameter

        -- this will be helpful, after we have finished all the import process
        -- and when we try to find out NOCOPY whether the status is complete or failed

        -- the code to update interface run id in igs_ad_interface is removed from here
        -- Now the updation is done in IGSAD79B.pls before call to prc_pe_dtls
  END LOOP;
  CLOSE person_cur;
END prc_pe_dtls;


PROCEDURE validate_address (p_addr_rec IN IGS_AD_ADDR_INT_ALL%ROWTYPE,
                            p_person_id IN igs_pe_person_base_v.PERSON_ID%TYPE,
                            p_status OUT NOCOPY VARCHAR2,
                            p_error_code OUT NOCOPY VARCHAR2) AS

     CURSOR birth_dt_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
     SELECT birth_date
     FROM igs_pe_person_base_v
     WHERE person_id = cp_person_id;

     CURSOR terr_name_cur(cp_territory_code FND_TERRITORIES_VL.TERRITORY_CODE%TYPE) IS
     SELECT territory_short_name
     FROM  FND_TERRITORIES_VL
     WHERE territory_code = UPPER(cp_territory_code);

     l_birth_dt  igs_pe_person_base_v.birth_date%TYPE;
     l_territory_short_name FND_TERRITORIES_VL.TERRITORY_SHORT_NAME%TYPE;
BEGIN


           IF p_addr_rec.START_DATE IS NULL THEN
                        p_error_code := 'E212';
                        RAISE NO_DATA_FOUND;
           END IF;

           IF p_addr_rec.END_DATE IS NOT NULL THEN
                IF p_addr_rec.END_DATE  < p_addr_rec.START_DATE  THEN
                        p_error_code := 'E208';
                        RAISE NO_DATA_FOUND;
                END IF;
           END IF;

           OPEN birth_dt_cur(p_person_id);
           FETCH birth_dt_cur INTO l_birth_dt;
           CLOSE birth_dt_cur;

           IF l_birth_dt IS NOT NULL THEN
               IF p_addr_rec.START_DATE < l_birth_dt THEN
                   p_error_code := 'E222';
                   RAISE NO_DATA_FOUND;
               END IF;
           END IF;

           OPEN terr_name_cur(p_addr_rec.country);
           FETCH terr_name_cur INTO l_territory_short_name ;
               IF   terr_name_cur%NOTFOUND  THEN
                        p_error_code := 'E209';
              RAISE NO_DATA_FOUND;
               END IF;
           CLOSE terr_name_cur;


           IF p_addr_rec.CORRESPONDENCE_flag IS NOT NULL AND
                 p_addr_rec.CORRESPONDENCE_flag  NOT IN ('Y', 'N') THEN
                 p_error_code := 'E213';
                 RAISE NO_DATA_FOUND;
           END IF;


        p_status := p_addr_rec.status;
        p_error_code := p_addr_rec.error_code;



EXCEPTION
        WHEN NO_DATA_FOUND THEN

            IF terr_name_cur%ISOPEN THEN
                CLOSE terr_name_cur;
            END IF;

            p_status := 3;

END validate_address;
END Igs_Ad_Imp_002;

/
