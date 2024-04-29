--------------------------------------------------------
--  DDL for Package Body PA_DURATION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DURATION_UTILS" AS
/*$Header: PADURUTB.pls 120.1 2005/08/19 16:21:43 mwasowic noship $*/

--
--  PROCEDURE   get_duration_old
--
--  PURPOSE
--              This procedure returns total number of hours and days for given
--              start date and end date.
PROCEDURE get_duration_old(p_calendar_id IN  NUMBER,
            p_start_date  IN  DATE,
            p_end_date    IN  DATE,
            x_duration_days  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_duration_hours OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_return_status  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count      OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data       OUT  NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS
  l_sch_record_tab  PA_SCHEDULE_GLOB.ScheduleTabTyp;
  l_date  DATE;
  l_week_day VARCHAR2(10);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_duration_days := 0;
  x_duration_hours :=0;

  PA_SCHEDULE_PVT.get_calendar_schedule(p_calendar_id => p_calendar_id,
      p_start_date     => p_start_date,
      p_end_date       => p_end_date,
      x_sch_record_tab => l_sch_record_tab,
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data);

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    IF l_sch_record_tab.COUNT > 0 THEN
      FOR j IN l_sch_record_tab.FIRST..l_sch_record_tab.LAST LOOP

        l_date := l_sch_record_tab(j).start_date;
        IF l_sch_record_tab(j).start_date IS NOT NULL AND
           l_sch_record_tab(j).end_date IS NOT NULL
        THEN

            LOOP
               l_week_day := TO_CHAR(l_date, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');

               IF l_week_day = 'MON' AND l_sch_record_tab(j).monday_hours > 0 THEN
                  x_duration_days := x_duration_days +1;
                  x_duration_hours := x_duration_hours + l_sch_record_tab(j).monday_hours;

               ELSIF l_week_day = 'TUE' AND l_sch_record_tab(j).tuesday_hours > 0 THEN
                  x_duration_days := x_duration_days +1;
                  x_duration_hours := x_duration_hours + l_sch_record_tab(j).tuesday_hours;

               ELSIF l_week_day = 'WED' AND l_sch_record_tab(j).wednesday_hours > 0 THEN
                  x_duration_days := x_duration_days +1;
                  x_duration_hours := x_duration_hours + l_sch_record_tab(j).wednesday_hours;

               ELSIF l_week_day = 'THU' AND l_sch_record_tab(j).thursday_hours > 0 THEN
                  x_duration_days := x_duration_days +1;
                  x_duration_hours := x_duration_hours + l_sch_record_tab(j).thursday_hours;

               ELSIF l_week_day = 'FRI' AND l_sch_record_tab(j).friday_hours > 0 THEN
                  x_duration_days := x_duration_days +1;
                  x_duration_hours := x_duration_hours + l_sch_record_tab(j).friday_hours;

               ELSIF l_week_day = 'SAT' AND l_sch_record_tab(j).saturday_hours > 0 THEN
                  x_duration_days := x_duration_days +1;
                  x_duration_hours := x_duration_hours + l_sch_record_tab(j).saturday_hours;

               ELSIF l_week_day = 'SUN' AND l_sch_record_tab(j).sunday_hours > 0 THEN
                  x_duration_days := x_duration_days +1;
                  x_duration_hours := x_duration_hours + l_sch_record_tab(j).sunday_hours;

               END IF;

               l_date := l_date + 1;

               EXIT WHEN trunc(l_date) > trunc(l_sch_record_tab(j).end_date);
            END LOOP;
        END IF;
      END LOOP;
    END IF;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg
         (p_pkg_name => 'PA_DURATION_UTILS.get_duration_old',
          p_procedure_name => PA_DEBUG.G_Err_Stack );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;
END get_duration_old;

FUNCTION get_total_hours(p_calendar_id IN NUMBER,
                         p_start_date IN DATE,
                         p_end_date IN DATE) return NUMBER
IS
  l_hours NUMBER;
  l_days  NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(256);
BEGIN
  get_duration(p_calendar_id,
               p_start_date,
               p_end_date,
               l_days,
               l_hours,
               l_return_status,
               l_msg_count,
               l_msg_data);
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    return 0;
  ELSE
    return l_hours;
  END IF;
EXCEPTION
  WHEN OTHERS then
    return 0;
END get_total_hours;


--          07-Mar-2003    Amksingh Bug 2838700 A new procedure get_duration
--                                  is added and the previous get_duration is
--                                  renamed to get_duration_old.

PROCEDURE get_duration(p_calendar_id IN  NUMBER,
            p_start_date  IN  DATE,
            p_end_date    IN  DATE,
            x_duration_days  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_duration_hours OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_return_status  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count      OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data       OUT  NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS
  l_sch_record_tab  PA_SCHEDULE_GLOB.ScheduleTabTyp;
  l_date  DATE;
  l_week_day VARCHAR2(10);
  l_duration_days NUMBER := 0;
  l_duration_hours NUMBER :=0;


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_duration_days := 0;
  x_duration_hours :=0;

  IF (g_calendar_id IS NULL OR g_calendar_id <> p_calendar_id) THEN

	  PA_SCHEDULE_PVT.get_calendar_schedule(p_calendar_id => p_calendar_id,
	      p_start_date     => p_start_date,
	      p_end_date       => p_end_date,
	      x_sch_record_tab => l_sch_record_tab,
	      x_return_status  => x_return_status,
	      x_msg_count      => x_msg_count,
	      x_msg_data       => x_msg_data);

	  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	    IF l_sch_record_tab.COUNT > 0 THEN
	      FOR j IN l_sch_record_tab.FIRST..l_sch_record_tab.LAST LOOP

		l_date := l_sch_record_tab(j).start_date;
	        IF l_sch_record_tab(j).start_date IS NOT NULL AND
	           l_sch_record_tab(j).end_date IS NOT NULL
	        THEN

		    LOOP
	               l_week_day := TO_CHAR(l_date, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');

		       IF l_week_day = 'MON' AND l_sch_record_tab(j).monday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).monday_hours;

		       ELSIF l_week_day = 'TUE' AND l_sch_record_tab(j).tuesday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).tuesday_hours;

		       ELSIF l_week_day = 'WED' AND l_sch_record_tab(j).wednesday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).wednesday_hours;

		       ELSIF l_week_day = 'THU' AND l_sch_record_tab(j).thursday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).thursday_hours;

		       ELSIF l_week_day = 'FRI' AND l_sch_record_tab(j).friday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).friday_hours;

		       ELSIF l_week_day = 'SAT' AND l_sch_record_tab(j).saturday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).saturday_hours;

		       ELSIF l_week_day = 'SUN' AND l_sch_record_tab(j).sunday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).sunday_hours;

		       END IF;

	               l_date := l_date + 1;

		       EXIT WHEN trunc(l_date) > trunc(l_sch_record_tab(j).end_date);
	            END LOOP;
	        END IF;
	      END LOOP;
	    END IF;
	  END IF;
   x_duration_days := l_duration_days;
   x_duration_hours := l_duration_hours;
   g_duration_days := l_duration_days;
   g_duration_hours := l_duration_hours;
   g_calendar_id := p_calendar_id;
   g_start_date := p_start_date;
   g_end_date := p_end_date;
   g_sch_record_tab := l_sch_record_tab;
 ELSE
	IF (p_start_date = g_start_date AND p_end_date = g_end_date) THEN
	   x_duration_days := g_duration_days;
	   x_duration_hours := g_duration_hours;
	ELSIF ( p_start_date >= g_start_date AND p_end_date <= g_end_date) THEN
 	   l_sch_record_tab := g_sch_record_tab;

           --hsiu added; bug 2846044
           l_date := p_start_date;

	    IF l_sch_record_tab.COUNT > 0 THEN
	      FOR j IN l_sch_record_tab.FIRST..l_sch_record_tab.LAST LOOP

