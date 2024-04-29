--------------------------------------------------------
--  DDL for Package Body MSC_EXCHANGE_BUCKETING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_EXCHANGE_BUCKETING" AS
/* $Header: MSCXBKB.pls 120.4 2006/02/13 04:12:43 pragarwa noship $ */
EQUAL      CONSTANT INTEGER := 1;
NOT_EQUAL  CONSTANT INTEGER := 2;
SYS_NO      CONSTANT INTEGER := 2;
SYS_YES     CONSTANT INTEGER := 1;
FIVE_DAY_WEEK  CONSTANT INTEGER := 1;
SEVEN_DAY_WEEK CONSTANT INTEGER := 2;
MIXED       CONSTANT INTEGER := 4;
DAY            CONSTANT INTEGER := 1;
WEEK        CONSTANT INTEGER := 2;
MONTH       CONSTANT INTEGER := 3;
NONE        CONSTANT INTEGER := -1;
SUPPLY_PLANNING CONSTANT INTEGER := 1;
DEMAND_PLANNING CONSTANT INTEGER := 2;

TYPE numberList is table of number;

   PROCEDURE LOG_MESSAGE( pBUFF                     IN  VARCHAR2)
   IS
   BEGIN
    IF( g_msc_cp_debug= '1' OR g_msc_cp_debug = '2') THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
    END IF;
	 --dbms_output.put_line(pBUFF);
   EXCEPTION
     WHEN OTHERS THEN
        RETURN;
   END LOG_MESSAGE;

PROCEDURE ADD_TO_PLAN_BUCKETS(p_plan_id IN NUMBER,
                       p_org_id IN NUMBER,
                       p_sr_instance_id IN NUMBER,
                       p_bkt_index IN NUMBER,
		     p_supplier_id  IN NUMBER,
		     p_supplier_site_id  IN NUMBER,
		     p_customer_id   IN NUMBER,
		     p_customer_site_id  IN NUMBER,
		     p_inventory_item_id  in number,
		     p_plan_type    in  number,
                        p_curr_flag IN NUMBER,
                         p_start_date IN NUMBER,
                       p_end_date IN NUMBER,
                       p_days_in_bkt IN NUMBER,
                       p_bkt_type IN NUMBER) IS
begin

if (p_plan_type = SUPPLY_PLANNING) then

   insert into msc_cp_plan_buckets(
      plan_id,
      organization_id,
      sr_instance_id,
      bucket_index,
      curr_flag,
      bkt_start_date,
      bkt_end_date,
      days_in_bkt,
      bucket_type,
		     supplier_id,
		     supplier_site_id,
		     customer_id,
		     customer_site_id,
		     inventory_item_id,
		     plan_type,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by) values
      (p_plan_id,
       p_org_id,
       p_sr_instance_id,
       p_bkt_index,
       p_curr_flag,
       to_date(p_start_date, 'J'),
       to_date(p_end_date,  'J'),
       p_days_in_bkt,
       p_bkt_type,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
		     p_inventory_item_id  ,
		     p_plan_type    ,
       sysdate,
       -1,
       sysdate,
       -1);

elsif (p_plan_type = DEMAND_PLANNING) then

   insert into msc_plan_buckets(
      plan_id,
      organization_id,
      sr_instance_id,
      bucket_index,
      curr_flag,
      bkt_start_date,
      bkt_end_date,
      days_in_bkt,
      bucket_type,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by) values
      (p_plan_id,
       p_org_id,
       p_sr_instance_id,
       p_bkt_index,
       p_curr_flag,
       to_date(p_start_date, 'J'),
       to_date(p_end_date,  'J'),
       p_days_in_bkt,
       p_bkt_type,
       sysdate,
       -1,
       sysdate,
       -1);

end if;

commit;
end;

PROCEDURE ADD_TO_PLAN_BUCKETS(p_plan_id IN NUMBER,
                       p_org_id IN NUMBER,
                       p_sr_instance_id IN NUMBER,
                       p_bkt_index IN NUMBER,
                        p_curr_flag IN NUMBER,
                         p_start_date IN NUMBER,
                       p_end_date IN NUMBER,
                       p_days_in_bkt IN NUMBER,
                       p_bkt_type IN NUMBER) IS
begin

   insert into msc_plan_buckets(
      plan_id,
      organization_id,
      sr_instance_id,
      bucket_index,
      curr_flag,
      bkt_start_date,
      bkt_end_date,
      days_in_bkt,
      bucket_type,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by) values
      (p_plan_id,
       p_org_id,
       p_sr_instance_id,
       p_bkt_index,
       p_curr_flag,
       to_date(p_start_date, 'J'),
       to_date(p_end_date,  'J'),
       p_days_in_bkt,
       p_bkt_type,
       sysdate,
       -1,
       sysdate,
       -1);

commit;
end;

FUNCTION COMPARE_MONTHS(p_date1 IN NUMBER,
                  p_date2 IN NUMBER)
                  return NUMBER IS
month1 NUMBER;
month2 NUMBER;
begin

   select to_number(to_char(to_date(p_date1, 'j'), 'MM'))
   INTO
   month1 from dual;


   select to_number(to_char(to_date(p_date2, 'j'), 'MM'))
   INTO
   month2 from dual;


   if(month1 <> month2)
   then
      return NOT_EQUAL;
   else
      return EQUAL;
   end if;

end;




FUNCTION CHECK_DAY_OF_WEEK(p_date IN NUMBER)
            return NUMBER IS
day_of_week NUMBER;
begin

      select to_char(to_date(p_date, 'j'), 'D')
      into
      day_of_week from dual;


      return day_of_week;
end;

PROCEDURE ASSIGN_MONTHLY_BUCKETS(p_plan_id IN NUMBER,
                            p_org_id IN NUMBER,
                         p_sr_instance_id IN NUMBER,
                         curr_date IN NUMBER,
                         p_cal_code IN NUMBER,
                         p_no_of_mths IN NUMBER,
                         p_bkt_index IN OUT NOCOPY NUMBER) IS
loop number;
the_date number;
last_day_of_mth number;
days_in_month number;
day_of_week number;
BEGIN


   the_date := curr_date;

   FOR loop in 1..p_no_of_mths loop

      /*------------------------------------+
      | Get the number of days in the month |
      +-------------------------------------*/

      select
         to_number(to_char(last_day(to_date(the_date, 'J')), 'J'))
      into
         last_day_of_mth
      from dual;

      /*--------------------------------------------------+
      | If last day of month falls on weekend, please    |
      | set it accordingly for 5-2 calendar           |
      +---------------------------------------------------*/

      if(p_cal_code = FIVE_DAY_WEEK) then

         day_of_week := check_day_of_week(last_day_of_mth);

         if(day_of_week = 1)
         then
            last_day_of_mth := last_day_of_mth - 2;
         elsif (day_of_week = 7)
         then
            last_day_of_mth := last_day_of_mth - 1;
         end if;

      end if;


      days_in_month := last_day_of_mth - the_date;


        add_to_plan_buckets(p_plan_id,
                            p_org_id,
                            p_sr_instance_id,
                            p_bkt_index,
                            1,
                            the_date,
                            last_day_of_mth,
                            days_in_month,
                            3);


        p_bkt_index := p_bkt_index + 1;
        the_date := last_day_of_mth + 1;

      /*----------------------------------------------------+
      | If the last day falls on Saturday or Sunday, advance|
      | and continue for 5-2 calendar                |
      +-----------------------------------------------------*/

      if(p_cal_code = FIVE_DAY_WEEK) then

         day_of_week := check_day_of_week(the_date);

         if(day_of_week = 7) then
            the_date := the_date + 2;
         elsif (day_of_week = 1) then
            the_date := the_date + 1;
         end if;

      end if;

    END LOOP;

-- added exception handler
EXCEPTION
   WHEN OTHERS THEN
          /* Bug # 4235511 */
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_ERROR,'MSC_EXCHANGE_BUCKETING.ASSIGN_MONTHLY_BUCKETS',SQLERRM);
            end if  ;

END ASSIGN_MONTHLY_BUCKETS;


PROCEDURE ASSIGN_WEEKLY_BUCKETS(p_plan_id IN NUMBER,
                               p_org_id IN NUMBER,
                                p_sr_instance_id IN NUMBER,
                                p_start_date IN NUMBER,
                                p_no_of_days IN NUMBER,
                        p_cal_code IN NUMBER,
                                p_bkt_index IN OUT NOCOPY NUMBER,
                                p_curr_date IN OUT NOCOPY NUMBER) IS

