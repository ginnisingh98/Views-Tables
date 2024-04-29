--------------------------------------------------------
--  DDL for Package Body GL_PERIOD_STATUSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_PERIOD_STATUSES_PKG" AS
/* $Header: glipstab.pls 120.11.12010000.2 2009/09/18 06:21:33 akhanapu ship $ */

--
-- PRIVATE FUNCTIONS
--

  PROCEDURE check_for_gap (
    x_periodsetname  IN    VARCHAR2,
    x_periodtype     IN    VARCHAR2 ) IS

    not_assigned CONSTANT VARCHAR2(15) := 'NOT ASSIGNED';

    gap_date   DATE;
    start_date DATE;
    end_date   DATE;
    beginning  DATE;
    ending     DATE;

    CURSOR period_set IS
      SELECT min(start_date) begins, max(end_date) ends
      FROM gl_periods
      WHERE period_set_name = x_periodsetname
      AND   period_type     = x_periodtype;

    CURSOR gap_exists IS
      SELECT accounting_date
      FROM gl_date_period_map
      WHERE period_name     = not_assigned
      AND   period_set_name = x_periodsetname
      AND   period_type     = x_periodtype
      AND   accounting_date BETWEEN beginning AND ending;

    CURSOR gap_start IS
      SELECT max(accounting_date)
      FROM gl_date_period_map
      WHERE period_name    <> not_assigned
      AND   period_set_name = x_periodsetname
      AND   period_type     = x_periodtype
      AND   accounting_date < gap_date;

    CURSOR gap_end IS
      SELECT min(accounting_date)
      FROM gl_date_period_map
      WHERE period_name    <> not_assigned
      AND   period_set_name = x_periodsetname
      AND   period_type     = x_periodtype
      AND   accounting_date > gap_date;

 BEGIN
    -- Open the gap_exists cursor and see if we get anything
    OPEN period_set;
    FETCH period_set INTO beginning, ending;
    CLOSE period_set;
    OPEN gap_exists;
    FETCH gap_exists INTO gap_date;
    IF gap_exists%NOTFOUND THEN
      CLOSE gap_exists;
    ELSE
      CLOSE gap_exists;
      -- Get the spanning dates
      OPEN gap_start;
      FETCH gap_start INTO start_date;
      CLOSE gap_start;
      OPEN gap_end;
      FETCH gap_end INTO end_date;
      CLOSE gap_end;
      -- Tell the user
      fnd_message.set_name('SQLGL', 'GL_GAP_IN_CALENDAR');
      fnd_message.set_token('CALENDAR_NAME', x_periodsetname);
      fnd_message.set_token('START_DATE', nvl(start_date, beginning));
      fnd_message.set_token('END_DATE', nvl(end_date, ending));
      RAISE app_exceptions.application_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.check_for_gap');
      RAISE;
  END check_for_gap;


--
-- PUBLIC FUNCTIONS
--

  FUNCTION default_actual_period(acc_id NUMBER,
                                 led_id NUMBER) RETURN VARCHAR2 IS
    CURSOR get_latest_opened IS
      SELECT ps.period_name
      FROM   gl_period_statuses ps,
             gl_access_set_ledgers acc
      WHERE  ps.application_id = 101
      AND    ps.ledger_id = led_id
      AND    ps.closing_status = 'O'
      AND    acc.access_set_id = acc_id
      AND    acc.ledger_id = ps.ledger_id
      AND    acc.access_privilege_code IN ('B','F')
      AND    ps.end_date between nvl(acc.start_date, ps.end_date-1)
                         and nvl(acc.end_date, ps.end_date+1)
      ORDER BY effective_period_num DESC;

    CURSOR get_earliest_future_ent IS
      SELECT ps.period_name
      FROM   gl_period_statuses ps,
             gl_access_set_ledgers acc
      WHERE  ps.application_id = 101
      AND    ps.ledger_id = led_id
      AND    ps.closing_status = 'F'
      AND    acc.access_set_id = acc_id
      AND    acc.ledger_id = ps.ledger_id
      AND    acc.access_privilege_code IN ('B','F')
      AND    ps.end_date between nvl(acc.start_date, ps.end_date-1)
                         and nvl(acc.end_date, ps.end_date+1)
      ORDER BY effective_period_num ASC;
    default_period VARCHAR2(15);
  BEGIN
    OPEN get_latest_opened;
    FETCH get_latest_opened INTO default_period;

    IF get_latest_opened%FOUND THEN
      CLOSE get_latest_opened;
      return(default_period);
    ELSE
      CLOSE get_latest_opened;

      OPEN get_earliest_future_ent;
      FETCH get_earliest_future_ent INTO default_period;

      IF get_earliest_future_ent%FOUND THEN
        CLOSE get_earliest_future_ent;
        return(default_period);
      ELSE
        CLOSE get_earliest_future_ent;
        fnd_message.set_name('SQLGL', 'GL_NO_OPEN_OR_FUTURE_PERIODS');
        return(null);
      END IF;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.default_actual_period');
      RAISE;
  END default_actual_period;

