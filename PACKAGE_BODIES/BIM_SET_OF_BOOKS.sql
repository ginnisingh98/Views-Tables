--------------------------------------------------------
--  DDL for Package Body BIM_SET_OF_BOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_SET_OF_BOOKS" AS
/* $Header: bimsobfb.pls 120.2 2005/09/26 23:45:05 arvikuma noship $*/

-------------------------------------------------------------------------------
-- PROCEDURE
--    GET_FISCAL_DATA
--
-- Note
--    This procedure will get the fiscal year, quarter and month for the
--    given date and org_id.
-------------------------------------------------------------------------------

PROCEDURE GET_FISCAL_DATA
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ,x_year                    OUT NOCOPY VARCHAR2
    ,x_quarter                 OUT NOCOPY VARCHAR2
    ,x_month                   OUT NOCOPY VARCHAR2
    ,x_quarter_num             OUT NOCOPY NUMBER
    ,x_month_num               OUT NOCOPY NUMBER
    ) IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_fiscal_data';

/*    CURSOR period_info
    IS
       SELECT b.period_year year,
              SUBSTR(b.entered_period_name, 0, 2) quarter,
              TO_CHAR(p_input_date, 'MON') month
       FROM gl_sets_of_books a, gl_periods b
       WHERE a.set_of_books_id = (select set_of_books_id FROM
                                       ozf_sys_parameters_all WHERE org_id = p_org_id)
          AND b.period_set_name = a.period_set_name
          AND b.period_type=quarter_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);
*/
    CURSOR period_month
    IS
       SELECT b.period_name, b.period_num
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=month_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);

    CURSOR period_quarter
    IS
       SELECT b.period_name, b.period_num
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=quarter_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);

    CURSOR period_year
    IS
       SELECT b.period_name
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=year_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_month;
  FETCH period_month INTO x_month, x_month_num;

  IF period_month%NOTFOUND THEN
     CLOSE period_month;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_month;

  OPEN period_quarter;
  FETCH period_quarter INTO x_quarter, x_quarter_num;

  IF period_quarter%NOTFOUND THEN
     CLOSE period_quarter;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_quarter;

  OPEN period_year;
  FETCH period_year INTO x_year;

  IF period_year%NOTFOUND THEN
     CLOSE period_year;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_year;

  --ams_utility_pvt.debug_message('fiscal year    --' || x_year);
  --ams_utility_pvt.debug_message('fiscal quarter --' || x_quarter);
  --ams_utility_pvt.debug_message('fiscal month   --' || x_month);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      RAISE;

END GET_FISCAL_DATA;

-------------------------------------------------------------------------------
-- FUNCTION
--    GET_FISCAL_MONTH
--
-- Note
--    This procedure will get the fiscal month
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_FISCAL_MONTH
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN VARCHAR2 IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_fiscal_month';
    l_month                    VARCHAR2(30);

    CURSOR period_info
    IS
       SELECT b.period_name
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          --AND b.period_type=month_type
          AND b.period_type=month_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_info;
  FETCH period_info INTO l_month;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  --ams_utility_pvt.debug_message('fiscal month   --' || l_month);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_month);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_FISCAL_MONTH;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_FISCAL_QTR
--
-- Note
--    This procedure will get the fiscal qtr
--    given date and org_id.
-------------------------------------------------------------------------------
FUNCTION GET_FISCAL_QTR
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN VARCHAR2 IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_fiscal_qtr';
    l_qtr                      VARCHAR2(30);

    CURSOR period_info
    IS
       SELECT b.period_name
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=quarter_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);
BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_info;
  FETCH period_info INTO l_qtr;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  --ams_utility_pvt.debug_message('fiscal quarter --' || l_qtr);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_qtr);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_FISCAL_QTR;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_FISCAL_YEAR
