--------------------------------------------------------
--  DDL for Package Body GMP_CALENDAR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_CALENDAR_API" AS
/* $Header: GMPCAPIB.pls 120.5.12010000.1 2008/07/30 06:15:08 appldev ship $ */

PROCEDURE  check_cal_data(
                          p_calendar_code           IN      VARCHAR2,
                          p_date               IN   DATE,
                          x_return_status      OUT  NOCOPY VARCHAR2);

PROCEDURE  check_contig_periods(
                                p_calendar_code           IN      VARCHAR2,
                                p_start_date         IN   DATE,
                                p_end_date           IN   DATE,
                                p_duration           IN   NUMBER,
                                x_return_status      OUT  NOCOPY VARCHAR2);

PROCEDURE  check_all_dates(
                           p_calendar_code           IN      VARCHAR2,
                           p_start_date         IN   DATE,
                           p_end_date           IN   DATE,
                           x_return_status      OUT  NOCOPY VARCHAR2);

/* B3194180 Rajesh D. Patangya Dynamic statement for LEAD function */
TYPE interval_typ is RECORD
(
  calendar_date   date,
  next_date       date,
  day_diff        number,
  l_working       number
);

TYPE interval_tab is table of interval_typ index by BINARY_INTEGER;
interval_record       interval_typ;

/*  Declare  Cursor Types */
TYPE  ref_cursor_typ is REF CURSOR;
/* Declare global variables */
zero_date 	DATE := sysdate - 3650 ;  /* B3278900 */
max_date 	DATE := sysdate + 3650 ;  /* B3278900 */

/*
|==========================================================================
| Procedure:                                                              |
| is_working_day                                                          |
|                                                                         |
| DESCRIPTION:                                                            |
|                                                                         |
| API returns if the date passed for a calendar is a work day or a        |
| Non Work day                                                            |
|                                                                         |
| History :                                                               |
| Sridhar 21-AUG-2003  Initial implementation                             |
==========================================================================
*/

FUNCTION is_working_day(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      BOOLEAN  := TRUE,
        p_calendar_code         IN      VARCHAR2,
        p_date                  IN      DATE,
        x_return_status         IN OUT  NOCOPY VARCHAR2
        ) RETURN BOOLEAN
IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'IS_WORKING_DAY';
  l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

CURSOR get_day_cur (c_calendar_id VARCHAR2 , c_cal_date DATE) IS
SELECT 1 FROM dual
WHERE EXISTS
(SELECT 1
FROM BOM_shift_dates sd, bom_shift_times sht
WHERE sd.calendar_code = sht.calendar_code
AND sd.shift_date = trunc(c_cal_date)
AND sd.shift_num = sht.shift_num
AND sd.calendar_code = c_calendar_id
AND sd.SEQ_NUM is NOT NULL
AND sht.to_time > sht.from_time);
--
CURSOR Cur_cal_check IS
SELECT COUNT(1)
FROM bom_Calendars
WHERE calendar_code =  p_calendar_code;

CURSOR Cur_cal_date IS
SELECT 	calendar_start_date,
 	calendar_end_date
FROM bom_calendars
WHERE calendar_code =  p_calendar_code;

l_duration NUMBER := 0 ;
v_min_date  date ;
v_max_date  date;
l_count    NUMBER := 0;

  /* Define Exceptions */
  CALENDAR_REQUIRED            EXCEPTION;
  INVALID_DATA_PASSED          EXCEPTION;
  INVALID_VERSION              EXCEPTION;
  DATE_OUT_OF_CAL_RANGE        EXCEPTION;
  PS_INVALID_CALENDAR          EXCEPTION;
  X_msg    varchar2(2000) := '';