PROCEDURE get_next_period(
        x_ledger_id       NUMBER,
        x_period                VARCHAR2,
        x_next_period   IN OUT NOCOPY  VARCHAR2 )  IS

  CURSOR c_period IS
    SELECT ps1.period_name
    FROM   gl_period_statuses ps1,
           gl_period_statuses ps2
    WHERE  ps1.application_id = 101
    AND    ps1.ledger_id = x_ledger_id
    AND    ps2.application_id = 101
    AND    ps2.ledger_id = x_ledger_id
    AND    ps2.period_name = x_period
    AND    ( ps1.start_date =
               ( SELECT MIN( ps3.start_date )
                 FROM   gl_period_statuses ps3
                 WHERE  ps3.application_id = 101
                 AND    ps3.ledger_id = x_ledger_id
                 AND    ps3.start_date > ps2.start_date ) )
    AND     ps1.closing_status NOT IN ( 'N','C','P' );

  BEGIN
    OPEN c_period;
    FETCH c_period INTO x_next_period;
    CLOSE c_period;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.get_next_period');
      RAISE;

  END get_next_period;



  PROCEDURE insert_led_ps(
                        x_ledger_id       NUMBER,
                        x_period_set_name       VARCHAR2,
                        x_accounted_period_type VARCHAR2,
                        x_last_update_date      DATE,
                        x_last_updated_by       NUMBER,
                        x_last_update_login     NUMBER,
                        x_creation_date         DATE,
                        x_created_by            NUMBER ) IS
  BEGIN

    -- Before doing anything else...
    check_for_gap(x_period_set_name, x_accounted_period_type);

    LOCK TABLE GL_PERIOD_STATUSES IN SHARE UPDATE MODE;

    INSERT INTO GL_PERIOD_STATUSES
    ( application_id,
      ledger_id,
      set_of_books_id,
      period_name,
      closing_status,
      start_date,
      end_date,
      period_type,
      period_year,
      period_num,
      quarter_num,
      last_update_date,
      last_updated_by,
      last_update_login,
      creation_date,
      created_by,
      adjustment_period_flag,
      quarter_start_date,
      year_start_date,
      effective_period_num,
      migration_status_code)
    SELECT
      ag.application_id,
      x_ledger_id,
      x_ledger_id,
      p.period_name,
      'N',
      p.start_date,
      p.end_date,
      p.period_type,
      p.period_year,
      p.period_num,
      p.quarter_num,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_creation_date,
      x_created_by,
      p.adjustment_period_flag,
      p.quarter_start_date,
      p.year_start_date,
      p.period_year*10000 + p.period_num,
      'N'
    FROM
      GL_APPLICATION_GROUPS ag,
      GL_PERIODS p
    WHERE p.period_set_name = x_period_set_name
    AND   p.period_type = x_accounted_period_type
    AND   ag.group_name = 'PERIOD_STATUS'
    AND   EXISTS ( SELECT 'Application Installed'
                   FROM   FND_PRODUCT_INSTALLATIONS pr
		   WHERE  pr.application_id = ag.application_id );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.insert_led_ps');
      RAISE;

  END insert_led_ps;


  PROCEDURE insert_ps_api( x_appl_id               NUMBER,
                           x_ledger_id       NUMBER,
                           x_period_name           VARCHAR2,
                           x_status                VARCHAR2,
                           x_period_set_name       VARCHAR2,
			   x_user_id               NUMBER,
			   x_login_id              NUMBER ) IS


  BEGIN

    LOCK TABLE GL_PERIOD_STATUSES IN SHARE UPDATE MODE;

    INSERT INTO GL_PERIOD_STATUSES
    ( application_id,
      ledger_id,
      set_of_books_id,
      period_name,
      closing_status,
      start_date,
      end_date,
      period_type,
      period_year,
      period_num,
      quarter_num,
      last_update_date,
      last_updated_by,
      last_update_login,
      creation_date,
      created_by,
      adjustment_period_flag,
      quarter_start_date,
      year_start_date,
      effective_period_num,
      migration_status_code)
    SELECT
      x_appl_id,
      x_ledger_id,
      x_ledger_id,
      x_period_name,
      x_status,
      GP.start_date,
      GP.end_date,
      GP.period_type,
      GP.period_year,
      GP.period_num,
      GP.quarter_num,
      sysdate,
      x_user_id,
      x_login_id,
      sysdate,
      x_user_id,
      GP.adjustment_period_flag,
      GP.quarter_start_date,
      GP.year_start_date,
      GP.period_year*10000 + GP.period_num,
      'N'
    FROM
      GL_PERIODS GP,
      GL_LEDGERS LD
    WHERE GP.period_set_name =  nvl(x_period_set_name, LD.period_set_name)
    AND   GP.period_name = x_period_name
    AND   LD.ledger_id = x_ledger_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE;
    WHEN DUP_VAL_ON_INDEX THEN
      NULL;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.insert_ps_api');
      RAISE;

  END insert_ps_api;


  PROCEDURE insert_period(
			x_calendar_name		VARCHAR2,
                      	x_period_name 		VARCHAR2,
			x_start_date		DATE,
			x_end_date		DATE,
 			x_period_type 		VARCHAR2,
                     	x_period_year 		NUMBER,
                       	x_period_num  		NUMBER,
			x_quarter_num 		NUMBER,
			x_adj_period_flag 	VARCHAR2,
			x_last_updated_by	NUMBER,
			x_last_update_login	NUMBER,
			x_quarter_start_date	DATE,
      			x_year_start_date	DATE) IS