the_date  NUMBER;
day_of_week NUMBER;
end_date NUMBER;
month_end NUMBER;
loop number;
diff number;
days_in_bkt number;
BEGIN


      /*------------------------------------------------+
      | Starting with the first date keep entering      |
      | weekly buckets into msc_plan_buckets until   |
      | the weekly buckets are over.                 |
      +-------------------------------------------------*/

      the_date := p_start_date;

      if(p_no_of_days = 0)
      then
            return;

       end if;

      /*------------------------------------------------+
      | Make sure the first date is a Monday. This will |
      | only not happen of daily bucketing is set to    |
      | zero. If daily buckets are set that procedure   |
      | makes sure that the_date is a Monday.        |
      +-------------------------------------------------*/


      /*------------------------------------------------+
      | If the first date is not Monday create a short  |
      | week starting from today and ending on       |
      | or Friday  for a five day week calendar         |
      +-------------------------------------------------*/


      if(p_cal_code = FIVE_DAY_WEEK) then

         day_of_week := check_day_of_week(the_date);

         if(day_of_week  = 1) /* Sunday */ then
            the_date := the_date + 1;
         elsif (day_of_week = 7) /* Saturday */ then
            the_date := the_date + 2;
         else

            if(day_of_week in (3, 4, 5, 6)) /* Tue to Friday */ then

               add_to_plan_buckets(p_plan_id,
                            p_org_id,
                            p_sr_instance_id,
                            p_bkt_index,
                            1,
                            the_date,
                            the_date + 6 - day_of_week,
                            6 - day_of_week + 1,
                            2);

               p_bkt_index := p_bkt_index + 1;

               /*-----------------------------------------+
               | Move the current date to the next Monday |
               +------------------------------------------*/
               the_date := the_date + 6 - day_of_week + 3;

            end if;

         end if;

      end if;

      day_of_week := check_day_of_week(the_date);

      if(p_cal_code = FIVE_DAY_WEEK) then
         days_in_bkt := 5;
      else
         days_in_bkt := 7;

      end if;



      FOR loop in 1..p_no_of_days loop


      add_to_plan_buckets(p_plan_id,
                           p_org_id,
                           p_sr_instance_id,
                           p_bkt_index,
                           1,
                           the_date,
                           the_date + days_in_bkt - 1,
                           days_in_bkt,
                           2);


         p_bkt_index := p_bkt_index + 1;
         the_date := the_date + 7;


      END LOOP;


      if(p_cal_code = FIVE_DAY_WEEK) then


      /*--------------------------------------------------+
      | See if the month ends on the weekend. If so just |
      | return.                                 |
      +---------------------------------------------------*/

      if(compare_months(the_date - 7 ,the_date) = NOT_EQUAL)
      then
         p_curr_date := the_date;
         return;

      end if;



      /*--------------------------------------------------+
      | Create weekly buckets until the end of the month |
      +---------------------------------------------------*/

      month_end := SYS_NO;

      LOOP

         FOR LOOP IN 1..5 loop


         /*----------------------------------------+
         | Keep comparing the months in the days   |
         | until the next month is reached or the  |
         | week is over.                       |
         +-----------------------------------------*/


         if(compare_months(the_date, the_date + loop) = NOT_EQUAL)
         then

            month_end := SYS_YES;
            end_date := the_date + loop;
            diff := loop;
            exit;
         end if;


         END LOOP;


         if(month_end = SYS_NO)
         then
            /*-------------------------------------------------+
            | If no month is found then create a new week and  |
            | continue.                               |
            +--------------------------------------------------*/

            add_to_plan_buckets(p_plan_id,
                            p_org_id,
                            p_sr_instance_id,
                            p_bkt_index,
                            1,
                            the_date,
                            the_date + 4,
                            5,
                            2);


            p_bkt_index := p_bkt_index + 1;
            the_date := the_date + 7;

            /*-----------------------------------------------+
            | If the month ends in the weekend just exit and |
            | return.                               |
            +------------------------------------------------*/

            if(compare_months(the_date - 7, the_date) = NOT_EQUAL)
            then
               exit;

            end if;
            /*-----------------------------------------------+
            | Add code here to check if the month begins on  |
            | the weekend.                          |
            +------------------------------------------------*/
         else
            /*-----------------------------------------------+
            | If month is found create a weekly bucket until |
            | the end of the month.                    |
            +------------------------------------------------*/


                add_to_plan_buckets(p_plan_id,
                            p_org_id,
                            p_sr_instance_id,
                            p_bkt_index,
                            1,
                            the_date,
                            the_date + diff - 1,
                            diff,
                            2);


                p_bkt_index := p_bkt_index + 1;
                the_date := the_date + diff;
            exit;
         end if;
   END LOOP;

   end if;

p_curr_date := the_date;

return;

-- added exception handler
EXCEPTION WHEN OTHERS THEN
          /* Bug # 4235511 */
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'MSC_EXCHANGE_BUCKETING.ASSIGN_WEEKLY_BUCKETS',SQLERRM);
        end if ;

END ASSIGN_WEEKLY_BUCKETS;



PROCEDURE ASSIGN_DAILY_BUCKETS(p_plan_id IN NUMBER,
                        p_org_id IN NUMBER,
                              p_sr_instance_id IN NUMBER,
                                p_start_date in NUMBER,
                        p_no_of_days IN NUMBER,
                        p_cal_code IN NUMBER,
                        p_bkt_index IN OUT NOCOPY NUMBER,
                        p_curr_date IN OUT NOCOPY NUMBER) IS
the_date NUMBER;
day_of_week NUMBER;
days_rem NUMBER;
begin




   the_date := p_start_date;

    /*-------------------------------------------------------+
    | Starting with the first date keep inserting buckets    |
    | into msc_plan_buckets until the daily buckets are over |
    +--------------------------------------------------------*/


   if(p_no_of_days = 0)
   then
      return;

   end if;

   FOR loop in 1..p_no_of_days loop

      if(p_cal_code = FIVE_DAY_WEEK) then

         day_of_week := check_day_of_week(the_date);

         if(day_of_week = 7)
         then
            the_date := the_date + 2;
         elsif (day_of_week = 1)
         then
            the_date := the_date + 1;
         end if;

      end if;

      add_to_plan_buckets(p_plan_id,
                     p_org_id,
                     p_sr_instance_id,
                     p_bkt_index,
                     1,
                     the_date,
                     the_date,
                     1,
                     1);


      p_bkt_index := p_bkt_index + 1;
      the_date := the_date + 1;


   END LOOP;

   /*------------------------------------------------------+
   | If the daily buckets do not end on Friday create more |
   | daily buckets until Friday.                   |
   +-------------------------------------------------------*/

   if(p_cal_code = FIVE_DAY_WEEK) then
      day_of_week := check_day_of_week(the_date);

      if(day_of_week  = 1) /* Sunday */
      then
         /* Just increment the date and return  */
         the_date := the_date + 1;
         p_curr_date := the_date;

      elsif(day_of_week = 7) /* Saturday */
      then
         the_date := the_date + 2;
         p_curr_date := the_date;
      else

         null;


      /*-------------------------------------------------------------+
      | Get the number of days between the_date and Friday and create|
      | more daily buckets.                                 |
      +--------------------------------------------------------------*/

      days_rem := 6 - day_of_week + 1;


      FOR loop in 1..days_rem loop

        add_to_plan_buckets(p_plan_id,
                            p_org_id,
                            p_sr_instance_id,
                            p_bkt_index,
                            1,
                            the_date,
                            the_date,
                            1,
                            1);


        p_bkt_index := p_bkt_index + 1;
        the_date := the_date + 1;

      p_curr_date := the_date + 2;


      END LOOP;

   end if;
   else /* 7 day calendar  */

      p_curr_date := the_date;

   end if;


return;

-- added exception handler
EXCEPTION WHEN OTHERS THEN
          /* Bug # 4235511 */
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FND_LOG.STRING(FND_LOG.LEVEL_ERROR,'MSC_EXCHANGE_BUCKETING.ASSIGN_DAILY_BUCKETS',SQLERRM);
          end if ;

end ASSIGN_DAILY_BUCKETS;

PROCEDURE calculate_plan_buckets(
                 p_plan_id                IN    NUMBER,
             p_org_id              IN NUMBER,
             p_sr_instance_id      IN NUMBER,
                 p_daily_cutoff_bucket    IN   number,
                 p_weekly_cutoff_bucket   IN    number,
                 p_mthly_cutoff_bucket   IN    number
                 ) IS
first_date     date;
jul_first_date  number;
curr_date number;
day_of_week number;
p_cal_code number;
bkt_index number := 1;
BEGIN

   /*------------------------------------------------------+
   | Delete the old buckets for the plan.             |
   +-------------------------------------------------------*/

   --delete msc_plan_buckets
   --where plan_id = p_plan_id;

   /*------------------------------------------------------+
   | Get today's date. This is the first date from which    |
   | the buckets are calculated.                   |
   +-------------------------------------------------------*/

   select sysdate
   into first_date
   from dual;

   select to_number(to_char(first_date, 'J'))
   into jul_first_date
   from dual;

   /*-------------------------------------------------------+
   | Get calendar code from the table msc_plan_organizations|
   | At present the code is defined at the plan level, so   |
   | get any row.                                |
   +--------------------------------------------------------*/

   select nvl(calendar_code, 1)
   into p_cal_code
   from msc_plan_organizations
   where plan_id = p_plan_id
   and rownum = 1;

   /*------------------------------------------------------+
   | If Sysdate is a Saturday or Sunday move it to the   |
   | next workday.                                 |
   +-------------------------------------------------------*/

   if(p_cal_code = FIVE_DAY_WEEK) then

      if(day_of_week = 1) /* Sunday */
      then
         jul_first_date := jul_first_date + 1;
      elsif (day_of_week = 7) /* Saturday */
      then
         jul_first_date := jul_first_date + 2;
      end if;

   end if;


   curr_date := jul_first_date;

   assign_daily_buckets(p_plan_id,
                   p_org_id,
                   p_sr_instance_id,
                   jul_first_date,
                   p_daily_cutoff_bucket,
                   p_cal_code,
                   bkt_index,
                   curr_date
                   );


   assign_weekly_buckets(p_plan_id,
                    p_org_id,
                    p_sr_instance_id,
                    curr_date,
                    p_weekly_cutoff_bucket,
                    p_cal_code,
                    bkt_index,
                     curr_date);


   assign_monthly_buckets(p_plan_id,
                     p_org_id,
                     p_sr_instance_id,
                     curr_date,
                     p_cal_code,
                     p_mthly_cutoff_bucket,
                     bkt_index);
   commit;

-- added exception handler
exception when others then
          /* Bug # 4235511 */
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
   FND_LOG.STRING(FND_LOG.LEVEL_ERROR, 'MSC_EXCHANGE_BUCKETING.calculate_plan_buckets',SQLERRM);
           end if  ;
end calculate_plan_buckets;

PROCEDURE CALC_MONTHLY_NETTING_BKTS(p_cutoff_date    IN NUMBER,
                                    p_start_date     IN NUMBER,
		     p_supplier_id  in number,
		     p_supplier_site_id  in number,
		     p_customer_id  in number,
		     p_customer_site_id  in number,
                             p_item_id  in  number,
			     p_plan_type in number,
				    p_calendar_code  IN VARCHAR2,
				    p_sr_instance_id IN NUMBER)
IS
p_bkt_index NUMBER  := 0;

