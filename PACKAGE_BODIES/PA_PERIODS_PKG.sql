--------------------------------------------------------
--  DDL for Package Body PA_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PERIODS_PKG" AS
/* $Header: PASUCPSB.pls 120.2.12010000.2 2008/09/16 09:14:43 svivaram ship $ */

  PROCEDURE copy_periods ( P_Org_Id      IN NUMBER DEFAULT NULL -- 12i MOAC changes
                         , x_rec_count  OUT NOCOPY NUMBER
                         , x_err_text   OUT NOCOPY VARCHAR2 )
  IS

    l_rec_count  NUMBER := 0;
    X_user_id    NUMBER(15);
    X_login_id   NUMBER(15);
    X_sob_id     NUMBER(15);
    x_stage      VARCHAR2(100);
    l_org_Id     NUMBER := nvl(P_Org_Id, pa_moac_utils.get_current_org_id); -- 12i MOAC changes


    --Bug 3065754
    l_imp_period_set_name pa_implementations_all.period_set_name%type;

    CURSOR NewPeriods
    IS
    SELECT
            period_name
    ,       start_date
    ,       end_date
    ,       gl_period_name
      FROM
            pa_periods_copy_v;

    BEGIN

      x_stage := 'SELECT FROM PA_IMPLEMENTATIONS';
      --Bug 3065754
      SELECT set_of_books_id, period_set_name
        INTO X_sob_id , l_imp_period_set_name
        FROM pa_implementations;

      X_user_id := fnd_global.user_id;
      X_login_id := fnd_global.login_id;

      FOR  xperiod  IN NewPeriods LOOP

        l_rec_count := l_rec_count + 1;

        x_stage := 'INSERT INTO PA_PERIODS';
        INSERT INTO pa_periods (
           period_name
        ,  last_update_date
        ,  last_updated_by
        ,  creation_date
        ,  created_by
        ,  last_update_login
        ,  start_date
        ,  end_date
        ,  status
        ,  gl_period_name
        ,  current_pa_period_flag
        ,  org_id ) -- 12i MOAC changes
        VALUES (
           xperiod.period_name
        ,  TRUNC(sysdate)
        ,  X_user_id
        ,  TRUNC(sysdate)
        ,  X_user_id
        ,  X_login_id
        ,  xperiod.start_date
        ,  xperiod.end_date
        ,  'N'    /* Never Opened */
        ,  xperiod.gl_period_name
        ,  NULL
        ,  l_org_id ); -- 12i MOAC changes

        x_stage := 'INSERT INTO GL_PERIOD_STATUSES';
        gl_period_statuses_pkg.insert_ps_api(
           275
        ,  X_sob_id
        ,  xperiod.period_name
        ,  'O'
        --Bug 3065754
        --,  NULL
        ,  l_imp_period_set_name
        ,  X_user_id
        ,  X_login_id );

/* Bug 2579245: Inserting record in gl_period_statuses*/
/*	gl_period_statuses_pkg.insert_ps_api(
           275
        ,  X_sob_id
        ,  xperiod.gl_period_name
        ,  'O'
        ,  NULL
        ,  X_user_id
        ,  X_login_id );  Bug# 3271356:reverting fix of 2579245*/


      END LOOP;

      IF ( l_rec_count > 0 ) THEN
        COMMIT;
      END IF;

      x_rec_count := l_rec_count;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      x_rec_count := 0;
      x_err_text := NULL;
    WHEN  OTHERS  THEN
      x_rec_count := SQLCODE;
      x_err_text :=  x_stage || ' - ' || SQLERRM(SQLCODE);

  END copy_periods;

  PROCEDURE copy_from_glperiods ( P_Org_ID      IN NUMBER DEFAULT NULL -- 12i MOAC changes
                                , x_rec_count  OUT NOCOPY NUMBER
                                , x_err_text   OUT NOCOPY VARCHAR2 )
  IS

    l_rec_count  NUMBER := 0;
    X_user_id    NUMBER(15);
    X_login_id   NUMBER(15);
    X_sob_id     NUMBER(15);
    x_stage      VARCHAR2(100);
    l_org_Id     NUMBER := nvl(P_Org_Id, pa_moac_utils.get_current_org_id); -- 12i MOAC changes

    CURSOR C_GlPeriods(p_sob_id in number)
    IS
    SELECT
            period_name
    ,       start_date
    ,       end_date
    ,       closing_status
      FROM
            gl_period_statuses gps
      WHERE gps.application_id = 8721
      and   gps.adjustment_period_flag = 'N'
      and   gps.set_of_books_id = p_sob_id
      and   not exists (
            SELECT NULL
            FROM PA_PERIODS pp
            WHERE PP.PERIOD_NAME = GPS.PERIOD_NAME );

    BEGIN

      x_stage := 'SELECT FROM PA_IMPLEMENTATIONS';
      SELECT set_of_books_id
        INTO X_sob_id
        FROM pa_implementations;

      X_user_id := fnd_global.user_id;
      X_login_id := fnd_global.login_id;

      FOR  xperiod  IN C_GlPeriods(X_sob_id) LOOP

        l_rec_count := l_rec_count + 1;

        x_stage := 'INSERT INTO PA_PERIODS';
        INSERT INTO pa_periods (
           period_name
        ,  last_update_date
        ,  last_updated_by
        ,  creation_date
        ,  created_by
        ,  last_update_login
        ,  start_date
        ,  end_date
        ,  status
        ,  gl_period_name
        ,  current_pa_period_flag
        ,  org_id) -- 12i MOAC changes
        VALUES (
           xperiod.period_name
        ,  TRUNC(sysdate)
        ,  X_user_id
        ,  TRUNC(sysdate)
        ,  X_user_id
        ,  X_login_id
        ,  xperiod.start_date
        ,  xperiod.end_date
        ,  xperiod.closing_status
        ,  xperiod.period_name
        ,  NULL
        ,  l_org_id); -- 12i MOAC changes

