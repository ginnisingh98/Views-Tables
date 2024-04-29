--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_026
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_026" AS
/* $Header: IGSPE13B.pls 120.4 2006/04/27 07:42:37 prbhardw ship $ */

/*
 ||  Created By : gmuralid
 ||  Date       : 2-DEC-2002
 ||  Build      : SEVIS
 ||  Bug No     : 2599109

 ||  Change History :
 ||  Who             When            What
 || npalanis         6-JAN-2003      Bug : 2734697
 ||                                  code added to commit after import of every
 ||                                  100 records .New variable l_processed_records added
 || pkpatel          24-FEB-2003     Bug : 2783882
 ||                                  Modified the code for implementing the overlap chack from TBH fpr visa and visit histry
 ||
 ||kumma             03-MAY-2003     2941138, Modified dynamic query variable l_select_clause inside function validate_record for sqlbind bug of PKM_ISSUE
 || ssaleem          7-OCT-2003      Bug : 3130316
 ||                                  Validations done for individual records inside the main loop are removed
 ||                                  Instead they are done for of bulk records before the start of main loop
 ||                                  Logging is modified to include logging mechanism
 || ssaleem          25 Aug 2004     Moving the validate_record function in visa, passport and visit histry outside to the package level
 ||                                  Added new procedures validate_visa_pub,validate_passport_pub and visit histry pub that will be called by the Visa, Passport and Visit Histry Public APIs.
 ||                                  Changes as part of Bug # 3847525
 || vredkar	     14-Oct-2005     Bug#4654248,replaced generic duplicate/overlap
 ||			             exists messages with component specific messages
 || skpandey         3_FEB-2006      Bug: 4937960
 ||                                  Description: Change call from GET_WHERE_CLAUSE to GET_WHERE_CLAUSE_API as a part of Literal fix
*/


CURSOR visa_dtls(cp_interface_run_id igs_pe_visa_int.interface_run_id%TYPE) IS
SELECT vi.*, i.person_id
 FROM igs_pe_visa_int vi,
      igs_ad_interface_all i
 WHERE vi.interface_id = i.interface_id
       AND  vi.STATUS = '2'
       AND  vi.interface_run_id = cp_interface_run_id
       AND  i.interface_run_id = cp_interface_run_id;


CURSOR visit_dtls(cp_vh_status_2 igs_pe_vst_hist_int.status%TYPE,
                  cp_vi_status_1 igs_pe_visa_int.status%TYPE,
          cp_interface_run_id igs_pe_vst_hist_int.interface_run_id%TYPE) IS
SELECT vh.*, i.person_id,pev.visa_id,pev.visa_issue_date issue_date,pev.visa_expiry_date expiry_date
FROM  igs_pe_vst_hist_int vh,
      igs_ad_interface_all i,
      igs_pe_visa_int vi,
      igs_pe_visa pev
WHERE vh.interface_visa_id = vi.interface_visa_id
     AND vi.interface_id = i.interface_id
     AND pev.person_id = i.person_id
     AND  vh.STATUS = cp_vh_status_2
     AND  vi.status = cp_vi_status_1
     AND  vh.interface_run_id = cp_interface_run_id
     AND  pev.visa_type = UPPER(vi.visa_type)
     AND  pev.visa_issue_date = TRUNC(vi.visa_issue_date);

CURSOR pass_dtls(cp_interface_run_id igs_pe_passport_int.interface_run_id%TYPE) IS
SELECT pi.*, i.person_id
FROM igs_pe_passport_int pi,
     igs_ad_interface_all i
WHERE pi.interface_id = i.interface_id
     AND  pi.STATUS = '2'
     AND  pi.interface_run_id = cp_interface_run_id
     AND  i.interface_run_id = cp_interface_run_id;

FUNCTION validate_visa(visa_rec IN visa_dtls%ROWTYPE,
                           p_error_code OUT NOCOPY igs_pe_visa_int.error_code%TYPE,
			   p_mode IN VARCHAR2 DEFAULT NULL) RETURN BOOLEAN IS

      CURSOR birth_dt_cur(cp_person_id igs_ad_interface.person_id%TYPE) IS
      SELECT birth_date birth_dt
      FROM igs_pe_person_base_v
      WHERE person_id = cp_person_id;

     --kumma, 2941138, PKM_ISSUE, Used the bind variable instead of using the conact for preparing the statement
      l_select_clause VARCHAR2(2000):=
      ' SELECT ou1.org_unit_cd FROM igs_or_unit ou1,igs_or_status org_status WHERE org_status.s_org_status = ''ACTIVE''
      AND org_status.org_status = ou1.org_status AND ou1.org_unit_cd  = :agent_org_unit_cd';

      TYPE org_unit_ref_cur IS REF CURSOR;
      org_unit_cur  org_unit_ref_cur;
      l_org_unit_cd  igs_or_unit.org_unit_cd%TYPE;

      CURSOR party_id_cur IS
      SELECT person_id
      FROM igs_pe_person_base_v
      WHERE person_id = visa_rec.AGENT_PERSON_ID ;

      CURSOR valid_pas_id IS
      SELECT passport_number
      FROM igs_pe_passport p
      WHERE p.person_id = visa_rec.person_id AND
      p.passport_id =  visa_rec.passport_id;

      CURSOR visa_issue_match_cur(cp_lookup_type igs_lookup_values.lookup_type%TYPE,
                                  cp_enabled_flag igs_lookup_values.enabled_flag%TYPE,
                   cp_visa_issuing_post igs_lookup_values.lookup_code%TYPE,
                   cp_visa_issuing_country igs_lookup_values.tag%TYPE) IS
      SELECT 'X'
      FROM   igs_lookup_values
      WHERE  lookup_type = cp_lookup_type AND
             lookup_code = cp_visa_issuing_post AND
             tag         = cp_visa_issuing_country AND
             enabled_flag = cp_enabled_flag;

      pas_id_rec                  valid_pas_id%ROWTYPE;
      party_id_rec                party_id_cur%ROWTYPE;

      l_error VARCHAR2(30);
      l_birth_date IGS_AD_INTERFACE.BIRTH_DT%TYPE;
      l_cnt NUMBER;
      l_where_clause VARCHAR2(2000);
      l_exists  VARCHAR2(1);

      l_enable_log VARCHAR2(1);
      l_prog_label  VARCHAR2(100);

      l_request_id NUMBER;
      l_label  VARCHAR2(100);
      l_debug_str VARCHAR2(2000);
      l_func_name VARCHAR2(10) := 'IGSEN027';

