--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_007" AS
/* $Header: IGSAD85B.pls 120.3 2006/02/01 02:30:00 pfotedar noship $ */

/*
||  Created By :
||  Created On :
||  Purpose : This procedure process the Application
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What

||  asbala         12-OCT-2003      Bug 3130316. Import Process Logging Framework Related changes.

||  asbala         28-SEP-2003      Bug 3130316. Import Process Source Category Rule processing changes,
                                    lookup caching related changes, and cursor parameterization.

||  pkpatel         25-Jul-2003     3045079 : TRUNC of start_dt for API insert/update
||  gmuralid        4-DEC-2002      SEVIS BUILD - Changed validation for country in
                                    procedure prc_pe_hz_citizenship to validate against fnd territories.
                                    Also made calls to the import processes in package igs_ad_imp_026
                                    in the procedure prc_pe_intl_dtls


    gmuralid        29-NOV-2002     SEVIS BUILD removed procedures prc_pe_visa_pass and prc_pe_fund_dep
                                    from both spec and body
                                    Also modified validation for country in procedure prc_pe_hz_citizenship
    gmaheswa        10-NOV-2003     Bug 3223043 HZ.K Impact changes
    nsidana         6/21/2004       Bug 3541714 : Added validtion to check that the date disowned > date recognized
                                    for citizenship details.
||  gmaheswa        29-Sep-2004     BUG 3787210 Added Closed indicator check for the Alternate Person Id type.

*/

cst_mi_val_18 CONSTANT  VARCHAR2(2) := '18';
cst_mi_val_19 CONSTANT  VARCHAR2(2) := '19';
cst_mi_val_20 CONSTANT  VARCHAR2(2) := '20';
cst_mi_val_21 CONSTANT  VARCHAR2(2) := '21';
cst_mi_val_22 CONSTANT  VARCHAR2(2) := '22';
cst_mi_val_23 CONSTANT  VARCHAR2(2) := '23';
cst_mi_val_24 CONSTANT  VARCHAR2(2) := '24';
cst_mi_val_25 CONSTANT  VARCHAR2(2) := '25';

cst_err_val_695 CONSTANT  VARCHAR2(4) := 'E695';
cst_err_val_14 CONSTANT  VARCHAR2(4) := 'E014';

cst_stat_val_1 CONSTANT  VARCHAR2(2) := '1';
cst_stat_val_2 CONSTANT  VARCHAR2(2) := '2';
cst_stat_val_3 CONSTANT  VARCHAR2(2) := '3';




PROCEDURE prc_pe_mltry_dtls (
    P_SOURCE_TYPE_ID IN NUMBER,
    P_BATCH_ID IN VARCHAR2
    ) AS
/*
||  Created By :
||  Created On :
||  Purpose : This procedure process the Application
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
|| npalanis         6-JAN-2003      Bug : 2734697
||                                  code added to commit after import of every
||                                  100 records .New variable l_processed_records added
||  masehgal        04-SEP-2002     # 2512906  Separation type id and corresponding validations added
||  npalanis        23-JUL-2002     Bug - 2421897
||                                  Validate procedure added .
||  sarakshi        12-Nov-2001     Bug no.2103692:Person Interface DLD
||                                  Added the DFF validation before insert/update to the oss table, also in
||                                  the call to insert_row/update_row to the oss table adding the dff columns
||  kumma           23-OCT-2002     Added the parameters for DFF columns to the calls of insert_row and update_row on
||                  igs_pe_hlth_ins_pkg and igs_pe_immu_dtls_pkg, #2608360
||  kumma           28-OCT-2002     Replaced MILITARY_TYPE_ID with MILITARY_TYPE_CD in validate_military procedure, #2608360
||                  Changed the data type of parameter p_MILITARY_TYPE_CD to VARCHAR2 in procedure CHK_DUP_MILIT
||  kumma           30-OCT-2002     Added the call to igs_ad_imp_018.validate_desc_flex for new flex fields added in health
||                  insurance and immunization details
||  pkpatel         6-JAN-2003      Bug No: 2729633
||                                  Added the UPPER for all VARCHAR2 fileds. Add additional columns for discrepancy. Add NOT NULL
||                                  check for separation type.
||  (reverse chronological order - newest change first)
*/

  CURSOR  milt_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
    SELECT mi.*,i.person_id
    FROM   igs_ad_military_int_all mi, igs_ad_interface_all i
    WHERE  mi.interface_run_id = cp_interface_run_id
      AND  mi.interface_id =  i.interface_id
      AND  mi.interface_run_id = cp_interface_run_id
      AND  mi.status = '2';
  l_var              VARCHAR2(1);
  l_rowid            VARCHAR2(25);
  l_milt_id          NUMBER;
  p_dup_var          BOOLEAN;
  l_rule             VARCHAR2(1);
  l_error_code       VARCHAR2(10);
  l_status           VARCHAR2(10);
  l_check            VARCHAR2(10);
  l_MILIT_SERVICE_ID igs_pe_mil_services_all.milit_service_id%TYPE;
  l_processed_records NUMBER(5) := 0 ;
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

  PROCEDURE crt_pr_mil(
      MILITARY_REC     milt_cur%ROWTYPE  ,
      p_error_code OUT NOCOPY VARCHAR2,
      p_status     OUT NOCOPY VARCHAR2
      ) AS

    l_org_id NUMBER(15);
  BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_007.crt_pr_mil.begin';
    l_debug_str := 'Interface military Id : ' || MILITARY_REC.Interface_military_Id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

    l_org_id := igs_ge_gen_003.get_org_id;
    IGS_PE_MIL_SERVICES_pkg.INSERT_ROW (
                X_ROWID                 => l_rowid,
                X_Org_Id                => l_org_id,
                x_MILIT_SERVICE_ID      => l_milt_id,
                x_PERSON_ID             => MILITARY_REC.PERSON_ID ,
                x_START_DATE            => MILITARY_REC.START_DATE ,
                x_END_DATE              => MILITARY_REC.END_DATE ,
                x_ATTRIBUTE_CATEGORY    => MILITARY_REC.ATTRIBUTE_CATEGORY ,
                x_ATTRIBUTE1            => MILITARY_REC.ATTRIBUTE1 ,
                x_ATTRIBUTE2            => MILITARY_REC.ATTRIBUTE2 ,
                x_ATTRIBUTE3            => MILITARY_REC.ATTRIBUTE3 ,
                x_ATTRIBUTE4            => MILITARY_REC.ATTRIBUTE4 ,
                x_ATTRIBUTE5            => MILITARY_REC.ATTRIBUTE5 ,
                x_ATTRIBUTE6            => MILITARY_REC.ATTRIBUTE6 ,
                x_ATTRIBUTE7            => MILITARY_REC.ATTRIBUTE7 ,
                x_ATTRIBUTE8            => MILITARY_REC.ATTRIBUTE8 ,
                x_ATTRIBUTE9            => MILITARY_REC.ATTRIBUTE9 ,
                x_ATTRIBUTE10           => MILITARY_REC.ATTRIBUTE10,
                x_ATTRIBUTE11           => MILITARY_REC.ATTRIBUTE11,
                x_ATTRIBUTE12           => MILITARY_REC.ATTRIBUTE12,
                x_ATTRIBUTE13           => MILITARY_REC.ATTRIBUTE13,
                x_ATTRIBUTE14           => MILITARY_REC.ATTRIBUTE14,
                x_ATTRIBUTE15           => MILITARY_REC.ATTRIBUTE15,
                x_ATTRIBUTE16           => MILITARY_REC.ATTRIBUTE16,
                x_ATTRIBUTE17           => MILITARY_REC.ATTRIBUTE17,
                x_ATTRIBUTE18           => MILITARY_REC.ATTRIBUTE18,
                x_ATTRIBUTE19           => MILITARY_REC.ATTRIBUTE19,
                x_ATTRIBUTE20           => MILITARY_REC.ATTRIBUTE20,
                x_MILITARY_TYPE_CD      => MILITARY_REC.MILITARY_TYPE_CD ,
                x_SEPARATION_TYPE_CD    => MILITARY_REC.SEPARATION_TYPE_CD ,
                x_ASSISTANCE_TYPE_CD    => MILITARY_REC.ASSISTANCE_TYPE_CD ,
                x_ASSISTANCE_STATUS_CD  => MILITARY_REC.ASSISTANCE_STATUS_CD ,
                X_MODE                  => 'R'
            );
           p_error_Code:= NULL;
           p_status :='1';
  EXCEPTION
    WHEN OTHERS THEN
      p_error_Code:= 'E322';
      p_status :='3';

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

        IF (l_request_id IS NULL) THEN
          l_request_id := fnd_global.conc_request_id;
        END IF;

        l_label := 'igs.plsql.igs_ad_imp_007.crt_pr_mil.exception';

          l_debug_str :=  'IGS_AD_IMP_007.PRC_PE_MLTRY_DTLS.crt_pr_mil ' ||
                               'Interface_military_Id: ' ||military_rec.Interface_military_Id
                   ||  'Status : 3' ||  'ErrorCode : E322' ||  SQLERRM;

        fnd_log.string_with_context( fnd_log.level_exception,
                      l_label,
                      l_debug_str, NULL,
                      NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(military_rec.Interface_military_Id,'E322');
    END IF;

END crt_pr_mil;

PROCEDURE Validate_Military(
    military_rec IN milt_cur%ROWTYPE ,
    l_check OUT NOCOPY VARCHAR2
    ) AS

  CURSOR birth_dt_cur(p_person_id IGS_AD_INTERFACE.PERSON_ID%TYPE) IS
    SELECT Birth_date
    FROM   IGS_PE_PERSON_BASE_V
    WHERE  person_id= p_person_id;


  l_var VARCHAR2(1);
  l_birth_dt  IGS_AD_INTERFACE.BIRTH_DT%TYPE;
  p_error_code igs_ad_military_int_all.ERROR_CODE%TYPE := NULL;

  BEGIN
    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('PE_MIL_SEV_TYPE',military_rec.military_type_cd,8405))
    THEN
      p_error_code := 'E278';
      l_check := 'TRUE';
      RAISE NO_DATA_FOUND;
    END IF;

    IF military_rec.ASSISTANCE_TYPE_CD IS NOT NULL THEN
      IF NOT
      (igs_pe_pers_imp_001.validate_lookup_type_code('PE_MIL_ASS_TYPE',military_rec.assistance_type_cd,8405))
      THEN
        p_error_code := 'E279';
        l_check := 'TRUE';
        RAISE NO_DATA_FOUND;
      END IF;
    END IF;

    IF military_rec.ASSISTANCE_STATUS_CD IS NOT NULL THEN
      IF NOT
      (igs_pe_pers_imp_001.validate_lookup_type_code('PE_MIL_ASS_STATUS',military_rec.assistance_status_cd,8405))
      THEN
        p_error_code := 'E280';
        l_check := 'TRUE';
        RAISE NO_DATA_FOUND;
      END IF;
    END IF;

    OPEN Birth_dt_cur(military_rec.person_id) ;
    FETCH Birth_dt_cur INTO l_birth_dt;
    IF l_birth_dt IS NOT NULL AND l_birth_dt > military_rec.start_date THEN
      p_error_code := 'E222';
      CLOSE Birth_dt_cur;
      l_check := 'TRUE';
      RAISE NO_DATA_FOUND;
    ELSE
      p_error_code := NULL;
    END IF;
    CLOSE Birth_dt_cur;
    IF military_rec.end_date IS NOT NULL THEN
      IF military_rec.start_date > military_rec.end_date THEN
        p_error_code := 'E208';
        l_check := 'TRUE';
        RAISE NO_DATA_FOUND;
      END IF;
    END IF;

    IF military_rec.separation_type_cd IS NOT NULL THEN
      IF NOT
      (igs_pe_pers_imp_001.validate_lookup_type_code('PE_MIL_SEP_TYPE',military_rec.separation_type_cd,8405))
      THEN
        p_error_code := 'E286';
        l_check := 'TRUE';
        RAISE NO_DATA_FOUND;
      END IF;
    END IF;

    IF NOT igs_ad_imp_018.validate_desc_flex(
                       p_attribute_category =>MILITARY_REC.attribute_category,
                       p_attribute1         =>MILITARY_REC.attribute1  ,
                       p_attribute2         =>MILITARY_REC.attribute2  ,
                       p_attribute3         =>MILITARY_REC.attribute3  ,
                       p_attribute4         =>MILITARY_REC.attribute4  ,
                       p_attribute5         =>MILITARY_REC.attribute5  ,
                       p_attribute6         =>MILITARY_REC.attribute6  ,
                       p_attribute7         =>MILITARY_REC.attribute7  ,
                       p_attribute8         =>MILITARY_REC.attribute8  ,
                       p_attribute9         =>MILITARY_REC.attribute9  ,
                       p_attribute10        =>MILITARY_REC.attribute10 ,
                       p_attribute11        =>MILITARY_REC.attribute11 ,
                       p_attribute12        =>MILITARY_REC.attribute12 ,
                       p_attribute13        =>MILITARY_REC.attribute13 ,
                       p_attribute14        =>MILITARY_REC.attribute14 ,
                       p_attribute15        =>MILITARY_REC.attribute15 ,
                       p_attribute16        =>MILITARY_REC.attribute16 ,
                       p_attribute17        =>MILITARY_REC.attribute17 ,
                       p_attribute18        =>MILITARY_REC.attribute18 ,
                       p_attribute19        =>MILITARY_REC.attribute19 ,
                       p_attribute20        =>MILITARY_REC.attribute20 ,
                       p_desc_flex_name     =>'IGS_PE_MIL_SERVICE_FLEX' ) THEN

      p_error_code := 'E255';
      l_check := 'TRUE';
      RAISE NO_DATA_FOUND;
    END IF;
    l_check := 'FALSE' ;
    p_error_code := NULL ;

    EXCEPTION
      WHEN OTHERS THEN
        UPDATE igs_ad_military_int_all
        SET    error_code = p_error_code,
               status = '3'
        WHERE  interface_military_id = military_rec.interface_military_id ;

      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(military_rec.Interface_military_Id,p_error_code);
      END IF;

    END;

