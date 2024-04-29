--------------------------------------------------------
--  DDL for Package Body IGS_PRECREATE_APPL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PRECREATE_APPL_PUB" AS
/* $Header: IGSPSAPB.pls 120.3 2006/05/25 06:19:40 arvsrini noship $ */
G_PKG_NAME 	CONSTANT VARCHAR2 (30):='IGS_PRECREATE_APPL_PUB';

PROCEDURE check_length(p_param_name IN VARCHAR2, p_table_name IN VARCHAR2, p_param_length IN NUMBER) AS
  CURSOR c_col_length IS
    SELECT WIDTH , precision , column_type ,scale
    FROM FND_COLUMNS
    WHERE  table_id IN
                      ( SELECT TABLE_ID
			FROM FND_TABLES
			WHERE table_name = p_table_name AND APPLICATION_ID = 8405)
      AND column_name = p_param_name
      AND APPLICATION_ID = 8405;

  l_col_length  c_col_length%ROWTYPE;

BEGIN
  OPEN 	c_col_length;
  FETCH   c_col_length INTO  l_col_length;
  CLOSE  c_col_length;
  IF l_col_length.column_type = 'V' AND p_param_length > l_col_length.width  THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_AD_EXCEED_MAX_LENGTH');
       FND_MESSAGE.SET_TOKEN('PARAMETER',p_param_name);
       FND_MESSAGE.SET_TOKEN('LENGTH',l_col_length.width);
       IGS_GE_MSG_STACK.ADD;
       RAISE FND_API.G_EXC_ERROR;
  ELSIF l_col_length.column_type ='N' AND p_param_length > (l_col_length.precision - l_col_length.scale) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_AD_EXCEED_MAX_LENGTH');
       FND_MESSAGE.SET_TOKEN('PARAMETER',p_param_name);
       IF l_col_length.scale > 0 THEN
         FND_MESSAGE.SET_TOKEN('LENGTH',l_col_length.precision || ',' || l_col_length.scale);
       ELSE
         FND_MESSAGE.SET_TOKEN('LENGTH',l_col_length.precision );
       END IF;
       IGS_GE_MSG_STACK.ADD;
       RAISE FND_API.G_EXC_ERROR;
  END IF;
END check_length;