--
-- Note
--    This procedure will get the fisical qtr
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_FISCAL_YEAR
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN VARCHAR2 IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_fiscal_year';
    l_year                     VARCHAR2(30);

    CURSOR period_info
    IS
       SELECT b.period_name year
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=year_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_info;
  FETCH period_info INTO l_year;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  --ams_utility_pvt.debug_message('fisical year    --' || l_year);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_year);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_FISCAL_YEAR;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_FISCAL_QTR_NUM
--
-- Note
--    This procedure will get the fisical qtr number
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_FISCAL_QTR_NUM
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN NUMBER IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_fiscal_qtr_num';
    l_period_num               NUMBER;

    CURSOR period_info
    IS
       SELECT b.period_num period_num
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=quarter_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_info;
  FETCH period_info INTO l_period_num;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  --ams_utility_pvt.debug_message('fisical quarter period num--' || l_period_num);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_period_num);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_FISCAL_QTR_NUM;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_PRE_PERIOD
--
-- Note
--    This procedure will get the previous period name
--    given current period name , type and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_PRE_PERIOD
   ( p_name                 IN VARCHAR2
    ,p_type                 IN VARCHAR2
    ,p_org_id                  IN  NUMBER
    ) RETURN VARCHAR2 IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_pre_period';
    l_name                    VARCHAR2(30);

    CURSOR period_name IS
      SELECT period_name
      FROM gl_periods
      WHERE end_date =( SELECT start_date -1
                        FROM gl_periods
                        WHERE period_name =p_name
                        AND period_set_name = default_calender)
      AND period_set_name = default_calender
      AND UPPER(period_type) =p_type;

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_name;
  FETCH period_name INTO l_name;

  IF period_name%NOTFOUND THEN
     CLOSE period_name;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_name;

  --ams_utility_pvt.debug_message('fisical month   --' || l_month);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_name);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_name || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_name || ' ' ||p_type||' '|| p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_name || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_name || ' ' ||p_type||' '|| p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_PRE_PERIOD;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_MONTH_ORDER
--
-- Note
--    This procedure will get the fsical month number
--    given month name and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_MONTH_ORDER
   (
     p_month                   IN  VARCHAR2
    ,p_org_id                  IN  NUMBER
    ) RETURN NUMBER IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_month_order';
    l_period_num               NUMBER;

    CURSOR period_info
    IS
       SELECT b.period_num period_num
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=month_type
          AND b.period_name =p_month;
BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_info;
  FETCH period_info INTO l_period_num;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  --ams_utility_pvt.debug_message('fisical quarter period num--' || l_period_num);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_period_num);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_month || ' ' || SQLERRM(SQLCODE));
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_month || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_month || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_month || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_MONTH_ORDER;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_FISCAL_MONTH_NUM
--
-- Note
--    This procedure will get the fsical month number
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_FISCAL_MONTH_NUM
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN NUMBER IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_fiscal_month_num';
    l_period_num               NUMBER;

    CURSOR period_info
    IS
       SELECT b.period_num period_num
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=month_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_info;
  FETCH period_info INTO l_period_num;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  --ams_utility_pvt.debug_message('fisical quarter period num--' || l_period_num);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_period_num);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_FISCAL_MONTH_NUM;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_FISCAL_ROLL_YEAR_START
--
-- Note
--    This procedure will get the start of the fiscal year
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_FISCAL_ROLL_YEAR_START
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_fiscal_roll_year_start';
    l_date                     DATE;

