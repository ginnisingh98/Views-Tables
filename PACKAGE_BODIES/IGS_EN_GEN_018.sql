--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_018
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_018" AS
/* $Header: IGSENA8B.pls 120.5 2006/02/23 05:50:59 ckasu ship $ */


TYPE r_msg_rec IS RECORD(upload_id      igs_en_blk_sua_ints.upload_id%TYPE,
                           type         VARCHAR(1),
                           message      VARCHAR2(2000));

TYPE l_msg_tab IS TABLE OF r_msg_rec INDEX BY BINARY_INTEGER;
l_message_table         l_msg_tab;
l_msg_rec_ind           INTEGER :=0;




FUNCTION enrpl_get_msg (p_message_in IN VARCHAR2)
-----------------------------------------------------------------------------------
--Created by  : rvivekan ( Oracle IDC)
--Date created: 12-AUG-2003
--
--Purpose:  This functions accepts semicoln separated concatenated message names and
--          returns a semicolon separated concatenated messages string
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------------------------
RETURN VARCHAR2 AS
l_return_msg    VARCHAR2(2000) :=NULL;
p_messages      VARCHAR2(2000) :=p_message_in;
l_mesg_name     VARCHAR2(2000) :=NULL;
l_mesg_text     VARCHAR2(2000) :=NULL;
l_msg_token     VARCHAR2(2000) :=NULL;
l_msg_len       INTEGER;
l_str_place     INTEGER;
cst_delimiter   VARCHAR2(1):=';' ;

BEGIN
  IF SUBSTR(p_messages,1,1) = cst_delimiter THEN
    p_messages := SUBSTR(p_messages,2);
  END IF;
  IF SUBSTR(p_messages,-1,1) <> cst_delimiter THEN
    p_messages := p_messages||cst_delimiter;
  END IF;
  l_mesg_name := NULL;
  l_msg_len:= LENGTH(p_messages);
  FOR i IN 1 .. l_msg_len
  LOOP
     IF SUBSTR(p_messages,i,1) = cst_delimiter THEN
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
           l_mesg_text:=fnd_message.get;
         ELSE
           l_mesg_text:=l_mesg_name;
         END IF; --30 character message name

         IF l_return_msg IS NULL THEN
           l_return_msg:= l_mesg_text;
         ELSE
           l_return_msg:= l_return_msg||';'||l_mesg_text;
         END IF;
         l_mesg_name := NULL;
     ELSE
        l_mesg_name := l_mesg_name||SUBSTR(p_messages,i,1);
     END IF;
  END LOOP;
  RETURN l_return_msg;
END enrpl_get_msg;





PROCEDURE enrpl_log_msg(
  p_level VARCHAR2,
  p_message VARCHAR2,
  p_batch_id igs_en_blk_sua_ints.batch_id%TYPE ,
  p_person_number igs_en_blk_sua_ints.person_number%TYPE DEFAULT NULL ,
  p_program_cd igs_en_blk_sua_ints.program_cd%TYPE DEFAULT NULL,
  p_program_ver igs_en_blk_sua_ints.program_ver_num%TYPE DEFAULT NULL,
  p_load_alt_code igs_en_blk_sua_ints.alternate_cd%TYPE DEFAULT NULL
  )
  AS
-----------------------------------------------------------------------------------
--Created by  : rvivekan ( Oracle IDC)
--Date created: 12-AUG-2003
--
--Purpose:  This procedure Updates the interface table with group level errors
--          and outputs the same to the fnd_log as well
--
--Known limitations/enhancements and/or remarks:

--Change History:
--Who         When            What
------------------------------------------------------------------------------------

l_cid     INTEGER;
l_exec    INTEGER;
l_sql     VARCHAR2(2000);
l_fcount  NUMBER:=1;
l_lcount  NUMBER:=1;
l_message VARCHAR2(2000);

BEGIN
  l_message:=enrpl_get_msg(p_message);

  UPDATE igs_en_blk_sua_ints
  SET ERROR_TXT=l_message,
      status_flag=DECODE(p_level,'E','E','W1',status_flag,'S'),   -- W1 is grp level warning..changing to S here will prevent c_bulk_suas from picking this upload
      last_updated_by=fnd_global.user_id, last_update_login=fnd_global.login_id, last_update_date=SYSDATE,
      request_id=fnd_global.conc_request_id, program_id=fnd_global.conc_program_id ,
      program_application_id=fnd_global.prog_appl_id, program_update_date=SYSDATE
  WHERE  batch_id=p_batch_id
  AND status_flag IN ('U','R','S')
  AND person_number   =p_person_number
  AND program_cd      = NVL(p_program_cd ,program_cd)
  AND program_ver_num = NVL(p_program_ver,program_ver_num)
  AND ((p_load_alt_code IS NULL) OR
      ((p_load_alt_code IS NOT NULL)AND
            alternate_cd IN ( SELECT teach_alternate_code FROM igs_ca_load_to_teach_v
                         WHERE  load_alternate_code=p_load_alt_code)));

  IF p_load_alt_code IS NULL THEN -- group header has not yet been put..teach code will be not null only in case of teach calendar errors or relationship errors
      --group header
    fnd_file.put_line(Fnd_File.LOG, rpad(' ',80,'_'));
    IF p_program_cd IS NULL THEN
      fnd_message.set_name('IGS','IGS_EN_BLK_PER_MSG');
    ELSE
      fnd_message.set_name('IGS','IGS_EN_BLK_PER_PRO');
      fnd_message.set_token('PRGCD',NVL(p_program_cd,''' '''));
    END IF;
    fnd_message.set_token('PERNUM', p_person_number);
    fnd_file.put_line(Fnd_File.LOG,fnd_message.get);
    fnd_file.put_line(Fnd_File.LOG, rpad(' ',80,'_'));
  END IF;
  WHILE l_fcount < LENGTH(l_message) LOOP
    l_lcount:=INSTR(l_message,';',l_fcount);
    IF l_lcount=0 THEN
      fnd_file.put_line(fnd_file.LOG, SUBSTR(l_message,l_fcount));
      l_fcount:=LENGTH(l_message)+1;
    ELSE
      fnd_file.put_line(fnd_file.LOG, SUBSTR(l_message,l_fcount,l_lcount-l_fcount));
      l_fcount:=l_lcount+1;
    END IF;
  END LOOP;
END enrpl_log_msg;




PROCEDURE enrpl_save_unit_msg(p_message VARCHAR2) AS
-----------------------------------------------------------------------------------
--Created by  : rvivekan ( Oracle IDC)
--Date created: 12-AUG-2003
--
--Purpose:  To ouput the saved unit level error messages in the plsql table to the fnd_log
--          and to update the interface table with the same information.
--          If a group level error has occured, the group level error message is concatenated
--          to the unit section message and the status_flag is set to 'E'
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------------------------

l_sql VARCHAR2(2000);
l_fcount NUMBER:=1;
l_lcount NUMBER:=1;
l_message VARCHAR2(2000);


BEGIN
  fnd_file.put_line(Fnd_File.LOG, rpad(' ',80,'_'));
  fnd_file.put_line(Fnd_File.LOG, rpad(fnd_message.get_string('IGS','IGS_EN_BLK_GRP_UID'),20,' ')||fnd_message.get_string('IGS','IGS_EN_BLK_GRP_UMSG'));
  fnd_file.put_line(Fnd_File.LOG, rpad(' ',80,'-'));
  FOR i IN 0.. l_msg_rec_ind-1
  LOOP

    IF l_message_table(i).type='S' AND p_message IS NOT NULL THEN
      l_message_table(i).message:=p_message;  --overwrite with group level error message.
      l_message_table(i).type:='E' ;
    END IF;
    IF l_message_table(i).type= 'W' AND p_message IS NOT NULL THEN
      l_message_table(i).message:=l_message_table(i).message||';'||p_message; --append with group level error message.
      l_message_table(i).type:='E';
    ELSE
      IF l_message_table(i).type= 'W' THEN
        l_message_table(i).type:='S';
        l_message_table(i).message:=l_message_table(i).message||';'||'IGS_EN_UA_SECCESS_ADDED_STUD';
      END IF;
    END IF;
    l_message:=enrpl_get_msg(l_message_table(i).message);
    UPDATE igs_en_blk_sua_ints SET ERROR_TXT=l_message , STATUS_FLAG=l_message_table(i).type,
    last_updated_by = fnd_global.user_id, last_update_login =fnd_global.login_id,last_update_date=SYSDATE,
    request_id=fnd_global.conc_request_id, program_id=fnd_global.conc_program_id ,program_application_id=fnd_global.prog_appl_id,
    program_update_date=SYSDATE
    WHERE upload_id=l_message_table(i).upload_id;

    l_fcount:=1;l_lcount:=1;
    WHILE l_fcount < LENGTH(l_message) LOOP
      l_lcount:=INSTR(l_message,';',l_fcount);
      IF l_lcount=0 THEN
      fnd_file.put_line(fnd_file.LOG, rpad(nvl(to_char(l_message_table(i).upload_id),' '),20,' ')||SUBSTR(l_message,l_fcount));
      l_fcount:=LENGTH(l_message)+1;
      ELSE
        fnd_file.put_line(fnd_file.LOG, rpad(nvl(to_char(l_message_table(i).upload_id),' '),20,' ')||SUBSTR(l_message,l_fcount,l_lcount-l_fcount));
        l_message_table(i).upload_id:=null;
        l_fcount:=l_lcount+1;
      END IF;
    END LOOP;
  END LOOP;
