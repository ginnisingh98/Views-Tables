--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_006" AS
/* $Header: IGSAD84B.pls 120.4 2006/06/06 09:37:34 skpandey ship $ */
/*
/* Change History
   Who        When            What

   asbala     7-OCT-2003      Bug 3130316. Import Process Logging Framework Related changes.
   asbala     28-SEP-2003     Bug 3130316. Import Process Source Category Rule processing changes,
                                    lookup caching related changes, and cursor parameterization.
   npalanis   6-JAN-2003      Bug : 2734697
                                    code added to commit after import of every
                                    100 records .New variable l_processed_records added
   pkpatel    6-JAn-2003      Bug : 2735909
                              Added the validation for Birth date in Employment Details
   npalanis   23-OCT-2002     Bug : 2608360
                               validation for alias is done from lookups
   pathipat   08-JUL-2002     Introduced UPPER validation for Type_Of_Employment and Tenure_Of_Employment fields for Bug:2425608
   pathipat   18-JUL-2002     Validation for Date Overlap included before Updation also (previously present for Insertion only)
   npalanis   16-JUN-2002     Bug - 2409967
                              Level of interest lookup type  not present in fnd_lookup_values
                              Level of interest validation removed
   npalanis   14-JUN-2002     Bug - 2409967
                              the cursor check is put inside the check for error code.
   gmaheswa   10-NOV-2003     Bug - 3223043 HZ.K impact changes
   gmaheswa       15-DEC-2003     Bug 3316838 Removed code related to date overlap under same employer or employer party number.
   pkpatel    23-Feb-2006     Bug 4937960 (Used the table HZ_EMPLOYMENT_HISTORY directly instead of the view IGS_AD_EMP_DTL)
   skpandey   16-May-2006     Bug - 5205911 added comments column to IGS_AD_EMP_INT_ALL
*/
 --1

