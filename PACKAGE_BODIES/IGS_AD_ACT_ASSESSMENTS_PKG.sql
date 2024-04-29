--------------------------------------------------------
--  DDL for Package Body IGS_AD_ACT_ASSESSMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_ACT_ASSESSMENTS_PKG" AS
/* $Header: IGSADD1B.pls 120.8 2006/04/12 03:09:52 akadam noship $ */
/* ------------------------------------------------------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose : Import ACT Assessment Details Process
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
      stammine         23-Dec-2004         bug# 4085289
                                          IGSQ2UKR:IMPORT ACT ASSESSMENT DETAILS PROCESS DOES NOT IMPORT FOR NON-USCOUNTRY
      stammine         13-Mar-2005        bug# 4252413 ACT - PLANNED COMPLETION DATE INCORRECT
      stammine         28-Feb-2005	  bug#4693325 Import Act Assessment Details Process Cancels When Unexpected Char
                                          Found in National/Local Norm columns of ACT_STATISTICS
 ---------------------------------------------------------------------------------------------------------------------------*/
/******************************************************************************
-- GLOBAL VARIABLES AND CONSTANTS

G_SSN_Person_Id_Type IGS_PE_PERSON_ID_TYP.PERSON_ID_TYPE%TYPE;
G_ACT_Person_Id_Type IGS_PE_PERSON_ID_TYP.PERSON_ID_TYPE%TYPE;
G_Score_Source_id    IGS_AD_CODE_CLASSES.CODE_ID%TYPE;
G_Transcript_Source  IGS_AD_CODE_CLASSES.CODE_ID%TYPE;
G_Grading_Scale      IGS_AD_CODE_CLASSES.CODE_ID%TYPE;
G_Unit_Difficulty    IGS_AD_CODE_CLASSES.CODE_ID%TYPE;

 ***************************************************************************** */


batch_id NUMBER := null;

/* This function is used to generate the batch_id into the ASSESSMENT Table through SQL Loader Process */
FUNCTION get_batch_id RETURN NUMBER AS
 BEGIN
   IF batch_id IS NULL THEN
     SELECT
      IGS_AD_ACT_ASSESSMENTS_S.nextval
     INTO batch_id
     FROM dual;
   END IF;
   return batch_id;
 END get_batch_id;


/* Local function to get the lookup meaning */

FUNCTION get_lookup_meaning (p_lookup_code igs_lookup_values.lookup_code%type) RETURN VARCHAR2 AS
  l_lookup_meaning igs_lookup_values.meaning%type;

  CURSOR c_lookup_meaning (cp_lookup_code igs_lookup_values.lookup_code%type) IS
   SELECT meaning from igs_lookup_values where lookup_code = cp_lookup_code and lookup_type = 'ACT_STATISTIC_CATEGORY';
 BEGIN
    l_lookup_meaning:= NULL;
    OPEN c_lookup_meaning(p_lookup_code);
    FETCH c_lookup_meaning INTO l_lookup_meaning;
    CLOSE c_lookup_meaning;
    RETURN  l_lookup_meaning;
  END get_lookup_meaning;




/* This function checks the Required setups for importing the data From ACT data store to Interface Tables.
   Returns the Error code 2 if the Required setup is not met.
   Returns 1 if the Required setup is met.
   This function also set the global variables to respective values requried while inserting into Interface Tables. */

FUNCTION  Check_Setups (
                  p_ACT_Batch_Id     IN IGS_AD_ACT_ASSESSMENTS.ACT_BATCH_ID%type,
		  p_Reporting_Year   IN IGS_AD_ACT_ASSESSMENTS.REPORTING_YEAR%type,
                  p_Test_Type        IN IGS_AD_ACT_ASSESSMENTS.TEST_TYPE%type,
		  p_Test_Date        IN IGS_AD_ACT_ASSESSMENTS.TEST_DATE_TXT%type,
		  p_ACT_Id           IN IGS_AD_ACT_ASSESSMENTS.act_identifier%type)
		  RETURN NUMBER AS

 l_return NUMBER;
 -- l_Country_Code VARCHAR2(30);

  -- Cursor to select the Person_ID_Type from IGS_PE_PERSON_ID_TYP where Sys_ID_Type = 'SSN'
   CURSOR c_ssn_Person_Id_Type IS
    SELECT
        PERSON_ID_TYPE
    FROM IGS_PE_PERSON_ID_TYP
    WHERE S_PERSON_ID_TYPE = 'SSN'
     AND CLOSED_IND ='N';

   -- Cursor to select the Person_ID_Type from IGS_PE_PERSON_ID_TYP where Sys_ID_Type = 'ACTID'
   CURSOR c_Act_Person_Id_Type IS
    SELECT
        PERSON_ID_TYPE
    FROM IGS_PE_PERSON_ID_TYP
    WHERE S_PERSON_ID_TYPE = 'ACTID'
     AND CLOSED_IND ='N';

   -- Cursor to check and select the corresponding cod_id for Test_Score_Source  = ELEC
    CURSOR c_Test_Score_Source IS
      SELECT
       CODE_ID
      FROM IGS_AD_CODE_CLASSES
      WHERE CLASS = 'SYS_SCORE_SOURCE'
       AND NAME = 'ELEC'
       AND CLOSED_IND = 'N'
       AND CLASS_TYPE_CODE='ADM_CODE_CLASSES';

   -- Cursor to check and select the corresponding cod_id for Transcript_Source  = ACT
    CURSOR c_Transcript_Source IS
     SELECT
      CODE_ID
     FROM IGS_AD_CODE_CLASSES
     WHERE CLASS = 'TRANSCRIPT_SOURCE'
      AND CLOSED_IND = 'N'
      AND NAME = 'ACT'
      AND CLASS_TYPE_CODE='ADM_CODE_CLASSES';

    -- Cursor to check and select the corresponding cod_id for Grading_Scale  = 4 POINT
    CURSOR c_Grading_Scale IS
     SELECT
      CODE_ID
     FROM IGS_AD_CODE_CLASSES
     WHERE CLASS = 'GRADING_SCALE_TYPES'
      AND CLOSED_IND = 'N'
      AND NAME = '4 POINT'
      AND CLASS_TYPE_CODE='ADM_CODE_CLASSES';

    -- Cursor to check and select the corresponding cod_id for Unit_Difficulty  = STANDARD
    CURSOR c_Unit_Difficulty IS
     SELECT
      CODE_ID
     FROM IGS_AD_CODE_CLASSES
     WHERE CLASS = 'UNIT_DIFFICULTY'
      AND CLOSED_IND = 'N'
      AND NAME = 'STANDARD'
      AND CLASS_TYPE_CODE='ADM_CODE_CLASSES';

     -- Cursor to Check the Assessments Grade Level Setup.
  CURSOR c_Assessment_grade_level ( cp_ACT_Batch_Id IGS_AD_ACT_ASSESSMENTS.ACT_BATCH_ID%type,
		  cp_Reporting_Year IGS_AD_ACT_ASSESSMENTS.REPORTING_YEAR%type,
                  cp_Test_Type IGS_AD_ACT_ASSESSMENTS.TEST_TYPE%type,
		  cp_Test_Date IGS_AD_ACT_ASSESSMENTS.TEST_DATE_TXT%type,
		  cp_ACT_Id    IGS_AD_ACT_ASSESSMENTS.act_identifier%type) IS
  SELECT
    DISTINCT Grade_Level LEVEL_OF_QUAL
  FROM IGS_AD_ACT_ASSESSMENTS actas
  WHERE actas.ACT_Batch_ID = cp_ACT_Batch_Id
    AND actas.Reporting_Year like nvl(cp_Reporting_Year,'%')
    AND actas.Test_Type like nvl(cp_Test_Type,'%')
    AND actas.TEST_DATE_TXT like nvl(cp_Test_Date,'%')
    AND actas.ACT_Identifier like nvl(cp_ACT_Id,'%')
    AND actas.Interface_Transfer_Date IS NULL
    AND actas.Grade_Level IS NOT NULL
  MINUS
    SELECT
      NAME  LEVEL_OF_QUAL
    FROM IGS_AD_CODE_CLASSES
    WHERE CLASS ='LEVEL_OF_QUAL'
    AND CLOSED_IND = 'N'
    AND CLASS_TYPE_CODE='ADM_CODE_CLASSES';

   -- Cursor to Check the Institution Codes Setup.
  CURSOR c_Assessment_Institution_code ( cp_ACT_Batch_Id IGS_AD_ACT_ASSESSMENTS.ACT_BATCH_ID%type,
		  cp_Reporting_Year IGS_AD_ACT_ASSESSMENTS.REPORTING_YEAR%type,
                  cp_Test_Type IGS_AD_ACT_ASSESSMENTS.TEST_TYPE%type,
		  cp_Test_Date IGS_AD_ACT_ASSESSMENTS.TEST_DATE_TXT%type,
		  cp_ACT_Id    IGS_AD_ACT_ASSESSMENTS.act_identifier%type) IS
  SELECT
    DISTINCT HIGH_SCHOOL_CODE INSTITUTION_CD
  FROM IGS_AD_ACT_ASSESSMENTS actas
  WHERE actas.ACT_Batch_ID = cp_ACT_Batch_Id
    AND actas.Reporting_Year like nvl(cp_Reporting_Year,'%')
    AND actas.Test_Type like nvl(cp_Test_Type,'%')
    AND actas.TEST_DATE_TXT like nvl(cp_Test_Date,'%')
    AND actas.ACT_Identifier like nvl(cp_ACT_Id,'%')
    AND actas.Interface_Transfer_Date IS NULL
    AND actas.High_School_Code IS NOT NULL