/*Bug# 3271356 :Reverted the fix of 2579245*/
/* Bug 2579245 : updating the status of gl_period to open */
/*	x_stage := 'UPDATE GL_PERIOD_STATUSES';
	UPDATE gl_period_statuses
	SET    closing_status = 'O'
	WHERE  application_id = 8721
	AND    set_of_books_id = X_sob_id
	AND    period_name = xperiod.period_name;  Commented for Bug 3271356*/

      END LOOP;

      IF ( l_rec_count > 0 ) THEN
        COMMIT;
      END IF;

      x_rec_count := l_rec_count;

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      x_rec_count := 0;
      x_err_text := NULL;
    WHEN  OTHERS  THEN
      x_rec_count := SQLCODE;
      x_err_text :=  x_stage || ' - ' || SQLERRM(SQLCODE);

  END copy_from_glperiods;

 /*****************************************************************************
  Bug# 3271356 :
  FUNCTION check_gl_period_used_in_pa :This is used by GL to prevent the user
   trying to manipulate the GL period name into which the PA periods falls.
  *****************************************************************************/

  FUNCTION check_gl_period_used_in_pa ( p_period_name     IN  VARCHAR2,
                                        p_period_set_name IN VARCHAR2)
    RETURN VARCHAR2  is

  l_temp        varchar2(1);
  l_period_name pa_periods_all.period_name%TYPE;

  l_pji_name    pji_time_cal_period.NAME%TYPE;

  l_rec_count   NUMBER;


  CURSOR period_cur IS
   SELECT  period_name
         FROM  PA_PERIODS_ALL prd,
               PA_IMPLEMENTATIONS_ALL imp,
               GL_SETS_OF_BOOKS sob
        WHERE  (period_name = p_period_name
           OR  gl_period_name = p_period_name)
          AND  prd.org_id  = imp.org_id           /* Removed the NVL check for bug 6811046*/
          AND  imp.set_of_books_id = sob.set_of_books_id
          AND  sob.period_set_name = p_period_set_name
          AND  rownum =1;

 BEGIN

  l_rec_count  := 1;

  Open period_cur;
  Fetch period_cur into l_period_name;

  If period_cur%NOTFOUND Then

      SELECT  COUNT(*)
        into  l_rec_count
         FROM  PA_PERIODS_ALL prd,
               PA_IMPLEMENTATIONS_ALL imp
        WHERE ( period_name = p_period_name
          OR  gl_period_name =p_period_name)
          AND  prd.org_id  = imp.org_id           /* Removed the NVL check for bug 6811046*/
          AND period_set_name = p_period_set_name --added this condition for the bug 4119508
          AND rownum =1;

  End if ;

  Close period_cur;


  /* Adding the condition to check GL period already extracted in PJI */


    IF  (l_rec_count = 0 )  THEN

     SELECT COUNT(*)
       INTO l_rec_count
       FROM fii_time_cal_name cal,
            pji_time_cal_period prd
      WHERE cal.period_set_name = p_period_set_name
        AND prd.name = p_period_name
        AND prd.calendar_id = cal.calendar_id
        AND ROWNUM =1;

    END IF;


    IF (l_rec_count = 0)   THEN

       RETURN ('N');

    else

       RETURN ('Y');

    END IF;

  EXCEPTION
  WHEN no_data_found THEN
    RETURN ('N');
  WHEN others THEN
    Raise;
  END check_gl_period_used_in_pa;
/*End of changes for Bug# 3271356 */

END pa_periods_pkg;

/
