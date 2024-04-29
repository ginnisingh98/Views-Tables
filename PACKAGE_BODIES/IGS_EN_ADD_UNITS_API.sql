--------------------------------------------------------
--  DDL for Package Body IGS_EN_ADD_UNITS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ADD_UNITS_API" AS
/* $Header: IGSEN93B.pls 120.39 2006/08/25 13:55:14 bdeviset noship $ */

--package variables
g_debug_level   CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_person_type   igs_pe_typ_instances.person_type_code%TYPE;

TYPE l_units_rec IS RECORD (
        uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE,
        ass_ind igs_en_su_attempt.no_assessment_ind%TYPE,
        grading_schema_cd igs_en_su_attempt.grading_schema_code%TYPE,
        gs_version_number  igs_en_su_attempt. gs_version_number %TYPE,
        override_enrolled_cp igs_en_su_attempt.override_enrolled_cp%TYPE,
        spl_perm_step VARCHAR2(200),
        aud_perm_step VARCHAR2(200),
        wlst_step VARCHAR2(200),
        create_wlst VARCHAR2(1)
     );

TYPE t_params_table IS TABLE OF l_units_rec INDEX BY BINARY_INTEGER;


FUNCTION set_deny_warn (
                        p_person_id                 IN igs_en_su_attempt.person_id%TYPE,
                        p_course_cd                 IN igs_en_su_attempt.course_cd%TYPE,
                        p_load_cal_type             IN igs_ca_inst.cal_type%TYPE,
                        p_load_sequence_number    IN igs_ca_inst.sequence_number%TYPE
                        )
                        RETURN VARCHAR2 AS
 -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose : returns deny if atleast one deny record exists and warn if only warn records
  -- else returns null
  --Change History:
  --Who         When            What
  --ckasu      18-OCT-2005    modfied as a part of bug#4674099 inorder to return 'D' as atleast
  --                          one deny record exists else return warn even if atlest one record
  --                          other than deny exists in warnings table.
  -------------------------------------------------------------------------------------------

  CURSOR get_deny_warn(cp_msg_icon VARCHAR2) IS
  SELECT 'X'
  FROM igs_en_std_warnings
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND term_cal_type = p_load_cal_type
  AND term_ci_sequence_number = p_load_sequence_number
  AND message_icon = cp_msg_icon
  AND step_type <> 'DROP';

  CURSOR get_error_warn IS
  SELECT 'X'
  FROM igs_en_std_warnings
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND term_cal_type = p_load_cal_type
  AND term_ci_sequence_number = p_load_sequence_number
  AND message_icon <> 'D'
  AND step_type <> 'DROP';

  l_deny_warn             VARCHAR2(1);
  l_msg_icon              igs_en_std_warnings.message_icon%TYPE;

BEGIN

  l_deny_warn := NULL;

  -- if any deny  records are found then set deny_warn flag to 'D' and return
  OPEN get_deny_warn('D');
  FETCH get_deny_warn INTO l_msg_icon;
    IF get_deny_warn%FOUND THEN
      CLOSE get_deny_warn;
      l_deny_warn := 'D';
      RETURN l_deny_warn;
    END IF;
  CLOSE get_deny_warn;

  --  if any error or warn records are found then set deny_warn flag to 'W' and return

  OPEN get_error_warn;
  FETCH get_error_warn INTO l_msg_icon;
    IF get_error_warn%FOUND THEN
      CLOSE get_error_warn;
      l_deny_warn := 'W';
      RETURN l_deny_warn;
    END IF;
  CLOSE get_error_warn;

  RETURN NULL;

EXCEPTION
    WHEN OTHERS THEN

      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.set_deny_warn :',SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.set_deny_warn');
      IGS_GE_MSG_STACK.ADD;
      RAISE;
END set_deny_warn;


PROCEDURE check_sua_exists(p_person_id IN NUMBER,
                         p_course_cd IN VARCHAR2,
                         p_load_cal_type IN VARCHAR2,
                         p_load_sequence_number IN NUMBER,
                         p_selected_uoo_ids IN VARCHAR2,
                         p_message OUT NOCOPY VARCHAR2) AS
PRAGMA  AUTONOMOUS_TRANSACTION;

 -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose : This  procedure checks if the selected uoo id already exists and if so
  -- returns sua already exists.It also checks if any ps error record unit already exits in
  -- sua table and if so deletes the ps error record
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

-- cursor to get planning sheet error units
CURSOR cur_fetch_ps_err_units IS
SELECT ROWID,uoo_id
FROM igs_en_plan_units
WHERE person_id = p_person_id
AND course_cd = p_course_cd
AND term_cal_type = p_load_cal_type
AND term_ci_sequence_number = p_load_sequence_number
AND cart_error_flag = 'Y';



CURSOR c_sua_exists(cp_uoo_id NUMBER) IS
SELECT 'X'
FROM igs_en_su_attempt
WHERE person_id = p_person_id
AND course_cd = p_course_cd
AND uoo_id = cp_uoo_id
AND unit_attempt_status <> 'DROPPED';

l_sua_exists  VARCHAR2(1);
l_sel_uoo_ids VARCHAR2(1000);
l_uoo_id      NUMBER;


BEGIN

  l_sel_uoo_ids :=  p_selected_uoo_ids;

  FOR l_ps_err_rec IN  cur_fetch_ps_err_units LOOP
    l_sua_exists := NULL;
    OPEN c_sua_exists(l_ps_err_rec.uoo_id);
    FETCH c_sua_exists INTO l_sua_exists;
    CLOSE c_sua_exists;

    IF l_sua_exists IS NOT NULL THEN

      IGS_EN_PLAN_UNITS_PKG.DELETE_ROW(x_rowid => l_ps_err_rec.ROWID);

    END IF;

  END LOOP;

  COMMIT;
  l_sua_exists := NULL;

  WHILE l_sel_uoo_ids IS NOT NULL LOOP

    IF(instr(l_sel_uoo_ids,';',1) = 0) THEN
        l_sel_uoo_ids := NULL;
    END IF;

     -- lunit is 1234,Y,P/F,233,343
    l_uoo_id := substr( l_sel_uoo_ids,1,instr(l_sel_uoo_ids,',')-1);

    OPEN c_sua_exists(l_uoo_id);
    FETCH c_sua_exists INTO l_sua_exists;
    CLOSE c_sua_exists;

    IF l_sua_exists IS NOT NULL THEN
      p_message := 'IGS_EN_SUA_EXISTS'||'*'||get_unit_sec(l_uoo_id);
      RETURN;
    END IF;

    -- Remove the uoo id details which is extacted  above
    l_sel_uoo_ids := substr(l_sel_uoo_ids,instr(l_sel_uoo_ids,';',1)+1);

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.chk_sua_exists');
        IGS_GE_MSG_STACK.ADD;
        IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
              FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.chk_sua_exists :',SQLERRM);
        END IF;
        ROLLBACK;
        RAISE;

END check_sua_exists;

PROCEDURE update_warnings_table  (p_person_id IN NUMBER,
                                  p_course_cd IN VARCHAR2,
                                  p_load_cal_type IN VARCHAR2,
                                  p_load_sequence_number IN NUMBER,
                                  p_calling_obj IN VARCHAR2) AS
PRAGMA  AUTONOMOUS_TRANSACTION;

 -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose : This table updates the message icon of deny warnings records of those units which are not in sua table
  -- and planning sheet (if calling object is not plan then checl for error records only) to 'I'
  --Change History:
  --Who         When            What
  --bdeviset    27-oct-2005     The deny record which does not have corresponding unit in the cart
  --                            is updated to 'I'(previously it was updated to 'E').Also concatenated
  --                            two message texts with the same message text for the same record
  --                            for bug# 4671726

  -------------------------------------------------------------------------------------------


-- cursor to get distinct uooids in warnings table with message icon as 'D'
CURSOR c_dist_uooids IS
SELECT DISTINCT uoo_id
FROM igs_en_std_warnings
WHERE person_id =  p_person_id
AND course_cd = p_course_cd
AND term_cal_type =  p_load_cal_type
AND term_ci_sequence_number = p_load_sequence_number
AND message_icon = 'D'
AND step_type <> 'DROP';

-- cursor to check if sua record exits
CURSOR chk_sua_exists (cp_uoo_id NUMBER)IS
SELECT 'X'
FROM igs_en_su_attempt
WHERE person_id = p_person_id
AND course_cd = p_course_cd
AND uoo_id = cp_uoo_id
AND unit_attempt_Status <> 'DROPPED';

-- cursor to check if planning sheet error record exits
CURSOR chk_ps_err_rec_exists (cp_uoo_id NUMBER)IS
SELECT 'X'
FROM igs_en_plan_units
WHERE person_id =  p_person_id
AND course_cd = p_course_cd
AND uoo_id = cp_uoo_id
AND cart_error_flag = 'Y';

CURSOR get_warn_rec (cp_uoo_id NUMBER) IS
SELECT ROWID,warn.*
FROM igs_en_std_warnings warn
WHERE warn.person_id =  p_person_id
AND warn.course_cd = p_course_cd
AND warn.term_cal_type =  p_load_cal_type
AND warn.term_ci_sequence_number = p_load_sequence_number
AND warn.message_icon = 'D'
AND warn.step_type <> 'DROP'
AND warn.uoo_id = cp_uoo_id;

l_sua_exists VARCHAR2(1);
l_ps_rec_exists VARCHAR2(1);
l_message1  VARCHAR2(2000);
l_message2  VARCHAR2(2000);

BEGIN
 -- if calling object is in PLAN or SUBMITPLAN then dont update the warnings record
 IF p_calling_obj IN ('PLAN','SUBMITPLAN') THEN
  RETURN;
 END IF;

-- get distinct uoo ids for this person course term calendar and term cal sequence number in warnings table having deny records
-- check whether record exists in sua or (ps error records or in planning sheet for plan)
-- if it does not exists then update the warnings records of those uoo ids having 'D' as 'I'

-- get the message text to be concatenated to the message text of a record in warnings table
-- which does not have a corresponding unit in the cart.
FND_MESSAGE.SET_NAME('IGS','IGS_EN_ERROR_UNITS');
l_message1 := FND_MESSAGE.GET();

FND_MESSAGE.SET_NAME('IGS','IGS_SS_EN_SEE_ADMIN');
l_message2 := FND_MESSAGE.GET();

FOR dist IN c_dist_uooids LOOP
  l_sua_exists := NULL;
  l_ps_rec_exists := NULL;

  OPEN chk_sua_exists(dist.uoo_id);
  FETCH chk_sua_exists INTO l_sua_exists;
  CLOSE chk_sua_exists;

  -- if the calling obj is not plan then check for planning sheet error record
  OPEN chk_ps_err_rec_exists(dist.uoo_id);
  FETCH chk_ps_err_rec_exists INTO l_ps_rec_exists;
  CLOSE chk_ps_err_rec_exists;


  IF l_sua_exists IS NULL AND l_ps_rec_exists IS NULL THEN

    FOR l_warn_rec IN  get_warn_rec(dist.uoo_id) LOOP

      IGS_EN_STD_WARNINGS_PKG.UPDATE_ROW (
                                          x_rowid                     =>  l_warn_rec.rowid,
                                          x_warning_id                =>  l_warn_rec.warning_id,
                                          x_person_id                 =>  p_person_id,
                                          x_course_cd                 =>  p_course_cd,
                                          x_uoo_id                    =>  dist.uoo_id,
                                          x_term_cal_type             =>  p_load_cal_type,
                                          x_term_ci_sequence_number   =>  p_load_sequence_number,
                                          x_message_for               =>  l_warn_rec.message_for,
                                          x_message_icon              =>  'I',
                                          x_message_name              =>  l_warn_rec.message_name,
                                          x_message_text              =>  l_message1||' '||l_warn_rec.message_text||' '||l_message2,
                                          x_message_action            =>  l_warn_rec.message_action,
                                          x_destination               =>  l_warn_rec.destination,
                                          x_p_parameters              =>  l_warn_rec.p_parameters,
                                          x_step_type                 =>  l_warn_rec.step_type,
                                          x_session_id                =>  igs_en_add_units_api.g_ss_session_id,
                                          x_mode                      =>  'R'    );
     END LOOP;


  END IF;


END LOOP;
COMMIT;

EXCEPTION
  WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.update_warnings_table');
        IGS_GE_MSG_STACK.ADD;
        IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
              FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.update_warnings_table :',SQLERRM);
        END IF;
        ROLLBACK;
        RAISE;

END update_warnings_table;


FUNCTION get_unit_sec(p_uoo_id IN NUMBER)
        RETURN VARCHAR2 AS

 -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose : returns concatenated string of unit_cd and unit class for the passed in uoo_id
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

CURSOR c_get_unit_sec(cp_uoo_id  IGS_PS_UNIT_OFR_OPT.sup_uoo_id%TYPE) IS
SELECT unit_cd||'/'||unit_class unit_sec
FROM IGS_PS_UNIT_OFR_OPT
WHERE uoo_id = cp_uoo_id;

l_unit_sec              VARCHAR2(50);

BEGIN

  OPEN c_get_unit_sec(p_uoo_id);
  FETCH c_get_unit_sec INTO l_unit_sec;
  CLOSE c_get_unit_sec;

  RETURN l_unit_sec;

EXCEPTION
    WHEN OTHERS THEN

      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.get_unit_sec :',SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.get_unit_sec');
      IGS_GE_MSG_STACK.ADD;
      RAISE;
END get_unit_sec;

FUNCTION  get_person_type (
                            p_course_cd VARCHAR2

                          ) RETURN VARCHAR2 AS

 -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose : returns person type
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------


  -- cursor to get person type
  CURSOR cur_per_typ IS
  SELECT person_type_code
  FROM igs_pe_person_types
  WHERE system_type = 'OTHER';

  l_cur_per_typ               igs_pe_typ_instances.person_type_code%TYPE;
  lv_person_type              igs_pe_typ_instances.person_type_code%TYPE;

BEGIN

  OPEN cur_per_typ;
  FETCH cur_per_typ INTO l_cur_per_typ;
  lv_person_type := NVL(Igs_En_Gen_008.enrp_get_person_type(p_course_cd),l_cur_per_typ);
  CLOSE cur_per_typ;

  RETURN lv_person_type;

EXCEPTION
    WHEN OTHERS THEN

      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.get_person_type :',SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.get_person_type');
      IGS_GE_MSG_STACK.ADD;
      RAISE;
END get_person_type;


PROCEDURE delete_ss_warnings (p_person_id IN NUMBER,
                              p_course_cd IN VARCHAR2,
                              p_load_cal_type IN VARCHAR2,
                              p_load_sequence_number IN NUMBER,
                              p_uoo_id IN NUMBER,
                              p_message_for IN VARCHAR2,
                              p_delete_steps IN VARCHAR2
                              ) AS
PRAGMA  AUTONOMOUS_TRANSACTION;

 -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose : deletes the warnings records as per parameters passed
  -- if p_delete_steps then step type is not considered while deleting
  -- else it is considered
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

  --  -- cursor to get the warnings records against the person,course and uooid/message_for
  CURSOR c_ss_warn IS
  SELECT ROWID
  FROM IGS_EN_STD_WARNINGS
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND term_cal_type = p_load_cal_type
  AND term_ci_sequence_number  = p_load_sequence_number
  AND ((p_uoo_id IS NOT NULL AND uoo_id = p_uoo_id) OR
        message_for = p_message_for)
  AND step_type <> 'DROP';

   TYPE c_ref_cursor IS REF CURSOR;
   c_ss_warn_of_steps             c_ref_cursor;
   l_rowid                        VARCHAR2(30);
   l_stmt                         VARCHAR2(1000);

BEGIN

    -- if p_delete_steps is null then
    IF p_delete_steps IS NULL THEN
  OPEN c_ss_warn;
  WHILE TRUE LOOP

    FETCH c_ss_warn INTO l_rowid;
    IF c_ss_warn%NOTFOUND THEN
      CLOSE c_ss_warn;
      EXIT;
    END IF;

    IGS_EN_STD_WARNINGS_PKG.delete_row(x_rowid => l_rowid);


  END LOOP;
  ELSE
    -- dynamic cursor to get the warnings records against the person for given steps


    IF p_uoo_id IS NOT NULL THEN

     l_stmt := 'SELECT ROWID
                FROM IGS_EN_STD_WARNINGS
                WHERE person_id = :p_person_id
                AND   course_cd =  :p_course_cd
                AND   term_cal_type = :p_load_cal_type
                AND   term_ci_sequence_number  = :p_load_sequence_number
                AND   step_type IN ( ''' || p_delete_steps ||''')
                AND   uoo_id = :p_uooo_id' ;
     OPEN c_ss_warn_of_steps FOR l_stmt USING p_person_id,p_course_cd,p_load_cal_type,p_load_sequence_number,p_uoo_id;

    ELSE

     l_stmt := 'SELECT ROWID
                FROM IGS_EN_STD_WARNINGS
                WHERE person_id = :p_person_id
                AND   course_cd =  :p_course_cd
                AND   term_cal_type = :p_load_cal_type
                AND   term_ci_sequence_number  = :p_load_sequence_number
                AND   step_type IN (''' || p_delete_steps || ''')';

     OPEN c_ss_warn_of_steps FOR l_stmt USING p_person_id,p_course_cd,p_load_cal_type,p_load_sequence_number;

    END IF;

    LOOP
      FETCH c_ss_warn_of_steps INTO l_rowid;
      IF c_ss_warn_of_steps%NOTFOUND THEN
        CLOSE c_ss_warn_of_steps;
        EXIT;
      END IF;

      IGS_EN_STD_WARNINGS_PKG.delete_row(x_rowid => l_rowid);


    END LOOP;

  END IF;

  COMMIT;

EXCEPTION
    WHEN OTHERS THEN

      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.delete_ss_warnings :',SQLERRM);
      END IF;
      ROLLBACK;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.delete_ss_warnings');
      IGS_GE_MSG_STACK.ADD;
      RAISE;

END delete_ss_warnings;


FUNCTION chk_sua_creation_is_valid (
                                    p_person_id IN NUMBER,
                                    p_course_cd IN VARCHAR2,
                                    p_uoo_id    IN NUMBER,
                                    p_load_cal_type IN VARCHAR2,
                                    p_load_sequence_number IN NUMBER,
                                    p_unit_params IN t_params_table,
                                    p_selected_units IN VARCHAR2
                                   ) RETURN BOOLEAN AS

 -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose : returns true if unit attempt can be created else false

  -- If the unit is not a subordinate then returns true
  -- if the unit is a subordiante and selected by system and superior has taken a seat then returns true
  -- else returns false
  -- if the unit is a subordiante and selected by user and superior exists in 'UNCONFIRM','INVALID','WAITLISTED','ENROLLED'
  -- statuses then returns true else false

  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------



-- cursor to check wheter a unit is subordinate
CURSOR cur_chk_unit_is_sub(cp_uoo_id igs_en_su_attempt.uoo_id%TYPE)IS
SELECT sup_uoo_id
FROM igs_ps_unit_ofr_opt
WHERE uoo_id = cp_uoo_id
AND sup_uoo_id IS NOT NULL
AND relation_type = 'SUBORDINATE';


-- cursor to check whheter a unit attempt  exists in particular statuses
CURSOR cur_chk_sup_exists(cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
SELECT 'X' FROM igs_en_su_attempt
WHERE person_id = p_person_id
AND course_cd = p_course_cd
AND uoo_id = cp_uoo_id
AND unit_attempt_status IN  ('UNCONFIRM','INVALID','WAITLISTED','ENROLLED');

l_sup_uoo_id          igs_ps_unit_ofr_opt.sup_uoo_id%TYPE;
l_create_sub          BOOLEAN;
l_sup_created         BOOLEAN;
l_sup_exists          VARCHAR2(1);
l_unit_sec            VARCHAR2(100);
BEGIN


      OPEN cur_chk_unit_is_sub(p_uoo_id);
      FETCH cur_chk_unit_is_sub INTO l_sup_uoo_id;
      CLOSE cur_chk_unit_is_sub;

       -- if the unit is not subordinate then return true
      IF l_sup_uoo_id IS NULL THEN

        RETURN TRUE;

      -- if this unit is a subordinate unit
      ELSE

          -- initially set the create subordinate flag to true
          l_create_sub := TRUE;



          --check if subordinate unit is in the selected list (if it is then it means it is selected by user else it is means
          -- it is selected by the system).

           -- check if it is selected by system or not
          IF instr(p_selected_units,','||p_uoo_id||',') = 0 THEN

                -- if subordinate has been automatically selected by the system, check if the superior has taken a seat/waitlisted.
                -- if superior has not taken a seat then donot select this subordinate.

                -- check if superior has taken a seat or not.
                l_sup_created := FALSE;
                FOR j IN 1..p_unit_params.count LOOP
                    IF  p_unit_params(j).uoo_id  = l_sup_uoo_id AND
                      p_unit_params(j).spl_perm_step = 'PERM_NREQ' AND
                       p_unit_params(j).aud_perm_step = 'PERM_NREQ' AND
                      p_unit_params(j).wlst_step = 'N' THEN
                      l_sup_created := TRUE;
                    END IF;
                END LOOP;

                IF NOT l_sup_created   THEN

                  -- Call method to delete the warning records created for this subordinate uoo_id for this person,
                  -- term, course in context.and dont create subordinate unit
                  l_create_sub := FALSE;
                  delete_ss_warnings( p_person_id,
                                      p_course_cd,
                                      p_load_cal_type,
                                      p_load_sequence_number,
                                      p_uoo_id,
                                      NULL,
                                      'PROGRAM'',''UNIT');
                END IF; -- IF NOT l_sup_created   THEN

          -- subordinate is selected by the user
          ELSE

                -- check if  superior exists in proper status for subordinate to be created in unconfirm status
                OPEN cur_chk_sup_exists(l_sup_uoo_id);
                FETCH cur_chk_sup_exists INTO l_sup_exists;
                CLOSE cur_chk_sup_exists;

                -- if not then log a warning record saying subordinate cannot be added
                IF l_sup_exists IS NULL THEN

                    -- set the create subordinate create flag to false
                    l_create_sub := FALSE;

                    l_unit_sec := get_unit_sec(l_sup_uoo_id);

                    igs_en_drop_units_api.create_ss_warning(
                                     p_person_id => p_person_id,
                                     p_course_cd => p_course_cd,
                                     p_term_cal_type => p_load_cal_type,
                                     p_term_ci_sequence_number =>  p_load_sequence_number,
                                     p_uoo_id => p_uoo_id,
                                     p_message_for => l_unit_sec,
                                     p_message_icon=> 'D',
                                     p_message_name => 'IGS_EN_CANNOT_ADD_SUB',
                                     p_message_rule_text => NULL,
                                     p_message_tokens => NULL,
                                     p_message_action => NULL,
                                     p_destination => NULL,
                                     p_parameters => NULL,
                                     p_step_type => 'UNIT');

                END IF; -- IF NOT l_sup_exists

           END IF; -- IF instr(p_selected_units,','||p_uoo_id||',') = 0

      END IF; -- IF l_sup_uoo_id IS NOT NULL THEN

      RETURN l_create_sub;

EXCEPTION

    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.chk_sua_creation_is_valid :',SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.chk_sua_creation_is_valid');
      IGS_GE_MSG_STACK.ADD;
      RAISE;
END chk_sua_creation_is_valid;

PROCEDURE create_ps_record( p_person_id             IN NUMBER,
                            p_course_cd             IN VARCHAR2,
                            p_load_cal_type         IN VARCHAR2,
                            p_load_sequence_number  IN NUMBER,
                            p_uoo_id                IN NUMBER,
                            p_sup_uoo_id            IN NUMBER,
                            p_cart_error_flag       IN VARCHAR2,
                            p_assessment_ind        IN VARCHAR2,
                            p_override_enrolled_cp  IN NUMBER,
                            p_grading_schema_code   IN VARCHAR2,
                            p_gs_version_number     IN NUMBER
                           ) AS

PRAGMA  AUTONOMOUS_TRANSACTION;

-------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose : This procedure calls table handler of the plan table. This is written as an autonomous transaction since the creation of
  -- planning sheet units must be comitted to the database.Check if unit does not already exist and call insert row of the
  -- table handler. The cart_error_flag column is a part of the primary key since it is possible to have temporary records in the
  -- plan table for cart errors. Hence for the same person_id , course_cd and uoo_id it is possible to have two records
  -- with differing cart_error_ind columns.

  --Change History:
  --Who         When            What
  --bdeviset    24-AUg-2006     Bug# 5487876. Only insertion needs to happen here.Updation is taken care at the page level
  -------------------------------------------------------------------------------------------

  l_unit_sec                      VARCHAR2(100);
  l_row_id                        VARCHAR2(30);
  l_enc_message_name              VARCHAR2(2000);
  l_app_short_name                VARCHAR2(100);
  l_msg_index                     NUMBER;
  l_message_name                  VARCHAR2(4000);
  l_rec_exists                    VARCHAR2(1);

   CURSOR c1 IS
      SELECT   'x'
      FROM     igs_en_plan_units
      WHERE    person_id                         = p_person_id
      AND      course_cd                         = p_course_cd
      AND      uoo_id                            = p_uoo_id
      AND      cart_error_flag                   = p_cart_error_flag;


BEGIN

  OPEN c1;
  FETCH c1 INTO l_rec_exists;
  IF (c1%NOTFOUND) THEN
      CLOSE c1;

     IGS_EN_PLAN_UNITS_PKG.insert_row(
                        x_rowid                     =>      l_row_id,
                        x_person_id                 =>      p_person_id,
                        x_course_cd                 =>      p_course_cd,
                        x_uoo_id                    =>      p_uoo_id,
                        x_term_cal_type             =>      p_load_cal_type,
                        x_term_ci_sequence_number   =>      p_load_sequence_number,
                        x_no_assessment_ind         =>      p_assessment_ind,  --- need to check
                        x_sup_uoo_id                =>      p_sup_uoo_id,--unit_dtls_rec,
                        x_override_enrolled_cp      =>      p_override_enrolled_cp,--unit_dtls_rec,
                        x_grading_schema_code       =>      p_grading_schema_code,--unit_dtls_rec,
                        x_gs_version_number         =>      p_gs_version_number,--unit_dtls_rec,
                        x_core_indicator_code       =>      NULL,--unit_dtls_rec,
                        x_alternative_title         =>      NULL,--unit_dtls_rec,
                        x_cart_error_flag           =>      p_cart_error_flag,
                        x_session_id                =>      igs_en_add_units_api.g_ss_session_id,
                        x_mode                      =>      'R'
                        );
  ELSE
    CLOSE c1;
  END IF;

  COMMIT  ;

EXCEPTION


   WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
      --  get message from stack and insert into warn record.
      IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
      FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);
      ROLLBACK;

      IF l_message_name IS NOT NULL THEN

          l_unit_sec := get_unit_sec(p_uoo_id);

          igs_en_drop_units_api.create_ss_warning (
                             p_person_id => p_person_id,
                             p_course_cd => p_course_cd,
                             p_term_cal_type=>p_load_cal_type,
                             p_term_ci_sequence_number => p_load_sequence_number,
                             p_uoo_id => p_uoo_id,
                             p_message_for => l_unit_sec,
                             p_message_icon=>'D',
                             p_message_name => l_message_name,
                             p_message_rule_text => NULL,
                             p_message_tokens => NULL,
                             p_message_action=> NULL,
                             p_destination =>NULL,
                             p_parameters => NULL,
                             p_step_type => 'UNIT');

      END IF;

    WHEN OTHERS THEN

      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.create_ps_record :',SQLERRM);
      END IF;
      ROLLBACK;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.create_ps_record');
      IGS_GE_MSG_STACK.ADD;
      RAISE;

END create_ps_record;



