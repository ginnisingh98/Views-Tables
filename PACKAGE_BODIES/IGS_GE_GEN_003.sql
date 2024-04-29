--------------------------------------------------------
--  DDL for Package Body IGS_GE_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_GEN_003" AS
/* $Header: IGSGE03B.pls 120.2 2006/05/30 09:08:06 vskumar noship $ */
/* Change History
   Who        When         What
   jbegum     15-Feb-02    As part of Enh bug #2222272 modified FUNCTION get_org_id
                           Explicitly the org id is being returned as null
               to remove multi org functionality from OSS
   knaraset   14-Nov-2002  added get_person_id,get_program_version,get_calendar_instance,
                           get_susa_sequence_num as part of Build TD Legacy HESA SPA Bug 2661533
   kumma      08-May-2003  2941138, Changed the procedure get_calendar_instance to not to use bind variable for cal_category
                           Bind variables should only be used for alternate code as cal_category is hard_coded in the caller and is not user enterable
   knaraset  29-Apr-03   Added parameter p_uoo_id in procedure GENP_INS_TODO_REF and passed uoo_id in TBH calls of IGS_PE_STD_TODO_REF,
                         as part of MUS build bug 2829262
   pkpatel    11-JUN-2003  Bug 2941138 (Closed the cursors cur_cal_cat_inst_cnt, cur_cal_cat_inst_dtls in procedure get_calendar_instance)
   pkpatel    6-sep-2004   Bug 3868572 (Made the variable l_reference_number from NUMBER(7) to NUMBER)
*/
l_rowid VARCHAR2(25);
FUNCTION GENP_GET_USER_PERSON(
  p_oracle_username IN VARCHAR2 ,
  p_staff_member_ind OUT NOCOPY VARCHAR2 )
RETURN NUMBER AS
    gv_other_detail         VARCHAR2(255);
BEGIN   -- genp_get_user_person
    -- Module to get the IGS_PE_PERSON id for a system user
/*
DECLARE
    v_person_id     IGS_PE_PERSON.person_id%TYPE;
    v_staff_member_ind  IGS_PE_PERSON.staff_member_ind%TYPE;
    CURSOR c_person (
            cp_oracle_username  IGS_PE_PERSON.oracle_username%TYPE) IS
        SELECT  pe.person_id,
            pe.staff_member_ind
        FROM    IGS_PE_PERSON pe
        WHERE   pe.oracle_username = cp_oracle_username;
BEGIN

    OPEN    c_person(
            p_oracle_username);
    FETCH   c_person INTO   v_person_id,
                v_staff_member_ind;
    IF(c_person%NOTFOUND) THEN
        CLOSE c_person;
        p_staff_member_ind := NULL;
        RETURN NULL;
    ELSE
        CLOSE c_person;
        p_staff_member_ind := v_staff_member_ind;
        RETURN v_person_id;
    END IF;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;
      */
        RETURN 0;
END genp_get_user_person;

PROCEDURE GENP_INS_LOG(
  p_s_log_type IN VARCHAR2 ,
  p_key IN VARCHAR2 ,
  p_creation_dt OUT NOCOPY DATE )
AS
    v_other_detail  VARCHAR2(255);
    v_creation_dt   DATE;
    l_rowid             VARCHAR2(25);
BEGIN
    -- this module inserts an entry into the system
    -- log and returns the creation date.
    -- set the creation dt to be the system date
    v_creation_dt := SYSDATE;
    -- insert a record into IGS_GE_S_LOG
    IGS_GE_S_LOG_PKG.INSERT_ROW(
        x_rowid => l_rowid ,
        x_s_log_type => p_s_log_type,
        x_creation_dt =>v_creation_dt,
        x_key =>p_key,
        x_mode => 'R' );
    -- set the output required
    p_creation_dt := v_creation_dt;
EXCEPTION
    WHEN OTHERS THEN
       if SQLCODE <> -20001 then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
          IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception(Null, Null, fnd_message.get);
       else
         RAISE;
        end if;
--      Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
--      App_Exception.Raise_Exception ;
END GENP_INS_LOG;


 PROCEDURE GENP_INS_LOG_ENTRY(
  p_s_log_type IN VARCHAR2 ,
  p_creation_dt IN DATE ,
  p_key IN VARCHAR2 ,
  p_s_message_name IN VARCHAR2 ,
  p_text IN VARCHAR2 )