MINUS
  SELECT INSTITUTION_CD FROM IGS_OR_INSTITUTION WHERE INSTITUTION_STATUS
   IN (SELECT INSTITUTION_STATUS FROM IGS_OR_INST_STAT WHERE S_INSTITUTION_STATUS = 'ACTIVE' AND CLOSED_IND = 'N');


  -- Cursor to Check the Assessments Test Type Setup.
  CURSOR c_Assessment_Test_Type ( cp_ACT_Batch_Id IGS_AD_ACT_ASSESSMENTS.ACT_BATCH_ID%type,
		  cp_Reporting_Year IGS_AD_ACT_ASSESSMENTS.REPORTING_YEAR%type,
                  cp_Test_Type IGS_AD_ACT_ASSESSMENTS.TEST_TYPE%type,
		  cp_Test_Date IGS_AD_ACT_ASSESSMENTS.TEST_DATE_TXT%type,
		  cp_ACT_Id    IGS_AD_ACT_ASSESSMENTS.act_identifier%type) IS
  SELECT
    DISTINCT Decode (actas.Test_Type,'D','ACT-DANTES','F','ACT-INTERNATIONAL','I',
    	        'ACT-INSTITUTION','R','ACT-RESIDUAL','S','ACT-STATE','Z','ACT-ARRANGED','N','ACT-NATIONAL') ADMISSION_TEST_TYPE
  FROM IGS_AD_ACT_ASSESSMENTS actas
  WHERE actas.ACT_Batch_ID = cp_ACT_Batch_Id
    AND actas.Reporting_Year like nvl(cp_Reporting_Year,'%')
    AND actas.Test_Type like nvl(cp_Test_Type,'%')
    AND actas.TEST_DATE_TXT like nvl(cp_Test_Date,'%')
    AND actas.ACT_Identifier like nvl(cp_ACT_Id,'%')
    AND actas.Interface_Transfer_Date IS NULL
  MINUS
    SELECT
      ADMISSION_TEST_TYPE
    FROM IGS_AD_TEST_TYPE
    WHERE SCORE_TYPE = 'OFFICIAL';

  -- Cursor to Check the Assessments Test Segments Setup.
  CURSOR c_Test_Segments (
                     cp_ACT_Batch_Id IGS_AD_ACT_ASSESSMENTS.ACT_BATCH_ID%type,
		     cp_reporting_year IGS_AD_ACT_ASSESSMENTS.REPORTING_YEAR%type,
    		     cp_test_type IGS_AD_ACT_ASSESSMENTS.TEST_TYPE%type,
		     cp_test_date IGS_AD_ACT_ASSESSMENTS.TEST_DATE_TXT%type,
                     cp_act_id IGS_AD_ACT_ASSESSMENTS.act_identifier%type) IS
    SELECT/*+ no_expand */
      DISTINCT  Decode (aas.Test_Type,'D','ACT-DANTES','F','ACT-INTERNATIONAL','I',
    	        'ACT-INSTITUTION','R','ACT-RESIDUAL','S','ACT-STATE','Z','ACT-ARRANGED','N','ACT-NATIONAL') ADMISSION_TEST_TYPE,
		Decode(aas.STATISTIC_TYPE,'TEST','SCORE','TEST_SUB_SCORE','SUB SCORE') SEGMENT_TYPE,
		lkv.meaning TEST_SEGMENT_NAME
    FROM IGS_AD_ACT_STATISTICS aas ,
         IGS_LOOKUP_VALUES lkv
    WHERE  aas.Reporting_Year like nvl(cp_Reporting_Year,'%')
        AND aas.Test_Type like nvl(cp_Test_Type,'%')
        AND aas.TEST_DATE_TXT like nvl(cp_Test_Date,'%')
        AND aas.ACT_Identifier like nvl(cp_ACT_Id,'%')
        AND aas.STATISTIC_TYPE IN ('TEST','TEST_SUB_SCORE')
	AND STATISTIC_CATEGORY IN ('COMENGWRI','COMPOSITE','ENGLISH','MATHS','READING','SCIENCE','ALGCOGEOM',
'ARTSLIT','ELEMALG','PLGEOTRIG','RHESKILLS','SOCSTSCI' ,'USAGMECH' ,'WRITING')
	AND trim(aas.SCORE) <> '--'
	AND lkv.Lookup_code = aas.STATISTIC_CATEGORY
	AND lkv.lookup_type = 'ACT_STATISTIC_CATEGORY'
	AND aas.ACT_Identifier in (Select ACT_Identifier from IGS_AD_ACT_ASSESSMENTS where ACT_Batch_ID = cp_ACT_Batch_Id)
  MINUS
   SELECT
     ADMISSION_TEST_TYPE,
     SEGMENT_TYPE,
     TEST_SEGMENT_NAME
   FROM IGS_AD_TEST_SEGMENTS
   WHERE CLOSED_IND = 'N';