cst_mi_val_18 CONSTANT  VARCHAR2(2) := '18';
cst_stat_val_1 CONSTANT  VARCHAR2(2) := '1';


  PROCEDURE Prc_Pe_Alias
  (  P_SOURCE_TYPE_ID IN NUMBER,
     P_BATCH_ID IN NUMBER  )
  AS
    CURSOR alias_cur(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
    SELECT  hii.*, i.person_id
    FROM  igs_ad_alias_int_all hii, igs_ad_interface_all i
    WHERE  hii.interface_run_id = cp_interface_run_id
    AND    i.interface_id = hii.interface_id
        AND    i.interface_run_id = cp_interface_run_id
    AND    hii.status  = '2';

    PERSON_ALIAS_REC alias_cur%ROWTYPE;

   l_var  VARCHAR2(1);
   l_seq_number NUMBER;
   l_rule VARCHAR2(1);
   l_status VARCHAR2(10);
   l_dup_var BOOLEAN;
   l_error_code IGS_AD_EMP_INT.Error_Code%TYPE;
   l_sequence_number  IGS_PE_PERSON_ALIAS.SEQUENCE_NUMBER%TYPE;
   l_processed_records NUMBER(5) := 0;
   l_prog_label  VARCHAR2(4000);
   l_label  VARCHAR2(4000);
   l_debug_str VARCHAR2(4000);
   l_enable_log VARCHAR2(1);
   l_request_id NUMBER(10);
   l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;

   --------Start of local Validate_pe_alias ------
PROCEDURE Validate_pe_alias(PERSON_ALIAS_REC alias_cur%ROWTYPE,
                                l_error_code OUT NOCOPY VARCHAR2) AS
    L_VAR  VARCHAR2(1);
    CURSOR birth_dt_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
    SELECT birth_date
    FROM  igs_pe_person_base_v
    WHERE person_id= cp_person_id;

    l_birth_date IGS_AD_INTERFACE.BIRTH_DT%TYPE;

  BEGIN

     --ALIAS_TYPE
     --SQL for validation:
    IF NOT
    (igs_pe_pers_imp_001.validate_lookup_type_code('PE_ALIAS_TYPE',person_alias_rec.alias_type,8405))
    THEN
      l_error_code := 'E221';                           -- Validation Unsuccessful
      UPDATE igs_ad_alias_int_all
      SET    STATUS = '3',
             ERROR_CODE = l_error_code
      WHERE  interface_alias_id = person_alias_rec.interface_alias_id;
                      -- Call Log detail

      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(person_alias_rec.interface_alias_id,l_error_code);
      END IF;
      RETURN;
    ELSE
      l_error_code := NULL;      --Validation successful
    END IF;
    OPEN birth_dt_cur(person_alias_rec.person_id);
    FETCH birth_dt_cur INTO l_birth_date;
    CLOSE birth_dt_cur;

    IF l_birth_date IS NOT NULL THEN
      IF PERSON_ALIAS_REC.START_DT < l_birth_date THEN
        l_error_code := 'E222';
        UPDATE IGS_AD_ALIAS_INT_ALL
        SET    STATUS = '3',
               ERROR_CODE = l_error_code
        WHERE  INTERFACE_ALIAS_ID = PERSON_ALIAS_REC.INTERFACE_ALIAS_ID;

        IF l_enable_log = 'Y' THEN
           igs_ad_imp_001.logerrormessage(PERSON_ALIAS_REC.INTERFACE_ALIAS_ID,l_error_code);
        END IF;
        RETURN;
      END IF;
    END IF;
    --END_DATE
    IF (PERSON_ALIAS_REC.END_DT < PERSON_ALIAS_REC.START_DT) OR
             (PERSON_ALIAS_REC.START_DT IS NULL AND PERSON_ALIAS_REC.END_DT IS NULL) THEN
         -- Validation Unsuccessful
      l_error_code := 'E208';
      UPDATE IGS_AD_ALIAS_INT_ALL
      SET    STATUS = '3',
             ERROR_CODE = l_error_code
      WHERE  INTERFACE_ALIAS_ID = PERSON_ALIAS_REC.INTERFACE_ALIAS_ID;
      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(PERSON_ALIAS_REC.INTERFACE_ALIAS_ID,l_error_code);
      END IF;
      RETURN;
    END IF;
    l_error_code := null;
    END Validate_pe_alias;
--------End of local Validate_pe_alias ------

PROCEDURE Crt_Pe_Alias(PERSON_ALIAS_REC IN alias_cur%ROWTYPE)
AS

-- Code added by Nshee as part of import process testing after verifying from DLDv1.8 on 27-FEB-01
      CURSOR c_person_alias_seq_number_s IS
        SELECT IGS_PE_PERSON_ALIAS_SEQ_NUM_S.NEXTVAL FROM dual;
         l_person_alias_seq_number IGS_PE_PERSON_ALIAS.SEQUENCE_NUMBER%TYPE;
--End of code addition by nshee

         l_var VARCHAR2(1);
         l_rowid VARCHAR2(25);
         l_error_code IGS_AD_EMP_INT.Error_Code%TYPE;
BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_006.crt_pe_alias.begin';
    l_debug_str := 'Interface Alias Id : ' || person_alias_rec.INTERFACE_ALIAS_ID;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;
  Validate_pe_alias(PERSON_ALIAS_REC, l_error_code);

-- Code added by Nshee as part of import process testing after verifying from DLDv1.8 on 27-FEB-01
       OPEN c_person_alias_seq_number_s;
       FETCH c_person_alias_seq_number_s INTO l_person_alias_seq_number;
       IF c_person_alias_seq_number_s%NOTFOUND THEN
         RAISE NO_DATA_FOUND;
       END IF;
--End of code addition by nshee
       IF l_error_code IS NULL THEN

          Igs_Pe_Person_Alias_Pkg.INSERT_ROW (
            X_ROWID => l_rowid,
            X_PERSON_ID => PERSON_ALIAS_REC.PERSON_ID,
            X_ALIAS_TYPE => PERSON_ALIAS_REC.ALIAS_TYPE,
        --   X_SEQUENCE_NUMBER => NULL,--PERSON_ALIAS_REC.SEQUENCE_NUMBER,--commented by nshee
            X_SEQUENCE_NUMBER => l_person_alias_seq_number,
            X_TITLE => PERSON_ALIAS_REC.TITLE,
            X_ALIAS_COMMENT => PERSON_ALIAS_REC.ALIAS_COMMENT,
            X_START_DT => PERSON_ALIAS_REC.START_DT,
            X_END_DT => PERSON_ALIAS_REC.END_DT,
            X_SURNAME => PERSON_ALIAS_REC.SURNAME,
            X_GIVEN_NAMES => PERSON_ALIAS_REC.GIVEN_NAMES,
            X_MODE => 'R'
          );

          UPDATE IGS_AD_ALIAS_INT_ALL
          SET STATUS    = '1',
              ERROR_CODE = NULL
          WHERE INTERFACE_ALIAS_ID = person_alias_rec.INTERFACE_ALIAS_ID;
       END IF;
     EXCEPTION
       WHEN OTHERS THEN
          UPDATE IGS_AD_ALIAS_INT_ALL
          SET ERROR_CODE  = 'E322',
              STATUS = '3'
          WHERE INTERFACE_ALIAS_ID = person_alias_rec.INTERFACE_ALIAS_ID;

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.igs_ad_imp_006.crt_pe_alias.exception';

          l_debug_str :=  'IGS_AD_IMP_006.Prc_Pe_Alias.Crt_Pe_Alias ' ||
              'Interface Alias Id : ' || person_alias_rec.INTERFACE_ALIAS_ID ||
              ' Status : 3 ' ||  'ErrorCode : E322 ' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(person_alias_rec.INTERFACE_ALIAS_ID,'E322');
    END IF;
  END Crt_Pe_Alias;
-- END OF LOCAL PROCEDURE

  BEGIN
    -- For every record check whether a corresponding row already exists
    -- in the table IGS_PE_PERSON_ALIAS
    -- Update of person alias is removed because there is no primary key based on which the record
    -- present can be obtained because duplicate records can be created in form.
    l_enable_log := igs_ad_imp_001.g_enable_log;
    l_prog_label := 'igs.plsql.igs_ad_imp_006.prc_pe_alias';
    l_label := 'igs.plsql.igs_ad_imp_006.prc_pe_alias.';
    l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
    FOR person_alias_rec IN alias_cur(l_interface_run_id)
    LOOP
        l_processed_records := l_processed_records + 1 ;
        person_alias_rec.start_dt := TRUNC(person_alias_rec.start_dt);
        person_alias_rec.end_dt := TRUNC(person_alias_rec.end_dt);
        person_alias_rec.alias_type := UPPER(person_alias_rec.alias_type);

        Crt_Pe_Alias(person_alias_rec);
        IF l_processed_records = 100 THEN
           COMMIT;
           l_processed_records := 0;
        END IF;
    END LOOP;
  END Prc_Pe_Alias;


-- 3
  PROCEDURE Prc_Pe_Empnt_Dtls (
    P_SOURCE_TYPE_ID IN NUMBER,
    P_BATCH_ID IN VARCHAR2 )
  AS
    CURSOR emp_dtls(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
      SELECT hii.*,  i.person_id
      FROM   igs_ad_emp_int_all hii, igs_ad_interface_all i
      WHERE  hii.interface_run_id = cp_interface_run_id
        AND    i.interface_id = hii.interface_id
        AND    i.interface_run_id = cp_interface_run_id
        AND    hii.status  = '2';

  L_MEANING  VARCHAR2(80);
  L_PARTY_TYPE VARCHAR2(30);
  L_VAR VARCHAR2(1);
  p_dup_var BOOLEAN;
  l_rule VARCHAR2(1);
  l_status VARCHAR2(25);
  l_Employment_History_Id    NUMBER;
  lDupExists       VARCHAR2(1);
  l_Msg_Data       VARCHAR2(2000);
  l_Return_Status      VARCHAR2(1);
  l_RowId        VARCHAR2(25);
  l_error_code IGS_AD_EMP_INT.Error_Code%TYPE;
  l_processed_records NUMBER(5) := 0;
  l_prog_label  VARCHAR2(4000);
  l_label  VARCHAR2(4000);
  l_debug_str VARCHAR2(4000);
  l_enable_log VARCHAR2(1);
  l_request_id NUMBER(10);
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
  l_object_version_number NUMBER;
------ Local Procedure validate_emp_dtls---
PROCEDURE validate_emp_dtls (PERSON_EMP_REC IN emp_dtls%ROWTYPE,
                             P_EMPLOYER_PARTY_ID IN OUT NOCOPY NUMBER,
                             p_error_code OUT NOCOPY VARCHAR2) AS

CURSOR Validate_Occup_Title(cp_occ_t_code igs_ps_dic_occ_titls.occupational_title_code%TYPE)  IS
SELECT 'Y'
FROM  igs_ps_dic_occ_titls
WHERE occupational_title_code = cp_occ_t_code;

CURSOR  birth_date_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
SELECT birth_date
FROM   igs_pe_person_base_v
WHERE  person_id = cp_person_id;

CURSOR employer_party_number_cur(cp_employer_party_number igs_ad_emp_int_all.employer_party_number%TYPE) IS
SELECT PARTY_ID
FROM HZ_PARTIES
WHERE party_type = 'ORGANIZATION' AND
      party_number = cp_employer_party_number AND
      status <> 'M';


l_var VARCHAR2(1);
l_birth_date  igs_pe_person_base_v.birth_date%TYPE;
l_employer_party_number VARCHAR2(1);

BEGIN

 --3. Perform validations for the following columns
  -- Occupational Title Code

  IF PERSON_EMP_REC.OCCUPATIONAL_TITLE_CODE IS NOT NULL THEN
      OPEN Validate_Occup_Title(person_emp_rec.occupational_title_code);
      FETCH Validate_Occup_Title INTO l_var;
      IF Validate_Occup_Title%NOTFOUND THEN
            p_error_code := 'E223';
            UPDATE IGS_AD_EMP_INT_ALL
            SET    Error_Code = p_error_code,
            Status     = '3'
            WHERE  Interface_Emp_Id = Person_Emp_Rec.Interface_Emp_Id;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,'E223');
    END IF;
        CLOSE Validate_Occup_Title;
        RETURN;
      END IF;
      CLOSE Validate_Occup_Title;
  END IF;

  --START_DATE This field is mandatory.
  IF PERSON_EMP_REC.START_DATE IS NULL THEN
    --Validation Unsuccessful
    p_error_code := 'E212';
    UPDATE IGS_AD_EMP_INT_ALL
    SET    Error_Code = p_error_code,
           Status     = '3'
    WHERE  Interface_Emp_Id = Person_Emp_Rec.Interface_Emp_Id;
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,'E212');
    END IF;
    RETURN;
  END IF;

  --END_DATE
  IF PERSON_EMP_REC.END_DATE IS NOT NULL THEN
  IF PERSON_EMP_REC.END_DATE < PERSON_EMP_REC.START_DATE THEN
    --Validation Unsuccessful
    p_error_code := 'E208';
    UPDATE IGS_AD_EMP_INT_ALL
    SET    Error_Code = p_error_code,
           Status     = '3'
    WHERE  Interface_Emp_Id = Person_Emp_Rec.Interface_Emp_Id;
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,'E208');
    END IF;

    RETURN;
  END IF;
  END IF;

  --TYPE_OF_EMPLOYMENT
  -- Modified to validate type_of_employment from lookup values
  IF PERSON_EMP_REC.TYPE_OF_EMPLOYMENT IS NOT NULL THEN
    IF NOT (igs_pe_pers_imp_001.validate_lookup_type_code('HZ_EMPLOYMENT_TYPE',PERSON_EMP_REC.TYPE_OF_EMPLOYMENT,222)) THEN
      p_error_code := 'E224';

      UPDATE IGS_AD_EMP_INT_ALL
      SET Error_Code = p_error_code,
          Status     = '3'
      WHERE Interface_Emp_Id = Person_Emp_Rec.Interface_Emp_Id;
      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,p_error_code);
      END IF;
      RETURN;
    END IF;
  END IF;

  --FRACTION OF EMPLOYMENT
  IF PERSON_EMP_REC.FRACTION_OF_EMPLOYMENT IS NOT NULL THEN
  IF PERSON_EMP_REC.FRACTION_OF_EMPLOYMENT NOT BETWEEN 0.01 AND 100.00 THEN
    --Validation Unsuccessful
    p_error_code := 'E225';
    UPDATE IGS_AD_EMP_INT_ALL
    SET    Error_Code = p_error_code,
           Status     = '3'
    WHERE  Interface_Emp_Id = Person_Emp_Rec.Interface_Emp_Id;
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,p_error_code);
    END IF;
    RETURN;
  END IF;
  END IF;

  --TENURE_OF_EMPLOYMENT
  --Modified to validate tenure_of_employment from lookup values
  IF PERSON_EMP_REC.TENURE_OF_EMPLOYMENT IS NOT NULL THEN
    IF NOT (igs_pe_pers_imp_001.validate_lookup_type_code('HZ_TENURE_CODE',PERSON_EMP_REC.TENURE_OF_EMPLOYMENT,222))THEN
     --Validation Unsuccessful
      p_error_code := 'E226';
      UPDATE IGS_AD_EMP_INT_ALL
      SET Error_Code = p_error_code,
           Status     = '3'
      WHERE  Interface_Emp_Id = Person_Emp_Rec.Interface_Emp_Id;
      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,p_error_code);
      END IF;
      RETURN;
    END IF;
  END IF ;

  --POSITION
  --No validation checks. Free text.
  --WEEKLY_WORK_HOURS
  IF PERSON_EMP_REC.WEEKLY_WORK_HRS IS NOT NULL THEN
  IF PERSON_EMP_REC.WEEKLY_WORK_HRS < 0 OR PERSON_EMP_REC.WEEKLY_WORK_HRS > 168 THEN
    --Validation Successful
    p_error_code := 'E227';
    UPDATE IGS_AD_EMP_INT_ALL
    SET    Error_Code = p_error_code,
           Status     = '3'
    WHERE  Interface_Emp_Id = Person_Emp_Rec.Interface_Emp_Id;
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,p_error_code);
    END IF;
    RETURN;
  END IF;
  END IF;

  OPEN birth_date_cur(person_emp_rec.person_id);
  FETCH birth_date_cur INTO l_birth_date;
  CLOSE birth_date_cur;
  -- start date must be greater than birth date
  IF l_birth_date IS NOT NULL THEN
    IF person_emp_rec.start_date < l_birth_date THEN
        p_error_code := 'E222';
        UPDATE IGS_AD_EMP_INT_ALL
        SET    Error_Code = p_error_code,
               Status     = '3'
        WHERE  Interface_Emp_Id = Person_Emp_Rec.Interface_Emp_Id;
      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,p_error_code);
      END IF;
      RETURN;
    END IF;
  END IF;

  --Employer and Employer_party_number are mutually exclusive
  IF PERSON_EMP_REC.employer_party_number IS NOT NULL AND PERSON_EMP_REC.EMPLOYER IS NOT NULL THEN
    p_error_code := 'E755';
    UPDATE IGS_AD_EMP_INT_ALL
    SET    Error_Code = p_error_code,
           Status     = '3'
    WHERE  Interface_Emp_Id = Person_Emp_Rec.Interface_Emp_Id;
    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,p_error_code);
    END IF;
    RETURN;
  END IF;

  --Validate employer party id from the list of values
  IF PERSON_EMP_REC.employer_party_number IS NOT NULL THEN
    OPEN employer_party_number_cur(PERSON_EMP_REC.employer_party_number);
    FETCH employer_party_number_cur INTO p_employer_party_id;
    IF employer_party_number_cur%NOTFOUND THEN
      p_error_code := 'E756';
      UPDATE IGS_AD_EMP_INT_ALL
      SET Error_Code = p_error_code,
          Status     = '3'
      WHERE Interface_Emp_Id = Person_Emp_Rec.Interface_Emp_Id;
      IF l_enable_log = 'Y' THEN
        igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,p_error_code);
      END IF;
      RETURN;
    END IF;
    CLOSE employer_party_number_cur;
  END IF;

  p_error_code := NULL;
  UPDATE IGS_AD_EMP_INT_ALL
  SET    Error_Code = p_error_code,
    Status     = '1'
  WHERE  Interface_Emp_Id = Person_Emp_Rec.Interface_Emp_Id;

