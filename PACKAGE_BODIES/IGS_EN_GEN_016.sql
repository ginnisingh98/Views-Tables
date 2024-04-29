--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_016
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_016" AS
/* $Header: IGSENA1B.pls 120.5 2006/01/17 04:06:48 ckasu ship $ */


PROCEDURE enrp_enr_reg_upd (
P_BATCH_ID IN NUMBER ,
P_ENROLL_MTD_TYPE IN VARCHAR2
) AS
/******************************************************************
Created By        : SVENKATA
Date Created By   : 31-OCT-02
Purpose           : Validate Registration details from interface tables and update
		    the corresponding OSS tables with the new Registration Date and Unit
		    Attempt Status.
Known limitations,
enhancements,
remarks            :
Change History
Who      When                 What
ckasu    31-DEC-2004         Modified code inorder to show note when stored Transfer exists for the source program and
                             that stored transfer needs to be updated to include newly enrolled units so that this unit
                             can be transfered to the destination when the future dated transfer is processed as a part
                             of bug#4095276
ckasu    29-SEP-2004          Modified signature of log_regid_person_dtls procedure by adding
                             p_load_cal_type,p_load_seq_number inorder to print Load cal details
                             and also modified code to do hold,person validations only when Load
                             cal in the context has unit attempts.
ckasu         14-SEP-2004     Added Holds,person step validations as a part of Bug# 3823810
stutta       11-Feb-2004     Passing new parameter p_enrolled_dt as SYSDATE in
                             call to validate_enroll_validate.
rvivekan      3-Aug-2003     Bulk unit upload TD #3049009. Added 'Enrolled' status to the get_prgrm_dtls curosr definition.
				Added error message logging for igs_en_enroll_wlst.validate_uinit_steps and igs_ss_en_wrappers.validate_enroll_validate
svenkata      15-Jan-2003    Bug# 2740746 - The message name IGS_PS_INVALID_PRG_CD was invalid.Changed the message to IGS_PR_INVALID_PRG_CD.
svenkata      31-DEC-2002    Bug# 2724288 - added values for WHO columns in the UPDATE stmnts for the interface table.
sgurusam      17-Jun-2005    Modified to pass aditional parameter p_calling_obj = 'JOB' p_create_warning='N' in the calls to
                             igs_en_elgbl_person.eval_person_steps
			     Modified to pass aditional parameter p_calling_obj='JOB' in the calls to
			     Igs_En_Enroll_Wlst.Validate_unit_steps

******************************************************************/

--cursor to fetch records from interface table
--
CURSOR get_int_dtls (p_batch_id IN NUMBER) IS
SELECT ROWID , int.*
FROM igs_en_reg_upd_int int
WHERE int.batch_id = p_batch_id
FOR UPDATE NOWAIT ;

-- cursor to fetch person_id
--
CURSOR get_person_number (p_person_number IN VARCHAR2 ) IS
SELECT pe.person_id
FROM igs_pe_person_base_v pe
WHERE pe.person_number = p_person_number;

-- cursor to validate course_cd
--
CURSOR get_course_cd(p_course_cd IN VARCHAR2) IS
SELECT 'x'
FROM igs_ps_ver ps
WHERE ps.course_cd = p_course_cd ;

-- cursor to get Academic Calendar Details
--
CURSOR get_acad_cal_dtls ( p_alternate_code IN VARCHAR2) IS
SELECT ca.cal_type , ca.sequence_number , ca.start_dt , ca.end_dt
FROM igs_ca_inst ca
WHERE ca.alternate_code = p_alternate_code;

-- Cursor to check if multiple matches are found for a given Altenate Code .
--
CURSOR get_acad_cnt( p_alternate_code IN VARCHAR2) IS
SELECT COUNT(*)
FROM igs_ca_inst ca
WHERE ca.alternate_code = p_alternate_code;

--cursor to get all INACTIVE program attempts
--
CURSOR get_prgm_dtls (p_course_cd IN VARCHAR2 , p_cal_type IN VARCHAR2 , p_person_id IN NUMBER) IS
SELECT sca.course_cd , sca.version_number , sca.cal_type,sca.course_attempt_status
FROM igs_en_stdnt_ps_att_all sca
WHERE sca.course_cd = NVL(p_course_cd,sca.course_cd) AND
      sca.course_attempt_status IN ('INACTIVE','ENROLLED') AND
      sca.cal_type = p_cal_type AND
      sca.person_id = p_person_id ;


-- cursor to get all Load Calendar instances for a given Academic Calendar.
--
CURSOR get_load_cal_inst (p_acad_cal_type IN VARCHAR2 , p_acad_ci_sequence_number IN NUMBER ,
			  p_start_dt IN DATE , p_end_dt IN DATE )IS
SELECT   ci.cal_type ,  ci.start_dt ,  ci.end_dt ,  ci.sequence_number
FROM   igs_ca_inst ci ,  igs_ca_type ct , igs_ca_stat cs , igs_ca_inst_rel cir
WHERE   ct.cal_type = ci.cal_type
AND ct.s_cal_cat = 'LOAD'
AND cir.sup_cal_type  = p_acad_cal_type
AND cir.sup_ci_sequence_number = p_acad_ci_sequence_number
AND cir.sub_cal_type  = ci.cal_type
AND cir.suB_ci_sequence_number = ci.sequence_number
AND ci.cal_status = cs. cal_status
AND cs.s_cal_status = 'ACTIVE'
AND ci.start_dt >= p_start_dt
AND ci.end_dt <= p_end_dt;

-- cursor to get all Unit Attempts whose Teaching Calendar fall within the given Load Calendar
--
CURSOR get_sua (p_person_id IN NUMBER , p_course_cd IN VARCHAR2, p_load_cal_type IN VARCHAR2 , p_load_ci_sequence_number IN NUMBER ) IS
SELECT sua.uoo_id , sua.unit_cd , sua.version_number , sua.cal_type , sua.ci_sequence_number
FROM igs_en_su_attempt_all sua , igs_ca_load_to_teach_v calt
where sua.unit_attempt_status = 'UNCONFIRM'
AND sua.course_cd = p_course_cd
AND sua.cal_type = calt.teach_cal_type
AND sua.person_id = p_person_id
AND sua.ci_sequence_number = calt.teach_ci_sequence_number
AND calt.load_cal_type = p_load_cal_type
AND calt.load_ci_sequence_number = p_load_ci_sequence_number
ORDER BY sua.sup_unit_cd DESC;


