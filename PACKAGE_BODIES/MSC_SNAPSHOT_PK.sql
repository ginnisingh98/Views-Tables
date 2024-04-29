--------------------------------------------------------
--  DDL for Package Body MSC_SNAPSHOT_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SNAPSHOT_PK" AS
/* $Header: MSCPSNPB.pls 120.11.12010000.3 2009/09/01 09:35:15 alsriniv ship $ */

MAKE_ITEM CONSTANT INTEGER:= 1;
mrdebug CONSTANT BOOLEAN := true;
NULL_VALUE CONSTANT NUMBER := -23453;

PROCEDURE LOG_MESSAGE( pBUFF                     IN  VARCHAR2)
IS
BEGIN

  IF fnd_global.conc_request_id > 0 THEN   -- concurrent program

      FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
       --dbms_output.put_line( pBUFF);

  ELSE

       --dbms_output.put_line( pBUFF);
    null;

  END IF;

END LOG_MESSAGE;


PROCEDURE insert_into_table(
			    p_plan_id                   NUMBER,
			    p_sr_instance_id            NUMBER,
			    p_org_id                    NUMBER,
			    p_bucket_index              NUMBER,
			    p_msc_plan_buckets          IN OUT NOCOPY msc_plan_buckets_typ,
			    p_err_mesg                  OUT NOCOPY VARCHAR2
			    );

-- ********************** complete_task *************************
PROCEDURE   complete_task(
			  arg_plan_id		    IN NUMBER,
			  arg_task            IN  NUMBER) IS
BEGIN

   UPDATE  msc_snapshot_tasks
     SET     completion_date = SYSDATE,
     program_update_date = SYSDATE
     WHERE   task = arg_task
     AND     plan_id = arg_plan_id;

   COMMIT;

END complete_task;

PROCEDURE get_bucket_cutoff_dates(
				  p_plan_id              IN    NUMBER,
				  p_org_id               IN    NUMBER,
				  p_instance_id          IN    NUMBER,
				  p_plan_start_date      IN    DATE,
				  p_plan_completion_date IN    DATE,
				  -- used by form
				  p_min_cutoff_bucket    IN    number,
				  p_hour_cutoff_bucket   IN    number,
				  p_daily_cutoff_bucket  IN    number,
				  p_weekly_cutoff_bucket IN    number,
				  p_period_cutoff_bucket IN    number,
				  -- used by form
				  p_min_cutoff_date      OUT NOCOPY  DATE,
				  p_hour_cutoff_date     OUT NOCOPY  DATE,
				  p_daily_cutoff_date    OUT NOCOPY  DATE,
				  p_weekly_cutoff_date   OUT NOCOPY  DATE,
				  p_period_cutoff_date   OUT NOCOPY  DATE,
				  p_err_mesg             OUT NOCOPY  VARCHAR2
				  ) IS

 l_min_cutoff_bucket       NUMBER;
 l_hour_cutoff_bucket      NUMBER;
 l_daily_cutoff_bucket     NUMBER;
 l_weekly_cutoff_bucket    NUMBER;
 l_period_cutoff_bucket    NUMBER;

 l_bucket_end_date         DATE;
 l_bucket_start_date       DATE;
 l_from_forms             varchar2(1) := 'N';
BEGIN

   p_min_cutoff_date := NULL;
   p_hour_cutoff_date := NULL;
   p_daily_cutoff_date := NULL;
   p_weekly_cutoff_date := NULL;
   p_period_cutoff_date := NULL;

   IF p_min_cutoff_bucket IS NULL AND p_hour_cutoff_bucket IS NULL AND
     p_daily_cutoff_bucket IS NULL AND p_weekly_cutoff_bucket IS NULL AND
     p_period_cutoff_bucket IS NULL THEN
      -- Not called from form.
      SELECT
	Nvl(min_cutoff_bucket,0),
	Nvl(hour_cutoff_bucket,0),
	Nvl(daily_cutoff_bucket,0),
--	   +Nvl(min_cutoff_bucket,0)   bug 1226108
--	   +Nvl(hour_cutoff_bucket,0), bug 1226108
	Nvl(weekly_cutoff_bucket,0)*7,
	Nvl(period_cutoff_bucket,0)
	INTO l_min_cutoff_bucket, l_hour_cutoff_bucket,
	l_daily_cutoff_bucket, l_weekly_cutoff_bucket, l_period_cutoff_bucket
	FROM msc_plans
	WHERE plan_id = p_plan_id;
    ELSE
      l_min_cutoff_bucket := p_min_cutoff_bucket;
      l_hour_cutoff_bucket := p_hour_cutoff_bucket;
      l_daily_cutoff_bucket := p_daily_cutoff_bucket;
      -- +p_min_cutoff_bucket+p_hour_cutoff_bucket;   bug 1226108
      --modification to set the number of days in weekly buckets to 7 times
      --the number of weeks
      l_weekly_cutoff_bucket := p_weekly_cutoff_bucket*7;
      l_period_cutoff_bucket := p_period_cutoff_bucket;
      l_from_forms := 'Y';
   END IF;

   -- the plan cutoff date changes to be the period_cutoff_date

   IF mrdebug = TRUE THEN
      null;
      /*LOG_MESSAGE('Cutoff buckets : '
			   ||' min '||l_min_cutoff_bucket
		           ||' hour '||l_hour_cutoff_bucket
			   ||' daily '||l_daily_cutoff_bucket
			   ||' weekly '||l_weekly_cutoff_bucket
			   ||' period '||l_period_cutoff_bucket);
			   */
   END IF;

   IF l_min_cutoff_bucket <> 0 THEN
      p_min_cutoff_date := Trunc(Sysdate) + (l_min_cutoff_bucket-1);
    ELSE
      p_min_cutoff_date := Trunc(Sysdate);
   END IF;

   IF l_hour_cutoff_bucket <> 0 THEN
      IF l_min_cutoff_bucket <> 0 THEN
	 p_hour_cutoff_date :=  p_min_cutoff_date + l_hour_cutoff_bucket;
       ELSE
	 -- If it is 0 then we can include plan_start_date for the hour bucket.
	 p_hour_cutoff_date :=  p_min_cutoff_date + (l_hour_cutoff_bucket-1);
      END IF;
    ELSE
      p_hour_cutoff_date := p_min_cutoff_date;
   END IF;

   -- Already summed up min+hour+daily. So just start from sysdate.
   if l_from_forms = 'Y' then
     IF l_daily_cutoff_bucket <> 0 THEN
       l_bucket_end_date :=  p_plan_start_date + (l_daily_cutoff_bucket-1);
     ELSE
       l_bucket_end_date :=  p_plan_start_date - 1;
     END IF;
   else
     IF l_daily_cutoff_bucket <> 0 THEN
        l_bucket_end_date := Trunc(p_plan_start_date) + (l_daily_cutoff_bucket-1);
     ELSE
        l_bucket_end_date := Trunc(p_plan_start_date) - 1;
     END IF;
   end if;



      IF l_weekly_cutoff_bucket <> 0 THEN
	 p_daily_cutoff_date :=
	   msc_calendar.next_work_day(-1*p_org_id,
				      p_instance_id,
				      msc_calendar.type_weekly_bucket,
				      l_bucket_end_date + 1
				      );

	 p_daily_cutoff_date := p_daily_cutoff_date -1;


	 -- The above call gives the week start date after l_bucket_end_date
	 IF mrdebug = TRUE THEN
            null;
	    --LOG_MESSAGE('p_daily_cutoff_date #1 = '||p_daily_cutoff_date||' org '||p_org_id||' inst '||p_instance_id||' l_bucket_end_date '||l_bucket_end_date);
	 END IF;
       ELSIF l_period_cutoff_bucket <> 0 THEN
	 p_daily_cutoff_date :=
	   msc_calendar.next_work_day(-1*p_org_id,
				      p_instance_id,
				      msc_calendar.type_monthly_bucket,
				      l_bucket_end_date + 1
				      );
	 p_daily_cutoff_date := p_daily_cutoff_date -1;
	 -- The above call gives the period start date after l_bucket_end_date
	 IF mrdebug = TRUE THEN
             null;
           --LOG_MESSAGE('p_daily_cutoff_date #2 = '||p_daily_cutoff_date||' org '||p_org_id||' inst '||p_instance_id||' l_bucket_end_date '||l_bucket_end_date);
	 END IF;
       ELSE
	 IF l_daily_cutoff_bucket <> 0 THEN
	 	p_daily_cutoff_date := l_bucket_end_date;
	 ELSE
		l_bucket_end_date := l_bucket_end_date + 1;
		p_daily_cutoff_date := l_bucket_end_date;
	 END IF;
      END IF;  -- IF l_weekly_cutoff_bucket <> 0 THEN
   -- END IF; -- IF l_daily_cutoff_bucket <> 0 THEN  .... moved up


   IF l_weekly_cutoff_bucket <> 0 THEN

      -- IF l_daily_cutoff_bucket = 0 THEN
      IF p_daily_cutoff_date = Trunc(p_plan_start_date) THEN
	 -- There is no daily bucket
	 l_bucket_start_date := Trunc(p_plan_start_date);
       ELSE
	 -- Get next week start date after daily period ends
	 l_bucket_start_date := p_daily_cutoff_date + 1;
      END IF;

      l_bucket_end_date := l_bucket_start_date + (l_weekly_cutoff_bucket-1);

      IF l_period_cutoff_bucket <> 0 THEN
	 -- This needs to be changed to be TYPE_PERIOD_BUCKET instead of months
	 p_weekly_cutoff_date :=
	   msc_calendar.next_work_day(-1*p_org_id,
				      p_instance_id,
				      msc_calendar.type_monthly_bucket,
				      l_bucket_end_date + 1
				      );

	 p_weekly_cutoff_date := p_weekly_cutoff_date -1;
	 IF mrdebug = TRUE THEN
  	    null;
	    --LOG_MESSAGE('p_weekly_cutoff_date #1 = '||p_weekly_cutoff_date||' org '||p_org_id||' inst '||p_instance_id||' l_bucket_end_date '||l_bucket_end_date);
	 END IF;
       ELSE
	 p_weekly_cutoff_date := l_bucket_end_date;
      END IF; -- IF l_period_cutoff_bucket <> 0 THEN


   END IF;  -- IF l_weekly_cutoff_bucket <> 0 THEN

   IF l_period_cutoff_bucket <> 0 THEN
      IF p_weekly_cutoff_date IS NOT NULL THEN
	 l_bucket_end_date := p_weekly_cutoff_date + 1;
       ELSIF p_daily_cutoff_date IS NOT NULL THEN
	 l_bucket_end_date := p_daily_cutoff_date + 1;
       ELSE
	 l_bucket_end_date := Trunc(p_plan_start_date);  -- They are planning only in periods
      END IF;

      FOR j IN 1..l_period_cutoff_bucket loop
	 p_period_cutoff_date :=
	   msc_calendar.next_work_day(-1*p_org_id,
				      p_instance_id,
				      msc_calendar.type_monthly_bucket,
				      l_bucket_end_date + 1
				      );
	 l_bucket_end_date := p_period_cutoff_date;
	 IF mrdebug = TRUE THEN
	    null;
	    --LOG_MESSAGE('p_period_cutoff_date  = '||p_period_cutoff_date);
	 END IF;
      END LOOP;
      p_period_cutoff_date := p_period_cutoff_date -1;


   END IF;