PROCEDURE create_cart_error( p_person_id            IN NUMBER,
                            p_course_cd             IN VARCHAR2,
                            p_load_cal_type         IN VARCHAR2,
                            p_load_sequence_number  IN NUMBER,
                            p_uoo_id                IN NUMBER,
                            p_sup_uoo_id            IN NUMBER,
                            p_cart_error_flag       IN VARCHAR2,
                            p_assessment_ind        IN VARCHAR2,
                            p_override_enrolled_cp  IN NUMBER,
                            p_grading_schema_code   IN VARCHAR2,
                            p_gs_version_number     IN NUMBER) AS


-------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose : This procedure calls table handler of the plan table. This is written as an autonomous transaction since the creation of
  -- planning sheet units must be comitted to the database.Check if unit does not already exist and call insert row of the
  -- table handler. The cart_error_flag column is a part of the primary key since it is possible to have temporary records in the
  -- plan table for cart errors. Hence for the same person_id , course_cd and uoo_id it is possible to have two records
  -- with differing cart_error_ind columns.

  --Change History:
  --Who         When            What
  -------------------------------------------------------------------------------------------

  l_unit_sec                      VARCHAR2(100);
  l_row_id                        VARCHAR2(30);
  l_enc_message_name              VARCHAR2(2000);
  l_app_short_name                VARCHAR2(100);
  l_msg_index                     NUMBER;
  l_message_name                  VARCHAR2(4000);


BEGIN

 -- check if record already exists then update else insert

  IGS_EN_PLAN_UNITS_PKG.add_row(
                      x_rowid                     =>      l_row_id,
                      x_person_id                 =>      p_person_id,
                      x_course_cd                 =>      p_course_cd,
                      x_uoo_id                    =>      p_uoo_id,
                      x_term_cal_type             =>      p_load_cal_type,
                      x_term_ci_sequence_number   =>      p_load_sequence_number,
                      x_no_assessment_ind         =>      p_assessment_ind,  --- need to check
                      x_sup_uoo_id                =>      p_sup_uoo_id,--unit_dtls_rec,
                      x_override_enrolled_cp      =>      p_override_enrolled_cp,--unit_dtls_rec,
                      x_grading_schema_code       =>      p_grading_schema_code,--unit_dtls_rec,
                      x_gs_version_number         =>      p_gs_version_number,--unit_dtls_rec,
                      x_core_indicator_code       =>      NULL,--unit_dtls_rec,
                      x_alternative_title         =>      NULL,--unit_dtls_rec,
                      x_cart_error_flag           =>      p_cart_error_flag,
                      x_session_id                =>      igs_en_add_units_api.g_ss_session_id,
                      x_mode                      =>      'R'
                      );


EXCEPTION


   WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
      --  get message from stack and insert into warn record.
      IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
      FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);

      IF l_message_name IS NOT NULL THEN

          l_unit_sec := get_unit_sec(p_uoo_id);

          igs_en_drop_units_api.create_ss_warning (
                             p_person_id => p_person_id,
                             p_course_cd => p_course_cd,
                             p_term_cal_type=>p_load_cal_type,
                             p_term_ci_sequence_number => p_load_sequence_number,
                             p_uoo_id => p_uoo_id,
                             p_message_for => l_unit_sec,
                             p_message_icon=>'D',
                             p_message_name => l_message_name,
                             p_message_rule_text => NULL,
                             p_message_tokens => NULL,
                             p_message_action=> NULL,
                             p_destination =>NULL,
                             p_parameters => NULL,
                             p_step_type => 'UNIT');
      END IF;

    WHEN OTHERS THEN

      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.create_cart_error :',SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.create_cart_error');
      IGS_GE_MSG_STACK.ADD;
      RAISE;

END create_cart_error;

PROCEDURE create_sua(p_person_id          IN NUMBER,
                     p_course_cd          IN VARCHAR2,
                     p_uoo_id             IN NUMBER,
                     p_load_cal_type      IN VARCHAR2,
                     p_load_sequence_number IN NUMBER,
                     p_audit_requested    IN VARCHAR2,
                     p_enr_method         IN VARCHAR2,
                     p_override_cp        IN NUMBER,
                     p_gradsch_cd         IN VARCHAR2,
                     p_gs_version_number  IN NUMBER,
                     p_calling_obj        IN VARCHAR2,
                     p_return_status      OUT NOCOPY VARCHAR2,
                     p_message            OUT NOCOPY VARCHAR2) AS

-------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose : creates student unit attempt.
  --Change History:
  --Who         When            What
  --bdeviset    03-NOV-2005    Modified when others then in exception block for bug# 4706405

  -------------------------------------------------------------------------------------------

PRAGMA  AUTONOMOUS_TRANSACTION;

  -- cursor to get the person number
  CURSOR  c_get_per_num IS
  SELECT party_number
  FROM HZ_PARTIES
  WHERE party_id = p_person_id;

  -- cursor to get the rowid of the plannig units table
  CURSOR c_get_rowid IS
  SELECT ROWID
  FROM igs_en_plan_units
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND uoo_id = p_uoo_id
  AND cart_error_flag = 'Y';

  l_core_indicator_code             igs_en_su_attempt.core_indicator_code%TYPE;
  l_person_number                   hz_parties.party_number%TYPE;
  l_rowid                           VARCHAR2(30);
  l_enc_message_name                VARCHAR2(2000);
  l_app_short_name                  VARCHAR2(100);
  l_msg_index                       NUMBER;
  l_message_name                    VARCHAR2(4000);
  l_unit_sec                        VARCHAR2(100);


BEGIN

  -- get the core indicator
  l_core_indicator_code := igs_en_gen_009.enrp_check_usec_core(
                                                                p_person_id => p_person_id,
                                                                p_program_cd => p_course_cd,
                                                                p_uoo_id => p_uoo_id);

  OPEN c_get_per_num;
  FETCH c_get_per_num INTO l_person_number;
  CLOSE c_get_per_num;

  igs_ss_en_wrappers.insert_into_enr_worksheet
                                            (p_person_number         => l_person_number,
                                             p_course_cd             => p_course_cd ,
                                             p_uoo_id                => p_uoo_id,
                                             p_waitlist_ind          => 'N',
                                             p_session_id            => igs_en_add_units_api.g_ss_session_id,
                                             p_return_status         => p_return_status,
                                             p_message               => p_message,
                                             p_cal_type              => p_load_cal_type,
                                             p_ci_sequence_number    => p_load_sequence_number,
                                             p_audit_requested       => p_audit_requested,
                                             p_enr_method            => p_enr_method,
                                             p_override_cp           => p_override_cp,
                                             p_subtitle              => NULL,
                                             p_gradsch_cd            => p_gradsch_cd,
                                             p_gs_version_num        => p_gs_version_number,
                                             p_core_indicator_code   => l_core_indicator_code,
                                             p_calling_obj         => p_calling_obj);

  IF p_return_status = 'D' AND p_message IS NOT NULL THEN
    p_return_status := 'FALSE';
    ROLLBACK;
    RETURN;
  ELSE
    p_return_status := NULL;
  END IF;

  OPEN c_get_rowid;
  FETCH c_get_rowid INTO l_rowid;
  IF c_get_rowid%FOUND THEN
  CLOSE c_get_rowid;

    IGS_EN_PLAN_UNITS_PKG.delete_row(x_rowid => l_rowid);

  ELSE
    CLOSE c_get_rowid;
  END IF;

  COMMIT;
EXCEPTION


   WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
    --  get message from stack and insert into warn record.
    IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
    FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);
    ROLLBACK;
    IF l_message_name IS NOT NULL THEN

        l_unit_sec := get_unit_sec(p_uoo_id);
        p_return_status := 'FALSE'; -- indiacted unit attempt is not created
        IF l_message_name IN ('IGS_GE_RECORD_ALREADY_EXISTS','IGS_GE_MULTI_ORG_DUP_REC') THEN
          p_message := 'IGS_EN_SUA_EXISTS'||'*'||l_unit_sec;
          RETURN;
        END IF;

        igs_en_drop_units_api.create_ss_warning (
                           p_person_id => p_person_id,
                           p_course_cd => p_course_cd,
                           p_term_cal_type=>p_load_cal_type,
                           p_term_ci_sequence_number => p_load_sequence_number,
                           p_uoo_id => p_uoo_id,
                           p_message_for => l_unit_sec,
                           p_message_icon=>'D',
                           p_message_name => l_message_name,
                           p_message_rule_text => NULL,
                           p_message_tokens => NULL,
                           p_message_action=> NULL,
                           p_destination =>NULL,
                           p_parameters => NULL,
                           p_step_type => 'UNIT');



    END IF;

  WHEN OTHERS THEN

      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.create_sua :',SQLERRM);
      END IF;
      ROLLBACK;
      IF SQLCODE = -1 THEN
          l_unit_sec := get_unit_sec(p_uoo_id);
          p_return_status := 'FALSE';
          p_message := 'IGS_EN_SUA_EXISTS'||'*'||l_unit_sec;
          RETURN;
      ELSE
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.create_sua');
        IGS_GE_MSG_STACK.ADD;
        RAISE;
      END IF;


END create_sua;

PROCEDURE create_sua_from_plan(p_person_Id            IN NUMBER,
                               p_course_cd            IN VARCHAR2,
                               p_uoo_id               IN NUMBER,
                               p_load_cal_type        IN VARCHAR2,
                               p_load_sequence_number IN NUMBER,
                               p_audit_requested      IN VARCHAR2,
                               p_waitlist_ind         IN VARCHAR2,
                               p_enr_method           IN VARCHAR2,
                               p_override_cp          IN NUMBER,
                               p_gradsch_cd           IN VARCHAR2,
                               p_gs_version_number    IN NUMBER,
                               p_calling_obj          IN VARCHAR2,
                               p_message              OUT NOCOPY VARCHAR2,
                               p_return_status        OUT NOCOPY VARCHAR2) AS
 -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose : creates unit attempt and deletes the record in the planning units table
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------


  -- cursor to get the person number
  CURSOR  c_get_per_num IS
  SELECT party_number
  FROM HZ_PARTIES
  WHERE party_id = p_person_id;

  -- cursor to get the rowid from the plaannig units table
  CURSOR c_get_rowid IS
  SELECT ROWID
  FROM igs_en_plan_units
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND uoo_id = p_uoo_id
  AND cart_error_flag = 'Y';

  l_core_indicator_code               igs_en_su_attempt.core_indicator_code%TYPE;
  l_person_number                     hz_parties.party_number%TYPE;
  l_rowid                             VARCHAR2(30);
  l_enc_message_name                  VARCHAR2(2000);
  l_app_short_name                    VARCHAR2(100);
  l_msg_index                         NUMBER;
  l_message_name                      VARCHAR2(4000);
  l_unit_sec                          VARCHAR2(100);
  l_message_tokens                    VARCHAR2(200);

BEGIN

  -- get the core indicator
  l_core_indicator_code := igs_en_gen_009.enrp_check_usec_core(
                                                                p_person_id => p_person_id,
                                                                p_program_cd => p_course_cd,
                                                                p_uoo_id => p_uoo_id);

  SAVEPOINT sp_plan_wrappers;

  OPEN c_get_per_num;
  FETCH c_get_per_num INTO l_person_number;
  CLOSE c_get_per_num;

  igs_ss_en_wrappers.insert_into_enr_worksheet
                                            (p_person_number         => l_person_number,
                                             p_course_cd             => p_course_cd ,
                                             p_uoo_id                => p_uoo_id,
                                             p_waitlist_ind          => p_waitlist_ind,
                                             p_session_id            => igs_en_add_units_api.g_ss_session_id,
                                             p_return_status         => p_return_status,
                                             p_message               => p_message,
                                             p_cal_type              => p_load_cal_type,
                                             p_ci_sequence_number    => p_load_sequence_number,
                                             p_audit_requested       => p_audit_requested,
                                             p_enr_method            => p_enr_method,
                                             p_override_cp           => p_override_cp,
                                             p_subtitle              => NULL,
                                             p_gradsch_cd            => p_gradsch_cd,
                                             p_gs_version_num        => p_gs_version_number,
                                             p_core_indicator_code   => l_core_indicator_code,
                                             p_calling_obj           => p_calling_obj);

  IF p_return_status = 'D' AND p_message IS NOT NULL THEN
    p_return_status := 'FALSE';
    ROLLBACK TO sp_plan_wrappers;
    RETURN;
  ELSE
    p_return_status := NULL;
  END IF;

  -- if the unit is not waitlisted then only delete the record
  IF p_waitlist_ind = 'N' THEN

    OPEN c_get_rowid;
    FETCH c_get_rowid INTO l_rowid;
    IF c_get_rowid%FOUND THEN
    CLOSE c_get_rowid;

      IGS_EN_PLAN_UNITS_PKG.delete_row(x_rowid => l_rowid);

    ELSE
      CLOSE c_get_rowid;
    END IF;
  END IF;

EXCEPTION


   WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
    --  get message from stack and insert into warn record.
    IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
    FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);

    IF l_message_name IS NOT NULL THEN

       l_message_tokens := NULL;
       l_unit_sec := get_unit_sec(p_uoo_id);
       ROLLBACK TO sp_plan_wrappers;
       IF l_message_name IN ('IGS_GE_RECORD_ALREADY_EXISTS','IGS_GE_MULTI_ORG_DUP_REC') THEN
          l_message_name := 'IGS_EN_SUA_EXISTS';
          l_message_tokens := 'UNIT_CD'||':'||l_unit_sec||';';
       END IF;
       igs_en_drop_units_api.create_ss_warning (
                           p_person_id => p_person_id,
                           p_course_cd => p_course_cd,
                           p_term_cal_type=>p_load_cal_type,
                           p_term_ci_sequence_number => p_load_sequence_number,
                           p_uoo_id => p_uoo_id,
                           p_message_for => l_unit_sec,
                           p_message_icon=>'D',
                           p_message_name => l_message_name,
                           p_message_rule_text => NULL,
                           p_message_tokens => l_message_tokens,
                           p_message_action=> NULL,
                           p_destination =>NULL,
                           p_parameters => NULL,
                           p_step_type => 'UNIT');


    END IF;

  WHEN OTHERS THEN

      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.create_sua_from_plan :',SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.create_sua_from_plan');
      IGS_GE_MSG_STACK.ADD;
      RAISE;

END create_sua_from_plan;


PROCEDURE get_perm_wlst_setup(
                              p_person_id IN NUMBER,
                              p_course_cd IN VARCHAR2,
                              p_load_cal_type IN VARCHAR2,
                              p_load_sequence_number IN NUMBER ,
                              p_unit_params IN OUT NOCOPY  t_params_table,
                              p_message OUT NOCOPY VARCHAR2,
                              p_return_status OUT NOCOPY VARCHAR2,
                              p_chk_waitlist IN VARCHAR2) AS

 -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose : This procedure loops through all units and sets the waitlist and special/audit permission status of the units.
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

  l_message_name                    VARCHAR2(4000);
  l_audit_msg_name                  VARCHAR2(100);
  l_return_status                   VARCHAR2(100);
  l_audit_status                    VARCHAR2(100);
  l_usec_status                     igs_ps_unit_ofr_opt.unit_section_status%TYPE;
  l_waitlist_ind                    VARCHAR2(10);
  l_enc_message_name                VARCHAR2(2000);
  l_app_short_name                  VARCHAR2(100);
  l_msg_index                       NUMBER;
  l_unit_sec                        VARCHAR2(100);


BEGIN

    p_message := NULL;
    p_return_status := NULL;

  FOR i IN 1..p_unit_params.COUNT LOOP

    BEGIN
        igs_en_gen_015.check_spl_perm_exists(
                                            p_person_id => p_person_id,
                                            p_person_type => g_person_type,
                                            p_program_cd => p_course_cd,
                                            p_cal_type => p_load_cal_type,
                                            p_ci_sequence_number => p_load_sequence_number,
                                            p_uoo_id=> p_unit_params(i).uoo_id,
                                            p_check_audit => p_unit_params(i).ass_ind,
                                            p_message_name  => l_message_name,
                                            p_return_status => l_return_status,
                                            p_audit_status => l_audit_status,
                                            p_audit_msg_name => l_audit_msg_name
                                            );


        IF  l_return_status = 'SPL_NREQ' THEN
          p_unit_params(i).spl_perm_step := 'PERM_NREQ';

        ELSIF l_return_status = 'SPL_REQ' THEN
          p_unit_params(i).spl_perm_step := 'SPL_REQ';

        ELSIF l_return_status = 'SPL_ERR' THEN
          IF l_message_name = 'IGS_SS_EN_INS_MORE_INFO' THEN
            --implies more information requested
            p_unit_params(i).spl_perm_step := 'SPL_MORE_INFO';

          ELSIF l_message_name = 'IGS_SS_EN_STD_MORE_INFO' THEN
            --implies request is pending
            p_unit_params(i).spl_perm_step := 'SPL_PEND';

          ELSIF l_message_name = 'IGS_SS_EN_INS_DENY' THEN
            --implies request is denied
            p_unit_params(i).spl_perm_step := 'SPL_DENY';
          ELSE
            p_return_status := 'FALSE';
            p_message := l_message_name;
            RETURN;
          END IF; -- IF l_message_name = 'IGS_SS_EN_INS_MORE_INFO' THEN

        END IF;

      IF l_audit_status = 'AUDIT_NREQ' THEN
                p_unit_params(i).aud_perm_step := 'PERM_NREQ';
      ELSIF  l_audit_status = 'AUDIT_REQ' THEN
          p_unit_params(i).aud_perm_step := 'AUD_REQ';

      ELSIF l_audit_status = 'AUDIT_ERR' THEN
          IF l_audit_msg_name = 'IGS_EN_AU_INS_MORE_INFO' THEN
             --implies more information requested
            p_unit_params(i).aud_perm_step := 'AUD_MORE_INFO';

          ELSIF l_audit_msg_name = 'IGS_EN_AU_STD_MORE_INFO' THEN
            --implies request is pending
            p_unit_params(i).aud_perm_step := 'AUD_PEND';

          ELSIF l_audit_msg_name = 'IGS_EN_AU_INS_DENY' THEN
            --implies request is denied
            p_unit_params(i).aud_perm_step := 'AUD_DENY';
          ELSE
            p_return_status := 'FALSE';
            p_message := l_audit_msg_name;
            RETURN;
          END IF; --    IF l_message_name = 'IGS_EN_AU_INS_MORE_INFO' THEN

     END IF;
    if p_chk_waitlist = 'Y' then
        -- now check if unit can be waitlisted or enrolled
        igs_en_gen_015.get_usec_status(
                                       p_person_id => p_person_id,
                                       p_course_cd => p_course_cd,
                                       p_uoo_id => p_unit_params(i).uoo_id,
                                       p_load_cal_type => p_load_cal_type,
                                       p_load_ci_sequence_number => p_load_sequence_number,
                                       p_unit_section_status => l_usec_status ,
                                       p_waitlist_ind => l_waitlist_ind  );

        IF l_waitlist_ind = 'N' THEN
          p_unit_params(i).wlst_step := 'N';

        ELSIF l_waitlist_ind = 'Y' THEN
          p_unit_params(i).wlst_step := 'Y';
        ELSE
          p_unit_params(i).wlst_step := 'E';
        END IF;
     end if;

    EXCEPTION

      WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
        --  get message from stack and insert into warn record.
        IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
        FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);

        IF l_message_name IS NOT NULL THEN

            l_unit_sec := get_unit_sec(p_unit_params(i).uoo_id);

            igs_en_drop_units_api.create_ss_warning (
                               p_person_id => p_person_id,
                               p_course_cd => p_course_cd,
                               p_term_cal_type=>p_load_cal_type,
                               p_term_ci_sequence_number => p_load_sequence_number,
                               p_uoo_id => p_unit_params(i).uoo_id,
                               p_message_for => l_unit_sec,
                               p_message_icon=>'D',
                               p_message_name => l_message_name,
                               p_message_rule_text => NULL,
                               p_message_tokens => NULL,
                               p_message_action=> NULL,
                               p_destination =>NULL,
                               p_parameters => NULL,
                               p_step_type => 'UNIT');



        END IF;

      WHEN OTHERS THEN
        RAISE;

    END; -- end of BEGIN

  END LOOP;

EXCEPTION

    WHEN OTHERS THEN

      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.get_perm_wlst_setup :',SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.get_perm_wlst_setup');
      IGS_GE_MSG_STACK.ADD;
      RAISE;
END get_perm_wlst_setup;

FUNCTION permission_required(
                            p_person_id IN NUMBER,
                            p_course_cd IN VARCHAR2,
                            p_load_cal_type IN VARCHAR2,
                            p_load_sequence_number IN NUMBER,
                            p_uoo_id IN NUMBER,
                            p_spl_perm_step IN VARCHAR2,
                            p_aud_perm_step IN VARCHAR2,
                            p_audit_requested  IN VARCHAR2,
                            p_override_cp IN VARCHAR2,
                            p_gradsch_cd IN VARCHAR2,
                            p_gs_version_number  IN NUMBER,
                            p_message OUT NOCOPY VARCHAR2,
                            p_calling_obj IN VARCHAR2
                            ) RETURN BOOLEAN AS

-------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose :
  -- This procedure checks if any unit requires special/audit permission based on the p_perm_step
  -- parameter and logs the appropriate warnings record. In addition, a planning sheet record with a
  -- cart flag is created since these units need to appear in the cart region even though the unit is
  -- not added to the unit attempt table.  The procedure returns true if a unit requires special/audit
  -- permission and a warning record is created. If a unit does not require permission it returns false,
  -- hence the calling procedure can proceed with creating unconfirm unit attempts

  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

  -- cursor to get the superior unit of a unit
  CURSOR c_fetch_sup(cp_uoo_id  IGS_PS_UNIT_OFR_OPT.sup_uoo_id%TYPE) IS
  SELECT sup_uoo_id
  FROM IGS_PS_UNIT_OFR_OPT
  WHERE uoo_id = cp_uoo_id
  AND relation_type = 'SUBORDINATE';

  -- cursor to get request id
  CURSOR c_get_request_id (cp_request_type IGS_EN_SPL_PERM.request_type%TYPE) IS
  SELECT spl_perm_request_id
  FROM igs_en_spl_perm
  WHERE student_person_id = p_person_id
  AND uoo_id = p_uoo_id
  AND request_type = cp_request_type;

    --cursor to check if unit is preenrolled

  CURSOR cur_is_unit_preenroled IS
  SELECT 'Y'
  FROM IGS_EN_SU_ATTEMPT
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND uoo_id = p_uoo_id ;


  l_sup_uoo_id            igs_en_su_attempt.uoo_id%TYPE;
  l_unit_sec              VARCHAR2(50);
  l_message_icon          VARCHAR2(1);
  l_message_name          VARCHAR2(4000);
  l_message_action        VARCHAR2(100);
  l_destination           VARCHAR2(100);
  l_parameters            VARCHAR2(1000);
  l_request_id            IGS_EN_SPL_PERM.spl_perm_request_id%TYPE;
  l_preenrol_unit          VARCHAR2(1);

BEGIN

  IF ( p_spl_perm_step = 'PERM_NREQ' AND p_aud_perm_step = 'PERM_NREQ')THEN
    RETURN FALSE;
  END IF;
  -- If control reaches beyond the above point, implies step is setup and a unit attempt cannot be created.

  l_unit_sec := get_unit_sec(p_uoo_id);

  -- Check if calilng page is SWAP, then create an warning record as 'DENY' since this is an error condition in case of swap.
  IF p_calling_obj IN ('SWAP','SUBMITSWAP') THEN
--in swap, permission is a deny cgeck whether it is audit or special
if (p_spl_perm_step is not null and p_spl_perm_step = 'PERM_NREQ') then

    igs_en_drop_units_api.create_ss_warning (
                      p_person_id => p_person_id,
                      p_course_cd => p_course_cd,
                      p_term_cal_type => p_load_cal_type,
                      p_term_ci_sequence_number => p_load_sequence_number,
                      p_uoo_id => p_uoo_id,
                      p_message_for => l_unit_sec,
                      p_message_icon => 'D',
                      p_message_name => 'IGS_EN_SWP_AUD_NOT_ALLOWED',
                      p_message_rule_text => NULL,
                      p_message_tokens => NULL,
                      p_message_action => NULL,
                      p_destination => NULL,
                      p_parameters => NULL,
                      p_step_type => 'UNIT');