BEGIN
  l_return := 0;

  -- Stammine commented as part of bug# 4085289

  -- This process is available only if the IGS: Country Code profile value is 'US'
 /* FND_PROFILE.GET('OSS_COUNTRY_CODE',l_Country_code);
  IF l_Country_code <> 'US' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'This Concurrent Request is not available for non-US Country Profile');
    return 1;
  END IF; */


  OPEN c_ssn_Person_Id_Type;
  FETCH  c_ssn_Person_Id_Type INTO G_SSN_Person_Id_Type;
  IF c_ssn_Person_Id_Type%NOTFOUND THEN
       CLOSE c_ssn_Person_Id_Type;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Social Security Number Person ID Type is not Setup in Person Data Setup.');
       l_return := 1;
  ELSE
      CLOSE c_ssn_Person_Id_Type;
  END IF;


  OPEN c_Act_Person_Id_Type;
  FETCH  c_Act_Person_Id_Type INTO G_ACT_Person_Id_Type;
  IF c_Act_Person_Id_Type%NOTFOUND THEN
       CLOSE c_Act_Person_Id_Type;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'ACT Identifier Person ID Type is not Setup in Person Data Setup.');
       l_return := 1;
  ELSE
      CLOSE c_Act_Person_Id_Type;
  END IF;

  OPEN c_Test_Score_Source;
  FETCH  c_Test_Score_Source INTO G_Score_Source_id;
  IF c_Test_Score_Source%NOTFOUND THEN
       CLOSE c_Test_Score_Source;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Test Score Source of ELEC is not defined in Test Result Information Setup.');
       l_return := 1;
 ELSE
      CLOSE c_Test_Score_Source;
  END IF;

  OPEN c_Transcript_Source;
  FETCH  c_Transcript_Source INTO G_Transcript_Source;
  IF c_Transcript_Source%NOTFOUND THEN
       CLOSE c_Transcript_Source;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Transcript Source of ACT is not defined in Transcript Information Setup.');
       l_return := 1;
  ELSE
      CLOSE c_Transcript_Source;
  END IF;

  OPEN c_Grading_Scale;
  FETCH  c_Grading_Scale INTO G_Grading_Scale;
  IF c_Grading_Scale%NOTFOUND THEN
       CLOSE c_Grading_Scale;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Grading Scale Type of 4 POINT is not defined in Transcript Information Setup.');
       l_return := 1;
  ELSE
      CLOSE c_Grading_Scale;
  END IF;

  OPEN c_Unit_Difficulty;
  FETCH  c_Unit_Difficulty INTO G_Unit_Difficulty;
  IF c_Unit_Difficulty%NOTFOUND THEN
       CLOSE c_Unit_Difficulty;
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unit Difficulty of STANDARD is not defined in Transcript Information Setup.');
       l_return := 1;
  ELSE
      CLOSE c_Unit_Difficulty;
  END IF;

  FOR l_Admission_Test_Type IN c_Assessment_Test_Type ( p_ACT_Batch_Id, p_Reporting_Year,
                  p_Test_Type , p_Test_Date , p_ACT_Id)
  LOOP
     FND_MESSAGE.SET_NAME('IGS','IGS_AD_TEST_TYPE_SETUP');
     FND_MESSAGE.SET_TOKEN('SETUP', l_Admission_Test_Type.ADMISSION_TEST_TYPE);
     FND_FILE.PUT_LINE(Fnd_File.LOG,FND_MESSAGE.GET);
     l_return := 1;
  END LOOP;

  FOR l_Test_Segments IN c_Test_Segments (p_ACT_Batch_Id, p_Reporting_Year,p_Test_Type , p_Test_Date , p_ACT_Id)
  LOOP
     FND_FILE.PUT_LINE(Fnd_File.LOG,'FOR Admission Test Type :'||l_Test_Segments.ADMISSION_TEST_TYPE||'           Test Segment Name : '||l_Test_Segments.TEST_SEGMENT_NAME ||
         '                Segment Type : '|| l_Test_Segments.SEGMENT_TYPE || '        is not/incorrect setup');
     l_return := 1;
  END LOOP;

  FOR l_Assessment_grade_level IN c_Assessment_grade_level (p_ACT_Batch_Id, p_Reporting_Year,p_Test_Type , p_Test_Date , p_ACT_Id)
  LOOP
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Level of Qualification : '||l_Assessment_grade_level.LEVEL_OF_QUAL ||'  is not/incorrect Setup in Application Detail Codes Data Setup.');
     l_return := 1;
  END LOOP;

  FOR l_Assessment_Institution_code IN c_Assessment_Institution_code (p_ACT_Batch_Id, p_Reporting_Year,p_Test_Type , p_Test_Date , p_ACT_Id)
  LOOP
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Institution Code : '||l_Assessment_Institution_code.INSTITUTION_CD ||'  is not/incorrect Setup in Organization Structure Setup.');
     l_return := 1;
  END LOOP;

  RETURN l_return;
END Check_Setups;




-- Loading the values into Interface tables from the ACT Data Store
/* This Procedure  Import the Act Data into the OSS tables.
   Process Stores the ACT Data into Interface tables and
   call the Import Process to import data from Interface tables to OSS functional Tables. */

PROCEDURE Insert_ACT_to_Interface (
                  ERRBUF             OUT NOCOPY VARCHAR2,
		  RETCODE            OUT NOCOPY NUMBER,
		  p_ACT_Batch_Id     IN IGS_AD_ACT_ASSESSMENTS.ACT_BATCH_ID%type,
		  p_Source_Type_Id   IN NUMBER,
                  p_Match_Set_Id     IN NUMBER,
		  p_Reporting_Year   IN IGS_AD_ACT_ASSESSMENTS.REPORTING_YEAR%type,
                  p_Test_Type        IN IGS_AD_ACT_ASSESSMENTS.TEST_TYPE%type,
		  p_Test_Date        IN IGS_AD_ACT_ASSESSMENTS.TEST_DATE_TXT%type,
		  p_ACT_Id           IN IGS_AD_ACT_ASSESSMENTS.act_identifier%type,
          P_ADDR_USAGE_CD    IN IGS_AD_ADDRUSAGE_INT_ALL.SITE_USE_CODE%type)

          AS

/*----------------------------------------------------------------------------------
  ||  Created By : stammine
  ||  Created On : 09-Nov-2004
  ||  Purpose : This procedure Loads the data into Ad Interface tables from ACT Data Store
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||--------------------------------------------------------------------------------*/


-- Cusrsor to select the ACT Assessment Recrod
CURSOR c_Act_Assessment ( cp_ACT_Batch_Id IGS_AD_ACT_ASSESSMENTS.ACT_BATCH_ID%type,
		  cp_Reporting_Year IGS_AD_ACT_ASSESSMENTS.REPORTING_YEAR%type,
                  cp_Test_Type IGS_AD_ACT_ASSESSMENTS.TEST_TYPE%type,
		  cp_Test_Date IGS_AD_ACT_ASSESSMENTS.TEST_DATE_TXT%type,
		  cp_ACT_Id    IGS_AD_ACT_ASSESSMENTS.act_identifier%type) IS
SELECT
    actas.ROWID, actas.*,cc.code_id
FROM IGS_AD_ACT_ASSESSMENTS actas,
     IGS_AD_CODE_CLASSES cc
WHERE actas.ACT_Batch_ID = cp_ACT_Batch_Id
    AND actas.Reporting_Year like nvl(cp_Reporting_Year,'%')
    AND actas.Test_Type like nvl(cp_Test_Type,'%')
    AND actas.TEST_DATE_TXT like nvl(cp_Test_Date,'%')
    AND actas.ACT_Identifier like nvl(cp_ACT_Id,'%')
    AND actas.Interface_Transfer_Date IS NULL
    AND cc.name (+) = actas.grade_level
    AND cc.class (+) = 'LEVEL_OF_QUAL'
    AND cc.closed_ind (+) = 'N'
    AND cc.class_type_code (+)='ADM_CODE_CLASSES'
ORDER BY actas.act_identifier,
    actas.TEST_DATE_TXT DESC,
    actas.High_School_Code,
    actas.High_School_Graduation;


-- Cursor to select the Test Segnemt Id from IGS_AD_TEST_SEGMENTS
    CURSOR c_test_segment_id (cp_admission_test_type IGS_AD_TEST_SEGMENTS.ADMISSION_TEST_TYPE%type,
                              cp_test_segment_name IGS_AD_TEST_SEGMENTS.TEST_SEGMENT_NAME%type,
    			      cp_segment_type IGS_AD_TEST_SEGMENTS.SEGMENT_TYPE%type) IS
    SELECT
        TEST_SEGMENT_ID
    FROM IGS_AD_TEST_SEGMENTS
    WHERE ADMISSION_TEST_TYPE = cp_admission_test_type
        AND UPPER(trim(TEST_SEGMENT_NAME)) = UPPER(trim(cp_test_segment_name))
        AND SEGMENT_TYPE = cp_segment_type;

 -- Cusror to select the Statistic Category Description from Lookups.
   CURSOR c_statistic_category_desc (cp_Statistic_category igs_lookup_values.LOOKUP_CODE%type) IS
    SELECT
       Description
     FROM IGS_LOOKUP_VALUES
     WHERE lookup_TYPE = 'ACT_STATISTIC_CATEGORY'
       AND Lookup_code = cp_Statistic_category;