END get_bucket_cutoff_dates;

PROCEDURE calculate_plan_buckets(
				 p_plan_id                IN    NUMBER,
				 p_err_mesg               OUT NOCOPY  VARCHAR2,
				 p_min_cutoff_date        OUT NOCOPY  number,
				 p_hour_cutoff_date       OUT NOCOPY  number,
				 p_daily_cutoff_date      OUT NOCOPY  number,
				 p_weekly_cutoff_date     OUT NOCOPY  number,
				 p_period_cutoff_date     OUT NOCOPY  number,
				 p_min_cutoff_bucket      OUT NOCOPY  number,
				 p_hour_cutoff_bucket     OUT NOCOPY  number,
				 p_daily_cutoff_bucket    OUT NOCOPY  number,
				 p_weekly_cutoff_bucket   OUT NOCOPY  number,
				 p_period_cutoff_bucket   OUT NOCOPY  number
				 )
  IS

     CURSOR plan_orgs_cur IS
 	SELECT /*+ NOREWRITE */
	  mpl.organization_id,
	  mpl.sr_instance_id,
	  TRUNC(sysdate),
	  mpl.cutoff_date
	  FROM
	  msc_trading_partners mtp,
	  msc_plans mpl
	  WHERE
	  mpl.plan_id = p_plan_id
	  and mpl.organization_id = mtp.sr_tp_id
	  and mtp.partner_type = 3
	  and mpl.sr_instance_id = mtp.sr_instance_id;

     l_calendar_code          Varchar2(14);

     l_min_cutoff_date        DATE;
     l_hour_cutoff_date       DATE;
     l_daily_cutoff_date      DATE;
     l_weekly_cutoff_date     DATE;
     l_period_cutoff_date     DATE;

     l_bkt_start_date         DATE;
     l_bkt_index              Number :=0;

     l_plan_start_date        DATE;
     l_plan_comp_date         DATE;
     l_plan_cutoff_date       DATE;
     l_org_id                 Number;
     l_sr_instance_id         Number;

     l_msc_plan_buckets       msc_plan_buckets_typ;

     m_calendar_code          VARCHAR2(14);
     m_cal_exception_set_id   Number;
     m_sr_instance_id         Number;

     l_curr_start_date        DATE;
     l_weekly_buckets         Number;

     j NUMBER;

     lv_bkt_ref_calendar      varchar2(14) := fnd_profile.value('MSC_BKT_REFERENCE_CALENDAR');
     lv_bkt_ref_instance      number;
BEGIN

 --  IF mrdebug = TRUE THEN
  --    dbms_output.enable(1000000);
  -- END IF;

   DELETE FROM msc_plan_buckets
     WHERE plan_id = p_plan_id;

   OPEN plan_orgs_cur;
   FETCH plan_orgs_cur
     INTO
     l_org_id, l_sr_instance_id, l_plan_start_date, l_plan_comp_date;
   CLOSE plan_orgs_cur;

    SELECT decode(plan_type, 4, trunc(curr_start_date), 9,
                    trunc(curr_start_date), trunc(sysdate)),
           weekly_cutoff_bucket
    into l_curr_start_date, l_weekly_buckets
    FROM  msc_plans
    WHERE plan_id = p_plan_id;


    IF  l_curr_start_date < l_plan_start_date THEN
        IF l_weekly_buckets > 0 THEN
	  IF (lv_bkt_ref_calendar is null) then
             select min(cal.week_start_date)
             into   l_curr_start_date
             from msc_cal_week_start_dates cal,
                  msc_trading_partners tp,
                  msc_calendar_dates mc
             where cal.exception_set_id = tp.calendar_exception_set_id
             and   mc.exception_set_id  = tp.calendar_exception_set_id
             and   cal.calendar_code    = tp.calendar_code
             and   mc.calendar_code     = tp.calendar_code
             and   cal.sr_instance_id   = tp.sr_instance_id
             and   mc.sr_instance_id    = tp.sr_instance_id
             and   cal.week_start_date >= mc.next_date
             and   mc.calendar_date     = trunc(sysdate)
             and   tp.sr_tp_id          = l_org_id
             and   tp.sr_instance_id    = l_sr_instance_id
             and   tp.partner_type      = 3 ;
	   ELSE
	     select min(cal.week_start_date)
	     into   l_curr_start_date
	     from msc_cal_week_start_dates cal,
	          msc_calendar_dates mc
		  where cal.exception_set_id = mc.exception_set_id
		  and cal.calendar_code = mc.calendar_code
		  and cal.sr_instance_id = mc.sr_instance_id
		  and cal.week_start_date >= mc.next_date
		  and mc.calendar_date     = trunc(sysdate)
		  and mc.calendar_code = lv_bkt_ref_calendar;
	   END IF;
        ELSE
	  IF (lv_bkt_ref_calendar is null) then
              select min(cal.period_start_date)
              into l_curr_start_date
              from msc_period_start_dates cal,
                   msc_trading_partners tp
              where cal.exception_set_id   = tp.calendar_exception_set_id
              and   cal.calendar_code      = tp.calendar_code
              and   cal.period_start_date >= trunc(sysdate)
              and   cal.sr_instance_id     = tp.sr_instance_id
              and   tp.sr_tp_id            = l_org_id
              and   tp.sr_instance_id      = l_sr_instance_id
              and   tp.partner_type        = 3;
	   ELSE
	      select min(cal.period_start_date)
	      into l_curr_start_date
	      from msc_period_start_dates cal
	      where cal.period_start_date >= trunc(sysdate)
	      and cal.calendar_code = lv_bkt_ref_calendar;
	   END IF;

        END IF;
    END IF;


    l_plan_start_date := l_curr_start_date;

    lv_bkt_ref_instance := l_sr_instance_id;

    IF (lv_bkt_ref_calendar is not null) then
        select sr_instance_id
	  into lv_bkt_ref_instance
	  from msc_calendar_dates
	  where calendar_code = lv_bkt_ref_calendar
	  and calendar_date = trunc(sysdate)
          and exception_set_id = -1;

    END IF;