--cursor to get SUA Administrative details
--
CURSOR get_as_sc_atmpt_enr (p_start_dt IN DATE , p_end_dt IN DATE , p_person_id IN NUMBER , p_course_cd IN VARCHAR2)IS
SELECT asa.ROWID , asa.*
FROM  igs_as_sc_atmpt_enr asa , igs_ca_inst ci
WHERE ci.start_dt >= p_start_dt  AND ci.end_dt <=  p_end_dt
AND asa.cal_type = ci.cal_type
AND asa.ci_sequence_number = ci.sequence_number
AND asa.course_cd = p_course_cd
AND asa.person_id = p_person_id
FOR UPDATE NOWAIT ;


-- cursor to get SUA records to update Enrollment Date.
--
CURSOR get_sua_upd ( p_person_id IN NUMBER,p_course_cd IN VARCHAR, p_uoo_id IN NUMBER  ) IS
SELECT sua.ROWID , sua.*
FROM igs_en_su_attempt_all sua
WHERE sua.person_id = p_person_id
AND sua.course_cd =  p_course_cd
AND sua.uoo_id = p_uoo_id
FOR UPDATE NOWAIT ;


--Declare all local variables .
--
l_course_cd_chk VARCHAR2(1);
l_reg_update_int_rec igs_en_reg_upd_int%ROWTYPE;
l_person_id igs_pe_person.person_id%TYPE;
l_cnt NUMBER ;
l_message_name VARCHAR2(2000) := NULL;

l_message_text VARCHAR2(2000) := NULL ;
l_message igs_en_reg_upd_int.errors%TYPE := NULL ;
l_deny_warn  igs_en_cpd_ext.notification_flag%TYPE;

l_prgm_inactive_chk VARCHAR2(1) := 'N';

l_acad_cal_type igs_ca_type.cal_type%TYPE;
l_acad_ci_Sequence_number igs_ca_inst.sequence_number%TYPE;
l_acad_cal_Start_dt igs_ca_inst.start_dt%TYPE;
l_acad_cal_end_dt igs_ca_inst.end_dt%TYPE;
l_load_cal_type igs_ca_type.cal_type%TYPE;
l_load_ci_Sequence_number igs_ca_inst.sequence_number%TYPE;
l_teach_cal_type igs_ca_type.cal_type%TYPE;
l_teach_ci_Sequence_number igs_ca_inst.sequence_number%TYPE;

l_error_status VARCHAR2(1);
l_course_cd igs_en_stdnt_ps_att_all.course_cd%TYPE;
l_course_version_number igs_en_stdnt_ps_att_all.version_number%TYPE;
l_del_int_rec VARCHAR2(1) := 'Y';

l_return_status VARCHAR2(10) ;
l_prgm_val_pass VARCHAR2(1) := 'N' ;
l_prgm_val_int_pass  VARCHAR2(1) := 'N' ;
l_unit_val_pass VARCHAR2(1) := 'N' ;
l_uoo_ids VARCHAR2(2000) := NULL;
l_unitcd_and_uooid_str VARCHAR2(3000) := NULL;
l_pass_uoo_ids VARCHAR2(2000) := NULL;
l_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE := NULL;
l_get_sua_upd_rec get_sua_upd%ROWTYPE;
l_boolean BOOLEAN := TRUE;

l_creation_date         igs_en_reg_upd_int.creation_date%TYPE;
l_last_update_date      igs_en_reg_upd_int.last_update_date%TYPE;
l_created_by            igs_en_reg_upd_int.created_by%TYPE;
l_last_updated_by       igs_en_reg_upd_int.last_updated_by%TYPE;
l_last_update_login     igs_en_reg_upd_int.last_update_login%TYPE;
l_request_id            igs_en_reg_upd_int.request_id%TYPE;
l_program_id            igs_en_reg_upd_int.program_id%TYPE;
l_program_application_id igs_en_reg_upd_int.program_application_id%TYPE;
l_program_update_date   igs_en_reg_upd_int.program_update_date%TYPE;

-- added by ckasu as a part of bug 3823810
l_enrolment_cat                 IGS_PS_TYPE.ENROLMENT_CAT%TYPE;
l_processed                     BOOLEAN;
l_dummy                         VARCHAR2(100);

l_commencement_type             VARCHAR2(20) DEFAULT NULL;
l_en_cal_type                   IGS_CA_INST.CAL_TYPE%TYPE;
l_en_ci_seq_num                 IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
l_person_type                   IGS_PE_PERSON_TYPES.person_type_code%TYPE;
l_sua_rec                       get_sua%ROWTYPE;



PROCEDURE log_error_message(
                            p_message_name    VARCHAR2,
                            p_del                 VARCHAR2) AS

/******************************************************************
Created By        : RVIVEKAN
Date Created By   : 3-aug-03
Purpose           : To Split the concatenated error messages and log them separately
Change History
Who      When        What

******************************************************************************/
l_messages      VARCHAR2(2000) := p_message_name;
l_mesg_name     VARCHAR2(2000);
l_mesg_txt      VARCHAR2(2000);
l_msg_len       NUMBER ;
l_msg_token     VARCHAR2(100);
l_str_place     NUMBER(3);
BEGIN --log_error_message

     IF SUBSTR(l_messages,1,1) = p_del THEN
        l_messages := SUBSTR(l_messages,2);
     END IF;
     IF SUBSTR(l_messages,-1,1) <> p_del THEN
        l_messages := l_messages||p_del;
     END IF;
     l_mesg_name := NULL;
     l_msg_len:= LENGTH(l_messages);
     FOR i IN 1 .. l_msg_len
     LOOP
         IF SUBSTR(l_messages,i,1) = p_del THEN
         --Following codes checks whether message has token or not.
         --If any call to igs_ss_en_wrappers results in a exception
         --Then l_mesg_name contains the exception text and should not be translated
         --Message texts are generally more than 30 chars and even if they are less
         --than 30 chars, fnd_message returns the same text if it cant find a match.
         --If messages larger than 30 chars (max size if msg_name field) are passed to
         --fnd_message, an plsql exception is thrown.Hence the check for 30 characters size.
         IF LENGTH(l_mesg_name)<=30 THEN
           l_str_place :=INSTR(l_mesg_name,'*');
           IF l_str_place <> 0 THEN
              l_msg_token:= SUBSTR(l_mesg_name,l_str_place+1);
              l_mesg_name:= SUBSTR(l_mesg_name,1,l_str_place-1);
              fnd_message.set_name('IGS',l_mesg_name);
              fnd_message.set_token('UNIT_CD',l_msg_token);
           ELSE
              fnd_message.set_name('IGS',l_mesg_name);
           END IF;
           l_mesg_txt:=fnd_message.get;
         ELSE
           l_mesg_txt:=l_mesg_name;
         END IF; --30 character message name

		Fnd_File.PUT_LINE(Fnd_File.LOG,l_mesg_txt);
             l_mesg_name := NULL;
         ELSE
            l_mesg_name := l_mesg_name||SUBSTR(l_messages,i,1);
         END IF;
     END LOOP;