BEGIN
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_ad_imp_007.prc_pe_mltry_dtls';
  l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_mltry_dtls.';
  l_check := 'FALSE' ;


  l_rule :=Igs_Ad_Imp_001.FIND_SOURCE_CAT_RULE(P_SOURCE_TYPE_ID,'PERSON_MILITARY_DETAILS');

  -- If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_ad_military_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND interface_run_id = l_interface_run_id
      AND status = cst_stat_val_2;
  END IF;

  -- If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_ad_military_int_all mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM   igs_pe_mil_services_all pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.person_id
             AND  pe.military_type_cd = UPPER(mi.military_type_cd)
             AND  TRUNC(pe.start_date) = TRUNC(mi.start_date) );
  END IF;

  -- If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_ad_military_int_all
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status = cst_stat_val_2;
  END IF;

  -- If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_ad_military_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25))
      AND status = cst_stat_val_2;
  END IF;

  -- If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_ad_military_int_all mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM igs_pe_mil_services_all pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.person_id
             AND  pe.military_type_cd = UPPER(mi.military_type_cd)
             AND  TRUNC(pe.start_date) = TRUNC(mi.start_date)
             AND  NVL(TRUNC(pe.end_date),igs_ge_date.igsdate('9999/01/01'))=NVL(TRUNC(mi.end_date),igs_ge_date.igsdate('9999/01/01'))
             AND  NVL(UPPER(pe.assistance_type_cd),'*!*')= NVL(UPPER(mi.assistance_type_cd),'*!*')
             AND  NVL(UPPER(pe.assistance_status_cd),'*!*') = NVL(UPPER(mi.assistance_status_cd),'*!*')
             AND  NVL(UPPER(pe.separation_type_cd),'*!*')   = NVL(UPPER(mi.separation_type_cd),'*!*')
             AND  NVL(pe.attribute1,'*!*')   = NVL(mi.attribute1,'*!*')
             AND  NVL(pe.attribute2,'*!*')   = NVL(mi.attribute2,'*!*')
             AND  NVL(pe.attribute3,'*!*')   = NVL(mi.attribute3,'*!*')
             AND  NVL(pe.attribute4,'*!*')   = NVL(mi.attribute4,'*!*')
             AND  NVL(pe.attribute5,'*!*')   = NVL(mi.attribute5,'*!*')
             AND  NVL(pe.attribute6,'*!*')   = NVL(mi.attribute6,'*!*')
             AND  NVL(pe.attribute7,'*!*')   = NVL(mi.attribute7,'*!*')
             AND  NVL(pe.attribute8,'*!*')   = NVL(mi.attribute8,'*!*')
             AND  NVL(pe.attribute9,'*!*')   = NVL(mi.attribute9,'*!*')
             AND  NVL(pe.attribute10,'*!*')   = NVL(mi.attribute10,'*!*')
             AND  NVL(pe.attribute11,'*!*')   = NVL(mi.attribute11,'*!*')
             AND  NVL(pe.attribute12,'*!*')   = NVL(mi.attribute12,'*!*')
             AND  NVL(pe.attribute13,'*!*')   = NVL(mi.attribute13,'*!*')
             AND  NVL(pe.attribute14,'*!*')   = NVL(mi.attribute14,'*!*')
             AND  NVL(pe.attribute15,'*!*')   = NVL(mi.attribute15,'*!*')
             AND  NVL(pe.attribute16,'*!*')   = NVL(mi.attribute16,'*!*')
             AND  NVL(pe.attribute17,'*!*')   = NVL(mi.attribute17,'*!*')
             AND  NVL(pe.attribute18,'*!*')   = NVL(mi.attribute18,'*!*')
             AND  NVL(pe.attribute19,'*!*')   = NVL(mi.attribute19,'*!*')
             AND  NVL(pe.attribute20,'*!*')   = NVL(mi.attribute20,'*!*')
             );
  END IF;
  -- If rule in R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_ad_military_int_all mi
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_20,
        dup_milit_service_id = (SELECT milit_service_id
                                FROM igs_pe_mil_services_all pe, igs_ad_interface_all ii
                            WHERE mi.interface_run_id = l_interface_run_id
                            AND  ii.interface_id = mi.interface_id
                            AND  ii.person_id = pe.person_id
                            AND  pe.military_type_cd = UPPER(mi.military_type_cd)
                            AND  TRUNC(pe.start_date) = TRUNC(mi.start_date))
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS (SELECT '1'
                  FROM igs_pe_mil_services_all pe, igs_ad_interface_all ii
          WHERE ii.interface_run_id = l_interface_run_id
          AND  ii.interface_id = mi.interface_id
          AND  ii.person_id = pe.person_id
          AND  pe.military_type_cd = UPPER(mi.military_type_cd)
          AND  TRUNC(pe.start_date) = TRUNC(mi.start_date));
  END IF;

  FOR military_rec IN milt_cur(l_interface_run_id) LOOP
    l_processed_records := l_processed_records + 1 ;

    l_MILIT_SERVICE_ID := NULL;
    MILITARY_REC.START_DATE := TRUNC(MILITARY_REC.START_DATE);
    MILITARY_REC.END_DATE := TRUNC(MILITARY_REC.END_DATE);
    military_rec.separation_type_cd := UPPER(military_rec.separation_type_cd);
    military_rec.military_type_cd := UPPER(military_rec.military_type_cd);
    military_rec.assistance_type_cd := UPPER(military_rec.assistance_type_cd);
    military_rec.assistance_status_cd := UPPER(military_rec.assistance_status_cd);

    l_check := 'FALSE';
    Validate_military(military_rec, l_check);

    IF l_check = 'FALSE' THEN
      DECLARE
        CURSOR chk_dup_milit(cp_military_type_cd VARCHAR2,
                             cp_person_id VARCHAR2,
                             cp_start_date igs_ad_military_int_all.start_date%TYPE) IS
        SELECT rowid,mi.*
        FROM igs_pe_mil_services mi
        WHERE UPPER(military_type_cd) = UPPER(cp_military_type_cd)
        AND    person_id = cp_person_id
        AND    TRUNC(start_date) = TRUNC(cp_start_date);
    dup_milit_rec chk_dup_milit%ROWTYPE;
      BEGIN
      OPEN chk_dup_milit(military_rec.military_type_cd,
             military_rec.person_id ,
                         military_rec.start_date);
      FETCH chk_dup_milit INTO dup_milit_rec;
      CLOSE chk_dup_milit;
      IF dup_milit_rec.military_type_cd IS NOT NULL THEN
        IF l_rule = 'I' THEN
          BEGIN
            igs_pe_mil_services_pkg.update_row(
             x_rowid=> dup_milit_rec.rowid,
             x_milit_service_id=> dup_milit_rec.milit_service_id,
             x_person_id=> dup_milit_rec.person_id,
             x_start_date=> NVL(TRUNC(military_rec.start_date),dup_milit_rec.start_date),
             x_end_date=> NVL(TRUNC(military_rec.end_date),dup_milit_rec.end_date),
             x_attribute_category=>NVL(military_rec.attribute_category,dup_milit_rec.attribute_category),
             x_attribute1=>NVL(military_rec.attribute1,dup_milit_rec.attribute1),
             x_attribute2=>NVL(military_rec.attribute2, dup_milit_rec.attribute2),
             x_attribute3=>NVL(military_rec.attribute3,dup_milit_rec.attribute3),
             x_attribute4=>NVL(military_rec.attribute4,dup_milit_rec.attribute4),
             x_attribute5=>NVL(military_rec.attribute5,dup_milit_rec.attribute5),
             x_attribute6=>NVL(military_rec.attribute6,dup_milit_rec.attribute6),
             x_attribute7=>NVL(military_rec.attribute7,dup_milit_rec.attribute7),
             x_attribute8=>NVL(military_rec.attribute8,dup_milit_rec.attribute8),
             x_attribute9=>NVL(military_rec.attribute9,dup_milit_rec.attribute9),
             x_attribute10=>NVL(military_rec.attribute10,dup_milit_rec.attribute10),
             x_attribute11=>NVL(military_rec.attribute11,dup_milit_rec.attribute11),
             x_attribute12=>NVL(military_rec.attribute12,dup_milit_rec.attribute12),
             x_attribute13=>NVL(military_rec.attribute13,dup_milit_rec.attribute13),
             x_attribute14=>NVL(military_rec.attribute14,dup_milit_rec.attribute14),
             x_attribute15=>NVL(military_rec.attribute15,dup_milit_rec.attribute15),
             x_attribute16=>NVL(military_rec.attribute16,dup_milit_rec.attribute16),
             x_attribute17=>NVL(military_rec.attribute17,dup_milit_rec.attribute17),
             x_attribute18=>NVL(military_rec.attribute18,dup_milit_rec.attribute18),
             x_attribute19=>NVL(military_rec.attribute19,dup_milit_rec.attribute19),
             x_attribute20=> NVL(military_rec.attribute20,dup_milit_rec.attribute20),
             x_military_type_cd=>NVL(military_rec.military_type_cd,dup_milit_rec.military_type_cd),
             x_separation_type_cd=>NVL(military_rec.separation_type_cd,dup_milit_rec.separation_type_cd),
             x_assistance_type_cd=> NVL(military_rec.assistance_type_cd,dup_milit_rec.assistance_type_cd),
             x_assistance_status_cd => NVL(military_rec.assistance_status_cd,dup_milit_rec.assistance_status_cd),
             x_mode=>'R');
                UPDATE  igs_ad_military_int_all
                SET     match_ind =cst_mi_val_18,
                        status = cst_stat_val_1
                WHERE   interface_military_id = military_rec.interface_military_id;
              EXCEPTION
                WHEN OTHERS THEN
          UPDATE  igs_ad_military_int_all
                  SET     ERROR_CODE = cst_err_val_14,
                          status = cst_stat_val_3
                  WHERE   interface_military_id= military_rec.interface_military_id;

          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_mltry_dtls.exception: '|| 'E014';

              l_debug_str :=  'IGS_AD_IMP_007.PRC_PE_MLTRY_DTLS ' ||
                                   'Interface Military Id : ' || (MILITARY_REC.INTERFACE_MILITARY_ID)
                   || 'Status : 3' ||  'ErrorCode : E014'  ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(MILITARY_REC.INTERFACE_MILITARY_ID,'E014');
        END IF;

          END;
        ELSIF l_rule = 'R' THEN
          IF MILITARY_REC.match_ind = cst_mi_val_21 THEN
             BEGIN
                   igs_pe_mil_services_pkg.update_row(
             x_rowid=> dup_milit_rec.rowid,
             x_milit_service_id=> dup_milit_rec.milit_service_id,
             x_person_id=>dup_milit_rec.person_id,
             x_start_date=> NVL(TRUNC(military_rec.start_date),dup_milit_rec.start_date),
             x_end_date=> NVL(TRUNC(military_rec.end_date),dup_milit_rec.end_date),
             x_attribute_category=>NVL(military_rec.attribute_category,dup_milit_rec.attribute_category),
             x_attribute1=>NVL(military_rec.attribute1,dup_milit_rec.attribute1),
             x_attribute2=>NVL(military_rec.attribute2, dup_milit_rec.attribute2),
             x_attribute3=>NVL(military_rec.attribute3,dup_milit_rec.attribute3),
             x_attribute4=>NVL(military_rec.attribute4,dup_milit_rec.attribute4),
             x_attribute5=>NVL(military_rec.attribute5,dup_milit_rec.attribute5),
             x_attribute6=>NVL(military_rec.attribute6,dup_milit_rec.attribute6),
             x_attribute7=>NVL(military_rec.attribute7,dup_milit_rec.attribute7),
             x_attribute8=>NVL(military_rec.attribute8,dup_milit_rec.attribute8),
             x_attribute9=>NVL(military_rec.attribute9,dup_milit_rec.attribute9),
             x_attribute10=>NVL(military_rec.attribute10,dup_milit_rec.attribute10),
             x_attribute11=>NVL(military_rec.attribute11,dup_milit_rec.attribute11),
             x_attribute12=>NVL(military_rec.attribute12,dup_milit_rec.attribute12),
             x_attribute13=>NVL(military_rec.attribute13,dup_milit_rec.attribute13),
             x_attribute14=>NVL(military_rec.attribute14,dup_milit_rec.attribute14),
             x_attribute15=>NVL(military_rec.attribute15,dup_milit_rec.attribute15),
             x_attribute16=>NVL(military_rec.attribute16,dup_milit_rec.attribute16),
             x_attribute17=>NVL(military_rec.attribute17,dup_milit_rec.attribute17),
             x_attribute18=>NVL(military_rec.attribute18,dup_milit_rec.attribute18),
             x_attribute19=>NVL(military_rec.attribute19,dup_milit_rec.attribute19),
             x_attribute20=> NVL(military_rec.attribute20,dup_milit_rec.attribute20),
             x_military_type_cd=>NVL(military_rec.military_type_cd,dup_milit_rec.military_type_cd),
             x_separation_type_cd=>NVL(military_rec.separation_type_cd,dup_milit_rec.separation_type_cd),
             x_assistance_type_cd=> NVL(military_rec.assistance_type_cd,dup_milit_rec.assistance_type_cd),
             x_assistance_status_cd => NVL(military_rec.assistance_status_cd,dup_milit_rec.assistance_status_cd),
             x_mode=>'R');

                  UPDATE igs_ad_military_int_all
                  SET    match_ind =cst_mi_val_18,
                         status = cst_stat_val_1
                  WHERE  interface_military_id = military_rec.interface_military_id;

                EXCEPTION
                  WHEN OTHERS THEN
            UPDATE igs_ad_military_int_all
                    SET    ERROR_CODE = 'E014',
                           status = '3'
                    WHERE  interface_military_id = military_rec.interface_military_id;

          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_mltry_dtls.exception: '|| 'E014';

              l_debug_str :=  'IGS_AD_IMP_007.PRC_PE_MLTRY_DTLS ' ||
                                   'Military Type Cd : ' || MILITARY_REC.MILITARY_TYPE_CD
                   || ' Status : 3 ' ||  'ErrorCode : E014'  ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(MILITARY_REC.INTERFACE_MILITARY_ID,'E014');
        END IF;

        END;
          END IF;
        END IF;
      ELSE
        crt_pr_mil(MILITARY_REC,
               l_error_code,
           l_status );
        UPDATE igs_ad_military_int_all
        SET    status = l_status,
               ERROR_CODE = l_error_code
        WHERE  interface_military_id= military_rec.interface_military_id;
      END IF;
    END;
    END IF;

    IF l_processed_records = 100 THEN
      COMMIT;
      l_processed_records := 0;
    END IF;

  END LOOP;
END prc_pe_mltry_dtls;

PROCEDURE prc_pe_immu_dtls
(   P_SOURCE_TYPE_ID IN NUMBER,
    P_BATCH_ID IN NUMBER
  )
AS
/*
      ||  Created By : adhawan
      ||  Created On :19-nov-2001F
      ||  Purpose : This procedure process the Immunization Details
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      || npalanis         6-JAN-2003      Bug : 2734697
      ||                                  code added to commit after import of every
      ||                                  100 records .New variable l_processed_records added
      ||  npalanis      25-JUL-2002     Bug - 2425734
      ||                                validation for start date cannot be less than birth date of person added
      ||  adhawan       12-Nov-2001     Bug no.2103692:Person Interface DLD
      ||                                 New procedure created for processing the immunization details of the person
      ||
      ||  (reverse chronological order - newest change first)
        */
  CURSOR c_immu_dtls_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
    SELECT  ai.*, i.person_id
    FROM    igs_pe_immu_dtl_int ai, igs_ad_interface_all i
    WHERE   ai.interface_run_id = cp_interface_run_id
      AND   ai.interface_id = i.interface_id
      AND   ai.interface_run_id = cp_interface_run_id
      AND   ai.status = '2';

  CURSOR dup_chk_health_cur(cp_person_id igs_pe_immu_dtls.person_id%TYPE,
                            cp_immu_code igs_pe_immu_dtls.immunization_code%TYPE,
                            cp_start_date igs_pe_immu_dtls.start_date%TYPE ) IS
    SELECT ROWID, mi.*
    FROM   igs_pe_immu_dtls mi
    WHERE  person_id         =cp_person_id
      AND  immunization_code = cp_immu_code
      AND  TRUNC(start_date) =TRUNC(cp_start_date);

  dup_chk_health_rec   dup_chk_health_cur%ROWTYPE;
  health_insur_rec     c_immu_dtls_cur%ROWTYPE;
  l_dup_var BOOLEAN;
  l_immu_details_id    igs_pe_immu_dtls.immu_details_id%TYPE;
  l_var VARCHAR2(1);
  l_rule VARCHAR2(1);
  l_error_code  igs_pe_immu_dtl_int.error_code%TYPE;
  l_status      igs_pe_immu_dtl_int.status%TYPE;
  l_count NUMBER(10);
  lv_rowid VARCHAR2(25);
  l_processed_records NUMBER(5) := 0;
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

PROCEDURE validate_record_health(p_health_insur_rec IN c_immu_dtls_cur%ROWTYPE,
                                 p_error_code  OUT NOCOPY VARCHAR2)
AS
        /*
      ||  Created By : adhawan
      ||  Created On :19-nov-2001
      ||  Purpose : This procedure process the Immunization Details
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  adhawan       12-Nov-2001     Bug no.2103692:Person Interface DLD
      ||                                 New procedure created for processing the validations for immunization
      ||                                 details of the person
      ||
      ||  (reverse chronological order - newest change first)
        */
  CURSOR birth_dt_cur(p_person_id IGS_AD_INTERFACE.PERSON_ID%TYPE)  IS
    SELECT birth_date
    FROM   igs_pe_person_base_v
    WHERE  person_id = p_person_id;

  l_birth_date   igs_ad_interface.birth_dt%TYPE;
  l_rec          VARCHAR2(1);
  TYPE           Validatecur IS REF CURSOR;
  Validate_cur   Validatecur;


  BEGIN
        -- Call Log header
                    -- Perform validations for the following columns.  If any validation fails further comparisions
                    -- do not happen i.e. first validation failure returns the control back without executing other
                -- subsequent validations.  The error_code field is updated with the corresponding error code.
                   --Immunization code
                  -- modified to new lookup igs_lookup_values by gmuralid
    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('PE_IMM_TYPE',p_health_insur_rec.immunization_code,8405))
    THEN
      p_error_code := 'E156';
      RAISE no_data_found;
    ELSE
      p_error_code := NULL;
    END IF;
                   --Status code
                   --Cursor modified by gmuralid by migrating to new look up igs_lookups_view

    IF
    (igs_pe_pers_imp_001.validate_lookup_type_code('PE_IMM_STATUS',p_health_insur_rec.status_code,8405))
    THEN
      p_error_code := NULL;
    ELSE
      p_error_code := 'E157'; -- Status code  Validation Failed
      RAISE no_data_found;
    END IF;

    OPEN birth_dt_cur(p_health_insur_rec.person_id);
    FETCH birth_dt_cur INTO l_birth_date;
    IF l_birth_date IS NOT NULL AND l_birth_date >  p_health_insur_rec.start_date THEN
      p_error_code := 'E222';
      CLOSE birth_dt_cur;
      RAISE NO_DATA_FOUND;
    ELSE
      p_error_code := NULL;
    END IF;
    CLOSE birth_dt_cur;

                    --Start date and End Date validation
    IF p_health_insur_rec.start_date <= NVL(p_health_insur_rec.end_date,IGS_GE_DATE.IGSDATE('4712/12/31')) THEN
      p_error_code := NULL;
    ELSE
      p_error_code := 'E158'; -- Start Date and End Date Validation Failed
      RAISE no_data_found;
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
                    -- Validation Unsuccessful
        UPDATE igs_pe_immu_dtl_int
        SET    status        = '3',
               error_code    = p_error_code
        WHERE  interface_immu_dtls_id = p_health_insur_rec.interface_immu_dtls_id;

      IF l_enable_log = 'Y' THEN
         igs_ad_imp_001.logerrormessage(p_health_insur_rec.interface_immu_dtls_id,p_error_code,'IGS_PE_IMMU_DTL_INT');
      END IF;

END validate_record_health; -- End of Local Procedure validate_record_health


PROCEDURE crt_health_ins (
            health_insur_rec IN     c_immu_dtls_cur%ROWTYPE,
            p_error_code    OUT NOCOPY  VARCHAR2,
            p_status    OUT NOCOPY  VARCHAR2 )
AS
        /*
      ||  Created By : adhawan
      ||  Created On :19-nov-2001
      ||  Purpose : This procedure process the Immunization Details
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  adhawan       12-Nov-2001     Bug no.2103692:Person Interface DLD
      ||                                 New procedure created for processing the immunization details of the person
      ||                                 for creation of records in the OSS table
      ||
      ||  (reverse chronological order - newest change first)
        */
  l_dummy VARCHAR2(1);
  l_rowid VARCHAR2(25);
  l_immu_id  igs_pe_immu_dtls.immu_details_id%TYPE;

  BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_007.crt_health_ins.begin';
    l_debug_str := 'INTERFACE_IMMU_DTLS_ID:'||health_insur_rec.INTERFACE_IMMU_DTLS_ID;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

                   --validate record values
    validate_record_health (health_insur_rec, l_error_code);
    IF l_error_code IS NULL THEN
      IF NOT igs_ad_imp_018.validate_desc_flex(
                   p_attribute_category => health_insur_rec.attribute_category,
                   p_attribute1         => health_insur_rec.attribute1  ,
                   p_attribute2         => health_insur_rec.attribute2  ,
                   p_attribute3         => health_insur_rec.attribute3  ,
                   p_attribute4         => health_insur_rec.attribute4  ,
                   p_attribute5         => health_insur_rec.attribute5  ,
                   p_attribute6         => health_insur_rec.attribute6  ,
                   p_attribute7         => health_insur_rec.attribute7  ,
                   p_attribute8         => health_insur_rec.attribute8  ,
                   p_attribute9         => health_insur_rec.attribute9  ,
                   p_attribute10        => health_insur_rec.attribute10 ,
                   p_attribute11        => health_insur_rec.attribute11 ,
                   p_attribute12        => health_insur_rec.attribute12 ,
                   p_attribute13        => health_insur_rec.attribute13 ,
                   p_attribute14        => health_insur_rec.attribute14 ,
                   p_attribute15        => health_insur_rec.attribute15 ,
                   p_attribute16        => health_insur_rec.attribute16 ,
                   p_attribute17        => health_insur_rec.attribute17 ,
                   p_attribute18        => health_insur_rec.attribute18 ,
                   p_attribute19        => health_insur_rec.attribute19 ,
                   p_attribute20        => health_insur_rec.attribute20 ,
                   p_desc_flex_name     => 'IGS_PE_IMMU_DTLS_FLEX' ) THEN

        p_status:='3';
        p_error_code:='E255';
        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(health_insur_rec.INTERFACE_IMMU_DTLS_ID,'E255','IGS_PE_IMMU_DTL_INT');
        END IF;
      ELSE
        igs_pe_immu_dtls_pkg.INSERT_ROW (
                x_rowid                             => l_rowid,
                x_immu_details_id                   => l_immu_details_id,
                x_person_id                         => health_insur_rec.person_id,
                x_immunization_code                 => health_insur_rec.immunization_code,
                x_status_code                       => health_insur_rec.status_code,
                x_start_date                        => health_insur_rec.start_date,
                x_end_date                          => health_insur_rec.end_date,
                      X_ATTRIBUTE_CATEGORY          => health_insur_rec.ATTRIBUTE_CATEGORY,
                      X_ATTRIBUTE1                  => health_insur_rec.ATTRIBUTE1,
                      X_ATTRIBUTE2          => health_insur_rec.ATTRIBUTE2,
                      X_ATTRIBUTE3          => health_insur_rec.ATTRIBUTE3,
                      X_ATTRIBUTE4          => health_insur_rec.ATTRIBUTE4,
                      X_ATTRIBUTE5          => health_insur_rec.ATTRIBUTE5,
                      X_ATTRIBUTE6          => health_insur_rec.ATTRIBUTE6,
                      X_ATTRIBUTE7          => health_insur_rec.ATTRIBUTE7,
                      X_ATTRIBUTE8          => health_insur_rec.ATTRIBUTE8,
                      X_ATTRIBUTE9          => health_insur_rec.ATTRIBUTE9,
                      X_ATTRIBUTE10         => health_insur_rec.ATTRIBUTE10,
                      X_ATTRIBUTE11         => health_insur_rec.ATTRIBUTE11,
                      X_ATTRIBUTE12         => health_insur_rec.ATTRIBUTE12,
                      X_ATTRIBUTE13         => health_insur_rec.ATTRIBUTE13,
                      X_ATTRIBUTE14         => health_insur_rec.ATTRIBUTE14,
                      X_ATTRIBUTE15         => health_insur_rec.ATTRIBUTE15,
                      X_ATTRIBUTE16         => health_insur_rec.ATTRIBUTE16,
                      X_ATTRIBUTE17         => health_insur_rec.ATTRIBUTE17,
                      X_ATTRIBUTE18         => health_insur_rec.ATTRIBUTE18,
                      X_ATTRIBUTE19         => health_insur_rec.ATTRIBUTE19,
                      X_ATTRIBUTE20         => health_insur_rec.ATTRIBUTE20,
                      x_MODE  =>  'R');

        p_error_code := NULL;
        p_status := '1';

        UPDATE igs_pe_immu_dtl_int
        SET    status     = '1',
               ERROR_CODE = p_error_code
        WHERE  interface_immu_dtls_id = health_insur_rec.interface_immu_dtls_id;
      END IF;
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_STATUS := '3';
        p_ERROR_CODE := 'E159';

        UPDATE igs_pe_immu_dtl_int
        SET    status     = p_status,
               ERROR_CODE = p_error_code
        WHERE  interface_immu_dtls_id = health_insur_rec.interface_immu_dtls_id;
            -- Call Log detail

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_007.crt_health_ins.exception';

          l_debug_str :=  'Igs_Ad_Imp_007.PRC_PE_IMMU_DLTS.CRT_HEALTH_INS'
                            || ' Exception from IGS_PE_IMMU_DTLS_PKG.INSERT_ROW '
                            || ' Interface Id : '
                            || (health_insur_rec.interface_immu_dtls_id)
                            || ' Status : 3'|| ' ErrorCode : E159' ||SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(health_insur_rec.interface_immu_dtls_id,'E159','IGS_PE_IMMU_DTL_INT');
    END IF;