-- Cusrsor to select the ACT Statistics Recrods for Test and Sub Test Statistic Types
   CURSOR c_Act_Statistic_Test (
		     cp_reporting_year IGS_AD_ACT_ASSESSMENTS.REPORTING_YEAR%type,
    		     cp_test_type IGS_AD_ACT_ASSESSMENTS.TEST_TYPE%type,
		     cp_test_date IGS_AD_ACT_ASSESSMENTS.TEST_DATE_TXT%type,
                     cp_act_id IGS_AD_ACT_ASSESSMENTS.act_identifier%type) IS
    SELECT
        *
    FROM IGS_AD_ACT_STATISTICS
    WHERE REPORTING_YEAR = cp_reporting_year
        AND TEST_TYPE = cp_test_type
        AND TEST_DATE_TXT = cp_test_date
        AND ACT_Identifier = cp_act_id
        AND STATISTIC_TYPE IN ('TEST','TEST_SUB_SCORE')
	AND STATISTIC_CATEGORY IN ('COMENGWRI','COMPOSITE','ENGLISH','MATHS','READING','SCIENCE','ALGCOGEOM',
'ARTSLIT','ELEMALG','PLGEOTRIG','RHESKILLS','SOCSTSCI' ,'USAGMECH' ,'WRITING')
	AND trim(SCORE) <> '--';


-- Cusrsor to select the ACT Statistics Recrods for 'HIGH_SCHOOL' Statistic Types
   CURSOR c_Act_Statistic_High_School (cp_reporting_year IGS_AD_ACT_ASSESSMENTS.REPORTING_YEAR%type,
    		     cp_test_type IGS_AD_ACT_ASSESSMENTS.TEST_TYPE%type,
		     cp_test_date IGS_AD_ACT_ASSESSMENTS.TEST_DATE_TXT%type,
                     cp_act_id IGS_AD_ACT_ASSESSMENTS.act_identifier%type) IS
    SELECT
        *
    FROM IGS_AD_ACT_STATISTICS
    WHERE REPORTING_YEAR = cp_reporting_year
        AND TEST_TYPE = cp_test_type
        AND TEST_DATE_TXT = cp_test_date
        AND ACT_Identifier = cp_act_id
        AND STATISTIC_TYPE = 'HIGH_SCHOOL'
	AND (COURSE_STATUS IN ('1','2') OR COURSE_STATUS IS NULL); -- exam taken(1) or Planned(2) or Numeric Grades


l_Batch_Id                 igs_ad_imp_batch_det.batch_id%type;
l_Batch_Desc               igs_ad_imp_batch_det.batch_desc%type;
l_interface_id             igs_ad_interface_all.interface_id%type;
l_interface_addr_id        igs_ad_addr_int_all.interface_addr_id%type;
l_interface_test_id        igs_ad_test_int.interface_test_id%type;
l_admission_test_type      igs_ad_test_int.admission_test_type%type;
l_interface_acadhis_id     igs_ad_acadhis_int_all.interface_acadhis_id%type;
l_Interface_Transcript_Id  igs_ad_txcpt_int.interface_transcript_id%type;
l_interface_term_dtls_id   igs_ad_trmdt_int.interface_term_dtls_id%type;

l_ACT_Exist                igs_Ad_Act_Assessments.act_identifier%type;
l_rec_count                NUMBER;
l_rec_fail_count           NUMBER;
l_ERRBUF                   VARCHAR2(1000);
l_RETCODE                  NUMBER;
l_Interface_Id_exist       igs_ad_interface_all.Interface_Id%type;
l_High_School_Code         igs_Ad_Act_Assessments.High_School_Code%type;
l_High_School_Graduation   igs_Ad_Act_Assessments.High_School_Graduation%type;

l_test_segment_id	   igs_ad_test_segs_int.test_segment_id%type;
l_test_score               igs_ad_test_segs_int.test_score%type;
l_national_percentile      igs_ad_act_statistics.national_norm%type;
l_state_percentile         igs_ad_act_statistics.local_norm%type;
l_score_band_upper         igs_ad_test_segs_int.score_band_upper%type;
l_score_band_lower         igs_ad_test_segs_int.score_band_lower%type;
l_grade                    VARCHAR2(10);
l_Statistic_Category_desc  igs_lookup_values.MEANING%type;

BEGIN /* Main */

   -- The following code is added for disabling of OSS in R12.IGS.A - Bug 4955192
   igs_ge_gen_003.set_org_id(null);

   FND_MESSAGE.SET_NAME('IGS','IGS_AD_ACT_IMPORT');
   FND_MESSAGE.SET_TOKEN('ACT_BATCH_ID', p_ACT_Batch_Id);
   FND_FILE.PUT_LINE(Fnd_File.LOG,FND_MESSAGE.GET);
   FND_FILE.PUT_LINE(Fnd_File.LOG,'Source Type ID : '|| p_Source_Type_Id||'      MatchSet Id : '  ||p_Match_Set_Id);
   FND_FILE.PUT_LINE(Fnd_File.LOG,'Reporting Year : '|| p_Reporting_Year||'      Test Type   : '  ||p_Test_Type);
   FND_FILE.PUT_LINE(Fnd_File.LOG,'Test_Date      : '|| p_Test_Date||'      ACT_Id   : '  ||p_ACT_Id);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '---------------------------------------------------------------------------------------');

    retcode := 0;
    errbuf  := NULL;
    retcode := Check_Setups(p_ACT_Batch_Id,
		  p_Reporting_Year, p_Test_Type,
		  p_Test_Date,p_ACT_Id);
    IF retcode = 1 THEN
     errbuf := 'INVALID SETUP';
     retcode := 0;
     RETURN;
    END IF;
 -- Insert the Batch_id in to the Batch Table IGS_AD_IMP_BATCH_DET for Import Process


  l_Batch_Desc := 'Import ACT Assessment Details :'||to_char(sysdate,'MM-DD-YY HH24:MI:SS');
  INSERT
  INTO IGS_AD_IMP_BATCH_DET
      (
          BATCH_ID ,
          BATCH_DESC ,
          CREATED_BY ,
          CREATION_DATE ,
          LAST_UPDATED_BY ,
          LAST_UPDATE_DATE ,
          LAST_UPDATE_LOGIN
      )
      VALUES
      (
          IGS_AD_INTERFACE_BATCH_ID_S.NEXTVAL,
          l_Batch_Desc,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.LOGIN_ID
      ) returning BATCH_ID into l_Batch_Id
      ;
      commit;
   FND_FILE.PUT_LINE(FND_FILE.LOG, '----------------------------------------------------------------------------------');
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Created a Bacth Record with following details :');
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch ID : ' || l_Batch_Id || '     Batch Description : '||l_Batch_Desc);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '-----------------------------------------------------------------------------------');


  BEGIN -- Loading the Data to Interface Tables.

  /*---------------------------------------------------------------------------------------------------------
    Loading the Data into Interface Tables in the Following Hierarchy:
        IGS_AD_INTERFACE_ALL
            --> IGS_AD_ADDR_INT_ALL
            ------> IGS_AD_ADDRUSAGE_INT_ALL -- akadam Bug# 4352471
            --> IGS_AD_CONTACTS_INT_ALL
            --> IGS_AD_API_INT_ALL
            --> IGS_AD_TEST_INT
            ------> IGS_AD_TEST_SEGS_INT
            --> IGS_AD_ACADHIS_INT_ALL
            ------> IGS_AD_TXCPT_INT_ALL
            ------------> IGS_AD_TRMDT_INT
            ------------------> IGS_AD_TUNDT_INT
  ---------------------------------------------------------------------------------------------------------*/

  -- flag to check if Latest Person Details is already inserted into Interface table or Not
  l_interface_addr_id := NULL;
  l_ACT_Exist := NULL;
  -- flags to check if Academic History Record is already inserted into Interface table or Not
  l_Interface_Id_exist := NULL;
  l_High_School_Code := NULL;
  l_High_School_Graduation := NULL;


  -- Record count to commit after every 100 Records and used to count Total Transactions Processed.
  l_rec_count := 0;

  -- Count Failure Transactions
  l_rec_fail_count:=0;

  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Loading the values into Interface tables from the ACT Data Store');

  FOR Act_Assessment_rec IN c_Act_Assessment( p_ACT_Batch_Id ,p_Reporting_Year,
                    p_Test_Type , p_Test_Date , p_ACT_Id  )
  LOOP
    BEGIN

      SAVEPOINT  Transact_spoint;  -- Save Point at the start of the transaction,
                                   -- is used to Rollback complete transaction for any failure in the transaction