end if;
if (p_aud_perm_step is not null and p_aud_perm_step = 'PERM_NREQ') then



    igs_en_drop_units_api.create_ss_warning (
                      p_person_id => p_person_id,
                      p_course_cd => p_course_cd,
                      p_term_cal_type => p_load_cal_type,
                      p_term_ci_sequence_number => p_load_sequence_number,
                      p_uoo_id => p_uoo_id,
                      p_message_for => l_unit_sec,
                      p_message_icon => 'D',
                      p_message_name => 'IGS_EN_SWP_SPL_NOT_ALLOWED',
                      p_message_rule_text => NULL,
                      p_message_tokens => NULL,
                      p_message_action => NULL,
                      p_destination => NULL,
                      p_parameters => NULL,
                      p_step_type => 'UNIT');
 end if;



  ELSE
    -- create planning sheet error record in case of submit plan
    IF p_calling_obj = 'SUBMITPLAN' THEN
        -- create planning sheet cart error record in the same transaction
        --for all units except preenrolled units.
        OPEN cur_is_unit_preenroled;
        FETCH cur_is_unit_preenroled into l_preenrol_unit;
        CLOSE cur_is_unit_preenroled;

     if nvl(l_preenrol_unit,'N') <> 'Y' THEN
        create_cart_error( p_person_id,
                           p_course_cd,
                           p_load_cal_type,
                           p_load_sequence_number,
                           p_uoo_id,
                           l_sup_uoo_id,
                           'Y',
                           p_audit_requested, -- ass ind
                           p_override_cp,
                           p_gradsch_cd,
                           p_gs_version_number
                           );
      end if;
    -- dont create any planning sheet record for plan
    ELSIF  p_calling_obj <> 'PLAN' THEN
        create_ps_record(p_person_id,
                         p_course_cd,
                         p_load_cal_type,
                         p_load_sequence_number,
                         p_uoo_id,
                         l_sup_uoo_id,
                         'Y',
                         p_audit_requested, -- ass ind
                         p_override_cp,
                         p_gradsch_cd,
                         p_gs_version_number
                         );
     END IF;

    IF p_spl_perm_step = 'SPL_REQ' THEN

        l_message_icon := 'D';
        l_message_name :=  'IGS_EN_NOSPL_TAB_DENY'; --  message for "submit special perm request" ,
        l_parameters :=    'SPL_PERM'; -- pass pRequestType
        l_message_action := igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                                p_lookup_code => 'REQ_SPL',
                                                                p_lookup_type => 'IGS_EN_WARN_LINKS');

        IF p_calling_obj IN ('CART','SUBMITCART','SCHEDULE','ENROLPEND') THEN
            l_destination := 'IGS_EN_CART_SPPERMREQINF_STUD';
        ELSIF p_calling_obj IN ('PLAN','SUBMITPLAN') THEN
            l_destination := 'IGS_EN_PLAN_SPPERMREQINF_STUD';
        END IF;


   ELSIF p_spl_perm_step = 'SPL_MORE_INFO' THEN

        OPEN c_get_request_id('SPL_PERM');
        FETCH c_get_request_id INTO l_request_id;
        CLOSE c_get_request_id;

        l_message_icon := 'D';
        l_message_name :=  'IGS_EN_MISPL_TAB_DENY'; --  message for "submit more information" , ,
        l_parameters :=    'SPL_PERM'||','||l_request_id||','||'Y'; -- pass pRequestType,pRequestId,pMoreInfo
        l_message_action := igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                                p_lookup_code => 'REQ_SPLADDINFO',
                                                                p_lookup_type => 'IGS_EN_WARN_LINKS');

        IF p_calling_obj IN ('CART','SUBMITCART','SCHEDULE','ENROLPEND') THEN
            l_destination := 'IGS_EN_CART_SPL_STUD_DETAILS';
        ELSIF p_calling_obj IN ('PLAN','SUBMITPLAN') THEN
            l_destination := 'IGS_EN_PLAN_SPL_STUD_DETAILS';
        END IF;

    ELSIF p_spl_perm_step = 'SPL_PEND' THEN

        OPEN c_get_request_id('SPL_PERM');
        FETCH c_get_request_id INTO l_request_id;
        CLOSE c_get_request_id;

        l_message_icon := 'P';
        l_message_name :=  'IGS_EN_PENSPL_TAB_INFO'; -- message for "view special perm request details"   ,
        l_parameters :=    'SPL_PERM'||','||l_request_id||','||'N'; -- pass pRequestType,pRequestId,pMoreInfo
        l_message_action := igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                                p_lookup_code => 'SPLPERM_DETS',
                                                                p_lookup_type => 'IGS_EN_WARN_LINKS');


        IF p_calling_obj IN ('CART','SUBMITCART','SCHEDULE','ENROLPEND') THEN
            l_destination := 'IGS_EN_CART_SPL_STUD_DETAILS';
        ELSIF p_calling_obj IN ('PLAN','SUBMITPLAN') THEN
            l_destination := 'IGS_EN_PLAN_SPL_STUD_DETAILS';
        END IF;

    ELSIF  p_spl_perm_step = 'SPL_DENY' THEN
        OPEN c_get_request_id('SPL_PERM');
        FETCH c_get_request_id INTO l_request_id;
        CLOSE c_get_request_id;

      l_message_icon := 'D';
      l_message_name :=  'IGS_EN_REJSPL_TAB_DENY'; --message for "request denied"  ,
      l_message_action := igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                                p_lookup_code => 'SPLPERM_DETS',
                                                                p_lookup_type => 'IGS_EN_WARN_LINKS');

        IF p_calling_obj IN ('CART','SUBMITCART','SCHEDULE','ENROLPEND') THEN
            l_destination := 'IGS_EN_CART_SPL_STUD_DETAILS';
        ELSIF p_calling_obj IN ('PLAN','SUBMITPLAN') THEN
            l_destination := 'IGS_EN_PLAN_SPL_STUD_DETAILS';
        END IF;

      l_parameters :=    'SPL_PERM'||','||l_request_id||','||'N'; -- pass pRequestType,pRequestId,pMoreInfo
    END IF;

    IF p_spl_perm_step <> 'PERM_NREQ' THEN

      igs_en_drop_units_api.create_ss_warning (
                        p_person_id => p_person_id,
                        p_course_cd => p_course_cd,
                        p_term_cal_type => p_load_cal_type,
                        p_term_ci_sequence_number => p_load_sequence_number,
                        p_uoo_id => p_uoo_id,
                        p_message_for => l_unit_sec,
                        p_message_icon => l_message_icon,
                        p_message_name => l_message_name,
                        p_message_rule_text => NULL,
                        p_message_tokens => NULL,
                        p_message_action => l_message_action,
                        p_destination => l_destination, -- p_destination
                        p_parameters => l_parameters, -- p_parameters
                        p_step_type => 'UNIT');
    END IF;


    IF p_aud_perm_step = 'AUD_REQ'  THEN

          l_message_icon := 'D';
          l_message_name :=  'IGS_EN_NOAUD_TAB_DENY'; --  message for "submit Aud perm request" ,
          l_parameters :=    'AUDIT_PERM'; -- pass pRequestType
          l_message_action := igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                                  p_lookup_code => 'REQ_AUD',
                                                                  p_lookup_type => 'IGS_EN_WARN_LINKS');
        IF p_calling_obj IN ('CART','SUBMITCART','SCHEDULE','ENROLPEND') THEN
            l_destination := 'IGS_EN_CART_SPPERMREQINF_STUD';
        ELSIF p_calling_obj IN ('PLAN','SUBMITPLAN') THEN
            l_destination := 'IGS_EN_PLAN_SPPERMREQINF_STUD';
        END IF;

    ELSIF p_aud_perm_step = 'AUD_MORE_INFO' THEN

        OPEN c_get_request_id('AUDIT_PERM');
        FETCH c_get_request_id INTO l_request_id;
        CLOSE c_get_request_id;

        l_message_icon := 'D';
        l_message_name :=  'IGS_EN_MIAUD_TAB_DENY'; --message for "submit more information"  ,
        l_parameters :=    'AUDIT_PERM'||','||l_request_id||','||'Y'; -- pass pRequestType,pRequestId,pMoreInfo
        l_message_action := igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                                  p_lookup_code => 'REQ_AUDADDINFO',
                                                                  p_lookup_type => 'IGS_EN_WARN_LINKS');
        IF p_calling_obj IN ('CART','SUBMITCART','SCHEDULE','ENROLPEND') THEN
            l_destination := 'IGS_EN_CART_SPL_STUD_DETAILS';
        ELSIF p_calling_obj IN ('PLAN','SUBMITPLAN') THEN
            l_destination := 'IGS_EN_PLAN_SPL_STUD_DETAILS';
        END IF;

    ELSIF p_aud_perm_step = 'AUD_PEND' THEN

        OPEN c_get_request_id('AUDIT_PERM');
        FETCH c_get_request_id INTO l_request_id;
        CLOSE c_get_request_id;

        l_message_icon := 'P';
        l_message_name :=  'IGS_EN_PENAUD_TAB_INFO'; --message for "request pending , view details"   ,
        l_parameters :=    'AUDIT_PERM'||','||l_request_id||','||'N'; -- pass pRequestType,pRequestId,pMoreInfo
        l_message_action := igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                                  p_lookup_code => 'AUDPERM_DETS',
                                                                  p_lookup_type => 'IGS_EN_WARN_LINKS');

        IF p_calling_obj IN ('CART','SUBMITCART','SCHEDULE','ENROLPEND') THEN
            l_destination := 'IGS_EN_CART_SPL_STUD_DETAILS';
        ELSIF p_calling_obj IN ('PLAN','SUBMITPLAN') THEN
            l_destination := 'IGS_EN_PLAN_SPL_STUD_DETAILS';
        END IF;

    ELSIF p_aud_perm_step = 'AUD_DENY' THEN

        l_message_icon := 'D';
        l_message_name :=  'IGS_EN_REJAUD_TAB_DENY'; --message for "Request denied"    ,
        l_parameters :=    'AUDIT_PERM'||','||l_request_id||','||'N'; -- pass pRequestType,pRequestId,pMoreInfo
        l_message_action := igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                                  p_lookup_code => 'AUDPERM_DETS',
                                                                  p_lookup_type => 'IGS_EN_WARN_LINKS');

        IF p_calling_obj IN ('CART','SUBMITCART','SCHEDULE','ENROLPEND') THEN
            l_destination := 'IGS_EN_CART_SPL_STUD_DETAILS';
        ELSIF p_calling_obj IN ('PLAN','SUBMITPLAN') THEN
            l_destination := 'IGS_EN_PLAN_SPL_STUD_DETAILS';
        END IF;

    END IF;

    IF p_aud_perm_step <> 'PERM_NREQ' THEN

      igs_en_drop_units_api.create_ss_warning (
                        p_person_id => p_person_id,
                        p_course_cd => p_course_cd,
                        p_term_cal_type => p_load_cal_type,
                        p_term_ci_sequence_number => p_load_sequence_number,
                        p_uoo_id => p_uoo_id,
                        p_message_for => l_unit_sec,
                        p_message_icon => l_message_icon,
                        p_message_name => l_message_name,
                        p_message_rule_text => NULL,
                        p_message_tokens => NULL,
                        p_message_action => l_message_action,
                        p_destination => l_destination, -- p_destination
                        p_parameters => l_parameters, -- p_parameters
                        p_step_type => 'UNIT');
    END IF;

  END IF;

  RETURN TRUE; -- -- permission reqd


EXCEPTION
   WHEN OTHERS THEN

      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.permission_required :',SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.permission_required');
      IGS_GE_MSG_STACK.ADD;
      RAISE;
END permission_required;



FUNCTION  waitlist_required (
                              p_person_id IN NUMBER,
                              p_course_cd IN VARCHAR2,
                              p_uoo_id  IN NUMBER,
                              p_waitlist_ind IN VARCHAR2,
                              p_load_cal_type IN VARCHAR2,
                              p_load_sequence_number IN NUMBER,
                              p_audit_requested  IN VARCHAR2,
                              p_enr_method IN VARCHAR2,
                              p_override_cp IN VARCHAR2,
                              p_subtitle IN VARCHAR2,
                              p_gradsch_cd IN VARCHAR2,
                              p_gs_version_number  IN NUMBER,
                              p_create_wlst OUT NOCOPY VARCHAR,
                              p_calling_obj IN VARCHAR2,
                              p_message OUT NOCOPY VARCHAR2
                            ) RETURN BOOLEAN AS
 -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  --Purpose :
  --This procedure returns true if a waitlist record was created or if a warning
  --record was created. False implies the calling procedure can continue to enroll
  --the student into these units. The out paramter p_message is populated only
  --in case of setup errors or exceptions.

  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

  -- cursor to get the person number
  CURSOR  c_get_per_num IS
  SELECT party_number
  FROM HZ_PARTIES
  WHERE party_id = p_person_id;

  l_person_number HZ_PARTIES.party_number%TYPE;

  -- cursor to fetch the superior units
  CURSOR c_fetch_sup(cp_uoo_id  IGS_PS_UNIT_OFR_OPT.sup_uoo_id%TYPE) IS
  SELECT sup_uoo_id
  FROM IGS_PS_UNIT_OFR_OPT
  WHERE uoo_id = cp_uoo_id
  AND relation_type = 'SUBORDINATE';

  l_unit_sec                        VARCHAR2(50);
  l_core_indicator_code             igs_en_su_attempt.core_indicator_code%TYPE;
  l_sup_uoo_id                      igs_en_su_attempt.uoo_id%TYPE;
  l_return_status                   VARCHAR2(100);
  l_enc_message_name                VARCHAR2(2000);
  l_app_short_name                  VARCHAR2(100);
  l_msg_index                       NUMBER;
  l_message_name                    VARCHAR2(100);

BEGIN

  l_unit_sec := get_unit_sec(p_uoo_id);

  OPEN c_fetch_sup(p_uoo_id);
  FETCH c_fetch_sup INTO l_sup_uoo_id;
  CLOSE c_fetch_sup;

  -- p_waitlist_ind indicates the status of the unit section.
  -- If it is 'Y', implies the unit can be wailisted, "N"
  -- indicates unit can be enrolled. E indicates an error.

  IF p_waitlist_ind = 'N' THEN
    RETURN FALSE;

  ELSIF p_waitlist_ind = 'E' THEN

      igs_en_drop_units_api.create_ss_warning (
                        p_person_id => p_person_id,
                        p_course_cd => p_course_cd,
                        p_term_cal_type => p_load_cal_type,
                        p_term_ci_sequence_number => p_load_sequence_number,
                        p_uoo_id => p_uoo_id,
                        p_message_for => l_unit_sec,
                        p_message_icon => 'D',
                        p_message_name => 'IGS_EN_SS_CANNOT_WAITLIST', -- message_name
                        p_message_rule_text => NULL,
                        p_message_tokens => NULL,
                        p_message_action => NULL,
                        p_destination => NULL, -- p_destination
                        p_parameters => NULL, -- p_parameters
                        p_step_type => 'UNIT');

      RETURN TRUE;

  ELSIF p_waitlist_ind = 'Y' THEN

    IF p_calling_obj IN ('SWAP','SUBMITSWAP' ) THEN

    --log warning record as error since waitlising is not allowed from swap.
      igs_en_drop_units_api.create_ss_warning (
                        p_person_id => p_person_id,
                        p_course_cd => p_course_cd,
                        p_term_cal_type => p_load_cal_type,
                        p_term_ci_sequence_number => p_load_sequence_number,
                        p_uoo_id => p_uoo_id,
                        p_message_for => l_unit_sec,
                        p_message_icon => 'D',
                        p_message_name => 'IGS_EN_SWP_WLST_NOT_ALLOWED', -- message_name
                        p_message_rule_text => NULL,
                        p_message_tokens => NULL,
                        p_message_action => NULL,
                        p_destination => NULL, -- p_destination
                        p_parameters => NULL, -- p_parameters
                        p_step_type => 'UNIT');


            RETURN TRUE;

      ELSE

        -- else create a warning record and nsert the record
        l_core_indicator_code := igs_en_gen_009.enrp_check_usec_core(
                                                                      p_person_id => p_person_id,
                                                                      p_program_cd => p_course_cd,
                                                                      p_uoo_id => p_uoo_id
                                                                     );
        -- creating warning record for plan
        IF p_calling_obj = 'PLAN' THEN

          igs_en_drop_units_api.create_ss_warning (
                            p_person_id => p_person_id,
                            p_course_cd => p_course_cd,
                            p_term_cal_type => p_load_cal_type,
                            p_term_ci_sequence_number => p_load_sequence_number,
                            p_uoo_id => p_uoo_id,
                            p_message_for => l_unit_sec,
                            p_message_icon => 'W',
                            p_message_name => 'IGS_EN_WLST_AVAIL', -- need to check message_name
                            p_message_rule_text => NULL,
                            p_message_tokens => NULL,
                            p_message_action => NULL,
                            p_destination => NULL, -- p_destination
                            p_parameters => NULL, -- p_parameters
                            p_step_type => 'UNIT');

        END IF;

        OPEN c_get_per_num;
        FETCH c_get_per_num INTO l_person_number;
        CLOSE c_get_per_num;

        -- incase of submit plan both unoconfirm and waitlisted units cannot be
        -- created at the same time as we need to roll back waitlisted units
        -- afterwards. So waitlisted units will be created after save point
        -- sp_enroll_sua so that we can rollback them
        -- incase of plan we will not be creating waitlisted units
        IF p_calling_obj NOT IN ( 'SUBMITPLAN','PLAN') THEN

            igs_ss_en_wrappers.insert_into_enr_worksheet(
                                           p_person_number         => l_person_number,
                                           p_course_cd             => p_course_cd ,
                                           p_uoo_id                => p_uoo_id,
                                           p_waitlist_ind          => 'Y',
                                           p_session_id            => igs_en_add_units_api.g_ss_session_id,
                                           p_return_status         => l_return_status,
                                           p_message               => p_message,
                                           p_cal_type              => p_load_cal_type,
                                           p_ci_sequence_number    => p_load_sequence_number,
                                           p_audit_requested       => p_audit_requested,
                                           p_enr_method            => p_enr_method,
                                           p_override_cp           => p_override_cp,
                                           p_subtitle              => NULL,
                                           p_gradsch_cd            => p_gradsch_cd,
                                           p_gs_version_num        => p_gs_version_number,
                                           p_core_indicator_code   =>l_core_indicator_code,
                                           p_calling_obj           => p_calling_obj);

          IF l_return_status = 'D' AND p_message IS NOT NULL THEN

            RETURN TRUE; -- waitlist is reqd and message is set

          END IF;

        ELSE
            -- set the craete waitlsit flag so that this can be created
            -- before enrolling the unit attempts
            p_create_wlst := 'Y';

        END IF;

      -- For submit plan we will be creating planning sheet error record in the same txn
      -- for cart,submitcart,schedule and enrolpend we create it in an autonomous txn
      IF p_calling_obj IN( 'CART', 'SUBMITCART','SCHEDULE','ENROLPEND') THEN

        -- create a warning record only if waiitlsited record has been succesfully created
         igs_en_drop_units_api.create_ss_warning (
                            p_person_id => p_person_id,
                            p_course_cd => p_course_cd,
                            p_term_cal_type => p_load_cal_type,
                            p_term_ci_sequence_number => p_load_sequence_number,
                            p_uoo_id => p_uoo_id,
                            p_message_for => l_unit_sec,
                            p_message_icon => 'W',
                            p_message_name => 'IGS_EN_WLST_AVAIL', -- need to check message_name
                            p_message_rule_text => NULL,
                            p_message_tokens => NULL,
                            p_message_action => NULL,
                            p_destination => NULL, -- p_destination
                            p_parameters => NULL, -- p_parameters
                            p_step_type => 'UNIT');

        --create PS record with cart error flag  (autonomous txn)
        create_ps_record(p_person_id,
                         p_course_cd,
                         p_load_cal_type,
                         p_load_sequence_number,
                         p_uoo_id,
                         l_sup_uoo_id, -- get sup uooid
                         'Y', -- cart error flag
                         p_audit_requested,--  ass ind
                         p_override_cp,
                         p_gradsch_cd,
                         p_gs_version_number
                         );

      ELSIF p_calling_obj = 'SUBMITPLAN' THEN

        --create cart error record with cart error flag (not an autonomous txn)
        -- so that it can rolled back if their is any deny warning record
        create_cart_error( p_person_id,
                           p_course_cd,
                           p_load_cal_type,
                           p_load_sequence_number,
                           p_uoo_id,
                           l_sup_uoo_id, -- get sup uooid
                           'Y', -- cart error flag
                           p_audit_requested,--  ass ind
                           p_override_cp,
                           p_gradsch_cd,
                           p_gs_version_number
                           );


      END IF;

      RETURN  TRUE;

      END IF; -- IF p_calling_obj IN ('SWAP' 'SUBMITSWAP' )


  END IF; -- IF p_waitlist_ind = 'N'
   RETURN  TRUE;

EXCEPTION

  WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
    --  get message from stack and insert into warn record.
    IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
    FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);

    IF l_message_name IS NOT NULL THEN

        l_unit_sec := get_unit_sec(p_uoo_id);
        igs_en_drop_units_api.create_ss_warning (
                           p_person_id => p_person_id,
                           p_course_cd => p_course_cd,
                           p_term_cal_type=> p_load_cal_type,
                           p_term_ci_sequence_number => p_load_sequence_number,
                           p_uoo_id => p_uoo_id,
                           p_message_for => l_unit_sec,
                           p_message_icon=> 'D',
                           p_message_name => l_message_name,
                           p_message_rule_text => NULL,
                           p_message_tokens => NULL,
                           p_message_action=> NULL,
                           p_destination => NULL,
                           p_parameters => NULL,
                           p_step_type => 'UNIT');
    END IF;


    IF p_waitlist_ind = 'N' THEN
       -- indicates the waitlist record is not created
      RETURN FALSE;
    ELSE
      -- waitlist record is created
      RETURN TRUE;
    END IF;

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.waitlist_required :',SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.waitlist_required');
      IGS_GE_MSG_STACK.ADD;
      RAISE;
END waitlist_required;


PROCEDURE validate_enr_encmb ( p_person_id IN NUMBER,
                              p_course_cd IN VARCHAR2,
                              p_load_cal_type IN VARCHAR2,
                              p_load_sequence_number IN NUMBER,
                              p_return_status OUT NOCOPY VARCHAR2,
                              p_message OUT NOCOPY VARCHAR2
                            ) AS

 -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  --Purpose :
  -- This procedure validates the encumbrance and depending on the message returned
  -- throws inline error or logs a warning record

  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------



l_message_name      VARCHAR2(30);
l_message_name2     VARCHAR2(30);
l_return_type       VARCHAR2(50);
l_message_for       igs_en_std_warnings.message_for%TYPE;

BEGIN
  IF NOT IGS_EN_VAL_ENCMB.enrp_val_enr_encmb(p_person_id => p_person_id,
                                         p_course_cd => p_course_cd ,
                                         p_cal_type => p_load_cal_type,
                                         p_ci_sequence_number => p_load_sequence_number,
                                         p_message_name => l_message_name,
                                         p_message_name2 => l_message_name2,
                                         p_return_type => l_return_type,
                                         p_effective_dt => NULL -- default value, it will be calculated internally based on the census date
                                         )  THEN

        -- if message is IGS_EN_PERS_HAS_ENCUMB (suspend all services ) and IGS_EN_PRSN_ENCUMB_REVOKING
        -- (revoke all services for the person then throw an inline error message
        IF l_message_name IN ('IGS_EN_PERS_HAS_ENCUMB','IGS_EN_PRSN_ENCUMB_REVOKING' ) THEN
           p_return_status := 'FALSE';
           p_message := l_message_name;
           RETURN;
        ELSIF l_message_name = 'IGS_EN_PRSN_ENR_CRDPOINT'	THEN
          l_message_for :=  igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                   p_lookup_code => 'RSTR_GE_CP',
                                                   p_lookup_type => 'ENCMB_EFFECT_TYPE');
        ELSIF l_message_name IN ( 'IGS_EN_PRSN_ENR_CRDPNT_VALUE', 'IGS_EN_PRSN_ENRCRDPNT')  THEN
          l_message_for :=  igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                   p_lookup_code => 'RSTR_LE_CP',
                                                   p_lookup_type => 'ENCMB_EFFECT_TYPE');
        ELSIF l_message_name = 'IGS_EN_PRSN_ATTTYPE_NE_ATT_TY'  THEN
          l_message_for :=  igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                   p_lookup_code => 'RSTR_AT_TY',
                                                   p_lookup_type => 'ENCMB_EFFECT_TYPE');
        ELSIF  l_message_name IS NOT NULL THEN
          l_message_for :=  igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                   p_lookup_code => 'CRSENCUMB',
                                                   p_lookup_type => 'ENROLMENT_STEP_TYPE');
        END IF;

        IF l_message_name IS NOT NULL THEN
              igs_en_drop_units_api.create_ss_warning(
                                       p_person_id => p_person_id,
                                       p_course_cd => p_course_cd,
                                       p_term_cal_type => p_load_cal_type,
                                       p_term_ci_sequence_number =>  p_load_sequence_number,
                                       p_uoo_id => NULL,
                                       p_message_for => l_message_for,
                                       p_message_icon=> 'D',
                                       p_message_name => l_message_name,
                                       p_message_rule_text => NULL,
                                       p_message_tokens => NULL,
                                       p_message_action => NULL,
                                       p_destination => NULL,
                                       p_parameters => NULL,
                                       p_step_type => 'PROGRAM');
        END IF;

        l_message_for := NULL;
        -- if message is IGS_EN_PERS_HAS_ENCUMB (suspend all services ) and IGS_EN_PRSN_ENCUMB_REVOKING
        -- (revoke all services for the person then throw an inline error message
        IF  l_message_name2 IN ('IGS_EN_PERS_HAS_ENCUMB','IGS_EN_PRSN_ENCUMB_REVOKING') THEN
           p_return_status := 'FALSE';
           p_message := l_message_name2;
           RETURN;
        ELSIF l_message_name2 IN ('IGS_EN_PRSN_NOTENR_REQUIRE' ,'IGS_EN_PRSN_DISCONT_REQUNIT')  THEN
          l_message_for :=  igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                   p_lookup_code => 'RQRD_CRS_U',
                                                   p_lookup_type => 'ENCMB_EFFECT_TYPE');
        ELSIF l_message_name2 IS NOT NULL THEN
          l_message_for :=  igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                   p_lookup_code => 'CRSENCUMB',
                                                   p_lookup_type => 'ENROLMENT_STEP_TYPE');
        END IF;
        IF l_message_name2 IS NOT NULL THEN
              igs_en_drop_units_api.create_ss_warning(
                                       p_person_id => p_person_id,
                                       p_course_cd => p_course_cd,
                                       p_term_cal_type => p_load_cal_type,
                                       p_term_ci_sequence_number =>  p_load_sequence_number,
                                       p_uoo_id => NULL,
                                       p_message_for => l_message_for,
                                       p_message_icon=> 'D',
                                       p_message_name => l_message_name2,
                                       p_message_rule_text => NULL,
                                       p_message_tokens => NULL,
                                       p_message_action => NULL,
                                       p_destination => NULL,
                                       p_parameters => NULL,
                                       p_step_type => 'PROGRAM');
        END IF;
    END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
      FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.validate_enr_encb :',SQLERRM);
    END IF;
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.validate_enr_encb');
    IGS_GE_MSG_STACK.ADD;
    RAISE;

END validate_enr_encmb;

PROCEDURE reorder_uoo_ids(
                          p_person_id IN NUMBER,
                          p_course_cd IN VARCHAR2,
                          p_uoo_ids IN VARCHAR2,
                          p_load_cal_type IN VARCHAR2,
                          p_load_sequence_number IN NUMBER,
                          p_calling_obj IN VARCHAR2,
                          p_unit_params OUT NOCOPY t_params_table
                          )    AS
 -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  --Purpose :
  -- This procedure reorders the uooids in the order of superior/subordinate/others
  -- it also adds the sub/sup units that needs to be added if not selected by the user

  --Change History:
  --Who         When            What
  -- smaddali   27-apr-2006     Modified reorder_uooids for bug#4861221
  -------------------------------------------------------------------------------------------


  t_sup_params t_params_table;
  t_sub_params t_params_table;
  t_oth_params t_params_table;

  v_sup_index BINARY_INTEGER := 1;
  v_sub_index BINARY_INTEGER := 1;
  v_oth_index BINARY_INTEGER := 1;
  v_all_index BINARY_INTEGER := 1;

 -- cursor to get uooid relation type of the uooid passed
  CURSOR c_rel_type(p_uoo_id IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE) IS
  SELECT relation_type
  FROM igs_ps_unit_ofr_opt
  WHERE uoo_id = p_uoo_id;


  -- cursor to get planning sheet error units or plan units in case of plan
  CURSOR cur_fetch_ps_units IS
  SELECT  uoo_id,no_assessment_ind,grading_schema_code,gs_version_number,
          override_enrolled_cp
  FROM igs_en_plan_units
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND term_cal_type = p_load_cal_type
  AND term_ci_sequence_number = p_load_sequence_number
   AND( (p_calling_obj in('PLAN','SUBMITPLAN') and cart_error_flag = 'N')OR
       (p_calling_obj <> 'PLAN' and cart_error_flag = 'Y'));

  -- cursor to fetch the superior unit
  CURSOR c_fetch_sup(cp_uoo_id  IGS_PS_UNIT_OFR_OPT.sup_uoo_id%TYPE) IS
  SELECT sup_uoo_id
  FROM igs_ps_unit_ofr_opt
  WHERE uoo_id = cp_uoo_id
  AND relation_type = 'SUBORDINATE';

  -- cursor to fetch the subordinate units
  CURSOR c_sub_uoo_ids(cp_uoo_id  IGS_PS_UNIT_OFR_OPT.sup_uoo_id%TYPE) IS
  SELECT uoo_id,default_enroll_flag
  FROM igs_ps_unit_ofr_opt
  WHERE sup_uoo_id = cp_uoo_id
  AND relation_type = 'SUBORDINATE' ;

   -- cursor which checks wheter a unit attempt exists
  CURSOR c_sua_exists(cp_uoo_id  IGS_PS_UNIT_OFR_OPT.sup_uoo_id%TYPE) IS
  SELECT 'X'
  FROM igs_en_su_attempt
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND uoo_id = cp_uoo_id
  AND unit_attempt_status NOT IN ('DROPPED');


  l_sup_uoo_id            IGS_PS_UNIT_OFR_OPT.sup_uoo_id%TYPE;
  l_sub_uoo_id            IGS_PS_UNIT_OFR_OPT.uoo_id%TYPE;
  l_sua_exists            VARCHAR2(1);
  l_unit_sec              VARCHAR2(50);
  l_sup_exists            BOOLEAN;
  l_sub_exists            BOOLEAN;
  l_uoo_ids               VARCHAR2(10000);
  l_ps_units          VARCHAR2(3000);
  l_temp                  VARCHAR2(200);
  l_uoo_id                igs_ps_unit_ofr_opt.uoo_id%TYPE;
  l_ass_ind               igs_en_su_attempt.no_assessment_ind%TYPE;
  l_gradsch_cd            igs_en_su_attempt.grading_schema_code%TYPE;
  l_gs_version_number     NUMBER;
  l_override_cp           NUMBER;
  lunit                   VARCHAR2(500);
  l_rel_type              IGS_PS_UNIT_OFR_OPT.relation_type%TYPE;
  l_message_name          VARCHAR2(4000);
  l_return_status         VARCHAR2(100);
  l_enc_message_name      VARCHAR2(100);
  l_app_short_name        VARCHAR2(100);
  l_msg_index             NUMBER;
  l_function              VARCHAR2(100);
  l_create_sub_link       BOOLEAN;
  l_valid_pos             VARCHAR2(1);