END crt_health_ins;

BEGIN
  -- Initialize variables for logging (as per logging framework)
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_ad_imp_007.prc_pe_immu_dtls';
  l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_immu_dtls.';

  -- Pick up all the records in the table for the P_INTERFACE_ID and
  -- store them into a Record variable pe_health_rec.
  -- Perform validations for the columns
  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_immu_dtls.begin';
    l_debug_str := 'igs_ad_imp_007.prc_pe_immu_dtls.begin';

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  l_rule := igs_ad_imp_001.find_source_cat_rule(
           p_source_type_id =>  P_SOURCE_TYPE_ID,
           p_category       =>  'PERSON_HEALTH_INSURANCE');

  -- If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_pe_immu_dtl_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND status = cst_stat_val_2
      AND interface_run_id = l_interface_run_id;
  END IF;

  -- If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_pe_immu_dtl_int mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM   igs_pe_immu_dtls pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.person_id
             AND  pe.immunization_code = UPPER(mi.immunization_code)
                     AND  TRUNC(pe.start_date) = TRUNC(mi.start_date));
  END IF;

  -- If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_pe_immu_dtl_int
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status = cst_stat_val_2;
  END IF;

  -- If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_pe_immu_dtl_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND status = cst_stat_val_2
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25));
  END IF;

  -- If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_pe_immu_dtl_int mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM igs_pe_immu_dtls pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.person_id
             AND  pe.immunization_code = UPPER(mi.immunization_code)
             AND  pe.status_code = UPPER(mi.status_code)
             AND  TRUNC(pe.start_date) = TRUNC(mi.start_date)
             AND  NVL(TRUNC(pe.end_date),igs_ge_date.igsdate('9999/01/01')) = NVL(TRUNC(mi.end_date),igs_ge_date.igsdate('9999/01/01'))
             );
  END IF;

  -- If rule is R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_pe_immu_dtl_int mi
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_20,
    dup_immu_details_id = (SELECT pe.immu_details_id
                           FROM igs_pe_immu_dtls pe, igs_ad_interface_all ii
                           WHERE mi.interface_run_id = l_interface_run_id
                           AND  ii.interface_id = mi.interface_id
                           AND  ii.person_id = pe.person_id
                           AND  pe.immunization_code = UPPER(mi.immunization_code)
                           AND  TRUNC(pe.start_date) = TRUNC(mi.start_date)
                )
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS (SELECT '1'
                  FROM igs_pe_immu_dtls pe, igs_ad_interface_all ii
          WHERE  ii.interface_run_id = l_interface_run_id
            AND  ii.interface_id = mi.interface_id
            AND  ii.person_id = pe.person_id
            AND  pe.immunization_code = UPPER(mi.immunization_code)
            AND  TRUNC(pe.start_date) = TRUNC(mi.start_date));
  END IF;

  FOR pe_health_rec IN c_immu_dtls_cur(l_interface_run_id) LOOP

    l_processed_records := l_processed_records + 1;

    pe_health_rec.immunization_code := UPPER(pe_health_rec.immunization_code);
    pe_health_rec.status_code := UPPER(pe_health_rec.status_code);
    pe_health_rec.start_date := TRUNC(pe_health_rec.start_date);
    pe_health_rec.end_date := TRUNC(pe_health_rec.end_date);

    dup_chk_health_rec.immu_details_id := NULL;
    OPEN  dup_chk_health_cur(pe_health_rec.person_id,pe_health_rec.immunization_code,pe_health_rec.start_date);
    FETCH dup_chk_health_cur INTO dup_chk_health_rec;
    CLOSE dup_chk_health_cur;

    IF dup_chk_health_rec.immu_details_id IS NOT NULL THEN
      IF l_rule = 'I' THEN
    validate_record_health(pe_health_rec, l_error_code);
        IF l_error_code IS NULL THEN
        BEGIN
      IF NOT igs_ad_imp_018.validate_desc_flex(
                            p_attribute_category =>pe_health_rec.attribute_category,
                            p_attribute1         =>pe_health_rec.attribute1  ,
                            p_attribute2         =>pe_health_rec.attribute2  ,
                            p_attribute3         =>pe_health_rec.attribute3  ,
                            p_attribute4         =>pe_health_rec.attribute4  ,
                            p_attribute5         =>pe_health_rec.attribute5  ,
                            p_attribute6         =>pe_health_rec.attribute6  ,
                            p_attribute7         =>pe_health_rec.attribute7  ,
                            p_attribute8         =>pe_health_rec.attribute8  ,
                            p_attribute9         =>pe_health_rec.attribute9  ,
                            p_attribute10        =>pe_health_rec.attribute10 ,
                            p_attribute11        =>pe_health_rec.attribute11 ,
                            p_attribute12        =>pe_health_rec.attribute12 ,
                            p_attribute13        =>pe_health_rec.attribute13 ,
                            p_attribute14        =>pe_health_rec.attribute14 ,
                            p_attribute15        =>pe_health_rec.attribute15 ,
                            p_attribute16        =>pe_health_rec.attribute16 ,
                            p_attribute17        =>pe_health_rec.attribute17 ,
                            p_attribute18        =>pe_health_rec.attribute18 ,
                            p_attribute19        =>pe_health_rec.attribute19 ,
                            p_attribute20        =>pe_health_rec.attribute20 ,
                            p_desc_flex_name     =>'IGS_PE_IMMU_DTLS_FLEX' ) THEN

      IF l_enable_log = 'Y' THEN
         igs_ad_imp_001.logerrormessage(pe_health_rec.interface_immu_dtls_id,'E255','IGS_PE_IMMU_DTL_INT');
      END IF;

            UPDATE  igs_pe_immu_dtl_int
                SET     ERROR_CODE ='E255',
                        status = '3'
                WHERE   INTERFACE_IMMU_DTLS_ID = pe_health_rec.interface_immu_dtls_id;

          ELSE
                igs_pe_immu_dtls_pkg.UPDATE_ROW
                 (
                  x_rowid               =>  dup_chk_health_rec.ROWID,
                  x_start_date          =>  NVL(pe_health_rec.start_date,dup_chk_health_rec.start_date),
                  x_end_date            =>  NVL(pe_health_rec.end_date,dup_chk_health_rec.start_date),
                  X_ATTRIBUTE_CATEGORY  => NVL(pe_health_rec.ATTRIBUTE_CATEGORY, dup_chk_health_rec.ATTRIBUTE_CATEGORY),
                  X_ATTRIBUTE1          => NVL(pe_health_rec.ATTRIBUTE1,  dup_chk_health_rec.ATTRIBUTE1),
                  X_ATTRIBUTE2          => NVL(pe_health_rec.ATTRIBUTE2,  dup_chk_health_rec.ATTRIBUTE2),
                  X_ATTRIBUTE3          => NVL(pe_health_rec.ATTRIBUTE3,  dup_chk_health_rec.ATTRIBUTE3),
                  X_ATTRIBUTE4          => NVL(pe_health_rec.ATTRIBUTE4,  dup_chk_health_rec.ATTRIBUTE4),
                  X_ATTRIBUTE5          => NVL(pe_health_rec.ATTRIBUTE5,  dup_chk_health_rec.ATTRIBUTE5),
                  X_ATTRIBUTE6          => NVL(pe_health_rec.ATTRIBUTE6,  dup_chk_health_rec.ATTRIBUTE6),
                  X_ATTRIBUTE7          => NVL(pe_health_rec.ATTRIBUTE7,  dup_chk_health_rec.ATTRIBUTE7),
                  X_ATTRIBUTE8          => NVL(pe_health_rec.ATTRIBUTE8,  dup_chk_health_rec.ATTRIBUTE8),
                  X_ATTRIBUTE9          => NVL(pe_health_rec.ATTRIBUTE9,  dup_chk_health_rec.ATTRIBUTE9),
                  X_ATTRIBUTE10         => NVL(pe_health_rec.ATTRIBUTE10,  dup_chk_health_rec.ATTRIBUTE10),
                  X_ATTRIBUTE11         => NVL(pe_health_rec.ATTRIBUTE11,  dup_chk_health_rec.ATTRIBUTE11),
                  X_ATTRIBUTE12         => NVL(pe_health_rec.ATTRIBUTE12,  dup_chk_health_rec.ATTRIBUTE12),
                  X_ATTRIBUTE13         => NVL(pe_health_rec.ATTRIBUTE13,  dup_chk_health_rec.ATTRIBUTE13),
                  X_ATTRIBUTE14         => NVL(pe_health_rec.ATTRIBUTE14,  dup_chk_health_rec.ATTRIBUTE14),
                  X_ATTRIBUTE15         => NVL(pe_health_rec.ATTRIBUTE15,  dup_chk_health_rec.ATTRIBUTE15),
                  X_ATTRIBUTE16         => NVL(pe_health_rec.ATTRIBUTE16,  dup_chk_health_rec.ATTRIBUTE16),
                  X_ATTRIBUTE17         => NVL(pe_health_rec.ATTRIBUTE17,  dup_chk_health_rec.ATTRIBUTE17),
                  X_ATTRIBUTE18         => NVL(pe_health_rec.ATTRIBUTE18,  dup_chk_health_rec.ATTRIBUTE18),
                  X_ATTRIBUTE19         => NVL(pe_health_rec.ATTRIBUTE19,  dup_chk_health_rec.ATTRIBUTE19),
                  X_ATTRIBUTE20         => NVL(pe_health_rec.ATTRIBUTE20,  dup_chk_health_rec.ATTRIBUTE20),
                  x_status_code         =>  NVL(pe_health_rec.status_code, dup_chk_health_rec.status_code),
                  x_immunization_code   =>  NVL(pe_health_rec.immunization_code,dup_chk_health_rec.immunization_code),
                  x_IMMU_DETAILS_ID     => dup_chk_health_rec.IMMU_DETAILS_ID,
                  x_PERSON_ID           =>  NVL(pe_health_rec.PERSON_ID,dup_chk_health_rec.PERSON_ID),
                  x_mode                =>'R'
                 );
                l_error_code := NULL;
                l_status := '1';
                UPDATE igs_pe_immu_dtl_int
                SET    match_ind  = cst_mi_val_18,
                      status     = l_status,
                      ERROR_CODE = l_error_code
                WHERE  interface_immu_dtls_id = pe_health_rec.interface_immu_dtls_id;
      END IF;

          EXCEPTION
        WHEN OTHERS THEN
              l_error_code := 'E160'; -- Could not update Immunization details
              l_status := '3';
              UPDATE igs_pe_immu_dtl_int
              SET    status     = l_status,
                     ERROR_CODE = l_error_code
              WHERE  interface_immu_dtls_id = pe_health_rec.interface_immu_dtls_id;

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_immu_dtls.exception';

          l_debug_str :=  'IGS_AD_IMP_007.PRC_PE_IMMU_DTLS'
                                        || 'INTERFACE_IMMU_DTLS_ID : ' ||
                                        pe_health_rec.interface_immu_dtls_id ||
                                        'Status : ' || l_status ||  'ErrorCode : ' ||  l_error_code ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(pe_health_rec.interface_immu_dtls_id,l_error_code,'IGS_PE_IMMU_DTL_INT');
    END IF;

          END;
        END IF;

      ELSIF l_rule  = 'R' THEN
        IF pe_health_rec.match_ind = '21' THEN
        -- call the validation process
          validate_record_health(pe_health_rec, l_error_code);
          IF l_error_code IS NULL THEN
            BEGIN
              IF NOT igs_ad_imp_018.validate_desc_flex(
                        p_attribute_category =>pe_health_rec.attribute_category,
                        p_attribute1         =>pe_health_rec.attribute1  ,
                        p_attribute2         =>pe_health_rec.attribute2  ,
                        p_attribute3         =>pe_health_rec.attribute3  ,
                        p_attribute4         =>pe_health_rec.attribute4  ,
                        p_attribute5         =>pe_health_rec.attribute5  ,
                        p_attribute6         =>pe_health_rec.attribute6  ,
                        p_attribute7         =>pe_health_rec.attribute7  ,
                        p_attribute8         =>pe_health_rec.attribute8  ,
                        p_attribute9         =>pe_health_rec.attribute9  ,
                        p_attribute10        =>pe_health_rec.attribute10 ,
                        p_attribute11        =>pe_health_rec.attribute11 ,
                        p_attribute12        =>pe_health_rec.attribute12 ,
                        p_attribute13        =>pe_health_rec.attribute13 ,
                        p_attribute14        =>pe_health_rec.attribute14 ,
                        p_attribute15        =>pe_health_rec.attribute15 ,
                        p_attribute16        =>pe_health_rec.attribute16 ,
                        p_attribute17        =>pe_health_rec.attribute17 ,
                        p_attribute18        =>pe_health_rec.attribute18 ,
                        p_attribute19        =>pe_health_rec.attribute19 ,
                        p_attribute20        =>pe_health_rec.attribute20 ,
                        p_desc_flex_name     =>'IGS_PE_IMMU_DTLS_FLEX' ) THEN

      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(pe_health_rec.INTERFACE_IMMU_DTLS_ID,'E255','IGS_PE_IMMU_DTL_INT');
      END IF;

                UPDATE  igs_pe_immu_dtl_int
                SET     ERROR_CODE ='E255',
                        status = '3'
                WHERE   INTERFACE_IMMU_DTLS_ID = pe_health_rec.INTERFACE_IMMU_DTLS_ID;
              ELSE
                igs_pe_immu_dtls_pkg.UPDATE_ROW
                 (
                  x_rowid               => dup_chk_health_rec.ROWID,
                  x_start_date          => NVL(pe_health_rec.start_date,dup_chk_health_rec.start_date),
                  x_end_date            => NVL(pe_health_rec.end_date,dup_chk_health_rec.end_date),
                  X_ATTRIBUTE_CATEGORY  => NVL(pe_health_rec.ATTRIBUTE_CATEGORY, dup_chk_health_rec.ATTRIBUTE_CATEGORY),
                  X_ATTRIBUTE1          => NVL(pe_health_rec.ATTRIBUTE1,  dup_chk_health_rec.ATTRIBUTE1),
                  X_ATTRIBUTE2          => NVL(pe_health_rec.ATTRIBUTE2,  dup_chk_health_rec.ATTRIBUTE2),
                  X_ATTRIBUTE3          => NVL(pe_health_rec.ATTRIBUTE3,  dup_chk_health_rec.ATTRIBUTE3),
                  X_ATTRIBUTE4          => NVL(pe_health_rec.ATTRIBUTE4,  dup_chk_health_rec.ATTRIBUTE4),
                  X_ATTRIBUTE5          => NVL(pe_health_rec.ATTRIBUTE5,  dup_chk_health_rec.ATTRIBUTE5),
                  X_ATTRIBUTE6          => NVL(pe_health_rec.ATTRIBUTE6,  dup_chk_health_rec.ATTRIBUTE6),
                  X_ATTRIBUTE7          => NVL(pe_health_rec.ATTRIBUTE7,  dup_chk_health_rec.ATTRIBUTE7),
                  X_ATTRIBUTE8          => NVL(pe_health_rec.ATTRIBUTE8,  dup_chk_health_rec.ATTRIBUTE8),
                  X_ATTRIBUTE9          => NVL(pe_health_rec.ATTRIBUTE9,  dup_chk_health_rec.ATTRIBUTE9),
                  X_ATTRIBUTE10         => NVL(pe_health_rec.ATTRIBUTE10,  dup_chk_health_rec.ATTRIBUTE10),
                  X_ATTRIBUTE11         => NVL(pe_health_rec.ATTRIBUTE11,  dup_chk_health_rec.ATTRIBUTE11),
                  X_ATTRIBUTE12         => NVL(pe_health_rec.ATTRIBUTE12,  dup_chk_health_rec.ATTRIBUTE12),
                  X_ATTRIBUTE13         => NVL(pe_health_rec.ATTRIBUTE13,  dup_chk_health_rec.ATTRIBUTE13),
                  X_ATTRIBUTE14         => NVL(pe_health_rec.ATTRIBUTE14,  dup_chk_health_rec.ATTRIBUTE14),
                  X_ATTRIBUTE15         => NVL(pe_health_rec.ATTRIBUTE15,  dup_chk_health_rec.ATTRIBUTE15),
                  X_ATTRIBUTE16         => NVL(pe_health_rec.ATTRIBUTE16,  dup_chk_health_rec.ATTRIBUTE16),
                  X_ATTRIBUTE17         => NVL(pe_health_rec.ATTRIBUTE17,  dup_chk_health_rec.ATTRIBUTE17),
                  X_ATTRIBUTE18         => NVL(pe_health_rec.ATTRIBUTE18,  dup_chk_health_rec.ATTRIBUTE18),
                  X_ATTRIBUTE19         => NVL(pe_health_rec.ATTRIBUTE19,  dup_chk_health_rec.ATTRIBUTE19),
                  X_ATTRIBUTE20         => NVL(pe_health_rec.ATTRIBUTE20,  dup_chk_health_rec.ATTRIBUTE20),
                  x_status_code         => NVL(pe_health_rec.status_code,dup_chk_health_rec.status_code),
                  x_immunization_code   => NVL(pe_health_rec.immunization_code,dup_chk_health_rec.immunization_code),
                  x_IMMU_DETAILS_ID     => dup_chk_health_rec.immu_details_id,
                  x_PERSON_ID           => NVL(pe_health_rec.PERSON_ID,dup_chk_health_rec.person_id),
                  x_mode                =>'R'
                 );
                l_error_code := NULL;
                l_status := '1';
                UPDATE igs_pe_immu_dtl_int
                SET    match_ind  = cst_mi_val_18,
                       status     = l_status,
                       ERROR_CODE = l_error_code
                WHERE  interface_immu_dtls_id = pe_health_rec.interface_immu_dtls_id;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
                l_error_code := 'E160'; -- Could not update Immunization details
                l_status := '3';
                UPDATE igs_pe_immu_dtl_int
                SET    status     = l_status,
                       ERROR_CODE = l_error_code
                WHERE  interface_immu_dtls_id = pe_health_rec.interface_immu_dtls_id;

          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_immu_dtls.exception: '|| l_error_code;

              l_debug_str :=  'IGS_AD_IMP_007.PRC_PE_IMMU_DTLS'
                      || 'INTERFACE_IMMU_DTLS_ID : ' ||
                      IGS_GE_NUMBER.TO_CANN(pe_health_rec.interface_immu_dtls_id) ||
                      'Status : ' || l_status ||  'ErrorCode : ' ||  l_error_code ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(pe_health_rec.interface_immu_dtls_id,l_error_code,'IGS_PE_IMMU_DTL_INT');
        END IF;
            END;
          END IF; -- if error_code = null (of validate record)
        END IF; --   pe_health_rec.MATCH_IND check
      END IF;  --    l_rule check for 'I' or 'R'.
    ELSE
     -- Make a call to Create health Details
     --with the following parameters.
      crt_health_ins(
         pe_health_rec,
         l_error_code,
         l_status);
    END IF;  -- record existance in Ad_health check
    IF l_processed_records = 100 THEN
      COMMIT;
      l_processed_records := 0;
    END IF;
  END LOOP;