END enrpl_save_unit_msg;



PROCEDURE enrpl_unit_msg(
  p_level VARCHAR2,
  p_upload_id igs_en_blk_sua_ints.upload_id%TYPE,
  p_message VARCHAR2
) AS
  -----------------------------------------------------------------------------------
--Created by  : rvivekan ( Oracle IDC)
--Date created: 12-AUG-2003
--
--Purpose:  To add unit level error messages to a plsql table
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
------------------------------------------------------------------------------------

BEGIN
  --If a new upload is being processed, add a new record to the table  else concatenate the message to existing record
  IF l_msg_rec_ind=0 OR l_message_table(l_msg_rec_ind-1).upload_id<>p_upload_id THEN
    l_message_table(l_msg_rec_ind).upload_id:=p_upload_id;
    l_message_table(l_msg_rec_ind).message:=p_message;
    l_message_table(l_msg_rec_ind).type:=p_level;
    l_msg_rec_ind:=l_msg_rec_ind+1;
  ELSE
    l_message_table(l_msg_rec_ind-1).message:=l_message_table(l_msg_rec_ind-1).message||';'||p_message;
    l_message_table(l_msg_rec_ind-1).type:=p_level;
  END IF;
END enrpl_unit_msg;






PROCEDURE enrl_upd_core_ind (p_person_id  IN NUMBER,
                             p_course_cd  IN VARCHAR2,
                             p_uoo_id     IN VARCHAR2,
                             p_core_ind   IN VARCHAR2) AS
------------------------------------------------------------------
  --Created by  : rvivekan, Oracle IDC
  --Date created: 3-Aug-2003
  --
  --Purpose: This procedure is called to update the core_indicator_code column
  --          in the student unit attempt
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
-------------------------------------------------------------------

CURSOR c_get_sua (cp_person_id NUMBER, cp_course_cd VARCHAR2, cp_uoo_id VARCHAR2) IS
SELECT *
FROM IGS_EN_SU_ATTEMPT
WHERE person_id=cp_person_id
AND   course_cd=cp_course_cd
AND   uoo_id=cp_uoo_id;

l_sua c_get_sua%ROWTYPE;
BEGIN
  OPEN c_get_sua (p_person_id,p_course_cd, p_uoo_id);
  FETCH c_get_sua INTO l_sua;
  CLOSE c_get_sua;
  igs_en_sua_api.update_unit_attempt (
  X_ROWID                       => l_sua.row_id ,
  X_PERSON_ID                   => l_sua.person_id ,
  X_COURSE_CD                   => l_sua.course_cd ,
  X_UNIT_CD                     => l_sua.unit_cd ,
  X_CAL_TYPE                    => l_sua.cal_type ,
  X_CI_SEQUENCE_NUMBER          => l_sua.ci_sequence_number ,
  X_VERSION_NUMBER              => l_sua.version_number ,
  X_LOCATION_CD                 => l_sua.location_cd ,
  X_UNIT_CLASS                  => l_sua.unit_class ,
  X_CI_START_DT                 => l_sua.ci_Start_dt ,
  X_CI_END_DT                   => l_sua.ci_end_dt ,
  X_UOO_ID                      => l_sua.uoo_id,
  X_ENROLLED_DT                 => l_sua.enrolled_dt ,
  X_UNIT_ATTEMPT_STATUS         => l_sua.unit_attempt_status ,
  X_ADMINISTRATIVE_UNIT_STATUS  => l_sua.administrative_unit_status ,
  X_DISCONTINUED_DT             => l_sua.discontinued_dt,
  X_RULE_WAIVED_DT              => l_sua.rule_waived_dt ,
  X_RULE_WAIVED_PERSON_ID       => l_sua.rule_waived_person_id ,
  X_NO_ASSESSMENT_IND           => l_sua.no_assessment_ind ,
  X_SUP_UNIT_CD                 => l_sua.sup_unit_cd ,
  X_SUP_VERSION_NUMBER          => l_sua.sup_version_number ,
  X_EXAM_LOCATION_CD            => l_sua.exam_location_cd ,
  X_ALTERNATIVE_TITLE           => l_sua.alternative_title ,
  X_OVERRIDE_ENROLLED_CP        => l_sua.override_enrolled_cp ,
  X_OVERRIDE_EFTSU              => l_sua.override_eftsu ,
  X_OVERRIDE_ACHIEVABLE_CP      => l_sua.override_achievable_cp       ,
  X_OVERRIDE_OUTCOME_DUE_DT     => l_sua.override_outcome_due_dt      ,
  X_OVERRIDE_CREDIT_REASON      => l_sua.override_credit_reason       ,
  X_ADMINISTRATIVE_PRIORITY     => l_sua.administrative_priority ,
  X_WAITLIST_DT                 => l_sua.waitlist_dt                  ,
  X_DCNT_REASON_CD              => l_sua.dcnt_reason_cd               ,
  X_MODE                        => 'R'   ,
  X_GS_VERSION_NUMBER           => l_sua.gs_version_number   ,
  X_ENR_METHOD_TYPE             => l_sua.enr_method_type   ,
  X_FAILED_UNIT_RULE            => l_sua.failed_unit_rule   ,
  X_CART                        => l_sua.cart   ,
  X_RSV_SEAT_EXT_ID             => l_sua.rsv_seat_ext_id     ,
  X_ORG_UNIT_CD                 => l_sua.org_unit_cd   ,
  X_GRADING_SCHEMA_CODE         => l_sua.grading_schema_code,
  X_SUBTITLE                    => l_sua.subtitle   ,
  X_SESSION_ID                  => l_sua.session_id     ,
  X_DEG_AUD_DETAIL_ID           => l_sua.deg_aud_detail_id     ,
  X_STUDENT_CAREER_TRANSCRIPT   => l_sua.student_career_transcript   ,
  X_STUDENT_CAREER_STATISTICS   => l_sua.student_career_statistics   ,
  X_WAITLIST_MANUAL_IND         => l_sua.waitlist_manual_ind   ,
  X_ATTRIBUTE_CATEGORY          => l_sua.attribute_category   ,
  X_ATTRIBUTE1                  => l_sua.attribute1   ,
  X_ATTRIBUTE2                  => l_sua.attribute2   ,
  X_ATTRIBUTE3                  => l_sua.attribute3   ,
  X_ATTRIBUTE4                  => l_sua.attribute4   ,
  X_ATTRIBUTE5                  => l_sua.attribute5   ,
  X_ATTRIBUTE6                  => l_sua.attribute6  ,
  X_ATTRIBUTE7                  => l_sua.attribute7  ,
  X_ATTRIBUTE8                  => l_sua.attribute8  ,
  X_ATTRIBUTE9                  => l_sua.attribute9  ,
  X_ATTRIBUTE10                 => l_sua.attribute10   ,
  X_ATTRIBUTE11                 => l_sua.attribute11   ,
  X_ATTRIBUTE12                 => l_sua.attribute12   ,
  X_ATTRIBUTE13                 => l_sua.attribute13   ,
  X_ATTRIBUTE14                 => l_sua.attribute14   ,
  X_ATTRIBUTE15                 => l_sua.attribute15   ,
  X_ATTRIBUTE16                 => l_sua.attribute16  ,
  X_ATTRIBUTE17                 => l_sua.attribute17  ,
  X_ATTRIBUTE18                 => l_sua.attribute18  ,
  X_ATTRIBUTE19                 => l_sua.attribute19  ,
  X_ATTRIBUTE20                 => l_sua.attribute20  ,
  X_WLST_PRIORITY_WEIGHT_NUM    => l_sua.wlst_priority_weight_num,
  X_WLST_PREFERENCE_WEIGHT_NUM  => l_sua.wlst_preference_weight_num,
  X_CORE_INDICATOR_CODE         => p_core_ind     );  -- Set core indicator to new value from interface table
END enrl_upd_core_ind;



PROCEDURE enrp_batch_sua_upload(
  Errbuf                OUT NOCOPY VARCHAR2,
  Retcode               OUT NOCOPY NUMBER,
  p_batch_id            IN NUMBER,
  p_dflt_unit_confirmed IN VARCHAR2,
  p_ovr_enr_method      IN VARCHAR2,
  p_deletion_flag       IN VARCHAR2) AS