AS
    l_rowid             VARCHAR2(25);
    v_other_detail  VARCHAR2(350);
    L_VAL NUMBER;
BEGIN
    -- this module inserts and entry into the
    -- system logging structure
    SELECT IGS_GE_S_ERROR_LOG_SEQ_NUM_S.nextval INTO L_VAL
    FROM DUAL;

    IGS_GE_S_LOG_ENTRY_PKG.INSERT_ROW(
        x_rowid => l_rowid ,
        x_s_log_type => p_s_log_type,
        x_creation_dt => p_creation_dt,
        x_sequence_number => L_VAL,
        x_key => p_key,
        x_message_name => p_s_message_name,
        x_text => p_text,
        x_mode => 'R');
EXCEPTION
    WHEN OTHERS THEN
       if SQLCODE <> -20001 then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
          IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception(Null, Null, fnd_message.get);
       else
         RAISE;
        end if;
--      Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
                IGS_GE_MSG_STACK.ADD;
--      App_Exception.Raise_Exception ;
END genp_ins_log_entry;


 FUNCTION genp_ins_stdnt_todo(
  p_person_id IN NUMBER ,
  p_s_student_todo_type IN VARCHAR2 ,
  p_todo_dt IN DATE ,
  p_single_entry_ind IN VARCHAR2)
RETURN NUMBER AS
    gv_other_details        VARCHAR2(255);
    l_rowid             VARCHAR2(25);

BEGIN   -- genp_ins_stdnt_todo
    -- Create a 'todo' item for a student on the IGS_PE_STD_TODO table.
    -- The 'single entry' option, if flagged as Y indicates that if
    -- an outstanding todo entry already exists (with an appropriate
    -- todo date) then another isn't to be created.
    -- The procedure was altered to a function to cater for returning
    -- the sequence number so that it can be used when inserting IGS_PE_STD_TODO_REF
    -- items for the todo item.
DECLARE
    CURSOR c_st (
            cp_person_id        IGS_PE_STD_TODO.person_id%TYPE,
            cp_s_student_todo_type  IGS_PE_STD_TODO.s_student_todo_type%TYPE,
            cp_todo_dt          IGS_PE_STD_TODO.todo_dt%TYPE) IS
        SELECT  sequence_number
        FROM    IGS_PE_STD_TODO
        WHERE   person_id       = cp_person_id AND
            s_student_todo_type     = cp_s_student_todo_type AND
            logical_delete_dt   IS NULL AND
            (todo_dt        IS NULL OR
            todo_dt         <= cp_todo_dt);
    CURSOR c_get_nxt_seq IS
            SELECT IGS_PE_STD_TODO_SEQ_NUM_S.nextval
            FROM DUAL;
    v_st_rec                    c_st%ROWTYPE;
    v_todo_compare              IGS_PE_STD_TODO.todo_dt%TYPE;
    v_sequence_num              NUMBER;
BEGIN
    IF (p_single_entry_ind = 'Y') THEN
        IF (p_todo_dt IS NULL) THEN
            v_todo_compare := SYSDATE;
        ELSE
            v_todo_compare := p_todo_dt;
        END IF;
        OPEN c_st(
            p_person_id,
            p_s_student_todo_type,
            v_todo_compare);
        FETCH c_st INTO v_st_rec;
        IF (c_st%FOUND) THEN
            CLOSE c_st;
            -- Exit routine without inserting
            RETURN v_st_rec.sequence_number;
        END IF;
        CLOSE c_st;
    END IF;
    OPEN c_get_nxt_seq;
    FETCH c_get_nxt_seq INTO v_sequence_num;
    CLOSE c_get_nxt_seq;

    IGS_PE_STD_TODO_PKG.INSERT_ROW (
        x_rowid => l_rowid ,
        X_person_id =>p_person_id,
        x_s_student_todo_type => p_s_student_todo_type,
        x_sequence_number => v_sequence_num,
        x_todo_dt => p_todo_dt,
        x_logical_delete_dt => NULL ,
        x_mode => 'R');
    RETURN v_sequence_num;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;