BEGIN

  l_uoo_ids := p_uoo_ids;

 -- if the calling object is cart,SCHEDULE, ENROLPEND,or submit cart then append cart error uooids also
  --in case of plan,submit plan pick up the plan units for the term since the plannig sheet page
  --will not pass any parameters to the API except the selected units on the search pages.
  IF p_calling_obj IN ( 'CART' ,'SUBMITCART','SCHEDULE','ENROLPEND', 'PLAN','SUBMITPLAN') THEN


    FOR ps_units_rec IN cur_fetch_ps_units LOOP

      -- if the unit selected by the user already exists in planning sheet error records then dont add it
       -- l_uoo_ids will be of the form '5982,N,P/F,3,23;6014,N,F/P,4,33;'
       -- so appending ; for the first uoo_id  so that it will also be of the same form as other uooids (;uoo_id,)
      IF instr(';'||l_uoo_ids,';'||ps_units_rec.uoo_id||',') = 0 THEN


        l_uoo_ids := l_uoo_ids||ps_units_rec.uoo_id||','||ps_units_rec.no_assessment_ind||','||
        ps_units_rec.grading_schema_code||','|| ps_units_rec.gs_version_number|| ','||ps_units_rec.override_enrolled_cp||';';

         --Store the uoo_ids in a variable say l_ps_units to indicate planning sheet error units.

        IF l_ps_units IS NULL THEN
          l_ps_units := ','||ps_units_rec.uoo_id||',';
        ELSE
          l_ps_units := l_ps_units||ps_units_rec.uoo_id||',';
        END IF;

      END IF;-- IF instr(','||l_uoo_ids,','||ps_err_units_rec.uoo_id||',',0) <> 0) THEN

    END LOOP;

  END IF;  -- end of  p_calling_obj in ( 'CART' ,'SUBMITCART')



  -- Three temporary pl/sql tables are used to reorder the units.
  -- Loop through the uoo_ids and extract the values

  WHILE l_uoo_ids IS NOT NULL LOOP

    lunit := substr(l_uoo_ids,1,instr(l_uoo_ids, ';')-1);

    -- Remove the uoo id details which is extacted  above
    l_uoo_ids := substr(l_uoo_ids,instr(l_uoo_ids,';',1)+1);

    IF(instr(l_uoo_ids,';',1) = 0) THEN
        l_uoo_ids := NULL;
    END IF;

    IF lunit IS NOT NULL THEN

      -- lunit is 1234,Y,P/F,233,343 or 1234,Y,P/F,233,343,Y
      l_uoo_id := substr( lunit,1,instr(lunit,',')-1);
      l_ass_ind := substr(lunit, instr(lunit,',')+1, 1);

      -- l_temp will be P/F,233
      l_temp := substr( lunit, instr(lunit, ',',1,2)+1,( instr(lunit, ',',1,4) - (instr(lunit, ',',1,2)+1) ) );

      l_gradsch_cd := substr( l_temp,1,instr(l_temp,',')-1);
      l_gs_version_number := to_number( substr( l_temp,instr(l_temp,',',-1)+1));

       IF instr(lunit,',',1,5) = 0  THEN
         l_override_cp := to_number(substr( lunit,instr(lunit,',',1,4)+1));
         l_valid_pos := 'Y';
       ELSE
           l_override_cp := to_number(substr( lunit,instr(lunit,',',1,4)+1, ( instr(lunit, ',',1,5) - (instr(lunit, ',',1,4)+1) )));
           l_valid_pos := substr(lunit, instr(lunit,',',-1)+1, 1);
       END IF;

    END IF;

      --smaddali  added this code for bug#4861221
     IF l_valid_pos ='N' THEN
         -- log warning record for this unit section and donot include for further processing.
             l_unit_sec := get_unit_sec(l_uoo_id);

             igs_en_drop_units_api.create_ss_warning (
                              p_person_id => p_person_id,
                              p_course_cd => p_course_cd,
                              p_term_cal_type => p_load_cal_type,
                              p_term_ci_sequence_number => p_load_sequence_number,
                              p_uoo_id => l_uoo_id,
                              p_message_for => l_unit_sec,
                              p_message_icon=> 'D',
                              p_message_name => 'IGS_EN_SRCH_POS',
                              p_message_rule_text => NULL,
                              p_message_tokens => NULL,
                              p_message_action => NULL,
                              p_destination => NULL,
                              p_parameters => NULL,
                              p_step_type => 'UNIT');

               IF p_calling_obj <> 'PLAN' THEN
                     -- create a planning sheet error record to be shown in the cart
                    l_message_name := NULL;
                    l_return_status := NULL;
                    create_ps_record(p_person_id,
                                 p_course_cd,
                                 p_load_cal_type,
                                 p_load_sequence_number,
                                 l_uoo_id, -- uooid for which plannig sheet record is created
                                 NULL, --  superior uoo id
                                 'Y', -- cart error flag
                                 l_ass_ind, -- assessment ind
                                 NULL,
                                 NULL,
                                 NULL);
               END IF;
    ELSE

        --  Check if unit is superior , subordinate or none, add to 3 different temporary tables.
        OPEN c_rel_type(l_uoo_id);
        FETCH c_rel_type INTO l_rel_type;
        CLOSE c_rel_type;


        IF l_rel_type= 'SUPERIOR' THEN

          t_sup_params(v_sup_index).uoo_id := l_uoo_id;
          t_sup_params(v_sup_index).ass_ind := l_ass_ind;
          t_sup_params(v_sup_index).grading_schema_cd := l_gradsch_cd;
          t_sup_params(v_sup_index).gs_version_number:= l_gs_version_number;
          t_sup_params(v_sup_index).override_enrolled_cp := l_override_cp;
          t_sup_params(v_sup_index).spl_perm_step := NULL;
          t_sup_params(v_sup_index).aud_perm_step := NULL;
          t_sup_params(v_sup_index).wlst_step := NULL;

          v_sup_index :=v_sup_index+1;

        ELSIF l_rel_type = 'SUBORDINATE' THEN

          t_sub_params(v_sub_index).uoo_id := l_uoo_id;
          t_sub_params(v_sub_index).ass_ind := l_ass_ind;
          t_sub_params(v_sub_index).grading_schema_cd := l_gradsch_cd;
          t_sub_params(v_sub_index).gs_version_number:= l_gs_version_number;
          t_sub_params(v_sub_index).override_enrolled_cp := l_override_cp;
          t_sub_params(v_sub_index).spl_perm_step := NULL;
          t_sub_params(v_sub_index).aud_perm_step := NULL;
          t_sub_params(v_sub_index).wlst_step := NULL;

          v_sub_index := v_sub_index+1;

        ELSE

          t_oth_params(v_oth_index).uoo_id := l_uoo_id;
          t_oth_params(v_oth_index).ass_ind := l_ass_ind;
          t_oth_params(v_oth_index).grading_schema_cd := l_gradsch_cd;
          t_oth_params(v_oth_index).gs_version_number:= l_gs_version_number;
          t_oth_params(v_oth_index).override_enrolled_cp := l_override_cp;
          t_oth_params(v_oth_index).spl_perm_step := NULL;
          t_oth_params(v_oth_index).aud_perm_step := NULL;
          t_oth_params(v_oth_index).wlst_step := NULL;

          v_oth_index := v_oth_index+1;
        END IF;

     END IF; --IF l_valid_pos ='N' THEN
  END LOOP;

  -- Once the units are ordered in the three pl/sql tables , loop through each table to check
  -- if any extra units need to be added and if any warning records need to be logged.


  FOR i IN 1 .. t_sub_params.COUNT LOOP
  -- First loop through the subordinate uoo_ids table and fetch the superior unit code.
  -- Check if the superior unit has been selected / already attempted in sua/ already added to planning sheet
  -- if not then add it to the superior units temporary table and create a warning record

    OPEN c_fetch_sup(t_sub_params(i).uoo_id);
    FETCH c_fetch_sup INTO l_sup_uoo_id;

    --check if it has a superior
    IF c_fetch_sup%FOUND THEN

        CLOSE c_fetch_sup;
      --check if it is selected in the list of selected uoo_ids
        l_sup_exists := FALSE;
        l_sua_exists := NULL;

        -- check if it is in unit attempt table
        OPEN c_sua_exists(l_sup_uoo_id); -- it should be l_sup_uoo_id
        FETCH c_sua_exists INTO l_sua_exists;
        CLOSE c_sua_exists;

        -- if it is in unit attempt or plannig sheet table then set sup_exists to true
        -- else check if it is in selected units
        IF l_sua_exists IS NOT NULL THEN
          l_sup_exists := TRUE;
        ELSE

          FOR j IN 1 .. t_sup_params.COUNT LOOP
            --Check whether it is selected units

            IF l_sup_uoo_id = t_sup_params(j).uoo_id  THEN
              l_sup_exists := TRUE;
              EXIT;
            END IF;

          END LOOP;
        END IF;

        IF NOT l_sup_exists THEN
        --Create warning record

            l_unit_sec := get_unit_sec(l_sup_uoo_id);

            igs_en_drop_units_api.create_ss_warning (
                             p_person_id => p_person_id,
                             p_course_cd => p_course_cd,
                             p_term_cal_type => p_load_cal_type,
                             p_term_ci_sequence_number => p_load_sequence_number,
                             p_uoo_id => l_sup_uoo_id,
                             p_message_for => l_unit_sec,
                             p_message_icon=> 'I',
                             p_message_name => 'IGS_EN_AUTO_ADD_SUP',
                             p_message_rule_text => NULL,
                             p_message_tokens => 'UNIT_CD:'|| get_unit_sec(t_sub_params(i).uoo_id  )||';',
                             p_message_action => NULL,
                             p_destination => NULL,
                             p_parameters => NULL,
                             p_step_type => 'UNIT');

        --Add uoo_id to the superior uooIds table.
          t_sup_params(v_sup_index).uoo_id := l_sup_uoo_id;
          t_sup_params(v_sup_index).ass_ind := 'N';
          v_sup_index := v_sup_index+1;

        --If called from plan ,add unit to PS table,
        --         create_ps_record;
          IF p_calling_obj = 'PLAN' THEN

                create_ps_record(p_person_id,
                            p_course_cd,
                            p_load_cal_type,
                            p_load_sequence_number,
                            l_sup_uoo_id, -- uooid for which plannig sheet record is created
                            NULL, --  superior uoo id
                            'N', -- cart error flag
                            'N', -- assessment ind
                            NULL,
                            NULL,
                            NULL);
          END IF;


        END IF; -- IF NOT l_sup_exists

    ELSE
        CLOSE c_fetch_sup;
    END IF; -- IF fetch_sup%FOUND

  END LOOP;

-- Loop through each uoo_id to get all  subordinates. If auto enroll, add it \
-- and create a info record else create an action record in the warnings table

  FOR i IN 1 .. t_sup_params.COUNT LOOP

 ---  Do not auto enroll if unit is from the planning sheet table. Check the variable l_ps_units.

    IF l_ps_units IS NULL OR instr(l_ps_units,','||t_sup_params(i).uoo_id||',') = 0 THEN

      l_create_sub_link := FALSE;
      FOR sub_uoo_ids_rec IN c_sub_uoo_ids(t_sup_params(i).uoo_id)  LOOP

          -- check if the uoo_id is in the selected uoo_ids else add to the
          -- subordinate table if not already present in the student unit attempt table.
          l_sub_exists := FALSE;
          l_sua_exists := NULL;

          OPEN c_sua_exists(sub_uoo_ids_rec.uoo_id);
          FETCH c_sua_exists INTO l_sua_exists;
          CLOSE c_sua_exists;
         IF l_sua_exists IS NOT NULL THEN
            l_sub_exists := TRUE;
         ELSE
          FOR j IN 1 .. t_sub_params.COUNT LOOP

            IF sub_uoo_ids_rec.uoo_id = t_sub_params(j).uoo_id  THEN
              l_sub_exists := TRUE;
              EXIT;
            END IF;

          END LOOP;
        END IF;

          IF NOT l_sub_exists THEN
          -- check if auto enroll is 'Y'
           IF sub_uoo_ids_rec.default_enroll_flag = 'Y' THEN

              --Add to subordinates table.
             t_sub_params(v_sub_index).uoo_id := sub_uoo_ids_rec.uoo_id;
             t_sub_params(v_sub_index).ass_ind := 'N';
             v_sub_index := v_sub_index+1;

            l_unit_sec := get_unit_sec(sub_uoo_ids_rec.uoo_id);

            -- create warning record.
            igs_en_drop_units_api.create_ss_warning (
                               p_person_id => p_person_id,
                               p_course_cd => p_course_cd,
                               p_term_cal_type => p_load_cal_type,
                               p_term_ci_sequence_number =>  p_load_sequence_number,
                               p_uoo_id => sub_uoo_ids_rec.uoo_id,
                               p_message_for => l_unit_sec,
                               p_message_icon=> 'I',
                               p_message_name =>'IGS_EN_AUTO_ADD_SUB',
                               p_message_rule_text => NULL,
                               p_message_tokens => 'UNIT_CD:'|| get_unit_sec(t_sup_params(i).uoo_id  )||';',
                               p_message_action => NULL,
                               p_destination => NULL,
                               p_parameters => NULL,
                               p_step_type => 'UNIT');

            -- If called from plan, add to the planning sheet table.
              IF p_calling_obj = 'PLAN' THEN

               l_message_name := NULL;
               l_return_status := NULL;
               create_ps_record(p_person_id,
                                p_course_cd,
                                p_load_cal_type,
                                p_load_sequence_number,
                                sub_uoo_ids_rec.uoo_id, -- uooid for which plannig sheet record is created
                                t_sup_params(i).uoo_id, --  superior uoo id
                                'N', -- cart error flag
                                'N', -- assessment ind
                                NULL,
                                NULL,
                                NULL);

                                --************* Need to check what should be done after getting the return status
              END IF;

            ELSE
                      l_create_sub_link := TRUE;


            END IF; -- IF sub_uoo_ids_rec.default_enroll_flag = 'Y'

          END IF; -- IF NOT l_sub_exists

      END LOOP;-- FOR uoo_ids_rec IN

        -- if the subordinates have to be manually added then provide a warning record
        -- with link to the add subordinates page
        IF l_create_sub_link THEN
                IF p_calling_obj IN ('PLAN','SUBMITPLAN') THEN
                    l_function := 'IGS_EN_PLAN_COREQ_SUB';
                ELSIF p_calling_obj IN ('CART', 'SUBMITCART','SCHEDULE','ENROLPEND') THEN
                    l_function := 'IGS_EN_CART_COREQ_SUB';
                ELSIF p_calling_obj IN ('SWAP','SUBMITSWAP') THEN
                    l_function := 'IGS_EN_SCH_COREQ_SUB';
                END IF;

                l_unit_sec := get_unit_sec(t_sup_params(i).uoo_id);
                igs_en_drop_units_api.create_ss_warning (
                               p_person_id => p_person_id,
                               p_course_cd => p_course_cd,
                               p_term_cal_type => p_load_cal_type,
                               p_term_ci_sequence_number =>  p_load_sequence_number,
                               p_uoo_id =>  t_sup_params(i).uoo_id,
                               p_message_for => l_unit_sec,
                               p_message_icon=> 'I',
                               p_message_name =>'IGS_EN_MAN_ADD_SUB',
                               p_message_rule_text => NULL,
                               p_message_tokens => NULL,
                               p_message_action => igs_ss_enroll_pkg.enrf_get_lookup_meaning(p_lookup_code =>'ADD_SUB',p_lookup_type =>'IGS_EN_WARN_LINKS'),
                               p_destination => l_function,
                               p_parameters => NULL,
                               p_step_type => 'UNIT');
        END IF;
    END IF; -- IF instr(l_ps_units,','||t_sup_params(i).uoo_id||',') = 0

  END LOOP;--FOR i IN 1 .. t_sup_params.COUNT

  IF t_sup_params.COUNT > 0 THEN

    FOR i IN 1 .. t_sup_params.COUNT LOOP

     p_unit_params(v_all_index) := t_sup_params(i);
      v_all_index := v_all_index + 1;
    END LOOP;
  END IF;

  IF t_sub_params.COUNT > 0 THEN
       FOR i IN 1 .. t_sub_params.COUNT LOOP
         p_unit_params(v_all_index) := t_sub_params(i);
         v_all_index := v_all_index + 1;
       END LOOP;
  END IF;

  IF t_oth_params.COUNT > 0 THEN
       FOR i IN 1 .. t_oth_params.COUNT LOOP
         p_unit_params(v_all_index) := t_oth_params(i);
         v_all_index := v_all_index + 1;
       END LOOP;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.reorder_uoo_ids :',SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.reorder_uoo_ids');
      IGS_GE_MSG_STACK.ADD;
      RAISE;

END reorder_uoo_ids;


FUNCTION eval_cart_max(
                        p_person_id IN NUMBER,
                        p_enrollment_category IN VARCHAR2,
                        p_enr_method_type IN VARCHAR2,
                        p_comm_type IN VARCHAR2,
                        p_course_cd IN VARCHAR2,
                        p_course_version IN NUMBER,
                        p_load_cal_type IN VARCHAR2,
                        p_load_sequence_number IN NUMBER,
                        p_unit_params IN t_params_table,
                        p_message OUT NOCOPY VARCHAR2,
                        p_calling_obj IN VARCHAR2
                        ) RETURN BOOLEAN
                        AS PRAGMA  AUTONOMOUS_TRANSACTION;