--API
PROCEDURE PRE_CREATE_APPLICATION(
--Standard Parameters Start
                    p_api_version                 IN      NUMBER,
		    p_init_msg_list               IN	  VARCHAR2  default FND_API.G_FALSE,
		    p_commit                      IN      VARCHAR2  default FND_API.G_FALSE,
		    p_validation_level            IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,
		    x_return_status               OUT     NOCOPY    VARCHAR2,
		    x_msg_count		          OUT     NOCOPY    NUMBER,
		    x_msg_data                    OUT     NOCOPY    VARCHAR2,
--Standard parameter ends
		    p_person_id		          IN	  NUMBER,
		    p_appl_date		          IN	  DATE,
		    p_acad_cal_type	          IN	  VARCHAR2,
		    p_acad_cal_seq_number         IN	  NUMBER,
		    p_adm_cal_type		  IN   	  VARCHAR2,
		    p_adm_cal_seq_number	  IN	  NUMBER,
		    p_entry_status		  IN   	  NUMBER,
		    p_entry_level		  IN   	  NUMBER,
		    p_spcl_gr1		   	  IN	  NUMBER,
		    p_spcl_gr2		          IN 	  NUMBER,
		    p_apply_for_finaid		  IN   	  VARCHAR2,
		    p_finaid_apply_date		  IN   	  DATE,
		    p_admission_application_type  IN	  VARCHAR2,
		    p_apsource_id		  IN   	  NUMBER,
		    p_application_fee_amount	  IN	  NUMBER,
		    x_ss_adm_appl_id		  OUT 	  NOCOPY     NUMBER
)
AS
   l_api_version         CONSTANT    	NUMBER := '1.0';
   l_api_name  	    	 CONSTANT    	VARCHAR2(30) := 'PRE_CREATE_APPLICATION';
   l_msg_index                          NUMBER;
   l_return_status                      VARCHAR2(1);
   l_hash_msg_name_text_type_tab        igs_ad_gen_016.g_msg_name_text_type_table;

   -- Cursor to validate person
   CURSOR c_person(p_person_id hz_parties.party_id%TYPE) IS
   SELECT party_id
   FROM hz_parties hzp
   WHERE hzp.party_id = p_person_id;

   -- Cursor to validate Entry Status
   CURSOR c_estatus(p_estatus IGS_AD_CODE_CLASSES.code_id%TYPE) IS
   SELECT code_id
   FROM IGS_AD_CODE_CLASSES
   WHERE class = 'STATUS' AND
	 code_id = p_estatus;

   -- Cursor to validate Entry Level
   CURSOR c_elevel(p_elevel IGS_AD_CODE_CLASSES.code_id%TYPE) IS
   SELECT code_id
   FROM IGS_AD_CODE_CLASSES
   WHERE class = 'LEVEL' AND
	 code_id = p_elevel;

   -- Cursor to validate Special Group 1
   CURSOR c_spcl_grp1(p_spcl_grp1 IGS_AD_CODE_CLASSES.code_id%TYPE) IS
   SELECT code_id
   FROM IGS_AD_CODE_CLASSES
   WHERE class = 'SPECIAL_GROUP1' AND
	 code_id = p_spcl_grp1;

   -- Cursor to validate Special Group 2
   CURSOR c_spcl_grp2(p_spcl_grp2 IGS_AD_CODE_CLASSES.code_id%TYPE) IS
   SELECT code_id
   FROM IGS_AD_CODE_CLASSES
   WHERE class = 'SPECIAL_GROUP2' AND
	 code_id = p_spcl_grp2;

   -- Cursor to validate Admission Application Type
   CURSOR c_apptype(p_app_type igs_ad_ss_appl_typ.admission_application_type%TYPE) IS
   SELECT admission_application_type, admission_cat, s_admission_process_type
   FROM igs_ad_ss_appl_typ
   WHERE admission_application_type = p_app_type;

   -- Cursor to validate whether the Application Type is available in the current Admission Calendar
   CURSOR c_apptype_admcal(p_adm_cal_type IGS_AD_PRD_AD_PRC_CA.adm_cal_type%TYPE,p_adm_cal_seq IGS_AD_PRD_AD_PRC_CA.adm_ci_sequence_number%TYPE,
    p_admission_cat IGS_AD_PRD_AD_PRC_CA.admission_cat%TYPE, p_s_admission_process_type IGS_AD_PRD_AD_PRC_CA.s_admission_process_type%TYPE) IS
   SELECT adm_cal_type
   FROM IGS_AD_PRD_AD_PRC_CA
   WHERE adm_cal_type = p_adm_cal_type AND
         adm_ci_sequence_number = p_adm_cal_seq AND
	 admission_cat = p_admission_cat AND
	 s_admission_process_type = p_s_admission_process_type;

   -- Cursor to validate Application Source Id. Applicant could be either Web Applicant or Web Staff
   CURSOR c_appsource(p_app_source_id IGS_AD_CODE_CLASSES.code_id%TYPE) IS
   SELECT code_id
   FROM IGS_AD_CODE_CLASSES
   WHERE class = 'SYS_APPL_SOURCE' AND
	 code_id = p_app_source_id AND
	 SYSTEM_STATUS IN ('WEB_STAFF', 'WEB_APPL');

   -- Cursor to validate Calendars
   CURSOR c_cal(p_cal_type IGS_CA_INST.cal_type%TYPE, p_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
   SELECT cal.cal_type, cal.sequence_number,cal.description
   FROM IGS_CA_INST cal,
        igs_ca_stat cstat
   WHERE cal.cal_type = p_cal_type AND
         cal.sequence_number = p_sequence_number AND
	 end_dt > sysdate AND
	 cstat.cal_status = cal.cal_status AND
	 cstat.s_cal_status = 'ACTIVE';

   -- Cursor to validte relationship between Academic Calendar and Admission Calendar
   CURSOR c_cal_rel(p_adm_cal_type IGS_CA_INST.cal_type%TYPE, p_adm_sequence_number IGS_CA_INST.sequence_number%TYPE,p_acad_cal_type IGS_CA_INST.cal_type%TYPE, p_acad_sequence_number IGS_CA_INST.sequence_number%TYPE) IS
   SELECT ci1.CAL_TYPE
   FROM
	igs_ca_inst ci1,
	igs_ca_inst_rel cir,
	igs_ca_inst ci2,
	igs_ca_type cat1,
	igs_ca_type cat2,
	igs_ca_stat cstat
   WHERE
	ci1.CAL_TYPE = p_adm_cal_type AND
	ci1.sequence_number = p_adm_sequence_number AND
	ci2.CAL_TYPE = p_acad_cal_type AND
	ci2.sequence_number = p_acad_sequence_number AND
	cir.sub_cal_type  = ci1.CAL_TYPE AND
	cir.sub_ci_sequence_number  = ci1.sequence_number AND
	ci2.CAL_TYPE  = cir.sup_cal_type AND
	ci2.sequence_number = cir.sup_ci_sequence_number AND
	cat1.CAL_TYPE = ci1.CAL_TYPE AND
	cat1.S_CAL_CAT = 'ADMISSION' AND
	cat2.CAL_TYPE  = ci2.CAL_TYPE AND
	cat2.S_CAL_CAT = 'ACADEMIC' AND
	ci2.end_dt > sysdate AND
	ci1.end_dt  > sysdate AND
	cstat.cal_status = ci1.cal_status AND
	cstat.cal_status = ci2.cal_status  AND
	cstat.s_cal_status = 'ACTIVE';

   -- Cursor to find out if Late Applications are allowed
   CURSOR c_late_app(p_admission_cat IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,p_s_adm_process_type IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
   SELECT S_ADMISSION_STEP_TYPE
   FROM	IGS_AD_PRCS_CAT_STEP	apcs
   WHERE admission_cat = p_admission_cat AND
         s_admission_process_type = p_s_adm_process_type  AND
         s_admission_step_type = 'LATE-APP' AND
	 mandatory_step_ind = 'Y';

   l_person_rec igs_pe_hz_parties.party_id%TYPE := NULL;
   l_estatus_rec IGS_AD_CODE_CLASSES.CODE_ID%TYPE := NULL;
   l_elevel_rec IGS_AD_CODE_CLASSES.CODE_ID%TYPE := NULL;
   l_spcl_grp1_rec IGS_AD_CODE_CLASSES.CODE_ID%TYPE := NULL;
   l_spcl_grp2_rec IGS_AD_CODE_CLASSES.CODE_ID%TYPE := NULL;
   l_apptype_admcal_rec IGS_AD_PRD_AD_PRC_CA.adm_cal_type%TYPE := NULL;
   l_late_app_rec IGS_AD_PRCS_CAT_STEP.S_ADMISSION_STEP_TYPE%TYPE := NULL;
   l_appsource_rec IGS_AD_CODE_CLASSES.CODE_ID%TYPE := NULL;
   l_cal_rel_rec IGS_CA_INST.CAL_TYPE%TYPE := NULL;

   l_apptype_rec c_apptype%ROWTYPE := NULL;
   l_cal_rec c_cal%ROWTYPE := NULL;

   l_person_id IGS_SS_ADM_APPL_STG.person_id%TYPE;
   l_appl_date IGS_SS_ADM_APPL_STG.appl_date%TYPE;
   l_acad_cal_type IGS_SS_ADM_APPL_STG.acad_cal_type%TYPE;
   l_acad_cal_seq_number IGS_SS_ADM_APPL_STG.acad_cal_seq_number%TYPE;
   l_adm_cal_type IGS_SS_ADM_APPL_STG.adm_cal_type%TYPE;
   l_adm_cal_seq_number IGS_SS_ADM_APPL_STG.adm_cal_seq_number%TYPE;
   l_description IGS_SS_ADM_APPL_STG.description%TYPE;
   l_entry_status IGS_SS_ADM_APPL_STG.entry_status%TYPE;
   l_entry_level IGS_SS_ADM_APPL_STG.entry_level%TYPE;
   l_spcl_gr1 IGS_SS_ADM_APPL_STG.SPCL_GRP_1%TYPE;
   l_spcl_gr2 IGS_SS_ADM_APPL_STG.SPCL_GRP_2%TYPE;
   l_apply_for_finaid IGS_SS_ADM_APPL_STG.apply_for_finaid%TYPE;
   l_finaid_apply_date IGS_SS_ADM_APPL_STG.finaid_apply_date%TYPE;
   l_admission_application_type IGS_SS_ADM_APPL_STG.admission_application_type%TYPE;
   l_s_adm_process_type IGS_SS_ADM_APPL_STG.s_adm_process_type%TYPE;
   l_admission_cat IGS_SS_ADM_APPL_STG.admission_cat%TYPE;
   l_apsource_id IGS_SS_ADM_APPL_STG.app_source_id%TYPE;
   l_application_fee_amount IGS_SS_ADM_APPL_STG.appl_fee_amt%TYPE;
   l_ss_adm_appl_id IGS_SS_ADM_APPL_STG.ss_adm_appl_id%TYPE;
   l_message_name VARCHAR2(2000);

BEGIN
   SAVEPOINT PRE_CREATE_APPLICATION_pub;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_msg_index   := 0;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    l_msg_index := igs_ge_msg_stack.count_msg;

    -----------------------
    -- Validate all the parameters for their length
    -----------------------
    -- p_person_id
    check_length('PERSON_ID', 'IGS_SS_ADM_APPL_STG', length(TRUNC(p_person_id)));
    -- p_acad_cal_type
    check_length('ACAD_CAL_TYPE', 'IGS_SS_ADM_APPL_STG', length(p_acad_cal_type));
    -- p_acad_cal_seq_number
    check_length('ACAD_CAL_SEQ_NUMBER', 'IGS_SS_ADM_APPL_STG', length(p_acad_cal_seq_number));
    -- p_adm_cal_type
    check_length('ADM_CAL_TYPE', 'IGS_SS_ADM_APPL_STG', length(p_adm_cal_type));
    -- p_adm_cal_seq_number
    check_length('ADM_CAL_SEQ_NUMBER', 'IGS_SS_ADM_APPL_STG', length(TRUNC(p_adm_cal_seq_number)));
    -- p_entry_status
    check_length('ENTRY_STATUS', 'IGS_SS_ADM_APPL_STG', length(TRUNC(p_entry_status)));
    -- p_entry_level
    check_length('ENTRY_LEVEL', 'IGS_SS_ADM_APPL_STG', length(TRUNC(p_entry_level)));
    -- p_spcl_gr1
    check_length('SPCL_GR1', 'IGS_SS_ADM_APPL_STG', length(TRUNC(p_spcl_gr1)));
    -- p_spcl_gr2
    check_length('SPCL_GR2', 'IGS_SS_ADM_APPL_STG', length(TRUNC(p_spcl_gr2)));
    -- p_apply_for_finaid
    check_length('APPLY_FOR_FINAID', 'IGS_SS_ADM_APPL_STG', length(p_apply_for_finaid));
    -- p_admission_application_type
    check_length('ADMISSION_APPLICATION_TYPE', 'IGS_SS_ADM_APPL_STG', length(p_admission_application_type));
    -- p_apsource_id
    check_length('APSOURCE_ID', 'IGS_SS_ADM_APPL_STG', length(TRUNC(p_apsource_id)));
    -- p_application_fee_amount
    check_length('APPLICATION_FEE_AMOUNT', 'IGS_SS_ADM_APPL_STG', length(TRUNC(p_application_fee_amount)));

    -- end of parameter-lenghth validations.

    ---------------------
    --Intialization of variables to handle G_MISS_CHAR/NUM/DATE
    ---------------------

    IF  p_person_id = FND_API.G_MISS_NUM OR p_person_id IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRECREATE_PARAM_MISSING');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    ELSE
        l_person_id := p_person_id;
    END IF;

    IF  p_appl_date IS NULL OR p_appl_date = FND_API.G_MISS_DATE THEN
	l_appl_date := SYSDATE;
    ELSE
	l_appl_date := p_appl_date;
    END IF;

    IF  p_acad_cal_type = FND_API.G_MISS_CHAR OR p_acad_cal_type IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRECREATE_PARAM_MISSING');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    ELSE
        l_acad_cal_type := p_acad_cal_type;
    END IF;

    IF  p_acad_cal_seq_number = FND_API.G_MISS_NUM OR p_acad_cal_seq_number IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRECREATE_PARAM_MISSING');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    ELSE
        l_acad_cal_seq_number := p_acad_cal_seq_number;
    END IF;

    IF  p_adm_cal_type = FND_API.G_MISS_CHAR OR p_adm_cal_type IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRECREATE_PARAM_MISSING');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    ELSE
        l_adm_cal_type := p_adm_cal_type;
    END IF;

    IF  p_adm_cal_seq_number = FND_API.G_MISS_NUM OR p_adm_cal_seq_number IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRECREATE_PARAM_MISSING');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    ELSE
        l_adm_cal_seq_number :=p_adm_cal_seq_number ;
    END IF;


    IF  p_entry_status = FND_API.G_MISS_NUM THEN
	l_entry_status := NULL;
    ELSE
	l_entry_status := p_entry_status;
    END IF;

    IF  p_entry_level = FND_API.G_MISS_NUM THEN
	l_entry_level := NULL;
    ELSE
	l_entry_level := p_entry_level;
    END IF;

    IF  p_spcl_gr1 = FND_API.G_MISS_NUM THEN
	l_spcl_gr1 := NULL;
    ELSE
	l_spcl_gr1 := p_spcl_gr1;
    END IF;

    IF  p_spcl_gr2 = FND_API.G_MISS_NUM THEN
	l_spcl_gr2 := NULL;
    ELSE
	l_spcl_gr2 := p_spcl_gr2;
    END IF;

    IF  p_apply_for_finaid = FND_API.G_MISS_CHAR THEN
	l_apply_for_finaid := NULL;
    ELSE
        l_apply_for_finaid := p_apply_for_finaid;
    END IF;

    IF  p_finaid_apply_date = FND_API.G_MISS_DATE THEN
	l_finaid_apply_date := NULL;
    ELSE
        l_finaid_apply_date := p_finaid_apply_date;
    END IF;

    IF  p_admission_application_type = FND_API.G_MISS_CHAR OR p_admission_application_type IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRECREATE_PARAM_MISSING');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    ELSE
	l_admission_application_type := p_admission_application_type;
    END IF;

    IF p_apsource_id = FND_API.G_MISS_NUM OR p_apsource_id IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRECREATE_PARAM_MISSING');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    ELSE
	l_apsource_id := p_apsource_id;
    END IF;

    IF p_application_fee_amount = FND_API.G_MISS_NUM OR p_application_fee_amount IS NULL THEN
	l_application_fee_amount := 0;
    ELSE
	l_application_fee_amount := p_application_fee_amount;
    END IF;

    ---------------------------
    -- Validate the values of the parameters passed in the API
    ---------------------------


    -- Validate Application Fee Amount

    IF l_application_fee_amount < 0 THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_AD_FEE_AMT_NON_NEGATIVE');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Validate Person
    OPEN c_person(l_person_id);
    FETCH c_person INTO l_person_rec;
    CLOSE c_person;

    IF l_person_rec IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERSON_ID'));
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate Admission Calendar
    OPEN c_cal(l_adm_cal_type,l_adm_cal_seq_number);
    FETCH c_cal INTO l_cal_rec;
    CLOSE c_cal;

    IF l_cal_rec.cal_type IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
	FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_CAL'));
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- derive Admission Calendar Description
    l_description := l_cal_rec.description;

    -- Validate Academic Calendar
    l_cal_rec := NULL;
    OPEN c_cal(l_acad_cal_type,l_acad_cal_seq_number);
    FETCH c_cal INTO l_cal_rec;
    CLOSE c_cal;

    IF l_cal_rec.cal_type IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
	FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ACAD_CAL'));
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate Admission and Academic Calendar Relationship
    OPEN c_cal_rel(l_adm_cal_type,l_adm_cal_seq_number,l_acad_cal_type,l_acad_cal_seq_number);
    FETCH c_cal_rel INTO l_cal_rel_rec;
    CLOSE c_cal_rel;

    IF l_cal_rel_rec IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_AD_ADMCAL_CHILD_ACACAL');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate Entry Status
    IF l_entry_status IS NOT NULL THEN
	OPEN c_estatus(l_entry_status);
	FETCH c_estatus INTO l_estatus_rec;
	CLOSE c_estatus;

	IF l_estatus_rec IS NULL THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ENTRY_STAT'));
		IGS_GE_MSG_STACK.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    END IF;

    -- Validate Entry Level
    IF l_entry_level IS NOT NULL THEN
	OPEN c_elevel(l_entry_level);
	FETCH c_elevel INTO l_elevel_rec;
	CLOSE c_elevel;

	IF l_elevel_rec IS NULL THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ENTRY_LVL'));
		IGS_GE_MSG_STACK.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    END IF;

    -- Validate Special Group 1
    IF l_spcl_gr1 IS NOT NULL THEN
	OPEN c_spcl_grp1(l_spcl_gr1);
	FETCH c_spcl_grp1 INTO l_spcl_grp1_rec;
	CLOSE c_spcl_grp1;

	IF l_spcl_grp1_rec IS NULL THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SPL_GRP1'));
		IGS_GE_MSG_STACK.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    END IF;

    -- Validate Special Group 2
    IF l_spcl_gr2 IS NOT NULL THEN
	OPEN c_spcl_grp2(l_spcl_gr2);
	FETCH c_spcl_grp2 INTO l_spcl_grp2_rec;
	CLOSE c_spcl_grp2;

	IF l_spcl_grp2_rec IS NULL THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SPL_GRP2'));
		IGS_GE_MSG_STACK.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    END IF;

    -- Validate Admission Application Type
    OPEN c_apptype(l_admission_application_type);
    FETCH c_apptype INTO l_apptype_rec;
    CLOSE c_apptype;

    IF l_apptype_rec.admission_application_type IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
	FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_APPL_TYPE'));
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Derive ADMISSION_CAT and S_ADM_PROCESS_TYPE
    l_s_adm_process_type := l_apptype_rec.s_admission_process_type;
    l_admission_cat := l_apptype_rec.admission_cat;

    -- Validate whether the Application Type is available in the current Admission Calendar
    OPEN c_apptype_admcal(l_adm_cal_type,l_adm_cal_seq_number,l_admission_cat,l_s_adm_process_type);
    FETCH c_apptype_admcal INTO l_apptype_admcal_rec;
    CLOSE c_apptype_admcal;

    IF l_apptype_admcal_rec IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_AD_INVALID_APP_TYPE');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate Apply for Financial Aid
    IF l_apply_for_finaid IS NOT NULL THEN
	IF (NOT (l_apply_for_finaid = 'Y' OR l_apply_for_finaid = 'N')) THEN
	   FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
	   FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FIN_AID'));
	   IGS_GE_MSG_STACK.ADD;
	   RAISE FND_API.G_EXC_ERROR;
	END IF;
    END IF;

    -- Validate Financial Aid Apply Date
    IF l_apply_for_finaid IS NULL AND l_finaid_apply_date IS NOT NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_AD_FIN_DATE_FIN_AID_REQ');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate Application Date.
    -- 1. If Application Date is NULL default to SYSDATE.

    -- 2. Application Date cannot be greater than SYSDATE.
    IF l_appl_date > SYSDATE THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_APPLDT_LE_CURRENT_DT');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- 3. SYSDATE should not have passed the Application submission deadline.
    OPEN c_late_app(l_admission_cat,l_s_adm_process_type);
    FETCH c_late_app INTO l_late_app_rec;
    CLOSE c_late_app;

    IF l_late_app_rec IS NULL THEN    -- Late Applications Not Allowed
	IF NOT IGS_AD_VAL_ACAI.admp_val_acai_late (
						SYSDATE,
						NULL,		--p_course_cd,
						NULL,		--p_version_number,
						l_acad_cal_type,
						NULL,		--p_location_cd,
						NULL,		--p_attendance_mode,
						NULL,		--p_attendance_type,
						l_adm_cal_type,
						l_adm_cal_seq_number,
						l_admission_cat,
						l_s_adm_process_type,
						'N',		-- late app not allowed
						l_message_name) THEN
		-- SYSDATE has passed submission deadline
		FND_MESSAGE.SET_NAME('IGS','IGS_AD_SUB_DEADLINE');
		IGS_GE_MSG_STACK.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    ELSE  -- Late Applications Allowed
	IF NOT IGS_AD_VAL_ACAI.admp_val_acai_late (
						SYSDATE,
						NULL,		--p_course_cd,
						NULL,		--p_version_number,
						l_acad_cal_type,
						NULL,		--p_location_cd,
						NULL,		--p_attendance_mode,
						NULL,		--p_attendance_type,
						l_adm_cal_type,
						l_adm_cal_seq_number,
						l_admission_cat,
						l_s_adm_process_type,
						'Y',            -- late app allowed
						l_message_name) THEN
		-- SYSDATE has passed submission deadline
		FND_MESSAGE.SET_NAME('IGS','IGS_AD_SUB_DEADLINE');
		IGS_GE_MSG_STACK.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    END IF;

    -- Validate Application Source Id
    OPEN c_appsource(l_apsource_id);
    FETCH c_appsource INTO l_appsource_rec;
    CLOSE c_appsource;

    IF l_appsource_rec IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APP_SOURCE'));
        IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    ---------------------
    -- Insert the Application Record.
    ---------------------

    INSERT INTO IGS_SS_ADM_APPL_STG	(SS_ADM_APPL_ID,
					 PERSON_ID,
					 APPL_DATE,
					 ACAD_CAL_TYPE,
					 ACAD_CAL_SEQ_NUMBER,
					 ADM_CAL_TYPE,
					 ADM_CAL_SEQ_NUMBER,
					 ADMISSION_CAT,
					 S_ADM_PROCESS_TYPE,
					 ENTRY_STATUS,
					 ENTRY_LEVEL,
					 SPCL_GRP_1,
					 SPCL_GRP_2,
					 APPLY_FOR_FINAID,
					 FINAID_APPLY_DATE,
					 LAST_UPDATE_DATE,
					 LAST_UPDATED_BY,
					 CREATION_DATE,
					 CREATED_BY,
					 LAST_UPDATE_LOGIN,
					 ADMISSION_APPLICATION_TYPE,
					 DESCRIPTION,
					 APP_SOURCE_ID,
					 APPL_FEE_AMT)
			     VALUES    (IGS_SS_ADM_APPL_S.NEXTVAL,
					l_person_id,
					l_appl_date,
					l_acad_cal_type,
					l_acad_cal_seq_number,
					l_adm_cal_type,
					l_adm_cal_seq_number,
					l_admission_cat,
					l_s_adm_process_type,
					l_entry_status,
					l_entry_level,
					l_spcl_gr1,
					l_spcl_gr2,
					l_apply_for_finaid,
					l_finaid_apply_date,
					SYSDATE,
					FND_GLOBAL.USER_ID,
					SYSDATE,
					FND_GLOBAL.USER_ID,
					FND_GLOBAL.USER_ID,
					l_admission_application_type,
					l_description,
					l_apsource_id,
					l_application_fee_amount
					) RETURNING SS_ADM_APPL_ID INTO x_ss_adm_appl_id;

    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT;
    END IF;

   -- Exception Handling
   EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
	   ROLLBACK TO PRE_CREATE_APPLICATION_pub;
	   igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

	   IF l_hash_msg_name_text_type_tab(x_msg_count - 2).name <> 'ORA' THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	   ELSE
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           END IF;

	   x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-2).text;
	   x_msg_count := x_msg_count-1;

	WHEN OTHERS THEN
	    ROLLBACK TO PRE_CREATE_APPLICATION_pub;
            igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

	    IF l_hash_msg_name_text_type_tab(x_msg_count - 1).name <> 'ORA' THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	    ELSE
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            END IF;

            x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-1).text;

