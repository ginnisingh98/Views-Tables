--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_UTIL" AS
/* $Header: IEUVUTLB.pls 120.0 2005/06/02 15:59:05 appldev noship $ */

PROCEDURE ADD_DATES
 (l_start_date in DATE,
  l_time_value IN NUMBER,
  l_time_uom IN VARCHAR2,
  l_final_date OUT NOCOPY DATE) IS


l_curr_date VARCHAR2(25);
l_curr_time VARCHAR2(25);
l_curr_hh   NUMBER := 0;
l_curr_mi   NUMBER := 0;
l_curr_ss   NUMBER := 0;
l_hh        NUMBER := 0;
l_mi        NUMBER := 0;
l_ss        NUMBER := 0;

BEGIN

        SELECT to_char(l_start_date, 'hh24:mi:ss')
        INTO   l_curr_time
        FROM   dual;
        l_curr_ss := substr(l_curr_time, instr(l_curr_time, ':', 1, 2) + 1,
                             length(l_curr_time)- instr(l_curr_time, ':', 1, 2) );
        l_curr_mi := substr(l_curr_time, instr(l_curr_time, ':', 1, 1) + 1,
                           (instr(l_curr_time, ':', 1, 2) - instr(l_curr_time, ':', 1, 1) - 1 ) );
        l_curr_hh := substr(l_curr_time, instr(l_curr_time, ' ', 1, 1) + 1,
                           (instr(l_curr_time, ':', 1, 1) - instr(l_curr_time, ' ', 1, 1) - 1) );

    IF (l_time_uom = 'HH')
    THEN

        l_ss := l_curr_ss;
        l_mi := l_curr_mi;
        l_hh := l_curr_hh + l_time_value;
        IF (l_hh > 24)
        THEN
           l_curr_date := to_char((l_start_date + floor(l_hh/24)), 'dd-mon-yyyy');
           l_hh := l_hh - (floor(l_hh/24)*24);
        ELSE
           l_curr_date := to_char(l_start_date, 'dd-mon-yyyy');
        END IF;

        l_curr_date := l_curr_date || ' '||l_hh||':'||l_mi||':'||l_ss;
 --       l_final_date := to_date(l_curr_date, 'dd-mon-yyyy hh24:mi:ss');
        l_final_date := FND_DATE.STRING_TO_DATE(l_curr_date, 'dd-mon-yyyy hh24:mi:ss');

     ELSIF ( l_time_uom = 'MI')
     THEN
        l_ss := l_curr_ss;
        l_mi := l_curr_mi + l_time_value;
        IF (l_mi > 60)
        THEN
          l_hh := l_curr_hh + floor(l_mi/60);
          l_mi := l_mi - (floor(l_mi/60)*60);
        ELSE
          l_hh := l_curr_hh;
        END IF;

        IF (l_hh > 24)
        THEN
           l_curr_date := to_char((l_start_date + floor(l_hh/24)), 'dd-mon-yyyy');
           l_hh := l_hh - (floor(l_hh/24)*24);
        ELSE
           l_curr_date := to_char(l_start_date, 'dd-mon-yyyy');
        END IF;

        l_curr_date := l_curr_date || ' '||l_hh||':'||l_mi||':'||l_ss;
 --       l_final_date := to_date(l_curr_date, 'dd-mon-yyyy hh24:mi:ss');
        l_final_date := FND_DATE.STRING_TO_DATE(l_curr_date, 'dd-mon-yyyy hh24:mi:ss');

     ELSIF ( l_time_uom = 'SS')
     THEN

        l_ss := l_curr_ss + l_time_value;
        IF (l_ss > 60)
        THEN
          l_mi := l_curr_mi + floor(l_ss/60);
          l_ss := l_ss - (floor(l_ss/60)*60);
        ELSE
          l_mi := l_curr_mi;
        END IF;
        IF (l_mi > 60)
        THEN
          l_hh := l_curr_hh + floor(l_mi/60);
          l_mi := l_mi - (floor(l_mi/60)*60);
        ELSE
          l_hh := l_curr_hh;
        END IF;

        IF (l_hh > 24)
        THEN
           l_curr_date := to_char((l_start_date + floor(l_curr_date/24)), 'dd-mon-yyyy');
           l_hh := l_hh - (floor(l_curr_date/24)*24);
        ELSE
           l_curr_date := to_char(l_start_date,'dd-mon-yyyy');
        END IF;

        l_curr_date := l_curr_date || ' '||l_hh||':'||l_mi||':'||l_ss;
 --       l_final_date := to_date(l_curr_date, 'dd-mon-yyyy hh24:mi:ss');
        l_final_date := FND_DATE.STRING_TO_DATE(l_curr_date, 'dd-mon-yyyy hh24:mi:ss');

     ELSIF ( l_time_uom = 'DAYS' )
     THEN
       l_final_date := l_start_date + l_time_value;

     ELSIF ( l_time_uom = 'WEEKS')
     THEN
       l_final_date := l_start_date + (l_time_value * 7);

     ELSIF ( l_time_uom = 'MONTHS' )
     THEN
       l_final_date := ADD_MONTHS(l_start_date, l_time_value);

     END IF;

 END ADD_DATES;

END IEU_UWQ_UTIL;


/