/*
    CURSOR period_info(v_date DATE)
    IS
       SELECT b.start_date
       FROM gl_sets_of_books a, gl_periods b
       WHERE a.set_of_books_id = (select set_of_books_id FROM
                                       ozf_sys_parameters_all WHERE org_id = p_org_id)
          AND b.period_set_name = a.period_set_name
          AND b.period_type=quarter_type
          AND TRUNC(v_date) >= TRUNC(b.start_date)
          AND TRUNC(v_date) <= TRUNC(b.end_date);
*/
    CURSOR period_info(v_date DATE)
    IS
       SELECT b.start_date
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=quarter_type
          AND TRUNC(v_date) >= TRUNC(b.start_date)
          AND TRUNC(v_date) <= TRUNC(b.end_date);

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');

  OPEN period_info(p_input_date);
  FETCH period_info INTO l_date;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  OPEN period_info(l_date-1);
  FETCH period_info INTO l_date;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  OPEN period_info(l_date-1);
  FETCH period_info INTO l_date;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  OPEN period_info(l_date-1);
  FETCH period_info INTO l_date;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  --ams_utility_pvt.debug_message('fisical year    --' || l_year);
  --ams_utility_pvt.debug_message('fisical quarter --' || l_qtr);
  --ams_utility_pvt.debug_message('fisical month   --' || l_month);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_date);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_FISCAL_ROLL_YEAR_START;

-------------------------------------------------------------------------------
-- FUNCTION
--    GET_PRE_FISCAL_ROLL_YEAR_START
--
-- Note
--    This procedure will get the previous start of the rolling fiscal year
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_PRE_FISCAL_ROLL_YEAR_START
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_pre_fiscal_roll_year_start';
    l_date                     DATE;



BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  l_date :=get_fiscal_roll_year_start(p_input_date, p_org_id);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');
  l_date := l_date-1;
  l_date := get_fiscal_roll_year_start(l_date, p_org_id);
  RETURN(l_date);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_PRE_FISCAL_ROLL_YEAR_START;

-------------------------------------------------------------------------------
-- FUNCTION
--    GET_PRE_FISCAL_ROLL_YEAR_END
--
-- Note
--    This procedure will get the previous start of the rolling fiscal year
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_PRE_FISCAL_ROLL_YEAR_END
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_pre_fiscal_roll_year_end';
    l_date                     DATE;
    l_delta                    NUMBER;

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  l_date :=get_fiscal_roll_year_start(p_input_date, p_org_id);
  l_delta :=p_input_date- l_date;
  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');
  l_date := l_date-1;
  l_date := get_fiscal_roll_year_start(l_date, p_org_id);
  l_date :=l_date +l_delta;
  RETURN(l_date);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_PRE_FISCAL_ROLL_YEAR_END;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_FISCAL_YEAR_START
--
-- Note
--    This procedure will get the start of the fiscal year
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_FISCAL_YEAR_START
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_fiscal_year_start';
    l_date                     DATE;

/*
    CURSOR period_info
    IS
       SELECT b.start_date
       FROM gl_sets_of_books a, gl_periods b
       WHERE a.set_of_books_id = (select set_of_books_id FROM
                                       ozf_sys_parameters_all WHERE org_id = p_org_id)
          AND b.period_set_name = a.period_set_name
          AND b.period_type=year_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);
*/
    CURSOR period_info
    IS
       SELECT b.start_date
       FROM gl_periods b
       WHERE b.period_set_name = default_calender
          AND b.period_type=year_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_info;
  FETCH period_info INTO l_date;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  --ams_utility_pvt.debug_message('fisical year    --' || l_date);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_date);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_FISCAL_YEAR_START;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_FISCAL_QTR_START
--
-- Note
--    This procedure will get the start of the fiscal qtr
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_FISCAL_QTR_START
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_fiscal_qtr_start';
    l_date                     DATE;

/*
    CURSOR period_info
    IS
       SELECT b.start_date
       FROM gl_sets_of_books a, gl_periods b
       WHERE a.set_of_books_id = (select set_of_books_id FROM
                                       ozf_sys_parameters_all WHERE org_id = p_org_id)
          AND b.period_set_name = a.period_set_name
          AND b.period_type=quarter_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);
*/
    CURSOR period_info
    IS
       SELECT b.start_date
       FROM gl_periods b
       WHERE b.period_set_name = default_calender
          AND b.period_type=quarter_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_info;
  FETCH period_info INTO l_date;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  --ams_utility_pvt.debug_message('fisical year    --' || l_date);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_date);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_FISCAL_QTR_START;