END PRE_CREATE_APPLICATION;


--API
PROCEDURE PRE_CREATE_APPLICATION_INST(
--Standard Parameters Start
			p_api_version           IN      NUMBER,
			p_init_msg_list         IN	VARCHAR2  default FND_API.G_FALSE,
			p_commit                IN      VARCHAR2  default FND_API.G_FALSE,
			p_validation_level      IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,
			x_return_status         OUT     NOCOPY    VARCHAR2,
			x_msg_count		OUT     NOCOPY    NUMBER,
			x_msg_data              OUT     NOCOPY    VARCHAR2,
--Standard parameter ends
			p_ss_adm_appl_id	IN	NUMBER,
			p_sch_apl_to_id		IN	NUMBER,
			p_location_cd		IN	VARCHAR2,
			p_attendance_type	IN	VARCHAR2,
			p_attendance_mode	IN	VARCHAR2,
			p_attribute_category	IN	VARCHAR2,
			p_attribute1		IN	VARCHAR2,
			p_attribute2		IN	VARCHAR2,
			p_attribute3		IN	VARCHAR2,
			p_attribute4		IN	VARCHAR2,
			p_attribute5		IN	VARCHAR2,
			p_attribute6		IN	VARCHAR2,
			p_attribute7		IN	VARCHAR2,
			p_attribute8		IN	VARCHAR2,
			p_attribute9		IN	VARCHAR2,
			p_attribute10		IN	VARCHAR2,
			p_attribute11		IN	VARCHAR2,
			p_attribute12		IN	VARCHAR2,
			p_attribute13		IN	VARCHAR2,
			p_attribute14		IN	VARCHAR2,
			p_attribute15		IN	VARCHAR2,
			p_attribute16		IN	VARCHAR2,
			p_attribute17		IN	VARCHAR2,
			p_attribute18		IN	VARCHAR2,
			p_attribute19		IN	VARCHAR2,
			p_attribute20		IN	VARCHAR2,
			p_attribute21		IN	VARCHAR2,
			p_attribute22		IN	VARCHAR2,
			p_attribute23		IN	VARCHAR2,
			p_attribute24		IN	VARCHAR2,
			p_attribute25		IN	VARCHAR2,
			p_attribute26		IN	VARCHAR2,
			p_attribute27		IN	VARCHAR2,
			p_attribute28		IN	VARCHAR2,
			p_attribute29		IN	VARCHAR2,
			p_attribute30		IN	VARCHAR2,
			p_attribute31		IN	VARCHAR2,
			p_attribute32		IN	VARCHAR2,
			p_attribute33		IN	VARCHAR2,
			p_attribute34		IN	VARCHAR2,
			p_attribute35		IN	VARCHAR2,
			p_attribute36		IN	VARCHAR2,
			p_attribute37		IN	VARCHAR2,
			p_attribute38		IN	VARCHAR2,
			p_attribute39		IN	VARCHAR2,
			p_attribute40		IN	VARCHAR2,
			x_ss_admappl_pgm_id     OUT     NOCOPY       NUMBER
)
AS
   l_api_version         CONSTANT    	NUMBER := '1.0';
   l_api_name  	    	 CONSTANT    	VARCHAR2(30) := 'PRE_CREATE_APPLICATION_INST';
   l_msg_index                          NUMBER;
   l_return_status                      VARCHAR2(1);
   l_hash_msg_name_text_type_tab        igs_ad_gen_016.g_msg_name_text_type_table;