cursor c1 is
   select distinct to_number(to_char(PERIOD_START_DATE,'j')) PERIOD_START_DATE,
	  to_number(to_char(NEXT_DATE-1,'j'))   period_end_date
     from msc_period_start_dates
    where CALENDAR_CODE = p_calendar_code
      and SR_INSTANCE_ID = p_sr_instance_id
      and EXCEPTION_SET_ID = -1
      and (    ( PERIOD_START_DATE <= to_date(p_start_date,'j')
	     and NEXT_DATE-1 >= to_date(p_start_date,'j') )
       or      ( PERIOD_START_DATE >= to_date(p_start_date,'j')
	     and NEXT_DATE-1 <= to_date(p_cutoff_date,'j') )
       or      ( PERIOD_START_DATE <= to_date(p_cutoff_date,'j')
	     and NEXT_DATE-1 >= to_date(p_cutoff_date,'j') )
	     );
BEGIN

      FOR c_rec in c1 LOOP

      EXIT WHEN C1%NOTFOUND;
      p_bkt_index := p_bkt_index + 1;

        add_to_plan_buckets(-1,
                            -1,
                            -1,
                            p_bkt_index,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
                            1,
                            c_rec.PERIOD_START_DATE,
                            c_rec.period_end_date,
                            c_rec.period_end_date - c_rec.PERIOD_START_DATE + 1,
                            MONTH);

      END LOOP;

END CALC_MONTHLY_NETTING_BKTS;

PROCEDURE CALC_WEEKLY_NETTING_BKTS(p_cutoff_date   IN NUMBER,
                                   p_start_date     IN NUMBER,
		     p_supplier_id  in number,
		     p_supplier_site_id  in number,
		     p_customer_id  in number,
		     p_customer_site_id  in number,
                             p_item_id  in  number,
			     p_plan_type in number,
				   p_calendar_code  IN VARCHAR2,
				   p_sr_instance_id IN NUMBER)
IS
p_bkt_index NUMBER  := 0;
p_days_in_bkt NUMBER := 7;

cursor c1 is
   select distinct to_number(to_char(WEEK_START_DATE,'j')) week_start_date,
	  to_number(to_char(NEXT_DATE-1,'j'))   week_end_date
     from msc_cal_week_start_dates
    where CALENDAR_CODE = p_calendar_code
      and SR_INSTANCE_ID = p_sr_instance_id
      and EXCEPTION_SET_ID = -1
      and ( (WEEK_START_DATE <= to_date(p_start_date,'j')
             and NEXT_DATE-1 >= to_date(p_start_date,'j'))
       or   (WEEK_START_DATE >= to_date(p_start_date,'j')
	     and NEXT_DATE-1 <= to_date(p_cutoff_date,'j') )
       or   (WEEK_START_DATE <= to_date(p_cutoff_date,'j')
	     and NEXT_DATE-1 >= to_date(p_cutoff_date,'j') )
	     );

BEGIN

   --log_message(' Entered CALC_WEEKLY_NETTING_BKTS :' || p_cutoff_date || '- ' || p_calendar_code || '-' || p_sr_instance_id);
   --log_message('adding bucket : ' || c_rec.week_start_date ||' - '||c_rec.week_end_date);
      FOR c_rec in c1 LOOP

        exit when c1%NOTFOUND;
        p_bkt_index := p_bkt_index + 1;

        add_to_plan_buckets(-1,
                            -1,
                            -1,
                            p_bkt_index,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
                            1,
                            c_rec.week_start_date,
                            c_rec.week_end_date,
                            p_days_in_bkt,
                            WEEK);


      END LOOP;

END CALC_WEEKLY_NETTING_BKTS;



PROCEDURE CALC_DAILY_NETTING_BKTS(p_cutoff_date    IN NUMBER,
                                  p_start_date     IN NUMBER,
		     p_supplier_id  in number,
		     p_supplier_site_id  in number,
		     p_customer_id  in number,
		     p_customer_site_id  in number,
                             p_item_id  in  number,
			     p_plan_type in number,
				  p_calendar_code  IN VARCHAR2,
				  p_sr_instance_id IN NUMBER)
IS
l_start_date NUMBER := p_start_date;
p_end_date NUMBER := 0;
p_bkt_index NUMBER := 0;
p_days_in_bkt NUMBER := 1;
BEGIN

   LOOP
         exit when  (l_start_date > p_cutoff_date);

         p_end_date := l_start_date;

         p_bkt_index := p_bkt_index + 1;
         add_to_plan_buckets(-1,
                            -1,
                            -1,
                            p_bkt_index,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
                            1,
                            l_start_date,
                            p_end_date,
                            p_days_in_bkt,
                            DAY);
         l_start_date := l_start_date + 1;

   END LOOP;


END CALC_DAILY_NETTING_BKTS;

/*
PROCEDURE calc_mixed_bucket_dates(p_sr_instance_id IN NUMBER,
                          p_customer_id IN NUMBER,
                          p_customer_site_id IN NUMBER,
                          p_item_id IN NUMBER,
                          p_supplier_id IN NUMBER,
                          p_supplier_site_id IN NUMBER,
                          p_plan_type IN NUMBER,
                          p_cutoff_date IN NUMBER) IS
l_start_date NUMBER;
l_curr_date NUMBER;
l_cust_bkt_type NUMBER;
l_supp_bkt_type NUMBER;
l_curr_bkt_type NUMBER;
l_bkt_index NUMBER := 0;
l_bkt_start_date NUMBER;
l_bkt_end_date NUMBER;
l_days_in_bkt NUMBER;
BEGIN



  -----------------------------------------------------------------+
   | Will not start with sysdate
   | Will start with the begining of the month and keep
   | comparing dates to find the next bucket
   | user may see the past exception using this bucket info
   +--------------------------------------------------------

 made this change to resolve GSCC warnings
--   select to_number(to_char(to_date('1' ||'-' || to_char (sysdate ,'MON-YYYY')), 'j'))
   select to_number(to_char(sysdate,'j') )
   into l_start_date
   from dual;

   l_curr_date := l_start_date;

   loop
      if(l_curr_date > p_cutoff_date) then
         return;
      end if;


      BEGIN
      select nvl(max(bucket_type), NONE)
       into l_cust_bkt_type
       from
       msc_sup_dem_entries sd
       where plan_id = -1
      and    sd.sr_instance_id = p_sr_instance_id
       and   sd.publisher_id =p_customer_id
       and   sd.publisher_site_id = p_customer_site_id
       and   nvl(sd.base_item_id, sd.inventory_item_id) = p_item_id
       and   sd.publisher_order_type = DECODE(p_plan_type,
            SUPPLY_PLANNING, 2,
            DEMAND_PLANNING, 1)
       and   sd.supplier_id = p_supplier_id
       and   sd.supplier_site_id = p_supplier_site_id
      and    to_number(to_char(sd.key_date, 'j')) = l_curr_date;
      EXCEPTION WHEN NO_DATA_FOUND THEN
         l_cust_bkt_type := NONE;
      END;


      IF (p_plan_type = SUPPLY_PLANNING) THEN
        BEGIN
        	select nvl(max(bucket_type), NONE)
        	into l_supp_bkt_type
        	from
        	msc_sup_dem_entries sd
        	where sd.plan_id = -1
      		and sd.sr_instance_id = p_sr_instance_id
        	and sd.publisher_id = p_supplier_id
        	and sd.publisher_site_id = p_supplier_site_id
        	and sd.customer_id = p_customer_id
        	and sd.customer_site_id = p_customer_site_id
        	and nvl(sd.base_item_id, sd.inventory_item_id) = p_item_id
        	and sd.publisher_order_type  in (3,14)
      		and to_number(to_char(sd.key_date, 'j')) = l_curr_date;
        EXCEPTION WHEN NO_DATA_FOUND THEN
        	l_supp_bkt_type := NONE;
        END;

      ELSIF (p_plan_type = DEMAND_PLANNING) THEN
        BEGIN
        	select nvl(max(bucket_type), NONE)
        	into l_supp_bkt_type
        	from
        	msc_sup_dem_entries sd
        	where sd.plan_id = -1
      		and sd.sr_instance_id = p_sr_instance_id
        	and sd.publisher_id = p_supplier_id
        	and sd.publisher_site_id = p_supplier_site_id
        	and sd.customer_id = p_customer_id
        	and sd.customer_site_id = p_customer_site_id
        	and nvl(sd.base_item_id, sd.inventory_item_id) = p_item_id
        	and sd.publisher_order_type  = 1
      		and to_number(to_char(sd.key_date, 'j')) = l_curr_date;
        EXCEPTION WHEN NO_DATA_FOUND THEN
       	 	l_supp_bkt_type := NONE;
        END;
      END IF;

      if(l_cust_bkt_type > l_supp_bkt_type) then
         l_curr_bkt_type := l_cust_bkt_type;
      else
         l_curr_bkt_type := l_supp_bkt_type;

      end if;



      if (l_curr_bkt_type = NONE) then
         --------------------------+
         | No data exists. Move to   |
         | next bucket.          |
         +---------------------------
         l_curr_date := l_curr_date + 1;

      elsif (l_curr_bkt_type = DAY) then

         l_bkt_start_date := l_curr_date;
         l_bkt_end_date := l_curr_date;

        ----------------------------------+
         | Bucket is day. Create daily bucket|
         | and move to next bucket.       |
         +----------------------------------

         l_bkt_index := l_bkt_index + 1;
         l_days_in_bkt := 1;
            add_to_plan_buckets(-1,
                            -1,
                            -1,
                            l_bkt_index,
                            1,
                            l_bkt_start_date,
                            l_bkt_end_date,
                            l_days_in_bkt,
                            DAY);

         l_curr_date := l_curr_date + 1;


      elsif (l_curr_bkt_type = WEEK) then

            l_bkt_start_date := l_curr_date;
            l_bkt_end_date := l_curr_date + 6;

            ------------------------------------+
            | Bucket is Week. Create weekly bucket|
            | and move to next bucket.            |
            +--------------------------------------

            l_bkt_index := l_bkt_index + 1;
         l_days_in_bkt := 7;
            add_to_plan_buckets(-1,
                            -1,
                            -1,
                            l_bkt_index,
                            1,
                            l_bkt_start_date,
                            l_bkt_end_date,
                            l_days_in_bkt,
                            WEEK);

            l_curr_date := l_curr_date + 7;


         ----------------------------------------+
         | Need to add a check here that if a month|
         | starts before the week ends, create a   |
         | short bucket for this week and continue |
         + : SBALA              |
         +-----------------------------------------
      elsif (l_curr_bkt_type = MONTH) then


          l_bkt_start_date := l_curr_date;

          select to_number(to_char(last_day(to_date(l_curr_date, 'j')), 'j'))
             into
             l_bkt_end_date
             from dual;


         --------------------------------------+
            | Bucket is month. Create monthly bucket|
            | and move to next month .              |
            +---------------------------------------
            l_bkt_index := l_bkt_index + 1;

         add_to_plan_buckets(-1,
                            -1,
                            -1,
                            l_bkt_index,
                            1,
                            l_bkt_start_date,
                            l_bkt_end_date,
                            l_bkt_end_date - l_bkt_start_date + 1,
                            MONTH);

         l_curr_date := l_bkt_end_date + 1;
        end if;

   if(l_curr_date > p_cutoff_date) then
      return;

   end if;


end loop;

end;
*/
FUNCTION  data_exists (p_sr_instance_id    IN NUMBER,
                       p_customer_id       IN NUMBER,
                       p_customer_site_id  IN NUMBER,
                       p_item_id           IN NUMBER,
                       p_supplier_id       IN NUMBER,
                       p_supplier_site_id  IN NUMBER,
                       p_plan_type         IN NUMBER,
                       p_bucket_type       IN NUMBER,
		       p_start_date        IN NUMBER,
		       p_end_date          IN NUMBER)
   RETURN NUMBER IS

