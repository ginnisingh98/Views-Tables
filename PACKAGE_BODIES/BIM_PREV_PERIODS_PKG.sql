--------------------------------------------------------
--  DDL for Package Body BIM_PREV_PERIODS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_PREV_PERIODS_PKG" AS
/* $Header: bimbppb.pls 115.4 2000/07/27 17:30:12 pkm ship        $ */

PROCEDURE BIM_PREV_PERIODS(
  p_period_type             IN VARCHAR2
 ,p_start_date              IN DATE
 ,p_end_date                IN DATE
 ,p_prev_start_date     IN OUT DATE
 ,p_prev_END_date       IN OUT DATE
 )
 AS
 l_first                        number;
 l_second                       number;
 l_result                       number;
 l_current_start_num            number(15);
 l_current_END_num              number(15);

 l_current_start_year           number(15);
 l_current_END_year             number(15);

 l_prev_start_num               number;
 l_prev_END_num                 number;

 l_prev_start_year              number(15);
 l_prev_END_year                number(15);


 l_no_of_quarters               number(2);

 l_current_start_quarter_num    number(15);
 l_current_END_quarter_num      number(15);

 BEGIN

BEGIN
SELECT  period_num
        ,period_year
        ,quarter_num
 INTO    l_current_start_num
        ,l_current_start_year
        ,l_current_start_quarter_num
 FROM    gl_periods
 WHERE   start_date  =   p_start_date
 AND     period_type = p_period_type
 AND    rownum < 2;
EXCEPTION
WHEN NO_DATA_FOUND THEN
NULL;
END;

BEGIN
 SELECT  period_num
        ,period_year
        ,quarter_num
 INTO    l_current_END_num
        ,l_current_END_year

        ,l_current_END_quarter_num
 FROM   gl_periods
 WHERE  END_date  =   p_END_date
 AND    period_type = p_period_type
 AND   rownum < 2;
EXCEPTION
WHEN NO_DATA_FOUND THEN
NULL;
END;

/*----------------------------- FOR THE PERIOD TYPE MONTH -----------------------*/

IF (p_period_type = 'Month') THEN

 l_prev_start_num       :=  l_current_start_num - 1;
 l_prev_END_num         :=  l_current_END_num   - 1;


 IF (l_prev_start_num = 0) THEN
        l_prev_start_year := l_current_start_year - 1;
        l_prev_start_num := 12;
 ELSE
        l_prev_start_year := l_current_start_year;
 END IF;


 IF (l_prev_END_num = 0) THEN

        l_prev_END_year := l_current_END_year - 1;
        l_prev_END_num := 12;
 ELSE
        l_prev_END_year := l_current_END_year;
 END IF;

END IF;         /* END OF MONTH LOGIC */

/*----------------------------- FOR THE PERIOD TYPE QUARTER -----------------------*/

IF (p_period_type = 'Quarter') THEN
        l_no_of_quarters := (l_current_start_num - l_current_END_num) + 1;

 l_prev_start_num := l_current_start_num - l_no_of_quarters;
 l_prev_END_num   := l_current_END_num   - l_no_of_quarters;


 IF (l_prev_start_num = 0) THEN
        l_prev_start_num := 4;
        l_prev_start_year := l_current_start_year - 1;
 ELSE
        l_prev_start_year := l_current_start_year;

 END IF;

 IF (l_prev_END_num = 0) THEN
        l_prev_END_num := 4;
        l_prev_END_year := l_current_END_year - 1;
 ELSE
        l_prev_END_year := l_current_END_year;
 END IF;

END IF;         /* END OF QUARTER LOGIC */

/*----------------------------- FOR THE PERIOD TYPE YEAR -----------------------*/

  IF (p_period_type = 'Year') THEN
        l_prev_start_year :=  l_current_start_year - 1;
        l_prev_END_year :=  l_current_END_year - 1;

        l_prev_start_num := l_current_start_num;
        l_prev_END_num := l_current_END_num;
  END IF;       /* END OF YEAR LOGIC */


/*------------------------------------------------------------------------------*/

BEGIN
 SELECT start_date
 INTO   p_prev_start_date
 FROM   gl_periods
 WHERE  period_num  =  l_prev_start_num
 AND    period_year =  l_prev_start_year
 AND    period_type =  p_period_type
 AND    rownum < 2;
EXCEPTION
WHEN NO_DATA_FOUND THEN
NULL;
END;

BEGIN
 SELECT END_date
 INTO   p_prev_END_date
 FROM   gl_periods
 WHERE  period_num  =  l_prev_END_num
 AND    period_year =  l_prev_END_year
 AND    period_type =  p_period_type
 AND    rownum < 2;
EXCEPTION
WHEN NO_DATA_FOUND THEN
NULL;
END;


 END BIM_PREV_PERIODS;

END BIM_PREV_PERIODS_PKG ;

/