END genp_ins_stdnt_todo;

 PROCEDURE GENP_SET_SLE_COUNT(
  p_s_log_type IN VARCHAR2 ,
  p_key IN VARCHAR2 ,
  p_sle_key IN VARCHAR2 ,
  p_message_name IN VARCHAR2,
  p_count IN NUMBER ,
  p_creation_dt IN OUT NOCOPY DATE ,
  p_total_count OUT NOCOPY NUMBER )
AS
    gv_other_detail     VARCHAR2(255);
BEGIN   -- genp_set_sle_count
    -- This module is used to keep a count in the IGS_GE_S_LOG_ENTRY table.
    -- It will generally be called by batch routines that keep a count of
    -- records processed up to the point of the routines last commit point.
    -- If an exception is encountered at anytime, then the count will not be
    -- compromised upto the point of last committing and can be used in exception
    -- reporting to indicate the number of records processed
    -- (or what ever the count is to represent).
DECLARE
    v_new_log   BOOLEAN := FALSE;
    v_update_log    BOOLEAN := FALSE;
    v_total_count   NUMBER := 0;
    CURSOR  c_sle IS
        SELECT  rowid, SLE.*
        FROM    IGS_GE_S_LOG_ENTRY  sle
        WHERE   sle.s_log_type  = p_s_log_type AND
            sle.creation_dt = p_creation_dt AND
            sle.key     = p_sle_key
        FOR UPDATE OF sle.text NOWAIT;
BEGIN
    -- Determine if an IGS_GE_S_LOG record exists already
    IF p_creation_dt IS NULL THEN
        -- 20Oct99 - This schema.pkg.proc notation should be removed later on.
        genp_ins_log(
            p_s_log_type,
            p_key,
            p_creation_dt);
        v_new_log := TRUE;
    END IF;
    -- Determine if an entry exists already and update it, otherwise create it.
    FOR v_sle_rec IN c_sle LOOP
    --  v_total_count := TO_NUMBER(v_sle_rec.text) + p_count;

        IGS_GE_S_LOG_ENTRY_pkg.update_row(
            X_ROWID => v_sle_rec.rowid,
            X_S_LOG_TYPE => v_sle_rec.s_log_type ,
            X_CREATION_DT => v_sle_rec.creation_dt ,
            X_SEQUENCE_NUMBER =>v_sle_rec.sequence_number,
            X_KEY => v_sle_rec.key ,
            X_MESSAGE_NAME => v_sle_rec.message_name,
            X_TEXT => TO_CHAR(TO_NUMBER(v_sle_rec.text) + p_count),
            X_MODE => 'R'
            );
        v_update_log :=TRUE;
    END LOOP;
    IF v_new_log OR NOT v_update_log THEN
        v_total_count := p_count;
        genp_ins_log_entry (
            p_s_log_type,
            p_creation_dt,
            p_sle_key,
            p_message_name,
            v_total_count);
    END IF;
    p_total_count := v_total_count;
EXCEPTION
    WHEN OTHERS THEN
        IF c_sle%ISOPEN THEN
            CLOSE c_sle;
        END IF;
        RAISE;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;
END genp_set_sle_count;


 FUNCTION GENP_SET_TIME(
  p_time IN DATE )
RETURN DATE AS
    gv_other_detail         VARCHAR2(255);
BEGIN   -- genp_set_time
    -- This routine will set the date component of a time field to have a
    -- standard date. It will be used when comparing fields where the time
    -- is the only component that is being analysed and the date is superfluous.
DECLARE
BEGIN
    IF(p_time IS NULL) THEN
        RETURN IGS_GE_DATE.IGSDATE(NULL);
    ELSE


        RETURN (IGS_GE_DATE.IGSDATE(IGS_GE_DATE.IGSCHAR(IGS_GE_DATE.IGSDATE('1900/01/01')) ||
                ' ' || TO_CHAR(p_time, 'HH24:MI:SS')));
    END IF;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;
END genp_set_time;


 FUNCTION GENP_UPD_STR_LGC_DEL(
  p_person_id IN NUMBER ,
  p_s_student_todo_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_reference_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN AS
    e_resource_busy_exception           EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54 );
    gv_other_details    VARCHAR2(255);