l_Effective_period_num GL_PERIOD_STATUSES.effective_period_num%type;
l_track_bc_ytd_flag GL_PERIOD_STATUSES.track_bc_ytd_flag%type;
l_sob_id GL_PERIOD_STATUSES.ledger_id%type;

CURSOR c_period_statuses IS
SELECT  track_bc_ytd_flag, set_of_books_id
FROM gl_period_statuses
WHERE application_id = 101
AND set_of_books_id in (SELECT ledger_id
					     FROM gl_ledgers
					     WHERE period_set_name = x_calendar_name
					     AND   accounted_period_type = x_period_type)
AND effective_period_num = l_Effective_period_num;

  BEGIN

  SELECT max(effective_period_num)
   INTO l_Effective_period_num
   FROM gl_period_statuses
   WHERE application_id = 101
   AND set_of_books_id in (
                                              SELECT ledger_id
					      FROM gl_ledgers
					      WHERE period_set_name = x_calendar_name
					      AND   accounted_period_type = x_period_type);

    INSERT INTO GL_PERIOD_STATUSES
    ( application_id,
      ledger_id,
      set_of_books_id,
      period_name,
      closing_status,
      start_date,
      end_date,
      period_type,
      period_year,
      period_num,
      quarter_num,
      last_update_date,
      last_updated_by,
      last_update_login,
      creation_date,
      created_by,
      adjustment_period_flag,
      quarter_start_date,
      year_start_date,
      effective_period_num,
      migration_status_code)
    SELECT
      ag.application_id,
      led.ledger_id,
      led.ledger_id,
      x_period_name,
      'N',
      x_start_date,
      x_end_date,
      x_period_type,
      x_period_year,
      x_period_num,
      x_quarter_num,
      sysdate,
      x_last_updated_by,
      x_last_update_login,
      sysdate,
      x_last_updated_by,
      x_adj_period_flag,
      x_quarter_start_date,
      x_year_start_date,
      x_period_year * 10000 + x_period_num,
      'N'
    FROM
      GL_APPLICATION_GROUPS ag,
      GL_LEDGERS led
    WHERE ag.group_name = 'PERIOD_STATUS'
    AND   led.period_set_name = x_calendar_name
    AND   led.accounted_period_type = x_period_type
    AND   EXISTS ( SELECT 'Application Installed'
                   FROM   FND_PRODUCT_INSTALLATIONS pr
		   WHERE  pr.application_id = ag.application_id );

     OPEN c_period_statuses;
	LOOP
		FETCH c_period_statuses
		INTO l_track_bc_ytd_flag,l_sob_id;
		EXIT WHEN c_period_statuses%NOTFOUND ;

		IF l_track_bc_ytd_flag IS NOT NULL AND l_track_bc_ytd_flag = 'Y'  THEN

			UPDATE gl_period_statuses
			SET track_bc_ytd_flag = 'Y'
			WHERE application_id = 101
			AND set_of_books_id = l_sob_id
			AND period_year=x_period_year
			AND  period_num=x_period_num;

		END IF;
	END LOOP;
     CLOSE c_period_statuses;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.insert_period');
      RAISE;
  END insert_period;


  PROCEDURE update_period(
			x_calendar_name		VARCHAR2,
 			x_old_period_name	VARCHAR2,
                      	x_period_name 		VARCHAR2,
			x_start_date		DATE,
			x_end_date		DATE,
 			x_period_type 		VARCHAR2,
                     	x_period_year 		NUMBER,
                       	x_period_num  		NUMBER,
			x_quarter_num 		NUMBER,
			x_adj_period_flag 	VARCHAR2,
			x_last_updated_by	NUMBER,
			x_last_update_login	NUMBER) IS
  BEGIN

    UPDATE GL_PERIOD_STATUSES ps
    SET    ps.period_name = x_period_name,
           ps.start_date  = x_start_date,
           ps.end_date    = x_end_date,
           ps.period_type = x_period_type,
           ps.period_year = x_period_year,
           ps.quarter_num = x_quarter_num,
           ps.period_num  = x_period_num,
           ps.adjustment_period_flag = x_adj_period_flag,
           ps.last_update_date  = sysdate,
           ps.last_updated_by   = x_last_updated_by,
           ps.last_update_login = x_last_update_login,
           ps.effective_period_num = x_period_year * 10000 + x_period_num
  WHERE  ps.period_name = x_old_period_name
  AND    ps.ledger_id IN
         ( SELECT led.ledger_id
           FROM   GL_LEDGERS led
           WHERE  led.period_set_name = x_calendar_name );

  exception
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.update_period');
      RAISE;
  END update_period;


  PROCEDURE delete_period(
		x_calendar_name		VARCHAR2,
 		x_old_period_name	VARCHAR2) IS
  BEGIN
    DELETE gl_period_statuses ps
    WHERE  ps.period_name = x_old_period_name
    AND    ps.ledger_id in
           (SELECT led.ledger_id
            FROM   gl_ledgers led
            WHERE  led.period_set_name = x_calendar_name);

  exception
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.delete_period');
      RAISE;
  END delete_period;


  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_period_statuses%ROWTYPE )  IS
  BEGIN
    SELECT  *
    INTO    recinfo
    FROM    gl_period_statuses
    WHERE   application_id = recinfo.application_id
    AND     ledger_id = recinfo.ledger_id
    AND     period_name = recinfo.period_name ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.select_row');
      RAISE;
  END select_row;


  PROCEDURE select_columns(
              x_application_id            NUMBER,
              x_ledger_id           NUMBER,
              x_period_name               VARCHAR2,
              x_closing_status    IN OUT NOCOPY  VARCHAR2,
              x_start_date        IN OUT NOCOPY  DATE,
              x_end_date          IN OUT NOCOPY  DATE,
              x_period_num        IN OUT NOCOPY  NUMBER,
              x_period_year       IN OUT NOCOPY  NUMBER ) IS
    recinfo gl_period_statuses%ROWTYPE;
  BEGIN
    recinfo.application_id := x_application_id;
    recinfo.ledger_id := x_ledger_id;
    recinfo.period_name := x_period_name;
    select_row( recinfo );
    x_closing_status := recinfo.closing_status;
    x_start_date := recinfo.start_date;
    x_end_date := recinfo.end_date;
    x_period_num := recinfo.period_num;
    x_period_year := recinfo.period_year;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.select_columns');
      RAISE;
  END select_columns;


  PROCEDURE initialize_period_statuses(
              x_application_id            NUMBER,
              x_ledger_id           NUMBER,
              x_period_year               NUMBER,
              x_period_num                NUMBER,
              x_user_id                   NUMBER )  IS

    v_fut_ent_periods_limit   NUMBER(15);
    v_num_periods_updated     NUMBER(15);
    v_period_type             VARCHAR2(15);

  BEGIN
    select led.future_enterable_periods_limit,
           led.accounted_period_type
    into   v_fut_ent_periods_limit,
           v_period_type
    from   gl_ledgers led
    where  led.ledger_id = x_ledger_id;

    update gl_period_statuses ps
       set ps.closing_status =
            decode(ps.period_year, x_period_year,
                   decode(ps.period_num, x_period_num,'O',
                          'F'),
                    'F'),
           ps.last_update_date = sysdate,
           ps.last_updated_by = x_user_id
     where ps.ledger_id = x_ledger_id
       and ps.application_id = x_application_id
       and ps.period_name in
           (select period_name
              from gl_period_statuses ps1,
                   gl_period_types pt
             where v_period_type = pt.period_type
               and ps1.application_id        = x_application_id
               and ps1.ledger_id       = x_ledger_id
               and ps1.period_type           = pt.period_type
               and ((ps1.period_year * pt.number_per_fiscal_year +
                     ps1.period_num) >=
                    (x_period_year * pt.number_per_fiscal_year +
                     x_period_num)
                   and (ps1.period_year * pt.number_per_fiscal_year +
                        ps1.period_num) <=
                       (x_period_year * pt.number_per_fiscal_year +
                        x_period_num +
                        v_fut_ent_periods_limit))) ;

    -- Count the number of periods updated
    v_num_periods_updated := SQL%ROWCOUNT;

    -- If some future enterable periods are not yet defined,
    -- raise an error
    IF (v_num_periods_updated <> (v_fut_ent_periods_limit + 1)) THEN
      fnd_message.set_name('SQLGL', 'GL_MISSING_FUT_ENT_PERIODS');
      RAISE NO_DATA_FOUND;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_period_statuses_pkg.initialize_period_statuses');
      RAISE;
  END initialize_period_statuses;