lv_data_exists  number := 2;

CURSOR sup_planning IS
             select 1
	       from msc_sup_dem_entries sd
	      where sd.plan_id = -1
	        and sd.sr_instance_id = p_sr_instance_id
	        and sd.publisher_id = p_supplier_id
	        and sd.publisher_site_id = p_supplier_site_id
	        and sd.customer_id = p_customer_id
	        and sd.customer_site_id = p_customer_site_id
	        and nvl(sd.base_item_id, sd.inventory_item_id) = p_item_id
	        and sd.publisher_order_type  in (G_SUPPLY_COMMIT,G_SALES_ORDER)
	        and nvl(bucket_type,0) = p_bucket_type
	        and to_number(to_char(sd.key_date, 'j')) between p_start_date and p_end_date
	        and rownum = 1
          UNION
             select 1
               from msc_sup_dem_entries sd
              where sd.plan_id = -1
                and sd.sr_instance_id = p_sr_instance_id
                and sd.publisher_id = p_customer_id
                and sd.publisher_site_id = p_customer_site_id
                and sd.supplier_id = p_supplier_id
                and sd.supplier_site_id = p_supplier_site_id
                and nvl(sd.base_item_id,sd.inventory_item_id) = p_item_id
                and sd.publisher_order_type = G_ORDER_FORECAST
                and nvl(bucket_type,0) = p_bucket_type
                and to_number(to_char(sd.key_date, 'j')) between p_start_date and p_end_date
                and rownum = 1;

CURSOR dem_planning IS
     select 1
       from msc_sup_dem_entries sd
      where sd.plan_id = -1
	and sd.sr_instance_id = p_sr_instance_id
	and sd.publisher_id = p_supplier_id
	and sd.publisher_site_id = p_supplier_site_id
	and sd.customer_id = p_customer_id
	and sd.customer_site_id = p_customer_site_id
	and nvl(sd.base_item_id, sd.inventory_item_id) = p_item_id
	and sd.publisher_order_type  = G_SALES_FORECAST
	and nvl(bucket_type,0) = p_bucket_type
	and to_number(to_char(sd.key_date, 'j')) between p_start_date and p_end_date
	and rownum = 1
  UNION
     select 1
       from msc_sup_dem_entries sd
      where sd.plan_id = -1
	and sd.sr_instance_id = p_sr_instance_id
	and sd.publisher_id = p_customer_id
	and sd.publisher_site_id = p_customer_site_id
	and sd.supplier_id = p_supplier_id
	and sd.supplier_site_id = p_supplier_site_id
	and nvl(sd.base_item_id, sd.inventory_item_id) = p_item_id
	and sd.publisher_order_type = G_SALES_FORECAST
	and nvl(bucket_type,0) = p_bucket_type
	and to_number(to_char(sd.key_date, 'j')) between p_start_date and p_end_date
	and rownum = 1;


BEGIN

    IF (p_plan_type = SUPPLY_PLANNING) THEN

		BEGIN
		   open sup_planning;
		   fetch sup_planning into lv_data_exists;
		   close sup_planning;

		EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			lv_data_exists := 2;
		END;

    ELSIF (p_plan_type = DEMAND_PLANNING) THEN

		BEGIN
		   open dem_planning;
		   fetch dem_planning into lv_data_exists;
		   close dem_planning;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			    lv_data_exists := 2;
		END;

    END IF;    ---- plan_type

 RETURN  lv_data_exists;

EXCEPTION
      WHEN OTHERS THEN
	  LOG_MESSAGE('An error occured in the function DATA_EXISTS in Bucketing : '||SQLERRM);
          RAISE;

END data_exists;


PROCEDURE calc_calendar_mixed_buckets(p_sr_instance_id    IN NUMBER,
                                p_customer_id       IN NUMBER,
                                p_customer_site_id  IN NUMBER,
                                p_item_id           IN NUMBER,
                                p_supplier_id       IN NUMBER,
                                p_supplier_site_id  IN NUMBER,
                                p_plan_type         IN NUMBER,
                                p_cutoff_date       IN NUMBER,
				p_calendar_code     IN VARCHAR2,
				p_instance_id       IN NUMBER) IS

l_start_date               NUMBER;
l_curr_date                NUMBER;
l_cust_bkt_type            NUMBER;
l_supp_bkt_type            NUMBER;
l_curr_bkt_type            NUMBER;
l_bkt_index                NUMBER := 0;
l_bkt_start_date           NUMBER;
l_bkt_end_date             NUMBER;
l_days_in_bkt              NUMBER;

lv_m_start_date            NUMBER;
lv_m_end_date              NUMBER;
month_data_exists          NUMBER;

lv_w_start_date            NUMBER;
lv_w_end_date              NUMBER;
week_data_exists           NUMBER;

lv_d_start_date            NUMBER;
lv_d_end_date              NUMBER;
day_data_exists            NUMBER;

week_in_month_data_exists  NUMBER;
day_in_month_data_exists   NUMBER;
day_in_week_data_exists    NUMBER;

CURSOR c1(p_m_start_date in NUMBER,
	  p_m_end_date   in NUMBER,
	  pCutoff_date   in NUMBER,
	  p_plan_type    in NUMBER)  is
select to_number(to_char(sd.key_date, 'j')) key_date
  from msc_sup_dem_entries sd
 where sd.plan_id = -1
   and sd.sr_instance_id = p_sr_instance_id
   and sd.publisher_id = p_supplier_id
   and sd.publisher_site_id = p_supplier_site_id
   and sd.customer_id = p_customer_id
   and sd.customer_site_id = p_customer_site_id
   and nvl(sd.base_item_id,sd.inventory_item_id) = p_item_id
   and sd.publisher_order_type in (G_SUPPLY_COMMIT,G_SALES_ORDER)
   and nvl(bucket_type,0) = DAY
   and to_number(to_char(sd.key_date, 'j'))
		between p_m_start_date and  p_m_end_date
   and to_number(to_char(sd.key_date, 'j')) <= pCutoff_date
   and p_plan_type = SUPPLY_PLANNING
UNION
select to_number(to_char(sd.key_date, 'j')) key_date
  from msc_sup_dem_entries sd
 where sd.plan_id = -1
   and sd.sr_instance_id = p_sr_instance_id
   and sd.publisher_id = p_customer_id
   and sd.publisher_site_id = p_customer_site_id
   and sd.supplier_id = p_supplier_id
   and sd.supplier_site_id = p_supplier_site_id
   and nvl(sd.base_item_id,sd.inventory_item_id) = p_item_id
   and sd.publisher_order_type = G_ORDER_FORECAST
   and nvl(bucket_type,0) = DAY
   and to_number(to_char(sd.key_date, 'j'))
		between p_m_start_date and p_m_end_date
   and to_number(to_char(sd.key_date, 'j')) <= pCutoff_date
   and p_plan_type = SUPPLY_PLANNING
UNION
select to_number(to_char(sd.key_date, 'j')) key_date
  from msc_sup_dem_entries sd
 where sd.plan_id = -1
   and sd.sr_instance_id = p_sr_instance_id
   and sd.publisher_id = p_supplier_id
   and sd.publisher_site_id = p_supplier_site_id
   and sd.customer_id = p_customer_id
   and sd.customer_site_id = p_customer_site_id
   and nvl(sd.base_item_id,sd.inventory_item_id) = p_item_id
   and sd.publisher_order_type  = G_SALES_FORECAST
   and nvl(bucket_type,0) = DAY
   and to_number(to_char(sd.key_date, 'j'))
		between p_m_start_date and p_m_end_date
   and to_number(to_char(sd.key_date, 'j')) <= pCutoff_date
   and p_plan_type = DEMAND_PLANNING
UNION
select to_number(to_char(sd.key_date, 'j')) key_date
  from msc_sup_dem_entries sd
 where sd.plan_id = -1
   and sd.sr_instance_id = p_sr_instance_id
   and sd.publisher_id = p_customer_id
   and sd.publisher_site_id = p_customer_site_id
   and sd.supplier_id = p_supplier_id
   and sd.supplier_site_id = p_supplier_site_id
   and nvl(sd.base_item_id, sd.inventory_item_id) = p_item_id
   and sd.publisher_order_type = G_SALES_FORECAST
   and nvl(bucket_type,0) = DAY
   and to_number(to_char(sd.key_date, 'j'))
		between p_m_start_date and p_m_end_date
   and to_number(to_char(sd.key_date, 'j')) <= pCutoff_date
   and p_plan_type = DEMAND_PLANNING
   ;


