--------------------------------------------------------
--  DDL for Package Body IGS_EN_VAL_PIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_VAL_PIG" AS
/* $Header: IGSEN98B.pls 115.5 2003/07/08 10:42:19 ptandon noship $ */

  FUNCTION enrf_get_pig_cp (p_person_id IN  NUMBER,
                            p_which_cp  IN  VARCHAR2,
                            p_message   OUT NOCOPY VARCHAR2)
  RETURN NUMBER IS
  ------------------------------------------------------------------
  --Created by  : Kiran Killamsetty, Oracle IDC
  --Date created: 01-NOV-2002
  --
  --Purpose: Gets the min/max cp for a person at person id group level
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --amuthu      02-JAN-2003     There was a check to see if the step
  --                            was setup at PIG level and only then
  --                            the value would be returned. Changed
  --                            this to return the value irrespective
  --                            of the step being setup at PIG level
  --ptandon     07-JUL-2003     Modified the cursor cur_pig to select
  --                            only those Person ID Groups for which
  --                            the person has not been end-dated.
  --                            Bug# 3038825
  -------------------------------------------------------------------
  CURSOR cur_pig IS SELECT DISTINCT group_id
                    FROM igs_pe_prsid_grp_mem
                    WHERE person_id = p_person_id AND
		          TRUNC(SYSDATE) BETWEEN start_date AND NVL(end_date,TRUNC(SYSDATE));
  CURSOR cur_cp  (cp_group_id       igs_pe_prsid_grp_mem.group_id%TYPE)
                  IS SELECT prsid_max_cp,prsid_min_cp FROM igs_en_pig_cp_setup
                                                      WHERE group_id = cp_group_id;
  rec_cp            cur_cp%ROWTYPE;
  l_count           NUMBER;
  l_ret_value       NUMBER DEFAULT NULL;
  l_cp_defined    BOOLEAN;
  BEGIN
      p_message := NULL;
      --Validating the input parameters.
      IF p_person_id IS NULL  OR
         p_which_cp  NOT IN ('MAX_CP','MIN_CP') THEN
         RETURN NULL;
      END IF;

	  l_count := 0;
      --Getting the group id's for the given persons
      FOR rec_pig IN cur_pig
      LOOP

        l_cp_defined := FALSE;
        --Checking whether step defined for given person group.
        OPEN cur_cp(rec_pig.group_id);
        FETCH cur_cp INTO rec_cp;
        IF cur_cp%FOUND THEN
           l_cp_defined := TRUE;
           IF p_which_cp = 'MAX_CP'  THEN
              l_ret_value := rec_cp.prsid_max_cp;
           ELSE
              l_ret_value := rec_cp.prsid_min_cp;
           END IF;
        END IF;
        CLOSE cur_cp;

        --if step is defined more than one group id;
        IF l_cp_defined THEN
           l_count := l_count +1;
           IF l_count >1 THEN
              p_message := 'IGS_EN_MORE_PIG_SETUP';
              RETURN NULL;
           END IF;
        END IF;

      END LOOP;
      RETURN l_ret_value;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_val_pig.enrf_get_pig_cp');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END enrf_get_pig_cp;

  FUNCTION get_pig_notify_flag (p_step_type  IN VARCHAR2,
                                p_person_id  IN NUMBER,
                                p_message   OUT NOCOPY VARCHAR2)
  RETURN VARCHAR2 IS
  ------------------------------------------------------------------
  --Created by  : Kiran Killamsetty, Oracle IDC
  --Date created: 01-NOV-2002
  --
  --Purpose: Returns the step notification flag for a person  at
  -- person id group level.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --ptandon     07-JUL-2003     Modified the cursor cur_pig to select
  --                            only those Person ID Groups for which
  --                            the person has not been end-dated.
  --                            Bug# 3038825
  -------------------------------------------------------------------
  CURSOR cur_pig IS SELECT DISTINCT group_id
                    FROM igs_pe_prsid_grp_mem
                    WHERE person_id = p_person_id AND
		          TRUNC(SYSDATE) BETWEEN start_date AND NVL(end_date,TRUNC(SYSDATE));
  CURSOR cur_step(p_group_id       igs_pe_prsid_grp_mem.group_id%TYPE)
                  IS SELECT s_enrolment_step_type,notification_flag FROM igs_en_pig_s_setup
                                     WHERE group_id = p_group_id;
  l_count                   NUMBER:= 0;
  l_ret_value               NUMBER DEFAULT NULL;
  l_notification_flag       igs_en_pig_s_setup.notification_flag%TYPE;
  l_defined_step            BOOLEAN;
  BEGIN
      p_message := NULL;
      --Validating the input parameters.
      IF p_person_id IS NULL  OR
         p_step_type  IS NULL THEN
         RETURN NULL;
      END IF;

      --Getting the group id's for the given persons
      FOR rec_pig IN cur_pig
      LOOP
          --Checking whether step defined for given person group.
          l_defined_step := FALSE;
          FOR rec_step IN cur_step(rec_pig.group_id)
          LOOP
                 l_defined_step := TRUE;
                 IF rec_step.s_enrolment_step_type = p_step_type THEN
                     l_notification_flag:=rec_step.notification_flag;
                    EXIT; --cur_step
                 END IF;
          END LOOP;

          --if step is defined more than one group id;
          IF l_defined_step THEN
             l_count := l_count +1;
             IF l_count >1 THEN
                p_message := 'IGS_EN_MORE_PIG_SETUP';
                RETURN NULL;
             END IF;
          END IF;

      END LOOP;
      RETURN l_notification_flag;
  EXCEPTION
  	WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
		FND_MESSAGE.SET_TOKEN('NAME', 'igs_en_val_pig.get_pig_notify_flag');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  END get_pig_notify_flag;


END igs_en_val_pig;

/