PROCEDURE select_encumbrance_periods(
	x_application_id			NUMBER,
        x_ledger_id       		NUMBER,
	x_first_period			IN OUT NOCOPY	VARCHAR2,
	x_first_period_start_date	IN OUT NOCOPY	DATE,
	x_second_period			IN OUT NOCOPY	VARCHAR2,
	x_second_period_year		IN OUT NOCOPY	NUMBER,
	x_second_period_start_date	IN OUT NOCOPY	DATE)  IS

  CURSOR c_period IS
    SELECT 	PS1.period_name,
   	    	PS1.start_date,
       		PS2.period_name,
       		PS2.period_year,
       		PS2.start_date
    FROM   	GL_LEDGERS LED,
       		GL_PERIOD_STATUSES PS1,
       		GL_PERIOD_STATUSES PS2,
       		GL_PERIOD_TYPES GPT
    WHERE  	PS1.application_id = x_application_id
    AND    	PS1.closing_status || '' in ('C', 'P')
    AND    	PS1.ledger_id = x_ledger_id
    AND    	PS1.period_type = GPT.period_type
    AND         PS1.period_year * GPT.number_per_fiscal_year +
		PS1.period_num + 1
       		= PS2.period_year * GPT.number_per_fiscal_year + PS2.period_num
    AND    	PS2.application_id = x_application_id
    AND    	PS2.ledger_id = x_ledger_id
    AND    	PS2.period_num = 1
    AND    	LED.ledger_id = x_ledger_id
    AND         PS2.period_year <= LED.latest_encumbrance_year;

  BEGIN
    OPEN c_period;
    FETCH c_period INTO x_first_period,
			x_first_period_start_date,
			x_second_period,
			x_second_period_year,
			x_second_period_start_date;
    CLOSE c_period;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                        'gl_period_statuses_pkg.select_encumbrance_periods');
      RAISE;

  END select_encumbrance_periods;