------------------------------------------------------------------
  --Created by  : rvivekan, Oracle IDC
  --Date created: 3-Aug-2003
  --
  --Purpose: This is procedure corresponding to the bulk unit upload concurrent job
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --stutta     11-Feb-2004    Passing new parameter p_enrolled_dt as SYSDATE in
  --                          call to validate_enroll_validate.
  -- ckasu     30-DEC-2004    modified code inorder to consider Term Records while
  --                          getting primary program type as a part of bug#4095276
  -- ckasu     17-JAN-2006     Added igs_ge_gen_003.set_org_id(NULL) as a part of bug#4958173.
-------------------------------------------------------------------

--Fetches the distinct persons in the batch
CURSOR c_bulk_persons (cp_batch_id igs_en_blk_sua_ints.batch_id%TYPE) IS
SELECT DISTINCT person_number
FROM igs_en_blk_sua_ints
WHERE batch_id=cp_batch_id
AND   status_flag IN ('U','R')
ORDER BY person_number;

--Fetches the distinct program attempts for the person
CURSOR c_bulk_programs (cp_batch_id igs_en_blk_sua_ints.batch_id%TYPE, cp_person_number igs_pe_person.person_number%TYPE) IS
SELECT DISTINCT program_cd, program_ver_num
FROM igs_en_blk_sua_ints
WHERE batch_id=cp_batch_id
AND person_number=cp_person_number
AND   status_flag IN ('U','R');


--Fetches the relevant load calendars depending upon the teach alt codes specified
--int the interface table. The person and program attempt are in the context.
CURSOR c_bulk_load (cp_batch_id igs_en_blk_sua_ints.batch_id%TYPE,
                    cp_person_number igs_pe_person.person_number%TYPE,
                    cp_program_cd   igs_ps_ofr_opt.course_cd%TYPE,
                    cp_program_ver_num  igs_en_blk_sua_ints.program_ver_num%TYPE) IS
SELECT DISTINCT ttol.load_cal_type cal_type,  ttol.load_ci_sequence_number
 seq_num, ttol.load_alternate_code alt_cd,ttol.load_start_dt
 FROM igs_en_blk_sua_ints sui, igs_ca_teach_to_load_v ttol
 WHERE batch_id=cp_batch_id
 AND  person_number=cp_person_number
 AND status_flag IN ('U','R')
 AND program_cd=cp_program_cd
 AND program_ver_num=cp_program_ver_num
 AND ttol.teach_alternate_code=sui.alternate_cd
 AND ttol.load_start_dt=
        (SELECT MIN(cttol.load_start_dt) FROM igs_ca_teach_to_load_v cttol
          WHERE cttol.teach_cal_type=ttol.teach_cal_type
          AND  cttol.teach_ci_sequence_number=ttol.teach_ci_sequence_number)
 ORDER BY ttol.load_start_dt;

--Fetches the Teach calendar details
CURSOR c_get_teach_cal_dtls(cp_load_cal_type igs_ca_inst.cal_type%TYPE,
                            cp_load_seq_num igs_ca_inst.sequence_number%TYPE
                           ) IS
SELECT teach_cal_type,
       teach_ci_sequence_number,
       teach_alternate_code
FROM  igs_ca_teach_to_load_v ttol
WHERE ttol.load_cal_type=cp_load_cal_type
AND ttol.load_ci_sequence_number=cp_load_seq_num;

--Fetches the induvidual sua records from the interface table
CURSOR c_bulk_suas (cp_batch_id igs_en_blk_sua_ints.batch_id%TYPE,
                    cp_person_number igs_pe_person.person_number%TYPE,
                    cp_program_cd   igs_ps_ofr_opt.course_cd%TYPE,
                    cp_program_ver_num  igs_en_blk_sua_ints.program_ver_num%TYPE,
                    cp_teach_cal_type igs_ca_inst.cal_type%TYPE,
                    cp_teach_seq_num igs_ca_inst.sequence_number%TYPE,
                    cp_teach_alternate_cd igs_ca_inst.alternate_code%TYPE
                    ) IS
SELECT sui.upload_id,
       sui.unit_cd,
       sui.unit_ver_num,
       sui.location_cd,
       sui.unit_class,
       sui.alternate_cd,
       sui.status_flag,
       sui.audit_flag,
       sui.grading_sch_cd,
       sui.grading_sch_ver_num,
       sui.variable_cr_point,
       sui.unit_sec_sub_title ,
       sui.alternate_cd alt_cd,
       sui.core_indicator_code,
       sui.update_core_flag,
       enrp_get_uoo_info(sui.unit_cd,sui.unit_ver_num,cp_teach_cal_type,cp_teach_seq_num,sui.location_cd,sui.unit_class) uoo_info
FROM igs_en_blk_sua_ints sui
WHERE batch_id=cp_batch_id
AND person_number=cp_person_number
AND status_flag IN ('U','R')
AND program_cd=cp_program_cd
AND program_ver_num=cp_program_ver_num
AND sui.alternate_cd = cp_teach_alternate_cd
ORDER BY uoo_info DESC;


--Used to check if the student has the relevant program attempt
CURSOR c_stdnt_ps_att (cp_person_id igs_pe_person.person_id%TYPE,
                      cp_program_cd   igs_ps_ofr_opt.course_cd%TYPE,
                      cp_program_ver_num  igs_en_blk_sua_ints.program_ver_num%TYPE) IS
SELECT course_attempt_status, primary_program_type FROM igs_en_stdnt_ps_att
WHERE person_id = cp_person_id
AND course_cd = cp_program_cd
AND version_number= cp_program_ver_num;