-------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  --Purpose : evaluates cart max rule
  --
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------


  -- cursor to get the system person type
  CURSOR cur_sys_pers_type IS
  SELECT system_type
  FROM igs_pe_person_types
  WHERE person_type_code = g_person_type;

  --  cursor to get the unit code and unit class
  CURSOR c_sua_exists(cp_uoo_id  IGS_PS_UNIT_OFR_OPT.sup_uoo_id%TYPE) IS
  SELECT unit_cd||'/'||unit_class
  FROM igs_en_su_attempt
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND uoo_id = cp_uoo_id
  AND unit_attempt_status <> 'DROPPED';

    -- cursor to get the unit details
  CURSOR c_unit_dtls (cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
  SELECT ofr.unit_cd, ofr.version_number, ofr.cal_type, ofr.ci_sequence_number,
         ofr.location_cd, ofr.unit_class, ca.start_dt, ca.end_dt
  FROM igs_ps_unit_ofr_opt ofr, igs_ca_inst_all ca
  WHERE ofr.uoo_id = cp_uoo_id
  AND ofr.cal_type = ca.cal_type
  AND ofr.ci_sequence_number = ca.sequence_number;

  CURSOR c_sua(cp_person_id igs_en_su_attempt_all.person_id%TYPE,
               cp_course_cd igs_en_su_attempt_all.course_cd%TYPE,
               cp_uoo_id     igs_en_su_attempt_all.uoo_id%TYPE) IS
  SELECT sua.rowid
  FROM   IGS_EN_SU_ATTEMPT_ALL SUA
  WHERE  sua.person_id=cp_person_id
  AND    sua.course_cd=cp_course_cd
  AND    sua.uoo_id=cp_uoo_id
  AND    sua.unit_attempt_status='DROPPED';

  TYPE c_ref_cursor IS REF CURSOR;
  cur_step_def_var c_ref_cursor;

  l_unit_dtsl_rec                   c_unit_dtls%ROWTYPE;
  l_enc_message_name                VARCHAR2(2000);
  l_app_short_name                  VARCHAR2(100);
  l_msg_index                       NUMBER;
  l_sys_per_type                    igs_pe_person_types.system_type%TYPE;
  l_en_cpd_ext_rec                  igs_en_cpd_ext%ROWTYPE;
  l_message_name                    VARCHAR2(100);
  l_deny_warn                       igs_en_cpd_ext.notification_flag%TYPE;
  p_rule_failed                     BOOLEAN;
  l_step_def_query                  VARCHAR2(1000);
  l_unit_sec                        VARCHAR2(50);
  l_message_for                     VARCHAR2(100);
  l_rowid                           VARCHAR2(25);

BEGIN

  OPEN cur_sys_pers_type;
  FETCH cur_sys_pers_type INTO l_sys_per_type;
  CLOSE cur_sys_pers_type;


  IF l_sys_per_type = 'STUDENT' THEN

    l_step_def_query :=  'SELECT eru.*
                          FROM igs_en_cpd_ext eru, igs_lookups_view lkv
                          WHERE eru.s_enrolment_step_type =lkv.lookup_code
                          AND lkv.lookup_type = ''ENROLMENT_STEP_TYPE_EXT''
                          AND lkv.step_group_type = ''UNIT''
                          AND eru.enrolment_cat = :1
                          AND eru.enr_method_type = :2
                          AND ( eru.s_student_comm_type = :3 OR
                                    eru.s_student_comm_type = ''ALL''  )
                          AND eru.s_enrolment_step_type = ''CART_MAX''';

     OPEN cur_step_def_var FOR l_step_def_query USING p_enrollment_category, p_enr_method_type, p_comm_type;

  ELSE

    l_step_def_query :=  'SELECT eru.*
                          FROM igs_en_cpd_ext eru, igs_pe_usr_aval_all uact,   igs_lookups_view lkv
                          WHERE eru.s_enrolment_step_type =lkv.lookup_code
                          AND  lkv.lookup_type = ''ENROLMENT_STEP_TYPE_EXT''
                          AND lkv.step_group_type = ''UNIT''
                          AND eru.s_enrolment_step_type = uact.validation(+)
                          AND uact.person_type(+) = :1
                          AND NVL(uact.override_ind,''N'') = ''N''
                          AND  eru.enrolment_cat = :2
                          AND eru.enr_method_type = :3
                          AND ( eru.s_student_comm_type = :4 OR
                                    eru.s_student_comm_type = ''ALL'')
                          AND eru.s_enrolment_step_type = ''CART_MAX''';

    OPEN cur_step_def_var FOR l_step_def_query USING g_person_type, p_enrollment_category, p_enr_method_type, p_comm_type;

  END IF;

  FETCH cur_step_def_var INTO l_en_cpd_ext_rec;
  CLOSE cur_step_def_var;

  IF  l_en_cpd_ext_rec.rul_sequence_number IS NULL THEN
    ROLLBACK;
    RETURN TRUE;

  END IF;

  p_rule_failed := FALSE;
  l_message_name := NULL;
  l_deny_warn  :=  igs_ss_enr_details.get_notification(
                                       p_person_type         => g_person_type,
                                       p_enrollment_category => l_en_cpd_ext_rec.enrolment_cat,
                                       p_comm_type           => l_en_cpd_ext_rec.s_student_comm_type,
                                       p_enr_method_type     => l_en_cpd_ext_rec.enr_method_type,
                                       p_step_group_type     => 'UNIT',
                                       p_step_type           => l_en_cpd_ext_rec.s_enrolment_step_type,
                                       p_person_id           => p_person_id,
                                       p_message             => l_message_name);
  IF l_message_name IS NOT NULL THEN
    p_message := l_message_name;
    ROLLBACK;
    RETURN FALSE;
  END IF;

  IF p_unit_params.COUNT > 0 THEN

    FOR i IN 1.. p_unit_params.COUNT LOOP

            BEGIN

                --Check that unit attempt does not already exist. If it does then set p_message and return
                OPEN c_sua_exists(p_unit_params(i).uoo_id); -- it should be l_sup_uoo_id
                FETCH c_sua_exists INTO l_unit_sec;

                -- if unit already exists for the person then throw an error
                IF c_sua_exists%FOUND THEN

                    CLOSE c_sua_exists;
                    -- Incase of submit plan a unit may be  in planning sheet
                    -- and at the same time be in preenroll units. So skipping this check and pass onto next record
                    IF p_calling_obj <> 'SUBMITPLAN' THEN
                      p_message := 'IGS_EN_SUA_EXISTS'||'*'||l_unit_sec;
                      ROLLBACK;
                      RETURN FALSE;
                    END IF;

                ELSE
                    CLOSE c_sua_exists;

                    -- First check if unit can be enrolled i.e it should not have a special/audit permission step error and seats must be available to enroll.

                    IF p_unit_params(i).spl_perm_step = 'PERM_NREQ' AND
                        p_unit_params(i).aud_perm_step = 'PERM_NREQ' AND
                            p_unit_params(i).wlst_step = 'N' THEN

                          -- create unit attempts by using a dynamic SQL statement if the above procedure call returns 'N'.
                          OPEN c_unit_dtls(p_unit_params(i).uoo_id);
                          FETCH c_unit_dtls INTO l_unit_dtsl_rec;
                          CLOSE c_unit_dtls;

                          OPEN c_sua(p_person_id,p_course_cd,p_unit_params(i).uoo_id);
                          FETCH c_sua INTO l_rowid;

			 --unit section was not attempted and dropped, so create new unit attempt
                         IF c_sua%NOTFOUND THEN
                          CLOSE c_sua;

                          INSERT INTO IGS_EN_SU_ATTEMPT_ALL (
                                                      PERSON_ID,
                                                      COURSE_CD,
                                                      UNIT_CD,
                                                      VERSION_NUMBER,
                                                      CAL_TYPE,
                                                      CI_SEQUENCE_NUMBER,
                                                      LOCATION_CD,
                                                      UNIT_CLASS,
                                                      CI_START_DT,
                                                      CI_END_DT,
                                                      UOO_ID,
                                                      ENROLLED_DT,
                                                      UNIT_ATTEMPT_STATUS,
                                                      ADMINISTRATIVE_UNIT_STATUS,
                                                      DISCONTINUED_DT,
                                                      RULE_WAIVED_DT,
                                                      RULE_WAIVED_PERSON_ID,
                                                      NO_ASSESSMENT_IND,
                                                      SUP_UNIT_CD,
                                                      SUP_VERSION_NUMBER,
                                                      EXAM_LOCATION_CD,
                                                      ALTERNATIVE_TITLE,
                                                      OVERRIDE_ENROLLED_CP,
                                                      OVERRIDE_EFTSU,
                                                      OVERRIDE_ACHIEVABLE_CP,
                                                      OVERRIDE_OUTCOME_DUE_DT,
                                                      OVERRIDE_CREDIT_REASON,
                                                      ADMINISTRATIVE_PRIORITY,
                                                      WAITLIST_DT,
                                                      DCNT_REASON_CD,
                                                      CREATION_DATE,
                                                      CREATED_BY,
                                                      LAST_UPDATE_DATE,
                                                      LAST_UPDATED_BY,
                                                      LAST_UPDATE_LOGIN,
                                                      REQUEST_ID,
                                                      PROGRAM_ID,
                                                      PROGRAM_APPLICATION_ID,
                                                      PROGRAM_UPDATE_DATE,
                                                      org_id,
                                                      GS_VERSION_NUMBER,
                                                      ENR_METHOD_TYPE  ,
                                                      FAILED_UNIT_RULE ,
                                                      CART             ,
                                                      RSV_SEAT_EXT_ID   ,
                                                      ORG_UNIT_CD      ,
                                                      GRADING_SCHEMA_CODE ,
                                                      subtitle,
                                                      session_id,
                                                      deg_aud_detail_id,
                                                      student_career_transcript,
                                                      student_career_statistics,
                                                      waitlist_manual_ind ,
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
                                                      WLST_PRIORITY_WEIGHT_NUM,
                                                      WLST_PREFERENCE_WEIGHT_NUM,
                                                      CORE_INDICATOR_CODE,
                                                      UPD_AUDIT_FLAG,
                                                      SS_SOURCE_IND
                                                    )
                                                    VALUES (p_person_id,
                                                            p_course_cd,
                                                            l_unit_dtsl_rec.unit_cd, -- unit_cd
                                                            l_unit_dtsl_rec.version_number, -- unit ver no
                                                            l_unit_dtsl_rec.cal_type, -- cal_type
                                                            l_unit_dtsl_rec.ci_sequence_number, -- cal seq num
                                                            l_unit_dtsl_rec.location_cd,
                                                            l_unit_dtsl_rec.unit_class,
                                                            l_unit_dtsl_rec.start_dt,
                                                            l_unit_dtsl_rec.end_dt,
                                                            p_unit_params(i).uoo_id,
                                                            NULL, -- enrolled date
                                                            'UNCONFIRM',
                                                            NULL, -- ADMINISTRATIVE_UNIT_STATUS
                                                            NULL, -- DISCONTINUED_DT
                                                            NULL, -- RULE_WAIVED_DT,
                                                            NULL, -- RULE_WAIVED_PERSON_ID,
                                                            p_unit_params(i).ass_ind, -- NO_ASSESSMENT_IND,
                                                            NULL, -- SUP_UNIT_CD,
                                                            NULL, -- SUP_VERSION_NUMBER,
                                                            NULL, -- EXAM_LOCATION_CD
                                                            NULL, -- ALTERNATIVE_TITLE,
                                                            p_unit_params(i).override_enrolled_cp, -- OVERRIDE_ENROLLED_CP,
                                                            NULL, --- OVERRIDE_EFTSU,
                                                            NULL, -- OVERRIDE_ACHIEVABLE_CP,
                                                            NULL, -- OVERRIDE_OUTCOME_DUE_DT,
                                                            NULL, -- OVERRIDE_CREDIT_REASON,
                                                            NULL, -- ADMINISTRATIVE_PRIORITY,
                                                            NULL, -- WAITLIST_DT,
                                                            NULL, -- DCNT_REASON_CD,
                                                            SYSDATE, -- CREATION_DATE,
                                                            NVL(FND_GLOBAL.USER_ID,-1),-- CREATED_BY,
                                                            SYSDATE, --   LAST_UPDATE_DATE,
                                                            NVL(FND_GLOBAL.USER_ID,-1), -- LAST_UPDATED_BY,
                                                            NVL(FND_GLOBAL.LOGIN_ID,-1), -- LAST_UPDATE_LOGIN,
                                                            NULL, -- REQUEST_ID,
                                                            NULL, --PROGRAM_ID,
                                                            NULL, --PROGRAM_APPLICATION_ID,
                                                            NULL, --PROGRAM_UPDATE_DATE,
                                                            NULL, --  org_id,
                                                            p_unit_params(i).gs_version_number, --    GS_VERSION_NUMBER,
                                                            NULL, --        ENR_METHOD_TYPE  ,
                                                            NULL, --FAILED_UNIT_RULE ,
                                                            NULL, --CART             ,
                                                            NULL, -- RSV_SEAT_EXT_ID   ,
                                                            NULL, -- ORG_UNIT_CD      ,
                                                            p_unit_params(i).grading_schema_cd, -- GRADING_SCHEMA_CODE ,
                                                            NULL, -- subtitle,
                                                            igs_en_add_units_api.g_ss_session_id, -- session_id,
                                                            NULL, -- deg_aud_detail_id,
                                                            NULL, -- student_career_transcript,
                                                            NULL, -- student_career_statistics,
                                                            NULL, -- waitlist_manual_ind ,--Bug ID: 2554109  added by adhawan
                                                            NULL, -- ATTRIBUTE_CATEGORY,
                                                            NULL, -- ATTRIBUTE1,
                                                            NULL, -- ATTRIBUTE2,
                                                            NULL, -- ATTRIBUTE3,
                                                            NULL, -- ATTRIBUTE4,
                                                            NULL, -- ATTRIBUTE5,
                                                            NULL, -- ATTRIBUTE6,
                                                            NULL, -- ATTRIBUTE7,
                                                            NULL, -- ATTRIBUTE8,
                                                            NULL, -- ATTRIBUTE9,
                                                            NULL, -- ATTRIBUTE10,
                                                            NULL, -- ATTRIBUTE11,
                                                            NULL, -- ATTRIBUTE12,
                                                            NULL, -- ATTRIBUTE13,
                                                            NULL, -- ATTRIBUTE14,
                                                            NULL, -- ATTRIBUTE15,
                                                            NULL, -- ATTRIBUTE16,
                                                            NULL, -- ATTRIBUTE17,
                                                            NULL, -- ATTRIBUTE18,
                                                            NULL, -- ATTRIBUTE19,
                                                            NULL, -- ATTRIBUTE20,
                                                            NULL, -- WLST_PRIORITY_WEIGHT_NUM,
                                                            NULL, -- WLST_PREFERENCE_WEIGHT_NUM,
                                                            NULL, -- CORE_INDICATOR_CODE
                                                            'N', -- upd_audit_ind
                                                            'N'); -- ss_source_ind
                   ELSE
		     -- unit attempt was attempted and dropped previously, so update that record
                      CLOSE c_sua;

                       UPDATE IGS_EN_SU_ATTEMPT_ALL SET
                       VERSION_NUMBER =l_unit_dtsl_rec.version_number,
                       LOCATION_CD = l_unit_dtsl_rec.location_cd,
                       UNIT_CLASS = l_unit_dtsl_rec.unit_class,
                       CI_START_DT = l_unit_dtsl_rec.start_dt,
                       CI_END_DT = l_unit_dtsl_rec.end_dt,
                       ENROLLED_DT = NULL,
                       UNIT_ATTEMPT_STATUS = 'UNCONFIRM',
                       ADMINISTRATIVE_UNIT_STATUS = NULL,
                       DISCONTINUED_DT = NULL,
                       RULE_WAIVED_DT = NULL,
                       RULE_WAIVED_PERSON_ID = NULL,
                       NO_ASSESSMENT_IND = p_unit_params(i).ass_ind,
                       SUP_UNIT_CD = NULL,
                       SUP_VERSION_NUMBER = NULL,
                       EXAM_LOCATION_CD = NULL,
                       ALTERNATIVE_TITLE = NULL,
                       OVERRIDE_ENROLLED_CP = p_unit_params(i).override_enrolled_cp,
                       OVERRIDE_EFTSU = NULL,
                       OVERRIDE_ACHIEVABLE_CP = NULL,
                       OVERRIDE_OUTCOME_DUE_DT = NULL,
                       OVERRIDE_CREDIT_REASON = NULL,
                       ADMINISTRATIVE_PRIORITY = NULL,
                       WAITLIST_DT = NULL,
                       DCNT_REASON_CD = NULL,
                       LAST_UPDATE_DATE = SYSDATE,
                       LAST_UPDATED_BY = NVL(FND_GLOBAL.USER_ID,-1),
                       LAST_UPDATE_LOGIN = NVL(FND_GLOBAL.LOGIN_ID,-1),
                       REQUEST_ID = NULL,
                       PROGRAM_ID = NULL,
                       PROGRAM_APPLICATION_ID = NULL,
                       PROGRAM_UPDATE_DATE = NULL,
                       GS_VERSION_NUMBER   = p_unit_params(i).gs_version_number,
                       ENR_METHOD_TYPE     = NULL,
                       FAILED_UNIT_RULE    = NULL,
                       CART                = NULL,
                       RSV_SEAT_EXT_ID     = NULL,
                       ORG_UNIT_CD         = NULL,
                       GRADING_SCHEMA_CODE = p_unit_params(i).grading_schema_cd,
                       SUBTITLE            = NULL,
                       SESSION_ID          = igs_en_add_units_api.g_ss_session_id,
                       DEG_AUD_DETAIL_ID   = NULL,
                       STUDENT_CAREER_TRANSCRIPT = NULL,
                       STUDENT_CAREER_STATISTICS =  NULL,
                       WAITLIST_MANUAL_IND =  NULL,
                       ATTRIBUTE_CATEGORY =  NULL,
                       ATTRIBUTE1 =  NULL,
                       ATTRIBUTE2 =  NULL,
                       ATTRIBUTE3 =  NULL,
                       ATTRIBUTE4 =  NULL,
                       ATTRIBUTE5 =  NULL,
                       ATTRIBUTE6 =  NULL,
                       ATTRIBUTE7 =  NULL,
                       ATTRIBUTE8 =  NULL,
                       ATTRIBUTE9 =  NULL,
                       ATTRIBUTE10 =  NULL,
                       ATTRIBUTE11 =  NULL,
                       ATTRIBUTE12 =  NULL,
                       ATTRIBUTE13 =  NULL,
                       ATTRIBUTE14 =  NULL,
                       ATTRIBUTE15 =  NULL,
                       ATTRIBUTE16 =  NULL,
                       ATTRIBUTE17 =  NULL,
                       ATTRIBUTE18 =  NULL,
                       ATTRIBUTE19 =  NULL,
                       ATTRIBUTE20 =  NULL,
                       WLST_PRIORITY_WEIGHT_NUM = NULL,
                       WLST_PREFERENCE_WEIGHT_NUM = NULL,
                       CORE_INDICATOR_CODE = NULL,
                       UPD_AUDIT_FLAG      = 'N' ,
                       SS_SOURCE_IND       = 'N'
                       WHERE ROWID = l_rowid;


                      END IF;

                         IF NOT p_rule_failed THEN
                               -- Call the cart max procedure.
                               IF NOT igs_En_elgbl_unit.eval_cart_max(
                                         p_person_id => p_person_id,
                                         p_load_cal_type => p_load_cal_type,
                                         p_load_sequence_number => p_load_sequence_number,
                                         p_uoo_id  => p_unit_params(i).uoo_id,
                                         p_course_cd => p_course_cd,
                                         p_course_version => p_course_version,
                                         p_message => p_message,
                                         p_deny_warn => l_deny_warn,
                                         p_rule_seq_number => l_en_cpd_ext_rec.rul_sequence_number
                                  ) THEN
                                    p_rule_failed := TRUE;

                               END IF; -- IF NOT igs_En_elgbl_unit.eval_cart_max(
                         END IF; -- NOT p_rule_failed
                    END IF; -- IF p_unit_params.perm_step = 'PERM_NREQ'
                END IF; --  IF c_sua_exists%FOUND THEN
           EXCEPTION

              WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
                --  get message from stack and insert into warn record.
                IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
                FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);

                IF l_message_name IS NOT NULL THEN

                    igs_en_drop_units_api.create_ss_warning (
                                       p_person_id => p_person_id,
                                       p_course_cd => p_course_cd,
                                       p_term_cal_type=> p_load_cal_type,
                                       p_term_ci_sequence_number => p_load_sequence_number,
                                       p_uoo_id => p_unit_params(i).uoo_id,
                                       p_message_for => l_unit_dtsl_rec.unit_cd||'/'||l_unit_dtsl_rec.unit_class,
                                       p_message_icon=> 'D',
                                       p_message_name => l_message_name,
                                       p_message_rule_text => NULL,
                                       p_message_tokens => NULL,
                                       p_message_action=> NULL,
                                       p_destination => NULL,
                                       p_parameters => NULL,
                                       p_step_type => 'UNIT');
                END IF;

              WHEN OTHERS THEN
                 ROLLBACK;
                 RAISE;
            END;

    END LOOP; -- FOR i in 1.. p_unit_params.count LOOP
    ROLLBACK;

  END IF; -- IF p_unit_params.count > 0 THEN

  IF p_rule_failed THEN
    l_message_for := igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                           p_lookup_code => 'CART_MAX',
                                           p_lookup_type => 'ENROLMENT_STEP_TYPE_EXT');
    --Check if step is deny or warn
    IF l_deny_warn = 'DENY' THEN

      IF p_calling_obj = 'SUBMITPLAN' THEN
        l_message_name := 'IGS_EN_PLANMAX_TAB_DENY';
         igs_en_drop_units_api.create_ss_warning(
                               p_person_id => p_person_id,
                               p_course_cd => p_course_cd,
                               p_term_cal_type => p_load_cal_type,
                               p_term_ci_sequence_number =>  p_load_sequence_number,
                               p_uoo_id => NULL,  ---- need tocheck the uooid tp be passed
                               p_message_for => l_message_for,  -- message_for
                               p_message_icon=> 'D',
                               p_message_name => l_message_name,
                               p_message_rule_text => NULL,
                               p_message_tokens => NULL,
                               p_message_action => NULL,
                               p_destination => NULL,
                               p_parameters => NULL,
                               p_step_type => 'UNIT');
               ROLLBACK;
               RETURN TRUE;
      ELSE
         p_message := 'IGS_EN_CARTMAX_TAB_DENY';
         ROLLBACK;
         RETURN FALSE;
      END IF;


    ELSIF  l_deny_warn = 'WARN' THEN

      IF p_calling_obj = 'SUBMITPLAN' THEN
        l_message_name := 'IGS_EN_PLANMAX_TAB_WARN';
     ELSE
        l_message_name := 'IGS_EN_CARTMAX_TAB_WARN';
      END IF;

      igs_en_drop_units_api.create_ss_warning(
                               p_person_id => p_person_id,
                               p_course_cd => p_course_cd,
                               p_term_cal_type => p_load_cal_type,
                               p_term_ci_sequence_number =>  p_load_sequence_number,
                               p_uoo_id => NULL,  ---- need tocheck the uooid tp be passed
                               p_message_for => l_message_for,  -- message_for
                               p_message_icon=> 'W',
                               p_message_name => l_message_name,
                               p_message_rule_text => NULL,
                               p_message_tokens => NULL,
                               p_message_action => NULL,
                               p_destination => NULL,
                               p_parameters => NULL,
                               p_step_type => 'UNIT');
      ROLLBACK;
      RETURN TRUE;
    END IF;
  END IF;

  ROLLBACK;
  RETURN TRUE;
EXCEPTION
  -- In case of exception rollback and return false.
   WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.eval_cart_max :',SQLERRM);
      END IF;
      ROLLBACK;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.eval_cart_max');
      IGS_GE_MSG_STACK.ADD;
      RAISE;
END eval_cart_max;