BEGIN
DECLARE
    v_str_record        IGS_PE_STD_TODO_REF%ROWTYPE;
    v_message_name      VARCHAR2(30);
    v_exists_flag       CHAR;
    CURSOR c_lock_str_records IS
        SELECT  *
        FROM    IGS_PE_STD_TODO_REF
        WHERE   person_id = p_person_id AND
            s_student_todo_type = p_s_student_todo_type AND
            sequence_number = p_sequence_number AND
            reference_number = p_reference_number
        FOR UPDATE
        NOWAIT;
    CURSOR c_chk_other_str_records IS
        SELECT  'x'
        FROM    dual
        WHERE   EXISTS (
                SELECT  person_id
                FROM    IGS_PE_STD_TODO_REF
                WHERE   person_id = p_person_id                     AND
                        s_student_todo_type = p_s_student_todo_type AND
                        sequence_number = p_sequence_number         AND
                        logical_delete_dt IS NULL
                );
    CURSOR SI_PE_TODO_REF_CUR
    IS
    SELECT IGS_PE_STD_TODO_REF.* , ROWID
    FROM IGS_PE_STD_TODO_REF
    WHERE   person_id = p_person_id                         AND
            s_student_todo_type = p_s_student_todo_type     AND
            sequence_number = p_sequence_number             AND
            reference_number = p_reference_number;

BEGIN
    -- Issue a save point so that if a lock occurs, the update can be rolled back.
    SAVEPOINT  sp_str_lgc_del;
    -- Update the IGS_PE_STD_TODO_REF table with the NOWAIT option.
    OPEN c_lock_str_records;
    FETCH c_lock_str_records INTO v_str_record;
    CLOSE c_lock_str_records;

    FOR SI_RE_REC IN SI_PE_TODO_REF_CUR LOOP

    IGS_PE_STD_TODO_REF_PKG.UPDATE_ROW(
        X_ROWID => SI_RE_REC.ROWID,
        X_PERSON_ID => SI_RE_REC.PERSON_ID,
        X_S_STUDENT_TODO_TYPE => SI_RE_REC.S_STUDENT_TODO_TYPE,
        X_SEQUENCE_NUMBER => SI_RE_REC.SEQUENCE_NUMBER,
        X_REFERENCE_NUMBER => SI_RE_REC.REFERENCE_NUMBER,
        X_CAL_TYPE => SI_RE_REC.CAL_TYPE,
        X_CI_SEQUENCE_NUMBER => SI_RE_REC.CI_SEQUENCE_NUMBER,
        X_COURSE_CD => SI_RE_REC.COURSE_CD,
        X_UNIT_CD=> SI_RE_REC.UNIT_CD,
        X_OTHER_REFERENCE=> SI_RE_REC.OTHER_REFERENCE,
        X_LOGICAL_DELETE_DT=> SYSDATE,
        X_MODE=> 'R',
        X_UOO_ID => SI_RE_REC.UOO_ID
        );
    END LOOP;
    -- Determine if there are any remaining IGS_PE_STD_TODO_REF records remaining to
    -- be actioned and if not, then logically delete the IGS_PE_STD_TODO record.
    OPEN c_chk_other_str_records;
    FETCH c_chk_other_str_records INTO v_exists_flag;
    IF c_chk_other_str_records%NOTFOUND THEN
        IF IGS_GE_GEN_004.genp_upd_st_lgc_del(p_person_id,
            p_s_student_todo_type,
            p_sequence_number,
            v_message_name) = FALSE THEN
            CLOSE c_chk_other_str_records;
            ROLLBACK TO sp_str_lgc_del;
            p_message_name := v_message_name;
            RETURN FALSE;
        END IF;
    END IF;
    CLOSE c_chk_other_str_records;
    p_message_name := null;
    RETURN TRUE;
END;
EXCEPTION
    WHEN e_resource_busy_exception THEN
        ROLLBACK TO sp_str_lgc_del;
        p_message_name := 'IGS_GE_LOG_DEL_REF_ITEM_LOCK';
        RETURN FALSE;
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;
END genp_upd_str_lgc_del;

PROCEDURE GENP_INS_TODO_REF(
  p_person_id IN NUMBER ,
  p_s_student_todo_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_other_reference IN VARCHAR2,
  p_uoo_id IN NUMBER)
 IS
 gv_other_detail  VARCHAR2(255);
 l_rowid      VARCHAR2(25);
 l_reference_number NUMBER;
 l_flag VARCHAR2(1) := NULL;