--debug
--	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside for loop : l_ACT_Exist ' || l_ACT_Exist);

       -- Insert Person Details of Latest Record
      IF ((l_ACT_Exist IS NULL ) OR ( l_ACT_Exist <> Act_Assessment_rec.act_identifier))
      THEN

      --debug
--	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside IF of  loop : l_ACT Exist ' || l_ACT_Exist);

       -- Inserting the Latest Record in to the Main Interface Table (IGS_AD_INTERFACE_ALL)
        INSERT
        INTO IGS_AD_INTERFACE_ALL
            (
                INTERFACE_ID ,
                BATCH_ID ,
                SOURCE_TYPE_ID ,
                SURNAME ,
                MIDDLE_NAME ,
                GIVEN_NAMES ,
                SEX ,
                BIRTH_DT ,
                LEVEL_OF_QUAL ,
                STATUS ,
                RECORD_STATUS ,
                CREATED_BY ,
                CREATION_DATE ,
                LAST_UPDATED_BY ,
                LAST_UPDATE_DATE ,
                LAST_UPDATE_LOGIN
            )
            VALUES
            (
                IGS_AD_INTERFACE_S.NEXTVAL,
                l_Batch_id,
                p_Source_Type_Id,
                Act_Assessment_rec.last_name,
                Act_Assessment_rec.middle_initial,
                Act_Assessment_rec.first_name,
                Decode(upper(Act_Assessment_rec.gender),'M','MALE','F','FEMALE','UNKNOWN'),
                to_date(Act_Assessment_rec.date_of_birth_txt,'YYYYMMDD'),
		Act_Assessment_rec.code_id,  -- Grade level need to be defined  in IGS_AD_CODE_CLASSES
		                         --WHERE CLASS ='LEVEL_OF_QUAL' code_id is retrieved from the code_classes table
		'2',
                '2',
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.LOGIN_ID
            ) returning INTERFACE_ID into l_interface_id;

	--debug
--	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Interface Id : 1' || l_interface_id);

        -- Inserting the Latest Record in to the Child (IGS_AD_ADDR_INT_ALL) of Interface Table (IGS_AD_INTERFACE_ALL).
        INSERT
        INTO IGS_AD_ADDR_INT_ALL
            (
                INTERFACE_ADDR_ID,
                INTERFACE_ID ,
                ADDR_LINE_1 ,
                POSTCODE ,
                CITY ,
                STATE ,
		--COUNTY, -- temp
                COUNTRY ,
                START_DATE ,
                STATUS ,
                CREATED_BY ,
                CREATION_DATE ,
                LAST_UPDATED_BY ,
                LAST_UPDATE_DATE ,
                LAST_UPDATE_LOGIN
            )
            VALUES
            (
                IGS_AD_ADDR_INT_S.NEXTVAL,
                l_interface_id,
                Act_Assessment_rec.street_address,
                Act_Assessment_rec.zip_code,
                Act_Assessment_rec.city,  --'ALBANY',
                Act_Assessment_rec.state_abbreviation, --'NY',
		--'ALBANY', --temp
                'US',
                SYSDATE,
                '2',
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.LOGIN_ID
            )returning INTERFACE_ADDR_ID into l_interface_addr_id;

         -- akadam Included the below logic for Bug# 4352471
         --Inserting the Latest Record in to the Child (IGS_AD_ADDRUSAGE_INT_ALL) of Interface Table (IGS_AD_ADDR_INT_ALL).

         IF P_ADDR_USAGE_CD  IS NOT NULL THEN
             INSERT INTO igs_ad_addrusage_int_all (
             interface_addrusage_id,
             interface_addr_id,
             site_use_code,
             status,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login
             )
             VALUES
             (
             igs_ad_addrusage_int_s.NEXTVAL,
             l_interface_addr_id,  -- interfaced Id populated in igs_ad_addr_int_all.
             p_addr_usage_cd,
             '2',
             fnd_global.user_id,
             sysdate,
             fnd_global.user_id,
             sysdate,
             fnd_global.login_id
         );
         END IF;


        -- Inserting the Latest Record in to the Child (IGS_AD_CONTACTS_INT_ALL) of Interface Table (IGS_AD_INTERFACE_ALL).
       IF (LENGTH(RTRIM(LTRIM(Act_Assessment_rec.home_phone,' '),' ')) = 10) THEN
            INSERT
            INTO IGS_AD_CONTACTS_INT_ALL
            (
                     INTERFACE_CONTACTS_ID ,
                     INTERFACE_ID  ,
                     CONTACT_POINT_TYPE ,
                     PHONE_LINE_TYPE ,
                     PHONE_AREA_CODE ,
                     PHONE_NUMBER ,
                     STATUS ,
                     CREATED_BY ,
                     CREATION_DATE ,
                     LAST_UPDATED_BY ,
                     LAST_UPDATE_DATE ,
                     LAST_UPDATE_LOGIN
             )
             VALUES
             (
                     IGS_AD_CONTACTS_INT_S.NEXTVAL,
                     l_interface_id,
                     'PHONE', -- COMMUNICATION_TYPE
                     'GEN' ,-- Telephone PHONE_LINE_TYPE
                     SUBSTR(Act_Assessment_rec.home_phone,1,3),
                     SUBSTR(Act_Assessment_rec.home_phone,4,7),
                     '2',
                     FND_GLOBAL.USER_ID,
                     SYSDATE,
                     FND_GLOBAL.USER_ID,
                     SYSDATE,
                     FND_GLOBAL.LOGIN_ID
             );
        ELSE
             IF (Act_Assessment_rec.home_phone IS NOT NULL) THEN
               INSERT
               INTO IGS_AD_CONTACTS_INT_ALL
                 (
                     INTERFACE_CONTACTS_ID ,
                     INTERFACE_ID ,
                     CONTACT_POINT_TYPE ,
                     PHONE_LINE_TYPE ,
                     PHONE_NUMBER ,
                     STATUS ,
                     CREATED_BY ,
                     CREATION_DATE ,
                     LAST_UPDATED_BY ,
                     LAST_UPDATE_DATE ,
                     LAST_UPDATE_LOGIN
                 )
                 VALUES
                 (
                     IGS_AD_CONTACTS_INT_S.NEXTVAL,
                     l_interface_id,
                     'PHONE', -- COMMUNICATION_TYPE
                     'GEN' ,-- Telephone PHONE_LINE_TYPE
                     Act_Assessment_rec.home_phone,
                     '2',
                     FND_GLOBAL.USER_ID,
                     SYSDATE,
                     FND_GLOBAL.USER_ID,
                     SYSDATE,
                     FND_GLOBAL.LOGIN_ID
                 );
            END IF;
        END IF;
        -- Check if the ALTERNATE_ID is SSN or -ACTID
        -- IF ALTERNATE_ID is SSN Then Add the two records. 1 with SSN person_id_type and other with ACT person_id_type

        IF (SUBSTR(Act_Assessment_rec.act_identifier,1,1) <> '-') THEN
          -- Inserting SSN Person_id_type
          INSERT
          INTO IGS_AD_API_INT_ALL
              (
                  INTERFACE_API_ID ,
                  INTERFACE_ID ,
                  PERSON_ID_TYPE ,
                  ALTERNATE_ID ,
                  STATUS ,
                  CREATED_BY ,
                  CREATION_DATE ,
                  LAST_UPDATED_BY ,
                  LAST_UPDATE_DATE ,
                  LAST_UPDATE_LOGIN
              )
              VALUES
              (
                  IGS_AD_API_INT_S.nextval,
                  l_interface_id,
                  G_SSN_Person_Id_Type,   -- 'SSN', -- {get the person_type having the System Person Type  = SSN}
                  Act_Assessment_rec.act_identifier,
                  '2',
                  FND_GLOBAL.USER_ID,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  SYSDATE,
                  FND_GLOBAL.LOGIN_ID
              );
         END IF;

