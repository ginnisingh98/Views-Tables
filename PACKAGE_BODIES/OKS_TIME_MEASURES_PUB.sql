--------------------------------------------------------
--  DDL for Package Body OKS_TIME_MEASURES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_TIME_MEASURES_PUB" AS
/* $Header: OKSSTQTB.pls 120.13.12010000.2 2009/10/14 11:39:14 cgopinee ship $ */

FUNCTION days_in_month(p_date IN DATE)

return NUMBER
as

l_month NUMBER;
l_day   NUMBER;
l_year  NUMBER;
BEGIN
  l_month := to_number(to_char(p_date,'MM'));
  if l_month in (1,3,5,7,8,10,12)
  then
    l_day := 31;
  elsif l_month in (4,6,9,11)
  then
    l_day := 30;
  else
    l_year := to_number(to_char(p_date,'YYYY'));
    if mod(l_year,4)= 0
    then
      l_day := 29;
    else
      l_day := 28;
    end if;
  end if;
 return l_day;
END;

------------------------------------------------------------------------------

FUNCTION end_of_month (p_date IN DATE)

return BOOLEAN
as

BEGIN
  if to_number(to_char(p_date,'DD')) = days_in_month(p_date)
  then
    return TRUE;
  else
    return FALSE;
  end if;

END;
----------------------------------------------------------------

FUNCTION get_year_from_days(p_start_date  IN DATE DEFAULT NULL,
                            p_end_date    IN DATE DEFAULT NULL,
                            p_no_of_days  IN NUMBER)
return NUMBER
as
l_start_year     NUMBER;
l_end_year       NUMBER;
l_leapyear_days  NUMBER := 0;
l_no_of_years    NUMBER := 0;

BEGIN

  l_start_year := to_number(to_char(p_start_date,'YYYY'));
  l_end_year   := to_number(to_char(p_end_date,'YYYY'));

  for i in l_start_year..l_end_year
  loop

    if mod(i,4) = 0 then
      if l_start_year = l_end_year then
         l_leapyear_days := p_end_date - p_start_date +1;
      else
        if i = l_start_year then
          l_leapyear_days := l_leapyear_days + to_date('31-12-'||to_char(l_start_year),'DD-MM-YYYY') - p_start_date +1;
        elsif i = l_end_year then
          l_leapyear_days := l_leapyear_days + p_end_date- to_date('01-01-'||to_char(l_end_year),'DD-MM-YYYY') +1;
        else
          l_leapyear_days := l_leapyear_days+366;
        end if;
      end if;
    end if;
    end loop;

    l_no_of_years := ((p_no_of_days - l_leapyear_days)/365) + (l_leapyear_days/366);

    return l_no_of_years;

END;

------------------------------------------------------

FUNCTION get_uom_code(p_tce_code      IN VARCHAR2
                     ,p_quantity      IN NUMBER)
return VARCHAR2
as

Cursor cs_uom(cp_tce_code IN VARCHAR2
             ,cp_quantity IN NUMBER)
is
select uom_code
from OKC_TIME_CODE_UNITS_V
where  tce_code = cp_tce_code and quantity = cp_quantity
and active_flag = 'Y';

l_uom  VARCHAR2(10);
invalid_uom_exception  EXCEPTION;

BEGIN

    Open  cs_uom(p_tce_code,p_quantity);
    Fetch cs_uom Into l_uom;

    IF cs_uom%NOTFOUND
    THEN
       RAISE INVALID_UOM_EXCEPTION;
    END IF;

    Close cs_uom;

    return l_uom;

  EXCEPTION
  WHEN
    INVALID_UOM_EXCEPTION
    THEN
      OKC_API.SET_MESSAGE(p_app_name    => 'OKS',
                         p_msg_name     => 'OKS_INVD_UOM_CODE',
                         p_token1       => 'OKS_API_NAME',
                         p_token1_value => 'OKS_TIME_MEASURES_PUB.get_uom_code',
                         p_token2       => 'UOM_CODE',
                         p_token2_value => p_tce_code);
      close cs_uom;
      return 0;

END  get_uom_code;
--------------------------

FUNCTION get_target_qty (p_start_date  IN DATE DEFAULT NULL,
                         p_source_qty  IN NUMBER,
                         p_source_uom  IN VARCHAR2,
                         p_target_uom  IN VARCHAR2,
                         p_round_dec   IN NUMBER)
return NUMBER
as
 CURSOR cs_validate_uom(p_uom_code IN VARCHAR2)
 is
 SELECT 1
 FROM okx_units_of_measure_v
 WHERE uom_code = p_uom_code;
 cr_validate_uom  cs_validate_uom%ROWTYPE;
 l_target_qty  NUMBER;
 l_learyear_yn VARCHAR2(1);
 l_start_date  date;
 l_end_date    date;
 l_no_days     NUMBER;

 l_day        VARCHAR2(40);
 l_month      VARCHAR2(40);
 l_year       VARCHAR2(40);
 l_week       VARCHAR2(40);
 l_minute     VARCHAR2(40);
 l_hour       VARCHAR2(40);
-- Commented for the Bug # 3077436
-- l_sec        VARCHAR2(40);
-- Bug # 3077436
 l_quarter     VARCHAR2(40);
 l_multiplier  NUMBER;

 invalid_uom_exception  EXCEPTION;

BEGIN

 open cs_validate_uom(p_source_uom);
 fetch cs_validate_uom into cr_validate_uom;
 IF cs_validate_uom%NOTFOUND
 THEN
   RAISE INVALID_UOM_EXCEPTION;
 END IF;

 close cs_validate_uom;

 open cs_validate_uom(p_target_uom);
 fetch cs_validate_uom into cr_validate_uom;
 IF cs_validate_uom%NOTFOUND
 THEN
   RAISE INVALID_UOM_EXCEPTION;
 END IF;

 close cs_validate_uom;

 l_day := upper(get_uom_code('DAY',1));
 l_month := upper(get_uom_code('MONTH',1));
 l_year := upper(get_uom_code('YEAR',1));
 l_week := upper(get_uom_code('DAY',7));
 l_minute:=upper(get_uom_code('MINUTE',1));
 l_hour:=upper(get_uom_code('HOUR',1));
