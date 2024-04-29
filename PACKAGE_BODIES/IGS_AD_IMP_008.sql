--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_008" AS
/* $Header: IGSAD86B.pls 120.8 2006/06/23 05:50:39 gmaheswa ship $ */
/* Change History
    Who               when            What

    ssaleem        13-OCT-2003     Bug : 3130316
                                   Logging is modified to include logging mechanism
    asbala         07-OCT-2003     Bug 3130316. Import Process Source Category Rule processing changes,
                                   lookup caching related changes, and cursor parameterization.
    vrathi         25-jun-2003     Bug No:3019813
                                   Added check to set error code and status if the person already exists in HR
    asbala         18-JUN-2003     Bug No: 3007112
                                   Included code to update igs_ad_reladdr_int.status after successful import
    npalanis       6-JAN-2003      Bug : 2734697
                                   code added to commit after import of every
                                   100 records .New variable l_processed_records added
    rrengara       16-DEC-2002     Bug 2693734, 2696082, 2694051, 2692214  fixes
    gmuralid       26-NOV-2002     BUG  2466674 --  V2API uptake
                                   Changed reference of HZ_CONTACT_POINT_PUB
                                   TO HZ_CONTACT_POINT_V2PUB for create
                                   and update of contact points

    gmuralid       27-NOV-2002     BUG 2676422 -- commented created_by_module := 'IGS' in update
                                   call of contact point
    pkpatel        23-DEC-2002     Bug No: 2722027
                                   Moved the code of Person special needs to IGSAD89B.pls
    gmaheswa       10-NOV-2003     Bug 3223043 HZ.K Impact changes
    pkpatel        11-DEC-2003     Bug 3311720 (Added the Date validations in Relation Address processing)
    gmaheswa       15-DEC-2003     Bug 3316838 Removed code related to date overlap under same employer or employer party number.
    asbala         10-MAR-2004     Bug 3484532 (Removed the check for person already exists in HR. All check will happen from TCA)
    asbala         15-APR-2004     3349171: Incorrect usage of fnd_lookup_values view
    akadam.in      21-SEP-2004     Academic History LOV Build
    skpandey       21-OCT-2004     Bug: 4691121
                                   Description: Sync the changes made in version 115.124 from 115.123 which was mistakenly overridden by 115.125 version
    pkpatel        17-Jan-2006     Bug 4937960 (R12: SWS Performance repository violation deliverables)
    gmaheswa	   27-Jan-2006     Bug: 4938278: crt_rel_adr: Call IGS_PE_WF_GEN. ADDR_BULK_SYNCHRONIZATION to raise bulk
  ||				   address change notification after process address records of all relationships.
  ||  gmaheswa      22-Jun-06	   Bug 5189180: modified CREATE_ADDRESS,Update_address to log error code E073, if address created with warning.
*/

PROCEDURE Prc_Pe_Relns (
                p_batch_id IN NUMBER,
                p_source_type_id IN NUMBER )