BEGIN
   --VALIDATE VISA ISSUE POST
    l_error := NULL;

    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_prog_label := 'igs.plsql.igs_ad_imp_026.prc_pe_visa';

    IF visa_rec.visa_issuing_post IS NOT NULL THEN

     IF NOT igs_pe_pers_imp_001.validate_lookup_type_code('PE_US_VISA_ISSUE_LOC',visa_rec.visa_issuing_post,8405) THEN
       l_error := 'E190';
       RAISE NO_DATA_FOUND;
     END IF;
    END IF;

  -- VALIDATE VISA TYPE

    IF NOT igs_pe_pers_imp_001.validate_lookup_type_code('PER_US_VISA_TYPES',visa_rec.visa_type,3) THEN
      l_error := 'E191';
      RAISE no_data_found;
    END IF;

    IF visa_rec.visa_issue_date > visa_rec.visa_expiry_date THEN
       l_error := 'E194';
       RAISE no_data_found;
    END IF;

    OPEN birth_dt_cur(visa_rec.person_id);
    FETCH birth_dt_cur INTO l_birth_date;
    IF l_birth_date IS NOT NULL THEN
      IF (visa_rec.visa_issue_date < l_birth_date) THEN
        l_error := 'E195';
        RAISE no_data_found;
      END IF;
    END IF;
    CLOSE birth_dt_cur;

  IF visa_rec.passport_id IS NOT NULL THEN
    OPEN valid_pas_id;
    FETCH valid_pas_id INTO pas_id_rec;
    IF valid_pas_id%NOTFOUND THEN
      l_error := 'E196';
      RAISE no_data_found;
    END IF;
    CLOSE valid_pas_id;
  END IF;

  IF visa_rec.agent_org_unit_cd IS NOT NULL THEN
      IGS_OR_GEN_012_PKG.GET_WHERE_CLAUSE_API ('IGSEN027', l_where_clause);
      IF  l_where_clause IS NOT NULL THEN
           l_select_clause := l_select_clause||' AND '||l_where_clause;
  --skpandey, 3-FEB-2006, Bug: 4937960: Added logic and additional parameter in using CLAUSE as a part of Literal fix
	   OPEN org_unit_cur FOR l_select_clause USING visa_rec.agent_org_unit_cd, l_func_name;
      ELSE
           OPEN org_unit_cur FOR l_select_clause USING visa_rec.agent_org_unit_cd;
      END IF;

      FETCH org_unit_cur INTO l_org_unit_cd;
        IF org_unit_cur%NOTFOUND THEN
          l_error := 'E197';
          RAISE no_data_found;
        END IF;
        CLOSE org_unit_cur;
      END IF;

  IF visa_rec.agent_person_id IS NOT NULL THEN
    OPEN party_id_cur;
    FETCH party_id_cur INTO party_id_rec;
    IF party_id_cur%NOTFOUND THEN
      l_error := 'E198';
      RAISE no_data_found;
    END IF;
    CLOSE party_id_cur;
  END IF;

  IF visa_rec.visa_issuing_country IS NOT NULL THEN
    IF visa_rec.visa_issuing_country <> 'US' THEN
      IF NOT (igs_pe_pers_imp_001.validate_country_code(visa_rec.visa_issuing_country))   -- change for country code inconsistency bug 3738488
      THEN
        l_error := 'E554';
        RAISE  NO_DATA_FOUND;
      END IF;
    END IF;
  END IF;

  IF visa_rec.visa_issuing_country IS NOT NULL AND visa_rec.visa_issuing_post IS NOT NULL THEN
    OPEN visa_issue_match_cur('PE_US_VISA_ISSUE_LOC','Y',visa_rec.visa_issuing_post,visa_rec.visa_issuing_country);
    FETCH visa_issue_match_cur INTO l_exists;
    IF visa_issue_match_cur%NOTFOUND THEN
      l_error := 'E555';
      RAISE  NO_DATA_FOUND;
    END IF;
    CLOSE visa_issue_match_cur;
  END IF;

      IF NOT igs_ad_imp_018.validate_desc_flex(
           p_attribute_category => visa_rec.attribute_category,
           p_attribute1         => visa_rec.attribute1  ,
           p_attribute2         => visa_rec.attribute2  ,
           p_attribute3         => visa_rec.attribute3  ,
           p_attribute4         => visa_rec.attribute4  ,
           p_attribute5         => visa_rec.attribute5  ,
           p_attribute6         => visa_rec.attribute6  ,
           p_attribute7         => visa_rec.attribute7  ,
           p_attribute8         => visa_rec.attribute8  ,
           p_attribute9         => visa_rec.attribute9  ,
           p_attribute10        => visa_rec.attribute10 ,
           p_attribute11        => visa_rec.attribute11 ,
           p_attribute12        => visa_rec.attribute12 ,
           p_attribute13        => visa_rec.attribute13 ,
           p_attribute14        => visa_rec.attribute14 ,
           p_attribute15        => visa_rec.attribute15 ,
           p_attribute16        => visa_rec.attribute16 ,
           p_attribute17        => visa_rec.attribute17 ,
           p_attribute18        => visa_rec.attribute18 ,
           p_attribute19        => visa_rec.attribute19 ,
           p_attribute20        => visa_rec.attribute20 ,
           p_desc_flex_name     => 'IGS_PE_INTL_VISA_FLEX' ) THEN

             l_error:='E255';
             RAISE  NO_DATA_FOUND;
      END IF;


 -- IF VALIDATIONS SUCCESSFUL
  l_error := NULL;
  p_error_code := l_error;

  IF p_mode IS NULL THEN
    UPDATE igs_pe_visa_int
    SET status = '1',
        error_code = l_error
    WHERE interface_visa_id   = visa_rec.interface_visa_id;
  END IF;

  RETURN TRUE;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN


            IF visa_issue_match_cur%ISOPEN THEN
              CLOSE visa_issue_match_cur;
            END IF;

            IF birth_dt_cur%ISOPEN THEN
               CLOSE birth_dt_cur;
            END IF;

            IF org_unit_cur%ISOPEN THEN
               CLOSE org_unit_cur;
            END IF;

            IF party_id_cur%ISOPEN THEN
               CLOSE party_id_cur;
            END IF;

            IF valid_pas_id%ISOPEN THEN
               CLOSE valid_pas_id;
            END IF;

           p_error_code := l_error;

            IF l_error = 'E555' THEN
	        IF p_mode IS NULL THEN
                   UPDATE igs_pe_visa_int
                   SET status = '4',
                   error_code = l_error
                   WHERE interface_visa_id = visa_rec.interface_visa_id;

		   -- CALL LOG DETAIL
                   IF l_enable_log = 'Y' THEN
                      igs_ad_imp_001.logerrormessage(visa_rec.interface_visa_id,l_error,'IGS_PE_VISA_INT');
                   END IF;
                 END IF;
                 RETURN TRUE;
            ELSE
                 IF p_mode IS NULL THEN
                   UPDATE igs_pe_visa_int
                   SET status = '3',
                   error_code = l_error
                   WHERE interface_visa_id = visa_rec.interface_visa_id;

		   -- CALL LOG DETAIL
                   IF l_enable_log = 'Y' THEN
                      igs_ad_imp_001.logerrormessage(visa_rec.interface_visa_id,l_error,'IGS_PE_VISA_INT');
                   END IF;
                 END IF;
                 RETURN FALSE;
            END IF;

      WHEN OTHERS THEN
	IF p_mode IS NULL THEN
          UPDATE igs_pe_visa_int
          SET status = '3',
          error_code = l_error
          WHERE interface_visa_id = visa_rec.interface_visa_id;
        END IF;

	p_error_code := l_error;
	-- CALL LOG DETAIL

        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

          IF (l_request_id IS NULL) THEN
            l_request_id := fnd_global.conc_request_id;
          END IF;

          l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_visa.val_exception' || l_error;

          fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
          fnd_message.set_token('INTERFACE_ID',visa_rec.interface_visa_id);
          fnd_message.set_token('ERROR_CD',l_error);

          l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

          fnd_log.string_with_context( fnd_log.level_exception,
                                       l_label,
                                       l_debug_str, NULL,
                                       NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

          IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(visa_rec.interface_visa_id,l_error,'IGS_PE_VISA_INT');
          END IF;
      RETURN FALSE;
END Validate_Visa;


PROCEDURE prc_pe_visa(
          p_source_type_id  IN NUMBER,
          p_batch_id        IN NUMBER )

 AS
 /*
  ||  Created By : gmuralid - Visa Import Process
  ||  Date       : 2-DEC-2002
  ||  Build      : SEVIS
  ||  Bug No     : 2599109

  ||  Change History :
  ||  Who             When            What
  ||  npalanis        5-MAR-2003    Bug No :2791137
  ||                                Validation added to prevent association
  ||                                of expired passport to visa
  ||  npalanis        16-DEC-2002     Bug :2738327 removing the code l_visaid := visa_rec.interface_visa_id
  ||                                  from crt_pe_visa procedure
  ||                                  because the pk value should not be passed to tbh before calling the
  ||                                  insert row
  || pkpatel          24-FEB-2003     Bug : 2783882
  ||                                  Modified the code for implementing the overlap chack from TBH
  ||
  || ssaleem          7-OCT-2003      Bug : 3130316
  ||                                  Validations done for individual records inside the main loop are removed
  ||                                  Instead they are done for of bulk records before the start of main loop
  ||
  || ssaleem          25 Aug 2004     Moving the validate_record function in prc_pe_visa procedure outside the package level
  ||                                  Added a new procedure that will be called by the Visa Public API.
  ||                                  Changes as part of Bug # 3847525
 */

     CURSOR chk_duplicate(cp_person_id   igs_pe_visa.person_id%TYPE,
                          cp_visa_type   igs_pe_visa.visa_type%TYPE ,
                          cp_visa_issue_date igs_pe_visa.visa_issue_date%TYPE) IS
     SELECT rowid,vi.*
     FROM  IGS_PE_VISA vi
     WHERE   person_id = cp_person_id AND
             visa_type = cp_visa_type AND
             visa_issue_date = cp_visa_issue_date;  -- end_date IS NULL check removed

  l_var VARCHAR2(1);
  l_rule VARCHAR2(1);
  l_count NUMBER;
  lvcAction VARCHAR2(1);
  l_error_code VARCHAR2(10);
  l_status VARCHAR2(10);
  l_dup_var BOOLEAN;
  visa_rec                    visa_dtls%ROWTYPE;
  -- The below variable will get populated during duplicate check
  l_visa_rec chk_duplicate%ROWTYPE;
  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER;
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
  l_processed_records NUMBER(5) := 0;

  -- VALIDATE RECORD FUNCTION


  -- LOCAL PROCEDURE TO CREATE INTL VISA DTLS created by gmuralid
   PROCEDURE crt_pe_visa(visa_rec   IN visa_dtls%ROWTYPE)
    AS

    l_rowid ROWID := NULL;
    l_visaid IGS_PE_VISA.VISA_ID%TYPE;
    l_error VARCHAR2(30);
    l_message_name  VARCHAR2(30);
    l_app           VARCHAR2(50);

    BEGIN
        SAVEPOINT before_insert;

           IGS_PE_VISA_PKG.INSERT_ROW(
                X_ROWID                    =>  l_rowid,
                X_VISA_ID                  =>  l_visaid,
                X_PERSON_ID                =>  visa_rec.person_id,
                X_VISA_TYPE                =>  visa_rec.VISA_TYPE ,
                X_VISA_NUMBER              =>  visa_rec.VISA_NUMBER,
                X_VISA_ISSUE_DATE          =>  visa_rec.VISA_ISSUE_DATE ,
                X_VISA_EXPIRY_DATE         =>  visa_rec.VISA_EXPIRY_DATE,
                X_VISA_CATEGORY            =>  visa_rec.VISA_CATEGORY ,
                X_VISA_ISSUING_POST        =>  visa_rec.VISA_ISSUING_POST,
                X_PASSPORT_ID              =>  visa_rec.PASSPORT_ID,
                X_AGENT_ORG_UNIT_CD        =>  visa_rec.AGENT_ORG_UNIT_CD ,
                X_AGENT_PERSON_ID          =>  visa_rec.AGENT_PERSON_ID    ,
                X_AGENT_CONTACT_NAME       =>  visa_rec.AGENT_CONTACT_NAME ,
                X_ATTRIBUTE_CATEGORY       =>  visa_rec.ATTRIBUTE_CATEGORY ,
                X_ATTRIBUTE1               =>  visa_rec.ATTRIBUTE1         ,
                X_ATTRIBUTE2               =>  visa_rec.ATTRIBUTE2         ,
                X_ATTRIBUTE3               =>  visa_rec.ATTRIBUTE3         ,
                X_ATTRIBUTE4               =>  visa_rec.ATTRIBUTE4         ,
                X_ATTRIBUTE5               =>  visa_rec.ATTRIBUTE5         ,
                X_ATTRIBUTE6               =>  visa_rec.ATTRIBUTE6         ,
                X_ATTRIBUTE7               =>  visa_rec.ATTRIBUTE7         ,
                X_ATTRIBUTE8               =>  visa_rec.ATTRIBUTE8         ,
                X_ATTRIBUTE9               =>  visa_rec.ATTRIBUTE9         ,
                X_ATTRIBUTE10              =>  visa_rec.ATTRIBUTE10        ,
                X_ATTRIBUTE11              =>  visa_rec.ATTRIBUTE11        ,
                X_ATTRIBUTE12              =>  visa_rec.ATTRIBUTE12        ,
                X_ATTRIBUTE13              =>  visa_rec.ATTRIBUTE13        ,
                X_ATTRIBUTE14              =>  visa_rec.ATTRIBUTE14        ,
                X_ATTRIBUTE15              =>  visa_rec.ATTRIBUTE15        ,
                X_ATTRIBUTE16              =>  visa_rec.ATTRIBUTE16        ,
                X_ATTRIBUTE17              =>  visa_rec.ATTRIBUTE17        ,
                X_ATTRIBUTE18              =>  visa_rec.ATTRIBUTE18        ,
                X_ATTRIBUTE19              =>  visa_rec.ATTRIBUTE19        ,
                X_ATTRIBUTE20              =>  visa_rec.ATTRIBUTE20        ,
                x_visa_issuing_country     =>  visa_rec.visa_issuing_country,
                X_MODE                     =>  'R');

  -- IF SUCCESSFUL INSERT THEN

       l_error := NULL;
       UPDATE igs_pe_visa_int
       SET status = '1',
       error_code = NULL
       WHERE interface_visa_id = visa_rec.interface_visa_id;

    EXCEPTION
      WHEN OTHERS THEN

        ROLLBACK TO before_insert;
        FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

        IF l_message_name = 'IGS_PE_VISA_DATE_OVERLAP' THEN
             l_error:='E558';
        ELSIF l_message_name = 'IGS_PE_VIS_ASOC_PASS_EXP' THEN
             l_error:='E287';
        ELSE
          l_error := 'E322';
     IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

           IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
       END IF;

           l_label := 'igs.plsql.igs_ad_imp_026.crt_pe_visa.exception' || l_error;

           fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
           fnd_message.set_token('INTERFACE_ID',visa_rec.interface_visa_id);
           fnd_message.set_token('ERROR_CD',l_error);

           l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

           fnd_log.string_with_context( fnd_log.level_exception,
                                    l_label,
                        l_debug_str, NULL,
                        NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
     END IF;

        END IF;

        IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(visa_rec.interface_visa_id,l_error,'IGS_PE_VISA_INT');
        END IF;


           UPDATE igs_pe_visa_int
           SET status = '3',
               error_code = l_error
           WHERE interface_visa_id = visa_rec.interface_visa_id;

     END crt_pe_visa;
 -- START local procedure for updating existing record based on discepancy rule;

PROCEDURE upd_pe_visa(  visa_rec    IN visa_dtls%ROWTYPE,
                        dup_visa_rec IN chk_duplicate%ROWTYPE)
AS

       l_error VARCHAR2(30);
       l_status igs_pe_visa_int.status%TYPE;
       l_exists VARCHAR2(1) := NULL;
       l_message_name  VARCHAR2(30);
       l_app           VARCHAR2(50);

       CURSOR visit_histry_date(cp_visa_rec   visa_dtls%ROWTYPE) IS
       SELECT 'X'
       FROM   igs_pe_visit_histry_v
       WHERE  person_id       = cp_visa_rec.person_id AND
              visa_type = cp_visa_rec.visa_type AND
              visa_issue_date = cp_visa_rec.visa_issue_date AND
              visit_end_date NOT BETWEEN cp_visa_rec.visa_issue_date AND (cp_visa_rec.visa_expiry_date+30);

  BEGIN

    SAVEPOINT before_update;

    OPEN visit_histry_date(visa_rec);
    FETCH visit_histry_date INTO l_exists;
    CLOSE visit_histry_date;

    IF l_exists IS NOT NULL THEN
     UPDATE igs_pe_visa_int
     SET status = '3',
     error_code = 'E559'
     WHERE interface_visa_id = visa_rec.interface_visa_id;

     IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(visa_rec.interface_visa_id,'E559','IGS_PE_VISA_INT');
     END IF;
    ELSE
     IGS_PE_VISA_PKG.UPDATE_ROW (
                 X_ROWID                         => dup_visa_rec.rowid,
                 X_VISA_ID                       => dup_visa_rec.visa_id,
                 X_PERSON_ID                     => NVL(visa_rec.person_id,dup_visa_rec.person_id),
                 X_VISA_TYPE                     => NVL(visa_rec.visa_type,dup_visa_rec.visa_type),
                 X_VISA_NUMBER                   => NVL(visa_rec.visa_number,dup_visa_rec.VISA_NUMBER),
                 X_VISA_ISSUE_DATE               => NVL(visa_rec.VISA_ISSUE_DATE,dup_visa_rec.VISA_ISSUE_DATE),
                 X_VISA_EXPIRY_DATE              => NVL(visa_rec.VISA_EXPIRY_DATE,dup_visa_rec.VISA_EXPIRY_DATE),
                 X_VISA_CATEGORY                 => NVL(visa_rec.VISA_CATEGORY,dup_visa_rec.VISA_CATEGORY),
                 X_VISA_ISSUING_POST             => NVL(visa_rec.VISA_ISSUING_POST,dup_visa_rec.VISA_ISSUING_POST),
                 X_PASSPORT_ID                   => NVL(visa_rec.PASSPORT_ID,dup_visa_rec.PASSPORT_ID),
                 X_AGENT_ORG_UNIT_CD             => NVL(visa_rec.AGENT_ORG_UNIT_CD,dup_visa_rec.AGENT_ORG_UNIT_CD),
                 X_AGENT_PERSON_ID               => NVL(visa_rec.AGENT_PERSON_ID,dup_visa_rec.AGENT_PERSON_ID)  ,
                 X_AGENT_CONTACT_NAME            => NVL(visa_rec.AGENT_CONTACT_NAME,dup_visa_rec.AGENT_CONTACT_NAME)   ,
                 X_ATTRIBUTE_CATEGORY            => NVL(visa_rec.attribute_category,dup_visa_rec.attribute_category)    ,
                 X_ATTRIBUTE1                    => NVL(visa_rec.attribute1, dup_visa_rec.attribute1)          ,
                 X_ATTRIBUTE2                    => NVL(visa_rec.attribute2, dup_visa_rec.attribute2)          ,
                 X_ATTRIBUTE3                    => NVL(visa_rec.attribute3, dup_visa_rec.attribute3)          ,
                 X_ATTRIBUTE4                    => NVL(visa_rec.attribute4, dup_visa_rec.attribute4)          ,
                 X_ATTRIBUTE5                    => NVL(visa_rec.attribute5, dup_visa_rec.attribute5)          ,
                 X_ATTRIBUTE6                    => NVL(visa_rec.attribute6, dup_visa_rec.attribute6)          ,
                 X_ATTRIBUTE7                    => NVL(visa_rec.attribute7, dup_visa_rec.attribute7)          ,
                 X_ATTRIBUTE8                    => NVL(visa_rec.attribute8, dup_visa_rec.attribute8)          ,
                 X_ATTRIBUTE9                    => NVL(visa_rec.attribute9, dup_visa_rec.attribute9)          ,
                 X_ATTRIBUTE10                   => NVL(visa_rec.attribute10,dup_visa_rec.attribute10)        ,
                 X_ATTRIBUTE11                   => NVL(visa_rec.attribute11,dup_visa_rec.attribute11)       ,
                 X_ATTRIBUTE12                   => NVL(visa_rec.attribute12,dup_visa_rec.attribute12)        ,
                 X_ATTRIBUTE13                   => NVL(visa_rec.attribute13,dup_visa_rec.attribute13)        ,
                 X_ATTRIBUTE14                   => NVL(visa_rec.attribute14,dup_visa_rec.attribute14)        ,
                 X_ATTRIBUTE15                   => NVL(visa_rec.attribute15,dup_visa_rec.attribute15)        ,
                 X_ATTRIBUTE16                   => NVL(visa_rec.attribute16,dup_visa_rec.attribute16)        ,
                 X_ATTRIBUTE17                   => NVL(visa_rec.attribute17,dup_visa_rec.attribute17)        ,
                 X_ATTRIBUTE18                   => NVL(visa_rec.attribute18,dup_visa_rec.attribute18)        ,
                 X_ATTRIBUTE19                   => NVL(visa_rec.attribute19,dup_visa_rec.attribute19)        ,
                 X_ATTRIBUTE20                   => NVL(visa_rec.attribute20,dup_visa_rec.attribute20)        ,
                 X_visa_issuing_country          => NVL(visa_rec.visa_issuing_country,dup_visa_rec.visa_issuing_country)        ,
                 X_MODE                          => 'R');

       UPDATE igs_pe_visa_int
       SET status = '1',
           error_code = NULL,
           match_ind = '18'
       WHERE interface_visa_id = visa_rec.interface_visa_id;
       END IF;

   EXCEPTION
     WHEN OTHERS THEN
    ROLLBACK TO before_update;
        FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);
        IF l_message_name = 'IGS_PE_VISA_DATE_OVERLAP' THEN
          UPDATE igs_pe_visa_int
          SET status = '3',
          error_code = 'E558'
          WHERE interface_visa_id = visa_rec.interface_visa_id;

          IF l_enable_log = 'Y' THEN
             igs_ad_imp_001.logerrormessage(visa_rec.interface_visa_id,'E558','IGS_PE_VISA_INT');
          END IF;

        ELSIF l_message_name = 'IGS_PE_VIS_ASOC_PASS_EXP' THEN
          UPDATE igs_pe_visa_int
          SET status = '3',
          error_code = 'E287'
          WHERE interface_visa_id = visa_rec.interface_visa_id;

          IF l_enable_log = 'Y' THEN
             igs_ad_imp_001.logerrormessage(visa_rec.interface_visa_id,'E287','IGS_PE_VISA_INT');
          END IF;

        ELSE
      UPDATE igs_pe_visa_int
        SET status = '3',
        error_code = 'E014'
      WHERE interface_visa_id = visa_rec.interface_visa_id;

            -- CALL LOG DETAIL

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_026.upd_pe_visa.exception' || 'E014';

            fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
            fnd_message.set_token('INTERFACE_ID',visa_rec.interface_visa_id);
            fnd_message.set_token('ERROR_CD','E014');

            l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                    l_label,
                        l_debug_str, NULL,
                        NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

          IF l_enable_log = 'Y' THEN
               igs_ad_imp_001.logerrormessage(visa_rec.interface_visa_id,'E014','IGS_PE_VISA_INT');
          END IF;

        END IF;

  END upd_pe_visa;

--MAIN PROCEDURE BEGINS NOW

  BEGIN

  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_ad_imp_026.prc_pe_visa';
  l_label      := 'igs.plsql.igs_ad_imp_026.prc_pe_visa.';
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

     IF (l_request_id IS NULL) THEN
         l_request_id := fnd_global.conc_request_id;
     END IF;

     l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_visa.begin';
     l_debug_str := 'IGS_AD_IMP_026.prc_pe_visa';

     fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  l_rule :=igs_ad_imp_001.find_source_cat_rule(p_source_type_id,'PERSON_INTERNATIONAL_DETAILS');

  IF l_rule = 'E' OR l_rule = 'I' THEN

     UPDATE igs_pe_visa_int
     SET status='3',
         error_code = 'E695'
     WHERE
          interface_run_id=l_interface_run_id
     AND  STATUS = '2'
     AND  match_ind IS NOT NULL;

     IF l_rule = 'E' THEN

       UPDATE igs_pe_visa_int vi
       SET status='1', match_ind='19'
       WHERE interface_run_id=l_interface_run_id
        AND STATUS = '2'
    AND EXISTS( SELECT vs.rowid
                FROM   igs_pe_visa vs,
                       igs_ad_interface_all ad
            WHERE  ad.interface_id = vi.interface_id AND
                   ad.interface_run_id = l_interface_run_id AND
                   vs.person_id = ad.person_id AND
                   vs.visa_type = UPPER(vi.visa_type) AND
                   vs.visa_issue_date = TRUNC(vi.visa_issue_date));
     END IF;

  ELSIF  l_rule = 'R' THEN

     UPDATE igs_pe_visa_int
     SET status = '1'
     WHERE
         interface_run_id=l_interface_run_id
     AND  status = '2'
     AND  match_ind IN ('18','19','22','23');

     UPDATE igs_pe_visa_int
     SET status = '3',
         error_code = 'E695'
     WHERE
         interface_run_id=l_interface_run_id
     AND  status = '2'
     AND ( match_ind IS NOT NULL  AND match_ind <> '21' AND match_ind <> '25');

     UPDATE igs_pe_visa_int vi
     SET status='1',
         match_ind = '23'
     WHERE
         interface_run_id=l_interface_run_id
     AND status = '2'
     AND match_ind IS NULL
     AND EXISTS( SELECT vs.rowid
                 FROM igs_pe_visa vs,
              igs_ad_interface_all ad
                 WHERE  ad.interface_id = vi.interface_id AND
                ad.interface_run_id = l_interface_run_id AND
                        vs.visa_type = UPPER(vi.visa_type) AND
                        UPPER(vs.visa_number) = UPPER(vi.visa_number) AND
                        vs.person_id = ad.person_id AND
                        ((UPPER(vs.agent_org_unit_cd)= UPPER(vi.agent_org_unit_cd)) OR ((vs.agent_org_unit_cd IS NULL) AND (vi.agent_org_unit_cd IS NULL))) AND
                        ((vs.agent_person_id = vi.agent_person_id) OR ((vs.agent_person_id IS NULL) AND (vi.agent_person_id IS NULL))) AND
                        ((UPPER(vs.agent_contact_name) = UPPER(vi.agent_contact_name)) OR ((vs.agent_contact_name IS NULL) AND (vi.agent_contact_name IS NULL))) AND
                        vs.visa_issue_date = TRUNC(vi.visa_issue_date) AND
                        TRUNC(vs.visa_expiry_date) = TRUNC(vi.visa_expiry_date) AND
                        ((vs.passport_id = vi.passport_id) OR ((vs.passport_id IS NULL) AND (vi.passport_id IS NULL))) AND
                        ((UPPER(vs.visa_issuing_post) = UPPER(vi.visa_issuing_post)) OR ((vs.visa_issuing_post IS NULL) AND (vi.visa_issuing_post IS NULL))) AND
                        ((UPPER(vs.visa_category) = UPPER(vi.visa_category)) OR ((vs.visa_category IS NULL) AND ( vi.visa_category is NULL))) AND
                        ((UPPER(vs.attribute_category) = UPPER(vi.attribute_category)) OR ((vs.attribute_category IS NULL) AND (vi.attribute_category IS NULL))) AND
                        ((UPPER(vs.attribute1) = UPPER(vi.attribute1)) OR ((vs.attribute1 IS NULL) AND (vi.attribute1 IS NULL))) AND
                        ((UPPER(vs.attribute2) = UPPER(vi.attribute2)) OR ((vs.attribute2 IS NULL) AND (vi.attribute2 IS NULL))) AND
                        ((UPPER(vs.attribute3) = UPPER(vi.attribute3)) OR ((vs.attribute3 IS NULL) AND (vi.attribute3 IS NULL))) AND
                        ((UPPER(vs.attribute4) = UPPER(vi.attribute4)) OR ((vs.attribute4 IS NULL) AND (vi.attribute4 IS NULL))) AND
                        ((UPPER(vs.attribute5) = UPPER(vi.attribute5)) OR ((vs.attribute5 IS NULL) AND (vi.attribute5 IS NULL))) AND
                        ((UPPER(vs.attribute6) = UPPER(vi.attribute6)) OR ((vs.attribute6 IS NULL) AND (vi.attribute6 IS NULL))) AND
                        ((UPPER(vs.attribute7) = UPPER(vi.attribute7)) OR ((vs.attribute7 IS NULL) AND (vi.attribute7 IS NULL))) AND
                        ((UPPER(vs.attribute8) = UPPER(vi.attribute8)) OR ((vs.attribute8 IS NULL) AND (vi.attribute8 IS NULL))) AND
                        ((UPPER(vs.attribute9) = UPPER(vi.attribute9)) OR ((vs.attribute9 IS NULL) AND (vi.attribute9 IS NULL))) AND
                        ((UPPER(vs.attribute10) = UPPER(vi.attribute10)) OR ((vs.attribute10 IS NULL) AND (vi.attribute10 IS NULL))) AND
                        ((UPPER(vs.attribute11) = UPPER(vi.attribute11)) OR ((vs.attribute11 IS NULL) AND (vi.attribute11 IS NULL))) AND
                        ((UPPER(vs.attribute12) = UPPER(vi.attribute12)) OR ((vs.attribute12 IS NULL) AND (vi.attribute12 IS NULL))) AND
                        ((UPPER(vs.attribute13) = UPPER(vi.attribute13)) OR ((vs.attribute13 IS NULL) AND (vi.attribute13 IS NULL))) AND
                        ((UPPER(vs.attribute14) = UPPER(vi.attribute14)) OR ((vs.attribute14 IS NULL) AND (vi.attribute14 IS NULL))) AND
                        ((UPPER(vs.attribute15) = UPPER(vi.attribute15)) OR ((vs.attribute15 IS NULL) AND (vi.attribute15 IS NULL))) AND
                        ((UPPER(vs.attribute16) = UPPER(vi.attribute16)) OR ((vs.attribute16 IS NULL) AND (vi.attribute16 IS NULL))) AND
                        ((UPPER(vs.attribute17) = UPPER(vi.attribute17)) OR ((vs.attribute17 IS NULL) AND (vi.attribute17 IS NULL))) AND
                        ((UPPER(vs.attribute18) = UPPER(vi.attribute18)) OR ((vs.attribute18 IS NULL) AND (vi.attribute18 IS NULL))) AND
                        ((UPPER(vs.attribute19) = UPPER(vi.attribute19)) OR ((vs.attribute19 IS NULL) AND (vi.attribute19 IS NULL))) AND
                        ((UPPER(vs.attribute20) = UPPER(vi.attribute20)) OR ((vs.attribute20 IS NULL) AND (vi.attribute20 IS NULL))) AND
                        ((UPPER(vs.visa_issuing_country) = UPPER(vi.visa_issuing_country)) OR ((vs.visa_issuing_country IS NULL) AND (vi.visa_issuing_country IS NULL))));

     UPDATE igs_pe_visa_int vi
     SET status = '3',
         match_ind='20',
     dup_visa_id = (SELECT visa_id
            FROM igs_pe_visa vs,
                 igs_ad_interface_all ad
                WHERE  ad.interface_id = vi.interface_id AND
                   ad.interface_run_id = l_interface_run_id AND
                   vs.person_id = ad.person_id AND
                   vs.visa_type = UPPER(vi.visa_type) AND
                   vs.visa_issue_date = TRUNC(vi.visa_issue_date) )
     WHERE
         interface_run_id=l_interface_run_id AND
         status = '2' AND
         match_ind IS NULL AND
     EXISTS (SELECT vs.rowid
             FROM igs_pe_visa vs,
                  igs_ad_interface_all ad
             WHERE  ad.interface_id = vi.interface_id AND
                ad.interface_run_id = l_interface_run_id AND
                vs.person_id = ad.person_id AND
                vs.visa_type = UPPER(vi.visa_type) AND
                vs.visa_issue_date = TRUNC(vi.visa_issue_date));
  END IF;

  FOR visa_rec IN visa_dtls(l_interface_run_id) LOOP

  l_processed_records := l_processed_records + 1;

  -- user uppers  truncs
      visa_rec.visa_issuing_post := UPPER(visa_rec.visa_issuing_post);
      visa_rec.VISA_TYPE  :=  UPPER(visa_rec.VISA_TYPE);
      visa_rec.visa_issuing_country := UPPER(visa_rec.visa_issuing_country);
      visa_rec.visa_issue_date := TRUNC(visa_rec.visa_issue_date);
      visa_rec.visa_expiry_date := TRUNC(visa_rec.visa_expiry_date);

    IF  validate_visa(visa_rec,l_error_code) THEN

      l_visa_rec.visa_id := NULL;
      OPEN chk_duplicate(visa_rec.person_id,visa_rec.visa_type,visa_rec.visa_issue_date);
      FETCH chk_duplicate INTO l_visa_rec;
      CLOSE chk_duplicate;

      IF l_visa_rec.visa_id  IS NOT NULL THEN
        l_dup_var := TRUE;
      END IF;

      IF l_dup_var THEN

-- IF DUPLICATE RECORDS FOUND THEN FOLLOW DISCREPANCY RULE,GMURALD

            IF l_rule = 'I' THEN
        upd_pe_visa( visa_rec => visa_rec, dup_visa_rec => l_visa_rec);
            ELSIF l_rule = 'R' THEN   -- MATCH REVIEWED TO BE IMPORTED
               IF visa_rec.match_ind = '21' THEN
                  upd_pe_visa( visa_rec => visa_rec, dup_visa_rec => l_visa_rec);
             END IF;
          END IF;
        ELSE
          crt_pe_visa(visa_rec  => visa_rec) ;
        END IF;
     END IF;

     IF l_error_code = 'E555' THEN
           UPDATE igs_pe_visa_int
           SET status = '4',
           error_code = l_error_code
           WHERE interface_visa_id = visa_rec.interface_visa_id;

           -- CALL LOG DETAIL

           IF l_enable_log = 'Y' THEN
              igs_ad_imp_001.logerrormessage(visa_rec.interface_visa_id,l_error_code,'IGS_PE_VISA_INT');
           END IF;
     END IF;

     IF l_processed_records = 100 THEN
       COMMIT;
       l_processed_records := 0;
     END IF;

   END LOOP;
END prc_pe_visa;

FUNCTION validate_visa_pub(api_visa_rec IGS_PE_VISAPASS_PUB.visa_rec_type,
                           p_err_code OUT NOCOPY igs_pe_visa_int.error_code%TYPE) RETURN BOOLEAN IS

  l_visa_rec visa_dtls%ROWTYPE;
  l_return_value BOOLEAN;

BEGIN

  l_visa_rec.person_id := api_visa_rec.person_id;
  l_visa_rec.visa_type := api_visa_rec.visa_type;
  l_visa_rec.visa_number := api_visa_rec.visa_number;
  l_visa_rec.visa_issue_date := api_visa_rec.visa_issue_date;
  l_visa_rec.visa_expiry_date := api_visa_rec.visa_expiry_date;

  l_visa_rec.agent_org_unit_cd := api_visa_rec.agent_org_unit_cd;
  l_visa_rec.agent_person_id := api_visa_rec.agent_person_id;
  l_visa_rec.agent_contact_name := api_visa_rec.agent_contact_name;
  l_visa_rec.visa_issuing_post := api_visa_rec.visa_issuing_post;
  l_visa_rec.passport_id := api_visa_rec.passport_id;
  l_visa_rec.visa_issuing_country := api_visa_rec.visa_issuing_country;

  l_visa_rec.attribute_category :=  api_visa_rec.attribute_category;
  l_visa_rec.attribute1 :=  api_visa_rec.attribute1;
  l_visa_rec.attribute2 :=  api_visa_rec.attribute2;
  l_visa_rec.attribute3 :=  api_visa_rec.attribute3;
  l_visa_rec.attribute4 :=  api_visa_rec.attribute4;
  l_visa_rec.attribute5 :=  api_visa_rec.attribute5;
  l_visa_rec.attribute6 :=  api_visa_rec.attribute6;
  l_visa_rec.attribute7 :=  api_visa_rec.attribute7;
  l_visa_rec.attribute8 :=  api_visa_rec.attribute8;
  l_visa_rec.attribute9 :=  api_visa_rec.attribute9;
  l_visa_rec.attribute10 :=  api_visa_rec.attribute10;
  l_visa_rec.attribute11 :=  api_visa_rec.attribute11;
  l_visa_rec.attribute12 :=  api_visa_rec.attribute12;
  l_visa_rec.attribute13 :=  api_visa_rec.attribute13;
  l_visa_rec.attribute14 :=  api_visa_rec.attribute14;
  l_visa_rec.attribute15 :=  api_visa_rec.attribute15;
  l_visa_rec.attribute16 :=  api_visa_rec.attribute16;
  l_visa_rec.attribute17 :=  api_visa_rec.attribute17;
  l_visa_rec.attribute18 :=  api_visa_rec.attribute18;
  l_visa_rec.attribute19 :=  api_visa_rec.attribute19;
  l_visa_rec.attribute20 :=  api_visa_rec.attribute20;

  l_return_value := validate_visa(visa_rec => l_visa_rec,
                                  p_error_code => p_err_code,
				  p_mode => 'PUB');

  return  l_return_value;

END validate_visa_pub;

FUNCTION Validate_Passport(pass_rec IN pass_dtls%ROWTYPE, p_err_code OUT NOCOPY VARCHAR2, p_mode IN VARCHAR2 DEFAULT NULL ) RETURN BOOLEAN IS

    CURSOR birth_dt_cur(cp_person_id igs_ad_interface.person_id%TYPE) IS
     SELECT BIRTH_DATE Birth_dt
     FROM IGS_PE_PERSON_BASE_V
     WHERE person_id = cp_person_id;

    l_birth_date IGS_AD_INTERFACE.BIRTH_DT%TYPE;

    l_enable_log VARCHAR2(1);
    l_prog_label  VARCHAR2(100);

    l_request_id NUMBER;
    l_label  VARCHAR2(100);
    l_debug_str VARCHAR2(2000);

    BEGIN
     --BEGIN OF VALIDATE RECORD FUNCTION
     -- start validations

        l_prog_label := 'igs.plsql.igs_ad_imp_026.prc_pe_passport';
        l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_passport.';
        l_enable_log := igs_ad_imp_001.g_enable_log;

        p_err_code := NULL;

        --IF NOT igs_pe_pers_imp_001.validate_lookup_type_code('PER_US_COUNTRY_CODE',pass_rec.passport_cntry_code,3) THEN
	IF NOT (igs_pe_pers_imp_001.validate_country_code(pass_rec.passport_cntry_code))   -- change for country code inconsistency bug 3738488
        THEN
          p_err_code := 'E553';
          RAISE no_data_found;
        END IF;

        OPEN birth_dt_cur(pass_rec.person_id);
        FETCH birth_dt_cur INTO l_birth_date;
        IF l_birth_date IS NOT NULL THEN
          IF pass_rec.passport_expiry_date < l_birth_date THEN
            p_err_code := 'E556';
            RAISE no_data_found;
          END IF;
        END IF;
        CLOSE birth_dt_cur;

    --ALL VALIDATIONS ARE OK

    p_err_code := NULL;

    IF p_mode IS NULL THEN
     UPDATE igs_pe_passport_int
     SET status = '1',
        error_code = p_err_code
     WHERE interface_passport_id   = pass_rec.interface_passport_id;
    END IF;

    RETURN TRUE;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

        IF birth_dt_cur%ISOPEN THEN
          CLOSE birth_dt_cur;
        END IF;

        IF p_mode IS NULL THEN
  	 UPDATE igs_pe_passport_int
         SET status = '3',
             error_code = p_err_code
         WHERE interface_passport_id = pass_rec.interface_passport_id;

         IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(pass_rec.interface_passport_id,p_err_code,'IGS_PE_PASSPORT_INT');
         END IF;
        END IF;

        RETURN FALSE;
      WHEN OTHERS THEN

        IF p_mode IS NULL THEN
 	  UPDATE igs_pe_passport_int
          SET status = '3',
              error_code = p_err_code
          WHERE interface_passport_id = pass_rec.interface_passport_id;
        END IF;

        -- CALL LOG DETAIL

     IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

             IF (l_request_id IS NULL) THEN
                l_request_id := fnd_global.conc_request_id;
         END IF;

             l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_passport.val_exception' || p_err_code;

             fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
             fnd_message.set_token('INTERFACE_ID',pass_rec.interface_passport_id);
             fnd_message.set_token('ERROR_CD',p_err_code);

         l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

             fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
       END IF;

           IF l_enable_log = 'Y' THEN
               igs_ad_imp_001.logerrormessage(pass_rec.interface_passport_id,p_err_code,'IGS_PE_PASSPORT_INT');
           END IF;

           RETURN FALSE;
END Validate_Passport;

FUNCTION validate_passport_pub(api_pass_rec IGS_PE_VISAPASS_PUB.passport_rec_type,
                                   p_err_code OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS

  l_pass_rec pass_dtls%ROWTYPE;
  l_return_value BOOLEAN;

BEGIN

   l_pass_rec.person_id := api_pass_rec.person_id;
   l_pass_rec.passport_number := api_pass_rec.passport_number;
   l_pass_rec.passport_expiry_date := api_pass_rec.passport_expiry_date;
   l_pass_rec.passport_cntry_code := api_pass_rec.passport_cntry_code;

   l_return_value := Validate_passport(pass_rec => l_pass_rec,p_err_code => p_err_code);

  return  l_return_value;

END validate_passport_pub;



PROCEDURE prc_pe_passport(
          p_source_type_id  IN NUMBER,
          p_batch_id        IN NUMBER )
 AS
/*
 ||  Created By : gmuralid  - Passport Import Process
 ||  Date       : 2-DEC-2002
 ||  Build      : SEVIS
 ||  Bug No     : 2599109

 ||  Change History :
 ||  Who             When            What
 || npalanis         6-JAN-2003      Bug : 2734697
 ||                                  code added to commit after import of every
 ||                                  100 records .New variable l_processed_records added
 ||
 ||  ssaleem       8-OCT-2003       Bug no : 3130316
 ||                                 Performance enhancements done, validations and status
 ||                                 updations done outside the main loop
*/

  CURSOR chk_duplicate(cp_person_id   igs_pe_passport.person_id%TYPE,
                     cp_passport_number   igs_pe_passport.passport_number%TYPE ,
                     cp_passport_cntry_code  igs_pe_passport.passport_cntry_code%TYPE) IS
  SELECT rowid, pi.*
  FROM  igs_pe_passport pi
  WHERE person_id = cp_person_id AND
        UPPER(passport_number) = UPPER(cp_passport_number) AND
        passport_cntry_code = UPPER(cp_passport_cntry_code);

  l_var VARCHAR2(1);
  l_rule VARCHAR2(1);
  l_count NUMBER;
  lvcAction VARCHAR2(1);
  l_error_code VARCHAR2(30);
  l_status VARCHAR2(10);
  l_dup_var BOOLEAN;
  pass_rec  pass_dtls%ROWTYPE;
  l_dup_id igs_pe_passport.passport_id%TYPE;
  l_processed_records NUMBER(5) := 0;
   -- l_pass_rec variable will get populated during duplicate check
  l_pass_rec chk_duplicate%ROWTYPE;


  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER;
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

    PROCEDURE crt_pe_pass(pass_rec   IN pass_dtls%ROWTYPE,
                         error_code OUT NOCOPY VARCHAR2,
                         status     OUT NOCOPY VARCHAR2)
     AS
      l_rowid ROWID := NULL;
      l_error VARCHAR2(30);
      l_pass_id IGS_PE_PASSPORT.passport_id%TYPE;

     BEGIN
        --CALL TO PASSPORT INSERT RECORD

        IGS_PE_PASSPORT_PKG.INSERT_ROW(
                         X_ROWID                    => l_rowid,
                         X_PASSPORT_ID              => l_pass_id ,
                         X_PERSON_ID                => pass_rec.person_id,
                         X_PASSPORT_NUMBER          => pass_rec.passport_number,
                         X_PASSPORT_EXPIRY_DATE     => pass_rec.passport_expiry_date,
                         X_PASSPORT_CNTRY_CODE      => pass_rec.passport_cntry_code  ,
                         X_ATTRIBUTE_CATEGORY       => pass_rec.attribute_category  ,
                         X_ATTRIBUTE1               => pass_rec.attribute1          ,
                         X_ATTRIBUTE2               => pass_rec.attribute2          ,
                         X_ATTRIBUTE3               => pass_rec.attribute3          ,
                         X_ATTRIBUTE4               => pass_rec.attribute4          ,
                         X_ATTRIBUTE5               => pass_rec.attribute5          ,
                         X_ATTRIBUTE6               => pass_rec.attribute6          ,
                         X_ATTRIBUTE7               => pass_rec.attribute7          ,
                         X_ATTRIBUTE8               => pass_rec.attribute8          ,
                         X_ATTRIBUTE9               => pass_rec.attribute9          ,
                         X_ATTRIBUTE10              => pass_rec.attribute10         ,
                         X_ATTRIBUTE11              => pass_rec.attribute11          ,
                         X_ATTRIBUTE12              => pass_rec.attribute12          ,
                         X_ATTRIBUTE13              => pass_rec.attribute13          ,
                         X_ATTRIBUTE14              => pass_rec.attribute14          ,
                         X_ATTRIBUTE15              => pass_rec.attribute15           ,
                         X_ATTRIBUTE16              => pass_rec.attribute16           ,
                         X_ATTRIBUTE17              => pass_rec.attribute17            ,
                         X_ATTRIBUTE18              => pass_rec.attribute18            ,
                         X_ATTRIBUTE19              => pass_rec.attribute19            ,
                         X_ATTRIBUTE20              => pass_rec.attribute20            ,
                         X_MODE                     => 'R'
                                           );

  --   IF SUCCESSFUL INSERT THEN

        l_error := NULL;
        UPDATE igs_pe_passport_int
        SET status = '1',
        error_code = l_error
        WHERE interface_passport_id = pass_rec.interface_passport_id;

        EXCEPTION
           WHEN OTHERS THEN
           l_error := 'E322';

           UPDATE igs_pe_passport_int
           SET status = '3',
           error_code = l_error
           WHERE interface_passport_id = pass_rec.interface_passport_id;

        -- CALL LOG DETAIL

           IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

             IF (l_request_id IS NULL) THEN
                l_request_id := fnd_global.conc_request_id;
         END IF;

             l_label := 'igs.plsql.igs_ad_imp_026.crt_pe_pass.exception' || l_error;

             fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
             fnd_message.set_token('INTERFACE_ID',pass_rec.interface_passport_id);
             fnd_message.set_token('ERROR_CD',l_error);

         l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

             fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
       END IF;

           IF l_enable_log = 'Y' THEN
               igs_ad_imp_001.logerrormessage(pass_rec.interface_passport_id,l_error,'IGS_PE_PASSPORT_INT');
           END IF;

   END crt_pe_pass;


  -- START local procedure for updating existing record based on discepancy rule;

  PROCEDURE upd_pe_pass( pass_rec  IN pass_dtls%ROWTYPE,
                            dup_pass_rec IN chk_duplicate%ROWTYPE,
                            p_error_code  OUT NOCOPY VARCHAR2,
                            p_status      OUT NOCOPY VARCHAR2)
      AS

       l_error VARCHAR2(30);
       l_message_name  VARCHAR2(30);
       l_app           VARCHAR2(50);

       BEGIN

       --  MAKE CALL TO THE TBH i.e IGS_PE_PASSPORT_PKG.UPDATE_ROW
         igs_pe_passport_pkg.update_row(
                          X_ROWID                   => dup_pass_rec.rowid,
                          X_PASSPORT_ID             => dup_pass_rec.passport_id,
                          X_PERSON_ID               => NVL(pass_rec.person_id,dup_pass_rec.person_id),
                          X_PASSPORT_NUMBER         => NVL(pass_rec.passport_number,dup_pass_rec.passport_number),
                          X_PASSPORT_EXPIRY_DATE    => NVL(pass_rec.passport_expiry_date,dup_pass_rec.passport_expiry_date),
                          X_PASSPORT_CNTRY_CODE     => NVL(pass_rec.passport_cntry_code,dup_pass_rec.passport_cntry_code),
                          X_ATTRIBUTE_CATEGORY      => NVL(pass_rec.attribute_category,dup_pass_rec.attribute_category)  ,
                          X_ATTRIBUTE1              => NVL(pass_rec.attribute1,dup_pass_rec.attribute1),
                          X_ATTRIBUTE2              => NVL(pass_rec.attribute2,dup_pass_rec.attribute2),
                          X_ATTRIBUTE3              => NVL(pass_rec.attribute3,dup_pass_rec.attribute3),
                          X_ATTRIBUTE4              => NVL(pass_rec.attribute4,dup_pass_rec.attribute4),
                          X_ATTRIBUTE5              => NVL(pass_rec.attribute5,dup_pass_rec.attribute5),
                          X_ATTRIBUTE6              => NVL(pass_rec.attribute6,dup_pass_rec.attribute6),
                          X_ATTRIBUTE7              => NVL(pass_rec.attribute7,dup_pass_rec.attribute7),
                          X_ATTRIBUTE8              => NVL(pass_rec.attribute8,dup_pass_rec.attribute8),
                          X_ATTRIBUTE9              => NVL(pass_rec.attribute9,dup_pass_rec.attribute9),
                          X_ATTRIBUTE10             => NVL(pass_rec.attribute10,dup_pass_rec.attribute10),
                          X_ATTRIBUTE11             => NVL(pass_rec.attribute11,dup_pass_rec.attribute11),
                          X_ATTRIBUTE12             => NVL(pass_rec.attribute12,dup_pass_rec.attribute12),
                          X_ATTRIBUTE13             => NVL(pass_rec.attribute13,dup_pass_rec.attribute13),
                          X_ATTRIBUTE14             => NVL(pass_rec.attribute14,dup_pass_rec.attribute14),
                          X_ATTRIBUTE15             => NVL(pass_rec.attribute15,dup_pass_rec.attribute15),
                          X_ATTRIBUTE16             => NVL(pass_rec.attribute16,dup_pass_rec.attribute16),
                          X_ATTRIBUTE17             => NVL(pass_rec.attribute17,dup_pass_rec.attribute17),
                          X_ATTRIBUTE18             => NVL(pass_rec.attribute18,dup_pass_rec.attribute18),
                          X_ATTRIBUTE19             => NVL(pass_rec.attribute19,dup_pass_rec.attribute19),
                          X_ATTRIBUTE20             => NVL(pass_rec.attribute20,dup_pass_rec.attribute20),
                          X_MODE                    => 'R'
                                          );

       -- IF SUCCESFUL UPDATE THEN

             p_error_code := NULL;
             p_status := '1';

           EXCEPTION
               WHEN OTHERS THEN

           FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

          IF l_message_name = 'IGS_PE_VIS_ASOC_PASS_EXP' THEN
                 p_error_code := 'E288';
                 p_status := '3';

        -- CALL LOG DETAIL

          ELSE
                  p_error_code := 'E014';
                  p_status := '3';

        -- CALL LOG DETAIL

         IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

               IF (l_request_id IS NULL) THEN
                 l_request_id := fnd_global.conc_request_id;
               END IF;

               l_label := 'igs.plsql.igs_ad_imp_026.upd_pe_pass.exception' || p_error_code;

               fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
               fnd_message.set_token('INTERFACE_ID',pass_rec.interface_passport_id);
               fnd_message.set_token('ERROR_CD',p_error_code);

           l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

               fnd_log.string_with_context( fnd_log.level_exception,
                                        l_label,
                            l_debug_str, NULL,
                            NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;

          END IF;

          IF l_enable_log = 'Y' THEN
               igs_ad_imp_001.logerrormessage(pass_rec.interface_passport_id,p_error_code,'IGS_PE_PASSPORT_INT');
          END IF;

          UPDATE igs_pe_passport_int
          SET status = p_status,
              error_code = p_error_code
          WHERE interface_passport_id = pass_rec.interface_passport_id;

        END upd_pe_pass;


     --MAIN PROCEDURE BEGINS NOW
     BEGIN

     l_prog_label := 'igs.plsql.igs_ad_imp_026.prc_pe_passport';
     l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_passport.';
     l_enable_log := igs_ad_imp_001.g_enable_log;
     l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
     IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

        IF (l_request_id IS NULL) THEN
            l_request_id := fnd_global.conc_request_id;
        END IF;

        l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_passport.begin';
        l_debug_str :=  'IGS_AD_IMP_026.prc_pe_passport';

    fnd_log.string_with_context( fnd_log.level_procedure,
                                 l_label,
                             l_debug_str, NULL,
                     NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
     END IF;

      l_rule :=igs_ad_imp_001.find_source_cat_rule(p_source_type_id,'PERSON_INTERNATIONAL_DETAILS');

      IF l_rule = 'E' OR l_rule = 'I' THEN

           UPDATE igs_pe_passport_int
           SET status='3',
               error_code = 'E695'
           WHERE
               interface_run_id=l_interface_run_id
           AND  STATUS = '2'
           AND  match_ind IS NOT NULL;

           IF l_rule = 'E' THEN

             UPDATE igs_pe_passport_int pi
             SET status='1',
             match_ind='19'
         WHERE
                 interface_run_id=l_interface_run_id
             AND STATUS = '2'
         AND EXISTS( SELECT ps.rowid
                     FROM   igs_pe_passport ps,
                            igs_ad_interface_all ad
                     WHERE  ad.interface_id = pi.interface_id AND
                            ad.interface_run_id = l_interface_run_id AND
                            ps.person_id = ad.person_id AND
                            ps.passport_cntry_code = UPPER(pi.passport_cntry_code) AND
                            UPPER(ps.passport_number)  = UPPER(pi.passport_number));
           END IF;

      ELSIF  l_rule = 'R' THEN

           UPDATE igs_pe_passport_int
           SET status = '1'
           WHERE
                interface_run_id=l_interface_run_id
           AND  status = '2'
           AND  match_ind IN ('18','19','22','23');

           UPDATE igs_pe_passport_int
           SET status = '3',
               error_code = 'E695'
           WHERE
                interface_run_id=l_interface_run_id
           AND  status = '2'
           AND ( match_ind IS NOT NULL  AND match_ind <> '21' AND match_ind <> '25');

           UPDATE igs_pe_passport_int pi
           SET status='1',
               match_ind = '23'
           WHERE
               interface_run_id=l_interface_run_id
           AND status = '2'
           AND match_ind IS NULL
           AND EXISTS( SELECT ps.rowid
                   FROM igs_pe_passport ps,
                    igs_ad_interface_all ad
               WHERE ad.interface_id = pi.interface_id AND
                     ad.interface_run_id = l_interface_run_id AND
                     ps.person_id = ad.person_id AND
                     ps.passport_cntry_code = UPPER(pi.passport_cntry_code) AND
                 UPPER(ps.passport_number)  = UPPER(pi.passport_number) AND
                             TRUNC(ps.passport_expiry_date) = TRUNC(pi.passport_expiry_date) AND
                             ((ps.attribute_category = pi.attribute_category) OR ((ps.attribute_category IS NULL) AND (pi.attribute_category IS NULL))) AND
                             ((ps.attribute1 = pi.attribute1) OR ((ps.attribute1 IS NULL) AND (pi.attribute1 IS NULL))) AND
                             ((ps.attribute2 = pi.attribute2) OR ((ps.attribute2 IS NULL) AND (pi.attribute2 IS NULL))) AND
                             ((ps.attribute3 = pi.attribute3) OR ((ps.attribute3 IS NULL) AND (pi.attribute3 IS NULL))) AND
                             ((ps.attribute4 = pi.attribute4) OR ((ps.attribute4 IS NULL) AND (pi.attribute4 IS NULL))) AND
                             ((ps.attribute5 = pi.attribute5) OR ((ps.attribute5 IS NULL) AND (pi.attribute5 IS NULL))) AND
                             ((ps.attribute6 = pi.attribute6) OR ((ps.attribute6 IS NULL) AND (pi.attribute6 IS NULL))) AND
                             ((ps.attribute7 = pi.attribute7) OR ((ps.attribute7 IS NULL) AND (pi.attribute7 IS NULL))) AND
                             ((ps.attribute8 = pi.attribute8) OR ((ps.attribute8 IS NULL) AND (pi.attribute8 IS NULL))) AND
                             ((ps.attribute9 = pi.attribute9) OR ((ps.attribute9 IS NULL) AND (pi.attribute9 IS NULL))) AND
                             ((ps.attribute10 = pi.attribute10) OR ((ps.attribute10 IS NULL) AND (pi.attribute10 IS NULL))) AND
                             ((ps.attribute11 = pi.attribute11) OR ((ps.attribute11 IS NULL) AND (pi.attribute11 IS NULL))) AND
                             ((ps.attribute12 = pi.attribute12) OR ((ps.attribute12 IS NULL) AND (pi.attribute12 IS NULL))) AND
                             ((ps.attribute13 = pi.attribute13) OR ((ps.attribute13 IS NULL) AND (pi.attribute13 IS NULL))) AND
                             ((ps.attribute14 = pi.attribute14) OR ((ps.attribute14 IS NULL) AND (pi.attribute14 IS NULL))) AND
                             ((ps.attribute15 = pi.attribute15) OR ((ps.attribute15 IS NULL) AND (pi.attribute15 IS NULL))) AND
                             ((ps.attribute16 = pi.attribute16) OR ((ps.attribute16 IS NULL) AND (pi.attribute16 IS NULL))) AND
                             ((ps.attribute17 = pi.attribute17) OR ((ps.attribute17 IS NULL) AND (pi.attribute17 IS NULL))) AND
                             ((ps.attribute18 = pi.attribute18) OR ((ps.attribute18 IS NULL) AND (pi.attribute18 IS NULL))) AND
                             ((ps.attribute19 = pi.attribute19) OR ((ps.attribute19 IS NULL) AND (pi.attribute19 IS NULL))) AND
                             ((ps.attribute20 = pi.attribute20) OR ((ps.attribute20 IS NULL) AND (pi.attribute20 IS NULL))));

           UPDATE igs_pe_passport_int pi
           SET status = '3',
               match_ind='20',
           dup_passport_id = (SELECT passport_id
                          FROM igs_pe_passport ps,
                                   igs_ad_interface_all ad
                          WHERE  ad.interface_id = pi.interface_id AND
                                 ad.interface_run_id = l_interface_run_id AND
                                 ps.person_id = ad.person_id AND
                                 ps.passport_cntry_code = UPPER(pi.passport_cntry_code) AND
                                 UPPER(ps.passport_number) = UPPER(pi.passport_number))
           WHERE interface_run_id=l_interface_run_id AND
                  status = '2' AND
                  match_ind IS NULL AND
           EXISTS (SELECT ps.rowid
                   FROM igs_pe_passport ps,
                        igs_ad_interface_all ad
                   WHERE  ad.interface_id = pi.interface_id AND
                          ps.person_id = ad.person_id AND
                          ad.interface_run_id = l_interface_run_id AND
                          ps.passport_cntry_code = UPPER(pi.passport_cntry_code) AND
                          UPPER(ps.passport_number) = UPPER(pi.passport_number));
       END IF;


      FOR pass_rec in pass_dtls(l_interface_run_id) LOOP

      l_processed_records := l_processed_records + 1;

  -- user uppers and truncs
        pass_rec.passport_cntry_code := UPPER(pass_rec.passport_cntry_code);
        pass_rec.PASSPORT_EXPIRY_DATE := TRUNC(pass_rec.PASSPORT_EXPIRY_DATE);

        IF  validate_passport(pass_rec, l_error_code) THEN

           l_dup_var := FALSE;
           l_pass_rec.passport_id := NULL;
       OPEN chk_duplicate(pass_rec.person_id,pass_rec.passport_number,pass_rec.passport_cntry_code);
           FETCH chk_duplicate INTO l_pass_rec;
           CLOSE chk_duplicate;

       IF l_pass_rec.passport_id IS NOT NULL THEN
             l_dup_var := TRUE;
       END IF;

           IF l_dup_var THEN

      -- IF DUPLICATE RECORDS FOUND THEN FOLLOW DISCREPANCY RULE,GMURALD

            IF l_rule = 'I' THEN
               BEGIN
                 upd_pe_pass( pass_rec => pass_rec,
                      dup_pass_rec => l_pass_rec,
                              p_error_code => l_error_code,
                              p_status => l_status);

                  UPDATE igs_pe_passport_int
                  SET match_ind = '18',  -- MATCH OCCURED AND USED IMPORTED VALUES
                      status = l_status ,
                      error_code = l_error_code
                  WHERE interface_passport_id= pass_rec.interface_passport_id;

               EXCEPTION
                    WHEN OTHERS THEN

                    IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                      IF (l_request_id IS NULL) THEN
                          l_request_id := fnd_global.conc_request_id;
                  END IF;

                      l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_passport.exception' || 'E014';

                      fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                      fnd_message.set_token('INTERFACE_ID',pass_rec.interface_passport_id);
                      fnd_message.set_token('ERROR_CD','E014');

                      l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

                      fnd_log.string_with_context( fnd_log.level_exception,
                                               l_label,
                                   l_debug_str, NULL,
                                   NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                    END IF;

                    IF l_enable_log = 'Y' THEN
                      igs_ad_imp_001.logerrormessage(pass_rec.interface_passport_id,'E014','IGS_PE_PASSPORT_INT');
                    END IF;

                     UPDATE igs_pe_passport_int
                     SET match_ind = '18',
                         status = '3',
                         error_code = 'E014'
                     WHERE interface_passport_id= pass_rec.interface_passport_id;
               END;

             ELSIF l_rule = 'R' THEN   -- MATCH REVIEWED TO BE IMPORTED
                 IF pass_rec.match_ind = '21' THEN
                    BEGIN
                       upd_pe_pass(pass_rec => pass_rec,
                           dup_pass_rec => l_pass_rec,
                                   p_error_code => l_error_code,
                                   p_status => l_status);

                       UPDATE igs_pe_passport_int
                       SET status = l_status ,
                           error_code = l_error_code
                       WHERE interface_passport_id= pass_rec.interface_passport_id;

                    EXCEPTION
                        WHEN OTHERS THEN

                          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                                 IF (l_request_id IS NULL) THEN
                                    l_request_id := fnd_global.conc_request_id;
                             END IF;

                                 l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_passport.exception1' || 'E014';

                                 fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                                 fnd_message.set_token('INTERFACE_ID',pass_rec.interface_passport_id);
                                 fnd_message.set_token('ERROR_CD','E014');

                                 l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

                                 fnd_log.string_with_context( fnd_log.level_exception,
                                                          l_label,
                                              l_debug_str, NULL,
                                                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                             END IF;

                             IF l_enable_log = 'Y' THEN
                               igs_ad_imp_001.logerrormessage(pass_rec.interface_passport_id,'E014','IGS_PE_PASSPORT_INT');
                             END IF;

                             UPDATE igs_pe_passport_int
                             SET status = '3',
                                 error_code = 'E014'
                             WHERE interface_passport_id= pass_rec.interface_passport_id;
                    END;
                   END IF;
              END IF;
            ELSE
                   crt_pe_pass(pass_rec  => pass_rec,
                               error_code => l_error_code,
                               status  => l_status) ;
             END IF;
          END IF;

          IF l_processed_records = 100 THEN
               COMMIT;
               l_processed_records := 0;
           END IF;

       END LOOP;

END prc_pe_passport;

FUNCTION Validate_visit_histry(visit_rec IN visit_dtls%ROWTYPE,
                               p_err_code OUT NOCOPY VARCHAR2,
			       p_mode IN VARCHAR2 DEFAULT NULL )
RETURN BOOLEAN IS

    CURSOR birth_dt_cur(cp_person_id igs_ad_interface.person_id%TYPE) IS
    SELECT BIRTH_DATE Birth_dt
    FROM IGS_PE_PERSON_BASE_V
    WHERE
    person_id = cp_person_id;


   CURSOR valid_entry_date(cp_person_id igs_ad_interface.person_id%TYPE,
               cp_visa_id igs_pe_visa.visa_id%TYPE,
               cp_visit_start_date igs_pe_visa.visa_issue_date%TYPE) IS
   SELECT 'Y' FROM IGS_PE_VISA
   WHERE person_id = cp_person_id AND
   visa_id = cp_visa_id AND
   cp_visit_start_date BETWEEN visa_issue_date AND visa_expiry_date;

   l_birth_date IGS_AD_INTERFACE.BIRTH_DT%TYPE;

   l_enable_log VARCHAR2(1);
   l_prog_label  VARCHAR2(100);

   l_request_id NUMBER;
   l_label  VARCHAR2(100);
   l_debug_str VARCHAR2(2000);

BEGIN
--BEGIN OF VALIDATE RECORD FUNCTION

   p_err_code := NULL;

  l_prog_label := 'igs.plsql.igs_ad_imp_026.prc_pe_visit_histry';
  l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_visit_histry.';
  l_enable_log := igs_ad_imp_001.g_enable_log;

   IF NOT igs_pe_pers_imp_001.validate_lookup_type_code('PE_US_PORT_OF_ENTRY',visit_rec.port_of_entry,8405) THEN
     p_err_code := 'E557';
     RAISE no_data_found;
   END IF;


    IF visit_rec.visit_end_date IS NOT NULL THEN
      IF visit_rec.visit_end_date < visit_rec.visit_start_date THEN
    p_err_code := 'E561';
    RAISE no_data_found;
      END IF;
   END IF;

 OPEN birth_dt_cur(visit_rec.person_id);
 FETCH birth_dt_cur INTO l_birth_date;
 IF l_birth_date IS NOT NULL THEN

   IF visit_rec.visit_start_date < l_birth_date THEN
     p_err_code := 'E562';
     RAISE no_data_found;
   END IF;

   IF visit_rec.visit_end_date IS NOT NULL THEN
      IF visit_rec.visit_end_date < l_birth_date THEN
    p_err_code := 'E563';
    RAISE no_data_found;
      END IF;
   END IF;
END IF;
CLOSE birth_dt_cur;


IF (visit_rec.visit_start_date) BETWEEN visit_rec.issue_date AND visit_rec.expiry_date THEN
  NULL;
ELSE
  p_err_code := 'E565';
  RAISE no_data_found;
END IF;

IF visit_rec.visit_end_date IS NOT NULL THEN
 IF (visit_rec.visit_end_date) BETWEEN visit_rec.issue_date AND (visit_rec.expiry_date +  30) THEN
  NULL;
 ELSE
   p_err_code := 'E572';
   RAISE no_data_found;
 END IF;
END IF;

--ALL VALIDATIONS ARE OK

 p_err_code := NULL;

 IF p_mode IS NULL THEN
  UPDATE igs_pe_vst_hist_int
  SET status = '1',
      error_code = p_err_code
  WHERE interface_visit_histry_id   = visit_rec.interface_visit_histry_id;
 END IF;

 RETURN TRUE;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN

       IF birth_dt_cur%ISOPEN THEN
     CLOSE birth_dt_cur;
       END IF;

       IF p_mode IS NULL THEN
         UPDATE igs_pe_vst_hist_int
         SET status = '3',
         error_code = p_err_code
         WHERE interface_visit_histry_id   = visit_rec.interface_visit_histry_id;

         IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(visit_rec.interface_visit_histry_id,p_err_code,'IGS_PE_VST_HIST_INT');
         END IF;
       END IF;

       RETURN FALSE;
     WHEN OTHERS THEN
        IF p_mode IS NULL THEN
          UPDATE igs_pe_vst_hist_int
            SET status = '3',
            error_code = p_err_code
            WHERE interface_visit_histry_id = visit_rec.interface_visit_histry_id;
         END IF;

         -- CALL LOG DETAIL

         IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

        IF (l_request_id IS NULL) THEN
            l_request_id := fnd_global.conc_request_id;
        END IF;

        l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_visit_histry.val_exception' || p_err_code;

        fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
        fnd_message.set_token('INTERFACE_ID',visit_rec.interface_visit_histry_id);
        fnd_message.set_token('ERROR_CD',p_err_code);

        l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

        fnd_log.string_with_context( fnd_log.level_exception,
                         l_label,
                         l_debug_str, NULL,
                         NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
         END IF;

         IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(visit_rec.interface_visit_histry_id,p_err_code,'IGS_PE_VST_HIST_INT');
         END IF;

         RETURN FALSE;
END Validate_visit_histry;

FUNCTION validate_visit_histry_pub(api_visit_rec IGS_PE_VISAPASS_PUB.visit_hstry_rec_type,
                                   p_err_code OUT NOCOPY igs_pe_visa_int.error_code%TYPE) RETURN BOOLEAN IS

  l_visit_rec visit_dtls%ROWTYPE;
  l_return_value BOOLEAN;

  CURSOR visit_visa_dtls(cp_visa_id igs_pe_visa.visa_id%TYPE) IS
  SELECT person_id,visa_issue_date issue_date,visa_expiry_date expiry_date
  FROM  igs_pe_visa
  WHERE visa_id = cp_visa_id;

  visit_visa_rec  visit_visa_dtls%ROWTYPE;

BEGIN

   l_visit_rec.visa_id := api_visit_rec.visa_id;

   OPEN visit_visa_dtls(l_visit_rec.visa_id);
   FETCH visit_visa_dtls INTO visit_visa_rec;
   CLOSE visit_visa_dtls;

   IF visit_visa_rec.issue_date IS NOT NULL THEN
      l_visit_rec.issue_date := visit_visa_rec.issue_date;
      l_visit_rec.expiry_date := visit_visa_rec.expiry_date;
      l_visit_rec.person_id := visit_visa_rec.person_id;
   ELSE
      fnd_message.set_name ('IGS', 'IGS_EN_INV');
      fnd_message.set_token('PARAM','VISA_ID');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
   END IF;

   l_visit_rec.port_of_entry := api_visit_rec.port_of_entry;
   l_visit_rec.cntry_entry_form_num := api_visit_rec.cntry_entry_form_num;

   l_visit_rec.visit_start_date := api_visit_rec.visit_start_date;
   l_visit_rec.visit_end_date := api_visit_rec.visit_end_date;
   l_visit_rec.remarks := api_visit_rec.remarks;

   l_return_value := Validate_visit_histry(visit_rec => l_visit_rec,p_err_code => p_err_code,p_mode => 'PUB');

  return  l_return_value;

END validate_visit_histry_pub;


PROCEDURE prc_pe_visit_histry(
               p_source_type_id  IN NUMBER,
               p_batch_id        IN NUMBER )
 AS
/*
 ||  Created By : gmuralid - Visit Histry Import Process
 ||  Date       : 2-DEC-2002
 ||  Build      : SEVIS
 ||  Bug No     : 2599109

 ||  Change History :
 ||  Who             When            What
 || npalanis         6-JAN-2003      Bug : 2734697
 ||                                  code added to commit after import of every
 ||                                  100 records .New variable l_processed_records added
 || pkpatel          24-FEB-2003     Bug : 2783882
 ||                                  Modified the code for implementing the overlap chack from TBH
 ||  ssaleem       8-OCT-2003       Bug no : 3130316
 ||                                 Performance enhancements done, validations and status
 ||                                 updations done outside the main loop
 || ssaleem        27-AUG-2003      Moved the Validate Record to the package level
 ||
*/

CURSOR chk_duplicate(cp_port_of_entry igs_pe_visit_histry.port_of_entry%TYPE,
                     cp_cntry_entry_form_num igs_pe_visit_histry.cntry_entry_form_num%TYPE) IS
     SELECT rowid,vh.*
     FROM  igs_pe_visit_histry vh
     WHERE port_of_entry = cp_port_of_entry AND
           cntry_entry_form_num = cp_cntry_entry_form_num;


     l_var VARCHAR2(1);
     l_rule VARCHAR2(1);
     l_count NUMBER;
     lvcAction VARCHAR2(1);
     l_error_code VARCHAR2(30);
     l_status VARCHAR2(10);
     l_dup_var BOOLEAN;
     visit_rec  visit_dtls%ROWTYPE;
     l_dup_pe   igs_pe_vst_hist_int.dup_port_of_entry%TYPE;
     l_dup_efn  igs_pe_vst_hist_int.dup_cntry_entry_form_num%TYPE;
     l_processed_records NUMBER(5) := 0;
     -- The below variable will get populated during duplicate check
     l_visit_rec chk_duplicate%ROWTYPE;

     l_prog_label  VARCHAR2(100);
     l_label  VARCHAR2(100);
     l_debug_str VARCHAR2(2000);
     l_enable_log VARCHAR2(1);
     l_request_id NUMBER;
     l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

     PROCEDURE crt_pe_visit_histry(visit_rec IN visit_dtls%ROWTYPE,
                          error_code OUT NOCOPY VARCHAR2,
                          status     OUT NOCOPY VARCHAR2)
      AS
      l_rowid ROWID := NULL;
      l_error VARCHAR2(30);
      l_count NUMBER(5);
      l_message_name  VARCHAR2(30);
      l_app           VARCHAR2(50);

      BEGIN

         SAVEPOINT before_insert;

              igs_pe_visit_histry_pkg.insert_row(
                            X_ROWID                   => l_rowid,
                            X_PORT_OF_ENTRY           => visit_rec.port_of_entry,
                            X_CNTRY_ENTRY_FORM_NUM    => visit_rec.cntry_entry_form_num ,
                            X_VISA_ID                 => visit_rec.visa_id               ,
                            X_VISIT_START_DATE        => visit_rec.visit_start_date      ,
                            X_VISIT_END_DATE          => visit_rec.visit_end_date        ,
                            X_REMARKS                 => visit_rec.remarks               ,
                            X_ATTRIBUTE_CATEGORY      => visit_rec.attribute_category    ,
                            X_ATTRIBUTE1              => visit_rec.attribute1            ,
                            X_ATTRIBUTE2              => visit_rec.attribute2            ,
                            X_ATTRIBUTE3              => visit_rec.attribute3            ,
                            X_ATTRIBUTE4              => visit_rec.attribute4            ,
                            X_ATTRIBUTE5              => visit_rec.attribute5            ,
                            X_ATTRIBUTE6              => visit_rec.attribute6            ,
                            X_ATTRIBUTE7              => visit_rec.attribute7            ,
                            X_ATTRIBUTE8              => visit_rec.attribute8            ,
                            X_ATTRIBUTE9              => visit_rec.attribute9            ,
                            X_ATTRIBUTE10             => visit_rec.attribute10           ,
                            X_ATTRIBUTE11             => visit_rec.attribute11           ,
                            X_ATTRIBUTE12             => visit_rec.attribute12           ,
                            X_ATTRIBUTE13             => visit_rec.attribute13           ,
                            X_ATTRIBUTE14             => visit_rec.attribute14           ,
                            X_ATTRIBUTE15             => visit_rec.attribute15           ,
                            X_ATTRIBUTE16             => visit_rec.attribute16           ,
                            X_ATTRIBUTE17             => visit_rec.attribute17           ,
                            X_ATTRIBUTE18             => visit_rec.attribute18           ,
                            X_ATTRIBUTE19             => visit_rec.attribute19           ,
                            X_ATTRIBUTE20             => visit_rec.attribute20           ,
                            X_MODE                    => 'R');

           --   IF SUCCESSFUL INSERT THEN

              l_error := NULL;
              UPDATE igs_pe_vst_hist_int
              SET status = '1',
              error_code = l_error
              WHERE interface_visit_histry_id   = visit_rec.interface_visit_histry_id;


     EXCEPTION
       WHEN OTHERS THEN
         ROLLBACK TO before_insert;
         FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

        IF l_message_name = 'IGS_PE_PORT_DATE_OVERLAP' THEN
             l_error:='E564';
        ELSE
         l_error := 'E322';

                   -- CALL LOG DETAIL

         IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

               IF (l_request_id IS NULL) THEN
                 l_request_id := fnd_global.conc_request_id;
               END IF;

               l_label := 'igs.plsql.igs_ad_imp_026.crt_pe_visit_histry.exception' || l_error;

               fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
               fnd_message.set_token('INTERFACE_ID',visit_rec.interface_visit_histry_id);
               fnd_message.set_token('ERROR_CD',l_error);

           l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

               fnd_log.string_with_context( fnd_log.level_exception,
                                        l_label,
                                l_debug_str, NULL,
                            NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
              END IF;

            END IF;

            IF l_enable_log = 'Y' THEN
               igs_ad_imp_001.logerrormessage(visit_rec.interface_visit_histry_id,l_error,'IGS_PE_VST_HIST_INT');
            END IF;

            UPDATE igs_pe_vst_hist_int
            SET status = '3',
                error_code = l_error
            WHERE interface_visit_histry_id   = visit_rec.interface_visit_histry_id;

      END crt_pe_visit_histry;

    -- START local procedure for updating existing record based on discepancy rule

       PROCEDURE upd_pe_visit_histry( visit_rec     IN visit_dtls%ROWTYPE,
                                      dup_visit_rec IN chk_duplicate%ROWTYPE,
                                      p_error_code  OUT NOCOPY VARCHAR2,
                                      p_status      OUT NOCOPY VARCHAR2)
        AS

         l_error VARCHAR2(30);
         l_message_name  VARCHAR2(30);
         l_app           VARCHAR2(50);
         l_visit_end_date  igs_pe_visit_histry.visit_end_date%TYPE;

         BEGIN

               SAVEPOINT before_update;

               l_visit_end_date := NVL(visit_rec.visit_end_date,dup_visit_rec.visit_end_date);

                IF visit_rec.visa_id <> dup_visit_rec.visa_id THEN
                  IF visit_rec.visit_end_date IS NULL THEN
                    l_visit_end_date := NULL;
                  END IF;
                END IF;

               igs_pe_visit_histry_pkg.update_row(
                                 X_ROWID                    => dup_visit_rec.rowid,
                                 X_PORT_OF_ENTRY            => NVL(visit_rec.port_of_entry,dup_visit_rec.port_of_entry),
                                 X_CNTRY_ENTRY_FORM_NUM     => NVL(visit_rec.cntry_entry_form_num,dup_visit_rec.cntry_entry_form_num),
                                 X_VISA_ID                  => NVL(visit_rec.visa_id ,dup_visit_rec.visa_id),
                                 X_VISIT_START_DATE         => NVL(visit_rec.visit_start_date,dup_visit_rec.visit_start_date),
                                 X_VISIT_END_DATE           => l_visit_end_date,
                                 X_REMARKS                  => NVL(visit_rec.remarks,dup_visit_rec.remarks),
                                 X_ATTRIBUTE_CATEGORY       => NVL(visit_rec.attribute_category,dup_visit_rec.attribute_category),
                                 X_ATTRIBUTE1               => NVL(visit_rec.attribute1,dup_visit_rec.attribute1),
                                 X_ATTRIBUTE2               => NVL(visit_rec.attribute2,dup_visit_rec.attribute2),
                                 X_ATTRIBUTE3               => NVL(visit_rec.attribute3,dup_visit_rec.attribute3),
                                 X_ATTRIBUTE4               => NVL(visit_rec.attribute4,dup_visit_rec.attribute4),
                                 X_ATTRIBUTE5               => NVL(visit_rec.attribute5,dup_visit_rec.attribute5),
                                 X_ATTRIBUTE6               => NVL(visit_rec.attribute6,dup_visit_rec.attribute6),
                                 X_ATTRIBUTE7               => NVL(visit_rec.attribute7,dup_visit_rec.attribute7),
                                 X_ATTRIBUTE8               => NVL(visit_rec.attribute8,dup_visit_rec.attribute8),
                                 X_ATTRIBUTE9               => NVL(visit_rec.attribute9,dup_visit_rec.attribute9),
                                 X_ATTRIBUTE10              => NVL(visit_rec.attribute10,dup_visit_rec.attribute10),
                                 X_ATTRIBUTE11              => NVL(visit_rec.attribute11,dup_visit_rec.attribute11),
                                 X_ATTRIBUTE12              => NVL(visit_rec.attribute12,dup_visit_rec.attribute12),
                                 X_ATTRIBUTE13              => NVL(visit_rec.attribute13,dup_visit_rec.attribute13),
                                 X_ATTRIBUTE14              => NVL(visit_rec.attribute14,dup_visit_rec.attribute14),
                                 X_ATTRIBUTE15              => NVL(visit_rec.attribute15,dup_visit_rec.attribute15),
                                 X_ATTRIBUTE16              => NVL(visit_rec.attribute16,dup_visit_rec.attribute16),
                                 X_ATTRIBUTE17              => NVL(visit_rec.attribute17,dup_visit_rec.attribute17),
                                 X_ATTRIBUTE18              => NVL(visit_rec.attribute18,dup_visit_rec.attribute18),
                                 X_ATTRIBUTE19              => NVL(visit_rec.attribute19,dup_visit_rec.attribute19),
                                 X_ATTRIBUTE20              => NVL(visit_rec.attribute20,dup_visit_rec.attribute20),
                                 X_MODE                     => 'R');

                       p_error_code := NULL;
                       p_status := '1';

       EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK TO before_update;
            FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

            IF l_message_name = 'IGS_PE_PORT_DATE_OVERLAP' THEN
                p_error_code := 'E564';
                p_status := '3';

            UPDATE igs_pe_vst_hist_int
                SET status = '3',
                    error_code = 'E014'
                WHERE interface_visit_histry_id   = visit_rec.interface_visit_histry_id;

            ELSE

                p_error_code := 'E014';
                p_status := '3';

                UPDATE igs_pe_vst_hist_int
                SET status = '3',
                error_code = 'E014'
                WHERE interface_visit_histry_id   = visit_rec.interface_visit_histry_id;

                       -- CALL LOG DETAIL
               IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
                            l_request_id := fnd_global.conc_request_id;
                        END IF;

                        l_label := 'igs.plsql.igs_ad_imp_026.upd_pe_visit_histry.exception' || 'E014';

                        fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                        fnd_message.set_token('INTERFACE_ID',visit_rec.interface_visit_histry_id);
                        fnd_message.set_token('ERROR_CD','E014');

                    l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

                        fnd_log.string_with_context( fnd_log.level_exception,
                                                 l_label,
                                     l_debug_str, NULL,
                                     NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
               END IF;

               IF l_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(visit_rec.interface_visit_histry_id,l_error,'IGS_PE_VST_HIST_INT');
               END IF;

            END IF;
       END upd_pe_visit_histry;

       --MAIN PROCEDURE BEGINS NOW

BEGIN

  l_prog_label := 'igs.plsql.igs_ad_imp_026.prc_pe_visit_histry';
  l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_visit_histry.';
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;

  l_rule :=igs_ad_imp_001.find_source_cat_rule(p_source_type_id,'PERSON_INTERNATIONAL_DETAILS');

        IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

           IF (l_request_id IS NULL) THEN
                l_request_id := fnd_global.conc_request_id;
           END IF;

           l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_visit_histry.begin';
       l_debug_str :=  'IGS_AD_IMP_026.prc_pe_visit_histry';

           fnd_log.string_with_context( fnd_log.level_procedure,
                                    l_label,
                                    l_debug_str, NULL,
                        NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;

        IF l_rule = 'E' OR l_rule = 'I' THEN

           UPDATE igs_pe_vst_hist_int
           SET status='3',
               error_code = 'E695'
           WHERE
               interface_run_id=l_interface_run_id
           AND  STATUS = '2'
           AND  match_ind IS NOT NULL;


        IF l_rule = 'E' THEN

              UPDATE igs_pe_vst_hist_int vh
              SET status='1',
                  match_ind='19'
              WHERE interface_run_id=l_interface_run_id
              AND STATUS = '2'
              AND EXISTS( SELECT vs.rowid
                      FROM   igs_pe_visit_histry vs
                      WHERE  vs.port_of_entry = UPPER(vh.port_of_entry) AND
                             UPPER(vs.cntry_entry_form_num) = UPPER(vh.cntry_entry_form_num))
          AND EXISTS( SELECT vi.rowid
                      FROM   igs_pe_visa_int vi
                      WHERE  vi.interface_visa_id = vh.interface_visa_id AND
                             vi.status = '1');
           END IF;

        ELSIF  l_rule = 'R' THEN

              UPDATE igs_pe_vst_hist_int vh
              SET status = '1'
              WHERE interface_run_id=l_interface_run_id
              AND  status = '2'
              AND  match_ind IN ('18','19','22','23')
              AND  EXISTS( SELECT vi.rowid
                       FROM   igs_pe_visa_int vi
                       WHERE  vi.interface_visa_id = vh.interface_visa_id AND
                              vi.status = '1');

              UPDATE igs_pe_vst_hist_int vh
              SET status = '3',
                  error_code = 'E695'
              WHERE interface_run_id=l_interface_run_id
              AND  status = '2'
              AND ( match_ind IS NOT NULL  AND match_ind <> '21' AND match_ind <> '25')
              AND  EXISTS( SELECT vi.rowid
                           FROM   igs_pe_visa_int vi
                           WHERE  vi.interface_visa_id = vh.interface_visa_id AND
                                  vi.status = '1');

              UPDATE igs_pe_vst_hist_int vh
              SET status='1',
                  match_ind = '23'
              WHERE interface_run_id=l_interface_run_id
              AND status = '2'
              AND match_ind IS NULL
              AND EXISTS( SELECT vi.rowid
                          FROM   igs_pe_visa_int vi
                          WHERE  vi.interface_visa_id = vh.interface_visa_id AND
                                 vi.status = '1')
              AND EXISTS( SELECT vs.rowid
                          FROM   igs_pe_visit_histry vs  ,
                                 igs_pe_visa pev
              WHERE  vs.visa_id = pev.visa_id AND
                     vs.port_of_entry = UPPER(vh.port_of_entry) AND
                     UPPER(vs.cntry_entry_form_num) = UPPER(vh.cntry_entry_form_num) AND
                                 TRUNC(vs.visit_start_date) = TRUNC(vh.visit_start_date) AND
                                 ((TRUNC(vs.visit_end_date) = TRUNC(vh.visit_end_date)) OR ((vs.visit_end_date IS NULL) AND (vh.visit_end_date IS NULL))) AND
                                 ((UPPER(vs.remarks) = UPPER(vh.remarks)) OR ((vs.remarks IS NULL) AND (vh.remarks IS NULL))) AND
                                 ((vs.attribute_category = vh.attribute_category) OR ((vs.attribute_category IS NULL) AND (vh.attribute_category IS NULL))) AND
                                 ((vs.attribute1 = vh.attribute1) OR ((vs.attribute1 IS NULL) AND (vh.attribute1 IS NULL))) AND
                                 ((vs.attribute2 = vh.attribute2) OR ((vs.attribute2 IS NULL) AND (vh.attribute2 IS NULL))) AND
                                 ((vs.attribute3 = vh.attribute3) OR ((vs.attribute3 IS NULL) AND (vh.attribute3 IS NULL))) AND
                                 ((vs.attribute4 = vh.attribute4) OR ((vs.attribute4 IS NULL) AND (vh.attribute4 IS NULL))) AND
                                 ((vs.attribute5 = vh.attribute5) OR ((vs.attribute5 IS NULL) AND (vh.attribute5 IS NULL))) AND
                                 ((vs.attribute6 = vh.attribute6) OR ((vs.attribute6 IS NULL) AND (vh.attribute6 IS NULL))) AND
                                 ((vs.attribute7 = vh.attribute7) OR ((vs.attribute7 IS NULL) AND (vh.attribute7 IS NULL))) AND
                                 ((vs.attribute8 = vh.attribute8) OR ((vs.attribute8 IS NULL) AND (vh.attribute8 IS NULL))) AND
                                 ((vs.attribute9 = vh.attribute9) OR ((vs.attribute9 IS NULL) AND (vh.attribute9 IS NULL))) AND
                                 ((vs.attribute10 = vh.attribute10) OR ((vs.attribute10 IS NULL) AND (vh.attribute10 IS NULL))) AND
                                 ((vs.attribute11 = vh.attribute11) OR ((vs.attribute11 IS NULL) AND (vh.attribute11 IS NULL))) AND
                                 ((vs.attribute12 = vh.attribute12) OR ((vs.attribute12 IS NULL) AND (vh.attribute12 IS NULL))) AND
                                 ((vs.attribute13 = vh.attribute13) OR ((vs.attribute13 IS NULL) AND (vh.attribute13 IS NULL))) AND
                                 ((vs.attribute14 = vh.attribute14) OR ((vs.attribute14 IS NULL) AND (vh.attribute14 IS NULL))) AND
                                 ((vs.attribute15 = vh.attribute15) OR ((vs.attribute15 IS NULL) AND (vh.attribute15 IS NULL))) AND
                                 ((vs.attribute16 = vh.attribute16) OR ((vs.attribute16 IS NULL) AND (vh.attribute16 IS NULL))) AND
                                 ((vs.attribute17 = vh.attribute17) OR ((vs.attribute17 IS NULL) AND (vh.attribute17 IS NULL))) AND
                                 ((vs.attribute18 = vh.attribute18) OR ((vs.attribute18 IS NULL) AND (vh.attribute18 IS NULL))) AND
                                 ((vs.attribute19 = vh.attribute19) OR ((vs.attribute19 IS NULL) AND (vh.attribute19 IS NULL))) AND
                                 ((vs.attribute20 = vh.attribute20) OR ((vs.attribute20 IS NULL) AND (vh.attribute20 IS NULL))));

              UPDATE igs_pe_vst_hist_int vh
              SET status = '3',
                  match_ind='20',
              (dup_port_of_entry,dup_cntry_entry_form_num) = (SELECT  port_of_entry,cntry_entry_form_num
                           FROM igs_pe_visit_histry vs
                           WHERE vs.port_of_entry = UPPER(vh.port_of_entry) AND
                                 UPPER(vs.cntry_entry_form_num) = UPPER(vh.cntry_entry_form_num))
              WHERE interface_run_id=l_interface_run_id AND
                    status = '2' AND
              EXISTS( SELECT vsi.rowid
                      FROM   igs_pe_visa_int vsi
                      WHERE  vsi.interface_visa_id = vh.interface_visa_id AND
                             vsi.status = '1') AND
                             match_ind IS NULL AND
             EXISTS (SELECT rowid
                     FROM igs_pe_visit_histry
                     WHERE port_of_entry = UPPER(vh.port_of_entry) AND
                    UPPER(cntry_entry_form_num) = UPPER(vh.cntry_entry_form_num) );
        END IF;

    FOR visit_rec in visit_dtls('2','1',l_interface_run_id) LOOP

          l_processed_records := l_processed_records + 1;

          visit_rec.port_of_entry := UPPER(visit_rec.port_of_entry);
          visit_rec.visit_end_date := TRUNC(visit_rec.visit_end_date);
          visit_rec.visit_start_date := TRUNC(visit_rec.visit_start_date);


          IF Validate_visit_histry(visit_rec => visit_rec, p_err_code => l_error_code) THEN

           l_dup_var := FALSE;
           l_visit_rec.port_of_entry := NULL;
           OPEN chk_duplicate(visit_rec.port_of_entry,visit_rec.cntry_entry_form_num);
               FETCH chk_duplicate INTO l_visit_rec;
               CLOSE chk_duplicate;

               IF l_visit_rec.port_of_entry  IS NOT NULL THEN
                 l_dup_var := TRUE;
               END IF;

               IF l_dup_var THEN
                 -- IF DUPLICATE RECORDS FOUND THEN FOLLOW DISCREPANCY RULE,GMURALD
                    IF l_rule = 'I' THEN
                      BEGIN
                        upd_pe_visit_histry(visit_rec => visit_rec,
                                dup_visit_rec => l_visit_rec,
                                            p_error_code => l_error_code,
                                            p_status => l_status );

                        UPDATE igs_pe_vst_hist_int
                        SET match_ind = '18',  -- MATCH OCCURED AND USED IMPORTED VALUES
                            status = l_status ,
                            error_code = l_error_code
                        WHERE interface_visit_histry_id = visit_rec.interface_visit_histry_id;

                        EXCEPTION
                             WHEN OTHERS THEN

                          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                                IF (l_request_id IS NULL) THEN
                                  l_request_id := fnd_global.conc_request_id;
                                END IF;

                                l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_visit_histry.exception' || 'E014';

                                fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                                fnd_message.set_token('INTERFACE_ID',visit_rec.interface_visit_histry_id);
                                fnd_message.set_token('ERROR_CD','E014');

                            l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

                                fnd_log.string_with_context( fnd_log.level_exception,
                                                         l_label,
                                             l_debug_str, NULL,
                                             NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                              END IF;

                              IF l_enable_log = 'Y' THEN
                                igs_ad_imp_001.logerrormessage(visit_rec.interface_visit_histry_id,'E014','IGS_PE_VST_HIST_INT');
                              END IF;

                               UPDATE igs_pe_vst_hist_int
                               SET match_ind = '18',
                                   status = '3',
                                   error_code = 'E014'
                               WHERE interface_visit_histry_id = visit_rec.interface_visit_histry_id;
                        END;


                       ELSIF l_rule = 'R' THEN   -- MATCH REVIEWED TO BE IMPORTED
                           IF visit_rec.match_ind = '21' THEN
                              BEGIN
                                 upd_pe_visit_histry(visit_rec => visit_rec,
                                     dup_visit_rec => l_visit_rec,
                                                     p_error_code => l_error_code,
                                                     p_status => l_status);

                                  UPDATE igs_pe_vst_hist_int
                                  SET status = l_status ,
                                      error_code = l_error_code
                                   WHERE interface_visit_histry_id = visit_rec.interface_visit_histry_id;

                                EXCEPTION
                                  WHEN OTHERS THEN

                               IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                                      IF (l_request_id IS NULL) THEN
                                         l_request_id := fnd_global.conc_request_id;
                                      END IF;

                                      l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_visit_histry.exception1' || 'E014';

                                      fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                                      fnd_message.set_token('INTERFACE_ID',visit_rec.interface_visit_histry_id);
                                      fnd_message.set_token('ERROR_CD','E014');

                                  l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

                                      fnd_log.string_with_context( fnd_log.level_exception,
                                                               l_label,
                                                   l_debug_str, NULL,
                                                   NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                                   END IF;

                               IF l_enable_log = 'Y' THEN
                                      igs_ad_imp_001.logerrormessage(visit_rec.interface_visit_histry_id,'E014','IGS_PE_VST_HIST_INT');
                                   END IF;

                                    UPDATE igs_pe_vst_hist_int
                                    SET status = '3',
                                    error_code = 'E014'
                                    WHERE interface_visit_histry_id = visit_rec.interface_visit_histry_id;
                               END;
                              END IF;
                          END IF;
                       ELSE
                          crt_pe_visit_histry(visit_rec  => visit_rec,
                                      error_code => l_error_code,
                                      status  => l_status) ;
                      END IF;
                 END IF;

                 IF l_processed_records = 100 THEN
                     COMMIT;
                     l_processed_records := 0;
                 END IF;

            END LOOP;
END prc_pe_visit_histry;

PROCEDURE prc_pe_eit(
          p_source_type_id  IN NUMBER,
          p_batch_id        IN NUMBER )
AS
/*
 ||  Created By : gmuralid - Residence details import process
 ||  Date       : 2-DEC-2002
 ||  Build      : SEVIS
 ||  Bug No     : 2599109

 ||  Change History :
 ||  Who             When            What
 || npalanis         6-JAN-2003      Bug : 2734697
 ||                                  code added to commit after import of every
 ||                                  100 records .New variable l_processed_records added
 ||
 ||  ssaleem       8-OCT-2003       Bug no : 3130316
 ||                                 Performance enhancements done, validations and status
 ||                                 updations done outside the main loop
*/


CURSOR chk_duplicate(cp_person_id   igs_pe_eit.person_id%TYPE,
                     cp_information_type  igs_pe_eit.information_type%TYPE,
             cp_start_date igs_pe_eit.start_date%TYPE)
IS
      SELECT rowid,ei.*
      FROM  igs_pe_eit ei
      WHERE person_id = cp_person_id AND
            UPPER(information_type) = UPPER(cp_information_type) AND
            TRUNC(start_date) = TRUNC(cp_start_date) ;

CURSOR eit_dtls(cp_ei_status_2 igs_pe_eit_int.status%TYPE,
                cp_interface_run_id igs_pe_eit_int.interface_run_id%TYPE,
        cp_information_type igs_pe_eit_int.information_type%TYPE)  IS

     SELECT ei.*, i.person_id
     FROM igs_pe_eit_int ei,
          igs_ad_interface_all i
     WHERE ei.interface_id = i.interface_id
          AND  ei.STATUS = cp_ei_status_2
          AND  ei.interface_run_id = cp_interface_run_id
      AND  i.interface_run_id = cp_interface_run_id
          AND  ei.information_type =cp_information_type;

     l_var VARCHAR2(1);
     l_rule VARCHAR2(1);
     l_count NUMBER;
     lvcAction VARCHAR2(1);
     l_error_code VARCHAR2(10);
     l_status VARCHAR2(10);
     l_dup_var BOOLEAN;
     eit_rec  eit_dtls%ROWTYPE;
     l_dup_id igs_pe_eit.pe_eit_id%TYPE;
     l_processed_records NUMBER(5) := 0;
     l_eit_rec chk_duplicate%ROWTYPE;

     l_prog_label  VARCHAR2(100);
     l_label  VARCHAR2(100);
     l_debug_str VARCHAR2(2000);
     l_enable_log VARCHAR2(1);
     l_request_id NUMBER;
     l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

     FUNCTION validate_record(eit_rec IN eit_dtls%ROWTYPE)
        RETURN BOOLEAN IS

          CURSOR birth_dt_cur(cp_person_id igs_ad_interface.person_id%TYPE) IS
          SELECT BIRTH_DATE Birth_dt
          FROM IGS_PE_PERSON_BASE_V
          WHERE
          person_id = cp_person_id;

          l_error VARCHAR2(30);
          l_birth_date IGS_AD_INTERFACE.BIRTH_DT%TYPE;

         BEGIN
            --BEGIN OF VALIDATE RECORD FUNCTION

          -- start validations

          l_error := NULL;

          IF eit_rec.pei_information1 IS NOT NULL THEN
        IF NOT
        (igs_pe_pers_imp_001.validate_country_code(eit_rec.pei_information1))   -- change for country code inconsistency bug 3738488
        THEN
              l_error := 'E566';
              RAISE no_data_found;
            END IF;
          END IF;


          IF eit_rec.end_date IS NOT NULL THEN
            IF eit_rec.start_date > eit_rec.end_date THEN
              l_error := 'E568';
              RAISE no_data_found;
            END IF;
          END IF;

          OPEN birth_dt_cur(eit_rec.person_id);
          FETCH birth_dt_cur INTO l_birth_date;
          IF l_birth_date IS NOT NULL THEN
            IF eit_rec.start_date < l_birth_date THEN
              l_error := 'E569';
              RAISE no_data_found;
            END IF;

            IF eit_rec.end_date IS NOT NULL THEN
               IF eit_rec.end_date < l_birth_date THEN
                 l_error := 'E570';
                 RAISE no_data_found;
               END IF;
            END IF;
          END IF;
          CLOSE birth_dt_cur;

          --ALL VALIDATIONS ARE OK

          l_error := NULL;

          UPDATE igs_pe_eit_int
          SET status = '1',
              error_code = l_error
          WHERE interface_eit_id  = eit_rec.interface_eit_id;

          RETURN TRUE;

           EXCEPTION
              WHEN NO_DATA_FOUND THEN

                IF birth_dt_cur%ISOPEN THEN
                  CLOSE birth_dt_cur;
                END IF;

                UPDATE igs_pe_eit_int
                SET status = '3',
                error_code = l_error
                WHERE interface_eit_id  = eit_rec.interface_eit_id;

                IF l_enable_log = 'Y' THEN
                   igs_ad_imp_001.logerrormessage(eit_rec.interface_eit_id,l_error,'IGS_PE_EIT_INT');
                END IF;

                RETURN FALSE;

            WHEN OTHERS THEN
                UPDATE igs_pe_eit_int
                SET status = '3',
                error_code = l_error
                WHERE interface_eit_id  = eit_rec.interface_eit_id;

            -- CALL LOG DETAIL

               IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                  IF (l_request_id IS NULL) THEN
                     l_request_id := fnd_global.conc_request_id;
                  END IF;

                  l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_eit.val_exception' || l_error;

                  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                  fnd_message.set_token('INTERFACE_ID',eit_rec.interface_eit_id);
                  fnd_message.set_token('ERROR_CD',l_error);

                  l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

                  fnd_log.string_with_context( fnd_log.level_exception,
                                               l_label,
                                   l_debug_str, NULL,
                                   NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
               END IF;

               IF l_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(eit_rec.interface_eit_id,l_error,'IGS_PE_EIT_INT');
               END IF;

        RETURN FALSE;
     END Validate_Record;


     PROCEDURE crt_pe_eit( eit_rec    IN eit_dtls%ROWTYPE,
                           error_code OUT NOCOPY VARCHAR2,
                           status     OUT NOCOPY VARCHAR2)
      AS

      l_rowid ROWID := NULL;
      l_error VARCHAR2(30);
      l_eit_id igs_pe_eit.pe_eit_id%TYPE;
      l_count   NUMBER(5);

          CURSOR date_overlap(cp_eit_rec  eit_dtls%ROWTYPE,
                          cp_end_date VARCHAR2) IS
          SELECT count(1) FROM IGS_PE_EIT
          WHERE person_id = cp_eit_rec.person_id
          AND INFORMATION_TYPE = cp_eit_rec.information_type
          AND (NVL(cp_eit_rec.end_date,IGS_GE_DATE.igsdate(cp_end_date)) BETWEEN START_DATE AND NVL(END_DATE,IGS_GE_DATE.igsdate(cp_end_date))
          OR
          cp_eit_rec.start_date BETWEEN START_DATE AND NVL(END_DATE,IGS_GE_DATE.igsdate(cp_end_date))
          OR
          ( cp_eit_rec.start_date < START_DATE AND
            NVL(end_date,IGS_GE_DATE.igsdate(cp_end_date))< NVL(cp_eit_rec.end_date,IGS_GE_DATE.igsdate(cp_end_date)) ) );

       BEGIN
          --CALL TO EIT INSERT RECORD

          OPEN date_overlap(eit_rec,'9999/01/01');
          FETCH date_overlap INTO l_count;
          CLOSE date_overlap;

          IF l_count > 0 THEN

               l_error := 'E571';
               UPDATE igs_pe_eit_int
               SET status = '3',
               error_code = l_error
               WHERE interface_eit_id  = eit_rec.interface_eit_id;

            -- CALL LOG DETAIL

               IF l_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(eit_rec.interface_eit_id,l_error,'IGS_PE_EIT_INT');
               END IF;

          ELSE
                  igs_pe_eit_pkg.insert_row(
                              X_ROWID              => l_rowid,
                              X_PE_EIT_ID          => l_eit_id,
                              X_PERSON_ID          => eit_rec.person_id           ,
                              X_INFORMATION_TYPE   => eit_rec.information_type    ,
                              X_PEI_INFORMATION1   => eit_rec.pei_information1    ,
                              X_PEI_INFORMATION2   => eit_rec.pei_information2    ,
                              X_PEI_INFORMATION3   => eit_rec.pei_information3    ,
                              X_PEI_INFORMATION4   => eit_rec.pei_information4    ,
                              X_PEI_INFORMATION5   => eit_rec.pei_information5    ,
                              X_START_DATE         => eit_rec.start_date          ,
                              X_END_DATE           => eit_rec.end_date            ,
                              X_MODE               => 'R'
                                             );

                    --   IF SUCCESSFUL INSERT THEN

                          l_error := NULL;
                          UPDATE igs_pe_eit_int
                          SET status = '1',
                          error_code = l_error
                          WHERE interface_eit_id  = eit_rec.interface_eit_id;
            END IF;

            EXCEPTION
               WHEN OTHERS THEN
               l_error := 'E322';
               UPDATE igs_pe_eit_int
               SET status = '3',
               error_code = l_error
               WHERE interface_eit_id  = eit_rec.interface_eit_id;

            -- CALL LOG DETAIL

               IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                  IF (l_request_id IS NULL) THEN
                     l_request_id := fnd_global.conc_request_id;
                  END IF;

                  l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_eit.crt_exception' || l_error;

                  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                  fnd_message.set_token('INTERFACE_ID',eit_rec.interface_eit_id);
                  fnd_message.set_token('ERROR_CD',l_error);

                  l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

                  fnd_log.string_with_context( fnd_log.level_exception,
                                               l_label,
                                   l_debug_str, NULL,
                                   NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
               END IF;

               IF l_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(eit_rec.interface_eit_id,l_error,'IGS_PE_EIT_INT');
               END IF;

     END crt_pe_eit;

    -- START local procedure for updating existing record based on discepancy rule;

    PROCEDURE upd_pe_eit(  eit_rec       IN eit_dtls%ROWTYPE,
                           dup_eit_rec     IN chk_duplicate%ROWTYPE,
                           p_error_code  OUT NOCOPY VARCHAR2,
                           p_status      OUT NOCOPY VARCHAR2)
     AS


      l_error VARCHAR2(30);

      l_count   NUMBER(5);

          CURSOR date_overlap(cp_eit_rec   eit_dtls%ROWTYPE,
                          cp_end_date  VARCHAR2 ) IS
          SELECT count(1) FROM IGS_PE_EIT
          WHERE person_id = cp_eit_rec.person_id
          AND information_type = cp_eit_rec.information_type
          AND start_date <> cp_eit_rec.start_date
          AND (NVL(cp_eit_rec.end_date,IGS_GE_DATE.igsdate(cp_end_date)) BETWEEN START_DATE AND NVL(END_DATE,IGS_GE_DATE.igsdate(cp_end_date))
          OR
          cp_eit_rec.start_date BETWEEN START_DATE AND NVL(END_DATE,IGS_GE_DATE.igsdate(cp_end_date))
          OR
          ( cp_eit_rec.start_date < START_DATE AND
            NVL(end_date,IGS_GE_DATE.igsdate(cp_end_date))< NVL(cp_eit_rec.end_date,IGS_GE_DATE.igsdate(cp_end_date)) ) );

       BEGIN
          --CALL TO EIT INSERT RECORD

          OPEN date_overlap(eit_rec,'9999/01/01');
          FETCH date_overlap INTO l_count;
          CLOSE date_overlap;

          IF l_count > 0 THEN

               l_error := 'E571';

               p_error_code := l_error;
               p_status := '3';

               UPDATE igs_pe_eit_int
               SET status = '3',
               error_code = l_error
               WHERE interface_eit_id  = eit_rec.interface_eit_id;

            -- CALL LOG DETAIL

           IF l_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(eit_rec.interface_eit_id,l_error,'IGS_PE_EIT_INT');
               END IF;

          ELSE

                    --  MAKE CALL TO THE TBH i.e IGS_PE_EIT_PKG.UPDATE_ROW

                    igs_pe_eit_pkg.update_row(
                                X_ROWID               => dup_eit_rec.rowid,
                                X_PE_EIT_ID           => dup_eit_rec.pe_eit_id,
                                X_PERSON_ID           => NVL(eit_rec.person_id,dup_eit_rec.person_id),
                                X_INFORMATION_TYPE    => NVL(eit_rec.information_type,dup_eit_rec.information_type),
                                X_PEI_INFORMATION1    => NVL(eit_rec.pei_information1,dup_eit_rec.pei_information1) ,
                                X_PEI_INFORMATION2    => NVL(eit_rec.pei_information2,dup_eit_rec.pei_information2) ,
                                X_PEI_INFORMATION3    => NVL(eit_rec.pei_information3,dup_eit_rec.pei_information3) ,
                                X_PEI_INFORMATION4    => NVL(eit_rec.pei_information4,dup_eit_rec.pei_information4) ,
                                X_PEI_INFORMATION5    => NVL(eit_rec.pei_information5,dup_eit_rec.pei_information5) ,
                                X_START_DATE          => NVL(eit_rec.start_date,dup_eit_rec.start_date),
                                X_END_DATE            => NVL(eit_rec.end_date,dup_eit_rec.end_date),
                                X_MODE                => 'R');

                            p_error_code := NULL;
                            p_status := '1';
           END IF;

                 EXCEPTION
                     WHEN OTHERS THEN
                        p_error_code := 'E014';
                        p_status := '3';

                     UPDATE igs_pe_eit_int
                     SET status = '3',
                     error_code = 'E014'
                     WHERE interface_eit_id  = eit_rec.interface_eit_id;

                    -- CALL LOG DETAIL

               IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                  IF (l_request_id IS NULL) THEN
                     l_request_id := fnd_global.conc_request_id;
                  END IF;

                  l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_eit.upd_exception' || 'E014';

                  fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
                  fnd_message.set_token('INTERFACE_ID',eit_rec.interface_eit_id);
                  fnd_message.set_token('ERROR_CD','E014');

                  l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

                  fnd_log.string_with_context( fnd_log.level_exception,
                                               l_label,
                                   l_debug_str, NULL,
                                   NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
               END IF;

               IF l_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(eit_rec.interface_eit_id,'E014','IGS_PE_EIT_INT');
               END IF;

    END upd_pe_eit;

  --MAIN PROCEDURE BEGINS NOW

  BEGIN

   l_prog_label := 'igs.plsql.igs_ad_imp_026.prc_pe_eit';
   l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_eit.';
   l_enable_log := igs_ad_imp_001.g_enable_log;
   l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
   IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

        IF (l_request_id IS NULL) THEN
               l_request_id := fnd_global.conc_request_id;
        END IF;

        l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_eit.begin';
        l_debug_str :=  'IGS_AD_IMP_026.prc_pe_eit';

        fnd_log.string_with_context( fnd_log.level_procedure,
                                     l_label,
                                 l_debug_str, NULL,
                         NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
   END IF;

   l_rule :=igs_ad_imp_001.find_source_cat_rule(p_source_type_id,'PERSON_INTERNATIONAL_DETAILS');

   IF l_rule = 'E' OR l_rule = 'I' THEN

     UPDATE igs_pe_eit_int
     SET status='3',
         error_code = 'E695'
     WHERE interface_run_id=l_interface_run_id
     AND  STATUS = '2'
     AND  UPPER(information_type) ='PE_INT_PERM_RES'
     AND  match_ind IS NOT NULL;

     IF l_rule = 'E' THEN

        UPDATE igs_pe_eit_int ei
    SET status='1',
        match_ind='19'
    WHERE interface_run_id=l_interface_run_id
        AND STATUS = '2'
        AND UPPER(information_type) ='PE_INT_PERM_RES'
    AND EXISTS( SELECT es.rowid
                FROM   igs_pe_eit es,
                       igs_ad_interface_all ad
                WHERE  ad.interface_id = ei.interface_id AND
                       es.person_id = ad.person_id AND
                       ad.interface_run_id = l_interface_run_id AND
                       es.information_type = UPPER(ei.information_type) AND
                       es.start_date = TRUNC(ei.start_date));
     END IF;

  ELSIF  l_rule = 'R' THEN

     UPDATE igs_pe_eit_int
     SET status = '1'
     WHERE interface_run_id=l_interface_run_id
     AND status = '2'
     AND UPPER(information_type) ='PE_INT_PERM_RES'
     AND match_ind IN ('18','19','22','23');

     UPDATE igs_pe_eit_int
     SET status = '3',
         error_code = 'E695'
     WHERE interface_run_id=l_interface_run_id
     AND status = '2'
     AND UPPER(information_type) ='PE_INT_PERM_RES'
     AND ( match_ind IS NOT NULL  AND match_ind <> '21' AND match_ind <> '25');

     UPDATE igs_pe_eit_int ei
     SET status='1',
         match_ind = '23'
     WHERE interface_run_id=l_interface_run_id
     AND status = '2'
     AND UPPER(information_type) ='PE_INT_PERM_RES'
     AND match_ind IS NULL
     AND EXISTS( SELECT es.rowid
                 FROM igs_pe_eit es,
              igs_ad_interface_all ad
                 WHERE ad.interface_id = ei.interface_id AND
                   es.person_id = ad.person_id AND
               ad.interface_run_id = l_interface_run_id AND
               es.information_type = UPPER(ei.information_type) AND
               TRUNC(es.start_date) = TRUNC(ei.start_date) AND
                       ((UPPER(es.pei_information1) = UPPER(ei.pei_information1)) OR ((es.pei_information1 IS NULL) AND (ei.pei_information1 IS NULL))) AND
                       ((UPPER(es.pei_information2) = UPPER(ei.pei_information2)) OR ((es.pei_information2 IS NULL) AND (ei.pei_information2 IS NULL))) AND
                       ((UPPER(es.pei_information3) = UPPER(ei.pei_information3)) OR ((es.pei_information3 IS NULL) AND (ei.pei_information3 IS NULL))) AND
                       ((UPPER(es.pei_information4) = UPPER(ei.pei_information4)) OR ((es.pei_information4 IS NULL) AND (ei.pei_information4 IS NULL))) AND
                       ((UPPER(es.pei_information5) = UPPER(ei.pei_information5)) OR ((es.pei_information5 IS NULL) AND (ei.pei_information5 IS NULL))) AND
                       ((TRUNC(es.end_date) = TRUNC(ei.end_date)) OR ((es.end_date IS NULL) AND (ei.end_date IS NULL))));

     UPDATE igs_pe_eit_int ei
     SET status = '3',
         match_ind='20',
     dup_pe_eit_id = (SELECT pe_eit_id
              FROM igs_pe_eit es,
                   igs_ad_interface_all ad
              WHERE  ad.interface_id = ei.interface_id AND
                         es.person_id = ad.person_id AND
                         ad.interface_run_id = l_interface_run_id AND
                         es.information_type = UPPER(ei.information_type) AND
                         es.start_date = TRUNC(ei.start_date) )
     WHERE interface_run_id=l_interface_run_id AND
       status = '2' AND
           information_type ='PE_INT_PERM_RES'  AND
           match_ind IS NULL AND
       EXISTS (SELECT es.rowid
               FROM igs_pe_eit es,
                        igs_ad_interface_all ad
               WHERE  ad.interface_id = ei.interface_id AND
                      es.person_id = ad.person_id AND
                  ad.interface_run_id = l_interface_run_id AND
                  es.information_type = UPPER(ei.information_type) AND
                  es.start_date = TRUNC(ei.start_date) );
   END IF;


   FOR eit_rec in eit_dtls('2',l_interface_run_id,'PE_INT_PERM_RES') LOOP

    l_processed_records := l_processed_records + 1;

    eit_rec.pei_information1 := UPPER(eit_rec.pei_information1);
    eit_rec.start_date :=  TRUNC(eit_rec.start_date) ;
    eit_rec.end_date :=  TRUNC(eit_rec.end_date);
    eit_rec.information_type := UPPER(eit_rec.information_type);

    IF validate_record(eit_rec) THEN

       l_dup_var := FALSE;
       l_eit_rec.pe_eit_id := NULL;
       OPEN chk_duplicate(eit_rec.person_id,eit_rec.information_type,eit_rec.start_date);
       FETCH chk_duplicate INTO l_eit_rec;
       CLOSE chk_duplicate;

       IF l_eit_rec.pe_eit_id IS NOT NULL THEN
          l_dup_var := TRUE;
       END IF;

       IF l_dup_var THEN

           -- IF DUPLICATE RECORDS FOUND THEN FOLLOW DISCREPANCY RULE,GMURALD

             IF l_rule = 'I' THEN
                BEGIN
                  upd_pe_eit(  eit_rec => eit_rec,
                       dup_eit_rec => l_eit_rec,
                               p_error_code => l_error_code,
                               p_status => l_status);

                  UPDATE igs_pe_eit_int
                  SET match_ind = '18',  -- MATCH OCCURED AND USED IMPORTED VALUES
                      status = l_status ,
                      error_code = l_error_code
                  WHERE interface_eit_id  = eit_rec.interface_eit_id;

                   EXCEPTION
                        WHEN OTHERS THEN

               IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

              IF (l_request_id IS NULL) THEN
                 l_request_id := fnd_global.conc_request_id;
              END IF;

              l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_eit.exception1 ' || 'E014';

              fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
              fnd_message.set_token('INTERFACE_ID',eit_rec.interface_eit_id);
              fnd_message.set_token('ERROR_CD','E014');

              l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

              fnd_log.string_with_context( fnd_log.level_exception,
                               l_label,
                               l_debug_str, NULL,
                               NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
               END IF;

               IF l_enable_log = 'Y' THEN
              igs_ad_imp_001.logerrormessage(eit_rec.interface_eit_id,'E014','IGS_PE_EIT_INT');
               END IF;

                          UPDATE igs_pe_eit_int
                          SET match_ind = '18',
                              status = '3',
                              error_code = 'E014'
                          WHERE interface_eit_id  = eit_rec.interface_eit_id;

                END;

           ELSIF l_rule = 'R' THEN   -- MATCH REVIEWED TO BE IMPORTED
               IF eit_rec.match_ind = '21' THEN
                  BEGIN
                     upd_pe_eit(eit_rec => eit_rec,
                        dup_eit_rec => l_eit_rec,
                                p_error_code => l_error_code,
                                p_status => l_status);

                         UPDATE igs_pe_eit_int
                         SET
                         status = l_status ,
                         error_code = l_error_code
                         WHERE
                         interface_eit_id  = eit_rec.interface_eit_id;

                     EXCEPTION
                       WHEN OTHERS THEN

               IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

              IF (l_request_id IS NULL) THEN
                 l_request_id := fnd_global.conc_request_id;
              END IF;

              l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_eit.exception2 ' || 'E014';

              fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
              fnd_message.set_token('INTERFACE_ID',eit_rec.interface_eit_id);
              fnd_message.set_token('ERROR_CD','E014');

              l_debug_str :=  fnd_message.get || ' ' ||  SQLERRM;

              fnd_log.string_with_context( fnd_log.level_exception,
                               l_label,
                               l_debug_str, NULL,
                               NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
               END IF;

               IF l_enable_log = 'Y' THEN
              igs_ad_imp_001.logerrormessage(eit_rec.interface_eit_id,'E014','IGS_PE_EIT_INT');
               END IF;

                         UPDATE igs_pe_eit_int
                         SET status = '3',
                         error_code = 'E014'
                         WHERE interface_eit_id  = eit_rec.interface_eit_id;
                  END;

                END IF;
             END IF;
          ELSE
          crt_pe_eit (eit_rec  => eit_rec,
                      error_code => l_error_code,
                      status  => l_status) ;
          END IF;
       END IF;

       IF l_processed_records = 100 THEN
          COMMIT;
          l_processed_records := 0;
       END IF;

     END LOOP;
  END prc_pe_eit;

PROCEDURE prc_pe_addr
(
  p_source_type_id IN NUMBER,
  p_batch_id IN  NUMBER ) AS
/*
  ||  Created By : nsinha
  ||  Created On : 22-JUN-2001
  ||  Purpose : This procedure process the Application
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ssaleem       8-OCT-2003       Bug no : 3130316
  ||                                 Performance enhancements done, validations and status
  ||                                 updations done outside the main loop
  ||                                 This procedure is brought in from IGSAD83B.pls
  || npalanis         6-JAN-2003      Bug : 2734697
  ||                                  code added to commit after import of every
  ||                                  100 records .New variable l_processed_records added
  ||  pkpatel       22-JUN-2001      Bug no.2466466
  ||                                 Added the parameter p_party_site_id in update address.
  ||                                 Modified for performance.
  ||  gmaheswa	     27-Jan-2006     Bug: 4938278: Call IGS_PE_WF_GEN. ADDR_BULK_SYNCHRONIZATION to raise bulk
  ||				     address change notification after process address records of all persons.
  ||  (reverse chronological order - newest change first)
*/

  lnDupExist NUMBER;
  lvcAction VARCHAR2(1);
  lvcRecordExist VARCHAR2(1);
  p_status VARCHAR2(1);
  p_error_code VARCHAR2(30);
  l_location_id   hz_party_sites.location_id%TYPE;
  l_party_site_id hz_party_sites.party_site_id%TYPE;
  l_processed_records NUMBER(5) := 0;

  l_prog_label  VARCHAR2(100);
  l_label  VARCHAR2(100);
  l_debug_str VARCHAR2(2000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER;
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

  CURSOR addr_cur(cp_interface_run_id igs_ad_addr_int_all.interface_run_id%TYPE) IS
  SELECT ai.*, i.person_id
  FROM  igs_ad_addr_int_all  ai, igs_ad_interface_all i
  WHERE ai.status = '2' AND
        i.interface_run_id = cp_interface_run_id AND
        ai.interface_id = i.interface_id AND
        i.status = '1';


  addr_rec addr_cur%ROWTYPE;
  l_addr_rec1 igs_ad_addr_int_all%ROWTYPE;

  CURSOR  check_dup_addr(cp_x_value VARCHAR2,
             cp_addr_rec addr_cur%ROWTYPE) IS
  SELECT  hz_party_sites.rowid,hz_party_sites.*
  FROM    hz_locations, hz_party_sites
  WHERE   hz_party_sites.party_id = cp_addr_rec.person_id
  AND     hz_party_sites.location_id = hz_locations.location_id
  AND     UPPER(NVL(hz_locations.address1,cp_x_value)) = UPPER(NVL(cp_addr_rec.addr_line_1,cp_x_value))
  AND     UPPER(NVL(hz_locations.address2,cp_x_value)) = UPPER(NVL(cp_addr_rec.addr_line_2,cp_x_value))
  AND     UPPER(NVL(hz_locations.address3,cp_x_value)) = UPPER(NVL(cp_addr_rec.addr_line_3,cp_x_value))
  AND     UPPER(NVL(hz_locations.address4,cp_x_value)) = UPPER(NVL(cp_addr_rec.addr_line_4,cp_x_value))
  AND     UPPER(NVL(hz_locations.city,cp_x_value))     = UPPER(NVL(cp_addr_rec.city,cp_x_value))
  AND     UPPER(NVL(hz_locations.state,cp_x_value))    = UPPER(NVL(cp_addr_rec.state,cp_x_value))
  AND     hz_locations.country  = cp_addr_rec.country
  AND     UPPER(NVL(hz_locations.county,cp_x_value))   = UPPER(NVL(cp_addr_rec.county,cp_x_value))
  AND     UPPER(NVL(hz_locations.province,cp_x_value)) = UPPER(NVL(cp_addr_rec.province,cp_x_value));

  l_addr_rec check_dup_addr%ROWTYPE;

 BEGIN

  l_prog_label := 'igs.plsql.igs_ad_imp_026.prc_pe_addr';
  l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_addr.';
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

      IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
      END IF;

      l_label := 'igs.plsql.igs_ad_imp_026.prc_pe_addr.begin';
      l_debug_str :=  'Igs_Ad_Imp_005.PRC_PE_ADDR';

      fnd_log.string_with_context( fnd_log.level_procedure,
                       l_label,
                   l_debug_str, NULL,
                   NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  lvcAction := Igs_Ad_Imp_001.find_source_cat_rule(p_source_type_id,'PERSON_ADDRESS');

  IF lvcAction = 'E' OR lvcAction = 'I' THEN

     UPDATE igs_ad_addr_int_all
     SET status='3',
         error_code = 'E695'
     WHERE interface_run_id=l_interface_run_id
     AND  STATUS = '2'
     AND  match_ind IS NOT NULL;

     IF lvcAction = 'E' THEN

        UPDATE igs_ad_addr_int_all ai
    SET status='1',
        match_ind='19'
    WHERE interface_run_id=l_interface_run_id
        AND STATUS = '2'
    AND EXISTS( SELECT hs.rowid
                FROM   hz_party_sites hs,
                       igs_ad_interface_all ad,
                           hz_locations hl
            WHERE  ad.interface_id = ai.interface_id AND
                   hs.party_id = ad.person_id AND
                           hs.location_id     = hl.location_id AND
                           UPPER(NVL(hl.address1,'X')) = UPPER(NVL(ai.addr_line_1,'X')) AND
                           UPPER(NVL(hl.address2,'X')) = UPPER(NVL(ai.addr_line_2,'X')) AND
                           UPPER(NVL(hl.address3,'X')) = UPPER(NVL(ai.addr_line_3,'X')) AND
                           UPPER(NVL(hl.address4,'X')) = UPPER(NVL(ai.addr_line_4,'X')) AND
                           UPPER(NVL(hl.city,'X'))     = UPPER(NVL(ai.city,'X')) AND
                           UPPER(NVL(hl.state,'X'))    = UPPER(NVL(ai.state,'X')) AND
                           hl.country  = UPPER(ai.country) AND
                           UPPER(NVL(hl.county,'X'))   = UPPER(NVL(ai.county,'X')) AND
                           UPPER(NVL(hl.province,'X')) = UPPER(NVL(ai.province,'X')));
     END IF;

  ELSIF  lvcAction = 'R' THEN

     UPDATE igs_ad_addr_int_all
     SET status = '1'
     WHERE interface_run_id=l_interface_run_id
     AND  status = '2'
     AND  match_ind IN ('18','19','22','23');

     UPDATE igs_ad_addr_int_all
     SET status = '3',
         error_code = 'E695'
     WHERE interface_run_id=l_interface_run_id
     AND  status = '2'
     AND ( match_ind IS NOT NULL  AND match_ind <> '21' AND match_ind <> '25');

     UPDATE igs_ad_addr_int_all ai
     SET status='1',
         match_ind = '23'
     WHERE interface_run_id=l_interface_run_id
     AND status = '2'
     AND match_ind IS NULL
     AND EXISTS( SELECT hs.rowid
                 FROM hz_locations hl,
              hz_party_sites hs,
              igs_ad_interface_all ad
                 WHERE  ad.interface_id = ai.interface_id AND
                        hs.party_id = ad.person_id AND
                        hs.location_id = hl.location_id   AND
                        NVL(UPPER(hl.address1), 'X') = NVL(UPPER(ai.addr_line_1), 'X') AND
                        NVL(UPPER(hl.address2), 'X') = NVL(UPPER(ai.addr_line_2), 'X') AND
                        NVL(UPPER(hl.address3), 'X') = NVL(UPPER(ai.addr_line_3), 'X') AND
                        NVL(UPPER(hl.address4), 'X') = NVL(UPPER(ai.addr_line_4), 'X') AND
                        NVL(UPPER(hl.city), 'X') = NVL(UPPER(ai.city), 'X') AND
                        NVL(UPPER(hl.state), 'X') = NVL(UPPER(ai.state), 'X') AND
                        NVL(UPPER(hl.province), 'X') = NVL(UPPER(ai.province), 'X') AND
                        NVL(UPPER(hl.county), 'X') = NVL(UPPER(ai.county), 'X') AND
                        hl.country = UPPER(ai.country) AND
                        NVL(UPPER(hl.postal_code), 'X') = NVL(UPPER(ai.postcode), 'X'));


     UPDATE igs_ad_addr_int_all ai
     SET status = '3',
         match_ind='20',
     dup_party_site_id = (SELECT hs.party_site_id
                          FROM hz_party_sites hs,
                             igs_ad_interface_all ad,
                             hz_locations hl
                          WHERE ad.interface_id = ai.interface_id AND
                                 ROWNUM = 1 AND
                                 hs.party_id = ad.person_id AND
                                 hs.location_id     = hl.location_id AND
                                 UPPER(NVL(hl.address1,'X')) = UPPER(NVL(ai.addr_line_1,'X')) AND
                                 UPPER(NVL(hl.address2,'X')) = UPPER(NVL(ai.addr_line_2,'X')) AND
                                 UPPER(NVL(hl.address3,'X')) = UPPER(NVL(ai.addr_line_3,'X')) AND
                                 UPPER(NVL(hl.address4,'X')) = UPPER(NVL(ai.addr_line_4,'X')) AND
                                 UPPER(NVL(hl.city,'X'))     = UPPER(NVL(ai.city,'X')) AND
                                 UPPER(NVL(hl.state,'X'))    = UPPER(NVL(ai.state,'X')) AND
                                 hl.country  = UPPER(ai.country) AND
                                 UPPER(NVL(hl.county,'X'))   = UPPER(NVL(ai.county,'X')) AND
                                 UPPER(NVL(hl.province,'X')) = UPPER(NVL(ai.province,'X')))
     WHERE interface_run_id=l_interface_run_id AND
     status = '2' AND
         match_ind IS NULL AND
     EXISTS (SELECT  hs.rowid
             FROM hz_party_sites hs,
                igs_ad_interface_all ad,
                hz_locations hl
         WHERE ad.interface_id = ai.interface_id AND
                hs.party_id = ad.person_id AND
                    hs.location_id = hl.location_id AND
                    UPPER(NVL(hl.address1,'X')) = UPPER(NVL(ai.addr_line_1,'X')) AND
                    UPPER(NVL(hl.address2,'X')) = UPPER(NVL(ai.addr_line_2,'X')) AND
                    UPPER(NVL(hl.address3,'X')) = UPPER(NVL(ai.addr_line_3,'X')) AND
                    UPPER(NVL(hl.address4,'X')) = UPPER(NVL(ai.addr_line_4,'X')) AND
                    UPPER(NVL(hl.city,'X'))     = UPPER(NVL(ai.city,'X')) AND
                    UPPER(NVL(hl.state,'X'))    = UPPER(NVL(ai.state,'X')) AND
                    hl.country  = UPPER(ai.country)  AND
                    UPPER(NVL(hl.county,'X'))   = UPPER(NVL(ai.county,'X')) AND
                    UPPER(NVL(hl.province,'X')) = UPPER(NVL(ai.province,'X')) );
 END IF;

 FOR addr_rec IN addr_cur(l_interface_run_id) LOOP
  Igs_Ad_Imp_002.g_addr_process := FALSE;
  -- initialize the columns of l_addr_rec
  addr_rec.country := UPPER(addr_rec.country);

  l_addr_rec1.org_id             := addr_rec.org_id;
  l_addr_rec1.interface_addr_id      := addr_rec.interface_addr_id;
  l_addr_rec1.interface_id       := addr_rec.interface_id;
  l_addr_rec1.addr_line_1        := addr_rec.addr_line_1;
  l_addr_rec1.addr_line_2        := addr_rec.addr_line_2;
  l_addr_rec1.addr_line_3        := addr_rec.addr_line_3;
  l_addr_rec1.addr_line_4            := addr_rec.addr_line_4;
  l_addr_rec1.postcode               := addr_rec.postcode;
  l_addr_rec1.city                   := addr_rec.city ;
  l_addr_rec1.state                  := addr_rec.state ;
  l_addr_rec1.county                 := addr_rec.county ;
  l_addr_rec1.province               := addr_rec.province;
  l_addr_rec1.country                := addr_rec.country ;
  l_addr_rec1.other_details          := addr_rec.other_details;
  l_addr_rec1.other_details_1        := addr_rec.other_details_1;
  l_addr_rec1.other_details_2        := addr_rec.other_details_2;
  l_addr_rec1.delivery_point_code    := addr_rec.delivery_point_code;
  l_addr_rec1.other_details_3        := addr_rec.other_details_3;
  l_addr_rec1.correspondence_flag    := addr_rec.correspondence_flag;
  l_addr_rec1.contact_person_id      := addr_rec.contact_person_id;
  l_addr_rec1.date_last_verified     := addr_rec.date_last_verified;
  l_addr_rec1.start_date             := addr_rec.start_date;
  l_addr_rec1.end_date               := addr_rec.end_date;
  l_addr_rec1.match_ind              := addr_rec.match_ind;
  l_addr_rec1.status                 := addr_rec.status;
  l_addr_rec1.ERROR_CODE             := addr_rec.ERROR_CODE;
  l_addr_rec1.dup_party_site_id      := addr_rec.dup_party_site_id;
  l_addr_rec1.created_by             := addr_rec.created_by;
  l_addr_rec1.creation_date          := addr_rec.creation_date;
  l_addr_rec1.last_updated_by        := addr_rec.last_updated_by;
  l_addr_rec1.last_update_date       := addr_rec.last_update_date;
  l_addr_rec1.last_update_login      := addr_rec.last_update_login;
  l_addr_rec1.request_id             := addr_rec.request_id;
  l_addr_rec1.program_application_id := addr_rec.program_application_id;
  l_addr_rec1.program_id             := addr_rec.program_id;
  l_addr_rec1.program_update_date    := addr_rec.program_update_date;
  l_addr_rec1.interface_run_id       := addr_rec.interface_run_id;
  --
      l_processed_records := l_processed_records + 1;

      l_location_id := NULL;
      l_party_site_id := NULL;
      l_addr_rec.location_id:= NULL;
      OPEN check_dup_addr('X',addr_rec);
      FETCH check_dup_addr INTO l_addr_rec;
      CLOSE check_dup_addr;

      IF l_addr_rec.location_id IS NOT NULL THEN

     IF lvcAction = 'I' THEN

            Igs_Ad_Imp_002.update_address(p_addr_rec      => l_addr_rec1,
                                          p_person_id     => addr_rec.person_id,
                                          p_location_id   => l_addr_rec.location_id,
                      p_party_site_id => l_addr_rec.party_site_id );
         ELSIF lvcAction = 'R' THEN
             IF  addr_rec.match_ind = '21'  THEN

                --Make a call to IGS_AD_UPDATE_ADDRESS with the following parameters.
                Igs_Ad_Imp_002.update_address( p_addr_rec      => l_addr_rec1,
                                               p_person_id     => addr_rec.person_id,
                                               p_location_id   => l_addr_rec.location_id,
                           p_party_site_id => l_addr_rec.party_site_id);
         END IF;
     END IF;

    ELSE
        --Make a call to IGS_AD_CREATE_ADDRESS with the following parameters.

                    --Make a call to Create ADDRESS with the following parameters.
                 Igs_Ad_Imp_002.create_address(
                                                p_addr_rec      => l_addr_rec1,
                                                p_person_id     => addr_rec.person_id,
                                                p_status        => p_status ,
                                                p_error_code => p_error_code );

    END IF;

    IF l_processed_records = 100 THEN
       COMMIT;
       l_processed_records := 0;
    END IF;
    IF (Igs_Ad_Imp_002.g_addr_process) THEN
       --populate IGS_PE_WF_GEN.TI_ADDR_CHG_PERSONS table with party id to generate notification at the end of process
       IGS_PE_WF_GEN.TI_ADDR_CHG_PERSONS(NVL(IGS_PE_WF_GEN.TI_ADDR_CHG_PERSONS.LAST,0)+1) := addr_rec.person_id;
    END IF;
 END LOOP;
END  prc_pe_addr;

END IGS_AD_IMP_026;

/