END validate_emp_dtls;
------ End of Local Procedure validate_emp_dtls---
------ Local Procedure crt_emp_dtls ---
 PROCEDURE crt_emp_dtls( PERSON_EMP_REC   emp_dtls%ROWTYPE) AS
  l_rowid VARCHAR2(25);
  l_Employment_History_Id  NUMBER;
  l_last_update_date DATE;
  l_return_status  VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  P_Emp_History_Id NUMBER;
  l_Row_Id VARCHAR2(25);
  l_error_code IGS_AD_EMP_INT.Error_Code%TYPE;

  l_employer_party_id NUMBER;
BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN
      IF (l_request_id IS NULL) THEN
	    l_request_id := fnd_global.conc_request_id;
      END IF;
      l_label := 'igs.plsql.igs_ad_imp_006.crt_emp_dtls.begin';
      l_debug_str := 'INTERFACE Emp Id : ' || Person_Emp_Rec.Interface_Emp_Id;
      fnd_log.string_with_context( fnd_log.level_procedure,
                                   l_label,
	                           l_debug_str, NULL,
				   NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
				 );
  END IF;

   -- Validate the values of PERSON_EMP_REC.
   validate_emp_dtls(PERSON_EMP_REC,l_employer_party_id,l_error_code);

   IF l_error_code IS NULL THEN
      --signature of Igs_Ad_Emp_Dtl_Pkg is changed and columns branch,military rank,served,station are obsoleted
      Igs_Ad_Emp_Dtl_Pkg.INSERT_ROW (
               X_ROWID                     => l_RowId,
               x_employment_history_id    => l_Employment_History_Id,
               x_PERSON_ID                 => PERSON_EMP_REC.person_id,
               x_START_DT                  => PERSON_EMP_REC.Start_Date,
               x_END_DT                    => PERSON_EMP_REC.End_Date,
               x_TYPE_OF_EMPLOYMENT        => PERSON_EMP_REC.Type_Of_Employment,
               x_FRACTION_OF_EMPLOYMENT    => PERSON_EMP_REC.Fraction_Of_Employment,
               x_TENURE_OF_EMPLOYMENT      => PERSON_EMP_REC.Tenure_Of_Employment,
               x_POSITION                  => PERSON_EMP_REC.Position,
               x_OCCUPATIONAL_TITLE_CODE   => PERSON_EMP_REC.OCCUPATIONAL_TITLE_CODE,
               x_OCCUPATIONAL_TITLE        => NULL, --PERSON_EMP_REC.TITLE,
               x_WEEKLY_WORK_HOURS         => PERSON_EMP_REC.WEEKLY_WORK_HRS,
               x_COMMENTS                  => PERSON_EMP_REC.Comments,
               x_EMPLOYER                  => PERSON_EMP_REC.Employer,
               x_EMPLOYED_BY_DIVISION_NAME => PERSON_EMP_REC.Employed_by_division_name,
               x_BRANCH                    => null,
               x_MILITARY_RANK             => null,
               x_SERVED                    => null,
               x_STATION                   => null,
               x_CONTACT                   => PERSON_EMP_REC.Contact,   --Bug : 2037512
               x_msg_data                  => l_msg_data,
               x_return_status             => l_return_status,
	       x_object_version_number     => l_object_version_number,
	       x_employed_by_party_id      => l_Employer_party_id,
               x_reason_for_leaving        => PERSON_EMP_REC.Reason_for_leaving,
               X_MODE                      => 'R'
            );
      IF l_return_Status IN ('E','U') THEN
          UPDATE IGS_AD_EMP_INT_all
	  SET status = '3',
	  error_code = 'E322'
	  WHERE INTERFACE_EMP_ID = PERSON_EMP_REC.INTERFACE_EMP_ID;

          IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
		IF (l_request_id IS NULL) THEN
		        l_request_id := fnd_global.conc_request_id;
		END IF;

	        l_label := 'igs.plsql.igs_ad_imp_006.crt_emp_dtls.exception';

	        l_debug_str := 'IGS_AD_IMP_006.Prc_Pe_Empnt_Dtls.crt_emp_dtls ' ||
		               'INTERFACE Emp Id : ' || IGS_GE_NUMBER.TO_CANN(Person_Emp_Rec.Interface_Emp_Id) ||
			       ' Status : 3 ' ||  'ErrorCode : E322 '|| l_msg_data;

	        fnd_log.string_with_context( fnd_log.level_exception,
			                     l_label,
					     l_debug_str, NULL,
		                             NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
	  END IF;

	  IF l_enable_log = 'Y' THEN
	      igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,'E322');
	  END IF;
      ELSE
	  UPDATE IGS_AD_EMP_INT_all
	  SET status = '1'
	  WHERE INTERFACE_EMP_ID = PERSON_EMP_REC.INTERFACE_EMP_ID;
      END IF;
   END IF;
 END crt_emp_dtls;