-------------------------------------------------------------------------------
-- FUNCTION
--    GET_FISCAL_MONTH_START
--
-- Note
--    This procedure will get the start of the fiscal month
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_FISCAL_MONTH_START
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_fiscal_month_start';
    l_date                     DATE;

/*
    CURSOR period_info
    IS
       SELECT b.start_date
       FROM gl_sets_of_books a, gl_periods b
       WHERE a.set_of_books_id = (select set_of_books_id FROM
                                       ozf_sys_parameters_all WHERE org_id = p_org_id)
          AND b.period_set_name = a.period_set_name
          AND b.period_type=month_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);
*/
    CURSOR period_info
    IS
       SELECT b.start_date
       FROM gl_periods b
       WHERE b.period_set_name = default_calender
          AND b.period_type=month_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_info;
  FETCH period_info INTO l_date;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  --ams_utility_pvt.debug_message('fisical year    --' || l_date);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_date);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_FISCAL_MONTH_START;

/*  GET_PRE_FISCAL_QTR_START */

FUNCTION GET_PRE_FISCAL_QTR_START
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS

 l_org_id                     NUMBER;
 l_current_fiscal_qtr_start DATE;
 l_previous_fiscal_qtr_start DATE;
 l_api_name                 CONSTANT VARCHAR2(300) := 'GET_PRE_FISCAL_QTR_START';



BEGIN
         l_current_fiscal_qtr_start := get_fiscal_qtr_start(p_input_date,l_org_id);
         l_previous_fiscal_qtr_start := get_fiscal_qtr_start(l_current_fiscal_qtr_start -1,l_org_id);

  RETURN(l_previous_fiscal_qtr_start);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END  GET_PRE_FISCAL_QTR_START;


/*  GET_PRE_FISCAL_QTR_START */


/* GET_PRE_FISCAL_QTR_END */

FUNCTION GET_PRE_FISCAL_QTR_END
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS

 l_org_id                     NUMBER;
 l_current_fiscal_qtr_start  DATE;
 l_current_fiscal_qtr_end    DATE;
 l_previous_fiscal_qtr_start DATE;
 l_previous_fiscal_qtr_end  DATE;
 l_api_name                 CONSTANT VARCHAR2(300) := 'GET_PRE_FISCAL_QTR_END';
 l_diff                     NUMBER;


BEGIN

         l_current_fiscal_qtr_start := get_fiscal_qtr_start(p_input_date,l_org_id);
         l_current_fiscal_qtr_end := get_fiscal_qtr_end(p_input_date,l_org_id);
         l_previous_fiscal_qtr_start := get_fiscal_qtr_start(l_current_fiscal_qtr_start -1,l_org_id);
         l_previous_fiscal_qtr_end := get_fiscal_qtr_end(l_current_fiscal_qtr_start -1,l_org_id);

         IF (l_current_fiscal_qtr_end <> p_input_date) THEN
           l_diff :=  p_input_date - l_current_fiscal_qtr_start;
           l_previous_fiscal_qtr_end   := l_previous_fiscal_qtr_start + l_diff;
           --l_previous_fiscal_qtr_end   := l_previous_fiscal_qtr_end + 1;
         END IF;

  RETURN(l_previous_fiscal_qtr_end);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END  GET_PRE_FISCAL_QTR_END;

/* GET_PRE_FISCAL_QTR_END */

-------------------------------------------------------------------------------
-- FUNCTION
--    GET_PRE_FISCAL_YEAR_START
--
-- Note
--    This procedure will get the previous start of the fiscal year
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_PRE_FISCAL_YEAR_START
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS

 l_org_id                     NUMBER;
 l_current_fiscal_year_start DATE;
 l_previous_fiscal_year_start DATE;
 l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:GET_PRE_FISCAL_YEAR_START';