--debug
--	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Interface Id : 2 ' || l_interface_id);

           -- Inserting ACT Person_id_type
         INSERT
          INTO IGS_AD_API_INT_ALL
              (
                  INTERFACE_API_ID ,
                  INTERFACE_ID ,
                  PERSON_ID_TYPE ,
                  ALTERNATE_ID ,
                  STATUS ,
                  CREATED_BY ,
                  CREATION_DATE ,
                  LAST_UPDATED_BY ,
                  LAST_UPDATE_DATE ,
                  LAST_UPDATE_LOGIN
              )
              VALUES
              (
                  IGS_AD_API_INT_S.nextval,
                  l_interface_id,
                  G_ACT_Person_Id_Type,   -- 'ACTID',     -- {get the person_type having the System Person Type  = ACT}
                  SUBSTR(Act_Assessment_rec.act_identifier,(Decode(SUBSTR(Act_Assessment_rec.act_identifier,1,1),'-',2,1))),
                  '2',
                  FND_GLOBAL.USER_ID,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  SYSDATE,
                  FND_GLOBAL.LOGIN_ID
              );

        l_ACT_Exist := Act_Assessment_rec.act_identifier;

      END IF; -- End Insert Most Recent Person Details

     -- Loading Test Detials in to Interface Tables.
     -- Multiple Records
     -- For each Test Type :
--debug
--	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Interface Id 3: ' || l_interface_id);
     INSERT
     INTO IGS_AD_TEST_INT
        (
            INTERFACE_TEST_ID ,
            INTERFACE_ID ,
            ADMISSION_TEST_TYPE ,
            TEST_DATE ,
            SCORE_TYPE ,
            SCORE_SOURCE_ID ,
	    SCORE_REPORT_DATE ,
            SPECIAL_CODE ,
            STATUS ,
            CREATED_BY ,
            CREATION_DATE ,
            LAST_UPDATED_BY ,
            LAST_UPDATE_DATE ,
            LAST_UPDATE_LOGIN,
	    ACTIVE_IND
        )
        VALUES
        (
            IGS_AD_TEST_INT_S.NEXTVAL,
            l_interface_id,
            Decode (Act_Assessment_rec.test_type,'D','ACT-DANTES','F','ACT-INTERNATIONAL','I',
    	        'ACT-INSTITUTION','R','ACT-RESIDUAL','S','ACT-STATE','Z','ACT-ARRANGED','N','ACT-NATIONAL'),
    	    to_date( Act_Assessment_rec.test_date_txt||'01','YYYYMMDD'),
            'OFFICIAL',
    	    G_Score_Source_id,
	    SYSDATE,
            Act_Assessment_rec.corrected_report_ind, -- if the data is ' ' in Data file value in the Assessments table is NULL
            '2',
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.LOGIN_ID,
	    'Y'
        ) returning INTERFACE_TEST_ID,ADMISSION_TEST_TYPE into l_interface_test_id,l_admission_test_type;

      -- Enter Test Details into IGS_AD_TEST_SEGS_INT from ACT Statistics
      -- For Inserting multiple records of Test Details for a Person for each Test Type

        FOR Act_Statistic_Rec IN  c_Act_Statistic_Test (Act_Assessment_rec.reporting_year,
                             Act_Assessment_rec.test_type,
        		     Act_Assessment_rec.TEST_DATE_TXT,
			     Act_Assessment_rec.act_identifier)
        LOOP


--debug
--	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside for of Statistic record Interface Id 4: ' || l_interface_id);
--      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside for of Statistic record l_admission_test_type  ' || l_admission_test_type);
--	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside for of Statistic record Act_Statistic_rec.statistic_category  ' || Act_Statistic_rec.statistic_category );
--	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside for of Statistic record Act_Statistic_rec.statistic_type ' || Act_Statistic_rec.statistic_type);
--      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside for of Statistic record get_lookup_meaning() ' || get_lookup_meaning(Act_Statistic_rec.statistic_category));

        l_test_segment_id := NULL;
        l_test_score := NULL;
        l_national_percentile := NULL;
        l_state_percentile := NULL;
        l_score_band_upper := NULL;
        l_score_band_lower := NULL;


     /* -- { Case 1 }
        -- STATISTIC_TYPE = 'Test' and STATISTIC_CATEGORY = 'Combined English/Writing'
        -- IF ACT_STATISTIC.SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'Combined English/Writing'  Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID

        -- { Case 2 }
        -- STATISTIC_TYPE = 'Test' and STATISTIC_CATEGORY = 'Composite'
        -- IF ACT_STATISTIC. SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'Composite'  Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID

        -- { Case 3 }
        -- STATISTIC_TYPE = 'Test' and STATISTIC_CATEGORY = 'English'
        -- IF ACT_STATISTIC.SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'English'     Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID


        -- { Case 4 }
        -- STATISTIC_TYPE = 'Test' and STATISTIC_CATEGORY = 'Mathematics'
        -- IF ACT_STATISTIC.SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'Mathematics'     Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID

        -- { Case 5 }
        -- STATISTIC_TYPE = 'Test' and STATISTIC_CATEGORY = 'Reading'
        -- IF ACT_STATISTIC.SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'Reading'     Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID

        -- { Case 6 }
        -- STATISTIC_TYPE = 'Test' and STATISTIC_CATEGORY = 'Science'
        -- IF ACT_STATISTIC.SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'Science'     Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID */

	IF  Act_Statistic_rec.statistic_type = 'TEST' AND Act_Statistic_rec.statistic_category IN ('COMENGWRI','COMPOSITE','ENGLISH',
	                  'MATHS','READING','SCIENCE') THEN
             FOR test_segment_rec IN c_test_segment_id(l_admission_test_type,get_lookup_meaning(Act_Statistic_rec.statistic_category),'SCORE')
        	LOOP
        	 l_test_score := Act_Statistic_rec.score;
        	 l_national_percentile := Act_Statistic_rec.national_norm;
                 l_state_percentile := NULL;
        	 l_score_band_upper := 36;
                 l_score_band_lower := 1;
		 l_test_segment_id:=test_segment_rec.TEST_SEGMENT_ID;
    	        END LOOP;


     /* -- { Case 7 }
        -- STATISTIC_TYPE = 'TEST_SUB_SCORE' and STATISTIC_CATEGORY = 'Alg/Cord Geom'
        -- IF ACT_STATISTIC.SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'Alg/Cord Geom'     Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID

        -- { Case 8 }
        -- STATISTIC_TYPE = 'TEST_SUB_SCORE' and STATISTIC_CATEGORY = 'Arts/Lit.'
        -- IF ACT_STATISTIC.SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'Arts/Lit.'     Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID

        -- { Case 9 }
        -- STATISTIC_TYPE = 'TEST_SUB_SCORE' and STATISTIC_CATEGORY = 'Elem Algebra.'
        -- IF ACT_STATISTIC.SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'Elem Algebra.'     Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID

        -- { Case 10 }
        -- STATISTIC_TYPE = 'TEST_SUB_SCORE' and STATISTIC_CATEGORY = 'Plane Geom/Trig.'
        -- IF ACT_STATISTIC.SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'Plane Geom/Trig'     Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID

        -- { Case 11 }
        -- STATISTIC_TYPE = 'TEST_SUB_SCORE' and STATISTIC_CATEGORY = 'Rhetorical Skills.'
        -- IF ACT_STATISTIC.SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'Rhetorical Skills'     Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID

        -- { Case 12 }
        -- STATISTIC_TYPE = 'TEST_SUB_SCORE' and STATISTIC_CATEGORY = 'Soc Stud/Sci.'
        -- IF ACT_STATISTIC.SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'Soc Stud/Sci'     Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID

        -- { Case 13 }
        -- STATISTIC_TYPE = 'TEST_SUB_SCORE' and STATISTIC_CATEGORY = 'Usage/Mech.'
        -- IF ACT_STATISTIC.SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'Usage/Mech'     Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID */

        ELSIF Act_Statistic_rec.statistic_type = 'TEST_SUB_SCORE' AND Act_Statistic_rec.statistic_category IN ('ALGCOGEOM',
                          'ARTSLIT','ELEMALG','PLGEOTRIG','RHESKILLS','SOCSTSCI' ,'USAGMECH')  THEN
             FOR test_segment_rec IN c_test_segment_id(l_admission_test_type,get_lookup_meaning(Act_Statistic_rec.statistic_category),'SUB SCORE')
        	LOOP
        	 l_test_score := Act_Statistic_rec.score;
        	 l_national_percentile := Act_Statistic_rec.national_norm;
                 l_state_percentile := Act_Statistic_rec.local_norm;
        	 l_score_band_upper := 18;
                 l_score_band_lower := 1;
		 l_test_segment_id:=test_segment_rec.TEST_SEGMENT_ID;
    	        END LOOP;

        -- { Case 14 }
        -- STATISTIC_TYPE = 'TEST_SUB_SCORE' and STATISTIC_CATEGORY = 'Writing.'
        -- IF ACT_STATISTIC.SCORE <> '-'
        -- Select TEST_SEGMENT_ID From IGS_AD_TEST_SEGMENTS Where ADMISSION_TEST_TYPE = IGS_AD_TEST_INT. ADMISSION_TEST_TYPE
        -- and TEST_SEGMENT_NAME = 'Writing'     Set to IGS_AD_TEST_SEGMENTS. TEST_SEGMENT_ID

        ELSIF Act_Statistic_rec.statistic_type = 'TEST_SUB_SCORE' AND Act_Statistic_rec.statistic_category = 'WRITING' THEN
             for test_segment_rec IN c_test_segment_id(l_admission_test_type,get_lookup_meaning('WRITING'),'SUB SCORE')
        	 LOOP
        	 l_test_score := Act_Statistic_rec.score;
        	 l_national_percentile := Act_Statistic_rec.national_norm;
                 l_state_percentile := NULL;
        	 l_score_band_upper := 12;
                 l_score_band_lower := 2;
		 l_test_segment_id:=test_segment_rec.TEST_SEGMENT_ID;
    	        END LOOP;
        END IF;

        INSERT
        INTO IGS_AD_TEST_SEGS_INT
            (
                INTERFACE_TESTSEGS_ID ,
                INTERFACE_TEST_ID ,
                ADMISSION_TEST_TYPE ,
                TEST_SEGMENT_ID ,
                TEST_SCORE ,
                NATIONAL_PERCENTILE ,
                STATE_PERCENTILE ,
                SCORE_BAND_UPPER ,
                SCORE_BAND_LOWER ,
                STATUS ,
                CREATED_BY ,
                CREATION_DATE ,
                LAST_UPDATED_BY ,
                LAST_UPDATE_DATE ,
                LAST_UPDATE_LOGIN
            )
            VALUES
            (
                IGS_AD_TEST_SEGS_INT_S.NEXTVAL,
                l_interface_test_id,
                l_admission_test_type,
                l_test_segment_id,
                l_test_score,
                DECODE(INSTR(l_national_percentile,'-'),0,to_number(l_national_percentile),NULL),  --l_national_percentile bug#4693325
                DECODE(INSTR(l_state_percentile,'-'),0,to_number(l_state_percentile),NULL),        --l_state_percentile
                l_score_band_upper,
                l_score_band_lower,
                '2',
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.LOGIN_ID
            );

      END LOOP;	--- End Inserting multiple records of Test Details for a Person

    -- Enter Acad History  Details into IGS_AD_ACADHIS_INT_ALL from ACT Statistics
  IF Act_Assessment_Rec.high_school_code IS NULL THEN
        FND_FILE.PUT_LINE(Fnd_File.LOG,'Academic History for the follwing Records will not be imported as High School Graduation Institution Code is not defined.');
        FND_FILE.PUT_LINE(Fnd_File.LOG,'ACT_ID : '|| Act_Assessment_Rec.ACT_Identifier ||' REPORTING_YEAR :'|| Act_Assessment_Rec.Reporting_Year||' TEST_DATE : '||Act_Assessment_Rec.Test_Date_Txt||' TEST_TYPE : '||Act_Assessment_Rec.Test_Type);
  ELSE
    IF (((l_Interface_Id_exist IS NULL ) OR ( l_Interface_Id_exist <> l_interface_id)) OR NOT
      (( l_High_School_Code = Act_Assessment_Rec.high_school_code)
      AND( l_High_School_Graduation = Act_Assessment_Rec.high_school_graduation))) THEN