AS
    l_prog_label  VARCHAR2(100);
    l_label  VARCHAR2(100);
    l_debug_str VARCHAR2(2000);
    l_enable_log VARCHAR2(1);
    l_request_id NUMBER;
    l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

    CURSOR per_rel(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
    SELECT mi.*,i.person_id
    FROM igs_ad_relations_int_all mi, igs_ad_interface_all i
    WHERE   mi.interface_run_id = cp_interface_run_id
      AND  mi.interface_id =  i.interface_id
      AND  i.interface_run_id = cp_interface_run_id
      AND  mi.status = '2';

       --cursor added to check if the src cat for relations details are included for import (tray)
    CURSOR c_category_included(p_cat_name IGS_AD_SOURCE_CAT.CATEGORY_NAME%TYPE, p_src_typ_id IGS_AD_SOURCE_CAT.SOURCE_TYPE_ID%TYPE) IS
    SELECT include_ind
    FROM   igs_ad_source_cat
    WHERE  CATEGORY_NAME = p_cat_name
      AND    SOURCE_TYPE_ID = p_src_typ_id;

    -- Cursor to check whether the relationship exists for the person
    CURSOR c_rel_count (cp_person_id igs_ad_interface_all.person_id%TYPE,
                        cp_rel_person_id igs_ad_relations_int_all.rel_person_id%TYPE,
            cp_relationship_type igs_ad_relations_int_all.relationship_type%TYPE,
            cp_relationship_code igs_ad_relations_int_all.relationship_code%TYPE) IS
    SELECT count(*)
    FROM    HZ_RELATIONSHIPS
    WHERE   subject_id = cp_person_Id
      AND object_id = cp_rel_person_id
      AND RELATIONSHIP_TYPE = cp_relationship_type
      AND RELATIONSHIP_CODE = cp_relationship_code
      AND ( SYSDATE BETWEEN START_DATE AND END_DATE )
      AND STATUS = 'A';

    c_category_included_rec c_category_included%ROWTYPE; --tray

    l_rel_person_exists  VARCHAR2(1);
    l_rel_count NUMBER(3);
    l_rule VARCHAR2(1);
    l_status VARCHAR2(10);
    l_error_code VARCHAR2(10);
    l_processed_records NUMBER(5);

    CURSOR  c_match(p_request_id NUMBER) IS
    SELECT argument3
    FROM FND_CONCURRENT_REQUESTS
    WHERE request_id = p_request_id;

    l_match_set_id  igs_pe_match_sets.match_set_id%TYPE;
    p_rel_dup_rec   Igs_Pe_Identify_Dups.r_record_dup_rel;

    -- crt_rel Local Procedure  for Prc_Pe_Relns

  PROCEDURE crt_rel(P_Relations_Rec IN per_rel%ROWTYPE, p_src_type_id IN NUMBER) AS
/*
  ||  Created By : nsinha
  ||  Created On : 22-JUN-2001
  ||  Purpose : This procedure process the Application
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When           What
  ||  skpandey        21-SEP-2005    Bug: 3663505
  ||                                 Description: Added ATTRIBUTES 21 TO 24 TO STORE ADDITIONAL INFORMATION
  ||  pkpatel       15-APR-2002      Bug no.1834307 : Modified the Relationship_Type_C cursor to validate both Relationship_code and relationship_type
  ||  asbala        12-nov-03        3227107: address changes - signature of igs_pe_person_addr_pkg.insert_row and update_row changed
  ||  asbala        15-APR-2004      3349171: Incorrect usage of fnd_lookup_values view
  ||  (reverse chronological order - newest change first)
*/

      --1.  Validate the RELATIONSHIP_TYPE and RELATIONSHIP_CODE  -- ssawhney PE CCR 2203778
  -- OSS will not allow creation of relations between org and person through import process at this moment.

  CURSOR Relationship_Type_C(cp_lookup_type fnd_lookup_values.lookup_type%TYPE,
                             cp_subject_type hz_relationship_types.subject_type%TYPE,
			     cp_object_type hz_relationship_types.object_type%TYPE,
	                     cp_appl_id fnd_lookup_values.view_application_id%TYPE,
		             cp_relationship_code P_Relations_Rec.Relationship_code%TYPE,
	                     cp_relationship_type P_Relations_Rec.Relationship_type%TYPE,
			     cp_security_group_id fnd_lookup_values.security_group_id%TYPE) IS
  SELECT COUNT(1)
  FROM FND_LOOKUP_VALUES lk, hz_relationship_types hz
  WHERE hz.forward_rel_code= cp_relationship_code AND
        hz.relationship_type = cp_relationship_type AND
        lk.LOOKUP_TYPE = cp_lookup_type AND
	lk.lookup_code = hz.forward_rel_code AND
        hz.subject_type = cp_subject_type AND
        hz.object_type= cp_object_type AND
        hz.STATUS='A' AND
        lk.ENABLED_FLAG='Y' AND
        lk.VIEW_APPLICATION_ID = cp_appl_id AND
	lk.language = USERENV('LANG') AND
	lk.security_group_id = cp_security_group_id;

  CURSOR Rel_person_exists_cur(p_rel_person_id IGS_AD_RELATIONS_INT.REL_PERSON_ID%TYPE) IS
  SELECT 'Y'
  FROM   HZ_PARTIES
  WHERE  party_id = p_rel_person_id ;

person_rec     HZ_PARTY_V2PUB.PERSON_REC_TYPE;


  l_rel_person_exists  VARCHAR2(1);
  l_Count              NUMBER;
  l_Status             IGS_AD_RELATIONS_INT.STATUS%TYPE;
  l_return_status      IGS_AD_RELATIONS_INT.STATUS%TYPE;
  l_msg_count          NUMBER ;
  l_last_update_date   DATE;
  l_msg_data           VARCHAR2(2000);
  l_party_id           NUMBER;
  l_person_id          igs_pe_person.person_id%TYPE;
  l_party_number       igs_pe_person.person_number%TYPE;
  l_person_number      igs_pe_person.person_number%TYPE;
  l_profile_id         NUMBER;
  x_rowid              VARCHAR2(25);
  l_rowid              VARCHAR2(25);
  l_party_relationship_id NUMBER;
  l_TYPE_INSTANCE_ID             NUMBER;
  lv_acc_no VARCHAR2(1);
  l_generate_party_number         VARCHAR2(1);
  l_object_version_number NUMBER;
  l_err_cd   VARCHAR2(30);
  p_match_found VARCHAR2(1);
  l_object_verson_number NUMBER(30);
  l_message_name  VARCHAR2(30);
  l_app           VARCHAR2(50);

  BEGIN
    l_rel_person_exists := 'N';
    l_Status := '3';
    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
	l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_relns.begin_crt_rel';
        l_debug_str :=  'Interface Relations Id: '||p_relations_rec.interface_relations_id;
        fnd_log.string_with_context( fnd_log.level_procedure,
	      			     l_label,
				     l_debug_str, NULL,
		                     NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

    -- RELATIONSHIP_CODE should be NOT NULL
    -- ssawhney 2203778 HZ F relationship model changes
    IF P_Relations_Rec.RELATIONSHIP_CODE IS NULL THEN
        IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(P_Relations_Rec.Interface_Relations_Id,'E171','IGS_AD_RELATIONS_INT_ALL');
        END IF;

	UPDATE  IGS_AD_RELATIONS_INT_ALL
        SET     ERROR_CODE = 'E171',
                STATUS       = l_Status
        WHERE   INTERFACE_RELATIONS_ID = P_Relations_Rec.Interface_Relations_Id;
        RETURN;
    END IF;

    -- Validate the RELATIONSHIP_TYPE
    OPEN Relationship_Type_C('PARTY_RELATIONS_TYPE','PERSON','PERSON',222,
                             P_Relations_Rec.RELATIONSHIP_CODE,p_relations_rec.RELATIONSHIP_TYPE,0);
    FETCH Relationship_Type_C  INTO  l_Count;
    IF l_Count = 0 THEN
       IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(P_Relations_Rec.Interface_Relations_Id,'E239','IGS_AD_RELATIONS_INT_ALL');
       END IF;
       UPDATE IGS_AD_RELATIONS_INT_ALL
       SET    ERROR_CODE = 'E239',
              STATUS       = l_Status
       WHERE  INTERFACE_RELATIONS_ID = P_Relations_Rec.Interface_Relations_Id;

       CLOSE Relationship_Type_C;
       RETURN;
    END IF;
    IF Relationship_Type_C%ISOPEN THEN
       CLOSE Relationship_Type_C;
    END IF;

    l_count:= 0;
    -- Validate Oth_Relationship_Type
    IF P_Relations_Rec.Oth_Relationship_Type IS NOT NULL THEN
       IF  NOT(igs_pe_pers_imp_001.validate_lookup_type_code('PARTY_RELATIONS_TYPE',P_Relations_Rec.oth_relationship_type,222)) THEN
          IF l_enable_log = 'Y' THEN
              igs_ad_imp_001.logerrormessage(P_Relations_Rec.Interface_Relations_Id,'E240','IGS_AD_RELATIONS_INT_ALL');
          END IF;
          UPDATE igs_ad_relations_int_all
          SET ERROR_CODE = 'E240',
              STATUS       = l_Status
          WHERE INTERFACE_RELATIONS_ID = P_Relations_Rec.Interface_Relations_Id;
          RETURN;
       END IF;
    END IF;

    -- If the Rel Person ID passed is valid only the relation is created and Person is not created
    -- Cursor to check whether the Rel Person ID passed is a valid Party ID in HZ_PARTIES
    OPEN  Rel_person_exists_cur(NVL(p_relations_rec.rel_person_id,0));
    FETCH Rel_person_exists_cur INTO l_rel_person_exists;
    CLOSE Rel_person_exists_cur;
    IF l_rel_person_exists <> 'Y' or l_rel_person_exists IS NULL THEN
        -- To check profile value HZ_GENERATE_PARTY_NUMBER, and depending on it,
        -- if or not to pass the person_number is decided.(Tray, Bug#1849225,02-07-2001)
        l_generate_party_number := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');
        IF (l_generate_party_number = 'N') THEN
            IF (P_Relations_Rec.person_number IS NULL) THEN
                UPDATE igs_ad_relations_int_all
                SET STATUS = '3',ERROR_CODE = 'E204'
                WHERE INTERFACE_RELATIONS_ID = P_Relations_Rec.INTERFACE_RELATIONS_ID;
                -- Call Log detail
                IF l_enable_log = 'Y' THEN
                     igs_ad_imp_001.logerrormessage(P_Relations_Rec.Interface_Relations_Id,'E204','IGS_AD_RELATIONS_INT_ALL');
                     FND_MESSAGE.SET_NAME('IGS','IGS_AD_REL_FAIL_PER_NO');
		     FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
                END IF;
                RETURN;
            ELSE
                l_person_number := P_Relations_Rec.person_number;
            END IF;
        END IF;

        -- Validate the title
        IF P_Relations_Rec.pre_name_adjunct IS NOT NULL THEN
            IF  NOT (igs_pe_pers_imp_001.validate_lookup_type_code('CONTACT_TITLE',P_Relations_Rec.pre_name_adjunct,222)) THEN
                IF l_enable_log = 'Y' THEN
                     igs_ad_imp_001.logerrormessage(P_Relations_Rec.Interface_Relations_Id,'E201','IGS_AD_RELATIONS_INT_ALL');
                END IF;
                UPDATE igs_ad_relations_int_all
	        SET ERROR_CODE = 'E201',
	            STATUS     = l_Status
	        WHERE INTERFACE_RELATIONS_ID = P_Relations_Rec.Interface_Relations_Id;
                RETURN;
            END IF;
        END IF;
        -- Validate Sex.
        IF P_Relations_Rec.sex IS NOT NULL THEN
            IF  NOT (igs_pe_pers_imp_001.validate_lookup_type_code('HZ_GENDER',P_Relations_Rec.sex,222)) THEN
                IF l_enable_log = 'Y' THEN
	            igs_ad_imp_001.logerrormessage(P_Relations_Rec.Interface_Relations_Id,'E202','IGS_AD_RELATIONS_INT_ALL');
	        END IF;
	        UPDATE igs_ad_relations_int_all
	        SET     ERROR_CODE = 'E202',
		        STATUS     = l_Status
	        WHERE INTERFACE_RELATIONS_ID = P_Relations_Rec.Interface_Relations_Id;
	        RETURN;
	    END IF;
        END IF;

        -- Validate birth_dt, deceased_dt.
	IF  ((P_Relations_Rec.birth_dt IS NOT NULL) AND (P_Relations_Rec.birth_dt > SYSDATE))  THEN
	    l_err_cd := 'E203';
	    IF l_enable_log = 'Y' THEN
	       igs_ad_imp_001.logerrormessage(P_Relations_Rec.Interface_Relations_Id,'E203','IGS_AD_RELATIONS_INT_ALL');
	    END IF;
	    UPDATE igs_ad_relations_int_all
	    SET     ERROR_CODE = l_err_cd,
	            STATUS     = l_Status
	    WHERE INTERFACE_RELATIONS_ID = P_Relations_Rec.Interface_Relations_Id;
	    RETURN;
        ELSIF ( (NVL(P_Relations_Rec.deceased,'N') = 'Y') AND (P_Relations_Rec.deceased_date > SYSDATE)) THEN
            l_err_cd := 'E451';
            IF l_enable_log = 'Y' THEN
		igs_ad_imp_001.logerrormessage(P_Relations_Rec.Interface_Relations_Id,'E451','IGS_AD_RELATIONS_INT_ALL');
	    END IF;
	    UPDATE igs_ad_relations_int_all
	    SET     ERROR_CODE = l_err_cd,
		    STATUS     = l_Status
	    WHERE   INTERFACE_RELATIONS_ID = P_Relations_Rec.Interface_Relations_Id;
	    RETURN;
        END IF;

	p_rel_dup_rec.interface_id := p_relations_rec.interface_id;
        p_rel_dup_rec.interface_relations_id := p_relations_rec.interface_relations_id;
        p_rel_dup_rec.surname := p_relations_rec.surname;
        p_rel_dup_rec.first_name := p_relations_rec.given_names;
        p_rel_dup_rec.gender := p_relations_rec.sex;
        p_rel_dup_rec.birth_date := p_relations_rec.birth_dt;
        p_rel_dup_rec.batch_id := p_batch_id;
        p_rel_dup_rec.match_set_id := l_match_set_id;

        Igs_Pe_Identify_Dups.Find_dup_rel_per(
                                      P_REL_DUP_REC => p_rel_dup_rec,
                                      P_MATCH_FOUND => p_match_found
                                      );
        IF p_match_found = 'N' THEN
             IGS_PE_PERSON_PKG.INSERT_ROW(
	                        X_MSG_COUNT => l_msg_count,
                                X_MSG_DATA => l_msg_data,
                                X_RETURN_STATUS => l_return_status,
                                X_ROWID => l_rowid,
                                X_PERSON_ID => l_person_id,
                                X_PERSON_NUMBER => l_person_number,
                                X_SURNAME => p_relations_rec.surname,
                                X_MIDDLE_NAME => NULL,
                                X_GIVEN_NAMES => p_relations_rec.given_names,
                                X_SEX => p_relations_rec.sex,
                                X_TITLE => p_relations_rec.title,
                                X_STAFF_MEMBER_IND => NULL,
                                X_DECEASED_IND => P_Relations_Rec.deceased,
                                X_SUFFIX => NULL,
                                X_PRE_NAME_ADJUNCT => p_relations_rec.pre_name_adjunct,
                                X_ARCHIVE_EXCLUSION_IND => 'N',
                                X_ARCHIVE_DT => NULL,
                                X_PURGE_EXCLUSION_IND => 'N',
                                X_PURGE_DT => NULL,
                                X_DECEASED_DATE => p_relations_rec.deceased_date,
                                X_PROOF_OF_INS => 'N',
                                X_PROOF_OF_IMMU =>  'N',
                                X_BIRTH_DT =>p_relations_rec.birth_dt,
                                X_SALUTATION => NULL,
                                X_ORACLE_USERNAME => NULL,
                                X_PREFERRED_GIVEN_NAME => P_Relations_Rec.preferred_given_name,
                                X_EMAIL_ADDR => NULL,
                                X_LEVEL_OF_QUAL_ID => NULL,
                                X_MILITARY_SERVICE_REG =>'N',
                                X_VETERAN => 'VETERAN_NOT', --  ssawhney now a lookup code 2203778
                                X_HZ_PARTIES_OVN => l_object_version_number,
                                X_ATTRIBUTE_CATEGORY => NULL,
                                X_ATTRIBUTE1 => NULL,
                                X_ATTRIBUTE2 => NULL,
                                X_ATTRIBUTE3 => NULL,
                                X_ATTRIBUTE4 => NULL,
                                X_ATTRIBUTE5 => NULL,
                                X_ATTRIBUTE6 => NULL,
                                X_ATTRIBUTE7 => NULL,
                                X_ATTRIBUTE8 => NULL,
                                X_ATTRIBUTE9 => NULL,
                                X_ATTRIBUTE10 => NULL,
                                X_ATTRIBUTE11 => NULL,
                                X_ATTRIBUTE12 => NULL,
                                X_ATTRIBUTE13 => NULL,
                                X_ATTRIBUTE14 => NULL,
                                X_ATTRIBUTE15 => NULL,
                                X_ATTRIBUTE16 => NULL,
                                X_ATTRIBUTE17 => NULL,
                                X_ATTRIBUTE18 => NULL,
                                X_ATTRIBUTE19 => NULL,
                                X_ATTRIBUTE20 => NULL,
                                X_PERSON_ID_TYPE => NULL,
                                X_API_PERSON_ID => NULL,
                                X_MODE => 'R',
                                X_ATTRIBUTE21 => NULL,
                                X_ATTRIBUTE22 => NULL,
                                X_ATTRIBUTE23 => NULL,
                                X_ATTRIBUTE24 => NULL
                                );


        IF l_return_status IN ('E','U') THEN
            IF l_enable_log = 'Y' THEN
               igs_ad_imp_001.logerrormessage(P_Relations_Rec.Interface_Relations_Id,'E452','IGS_AD_RELATIONS_INT_ALL');
            END IF;
            IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
	        l_label := 'igs.plsql.igs_ad_imp_008.crt_rel.exception '||'E452';
		fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
	        fnd_message.set_token('INTERFACE_ID',P_Relations_Rec.Interface_Relations_Id);
	        fnd_message.set_token('ERROR_CD','E452');
	        l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;
	        fnd_log.string_with_context( fnd_log.level_exception,
			                     l_label,
		                             l_debug_str, NULL,
		                             NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
					    );
	    END IF;
	    UPDATE igs_ad_relations_int_all
            SET ERROR_CODE = 'E452',
		status   = l_status
	    WHERE interface_relations_id = P_Relations_Rec.Interface_Relations_Id;
	    RETURN;
	END IF;

        --10.  Create the relationship for this person
        -- ssawhney 2203778 using IGS wrapper now.
        ELSIF p_match_found = 'Y' THEN
	    l_status := '3';
	    IF l_enable_log = 'Y' THEN
		igs_ad_imp_001.logerrormessage(P_Relations_Rec.Interface_Relations_Id,'E289','IGS_AD_RELATIONS_INT_ALL');
	    END IF;
	    UPDATE igs_ad_relations_int_all
	    SET ERROR_CODE = 'E289',
	        STATUS   = l_Status
	    WHERE INTERFACE_RELATIONS_ID = P_Relations_Rec.Interface_Relations_Id;
	    RETURN;
	END IF;
    ELSE  --l_rel_person_exists <> 'Y'
        l_person_id := p_relations_rec.rel_person_id;
    END IF;

  BEGIN
    SAVEPOINT before_creatupdate;
    igs_pe_relationships_pkg.CREATUPDATE_PARTY_RELATIONSHIP(
                        p_action                  => 'INSERT',
                        p_subject_id              => P_Relations_Rec.Person_Id,
                        p_object_id               => l_person_id ,
                        p_party_relationship_type => P_Relations_Rec.RELATIONSHIP_TYPE,
                        p_relationship_code       => P_Relations_Rec.RELATIONSHIP_CODE,
                        p_comments                => null,
                        p_start_date              => sysdate,
                        p_end_date                => null,
                        p_last_update_date        => l_last_update_date ,
                        p_return_status           => l_return_status ,
                        p_msg_count               => l_msg_count, -- this is coded wrong, it should have been a number
                        p_msg_data                => l_msg_data,
                        p_party_relationship_id   => l_party_relationship_id,
                        p_party_id                => l_party_id,
                        p_party_number            => l_party_number,
                        p_object_version_number   => l_object_verson_number) ;

    IF l_return_status IN ('E','U') THEN
      IF l_enable_log = 'Y' THEN
         igs_ad_imp_001.logerrormessage(P_Relations_Rec.Interface_Relations_Id,'E172','IGS_AD_RELATIONS_INT_ALL');
      END IF;

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
	  l_label := 'igs.plsql.igs_ad_imp_008.crt_rel.exception '||'E172';
	  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
	  fnd_message.set_token('INTERFACE_ID',P_Relations_Rec.Interface_Relations_Id);
	  fnd_message.set_token('ERROR_CD','E172');
	  l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;
	  fnd_log.string_with_context( fnd_log.level_exception,
			               l_label,
		                       l_debug_str, NULL,
		                       NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
				      );
      END IF;
      UPDATE igs_ad_relations_int_all
      SET ERROR_CODE = 'E172',
          STATUS   = '3'
      WHERE INTERFACE_RELATIONS_ID = P_Relations_Rec.Interface_Relations_Id;
      RETURN;
    ELSE
      UPDATE igs_ad_relations_int_all
      SET    rel_person_id  = l_person_id,
             status = '1',
             ERROR_CODE = NULL
      WHERE  INTERFACE_RELATIONS_ID = P_Relations_Rec.Interface_Relations_Id;
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
          ROLLBACK TO before_creatupdate;
          FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);
	  IF l_message_name = ('IGS_PE_PERS_ID_PRD_OVRLP') THEN
	       IF l_enable_log = 'Y' THEN
		  igs_ad_imp_001.logerrormessage(P_Relations_Rec.Interface_Relations_Id,'E290','IGS_AD_RELATIONS_INT_ALL');
	       END IF;
	       UPDATE igs_ad_relations_int_all
	       SET    ERROR_CODE = 'E290',
		      STATUS   = '3'
	       WHERE INTERFACE_RELATIONS_ID = P_Relations_Rec.Interface_Relations_Id;
	       RETURN;
	  ELSE
	       IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
	            l_label := 'igs.plsql.igs_ad_imp_008.crt_rel.exception.others';
	            l_debug_str :=  'Unhandled Exception for interface Relatuons ID:'||P_Relations_Rec.Interface_Relations_Id||' ' ||  l_msg_data;
	            fnd_log.string_with_context( fnd_log.level_exception,
			                         l_label,
		                                 l_debug_str, NULL,
					         NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
					        );
	      END IF;
	      RETURN;
	  END IF;
  END ;

  --9.  If the person and relationship creation is successful then
  --Added to check if include_ind is 'Y'/'N' for the source_category for importing details of the relation created (tray),
  --if yes make a call to process the category in question , (tray)

  OPEN c_category_included('RELATIONS_CONTACTS',p_src_type_id);
  FETCH c_category_included INTO c_category_included_rec;
  CLOSE c_category_included;
  IF c_category_included_rec.include_ind  = 'Y' THEN
     -- ssomani, passing the person id of the relation created above 15 March 2001
     prc_rel_con_dtl(P_Relations_Rec.interface_relations_id, l_person_id , p_source_type_id);
  END IF;

  OPEN c_category_included('RELATIONS_ADDRESS',p_src_type_id);
  FETCH c_category_included INTO c_category_included_rec;
  CLOSE c_category_included;
  IF c_category_included_rec.include_ind  = 'Y' THEN
     Crt_Rel_adr(P_Relations_Rec.interface_relations_id, l_person_id,p_source_type_Id);
  END IF;

  OPEN c_category_included('RELATIONS_ACAD_HISTORY',p_src_type_id);
  FETCH c_category_included INTO c_category_included_rec;
  CLOSE c_category_included;
  IF c_category_included_rec.include_ind  = 'Y' THEN
    -- ssomani, passing the person id of the relation created above 15 March 2001
    crt_rel_acad_his(P_Relations_Rec.interface_relations_id, l_PERSON_ID,p_source_type_Id);
  END IF;

  OPEN c_category_included('RELATIONS_EMPLOYMENT_DETAILS',p_src_type_id);
  FETCH c_category_included INTO c_category_included_rec;
  CLOSE c_category_included;
  IF c_category_included_rec.include_ind  = 'Y' THEN
     Prc_Relns_Emp_Dtls(P_Relations_Rec.interface_relations_id, l_PERSON_ID,p_source_type_id);
  END IF;

-----------------------------------
  EXCEPTION
  WHEN OTHERS THEN
    l_msg_data := SQLERRM;
    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
       l_label := 'igs.plsql.igs_ad_imp_008.crt_rel.exception '|| 'E518';
       fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
       fnd_message.set_token('INTERFACE_ID',p_relations_rec.interface_relations_id);
       fnd_message.set_token('ERROR_CD','E518');
       l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;
       fnd_log.string_with_context( fnd_log.level_exception,
		                    l_label,
				    l_debug_str, NULL,
		                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
				  );
    END IF;

    IF l_enable_log = 'Y' THEN
       igs_ad_imp_001.logerrormessage(P_Relations_Rec.Interface_Relations_Id,'E518','IGS_AD_RELATIONS_INT_ALL');
    END IF;

    UPDATE igs_ad_relations_int_all
    SET     ERROR_CODE = 'E518',
            STATUS   = l_Status
    WHERE INTERFACE_RELATIONS_ID = P_Relations_Rec.Interface_Relations_Id;
  END crt_rel;
  -- End Local Procedure crt_rel

-- Main Procedure starts here Prc_Pe_Rel
BEGIN
  l_processed_records := 0;
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  l_prog_label := 'igs.plsql.igs_ad_imp_008.prc_pe_relns';
  l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_relns.';
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_request_id := fnd_global.conc_request_id;
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
      l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_relns.begin';
      l_debug_str :=  'igs_ad_imp_008.prc_pe_rel';
      fnd_log.string_with_context( fnd_log.level_procedure,
		                   l_label,
		                   l_debug_str, NULL,
		                   NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
				 );
  END IF;

/*  OPEN c_match(l_request_id);
  FETCH c_match INTO l_match_set_id;
  CLOSE c_match;
*/

  l_match_set_id := Igs_Pe_Identify_Dups.g_match_set_id;  -- bug 3671344

  FOR  relations_rec IN per_rel(l_interface_run_id) LOOP
      l_processed_records := l_processed_records + 1 ;
      relations_rec.RELATIONSHIP_CODE := UPPER(relations_rec.RELATIONSHIP_CODE);
      relations_rec.RELATIONSHIP_TYPE := UPPER(relations_rec.RELATIONSHIP_TYPE);
      relations_rec.pre_name_adjunct := UPPER(relations_rec.pre_name_adjunct);
      relations_rec.OTH_RELATIONSHIP_TYPE := UPPER(relations_rec.OTH_RELATIONSHIP_TYPE);
      relations_rec.sex := UPPER(relations_rec.sex);
      BEGIN
          -- Check to see that the rel_person ID passed is valid
          IF relations_rec.rel_person_id IS NULL OR
	      relations_rec.relationship_code IS NULL THEN
	      RAISE NO_DATA_FOUND;
	  END IF;
          -- Check whether the relationship exist for the person
	  OPEN c_rel_count(relations_rec.person_Id,relations_rec.rel_person_id,
               relations_rec.relationship_type,relations_rec.relationship_code);
	  FETCH c_rel_count INTO l_rel_count;
	  CLOSE c_rel_count;
	  IF l_rel_count = 0 THEN
	      RAISE NO_DATA_FOUND;
	  END IF;
          -- If Relation exists update interface table and proceed to the next record
	  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
	      l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_relns.relation_exist';
	      l_debug_str :=  'Igs_Ad_Imp_008.Prc_Pe_Relns ' ||'Interface_Relations_Id : ' ||
	                      IGS_GE_NUMBER.TO_CANN(Relations_Rec.Interface_Relations_Id) ||'Status : 1' ||  'Relationship Exists';
	      fnd_log.string_with_context( fnd_log.level_procedure,
				           l_label,
		                           l_debug_str, NULL,
			                   NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
					 );
	  END IF;

	  UPDATE  igs_ad_relations_int_all
	  SET     status = '1',
		  error_code = NULL
	  WHERE   interface_relations_id = relations_rec.interface_relations_id;
	  OPEN c_category_included('RELATIONS_CONTACTS',p_source_type_id);
	  FETCH c_category_included INTO c_category_included_rec;
	  CLOSE c_category_included;
	  IF c_category_included_rec.include_ind  = 'Y' THEN
	      -- ssomani, passing the person id of the relation created above 15 March 2001
	      prc_rel_con_dtl(Relations_Rec.interface_relations_id, relations_rec.Rel_Person_Id, p_source_type_id);
	  END IF;
	  OPEN c_category_included('RELATIONS_ADDRESS',p_source_type_id);
	  FETCH c_category_included INTO c_category_included_rec;
	  CLOSE c_category_included;

	  IF c_category_included_rec.include_ind  = 'Y' THEN
	      crt_rel_adr (relations_rec.interface_relations_id, relations_rec.Rel_Person_Id, p_source_type_id);
	  END IF;

	  OPEN c_category_included('RELATIONS_ACAD_HISTORY',p_source_type_id);
	  FETCH c_category_included INTO c_category_included_rec;
	  CLOSE c_category_included;
	  IF c_category_included_rec.include_ind  = 'Y' THEN
	      -- ssomani, passing the person id of the relation created above 15 March 2001
	      crt_rel_acad_his(Relations_Rec.interface_relations_id, relations_rec.Rel_Person_Id, p_source_type_Id);
	  END IF;

	  OPEN c_category_included('RELATIONS_EMPLOYMENT_DETAILS',p_source_type_id);
	  FETCH c_category_included INTO c_category_included_rec;
	  CLOSE c_category_included;
	  IF c_category_included_rec.include_ind  = 'Y' THEN
	      Prc_Relns_Emp_Dtls(Relations_Rec.interface_relations_id, relations_rec.Rel_Person_Id, p_source_type_id);
	  END IF;

      EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	       crt_rel(P_Relations_Rec => relations_rec,
               p_src_type_id=> p_source_type_id);  --tray , parameter added p_src_type_id=> p_source_type_id
          WHEN OTHERS THEN
               -- this can happen from the crt_rel_adr also, hence its better to keep when others
               -- and when no data found separate
               IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
	           l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_relns.exception';
	           fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                   fnd_message.set_token('INTERFACE_ID',relations_rec.interface_relations_id);
                   fnd_message.set_token('ERROR_CD','E518');
                   l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;
                   fnd_log.string_with_context( fnd_log.level_exception,
                                                l_label,
			                        l_debug_str, NULL,
					        NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
					      );
               END IF;

               IF l_enable_log = 'Y' THEN
	              igs_ad_imp_001.logerrormessage(Relations_Rec.Interface_Relations_Id,'E518','IGS_AD_RELATIONS_INT_ALL');
               END IF;
	       UPDATE     igs_ad_relations_int_all
	       SET        status = '3',   error_code = 'E518'
	       WHERE      interface_relations_id = relations_rec.interface_relations_id;
      END;
      IF l_processed_records = 100 THEN
          COMMIT;
          l_processed_records := 0;
      END IF;
  END LOOP;
END Prc_Pe_Relns;

PROCEDURE crt_rel_adr (P_Interface_Relations_Id NUMBER,
                       P_Rel_Person_Id NUMBER,
                       p_source_type_id NUMBER) AS

    l_prog_label  VARCHAR2(100);
    l_label  VARCHAR2(100);
    l_debug_str VARCHAR2(2000);
    l_enable_log VARCHAR2(1);
    l_request_id NUMBER;
    l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
    l_party_site_ovn hz_party_sites.object_version_number%TYPE;
    l_location_ovn hz_locations.object_version_number%TYPE;
    l_addr_process   BOOLEAN := FALSE;


    --1.  Pick up all the records from the table IGS_AD_RELADDR_INT
    CURSOR  reladdr_rec_c( cp_Interface_Relations_Id NUMBER ) IS
    SELECT  *
    FROM    igs_ad_reladdr_int_all
    WHERE   status = '2'
    AND     interface_relations_id = cp_interface_relations_id;

    --3.  Validate to see if this address already exist for this person.
    CURSOR addr_c(p_addr_line_1 igs_ad_reladdr_int.addr_line_1%TYPE,
                p_addr_line_2  igs_ad_reladdr_int.addr_line_2%TYPE,
                p_addr_line_3  igs_ad_reladdr_int.addr_line_3%TYPE,
                p_addr_line_4  igs_ad_reladdr_int.addr_line_4%TYPE,
                p_country      igs_ad_reladdr_int.country%TYPE,
                p_county       igs_ad_reladdr_int.county%TYPE,
                p_province     igs_ad_reladdr_int.province%TYPE,
                p_city         igs_ad_reladdr_int.city%TYPE,
                p_state        igs_ad_reladdr_int.state%TYPE,
                p_party_id     NUMBER
          ) IS
    SELECT *
    FROM IGS_PE_ADDR_V
    WHERE UPPER(addr_line_1) = UPPER(p_addr_line_1)
    AND   UPPER(nvl(addr_line_2,'NulL')) = UPPER(nvl(p_addr_line_2,'NulL'))
    AND   UPPER(nvl(addr_line_3,'NulL')) = UPPER(nvl(p_addr_line_3,'NulL'))
    AND   UPPER(nvl(addr_line_4,'NulL')) = UPPER(nvl(p_addr_line_4,'NulL'))
    AND   country_cd = p_country
    AND   UPPER(nvl(county,'NulL')) = UPPER(nvl(p_county,'NulL'))
    AND   UPPER(nvl(province,'NulL')) = UPPER(nvl(p_province,'NulL'))
    AND   UPPER(nvl(city,'NulL')) = UPPER(nvl(p_city,'NulL'))
    AND   UPPER(nvl(state,'NulL')) = UPPER(nvl(p_state,'NulL'))
    AND   person_id  = P_Rel_Person_Id;

    addr_rec   addr_c%ROWTYPE;


    --Check to see if for this address these two site usages exist.
    CURSOR site_c (p_party_site_id igs_pe_addr_v.party_site_id%TYPE,
                   p_site_use_code igs_ad_reladdr_int.site_use_code_1%TYPE ) IS
    SELECT site_use_type,party_site_use_id,last_update_date
    FROM HZ_PARTY_SITE_USES
    WHERE PARTY_SITE_ID = p_party_site_id
    AND site_use_type     = p_site_use_code;



    --Create a party_site.
    p_api_version       NUMBER(15);
    site_c_rec          site_c%ROWTYPE;
    l_party_site_id     HZ_PARTY_SITES.PARTY_SITE_ID%TYPE;
    l_party_site_number VARCHAR2(2000);
    l_party_site_use_id HZ_PARTY_SITE_USES.PARTY_SITE_USE_ID%TYPE;
    l_site1             igs_ad_reladdr_int.site_use_code_1%TYPE;
    l_site2             igs_ad_reladdr_int.site_use_code_2%TYPE;
    l_return_status   IGS_AD_RELATIONS_INT.STATUS%TYPE;
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);
    l_Count              NUMBER;
    l_Status             IGS_AD_RELATIONS_INT.STATUS%TYPE;
    l_Error_Code         IGS_AD_RELATIONS_INT.Error_Code%TYPE;
    l_rule               igs_ad_source_cat.discrepancy_rule_cd%TYPE;
    l_last_update_date   DATE;
    l_site_use_last_update_date  DATE;
    l_profile_last_update_date   DATE;
    l_row_id         VARCHAR2(30);
    l_location_id    HZ_LOCATIONS.LOCATION_ID%TYPE;
    l_territory_short_name FND_TERRITORIES_VL.TERRITORY_SHORT_NAME%TYPE;
    l_Check  VARCHAR2(30);
    l_object_version_number NUMBER;

    PROCEDURE Update_Addr(addr_rec addr_c%ROWTYPE , reladdr_rec reladdr_rec_c%ROWTYPE , p_rel_person_id NUMBER) AS
        --Check to see if for this address these two site usages exist.
        CURSOR site_c (p_party_site_id igs_pe_addr_v.party_site_id%TYPE,
                       p_site_use_code igs_ad_reladdr_int.site_use_code_1%TYPE ) IS
        SELECT  site_use_type,party_site_use_id,last_update_date
        FROM    hz_party_site_uses
        WHERE   party_site_id = p_party_site_id AND
                site_use_type     = p_site_use_code;
        l_flag_check_status VARCHAR2(1);
        site_c_rec          site_c%ROWTYPE;
        l_location_id    HZ_LOCATIONS.LOCATION_ID%TYPE;
        l_party_site_id     HZ_PARTY_SITES.PARTY_SITE_ID%TYPE;
        l_party_site_use_id HZ_PARTY_SITE_USES.PARTY_SITE_USE_ID%TYPE;
        l_row_id         VARCHAR2(30);
        l_Status             IGS_AD_RELATIONS_INT.STATUS%TYPE;
        l_Error_Code         IGS_AD_RELATIONS_INT.Error_Code%TYPE;
        l_return_status   IGS_AD_RELATIONS_INT.STATUS%TYPE;
        l_msg_data           VARCHAR2(2000);
        l_last_update_date   DATE;
        l_site_use_last_update_date  DATE;
        l_profile_last_update_date   DATE;
	l_addr_warning VARCHAR2(1) := 'N';
    BEGIN
        l_flag_check_status := 'Y';
	l_Status := '3';
	l_Error_Code := 'E008';
	l_site_use_last_update_date := NULL;
	l_profile_last_update_date := NULL;

        l_location_id :=  addr_rec.location_id;
        l_party_site_id := addr_rec.party_site_id;
        --  cursor to fetch l_last_update_date  from hz_locations for a given location_id
        l_location_ovn := addr_rec.location_ovn;
        l_party_site_ovn := addr_rec.party_site_ovn;

        IGS_PE_PERSON_ADDR_PKG.UPDATE_ROW(
              p_action          => NULL,
              p_rowid           => l_row_id,
              p_location_id     => l_location_id ,
              p_start_dt        => nvl(reladdr_rec.start_dt,addr_rec.start_dt) ,
              p_end_dt          => nvl(reladdr_rec.end_dt,addr_rec.end_dt) ,
              p_country         => nvl(reladdr_rec.country,addr_rec.country),
              p_address_style   => addr_rec.address_style,
              p_addr_line_1     => nvl(reladdr_rec.addr_line_1,addr_rec.addr_line_1),
              p_addr_line_2     => nvl(reladdr_rec.addr_line_2,addr_rec.addr_line_2),
              p_addr_line_3     => nvl(reladdr_rec.addr_line_3,addr_rec.addr_line_3),
              p_addr_line_4     => nvl(reladdr_rec.addr_line_4,addr_rec.addr_line_4),
              p_date_last_verified  => addr_rec.date_last_verified,
              p_correspondence      => nvl(reladdr_rec.correspondence,addr_rec.correspondence),
              p_city            => nvl(reladdr_rec.city,addr_rec.city),
              p_state           => nvl(reladdr_rec.state,addr_rec.state),
              p_province        => nvl(reladdr_rec.province,addr_rec.province),
              p_county          => nvl(reladdr_rec.county,addr_rec.county),
              p_postal_code     => nvl(reladdr_rec.postal_code,addr_rec.postal_code),
              p_address_lines_phonetic  => addr_rec.address_lines_phonetic,
              p_delivery_point_code => addr_rec.delivery_point_code,
              p_other_details_1     => nvl(reladdr_rec.other_details_1,addr_rec.other_details_1),
              p_other_details_2     => nvl(reladdr_rec.other_details_2,addr_rec.other_details_2),
              p_other_details_3     => nvl(reladdr_rec.other_details_3,addr_rec.other_details_3),
              l_return_status       => l_return_status ,
              l_msg_data            => l_msg_data ,
              p_party_id            => P_Rel_Person_Id,
              p_party_site_id       => l_party_site_id,
              p_party_type          => NULL,
              p_last_update_date    => l_last_update_date,
              p_party_site_ovn      => l_party_site_ovn,
              p_location_ovn        => l_location_ovn,
              p_status          => addr_rec.status
        );

        IF l_return_status IN ('E','U') THEN
             l_flag_check_status := 'N';
             IF l_enable_log = 'Y' THEN
                 igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E014','IGS_AD_RELADDR_INT_ALL');
             END IF;
             IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                 IF (l_request_id IS NULL) THEN
                     l_request_id := fnd_global.conc_request_id;
                 END IF;
                 l_label := 'igs.plsql.igs_ad_imp_008.update_addr.exception '||'E014';

                 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                 fnd_message.set_token('INTERFACE_ID',reladdr_rec.interface_reladdr_id);
                 fnd_message.set_token('ERROR_CD','E014');
                 l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;
                 fnd_log.string_with_context( fnd_log.level_exception,
	                                      l_label,
		                              l_debug_str, NULL,
			                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
					    );
             END IF;

             UPDATE  Igs_Ad_RelAddr_Int_all
             SET     Error_Code = 'E014',
                     Status     = '3'
             WHERE   interface_reladdr_id = reladdr_rec.interface_reladdr_id;
        ELSIF l_return_status = 'W' THEN
	     l_addr_warning := 'Y';
             IF l_enable_log = 'Y' THEN
                 igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E073','IGS_AD_RELADDR_INT_ALL');
             END IF;
             IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                 IF (l_request_id IS NULL) THEN
                     l_request_id := fnd_global.conc_request_id;
                 END IF;
                 l_label := 'igs.plsql.igs_ad_imp_008.update_addr.warning '||'E073';

                 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                 fnd_message.set_token('INTERFACE_ID',reladdr_rec.interface_reladdr_id);
                 fnd_message.set_token('ERROR_CD','E073');
                 l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;
                 fnd_log.string_with_context( fnd_log.level_exception,
	                                      l_label,
		                              l_debug_str, NULL,
			                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
					    );
             END IF;

             UPDATE  Igs_Ad_RelAddr_Int_all
             SET     Error_Code = 'E073',
                     Status     = '4'
             WHERE   interface_reladdr_id = reladdr_rec.interface_reladdr_id;
	END IF;
        IF (reladdr_rec.site_use_code_1 IS NOT NULL) AND l_flag_check_status = 'Y' THEN
             --Check to see if for this address the site usage exist.
             OPEN  site_c(addr_rec.party_site_id, reladdr_rec.site_use_code_1);
             FETCH site_c INTO site_c_rec;
             l_party_site_id := addr_rec.party_site_id;
	     IF site_c%NOTFOUND THEN
                  l_party_site_use_id := NULL;
                  l_object_version_number := NULL;
                  --       call  to create party site uses for site use code 1
                  IGS_PE_PARTY_SITE_USE_PKG.HZ_PARTY_SITE_USES_AK(
                                        p_action                     => 'INSERT',
                                        p_rowid                      => l_row_id,
                                        p_party_site_use_id          => l_party_site_use_id,
                                        p_party_site_id              => l_party_site_id,
                                        p_site_use_type              => reladdr_rec.site_use_code_1,
                                        p_status                     => 'A',
                                        p_return_status              => l_return_status,
                                        p_msg_data                   => l_msg_data,
                                        p_last_update_date           => l_last_update_date,
                                        p_site_use_last_update_date  => l_site_use_last_update_date,
                                        P_profile_last_update_date   => l_profile_last_update_date,
                                        p_hz_party_site_use_ovn      => l_object_version_number
                                     );

                  IF l_return_status IN ('E','U') THEN
                       l_flag_check_status := 'N';
                       IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                           IF (l_request_id IS NULL) THEN
                              l_request_id := fnd_global.conc_request_id;
                           END IF;
                           l_label := 'igs.plsql.igs_ad_imp_008.update_addr.exception1 '||'E244';
                           fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                           fnd_message.set_token('INTERFACE_ID',reladdr_rec.interface_reladdr_id);
                           fnd_message.set_token('ERROR_CD','E244');
                           l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;
                           fnd_log.string_with_context( fnd_log.level_exception,
			                                l_label,
						        l_debug_str, NULL,
		                                        NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
						       );
                       END IF;
                       IF l_enable_log = 'Y' THEN
                           igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E244','IGS_AD_RELADDR_INT_ALL');
                       END IF;
                       UPDATE Igs_Ad_RelAddr_Int_all
                       SET Error_Code = 'E244',
                           Status     = '3'
                       WHERE INTERFACE_RELADDR_ID = reladdr_rec.INTERFACE_RELADDR_ID;
                  END IF;
             END IF;
             CLOSE site_c;
        END IF;

        IF (reladdr_rec.site_use_code_2 IS NOT NULL) AND l_flag_check_status = 'Y' THEN
             --Check to see if for this address these two site usages exist.
             OPEN  site_c(addr_rec.party_site_id, reladdr_rec.site_use_code_2);
             FETCH site_c INTO site_c_rec;
             l_party_site_id := addr_rec.party_site_id;
             IF site_c%NOTFOUND THEN
                 l_party_site_use_id := NULL;
                 l_object_version_number := NULL;
                 --       call  to create party site uses for site use code 2
                 IGS_PE_PARTY_SITE_USE_PKG.HZ_PARTY_SITE_USES_AK(
                                        p_action                     => 'INSERT',
                                        p_rowid                      => l_row_id,
                                        p_party_site_use_id          => l_party_site_use_id,
                                        p_party_site_id              => l_party_site_id,
                                        p_site_use_type              => reladdr_rec.site_use_code_2,
                                        p_status                     => 'A',
                                        p_return_status              => l_return_status,
                                        p_msg_data                   => l_msg_data,
                                        p_last_update_date           => l_last_update_date,
                                        p_site_use_last_update_date  => l_site_use_last_update_date,
                                        P_profile_last_update_date   => l_profile_last_update_date,
                                        p_hz_party_site_use_ovn      => l_object_version_number
                                     );
                 IF l_return_status IN('E','U') THEN
                      l_flag_check_status := 'N';

                      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                         IF (l_request_id IS NULL) THEN
                             l_request_id := fnd_global.conc_request_id;
                         END IF;
                         l_label := 'igs.plsql.igs_ad_imp_008.update_addr.exception2 '||'E244';
                         fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                         fnd_message.set_token('INTERFACE_ID',reladdr_rec.interface_reladdr_id);
                         fnd_message.set_token('ERROR_CD','E244');
                         l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;
                         fnd_log.string_with_context( fnd_log.level_exception,
		                                      l_label,
				                      l_debug_str, NULL,
						      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
						     );
                      END IF;
                      IF l_enable_log = 'Y' THEN
                          igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E244','IGS_AD_RELADDR_INT_ALL');
                      END IF;
                      UPDATE  Igs_Ad_RelAddr_Int_all
                      SET  Error_Code = 'E244',
                           Status     = l_Status
                      WHERE INTERFACE_RELADDR_ID = reladdr_rec.INTERFACE_RELADDR_ID;
                 END IF;
             END IF;
             CLOSE site_c;
        END IF;

        IF l_flag_check_status = 'Y' AND l_addr_warning = 'N' THEN
            UPDATE   igs_ad_reladdr_int_all
            SET      error_code = NULL,
                     match_ind = '18',
                     status = '1'
            WHERE    interface_reladdr_id = reladdr_rec.interface_reladdr_id;

	     -- Address Record processed successfully
  	     l_addr_process := TRUE;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
           l_msg_data := SQLERRM;
           IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
               IF (l_request_id IS NULL) THEN
                    l_request_id := fnd_global.conc_request_id;
               END IF;
               l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_adr.update_addr_exception'||'E014';
               fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
               fnd_message.set_token('INTERFACE_ID',reladdr_rec.interface_reladdr_id);
               fnd_message.set_token('ERROR_CD','E014');
               l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;
               fnd_log.string_with_context( fnd_log.level_exception,
                                            l_label,
	                                    l_debug_str, NULL,
	                                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
					  );
           END IF;
           IF l_enable_log = 'Y' THEN
               igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E014','IGS_AD_RELADDR_INT_ALL');
           END IF;

           UPDATE Igs_Ad_RelAddr_Int_all
           SET  Error_Code = 'E014',
                Status     = '3'
           WHERE Interface_Reladdr_Id = reladdr_rec.Interface_Reladdr_Id;
    END Update_Addr;
    -- End Local Procedure Update_Addr
    -- Start Local Procedure to validate address
    PROCEDURE Validate_reladdr(reladdr_rec IN reladdr_rec_c%ROWTYPE , p_rel_person_id IN NUMBER , l_Check OUT NOCOPY VARCHAR2 ) AS
        CURSOR terr_name_cur(p_territory_code FND_TERRITORIES_VL.TERRITORY_CODE%TYPE) IS
        SELECT territory_short_name
        FROM  fnd_territories_vl
        WHERE territory_code = p_territory_code;

        CURSOR  birth_date_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
        SELECT birth_date
        FROM   igs_pe_person_base_v
        WHERE  person_id = cp_person_id;

	l_Status       igs_ad_relations_int.status%TYPE;
	l_Error_Code   igs_ad_relations_int.error_code%TYPE;
	l_birth_date   DATE;
    BEGIN
        l_Status := '3';
        IF (reladdr_rec.site_use_code_1 IS NOT NULL) THEN
            IF NOT (igs_pe_pers_imp_001.validate_lookup_type_code('PARTY_SITE_USE_CODE',reladdr_rec.site_use_code_1,222))  THEN
                IF l_enable_log = 'Y' THEN
                    igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E211','IGS_AD_RELADDR_INT_ALL');
                END IF;

                UPDATE igs_ad_reladdr_int_all
                SET    error_code = 'E211', status = '3'
                WHERE  interface_reladdr_id = reladdr_rec.interface_reladdr_id;

                l_check := 'TRUE';
                RETURN;
             END IF;
        END IF;

        IF (reladdr_rec.site_use_code_2 IS NOT NULL) THEN
            IF NOT (igs_pe_pers_imp_001.validate_lookup_type_code('PARTY_SITE_USE_CODE',reladdr_rec.site_use_code_2,222)) THEN
                IF l_enable_log = 'Y' THEN
	             igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E211','IGS_AD_RELADDR_INT_ALL');
		END IF;
	        UPDATE igs_ad_reladdr_int_all
		SET    error_code = 'E211', status = '3'
	        WHERE  interface_reladdr_id = reladdr_rec.interface_reladdr_id;
                l_Check:='TRUE';
                RETURN;
            END IF;
        END IF;
        --  Also  site_use_code_1 should not be the same as site_use_code_2.
	IF (reladdr_rec.site_use_code_1 IS NOT NULL AND reladdr_rec.site_use_code_2 IS NOT NULL) THEN
            IF reladdr_rec.site_use_code_1 = reladdr_rec.site_use_code_2 THEN
                IF l_enable_log = 'Y' THEN
                    igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E449','IGS_AD_RELADDR_INT_ALL');
                END IF;

		UPDATE igs_ad_reladdr_int_all
                SET    error_code = 'E449', status = '3'
                WHERE  interface_reladdr_id = reladdr_rec.interface_reladdr_id;

                l_Check:='TRUE';
                RETURN;
            END IF;
        END IF;

        -- Get Territory short name from territory code
        OPEN terr_name_cur(reladdr_rec.country);
        FETCH terr_name_cur INTO l_territory_short_name ;
        IF   terr_name_cur%NOTFOUND  THEN
             IF l_enable_log = 'Y' THEN
                   igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E209','IGS_AD_RELADDR_INT_ALL');
             END IF;

             UPDATE igs_ad_reladdr_int_all
             SET     error_code = 'E209', status = '3'
             WHERE   interface_reladdr_id = reladdr_rec.interface_reladdr_id;
             l_check := 'TRUE';
             CLOSE terr_name_cur;
             RETURN;
        END IF;
        CLOSE terr_name_cur;

	IF reladdr_rec.correspondence IS NOT NULL THEN
            IF reladdr_rec.correspondence  NOT IN ('Y','N') THEN
               IF l_enable_log = 'Y' THEN
                   igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E213','IGS_AD_RELADDR_INT_ALL');
               END IF;

                UPDATE igs_ad_reladdr_int_all
                SET    error_code = 'E213', status = '3'
                WHERE  interface_reladdr_id = reladdr_rec.interface_reladdr_id;

                l_Check:='TRUE';
                RETURN;
            END IF;
        END IF;

        IF reladdr_rec.start_dt IS NULL AND reladdr_rec.end_dt IS NOT NULL THEN
            IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage( reladdr_rec.interface_reladdr_id,'E407','IGS_AD_RELADDR_INT_ALL');
            END IF;

            UPDATE igs_ad_reladdr_int_all
            SET    error_code = 'E407', status = '3'
            WHERE  interface_reladdr_id = reladdr_rec.interface_reladdr_id;
            l_Check:='TRUE';
            RETURN;
     END IF;

     IF reladdr_rec.start_dt IS NOT NULL AND reladdr_rec.end_dt IS NOT NULL THEN
          IF reladdr_rec.start_dt > reladdr_rec.end_dt THEN
            IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage( reladdr_rec.interface_reladdr_id,'E406','IGS_AD_RELADDR_INT_ALL');
            END IF;

            UPDATE igs_ad_reladdr_int_all
            SET    error_code = 'E406', status = '3'
            WHERE  interface_reladdr_id = reladdr_rec.interface_reladdr_id;

            l_Check:='TRUE';
            RETURN;
          END IF;
     END IF;

     OPEN birth_date_cur(p_rel_person_id);
     FETCH birth_date_cur INTO l_birth_date;
     CLOSE birth_date_cur;

     -- start date must be greater than birth date
     IF l_birth_date IS NOT NULL THEN
        IF reladdr_rec.start_dt < l_birth_date THEN
             IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage( reladdr_rec.interface_reladdr_id,'E222','IGS_AD_RELADDR_INT_ALL');
             END IF;
             UPDATE igs_ad_reladdr_int_all
             SET    error_code = 'E222', status = '3'
             WHERE  interface_reladdr_id = reladdr_rec.interface_reladdr_id;
             l_check := 'TRUE';
             RETURN;
        END IF;
     END IF;

     l_Check:='FALSE';

  END validate_reladdr;
  --  end of local procedure validate address

BEGIN
p_api_version := 1.0;
l_Status := '3';
l_Check := 'FALSE';
l_Error_Code := 'E008';
l_prog_label := 'igs.plsql.igs_ad_imp_008.crt_rel_adr';
l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_adr.';
l_enable_log := igs_ad_imp_001.g_enable_log;
l_interface_run_id := igs_ad_imp_001.g_interface_run_id;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
    IF (l_request_id IS NULL) THEN
       l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_adr.begin';
    l_debug_str :=  'Igs_Ad_Imp_008.crt_rel_adr.begin';

    fnd_log.string_with_context( fnd_log.level_procedure,
		                 l_label,
			         l_debug_str, NULL,
		                 NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
				);
  END IF;

  l_rule := Igs_Ad_Imp_001.Find_Source_Cat_Rule(p_source_type_id,'RELATIONS_ADDRESS');
  --1. If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE Igs_Ad_RelAddr_Int_all
    SET status = '3',
        ERROR_CODE = 'E695'  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
    AND status = '2'
    AND interface_relations_id = p_interface_relations_id;
  END IF;

  --2. If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE Igs_Ad_RelAddr_Int_all mi
    SET status = '1',
        match_ind = '19'
    WHERE mi.interface_relations_id = p_interface_relations_id
      AND mi.status = '2'
      AND EXISTS ( SELECT 1
                   FROM   hz_locations pe, hz_party_sites ps
                   WHERE  ps.party_id = P_Rel_Person_Id
	           AND   ps.location_id = pe.location_id
		   AND   UPPER(pe.address1) = UPPER(mi.addr_line_1)
	           AND   UPPER(NVL(pe.address2,'NulL')) = UPPER(NVL(mi.addr_line_2,'NulL'))
		   AND   UPPER(NVL(pe.address3,'NulL')) = UPPER(NVL(mi.addr_line_3,'NulL'))
	           AND   UPPER(NVL(pe.address4,'NulL')) = UPPER(NVL(mi.addr_line_4,'NulL'))
		   AND   pe.country = UPPER(mi.country)
	           AND   UPPER(NVL(pe.county,'NulL')) = UPPER(NVL(mi.county,'NulL'))
	           AND   UPPER(NVL(mi.province,'NulL')) = UPPER(NVL(pe.province,'NulL'))
		   AND   UPPER(NVL(mi.city,'NulL')) = UPPER(NVL(pe.city,'NulL'))
	           AND   UPPER(NVL(mi.state,'NulL')) = UPPER(NVL(pe.state,'NulL'))
		 );
  END IF;

  --3. If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE Igs_Ad_RelAddr_Int_all
    SET status = '1'
    WHERE interface_relations_id = p_interface_relations_id
    AND match_ind IN ('18','19','22','23')
    AND status = '2';
  END IF;

  --4. If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE Igs_Ad_RelAddr_Int_all
    SET status = '3',
        ERROR_CODE = 'E695'
    WHERE interface_relations_id = p_interface_relations_id
      AND status = 2
      AND (match_ind IS NOT NULL AND match_ind NOT IN ('21','25'));
  END IF;

  --5. If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE Igs_Ad_RelAddr_Int_all mi
    SET status = '1',
        match_ind = '23'
    WHERE mi.interface_relations_id = p_interface_relations_id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS ( SELECT 1
                   FROM igs_pe_addr_v pe
                   WHERE UPPER(mi.addr_line_1) = UPPER(pe.addr_line_1)
	           AND   NVL(UPPER(mi.addr_line_2),'NulL') = NVL(UPPER(pe.addr_line_2),'NulL')
		   AND   NVL(UPPER(mi.addr_line_3),'NulL') = NVL(UPPER(pe.addr_line_3),'NulL')
	           AND   NVL(UPPER(mi.addr_line_4),'NulL') = NVL(UPPER(pe.addr_line_4),'NulL')
	           AND   UPPER(mi.country) = UPPER(pe.country_cd)
		   AND   NVL(UPPER(mi.county),'NulL') = NVL(UPPER(pe.county),'NulL')
	           AND   NVL(UPPER(mi.province),'NulL') = NVL(UPPER(pe.province),'NulL')
	           AND   NVL(UPPER(mi.city),'NulL') = NVL(UPPER(pe.city),'NulL')
	           AND   NVL(UPPER(mi.state),'NulL') = NVL(UPPER(pe.state),'NulL')
	           AND   NVL(TRUNC(mi.start_dt),IGS_GE_DATE.igsdate('4712/12/31')) = NVL(TRUNC(pe.start_dt),IGS_GE_DATE.igsdate('4712/12/31'))
	           AND   NVL(TRUNC(mi.end_dt),IGS_GE_DATE.igsdate('4712/12/31')) = NVL(TRUNC(pe.end_dt),IGS_GE_DATE.igsdate('4712/12/31'))
	           AND   NVL(UPPER(mi.correspondence),'N') = NVL(UPPER(pe.correspondence),'N')
		   AND   NVL(UPPER(mi.postal_code),'NulL') = NVL(UPPER(pe.postal_code),'NulL')
	           AND   NVL(UPPER(mi.other_details_1),'NulL') = NVL(UPPER(pe.other_details_1),'NulL')
		   AND   NVL(UPPER(mi.other_details_2),'NulL') = NVL(UPPER(pe.other_details_2),'NulL')
	           AND   NVL(UPPER(mi.other_details_3),'NulL') = NVL(UPPER(pe.other_details_3),'NulL')
	           AND   pe.person_id  = P_Rel_Person_Id
             );
  END IF;

  --6. If rule is R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE Igs_Ad_RelAddr_Int_all mi
    SET status = '3',
        match_ind = '20'
    WHERE mi.interface_relations_id = p_interface_relations_id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS (SELECT 1
                   FROM   hz_locations pe, hz_party_sites ps
                   WHERE  ps.party_id = P_Rel_Person_Id
                   AND   ps.location_id = pe.location_id
	           AND   UPPER(pe.address1) = UPPER(mi.addr_line_1)
		   AND   UPPER(NVL(pe.address2,'NulL')) = UPPER(NVL(mi.addr_line_2,'NulL'))
                   AND   UPPER(NVL(pe.address3,'NulL')) = UPPER(NVL(mi.addr_line_3,'NulL'))
                   AND   UPPER(NVL(pe.address4,'NulL')) = UPPER(NVL(mi.addr_line_4,'NulL'))
                   AND   pe.country = UPPER(mi.country)
                   AND   UPPER(NVL(pe.county,'NulL')) = UPPER(NVL(mi.county,'NulL'))
                   AND   UPPER(NVL(mi.province,'NulL')) = UPPER(NVL(pe.province,'NulL'))
		   AND   UPPER(NVL(mi.city,'NulL')) = UPPER(NVL(pe.city,'NulL'))
                   AND   UPPER(NVL(mi.state,'NulL')) = UPPER(NVL(pe.state,'NulL'))
               );
  END IF;

  FOR reladdr_rec IN reladdr_rec_c(p_Interface_Relations_Id) LOOP
    reladdr_rec.site_use_code_1 := UPPER(reladdr_rec.site_use_code_1);
    reladdr_rec.site_use_code_2 := UPPER(reladdr_rec.site_use_code_2);
    reladdr_rec.country := UPPER(reladdr_rec.country);
    l_check :=  'FALSE';
    Validate_reladdr (reladdr_rec , p_rel_person_id , l_Check  );

    IF l_Check = 'FALSE' THEN
        --3.  Validate to see if this address already exist for this person.
        OPEN addr_c(reladdr_rec.addr_line_1,
                reladdr_rec.addr_line_2,
                reladdr_rec.addr_line_3,
                reladdr_rec.addr_line_4,
                reladdr_rec.country,
                reladdr_rec.county,
                reladdr_rec.province,
                reladdr_rec.city,
                reladdr_rec.state,
                P_Rel_Person_Id
                );
        FETCH addr_c INTO addr_rec;

        IF addr_c%FOUND THEN
          --4.  IF the address  already exist for this person THEN
          l_last_update_date := addr_rec.last_update_date;
          IF l_rule = 'I' THEN
               Update_Addr(addr_rec  , reladdr_rec , p_rel_person_id);
          ELSIF l_rule = 'R' THEN
             IF reladdr_rec.match_ind = '21' THEN
                Update_Addr(addr_rec  , reladdr_rec , p_rel_person_id);
             END IF;  -- match_ind=21
          END IF;  -- rule =R
        ELSE -- no duplicate addr_c%FOUND
        DECLARE
            l_flag_check_status VARCHAR2(1) := 'Y';
	    l_addr_warning VARCHAR2(1) := 'N';
        BEGIN
           --Create the person address.
	   IGS_PE_PERSON_ADDR_PKG.INSERT_ROW (
                 p_action       => NULL,
                 p_rowid        => l_row_id,
                 p_location_id      => l_location_id,
                 p_start_dt     => reladdr_rec.start_dt,
                 p_end_dt       => reladdr_rec.end_dt,
                 p_country      => reladdr_rec.country,
                 p_address_style    => NULL,
                 p_addr_line_1      => reladdr_rec.addr_line_1,
                 p_addr_line_2      => reladdr_rec.addr_line_2,
                 p_addr_line_3      => reladdr_rec.addr_line_3,
                 p_addr_line_4      => reladdr_rec.addr_line_4,
                 p_date_last_verified   => NULL,
                 p_correspondence   => NVL(reladdr_rec.correspondence,'N'),
                 p_city         => reladdr_rec.city,
                 p_state        => reladdr_rec.state,
                 p_province     => reladdr_rec.province,
                 p_county       => reladdr_rec.county,
                 p_postal_code      => reladdr_rec.postal_code,
                 p_address_lines_phonetic  => NULL,
                 p_delivery_point_code  => NULL,
                 p_other_details_1  => reladdr_rec.other_details_1,
                 p_other_details_2  => reladdr_rec.other_details_2,
                 p_other_details_3  => reladdr_rec.other_details_3,
                 l_return_status    => l_return_status,
                 l_msg_data     => l_msg_data,
                 p_party_id     => p_rel_person_id,
                 p_party_site_id    => l_party_site_id,
                 p_party_type       => NULL,
                 p_last_update_date => l_last_update_date,
		 p_party_site_ovn   => l_party_site_ovn,
	         p_location_ovn     => l_location_ovn,
		 p_status       => 'A'
                );


           IF l_return_status IN ('E','U') THEN
                l_flag_check_status := 'N';
                IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
	            IF (l_request_id IS NULL) THEN
		            l_request_id := fnd_global.conc_request_id;
                    END IF;
                    l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_adr.exception1 '||'E322';
                    fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
	            fnd_message.set_token('INTERFACE_ID',reladdr_rec.interface_reladdr_id);
		    fnd_message.set_token('ERROR_CD','E322');
	            l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;
	            fnd_log.string_with_context( fnd_log.level_exception,
			                         l_label,
					         l_debug_str, NULL,
		                                 NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
					        );
                END IF;

                IF l_enable_log = 'Y' THEN
                    igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E322','IGS_AD_RELADDR_INT_ALL');
                END IF;
                UPDATE Igs_Ad_RelAddr_Int_all
                SET Error_Code = 'E322',
                    Status     = '3'
                WHERE INTERFACE_RELADDR_ID = reladdr_rec.INTERFACE_RELADDR_ID;
	   ELSIF l_return_status = 'W' THEN
	        l_addr_warning := 'Y';
                IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
	            IF (l_request_id IS NULL) THEN
		            l_request_id := fnd_global.conc_request_id;
                    END IF;
                    l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_adr.warning '||'E073';
                    fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
	            fnd_message.set_token('INTERFACE_ID',reladdr_rec.interface_reladdr_id);
		    fnd_message.set_token('ERROR_CD','E073');
	            l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;
	            fnd_log.string_with_context( fnd_log.level_exception,
			                         l_label,
					         l_debug_str, NULL,
		                                 NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
					        );
                END IF;

                IF l_enable_log = 'Y' THEN
                    igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E073','IGS_AD_RELADDR_INT_ALL');
                END IF;
                UPDATE Igs_Ad_RelAddr_Int_all
                SET Error_Code = 'E073',
                    Status     = '4'
                WHERE INTERFACE_RELADDR_ID = reladdr_rec.INTERFACE_RELADDR_ID;

	   END IF;

           -- code to  create part site use if site use code1 is not null
           IF (reladdr_rec.site_use_code_1 IS NOT NULL) AND l_flag_check_status = 'Y' THEN
	          l_party_site_use_id := NULL;
		  l_object_version_number := NULL;
		  IGS_PE_PARTY_SITE_USE_PKG.HZ_PARTY_SITE_USES_AK(
                                        p_action                     => 'INSERT',
                                        p_rowid                      => l_row_id,
                                        p_party_site_use_id          => l_party_site_use_id,
                                        p_party_site_id              => l_party_site_id,
                                        p_site_use_type              => reladdr_rec.site_use_code_1,
                                        p_status                     => 'A',
                                        p_return_status              => l_return_status,
                                        p_msg_data                   => l_msg_data,
                                        p_last_update_date           => l_last_update_date,
                                        p_site_use_last_update_date  => l_site_use_last_update_date,
                                        P_profile_last_update_date   => l_profile_last_update_date,
                                        p_hz_party_site_use_ovn      => l_object_version_number
                                     );

                  IF l_return_status IN ('E','U') THEN
                        l_flag_check_status := 'N';
                        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                           IF (l_request_id IS NULL) THEN
                               l_request_id := fnd_global.conc_request_id;
                           END IF;
                           l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_adr.exception2 '||'E322';
                           fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		           fnd_message.set_token('INTERFACE_ID',reladdr_rec.interface_reladdr_id);
			   fnd_message.set_token('ERROR_CD','E322');
	                   l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;
	                   fnd_log.string_with_context( fnd_log.level_exception,
			                                l_label,
					                l_debug_str, NULL,
		                                        NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
						       );
                        END IF;
                        IF l_enable_log = 'Y' THEN
	                    igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E322','IGS_AD_RELADDR_INT_ALL');
                        END IF;
                        UPDATE Igs_Ad_RelAddr_Int_all
                        SET Error_Code = 'E322',
                            Status     = '3'
                        WHERE INTERFACE_RELADDR_ID = reladdr_rec.INTERFACE_RELADDR_ID;
                  END IF;
           END IF;
           -- code to  create part site use if site use code2 is not null
           IF (reladdr_rec.site_use_code_2 IS NOT NULL) AND l_flag_check_status = 'Y' THEN
              l_party_site_use_id := NULL;
              l_object_version_number := NULL;
              IGS_PE_PARTY_SITE_USE_PKG.HZ_PARTY_SITE_USES_AK(
                                          p_action                     => 'INSERT',
                                          p_rowid                      => l_row_id,
                                          p_party_site_use_id          => l_party_site_use_id,
                                          p_party_site_id              => l_party_site_id,
                                          p_site_use_type              => reladdr_rec.site_use_code_2,
                                          p_status                     => 'A',
                                          p_return_status              => l_return_status,
                                          p_msg_data                   => l_msg_data,
                                          p_last_update_date           => l_last_update_date,
                                          p_site_use_last_update_date  => l_site_use_last_update_date,
                                          P_profile_last_update_date   => l_profile_last_update_date,
                                          p_hz_party_site_use_ovn      => l_object_version_number
                                     );

              IF l_return_status IN ('E','U') THEN
                  l_flag_check_status := 'N';

                  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                       IF (l_request_id IS NULL) THEN
                            l_request_id := fnd_global.conc_request_id;
                       END IF;

                        l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_adr.exception '||'E244';

                        fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                        fnd_message.set_token('INTERFACE_ID',reladdr_rec.interface_reladdr_id);
                        fnd_message.set_token('ERROR_CD','E244');

                        l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

                        fnd_log.string_with_context( fnd_log.level_exception,
	                                             l_label,
		                                     l_debug_str, NULL,
			                             NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
						   );
                  END IF;

                  IF l_enable_log = 'Y' THEN
                       igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E244','IGS_AD_RELADDR_INT_ALL');
                  END IF;

		  UPDATE Igs_Ad_RelAddr_Int_all
                  SET Error_Code = 'E244',
                      Status     = '3'
                  WHERE INTERFACE_RELADDR_ID = reladdr_rec.INTERFACE_RELADDR_ID;
              END IF;
           END IF;

           IF l_flag_check_status = 'Y' AND l_addr_warning = 'N' THEN
              UPDATE  igs_ad_reladdr_int_all
              SET     error_code = NULL,
                      status     = '1'
              WHERE   interface_reladdr_id = reladdr_rec.interface_reladdr_id;

	      l_addr_process := TRUE;
           END IF;
        EXCEPTION
          WHEN OTHERS THEN
            IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
              IF (l_request_id IS NULL) THEN
                   l_request_id := fnd_global.conc_request_id;
               END IF;

               l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_adr.exception '||'E518';

               fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
               fnd_message.set_token('INTERFACE_ID',reladdr_rec.interface_reladdr_id);
               fnd_message.set_token('ERROR_CD','E518');

               l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

               fnd_log.string_with_context( fnd_log.level_exception,
                                            l_label,
                                            l_debug_str, NULL,
                                            NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
					   );
            END IF;

            IF l_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(reladdr_rec.interface_reladdr_id,'E518','IGS_AD_RELADDR_INT_ALL');
            END IF;

            UPDATE  Igs_Ad_RelAddr_Int_all
            SET  Error_Code = 'E518',
                 Status     = '3'
            WHERE Interface_Reladdr_Id = reladdr_rec.Interface_Reladdr_Id;
        END;
      END IF;  -- c_addr
      CLOSE addr_c;
    END IF;  -- l_check
  END LOOP;

  IF (l_addr_process) THEN
      --populate IGS_PE_WF_GEN.TI_ADDR_CHG_PERSONS table with party id to generate notification at the end of process
      IGS_PE_WF_GEN.TI_ADDR_CHG_PERSONS(NVL(IGS_PE_WF_GEN.TI_ADDR_CHG_PERSONS.LAST,0)+1) := p_rel_person_id;
  END IF;

END crt_rel_adr;


PROCEDURE prc_rel_con_dtl (p_interface_relations_id NUMBER,
                           p_rel_person_id NUMBER,
                           p_source_type_id NUMBER) AS

  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER;
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

  --1. Pick up all the records from the table IGS_AD_REL_CON_INT.
  CURSOR relcon_rec_c(cp_interface_relations_id NUMBER) IS
  SELECT *
  FROM   igs_ad_rel_con_int_all
  WHERE  status = '2'
  AND    interface_relations_id = cp_interface_relations_id;

  --2.  The duplicate check in the table HZ_CONTACT_POINTS.
  CURSOR rel_cont_del_dup_rec_c
  (
    p_contact_point_type  igs_ad_rel_con_int.contact_point_type%TYPE,
    p_email_format        igs_ad_rel_con_int.email_format%TYPE,
    p_email_address       igs_ad_rel_con_int.email_addrress%TYPE,
    p_phone_line_type     igs_ad_rel_con_int.phone_line_type%TYPE,
    p_phone_country_code  igs_ad_rel_con_int.phone_country_code%TYPE,
    p_phone_area_code     igs_ad_rel_con_int.phone_area_code%TYPE,
    p_phone_number        igs_ad_rel_con_int.phone_number%TYPE
  ) IS
  SELECT contact_point_id,
         primary_flag ,
         email_format ,
         phone_country_code ,
         phone_line_type ,
         phone_area_code ,
         phone_number    ,
         phone_extension
  FROM   hz_contact_points
  WHERE  owner_table_id = p_rel_person_id
  AND    contact_point_type = p_contact_point_type
  AND    owner_table_name = 'HZ_PARTIES'
  AND    (( nvl(email_format,'NulL') = nvl(p_email_format,'NulL')  AND
            UPPER(nvl(email_address,'NulL')) =  UPPER(nvl(p_email_address,'NulL')) AND
            contact_point_type = 'EMAIL'    )OR
      ( nvl(phone_line_type,'NulL') = nvl(p_phone_line_type,'NulL') AND
            nvl(phone_country_code,'NulL') = nvl(p_phone_country_code,'NulL') AND
            UPPER(nvl(phone_area_code,'NulL')) = UPPER(nvl(p_phone_area_code,'NulL')) AND
            nvl(phone_number,'NulL') = nvl(p_phone_number,'NulL') AND
        contact_point_type = 'PHONE' ));

  rel_cont_del_dup_rec  rel_cont_del_dup_rec_c%ROWTYPE;

  --Check for discrepancy in data for all the columns in the table
  --HZ_CONTACT_POINTS excepting the Primary Key Columns.


  CURSOR get_obj_version(c_contact_point_id NUMBER) IS
  SELECT object_version_number
  FROM    hz_contact_points
  WHERE   contact_point_id = c_contact_point_id;

  l_obj_ver            hz_contact_points.object_version_number%TYPE;

  l_return_status      IGS_AD_RELATIONS_INT.STATUS%TYPE;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_Count              NUMBER;
  l_Status             IGS_AD_RELATIONS_INT.STATUS%TYPE;
  l_Error_Code         IGS_AD_RELATIONS_INT.Error_Code%TYPE;
  l_rule               igs_ad_source_cat.discrepancy_rule_cd%TYPE;

  contact_point_rec    HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
  email_rec            HZ_CONTACT_POINT_V2PUB.email_rec_type;
  phone_rec            HZ_CONTACT_POINT_V2PUB.phone_rec_type;
  l_telex_rec          HZ_CONTACT_POINT_V2PUB.telex_rec_type;
  l_web_rec            HZ_CONTACT_POINT_V2PUB.web_rec_type;
  l_edi_rec            HZ_CONTACT_POINT_V2PUB.edi_rec_type;
  l_last_update_date   DATE;
  l_check VARCHAR2(30);

 tmp_var1          VARCHAR2(2000);
 tmp_var           VARCHAR2(2000);
-- Start Of Local Procedure prc_rel_con.
PROCEDURE prc_rel_con (p_rel_con_rec relcon_rec_c%ROWTYPE) AS

  l_return_status      igs_ad_relations_int.status%TYPE;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_Status             igs_ad_relations_int.status%TYPE;
  l_Error_Code         igs_ad_relations_int.error_code%TYPE;
  contact_point_rec    HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
  email_rec            HZ_CONTACT_POINT_V2PUB.email_rec_type;
  phone_rec            HZ_CONTACT_POINT_V2PUB.phone_rec_type;
  l_telex_rec          HZ_CONTACT_POINT_V2PUB.telex_rec_type;
  l_web_rec            HZ_CONTACT_POINT_V2PUB.web_rec_type;
  l_edi_rec            HZ_CONTACT_POINT_V2PUB.edi_rec_type;
  ln_Error_Code        NUMBER;
  l_last_update_date   DATE;

  tmp_var1          VARCHAR2(2000);
  tmp_var           VARCHAR2(2000);
  l_contact_point_id   NUMBER;
  l_dummy              VARCHAR2(1);

BEGIN

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

       IF (l_request_id IS NULL) THEN
       l_request_id := fnd_global.conc_request_id;
       END IF;

       l_label := 'igs.plsql.igs_ad_imp_008.prc_rel_con_dtl.begin_prc_rel_con';
       l_debug_str :=  'Igs_Ad_Imp_008.prc_rel_con_dtl.prc_rel_con';

       fnd_log.string_with_context( fnd_log.level_procedure,
                    l_label,
                    l_debug_str, NULL,
                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

  --5.  if the validation is successful then, insert this record into the table hz_contact_points.
  --items in the record p_contact_point_rec
  contact_point_rec.contact_point_type  := p_rel_con_rec.contact_point_type;
  --  contact_point_rec.status  := p_rel_con_rec.status; ssomani, these two statuses are different 15 March 2001
  contact_point_rec.owner_table_name  := 'HZ_PARTIES';
  contact_point_rec.primary_flag  := NVL(p_rel_con_rec.primary_flag,'N');
  contact_point_rec.content_source_type  := 'USER_ENTERED';
  contact_point_rec.created_by_module := 'IGS';
  contact_point_rec.owner_table_id      := p_rel_person_id ; --ssomani, added this 15 March 2001

  --items in the record p_email_rec
  IF p_rel_con_rec.contact_point_type = 'EMAIL' THEN
     email_rec.email_format  := p_rel_con_rec.email_format;
     email_rec.email_address  := p_rel_con_rec.email_addrress;
  ELSIF p_rel_con_rec.contact_point_type = 'PHONE' THEN
  --items in the record p_phone_rec
     phone_rec.phone_country_code  := p_rel_con_rec.phone_country_code;
     phone_rec.phone_line_type     := p_rel_con_rec.phone_line_type;
     phone_rec.phone_area_code  := p_rel_con_rec.phone_area_code;
     phone_rec.phone_number     := p_rel_con_rec.phone_number;
     phone_rec.phone_extension  := p_rel_con_rec.phone_extension;
  END IF;
         HZ_CONTACT_POINT_V2PUB.create_contact_point(
                               p_init_msg_list         => FND_API.G_FALSE,
                               p_contact_point_rec     => contact_point_rec,
                               p_edi_rec               => l_edi_rec,
                               p_email_rec              => email_rec,
                               p_phone_rec              => phone_rec,
                               p_telex_rec              => l_telex_rec,
                               p_web_rec                => l_web_rec,
                               x_return_status          => l_return_status,
                               x_msg_count              => l_msg_count,
                               x_msg_data               => l_msg_data,
                               x_contact_point_id       => l_contact_point_id);
  IF l_return_status IN ( 'E' , 'U' ) THEN
    IF l_msg_count > 1 THEN
         FOR i IN 1..l_msg_count  LOOP
          tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          tmp_var1 := tmp_var1 || ' '|| tmp_var;
         END LOOP;
    l_msg_data := tmp_var1;
    END IF;

    ln_Error_Code   :=        'E322';

    IF l_enable_log = 'Y' THEN
       igs_ad_imp_001.logerrormessage(p_rel_con_rec.interface_rel_con_id,'E322','IGS_AD_REL_CON_INT_ALL');
    END IF;

    UPDATE igs_ad_rel_con_int_all
    SET    error_code  = ln_Error_Code, --error code for the insert failure
           status      = '3'
    WHERE  interface_rel_con_id = p_rel_con_rec.interface_rel_con_id;

  ELSE
    UPDATE igs_ad_rel_con_int_all
    SET    status      = '1'
    WHERE  interface_rel_con_id = p_rel_con_rec.interface_rel_con_id;
  END IF;
END prc_rel_con;
-- End Of Local Procedure prc_rel_con.
-- Start ol Local Procedure validate contact
PROCEDURE Validate_Contact(relcon_rec relcon_rec_c%ROWTYPE,l_Check OUT NOCOPY VARCHAR2 ) AS

  -- 4. phone country code is now to be validated against
  -- HZ_PHONE_COUNTRY_CODEs  : HZ F validations -- ssawhney  bug 2203778
  CURSOR c_ph_cntry_cd (p_phone_country_code VARCHAR2) IS
  SELECT 'X'
  FROM   HZ_PHONE_COUNTRY_CODES
  WHERE PHONE_COUNTRY_CODE = p_phone_country_code;
  l_dummy                  VARCHAR2(1);
BEGIN

    -- Validate contact point type
  IF NOT
  (igs_pe_pers_imp_001.validate_lookup_type_code('COMMUNICATION_TYPE',relcon_rec.contact_point_type,222))
  THEN
          --   If the validation is not successful.

         IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(relcon_rec.interface_rel_con_id,'E246','IGS_AD_REL_CON_INT_ALL');
          END IF;

          UPDATE igs_ad_rel_con_int_all
          SET    status      = '3',
                 error_code  = 'E246'
          WHERE  interface_rel_con_id = relcon_rec.interface_rel_con_id;
      l_Check := 'TRUE';
          RETURN;
  END IF;

  IF relcon_rec.primary_flag IS NOT NULL THEN
    IF relcon_rec.primary_flag NOT IN ('N','Y') THEN

        IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(relcon_rec.interface_rel_con_id,'E450','IGS_AD_REL_CON_INT_ALL');
        END IF;

              UPDATE igs_ad_rel_con_int_all
              SET    error_code  = 'E450',
              status      = '3'
              WHERE  interface_rel_con_id = relcon_rec.interface_rel_con_id;
          l_Check := 'TRUE';
        RETURN;
    END IF;
  END IF;

  IF relcon_rec.contact_point_type = 'PHONE' THEN
    --     Validation to check whether phone line type or phone number are null
    IF relcon_rec.phone_number IS NULL OR relcon_rec.phone_line_type IS NULL THEN

    IF l_enable_log = 'Y' THEN
       igs_ad_imp_001.logerrormessage(relcon_rec.interface_rel_con_id,'E250','IGS_AD_REL_CON_INT_ALL');
    END IF;

              UPDATE igs_ad_rel_con_int_all
              SET    error_code  = 'E250',
              status      = '3'
              WHERE  interface_rel_con_id = relcon_rec.interface_rel_con_id;
          l_Check := 'TRUE';
        RETURN;
    END IF;

    -- Validate the PHONE_LINE_TYPE
    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('PHONE_LINE_TYPE',relcon_rec.phone_line_type,222))
    THEN
          --   If the validation is not successful.


      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(relcon_rec.interface_rel_con_id,'E247','IGS_AD_REL_CON_INT_ALL');
      END IF;

          UPDATE igs_ad_rel_con_int_all
          SET    status      = '3',
                 error_code   = 'E247'
          WHERE  interface_rel_con_id = relcon_rec.interface_rel_con_id;
          l_Check := 'TRUE';
          RETURN;
    END IF;

    -- Validate the PHONE_COUNTRY_CODE
    IF relcon_rec.phone_country_code IS NOT NULL THEN
        OPEN c_ph_cntry_cd(relcon_rec.phone_country_code);
        FETCH c_ph_cntry_cd INTO l_dummy;
      IF c_ph_cntry_cd%NOTFOUND THEN
          --   If the validation is not successful.

    IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(relcon_rec.interface_rel_con_id,'E173','IGS_AD_REL_CON_INT_ALL');
    END IF;

          UPDATE igs_ad_rel_con_int_all
          SET    status      = '3',
                 error_code   = 'E173'
          WHERE  interface_rel_con_id = relcon_rec.interface_rel_con_id;
          CLOSE c_ph_cntry_cd;
          l_Check := 'TRUE';
          RETURN;
      END IF;
      CLOSE c_ph_cntry_cd;
    END IF;

  END IF;

  IF relcon_rec.contact_point_type = 'EMAIL' THEN
      -- Validation to check whether email address is null
    IF relcon_rec.email_addrress IS NULL THEN

    IF l_enable_log = 'Y' THEN
       igs_ad_imp_001.logerrormessage(relcon_rec.interface_rel_con_id,'E251','IGS_AD_REL_CON_INT_ALL');
    END IF;

              UPDATE igs_ad_rel_con_int_all
              SET    error_code  = 'E251',
              status      = '3'
              WHERE  interface_rel_con_id = relcon_rec.interface_rel_con_id;
          l_Check := 'TRUE';
        RETURN;
    END IF;

    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('EMAIL_FORMAT',relcon_rec.email_format,222))
    THEN

        IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(relcon_rec.interface_rel_con_id,'E248','IGS_AD_REL_CON_INT_ALL');
        END IF;

              UPDATE igs_ad_rel_con_int_all
              SET    error_code  = 'E248',
              status      = '3'
              WHERE  interface_rel_con_id = relcon_rec.interface_rel_con_id;
          l_Check := 'TRUE';
          RETURN;
    END IF;
  END IF;

  l_check := 'FALSE';