PROCEDURE create_planned_sua( p_person_id IN NUMBER,
                              p_course_cd IN VARCHAR2,
                              p_course_version  IN NUMBER,
                              p_load_cal_type IN VARCHAR2,
                              p_load_sequence_number IN NUMBER,
                              p_unit_params IN t_params_table,
                              p_enrollment_category IN VARCHAR2,
                              p_enr_method_type IN VARCHAR2,
                              p_comm_type IN VARCHAR2,
                              p_message OUT NOCOPY VARCHAR2,
                              p_return_status OUT NOCOPY  VARCHAR2,
                              p_calling_obj IN VARCHAR2) AS

 -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  -- Purpose : makes unit abd program step validations for the passed units along with
  -- preenroll units (units that are added by admin through preenrollment job or through admin self-service)
  --Change History:
  --Who         When            What
  --bdeviset    14-NOV-2005     Added cursor c_sua and update igs_en_su_attempt all for bug# 4723960
  -- ckasu      27-NOV-2005     modified create_planned_sua by changing direct DML insert,update with
  --                            INSERT_ROW,UPDATE_ROW of SUA TBH as a part of bug#4666102
  -------------------------------------------------------------------------------------------

  -- cursor to fetch the unit details
  CURSOR c_get_unit_dtls (cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
  SELECT ofr.unit_cd, ofr.version_number, ofr.cal_type, ofr.ci_sequence_number,
         ofr.location_cd, ofr.unit_class, ca.start_dt, ca.end_dt
  FROM igs_ps_unit_ofr_opt ofr, igs_ca_inst_all ca
  WHERE ofr.uoo_id = cp_uoo_id
  AND ofr.cal_type = ca.cal_type
  AND ofr.ci_sequence_number = ca.sequence_number;


  -- cursor to fetch preenroll units
  CURSOR c_get_preenr_units IS
  SELECT DISTINCT sua.uoo_id, sua.sup_unit_cd, no_assessment_ind,unit_Attempt_Status,ss_source_ind
  FROM igs_en_su_attempt sua,igs_ca_teach_to_load_v load
  WHERE sua.person_id = p_person_id
  AND  sua.course_cd = p_course_cd
  AND  sua.unit_attempt_status = 'UNCONFIRM'
  AND NVL(sua.ss_source_ind  ,'N')  <> 'S'
  AND sua.cal_type = load.teach_cal_type
  AND sua.ci_sequence_number = load.teach_ci_sequence_number
  AND load_cal_type = p_load_cal_type
  AND load_ci_sequence_number = p_load_sequence_number
  ORDER BY sua.sup_unit_cd DESC;

  -- Get the details of unit attempt
  CURSOR c_get_sua_dtls (cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
  SELECT sua.*
  FROM igs_en_su_attempt sua
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND uoo_id = cp_uoo_id;


  NO_AUSL_RECORD_FOUND EXCEPTION;
  PRAGMA EXCEPTION_INIT(NO_AUSL_RECORD_FOUND , -20010);

  l_rowid                         VARCHAR2(100);
  l_unit_rec                      c_get_unit_dtls%ROWTYPE;
  l_core_indicator_code           igs_en_su_attempt.core_indicator_code%TYPE;
  l_combined_unit_params          t_params_table;
  l_return_status                       VARCHAR2(20);
  v_comb_index                    BINARY_INTEGER := 1;
  l_uoo_id                        igs_en_su_attempt.uoo_id%TYPE;
  l_sup_unit_cd                   igs_en_su_attempt.sup_unit_cd%TYPE;
  l_message_name                  VARCHAR2(4000);
  l_deny_warn                     VARCHAR2(30);
  l_deny_warn_max_cp              VARCHAR2(10);
  l_deny_warn_min_cp              VARCHAR2(10);
  l_sua_rec                       igs_en_su_attempt%ROWTYPE;
  l_credit_points                 NUMBER;
  l_min_credit_point              NUMBER;
  l_enc_message_name              VARCHAR2(2000);
  l_app_short_name                VARCHAR2(100);
  l_msg_index                     NUMBER;
  l_unit_sec                      VARCHAR2(100);
  l_max_cp_fail                   BOOLEAN;
  l_min_cp_fail                   BOOLEAN;
  l_create_wlst                   VARCHAR2(1);
  l_no_ass_ind                    igs_en_su_attempt.no_assessment_ind%TYPE;
  x_OVERRIDE_ACHIEVABLE_CP        NUMBER;
  x_OVERRIDE_ENROLLED_CP        NUMBER;
  lv_message_name               VARCHAR2(100);
  lv_teach_cal_type              igs_ps_unit_ofr_opt.cal_type%TYPE;
 lv_teach_ci_sequence_number      igs_ps_unit_ofr_opt.ci_sequence_number%TYPE;
 lv_unit_cd                      igs_ps_unit_ofr_opt.unit_cd%TYPE;
 lv_unit_class                  igs_ps_unit_ofr_opt.unit_class%TYPE;
 crse_hold_fail                  BOOLEAN ;
 l_message_for                   VARCHAR2(100);
 l_message_tokens                VARCHAR2(200);

  CURSOR c_teach_cal (cp_uoo_id igs_ps_unit_ofr_opt.uoo_id%TYPE) IS
  SELECT cal_type, ci_sequence_number,unit_cd,unit_class
  FROM igs_ps_unit_ofr_opt
  WHERE uoo_id = cp_uoo_id;

 CURSOR  c_teach_census_dt(p_cal_type  igs_ps_unit_ofr_opt.cal_type%TYPE,
                           p_ci_sequence_number igs_ps_unit_ofr_opt.ci_sequence_number%TYPE)IS
                SELECT  daiv.alias_val,
                        ci.start_dt,
                        ci.end_dt
                FROM    IGS_CA_DA_INST_V        daiv,
                        IGS_CA_INST             ci,
                        IGS_GE_S_GEN_CAL_CON            sgcc
                WHERE   daiv.cal_type           = p_cal_type AND
                        daiv.ci_sequence_number = p_ci_sequence_number AND
                        daiv.dt_alias           = sgcc.census_dt_alias AND
                        sgcc.s_control_num      = 1 AND
                        daiv.cal_type           = ci.cal_type AND
                        daiv.ci_sequence_number = ci.sequence_number;

BEGIN
  -- loop to insert  unit attempts  with unit attempt status as planned
   crse_hold_fail  := FALSE;
  FOR i IN 1.. p_unit_params.COUNT LOOP

    BEGIN

          --  Check if unit requires special/audit permission, if required the procedure creates the appropriate warning record and returns true.
          -- If the procedure has returned false, it implies that no permission is required and the API can continue with the creation of unit attempts.
          -- The out paramter l_message_name has a value only in case of errors.  Hence check for the same and exit out.
          l_message_name := NULL;
          IF permission_required(   p_person_id,
                                    p_course_cd,
                                    p_load_cal_type,
                                    p_load_sequence_number,
                                    p_unit_params(i).uoo_id,
                                    p_unit_params(i).spl_perm_step ,
                                    p_unit_params(i).aud_perm_step ,
                                    p_unit_params(i).ass_ind,
                                    p_unit_params(i).override_enrolled_cp,
                                    p_unit_params(i).grading_schema_cd,
                                    p_unit_params(i).gs_version_number,
                                    l_message_name,
                                    p_calling_obj) THEN

              IF l_message_name IS NOT NULL THEN
              --implies some unexpected error , set return status and message name and stop processing.

                p_return_status := 'FALSE';
                p_message := l_message_name;
                RETURN;

              END IF; -- IF l_message_name IS NOT NULL

         ELSE

              IF waitlist_required(
                            p_person_id ,
                            p_course_cd ,
                            p_unit_params(i).uoo_id,
                            p_unit_params(i).wlst_step,
                            p_load_cal_type,
                            p_load_sequence_number,
                            p_unit_params(i).ass_ind,
                            p_enr_method_type,
                            p_unit_params(i).override_enrolled_cp,
                            NULL,
                            p_unit_params(i).grading_schema_cd,
                            p_unit_params(i).gs_version_number,
                            l_create_wlst,
                            p_calling_obj ,
                            l_message_name) THEN

                   IF l_message_name IS NOT NULL THEN
                  --implies some unexpected error , set return status and message name and stop processing.

                     p_return_status := 'FALSE';
                     p_message := l_message_name;
                     RETURN;

                    END IF; -- IF l_message_name IS NOT NULL

             ELSE
                l_core_indicator_code := igs_en_gen_009.enrp_check_usec_core(
                                                                        p_person_id => p_person_id,
                                                                        p_program_cd => p_course_cd,
                                                                        p_uoo_id => p_unit_params(i).uoo_id);

                OPEN c_get_unit_dtls(p_unit_params(i).uoo_id);
                FETCH c_get_unit_dtls INTO l_unit_rec;
                CLOSE c_get_unit_dtls;




lv_message_name := null;
l_message_for :=  igs_ss_enroll_pkg.enrf_get_lookup_meaning (
                                                   p_lookup_code => 'CRSENCUMB',
                                                   p_lookup_type => 'ENROLMENT_STEP_TYPE');
        OPEN c_teach_Cal(p_unit_params(i).uoo_id);
        FETCH c_teach_cal INTO lv_teach_cal_type, lv_teach_ci_sequence_number, lv_unit_cd, lv_unit_class;
        CLOSE c_teach_Cal;

 FOR v_census_dt_rec IN c_teach_census_dt(lv_teach_cal_type, lv_teach_ci_sequence_number) LOOP
                -- Only validate if census date is between ci.start_dt and ci.end_dt.

                IF (v_census_dt_rec.alias_val >= v_census_dt_rec.start_dt) AND
                                (v_census_dt_rec.alias_val <= v_census_dt_rec.end_dt) THEN

                    lv_message_name := null;
                    IF  IGS_EN_VAL_ENCMB.enrp_val_excld_unit (
                                                                p_person_id,
                                                                p_course_cd,
                                                                lv_unit_cd,
                                                                v_census_dt_rec.alias_val,
                                                                lv_message_name) = FALSE THEN

                                 igs_en_drop_units_api.create_ss_warning(
                                 p_person_id => p_person_id,
                                 p_course_cd => p_course_cd,
                                 p_term_cal_type => p_load_cal_type,
                                 p_term_ci_sequence_number =>  p_load_sequence_number,
                                 p_uoo_id => p_unit_params(i).uoo_id,
                                 p_message_for => lv_unit_cd||'/'||lv_unit_class,
                                 p_message_icon=> 'D',
                                 p_message_name => lv_message_name,
                                 p_message_rule_text => NULL,
                                 p_message_tokens => NULL,
                                 p_message_action => NULL,
                                 p_destination => NULL,
                                 p_parameters => NULL,
                                 p_step_type => 'UNIT');

                    end if;
                lv_message_name := null;

            -- Validate against person, course and course group exclusions.

            IF NOT crse_hold_fail then
             IF NOT IGS_EN_VAL_ENCMB.enrp_val_excld_crs (
                                                        p_person_id,
                                                        p_course_cd,
                                                        v_census_dt_rec.alias_val,
                                                        lv_message_name)  THEN

                                crse_hold_fail := TRUE;
                                 igs_en_drop_units_api.create_ss_warning(
                                 p_person_id => p_person_id,
                                 p_course_cd => p_course_cd,
                                 p_term_cal_type => p_load_cal_type,
                                 p_term_ci_sequence_number =>  p_load_sequence_number,
                                 p_uoo_id => null,
                                 p_message_for => l_message_for,
                                 p_message_icon=> 'D',
                                 p_message_name => lv_message_name,
                                 p_message_rule_text => NULL,
                                 p_message_tokens => NULL,
                                 p_message_action => NULL,
                                 p_destination => NULL,
                                 p_parameters => NULL,
                                 p_step_type => 'PROGRAM');

              end if;
             END IF;

        END IF;
END LOOP;

                 l_message_tokens := NULL;
                 IGS_EN_SU_ATTEMPT_PKG.INSERT_ROW (
                                     X_ROWID                        =>     l_rowid                                    ,
                                     X_PERSON_ID                    =>     p_person_id                                ,
                                     X_COURSE_CD                    =>     p_course_cd                                ,
                                     X_UNIT_CD                      =>     l_unit_rec.unit_cd                         ,
                                     X_CAL_TYPE                     =>     l_unit_rec.cal_type                        ,
                                     X_CI_SEQUENCE_NUMBER           =>     l_unit_rec.ci_sequence_number              ,
                                     X_VERSION_NUMBER               =>     l_unit_rec.version_number                  ,
                                     X_LOCATION_CD                  =>     l_unit_rec.location_cd                     ,
                                     X_UNIT_CLASS                   =>     l_unit_rec.unit_class                      ,
                                     X_CI_START_DT                  =>     l_unit_rec.start_dt                        ,
                                     X_CI_END_DT                    =>     l_unit_rec.end_dt                          ,
                                     X_UOO_ID                       =>     p_unit_params(i).uoo_id                    ,
                                     X_ENROLLED_DT                  =>     NULL                                       ,
                                     X_UNIT_ATTEMPT_STATUS          =>     'PLANNED'                                  ,
                                     X_ADMINISTRATIVE_UNIT_STATUS   =>     NULL                                       ,
                                     X_DISCONTINUED_DT              =>     NULL                                       ,
                                     X_RULE_WAIVED_DT               =>     NULL                                       ,
                                     X_RULE_WAIVED_PERSON_ID        =>     NULL                                       ,
                                     X_NO_ASSESSMENT_IND            =>     NVL(p_unit_params(i).ass_ind,'N')          , -- value passed to indicate that audit is requeted or not
                                     X_SUP_UNIT_CD                  =>     NULL                                       ,
                                     X_SUP_VERSION_NUMBER           =>     NULL                                       ,
                                     X_EXAM_LOCATION_CD             =>     NULL                                       ,
                                     X_ALTERNATIVE_TITLE            =>     NULL                                       ,
                                     X_OVERRIDE_ENROLLED_CP         =>     p_unit_params(i).override_enrolled_cp      ,
                                     X_OVERRIDE_EFTSU               =>     NULL                                       ,
                                     X_OVERRIDE_ACHIEVABLE_CP       =>     NULL                                       , -- selective values passed based on whether audit is requeted or not
                                     X_OVERRIDE_OUTCOME_DUE_DT      =>     NULL                                       ,
                                     X_OVERRIDE_CREDIT_REASON       =>     NULL                                       ,
                                     X_ADMINISTRATIVE_PRIORITY      =>     NULL                                       ,
                                     X_WAITLIST_DT                  =>     NULL                                       ,
                                     X_DCNT_REASON_CD               =>     NULL                                       ,
                                     X_MODE                         =>     'R'                                        ,
                                     X_ORG_ID                       =>     NULL                                       ,
                                     X_GS_VERSION_NUMBER            =>     p_unit_params(i).gs_version_number         ,
                                     X_ENR_METHOD_TYPE              =>     p_enr_method_type                          ,
                                     X_FAILED_UNIT_RULE             =>     NULL                                       ,
                                     X_CART                         =>     NULL                                       ,
                                     X_RSV_SEAT_EXT_ID              =>     NULL                                       ,
                                     X_ORG_UNIT_CD                  =>     NULL                                       ,
                                     -- session_id added by Nishikant 28JAN2002 - Enh Bug#2172380.
                                     X_SESSION_ID                   =>     igs_en_add_units_api.g_ss_session_id                      ,
                                     -- Added the column grading schema as a part pf the bug 2037897. - aiyer
                                     X_GRADING_SCHEMA_CODE          =>     p_unit_params(i).grading_schema_cd         ,
                                     --Added the column Deg_Aud_Detail_Id as part of Degree Audit Interface build. (Bug# 2033208) - pradhakr
                                     X_DEG_AUD_DETAIL_ID            => NULL,
                                     X_STUDENT_CAREER_TRANSCRIPT    => NULL,
                                     X_STUDENT_CAREER_STATISTICS    => NULL,
                                     X_ATTRIBUTE_CATEGORY           => NULL,
                                     X_ATTRIBUTE1                   => NULL,
                                     X_ATTRIBUTE2                   => NULL,
                                     X_ATTRIBUTE3                   => NULL,
                                     X_ATTRIBUTE4                   => NULL,
                                     X_ATTRIBUTE5                   => NULL,
                                     X_ATTRIBUTE6                   => NULL,
                                     X_ATTRIBUTE7                   => NULL,
                                     X_ATTRIBUTE8                   => NULL,
                                     X_ATTRIBUTE9                   => NULL,
                                     X_ATTRIBUTE10                  => NULL,
                                     X_ATTRIBUTE11                  => NULL,
                                     X_ATTRIBUTE12                  => NULL,
                                     X_ATTRIBUTE13                  => NULL,
                                     X_ATTRIBUTE14                  => NULL,
                                     X_ATTRIBUTE15                  => NULL,
                                     X_ATTRIBUTE16                  => NULL,
                                     X_ATTRIBUTE17                  => NULL,
                                     X_ATTRIBUTE18                  => NULL,
                                     X_ATTRIBUTE19                  => NULL,
                                     X_ATTRIBUTE20                  => NULL,
                                     X_WAITLIST_MANUAL_IND          => NULL, --Added by mesriniv for Bug 2554109 Mini Waitlist Build.,
                                     X_WLST_PRIORITY_WEIGHT_NUM     => NULL,
                                     X_WLST_PREFERENCE_WEIGHT_NUM   => NULL,
                                     X_CORE_INDICATOR_CODE          => l_core_indicator_code,
                                     X_UPD_AUDIT_FLAG               => 'N',
                                     X_SS_SOURCE_IND	            => 'P'

                                );


             END IF; -- IF waitlist_required

           END IF; -- IF permission_required

        EXCEPTION

          WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN

            --  get message from stack and insert into warn record.
            IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
            FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);

            IF l_message_name IS NOT NULL THEN

                 -- add to warnings table as error i.e warn_icon is 'D'

                 IF l_message_name IN ('IGS_GE_RECORD_ALREADY_EXISTS','IGS_GE_MULTI_ORG_DUP_REC') THEN
                      l_message_name := 'IGS_EN_SUA_EXISTS';
                      l_message_tokens := 'UNIT_CD'||':'||l_unit_rec.unit_cd||'/'||l_unit_rec.unit_class||';';
                 END IF;


                 igs_en_drop_units_api.create_ss_warning(
                                 p_person_id => p_person_id,
                                 p_course_cd => p_course_cd,
                                 p_term_cal_type => p_load_cal_type,
                                 p_term_ci_sequence_number =>  p_load_sequence_number,
                                 p_uoo_id => p_unit_params(i).uoo_id,
                                 p_message_for => l_unit_rec.unit_cd||'/'||l_unit_rec.unit_class,
                                 p_message_icon=> 'D',
                                 p_message_name => l_message_name,
                                 p_message_rule_text => NULL,
                                 p_message_tokens => l_message_tokens,
                                 p_message_action => NULL,
                                 p_destination => NULL,
                                 p_parameters => NULL,
                                 p_step_type => 'UNIT');

              END IF;

        WHEN OTHERS THEN

            RAISE;

      END; -- end of BEGIN block

    END LOOP;



    -- In addition to units being added, preenrolled units need to be evaluated.
    -- These include units that are added by admin through preenrollment job or through admin self-service
    -- so add these unit details into l_combined_unit_params

    FOR preenr_units_rec in c_get_preenr_units loop

      l_combined_unit_params(v_comb_index).uoo_id := preenr_units_rec.uoo_id;
      l_combined_unit_params(v_comb_index).ass_ind := preenr_units_rec.no_assessment_ind;
      v_comb_index := v_comb_index+1;

    END LOOP;

    --before doing step validations for all the units, perform permission validations
    --for the above preenrolled units.
    l_return_status := NULL;

    get_perm_wlst_setup(p_person_id,
                      p_course_cd,
                      p_load_cal_type,
                      p_load_sequence_number,
                      l_combined_unit_params,
                      p_message,
                      l_return_status,
                      'N');  --do not chek waitlist setup
     IF l_return_status  = 'FALSE' THEN
        p_return_status := 'FALSE';
        RETURN;
    END IF;
FOR i in 1 .. l_combined_unit_params.COUNT loop

   l_message_name := NULL;
          IF permission_required(   p_person_id,
                                    p_course_cd,
                                    p_load_cal_type,
                                    p_load_sequence_number,
                                    l_combined_unit_params(i).uoo_id,
                                    l_combined_unit_params(i).spl_perm_step ,
                                    l_combined_unit_params(i).aud_perm_step ,
                                    l_combined_unit_params(i).ass_ind,
                                    l_combined_unit_params(i).override_enrolled_cp,
                                    l_combined_unit_params(i).grading_schema_cd,
                                    l_combined_unit_params(i).gs_version_number,
                                    l_message_name,
                                    p_calling_obj) THEN

              IF l_message_name IS NOT NULL THEN
              --implies some unexpected error , set return status and message name and stop processing.

                p_return_status := 'FALSE';
                p_message := l_message_name;
                RETURN;
               END IF;
               END IF;
  END LOOP;


    -- fetch the passed unit details into l_combined_unit_params


    FOR i IN 1.. p_unit_params.COUNT LOOP

      l_combined_unit_params(v_comb_index) := p_unit_params(i);
       v_comb_index := v_comb_index+1;

    END LOOP;

    l_max_cp_fail := FALSE;
    l_min_cp_fail := FALSE;

    l_message_name := NULL;
    l_deny_warn_max_cp := NULL;
    l_deny_warn_max_cp :=   igs_ss_enr_details.get_notification(
                                   p_person_type         => g_person_type,
                                   p_enrollment_category => p_enrollment_category,
                                   p_comm_type           => p_comm_type,
                                   p_enr_method_type     => p_enr_method_type,
                                   p_step_group_type     => 'PROGRAM',
                                   p_step_type           => 'FMAX_CRDT' ,
                                   p_person_id           => p_person_id,
                                   p_message             => l_message_name
                                 );
    IF l_message_name IS NOT NULL THEN
       p_return_status :=  'FALSE';
       p_message  := l_message_name;
       RETURN;
    END IF;

    l_deny_warn_min_cp := NULL;
    l_deny_warn_min_cp := igs_ss_enr_details.get_notification(
                         p_person_type         => g_person_type,
                         p_enrollment_category => p_enrollment_category,
                         p_comm_type           => p_comm_type,
                         p_enr_method_type     => p_enr_method_type,
                         p_step_group_type     => 'PROGRAM',
                         p_step_type           => 'FMIN_CRDT' ,
                         p_person_id           => p_person_id,
                         p_message             => l_message_name
                       );
    IF l_message_name IS NOT NULL THEN
       p_return_status :=  'FALSE';
       p_message  := l_message_name;
       RETURN;
    END IF;

    -- loop to make unit,program steps and encumbrance validations
    FOR i IN 1.. l_combined_unit_params.COUNT LOOP

      BEGIN
                l_deny_warn := NULL;
                l_message_name := NULL;
                IF NOT IGS_EN_ELGBL_UNIT.eval_unit_steps(
                                                p_person_id => p_person_id,
                                                p_person_type => g_person_type,
                                                p_load_cal_type => p_load_cal_type,
                                                p_load_sequence_number => p_load_sequence_number,
                                                p_uoo_id => l_combined_unit_params(i).uoo_id,
                                                p_course_cd => p_course_cd,
                                                p_course_version => p_course_version,
                                                p_enrollment_category => p_enrollment_category,
                                                p_enr_method_type => p_enr_method_type,
                                                p_comm_type => p_comm_type,
                                                p_message => l_message_name, -- out
                                                p_deny_warn => l_deny_warn,  -- out
                                                p_calling_obj => p_calling_obj) THEN
                        IF l_message_name IS NOT NULL THEN
                            p_message := l_message_name;
                            p_return_status := 'FALSE';
                            RETURN;
                        END IF;
                 END IF; -- IF NOT IGS_EN_ELGBL_UNIT.eval_unit_steps

                IF NOT l_max_cp_fail THEN

                        IF l_deny_warn_max_cp IS NOT NULL THEN
                              -- Call igs_en_elgbl_program.eval_max_cp before enrolling the program attempt
                                    IF NOT igs_en_elgbl_program.eval_max_cp(
                                                     p_person_id => p_person_id,
                                                     p_load_calendar_type => p_load_cal_type,
                                                     p_load_cal_sequence_number => p_load_sequence_number,
                                                     p_uoo_id => l_combined_unit_params(i).uoo_id,
                                                     p_program_cd => p_course_cd,
                                                     p_program_version => p_course_version,
                                                     p_message => l_message_name,
                                                     p_deny_warn => l_deny_warn_max_cp,
                                                     p_upd_cp => NULL,
                                                     p_calling_obj => p_calling_obj) THEN
                                        l_max_cp_fail := TRUE;
                                        IF l_message_name IS NOT NULL THEN
                                        p_message := l_message_name;
                                        p_return_status := 'FALSE';
                                        RETURN;
                                        END IF;

                                    END IF; -- end of eval_max_cp

                        END IF; -- IF l_deny_warn IS NOT NULL THEN

               END IF;-- IF NOT l_max_cp_fail THEN

                        OPEN c_get_sua_dtls(l_combined_unit_params(i).uoo_id);
                        FETCH c_get_sua_dtls INTO l_sua_rec;

                        IF c_get_sua_dtls%FOUND THEN
                         CLOSE c_get_sua_dtls;

              -- enroll the unit attempts
               IGS_EN_SU_ATTEMPT_PKG.UPDATE_ROW(
                        X_ROWID                        =>     l_sua_rec.row_id                         ,
                        X_PERSON_ID                    =>     l_sua_rec.person_id                      ,
                        X_COURSE_CD                    =>     l_sua_rec.course_cd                      ,
                        X_UNIT_CD                      =>     l_sua_rec.unit_cd                        ,
                        X_CAL_TYPE                     =>     l_sua_rec.cal_type                       ,
                        X_CI_SEQUENCE_NUMBER           =>     l_sua_rec.ci_sequence_number             ,
                        X_VERSION_NUMBER               =>     l_sua_rec.version_number                 ,
                        X_LOCATION_CD                  =>     l_sua_rec.location_cd                    ,
                        X_UNIT_CLASS                   =>     l_sua_rec.unit_class                     ,
                        X_CI_START_DT                  =>     l_sua_rec.ci_start_dt                    ,
                        X_CI_END_DT                    =>     l_sua_rec.ci_end_dt                      ,
                        X_UOO_ID                       =>     l_sua_rec.uoo_id                         ,
                        X_ENROLLED_DT                  =>     SYSDATE                                  ,
                        X_UNIT_ATTEMPT_STATUS          =>     'ENROLLED'                               ,
                        X_ADMINISTRATIVE_UNIT_STATUS   =>     l_sua_rec.administrative_unit_status     ,
                        X_DISCONTINUED_DT              =>     l_sua_rec.discontinued_dt                ,
                        X_RULE_WAIVED_DT               =>     l_sua_rec.rule_waived_dt                 ,
                        X_RULE_WAIVED_PERSON_ID        =>     l_sua_rec.rule_waived_person_id          ,
                        X_NO_ASSESSMENT_IND            =>     l_sua_rec.no_assessment_ind              ,
                        X_SUP_UNIT_CD                  =>     l_sua_rec.sup_unit_cd                    ,
                        X_SUP_VERSION_NUMBER           =>     l_sua_rec.sup_version_number             ,
                        X_EXAM_LOCATION_CD             =>     l_sua_rec.exam_location_cd               ,
                        X_ALTERNATIVE_TITLE            =>     l_sua_rec.alternative_title              ,
                        X_OVERRIDE_ENROLLED_CP         =>     l_sua_rec.override_enrolled_cp           ,
                        X_OVERRIDE_EFTSU               =>     l_sua_rec.override_eftsu                 ,
                        X_OVERRIDE_ACHIEVABLE_CP       =>     l_sua_rec.override_achievable_cp         ,
                        X_OVERRIDE_OUTCOME_DUE_DT      =>     l_sua_rec.override_outcome_due_dt        ,
                        X_OVERRIDE_CREDIT_REASON       =>     l_sua_rec.override_credit_reason         ,
                        X_ADMINISTRATIVE_PRIORITY      =>     l_sua_rec.administrative_priority        ,
                        X_WAITLIST_DT                  =>     l_sua_rec.waitlist_dt                    ,
                        X_DCNT_REASON_CD               =>     l_sua_rec.dcnt_reason_cd                 ,
                        X_MODE                         =>     'R'                                      ,
                        X_GS_VERSION_NUMBER            =>     l_sua_rec.gs_version_number              ,
                        X_ENR_METHOD_TYPE              =>     l_sua_rec.enr_method_type                ,
                        X_FAILED_UNIT_RULE             =>     l_sua_rec.failed_unit_rule               ,
                        X_CART                         =>     'N'                                      ,
                        X_RSV_SEAT_EXT_ID              =>     l_sua_rec.rsv_seat_ext_id                ,
                        X_ORG_UNIT_CD                  =>     l_sua_rec.org_unit_cd                    ,
                        X_SESSION_ID                   =>     l_sua_rec.session_id                     ,
                        X_GRADING_SCHEMA_CODE          =>     l_sua_rec.grading_schema_code            ,
                        X_DEG_AUD_DETAIL_ID            =>     l_sua_rec.deg_aud_detail_id    ,
                        X_STUDENT_CAREER_TRANSCRIPT    =>     l_sua_rec.student_career_transcript,
                        X_STUDENT_CAREER_STATISTICS    =>     l_sua_rec.student_career_statistics,
                        x_waitlist_manual_ind          =>     l_sua_rec.waitlist_manual_ind ,
                        X_ATTRIBUTE_CATEGORY           =>     l_sua_rec.attribute_category,
                        X_ATTRIBUTE1                   =>     l_sua_rec.attribute1,
                        X_ATTRIBUTE2                   =>     l_sua_rec.attribute2,
                        X_ATTRIBUTE3                   =>     l_sua_rec.attribute3,
                        X_ATTRIBUTE4                   =>     l_sua_rec.attribute4,
                        X_ATTRIBUTE5                   =>     l_sua_rec.attribute5,
                        X_ATTRIBUTE6                   =>     l_sua_rec.attribute6,
                        X_ATTRIBUTE7                   =>     l_sua_rec.attribute7,
                        X_ATTRIBUTE8                   =>     l_sua_rec.attribute8,
                        X_ATTRIBUTE9                   =>     l_sua_rec.attribute9,
                        X_ATTRIBUTE10                  =>     l_sua_rec.attribute10,
                        X_ATTRIBUTE11                  =>     l_sua_rec.attribute11,
                        X_ATTRIBUTE12                  =>     l_sua_rec.attribute12,
                        X_ATTRIBUTE13                  =>     l_sua_rec.attribute13,
                        X_ATTRIBUTE14                  =>     l_sua_rec.attribute14,
                        X_ATTRIBUTE15                  =>     l_sua_rec.attribute15,
                        X_ATTRIBUTE16                  =>     l_sua_rec.attribute16,
                        X_ATTRIBUTE17                  =>     l_sua_rec.attribute17,
                        X_ATTRIBUTE18                  =>     l_sua_rec.attribute18,
                        X_ATTRIBUTE19                  =>     l_sua_rec.attribute19,
                        X_ATTRIBUTE20                  =>     l_sua_rec.attribute20,
                        -- WLST_PRIORITY_WEIGHT_NUM and WLST_PREFERENCE_WEIGHT_NUM added by ptandon 1-SEP-2003. Enh Bug# 3052426
                        X_WLST_PRIORITY_WEIGHT_NUM     =>     l_sua_rec.wlst_priority_weight_num,
                        X_WLST_PREFERENCE_WEIGHT_NUM   =>     l_sua_rec.wlst_preference_weight_num,
                        -- CORE_INDICATOR_CODE added by ptandon 30-SEP-2003. Enh Bug# 3052432
                        X_CORE_INDICATOR_CODE          =>     l_sua_rec.core_indicator_code,
                        X_UPD_AUDIT_FLAG               =>     l_sua_rec.UPD_AUDIT_FLAG ,
                        X_SS_SOURCE_IND                =>     l_sua_rec.SS_SOURCE_IND
                      );


                         -- Minimum CP validations
                         -- Check if min_cp has not failed, then call procedure to evaluate min cp.
                    IF NOT l_min_cp_fail THEN

                        IF l_deny_warn_min_cp IS NOT NULL THEN

                              l_credit_points := 0;
                              IF NOT igs_en_elgbl_program.eval_min_cp(
                                                   p_person_id  => p_person_id,
                                                   p_load_calendar_type => p_load_cal_type,
                                                   p_load_cal_sequence_number => p_load_sequence_number,
                                                   p_uoo_id => l_combined_unit_params(i).uoo_id,
                                                   p_program_cd => p_course_cd,
                                                   p_program_version => p_course_version,
                                                   p_message => l_message_name,
                                                   p_deny_warn => l_deny_warn_min_cp,
                                                   p_credit_points => l_credit_points,
                                                   p_enrollment_category => p_enrollment_category,
                                                   p_comm_type => p_comm_type,
                                                   p_method_type => p_enr_method_type,
                                                   p_min_credit_point => l_min_credit_point,
                                                   p_calling_obj => p_calling_obj) THEN

                                        l_min_cp_fail := TRUE;
                                        IF l_message_name IS NOT NULL THEN
                                        p_message := l_message_name;
                                          p_return_status := 'FALSE';
                                          RETURN;
                                        END IF;

                               END IF; -- IF NOT igs_en_elgbl_program.eval_min_cp

                          END IF; -- IF l_deny_warn IS NOT NULL THEN

                      END IF; -- IF NOT l_min_cp_fail THEN
                ELSE
                CLOSE c_get_sua_dtls;
                END IF; -- IF c_get_sua_dtls%FOUND
EXCEPTION

          WHEN NO_AUSL_RECORD_FOUND THEN
            IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop := NULL;
            p_message := 'IGS_SS_CANTDET_ADM_UNT_STATUS';
            p_return_status := 'FALSE';
            RETURN;

          WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN

              --  get message from stack and insert into warn record.
              IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
              FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);

              IF l_message_name IS NOT NULL THEN

                   -- add to warnings table as error i.e warn_icon is 'D'
                   l_unit_sec := get_unit_sec(l_combined_unit_params(i).uoo_id);

                   igs_en_drop_units_api.create_ss_warning(
                                   p_person_id => p_person_id,
                                   p_course_cd => p_course_cd,
                                   p_term_cal_type => p_load_cal_type,
                                   p_term_ci_sequence_number =>  p_load_sequence_number,
                                   p_uoo_id => l_combined_unit_params(i).uoo_id,
                                   p_message_for => l_unit_sec,
                                   p_message_icon=> 'D',
                                   p_message_name => l_message_name,
                                   p_message_rule_text => NULL,
                                   p_message_tokens => NULL,
                                   p_message_action => NULL,
                                   p_destination => NULL,
                                   p_parameters => NULL,
                                   p_step_type => 'UNIT');

                END IF;

          WHEN OTHERS THEN
              RAISE;

        END;

     END LOOP;
FOR i IN 1.. l_combined_unit_params.COUNT LOOP

 BEGIN
            -- Evaluate  program steps
            l_deny_warn := NULL;

            OPEN c_get_sua_dtls(l_combined_unit_params(i).uoo_id);
                        FETCH c_get_sua_dtls INTO l_sua_rec;
                        IF c_get_sua_dtls%FOUND THEN
                         CLOSE c_get_sua_dtls;


                                IF NOT igs_en_elgbl_program.eval_program_steps(
                                                       p_person_id => p_person_id,
                                                       p_person_type => g_person_type,
                                                       p_load_calendar_type => p_load_cal_type,
                                                       p_load_cal_sequence_number  => p_load_sequence_number,
                                                       p_uoo_id => l_combined_unit_params(i).uoo_id,
                                                       p_program_cd => p_course_cd,
                                                       p_program_version => p_course_version,
                                                       p_enrollment_category => p_enrollment_category,
                                                       p_comm_type => p_comm_type,
                                                       p_method_type => p_enr_method_type,
                                                       p_message  => l_message_name,
                                                       p_deny_warn => l_deny_warn,
                                                       p_calling_obj => p_calling_obj) THEN
                                        IF l_message_name IS NOT NULL THEN
                                            p_message := l_message_name;
                                            p_return_status := 'FALSE';
                                            RETURN;
                                         END IF;
                                END IF;

                         ELSE

                         CLOSE c_get_sua_dtls;
                        END IF; -- IF c_get_sua_dtls%FOUND

        EXCEPTION

          WHEN NO_AUSL_RECORD_FOUND THEN
            IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop  := NULL;
            p_message := 'IGS_SS_CANTDET_ADM_UNT_STATUS';
            p_return_status := 'FALSE';
            RETURN;

          WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN

              --  get message from stack and insert into warn record.
              IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
              FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);

              IF l_message_name IS NOT NULL THEN

                   -- add to warnings table as error i.e warn_icon is 'D'
                   l_unit_sec := get_unit_sec(l_combined_unit_params(i).uoo_id);

                   igs_en_drop_units_api.create_ss_warning(
                                   p_person_id => p_person_id,
                                   p_course_cd => p_course_cd,
                                   p_term_cal_type => p_load_cal_type,
                                   p_term_ci_sequence_number =>  p_load_sequence_number,
                                   p_uoo_id => l_combined_unit_params(i).uoo_id,
                                   p_message_for => l_unit_sec,
                                   p_message_icon=> 'D',
                                   p_message_name => l_message_name,
                                   p_message_rule_text => NULL,
                                   p_message_tokens => NULL,
                                   p_message_action => NULL,
                                   p_destination => NULL,
                                   p_parameters => NULL,
                                   p_step_type => 'UNIT');

                END IF;

          WHEN OTHERS THEN
              RAISE;

        END;

     END LOOP;

     l_return_status := NULL;
     l_message_name := NULL;
    -- The call to encumbrance check procedure does not require a unit code, hence it can be evaluated outside the loop.
     validate_enr_encmb( p_person_id,
                         p_course_cd,
                         p_load_cal_type,
                         p_load_sequence_number,
                         l_return_status,
                         l_message_name
                         );
     IF l_return_status IS NOT NULL AND l_message_name IS NOT NULL THEN
        p_return_status := 'FALSE';
        p_message := l_message_name;
        RETURN;
     END IF;

EXCEPTION
     WHEN OTHERS THEN
          IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop  := NULL;
          IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
            FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.create_planned_sua :',SQLERRM);
          END IF;
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.create_planned_sua');
          IGS_GE_MSG_STACK.ADD;
          RAISE;

END create_planned_sua;


PROCEDURE create_unconfirm_sua(
                      p_person_id IN NUMBER,
                      p_course_cd IN VARCHAR2,
                      p_course_version IN NUMBER,
                      p_load_cal_type IN VARCHAR2,
                      p_load_sequence_number IN NUMBER,
                      p_unit_params IN OUT NOCOPY t_params_table,
                      p_selected_units IN VARCHAR2,
                      p_enrollment_category IN VARCHAR2,
                      p_enr_method_type IN VARCHAR2,
                      p_comm_type IN VARCHAR2,
                      p_succ_suas OUT NOCOPY VARCHAR2,
                      p_message OUT NOCOPY VARCHAR2,
                      p_return_status OUT NOCOPY VARCHAR2,
                      p_calling_obj IN VARCHAR2) AS
-------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  --Purpose :
  -- This procedure creates unconfirm unit attempts for the passed in list of uoo_ids.
  -- The API tries to reserve seats in all cases except when the special/audit persmission step
  -- is deny or when no seats are available.
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

-- cursor to check wheter a unit attempt exists
CURSOR chk_sua_exists (cp_uoo_id igs_en_su_attempt.uoo_id%TYPE)IS
SELECT 'X'
FROM igs_en_su_attempt
WHERE person_id = p_person_id
AND course_cd = p_course_cd
AND uoo_id = cp_uoo_id
AND unit_attempt_status <> 'DROPPED';


l_out_uoo_ids         VARCHAR2(1000);
l_sua_exists          VARCHAR2(1);
l_enc_message_name    VARCHAR2(2000);
l_message_name        VARCHAR2(4000);
l_app_short_name      VARCHAR2(100);
l_msg_index           NUMBER;
l_unit_sec            VARCHAR2(100);
l_return_status       VARCHAR2(10);
l_deny_warn           VARCHAR2(10);
l_create_sub          BOOLEAN;
l_message_action      VARCHAR2(100);
l_create_wlst         VARCHAR2(1);