END log_error_message;

PROCEDURE log_regid_person_dtls(p_regid NUMBER,
                                p_person_number VARCHAR2,
                                p_load_cal_type VARCHAR2,
                                p_load_seq_number NUMBER) AS

/******************************************************************
Created By        : CKASU
Date Created By   : 23-SEP-04
Purpose           : To Log the Registration id and Person number in Log file before
                    the message whenever a person fails in Deny all holds or Person
                    Validations steps or Unit validation steps.
Change History
Who      When        What
ckasu   29-SEP-2004 added parameters p_load_cal_type,p_load_seq_number
                    inorder to print Load cal details

******************************************************************************/
l_regid_person_dtls VARCHAR2(1000);

BEGIN

      Fnd_Message.SET_NAME ('IGS','IGS_EN_REG_LOG_REG');
      l_regid_person_dtls := fnd_message.get || ' : ' || p_regid || '   ';
      Fnd_Message.SET_NAME ('IGS','IGS_PR_PERSON_ID');
      l_regid_person_dtls := l_regid_person_dtls || fnd_message.get || ' : ' || p_person_number || '   ';

      FND_MESSAGE.SET_NAME('IGS','IGS_FI_CAL_BALANCES_LOG');
      FND_MESSAGE.SET_TOKEN('PARAMETER_NAME','LOAD CAL ');
      FND_MESSAGE.SET_TOKEN('PARAMETER_VAL' ,p_load_cal_type||'*'||p_load_seq_number) ;

      l_regid_person_dtls := l_regid_person_dtls || fnd_message.get;
      Fnd_File.PUT_LINE(Fnd_File.LOG,l_regid_person_dtls);

END  log_regid_person_dtls;

--
-- Logic of the below procedure is briefly explained below
--
-- 1. If all Program Attempts and Unit Attempts fail the validations,
-- the interface table is updated with an error message . None of the OSS tables are updated .
-- 2. If atleast one Program Attempt pass the validation and One or more Unit Attempts fail the validations , the interface
-- table is updated with a warning message.  The details of Program / Unit Attempts that have passed the validations are
-- updated in the OSS tables.
-- 3. If all Program and Unit validations are passed , the record is deleted from the Interface Table. The details of Program/
-- Unit Attempts that have passed the validations are updated in the OSS tables.
--
-- l_prgm_inactive_chk ::  This variable is set to 'N' for every record in the interface table , indicating that
-- No Inactive Program Attempts have been found. If an INACTIVE Program Attempt is found , this variable is set to Y.
--
-- l_del_int_rec :: This variable is set to 'Y' for every interface record. When a Unit step / Program Step
-- Validation Fails , the value is set to 'N' , indicating that the record in the interface table should not be deleted.
--
-- l_prgm_val_int_pass :: This variable is set to 'N' indicating that none of the Program Step Valdns have passed . If
-- atleast one Prgm Step valdn is passed , the value is set to 'Y'. Reset at the interface record level.
--
-- l_unit_val_pass :: This initial value of the variable is set to 'Y'.If one or more Unit Step valdn fail, the value
-- is set to 'N'.Reset at the interface record level.This variable is used to determine if Warning / Error message should
-- be shown to the user.
--
-- l_prgm_val_pass :: This variable is set to 'N' at the start of every Program loop , indicating that the Program
-- has not passed the validation. When the Prgm passes the validation , this variable is set to Y. Based on the value of
-- l_prgm_val_pass, the Administrative Unit records are updated for that Program
--
-- If l_prgm_val_int_pass = Y and l_prgm_val_int_pass = N , it indicates that atleast one Program has passed all rge
-- validations , and the record has been successfully updated. Warning message is shown to the user.
--
-- If l_prgm_val_int_pass = N , none of the Programs have passed the valdn , and hence Error message is shown to the user.
--
--


BEGIN

   l_creation_date := SYSDATE;
   l_created_by := FND_GLOBAL.USER_ID;
   l_last_update_date := SYSDATE;
   l_last_updated_by := FND_GLOBAL.USER_ID;
   l_last_update_login :=FND_GLOBAL.LOGIN_ID;

   IF l_created_by IS NULL THEN
       l_created_by := -1;
   END IF;

   IF l_last_updated_by IS NULL THEN
       l_last_updated_by := -1;
   END IF;

   IF l_last_update_login IS NULL THEN
       l_last_update_login := -1;
   END IF;

   l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
   l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
   l_program_application_id := FND_GLOBAL.PROG_APPL_ID;

   IF (l_request_id = -1) THEN
        l_request_id := NULL;
        l_program_id := NULL;
        l_program_application_id := NULL;
        l_program_update_date := NULL;
   ELSE
        l_program_update_date := SYSDATE;
   END IF;


-- Process all the records that match the batch_id

FOR l_reg_update_int_rec IN get_int_dtls (p_batch_id)
LOOP