BEGIN

 --LOG_MESSAGE(' Calendar =  :'||p_calendar_code);
 --LOG_MESSAGE(' Source Instance Id : '||p_instance_id);

                 /* start with the sysdate */
 l_curr_date :=  TO_NUMBER(TO_CHAR(sysdate,'J') );

 LOOP
	        /* if the cutoff date is reached; then exit the procedure */
	IF (l_curr_date > p_cutoff_date) then
           EXIT;
        ELSE
	   l_curr_date := LEAST(l_curr_date,p_cutoff_date);
        END IF;

        LOG_MESSAGE(' *********************************************************');
	LOG_MESSAGE(' Current Date : '||l_curr_date);

	    /* get the period start and end dates  */
	select to_number(to_char(PERIOD_START_DATE,'J') ),
	       to_number(to_char(NEXT_DATE-1,'J') )
	  into lv_m_start_date ,
	       lv_m_end_date
	  from MSC_PERIOD_START_DATES
	 where SR_INSTANCE_ID = p_instance_id
	   and CALENDAR_CODE = p_calendar_code
	   and EXCEPTION_SET_ID = -1
	   and l_curr_date between to_number(to_char(PERIOD_START_DATE,'J'))
			       and to_number(to_char(NEXT_DATE-1,'J'));

        LOG_MESSAGE(' PERIOD start dates: '|| lv_m_start_date || '-' || lv_m_end_date );

           /* check if the Monthly data exists between the period of l_curr_date */
	month_data_exists :=  data_exists(p_sr_instance_id    ,
					  p_customer_id       ,
					  p_customer_site_id  ,
					  p_item_id           ,
					  p_supplier_id       ,
					  p_supplier_site_id  ,
					  p_plan_type         ,
					  MONTH               ,
					  lv_m_start_date     ,
					  lv_m_end_date       );

  IF (month_data_exists = SYS_YES) THEN

		    /*--------------------------------------------------------------+
                    |  If monthly data exists then create the monthly bucket        |
		    +--------------------------------------------------------------*/
		LOG_MESSAGE(' ######## MONTHLY DATA EXISTS FOR    : '
				     || lv_m_start_date || '-' || lv_m_end_date);

		  l_bkt_start_date := lv_m_start_date;
		  l_bkt_end_date   := lv_m_end_date;

		    /*--------------------------------------------------------------+
		    | Bucket is month. Create monthly bucket and move to next month |
		    +--------------------------------------------------------------*/
		  l_bkt_index := l_bkt_index + 1;

		  add_to_plan_buckets(-1,
				      -1,
				      -1,
				      l_bkt_index,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
				      1,
				      l_bkt_start_date,
				      l_bkt_end_date,
				      l_bkt_end_date - l_bkt_start_date + 1,
				      MONTH);

		    /*  move to the next month  */
		  l_curr_date := l_bkt_end_date + 1;

   ELSIF (month_data_exists = SYS_NO) THEN          --- monthly data does not exists

	        LOG_MESSAGE(' ######## MONTHLY DATA DOES NOT  EXISTS FOR    : '
		                    || lv_m_start_date || '-' || lv_m_end_date);

                           /* check if weekly data exists in the month  */
		week_in_month_data_exists := data_exists(p_sr_instance_id    ,
					        p_customer_id       ,
					        p_customer_site_id  ,
					        p_item_id           ,
					        p_supplier_id       ,
					        p_supplier_site_id  ,
					        p_plan_type         ,
					        WEEK                ,
					        lv_m_start_date      ,
					        lv_m_end_date        );

                if (week_in_month_data_exists = SYS_YES) then
	           LOG_MESSAGE(' @@@@@@@ WEEKLY data EXISTS in Month : '
					|| lv_m_start_date || '--' || lv_m_end_date);
		else
	           LOG_MESSAGE(' @@@@@@@ WEEKLY data DOES NOT EXISTS in Month : '
				        ||lv_m_start_date || '--' || lv_m_end_date);
	        end if;

                           /* check if Daily data exists in the month  */
		day_in_month_data_exists := data_exists(p_sr_instance_id    ,
					        p_customer_id       ,
					        p_customer_site_id  ,
					        p_item_id           ,
					        p_supplier_id       ,
					        p_supplier_site_id  ,
					        p_plan_type         ,
					        DAY,
					        lv_m_start_date      ,
					        lv_m_end_date        );

                if (day_in_month_data_exists = SYS_YES) then
	            LOG_MESSAGE(' %%%%%%% Daily data EXISTS in Month : '
					  || lv_m_start_date || '--' || lv_m_end_date);
	        else
	            LOG_MESSAGE(' %%%%%%% DAILY data DOES NOT EXISTS in Month : '
					  || lv_m_start_date || '--' || lv_m_end_date);
	        end if;

        IF (week_in_month_data_exists = SYS_YES) THEN

	   LOOP               --- loop through the week within the month

	            -- if the cutoff date is reached then exit the program
		IF (l_curr_date > p_cutoff_date) then
		   EXIT;
	        ELSE
		   l_curr_date := LEAST(l_curr_date,p_cutoff_date);
		END IF;

                    -- exit from the Weekly loop when next month is reached
		EXIT WHEN (l_curr_date > lv_m_end_date);

                    -- get the Week start and end dates
		select to_number(to_char(WEEK_START_DATE,'J') ) ,
		       to_number(to_char(NEXT_DATE-1,'J') )
		into   lv_w_start_date,
		       lv_w_end_date
		from   MSC_CAL_WEEK_START_DATES
		where  SR_INSTANCE_ID = p_instance_id
		and    CALENDAR_CODE = p_calendar_code
		and    EXCEPTION_SET_ID = -1
		and    l_curr_date between to_number(to_char(WEEK_START_DATE,'J'))
				       and to_number(to_char(NEXT_DATE-1,'J'));

                           /* check if Weekly data exists in the week of l_curr_date */
		week_data_exists := data_exists(p_sr_instance_id    ,
						p_customer_id       ,
					        p_customer_site_id  ,
						p_item_id           ,
						p_supplier_id       ,
						p_supplier_site_id  ,
						p_plan_type         ,
						WEEK                ,
						lv_w_start_date     ,
						lv_w_end_date       );

                IF (week_data_exists = SYS_YES) THEN

	                  LOG_MESSAGE(' Weekly data exists in Week : '
				|| lv_w_start_date || '--' || lv_w_end_date);
			  l_bkt_start_date := lv_w_start_date;
			  l_bkt_end_date := lv_w_end_date;

			   /*------------------------------------------------------------------+
			   | Bucket is week. Create Weekly bucket and then move to next week   |
			   +------------------------------------------------------------------*/
			  l_bkt_index := l_bkt_index + 1;
			  l_days_in_bkt := 7;

			  add_to_plan_buckets(-1,
					      -1,
					      -1,
					      l_bkt_index,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
					      1,
					      l_bkt_start_date,
					      l_bkt_end_date,
					      l_days_in_bkt,
					      WEEK);

			  l_curr_date := l_bkt_end_date + 1;
		 ELSE
			   /* there is no weekly data in the week of l_curr_date,
			      check for daily data in the month -- this is added for performance */
	                LOG_MESSAGE(' Weekly data DOES NOT exists in Week : '
					 || lv_w_start_date || '--' || lv_w_end_date);

                              /* This check that day data exists in month is for performance */
			if (day_in_month_data_exists = SYS_YES) then

				day_in_week_data_exists := data_exists(p_sr_instance_id    ,
								p_customer_id       ,
								p_customer_site_id  ,
								p_item_id           ,
								p_supplier_id       ,
								p_supplier_site_id  ,
								p_plan_type         ,
								DAY                ,
								lv_w_start_date      ,
								lv_w_end_date        );

			               /* check for daily data in the week */
			  IF (day_in_week_data_exists = SYS_YES) then

			        LOG_MESSAGE(' Daily data exists in Week: '
					  || lv_w_start_date || '--' || lv_w_end_date);

					       /* daily data exists in the week,
						loop through all the days in the week */

				FOR c_rec in c1(lv_w_start_date, lv_w_end_date
						, least(p_cutoff_date,lv_w_end_date,lv_m_end_date)
						,p_plan_type)
				    LOOP
					/* loop through all the daily bucket data
					   in the week and create daily buckets */

					l_curr_date := c_rec.key_date;

					LOG_MESSAGE('Daily bucket: '||l_curr_date);

					  l_bkt_start_date := l_curr_date;
					  l_bkt_end_date   := l_curr_date;

					    /*---------------------+
					    |  Create Daily bucket |
					    +---------------------*/
					  l_bkt_index := l_bkt_index + 1;
					  l_days_in_bkt := 1;

					  add_to_plan_buckets(-1,
							      -1,
							      -1,
							      l_bkt_index,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
							      1,
							      l_bkt_start_date,
							      l_bkt_end_date,
							      l_days_in_bkt,
							      DAY);

				     END LOOP;   --- loop for the days within the week

				l_curr_date := l_curr_date + 7;

			   ELSE       --- else part of day_in_week data exists

				l_curr_date := l_curr_date + 7;
			        LOG_MESSAGE('No daily data exists between week : '
					      || lv_w_start_date ||'-'||lv_w_end_date);

			   END IF;   --- day_in_week data exists

			else
			       /* No daily bucket data exists in the month -- so go to next week */
			   LOG_MESSAGE('No daily data exists between month : ' ||
					   lv_m_start_date ||'-'||lv_m_end_date ||
					   '---- week' || lv_w_start_date ||'-'||lv_w_end_date);
			  l_curr_date := l_curr_date + 7;

		       end if;     ---- day_in_month data exists

               END IF;  --- week data exists

	   END LOOP;   ---- loop for the week within a month


        ELSIF (day_in_month_data_exists = SYS_YES) THEN

		/* only daily bucket data exists within the period  */

                lv_m_end_date := LEAST(lv_m_end_date,p_cutoff_date);
		LOG_MESSAGE('Month start date: ' || lv_m_start_date
			    ||'- Month End date: '||lv_m_end_date);

		FOR c_rec in c1(lv_m_start_date, lv_m_end_date
			       , p_cutoff_date ,p_plan_type)
		       LOOP
			   /* loop through all the daily bucket data
			   in the month and create daily buckets */

			l_curr_date := c_rec.key_date;

		       	LOG_MESSAGE('Daily bucket: '||l_curr_date);

		        l_bkt_start_date := l_curr_date;
		        l_bkt_end_date   := l_curr_date;

			/*---------------------+
			|  Create Daily bucket |
			+---------------------*/
			l_bkt_index := l_bkt_index + 1;
			l_days_in_bkt := 1;

			add_to_plan_buckets(-1,
				            -1,
					    -1,
					    l_bkt_index,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
					    1,
					    l_bkt_start_date,
					    l_bkt_end_date,
					    l_days_in_bkt,
					    DAY);

		END LOOP;   --- loop for the days within the month

		l_curr_date := lv_m_end_date + 1; --- go to next month

        ELSE
		  /* NO Weekly/daily bucket data  exists within the period  */
		l_curr_date := lv_m_end_date + 1; --- go to next month
		LOG_MESSAGE(' lv_m_end_date : '||lv_m_end_date);
	END IF;

   END IF;    --- month_data_exists or not

 END LOOP;       -- main loop for Months