END prc_pe_immu_dtls;


PROCEDURE PRC_PE_HLTH_INS_DTLS
(   P_SOURCE_TYPE_ID IN NUMBER,
    P_BATCH_ID IN NUMBER
   )
AS
/*
      ||  Created By : npalanis
      ||  Created On :23-Jul-2002
      ||  Purpose : This procedure process the Health Insurance Details
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  pkpatel        15-JAN-2003     Bug NO: 2397876
      ||                                 Added all the missing validations and replaced E008 with proper error codes
      || npalanis         6-JAN-2003      Bug : 2734697
      ||                                  code added to commit after import of every
      ||                                  100 records .New variable l_processed_records added
      ||  npalanis      25-JUL-2002     Bug - 2425734
      ||                                Validate_health_Ins procedure added,parameter added in dup check to get the
      ||                                 primary key id into the DUP_HLTH_INS_ID field in interfce table
      ||
      ||  (reverse chronological order - newest change first)
        */
        CURSOR hlth_ins(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
        SELECT hii.*, i.person_id
        FROM   igs_ad_hlth_ins_int_all hii, igs_ad_interface_all i
        WHERE  hii.interface_run_id = cp_interface_run_id
    AND    i.interface_id = hii.interface_id
        AND    i.interface_run_id = cp_interface_run_id
    AND    hii.status  = '2';

        l_dup_var BOOLEAN;
        p_health_ins_id NUMBER(15);
        l_var VARCHAR2(1);
        L_RULE VARCHAR2(1);
        L_ERROR_cODE  VARCHAR2(10);
        L_STATUS VARCHAR2(10);
        l_check VARCHAR2(10);
        l_dup_hlth_ins_id IGS_AD_HLTH_INS_INT.DUP_HLTH_INS_ID%TYPE;
        l_processed_records NUMBER(5) := 0;
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
  PROCEDURE Crt_Pe_hlth_ins(hlth_ins_rec  IN HLTH_INS%ROWTYPE,
                              p_error_code OUT NOCOPY VARCHAR2,
                              p_status OUT NOCOPY VARCHAR2) AS

            l_rowid VARCHAR2(25);
            l_hlth_id NUMBER;
            l_org_id NUMBER(15);
  BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_007.crt_pe_hlth_ins.begin';
    l_debug_str := 'Interface_hlth_Id: '||(hlth_ins_rec.Interface_hlth_Id);

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

            l_org_id := igs_ge_gen_003.get_org_id;

            IGS_PE_HLTH_INS_PKG.INSERT_ROW (
                   x_ROWID              => l_rowid,
                   x_HEALTH_INS_ID          => l_hlth_id  ,
                   x_PERSON_ID          => HLTH_INS_REC.PERSON_ID  ,
                   x_INSURANCE_CD           => HLTH_INS_REC.INSURANCE_CD   ,
                   x_INSURANCE_PROVIDER     => HLTH_INS_REC.INSURANCE_PROVIDER  ,
                   x_POLICY_NUMBER          => HLTH_INS_REC.POLICY_NUMBER  ,
                   x_START_DATE         => HLTH_INS_REC.START_DATE  ,
                   x_END_DATE           => HLTH_INS_REC.END_DATE  ,
                  X_ATTRIBUTE_CATEGORY      => HLTH_INS_REC.ATTRIBUTE_CATEGORY,
                  X_ATTRIBUTE1          => HLTH_INS_REC.ATTRIBUTE1,
                  X_ATTRIBUTE2          => HLTH_INS_REC.ATTRIBUTE2,
                  X_ATTRIBUTE3          => HLTH_INS_REC.ATTRIBUTE3,
                  X_ATTRIBUTE4          => HLTH_INS_REC.ATTRIBUTE4,
                  X_ATTRIBUTE5          => HLTH_INS_REC.ATTRIBUTE5,
                  X_ATTRIBUTE6          => HLTH_INS_REC.ATTRIBUTE6,
                  X_ATTRIBUTE7          => HLTH_INS_REC.ATTRIBUTE7,
                  X_ATTRIBUTE8          => HLTH_INS_REC.ATTRIBUTE8,
                  X_ATTRIBUTE9          => HLTH_INS_REC.ATTRIBUTE9,
                  X_ATTRIBUTE10         => HLTH_INS_REC.ATTRIBUTE10,
                  X_ATTRIBUTE11         => HLTH_INS_REC.ATTRIBUTE11,
                  X_ATTRIBUTE12         => HLTH_INS_REC.ATTRIBUTE12,
                  X_ATTRIBUTE13         => HLTH_INS_REC.ATTRIBUTE13,
                  X_ATTRIBUTE14         => HLTH_INS_REC.ATTRIBUTE14,
                  X_ATTRIBUTE15         => HLTH_INS_REC.ATTRIBUTE15,
                  X_ATTRIBUTE16         => HLTH_INS_REC.ATTRIBUTE16,
                  X_ATTRIBUTE17         => HLTH_INS_REC.ATTRIBUTE17,
                  X_ATTRIBUTE18         => HLTH_INS_REC.ATTRIBUTE18,
                  X_ATTRIBUTE19         => HLTH_INS_REC.ATTRIBUTE19,
                  X_ATTRIBUTE20         => HLTH_INS_REC.ATTRIBUTE20,
                  X_MODE                =>  'R',
                  X_org_id => l_org_id );

                p_error_code := NULL;
                p_status := '1';

        EXCEPTION
          WHEN OTHERS THEN

                p_error_code := 'E322';
                p_status := '3';

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_007.crt_pe_hlth_ins.exception';

          l_debug_str :=  'IGS_AD_IMP_007.PRC_PE_HLTH_INS_DTLS.Crt_Pe_hlth_ins ' ||
                               'Status : 3' ||  'ErrorCode : E322 insert failed ' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(HLTH_INS_REC.Interface_hlth_Id,'E322','IGS_AD_HLTH_INS_INT_ALL');
    END IF;

        END Crt_Pe_hlth_ins;

 PROCEDURE Validate_health_Ins(hlth_ins_rec IN HLTH_INS%ROWTYPE, l_check OUT NOCOPY VARCHAR2) AS

  CURSOR birth_dt_cur(p_person_id IGS_AD_INTERFACE.PERSON_ID%TYPE) IS
  SELECT birth_date
  FROM   igs_pe_person_base_v
  WHERE  person_id= p_person_id;

  l_var VARCHAR2(1);
  l_birth_dt  IGS_AD_INTERFACE.BIRTH_DT%TYPE;
  p_error_code IGS_AD_INTERFACE.ERROR_CODE%TYPE;

  BEGIN

    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('PE_INS_TYPE',hlth_ins_rec.insurance_cd,8405))
    THEN
      p_error_code := 'E552';
      RAISE NO_DATA_FOUND;
    END IF;

     OPEN birth_dt_cur(hlth_ins_rec.person_id);
     FETCH birth_dt_cur INTO l_birth_dt;
           IF l_birth_dt IS NOT NULL AND hlth_ins_rec.start_date < l_birth_dt THEN
              p_error_code := 'E222';
              CLOSE birth_dt_cur;
              RAISE NO_DATA_FOUND;
           END IF;
     CLOSE birth_dt_cur;

     IF hlth_ins_rec.end_date IS NOT NULL THEN
         IF hlth_ins_rec.end_date < hlth_ins_rec.start_date THEN
           p_error_code := 'E208';
           RAISE NO_DATA_FOUND;
         END IF;
     END IF;

     IF NOT igs_ad_imp_018.validate_desc_flex(
         p_attribute_category =>HLTH_INS_REC.attribute_category,
         p_attribute1         =>HLTH_INS_REC.attribute1  ,
         p_attribute2         =>HLTH_INS_REC.attribute2  ,
         p_attribute3         =>HLTH_INS_REC.attribute3  ,
         p_attribute4         =>HLTH_INS_REC.attribute4  ,
         p_attribute5         =>HLTH_INS_REC.attribute5  ,
         p_attribute6         =>HLTH_INS_REC.attribute6  ,
         p_attribute7         =>HLTH_INS_REC.attribute7  ,
         p_attribute8         =>HLTH_INS_REC.attribute8  ,
         p_attribute9         =>HLTH_INS_REC.attribute9  ,
         p_attribute10        =>HLTH_INS_REC.attribute10 ,
         p_attribute11        =>HLTH_INS_REC.attribute11 ,
         p_attribute12        =>HLTH_INS_REC.attribute12 ,
         p_attribute13        =>HLTH_INS_REC.attribute13 ,
         p_attribute14        =>HLTH_INS_REC.attribute14 ,
         p_attribute15        =>HLTH_INS_REC.attribute15 ,
         p_attribute16        =>HLTH_INS_REC.attribute16 ,
         p_attribute17        =>HLTH_INS_REC.attribute17 ,
         p_attribute18        =>HLTH_INS_REC.attribute18 ,
         p_attribute19        =>HLTH_INS_REC.attribute19 ,
         p_attribute20        =>HLTH_INS_REC.attribute20 ,
         p_desc_flex_name     =>'IGS_PE_HLTH_INS_ALL_FLEX' ) THEN

           p_error_code := 'E255';
           RAISE NO_DATA_FOUND;
     END IF;

     p_error_code := NULL;
     l_check := 'FALSE';

  EXCEPTION
    WHEN OTHERS THEN
      UPDATE igs_ad_hlth_ins_int
      SET    error_code = p_error_code,
             status = '3'
      WHERE  interface_hlth_id = hlth_ins_rec.interface_hlth_id;

      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(hlth_ins_rec.Interface_hlth_Id,p_error_code,'IGS_AD_HLTH_INS_INT_ALL');
      END IF;

      l_check := 'TRUE';
  END;