--Checks if the student has already attempted the specified uoo
CURSOR c_sua_exists (cp_person_id igs_pe_person.person_id%TYPE,
                     cp_program_cd igs_ps_ofr_opt.course_cd%TYPE,
                     cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
SELECT 'Y' FROM igs_en_su_attempt
WHERE person_id =cp_person_id
AND course_cd = cp_program_cd
AND uoo_id  = cp_uoo_id
AND unit_attempt_status IN ('ENROLLED','UNCONFIRM','WAITLISTED');


--Retrieves the interface records with invalid teach alt codes
-- replaced view igs_ca_inst with igs_ca_inst_all for perf bug#4961316
CURSOR c_invalid_teach (cp_batch_id igs_en_blk_sua_ints.batch_id%TYPE) IS
SELECT sui.upload_id, sui.alternate_cd alt_cd
FROM igs_en_blk_sua_ints sui,igs_ca_inst_all cal
WHERE sui.batch_id=cp_batch_id
AND status_flag IN ('U','R')
AND cal.alternate_code(+)=sui.alternate_cd
AND cal.alternate_code IS NULL;

--Retrieves the interface records with invalid teach 2 load relationship
CURSOR c_invalid_teach2load (cp_batch_id igs_en_blk_sua_ints.batch_id%TYPE) IS
SELECT sui.upload_id, sui.alternate_cd alt_cd,cal.cal_type,cal.sequence_number
FROM igs_en_blk_sua_ints sui,
     igs_ca_inst cal
WHERE sui.alternate_cd=cal.alternate_code
AND batch_id=cp_batch_id
AND status_flag IN ('U','R')
AND NOT EXISTS(SELECT load_cal_type,load_ci_sequence_number
               FROM igs_ca_teach_to_load_v ttol
               WHERE cal.cal_type=ttol.teach_cal_type
               AND cal.sequence_number=ttol.teach_ci_sequence_number);

CURSOR c_batch_desc (cp_batch_id igs_en_blk_sua_ints.batch_id%TYPE) IS
SELECT batch_desc
FROM igs_en_bat_sua_ints
WHERE batch_id=cp_batch_id;

CURSOR c_delete_bat (cp_batch_id igs_en_blk_sua_ints.batch_id%TYPE) IS
SELECT '1'
FROM igs_en_blk_sua_ints
WHERE batch_id=cp_batch_id;


cst_discontin VARCHAR2(40) :='DISCONTIN';
cst_completed VARCHAR2(40) :='COMPLETED';
cst_unconfirm VARCHAR2(40) :='UNCONFIRM';
cst_intermit  VARCHAR2(40):='INTERMIT';
cst_invalid   VARCHAR2(40):='INVALID';
cst_multiple  VARCHAR2(40):='MULTIPLE';
cst_planned   VARCHAR2(40):='PLANNED';
cst_cancelled VARCHAR2(40):='CANCELLED';
cst_notofr    VARCHAR2(40):='NOT_OFFERED';
cst_primary   VARCHAR2(40):='PRIMARY';

l_person_id             igs_pe_person.person_id%TYPE;
l_person_type           VARCHAR2(30);
l_uoo_id                igs_ps_unit_ofr_opt.uoo_id%TYPE;
l_rel_type              igs_ps_unit_ofr_opt.relation_type%TYPE;
l_usec_status           igs_ps_unit_ver.unit_status%TYPE;
l_acad_cal_type         igs_ca_inst.cal_type%TYPE;
l_acad_seq_num          igs_ca_inst.sequence_number%TYPE;
l_acad_alt_cd           igs_ca_inst.alternate_code%TYPE;
l_enr_cal_type          igs_ca_inst.cal_type%TYPE;
l_enr_seq_num           igs_ca_inst.sequence_number%TYPE;
l_acad_start_dt         igs_ca_inst.start_dt%TYPE;
l_acad_end_dt           igs_ca_inst.start_dt%TYPE;
l_enr_method            VARCHAR2(100);
l_enr_category          VARCHAR2(100);
l_commencement_type     VARCHAR2(100);
l_enr_categories        VARCHAR2(100);
l_uoo_ids_list          VARCHAR2(2000):=null;
l_error_message         VARCHAR2(2000);
l_ret_status            VARCHAR2(2000);
l_stdnt_ps_att          c_stdnt_ps_att%ROWTYPE;
l_waitlist_ind          VARCHAR2(30);
l_sua_exists            VARCHAR(2);
l_deny_warn             VARCHAR2(30);
l_abort_loop            BOOLEAN :=FALSE;
l_dummy                 VARCHAR(10);
l_chk_au_allowed        VARCHAR(10);
l_pos                   NUMBER;
l_pos1                  NUMBER;
l_pos2                  NUMBER;
l_processed_rec         BOOLEAN := FALSE;  -- Boolean to indicate if any records where processed
l_batch_desc            VARCHAR2(100);
l_core_indicator_code   igs_en_su_attempt.core_indicator_code%TYPE;
l_sup_units_list        VARCHAR2(2000);
l_sup_unit              igs_ps_unit_ofr_opt.uoo_id%TYPE;
l_sub_success           VARCHAR2(2000);
l_sub_waitlist          VARCHAR2(2000);
l_sub_failed            VARCHAR2(2000);
l_save_message_no       NUMBER;


BEGIN

  igs_ge_gen_003.set_org_id(NULL);

  igs_en_gen_017.g_invoke_source:='JOB';
  retcode:=0;
  SAVEPOINT blk_sua_job;
  l_ret_status:=null;l_error_message:=null;

  --Derive the --enrollment method
  IF p_ovr_enr_method IS NULL THEN
    igs_en_gen_017.enrp_get_enr_method (l_enr_method,l_error_message,l_ret_status);
    IF l_ret_status='FALSE' THEN
        Fnd_message.set_name('IGS','IGS_SS_EN_NOENR_METHOD');
        Fnd_file.put_line(fnd_file.log,fnd_message.get);
        retcode:=2;
        RETURN;
    END IF;
  ELSE
    l_enr_method:=p_ovr_enr_method;
  END IF;
  l_ret_status:=null;l_error_message:=null;
  l_person_type:=igs_en_gen_008.enrp_get_person_type(p_course_cd =>NULL);

  --Log header
  OPEN c_batch_desc(p_batch_id);
  FETCH c_batch_desc INTO l_batch_desc;
  CLOSE c_batch_desc;
  fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_PE_CURR_DT')||':'||SYSDATE);
  fnd_message.set_name('IGS','IGS_EN_BLK_GRP_HD');
  fnd_message.set_token('BATCHID', p_batch_id);
  fnd_message.set_token('BATCHDESC',l_batch_desc);
  fnd_message.set_token('ENRMETHOD',l_enr_method);
  fnd_file.put_line(Fnd_File.LOG,fnd_message.get);

  fnd_message.set_name('IGS','IGS_EN_BLK_JOB_PARAM');
  fnd_message.set_token('PARAM1', p_dflt_unit_confirmed);
  fnd_message.set_token('PARAM2',p_ovr_enr_method);
  fnd_message.set_token('PARAM3',p_deletion_flag);
  fnd_file.put_line(Fnd_File.LOG,fnd_message.get);


  FOR l_bulk_persons IN c_bulk_persons(p_batch_id)
  LOOP --for each person
    l_processed_rec:=TRUE;
    l_person_id:= igs_ge_gen_003.get_person_id(l_bulk_persons.person_number);
    IF l_person_id IS NULL THEN
      enrpl_log_msg(p_level =>'E',
                    p_message =>'IGS_GE_INVALID_PERSON_NUMBER',
                    p_batch_id => p_batch_id,
                    p_person_number=>l_bulk_persons.person_number );
    ELSE  --valid person number
      FOR l_bulk_programs IN c_bulk_programs(p_batch_id,l_bulk_persons.person_number)
      LOOP --for each program attempt

        --Check if the stundent has a relevant program attempt
        OPEN c_stdnt_ps_att (l_person_id,l_bulk_programs.program_cd,l_bulk_programs.program_ver_num);
        FETCH c_stdnt_ps_att INTO l_stdnt_ps_att;

        IF c_stdnt_ps_att%NOTFOUND  THEN
          l_error_message :='IGS_EN_NO_ACTIVE_PROGRAM';
        ELSIF l_stdnt_ps_att.course_attempt_status=cst_unconfirm THEN
          l_error_message :='IGS_EN_FAIL_SUA_DUE_PROG_UNCR';
        ELSIF l_stdnt_ps_att.course_attempt_status=cst_intermit THEN
         l_error_message :='IGS_EN_FAIL_SUA_DUE_PROG_INT';
        ELSIF l_stdnt_ps_att.course_attempt_status IN (cst_discontin,cst_completed) THEN
          l_error_message :='IGS_EN_SUA_SPA_MISMTCH';
        ELSE
          l_error_message:=null;
        END IF;

        IF l_error_message IS NOT NULL THEN
        --Applicable Program attempt not found
        enrpl_log_msg(p_level =>'E',
                      p_message =>l_error_message,
                      p_batch_id => p_batch_id,
                      p_person_number=>l_bulk_persons.person_number,
                      p_program_cd=>l_bulk_programs.program_cd,
                      p_program_ver=>l_bulk_programs.program_ver_num);
        ELSE  -- student has prog attempt

          FOR l_bulk_load IN c_bulk_load (p_batch_id,l_bulk_persons.person_number,l_bulk_programs.program_cd,l_bulk_programs.program_ver_num) LOOP --load calendars
            SAVEPOINT blk_sc_load_lvl;
            --group header
            fnd_file.put_line(Fnd_File.LOG, rpad(' ',80,'_'));
            fnd_message.set_name('IGS','IGS_EN_BLK_GRP_INF');
            fnd_message.set_token('PERNUM', l_bulk_persons.person_number);
            fnd_message.set_token('PRGCD',l_bulk_programs.program_cd);
            fnd_message.set_token('LOADALTCD',l_bulk_load.alt_cd);
            fnd_file.put_line(Fnd_File.LOG,fnd_message.get);
            fnd_file.put_line(Fnd_File.LOG, rpad(' ',80,'_'));

            l_abort_loop:=FALSE;
            l_error_message:=null;
            -- check whether the program is PRIMARY or not by considering Term Records
            -- If it's not an PRIMARY program in career mode then log message and stop processing
            -- for the current unit by assigning l_abort_loop to TRUE and proceed for the unit for
            -- the corresponding load cal type and sequence number.
            -- added by ckasu as a part of bug # 4095479
            IF NVL(FND_PROFILE.VALUE('CAREER_MODEL_ENABLED'),'N') = 'Y' AND
               igs_en_spa_terms_api.get_spat_primary_prg(l_person_id,
                                                         l_bulk_programs.program_cd,
                                                         l_bulk_load.cal_type,
                                                         l_bulk_load.seq_num) <> cst_primary  THEN
               l_error_message :='IGS_EN_ENR_UNT_SEC_PRGM';
            END IF;

            IF l_error_message IS NOT NULL THEN
              enrpl_log_msg(p_level             =>'E',
                            p_message           =>l_error_message,
                            p_batch_id          => p_batch_id,
                            p_person_number     =>l_bulk_persons.person_number,
                            p_program_cd        =>l_bulk_programs.program_cd,
                            p_program_ver       =>l_bulk_programs.program_ver_num,
                            p_load_alt_code     =>l_bulk_load.alt_cd);

              l_abort_loop:=TRUE;
            END IF; -- end if statement that logs message when program type is not an Pprimary program

            l_error_message:=null;

            IF l_abort_loop=FALSE THEN

                    l_acad_alt_cd := igs_en_gen_002.enrp_get_acad_alt_cd(p_cal_type             =>l_bulk_load.cal_type,
                                                        p_ci_sequence_number                    =>l_bulk_load.seq_num,
                                                        p_acad_cal_type                         => l_acad_cal_type,
                                                        p_acad_ci_sequence_number               =>l_acad_seq_num,
                                                        p_acad_ci_start_dt                      => l_acad_start_dt,
                                                        p_acad_ci_end_dt                        => l_acad_end_dt,
                                                        p_message_name                          => l_error_message);
                    IF l_error_message IS NOT NULL THEN
                      enrpl_log_msg(p_level             =>'E',
                                    p_message           =>l_error_message,
                                    p_batch_id          =>p_batch_id,
                                    p_person_number     =>l_bulk_persons.person_number,
                                    p_program_cd        =>l_bulk_programs.program_cd,
                                    p_program_ver       =>l_bulk_programs.program_ver_num,
                                    p_load_alt_code     =>l_bulk_load.alt_cd);

                      l_abort_loop:=TRUE;
                    END IF; --found/not found acad calendar

            END IF; -- end of IF THEN getting Academic calendar

            l_ret_status:=null;l_error_message:=null;

            IF l_abort_loop=FALSE THEN
              --derive enrollment category and commencement type
              l_enr_category :=igs_en_gen_003.enrp_get_enr_cat( p_person_id                =>l_person_id,
                                                                p_course_cd                =>l_bulk_programs.program_cd,
                                                                p_cal_type                 =>l_acad_cal_type,
                                                                p_ci_sequence_number       =>l_acad_seq_num,
                                                                p_session_enrolment_cat    =>NULL,
                                                                p_enrol_cal_type           =>l_enr_cal_type,
                                                                p_enrol_ci_sequence_number =>l_enr_seq_num,
                                                                p_commencement_type        =>l_commencement_type,
                                                                p_enr_categories           =>l_enr_categories);

              --Validate the applicable advising holds
              igs_en_elgbl_person.eval_ss_deny_all_hold (p_person_id                  =>l_person_id,
                                                      p_person_type                     =>l_person_type,
                                                      p_course_cd                       =>l_bulk_programs.program_cd,
                                                      p_load_calendar_type              =>l_bulk_load.cal_type,
                                                      p_load_cal_sequence_number        =>l_bulk_load.seq_num,
                                                      p_status                          =>l_ret_status,
                                                      p_message                         =>l_error_message);

              IF l_ret_status='E' THEN --person steps validations
                enrpl_log_msg(p_level           =>'E',
                            p_message           =>l_error_message,
                            p_batch_id          => p_batch_id,
                            p_person_number     =>l_bulk_persons.person_number,
                            p_program_cd        =>l_bulk_programs.program_cd,
                            p_program_ver       =>l_bulk_programs.program_ver_num,
                            p_load_alt_code     =>l_bulk_load.alt_cd);
                l_abort_loop:=TRUE;
              END IF;
              l_ret_status:=null;l_error_message:=null;
            END IF; --l_abort_loop


            IF l_abort_loop=FALSE THEN
              --Evaluate the applicable person steps
              IF FALSE=igs_en_elgbl_person.eval_person_steps ( p_person_id              =>l_person_id,
                                                             p_person_type              =>l_person_type,
                                                             p_load_calendar_type       =>l_bulk_load.cal_type,
                                                             p_load_cal_sequence_number =>l_bulk_load.seq_num,
                                                             p_program_cd               =>l_bulk_programs.program_cd,
                                                             p_program_version          =>l_bulk_programs.program_ver_num,
                                                             p_enrollment_category      =>l_enr_category,
                                                             p_comm_type                =>l_commencement_type,
                                                             p_enrl_method              =>l_enr_method,
                                                             p_message                  =>l_error_message,
                                                             p_deny_warn                =>l_deny_warn,
                                                             p_calling_obj              =>'JOB',
                                                             p_create_warning           =>'N') THEN
                enrpl_log_msg(p_level           =>'E',
                            p_message           =>l_error_message,
                            p_batch_id          => p_batch_id,
                            p_person_number     =>l_bulk_persons.person_number,
                            p_program_cd        =>l_bulk_programs.program_cd,
                            p_program_ver       =>l_bulk_programs.program_ver_num,
                            p_load_alt_code     =>l_bulk_load.alt_cd);
                l_abort_loop:=TRUE;
              ELSE
                IF l_error_message IS NOT NULL THEN
                --log enrollment category validation warnings and continue
                  enrpl_log_msg(p_level         =>'W1',  --W1 is group level warning before the sua is inserted..thus status should not be changed
                                p_message       =>l_error_message,
                                p_batch_id      => p_batch_id,
                                p_person_number =>l_bulk_persons.person_number,
                                p_program_cd    =>l_bulk_programs.program_cd,
                                p_program_ver   =>l_bulk_programs.program_ver_num,
                                p_load_alt_code =>l_bulk_load.alt_cd);
                END IF;
              END IF;
              l_ret_status:=null;l_error_message:=null;
            END IF; --l_abort_loop

            l_sup_units_list:=NULL;
            l_msg_rec_ind:=0;
            l_uoo_ids_list:=NULL;

            IF l_abort_loop=FALSE THEN

             FOR l_teach_cal_dtls IN c_get_teach_cal_dtls(l_bulk_load.cal_type,l_bulk_load.seq_num) LOOP
              FOR l_bulk_suas IN c_bulk_suas (p_batch_id,l_bulk_persons.person_number,l_bulk_programs.program_cd,l_bulk_programs.program_ver_num,
                                              l_teach_cal_dtls.teach_cal_type,l_teach_cal_dtls.teach_ci_sequence_number,l_teach_cal_dtls.teach_alternate_code)
              LOOP  --Student unit attempts
                l_abort_loop:=FALSE;
                l_core_indicator_code:=NULL;
                --If an appropriate uoo is not found then uoo_info column will be null
                IF l_bulk_suas.uoo_info  IS NULL THEN
                  enrpl_unit_msg ('E',l_bulk_suas.upload_id,'IGS_EN_UNIT_OFR_OPT_NT_FND');
                  l_abort_loop:=TRUE;
                END IF;

                --Derive all unit offering option from the concatenated string
                enrp_decode_uoo_info (l_bulk_suas.uoo_info,l_uoo_id,l_rel_type,l_chk_au_allowed,l_usec_status,l_sup_unit);

                --Validate the core_indicator_code column if update_core_flag is set
                IF l_abort_loop=FALSE AND l_bulk_suas.update_core_flag='Y' THEN
                  IF FALSE=igs_lookups_view_pkg.get_pk_for_validation ('IGS_PS_CORE_IND', l_bulk_suas.core_indicator_code) THEN
                    enrpl_unit_msg ('E',l_bulk_suas.upload_id,'IGS_EN_CORE_IND_INVALID');
                    l_abort_loop:=TRUE;
                  END IF;
                END IF;

                --Check the status of the unit ofr option
                IF l_abort_loop=FALSE THEN
                  IF l_usec_status IN (cst_planned,cst_cancelled,cst_notofr) THEN
                    l_abort_loop:=TRUE;
                    enrpl_unit_msg ('E',l_bulk_suas.upload_id,'IGS_EN_FAIL_SUA_DUE_INV_SUA');
                  END IF;
                END IF; --l_abort_loop


                IF l_abort_loop=FALSE THEN
                  --is uoo already attempted
                  OPEN c_sua_exists(l_person_id,l_bulk_programs.program_cd,l_uoo_id);
                  FETCH c_sua_exists INTO l_sua_exists;
                  CLOSE c_sua_exists;
                  IF l_sua_exists='Y' THEN
                    IF l_bulk_suas.update_core_flag='Y' THEN
                      IF NVL(FND_PROFILE.VALUE('IGS_EN_CORE_VAL'),'N') = 'Y' THEN
                        --If profile is set then Derive core indicator from POS and log warning if it is being overriden
                        l_core_indicator_code:=Igs_En_Gen_009.enrp_check_usec_core (p_person_id  =>l_person_id,
                                                                                    p_program_cd =>l_bulk_programs.program_cd,
                                                                                    p_uoo_id     =>l_uoo_id);
                        IF l_core_indicator_code <> l_bulk_suas.core_indicator_code THEN
                          enrpl_unit_msg('W',l_bulk_suas.upload_id,'IGS_EN_POS_MATCH');
                        END IF;
                      END IF;--profile check
                      --Override the core indicator for the existing unit attempt
                      enrl_upd_core_ind (p_person_id   => l_person_id,
                                         p_course_cd   => l_bulk_programs.program_cd,
                                         p_uoo_id      => l_uoo_id ,
                                         p_core_ind    => l_bulk_suas.core_indicator_code);
                      enrpl_unit_msg('S',l_bulk_suas.upload_id,'IGS_EN_SUA_UPDATE_SUCC');
                      l_abort_loop:=TRUE;
                     ELSE
                      enrpl_unit_msg ('E',l_bulk_suas.upload_id,'IGS_EN_UNT_ATMPT_EXTS');
                      l_abort_loop:=TRUE;
                    END IF;

                  ELSIF --uoo is not attempted -- Variation Window Validation
                  FALSE= igs_en_gen_008.enrp_get_var_window(p_cal_type           =>   l_teach_cal_dtls.teach_cal_type,
                                                            p_ci_sequence_number =>   l_teach_cal_dtls.teach_ci_sequence_number,
                                                            p_effective_dt       =>   SYSDATE,
                                                            p_uoo_id             =>   l_uoo_id ) THEN
                    enrpl_unit_msg ('E',l_bulk_suas.upload_id,'IGS_EN_CANT_UPD_OUTS_ENRL');
                    l_abort_loop:=TRUE;
                  ELSE --uoo is not attempted -- Variation Window Validation passed-- Validation for the Enrollment window
                    IF FALSE=igs_en_gen_004.enrp_get_rec_window (p_cal_type       =>   l_teach_cal_dtls.teach_cal_type,
                                                             p_ci_sequence_number =>   l_teach_cal_dtls.teach_ci_sequence_number,
                                                             p_effective_date     =>   SYSDATE,
                                                             p_uoo_id             =>   l_uoo_id,
                                                             p_message_name       =>  l_error_message ) THEN
                      enrpl_unit_msg ('E',l_bulk_suas.upload_id,l_error_message);
                      l_abort_loop:=TRUE;
                    END IF;
                  END IF;
                  l_ret_status:=null;l_error_message:=null;
                END IF; --l_abort_loop


                IF l_abort_loop=FALSE THEN
                     --uoo is not attempted - Variation Window Validation and Enrollment window Validation passed
                     --get Availability
                  l_usec_status:=null;
                  igs_en_gen_015.get_usec_status(p_uoo_id                  =>l_uoo_id,
                                                 p_person_id               =>l_person_id,
                                                 p_unit_section_status     =>l_usec_status,
                                                 p_waitlist_ind            =>l_waitlist_ind,
                                                 p_load_cal_type           =>l_bulk_load.cal_type,
                                                 p_load_ci_sequence_number =>l_bulk_load.seq_num,
                                                 p_course_cd               =>l_bulk_programs.program_cd);
                  IF  l_waitlist_ind IS NULL THEN
                    enrpl_unit_msg ('E',l_bulk_suas.upload_id,'IGS_EN_FAIL_SUA_NO_SEATS');
                    l_abort_loop:=TRUE;
                  END IF;
                END IF; --l_abort_loop

                IF l_abort_loop=FALSE AND l_bulk_suas.audit_flag='Y' THEN
                    IF l_chk_au_allowed='N' THEN
                      enrpl_unit_msg ('E',l_bulk_suas.upload_id,'IGS_EN_CANNOT_AUDIT');
                      l_abort_loop:=TRUE;
                    END IF;
                END IF;

                IF l_abort_loop=FALSE AND
                   l_bulk_suas.variable_cr_point IS NOT NULL THEN --checking variable credit point
                  IF l_bulk_suas.audit_flag='Y' THEN
                    enrpl_unit_msg ('E',l_bulk_suas.upload_id,'IGS_EN_OVR_CP_AUD');
                    l_abort_loop:=TRUE;
                  ELSIF 'N'=igs_en_gen_008.enrp_val_chg_cp (p_person_id          =>l_person_id,          --override allowed?
                                                            p_uoo_id             =>l_uoo_id,
                                                            p_cal_type           =>l_teach_cal_dtls.teach_cal_type,
                                                            p_ci_sequence_number =>l_teach_cal_dtls.teach_ci_sequence_number) THEN
                    enrpl_unit_msg ('E',l_bulk_suas.upload_id,'IGS_EN_FAIL_SUA_VARCP_NOT_AWD');
                    l_abort_loop:=TRUE;
                  ELSE
                    IF FALSE=igs_en_val_sua.enrp_val_sua_ovrd_cp(p_unit_cd                 =>l_bulk_suas.unit_cd,                  --within min/max CP?
                                                                  p_version_number         =>l_bulk_suas.unit_ver_num,
                                                                  p_override_enrolled_cp   =>l_bulk_suas.variable_cr_point,
                                                                  p_override_achievable_cp => NULL,
                                                                  p_override_eftsu         => NULL,
                                                                  p_message_name           => l_error_message,
                                                                  p_uoo_id                 =>l_uoo_id,
                                                                  p_no_assessment_ind      =>l_bulk_suas.audit_flag) THEN
                      enrpl_unit_msg ('E',l_bulk_suas.upload_id,'IGS_EN_FAIL_SUA_VARCP_NOT_VLD');
                      l_abort_loop:=TRUE;
                    END IF;
                  END IF;
                  l_ret_status:=null;l_error_message:=null;
                END IF; --checking variable credit point --l_abort_loop


                IF l_abort_loop=FALSE AND  -- var_cr_point validation was passed or not applicable
                   l_bulk_suas.grading_sch_cd IS NOT NULL THEN -- checking grading schema
                  IF FALSE=igs_en_gen_008.enrp_val_chg_grd_sch (p_uoo_id             =>l_uoo_id,
                                                                p_cal_type           =>l_teach_cal_dtls.teach_cal_type,
                                                                p_ci_sequence_number =>l_teach_cal_dtls.teach_ci_sequence_number,
                                                                p_message_name       =>l_error_message) THEN
                    enrpl_unit_msg ('E',l_bulk_suas.upload_id,'IGS_EN_FAIL_SUA_VARGRD_NOT_AWD');
                    l_abort_loop:=TRUE;
                  ELSE
                    IF  FALSE=igs_ss_en_wrappers.enr_val_grad_usec(p_uoo_ids              => l_uoo_id,
                                                                    p_grading_schema_code => l_bulk_suas.grading_sch_cd,
                                                                    p_gs_version_number   => l_bulk_suas.grading_sch_ver_num) THEN
                      enrpl_unit_msg ('E',l_bulk_suas.upload_id,'IGS_EN_FAIL_SUA_VARGRD_NOT_VLD');
                      l_abort_loop:=TRUE;
                    END IF;
                  END IF;
                  l_ret_status:=null;l_error_message:=null;
                END IF;-- checking grading schema --l_abort_loop


                IF l_abort_loop=FALSE AND --Grading schema validation was passed or not applicable
                   l_bulk_suas.unit_sec_sub_title IS NOT NULL THEN
                  IF 'N'= igs_ss_enr_details.enrp_val_subttl_chg(p_person_id => l_person_id,p_uoo_id =>l_uoo_id) THEN
                    l_abort_loop:=TRUE;
                    enrpl_unit_msg ('E',l_bulk_suas.upload_id,'IGS_EN_FAIL_SUA_SUBTIT_NOT_AWD');
                  END IF;  --subtitle validation
                END IF; --l_abort_loop

                IF l_abort_loop=FALSE  THEN --Subtitile validation was passed or not applicable
                  --populate core indicator from POS if profile is set
                  IF NVL(FND_PROFILE.VALUE('IGS_EN_CORE_VAL'),'N') = 'Y' THEN
                    l_core_indicator_code:=Igs_En_Gen_009.enrp_check_usec_core (p_person_id  =>l_person_id,
                                                                                p_program_cd =>l_bulk_programs.program_cd,
                                                                                p_uoo_id     =>l_uoo_id);
                  END IF;
                  --override from interface table if flag is set
                  IF l_bulk_suas.update_core_flag='Y' THEN
                    IF l_core_indicator_code <> l_bulk_suas.core_indicator_code AND NVL(FND_PROFILE.VALUE('IGS_EN_CORE_VAL'),'N') = 'Y' THEN
                      enrpl_unit_msg('W',l_bulk_suas.upload_id,'IGS_EN_POS_MATCH');
                    END IF;
                    l_core_indicator_code:=l_bulk_suas.core_indicator_code;
                  END IF;
                END IF; --l_abort_loop

                IF l_abort_loop=FALSE THEN --Core indicator populated appropriately, proceed to insert sua
                  SAVEPOINT bulk_sua_upload;
                  BEGIN
                    igs_ss_en_wrappers.insert_into_enr_worksheet(p_person_number          =>l_bulk_persons.person_number,
                                                               p_course_cd              =>l_bulk_programs.program_cd,
                                                               p_uoo_id                 =>l_uoo_id,
                                                               p_waitlist_ind           =>l_waitlist_ind,
                                                               p_session_id             =>NULL,
                                                               p_return_status          =>l_ret_status,
                                                               p_message                =>l_error_message,
                                                               p_cal_type               =>l_bulk_load.cal_type,
                                                               p_ci_sequence_number     =>l_bulk_load.seq_num,
                                                               p_audit_requested        =>l_bulk_suas.audit_flag,
                                                               p_enr_method             =>l_enr_method,
                                                               p_override_cp            =>l_bulk_suas.variable_cr_point,
                                                               p_subtitle               =>l_bulk_suas.unit_sec_sub_title,
                                                               p_gradsch_cd             =>l_bulk_suas.grading_sch_cd,
                                                               p_gs_version_num         =>l_bulk_suas.grading_sch_ver_num,
                                                               p_core_indicator_code    =>l_core_indicator_code,
                                                               p_calling_obj            =>'JOB');
                  EXCEPTION WHEN OTHERS THEN
                    --When an exception is raised..get the exception text and store it in l_error_message
                    IF IGS_GE_MSG_STACK.COUNT_MSG <> 0 THEN
                      l_error_message := FND_MESSAGE.GET;
                    ELSE
                      l_error_message := SQLERRM;
                    END IF;
                    l_ret_status := 'D';
                  END;

                  --Removing the coreq warning message from the error messages
                  l_pos:=INSTR(l_error_message,'IGS_SS_WARN_COREQ',1);
                  IF l_pos=0 THEN
                    l_pos:=INSTR(l_error_message,'IGS_SS_DENY_COREQ',1);
                  END IF;
                  IF l_pos<>0 THEN
                    l_pos1:=INSTR(l_error_message,';',l_pos);
                    IF l_pos1<>0 THEN
                      l_error_message:=SUBSTR(l_error_message,1,l_pos-1)||SUBSTR(l_error_message,INSTR(l_error_message,';',l_pos+1)+1);
                    ELSE
                      l_error_message:=SUBSTR(l_error_message,1,l_pos-1);    --COREQ is the last message
                    END IF;
                  END IF;


                  IF l_ret_status='D' THEN
                    enrpl_unit_msg ('E',l_bulk_suas.upload_id,l_error_message);
                    ROLLBACK TO bulk_sua_upload;
                    l_abort_loop:=TRUE;
                  ELSIF l_error_message IS NOT NULL THEN
                    enrpl_unit_msg ('W',l_bulk_suas.upload_id,l_error_message);
                  ELSE
                    enrpl_unit_msg ('S',l_bulk_suas.upload_id,'IGS_EN_UA_SECCESS_ADDED_STUD');
                  END IF;
                  IF l_ret_status<>'D' AND l_waitlist_ind='N' AND p_dflt_unit_confirmed='Y' THEN
                    IF l_uoo_ids_list IS NOT NULL THEN
                      l_uoo_ids_list:=l_uoo_ids_list||',';
                    END IF;
                    l_uoo_ids_list:=l_uoo_ids_list||l_uoo_id;
                  END IF;
                  l_ret_status:=null;l_error_message:=null;
                END IF; --l_abort_loop

                IF l_rel_type='SUPERIOR' AND l_abort_loop=FALSE THEN
                  --Add to the list of superiors for which default enroll is to be done
                  --The commas on either side are necessary to allow proper string search
                  --The msg_rec_ind is included so that the subordinate success/failure messages
                  --can be logged against the same upload
                  l_sup_units_list:=NVL(l_sup_units_list,',')||l_uoo_id||'*'||(l_msg_rec_ind-1)||',';
                END IF;
                IF l_rel_type='SUBORDINATE' THEN
                  --Remove its superior as default enroll should not be done if even one subordinate is given by the user.
                  --Note no l_abort_loop check as even if user TRIES to enroll subordinate and it Errors out
                  --no default subs are processed
                  l_pos:=INSTR(l_sup_units_list,','||l_sup_unit||'*');
                  IF l_pos<>0 THEN
                    l_pos1:=INSTR(l_sup_units_list,',',l_pos+1);
                    l_sup_units_list:=SUBSTR(l_sup_units_list,1,l_pos)||SUBSTR(l_sup_units_list,l_pos1+1); --Note..one of the commas is retained
                  END IF;
                END IF;
                l_abort_loop:=FALSE;
              END LOOP; --Student unit attempts
             END LOOP; -- end of FOR l_teach_cal_dtls IN c_get_teach_cal_dtls THEN
            END IF; --l_abort_loop before the l_bulk_Suas main for loop

            --All the suas have been processed. Now for each of the superiors for which no
            --subordinate was imported,enroll the default subordinates
            IF l_abort_loop =FALSE THEN
              l_pos1:=1;
              --processing superior uooids from concatenated string
              LOOP
                l_pos:=l_pos1;
                l_pos1:=INSTR(l_sup_units_list,',',l_pos+1);
                EXIT WHEN NVL(l_pos1,0)=0;
                l_pos2:=INSTR(l_sup_units_list,'*',l_pos+1);
                l_uoo_id:=SUBSTR (l_sup_units_list,              --search the list eg: uooid=1009,msg_rec=5 then record is '%,1009*5,%'
                                  l_pos+1,                       --starting in the current comma separated record
                                  l_pos2-l_pos-1);               --ending just before the '*' after which l_msg_rec_ind appears

                --get the record number in the l_message_table table
                l_save_message_no:=SUBSTR(l_sup_units_list,                       --search the list
                                          l_pos2+1,                               --starting just after '*'
                                          l_pos1-l_pos2-1);                       --ending just before the ','

                l_sub_success:=NULL;l_sub_waitlist:=NULL;l_sub_failed:=NULL;
                igs_en_val_sua.enr_sub_units(
                        p_person_id           => l_person_id,
                        p_course_cd           => l_bulk_programs.program_cd,
                        p_uoo_id              => l_uoo_id,
                        p_waitlist_flag       => l_waitlist_ind,
                        p_load_cal_type       => l_bulk_load.cal_type,
                        p_load_seq_num        => l_bulk_load.seq_num,
                        p_enrollment_date     => SYSDATE,
                        p_enrollment_method   => l_enr_method,
                        p_enr_uoo_ids         => NULL,
                        p_uoo_ids             => l_sub_success,
                        p_waitlist_uoo_ids    => l_sub_waitlist,
                        p_failed_uoo_ids      => l_sub_failed);
                IF l_sub_success IS NOT NULL THEN
                  l_message_table(l_save_message_no).message:= l_message_table(l_save_message_no).message||';'||'IGS_EN_BLK_SUB_SUCCESS*'||igs_en_gen_018.enrp_get_unitcds(l_sub_success);
                  --Since this message reads "Subordinates have been added", the message needs to be overwritten if
                  --validate_enroll_validate fails. If 'W' is the status, then the error message is only appended to the list of warnings
                  --If 'S' is the status, the current messages are replaced with the error message.IGS_EN_BLK_SUB_SUCCESS needs to be replaced
                  IF l_message_table(l_save_message_no).type='W' THEN
                    l_message_table(l_save_message_no).message:= l_message_table(l_save_message_no).message||';IGS_EN_UA_SECCESS_ADDED_STUD';
                    l_message_table(l_save_message_no).type:='S';
                  END IF;
                  IF l_uoo_ids_list IS NOT NULL THEN
                    l_uoo_ids_list:=l_uoo_ids_list||',';
                  END IF;
                  l_uoo_ids_list:=l_uoo_ids_list||l_sub_success;
                END IF;
                IF l_sub_failed IS NOT NULL THEN
                  l_message_table(l_save_message_no).message:= l_message_table(l_save_message_no).message||';'||'IGS_EN_BLK_SUB_FAILED*'||igs_en_gen_018.enrp_get_unitcds(l_sub_failed);
                END IF;
              END LOOP;--processing superior uooids from concatenated string
            END IF; --l_abort_loop

            --Program Level Validations
            IF p_dflt_unit_confirmed='Y' AND l_abort_loop=FALSE THEN
              --Confirm the sua if so specified
              BEGIN
              igs_ss_en_wrappers.validate_enroll_validate ( p_person_id                 => l_person_id,
                                                              p_load_cal_type           =>l_bulk_load.cal_type,
                                                              p_load_ci_sequence_number =>l_bulk_load.seq_num,
                                                              p_uoo_ids                 =>l_uoo_ids_list,
                                                              p_program_cd              =>l_bulk_programs.program_cd,
                                                              p_message_name            =>l_error_message,
                                                              p_deny_warn               =>l_deny_warn,
                                                              p_return_status           =>l_ret_status,
                                                              p_enr_method              =>l_enr_method,
                                                              p_enrolled_dt             =>SYSDATE);
              EXCEPTION WHEN OTHERS THEN
                --If an exception is thrown, get the error message text and save it in the message name variable
                IF IGS_GE_MSG_STACK.COUNT_MSG <> 0 THEN
                  l_error_message := FND_MESSAGE.GET;
                ELSE
                  l_error_message := SQLERRM;
                END IF;
                l_deny_warn      := 'DENY';
                l_ret_status  := 'FALSE';
              END;

              IF  l_ret_status='FALSE' AND l_deny_warn ='DENY' THEN
                --Progam level validations failed
                enrpl_log_msg(p_level           =>'E',
                              p_message         =>l_error_message,
                              p_batch_id        => p_batch_id,
                              p_person_number   =>l_bulk_persons.person_number,
                              p_program_cd      =>l_bulk_programs.program_cd,
                              p_program_ver     =>l_bulk_programs.program_ver_num,
                              p_load_alt_code   =>l_bulk_load.alt_cd);
                ROLLBACK TO blk_sc_load_lvl;
                enrpl_save_unit_msg(l_error_message); --override the messages in successfully processed uploads as well
              ELSE
                --Warning in program level validations
                IF l_error_message IS NOT NULL THEN
                  enrpl_log_msg(p_level         =>'W',
                                p_message       =>l_error_message,
                                p_batch_id      => p_batch_id,
                                p_person_number =>l_bulk_persons.person_number,
                                p_program_cd    =>l_bulk_programs.program_cd,
                                p_program_ver   =>l_bulk_programs.program_ver_num,
                                p_load_alt_code =>l_bulk_load.alt_cd);
                END IF;
                enrpl_save_unit_msg(NULL);
              END IF;
            ELSE
              -- dflt_unit_confirmed not set...just save upload ids statuses and error messages
              IF l_abort_loop=FALSE THEN
                enrpl_save_unit_msg(NULL);
              END IF;
            END IF;--person level validations done only if p_dflt_unit_confirmed is set  --l_abort_loop
            l_ret_status:=null;l_error_message:=null;
          END LOOP; --bulk loadcals
        END IF;  -- program attempt exist validation
        CLOSE c_stdnt_ps_att;
      END LOOP; --programs
    END IF;-- if l_personid_ is null
  END LOOP; --persons

  --Log entries with invalid teach alt codes
  l_msg_rec_ind:=0;
  FOR l_invalid_teach IN c_invalid_teach (p_batch_id)
  LOOP
    enrpl_unit_msg ('E',l_invalid_teach.upload_id,'IGS_EN_ALT_CD_NO_CAL_FND');
  END LOOP;

  --Log entries with invalid load cal relationships
  FOR l_invalid_t2l IN c_invalid_teach2load (p_batch_id)
  LOOP
    enrpl_unit_msg ('E',l_invalid_t2l.upload_id,'IGS_EN_BULK_E_D_NO_CAL_REL');
  END LOOP;
  IF l_msg_rec_ind>0 THEN
    enrpl_save_unit_msg(NULL);
    l_processed_rec:=TRUE;
  END IF;

  IF l_processed_rec=FALSE THEN
    fnd_file.put_line(Fnd_File.LOG, rpad(' ',80,'_'));
    fnd_file.put_line(Fnd_File.LOG,fnd_message.get_string('IGS','IGS_EN_BLK_NO_RECS'));
    fnd_file.put_line(Fnd_File.LOG, rpad(' ',80,'_'));
  END IF;

  --Delete the successfully processed records from the interface table if required
  IF p_deletion_flag='Y' THEN
    DELETE FROM igs_en_blk_sua_ints WHERE batch_id=p_batch_id AND status_flag='S';
    OPEN c_delete_bat (p_batch_id);
    FETCH c_delete_bat INTO l_dummy;
    IF c_delete_bat%NOTFOUND THEN
      DELETE FROM igs_en_bat_sua_ints WHERE batch_id=p_batch_id;
    END IF;
    CLOSE c_delete_bat ;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      retcode:=2;
      ROLLBACK TO blk_sua_job;
      fnd_file.put_line(fnd_file.LOG,SQLERRM);
      Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','Igs_En_Gen_018.Enrp_batch_sua_upload');
      IGS_GE_MSG_STACK.ADD;
      igs_ge_msg_stack.conc_exception_hndl;
END enrp_batch_sua_upload;

FUNCTION enrp_get_uoo_info (
  p_unit_cd            IN VARCHAR2,
  p_unit_ver           IN NUMBER,
  p_cal_type           IN VARCHAR2,
  p_ci_sequence_number IN NUMBER,
  p_location_cd        IN VARCHAR2,
  p_unit_class         IN VARCHAR2)
RETURN VARCHAR2 AS
------------------------------------------------------------------
  --Created by  : rvivekan, Oracle IDC
  --Date created: 22-oct-2003
  --
  --Purpose: This Function returns various uoo information in the form of
  --         and encoded string RelationType*UooId*UnitSectionStatus*AuditableInd*SuperiorUooId
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
-------------------------------------------------------------------

  CURSOR c_get_uoo (  cp_unit_cd            IN VARCHAR2,
                    cp_unit_ver           IN NUMBER,
                    cp_cal_type           IN VARCHAR2,
                    cp_ci_sequence_number IN NUMBER,
                    cp_location_cd        IN VARCHAR2,
                    cp_unit_class         IN VARCHAR2) IS
  SELECT NVL(relation_type,'NONE')||'*'||uoo_id||'*'||unit_section_status||'*'||NVL(auditable_ind,'N')||'*'||sup_uoo_id   uoo_info
  -- Gives all required uoo information
  FROM igs_ps_unit_ofr_opt
  WHERE unit_cd = cp_unit_cd AND version_number = cp_unit_ver
  AND cal_type = cp_cal_type  AND ci_sequence_number = cp_ci_sequence_number
  AND location_cd = cp_location_cd AND unit_class = cp_unit_class;

  l_uoo_info    VARCHAR2(500);
BEGIN
  l_uoo_info:=NULL;
  OPEN c_get_uoo (p_unit_cd,p_unit_ver,p_cal_type,p_ci_sequence_number,p_location_cd,p_unit_class);
  FETCH c_get_uoo INTO l_uoo_info;
  CLOSE c_get_uoo;
  RETURN l_uoo_info;
END enrp_get_uoo_info ;



PROCEDURE enrp_decode_uoo_info (
  p_uoo_info              IN VARCHAR2,
  p_uoo_id                OUT NOCOPY NUMBER,
  p_rel_type              OUT NOCOPY VARCHAR2,
  p_audit_allowed         OUT NOCOPY VARCHAR2,
  p_usec_status           OUT NOCOPY VARCHAR2,
  p_sup_unit              OUT NOCOPY VARCHAR2
  ) AS
------------------------------------------------------------------
  --Created by  : rvivekan, Oracle IDC
  --Date created: 22-oct-2003
  --
  --Purpose: This procedure decodes the string returned by enrp_get_uoo_info
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
-------------------------------------------------------------------
l_pos NUMBER;
l_pos1 NUMBER;

BEGIN
  l_pos:=INSTR(p_uoo_info,'*');
  l_pos1:=INSTR(p_uoo_info,'*',l_pos+1);
  p_rel_type:=SUBSTR(p_uoo_info,1,l_pos-1);                  -- Relation type Superior/subordinate/none
  p_uoo_id:=SUBSTR(p_uoo_info,l_pos+1,l_pos1-1-l_pos);       -- Uoo Id
  l_pos:=INSTR(p_uoo_info,'*',l_pos1+1);
  p_usec_status:=SUBSTR(p_uoo_info,l_pos1+1,l_pos-1-l_pos1); -- Uoo Status OPEN/FULLWAITOK etc
  p_audit_allowed:=SUBSTR(p_uoo_info,l_pos+1,1);               -- Audit allowed
  p_sup_unit:=SUBSTR(p_uoo_info,l_pos+3);                    -- Superior Unit Cd
END enrp_decode_uoo_info ;




FUNCTION enrp_get_unitcds ( p_uoo_ids IN VARCHAR2)
RETURN VARCHAR2 IS
------------------------------------------------------------------
  --Created by  : rvivekan, Oracle IDC
  --Date created: 22-oct-2003
  --
  --Purpose: to translate comma separated uooids to comma separated unitcds
  --
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --
-------------------------------------------------------------------


CURSOR c_get_unit_cd (cp_uoo_id NUMBER) IS
 SELECT unit_cd
 FROM igs_ps_unit_ofr_opt
 WHERE uoo_id=cp_uoo_id;


l_uoo_ids_list VARCHAR2(2000);
l_unit_cds     VARCHAR2(2000);
l_unitcd       VARCHAR2(500);
l_uoo_id       NUMBER;
l_pos          NUMBER;
l_pos1         NUMBER;
BEGIN
  l_uoo_ids_list:=','||p_uoo_ids||',';
  l_pos1:=1;
  LOOP
    l_pos:=l_pos1;
    l_pos1:=INSTR(l_uoo_ids_list,',',l_pos+1);
    EXIT WHEN NVL(l_pos1,0)=0;
    l_uoo_id:=SUBSTR(l_uoo_ids_list,l_pos+1,l_pos1-l_pos-1);

    --This done as if the list contains an invalid uooid, this will prevent the
    --previous unitcd from getting concatenated again.
    l_unitcd:=NULL;

    OPEN c_get_unit_cd(l_uoo_id);
    FETCH c_get_unit_cd INTO l_unitcd;
    CLOSE c_get_unit_Cd;
    IF l_unit_cds IS NOT NULL THEN
      l_unit_cds:=l_unit_cds||',';
    END IF;
    l_unit_cds:=l_unit_cds||l_unitcd;
  END LOOP;
  RETURN l_unit_cds;
END enrp_get_unitcds;

END igs_en_gen_018;


/