EXCEPTION
  WHEN OTHERS THEN
      LOG_MESSAGE(SQLCODE);
      LOG_MESSAGE(SQLERRM);
      RAISE;

END calc_calendar_mixed_buckets;

PROCEDURE CALCULATE_NETTING_BUCKET(
            p_sr_instance_id IN NUMBER,
                p_customer_id IN NUMBER,
                p_customer_site_id IN NUMBER,
                p_supplier_id IN NUMBER,
                p_supplier_site_id IN NUMBER,
                p_item_id IN NUMBER,
                p_plan_type IN NUMBER,
            p_cutoff_ref_num IN OUT NOCOPY NUMBER)

IS
l_cust_bucket_type   NUMBER := 0;
l_supp_bucket_type   NUMBER := 0;
l_max_receipt_cust   date;
l_max_receipt_supp   date;
l_max_cust     NUMBER := 0;
l_max_supp     NUMBER := 0;
l_max_ref_cust       NUMBER := 0;
l_max_ref_supp       NUMBER := 0;
p_cutoff_date     NUMBER;
p_start_date     NUMBER;

lv_calendar_code    varchar2(14);
lv_instance_id      number;
l_min_receipt_cust   date;
l_min_receipt_supp   date;
l_min_cust     NUMBER := 0;
l_min_supp     NUMBER := 0;

l_customer_name		msc_companies.company_name%type;
l_customer_site_name 	msc_company_sites.company_site_name%type;
l_supplier_name		msc_companies.company_name%type;
l_supplier_site_name	msc_company_sites.company_site_name%type;

BEGIN
 log_message(' p_sr_instance_id : ' || p_sr_instance_id);
 log_message(' p_customer_id : ' || p_customer_id);
 log_message(' p_customer_site_id : ' || p_customer_site_id);
 log_message(' p_supplier_id : ' || p_supplier_id);
 log_message(' p_supplier_site_id : ' || p_supplier_site_id);
 log_message(' p_item_id : ' || p_item_id);
 log_message(' p_cutoff_ref_num : ' || p_cutoff_ref_num);



 /*-------------------------------------------------------------
  Print out the calendar to log for the exception.
  --------------------------------------------------------------*/
/*
  select c1.company_name, c2.company_site_name
  into	l_supplier_name, l_supplier_site_name
  from	msc_companies c1, msc_company_sites c2
  where	c1.company_id = p_supplier_id
  and	c1.company_id = c2.company_id
  and	c2.company_site_id = p_supplier_site_id;

  select c1.company_name, c2.company_site_name
  into	l_customer_name, l_customer_site_name
  from	msc_companies c1, msc_company_sites c2
  where	c1.company_id = p_customer_id
  and	c1.company_id = c2.company_id
  and	c2.company_site_id = p_customer_site_id;

  FND_FILE.PUT_LINE( FND_FILE.LOG, 'Calendar code ' || lv_calendar_code || ' for Supplier: ' || l_supplier_name || ' ' ||
  	l_supplier_site_name || ' and Customer: ' || l_customer_name || ' ' || l_customer_site_name);
 */
   /*------------------------------------------------------+
   | Delete the previous set of data from msc_plan_buckets |
   +-------------------------------------------------------*/

   --delete msc_plan_buckets
   --where plan_id = -1;


   /*----------------------------------------------+
   | Get the maximum value of the refresh number   |
   | The refresh number will           |
   | be used to ignore new data loaded after the   |
   | bucketing has been done for this item/cust/   |
   | supplier combination           |
   | The SQL is used different order types for  |
   | supply and demand planning        |
   +-----------------------------------------------*/

   /*----------------------------------------------+
   | Also Get the maximum value of the receipt date|
   | The receipt date will be used to determine the
   | bucket end date
   +-----------------------------------------------*/