BEGIN


 FOR i IN 1.. p_unit_params.COUNT LOOP

  BEGIN
       -- check if the creation of this subordinate unit attempt is valid
       -- This cannot be created if system added this subordinate and
       -- its superior didnot take a seat
      l_create_sub := FALSE;
      l_create_sub := chk_sua_creation_is_valid(p_person_id,
                                                p_course_cd,
                                                p_unit_params(i).uoo_id,
                                                p_load_cal_type,
                                                p_load_sequence_number,
                                                p_unit_params,
                                                p_selected_units
                                                );

      -- if the unit creation is valid
      IF l_create_sub THEN

          --  Check if unit requires special/audit permission, if required the procedure creates the appropriate warning record and returns true.
          -- If the procedure has returned false, it implies that no permission is required and the API can continue with the creation of unit attempts.
          -- The out paramter l_message_name has a value only in case of errors.  Hence check for the same and exit out.
            l_message_name := NULL;


            IF permission_required(   p_person_id,
                                      p_course_cd,
                                      p_load_cal_type,
                                      p_load_sequence_number,
                                      p_unit_params(i).uoo_id,
                                      p_unit_params(i).spl_perm_step ,
                                      p_unit_params(i).aud_perm_step ,
                                      p_unit_params(i).ass_ind,
                                      p_unit_params(i).override_enrolled_cp,
                                      p_unit_params(i).grading_schema_cd,
                                      p_unit_params(i).gs_version_number,
                                      l_message_name,
                                      p_calling_obj) THEN

                IF l_message_name IS NOT NULL THEN
                --implies some unexpected error , set return status and message name and stop processing.

                  p_return_status := 'FALSE';
                  p_message := l_message_name;
                  RETURN;

                END IF; -- IF l_message_name IS NOT NULL

           ELSE
                l_create_wlst := 'N';
                IF waitlist_required(
                              p_person_id ,
                              p_course_cd ,
                              p_unit_params(i).uoo_id,
                              p_unit_params(i).wlst_step,
                              p_load_cal_type,
                              p_load_sequence_number,
                              p_unit_params(i).ass_ind,
                              p_enr_method_type,
                              p_unit_params(i).override_enrolled_cp,
                              NULL,
                              p_unit_params(i).grading_schema_cd,
                              p_unit_params(i).gs_version_number,
                              l_create_wlst,
                              p_calling_obj ,
                              l_message_name) THEN

                     IF l_message_name IS NOT NULL THEN
                    --implies some unexpected error , set return status and message name and stop processing.

                       p_return_status := 'FALSE';
                       p_message := l_message_name;
                       RETURN;

                      END IF; -- IF l_message_name IS NOT NULL

                        -- set this flag so that this unit can be waitlisted
                        IF p_calling_obj = 'SUBMITPLAN' THEN
                          p_unit_params(i).create_wlst := l_create_wlst;
                        END IF;
                  ELSE

                    l_return_status := NULL;
                    IF p_calling_obj  = 'SUBMITPLAN' THEN
                    -- call procedure, since creation of unconfirm unit attempts from PLANSUBMIT is not an autonomous transaction.
                      create_sua_from_plan(p_person_id,
                                           p_course_cd,
                                           p_unit_params(i).uoo_id,
                                           p_load_cal_type,
                                           p_load_sequence_number,
                                           p_unit_params(i).ass_ind,
                                           'N',               --- pass waitlsit ind as 'N'
                                           p_enr_method_type,
                                           p_unit_params(i).override_enrolled_cp,
                                           p_unit_params(i).grading_schema_cd,
                                           p_unit_params(i).gs_version_number,
                                           p_calling_obj,
                                           p_message,
                                           l_return_status) ;
                    ELSE

                      IF p_calling_obj = 'SWAP' THEN

                         IGS_EN_VAL_SUA.validate_mus(p_person_id             => p_person_id,
                                                     p_course_cd             => p_course_cd,
                                                     p_uoo_id                => p_unit_params(i).uoo_id
                                                     );

                      END IF;

                      create_sua(p_person_id,
                                 p_course_cd,
                                 p_unit_params(i).uoo_id,
                                 p_load_cal_type,
                                 p_load_sequence_number,
                                 p_unit_params(i).ass_ind,
                                 p_enr_method_type,
                                 p_unit_params(i).override_enrolled_cp,
                                 p_unit_params(i).grading_schema_cd,
                                 p_unit_params(i).gs_version_number,
                                 p_calling_obj,
                                 l_return_status,
                                 p_message) ;


                  END IF;
                --  Check for any messages
                  IF l_return_status = 'FALSE' AND p_message IS NOT NULL THEN
                    p_return_status := 'FALSE';
                    RETURN;
                  END IF;

               -- If unit is sucessfully created add to the list of l_out_uoo_ids.
                 IF l_return_status IS NULL THEN
                     IF l_out_uoo_ids IS NULL THEN
                        l_out_uoo_ids := p_unit_params(i).uoo_id;
                     ELSE
                        l_out_uoo_ids :=l_out_uoo_ids||','|| p_unit_params(i).uoo_id;
                     END IF;
                 END IF;

               END IF;-- IF NOT waitlist_required(

          END IF; -- IF NOT permission_required

      END IF; -- IF l_sup_uoo_id IS NULL OR l_create_sub THEN

  EXCEPTION

    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN

        IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
        FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);

        IF l_message_name IS NOT NULL THEN

            l_unit_sec := get_unit_sec(p_unit_params(i).uoo_id);
              ---- Add to warnings table as error
            igs_en_drop_units_api.create_ss_warning(
                               p_person_id => p_person_id,
                               p_course_cd => p_course_cd,
                               p_term_cal_type => p_load_cal_type,
                               p_term_ci_sequence_number =>  p_load_sequence_number,
                               p_uoo_id => p_unit_params(i).uoo_id,
                               p_message_for => l_unit_sec,
                               p_message_icon=> 'D',
                               p_message_name => l_message_name,
                               p_message_rule_text => NULL,
                               p_message_tokens => NULL,
                               p_message_action => NULL,
                               p_destination => NULL,
                               p_parameters => NULL,
                               p_step_type => 'UNIT');

        END IF;

    WHEN OTHERS THEN
       RAISE;
  END;
END LOOP;
p_succ_suas :=  l_out_uoo_ids;

EXCEPTION
   WHEN OTHERS THEN

    IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
      FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.create_unconfirm_sua :',SQLERRM);
    END IF;
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.create_unconfirm_sua');
    IGS_GE_MSG_STACK.ADD;
    RAISE;

END create_unconfirm_sua;

PROCEDURE create_enroll_sua( p_person_Id IN NUMBER,
                             p_course_cd IN VARCHAR2,
                             p_course_version IN VARCHAR2,
                             p_uoo_ids  IN VARCHAR2,
                             p_load_cal_type IN VARCHAR2,
                             p_load_sequence_number IN NUMBER,
                             p_enrollment_category IN VARCHAR2,
                             p_enr_meth_type IN VARCHAR2,
                             p_comm_type IN VARCHAR2,
                             p_message OUT NOCOPY  VARCHAR2,
                             p_return_status OUT NOCOPY VARCHAR2,
                             p_calling_obj  IN VARCHAR2) AS
-------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  --Purpose : This procedure validates the necessary steps and enrolls the unit attempts for the passed in list of uoo_ids.
  --Change History:
  --Who         When            What
  --ckasu       14-FEB-2006     Modified as a part of bug#5036954 inorder to resolve string literal issue.
  --bdeviset    02-DEC-2005     Modified apps exception block after enroll_cart_unit procedure
  --                            to get the tokens of message IGS_EN_INVALID_SUP_SUB for bug# 4706395

  -------------------------------------------------------------------------------------------

  -- cursor to fetch the swap units
  CURSOR cur_swap_units IS
  SELECT DISTINCT sua.uoo_id, sua.sup_unit_cd, sua.no_assessment_ind
  FROM igs_en_su_attempt sua, igs_ca_teach_to_load_v lod
  WHERE sua.person_id = p_person_Id
  AND sua.course_cd = p_course_cd
  AND sua.unit_attempt_status = 'UNCONFIRM'
  AND lod.teach_cal_type = sua.cal_type
  AND lod.teach_ci_sequence_number = sua.ci_sequence_number
  AND lod.load_cal_type = p_load_cal_type
  AND lod.load_ci_sequence_number = p_load_sequence_number
  AND sua.SS_SOURCE_IND = 'S'
  ORDER BY sua.sup_unit_cd DESC;

  -- cursor to get the cart units
  CURSOR cur_cart_units IS
  SELECT DISTINCT sua.uoo_id, sua.sup_unit_cd
  FROM igs_en_su_attempt sua, igs_ca_teach_to_load_v lod
  WHERE sua.person_id = p_person_Id
  AND sua.course_cd = p_course_cd
  AND sua.unit_attempt_status = 'UNCONFIRM'
  AND sua.SS_SOURCE_IND <> 'S'
  AND lod.teach_cal_type = sua.cal_type
  AND lod.teach_ci_sequence_number = sua.ci_sequence_number
  AND lod.load_cal_type = p_load_cal_type
  AND lod.load_ci_sequence_number = p_load_sequence_number
  ORDER BY sua.sup_unit_cd DESC;

  -- To get student unit attempt and unit code
  CURSOR chk_unconfirm_sua (cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
  SELECT unit_attempt_status,unit_cd,version_number
  FROM igs_en_su_attempt
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND uoo_id = cp_uoo_id;

  TYPE c_ref_cursor IS REF CURSOR;
  c_get_swap_units c_ref_cursor;

  NO_AUSL_RECORD_FOUND EXCEPTION;
  PRAGMA EXCEPTION_INIT(NO_AUSL_RECORD_FOUND , -20010);

  l_swap_unit_params          t_params_table;

  l_uoo_ids                       VARCHAR2(2000);
  l_uoo_id                        igs_en_su_attempt.uoo_id%TYPE;
  l_deny_warn_coreq               VARCHAR2(10);
  l_deny_warn_prereq              VARCHAR2(10);
  l_deny_warn_min_cp              VARCHAR2(10);
  l_message_icon                  VARCHAR2(30);
  l_sua_status                    igs_en_su_attempt.unit_attempt_status%TYPE;
  l_message_name                  VARCHAR2(4000);
  l_app_short_name                VARCHAR2(100);
  l_msg_index                     NUMBER;
  l_unit_sec                      VARCHAR2(100);
  l_enc_message_name              VARCHAR2(2000);
  l_succ_new_uoo_ids              VARCHAR2(1000);
  l_unit_ver                      igs_en_su_attempt.version_number%TYPE;
  l_unit_cd                       igs_en_su_attempt.unit_cd%TYPE;
  l_return_status                 VARCHAR2(30);
  l_deny_warn                     VARCHAR2(30);
  l_message_for                   VARCHAR2(100);

  -- min and max  cp  val status  variables
  l_max_cp_fail                   BOOLEAN;
  l_min_cp_fail                   BOOLEAN;
  l_new_uoo_ids                   VARCHAR2(4000);
  l_min_credit_point              NUMBER;
  l_credit_points                 NUMBER;
  v_swap_index                    BINARY_INTEGER := 1;

  l_token1                     VARCHAR2(1000);
  l_token2                     VARCHAR2(1000);
  l_token_set                  VARCHAR2(2100);

BEGIN



  l_uoo_ids := p_uoo_ids;
  l_new_uoo_ids  := NULL;

  -- if calling object submitswap  then fetch the swap units,
  -- i.e units in unconfirm status with ss_cart_ind set to 'S'.
    IF p_calling_obj IN ('SWAP', 'SUBMITSWAP') THEN
            --first do permission check of existing swap units

            FOR swap_records IN cur_swap_units LOOP
                IF  INSTR(','||p_uoo_ids||',',','||swap_records.uoo_id||',',1) = 0  THEN

                l_swap_unit_params(v_swap_index).uoo_id := swap_records.uoo_id;
                l_swap_unit_params(v_swap_index).ass_ind := swap_records.no_assessment_ind;
                  v_swap_index := v_swap_index+1;
              end if;
            end loop;

                --now check permission setup
                l_return_status := NULL;
                get_perm_wlst_setup(p_person_id,
                      p_course_cd,
                      p_load_cal_type,
                      p_load_sequence_number,
                      l_swap_unit_params,
                      p_message,
                      l_return_status,
                      'N');
                    IF l_return_status  = 'FALSE' THEN
                        p_return_status := 'FALSE';
                        RETURN;
                     END IF;
                FOR i in 1 .. l_swap_unit_params.COUNT loop

                    l_message_name := NULL;
                    IF permission_required(   p_person_id,
                                    p_course_cd,
                                    p_load_cal_type,
                                    p_load_sequence_number,
                                    l_swap_unit_params(i).uoo_id,
                                    l_swap_unit_params(i).spl_perm_step ,
                                    l_swap_unit_params(i).aud_perm_step ,
                                    l_swap_unit_params(i).ass_ind,
                                    l_swap_unit_params(i).override_enrolled_cp,
                                    l_swap_unit_params(i).grading_schema_cd,
                                    l_swap_unit_params(i).gs_version_number,
                                    l_message_name,
                                    p_calling_obj) THEN

                                IF l_message_name IS NOT NULL THEN
                            --implies some unexpected error , set return status and message name and
                            --stop processing.

                                p_return_status := 'FALSE';
                                p_message := l_message_name;
                                RETURN;
                                END IF;
                 END IF;
                END LOOP;


      FOR swap_records IN cur_swap_units LOOP

              IF NOT IGS_EN_ELGBL_UNIT.eval_unit_steps(
                                                  p_person_id => p_person_id,
                                                  p_person_type => g_person_type,
                                                  p_load_cal_type => p_load_cal_type,
                                                  p_load_sequence_number => p_load_sequence_number,
                                                  p_uoo_id => swap_records.uoo_id,
                                                  p_course_cd => p_course_cd,
                                                  p_course_version => p_course_version,
                                                  p_enrollment_category => p_enrollment_category,
                                                  p_enr_method_type => p_enr_meth_type,
                                                  p_comm_type => p_comm_type,
                                                  p_message => l_message_name, -- out
                                                  p_deny_warn => l_deny_warn,  -- out
                                                  p_calling_obj => p_calling_obj) THEN
                                       IF l_message_name IS NOT NULL THEN
                                          p_message := l_message_name;
                                          p_return_status := 'FALSE';
                                           RETURN;
                                       END IF;

              END IF;

             -- pickup the existing cart records, but not the newly created unconfirmed cart records
             IF l_new_uoo_ids IS NOT NULL THEN
                 l_new_uoo_ids := l_new_uoo_ids ||','||swap_records.uoo_id;
             ELSE
                 l_new_uoo_ids := swap_records.uoo_id;
             END IF;

      END LOOP;

  ELSIF  p_calling_obj IN ('SCHEDULE','ENROLPEND', 'CART','SUBMITCART','SUBMITPLAN' ) THEN
 -- cart or schedule then append the units already in cart.


    FOR cart_records IN cur_cart_units LOOP
          IF  INSTR(','||p_uoo_ids||',',','||cart_records.uoo_id||',',1) = 0  THEN
                  IF NOT IGS_EN_ELGBL_UNIT.eval_unit_steps(
                                                p_person_id => p_person_id,
                                                p_person_type => g_person_type,
                                                p_load_cal_type => p_load_cal_type,
                                                p_load_sequence_number => p_load_sequence_number,
                                                p_uoo_id => cart_records.uoo_id,
                                                p_course_cd => p_course_cd,
                                                p_course_version => p_course_version,
                                                p_enrollment_category => p_enrollment_category,
                                                p_enr_method_type => p_enr_meth_type,
                                                p_comm_type => p_comm_type,
                                                p_message => l_message_name, -- out
                                                p_deny_warn => l_deny_warn,  -- out
                                                p_calling_obj => p_calling_obj) THEN
                                     IF l_message_name IS NOT NULL THEN
                                        p_message := l_message_name;
                                        p_return_status := 'FALSE';
                                         RETURN;
                                     END IF;
                END IF;
                -- pickup the existing cart records, but not the newly created unconfirmed cart records
                IF l_new_uoo_ids IS NOT NULL THEN
                    l_new_uoo_ids := l_new_uoo_ids ||','||cart_records.uoo_id;
                ELSE
                    l_new_uoo_ids := cart_records.uoo_id;
                END IF;
            END IF;
    END LOOP;

  END IF; -- IF p_calling_obj = 'SUBMITSWAP' THEN

  IF l_new_uoo_ids IS NOT NULL THEN
    l_uoo_ids := l_new_uoo_ids || ',' || l_uoo_ids;
  END IF;
  --  Initialize min and max cp faile as false

  l_max_cp_fail := FALSE;
  l_min_cp_fail := FALSE;

  l_deny_warn := NULL;
  l_message_name := NULL;
  -- get the notification flag for max cp
  l_deny_warn :=   igs_ss_enr_details.get_notification(
                       p_person_type         => g_person_type,
                       p_enrollment_category => p_enrollment_category,
                       p_comm_type           => p_comm_type,
                       p_enr_method_type     => p_enr_meth_type,
                       p_step_group_type     => 'PROGRAM',
                       p_step_type           => 'FMAX_CRDT' ,
                       p_person_id           => p_person_id,
                       p_message             => l_message_name
                     );
  IF l_message_name IS NOT NULL THEN
     p_return_status :=  'FALSE';
     p_message  := l_message_name;
     RETURN;
  END IF;
 --loop through all the uoo_ids

  WHILE l_uoo_ids IS NOT NULL LOOP

    BEGIN
          l_message_name := NULL;
          IF(INSTR(l_uoo_ids,',',1) = 0) THEN
               l_uoo_id := TO_NUMBER(l_uoo_ids);
          ELSE
               l_uoo_id := TO_NUMBER(SUBSTR(l_uoo_ids,0,INSTR(l_uoo_ids,',',1)-1)) ;
          END IF;

           -- remove the uoo_id that will be processed
           IF(instr(l_uoo_ids,',',1) = 0) THEN
              l_uoo_ids := NULL;
            ELSE
              l_uoo_ids := substr(l_uoo_ids,instr(l_uoo_ids,',',1)+1);
            END IF;

          --Check that  unit attempt status is UNCONFIRM .
          OPEN chk_unconfirm_sua(l_uoo_id);
          FETCH chk_unconfirm_sua INTO l_sua_status,l_unit_cd,l_unit_ver;
          CLOSE chk_unconfirm_sua;

          IF l_sua_status = 'UNCONFIRM' THEN

              -- Evaluate Max Cp check
              -- Check if l_max_cp is false then call procedure to evaluate max cp.
              -- p_credit_points is deliberately passed as null for the procedure to calculate the existing enrolled CP.
              IF NOT l_max_cp_fail THEN


                  IF l_deny_warn IS NOT NULL THEN
                    l_message_name := NULL;
                    IF NOT igs_en_elgbl_program.eval_max_cp(
                                       p_person_id                    =>  p_person_id,
                                       p_load_calendar_type           =>  p_load_cal_type,
                                       p_load_cal_sequence_number     =>  p_load_sequence_number,
                                       p_uoo_id                       =>  l_uoo_id,
                                       p_program_cd                   =>  p_course_cd,
                                       p_program_version              =>  p_course_version,
                                       p_message                      =>  l_message_name,
                                       p_deny_warn                    =>  l_deny_warn,
                                       p_upd_cp                       =>  NULL,
                                       p_calling_obj                  =>  p_calling_obj) THEN

                         l_max_cp_fail := TRUE;
                        IF l_message_name IS NOT NULL THEN
                          p_return_status := 'FALSE';
                          p_message := l_message_name;
                          RETURN;
                        END IF; -- IF l_message_name IS NOT NULL


                     END IF; -- IF NOT igs_en_elgbl_program.eval_max_cp

                  END IF; -- IF l_deny_warn IS NOT NULL THEN

              END IF;-- IF NOT l_max_cp_fail THEN

             -- Enroll the unit
             igs_ss_en_wrappers.enroll_cart_unit(
                                                p_person_id => p_person_id ,
                                                p_uoo_id => l_uoo_id  ,
                                                p_unit_cd => l_unit_cd ,
                                                p_version_number => l_unit_ver ,
                                                p_course_cd => p_course_cd ,
                                                p_unit_attempt_status => 'ENROLLED' ,
                                                p_enrolled_dt => SYSDATE
                                                );
               -- Add the unit enrolled successfully
              IF  l_succ_new_uoo_ids IS NULL THEN
                l_succ_new_uoo_ids := l_uoo_id;
              ELSE
                l_succ_new_uoo_ids := l_succ_new_uoo_ids||','||l_uoo_id;
              END IF;

          END IF; -- IF l_sua_status = 'UNCONFIRM' THEN

      EXCEPTION

            -- To handle user defined exception raised when adminstrative unit status cannot be detremined
            WHEN NO_AUSL_RECORD_FOUND THEN
                RAISE NO_AUSL_RECORD_FOUND;

            -- Catch any exceptions here. If unhandled exceptions occur then return otherwise log an error record and continue
            WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN

                l_message_name := NULL;
                l_token_set := NULL;
                IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
                FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);

                -- Extract the token values if the retrieved msg is IGS_EN_INVALID_SUP_SUB
                IF l_message_name = 'IGS_EN_INVALID_SUP_SUB' THEN
                   l_token1 := FND_MESSAGE.GET_TOKEN('CONSTAT',NULL);
                   l_token2 := FND_MESSAGE.GET_TOKEN('SSTAT',NULL);
                   -- Then prepare the token along with their values in the fromat required
                   -- token:token_value
                   IF l_token1 IS NOT NULL AND l_token2 IS NOT NULL   THEN
                     l_token_set := 'CONSTAT' || ':' || l_token1 ||';'||'SSTAT'||':'||l_token2||';' ;
                   END IF;
                END IF;

                IF l_message_name IS NOT NULL THEN

                     l_unit_sec := get_unit_sec(l_uoo_id);
                      ---- Add to warnings table as error
                      igs_en_drop_units_api.create_ss_warning(
                                     p_person_id => p_person_id,
                                     p_course_cd => p_course_cd,
                                     p_term_cal_type => p_load_cal_type,
                                     p_term_ci_sequence_number =>  p_load_sequence_number,
                                     p_uoo_id => l_uoo_id,
                                     p_message_for => l_unit_sec,
                                     p_message_icon=> 'D',
                                     p_message_name => l_message_name,
                                     p_message_rule_text => NULL,
                                     p_message_tokens => l_token_set,
                                     p_message_action => NULL,
                                     p_destination => NULL,
                                     p_parameters => NULL,
                                     p_step_type => 'UNIT');
                END IF; -- IF l_message_name IS NOT NULL THEN


            WHEN OTHERS THEN
              RAISE;
      END; --- end of begin

          --  END IF; -- IF l_sua_status = 'UNCONFIRM' THEN
  END LOOP; -- WHILE l_uoo_ids IS NOT NULL LOOP



  l_uoo_ids := l_succ_new_uoo_ids;

  --- get the notification flag for min cp
  l_deny_warn_min_cp := NULL;
  l_message_name := NULL;
  l_deny_warn_min_cp :=   igs_ss_enr_details.get_notification(
                             p_person_type         => g_person_type,
                             p_enrollment_category => p_enrollment_category,
                             p_comm_type           => p_comm_type,
                             p_enr_method_type     => p_enr_meth_type,
                             p_step_group_type     => 'PROGRAM',
                             p_step_type           => 'FMIN_CRDT' ,
                             p_person_id           => p_person_id,
                             p_message             => l_message_name
                           );
  IF l_message_name IS NOT NULL THEN
     p_return_status :=  'FALSE';
     p_message  := l_message_name;
     RETURN;
  END IF;

  -- Loop through the units enrolled and implement the following validations:
  WHILE l_succ_new_uoo_ids IS NOT NULL LOOP

    BEGIN
           l_message_name := NULL;
           IF(INSTR(l_succ_new_uoo_ids,',',1) = 0) THEN
            l_uoo_id := TO_NUMBER(l_succ_new_uoo_ids);
           ELSE
            l_uoo_id :=  TO_NUMBER(SUBSTR(l_succ_new_uoo_ids,0,INSTR(l_succ_new_uoo_ids,',',1)-1)) ;
           END IF;

            -- remove the uoo id that will be processed
            IF(instr(l_succ_new_uoo_ids,',',1) = 0) THEN
              l_succ_new_uoo_ids := NULL;
            ELSE
              l_succ_new_uoo_ids := substr(l_succ_new_uoo_ids,instr(l_succ_new_uoo_ids,',',1)+1);
            END IF;

           -- Minimum CP validations
           -- Check if min_cp has not failed, then call procedure to evaluate min cp.
            IF NOT l_min_cp_fail THEN

                  IF l_deny_warn_min_cp IS NOT NULL THEN

                    l_credit_points := 0;
                    l_message_name := NULL;
                    IF NOT igs_en_elgbl_program.eval_min_cp(
                                       p_person_id                    =>  p_person_id,
                                       p_load_calendar_type           =>  p_load_cal_type,
                                       p_load_cal_sequence_number     =>  p_load_sequence_number,
                                       p_uoo_id                       =>  l_uoo_id,
                                       p_program_cd                   =>  p_course_cd,
                                       p_program_version              =>  p_course_version,
                                       p_message                      =>  l_message_name,
                                       p_deny_warn                    =>  l_deny_warn_min_cp,
                                       p_credit_points                =>  l_credit_points, -- deliberately passing the value zero since the cp has already been enrolled
                                       p_enrollment_category          =>  p_enrollment_category,
                                       p_comm_type                    =>  p_comm_type,
                                       p_method_type                  =>  p_enr_meth_type,
                                       p_min_credit_point             =>  l_min_credit_point,
                                       p_calling_obj                  =>  p_calling_obj) THEN

                         l_min_cp_fail := TRUE;
                        IF l_message_name IS NOT NULL THEN
                          p_return_status := 'FALSE';
                          p_message := l_message_name;
                          RETURN;
                        END IF; -- IF l_message_name IS NOT NULL


                     END IF; -- IF NOT igs_en_elgbl_program.eval_min_cp

                  END IF; -- IF l_deny_warn IS NOT NULL THEN

            END IF; -- IF NOT l_min_cp_fail THEN

            -- Implement Program validations
            l_deny_warn := NULL;
            IF NOT igs_en_elgbl_program.eval_program_steps(
                                         p_person_id => p_person_id,
                                         p_person_type => g_person_type,
                                         p_load_calendar_type => p_load_cal_type,
                                         p_load_cal_sequence_number  => p_load_sequence_number,
                                         p_uoo_id => l_uoo_id,
                                         p_program_cd => p_course_cd,
                                         p_program_version => p_course_version,
                                         p_enrollment_category => p_enrollment_category,
                                         p_comm_type => p_comm_type,
                                         p_method_type => p_enr_meth_type,
                                         p_message  => l_message_name,
                                         p_deny_warn => l_deny_warn,
                                         p_calling_obj => p_calling_obj) THEN

              IF l_message_name IS NOT NULL THEN
                  p_return_status := 'FALSE';
                  p_message := l_message_name;
                  RETURN;
              END IF;

            END IF; -- IF NOT igs_en_enroll_wlst.validate_prog

          -- Execute call to the fee assesment procedure.
          -- in case of cart swap submit plan no need to call this because
          -- beacuse  we will be rolling back the enrolled units to
          -- unconfirm units and no validations that need to be informed to
          -- the user are done here.
            IF p_calling_obj NOT IN  ('CART','SWAP','SUBMITPLAN') THEN
              IGS_SS_EN_WRAPPERS.call_fee_ass (
                               p_person_id       => p_person_id,
                               p_cal_type        => p_load_cal_type,
                               p_sequence_number => p_load_sequence_number,
                               p_course_cd       => p_course_cd,
                               p_unit_cd         => l_unit_cd,
                               p_uoo_id          => l_uoo_id);

            END IF;

    EXCEPTION

            -- To handle user defined exception raised when adminstrative unit status cannot be detremined
            WHEN NO_AUSL_RECORD_FOUND THEN
                RAISE NO_AUSL_RECORD_FOUND;


            -- Catch any exceptions here. If unhandled exceptions occur then return otherwise log an error record and continue
            WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN

                l_message_name := NULL;
                IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
                FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);

                IF l_message_name IS NOT NULL THEN

                     l_unit_sec := get_unit_sec(l_uoo_id);
                      ---- Add to warnings table as error
                      igs_en_drop_units_api.create_ss_warning(
                                     p_person_id => p_person_id,
                                     p_course_cd => p_course_cd,
                                     p_term_cal_type => p_load_cal_type,
                                     p_term_ci_sequence_number =>  p_load_sequence_number,
                                     p_uoo_id => l_uoo_id,
                                     p_message_for => l_unit_sec,
                                     p_message_icon=> 'D',
                                     p_message_name => l_message_name,
                                     p_message_rule_text => NULL,
                                     p_message_tokens => NULL,
                                     p_message_action => NULL,
                                     p_destination => NULL,
                                     p_parameters => NULL,
                                     p_step_type => 'UNIT');
                END IF; -- IF l_message_name IS NOT NULL THEN


            WHEN OTHERS THEN
              RAISE;


    END;
  END LOOP; -- WHILE l_succ_new_uoo_ids IS NOT NULL LOOP

     l_message_name := NULL;
     l_return_status := NULL;
  -- The call to encumbrance check procedure does not require a unit code, hence it can be evaluated outside the loop.
    validate_enr_encmb( p_person_id,
                        p_course_cd,
                        p_load_cal_type,
                        p_load_sequence_number,
                        l_return_status,
                        l_message_name
                        ) ;
    IF l_return_status IS NOT NULL AND l_message_name IS NOT NULL THEN
      p_message := l_message_name;
      p_return_status := 'FALSE';
      RETURN;
    END IF;

  -- Check if p_calling_obj is "SWAP", "SUBMITSWAP"
  IF p_calling_obj In ( 'SWAP','SUBMITSWAP') THEN

     -- Fetch the enrolled units in the term that have not been selected for swap.
     -- Use the following ref cursor for the same:

      l_message_name := NULL;

      l_deny_warn_coreq := NULL;
      l_deny_warn_coreq :=   igs_ss_enr_details.get_notification(
                                 p_person_type         => g_person_type,
                                 p_enrollment_category => p_enrollment_category,
                                 p_comm_type           => p_comm_type,
                                 p_enr_method_type     => p_enr_meth_type,
                                 p_step_group_type     => 'UNIT',
                                 p_step_type           => 'COREQ' ,
                                 p_person_id           => p_person_id,
                                 p_message             => l_message_name
                               );
      IF l_message_name IS NOT NULL THEN
         p_return_status :=  'FALSE';
         p_message  := l_message_name;
         RETURN;
      END IF;

      l_deny_warn_prereq := NULL;
      l_deny_warn_prereq :=   igs_ss_enr_details.get_notification(
                                 p_person_type         => g_person_type,
                                 p_enrollment_category => p_enrollment_category,
                                 p_comm_type           => p_comm_type,
                                 p_enr_method_type     => p_enr_meth_type,
                                 p_step_group_type     => 'UNIT',
                                 p_step_type           => 'PREREQ' ,
                                 p_person_id           => p_person_id,
                                 p_message             => l_message_name
                               );
      IF l_message_name IS NOT NULL THEN
         p_return_status :=  'FALSE';
         p_message  := l_message_name;
         RETURN;
      END IF;

      -- modified this cursor as a part of bug#5036954.

      OPEN c_get_swap_units  FOR
                             'SELECT SUA.uoo_id
                             FROM  igs_en_su_attempt sua, igs_ca_load_to_teach_v load
                             WHERE person_id = :p_person_id
                             AND course_cd = :p_course_cd
                             AND unit_attempt_status IN (''ENROLLED'',''INVALID'')
                             AND cal_type = teach_cal_type
                             AND ci_sequence_number = teach_ci_sequence_number
                             AND load_cal_type = :p_load_cal_type
                             AND load_ci_sequence_number = :p_load_sequence_number
                             AND (uoo_id NOT IN('|| NVL(l_uoo_ids,'-999') ||'))' USING p_person_id,p_course_cd,p_load_cal_type,p_load_sequence_number;

      WHILE TRUE LOOP

              FETCH c_get_swap_units INTO l_uoo_id;

              IF c_get_swap_units%NOTFOUND THEN
                CLOSE c_get_swap_units;
                EXIT;
              END IF;

              -- if the uooid exists in the list of the uooids list failed prereq and coreq
              -- rules because of swapping the passed units
              IF (INSTR(','||igs_en_add_units_api.g_swap_failed_uooids||',' , ','||l_uoo_id||',') <> 0) THEN

                  l_unit_sec := get_unit_sec(l_uoo_id);
                  IF l_deny_warn_coreq IS NOT NULL THEN

                    l_message_name := NULL;
                    IF NOT IGS_EN_ELGBL_UNIT.eval_coreq(  p_person_id            =>  p_person_id,
                                                          p_load_cal_type        =>  p_load_cal_type,
                                                          p_load_sequence_number =>  p_load_sequence_number,
                                                          p_uoo_id               =>  l_uoo_id,
                                                          p_course_cd            =>  p_course_cd,
                                                          p_course_version       =>  p_course_version,
                                                          p_message              =>  l_message_name,
                                                          p_deny_warn            =>  l_deny_warn_coreq,
                                                          p_calling_obj          => 'JOB') THEN

                                IF l_deny_warn_coreq = 'DENY' THEN
                                  l_message_icon := 'D';
                                  l_message_name := 'IGS_SS_DENY_COREQ_SWP';
                                ELSE
                                  l_message_icon := 'W';
                                  l_message_name := 'IGS_SS_WARN_COREQ_SWP';
                                END IF;

                                igs_en_drop_units_api.create_ss_warning (
                                                       p_person_id => p_person_id,
                                                       p_course_cd => p_course_cd,
                                                       p_term_cal_type=>p_load_cal_type,
                                                       p_term_ci_sequence_number => p_load_sequence_number,
                                                       p_uoo_id => l_uoo_id,
                                                       p_message_for => l_unit_sec,
                                                       p_message_icon=> l_message_icon,
                                                       p_message_name => l_message_name,
                                                       p_message_rule_text => NULL,
                                                       p_message_tokens => NULL,
                                                       p_message_action=> NULL ,
                                                       p_destination => NULL,
                                                       p_parameters => NULL,
                                                       p_step_type => 'UNIT');

                    END IF; -- IF NOT IGS_EN_ELGBL_UNIT.eval_coreq

                  END IF; -- IF l_deny_warn_coreq IS NOT NULL THEN

                  IF l_deny_warn_prereq IS NOT NULL THEN
                    l_message_name := NULL;
                    IF NOT  IGS_EN_ELGBL_UNIT.eval_prereq(
                                              p_person_id            =>  p_person_id,
                                              p_load_cal_type        =>  p_load_cal_type,
                                              p_load_sequence_number =>  p_load_sequence_number,
                                              p_uoo_id               =>  l_uoo_id,
                                              p_course_cd            =>  p_course_cd,
                                              p_course_version       =>  p_course_version,
                                              p_message              =>  l_message_name,
                                              p_deny_warn            =>  l_deny_warn_prereq,
                                              p_calling_obj          =>  'JOB') THEN

                                IF l_deny_warn_prereq = 'DENY' THEN
                                  l_message_icon := 'D';
                                  l_message_name := 'IGS_SS_DENY_PREREQ_SWP';
                                ELSE
                                  l_message_icon := 'W';
                                  l_message_name := 'IGS_SS_WARN_PREREQ_SWP';
                                END IF;

                                igs_en_drop_units_api.create_ss_warning (
                                                       p_person_id => p_person_id,
                                                       p_course_cd => p_course_cd,
                                                       p_term_cal_type=>p_load_cal_type,
                                                       p_term_ci_sequence_number => p_load_sequence_number,
                                                       p_uoo_id => l_uoo_id,
                                                       p_message_for => l_unit_sec,
                                                       p_message_icon=> l_message_icon,
                                                       p_message_name => l_message_name,
                                                       p_message_rule_text => NULL,
                                                       p_message_tokens => NULL,
                                                       p_message_action=>NULL ,
                                                       p_destination =>NULL,
                                                       p_parameters =>NULL,
                                                       p_step_type => 'UNIT');
                    END IF; -- IF NOT  IGS_EN_ELGBL_UNIT.eval_prereq

                  END IF; --IF l_deny_warn_prereq IS NOT NULL THEN

              END IF; --IF (INSTR(','||igs_en_add_units_api.g_swap_failed_uooids||',' , ','||l_uoo_id||',') = 0) THEN

      END LOOP; -- WHILE TRUE LOOP

  END IF; -- IF p_calling_obj In ( 'SWAP','SUBMITSWAP') THEN