/*
   IF mrdebug = TRUE THEN
      LOG_MESSAGE('owning_org = '||l_org_id||' instance '||l_sr_instance_id||' start '||l_plan_start_date||' comp '||l_plan_comp_date);
   END IF;
 */
   get_bucket_cutoff_dates(
			   p_plan_id               => p_plan_id,
			   p_org_id                => l_org_id,
			   p_instance_id           => lv_bkt_ref_instance,
			   p_plan_start_date       => l_plan_start_date,
			   p_plan_completion_date  => l_plan_comp_date,
			   p_min_cutoff_bucket     => NULL,
			   p_hour_cutoff_bucket    => NULL,
			   p_daily_cutoff_bucket   => NULL,
			   p_weekly_cutoff_bucket  => NULL,
			   p_period_cutoff_bucket  => NULL,
			   p_min_cutoff_date       => l_min_cutoff_date,
			   p_hour_cutoff_date      => l_hour_cutoff_date,
			   p_daily_cutoff_date     => l_daily_cutoff_date,
			   p_weekly_cutoff_date    => l_weekly_cutoff_date,
			   p_period_cutoff_date    => l_period_cutoff_date,
			   p_err_mesg              => p_err_mesg
			   );

   p_min_cutoff_date := To_char(l_min_cutoff_date,'J');
   p_hour_cutoff_date := To_char(l_hour_cutoff_date,'J');
   p_daily_cutoff_date := To_char(l_daily_cutoff_date,'J');
   p_weekly_cutoff_date := To_char(Nvl(l_weekly_cutoff_date,l_daily_cutoff_date),'J');
   p_period_cutoff_date := To_char(Nvl(l_period_cutoff_date,Nvl(l_weekly_cutoff_date,l_daily_cutoff_date)),'J');

   l_plan_cutoff_date := to_date(p_period_cutoff_date,'J');

   IF p_err_mesg IS NOT NULL THEN
      RETURN;
   END IF;

   --   l_weekly_cutoff_date := NULL;
   --   l_period_cutoff_date := NULL;
  /*
   IF mrdebug = TRUE THEN
      LOG_MESSAGE(' min = '||l_min_cutoff_date);
      LOG_MESSAGE(' hour = '||l_hour_cutoff_date);
      LOG_MESSAGE(' daily = '||l_daily_cutoff_date);
      LOG_MESSAGE(' weekly = '||l_weekly_cutoff_date);
      LOG_MESSAGE(' period = '||l_period_cutoff_date);
   END IF;
*/
   -- Set the cutoff_date of the plan based period, week, day buckets set
   UPDATE msc_plans
   SET curr_cutoff_date = l_plan_cutoff_date,
       curr_start_date = l_curr_start_date
   WHERE plan_id = p_plan_id;


   SELECT Nvl(min_cutoff_bucket,0), Nvl(hour_cutoff_bucket,0)+Nvl(min_cutoff_bucket,0)
     INTO p_min_cutoff_bucket, p_hour_cutoff_bucket
     FROM msc_plans
     WHERE plan_id = p_plan_id;

   -- select bucket reference calendar
   select nvl(fnd_profile.value('MSC_BKT_REFERENCE_CALENDAR'), tp.calendar_code),
          tp.calendar_exception_set_id ,
        decode(fnd_profile.value('MSC_BKT_REFERENCE_CALENDAR'), NULL, tp.sr_instance_id, mcd.sr_instance_id)
   into m_calendar_code , m_cal_exception_set_id , m_sr_instance_id
   from msc_plans mp,
        msc_trading_partners tp,
        msc_calendar_dates mcd
   where mp.plan_id = p_plan_id
   and tp.partner_type = 3
   and tp.sr_instance_id  = mp.sr_instance_id
   and mp.organization_id = tp.sr_tp_id
   and mcd.exception_set_id = tp.calendar_exception_set_id
   and mcd.calendar_date = trunc(sysdate)
   and mcd.calendar_code = nvl(fnd_profile.value('MSC_BKT_REFERENCE_CALENDAR'), tp.calendar_code);


   IF l_daily_cutoff_date IS NOT NULL THEN
      -- insert the daily time buckets
      SELECT
	rownum
	,To_char(cal.calendar_date, 'YYYY/MM/DD')
	,To_char(cal.calendar_date,'YYYY/MM/DD')
	,1 bucket_type
	,1 days_in_bucket
	BULK COLLECT INTO
	l_msc_plan_buckets.bucket_index,
	l_msc_plan_buckets.bkt_start_date,
	l_msc_plan_buckets.bkt_end_date,
	l_msc_plan_buckets.bucket_type,
	l_msc_plan_buckets.days_in_bkt
	FROM
	MSC_CALENDAR_DATES cal
	WHERE
            cal.sr_instance_id = m_sr_instance_id
	AND cal.calendar_code = m_calendar_code
	AND cal.exception_set_id  = m_cal_exception_set_id
	and trunc(cal.calendar_date) <= trunc(l_daily_cutoff_date )
	and trunc(cal.calendar_date) >= l_curr_start_date
	ORDER BY cal.calendar_date;


	insert_into_table(
			  p_plan_id,
			  l_sr_instance_id,
			  l_org_id,
			  l_bkt_index,
			  l_msc_plan_buckets,
			  p_err_mesg);

	IF p_err_mesg IS NOT NULL THEN
	  /* IF mrdebug = TRUE THEN
	      LOG_MESSAGE(' 101 ');
	   END IF;		   */
	   RETURN;
	END IF;

	p_daily_cutoff_bucket := l_bkt_index + l_msc_plan_buckets.bucket_index.COUNT;
	p_weekly_cutoff_bucket := l_bkt_index + l_msc_plan_buckets.bucket_index.COUNT;
	p_period_cutoff_bucket := l_bkt_index + l_msc_plan_buckets.bucket_index.COUNT;

	l_bkt_index := l_bkt_index + l_msc_plan_buckets.bucket_index.count;
	l_msc_plan_buckets := NULL;
   END IF;


   IF l_weekly_cutoff_date IS NOT NULL THEN

      SELECT
	l_bkt_index+rownum
	,To_char(cal.week_start_date, 'YYYY/MM/DD')
	,To_char(Least(
		       Greatest(cal.next_date - 1, cal.week_start_date),
		       -- for last week both are same
		       l_weekly_cutoff_date),'YYYY/MM/DD')
	--min of this and weekly cutoff
	,2 bucket_type
	,trunc(Least(
		     Greatest(cal.next_date - 1, cal.week_start_date),
		     l_weekly_cutoff_date)) - trunc(cal.week_start_date) + 1    days_in_bucket
	BULK COLLECT INTO
	l_msc_plan_buckets.bucket_index,
	l_msc_plan_buckets.bkt_start_date,
	l_msc_plan_buckets.bkt_end_date,
	l_msc_plan_buckets.bucket_type,
	l_msc_plan_buckets.days_in_bkt
	FROM
	MSC_CAL_WEEK_START_DATES cal
	WHERE cal.sr_instance_id = m_sr_instance_id
	AND cal.calendar_code = m_calendar_code
	AND cal.exception_set_id = m_cal_exception_set_id
	and trunc(cal.week_start_date) <= trunc(l_weekly_cutoff_date)
	and trunc(cal.week_start_date) >= trunc(Nvl(l_daily_cutoff_date,Sysdate-1))+1
	ORDER BY cal.week_start_date ASC;

      insert_into_table(
			p_plan_id,
			l_sr_instance_id,
			l_org_id,
			l_bkt_index,
			l_msc_plan_buckets,
			p_err_mesg);

      IF p_err_mesg IS NOT NULL THEN
	  /* IF mrdebug = TRUE THEN
	      LOG_MESSAGE(' 201 ');
	   END IF;		   */
	 RETURN;
      END IF;

      p_weekly_cutoff_bucket := l_bkt_index + l_msc_plan_buckets.bucket_index.COUNT;
      p_period_cutoff_bucket := l_bkt_index + l_msc_plan_buckets.bucket_index.COUNT;

      l_bkt_index := l_bkt_index + l_msc_plan_buckets.bucket_index.count;
      l_msc_plan_buckets := NULL;


   END IF;


   IF l_period_cutoff_date IS NOT NULL THEN

      SELECT
	l_bkt_index+ROWNUM
	,To_char(cal.period_start_date, 'YYYY/MM/DD') bkt_start_date
	,To_char(Least(
		       Greatest(cal.next_date - 1,cal.period_start_date),
		       l_period_cutoff_date), 'YYYY/MM/DD')   bkt_end_date
	,3 bucket_type
	,trunc(Least(
		     Greatest(cal.next_date - 1,cal.period_start_date),
		     l_period_cutoff_date)) - trunc(cal.period_start_date)
	           + 1            days_in_bucket
	-- days between needs a + 1
	BULK COLLECT INTO
	l_msc_plan_buckets.bucket_index,
	l_msc_plan_buckets.bkt_start_date,
	l_msc_plan_buckets.bkt_end_date,
	l_msc_plan_buckets.bucket_type,
	l_msc_plan_buckets.days_in_bkt
	FROM
	msc_period_start_dates cal
	WHERE
            cal.sr_instance_id = m_sr_instance_id
	AND cal.calendar_code = m_calendar_code
	AND cal.exception_set_id  = m_cal_exception_set_id
	and trunc(cal.period_start_date) <= trunc(l_period_cutoff_date )
	and trunc(cal.period_start_date) >=
	trunc(Nvl(l_weekly_cutoff_date, Nvl(l_daily_cutoff_date,Sysdate-1))) + 1
      	ORDER BY cal.period_start_date;

      insert_into_table(
			p_plan_id,
			l_sr_instance_id,
			l_org_id,
			l_bkt_index,
			l_msc_plan_buckets,
			p_err_mesg);
      IF p_err_mesg IS NOT NULL THEN
	/* IF mrdebug = TRUE THEN
	    LOG_MESSAGE(' 301 ');
	 END IF;		   */
	 RETURN;
      END IF;
      p_period_cutoff_bucket := l_bkt_index + l_msc_plan_buckets.bucket_index.COUNT;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
     /* IF mrdebug = TRUE THEN
	 LOG_MESSAGE('Error in calculate_plan_buckets :'|| to_char(sqlcode) || substr(sqlerrm,1,60));
      END IF; */
      p_err_mesg := to_char(sqlcode)||substr(sqlerrm,1,60);
END calculate_plan_buckets;

/*====================================================
  This procedure will be used for concurrent program
  This will call refresh_snapshot_ods_mv internally
  with different parameters

  p_source : 1 - Collections
             2 - Others
  ====================================================*/
PROCEDURE refresh_snapshot_ods_mv(
                           ERRBUF             OUT NOCOPY VARCHAR2,
                           RETCODE            OUT NOCOPY NUMBER,
                           p_plan_id          IN NUMBER default null) IS
lv_plan_so NUMBER := 0;
lv_global_forecast NUMBER := 0;
lv_err_code NUMBER;
lv_err_mesg VARCHAR2(2000);
lv_launch_refresh_gf BOOLEAN := FALSE;
l_latest_change_date DATE;
last_gf_refresh_date DATE;
BEGIN
LOG_MESSAGE('Started refresh of global forecast');

    IF p_plan_id IS NOT NULL THEN

        BEGIN

            select count(*) into lv_plan_so
            from msc_plan_organizations_v
            where plan_id = p_plan_id
            and nvl(include_salesorder,SYS_NO) = SYS_YES;

        EXCEPTION WHEN OTHERS THEN
            RETCODE := G_ERROR;
            RETURN;
        END;

        BEGIN

            select count(*)
            into lv_global_forecast
            from msc_plan_schedules_v
            where plan_id = p_plan_id
            and   input_organization_id = GLOBAL_ORG;

        EXCEPTION WHEN OTHERS THEN
            RETCODE := G_ERROR;
            RETURN;
        END;

        /*================================================
          Check if refresh global forecast needs to be
          launched.
          ================================================*/

        IF (lv_global_forecast > 0 OR lv_plan_so >0 ) THEN

          /*
            BEGIN
                select nvl(global_fcst_refresh_date, to_date('01-JAN-1900','dd-mon-yyyy'))
                    into last_gf_refresh_date
                from msc_plans
                where plan_id = p_plan_id;

            EXCEPTION WHEN OTHERS THEN
                RETCODE := G_ERROR;
                RETURN;
            END;

            IF (lv_launch_refresh_gf = FALSE) THEN
                l_latest_change_date := NULL;
                BEGIN
                    select max(last_update_date) into l_latest_change_date
                    from msc_plan_organizations
                    where plan_id = p_plan_id;
                EXCEPTION WHEN OTHERS THEN
                    RETCODE := G_ERROR;
                    RETURN;
                END;

                IF (l_latest_change_date > last_gf_refresh_date) THEN
                    lv_launch_refresh_gf := TRUE;
                END IF;

            END IF;

            IF (lv_launch_refresh_gf = FALSE) THEN
                l_latest_change_date := NULL;
                BEGIN
                    select max(msa.last_update_date) into l_latest_change_date
                    from msc_sr_assignments msa,
                         msc_plans mp
                    where mp.plan_id = p_plan_id
                    and   mp.FORECAST_ASSIGNMENT_SET_ID = msa.assignment_set_id;
                EXCEPTION WHEN OTHERS THEN
                    RETCODE := G_ERROR;
                    RETURN;
                END;

                IF (l_latest_change_date > last_gf_refresh_date) THEN
                    lv_launch_refresh_gf := TRUE;
                END IF;

            END IF;

            IF (lv_launch_refresh_gf = FALSE) THEN
                l_latest_change_date := NULL;
                BEGIN
                    select max(msr.last_update_date) into l_latest_change_date
                    from msc_sourcing_rules msr,
                         msc_sr_assignments msra,
                         msc_plans mp
                    where mp.plan_id = p_plan_id
                    and   mp.FORECAST_ASSIGNMENT_SET_ID = msra.ASSIGNMENT_SET_ID
                    and   msra.sourcing_rule_id = msr.sourcing_rule_id;
                EXCEPTION WHEN OTHERS THEN
                    RETCODE := G_ERROR;
                    RETURN;
                END;

                IF (l_latest_change_date > last_gf_refresh_date) THEN
                    lv_launch_refresh_gf := TRUE;
                END IF;

            END IF; */

            lv_launch_refresh_gf := TRUE;
        ELSE
            lv_launch_refresh_gf := FALSE;
        END IF; /* IF (lv_global_forecast > 0 OR lv_plan_so >0 ) THEN */

    ELSE
        lv_launch_refresh_gf := TRUE;
    END IF;  /* p_plan_id IS NOT NULL THEN */


    /*===========================
      Call refresh_snapshot_ods_mv
      ============================*/
    IF ( lv_launch_refresh_gf) THEN

        LOG_MESSAGE('Calling refresh_snp_ods_mv_pvt for refresh of global forecast');
        refresh_snp_ods_mv_pvt(lv_err_code,
                               lv_err_mesg,
                                p_plan_id,
                                lv_global_forecast,
                                lv_plan_so);

    ELSE
        LOG_MESSAGE('This plan does not have Sales Orders and Global Forecast.');
        LOG_MESSAGE('There is no need to refresh global forecast');
        RETCODE := G_SUCCESS;
    END IF;

    IF  lv_err_code = G_ERROR THEN
        RETCODE := G_ERROR;
        LOG_MESSAGE('RETCODE -'||lv_err_code);
        LOG_MESSAGE(lv_err_mesg);
    ELSE
        RETCODE := G_SUCCESS;
        LOG_MESSAGE('RETCODE -'||lv_err_code);
    END IF;