/*		l_max_ref_cust := p_cust_max_rn;
		l_max_receipt_cust := p_cust_max_key_date;
		l_min_receipt_cust := p_cust_min_key_date;

   	      l_max_ref_supp := p_supp_max_rn;
	      l_max_receipt_supp := p_supp_max_key_date;
	      l_min_receipt_supp := p_supp_min_key_date;

*/

   BEGIN
      select nvl(max(sd.last_refresh_number), -1), max(sd.key_date),min(sd.key_date)
      into l_max_ref_cust, l_max_receipt_cust, l_min_receipt_cust
      from
      msc_sup_dem_entries sd
      where sd.plan_id = -1
      and sd.sr_instance_id = p_sr_instance_id
      and   sd.publisher_id =p_customer_id
         and   sd.publisher_site_id = p_customer_site_id
      and   nvl(sd.base_item_id, sd.inventory_item_id) = p_item_id
      and   sd.publisher_order_type = DECODE(p_plan_type,
                                              SUPPLY_PLANNING, 2,
                                              DEMAND_PLANNING, 1)
      and   sd.supplier_id = p_supplier_id
           and   sd.supplier_site_id = p_supplier_site_id;
   EXCEPTION WHEN NO_DATA_FOUND then
      l_max_ref_cust := -1;
      l_max_cust := 0;
   END;

    /*
    log_message('l_max_ref_cust :' || l_max_ref_cust);
    log_message('l_max_cust :' || l_max_cust);
    log_message('l_max_receipt_cust :' || l_max_receipt_cust);
    */

   IF (p_plan_type = SUPPLY_PLANNING) THEN
   	BEGIN
   	   select nvl(max(sd.last_refresh_number), -1),
	   max(sd.key_date),min(sd.key_date)
   	      into l_max_ref_supp, l_max_receipt_supp,l_min_receipt_supp
   	      from
   	      msc_sup_dem_entries sd
   	      where
   	      sd.plan_id = -1
   	    and  sd.sr_instance_id = p_sr_instance_id
   	      and sd.publisher_id = p_supplier_id
   	      and sd.publisher_site_id = p_supplier_site_id
   	      and sd.customer_id = p_customer_id
   	   and sd.customer_site_id = p_customer_site_id
   	   and nvl(sd.base_item_id,sd.inventory_item_id) = p_item_id
   	   and sd.publisher_order_type in (3,14);
   	EXCEPTION WHEN NO_DATA_FOUND THEN
    	  l_max_ref_supp := -1;
    	  l_max_supp := 0;
   	END;
   ELSIF (p_plan_type = DEMAND_PLANNING) THEN
	   delete msc_plan_buckets
	   where plan_id = -1;
   	BEGIN
   	   select nvl(max(sd.last_refresh_number), -1),
	   max(sd.key_date),min(sd.key_date)
   	      into l_max_ref_supp, l_max_receipt_supp,l_min_receipt_supp
   	      from
   	      msc_sup_dem_entries sd
   	      where
   	      sd.plan_id = -1
   	    and  sd.sr_instance_id = p_sr_instance_id
   	      and sd.publisher_id = p_supplier_id
   	      and sd.publisher_site_id = p_supplier_site_id
   	      and sd.customer_id = p_customer_id
   	   and sd.customer_site_id = p_customer_site_id
   	   and nvl(sd.base_item_id, sd.inventory_item_id) = p_item_id
   	   and sd.publisher_order_type = 1;
        EXCEPTION WHEN NO_DATA_FOUND THEN
   	   l_max_ref_supp := -1;
   	   l_max_supp := 0;
   	END;
   END IF;

   /*
    log_message('l_max_ref_supp :' || l_max_ref_supp);
    log_message('l_max_receipt_supp :' || l_max_receipt_supp);
    log_message('l_max_supp :' || l_max_supp);
   */

   if(l_max_ref_cust > l_max_ref_supp) then
          p_cutoff_ref_num := l_max_ref_cust;
   else
          p_cutoff_ref_num := l_max_ref_supp;
   end if;

   /*-------------------------------------------------------------------
     | There is no bucket at all, return and the
     | cutoff_ref_num back to -1; therefore, no need to query
     | supply/demand in the netting engine
     -----------------------------------------------------------------*/
   IF (l_max_receipt_cust is null or l_max_receipt_supp is null) THEN
      p_cutoff_ref_num  := -1;
      return;
   END IF;

      /* Call the API to get the correct Calendar */
     msc_x_util.get_calendar_code(
			 p_supplier_id,
			 p_supplier_site_id,
			 p_customer_id,
			 p_customer_site_id,
			 lv_calendar_code,
			 lv_instance_id);
     --log_message(' Calendar used: ' || lv_calendar_code);
     log_message(' Source instance id : ' || lv_instance_id);

   --bug# 2343118, need to initial the l_max_supp and l_max_cust
   l_max_supp := to_number(to_char(l_max_receipt_supp,'j'));
   l_max_cust := to_number(to_char(l_max_receipt_cust,'j'));

   IF (l_max_receipt_cust is null) then
      l_max_cust := 0 ;
   end if;
   IF (l_max_receipt_supp is null) then
      l_max_supp := 0;
   end if;

   IF (l_max_cust > l_max_supp) then
      p_cutoff_date := l_max_cust;
   ELSE
      p_cutoff_date := l_max_supp;
   END IF;

   l_min_supp := to_number(to_char(nvl(l_min_receipt_supp,sysdate),'j'));
   l_min_cust := to_number(to_char(nvl(l_min_receipt_cust,sysdate),'j'));

   IF (l_min_supp < l_min_cust) then
      p_start_date := l_min_supp;
   ELSE
      p_start_date := l_min_cust;
   END IF;

   LOG_MESSAGE('START DATE = ' || p_start_date );
   LOG_MESSAGE('CUTOFF DATE = ' || p_cutoff_date );

   /*----------------------------------------------+
   | Get the distinct bucket types for data        |
   | posted by customer             |
   | If more than one bucket type is present then  |
   | this implies that the bucket type is MIXED.   |
   +-----------------------------------------------*/

   BEGIN
   select distinct bucket_type
   into l_cust_bucket_type
   from msc_sup_dem_entries sd
   where sd.plan_id = -1
   and   sd.sr_instance_id = p_sr_instance_id
   and   sd.publisher_id =p_customer_id
   and   sd.publisher_site_id = p_customer_site_id
   and   nvl(sd.base_item_id, sd.inventory_item_id) = p_item_id
   and   sd.publisher_order_type = DECODE(p_plan_type,
         SUPPLY_PLANNING, 2,
         DEMAND_PLANNING, 1)
   and   sd.supplier_id = p_supplier_id
   and   sd.supplier_site_id = p_supplier_site_id;
   EXCEPTION WHEN TOO_MANY_ROWS THEN
         l_cust_bucket_type := MIXED;
         WHEN NO_DATA_FOUND THEN
         l_cust_bucket_type := NONE;
   END;

  log_message('l_cust_bucket_type : '||l_cust_bucket_type);

   if(l_cust_bucket_type = MIXED) /* mixed bucket types */
   then
           calc_calendar_mixed_buckets( p_sr_instance_id,
                                  p_customer_id,
                                  p_customer_site_id,
                                  p_item_id,
                                  p_supplier_id,
                                  p_supplier_site_id,
                                  p_plan_type,
                                  p_cutoff_date,
			          lv_calendar_code,
			          lv_instance_id);

   else

      /*--------------------------------------+
      | Get the distinct bucket type for the  |
      | suppliers data. The where clause for  |
      | the select here depends on the plan   |
      +---------------------------------------*/
      IF (p_plan_type = SUPPLY_PLANNING) THEN

      	BEGIN
      	   select distinct bucket_type into l_supp_bucket_type
      	   from msc_sup_dem_entries sd
      	   where sd.plan_id = -1
      	   and sd.sr_instance_id = p_sr_instance_id
      	   and sd.publisher_id = p_supplier_id
      	   and sd.publisher_site_id = p_supplier_site_id
      	   and sd.customer_id = p_customer_id
      	   and sd.customer_site_id = p_customer_site_id
      	   and nvl(sd.base_item_id, sd.inventory_item_id) = p_item_id
      	   and sd.publisher_order_type in (3,14);

         EXCEPTION WHEN TOO_MANY_ROWS THEN
            l_supp_bucket_type := MIXED;
                 WHEN NO_DATA_FOUND THEN
            l_supp_bucket_type := NONE;
      	END;
      ELSIF (p_plan_type = DEMAND_PLANNING) THEN
        BEGIN
      	   select distinct bucket_type into l_supp_bucket_type
      	   from msc_sup_dem_entries sd
      	   where sd.plan_id = -1
      	   and sd.sr_instance_id = p_sr_instance_id
      	   and sd.publisher_id = p_supplier_id
      	   and sd.publisher_site_id = p_supplier_site_id
      	   and sd.customer_id = p_customer_id
      	   and sd.customer_site_id = p_customer_site_id
      	   and nvl(sd.base_item_id, sd.inventory_item_id) = p_item_id
      	   and sd.publisher_order_type = 1;

         EXCEPTION WHEN TOO_MANY_ROWS THEN
            l_supp_bucket_type := MIXED;
                 WHEN NO_DATA_FOUND THEN
            l_supp_bucket_type := NONE;
      	END;
     END IF;

  log_message('l_supp_bucket_type : '||l_supp_bucket_type);
      if(l_supp_bucket_type = MIXED) /* mixed bucket types */
      then

               calc_calendar_mixed_buckets(
                             p_sr_instance_id,
                             p_customer_id,
                             p_customer_site_id,
                             p_item_id,
                             p_supplier_id,
                             p_supplier_site_id,
                             p_plan_type,
                             p_cutoff_date,
			     lv_calendar_code,
			     lv_instance_id);


      else
      /*-------------------------------------------------------+
       | If the customer and supplier have different bucket     |
       | types this also implies that the data has mixed        |
       | bucket types. The only exception to this case is when |
       | either customer or supplier data is not there       |
       | In that case  we generate using the other party's data|
       +-------------------------------------------------------*/

       if(l_supp_bucket_type <> l_cust_bucket_type) then

         if((l_supp_bucket_type <> NONE) and
            (l_cust_bucket_type <> NONE)) then

            calc_calendar_mixed_buckets(
                                  p_sr_instance_id,
                                  p_customer_id,
                                  p_customer_site_id,
                                  p_item_id,
                                  p_supplier_id,
                                  p_supplier_site_id,
                                  p_plan_type,
                                  p_cutoff_date,
				  lv_calendar_code,
			          lv_instance_id);

         elsif (l_supp_bucket_type = NONE) then
               if(l_cust_bucket_type = DAY) then
                     calc_daily_netting_bkts(p_cutoff_date,
					     p_start_date,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
					     lv_calendar_code,
					     lv_instance_id);
               elsif(l_cust_bucket_type = WEEK) then
                     calc_weekly_netting_bkts(p_cutoff_date,
					      p_start_date,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
					      lv_calendar_code,
					      lv_instance_id);
               elsif(l_cust_bucket_type = MONTH) then
                     calc_monthly_netting_bkts(p_cutoff_date,
					       p_start_date,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
					       lv_calendar_code,
					       lv_instance_id);
               end if;
         elsif (l_cust_bucket_type = NONE) then
               if(l_supp_bucket_type = DAY) then
                     calc_daily_netting_bkts(p_cutoff_date,
					     p_start_date,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
					     lv_calendar_code,
					     lv_instance_id);
               elsif(l_supp_bucket_type = WEEK) then
                     calc_weekly_netting_bkts(p_cutoff_date,
					      p_start_date,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
					      lv_calendar_code,
					      lv_instance_id);
               elsif(l_supp_bucket_type = MONTH) then
                     calc_monthly_netting_bkts(p_cutoff_date,
					       p_start_date,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
					       lv_calendar_code,
					       lv_instance_id);
               end if;

         end if;


       else  /* Bucket Types are equal and not null */
            if(l_supp_bucket_type = DAY) then
               calc_daily_netting_bkts(p_cutoff_date,
				       p_start_date,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
				       lv_calendar_code,
				       lv_instance_id);
            elsif(l_supp_bucket_type = WEEK) then
               calc_weekly_netting_bkts(p_cutoff_date,
					p_start_date,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
					lv_calendar_code,
					lv_instance_id);
            elsif(l_supp_bucket_type = MONTH) then
               calc_monthly_netting_bkts(p_cutoff_date,
					 p_start_date,
		     p_supplier_id,
		     p_supplier_site_id,
		     p_customer_id,
		     p_customer_site_id,
                             p_item_id,
			     p_plan_type,
					 lv_calendar_code,
					 lv_instance_id);
            end if;

      end if; /* end if for bucket types not equal */



   end if;  /* end if for supp bucket type not mixed */

end if;  /* end if for cust bucket type is mixed */