BEGIN

   SAVEPOINT interface_rec;
   l_message_text := NULL;
   l_message := NULL;
   l_del_int_rec  := 'Y';
   l_prgm_val_int_pass  := 'N' ;
   l_unit_val_pass := 'Y';
   l_prgm_inactive_chk := 'N';

   --Validate Person Number
   OPEN get_person_number (l_reg_update_int_rec.person_number ) ;

   FETCH get_person_number into l_person_id ;
   IF get_person_number%NOTFOUND THEN

	   FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_PERSON_NUMBER');
	   l_message := FND_MESSAGE.GET;
	   l_message_text := l_message ;

   END IF ;
   CLOSE get_person_number ;

   -- Validate Program Code
   IF l_reg_update_int_rec.course_cd IS NOT NULL THEN
	   OPEN get_course_cd(l_reg_update_int_rec.course_cd );
	   FETCH get_course_cd into l_course_cd_chk;
	   IF get_course_cd%NOTFOUND THEN

		   FND_MESSAGE.SET_NAME('IGS','IGS_PR_INVALID_PRG_CD');
		   l_message := FND_MESSAGE.GET;

		   IF l_message_text IS NOT NULL THEN
			l_message_text := l_message_text || ';' || l_message ;
		   ELSE
			l_message_text := l_message ;
		   END IF;

	   END IF ;
	   CLOSE get_course_cd ;
   END IF;

   -- Validate Academic Calendar
   OPEN get_acad_cnt  (l_reg_update_int_rec.alternate_code);
   FETCH get_acad_cnt  INTO l_cnt;
   CLOSE get_acad_cnt  ;

   -- If NO matching Academic Cal is found , or if multiple matches are found , error out.
   IF l_cnt > 1 OR l_cnt = 0 THEN

	   FND_MESSAGE.SET_NAME('IGS','IGS_EN_INVLD_ACA_CD');
	   l_message := FND_MESSAGE.GET;

	   IF l_message_text IS NOT NULL THEN
		l_message_text := l_message_text || ';' || l_message ;
	   ELSE
		l_message_text := l_message ;
	   END IF;

   ELSE
	OPEN get_acad_cal_dtls (l_reg_update_int_rec.alternate_code);
	FETCH get_acad_cal_dtls INTO l_acad_cal_type,l_acad_ci_Sequence_number,l_acad_cal_Start_dt, l_acad_cal_end_dt  ;
	CLOSE get_acad_cal_dtls ;

   END IF ;

    -- If any of the parameters have failed the validation , stop further processing for the record.
   IF l_message_text IS NOT  NULL  THEN
	-- Update the record with error messages in the  interface table.
	UPDATE igs_en_reg_upd_int  SET errors = l_message_text ,
        creation_date      = l_creation_date     ,
        last_update_date   = l_last_update_date  ,
        created_by         = l_created_by        ,
        last_updated_by    = l_last_updated_by   ,
        last_update_login  = l_last_update_login ,
        request_id         =       l_request_id            ,
        program_id         =       l_program_id            ,
        program_application_id =   l_program_application_id,
        program_update_date     =  l_program_update_date
    WHERE ROWID = l_reg_update_int_rec.ROWID ;

   END IF ;

   IF l_message_text is NULL THEN

     -- Get all Program attempts of status INACTIVE
     FOR l_prgm_dtls_rec IN get_prgm_dtls ( NVL(l_reg_update_int_rec.course_cd , NULL) , l_acad_cal_type , l_person_id)
     LOOP

	l_prgm_inactive_chk := 'Y';
	l_prgm_val_pass := 'N' ;

	--
	-- Process the Program Attempts. The value is defaulted at the start of processing. If any of the validations fail , it is set to 'N'.
	-- Loop for all Load Calendar Instances that fall bet. the Acad Cal Start and End dates.
	--
	FOR l_get_load_cal_inst_rec IN get_load_cal_inst ( l_acad_cal_type , l_acad_ci_Sequence_number ,l_acad_cal_Start_dt ,l_acad_cal_end_dt )
	LOOP

        OPEN get_sua(l_person_id , l_prgm_dtls_rec.course_cd ,l_get_load_cal_inst_rec.cal_type ,l_get_load_cal_inst_rec.sequence_number) ;
        FETCH get_sua INTO l_sua_rec;
        IF get_sua%FOUND THEN
         CLOSE get_sua;

	 BEGIN

	    SAVEPOINT load_prgm_rec ;
	    l_uoo_ids := NULL;
            l_unitcd_and_uooid_str := NULL;
-- added by ckasu as a part of bug 3823810
            l_person_type := Igs_En_Gen_008.enrp_get_person_type(p_course_cd =>NULL);