END refresh_snapshot_ods_mv;

PROCEDURE refresh_snp_ods_mv_pvt(
			    p_err_code                  OUT NOCOPY NUMBER,
                            p_err_mesg                  OUT NOCOPY VARCHAR2,
                            p_plan_id            in NUMBER,
                            p_global_forecast     in number default null,
                            p_plan_so     in number default null
			    ) IS
lv_sql_stmt        VARCHAR2(32767);
lv_plan_id        VARCHAR2(200);
    lv_task_start_time DATE;
    lv_retval boolean;
    lv_dummy1 varchar2(32);
    lv_dummy2 varchar2(32);
    lv_msc_schema varchar2(32);
BEGIN
/*    DBMS_MVIEW.REFRESH ('MSC_ITEM_SO_SR_LEVELS_MV','c');
      DBMS_MVIEW.REFRESH ('MSC_ITEM_FCST_SR_LEVELS_MV','c');*/

   IF p_plan_id is NULL THEN
         lv_retval := FND_INSTALLATION.GET_APP_INFO ( 'MSC', lv_dummy1, lv_dummy2, lv_msc_schema);

         lv_sql_stmt:= 'TRUNCATE TABLE '||lv_msc_schema||'.MSC_ITEM_SO_SR_LEVELS';
         EXECUTE IMMEDIATE lv_sql_stmt;

         lv_sql_stmt:= 'TRUNCATE TABLE '||lv_msc_schema||'.MSC_ITEM_FCST_SR_LEVELS';
         EXECUTE IMMEDIATE lv_sql_stmt;

         lv_plan_id := '  ';

   ELSE
         DELETE MSC_ITEM_SO_SR_LEVELS where plan_id = p_plan_id;
         DELETE MSC_ITEM_FCST_SR_LEVELS where plan_id = p_plan_id;
         lv_plan_id := ' WHERE plan_id = '||p_plan_id||' ';
   END IF;

   COMMIT;

IF (p_plan_so > 0 OR p_plan_id IS NULL) THEN

lv_sql_stmt :=
  '    INSERT /*+ APPEND */ INTO MSC_ITEM_SO_SR_LEVELS'
||'          (INVENTORY_ITEM_ID                        ,'
||'           ORGANIZATION_ID                          ,'
||'           SR_INSTANCE_ID                           ,'
||'           PLAN_ID                                  ,'
||'           ASSIGNMENT_TYPE                          ,'
||'           ASSIGNMENT_SET_ID                        ,'
||'           SOURCING_RULE_TYPE                       ,'
||'           SOURCE_ORGANIZATION_ID                   ,'
||'           SOURCE_ORG_INSTANCE_ID                   ,'
||'           ALLOCATION_PERCENT                       ,'
||'           RANK                                     ,'
||'           EFFECTIVE_DATE                           ,'
||'           DISABLE_DATE                             ,'
||'           SOURCING_LEVEL                           ,'
||'           ASSIGNMENT_ID                            ,'
||'           SOURCING_RULE_ID                         ,'
||'           SOURCING_RULE_NAME                       ,'
||'           SOURCE_TYPE                              ,'
||'           SR_DESCRIPTION                           ,'
||'           COMPILE_DESIGNATOR                       ,'
||'           OWNING_ORG_ID                            ,'
||'           COMP_MRP_PLANNING_CODE                   ,'
||'           COMP_BOM_ITEM_TYPE                       ,'
||'           COMP_PLANNING_MAKE_BUY_CODE              ,'
||'           COMP_PRIMARY_UOM_CODE                    ,'
||'           CUSTOMER_ID                              ,'
||'           CUSTOMER_SITE_ID                         ,'
||'           REGION_ID                                ,'
||'           COMP_DRP_PLANNED                         )'
||'          SELECT '
||'          INVENTORY_ITEM_ID                        ,'
||'           ORGANIZATION_ID                          ,'
||'           SR_INSTANCE_ID                           ,'
||'           PLAN_ID                                  ,'
||'           ASSIGNMENT_TYPE                          ,'
||'           ASSIGNMENT_SET_ID                        ,'
||'           SOURCING_RULE_TYPE                       ,'
||'           SOURCE_ORGANIZATION_ID                   ,'
||'           SOURCE_ORG_INSTANCE_ID                   ,'
||'           ALLOCATION_PERCENT                       ,'
||'           RANK                                     ,'
||'           EFFECTIVE_DATE                           ,'
||'           DISABLE_DATE                             ,'
||'           SOURCING_LEVEL                           ,'
||'           ASSIGNMENT_ID                            ,'
||'           SOURCING_RULE_ID                         ,'
||'           SOURCING_RULE_NAME                       ,'
||'           SOURCE_TYPE                              ,'
||'           SR_DESCRIPTION                           ,'
||'           COMPILE_DESIGNATOR                       ,'
||'           OWNING_ORG_ID                            ,'
||'           COMP_MRP_PLANNING_CODE                   ,'
||'           COMP_BOM_ITEM_TYPE                       ,'
||'           COMP_PLANNING_MAKE_BUY_CODE              ,'
||'           COMP_PRIMARY_UOM_CODE                    ,'
||'           CUSTOMER_ID                              ,'
||'           CUSTOMER_SITE_ID                         ,'
||'           REGION_ID                                ,'
||'           COMP_DRP_PLANNED                         '
||'  FROM     MSC_ITEM_SO_SR_LEVELS_V	'
||lv_plan_id;
    EXECUTE IMMEDIATE lv_sql_stmt ;
    COMMIT;

LOG_MESSAGE('Inserted records into MSC_ITEM_SO_SR_LEVELS');
END IF;


IF (p_global_forecast > 0 OR p_plan_id is NULL) THEN
lv_sql_stmt :=
  '    INSERT /*+ APPEND */ INTO MSC_ITEM_FCST_SR_LEVELS '
||'          (INVENTORY_ITEM_ID                        ,'
||'           SR_INVENTORY_ITEM_ID                          ,'
||'           ORGANIZATION_ID                          ,'
||'           SR_INSTANCE_ID                           ,'
||'           PLAN_ID                                  ,'
||'           ASSIGNMENT_TYPE                          ,'
||'           ASSIGNMENT_SET_ID                        ,'
||'           SOURCING_RULE_TYPE                       ,'
||'           SOURCE_ORGANIZATION_ID                   ,'
||'           SOURCE_ORG_INSTANCE_ID                   ,'
||'           VENDOR_ID                       ,'
||'           VENDOR_SITE_ID                                     ,'
||'           ALLOCATION_PERCENT                           ,'
||'           RANK                           ,'
||'           EFFECTIVE_DATE                           ,'
||'           DISABLE_DATE                             ,'
||'           CATEGORY_ID                             ,'
||'           SOURCING_LEVEL                           ,'
||'           ASSIGNMENT_ID                            ,'
||'           SOURCING_RULE_ID                         ,'
||'           SOURCING_RULE_NAME                       ,'
||'           SOURCE_TYPE                              ,'
||'           SOURCE_ORG_CODE                              ,'
||'           SR_DESCRIPTION                           ,'
||'           COMPILE_DESIGNATOR                       ,'
||'           OWNING_ORG_ID                            ,'
||'           MRP_PLANNING_CODE                   ,'
||'           BOM_ITEM_TYPE                       ,'
||'           PLANNING_MAKE_BUY_CODE              ,'
||'           PRIMARY_UOM_CODE                    ,'
||'           COMP_MRP_PLANNING_CODE                   ,'
||'           CUSTOMER_ID                              ,'
||'           CUSTOMER_SITE_ID                         ,'
||'           ZONE_ID                                ,'
||'           ASSY_DRP_PLANNED                                ,'
||'           COMP_DRP_PLANNED                         ) '
||'    SELECT  '
||'           INVENTORY_ITEM_ID                        ,'
||'           SR_INVENTORY_ITEM_ID                          ,'
||'           ORGANIZATION_ID                          ,'
||'           SR_INSTANCE_ID                           ,'
||'           PLAN_ID                                  ,'
||'           ASSIGNMENT_TYPE                          ,'
||'           ASSIGNMENT_SET_ID                        ,'
||'           SOURCING_RULE_TYPE                       ,'
||'           SOURCE_ORGANIZATION_ID                   ,'
||'           SOURCE_ORG_INSTANCE_ID                   ,'
||'           VENDOR_ID                       ,'
||'           VENDOR_SITE_ID                                     ,'
||'           ALLOCATION_PERCENT                           ,'
||'           RANK                           ,'
||'           EFFECTIVE_DATE                           ,'
||'           DISABLE_DATE                             ,'
||'           CATEGORY_ID                             ,'
||'           SOURCING_LEVEL                           ,'
||'           ASSIGNMENT_ID                            ,'
||'           SOURCING_RULE_ID                         ,'
||'           SOURCING_RULE_NAME                       ,'
||'           SOURCE_TYPE                              ,'
||'           SOURCE_ORG_CODE                              ,'
||'           SR_DESCRIPTION                           ,'
||'           COMPILE_DESIGNATOR                       ,'
||'           OWNING_ORG_ID                            ,'
||'           MRP_PLANNING_CODE                   ,'
||'           BOM_ITEM_TYPE                       ,'
||'           PLANNING_MAKE_BUY_CODE              ,'
||'           PRIMARY_UOM_CODE                    ,'
||'           COMP_MRP_PLANNING_CODE                   ,'
||'           CUSTOMER_ID                              ,'
||'           CUSTOMER_SITE_ID                         ,'
||'           ZONE_ID                                ,'
||'           ASSY_DRP_PLANNED                                ,'
||'           COMP_DRP_PLANNED                           '
||' FROM 	MSC_ITEM_FCST_SR_LEVELS_V	'
||lv_plan_id;

   EXECUTE IMMEDIATE lv_sql_stmt ;
   COMMIT;