-- Commented for the Bug # 3077436
-- l_sec:=upper(get_uom_code('SECOND',1));
-- Bug # 3077436
 l_quarter :=upper(get_uom_code('MONTH',3));


 IF p_source_uom = p_target_uom
 THEN
   l_target_qty := p_source_qty;
 ELSE
   IF p_start_date IS NOT NULL
   THEN
     l_start_date := p_start_date;
     l_end_date := okc_time_util_pub.get_enddate(p_start_date,p_source_uom,p_source_qty);
   ELSE
     l_start_date := sysdate;
     l_end_date := okc_time_util_pub.get_enddate(sysdate,p_source_uom,p_source_qty);
   END IF;

   l_no_days := l_end_date - l_start_date+1;

   IF upper(p_source_uom) =l_year
   THEN
     IF upper(p_target_uom) = l_quarter
     THEN
       l_target_qty := p_source_qty*4;
     ELSIF upper(p_target_uom) = l_month
     THEN
       l_target_qty := p_source_qty*12;
     ELSE
        -- Changed to get relationship from okc_time_code_units_b bug no:4255530
       l_multiplier := get_con_factor(p_source_uom, p_target_uom);
          IF l_multiplier is NULL THEN
            l_target_qty := GET_QTY_FOR_DAYS(l_no_days,p_target_uom);
          ELSE
            l_target_qty := p_source_qty * l_multiplier;
          END IF;
     --end of change bug no:4255530
     END IF;
   ELSIF upper(p_source_uom) = l_month
   THEN
     IF upper(p_target_uom) = l_year
     THEN
       l_target_qty := p_source_qty/12;
     ELSIF upper(p_target_uom) = l_quarter
     THEN
       l_target_qty := p_source_qty/3;
     ELSE
       -- Changed to get relationship from okc_time_code_units_b bug no:4255530
       l_multiplier := get_con_factor(p_source_uom, p_target_uom);
          IF l_multiplier is NULL THEN
            l_target_qty := GET_QTY_FOR_DAYS(l_no_days,p_target_uom);
          ELSE
            l_target_qty := p_source_qty * l_multiplier;
          END IF;
      --end of change bug no:4255530
     END IF;
   ELSIF upper(p_source_uom) = l_quarter
   THEN
     IF upper(p_target_uom) = l_year
     THEN
       l_target_qty := p_source_qty/4;
     ELSIF upper(p_target_uom) = l_month
     THEN
       l_target_qty := p_source_qty*3;
     ELSE
       -- Changed to get relationship from okc_time_code_units_b bug no:4255530
       l_multiplier := get_con_factor(p_source_uom, p_target_uom);
          IF l_multiplier is NULL THEN
            l_target_qty := GET_QTY_FOR_DAYS(l_no_days,p_target_uom);
          ELSE
            l_target_qty := p_source_qty * l_multiplier;
          END IF;
    --end of change bug no:4255530
     END IF;
   ELSIF upper(p_source_uom) = l_day
   THEN
     IF upper(p_target_uom) = l_year
     THEN
       l_target_qty := get_year_from_days (l_start_date,l_end_date,l_no_days);
     ELSIF upper(p_target_uom) = l_month
     THEN
       l_target_qty := months_between(l_end_date+1,l_start_date);
     ELSIF upper(p_target_uom) = l_quarter
     THEN
       l_target_qty := (months_between(l_end_date+1,l_start_date))/3;
     ELSE
      -- Changed to get relationship from okc_time_code_units_b bug no:4255530
       l_multiplier := get_con_factor(p_source_uom, p_target_uom);
          IF l_multiplier is NULL THEN
            l_target_qty := GET_QTY_FOR_DAYS(l_no_days,p_target_uom);
          ELSE
            l_target_qty := p_source_qty * l_multiplier;
          END IF;
   --end of change bug no:4255530
     END IF;
-- Changed the condition for Bug # 3077436
   --ELSIF upper(p_source_uom) in (l_week,l_day,l_hour,l_minute,l_sec)
   ELSIF upper(p_source_uom) in (l_week,l_hour,l_minute)
-- Changed the condition for Bug # 3077436
   THEN
     IF upper(p_target_uom) = l_quarter
     THEN
       l_target_qty := (months_between(l_end_date+1,l_start_date))/3;
     ELSIF upper(p_target_uom) = l_month
     THEN
       l_target_qty := months_between(l_end_date+1,l_start_date);
     ELSE
        -- Changed to get relationship from okc_time_code_units_b bug no:4255530
       l_multiplier := get_con_factor(p_source_uom, p_target_uom);
          IF l_multiplier is NULL THEN
            l_target_qty := GET_QTY_FOR_DAYS(l_no_days,p_target_uom);
          ELSE
            l_target_qty := p_source_qty * l_multiplier;
          END IF;
  --end of change bug no:4255530
     END IF;
   END IF;
/*   ELSIF upper(p_source_uom) = l_week
   THEN
     IF upper(p_target_uom) = l_month
     THEN
       l_target_qty := months_between(l_end_date+1,l_start_date);
     ELSE
       l_target_qty := GET_QTY_FOR_DAYS(l_no_days,p_target_uom);
     END IF;
   ELSIF upper(p_source_uom) = l_day
   THEN
      IF upper(p_target_uom) = l_month
      THEN
	  l_target_qty := months_between(l_end_date+1,l_start_date);
      ELSE
         l_target_qty := GET_QTY_FOR_DAYS(l_no_days,p_target_uom);
      END IF;
   END IF;
   */
   /*
   The following condn will meet if target_uom is a user defined uom and there
 no common conv factor available bw source ,target uom in Map Time units form
 bugno:4255530
*/
   IF (nvl(l_target_qty,0) =0 AND p_source_qty <> 0)
   THEN
   l_target_qty := (okc_time_util_pub.get_enddate(nvl(p_start_date,SYSDATE),p_source_uom,p_source_qty)-nvl(p_start_date,SYSDATE)+1)
                   /(okc_time_util_pub.get_enddate(nvl(p_start_date,SYSDATE),p_target_uom,1)-nvl(p_start_date,SYSDATE)+1);
   END IF;
   -- End bugno:4255530
 END IF;

 l_target_qty := round(l_target_qty,p_round_dec);
 return l_target_qty;

 EXCEPTION
  WHEN
    INVALID_UOM_EXCEPTION
    THEN
      OKC_API.SET_MESSAGE(p_app_name    => 'OKS',
                         p_msg_name     => 'OKS_INVD_UOM_CODE',
                         p_token1       => 'OKS_API_NAME',
                         p_token1_value => 'OKS_TIME_MEASURES_PUB.get_target_qty',
                         p_token2       => 'UOM_CODE',
                         p_token2_value => p_source_uom );
      close cs_validate_uom;
      return 0;
END get_target_qty;

-------------------------------------------------------------

