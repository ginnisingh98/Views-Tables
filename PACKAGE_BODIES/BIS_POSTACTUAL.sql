--------------------------------------------------------
--  DDL for Package Body BIS_POSTACTUAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_POSTACTUAL" as
/* $Header: BISPACTB.pls 120.1 2005/10/06 06:58:41 ankgoel noship $ */

G_ACTION_INSERT CONSTANT VARCHAR2(10) := 'INSERT';
G_ACTION_UPDATE CONSTANT VARCHAR2(10) := 'UPDATE';

PROCEDURE Post_Actual
( x_target_lvl_short_name  IN VARCHAR2
, x_organization_id        IN NUMBER
, x_actual_value           IN NUMBER
, x_timestamp              IN DATE DEFAULT NULL
, x_DIMENSION1_LEVEL_VALUE IN VARCHAR2 DEFAULT NULL
, x_DIMENSION2_LEVEL_VALUE IN VARCHAR2 DEFAULT NULL
, x_DIMENSION3_LEVEL_VALUE IN VARCHAR2 DEFAULT NULL
, x_DIMENSION4_LEVEL_VALUE IN VARCHAR2 DEFAULT NULL
, x_DIMENSION5_LEVEL_VALUE IN VARCHAR2 DEFAULT NULL
)
IS
l_target_level_id      NUMBER;
l_organization_id      NUMBER;
l_organization_ID_char VARCHAR2(250);
l_time_level_Value     VARCHAR2(250);
l_actual_rec           BIS_ACTUAL_VALUES%ROWTYPE;
l_action               VARCHAR2(10);
l_Return_Status        VARCHAR2(1);
e_invalidActualException EXCEPTION;

CURSOR cr_actual IS
  SELECT *
--  SELECT creation_date, last_update_date
  FROM BIS_ACTUAL_VALUES
  WHERE TARGET_LEVEL_ID  = l_target_level_id
  AND ORG_LEVEL_VALUE    = l_organization_ID_char
  AND TIME_LEVEL_VALUE = l_time_level_value
  AND NVL(DIMENSION1_LEVEL_VALUE,'-999')=NVL(x_DIMENSION1_LEVEL_VALUE,'-999')
  AND NVL(DIMENSION2_LEVEL_VALUE,'-999')=NVL(x_DIMENSION2_LEVEL_VALUE,'-999')
  AND NVL(DIMENSION3_LEVEL_VALUE,'-999')=NVL(x_DIMENSION3_LEVEL_VALUE,'-999')
  AND NVL(DIMENSION4_LEVEL_VALUE,'-999')=NVL(x_DIMENSION4_LEVEL_VALUE,'-999')
  AND NVL(DIMENSION5_LEVEL_VALUE,'-999')=NVL(x_DIMENSION5_LEVEL_VALUE,'-999')
  ORDER BY CREATION_DATE
  FOR UPDATE;

--l_create_date DATE;
--l_update_date DATE;

BEGIN
  -- check if target_level, organization IS valid
  --
  SELECT tg.target_level_id
  INTO l_target_level_id
  FROM bis_target_levels tg
  WHERE tg.short_name = x_target_lvl_short_name;

  IF x_organization_id <> -1 THEN
    SELECT DISTINCT o.organization_id
    INTO l_organization_id
    FROM hr_all_organization_units o
    WHERE o.organization_id = x_organization_id;
  ELSE
    l_organization_id := x_organization_id;
  END IF;

  l_organization_id_char := TO_CHAR(l_organization_id);

  -- get the period_name for the current date
  --
  BIS_UTIL.Get_Time_Level_Value
  ( p_date             => x_Timestamp
  , p_Target_Level_ID  => l_target_level_id
  , p_Organization_ID  => l_organization_id
  , x_Time_Level_Value => l_time_level_value
  , x_Return_Status    => l_Return_Status
  );

  IF l_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE e_invalidActualException;
  END IF;

  -- check if previous record exist and set action flag
  --
  OPEN cr_actual;
  FETCH cr_actual INTO l_actual_rec;
--  FETCH cr_actual INTO l_create_date, l_update_date;
  IF cr_actual%FOUND THEN
    l_action := G_ACTION_UPDATE;
  ELSE
    l_action := G_ACTION_INSERT;
  END IF;

  IF l_action = G_ACTION_UPDATE AND l_time_level_value IS NOT NULL THEN

    UPDATE bis_actual_values
    SET TARGET_LEVEL_ID = l_target_level_id
    , ORG_LEVEL_VALUE = l_organization_id_char
    , TIME_LEVEL_VALUE = l_time_level_value
    , DIMENSION1_LEVEL_VALUE = x_dimension1_level_value
    , DIMENSION2_LEVEL_VALUE = x_dimension2_level_value
    , DIMENSION3_LEVEL_VALUE = x_dimension3_level_value
    , DIMENSION4_LEVEL_VALUE = x_dimension4_level_value
    , DIMENSION5_LEVEL_VALUE = x_dimension5_level_value
    , ACTUAL_VALUE      = x_actual_value
    , LAST_UPDATE_DATE  = SYSDATE
    , LAST_UPDATED_BY   = FND_GLOBAL.USER_ID
    , LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
    WHERE CURRENT OF cr_actual;

    COMMIT;
    IF cr_actual%ISOPEN THEN CLOSE cr_actual; END IF;

