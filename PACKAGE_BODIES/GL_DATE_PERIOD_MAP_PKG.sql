--------------------------------------------------------
--  DDL for Package Body GL_DATE_PERIOD_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_DATE_PERIOD_MAP_PKG" AS
/* $Header: gliprmpb.pls 120.3.12010000.2 2010/04/30 13:36:47 sommukhe ship $ */
--
-- PRIVATE FUNCTIONS
--
PROCEDURE insert_new_year
			(
			x_period_set_name 	VARCHAR2,
			x_period_type           VARCHAR2,
			x_entered_year		VARCHAR2,
			x_period_name		VARCHAR2,
			x_CREATION_DATE		DATE,
			x_CREATED_BY		NUMBER,
			x_LAST_UPDATE_DATE	DATE,
			x_LAST_UPDATED_BY	NUMBER,
			x_LAST_UPDATE_LOGIN	NUMBER
			)  IS
        dummy			VARCHAR2(100);
	new_year_flag		VARCHAR2(1);
	new_entered_year	VARCHAR2(30);
BEGIN
   -- do we already have this year in GL_DATE_PERIOD_MAP?
   SELECT '1' INTO dummy FROM sys.dual
	WHERE EXISTS
		(SELECT 'Existing Year'
		FROM	gl_date_period_map
		WHERE
			    period_set_name = x_period_set_name
			AND period_type = x_period_type
			AND accounting_date BETWEEN
			        TO_DATE(x_entered_year || '/01/01', 'YYYY/MM/DD')
			    AND TO_DATE(x_entered_year || '/12/31', 'YYYY/MM/DD')
		);


EXCEPTION
  WHEN NO_DATA_FOUND THEN
      -- NO, this is a new year
      -- Insert placeholder records (with period_name = NOT ASSIGNED) for the new
      -- year into the GL_DATE_PERIOD_MAP table
      new_entered_year := x_entered_year;
      INSERT INTO gl_date_period_map
		(
		period_set_name,
		period_type,
		accounting_date,
		period_name,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN
		)
         SELECT
   	   x_period_set_name,
   	   x_period_type,
   	   TO_DATE(new_entered_year || '/01/01',
			'YYYY/MM/DD')+(cnt.multiplier-1),
   	   'NOT ASSIGNED',		-- placeholder
	   x_CREATION_DATE,
	   x_CREATED_BY,
	   x_LAST_UPDATE_DATE,
	   x_LAST_UPDATED_BY,
	   x_LAST_UPDATE_LOGIN
        FROM gl_row_multipliers cnt
        WHERE
           cnt.multiplier <=
	 	TO_DATE(new_entered_year || '/12/31', 'YYYY/MM/DD') -
    	        TO_DATE(new_entered_year || '/01/01', 'YYYY/MM/DD')+1;

END;


PROCEDURE select_row( recinfo 	IN OUT NOCOPY gl_date_period_map%ROWTYPE)		IS
BEGIN
	SELECT *
	INTO recinfo
	FROM gl_date_period_map
	WHERE period_set_name = recinfo.period_set_name
	AND   period_type     = recinfo.period_type
	AND   accounting_date = recinfo.accounting_date;

END select_row;

--
-- PUBLIC FUNCTIONS
--
PROCEDURE maintain_date_period_map
			(
			x_period_set_name 	VARCHAR2,
			x_period_type     	VARCHAR2,
			x_adjust_period_flag	VARCHAR2,
			x_operation		VARCHAR2,
			x_start_date		DATE,
			x_end_date		DATE,
			x_period_name		VARCHAR2,
			x_CREATION_DATE		DATE,
			x_CREATED_BY		NUMBER,
			x_LAST_UPDATE_DATE	DATE,
			x_LAST_UPDATED_BY	NUMBER,
			x_LAST_UPDATE_LOGIN	NUMBER
			)  IS
        dummy			VARCHAR2(100);
        start_entered_year	VARCHAR2(30);
        end_entered_year	VARCHAR2(30);
BEGIN

   start_entered_year := TO_CHAR(x_start_date, 'YYYY');
   -- insert new year for start_date if needed
   insert_new_year	(
			x_period_set_name,
			x_period_type,
			start_entered_year,
			x_period_name,
			x_CREATION_DATE,
			x_CREATED_BY,
			x_LAST_UPDATE_DATE,
			x_LAST_UPDATED_BY,
			x_LAST_UPDATE_LOGIN
			);

   -- if start_entered_year and end_entered_year are different and
   -- the end_date is a new year, insert a new year for this one too
      end_entered_year := TO_CHAR(x_end_date, 'YYYY');
      IF(start_entered_year <> end_entered_year) THEN
   	-- insert new year for end_date if needed
   	insert_new_year	(
			x_period_set_name,
			x_period_type,
			end_entered_year,
			x_period_name,
			x_CREATION_DATE,
			x_CREATED_BY,
			x_LAST_UPDATE_DATE,
			x_LAST_UPDATED_BY,
			x_LAST_UPDATE_LOGIN
			);
      END IF;


   -- Update period_name column in GL_DATE_PERIOD_MAP table
   -- (only non-adjusting periods)
   IF (x_adjust_period_flag = 'N') THEN
	IF (x_operation = 'INSERT') THEN
   	   -- For new  periods being inserted:
   	   UPDATE gl_date_period_map
	   SET period_name = x_period_name
	   WHERE
		accounting_date between
			    x_start_date
			AND x_end_date
            AND period_set_name = x_period_set_name
            AND period_type = x_period_type;

       	ELSIF(x_operation = 'DELETE') THEN

	   -- For existing  periods being updated:
	   UPDATE gl_date_period_map
	   SET period_name = 'NOT ASSIGNED'
	   WHERE
    		(    accounting_date between x_start_date AND x_end_date
     		 OR  period_name = x_period_name)
  		 AND period_set_name = x_period_set_name
  		 AND period_type = x_period_type;
	ELSE

	   -- For existing  periods being updated:
	   UPDATE gl_date_period_map
	   SET period_name = DECODE(LEAST(accounting_date, x_start_date-1),
             	accounting_date, 'NOT ASSIGNED',
	    	DECODE(GREATEST(accounting_date, x_end_date+1),
                    accounting_date, 'NOT ASSIGNED',
                    x_period_name))
	   WHERE
    		(    accounting_date between x_start_date AND x_end_date
     		 OR  period_name = x_period_name)
  		 AND period_set_name = x_period_set_name
  		 AND period_type = x_period_type;
	END IF;
   END IF;       -- from IF (x_adjust_period_flag =

EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_date_period_map_pkg.maintain_date_period_map');
      RAISE;

END maintain_date_period_map;


PROCEDURE select_columns
			(
			x_period_set_name 	       VARCHAR2,
			x_period_type     	       VARCHAR2,
			x_accounting_date	       DATE,
			x_period_name		IN OUT NOCOPY VARCHAR2) IS

	recinfo gl_date_period_map%ROWTYPE;

BEGIN
	recinfo.period_set_name := x_period_set_name;
	recinfo.period_type     := x_period_type;
	recinfo.accounting_date := x_accounting_date;

	select_row(recinfo);

	x_period_name := recinfo.period_name;
END select_columns;

END;

/