BEGIN

    /* Set the return status to success initially */
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( GMP_CALENDAR_API.m_api_version
                                        ,p_api_version
                                        ,'IS_WORKING_DAY'
                                        ,GMP_CALENDAR_API.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE INVALID_VERSION;
    END IF;

    IF ((p_calendar_code is NOT NULL) AND (p_date is NOT NULL ))
    THEN

       /* Check if the Calendar Id passed is Valid or Nor */
       OPEN Cur_cal_check;
       FETCH Cur_cal_check into l_count;
       CLOSE Cur_cal_check;

       IF l_count = 0
       THEN
          RAISE  PS_INVALID_CALENDAR;
       END IF;
       /* Check If Date passed is Out of Calendar Range first */
       OPEN Cur_cal_date;
       FETCH Cur_cal_date INTO v_min_date,v_max_date;
       CLOSE Cur_cal_date;

       IF  ((p_date < v_min_date) OR (p_date > v_max_date ))
       THEN
         RAISE DATE_OUT_OF_CAL_RANGE;
       END IF;

--
           OPEN get_day_cur(p_calendar_code , p_date) ;
           FETCH get_day_cur INTO l_duration ;
           CLOSE get_day_cur ;

           IF l_duration > 0 THEN
              RETURN TRUE ;
           ELSE
              RETURN FALSE ;
           END IF ;
    ELSE
       x_return_status := 'E';
       X_msg := 'Calendar/Date ';
       RAISE CALENDAR_REQUIRED;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Completed '||l_api_name ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));

EXCEPTION
    WHEN INVALID_DATA_PASSED OR invalid_version THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     RETURN FALSE ;

    WHEN CALENDAR_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;
     RETURN FALSE ;

    WHEN DATE_OUT_OF_CAL_RANGE  THEN
     x_return_status  := FND_API.G_RET_STS_SUCCESS;
     FND_MESSAGE.SET_NAME('GMP','GMP_DATE_OUT_OF_CAL_RANGE');
     FND_MSG_PUB.ADD;
     RETURN TRUE;

   WHEN PS_INVALID_CALENDAR   THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('GMP','PS_INVALID_CALENDAR');
        FND_MSG_PUB.ADD;
        RETURN FALSE ;

    WHEN OTHERS  THEN
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.g_ret_sts_unexp_error;
     RETURN FALSE ;
END is_working_day;

/*
|==========================================================================
| Procedure:                                                                |
|  get_contiguous_periods                                                   |
|                                                                           |
|  DESCRIPTION:                                                             |
|                                                                           |
|  The API calculates contiguous periods for a given Calendar Id, Start or
|  End Date and a duration. If Start Date is given the duration is calculated
|  from the Start date and the calendar dates and durations are returned, If
|  end date is given, the duration is calculated from the end date backwards
|  and the calendar dates and the durations are returned in a Output PL/sql
|  table
|
|  History :
|  Abhay   08/21/2003   Initial implementation
|  Sridhar   10/08/2003   Added CEIL function for Date Differences         |
|                         B3167015                                         |
|  Sridhar   03/24/2004   CEIL Function is used wherever remaining         |
|                         duration assignment is used                      |
+========================================================================== +
*/

PROCEDURE get_contiguous_periods(
        p_api_version           IN             NUMBER,
        p_init_msg_list         IN             BOOLEAN  := TRUE,
        p_start_date            IN             DATE,
        p_end_date              IN             DATE,
        p_calendar_code         IN             VARCHAR2,
        p_duration              IN             NUMBER,
        p_output_tbl            OUT     NOCOPY contig_period_tbl,
        x_return_status         IN OUT  NOCOPY VARCHAR2
       )IS

CURSOR start_date_cur (c_calendar_code  VARCHAR2,
                       c_start_date  DATE) IS
SELECT sd.shift_date calendar_date,
	   sd.shift_num shift_num,
	   st.from_time from_time,
       	   decode(sign(st.to_time - st.from_time),1,(st.to_time - st.from_time),0,0,((86400 - st.from_time)+ st.from_time)) duration,
	   st.to_time to_time
FROM  bom_calendars cal,
	  bom_shift_dates sd,
	  bom_shift_times st
WHERE cal.calendar_code = c_calendar_code
AND sd.calendar_code = cal.calendar_code
AND st.calendar_code = sd.calendar_code
AND sd.shift_num = st.shift_num
AND sd.seq_num IS NOT NULL
AND (sd.shift_date + (st.from_time + decode(sign(st.to_time - st.from_time),1,(st.to_time - st.from_time),0,0,((86400 - st.from_time)+ st.from_time)))/86400) > c_start_date
ORDER BY sd.shift_date ,
	 st.from_time ,
	 st.to_time ;

CURSOR end_date_cur (c_calendar_code VARCHAR2,
                       c_end_date  DATE) IS
SELECT sd.shift_date calendar_date,
	   sd.shift_num shift_num,
	   st.from_time from_time,
       	   decode(sign(st.to_time - st.from_time),1,(st.to_time - st.from_time),0,0,((86400 - st.from_time)+ st.from_time)) duration,
	   st.to_time to_time
FROM  bom_calendars cal,
	  bom_shift_dates sd,
	  bom_shift_times st
WHERE cal.calendar_code = c_calendar_code
AND sd.calendar_code = cal.calendar_code
AND st.calendar_code = sd.calendar_code
AND sd.shift_num = st.shift_num
AND sd.seq_num IS NOT NULL
AND (sd.shift_date + st.from_time/86400) < c_end_date
ORDER BY sd.shift_date DESC,
	 (st.from_time + decode(sign(st.to_time - st.from_time),1,(st.to_time - st.from_time),0,0,((86400 - st.from_time)+ st.from_time)))  DESC,
	 st.from_time DESC ;

o_cnt          INTEGER := 0 ;
i          	INTEGER := 1 ;
remaining_duration NUMBER := 0;
previous_start_date DATE  ;
current_start_date DATE ;
current_end_date   DATE ;
previous_end_date  DATE ;
contig_start_date  DATE ;
contig_end_date  DATE ;
contig_duration    NUMBER := 0 ;

/* Local variable section */

  l_api_name              CONSTANT VARCHAR2(30) := 'GET_CONTIGUOUS_PERIODS';
  l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  /* Define Exceptions */
  CALENDAR_REQUIRED                  EXCEPTION;
  CONTIG_PERIODS_FAILURE             EXCEPTION;
  INVALID_VERSION                    EXCEPTION;
  ZERO_DURATION                      EXCEPTION;
  X_msg    			varchar2(2000) := '';
  l_date                        DATE;

BEGIN

   /* Set the return status to success initially */
  x_return_status  := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
  IF p_init_msg_list THEN
     fnd_msg_pub.initialize;
  END IF;

    /* Make sure we are call compatible */
  IF NOT FND_API.compatible_api_call ( GMP_CALENDAR_API.m_api_version
                                        ,p_api_version
                                        ,'GET_CONTIGUOUS_PERIODS'
                                        ,GMP_CALENDAR_API.m_pkg_name) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE INVALID_VERSION;
  END IF;

  /* { */
  IF (p_calendar_code is NOT NULL) AND ((p_start_date is NOT NULL) OR
                                      (p_end_date is NOT NULL))  AND
     (p_duration is NOT NULL )
  THEN
     check_contig_periods(
                           p_calendar_code,
                           p_start_date,
                           p_end_date,
                           p_duration,
                           l_return_status
                         );
     /* { */
     IF l_return_status = 'E'
     THEN
        RAISE CONTIG_PERIODS_FAILURE;
     ELSE
        /* Handling the 0 duration case right before the Looping starts */
        IF (p_duration = 0)
        THEN
            IF (p_start_date is NOT NULL)
            THEN
                l_date := p_start_date;
            ELSIF(p_end_date is NOT NULL)
            THEN
                l_date := p_end_date;
            END IF;

            p_output_tbl(1).start_date :=  l_date ;
            p_output_tbl(1).duration := 0;
            p_output_tbl(1).end_date := l_date;
            RAISE ZERO_DURATION;
        END IF;
--
--        remaining_duration  := p_duration * 3600 ;
        remaining_duration  := CEIL(p_duration * 3600) ;  /* B3361082 */
        /* B3361082 - CEIL is used, where remaining_duration value is assigned */

        IF p_start_date is NOT NULL THEN
        /* { */
          current_start_date  := zero_date ;
          current_end_date    := zero_date ;
          contig_start_date   := zero_date ;
          contig_end_date     := zero_date ;
          previous_end_date   := zero_date ;
          previous_start_date := zero_date ;

         x_return_status := 'S';
--
         FOR cur_rec in start_date_cur (p_calendar_code, p_start_date)
         LOOP
           IF cur_rec.calendar_date + (cur_rec.from_time /86400)  >
                                                        previous_end_date THEN
             current_start_date := cur_rec.calendar_date +
                                            cur_rec.from_time /86400 ;
           END IF ;
           IF (current_start_date <> previous_start_date AND
              previous_start_date <> zero_date ) OR
              remaining_duration <= 0  THEN
              o_cnt := o_cnt + 1 ;
              p_output_tbl(o_cnt).start_date :=  contig_start_date ;
              p_output_tbl(o_cnt).duration := (contig_duration/3600) ;
              p_output_tbl(o_cnt).end_date := p_output_tbl(o_cnt).start_date + (p_output_tbl(o_cnt).duration)/24;
              contig_start_date := zero_date ;
           END IF ;
           IF remaining_duration <= 0 THEN
             EXIT ;
           END IF ;

           IF cur_rec.calendar_date +
             ((cur_rec.from_time+cur_rec.duration) /86400) > current_end_date
           THEN
             current_end_date := cur_rec.calendar_date + ((cur_rec.from_time + cur_rec.duration)/86400) ;
           END IF ;
--
           IF p_start_date > current_start_date AND
             p_start_date < current_end_date THEN
             contig_start_date := p_start_date ;
           ELSE
             contig_start_date := current_start_date ;
           END IF ;
--
           IF current_start_date = previous_start_date THEN
             IF current_end_date > previous_end_date THEN
                IF remaining_duration >
                   CEIL((current_end_date - previous_end_date ) * 86400) THEN
                    contig_duration := contig_duration + CEIL((current_end_date - previous_end_date ) * 86400) ;
                    remaining_duration := CEIL(remaining_duration - CEIL((current_end_date - previous_end_date ) * 86400)) ;
                ELSE
                    contig_duration := contig_duration + remaining_duration ;
                   remaining_duration := CEIL(remaining_duration - remaining_duration) ;
                END IF ;
             END IF ;
           ELSE
             IF remaining_duration <
               CEIL((current_end_date - contig_start_date ) * 86400) THEN
               contig_duration := remaining_duration ;
               remaining_duration := CEIL(remaining_duration - contig_duration) ;
             ELSE
               IF remaining_duration >
                 CEIL((current_end_date - contig_start_date ) * 86400) THEN
                  contig_duration :=
                        (current_end_date - contig_start_date ) * 86400 ;
                  remaining_duration := CEIL(remaining_duration - contig_duration) ;
               ELSE
                 contig_duration :=  remaining_duration ;
                 remaining_duration := CEIL(remaining_duration - remaining_duration) ;
               END IF;
             END IF ;
           END IF ;
           IF previous_start_date = zero_date  AND
              remaining_duration <= 0  THEN
              o_cnt := o_cnt + 1 ;
              p_output_tbl(o_cnt).start_date := contig_start_date ;
              p_output_tbl(o_cnt).duration := (contig_duration/3600) ;
              p_output_tbl(o_cnt).end_date := p_output_tbl(o_cnt).start_date + (p_output_tbl(o_cnt).duration)/24;
              EXIT ;
           END IF ;

           previous_start_date := current_start_date ;
           previous_end_date   := current_end_date ;
         END LOOP ;

         IF remaining_duration > 0 THEN
            p_output_tbl.DELETE ;
         END IF ;

/* } */
-- ====***===***===***===***END DATE***===***===***===***===***===
/* { */
       ELSIF p_end_date is NOT NULL THEN
           current_start_date  := max_date ;
           current_end_date    := max_date ;
           contig_start_date   := max_date ;
           contig_end_date     := max_date ;
           previous_end_date   := max_date ;
           previous_start_date := max_date ;
           x_return_status := 'S';
--

        FOR cur_rec in end_date_cur (p_calendar_code, p_end_date)
        LOOP

          IF cur_rec.calendar_date + ((cur_rec.from_time + cur_rec.duration) /86400) <
              previous_start_date THEN
            current_end_date := cur_rec.calendar_date + ((cur_rec.from_time+cur_rec.duration) /86400) ;
          END IF ;

          IF (current_end_date <> previous_end_date AND
              previous_end_date <> max_date ) OR
              remaining_duration <= 0  THEN
              o_cnt := o_cnt + 1 ;
              p_output_tbl(o_cnt).start_date :=
                             contig_end_date - contig_duration/86400 ;
              p_output_tbl(o_cnt).duration := (contig_duration/3600) ;
          p_output_tbl(o_cnt).end_date := p_output_tbl(o_cnt).start_date + (p_output_tbl(o_cnt).duration)/24;
          END IF ;

          IF remaining_duration <= 0 THEN
             EXIT ;
          END IF ;

          IF cur_rec.calendar_date + (cur_rec.from_time /86400) <
             current_start_date THEN
             current_start_date := cur_rec.calendar_date + (cur_rec.from_time /86400) ;
          END IF ;

          IF p_end_date > current_start_date AND p_end_date <
                                                current_end_date THEN
             contig_end_date := p_end_date ;
          ELSE
             contig_end_date := current_end_date ;
          END IF ;
 /*  ----------NEW------------- */
          IF current_end_date = previous_end_date THEN
             IF current_start_date < previous_start_date THEN
                IF remaining_duration >
                      CEIL((previous_start_date - current_start_date ) * 86400) THEN
                   contig_duration := contig_duration + CEIL((previous_start_date - current_start_date ) * 86400) ;
                   remaining_duration := CEIL(remaining_duration - CEIL((previous_start_date - current_start_date ) * 86400)) ;
                ELSE
                   contig_duration := contig_duration + remaining_duration ;
                   remaining_duration := CEIL(remaining_duration - remaining_duration);
                END IF ;
            END IF ;
          ELSE
            IF p_duration * 3600 <
                     CEIL((current_start_date - contig_end_date ) * 86400) THEN
               contig_duration := p_duration * 3600 ;
               remaining_duration := CEIL(remaining_duration - contig_duration) ;
            ELSE
              IF remaining_duration >
                     CEIL((contig_end_date - current_start_date ) * 86400) THEN
                 contig_duration :=
                     (contig_end_date - current_start_date) * 86400 ;
                 remaining_duration := CEIL(remaining_duration - contig_duration);
             ELSE
                 contig_duration :=  remaining_duration ;
                 remaining_duration := CEIL(remaining_duration - remaining_duration);
             END IF;
            END IF ;
          END IF ;
          IF previous_end_date = max_date  AND
             remaining_duration <= 0  THEN
             o_cnt := o_cnt + 1 ;
             p_output_tbl(o_cnt).start_date := contig_end_date - (p_duration/24) ;
             p_output_tbl(o_cnt).duration := (contig_duration/3600) ;
          p_output_tbl(o_cnt).end_date := p_output_tbl(o_cnt).start_date + (p_output_tbl(o_cnt).duration)/24;
             EXIT ;
          END IF ;

          previous_start_date := current_start_date ;
          previous_end_date   := current_end_date ;

        END LOOP ;

        IF remaining_duration > 0 THEN
            p_output_tbl.DELETE ;
        END IF ;

       ELSE
            FND_MESSAGE.SET_NAME('GMP','GMP_ENTER_START_OR_END_DATE');
            FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;

     /* } */
       END IF ;
     /* } */
     END IF;
  ELSE
       x_return_status := 'E';
       X_msg := 'Calendar/Start or End Date ';
       RAISE CALENDAR_REQUIRED;
       FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
       FND_MSG_PUB.ADD;
  END IF;
  /* } */

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Completed '||l_api_name ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));


  EXCEPTION
    WHEN CONTIG_PERIODS_FAILURE OR INVALID_VERSION THEN
         x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN CALENDAR_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;

    WHEN ZERO_DURATION THEN
    NULL;

    WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
END get_contiguous_periods;
/*
==========================================================================
 Procedure:
  check_contig_periods

  DESCRIPTION:

  The following Procedure checks the data passed and Returns S code If
  Successful

  History :
  Sgidugu 08/21/2003   Initial implementation
==========================================================================
*/
PROCEDURE  check_contig_periods(
                                p_calendar_code      IN      VARCHAR2,
                                p_start_date         IN   DATE,
                                p_end_date           IN   DATE,
                                p_duration           IN   NUMBER,
                                x_return_status      OUT  NOCOPY VARCHAR2) IS

CURSOR Cur_cal_check ( c_calendar_code  VARCHAR2 ) IS
SELECT COUNT(1)
FROM bom_Calendars
WHERE calendar_code =  c_calendar_code;

CURSOR Cur_cal_date ( c_calendar_code  VARCHAR2 ) IS
SELECT calendar_start_date ,
       calendar_end_date
FROM bom_Calendars
WHERE calendar_code =  c_calendar_code;

v_min_date   date;
v_max_date   date;

INVALID_DATE_RANGE  EXCEPTION;
CALENDAR_NULL       EXCEPTION;
INVALID_VALUE       EXCEPTION;
GMP_DATE_NOT_IN_CAL_RANGE  EXCEPTION;
ENTER_START_OR_END_DATE    EXCEPTION;
PS_INVALID_CALENDAR    EXCEPTION;

X_field      varchar2(2000) := '';
X_value      varchar2(2000) := '';
X_msg        varchar2(2000) := '';
l_count      number := 0;

begin
    x_return_status := 'S';

    OPEN Cur_cal_date (p_calendar_code);
    FETCH Cur_cal_date into v_min_date,v_max_date;
    CLOSE Cur_cal_date;

    if p_duration < 0
    then
        x_return_status := 'E';
        X_field := 'Duration';
        X_value := p_duration;
        RAISE INVALID_VALUE;
    end if;

    /*  We could write an ELSE condition to make the logic complete, but is
        not needed as calling proc makes sure one and only one date is NOT NULL
    */

    IF p_start_date IS NOT NULL THEN
       IF (p_start_date < v_min_date) OR (p_start_date > v_max_date)
       THEN
           x_return_status := 'E';
           RAISE GMP_DATE_NOT_IN_CAL_RANGE;
       END IF;
    ELSIF p_end_date IS NOT NULL THEN
       IF (p_end_date < v_min_date) OR (p_end_date > v_max_date)
       THEN
           x_return_status := 'E';
           RAISE GMP_DATE_NOT_IN_CAL_RANGE;
       END IF;
    END IF ;

    OPEN Cur_cal_check (p_calendar_code);
    FETCH Cur_cal_check INTO l_count;
    CLOSE Cur_cal_check;
--
    IF l_count = 0
    THEN
       RAISE  PS_INVALID_CALENDAR;
    END IF;
--
    /* Erroring Out when Both Start Date and End Date is Passed at the same time
  */
    if ((p_start_date is NOT NULL) AND
       (p_end_date   is NOT NULL ))
    then
        x_return_status := 'E';
        RAISE ENTER_START_OR_END_DATE;
    end If;


EXCEPTION
   WHEN GMP_DATE_NOT_IN_CAL_RANGE   THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Date Passed is Out of Calendar Range '||X_msg);
     FND_MESSAGE.SET_NAME('GMP','GMP_DATE_NOT_IN_CAL_RANGE');
     FND_MSG_PUB.ADD;

   WHEN ENTER_START_OR_END_DATE   THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Enter Start Or End Date '||X_msg);
     FND_MESSAGE.SET_NAME('GMP','GMP_ENTER_START_OR_END_DATE');
     FND_MSG_PUB.ADD;

   WHEN PS_INVALID_CALENDAR   THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('GMP','PS_INVALID_CALENDAR');
        FND_MSG_PUB.ADD;

    WHEN INVALID_VALUE THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Value '||X_field||'-'||X_value);
     FND_MESSAGE.SET_NAME('GMP','GMP_INVALID_VALUE');
     FND_MESSAGE.SET_TOKEN('FIELD',X_field);
     FND_MESSAGE.SET_TOKEN('VALUE',X_value);
     FND_MSG_PUB.ADD;
END check_contig_periods;

/* *****************************************************************
   Gantt Chart APIs
   *****************************************************************
==========================================================================
 Procedure:
  get_all_dates

  DESCRIPTION:

  The following Procedure gets the Working and Non-Working dates between two
  specified Start and End Dates in a Calendar

  History :
  Sgidugu 08/21/2003   Initial implementation
==========================================================================
*/

PROCEDURE get_all_dates(
        p_api_version           IN             NUMBER,
        p_init_msg_list         IN             BOOLEAN  := TRUE,
        p_calendar_code         IN             VARCHAR2,
        p_start_date            IN             DATE,
        p_end_date              IN             DATE,
        p_output_tbl            OUT     NOCOPY date_tbl,
        x_return_status         IN OUT  NOCOPY VARCHAR2
     ) IS

CURSOR get_all_dates (c_calendar_code  VARCHAR2,
                        c_start_date DATE,
                        c_end_date   DATE) IS
SELECT sd.shift_date calendar_date,
      decode(SUM(decode(sd.seq_num,NULL,0,1)),0,0,1) l_work_day
FROM  bom_calendars  cal,
      bom_shift_dates sd,
      bom_shift_times st
WHERE cal.calendar_code = c_calendar_code
AND sd.calendar_code = cal.calendar_code
AND st.calendar_code = sd.calendar_code
AND sd.shift_date BETWEEN trunc(c_start_date) AND trunc(c_end_date)
AND sd.shift_num = st.shift_num
GROUP BY sd.shift_date
ORDER BY sd.shift_date; /*B5182025 - sowsubra - added order by clause*/

 i INTEGER := 0 ;
  add_day   INTEGER := 1 ;

/* Local variable section */

  l_api_name              CONSTANT VARCHAR2(30) := 'GET_ALL_DATES';
  l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  /* Define Exceptions */
  CALENDAR_REQUIRED                  EXCEPTION;
  CHECK_ALL_DATES_FAILURE            EXCEPTION;
  INVALID_VERSION                    EXCEPTION;
  VALUE_REQUIRED                     EXCEPTION;
  INVALID_CAL_RANGE                  EXCEPTION;

  X_field  varchar2(2000) := '';
  X_value  varchar2(2000) := '';
  X_msg    varchar2(2000) := '';

BEGIN

    /* Set the return status to success initially */
  x_return_status  := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
  IF p_init_msg_list THEN
     fnd_msg_pub.initialize;
  END IF;

    /* Make sure we are call compatible */
  IF NOT FND_API.compatible_api_call ( GMP_CALENDAR_API.m_api_version
                                        ,p_api_version
                                        ,'GET_ALL_DATES'
                                        ,GMP_CALENDAR_API.m_pkg_name) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE INVALID_VERSION;
  END IF;
--
  IF p_calendar_code is NOT NULL
  THEN
      IF ((p_start_date IS NULL) OR (p_end_date IS NULL))
      THEN
          x_return_status := 'E';
          X_field := 'Start/End Date';
          X_value := p_start_date||'-'||p_end_date ;
          RAISE VALUE_REQUIRED;
      END IF;
--
      IF p_end_date < p_start_date
      THEN
          x_return_status := 'E';
          RAISE INVALID_CAL_RANGE;
      END IF;
--
      IF l_return_status = 'E'
      THEN
         RAISE check_all_dates_failure;
      ELSE
              FOR c_rec in get_all_dates (p_calendar_code, p_start_date,  p_end_date)
                LOOP
                        i := i + 1;
                        p_output_tbl(i). cal_date := c_rec.calendar_date ;
                        p_output_tbl(i). is_workday:= c_rec.l_work_day;
                END LOOP;
      END IF;
  ELSE
       x_return_status := 'E';
       X_msg := 'Calendar';
       RAISE CALENDAR_REQUIRED;
       FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
       FND_MSG_PUB.ADD;
  END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Completed '||l_api_name ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));

  EXCEPTION
    WHEN check_all_dates_failure OR invalid_version THEN
         x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN CALENDAR_REQUIRED OR VALUE_REQUIRED THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
         FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
         FND_MSG_PUB.ADD;

   WHEN INVALID_CAL_RANGE   THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','MR_INV_CALENDAR_RANGE');
     FND_MSG_PUB.ADD;

    WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.g_ret_sts_unexp_error;

END get_all_dates ;

/*
==========================================================================
 Procedure:
  get_work_days

  DESCRIPTION:

  The following Procedure gets the workdays between a specified Start and
  End dates in a Calendar

  History :
  Sgidugu 08/21/2003   Initial implementation
==========================================================================
*/

PROCEDURE get_work_days(
                         p_api_version       IN      NUMBER,
                         p_init_msg_list     IN      BOOLEAN  := TRUE,
                         p_calendar_code     IN      VARCHAR2,
                         p_start_date        IN      DATE,
                         p_end_date          IN      DATE,
                         p_output_tbl        OUT     NOCOPY workdays_tbl,
                         x_return_status     IN OUT  NOCOPY VARCHAR2
                       ) IS
CURSOR get_cal_dates (c_calendar_code  VARCHAR2,
                      c_start_date   DATE ,
                      c_end_date   DATE ) IS
SELECT sd.shift_date calendar_date,
	   SUM((st.to_time - st.from_time)/3600) duration
FROM bom_calendars cal,
	 bom_shift_dates sd,
	 bom_shift_times st
WHERE cal.calendar_code =  c_calendar_code
AND sd.calendar_code = cal.calendar_code
AND st.calendar_code = sd.calendar_code
AND sd.shift_date BETWEEN trunc(c_start_date) AND trunc(c_end_date)
AND sd.shift_num = st.shift_num
AND sd.seq_num IS NOT NULL
GROUP BY sd.shift_date
HAVING SUM((st.to_time - st.from_time)/3600) > 0 ;

i INTEGER := 0 ;
/* Local variable section */

  l_api_name              CONSTANT VARCHAR2(30) := 'GET_WORK_DAYS';
  l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  /* Define Exceptions */
  CALENDAR_REQUIRED                  EXCEPTION;
  work_days_failure                  EXCEPTION;
  INVALID_VERSION                    EXCEPTION;
  X_msg    varchar2(2000) := '';

BEGIN

    /* Set the return status to success initially */
  x_return_status  := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
  IF p_init_msg_list THEN
     fnd_msg_pub.initialize;
  END IF;

    /* Make sure we are call compatible */
  IF NOT FND_API.compatible_api_call ( GMP_CALENDAR_API.m_api_version
                                        ,p_api_version
                                        ,'GET_WORK_DAYS'
                                        ,GMP_CALENDAR_API.m_pkg_name) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE INVALID_VERSION;
  END IF;

  IF p_calendar_code is NOT NULL
  THEN
      check_all_dates (
                        p_calendar_code,
                        p_start_date,
                        p_end_date,
                        l_return_status
                      );
--
      IF l_return_status = 'E'
      THEN
         RAISE work_days_failure;
      ELSE
         FOR c_rec in get_cal_dates (p_calendar_code, p_start_date, p_end_date)
         LOOP
             i := i + 1;
             p_output_tbl(i).workday := c_rec.calendar_date ;
         END LOOP ;
      END IF;
  ELSE
       x_return_status := 'E';
       X_msg := 'Calendar';
       RAISE CALENDAR_REQUIRED;
       FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
       FND_MSG_PUB.ADD;
  END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Completed '||l_api_name ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));

  EXCEPTION
    WHEN work_days_failure OR invalid_version THEN
         x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN CALENDAR_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;

    WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.g_ret_sts_unexp_error;

END get_work_days ;

/* ==========================================================================
 Procedure:
  get_workday_details

  DESCRIPTION:

  The following Procedure gets the Workday Details for a given Shopday

  History :
  Sgidugu 08/21/2003   Initial implementation
========================================================================== */

PROCEDURE get_workday_details(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      BOOLEAN := TRUE,
        p_calendar_code		IN 	VARCHAR2,
        p_shopday_no            IN      NUMBER,
        p_output_tbl       	OUT     NOCOPY shopday_dtl_tbl,
        x_return_status         IN OUT  NOCOPY VARCHAR2
     ) IS

CURSOR shopday_dtls_cur (c_calendar_code  VARCHAR2,
                          c_shopday_no   NUMBER) IS
SELECT shift_num,from_time,to_time
FROM bom_shift_times
WHERE calendar_code = c_calendar_code
AND shift_num = c_shopday_no
ORDER BY from_time ;

CURSOR Cur_shop_day (c_calendar_code  VARCHAR2,
                          c_shopday_no   NUMBER) IS
SELECT COUNT(*)
FROM bom_shift_times
WHERE calendar_code = c_calendar_code
AND shift_num = c_shopday_no;

i INTEGER := 0 ;

/* Local variable section */

  l_api_name              CONSTANT VARCHAR2(30) := 'GET_WORKDAY_DETAILS';
  l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  /* Define Exceptions */
  SHOPDAY_NUMBER_REQUIRED            EXCEPTION;
  WORKDAY_DTLS_FAILURE               EXCEPTION;
  INVALID_VERSION                    EXCEPTION;
  INVALID_SHOPDAY                    EXCEPTION;
  X_msg     varchar2(2000) := '';
  l_count   number := 0 ;

BEGIN

    /* Set the return status to success initially */
  x_return_status  := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
  IF p_init_msg_list THEN
     fnd_msg_pub.initialize;
  END IF;

    /* Make sure we are call compatible */
  IF NOT FND_API.compatible_api_call ( GMP_CALENDAR_API.m_api_version
                                        ,p_api_version
                                        ,'GET_WORKDAY_DETAILS'
                                        ,GMP_CALENDAR_API.m_pkg_name) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE INVALID_VERSION;
  END IF;
--
  OPEN Cur_shop_day(p_calendar_code , p_shopday_no);
  FETCH Cur_shop_day INTO l_count;
  CLOSE Cur_shop_day;

  IF l_count = 0
  THEN
         x_return_status := 'E';
         RAISE INVALID_SHOPDAY;
  END IF;
--
  IF p_shopday_no is NOT NULL
  THEN
       FOR c_rec in shopday_dtls_cur (p_calendar_code , p_shopday_no) /*Parameter added - calendar id*/
       LOOP
           i := i + 1;
           p_output_tbl(i).shift_no := c_rec.shift_num ;
           p_output_tbl(i).shift_start := c_rec.from_time ;
           p_output_tbl(i).shift_duration := c_rec.to_time ;
       END LOOP ;
  ELSE
       x_return_status := 'E';
       X_msg := 'Shopday Number';
       RAISE SHOPDAY_NUMBER_REQUIRED;
       FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
       FND_MSG_PUB.ADD;
  END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Completed '||l_api_name ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));

  EXCEPTION
    WHEN INVALID_VERSION THEN
         x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN SHOPDAY_NUMBER_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;

   WHEN INVALID_SHOPDAY  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('GMP','GMP_INVALID_SHOPDAY');
        FND_MSG_PUB.ADD;

    WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.g_ret_sts_unexp_error;

END get_workday_details ;

/* ==========================================================================
 Procedure:
  check_cal_data

  DESCRIPTION:

  The following Procedure checks the data passed and Returns S code If
  Successful

  History :
  Sgidugu 08/21/2003   Initial implementation
========================================================================== */
PROCEDURE  check_cal_data(
                          p_calendar_code      IN      VARCHAR2,
                          p_date               IN   DATE,
                          x_return_status      OUT  NOCOPY VARCHAR2) IS

CURSOR Cur_cal_check IS
SELECT COUNT(1)
FROM bom_Calendars
WHERE calendar_code =  p_calendar_code;

CURSOR Cur_cal_date IS
SELECT calendar_start_date ,
       calendar_end_date
FROM bom_Calendars
WHERE calendar_code =  p_calendar_code;

GMP_SDATE_BEFORE_CAL_SDATE  EXCEPTION;
GMP_EDATE_AFTER_CAL_EDATE  EXCEPTION;
PS_INVALID_CALENDAR        EXCEPTION;

v_min_date   date;
v_max_date   date;
X_field  varchar2(2000) := '';
X_value  varchar2(2000) := '';
X_msg  varchar2(2000) := '';
l_count      number := 0;


begin
    x_return_status := 'S';

--
    OPEN Cur_cal_date;
    FETCH Cur_cal_date into v_min_date,v_max_date;
    CLOSE Cur_cal_date;
--
    if nvl(p_date,sysdate) < v_min_date
    then
        x_return_status := 'E';
        RAISE GMP_SDATE_BEFORE_CAL_SDATE;
    end if;
--
    if nvl(p_date,sysdate) > v_max_date
    then
        x_return_status := 'E';
        RAISE GMP_EDATE_AFTER_CAL_EDATE;
    end if;
--
    OPEN Cur_cal_check;
    FETCH Cur_cal_check into l_count;
    CLOSE Cur_cal_check;
--
    IF l_count = 0
    THEN
       RAISE  PS_INVALID_CALENDAR;
    END IF;


EXCEPTION
   WHEN GMP_SDATE_BEFORE_CAL_SDATE   THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('GMP','GMP_SDATE_BEFORE_CAL_SDATE');
        FND_MSG_PUB.ADD;

   WHEN PS_INVALID_CALENDAR   THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('GMP','PS_INVALID_CALENDAR');
        FND_MSG_PUB.ADD;

   WHEN GMP_EDATE_AFTER_CAL_EDATE   THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('GMP','GMP_EDATE_AFTER_CAL_EDATE');
        FND_MSG_PUB.ADD;

    WHEN OTHERS  THEN
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.g_ret_sts_unexp_error;
end check_cal_data;
/* ==========================================================================
 Procedure:
  check_all_dates

  DESCRIPTION:

  The following Procedure checks the data passed and Returns S code If
  Successful

  History :
  Sgidugu 08/21/2003   Initial implementation
========================================================================== */

PROCEDURE  check_all_dates(
                           p_calendar_code           IN      VARCHAR2,
                           p_start_date         IN   DATE,
                           p_end_date           IN   DATE,
                           x_return_status      OUT  NOCOPY VARCHAR2) IS

CURSOR Cur_cal_check (c_calendar_code VARCHAR2 ) IS
SELECT COUNT(1)
FROM bom_Calendars
WHERE calendar_code =  c_calendar_code;

INVALID_DATE_RANGE  EXCEPTION;
CALENDAR_NULL       EXCEPTION;
INVALID_VALUE       EXCEPTION;
VALUE_REQUIRED      EXCEPTION;
INVALID_CAL_RANGE   EXCEPTION;
PS_INVALID_CALENDAR   EXCEPTION;

X_field  varchar2(2000) := '';
X_value  varchar2(2000) := '';
X_msg  varchar2(2000) := '';
l_count      number := 0;


begin
    x_return_status := 'S';
--
    if ((p_start_date IS NULL) OR (p_end_date IS NULL))
    then
        x_return_status := 'E';
        X_field := 'Start/End Date';
        X_value := p_start_date||'-'||p_end_date ;
        RAISE VALUE_REQUIRED;
    end if;
--
    OPEN Cur_cal_check ( p_calendar_code );
    FETCH Cur_cal_check into l_count;
    CLOSE Cur_cal_check;
--
    IF l_count = 0
    THEN
       RAISE  PS_INVALID_CALENDAR;
    END IF;

--
/* The following lines were commented as per Eddie's recommendation

    if ((nvl(p_start_date,sysdate) < v_min_date) OR
        (nvl(p_start_date,sysdate) > v_max_date))
    then
        x_return_status := 'E';
        RAISE INVALID_DATE_RANGE;
    end If;

    if ((nvl(p_end_date,sysdate) < v_min_date) OR
        (nvl(p_end_date,sysdate) > v_max_date))
    then
        x_return_status := 'E';
        RAISE INVALID_DATE_RANGE;
    end If;
*/
--
    if p_end_date < p_start_date
    then
        x_return_status := 'E';
        RAISE INVALID_CAL_RANGE;
    end If;

EXCEPTION
    WHEN VALUE_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;
--
   WHEN INVALID_CAL_RANGE   THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','MR_INV_CALENDAR_RANGE');
     FND_MSG_PUB.ADD;
--
   WHEN PS_INVALID_CALENDAR   THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('GMP','PS_INVALID_CALENDAR');
        FND_MSG_PUB.ADD;
--
    WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.g_ret_sts_unexp_error;

end check_all_dates;

/*
|==========================================================================
| Procedure:                                                              |
| is_working_daytime                                                      |
|                                                                         |
| DESCRIPTION:                                                            |
|                                                                         |
| API returns if the date time  passed for a calendar is a work day or a  |
| Non Work day                                                            |
| The API takes Calendar_id, Date and Time and Indicator as Inputs        |
| and returns if the day is a work day or a Non-work day, The             |
| Indicator takes values 0 or 1 0 means Start and 1 means End             |
|                                                                         |
| History :                                                               |
| Sridhar 19-SEP-2003  Initial implementation                             |
|    B4610901, Rajesh Patangya 15-Sep-2005                                |
==========================================================================
*/

FUNCTION IS_WORKING_DAYTIME(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      BOOLEAN  := TRUE,
        p_calendar_code         IN      VARCHAR2,
        p_date                  IN      DATE,
	p_ind			IN	NUMBER,
        x_return_status         IN OUT  NOCOPY VARCHAR2
        ) RETURN BOOLEAN
IS
 	/* p_ind 0 means start and 1 means end */

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'IS_WORKING_DAYTIME';
  l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  x_date  date;

  CURSOR get_datetime_cur (c_calendar_code VARCHAR2, c_cal_date DATE) IS
  SELECT 1
  FROM  bom_calendars cal,
        bom_shift_dates sd,
        bom_shift_times st
  WHERE cal.calendar_code = c_calendar_code
  AND sd.calendar_code = cal.calendar_code
  AND st.calendar_code = sd.calendar_code
  AND sd.shift_num = st.shift_num
  -- B4610901, Rajesh Patangya 15-Sep-2005
  AND (sd.shift_date + (st.from_time/86400)) <= c_cal_date
  AND DECODE(
        SIGN(st.from_time - st.to_time),
	1,(sd.shift_date+1), sd.shift_date
	     ) + (st.to_time/86400) >=  c_cal_date
  AND sd.seq_num IS NOT NULL;

  /* Define Exceptions */
  CALENDAR_REQUIRED                  EXCEPTION;
  INVALID_DATA_PASSED                EXCEPTION;
  INVALID_VALUE                      EXCEPTION;
  INVALID_VERSION                    EXCEPTION;

  l_count  NUMBER := 0 ;
  X_msg    varchar2(2000) := '';
  X_field      varchar2(2000) := '';
  X_value      varchar2(2000) := '';

BEGIN

    /* Set the return status to success initially */
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( GMP_CALENDAR_API.m_api_version
                                        ,p_api_version
                                        ,'IS_WORKING_DAYTIME'
                                        ,GMP_CALENDAR_API.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE INVALID_VERSION;
    END IF;

    /* Error Out if the Indicator passed not 0 or 1 */
    IF (p_ind not in (0,1))
    THEN
        X_field := 'Indicator ';
        X_value := p_ind;
        RAISE INVALID_VALUE;

    END IF;
    IF ((p_calendar_code is NOT NULL) AND (p_date is NOT NULL ))
    THEN
       check_cal_data(
                       p_calendar_code,
                       p_date,
                       l_return_status
                     );

       IF l_return_status = 'E'
       THEN
           RAISE INVALID_DATA_PASSED;
       ELSE
	 IF p_ind = 0 THEN
		x_date := p_date + 1/86400 ;
 	 ELSIF p_ind = 1  THEN
		x_date := p_date - 1/86400 ;
	 END IF ;

           OPEN get_datetime_cur (p_calendar_code , x_date) ;
           FETCH get_datetime_cur INTO l_count ;
           CLOSE get_datetime_cur ;

           IF l_count = 1 THEN
              RETURN TRUE ;
           ELSE
              RETURN FALSE ;
           END IF ;
       END IF;
    ELSE
       x_return_status := 'E';
       X_msg := 'Calendar/Date ';
       RAISE CALENDAR_REQUIRED;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Completed '||l_api_name ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));

EXCEPTION
    WHEN INVALID_DATA_PASSED OR invalid_version THEN

     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     RETURN FALSE ;

    WHEN CALENDAR_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;
     RETURN FALSE ;

    WHEN INVALID_VALUE THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Value '||X_field||'-'||X_value);
     FND_MESSAGE.SET_NAME('GMP','GMP_INVALID_VALUE');
     FND_MESSAGE.SET_TOKEN('FIELD',X_field);
     FND_MESSAGE.SET_TOKEN('VALUE',X_value);
     FND_MSG_PUB.ADD;
     RETURN FALSE ;

    WHEN OTHERS  THEN
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.g_ret_sts_unexp_error;
     RETURN FALSE ;
END IS_WORKING_DAYTIME ;

-- Bug: 6265867 Kbanddyo added this procedure
/*
|==========================================================================
| Procedure:                                                              |
| get_nearest_workdaytime                                                 |
|                                                                         |
| DESCRIPTION:                                                            |
|                                                                         |
| The purpose of the API is to return the working date-time that is       |
| closest to the date-time passed in as parameter                         |
| When the date-time passed in is NOT work time the API either searches   |
| backwards to locate the end of previous workday OR searches forward     |
| to locate the start of next workday - this direction of search is       |
| controlled by parameter pDirection                                      |
|                                                                         |
| PARAMETERS                                                              |
|    p_direction - 0 means backwards and 1 means forward                  |
| History :                                                               |
| Abhay 24-Jul-2006  Initial implementation                               |
|                    B5378109 Teva                                        |
==========================================================================
*/

PROCEDURE get_nearest_workdaytime(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      BOOLEAN  := TRUE,
        p_calendar_id           IN      VARCHAR2,
        p_date                  IN      DATE,
        p_direction      	IN 	NUMBER,
        x_date                  IN OUT  NOCOPY DATE ,
        x_return_status         IN OUT  NOCOPY VARCHAR2
        )
IS

  CALENDAR_REQUIRED   EXCEPTION;
  INVALID_DATA_PASSED EXCEPTION;
  INVALID_VALUE       EXCEPTION;
  INVALID_VERSION     EXCEPTION;
  l_count             NUMBER ;
  X_msg               VARCHAR2(2000) ;
  X_field             VARCHAR2(2000) ;
  X_value             VARCHAR2(2000) ;
  l_api_name          CONSTANT VARCHAR2(30) := 'GET_NEAREST_WORKDAYTIME';
  l_return_status     VARCHAR2(1) ;
  l_date              DATE;

CURSOR Is_WorkDayTime (p_calendar_id VARCHAR2 , p_cal_date DATE) IS
SELECT 1
FROM sys.dual
WHERE EXISTS (
select 'x'
              FROM bom_calendars  bd,
                   bom_shift_dates sd,
                    bom_shift_times st
              WHERE bd.calendar_code = p_calendar_id
                 AND sd.calendar_code = bd.calendar_code
                AND sd.calendar_code= st.calendar_code
                AND sd.shift_num = st.shift_num
                AND (sd.shift_date + (st.from_time/86400))   <= p_date
				AND sd.seq_num IS NOT NULL
                AND ((decode(sign(st.from_time + (st.to_time- st.from_time) - 86400),1,
                     (sd.shift_date+1),sd.shift_date) ) +
                     (decode(sign(st.from_time + (st.to_time- st.from_time)  - 86400),1,
                     (st.from_time + (st.to_time- st.from_time)  - 86400),
                     (st.from_time + (st.to_time- st.from_time)))/86400 ) ) >= p_date);


CURSOR get_NextDatetime_cur (p_calendar_id VARCHAR2 , p_cal_date DATE) IS
SELECT min (sd.shift_date + (st.from_time/86400))
FROM bom_calendars  bd,
     bom_shift_dates sd,
     bom_shift_times st
WHERE bd.calendar_code = p_calendar_id
  AND sd.calendar_code = bd.calendar_code
  AND sd.calendar_code= st.calendar_code
  AND sd.shift_num = st.shift_num
  AND sd.seq_num IS NOT NULL
  AND (st.to_time- st.from_time)  > 0
  AND (sd.shift_date + (st.from_time/86400))   > p_cal_date ;


CURSOR get_PrevDatetime_cur (p_calendar_id VARCHAR2 , p_cal_date DATE) IS
 SELECT max (
((decode(sign(st.from_time + (st.to_time- st.from_time)  - 86400),1,
    (sd.shift_date+1),sd.shift_date) ) +
    (decode(sign(st.from_time + (st.to_time- st.from_time)  - 86400),1,(st.from_time
    + (st.to_time- st.from_time)  - 86400),(st.from_time + (st.to_time- st.from_time)))/86400 )  )
)
FROM bom_calendars  bd,
     bom_shift_dates sd,
     bom_shift_times st
WHERE bd.calendar_code = p_calendar_id
  AND sd.calendar_code = bd.calendar_code
  AND sd.calendar_code= st.calendar_code
  AND sd.shift_num = st.shift_num
  AND sd.seq_num IS NOT NULL
  AND (st.to_time- st.from_time)  > 0
  AND ((decode(sign(st.from_time + (st.to_time- st.from_time)  - 86400),1,
    (sd.shift_date+1),sd.shift_date) ) +
    (decode(sign(st.from_time + (st.to_time- st.from_time)  - 86400),1,(st.from_time
    + (st.to_time- st.from_time)  - 86400),(st.from_time + (st.to_time- st.from_time)))/86400 ))
< p_date;

BEGIN

  l_count  := 0 ;
  X_msg    := '';
  X_field  := '';
  X_value  := '';
  l_date   := NULL;
  l_return_status := FND_API.G_RET_STS_SUCCESS;
  x_return_status  := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( GMP_CALENDAR_API.m_api_version
                                        ,p_api_version
                                        ,'GET_NEAREST_WORKDAYTIME'
                                        ,GMP_CALENDAR_API.m_pkg_name) THEN
       FND_FILE.PUT_LINE ( FND_FILE.LOG,'if not FND_API.compatible_api_call');
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_date := (sysdate - 9999 ) ;
       RAISE INVALID_VERSION;
    END IF;

    /* Error Out if the Indicator passed not 0 or 1 */


    IF (p_direction not in (0,1))
    THEN
        X_field := 'Direction ';
        X_value := p_direction;

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_date := (sysdate - 9999 ) ;
        RAISE INVALID_VALUE;

    END IF;

    IF ((p_calendar_id is NOT NULL) AND (p_date is NOT NULL )) THEN
       check_cal_data(
                       p_calendar_id,
                       p_date,
                       l_return_status
                     );




FND_FILE.PUT_LINE ( FND_FILE.LOG,p_calendar_id);
FND_FILE.PUT_LINE ( FND_FILE.LOG,to_char(p_date,'dd/mm/yyyy hh24:mi:ss'));

	IF l_return_status = 'E' THEN

	    FND_FILE.PUT_LINE ( FND_FILE.LOG,'IF l_return_status = E');
        	x_return_status := FND_API.G_RET_STS_ERROR;
                x_date := (sysdate - 9999 ) ;
		RAISE INVALID_DATA_PASSED;
	ELSE
		OPEN Is_WorkDayTime(p_calendar_id , p_date) ;
       		FETCH Is_WorkdayTime INTO l_count ;
	       	CLOSE Is_WorkdayTime ;

       		IF l_count = 1 THEN
                      x_return_status  := FND_API.G_RET_STS_SUCCESS;
                      x_date := p_date ;
       		ELSE
			IF p_direction = 1 THEN
       				OPEN get_NextDatetime_cur(p_calendar_id , p_date) ;
	       			FETCH get_NextDatetime_cur INTO l_date ;
	       			CLOSE get_NextDatetime_cur ;

			ELSE
		       		OPEN get_PrevDatetime_cur(p_calendar_id , p_date) ;
	       			FETCH get_PrevDatetime_cur INTO l_date ;
	       			CLOSE get_PrevDatetime_cur ;
        	END IF ;
			l_return_status := FND_API.G_RET_STS_SUCCESS;
                        x_return_status := FND_API.G_RET_STS_SUCCESS;
			X_date := l_date ;

		END IF ;  /* IF l_count = 1 */
	END IF; /* IF l_return_status = 'E' */
    ELSE


        FND_FILE.PUT_LINE ( FND_FILE.LOG,'last else');
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_date := (sysdate - 9999 ) ;
       X_msg := 'Calendar/Date ';
       RAISE CALENDAR_REQUIRED;
    END IF;
EXCEPTION
    WHEN INVALID_DATA_PASSED OR invalid_version THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_date := (sysdate - 9999 ) ;
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;

    WHEN CALENDAR_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;
     x_date := (sysdate - 9999 ) ;

    WHEN INVALID_VALUE THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_date := (sysdate - 9999 ) ;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Value '||X_field||'-'||X_value);
     FND_MESSAGE.SET_NAME('GMP','GMP_INVALID_VALUE');
     FND_MESSAGE.SET_TOKEN('FIELD',X_field);
     FND_MESSAGE.SET_TOKEN('VALUE',X_value);
     FND_MSG_PUB.ADD;

    WHEN OTHERS  THEN
     x_return_status := FND_API.g_ret_sts_unexp_error;
     x_date := (sysdate - 9999 ) ;
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;

END get_nearest_workdaytime ;

END gmp_calendar_api ;

/
