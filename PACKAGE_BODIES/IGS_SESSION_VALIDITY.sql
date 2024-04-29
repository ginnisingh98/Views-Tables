--------------------------------------------------------
--  DDL for Package Body IGS_SESSION_VALIDITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_SESSION_VALIDITY" AS
/* $Header: IGSSS10B.pls 120.10 2006/08/24 07:33:01 bdeviset ship $ */

 g_icx_session_timeout NUMBER := NVL(fnd_profile.value('ICX_SESSION_TIMEOUT'), 0);

 FUNCTION validate_first_connect (p_first_connect DATE, p_limit_time NUMBER)
 /*
  ||  Change History :
  ||  Who             When            What
  ||
  ||  ckasu         23-Aug-2004     Modified If Condition inorder as a part of
  ||                                bug 3855996.
  */

 RETURN BOOLEAN IS
 BEGIN

  -- If the diffence between Current Login Time  and First connect time
  -- is greater than  Limit than the session is invalid

  IF ( ((SYSDATE - p_first_connect)*24*60*60) > p_limit_time*60*60 ) THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

 END validate_first_connect;

 FUNCTION validate_last_connect ( p_last_connect DATE)
 /*
  ||  Change History :
  ||  Who             When            What
  ||
  ||  ckasu         23-Aug-2004     Modified If Condition inorder as a part of
  ||                                bug 3855996.
  */

 RETURN BOOLEAN IS
 BEGIN

  -- If the diffence between Current Login Time  and Last connect time
  -- is greater than  icx_session_timeout than the session is invalid

  IF ( ((SYSDATE - p_last_connect)*24*60*60) >  g_icx_session_timeout*60  ) THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

 END validate_last_connect;

 /**
 This function checks the validity of an ICX_SESSION based on
  1. Record not found in the ICX_SESSION
  2. Disabled_flag
  3. ICX_SESSION_TIMEOUT, last_connect
  4. first_connect, limit_time
 */
 FUNCTION is_valid_session ( p_session_id NUMBER)
 RETURN BOOLEAN IS
  CURSOR session_cur IS
   SELECT
    first_connect,
    last_connect,
    limit_time,
    disabled_flag
   FROM
    icx_sessions
   WHERE
    session_id = p_session_id;
   session_rec session_cur%ROWTYPE;
 BEGIN
  OPEN session_cur;
  FETCH session_cur INTO session_rec;
  IF session_cur%NOTFOUND THEN
   CLOSE session_cur;
   RETURN FALSE;
  END IF;
  CLOSE session_cur;
  IF session_rec.disabled_flag = 'Y' THEN
   RETURN FALSE;
  END IF;
  IF g_icx_session_timeout = 0 THEN
   RETURN validate_first_connect ( session_rec.first_connect, session_rec.limit_time);
  ELSE
   RETURN validate_last_connect ( session_rec.last_connect);
  END IF;
 END is_valid_session;

 /**
 This procedure cleans all the enrollment worksheet records that are added in
 the previous sessions that are no longer valid
 */
 PROCEDURE clean_enroll_wrksht IS
 /*
  ||  Change History :
  ||  Who             When            What
  ||
  ||  ckasu         23-Aug-2004     Added the If condition inorder to retain
  ||                                the Units added to Enrollment cart when
  ||                                the profile value is set 'N' as a part of
  ||                                bug 3847480.
  ||  sgurusam      07-Jun-2005     EN317 Enhnacement
  ||  svanukur      20-sep-2005     Added logic to rollback deletion of unit in case of exception, EN317 build
  ||  bdeviset      24-mar-2006     Modified so that the profile purge cart is used only for admin as
  ||                                per bug# 5083862
  ||  bdeviset      08-jn-2006      Modified such that in all the cases planning sheet error records/swap records are deleted.
                                    For student irrespective of the profile cart units are also purged but for admin it is
                                    done based on the profile. bug# 5306874
  */

 PRAGMA AUTONOMOUS_TRANSACTION;
  /**
  Cursor to select all the records which are added through the self service page
  and are still in the enrollment worksheet
  */

  CURSOR all_sessions_cur IS
   SELECT
    DISTINCT session_id
   FROM
    igs_en_su_attempt_all
   WHERE
    cart = 'S';

  /**
  Cursor to select the enrollment worksheet records which are added in a session, not valid
  anymore
  */

  CURSOR unit_attempt_del_cur (c_session_id NUMBER) IS
   SELECT
    rowid row_id, person_id
   FROM
    igs_en_su_attempt_all
   WHERE
    session_id = c_session_id AND
    cart = 'S'
  ORDER BY sup_unit_cd ASC;

  l_ispurgeenabled VARCHAR2(3);

  /**
  Cursor to select the enrollment worksheet records which are added in a session by a student, not valid
  anymore
  */

  CURSOR std_unit_attempt_del_cur (c_session_id NUMBER) IS
   SELECT
    rowid row_id, person_id
   FROM
    igs_en_su_attempt_all
   WHERE
    session_id = c_session_id AND
    cart = 'S' AND
    ss_source_ind <> 'A'
  ORDER BY sup_unit_cd ASC;

  /**
  Cursor to select all the records which are added through the self service page
   and are still in the enrollment worksheet except for the records added by admin
  */
  CURSOR all_stud_sessions_cur IS
   SELECT
    DISTINCT session_id
   FROM
    igs_en_su_attempt_all
   WHERE cart = 'S'
   AND ss_source_ind <> 'A';

  /**
  Cursor to select all the distinct session ids of cart, created from planned sheet and swap page.
  */
  CURSOR c_stud_cart_ses IS
    SELECT DISTINCT session_id
    FROM   igs_en_su_attempt
    WHERE  cart = 'S'
    AND    ss_source_ind IN ('P','S');

  /**
  Cursor to select details of the cart, created from planned sheet and swap page.
  */
  CURSOR c_stud_cart_row (p_session_id igs_en_su_attempt.session_id%TYPE) IS
    SELECT a.rowid, a.person_id,a.course_cd, a.uoo_id, a.ss_source_ind
    FROM   igs_en_su_attempt a
    WHERE  a.cart = 'S'
    AND    a.ss_source_ind IN ('P','S')
    AND    a.session_id  = p_session_id
    ORDER BY a.sup_unit_cd asc;

  /**
  Cursor to select rowid of error carts for deleting.
  */
  CURSOR c_plan_error( p_session_id igs_en_plan_units.session_id%TYPE,
                       p_person_id  igs_en_plan_units.person_id%TYPE,
                       p_course_cd  igs_en_plan_units.course_cd%TYPE,
                       p_uoo_id     igs_en_plan_units.uoo_id%TYPE ) IS
    SELECT ROWID
    FROM   igs_en_plan_units
    WHERE  person_id       = p_person_id
    AND    course_cd       = p_course_cd
    AND    uoo_id          = p_uoo_id
    AND    cart_error_flag = 'Y'
    AND    session_id      = p_session_id;

  /**
  Cursor to select value of term_cal_type and term_ci_sequence_number.
  */
  CURSOR c_cal_type( p_person_id  igs_en_plan_units.person_id%TYPE,
                     p_course_cd  igs_en_plan_units.course_cd%TYPE,
                     p_uoo_id     igs_en_plan_units.uoo_id%TYPE ) IS
    SELECT term_cal_type, term_ci_sequence_number
    FROM   igs_en_plan_units
    WHERE  person_id       = p_person_id
    AND    course_cd       = p_course_cd
    AND    uoo_id          = p_uoo_id;

    /*
    curosor to select warnings of invalid sessions
    */
    CURSOR c_stud_warn_row(p_session_id IGS_EN_STD_WARNINGS.SESSION_ID%type) is
    SELECT rowid
    from IGS_EN_STD_WARNINGS
    where SESSION_ID = p_session_id;

    -- added by ckasu as a part of bug#4673919

    CURSOR all_plan_session IS
    SELECT DISTINCT session_id
    FROM   igs_en_plan_units
    WHERE  cart_error_flag= 'Y';

    CURSOR c_get_all_plan_error_units(p_session_id IGS_EN_PLAN_UNITS.SESSION_ID%TYPE) IS
    SELECT ROWID
    FROM igs_en_plan_units
    WHERE session_id = p_session_id
    AND   cart_error_flag = 'Y';

    l_purge_admin_cart BOOLEAN;

  BEGIN

  -- delete unit attempts taken by swap, plan and student for invalida sessions

  FOR c_stud_cart_ses_rec IN c_stud_cart_ses LOOP
     -- if a unit attempt created by planning sheet is being deleted then the
     -- planning sheet should be re-instated if it was already submitted.

     IF NOT is_valid_session (c_stud_cart_ses_rec.session_id) THEN

       FOR c_stud_warn_rec in c_stud_warn_row(c_stud_cart_ses_rec.session_id) LOOP

        BEGIN
        SAVEPOINT SP_WARN_REC;

        IGS_EN_STD_WARNINGS_PKG.delete_row(x_rowid =>c_stud_warn_rec.rowid );

        EXCEPTION
         WHEN OTHERS THEN
         ROLLBACK TO SP_WARN_REC;
         NULL; --suppress the exception if any, since we are only trying to clear the warnings
        END;

       END LOOP; -- c_stud_cart_ses_rec



       FOR c_stud_cart_rec IN c_stud_cart_row (c_stud_cart_ses_rec.session_id) LOOP
         --create a savepoint here and rollback in case of errors, since an error in this package
         --will prevent user from even logging in

         BEGIN
         SAVEPOINT SP_CART_REC;

                -- Delete the cart record
                igs_en_su_attempt_pkg.delete_row (c_stud_cart_rec.rowid);

                IF  c_stud_cart_rec.ss_source_ind = 'P' THEN
                 -- If there exists a term record with planning sheet marked as
                     -- submited for this unit attempt, then update that term record to PLAN.

                     --This loop is executed only once
                    FOR c_cal_type_rec IN c_cal_type (c_stud_cart_rec.person_id,
                                              c_stud_cart_rec.course_cd,
                                              c_stud_cart_rec.uoo_id)
                    LOOP

                        UPDATE  igs_en_spa_terms spa SET spa.plan_sht_status = 'PLAN'
                        WHERE   spa.plan_sht_status                      = 'SUB_PLAN'
                         AND     spa.person_id                          = c_stud_cart_rec.person_id
                         AND     spa.program_cd                         = c_stud_cart_rec.course_cd
                         AND     spa.term_cal_type                      = c_cal_type_rec.term_cal_type
                         AND     spa.term_sequence_number               = c_cal_type_rec.term_ci_sequence_number
	                     AND    EXISTS ( SELECT pl.uoo_id FROM igs_en_plan_units pl WHERE pl.person_id=spa.person_id AND pl.course_cd = spa.program_cd AND
				        pl.term_cal_type = spa.term_cal_type  AND pl.term_ci_sequence_number = spa.term_sequence_number AND  pl.uoo_id =c_stud_cart_rec.uoo_id);

                         -- After updating exit the loop.
                        EXIT;
                    END LOOP;

                    -- delete planning sheet cart error records for the cart being deleted above
                    FOR c_plan_error_rec IN c_plan_error (c_stud_cart_ses_rec.session_id,
                                                  c_stud_cart_rec.person_id,
                                                  c_stud_cart_rec.course_cd,
                                                  c_stud_cart_rec.uoo_id)
                    LOOP
                        igs_en_plan_units_pkg.delete_row(c_plan_error_rec.rowid) ;
                    END LOOP;

                END IF;
         EXCEPTION
         WHEN OTHERS THEN
         ROLLBACK TO SP_CART_REC;
         NULL; --suppress the exception if any, since we are only trying to clear the cart
         END;
       END LOOP; -- c_stud_cart_rec

     END IF; -- isValidSession

  END LOOP; -- c_stud_cart_ses_rec

  l_purge_admin_cart := FALSE;
  l_ispurgeenabled := FND_PROFILE.VALUE('IGS_PURGE_ENROLLMENT_CART');

   IF l_ispurgeenabled = 'Y' THEN
      l_purge_admin_cart := TRUE;
   END IF;

  -- planning sheet error records cant figured out whether they
  -- are created by admin or student.So purging them.

   -- code added by ckasu as a part of bug#4673919

   FOR all_plan_session_rec IN all_plan_session LOOP

       IF  NOT is_valid_session ( all_plan_session_rec.session_id) THEN

           FOR c_get_all_plan_error_units_rec IN c_get_all_plan_error_units(all_plan_session_rec.session_id) LOOP

              BEGIN

                SAVEPOINT SP_PLAN_ERROR_REC;
                igs_en_plan_units_pkg.delete_row(c_get_all_plan_error_units_rec.rowid);


              EXCEPTION
              WHEN OTHERS THEN
                   ROLLBACK TO SP_PLAN_ERROR_REC;
                   NULL; --suppress the exception if any, since we are only trying to clear the warnings
              END;

           END LOOP; -- end of FOR c_get_all_plan_error_units_rec IN c_get_all_plan_error_units LOOP

           FOR c_stud_warn_rec in c_stud_warn_row(all_plan_session_rec.session_id) LOOP

              BEGIN

                SAVEPOINT SP_WARN_REC;

                IGS_EN_STD_WARNINGS_PKG.delete_row(x_rowid =>c_stud_warn_rec.rowid );

              EXCEPTION
              WHEN OTHERS THEN
                   ROLLBACK TO SP_WARN_REC;
                   NULL; --suppress the exception if any, since we are only trying to clear the warnings
              END;

           END LOOP; -- end of c_stud_warn_rec in c_stud_warn_row(c_stud_cart_ses_rec.session_id) LOOP


       END IF; -- end of IF  NOT is_valid_session ( all_plan_session_rec.session_id) THEN

   END LOOP; -- end of FOR all_plan_session_rec IN all_plan_session LOOP

   -- end of code added by ckasu as a part of bug#4673919

   IF l_purge_admin_cart THEN
  -- if the profile is set delete all the inactive cart records

     FOR all_sessions_rec IN all_sessions_cur LOOP

      IF NOT is_valid_session ( all_sessions_rec.session_id) THEN

              FOR c_stud_warn_rec in c_stud_warn_row(all_sessions_rec.session_id) LOOP

                  BEGIN
                  SAVEPOINT SP_WARN_REC;

                  IGS_EN_STD_WARNINGS_PKG.delete_row(x_rowid =>c_stud_warn_rec.rowid );

                  EXCEPTION
                   WHEN OTHERS THEN
                   ROLLBACK TO SP_WARN_REC;
                   NULL; --suppress the exception if any, since we are only trying to clear the warnings
                   END;

               END LOOP; -- end of FOR c_stud_warn_rec in c_stud_warn_row(all_sessions_rec.session_id) LOOP

               FOR unit_attempt_del_rec IN unit_attempt_del_cur ( all_sessions_rec.session_id) LOOP
                BEGIN
                  SAVEPOINT SP_SESSION_VAL_SUA_DEL;
                  igs_en_su_attempt_pkg.delete_row ( unit_attempt_del_rec.row_id);

                EXCEPTION
                  WHEN OTHERS THEN
                   ROLLBACK TO SP_SESSION_VAL_SUA_DEL;
                   NULL; --suppress the exception if any, since we are only trying to clear the cart
                END;
               END LOOP; -- end of FOR unit_attempt_del_rec IN unit_attempt_del_cur ( all_sessions_rec.session_id) LOOP

      END IF; -- end of  IF NOT is_valid_session ( all_sessions_rec.session_id) THEN

     END LOOP; -- end of FOR all_sessions_rec IN all_sessions_cur LOOP

  ELSE
  -- if the profile is not set delete all the inactive cart records created by student

    FOR all_stud_sessions_rec IN all_stud_sessions_cur LOOP

      IF NOT is_valid_session ( all_stud_sessions_rec.session_id) THEN

              FOR c_stud_warn_rec in c_stud_warn_row(all_stud_sessions_rec.session_id) LOOP

                  BEGIN
                  SAVEPOINT SP_WARN_REC;

                  IGS_EN_STD_WARNINGS_PKG.delete_row(x_rowid =>c_stud_warn_rec.rowid );

                  EXCEPTION
                   WHEN OTHERS THEN
                   ROLLBACK TO SP_WARN_REC;
                   NULL; --suppress the exception if any, since we are only trying to clear the warnings
                   END;

               END LOOP; -- end of FOR c_stud_warn_rec in c_stud_warn_row(all_sessions_rec.session_id) LOOP

               FOR std_unit_attempt_del_rec IN std_unit_attempt_del_cur ( all_stud_sessions_rec.session_id) LOOP
                BEGIN
                  SAVEPOINT SP_SESSION_VAL_SUA_DEL;
                  igs_en_su_attempt_pkg.delete_row ( std_unit_attempt_del_rec.row_id);

                EXCEPTION
                  WHEN OTHERS THEN
                   ROLLBACK TO SP_SESSION_VAL_SUA_DEL;
                   NULL; --suppress the exception if any, since we are only trying to clear the cart
                END;
               END LOOP; -- end of FOR std_unit_attempt_del_rec IN unit_attempt_del_cur ( all_sessions_rec.session_id) LOOP

      END IF; -- end of  IF NOT is_valid_session ( all_sessions_rec.session_id) THEN

     END LOOP; -- end of FOR all_sessions_rec IN all_sessions_cur LOOP

  END IF;


   -- this has been added to commit this transaction
   -- if it not committed here then  a lock is aquired by the
   -- IgsApplication module which is the root AM on the table
   -- and from there on, no transaction can be performed on this table
   -- hence runing this procedure in an autonomous transaction.
   -- commiting the same
   --amuthu 3-APR-2002
   COMMIT;
  END clean_enroll_wrksht;
END igs_session_validity;

/