--commented for bug 2846044
--		l_date := l_sch_record_tab(j).start_date;

	        IF l_sch_record_tab(j).start_date IS NOT NULL AND
	           l_sch_record_tab(j).end_date IS NOT NULL
	        THEN

		    LOOP
		       EXIT WHEN (trunc(l_date) > trunc(l_sch_record_tab(j).end_date) OR
                                  trunc(l_date) > trunc(p_end_date));

	               l_week_day := TO_CHAR(l_date, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');

		       IF l_week_day = 'MON' AND l_sch_record_tab(j).monday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).monday_hours;

		       ELSIF l_week_day = 'TUE' AND l_sch_record_tab(j).tuesday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).tuesday_hours;

		       ELSIF l_week_day = 'WED' AND l_sch_record_tab(j).wednesday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).wednesday_hours;

		       ELSIF l_week_day = 'THU' AND l_sch_record_tab(j).thursday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).thursday_hours;

		       ELSIF l_week_day = 'FRI' AND l_sch_record_tab(j).friday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).friday_hours;

		       ELSIF l_week_day = 'SAT' AND l_sch_record_tab(j).saturday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).saturday_hours;

		       ELSIF l_week_day = 'SUN' AND l_sch_record_tab(j).sunday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).sunday_hours;

		       END IF;

	               l_date := l_date + 1;