BEGIN -- genp_ins_todo_ref

 -- This routine will insert a student_todo_ref record.

DECLARE

CURSOR c_dup IS
  SELECT 1 FROM IGS_PE_STD_TODO_REF WHERE
  PERSON_ID=P_PERSON_ID AND
  S_STUDENT_TODO_TYPE=P_S_STUDENT_TODO_TYPE AND
  SEQUENCE_NUMBER=P_SEQUENCE_NUMBER AND
  ((CAL_TYPE = P_CAL_TYPE AND CAL_TYPE IS NOT NULL AND P_CAL_TYPE IS NOT NULL) OR (CAL_TYPE IS NULL AND P_CAL_TYPE IS NULL)) AND
  ((CI_SEQUENCE_NUMBER= P_CI_SEQUENCE_NUMBER AND CI_SEQUENCE_NUMBER IS NOT NULL AND P_CI_SEQUENCE_NUMBER IS NOT NULL) OR (CI_SEQUENCE_NUMBER IS NULL AND P_CI_SEQUENCE_NUMBER IS NULL)) AND
  ((COURSE_CD= P_COURSE_CD AND COURSE_CD IS NOT NULL AND P_COURSE_CD IS NOT NULL) OR (COURSE_CD IS NULL AND P_COURSE_CD IS NULL)) AND
  ((UNIT_CD = P_UNIT_CD AND UNIT_CD IS NOT NULL AND P_UNIT_CD IS NOT NULL) OR (UNIT_CD IS NULL AND P_UNIT_CD IS NULL)) AND
  ((UOO_ID = P_UOO_ID AND UOO_ID IS NOT NULL AND P_UOO_ID IS NOT NULL) OR (UOO_ID IS NULL AND P_UOO_ID IS NULL)) AND
  ((OTHER_REFERENCE = P_OTHER_REFERENCE AND OTHER_REFERENCE IS NOT NULL AND P_OTHER_REFERENCE IS NOT NULL) OR (OTHER_REFERENCE IS NULL AND P_OTHER_REFERENCE IS NULL)) AND
  LOGICAL_DELETE_DT IS NULL;


BEGIN

  -- check whether the record being created already exists.
  OPEN c_dup;
  FETCH c_dup INTO L_FLAG;
  CLOSE c_dup;

  IF l_flag IS NULL THEN
    SELECT IGS_PE_STD_TODO_REF_RF_NUM_S.NEXTVAL INTO l_reference_number
                        FROM DUAL;

    IGS_PE_STD_TODO_REF_PKG.INSERT_ROW (
        x_rowid => l_rowid ,
        X_person_id =>p_person_id,
        x_s_student_todo_type => p_s_student_todo_type,
        x_sequence_number => p_sequence_number,
                x_reference_number => l_reference_number,
                x_cal_type  => p_cal_type,
                x_ci_sequence_number=>p_ci_sequence_number,
                x_course_cd => p_course_cd,
                x_unit_cd => p_unit_cd,
                x_other_reference => p_other_reference,
        x_logical_delete_dt => NULL ,
        x_mode => 'R',
        x_uoo_id => p_uoo_id);
  END IF;
/* INSERT INTO student_todo_ref (

    person_id,

    s_student_todo_type,

    sequence_number,

    reference_number,

    cal_type,

    ci_sequence_number,

    course_cd,

    unit_cd,

    other_reference)

 VALUES(

  p_person_id,

  p_s_student_todo_type,

  p_sequence_number,

  str_sequence_number.nextval,

  p_cal_type,

  p_ci_sequence_number,

  p_course_cd,

  p_unit_cd,

  p_other_reference);*/

END;


EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS' , 'IGS_GE_UNHANDLED_EXCEPTION');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;

END genp_ins_todo_ref;


FUNCTION get_org_id RETURN NUMBER AS
 CURSOR get_orgid IS
   SELECT
   NVL ( TO_NUMBER ( DECODE ( SUBSTRB ( USERENV ('CLIENT_INFO'
                                                ), 1, 1
                                      ), ' ', NULL,  SUBSTRB (USERENV ('CLIENT_INFO'),1,10)
                             )
                   ), NULL
       )
 FROM dual;
   l_org_id        NUMBER(15);