/* ****************** PUT CURSOR DEFINITIONS FOR VALIDATION PURPOSE HERE ************************** */

    -- Cursor to validate Parent Application's Application Identifier
    CURSOR c_admappl(p_ss_adm_appl_id NUMBER) IS
    SELECT ss_adm_appl_id, person_id, admission_cat,s_adm_process_type, admission_application_type
    FROM IGS_SS_ADM_APPL_STG
    WHERE ss_adm_appl_id = p_ss_adm_appl_id;


    -- Cursor to validate School Applying To
    CURSOR c_sch_apl_to(p_sch_apl_to_id NUMBER) IS
    SELECT sch_apl_to_id
    FROM IGS_AD_SCHL_APLY_TO
    WHERE sch_apl_to_id = p_sch_apl_to_id;

    -- Cursor to validate Location Code
    CURSOR c_location(p_location_cd VARCHAR2) IS
    SELECT location_cd
    FROM IGS_AD_LOCATION
    WHERE location_cd = p_location_cd;

    -- Cursor to validate Attendance Type
    CURSOR c_att_type(p_attendance_type VARCHAR2) IS
    SELECT attendance_type
    FROM IGS_EN_ATD_TYPE
    WHERE attendance_type = p_attendance_type;

    -- Cursor to validate Attendance Mode
    CURSOR c_att_mode(p_attendance_mode VARCHAR2) IS
    SELECT attendance_mode
    FROM IGS_EN_ATD_MODE
    WHERE attendance_mode = p_attendance_mode;


    -- Cursor to validate Program Offering Options
    CURSOR c_off_pattern(p_admission_cat VARCHAR2, p_s_adm_process_type VARCHAR2,p_location_cd VARCHAR2, p_attendance_type VARCHAR2,p_attendance_mode VARCHAR2) IS
    SELECT acopv.ACAD_CAL_TYPE
    FROM IGS_PS_OFR_PAT_OFERPAT_V acopv,
	 IGS_AD_LOCATION loc,
	 IGS_EN_ATD_MODE atd_mode,
	 IGS_EN_ATD_TYPE atd_type
    WHERE
	(IGS_AD_GEN_013.ADMS_GET_COO_CRV(
	  acopv.course_cd,
	  acopv.version_number,
	  acopv.s_admission_process_type, 'Y') = 'Y') AND
	(IGS_AD_GEN_013.ADMS_GET_ACAI_COO (
	  acopv.course_cd,
	  acopv.version_number,
	  acopv.location_cd,
	  acopv.attendance_mode,
	  acopv.attendance_type,
	  acopv.acad_cal_type,
	  acopv.acad_ci_sequence_number,
	  acopv.adm_cal_type,
	  acopv.adm_ci_sequence_number,
	  acopv.admission_cat,
	  acopv.s_admission_process_type,
	  'Y',
	  trunc(sysdate),
	  'Y')= 'Y') AND
        acopv.admission_cat = p_admission_cat AND
	acopv.s_admission_process_type = p_s_adm_process_type AND
	acopv.location_cd = NVL(p_location_cd,acopv.location_cd )AND
	acopv.attendance_mode = NVL(p_attendance_mode,acopv.attendance_mode) AND
	acopv.attendance_type = NVL(p_attendance_type,acopv.attendance_type);

   -- Cursor to check if the Preference Limit APC Step is set or not against the Application Type
   CURSOR c_pref_limit(p_admission_cat VARCHAR2,p_s_adm_process_type VARCHAR2) IS
   SELECT S_ADMISSION_STEP_TYPE
   FROM	IGS_AD_PRCS_CAT_STEP	apcs
   WHERE admission_cat = p_admission_cat AND
         s_admission_process_type = p_s_adm_process_type  AND
         s_admission_step_type = 'PREF-LIMIT' AND
	 mandatory_step_ind = 'Y';


   -- Cursor to check if another Program Instance for this Instance's Parent Application exists or not.
   CURSOR c_prog_inst(p_ss_adm_appl_id NUMBER) IS
   SELECT SS_ADMAPPL_PGM_ID
   FROM IGS_SS_APP_PGM_STG
   WHERE SS_ADM_APPL_ID = p_ss_adm_appl_id;

/* ******************* Put additional parameters here ********************************************  */
l_admappl_rec c_admappl%ROWTYPE := NULL;
l_sch_apl_to_rec IGS_AD_SCHL_APLY_TO.sch_apl_to_id%TYPE := NULL;
l_location_rec IGS_AD_LOCATION.location_cd%TYPE := NULL;
l_att_type_rec IGS_EN_ATD_TYPE.ATTENDANCE_TYPE%TYPE := NULL;
l_att_mode_rec IGS_EN_ATD_MODE.ATTENDANCE_MODE%TYPE := NULL;
l_off_pattern_rec IGS_PS_OFR_PAT_OFERPAT_V.ACAD_CAL_TYPE%TYPE := NULL;
l_pref_limit_rec IGS_AD_PRCS_CAT_STEP.S_ADMISSION_STEP_TYPE%TYPE := NULL;
l_prog_inst_rec IGS_SS_APP_PGM_STG.SS_ADMAPPL_PGM_ID%TYPE := NULL;

l_ss_adm_appl_id IGS_SS_APP_PGM_STG.ss_adm_appl_id%TYPE;
l_preference_number IGS_SS_APP_PGM_STG.preference_number%TYPE;
l_person_id IGS_SS_APP_PGM_STG.person_id%TYPE;
l_sch_apl_to_id	IGS_SS_APP_PGM_STG.sch_apl_to_id%TYPE;
l_location_cd IGS_SS_APP_PGM_STG.location_cd%TYPE;
l_attendance_type IGS_SS_APP_PGM_STG.attendance_type%TYPE;
l_attendance_mode IGS_SS_APP_PGM_STG.attendance_mode%TYPE;
l_attribute_category IGS_SS_APP_PGM_STG.attribute_category%TYPE;
l_attribute1 IGS_SS_APP_PGM_STG.ATTRIBUTE1%TYPE;
l_attribute2 IGS_SS_APP_PGM_STG.ATTRIBUTE2%TYPE;
l_attribute3 IGS_SS_APP_PGM_STG.ATTRIBUTE3%TYPE;
l_attribute4 IGS_SS_APP_PGM_STG.ATTRIBUTE4%TYPE;
l_attribute5 IGS_SS_APP_PGM_STG.ATTRIBUTE5%TYPE;
l_attribute6 IGS_SS_APP_PGM_STG.ATTRIBUTE6%TYPE;
l_attribute7 IGS_SS_APP_PGM_STG.ATTRIBUTE7%TYPE;
l_attribute8 IGS_SS_APP_PGM_STG.ATTRIBUTE8%TYPE;
l_attribute9 IGS_SS_APP_PGM_STG.ATTRIBUTE9%TYPE;
l_attribute10 IGS_SS_APP_PGM_STG.ATTRIBUTE10%TYPE;
l_attribute11 IGS_SS_APP_PGM_STG.ATTRIBUTE11%TYPE;
l_attribute12 IGS_SS_APP_PGM_STG.ATTRIBUTE12%TYPE;
l_attribute13 IGS_SS_APP_PGM_STG.ATTRIBUTE13%TYPE;
l_attribute14 IGS_SS_APP_PGM_STG.ATTRIBUTE14%TYPE;
l_attribute15 IGS_SS_APP_PGM_STG.ATTRIBUTE15%TYPE;
l_attribute16 IGS_SS_APP_PGM_STG.ATTRIBUTE16%TYPE;
l_attribute17 IGS_SS_APP_PGM_STG.ATTRIBUTE17%TYPE;
l_attribute18 IGS_SS_APP_PGM_STG.ATTRIBUTE18%TYPE;
l_attribute19 IGS_SS_APP_PGM_STG.ATTRIBUTE19%TYPE;
l_attribute20 IGS_SS_APP_PGM_STG.ATTRIBUTE20%TYPE;
l_attribute21 IGS_SS_APP_PGM_STG.ATTRIBUTE21%TYPE;
l_attribute22 IGS_SS_APP_PGM_STG.ATTRIBUTE22%TYPE;
l_attribute23 IGS_SS_APP_PGM_STG.ATTRIBUTE23%TYPE;
l_attribute24 IGS_SS_APP_PGM_STG.ATTRIBUTE24%TYPE;
l_attribute25 IGS_SS_APP_PGM_STG.ATTRIBUTE25%TYPE;
l_attribute26 IGS_SS_APP_PGM_STG.ATTRIBUTE26%TYPE;
l_attribute27 IGS_SS_APP_PGM_STG.ATTRIBUTE27%TYPE;
l_attribute28 IGS_SS_APP_PGM_STG.ATTRIBUTE28%TYPE;
l_attribute29 IGS_SS_APP_PGM_STG.ATTRIBUTE29%TYPE;
l_attribute30 IGS_SS_APP_PGM_STG.ATTRIBUTE30%TYPE;
l_attribute31 IGS_SS_APP_PGM_STG.ATTRIBUTE31%TYPE;
l_attribute32 IGS_SS_APP_PGM_STG.ATTRIBUTE32%TYPE;
l_attribute33 IGS_SS_APP_PGM_STG.ATTRIBUTE33%TYPE;
l_attribute34 IGS_SS_APP_PGM_STG.ATTRIBUTE34%TYPE;
l_attribute35 IGS_SS_APP_PGM_STG.ATTRIBUTE35%TYPE;
l_attribute36 IGS_SS_APP_PGM_STG.ATTRIBUTE36%TYPE;
l_attribute37 IGS_SS_APP_PGM_STG.ATTRIBUTE37%TYPE;
l_attribute38 IGS_SS_APP_PGM_STG.ATTRIBUTE38%TYPE;
l_attribute39 IGS_SS_APP_PGM_STG.ATTRIBUTE39%TYPE;
l_attribute40 IGS_SS_APP_PGM_STG.ATTRIBUTE40%TYPE;
l_ss_admappl_pgm_id IGS_SS_APP_PGM_STG.ss_admappl_pgm_id%TYPE;