LOG_MESSAGE( 'Inserted records into MSC_ITEM_FCST_SR_LEVELS');
END IF;
p_err_code := G_SUCCESS;
p_err_mesg := 'SUCCESS';
EXCEPTION
   WHEN OTHERS THEN
        p_err_code := G_ERROR;
        p_err_mesg := to_char(sqlcode)||substr(sqlerrm,1,60);
        LOG_MESSAGE('Error while refresh global forecast');
END refresh_snp_ods_mv_pvt;

PROCEDURE refresh_snapshot_pds_mv(
			    p_err_mesg                  OUT NOCOPY VARCHAR2,
                            p_plan_id            in NUMBER,
                            p_global_forecast     in number default null,
                            p_plan_so     in number default null
			    ) IS
	lv_p_plan_so number;
	lv_p_plan_type number;
BEGIN
/*    DBMS_MVIEW.REFRESH ('MSC_ITEM_FCST_BOD_SR_LEVELS_MV','c');
    DBMS_MVIEW.REFRESH ('MSC_BOD_SO_SR_LEVELS_MV','c');
*/
        IF p_global_forecast = SYS_YES THEN
         DELETE MSC_ITEM_FCST_BOD_SR_LEVELS where plan_id = p_plan_id;
         COMMIT;

         INSERT /*+APPEND*/ INTO MSC_ITEM_FCST_BOD_SR_LEVELS
         (
          INVENTORY_ITEM_ID                        ,
          SR_INVENTORY_ITEM_ID                     ,
          ORGANIZATION_ID                          ,
          SR_INSTANCE_ID                           ,
          PLAN_ID                                  ,
          ASSIGNMENT_TYPE                          ,
          ASSIGNMENT_SET_ID                        ,
          SOURCING_RULE_TYPE                       ,
          SOURCE_ORGANIZATION_ID                   ,
          SOURCE_ORG_INSTANCE_ID                   ,
          VENDOR_ID                                ,
          VENDOR_SITE_ID                           ,
          ALLOCATION_PERCENT                       ,
          RANK                                     ,
          SHIP_METHOD                              ,
          EFFECTIVE_DATE                           ,
          DISABLE_DATE                             ,
          CATEGORY_ID                              ,
          SOURCING_LEVEL                           ,
          ASSIGNMENT_ID                            ,
          SOURCING_RULE_ID                         ,
          SOURCING_RULE_NAME                       ,
          SOURCE_TYPE                              ,
          SOURCE_ORG_CODE                          ,
          SR_DESCRIPTION                           ,
          OWNING_ORG_ID                            ,
          CUSTOMER_ID                              ,
          CUSTOMER_SITE_ID                         ,
          ZONE_ID                                  )
         SELECT
          INVENTORY_ITEM_ID                        ,
          SR_INVENTORY_ITEM_ID                     ,
          ORGANIZATION_ID                          ,
          SR_INSTANCE_ID                           ,
          PLAN_ID                                  ,
          ASSIGNMENT_TYPE                          ,
          ASSIGNMENT_SET_ID                        ,
          SOURCING_RULE_TYPE                       ,
          SOURCE_ORGANIZATION_ID                   ,
          SOURCE_ORG_INSTANCE_ID                   ,
          VENDOR_ID                                ,
          VENDOR_SITE_ID                           ,
          ALLOCATION_PERCENT                       ,
          RANK                                     ,
          SHIP_METHOD                              ,
          EFFECTIVE_DATE                           ,
          DISABLE_DATE                             ,
          CATEGORY_ID                              ,
          SOURCING_LEVEL                           ,
          ASSIGNMENT_ID                            ,
          SOURCING_RULE_ID                         ,
          SOURCING_RULE_NAME                       ,
          SOURCE_TYPE                              ,
          SOURCE_ORG_CODE                          ,
          SR_DESCRIPTION                           ,
          OWNING_ORG_ID                            ,
          CUSTOMER_ID                              ,
          CUSTOMER_SITE_ID                         ,
          ZONE_ID
         FROM MSC_ITEM_FCST_BOD_SR_LEVELS_V
         WHERE PLAN_ID = p_plan_id;
         COMMIT;
  END IF;


  IF p_plan_so > 0 THEN
     select decode(curr_plan_type,1,1,2,1,3,1,0)
	into lv_p_plan_type
     from msc_plans
     where plan_id = p_plan_id;

     IF lv_p_plan_type = 0 THEN
	lv_p_plan_so := 1;
     ELSE
	select decode(DAILY_MATERIAL_CONSTRAINTS,1,1,
		decode(DAILY_RESOURCE_CONSTRAINTS,1,1,
		 decode(WEEKLY_MATERIAL_CONSTRAINTS,1,1,
		  decode(WEEKLY_RESOURCE_CONSTRAINTS,1,1,
		   decode(PERIOD_MATERIAL_CONSTRAINTS,1,1,
		    decode(PERIOD_RESOURCE_CONSTRAINTS,1,1,0))))))
		into lv_p_plan_so
	from msc_plans
	where plan_id = p_plan_id;

	IF lv_p_plan_so = 1 THEN
	   select decode(optimize_flag,1,1,
		  	decode(nvl(fnd_profile.value('MSO_ENABLE_DECISION_RULES'),'N'),
			'Y',1,'Yes',1,'YES',1,0))
	   into lv_p_plan_so
	   from msc_plans
	   where plan_id = p_plan_id;

		IF lv_p_plan_so = 1 THEN
			lv_p_plan_so := 1;
		ELSE
			lv_p_plan_so := 0;
		END IF;
	ELSE
		lv_p_plan_so := 0;
	END IF;
     END IF;
  ELSE
	lv_p_plan_so := 0;
  END IF;

  IF lv_p_plan_so > 0 THEN

     DELETE MSC_BOD_SO_SR_LEVELS where plan_id = p_plan_id;
     COMMIT;

         INSERT INTO MSC_TEMP_REGION_LOCATIONS(
		REGION_ID ,
		LOCATION_ID ,
		LOCATION_SOURCE ,
		REGION_TYPE ,
		PARENT_REGION_FLAG ,
		SR_INSTANCE_ID,
		partner_type)
	 SELECT REGION_ID ,
		LOCATION_ID ,
		LOCATION_SOURCE ,
		(10 * (10 - region_type)) REGION_TYPE ,
		PARENT_REGION_FLAG ,
		SR_INSTANCE_ID,
		2 partner_type
	  FROM  MSC_REGION_LOCATIONS
	 WHERE  location_source = 'HZ'
	   and  region_id is not null
	   and  region_id in ( select distinct msa.region_id
				 from msc_sr_assignments msa,
				      msc_plans mp
			  where msa.assignment_type in (7,8,9)
				and mp.plan_id = p_plan_id
				and msa.assignment_set_id = mp.curr_assignment_set_id
			      )
	 UNION ALL
	 select a.REGION_ID,
		c.LOCATION_ID,
		c.LOCATION_SOURCE,
		((10 * (10 - a.zone_level)) + 1) REGION_TYPE,
		c.PARENT_REGION_FLAG,
		a.SR_INSTANCE_ID,
		2 PARTNER_TYPE
	  FROM  MSC_REGIONS a,
		MSC_ZONE_REGIONS b,
		msc_region_locations c
	  WHERE a.region_id = b.parent_region_id
	  AND a.region_type = 10
	  AND a.zone_level IS NOT NULL
	  AND a.sr_instance_id = b.sr_instance_id
	  AND b.region_id = c.region_id
	  and b.sr_instance_id = c.sr_instance_id
	  and c.region_id is not null
	  and c.location_source = 'HZ'
	  and a.region_id in ( select distinct msa.region_id
				 from msc_sr_assignments msa,
				      msc_plans mp
			  where msa.assignment_type in (7,8,9)
			    and mp.plan_id = p_plan_id
			    and msa.assignment_set_id = mp.curr_assignment_set_id
			  )
			  ;

     INSERT /*+APPEND*/ into MSC_BOD_SO_SR_LEVELS
     ( INVENTORY_ITEM_ID                        ,
       ORGANIZATION_ID                          ,
       SR_INSTANCE_ID                           ,
       PLAN_ID                                  ,
       ASSIGNMENT_TYPE                          ,
       ASSIGNMENT_SET_ID                        ,
       SOURCING_RULE_TYPE                       ,
       SOURCE_ORGANIZATION_ID                   ,
       SOURCE_ORG_INSTANCE_ID                   ,
       ALLOCATION_PERCENT                       ,
       RANK                                     ,
       SHIP_METHOD                       ,
       EFFECTIVE_DATE                     ,
       DISABLE_DATE                        ,
       SOURCING_LEVEL                           ,
       ASSIGNMENT_ID                            ,
       SOURCING_RULE_ID                         ,
       SOURCING_RULE_NAME                   ,
       SOURCE_TYPE                              ,
       SR_DESCRIPTION                        ,
       COMPILE_DESIGNATOR                     ,
       OWNING_ORG_ID                            ,
       MRP_PLANNING_CODE                        ,
       BOM_ITEM_TYPE                            ,
       PLANNING_MAKE_BUY_CODE                   ,
       PRIMARY_UOM_CODE                        ,
       CUSTOMER_ID                              ,
       CUSTOMER_SITE_ID                         ,
       REGION_ID                                ,
       REGION_TYPE                              )
      SELECT
       INVENTORY_ITEM_ID                        ,
       ORGANIZATION_ID                          ,
       SR_INSTANCE_ID                           ,
       PLAN_ID                                  ,
       ASSIGNMENT_TYPE                          ,
       ASSIGNMENT_SET_ID                        ,
       SOURCING_RULE_TYPE                       ,
       SOURCE_ORGANIZATION_ID                   ,
       SOURCE_ORG_INSTANCE_ID                   ,
       ALLOCATION_PERCENT                       ,
       RANK                                     ,
       SHIP_METHOD                       ,
       EFFECTIVE_DATE                     ,
       DISABLE_DATE                        ,
       SOURCING_LEVEL                           ,
       ASSIGNMENT_ID                            ,
       SOURCING_RULE_ID                         ,
       SOURCING_RULE_NAME                   ,
       SOURCE_TYPE                              ,
       SR_DESCRIPTION                        ,
       COMPILE_DESIGNATOR                     ,
       OWNING_ORG_ID                            ,
       MRP_PLANNING_CODE                        ,
       BOM_ITEM_TYPE                            ,
       PLANNING_MAKE_BUY_CODE                   ,
       PRIMARY_UOM_CODE                        ,
       CUSTOMER_ID                              ,
       CUSTOMER_SITE_ID                         ,
       REGION_ID                                ,
       REGION_TYPE
      FROM MSC_BOD_SO_SR_LEVELS_V
      WHERE PLAN_ID = p_plan_id;
      COMMIT;
  END IF;