BEGIN
 -- Commented out by jbegum as part of Enh bug #2222272
 -- This code has been commented out to remove multi org functionality from OSS
 /* OPEN    get_orgid;
  FETCH   get_orgid  INTO    l_org_id;
  CLOSE   get_orgid;*/
  -- Added by jbegum as part of Enh bug #2222272
  -- The org_id is being passed as null to remove multi org functionality from OSS
  l_org_id := NULL;
  RETURN l_org_id;
END get_org_id;

PROCEDURE set_org_id(p_context IN VARCHAR2) AS
p_org_id VARCHAR2(15);

BEGIN
  IF disable_oss = 'Y' THEN
     fnd_message.set_name ('IGS', 'IGS_GE_CONC_NOT_AVAIL_R12');
     fnd_file.put_line (fnd_file.LOG, fnd_message.get);
     fnd_msg_pub.ADD;
     RAISE g_oss_disable_exception;
  END IF;

  IF p_context is NULL THEN
    FND_PROFILE.GET('ORG_ID',p_org_id);
  ELSE
    p_org_id := p_context;
  END IF;
  FND_CLIENT_INFO.SET_ORG_CONTEXT(p_org_id);
END set_org_id;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose:Function to get the person ID for the given person number
--        returns NULL if no person or more than one person found in the system.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION get_person_id(
  p_person_number IN VARCHAR2)
RETURN NUMBER AS

-- cursor to select person ID corresponding to the given person number
-- This cursor will fetch no records when the person is not exists in the system
-- or more than one person is matching the criteria.
CURSOR cur_person_id IS
SELECT person_id
FROM igs_pe_person_base_v
WHERE person_number = p_person_number
AND 1 = (SELECT COUNT(*)
         FROM igs_pe_person_base_v
         WHERE person_number = p_person_number);

l_person_id igs_pe_person_base_v.person_id%TYPE;
BEGIN

  l_person_id := NULL;

  IF p_person_number IS NOT NULL THEN
     OPEN  cur_person_id;
     FETCH cur_person_id INTO l_person_id;
     CLOSE cur_person_id;
  END IF;

  RETURN l_person_id;

EXCEPTION
   WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME', 'igs_ge_gen_003.get_person_id');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

END get_person_id;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose:Function to get the version number for the given program attempt
--        returns NULL if no program attempt found in the system.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
FUNCTION get_program_version(
  p_person_id IN NUMBER,
  p_program_cd IN VARCHAR2)
RETURN NUMBER AS

-- cursor to select version number of the program for the given program attempt
-- This cursor will fetch no records when the program attempt is not exists in the system
--
CURSOR cur_prgm_version IS
SELECT version_number
FROM igs_en_stdnt_ps_att
WHERE person_id = p_person_id
AND course_cd = p_program_cd;

l_prgm_version igs_en_stdnt_ps_att.version_number%TYPE;

BEGIN

  l_prgm_version := NULL;

  IF p_person_id IS NOT NULL AND p_program_cd IS NOT NULL THEN
     OPEN cur_prgm_version;
     FETCH cur_prgm_version INTO l_prgm_version;
     CLOSE cur_prgm_version;
  END IF;

  RETURN l_prgm_version;

EXCEPTION
   WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME', 'igs_ge_gen_003.get_program_version');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

END get_program_version;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose:procedure which returns the calendar details of the given caledar alternate code as OUT params.
--        returns NULL if no calendar instance found or more than one calendar instance found in the system.
--
--Known limitations/enhancements and/or remarks:
--
-- Parameter p_s_cal_category is optional, if specified then it will be used to filter the calendar instance
-- if the value is NULL then category filter will not be used.
-- if the value is specified it should be with proper quotes.
-- ex.  p_s_cal_category => '''LOAD'',''ACADEMIC'''
--
--Change History:
--Who         When               What
--KUMMA       13-may-2003        2941138, Replaced p_alternate_code with the bind variable
--vskumar     24-May-2006	 xbuild3 performance fix. added a calander type parse code and used fnd_dsql.
------------------------------------------------------------------  */
 PROCEDURE get_calendar_instance(
  p_alternate_cd IN VARCHAR2,
  p_s_cal_category IN VARCHAR2,
  p_cal_type OUT NOCOPY VARCHAR2,
  p_ci_sequence_number OUT NOCOPY NUMBER,
  p_start_dt OUT NOCOPY DATE,
  p_end_dt OUT NOCOPY DATE,
  p_return_status OUT NOCOPY VARCHAR2) AS