--commmented for duration bug
--		       EXIT WHEN trunc(l_date) > trunc(l_sch_record_tab(j).end_date);
	            END LOOP;
	        END IF;
--hsiu added when > end_date
		EXIT WHEN trunc(l_date) > trunc(p_end_date);
	      END LOOP;
	    END IF;
	   x_duration_days := l_duration_days;
	   x_duration_hours := l_duration_hours;
	ELSE
	  PA_SCHEDULE_PVT.get_calendar_schedule(p_calendar_id => p_calendar_id,
	      p_start_date     => p_start_date,
	      p_end_date       => p_end_date,
	      x_sch_record_tab => l_sch_record_tab,
	      x_return_status  => x_return_status,
	      x_msg_count      => x_msg_count,
	      x_msg_data       => x_msg_data);

	  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	    IF l_sch_record_tab.COUNT > 0 THEN
	      FOR j IN l_sch_record_tab.FIRST..l_sch_record_tab.LAST LOOP

		l_date := l_sch_record_tab(j).start_date;
	        IF l_sch_record_tab(j).start_date IS NOT NULL AND
	           l_sch_record_tab(j).end_date IS NOT NULL
	        THEN

		    LOOP
	               l_week_day := TO_CHAR(l_date, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');

		       IF l_week_day = 'MON' AND l_sch_record_tab(j).monday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).monday_hours;

		       ELSIF l_week_day = 'TUE' AND l_sch_record_tab(j).tuesday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).tuesday_hours;

		       ELSIF l_week_day = 'WED' AND l_sch_record_tab(j).wednesday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).wednesday_hours;

		       ELSIF l_week_day = 'THU' AND l_sch_record_tab(j).thursday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).thursday_hours;

		       ELSIF l_week_day = 'FRI' AND l_sch_record_tab(j).friday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).friday_hours;

		       ELSIF l_week_day = 'SAT' AND l_sch_record_tab(j).saturday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).saturday_hours;

		       ELSIF l_week_day = 'SUN' AND l_sch_record_tab(j).sunday_hours > 0 THEN
	                  l_duration_days := l_duration_days +1;
	                  l_duration_hours := l_duration_hours + l_sch_record_tab(j).sunday_hours;

		       END IF;

	               l_date := l_date + 1;

		       EXIT WHEN trunc(l_date) > trunc(l_sch_record_tab(j).end_date);
	            END LOOP;
	        END IF;
	      END LOOP;
	    END IF;
	  END IF;
	   x_duration_days := l_duration_days;
	   x_duration_hours := l_duration_hours;
	   g_duration_days := l_duration_days;
	   g_duration_hours := l_duration_hours;
	   g_calendar_id := p_calendar_id;
	   g_start_date := p_start_date;
	   g_end_date := p_end_date;
	   g_sch_record_tab := l_sch_record_tab;
	END IF;

 END IF; -- g_calendar_id IS NULL THEN

EXCEPTION
    WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg
         (p_pkg_name => 'PA_DURATION_UTILS.get_duration',
          p_procedure_name => PA_DEBUG.G_Err_Stack );
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;
END get_duration;


END PA_DURATION_UTILS;

/