-- Determine the Enrollment method , Enrollment Commencement type.
            l_dummy := NULL;
            l_deny_warn := NULL;
            l_processed := TRUE;
            l_enrolment_cat:=IGS_EN_GEN_003.Enrp_Get_Enr_Cat(p_person_id                =>l_person_id,
                                                             p_course_cd                =>l_prgm_dtls_rec.course_cd,
                                                             p_cal_type                 =>l_acad_cal_type,
                                                             p_ci_sequence_number       =>l_acad_ci_Sequence_number,
                                                             p_session_enrolment_cat    =>NULL,
                                                             p_enrol_cal_type           =>l_en_cal_type,
                                                             p_enrol_ci_sequence_number =>l_en_ci_seq_num,
                                                             p_commencement_type        =>l_commencement_type,
                                                             p_enr_categories           =>l_dummy);



           -- deny all hold validation added as part of Bug 3823810
           -- when l_deny_warn equals 'E' then person steps are not validated.
	    igs_en_elgbl_person.eval_ss_deny_all_hold (
							p_person_id	=>l_person_id,
							p_person_type	=>l_person_type,
							p_course_cd	=>l_prgm_dtls_rec.course_cd,
							p_load_calendar_type	=>l_get_load_cal_inst_rec.cal_type,
							p_load_cal_sequence_number =>l_get_load_cal_inst_rec.sequence_number,
							p_status	=>l_deny_warn,
							p_message	=>l_message_name);


            IF l_deny_warn='E' THEN --deny all hold validation
			l_processed := FALSE;
                        log_regid_person_dtls(l_reg_update_int_rec.registration_id,l_reg_update_int_rec.person_number,l_get_load_cal_inst_rec.cal_type,l_get_load_cal_inst_rec.sequence_number);
			log_error_message(l_message_name,';');
	    END IF;
            --person steps not validated when deny all hold fails added for Bug 3823810
	    l_message_name :=NULL;
	    l_deny_warn := NULL;

           --Following function will do the all person step validations for the context person.
           --when person validations are passed successfully then Unit step validations are done
           --l_processed set to FALSE when any one of person steps for a context person evaluates
           --to FALSE.
            IF l_processed THEN
	      IF NOT igs_en_elgbl_person.eval_person_steps( p_person_id               =>l_person_id,
                                                          p_person_type               =>l_person_type,
                                                          p_load_calendar_type        =>l_get_load_cal_inst_rec.cal_type,
                                                          p_load_cal_sequence_number  =>l_get_load_cal_inst_rec.sequence_number,
                                                          p_program_cd                =>l_prgm_dtls_rec.course_cd,
                                                          p_program_version           =>l_prgm_dtls_rec.version_number,
                                                          p_enrollment_category       =>l_enrolment_cat,
                                                          p_comm_type                 =>l_commencement_type,
                                                          p_enrl_method               =>p_enroll_mtd_type,
                                                          p_message                   =>l_message_name,
                                                          p_deny_warn                 =>l_deny_warn,
							  p_calling_obj               =>'JOB',
							  p_create_warning            =>'N') THEN
                 --function returns the error then log all the error message and abort the further processing for the context person.
                 log_regid_person_dtls(l_reg_update_int_rec.registration_id,l_reg_update_int_rec.person_number,l_get_load_cal_inst_rec.cal_type,l_get_load_cal_inst_rec.sequence_number);
                 log_error_message(l_message_name,';');
                 l_processed := FALSE;
                 l_del_int_rec := 'N';

              ELSE
                IF l_message_name IS NOT NULL AND l_deny_warn = 'WARN' THEN
                        log_regid_person_dtls(l_reg_update_int_rec.registration_id,l_reg_update_int_rec.person_number,l_get_load_cal_inst_rec.cal_type,l_get_load_cal_inst_rec.sequence_number);
   	        	log_error_message(l_message_name,';');

                END IF;
              END IF; --NOT igs_en_elgbl_person.eval_person_steps
	   END IF;


          -- Process all Units for a given Program .

          -- when all Person steps steps are passed then Unit step validations are done.
          IF  l_processed THEN
            FOR l_get_sua_rec IN get_sua (l_person_id , l_prgm_dtls_rec.course_cd ,l_get_load_cal_inst_rec.cal_type ,l_get_load_cal_inst_rec.sequence_number)
		LOOP

                l_message_name:=NULL;
 		-- Call the Unit validation steps for each of the unit records that has been fetched.
		l_boolean := igs_en_enroll_wlst.validate_unit_steps  (p_person_id => l_person_id ,
                                 p_cal_type		 => l_get_load_cal_inst_rec.cal_type,
                                 p_ci_sequence_number	 => l_get_load_cal_inst_rec.sequence_number,
                                 p_uoo_id		 => l_get_sua_rec.uoo_id ,
                                 p_course_cd		 => l_prgm_dtls_rec.course_cd ,
                                 p_enr_method_type	 => p_enroll_mtd_type ,
                                 p_message_name		 => l_message_name ,
                                 p_deny_warn		 => l_deny_warn,
				                 p_calling_obj           => 'JOB'
                                 ) ;

              IF l_message_name IS NOT NULL THEN
                log_regid_person_dtls(l_reg_update_int_rec.registration_id,l_reg_update_int_rec.person_number,l_get_load_cal_inst_rec.cal_type,l_get_load_cal_inst_rec.sequence_number);
		log_error_message(l_message_name,';');
	      END IF;


		IF NOT l_boolean AND l_deny_warn = 'DENY' then
			l_unit_val_pass := 'N';
			l_del_int_rec := 'N';
		ELSE
			-- Concatenate the uoo_id of the Unit section that passed the validations.
                        -- l_unitcd_and_uooid_str contains unit_cd*uoo_id delimted by comma inorder
                        -- to print unit information on log file as a prt of bug#4095276
			IF l_uoo_ids IS NULL THEN
				l_uoo_ids := l_get_sua_rec.uoo_id ;
                                l_unitcd_and_uooid_str := l_get_sua_rec.unit_cd || '*' || l_get_sua_rec.uoo_id;
			ELSE
				l_uoo_ids := l_uoo_ids || ',' || l_get_sua_rec.uoo_id;
                                l_unitcd_and_uooid_str := l_unitcd_and_uooid_str || ',' || l_get_sua_rec.unit_cd || '*' || l_get_sua_rec.uoo_id;
			END IF ;
		END IF;

            END LOOP; -- All SUA records for a Program.
         END IF; -- end of If l_processed


	    IF l_uoo_ids IS NOT NULL THEN

                       --code added by ckasu as apart of bug#4095276
                       --validate if this program is a primary/secondary in this term
                       -- if it is secondary then show a warning asking the user to update the stored transfer to include the newly enrolled
                       -- unit attempts in the transfer.
                       IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'Y' AND
                          igs_en_spa_terms_api.get_spat_primary_prg(l_person_id,
                                                                    l_prgm_dtls_rec.course_cd ,
                                                                    l_get_load_cal_inst_rec.cal_type,
                                                                    l_get_load_cal_inst_rec.sequence_number ) = 'SECONDARY'
                       THEN
                                log_regid_person_dtls(l_reg_update_int_rec.registration_id,l_reg_update_int_rec.person_number,
                                l_get_load_cal_inst_rec.cal_type,l_get_load_cal_inst_rec.sequence_number);
                                fnd_message.set_name('IGS','IGS_EN_UPD_FUT_TRANS');
                                fnd_message.set_token('COURSE_CD',l_prgm_dtls_rec.course_cd);
                                fnd_message.set_token('UNIT_CD',l_unitcd_and_uooid_str);
                                fnd_file.put_line(fnd_file.log, fnd_message.get);
                        END IF ; -- end of igs_en_spa_terms_api.get_spat_primary_prg
                        --end of code added by ckasu as apart of bug#4095276

                        l_message_name:=NULL;
			BEGIN

                          igs_ss_en_wrappers.Validate_enroll_validate (
			      p_person_id		    => l_person_id ,
			      p_load_cal_type		    => l_get_load_cal_inst_rec.cal_type,
			      p_load_ci_sequence_number	    => l_get_load_cal_inst_rec.sequence_number,
			      p_uoo_ids			    => l_uoo_ids ,
			      p_program_cd	            => l_prgm_dtls_rec.course_cd ,
			      p_message_name		    => l_message_name ,
			      p_deny_warn	            => l_deny_warn ,
			      p_return_status		    => l_return_status,
                              p_enr_method                  => p_enroll_mtd_type,
                              p_enrolled_dt                 => SYSDATE);
                        EXCEPTION WHEN OTHERS THEN
                          IF IGS_GE_MSG_STACK.COUNT_MSG <> 0 THEN
                            l_message_name := FND_MESSAGE.GET;
                          ELSE
                            l_message_name := SQLERRM;
                          END IF;
                            l_deny_warn      := 'DENY';
                            l_return_status  := 'FALSE';
                        END;
		      IF l_message_name IS NOT NULL THEN
			log_error_message(l_message_name,';');
		      END IF;

		      IF l_return_status = 'FALSE' THEN
			l_del_int_rec := 'N';
			ROLLBACK TO load_prgm_rec;

		      ELSE
			l_prgm_val_pass := 'Y'	;
			l_prgm_val_int_pass := 'Y';
			l_load_cal_type :=  l_get_load_cal_inst_rec.cal_type ;
		        l_load_ci_Sequence_number := l_get_load_cal_inst_rec.sequence_number ;

			-- Update the Enrolled_date of all the Unit Attempts that have passed the Unit step validation
			l_pass_uoo_ids := l_uoo_ids;

			WHILE l_pass_uoo_ids IS NOT NULL LOOP
			      IF(instr(l_pass_uoo_ids,',',1) = 0) THEN
			        l_uoo_id := TO_NUMBER(l_pass_uoo_ids);
			      ELSE
			        l_uoo_id := TO_NUMBER(substr(l_pass_uoo_ids,0,instr(l_pass_uoo_ids,',',1)-1)) ;
			      END IF;

			      OPEN get_sua_upd(l_person_id ,  l_prgm_dtls_rec.course_cd, l_uoo_id);
			      FETCH get_sua_upd INTO l_get_sua_upd_rec;
			      CLOSE get_sua_upd ;
			      UPDATE IGS_EN_SU_ATTEMPT_ALL SET ENROLLED_DT = l_reg_update_int_rec.enr_form_received_dt WHERE ROWID = l_get_sua_upd_rec.ROWID;
			      IF(instr(l_pass_uoo_ids,',',1) = 0) THEN
                                 l_pass_uoo_ids := NULL;
			      ELSE
                                 l_pass_uoo_ids := substr(l_pass_uoo_ids,instr(l_pass_uoo_ids,',',1)+1);
			      END IF;
			END LOOP;

		      END IF;
	    ELSE
		      -- If No UOO_IDS are found for the given Program
		      l_del_int_rec := 'N';
		      ROLLBACK TO load_prgm_rec;
	    END IF ;

	    -- IF an Exception is encountered while processing a Program , skip the Program - Proceed with processing the next Program.
	    --
	    EXCEPTION
		        WHEN OTHERS THEN
                        l_del_int_rec := 'N';
			ROLLBACK TO load_prgm_rec ;
			FND_MESSAGE.SET_NAME('IGS','IGS_EN_PGM_STP_FAIL');
			l_message_text := l_message_text || ',' || FND_MESSAGE.GET;
			UPDATE igs_en_reg_upd_int
                            SET errors = l_message_text ,
                                creation_date      = l_creation_date     ,
                                last_update_date   = l_last_update_date  ,
                                created_by         = l_created_by        ,
                                last_updated_by    = l_last_updated_by   ,
                                last_update_login  = l_last_update_login ,
                                request_id         =       l_request_id            ,
                                program_id         =       l_program_id            ,
                                program_application_id =   l_program_application_id,
                                program_update_date     =  l_program_update_date
                            WHERE ROWID = l_reg_update_int_rec.ROWID ;
	END ;

       ELSE -- if no unit attempts exists for the Load Calendar in context
        CLOSE get_sua;
       END IF;

      END LOOP; -- All Load Calendars for a given Teach Calendar

	IF l_prgm_val_pass = 'Y' AND l_prgm_dtls_rec.course_attempt_status='INACTIVE' THEN

		FOR l_as_sc_atmpt_enr_rec IN get_as_sc_atmpt_enr ( l_acad_cal_Start_dt ,l_acad_cal_end_dt ,l_person_id , l_prgm_dtls_rec.course_cd )
		LOOP

			-- Update all Administrative Program Details for the Programs that passed the validations.
			igs_as_sc_atmpt_enr_pkg .update_row (
			  X_ROWID		=> l_as_sc_atmpt_enr_rec.ROWID,
			  x_person_id		=> l_as_sc_atmpt_enr_rec.person_id,
			  x_course_cd		=> l_as_sc_atmpt_enr_rec.course_cd,
			  x_cal_type		=> l_as_sc_atmpt_enr_rec.cal_type,
			  x_ci_sequence_number	=> l_as_sc_atmpt_enr_rec.ci_sequence_number,
			  x_enrolment_cat	=> l_as_sc_atmpt_enr_rec.enrolment_cat,
			  x_enrolled_dt		=> l_reg_update_int_rec.enr_form_received_dt,
			  x_enr_form_due_dt	=> l_as_sc_atmpt_enr_rec.enr_form_due_dt ,
			  x_enr_pckg_prod_dt	=> l_as_sc_atmpt_enr_rec.enr_pckg_prod_dt ,
			  x_enr_form_received_dt => l_reg_update_int_rec.enr_form_received_dt ,
			  x_mode =>  'R'  );

		END LOOP ; 	-- All matching SPA Administration records.
	END IF ;

    END LOOP;     -- All INACTIVE Program Attempts.

   --
   -- If no INACTIVE Program Attempts are found, log the error message and start processing the next record.
   IF l_prgm_inactive_chk = 'N'
   THEN
	   -- Update the records with error message in the interface table
	   FND_MESSAGE.SET_NAME('IGS','IGS_EN_INACT_PGM');
	   l_message_text := FND_MESSAGE.GET;
	   UPDATE igs_en_reg_upd_int
       SET errors = l_message_text ,
        creation_date      = l_creation_date     ,
        last_update_date   = l_last_update_date  ,
        created_by         = l_created_by        ,
        last_updated_by    = l_last_updated_by   ,
        last_update_login  = l_last_update_login ,
        request_id         =       l_request_id            ,
        program_id         =       l_program_id            ,
        program_application_id =   l_program_application_id,
        program_update_date     =  l_program_update_date
       WHERE ROWID = l_reg_update_int_rec.ROWID ;

   --
   -- Update FAIL error messages for records that failed all validations.
   ELSIF l_del_int_rec = 'N' AND l_prgm_val_int_pass = 'N'
   THEN
	   FND_MESSAGE.SET_NAME('IGS','IGS_EN_PGM_STP_FAIL');
	   l_message_text :=  FND_MESSAGE.GET;
	   UPDATE igs_en_reg_upd_int
       SET errors = l_message_text ,
        creation_date      = l_creation_date     ,
        last_update_date   = l_last_update_date  ,
        created_by         = l_created_by        ,
        last_updated_by    = l_last_updated_by   ,
        last_update_login  = l_last_update_login ,
        request_id         =       l_request_id            ,
        program_id         =       l_program_id            ,
        program_application_id =   l_program_application_id,
        program_update_date     =  l_program_update_date
       WHERE ROWID = l_reg_update_int_rec.ROWID ;

   --
   -- Update WARN error messages for records that partially passed the validations.
   ELSIF  l_del_int_rec = 'N' AND l_prgm_val_int_pass = 'Y' AND  l_unit_val_pass = 'N'
   THEN
   	   FND_MESSAGE.SET_NAME('IGS','IGS_EN_PGM_STP_WARN');
	   l_message_text :=  FND_MESSAGE.GET;
	   UPDATE igs_en_reg_upd_int
       SET errors = l_message_text ,
        creation_date      = l_creation_date     ,
        last_update_date   = l_last_update_date  ,
        created_by         = l_created_by        ,
        last_updated_by    = l_last_updated_by   ,
        last_update_login  = l_last_update_login ,
        request_id         =       l_request_id            ,
        program_id         =       l_program_id            ,
        program_application_id =   l_program_application_id,
        program_update_date     =  l_program_update_date
       WHERE ROWID = l_reg_update_int_rec.ROWID ;

   --
   -- Delete all the records that have been succesfully processed .
   ELSIF l_del_int_rec ='Y'
   THEN
	DELETE FROM igs_en_reg_upd_int
	WHERE ROWID = l_reg_update_int_rec.ROWID;

   END IF ;
   END IF;

   --
   -- If an unhandled exception is raised while processing a record of the Interface table, the error message
   -- should be updated in the interface table, and processing should continue for the next record.
 EXCEPTION
        WHEN OTHERS THEN
                ROLLBACK TO interface_rec;
		l_message_text := FND_MESSAGE.GET;
                Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_016.enrp_batch_reg_upd');
		l_message_text := l_message_text || ',' || FND_MESSAGE.GET;
		UPDATE igs_en_reg_upd_int
        SET errors = l_message_text ,
        creation_date      = l_creation_date     ,
        last_update_date   = l_last_update_date  ,
        created_by         = l_created_by        ,
        last_updated_by    = l_last_updated_by   ,
        last_update_login  = l_last_update_login ,
        request_id         =       l_request_id            ,
        program_id         =       l_program_id            ,
        program_application_id =   l_program_application_id,
        program_update_date     =  l_program_update_date
        WHERE ROWID = l_reg_update_int_rec.ROWID ;
 END ;