BEGIN
         l_current_fiscal_year_start := get_fiscal_year_start(p_input_date,l_org_id);
         l_previous_fiscal_year_start := get_fiscal_year_start(l_current_fiscal_year_start -1,l_org_id);

  RETURN(l_previous_fiscal_year_start);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END  GET_PRE_FISCAL_YEAR_START;

-------------------------------------------------------------------------------
-- FUNCTION
--    GET_PRE_FISCAL_YEAR_END
--
-- Note
--    This procedure will get the previous end of the fiscal year
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_PRE_FISCAL_YEAR_END
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS

 l_org_id                     NUMBER;
 l_current_fiscal_year_start  DATE;
 l_current_fiscal_year_end    DATE;
 l_previous_fiscal_year_start DATE;
 l_previous_fiscal_year_end  DATE;
 l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:GET_PRE_FISCAL_YEAR_END';
 l_diff                     NUMBER;


BEGIN

         l_current_fiscal_year_start := get_fiscal_year_start(p_input_date,l_org_id);
         l_current_fiscal_year_end := get_fiscal_year_end(p_input_date,l_org_id);
         l_previous_fiscal_year_start := get_fiscal_year_start(l_current_fiscal_year_start -1,l_org_id);
         l_previous_fiscal_year_end := get_fiscal_year_end(l_current_fiscal_year_start -1,l_org_id);
         IF (l_current_fiscal_year_end <> p_input_date) THEN
           l_diff :=  p_input_date - l_current_fiscal_year_start;
           l_previous_fiscal_year_end   := l_previous_fiscal_year_start + l_diff;
           --l_previous_fiscal_year_end   := l_previous_fiscal_year_end + 1;
         END IF;

  RETURN(l_previous_fiscal_year_end);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

END GET_PRE_FISCAL_YEAR_END;

-------------------------------------------------------------------------------
-- FUNCTION
--    GET_PRE_FISCAL_MONTH_START
--
-- Note
--    This procedure will get the previous start of the rolling fiscal year
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_PRE_FISCAL_MONTH_START
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_pre_fiscal_month_start';
    l_date                     DATE;

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  l_date :=get_fiscal_month_start(p_input_date, p_org_id);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');
  l_date := l_date-1;
  l_date := get_fiscal_month_start(l_date, p_org_id);
  RETURN(l_date);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_PRE_FISCAL_MONTH_START;

-------------------------------------------------------------------------------
-- FUNCTION
--    GET_PRE_FISCAL_MONTH_END
--
-- Note
--    This procedure will get the previous start of the rolling fiscal year
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_PRE_FISCAL_MONTH_END
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_pre_fiscal_month_end';
    l_date                     DATE;
    l_date1                     DATE;
    l_date2                     DATE;
    l_delta                    NUMBER;

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  l_date :=get_fiscal_month_start(p_input_date, p_org_id);
  l_date1 :=get_fiscal_month_end(p_input_date, p_org_id);
  l_delta :=p_input_date- l_date;
  l_date := l_date-1;
  l_date := get_fiscal_month_start(l_date, p_org_id);
  l_date2 := get_fiscal_month_end(l_date, p_org_id);
  IF (l_date1 <> p_input_date) THEN
    l_date :=l_date +l_delta;
  ELSE
    l_date := l_date2;
  END IF;
  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');
  RETURN(l_date);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_PRE_FISCAL_MONTH_END;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_FISCAL_MONTH_END
--
-- Note
--    This procedure will get the end of the fiscal month
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_FISCAL_MONTH_END
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_fiscal_month_end';
    l_date                     DATE;

/*
    CURSOR period_info
    IS
       SELECT b.end_date
       FROM gl_sets_of_books a, gl_periods b
       WHERE a.set_of_books_id = (select set_of_books_id FROM
                                       ozf_sys_parameters_all WHERE org_id = p_org_id)
          AND b.period_set_name = a.period_set_name
          AND b.period_type=month_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);
*/
    CURSOR period_info
    IS
       SELECT b.end_date
       FROM gl_periods b
       WHERE b.period_set_name = default_calender
          AND b.period_type=month_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_info;
  FETCH period_info INTO l_date;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  --ams_utility_pvt.debug_message('fisical year    --' || l_date);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_date);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_FISCAL_MONTH_END;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_FISCAL_QTR_END