--    l_update_date := SYSDATE;

  ELSIF l_action = G_ACTION_INSERT AND l_time_level_value IS NOT NULL THEN

    IF cr_actual%ISOPEN THEN CLOSE cr_actual; END IF;

    INSERT INTO bis_actual_values
    (
    ACTUAL_ID    -- Fix for #3493470
    , TARGET_LEVEL_ID
    , ORG_LEVEL_VALUE
    , TIME_LEVEL_VALUE
    , DIMENSION1_LEVEL_VALUE
    , DIMENSION2_LEVEL_VALUE
    , DIMENSION3_LEVEL_VALUE
    , DIMENSION4_LEVEL_VALUE
    , DIMENSION5_LEVEL_VALUE
    , ACTUAL_VALUE
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    )
    VALUES
    ( BIS_ACTUAL_VALUES_S.NEXTVAL  -- Fix for #3493470.
    , l_target_level_id
    , l_organization_id_char
    , l_time_level_value
    , x_dimension1_level_value
    , x_dimension2_level_value
    , x_dimension3_level_value
    , x_dimension4_level_value
    , x_dimension5_level_value
    , x_actual_value
    , SYSDATE
    , FND_GLOBAL.USER_ID
    , SYSDATE
    , FND_GLOBAL.USER_ID
    , FND_GLOBAL.LOGIN_ID
    );

    COMMIT;

--    l_update_date := SYSDATE;
--    l_create_date := SYSDATE;

  ELSE
    IF cr_actual%ISOPEN THEN CLOSE cr_actual; END IF;
    RAISE e_invalidActualException;
  END IF;

--  dbms_output.put_line('action: '||l_action
--                      ||'.  Time Val: '||SUBSTR(l_time_level_value,1,20)
--                      ||'-- Org Val: '||SUBSTR(l_organization_id_char,1,5)
--                      ||'-- Create date: '||l_create_date
--                      ||'-- Update date: '||l_update_date);

EXCEPTION
  WHEN NO_DATA_FOUND OR e_invalidActualException THEN
    IF cr_actual%ISOPEN THEN CLOSE cr_actual; END IF;
    RETURN;

  WHEN OTHERS THEN
    IF cr_actual%ISOPEN THEN CLOSE cr_actual; END IF;
    RAISE;

END Post_Actual;

/*PROCEDURE get_trgt_level_orgs
( p_target_lvl_short_name IN VARCHAR2
, x_orgtable              OUT NOCOPY t_orgTable
)
IS
l_target_level_id NUMBER;
l_organization_id NUMBER;
l_time_level_name VARCHAR2(15);
l_calendar VARCHAR2(15);
l_start_end_date VARCHAR2(30);
l_msg VARCHAR2(100);
CURSOR c_orgs is
  SELECT distinct sel.organization_id
  FROM 	bis_user_ind_selections sel
  WHERE sel.target_level_id = l_target_level_id;

BEGIN
  -- get time_level
  --
  SELECT target_level_id, time_level_name
  INTO l_target_level_id, l_time_level_name
  FROM bis_target_levels_v
  WHERE short_name = p_target_lvl_short_name;

  -- get organization and the start date and end date of the current period
  --
  OPEN c_orgs;
  FETCH c_orgs INTO l_organization_id;

  WHILE c_orgs%FOUND LOOP
  IF UPPER(l_time_level_name) = 'TOTAL_TIME' THEN
    l_calendar := 'Accounting';
    l_start_end_date := to_char(sysdate)||'+'||to_char(sysdate);

  ELSIF UPPER(l_time_level_name) = 'HR MONTH' THEN
  l_start_end_date := to_char(sysdate, 'DD-MM-YYYY')
    ||'+'||to_char(add_months (sysdate, 1) -1,'DD-MM-YYYY');

  ELSIF UPPER(l_time_level_name) = 'HR YEAR' THEN
  l_start_end_date := to_char(sysdate, 'DD-MM-YYYY')
    ||'+'||to_char(add_months (sysdate, 12) -1,'DD-MM-YYYY');

  ELSIF UPPER(l_time_level_name) = 'HR QUARTER' THEN
  l_start_end_date := to_char(sysdate, 'DD-MM-YYYY')
    ||'+'||to_char(add_months (sysdate, 3) -1,'DD-MM-YYYY');

  ELSE
    Get_Indicator_Calendar
    ( p_target_lvl_short_name
    , l_organization_id
    , l_calendar
    , l_msg
    );
    l_start_end_date := Get_Start_End_Date
                        ( l_calendar
                        , l_time_level_name
                        );
  END if;

  -- fill in table
  --
  x_orgtable(l_organization_id) := l_start_end_date;
  FETCH c_orgs INTO l_organization_id;

  END LOOP;

  IF c_orgs%ISOPEN THEN CLOSE c_orgs;  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF c_orgs%ISOPEN THEN CLOSE c_orgs; END IF;
    RETURN;

  WHEN OTHERS THEN
    IF c_orgs%ISOPEN THEN CLOSE c_orgs; END IF;
    RAISE;

END get_trgt_level_orgs;*/