EXCEPTION

-- To handle user defined exception raised when adminstrative unit status cannot be detremined
  WHEN NO_AUSL_RECORD_FOUND THEN
    p_message := 'IGS_SS_CANTDET_ADM_UNT_STATUS';
    p_return_status :=  'FALSE';
    RETURN;

  WHEN OTHERS THEN
     IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
        FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.create_enroll_sua :',SQLERRM);
      END IF;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.create_enroll_sua');
      IGS_GE_MSG_STACK.ADD;
      RAISE;
END create_enroll_sua;


PROCEDURE delete_cart_error_records(p_person_id          IN NUMBER,
                                    p_course_cd          IN VARCHAR2,
                                    p_load_cal_type      IN VARCHAR2,
                                    p_load_sequence_number IN NUMBER
                                   ) AS
-------------------------------------------------------------------------------------------
  --Created by  : Chandrasekhar Kasu, Oracle IDC
  --Date created: 17-OCT-2005
  -- Purpose : creates student unit attempt.
  --Change History:
  --Who         When            What
  --ckasu      18-OCT-2005    created as a part of bug#4674099 inorder to delete the cart error
  --                          records present in Planning sheet table
  -------------------------------------------------------------------------------------------


  CURSOR c_get_rowid IS
  SELECT ROWID
  FROM igs_en_plan_units
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND term_cal_type = p_load_cal_type
  AND term_ci_sequence_number = p_load_sequence_number
  AND cart_error_flag = 'Y';

  CURSOR c_ss_warn IS
  SELECT ROWID
  FROM IGS_EN_STD_WARNINGS
  WHERE person_id = p_person_id
  AND course_cd = p_course_cd
  AND term_cal_type = p_load_cal_type
  AND term_ci_sequence_number  = p_load_sequence_number
  AND step_type <> 'DROP';


BEGIN

FOR c_get_plan_err_rec IN c_get_rowid LOOP

  IGS_EN_PLAN_UNITS_PKG.delete_row(x_rowid => c_get_plan_err_rec.ROWID);

END LOOP;

FOR c_ss_warn_rec IN c_ss_warn LOOP
  IGS_EN_STD_WARNINGS_PKG.delete_row(x_rowid => c_ss_warn_rec.rowid);
END LOOP;


EXCEPTION
  WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.delete_plan_error_records');
        IGS_GE_MSG_STACK.ADD;
        IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
              FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.delete_plan_error_records :',SQLERRM);
        END IF;
        ROLLBACK;
        RAISE;

END delete_cart_error_records;


PROCEDURE add_selected_units (
                              p_person_id IN NUMBER,
                              p_course_cd IN VARCHAR2,
                              p_course_version  IN NUMBER,
                              p_load_cal_type IN VARCHAR2,
                              p_load_sequence_number IN NUMBER,
                              p_uoo_ids IN VARCHAR2,
                              p_calling_obj IN VARCHAR2,
                              p_validate_person_step IN VARCHAR2,
                              p_return_status OUT NOCOPY VARCHAR2,
                              p_message OUT NOCOPY VARCHAR2,
                              p_deny_warn OUT NOCOPY VARCHAR2,
                              p_ss_session_id IN NUMBER) AS
  -------------------------------------------------------------------------------------------
  --Created by  : Basanth Kumar D, Oracle IDC
  --Date created: 29-JUL-2005
  --Purpose : This procedure gets uooids passed reordered (superior/subordinate/others units)
  -- Then it gets the perm/waitlsit deatils of the units
  -- For 'PLAN' it validates the steps required for the passed units
  -- For others it creates unocnfirm units which are later updated to enroll units
  -- Finally depending on the calling object, return status and p_deny_warn values
  -- it is rolled back to diff savepoints if required.
  --Change History:
  --Who         When            What

  -------------------------------------------------------------------------------------------

  l_enr_meth_type                       igs_en_method_type.enr_method_type%TYPE;
  l_alternate_code                      igs_ca_inst.alternate_code%TYPE;
  l_acad_cal_type                       igs_ca_inst.cal_type%TYPE;
  l_acad_ci_sequence_number             igs_ca_inst.sequence_number%TYPE;
  l_acad_start_dt                       DATE;
  l_acad_end_dt                         DATE;
  l_enr_cat                             igs_ps_type.enrolment_cat%TYPE;
  l_enr_cal_type                        igs_ca_inst.cal_type%TYPE;
  l_enr_ci_seq                          igs_ca_inst.sequence_number%TYPE;
  l_enr_categories                      VARCHAR2(255);
  l_enr_comm                            VARCHAR2(1000);
  l_enc_message_name                    VARCHAR2(2000);
  l_app_short_name                      VARCHAR2(100);
  l_msg_index                           NUMBER;
  t_reorder_unit_params                 t_params_table;
  l_message_name                        VARCHAR2(4000);
  l_deny_warn                           VARCHAR2(20);
  l_return_status                       VARCHAR2(20);
  l_unconfirm_suas                      VARCHAR2(1000);
  l_steps                               VARCHAR2(100);

BEGIN

SAVEPOINT sp_add_units_api;

igs_en_add_units_api.g_ss_session_id := p_ss_session_id;

 p_return_status := 'TRUE';
 IF p_calling_obj IS NULL OR p_calling_obj NOT IN ('SWAP', 'SUBMITSWAP','CART','SUBMITCART','ENROLPEND','SCHEDULE','PLAN','SUBMITPLAN') THEN
      p_message  := 'IGS_EN_INVALID_CALLINGOBJ';
      p_return_status := 'FALSE';
      p_deny_warn := 'D';
      igs_en_add_units_api.g_ss_session_id := NULL;
      RETURN;
 END IF;

 IF p_calling_obj  NOT IN ('PLAN','SUBMITPLAN') THEN
         check_sua_exists( p_person_id,
                           p_course_cd,
                           p_load_cal_type,
                           p_load_sequence_number,
                           p_uoo_ids,
                           p_message);
         IF p_message IS NOT NULL THEN
            p_return_status := 'FALSE';
            p_deny_warn := 'D';
            igs_en_add_units_api.g_ss_session_id := NULL;
            RETURN;
         END IF;
 END IF; --  end of IF p_calling_obj IS NOT IN ('PLAN','SUBMITPLAN') THEN
 -- get the person type
  g_person_type := get_person_type(p_course_cd);

  igs_en_gen_017.enrp_get_enr_method(
                                       p_enr_method_type => l_enr_meth_type,
                                       p_error_message   => l_message_name,
                                       p_ret_status      => l_return_status
                                       );

   IF l_return_status = 'FALSE' OR l_message_name IS NOT NULL THEN

      p_message  := l_message_name;
      p_return_status := 'FALSE';
      p_deny_warn := 'D';
      igs_en_add_units_api.g_ss_session_id := NULL;
      RETURN;

   END IF ;

   l_alternate_code := Igs_En_Gen_002.Enrp_Get_Acad_Alt_Cd(
                        p_cal_type                => p_load_cal_type,
                        p_ci_sequence_number      => p_load_sequence_number,
                        p_acad_cal_type           => l_acad_cal_type,
                        p_acad_ci_sequence_number => l_acad_ci_sequence_number,
                        p_acad_ci_start_dt        => l_acad_start_dt,
                        p_acad_ci_end_dt          => l_acad_end_dt,
                        p_message_name            => l_message_name );

  IF l_message_name IS NOT NULL THEN

    p_message  := l_message_name;
    p_return_status :=  'FALSE';
    p_deny_warn := 'D';
    igs_en_add_units_api.g_ss_session_id := NULL;
    RETURN;

  END IF;

  l_enr_cat := igs_en_gen_003.enrp_get_enr_cat(
                                                p_person_id            =>    p_person_id,
                                                p_course_cd            =>    p_course_cd ,
                                                p_cal_type             =>    l_acad_cal_type ,
                                                p_ci_sequence_number   =>    l_acad_ci_sequence_number,
                                                p_session_enrolment_cat =>    NULL,
                                                p_enrol_cal_type        =>   l_enr_cal_type,
                                                p_enrol_ci_sequence_number => l_enr_ci_seq,
                                                p_commencement_type     =>   l_enr_comm,
                                                p_enr_categories        =>   l_enr_categories
                                                );


    IF p_validate_person_step = 'Y' THEN
      -- delete all messages for person program,unit steps in warnings table for the person
      l_steps := 'PERSON'',''PROGRAM'',''UNIT';
      delete_ss_warnings(p_person_id,
                         p_course_cd,
                         p_load_cal_type,
                         p_load_sequence_number,
                         NULL, -- uoo_id
                         NULL, -- message_for
                         l_steps); -- steps to be considered while delete warnings records agsinst the person context

      l_message_name := NULL;
      IF NOT  IGS_EN_ELGBL_PERSON.eval_person_steps(
                                              p_person_id => p_person_id,
                                              p_person_type => g_person_type,
                                              p_load_calendar_type => p_load_cal_type,
                                              p_load_cal_sequence_number  => p_load_sequence_number,
                                              p_program_cd  => p_course_cd,
                                              p_program_version => p_course_version,
                                              p_enrollment_category => l_enr_cat,
                                              p_comm_type => l_enr_comm,
                                              p_enrl_method => l_enr_meth_type,
                                              p_message =>   l_message_name,
                                              p_deny_warn => l_deny_warn,
                                              p_calling_obj  => p_calling_obj,
                                              p_create_warning => 'Y') THEN
                IF l_message_name IS NOT NULL THEN
                      p_message := l_message_name;
                      p_return_status :=  'FALSE';
                      p_deny_warn := 'D';
                      igs_en_add_units_api.g_ss_session_id := NULL;
                      RETURN;
                END IF;

      END IF;

    ELSE
    --   purge unit and program level messages from warnings table
      l_steps := 'PROGRAM'',''UNIT';
      delete_ss_warnings(p_person_id,
                         p_course_cd,
                         p_load_cal_type,
                         p_load_sequence_number,
                         NULL, -- uoo_id
                         NULL, -- message_for
                         l_steps); -- -- steps to be considered while delete warnings records agsinst the person context

    END IF;


  -- .    Call routine to decode and reorder the uoo_ids
  reorder_uoo_ids(p_person_id,
                  p_course_cd,
                  p_uoo_ids,
                  p_load_cal_type,
                  p_load_sequence_number,
                  p_calling_obj,
                  t_reorder_unit_params);

  --   Call routine to get the permission status and waitlist status for each of the above units.
  l_return_status := NULL;
  get_perm_wlst_setup(p_person_id,
                      p_course_cd,
                      p_load_cal_type,
                      p_load_sequence_number,
                      t_reorder_unit_params,
                      p_message,
                      l_return_status,
                      'Y'); --chk wailist setup also
    IF l_return_status  = 'FALSE' THEN
        p_return_status := 'FALSE';
        p_deny_warn := 'D';
        igs_en_add_units_api.g_ss_session_id := NULL;
        RETURN;
    END IF;

  IF p_calling_obj = 'PLAN' THEN

    SAVEPOINT sp_plan_sua;
    l_return_status := NULL;
    IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop  := 'PLAN';
    create_planned_sua( p_person_id,
                        p_course_cd,
                        p_course_version,
                        p_load_cal_type,
                        p_load_sequence_number,
                        t_reorder_unit_params,
                        l_enr_cat,
                        l_enr_meth_type,
                        l_enr_comm,
                        p_message,
                        l_return_status,
                       p_calling_obj);
    IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop  := NULL;
        ROLLBACK TO sp_plan_sua; -- needs to be rollbacked as this is just for making validations

    IF l_return_status  = 'FALSE' THEN
        p_return_status := 'FALSE';
        p_deny_warn := 'D';
        igs_en_add_units_api.g_ss_session_id := NULL;
        RETURN;
    END IF;

  ELSE

    -- Cart Max rule is not evaluated for swap and submitswap and submitcart, ENROLPEND

    IF p_calling_obj NOT IN ('SWAP', 'SUBMITSWAP','SUBMITCART','ENROLPEND') THEN

      IF NOT eval_cart_max(
                            p_person_id,
                            l_enr_cat,
                            l_enr_meth_type,
                            l_enr_comm,
                            p_course_cd,
                            p_course_version,
                            p_load_cal_type,
                            p_load_sequence_number,
                            t_reorder_unit_params,
                            p_message,
                            p_calling_obj) THEN

        p_return_status := 'FALSE';
        p_deny_warn := 'D';
        ROLLBACK TO sp_add_units_api;
        igs_en_add_units_api.g_ss_session_id := NULL;
        RETURN;

      END IF; -- IF NOT eval_cart_max(

    END IF; -- IF p_calling_obj NOT IN ('SWAP', 'SUBMITSWAP','SUBMITCART','ENROLPEND') THEN

    SAVEPOINT sp_unconfirm_sua;
    l_return_status := NULL;
    create_unconfirm_sua(
                            p_person_id,
                            p_course_cd,
                            p_course_version,
                            p_load_cal_type,
                            p_load_sequence_number,
                            t_reorder_unit_params,
                            ','||p_uoo_ids||',',
                            l_enr_cat,
                            l_enr_meth_type,
                            l_enr_comm,
                            l_unconfirm_suas,
                            p_message,
                            l_return_status,
                            p_calling_obj);

      IF l_return_status  = 'FALSE' THEN
        p_return_status := 'FALSE';
        p_deny_warn := 'D';
        ROLLBACK TO sp_unconfirm_sua;
        igs_en_add_units_api.g_ss_session_id := NULL;
        RETURN;
      END IF;


      SAVEPOINT sp_enroll_sua;

      -- create waitlisted units after sp_enroll_sua so that
      -- they get rolled back once we roll back to this savepoint
      -- but unconfirm unit attempts doesnot get rolled back
      IF p_calling_obj = 'SUBMITPLAN' THEN

          FOR i IN 1.. t_reorder_unit_params.COUNT

          LOOP

            IF t_reorder_unit_params(i).wlst_step = 'Y' AND
               t_reorder_unit_params(i).create_wlst = 'Y' THEN

               l_message_name := NULL;
               l_return_status := NULL;
               create_sua_from_plan( p_person_id,
                                     p_course_cd,
                                     t_reorder_unit_params(i).uoo_id,
                                     p_load_cal_type,
                                     p_load_sequence_number,
                                     t_reorder_unit_params(i).ass_ind,
                                     'Y',               --- pass waitlsit ind as 'Y'
                                     l_enr_meth_type,
                                     t_reorder_unit_params(i).override_enrolled_cp,
                                     t_reorder_unit_params(i).grading_schema_cd,
                                     t_reorder_unit_params(i).gs_version_number,
                                     p_calling_obj,
                                     l_message_name,
                                     l_return_status) ;

               IF l_return_status = 'FALSE' AND l_message_name IS NOT NULL THEN
                        p_return_status := 'FALSE';
                        p_message := l_message_name;
                        igs_en_add_units_api.g_ss_session_id := NULL;
                        RETURN;
               END IF;

               -- create warning record if waitlisted unit has been created succesfully.
              igs_en_drop_units_api.create_ss_warning (
                          p_person_id => p_person_id,
                          p_course_cd => p_course_cd,
                          p_term_cal_type => p_load_cal_type,
                          p_term_ci_sequence_number => p_load_sequence_number,
                          p_uoo_id => t_reorder_unit_params(i).uoo_id,
                          p_message_for => get_unit_sec(t_reorder_unit_params(i).uoo_id),
                          p_message_icon => 'W',
                          p_message_name => 'IGS_EN_WLST_AVAIL', -- need to check message_name
                          p_message_rule_text => NULL,
                          p_message_tokens => NULL,
                          p_message_action => NULL,
                          p_destination => NULL, -- p_destination
                          p_parameters => NULL, -- p_parameters
                          p_step_type => 'UNIT');


            END IF;

          END LOOP;

      END IF; -- IF p_calling_obj = 'SUBMITPLAN'

       -- call routine to create enrolled unit attempt.
      l_return_status := NULL;
      create_enroll_sua(
                        p_person_id,
                        p_course_cd,
                        p_course_version,
                        l_unconfirm_suas,
                        p_load_cal_type,
                        p_load_sequence_number,
                        l_enr_cat,
                        l_enr_meth_type,
                        l_enr_comm,
                        p_message,
                        l_return_status,
                        p_calling_obj);

                  -- p_return_status has the status of the creation of enrolled unit attempts.
                  -- If this is false then it implies that the API cannot proceed any further. Return to the calling page.

                  update_warnings_table(p_person_id,
                                        p_course_cd ,
                                        p_load_cal_type,
                                        p_load_sequence_number,
                                        p_calling_obj);

                  p_deny_warn := set_deny_warn(p_person_id,
                                               p_course_cd,
                                               p_load_cal_type,
                                               p_load_sequence_number);

                  -- to update the deny records of those units not in sua table and planning sheet
                  -- (planning shhet error records if calling object is not plan) 'E'

                 IF l_return_status  = 'FALSE' THEN
                    p_return_status := 'FALSE';
                    p_deny_warn := 'D';
                    ROLLBACK TO sp_unconfirm_Sua;
                    igs_en_add_units_api.g_ss_session_id := NULL;
                    RETURN;
                 END IF;

                -- Incase of cart and swap rollback till sp_unconfirm_sua
                -- so that all the waitlisted units will be rolled back
                -- and enrolled units will be rolled bcak to unconfirm units ( as unocnfirming units is done
                -- in an autonomus transaction for cart and swap)
                IF p_calling_obj IN ( 'CART', 'SWAP')  THEN

                    ROLLBACK TO sp_unconfirm_sua;

                ELSIF p_calling_obj = 'SUBMITPLAN' THEN

                   -- in this case if any deny record exists then
                   -- all the unts are rolled back even uncofirm units as in case
                   -- of submit plan units are unconfirmed in a normal transaction
                   IF p_deny_warn='D' THEN

                     ROLLBACK TO sp_unconfirm_sua;
                   -- if no deny records exists then enrolled units are rolled back to unocnfirm status
                   -- waitlisted records created are rolled back
                   ELSE
                     ROLLBACK TO sp_enroll_sua;
                   END IF;

                ELSIF p_calling_obj IN ('SUBMITCART','SUBMITSWAP','SCHEDULE','ENROLPEND') THEN

                  IF p_deny_warn = 'D' OR
                      (p_calling_obj IN ('SCHEDULE','ENROLPEND') AND p_deny_warn = 'W') THEN
                    ROLLBACK TO  sp_unconfirm_sua;
                  ELSE
                    -- added by ckasu as a part of bug#4674099 inorder to delete the cart error
                    -- record present in Planning sheet table when p_calling object is 'SUBMITCART',
                    -- or 'SUBMITSWAP'
                    delete_cart_error_records(p_person_id,
                                              p_course_cd,
                                              p_load_cal_type,
                                              p_load_sequence_number);
                  END IF;

                END IF; -- IF p_calling_obj IN ('SUBMITPLAN', 'CART', 'SWAP')


    END IF; -- IF p_calling_obj = 'PLAN' THEN

        -- to update the deny records of those units not in sua table and planning sheet
        -- (planning sheet error records if calling object is not plan) 'E'
        update_warnings_table(p_person_id,
                              p_course_cd ,
                              p_load_cal_type,
                              p_load_sequence_number,
                              p_calling_obj);
        -- p_return_status has the status of the creation of enrolled unit attempts.
        -- If this is false then it implies that the API cannot proceed any further. Return to the calling page.
        p_deny_warn := set_deny_warn(p_person_id,
                                     p_course_cd,
                                     p_load_cal_type,
                                     p_load_sequence_number);

    igs_en_add_units_api.g_ss_session_id := NULL;
EXCEPTION

  WHEN OTHERS THEN
    igs_en_add_units_api.g_ss_session_id := NULL;
    IGS_EN_SU_ATTEMPT_PKG.pkg_source_of_drop  := NULL;
    IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
            FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.add_selected_units :',SQLERRM);
    END IF;
    ROLLBACK TO sp_add_units_api;
    p_deny_warn := 'D';
    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
    FND_MESSAGE.SET_TOKEN('NAME', 'IGS_EN_ADD_UNITS_API.add_selected_units');
    IGS_GE_MSG_STACK.ADD;
    RAISE;
END add_selected_units;

 PROCEDURE delete_unrelated_warnings(p_person_id IN VARCHAR2,
                           p_course_cd IN VARCHAR2,
                           p_load_cal_type IN VARCHAR2,
                           p_load_sequence_number IN VARCHAR2,
                           p_delete_message_count OUT NOCOPY NUMBER
                               ) AS
 PRAGMA  AUTONOMOUS_TRANSACTION;
   CURSOR c_get_warnings IS
   SELECT ROWID
   FROM IGS_EN_STD_WARNINGS
   WHERE person_id = p_person_id
   AND course_cd = p_course_cd
   AND term_cal_type = p_load_cal_type
   AND term_ci_sequence_number  = p_load_sequence_number
   AND step_type <> 'PERSON';
 BEGIN
     p_delete_message_count := 0;
     FOR c_get_warnings_rec IN c_get_warnings  LOOP
       IGS_EN_STD_WARNINGS_PKG.delete_row(x_rowid => c_get_warnings_rec.ROWID);
       p_delete_message_count := p_delete_message_count + 1;
     END LOOP;

   COMMIT;
 EXCEPTION
     WHEN OTHERS THEN
       IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level ) THEN
         FND_LOG.STRING(fnd_log.level_unexpected, 'igs.patch.115.sql.igs_en_add_units_api.delete_unrelated_warnings :',SQLERRM);
       END IF;
       ROLLBACK;
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_ADD_UNITS_API.delete_unrelated_warnings');
       IGS_GE_MSG_STACK.ADD;
       RAISE;
 END delete_unrelated_warnings;

END IGS_EN_ADD_UNITS_API;

/