--
-- Note
--    This procedure will get the end of the fiscal qtr
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_FISCAL_QTR_END
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_fiscal_qtr_end';
    l_date                     DATE;

/*
    CURSOR period_info
    IS
       SELECT b.end_date
       FROM gl_sets_of_books a, gl_periods b
       WHERE a.set_of_books_id = (select set_of_books_id FROM
                                       ozf_sys_parameters_all WHERE org_id = p_org_id)
          AND b.period_set_name = a.period_set_name
          AND b.period_type=quarter_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);
*/
    CURSOR period_info
    IS
       SELECT b.end_date
       FROM gl_periods b
       WHERE b.period_set_name = default_calender
          AND b.period_type=quarter_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_info;
  FETCH period_info INTO l_date;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  --ams_utility_pvt.debug_message('fisical year    --' || l_date);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_date);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_FISCAL_QTR_END;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_FISCAL_YEAR_END
--
-- Note
--    This procedure will get the end of the fiscal month
--    given date and org_id.
-------------------------------------------------------------------------------

FUNCTION GET_FISCAL_YEAR_END
   (
     p_input_date              IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ) RETURN DATE IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_fiscal_year_end';
    l_date                     DATE;

/*
    CURSOR period_info
    IS
       SELECT b.end_date
       FROM gl_sets_of_books a, gl_periods b
       WHERE a.set_of_books_id = (select set_of_books_id FROM
                                       ozf_sys_parameters_all WHERE org_id = p_org_id)
          AND b.period_set_name = a.period_set_name
          AND b.period_type=year_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);
*/
    CURSOR period_info
    IS
       SELECT b.end_date
       FROM gl_periods b
       WHERE b.period_set_name = default_calender
          AND b.period_type=year_type
          AND TRUNC(p_input_date) >= TRUNC(b.start_date)
          AND TRUNC(p_input_date) <= TRUNC(b.end_date);

BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN period_info;
  FETCH period_info INTO l_date;

  IF period_info%NOTFOUND THEN
     CLOSE period_info;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE period_info;

  --ams_utility_pvt.debug_message('fisical year    --' || l_date);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_date);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_input_date || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_input_date || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END GET_FISCAL_YEAR_END;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_QTR_FROM_MONTH
--
-- Note
--    This procedure will get the qtr name
--    given month name and org_id.
-------------------------------------------------------------------------------

FUNCTION  GET_QTR_FROM_MONTH
   (
     p_period_name             IN  VARCHAR2
    ,p_org_id                  IN  NUMBER
    ) RETURN VARCHAR2 IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_qtr_from_month';
    l_period_name               VARCHAR2(15);
    l_period_date               DATE;

    CURSOR cur_period_date
    IS
       SELECT b.start_date
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=month_type
          AND b.period_name =p_period_name;

    CURSOR cur_period_name(l_start_date DATE)
    IS
       SELECT b.period_name period_name
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=quarter_type
          AND TRUNC(l_start_date) >= TRUNC(b.start_date)
          AND TRUNC(l_start_date) <= TRUNC(b.end_date);
BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN cur_period_date;
  FETCH cur_period_date INTO l_period_date;

  IF cur_period_date%NOTFOUND THEN
     CLOSE cur_period_date;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE cur_period_date;

  OPEN cur_period_name(l_period_date);
  FETCH cur_period_name INTO l_period_name;

  IF cur_period_name%NOTFOUND THEN
     CLOSE cur_period_name;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE cur_period_name;

  --ams_utility_pvt.debug_message('fiscal quarter period name--' || l_period_name);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_period_name);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_period_name || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_period_name || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_period_name || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_period_name || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END  GET_QTR_FROM_MONTH;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_YEAR_FROM_MONTH