END LOOP; -- All records in inetrface Table
COMMIT;
END enrp_enr_reg_upd ;

PROCEDURE enrp_batch_reg_upd(
errbuf            OUT NOCOPY VARCHAR2,
retcode           OUT NOCOPY NUMBER,
p_batch_id        IN VARCHAR2,
p_enr_method_type IN VARCHAR2
) AS
/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 07-Nov-2002
--
-- Purpose: This job will confirm(Enroll) the unit attempts of all students
-- in the interface table Igs_En_Reg_Upd_Int after successful completion of
-- the unit and program step validations.
-- And also generates the log for all the failed records.
-- If both the batch id and enrollment method type are given then it first
-- process all the records in the interface table igs_en_reg_upd_int for
-- the given batch id and generates the log for failed records.
-- If only batch id is given then only log file of existing failed records
-- will be generated.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who           When               What
--ckasu         14-SEP-2004    added new variable l_later_cnt and modified procedure as
--                             a part of Bug# 3823810
--rvivekan	04-Aug-2003    Bulk unit upload TD bug#3049009. Removed country code validation.
--svenkata      31-DEC-2002    Bug# 2724288 - NO message shown when ran with Invalid data.Wrote a query to check if data exists in the
--                             interface table for a given batch id.
--  ckasu           17-JAN-2006     Added igs_ge_gen_003.set_org_id(NULL) as a part of bug#4958173.
------------------------------------------------------------------  */
--
-- cursor to fetch the batch description
CURSOR cur_batch_desc IS
SELECT batch_description
FROM igs_en_reg_btch_int
WHERE batch_id = p_batch_id;