END Validate_Contact;
--end olf local procedure validate contact

BEGIN
   l_check := 'FALSE';
   l_Status := '3';
   l_Error_Code := 'E008';
   l_prog_label := 'igs.plsql.igs_ad_imp_008.prc_rel_con_dtl';
   l_label := 'igs.plsql.igs_ad_imp_008.prc_rel_con_dtl.';
   l_enable_log := igs_ad_imp_001.g_enable_log;
   l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

       IF (l_request_id IS NULL) THEN
       l_request_id := fnd_global.conc_request_id;
       END IF;

       l_label := 'igs.plsql.igs_ad_imp_008.prc_rel_con_dtl.begin';
       l_debug_str :=  'Igs_Ad_Imp_008.prc_rel_con_dtl';

       fnd_log.string_with_context( fnd_log.level_procedure,
                    l_label,
                    l_debug_str, NULL,
                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

  l_rule := Igs_Ad_Imp_001.Find_Source_Cat_Rule(p_source_type_id,'RELATIONS_CONTACTS');

  --1. If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_ad_rel_con_int_all
    SET status = '3',
        ERROR_CODE = 'E695'  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND status = '2'
      AND interface_relations_id = p_interface_relations_id;
  END IF;

  --2. If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_ad_rel_con_int_all mi
    SET status = '1',
        match_ind = '19'
    WHERE mi.interface_relations_id = p_interface_relations_id
      AND mi.status = '2'
      AND EXISTS ( SELECT '1'
                   FROM   hz_contact_points pe
           WHERE  pe.owner_table_id = p_rel_person_id
           AND    pe.contact_point_type = UPPER(mi.contact_point_type)
           AND    pe.owner_table_name = 'HZ_PARTIES'
           AND   (pe.contact_point_type = 'EMAIL' AND
                  (NVL(pe.email_format,'NulL') = NVL(UPPER(mi.email_format),'NulL')  AND
                  UPPER(NVL(pe.email_address,'NulL')) =  UPPER(NVL(mi.email_addrress,'NulL'))
                ) OR
                ( pe.contact_point_type = 'PHONE' AND
                NVL(pe.phone_line_type,'NulL') = NVL(UPPER(mi.phone_line_type),'NulL') AND
                NVL(pe.phone_country_code,'NulL') = NVL(UPPER(mi.phone_country_code),'NulL') AND
                UPPER(NVL(pe.phone_area_code,'NulL')) = UPPER(NVL(mi.phone_area_code,'NulL')) AND
                NVL(UPPER(pe.phone_number),'NulL') = NVL(UPPER(mi.phone_number),'NulL')
                 ))
                );
  END IF;

  --3. If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_ad_rel_con_int_all
    SET status = '1'
    WHERE interface_relations_id = p_interface_relations_id
      AND match_ind IN ('18','19','22','23')
      AND status = '2';
  END IF;

  --4 If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_ad_rel_con_int_all
    SET status = '3',
        ERROR_CODE = 'E695'
    WHERE interface_relations_id = p_interface_relations_id
      AND status = '2'
      AND (match_ind IS NOT NULL AND match_ind NOT IN ('21','25'));
  END IF;

  --5. If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_ad_rel_con_int_all mi
    SET status = '1',
        match_ind = '23'
    WHERE mi.interface_relations_id = p_interface_relations_id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS ( SELECT 1
                    FROM   hz_contact_points pe
            WHERE  pe.owner_table_id = p_rel_person_id
              AND   NVL(pe.primary_flag,'N') = NVL(UPPER(mi.primary_flag),'N')
              AND   NVL(UPPER(pe.phone_extension),'NulL') = NVL(UPPER(mi.phone_extension),'NulL')
              AND   pe.contact_point_type  =  UPPER(mi.contact_point_type)
              AND   NVL(pe.email_format,'NulL') =   NVL(UPPER(mi.email_format),'NulL')
              AND   NVL(pe.phone_line_type,'NulL')   = NVL(UPPER(mi.phone_line_type),'NulL')
              AND   NVL(pe.phone_country_code,'NulL') =   NVL(UPPER(mi.phone_country_code),'NulL')
              AND   NVL(UPPER(pe.phone_area_code),'NulL')   = NVL(UPPER(mi.phone_area_code),'NulL')
              AND   NVL(UPPER(pe.phone_number),'NulL') =   NVL(UPPER(mi.phone_number),'NulL')
              AND   NVL(UPPER(pe.email_address),'NulL') =   NVL(UPPER(mi.email_addrress),'NulL')
             );
  END IF;

  --6. If rule is R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_ad_rel_con_int_all mi
    SET status = '3',
        match_ind = '20',
    DUP_CONTACT_POINT_ID = (SELECT pe.contact_point_id
                 FROM   hz_contact_points pe
                 WHERE  pe.owner_table_id = p_rel_person_id
                 AND    pe.contact_point_type = UPPER(mi.contact_point_type)
                 AND    pe.owner_table_name = 'HZ_PARTIES'
                 AND ((pe.contact_point_type = 'EMAIL' AND
                    NVL(pe.email_format,'NulL') = NVL(UPPER(mi.email_format),'NulL')  AND
                    UPPER(NVL(pe.email_address,'NulL')) =  UPPER(NVL(mi.email_addrress,'NulL'))
                    )
                    OR
                   (pe.contact_point_type = 'PHONE' AND
                    NVL(pe.phone_line_type,'NulL') = NVL(UPPER(mi.phone_line_type),'NulL') AND
                    NVL(pe.phone_country_code,'NulL') = NVL(UPPER(mi.phone_country_code),'NulL') AND
                    UPPER(NVL(pe.phone_area_code,'NulL')) = UPPER(NVL(mi.phone_area_code,'NulL')) AND
                    NVL(UPPER(pe.phone_number),'NulL') = NVL(UPPER(mi.phone_number),'NulL')
                     ))
                 AND ROWNUM = 1)
    WHERE mi.interface_relations_id = p_interface_relations_id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS (SELECT '1'
          FROM   hz_contact_points pe
          WHERE  pe.owner_table_id = p_rel_person_id
             AND pe.contact_point_type = UPPER(mi.contact_point_type)
             AND pe.owner_table_name = 'HZ_PARTIES'
             AND (pe.contact_point_type = 'EMAIL' AND
                (NVL(pe.email_format,'NulL') = NVL(UPPER(mi.email_format),'NulL')  AND
                UPPER(NVL(pe.email_address,'NulL')) =  UPPER(NVL(mi.email_addrress,'NulL'))
                )
                OR
               (pe.contact_point_type = 'PHONE' AND
                NVL(pe.phone_line_type,'NulL') = NVL(UPPER(mi.phone_line_type),'NulL') AND
                NVL(pe.phone_country_code,'NulL') = NVL(UPPER(mi.phone_country_code),'NulL') AND
                UPPER(NVL(pe.phone_area_code,'NulL')) = UPPER(NVL(mi.phone_area_code,'NulL')) AND
                NVL(UPPER(pe.phone_number),'NulL') = NVL(UPPER(mi.phone_number),'NulL')
                 ))
           );
  END IF;

  --1. Pick up all the records from the table IGS_AD_REL_CON_INT.
  FOR relcon_rec IN relcon_rec_c(p_interface_relations_id) LOOP
  relcon_rec.contact_point_type := UPPER(relcon_rec.contact_point_type);
  relcon_rec.phone_line_type := UPPER(relcon_rec.phone_line_type);
  relcon_rec.primary_flag := UPPER(relcon_rec.primary_flag);
  relcon_rec.email_format := UPPER(relcon_rec.email_format);
  l_check := 'FALSE';
  Validate_Contact(relcon_rec ,l_Check  );
  rel_cont_del_dup_rec.contact_point_id := NULL;
  IF l_Check = 'FALSE' THEN
    OPEN rel_cont_del_dup_rec_c(
     relcon_rec.contact_point_type,
     relcon_rec.email_format,
     relcon_rec.email_addrress,
     relcon_rec.phone_line_type,
     relcon_rec.phone_country_code,
     relcon_rec.phone_area_code,
     relcon_rec.phone_number);

  FETCH rel_cont_del_dup_rec_c INTO rel_cont_del_dup_rec;
  CLOSE rel_cont_del_dup_rec_c;
  IF rel_cont_del_dup_rec.contact_point_id IS NOT NULL THEN
    IF l_rule = 'I' THEN
        --3.  If validations are successful then update the HZ_CONTACT_POINTS table.
        --items in the record p_contact_point_rec
      contact_point_rec.contact_point_type  := relcon_rec.contact_point_type;
      contact_point_rec.contact_point_id := rel_cont_del_dup_rec.contact_point_id;
--        contact_point_rec.status  := relcon_rec.status; --ssomani, unrelated statuses 15 March 2001
      contact_point_rec.owner_table_name  := 'HZ_PARTIES';
      contact_point_rec.primary_flag  :=NVL((NVL(relcon_rec.primary_flag,rel_cont_del_dup_rec.primary_flag)),FND_API.G_MISS_CHAR);

      --  contact_point_rec.content_source_type  := 'USER_ENTERED';
      --  contact_point_rec.created_by_module := 'IGS';

      IF relcon_rec.contact_point_type = 'EMAIL' THEN
           --items in the record p_email_rec
        email_rec.email_format  := NVL((NVL(relcon_rec.email_format,rel_cont_del_dup_rec.email_format)),FND_API.G_MISS_CHAR);
        email_rec.email_address  :=NVL((NVL(relcon_rec.email_addrress,rel_cont_del_dup_rec.email_format)),FND_API.G_MISS_CHAR);
      ELSIF relcon_rec.contact_point_type = 'PHONE' THEN
           --items in the record p_phone_rec
        phone_rec.phone_country_code  := NVL((NVL(relcon_rec.phone_country_code,rel_cont_del_dup_rec.phone_country_code)),FND_API.G_MISS_CHAR);
        phone_rec.phone_line_type  := NVL((NVL(relcon_rec.phone_line_type,rel_cont_del_dup_rec.phone_line_type)),FND_API.G_MISS_CHAR);
        phone_rec.phone_area_code  := NVL((NVL(relcon_rec.phone_area_code,rel_cont_del_dup_rec.phone_area_code)),FND_API.G_MISS_CHAR);
        phone_rec.phone_number     := NVL((NVL(relcon_rec.phone_number,rel_cont_del_dup_rec.phone_number)),FND_API.G_MISS_CHAR);
        phone_rec.phone_extension  := NVL((NVL(relcon_rec.phone_extension,rel_cont_del_dup_rec.phone_extension)),FND_API.G_MISS_CHAR);
      END IF;

      OPEN get_obj_version(rel_cont_del_dup_rec.contact_point_id);
      FETCH get_obj_version INTO l_obj_ver;
      CLOSE get_obj_version;

        --Usage of API HZ_CONTACT_POINT_PUB.update_contact_points
      HZ_CONTACT_POINT_V2PUB.update_contact_point(
                                    p_init_msg_list         => FND_API.G_FALSE,
                                    p_contact_point_rec     => contact_point_rec,
                                    p_email_rec             => email_rec ,
                                    p_phone_rec              => phone_rec,
                                    p_object_version_number => l_obj_ver,
                                    x_return_status         => l_return_status,
                                    x_msg_count             => l_msg_count,
                                    x_msg_data              => l_msg_data
                                                                );



        --4.  Update the IGS_AD_CONTACTS_INT  with the following values
        --   If the validation and update is successful.

      IF l_return_status NOT IN ('E','U') THEN
        UPDATE igs_ad_rel_con_int_all
        SET    status      = '1',
               match_ind   = '18'
        WHERE  interface_rel_con_id = relcon_rec.interface_rel_con_id;
      ELSE --ssomani added this check 15 March 2001

        IF l_msg_count > 1 THEN
          FOR i IN 1..l_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          l_msg_data := tmp_var1;
      END IF;

     IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_008.prc_rel_con_dtl.exception';

    fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
    fnd_message.set_token('INTERFACE_ID',relcon_rec.interface_rel_con_id);
    fnd_message.set_token('ERROR_CD','E014');

    l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

    fnd_log.string_with_context( fnd_log.level_exception,
                      l_label,
                      l_debug_str, NULL,
                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
     END IF;

    IF l_enable_log = 'Y' THEN
       igs_ad_imp_001.logerrormessage(relcon_rec.interface_rel_con_id,'E014','IGS_AD_REL_CON_INT_ALL');
    END IF;

      UPDATE igs_ad_rel_con_int_all
          SET    status      = '3',
                 error_code  = 'E014'
          WHERE  interface_rel_con_id = relcon_rec.interface_rel_con_id;
    END IF;

  ELSIF l_rule = 'R' THEN
    IF relcon_rec.match_ind = '21' THEN
        --3.  If validations are successful then update the HZ_CONTACT_POINTS table.
        --items in the record p_contact_point_rec
      contact_point_rec.contact_point_type  := relcon_rec.contact_point_type;
      contact_point_rec.contact_point_id := rel_cont_del_dup_rec.contact_point_id;
--        contact_point_rec.status  := relcon_rec.status; --ssomani, unrelated statuses 15 March 2001
      contact_point_rec.owner_table_name  := 'HZ_PARTIES';
      contact_point_rec.primary_flag  := NVL((NVL(relcon_rec.primary_flag,rel_cont_del_dup_rec.primary_flag)),FND_API.G_MISS_CHAR);

       -- contact_point_rec.content_source_type  := 'USER_ENTERED';
       -- contact_point_rec.created_by_module := 'IGS';

      IF relcon_rec.contact_point_type = 'EMAIL' THEN
           --items in the record p_email_rec
           email_rec.email_format  := NVL((NVL(relcon_rec.email_format,rel_cont_del_dup_rec.email_format)),FND_API.G_MISS_CHAR);
           email_rec.email_address  :=NVL((NVL(relcon_rec.email_addrress,rel_cont_del_dup_rec.email_format)),FND_API.G_MISS_CHAR);
      ELSIF relcon_rec.contact_point_type = 'PHONE' THEN
           --items in the record p_phone_rec
           phone_rec.phone_country_code  :=NVL((NVL(relcon_rec.phone_country_code,rel_cont_del_dup_rec.phone_country_code)),FND_API.G_MISS_CHAR);
           phone_rec.phone_line_type  := NVL((NVL(relcon_rec.phone_line_type,rel_cont_del_dup_rec.phone_line_type)),FND_API.G_MISS_CHAR);
           phone_rec.phone_area_code  := NVL((NVL(relcon_rec.phone_area_code,rel_cont_del_dup_rec.phone_area_code)),FND_API.G_MISS_CHAR);
           phone_rec.phone_number     := NVL((NVL(relcon_rec.phone_number,rel_cont_del_dup_rec.phone_number)),FND_API.G_MISS_CHAR);
           phone_rec.phone_extension  := NVL((NVL(relcon_rec.phone_extension,rel_cont_del_dup_rec.phone_extension)),FND_API.G_MISS_CHAR);
      END IF;

        -- SELECT LAST_UPDATE_DATEFROM HZ_CONTACT_POINTSWHERE OWNER_TABLE_ID = contact_point_id
        -- returned from duplicate check.

      OPEN get_obj_version(rel_cont_del_dup_rec.contact_point_id);
      FETCH get_obj_version INTO l_obj_ver;
      CLOSE get_obj_version;

        --Usage of API HZ_CONTACT_POINT_PUB.update_contact_points
      BEGIN --ssomani added BEGIN - EXCEPTION - END Block 15 March 2001

      HZ_CONTACT_POINT_V2PUB.update_contact_point(
                                       p_init_msg_list         => FND_API.G_FALSE,
                                       p_contact_point_rec     => contact_point_rec,
                                       p_email_rec             => email_rec ,
                                       p_phone_rec              => phone_rec,
                                       p_object_version_number => l_obj_ver,
                                       x_return_status         => l_return_status,
                                       x_msg_count             => l_msg_count,
                                       x_msg_data              => l_msg_data
                                                );

      IF l_return_status IN ('E','U') THEN
        IF l_msg_count > 1 THEN
          FOR i IN 1..l_msg_count  LOOP
                tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          l_msg_data := tmp_var1;
    END IF;

         IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

        IF (l_request_id IS NULL) THEN
            l_request_id := fnd_global.conc_request_id;
        END IF;

        l_label := 'igs.plsql.igs_ad_imp_008.prc_rel_con_dtl.exception '||'E014';

        fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
        fnd_message.set_token('INTERFACE_ID',relcon_rec.interface_rel_con_id);
        fnd_message.set_token('ERROR_CD','E014');

        l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

        fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
         END IF;

        IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(relcon_rec.interface_rel_con_id,'E014','IGS_AD_REL_CON_INT_ALL');
        END IF;

        UPDATE igs_ad_rel_con_int_all
        SET    status      = '3',
               ERROR_CODE  = 'E014'
        WHERE  interface_rel_con_id = relcon_rec.interface_rel_con_id;
      ELSE
        UPDATE igs_ad_rel_con_int_all
        SET    status      = '1',
               ERROR_CODE  = NULL,
           match_ind = '18'
        WHERE  interface_rel_con_id = relcon_rec.interface_rel_con_id;
      END IF;

      EXCEPTION
        WHEN OTHERS THEN

            IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

               IF (l_request_id IS NULL) THEN
                   l_request_id := fnd_global.conc_request_id;
               END IF;

               l_label := 'igs.plsql.igs_ad_imp_008.prc_rel_con_dtl.exception '||'E518';

               fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
               fnd_message.set_token('INTERFACE_ID',relcon_rec.interface_rel_con_id);
               fnd_message.set_token('ERROR_CD','E518');

               l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

               fnd_log.string_with_context( fnd_log.level_exception,
                                            l_label,
                                    l_debug_str, NULL,
                                NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
            END IF;

          IF l_enable_log = 'Y' THEN
             igs_ad_imp_001.logerrormessage(relcon_rec.interface_rel_con_id,'E518','IGS_AD_REL_CON_INT_ALL');
          END IF;

                UPDATE igs_ad_rel_con_int_all
                SET    status      = '3',
                       error_code  = 'E518'
                WHERE  interface_rel_con_id = relcon_rec.interface_rel_con_id;

      END;
    END IF;
    NULL;
  END IF;
  ELSE                  --       rel_cont_del_dup_rec_c%FOUND
    prc_rel_con(relcon_rec);
  END IF;               --       rel_cont_del_dup_rec_c%FOUND
  END IF;
  END LOOP ;
END prc_rel_con_dtl;

PROCEDURE crt_rel_acad_his (P_Interface_Relations_Id NUMBER,
                            P_Rel_Person_Id NUMBER,
                            p_source_type_id NUMBER) AS

l_prog_label  VARCHAR2(100);
l_label  VARCHAR2(100);
l_debug_str VARCHAR2(2000);
l_enable_log VARCHAR2(1);
l_request_id NUMBER;
l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

  --1.  Pick up all the records from the table IGS_AD_RELACAD_INT WHERE STATUS = '2' AND INTERFACE_RELATIONS_ID = P_INTERFACE_RELATIONS_ID
  CURSOR Relacad_Rec_C(cp_interface_relations_id NUMBER) IS
  SELECT *
  FROM   Igs_Ad_Relacad_Int_all
  WHERE  Status = '2'
  AND    Interface_Relations_Id = cP_Interface_Relations_Id;

  --     Check to see if an academic history record already exists for this person
  -- Duplicate check changed to ( person_id, institution_code , start_Date, end_date )  Import Process enahancements
  CURSOR Academic_His_C(P_Institution_Code Igs_Ad_Relacad_Int.Institution_Code%TYPE,
                        P_Start_Date Igs_Ad_Relacad_Int.Start_Date%TYPE,
            P_Rel_Person_ID NUMBER,
                        p_end_Date Igs_Ad_Relacad_Int.end_Date%TYPE
                        )        IS
  SELECT  *
    FROM   IGS_AD_ACAD_HISTORY_V a
  WHERE  a.institution_code  =  P_Institution_Code
  AND   ((TRUNC(a.Start_Date)  =  TRUNC(P_Start_Date)) OR (a.start_date IS NULL AND P_Start_Date IS NULL))
  AND   ((TRUNC(a.end_Date)  =  TRUNC(p_end_date)) OR (a.end_date IS NULL AND p_end_date IS NULL))
  AND    a.person_id  =  P_Rel_Person_ID;
--Cursor to select the records that are for first record updates.
CURSOR c_Academic_His_first(
                        cp_Interface_Relacad_Id  Igs_Ad_Relacad_Int_all.Interface_Relacad_Id%TYPE,
                        P_Institution_Code Igs_Ad_Relacad_Int.Institution_Code%TYPE,
                        P_Start_Date Igs_Ad_Relacad_Int.Start_Date%TYPE,
            P_Rel_Person_ID NUMBER,
                        p_end_Date Igs_Ad_Relacad_Int.end_Date%TYPE
                        )        IS

    SELECT  'X' a
     FROM Igs_Ad_Relacad_Int_all a
     WHERE   Interface_Relacad_Id = cp_Interface_Relacad_Id
     AND NVL(p_start_date,p_end_date) IS NOT NULL
     AND  EXISTS (SELECT 1 FROM hz_Education h1, hz_parties h2
                      WHERE  h1.party_id = P_Rel_Person_ID
                      AND h2.party_number = p_institution_code
                      AND h2.party_id = h1.school_party_id
                      AND h1.start_date_attended IS NULL
                      AND h1.last_date_attended IS NULL
                      )
     AND NOT EXISTS ( SELECT 1 FROM hz_Education h1, hz_parties h2
                    WHERE  h1.party_id = p_rel_person_id
                      AND h2.party_number = p_institution_code
                    AND h2.party_id = h1.school_party_id
                    AND NVL(h1.start_date_attended,
                         h1.last_date_attended) IS NOT NULL
                 );
l_Academic_His_first_Rec  c_Academic_His_first%ROWTYPE;

-- This cursor will be opened only if it is not exact match OR this record is not a candidate for first record udpate.
CURSOR c_Academic_His_partial(P_Institution_Code Igs_Ad_Relacad_Int.Institution_Code%TYPE,
                        P_Start_Date Igs_Ad_Relacad_Int.Start_Date%TYPE,
            P_Rel_Person_ID NUMBER,
                        p_end_Date Igs_Ad_Relacad_Int.end_Date%TYPE
                        )        IS

   SELECT 1  a
   FROM hz_Education h1, hz_parties h2
                    WHERE  h1.party_id = P_Rel_Person_ID
                      AND h2.party_number = p_institution_code
                    AND h2.party_id = h1.school_party_id
                    AND NVL(h1.start_date_attended,
                         h1.last_date_attended) IS NOT NULL;
  l_Academic_His_partial    c_Academic_His_partial%ROWTYPE;
 CURSOR c_dup_cur_first (Relacad_Rec  Relacad_Rec_C%ROWTYPE, P_Rel_Person_ID NUMBER ) IS
        SELECT  ah.rowid, ah.*
        FROM  igs_ad_acad_history_v ah
        WHERE person_id = P_Rel_Person_ID
        AND institution_code  = Relacad_Rec.institution_code
        AND creation_date = ( SELECT  min(creation_date) FROM igs_ad_acad_history_v
                                     WHERE person_id = P_Rel_Person_ID
                                     AND institution_code  = Relacad_Rec.institution_code);

  dup_cur_first_rec  c_dup_cur_first%ROWTYPE;



--  AND    current_inst     = P_current_inst;
-- current_inst is a check box hence should not be part of duplicate check
-- Person ID is added to check whether that person has academic history details.( 16-MAR-2002)

  l_Academic_His_Rec  Academic_His_C%ROWTYPE;

  l_row_id              IGS_AD_ACAD_HISTORY_V.ROW_ID%TYPE;--VARCHAR2(30);
  l_education_id       NUMBER;
  l_object_version_number  HZ_EDUCATION.OBJECT_VERSION_NUMBER%TYPE;
  l_return_status      IGS_AD_RELATIONS_INT.STATUS%TYPE;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_peron_interest_id  NUMBER;
  l_Status      IGS_AD_RELATIONS_INT.STATUS%TYPE;
  l_Error_Code  IGS_AD_RELATIONS_INT.Error_Code%TYPE;
  l_rule        igs_ad_source_cat.discrepancy_rule_cd%TYPE;
  l_check    VARCHAR2(30);
  l_count NUMBER;
  l_match_ind VARCHAR2(2);

  --Start of local procedure Validate_Acad_Hist
 PROCEDURE Validate_Acad_Hist( Relacad_Rec Relacad_Rec_C%ROWTYPE ,l_check OUT NOCOPY VARCHAR2 ) AS

 --  Validate the INSTITUTION_CD.
  CURSOR Institution_C(cp_Institution_Cd Igs_Ad_Relacad_Int.Institution_Code%TYPE,
                       cp_inst_status Igs_Or_Inst_Stat.S_Institution_Status%TYPE) IS
    SELECT 1
    FROM  igs_pe_hz_parties pzp, hz_parties hp, Igs_Or_Inst_Stat stat
    WHERE pzp.party_id = hp.party_id AND
    hp.party_number = cp_institution_cd AND
    pzp.OI_INSTITUTION_STATUS = stat.Institution_Status AND
    pzp.inst_org_ind = 'I' AND
    stat.S_Institution_Status = cp_inst_status;

  l_Institution_Rec Institution_C%ROWTYPE;

  --  Validate the DEGREE_CODE
  CURSOR c_degree_code  (p_degree hz_education.degree_received%TYPE) IS
    SELECT    dg.degree_cd
    FROM       igs_ps_degrees dg,
               igs_ps_type_all ps
    WHERE   dg.degree_cd = p_degree
    AND dg.closed_ind  ='N'
    AND dg.program_type = ps.course_type;

  l_Course_Rec  c_degree_code%ROWTYPE;


  CURSOR birth_date_cur(cp_person_id hz_parties.party_id%TYPE)
  IS
  SELECT birth_date
  FROM igs_pe_person_base_v
  WHERE person_id = cp_person_id;


  l_Status             IGS_AD_RELATIONS_INT.STATUS%TYPE;
  l_Error_Code         IGS_AD_RELATIONS_INT.Error_Code%TYPE;
  birth_date_rec       birth_date_cur%ROWTYPE;

  BEGIN

    l_Error_Code := 'E008';
    l_status := '3';

    --For UK Degree Earned and Degree Attempted should be null
    IF NVL(FND_PROFILE.VALUE('OSS_COUNTRY_CODE'),'*') = 'GB'
       AND (Relacad_Rec.degree_attempted IS NOT NULL
       OR Relacad_Rec.degree_earned IS NOT NULL
       OR Relacad_Rec.program_code IS NOT NULL) THEN

      IF l_enable_log = 'Y' THEN
         igs_ad_imp_001.logerrormessage(relacad_rec.interface_relacad_id,'E396','IGS_AD_RELACAD_INT_ALL');
      END IF;

      UPDATE Igs_Ad_Relacad_Int_all
      SET    Error_Code = 'E396',
             Status     = l_Status
      WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
      l_check := 'TRUE';
      RETURN;

    END IF;

--  Validate the INSTITUTION_CD.
    OPEN Institution_C(Relacad_Rec.Institution_Code,'ACTIVE');
    FETCH Institution_C INTO l_Institution_Rec;
    IF (Institution_C%NOTFOUND) THEN

      IF l_enable_log = 'Y' THEN
         igs_ad_imp_001.logerrormessage(relacad_rec.interface_relacad_id,'E401','IGS_AD_RELACAD_INT_ALL');
      END IF;

      UPDATE Igs_Ad_Relacad_Int_all
      SET    Error_Code = 'E401',
             Status     = l_Status
      WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
      CLOSE Institution_C;
      l_check := 'TRUE';
      RETURN;
    END IF;
    CLOSE Institution_C;

    --  Validate the DEGREE_ATTEMPTED
   IF (Relacad_Rec.degree_attempted IS NOT NULL) THEN
    OPEN c_degree_code(Relacad_Rec.degree_attempted);
    FETCH c_degree_code INTO l_Course_Rec;
    IF (c_degree_code%NOTFOUND) THEN

      IF l_enable_log = 'Y' THEN
         igs_ad_imp_001.logerrormessage(relacad_rec.interface_relacad_id,'E402','IGS_AD_RELACAD_INT_ALL');
      END IF;

      UPDATE Igs_Ad_Relacad_Int_all
      SET    Error_Code = 'E402',
             Status     = l_Status
      WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
      CLOSE c_degree_code;
      l_check := 'TRUE';
      RETURN;
    END IF;
    CLOSE c_degree_code;
   END IF;

    --  Validate the DEGREE_EARNED

   IF (Relacad_Rec.degree_earned IS NOT NULL) THEN
    OPEN c_degree_code(Relacad_Rec.degree_earned);
    FETCH c_degree_code INTO l_Course_Rec;
    IF (c_degree_code%NOTFOUND) THEN

      IF l_enable_log = 'Y' THEN
         igs_ad_imp_001.logerrormessage(relacad_rec.interface_relacad_id,'E403','IGS_AD_RELACAD_INT_ALL');
      END IF;

      UPDATE Igs_Ad_Relacad_Int_all
      SET    Error_Code = 'E403',
             Status     = l_Status
      WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
      CLOSE c_degree_code;
      l_check := 'TRUE';
      RETURN;
    END IF;
    CLOSE c_degree_code;
   END IF;


   IF RELACAD_REC.CURRENT_INST NOT IN('Y','N') THEN

      IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(relacad_rec.interface_relacad_id,'E453','IGS_AD_RELACAD_INT_ALL');
      END IF;

      UPDATE Igs_Ad_Relacad_Int_all
      SET    Error_Code = 'E453',
             Status     = l_Status
      WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
      l_check := 'TRUE';
      RETURN;
   END IF;

    -- IF RELACAD_REC.CURRENT_INST = 'Y' THEN THE END DATE MUST BE NULL.
    IF RELACAD_REC.CURRENT_INST = 'Y' AND RELACAD_REC.END_DATE IS NOT NULL THEN

      IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(relacad_rec.interface_relacad_id,'E448','IGS_AD_RELACAD_INT_ALL');
      END IF;


      UPDATE Igs_Ad_Relacad_Int_all
      SET    Error_Code = 'E448',
             Status     = l_Status
      WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
      l_check := 'TRUE';
      RETURN;
    END IF;

    --6. START_DATE
    IF  RELACAD_REC.START_DATE IS NOT NULL THEN
      IF  NOT RELACAD_REC.START_DATE < SYSDATE THEN
         UPDATE Igs_Ad_Relacad_Int_all
         SET    Error_Code = 'E405',
                Status     = l_Status
         WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
      l_check := 'TRUE';
      RETURN;
      END IF;
    END IF;

    --7. END_DATE
    IF RELACAD_REC.END_DATE  IS NOT NULL
                   AND RELACAD_REC.START_DATE IS NOT NULL THEN
      IF  NOT RELACAD_REC.END_DATE >= RELACAD_REC.START_DATE THEN
         UPDATE Igs_Ad_Relacad_Int_all
         SET    Error_Code = 'E406',
                Status     = l_Status
         WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
      l_check := 'TRUE';
      RETURN;
      END IF;
    ELSIF RELACAD_REC.END_DATE  IS NOT NULL
                   AND RELACAD_REC.START_DATE IS NULL THEN
         UPDATE Igs_Ad_Relacad_Int_all
         SET    Error_Code = 'E407',
                Status     = l_Status
         WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
        l_check := 'TRUE';
      RETURN;

    END IF;

    --8. PLANNED_COMPLETION_DATE
    IF RELACAD_REC.PLAN_COMPLETION_DATE  IS NOT NULL AND RELACAD_REC.START_DATE IS NOT NULL THEN
      IF  NOT RELACAD_REC.PLAN_COMPLETION_DATE >= RELACAD_REC.START_DATE THEN
         UPDATE Igs_Ad_Relacad_Int_all
         SET    Error_Code = 'E408',
                Status     = l_Status
         WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
        l_check := 'TRUE';
      RETURN;

      END IF;
    END IF;

    OPEN birth_date_cur(p_rel_person_id);
    FETCH birth_date_cur INTO birth_date_rec;
    CLOSE birth_date_cur;

    IF birth_date_rec.birth_date IS NOT NULL AND relacad_rec.start_date IS NOT NULL THEN
       IF relacad_rec.start_date < birth_date_rec.birth_date THEN
         UPDATE Igs_Ad_Relacad_Int_all
         SET    Error_Code = 'E222',
                Status     = l_Status
         WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
         l_check := 'TRUE';
         RETURN;
       END IF;
    END IF;

    l_check := 'FALSE';

END Validate_Acad_Hist;

  -- END of Local Procedure Validate_Acad_Hist

BEGIN
    l_check := 'FALSE';
    l_Status := '3';
    l_Error_Code := 'E008';
    l_prog_label := 'igs.plsql.igs_ad_imp_008.crt_rel_acad_his';
    l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_acad_his.';
    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

       IF (l_request_id IS NULL) THEN
       l_request_id := fnd_global.conc_request_id;
       END IF;

       l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_acad_his.begin';
       l_debug_str :=  'Igs_Ad_Imp_008.crt_rel_acad_his';

       fnd_log.string_with_context( fnd_log.level_procedure,
                    l_label,
                    l_debug_str, NULL,
                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

  l_rule := Igs_Ad_Imp_001.Find_Source_Cat_Rule(p_source_type_id,'RELATIONS_ACAD_HISTORY');

  --1 If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE Igs_Ad_Relacad_Int_all
    SET status = '3',
        ERROR_CODE = 'E695'  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND status = '2'
      AND Interface_Relations_Id = P_Interface_Relations_Id;
  END IF;

  --2 If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE Igs_Ad_Relacad_Int_all mi
    SET status = '1',
        match_ind = '19'
    WHERE mi.Interface_Relations_Id = P_Interface_Relations_Id
      AND mi.status = '2'
      AND EXISTS ( SELECT 1
                   FROM   Igs_Ad_Acad_History_V pe
           WHERE  pe.Institution_Code = mi.institution_code
            AND   ((TRUNC(pe.Start_Date)  =  TRUNC(mi.Start_Date)) OR (pe.start_date IS NULL AND mi.Start_date IS NULL))
                        AND   ((TRUNC(pe.end_Date)  =  TRUNC(mi.end_date)) OR (pe.end_date IS NULL AND mi.end_date IS NULL))
            AND    pe.person_id        =  P_Rel_Person_ID);
  END IF;

  --3 If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE Igs_Ad_Relacad_Int_all
    SET status = '1'
    WHERE Interface_Relations_Id = P_Interface_Relations_Id
      AND match_ind IN ('18','19','22','23')
      AND status = '2';
  END IF;

  --4 If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE Igs_Ad_Relacad_Int_all
    SET status = '3',
        ERROR_CODE = 'E695'
    WHERE Interface_Relations_Id = P_Interface_Relations_Id
      AND status = '2'
      AND (match_ind IS NOT NULL AND match_ind NOT IN ('21','25'));
  END IF;

  --5 If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE Igs_Ad_Relacad_Int_all mi
    SET status = '1',
        match_ind = '23'
    WHERE mi.Interface_Relations_Id = P_Interface_Relations_Id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS ( SELECT '1'
                   FROM Igs_Ad_Acad_History_V pe
           WHERE  pe.person_id        = P_Rel_Person_ID
              AND    UPPER(pe.current_inst) = UPPER(mi.current_inst)
              AND    ( (TRUNC(pe.Start_Date)  =  TRUNC(mi.Start_Date)) OR (pe.start_date IS NULL AND mi.Start_date is null) )
              AND    ( (UPPER(pe.program_code) = UPPER(mi.program_code)) OR (pe.program_code IS NULL AND mi.program_code is null) )
              AND    ( (UPPER(pe.degree_attempted) = UPPER(mi.degree_attempted)) or (pe.degree_attempted is null and mi.degree_attempted is null) )
              AND    ( (UPPER(pe.degree_earned) = UPPER(mi.degree_earned)) OR (pe.degree_earned is null and mi.degree_earned is null) )
              AND    ( (UPPER(pe.comments) = UPPER(mi.comments)) or (pe.comments is null and mi.comments is null) )
              AND    ( (TRUNC(pe.planned_completion_date) = TRUNC(mi.plan_completion_date)) or (pe.planned_completion_date is null and mi.plan_completion_date is null) )
              AND    UPPER(pe.Institution_Code) = UPPER(mi.Institution_Code)
             );
  END IF;

  --6 If rule is R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE Igs_Ad_Relacad_Int_all mi
    SET status = '3',
        match_ind = '20'
    WHERE mi.Interface_Relations_Id = P_Interface_Relations_Id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS ( SELECT 1
                   FROM   Igs_Ad_Acad_History_V pe
           WHERE  pe.Institution_Code = mi.institution_code
            AND   ((TRUNC(pe.Start_Date)  =  TRUNC(mi.Start_Date)) OR (pe.start_date IS NULL AND mi.Start_date IS NULL))
                        AND   ((TRUNC(pe.end_Date)  =  TRUNC(mi.end_date)) OR (pe.end_date IS NULL AND mi.end_date IS NULL))
            AND    pe.person_id        =  P_Rel_Person_ID);
  END IF;

  --1.  Pick up all the records from the table IGS_AD_RELACAD_INT
  FOR Relacad_Rec IN Relacad_Rec_C(P_Interface_Relations_Id) LOOP
    Relacad_Rec.CURRENT_INST := UPPER(Relacad_Rec.CURRENT_INST);
    Relacad_Rec.start_date := TRUNC(Relacad_Rec.start_date);
    l_check:= 'FALSE';
    Validate_Acad_Hist( Relacad_Rec ,l_check );

    IF l_check <> 'TRUE' THEN
    --7.     Check to see if an academic history record already exists for this person
    OPEN Academic_His_C(RELACAD_REC.INSTITUTION_CODE,RELACAD_REC.START_DATE,p_rel_person_id,RELACAD_REC.END_DATE);
    FETCH Academic_His_C  INTO  l_Academic_His_Rec;

     --8.    IF the academic history details  already exist for this person THEN
    IF Academic_His_C%FOUND THEN
      IF l_rule = 'I' THEN
        BEGIN
       -- Call IGS_AD_HZ_ACAD_HISTORY.UPDATE_ROW to update the  row in the extension table.
          l_education_id := l_Academic_His_Rec.Education_ID;
          l_row_id := l_Academic_His_Rec.row_id;

  Igs_Ad_Acad_History_Pkg.update_row(
              x_rowid                             => l_row_id,
              x_recalc_total_cp_earned            => l_Academic_His_Rec.recalc_total_cp_earned,
              x_recalc_total_cp_attempted         => l_Academic_His_Rec.recalc_total_cp_attempted,
              x_recalc_total_unit_gp              => l_Academic_His_Rec.recalc_total_unit_gp,
              x_recalc_tot_gpa_units_attemp       => l_Academic_His_Rec.recalc_total_gpa_units_attemp,
              x_recalc_inst_gpa                   => l_Academic_His_Rec.recalc_inst_gpa,
              x_recalc_grading_scale_id           => l_Academic_His_Rec.recalc_grading_scale_id,
              x_selfrep_total_cp_attempted        => l_Academic_His_Rec.selfrep_total_cp_attempted,
              x_selfrep_total_cp_earned           => l_Academic_His_Rec.selfrep_total_cp_earned,
              x_selfrep_total_unit_gp             => l_Academic_His_Rec.selfrep_total_unit_gp,
              x_selfrep_tot_gpa_uts_attemp        => l_Academic_His_Rec.selfrep_total_gpa_units_attemp,
              x_selfrep_inst_gpa                  => l_Academic_His_Rec.selfrep_inst_gpa,
              x_selfrep_grading_scale_id          => l_Academic_His_Rec.selfrep_grading_scale_id,
              x_selfrep_weighted_gpa              => l_Academic_His_Rec.selfrep_weighted_gpa,
              x_selfrep_rank_in_class             => l_Academic_His_Rec.selfrep_rank_in_class,
              x_selfrep_weighed_rank              => l_Academic_His_Rec.selfrep_weighed_rank,
              x_selfrep_class_size                => l_Academic_His_Rec.selfrep_class_size,    --   x_hz_acad_hist_id                   => l_Academic_His_Rec.hz_acad_hist_id,
              x_attribute_category                => l_Academic_His_Rec.attribute_category,
              x_attribute1                        => l_Academic_His_Rec.attribute1,
              x_attribute2                        => l_Academic_His_Rec.attribute2,
              x_attribute3                        => l_Academic_His_Rec.attribute3,
              x_attribute4                        => l_Academic_His_Rec.attribute4,
              x_attribute5                        => l_Academic_His_Rec.attribute5,
              x_attribute6                        => l_Academic_His_Rec.attribute6,
              x_attribute7                        => l_Academic_His_Rec.attribute7,
              x_attribute8                        => l_Academic_His_Rec.attribute8,
              x_attribute9                        => l_Academic_His_Rec.attribute9,
              x_attribute10                       => l_Academic_His_Rec.attribute10,
              x_attribute11                       => l_Academic_His_Rec.attribute11,
              x_attribute12                       => l_Academic_His_Rec.attribute12,
              x_attribute13                       => l_Academic_His_Rec.attribute13,
              x_attribute14                       => l_Academic_His_Rec.attribute14,
              x_attribute15                       => l_Academic_His_Rec.attribute15,
              x_attribute16                       => l_Academic_His_Rec.attribute16,
              x_attribute17                       => l_Academic_His_Rec.attribute17,
              x_attribute18                       => l_Academic_His_Rec.attribute18,
              x_attribute19                       => l_Academic_His_Rec.attribute19,
              x_attribute20                       => l_Academic_His_Rec.attribute20,
              x_type_of_school                    => l_Academic_His_Rec.type_of_school,
              x_institution_code                  => NVL(Relacad_Rec.institution_code,l_Academic_His_Rec.institution_code),
              x_education_id                      => l_education_id,
              x_person_id                         => l_Academic_His_Rec.person_id,
              x_current_inst                      => NVL(Relacad_Rec.current_inst,l_Academic_His_Rec.current_inst),
              x_degree_attempted            => NVL(Relacad_Rec.degree_attempted,l_Academic_His_Rec.degree_attempted),
              x_program_code                      => NVL(Relacad_Rec.program_code,l_Academic_His_Rec.program_code ),
              x_degree_earned               => NVL(Relacad_Rec.degree_earned,l_Academic_His_Rec.degree_earned),
              x_comments                          => NVL(Relacad_Rec.comments,l_Academic_His_Rec.comments),
              x_start_date                        => NVL(Relacad_Rec.start_date,TRUNC(l_Academic_His_Rec.start_date)),
              x_end_date                          => NVL(Relacad_Rec.end_date,TRUNC(l_Academic_His_Rec.end_date)),
              x_planned_completion_date           => NVL(Relacad_Rec.plan_completion_date,TRUNC(l_Academic_His_Rec.planned_completion_date)),
              x_transcript_required               => l_Academic_His_Rec.transcript_required,
              x_object_version_number             => l_Academic_His_Rec.object_version_number,
              x_msg_data			  => l_msg_data,
              x_return_status                     => l_return_status,
              x_mode                              => 'R'
            );

      IF (l_return_status = 'E' OR l_return_status = 'U')  THEN

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_acad_his.exception '||'E014';

          l_debug_str :=  'Rule - Import, IGS_AD_IMP_008.crt_rel_acad_his Update Row failed'
                || 'Interface Relacad Id : '
                || (relacad_rec.interface_relacad_id)
                || 'Status : 3' || 'ErrorCode : E014 HzMesg: '||l_msg_data||' SQLERRM:' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

      IF l_enable_log = 'Y' THEN
             igs_ad_imp_001.logerrormessage(relacad_rec.interface_relacad_id,'E014','IGS_AD_RELACAD_INT_ALL');
      END IF;

                  UPDATE Igs_Ad_Relacad_Int_all
                  SET    Error_Code = 'E014',
                  Status     = '3'
                  WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
      ELSE
                 UPDATE Igs_Ad_Relacad_Int_all
                 SET    Error_Code = NULL,
                 Status     = '1', Match_Ind = '18'
                WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
      END IF;
       END;

      ELSIF l_rule = 'R' THEN
        IF Relacad_Rec.match_ind = '21' THEN
        BEGIN
                  -- Call IGS_AD_HZ_ACAD_HISTORY.UPDATE_ROW to update the  row in the extension table.
                  --Standard start of API savepoint
                  l_education_id := l_Academic_His_Rec.Education_ID;
                  l_row_id := l_Academic_His_Rec.row_id;

                  Igs_Ad_Acad_History_Pkg.update_row(
                     x_rowid                             => l_row_id,
                         x_recalc_total_cp_earned            => l_Academic_His_Rec.recalc_total_cp_earned,
                         x_recalc_total_cp_attempted         => l_Academic_His_Rec.recalc_total_cp_attempted,
                         x_recalc_total_unit_gp              => l_Academic_His_Rec.recalc_total_unit_gp,
                         x_recalc_tot_gpa_units_attemp     => l_Academic_His_Rec.recalc_total_gpa_units_attemp,
                         x_recalc_inst_gpa                   => l_Academic_His_Rec.recalc_inst_gpa,
                         x_recalc_grading_scale_id           => l_Academic_His_Rec.recalc_grading_scale_id,
                         x_selfrep_total_cp_attempted        => l_Academic_His_Rec.selfrep_total_cp_attempted,
                         x_selfrep_total_cp_earned           => l_Academic_His_Rec.selfrep_total_cp_earned,
                         x_selfrep_total_unit_gp             => l_Academic_His_Rec.selfrep_total_unit_gp,
                         x_selfrep_tot_gpa_uts_attemp        => l_Academic_His_Rec.selfrep_total_gpa_units_attemp,
                         x_selfrep_inst_gpa                  => l_Academic_His_Rec.selfrep_inst_gpa,
                         x_selfrep_grading_scale_id          => l_Academic_His_Rec.selfrep_grading_scale_id,
                         x_selfrep_weighted_gpa              => l_Academic_His_Rec.selfrep_weighted_gpa,
                         x_selfrep_rank_in_class             => l_Academic_His_Rec.selfrep_rank_in_class,
                         x_selfrep_weighed_rank              => l_Academic_His_Rec.selfrep_weighed_rank,
                         x_selfrep_class_size                => l_Academic_His_Rec.selfrep_class_size,    --   x_hz_acad_hist_id                   => l_Academic_His_Rec.hz_acad_hist_id,
                         x_attribute_category                => l_Academic_His_Rec.attribute_category,
                         x_attribute1                        => l_Academic_His_Rec.attribute1,
                         x_attribute2                        => l_Academic_His_Rec.attribute2,
                         x_attribute3                        => l_Academic_His_Rec.attribute3,
                         x_attribute4                        => l_Academic_His_Rec.attribute4,
                         x_attribute5                        => l_Academic_His_Rec.attribute5,
                         x_attribute6                        => l_Academic_His_Rec.attribute6,
                         x_attribute7                        => l_Academic_His_Rec.attribute7,
                         x_attribute8                        => l_Academic_His_Rec.attribute8,
                         x_attribute9                        => l_Academic_His_Rec.attribute9,
                         x_attribute10                       => l_Academic_His_Rec.attribute10,
                         x_attribute11                       => l_Academic_His_Rec.attribute11,
                         x_attribute12                       => l_Academic_His_Rec.attribute12,
                         x_attribute13                       => l_Academic_His_Rec.attribute13,
                         x_attribute14                       => l_Academic_His_Rec.attribute14,
                         x_attribute15                       => l_Academic_His_Rec.attribute15,
                         x_attribute16                       => l_Academic_His_Rec.attribute16,
                         x_attribute17                       => l_Academic_His_Rec.attribute17,
                         x_attribute18                       => l_Academic_His_Rec.attribute18,
                         x_attribute19                       => l_Academic_His_Rec.attribute19,
                         x_attribute20                       => l_Academic_His_Rec.attribute20,
                         x_type_of_school                    => l_Academic_His_Rec.type_of_school,
                         x_institution_code           => NVL(Relacad_Rec.institution_code,l_Academic_His_Rec.institution_code),
                         x_education_id                      => l_education_id,
                         x_person_id                         => l_Academic_His_Rec.person_id,
                         x_current_inst                      => NVL(Relacad_Rec.current_inst,l_Academic_His_Rec.current_inst),
                         x_degree_attempted            => NVL(Relacad_Rec.degree_attempted,l_Academic_His_Rec.degree_attempted),
                         x_program_code                      => NVL(Relacad_Rec.program_code,l_Academic_His_Rec.program_code ),
                         x_degree_earned        => NVL(Relacad_Rec.degree_earned,l_Academic_His_Rec.degree_earned),
                         x_comments                          => NVL(Relacad_Rec.comments,l_Academic_His_Rec.comments),
                         x_start_date                        => NVL(Relacad_Rec.start_date,TRUNC(l_Academic_His_Rec.start_date)),
                         x_end_date                          => NVL(Relacad_Rec.end_date,TRUNC(l_Academic_His_Rec.end_date)),
                         x_planned_completion_date           => NVL(Relacad_Rec.plan_completion_date,TRUNC(l_Academic_His_Rec.planned_completion_date)),
                         x_transcript_required               => l_Academic_His_Rec.transcript_required,
                         x_object_version_number    => l_Academic_His_Rec.object_version_number,
                         x_msg_data           => l_msg_data,
                         x_return_status                  => l_return_status,
                         x_mode                              => 'R'
                         );

                       IF (l_return_status = 'E' OR l_return_status = 'U')  THEN

              IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                IF (l_request_id IS NULL) THEN
                  l_request_id := fnd_global.conc_request_id;
                END IF;

                l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_acad_his.exception1 '||'E014';

                  l_debug_str :=  'Rule - Import, IGS_AD_IMP_008.crt_rel_acad_his Update Row failed'
                || 'Interface Relacad Id : '
                || (relacad_rec.interface_relacad_id)
                || 'Status : 3' || 'ErrorCode : E014 HzMesg: '||l_msg_data||' SQLERRM:' ||  SQLERRM;

                fnd_log.string_with_context( fnd_log.level_exception,
                              l_label,
                              l_debug_str, NULL,
                              NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
              END IF;

                         IF l_enable_log = 'Y' THEN
                            igs_ad_imp_001.logerrormessage(relacad_rec.interface_relacad_id,'E014','IGS_AD_RELACAD_INT_ALL');
                         END IF;

                          UPDATE Igs_Ad_Relacad_Int_all
                          SET    Error_Code = 'E014',
                          Status     = '3'
                          WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
                    ELSE
                          UPDATE Igs_Ad_Relacad_Int_all
                          SET    Error_Code = NULL,
                          Status     = '1',
              match_ind  = '18'
                          WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
                    END IF;
          END;
        END IF;

      END IF;
    ELSE
      l_Academic_His_first_Rec.a := NULL;
       OPEN c_Academic_His_first(RELACAD_REC.Interface_Relacad_Id, RELACAD_REC.INSTITUTION_CODE,RELACAD_REC.START_DATE,p_rel_person_id,RELACAD_REC.END_DATE);
       FETCH c_Academic_His_first  INTO  l_Academic_His_first_Rec;
       CLOSE c_Academic_His_first;
      IF  l_Academic_His_first_Rec.a  IS NOT NULL THEN
        OPEN c_dup_cur_first(RELACAD_REC, p_rel_person_id);
        FETCH c_dup_cur_first INTO dup_cur_first_rec;
        CLOSE c_dup_cur_first ;
          --Update the first record. (Import Process Enhancements)
          BEGIN
                  -- Call IGS_AD_HZ_ACAD_HISTORY.UPDATE_ROW to update the  row in the extension table.
                  --Standard start of API savepoint
                  l_education_id := dup_cur_first_rec.Education_ID;
                  l_row_id := dup_cur_first_rec.row_id;

                  Igs_Ad_Acad_History_Pkg.update_row(
                     x_rowid                             => l_row_id,
                         x_recalc_total_cp_earned            => dup_cur_first_rec.recalc_total_cp_earned,
                         x_recalc_total_cp_attempted         => dup_cur_first_rec.recalc_total_cp_attempted,
                         x_recalc_total_unit_gp              => dup_cur_first_rec.recalc_total_unit_gp,
                         x_recalc_tot_gpa_units_attemp     => dup_cur_first_rec.recalc_total_gpa_units_attemp,
                         x_recalc_inst_gpa                   => dup_cur_first_rec.recalc_inst_gpa,
                         x_recalc_grading_scale_id           => dup_cur_first_rec.recalc_grading_scale_id,
                         x_selfrep_total_cp_attempted        => dup_cur_first_rec.selfrep_total_cp_attempted,
                         x_selfrep_total_cp_earned           => dup_cur_first_rec.selfrep_total_cp_earned,
                         x_selfrep_total_unit_gp             => dup_cur_first_rec.selfrep_total_unit_gp,
                         x_selfrep_tot_gpa_uts_attemp        => dup_cur_first_rec.selfrep_total_gpa_units_attemp,
                         x_selfrep_inst_gpa                  => dup_cur_first_rec.selfrep_inst_gpa,
                         x_selfrep_grading_scale_id          => dup_cur_first_rec.selfrep_grading_scale_id,
                         x_selfrep_weighted_gpa              => dup_cur_first_rec.selfrep_weighted_gpa,
                         x_selfrep_rank_in_class             => dup_cur_first_rec.selfrep_rank_in_class,
                         x_selfrep_weighed_rank              => dup_cur_first_rec.selfrep_weighed_rank,
                         x_selfrep_class_size                => dup_cur_first_rec.selfrep_class_size,    --   x_hz_acad_hist_id                   => l_Academic_His_Rec.hz_acad_hist_id,
                         x_attribute_category                => dup_cur_first_rec.attribute_category,
                         x_attribute1                        => dup_cur_first_rec.attribute1,
                         x_attribute2                        => dup_cur_first_rec.attribute2,
                         x_attribute3                        => dup_cur_first_rec.attribute3,
                         x_attribute4                        => dup_cur_first_rec.attribute4,
                         x_attribute5                        => dup_cur_first_rec.attribute5,
                         x_attribute6                        => dup_cur_first_rec.attribute6,
                         x_attribute7                        => dup_cur_first_rec.attribute7,
                         x_attribute8                        => dup_cur_first_rec.attribute8,
                         x_attribute9                        => dup_cur_first_rec.attribute9,
                         x_attribute10                       => dup_cur_first_rec.attribute10,
                         x_attribute11                       => dup_cur_first_rec.attribute11,
                         x_attribute12                       => dup_cur_first_rec.attribute12,
                         x_attribute13                       => dup_cur_first_rec.attribute13,
                         x_attribute14                       => dup_cur_first_rec.attribute14,
                         x_attribute15                       => dup_cur_first_rec.attribute15,
                         x_attribute16                       => dup_cur_first_rec.attribute16,
                         x_attribute17                       => dup_cur_first_rec.attribute17,
                         x_attribute18                       => dup_cur_first_rec.attribute18,
                         x_attribute19                       => dup_cur_first_rec.attribute19,
                         x_attribute20                       => dup_cur_first_rec.attribute20,
                         x_type_of_school                    => dup_cur_first_rec.type_of_school,
                         x_institution_code           => NVL(Relacad_Rec.institution_code,dup_cur_first_rec.institution_code),
                         x_education_id                      => l_education_id,
                         x_person_id                         => dup_cur_first_rec.person_id,
                         x_current_inst                      => NVL(Relacad_Rec.current_inst,dup_cur_first_rec.current_inst),
                         x_degree_attempted            => NVL(Relacad_Rec.degree_attempted,dup_cur_first_rec.degree_attempted),
                         x_program_code                      => NVL(Relacad_Rec.program_code,dup_cur_first_rec.program_code ),
                         x_degree_earned        => NVL(Relacad_Rec.degree_earned,dup_cur_first_rec.degree_earned),
                         x_comments                          => NVL(Relacad_Rec.comments,dup_cur_first_rec.comments),
                         x_start_date                        => NVL(Relacad_Rec.start_date,TRUNC(dup_cur_first_rec.start_date)),
                         x_end_date                          => NVL(Relacad_Rec.end_date,TRUNC(dup_cur_first_rec.end_date)),
                         x_planned_completion_date           => NVL(Relacad_Rec.plan_completion_date,TRUNC(dup_cur_first_rec.planned_completion_date)),
                         x_transcript_required               => dup_cur_first_rec.transcript_required,
                         x_object_version_number    => dup_cur_first_rec.object_version_number,
                         x_msg_data           => l_msg_data,
                         x_return_status                  => l_return_status,
                         x_mode                              => 'R'
                         );

                       IF (l_return_status = 'E' OR l_return_status = 'U')  THEN

              IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                IF (l_request_id IS NULL) THEN
                  l_request_id := fnd_global.conc_request_id;
                END IF;

                l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_acad_his.exception1 '||'E014';

                  l_debug_str :=  'Rule - Import, IGS_AD_IMP_008.crt_rel_acad_his Update Row failed'
                || 'Interface Relacad Id : '
                || (relacad_rec.interface_relacad_id)
                || 'Status : 3' || 'ErrorCode : E014 HzMesg: '||l_msg_data||' SQLERRM:' ||  SQLERRM;

                fnd_log.string_with_context( fnd_log.level_exception,
                              l_label,
                              l_debug_str, NULL,
                              NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
              END IF;

                         IF l_enable_log = 'Y' THEN
                            igs_ad_imp_001.logerrormessage(relacad_rec.interface_relacad_id,'E014','IGS_AD_RELACAD_INT_ALL');
                         END IF;

                          UPDATE Igs_Ad_Relacad_Int_all
                          SET    Error_Code = 'E014',
                          Status     = '3'
                          WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
                    ELSE
                          UPDATE Igs_Ad_Relacad_Int_all
                          SET    Error_Code = NULL,
                          Status     = '1',
              match_ind  = '18'
                          WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
                    END IF;
          END;
      ELSE
      l_Academic_His_partial.a := NULL;
       OPEN c_Academic_His_partial(RELACAD_REC.INSTITUTION_CODE,RELACAD_REC.START_DATE,p_rel_person_id,RELACAD_REC.END_DATE);
       FETCH c_Academic_His_partial  INTO  l_Academic_His_partial;
       CLOSE c_Academic_His_partial;
         IF l_Academic_His_partial.a IS  NOT NULL  THEN --PARTIAL
             SELECT COUNT(*)  INTO l_count
             FROM  IGS_AD_ACAD_HISTORY_V acad
             WHERE acad.person_id =  p_rel_person_id
             AND acad.institution_code = RELACAD_REC.INSTITUTION_CODE;
             IF l_count >1 THEN
                          UPDATE Igs_Ad_Relacad_Int_all
                          SET    Status     = '3', match_ind = '14'
                          WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
             ELSE
                          UPDATE Igs_Ad_Relacad_Int_all
                          SET    Status     = '3', match_ind = '13'
                          WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
             END IF;

         ELSE
            l_row_id := Null;
            Igs_Ad_Acad_History_Pkg.INSERT_ROW (
                       x_rowid                           => l_row_id,
                       x_education_id                    => l_education_id,
                       x_person_id                       => p_rel_person_id,
                       x_current_inst                    => relacad_rec.current_inst,
                       x_degree_attempted          => relacad_rec.degree_attempted,
                       x_program_code                    => relacad_rec.program_code,
                       x_degree_earned           => relacad_rec.degree_earned,
                       x_comments                        => relacad_rec.comments,
                       x_start_date                      => relacad_rec.start_date,
                       x_end_date                        => relacad_rec.end_date,
                       x_planned_completion_date         => relacad_rec.plan_completion_date,
                       x_recalc_total_cp_attempted       => NULL,
                       x_recalc_total_cp_earned          => NULL,
                       x_recalc_total_unit_gp            => NULL,
                       x_recalc_tot_gpa_units_attemp     => NULL,
                       x_recalc_inst_gpa                 => NULL,
                       x_recalc_grading_scale_id         => NULL,
                       x_selfrep_total_cp_attempted      => NULL,
                       x_selfrep_total_cp_earned         => NULL,
                       x_selfrep_total_unit_gp           => NULL,
                       X_selfrep_tot_gpa_uts_attemp      => NULL,
                       x_selfrep_inst_gpa                => NULL,
                       x_selfrep_grading_scale_id        => NULL,
                       x_selfrep_weighted_gpa            => NULL,
                       x_selfrep_rank_in_class           => NULL,
                       x_selfrep_weighed_rank            => NULL,
                       x_type_of_school                  => NULL,
                       x_institution_code              => relacad_rec.institution_code,
                       x_attribute_category              => NULL,
                       x_attribute1                      => NULL,
                       x_attribute2                      => NULL,
                       x_attribute3                      => NULL,
                       x_attribute4                      => NULL,
                       x_attribute5                      => NULL,
                       x_attribute6                      => NULL,
                       x_attribute7                      => NULL,
                       x_attribute8                      => NULL,
                       x_attribute9                      => NULL,
                       x_attribute10                     => NULL,
                       x_attribute11                     => NULL,
                       x_attribute12                     => NULL,
                       x_attribute13                     => NULL,
                       x_attribute14                     => NULL,
                       x_attribute15                     => NULL,
                       x_attribute16                     => NULL,
                       x_attribute17                     => NULL,
                       x_attribute18                     => NULL,
                       x_attribute19                     => NULL,
                       x_attribute20                     => NULL,
                       x_selfrep_class_size              => NULL,
                       x_transcript_required             => NULL,
                       x_object_version_number		 =>  l_object_version_number,
                       x_msg_data			 => l_msg_data,
                       x_return_status			 => l_return_status,
                       x_mode                            => 'R'
                     ) ;


        --ssomani added this check feb 26, 2001
            IF (l_return_status = 'E' OR l_return_status = 'U')  THEN

                  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                    IF (l_request_id IS NULL) THEN
                      l_request_id := fnd_global.conc_request_id;
                    END IF;

                    l_label := 'igs.plsql.igs_ad_imp_008.crt_rel_acad_his.exception '||'E322';

                      l_debug_str :=  'Rule - Import, IGS_AD_IMP_008.crt_rel_acad_his Insert Row failed'
                        || 'Interface Relacad Id : '
                        || (relacad_rec.interface_relacad_id)
                        || 'Status : 3' || 'ErrorCode : E322 HzMesg: '||l_msg_data||' SQLERRM:' ||  SQLERRM;

                    fnd_log.string_with_context( fnd_log.level_exception,
                                                  l_label,
                                                  l_debug_str, NULL,
                                                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                  END IF;

                  IF l_enable_log = 'Y' THEN
                     igs_ad_imp_001.logerrormessage(relacad_rec.interface_relacad_id,'E322','IGS_AD_RELACAD_INT_ALL');
              END IF;

                  UPDATE Igs_Ad_Relacad_Int_all
                  SET    Error_Code = 'E322',
                         Status     = '3'
                  WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
            ELSE
                  UPDATE Igs_Ad_Relacad_Int_all
                  SET    Error_Code = NULL,
                         Status     = '1'
                  WHERE  Interface_Relacad_Id = Relacad_Rec.Interface_Relacad_Id;
            END IF;
        END IF;
    END IF;
   END IF;
  CLOSE Academic_His_C;
  END IF;
  END LOOP;
END crt_rel_acad_his;

PROCEDURE validate_relns_emp_dtls(
   P_RELEMP_REC IN IGS_AD_RELEMP_INT_ALL%ROWTYPE,
   p_rel_person_id  IN hz_parties.party_id%TYPE,
   P_EMPLOYER_PARTY_ID IN OUT NOCOPY NUMBER,
   P_ERROR_CODE OUT NOCOPY VARCHAR2);

PROCEDURE Crt_Relns_Emp_Dtls(
        P_RELEMP_REC    IGS_AD_RELEMP_INT_ALL%ROWTYPE, p_person_id NUMBER) AS

  lv_var     VARCHAR2(1);
  l_rowid VARCHAR2(25);
  l_msg_data      VARCHAR2(2000);
  l_return_status VARCHAR2(1);
  l_Employment_History_Id NUMBER;
  l_error_code VARCHAR2(30);
  l_count NUMBER(3);
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_request_id NUMBER;
  l_object_version_number NUMBER;
  l_employer_party_id  NUMBER;
  l_enable_log VARCHAR2(1);
BEGIN

    l_prog_label := 'igs.plsql.igs_ad_imp_008.crt_relns_emp_dtls';
    l_label := 'igs.plsql.igs_ad_imp_008.crt_relns_emp_dtls.';
    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
    lv_var := 'N';
    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
       IF (l_request_id IS NULL) THEN
	  l_request_id := fnd_global.conc_request_id;
       END IF;

       l_label := 'igs.plsql.igs_ad_imp_008.crt_relns_emp_dtls.begin';
       l_debug_str :=  'Igs_Ad_Imp_008.Crt_Relns_Emp_Dtls';

       fnd_log.string_with_context( fnd_log.level_procedure,
			            l_label,
		                    l_debug_str, NULL,
				    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

    validate_relns_emp_dtls(P_RELEMP_REC,p_person_id,l_employer_party_id,l_error_code);

    IF l_error_code IS NOT NULL THEN
        UPDATE igs_ad_relemp_int_all
        SET status = '3', error_code = l_error_code
        WHERE interface_relemp_id = p_relemp_rec.interface_relemp_id;
    ELSE
      BEGIN
        --Signature of Igs_Ad_Emp_Dtl_Pkg is changed to include HZ.K impact changes
        Igs_Ad_Emp_Dtl_Pkg.Insert_Row (
                           X_ROWID                  => l_RowId,
                           x_employment_history_id  => l_Employment_History_Id,
                           x_PERSON_ID              => p_person_id,
                           x_START_DT               => P_RELEMP_REC.Start_Dt,
                           x_END_DT                 => P_RELEMP_REC.End_Dt,
                           x_TYPE_OF_EMPLOYMENT     => P_RELEMP_REC.Type_Of_Employment,
                           x_FRACTION_OF_EMPLOYMENT => P_RELEMP_REC.Fraction_Of_Employment,
                           x_TENURE_OF_EMPLOYMENT   => P_RELEMP_REC.Tenure_Of_Employment,
                           x_POSITION               => P_RELEMP_REC.Position,
                           x_OCCUPATIONAL_TITLE_CODE => P_RELEMP_REC.OCCUPATIONAL_TITLE_CODE,
                           x_OCCUPATIONAL_TITLE     => NULL, --P_RELEMP_REC.TITLE,
                           x_WEEKLY_WORK_HOURS      => P_RELEMP_REC.WEEKLY_WORK_HOURS,
                           x_COMMENTS               => P_RELEMP_REC.Comments,
                           x_EMPLOYER               => P_RELEMP_REC.Employer,
                           x_EMPLOYED_BY_DIVISION_NAME => P_RELEMP_REC.Employed_by_division_name,
                           x_BRANCH                 => null,
                           x_MILITARY_RANK          => null,
                           x_SERVED                 => null,
                           x_STATION                => null,
                           x_CONTACT                => p_RELEMP_REC.Contact,  -- Bug : 2037512
                           x_msg_data               => l_msg_data,
                           x_return_status          => l_return_status,
                           x_object_version_number  => l_object_version_number,
                           x_employed_by_party_id   => l_employer_party_id,
                           x_reason_for_leaving     => p_RELEMP_REC.Reason_for_leaving,
                           X_MODE                   => 'R'  );

        IF l_return_Status IN ('E','U') THEN
	    IF l_enable_log = 'Y' THEN
		   fnd_message.set_name('igs', 'igs_ad_crt_emp_dtl_failed');
		   fnd_file.put_line(fnd_file.log, fnd_message.get);
		   -- Log the message Employment Details failed
		   igs_ad_imp_001.logerrormessage(p_relemp_rec.interface_relemp_id,'E322','IGS_AD_RELEMP_INT_ALL');
            END IF;

            IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
               IF (l_request_id IS NULL) THEN
                   l_request_id := fnd_global.conc_request_id;
               END IF;
               l_label := 'igs.plsql.igs_ad_imp_008.crt_relns_emp_dtls.exception';
               fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
               fnd_message.set_token('INTERFACE_ID',p_relemp_rec.interface_relemp_id);
               fnd_message.set_token('ERROR_CD','E322');
               l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;
               fnd_log.string_with_context( fnd_log.level_exception,
		                            l_label,
				            l_debug_str, NULL,
		                            NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
            END IF;
            --ssomani, added the update of igs_ad_relemp_int 15 March 2001
            UPDATE igs_ad_relemp_int_all
            SET  status = '3', error_code = 'E322'
            WHERE interface_relemp_id = p_relemp_rec.interface_relemp_id;
        ELSE
   	    UPDATE igs_ad_relemp_int_all
	    SET	status = '1', error_code = NULL
	    WHERE interface_relemp_id = p_relemp_rec.interface_relemp_id;
        END IF;

      EXCEPTION
         WHEN OTHERS THEN
	    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
	   	IF (l_request_id IS NULL) THEN
	            l_request_id := fnd_global.conc_request_id;
		END IF;

		l_label := 'igs.plsql.igs_ad_imp_008.crt_relns_emp_dtls.exception '||'E518';
		fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		fnd_message.set_token('INTERFACE_ID',p_relemp_rec.interface_relemp_id);
		fnd_message.set_token('ERROR_CD','E518');
		l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;
	        fnd_log.string_with_context( fnd_log.level_exception,
				             l_label,
					     l_debug_str, NULL,
					     NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	    END IF;

            IF l_enable_log = 'Y' THEN
	           igs_ad_imp_001.logerrormessage(p_relemp_rec.interface_relemp_id,'E518','IGS_AD_RELEMP_INT_ALL');
	    END IF;

            UPDATE  igs_ad_relemp_int_all
            SET status = '3', error_code = 'E518'
            WHERE interface_relemp_id = p_relemp_rec.interface_relemp_id;
      END;
    END IF;

END Crt_Relns_Emp_Dtls;

PROCEDURE validate_relns_emp_dtls(P_RELEMP_REC IN IGS_AD_RELEMP_INT_ALL%ROWTYPE,
                              P_REL_PERSON_ID  IN hz_parties.party_id%TYPE,
                              P_EMPLOYER_PARTY_ID IN OUT NOCOPY NUMBER,
                  P_ERROR_CODE OUT NOCOPY VARCHAR2) AS

  CURSOR Validate_Occup_Title( p_occupational_title_code igs_ps_dic_occ_titls.occupational_title_code%TYPE ) IS
  SELECT 'Y'
  FROM igs_ps_dic_occ_titls
  WHERE occupational_title_code = p_occupational_title_code;

  CURSOR employer_party_number_cur(cp_employer_party_number igs_ad_emp_int_all.employer_party_number%TYPE) IS
  SELECT party_id
  FROM HZ_PARTIES
  WHERE party_type = 'ORGANIZATION' AND
        party_number = cp_employer_party_number AND
        status <> 'M';

  CURSOR  birth_date_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
  SELECT birth_date
  FROM   igs_pe_person_base_v
  WHERE  person_id = cp_person_id;

  lv_var     VARCHAR2(1);
  l_count NUMBER(3);
  l_enable_log VARCHAR2(1);
  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
  l_debug_str VARCHAR2(2000);
  l_request_id NUMBER;
  l_birth_date  DATE;

BEGIN

    P_ERROR_CODE := NULL;
    lv_var := 'N';

    l_prog_label := 'igs.plsql.igs_ad_imp_008.validate_relns_emp_dtls';
    l_label := 'igs.plsql.igs_ad_imp_008.validate_relns_emp_dtls.';
    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

       IF (l_request_id IS NULL) THEN
       l_request_id := fnd_global.conc_request_id;
       END IF;

       l_label := 'igs.plsql.igs_ad_imp_008.validate_relns_emp_dtls.begin';
       l_debug_str :=  'Igs_Ad_Imp_008.validate_relns_emp_dtls';

       fnd_log.string_with_context( fnd_log.level_procedure,
                    l_label,
                    l_debug_str, NULL,
                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

    IF P_RELEMP_REC.OCCUPATIONAL_TITLE_CODE IS NOT NULl THEN
      OPEN Validate_Occup_Title (P_RELEMP_REC.OCCUPATIONAL_TITLE_CODE);
      FETCH Validate_Occup_Title INTO lv_var;
      CLOSE Validate_Occup_Title;
    END IF;


    --ssomani, corrected these validations 15 March 2001
      IF  (P_RELEMP_REC.OCCUPATIONAL_TITLE_CODE IS NOT NULl AND lv_var = 'N') THEN
          p_error_code :='E223';
          IF l_enable_log = 'Y' THEN
             igs_ad_imp_001.logerrormessage(p_relemp_rec.interface_relemp_id,p_error_code,'IGS_AD_RELEMP_INT_ALL');
          END IF;
          RETURN;
      END IF;

      IF P_RELEMP_REC.Start_DT IS NULL THEN
         p_error_code :='E407';
         IF l_enable_log = 'Y' THEN
             igs_ad_imp_001.logerrormessage(p_relemp_rec.interface_relemp_id,p_error_code,'IGS_AD_RELEMP_INT_ALL');
         END IF;
         RETURN;
      END IF;

      IF NVL(P_RELEMP_REC.End_Dt,P_RELEMP_REC.Start_Dt) < P_RELEMP_REC.Start_DT THEN
        p_error_code :='E406';
        IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(p_relemp_rec.interface_relemp_id,p_error_code,'IGS_AD_RELEMP_INT_ALL');
        END IF;
        RETURN;
      END IF;

      OPEN birth_date_cur(p_rel_person_id);
      FETCH birth_date_cur INTO l_birth_date;
      CLOSE birth_date_cur;
      -- start date must be greater than birth date
      IF l_birth_date IS NOT NULL THEN
         IF p_relemp_rec.start_dt < l_birth_date THEN
                p_error_code := 'E222';
              IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage( p_relemp_rec.interface_relemp_id,p_error_code,'IGS_AD_RELEMP_INT_ALL');
              END IF;
              RETURN;
        END IF;
      END IF;

      IF P_RELEMP_REC.TYPE_OF_EMPLOYMENT IS NOT NULL THEN
        IF NOT (igs_pe_pers_imp_001.validate_lookup_type_code('HZ_EMPLOYMENT_TYPE',P_RELEMP_REC.TYPE_OF_EMPLOYMENT,222)) THEN
          p_error_code :='E224';
          IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(p_relemp_rec.interface_relemp_id,'E224','IGS_AD_RELEMP_INT_ALL');
          END IF;
          RETURN;
        END IF;
      END IF;

      IF NVL(P_RELEMP_REC.FRACTION_OF_EMPLOYMENT,1) NOT BETWEEN 0.01 AND 100.00 THEN
        p_error_code :='E225';
        IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(p_relemp_rec.interface_relemp_id,p_error_code,'IGS_AD_RELEMP_INT_ALL');
        END IF;
        RETURN;
      END IF;

      IF P_RELEMP_REC.TENURE_OF_EMPLOYMENT IS NOT NULL THEN
        IF NOT (igs_pe_pers_imp_001.validate_lookup_type_code('HZ_TENURE_CODE',P_RELEMP_REC.TENURE_OF_EMPLOYMENT,222))THEN
          p_error_code :='E226';
          IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(p_relemp_rec.interface_relemp_id,p_error_code,'IGS_AD_RELEMP_INT_ALL');
          END IF;
          RETURN;
        END IF;

      END IF;

      IF  P_RELEMP_REC.WEEKLY_WORK_HOURS < 0 OR P_RELEMP_REC.WEEKLY_WORK_HOURS > 168  THEN
        p_error_code :='E227';
        IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(p_relemp_rec.interface_relemp_id,p_error_code,'IGS_AD_RELEMP_INT_ALL');
        END IF;
        RETURN;
      END IF;

      --Employer and Employed_by_party_id are mutually_exclusive
      IF P_RELEMP_REC.employer_party_number IS NOT NULL AND P_RELEMP_REC.EMPLOYER IS NOT NULL THEN
        p_error_code := 'E755';
        IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(P_RELEMP_REC.interface_relemp_id,p_error_code,'IGS_AD_RELEMP_INT_ALL');
        END IF;
        RETURN;
      END IF;

      --validate employer_party_number from  the list of values whose party_type is organization and status <> 'M'
      IF P_RELEMP_REC.employer_party_number IS NOT NULL THEN
        OPEN employer_party_number_cur(P_RELEMP_REC.employer_party_number);
        FETCH employer_party_number_cur INTO p_employer_party_id;
        IF employer_party_number_cur%NOTFOUND THEN
          p_error_code := 'E756';
          IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(P_RELEMP_REC.interface_relemp_id,p_error_code,'IGS_AD_RELEMP_INT_ALL');
          END IF;
          RETURN;
        END IF;
        CLOSE employer_party_number_cur;
      END IF;


END validate_relns_emp_dtls;

PROCEDURE Prc_Relns_Emp_Dtls(
        p_interface_relations_id NUMBER,
        p_rel_person_id NUMBER,
        P_source_type_id           NUMBER )
IS

  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER;
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

  CURSOR Relns_Emp_Dtls(cp_interface_relations_id NUMBER) IS
  SELECT ri.*
  FROM igs_ad_relemp_int_all ri
  WHERE
    INTERFACE_RELATIONS_ID = cP_INTERFACE_RELATIONS_ID AND
    ri.STATUS = '2';

  lv_Var                           VARCHAR2(1);
  l_Var                            VARCHAR2(1);
  l_status                         VARCHAR2(1);
  lv_Row_Id                        VARCHAR2(25);
  lv_Employee_History_Id  NUMBER;
  l_Rule                                  VARCHAR2(1);
  l_return_Status                 VARCHAR2(1);
  l_msg_data                              VARCHAR2(2000);
  l_error_code    VARCHAR2(30);

BEGIN

  l_prog_label := 'igs.plsql.igs_ad_imp_008.prc_relns_emp_dtls';
  l_label := 'igs.plsql.igs_ad_imp_008.prc_relns_emp_dtls.';
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;

IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
       l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_008.prc_relns_emp_dtls.begin';
    l_debug_str :=  'Igs_Ad_Imp_008.Prc_Relns_Emp_Dtls';

    fnd_log.string_with_context( fnd_log.level_procedure,
                    l_label,
                    l_debug_str, NULL,
                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
END IF;

  l_rule := Igs_Ad_Imp_001.find_source_cat_rule(p_source_type_id,'RELATIONS_EMPLOYMENT_DETAILS');

  --1 If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_ad_relemp_int_all
    SET status = '3',
        ERROR_CODE = 'E695'  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND status = '2'
      AND interface_relations_id = p_interface_relations_id;
  END IF;

  --2 If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_ad_relemp_int_all mi
    SET status = '1',
        match_ind = '19'
    WHERE mi.interface_relations_id = p_interface_relations_id
      AND mi.status = '2'
      AND EXISTS ( SELECT 1
                   FROM   IGS_AD_EMP_DTL pe
                   WHERE  PERSON_ID = P_REL_PERSON_ID AND
                   ((NVL(UPPER(pe.EMPLOYER),'*!') = NVL(UPPER(mi.employer),'*')) OR
                   (NVL(mi.employer_party_number,'*!') = NVL(pe.employed_by_party_number,'*'))) AND
                   NVL(TRUNC(pe.START_DT),TO_DATE('4712/12/31','YYYY/MM/DD')) = NVL(TRUNC(mi.start_dt),TO_DATE('4712/12/31','YYYY/MM/DD'))
                 );
  END IF;

  --3 If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_ad_relemp_int_all
    SET status = '1'
    WHERE interface_relations_id = p_interface_relations_id
      AND match_ind IN ('18','19','22','23')
      AND status = '2';
  END IF;

  --4 If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_ad_relemp_int_all
    SET status = '3',
        ERROR_CODE = 'E695'
    WHERE interface_relations_id = p_interface_relations_id
      AND status = '2'
      AND (match_ind IS NOT NULL AND match_ind NOT IN ('21','25'));
  END IF;

  --5 If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_ad_relemp_int_all mi
    SET status = '1',
        match_ind = '23'
    WHERE mi.interface_relations_id = p_interface_relations_id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS ( SELECT '1'
                   FROM IGS_AD_EMP_DTL pe
           WHERE pe.PERSON_ID = p_rel_person_id AND
          ((TRUNC(pe.START_DT) =  TRUNC(mi.Start_Dt) )OR (pe.start_dt IS NULL AND mi.Start_Dt IS NULL ))AND
          ((TRUNC(pe.END_DT) = TRUNC(mi.End_Dt))OR ( pe.end_dt IS NULL AND mi.End_Dt IS NULL )) AND
          ((pe.TYPE_OF_EMPLOYMENT = UPPER(mi.Type_Of_Employment)) OR (pe.TYPE_OF_EMPLOYMENT IS NULL AND mi.Type_Of_Employment IS NULL )) AND
          ((pe.FRACTION_OF_EMPLOYMENT = mi.Fraction_Of_Employment) OR (pe.FRACTION_OF_EMPLOYMENT IS NULL AND  mi.Fraction_Of_Employment IS NULL  )) AND
          ((pe.TENURE_OF_EMPLOYMENT = UPPER(mi.Tenure_Of_Employment)) OR (pe.TENURE_OF_EMPLOYMENT IS NULL AND mi.Tenure_Of_Employment IS NULL  ) ) AND
          ((UPPER(pe.POSITION) = UPPER(mi.Position)) OR (pe.POSITION IS NULL AND mi.Position IS NULL ) ) AND
          ((UPPER(pe.OCCUPATIONAL_TITLE_CODE) = UPPER(mi.Occupational_Title_code)) OR (pe.OCCUPATIONAL_TITLE_CODE IS NULL AND  mi.Occupational_Title_code IS NULL  ) )AND
          ((UPPER(pe.WEEKLY_WORK_HOURS) = UPPER(mi.Weekly_Work_Hours)) OR (pe.WEEKLY_WORK_HOURS IS NULL AND mi.Weekly_Work_Hours IS NULL))AND
          ((pe.COMMENTS = mi.Comments ) OR (pe.COMMENTS IS NULL AND  mi.Comments IS NULL   ) )AND
          (((UPPER(pe.EMPLOYER) = UPPER(mi.Employer)) OR (pe.EMPLOYER IS NULL AND  mi.Employer IS NULL  ) )OR
           ((pe.EMPLOYED_BY_PARTY_NUMBER  = mi.EMPLOYER_PARTY_NUMBER) OR ( pe.EMPLOYED_BY_PARTY_NUMBER IS NULL AND   mi.EMPLOYER_PARTY_NUMBER IS NULL ))) AND
           ((UPPER(pe.EMPLOYED_BY_DIVISION_NAME) = UPPER(mi.Employed_By_Division_Name)) OR (pe.EMPLOYED_BY_DIVISION_NAME IS NULL AND  mi.Employed_By_Division_Name IS NULL ))
               );
  END IF;

  --6 If rule is R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_ad_relemp_int_all mi
    SET status = '3',
        match_ind = '20',
    dup_employment_history_id = (SELECT pe.employment_history_id
                                 FROM IGS_AD_EMP_DTL pe
		                 WHERE  pe.person_id = P_REL_PERSON_ID AND
				 ((NVL(UPPER(pe.EMPLOYER),'*!') = NVL(UPPER(mi.EMPLOYER),'*')) OR
	                         (NVL(pe.EMPLOYED_BY_PARTY_NUMBER,'*!') = NVL(mi.EMPLOYER_PARTY_NUMBER,'*') ))AND
		                  NVL(TRUNC(pe.START_DT),TO_DATE('4712/12/31','YYYY/MM/DD')) = NVL(TRUNC(mi.start_dt),TO_DATE('4712/12/31','YYYY/MM/DD'))
				  AND ROWNUM = 1)
      WHERE mi.interface_relations_id = p_interface_relations_id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS (SELECT '1'
                  FROM IGS_AD_EMP_DTL pe
                   WHERE  pe.PERSON_ID = P_REL_PERSON_ID AND
                  ((NVL(UPPER(pe.EMPLOYER),'*!') = NVL(UPPER(mi.EMPLOYER),'*')) OR
                          (NVL(pe.EMPLOYED_BY_PARTY_NUMBER,'*!') = NVL(mi.EMPLOYER_PARTY_NUMBER,'*'))) AND
              NVL(TRUNC(pe.START_DT),TO_DATE('4712/12/31','YYYY/MM/DD')) = NVL(TRUNC(mi.start_dt),TO_DATE('4712/12/31','YYYY/MM/DD'))
                  );
  END IF;

FOR Relns_Emp_Dtls_Rec IN Relns_Emp_Dtls(p_interface_relations_id) LOOP

DECLARE
  CURSOR chk_dup_cur(cp_Relns_Emp_Dtls_Rec Relns_Emp_Dtls%ROWTYPE,
                     cp_person_id NUMBER) IS
  SELECT pe.*
  FROM igs_ad_emp_dtl pe
  WHERE pe.person_id = cp_person_id
    AND (((NVL(UPPER(pe.employer),'*!')) = NVL(UPPER(cp_Relns_Emp_Dtls_Rec.employer),'*'))
    OR (NVL(pe.employed_by_party_number,'*!') = NVL(cp_Relns_Emp_Dtls_Rec.employer_party_number,'*')))
    AND NVL(TRUNC(pe.START_DT),TO_DATE('4712/12/31','YYYY/MM/DD')) = NVL(TRUNC(cp_Relns_Emp_Dtls_Rec.start_dt),TO_DATE('4712/12/31','YYYY/MM/DD'));

  chk_dup_rec chk_dup_cur%ROWTYPE;
  l_employer_party_id NUMBER;
  l_count NUMBER(3);
BEGIN
    -- changing tenure of employment and type of employment case insensitive
  Relns_Emp_Dtls_Rec.Type_Of_Employment :=  UPPER(Relns_Emp_Dtls_Rec.Type_Of_Employment);
  Relns_Emp_Dtls_Rec.Tenure_of_Employment := UPPER(Relns_Emp_Dtls_Rec.Tenure_of_Employment);
  Relns_Emp_Dtls_Rec.start_dt := TRUNC(Relns_Emp_Dtls_Rec.start_dt);
  Relns_Emp_Dtls_Rec.end_dt := TRUNC(Relns_Emp_Dtls_Rec.end_dt);

  OPEN chk_dup_cur(Relns_Emp_Dtls_Rec,p_rel_person_id);
  FETCH chk_dup_cur INTO chk_dup_rec;
  IF chk_dup_cur%FOUND THEN
    IF l_Rule = 'I' THEN
    DECLARE
      l_exists                        VARCHAR2(1):='N';
      l_count NUMBER(3);

    BEGIN
      --ssomani corrected the validation 15 March 2001

      validate_relns_emp_dtls(Relns_Emp_Dtls_Rec,p_rel_person_id,l_employer_party_id,l_error_code);

      IF l_error_code IS NOT NULL THEN
          UPDATE igs_ad_relemp_int_all
          SET status = '3', error_code = l_error_code
          WHERE interface_relemp_id = relns_emp_dtls_rec.interface_relemp_id;
      ELSE
          --Signature of Igs_Ad_Emp_Dtl_Pkg is changed to include HZ.K impact changes
          Igs_Ad_Emp_Dtl_Pkg.Update_Row (
		   x_rowid                     => chk_dup_rec.Row_Id,
		   x_employment_history_id     => chk_dup_rec.Employment_History_Id,
		   x_person_id                 => NVL(p_rel_person_id,chk_dup_rec.person_id),
	           x_start_dt                  => NVL(relns_emp_dtls_rec.start_dt,chk_dup_rec.start_dt),
		   x_end_dt                    => NVL(relns_emp_dtls_rec.end_dt,chk_dup_rec.end_dt),
	           x_type_of_employment        => NVL(relns_emp_dtls_rec.type_of_employment,chk_dup_rec.type_of_employment),
	           x_fraction_of_employment    => NVL(relns_emp_dtls_rec.fraction_of_employment,chk_dup_rec.fraction_of_employment),
	           x_tenure_of_employment      => NVL(relns_emp_dtls_rec.tenure_of_employment,chk_dup_rec.tenure_of_employment),
	           x_position                  => NVL(relns_emp_dtls_rec.position,chk_dup_rec.position),
		   x_occupational_title_code   => NVL(relns_emp_dtls_rec.occupational_title_code,chk_dup_rec.occupational_title_code),
	           x_occupational_title        => chk_dup_rec.occupational_title,
	           x_weekly_work_hours         => NVL(relns_emp_dtls_rec.weekly_work_hours,chk_dup_rec.weekly_work_hours),
	           x_comments                  => NVL(relns_emp_dtls_rec.comments,chk_dup_rec.comments),
	           x_employer                  => NVL(relns_emp_dtls_rec.employer,chk_dup_rec.employer),
	           x_employed_by_division_name => NVL(relns_emp_dtls_rec.employed_by_division_name,chk_dup_rec.employed_by_division_name),
	           x_branch                    => NVL(relns_emp_dtls_rec.branch,chk_dup_rec.branch),
	           x_military_rank             => NVL(relns_emp_dtls_rec.military_rank,chk_dup_rec.military_rank),
	           x_served                    => NVL(relns_emp_dtls_rec.served,chk_dup_rec.served),
	           x_station                   => NVL(relns_emp_dtls_rec.station,chk_dup_rec.station),
	           x_contact                   => NVL(relns_emp_dtls_rec.contact, chk_dup_rec.contact),  -- bug : 2037512
		   x_msg_data                  => l_msg_data,
	           x_return_status             => l_return_status,
	           x_object_version_number     => chk_dup_rec.object_version_number,
	           x_employed_by_party_id      => NVL(l_employer_party_id,chk_dup_rec.employed_by_party_id),
	           x_reason_for_leaving        => NVL(relns_emp_dtls_rec.reason_for_leaving,chk_dup_rec.reason_for_leaving),
	           x_mode                      => 'R'
          );

	  IF l_return_Status IN ('E','U') THEN
                IF l_enable_log = 'Y' THEN
		     igs_ad_imp_001.logerrormessage(relns_emp_dtls_rec.interface_relemp_id,'E014','IGS_AD_RELEMP_INT_ALL');
                END IF;

                IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
			IF (l_request_id IS NULL) THEN
				l_request_id := fnd_global.conc_request_id;
			END IF;
			l_label := 'igs.plsql.igs_ad_imp_008.prc_relns_emp_dtls.exception '||'E014';

			fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
			fnd_message.set_token('INTERFACE_ID',relns_emp_dtls_rec.interface_relemp_id);
			fnd_message.set_token('ERROR_CD','E014');

			l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;
			fnd_log.string_with_context( fnd_log.level_exception,
                                                     l_label,
						     l_debug_str, NULL,
						     NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
						    );
        	END IF;
		UPDATE igs_ad_relemp_int_all
		SET  error_code = 'E014', status = '3'
		WHERE interface_relemp_id = relns_emp_dtls_rec.interface_relemp_id;
          ELSE
		UPDATE  igs_ad_relemp_int_all
		SET status = '1', error_code = NULL, match_ind ='18'
		WHERE interface_relemp_id = relns_emp_dtls_rec.interface_relemp_id;
          END IF;
      END IF;
    END;
  ELSIF l_rule = 'R' THEN
   IF Relns_Emp_Dtls_Rec.match_ind = '21' THEN
    DECLARE
      l_exists                        VARCHAR2(1):='N';
      l_count NUMBER(3);
      l_employer_party_id NUMBER;

    BEGIN
      --ssomani corrected the validation 15 March 2001

      validate_relns_emp_dtls(Relns_Emp_Dtls_Rec,p_rel_person_id,l_employer_party_id,l_error_code);
      IF l_error_code IS NOT NULL THEN
	  UPDATE igs_ad_relemp_int_all
	  SET status = '3', error_code = l_error_code
	  WHERE interface_relemp_id = relns_emp_dtls_rec.interface_relemp_id;
      ELSE
          --Signature of Igs_Ad_Emp_Dtl_Pkg is changed to include HZ.K impact changes
          Igs_Ad_Emp_Dtl_Pkg.Update_Row (
                   x_rowid                     => chk_dup_rec.Row_Id,
                   x_employment_history_id     => chk_dup_rec.Employment_History_Id,
                   x_person_id                 => NVL(p_rel_person_id,chk_dup_rec.person_id),
                   x_start_dt                  => NVL(relns_emp_dtls_rec.start_dt,chk_dup_rec.start_dt),
                   x_end_dt                    => NVL(relns_emp_dtls_rec.end_dt,chk_dup_rec.end_dt),
                   x_type_of_employment        => NVL(relns_emp_dtls_rec.type_of_employment,chk_dup_rec.type_of_employment),
                   x_fraction_of_employment    => NVL(relns_emp_dtls_rec.fraction_of_employment,chk_dup_rec.fraction_of_employment),
                   x_tenure_of_employment      => NVL(relns_emp_dtls_rec.tenure_of_employment,chk_dup_rec.tenure_of_employment),
                   x_position                  => NVL(relns_emp_dtls_rec.position,chk_dup_rec.position),
                   x_occupational_title_code   => NVL(relns_emp_dtls_rec.occupational_title_code,chk_dup_rec.occupational_title_code),
                   x_occupational_title        => chk_dup_rec.occupational_title,
                   x_weekly_work_hours         => NVL(relns_emp_dtls_rec.weekly_work_hours,chk_dup_rec.weekly_work_hours),
                   x_comments                  => NVL(relns_emp_dtls_rec.comments,chk_dup_rec.comments),
                   x_employer                  => NVL(relns_emp_dtls_rec.employer,chk_dup_rec.employer),
                   x_employed_by_division_name => NVL(relns_emp_dtls_rec.employed_by_division_name,chk_dup_rec.employed_by_division_name),
                   x_branch                    => NVL(relns_emp_dtls_rec.branch,chk_dup_rec.branch),
                   x_military_rank             => NVL(relns_emp_dtls_rec.military_rank,chk_dup_rec.military_rank),
                   x_served                    => NVL(relns_emp_dtls_rec.served,chk_dup_rec.served),
                   x_station                   => NVL(relns_emp_dtls_rec.station,chk_dup_rec.station),
                   x_contact                   => NVL(relns_emp_dtls_rec.contact, chk_dup_rec.contact),  -- Bug : 2037512
                   x_msg_data                  => l_msg_data,
                   x_return_status             => l_return_status,
                   x_object_version_number     => chk_dup_rec.object_version_number,
                   x_employed_by_party_id      => NVL(l_employer_party_id,chk_dup_rec.employed_by_party_id),
                   x_reason_for_leaving        => NVL(relns_emp_dtls_rec.reason_for_leaving,chk_dup_rec.reason_for_leaving),
                   x_mode                      => 'R'
                  );
          IF l_return_Status IN ('E','U') THEN
               IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                     IF (l_request_id IS NULL) THEN
                          l_request_id := fnd_global.conc_request_id;
                     END IF;
                     l_label := 'igs.plsql.igs_ad_imp_008.prc_relns_emp_dtls.exception';
                     fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                     fnd_message.set_token('INTERFACE_ID',relns_emp_dtls_rec.interface_relemp_id);
                     fnd_message.set_token('ERROR_CD','E014');
                     l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;
                     fnd_log.string_with_context( fnd_log.level_exception,
	                                          l_label,
		                                  l_debug_str, NULL,
			                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
						 );
               END IF;

               IF l_enable_log = 'Y' THEN
                    igs_ad_imp_001.logerrormessage(relns_emp_dtls_rec.interface_relemp_id,'E014','IGS_AD_RELEMP_INT_ALL');
               END IF;
               UPDATE  igs_ad_relemp_int_all
               SET   error_code = 'E014', status = '3'
               WHERE interface_relemp_id = relns_emp_dtls_rec.interface_relemp_id;
          ELSE
               UPDATE  igs_ad_relemp_int_all
               SET error_code = NULL, status = '1', match_ind ='18'
               WHERE interface_relemp_id = relns_emp_dtls_rec.interface_relemp_id;
          END IF;
      END IF;
    END;
   END IF; /*match_ind = 21*/
  END IF; /*l_rule*/
ELSE
    Crt_Relns_Emp_Dtls(Relns_Emp_Dtls_Rec, p_Rel_Person_Id);
END IF;
CLOSE chk_dup_cur;
END;
END LOOP;
END;
-- End of Prc_Relns_Emp_Dtls


--
-- Start of Main Procedure for Person Special Need
--

PROCEDURE  prc_pe_spl_needs (
                   p_source_type_id     IN      NUMBER,
                   p_batch_id   IN      NUMBER )
    AS
 /*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 06-Jul-2001
  ||  Purpose : This procedure is for importing person Special Need Information.
  ||            DLD: Person Interface DLD.  Enh Bug# 2103692.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel        23-DEC-2002     Bug No: 2722027
  ||                                 The call to PRC_SPECIAL_NEEDS added and all the code was moved to IGSAD89B.pls
  ||  (reverse chronological order - newest change first)
  */
        --Start of the Main Processing
      BEGIN
        igs_ad_imp_011.prc_special_needs(
          p_source_type_id,
          p_batch_id);

      END prc_pe_spl_needs;
--
-- End of Main Procedure PRC_PE_SPL_NEEDS
--

-- Prc_Pe_Stat is now changed to Prc_Pe_Stat_Main
-- Person Interface DLD. 2103692 -- ssawhney

PROCEDURE Prc_Pe_Stat_Main(
           p_source_type_id IN  NUMBER,
           p_batch_id IN NUMBER )
/*
 ||  Created By : ssawhney
 ||  Created On : 15 november
 ||  Purpose : Prc_Pe_Stat is now changed to Prc_Pe_Stat_Main
 ||
 ||  Change :
 || npalanis         6-JAN-2003      Bug : 2734697
 ||                                  code added to commit after import of every
 ||                                  100 records .New variable l_processed_records added
 ||  ssawhney  27may   bug 2385296. - the person id should be picked from IGS_AD_INTERFACE and not IGS_AD_STAT_INT.
 ||                    the person id is now referred as stat_rec.pid.
 ||  kumma     02-JUL-2002 bug 2421786 remved the duplicate log messages. after a call to Validate_Person_Statistics
 ||                                    if there is error then it was logging a error message though it was already done
 ||                        in called procedure Validate_Person_Statistics. also changed the interface_id to
 ||                 interface_stat_id
 || npalanis       19-OCT-2002       Bug - 2608360
 ||                                   The stat package call is changed for transition of code classes to lookups
    */
AS

-- modified as part of Person Interface DLD
-- ssawhney 2193692

        p_status VARCHAR2(1);
        p_error_code VARCHAR2(30);
        l_rowid VARCHAR2(25);
        l_var VARCHAR2(2000);
        l_var_person VARCHAR2(1);
        l_rule VARCHAR2(1);
        l_statistics_id NUMBER;
        l_processed_records NUMBER(5);

  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER;
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

    CURSOR per_stat(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
    SELECT  mi.*, i.person_id pid
    FROM    igs_ad_stat_int_all mi, igs_ad_interface_all i
    WHERE  mi.interface_run_id = cp_interface_run_id
      AND  mi.interface_id =  i.interface_id
      AND  i.interface_run_id = cp_interface_run_id
      AND  mi.status = '2'
      AND  i.status IN ('1','4');

    stat_rec per_stat%ROWTYPE;
    l_error_code VARCHAR2(30);
    l_status VARCHAR2(10);
    l_success VARCHAR2(1);

    l_return_status VARCHAR2(1);
    l_msg_data              VARCHAR2(2000);
    l_msg_count             NUMBER;
    l_party_last_update_date DATE;
    l_person_profile_id                      NUMBER;
    l_default_date DATE := IGS_GE_DATE.IGSDATE('4712/12/01');

PROCEDURE Validate_Person_Statistics(p_per_stat per_stat%ROWTYPE, p_success OUT NOCOPY VARCHAR2, p_error_code OUT NOCOPY VARCHAR2)
IS
  l_var     VARCHAR2(1);
  l_birth_date    DATE;

BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
       l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.begin_validate_person_statistics';
    l_debug_str :=  'Igs_Ad_Imp_008.Validate_Person_Statistics';

    fnd_log.string_with_context( fnd_log.level_procedure,
                    l_label,
                    l_debug_str, NULL,
                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  IF p_per_stat.RELIGION_CD IS NOT NULL THEN
                -- kumma, added the condition in where clause that the code should not be marked as closed.
            -- bug 2421786
    IF  NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('PE_RELIGION',p_per_stat.religion_cd,8405))
    THEN
      p_success := 'N';
      p_error_code := 'E205';

      IF l_enable_log = 'Y' THEN
         igs_ad_imp_001.logerrormessage(p_per_stat.interface_stat_id,'E205','IGS_AD_STAT_INT_ALL');
      END IF;

            UPDATE igs_ad_stat_int_all
            SET    error_code  = 'E205',
            status      = '3'
            WHERE  interface_stat_id = p_per_stat.interface_stat_id;
      RETURN;
    END IF;
  END IF;

  IF p_per_stat.MARITAL_STATUS IS NOT NULL THEN
    IF  NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('MARITAL_STATUS',p_per_stat.marital_status,222))
    THEN
         --Bug Id :  2138382
      p_success := 'N';
      p_error_code := 'E206';

      IF l_enable_log = 'Y' THEN
         igs_ad_imp_001.logerrormessage(p_per_stat.interface_stat_id,'E206','IGS_AD_STAT_INT_ALL');
      END IF;

      UPDATE igs_ad_stat_int_all
      SET    error_code  = 'E206',
            status      = '3'
      WHERE  interface_stat_id = p_per_stat.interface_stat_id;
      RETURN;
    END IF;
  END IF;

    --kumma, adding validations for the MARITAL_STATUS_EFFECTIVE_DATE, this date should not be less than the
    -- date of birth, bug 2421786

  IF p_per_stat.MARITAL_STATUS_EFFECTIVE_DATE IS NOT NULL THEN
    DECLARE
    CURSOR c_mar_eff_dt(p_person_id igs_pe_person.person_id%TYPE) IS
    SELECT  BIRTH_DATE
    FROM    IGS_PE_PERSON_BASE_V WHERE PERSON_ID =p_person_id;

    BEGIN
      OPEN c_mar_eff_dt(p_per_stat.pid);
      FETCH c_mar_eff_dt INTO l_birth_date;
      CLOSE c_mar_eff_dt;
      IF l_birth_date IS NOT NULL THEN
        IF p_per_stat.MARITAL_STATUS_EFFECTIVE_DATE < l_birth_date THEN
          raise no_data_found;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_success := 'N';
        p_error_code := 'E277';

    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

        IF (l_request_id IS NULL) THEN
          l_request_id := fnd_global.conc_request_id;
        END IF;

         l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.exception '||'E277';

         fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
         fnd_message.set_token('INTERFACE_ID',p_per_stat.interface_stat_id);
         fnd_message.set_token('ERROR_CD','E277');

         l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

         fnd_log.string_with_context( fnd_log.level_exception,
                      l_label,
                      l_debug_str, NULL,
                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

        IF l_enable_log = 'Y' THEN
         igs_ad_imp_001.logerrormessage(p_per_stat.interface_stat_id,'E277','IGS_AD_STAT_INT_ALL');
        END IF;

    UPDATE igs_ad_stat_int_all
    SET    error_code  = 'E277',
    status      = '3'
    WHERE  interface_stat_id = p_per_stat.interface_stat_id;
    RETURN;
    END;
  END IF;

 -- code for country_cd3 and resid_stat_id to be removed, as this column is obsoleted from the table
 -- ssawhney Person Interface DLD. 2103692

  IF p_per_stat.ETHNIC_ORIGIN  IS NOT NULL THEN
    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('IGS_ETHNIC_ORIGIN',p_per_stat.ETHNIC_ORIGIN,8405))
    THEN
      p_success := 'N';
      p_error_code := 'E207';

      IF l_enable_log = 'Y' THEN
         igs_ad_imp_001.logerrormessage(p_per_stat.interface_stat_id,'E207','IGS_AD_STAT_INT_ALL');
      END IF;

      UPDATE igs_ad_stat_int_all
      SET    error_code  = 'E207',
            status      = '3'
      WHERE  interface_stat_id = p_per_stat.interface_stat_id;

      RETURN;
    END IF;
  END IF;
  -- All the validations has been moved out NOCOPY to HZ packages
  p_success := 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      p_success := 'N';
  END;
        -- End local Proc Validate_Person_Statistics
        --Local procedure to validate descriptive flexfield

PROCEDURE  Validate_desc_flex(stat_rec IN per_stat%ROWTYPE,
                                     p_success OUT NOCOPY VARCHAR2)
AS
BEGIN
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


                                p_success  := 'N';
                                RAISE NO_DATA_FOUND;
  ELSE
                                p_success  := 'Y' ;

  END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
                L_MSG_DATA := SQLERRM;
            UPDATE      IGS_AD_STAT_INT_ALL
                        SET     status = '3',
                                error_code = 'E170'
                        WHERE   interface_id = stat_rec.INTERFACE_ID;

            -- there was a call to update IGS_AD_INTERFACE with status=3, that is not required.
            -- UPDATE   IGS_AD_INTERFACE

                -- Call Log detail

    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

        IF (l_request_id IS NULL) THEN
          l_request_id := fnd_global.conc_request_id;
        END IF;

         l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.exception '||'E170';

         fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
         fnd_message.set_token('INTERFACE_ID',stat_rec.interface_stat_id);
         fnd_message.set_token('ERROR_CD','E170');

         l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

         fnd_log.string_with_context( fnd_log.level_exception,
                      l_label,
                      l_debug_str, NULL,
                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

        IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(stat_rec.interface_stat_id,'E170','IGS_AD_STAT_INT_ALL');
        END IF;



  END Validate_desc_flex;

  PROCEDURE Crt_Pe_Stat( stat_rec IN per_stat%ROWTYPE,
                               p_error_code OUT NOCOPY VARCHAR2,
                               p_status OUT NOCOPY VARCHAR2) AS
                                   l_statistics_id NUMBER;
                l_rowid VARCHAR2(25);
                l_success VARCHAR2(1);
                l_return_status VARCHAR2(1);
                l_msg_data              VARCHAR2(2000);
                l_msg_count             NUMBER;
                l_party_last_update_date DATE;
                l_person_profile_id       NUMBER;
                l_error_code VARCHAR2(30);
                l_object_version_number NUMBER;


  BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
       l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.begin_crt_pe_stat';
    l_debug_str :=  'Igs_Ad_Imp_008.Crt_Pe_Stat';

    fnd_log.string_with_context( fnd_log.level_procedure,
                    l_label,
                    l_debug_str, NULL,
                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  Validate_Person_Statistics(p_per_stat => stat_rec, p_success => l_success, p_error_code =>l_error_code);

  IF l_success = 'Y' THEN
  --Validation check of Descriptive Flexfield
  -- Added as a part of bug number 2203778
    l_success := NULL;
    Validate_desc_flex(stat_rec ,l_success );
    IF l_success = 'Y' THEN

--Bayadav :Changed the columns values getting passed for attribute1 to attribute20 from null
--to new flexfield columns added in iGS_AD_STAT_INT table to pass these flexfields values  in newly added
-- felxfield in IGS_PE_STAT_DETAILS table as a part of bug 2203778

      igs_pe_stat_pkg.insert_row(
                X_ACTION=> 'INSERT',
                X_ROWID=> l_rowid,
                X_PERSON_ID => stat_rec.pid,   --stat_rec.person_id,
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
                X_HZ_PARTIES_OVN => l_object_version_number,
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
                X_GLOBAL_ATTRIBUTE_CATEGORY     => NULL,
                X_GLOBAL_ATTRIBUTE1           => NULL,
                X_GLOBAL_ATTRIBUTE2             => NULL,
                X_GLOBAL_ATTRIBUTE3            => NULL,
                X_GLOBAL_ATTRIBUTE4 => NULL,
                X_GLOBAL_ATTRIBUTE5      => NULL,
                X_GLOBAL_ATTRIBUTE6      => NULL,
                X_GLOBAL_ATTRIBUTE7        => NULL,
                X_GLOBAL_ATTRIBUTE8  => NULL,
                X_GLOBAL_ATTRIBUTE9    => NULL,
                X_GLOBAL_ATTRIBUTE10     => NULL,
                X_GLOBAL_ATTRIBUTE11      => NULL,
                X_GLOBAL_ATTRIBUTE12     => NULL,
                X_GLOBAL_ATTRIBUTE13     => NULL,
                X_GLOBAL_ATTRIBUTE14  => NULL,
                X_GLOBAL_ATTRIBUTE15     => NULL,
                X_GLOBAL_ATTRIBUTE16     => NULL,
                X_GLOBAL_ATTRIBUTE17     => NULL,
                X_GLOBAL_ATTRIBUTE18     => NULL,
                X_GLOBAL_ATTRIBUTE19      => NULL,
                X_GLOBAL_ATTRIBUTE20       => NULL,
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

                                IF l_return_status IN('E','U') THEN
                                        p_status :='3';
                                        p_error_code := 'E005';

                    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                        IF (l_request_id IS NULL) THEN
                            l_request_id := fnd_global.conc_request_id;
                        END IF;

                        l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.exception '||'E005';

                        fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                        fnd_message.set_token('INTERFACE_ID',stat_rec.interface_stat_id);
                        fnd_message.set_token('ERROR_CD','E005');

                        l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

                        fnd_log.string_with_context( fnd_log.level_exception,
                                          l_label,
                                          l_debug_str, NULL,
                                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                    END IF;

                      IF l_enable_log = 'Y' THEN
                         igs_ad_imp_001.logerrormessage(stat_rec.interface_stat_id,'E005','IGS_AD_STAT_INT_ALL');
                      END IF;
                                ELSE
                                        p_status :='1';
                                        p_error_code := NULL;
                                END IF;
                      ELSE
                      --In case descriptive validation failed
                                p_status := '3';
                                p_error_code := 'E170';

                       END IF;

          -- else part will be required now. ssawhney.
              ELSE
               p_status := '3';
               p_error_code := l_error_code;  -- assign to p_error_code and this will be used down the line

              END IF;


        EXCEPTION

                WHEN OTHERS THEN
                        l_msg_data := SQLERRM;
                        p_status :='3';
                        p_error_code := 'E005';


        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

             l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.exception2';

             fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
             fnd_message.set_token('INTERFACE_ID',stat_rec.interface_stat_id);
             fnd_message.set_token('ERROR_CD','E005');

             l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

             fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;

            IF l_enable_log = 'Y' THEN
               igs_ad_imp_001.logerrormessage(stat_rec.interface_stat_id,'E005','IGS_AD_STAT_INT_ALL');
            END IF;

        END Crt_Pe_Stat; -- end of local procedure crt_pe_stat

-- main procedure begins
BEGIN
    -- Call Log header
  l_processed_records := 0;
  l_prog_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main';
  l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.';
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
       l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.begin';
    l_debug_str :=  'Igs_Ad_Imp_008.Prc_Pe_Stat_Main';

    fnd_log.string_with_context( fnd_log.level_procedure,
                    l_label,
                    l_debug_str, NULL,
                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

    l_rule := Igs_Ad_Imp_001.find_source_cat_rule (p_source_type_id, 'PERSON_STATISTICS');
    --ssomani, corrected the looping 15 March 2001

  --1. If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE IGS_AD_STAT_INT_all
    SET status = '3',
        ERROR_CODE = 'E695'  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND status = '2'
      AND interface_run_id = l_interface_run_id;
  END IF;

  --2 If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE IGS_AD_STAT_INT_all mi
    SET status = '1',
        match_ind = '19'
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.status = '2'
      AND EXISTS ( SELECT '1'
                   FROM   hz_parties hp, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
                   AND  ii.interface_id = mi.interface_id
                   AND  ii.person_id = hp.party_id);
  END IF;

  --3 If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE IGS_AD_STAT_INT_all
    SET status = '1'
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN ('18','19','22','23')
      AND status = '2';
  END IF;

  --4 If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE IGS_AD_STAT_INT_all
    SET status = '3',
        ERROR_CODE = 'E695'
    WHERE interface_run_id = l_interface_run_id
      AND status = '2'
      AND (match_ind IS NOT NULL AND match_ind NOT IN ('21','25'));
  END IF;

  --5 If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE IGS_AD_STAT_INT_all mi
    SET status = '1',
        match_ind = '23'
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS ( SELECT 1
                   FROM   hz_person_profiles pp,
                          igs_pe_stat_details sd,
			  igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id AND
            ii.interface_id = mi.interface_id AND
            ii.person_id = pp.party_id AND
            sd.person_id(+)  = pp.party_id AND
            SYSDATE BETWEEN pp.effective_start_date AND NVL(pp.effective_end_date, SYSDATE) AND
            NVL(pp.declared_ethnicity,'*') = NVL(mi.ethnic_origin,'*') AND
            NVL(pp.marital_status,'*') = NVL(UPPER(mi.marital_status),'*') AND
            NVL(sd.religion_cd,'*') =  NVL(mi.religion_cd,'*') AND
            NVL(TRUNC(pp.marital_status_effective_date), l_default_date)
                = NVL(TRUNC(mi.marital_status_effective_date),l_default_date)AND
            NVL(UPPER(pp.place_of_birth),'*') =  NVL(UPPER(mi.place_of_birth),'*') AND
            NVL(UPPER(sd.attribute1),'*') =  NVL(UPPER(mi.attribute1),'*') AND
            NVL(UPPER(sd.attribute2),'*') =  NVL(UPPER(mi.attribute2),'*') AND
            NVL(UPPER(sd.attribute3),'*') =  NVL(UPPER(mi.attribute3),'*') AND
            NVL(UPPER(sd.attribute4),'*') =  NVL(UPPER(mi.attribute4),'*') AND
            NVL(UPPER(sd.attribute5),'*') =  NVL(UPPER(mi.attribute5),'*') AND
            NVL(UPPER(sd.attribute6),'*') =  NVL(UPPER(mi.attribute6),'*') AND
            NVL(UPPER(sd.attribute7),'*') =  NVL(UPPER(mi.attribute7),'*') AND
            NVL(UPPER(sd.attribute8),'*') =  NVL(UPPER(mi.attribute8),'*') AND
            NVL(UPPER(sd.attribute9),'*') =  NVL(UPPER(mi.attribute9),'*') AND
            NVL(UPPER(sd.attribute10),'*') =  NVL(UPPER(mi.attribute10),'*') AND
            NVL(UPPER(sd.attribute11),'*') =  NVL(UPPER(mi.attribute11),'*') AND
            NVL(UPPER(sd.attribute12),'*') =  NVL(UPPER(mi.attribute12),'*') AND
            NVL(UPPER(sd.attribute13),'*') =  NVL(UPPER(mi.attribute13),'*') AND
            NVL(UPPER(sd.attribute14),'*') =  NVL(UPPER(mi.attribute14),'*') AND
            NVL(UPPER(sd.attribute15),'*') =  NVL(UPPER(mi.attribute15),'*') AND
            NVL(UPPER(sd.attribute16),'*') =  NVL(UPPER(mi.attribute16),'*') AND
            NVL(UPPER(sd.attribute17),'*') =  NVL(UPPER(mi.attribute17),'*') AND
            NVL(UPPER(sd.attribute18),'*') =  NVL(UPPER(mi.attribute18),'*') AND
            NVL(UPPER(sd.attribute19),'*') =  NVL(UPPER(mi.attribute19),'*') AND
            NVL(UPPER(sd.attribute20),'*') =  NVL(UPPER(mi.attribute20),'*') AND
            NVL(UPPER(sd.attribute_category),'*') =  NVL(UPPER(mi.attribute_category),'*')
             );
  END IF;

  --6 If rule is R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE IGS_AD_STAT_INT_all mi
    SET status = '3',
        match_ind = '20'
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS (SELECT '1'
                  FROM hz_parties hp,
		       igs_ad_interface_all ii
          WHERE  ii.interface_run_id = l_interface_run_id
            AND  ii.interface_id = mi.interface_id
            AND  ii.person_id = hp.party_id);
  END IF;

  FOR stat_rec IN per_stat(l_interface_run_id) LOOP
  DECLARE
    CURSOR chk_dup_cur(cp_person_id igs_pe_stat_v.person_id%TYPE) IS
    SELECT
    p.rowid row_id,
    pp.person_profile_id,
    p.party_id person_id,
    p.party_number person_number,
    pp.effective_start_date,
    pp.effective_end_date,
    pp.declared_ethnicity ethnic_origin_id,
    pp.marital_status,
    pp.marital_status_effective_date,
    pp.internal_flag,
    sd.religion_cd religion,
    sd.next_to_kin,
    pp.place_of_birth,
    sd.socio_eco_cd socio_eco_status,
    sd.further_education_cd further_education,
    pp.household_size number_in_family,
    pp.household_income ann_family_income,
    sd.in_state_tuition,
    sd.tuition_st_date,
    sd.tuition_end_date,
    sd.matr_cal_type,
    sd.matr_sequence_number,
    sd.init_cal_type,
    sd.init_sequence_number,
    sd.recent_cal_type,
    sd.recent_sequence_number,
    sd.catalog_cal_type,
    sd.catalog_sequence_number,
    sd.attribute_category attribute_category,
    sd.attribute1 attribute1,
    sd.attribute2 attribute2,
    sd.attribute3 attribute3,
    sd.attribute4 attribute4,
    sd.attribute5 attribute5,
    sd.attribute6 attribute6,
    sd.attribute7 attribute7,
    sd.attribute8 attribute8,
    sd.attribute9 attribute9,
    sd.attribute10 attribute10,
    sd.attribute11 attribute11,
    sd.attribute12 attribute12,
    sd.attribute13 attribute13,
    sd.attribute14 attribute14,
    sd.attribute15 attribute15,
    sd.attribute16 attribute16,
    sd.attribute17 attribute17,
    sd.attribute18 attribute18,
    sd.attribute19 attribute19,
    sd.attribute20 attribute20,
    pp.global_attribute_category,
    pp.global_attribute1,
    pp.global_attribute2,
    pp.global_attribute3,
    pp.global_attribute4,
    pp.global_attribute5,
    pp.global_attribute6,
    pp.global_attribute7,
    pp.global_attribute8,
    pp.global_attribute9,
    pp.global_attribute10,
    pp.global_attribute11,
    pp.global_attribute12,
    pp.global_attribute13,
    pp.global_attribute14,
    pp.global_attribute15,
    pp.global_attribute16,
    pp.global_attribute17,
    pp.global_attribute18,
    pp.global_attribute19,
    pp.global_attribute20,
    pp.person_initials,
    pp.primary_contact_id,
    pp.personal_income,
    pp.head_of_household_flag,
    pp.content_source_type,
    pp.content_source_number,
    p.object_version_number object_version_number
    FROM
    hz_person_profiles pp,
    igs_pe_stat_details sd,
    hz_parties p
    WHERE
    sd.person_id(+)  = p.party_id AND
    pp.party_id   = p.party_id AND
    SYSDATE BETWEEN pp.effective_start_date AND NVL(pp.effective_end_date, SYSDATE) AND
    p.party_id = cp_person_id;

    chk_dup_rec chk_dup_cur%ROWTYPE;
  BEGIN
  l_processed_records := l_processed_records + 1 ;
            -- kumma, 2421786
            -- marital status and ethnic origin are made case insensitive
  stat_rec.marital_status := UPPER(stat_rec.marital_status);
  stat_rec.ethnic_origin := UPPER(stat_rec.ethnic_origin);
  stat_rec.marital_status_effective_date := TRUNC(stat_rec.marital_status_effective_date);

  OPEN chk_dup_cur(stat_rec.pid);
  FETCH chk_dup_cur INTO chk_dup_rec;
  IF chk_dup_cur%FOUND THEN
    IF l_rule = 'I' THEN
      BEGIN

      Validate_Person_Statistics(p_per_stat => stat_rec, p_success => l_success, p_error_code=>l_error_code);
          IF l_success = 'Y' THEN
  -- ssawhney 2203778 person_id was passed into person number
  -- and ethenic_origin_id is not a field in int tables

  --Validation check of Descriptive Flexfield
  -- Added as a part of bug number 2203778
            l_success := NULL;
            Validate_desc_flex(stat_rec ,l_success );

            IF l_success = 'Y' THEN
               IGS_PE_STAT_PKG.Update_Row(
                    X_ACTION => 'UPDATE',
                    x_rowid => chk_dup_rec.row_id,
                    x_person_id => stat_rec.pid,  -- stat_rec.person_id ,
                    x_ethnic_origin_id => NVL(stat_rec.ethnic_origin,chk_dup_rec.ethnic_origin_id), -- BUG ID: 2138382
                    x_marital_status => NVL(stat_rec.marital_status,chk_dup_rec.marital_status),
                    x_marital_stat_effect_dt => NVL(stat_rec.marital_status_effective_date,TRUNC(chk_dup_rec.marital_status_effective_date)),
                    x_ann_family_income => chk_dup_rec.ann_family_income,
                    x_number_in_family => chk_dup_rec.number_in_family,
                    x_content_source_type => 'USER_ENTERED',
                    x_internal_flag => chk_dup_rec.internal_flag,
                    x_person_number => chk_dup_rec.person_number,
                    x_effective_start_date => TRUNC(chk_dup_rec.effective_start_date),
                    x_effective_end_date => TRUNC(chk_dup_rec.effective_end_date),
                    x_ethnic_origin => NULL,
                    x_religion => NVL(stat_rec.religion_cd,chk_dup_rec.religion),
                    x_next_to_kin => chk_dup_rec.next_to_kin,
                    x_next_to_kin_meaning => NULL,
                    x_place_of_birth => NVL(stat_rec.place_of_birth,chk_dup_rec.place_of_birth),
                    x_socio_eco_status => chk_dup_rec.socio_eco_status,
                    x_socio_eco_status_desc => NULL,
                    x_further_education => chk_dup_rec.further_education,
                    x_further_education_desc => NULL,
                    x_in_state_tuition => chk_dup_rec.in_state_tuition,
                    x_tuition_st_date => TRUNC(chk_dup_rec.tuition_st_date),
                    x_tuition_end_date => TRUNC(chk_dup_rec.tuition_end_date),
                    x_person_initials => chk_dup_rec.person_initials,
                    x_primary_contact_id => chk_dup_rec.primary_contact_id,
                    x_personal_income => chk_dup_rec.personal_income,
                    x_head_of_household_flag => chk_dup_rec.head_of_household_flag,
                    x_content_source_number => chk_dup_rec.content_source_number,
                    x_attribute_category =>  NVL(stat_rec.attribute_category,chk_dup_rec.attribute_category),
                    x_hz_parties_ovn => chk_dup_rec.object_version_number,
                    x_attribute1          =>  NVL(stat_rec.attribute1,chk_dup_rec.attribute1),
                    x_attribute2          =>  NVL(stat_rec.attribute2,chk_dup_rec.attribute2),
                    x_attribute3          =>  NVL(stat_rec.attribute3,chk_dup_rec.attribute3),
                    x_attribute4          =>  NVL(stat_rec.attribute4,chk_dup_rec.attribute4),
                    x_attribute5          =>  NVL(stat_rec.attribute5,chk_dup_rec.attribute5),
                    x_attribute6          =>  NVL(stat_rec.attribute6,chk_dup_rec.attribute6),
                    x_attribute7          =>  NVL(stat_rec.attribute7,chk_dup_rec.attribute7),
                    x_attribute8          =>  NVL(stat_rec.attribute8,chk_dup_rec.attribute8),
                    x_attribute9          =>  NVL(stat_rec.attribute9,chk_dup_rec.attribute9),
                    x_attribute10         =>  NVL(stat_rec.attribute10,chk_dup_rec.attribute10),
                    x_attribute11         =>  NVL(stat_rec.attribute11,chk_dup_rec.attribute11),
                    x_attribute12         =>  NVL(stat_rec.attribute12,chk_dup_rec.attribute12),
                    x_attribute13         =>  NVL(stat_rec.attribute13,chk_dup_rec.attribute13),
                    x_attribute14         =>  NVL(stat_rec.attribute14,chk_dup_rec.attribute14),
                    x_attribute15         =>  NVL(stat_rec.attribute15,chk_dup_rec.attribute15),
                    x_attribute16         =>  NVL(stat_rec.attribute16,chk_dup_rec.attribute16),
                    x_attribute17         =>  NVL(stat_rec.attribute17,chk_dup_rec.attribute17),
                    x_attribute18         =>  NVL(stat_rec.attribute18,chk_dup_rec.attribute18),
                    x_attribute19         =>  NVL(stat_rec.attribute19,chk_dup_rec.attribute19),
                    x_attribute20         =>  NVL(stat_rec.attribute20,chk_dup_rec.attribute20),
                    x_global_attribute_category => chk_dup_rec.global_attribute_category,
                    x_global_attribute1 => chk_dup_rec.global_attribute1,
                    x_global_attribute2=> chk_dup_rec.global_attribute1,
                    x_global_attribute3=> chk_dup_rec.global_attribute1,
                    x_global_attribute4=> chk_dup_rec.global_attribute1,
                    x_global_attribute5=> chk_dup_rec.global_attribute1,
                    x_global_attribute6=> chk_dup_rec.global_attribute1,
                    x_global_attribute7=> chk_dup_rec.global_attribute1,
                    x_global_attribute8=> chk_dup_rec.global_attribute1,
                    x_global_attribute9=> chk_dup_rec.global_attribute1,
                    x_global_attribute10=> chk_dup_rec.global_attribute1,
                    x_global_attribute11=> chk_dup_rec.global_attribute1,
                    x_global_attribute12=> chk_dup_rec.global_attribute1,
                    x_global_attribute13=> chk_dup_rec.global_attribute1,
                    x_global_attribute14=> chk_dup_rec.global_attribute1,
                    x_global_attribute15=> chk_dup_rec.global_attribute1,
                    x_global_attribute16=> chk_dup_rec.global_attribute1,
                    x_global_attribute17=> chk_dup_rec.global_attribute1,
                    x_global_attribute18=> chk_dup_rec.global_attribute1,
                    x_global_attribute19=> chk_dup_rec.global_attribute1,
                    x_global_attribute20=> chk_dup_rec.global_attribute1,
                    x_party_last_update_date=> l_party_last_update_date,
                    x_person_profile_id => chk_dup_rec.person_profile_id,
                    x_matr_cal_type => chk_dup_rec.matr_cal_type,
                    x_matr_sequence_number => chk_dup_rec.matr_sequence_number,
                    x_init_cal_type => chk_dup_rec.init_cal_type,
                    x_init_sequence_number => chk_dup_rec.init_sequence_number,
                    x_recent_cal_type => chk_dup_rec.recent_cal_type,
                    x_recent_sequence_number => chk_dup_rec.recent_sequence_number,
                    x_catalog_cal_type => chk_dup_rec.catalog_cal_type,
                    x_catalog_sequence_number => chk_dup_rec.catalog_sequence_number,
                    z_return_status => l_return_status,
                    z_msg_count => l_msg_count,
                    z_msg_data => l_msg_data,
		    x_birth_cntry_resn_code  => NULL   --- prbhardw
                       );

      IF l_return_status IN('E','U') THEN
            UPDATE igs_ad_stat_int_all
            SET status = '3',error_code = 'E014'
            WHERE interface_id = stat_rec.interface_id
              AND interface_stat_id = stat_rec.interface_stat_id;

        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

             l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.exception '||'E014';

             fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
             fnd_message.set_token('INTERFACE_ID',stat_rec.interface_stat_id);
             fnd_message.set_token('ERROR_CD','E014');

             l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

             fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;

            IF l_enable_log = 'Y' THEN
              igs_ad_imp_001.logerrormessage(stat_rec.interface_stat_id,'E014','IGS_AD_STAT_INT_ALL');
            END IF;
          ELSE
        UPDATE
            igs_ad_stat_int_all
        SET
            error_code = NULL, --ssomani, added this 15 March 2001
            status = '1', match_ind = '18'
        WHERE
            interface_id = stat_rec.interface_id
            AND interface_stat_id = stat_rec.interface_stat_id;
      END IF;
        END IF;  --l_success =Y for dflex validation.
                -- kumma, removed the else clause, 2421786
      END IF;   --l_success =Y for Stat validation.
    EXCEPTION
        WHEN OTHERS THEN
        l_msg_data := SQLERRM;
        UPDATE igs_ad_stat_int_all
        SET status = '3',
            error_code = 'E518'
        WHERE interface_id = stat_rec.interface_id
          AND interface_stat_id = stat_rec.interface_stat_id;

    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

        IF (l_request_id IS NULL) THEN
          l_request_id := fnd_global.conc_request_id;
        END IF;

         l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.exception '||'E518';

         fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
         fnd_message.set_token('INTERFACE_ID',stat_rec.interface_stat_id);
         fnd_message.set_token('ERROR_CD','E518');

         l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

         fnd_log.string_with_context( fnd_log.level_exception,
                      l_label,
                      l_debug_str, NULL,
                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

    IF l_enable_log = 'Y' THEN
       igs_ad_imp_001.logerrormessage(stat_rec.interface_stat_id,'E518','IGS_AD_STAT_INT_ALL');
    END IF;
    END;

    ELSIF l_rule = 'R' THEN
      IF stat_rec.match_ind = '21' THEN

      BEGIN

	  Validate_Person_Statistics(p_per_stat => stat_rec, p_success => l_success, p_error_code =>l_error_code);

          IF l_success = 'Y' THEN  -- null handling
  --Validation check of Descriptive Flexfield
  -- Added as a part of bug number 2203778
             l_success := NULL;
             Validate_desc_flex(stat_rec ,l_success );

             IF l_success = 'Y' THEN   -- for dff

               IGS_PE_STAT_PKG.Update_Row(
                    X_ACTION => 'UPDATE',
                    x_rowid => chk_dup_rec.row_id,
                    x_person_id => stat_rec.pid,   --stat_rec.person_id,
                    x_ethnic_origin_id => NVL(stat_rec.ethnic_origin,chk_dup_rec.ethnic_origin_id), -- BUG ID : 2138382
                    x_marital_status => NVL(stat_rec.marital_status,chk_dup_rec.marital_status),
                    x_marital_stat_effect_dt => NVL(stat_rec.marital_status_effective_date,chk_dup_rec.marital_status_effective_date),
                    x_ann_family_income => chk_dup_rec.ann_family_income,
                    x_number_in_family => chk_dup_rec.number_in_family,
                    x_content_source_type => 'USER_ENTERED',
                    x_internal_flag => chk_dup_rec.internal_flag,
                    x_person_number => chk_dup_rec.person_number,
                    x_effective_start_date => TRUNC(chk_dup_rec.effective_start_date),
                    x_effective_end_date => TRUNC(chk_dup_rec.effective_end_date),
                    x_ethnic_origin => NULL,
                    x_religion => NVL(stat_rec.religion_cd,chk_dup_rec.religion),
                    x_next_to_kin => chk_dup_rec.next_to_kin,
                    x_next_to_kin_meaning => NULL,
                    x_place_of_birth => NVL(stat_rec.place_of_birth,chk_dup_rec.place_of_birth),
                    x_socio_eco_status => chk_dup_rec.socio_eco_status,
                    x_socio_eco_status_desc => NULL,
                    x_further_education => chk_dup_rec.further_education,
                    x_further_education_desc => NULL,
                    x_in_state_tuition => chk_dup_rec.in_state_tuition,
                    x_tuition_st_date => TRUNC(chk_dup_rec.tuition_st_date),
                    x_tuition_end_date => TRUNC(chk_dup_rec.tuition_end_date),
                    x_person_initials => chk_dup_rec.person_initials,
                    x_primary_contact_id => chk_dup_rec.primary_contact_id,
                    x_personal_income => chk_dup_rec.personal_income,
                    x_head_of_household_flag => chk_dup_rec.head_of_household_flag,
                    x_content_source_number => chk_dup_rec.content_source_number,
                    x_hz_parties_ovn => chk_dup_rec.object_version_number,
                     x_attribute_category =>  NVL(stat_rec.attribute_category,chk_dup_rec.attribute_category),
                    x_attribute1          =>  NVL(stat_rec.attribute1,chk_dup_rec.attribute1),
                    x_attribute2          =>  NVL(stat_rec.attribute2,chk_dup_rec.attribute2),
                    x_attribute3          =>  NVL(stat_rec.attribute3,chk_dup_rec.attribute3),
                    x_attribute4          =>  NVL(stat_rec.attribute4,chk_dup_rec.attribute4),
                    x_attribute5          =>  NVL(stat_rec.attribute5,chk_dup_rec.attribute5),
                    x_attribute6          =>  NVL(stat_rec.attribute6,chk_dup_rec.attribute6),
                    x_attribute7          =>  NVL(stat_rec.attribute7,chk_dup_rec.attribute7),
                    x_attribute8          =>  NVL(stat_rec.attribute8,chk_dup_rec.attribute8),
                    x_attribute9          =>  NVL(stat_rec.attribute9,chk_dup_rec.attribute9),
                    x_attribute10         =>  NVL(stat_rec.attribute10,chk_dup_rec.attribute10),
                    x_attribute11         =>  NVL(stat_rec.attribute11,chk_dup_rec.attribute11),
                    x_attribute12         =>  NVL(stat_rec.attribute12,chk_dup_rec.attribute12),
                    x_attribute13         =>  NVL(stat_rec.attribute13,chk_dup_rec.attribute13),
                    x_attribute14         =>  NVL(stat_rec.attribute14,chk_dup_rec.attribute14),
                    x_attribute15         =>  NVL(stat_rec.attribute15,chk_dup_rec.attribute15),
                    x_attribute16         =>  NVL(stat_rec.attribute16,chk_dup_rec.attribute16),
                    x_attribute17         =>  NVL(stat_rec.attribute17,chk_dup_rec.attribute17),
                    x_attribute18         =>  NVL(stat_rec.attribute18,chk_dup_rec.attribute18),
                    x_attribute19         =>  NVL(stat_rec.attribute19,chk_dup_rec.attribute19),
                    x_attribute20         =>  NVL(stat_rec.attribute20,chk_dup_rec.attribute20),
                    x_global_attribute_category => chk_dup_rec.global_attribute_category,
                    x_global_attribute1 => chk_dup_rec.global_attribute1,
                    x_global_attribute2=> chk_dup_rec.global_attribute1,
                    x_global_attribute3=> chk_dup_rec.global_attribute1,
                    x_global_attribute4=> chk_dup_rec.global_attribute1,
                    x_global_attribute5=> chk_dup_rec.global_attribute1,
                    x_global_attribute6=> chk_dup_rec.global_attribute1,
                    x_global_attribute7=> chk_dup_rec.global_attribute1,
                    x_global_attribute8=> chk_dup_rec.global_attribute1,
                    x_global_attribute9=> chk_dup_rec.global_attribute1,
                    x_global_attribute10=> chk_dup_rec.global_attribute1,
                    x_global_attribute11=> chk_dup_rec.global_attribute1,
                    x_global_attribute12=> chk_dup_rec.global_attribute1,
                    x_global_attribute13=> chk_dup_rec.global_attribute1,
                    x_global_attribute14=> chk_dup_rec.global_attribute1,
                    x_global_attribute15=> chk_dup_rec.global_attribute1,
                    x_global_attribute16=> chk_dup_rec.global_attribute1,
                    x_global_attribute17=> chk_dup_rec.global_attribute1,
                    x_global_attribute18=> chk_dup_rec.global_attribute1,
                    x_global_attribute19=> chk_dup_rec.global_attribute1,
                    x_global_attribute20=> chk_dup_rec.global_attribute1,
                    x_party_last_update_date=> l_party_last_update_date,
                    x_person_profile_id => chk_dup_rec.person_profile_id,
                    x_matr_cal_type => chk_dup_rec.matr_cal_type,
                    x_matr_sequence_number => chk_dup_rec.matr_sequence_number,
                    x_init_cal_type => chk_dup_rec.init_cal_type,
                    x_init_sequence_number => chk_dup_rec.init_sequence_number,
                    x_recent_cal_type => chk_dup_rec.recent_cal_type,
                    x_recent_sequence_number => chk_dup_rec.recent_sequence_number,
                    x_catalog_cal_type => chk_dup_rec.catalog_cal_type,
                    x_catalog_sequence_number => chk_dup_rec.catalog_sequence_number,
                    z_return_status => l_return_status,
                    z_msg_count => l_msg_count,
                    z_msg_data => l_msg_data,
		    x_birth_cntry_resn_code  => NULL   --- prbhardw
		    );


             IF l_return_status IN('E','U') THEN
                UPDATE igs_ad_stat_int_all
                SET status = '3',
                    error_code = 'E014'
                WHERE interface_id = stat_rec.interface_id
                  AND interface_stat_id = stat_rec.interface_stat_id;

        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

             l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.exception1';

             fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
             fnd_message.set_token('INTERFACE_ID',stat_rec.interface_stat_id);
             fnd_message.set_token('ERROR_CD','E014');

             l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

             fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;

            IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(stat_rec.interface_stat_id,'E014','IGS_AD_STAT_INT_ALL');
            END IF;


        ELSE
            UPDATE  igs_ad_stat_int_all
            SET     status = '1', ERROR_CODE = NULL, match_ind = '18'
            WHERE
                interface_id = stat_rec.interface_id
                AND interface_stat_id = stat_rec.interface_stat_id;
           END IF;
          END IF;  -- for dff

              ELSE  -- else l_success = 'N'
                  UPDATE
                    igs_ad_stat_int_all
                SET

                    status = '3',
                    error_code = p_error_code
                WHERE
                    interface_id = stat_rec.interface_id
                    AND interface_stat_id = stat_rec.interface_stat_id;


        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

             l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.exception2';

             fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
             fnd_message.set_token('INTERFACE_ID',stat_rec.interface_stat_id);
             fnd_message.set_token('ERROR_CD',p_error_code);

             l_debug_str :=  fnd_message.get || ' ' ||  l_msg_data;

             fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;

            IF l_enable_log = 'Y' THEN
               igs_ad_imp_001.logerrormessage(stat_rec.interface_stat_id,p_error_code,'IGS_AD_STAT_INT_ALL');
            END IF;


             END IF; -- null handling

            EXCEPTION WHEN OTHERS THEN
                UPDATE igs_ad_stat_int_all
                SET

                    status = '3',
                    error_code = 'E014'
                WHERE
                    interface_id = stat_rec.interface_id
                    AND interface_stat_id = stat_rec.interface_stat_id;

                IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                    IF (l_request_id IS NULL) THEN
                      l_request_id := fnd_global.conc_request_id;
                    END IF;

                     l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.exception3';

                     fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                     fnd_message.set_token('INTERFACE_ID',stat_rec.interface_stat_id);
                     fnd_message.set_token('ERROR_CD','E014');

                     l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

                     fnd_log.string_with_context( fnd_log.level_exception,
                                  l_label,
                                  l_debug_str, NULL,
                                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                END IF;

                IF l_enable_log = 'Y' THEN
                   igs_ad_imp_001.logerrormessage(stat_rec.interface_stat_id,'E014','IGS_AD_STAT_INT_ALL');
                END IF;

            END;
           END IF;--end if for match_ind = '21'
          END IF;-- end if for l_rule = 'e'
        ELSE
          Crt_Pe_Stat(stat_rec =>stat_rec,  p_status =>l_status,  p_error_code=>l_error_code );
          UPDATE igs_ad_stat_int_all
          SET status = l_status,error_code = l_error_code
          WHERE interface_id = stat_rec.interface_id
            AND interface_stat_id = stat_rec.interface_stat_id;
        END IF;
    CLOSE chk_dup_cur;
    EXCEPTION
      WHEN OTHERS THEN
      IF chk_dup_cur%ISOPEN THEN
        CLOSE chk_dup_cur;
      END IF;
          UPDATE igs_ad_stat_int_all
          SET status = '3',error_code = 'E518'
          WHERE interface_id = stat_rec.interface_id
                AND interface_stat_id = stat_rec.interface_stat_id;


      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

        IF (l_request_id IS NULL) THEN
          l_request_id := fnd_global.conc_request_id;
        END IF;

         l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_main.exception '||'E518';

         fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
         fnd_message.set_token('INTERFACE_ID',stat_rec.interface_stat_id);
         fnd_message.set_token('ERROR_CD','E518');

         l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

         fnd_log.string_with_context( fnd_log.level_exception,
                      l_label,
                      l_debug_str, NULL,
                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
     END IF;

    IF l_enable_log = 'Y' THEN
       igs_ad_imp_001.logerrormessage(stat_rec.interface_stat_id,'E518','IGS_AD_STAT_INT_ALL');
    END IF;

        END;

  IF l_processed_records = 100 THEN
    COMMIT;
    l_processed_records := 0;
  END IF;
END LOOP;
END Prc_Pe_Stat_Main;

PROCEDURE Prc_Pe_Stat_Biodemo (
       p_source_type_id IN  NUMBER,
           p_batch_id IN NUMBER )
AS
/*
  ||  Created By : ssawhney
  ||  Purpose : Person Stats - Biodemo Import
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || npalanis         6-JAN-2003      Bug : 2734697
  ||                                  code added to commit after import of every
  ||                                  100 records .New variable l_processed_records added
*/

  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER;
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
CURSOR c_biodemo(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
  SELECT mi.*,i.person_id
  FROM   igs_pe_eit_int mi,
         igs_ad_interface_all i
  WHERE mi.information_type IN ('PE_STAT_RES_COUNTRY','PE_STAT_RES_STATE', 'PE_STAT_RES_STATUS')
     AND  mi.interface_run_id = cp_interface_run_id
      AND  mi.interface_id =  i.interface_id
      AND  i.interface_run_id = cp_interface_run_id
      AND  mi.status = '2';

 biodem_rec  c_biodemo%ROWTYPE;

CURSOR c_dup_cur (biodem_rec    c_biodemo%ROWTYPE) IS
  SELECT rowid, pe.*
  FROM igs_pe_eit pe
  WHERE  person_id = biodem_rec.person_id AND
         information_type = biodem_rec.information_type AND
         start_date = TRUNC(biodem_rec.start_date);

dup_cur_rec c_dup_cur%ROWTYPE;

l_rule igs_ad_source_cat.discrepancy_rule_cd%TYPE;
l_count number;
l_status  biodem_rec.status%TYPE;
l_error_code  biodem_rec.error_code%TYPE;
l_match_ind  biodem_rec.match_ind%TYPE;
l_processed_records NUMBER(5);

 -- local procedure

PROCEDURE crt_biodemo (
                biodem_rec  IN  c_biodemo%ROWTYPE,
            p_error_code    OUT NOCOPY  VARCHAR2,
            p_status    OUT NOCOPY  VARCHAR2 )
/*
  ||  Created By : ssawhney
  ||  Purpose : Person Stats - Local Insert Biodemo details proc
  ||  Known limitations, enhancements or remarks :
 */
AS
    l_count NUMBER(3);
    l_rowid VARCHAR2(25);
    l_pe_eit_id NUMBER;
    CURSOR date_overlap(cp_start_date IGS_PE_EIT.start_date%TYPE,
                        cp_end_date IGS_PE_EIT.end_date%TYPE,
                        cp_information_type IGS_PE_EIT.information_type%TYPE,
                        cp_person_id NUMBER) IS
    SELECT count(1) FROM IGS_PE_EIT
    WHERE person_id = cp_person_id
    AND INFORMATION_TYPE = cp_information_type
    AND (
          NVL(TRUNC(cp_end_date),IGS_GE_DATE.igsdate('4712/12/31')) BETWEEN START_DATE
          AND NVL(END_DATE,IGS_GE_DATE.igsdate('4712/12/31')) OR
          cp_start_date BETWEEN START_DATE AND NVL(END_DATE,IGS_GE_DATE.igsdate('4712/12/31')) OR
          (cp_start_Date < START_DATE AND
          NVL(end_date,IGS_GE_DATE.igsdate('4712/12/31'))< NVL(cp_end_date ,IGS_GE_DATE.igsdate('4712/12/31')) )
        );
BEGIN
    -- Call Log header
    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

      IF (l_request_id IS NULL) THEN
         l_request_id := fnd_global.conc_request_id;
      END IF;

      l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_biodemo.begin_crt_biodemo';
      l_debug_str :=  'Igs_Ad_Imp_008.prc_pe_stat_biodemo.crt_biodemo';

      fnd_log.string_with_context( fnd_log.level_procedure,
		                   l_label,
				   l_debug_str, NULL,
		                   NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;
    OPEN date_overlap(biodem_rec.start_date,biodem_rec.end_date, biodem_rec.information_type,biodem_rec.person_id);
    FETCH date_overlap INTO l_count;
    CLOSE date_overlap;
    IF l_count > 0 THEN
       p_error_code := 'E228';
       p_status :='3';

       IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(biodem_rec.interface_eit_id,'E228','IGS_PE_EIT_INT');
       END IF;
    ELSE
       Igs_Pe_Eit_Pkg.insert_row (
           x_rowid => l_rowid,
           x_pe_eit_id => l_pe_eit_id,
           x_person_id => biodem_rec.person_id,
           x_information_type  => biodem_rec.information_type,
           x_pei_information1  => biodem_rec.pei_information1,
           x_pei_information2  => biodem_rec.pei_information2,
           x_pei_information3  => biodem_rec.pei_information3,
           x_pei_information4  => biodem_rec.pei_information4,
           x_pei_information5  => biodem_rec.pei_information5,
           x_start_date  => biodem_rec.start_date,
           x_end_date  => biodem_rec.end_date,
           x_mode  =>  'R'
       );
       p_error_code:=NULL;
       p_status :='1';
    END IF;

   EXCEPTION
     WHEN OTHERS THEN
     p_status := '3';
     p_error_code := 'E161';
     -- Call Log detail

     IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_biodemo.exception '||'E161';

    fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
    fnd_message.set_token('INTERFACE_ID',biodem_rec.interface_id);
    fnd_message.set_token('ERROR_CD','E161');

    l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

    fnd_log.string_with_context( fnd_log.level_exception,
                      l_label,
                      l_debug_str, NULL,
                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
     END IF;

     IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(biodem_rec.interface_eit_id,'E161','IGS_PE_EIT_INT');
     END IF;


   END crt_biodemo;  -- END OF LOCAL PROCEDURE crt_biodemo


   -- Start Local Procedure Validate_Record for validation of the record values

   FUNCTION Validate_Record(p_biodemo_rec  IN   c_biodemo%ROWTYPE) RETURN BOOLEAN
   /*
  ||  Created By : ssawhney
  ||  Purpose : Person Stats - Local validate function
  ||  Known limitations, enhancements or remarks :
  ||  WHO	      WHEN            WHAT
  ||  skpandey        09-Jan-2006     Bug#4178224
  ||                                  Changed the definition of region_cd_cur cursor as a part of New Geography Model
 */
   IS
   l_var    VARCHAR2(1);

   -- validate the territory if passed
   CURSOR c_country(cp_territory_code VARCHAR2) IS
   SELECT  'X' var
   FROM fnd_territories_vl
   WHERE territory_code = NVL(cp_territory_code,'0');

   country_rec c_country%ROWTYPE;

   -- validate state if passed
   CURSOR c_state(cp_geography_type hz_geographies.geography_type%TYPE, cp_geography_cd hz_geographies.geography_code%TYPE, cp_country_cd hz_geographies.country_code%TYPE) IS
	SELECT 'X'
	   FROM hz_geographies
	   WHERE GEOGRAPHY_TYPE = cp_geography_type
	   AND geography_code = NVL(cp_geography_cd, '0')
	   AND COUNTRY_CODE = cp_country_cd;

   state_rec c_state%ROWTYPE;


   -- Validate date of birth
   CURSOR birth_date_cur(cp_person_id NUMBER) IS
   SELECT birth_date
   FROM   igs_pe_person_base_v
   WHERE  person_id = cp_person_id;

   l_birth_date igs_pe_person_base_v.birth_date%TYPE;
   l_error VARCHAR2(30);
   BEGIN
    -- Call Log header

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
       l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_biodemo.begin_validate_record';
    l_debug_str :=  'Igs_Ad_Imp_008.prc_pe_stat_biodemo.Validate_Record';

    fnd_log.string_with_context( fnd_log.level_procedure,
                    l_label,
                    l_debug_str, NULL,
                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

        -- test for input data if its NOT NULL
    OPEN birth_date_cur(p_biodemo_rec.person_id);
        FETCH birth_date_cur INTO l_birth_date;
        CLOSE birth_date_cur;

        IF l_birth_date IS NOT NULL THEN
          IF p_biodemo_rec.start_date < l_birth_date THEN
          l_error := 'E222';
          RAISE NO_DATA_FOUND;
          END IF;
        END IF;

    IF p_biodemo_rec.pei_information1 IS NOT NULL THEN

    -- validate for country
    IF p_biodemo_rec.information_type = 'PE_STAT_RES_COUNTRY' THEN
      OPEN c_country(p_biodemo_rec.pei_information1);
           FETCH c_country INTO country_rec;
           IF c_country%NOTFOUND THEN
             l_error := 'E105';
             RAISE no_data_found;
       ELSE
         CLOSE c_country;
         l_error := NULL;
       END IF;

    -- validate for state
    ELSIF p_biodemo_rec.information_type = 'PE_STAT_RES_STATE' THEN
       OPEN c_state('STATE',p_biodemo_rec.pei_information1, FND_PROFILE.VALUE('OSS_COUNTRY_CODE'));
           FETCH c_state INTO state_rec;
       -- CLOSE c_state;
           IF c_state%NOTFOUND THEN
         l_error := 'E106';
             RAISE no_data_found;
       ELSE
         CLOSE c_state;
         l_error := NULL;
       END IF;

        -- validate for citizenship status
    ELSIF p_biodemo_rec.information_type = 'PE_STAT_RES_STATUS' THEN
   -- validate code if passed
    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('PE_CITI_STATUS',NVL(p_biodemo_rec.pei_information1,'0'),8405))
    THEN
      l_error := 'E107';
      RAISE no_data_found;
    ELSE
      l_error := NULL;
    END IF;
    END IF ;

    END IF; -- pei_information1 IS NOT NULL

    -- validate start and end dates
    IF p_biodemo_rec.start_date > NVL(p_biodemo_rec.end_date, IGS_GE_DATE.IGSDATE('4712/12/31')) THEN
      l_error := 'E108';
      RAISE no_data_found;
    END IF;

        -- if all validations pass then update the INTERFACE Table
    RETURN TRUE;

  EXCEPTION
   -- search for NO_DATA_FOUND, as its not trapped, OTHERS will be raised

  WHEN  OTHERS THEN

          IF c_state%ISOPEN THEN
                CLOSE c_state;
          END IF;
          IF c_country%ISOPEN THEN
                CLOSE c_country;
          END IF;
          -- update for failure

      UPDATE igs_pe_eit_int
      SET    status = '3',
         error_code = l_error
      WHERE  interface_eit_id = p_biodemo_rec.interface_eit_id;

     IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_biodemo.validate_record';

    fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
    fnd_message.set_token('INTERFACE_ID',p_biodemo_rec.interface_eit_id);
    fnd_message.set_token('ERROR_CD',l_error);

    l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

    fnd_log.string_with_context( fnd_log.level_exception,
                      l_label,
                      l_debug_str, NULL,
                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
     END IF;

     IF l_enable_log = 'Y' THEN
         igs_ad_imp_001.logerrormessage(p_biodemo_rec.interface_eit_id,l_error,'IGS_PE_EIT_INT');
     END IF;

     RETURN FALSE ;

   END validate_record;  -- End Local function Validate_Record


BEGIN -- Start the Prc_Pe_Stat_Biodemo Now.

  l_prog_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_biodemo';
  l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_biodemo.';
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
   -- Call Log header
   l_processed_records := 0;
   l_count := 0;

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
       l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_biodemo.begin';
    l_debug_str :=  'Igs_Ad_Imp_008.Prc_Pe_Stat_Biodemo';

    fnd_log.string_with_context( fnd_log.level_procedure,
                    l_label,
                    l_debug_str, NULL,
                    NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;

  l_rule :=IGS_AD_IMP_001.Find_Source_Cat_Rule(p_source_type_id, 'PERSON_STATISTICS');
   --
  --1 If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_pe_eit_int
    SET status = '3',
        ERROR_CODE = 'E695'  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND status = '2'
      AND interface_run_id = l_interface_run_id;
  END IF;

  --2 If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_pe_eit_int mi
    SET status = '1',
        match_ind = '19'
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.status = '2'
      AND EXISTS ( SELECT '1'
                   FROM   igs_pe_eit pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.person_id
                     AND  UPPER(mi.information_type) = UPPER(pe.information_type)
             AND  TRUNC(pe.start_date) = TRUNC(mi.start_date));
  END IF;

  --3 If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_pe_eit_int
    SET status = '1'
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN ('18','19','22','23')
      AND status = '2';
  END IF;

  --4 If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_pe_eit_int
    SET status = '3',
        ERROR_CODE = 'E695'
    WHERE interface_run_id = l_interface_run_id
      AND status = '2'
      AND (match_ind IS NOT NULL AND match_ind NOT IN ('21','25'));
  END IF;

  --5 If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_pe_eit_int mi
    SET status = '1',
        match_ind = '23'
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS ( SELECT '1'
                   FROM igs_pe_eit pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.person_id
                     AND  UPPER(mi.information_type) = UPPER(pe.information_type)
             AND  TRUNC(pe.start_date) = TRUNC(mi.start_date)
             AND NVL(UPPER(pe.pei_information1),'1') = NVL(UPPER(mi.pei_information1),'1')
            AND NVL(UPPER(pe.pei_information2),'2') = NVL(UPPER(mi.pei_information2),'2')
            AND NVL(UPPER(pe.pei_information3),'3') = NVL(UPPER(mi.pei_information3),'3')
            AND NVL(UPPER(pe.pei_information4),'4') = NVL(UPPER(mi.pei_information4),'4')
            AND NVL(UPPER(pe.pei_information5),'5') = NVL(UPPER(mi.pei_information5),'5')
            AND NVL(TRUNC(pe.end_date),IGS_GE_DATE.IGSDATE('4712/12/01'))=
                NVL(TRUNC(mi.end_date),IGS_GE_DATE.IGSDATE('4712/12/01'))
             );
  END IF;

  --6 If rule is R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_pe_eit_int mi
    SET status = '3',
        match_ind = '20',
    DUP_PE_EIT_ID   =   (SELECT pe.pe_eit_id
                           FROM igs_pe_eit pe, igs_ad_interface_all ii
                   WHERE mi.interface_run_id = l_interface_run_id
                         AND  ii.interface_id = mi.interface_id
                     AND  ii.person_id = pe.person_id
                             AND  UPPER(mi.information_type) = UPPER(pe.information_type)
                     AND  TRUNC(pe.start_date) = TRUNC(mi.start_date))
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS (SELECT '1'
                  FROM igs_pe_eit pe, igs_ad_interface_all ii
          WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.person_id
                     AND  UPPER(mi.information_type) = UPPER(pe.information_type)
             AND  TRUNC(pe.start_date) = TRUNC(mi.start_date));
  END IF;

  FOR biodem_rec IN c_biodemo(l_interface_run_id) LOOP  -- LOOP Started
    l_processed_records := l_processed_records + 1;
  BEGIN
     --
     -- Set the status, match_ind, error_code of the interface record
     --
    l_status := biodem_rec.status;
    l_error_code := biodem_rec.error_code;
    l_match_ind := biodem_rec.match_ind;
    biodem_rec.start_date := TRUNC(biodem_rec.start_date);
    biodem_rec.end_date := TRUNC(biodem_rec.end_date);
    -- validate the current record
    IF validate_record( p_biodemo_rec => biodem_rec )  THEN   -- 1 IF
       --  check  for duplicates
           dup_cur_rec.pe_eit_id := NULL; -- initialise
      OPEN c_dup_cur ( biodem_rec);
      FETCH c_dup_cur INTO dup_cur_rec;
      CLOSE c_dup_cur;

      IF dup_cur_rec.pe_eit_id IS NOT NULL THEN  -- duplicate found.      -- 2 IF
        -- follow the path of insert/updates depending on the RETURN value of the RULE.
        IF l_rule = 'I' THEN
          DECLARE
       CURSOR date_overlap(cp_start_date IGS_PE_EIT.start_date%TYPE,
                       cp_end_date IGS_PE_EIT.end_date%TYPE,
               cp_information_type IGS_PE_EIT.information_type%TYPE,
               cp_person_id NUMBER) IS
       SELECT COUNT(1) FROM IGS_PE_EIT
        WHERE person_id = cp_person_id
        AND INFORMATION_TYPE = cp_information_type
        AND start_date <> cp_start_date
        AND (NVL(cp_end_date,IGS_GE_DATE.igsdate('4712/12/31')) BETWEEN START_DATE AND NVL(END_DATE,IGS_GE_DATE.igsdate('4712/12/31'))
         OR
         cp_start_date BETWEEN START_DATE AND NVL(END_DATE,IGS_GE_DATE.igsdate('4712/12/31'))
         OR
         ( cp_start_date < START_DATE AND
          NVL(end_date,IGS_GE_DATE.igsdate('4712/12/31'))< NVL(cp_end_date,IGS_GE_DATE.igsdate('4712/12/31')) ) );

      l_count  NUMBER(3);
        BEGIN
    OPEN date_overlap(biodem_rec.start_date,biodem_rec.end_date,
                      biodem_rec.information_type,biodem_rec.person_id);
    FETCH date_overlap INTO l_count;
    CLOSE date_overlap;

    IF l_count > 0 THEN

            UPDATE igs_pe_eit_int
            SET     status = '3',
                error_code = 'E228'
            WHERE  interface_eit_id = biodem_rec.interface_eit_id;

             IF l_enable_log = 'Y' THEN
                 igs_ad_imp_001.logerrormessage(biodem_rec.interface_eit_id,'E228','IGS_PE_EIT_INT');
             END IF;

    ELSE
          -- open the Null handling cursor
            igs_pe_eit_pkg.update_row (
              x_rowid => dup_cur_rec.rowid,
              x_pe_eit_id => dup_cur_rec.pe_eit_id,
              x_person_id => dup_cur_rec.person_id,
              x_information_type  => dup_cur_rec.information_type,
              x_pei_information1  => NVL(biodem_rec.pei_information1,dup_cur_rec.pei_information1),
              x_pei_information2  => NVL(biodem_rec.pei_information2,dup_cur_rec.pei_information2),
              x_pei_information3  => NVL(biodem_rec.pei_information3,dup_cur_rec.pei_information3),
              x_pei_information4  => NVL(biodem_rec.pei_information4,dup_cur_rec.pei_information4),
              x_pei_information5  => NVL(biodem_rec.pei_information5,dup_cur_rec.pei_information5),
              x_start_date  => dup_cur_rec.start_date,
              x_end_date  => NVL(biodem_rec.end_date,dup_cur_rec.end_date),
              x_mode  =>  'R'
              );

            UPDATE igs_pe_eit_int
            SET     status = '1',
                match_ind = '18'
            WHERE  interface_eit_id = biodem_rec.interface_eit_id;
        END IF;

          EXCEPTION
        WHEN OTHERS THEN
          UPDATE igs_pe_eit_int
          SET   status = '3',
            error_code = 'E090'
          WHERE  interface_eit_id = biodem_rec.interface_eit_id;

                    -- Call Log detail

             IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
                l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_biodemo.exception '||'E090';

            fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
            fnd_message.set_token('INTERFACE_ID',biodem_rec.interface_eit_id);
            fnd_message.set_token('ERROR_CD','E090');

            l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                              l_label,
                              l_debug_str, NULL,
                              NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
             END IF;

             IF l_enable_log = 'Y' THEN
                 igs_ad_imp_001.logerrormessage(biodem_rec.interface_eit_id,'E090','IGS_PE_EIT_INT');
             END IF;

                END;

          ELSIF l_rule ='R' THEN

          IF l_match_ind =21 THEN
          DECLARE
       CURSOR date_overlap(cp_start_date IGS_PE_EIT.start_date%TYPE,
                       cp_end_date IGS_PE_EIT.end_date%TYPE,
               cp_information_type IGS_PE_EIT.information_type%TYPE,
               cp_person_id NUMBER) IS
       SELECT count(1) FROM IGS_PE_EIT
        WHERE person_id = cp_person_id
        AND INFORMATION_TYPE = cp_information_type
        AND start_date <> cp_start_date
        AND (NVL(cp_end_date,IGS_GE_DATE.igsdate('4712/12/31')) BETWEEN START_DATE AND NVL(END_DATE,IGS_GE_DATE.igsdate('4712/12/31'))
         OR
         cp_start_date BETWEEN START_DATE AND NVL(END_DATE,IGS_GE_DATE.igsdate('4712/12/31'))
         OR
         ( cp_start_date < START_DATE AND
          NVL(end_date,IGS_GE_DATE.igsdate('4712/12/31'))< NVL(cp_end_date,IGS_GE_DATE.igsdate('4712/12/31')) ) );
        l_count  NUMBER(3);
          BEGIN
      OPEN date_overlap(biodem_rec.start_date,biodem_rec.end_date,
                        biodem_rec.information_type,biodem_rec.person_id);
      FETCH date_overlap INTO l_count;
      CLOSE date_overlap;

      IF l_count > 0 THEN

        UPDATE igs_pe_eit_int
        SET     status = '3',
            error_code = 'E228'
        WHERE  interface_eit_id = biodem_rec.interface_eit_id;

         IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(biodem_rec.interface_eit_id,'E228','IGS_PE_EIT_INT');
        END IF;

      ELSE
            igs_pe_eit_pkg.update_row (
                                x_rowid => dup_cur_rec.rowid,
                                x_pe_eit_id => dup_cur_rec.pe_eit_id,
                                x_person_id => dup_cur_rec.person_id,
                                x_information_type  => dup_cur_rec.information_type,
                                x_pei_information1  => NVL(biodem_rec.pei_information1,dup_cur_rec.pei_information1),
                                x_pei_information2  => NVL(biodem_rec.pei_information2,dup_cur_rec.pei_information2),
                                x_pei_information3  => NVL(biodem_rec.pei_information3,dup_cur_rec.pei_information3),
                                x_pei_information4  => NVL(biodem_rec.pei_information4,dup_cur_rec.pei_information4),
                                x_pei_information5  => NVL(biodem_rec.pei_information5,dup_cur_rec.pei_information5),
                                x_start_date  => dup_cur_rec.start_date,
                                x_end_date  => NVL(biodem_rec.end_date,dup_cur_rec.end_date),
                                x_mode  =>  'R'
                                );

                               UPDATE igs_pe_eit_int
                               SET    status = '1', error_code = NULL,match_ind = '18'
                               WHERE  interface_eit_id = biodem_rec.interface_eit_id;
          END IF;
                        EXCEPTION
                           WHEN OTHERS THEN
                             UPDATE igs_pe_eit_int
                             SET    status = '3',
                                    error_code = 'E089'
                             WHERE  interface_eit_id = biodem_rec.interface_eit_id;

                    -- Call Log detail

             IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
                l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat_biodemo.exception '||'E089';

            fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
            fnd_message.set_token('INTERFACE_ID',biodem_rec.interface_eit_id);
            fnd_message.set_token('ERROR_CD','E089');

            l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                              l_label,
                              l_debug_str, NULL,
                              NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
             END IF;

             IF l_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(biodem_rec.interface_eit_id,'E089','IGS_PE_EIT_INT');
             END IF;

                        END;

          END IF;  -- end if of match ind check
        END IF ; -- end if or l_rule

        ELSE  -- this is the else of Count > 0 ie 2 IF

        -- since there are no dup records, insert the current rec in OSS and update the
        -- interface table with the status.

          crt_biodemo (biodem_rec   =>  biodem_rec,
               p_error_code => l_error_code,
               p_status     => l_status );

          UPDATE    igs_pe_eit_int
          SET   status = l_status,
            error_code = l_error_code
          WHERE     interface_eit_id = biodem_rec.interface_eit_id;

          -- Call Log detail

          IF l_status <> '1' THEN
            IF l_enable_log = 'Y' THEN
              igs_ad_imp_001.logerrormessage(biodem_rec.interface_eit_id,l_error_code,'IGS_PE_EIT_INT');
            END IF;
          END IF;
        END IF; -- for 2 IF
        -- ELSE  already taken care in the Validate Record function for update of interface table
    END IF; -- for 1 IF
   END ;

   IF l_processed_records = 100 THEN
      COMMIT;
      l_processed_records := 0;
   END IF;

   END LOOP;
   --
   -- End of Cursor Loop
   --

END Prc_Pe_Stat_Biodemo;




-- Import Statistic Details
-- Person Interface DLD, 2103692 -- ssawhney

PROCEDURE Prc_Pe_Stat (
       p_source_type_id IN  NUMBER,
           p_batch_id IN NUMBER )
AS
/*
  ||  Created By : ssawhney
  ||  Purpose : Person Stats Import
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel         6-FEB-2003      bug No: 2758854
  ||                                  Added the call igs_ad_imp_025.prc_pe_race for processing Multiple Races
*/

  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER;
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
BEGIN

  l_prog_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat';
  l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat.';
  l_enable_log := igs_ad_imp_001.g_enable_log;

     Prc_Pe_Stat_Main (p_source_type_id, p_batch_id);
     Prc_Pe_Stat_Biodemo (p_source_type_id, p_batch_id);
     igs_ad_imp_025.prc_pe_race (p_source_type_id, p_batch_id);

EXCEPTION
     WHEN OTHERS THEN
     IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_008.prc_pe_stat.exception1';
    l_debug_str :=  SQLERRM || ' ';

    fnd_log.string_with_context( fnd_log.level_exception,
                      l_label,
                      l_debug_str, NULL,
                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
     END IF;
END Prc_Pe_Stat;



END Igs_Ad_Imp_008;

/