FUNCTION Get_Start_End_Date
( p_calendar    IN VARCHAR2
, p_period_type IN VARCHAR2
)
RETURN VARCHAR2
IS
  x_start_end_date VARCHAR2(20);
  l_start_date DATE;
  l_end_date DATE;

cursor c_date IS
  SELECT start_date, end_date
  FROM gl_periods
  WHERE UPPER(period_type) = UPPER(p_period_type)
  AND UPPER(period_set_name) = UPPER(p_calendar);

BEGIN

 OPEN c_date;
 FETCH c_date INTO l_start_date, l_end_date;
 WHILE c_date%found LOOP
   IF sysdate >= l_start_date AND sysdate <= l_end_date THEN
     x_start_end_date := to_char(l_start_date)||'+'||to_char(l_end_date);
     CLOSE c_date;
     RETURN x_start_end_date;
   ELSE
     FETCH c_date INTO l_start_date, l_end_date;
   END IF;
 END LOOP;

 IF c_date%ISOPEN THEN CLOSE c_date; END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF c_date%ISOPEN THEN CLOSE c_date; END IF;
    RETURN ' ';
  WHEN TOO_MANY_ROWS THEN
    IF c_date%ISOPEN THEN CLOSE c_date; END IF;
    RETURN TO_CHAR(sysdate)||'+'||to_char(sysdate);
  WHEN OTHERS THEN
    IF c_date%ISOPEN THEN CLOSE c_date; END IF;
    RETURN to_char(sysdate)||'+'||to_char(sysdate);

END get_start_end_date;

/*PROCEDURE Get_SOB
( p_organization_id IN NUMBER
, x_sob             OUT NOCOPY NUMBER
, x_msg             OUT NOCOPY VARCHAR2
)
IS
cursor c_sob is
	SELECT TO_NUMBER(le.set_of_books_id)
	FROM hr_legal_entities le
	WHERE le.organization_id = p_organization_id
--
	UNION SELECT TO_NUMBER(ou.set_of_books_id)
	FROM hr_legal_entities le, hr_operating_units ou
	WHERE ou.organization_id = p_organization_id
	AND ou.legal_entity_id = le.organization_id
--
	UNION SELECT od.set_of_books_id
	FROM org_organization_definitions od
	WHERE od.organization_id = p_organization_id;

BEGIN
  OPEN c_sob;
  FETCH c_sob INTO x_sob;
  IF c_sob%FOUND THEN
    x_msg := FND_API.G_RET_STS_SUCCESS;
  ELSE
    x_msg := FND_API.G_RET_STS_SUCCESS;
    x_sob := -1;
  END IF;

  IF c_sob%ISOPEN THEN CLOSE c_sob; END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_sob%ISOPEN THEN CLOSE c_sob; END IF;

END get_sob;*/

-- to get GL calendars only
/*PROCEDURE Get_Indicator_Calendar
( p_target_lvl_short_name IN VARCHAR2
, p_organization_id       IN NUMBER
, x_calendar              OUT NOCOPY VARCHAR2
, x_msg                   OUT NOCOPY VARCHAR2
)
IS
sob_id gl_sets_of_books.set_of_books_id%TYPE;
l_msg VARCHAR2(100);

CURSOR c_cal IS
  SELECT sob.period_set_name
  FROM gl_periods gl,
  gl_sets_of_books sob,
  bis_levels l,
  BIS_TARGET_LEVELS TL
  WHERE
  UPPER(TL.short_name) = UPPER(p_target_lvl_short_name)
  AND TL.time_level_id = l.level_id
  AND upper(l.short_name) = UPPER(gl.period_type)
  AND sob_id = sob.set_of_books_id
  AND gl.period_set_name = sob.period_set_name;

BEGIN

  Get_Sob
  ( p_organization_id
  , sob_id
  , l_msg);

  OPEN c_cal;
  FETCH c_cal INTO x_calendar;

  IF c_cal%FOUND THEN
    x_msg := 'ok';
    CLOSE c_cal;
  ELSE
    x_calendar := 'Accounting';
    x_msg := 'Defaulting to Accounting Calendar';
    CLOSE c_cal;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_cal%ISOPEN THEN CLOSE c_cal; END IF;

END get_indicator_calendar;*/

END BIS_PostActual;

/