-- added exception handler
EXCEPTION WHEN OTHERS THEN
         /* Bug 4235511 */
            if( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error in MSC_EXCHANGE_BUCKETING.CALCULATE_NETTING_BUCKET ' || sqlerrm);
   FND_LOG.STRING(FND_LOG.LEVEL_ERROR,'MSC_EXCHANGE_BUCKETING.CALCULATE_NETTING_BUCKET',SQLERRM);
           end if ;

END CALCULATE_NETTING_BUCKET;

PROCEDURE start_bucketing(
            p_refresh_number IN OUT NOCOPY NUMBER)
IS

t_customer_of       numberlist ;
t_customer_site_of  numberlist ;
t_supplier_of       numberlist ;
t_supplier_site_of  numberlist ;
t_item_id_of        numberlist ;
t_max_ref_cust      numberlist ;
t_max_receipt_cust  msc_sce_loads_pkg.receiptdateList ;
t_min_receipt_cust  msc_sce_loads_pkg.receiptdateList ;

t_customer_sc       numberlist ;
t_customer_site_sc  numberlist ;
t_supplier_sc       numberlist ;
t_supplier_site_sc  numberlist ;
t_item_id_sc        numberlist ;
t_max_ref_supp      numberlist ;
t_max_receipt_supp  msc_sce_loads_pkg.receiptdateList ;
t_min_receipt_supp  msc_sce_loads_pkg.receiptdateList ;
cursor c1 is
SELECT distinct sd.customer_id,
	        sd.customer_site_id,
                sd.publisher_id  supplier_id,
                sd.publisher_site_id  supplier_site_id,
                nvl(sd.base_item_id,sd.inventory_item_id) item_id
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type in (msc_x_netting_pkg.SUPPLY_COMMIT, msc_x_netting_pkg.SALES_ORDER)
AND     sd.last_refresh_number > p_refresh_number
union
SELECT distinct sd.publisher_id  customer_id,
                sd.publisher_site_id customer_site_id,
		sd.supplier_id,
	        sd.supplier_site_id,
                nvl(sd.base_item_id,sd.inventory_item_id) item_id
FROM  msc_sup_dem_entries sd
WHERE    sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND   sd.publisher_order_type = msc_x_netting_pkg.ORDER_FORECAST
AND   sd.last_refresh_number> p_refresh_number;

/* These cursors c2 and c3 are not used at all .
   These were alternatives tried for performance gains */
/*
cursor c2 is
select customer_id,customer_site_id,supplier_id,supplier_site_id,item_id,
       nvl(max(last_refresh_number), -1),
       nvl(max(key_date),sysdate),
       nvl(min(key_date),sysdate)
from (
	select
	       sd1.publisher_id  customer_id,
	       sd1.publisher_site_id customer_site_id,
	       sd1.supplier_id,
	       sd1.supplier_site_id,
	       nvl(sd1.base_item_id,sd1.inventory_item_id) item_id,
	       sd1.last_refresh_number,
	       sd1.key_date
	from msc_sup_dem_entries sd1
	where sd1.publisher_order_type = 2
	  and sd1.plan_id=  -1
	  and sd1.last_refresh_number > p_refresh_number
	  and exists (select 1
			from msc_sup_dem_entries sd2
			where sd2.plan_id = sd1.plan_id
			  and sd2.sr_instance_id = sd1.sr_instance_id
			  and sd2.publisher_order_type  = 3
			  and sd2.customer_id = sd1.publisher_id
			  and sd2.customer_site_id = sd1.publisher_site_id
			  and sd2.publisher_id = sd1.supplier_id
			  and sd2.publisher_site_id = sd1.supplier_site_id
			  and nvl(sd2.base_item_id,sd2.inventory_item_id) = nvl(sd1.base_item_id,sd1.inventory_item_id)
			  and sd2.last_refresh_number > p_refresh_number
			  )
	union all
	select
	      -- distinct
	       sd1.publisher_id  customer_id,
	       sd1.publisher_site_id customer_site_id,
	       sd1.supplier_id,
	       sd1.supplier_site_id,
	       nvl(sd1.base_item_id,sd1.inventory_item_id) item_id,
	       sd1.last_refresh_number,
	       sd1.key_date
	from msc_sup_dem_entries sd1
	where sd1.publisher_order_type = 2
	  and sd1.plan_id=  -1
	  and sd1.last_refresh_number > p_refresh_number
	  and exists (select 1
			from msc_sup_dem_entries sd2
			where sd2.plan_id = sd1.plan_id
			  and sd2.sr_instance_id = sd1.sr_instance_id
			  and sd2.publisher_order_type  = 14
			  and sd2.customer_id = sd1.publisher_id
			  and sd2.customer_site_id = sd1.publisher_site_id
			  and sd2.publisher_id = sd1.supplier_id
			  and sd2.publisher_site_id = sd1.supplier_site_id
			  and nvl(sd2.base_item_id,sd2.inventory_item_id) = nvl(sd1.base_item_id,sd1.inventory_item_id)
			  and sd2.last_refresh_number > p_refresh_number
			  )
	)  x
group by x.customer_id,x.customer_site_id,x.supplier_id
		,x.supplier_site_id ,x.item_id
order by 1,2,3,4,5;

cursor c3 is
select customer_id,customer_site_id,supplier_id,supplier_site_id,item_id,
       nvl(max(last_refresh_number), -1),
       nvl(max(key_date),sysdate),
       nvl(min(key_date),sysdate)
from (
	select
	       sd1.customer_id,
	       sd1.customer_site_id,
	       sd1.publisher_id     supplier_id,
	       sd1.publisher_site_id supplier_site_id,
	       nvl(sd1.base_item_id,sd1.inventory_item_id) item_id,
	       sd1.last_refresh_number,
	       sd1.key_date
	from msc_sup_dem_entries sd1
	where sd1.publisher_order_type = 3
	  and sd1.plan_id=  -1
	  and sd1.last_refresh_number > p_refresh_number
	  and exists (select 1
			from msc_sup_dem_entries sd2
			where sd2.plan_id = sd1.plan_id
			  and sd2.sr_instance_id = sd1.sr_instance_id
			  and sd2.publisher_order_type  = 2
			  and sd2.publisher_id = sd1.customer_id
			  and sd2.publisher_site_id = sd1.customer_site_id
			  and sd2.supplier_id =  sd1.publisher_id
			  and sd2.supplier_site_id = sd1.publisher_site_id
			  and nvl(sd2.base_item_id,sd2.inventory_item_id) = nvl(sd1.base_item_id,sd1.inventory_item_id)
			  and sd2.last_refresh_number > p_refresh_number
			  )
	union all
	select
	       sd1.customer_id,
	       sd1.customer_site_id,
	       sd1.publisher_id     supplier_id,
	       sd1.publisher_site_id supplier_site_id,
	       nvl(sd1.base_item_id,sd1.inventory_item_id) item_id,
	       sd1.last_refresh_number,
	       sd1.key_date
	from msc_sup_dem_entries sd1
	where sd1.publisher_order_type = 14
	  and sd1.plan_id=  -1
	  and sd1.last_refresh_number > p_refresh_number
	  and exists (select 1
			from msc_sup_dem_entries sd2
			where sd2.plan_id = sd1.plan_id
			  and sd2.sr_instance_id = sd1.sr_instance_id
			  and sd2.publisher_order_type  = 2
			  and sd2.publisher_id = sd1.customer_id
			  and sd2.publisher_site_id = sd1.customer_site_id
			  and sd2.supplier_id =  sd1.publisher_id
			  and sd2.supplier_site_id = sd1.publisher_site_id
			  and nvl(sd2.base_item_id,sd2.inventory_item_id) = nvl(sd1.base_item_id,sd1.inventory_item_id)
			  and sd2.last_refresh_number > p_refresh_number
			  )
	)  x
group by x.customer_id,x.customer_site_id,x.supplier_id
	,x.supplier_site_id ,x.item_id
order by 1,2,3,4,5;
*/

lv_cutoff_ref_num  number;
lv_max_rn           number;
lv_min_key_date date;
lv_max_key_date date;

lv_sql_stmt         varchar2(1000);
begin

   lv_sql_stmt := 'delete msc_cp_plan_buckets';
   execute immediate lv_sql_stmt;
   commit;

   select nvl(max(last_refresh_number),0)
     into  lv_cutoff_ref_num
   from msc_sup_dem_entries;


/* These cursors c2 and c3 are not used at all .
   These were alternatives tried for performance gains */
/*
   BEGIN
   OPEN c2;
   FETCH c2 BULK COLLECT INTO
	    t_customer_of  ,
	    t_customer_site_of,
	    t_supplier_of     ,
	    t_supplier_site_of,
	    t_item_id_of      ,
	    t_max_ref_cust    ,
	    t_max_receipt_cust,
	    t_min_receipt_cust;
   CLOSE c2;
   exception
     when others then
	  LOG_MESSAGE('An error occured in the cursor c2 : '||SQLERRM);

   BEGIN
   OPEN c3;
   FETCH c3 BULK COLLECT INTO
	    t_customer_sc       ,
	    t_customer_site_sc  ,
	    t_supplier_sc       ,
	    t_supplier_site_sc  ,
	    t_item_id_sc        ,
	    t_max_ref_supp      ,
	    t_max_receipt_supp  ,
	    t_min_receipt_supp  ;
   CLOSE c3;
   exception
     when others then
	  LOG_MESSAGE('An error occured in the cursor c3 : '||SQLERRM);
     end;

  IF (t_customer_of.COUNT > 0) and (t_customer_sc.COUNT > 0) THEN

	  LOG_MESSAGE('t_customer_of.COUNT : '||t_customer_of.COUNT);
	  LOG_MESSAGE('t_customer_sc.count '||t_customer_sc.count);

      FOR j in 1..t_customer_of.COUNT LOOP

	   if (t_customer_of(j) = t_customer_sc(j) and
	       t_customer_site_of(j) = t_customer_site_sc(j) and
	       t_supplier_of(j) = t_supplier_sc(j) and
	       t_supplier_site_of(j) = t_supplier_site_sc(j) and
	       t_item_id_of(j) = t_item_id_sc(j) ) then

	   CALCULATE_NETTING_BUCKET( -1,
			t_customer_sc(j)  ,   -- p_customer_id IN NUMBER,
			t_customer_site_sc(j) ,  ---p_customer_site_id IN NUMBER,
			t_supplier_sc(j) ,   ---p_supplier_id IN NUMBER,
			t_supplier_site_sc(j) ,  ---p_supplier_site_id IN NUMBER,
			t_item_id_sc(j), ----p_item_id IN NUMBER,
			msc_x_netting_pkg.SUPPLY_PLANNING,                    ---.p_plan_type IN NUMBER,
			t_max_ref_supp(j),
			t_max_receipt_supp(j),
			t_min_receipt_supp(j),
			t_max_ref_cust(j),
			t_max_receipt_cust(j),
			t_min_receipt_cust(j),
			lv_cutoff_ref_num);   ---p_cutoff_ref_num IN OUT NOCOPY NUMBER)
            end if;


      end loop;

   end if;
   */

   for c_rec in c1 loop

	   CALCULATE_NETTING_BUCKET(
	                -1,
		        c_rec.customer_id,                 --p_customer_id
			c_rec.customer_site_id,            --p_customer_site_id
			c_rec.supplier_id,                 --p_supplier_id
			c_rec.supplier_site_id,            --p_supplier_site_id
			c_rec.item_id,                     --p_item_id
			msc_x_netting_pkg.SUPPLY_PLANNING, --p_plan_type
			lv_cutoff_ref_num);                --p_cutoff_ref_num


   exit when c1%NOTFOUND;

   end loop;

EXCEPTION WHEN OTHERS THEN
       LOG_MESSAGE(SQLERRM);
       LOG_MESSAGE(SQLCODE);
       LOG_MESSAGE('Error bucketing code.');
       RAISE;

END start_bucketing;

END MSC_EXCHANGE_BUCKETING;

/