PROCEDURE select_prior_year_1st_period(
        x_application_id                        NUMBER,
        x_ledger_id                       NUMBER,
	x_period_year				NUMBER,
	x_period_name		IN OUT NOCOPY		VARCHAR2) IS

  CURSOR c_period IS
    SELECT 	period_name
    FROM   	GL_PERIOD_STATUSES
    WHERE  	application_id = x_application_id
    AND    	ledger_id = x_ledger_id
    AND         period_year = x_period_year - 1
    AND         period_num = (SELECT min(period_num)
                     FROM   GL_PERIOD_STATUSES
                     WHERE  application_id = x_application_id
                     AND    ledger_id = x_ledger_id
                     AND    period_year = x_period_year - 1);

  BEGIN
    OPEN c_period;
    FETCH c_period INTO x_period_name;
    CLOSE c_period;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                        'gl_period_statuses_pkg.select_prior_year_1st_period');
      RAISE;
  END select_prior_year_1st_period;



PROCEDURE select_year_1st_period(
        x_application_id                        NUMBER,
        x_ledger_id                       NUMBER,
        x_period_year                           NUMBER,
        x_period_name           IN OUT NOCOPY          VARCHAR2) IS

  CURSOR c_period IS
    select
        period_name
    from
        gl_period_statuses s1
    where
        s1.application_id = x_application_id
    and s1.ledger_id = x_ledger_id
    and s1.period_year = x_period_year
    and s1.period_num = (select min(period_num)
                         from  gl_period_statuses s2
                         where s2.period_year = x_period_year
                         and   s2.application_id = x_application_id
                         and   s2.ledger_id = x_ledger_id);

  BEGIN
    OPEN c_period;
    FETCH c_period INTO x_period_name;
    CLOSE c_period;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                        'gl_period_statuses_pkg.select_year_1st_period');
      RAISE;
  END select_year_1st_period;


  PROCEDURE get_extended_quarter(
              x_application_id                       NUMBER,
              x_ledger_id                      NUMBER,
              x_period_year                          NUMBER,
              x_period_name                          VARCHAR2,
              x_period_set_name                      VARCHAR2,
              x_accounted_period_type                VARCHAR2,
              x_period_used_for_ext_actuals   IN OUT NOCOPY VARCHAR2,
              x_num_used_for_ext_actuals      IN OUT NOCOPY NUMBER,
              x_year_used_for_ext_actuals     IN OUT NOCOPY NUMBER,
              x_quarter_used_for_ext_actuals  IN OUT NOCOPY NUMBER ) IS

  CURSOR c_qtde IS
  select
        period_name, period_num, period_year, quarter_num
  from
        gl_period_statuses
  where
        application_id = x_application_id
  and   ledger_id = x_ledger_id
  and   period_year = x_period_year
  and   period_num = (select max(glps.period_num)
                      from gl_period_statuses glps
                      where glps.closing_status in ('O','C','P')
                      and glps.quarter_num = (
                                select quarter_num from gl_periods
                                where period_name = x_period_name
                                and period_set_name = x_period_set_name)
                      and glps.period_year = x_period_year
                      and glps.application_id = 101
                      and glps.ledger_id = x_ledger_id
                      and glps.period_type = x_accounted_period_type );
  /* Removed the redundant join to the GL_PERIODS table
  for perf.bug Fix 2925883*/


  BEGIN
    OPEN c_qtde;
    FETCH c_qtde INTO x_period_used_for_ext_actuals,
                      x_num_used_for_ext_actuals,
                      x_year_used_for_ext_actuals,
                      x_quarter_used_for_ext_actuals;
    CLOSE c_qtde;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                        'gl_period_statuses_pkg.get_extended_quarter');
      RAISE;
  END get_extended_quarter;


  PROCEDURE get_extended_year(
              x_application_id                       NUMBER,
              x_ledger_id                      NUMBER,
              x_period_year                          NUMBER,
              x_accounted_period_type                VARCHAR2,
              x_period_used_for_ext_actuals   IN OUT NOCOPY VARCHAR2,
              x_num_used_for_ext_actuals      IN OUT NOCOPY NUMBER,
              x_year_used_for_ext_actuals     IN OUT NOCOPY NUMBER,
              x_quarter_used_for_ext_actuals  IN OUT NOCOPY NUMBER ) IS

  CURSOR c_ytde IS
    select
        period_name, period_num, period_year, quarter_num
    from
        gl_period_statuses
    where
        application_id = x_application_id
    and ledger_id = x_ledger_id
    and period_year = x_period_year
    and period_num = (select max(period_num)
                      from gl_period_statuses
                      where period_type = x_accounted_period_type
                      and ledger_id = x_ledger_id
                      and period_year = x_period_year
                      and closing_status in ('O','C','P')
                      and application_id = x_application_id);

  BEGIN
    OPEN c_ytde;
    FETCH c_ytde INTO x_period_used_for_ext_actuals,
                      x_num_used_for_ext_actuals,
                      x_year_used_for_ext_actuals,
                      x_quarter_used_for_ext_actuals;
    CLOSE c_ytde;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                        'gl_period_statuses_pkg.get_extended_year');
      RAISE;
  END get_extended_year;



  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Application_Id                 NUMBER,
                       X_Ledger_Id                NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Closing_Status                 VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Period_Type                    VARCHAR2,
                       X_Period_Year                    NUMBER,
                       X_Period_Num                     NUMBER,
                       X_Quarter_Num                    NUMBER,
                       X_Adjustment_Period_Flag         VARCHAR2,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Context                        VARCHAR2

   ) IS
     CURSOR C IS SELECT rowid FROM gl_period_statuses
                 WHERE application_id = X_Application_Id

                 AND   ledger_id = X_Ledger_Id

                 AND   period_name = X_Period_Name;



    BEGIN


       INSERT INTO gl_period_statuses(
               application_id,
               ledger_id,
               set_of_books_id,
               period_name,
               last_update_date,
               last_updated_by,
               closing_status,
               start_date,
               end_date,
               period_type,
               period_year,
               period_num,
               quarter_num,
               adjustment_period_flag,
               creation_date,
               created_by,
               last_update_login,
               attribute1,
               attribute2,
               attribute3,
               attribute4,
               attribute5,
               context,
               effective_period_num,
               migration_status_code
             ) VALUES (
               X_Application_Id,
               X_Ledger_Id,
               X_Ledger_Id,
               X_Period_Name,
               X_Last_Update_Date,
               X_Last_Updated_By,
               X_Closing_Status,
               X_Start_Date,
               X_End_Date,
               X_Period_Type,
               X_Period_Year,
               X_Period_Num,
               X_Quarter_Num,
               X_Adjustment_Period_Flag,
               X_Creation_Date,
               X_Created_By,
               X_Last_Update_Login,
               X_Attribute1,
               X_Attribute2,
               X_Attribute3,
               X_Attribute4,
               X_Attribute5,
               X_Context,
               X_period_year * 10000 + x_period_num,
               'N'
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
  END Insert_Row;


  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Application_Id                   NUMBER,
                     X_Ledger_Id                  NUMBER,
                     X_Period_Name                      VARCHAR2,
                     X_Closing_Status                   VARCHAR2,
                     X_Start_Date                       DATE,
                     X_End_Date                         DATE,
                     X_Period_Type                      VARCHAR2,
                     X_Period_Year                      NUMBER,
                     X_Period_Num                       NUMBER,
                     X_Quarter_Num                      NUMBER,
                     X_Adjustment_Period_Flag           VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Context                          VARCHAR2

  ) IS
    CURSOR C IS
        SELECT *
        FROM   gl_period_statuses
        WHERE  rowid = X_Rowid
        FOR UPDATE of Application_Id NOWAIT;
    Recinfo C%ROWTYPE;
  BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (
               (Recinfo.application_id = X_Application_Id)
           AND (Recinfo.ledger_id = X_Ledger_Id)
           AND (Recinfo.period_name = X_Period_Name)
           AND (Recinfo.closing_status = X_Closing_Status)
           AND (Recinfo.start_date = X_Start_Date)
           AND (Recinfo.end_date = X_End_Date)
           AND (Recinfo.period_type = X_Period_Type)
           AND (Recinfo.period_year = X_Period_Year)
           AND (Recinfo.period_num = X_Period_Num)
           AND (Recinfo.quarter_num = X_Quarter_Num)
           AND (Recinfo.adjustment_period_flag = X_Adjustment_Period_Flag)
           AND (   (Recinfo.attribute1 = X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 = X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 = X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 = X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 = X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.context = X_Context)
                OR (    (Recinfo.context IS NULL)
                    AND (X_Context IS NULL)))

            ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
  END Lock_Row;


  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Application_Id                 NUMBER,
                       X_Ledger_Id                NUMBER,
                       X_Period_Name                    VARCHAR2,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Closing_Status                 VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Period_Type                    VARCHAR2,
                       X_Period_Year                    NUMBER,
                       X_Period_Num                     NUMBER,
                       X_Quarter_Num                    NUMBER,
                       X_Adjustment_Period_Flag         VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Context                        VARCHAR2

 ) IS
 BEGIN

   IF (X_Closing_Status IN ('C', 'P')) THEN
      UPDATE gl_period_statuses
      SET
        application_id                    =     X_Application_Id,
     	ledger_id                         =     X_Ledger_Id,
     	period_name                       =     X_Period_Name,
     	last_update_date                  =     X_Last_Update_Date,
     	last_updated_by                   =     X_Last_Updated_By,
     	closing_status                    =     X_Closing_Status,
     	start_date                        =     X_Start_Date,
     	end_date                          =     X_End_Date,
     	period_type                       =     X_Period_Type,
     	period_year                       =     X_Period_Year,
     	period_num                        =     X_Period_Num,
     	quarter_num                       =     X_Quarter_Num,
     	adjustment_period_flag            =     X_Adjustment_Period_Flag,
        elimination_confirmed_flag        =     'Y',
     	last_update_login                 =     X_Last_Update_Login,
     	attribute1                        =     X_Attribute1,
     	attribute2                        =     X_Attribute2,
     	attribute3                        =     X_Attribute3,
     	attribute4                        =     X_Attribute4,
     	attribute5                        =     X_Attribute5,
     	context                           =     X_Context,
     	effective_period_num	          =     X_Period_Year * 10000 + X_Period_Num

      WHERE rowid = X_rowid;
   ELSE
      UPDATE gl_period_statuses
      SET
        application_id                    =     X_Application_Id,
        ledger_id                         =     X_Ledger_Id,
     	period_name                       =     X_Period_Name,
     	last_update_date                  =     X_Last_Update_Date,
     	last_updated_by                   =     X_Last_Updated_By,
     	closing_status                    =     X_Closing_Status,
     	start_date                        =     X_Start_Date,
     	end_date                          =     X_End_Date,
     	period_type                       =     X_Period_Type,
     	period_year                       =     X_Period_Year,
     	period_num                        =     X_Period_Num,
     	quarter_num                       =     X_Quarter_Num,
     	adjustment_period_flag            =     X_Adjustment_Period_Flag,
     	last_update_login                 =     X_Last_Update_Login,
     	attribute1                        =     X_Attribute1,
     	attribute2                        =     X_Attribute2,
     	attribute3                        =     X_Attribute3,
     	attribute4                        =     X_Attribute4,
     	attribute5                        =     X_Attribute5,
     	context                           =     X_Context,
     	effective_period_num	          =     X_Period_Year * 10000 + X_Period_Num
      WHERE rowid = X_rowid;
   END IF;


    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    DELETE FROM gl_period_statuses
    WHERE  rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;

 PROCEDURE update_row_dff(
  		X_rowid	                           VARCHAR2,
  		X_attribute1	                   VARCHAR2,
  		X_attribute2	                   VARCHAR2,
  		X_attribute3	                   VARCHAR2,
		X_attribute4	                   VARCHAR2,
		X_attribute5	                   VARCHAR2,
		X_context	                   VARCHAR2,
                X_Last_Update_Date                 DATE,
                X_Last_Updated_By                  NUMBER,
                X_Last_Update_Login                NUMBER
 ) IS
    CURSOR C IS
        SELECT *
        FROM   gl_period_statuses
        WHERE  rowid = X_rowid
        FOR UPDATE of Application_Id NOWAIT;
    Recinfo C%ROWTYPE;
 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    else
	   IF ((    (   (Recinfo.attribute1 <> X_Attribute1)
                      OR (    (Recinfo.attribute1 IS NOT NULL)
                          AND (X_Attribute1 IS NULL))
                      OR (    (Recinfo.attribute1 IS NULL)
                          AND (X_Attribute1 IS NOT NULL))
		     )
                 OR (   (Recinfo.attribute2 <> X_Attribute2)
                      OR (    (Recinfo.attribute2 IS NOT NULL)
                          AND (X_Attribute2 IS NULL))
                      OR (    (Recinfo.attribute2 IS NULL)
                          AND (X_Attribute2 IS NOT NULL))
		     )
                 OR (   (Recinfo.attribute3 <> X_Attribute3)
                      OR (    (Recinfo.attribute3 IS NOT NULL)
                          AND (X_Attribute3 IS NULL))
                      OR (    (Recinfo.attribute3 IS NULL)
                          AND (X_Attribute3 IS NOT NULL))
		     )
                 OR (   (Recinfo.attribute4 <> X_Attribute4)
                      OR (    (Recinfo.attribute4 IS NOT NULL)
                          AND (X_Attribute4 IS NULL))
                      OR (    (Recinfo.attribute4 IS NULL)
                          AND (X_Attribute4 IS NOT NULL))
		     )
                 OR (   (Recinfo.attribute5 <> X_Attribute5)
                      OR (    (Recinfo.attribute5 IS NOT NULL)
                          AND (X_Attribute5 IS NULL))
                      OR (    (Recinfo.attribute5 IS NULL)
                          AND (X_Attribute5 IS NOT NULL))
		     )
                 OR (   (Recinfo.context <> X_Context)
                      OR (    (Recinfo.context IS NOT NULL)
                          AND (X_Context IS NULL))
                      OR (    (Recinfo.context IS NULL)
                          AND (X_Context IS NOT NULL))
		     )
                )) THEN
  	     UPDATE gl_period_statuses
             SET
                Attribute1        = X_Attribute1,
                Attribute2        = X_Attribute2,
                Attribute3        = X_Attribute3,
                Attribute4        = X_Attribute4,
                Attribute5        = X_Attribute5,
                Context           = X_Context,
                Last_Update_Date  = X_Last_Update_Date,
                Last_Updated_By   = X_Last_Updated_By,
                Last_Update_Login = X_Last_Update_Login
             WHERE rowid = X_rowid;
           END IF;
    END IF;
  END Update_Row_Dff;

  PROCEDURE get_period_by_date(
  		x_application_id	NUMBER,
  		x_ledger_id	NUMBER,
  		x_given_date		DATE,
  		x_period_name	 IN OUT NOCOPY	VARCHAR2,
		x_closing_status IN OUT NOCOPY	VARCHAR2,
		x_period_year	 IN OUT NOCOPY	NUMBER,
		x_period_num	 IN OUT NOCOPY NUMBER,
		x_period_type	 IN OUT NOCOPY	VARCHAR2)  IS
  BEGIN
    SELECT  ps.period_name, ps.closing_status,
            ps.period_year, ps.period_num, ps.period_type
    INTO    x_period_name, x_closing_status, x_period_year,
            x_period_num, x_period_type
    FROM    gl_period_statuses ps,
            gl_date_period_map dpm,
            gl_ledgers led
    WHERE  led.ledger_id = x_ledger_id
    AND    dpm.accounting_date = x_given_date
    AND    dpm.period_set_name = led.period_set_name
    AND    dpm.period_type     = led.accounted_period_type
    AND    ps.period_name      = dpm.period_name
    AND    ps.ledger_id  = led.ledger_id
    AND    ps.application_id   = x_application_id
    AND    ps.adjustment_period_flag = 'N';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_period_name := NULL;
      x_closing_status := NULL;
      RETURN;
      /*
      fnd_message.set_name('SQLGL', 'GL_IEA_NOT_IN_OPEN_FUTURE_PER');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.get_period_by_date');
      APP_EXCEPTION.Raise_Exception;
      */
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.get_period_by_date');
      RAISE;
  END get_period_by_date;