--debug
--	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside IF of Acad History Details record Interface Id 5: ' || l_interface_id);

      INSERT
      INTO IGS_AD_ACADHIS_INT_ALL
        (
            INTERFACE_ACADHIS_ID ,
            INTERFACE_ID ,
            INSTITUTION_CODE ,
            CURRENT_INST ,
            PLANNED_COMPLETION_DATE ,
            SELFREP_INST_GPA ,
            STATUS ,
            CREATED_BY ,
            CREATION_DATE ,
            LAST_UPDATED_BY ,
            LAST_UPDATE_DATE ,
            LAST_UPDATE_LOGIN
        )
        VALUES
        (
            IGS_AD_ACADHIS_INT_S.NEXTVAL,
            l_interface_id,
            Act_Assessment_Rec.high_school_code,
            'N',
            DECODE(Act_Assessment_Rec.high_school_graduation,'',NULL,to_date(Act_Assessment_Rec.high_school_graduation||'0501','YYYYMMDD')),
                                                          	    -- changed planned completion date from 01-jan to 01-may bug# 4252413
            DECODE(INSTR(Act_Assessment_Rec.high_school_average,'-'),0,Act_Assessment_Rec.high_school_average,NULL),
            '2',
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.LOGIN_ID
        ) returning INTERFACE_ACADHIS_ID into l_interface_acadhis_id;

    l_High_School_Code := Act_Assessment_Rec.high_school_code;
    l_High_School_Graduation := Act_Assessment_Rec.high_school_graduation;
    l_Interface_Id_exist := l_interface_id;
    -- Insert data into detail tables
    -- in following Hierarchy
    -- Setup the Transcript Source User Defined Transcript Source of System Type 'ACT'
    --------> IGS_AD_TXCPT_INT_ALL
    --------------> IGS_AD_TRMDT_INT
    --------------------> IGS_AD_TUNDT_INT

    -- Enter Test Details into IGS_AD_TXCPT_INT from ACT Statistics

    --debug
--	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside IF of Acad History Details: IGS_AD_TXCPT_INT record Interface Id 5: ' || l_interface_id);

    INSERT
    INTO IGS_AD_TXCPT_INT
        (
            INTERFACE_TRANSCRIPT_ID ,
            TRANSCRIPT_STATUS ,
            TRANSCRIPT_TYPE ,
            TRANSCRIPT_SOURCE ,
            INTERFACE_ACADHIS_ID ,
            STATUS ,
            ENTERED_GS_ID ,
            CONV_GS_ID ,
            TERM_TYPE ,
            CREATED_BY ,
            CREATION_DATE ,
            LAST_UPDATED_BY ,
            LAST_UPDATE_DATE ,
            LAST_UPDATE_LOGIN ,
            DATE_OF_ISSUE
        )
        VALUES
        (
            IGS_AD_TXCPT_INT_S.NEXTVAL,
            'FINAL', -- Lookup code for lookup_type  =  TRANSCRIPT_STATUS
            'OFFICIAL', -- Lookup code for lookup_type  =  TRANSCRIPT_TYPE
            G_Transcript_Source,       --User Defined 'ACT' Transcript Info Code Class 'Transcript Source'
            l_interface_acadhis_id,
            '2',
            G_Grading_Scale, -- User Defined '4 POINT' Transcript Info Code Class 'Grading Scale Types'
            G_Grading_Scale,  -- User Defined '4 POINT' Transcript Info Code Class 'Grading Scale Types'
            'S',       -- Term Type is Defined as 'S' for Semister in lookup for TERM_TYPE
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.LOGIN_ID,
    	    to_date( Act_Assessment_rec.TEST_DATE_TXT||'01','YYYYMMDD')
        ) returning INTERFACE_TRANSCRIPT_ID into l_Interface_Transcript_Id ;

  --debug