------ End of Local Procedure crt_emp_dtls----
BEGIN
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_ad_imp_006.prc_pe_empnt_dtls';
  l_label := 'igs.plsql.igs_ad_imp_006.prc_pe_empnt_dtls.';

  l_rule :=Igs_Ad_Imp_001.FIND_SOURCE_CAT_RULE(P_SOURCE_TYPE_ID,'PERSON_EMPLOYMENT_DETAILS');

  -- 1.If rule is E or I, then if the match_ind is not null, the combination is invalid
  IF l_rule IN ('E','I') THEN
    UPDATE igs_ad_emp_int_all
    SET status = '3',
        ERROR_CODE = 'E695'  -- Error code depicting incorrect combination
    WHERE match_ind IS NOT NULL
      AND interface_run_id = l_interface_run_id
      AND status = '2';
  END IF;

  --2. If rule is E and duplicate exists, update match_ind to 19 and status to 1
  IF l_rule = 'E' THEN
    UPDATE igs_ad_emp_int_all mi
    SET status = '1',
        match_ind = '19'
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.status = '2'
      AND EXISTS ( SELECT '1'
                   FROM   hz_employment_history pe, igs_ad_interface_all ii, hz_parties hz
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
	     AND  pe.employed_by_party_id = hz.party_id(+)
             AND  ii.person_id = pe.party_id
             AND  (( NVL(UPPER(mi.employer),'*!') = NVL(UPPER(pe.employed_by_name_company),'*'))
                     OR (NVL(mi.employer_party_number,'*!') = NVL(hz.party_number,'*')))
                     AND  pe.begin_date = TRUNC(mi.start_date) );
  END IF;

  -- 3.If rule is R and there match_ind is 18,19,22 or 23 then the records must have been
  -- processed in prior runs and didn't get updated .. update to status 1
  IF l_rule = 'R' THEN
    UPDATE igs_ad_emp_int_all
    SET status = '1'
    WHERE interface_run_id = l_interface_run_id
      AND match_ind IN ('18','19','22','23')
      AND status='2';
  END IF;

  -- 4.If rule is R and match_ind is neither 21 nor 25 then error
  IF l_rule = 'R' THEN
    UPDATE igs_ad_emp_int_all
    SET status = '3',
        ERROR_CODE = 'E695'
    WHERE interface_run_id = l_interface_run_id
      AND (match_ind IS NOT NULL AND match_ind NOT IN ('21','25'))
      AND status='2';
  END IF;

  -- 5.If rule is R, set duplicated records with no discrepancy to status 1 and match_ind 23
  IF l_rule = 'R' THEN
    UPDATE igs_ad_emp_int_all mi
    SET status = '1',
        match_ind = '23'
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS ( SELECT '1'
                   FROM hz_employment_history  pe, igs_ad_interface_all ii, igs_ad_hz_emp_dtl ahed, hz_parties hz
                   WHERE  ii.interface_run_id = l_interface_run_id
             AND  ii.interface_id = mi.interface_id
             AND  ii.person_id = pe.party_id
	     AND  pe.employment_history_id = ahed.employment_history_id (+)
	     AND  pe.employed_by_party_id = hz.party_id (+)
             AND  ((NVL(UPPER(mi.employer),'*!') = NVL(UPPER(pe.employed_by_name_company),'*'))
	            OR (NVL(hz.party_number,'*!') = NVL(mi.employer_party_number,'*')))
             AND  pe.begin_date = TRUNC(mi.start_date)
             AND  NVL(pe.end_date,igs_ge_date.igsdate('9999/01/01')) = NVL(TRUNC(mi.end_date),igs_ge_date.igsdate('9999/01/01'))
             AND  NVL(pe.supervisor_name,'*') = NVL(mi.contact,'*')
             AND  NVL(pe.employment_type_code,'*') = NVL(UPPER(mi.type_of_employment),'*')
             AND  NVL(pe.fraction_of_tenure,0) = NVL(mi.fraction_of_employment,0)
             AND  NVL(pe.tenure_code,'*') = NVL(UPPER(mi.tenure_of_employment),'*')
             AND  NVL(pe.employed_as_title,'*') = NVL(mi.position,'*')
             AND  NVL(ahed.occupational_title_code,'*') = NVL(mi.occupational_title_code,'*')
             AND  NVL(pe.weekly_work_hours,0) = NVL(mi.weekly_work_hrs,0)
             AND  NVL(pe.employed_by_division_name,'*') = NVL(mi.employed_by_division_name,'*')
             AND  NVL(pe.reason_for_leaving,'*') = NVL(mi.reason_for_leaving,'*')
	     AND  NVL(pe.comments,'*') = NVL(mi.comments,'*')
             );
  END IF;

  -- 6.If rule in R  records still exist, they are duplicates and have discrepancy .. update status=3,match_ind=20
  IF l_rule = 'R' THEN
    UPDATE igs_ad_emp_int_all mi
    SET status = '3',
        match_ind = '20',
    dup_employment_number  = (SELECT employment_history_id
                              FROM   hz_employment_history  pe, igs_ad_interface_all ii, hz_parties hz
                              WHERE  ii.interface_run_id = l_interface_run_id
                                AND  ii.interface_id = mi.interface_id
                                AND  ii.person_id = pe.party_id
				AND  pe.employed_by_party_id = hz.party_id (+)
                                AND ((NVL(UPPER(mi.employer),'*!') = NVL(UPPER(pe.employed_by_name_company),'*'))
		                  OR (NVL(mi.employer_party_number,'*!') = NVL(hz.party_number,'*')))
                                AND  pe.begin_date = TRUNC(mi.start_date)
				AND  ROWNUM = 1)
    WHERE mi.interface_run_id = l_interface_run_id
      AND mi.match_ind IS NULL
      AND mi.status = '2'
      AND EXISTS (SELECT '1'
                  FROM   hz_employment_history  pe, igs_ad_interface_all ii, hz_parties hz
                  WHERE  ii.interface_run_id = l_interface_run_id
                    AND  ii.interface_id = mi.interface_id
                    AND  ii.person_id = pe.party_id
		    AND  pe.employed_by_party_id = hz.party_id (+)
                    AND ((NVL(UPPER(mi.employer),'*!') = NVL(UPPER(pe.employed_by_name_company),'*'))
                      OR (NVL(mi.employer_party_number,'*!') = NVL(hz.party_number,'*')))
                    AND  pe.begin_date = TRUNC(mi.start_date));
  END IF;

  FOR person_emp_rec IN  emp_dtls(l_interface_run_id) LOOP
    l_processed_records := l_processed_records + 1;

    DECLARE
      CURSOR chk_dup_emp_dtls(cp_employer VARCHAR2,
                              cp_employer_party_number VARCHAR2,
                              cp_person_id NUMBER,
                              cp_start_date igs_ad_emp_dtl.start_dt%TYPE) IS
      SELECT heh.rowid row_id,
      heh.employment_history_id,
      heh.party_id  person_id,
      heh.begin_date  start_dt,
      heh.end_date  end_dt,
      heh.supervisor_name contact,
      heh.employment_type_code type_of_employment,
      heh.fraction_of_tenure fraction_of_employment,
      heh.tenure_code tenure_of_employment,
      heh.employed_as_title  position,
      ahed.occupational_title_code,
      heh.weekly_work_hours,
      heh.comments,
      heh.employed_by_name_company  employer,
      heh.employed_by_division_name,
      heh.branch,
      heh.military_rank,
      heh.served,
      heh.station,
      heh.object_version_number,
      heh.employed_by_party_id,
      heh.reason_for_leaving reason_for_leaving,
      null occupational_title
         FROM  hz_employment_history heh,  igs_ad_hz_emp_dtl ahed, hz_parties hz
         WHERE heh.party_id = cp_person_id
	 AND  heh.employment_history_id = ahed.employment_history_id (+)
	 AND  heh.employed_by_party_id = hz.party_id (+)
         AND ( NVL(UPPER(heh.employed_by_name_company),'!*!') = NVL(UPPER(cp_employer),'!*!')
	       OR
               NVL(hz.party_number,'!*!') = NVL(cp_employer_party_number,'!*!'))
	 AND
         TRUNC(heh.begin_date) = TRUNC(cp_start_date);
      dup_emp_dtlsc_rec chk_dup_emp_dtls%ROWTYPE;

    BEGIN
       -- Upper validation for type_of_employment and tenure_of_employment   Bug: 2425608
      person_emp_rec.type_of_employment := UPPER(person_emp_rec.Type_Of_Employment);
      person_emp_rec.tenure_of_employment :=  UPPER(person_emp_rec.Tenure_Of_Employment) ;
      person_emp_rec.start_date := TRUNC(person_emp_rec.Start_Date);  --  Time is truncated
      person_emp_rec.end_date := TRUNC(person_emp_rec.end_date);
      dup_emp_dtlsc_rec.employment_history_id := NULL;

      OPEN chk_dup_emp_dtls(person_emp_rec.employer,person_emp_rec.employer_party_number,person_emp_rec.person_id,person_emp_rec.start_date);
      FETCH chk_dup_emp_dtls INTO dup_emp_dtlsc_rec;
      CLOSE chk_dup_emp_dtls;
      IF dup_emp_dtlsc_rec.employment_history_id IS NOT NULL THEN
        IF l_rule = 'I' THEN
        DECLARE
          l_employer_party_id NUMBER;
        BEGIN
          -- Validate the values of person_emp_rec.
          validate_emp_dtls(PERSON_EMP_REC,l_employer_party_id,l_error_code);
          IF l_error_code IS  NULL THEN  -- nsidana Bug 3541735 : Corrected the check from not null --> null.
              igs_ad_emp_dtl_pkg.update_row (
                      x_rowid                  => dup_emp_dtlsc_rec.row_id,
                      x_employment_history_id => dup_emp_dtlsc_rec.employment_history_id,
                      x_person_id              => NVL(person_emp_rec.person_id,dup_emp_dtlsc_rec.person_id),
                      x_start_dt               => NVL(person_emp_rec.start_date,dup_emp_dtlsc_rec.start_dt),
                      x_end_dt                 => NVL(person_emp_rec.end_date,dup_emp_dtlsc_rec.end_dt),
                      x_type_of_employment     => NVL(person_emp_rec.type_of_employment,dup_emp_dtlsc_rec.type_of_employment),
                      x_fraction_of_employment => NVL(person_emp_rec.fraction_of_employment,dup_emp_dtlsc_rec.fraction_of_employment),
                      x_tenure_of_employment   => NVL(person_emp_rec.tenure_of_employment,dup_emp_dtlsc_rec.tenure_of_employment),
                      x_position               => NVL(person_emp_rec.position,dup_emp_dtlsc_rec.position),
                      x_occupational_title_code => NVL(person_emp_rec.occupational_title_code,dup_emp_dtlsc_rec.occupational_title_code),
                      x_occupational_title     => dup_emp_dtlsc_rec.occupational_title,
                      x_weekly_work_hours      => NVL(person_emp_rec.weekly_work_hrs,dup_emp_dtlsc_rec.weekly_work_hours),
                      x_comments               => NVL(person_emp_rec.comments,dup_emp_dtlsc_rec.comments),
                      x_employer               => NVL(person_emp_rec.employer,dup_emp_dtlsc_rec.employer),
                      x_employed_by_division_name => NVL(person_emp_rec.employed_by_division_name,dup_emp_dtlsc_rec.employed_by_division_name),
                      x_branch                 => NVL(person_emp_rec.branch,dup_emp_dtlsc_rec.branch),
                      x_military_rank          => NVL(person_emp_rec.military_rank,dup_emp_dtlsc_rec.military_rank),
                      x_served                 => NVL(person_emp_rec.served,dup_emp_dtlsc_rec.served),
                      x_station                => NVL(person_emp_rec.station,dup_emp_dtlsc_rec.station),
                      x_contact                => NVL(person_emp_rec.contact,dup_emp_dtlsc_rec.contact),    -- Bug : 2037512
                      x_msg_data               => l_msg_data,
                      x_return_status          => l_return_status,
		      x_object_version_number  => dup_emp_dtlsc_rec.object_version_number,
		      x_employed_by_party_id   => NVL(l_employer_party_id,dup_emp_dtlsc_rec.employed_by_party_id),
		      x_reason_for_leaving     => NVL(person_emp_rec.reason_for_leaving,dup_emp_dtlsc_rec.reason_for_leaving),
                      x_mode                   => 'R'
                    );

              IF l_return_Status IN ('E','U') THEN
                UPDATE IGS_AD_EMP_INT_all
                SET    error_code = 'E014',
                       status     = '3'
                WHERE  interface_emp_id = person_emp_rec.interface_emp_id;

                IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

                IF (l_request_id IS NULL) THEN
                   l_request_id := fnd_global.conc_request_id;
                END IF;

                l_label := 'igs.plsql.igs_ad_imp_006.prc_pe_empnt_dtls.exception: ' || 'e014';

                l_debug_str :=  'IGS_AD_IMP_006.Prc_Pe_Empnt_Dtls ' ||
                            'INTERFACE Emp Id : ' || IGS_GE_NUMBER.TO_CANN(Person_Emp_Rec.Interface_Emp_Id) ||
                            ' Status : 3 ' ||  'ErrorCode : E014 '||l_msg_data;

                fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
             END IF;

             IF l_enable_log = 'Y' THEN
                  igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,'E014');
             END IF;

         ELSE
                UPDATE igs_ad_emp_int_all
                SET     match_ind  = cst_mi_val_18 ,
                        STATUS = cst_stat_val_1, ERROR_CODE = NULL
                WHERE interface_emp_id = person_emp_rec.interface_emp_id;
              END IF;
         END IF;  -- if lerror_code is NOT null
    EXCEPTION
      WHEN OTHERS THEN
          UPDATE igs_ad_emp_int_all
          SET ERROR_CODE = 'E014',
              STATUS = '3'
          WHERE interface_emp_id = person_emp_rec.interface_emp_id;

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
            END IF;

            l_label := 'igs.plsql.igs_ad_imp_006.prc_pe_empnt_dtls.exception: ' || 'E014';

            l_debug_str :=  'IGS_AD_IMP_006.Prc_Pe_Empnt_Dtls ' ||
                            'INTERFACE Emp Id : ' || Person_Emp_Rec.Interface_Emp_Id ||
                            ' Status : 3 ' ||  'ErrorCode : E014 '||SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                         l_label,
			                 l_debug_str, NULL,
		                         NULL,NULL,NULL,NULL,TO_CHAR(l_request_id)
				       );
      END IF;

      IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,'E014');
      END IF;
    END;
    ELSIF l_rule = 'R' THEN
        IF PERSON_EMP_REC.match_ind = '21' THEN
        DECLARE
	  l_employer_party_id NUMBER;

        BEGIN
          -- Validate the values of person_emp_rec.
          validate_emp_dtls(PERSON_EMP_REC,l_employer_party_id,l_error_code);
          IF l_error_code IS  NULL THEN   -- nsidana Bug 3541735 : Corrected the check from not null --> null.
                   igs_ad_emp_dtl_pkg.update_row (
                           x_rowid                    => dup_emp_dtlsc_rec.row_id,
                           x_employment_history_id    => dup_emp_dtlsc_rec.employment_history_id,
                           x_person_id                => NVL(person_emp_rec.person_id,dup_emp_dtlsc_rec.person_id),
                           x_start_dt                 => NVL(person_emp_rec.start_date,dup_emp_dtlsc_rec.start_dt),
                           x_end_dt                   => NVL(person_emp_rec.end_date,dup_emp_dtlsc_rec.end_dt),
                           x_type_of_employment       => NVL(person_emp_rec.type_of_employment,dup_emp_dtlsc_rec.type_of_employment),
                           x_fraction_of_employment   => NVL(person_emp_rec.fraction_of_employment,dup_emp_dtlsc_rec.fraction_of_employment),
                           x_tenure_of_employment     => NVL(person_emp_rec.tenure_of_employment,dup_emp_dtlsc_rec.tenure_of_employment),
                           x_position                 => NVL(person_emp_rec.position,dup_emp_dtlsc_rec.position),
                           x_occupational_title_code  => NVL(person_emp_rec.occupational_title_code,dup_emp_dtlsc_rec.occupational_title_code),
                           x_occupational_title       => dup_emp_dtlsc_rec.occupational_title,
                           x_weekly_work_hours        => NVL(person_emp_rec.weekly_work_hrs,dup_emp_dtlsc_rec.weekly_work_hours),
                           x_comments                 => NVL(person_emp_rec.comments,dup_emp_dtlsc_rec.comments),
                           x_employer                 => NVL(person_emp_rec.employer,dup_emp_dtlsc_rec.employer),
                           x_employed_by_division_name => NVL(person_emp_rec.employed_by_division_name,dup_emp_dtlsc_rec.employed_by_division_name),
                           x_branch                   => NVL(person_emp_rec.branch,dup_emp_dtlsc_rec.branch),
                           x_military_rank            => NVL(person_emp_rec.military_rank,dup_emp_dtlsc_rec.military_rank),
                           x_served                   => NVL(person_emp_rec.served,dup_emp_dtlsc_rec.served),
                           x_station                  => NVL(person_emp_rec.station,dup_emp_dtlsc_rec.station),
                           x_contact                  => NVL(person_emp_rec.contact,dup_emp_dtlsc_rec.contact), ---Bug : 2037512
                           x_msg_data                 => l_msg_data,
                           x_return_status            => l_return_status,
			   x_object_version_number    => dup_emp_dtlsc_rec.object_version_number,
		           x_employed_by_party_id     => NVL(l_employer_party_id,dup_emp_dtlsc_rec.employed_by_party_id),
		           x_reason_for_leaving       => NVL(person_emp_rec.reason_for_leaving,dup_emp_dtlsc_rec.reason_for_leaving),
                           x_mode                     => 'R'
                       );


                 IF l_return_Status IN ('E','U') THEN
			UPDATE IGS_AD_EMP_INT_all
		        SET error_code = 'E014',
		               status = '3'
			WHERE interface_emp_id = person_emp_rec.interface_emp_id;

		        IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                             IF (l_request_id IS NULL) THEN
			         l_request_id := fnd_global.conc_request_id;
		             END IF;

		             l_label := 'igs.plsql.igs_ad_imp_006.prc_pe_empnt_dtls.exception: '|| 'E014';

		             l_debug_str := 'IGS_AD_IMP_006.Prc_Pe_Empnt_Dtls ' ||
					    'INTERFACE Emp Id : ' || Person_Emp_Rec.Interface_Emp_Id ||
			                    ' Status : 3 ' ||  'ErrorCode : E014 '|| l_msg_data;

		             fnd_log.string_with_context( fnd_log.level_exception,
						          l_label,
				                          l_debug_str, NULL,
				                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
			 END IF;

			 IF l_enable_log = 'Y' THEN
			     igs_ad_imp_001.logerrormessage(Person_Emp_Rec.Interface_Emp_Id,'E014');
			 END IF;

	         ELSE
		        UPDATE igs_ad_emp_int_all
			SET    match_ind  = cst_mi_val_18 ,
			       STATUS = cst_stat_val_1, ERROR_CODE = NULL
		        WHERE interface_emp_id = person_emp_rec.interface_emp_id;
		 END IF;  -- if l_ret_status
          END IF;  -- if l_err_code
	END;  -- inner begin
      END IF;  -- if match_ind
      END IF;  -- if l_rule
    ELSE -- Duplicate Not exist -- so create new history details
        crt_emp_dtls(PERSON_EMP_REC);
    END IF;  -- if chk_dup
    END;  -- begin
    IF l_processed_records = 100 THEN
      COMMIT;
      l_processed_records := 0 ;
    END IF;
  END LOOP;
END Prc_Pe_Empnt_Dtls;

  PROCEDURE Prc_Pe_Extclr_Dtls(
    P_SOURCE_TYPE_ID IN NUMBER,
    P_BATCH_ID    IN VARCHAR2
  ) AS

  l_dup_person_interest_id  IGS_AD_EXCURR_INT.DUP_PERSON_INTEREST_ID%TYPE;
  l_last_update_date IGS_AD_EXTRACURR_ACT_V.LAST_UPDATE_DATE%TYPE;
  l_interface_run_id igs_ad_interface_all.interface_run_id%TYPE;
    CURSOR  extracurr(cp_interface_run_id igs_ad_interface_all.interface_run_id%TYPE) IS
    SELECT  hii.*, i.person_id
    FROM    igs_ad_excurr_int_all hii, igs_ad_interface_all i
    WHERE  hii.interface_run_id = cp_interface_run_id
    AND    i.interface_id = hii.interface_id
        AND    i.interface_run_id = cp_interface_run_id
    AND    hii.status  = '2';

    extracurr_rec  extracurr%ROWTYPE;
    l_Var VARCHAR2(1);
    l_error_code VARCHAR2(10);
    l_msg_data   VARCHAR2(2000);
    l_return_status VARCHAR2(1);
    l_rule VARCHAR2(1);
    l_DUP_VAR BOOLEAN;
    l_RowId    VARCHAR2(25);
    l_person_interest_id     NUMBER;
    l_processed_records NUMBER(5) := 0 ;
    l_prog_label  VARCHAR2(4000);
    l_label  VARCHAR2(4000);
    l_debug_str VARCHAR2(4000);
    l_enable_log VARCHAR2(1);
    l_request_id NUMBER(10);

-------------Start of local procedure validate_pe_excurr ------------
PROCEDURE validate_pe_excurr (EXTRACURR_REC IN extracurr%ROWTYPE, p_error_code OUT NOCOPY VARCHAR2) AS
      l_var  VARCHAR2(1);

      CURSOR  birth_date_cur(cp_person_id igs_pe_person_base_v.person_id%TYPE) IS
      SELECT birth_date
      FROM   igs_pe_person_base_v
      WHERE  person_id = cp_person_id;

      l_birth_date  igs_pe_person_base_v.birth_date%TYPE;

BEGIN

      --3. Perform validations for the following columns
      --INTEREST_TYPE

      --LEVEL_OF_PARTICIPATION
      IF EXTRACURR_REC.LEVEL_OF_PARTICIPATION IS NOT NULL THEN
        IF NOT
        (igs_pe_pers_imp_001.validate_lookup_type_code('PARTICIPATION_LEVEL',extracurr_rec.level_of_participation,222))
        THEN
          p_error_code := 'E233';
          RAISE no_data_found;
        END IF;
      END IF;

      --HOURS_PER_WEEK
      IF EXTRACURR_REC.HOURS_PER_WEEK IS NOT NULL THEN
        IF EXTRACURR_REC.HOURS_PER_WEEK > 0 AND EXTRACURR_REC.HOURS_PER_WEEK <= 168 THEN
          --Validation Successful
          NULL;
        ELSE
          --Validation Unsuccessful
          p_error_code := 'E227';
          RAISE NO_DATA_FOUND;
        END IF;
      END IF;

      --WEEKS_PER_YEAR
      IF EXTRACURR_REC.WEEKS_PER_YEAR IS NOT NULL THEN
        IF EXTRACURR_REC.WEEKS_PER_YEAR > 0 AND EXTRACURR_REC.WEEKS_PER_YEAR <= 52 THEN
          --Validation Successful
          NULL;
        ELSE
          --Validation Unsuccessful
          p_error_code := 'E219';
          RAISE NO_DATA_FOUND;
        END IF;
      END IF;

      --COMMENTS
      --No Validation for this field
      --START_DATE

      --No Validation for this field.
      --END_DATE

      OPEN birth_date_cur(extracurr_rec.person_id);
      FETCH birth_date_cur INTO l_birth_date;
      CLOSE birth_date_cur;

      IF l_birth_date IS NOT NULL AND EXTRACURR_REC.START_DATE IS NOT NULL THEN
        IF EXTRACURR_REC.START_DATE < l_birth_date THEN
          p_error_code := 'E222';
              RAISE NO_DATA_FOUND;
        ELSE
              NULL;
    END IF;
      END IF;


      IF EXTRACURR_REC.END_DATE IS NOT NULL AND  EXTRACURR_REC.START_DATE IS NULL THEN
            --Validation Unsuccessful
        p_error_code := 'E212';
        RAISE NO_DATA_FOUND;
      ELSIF ( EXTRACURR_REC.START_DATE IS NOT NULL
                  AND EXTRACURR_REC.END_DATE IS NOT NULL
                  AND TRUNC(EXTRACURR_REC.END_DATE)  >= TRUNC(EXTRACURR_REC.START_DATE)
                        ) OR EXTRACURR_REC.END_DATE IS NULL THEN
            --Validation Successful
        NULL;
      ELSE
        p_error_code := 'E208';
        RAISE NO_DATA_FOUND;
      END IF;

      --SPORT_INDICATOR
      IF EXTRACURR_REC.SPORT_INDICATOR IS NOT NULL THEN
        IF EXTRACURR_REC.SPORT_INDICATOR IN ('Y','N' ) THEN
          --Validation Successful
          NULL;
        ELSE
          --Validation Unsuccessful
          p_error_code := 'E213';
          RAISE NO_DATA_FOUND;
        END IF;
      END IF;

      --SUB_INTEREST_TYPE_CODE
--    IF EXTRACURR_REC.SUB_INTEREST_TYPE_CODE IS NOT NULL THEN
--          IF EXTRACURR_REC.SUB_INTEREST_TYPE_CODE IN ('INTEREST_TYPE','ENTERTAINMENT') THEN
          --Validation Successful
          -- now validate the INTEREST_TYPE code whether it belongs to the lookup_type as
          -- per the SUB_INTEREST_TYPE_CODE
          -- In the form the SUB_INTEREST_TYPE_CODE is populated internally when a value for the
          -- INTEREST_TYPE Code is selected.
    IF EXTRACURR_REC.SUB_INTEREST_TYPE_CODE IS NOT NULL THEN
      IF EXTRACURR_REC.SUB_INTEREST_TYPE_CODE NOT IN ('INTEREST_TYPE','ENTERTAINMENT')  THEN
        p_error_code := 'E231';
        RAISE NO_DATA_FOUND;
      ELSIF EXTRACURR_REC.INTEREST_TYPE_CODE IS NULL THEN
        p_error_code := 'E216';
        RAISE NO_DATA_FOUND;
      ELSE
        IF NOT
        (igs_pe_pers_imp_001.validate_lookup_type_code(extracurr_rec.sub_interest_type_code,extracurr_rec.interest_type_code,222))
        THEN
          p_error_code := 'E254';
      RAISE NO_DATA_FOUND;
        END IF;
      END IF;

    ELSE
      IF EXTRACURR_REC.INTEREST_TYPE_CODE IS NOT NULL  THEN
        IF NOT
        (igs_pe_pers_imp_001.validate_lookup_type_code('INTEREST_TYPE',extracurr_rec.interest_type_code,222))
    OR
    (igs_pe_pers_imp_001.validate_lookup_type_code('ENTERTAINMENT',extracurr_rec.interest_type_code,222))
        THEN
          p_error_code := 'E232';
          RAISE no_data_found;
        END IF;
      END IF;
    END IF;

    -- added Activity Source CD as part of ID prospective applicant part 2 of 1
    --ACTIVITY SOURCE CD
    IF EXTRACURR_REC.ACTIVITY_SOURCE_CD IS NOT NULL THEN
      IF NOT
      (igs_pe_pers_imp_001.validate_lookup_type_code('ACTIVITY_SOURCE',EXTRACURR_REC.ACTIVITY_SOURCE_CD,8405))
      THEN
        p_error_code := 'E230';
    RAISE NO_DATA_FOUND;
      END IF;

    ELSE -- This column has been newly added to the existing table
        -- it cannot be made not null at the data base level.
        -- checking for it programatically and giving an error when
        -- the column is null
        p_error_code := 'E215';
        RAISE NO_DATA_FOUND;
    END IF;


      --Validation successful
      p_error_code := NULL;
      UPDATE igs_ad_excurr_int_all
      SET    STATUS = '1'
      WHERE  INTERFACE_EXCURR_ID = EXTRACURR_REC.INTERFACE_EXCURR_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      -- Validation Unsuccessful
        UPDATE igs_ad_excurr_int_all
        SET    STATUS = '3',
        ERROR_CODE = p_error_code
        WHERE  INTERFACE_EXCURR_ID = EXTRACURR_REC.INTERFACE_EXCURR_ID;

    IF l_enable_log = 'Y' THEN
      igs_ad_imp_001.logerrormessage(EXTRACURR_REC.INTERFACE_EXCURR_ID,p_error_code);
    END IF;

    END validate_pe_excurr;
-------------End of local procedure validate_pe_excurr ------------
      -- Local Procedure crt_extra_cur
PROCEDURE crt_extra_cur(EXTRACURR_REC    extracurr%ROWTYPE) AS
      l_rowid VARCHAR2(25);
      l_person_interest_id NUMBER;
      l_return_status  VARCHAR2(1);
      l_msg_count NUMBER;
      l_msg_data VARCHAR2(2000);
      l_extracurr_act_id NUMBER;
      l_error_code VARCHAR2(10);
      l_sub_interest_type_code EXTRACURR_REC.SUB_INTEREST_TYPE_CODE%TYPE;
      l_object_version_number NUMBER;

BEGIN

  IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

    IF (l_request_id IS NULL) THEN
      l_request_id := fnd_global.conc_request_id;
    END IF;

    l_label := 'igs.plsql.igs_ad_imp_006.crt_extra_cur.Begin';
    l_debug_str := 'INTERFACE Excurr Id : ' || extracurr_rec.interface_excurr_id;

    fnd_log.string_with_context( fnd_log.level_procedure,
                                  l_label,
                          l_debug_str, NULL,
                  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
  END IF;

    validate_pe_excurr(EXTRACURR_REC, l_error_code);

    IF l_error_code IS NULL THEN
      IF EXTRACURR_REC.INTEREST_TYPE_CODE IS NOT NULL AND EXTRACURR_REC.SUB_INTEREST_TYPE_CODE IS NULL THEN
        IF NOT
        (igs_pe_pers_imp_001.validate_lookup_type_code('INTEREST_TYPE',extracurr_rec.interest_type_code,222))
    OR
    (igs_pe_pers_imp_001.validate_lookup_type_code('ENTERTAINMENT',extracurr_rec.interest_type_code,222))
        THEN
          RAISE NO_DATA_FOUND;
        END IF;
      ELSE
          l_sub_interest_type_code := EXTRACURR_REC.SUB_INTEREST_TYPE_CODE;
      END IF;

       --Igs_Ad_Extracurr_Act_Pkg signature is modified to include HZ.K impact changes
       Igs_Ad_Extracurr_Act_Pkg.Insert_Row(
          x_rowid => l_RowId,
          x_person_interest_id => l_Person_Interest_Id,
          x_person_id =>  extracurr_rec.person_id,
          x_interest_type_code =>  extracurr_rec.interest_type_code,
          x_comments  => extracurr_rec.comments,
          x_start_date => EXTRACURR_REC.Start_Date,
          x_end_date  => EXTRACURR_REC.End_Date,
          x_hours_per_week => EXTRACURR_REC.hours_per_week,
          x_weeks_per_year => EXTRACURR_REC.weeks_per_year,
          x_level_of_interest => EXTRACURR_REC.level_of_interest,
          x_level_of_participation => EXTRACURR_REC.level_Of_Participation,
          x_sport_indicator => EXTRACURR_REC.sport_indicator,
          x_sub_interest_type_code => l_sub_interest_type_code,
          x_interest_name   => EXTRACURR_REC.Interest_name,
          x_team  => EXTRACURR_REC.team,
          x_wh_update_date => NULL,
          -- added Activity Source CD as part of ID prospective applicant part 2 of 1
          X_ACTIVITY_SOURCE_CD =>  extracurr_rec.activity_source_cd,
          x_last_update_date => l_last_update_date,
          x_msg_Data=> l_msg_Data,
          x_return_Status => l_return_status,
	  x_object_version_number  => l_object_version_number,
          x_mode => 'R');

        IF l_return_Status IN ('E','U') THEN
          UPDATE
            igs_ad_excurr_int_all
          SET
            ERROR_CODE = 'E322',
            STATUS = '3'
          WHERE
            INTERFACE_EXCURR_ID =  extracurr_rec.INTERFACE_EXCURR_ID;


            IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

              IF (l_request_id IS NULL) THEN
            l_request_id := fnd_global.conc_request_id;
              END IF;

              l_label := 'igs.plsql.igs_ad_imp_006.crt_extra_cur.exception';

              l_debug_str := 'IGS_AD_IMP_006.Prc_Pe_Extclr_Dtls ' ||
                    'INTERFACE Excurr Id : ' || EXTRACURR_REC.INTERFACE_EXCURR_ID ||
                    ' Status : 3 ' ||  'ErrorCode : E322 '|| l_msg_data;

              fnd_log.string_with_context( fnd_log.level_exception,
                              l_label,
                              l_debug_str, NULL,
                              NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
            END IF;

            IF l_enable_log = 'Y' THEN
              igs_ad_imp_001.logerrormessage(EXTRACURR_REC.INTERFACE_EXCURR_ID,'E322');
            END IF;

        ELSE
          UPDATE
            igs_ad_excurr_int_all
          SET
            STATUS = '1'
          WHERE
            INTERFACE_EXCURR_ID = extracurr_rec.INTERFACE_EXCURR_ID;
        END IF;
       END IF;
    EXCEPTION
      WHEN OTHERS THEN
      -- Validation Unsuccessful
        UPDATE igs_ad_excurr_int_all
        SET    STATUS = '3',
        ERROR_CODE = 'E322'
        WHERE  INTERFACE_EXCURR_ID = EXTRACURR_REC.INTERFACE_EXCURR_ID;

      IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

            IF (l_request_id IS NULL) THEN
              l_request_id := fnd_global.conc_request_id;
        END IF;

            l_label := 'igs.plsql.Igs_Ad_Imp_006.crt_extra_cur.exception';

          l_debug_str :=  'Igs_Ad_Imp_006.Prc_Pe_Extclr_Dtls ' ||
                      'INTERFACE Excurr Id : ' || IGS_GE_NUMBER.TO_CANN(EXTRACURR_REC.INTERFACE_EXCURR_ID) ||
                          ' Status : 3 ' ||  'ErrorCode : E322 ' ||  SQLERRM;

            fnd_log.string_with_context( fnd_log.level_exception,
                                      l_label,
                          l_debug_str, NULL,
                          NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
      END IF;

      IF l_enable_log = 'Y' THEN
            igs_ad_imp_001.logerrormessage(EXTRACURR_REC.INTERFACE_EXCURR_ID,'E322');
      END IF;

    END crt_extra_cur;
  -- End Local crt_extra_cur

  BEGIN

  l_enable_log := igs_ad_imp_001.g_enable_log;
  l_prog_label := 'igs.plsql.igs_ad_imp_006.prc_pe_extclr_dtls';
  l_label := 'igs.plsql.igs_ad_imp_006.prc_pe_extclr_dtls.';
  l_interface_run_id := igs_ad_imp_001.g_interface_run_id;
-- No duplicate check!! Hence, different logic
      FOR extracurr_rec IN extracurr(l_interface_run_id) LOOP
       l_processed_records := l_processed_records + 1;

       -- Find out NOCOPY the duplicate check from HQ ..sine dup_extracurr_act_id is removed from the table
       extracurr_rec.interest_type_code := UPPER(extracurr_rec.interest_type_code);
       extracurr_rec.sub_interest_type_code := UPPER(extracurr_rec.sub_interest_type_code);
       extracurr_rec.activity_source_cd := UPPER(extracurr_rec.activity_source_cd);
       extracurr_rec.level_of_interest := UPPER(extracurr_rec.level_of_interest);
       extracurr_rec.level_of_participation := UPPER(extracurr_rec.level_of_participation);
       extracurr_rec.start_date := TRUNC(extracurr_rec.start_date);
       extracurr_rec.end_date := TRUNC(extracurr_rec.end_date);
       crt_extra_cur(extracurr_rec);
      IF l_processed_records = 100 THEN
         COMMIT;
         l_processed_records := 0 ;
      END IF;

    END LOOP;
  END Prc_Pe_Extclr_Dtls;
END Igs_Ad_Imp_006;

/