BEGIN
    SAVEPOINT PRE_CREATE_APPL_INST_pub;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_msg_index   := 0;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
    	RAISE FND_API.G_EXC_ERROR;
    END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    l_msg_index := igs_ge_msg_stack.count_msg;

    -----------------------
    -- Validate all the parameters for their length
    -----------------------
    --p_ss_adm_appl_id
    check_length('PERSON_ID', 'IGS_SS_APP_PGM_STG', length(TRUNC(p_ss_adm_appl_id)));

    --p_sch_apl_to_id
    check_length('SCH_APL_TO_ID', 'IGS_SS_APP_PGM_STG', length(TRUNC(p_sch_apl_to_id)));

    --p_location_cd
    check_length('LOCATION_CD', 'IGS_SS_APP_PGM_STG', length(p_location_cd));

    --p_attendance_type
    check_length('ATTENDANCE_TYPE', 'IGS_SS_APP_PGM_STG', length(p_attendance_type));

    --p_attendance_mode
    check_length('ATTENDANCE_MODE', 'IGS_SS_APP_PGM_STG', length(p_attendance_mode));

    --p_attribute_category
    check_length('ATTRIBUTE_CATEGORY', 'IGS_SS_APP_PGM_STG', length(p_attribute_category));

    --p_attribute1
    check_length('ATTRIBUTE1', 'IGS_SS_APP_PGM_STG', length(p_attribute1));

    --p_attribute2
    check_length('ATTRIBUTE2', 'IGS_SS_APP_PGM_STG', length(p_attribute2));

    --p_attribute3
    check_length('ATTRIBUTE3', 'IGS_SS_APP_PGM_STG', length(p_attribute3));

    --p_attribute4
    check_length('ATTRIBUTE4', 'IGS_SS_APP_PGM_STG', length(p_attribute4));

    --p_attribute5
    check_length('ATTRIBUTE5', 'IGS_SS_APP_PGM_STG', length(p_attribute5));

    --p_attribute6
    check_length('ATTRIBUTE6', 'IGS_SS_APP_PGM_STG', length(p_attribute6));

    --p_attribute7
    check_length('ATTRIBUTE7', 'IGS_SS_APP_PGM_STG', length(p_attribute7));

    --p_attribute8
    check_length('ATTRIBUTE8', 'IGS_SS_APP_PGM_STG', length(p_attribute8));

    --p_attribute9
    check_length('ATTRIBUTE9', 'IGS_SS_APP_PGM_STG', length(p_attribute9));

    --p_attribute10
    check_length('ATTRIBUTE10', 'IGS_SS_APP_PGM_STG', length(p_attribute10));

    --p_attribute11
    check_length('ATTRIBUTE11', 'IGS_SS_APP_PGM_STG', length(p_attribute11));

    --p_attribute12
    check_length('ATTRIBUTE12', 'IGS_SS_APP_PGM_STG', length(p_attribute12));

    --p_attribute13
    check_length('ATTRIBUTE13', 'IGS_SS_APP_PGM_STG', length(p_attribute13));

    --p_attribute14
    check_length('ATTRIBUTE14', 'IGS_SS_APP_PGM_STG', length(p_attribute14));

    --p_attribute15
    check_length('ATTRIBUTE15', 'IGS_SS_APP_PGM_STG', length(p_attribute15));

    --p_attribute16
    check_length('ATTRIBUTE16', 'IGS_SS_APP_PGM_STG', length(p_attribute16));

    --p_attribute17
    check_length('ATTRIBUTE17', 'IGS_SS_APP_PGM_STG', length(p_attribute17));

    --p_attribute18
    check_length('ATTRIBUTE18', 'IGS_SS_APP_PGM_STG', length(p_attribute18));

    --p_attribute19
    check_length('ATTRIBUTE19', 'IGS_SS_APP_PGM_STG', length(p_attribute19));

    --p_attribute20
    check_length('ATTRIBUTE20', 'IGS_SS_APP_PGM_STG', length(p_attribute20));

    --p_attribute21
    check_length('ATTRIBUTE21', 'IGS_SS_APP_PGM_STG', length(p_attribute21));

    --p_attribute22
    check_length('ATTRIBUTE22', 'IGS_SS_APP_PGM_STG', length(p_attribute22));

    --p_attribute23
    check_length('ATTRIBUTE23', 'IGS_SS_APP_PGM_STG', length(p_attribute23));

    --p_attribute24
    check_length('ATTRIBUTE24', 'IGS_SS_APP_PGM_STG', length(p_attribute24));

    --p_attribute25
    check_length('ATTRIBUTE25', 'IGS_SS_APP_PGM_STG', length(p_attribute25));

    --p_attribute26
    check_length('ATTRIBUTE26', 'IGS_SS_APP_PGM_STG', length(p_attribute26));

    --p_attribute27
    check_length('ATTRIBUTE27', 'IGS_SS_APP_PGM_STG', length(p_attribute27));

    --p_attribute28
    check_length('ATTRIBUTE28', 'IGS_SS_APP_PGM_STG', length(p_attribute28));

    --p_attribute29
    check_length('ATTRIBUTE29', 'IGS_SS_APP_PGM_STG', length(p_attribute29));

    --p_attribute30
    check_length('ATTRIBUTE30', 'IGS_SS_APP_PGM_STG', length(p_attribute30));

    --p_attribute31
    check_length('ATTRIBUTE31', 'IGS_SS_APP_PGM_STG', length(p_attribute31));

    --p_attribute32
    check_length('ATTRIBUTE32', 'IGS_SS_APP_PGM_STG', length(p_attribute32));

    --p_attribute33
    check_length('ATTRIBUTE33', 'IGS_SS_APP_PGM_STG', length(p_attribute33));

    --p_attribute34
    check_length('ATTRIBUTE34', 'IGS_SS_APP_PGM_STG', length(p_attribute34));

    --p_attribute35
    check_length('ATTRIBUTE35', 'IGS_SS_APP_PGM_STG', length(p_attribute35));

    --p_attribute36
    check_length('ATTRIBUTE36', 'IGS_SS_APP_PGM_STG', length(p_attribute36));

    --p_attribute37
    check_length('ATTRIBUTE37', 'IGS_SS_APP_PGM_STG', length(p_attribute37));

    --p_attribute38
    check_length('ATTRIBUTE38', 'IGS_SS_APP_PGM_STG', length(p_attribute38));

    --p_attribute39
    check_length('ATTRIBUTE39', 'IGS_SS_APP_PGM_STG', length(p_attribute39));

    --p_attribute40
    check_length('ATTRIBUTE40', 'IGS_SS_APP_PGM_STG', length(p_attribute40));

    ---------------------
    --Intialization of variables to handle G_MISS_CHAR/NUM/DATE
    ---------------------

    -- p_ss_adm_appl_id
    IF  p_ss_adm_appl_id = FND_API.G_MISS_NUM OR p_ss_adm_appl_id IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRECREATE_PAR_INST_MISS');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    ELSE
	l_ss_adm_appl_id := p_ss_adm_appl_id;
    END IF;

    -- p_sch_apl_to_id
    IF  p_sch_apl_to_id = FND_API.G_MISS_NUM THEN
	l_sch_apl_to_id := NULL;
    ELSE
	l_sch_apl_to_id := p_sch_apl_to_id;
    END IF;

    -- p_location_cd
    IF  p_location_cd = FND_API.G_MISS_CHAR THEN
	l_location_cd := NULL;
    ELSE
	l_location_cd := p_location_cd;
    END IF;

    -- p_attendance_type
    IF  p_attendance_type = FND_API.G_MISS_CHAR THEN
	l_attendance_type := NULL;
    ELSE
	l_attendance_type := p_attendance_type;
    END IF;

    -- p_attendance_mode
    IF  p_attendance_mode = FND_API.G_MISS_CHAR  THEN
	l_attendance_mode := NULL;
    ELSE
	l_attendance_mode := p_attendance_mode;
    END IF;

    -- p_attribute_category
    IF  p_attribute_category = FND_API.G_MISS_CHAR THEN
	l_attribute_category := NULL;
    ELSE
	l_attribute_category := p_attribute_category;
    END IF;

    -- p_attribute1
    IF p_attribute1 = FND_API.G_MISS_CHAR THEN
	l_attribute1 := NULL;
    ELSE
	l_attribute1 := p_attribute1;
    END IF;

    --	p_attribute2
    IF p_attribute2 = FND_API.G_MISS_CHAR THEN
	l_attribute2 := NULL;
    ELSE
	l_attribute2 := p_attribute2;
    END IF;

    --	p_attribute3
    IF p_attribute3 = FND_API.G_MISS_CHAR THEN
	l_attribute3 := NULL;
    ELSE
	l_attribute3 := p_attribute3;
    END IF;

    --	p_attribute4
    IF p_attribute4 = FND_API.G_MISS_CHAR THEN
	l_attribute4 := NULL;
    ELSE
	l_attribute4 := p_attribute4;
    END IF;

    --	p_attribute5
    IF p_attribute5 = FND_API.G_MISS_CHAR THEN
	l_attribute5 := NULL;
    ELSE
	l_attribute5 := p_attribute5;
    END IF;

    --	p_attribute6
    IF p_attribute6 = FND_API.G_MISS_CHAR THEN
	l_attribute6 := NULL;
    ELSE
	l_attribute6 := p_attribute6;
    END IF;

    --	p_attribute7
    IF p_attribute7 = FND_API.G_MISS_CHAR THEN
	l_attribute7 := NULL;
    ELSE
	l_attribute7 := p_attribute7;
    END IF;

    --	p_attribute8
    IF p_attribute8 = FND_API.G_MISS_CHAR THEN
	l_attribute8 := NULL;
    ELSE
	l_attribute8 := p_attribute8;
    END IF;

    --	p_attribute9
    IF p_attribute9 = FND_API.G_MISS_CHAR THEN
	l_attribute9 := NULL;
    ELSE
	l_attribute9 := p_attribute9;
    END IF;

    --	p_attribute10
    IF p_attribute10 = FND_API.G_MISS_CHAR THEN
	l_attribute10 := NULL;
    ELSE
	l_attribute10 := p_attribute10;
    END IF;

    --	p_attribute11
    IF p_attribute11 = FND_API.G_MISS_CHAR THEN
	l_attribute11 := NULL;
    ELSE
	l_attribute11 := p_attribute11;
    END IF;

    --	p_attribute12
    IF p_attribute12 = FND_API.G_MISS_CHAR THEN
	l_attribute12 := NULL;
    ELSE
	l_attribute12 := p_attribute12;
    END IF;

    --	p_attribute13
    IF p_attribute13 = FND_API.G_MISS_CHAR THEN
	l_attribute13 := NULL;
    ELSE
	l_attribute13 := p_attribute13;
    END IF;

    -- p_attribute14
    IF p_attribute14 = FND_API.G_MISS_CHAR THEN
	l_attribute14 := NULL;
    ELSE
	l_attribute14 := p_attribute14;
    END IF;

    -- p_attribute14
    IF p_attribute15 = FND_API.G_MISS_CHAR THEN
	l_attribute15 := NULL;
    ELSE
	l_attribute15 := p_attribute15;
    END IF;

    --	p_attribute16
    IF p_attribute16 = FND_API.G_MISS_CHAR THEN
	l_attribute16 := NULL;
    ELSE
	l_attribute16 := p_attribute16;
    END IF;

    --	p_attribute17
    IF p_attribute17 = FND_API.G_MISS_CHAR THEN
	l_attribute17 := NULL;
    ELSE
	l_attribute17 := p_attribute17;
    END IF;

    --	p_attribute18
    IF p_attribute18 = FND_API.G_MISS_CHAR THEN
	l_attribute18 := NULL;
    ELSE
	l_attribute18 := p_attribute18;
    END IF;

    --	p_attribute19
    IF p_attribute19 = FND_API.G_MISS_CHAR THEN
	l_attribute19 := NULL;
    ELSE
	l_attribute19 := p_attribute19;
    END IF;

    --	p_attribute20
    IF p_attribute20 = FND_API.G_MISS_CHAR THEN
	l_attribute20 := NULL;
    ELSE
	l_attribute20 := p_attribute20;
    END IF;

    --	p_attribute21
    IF p_attribute21 = FND_API.G_MISS_CHAR THEN
	l_attribute21 := NULL;
    ELSE
	l_attribute21 := p_attribute21;
    END IF;

    --	p_attribute22
    IF p_attribute22 = FND_API.G_MISS_CHAR THEN
	l_attribute22 := NULL;
    ELSE
	l_attribute22 := p_attribute22;
    END IF;

    --	p_attribute23
    IF p_attribute23 = FND_API.G_MISS_CHAR THEN
	l_attribute23 := NULL;
    ELSE
	l_attribute23 := p_attribute23;
    END IF;

    --	p_attribute24
    IF p_attribute24 = FND_API.G_MISS_CHAR THEN
	l_attribute24 := NULL;
    ELSE
	l_attribute24 := p_attribute24;
    END IF;

    --	p_attribute25
    IF p_attribute25 = FND_API.G_MISS_CHAR THEN
	l_attribute25 := NULL;
    ELSE
	l_attribute25 := p_attribute25;
    END IF;

    --	p_attribute26
    IF p_attribute26 = FND_API.G_MISS_CHAR THEN
	l_attribute26 := NULL;
    ELSE
	l_attribute26 := p_attribute26;
    END IF;

    --	p_attribute27
    IF p_attribute27 = FND_API.G_MISS_CHAR THEN
	l_attribute27 := NULL;
    ELSE
	l_attribute27 := p_attribute27;
    END IF;

    --	p_attribute28
    IF p_attribute28 = FND_API.G_MISS_CHAR THEN
	l_attribute28 := NULL;
    ELSE
	l_attribute28 := p_attribute28;
    END IF;

    --	p_attribute29
    IF p_attribute29 = FND_API.G_MISS_CHAR THEN
	l_attribute29 := NULL;
    ELSE
	l_attribute29 := p_attribute29;
    END IF;

    --	p_attribute30
    IF p_attribute30 = FND_API.G_MISS_CHAR THEN
	l_attribute30 := NULL;
    ELSE
	l_attribute30 := p_attribute30;
    END IF;

    --	p_attribute31
    IF p_attribute31 = FND_API.G_MISS_CHAR THEN
	l_attribute31 := NULL;
    ELSE
	l_attribute31 := p_attribute31;
    END IF;

    --	p_attribute32
    IF p_attribute32 = FND_API.G_MISS_CHAR THEN
	l_attribute32 := NULL;
    ELSE
	l_attribute32 := p_attribute32;
    END IF;

    --	p_attribute33
    IF p_attribute33 = FND_API.G_MISS_CHAR THEN
	l_attribute33 := NULL;
    ELSE
	l_attribute33 := p_attribute33;
    END IF;

    --	p_attribute34
    IF p_attribute34 = FND_API.G_MISS_CHAR THEN
	l_attribute34 := NULL;
    ELSE
	l_attribute34 := p_attribute34;
    END IF;

    --	p_attribute35
    IF p_attribute35 = FND_API.G_MISS_CHAR THEN
	l_attribute35 := NULL;
    ELSE
	l_attribute35 := p_attribute35;
    END IF;

    --	p_attribute36
    IF p_attribute36 = FND_API.G_MISS_CHAR THEN
	l_attribute36 := NULL;
    ELSE
	l_attribute36 := p_attribute36;
    END IF;

    --	p_attribute37
    IF p_attribute37 = FND_API.G_MISS_CHAR THEN
	l_attribute37 := NULL;
    ELSE
	l_attribute37 := p_attribute37;
    END IF;

    --	p_attribute38
    IF p_attribute38 = FND_API.G_MISS_CHAR THEN
	l_attribute38 := NULL;
    ELSE
	l_attribute38 := p_attribute38;
    END IF;

    --	p_attribute39
    IF p_attribute39 = FND_API.G_MISS_CHAR THEN
	l_attribute39 := NULL;
    ELSE
	l_attribute39 := p_attribute39;
    END IF;

    --	p_attribute40
    IF p_attribute40 = FND_API.G_MISS_CHAR THEN
	l_attribute40 := NULL;
    ELSE
	l_attribute40 := p_attribute40;
    END IF;

    ---------------------------
    -- Validate the values of the parameters passed in the API
    ---------------------------

    -- validate p_ss_adm_appl_id
    -- The application id should exist in the parent Table-IGS_SS_ADM_APPL_STG
    OPEN c_admappl(l_ss_adm_appl_id);
    FETCH c_admappl INTO l_admappl_rec;
    CLOSE c_admappl;

    IF l_admappl_rec.ss_adm_appl_id IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
	FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_APPL_ID'));
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    ---------------------
    -- Derive Person Id from the application Type
    ---------------------
    l_person_id := l_admappl_rec.person_id;


    /*
    For the parameters p_sch_apl_to_id, p_location_cd, p_attendance_type and	 p_attendance_mode there will be 2 kinds of validations:
    a) That the individual values exist in OSS Tables IGS_AD_SCHL_APLY_TO, IGS_AD_LOCATION, IGS_EN_ATD_MODE, IGS_EN_ATD_TYPE resp.
    b) That the combination of these parameter values is a part of a valid Offering Option corresponding to this Application's Calendar and Application Type.
    */

    -- validate p_sch_apl_to_id
    IF l_sch_apl_to_id IS NOT NULL THEN
	OPEN c_sch_apl_to(l_sch_apl_to_id);
	FETCH c_sch_apl_to INTO l_sch_apl_to_rec;
	CLOSE c_sch_apl_to;

	IF l_sch_apl_to_rec IS NULL THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SCH_APPLY_TO'));
		IGS_GE_MSG_STACK.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    END IF;

    -- validate l_location_cd
    IF l_location_cd IS NOT NULL THEN
	OPEN c_location(l_location_cd);
	FETCH c_location INTO l_location_rec;
	CLOSE c_location;

	IF l_location_rec IS NULL THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_EN_LOC_CD_INV');
		IGS_GE_MSG_STACK.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    END IF;

    -- validate p_attendance_type
    IF l_attendance_type IS NOT NULL THEN
	OPEN c_att_type(l_attendance_type);
	FETCH c_att_type INTO l_att_type_rec;
	CLOSE c_att_type;

	IF l_att_type_rec IS NULL THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ATTENDANCE_TYPE'));
		IGS_GE_MSG_STACK.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    END IF;

    -- validate p_attendance_mode
    IF l_attendance_mode IS NOT NULL THEN
	OPEN c_att_mode(l_attendance_mode);
	FETCH c_att_mode INTO l_att_mode_rec;
	CLOSE c_att_mode;

	IF l_att_mode_rec IS NULL THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ATTENDANCE_MODE'));
		IGS_GE_MSG_STACK.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    END IF;

    -- validate  p_location_cd, p_attendance_type and p_attendance_mode combination
    IF l_location_cd IS NULL AND l_attendance_type IS NULL AND l_attendance_mode IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_AD_COMB_NOT_NULL');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_off_pattern(l_admappl_rec.admission_cat, l_admappl_rec.s_adm_process_type, l_location_cd, l_attendance_type,l_attendance_mode);
    FETCH c_off_pattern INTO l_off_pattern_rec;
    CLOSE c_off_pattern;

    IF l_off_pattern_rec IS NULL THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_AD_COMB_NOT_EXIST');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate/ Derive Preference Number
    OPEN c_pref_limit(l_admappl_rec.admission_cat,  l_admappl_rec.s_adm_process_type);
    FETCH c_pref_limit INTO l_pref_limit_rec;
    CLOSE c_pref_limit;

    OPEN c_prog_inst(l_ss_adm_appl_id);
    FETCH c_prog_inst INTO l_prog_inst_rec;
    CLOSE c_prog_inst;

    IF l_pref_limit_rec IS NULL THEN	-- Preference Limit APC step is not set
	l_preference_number := NULL;
    ELSE				 -- Preference Limit APC Step is set
	IF l_prog_inst_rec IS NULL THEN	-- Another Program Instance for same Parent Application does not exists
		l_preference_number := 1;
	ELSE
		FND_MESSAGE.SET_NAME('IGS','IGS_AD_PROG_PREF_EXIST');
		IGS_GE_MSG_STACK.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
    END IF;

    -- Check for correctness of Descriptive FlexField values
    IF NOT IGS_AD_IMP_018.validate_desc_flex_40_cols(
						     l_attribute_category,
						     l_attribute1,
						     l_attribute2,
						     l_attribute3,
						     l_attribute4,
						     l_attribute5,
						     l_attribute6,
						     l_attribute7,
						     l_attribute8,
						     l_attribute9,
						     l_attribute10,
						     l_attribute11,
						     l_attribute12,
						     l_attribute13,
						     l_attribute14,
						     l_attribute15,
						     l_attribute16,
						     l_attribute17,
						     l_attribute18,
						     l_attribute19,
						     l_attribute20,
						     l_attribute21,
						     l_attribute22,
						     l_attribute23,
						     l_attribute24,
						     l_attribute25,
						     l_attribute26,
						     l_attribute27,
						     l_attribute28,
						     l_attribute29,
						     l_attribute30,
						     l_attribute31,
						     l_attribute32,
						     l_attribute33,
						     l_attribute34,
						     l_attribute35,
						     l_attribute36,
						     l_attribute37,
						     l_attribute38,
						     l_attribute39,
						     l_attribute40,
						     'IGS_AD_APPL_INST_FLEX'
						    ) THEN
	FND_MESSAGE.SET_NAME('IGS','IGS_AD_INVALID_DESC_FLEX');
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    ---------------------
    -- Insert the Application Instance Record.
    ---------------------

    INSERT INTO IGS_SS_APP_PGM_STG     (SS_ADMAPPL_PGM_ID,
					SS_ADM_APPL_ID,
					PERSON_ID,
					PREFERENCE_NUMBER,
					SCH_APL_TO_ID,
					LOCATION_CD,
					ATTENDANCE_TYPE,
					ATTENDANCE_MODE,
					ATTRIBUTE_CATEGORY,
					ATTRIBUTE1,
					ATTRIBUTE2,
					ATTRIBUTE3,
					ATTRIBUTE4,
					ATTRIBUTE5,
					ATTRIBUTE6,
					ATTRIBUTE7,
					ATTRIBUTE8,
					ATTRIBUTE9,
					ATTRIBUTE10,
					ATTRIBUTE11,
					ATTRIBUTE12,
					ATTRIBUTE13,
					ATTRIBUTE14,
					ATTRIBUTE15,
					ATTRIBUTE16,
					ATTRIBUTE17,
					ATTRIBUTE18,
					ATTRIBUTE19,
					ATTRIBUTE20,
					ATTRIBUTE21,
					ATTRIBUTE22,
					ATTRIBUTE23,
					ATTRIBUTE24,
					ATTRIBUTE25,
					ATTRIBUTE26,
					ATTRIBUTE27,
					ATTRIBUTE28,
					ATTRIBUTE29,
					ATTRIBUTE30,
					ATTRIBUTE31,
					ATTRIBUTE32,
					ATTRIBUTE33,
					ATTRIBUTE34,
					ATTRIBUTE35,
					ATTRIBUTE36,
					ATTRIBUTE37,
					ATTRIBUTE38,
					ATTRIBUTE39,
					ATTRIBUTE40,
					LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					CREATION_DATE,
					CREATED_BY,
					LAST_UPDATE_LOGIN)
			     VALUES    (IGS_SS_ADMAPPL_PGM_S.NEXTVAL,
					l_ss_adm_appl_id,
					l_person_id,
					l_preference_number,
					l_sch_apl_to_id,
					l_location_cd,
					l_attendance_type,
					l_attendance_mode,
					l_attribute_category,
					l_attribute1,
					l_attribute2,
					l_attribute3,
					l_attribute4,
					l_attribute5,
					l_attribute6,
					l_attribute7,
					l_attribute8,
					l_attribute9,
					l_attribute10,
					l_attribute11,
					l_attribute12,
					l_attribute13,
					l_attribute14,
					l_attribute15,
					l_attribute16,
					l_attribute17,
					l_attribute18,
					l_attribute19,
					l_attribute20,
					l_attribute21,
					l_attribute22,
					l_attribute23,
					l_attribute24,
					l_attribute25,
					l_attribute26,
					l_attribute27,
					l_attribute28,
					l_attribute29,
					l_attribute30,
					l_attribute31,
					l_attribute32,
					l_attribute33,
					l_attribute34,
					l_attribute35,
					l_attribute36,
					l_attribute37,
					l_attribute38,
					l_attribute39,
					l_attribute40,
					SYSDATE,
					FND_GLOBAL.USER_ID,
					SYSDATE,
					FND_GLOBAL.USER_ID,
					FND_GLOBAL.USER_ID) RETURNING SS_ADMAPPL_PGM_ID INTO x_ss_admappl_pgm_id;

    IF FND_API.To_Boolean( p_commit ) THEN
	COMMIT;
    END IF;

    -- Exception Handling
    EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
	    ROLLBACK TO PRE_CREATE_APPL_INST_pub;
	    igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

	    IF l_hash_msg_name_text_type_tab(x_msg_count - 2).name <> 'ORA' THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	    ELSE
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            END IF;

	    x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-2).text;
	    x_msg_count := x_msg_count-1;


	WHEN OTHERS THEN
	    ROLLBACK TO PRE_CREATE_APPL_INST_pub;
            igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

	    IF l_hash_msg_name_text_type_tab(x_msg_count - 1).name <> 'ORA' THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
	    ELSE
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            END IF;

            x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-1).text;