EXCEPTION
   WHEN OTHERS THEN
    /*  IF mrdebug = TRUE THEN
	 LOG_MESSAGE('Error in insert_into_table :'|| to_char(sqlcode) || substr(sqlerrm,1,60));
      END IF; */
      p_err_mesg := to_char(sqlcode)||substr(sqlerrm,1,60);

END refresh_snapshot_pds_mv;

PROCEDURE insert_into_table(
			    p_plan_id                   NUMBER,
			    p_sr_instance_id            NUMBER,
			    p_org_id                    NUMBER,
			    p_bucket_index              NUMBER,
			    p_msc_plan_buckets          IN OUT NOCOPY msc_plan_buckets_typ,
			    p_err_mesg                  OUT NOCOPY VARCHAR2
			    ) IS
    j NUMBER;
    k NUMBER;
BEGIN

   FOR j IN 1..p_msc_plan_buckets.bucket_index.COUNT LOOP
      p_msc_plan_buckets.bucket_index(j) := j+p_bucket_index;
   END LOOP;
  /*
   IF mrdebug = TRUE THEN
      NULL;
      FOR j IN 1..p_msc_plan_buckets.bucket_index.COUNT LOOP
	 LOG_MESSAGE(p_msc_plan_buckets.bucket_index(j)||' '||
			      p_msc_plan_buckets.bkt_start_date(j)||' '||
			      p_msc_plan_buckets.bkt_end_date(j)||' '||
			      p_msc_plan_buckets.bucket_type(j)||' '||
			      p_msc_plan_buckets.days_in_bkt(j));
      END LOOP;

	 LOG_MESSAGE(p_msc_plan_buckets.bucket_index.count||' '||
			p_msc_plan_buckets.bkt_start_date.count||' '||
			p_msc_plan_buckets.bkt_end_date.count||' '||
			p_msc_plan_buckets.bucket_type.count||' '||
			p_msc_plan_buckets.days_in_bkt.count);

   END IF;
   */

      FORALL k IN 1..p_msc_plan_buckets.bucket_index.COUNT
	insert into msc_plan_buckets(
				     PLAN_ID
				     ,ORGANIZATION_ID
				     ,SR_INSTANCE_ID
				     ,BUCKET_INDEX
				     ,BKT_START_DATE
				     ,BKT_END_DATE
				     ,BUCKET_TYPE
				     ,DAYS_IN_BKT
				     ,CURR_FLAG
				     ,LAST_UPDATE_DATE
				     ,LAST_UPDATED_BY
				     ,CREATION_DATE
				     ,CREATED_BY)
	VALUES
	(
	 p_plan_id,
	 p_org_id,
	 p_sr_instance_id,
	 p_msc_plan_buckets.bucket_index(k),
	 To_date(p_msc_plan_buckets.bkt_start_date(k), 'YYYY/MM/DD'),
	 To_date(p_msc_plan_buckets.bkt_end_date(k), 'YYYY/MM/DD')+(86399/86400),
	 p_msc_plan_buckets.bucket_type(k),
	 p_msc_plan_buckets.days_in_bkt(k),
	 1,
	 Sysdate,
	 1,
	 Sysdate,
	 1);

EXCEPTION
   WHEN OTHERS THEN
    /*  IF mrdebug = TRUE THEN
	 LOG_MESSAGE('Error in insert_into_table :'|| to_char(sqlcode) || substr(sqlerrm,1,60));
      END IF; */
      p_err_mesg := to_char(sqlcode)||substr(sqlerrm,1,60);

END insert_into_table;

PROCEDURE get_cutoff_dates(
			   p_plan_id               IN    NUMBER,
			   p_err_mesg              OUT NOCOPY  VARCHAR2,
			   p_min_cutoff_date       OUT NOCOPY  number,
			   p_hour_cutoff_date      OUT NOCOPY  number,
			   p_daily_cutoff_date     OUT NOCOPY number,
			   p_weekly_cutoff_date    OUT NOCOPY number,
			   p_period_cutoff_date    OUT NOCOPY number,
			   p_min_cutoff_bucket     OUT NOCOPY number,
			   p_hour_cutoff_bucket    OUT NOCOPY number,
			   p_daily_cutoff_bucket   OUT NOCOPY number,
			   p_weekly_cutoff_bucket  OUT NOCOPY number,
			   p_period_cutoff_bucket  OUT NOCOPY number
			   ) IS
      l_daily_cutoff_date     DATE;
      l_weekly_cutoff_date    DATE;
      l_period_cutoff_date    DATE;
      first_date              DATE;
  BEGIN

     SELECT Nvl(min_cutoff_bucket,0), Nvl(hour_cutoff_bucket,0)
       INTO p_min_cutoff_bucket,p_hour_cutoff_bucket
       FROM msc_plans
       WHERE plan_id = p_plan_id;

     --LOG_MESSAGE(' 1 : '||p_min_cutoff_bucket||' '||p_hour_cutoff_bucket);

     SELECT NVL(MIN(bkt_start_date), TRUNC(SYSDATE))
       INTO first_date
       FROM msc_plan_buckets
       WHERE plan_id = p_plan_id
       AND bucket_type = 1;

     --LOG_MESSAGE(' 2 : '||first_date);

     IF p_min_cutoff_bucket <> 0 THEN
	p_min_cutoff_date := To_char(first_date+(p_min_cutoff_bucket-1),'J');
	--LOG_MESSAGE(' 3 : '||p_min_cutoff_date);
      ELSE
	p_min_cutoff_date := To_char(first_date,'J');
	--LOG_MESSAGE(' 4 : '||p_min_cutoff_date);
     END IF;

     IF p_hour_cutoff_bucket <> 0 THEN
	IF p_min_cutoff_bucket <> 0 THEN
	   p_hour_cutoff_date := p_min_cutoff_date+p_hour_cutoff_bucket;
	   -- changed after finding the date.
	   p_hour_cutoff_bucket := p_min_cutoff_bucket + p_hour_cutoff_bucket;
	   --LOG_MESSAGE(' 5 : '||p_hour_cutoff_bucket||' '||p_hour_cutoff_date);
	 ELSE
	   p_hour_cutoff_date := To_char(first_date+p_hour_cutoff_bucket -1,'J');
	   --LOG_MESSAGE(' 6 : '||p_hour_cutoff_date);
	END IF;
      ELSE
	p_hour_cutoff_bucket := p_min_cutoff_bucket;
	p_hour_cutoff_date := p_min_cutoff_date;
	--LOG_MESSAGE(' 7 : '||p_hour_cutoff_bucket||' '||p_hour_cutoff_date);
     END IF;


     SELECT  NVL(max(bkt_end_date), TRUNC(SYSDATE)),
             NVL(max(bucket_index), 0)
       INTO l_daily_cutoff_date, p_daily_cutoff_bucket
       from msc_plan_buckets
       where plan_id = p_plan_id
       AND bucket_type = 1;

    if  p_daily_cutoff_bucket = 0
     then
           select nvl(curr_start_date-1, TRUNC(SYSDATE-1))
           INTO   l_daily_cutoff_date
            from msc_plans
            where plan_id = p_plan_id;
     end if;



     --LOG_MESSAGE(' 8 : '||l_daily_cutoff_date||' '||p_daily_cutoff_bucket);

     SELECT
       Nvl(max(bkt_end_date),l_daily_cutoff_date),
       Nvl(max(bucket_index), p_daily_cutoff_bucket)
       INTO l_weekly_cutoff_date, p_weekly_cutoff_bucket
       from msc_plan_buckets
       where plan_id = p_plan_id
       AND bucket_type = 2;

  --LOG_MESSAGE(' 9 : '||l_weekly_cutoff_date||' '||p_weekly_cutoff_bucket);

     SELECT
       Nvl(max(bkt_end_date),l_weekly_cutoff_date),
       Nvl(max(bucket_index), p_weekly_cutoff_bucket)
       INTO l_period_cutoff_date, p_period_cutoff_bucket
       from msc_plan_buckets
       where plan_id = p_plan_id
       AND bucket_type = 3;

     --LOG_MESSAGE(' 10 : '||l_period_cutoff_date||' '||p_period_cutoff_bucket);

     p_daily_cutoff_date := To_char(l_daily_cutoff_date,'J');
     p_weekly_cutoff_date :=  To_char(l_weekly_cutoff_date,'J');
     p_period_cutoff_date := To_char(l_period_cutoff_date,'J');

     --LOG_MESSAGE(' 10 : '||p_daily_cutoff_date||' '||p_weekly_cutoff_date||' '||p_period_cutoff_date);

  EXCEPTION
     WHEN OTHERS THEN
--	IF mrdebug = TRUE THEN
	   LOG_MESSAGE('Error in get_cutoff_dates :'|| to_char(sqlcode) || substr(sqlerrm,1,60));
--	END IF;
	p_err_mesg := to_char(sqlcode)||substr(sqlerrm,1,60);

END get_cutoff_dates;

PROCEDURE form_get_bucket_cutoff_dates
  (
   p_plan_id              IN    NUMBER,
   p_org_id               IN    NUMBER,
   p_instance_id          IN    NUMBER,
   p_min_cutoff_bucket    IN    number,
   p_hour_cutoff_bucket   IN    number,
   p_daily_cutoff_bucket  IN    number,
   p_weekly_cutoff_bucket IN    number,
   p_period_cutoff_bucket IN    number,
   p_plan_completion_date OUT NOCOPY DATE,
   p_err_mesg             OUT NOCOPY VARCHAR2
   ) IS
      l_daily_cutoff_date  DATE;
      l_weekly_cutoff_date DATE;
      l_period_cutoff_date DATE;
BEGIN

   get_bucket_cutoff_dates(
			   p_plan_id              =>p_plan_id,
			   p_org_id               =>p_org_id,
			   p_instance_id          =>p_instance_id,
			   p_plan_start_date      =>Sysdate,
			   p_plan_completion_date =>NULL, -- not used
			   p_min_cutoff_bucket    =>p_daily_cutoff_bucket,
			   p_hour_cutoff_bucket   =>p_daily_cutoff_bucket,
			   p_daily_cutoff_bucket  =>p_daily_cutoff_bucket,
			   p_weekly_cutoff_bucket =>p_weekly_cutoff_bucket,
			   p_period_cutoff_bucket =>p_period_cutoff_bucket,
			   p_min_cutoff_date      =>l_daily_cutoff_date,
			   p_hour_cutoff_date     =>l_daily_cutoff_date,
			   p_daily_cutoff_date    =>l_daily_cutoff_date,
			   p_weekly_cutoff_date   =>l_weekly_cutoff_date,
			   p_period_cutoff_date   =>l_period_cutoff_date,
			   p_err_mesg             =>p_err_mesg
			   );

   IF l_period_cutoff_date IS NOT NULL THEN
      p_plan_completion_date := l_period_cutoff_date;
    ELSIF l_weekly_cutoff_date IS NOT NULL THEN
      p_plan_completion_date := l_weekly_cutoff_date;
    ELSE
      p_plan_completion_date := l_daily_cutoff_date;
   END IF;

   RETURN;