--
-- cursor to fetch the prefered person ID type
CURSOR cur_pref_per_type IS
SELECT person_id_type
FROM igs_pe_person_id_typ
WHERE preferred_ind = 'Y';

--
-- get the person details
CURSOR cur_person_dtl(p_person_number VARCHAR2) IS
SELECT person_id,full_name
FROM igs_pe_person_base_v
WHERE person_number = p_person_number;

--
-- cursor to fetch value for prefered person id type.
CURSOR cur_alt_pers_id(p_pers_id_type VARCHAR2,p_person_id NUMBER) IS
SELECT api_person_id
FROM igs_pe_alt_pers_id
WHERE person_id_type = p_pers_id_type AND
      pe_person_id = p_person_id;

--
-- cursor to fetch all the students in the interface table whoes records failed to import/update
CURSOR cur_enr_reg_err IS
SELECT registration_id,person_number,course_cd,alternate_code,errors
FROM igs_en_reg_upd_int
WHERE batch_id = p_batch_id AND
      errors IS NOT NULL;

--cursor to fetch records from interface table
--
CURSOR get_int_cnt IS
SELECT count(*)
FROM igs_en_reg_upd_int int
WHERE int.batch_id = p_batch_id ;

l_batch_desc igs_en_reg_btch_int.batch_description%TYPE;
l_pref_per_type igs_pe_person_id_typ.person_id_type%TYPE;
l_person_id igs_pe_person_base_v.person_id%TYPE;
l_full_name igs_pe_person_base_v.full_name%TYPE;
l_alt_pers_id igs_pe_alt_pers_id.api_person_id%TYPE;
l_batch_id_label VARCHAR2(200);
l_batch_desc_label VARCHAR2(200);
l_error_rec VARCHAR2(1):= 'N' ;
l_int_cnt NUMBER := 0;
--added by ckasu
l_later_cnt NUMBER := 0;
--end of addition by ckasu