-- REF cursor type variable
TYPE cur_cal_inst IS REF CURSOR;

cur_cal_cat_inst_dtls cur_cal_inst; -- REF cursor variable for calendar details
cur_cal_cat_inst_cnt cur_cal_inst; -- REF cursor variable for calendar instances count

--
-- cursor to fetch the count of calendar instances exists for the given alternate code
CURSOR cur_cal_inst_cnt IS
SELECT count(*)
FROM igs_ca_inst
WHERE alternate_code = p_alternate_cd;

--
-- cursor to fetch the details of calendar instances for the given alternate code
CURSOR cur_cal_inst_dtls IS
SELECT cal_type,sequence_number,start_dt,end_dt
FROM igs_ca_inst
WHERE alternate_code = p_alternate_cd;

l_cal_inst_cnt NUMBER;
l_cal_cat_inst_cnt NUMBER;
l_cal_cat_dtls_query VARCHAR2(1000);
l_cal_cat_cnt_query VARCHAR2(1000);

curr_pos_lv NUMBER;
next_pos_lv NUMBER;
token_lv    VARCHAR2(50);
l_cursor_id NUMBER(15);
l_num_of_rows NUMBER(10);
l_p_s_cal_category VARCHAR2(100);

BEGIN
  p_cal_type := NULL;
  p_ci_sequence_number := NULL;
  p_start_dt := NULL;
  p_end_dt := NULL;
  p_return_status := 'INVALID';
  l_p_s_cal_category :=REPLACE(p_s_cal_category,'''','');

  IF p_alternate_cd IS NOT NULL THEN

     -- If calendar category is specified then category should be used in criteria of fetching data along with alternate code
     IF p_s_cal_category IS NOT NULL THEN

        l_cal_cat_inst_cnt := 0;
	p_cal_type := NULL;
        p_ci_sequence_number := NULL;
        p_start_dt := TO_DATE(NULL);
        p_end_dt := TO_DATE(NULL);

	fnd_dsql.init;
	curr_pos_lv := 1;
	next_pos_lv := 1;

	-- Query to get the count of calendar instances for the given alternate code and calendar categories

	fnd_dsql.add_text('SELECT ci.cal_type,ci.sequence_number,ci.start_dt,ci.end_dt FROM igs_ca_inst_all ci, igs_ca_type ct WHERE alternate_code =');
	fnd_dsql.add_bind(p_alternate_cd);
	fnd_dsql.add_text(' AND ci.cal_type = ct.cal_type AND ct.s_cal_cat IN (');

	LOOP
	  next_pos_lv := INSTR(l_p_s_cal_category, ',', curr_pos_lv);
	  IF next_pos_lv = 0 THEN
	    token_lv := SUBSTR(l_p_s_cal_category,curr_pos_lv);
	    fnd_dsql.add_bind(token_lv);
	    fnd_dsql.add_text(')');
	    EXIT;
	  END IF;
	    token_lv := SUBSTR(l_p_s_cal_category, curr_pos_lv, next_pos_lv-curr_pos_lv);
	    fnd_dsql.add_bind(token_lv);
	    fnd_dsql.add_text(',');
	    curr_pos_lv := next_pos_lv + 1;
	END LOOP;

	l_cal_cat_cnt_query := fnd_dsql.get_text(FALSE);

        l_cursor_id := dbms_sql.open_cursor;
        fnd_dsql.set_cursor(l_cursor_id);
        dbms_sql.parse(l_cursor_id, l_cal_cat_cnt_query, dbms_sql.native);
        fnd_dsql.do_binds;

	dbms_sql.define_column(l_cursor_id, 1, p_cal_type,10);
	dbms_sql.define_column(l_cursor_id, 2, p_ci_sequence_number);
	dbms_sql.define_column(l_cursor_id, 3, p_start_dt);
	dbms_sql.define_column(l_cursor_id, 4, p_end_dt);

	l_num_of_rows := dbms_sql.EXECUTE(l_cursor_id);
	LOOP
           IF dbms_sql.fetch_rows(l_cursor_id) > 0 THEN
	      l_cal_cat_inst_cnt := l_cal_cat_inst_cnt + 1;
	   ELSE
              EXIT;
           END IF;
        END LOOP;


       IF l_cal_cat_inst_cnt = 0 THEN
          p_return_status := 'INVALID';

       ELSIF l_cal_cat_inst_cnt > 1 THEN
          p_return_status := 'MULTIPLE';

       ELSE
          p_return_status := 'SINGLE';
          dbms_sql.column_value(l_cursor_id, 1, p_cal_type);
          dbms_sql.column_value(l_cursor_id, 2, p_ci_sequence_number);
          dbms_sql.column_value(l_cursor_id, 3, p_start_dt);
          dbms_sql.column_value(l_cursor_id, 4, p_end_dt);

	  dbms_sql.close_cursor(l_cursor_id);
       END IF;

     ELSE -- p_s_cal_category is NULL
       -- Calendar category is not specified, so only alternate code will be used as criteria for fetching data
       OPEN cur_cal_inst_cnt;
       FETCH cur_cal_inst_cnt INTO l_cal_inst_cnt;
       CLOSE cur_cal_inst_cnt;

       IF l_cal_inst_cnt = 0 THEN
          p_return_status := 'INVALID';
       ELSIF l_cal_inst_cnt > 1 THEN
          p_return_status := 'MULTIPLE';
       ELSE
          p_return_status := 'SINGLE';
          OPEN cur_cal_inst_dtls;
          FETCH cur_cal_inst_dtls INTO p_cal_type,p_ci_sequence_number,p_start_dt,p_end_dt;
          CLOSE cur_cal_inst_dtls;
       END IF;
     END IF; -- p_s_cal_category <> NULL
  END IF; -- p_alternate_cd <> NULL

  RETURN;

EXCEPTION
   WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME', 'igs_ge_gen_003.get_calendar_instance');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

END get_calendar_instance;

/*------------------------------------------------------------------
--Created by  : knaraset, Oracle IDC
--Date created: 14-Nov-2002
--
--Purpose: procedure which returns the unit set version number and sequence number of the given unit set attempt.
--         returns NULL if no unit set attempt found or more than one unit set attempt found in the system.
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When               What
--
------------------------------------------------------------------  */
PROCEDURE get_susa_sequence_num(
  p_person_id IN NUMBER,
  p_program_cd IN VARCHAR2,
  p_unit_set_cd IN VARCHAR2,
  p_us_version_number OUT NOCOPY NUMBER,
  p_sequence_number OUT NOCOPY NUMBER) AS

-- cursor to select version number,sequence number of the given unit set attempt
-- This cursor will fetch no records when the unit set attempt is not exists in the system
-- or more than one unit set attempt is matching the criteria.
CURSOR cur_susa_dtl IS
SELECT us_version_number,sequence_number
FROM igs_as_su_setatmpt
WHERE person_id = p_person_id
AND course_cd = p_program_cd
AND unit_set_cd = p_unit_set_cd
AND 1 = (SELECT COUNT(*)
         FROM igs_as_su_setatmpt
         WHERE person_id = p_person_id
         AND course_cd = p_program_cd
     AND unit_set_cd = p_unit_set_cd);

BEGIN

  p_us_version_number := NULL;
  p_sequence_number := NULL;

  IF p_person_id IS NOT NULL AND p_program_cd IS NOT NULL AND p_unit_set_cd IS NOT NULL THEN
     OPEN cur_susa_dtl;
     FETCH cur_susa_dtl INTO p_us_version_number,p_sequence_number;
     CLOSE cur_susa_dtl;
  END IF;

  RETURN;
EXCEPTION
   WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME', 'igs_ge_gen_003.get_susa_sequence_num');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

END get_susa_sequence_num;

FUNCTION disable_oss RETURN VARCHAR2 AS
BEGIN
   IF(FND_PROFILE.VALUE('IGS_RELEASE_VERSION') = '12IGSA') THEN
       RETURN 'Y';
   ELSE
       RETURN 'N';
   END IF;
END disable_oss;

END igs_ge_gen_003 ;

/