--	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside IF of Acad History Details: IGS_AD_TRMDT_INT record Interface Id 5: ' || l_interface_id);

    INSERT
    INTO IGS_AD_TRMDT_INT
        (
            INTERFACE_TERM_DTLS_ID ,
            INTERFACE_TRANSCRIPT_ID ,
            START_DATE ,
            END_DATE ,
            TERM ,
            STATUS ,
            CREATED_BY ,
            CREATION_DATE ,
            LAST_UPDATED_BY ,
            LAST_UPDATE_DATE ,
            LAST_UPDATE_LOGIN
        )
        VALUES
        (
            igs_ad_trmdt_int_s.NEXTVAL,
            l_Interface_Transcript_Id,
            to_date( Act_Assessment_rec.TEST_DATE_TXT||'01','YYYYMMDD'),
            to_date( Act_Assessment_rec.TEST_DATE_TXT||'02','YYYYMMDD'),
            'ACT - '||to_char(to_date( Act_Assessment_rec.TEST_DATE_TXT||'01','YYYYMMDD'),'Mon DD, YYYY'),  -- 'ACT Test Date - '||to_char(to_date( Act_Assessment_rec.TEST_DATE_TXT||'01','YYYYMMDD'),'Month DD, YYYY'),
            '2',
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.LOGIN_ID
        )returning INTERFACE_TERM_DTLS_ID into l_interface_term_dtls_id;

    END IF; -- END IF of Graduation School Detials

    FOR Act_Statistic_HS_Rec IN  c_Act_Statistic_High_School
    			(Act_Assessment_rec.reporting_year,
                              Act_Assessment_rec.test_type,
        			 Act_Assessment_rec.TEST_DATE_TXT,
				 Act_Assessment_rec.act_identifier)
    LOOP
      l_grade :=NULL;

       OPEN c_Statistic_Category_desc(Act_Statistic_HS_Rec.statistic_category);
        FETCH c_Statistic_Category_desc INTO l_Statistic_Category_desc;
      CLOSE c_Statistic_Category_desc;

     --debug
--	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside FOR  of History Details: IGS_AD_TUNDT_INT record Interface Id 5: ' || l_interface_id);


     IF Act_Statistic_HS_Rec.statistic_category IN ('ENGLISH','MATHS','NATSCI','SOCSCI') THEN
         -- If Numeric Grade is 'NN'  not NULL not '--'
	 IF ((Act_Statistic_HS_Rec.Numeric_Grade IS NOT NULL) AND (INSTR(Act_Statistic_HS_Rec.Numeric_Grade,'-')=0)) THEN
          l_grade := SUBSTR(Act_Statistic_HS_Rec.Numeric_Grade,1,1)||'.'||SUBSTR(Act_Statistic_HS_Rec.Numeric_Grade,2);
	  INSERT
          INTO IGS_AD_TUNDT_INT
          (
              INTERFACE_TERM_UNITDTLS_ID ,
              INTERFACE_TERM_DTLS_ID ,
              UNIT ,
              UNIT_DIFFICULTY ,
              UNIT_NAME ,
              GRADE ,
              STATUS ,
              CREATED_BY ,
              CREATION_DATE ,
              LAST_UPDATED_BY ,
              LAST_UPDATE_DATE ,
              LAST_UPDATE_LOGIN
          )
          VALUES
          (
              IGS_AD_TUNDT_INT_S.NEXTVAL,
              l_interface_term_dtls_id,
              Act_Statistic_HS_Rec.statistic_category ,
              G_Unit_Difficulty,
              l_Statistic_Category_desc,
              l_grade,
              '2',
              FND_GLOBAL.USER_ID,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              FND_GLOBAL.LOGIN_ID
          ) ;

        END IF;
      ELSIF Act_Statistic_HS_Rec.course_status IN ('1','2') THEN
         l_grade := Act_Statistic_HS_Rec.Grade_Earned;
	 IF ((l_grade IS NULL) AND (Act_Statistic_HS_Rec.course_status = '1')) THEN
	    l_grade :='T';
         END IF;

	 INSERT
         INTO IGS_AD_TUNDT_INT
          (
              INTERFACE_TERM_UNITDTLS_ID ,
              INTERFACE_TERM_DTLS_ID ,
              UNIT ,
              UNIT_DIFFICULTY ,
              UNIT_NAME ,
              GRADE ,
              STATUS ,
              CREATED_BY ,
              CREATION_DATE ,
              LAST_UPDATED_BY ,
              LAST_UPDATE_DATE ,
              LAST_UPDATE_LOGIN
          )
          VALUES
          (
              IGS_AD_TUNDT_INT_S.NEXTVAL,
              l_interface_term_dtls_id,
              Act_Statistic_HS_Rec.statistic_category ,
              G_Unit_Difficulty,
              l_Statistic_Category_desc,
              Decode(trim(l_grade),'4','A','3','B','2','C','1','D','0','F','','P',l_grade),
              '2',
              FND_GLOBAL.USER_ID,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              FND_GLOBAL.LOGIN_ID
          ) ;

      END IF;
    END LOOP;
   END IF; -- Academic History Details
       -- Update the IGS_AD_ACT_ASSSESSMENT table Interface_Transfer_Date with Sysdate
       Update IGS_AD_ACT_ASSESSMENTS set Interface_Transfer_Date = SYSDATE where rowid = Act_Assessment_Rec.rowid;

     EXCEPTION
      WHEN OTHERS THEN
        -- Insert a log message that Person Record failed to populate into Interface Tables.

        FND_MESSAGE.SET_NAME('IGS','IGS_AD_ACT_INS_FAIL');
        FND_MESSAGE.SET_TOKEN('ACT_ID', Act_Assessment_Rec.ACT_Identifier);
        FND_MESSAGE.SET_TOKEN('REPORTING_YEAR', Act_Assessment_Rec.Reporting_Year);
        FND_MESSAGE.SET_TOKEN('TEST_DATE', Act_Assessment_Rec.Test_Date_Txt);
        FND_MESSAGE.SET_TOKEN('TEST_TYPE','  -  '|| Act_Assessment_Rec.Test_Type);
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_FILE.PUT_LINE(Fnd_File.LOG,FND_MESSAGE.GET);
        ROLLBACK TO  Transact_spoint;
        l_rec_fail_count := l_rec_fail_count + 1;
       END; -- END of Inserting a Single Transaction

       l_rec_count := l_rec_count + 1;
       IF MOD(l_rec_count,100) = 0 THEN
         COMMIT;
        END IF;

    END LOOP --END of Inserting all Person details
    COMMIT;

    END; -- END Loading the Data to Interface Tables.

   FND_FILE.PUT_LINE(FND_FILE.LOG, '---------------------------------------------------------------------------------------------------------------------------------------------------');
   FND_MESSAGE.SET_NAME('IGS','IGS_AD_ACT_COUNT');
   FND_MESSAGE.SET_TOKEN('COUNT', l_rec_count - l_rec_fail_count);
   FND_FILE.PUT_LINE(Fnd_File.LOG,FND_MESSAGE.GET);
   FND_FILE.PUT_LINE(Fnd_File.LOG,l_rec_fail_count || ' ACT records have failed to insert into the interface tables');
   FND_FILE.PUT_LINE(Fnd_File.LOG,'Total Records Processed : '||l_rec_count);
   FND_FILE.PUT_LINE(FND_FILE.LOG, '---------------------------------------------------------------------------------------------------------------------------------------------------');

   -- Call to Import Process only if any success records.
   IF ((l_rec_count - l_rec_fail_count) <> 0) THEN
    igs_ad_imp_001.imp_adm_data(
    ERRBUF  =>  l_errbuf,
    RETCODE =>  l_retcode,
    P_BATCH_ID       => l_Batch_Id,
    P_SOURCE_TYPE_ID => p_Source_Type_Id,
    P_MATCH_SET_ID   => p_Match_set_Id,
    P_LEGACY_IND     => 'N',
    P_ENABLE_LOG     => 'Y' );
   END IF;
    EXCEPTION
      WHEN OTHERS THEN
      FND_FILE.PUT_LINE(Fnd_File.LOG,' Following Error Occured during the Import Process : ');
      FND_FILE.PUT_LINE(Fnd_File.LOG,SQLERRM);
      retcode :=2;
      errbuf:=SQLERRM;

   END Insert_ACT_to_Interface;-- End of Procedure

END IGS_AD_ACT_ASSESSMENTS_PKG;

/
