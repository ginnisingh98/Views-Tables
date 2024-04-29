--------------------------------------------------------
--  DDL for Package Body JTF_TASK_RECURRENCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_RECURRENCES_PVT" AS
/* $Header: jtfvtkub.pls 120.8.12010000.3 2009/12/18 07:00:46 rkamasam ship $ */

 PROCEDURE get_mth_day(
   p_occurs_which VARCHAR2,
   p_sunday      VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_monday      VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_tuesday     VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_wednesday   VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_thursday    VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_friday      VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_saturday    VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_month       VARCHAR2,
   p_year        NUMBER,
   x_required_date OUT NOCOPY DATE
   )
AS
        TYPE get_days IS TABLE OF DATE
            INDEX BY BINARY_INTEGER;
        TYPE get_weekdays IS TABLE OF VARCHAR2(10)
            INDEX BY BINARY_INTEGER;
        daywk        get_weekdays;
        daysx        get_days;
        l_count        INTEGER  := 0;
        start_date     DATE;
        i              INTEGER  := 1;
        j              INTEGER  := 1;
        output_date    DATE;
    BEGIN
        start_date := TO_DATE ('01-' || p_month || '-' || p_year, 'dd-mm-rrrr','NLS_DATE_LANGUAGE=AMERICAN');

        WHILE (i < 8)
          AND (TO_CHAR (start_date, 'MON','NLS_DATE_LANGUAGE=AMERICAN') = p_month)
        LOOP
            IF p_sunday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'SUNDAY'
                THEN
                    daysx (j) := start_date;
                    daywk (j) := 'SUNDAY';
                    j := j + 1;
                END IF;
            END IF;

            IF p_monday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) ='MONDAY'
                THEN
                    daysx (j) := start_date;
                    daywk (j) := 'MONDAY';
                    j := j + 1;
                END IF;
            END IF;

            IF p_tuesday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) ='TUESDAY'
                THEN
                    daysx (j) := start_date;
                    daywk (j) := 'TUESDAY';
                    j := j + 1;
                END IF;
            END IF;

            IF p_wednesday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'WEDNESDAY'
                THEN
                    daysx (j) := start_date;
                    daywk (j) := 'WEDNESDAY';
                    j := j + 1;
                END IF;
            END IF;

            IF p_thursday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'THURSDAY'
                THEN
                    daysx (j) := start_date;
                    daywk (j) := 'THURSDAY';
                    j := j + 1;
                END IF;
            END IF;

            IF p_friday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'FRIDAY'
                THEN
                    daysx (j) := start_date;
                    daywk (j) := 'FRIDAY';
                    j := j + 1;
                END IF;
            END IF;

            IF p_saturday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'SATURDAY'
                THEN
                    daysx (j) := start_date;
                    daywk (j) := 'SATURDAY';
                    j := j + 1;
                END IF;
            END IF;

            i := i + 1;
            start_date := start_date + 1;
        END LOOP;

        j := 2;
        IF daywk(1) = 'SUNDAY' THEN
        WHILE (i < 32)
           AND (TO_CHAR (start_date, 'MON','NLS_DATE_LANGUAGE=AMERICAN') = p_month)
           LOOP
              IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'SUNDAY'
              THEN
                 daysx (j) := start_date;
                 j := j + 1;
              END IF;
              i := i + 1;
              start_date := start_date + 1;
           END LOOP;
        END IF;

        IF daywk(1) = 'MONDAY' THEN
        WHILE (i < 32)
           AND (TO_CHAR (start_date, 'MON','NLS_DATE_LANGUAGE=AMERICAN') = p_month)
           LOOP
              IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'MONDAY'
              THEN
                 daysx (j) := start_date;
                 j := j + 1;
              END IF;
              i := i + 1;
              start_date := start_date + 1;
           END LOOP;
        END IF;

        IF daywk(1) = 'TUESDAY' THEN
        WHILE (i < 32)
           AND (TO_CHAR (start_date, 'MON','NLS_DATE_LANGUAGE=AMERICAN') = p_month)
           LOOP
              IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'TUESDAY'
              THEN
                 daysx (j) := start_date;
                 j := j + 1;
              END IF;
              i := i + 1;
              start_date := start_date + 1;
           END LOOP;
        END IF;

        IF daywk(1) = 'WEDNESDAY' THEN
        WHILE (i < 32)
           AND (TO_CHAR (start_date, 'MON','NLS_DATE_LANGUAGE=AMERICAN') = p_month)
           LOOP
              IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'WEDNESDAY'
              THEN
                 daysx (j) := start_date;
                 j := j + 1;
              END IF;
              i := i + 1;
              start_date := start_date + 1;
           END LOOP;
        END IF;

        IF daywk(1) = 'THURSDAY' THEN
        WHILE (i < 32)
           AND (TO_CHAR (start_date, 'MON','NLS_DATE_LANGUAGE=AMERICAN') = p_month)
           LOOP
              IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'THURSDAY'
              THEN
                 daysx (j) := start_date;
                 j := j + 1;
              END IF;
              i := i + 1;
              start_date := start_date + 1;
           END LOOP;
        END IF;

        IF daywk(1) = 'FRIDAY' THEN
        WHILE (i < 32)
           AND (TO_CHAR (start_date, 'MON','NLS_DATE_LANGUAGE=AMERICAN') = p_month)
           LOOP
              IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'FRIDAY'
              THEN
                 daysx (j) := start_date;
                 j := j + 1;
              END IF;
              i := i + 1;
              start_date := start_date + 1;
           END LOOP;
        END IF;

        IF daywk(1) = 'SATURDAY' THEN
        WHILE (i < 32)
           AND (TO_CHAR (start_date, 'MON','NLS_DATE_LANGUAGE=AMERICAN') = p_month)
           LOOP
              IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'SATURDAY'
              THEN
                 daysx (j) := start_date;
                 j := j + 1;
              END IF;
              i := i + 1;
              start_date := start_date + 1;
           END LOOP;
        END IF;

        IF p_occurs_which = 'FIRST'
        THEN
            output_date := daysx (1);
        ELSIF p_occurs_which = 'SECOND'
        THEN
            output_date := daysx (2);
        ELSIF p_occurs_which = 'THIRD'
        THEN
            output_date := daysx (3);
        ELSIF p_occurs_which = 'FOUR'
        THEN
            output_date := daysx (4);
        ELSE
            output_date := daysx (j - 1);
        --when user selects last to each month, check to see if the following selected date
        --falls to next month, if it's true, go back to select all qulified date prior to the output_date
            IF RTRIM (LTRIM (TO_CHAR (output_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'SUNDAY'
            THEN
               IF p_monday = 'Y' AND (TO_CHAR ((output_date + 1), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 6;
               ELSIF p_tuesday = 'Y' AND (TO_CHAR ((output_date + 2), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 5;
               ELSIF p_wednesday = 'Y' AND (TO_CHAR ((output_date + 3), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 4;
               ELSIF p_thursday = 'Y' AND (TO_CHAR ((output_date + 4), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 3;
               ELSIF p_friday = 'Y' AND (TO_CHAR ((output_date + 5), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 2;
               ELSIF p_saturday = 'Y' AND (TO_CHAR ((output_date + 6), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 1;
               END IF;
            END IF;

            IF RTRIM (LTRIM (TO_CHAR (output_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'SATURDAY'
            THEN
               IF p_sunday = 'Y' AND (TO_CHAR ((output_date + 1), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 6;
               ELSIF p_monday = 'Y' AND (TO_CHAR ((output_date + 2), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 5;
               ELSIF p_tuesday = 'Y' AND (TO_CHAR ((output_date + 3), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 4;
               ELSIF p_wednesday = 'Y' AND (TO_CHAR ((output_date + 4), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 3;
               ELSIF p_thursday = 'Y' AND (TO_CHAR ((output_date + 5), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 2;
               ELSIF p_friday = 'Y' AND (TO_CHAR ((output_date + 6), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 1;
               END IF;
            END IF;

            IF RTRIM (LTRIM (TO_CHAR (output_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'FRIDAY'
            THEN
               IF p_saturday = 'Y' AND (TO_CHAR ((output_date + 1), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 6;
               ELSIF p_sunday = 'Y' AND (TO_CHAR ((output_date + 2), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 5;
               ELSIF p_monday = 'Y' AND (TO_CHAR ((output_date + 3), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 4;
               ELSIF p_tuesday = 'Y' AND (TO_CHAR ((output_date + 4), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 3;
               ELSIF p_wednesday = 'Y' AND (TO_CHAR ((output_date + 5), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 2;
               ELSIF p_thursday = 'Y' AND (TO_CHAR ((output_date + 6), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 1;
               END IF;
            END IF;

            IF RTRIM (LTRIM (TO_CHAR (output_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'THURSDAY'
            THEN
               IF p_friday = 'Y' AND (TO_CHAR ((output_date + 1), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 6;
               ELSIF p_saturday = 'Y' AND (TO_CHAR ((output_date + 2), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 5;
               ELSIF p_sunday = 'Y' AND (TO_CHAR ((output_date + 3), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 4;
               ELSIF p_monday = 'Y' AND (TO_CHAR ((output_date + 4), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 3;
               ELSIF p_tuesday = 'Y' AND (TO_CHAR ((output_date + 5), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 2;
               ELSIF p_wednesday = 'Y' AND (TO_CHAR ((output_date + 6), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 1;
               END IF;
            END IF;

            IF RTRIM (LTRIM (TO_CHAR (output_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'WEDNESDAY'
            THEN
               IF p_thursday = 'Y' AND (TO_CHAR ((output_date + 1), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 6;
               ELSIF p_friday = 'Y' AND (TO_CHAR ((output_date + 2), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 5;
               ELSIF p_saturday = 'Y' AND (TO_CHAR ((output_date + 3), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 4;
               ELSIF p_sunday = 'Y' AND (TO_CHAR ((output_date + 4), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 3;
               ELSIF p_monday = 'Y' AND (TO_CHAR ((output_date + 5), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 2;
               ELSIF p_tuesday = 'Y' AND (TO_CHAR ((output_date + 6), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 1;
               END IF;
            END IF;

            IF RTRIM (LTRIM (TO_CHAR (output_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'TUESDAY'
            THEN
               IF p_wednesday = 'Y' AND (TO_CHAR ((output_date + 1), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 6;
               ELSIF p_thursday = 'Y' AND (TO_CHAR ((output_date + 2), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 5;
               ELSIF p_friday = 'Y' AND (TO_CHAR ((output_date + 3), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 4;
               ELSIF p_saturday = 'Y' AND (TO_CHAR ((output_date + 4), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 3;
               ELSIF p_sunday = 'Y' AND (TO_CHAR ((output_date + 5), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 2;
               ELSIF p_monday = 'Y' AND (TO_CHAR ((output_date + 6), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 1;
               END IF;
            END IF;

            IF RTRIM (LTRIM (TO_CHAR (output_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'MONDAY'
            THEN
               IF p_tuesday = 'Y' AND (TO_CHAR ((output_date + 1), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 6;
               ELSIF p_wednesday = 'Y' AND (TO_CHAR ((output_date + 2), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 5;
               ELSIF p_thursday = 'Y' AND (TO_CHAR ((output_date + 3), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 4;
               ELSIF p_friday = 'Y' AND (TO_CHAR ((output_date + 4), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 3;
               ELSIF p_saturday = 'Y' AND (TO_CHAR ((output_date + 5), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 2;
               ELSIF p_sunday = 'Y' AND (TO_CHAR ((output_date + 6), 'MON','NLS_DATE_LANGUAGE=AMERICAN') <> p_month)
               THEN
                  output_date := output_date - 1;
               END IF;
            END IF;
        END IF;

        x_required_date := output_date;

    END;

    PROCEDURE get_week_day(
   p_sunday      VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_monday      VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_tuesday     VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_wednesday   VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_thursday    VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_friday      VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_saturday    VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
   p_required_date DATE,
   x_required_date IN OUT NOCOPY DATE
   )
AS

        start_date     DATE;
        i              INTEGER  := 1;
     BEGIN
        start_date := p_required_date;
        WHILE (i < 8)
        LOOP
            IF p_sunday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'SUNDAY'
                THEN
                    x_required_date := start_date;
                    EXIT;
                END IF;
            END IF;

            IF p_monday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) ='MONDAY'
                THEN
                    x_required_date := start_date;
                    EXIT;
                END IF;
            END IF;

            IF p_tuesday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) ='TUESDAY'
                THEN
                    x_required_date := start_date;
                    EXIT;
                END IF;
            END IF;

            IF p_wednesday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'WEDNESDAY'
                THEN
                    x_required_date := start_date;
                    EXIT;
                END IF;
            END IF;

            IF p_thursday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'THURSDAY'
                THEN
                    x_required_date := start_date;
                    EXIT;
                END IF;
            END IF;

            IF p_friday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'FRIDAY'
                THEN
                    x_required_date := start_date;
                    EXIT;
                END IF;
            END IF;

            IF p_saturday = 'Y'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'SATURDAY'
                THEN
                    x_required_date := start_date;
                    EXIT;
                END IF;
            END IF;

            i := i + 1;
            start_date := start_date + 1;
        END LOOP;

    END;

    PROCEDURE get_occurs_which (
        p_occurs_which                     VARCHAR2,
        p_day_of_week                      VARCHAR2,
        p_month                            VARCHAR2,
        p_year                             NUMBER,
        x_required_date           OUT NOCOPY      DATE
    )
    AS
        TYPE get_days IS TABLE OF DATE
            INDEX BY BINARY_INTEGER;

        daysx          get_days;
        start_date     DATE;
        i              INTEGER  := 1;
        j              INTEGER  := 1;
        output_date    DATE;
    BEGIN
        start_date := TO_DATE ('01-' || p_month || '-' || p_year, 'dd-mm-rrrr','NLS_DATE_LANGUAGE=AMERICAN');

        WHILE (i < 32)
          AND (TO_CHAR (start_date, 'MON','NLS_DATE_LANGUAGE=AMERICAN') = p_month)
        LOOP
            IF p_day_of_week IN ('SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY')
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = LTRIM (TRIM (p_day_of_week))
                THEN
                    daysx (j) := start_date;
                    j := j + 1;
                END IF;
            END IF;

            IF p_day_of_week IN ('WEEKEND')
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) IN ('SATURDAY', 'SUNDAY')
                THEN
                    daysx (j) := start_date;
                    j := j + 1;
                END IF;
            END IF;

            IF p_day_of_week IN ('WEEKDAY')
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) IN ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY')
                THEN
                    daysx (j) := start_date;
                    j := j + 1;
                END IF;
            END IF;

            IF p_day_of_week = 'DAY'
            THEN
                IF RTRIM (LTRIM (TO_CHAR (start_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) IN ('SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY')
                THEN
                    daysx (j) := start_date;
                    j := j + 1;
                END IF;
            END IF;

            i := i + 1;
            start_date := start_date + 1;
        END LOOP;

        IF p_occurs_which = 'FIRST'
        THEN
            output_date := daysx (1);
        ELSIF p_occurs_which = 'SECOND'
        THEN
            output_date := daysx (2);
        ELSIF p_occurs_which = 'THIRD'
        THEN
            output_date := daysx (3);
        ELSIF p_occurs_which = 'FOUR'
        THEN
            output_date := daysx (4);
        ELSE
            output_date := daysx (j - 1);
        END IF;

        x_required_date := output_date;
    END;

-------------------------------------------------------
-------------------------------------------------------
    PROCEDURE occurs_date_of_month (
        p_date_of_month                    NUMBER,
        p_month                            VARCHAR2,
        p_year                             NUMBER,
        x_required_date           OUT NOCOPY      DATE
    )
    IS
    BEGIN
		-- Added NLS parameter to bug# 7491191
        x_required_date := TO_DATE (TO_CHAR (p_date_of_month) || '-' || p_month || '-' || TO_CHAR (p_year), 'dd-mm-rrrr','NLS_DATE_LANGUAGE=AMERICAN');
    END;



    --This function corrects DST offset for p_to_date
    --using p_from_date.

    FUNCTION get_dst_corrected_date (
      p_to_date   IN DATE
    , p_from_date IN DATE
    ) RETURN DATE IS

      l_server_tz_id           NUMBER := TO_NUMBER(fnd_profile.value_specific('SERVER_TIMEZONE_ID'));
      l_from_date              DATE   :=  p_from_date;
      l_to_date                DATE   :=  p_to_date;
      l_global_timezone_name   VARCHAR2(50);
      l_name                   VARCHAR2(80);
      l_status                 VARCHAR2(1);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2(2000);
      l_GMT_deviation          NUMBER;
      l_server_offset          NUMBER;
      l_to_date_in_dst         BOOLEAN := false;
      l_from_date_in_dst       BOOLEAN := false;

    BEGIN
      --Get server timezone's offset from GMT
      /*SELECT  gmt_deviation_hours
        INTO   l_server_offset
        FROM   hz_timezones
        WHERE  timezone_id =  l_server_tz_id;

      --Get the GMT deviation of p_to_date
      hz_timezone_pub.get_timezone_gmt_deviation(
        p_api_version          => 1.0
      , p_init_msg_list        => 'F'
      , p_timezone_id          => l_server_tz_id
      , p_date                 => l_to_date
      , x_gmt_deviation        => l_gmt_deviation
      , x_global_timezone_name => l_global_timezone_name
      , x_name                 => l_name
      , x_return_status        => l_status
      , x_msg_count            => l_msg_count
      , x_msg_data             => l_msg_data
      );

      IF ( l_status <> FND_API.G_RET_STS_SUCCESS )
      THEN
        RAISE fnd_api.G_EXC_ERROR;
      END IF;

     IF ( l_gmt_deviation <> l_server_offset)
      THEN
        --p_to_date is in DST
        l_to_date_in_dst := true;
      END IF;

      --Get the GMT deviation of p_from_date
      hz_timezone_pub.get_timezone_gmt_deviation(
        p_api_version          => 1.0
      , p_init_msg_list        => 'F'
      , p_timezone_id          => l_server_tz_id
      , p_date                 => l_from_date
      , x_gmt_deviation        => l_gmt_deviation
      , x_global_timezone_name => l_global_timezone_name
      , x_name                 => l_name
      , x_return_status        => l_status
      , x_msg_count            => l_msg_count
      , x_msg_data             => l_msg_data
      );

      IF ( l_status <> FND_API.G_RET_STS_SUCCESS )
      THEN
        RAISE fnd_api.G_EXC_ERROR;
      END IF;

      IF ( l_gmt_deviation <> l_server_offset)
      THEN
        --p_from_date is in DST
        l_from_date_in_dst := true;
      END IF;

      --correct p_to_date by one hour based
      -- DST information retrieved above.
      IF ( l_from_date_in_dst = true AND
           l_to_date_in_dst   = false
         )
      THEN
        l_to_date := l_to_date - 1/24;
      ELSIF
        ( l_from_date_in_dst = false AND
          l_to_date_in_dst   = true
        )
      THEN
        l_to_date :=l_to_date + 1/24;
      END IF;*/

      RETURN l_to_date;

    END get_dst_corrected_date;


-------------------------------------------------------
-------------------------------------------------------
    PROCEDURE recur_main (
        p_occurs_which                     VARCHAR2 DEFAULT NULL,
        p_day_of_week                      VARCHAR2 DEFAULT NULL,
        p_date_of_month                    NUMBER DEFAULT NULL,
        p_occurs_month                     NUMBER DEFAULT NULL,
        p_occurs_uom                       VARCHAR2 DEFAULT NULL,
        p_occurs_every                     NUMBER DEFAULT NULL,
        p_occurs_number                    NUMBER DEFAULT 0,
        p_start_date                       DATE DEFAULT NULL,
        p_end_date                         DATE DEFAULT NULL,
        x_output_dates_tbl        OUT NOCOPY      jtf_task_recurrences_pvt.output_dates_rec,
        x_output_dates_counter    OUT NOCOPY      INTEGER,
        p_sunday                           VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_monday                           VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_tuesday                          VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_wednesday                        VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_thursday                         VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_friday                           VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_saturday                         VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_task_id                          NUMBER   DEFAULT NULL
    )
    IS
        p_required_date         DATE    := p_start_date;
        p_count                 NUMBER  := 0;
        output_dates_counter    INTEGER := 1;
        success                 BOOLEAN;
        generated               BOOLEAN := TRUE;
        valid_date              BOOLEAN := FALSE;
        i                       INTEGER  := 1;
        j                       INTEGER  := 1;
        p_required_date_tbl     jtf_task_recurrences_pvt.output_dates_rec;
        l_day_of_week           VARCHAR2(15);
        l_month                 VARCHAR2(2);

        /******* Start of addition by SBARAT on 12/04/2006 for bug# 5119803 ******/
        l_tz_enabled_prof              VARCHAR2(10) := fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS');
        l_server_tz_id                 NUMBER := to_number(fnd_profile.value_specific('SERVER_TIMEZONE_ID'));
        l_client_tz_id                 NUMBER := to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID'));

        Cursor c_task IS
          Select calendar_start_date, timezone_id From jtf_tasks_b Where task_id=p_task_id;

        l_cal_start_date               DATE;
        l_conv_cal_start_date          DATE;
        l_tz_id                        NUMBER;
        l_tz_diff                      NUMBER;
        l_required_date                DATE;
        /******* End of addition by SBARAT on 12/04/2006 for bug# 5119803 ******/

    BEGIN

        WHILE 2 > 1
        LOOP
            IF p_occurs_number < output_dates_counter
            THEN
                EXIT;
            END IF;

            generated := TRUE;

            IF p_occurs_uom = 'DAY'
            THEN
                NULL;
            END IF;

            IF p_occurs_uom = 'WEK'
            THEN
               jtf_task_recurrences_pvt.get_week_day (
                        p_sunday => p_sunday,
                        p_monday => p_monday,
                        p_tuesday => p_tuesday,
                        p_wednesday => p_wednesday,
                        p_thursday => p_thursday,
                        p_friday => p_friday,
                        p_saturday => p_saturday,
                        p_required_date => p_required_date,
                        x_required_date => p_required_date
                        );
            END IF;

            IF p_occurs_uom = 'WK'
            THEN
                IF ltrim(rtrim(TO_CHAR (p_required_date, 'DAY', 'NLS_DATE_LANGUAGE=AMERICAN'))) = rtrim(ltrim(p_day_of_week)) -- Fix Bug 2398568
                THEN
                    NULL;
                ELSE
                    generated := FALSE;
                END IF;
            END IF;

            IF p_occurs_uom = 'MTH'
            THEN
                IF p_date_of_month IS NULL
                THEN
                    jtf_task_recurrences_pvt.get_occurs_which (
                        p_occurs_which,
                        p_day_of_week,
                        TO_CHAR (p_required_date, 'MON', 'NLS_DATE_LANGUAGE=AMERICAN'), -- Fix Bug 2398568
                        TO_CHAR (p_required_date, 'YYYY'),
                        p_required_date
                    );


                ELSE
                    jtf_task_recurrences_pvt.occurs_date_of_month (
                        p_date_of_month,
                        TO_CHAR (p_required_date, 'MON', 'NLS_DATE_LANGUAGE=AMERICAN'), -- Fix Bug 2398568
                        TO_CHAR (p_required_date, 'YYYY'),
                        p_required_date
                    );

                END IF;
            END IF;

            IF p_occurs_uom = 'MON'
            THEN
                IF p_date_of_month IS NULL
                THEN

                    jtf_task_recurrences_pvt.get_mth_day (
                        p_occurs_which => p_occurs_which,
                        p_sunday => p_sunday,
                        p_monday => p_monday,
                        p_tuesday => p_tuesday,
                        p_wednesday => p_wednesday,
                        p_thursday => p_thursday,
                        p_friday => p_friday,
                        p_saturday => p_saturday,
                        p_month => TO_CHAR (p_required_date, 'MON', 'NLS_DATE_LANGUAGE=AMERICAN'), -- Fix Bug 2398568
                        p_year => TO_CHAR (p_required_date, 'YYYY'),
                        x_required_date => p_required_date
                     );


                ELSE
                  -- when date of month is selected
                    jtf_task_recurrences_pvt.occurs_date_of_month (
                        p_date_of_month,
                        TO_CHAR (p_required_date, 'MON', 'NLS_DATE_LANGUAGE=AMERICAN'), -- Fix Bug 2398568
                        TO_CHAR (p_required_date, 'YYYY'),
                        p_required_date
                    );

                END IF;
            END IF;

            IF p_occurs_uom = 'YR'
            THEN

                IF p_date_of_month IS NOT NULL
                THEN
                    IF (  p_occurs_month < TO_CHAR (p_required_date, 'MM')
                       OR     NOT (p_occurs_month = TO_CHAR (p_required_date, 'MM'))
                          AND p_date_of_month <= TO_CHAR (LAST_DAY (p_required_date), 'DD')
                          AND p_date_of_month >= TO_CHAR (p_required_date, 'DD'))
                    THEN
                        success := FALSE;
                        p_required_date := ADD_MONTHS (p_required_date, 1);

                        WHILE NOT success
                        LOOP
                            IF     TO_NUMBER (TO_CHAR (LAST_DAY (p_required_date), 'DD')) >= p_date_of_month
                               AND p_occurs_month = TO_CHAR (p_required_date, 'MM')
                            THEN
                                p_required_date :=
                                    TO_DATE (
                                        TO_CHAR (p_date_of_month) ||
                                        '-' ||
                                        TO_CHAR (p_required_date, 'MM') ||
                                        '-' ||
                                        TO_CHAR (p_required_date, 'yyyy'),
                                        'dd-mm-yyyy'
                                    );
                                success := TRUE;
                            ELSE
                                p_required_date := ADD_MONTHS (p_required_date, 1);
                            END IF;
                        END LOOP;
                    ELSE
                        p_required_date :=
                            TO_DATE (TO_CHAR (p_date_of_month) || '-' || p_occurs_month || '-' || TO_CHAR (p_required_date, 'yyyy'), 'dd-mm-yyyy');
                    END IF;
                ELSE
                    IF TO_NUMBER (TO_CHAR (p_required_date, 'MM')) = p_occurs_month
                    THEN
                        jtf_task_recurrences_pvt.get_occurs_which (
                            p_occurs_which,
                            p_day_of_week,
                            TO_CHAR (p_required_date, 'MON', 'NLS_DATE_LANGUAGE=AMERICAN'), -- Fix Bug 2398568
                            TO_CHAR (p_required_date, 'YYYY'),
                            p_required_date
                        );

                        generated := TRUE;
                    ELSE
                        generated := FALSE;
                    END IF;
                END IF;
            END IF;
             IF p_occurs_uom = 'YER' THEN
                IF p_date_of_month IS NOT NULL
                THEN
                    IF (  p_occurs_month < TO_CHAR (p_required_date, 'MM')
                       OR     NOT (p_occurs_month = TO_CHAR (p_required_date, 'MM'))
                          AND p_date_of_month <= TO_CHAR (LAST_DAY (p_required_date), 'DD')
                          AND p_date_of_month >= TO_CHAR (p_required_date, 'DD'))
                    THEN
                        success := FALSE;
                        p_required_date := ADD_MONTHS (p_required_date, 1);

                        WHILE NOT success
                        LOOP
                            IF     TO_NUMBER (TO_CHAR (LAST_DAY (p_required_date), 'DD')) >= p_date_of_month
                               AND p_occurs_month = TO_CHAR (p_required_date, 'MM')
                            THEN
                                p_required_date :=
                                    TO_DATE (
                                        TO_CHAR (p_date_of_month) ||
                                        '-' ||
                                        TO_CHAR (p_required_date, 'MM') ||
                                        '-' ||
                                        TO_CHAR (p_required_date, 'yyyy'),
                                        'dd-mm-yyyy'
                                    );

                                success := TRUE;
                            ELSE
                                p_required_date := ADD_MONTHS (p_required_date, 1);
                            END IF;
                        END LOOP;
                    ELSE
                        -- Commented out by SBARAT on 12/04/2006 for bug# 5119803
                        --p_required_date :=
                            --TO_DATE (TO_CHAR (p_date_of_month) || '-' || p_occurs_month || '-' || TO_CHAR (p_required_date, 'yyyy'), 'dd-mm-yyyy');

                      /******* Start of addition by SBARAT on 12/04/2006 for bug# 5119803 ******/
                      ---------------------------------------------------------------
                      -- This new logic has been introduced to handle leap-year issue
                      ----------------------------------------------------------------
                       IF (NOT ((p_date_of_month = 28 OR p_date_of_month = 29) AND p_occurs_month = 2)
                           AND NOT (p_date_of_month = 01 AND p_occurs_month = 3))
                       THEN
                          p_required_date :=
                               TO_DATE (TO_CHAR (p_date_of_month) || '-' || p_occurs_month || '-' || TO_CHAR (p_required_date, 'yyyy'), 'dd-mm-yyyy');
                       ELSE
                          IF p_task_id IS NULL
                          THEN
                             IF (p_date_of_month = 29)
                             THEN
                                WHILE 2>1 LOOP
                                   p_required_date:=LAST_DAY(p_required_date);

                                   IF (to_number(to_char(p_required_date,'DD'))=29
                                       AND to_number(to_char(p_required_date,'MM'))=2)
                                   THEN
                                      EXIT;
                                   END IF;

                                   p_required_date :=
                                             ADD_MONTHS (to_date('01-02-'|| to_char(p_required_date, 'YYYY'), 'DD-MM-YYYY'), p_occurs_every*12);
                                END LOOP;
                             ELSE
                                p_required_date :=
                                        TO_DATE (TO_CHAR (p_date_of_month) || '-' || p_occurs_month || '-' || TO_CHAR (p_required_date, 'yyyy'), 'dd-mm-yyyy');
                             END IF;
                          ELSE
                             Open c_task;
                             Fetch c_task Into l_cal_start_date, l_tz_id;
                             Close c_task;

                             IF ((l_tz_id IS NOT NULL AND l_tz_id <> l_server_tz_id) Or NVL(l_tz_enabled_prof,'N') <> 'Y' Or l_server_tz_id IS NULL)
                             THEN
                                IF (p_date_of_month = 29 AND p_occurs_month = 2)
                                THEN
                                   WHILE 2>1 LOOP
                                      p_required_date:=LAST_DAY(p_required_date);

                                      IF (to_number(to_char(p_required_date,'DD'))=29
                                          AND to_number(to_char(p_required_date,'MM'))=2)
                                      THEN
                                         EXIT;
                                      END IF;

                                      p_required_date := ADD_MONTHS (to_date('01-02-'|| to_char(p_required_date, 'YYYY'), 'DD-MM-YYYY'), p_occurs_every*12);
                                   END LOOP;
                                ELSE
                                   p_required_date :=
                                           TO_DATE (TO_CHAR (p_date_of_month) || '-' || p_occurs_month || '-' || TO_CHAR (p_required_date, 'yyyy'), 'dd-mm-yyyy');
                             END IF;
                          ELSE
                             l_conv_cal_start_date:= HZ_TIMEZONE_PUB.CONVERT_DATETIME(l_server_tz_id,
                                                                                      l_client_tz_id,
                                                                                      l_cal_start_date
                                                                                      );

                             l_tz_diff:=(l_conv_cal_start_date - p_start_date);

                             IF ((p_date_of_month=28 AND to_number(TO_CHAR(l_conv_cal_start_date,'DD')) IN (27,28))
                                  OR (p_date_of_month=1 AND to_number(TO_CHAR(l_conv_cal_start_date,'DD')) IN (1,2))
                                )
                             THEN
                                p_required_date :=
                                           TO_DATE (TO_CHAR (p_date_of_month) || '-' || p_occurs_month || '-' || TO_CHAR (p_required_date, 'yyyy'), 'dd-mm-yyyy');
                             ELSIF (p_date_of_month IN (28,29) AND to_number(TO_CHAR(l_conv_cal_start_date,'DD'))=29)
                             THEN
                                WHILE 2>1 LOOP
                                    p_required_date:=LAST_DAY(p_required_date);

                                    IF (p_date_of_month=28 AND to_char(p_required_date,'DD')='29')
                                    THEN
                                       p_required_date:=p_required_date - 1;
                                    END IF;

                                    l_required_date:= p_required_date+l_tz_diff;

                                    IF (to_number(to_char(l_required_date,'DD'))=29
                                        AND to_number(to_char(l_required_date,'MM'))=2)
                                    THEN
                                       EXIT;
                                    END IF;
                                    p_required_date := ADD_MONTHS (to_date('01-02-'|| to_char(p_required_date, 'YYYY'), 'DD-MM-YYYY'), p_occurs_every*12);
                                END LOOP;

                             ELSIF (p_date_of_month IN (28,29) AND to_number(TO_CHAR(l_conv_cal_start_date,'DD'))=1)
                             THEN
                                p_required_date :=
                                       LAST_DAY(TO_DATE (TO_CHAR (p_date_of_month-1) || '-' || p_occurs_month || '-' || TO_CHAR (p_required_date, 'yyyy'), 'dd-mm-yyyy'));
                             ELSIF (p_date_of_month=29 AND to_number(TO_CHAR(l_conv_cal_start_date,'DD'))=28)
                             THEN
                                p_required_date := to_date('01-02-'|| to_char(p_required_date, 'YYYY'), 'DD-MM-YYYY') + 28;

                             ELSIF (p_date_of_month=1 AND to_number(TO_CHAR(l_conv_cal_start_date,'DD'))=29)
                             THEN
                                WHILE 2>1 LOOP

                                    l_required_date:= p_required_date+l_tz_diff;

                                    IF (to_number(to_char(l_required_date,'DD'))=29
                                        AND to_number(to_char(l_required_date,'MON'))=2)
                                    THEN
                                       EXIT;
                                    END IF;

                                    p_required_date := ADD_MONTHS (to_date('01-03-'|| to_char(p_required_date, 'YYYY'), 'DD-MM-YYYY'), p_occurs_every*12);
                                END LOOP;
                             ELSIF (p_date_of_month=1 AND to_number(TO_CHAR(l_conv_cal_start_date,'DD'))=28)
                             THEN

                                l_required_date:= p_required_date+l_tz_diff;

                                IF (to_number(to_char(l_required_date,'DD'))=28
                                    AND to_number(to_char(l_required_date,'MON'))=2)
                                THEN
                                   NULL;
                                ELSE
                                   p_required_date:=(p_required_date-1);
                                END IF;
                             END IF;
                          END IF;
                       END IF;
                    END IF;
               /******* End of addition by SBARAT on 12/04/2006 for bug# 5119803 ******/
                END IF;
            ELSE
                    IF TO_NUMBER (TO_CHAR (p_required_date, 'MM')) = p_occurs_month
                    THEN

                       IF p_sunday = 'Y' THEN
                         l_day_of_week := 'SUNDAY';
                       ELSIF p_monday = 'Y' THEN
                         l_day_of_week := 'MONDAY';
                       ELSIF p_tuesday = 'Y' THEN
                         l_day_of_week := 'TUESDAY';
                       ELSIF p_wednesday = 'Y' THEN
                         l_day_of_week := 'WEDNESDAY';
                       ELSIF p_thursday = 'Y' THEN
                         l_day_of_week := 'THURSDAY';
                      ELSIF p_friday = 'Y' THEN
                        l_day_of_week := 'FRIDAY';
                     ELSIF p_saturday = 'Y' THEN
                        l_day_of_week := 'SATURDAY';
                     END IF;
                        jtf_task_recurrences_pvt.get_occurs_which (
                            p_occurs_which,
                            l_day_of_week,
                            TO_CHAR (p_required_date, 'MON', 'NLS_DATE_LANGUAGE=AMERICAN'), -- Fix Bug 2398568
                            TO_CHAR (p_required_date, 'YYYY'),
                            p_required_date
                        );

                        generated := TRUE;
                    ELSE
                        generated := FALSE;
                    END IF;

                END IF;

            END IF;
            IF p_required_date > p_end_date
            THEN
                EXIT;
            END IF;
            IF     generated
               AND (  (trunc(p_required_date) <= trunc(p_end_date))
                   OR (output_dates_counter <= p_occurs_number))
            THEN
                IF trunc(p_required_date) >= trunc(p_start_date)
                THEN
                    x_output_dates_tbl (output_dates_counter) := p_required_date;
                    output_dates_counter := output_dates_counter + 1;
                    valid_date := TRUE;
                END IF;
            END IF;

            IF p_occurs_uom IN ('MTH', 'YR')
            THEN
                IF valid_date
                THEN
                    p_required_date := ADD_MONTHS (p_required_date, p_occurs_every);
                ELSE
                    p_required_date := ADD_MONTHS (p_required_date, 1);
                END IF;
            END IF;

             IF p_occurs_uom IN ('YER')
            THEN
                IF valid_date
                THEN
                    --p_required_date := ADD_MONTHS (p_required_date, p_occurs_every*12);
                    IF p_occurs_month < 10 THEN
                      l_month := '0' || p_occurs_month;
                    ELSE
                      l_month := p_occurs_month; -- Fix bug 2720817
                    END IF;
                    p_required_date := ADD_MONTHS (to_date('01' || l_month
                                       || to_char(p_required_date, 'YYYY'), 'DD-MM-YYYY'), p_occurs_every*12);

                ELSE
                    p_required_date := ADD_MONTHS (p_required_date, 1);
                END IF;
            END IF;

            IF p_occurs_uom IN ('DAY')
            THEN
                p_required_date := p_required_date + p_occurs_every;
            END IF;



            IF p_occurs_uom = 'MON' AND p_date_of_month IS NULL
            THEN
                WHILE (i < 7)
                AND (TO_CHAR (p_required_date, 'MON','NLS_DATE_LANGUAGE=AMERICAN') = TO_CHAR (p_required_date + i, 'MON','NLS_DATE_LANGUAGE=AMERICAN'))
                LOOP
                 --check the next 6 days starts from the required date to see if they are checked
                 --if checked, add up to the output
                   IF p_sunday = 'Y' AND (p_required_date + i > p_start_date) AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null)
                   THEN
                      IF RTRIM (LTRIM (TO_CHAR (p_required_date + i, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'SUNDAY'
                      THEN
                         x_output_dates_tbl (output_dates_counter) := p_required_date + i;
                         output_dates_counter := output_dates_counter + 1;
                      END IF;
                   END IF;

                   IF p_monday = 'Y' AND (p_required_date + i > p_start_date) AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null)
                   THEN
                      IF RTRIM (LTRIM (TO_CHAR (p_required_date + i, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) ='MONDAY'
                      THEN
                         x_output_dates_tbl (output_dates_counter) := p_required_date + i;
                         output_dates_counter := output_dates_counter + 1;
                      END IF;
                   END IF;

                   IF p_tuesday = 'Y' AND (p_required_date + i > p_start_date) AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null)
                   THEN
                      IF RTRIM (LTRIM (TO_CHAR (p_required_date + i, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) ='TUESDAY'
                      THEN
                         x_output_dates_tbl (output_dates_counter) := p_required_date + i;
                         output_dates_counter := output_dates_counter + 1;
                      END IF;
                   END IF;

                   IF p_wednesday = 'Y' AND (p_required_date + i > p_start_date) AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null)
                   THEN
                      IF RTRIM (LTRIM (TO_CHAR (p_required_date + i, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'WEDNESDAY'
                      THEN
                         x_output_dates_tbl (output_dates_counter) := p_required_date + i;
                         output_dates_counter := output_dates_counter + 1;
                      END IF;
                   END IF;

                   IF p_thursday = 'Y' AND (p_required_date + i > p_start_date) AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null)
                   THEN
                      IF RTRIM (LTRIM (TO_CHAR (p_required_date + i, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'THURSDAY'
                      THEN
                         x_output_dates_tbl (output_dates_counter) := p_required_date + i;
                         output_dates_counter := output_dates_counter + 1;
                      END IF;
                   END IF;

                   IF p_friday = 'Y' AND (p_required_date + i > p_start_date) AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null)
                   THEN
                      IF RTRIM (LTRIM (TO_CHAR (p_required_date + i, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'FRIDAY'
                      THEN
                         x_output_dates_tbl (output_dates_counter) := p_required_date + i;
                         output_dates_counter := output_dates_counter + 1;

                      END IF;
                   END IF;

                   IF p_saturday = 'Y' AND (p_required_date + i > p_start_date) AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null)
                   THEN
                      IF RTRIM (LTRIM (TO_CHAR (p_required_date + i, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'SATURDAY'
                      THEN
                         x_output_dates_tbl (output_dates_counter) := p_required_date + i;
                         output_dates_counter := output_dates_counter + 1;
                      END IF;
                   END IF;

                   i := i + 1;
               END LOOP;

               i := 1;

               IF valid_date
               THEN
                --go to the next circle based on user's selection criteria
                --to check should required date is greater than end date,  check if the end date meets the criteria.
                  if trunc(p_required_date) = trunc(p_end_date) then
                     exit;
                  else
                     p_required_date := ADD_MONTHS (x_output_dates_tbl (output_dates_counter-1), p_occurs_every);
                     if p_required_date > p_end_date  and
                        to_char(p_required_date, 'MON', 'NLS_DATE_LANGUAGE=AMERICAN') = to_char(p_end_date, 'MON', 'NLS_DATE_LANGUAGE=AMERICAN') then -- Fix Bug 2398568
                        p_required_date := p_end_date;
                     end if;
                  end if;
               ELSE
                --if not valid, add one month to start the loop again
                --to check if the required date less than end date, and counter is not incremented, use p_required_date
                  if (output_dates_counter = 1) then
                     p_required_date := ADD_MONTHS (p_required_date, 1);
                  else
                     p_required_date := ADD_MONTHS (x_output_dates_tbl (output_dates_counter-1), 1);
                  end if;
               END IF;

          --when date of month is selected
            ELSIF p_occurs_uom = 'MON' AND p_date_of_month IS NOT NULL
            THEN
               IF valid_date
               THEN
                --go to the next circle based on user's selection criteria
                  p_required_date := ADD_MONTHS (p_required_date, p_occurs_every);

                  -- Commented out by SBARAT on 12/04/2006 for bug# 5144171
                  /*WHILE 2 > 1 AND j < 1000 LOOP
                     IF TO_CHAR (p_required_date, 'DD') <> p_date_of_month THEN
                        p_required_date := ADD_MONTHS (p_required_date, p_occurs_every);
                        j := j + 1;
                     ELSE
                        exit;
                     END IF;
                  END LOOP;*/

                  /******** Start of addition by SBARAT on 12/04/2006 for bug# 5144171 ********/
                  WHILE 2 > 1 AND j < 1000 LOOP
                    IF to_number(TO_CHAR (p_required_date, 'DD')) < p_date_of_month THEN
                        p_required_date := ADD_MONTHS (p_required_date, p_occurs_every);
                        j := j + 1;
                     ELSE
                        exit;
                     END IF;
                  END LOOP;

                  IF to_number(TO_CHAR (p_required_date, 'DD')) > p_date_of_month
                  THEN
                     p_required_date:=p_required_date-(to_number(TO_CHAR (p_required_date, 'DD')) - p_date_of_month);
                  END IF;
                  /******** End of addition by SBARAT on 12/04/2006 for bug# 5144171 ********/

               ELSE
                --if not valid, add one month to start the loop again
                  p_required_date := ADD_MONTHS (p_required_date, 1);
               END IF;
            END IF;

            IF p_occurs_uom IN ('WK')
            THEN
             if generated then
                p_required_date := p_required_date + p_occurs_every * 7;
             else
             p_required_date := p_required_date + 1;
             end if ;
            END IF;

            IF p_occurs_uom IN ('WEK')
            THEN
            IF RTRIM (LTRIM (TO_CHAR (p_required_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'SUNDAY'
        THEN
                IF p_monday = 'Y' AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 1;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_tuesday = 'Y' AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 2;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_wednesday = 'Y' AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 3;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_thursday = 'Y'  AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 4;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_friday = 'Y'  AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 5;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_saturday = 'Y' AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 6;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;
                p_required_date := p_required_date + p_occurs_every * 7;
        END IF;

        IF RTRIM (LTRIM (TO_CHAR (p_required_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'MONDAY'
        THEN

                    IF p_tuesday = 'Y' AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 1;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_wednesday = 'Y' AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 2;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_thursday = 'Y'  AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 3;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_friday = 'Y'  AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 4;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_saturday = 'Y' AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 5;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_sunday = 'Y' THEN
                       p_required_date := p_required_date - 1;
                    END IF;

                p_required_date := p_required_date + p_occurs_every * 7;
        END IF;

        IF RTRIM (LTRIM (TO_CHAR (p_required_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'TUESDAY'
        THEN

                    IF p_wednesday = 'Y' AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 1;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_thursday = 'Y'  AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 2;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_friday = 'Y'  AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 3;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_saturday = 'Y' AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 4;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_monday = 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 1;
                    ELSIF p_sunday = 'Y' THEN
                       p_required_date := p_required_date - 2;
                    END IF;
                p_required_date := p_required_date + p_occurs_every * 7;

        END IF;

                IF RTRIM (LTRIM (TO_CHAR (p_required_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'WEDNESDAY'
        THEN

                    IF p_thursday = 'Y'  AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 1;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_friday = 'Y'  AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 2;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_saturday = 'Y' AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 3;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_tuesday = 'Y' AND p_monday <> 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 1;
                    ELSIF p_monday = 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 2;
                    ELSIF p_sunday = 'Y' THEN
                       p_required_date := p_required_date - 3;
                    END IF;

                p_required_date := p_required_date + p_occurs_every * 7;
        END IF;

        IF RTRIM (LTRIM (TO_CHAR (p_required_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'THURSDAY'
        THEN

                    IF p_friday = 'Y'  AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 1;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_saturday = 'Y' AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 2;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_wednesday = 'Y'  AND p_tuesday <> 'Y' AND p_monday <> 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 1;
                    ELSIF p_tuesday = 'Y' AND p_monday <> 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 2;
                    ELSIF p_monday = 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 3;
                    ELSIF p_sunday = 'Y' THEN
                       p_required_date := p_required_date - 4;
                    END IF;

                p_required_date := p_required_date + p_occurs_every * 7;
        END IF;

                IF RTRIM (LTRIM (TO_CHAR (p_required_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'FRIDAY'
        THEN

                    IF p_saturday = 'Y' AND (output_dates_counter <= p_occurs_number OR p_occurs_number is null) THEN
                       x_output_dates_tbl (output_dates_counter) := p_required_date + 1;
                       output_dates_counter := output_dates_counter + 1;
                    END IF;

                    IF p_thursday = 'Y' AND p_wednesday <> 'Y' AND p_tuesday <> 'Y' AND p_monday <> 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 1;
                    ELSIF p_wednesday = 'Y' AND p_tuesday <> 'Y' AND p_monday <> 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 2;
                    ELSIF p_tuesday = 'Y' AND p_monday <> 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 3;
                    ELSIF p_monday = 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 4;
                    ELSIF p_sunday = 'Y' THEN
                       p_required_date := p_required_date - 5;
                    END IF;

                p_required_date := p_required_date + p_occurs_every * 7;
        END IF;

                IF RTRIM (LTRIM (TO_CHAR (p_required_date, 'DAY','NLS_DATE_LANGUAGE=AMERICAN'))) = 'SATURDAY'
        THEN

                IF p_friday = 'Y' AND p_thursday <> 'Y' AND p_wednesday <> 'Y' AND p_tuesday <> 'Y' AND p_monday <> 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 1;
                    ELSIF p_thursday = 'Y'  AND p_wednesday <> 'Y' AND p_tuesday <> 'Y' AND p_monday <> 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 2;
                    ELSIF p_wednesday = 'Y'  AND p_tuesday <> 'Y' AND p_monday <> 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 3;
                    ELSIF p_tuesday = 'Y' AND p_monday <> 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 4;
                    ELSIF p_monday = 'Y' AND p_sunday <> 'Y' THEN
                       p_required_date := p_required_date - 5;
                    ELSIF p_sunday = 'Y' THEN
                       p_required_date := p_required_date - 6;
                    END IF;

                    p_required_date := p_required_date + p_occurs_every * 7;
        END IF;
            END IF;
        END LOOP;
        x_output_dates_counter := output_dates_counter;
        EXCEPTION
        WHEN OTHERS
        THEN
            null;
    END;   -- Procedure

-------------------------------------------------------
-------------------------------------------------------
    PROCEDURE generate_dates (
        p_occurs_which                     NUMBER DEFAULT NULL,
        p_day_of_week                      NUMBER DEFAULT NULL,
        p_date_of_month                    NUMBER DEFAULT NULL,
        p_occurs_month                     NUMBER DEFAULT NULL,
        p_occurs_uom                       VARCHAR2 DEFAULT NULL,
        p_occurs_every                     NUMBER DEFAULT NULL,
        p_occurs_number                    NUMBER DEFAULT 0,
        p_start_date                       DATE DEFAULT NULL,
        p_end_date                         DATE DEFAULT SYSDATE,
        x_output_dates_tbl        OUT NOCOPY      jtf_task_recurrences_pvt.output_dates_rec,
        x_output_dates_counter    OUT NOCOPY      INTEGER,
        p_sunday                           VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_monday                           VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_tuesday                          VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_wednesday                        VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_thursday                         VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_friday                           VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_saturday                         VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_task_id                          NUMBER   DEFAULT NULL
    )
    IS
        l_occurs_which     VARCHAR2(20);
        l_day_of_week      VARCHAR2(20);
        l_date_of_month    NUMBER       := p_date_of_month;
        l_occurs_month     NUMBER       := p_occurs_month;
        l_occurs_uom       VARCHAR2(20);
        l_occurs_every     NUMBER       := p_occurs_every;
        l_occurs_number    NUMBER       := p_occurs_number;
        l_start_date       DATE         := p_start_date;
        l_end_date         DATE         := p_end_date;
        l_sunday           VARCHAR2(1)  := p_sunday;
        l_monday           VARCHAR2(1)  := p_monday;
        l_tuesday          VARCHAR2(1)  := p_tuesday;
        l_wednesday        VARCHAR2(1)  := p_wednesday;
        l_thursday         VARCHAR2(1)  := p_thursday;
        l_friday           VARCHAR2(1)  := p_friday;
        l_saturday         VARCHAR2(1)  := p_saturday;
    BEGIN
        SELECT DECODE (p_occurs_which, 1, 'FIRST', 2, 'SECOND', 3, 'THIRD', 4, 'FOUR', 99, 'LAST')
          INTO l_occurs_which
          FROM dual;
        SELECT DECODE (
                   p_day_of_week,
                   1, 'SUNDAY',
                   2, 'MONDAY',
                   3, 'TUESDAY',
                   4, 'WEDNESDAY',
                   5, 'THURSDAY',
                   6, 'FRIDAY',
                   7, 'SATURDAY',
                   0, 'DAY',
                   8, 'WEEKDAY',
                   9, 'WEEKEND'
               )
          INTO l_day_of_week
          FROM dual;
        jtf_task_recurrences_pvt.recur_main (
            p_occurs_which => l_occurs_which,
            p_date_of_month => p_date_of_month,
            p_day_of_week => l_day_of_week,
            p_occurs_month => p_occurs_month,
            p_occurs_uom => p_occurs_uom,
            p_occurs_every => p_occurs_every,
            p_occurs_number => p_occurs_number,
            p_start_date => p_start_date,
            p_end_date => p_end_date,
            x_output_dates_tbl => x_output_dates_tbl,
            x_output_dates_counter => x_output_dates_counter,
            p_sunday => l_sunday,
            p_monday   =>  l_monday,
            p_tuesday  =>   l_tuesday,
            p_wednesday  =>  l_wednesday,
            p_thursday   =>  l_thursday,
            p_friday     =>  l_friday,
            p_saturday   =>  l_saturday,
            p_task_id    =>  p_task_id
        );
    END;

    FUNCTION get_ovn (p_task_id IN NUMBER)
      RETURN NUMBER
   IS
      CURSOR c_tasks_ovn (b_task_id NUMBER)
      IS
         SELECT object_version_number
           FROM jtf_tasks_b
          WHERE task_id = b_task_id;

      l_object_version_number NUMBER;
   BEGIN
      OPEN c_tasks_ovn (p_task_id);
      FETCH c_tasks_ovn INTO l_object_version_number;

      IF c_tasks_ovn%NOTFOUND
      THEN
         CLOSE c_tasks_ovn;
         raise_application_error(-20100,'Task OVN not found at GET_OVN');
      END IF;

      CLOSE c_tasks_ovn;
      RETURN l_object_version_number;
   END get_ovn;

    FUNCTION original_date_meets_criteria (p_output_dates_tbl IN jtf_task_recurrences_pvt.output_dates_rec,
                               p_start_date_active IN DATE)
   RETURN BOOLEAN
   IS
   BEGIN
     FOR i IN 1..p_output_dates_tbl.last LOOP
      IF TRUNC(p_output_dates_tbl(i)) = TRUNC(p_start_date_active) THEN
        RETURN TRUE;
      END IF;
     END LOOP;
     RETURN FALSE;
   END;

   FUNCTION week_days_are_null (p_sunday IN VARCHAR2, p_monday IN VARCHAR2, p_tuesday IN VARCHAR2,
                                p_wednesday IN VARCHAR2, p_thursday IN VARCHAR2, p_friday IN VARCHAR2,
                                p_saturday IN VARCHAR2)
   RETURN BOOLEAN
   IS
   BEGIN
      IF ((p_sunday = 'N' and p_monday = 'N' and p_tuesday = 'N' and
           p_wednesday = 'N' and p_thursday = 'N'and p_friday = 'N' and
           p_saturday = 'N') OR
           (p_sunday is null and p_monday is null and p_tuesday is null and
            p_wednesday is null and p_thursday is null and p_friday is null
            and p_saturday is null) OR
            (p_sunday = jtf_task_utl.g_no_char and
             p_monday = jtf_task_utl.g_no_char and
             p_tuesday = jtf_task_utl.g_no_char and
             p_wednesday = jtf_task_utl.g_no_char and
             p_thursday = jtf_task_utl.g_no_char and
             p_friday = jtf_task_utl.g_no_char and
             p_saturday = jtf_task_utl.g_no_char)) THEN
               RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
   END;

   PROCEDURE set_last_update_date(p_recurrence_rule_id IN NUMBER)
   IS
       -- Fix bug 2376554
       --CURSOR c_last_update_date IS
       --select max(last_update_date)
       --  from jtf_tasks_b t
       --where t.recurrence_rule_id = p_recurrence_rule_id
       --  and deleted_flag <> 'Y';
       l_date DATE := SYSDATE;
   BEGIN
     -- set all last_update_dates equal, needed for JSync project
     --OPEN c_last_update_date;
     --FETCH c_last_update_date INTO l_date;
     --IF c_last_update_date%NOTFOUND THEN
     --  CLOSE c_last_update_date;
     --  fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
     --  fnd_msg_pub.add;
     --  RAISE fnd_api.g_exc_unexpected_error;
     --ELSE
     -- CLOSE c_last_update_date;
     -- UPDATE jtf_tasks_b
     --    SET last_update_date = NVL(l_date, SYSDATE) -- Fix bug 2376554
     --  WHERE recurrence_rule_id = p_recurrence_rule_id;
     --END IF;

     UPDATE jtf_task_recur_rules
        SET last_update_date = l_date
          , creation_date = l_date
      WHERE recurrence_rule_id = p_recurrence_rule_id;
   END;

   PROCEDURE get_repeat_start_date(p_recurrence_rule_id IN NUMBER,
                                   x_repeat_start_date OUT NOCOPY DATE)
   IS
   CURSOR c_start_date IS
   select min(planned_start_date)
     from jtf_tasks_b t
   where t.recurrence_rule_id = p_recurrence_rule_id
     and deleted_flag <> 'Y';

   l_start_date DATE;
   BEGIN
     OPEN c_start_date;
     FETCH c_start_date INTO l_start_date;
     IF c_start_date%NOTFOUND THEN
       CLOSE c_start_date;
       fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_unexpected_error;
     ELSE
      CLOSE c_start_date;
      x_repeat_start_date := l_start_date;
    END IF;
   END;

   PROCEDURE get_repeat_end_date(p_recurrence_rule_id IN NUMBER,
                                  x_repeat_end_date OUT NOCOPY DATE)
   IS
   CURSOR c_end_date IS
   select max(planned_end_date)
     from jtf_tasks_b t
   where t.recurrence_rule_id = p_recurrence_rule_id
     and deleted_flag <> 'Y';

   l_end_date DATE;
   BEGIN
     OPEN c_end_date;
     FETCH c_end_date INTO l_end_date;
     IF c_end_date%NOTFOUND THEN
       CLOSE c_end_date;
       fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_unexpected_error;
     ELSE
      CLOSE c_end_date;
      x_repeat_end_date := l_end_date;
    END IF;
   END;


-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
    PROCEDURE validate_task_recurrence (
        p_occurs_which            IN       INTEGER DEFAULT NULL,
        p_day_of_week             IN       INTEGER DEFAULT NULL,
        p_date_of_month           IN       INTEGER DEFAULT NULL,
        p_occurs_month            IN       INTEGER DEFAULT NULL,
        p_occurs_uom              IN       VARCHAR2 DEFAULT NULL,
        p_occurs_every            IN       INTEGER DEFAULT NULL,
        p_occurs_number           IN       INTEGER DEFAULT NULL,
        p_start_date_active       IN       DATE DEFAULT NULL,
        p_end_date_active         IN       DATE DEFAULT NULL,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        x_return_status           OUT NOCOPY      VARCHAR2,
        p_sunday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_monday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_tuesday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_wednesday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_thursday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_friday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_saturday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char
    )
    IS
    BEGIN
        x_return_status := fnd_api.g_ret_sts_success;

        --- the uom should be right.
        IF p_occurs_uom IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_RECUR_UOM');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF p_occurs_uom NOT IN ('DAY', 'WK', 'WEK', 'MTH', 'MON', 'YR', 'YER')
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_UOM');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
       IF p_start_date_active IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_START_DATE');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        --- at least p_occurs_number or end date should be specified
        IF     ( p_occurs_number <= 0 OR p_occurs_number IS NULL )
           AND p_end_date_active IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_RECUR_END_DATE_MSG');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        IF p_occurs_every IS NULL
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_MISSING_OCCURS_EVERY');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        IF p_occurs_every < 0
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OCCURS_EVERY');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        --- occurs_every should be 1 if uom is year else it should be atleast 1
        IF     p_occurs_uom IN ('YR')
           AND p_occurs_every <> 1
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        ELSE
            IF p_occurs_every < 1
            THEN
                fnd_message.set_name ('JTF', 'JTF_TASK_OCCURS_EVERY_<_THAN_1');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;
        IF p_occurs_uom = 'DAY'
        THEN
            IF    (p_occurs_which IS NOT NULL)
               OR (p_day_of_week IS NOT NULL)
               OR (p_date_of_month IS NOT NULL)
               OR (p_occurs_month IS NOT NULL)
            THEN
               fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

        IF p_occurs_uom = 'WK'
        THEN
            IF    (p_occurs_which IS NOT NULL)
               OR (p_date_of_month IS NOT NULL)
               OR (p_occurs_month IS NOT NULL)
            THEN

                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF p_day_of_week IS NULL
            THEN
                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            ELSE
                IF    (p_day_of_week < 1)
                   OR (p_day_of_week > 7)
                THEN
                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
            END IF;


        END IF;

        IF p_occurs_uom = 'MTH'
        THEN


            --- start from the day of the week
            IF p_day_of_week IS NOT NULL
            THEN

               IF (  p_day_of_week < 0
               OR p_day_of_week > 9)
               THEN

                   fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                   fnd_msg_pub.add;
                   RAISE fnd_api.g_exc_unexpected_error;
               END IF;
            END IF;

            IF     p_occurs_which IS NULL
               AND p_date_of_month IS NULL
            THEN

                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF (p_date_of_month IS NOT NULL)
            THEN

                IF (  p_date_of_month < 1
                   OR p_date_of_month > 31)
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF p_occurs_month IS NOT NULL
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF p_occurs_which IS NOT NULL
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
            END IF;
        END IF;

        IF p_occurs_uom = 'WEK'
        THEN
            IF    (p_occurs_which IS NOT NULL)
               OR (p_date_of_month IS NOT NULL)
               OR (p_occurs_month IS NOT NULL)
            THEN

                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

            IF week_days_are_null(p_sunday, p_monday, p_tuesday, p_wednesday, p_thursday, p_friday, p_saturday)
            THEN
                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

        IF p_occurs_uom = 'MON'
        THEN

            IF p_sunday = 'N' and p_monday = 'N' and p_tuesday = 'N' and p_wednesday = 'N' and p_thursday = 'N'
                   and p_friday = 'N' and p_saturday = 'N'
            THEN
                --- here the date of the month should be specified
                IF p_date_of_month IS NULL
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF (  p_date_of_month < 1
                   OR p_date_of_month > 31)
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF p_occurs_month IS NOT NULL
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF p_occurs_which IS NOT NULL
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
            ELSE
            /*  IF p_date_of_month IS NOT NULL
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF p_occurs_month IS NOT NULL
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
            */
                IF (p_occurs_which NOT IN (1, 2, 3, 4, 99))
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
            END IF;
        END IF;

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
---- end of checking month UOM
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------

        IF p_occurs_uom = 'YR'
        THEN
            IF p_occurs_month IS NULL
            THEN

                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            IF    p_occurs_month < 1
               OR p_occurs_month > 12
            THEN

                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            IF     p_date_of_month IS NULL
               AND (  p_occurs_which IS NULL
                   OR p_day_of_week IS NULL)
            THEN

                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            IF     p_date_of_month IS NOT NULL
               AND (  p_occurs_which IS NOT NULL
                   OR p_day_of_week IS NOT NULL)
            THEN
                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            IF p_date_of_month IS NULL
            THEN
                IF (p_occurs_which IS NULL)
                THEN
                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
                IF (p_occurs_which NOT IN (1, 2, 3, 4, 99))
                THEN
                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
                IF p_day_of_week IS NULL
                THEN
                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
                IF (  p_day_of_week < 0
                   OR p_day_of_week > 9)
                THEN
                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
                IF p_date_of_month IS NOT NULL
                THEN
                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
            ELSE
                IF (  p_date_of_month < 1
                   OR p_date_of_month > 31)
                THEN
                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF    (   p_occurs_month = 2
                      AND p_date_of_month > 29)
                   OR (   p_occurs_month IN (1, 3, 5, 7, 8, 10, 12)
                      AND p_date_of_month > 31)
                   OR (   p_occurs_month IN (4, 6, 9, 11)
                      AND p_date_of_month > 30)
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF    (p_occurs_which IS NOT NULL)
                   OR (p_day_of_week IS NOT NULL)
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
            END IF;
        END IF;
        IF p_occurs_uom = 'YER'
        THEN
            IF p_occurs_month IS NULL
            THEN

                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            IF    p_occurs_month < 1
               OR p_occurs_month > 12
            THEN

                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            IF     p_date_of_month IS NULL
               AND (p_occurs_which IS NULL
                   OR week_days_are_null(p_sunday, p_monday, p_tuesday, p_wednesday, p_thursday, p_friday, p_saturday))
            THEN

                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            IF     p_date_of_month IS NOT NULL
               AND (  p_occurs_which IS NOT NULL
                   OR p_day_of_week IS NOT NULL)
            THEN
                fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            IF p_date_of_month IS NULL
            THEN
                IF (p_occurs_which IS NULL)
                THEN
                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
                IF (p_occurs_which NOT IN (1, 2, 3, 4, 99))
                THEN
                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
                IF week_days_are_null(p_sunday, p_monday, p_tuesday, p_wednesday, p_thursday, p_friday, p_saturday)
                THEN
                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
                IF p_date_of_month IS NOT NULL
                THEN
                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
            ELSE
                IF (  p_date_of_month < 1
                   OR p_date_of_month > 31)
                THEN
                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF    (p_occurs_month = 2
                      AND p_date_of_month > 29)
                   OR (   p_occurs_month IN (1, 3, 5, 7, 8, 10, 12)
                      AND p_date_of_month > 31)
                   OR (   p_occurs_month IN (4, 6, 9, 11)
                      AND p_date_of_month > 30)
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;

                IF    (p_occurs_which IS NOT NULL)
                   OR (p_day_of_week IS NOT NULL)
                THEN

                    fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_RECUR_RULE');
                    fnd_msg_pub.add;
                    RAISE fnd_api.g_exc_unexpected_error;
                END IF;
              END IF;
        END IF;

        EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
    PROCEDURE create_task_recurrence (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                 IN       NUMBER,
        p_occurs_which            IN       INTEGER DEFAULT NULL,
        p_day_of_week             IN       INTEGER DEFAULT NULL,
        p_date_of_month           IN       INTEGER DEFAULT NULL,
        p_occurs_month            IN       INTEGER DEFAULT NULL,
        p_occurs_uom              IN       VARCHAR2 DEFAULT NULL,
        p_occurs_every            IN       INTEGER DEFAULT NULL,
        p_occurs_number           IN       INTEGER DEFAULT NULL,
        p_start_date_active       IN       DATE DEFAULT NULL,
        p_end_date_active         IN       DATE DEFAULT NULL,
        p_template_flag           IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        x_recurrence_rule_id      OUT NOCOPY      NUMBER,
        x_task_rec                OUT NOCOPY      jtf_task_recurrences_pub.task_details_rec,
        x_output_dates_counter    OUT NOCOPY      INTEGER,
        p_attribute1              IN       VARCHAR2 DEFAULT null ,
        p_attribute2              IN       VARCHAR2 DEFAULT null ,
        p_attribute3              IN       VARCHAR2 DEFAULT null ,
        p_attribute4              IN       VARCHAR2 DEFAULT null ,
        p_attribute5              IN       VARCHAR2 DEFAULT null ,
        p_attribute6              IN       VARCHAR2 DEFAULT null ,
        p_attribute7              IN       VARCHAR2 DEFAULT null ,
        p_attribute8              IN       VARCHAR2 DEFAULT null ,
        p_attribute9              IN       VARCHAR2 DEFAULT null ,
        p_attribute10             IN       VARCHAR2 DEFAULT null ,
        p_attribute11             IN       VARCHAR2 DEFAULT null ,
        p_attribute12             IN       VARCHAR2 DEFAULT null ,
        p_attribute13             IN       VARCHAR2 DEFAULT null ,
        p_attribute14             IN       VARCHAR2 DEFAULT null ,
        p_attribute15             IN       VARCHAR2 DEFAULT null ,
        p_attribute_category      IN       VARCHAR2 DEFAULT null ,
        p_sunday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_monday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_tuesday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_wednesday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_thursday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_friday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_saturday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char
        )
    IS
        l_output_dates_tbl        jtf_task_recurrences_pvt.output_dates_rec;
        l_recur_task_id           NUMBER;
        l_api_version    CONSTANT NUMBER                                       := 1.0;
        l_api_name       CONSTANT VARCHAR2(30)                                 := 'CREATE_TASK_RECURRENCE';
        l_task_id                 jtf_tasks_b.task_id%TYPE                     := p_task_id;
        l_recur_id                jtf_task_recur_rules.recurrence_rule_id%TYPE;
        l_rowid                   ROWID;
        x                         CHAR;
        l_date_selected           VARCHAR(1);
        l_planned_start_date      date ;
        l_planned_end_date        date ;
        l_scheduled_start_date    date ;
        l_scheduled_end_date      date ;
        l_actual_start_date       date ;
        l_actual_end_date         date ;
        l_ovn                     NUMBER;
        l_repeat_start_date       date;
        l_repeat_end_date         date;
        l_last                binary_integer; -- Fix bug 2376554
        l_calendar_start_date DATE; -- Fix bug 2376554
        l_calendar_end_date   DATE; -- Fix bug 2376554
        l_valid               BOOLEAN := FALSE; -- Fix bug 2376554
        l_current             DATE;

        CURSOR c_jtf_task_recur (
            l_rowid                   IN       ROWID
        )
        IS
            SELECT 1
              FROM jtf_task_recur_rules
             WHERE ROWID = l_rowid;

        i                         NUMBER;

	CURSOR c_task_details
	IS
	SELECT planned_start_date
	     , planned_end_date
	     , scheduled_start_date
	     , scheduled_end_date
	     , actual_start_date
	     , actual_end_date
	     , task_status_id
	     , creation_date
	FROM   jtf_tasks_b
	WHERE  task_id = p_task_id;

        /* Start of addition by lokumar for bug#6067036 */
        cursor c_task_planned_effort (p_task_id   number)
        is
        select planned_effort,
               planned_effort_uom
          from jtf_tasks_b
         where task_id=p_task_id;

        v_task_planned_effort    c_task_planned_effort%rowtype;

        cursor c_assign_actual_dtls (p_task_id   number)
        is
        select task_assignment_id,
               actual_start_date,
               actual_end_date,
               actual_travel_duration,
               actual_travel_duration_uom,
               actual_effort,
               actual_effort_uom
          from jtf_task_all_assignments
         where task_id = p_task_id;

        l_booking_start_date    Date;
        l_booking_end_date      Date;

	/* End of additon lokumar for bug#6067036 */


	l_task_details    c_task_details%rowtype;

    BEGIN
       IF jtf_task_recurrences_pub.creating_recurrences
        THEN
          RETURN;
        END IF;

        jtf_task_recurrences_pub.creating_recurrences := TRUE;

        SAVEPOINT create_task_recur_pvt;
        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        --- check if the given task id has already the recur
        --- checking if the task already has a recurrence
        IF jtf_task_utl.to_boolean (p_template_flag)
        THEN


            SELECT recurrence_rule_id
              INTO l_recur_id
              FROM jtf_task_templates_b
             WHERE task_template_id = l_task_id;

            IF l_recur_id IS NOT NULL
            THEN

                x_return_status := fnd_api.g_ret_sts_error;
                fnd_message.set_name ('JTF', 'JTF_TASK_RECURS_TEMP_ALREADY');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        ELSE
            SELECT recurrence_rule_id
              INTO l_recur_id
              FROM jtf_tasks_b
             WHERE task_id = l_task_id;
            IF l_recur_id IS NOT NULL
            THEN
                x_return_status := fnd_api.g_ret_sts_error;
                fnd_message.set_name ('JTF', 'JTF_TASK_RECURS_TASK_ALREADY');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;

        jtf_task_recurrences_pvt.validate_task_recurrence (
            p_occurs_which => p_occurs_which,
            p_day_of_week => p_day_of_week,
            p_date_of_month => p_date_of_month,
            p_occurs_month => p_occurs_month,
            p_occurs_uom => p_occurs_uom,
            p_occurs_every => p_occurs_every,
            p_occurs_number => p_occurs_number,
            p_start_date_active => p_start_date_active,
            p_end_date_active => p_end_date_active,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_return_status => x_return_status,
            p_sunday => p_sunday,
            p_monday   =>  p_monday,
            p_tuesday  =>   p_tuesday,
            p_wednesday  =>  p_wednesday,
            p_thursday   =>  p_thursday,
            p_friday     =>  p_friday,
            p_saturday   =>  p_saturday
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        --- Call the procedure to generate the dates
        IF not jtf_task_utl.to_boolean (p_template_flag)
        THEN
        jtf_task_recurrences_pvt.generate_dates (
            p_occurs_which => p_occurs_which,
            p_day_of_week => p_day_of_week,
            p_date_of_month => p_date_of_month,
            p_occurs_month => p_occurs_month,
            p_occurs_uom => p_occurs_uom,
            p_occurs_every => p_occurs_every,
            p_occurs_number => p_occurs_number,
            p_start_date => p_start_date_active,
            p_end_date => p_end_date_active,
            x_output_dates_tbl => l_output_dates_tbl,
            x_output_dates_counter => x_output_dates_counter,
            p_sunday => p_sunday,
            p_monday   =>  p_monday,
            p_tuesday  =>   p_tuesday,
            p_wednesday  =>  p_wednesday,
            p_thursday   =>  p_thursday,
            p_friday     =>  p_friday,
            p_saturday   =>  p_saturday,
            p_task_id    =>  p_task_id
        );

        END IF ;
        IF x_output_dates_counter > 1
        THEN
            x_output_dates_counter := x_output_dates_counter - 1;
        END IF;

        i := 1;

        --- To fix bug#2170817
        BEGIN
        SELECT date_selected
            INTO l_date_selected
            FROM jtf_tasks_b
            WHERE task_id = p_task_id;
        EXCEPTION WHEN OTHERS THEN
            l_date_selected := null;
        END;

        SELECT jtf_task_recur_rules_s.nextval
          INTO l_recur_id
          FROM dual;

        jtf_task_recur_rules_pkg.insert_row (
            x_rowid => l_rowid,
            x_recurrence_rule_id => l_recur_id,
            x_occurs_which => p_occurs_which,
            x_day_of_week => p_day_of_week,
            x_date_of_month => p_date_of_month,
            x_occurs_month => p_occurs_month,
            x_occurs_uom => p_occurs_uom,
            x_occurs_every => p_occurs_every,
            x_occurs_number => p_occurs_number,
            x_start_date_active => p_start_date_active,
            x_end_date_active => p_end_date_active,
            x_attribute1 => p_attribute1 ,
            x_attribute2 => p_attribute2 ,
            x_attribute3 => p_attribute3 ,
            x_attribute4 => p_attribute4 ,
            x_attribute5 => p_attribute5 ,
            x_attribute6 => p_attribute6 ,
            x_attribute7 => p_attribute7 ,
            x_attribute8 => p_attribute8 ,
            x_attribute9 => p_attribute9 ,
            x_attribute10 => p_attribute10 ,
            x_attribute11 => p_attribute11 ,
            x_attribute12 => p_attribute12 ,
            x_attribute13 => p_attribute13 ,
            x_attribute14 => p_attribute14 ,
            x_attribute15 => p_attribute15,
            x_attribute_category => p_attribute_category ,
            x_creation_date => SYSDATE,
            x_created_by => jtf_task_utl.created_by,
            x_last_update_date => SYSDATE,
            x_last_updated_by => jtf_task_utl.updated_by,
           x_last_update_login => fnd_global.login_id,
            x_sunday => p_sunday,
            x_monday => p_monday,
            x_tuesday => p_tuesday,
            x_wednesday => p_wednesday,
            x_thursday => p_thursday,
            x_friday => p_friday,
            x_saturday => p_saturday,
            x_date_selected => l_date_selected
        );
        OPEN c_jtf_task_recur (l_rowid);
        FETCH c_jtf_task_recur INTO x;

        IF c_jtf_task_recur%NOTFOUND
        THEN

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'ERROR_INSERTING_RECURRENCE');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        ELSE
             x_recurrence_rule_id := l_recur_id;

            IF jtf_task_utl.to_boolean(p_template_flag)
            THEN
                UPDATE jtf_task_templates_b
                   SET recurrence_rule_id = l_recur_id
                 WHERE task_template_id = l_task_id;
            ELSE
                UPDATE jtf_tasks_b
                   SET recurrence_rule_id = l_recur_id
                 WHERE task_id = l_task_id;

            END IF;
            IF SQL%NOTFOUND
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                fnd_message.set_name ('JTF', 'ERROR_UPDATING_TASK');
                fnd_msg_pub.add;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
        END IF;


        OPEN  c_task_details;
        FETCH c_task_details into l_task_details;
        IF c_task_details%NOTFOUND
	THEN
	  CLOSE c_task_details;
          fnd_message.set_name('JTF','JTF_TASK_INVALID_TASK_ID');
          fnd_message.set_token('P_TASK_ID', p_task_id);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

	--- if it a template do nothing
        --- else call copy tasks to create the tasks.
        ---

        IF NOT jtf_task_utl.to_boolean (p_template_flag)
        THEN
            i := 1;
            WHILE i <= x_output_dates_counter
            LOOP
                l_valid := FALSE; -- Fix bug 2376554


               IF l_date_selected = 'P' OR l_date_selected IS NULL
               THEN

                 IF ( l_task_details.planned_end_date   IS NULL   AND
                      l_task_details.planned_start_date IS NOT NULL
                    )
                 THEN
                   l_planned_start_date :=
                     get_dst_corrected_date( TO_DATE(TO_CHAR(l_output_dates_tbl (i),'dd-mm-rrrr')||TO_CHAR (l_task_details.planned_start_date, 'hh24:mi:ss'), 'DD-MM-RRRRHH24:MI:SS')
                                           , l_task_details.planned_start_date
                                           );

                   l_planned_end_date := NULL ;

                 ELSIF ( l_task_details.planned_end_date IS NOT NULL AND
                         l_task_details.planned_start_date IS  NULL
                       )
                 THEN
                   l_planned_end_date :=
                     get_dst_corrected_date( TO_DATE(TO_CHAR(l_output_dates_tbl (i),'dd-mm-rrrr') || TO_CHAR (l_task_details.planned_end_date, 'hh24:mi:ss'), 'DD-MM-RRRRHH24:MI:SS')
                                           , l_task_details.planned_end_date
                                           );
                   l_planned_start_date := null ;


                 ELSIF ( l_task_details.planned_end_date IS NULL AND
                         l_task_details.planned_start_date IS  NULL
                       )
                 THEN
                   l_planned_start_date := l_output_dates_tbl(i);
                   l_planned_end_date   := NULL ;

                 ELSIF ( l_task_details.planned_end_date IS NOT NULL AND
                         l_task_details.planned_start_date IS NOT NULL
                       )
                 THEN
                   l_planned_start_date :=
                     get_dst_corrected_date(TO_DATE(TO_CHAR(l_output_dates_tbl (i),'dd-mm-rrrr') || TO_CHAR (l_task_details.planned_start_date, 'hh24:mi:ss'), 'DD-MM-RRRRHH24:MI:SS')
                                           , l_task_details.planned_start_date
                                           );
                   l_planned_end_date := l_planned_start_date + (l_task_details.planned_end_date - l_task_details.planned_start_date);
                 END IF;

	       ELSIF l_date_selected = 'S'
               THEN
                 IF ( l_task_details.scheduled_end_date IS NULL AND
                      l_task_details.scheduled_start_date IS NOT NULL
                    )
                 THEN
                   l_scheduled_start_date :=
                     get_dst_corrected_date(TO_DATE (TO_CHAR(l_output_dates_tbl (i),'dd-mm-rrrr')||TO_CHAR (l_task_details.scheduled_start_date, 'hh24:mi:ss'), 'dd-mm-rrrrhh24:mi:ss')
                                          ,l_task_details.scheduled_start_date
                                          );
                   l_scheduled_end_date := Null ;

                 ELSIF ( l_task_details.scheduled_end_date IS NOT NULL AND
                         l_task_details.scheduled_start_date IS  NULL
                       )
                 THEN
                   l_scheduled_end_date :=
                     get_dst_corrected_date(TO_DATE (to_char(l_output_dates_tbl (i),'dd-mm-rrrr') || TO_CHAR (l_task_details.scheduled_end_date, 'hh24:mi:ss'), 'dd-mm-rrrrhh24:mi:ss')
                                           ,l_task_details.scheduled_end_date
                                           );
                   l_scheduled_start_date := null ;

                 ELSIF ( l_task_details.scheduled_end_date IS NULL AND
                         l_task_details.scheduled_start_date IS  NULL
                       )
                 THEN
                   l_scheduled_start_date := l_output_dates_tbl(i);
                   l_scheduled_end_date := null ;
                 ELSIF ( l_task_details.scheduled_end_date IS NOT NULL  AND
                         l_task_details.scheduled_start_date IS NOT NULL
                       )
                 THEN
                   l_scheduled_start_date :=
                     get_dst_corrected_date(TO_DATE (to_char(l_output_dates_tbl (i),'dd-mm-rrrr') || TO_CHAR (l_task_details.scheduled_start_date, 'hh24:mi:ss'), 'dd-mm-rrrrhh24:mi:ss')
                                       ,l_task_details.scheduled_start_date
                                       );
                   l_scheduled_end_date := l_scheduled_start_date + (l_task_details.scheduled_end_date - l_task_details.scheduled_start_date);
                 END IF;

	      ELSIF l_date_selected = 'A'
              THEN
                IF ( l_task_details.actual_end_date IS NULL AND
                     l_task_details.actual_start_date IS NOT NULL
                   )
                THEN
                  l_actual_start_date :=
                    get_dst_corrected_date(TO_DATE (to_char(l_output_dates_tbl (i),'dd-mm-rrrr')||TO_CHAR (l_task_details.actual_start_date, 'hh24:mi:ss'), 'dd-mm-rrrrhh24:mi:ss')
                                          ,l_task_details.actual_start_date
					  );
                  l_actual_end_date := Null ;

                ELSIF ( l_task_details.actual_end_date IS NOT NULL AND
                        l_task_details.actual_start_date IS  NULL
                      )
                THEN
                  l_actual_end_date :=
                    get_dst_corrected_date(TO_DATE (to_char(l_output_dates_tbl (i),'dd-mm-rrrr') || TO_CHAR (l_task_details.actual_end_date, 'hh24:mi:ss'), 'dd-mm-rrrrhh24:mi:ss')
                                          ,l_task_details.actual_end_date
					  );
                  l_actual_start_date := null ;

                ELSIF ( l_task_details.actual_end_date IS NULL AND
                        l_task_details.actual_start_date IS  NULL
                      )
                THEN
                  l_actual_start_date := l_output_dates_tbl(i);
                  l_actual_end_date := null ;
                ELSIF ( l_task_details.actual_end_date IS NOT NULL AND
                        l_task_details.actual_start_date IS NOT NULL
                      )
                THEN
                  l_actual_start_date :=
                    get_dst_corrected_date(TO_DATE (to_char(l_output_dates_tbl (i),'dd-mm-rrrr') || TO_CHAR (l_task_details.actual_start_date, 'hh24:mi:ss'), 'dd-mm-rrrrhh24:mi:ss')
                                          ,l_task_details.actual_start_date
                                          );
                  l_actual_end_date := l_actual_start_date + (l_task_details.actual_end_date - l_task_details.actual_start_date);
                END IF;


             END IF;

             IF l_date_selected = 'P' OR l_date_selected IS NULL
               THEN


                       --change or add dates for scheduled date fields with the same pattern
                       IF (  l_task_details.scheduled_end_date IS NULL
                          AND l_task_details.scheduled_start_date IS NOT NULL)
                       THEN

                          l_scheduled_start_date :=
                          l_task_details.scheduled_start_date +(l_planned_start_date - l_task_details.planned_start_date);

                          l_scheduled_end_date := Null ;
                       elsif (  l_task_details.scheduled_end_date IS NOT NULL
                          AND l_task_details.scheduled_start_date IS  NULL)
                       THEN

                          l_scheduled_end_date :=
                          l_task_details.scheduled_end_date +(l_planned_start_date  - l_task_details.planned_start_date);

                          l_scheduled_start_date := Null ;

                       elsif
                        (  l_task_details.scheduled_end_date IS NULL
                          AND l_task_details.scheduled_start_date IS  NULL)
                       THEN

                          l_scheduled_start_date := null;
                          l_scheduled_end_date := null ;
                       elsif
                       (  l_task_details.scheduled_end_date IS NOT NULL
                          AND l_task_details.scheduled_start_date IS NOT NULL)
                       THEN

                          l_scheduled_start_date :=
                          l_task_details.scheduled_start_date + (l_planned_start_date - l_task_details.planned_start_date);

                          l_scheduled_end_date :=
                          l_task_details.scheduled_end_date + (l_planned_start_date - l_task_details.planned_start_date);
                       end if;-- for scheduled

                       --change or add dates for actual date fields with the same pattern
                       IF (  l_task_details.actual_end_date IS NULL
                          AND l_task_details.actual_start_date IS NOT NULL)
                       THEN

                          l_actual_start_date :=
                          l_task_details.actual_start_date + (l_planned_start_date - l_task_details.planned_start_date);

                          l_actual_end_date := Null ;

                       elsif (  l_task_details.actual_end_date IS NOT NULL
                          AND l_task_details.actual_start_date IS  NULL)
                       THEN

                          l_actual_end_date :=
                          l_task_details.actual_end_date + (l_planned_start_date - l_task_details.planned_start_date);

                          l_actual_start_date := Null ;

                       elsif
                        (  l_task_details.actual_end_date IS NULL
                          AND l_task_details.actual_start_date IS  NULL)
                       THEN

                          l_actual_start_date := null;
                          l_actual_end_date := null ;
                       elsif
                       (  l_task_details.actual_end_date IS NOT NULL
                          AND l_task_details.actual_start_date IS NOT NULL)
                       THEN

                          l_actual_start_date :=
                          l_task_details.actual_start_date + (l_planned_start_date - l_task_details.planned_start_date);

                          l_actual_end_date :=
                          l_task_details.actual_end_date + (l_planned_start_date - l_task_details.planned_start_date);
                       end if;-- for actual

             ELSIF l_date_selected = 'S'
              THEN

                       --change or add dates for planned date fields with the same pattern
                       IF (  l_task_details.planned_end_date IS NULL
                          AND l_task_details.planned_start_date IS NOT NULL)
                       THEN

                          l_planned_start_date :=
                          l_task_details.planned_start_date + (l_scheduled_start_date - l_task_details.scheduled_start_date);

                          l_planned_end_date := Null ;

                       elsif (  l_task_details.planned_end_date IS NOT NULL
                          AND l_task_details.planned_start_date IS  NULL)
                       THEN

                          l_planned_end_date :=
                          l_task_details.planned_end_date + (l_scheduled_start_date - l_task_details.scheduled_start_date);

                          l_planned_start_date := Null ;

                       elsif
                        (  l_task_details.planned_end_date IS NULL
                          AND l_task_details.planned_start_date IS  NULL)
                       THEN

                          l_planned_start_date := null;
                          l_planned_end_date := null ;
                       elsif
                       (  l_task_details.planned_end_date IS NOT NULL
                          AND l_task_details.planned_start_date IS NOT NULL)
                       THEN

                          l_planned_start_date :=
                          l_task_details.planned_start_date + (l_scheduled_start_date - l_task_details.scheduled_start_date);

                          l_planned_end_date :=
                          l_task_details.planned_end_date + (l_scheduled_start_date - l_task_details.scheduled_start_date);
                       end if;-- for planned

                       --change or add dates for actual date fields with the same pattern
                       IF (  l_task_details.actual_end_date IS NULL
                          AND l_task_details.actual_start_date IS NOT NULL)
                       THEN

                          l_actual_start_date :=
                          l_task_details.actual_start_date + (l_scheduled_start_date - l_task_details.scheduled_start_date);

                          l_actual_end_date := Null ;

                       elsif (  l_task_details.actual_end_date IS NOT NULL
                          AND l_task_details.actual_start_date IS  NULL)
                       THEN

                          l_actual_end_date :=
                          l_task_details.actual_end_date + (l_scheduled_start_date - l_task_details.scheduled_start_date);

                          l_actual_start_date := Null ;

                       elsif
                        (  l_task_details.actual_end_date IS NULL
                          AND l_task_details.actual_start_date IS  NULL)
                       THEN

                          l_actual_start_date := null;
                          l_actual_end_date := null ;
                       elsif
                       (  l_task_details.actual_end_date IS NOT NULL
                          AND l_task_details.actual_start_date IS NOT NULL)
                       THEN

                          l_actual_start_date :=
                          l_task_details.actual_start_date + (l_scheduled_start_date - l_task_details.scheduled_start_date);

                          l_actual_end_date :=
                          l_task_details.actual_end_date + (l_scheduled_start_date - l_task_details.scheduled_start_date);
                       end if;-- for actual

             ELSIF l_date_selected = 'A'
              THEN

                          --change or add dates for planned date fields with the same pattern
                       IF (  l_task_details.planned_end_date IS NULL
                          AND l_task_details.planned_start_date IS NOT NULL)
                       THEN

                          l_planned_start_date :=
                          l_task_details.planned_start_date + (l_actual_start_date - l_task_details.actual_start_date);

                          l_planned_end_date := Null ;

                       elsif (  l_task_details.planned_end_date IS NOT NULL
                          AND l_task_details.planned_start_date IS  NULL)
                       THEN

                          l_planned_end_date :=
                          l_task_details.planned_end_date + (l_actual_start_date - l_task_details.actual_start_date);

                          l_planned_start_date := Null ;

                       elsif
                        (  l_task_details.planned_end_date IS NULL
                          AND l_task_details.planned_start_date IS  NULL)
                       THEN

                          l_planned_start_date := null;
                          l_planned_end_date := null ;
                       elsif
                       (  l_task_details.planned_end_date IS NOT NULL
                          AND l_task_details.planned_start_date IS NOT NULL)
                       THEN

                          l_planned_start_date :=
                          l_task_details.planned_start_date + (l_actual_start_date - l_task_details.actual_start_date);

                          l_planned_end_date :=
                          l_task_details.planned_end_date + (l_actual_start_date - l_task_details.actual_start_date);
                       end if;-- for planned

                       --change or add dates for scheduled date fields with the same pattern
                       IF (  l_task_details.scheduled_end_date IS NULL
                          AND l_task_details.scheduled_start_date IS NOT NULL)
                       THEN

                          l_scheduled_start_date :=
                          l_task_details.scheduled_start_date + (l_actual_start_date - l_task_details.actual_start_date);

                          l_scheduled_end_date := Null ;

                       elsif (  l_task_details.scheduled_end_date IS NOT NULL
                          AND l_task_details.scheduled_start_date IS  NULL)
                       THEN

                          l_scheduled_end_date :=
                          l_task_details.scheduled_end_date + (l_actual_start_date - l_task_details.actual_start_date);

                          l_scheduled_start_date := Null ;

                       elsif
                        (  l_task_details.scheduled_end_date IS NULL
                          AND l_task_details.scheduled_start_date IS  NULL)
                       THEN

                          l_scheduled_start_date := null;
                          l_scheduled_end_date := null ;
                       elsif
                       (  l_task_details.scheduled_end_date IS NOT NULL
                          AND l_task_details.scheduled_start_date IS NOT NULL)
                       THEN

                          l_scheduled_start_date :=
                          l_task_details.scheduled_start_date + (l_actual_start_date - l_task_details.actual_start_date);

                          l_scheduled_end_date :=
                          l_task_details.scheduled_end_date + (l_actual_start_date - l_task_details.actual_start_date);
                       end if;-- for scheduled
             ELSIF l_date_selected = 'D'
	     THEN
	       l_planned_start_date   := NULL;
	       l_planned_end_date     := NULL;
	       l_scheduled_start_date := NULL;
	       l_scheduled_end_date   := NULL;
	       l_actual_start_date    := NULL;
	       l_actual_end_date      := NULL;
	       IF l_task_details.planned_start_date IS NOT NULL
	       THEN
	         l_planned_start_date := get_dst_corrected_date( TO_DATE(TO_CHAR(l_output_dates_tbl (i),'dd-mm-rrrr')||TO_CHAR (l_task_details.planned_start_date, 'hh24:mi:ss'), 'DD-MM-RRRRHH24:MI:SS')
                                           , l_task_details.planned_start_date
                                           );
               END IF;

	       IF l_task_details.planned_end_date IS NOT NULL
	       THEN
	         l_planned_end_date := get_dst_corrected_date( TO_DATE(TO_CHAR(l_output_dates_tbl (i),'dd-mm-rrrr')||TO_CHAR (l_task_details.planned_end_date, 'hh24:mi:ss'), 'DD-MM-RRRRHH24:MI:SS')
                                          , l_task_details.planned_end_date
                                          );
               END IF;

	       IF l_task_details.scheduled_start_date IS NOT NULL
	       THEN
	         l_scheduled_start_date :=  get_dst_corrected_date( TO_DATE(TO_CHAR(l_output_dates_tbl (i),'dd-mm-rrrr')||TO_CHAR (l_task_details.scheduled_start_date, 'hh24:mi:ss'), 'DD-MM-RRRRHH24:MI:SS')
                                             , l_task_details.scheduled_start_date
                                           );
               END IF;

	       IF l_task_details.scheduled_end_date IS NOT NULL
	       THEN
	         l_scheduled_end_date :=  get_dst_corrected_date( TO_DATE(TO_CHAR(l_output_dates_tbl (i),'dd-mm-rrrr')||TO_CHAR (l_task_details.scheduled_end_date, 'hh24:mi:ss'), 'DD-MM-RRRRHH24:MI:SS')
                                           , l_task_details.scheduled_end_date
                                           );
               END IF;

	       IF l_task_details.actual_start_date IS NOT NULL
	       THEN
	         l_actual_start_date :=  get_dst_corrected_date( TO_DATE(TO_CHAR(l_output_dates_tbl (i),'dd-mm-rrrr')||TO_CHAR (l_task_details.actual_start_date, 'hh24:mi:ss'), 'DD-MM-RRRRHH24:MI:SS')
                                           , l_task_details.actual_start_date
                                           );
               END IF;

	       IF l_task_details.actual_end_date IS NOT NULL
	       THEN
	         l_actual_end_date :=  get_dst_corrected_date( TO_DATE(TO_CHAR(l_output_dates_tbl (i),'dd-mm-rrrr')||TO_CHAR (l_task_details.actual_end_date, 'hh24:mi:ss'), 'DD-MM-RRRRHH24:MI:SS')
                                           , l_task_details.actual_end_date
                                           );
               END IF;
             END IF;








                IF l_date_selected IS NULL                          -- Added by lokumar for bug#6067036
		THEN
                    l_calendar_start_date := NULL;
                    l_calendar_end_date   := NULL;
                    l_valid := TRUE;
                ELSIF l_date_selected = 'P' --OR l_date_selected IS NULL  -- Commented out by lokumar for bug#6067036
                THEN
                    if ((p_end_date_active is null or trunc(l_planned_start_date) <= trunc(p_end_date_active))
                       --and trunc(p_start_date_active) <> trunc(l_planned_start_date) then
                       and trunc(l_task_details.planned_start_date) <> trunc(l_planned_start_date))
                       OR l_date_selected IS NULL -- Fix bug 2376554
                    then
                        l_calendar_start_date := l_planned_start_date; -- Fix bug 2376554
                        l_calendar_end_date   := l_planned_end_date; -- Fix bug 2376554
                        l_valid := TRUE; -- Fix bug 2376554
                   end if;
                ELSIF l_date_selected = 'S'
                THEN
                   if (p_end_date_active is null or trunc(l_scheduled_start_date) <= trunc(p_end_date_active))
                      --and trunc(p_start_date_active) <> trunc(l_scheduled_start_date) then
                      and trunc(l_task_details.scheduled_start_date) <> trunc(l_scheduled_start_date) then
                        l_calendar_start_date := l_scheduled_start_date; -- Fix bug 2376554
                        l_calendar_end_date   := l_scheduled_end_date; -- Fix bug 2376554
                        l_valid := TRUE; -- Fix bug 2376554
                   end if;
                ELSIF l_date_selected = 'A'
                THEN
                   if (p_end_date_active is null or trunc(l_actual_start_date) <= trunc(p_end_date_active))
                       --and trunc(p_start_date_active) <> trunc(l_actual_start_date) then
                       and trunc(l_task_details.actual_start_date) <> trunc(l_actual_start_date) then
                        l_calendar_start_date := l_actual_start_date; -- Fix bug 2376554
                        l_calendar_end_date   := l_actual_end_date; -- Fix bug 2376554
                        l_valid := TRUE; -- Fix bug 2376554
                   end if;
		ELSIF l_date_selected = 'D'
		THEN
		  jtf_task_utl_ext.set_start_n_due_date (
	              p_task_status_id        => l_task_details.task_status_id
		    , p_planned_start_date    => l_planned_start_date
	            , p_planned_end_date      => l_planned_end_date
	            , p_scheduled_start_date  => l_scheduled_start_date
	            , p_scheduled_end_date    => l_scheduled_end_date
	            , p_actual_start_date     => l_actual_start_date
	            , p_actual_end_date       => l_actual_end_date
	            , p_creation_date         => l_task_details.creation_date
	            , x_calendar_start_date   => l_calendar_start_date
	            , x_calendar_end_date     => l_calendar_end_date
	            , x_return_status         => x_return_status);

 	          IF NOT (x_return_status = fnd_api.g_ret_sts_success)
                  THEN
                    RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
		  l_valid := TRUE;
                END IF;

                -------------------------
                -- Fix bug 2376554
                -------------------------
                IF l_valid
                THEN
                    l_current := SYSDATE;

                    IF i <> 1
                    THEN
                        jtf_tasks_pub.copy_task (
                            p_api_version => 1.0,
                            p_init_msg_list => fnd_api.g_false,
                            p_commit => fnd_api.g_true,
                            p_source_task_id => l_task_id,
                            p_copy_task_assignments => fnd_api.g_true,
                            p_copy_task_rsc_reqs => fnd_api.g_true,
                            p_copy_task_depends => fnd_api.g_true,
                            p_create_recurrences => fnd_api.g_false,
                            p_copy_task_references => fnd_api.g_true,
                            p_copy_task_dates => fnd_api.g_true,
                            p_copy_task_contacts => fnd_api.g_true,
                            p_copy_task_contact_points => fnd_api.g_true,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data,
                            x_task_id => l_recur_task_id
                        );

                        UPDATE jtf_tasks_b
                           SET recurrence_rule_id = l_recur_id,
                               planned_start_date     = l_planned_start_date ,
                               planned_end_date       = l_planned_end_date,
                               scheduled_start_date   = l_scheduled_start_date ,
                               scheduled_end_date     = l_scheduled_end_date,
                               actual_start_date      = l_actual_start_date ,
                               actual_end_date        = l_actual_end_date,
                               calendar_start_date    = l_calendar_start_date ,
                               calendar_end_date      = l_calendar_end_date,
                               creation_date          = l_current,
                               last_update_date       = l_current,
			       date_selected          = l_date_selected       -- Added by lokumar for bug#6067036
                         WHERE task_id = l_recur_task_id ;
                    ELSE
                        UPDATE jtf_tasks_b
                           SET recurrence_rule_id     = l_recur_id,
                               planned_start_date     = l_planned_start_date ,
                               planned_end_date       = l_planned_end_date,
                               scheduled_start_date   = l_scheduled_start_date ,
                               scheduled_end_date     = l_scheduled_end_date,
                               actual_start_date      = l_actual_start_date ,
                               actual_end_date        = l_actual_end_date,
                               calendar_start_date    = l_calendar_start_date ,
                               calendar_end_date      = l_calendar_end_date,
                               creation_date          = l_current,
                               last_update_date       = l_current,
                               date_selected          = l_date_selected       -- Added by lokumar for bug#6067036
                         WHERE task_id = l_task_id ;
                    END IF;

		   /* Start of addition by lokumar for bug#6067036 */

                   OPEN c_task_planned_effort(NVL(l_recur_task_id,l_task_id));
                   FETCH c_task_planned_effort INTO v_task_planned_effort;
                   CLOSE c_task_planned_effort;

                   FOR i IN c_assign_actual_dtls(NVL(l_recur_task_id,l_task_id))
                   LOOP
                       jtf_task_assignments_pvt.populate_booking_dates
                        (
                         p_calendar_start_date         =>  l_calendar_start_date,
                         p_calendar_end_date           =>  l_calendar_end_date,
                         p_actual_start_date           =>  i.actual_start_date,
                         p_actual_end_date             =>  i.actual_end_date,
                         p_actual_travel_duration      =>  i.actual_travel_duration,
                         p_actual_travel_duration_uom  =>  i.actual_travel_duration_uom,
                         p_planned_effort              =>  v_task_planned_effort.planned_effort,
                         p_planned_effort_uom          =>  v_task_planned_effort.planned_effort_uom,
                         p_actual_effort               =>  i.actual_effort,
                         p_actual_effort_uom           =>  i.actual_effort_uom,
                         x_booking_start_date          =>  l_booking_start_date,
                         x_booking_end_date            =>  l_booking_end_date
                        );

                        UPDATE jtf_task_all_assignments
                           SET booking_start_date = l_booking_start_date,
                               booking_end_date   = l_booking_end_date
                         WHERE task_assignment_id = i.task_assignment_id;
                   END LOOP;

		   /* End of addition by lokumar for bug#6067036 */


                END IF;
                ---------------------------------------------------

                jtf_task_recurrences_pub.creating_recurrences := FALSE;
                i := i + 1;
            END LOOP;
        END IF;
        close c_task_details;
        jtf_task_recurrences_pub.creating_recurrences := FALSE;
        IF not jtf_task_utl.to_boolean (p_template_flag) AND -- Fix bug 2395216
           NOT original_date_meets_criteria(p_output_dates_tbl => l_output_dates_tbl ,
                               p_start_date_active => p_start_date_active) and
                               p_occurs_uom <> 'DAY'
        THEN
            -- Fix bug 2376554
            --l_ovn := get_ovn (p_task_id => p_task_id);
            --jtf_tasks_pvt.delete_task (
            --  p_api_version           =>  1.0,
            --  p_init_msg_list         => fnd_api.g_true,
            --  p_commit                => fnd_api.g_false,
            --  p_task_id               => p_task_id,
            --  p_object_version_number => l_ovn,
            --  x_return_status         => x_return_status,
            --  x_msg_count             => x_msg_count,
            --  x_msg_data              => x_msg_data
            --);
            get_repeat_start_date(
                 p_recurrence_rule_id => l_recur_id
                ,x_repeat_start_date => l_repeat_start_date
            );

            UPDATE jtf_task_recur_rules
               SET start_date_active = TRUNC(NVL(l_repeat_start_date, l_output_dates_tbl(1))) -- Fix bug 2376554, bug 2385202
             WHERE recurrence_rule_id = l_recur_id;
        END IF;

        IF not jtf_task_utl.to_boolean (p_template_flag) AND -- Fix bug 2395216
           p_end_date_active IS NULL
        THEN
           l_last := l_output_dates_tbl.LAST; -- Fix bug 2376554

           -- Commented out by SBARAT on 28/07/2005 for bug# 4365923
           /*jtf_task_recurrences_pvt.get_repeat_end_date(
                p_recurrence_rule_id => l_recur_id
               ,x_repeat_end_date    => l_repeat_end_date
           );*/

           -- Modified by SBARAT on 28/07/2005 for bug# 4365923
           UPDATE jtf_task_recur_rules
              SET end_date_active = trunc(l_output_dates_tbl(l_last)) --trunc(NVL(l_repeat_end_date,l_output_dates_tbl(l_last))) -- Fix bug 2376554, bug 2385202
            WHERE recurrence_rule_id = l_recur_id;
        END IF;

        set_last_update_date(l_recur_id);

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            jtf_task_recurrences_pub.creating_recurrences := FALSE;


            ROLLBACK TO create_task_recur_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            jtf_task_recurrences_pub.creating_recurrences := FALSE;
            ROLLBACK TO create_task_recur_pvt;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END;

    -- To fix bug 2721278
    FUNCTION is_repeat_start_date_changed (p_recurrence_rule_id IN NUMBER
                                          ,p_target_repeat_start_date IN DATE)
    RETURN BOOLEAN
    IS
        CURSOR c_recur IS
        SELECT 1
          FROM jtf_task_recur_rules
         WHERE recurrence_rule_id = p_recurrence_rule_id
           AND TRUNC(start_date_active) = TRUNC(p_target_repeat_start_date);

        l_dummy NUMBER;
        l_changed BOOLEAN := TRUE;
    BEGIN
        OPEN c_recur;
        FETCH c_recur INTO l_dummy;
        IF c_recur%FOUND
        THEN
            l_changed := FALSE;
        END IF;
        CLOSE c_recur;

        RETURN l_changed;
    END is_repeat_start_date_changed;

    PROCEDURE update_task_recurrence (
        p_api_version            IN       NUMBER,
        p_init_msg_list          IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                 IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                IN       NUMBER,
        p_recurrence_rule_id     IN       NUMBER,
        p_occurs_which           IN       INTEGER DEFAULT NULL,
        p_day_of_week            IN       INTEGER DEFAULT NULL,
        p_date_of_month          IN       INTEGER DEFAULT NULL,
        p_occurs_month           IN       INTEGER DEFAULT NULL,
        p_occurs_uom             IN       VARCHAR2 DEFAULT NULL,
        p_occurs_every           IN       INTEGER DEFAULT NULL,
        p_occurs_number          IN       INTEGER DEFAULT NULL,
        p_start_date_active      IN       DATE DEFAULT NULL,
        p_end_date_active        IN       DATE DEFAULT NULL,
        p_template_flag          IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_attribute1             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute2             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute3             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute4             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute5             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute6             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute7             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute8             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute9             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute10            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute11            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute12            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute13            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute14            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute15            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute_category     IN       VARCHAR2 DEFAULT NULL ,
        p_sunday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_monday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_tuesday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_wednesday              IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_thursday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_friday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_saturday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        x_new_recurrence_rule_id OUT NOCOPY      NUMBER,
        x_return_status          OUT NOCOPY      VARCHAR2,
        x_msg_count              OUT NOCOPY      NUMBER,
        x_msg_data               OUT NOCOPY      VARCHAR2
    )
    IS
        CURSOR c_task (b_task_id NUMBER) IS
        SELECT MAX(t.calendar_start_date) calendar_start_date
             , COUNT(t.task_id) occurs_number
          FROM jtf_tasks_b t
             , jtf_tasks_b curr_task
         WHERE curr_task.task_id = b_task_id
           AND t.recurrence_rule_id = curr_task.recurrence_rule_id
           AND t.calendar_start_date < curr_task.calendar_start_date;

        rec_task c_task%ROWTYPE;

        CURSOR c_new_start_date (b_task_id NUMBER) IS
        SELECT TRUNC(calendar_start_date) calendar_start_date
          FROM jtf_tasks_b
         WHERE task_id = b_task_id;

        rec_new_start_date  c_new_start_date%ROWTYPE;

        l_new_task_id NUMBER;
        l_first_task  BOOLEAN := FALSE;
        l_delete_future_recurrences VARCHAR2(1);
        l_task_details_rec   jtf_task_recurrences_pub.task_details_rec;
        l_output_dates_counter INTEGER;
        l_object_version_number NUMBER;
        i NUMBER;
        -- To fix bug 2721278
        l_repeat_start_date DATE;
    BEGIN
        SAVEPOINT update_task_recurrence_pvt;

        x_return_status := fnd_api.g_ret_sts_success;

        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        OPEN c_new_start_date (p_task_id);
        FETCH c_new_start_date INTO rec_new_start_date;

        IF c_new_start_date%NOTFOUND
        THEN
            CLOSE c_new_start_date;
            fnd_message.set_name('JTF','JTF_TASK_INVALID_TASK_ID');
            fnd_message.set_token('P_TASK_ID', p_task_id);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        CLOSE c_new_start_date;

        -- To fix bug 2721278
        -- Check if the repeat start date is changed or not.
        -- If it's changed, use the new repeating start date
        -- Otherwise, use the current selected task's calendar start date
        IF is_repeat_start_date_changed (p_recurrence_rule_id       => p_recurrence_rule_id
                                        ,p_target_repeat_start_date => p_start_date_active)
        THEN
            l_repeat_start_date := p_start_date_active;
        ELSE
            l_repeat_start_date := rec_new_start_date.calendar_start_date;
        END IF;
        -----------------------------------------------------------------------------

        ---------------------------------------------
        -- Copy p_task_id to a new one
        -- Store the new task_id into l_new_task_id
        ---------------------------------------------
        jtf_tasks_pub.copy_task (
            p_api_version              => 1.0,
            p_init_msg_list            => fnd_api.g_true,
            p_commit                   => fnd_api.g_false,
            p_source_task_id           => p_task_id,
            p_copy_task_assignments    => fnd_api.g_true,
            p_copy_task_rsc_reqs       => fnd_api.g_true,
            p_copy_task_depends        => fnd_api.g_true,
            p_create_recurrences       => fnd_api.g_false,
            p_copy_task_references     => fnd_api.g_true,
            p_copy_task_dates          => fnd_api.g_true,
            p_copy_task_contacts => fnd_api.g_true,
            p_copy_task_contact_points => fnd_api.g_true,
            x_return_status            => x_return_status,
            x_msg_count                => x_msg_count,
            x_msg_data                 => x_msg_data,
            x_task_id                  => l_new_task_id
        );
        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        ---------------------------------------------
        -- Change the status of all assignees to 18
        --     for the copied
        ---------------------------------------------
        UPDATE jtf_task_all_assignments
           SET assignment_status_id = 18
             , last_update_date = SYSDATE
             , last_updated_by = fnd_global.user_id
         WHERE task_id = l_new_task_id
           AND assignee_role = 'ASSIGNEE';

        --------------------------------------------------
        -- Check if p_task_id equals to the first task id
        --------------------------------------------------
        l_first_task := jta_sync_task_utl.is_this_first_task(p_task_id => p_task_id);

        IF l_first_task
        THEN
            l_delete_future_recurrences := 'A'; -- Delete all the occurrences
        ELSE
            l_delete_future_recurrences := fnd_api.g_true; -- Delete the future occrrences
        END IF;

        --------------------------------------------------
        -- Delete all the appointments
        --  with given option l_delete_future_recurrences
        --------------------------------------------------
        l_object_version_number := jta_sync_task_common.get_ovn(p_task_id => p_task_id);

        jtf_tasks_pvt.delete_task (
            p_api_version               => 1.0,
            p_init_msg_list             => fnd_api.g_false,
            p_commit                    => fnd_api.g_false,
            p_object_version_number     => l_object_version_number,
            p_task_id                   => p_task_id,
            p_delete_future_recurrences => l_delete_future_recurrences,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
        );
        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        ---------------------------------------------------------------------
        -- Update end_date_active and occurs_number for the current
        --    recurrence rule with the calendar_start_date of the task
        --    and the number of tasks right before the current selected task
        ---------------------------------------------------------------------
        IF NOT l_first_task
        THEN
            OPEN c_task (p_task_id);
            FETCH c_task INTO rec_task;
            IF c_task%NOTFOUND
            THEN
                CLOSE c_task;
                fnd_message.set_name('JTF','JTF_TASK_INVALID_TASK_ID');
                fnd_message.set_token('P_TASK_ID', p_task_id);
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            CLOSE c_task;

            UPDATE jtf_task_recur_rules
               SET end_date_active = TRUNC(rec_task.calendar_start_date)
                 , occurs_number = rec_task.occurs_number
             WHERE recurrence_rule_id = p_recurrence_rule_id;
        END IF;

        --------------------------------------------------
        -- Create a new recurrence with l_new_task_id
        --------------------------------------------------
        create_task_recurrence (
            p_api_version             => 1.0,
            p_init_msg_list           => fnd_api.g_false,
            p_commit                  => fnd_api.g_false,
            p_task_id                 => l_new_task_id,
            p_occurs_which            => p_occurs_which,
            p_day_of_week             => p_day_of_week,
            p_date_of_month           => p_date_of_month,
            p_occurs_month            => p_occurs_month,
            p_occurs_uom              => p_occurs_uom,
            p_occurs_every            => p_occurs_every,
            p_occurs_number           => p_occurs_number,
            p_start_date_active       => l_repeat_start_date, -- To fix bug 2721278
            p_end_date_active         => p_end_date_active,
            p_template_flag           => p_template_flag,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data,
            x_recurrence_rule_id      => x_new_recurrence_rule_id,
            x_task_rec                => l_task_details_rec,
            x_output_dates_counter    => l_output_dates_counter,
            p_attribute1              => p_attribute1,
            p_attribute2              => p_attribute2,
            p_attribute3              => p_attribute3,
            p_attribute4              => p_attribute4,
            p_attribute5              => p_attribute5,
            p_attribute6              => p_attribute6,
            p_attribute7              => p_attribute7,
            p_attribute8              => p_attribute8,
            p_attribute9              => p_attribute9,
            p_attribute10             => p_attribute10,
            p_attribute11             => p_attribute11,
            p_attribute12             => p_attribute12,
            p_attribute13             => p_attribute13,
            p_attribute14             => p_attribute14,
            p_attribute15             => p_attribute15,
            p_attribute_category      => p_attribute_category,
            p_sunday                  => p_sunday,
            p_monday                  => p_monday,
            p_tuesday                 => p_tuesday,
            p_wednesday               => p_wednesday,
            p_thursday                => p_thursday,
            p_friday                  => p_friday,
            p_saturday                => p_saturday
        );
        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        ------------------------------------------------------------
        -- Update sync mapping table if this task is the first one
        ------------------------------------------------------------
        IF l_first_task
        THEN
            UPDATE jta_sync_task_mapping
               SET task_id = l_new_task_id
             WHERE task_id = p_task_id;
        END IF;

        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO update_task_recurrence_pvt;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO update_task_recurrence_pvt;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END update_task_recurrence;

END;   --CREATE OR REPLACE PACKAGE

/