--
-- Note
--    This procedure will get the year name
--    given month name and org_id.
-------------------------------------------------------------------------------

FUNCTION  GET_YEAR_FROM_MONTH
   (
     p_period_name             IN  VARCHAR2
    ,p_org_id                  IN  NUMBER
    ) RETURN VARCHAR2 IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_year_from_qtr';
    l_period_name               VARCHAR2(15);
    l_period_date               DATE;

    CURSOR cur_period_date
    IS
       SELECT b.start_date
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=month_type
          AND b.period_name =p_period_name;

    CURSOR cur_period_name(l_start_date DATE)
    IS
       SELECT b.period_name period_name
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=year_type
          AND TRUNC(l_start_date) >= TRUNC(b.start_date)
          AND TRUNC(l_start_date) <= TRUNC(b.end_date);
BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN cur_period_date;
  FETCH cur_period_date INTO l_period_date;

  IF cur_period_date%NOTFOUND THEN
     CLOSE cur_period_date;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE cur_period_date;

  OPEN cur_period_name(l_period_date);
  FETCH cur_period_name INTO l_period_name;

  IF cur_period_name%NOTFOUND THEN
     CLOSE cur_period_name;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE cur_period_name;

  --ams_utility_pvt.debug_message('fiscal quarter period name--' || l_period_name);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_period_name);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_period_name || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_period_name || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_period_name || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_period_name || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END  GET_YEAR_FROM_MONTH;
-------------------------------------------------------------------------------
-- FUNCTION
--    GET_YEAR_FROM_QTR
--
-- Note
--    This procedure will get the year name
--    given qtr name and org_id.
-------------------------------------------------------------------------------

FUNCTION  GET_YEAR_FROM_QTR
   (
     p_period_name             IN  VARCHAR2
    ,p_org_id                  IN  NUMBER
    ) RETURN VARCHAR2 IS
    l_api_name                 CONSTANT VARCHAR2(300) := 'bim_set_of_books:get_year_from_qtr';
    l_period_name               VARCHAR2(15);
    l_period_date               DATE;

    CURSOR cur_period_date
    IS
       SELECT b.start_date
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=quarter_type
          AND b.period_name =p_period_name;

    CURSOR cur_period_name(l_start_date DATE)
    IS
       SELECT b.period_name period_name
       FROM gl_periods b
          WHERE b.period_set_name = default_calender
          AND b.period_type=year_type
          AND TRUNC(l_start_date) >= TRUNC(b.start_date)
          AND TRUNC(l_start_date) <= TRUNC(b.end_date);
BEGIN

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'START');
  OPEN cur_period_date;
  FETCH cur_period_date INTO l_period_date;

  IF cur_period_date%NOTFOUND THEN
     CLOSE cur_period_date;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE cur_period_date;

  OPEN cur_period_name(l_period_date);
  FETCH cur_period_name INTO l_period_name;

  IF cur_period_name%NOTFOUND THEN
     CLOSE cur_period_name;
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  CLOSE cur_period_name;

  --ams_utility_pvt.debug_message('fiscal quarter period name--' || l_period_name);

  ams_utility_pvt.debug_message('PUBLIC API: ' || l_api_name || 'END');

  RETURN(l_period_name);

EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_period_name || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_period_name || ' ' || p_org_id || ' '
                        || ' -- NO DATA FOUND -- ' );
      fnd_msg_pub.add;
      RAISE;

    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log,'ERROR-' || l_api_name ||  ' ' || p_period_name || ' ' || SQLERRM(SQLCODE));
      fnd_message.set_name('AMS', 'API_DEBUG_MESSAGE');
      fnd_message.set_token('ROW', l_api_name || ' ' ||
                        p_period_name || ' ' || p_org_id || ' '
                        || SQLERRM||' ' ||SQLCODE);
      fnd_msg_pub.add;
      RAISE;

END  GET_YEAR_FROM_QTR;
END BIM_SET_OF_BOOKS;

/