PROCEDURE get_calendar_range(
  		x_ledger_id	NUMBER,
  		x_start_date  IN OUT NOCOPY	DATE,
  		x_end_date    IN OUT NOCOPY	DATE)  IS
  CURSOR not_never_opened_period IS
    SELECT  min(start_date), max(end_date)
    FROM    gl_period_statuses
    WHERE   application_id = 101
    AND     ledger_id = x_ledger_id
    AND     closing_status <> 'N';

  BEGIN
    OPEN not_never_opened_period;
    FETCH not_never_opened_period INTO x_start_date, x_end_date;
    CLOSE not_never_opened_period;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_start_date := NULL;
      x_end_date := NULL;
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.get_calendar_range');
      RAISE;
  END get_calendar_range;


  PROCEDURE get_open_closed_calendar_range(
  		x_ledger_id	NUMBER,
  		x_start_date  IN OUT NOCOPY	DATE,
  		x_end_date    IN OUT NOCOPY	DATE)  IS
  CURSOR closed_opened_period IS
    SELECT  min(start_date), max(end_date)
    FROM    gl_period_statuses
    WHERE   application_id = 101
    AND     ledger_id = x_ledger_id
    AND     closing_status in ('C', 'O', 'P');

  BEGIN
    OPEN closed_opened_period;
    FETCH closed_opened_period INTO x_start_date, x_end_date;
    CLOSE closed_opened_period;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_start_date := NULL;
      x_end_date := NULL;
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.get_open_closed_calendar_range');
      RAISE;
  END get_open_closed_calendar_range;


PROCEDURE get_journal_range(
  		x_ledger_id	NUMBER,
  		x_start_date  IN OUT NOCOPY	DATE,
  		x_end_date    IN OUT NOCOPY	DATE)  IS
  CURSOR journal_period IS
    SELECT  min(start_date), max(end_date)
    FROM    gl_period_statuses
    WHERE   application_id = 101
    AND     ledger_id = x_ledger_id
    AND     closing_status||'' IN ('O', 'F');

  BEGIN
    OPEN journal_period;
    FETCH journal_period INTO x_start_date, x_end_date;
    CLOSE journal_period;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_start_date := NULL;
      x_end_date := NULL;
      RETURN;
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.get_journal_range');
      RAISE;
  END get_journal_range;

END gl_period_statuses_pkg;

/