END form_get_bucket_cutoff_dates;

FUNCTION get_validation_org_id (p_sr_instance_id in NUMBER)
return NUMBER IS
l_org_id NUMBER;
BEGIN
   select nvl(validation_org_id,-1) into l_org_id
   from msc_apps_instances
   where instance_id = p_sr_instance_id;
   return l_org_id;
EXCEPTION WHEN OTHERS THEN
   return -1;
END get_validation_org_id;

FUNCTION get_column_expression (p_column_name in VARCHAR2,
                                p_index_owner in VARCHAR2,
                                p_table_owner in VARCHAR2,
                                p_index_name in VARCHAR2,
                                p_table_name in VARCHAR2,
                                p_column_position in number)
return VARCHAR2 IS
l_retval  VARCHAR2(2000);
l_longvar long;
BEGIN
  select column_expression into l_longvar
  from all_ind_expressions
  where table_owner = p_table_owner
    and index_owner = p_index_owner
    and table_name = p_table_name
    and index_name = p_index_name
    and column_position = p_column_position;
  return (substr(l_longvar, 1, 2000));
EXCEPTION WHEN NO_DATA_FOUND THEN
  return p_column_name;

END get_column_expression;
/*
FUNCTION get_ss_date (p_calendar_code VARCHAR2,
                            p_plan_id IN NUMBER,
                            p_owning_org_id IN NUMBER,
                            p_owning_instance_id IN NUMBER,
                            p_ss_org_id IN NUMBER,
                            p_ss_instance_id IN NUMBER,
                            p_ss_date IN NUMBER,
                            p_plan_type IN NUMBER)
	return NUMBER IS
l_bucket_type NUMBER;
l_bucket_index NUMBER;
l_bkt_end_date NUMBER;
l_bkt_end_date1 NUMBER;
l_bkt_end_date3 NUMBER;
l_calendar_date NUMBER;

BEGIN
      IF ( p_owning_org_id IS NULL OR
                p_owning_instance_id IS NULL OR
                p_ss_date IS NULL OR
                p_calendar_code IS NULL ) THEN
            return null;
        END IF;


	BEGIN
           IF (p_plan_type <> 4 AND p_plan_type <> 9) THEN
                select  own_org_bkt.bucket_type,
                        own_org_bkt.bucket_index,
                        to_number(to_char(own_org_bkt.bkt_end_date,'J')),
                        to_number(to_char(nvl(org_bkt.bkt_end_date,sysdate),'J'))
                into    l_bucket_type,
                        l_bucket_index,
                        l_bkt_end_date,
                        l_bkt_end_date1
                from    msc_plan_buckets own_org_bkt,
                        msc_plan_buckets org_bkt
                where   own_org_bkt.plan_id = p_plan_id
                and     own_org_bkt.organization_id = p_owning_org_id
                and     own_org_bkt.sr_instance_id = p_owning_instance_id
                and     own_org_bkt.curr_flag = 1
                and     ((own_org_bkt.bkt_start_date <= to_date(p_ss_date,'J') and
                        own_org_bkt.bkt_end_date >= to_date(p_ss_date,'J')) OR
                        (own_org_bkt.bkt_start_date > to_date(p_ss_date,'J') and
                        own_org_bkt.bucket_index = 1))
                and     org_bkt.plan_id(+) = own_org_bkt.plan_id
                and     org_bkt.organization_id(+) = p_owning_org_id
                and     org_bkt.sr_instance_id(+) = p_owning_instance_id
                and     org_bkt.curr_flag(+) = 1
                and     org_bkt.bucket_index(+) = own_org_bkt.bucket_index-1;

                IF (l_bucket_type = 1 or l_bucket_index = 1) THEN
                   l_bkt_end_date3 := l_bkt_end_date;
                ELSE
                   l_bkt_end_date3 := l_bkt_end_date1;
                END IF;

              select to_number(to_char(cal2.calendar_date,'J'))
              into   l_calendar_date
              from msc_calendar_dates cal1,
                   msc_calendar_dates cal2
              where cal1.calendar_code = p_calendar_code
              and   cal1.calendar_date = to_date(l_bkt_end_date3,'J')
              and   cal1.exception_set_id = -1
              and   cal1.sr_instance_id = p_ss_instance_id
              and   cal2.seq_num = cal1.prior_seq_num
              and   cal2.calendar_code = cal1.calendar_code
              and   cal2.sr_instance_id = cal1.sr_instance_id
              and   cal2.exception_set_id = -1;
            ELSE
               select to_number(to_char(cal2.calendar_date,'J'))
               into l_calendar_date
               from msc_plan_buckets   org_bkt,
                    msc_calendar_dates cal1,
                    msc_calendar_dates cal2
               where org_bkt.plan_id = p_plan_id
                 and org_bkt.organization_id = p_owning_org_id
                 and org_bkt.sr_instance_id = p_owning_instance_id
                 and org_bkt.curr_flag = 1
                 and     ((org_bkt.bkt_start_date <= to_date(p_ss_date,'J') and
                         org_bkt.bkt_end_date >= to_date(p_ss_date,'J')) OR
                         (org_bkt.bkt_start_date > to_date(p_ss_date,'J') and
                        org_bkt.bucket_index = 1))
                 and cal1.calendar_code  = p_calendar_code
                 and cal1.calendar_date = org_bkt.bkt_start_date
                 and cal1.exception_set_id = -1
                 and   cal1.sr_instance_id = p_ss_instance_id
                 and   cal2.seq_num = cal1.next_seq_num
                 and   cal2.calendar_code = cal1.calendar_code
                 and   cal2.sr_instance_id = cal1.sr_instance_id
                 and   cal2.exception_set_id = -1;
             END IF;


            return(l_calendar_date);

          EXCEPTION WHEN NO_DATA_FOUND THEN
				return null;
        END;



END get_ss_date;
*/
--modified body of msc_snapshot_pk.get_ss_date for Bug 5610482
FUNCTION GET_SS_DATE (p_calendar_code VARCHAR2,
                            p_plan_id IN NUMBER,
                            p_owning_org_id IN NUMBER,
                            p_owning_instance_id IN NUMBER,
                            p_ss_org_id IN NUMBER,
                            p_ss_instance_id IN NUMBER,
                            p_ss_date IN NUMBER,
                            p_plan_type IN NUMBER)
return NUMBER IS
l_bucket_type NUMBER;
l_bucket_index NUMBER;
l_bkt_end_date NUMBER;
l_bkt_end_date1 NUMBER;
l_bkt_end_date3 NUMBER;
l_calendar_date NUMBER;
BEGIN
      IF ( p_owning_org_id IS NULL OR
                p_owning_instance_id IS NULL OR
                p_ss_date IS NULL OR
                p_calendar_code IS NULL ) THEN
            return null;
        END IF;

        BEGIN
           IF (p_plan_type <> 4 AND p_plan_type <> 9) THEN
                select  to_number(to_char(cal1.prior_date,'J'))
                into    l_calendar_date
                from    msc_plan_buckets own_org_bkt,
                        msc_plan_buckets org_bkt,
                        msc_calendar_dates cal1
                where   own_org_bkt.plan_id = p_plan_id
                and     own_org_bkt.organization_id = p_owning_org_id
                and     own_org_bkt.sr_instance_id = p_owning_instance_id
                and     own_org_bkt.curr_flag = 1
                and     ((own_org_bkt.bkt_start_date <= to_date(p_ss_date,'J') and
                        own_org_bkt.bkt_end_date >= to_date(p_ss_date,'J')) OR
                        (own_org_bkt.bkt_start_date > to_date(p_ss_date,'J') and
                        own_org_bkt.bucket_index = 1))
                and     org_bkt.plan_id(+) = own_org_bkt.plan_id
                and     org_bkt.organization_id(+) = p_owning_org_id
                and     org_bkt.sr_instance_id(+) = p_owning_instance_id
                and     org_bkt.curr_flag(+) = 1
                and     org_bkt.bucket_index(+) = own_org_bkt.bucket_index-1
                and     cal1.calendar_code = p_calendar_code
                and     cal1.calendar_date = decode(own_org_bkt.bucket_type,1,trunc(own_org_bkt.bkt_end_date),decode(own_org_bkt.bucket_index,1,trunc(own_org_bkt.bkt_end_date),nvl(trunc(org_bkt.bkt_end_date),trunc(sysdate))))
                and     cal1.exception_set_id = -1
                and     cal1.sr_instance_id = p_ss_instance_id ;
            ELSE
               select to_number(to_char(cal1.next_date,'J'))
               into l_calendar_date
               from msc_plan_buckets   org_bkt,
                    msc_calendar_dates cal1
               where org_bkt.plan_id = p_plan_id
                 and org_bkt.organization_id = p_owning_org_id
                 and org_bkt.sr_instance_id = p_owning_instance_id
                 and org_bkt.curr_flag = 1
                 and     ((org_bkt.bkt_start_date <= to_date(p_ss_date,'J') and
                         org_bkt.bkt_end_date >= to_date(p_ss_date,'J')) OR
                         (org_bkt.bkt_start_date > to_date(p_ss_date,'J') and
                        org_bkt.bucket_index = 1))
                 and cal1.calendar_code  = p_calendar_code
                 and cal1.calendar_date = org_bkt.bkt_start_date
                 and cal1.exception_set_id = -1
                 and   cal1.sr_instance_id = p_ss_instance_id;
             END IF;

            return(l_calendar_date);

          EXCEPTION WHEN NO_DATA_FOUND THEN
                                return null;
        END;
END;



FUNCTION get_op_leadtime_percent(p_plan_id IN NUMBER,
                                 p_routing_seq_id IN NUMBER,
                                 p_sr_instance_id IN NUMBER,
                                 p_op_seq_num IN NUMBER)
return NUMBER  IS
l_op_leadtime_percent NUMBER;

BEGIN
        BEGIN
                select  nvl(mro.operation_lead_time_percent, 0.0)
                into    l_op_leadtime_percent
                from
                        msc_routing_operations mro
                where   mro.plan_id = p_plan_id
                and     mro.sr_instance_id = p_sr_instance_id
                and     mro.routing_sequence_id = p_routing_seq_id
                and     mro.operation_seq_num = p_op_seq_num
                and     mro.effectivity_date <= sysdate
                and     (mro.disable_date >= sysdate or
                         mro.disable_date is NULL);

            return(l_op_leadtime_percent);

          EXCEPTION    WHEN OTHERS THEN
                                return 0.0;
        END;

END get_op_leadtime_percent;