PROCEDURE get_duration_uom ( p_start_date    IN DATE
                           , p_end_date      IN  DATE
                           , x_duration      OUT nocopy NUMBER
                           , x_timeunit      OUT nocopy VARCHAR2
                           , x_return_status OUT nocopy VARCHAR2)
IS

  l_counter number(12,6);
  l_date date;
  l_timeunit varchar2(10);
  l_offset number := 0;
  l_duration number := 0;
  l_duration_wk number := 0;
  l_duration_mth number := 0;

BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    if p_end_date is NULL Then
	 x_duration := NULL;
	 x_timeunit := NULL;
	 return;
    end if;
    if p_start_date > p_end_date then
      OKC_API.SET_MESSAGE(p_app_name    => G_APP_NAME,
                         p_msg_name     => G_DATE_ERROR,
                         p_token1       => G_COL_NAME_TOKEN,
                         p_token1_value => 'START_DATE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	 return;
    end if;

    okc_time_util_pub.get_duration(p_start_date,p_end_date,l_duration,l_timeunit,x_return_status);
    if x_return_status <> OKC_API.G_RET_STS_SUCCESS then
	  l_duration := NULL;
      l_timeunit := NULL;
    end if;

    l_duration := get_target_qty(p_start_date,l_duration,l_timeunit,get_uom_code('DAY',1),2);

    if l_duration >=7
    then

      l_duration_wk := get_target_qty(p_start_date,l_duration,get_uom_code('DAY',1),get_uom_code('DAY',7),2);
      l_duration_mth := get_target_qty(p_start_date,l_duration,get_uom_code('DAY',1),get_uom_code('MONTH',1),2);
      if l_duration_mth < 1 then
        x_duration := l_duration_wk;
        x_timeunit := get_uom_code('DAY',7);
      elsif l_duration_mth >= 3 and l_duration_mth < 12
      then
        x_duration := get_target_qty(p_start_date,l_duration_mth,get_uom_code('MONTH',1),get_uom_code('MONTH',3),2);
        x_timeunit := get_uom_code('MONTH',3);
      elsif l_duration_mth >= 12
      then
        x_duration := get_target_qty(p_start_date,l_duration_mth,get_uom_code('MONTH',1),get_uom_code('YEAR',1),2);
        x_timeunit := get_uom_code('YEAR',1);
      elsif l_duration_mth >=1 and l_duration_mth < 3
      then
        x_duration := l_duration_mth; --get_target_qty(p_start_date,l_duration,l_timeunit,get_uom_code('MONTH',1),2);
        x_timeunit := get_uom_code('MONTH',1);
      else
        x_duration := l_duration;
        x_timeunit := l_timeunit;
      end if;
    else
       x_duration := l_duration;
       x_timeunit := l_timeunit;
    end if;

END get_duration_uom;

--------------------------------------------------------------------------

FUNCTION GET_QTY_FOR_DAYS (p_no_days     IN NUMBER,
                           p_target_uom  IN VARCHAR2)
return NUMBER
as
 l_target_qty NUMBER;
 no_strdt_exception     EXCEPTION;

 l_day        VARCHAR2(40);
 l_month      VARCHAR2(40);
 l_year       VARCHAR2(40);
 l_week       VARCHAR2(40);
 l_minute     VARCHAR2(40);
 l_hour       VARCHAR2(40);
-- Commented for the Bug # 3077436
-- l_sec        VARCHAR2(40);
-- Bug # 3077436

BEGIN


   IF p_no_days IS NULL then
     RAISE NO_STRDT_EXCEPTION;
   END IF;


   l_day := upper(get_uom_code('DAY',1));
   l_month := upper(get_uom_code('MONTH',1));
   l_year := upper(get_uom_code('YEAR',1));
   l_week := upper(get_uom_code('DAY',7));
   l_minute:=upper(get_uom_code('MINUTE',1));
   l_hour:=upper(get_uom_code('HOUR',1));
-- Commented for the Bug # 3077436
--   l_sec:=upper(get_uom_code('SECOND',1));
-- Bug # 3077436

   IF upper(p_target_uom) = l_year
   THEN
     l_target_qty := p_no_days/365;
   ELSIF upper(p_target_uom) = l_week
   THEN
     l_target_qty := p_no_days/7;
   ELSIF upper(p_target_uom) = l_day
   THEN
     l_target_qty := p_no_days;
   ELSIF upper(p_target_uom) = l_hour
   THEN
     l_target_qty := p_no_days*24;
   ELSIF upper(p_target_uom) = l_minute
   THEN
     l_target_qty := p_no_days*1440;
-- Commented for the Bug # 3077436
--   ELSIF upper(p_target_uom) = l_sec
--   THEN
--     l_target_qty := p_no_days*86400;
-- Bug # 3077436
   END IF;
 return l_target_qty;
 EXCEPTION
  WHEN
    NO_STRDT_EXCEPTION
    THEN
      OKC_API.set_message('OKS','OKS_START_DATE_REQD');
      return 0;
END;

------------------------------------------------------------------------
/* This function  includes logic to calculate duration based on Period Start and Period Type
in addition to present way of calculating the duration
*/
FUNCTION get_quantity(p_start_date    IN DATE,
                      p_end_date      IN DATE,
                      p_source_uom    IN VARCHAR2 DEFAULT NULL,
                      p_period_type   IN VARCHAR2 DEFAULT NULL, --New paramter
                      p_period_start  IN VARCHAR2 DEFAULT NULL) --New parameter
return NUMBER
as


 CURSOR cs_validate_uom(p_uom_code IN VARCHAR2)
 is
 SELECT 1
 FROM MTL_UNITS_OF_MEASURE_TL
 WHERE uom_code = p_uom_code
 AND LANGUAGE = USERENV('LANG');

 cr_validate_uom  cs_validate_uom%ROWTYPE;


 --------------------------------------------------
CURSOR get_tce_code(p_uom_code IN VARCHAR2)
is
SELECT tce_code
FROM OKC_TIME_CODE_UNITS_B
WHERE uom_code=p_uom_code;

----------------------------------------------------

 l_target_qty  NUMBER;
 l_source_qty  NUMBER;
 l_learyear_yn VARCHAR2(1);
 l_start_date  date;
 l_end_date    date;
 l_chr_date    VARCHAR2(20);
 l_no_days     NUMBER;
 l_tce_code    VARCHAR2(30);
 l_period_start VARCHAR2(30);

 l_period_uom_code VARCHAR2(80);
 l_status          VARCHAR2(80);

 invalid_uom_exception  EXCEPTION;
 l_source_uom     VARCHAR2(100) := NULL;


BEGIN

 l_chr_date   := to_char(p_start_date,'YYYY/MM/DD');
 l_start_date := to_date(l_chr_date,'YYYY/MM/DD');
 l_chr_date   := to_char(p_end_date,'YYYY/MM/DD');
 l_end_date   := to_date(l_chr_date,'YYYY/MM/DD');

 IF p_source_uom Is Null Then
    l_source_uom := get_uom_code('MONTH',1);

 Else
    open cs_validate_uom(p_source_uom);
    fetch cs_validate_uom into cr_validate_uom;

    IF cs_validate_uom%NOTFOUND
    THEN
       RAISE INVALID_UOM_EXCEPTION;
    END IF;

    l_source_uom := p_source_uom;
    close cs_validate_uom;

 End If;

 --for calendar month start, the uom should be defined in multiples of months
    open get_tce_code(p_source_uom);
    fetch get_tce_code into l_tce_code;
    close get_tce_code;


 IF (l_tce_code = 'YEAR') OR
    (l_tce_code = 'MONTH')OR
    (p_period_start  IS NULL)
 THEN
    l_period_start := p_period_start;
 ELSE
     l_period_start := 'SERVICE';
 END IF;

 IF l_period_start ='CALENDAR' AND p_period_type IS NOT NULL
 THEN
    l_target_qty := get_target_qty_cal(p_start_date,
                                       p_end_date,
                                       p_source_uom,
                                       p_period_type,
                                       18);
 ELSIF l_period_start ='SERVICE' AND p_period_type IS NOT NULL
 THEN
     l_target_qty := get_target_qty_service(p_start_date,
                                            p_end_date,
                                            p_source_uom,
                                            p_period_type,
                                            18);
 ELSE

    okc_time_util_pub.get_duration (
  	     p_start_date    => l_start_date,
  	     p_end_date      => l_end_date,
  	     x_duration      => l_source_qty,
  	     x_timeunit      => l_period_uom_code,
  	     x_return_status => l_status);

    l_target_qty := get_target_qty(l_start_date,
                                l_source_qty,
                                l_period_uom_code,
                                l_source_uom,
                                18);
 END IF;
 return l_target_qty;

 EXCEPTION
  WHEN
    INVALID_UOM_EXCEPTION
    THEN
      OKC_API.SET_MESSAGE(p_app_name    => 'OKS',
                         p_msg_name     => 'OKS_INVD_UOM_CODE',
                         p_token1       => 'OKS_API_NAME',
                         p_token1_value => 'OKS_TIME_MEASURES_PUB.get_quantity',
                         p_token2       => 'UOM_CODE',
                         p_token2_value => p_source_uom );
      close cs_validate_uom;
      return 0;
  WHEN OTHERS THEN
                 OKC_API.set_message(G_APP_NAME,
                                     G_UNEXPECTED_ERROR,
                                     G_SQLCODE_TOKEN,
                                     SQLCODE,
                                     G_SQLERRM_TOKEN,
                                     SQLERRM);
                 return 0;


END get_quantity;

------------------------------------------------------------------------
-- This function calculates the duration using partial period logic if period start is 'calendar'

FUNCTION get_target_qty_cal(p_start_date   IN DATE,
                            p_end_date     IN DATE,
                            p_price_uom    IN VARCHAR2,
                            p_period_type  IN VARCHAR2,
                            p_round_dec    IN NUMBER)

return NUMBER
as

CURSOR cs_validate_uom(p_uom_code IN VARCHAR2)
 is
 SELECT 1
 FROM MTL_UNITS_OF_MEASURE_TL
 WHERE uom_code = p_uom_code
 --AND   uom_class = 'Time' commented for bug#5585356
 AND LANGUAGE = USERENV('LANG');
 cr_validate_uom  cs_validate_uom%ROWTYPE;

l_full_periods           NUMBER;
l_full_period_end_date   DATE;
l_status                 VARCHAR2(80);
l_ppc_begin              NUMBER;
l_ppc_end                NUMBER;
l_period_tot_duration    NUMBER;
l_full_period_start_date DATE;
l_ppc_end_start_date     DATE;
l_month_end_date         DATE;

invalid_period_type_exception  EXCEPTION;
invalid_date_exception         EXCEPTION;
invalid_uom_exception          EXCEPTION;
BEGIN
 IF upper(p_period_type) NOT IN ('ACTUAL','FIXED')
 THEN
     RAISE INVALID_PERIOD_TYPE_EXCEPTION;
 END IF;
 open cs_validate_uom(p_price_uom);
 fetch cs_validate_uom into cr_validate_uom;
 IF cs_validate_uom%NOTFOUND
 THEN
     RAISE INVALID_UOM_EXCEPTION;
 END IF;
 close cs_validate_uom;
 IF (p_start_date IS NULL)OR(p_end_date IS NULL)OR(p_start_date > p_end_date)
 THEN
    RAISE INVALID_DATE_EXCEPTION;
 END IF;
 IF (trunc(p_start_date,'MM')= p_start_date)
 THEN
    l_ppc_begin :=0;
    l_full_period_start_date :=p_start_date;
 ELSE
    l_month_end_date := last_day(p_start_date);
	IF p_end_date <= l_month_end_date
    THEN
       l_ppc_begin :=get_partial_period_duration(p_start_date,
                                                  p_end_date,
                                                  p_price_uom,
                                                  p_period_type,
                                                  'CALENDAR');
        IF l_ppc_begin = -1
        THEN
            return 0;
        END IF;
        return l_ppc_begin;
	ELSE
		l_ppc_begin :=get_partial_period_duration(p_start_date,
                                              l_month_end_date,
                                              p_price_uom,
                                              p_period_type,
                                              'CALENDAR');
        IF l_ppc_begin = -1
        THEN
           return 0;
        END IF;
        l_full_period_start_date := l_month_end_date+1;
    END IF;
 END IF;

 -- To find number of full periods between given date range
 get_full_periods (
  	    p_start_date           => l_full_period_start_date,
  	    p_end_date             => p_end_date,
  	    p_price_uom            => p_price_uom,
  	    x_full_periods         => l_full_periods,
  	    x_full_period_end_date => l_full_period_end_date,
            x_return_status        => l_status);

 IF l_status = OKC_API.G_RET_STS_ERROR
 THEN
    return 0;
 END IF;

 IF l_full_periods = 0
 THEN
    l_ppc_end_start_date := l_full_period_start_date;
 ELSE
    l_ppc_end_start_date := l_full_period_end_date+1;
 END IF;

 IF l_full_period_end_date = p_end_date
 THEN
     l_ppc_end :=0;
 ELSE
     l_ppc_end := get_partial_period_duration(l_ppc_end_start_date,
                                              p_end_date,
                                              p_price_uom,
                                              p_period_type,
                                              'CALENDAR');
     IF l_ppc_end = -1
     THEN
        return 0;
     END IF;
 END IF;

 l_period_tot_duration := ROUND(l_ppc_begin+l_full_periods+l_ppc_end, p_round_dec);

return l_period_tot_duration;

EXCEPTION
WHEN
    INVALID_PERIOD_TYPE_EXCEPTION
    THEN
      OKC_API.set_message(
         p_app_name     => G_APP_NAME,
         p_msg_name     => G_INVALID_VALUE,
         p_token1       => G_COL_NAME_TOKEN,
         p_token1_value => 'Period type');
      return 0;
WHEN
    INVALID_UOM_EXCEPTION
    THEN
      OKC_API.SET_MESSAGE(p_app_name    => 'OKS',
                         p_msg_name     => 'OKS_INVD_UOM_CODE',
                         p_token1       => 'OKS_API_NAME',
                         p_token1_value => 'OKS_TIME_MEASURES_PUB.get_target_qty_cal',
                         p_token2       => 'UOM_CODE',
                         p_token2_value => p_price_uom);

      close cs_validate_uom;
      return 0;
WHEN
    INVALID_DATE_EXCEPTION
    THEN
      OKC_API.set_message('OKC','OKC_REP_INV_EFF_DATE_SD');
      return 0;
WHEN OTHERS THEN
               OKC_API.set_message(G_APP_NAME,
                                   G_UNEXPECTED_ERROR,
                                   G_SQLCODE_TOKEN,
                                   SQLCODE,
                                   G_SQLERRM_TOKEN,
                                   SQLERRM);
               return 0;

END get_target_qty_cal;

------------------------------------------------------------------------
-- This function calculates the duration using partial period logic if period start is service

FUNCTION get_target_qty_service(p_start_date   IN DATE,
                                p_end_date     IN DATE,
                                p_price_uom    IN VARCHAR2,
                                p_period_type  IN VARCHAR2,
                                p_round_dec    IN NUMBER)
return NUMBER
as
CURSOR cs_validate_uom(p_uom_code IN VARCHAR2)
 is
 SELECT 1
 FROM MTL_UNITS_OF_MEASURE_TL
 WHERE uom_code = p_uom_code
 --AND   uom_class = 'Time'  commented for bug#5585356
 AND LANGUAGE = USERENV('LANG');

 cr_validate_uom  cs_validate_uom%ROWTYPE;


l_full_periods           NUMBER;
l_full_period_end_date   DATE;
l_status                 VARCHAR2(80);
l_ppc_end_start_date     DATE;
l_ppc_end                NUMBER;
l_period_tot_duration    NUMBER;
---------------------------------------------
 l_source_uom_quantity      NUMBER;
 l_source_tce_code          VARCHAR2(30);
 l_target_uom_quantity      NUMBER;
 l_target_tce_code          VARCHAR2(30);
 l_return_status     VARCHAR2(1);
 l_service_duration   Number;
 l_service_period     Varchar2(30);
 l_called_from        Varchar2(20);
------------------------------------------------

invalid_period_type_exception  EXCEPTION;
invalid_date_exception         EXCEPTION;
invalid_uom_exception          EXCEPTION;

BEGIN

 IF upper(p_period_type) NOT IN ('ACTUAL','FIXED')
 THEN
     RAISE INVALID_PERIOD_TYPE_EXCEPTION;
 END IF;
 open cs_validate_uom(p_price_uom);
 fetch cs_validate_uom into cr_validate_uom;
 IF cs_validate_uom%NOTFOUND
 THEN
     RAISE INVALID_UOM_EXCEPTION;
 END IF;
 close cs_validate_uom;
 IF (p_start_date IS NULL)OR(p_end_date IS NULL)OR(p_start_date > p_end_date)
 THEN
    RAISE INVALID_DATE_EXCEPTION;
 END IF;

  -- To find number of full periods between given date range
   get_full_periods (
  	    p_start_date           => p_start_date,
  	    p_end_date             => p_end_date,
  	    p_price_uom            => p_price_uom,
  	    x_full_periods         => l_full_periods,
  	    x_full_period_end_date => l_full_period_end_date,
        x_return_status        => l_status);

   IF l_status = OKC_API.G_RET_STS_ERROR
   THEN
     return 0;
   END IF;

   IF l_full_periods = 0
   THEN
      l_ppc_end_start_date := p_start_date;
   ELSE
      l_ppc_end_start_date := l_full_period_end_date+1;
   END IF;

   IF l_full_period_end_date = p_end_date
   THEN
     l_ppc_end :=0;
   ELSE
     l_ppc_end := get_partial_period_duration(l_ppc_end_start_date,
                                              p_end_date,
                                              p_price_uom,
                                              p_period_type,
                                              'SERVICE');
     IF l_ppc_end = -1
     THEN
        return 0;
     END IF;
   END IF;
   l_period_tot_duration := ROUND(l_full_periods + l_ppc_end,p_round_dec);

   return l_period_tot_duration;

EXCEPTION
WHEN
    INVALID_PERIOD_TYPE_EXCEPTION
    THEN
       OKC_API.set_message(
         p_app_name     => G_APP_NAME,
         p_msg_name     => G_INVALID_VALUE,
         p_token1       => G_COL_NAME_TOKEN,
         p_token1_value => 'Period type');

      return 0;
WHEN
    INVALID_UOM_EXCEPTION
    THEN
      OKC_API.SET_MESSAGE(p_app_name    => 'OKS',
                         p_msg_name     => 'OKS_INVD_UOM_CODE',
                         p_token1       => 'OKS_API_NAME',
                         p_token1_value => 'OKS_TIME_MEASURES_PUB.get_target_qty_service',
                         p_token2       => 'UOM_CODE',
                         p_token2_value =>  p_price_uom);
      close cs_validate_uom;
      return 0;
WHEN
    INVALID_DATE_EXCEPTION
    THEN
      OKC_API.set_message('OKC','OKC_REP_INV_EFF_DATE_SD');
      return 0;
WHEN OTHERS THEN
                OKC_API.set_message(G_APP_NAME,
                                    G_UNEXPECTED_ERROR,
                                    G_SQLCODE_TOKEN,
                                    SQLCODE,
                                    G_SQLERRM_TOKEN,
                                    SQLERRM);
                return 0;


END get_target_qty_service;


------------------------------------------------------------------------
/* This function return partial period quantity in terms of UOM. If UOM duration is more than
month, it will determine partial period using full months  and partial month else determines
partial period using just days */

FUNCTION get_partial_period_duration (p_start_date   IN DATE,
                                      p_end_date     IN DATE,
                                      p_price_uom    IN VARCHAR2,
                                      p_period_type  IN VARCHAR2,
                                      p_period_start IN VARCHAR2)
return NUMBER
as

CURSOR cs_validate_uom(p_uom_code IN VARCHAR2)
 is
 SELECT 1
 FROM MTL_UNITS_OF_MEASURE_TL
 WHERE uom_code = p_uom_code
 --AND   uom_class = 'Time'  commented for bug#5585356
 AND LANGUAGE = USERENV('LANG');
 cr_validate_uom  cs_validate_uom%ROWTYPE;

 l_months_in_uom            NUMBER;
 l_days_in_partial_period   NUMBER;
 l_full_months              NUMBER;
 l_partial_mth_start_date   DATE;
 l_days_in_partial_mth      NUMBER;
 l_days_in_mth              NUMBER;
 l_days_in_uom              NUMBER;
 l_duration_in_mths         NUMBER;
 l_partial_period           NUMBER;
 x_return_status            VARCHAR2(10);
 l_uom_quantity             NUMBER;
 l_tce_code                 VARCHAR2(10);

invalid_period_type_exception  EXCEPTION;
invalid_period_start_exception EXCEPTION;
invalid_date_exception         EXCEPTION;
invalid_uom_exception          EXCEPTION;
BEGIN

    IF upper(p_period_type) NOT IN ('ACTUAL','FIXED')
    THEN
      RAISE INVALID_PERIOD_TYPE_EXCEPTION;
    END IF;

    IF upper(p_period_start) NOT IN ('CALENDAR','SERVICE')
    THEN
      RAISE INVALID_PERIOD_START_EXCEPTION;
    END IF;
    open cs_validate_uom(p_price_uom);
    fetch cs_validate_uom into cr_validate_uom;
    IF cs_validate_uom%NOTFOUND
    THEN
       RAISE INVALID_UOM_EXCEPTION;
    END IF;
    close cs_validate_uom;
    IF p_start_date > p_end_date
    THEN
       RAISE INVALID_DATE_EXCEPTION;
    END IF;
     --mchoudha fix for bug#5199908
    OKS_BILL_UTIL_PUB.Get_Seeded_Timeunit
                    (p_timeunit      => p_price_uom,
                     x_return_status => x_return_status,
                     x_quantity      => l_uom_quantity ,
                     x_timeunit      => l_tce_code);
    IF x_return_status <> 'S' THEN
     RAISE INVALID_UOM_EXCEPTION;
    END IF;
    --The following logic is to get other uoms conversion factor in Month
    l_months_in_uom := months_between(OKC_TIME_UTIL_PUB.get_enddate(TRUNC(p_start_date,'MM'),p_price_uom,1)+1 ,TRUNC(p_start_date,'MM'));
    IF(l_months_in_uom <1 AND l_tce_code='DAY')
    THEN
       l_days_in_partial_period := (p_end_date+1)- p_start_date;
       --l_days_in_uom := (OKC_TIME_UTIL_PUB.get_enddate(p_start_date,p_price_uom,1)+1) - p_start_date;
       l_days_in_uom := l_uom_quantity;
       l_partial_period := l_days_in_partial_period/l_days_in_uom;
    ELSE
       l_full_months := floor(months_between(p_end_date+1,p_start_date));
       --08-SEP-2005 mchoudha
       --start bug#4571411: Fixed issue 2
       IF(l_full_months = months_between(p_end_date+1,p_start_date) ) THEN
          l_days_in_partial_mth := 0;
          l_partial_mth_start_date := add_months(p_start_date,l_full_months);
       ELSE
          l_partial_mth_start_date := add_months(p_start_date,l_full_months);
          l_days_in_partial_mth := (p_end_date+1)- l_partial_mth_start_date;
       END IF;
       --end bug#4571411
       IF upper(p_period_type) = 'FIXED'
       THEN
          l_days_in_mth :=30;
       ELSE
           --mchoudha fix for bug#5199908
	   --last day logic will be used for both Service and Calendar kind of scenarios
           --IF UPPER(p_period_start) = 'CALENDAR'
           --THEN
              l_days_in_mth := to_char(last_day(l_partial_mth_start_date),'dd');
           --ELSE
           --   l_days_in_mth := add_months(l_partial_mth_start_date,1) - l_partial_mth_start_date;
           --END IF;
       END IF;
       l_duration_in_mths := l_full_months+ l_days_in_partial_mth/l_days_in_mth;
       l_partial_period := l_duration_in_mths/l_months_in_uom;
    END IF;

   return(l_partial_period);
EXCEPTION
  WHEN
    INVALID_PERIOD_TYPE_EXCEPTION
    THEN
      OKC_API.set_message(
         p_app_name     => G_APP_NAME,
         p_msg_name     => G_INVALID_VALUE,
         p_token1       => G_COL_NAME_TOKEN,
         p_token1_value => 'Period Type');
      return -1;
  WHEN
    INVALID_PERIOD_START_EXCEPTION
    THEN
      OKC_API.set_message(
         p_app_name     => G_APP_NAME,
         p_msg_name     => G_INVALID_VALUE,
         p_token1       => G_COL_NAME_TOKEN,
         p_token1_value => 'Period Start');
      return -1;
  WHEN
    INVALID_UOM_EXCEPTION
    THEN
      OKC_API.SET_MESSAGE(p_app_name    => 'OKS',
                         p_msg_name     => 'OKS_INVD_UOM_CODE',
                         p_token1       => 'OKS_API_NAME',
                         p_token1_value => 'OKS_TIME_MEASURES_PUB.get_partial_period_duration',
                         p_token2       => 'UOM_CODE',
                         p_token2_value => p_price_uom);
      close cs_validate_uom;
      return -1;
  WHEN
    INVALID_DATE_EXCEPTION
    THEN
      OKC_API.set_message('OKC','OKC_REP_INV_EFF_DATE_SD');
      return -1;
  WHEN OTHERS THEN
                 OKC_API.set_message(G_APP_NAME,
                                     G_UNEXPECTED_ERROR,
                                     G_SQLCODE_TOKEN,
                                     SQLCODE,
                                     G_SQLERRM_TOKEN,
                                     SQLERRM);
                 return -1;


END get_partial_period_duration;


------------------------------------------------------------------------
/* This procedure calculates number of full periods for given period (startdate,end date),price uom
and also the last day of last full period. */

PROCEDURE get_full_periods (p_start_date            IN DATE,
                            p_end_date              IN DATE,
                            p_price_uom             IN VARCHAR2,
                            x_full_periods          OUT NOCOPY  NUMBER,
                            x_full_period_end_date  OUT NOCOPY  DATE,
                            x_return_status         OUT NOCOPY  VARCHAR2)
is

CURSOR cs_validate_uom(p_uom_code IN VARCHAR2)
 is
 SELECT 1
 FROM MTL_UNITS_OF_MEASURE_TL
 WHERE uom_code = p_uom_code
 --AND   uom_class = 'Time'  commented for bug#5585356
 AND LANGUAGE = USERENV('LANG');

 cr_validate_uom  cs_validate_uom%ROWTYPE;


 l_day         VARCHAR2(40);
 l_week        VARCHAR2(40);
 l_month       VARCHAR2(40);
 l_quarter     VARCHAR2(40);
 l_halfyear    VARCHAR2(40);
 l_year        VARCHAR2(40);
 l_full_periods         NUMBER;
 l_full_period_end_date DATE;
 l_confactor_mth        NUMBER;
 l_confactor_day        NUMBER;
 l_confactor_yr         NUMBER;

 invalid_date_exception         EXCEPTION;
 invalid_uom_exception          EXCEPTION;
 invalid_mapping_exception      EXCEPTION;
BEGIN
 x_return_status := OKC_API.G_RET_STS_SUCCESS;
 open cs_validate_uom(p_price_uom);
 fetch cs_validate_uom into cr_validate_uom;
 IF cs_validate_uom%NOTFOUND
 THEN
    RAISE INVALID_UOM_EXCEPTION;
 END IF;
 close cs_validate_uom;
 IF p_start_date > p_end_date
 THEN
    RAISE INVALID_DATE_EXCEPTION;
 END IF;

 l_day     := upper(get_uom_code('DAY',1));
 l_week    := upper(get_uom_code('DAY',7));
 l_month   := upper(get_uom_code('MONTH',1));
 l_quarter :=upper(get_uom_code('MONTH',3));
 --commented for bug#5122566
 --l_halfyear:=upper(get_uom_code('MONTH',6));
 l_year    := upper(get_uom_code('YEAR',1));

 --08-SEP-2005 mchoudha
 --bug#4571411 : Fixed issue 2
 --return p_end_date as l_full_period_end_date if full periods are there
 --between p_start_date and p_end_date

 IF   upper(p_price_uom) = l_year
 THEN
       l_full_periods := floor(months_between(p_end_date+1,p_start_date)/12);
       IF l_full_periods = months_between(p_end_date+1,p_start_date)/12 THEN
         l_full_period_end_date := p_end_date;
       ELSE
         l_full_period_end_date := add_months(p_start_date,l_full_periods*12)-1;
       END IF;
 --commented for bug#5122566
 /*ELSIF upper(p_price_uom) = l_halfyear
 THEN
       l_full_periods := floor(months_between(p_end_date+1,p_start_date)/6);
       IF l_full_periods =months_between(p_end_date+1,p_start_date)/6 THEN
         l_full_period_end_date := p_end_date;
       ELSE
         l_full_period_end_date := add_months(p_start_date,l_full_periods*6)-1;
       END IF;*/
 ELSIF upper(p_price_uom) = l_quarter
 THEN

       l_full_periods := floor(months_between(p_end_date+1,p_start_date)/3);
       IF l_full_periods = months_between(p_end_date+1,p_start_date)/3 THEN
         l_full_period_end_date := p_end_date;
       ELSE
         l_full_period_end_date := add_months(p_start_date,l_full_periods*3)-1;
       END IF;


 ELSIF upper(p_price_uom) = l_month
 THEN
       l_full_periods := floor(months_between(p_end_date+1,p_start_date));
       IF l_full_periods = months_between(p_end_date+1,p_start_date) THEN
         l_full_period_end_date := p_end_date;
       ELSE
         l_full_period_end_date := add_months(p_start_date,l_full_periods)-1;
       END IF;

 ELSIF upper(p_price_uom) = l_week
 THEN
       l_full_periods := FLOOR((p_end_date+1 -p_start_date)/7);
       l_full_period_end_date := (p_start_date + l_full_periods*7)-1;
 ELSIF upper(p_price_uom) = l_day
 THEN
       l_full_periods := (p_end_date+1 -p_start_date);
       l_full_period_end_date := p_end_date;
 ELSE
       l_full_periods := GET_QTY_FOR_DAYS(p_end_date+1-p_start_date,p_price_uom);
       IF l_full_periods is NOT NULL  --HR,MIN are covered in ths loop
       THEN
           l_full_period_end_date := p_end_date;
       ELSE
          l_confactor_yr := get_con_factor(p_price_uom,l_year);  --Bugno:4654304.Added by Jvorugan
          IF l_confactor_yr is NOT NULL    --user defined tce in terms of year
          THEN
             l_full_periods := floor(months_between(p_end_date+1,p_start_date)/(l_confactor_yr*12));
             IF l_full_periods = months_between(p_end_date+1,p_start_date)/(l_confactor_yr*12) THEN
                l_full_period_end_date := p_end_date;
             ELSE
                l_full_period_end_date := add_months(p_start_date,l_full_periods*(l_confactor_yr*12))-1;
             END IF;     -- End of changes for Bugno:4654304
          ELSE
           l_confactor_mth := get_con_factor(p_price_uom,l_month);
           IF l_confactor_mth is NOT NULL    --user defined tce in terms of month
           THEN
              l_full_periods := floor(months_between(p_end_date+1,p_start_date)/l_confactor_mth);
              IF l_full_periods = months_between(p_end_date+1,p_start_date)/l_confactor_mth THEN
                l_full_period_end_date := p_end_date;
              ELSE
                l_full_period_end_date := add_months(p_start_date,l_full_periods*l_confactor_mth)-1;
              END IF;

           ELSE
             l_confactor_day := get_con_factor(p_price_uom,l_day);
             IF l_confactor_day is NOT NULL   --user defined tce in terms of day
             THEN
                l_full_periods :=  FLOOR((p_end_date+1 -p_start_date)/l_confactor_day);
                l_full_period_end_date := (p_start_date + l_full_periods*l_confactor_day)-1;
             ELSE
                RAISE INVALID_MAPPING_EXCEPTION;  --No mapping available in tce
             END IF;     --user defined in terms of day
           END IF;       --user define din terms of month
          END IF;        --user defined in terms of year
       END IF;           --HR,MIN
 END IF;              --outer if
 x_full_periods := l_full_periods;
 IF x_full_periods =0
 THEN
 x_full_period_end_date := NULL;
 ELSE
 x_full_period_end_date := l_full_period_end_date;
 END IF;
 EXCEPTION
 WHEN
    INVALID_UOM_EXCEPTION
    THEN
      OKC_API.SET_MESSAGE(p_app_name    => 'OKS',
                         p_msg_name     => 'OKS_INVD_UOM_CODE',
                         p_token1       => 'OKS_API_NAME',
                         p_token1_value => 'OKS_TIME_MEASURES_PUB.get_full_periods',
                         p_token2       => 'UOM_CODE',
                         p_token2_value => p_price_uom );
      close cs_validate_uom;
      x_return_status := OKC_API.G_RET_STS_ERROR;
      x_full_periods := NULL;
      x_full_period_end_date := NULL;
 WHEN
    INVALID_DATE_EXCEPTION
    THEN
      OKC_API.set_message('OKC','OKC_REP_INV_EFF_DATE_SD');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      x_full_periods := NULL;
      x_full_period_end_date := NULL;
 WHEN
    INVALID_MAPPING_EXCEPTION
    THEN
       OKC_API.set_message(
         p_app_name     => G_APP_NAME,
         p_msg_name     => 'OKS_INVALID_TIME_MAPPING',
         p_token1       => 'TOKEN1',
         p_token1_value =>  p_price_uom);
      x_return_status := OKC_API.G_RET_STS_ERROR;
      x_full_periods := NULL;
      x_full_period_end_date := NULL;
 WHEN OTHERS THEN
                 OKC_API.set_message(G_APP_NAME,
                                     G_UNEXPECTED_ERROR,
                                     G_SQLCODE_TOKEN,
                                     SQLCODE,
                                     G_SQLERRM_TOKEN,
                                     SQLERRM);
                 x_return_status := OKC_API.G_RET_STS_ERROR;
                 x_full_periods := NULL;
                 x_full_period_end_date := NULL;


END get_full_periods;

------------------------------------------------------------------------
/* This function takes source_uom and target_uom as input parameters and searches
for a common tce_code for both  in okc_time_code_units_b. If it finds common tce_code
it calculates source_uom in terms of the target_uom and returns the value. Else
it returns null
*/

FUNCTION get_con_factor(p_source_uom IN VARCHAR2,
                          p_target_uom IN VARCHAR2)
return NUMBER
as
CURSOR get_common_uom(p_source_uom IN VARCHAR2,p_target_uom IN VARCHAR2)
is
  SELECT tce_code,quantity
  FROM okc_time_code_units_b
  WHERE uom_code = p_source_uom
  AND tce_code in (SELECT tce_code FROM okc_time_code_units_b WHERE uom_code=p_target_uom)
  ORDER BY quantity ASC;

CURSOR time_code_unit(p_source_uom IN varchar2, p_target_uom IN VARCHAR2)
is
  SELECT  quantity
  FROM okc_time_code_units_b
  WHERE  tce_code = p_source_uom
  AND    active_flag = 'Y'
  AND    uom_code = p_target_uom;

l_quantity1 NUMBER :=0;
l_quantity2 NUMBER :=0;
l_target_qty NUMBER;
l_tce_code varchar2(40);

BEGIN

   open get_common_uom(p_source_uom,p_target_uom);
   fetch get_common_uom into l_tce_code,l_quantity1;
   close get_common_uom;
   IF (l_quantity1 >0)
   THEN
        open time_code_unit(l_tce_code,p_target_uom);
        fetch time_code_unit into l_quantity2;
        close time_code_unit;
        IF(l_quantity2 >0) THEN
          l_target_qty:= (l_quantity1)/(l_quantity2);
          IF (l_target_qty > 0) THEN
              return l_target_qty;
          ELSE
	          return NULL;
	      END IF;
	    ELSE
	      return NULL;
	    END IF;
   ELSE
     return NULL;
   END IF;

 EXCEPTION
 WHEN OTHERS THEN
                 OKC_API.set_message(G_APP_NAME,
                                     G_UNEXPECTED_ERROR,
                                     G_SQLCODE_TOKEN,
                                     SQLCODE,
                                     G_SQLERRM_TOKEN,
                                     SQLERRM);
                 return NULL;


END get_con_factor;

------------------------------------------------------------------------

FUNCTION get_months_between(p_start_date    IN DATE,
                            p_end_date      IN DATE)
return NUMBER
as

l_no_of_months NUMBER;

l_days_start   NUMBER := days_in_month(p_start_date);
l_days_end     NUMBER := days_in_month(p_end_date);
l_dd_start     NUMBER ;
l_dd_end       NUMBER ;

BEGIN

 l_dd_start  := to_number(to_char(p_start_date,'DD'));
 l_dd_end    := to_number(to_char(p_end_date,'DD'));

 if   end_of_month(p_start_date) and end_of_month(p_end_date)
 then
   l_no_of_months := months_between(p_end_date,p_start_date);
 elsif end_of_month(p_start_date)
 then
   if to_number(to_char(p_start_date,'MM')) = 2
     and l_dd_end >= l_dd_start
   then
     l_no_of_months:= floor(months_between(p_end_date,p_start_date))-1+(l_dd_end/l_days_end);
   else
     l_no_of_months:= floor(months_between(p_end_date,p_start_date))+(l_dd_end/l_days_end);
   end if;
 elsif end_of_month(p_end_date)
 then
   if to_number(to_char(p_end_date,'MM')) = 2
     and l_dd_start > l_dd_end
   then
     l_no_of_months:= ((l_days_start- l_dd_start)/l_days_start)+floor(months_between(p_end_date,p_start_date))+1;
   else
     l_no_of_months:= ((l_days_start- l_dd_start)/l_days_start)+floor(months_between(p_end_date,p_start_date));
   end if;
 elsif (l_dd_start = l_dd_end)
 then
    l_no_of_months := months_between(p_end_date,p_start_date);
 else
   l_no_of_months:= ((l_days_start- l_dd_start)/l_days_start)+floor(months_between(p_end_date,p_start_date))+(l_dd_end/l_days_end);
 end if;

 return l_no_of_months;

END;

-----------------------------------------------------------------------------------
END OKS_TIME_MEASURES_PUB;


/