BEGIN
  --added by ckasu as apart of bug# 4958173
  igs_ge_gen_003.set_org_id(NULL);

  OPEN get_int_cnt ;
  FETCH get_int_cnt INTO l_int_cnt;
  CLOSE get_int_cnt ;

  -- If method type specified then call the procedure to process the records in interface table.
  IF p_enr_method_type IS NOT NULL THEN
     igs_en_gen_016.enrp_enr_reg_upd(p_batch_id,p_enr_method_type);
  END IF;

  --
  -- Start of log file creation
  --

  -- Get the description of the passed in Batch Id
  OPEN cur_batch_desc;
  FETCH cur_batch_desc INTO l_batch_desc;
  CLOSE cur_batch_desc;

  -- Get the prefered person id type
  OPEN cur_pref_per_type;
  FETCH cur_pref_per_type INTO l_pref_per_type;
  CLOSE cur_pref_per_type;

  --
  -- Get the labels for the batch details
  Fnd_Message.SET_NAME ('IGS','IGS_EN_REG_LOG_BATCH');
  l_batch_id_label := fnd_message.get;
  Fnd_Message.SET_NAME ('IGS','IGS_EN_REG_LOG_DESC');
  l_batch_desc_label := fnd_message.get;
  --
  -- log the Batch details into log file
  Fnd_File.PUT_LINE(Fnd_File.LOG,'=============================================================================');
  Fnd_File.PUT_LINE(Fnd_File.LOG,l_batch_id_label||' : '||RPAD(p_batch_id,20,' ')||l_batch_desc_label||' : '||l_batch_desc);
  Fnd_File.PUT_LINE(Fnd_File.LOG,'=============================================================================');

  OPEN get_int_cnt ;
  FETCH get_int_cnt INTO l_later_cnt;
  CLOSE get_int_cnt ;

  IF l_int_cnt = 0 THEN
     Fnd_Message.SET_NAME ('IGS','IGS_EN_NO_DATA_IMP');
     Fnd_File.PUT_LINE(Fnd_File.LOG,fnd_message.get);
     RETURN;
  ELSIF l_later_cnt = l_int_cnt THEN
     Fnd_Message.SET_NAME ('IGS','IGS_EN_NO_DATA_IMP');
     Fnd_File.PUT_LINE(Fnd_File.LOG,fnd_message.get);
  END IF ;

  --
  -- Get all the records in Interface table where 'errors' column has value.
  -- and log the student details and errors in log file.
  --
  FOR cur_enr_reg_err_rec IN cur_enr_reg_err LOOP


	-- Set the variable indicating that error(s) were encountered while processing for the given batch_id
	l_error_rec := 'Y';

      -- Get the person details
      OPEN cur_person_dtl(cur_enr_reg_err_rec.person_number);
      FETCH cur_person_dtl INTO l_person_id,l_full_name;
      CLOSE cur_person_dtl;
      -- Get the alternate person ID for the prefered person ID type
      OPEN cur_alt_pers_id(l_pref_per_type,l_person_id);
      FETCH cur_alt_pers_id INTO l_alt_pers_id;
      CLOSE cur_alt_pers_id;

      Fnd_Message.SET_NAME ('IGS','IGS_EN_REG_LOG_REG');
      Fnd_File.PUT_LINE(Fnd_File.LOG,fnd_message.get||' : '||cur_enr_reg_err_rec.registration_id);
      Fnd_Message.SET_NAME ('IGS','IGS_PR_PERSON_ID');
      Fnd_File.PUT_LINE(Fnd_File.LOG,fnd_message.get||' : '||cur_enr_reg_err_rec.person_number);
      Fnd_Message.SET_NAME ('IGS','IGS_EN_REG_LOG_NAME');
      Fnd_File.PUT_LINE(Fnd_File.LOG,fnd_message.get||' : '||l_full_name);
      Fnd_File.PUT_LINE(Fnd_File.LOG,l_pref_per_type||' : '||l_alt_pers_id);
      Fnd_Message.SET_NAME ('IGS','IGS_EN_REG_LOG_PGM');
      Fnd_File.PUT_LINE(Fnd_File.LOG,fnd_message.get||' : '||cur_enr_reg_err_rec.course_cd);
      Fnd_Message.SET_NAME ('IGS','IGS_EN_REG_LOG_ACAD');
      Fnd_File.PUT_LINE(Fnd_File.LOG,fnd_message.get||' : '||cur_enr_reg_err_rec.alternate_code);
      Fnd_Message.SET_NAME ('IGS','IGS_EN_REG_LOG_ERR');
      Fnd_File.PUT_LINE(Fnd_File.LOG,fnd_message.get||' : '||cur_enr_reg_err_rec.errors);

      Fnd_File.PUT_LINE(Fnd_File.LOG,'-----------------------------------------------------------------------------');

  END LOOP;

  --
  -- Check if the records of the Interface table has been successfully processed and Deleted .
  -- If No error record(s) were found , show this message indicating that all records were processed ,
  -- Data imported into OSS tables and records in Interface Table deleted.
  --
  IF l_error_rec = 'N'  THEN
	Fnd_Message.Set_name('IGS','IGS_EN_REG_UPD_SUCCESS');
	Fnd_File.PUT_LINE(Fnd_File.LOG,fnd_message.get);
	Fnd_File.PUT_LINE(Fnd_File.LOG,'-----------------------------------------------------------------------------');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     retcode:=2;
     Fnd_File.PUT_LINE(Fnd_File.LOG,SQLERRM);
     ERRBUF := Fnd_Message.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
     IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

END enrp_batch_reg_upd;

END igs_en_gen_016;

/