BEGIN
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_ad_imp_007.prc_pe_hlth_ins_dtls';
  l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_hlth_ins_dtls.';

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_hlth_ins_dtls.begin';
    l_debug_str := 'igs_ad_imp_007.prc_pe_hlth_ins_dtls.begin';

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

  l_rule := Igs_Ad_Imp_001.FIND_SOURCE_CAT_RULE(p_source_type_id, 'PERSON_HEALTH_INSURANCE');

  -- If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_ad_hlth_ins_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND status = cst_stat_val_2
      AND interface_run_id = l_interface_run_id;
  END IF;

  -- If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_ad_hlth_ins_int_all mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM   igs_pe_hlth_ins_all pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.person_id
             AND  pe.insurance_cd = UPPER(mi.insurance_cd)
             AND  TRUNC(pe.start_date) = TRUNC(mi.start_date) );
  END IF;

  -- If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_ad_hlth_ins_int_all
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status=cst_stat_val_2;
  END IF;

  -- If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_ad_hlth_ins_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25))
      AND status=cst_stat_val_2;
  END IF;

  -- If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_ad_hlth_ins_int_all mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM igs_pe_hlth_ins_all pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.person_id
             AND  pe.insurance_cd = UPPER(mi.insurance_cd)
             AND  TRUNC(pe.start_date) = TRUNC(mi.start_date)
                     AND  UPPER(pe.insurance_provider) = UPPER(mi.insurance_provider)
             AND  UPPER(pe.policy_number) = UPPER(mi.policy_number)
             AND  NVL(TRUNC(pe.end_date),igs_ge_date.igsdate('9999/01/01')) = NVL(TRUNC(mi.end_date),igs_ge_date.igsdate('9999/01/01'))
             AND  NVL(UPPER(pe.attribute1),'*!*')   = NVL(UPPER(mi.attribute1),'*!*')
             AND  NVL(UPPER(pe.attribute2),'*!*')   = NVL(UPPER(mi.attribute2),'*!*')
             AND  NVL(UPPER(pe.attribute3),'*!*')   = NVL(UPPER(mi.attribute3),'*!*')
             AND  NVL(UPPER(pe.attribute4),'*!*')   = NVL(UPPER(mi.attribute4),'*!*')
             AND  NVL(UPPER(pe.attribute5),'*!*')   = NVL(UPPER(mi.attribute5),'*!*')
             AND  NVL(UPPER(pe.attribute6),'*!*')   = NVL(UPPER(mi.attribute6),'*!*')
             AND  NVL(UPPER(pe.attribute7),'*!*')   = NVL(UPPER(mi.attribute7),'*!*')
             AND  NVL(UPPER(pe.attribute8),'*!*')   = NVL(UPPER(mi.attribute8),'*!*')
             AND  NVL(UPPER(pe.attribute9),'*!*')   = NVL(UPPER(mi.attribute9),'*!*')
             AND  NVL(UPPER(pe.attribute10),'*!*')   = NVL(UPPER(mi.attribute10),'*!*')
             AND  NVL(UPPER(pe.attribute11),'*!*')   = NVL(UPPER(mi.attribute11),'*!*')
             AND  NVL(UPPER(pe.attribute12),'*!*')   = NVL(UPPER(mi.attribute12),'*!*')
             AND  NVL(UPPER(pe.attribute13),'*!*')   = NVL(UPPER(mi.attribute13),'*!*')
             AND  NVL(UPPER(pe.attribute14),'*!*')   = NVL(UPPER(mi.attribute14),'*!*')
             AND  NVL(UPPER(pe.attribute15),'*!*')   = NVL(UPPER(mi.attribute15),'*!*')
             AND  NVL(UPPER(pe.attribute16),'*!*')   = NVL(UPPER(mi.attribute16),'*!*')
             AND  NVL(UPPER(pe.attribute17),'*!*')   = NVL(UPPER(mi.attribute17),'*!*')
             AND  NVL(UPPER(pe.attribute18),'*!*')   = NVL(UPPER(mi.attribute18),'*!*')
             AND  NVL(UPPER(pe.attribute19),'*!*')   = NVL(UPPER(mi.attribute19),'*!*')
             AND  NVL(UPPER(pe.attribute20),'*!*')   = NVL(UPPER(mi.attribute20),'*!*')
             );
  END IF;

  -- If rule in R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_ad_hlth_ins_int_all mi
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_20,
    dup_hlth_ins_id = (SELECT health_ins_id
                            FROM   igs_pe_hlth_ins_all pe, igs_ad_interface_all ii
                                WHERE  ii.interface_run_id = l_interface_run_id
                          AND  ii.interface_id = mi.interface_id
                  AND  ii.person_id = pe.person_id
                  AND  pe.insurance_cd = UPPER(mi.insurance_cd)
                  AND  TRUNC(pe.start_date) = TRUNC(mi.start_date))
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS (SELECT '1'
                  FROM   igs_pe_hlth_ins_all pe, igs_ad_interface_all ii
                  WHERE  ii.interface_run_id = l_interface_run_id
            AND  ii.interface_id = mi.interface_id
            AND  ii.person_id = pe.person_id
            AND  pe.insurance_cd = UPPER(mi.insurance_cd)
            AND  TRUNC(pe.start_date) = TRUNC(mi.start_date));
  END IF;

  FOR hlth_ins_rec IN hlth_ins(l_interface_run_id) LOOP

    l_processed_records := l_processed_records + 1;

    l_check := 'FALSE';
    hlth_ins_rec.start_date := TRUNC(hlth_ins_rec.start_date);
    hlth_ins_rec.end_date := TRUNC(hlth_ins_rec.end_date);
    hlth_ins_rec.INSURANCE_CD := UPPER(hlth_ins_rec.INSURANCE_CD);

    Validate_health_ins(hlth_ins_rec,l_check);

    IF l_check <> 'TRUE' THEN
      DECLARE
      CURSOR chk_dup_pe_hlthins(cp_insurance_cd VARCHAR2,
                                cp_person_id NUMBER,
                                cp_start_date IGS_AD_HLTH_INS_INT.START_DATE%TYPE) IS
      SELECT rowid, hi.*
         FROM  igs_pe_hlth_ins hi
         WHERE hi.person_id = cp_person_id
         AND   UPPER(hi.insurance_cd) = UPPER(cp_insurance_cd)
         AND   TRUNC(hi.start_date) = TRUNC(cp_start_date);
      dup_pe_hlthins_rec chk_dup_pe_hlthins%ROWTYPE;
      BEGIN
      dup_pe_hlthins_rec.insurance_cd := NULL;
      OPEN chk_dup_pe_hlthins(hlth_ins_rec.insurance_cd,
                            hlth_ins_rec.person_id,
                            hlth_ins_rec.start_date);
      FETCH chk_dup_pe_hlthins INTO dup_pe_hlthins_rec;
      CLOSE chk_dup_pe_hlthins;
      IF dup_pe_hlthins_rec.insurance_cd IS NOT NULL THEN
    IF l_rule = 'I'  THEN
          BEGIN
      igs_pe_hlth_ins_pkg.update_row(
                     x_rowid=>dup_pe_hlthins_rec.rowid,
                     x_health_ins_id=>dup_pe_hlthins_rec.health_ins_id,
                     x_person_id=>dup_pe_hlthins_rec.person_id,
                     x_insurance_provider=> NVL(hlth_ins_rec.insurance_provider,dup_pe_hlthins_rec.insurance_provider),
                     x_policy_number=> NVL(hlth_ins_rec.policy_number,dup_pe_hlthins_rec.policy_number),
                     x_start_date=> NVL(hlth_ins_rec.start_date,dup_pe_hlthins_rec.start_date),
                     x_end_date=> NVL(hlth_ins_rec.end_date,dup_pe_hlthins_rec.end_date),
                      X_ATTRIBUTE_CATEGORY      => NVL(HLTH_INS_REC.ATTRIBUTE_CATEGORY, dup_pe_hlthins_rec.ATTRIBUTE_CATEGORY),
                      X_ATTRIBUTE1          => NVL(HLTH_INS_REC.ATTRIBUTE1,  dup_pe_hlthins_rec.ATTRIBUTE1),
                      X_ATTRIBUTE2          => NVL(HLTH_INS_REC.ATTRIBUTE2,  dup_pe_hlthins_rec.ATTRIBUTE2),
                      X_ATTRIBUTE3          => NVL(HLTH_INS_REC.ATTRIBUTE3,  dup_pe_hlthins_rec.ATTRIBUTE3),
                      X_ATTRIBUTE4          => NVL(HLTH_INS_REC.ATTRIBUTE4,  dup_pe_hlthins_rec.ATTRIBUTE4),
                      X_ATTRIBUTE5          => NVL(HLTH_INS_REC.ATTRIBUTE5,  dup_pe_hlthins_rec.ATTRIBUTE5),
                      X_ATTRIBUTE6          => NVL(HLTH_INS_REC.ATTRIBUTE6,  dup_pe_hlthins_rec.ATTRIBUTE6),
                      X_ATTRIBUTE7          => NVL(HLTH_INS_REC.ATTRIBUTE7,  dup_pe_hlthins_rec.ATTRIBUTE7),
                      X_ATTRIBUTE8          => NVL(HLTH_INS_REC.ATTRIBUTE8,  dup_pe_hlthins_rec.ATTRIBUTE8),
                      X_ATTRIBUTE9          => NVL(HLTH_INS_REC.ATTRIBUTE9,  dup_pe_hlthins_rec.ATTRIBUTE9),
                      X_ATTRIBUTE10         => NVL(HLTH_INS_REC.ATTRIBUTE10,  dup_pe_hlthins_rec.ATTRIBUTE10),
                      X_ATTRIBUTE11         => NVL(HLTH_INS_REC.ATTRIBUTE11,  dup_pe_hlthins_rec.ATTRIBUTE11),
                      X_ATTRIBUTE12         => NVL(HLTH_INS_REC.ATTRIBUTE12,  dup_pe_hlthins_rec.ATTRIBUTE12),
                      X_ATTRIBUTE13         => NVL(HLTH_INS_REC.ATTRIBUTE13,  dup_pe_hlthins_rec.ATTRIBUTE13),
                      X_ATTRIBUTE14         => NVL(HLTH_INS_REC.ATTRIBUTE14,  dup_pe_hlthins_rec.ATTRIBUTE14),
                      X_ATTRIBUTE15         => NVL(HLTH_INS_REC.ATTRIBUTE15,  dup_pe_hlthins_rec.ATTRIBUTE15),
                      X_ATTRIBUTE16         => NVL(HLTH_INS_REC.ATTRIBUTE16,  dup_pe_hlthins_rec.ATTRIBUTE16),
                      X_ATTRIBUTE17         => NVL(HLTH_INS_REC.ATTRIBUTE17,  dup_pe_hlthins_rec.ATTRIBUTE17),
                      X_ATTRIBUTE18         => NVL(HLTH_INS_REC.ATTRIBUTE18,  dup_pe_hlthins_rec.ATTRIBUTE18),
                      X_ATTRIBUTE19         => NVL(HLTH_INS_REC.ATTRIBUTE19,  dup_pe_hlthins_rec.ATTRIBUTE19),
                      X_ATTRIBUTE20         => NVL(HLTH_INS_REC.ATTRIBUTE20,  dup_pe_hlthins_rec.ATTRIBUTE20),
                      x_mode =>'R',
                      x_insurance_cd=> NVL(hlth_ins_rec.insurance_cd,dup_pe_hlthins_rec.insurance_cd));

        UPDATE igs_ad_hlth_ins_int
                SET    error_code  = NULL,
                       match_ind = cst_mi_val_18,
                       status = cst_stat_val_1
                WHERE  interface_hlth_id = hlth_ins_rec.interface_hlth_id;
          EXCEPTION
            WHEN OTHERS THEN
              UPDATE igs_ad_hlth_ins_int
              SET    error_code  = 'E014',
                     status = '3'
              WHERE  interface_hlth_id = hlth_ins_rec.interface_hlth_id;
          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_hlth_ins_dtls.exception1';

              l_debug_str :=  'IGS_AD_IMP_007.PRC_PE_HLTH_INS_DTLS ' ||
                               'Interface Health Id : ' || hlth_ins_rec.INTERFACE_HLTH_ID ||
                               ' Status : 3 ' ||  'ErrorCode : E014 Update Failed ' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(hlth_ins_rec.INTERFACE_HLTH_ID,'E014','IGS_AD_HLTH_INS_INT_ALL');
        END IF;


          END;
    ELSIF l_rule = 'R' THEN
          IF hlth_ins_rec.MATCH_IND = '21' THEN
            BEGIN
          igs_pe_hlth_ins_pkg.update_row(
                     x_rowid=>dup_pe_hlthins_rec.rowid,
                     x_health_ins_id=>dup_pe_hlthins_rec.health_ins_id,
                     x_person_id=>dup_pe_hlthins_rec.person_id,
                     x_insurance_cd=> NVL(hlth_ins_rec.insurance_cd,dup_pe_hlthins_rec.insurance_cd),
                     x_insurance_provider=> NVL(hlth_ins_rec.insurance_provider,dup_pe_hlthins_rec.insurance_provider),
                     x_policy_number=> NVL(hlth_ins_rec.policy_number,dup_pe_hlthins_rec.policy_number),
                     x_start_date=> NVL(hlth_ins_rec.start_date,dup_pe_hlthins_rec.start_date),
                     x_end_date=> NVL(hlth_ins_rec.end_date,dup_pe_hlthins_rec.end_date),
                      X_ATTRIBUTE_CATEGORY      => NVL(HLTH_INS_REC.ATTRIBUTE_CATEGORY, dup_pe_hlthins_rec.ATTRIBUTE_CATEGORY),
                      X_ATTRIBUTE1          => NVL(HLTH_INS_REC.ATTRIBUTE1,  dup_pe_hlthins_rec.ATTRIBUTE1),
                      X_ATTRIBUTE2          => NVL(HLTH_INS_REC.ATTRIBUTE2,  dup_pe_hlthins_rec.ATTRIBUTE2),
                      X_ATTRIBUTE3          => NVL(HLTH_INS_REC.ATTRIBUTE3,  dup_pe_hlthins_rec.ATTRIBUTE3),
                      X_ATTRIBUTE4          => NVL(HLTH_INS_REC.ATTRIBUTE4,  dup_pe_hlthins_rec.ATTRIBUTE4),
                      X_ATTRIBUTE5          => NVL(HLTH_INS_REC.ATTRIBUTE5,  dup_pe_hlthins_rec.ATTRIBUTE5),
                      X_ATTRIBUTE6          => NVL(HLTH_INS_REC.ATTRIBUTE6,  dup_pe_hlthins_rec.ATTRIBUTE6),
                      X_ATTRIBUTE7          => NVL(HLTH_INS_REC.ATTRIBUTE7,  dup_pe_hlthins_rec.ATTRIBUTE7),
                      X_ATTRIBUTE8          => NVL(HLTH_INS_REC.ATTRIBUTE8,  dup_pe_hlthins_rec.ATTRIBUTE8),
                      X_ATTRIBUTE9          => NVL(HLTH_INS_REC.ATTRIBUTE9,  dup_pe_hlthins_rec.ATTRIBUTE9),
                      X_ATTRIBUTE10         => NVL(HLTH_INS_REC.ATTRIBUTE10,  dup_pe_hlthins_rec.ATTRIBUTE10),
                      X_ATTRIBUTE11         => NVL(HLTH_INS_REC.ATTRIBUTE11,  dup_pe_hlthins_rec.ATTRIBUTE11),
                      X_ATTRIBUTE12         => NVL(HLTH_INS_REC.ATTRIBUTE12,  dup_pe_hlthins_rec.ATTRIBUTE12),
                      X_ATTRIBUTE13         => NVL(HLTH_INS_REC.ATTRIBUTE13,  dup_pe_hlthins_rec.ATTRIBUTE13),
                      X_ATTRIBUTE14         => NVL(HLTH_INS_REC.ATTRIBUTE14,  dup_pe_hlthins_rec.ATTRIBUTE14),
                      X_ATTRIBUTE15         => NVL(HLTH_INS_REC.ATTRIBUTE15,  dup_pe_hlthins_rec.ATTRIBUTE15),
                      X_ATTRIBUTE16         => NVL(HLTH_INS_REC.ATTRIBUTE16,  dup_pe_hlthins_rec.ATTRIBUTE16),
                      X_ATTRIBUTE17         => NVL(HLTH_INS_REC.ATTRIBUTE17,  dup_pe_hlthins_rec.ATTRIBUTE17),
                      X_ATTRIBUTE18         => NVL(HLTH_INS_REC.ATTRIBUTE18,  dup_pe_hlthins_rec.ATTRIBUTE18),
                      X_ATTRIBUTE19         => NVL(HLTH_INS_REC.ATTRIBUTE19,  dup_pe_hlthins_rec.ATTRIBUTE19),
                      X_ATTRIBUTE20         => NVL(HLTH_INS_REC.ATTRIBUTE20,  dup_pe_hlthins_rec.ATTRIBUTE20),
                      x_mode =>'R');
                   UPDATE igs_ad_hlth_ins_int
                   SET    error_code  = NULL,
                          match_ind = cst_mi_val_18,
                          status = cst_stat_val_1
                   WHERE  interface_hlth_id = hlth_ins_rec.interface_hlth_id;
            EXCEPTION
              WHEN OTHERS THEN
                UPDATE igs_ad_hlth_ins_int
                SET    error_code  = 'E014',
                       status = '3'
                WHERE interface_hlth_id = hlth_ins_rec.interface_hlth_id;
      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_hlth_ins_dtls.exception2';

          l_debug_str :=  'IGS_AD_IMP_007.PRC_PE_HLTH_INS_DTLS ' ||
                               'Interface Health Id : ' || (hlth_ins_rec.INTERFACE_HLTH_ID) ||
                               'Status : 3' ||  'ErrorCode : E014 update Failed ' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(hlth_ins_rec.INTERFACE_HLTH_ID,'E014','IGS_AD_HLTH_INS_INT_ALL');
        END IF;
          END;
          END IF;  -- if match_ind
        END IF;  -- if rule
      ELSE
        crt_pe_hlth_ins(hlth_ins_rec,
                          l_error_code,
                          l_status);

        UPDATE IGS_AD_HLTH_INS_INT
        SET status = l_status,
            error_code = l_error_code
        WHERE INTERFACE_HLTH_ID = hlth_ins_rec.INTERFACE_HLTH_ID;
      END IF; -- if dup
    END;
    END IF;  -- if l_check
    IF l_processed_records = 100 THEN
      COMMIT;
      l_processed_records := 0;
    END IF;
  END LOOP; -- end for
END prc_pe_hlth_ins_dtls;
 --Health and insurance details

PROCEDURE prc_pe_hlth_dtls
 (   P_SOURCE_TYPE_ID     IN      NUMBER,
     P_BATCH_ID   IN      NUMBER )
 AS
 /*
      ||  Created By : adhawan
      ||  Created On :19-nov-2001
      ||  Purpose : This procedure process the Immunization Details
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      || npalanis         6-JAN-2003      Bug : 2734697
      ||                                  code added to commit after import of every
      ||                                  100 records .New variable l_processed_records added
      ||  adhawan       12-Nov-2001     Bug no.2103692:Person Interface DLD
      ||                                 New procedure created for processing the immunization details, health details
      ||                                 of the person
      ||
      ||  (reverse chronological order - newest change first)
        */
  BEGIN
    prc_pe_immu_dtls(P_SOURCE_TYPE_ID, P_BATCH_ID);
    prc_pe_hlth_ins_dtls (P_SOURCE_TYPE_ID, P_BATCH_ID);
END prc_pe_hlth_dtls;