END PRE_CREATE_APPLICATION_INST;

PROCEDURE INSERT_STG_FEE_REQ_DET (

       p_api_version IN NUMBER,					-- standard Public API IN params
       p_init_msg_list IN VARCHAR2 default FND_API.G_FALSE,
       p_commit	IN VARCHAR2 default FND_API.G_FALSE,
       p_validation_level IN NUMBER :=FND_API.G_VALID_LEVEL_FULL,
       x_return_status OUT NOCOPY VARCHAR2,				-- standard Public API OUT params
       x_msg_count OUT NOCOPY NUMBER,
       x_msg_data OUT NOCOPY VARCHAR2,
       p_SS_ADM_APPL_ID IN NUMBER,				-- Staging table related params
       p_PERSON_ID IN NUMBER,
       p_APPLICANT_FEE_TYPE IN NUMBER,
       p_APPLICANT_FEE_STATUS IN NUMBER,
       p_FEE_DATE IN DATE,
       p_FEE_PAYMENT_METHOD IN NUMBER,
       p_FEE_AMOUNT IN NUMBER,
       p_REFERENCE_NUM IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : Pranay Fotedar
  Date Created By : 28-Apr-2006
  Purpose : Creation of Fee Records on submission
  Change History
  Who             When            What
  pfotedar        2006/05/05      Added Validation for Fee Payment Method
  (reverse chronological order - newest change first)
  ***************************************************************/

    l_api_version CONSTANT NUMBER := '1.0';
    l_api_name CONSTANT VARCHAR2(30) := 'INSERT_STG_FEE_REQ_DET';
    l_msg_index NUMBER;
    l_return_status VARCHAR2(1);
    l_hash_msg_name_text_type_tab igs_ad_gen_016.g_msg_name_text_type_table;

    CURSOR C_FEE_TYPE(p_APPL_FEE_TYPE IGS_AD_CODE_CLASSES.CODE_ID%TYPE) IS
      SELECT CC.CODE_ID
      FROM IGS_AD_CODE_CLASSES CC
      WHERE CC.CODE_ID = p_APPL_FEE_TYPE
	AND CC.CLASS = 'SYS_FEE_TYPE'
	AND NVL(CLOSED_IND,'N') = 'N'
	AND CC.CLASS_TYPE_CODE='ADM_CODE_CLASSES';

    CURSOR C_FEE_STATUS(p_APPL_FEE_STATUS IGS_AD_CODE_CLASSES.CODE_ID%TYPE) IS
      SELECT CC.CODE_ID
      FROM IGS_AD_CODE_CLASSES CC
      WHERE CC.CODE_ID = p_APPL_FEE_STATUS
	AND CC.CLASS = 'SYS_FEE_STATUS'
	AND NVL(CLOSED_IND,'N') = 'N'
	AND CC.CLASS_TYPE_CODE='ADM_CODE_CLASSES';


    CURSOR C_FEE_PAYMENT_METHOD(p_APPL_FEE_PAY_MET IGS_AD_CODE_CLASSES.CODE_ID%TYPE) IS
      SELECT CC.CODE_ID
      FROM IGS_AD_CODE_CLASSES CC
      WHERE CC.CODE_ID = p_APPL_FEE_PAY_MET
        AND CC.CLASS = 'SYS_FEE_PAY_METHOD'
        AND NVL(CLOSED_IND,'N') = 'N'
        AND CC.CLASS_TYPE_CODE='ADM_CODE_CLASSES';

    l_APPL_FEE_TYPE_REC  C_FEE_TYPE%ROWTYPE;
    l_APPL_FEE_STATUS_REC  C_FEE_STATUS%ROWTYPE;
    l_APPL_FEE_PAY_MET_REC  C_FEE_PAYMENT_METHOD%ROWTYPE;


    l_SS_ADM_APPL_ID IGS_SS_APP_REQ_STG.SS_ADM_APPL_ID%TYPE;
    l_PERSON_ID IGS_SS_APP_REQ_STG.PERSON_ID%TYPE;
    l_APPLICANT_FEE_TYPE IGS_SS_APP_REQ_STG.APPLICANT_FEE_TYPE%TYPE;
    l_APPLICANT_FEE_STATUS IGS_SS_APP_REQ_STG.APPLICANT_FEE_STATUS%TYPE;
    l_FEE_DATE IGS_SS_APP_REQ_STG.FEE_DATE%TYPE;
    l_FEE_PAYMENT_METHOD IGS_SS_APP_REQ_STG.FEE_PAYMENT_METHOD%TYPE;
    l_FEE_AMOUNT IGS_SS_APP_REQ_STG.FEE_AMOUNT%TYPE;
    l_REFERENCE_NUM IGS_SS_APP_REQ_STG.REFERENCE_NUM%TYPE;

 BEGIN
        --  Standard begin of API savepoint
    	SAVEPOINT INSERT_STG_FEE_REQ_DET_PUB;

	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_msg_index   := 0;

    	-- Standard call to check for call compatibility.
    	IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- Check p_init_msg_list
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	l_msg_index := igs_ge_msg_stack.count_msg;


	-----------------------
	-- Validate all the parameters for their length
	-----------------------
	-- p_SS_ADM_APPL_ID
	check_length('SS_ADM_APPL_ID', 'IGS_SS_APP_REQ_STG', length(TRUNC(p_SS_ADM_APPL_ID)));
	-- p_PERSON_ID
	check_length('PERSON_ID', 'IGS_SS_APP_REQ_STG', length(TRUNC(p_PERSON_ID)));
        -- p_APPLICANT_FEE_TYPE
       	check_length('APPLICANT_FEE_TYPE', 'IGS_SS_APP_REQ_STG', length(TRUNC(p_APPLICANT_FEE_TYPE)));
	-- p_APPLICANT_FEE_STATUS
	check_length('APPLICANT_FEE_STATUS', 'IGS_SS_APP_REQ_STG', length(TRUNC(p_APPLICANT_FEE_STATUS)));
	-- p_FEE_PAYMENT_METHOD
	check_length('FEE_PAYMENT_METHOD', 'IGS_SS_APP_REQ_STG', length(TRUNC(p_FEE_PAYMENT_METHOD)));
        -- p_FEE_AMOUNT
	check_length('FEE_AMOUNT', 'IGS_SS_APP_REQ_STG', length(TRUNC(p_FEE_AMOUNT)));
        -- p_REFERENCE_NUM
	check_length('REFERENCE_NUM', 'IGS_SS_APP_REQ_STG', length(p_REFERENCE_NUM));
	------------------------
	-- End of parameter-length validations.
	------------------------

	------------------------
	--Intialization of variables to handle G_MISS_CHAR/NUM/DATE
	------------------------

	IF  p_SS_ADM_APPL_ID = FND_API.G_MISS_NUM OR p_SS_ADM_APPL_ID IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_STG_FEE_PARAM_MISSING');			--error message
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
	ELSE
	l_SS_ADM_APPL_ID := p_SS_ADM_APPL_ID;
	END IF;

	IF  p_PERSON_ID = FND_API.G_MISS_NUM OR p_PERSON_ID IS NULL THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_STG_FEE_PARAM_MISSING');			--error message
	IGS_GE_MSG_STACK.ADD;
	RAISE FND_API.G_EXC_ERROR;
	ELSE
	l_PERSON_ID := p_PERSON_ID;
	END IF;

	IF  p_APPLICANT_FEE_TYPE = FND_API.G_MISS_NUM THEN
	l_APPLICANT_FEE_TYPE := NULL;
	ELSE
	l_APPLICANT_FEE_TYPE := p_APPLICANT_FEE_TYPE;
	END IF;

	IF  p_APPLICANT_FEE_STATUS = FND_API.G_MISS_NUM THEN
	l_APPLICANT_FEE_STATUS := NULL;
	ELSE
	l_APPLICANT_FEE_STATUS := p_APPLICANT_FEE_STATUS;
	END IF;

	IF  p_FEE_DATE = FND_API.G_MISS_DATE THEN
	l_FEE_DATE := NULL;
	ELSE
	l_FEE_DATE := p_FEE_DATE;
	END IF;

	IF  p_FEE_PAYMENT_METHOD = FND_API.G_MISS_NUM THEN
	l_FEE_PAYMENT_METHOD := NULL;
	ELSE
	l_FEE_PAYMENT_METHOD := p_FEE_PAYMENT_METHOD;
	END IF;

	IF  p_FEE_AMOUNT = FND_API.G_MISS_NUM THEN
	l_FEE_AMOUNT := NULL;
	ELSE
	l_FEE_AMOUNT := p_FEE_AMOUNT;
	END IF;

	IF  p_REFERENCE_NUM = FND_API.G_MISS_CHAR THEN
	l_REFERENCE_NUM := NULL;
	ELSE
	l_REFERENCE_NUM := p_REFERENCE_NUM;
	END IF;

	------------------------
	-- End of intialization of variables to handle G_MISS_CHAR/NUM/DATE
	------------------------

	-- When fee type, fee status, fee date and fee amount are null
	IF l_APPLICANT_FEE_TYPE IS NULL OR l_APPLICANT_FEE_STATUS IS NULL
		OR l_FEE_DATE IS NULL OR l_FEE_AMOUNT IS NULL
		THEN
			FND_MESSAGE.SET_NAME('IGS','IGS_SS_AD_FEE_NTNULL');	--error message
			IGS_GE_MSG_STACK.ADD;
			RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- check for applicant_fee_type values
	IF l_APPLICANT_FEE_TYPE IS NOT NULL THEN
	    OPEN C_FEE_TYPE(l_APPLICANT_FEE_TYPE);
	    FETCH C_FEE_TYPE INTO l_APPL_FEE_TYPE_REC;
 		IF (C_FEE_TYPE%NOTFOUND) THEN
		    CLOSE C_FEE_TYPE;
	 	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
		    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPLICANT_FEE_TYPE'));
	            IGS_GE_MSG_STACK.ADD;
	            RAISE FND_API.G_EXC_ERROR;		--error message
		END IF;
 	    CLOSE C_FEE_TYPE;
	END IF;

	-- check for applicant_fee_status values
	IF l_APPLICANT_FEE_STATUS IS NOT NULL THEN
	    OPEN C_FEE_STATUS(l_APPLICANT_FEE_STATUS);
	    FETCH C_FEE_STATUS INTO l_APPL_FEE_STATUS_REC;
 		IF (C_FEE_STATUS%NOTFOUND) THEN
		    CLOSE C_FEE_STATUS;
	 	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
		    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPLICANT_FEE_STAT'));
		    IGS_GE_MSG_STACK.ADD;
		    RAISE FND_API.G_EXC_ERROR;		--error message
		END IF;
 	    CLOSE C_FEE_STATUS;
	END IF;

        -- check for fee_payment_method values
        IF l_FEE_PAYMENT_METHOD IS NOT NULL THEN
            OPEN C_FEE_PAYMENT_METHOD(l_FEE_PAYMENT_METHOD);
            FETCH C_FEE_PAYMENT_METHOD INTO l_APPL_FEE_PAY_MET_REC;
                IF (C_FEE_PAYMENT_METHOD%NOTFOUND) THEN
                    CLOSE C_FEE_PAYMENT_METHOD;
                    FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
                    FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FEE_PAY_METHOD'));
                    IGS_GE_MSG_STACK.ADD;
                    RAISE FND_API.G_EXC_ERROR;          --error message
                END IF;
            CLOSE C_FEE_PAYMENT_METHOD;
        END IF;

	-- if Fee Amount is negative
	IF l_FEE_AMOUNT IS NOT NULL AND l_FEE_AMOUNT < 0 THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_AD_FEE_AMT_NON_NEGATIVE');	--error message
           IGS_GE_MSG_STACK.ADD;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

	-- if Fee Date is greater than sysdate
	IF l_FEE_DATE IS NOT NULL AND l_FEE_DATE > SYSDATE THEN
	   FND_MESSAGE.SET_NAME('IGS','IGS_AD_DATE_SYSDATE');		--error message
	   FND_MESSAGE.SET_TOKEN ('NAME',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FEE_DATE'));
           IGS_GE_MSG_STACK.ADD;
           RAISE FND_API.G_EXC_ERROR;
	END IF;

	INSERT INTO IGS_SS_APP_REQ_STG (
			SS_APP_REQ_ID,
			SS_ADM_APPL_ID,
			PERSON_ID,
			APPLICANT_FEE_TYPE,
			APPLICANT_FEE_STATUS,
			FEE_DATE,
			FEE_PAYMENT_METHOD,
			FEE_AMOUNT,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_LOGIN,
			REFERENCE_NUM
			)
		VALUES
		(
			IGS_SS_APP_REQ_STG_S.NEXTVAL,
			l_SS_ADM_APPL_ID,
			l_PERSON_ID,
			l_APPLICANT_FEE_TYPE,
			l_APPLICANT_FEE_STATUS,
			l_FEE_DATE,
			l_FEE_PAYMENT_METHOD,
			l_FEE_AMOUNT,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.USER_ID,
			l_REFERENCE_NUM
           );

	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Get message count and if 1, return message data.
	FND_MSG_PUB.Count_And_Get
	(  		p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
	);


EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN

		ROLLBACK TO INSERT_STG_FEE_REQ_DET_PUB;
		igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

		IF l_hash_msg_name_text_type_tab(x_msg_count - 2).name <> 'ORA' THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
		ELSE
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		END IF;

		x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-2).text;
		x_msg_count := x_msg_count-1;

	WHEN OTHERS THEN

		ROLLBACK TO INSERT_STG_FEE_REQ_DET_PUB;
		igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);

		IF l_hash_msg_name_text_type_tab(x_msg_count - 1).name <> 'ORA' THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
		ELSE
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		END IF;

		x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-1).text;

END INSERT_STG_FEE_REQ_DET;

END IGS_PRECREATE_APPL_PUB;

/