procedure calculate_start_date(p_org_id               IN NUMBER,
                               p_sr_instance_id       IN    NUMBER,
                               p_plan_start_date      IN    DATE,
                               p_daily_cutoff_bucket  IN    NUMBER,
                               p_weekly_cutoff_bucket IN    NUMBER,
                               p_period_cutoff_bucket IN    NUMBER,
                               p_daily_start_date    OUT  NOCOPY  DATE,
                               p_weekly_start_date   OUT  NOCOPY  DATE,
                               p_period_start_date   OUT  NOCOPY  DATE,
                               p_curr_cutoff_date    OUT  NOCOPY  DATE) IS
v_min_cutoff_date date;
v_hour_cutoff_date date;
v_daily_cutoff_date date;
v_weekly_cutoff_date date;
v_period_cutoff_date date;
v_err_mesg varchar2(2000);
v_daily_cutoff_bucket number;
v_weekly_cutoff_bucket number;
v_period_cutoff_bucket number;


BEGIN

   get_bucket_cutoff_dates(
                            0, -- p_plan_id            IN    NUMBER,
                            p_org_id, -- p_org_id      IN    NUMBER,
                            p_sr_instance_id,   --     IN    NUMBER,
                            p_plan_start_date,  --     IN    DATE,
                            to_date(null), --p_plan_completion_date IN    DATE,
                            0, --p_min_cutoff_bucket   IN    number,
                            0, --p_hour_cutoff_bucket  IN    number,
                            p_daily_cutoff_bucket, --  IN    number,
                            p_weekly_cutoff_bucket, -- IN    number,
                            p_period_cutoff_bucket, --  IN    number,
                            v_min_cutoff_date, --      OUT   DATE,
                            v_hour_cutoff_date, --     OUT   DATE,
                            v_daily_cutoff_date, --    OUT   DATE,
                            v_weekly_cutoff_date, --   OUT   DATE,
                            v_period_cutoff_date,  --   OUT   DATE
                            v_err_mesg) ;

   p_daily_start_date  := p_plan_start_date;

   select min(cal.week_start_date)
   into p_weekly_start_date
   from msc_cal_week_start_dates cal,
        msc_trading_partners tp
   where cal.exception_set_id = tp.calendar_exception_set_id
   and   cal.calendar_code    = tp.calendar_code
   and   cal.week_start_date >= trunc(v_daily_cutoff_date)
   and   cal.sr_instance_id   = tp.sr_instance_id
   and   tp.sr_tp_id          = p_org_id
   and   tp.partner_type      = 3;

   if p_daily_cutoff_bucket = 0  and p_weekly_cutoff_bucket = 0 then
     p_weekly_start_date := p_daily_start_date;
   end if;

   select min(cal.period_start_date)
   into p_period_start_date
   from msc_period_start_dates cal,
        msc_trading_partners tp
   where cal.exception_set_id   = tp.calendar_exception_set_id
   and   cal.calendar_code      = tp.calendar_code
   and   cal.period_start_date >= nvl(trunc(v_weekly_cutoff_date),
                                  trunc(v_daily_cutoff_date))
   and   cal.sr_instance_id     = tp.sr_instance_id
   and   tp.sr_tp_id            = p_org_id
   and   tp.partner_type        = 3;

   if v_weekly_cutoff_bucket = 0 and v_period_cutoff_bucket = 0  then
     p_period_start_date := p_weekly_start_date;
   end if;

   if v_period_cutoff_date is not null then
     p_curr_cutoff_date := v_period_cutoff_date;
   elsif v_weekly_cutoff_date is not null then
     p_curr_cutoff_date := v_weekly_cutoff_date;
   elsif v_daily_cutoff_date is not null then
     p_curr_cutoff_date := v_daily_cutoff_date;
   end if;

end calculate_start_date;

function calculate_start_date1(p_org_id               IN    NUMBER,
                               p_sr_instance_id       IN    NUMBER,
                               p_plan_start_date      IN    DATE,
                               p_daily_cutoff_bucket  IN    NUMBER,
                               p_weekly_cutoff_bucket IN    NUMBER,
                               p_period_cutoff_bucket IN    NUMBER,
                               P_start_date_bucket    IN    NUMBER) return Date is
v_daily_start_date date;
v_weekly_start_date date;
v_period_start_date date;
v_curr_cutoff_date date;

begin
          calculate_start_date(p_org_id ,
                               p_sr_instance_id       ,
                               p_plan_start_date      ,
                               p_daily_cutoff_bucket  ,
                               p_weekly_cutoff_bucket ,
                               p_period_cutoff_bucket ,
                               v_daily_start_date    ,
                               v_weekly_start_date   ,
                               v_period_start_date   ,
                               v_curr_cutoff_date    ) ;

    if    p_start_date_bucket = 1 then
       return v_daily_start_date;
    elsif p_start_date_bucket = 2 then
       return v_weekly_start_date;
    elsif p_start_date_bucket = 3 then
       return v_period_start_date;
    end if;

exception when others then
    return to_date(null);

end calculate_start_date1;

PROCEDURE update_items_info(
			    p_err_mesg           OUT NOCOPY VARCHAR2,
                            p_plan_id            in NUMBER
			    ) IS
lv_fetchComplete  Boolean;

TYPE NumTblTyp  IS TABLE OF NUMBER;
TYPE Char1TblTyp IS TABLE OF VARCHAR2(250);
TYPE Char2TblTyp IS TABLE OF VARCHAR2(240);
TYPE Char3TblTyp IS TABLE OF VARCHAR2(10);
TYPE Char4TblTyp IS TABLE OF VARCHAR2(3);

lb_inv_item_id    NumTblTyp;
lb_org_id         NumTblTyp;
lb_val_org_id     NumTblTyp;
lb_sr_instance_id NumTblTyp;

lb_item_name      Char1TblTyp;
lb_description    Char2TblTyp;
lb_buyer_name     Char2TblTyp;
lb_planner_code   Char3TblTyp;
lb_plng_excp_set  Char3TblTyp;
lb_revision       Char4TblTyp;

ln_rows_to_fetch  Number := nvl(TO_NUMBER( FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE')),75000);
lv_plan_partition_exists Number := 0;

CURSOR items_for_update
   IS
SELECT /*+ ORDERED USE_NL(ODS, MSC_SYSTEM_ITEMS_U1) */ ODS.INVENTORY_ITEM_ID,
     PDS.ORGANIZATION_ID,
     ODS.SR_INSTANCE_ID,
     ODS.ITEM_NAME,
     ODS.DESCRIPTION,
     ODS.BUYER_NAME,
     ODS.PLANNER_CODE,
     ODS.PLANNING_EXCEPTION_SET,
     ODS.REVISION,
     -1
FROM MSC_SYSTEM_ITEMS PDS,
     MSC_SYSTEM_ITEMS ODS
WHERE ODS.PLAN_ID = -1
  AND ODS.INVENTORY_ITEM_ID = PDS.INVENTORY_ITEM_ID
  AND ODS.ORGANIZATION_ID = DECODE(PDS.ORGANIZATION_ID, -1,
	msc_snapshot_pk.get_validation_org_id(PDS.SR_INSTANCE_ID), PDS.ORGANIZATION_ID)
  AND ODS.SR_INSTANCE_ID = PDS.SR_INSTANCE_ID
  AND PDS.PLAN_ID = p_plan_id;
BEGIN

    SELECT count(*)
    INTO   lv_plan_partition_exists
    FROM   MSC_PLAN_PARTITIONS
    WHERE  plan_id = p_plan_id;

    IF (lv_plan_partition_exists > 0) THEN

        LOG_MESSAGE('Analysing MSC_SYSTEM_ITEMS plan partition ');

        msc_analyse_tables_pk.analyse_table( 'MSC_SYSTEM_ITEMS', -1, p_plan_id);

    ELSE

       -- LOG_MESSAGE('Analysing MSC_SYSTEM_ITEMS table ');

       -- msc_analyse_tables_pk.analyse_table( 'MSC_SYSTEM_ITEMS' );

        null;

    END IF;

    LOG_MESSAGE('Updating the Items Table ');

    lv_fetchComplete := FALSE;

    OPEN items_for_update;
    IF (items_for_update%ISOPEN) THEN
	LOOP
	    IF (lv_fetchComplete) THEN
	      EXIT;
	    END IF;

	    FETCH items_for_update
	    BULK COLLECT
	    INTO   lb_inv_item_id,
		   lb_org_id,
		   lb_sr_instance_id,
		   lb_item_name,
		   lb_description,
		   lb_buyer_name,
		   lb_planner_code,
		   lb_plng_excp_set,
		   lb_revision,
		   lb_val_org_id
	    LIMIT ln_rows_to_fetch;

	    EXIT WHEN lb_inv_item_id.count = 0;

	    IF (items_for_update%NOTFOUND) THEN
	      lv_fetchComplete := TRUE;
	    END IF;

	    FORALL j IN lb_inv_item_id.FIRST..lb_inv_item_id.LAST
		UPDATE MSC_SYSTEM_ITEMS
		SET   item_name =  lb_item_name(j),
		      description = lb_description(j),
		      buyer_name = lb_buyer_name(j),
		      planner_code = lb_planner_code(j),
		      planning_exception_set = lb_plng_excp_set(j),
		      revision = lb_revision(j)
		WHERE  sr_instance_id = lb_sr_instance_id(j)
		AND    inventory_item_id = lb_inv_item_id(j)
		--AND    (organization_id  = lb_org_id(j) OR
		--       (organization_id  = -1 AND lb_val_org_id(j) = lb_org_id(j)
		--	 ))
		AND	organization_id = lb_org_id(j)
		AND    plan_id = p_plan_id;

	COMMIT;

	END LOOP;

    END IF;

    IF (items_for_update%ISOPEN) THEN
	CLOSE items_for_update;
    END IF;

    COMMIT;

    LOG_MESSAGE('Completed updating the Items Table ');
EXCEPTION WHEN OTHERS then
        LOG_MESSAGE('RETCODE -'||SQLCODE);
        LOG_MESSAGE(SQLERRM);
        p_err_mesg := to_char(sqlcode)||substr(sqlerrm,1,60);
END update_items_info;

FUNCTION f_period_start_date(p_plan_id IN NUMBER,
                             p_instance_id IN NUMBER,
                             p_org_id IN NUMBER,
                             p_item_id  IN  NUMBER) return date is
l_date date;
begin
SELECT TRUNC(nvl(max(period_start_date),sysdate))
                 into   l_date
                 FROM   msc_safety_stocks
                 WHERE  period_start_date <= TRUNC(SYSDATE)
                 AND    inventory_item_id = p_item_id
                 AND    sr_instance_id = p_instance_id
                 AND    organization_id = p_org_id
                 AND    plan_id = p_plan_id;
return l_date;

end;

END MSC_SNAPSHOT_PK; -- package

/