PROCEDURE prc_pe_id_types
(
       P_SOURCE_TYPE_ID IN  NUMBER,
       P_BATCH_ID   IN  NUMBER ) AS
    /*
      ||  Created By :
      ||  Created On :
      ||  Purpose : This procedure process the Application
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  pkpatel        15-JAN-2003     Bug NO: 2397876
      ||                                 Added all the missing validations and corresponding error codes
      || npalanis         6-JAN-2003      Bug : 2734697
      ||                                  code added to commit after import of every
      ||                                  100 records .New variable l_processed_records added
      ||  pkpatel        01-DEC-2002     Bug NO: 2599109 (Sevis DLD)
      ||                                 Added the validation for REGION_CODE
      ||  npalanis       26-May-2002     Bug no - 2377751
      ||                                 New error codes registered and added
      ||  sarakshi       12-Nov-2001     Bug no.2103692:Person Interface DLD
      ||                                 Added the DFF validation before insert/update to the oss table, also in
      ||                                 the call to insert_row/update_row to the oss table adding the dff columns
      ||  (reverse chronological order - newest change first)
        */


  -- Logic for IGS_AD_IMPORT_PERSON_ID_TYPES
  -- Create the cursor using the following select statement.

  CURSOR API(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
  SELECT     mi.*, i.person_id
  FROM   igs_ad_api_int_all mi,   igs_ad_interface_all I
  WHERE  mi.interface_run_id = cp_interface_run_id
      AND  mi.interface_id =  i.interface_id
      AND  i.interface_run_id = cp_interface_run_id
      AND  mi.status = '2'
      AND  i.status = '1';

  CURSOR check_dur_cur(api_rec api%ROWTYPE) IS
  SELECT ROWID,pi.*
  FROM   igs_pe_alt_pers_id pi
  WHERE  pe_person_id = api_rec.person_id
    AND  api_person_id  = api_rec.alternate_id
    AND  UPPER(person_id_type) = UPPER(api_rec.person_id_type)
    AND  TRUNC(start_dt) = TRUNC(api_rec.start_dt);

 CURSOR source_type_cur(cp_source_type igs_pe_src_types_all.source_type%TYPE) Is
 SELECT source_type_id
 FROM  igs_pe_src_types_all
 WHERE source_type = cp_source_type;

  check_dur_rec check_dur_cur%ROWTYPE;
  lnDupExist VARCHAR2(1);
  l_exists    VARCHAR2(1);
  l_rule VARCHAR2(1);
  lvcRecordExist  VARCHAR2(1);
  l_error_code VARCHAR2(10);
  l_status VARCHAR2(10);
  l_processed_records NUMBER(5) := 0;
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_message_name  VARCHAR2(30);
  l_app           VARCHAR2(50);
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
  l_ucas_action          VARCHAR2(1);
  l_ucas_error_code VARCHAR2(10);
  l_call_ucas_user_hook  BOOLEAN;
  l_source_type_id1 NUMBER;
  l_source_type_id2 NUMBER;

FUNCTION validate_api(p_api_rec IN api%ROWTYPE )
RETURN BOOLEAN AS
   /*
      ||  Created By : pkpatel
      ||  Created On : 10-JUN-2002
      ||  Purpose : Bug No:2402077 Validate the Person ID type and Format mask for Alternate ID
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  skpandey        09-Jan-2006     Bug#4178224
      ||                                  Changed the definition of region_cd_cur cursor as a part of New Geography Model
      ||  gmaheswa      29-Sep-2004       BUG 3787210 Added Closed indicator check for the Alternate Person Id type.
      ||  (reverse chronological order - newest change first)
   */
  l_error_code  VARCHAR2(30);
  l_exists      VARCHAR2(1);

  CURSOR api_type_cur(cp_person_id_type igs_pe_person_id_typ.person_id_type%TYPE) IS
  SELECT format_mask, region_ind
  FROM   igs_pe_person_id_typ
  WHERE  person_id_type = cp_person_id_type
  AND closed_ind = 'N';

  CURSOR region_cd_cur(cp_geography_type hz_geographies.geography_type%TYPE, cp_geography_cd hz_geographies.geography_code%TYPE, cp_country_cd hz_geographies.country_code%TYPE) IS
	SELECT 'X'
	FROM hz_geographies
	WHERE GEOGRAPHY_TYPE = cp_geography_type
	AND geography_code = cp_geography_cd
	AND COUNTRY_CODE = cp_country_cd;

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

      l_error_code:='E255';
      RAISE NO_DATA_FOUND;
    END IF;
            --validate Person ID type
    OPEN  api_type_cur(p_api_rec.person_id_type);
    FETCH api_type_cur INTO api_type_rec;
    IF api_type_cur%NOTFOUND THEN
      CLOSE api_type_cur;
      l_error_code:='E258';
      RAISE NO_DATA_FOUND;
    ELSE
      CLOSE api_type_cur;
    END IF;

            -- Validate the format mask
    IF api_type_rec.format_mask IS NOT NULL THEN
      IF NOT igs_en_val_api.fm_equal(p_api_rec.alternate_id,api_type_rec.format_mask) THEN
        l_error_code:='E268';
        RAISE NO_DATA_FOUND;
      END IF;
    END IF;

          -- Validation for Region Code
    IF api_type_rec.region_ind IS NULL OR api_type_rec.region_ind = 'N' THEN
      IF p_api_rec.region_cd IS NOT NULL THEN
        l_error_code:='E573';
        RAISE NO_DATA_FOUND;
      END IF;
    ELSE
      IF p_api_rec.region_cd IS NULL THEN
        l_error_code:='E574';
        RAISE NO_DATA_FOUND;
      ELSE
        OPEN region_cd_cur('STATE',p_api_rec.region_cd, FND_PROFILE.VALUE('OSS_COUNTRY_CODE'));
        FETCH region_cd_cur INTO l_exists;
        IF region_cd_cur%NOTFOUND THEN
          CLOSE region_cd_cur;
          l_error_code:='E575';
          RAISE NO_DATA_FOUND;
        END IF;
        CLOSE region_cd_cur;
      END IF;
    END IF;

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      UPDATE igs_ad_api_int_all
      SET    status = '3',
             error_code = l_error_code
      WHERE  interface_api_id = p_api_rec.interface_api_id;

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_007.validate_api.exception';

          l_debug_str :=  'Igs_Ad_Imp_007.PRC_PE_ID_TYPES.validate_api '
                                   ||'Validation Failed '
                                   ||'Interface_Api_Id:'
                                   ||IGS_GE_NUMBER.TO_CANN(p_api_rec.Interface_api_Id)
                                   ||' Status:3 '
                                   ||'Error Code:'||l_error_code||' ' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(p_api_rec.Interface_api_Id,l_error_code);
    END IF;

      RETURN FALSE;
END validate_api;

PROCEDURE crt_person_id_types
          (p_api_rec IN API%ROWTYPE,
           p_error_code OUT NOCOPY VARCHAR2,
           p_status OUT NOCOPY VARCHAR2) AS
    /*
      ||  Created By : nsinha
      ||  Created On : 22-JUN-2001
      ||  Purpose : This procedure process the Application
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  sarakshi       12-Nov-2001     Bug no.2103692:Person Interface DLD
      ||                                 Added the DFF validation before insert to the oss table, also in
      ||                                 the call to insert_row to the oss table adding the dff columns
      ||  pkpatel       25-JUN-2001      Bug no.1834307 :Modeling and Forecasting SDQ DLD
      ||                                 Modified code to refer igs_ad_interface_dtl_dscp_v instead of
      ||                                 igs_ad_interface due to change in signature of Igs_Ad_Imp_002.Update_Person .
      ||  (reverse chronological order - newest change first)
        */

  l_rowid VARCHAR2(25);
  l_message_name  VARCHAR2(30);
  l_app           VARCHAR2(50);
  BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_007.crt_person_id_types.begin';
    l_debug_str :=  'Interface Api Id : '|| p_api_rec.interface_api_id ;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

    SAVEPOINT before_api_insert;
    igs_pe_alt_pers_id_pkg.insert_row(
                 X_ROWID              =>l_rowid,
                 X_PE_PERSON_ID       =>p_api_rec.person_id,
                 X_API_PERSON_ID      =>p_api_rec.alternate_id,
                 X_PERSON_ID_TYPE     =>p_api_rec.person_id_type,
                 X_START_DT           =>p_api_rec.start_dt,
                 X_END_DT             =>p_api_rec.end_dt,
                 X_MODE               =>'R',
                 X_ATTRIBUTE_CATEGORY =>p_api_rec.attribute_category  ,
                 X_ATTRIBUTE1         =>p_api_rec.attribute1  ,
                 X_ATTRIBUTE2         =>p_api_rec.attribute2  ,
                 X_ATTRIBUTE3         =>p_api_rec.attribute3  ,
                 X_ATTRIBUTE4         =>p_api_rec.attribute4  ,
                 X_ATTRIBUTE5         =>p_api_rec.attribute5  ,
                 X_ATTRIBUTE6         =>p_api_rec.attribute6  ,
                 X_ATTRIBUTE7         =>p_api_rec.attribute7  ,
                 X_ATTRIBUTE8         =>p_api_rec.attribute8  ,
                 X_ATTRIBUTE9         =>p_api_rec.attribute9  ,
                 X_ATTRIBUTE10        =>p_api_rec.attribute10 ,
                 X_ATTRIBUTE11        =>p_api_rec.attribute11 ,
                 X_ATTRIBUTE12        =>p_api_rec.attribute12 ,
                 X_ATTRIBUTE13        =>p_api_rec.attribute13 ,
                 X_ATTRIBUTE14        =>p_api_rec.attribute14 ,
                 X_ATTRIBUTE15        =>p_api_rec.attribute15 ,
                 X_ATTRIBUTE16        =>p_api_rec.attribute16 ,
                 X_ATTRIBUTE17        =>p_api_rec.attribute17 ,
                 X_ATTRIBUTE18        =>p_api_rec.attribute18 ,
                 X_ATTRIBUTE19        =>p_api_rec.attribute19 ,
                 X_ATTRIBUTE20        =>p_api_rec.attribute20 ,
                 X_REGION_CD          =>p_api_rec.region_cd );

    p_error_code := NULL;
    p_status := '1';

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO before_api_insert;
        -- To find the message name raised from the TBH
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

      l_label := 'igs.plsql.igs_ad_imp_007.crt_person_id_types.exception ' || p_error_code;

      l_debug_str :=  'IGS_AD_IMP_007.PRC_PE_ID_TYPES.crt_person_id_types, Interface Api Id : '
             || p_api_rec.interface_api_id ||' Status : '|| p_status ||  ' ErrorCode : '||
             p_error_code||  ' SQLERRM: '||SQLERRM;

      fnd_log.string_with_context( fnd_log.level_exception,
                  l_label,
                  l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
    END IF;
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(p_api_rec.interface_api_id,p_error_code);
    END IF;

END crt_person_id_types;


  BEGIN
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_ad_imp_007.prc_pe_id_types';
  l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_id_types.';

  -- Check whether UCAS user hook needs to be called. It is to be called only for UCAS PER and UCAS APPL source categories.
  OPEN source_type_cur('UCAS PER');
  FETCH source_type_cur INTO l_source_type_id1;
  CLOSE source_type_cur;

  OPEN source_type_cur('UCAS APPL');
  FETCH source_type_cur INTO l_source_type_id2;
  CLOSE source_type_cur;

  IF ((l_source_type_id1 = p_source_type_id) OR (l_source_type_id2 = p_source_type_id ))THEN
    l_call_ucas_user_hook := TRUE;
  END IF;

  l_rule :=  IGS_AD_IMP_001.FIND_SOURCE_CAT_RULE(
                               P_SOURCE_TYPE_ID     =>  P_SOURCE_TYPE_ID,
                               P_CATEGORY       =>  'PERSON_ID_TYPES');

  -- If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_ad_api_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND interface_run_id = l_interface_run_id
      AND status = cst_stat_val_2;
  END IF;

  -- If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_ad_api_int_all mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM   igs_pe_alt_pers_id pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.pe_person_id
             AND  UPPER(pe.api_person_id) = UPPER(mi.alternate_id)
             AND  UPPER(pe.person_id_type) = UPPER(mi.person_id_type)
                     AND  TRUNC(pe.start_dt) = TRUNC(mi.start_dt) );
  END IF;

  -- If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_ad_api_int_all
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status = cst_stat_val_2;
  END IF;

  -- If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_ad_api_int_all
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25))
      AND status = cst_stat_val_2;
  END IF;

  -- If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_ad_api_int_all mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM igs_pe_alt_pers_id pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.pe_person_id
             AND  UPPER(pe.api_person_id) = UPPER(mi.alternate_id)
             AND  UPPER(pe.person_id_type) = UPPER(mi.person_id_type)
                     AND  TRUNC(pe.start_dt) = TRUNC(mi.start_dt)
             AND  NVL(TRUNC(pe.end_dt),igs_ge_date.igsdate('9999/01/01'))=NVL(TRUNC(mi.end_dt),igs_ge_date.igsdate('9999/01/01'))
             AND NVL(UPPER(pe.attribute_category), '*') = NVL(UPPER(mi.attribute_category), '*')
             AND NVL(UPPER(pe.region_cd), '*')   = NVL(UPPER(mi.region_cd), '*')
             AND  NVL(UPPER(pe.attribute1),'*!*')   = NVL(UPPER(mi.attribute1),'*!*')
             AND  NVL(UPPER(pe.attribute2),'*!*')   = NVL(UPPER(mi.attribute2),'*!*')
             AND  NVL(UPPER(pe.attribute3),'*!*')   = NVL(UPPER(mi.attribute3),'*!*')
             AND  NVL(UPPER(pe.attribute4),'*!*')   = NVL(UPPER(mi.attribute4),'*!*')
             AND  NVL(UPPER(pe.attribute5),'*!*')   = NVL(UPPER(mi.attribute5),'*!*')
             AND  NVL(UPPER(pe.attribute6),'*!*')   = NVL(UPPER(mi.attribute6),'*!*')
             AND  NVL(UPPER(pe.attribute7),'*!*')   = NVL(UPPER(mi.attribute7),'*!*')
             AND  NVL(UPPER(pe.attribute8),'*!*')   = NVL(UPPER(mi.attribute8),'*!*')
             AND  NVL(UPPER(pe.attribute9),'*!*')   = NVL(UPPER(mi.attribute9),'*!*')
             AND  NVL(UPPER(pe.attribute10),'*!*')   = NVL(UPPER(mi.attribute10),'*!*')
             AND  NVL(UPPER(pe.attribute11),'*!*')   = NVL(UPPER(mi.attribute11),'*!*')
             AND  NVL(UPPER(pe.attribute12),'*!*')   = NVL(UPPER(mi.attribute12),'*!*')
             AND  NVL(UPPER(pe.attribute13),'*!*')   = NVL(UPPER(mi.attribute13),'*!*')
             AND  NVL(UPPER(pe.attribute14),'*!*')   = NVL(UPPER(mi.attribute14),'*!*')
             AND  NVL(UPPER(pe.attribute15),'*!*')   = NVL(UPPER(mi.attribute15),'*!*')
             AND  NVL(UPPER(pe.attribute16),'*!*')   = NVL(UPPER(mi.attribute16),'*!*')
             AND  NVL(UPPER(pe.attribute17),'*!*')   = NVL(UPPER(mi.attribute17),'*!*')
             AND  NVL(UPPER(pe.attribute18),'*!*')   = NVL(UPPER(mi.attribute18),'*!*')
             AND  NVL(UPPER(pe.attribute19),'*!*')   = NVL(UPPER(mi.attribute19),'*!*')
             AND  NVL(UPPER(pe.attribute20),'*!*')   = NVL(UPPER(mi.attribute20),'*!*')
             );
  END IF;
  -- If rule in R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_ad_api_int_all mi
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_20
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS (SELECT '1'
                  FROM igs_pe_alt_pers_id pe, igs_ad_interface_all ii
          WHERE mi.interface_run_id = l_interface_run_id
          AND  ii.interface_id = mi.interface_id
              AND  ii.person_id = pe.pe_person_id
          AND  UPPER(pe.api_person_id) = UPPER(mi.alternate_id)
          AND  UPPER(pe.person_id_type) = UPPER(mi.person_id_type)
                  AND  TRUNC(pe.start_dt) = TRUNC(mi.start_dt) );
  END IF;

   FOR api_rec IN api(l_interface_run_id) LOOP
     l_processed_records := l_processed_records + 1 ;
    api_rec.person_id_type := UPPER(api_rec.person_id_type);
    api_rec.alternate_id := UPPER(api_rec.alternate_id);
    api_rec.start_dt :=  TRUNC(api_rec.start_dt);
    api_rec.end_dt :=  TRUNC(api_rec.end_dt);
    IF api_rec.start_dt IS NULL THEN
      api_rec.start_dt := TRUNC(SYSDATE);
    ELSE
      api_rec.start_dt := TRUNC(api_rec.start_dt);
    END IF;
    -- Validate the record. If successful then process.
    IF validate_api(api_rec) THEN
     --  Fetch this into a record called API_REC.
    --  Find the duplicate alternate person id for a person using the following SQL statement.
      check_dur_rec.person_id_type := NULL;

      IF ((l_call_ucas_user_hook) AND (api_rec.person_id_type IN ('UCASID','NMASID','SWASID','GTTRID','UCASREGNO'))) THEN

	  igs_pe_pers_imp_001.validate_ucas_id(api_rec.alternate_id,api_rec.person_id,api_rec.person_id_type,l_ucas_action,l_ucas_error_code);

	/* S - Skip the record.
           P - Proceed with the record.
           E - Error out the record.
        */
           IF (l_ucas_action = 'S')
	   THEN
	      -- Skip the record, no action reqd. Just mark it as processed.
		 UPDATE IGS_AD_API_INT_ALL
		 SET ERROR_CODE  = NULL,
		 STATUS = '1'
		 WHERE INTERFACE_API_ID  = API_REC.INTERFACE_API_ID;
	   ELSIF (l_ucas_action = 'E')
	   THEN
	     -- Skip the record and set the error code.
	       UPDATE IGS_AD_API_INT_ALL
	       SET error_code  = l_ucas_error_code,
	       STATUS = '3'
	       WHERE interface_api_id  = api_rec.interface_api_id;
	   ELSE
	   -- Process the record in case of 'P'. Create a new record.
	       crt_person_id_types(p_api_rec=>api_rec,p_error_code=>l_error_code,p_status=>l_status);

		 UPDATE IGS_AD_API_INT_ALL
		 SET ERROR_CODE  = l_error_code,
		     STATUS = l_status
		 WHERE INTERFACE_API_ID  = API_REC.INTERFACE_API_ID;

	   END IF;
      ELSE  -- Either source category is not UCAS PER / UCAS APPL or the ID being passed is not from the 4 UCAS IDs, do the normal processing.

      OPEN check_dur_cur(api_rec);
      FETCH check_dur_cur INTO check_dur_rec;
      CLOSE check_dur_cur;
      IF check_dur_rec.person_id_type IS NOT NULL THEN
           --The person id type already exits. In this case find out NOCOPY the discrepancy action
           -- using the function. Call FIND_SOURCE_CAT_RULE with the following values.
           --   And the returned action is obtained in a variable lvcAction.
        IF l_rule  = 'R' THEN
          IF api_rec.match_ind = '21' THEN
           BEGIN
             SAVEPOINT before_api_update;

              igs_pe_alt_pers_id_pkg.update_row(
                           x_rowid              =>check_dur_rec.rowid,
                           x_pe_person_id       =>check_dur_rec.pe_person_id,
                           x_api_person_id      =>check_dur_rec.api_person_id,
                           x_person_id_type     =>NVL(api_rec.person_id_type,check_dur_rec.person_id_type),
                           x_start_dt           => NVL(api_rec.start_dt,check_dur_rec.start_dt),
                           x_end_dt             => NVL(api_rec.end_dt,check_dur_rec.end_dt),
                           x_mode               => 'R',
                           X_ATTRIBUTE_CATEGORY =>NVL(api_rec.attribute_category  ,check_dur_rec.attribute_category),
                           X_ATTRIBUTE1         =>NVL(api_rec.attribute1  ,check_dur_rec.attribute1),
                           X_ATTRIBUTE2         =>NVL(api_rec.attribute2  ,check_dur_rec.attribute2),
                           X_ATTRIBUTE3         =>NVL(api_rec.attribute3  ,check_dur_rec.attribute3),
                           X_ATTRIBUTE4         =>NVL(api_rec.attribute4  ,check_dur_rec.attribute4),
                           X_ATTRIBUTE5         =>NVL(api_rec.attribute5  ,check_dur_rec.attribute5),
                           X_ATTRIBUTE6         =>NVL(api_rec.attribute6  ,check_dur_rec.attribute6),
                           X_ATTRIBUTE7         =>NVL(api_rec.attribute7  ,check_dur_rec.attribute7),
                           X_ATTRIBUTE8         =>NVL(api_rec.attribute8  ,check_dur_rec.attribute8),
                           X_ATTRIBUTE9         =>NVL(api_rec.attribute9  ,check_dur_rec.attribute9),
                           X_ATTRIBUTE10        =>NVL(api_rec.attribute10 ,check_dur_rec.attribute10),
                           X_ATTRIBUTE11        =>NVL(api_rec.attribute11 ,check_dur_rec.attribute11),
                           X_ATTRIBUTE12        =>NVL(api_rec.attribute12 ,check_dur_rec.attribute12),
                           X_ATTRIBUTE13        =>NVL(api_rec.attribute13 ,check_dur_rec.attribute13),
                           X_ATTRIBUTE14        =>NVL(api_rec.attribute14 ,check_dur_rec.attribute14),
                           X_ATTRIBUTE15        =>NVL(api_rec.attribute15 ,check_dur_rec.attribute15),
                           X_ATTRIBUTE16        =>NVL(api_rec.attribute16 ,check_dur_rec.attribute16),
                           X_ATTRIBUTE17        =>NVL(api_rec.attribute17 ,check_dur_rec.attribute17),
                           X_ATTRIBUTE18        =>NVL(api_rec.attribute18 ,check_dur_rec.attribute18),
                           X_ATTRIBUTE19        =>NVL(api_rec.attribute19 ,check_dur_rec.attribute19),
                           X_ATTRIBUTE20        =>NVL(api_rec.attribute20 ,check_dur_rec.attribute20),
                           X_REGION_CD          =>NVL(api_rec.region_cd   ,check_dur_rec.region_cd));

                     UPDATE IGS_AD_API_INT_ALL
                     SET ERROR_CODE  = NULL,
                         MATCH_IND = cst_mi_val_18,
                         STATUS = cst_stat_val_1
                     WHERE INTERFACE_API_ID  = API_REC.INTERFACE_API_ID;

                 EXCEPTION
                  WHEN OTHERS THEN

                    ROLLBACK TO before_api_update;
                    -- To find the message name raised from the TBH
                    FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

                    IF l_message_name IN ('IGS_PE_PERS_ID_PRD_OVRLP', 'IGS_PE_SSN_PERS_ID_PRD_OVRLP') THEN
                       l_error_code := 'E560';

                    ELSIF l_message_name = 'IGS_PE_ALT_END_DT_VAL' THEN
                       l_error_code := 'E581';

                    ELSIF l_message_name = 'IGS_AD_STRT_DT_LESS_BIRTH_DT' THEN
                       l_error_code := 'E222';

                    ELSIF l_message_name = 'IGS_GE_INVALID_DATE' THEN
                       l_error_code := 'E208';
                    ELSE
                       l_error_code := 'E014';
                    END IF;

              IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                IF (l_request_id IS NULL) THEN
                  l_request_id := fnd_global.conc_request_id;
                END IF;

                l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_id_types.exception ' || l_error_code;

                  l_debug_str := 'IGS_AD_IMP_007.PRC_PE_ID_TYPES ' || 'Interface Api Id : '
                     || api_rec.interface_api_id || 'SQLERRM '||SQLERRM ||' Status : 3 ' ||
                     'ErrorCode : '|| l_error_code;

                fnd_log.string_with_context( fnd_log.level_exception,
                              l_label,
                              l_debug_str, NULL,
                              NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
              END IF;

                IF l_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(api_rec.interface_api_id,l_error_code);
                END IF;

                     UPDATE IGS_AD_API_INT_ALL
                     SET ERROR_CODE  = l_error_code,
                         STATUS = '3'
                     WHERE INTERFACE_API_ID  = API_REC.INTERFACE_API_ID;

               END;
              END IF;
           ELSIF l_rule = 'I' THEN
                BEGIN
                      SAVEPOINT before_api_update;

                     igs_pe_alt_pers_id_pkg.update_row(
                           x_rowid              =>check_dur_rec.rowid,
                           x_pe_person_id       =>check_dur_rec.pe_person_id,
                           x_api_person_id      =>check_dur_rec.api_person_id,
                           x_person_id_type     =>NVL(api_rec.person_id_type,check_dur_rec.person_id_type),
                           x_start_dt           => NVL(api_rec.start_dt,check_dur_rec.start_dt),
                           x_end_dt             => NVL(api_rec.end_dt,check_dur_rec.end_dt),
                           x_mode               => 'R',
                           X_ATTRIBUTE_CATEGORY =>NVL(api_rec.attribute_category  ,check_dur_rec.attribute_category),
                           X_ATTRIBUTE1         =>NVL(api_rec.attribute1  ,check_dur_rec.attribute1),
                           X_ATTRIBUTE2         =>NVL(api_rec.attribute2  ,check_dur_rec.attribute2),
                           X_ATTRIBUTE3         =>NVL(api_rec.attribute3  ,check_dur_rec.attribute3),
                           X_ATTRIBUTE4         =>NVL(api_rec.attribute4  ,check_dur_rec.attribute4),
                           X_ATTRIBUTE5         =>NVL(api_rec.attribute5  ,check_dur_rec.attribute5),
                           X_ATTRIBUTE6         =>NVL(api_rec.attribute6  ,check_dur_rec.attribute6),
                           X_ATTRIBUTE7         =>NVL(api_rec.attribute7  ,check_dur_rec.attribute7),
                           X_ATTRIBUTE8         =>NVL(api_rec.attribute8  ,check_dur_rec.attribute8),
                           X_ATTRIBUTE9         =>NVL(api_rec.attribute9  ,check_dur_rec.attribute9),
                           X_ATTRIBUTE10        =>NVL(api_rec.attribute10 ,check_dur_rec.attribute10),
                           X_ATTRIBUTE11        =>NVL(api_rec.attribute11 ,check_dur_rec.attribute11),
                           X_ATTRIBUTE12        =>NVL(api_rec.attribute12 ,check_dur_rec.attribute12),
                           X_ATTRIBUTE13        =>NVL(api_rec.attribute13 ,check_dur_rec.attribute13),
                           X_ATTRIBUTE14        =>NVL(api_rec.attribute14 ,check_dur_rec.attribute14),
                           X_ATTRIBUTE15        =>NVL(api_rec.attribute15 ,check_dur_rec.attribute15),
                           X_ATTRIBUTE16        =>NVL(api_rec.attribute16 ,check_dur_rec.attribute16),
                           X_ATTRIBUTE17        =>NVL(api_rec.attribute17 ,check_dur_rec.attribute17),
                           X_ATTRIBUTE18        =>NVL(api_rec.attribute18 ,check_dur_rec.attribute18),
                           X_ATTRIBUTE19        =>NVL(api_rec.attribute19 ,check_dur_rec.attribute19),
                           X_ATTRIBUTE20        =>NVL(api_rec.attribute20 ,check_dur_rec.attribute20),
                           X_REGION_CD          =>NVL(api_rec.region_cd   ,check_dur_rec.region_cd));

                     UPDATE IGS_AD_API_INT_ALL
                     SET ERROR_CODE  = NULL,
                         MATCH_IND = cst_mi_val_18,
                         STATUS = cst_stat_val_1
                     WHERE INTERFACE_API_ID  = API_REC.INTERFACE_API_ID;

               EXCEPTION
                  WHEN OTHERS THEN

                    ROLLBACK TO before_api_update;
                    -- To find the message name raised from the TBH
                    FND_MESSAGE.PARSE_ENCODED(FND_MESSAGE.GET_ENCODED, l_app, l_message_name);

                    IF l_message_name IN ('IGS_PE_PERS_ID_PRD_OVRLP', 'IGS_PE_SSN_PERS_ID_PRD_OVRLP') THEN
                       l_error_code := 'E560';
                    ELSIF l_message_name = 'IGS_PE_ALT_END_DT_VAL' THEN
                       l_error_code := 'E581';
                    ELSIF l_message_name = 'IGS_AD_STRT_DT_LESS_BIRTH_DT' THEN
                       l_error_code := 'E222';
                    ELSIF l_message_name = 'IGS_GE_INVALID_DATE' THEN
                       l_error_code := 'E208';
                    ELSE
                       l_error_code := 'E014';
                    END IF;

              IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                IF (l_request_id IS NULL) THEN
                  l_request_id := fnd_global.conc_request_id;
                END IF;

                l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_id_types.exception ' || l_error_code;

                  l_debug_str := 'IGS_AD_IMP_007.PRC_PE_ID_TYPES ' || 'Interface Api Id : '
                     || api_rec.interface_api_id || ' SQLERRM '||SQLERRM ||' Status : 3 ' ||
                     'ErrorCode : '|| l_error_code;

                fnd_log.string_with_context( fnd_log.level_exception,
                              l_label,
                              l_debug_str, NULL,
                              NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
              END IF;

                IF l_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(api_rec.interface_api_id,l_error_code);
                END IF;

                     UPDATE IGS_AD_API_INT_ALL
                     SET ERROR_CODE  = l_error_code,
                         STATUS = '3'
                     WHERE INTERFACE_API_ID  = API_REC.INTERFACE_API_ID;

             END;

           END IF;
    ELSE  --If the record is not a duplicate one
    --Make a call to CREATE_PERSON_ID_TYPES
    --with the following parameters.
    crt_person_id_types
              (p_api_rec=>api_rec,
           p_error_code=>l_error_code,
           p_status=>l_status);

         UPDATE IGS_AD_API_INT_ALL
         SET ERROR_CODE  = l_error_code,
             STATUS = l_status
         WHERE INTERFACE_API_ID  = API_REC.INTERFACE_API_ID;

    END IF;

    END IF; -- End of validation
  END IF;
  IF l_processed_records = 100 THEN
     COMMIT;
     l_processed_records := 0;
  END IF;

  END LOOP;

END prc_pe_id_types;

-- PERSON INTERFACE DLD changes start here
-- prc_pe_citizenship from IGSAD90 is moved here and renamed.

PROCEDURE prc_pe_hz_citizenship
(      p_source_type_id IN  NUMBER,
       p_batch_id   IN  NUMBER
       )
/*
 ||  Created By : ssawhney
 ||  Created On : 15 november
 ||  Purpose : This procedure process the Internation Dtls, Fund Dep part
 ||  Known limitations, enhancements or remarks :
 ||  Change History :
 ||  Who             When            What
 || npalanis         6-JAN-2003      Bug : 2734697
 ||                                  code added to commit after import of every
 ||                                  100 records .New variable l_processed_records added
 ||  npalanis        6-JUN-2002   Bug - 2391172
 ||                               Reference to igs_pe_code_classes changed to
 ||                               fnd or igs lookups,Date validations added
    */
AS
--cursor to select records from interface records
CURSOR c_pcz(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
 SELECT   hii.*, i.person_id
 FROM   igs_pe_citizen_int hii, igs_ad_interface_all i
 WHERE  hii.interface_run_id = cp_interface_run_id
 AND    i.interface_id = hii.interface_id
 AND    i.interface_run_id = cp_interface_run_id
 AND    hii.status  = '2';

 l_var VARCHAR2(1);
 l_rule VARCHAR2(1);
 l_error_code VARCHAR2(25);
 l_status VARCHAR2(25);
 l_dup_var BOOLEAN;
 l_last_update_date DATE;
 pcz_rec c_pcz%ROWTYPE;
 l_processed_records NUMBER(5) := 0;
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
  l_default_date DATE;

-- Local Procedure to create new records .
    PROCEDURE crt_pe_citizenship( pcz_rec IN c_pcz%ROWTYPE  ,
                                 error_code OUT NOCOPY VARCHAR2,
                                 status OUT NOCOPY VARCHAR2) AS
        l_update_date1 DATE;
        l_return_status VARCHAR2(25);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(4000);
        l_smp VARCHAR2(25);
        l_smp1 VARCHAR2(25);
        p_error_code  VARCHAR2(25);
        p_status VARCHAR2(25);
        l_p_last_update_date DATE;
        l_citizenship_id NUMBER;

   -- gmuralid validation for country changed - SEVIS
        CURSOR c_valid_country(cp_territory_code VARCHAR2) IS
        SELECT territory_short_name
        FROM fnd_territories_vl
        WHERE territory_code = cp_territory_code;

        CURSOR birth_dt_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
        SELECT birth_date FROM
        igs_pe_person_base_v WHERE
        person_id = cp_person_id;

        CURSOR date_overlap(PCZ_REC c_pcz%ROWTYPE) IS
        SELECT count(1) FROM HZ_CITIZENSHIP
        WHERE
        party_id = PCZ_REC.PERSON_ID AND
        UPPER(country_code) = UPPER(PCZ_REC.Country_code) AND
        ( NVL(TRUNC(PCZ_REC.end_date),IGS_GE_DATE.igsdate('9999/01/01')) BETWEEN TRUNC(date_recognized) AND NVL(TRUNC(end_date),IGS_GE_DATE.igsdate('9999/01/01'))
          OR
          TRUNC(PCZ_REC.date_recognized) BETWEEN TRUNC(date_recognized) AND NVL(TRUNC(end_date),IGS_GE_DATE.igsdate('9999/01/01'))
          OR
          ( TRUNC(PCZ_REC.date_recognized) < TRUNC(date_recognized) AND
          NVL(TRUNC(end_date),IGS_GE_DATE.igsdate('9999/01/01'))< NVL(TRUNC(PCZ_REC.end_date),IGS_GE_DATE.igsdate('9999/01/01')) ) );

          l_birth_dt IGS_PE_PERSON.BIRTH_DT%TYPE;
          valid_country_rec c_valid_country%ROWTYPE;
          l_count NUMBER(3);
          l_last_update  DATE;
          l_error VARCHAR2(30);
	  l_object_version_number NUMBER;
  BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_007.crt_pe_citizenship.begin';
    l_debug_str := 'Interface Citizen Id : ' ||(pcz_rec.interface_citizenship_id) ;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

          -- Start Validations

      OPEN c_valid_country(pcz_rec.country_code);
      FETCH c_valid_country INTO valid_country_rec;
        IF  c_valid_country%NOTFOUND THEN
          l_error := 'E125';
          RAISE no_data_found;
        ELSE
          l_error := null;
        END IF;
      IF pcz_rec.document_type IS NOT NULL THEN
        IF NOT
        (igs_pe_pers_imp_001.validate_lookup_type_code('CITIZENSHIP_DOC_TYPE',pcz_rec.document_type,8405))
        THEN
          l_error := 'E126';
          RAISE no_data_found;
        ELSE
          l_error := null;
        END IF;
      END IF;
      IF pcz_rec.date_recognized IS NULL THEN
        l_error := 'E257';
        RAISE no_data_found;
      ELSE
        IF pcz_rec.date_recognized >  pcz_rec.end_date THEN
          l_error := 'E208';
          RAISE no_data_found;
        ELSE
          l_error := null;
        END IF;

	-- nsidana Bug 3541714 : Added the validation to check that the date disowned in greater than the date recognized.
	IF NOT (pcz_rec.date_disowned BETWEEN pcz_rec.date_recognized AND NVL(PCZ_REC.end_date,IGS_GE_DATE.igsdate('9999/01/01'))) THEN
	  l_error := 'E267';
	  RAISE no_data_found;
	END IF;

        OPEN birth_dt_cur(pcz_rec.person_id);
        FETCH birth_dt_cur INTO l_birth_dt;
        IF l_birth_dt IS NOT NULL THEN
          IF pcz_rec.date_recognized < l_birth_dt THEN
            l_error := 'E222';
            RAISE no_data_found;
          ELSE
            l_error :=null;
          END IF;
        END IF;
        CLOSE birth_dt_cur;
      END IF;
      IF pcz_rec.date_disowned IS NOT NULL THEN
        OPEN birth_dt_cur(pcz_rec.person_id);
        FETCH birth_dt_cur INTO l_birth_dt;
        IF l_birth_dt IS NOT NULL THEN
          IF pcz_rec.date_disowned < l_birth_dt THEN
            l_error := 'E258';
            RAISE no_data_found;
          ELSE
            l_error :=null;
          END IF;
        END IF;
        CLOSE birth_dt_cur;
      END IF;
         OPEN date_overlap(PCZ_REC);
         FETCH date_overlap INTO l_count;
         CLOSE date_overlap;

        IF l_count > 0 THEN
          l_error := 'E228';
          Raise no_data_found;
        END IF;

      -- all validations are ok. --insert
      -- Object version number is added to the signature of IGS_PE_CITIZENSHIP_PKG
      IGS_PE_CITIZENSHIPS_PKG.Citizenship(
                p_ACTION                           => 'INSERT',
                p_BIRTH_OR_SELECTED                =>  null,
                p_COUNTRY_CODE                     =>  pcz_rec.country_code,
                p_DATE_DISOWNED                    =>  pcz_rec.DATE_DISOWNED,
                p_DATE_RECOGNIZED                  =>  pcz_rec.DATE_RECOGNIZED,
                p_DOCUMENT_REFERENCE               =>  pcz_rec.DOCUMENT_REFERENCE,
                p_DOCUMENT_TYPE                    =>  pcz_rec.DOCUMENT_TYPE,
                p_PARTY_ID                         =>  pcz_rec.person_ID,
                p_END_DATE                         =>  pcz_rec.END_DATE,
                p_TERRITORY_SHORT_NAME             =>  valid_country_rec.territory_short_name,
                p_LAST_UPDATE_DATE                 =>  l_last_update_date,
                p_CITIZENSHIP_ID                   =>  l_citizenship_id,
                p_RETURN_STATUS                    =>  l_return_status,
                p_MSG_COUNT                        =>  l_msg_count,
                p_MSG_DATA                         =>  l_msg_data,
		p_object_version_number            =>  l_object_version_number
            );

      IF l_return_status IN ('E','U') THEN  -- error returned by HZ API
        error_code := 'E127'; --  failed in HZ insert
        status := '3';
        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

          IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
          END IF;

          l_label := 'igs.plsql.IGS_AD_IMP_007.crt_pe_citizenship.exception: '||'E127';

          l_debug_str := 'IGS_AD_IMP_007.crt_pe_citizenship Insert into HZ table failed. '
            || 'Interface Citizen Id : '
            || (pcz_rec.interface_citizenship_id)
            || 'Status : 3' ||  'ErrorCode : E127'|| l_msg_data;

          fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(pcz_rec.interface_citizenship_id,'E127','IGS_PE_CITIZEN_INT');
        END IF;

      ELSE
        status := '1';
        UPDATE igs_pe_citizen_int
        SET status='1'
        WHERE interface_citizenship_id= pcz_rec.interface_citizenship_id;
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
          IF c_valid_country%ISOPEN THEN
                 CLOSE c_valid_country;
          END IF;
          error_code:= l_error;
          status:= '3';
           -- there can be a case when unhandled exception is raised in HZ package then the l_error will not be set

        IF l_error IS NULL THEN
          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                IF (l_request_id IS NULL) THEN
                  l_request_id := fnd_global.conc_request_id;
                END IF;

            l_label := 'igs.plsql.igs_ad_imp_007.crt_pe_citizenship.exception';

           l_debug_str := 'IGS_AD_IMP_007.crt_pe_citizenship Create Row failed'
                || 'Interface Citizen Id : '
                || (pcz_rec.interface_citizenship_id)
                || 'Status : 3' || ' SQLERRM:' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
          END IF;
          error_code :='E127' ;
        END IF;

          IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(pcz_rec.interface_citizenship_id,l_error,'IGS_PE_CITIZEN_INT');
          END IF;

          UPDATE igs_pe_citizen_int
          SET error_code = l_error, status ='3'
              WHERE interface_citizenship_id= pcz_rec.interface_citizenship_id;
      END crt_pe_citizenship;  -- end local proc to create new record


--start local proc to check if record already exists in system table , duplicate check
  PROCEDURE check_dup_citizenship(p_dup_var OUT NOCOPY BOOLEAN,
                                  p_person_id IN NUMBER,
                                  p_country_code IN VARCHAR2,
                                  p_date_recognized IN HZ_CITIZENSHIP.DATE_RECOGNIZED%TYPE) AS
     l_count VARCHAR2(1);
  BEGIN


     SELECT 'X'
     INTO  l_count
     FROM  hz_citizenship
     WHERE   party_id = p_person_id
     AND     country_code = p_country_code
     AND  TRUNC(date_recognized) = TRUNC(p_date_recognized) ;  -- end_date IS NULL check removed.

     p_dup_var := TRUE;

  EXCEPTION
     WHEN OTHERS THEN
      p_dup_var:=FALSE;
  END check_dup_citizenship;
--end local proc to check if record already exists in system table , duplicate check

--start local proc for updating existing records based on discrepancy rule
  PROCEDURE upd_pe_citizenship(pcz_rec IN c_pcz%ROWTYPE,
                               error_code OUT NOCOPY VARCHAR2,
                               status OUT NOCOPY VARCHAR2) AS
        l_update_date1 DATE;
        l_return_status VARCHAR2(25);
        l_msg_count VARCHAR2(30);
        l_msg_data VARCHAR2(2000);
        p_error_code  VARCHAR2(25);
        p_status VARCHAR2(25);
        l_citizenship_id NUMBER;
        l_error VARCHAR2(25);
        l_last_update_date DATE;

        CURSOR c_valid_country(cp_territory_code VARCHAR2) IS
        SELECT territory_short_name
        FROM fnd_territories_vl
        WHERE territory_code = cp_territory_code;

        CURSOR c_null_hndlg (pcz_rec IN c_pcz%ROWTYPE) IS
        SELECT *
        FROM hz_citizenship
        WHERE party_id = pcz_rec.person_id
         AND country_code =pcz_rec.country_code
         AND date_recognized = pcz_rec.date_recognized;

        CURSOR birth_dt_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
        SELECT birth_date
    FROM igs_pe_person_base_v
    WHERE person_id = pcz_rec.person_id;

        CURSOR date_overlap(PCZ_REC c_pcz%ROWTYPE) IS
        SELECT COUNT(1)
    FROM HZ_CITIZENSHIP
        WHERE
        party_id = PCZ_REC.PERSON_ID AND
        UPPER(country_code) = UPPER(PCZ_REC.Country_code) AND
        TRUNC(date_recognized) <> TRUNC(PCZ_REC.date_recognized) AND
        ( NVL(TRUNC(PCZ_REC.end_date),IGS_GE_DATE.igsdate('9999/01/01')) BETWEEN TRUNC(date_recognized) AND NVL(TRUNC(end_date),IGS_GE_DATE.igsdate('9999/01/01'))
          OR
          TRUNC(PCZ_REC.date_recognized) BETWEEN TRUNC(date_recognized) AND NVL(TRUNC(end_date),IGS_GE_DATE.igsdate('9999/01/01'))
          OR
          ( TRUNC(PCZ_REC.date_recognized) < TRUNC(date_recognized) AND
          NVL(TRUNC(end_date),IGS_GE_DATE.igsdate('9999/01/01'))< NVL(TRUNC(PCZ_REC.end_date),IGS_GE_DATE.igsdate('9999/01/01')) ) );

    l_count NUMBER(3);
    l_birth_dt IGS_PE_PERSON_V.BIRTH_DT%TYPE;
    null_hndlg_rec c_null_hndlg%ROWTYPE;
    valid_country_rec c_valid_country%ROWTYPE;

  BEGIN

      OPEN c_null_hndlg (pcz_rec);
      FETCH c_null_hndlg INTO null_hndlg_rec;
      CLOSE c_null_hndlg;

      -- Start Validations

        OPEN c_valid_country(pcz_rec.country_code);
        FETCH c_valid_country INTO valid_country_rec;
        IF c_valid_country%NOTFOUND THEN
          l_error := 'E125';
          RAISE no_data_found;
        ELSE
          l_error := null;
          CLOSE c_valid_country;
        END IF;


    IF pcz_rec.document_type IS NOT NULL THEN
      IF NOT
      (igs_pe_pers_imp_001.validate_lookup_type_code('CITIZENSHIP_DOC_TYPE',pcz_rec.document_type,8405))
      THEN
        l_error := 'E126';
        RAISE no_data_found;
      ELSE
        l_error := null;
      END IF;
    END IF;

        IF pcz_rec.date_recognized IS NULL THEN
             l_error := 'E257';
             RAISE no_data_found;
        ELSE
          IF pcz_rec.date_recognized >  pcz_rec.end_date THEN
            l_error := 'E208';
            RAISE no_data_found;
          END IF;

          OPEN birth_dt_cur(pcz_rec.person_id);
          FETCH birth_dt_cur INTO l_birth_dt;
          IF l_birth_dt IS NOT NULL THEN
             IF pcz_rec.date_recognized < l_birth_dt THEN
               l_error := 'E222';
               RAISE no_data_found;
             END IF;
          END IF;
          CLOSE birth_dt_cur;
        END IF;

        IF pcz_rec.date_disowned IS NOT NULL THEN

          OPEN birth_dt_cur(pcz_rec.person_id);
          FETCH birth_dt_cur INTO l_birth_dt;
          IF l_birth_dt IS NOT NULL THEN
            IF pcz_rec.date_disowned < l_birth_dt THEN
              l_error := 'E258';
              RAISE no_data_found;
            ELSE
              l_error :=null;
            END IF;
          END IF;
          CLOSE birth_dt_cur;

          IF NOT (pcz_rec.date_disowned BETWEEN pcz_rec.date_recognized AND NVL(PCZ_REC.end_date,IGS_GE_DATE.igsdate('9999/01/01'))) THEN
             l_error := 'E267';
             RAISE no_data_found;
          END IF;
        END IF;

        OPEN date_overlap(pcz_rec) ;
        FETCH date_overlap INTO l_count;
        CLOSE date_overlap;

        IF l_count > 0 THEN
          l_error := 'E228';
          Raise no_data_found;
        END IF;


-- Object version number is added to the signature of IGS_PE_CITIZENSHIP_PKG
    IGS_PE_CITIZENSHIPS_PKG.Citizenship(
                p_ACTION                           => 'UPDATE',
                p_BIRTH_OR_SELECTED                =>  null,
                p_COUNTRY_CODE                     =>  NVL( pcz_rec.country_code,null_hndlg_rec.country_code),
                p_DATE_DISOWNED                    =>  NVL(pcz_rec.date_disowned,null_hndlg_rec.date_disowned),
                p_DATE_RECOGNIZED                  =>  NVL(pcz_rec.date_recognized,null_hndlg_rec.date_recognized),
                p_DOCUMENT_REFERENCE               =>  NVL(pcz_rec.document_reference,null_hndlg_rec.document_reference),
                p_DOCUMENT_TYPE                    =>  NVL(pcz_rec.document_type,null_hndlg_rec.document_type),
                p_PARTY_ID                         =>  NVL(pcz_rec.person_id,null_hndlg_rec.party_id),
                p_END_DATE                         =>  NVL(pcz_rec.end_date,null_hndlg_rec.end_date),
                p_TERRITORY_SHORT_NAME             =>  valid_country_rec.territory_short_name,
                p_LAST_UPDATE_DATE                 =>  l_last_update_date,
                p_CITIZENSHIP_ID                   =>  null_hndlg_rec.citizenship_id,
                p_RETURN_STATUS                    =>  l_return_status,
                p_MSG_COUNT                        =>  l_msg_count,
                p_MSG_DATA                         =>  l_msg_data,
		p_OBJECT_VERSION_NUMBER            =>  null_hndlg_rec.object_version_number
            );

      IF l_return_status IN ('E','U') THEN
        error_code := 'E128'; -- updation failed in HZ
        status := '3';
        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

          IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
          END IF;

          l_label := 'igs.plsql.IGS_AD_IMP_007.upd_pe_citizenship.exception: '||'E128';

          l_debug_str :=  'IGS_AD_IMP_007.upd_pe_citizenship Update into HZ table failed. '
                || 'Interface Citizen Id : '
                || (pcz_rec.interface_citizenship_id)
                || ' Status : 3 ' ||  'ErrorCode : E128 msg_data: ' || l_msg_data;

          fnd_log.string_with_context( fnd_log.level_exception,
                          l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;

        IF l_enable_log = 'Y' THEN
          igs_ad_imp_001.logerrormessage(pcz_rec.interface_citizenship_id,'E128','IGS_PE_CITIZEN_INT');
        END IF;

      ELSE
        status := '1';
        error_code :=NULL;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN

    error_Code:= l_error;  -- discrepency rule check failed
    status:= '3';

      IF l_error IS NULL THEN
        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_007.upd_pe_citizenship.exception';

        l_debug_str :=  'IGS_AD_IMP_007.upd_pe_citizenship '
                || 'Interface Citizen Id : '
                || (pcz_rec.interface_citizenship_id)
                || 'Status : 3' || ' SQLERRM:' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
        END IF;
        error_Code:= 'E128';
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(pcz_rec.interface_citizenship_id,l_error,'IGS_PE_CITIZEN_INT');
    END IF;

      IF c_valid_country%ISOPEN THEN
         CLOSE c_valid_country;
      END IF;

  END upd_pe_citizenship;
--end local proc for updating existing records based on discrepancy rule

  BEGIN
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_ad_imp_007.prc_pe_hz_citizenship';
  l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_hz_citizenship.';

  l_rule :=igs_ad_imp_001.find_source_cat_rule(p_source_type_id,'PERSON_INTERNATIONAL_DETAILS');

  l_default_date := igs_ge_date.igsdate('9999/01/01');

  --1. If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_pe_citizen_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND interface_run_id = l_interface_run_id
      AND status = cst_stat_val_2;
  END IF;


  --2. If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_pe_citizen_int mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_19
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM   hz_citizenship pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.party_id
             AND  UPPER(pe.country_code) = UPPER(mi.country_code)
             AND  NVL(TRUNC(pe.date_recognized),l_default_date) = NVL(TRUNC(mi.date_recognized),l_default_date) );
  END IF;

  --3. If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_pe_citizen_int
    SET status = cst_stat_val_1
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN (cst_mi_val_18,cst_mi_val_19,cst_mi_val_22,cst_mi_val_23)
      AND status=cst_stat_val_2;
  END IF;

  --4. If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_pe_citizen_int
    SET status = cst_stat_val_3,
        ERROR_CODE = cst_err_val_695
    WHERE interface_run_id = l_interface_run_id
      AND (match_ind IS NOT NULL AND match_ind NOT IN (cst_mi_val_21,cst_mi_val_25))
      AND status=cst_stat_val_2;
  END IF;

  --5. If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_pe_citizen_int mi
    SET status = cst_stat_val_1,
        match_ind = cst_mi_val_23
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS ( SELECT '1'
                   FROM hz_citizenship pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.party_id
             AND  pe.country_code = UPPER(mi.country_code)
             AND  NVL(TRUNC(pe.date_recognized),l_default_date) = NVL(TRUNC(mi.date_recognized),l_default_date)
             AND  NVL(UPPER(pe.document_reference),'N') = NVL(UPPER(mi.document_reference),'N')
             AND  NVL(TRUNC(pe.date_disowned),l_default_date) = NVL(TRUNC(mi.date_disowned),l_default_date)
             AND  NVL(TRUNC(pe.end_date),l_default_date) = NVL(TRUNC(mi.end_date),l_default_date)
             AND  NVL(UPPER(pe.document_type),'N') =NVL(UPPER(mi.document_type),'N')
             );
  END IF;

  --6. If rule in R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_pe_citizen_int mi
    SET status = cst_stat_val_3,
        match_ind = cst_mi_val_20,
    dup_citizenship_id  = (SELECT  citizenship_id
                            FROM   hz_citizenship pe, igs_ad_interface_all ii
                    WHERE  ii.interface_run_id = l_interface_run_id
                     AND  ii.interface_id = mi.interface_id
                     AND  ii.person_id = pe.party_id
                     AND  pe.country_code = UPPER(mi.country_code)
                     AND  NVL(TRUNC(pe.date_recognized),l_default_date) = NVL(TRUNC(mi.date_recognized),l_default_date))
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = cst_stat_val_2
      AND EXISTS (SELECT '1'
                  FROM   hz_citizenship pe, igs_ad_interface_all ii
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.party_id
             AND  pe.country_code = UPPER(mi.country_code)
             AND  NVL(TRUNC(pe.date_recognized),l_default_date) = NVL(TRUNC(mi.date_recognized),l_default_date));
  END IF;

  FOR  pcz_rec  IN c_pcz(l_interface_run_id) LOOP

  l_processed_records := l_processed_records + 1;

  pcz_rec.document_type := UPPER(pcz_rec.document_type);
  pcz_rec.country_code := UPPER(pcz_rec.country_code);
  pcz_rec.date_recognized := TRUNC(pcz_rec.date_recognized);
  pcz_rec.end_date := TRUNC(pcz_rec.end_date);
  pcz_rec.date_disowned :=  TRUNC(pcz_rec.date_disowned);

  check_dup_citizenship( p_dup_var => l_dup_var,
                     p_person_id => pcz_rec.person_id,
                         p_country_code => pcz_rec.country_code,
                         p_date_recognized => pcz_rec.date_recognized);

  IF l_dup_var THEN

  -- incase dup records are found, get the disc rule to be followed
    IF l_rule = 'I' THEN

        upd_pe_citizenship(pcz_rec => pcz_rec,
                           error_code => l_error_code,
                           status => l_status);
        UPDATE igs_pe_citizen_int
        SET match_ind = cst_mi_val_18, status = l_status ,error_code = l_error_code
        WHERE interface_citizenship_id= pcz_rec.interface_citizenship_id;

    ELSIF l_rule = 'R' THEN
       IF pcz_rec.match_ind = '21' THEN

          upd_pe_citizenship(pcz_rec => pcz_rec,
                    error_code => l_error_code,
                    status => l_status );

          UPDATE igs_pe_citizen_int
          SET status = l_status , error_code = l_error_code
          WHERE interface_citizenship_id = pcz_rec.interface_citizenship_id;

       END IF;
    END IF;
  ELSE -- ie not a dup record. first IF check
   crt_pe_citizenship(pcz_rec => pcz_rec  ,
                      error_code => l_error_code,
                      status => l_status );
   END IF;

   IF l_processed_records = 100 THEN
      COMMIT;
      l_processed_records := 0;
   END IF;

 END LOOP;
 END prc_pe_hz_citizenship ;

PROCEDURE prc_pe_fund_source
(      p_source_type_id IN  NUMBER,
       p_batch_id   IN  NUMBER
       )
/*
 ||  Created By : ssawhney
 ||  Created On : 15 november
 ||  Purpose : This procedure process the Internation Dtls, Fund Dep part
 ||  Known limitations, enhancements or remarks :
 ||  Change History :
 ||  Who             When            What
 || npalanis         6-JAN-2003      Bug : 2734697
 ||                                  code added to commit after import of every
 ||                                  100 records .New variable l_processed_records added
 ||  npalanis        6-JUN-2002   Bug - 2391172
 ||                               Reference to igs_pe_code_classes changed to
 ||                               fnd or igs lookups , null handling cursor
 ||                                made to retrieve value using fund dep id
    */
AS

--cursor to select records from interface records
CURSOR c_pfs(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE)  IS
  SELECT   ai.*,
           i.person_id
  FROM   igs_pe_fund_src_int ai, igs_ad_interface_all i
  WHERE  ai.interface_run_id = cp_interface_run_id
    AND    i.interface_id = ai.interface_id
        AND    i.interface_run_id = cp_interface_run_id
    AND    ai.status  = '2';

  l_var VARCHAR2(1);
  l_rowid VARCHAR2(30);
  l_dup_var BOOLEAN;
  l_rule VARCHAR2(1);

  pfs_rec c_pfs%ROWTYPE;
  l_fund_source_id igs_pe_fund_source.fund_source_id%TYPE;
  l_status  pfs_rec.status%TYPE;
  l_error_code  pfs_rec.error_code%TYPE;
  l_match_ind  pfs_rec.match_ind%TYPE;
  l_processed_records NUMBER(5) := 0;
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
-- Local Procedure to create new records .

   PROCEDURE crt_pe_fund_source( pfs_rec IN c_pfs%ROWTYPE  ,
                                 error_code OUT NOCOPY VARCHAR2,
                                 status OUT NOCOPY VARCHAR2)
   /*
    ||  Created By : ssawhney
    ||  Created On : 15 november
    ||  Purpose : Local procedure for insert
    ||
    */
   AS

   BEGIN
      igs_pe_fund_source_pkg.insert_row(
                x_rowid             => l_rowid,
        x_fund_source_id    => l_fund_source_id,
        x_person_id         => pfs_rec.person_id,
        x_fund_source_code  => pfs_rec.fund_source_code,
        x_name              => pfs_rec.name,
        x_amount            => pfs_rec.amount,
        x_relationship_code => pfs_rec.relationship_code,
        x_document_ind      => NVL(pfs_rec.document_ind,'N'),
        x_notes             => pfs_rec.notes,
        x_mode              => 'R'
            );
          error_code:=NULL;
          status :='1';
   EXCEPTION
     WHEN OTHERS THEN
     status := '3';
     error_code := 'E133';
     -- Call Log detail
      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_007.crt_pe_fund_source.exception '||'E133';

          l_debug_str :=  'IGS_AD_IMP_007.crt_pe_fund_source '
                || ' Exception from Igs_Pe_Fund_Source_Pkg.Insert_Row '
                || 'Interface Fund Source Id : '
                || (pfs_rec.interface_fund_source_id)
                || 'Status : 3' ||  'ErrorCode : E133 SQLERRM:' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(pfs_rec.interface_fund_source_id,'E133','IGS_PE_FUND_SRC_INT');
    END IF;

   END crt_pe_fund_source;  -- end local proc to create new record

  -- local function for validating the records.
   FUNCTION Validate_Record(pfs_rec  IN c_pfs%ROWTYPE) RETURN BOOLEAN
   /*
 ||  Created By : ssawhney
 ||  Created On : 15 november
 ||  Purpose : Local function for validations
 ||
    */
   IS
   l_var    VARCHAR2(1);
  --validation cursors

      l_error VARCHAR2(30);
      l_rowid VARCHAR2(25);
   BEGIN

         -- Start Validations

    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('PE_FUND_TYPE',pfs_rec.fund_source_code,8405))
    THEN
      l_error := 'E124';
      RAISE no_data_found;
     ELSE
      l_error := NULL;
     END IF;

      IF pfs_rec.relationship_code IS NOT NULL THEN
      IF NOT
      (igs_pe_pers_imp_001.validate_lookup_type_code('PARTY_RELATIONS_TYPE',pfs_rec.relationship_code,222))
      THEN
        l_error := 'E135';
        RAISE no_data_found;
      ELSE
        l_error := null;
      END IF;
      END IF;

      IF pfs_rec.document_ind NOT IN ('N','Y') THEN
        l_error := 'E132';
        RAISE no_data_found;
      END IF;

    -- all validations are ok. --insert
      RETURN TRUE;

      EXCEPTION
      -- search for NO_DATA_FOUND, as its not trapped, OTHERS will be raised
          WHEN OTHERS THEN
        -- update for failure
      UPDATE igs_pe_fund_src_int
      SET    status = '3',
         error_code = l_error
      WHERE  interface_fund_source_id = pfs_rec.interface_fund_source_id;

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_fund_source.exception '||l_error;

          l_debug_str :=  'Igs_Ad_Imp_007.prc_pe_fund_source.Validate_Record '
         ||' Interface Fund Source Id : ' || (pfs_rec.interface_fund_source_id) ||'Status : 3'
             ||  'ErrorCode :' || l_error || ' SQLERRM: ' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(pfs_rec.interface_fund_source_id,l_error,'IGS_PE_FUND_SRC_INT');
        END IF;
        RETURN FALSE ;

   END Validate_Record;  -- End Local function Validate_Record

-- start the main processing from HERE.
BEGIN -- Start the prc_pe_fund_source Now.
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_ad_imp_007.prc_pe_fund_source';
  l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_fund_source.';

-- Logic of Fund Source is different.
-- There will BE DUPLICATE RECORDS, so no check for duplicacy and
-- no check for discrepency rule.

   -- Call Log header

   --
      FOR pfs_rec IN c_pfs(l_interface_run_id) LOOP  -- LOOP Started
       BEGIN

       l_processed_records := l_processed_records + 1;
     --
     -- Set the status, match_ind, error_code of the interface record
     --
         l_status := pfs_rec.status;
         l_error_code := pfs_rec.error_code;
         l_match_ind := pfs_rec.match_ind;

         pfs_rec.fund_source_code := UPPER(pfs_rec.fund_source_code);
     pfs_rec.relationship_code := UPPER(pfs_rec.relationship_code);
         pfs_rec.document_ind := UPPER(pfs_rec.document_ind);

    -- validate the current record
         IF validate_record( pfs_rec => pfs_rec )  THEN   --


              crt_pe_fund_source (pfs_rec   =>  pfs_rec,
                            error_code => l_error_code,
                            status  => l_status );

            UPDATE  igs_pe_fund_src_int
            SET     status = l_status,
                error_code = l_error_code
            WHERE   interface_fund_source_id = pfs_rec.interface_fund_source_id;

       END IF;

       IF l_processed_records = 100 THEN
          COMMIT;
          l_processed_records := 0;
       END IF;

       END ;
      END LOOP;
   END prc_pe_fund_source ;


PROCEDURE prc_pe_intl_dtls
(      p_source_type_id IN  NUMBER,
       p_batch_id   IN  NUMBER
       )
 /*
 ||  Created By : 15 november
 ||  Created On :
 ||  Purpose : This procedure process the Internation Dtls, Main procedure
 ||  Known limitations, enhancements or remarks :
 ||  Change History :
 ||  Who             When            What
 ||  npalanis       27-MAy-2002  Bug no - 2377751
 ||                              New error codes registered and added
 ||  ssawhney       15 nov       Bug no.2103692:Person Interface DLD
 ||                              Internation Dtls structure is completly changed.
    */
AS
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_request_id NUMBER(10);

BEGIN
    l_prog_label := 'igs.plsql.igs_ad_imp_007.prc_pe_intl_dtls';
    l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_intl_dtls.';

-- start the main parent import.
  prc_pe_hz_citizenship ( p_source_type_id, p_batch_id) ;

-- start with the childs
  prc_pe_fund_source ( p_source_type_id, p_batch_id) ;

  IGS_AD_IMP_026.prc_pe_visa(p_source_type_id, p_batch_id);
  IGS_AD_IMP_026.prc_pe_visit_histry(p_source_type_id, p_batch_id);
  IGS_AD_IMP_026.prc_pe_passport(p_source_type_id, p_batch_id);
  IGS_AD_IMP_026.prc_pe_eit(p_source_type_id, p_batch_id);

EXCEPTION
  WHEN OTHERS THEN

  IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_007.prc_pe_int_dtls.exception ';

      l_debug_str :=  'Igs_Ad_Imp_007.prc_pe_int_dtls Unhandled Exception'
                || ' Source  Id : '
                ||   (p_source_type_id)
                || 'Batch Id : ' || IGS_GE_NUMBER.TO_CANN(p_batch_id)|| ' SQLERRM: ' ||  SQLERRM;

    fnd_log.string_with_context( fnd_log.level_exception,
                  l_label,
                  l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;
END   prc_pe_intl_dtls ;



END IGS_AD_IMP_007;

/
